#!/usr/bin/env python3
"""Parser and validator for object graphics banks $27-$29.

Facts are derived from baserom.gbc and from the readers documented in
BANKS_27_29_RESEARCH.md:
  ROM0 LoadObjectPalettes  maps $27/$28/$29, loads OBJ palettes 0/1/2 from $4512
  ROM0 Func_057D           writes colour 0 = $0000, then 3 colours (6 bytes)
  ROM0 Func_0F43           maps [$FF80] + $27, copies 9 tiles from
                           $05:ObjectOrientationTilePointers[[$FF81]]
  ROM0 Func_0F0C           writes 9 OAM entries from
                           $05:ObjectOrientationLayoutPointers[[$FF81]]
"""
from __future__ import annotations

import hashlib
import pathlib
import re

BANKS = (0x27, 0x28, 0x29)
BANK_SIZE = 0x4000
FRAME_TILES, FRAMES, ORIENTATIONS = 9, 9, 16
FRAME_SIZE = FRAME_TILES * 16
FRAMES_END = 0x4000 + FRAMES * FRAME_SIZE            # $4510
UNKNOWN_WORD = 0x4510
PALETTE = 0x4512
RESIDUE_START, RESIDUE_END = 0x4518, 0x4BFC
LAYOUT_PTRS, TILE_PTRS = 0x4000, 0x4020               # bank $05
LAYOUT_NORMAL, LAYOUT_FLIPPED = 0x4040, 0x4064        # bank $05, 9 x 4 bytes
EXPECTED_UNKNOWN = {0x27: 0x318C, 0x28: 0x6739, 0x29: 0x6739}
ASSET_SHA1 = {
    # filled from the committed assets; see BANKS_27_29_RESEARCH.md
}
SYMBOLS = {}
for _b in BANKS:
    SYMBOLS[f"Bank{_b:02X}OrientationTiles"] = (_b, 0x4000)
    for _f in range(FRAMES):
        SYMBOLS[f"Bank{_b:02X}OrientationFrame{_f}"] = (_b, 0x4000 + _f * FRAME_SIZE)
    SYMBOLS[f"Bank{_b:02X}Unknown4510"] = (_b, UNKNOWN_WORD)
    SYMBOLS[f"Bank{_b:02X}ObjectPalette"] = (_b, PALETTE)
    SYMBOLS[f"Bank{_b:02X}Bank26Residue"] = (_b, RESIDUE_START)


class ObjectBankError(ValueError):
    pass


def check(cond: bool, msg: str) -> None:
    if not cond:
        raise ObjectBankError(msg)


def off(bank: int, addr: int) -> int:
    return addr if bank == 0 else bank * BANK_SIZE + addr - 0x4000


def word(rom: bytes, bank: int, addr: int) -> int:
    return int.from_bytes(rom[off(bank, addr):off(bank, addr) + 2], "little")


def find_routine(rom: bytes, pattern: bytes, name: str) -> int:
    i = rom.find(pattern, 0, 0x4000)
    check(i >= 0 and rom.find(pattern, i + 1, 0x4000) < 0, f"{name}: code pattern not found once")
    return i


def parse(rom: bytes) -> list[tuple[int, int, int, str]]:
    """Validate everything; return (bank, start, end, class) ranges."""
    # --- bank selection and palette destinations (ROM0 LoadObjectPalettes)
    for slot, bank in enumerate(BANKS):
        pat = bytes([0x3E, bank, 0xEA, 0x00, 0x20, 0x21, 0x12, 0x45, 0x06, slot, 0x0E, 0x01, 0xCD, 0x7D, 0x05])
        check(rom.find(pat, 0, 0x4000) >= 0,
              f"palette loader: bank ${bank:02X} -> OBJ palette {slot} sequence missing")
    # colour 0 written as zero by Func_057D: xor a / ld [de],a / ld [de],a then 6 x ld a,[hli]/ld [de],a
    check(rom[0x0596:0x05A5] == bytes.fromhex("af12122a122a122a122a122a122a12"),
          "palette writer Func_057D: colour-0 / 3-colour sequence changed")
    # --- orientation tile copy (ROM0 Func_0F43): bank = [$FF80] + $27, 9 tiles
    i = find_routine(rom, bytes.fromhex("f080c627ea0020"), "Func_0F43 bank select")
    check(rom[i + 7:i + 9] == bytes.fromhex("0609"), "Func_0F43: tile-count loop is not 9")
    # --- OAM layout writer (ROM0 Func_0F0C): 9 entries, attribute | $08
    j = find_routine(rom, bytes.fromhex("0e09cd9020"), "Func_0F0C entry loop")
    check(rom.find(bytes.fromhex("2af608"), j, j + 0x30) >= 0, "Func_0F0C: attribute VRAM-bank bit missing")

    # --- orientation tables in bank $05
    tptr = [word(rom, 5, TILE_PTRS + 2 * k) for k in range(ORIENTATIONS)]
    lptr = [word(rom, 5, LAYOUT_PTRS + 2 * k) for k in range(ORIENTATIONS)]
    for k, p in enumerate(tptr):
        frame = k if k < FRAMES else ORIENTATIONS - k
        check(p == 0x4000 + frame * FRAME_SIZE, f"orientation table entry {k} is {p:#x}")
        check(0x4000 <= p and p + FRAME_SIZE <= FRAMES_END and (p - 0x4000) % FRAME_SIZE == 0,
              f"orientation pointer {k} outside the frame block")
        check(lptr[k] == (LAYOUT_NORMAL if k < FRAMES else LAYOUT_FLIPPED), f"layout pointer {k}")
    normal = rom[off(5, LAYOUT_NORMAL):off(5, LAYOUT_NORMAL) + 36]
    flipped = rom[off(5, LAYOUT_FLIPPED):off(5, LAYOUT_FLIPPED) + 36]
    for t in range(FRAME_TILES):
        y, x, tile, attr = normal[4 * t:4 * t + 4]
        fy, fx, ftile, fattr = flipped[4 * t:4 * t + 4]
        check(tile == t and attr == 0 and y == [0xF4, 0xFC, 0x04][t // 3] and x == [0xF4, 0xFC, 0x04][t % 3],
              f"normal layout record {t}")
        check(ftile == t and fattr == 0x20 and fy == y and fx == (-8 - (x - 256 if x > 127 else x)) & 0xFF,
              f"x-flipped layout record {t}")

    ranges = []
    for bank in BANKS:
        data = rom[bank * BANK_SIZE:(bank + 1) * BANK_SIZE]
        check(word(rom, bank, UNKNOWN_WORD) == EXPECTED_UNKNOWN[bank], f"bank ${bank:02X}: $4510 word changed")
        check(not word(rom, bank, UNKNOWN_WORD) & 0x8000, f"bank ${bank:02X}: $4510 bit 15 set")
        for c in range(3):
            check(not word(rom, bank, PALETTE + 2 * c) & 0x8000, f"bank ${bank:02X}: palette colour {c} bit 15 set")
        prev = rom[off(bank - 1, RESIDUE_START):off(bank - 1, RESIDUE_END)]
        lvl = rom[off(0x26, RESIDUE_START):off(0x26, RESIDUE_END)]
        cur = data[RESIDUE_START - 0x4000:RESIDUE_END - 0x4000]
        check(cur == prev == lvl, f"bank ${bank:02X}: residue no longer equals bank $26")
        check(not any(data[RESIDUE_END - 0x4000:0x3FFF]), f"bank ${bank:02X}: non-zero byte in fill")
        check(data[0x3FFF] == bank, f"bank ${bank:02X}: bank marker")
        ranges += [
            (bank, 0x4000, FRAMES_END, "graphics"),
            (bank, UNKNOWN_WORD, PALETTE, "unknown word"),
            (bank, PALETTE, RESIDUE_START, "palette"),
            (bank, RESIDUE_START, RESIDUE_END, "residue"),
            (bank, RESIDUE_END, 0x7FFF, "fill"),
            (bank, 0x7FFF, 0x8000, "marker"),
        ]
    check_coverage(ranges)
    return ranges


def check_coverage(ranges) -> None:
    for bank in BANKS:
        cursor = 0x4000
        for _, s, e, _ in sorted(r for r in ranges if r[0] == bank):
            check(s == cursor and e > s, f"bank ${bank:02X}: overlap or gap at {cursor:#x}")
            cursor = e
        check(cursor == 0x8000, f"bank ${bank:02X}: coverage ends at {cursor:#x}")


def check_project_files(root: pathlib.Path, sha1: dict, symbols: dict | None) -> None:
    """Source, asset and symbol checks (separate so tests can feed fakes)."""
    for bank in BANKS:
        text = (root / "src" / f"bank_{bank:02X}.asm").read_text()
        check(not re.search(r'INCBIN "assets/bank_%02X/(?!orientation_tiles\.bin")' % bank, text),
              f"bank ${bank:02X}: an opaque blob was reintroduced")
        check("bank26_residue" in text and "orientation_frames" in text,
              f"bank ${bank:02X}: structured layout missing")
    for rel, (size, digest) in sha1.items():
        path = root / rel
        check(path.exists(), f"missing source asset {rel}")
        data = path.read_bytes()
        check(len(data) == size, f"source asset {rel} has size {len(data)}, expected {size}")
        check(hashlib.sha1(data).hexdigest() == digest, f"source asset {rel} hash changed")
    if symbols is not None:
        for name, where in SYMBOLS.items():
            check(symbols.get(name) == where, f"symbol {name} at {symbols.get(name)}, expected {where}")


def read_symbols(path: pathlib.Path) -> dict | None:
    if not path.exists():
        return None
    out = {}
    for line in path.read_text().splitlines():
        m = re.fullmatch(r"([0-9a-fA-F]{2}):([0-9a-fA-F]{4}) (\S+)", line.strip())
        if m:
            out[m.group(3)] = (int(m.group(1), 16), int(m.group(2), 16))
    return out


ASSETS = {
    f"assets/bank_{b:02X}/orientation_tiles.bin": None for b in BANKS
}


def asset_table(root: pathlib.Path, rom: bytes) -> dict:
    """Expected size and SHA-1 of each source asset, derived from the ROM."""
    out = {}
    for b in BANKS:
        data = rom[off(b, 0x4000):off(b, FRAMES_END)]
        out[f"assets/bank_{b:02X}/orientation_tiles.bin"] = (len(data), hashlib.sha1(data).hexdigest())
    lvl = rom[off(0x26, 0x4000):off(0x26, 0x4000) + 64 * 120]
    out["assets/levels/level_14/tilemap.bin"] = (len(lvl), hashlib.sha1(lvl).hexdigest())
    return out


def negative_tests(rom: bytes, root: pathlib.Path) -> int:
    def poke(changes):
        data = bytearray(rom)
        for (bank, addr), value in changes.items():
            data[off(bank, addr)] = value
        return bytes(data)

    load = rom.find(bytes([0x3E, 0x28, 0xEA, 0x00, 0x20]), 0, 0x4000)
    f0f43 = rom.find(bytes.fromhex("f080c627ea0020"), 0, 0x4000)
    rom_cases = {
        "bank selection": ({(0, f0f43 + 3): 0x26}, "Func_0F43 bank select"),
        "bank identity": ({(0, load + 1): 0x2A}, "bank $28 -> OBJ palette 1"),
        "palette destination": ({(0, load + 9): 0x02}, "bank $28 -> OBJ palette 1"),
        "orientation table entry": ({(5, TILE_PTRS + 2 * 12): 0x41}, "orientation table entry 12"),
        "frame boundary": ({(5, TILE_PTRS + 2 * 3): 0xB1}, "orientation table entry 3"),
        "tile count": ({(0, f0f43 + 8): 0x08}, "tile-count loop"),
        "layout record": ({(5, LAYOUT_FLIPPED + 4 * 4 + 3): 0x00}, "x-flipped layout record 4"),
        "layout pointer": ({(5, LAYOUT_PTRS + 2 * 9): 0x40}, "layout pointer 9"),
        "palette value range": ({(0x29, PALETTE + 1): 0x80}, "palette colour 0 bit 15"),
        "unknown word": ({(0x27, UNKNOWN_WORD): 0x8D}, "$4510 word changed"),
        "residue": ({(0x28, 0x4800): 0x00}, "residue"),
        "fill byte": ({(0x27, 0x6000): 0x01}, "non-zero byte in fill"),
        "bank marker": ({(0x29, 0x7FFF): 0x28}, "bank marker"),
    }
    n = 0
    for name, (change, expect) in rom_cases.items():
        try:
            parse(poke(change))
        except ObjectBankError as exc:
            check(expect in str(exc), f"negative test {name} rejected for the wrong reason: {exc}")
            n += 1
            continue
        raise ObjectBankError(f"negative test not rejected: {name}")

    # coverage: drop and overlap a range
    good = parse(rom)
    for name, bad, expect in (
        ("uncovered range", [r for r in good if r[3] != "unknown word"], "gap"),
        ("overlapping range", good + [(0x28, 0x4500, 0x4520, "x")], "overlap"),
    ):
        try:
            check_coverage(bad)
        except ObjectBankError as exc:
            check(expect in str(exc), f"negative test {name} rejected for the wrong reason: {exc}")
            n += 1
            continue
        raise ObjectBankError(f"negative test not rejected: {name}")

    # project files: work on an in-memory view via a temporary copy of the root
    import shutil
    import tempfile
    sha1 = asset_table(root, rom)
    syms = {k: v for k, v in SYMBOLS.items()}
    with tempfile.TemporaryDirectory() as tmp:
        t = pathlib.Path(tmp)
        for rel in [f"src/bank_{b:02X}.asm" for b in BANKS] + list(sha1):
            (t / rel).parent.mkdir(parents=True, exist_ok=True)
            shutil.copy(root / rel, t / rel)
        check_project_files(t, sha1, syms)        # baseline passes
        cases = []
        src = t / "src/bank_28.asm"
        orig = src.read_text()
        src.write_text(orig + '\tINCBIN "assets/bank_28/sprite_data_4518.bin"\n')
        cases.append(("opaque blob", lambda: check_project_files(t, sha1, syms), "opaque blob"))
        for name, fn, expect in cases:
            try:
                fn()
            except ObjectBankError as exc:
                check(expect in str(exc), f"negative test {name}: {exc}")
                n += 1
            else:
                raise ObjectBankError(f"negative test not rejected: {name}")
        src.write_text(orig)
        asset = t / "assets/bank_29/orientation_tiles.bin"
        data = asset.read_bytes()
        for name, mutate, expect in (
            ("missing asset", lambda: asset.unlink(), "missing source asset"),
            ("asset size", lambda: asset.write_bytes(data[:-16]), "has size"),
            ("asset hash", lambda: asset.write_bytes(data[:-1] + b"\x01"), "hash changed"),
        ):
            mutate()
            try:
                check_project_files(t, sha1, syms)
            except ObjectBankError as exc:
                check(expect in str(exc), f"negative test {name}: {exc}")
                n += 1
            else:
                raise ObjectBankError(f"negative test not rejected: {name}")
            asset.write_bytes(data)
        bad = dict(syms)
        bad["Bank28ObjectPalette"] = (0x28, 0x4510)
        try:
            check_project_files(t, sha1, bad)
        except ObjectBankError as exc:
            check("symbol Bank28ObjectPalette" in str(exc), f"negative test symbol: {exc}")
            n += 1
        else:
            raise ObjectBankError("negative test not rejected: symbol address")
    return n


def validate_all(root: pathlib.Path) -> str:
    rom = (root / "baserom.gbc").read_bytes()
    ranges = parse(rom)
    check_project_files(root, asset_table(root, rom), read_symbols(root / "battletanx.sym"))
    n = negative_tests(rom, root)
    totals = {}
    for _, s, e, cls in ranges:
        totals[cls] = totals.get(cls, 0) + e - s
    return (f"object banks: $27-$29 fully accounted ("
            + ", ".join(f"{k} {v}" for k, v in sorted(totals.items())) + f"), {n} negative tests rejected")


if __name__ == "__main__":
    print(validate_all(pathlib.Path(__file__).resolve().parent.parent))
