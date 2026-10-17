#!/usr/bin/env python3
"""Structural validator for ROM banks $01-$05.

Every fact is derived from baserom.gbc and from code bytes in the ROM, then
compared with the checked-in source. See docs/research/banks_01_05/.
Run by `make banks0105` (part of `make check`).
"""
from __future__ import annotations

import hashlib
import json
import pathlib
import re
import struct
import shutil
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
REPORTS = ROOT / "reports"


class Banks0105Error(ValueError):
    pass


def check(cond, msg):
    if not cond:
        raise Banks0105Error(msg)


def off(bank, addr):
    return addr if bank == 0 else bank * 0x4000 + addr - 0x4000


def rd(rom, bank, addr, n=1):
    return rom[off(bank, addr):off(bank, addr) + n]


def word(rom, bank, addr):
    return rom[off(bank, addr)] | rom[off(bank, addr) + 1] << 8


# ------------------------------------------------------------------ effect tables
EFFECT_STEPS, EFFECT_STEP_COUNT, EFFECT_REACHABLE = 0x6358, 72, 19


def check_effect_tables(rom):
    # ROM0 StartScreenEffect: ld a,$58 / ld [$C95D],a / ld a,$63 / ld [$C95E],a and $C959 = $4B
    check(rom.find(bytes.fromhex("3e58ea5dc93e63ea5ec9"), 0, 0x4000) >= 0, "effect: step table pointer $6358 not set in ROM0")
    check(rom.find(bytes.fromhex("3e4bea59c9"), 0, 0x4000) >= 0, "effect: countdown $4B not set in ROM0")
    recs, tmpls = {}, {}
    for s in range(EFFECT_STEP_COUNT):
        for k in range(3):
            p = word(rom, 5, EFFECT_STEPS + 6 * s + 2 * k)
            if p:
                check(0x59E0 <= p < EFFECT_STEPS, f"effect: step {s} part pointer {p:04X} outside the part area")
                count, src, tp = rd(rom, 5, p)[0], word(rom, 5, p + 1), word(rom, 5, p + 3)
                check(1 <= count <= 16, f"effect: part {p:04X} tile count {count}")
                check(0x44A8 <= src and src + 16 * count <= 0x60F0, f"effect: part {p:04X} tile source {src:04X} outside bank $08 sprite area")
                check(0x59E0 <= tp < EFFECT_STEPS, f"effect: part {p:04X} template {tp:04X} outside the part area")
                recs[p] = (count, src, tp)
                if tp in tmpls:
                    check(tmpls[tp] == count, f"effect: template {tp:04X} used with different counts")
                tmpls[tp] = count
    check(len(recs) == 72 and len(tmpls) == 72, f"effect: {len(recs)} parts / {len(tmpls)} templates, expected 72/72")
    for tp, n in tmpls.items():
        for i in range(n):
            attr = rd(rom, 5, tp + 4 * i + 3)[0]
            check(attr in (0x08, 0x28, 0x48, 0x68), f"effect: template {tp:04X} entry {i} attribute {attr:02X}")
    check(not any(rd(rom, 5, EFFECT_STEPS + 6 * EFFECT_STEP_COUNT, 0x7FFF - (EFFECT_STEPS + 6 * EFFECT_STEP_COUNT))),
          "effect: bytes after the step table are not zero")
    return len(recs)


# ------------------------------------------------------------------ velocity table
def check_velocity_table(rom):
    for c in range(16):
        mag = (c + 1) * 0x60
        for d in range(16):
            x, y = struct.unpack("<ii", rd(rom, 5, 0x4600 + (c * 16 + d) * 8, 8))
            if d % 4 == 0:
                want = {0: (0, -mag), 4: (mag, 0), 8: (0, mag), 12: (-mag, 0)}[d]
                check((x, y) == want, f"velocity: class {c} direction {d} is {(x, y)}, expected {want}")
            check(abs(x) <= mag and abs(y) <= mag, f"velocity: class {c} direction {d} exceeds magnitude")
    check(not any(rd(rom, 5, 0x4E00, 0xA0)), "velocity: $4E00-$4E9F not zero")


# ------------------------------------------------------------------ bank $05 copies of bank $04
COPIES = [(0x40B1, 0x24F), (0x431E, 0xE2), (0x452C, 0xD4)]


def check_bank04_copies(rom):
    for a, n in COPIES:
        check(rd(rom, 5, a, n) == rd(rom, 4, a, n), f"bank $05 ${a:04X}: no longer a copy of bank $04")


# ------------------------------------------------------------------ fills and markers
FILLS = {1: "Bank01ZeroFill", 2: "Bank02ZeroFill"}


def check_fills(rom, sym):
    for b, label in FILLS.items():
        start = sym[label][1]
        check(not any(rd(rom, b, start, 0x7FFF - start)), f"bank ${b:02X}: non-zero byte in fill")
    for b in range(1, 6):
        check(rd(rom, b, 0x7FFF)[0] == b, f"bank ${b:02X}: marker")


# ------------------------------------------------------------------ indirect target tables
def check_dispatch_tables(rom, sym):
    def table(label, n):
        b, a = sym[label]
        return [word(rom, b, a + 2 * i) for i in range(n)]
    ent = table("EntityHandlerTable", 10)
    check(all(0x4000 <= t < 0x8000 for t in ent), "dispatch: EntityHandlerTable target outside ROMX")
    st = table("StateCheckTable", 15)
    check(all(0x4000 <= t < 0x8000 for t in st), "dispatch: StateCheckTable target outside ROMX")
    rc = table("RuntimeCallbackTable", 3)
    check(all(t < 0x4000 for t in rc), "dispatch: RuntimeCallbackTable target outside ROM0")
    by_addr = {(b, a) for b, a in sym.values()}
    for name, targets, bank in (("EntityHandlerTable", ent, 1), ("StateCheckTable", st, 3), ("RuntimeCallbackTable", rc, 0)):
        for t in targets:
            check((bank, t) in by_addr, f"dispatch: {name} target {t:04X} has no label")
    return len(ent) + len(st) + len(rc)


# ------------------------------------------------------------------ source structure
SUPERSEDED = ["assets/bank_05/59E0.bin", "assets/bank_02/66DC.bin", "assets/bank_01/7D5D.bin",
              "assets/bank_05/40B1.bin", "assets/bank_05/431E.bin", "assets/bank_05/452C.bin",
              "assets/bank_05/bank04_copy_40B1.bin", "assets/bank_05/bank04_copy_431E.bin",
              "assets/bank_05/bank04_copy_452C.bin"]


def check_source(root):
    text = "".join((root / "src" / f"bank_{b:02X}.asm").read_text() for b in range(1, 6))
    for a in SUPERSEDED:
        check(f'"{a}"' not in text, f"source: superseded blob {a} included again")
    check("INCLUDE \"src/screen_effect_tables.asm\"" in text, "source: effect tables not included")
    check("ObjectVelocityTable:" in text, "source: velocity table not explicit")
    check("bank05_bank04_copy_40b1" in text and "bank05_bank04_copy_431e" in text and
          "bank05_bank04_copy_452c" in text, "source: bank $04 residue macros not used")


def check_recorded_path_source(root):
    """Keep the shipped recorded-path feature's unreachable entry explicit.

    The only routine that enables object slot-flag bit 6 and primes the ring is
    UnusedStartRecordedPathFollow.  Its name must occur only at its definition;
    adding a source operand creates a real route that needs fresh analysis.
    The ring appender itself has exactly one caller, inside that unused entry.
    """
    sources = {
        p: p.read_text()
        for p in sorted((root / "src").glob("*.asm"))
    }
    all_text = "".join(sources.values())
    check(all_text.count("UnusedStartRecordedPathFollow") == 1,
          "recorded path: unused initializer gained a source reference")
    check(all_text.count("call AppendRecordedPathWaypoint") == 1,
          "recorded path: appender caller set changed")
    bank3 = sources[root / "src" / "bank_03.asm"]
    initializer = bank3.index("UnusedStartRecordedPathFollow:")
    appender_call = bank3.index("call AppendRecordedPathWaypoint")
    next_entry = bank3.index("SetObjectVelocityTowardPoint:")
    check(initializer < appender_call < next_entry,
          "recorded path: appender is no longer called only by the unused initializer")


# ------------------------------------------------------------------ bank $01 structures
def check_picture_descriptors(rom, sym):
    b, a = sym["MenuState05PictureDescriptors"]
    for i in range(3):
        r = rd(rom, b, a + 16 * i, 16)
        check(r[0] == 0x2E, f"pictures: descriptor {i} bank {r[0]:02X}")
        check(r[9] == 0x40 and not any(r[10:]), f"pictures: descriptor {i} tail")
        for k in range(4):
            p = r[1 + 2 * k] | r[2 + 2 * k] << 8
            check(0x4000 <= p < 0x8000, f"pictures: descriptor {i} pointer {k}")


def check_indexed_sprite_grids(rom, sym):
    b, a = sym["IndexedSpriteGridDescriptors"]
    check((b, a) == (2, 0x41F7), "indexed grids: descriptor table moved")
    expected = ((0x4AD0, 0x30, 0x20), (0x4830, 0x20, 0x40))
    for i, (source, x, y) in enumerate(expected):
        r = rd(rom, b, a + 4 * i, 4)
        got = (r[0] | r[1] << 8, r[2], r[3])
        check(got == (source, x, y),
              f"indexed grids: descriptor {i} is {got}, expected {(source, x, y)}")
        check(source + 40 * 16 in (0x4D50, 0x4AB0),
              f"indexed grids: descriptor {i} does not bound 40 tiles")
    check(sym["IndexedSpriteGrid0Tiles"] == (2, 0x4AD0), "indexed grids: grid 0 symbol")
    check(sym["IndexedSpriteGrid1Tiles"] == (2, 0x4830), "indexed grids: grid 1 symbol")
    check(sym["UnusedIndexedSpriteGridTiles"] == (2, 0x4AB0), "indexed grids: unused tiles symbol")
    check(sym["Bank02ObjPalette7"] == (2, 0x4D50), "indexed grids: palette symbol")
    # The loader writes $27 to HDMA5: (value + 1) * $10 = 40 tiles.
    # Its nested counters stop after 10 columns and 4 rows.
    _, loader = sym["LoadIndexedSpriteGrid"]
    code = rd(rom, 2, loader, 0xC0)
    check(bytes.fromhex("3e27e055") in code, "indexed grids: 40-tile HDMA length changed")
    check(bytes.fromhex("7bc6085ffe50") in code and bytes.fromhex("7ac60857fe20") in code,
          "indexed grids: 10-by-4 OAM dimensions changed")
    return len(expected)


def check_bank01_screen_pointer_residue(rom, sym):
    label = "Bank01ScreenMode06PointerResidue"
    check(sym[label] == (2, 0x481E), "screen pointer residue: symbol moved")
    check(rd(rom, 2, 0x481E, 2) == rd(rom, 1, 0x481E, 2),
          "screen pointer residue: no longer matches bank $01 at the same address")
    check(word(rom, 2, 0x481E) == sym["Func_2C_5F9F"][1],
          "screen pointer residue: value is not ScreenMode06_LoadTiles")


def check_palettes(rom, sym):
    for label, n in (("MenuCursorObjectPalette", 3), ("PasswordBgPalettes", 16), ("PasswordObjPaletteColours", 6),
                     ("BurstObjPalettes", 32), ("Bank02ObjPalette7Colours", 3)):
        b, a = sym[label]
        for i in range(n):
            check(not word(rom, b, a + 2 * i) & 0x8000, f"palette: {label} word {i} bit 15 set")
    for label, n in (("UnusedPasswordBgPalette", 4), ("UnusedPasswordObjPaletteColours", 3),
                     ("Bank02UnusedPaletteRecord5E81", 4)):
        b, a = sym[label]
        for i in range(n):
            check(not word(rom, b, a + 2 * i) & 0x8000, f"palette: {label} word {i} bit 15 set")
    check(sym["Bank02Unknown5E80"] == (2, 0x5E80), "palette residue: leading byte symbol moved")
    check(rd(rom, 2, 0x5E80, 1) == b"\x08", "palette residue: leading byte changed")
    check(sym["Bank02UnusedPaletteRecord5E81"] == (2, 0x5E81),
          "palette residue: record symbol moved")


# ------------------------------------------------------------------ assets
def asset_manifest(root):
    out = {}
    for b in range(1, 6):
        for m in re.finditer(r'INCBIN "([^"]+)"', (root / "src" / f"bank_{b:02X}.asm").read_text()):
            data = (root / m.group(1)).read_bytes()
            out[m.group(1)] = {"bytes": len(data), "sha1": hashlib.sha1(data).hexdigest(), "bank": f"${b:02X}"}
    return dict(sorted(out.items()))


def check_assets(root, rom):
    lines = {l.split()[0]: (int(l.split()[1], 0), int(l.split()[2], 0))
             for l in (root / "assets.txt").read_text().splitlines() if len(l.split()) == 3}
    for path, info in asset_manifest(root).items():
        check(path in lines, f"asset: {path} missing from assets.txt")
        start, size = lines[path]
        check(size == info["bytes"], f"asset: {path} size {info['bytes']} != manifest {size}")
        check((root / path).read_bytes() == rom[start:start + size], f"asset: {path} differs from its ROM range")


def check_ram_include(root):
    inc = (root / "include" / "banks_01_05_ram.inc").read_text()
    names = re.findall(r"^DEF (\w+)\s+EQU \$([0-9A-F]{4})", inc, re.M)
    other = "".join(p.read_text() for p in (root / "include").glob("*.inc") if p.name != "banks_01_05_ram.inc")
    for n, a in names:
        check(not re.search(rf"\bDEF {n}\b", other), f"ram: {n} defined twice")
        v = int(a, 16)
        check(0xC000 <= v < 0xE000 or 0xFF80 <= v < 0xFFFF, f"ram: {n} = ${a} outside WRAM/HRAM")
    check(len({a for _, a in names}) == len(names), "ram: two symbols share an address")
    all_source = "".join(path.read_text() for path in (root / "src").glob("*.asm"))
    check(all_source.count("wVestigialStateC8E6") == 3,
          "ram: vestigial $C8E6 access set changed")
    check("wC8E6" not in all_source and "$C8E6" not in all_source,
          "ram: raw or obsolete $C8E6 reference remains")
    return len(names)


# Scene interrupt images (installed by InstallSceneInterruptHandlers, or copied
# for the window split) that call bank-$01 ROM directly, without mapping bank $01.
# They are safe only while bank $01 is mapped whenever they can fire; see
# docs/research/banks_01_05/INDIRECT_CONTROL_FLOW.md. This pins the set of such
# calls so a new one cannot appear unnoticed.
SCENE_IMAGES = {"Bank01RomImage_5D77": "SceneStatHandler", "Bank01RomImage_5E16": "SceneVBlankHandler",
                "Bank01RomImage_5BD6": "StepSceneWindowSplit"}
SCENE_BANK1_CALLS = {("SceneStatHandler", "Bank01RomImage_5EE0"), ("SceneVBlankHandler", "StartSceneTileRowHdma"),
                     ("StepSceneWindowSplit", "Bank01RomImage_5F26")}
_LEN3 = {0x01, 0x11, 0x21, 0x31, 0x08, 0xC2, 0xC3, 0xC4, 0xCA, 0xCC, 0xCD, 0xD2, 0xD4, 0xDA, 0xDC, 0xEA, 0xFA}
_LEN2 = {0x06, 0x0E, 0x16, 0x1E, 0x26, 0x2E, 0x36, 0x3E, 0x18, 0x20, 0x28, 0x30, 0x38, 0xC6, 0xCE, 0xD6, 0xDE,
         0xE6, 0xEE, 0xF6, 0xFE, 0xE0, 0xF0, 0xE8, 0xF8, 0xCB}


def check_scene_interrupt_calls(root, rom, sym):
    src = (root / "src" / "bank_01.asm").read_text()
    by_addr = {}
    for n, (b, a) in sorted(sym.items()):
        if b == 1 and "." not in n:
            by_addr.setdefault(a, n)
    found = set()
    for image, owner in SCENE_IMAGES.items():
        m = re.search(rf"ld hl, {image}\n\tld de, \$([0-9A-F]{{4}})\n", src)
        check(m, f"scene interrupts: copy of {image} not found")
        start = sym[image][1]
        end = start + int(m.group(1), 16)
        a = start
        while a < end:
            op = rom[off(1, a)]
            if op in (0xC2, 0xC3, 0xC4, 0xCA, 0xCC, 0xCD, 0xD2, 0xD4, 0xDA, 0xDC):
                target = word(rom, 1, a + 1)
                if 0x4000 <= target < 0x8000:
                    found.add((owner, by_addr.get(target, f"${target:04X}")))
            a += 3 if op in _LEN3 else 2 if op in _LEN2 else 1
        check(a == end, f"scene interrupts: {owner} image does not decode to its end")
    check(found == SCENE_BANK1_CALLS, f"scene interrupts: bank-$01 ROM calls changed: {sorted(found ^ SCENE_BANK1_CALLS)}")
    return len(found)


# ------------------------------------------------------------------ reports
def build_reports(root, rom, sym):
    sys.path.insert(0, str(root / "tools"))
    import byte_accounting_01_05 as A  # noqa: E402
    acc = A.classify(root, rom)
    accounting = {f"${b:02X}": r["counts"] for b, r in acc.items()}
    for b, r in acc.items():
        check(r["unclassified"] == 0 and sum(r["counts"].values()) == 0x4000, f"accounting: bank ${b:02X} not fully classified")
    labels = {}
    for b in range(1, 6):
        names = [n for n, (bb, a) in sym.items() if bb == b and 0x4000 <= a < 0x8000 and "." not in n]
        labels[f"${b:02X}"] = {"total": len(names),
                               "address_named": sum(1 for n in names if re.match(r"^(Func|Jump)_0[1-5]_[0-9A-F]{4}$|^Bank0[1-5](Data|Code)_[0-9A-F]{4}$", n))}
    pins = sorted(set(re.findall(r'ASSERT BANK\((\w+)\) == \$([0-9A-F]{2}) && \1 == \$([0-9A-F]{4}), "([^"]+)"',
                                 "".join((root / "src" / f"bank_{b:02X}.asm").read_text() for b in range(1, 6)))))
    return {"accounting": accounting, "labels": labels,
            "pins": [{"label": l, "bank": f"${b}", "address": f"${a}", "reason": r} for l, b, a, r in pins],
            "assets": asset_manifest(root)}


def check_reports(root, rom, sym, reports_dir):
    data = build_reports(root, rom, sym)
    for name, value in data.items():
        p = reports_dir / f"banks_01_05_{name}.json"
        check(p.exists(), f"report: {p.name} missing")
        check(json.loads(p.read_text()) == value, f"report: {p.name} is stale; rerun tools/banks_01_05.py --write")
    return data


def read_sym(path):
    out = {}
    for line in path.read_text().splitlines():
        m = re.fullmatch(r"([0-9a-fA-F]{2}):([0-9a-fA-F]{4}) (\S+)", line.strip())
        if m:
            out[m.group(3)] = (int(m.group(1), 16), int(m.group(2), 16))
    return out


def validate(root, rom, sym):
    parts = check_effect_tables(rom)
    check_velocity_table(rom)
    check_bank04_copies(rom)
    check_fills(rom, sym)
    n = check_dispatch_tables(rom, sym)
    check_picture_descriptors(rom, sym)
    grids = check_indexed_sprite_grids(rom, sym)
    check_bank01_screen_pointer_residue(rom, sym)
    check_palettes(rom, sym)
    check_source(root)
    check_recorded_path_source(root)
    check_assets(root, rom)
    check_ram_include(root)
    check_scene_interrupt_calls(root, rom, sym)
    return parts, n, grids


def negative_tests(root, rom, sym):
    def poke(changes):
        d = bytearray(rom)
        for (b, a), v in changes.items():
            d[off(b, a)] = v
        return bytes(d)
    i_step = rom.find(bytes.fromhex("3e58ea5dc93e63ea5ec9"), 0, 0x4000)
    cases = [
        ("effect step pointer", {(0, i_step + 1): 0x59}, "step table pointer"),
        ("effect part pointer", {(5, EFFECT_STEPS + 1): 0x30}, "outside the part area"),
        ("effect tile count", {(5, 0x59E0): 0x00}, "tile count"),
        ("effect template attribute", {(5, 0x59EF + 3): 0x09}, "attribute"),
        ("effect fill", {(5, 0x7000): 0x01}, "after the step table"),
        ("velocity value", {(5, 0x4604): 0x00}, "velocity: class 0 direction 0"),
        ("velocity gap", {(5, 0x4E10): 0x01}, "not zero"),
        ("bank $04 copy", {(5, 0x40B1): rom[off(5, 0x40B1)] ^ 1}, "no longer a copy"),
        ("bank $02 fill", {(2, 0x7000): 0x01}, "bank $02: non-zero"),
        ("bank marker", {(3, 0x7FFF): 0x00}, "bank $03: marker"),
        ("dispatch target", {(1, sym["EntityHandlerTable"][1] + 1): 0x00}, "EntityHandlerTable target"),
        ("indexed grid descriptor", {(2, sym["IndexedSpriteGridDescriptors"][1]): 0xD1}, "descriptor 0"),
        ("screen pointer residue", {(2, 0x481E): rom[off(2, 0x481E)] ^ 1}, "screen pointer residue"),
    ]
    n = 0
    for name, chg, expect in cases:
        try:
            validate(root, poke(chg), sym)
        except Banks0105Error as exc:
            check(expect in str(exc), f"negative test {name} rejected for the wrong reason: {exc}")
            n += 1
            continue
        raise Banks0105Error(f"negative test not rejected: {name}")
    # source-structure negative test on a scratch copy
    import shutil
    import tempfile
    with tempfile.TemporaryDirectory() as tmp:
        t = pathlib.Path(tmp)
        shutil.copytree(root / "src", t / "src")
        p = t / "src" / "bank_02.asm"
        p.write_text(p.read_text() + '\n\tINCBIN "assets/bank_02/66DC.bin"\n')
        try:
            check_source(t)
        except Banks0105Error as exc:
            check("superseded blob" in str(exc), f"negative test source: {exc}")
            n += 1
        else:
            raise Banks0105Error("negative test not rejected: superseded blob")
    with tempfile.TemporaryDirectory() as tmp:
        t = pathlib.Path(tmp)
        shutil.copytree(root / "src", t / "src")
        p = t / "src" / "bank_01.asm"
        p.write_text(p.read_text() + "\n\tcall UnusedStartRecordedPathFollow\n")
        try:
            check_recorded_path_source(t)
        except Banks0105Error as exc:
            check("unused initializer gained a source reference" in str(exc),
                  f"negative test recorded-path caller: {exc}")
            n += 1
        else:
            raise Banks0105Error("negative test not rejected: recorded-path caller")
    extra = [
        ("scene interrupt call", {(1, 0x5E3B): 0x81}, "bank-$01 ROM calls changed"),
        ("scene interrupt new call", {(1, sym["Bank01RomImage_5D77"][1] + i): v for i, v in enumerate((0xCD, 0x00, 0x50, 0x00))}, "bank-$01 ROM calls changed"),
        ("picture descriptor bank", {(1, sym["MenuState05PictureDescriptors"][1]): 0x2D}, "descriptor 0 bank"),
        ("picture descriptor padding", {(1, sym["MenuState05PictureDescriptors"][1] + 12): 0x01}, "descriptor 0 tail"),
        ("palette bit 15", {(2, sym["BurstObjPalettes"][1] + 1): 0x80}, "BurstObjPalettes word 0"),
        ("unused palette record bit 15", {(2, 0x5E82): 0x80},
         "Bank02UnusedPaletteRecord5E81 word 0"),
    ]
    for name, chg, expect in extra:
        try:
            validate(root, poke(chg), sym)
        except Banks0105Error as exc:
            check(expect in str(exc), f"negative test {name} rejected for the wrong reason: {exc}")
            n += 1
            continue
        raise Banks0105Error(f"negative test not rejected: {name}")
    with tempfile.TemporaryDirectory() as tmp:
        t = pathlib.Path(tmp)
        for d in ("src", "include", "assets", "reports"):
            shutil.copytree(root / d, t / d)
        shutil.copy(root / "assets.txt", t / "assets.txt")
        a = t / "assets" / "bank_02" / "burst_tiles.2bpp"
        orig = a.read_bytes()
        for name, mut, expect in (
            ("asset hash", lambda: a.write_bytes(orig[:-1] + bytes([orig[-1] ^ 1])), "differs from its ROM range"),
            ("asset size", lambda: a.write_bytes(orig[:-16]), "size"),
        ):
            mut()
            try:
                check_assets(t, rom)
            except Banks0105Error as exc:
                check(expect in str(exc), f"negative test {name}: {exc}")
                n += 1
            else:
                raise Banks0105Error(f"negative test not rejected: {name}")
            a.write_bytes(orig)
        inc = t / "include" / "banks_01_05_ram.inc"
        itxt = inc.read_text()
        inc.write_text(itxt.replace("ENDC", "DEF wDuplicateTest EQU $C6C1\nENDC"))
        try:
            check_ram_include(t)
        except Banks0105Error as exc:
            check("share an address" in str(exc), f"negative test ram duplicate: {exc}")
            n += 1
        else:
            raise Banks0105Error("negative test not rejected: ram duplicate")
        inc.write_text(itxt)
        rep = t / "reports" / "banks_01_05_accounting.json"
        rtxt = rep.read_text()
        rep.write_text(rtxt.replace("1", "2", 1))
        try:
            check_reports(t, rom, sym, t / "reports")
        except Banks0105Error as exc:
            check("is stale" in str(exc), f"negative test stale report: {exc}")
            n += 1
        else:
            raise Banks0105Error("negative test not rejected: stale report")
    return n


def main():
    rom = (ROOT / "baserom.gbc").read_bytes()
    sym = read_sym(ROOT / "battletanx.sym")
    if "--write" in sys.argv:
        REPORTS.mkdir(exist_ok=True)
        for name, value in build_reports(ROOT, rom, sym).items():
            (REPORTS / f"banks_01_05_{name}.json").write_text(json.dumps(value, indent=1, sort_keys=True) + "\n")
    parts, n, grids = validate(ROOT, rom, sym)
    data = check_reports(ROOT, rom, sym, REPORTS)
    neg = negative_tests(ROOT, rom, sym)
    print(f"banks 01-05: {parts} effect parts and templates, 16x16 velocity table, {grids} indexed sprite grids, 3 bank-$04 copies, recorded-path initializer unreachable, "
          f"{n} dispatch targets labelled, {len(data['pins'])} pins, {len(data['assets'])} assets; "
          f"{neg} negative tests rejected")


if __name__ == "__main__":
    main()
