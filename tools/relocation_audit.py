#!/usr/bin/env python3
"""Relocation audit for banks $09-$3A.

Writes (with --write) and validates three machine-readable reports under
reports/:
  range_map_09_3A.json         every byte of banks $09-$3A, from the linked symbols
  raw_references_09_3A.json    every address into banks $09-$3A that the program
                               stores as a raw number, with its pin
  asset_manifest_09_3A.json    every asset assembled into banks $09-$3A

Raw references are derived from the ROM, not from source text:
  $01:ScrollingSceneDescriptors  36 x (bank, tiles, rows, last row, palette)
  $01:$596D                      3 x (bank, tiles, tile map, attr map, palettes)
  $05:ObjectOrientationTilePointers  16 tile pointers into banks $27-$29
  $01:7981                       ld bc, $6CE9 / ld de, $6FB9 (bank $2C)
Each must be pinned in the target bank source by
  ASSERT BANK(Label) == $BB && Label == $AAAA, ...
so that moving the target stops the build. Bank bytes stored raw (scene
descriptors, ScreenModeTable) must be pinned by ASSERT BANK(Label) == $BB.
"""
from __future__ import annotations

import hashlib
import json
import pathlib
import re
import sys

SCOPE = range(0x09, 0x3B)
ROOT = pathlib.Path(__file__).resolve().parent.parent
REPORTS = ROOT / "reports"


class AuditError(ValueError):
    pass


def check(cond, msg):
    if not cond:
        raise AuditError(msg)


def off(bank, addr):
    return addr if bank == 0 else bank * 0x4000 + addr - 0x4000


def word(rom, bank, addr):
    return rom[off(bank, addr)] | rom[off(bank, addr) + 1] << 8


def read_sym(path):
    by_addr, by_name = {}, {}
    for line in path.read_text().splitlines():
        m = re.fullmatch(r"([0-9a-fA-F]{2}):([0-9a-fA-F]{4}) (\S+)", line.strip())
        if m:
            b, a, n = int(m.group(1), 16), int(m.group(2), 16), m.group(3)
            by_name[n] = (b, a)
            if "." not in n:
                by_addr.setdefault((b, a), []).append(n)
    return by_addr, by_name


def symbolic_scroll_entries(root):
    """Indexes of ScrollingSceneDescriptors entries written with labels in bank_01.asm."""
    text = (root / "src" / "bank_01.asm").read_text()
    body = text.split("ScrollingSceneDescriptors:\n", 1)[1].split("\n\n", 1)[0]
    ops = [l.split(None, 1)[1] for l in body.splitlines() if l.strip().startswith(("db ", "dw "))]
    out = set()
    for i in range(len(ops) // 4):
        words = ops[4 * i + 1].split(", ") + [ops[4 * i + 3]]
        if all(not w.strip().startswith("$") for w in words):
            out.add(i)
    return out


def raw_references(rom, symbolic=frozenset()):
    """(target bank, address, source description) for raw addresses into scope."""
    refs = []
    base = 0x5A60 - 0x4000 + 0x4000      # $01:5A60, ScrollingSceneDescriptors
    for i in range(36):
        e = rom[off(1, 0x5A60) + 8 * i:off(1, 0x5A60) + 8 * i + 8]
        if e[0] not in SCOPE or i in symbolic:
            continue
        for k, v in (("tiles", e[1] | e[2] << 8), ("rows", e[3] | e[4] << 8), ("palette", e[6] | e[7] << 8)):
            refs.append((e[0], v, f"$01:ScrollingSceneDescriptors[{i}].{k}"))
    for i in range(3):
        e = rom[off(1, 0x596D) + 16 * i:off(1, 0x596D) + 16 * i + 9]
        for k, n in enumerate(("tiles", "tilemap", "attrmap", "palettes")):
            refs.append((e[0], e[1 + 2 * k] | e[2 + 2 * k] << 8, f"$01:$596D[{i}].{n}"))
    for i in range(16):
        v = word(rom, 5, 0x4020 + 2 * i)
        for b in (0x27, 0x28, 0x29):
            refs.append((b, v, f"$05:ObjectOrientationTilePointers[{i}] (bank $27 + [$FF80])"))
    seq = bytes.fromhex("01e96c11b96f")      # ld bc, $6CE9 / ld de, $6FB9
    i = rom.find(seq, 0x4000, 0x8000)
    check(i >= 0, "$01:7981 alternate-map operands not found")
    refs += [(0x2C, 0x6CE9, "$01:7981 ld bc"), (0x2C, 0x6FB9, "$01:7981 ld de")]
    return refs


def pins_in_source(root):
    pins, bank_pins = {}, {}
    for b in SCOPE:
        text = (root / "src" / f"bank_{b:02X}.asm").read_text()
        for lab, bb, addr in re.findall(r"ASSERT BANK\((\w+)\) == \$([0-9A-F]{2}) && \1 == \$([0-9A-F]{4})", text):
            pins[(int(bb, 16), int(addr, 16))] = lab
        for lab, bb in re.findall(r"ASSERT BANK\((\w+)\) == \$([0-9A-F]{2})", text):
            bank_pins[lab] = int(bb, 16)
    return pins, bank_pins


def raw_bank_bytes(root, rom):
    """Labels whose bank is stored as a raw byte in out-of-scope tables."""
    src1 = (root / "src" / "bank_01.asm").read_text()
    out = {}
    for bank, a, b in re.findall(r"screen_mode \$([0-9A-F]{2}), (\w+), (\w+)", src1):
        out[a] = out[b] = (int(bank, 16), "$01:ScreenModeTable")
    # Walk descriptor lines in order: a raw `db $BB` before a `dw` of scene labels is a
    # bank byte; `db BANK(...)` is symbolic and needs no pin. The single `db` before a
    # palette `dw` is the entry's last-row index, so palettes inherit the entry bank.
    entry_bank = None
    lines = src1.split("\n")
    for i in range(len(lines) - 1):
        a, b = lines[i].strip(), lines[i + 1].strip()
        m = re.fullmatch(r"dw ((?:Fixed|Scroll)Scene\w+(?:, \w+)*)", b)
        if not m:
            continue
        names = m.group(1).split(", ")
        if len(names) == 1 and names[0].endswith("Palette"):
            bank = entry_bank
        elif a.startswith("db BANK("):
            entry_bank = bank = None
        else:
            mm = re.fullmatch(r"db \$([0-9A-F]{2})", a)
            entry_bank = bank = int(mm.group(1), 16) if mm else None
        if bank is None:
            continue
        for n in names:
            out[n] = (bank, "$01 scene descriptor bank byte")
    return out


def build_reports(root, rom, sym_path):
    by_addr, by_name = read_sym(sym_path)
    pins, bank_pins = pins_in_source(root)
    refs = []
    for b, a, src in raw_references(rom, symbolic_scroll_entries(root)):
        labels = by_addr.get((b, a), [])
        refs.append({"target": f"${b:02X}:{a:04X}", "labels": labels, "source": src,
                     "classification": "ROM pointer stored as a raw number outside this assignment",
                     "disposition": "pinned" if (b, a) in pins else "UNPINNED",
                     "pin_label": pins.get((b, a))})
    bank_refs = [{"label": n, "bank": f"${bb:02X}", "source": src,
                  "disposition": "pinned" if bank_pins.get(n) == bb else "UNPINNED"}
                 for n, (bb, src) in sorted(raw_bank_bytes(root, rom).items())]
    ranges = []
    for b in SCOPE:
        labs = sorted({a: n for (bb, a), ns in by_addr.items() if bb == b and 0x4000 <= a < 0x8000
                       for n in [sorted(ns)[0]]}.items())
        starts = [a for a, _ in labs]
        if not starts or starts[0] != 0x4000:
            labs = [(0x4000, f"bank_{b:02X}_start")] + labs
        for i, (a, n) in enumerate(labs):
            end = labs[i + 1][0] if i + 1 < len(labs) else 0x8000
            ranges.append({"bank": f"${b:02X}", "start": f"${a:04X}", "end": f"${end - 1:04X}",
                           "bytes": end - a, "label": n, "aliases": sorted(set(by_addr.get((b, a), [])) - {n})})
    manifest = {}
    assets_txt = {}
    for line in (root / "assets.txt").read_text().splitlines():
        f = line.split()
        if len(f) == 3:
            assets_txt[f[0]] = (int(f[1], 0), int(f[2], 0))
    for b in SCOPE:
        p = f"src/bank_{b:02X}.asm"
        for m in re.finditer(r'INCBIN "([^"]+)"(?:, *([^,\n;]+))?(?:, *([^\n;]+))?', (root / p).read_text()):
            rel = m.group(1)
            data = (root / rel).read_bytes()
            e = manifest.setdefault(rel, {"bytes": len(data), "sha1": hashlib.sha1(data).hexdigest(),
                                          "rom_range": None, "consumers": []})
            if rel in assets_txt:
                s, n = assets_txt[rel]
                e["rom_range"] = f"{s:#x}+{n:#x}"
            if p not in e["consumers"]:
                e["consumers"].append(p)
    return ({"banks": "09-3A", "ranges": ranges},
            {"raw_pointers": refs, "raw_bank_bytes": bank_refs},
            {"assets": dict(sorted(manifest.items()))})


def validate(root, rom, sym_path, reports_dir):
    rm, rr, am = build_reports(root, rom, sym_path)
    unpinned = [r for r in rr["raw_pointers"] if r["disposition"] != "pinned"]
    check(not unpinned, f"raw pointer not pinned: {unpinned[0]['target']} from {unpinned[0]['source']}" if unpinned else "")
    nolab = [r for r in rr["raw_pointers"] if not r["labels"]]
    check(not nolab, f"raw pointer target has no label: {nolab[0]['target'] if nolab else ''}")
    ub = [r for r in rr["raw_bank_bytes"] if r["disposition"] != "pinned"]
    check(not ub, f"raw bank byte not pinned: {ub[0]['label'] if ub else ''}")
    for b in SCOPE:
        cover = sum(r["bytes"] for r in rm["ranges"] if r["bank"] == f"${b:02X}")
        check(cover == 0x4000, f"range map for bank ${b:02X} covers {cover} bytes")
    for name, data in (("range_map_09_3A.json", rm), ("raw_references_09_3A.json", rr),
                       ("asset_manifest_09_3A.json", am)):
        p = reports_dir / name
        check(p.exists(), f"missing report {name}")
        check(json.loads(p.read_text()) == data, f"report {name} is stale; rerun tools/relocation_audit.py --write")
    return rm, rr, am


def negative_tests(root, rom, sym_path):
    import shutil
    import tempfile
    n = 0
    with tempfile.TemporaryDirectory() as tmp:
        t = pathlib.Path(tmp)
        shutil.copytree(root / "src", t / "src")
        shutil.copytree(root / "assets", t / "assets")
        shutil.copy(root / "assets.txt", t / "assets.txt")
        shutil.copytree(root / "reports", t / "reports")
        cases = []
        p2e = t / "src" / "bank_2E.asm"
        txt2e = p2e.read_text()
        cases.append(("dropped address pin", lambda: p2e.write_text(re.sub(r"\tASSERT BANK\(Picture596D0_Tiles\)[^\n]*\n", "", txt2e)),
                      lambda: p2e.write_text(txt2e), "raw pointer not pinned"))
        cases.append(("wrong pin address", lambda: p2e.write_text(txt2e.replace("Picture596D0_Tiles == $689A", "Picture596D0_Tiles == $689B")),
                      lambda: p2e.write_text(txt2e), "raw pointer not pinned"))
        p2b = t / "src" / "bank_2B.asm"
        txt2b = p2b.read_text()
        p01 = t / "src" / "bank_01.asm"
        txt01 = p01.read_text()

        def raw_bank_byte_without_pin():
            # reintroduce one raw ScreenModeTable bank byte and drop its pin
            p01.write_text(re.sub(r"screen_mode BANK\(Func_2B_4000\)", "screen_mode $2B", txt01, count=1))
            p2b.write_text(re.sub(r'\tASSERT BANK\(Func_2B_4000\) == \$2B[^\n]*\n', "", txt2b))

        def restore_bank_byte():
            p01.write_text(txt01)
            p2b.write_text(txt2b)
        cases.append(("raw bank byte without pin", raw_bank_byte_without_pin, restore_bank_byte, "raw bank byte not pinned"))
        rep = t / "reports" / "asset_manifest_09_3A.json"
        rtxt = rep.read_text()
        cases.append(("stale report", lambda: rep.write_text(rtxt.replace('"bytes": 4096', '"bytes": 4097', 1)),
                      lambda: rep.write_text(rtxt), "is stale"))
        for name, mut, restore, expect in cases:
            mut()
            try:
                validate(t, rom, sym_path, t / "reports")
            except AuditError as exc:
                check(expect in str(exc), f"negative test {name} rejected for the wrong reason: {exc}")
                n += 1
            else:
                raise AuditError(f"negative test not rejected: {name}")
            finally:
                restore()
        # ROM-side: a raw table value that no pin covers
        bad = bytearray(rom)
        bad[off(1, 0x596D) + 1] ^= 0x10
        try:
            validate(root, bytes(bad), sym_path, root / "reports")
        except AuditError as exc:
            check("raw pointer" in str(exc), f"negative test moved table value: {exc}")
            n += 1
        else:
            raise AuditError("negative test not rejected: moved table value")
    return n


def main():
    rom = (ROOT / "baserom.gbc").read_bytes()
    sym = ROOT / "battletanx.sym"
    if "--write" in sys.argv:
        REPORTS.mkdir(exist_ok=True)
        for name, data in zip(("range_map_09_3A.json", "raw_references_09_3A.json", "asset_manifest_09_3A.json"),
                              build_reports(ROOT, rom, sym)):
            (REPORTS / name).write_text(json.dumps(data, indent=1) + "\n")
    rm, rr, am = validate(ROOT, rom, sym, REPORTS)
    n = negative_tests(ROOT, rom, sym)
    print(f"relocation: {len(rr['raw_pointers'])} raw pointers and {len(rr['raw_bank_bytes'])} raw bank bytes pinned; "
          f"{len(rm['ranges'])} ranges cover banks $09-$3A; {len(am['assets'])} assets; {n} negative tests rejected")


if __name__ == "__main__":
    main()
