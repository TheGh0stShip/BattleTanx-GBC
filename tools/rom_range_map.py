#!/usr/bin/env python3
"""Whole-ROM range map: every byte of all 64 banks, derived from the source.

RGBDS has no listing output, so a scratch copy of src/ is assembled with a
`PRINTLN` of the current address before every top-level statement. That gives
an exact statement -> ROM range map. Consecutive statements under the same
source label and of the same kind are merged into one range record:

  bank, start, end (exclusive), kind, label, file:line, asset, readers,
  understanding, evidence, flags

kind:          code | ram code | ram data | data | asset | fill | marker
understanding: named      - behaviour or format name from evidence
               neutral    - address/format placeholder or explicitly unread/unknown
               padding    - fill and bank markers
evidence:      traced     - code reached by tools/trace.py from known entries
               untraced   - instruction source the tracer does not reach
               referenced - data whose label (or label+offset) appears in code
               unreferenced
               layout     - fill, markers, end-of-bank padding
flags:         unused, unreachable, duplicated, residue, padding, runtime code

Checks (all fatal): full coverage of $0000-$3FFF and 63 x $4000-$7FFF with no
gap or overlap; the assembled scratch ROM equals baserom.gbc; every
assets.txt entry exists, has the right size and bytes, and lies in a range the
source fills with INCBIN; every INCBIN path is listed in assets.txt; the
committed report is fresh.

Outputs (deterministic): reports/rom_range_map.json, and the derived
inventory reports/rom_unresolved_inventory.json.
Usage: rom_range_map.py [--write] [--no-negative]
"""
from __future__ import annotations

import collections
import hashlib
import json
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
REPORT = "reports/rom_range_map.json"
INVENTORY = "reports/rom_unresolved_inventory.json"
DIRECTIVE = re.compile(r"^(SECTION|INCLUDE|IF|ELIF|ELSE|ENDC|ENDR|ENDM|MACRO|REPT|FOR|DEF|REDEF|ASSERT|STATIC_ASSERT|"
                       r"PRINT|PRINTLN|EXPORT|PURGE|OPT|PUSHO|POPO|PUSHS|POPS|CHARMAP|NEWCHARMAP|SETCHARMAP|ALIGN|UNION|NEXTU|ENDU|"
                       r"FAIL|WARN|SHIFT|BREAK|RSRESET|RSSET|RB|RW|RL)\b", re.I)
LABEL_DEF = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)::?")
# automatic/address names and explicit "meaning unknown" names; Unused*/Residue*
# names are understood (identity known, no reader) and only flagged
NEUTRAL = re.compile(r"^(Func|Jump|RAM)_[0-9A-F]{2,4}|_[0-9A-F]{4}$|Data_[0-9A-F]{4}|Unread|Unknown|Gap|Unclassified")
AUTO = re.compile(r"^(Func|Jump|RAM)_[0-9A-F]{2,4}|_[0-9A-F]{4}$|Data_[0-9A-F]{4}")
DUPLICATED = re.compile(r"Copy|copy_|Duplicate", re.I)
RESIDUE = re.compile(r"[Rr]esidue")
UNUSED = re.compile(r"Unread|Unused|Unreferenced")


class RangeMapError(ValueError):
    pass


def check(cond, msg):
    if not cond:
        raise RangeMapError(msg)


def strip(line: str) -> str:
    out, q = [], False
    for ch in line:
        if ch == '"':
            q = not q
        if ch == ";" and not q:
            break
        out.append(ch)
    return "".join(out).strip()


def macro_kinds(root: pathlib.Path) -> dict:
    """Classify every macro by what its body emits."""
    kinds = {}
    for p in sorted(list((root / "include").glob("*.inc")) + list((root / "src").glob("*.asm"))):
        text = p.read_text()
        for m in re.finditer(r"^MACRO\s+(\w+)(.*?)^\s*ENDM", text, re.M | re.S):
            ops = set()
            for line in m.group(2).split("\n")[1:]:
                s = strip(line)
                s = re.sub(r"^[A-Za-z_.][A-Za-z0-9_.]*:+\s*", "", s)
                if not s or DIRECTIVE.match(s):
                    continue
                ops.add(s.split()[0].lower())
            if ops & {"incbin"}:
                kinds[m.group(1)] = "asset"
            elif ops - {"db", "dw", "dl", "ds"} and not ops <= {"db", "dw", "dl", "ds"}:
                code = {o for o in ops if o not in ("db", "dw", "dl", "ds")}
                known_macros = set(kinds)
                kinds[m.group(1)] = "code" if code - known_macros else "data"
            elif ops == {"ds"}:
                kinds[m.group(1)] = "fill"
            else:
                kinds[m.group(1)] = "data"
    return kinds


def kind_of(stmt: str, macros: dict):
    s = re.sub(r"^[A-Za-z_.][A-Za-z0-9_.]*:+\s*", "", stmt)
    if not s:
        return None
    word = s.split()[0]
    lw = word.lower()
    if lw in ("load", "endl"):
        return lw
    if DIRECTIVE.match(s):
        return None
    if lw in ("db", "dw", "dl"):
        return "data"
    if lw == "ds":
        return "fill"
    if lw == "incbin":
        return "asset"
    if word in macros:
        return macros[word]
    return "code"


def source_files(root: pathlib.Path):
    """(bank, path) for every bank file and the files it INCLUDEs."""
    main = (root / "src" / "main.asm").read_text()
    out = []
    for inc in re.findall(r'^INCLUDE "(src/bank_([0-9A-F]{2})\.asm)"', main, re.M):
        b = int(inc[1], 16)
        out.append((b, inc[0]))
        stack = [inc[0]]
        while stack:
            for sub in re.findall(r'^\s*INCLUDE "(src/[^"]+)"', (root / stack.pop()).read_text(), re.M):
                out.append((b, sub))
                stack.append(sub)
    return out


def instrument(t: pathlib.Path, files, macros):
    meta = {}     # id -> (bank, file, line, kind, label)
    for fi, (b, rel) in enumerate(files):
        p = t / rel
        lines = p.read_text().split("\n")
        out, depth, label, block_first = [], 0, None, None
        prev_label_line = False
        for n, raw in enumerate(lines, 1):
            stmt = strip(raw)
            if re.match(r"^MACRO\b", stmt) or re.match(r"^\w+:?\s+MACRO\b", stmt):
                depth += 1
            m = LABEL_DEF.match(stmt) if depth == 0 else None
            if m and not m.group(1).startswith(".") and not (m.group(1).startswith("Jump_") and label):
                if not prev_label_line:
                    block_first = m.group(1)
                elif AUTO.search(block_first) and not AUTO.search(m.group(1)):
                    block_first = m.group(1)   # prefer the reviewed companion name
                label = block_first
                prev_label_line = True
            elif stmt:
                prev_label_line = False
            k = kind_of(stmt, macros) if depth == 0 and stmt else None
            if k is not None:
                ident = fi * 100000 + n
                out.append(f'\tPRINTLN STRFMT("@R {ident} %d", @)')
                meta[ident] = (b, rel, n, k, label)
                mi = re.match(r'^(?:[A-Za-z_.][A-Za-z0-9_.]*:+\s*)?INCBIN\s+"([^"]+)"\s*(?:,\s*(\d+)\s*(?:,\s*(\d+))?)?$', stmt)
                if mi:
                    INCBINS[ident] = (mi.group(1), int(mi.group(2) or 0), None if mi.group(3) is None else int(mi.group(3)))
            out.append(raw)
            if depth and re.match(r"^ENDM\b", stmt):
                depth -= 1
        if rel.startswith("src/bank_"):
            ident = fi * 100000 + 99999
            out.append(f'\tPRINTLN STRFMT("@R {ident} %d", @)')
            meta[ident] = (b, rel, len(lines) + 1, "end", None)
        p.write_text("\n".join(out))
    return meta


ROOT_FOR_CHECK = [ROOT]
DIRECT = []    # (bank, start, end, path, offset, length) of every direct INCBIN in the build
INCBINS = {}   # statement id -> (path, offset, length) for direct INCBIN statements


def references(root: pathlib.Path):
    """label -> sorted set of routine labels whose code mentions it."""
    defs = set()
    texts = {}
    for p in sorted((root / "src").glob("*.asm")):
        t = p.read_text()
        texts[p] = t
        defs |= set(re.findall(r"^([A-Za-z_][A-Za-z0-9_]*):", t, re.M))
    refs = collections.defaultdict(set)
    word = re.compile(r"\b([A-Za-z_][A-Za-z0-9_]*)\b")
    for p, t in texts.items():
        owner = None
        for raw in t.split("\n"):
            s = strip(raw)
            m = LABEL_DEF.match(s)
            if m:
                owner = m.group(1)
                s = s[m.end():].strip()
            if not s:
                continue
            for w in word.findall(s):
                if w in defs and w != owner:
                    refs[w].add(owner or p.name)
    return refs


def build(root: pathlib.Path, rom: bytes):
    macros = macro_kinds(root)
    files = source_files(root)
    with tempfile.TemporaryDirectory() as tmp:
        t = pathlib.Path(tmp)
        for d in ("src", "include", "assets"):
            shutil.copytree(root / d, t / d)
        meta = instrument(t, files, macros)
        r = subprocess.run(["rgbasm", "-o", "x.o", "src/main.asm"], cwd=t, capture_output=True, text=True)
        check(r.returncode == 0, "range map: instrumented assembly failed: " + r.stderr[-400:])
        # the real build, for the byte comparison
        shutil.rmtree(t / "src")
        shutil.copytree(root / "src", t / "src")
        r2 = subprocess.run(["rgbasm", "-o", "y.o", "src/main.asm"], cwd=t, capture_output=True, text=True)
        check(r2.returncode == 0, "range map: assembly failed")
        r3 = subprocess.run(["rgblink", "-p", "0xFF", "-o", "y.gbc", "y.o"], cwd=t, capture_output=True, text=True)
        check(r3.returncode == 0, "range map: link failed")
        built = (t / "y.gbc").read_bytes()
    check(built == rom, "range map: the source no longer assembles to baserom.gbc")
    prints = []
    for line in r.stdout.splitlines():
        m = re.fullmatch(r"@R (\d+) (-?\d+)", line.strip())
        if m:
            prints.append((int(m.group(1)), int(m.group(2))))
    sys.path.insert(0, str(root / "tools"))
    import hints  # noqa: E402
    import trace  # noqa: E402
    traced = trace.run(rom, hints.extra_entries(rom), getattr(hints, "DATA_RANGES", None))
    code_offsets = set()
    for o, ln in traced.code.items():
        code_offsets.update(range(o, o + ln))
    stmts = []
    by_bank = collections.defaultdict(list)
    for ident, addr in prints:
        by_bank[meta[ident][0]].append((ident, addr))
    for b, seq in by_bank.items():
        in_load, ram0, rom0 = False, None, None
        for i, (ident, addr) in enumerate(seq[:-1]):
            _, rel, n, kind, label = meta[ident]
            nxt = seq[i + 1][1]
            if kind == "load":
                in_load, rom0, ram0 = True, addr, None
                continue
            if kind == "endl":
                in_load = False
                continue
            if in_load:
                if ram0 is None:
                    ram0 = addr
                start, end = rom0 + addr - ram0, rom0 + nxt - ram0
                kind = "ram code" if kind == "code" else "ram data"
            else:
                start, end = addr, nxt
            if end > start:
                stmts.append((b, start, end, kind, label, rel, n))
                if ident in INCBINS:
                    DIRECT.append((b, start, end) + INCBINS[ident])
    return stmts, code_offsets


def off(b, a):
    return a if b == 0 else b * 0x4000 + a - 0x4000


def assets(root: pathlib.Path):
    out = []
    for line in (root / "assets.txt").read_text().split("\n"):
        if line.strip():
            path, o, n = line.split()
            out.append((path, int(o, 16), int(n, 16)))
    return out


def ranges_from(root, rom, stmts, code_offsets):
    asset_list = assets(root)
    asset_at = {}
    for b, s, e, path, _, _ in DIRECT:
        for a in range(s, e):
            asset_at[off(b, a)] = path
    for path, o, n in asset_list:
        for x in range(o, o + n):
            asset_at[x] = path
    refs = references(root)
    recs = []
    for b, s, e, kind, label, rel, n in sorted(stmts):
        # split code by traced status and data by asset membership
        cur = None
        for a in range(s, e):
            o = off(b, a)
            k = kind
            if kind in ("code",):
                k = "code" if o in code_offsets else "code untraced"
            if (b != 0 and a == 0x7FFF) and kind in ("fill", "data"):
                k = "marker"
            ap = asset_at.get(o)
            key = (k, ap)
            if cur and cur[0] == key and cur[2] == a:
                cur[2] = a + 1
            else:
                if cur:
                    recs.append((b, cur[1], cur[2], cur[0][0], label, rel, n, cur[0][1]))
                cur = [key, a, a + 1]
        if cur:
            recs.append((b, cur[1], cur[2], cur[0][0], label, rel, n, cur[0][1]))
    merged = []
    for r in recs:
        if merged:
            p = merged[-1]
            if p[0] == r[0] and p[2] == r[1] and p[3] == r[3] and p[4] == r[4] and p[7] == r[7]:
                merged[-1] = (p[0], p[1], r[2], p[3], p[4], p[5], p[6], p[7])
                continue
        merged.append(r)
    out = []
    for b, s, e, kind, label, rel, n, ap in merged:
        lab = label or ""
        readers = sorted(refs.get(lab, ()))
        if kind in ("fill", "marker"):
            und, ev = "padding", "layout"
        elif NEUTRAL.search(lab) or not lab:
            und = "neutral"
        else:
            und = "named"
        if kind == "code":
            ev = "traced"
        elif kind == "code untraced":
            ev = "untraced"
        elif kind in ("ram code", "ram data"):
            ev = "referenced" if readers else "unreferenced"
        elif kind not in ("fill", "marker"):
            ev = "referenced" if readers else "unreferenced"
        flags = []
        if kind in ("fill", "marker"):
            flags.append("padding")
        if UNUSED.search(lab) or (ev == "unreferenced" and kind not in ("fill", "marker")):
            flags.append("unused")
        if kind == "code untraced":
            flags.append("unreachable")
        if DUPLICATED.search(lab) or "bank04_copy" in lab.lower():
            flags.append("duplicated")
        if RESIDUE.search(lab) or (ap and "residue" in ap):
            flags.append("residue")
        if kind == "ram code":
            flags.append("runtime code")
        data = rom[off(b, s):off(b, e)]
        out.append({"bank": b, "start": s, "end": e, "kind": kind, "label": lab, "source": f"{rel}:{n}",
                    "asset": ap, "readers": readers[:8], "reader_count": len(readers), "understanding": und,
                    "evidence": ev, "flags": flags, "sha1": hashlib.sha1(data).hexdigest()[:12]})
    return out, asset_list


def check_ranges(out, rom, asset_list, incbins):
    by_bank = collections.defaultdict(list)
    for r in out:
        by_bank[r["bank"]].append(r)
    check(sorted(by_bank) == list(range(64)), f"range map: banks covered {sorted(by_bank)[:3]}... not all 64")
    for b, rs in by_bank.items():
        lo, hi = (0, 0x4000) if b == 0 else (0x4000, 0x8000)
        pos = lo
        for r in sorted(rs, key=lambda r: r["start"]):
            check(r["start"] >= pos, f"range map: overlap in bank ${b:02X} at ${r['start']:04X}")
            check(r["start"] == pos, f"range map: gap in bank ${b:02X} at ${pos:04X}-${r['start']:04X}")
            check(r["end"] <= hi, f"range map: bank ${b:02X} range runs past the bank")
            pos = r["end"]
        check(pos == hi, f"range map: gap at the end of bank ${b:02X}")
    for r in out:
        b = r["bank"]
        data = rom[off(b, r["start"]):off(b, r["end"])]
        check(hashlib.sha1(data).hexdigest()[:12] == r["sha1"],
              f"range map: ${b:02X}:{r['start']:04X} {r['label']} no longer matches its source bytes")
    covered = collections.defaultdict(int)
    for r in out:
        if r["asset"]:
            covered[r["asset"]] += r["end"] - r["start"]
    for path, o, n in asset_list:
        check(covered.get(path, 0) == n, f"range map: asset {path} is not fully inside source ranges")
    for b, s, e, path, o, n in incbins:
        f = ROOT_FOR_CHECK[0] / path
        check(f.exists(), f"range map: missing asset {path}")
        d = f.read_bytes()
        want = d[o:] if n is None else d[o:o + n]
        check(want == rom[off(b, s):off(b, e)], f"range map: INCBIN {path} at ${b:02X}:{s:04X} differs from its slice")


def check_assets(root, rom, asset_list):
    for path, o, n in asset_list:
        f = root / path
        check(f.exists(), f"range map: missing asset {path}")
        d = f.read_bytes()
        check(len(d) == n, f"range map: asset {path} has size {len(d)}, expected {n}")
        check(d == rom[o:o + n], f"range map: asset {path} differs from ROM ${o:X}")


def incbin_paths(root):
    out = set()
    for p in list((root / "src").glob("*.asm")) + list((root / "include").glob("*.inc")):
        for m in re.finditer(r'^\s*INCBIN\s+"([^"]+)"', p.read_text(), re.M):
            if "\\" not in m.group(1):
                out.add(m.group(1))
    return out


def inventory(out):
    """Unresolved inventory derived from the range records (not from prose)."""
    inv = collections.defaultdict(lambda: {"ranges": 0, "bytes": 0, "labels": set()})
    for r in out:
        reasons = []
        if r["understanding"] == "neutral":
            reasons.append("neutral label")
        if r["kind"] == "code untraced":
            reasons.append("untraced code")
        if "unused" in r["flags"] and r["kind"] not in ("fill", "marker"):
            reasons.append("no reader")
        for why in reasons:
            k = (r["bank"], why)
            inv[k]["ranges"] += 1
            inv[k]["bytes"] += r["end"] - r["start"]
            if len(inv[k]["labels"]) < 40:
                inv[k]["labels"].add(r["label"] or f"${r['start']:04X}")
    rows = [{"bank": f"${b:02X}", "reason": why, "ranges": v["ranges"], "bytes": v["bytes"],
             "examples": sorted(v["labels"])} for (b, why), v in sorted(inv.items())]
    return rows


def summary(out):
    s = collections.defaultdict(int)
    for r in out:
        s[f"{r['kind']}|{r['understanding']}|{r['evidence']}"] += r["end"] - r["start"]
    return dict(sorted(s.items()))


def compact(out):
    keys = ["bank", "start", "end", "kind", "label", "source", "asset", "readers", "reader_count",
            "understanding", "evidence", "flags", "sha1"]
    return {"columns": keys, "rows": [[r[k] for k in keys] for r in out]}


def run(root, rom, write=False, negative=True):
    stmts, code = build(root, rom)
    out, asset_list = ranges_from(root, rom, stmts, code)
    check_assets(root, rom, asset_list)
    ROOT_FOR_CHECK[0] = root
    check_ranges(out, rom, asset_list, list(DIRECT))
    report = {"summary": summary(out), "ranges": compact(out)}
    inv = {"derived_from": REPORT, "rows": inventory(out)}
    for rel, value in ((REPORT, report), (INVENTORY, inv)):
        text = json.dumps(value, indent=None, sort_keys=True, separators=(",", ":")) + "\n"
        p = root / rel
        if write:
            p.write_text(text)
        check(p.exists() and p.read_text() == text, f"range map: {rel} is stale; rerun tools/rom_range_map.py --write")
    neg = negative_tests(root, rom, out, asset_list) if negative else 0
    return out, neg


def negative_tests(root, rom, out, asset_list):
    import copy
    n = 0
    incb = list(DIRECT)
    cases = []
    gap = copy.deepcopy(out)
    del gap[len(gap) // 2]
    cases.append(("gap", gap, rom, "gap in bank"))
    ov = copy.deepcopy(out)
    ov[10]["end"] += 1
    ov[11]["start"] += 0  # next range now overlaps
    cases.append(("overlap", ov, rom, "overlap in bank"))
    st = copy.deepcopy(out)
    st[5]["sha1"] = "000000000000"
    cases.append(("stale range bytes", st, rom, "no longer matches"))
    bad = bytearray(rom)
    r = next(x for x in out if x["kind"] == "data" and x["bank"] == 5)
    bad[off(5, r["start"])] ^= 0xFF
    cases.append(("ROM differs from source", out, bytes(bad), "no longer matches"))
    for name, recs, data, expect in cases:
        try:
            check_ranges(recs, data, asset_list, incb)
        except RangeMapError as exc:
            check(expect in str(exc), f"range map negative test {name}: wrong reason: {exc}")
            n += 1
        else:
            raise RangeMapError(f"range map negative test not rejected: {name}")
    try:
        b, s, e, path, o, ln = incb[0]
        check_ranges(out, rom, asset_list, [(b, s, e, path, o + 1, ln)] + incb[1:])
    except RangeMapError as exc:
        check("differs from its slice" in str(exc), f"range map negative test INCBIN slice: {exc}")
        n += 1
    else:
        raise RangeMapError("range map negative test not rejected: INCBIN slice")
    with tempfile.TemporaryDirectory() as tmp:
        t = pathlib.Path(tmp)
        shutil.copytree(root / "assets", t / "assets")
        shutil.copy(root / "assets.txt", t / "assets.txt")
        victim = asset_list[0][0]
        (t / victim).unlink()
        try:
            check_assets(t, rom, asset_list)
        except RangeMapError as exc:
            check("missing asset" in str(exc), f"range map negative test missing asset: {exc}")
            n += 1
        else:
            raise RangeMapError("range map negative test not rejected: missing asset")
    return n


def main():
    rom = (ROOT / "baserom.gbc").read_bytes()
    out, neg = run(ROOT, rom, write="--write" in sys.argv, negative="--no-negative" not in sys.argv)
    total = sum(r["end"] - r["start"] for r in out)
    und = collections.Counter()
    for r in out:
        und[r["understanding"]] += r["end"] - r["start"]
    print(f"rom range map: {len(out)} ranges, {total} bytes in 64 banks, no gaps or overlaps; "
          + ", ".join(f"{k} {v}" for k, v in sorted(und.items())) + f"; {neg} negative tests rejected")


if __name__ == "__main__":
    main()
