#!/usr/bin/env python3
"""Parser and validator for ROM bank $08 (interface and object graphics).

Every boundary is derived from baserom.gbc: loader call operands in ROM0
code, palette-load operands, the bank-$02 object animation frame tables,
the bank-$05 effect step table and records, the glyph table and the
metatile table. See BANK08_RESEARCH.md for the routines cited here.
"""
from __future__ import annotations

import hashlib
import pathlib
import re

BANK = 0x08
B = 0x20000 - 0x4000            # ROM offset of bank-$08 CPU address 0


class Bank08Error(ValueError):
    pass


def check(cond: bool, msg: str) -> None:
    if not cond:
        raise Bank08Error(msg)


def off(bank: int, addr: int) -> int:
    return addr if bank == 0 else bank * 0x4000 + addr - 0x4000


def word(rom: bytes, bank: int, addr: int) -> int:
    return int.from_bytes(rom[off(bank, addr):off(bank, addr) + 2], "little")


def find_once(rom: bytes, pat: bytes, name: str, lo: int = 0, hi: int = 0x4000) -> int:
    i = rom.find(pat, lo, hi)
    check(i >= 0, f"{name}: code pattern not found")
    check(rom.find(pat, i + 1, hi) < 0, f"{name}: code pattern not unique")
    return i


# --- Static tile loads: ROM0 LoadInterfaceTilesVRAM1/VRAM0 call Func_0622
# with e = first tile, d = count, a = VRAM page, bc = source.
TILE_LOADS = [
    # (source, tiles, vram bank, first tile, page) -- verified in ROM0 code
    (0x60F8, 1, 1, 0x40, 0x80), (0x6222, 2, 1, 0x41, 0x80), (0x611A, 16, 1, 0x43, 0x80),
    (0x6753, 10, 1, 0x53, 0x80), (0x6815, 12, 1, 0x5D, 0x80), (0x4010, 61, 1, 0x43, 0x88),
    (0x69FD, 8, 1, 0x3B, 0x88),
    (0x626B, 78, 0, 0x00, 0x80), (0x68DD, 4, 0, 0x4E, 0x80), (0x6925, 4, 0, 0x52, 0x80),
    (0x696D, 4, 0, 0x56, 0x80), (0x69B5, 4, 0, 0x5A, 0x80),
]
ENCODED_FONT = 0x6B85          # 37 tiles: LoadEncodedFontTiles (ROM0) and $01:RAM_D9CB
ENCODED_FONT_TILES = 37
GLYPH_TABLE = 0x6B05           # 128 bytes, DrawEncodedGlyph: tile = [table + char]
METATILES = 0x43E0             # 16 x 12 bytes, Func_0DB6 type-3 path: $43E0 + 12 * (obj+$19 & $0F)
METATILE_COUNT = 16
# Palette reads: (address, bytes, reader)
PALETTE_READS = [
    (0x44A0, 8, "LoadInterfacePalettes CopyBytesShort -> wUiFontPalette"),
    (0x44A2, 8, "LoadObjectPalettes Func_052F -> BG palette 7"),
    (0x46EA, 6, "Func_057D -> OBJ palette 3 (LoadObjectPalettes, ROM0 $3F00 path)"),
    (0x5502, 6, "Func_057D -> OBJ palette 3 (ROM0 $3CFB effect start)"),
    (0x674B, 8, "CopyBytesShort -> wHudIconPalette"),
    (0x67FD, 24, "Func_057D -> OBJ palettes 4-7"),
    (0x691D, 8, "CopyBytesShort -> wArrowUpPalette"),
    (0x6965, 8, "CopyBytesShort -> wArrowDownPalette"),
    (0x69AD, 8, "CopyBytesShort -> wAlphanumericFontPalette"),
]
# Object animation frame tables in bank $02 used by ROM0 Func_3190:
# (table, entries, tiles per frame); counts come from the bank-$02 setters'
# frame limits ((limit - 1) / 4 + 1 entries).
FRAME_TABLES = [(0x4565, 8, 9), (0x4575, 5, 9), (0x457F, 11, 9), (0x4595, 4, 4), (0x459D, 4, 4),
                (0x45A5, 4, 4), (0x45AD, 4, 4), (0x45B5, 3, 1), (0x45BB, 3, 1)]
EFFECT_STEPS = 0x6358          # bank $05: 6-byte steps of 3 record pointers
EFFECT_STEP_COUNT = 72         # followed by zero words
EFFECT_REACHABLE = 19          # $C959 = $4B; advance at each non-zero multiple of 4
CODE = (0x6DD5, 0x6DF0)        # SelectObjectSpritePalette
INDEX_TABLE = (0x67F3, 10)     # ObjectSpritePaletteIndexTable


def frame_reads(rom):
    out = []
    for t, n, k in FRAME_TABLES:
        for i in range(n):
            out.append((word(rom, 2, t + 2 * i), 16 * k, f"frame table $02:{t:04X}[{i}]"))
    return out


def effect_reads(rom):
    out = []
    for step in range(EFFECT_STEP_COUNT):
        for slot in range(3):
            p = word(rom, 5, EFFECT_STEPS + 6 * step + 2 * slot)
            if p >> 8 == 0:
                continue
            rec = rom[off(5, p):off(5, p) + 5]
            out.append((rec[1] | rec[2] << 8, 16 * rec[0], f"effect step {step} record $05:{p:04X}",
                        step < EFFECT_REACHABLE))
    return out


def check_gameplay_interrupt_bank_safety(rom: bytes) -> None:
    """Check the interrupt path that can pre-empt banked object rendering."""
    # RunLevel installs the bank-$02 gameplay images before its frame loop.
    check(rom[0x020F:0x0214] == bytes.fromhex("cdb30a1608"),
          "gameplay interrupt installation no longer precedes the frame loop")
    # The ROM0 wrapper preserves the current bank while selecting bank $02.
    check(rom[0x0AB3:0x0AC4] == bytes.fromhex("faff7ff53e02ea0020cd8a41f1ea0020c9"),
          "gameplay interrupt installer wrapper changed")
    # The installer copies both complete handlers and enables VBlank + LCD STAT.
    installer = rom[off(2, 0x418A):off(2, 0x41C2)]
    check(bytes.fromhex("21ec40114c000129c7cd8f0a") in installer,
          "gameplay LCD handler copy changed")
    check(bytes.fromhex("21384111520001f1c7cd8f0a") in installer,
          "gameplay VBlank handler copy changed")
    check(bytes.fromhex("3e03e0fffb") in installer,
          "gameplay interrupt enable mask changed")

    lcd = rom[off(2, 0x40EC):off(2, 0x4138)]
    vblank = rom[off(2, 0x4138):off(2, 0x418A)]
    check(bytes.fromhex("cd212f") in lcd,
          "gameplay LCD handler no longer calls Audio_Update")
    check(bytes.fromhex("ea0020") not in vblank,
          "gameplay VBlank handler unexpectedly changes the ROM bank")

    # Audio_Update saves the transient marker before selecting bank $06 and
    # restores it on return. Interrupt entry clears IME, so this cannot nest.
    audio = rom[0x2F21:0x2F73]
    check(bytes.fromhex("faff7ff53e06ea0020") in audio,
          "Audio_Update no longer saves the mapped bank before selecting bank $06")
    check(audio.endswith(bytes.fromhex("f1ea0020e1d1c1f1c9")),
          "Audio_Update no longer restores the interrupted ROM bank")

    # The bank-$08 wrapper leaves interrupts enabled, making the marker part
    # of its correctness contract rather than dead metadata.
    check(rom[0x37AC:0x37BD] == bytes.fromhex("faff7ff53e08ea0020cdd56df1ea0020c9"),
          "bank-$08 palette wrapper changed")


def parse(rom: bytes):
    """Validate all facts; return list of (start, end, class, label)."""
    r = lambda a, n=1: rom[B + a:B + a + n]
    # 1. Static loads appear in ROM0 code as `ld e,E / ld d,D / ld a,A / ld bc,SRC / call $0622`.
    for src, n, vb, first, page in TILE_LOADS:
        pat = bytes([0x1E, first, 0x16, n, 0x3E, page, 0x01, src & 0xFF, src >> 8, 0xCD, 0x22, 0x06])
        find_once(rom, pat, f"tile load {src:04X} x{n}")
    font_pat = bytes([0x1E, 0x00, 0x16, ENCODED_FONT_TILES, 0x3E, 0x80, 0x01,
                      ENCODED_FONT & 0xFF, ENCODED_FONT >> 8, 0xCD, 0x22, 0x06])
    find_once(rom, font_pat, "LoadEncodedFontTiles")
    ram_font = bytes([0x1E, 0x00, 0x16, ENCODED_FONT_TILES, 0x3E, 0x88, 0x01,
                      ENCODED_FONT & 0xFF, ENCODED_FONT >> 8, 0xCD, 0x22, 0x06])
    find_once(rom, ram_font, "$01:RAM_D9CB font copy", 0x4000, 0x8000)
    # 2. Glyph table: table = $6B05, 128 ASCII entries, values < font tile count; ends at font.
    find_once(rom, bytes([0x21, GLYPH_TABLE & 0xFF, GLYPH_TABLE >> 8]), "DrawEncodedGlyph table pointer")
    glyphs = r(GLYPH_TABLE, 128)
    check(GLYPH_TABLE + 128 == ENCODED_FONT, "glyph table does not end at the encoded font")
    check(max(glyphs) == ENCODED_FONT_TILES - 1, "glyph table value out of the 37-tile font")
    for c in range(128):
        want = (c - 0x2F if 0x30 <= c <= 0x39 else c - 0x36 if 0x41 <= c <= 0x5A else 0)
        check(glyphs[c] == want, f"glyph table entry ${c:02X} is {glyphs[c]}, expected {want}")
    check(not any(r(ENCODED_FONT, 16)), "encoded font tile 0 is not blank")
    # 3. Metatile table: ptr = $43E0 + 12*idx (code: add a,a / ld c,a / add a,a / add a,c / add a,a).
    find_once(rom, bytes.fromhex("874f878187" "01e043"), "metatile table pointer (12 * index + $43E0)")
    for i in range(METATILE_COUNT):
        rec = r(METATILES + 12 * i, 12)
        for k in range(6):
            t, a = rec[2 * k], rec[2 * k + 1]
            check(0x81 <= t <= 0xBD, f"metatile {i}: tile byte {t:#04x} outside the loaded font tiles")
            check(a & ~0x20 == 0, f"metatile {i}: attribute {a:#04x} uses bits other than x flip")
    check(METATILES + 12 * METATILE_COUNT == 0x44A0, "metatile table does not end at the font palette")
    check(METATILES == 0x4010 + 61 * 16, "UI font tiles do not end at the metatile table")
    check(not any(r(0x4000, 16)), "UI font tile 0 is not blank")
    # 4. Palettes: 4-colour RGB555, bit 15 clear.
    for a, n, reader in PALETTE_READS:
        for k in range(0, n, 2):
            check(not word(rom, 8, a + k) & 0x8000, f"palette ${a:04X} word {k // 2} bit 15 set")
    # 5. Sprite tile blocks from the frame and effect tables.
    reads = [(a, n, why, True) for a, n, why in frame_reads(rom)] + effect_reads(rom)
    for a, n, why, _ in reads:
        check(n and n % 16 == 0 and 0x44A8 <= a and a + n <= 0x60F0, f"{why}: read {a:04X}+{n:#x} outside sprite area")
    blocks = {}
    for a, n, why, reach in reads:
        e, rch = blocks.get(a, (0, False))
        blocks[a] = (max(e, a + n), rch or reach)
    ranges = []
    cursor = 0x44A8
    starts = sorted(blocks)
    for a in starts:
        end, reach = blocks[a]
        if a < cursor:
            check(False, f"sprite block {a:04X} overlaps the previous block")
        if a > cursor:
            check(a - cursor == 8, f"gap {cursor:04X}-{a - 1:04X} is not one 8-byte palette record")
            ranges.append((cursor, a, "palette record", f"PaletteRecord{cursor:04X}"))
        cls = "graphics" if reach else "graphics (unreachable table entries only)"
        ranges.append((a, end, cls, f"SpriteTiles{a:04X}"))
        cursor = end
    check(cursor == 0x60F0, f"sprite tile area ends at {cursor:04X}")
    # every 8-byte record between blocks has colour 0 = $0000 and bit 15 clear
    for s, e, cls, _ in ranges:
        if cls == "palette record":
            check(word(rom, 8, s) == 0, f"palette record {s:04X}: colour 0 is not $0000")
            for k in range(0, 8, 2):
                check(not word(rom, 8, s + k) & 0x8000, f"palette record {s:04X} word {k // 2} bit 15 set")
    # 6. Effect table shape: 72 steps then zero; reachable step count from code.
    check(not any(rom[off(5, EFFECT_STEPS + 6 * EFFECT_STEP_COUNT):off(5, EFFECT_STEPS + 6 * EFFECT_STEP_COUNT) + 6]),
          "effect step table does not end after 72 steps")
    find_once(rom, bytes.fromhex("3e4bea59c9"), "effect countdown $C959 = $4B")
    find_once(rom, bytes.fromhex("3e58ea5dc93e63ea5ec9"), "effect step table pointer $6358")
    # 7. Code.
    check(r(*CODE[:1], CODE[1] - CODE[0])[-1] == 0xC9, "SelectObjectSpritePalette does not end in ret")
    check(r(CODE[0] + 9, 1)[0] == 0xC6 and r(CODE[0] + 10, 1)[0] == INDEX_TABLE[0] & 0xFF,
          "SelectObjectSpritePalette table operand")
    check(all(v < 4 for v in r(INDEX_TABLE[0], INDEX_TABLE[1])), "palette index table value >= 4")
    # Status-4 objects are created from type-6 level records using byte +7
    # (0-8), while handler 8 increments once to 9 and handler 9 is a no-op.
    status4_types = []
    for i in range(15 * 40):
        record = rom[off(4, 0x4000 + 12 * i):off(4, 0x4000 + 12 * (i + 1))]
        if record[0] == 6:
            status4_types.append(record[7])
    check(status4_types and set(status4_types) == set(range(9)),
          "status-4 level-record types are not exactly 0-8")
    check([word(rom, 1, 0x44E0 + 2 * i) for i in range(10)][8:] == [0x4648, 0x467B],
          "status-4 handlers 8/9 changed")
    check(rom[off(1, 0x467B):off(1, 0x467F)] == bytes.fromhex("e1c31645"),
          "status-4 handler 9 is no longer a no-op")
    check_gameplay_interrupt_bank_safety(rom)
    check(not any(r(CODE[1], 0x7FFF - CODE[1])), "non-zero byte in fill")
    check(r(0x7FFF)[0] == BANK, "bank marker")

    static = [
        (0x4000, 0x4010, "graphics (not loaded)", "UiFontTile0"),
        (0x4010, 0x43E0, "graphics", "UiFontTiles"),
        (0x43E0, 0x44A0, "table", "InterfaceMetatiles"),
        (0x44A0, 0x44A8, "palette", "Bank08UiFontPalette"),
        (0x60F0, 0x60F8, "palette record", "PaletteRecord60F0"),
        (0x60F8, 0x6108, "graphics", "Bank08InterfaceTiles60F8"),
        (0x6108, 0x610A, "unknown", "Bank08Unknown6108"),
        (0x610A, 0x6112, "palette record", "PaletteRecord610A"),
        (0x6112, 0x611A, "palette record (unused)", "Bank08UnusedPalette6112"),
        (0x611A, 0x621A, "graphics", "Bank08InterfaceTiles611A"),
        (0x621A, 0x6222, "palette record", "PaletteRecord621A"),
        (0x6222, 0x6242, "graphics", "Bank08InterfaceTiles6222"),
        (0x6242, 0x624A, "palette record", "PaletteRecord6242"),
        (0x624A, 0x6250, "unknown", "Bank08Unknown624A"),
        (0x6250, 0x6260, "graphics (duplicate, not loaded)", "Bank08DuplicateInterfaceTile6250"),
        (0x6260, 0x6263, "unknown", "Bank08Unknown6260"),
        (0x6263, 0x626B, "palette record", "PaletteRecord6263"),
        (0x626B, 0x674B, "graphics", "Bank08InterfaceTiles626B"),
        (0x674B, 0x6753, "palette", "Bank08HudIconPalette"),
        (0x6753, 0x67F3, "graphics", "Bank08HudIconTiles"),
        (0x67F3, 0x67FD, "table", "ObjectSpritePaletteIndexTable"),
        (0x67FD, 0x6815, "palette", "Bank08ObjectPalettes67FD"),
        (0x6815, 0x68D5, "graphics", "Bank08InterfaceTiles6815"),
        (0x68D5, 0x68DD, "palette record", "Bank08InterfacePalette68D5"),
        (0x68DD, 0x691D, "graphics", "Bank08InterfaceTiles68DD"),
        (0x691D, 0x6925, "palette", "Bank08ArrowUpPalette"),
        (0x6925, 0x6965, "graphics", "Bank08ArrowUpTiles"),
        (0x6965, 0x696D, "palette", "Bank08ArrowDownPalette"),
        (0x696D, 0x69AD, "graphics", "Bank08ArrowDownTiles"),
        (0x69AD, 0x69B5, "palette", "Bank08AlphanumericFontPalette"),
        (0x69B5, 0x69F5, "graphics", "Bank08InterfaceTiles69B5"),
        (0x69F5, 0x69FD, "palette record", "PaletteRecord69F5"),
        (0x69FD, 0x6A7D, "graphics", "Bank08InterfaceTiles69FD"),
        (0x6A7D, 0x6AFD, "graphics (not loaded)", "Bank08UnreferencedTiles6A7D"),
        (0x6AFD, 0x6B05, "palette (not loaded)", "Bank08UnreferencedPalette6AFD"),
        (GLYPH_TABLE, ENCODED_FONT, "table", "EncodedGlyphTable"),
        (ENCODED_FONT, ENCODED_FONT + 16 * ENCODED_FONT_TILES, "graphics", "EncodedFontTiles"),
        (CODE[0], CODE[1], "code", "SelectObjectSpritePalette"),
        (CODE[1], 0x7FFF, "fill", "fill"),
        (0x7FFF, 0x8000, "marker", "bank marker"),
    ]
    check(r(0x6112, 8) == bytes.fromhex("1f001f001f001f00"),
          "unused palette record $6112 changed")
    check(r(0x6250, 16) == r(0x626B + 47 * 16, 16),
          "duplicate interface tile $6250 no longer matches tile 47 at $655B")
    unused_palette = [word(rom, 8, 0x6AFD + 2 * i) for i in range(4)]
    check(not any(value & 0x8000 for value in unused_palette),
          "unreferenced palette $6AFD has bit 15 set")
    channels = [[(value >> shift) & 0x1F for value in unused_palette]
                for shift in (0, 5, 10)]
    check(all(all(a < b for a, b in zip(channel, channel[1:])) for channel in channels),
          "unreferenced palette $6AFD is not dark-to-light in every channel")
    # loaded tile blocks must match the static graphics ranges they claim
    for src, n, *_ in TILE_LOADS:
        hit = [s for s, e, c, _ in static if s <= src and src + 16 * n <= e and c.startswith("graphics")]
        check(hit, f"tile load {src:04X} x{n} is not inside a graphics range")
    for s, e, c, _ in static:
        if c == "palette record":
            check(word(rom, 8, s) == 0, f"palette record {s:04X}: colour 0 is not $0000")
    ranges += static
    check_coverage(ranges)
    return sorted(ranges)


def check_coverage(ranges) -> None:
    cursor = 0x4000
    for s, e, c, label in sorted(ranges):
        check(s == cursor and e > s, f"coverage gap or overlap at {cursor:04X} ({label})")
        cursor = e
    check(cursor == 0x8000, f"coverage ends at {cursor:04X}")


# ---------------------------------------------------------------- project files
ASSETS = {
    "assets/bank_08/ui_font_tiles.bin": (0x4000, 0x43E0),
    "assets/bank_08/object_animation_tiles.bin": None,   # tile blocks $44A8-$5487 concatenated
    "assets/bank_08/effect_tiles.bin": None,             # tile blocks $5490-$60EF concatenated
    "assets/bank_08/interface_tiles_60F8.bin": (0x60F8, 0x6108),
    "assets/bank_08/interface_tiles_611A.bin": (0x611A, 0x621A),
    "assets/bank_08/interface_tiles_6222.bin": (0x6222, 0x6242),
    "assets/bank_08/interface_tiles_626B.bin": (0x626B, 0x674B),
    "assets/bank_08/hud_icon_tiles.bin": (0x6753, 0x67F3),
    "assets/bank_08/interface_tiles_6815.bin": (0x6815, 0x68D5),
    "assets/bank_08/interface_tiles_68DD.bin": (0x68DD, 0x691D),
    "assets/bank_08/arrow_up_tiles.bin": (0x6925, 0x6965),
    "assets/bank_08/arrow_down_tiles.bin": (0x696D, 0x69AD),
    "assets/bank_08/interface_tiles_69B5.bin": (0x69B5, 0x69F5),
    "assets/bank_08/interface_tiles_69FD.bin": (0x69FD, 0x6A7D),
    "assets/bank_08/unreferenced_tiles_6A7D.bin": (0x6A7D, 0x6AFD),
    "assets/bank_08/encoded_font_tiles.bin": (0x6B85, 0x6DD5),
}
SUPERSEDED = ["unknown_44A8.bin", "unknown_46F0.bin", "unknown_6108.bin", "unknown_621A.bin",
              "unknown_6242.bin", "alphanumeric_font_tiles.bin"]


def asset_bytes(rom: bytes, ranges) -> dict:
    out = {}
    for path, span in ASSETS.items():
        if span:
            out[path] = rom[B + span[0]:B + span[1]]
    tiles = [(s, e) for s, e, c, _ in ranges if c.startswith("graphics") and 0x44A8 <= s < 0x60F0]
    out["assets/bank_08/object_animation_tiles.bin"] = b"".join(rom[B + s:B + e] for s, e in tiles if s < 0x5490)
    out["assets/bank_08/effect_tiles.bin"] = b"".join(rom[B + s:B + e] for s, e in tiles if s >= 0x5490)
    return out


SYMBOLS = {
    "Bank08UiFontTiles": (0x08, 0x4000), "InterfaceMetatiles": (0x08, 0x43E0),
    "Bank08UiFontPalette": (0x08, 0x44A0), "Bank08ObjectPalette46EA": (0x08, 0x46EA),
    "EffectPalette5502": (0x08, 0x5502), "Bank08InterfaceTiles60F8": (0x08, 0x60F8),
    "Bank08InterfaceTiles611A": (0x08, 0x611A), "Bank08InterfaceTiles6222": (0x08, 0x6222),
    "Bank08UnusedPalette6112": (0x08, 0x6112),
    "Bank08DuplicateInterfaceTile6250": (0x08, 0x6250),
    "Bank08InterfaceTiles626B": (0x08, 0x626B), "Bank08HudIconPalette": (0x08, 0x674B),
    "Bank08HudIconTiles": (0x08, 0x6753), "ObjectSpritePaletteIndexTable": (0x08, 0x67F3),
    "Bank08ObjectPalettes67FD": (0x08, 0x67FD), "Bank08InterfaceTiles6815": (0x08, 0x6815),
    "Bank08InterfacePalette68D5": (0x08, 0x68D5), "Bank08InterfaceTiles68DD": (0x08, 0x68DD),
    "Bank08ArrowUpPalette": (0x08, 0x691D), "Bank08ArrowUpTiles": (0x08, 0x6925),
    "Bank08ArrowDownPalette": (0x08, 0x6965), "Bank08ArrowDownTiles": (0x08, 0x696D),
    "Bank08AlphanumericFontPalette": (0x08, 0x69AD), "Bank08AlphanumericFontTiles": (0x08, 0x69B5),
    "Bank08InterfaceTiles69B5": (0x08, 0x69B5), "Bank08InterfaceTiles69FD": (0x08, 0x69FD),
    "Bank08UnreferencedTiles6A7D": (0x08, 0x6A7D),
    "Bank08UnreferencedPalette6AFD": (0x08, 0x6AFD),
    "EncodedGlyphTable": (0x08, 0x6B05), "EncodedFontTiles": (0x08, 0x6B85),
    "SelectObjectSpritePalette": (0x08, 0x6DD5),
    "wUiFontPalette": (0x00, 0xC721), "wHudIconPalette": (0x00, 0xC6F9),
    "wArrowUpPalette": (0x00, 0xC701), "wArrowDownPalette": (0x00, 0xC709),
    "wAlphanumericFontPalette": (0x00, 0xC711),
    "LoadObjectPalettes": (0x00, 0x07A7), "LoadInterfaceTilesVRAM1": (0x00, 0x0807),
    "LoadInterfaceTilesVRAM0": (0x00, 0x0879), "LoadInterfacePalettes": (0x00, 0x092F),
    "SelectObjectSpritePaletteFar": (0x00, 0x37AC),
}


def check_project_files(root: pathlib.Path, expected: dict, symbols: dict | None) -> None:
    src = (root / "src" / "bank_08.asm").read_text()
    for name in SUPERSEDED:
        check(name not in src, f"superseded opaque asset {name} is included again")
    for rel, data in expected.items():
        p = root / rel
        check(p.exists(), f"missing source asset {rel}")
        got = p.read_bytes()
        check(len(got) == len(data), f"source asset {rel} has size {len(got)}, expected {len(data)}")
        check(hashlib.sha1(got).digest() == hashlib.sha1(data).digest(), f"source asset {rel} differs from the ROM range")
        check(f'"{rel}"' in src, f"bank 08 source does not include {rel}")
    if symbols is not None:
        for name, where in SYMBOLS.items():
            check(symbols.get(name) == where, f"symbol {name} at {symbols.get(name)}, expected {where}")


def read_symbols(path: pathlib.Path):
    if not path.exists():
        return None
    out = {}
    for line in path.read_text().splitlines():
        m = re.fullmatch(r"([0-9a-fA-F]{2}):([0-9a-fA-F]{4}) (\S+)", line.strip())
        if m:
            out[m.group(3)] = (int(m.group(1), 16), int(m.group(2), 16))
    return out


def negative_tests(rom: bytes, root: pathlib.Path) -> int:
    def poke(changes):
        d = bytearray(rom)
        for (bank, addr), v in changes.items():
            d[off(bank, addr)] = v
        return bytes(d)

    v1 = rom.find(bytes([0x1E, 0x43, 0x16, 0x3D, 0x3E, 0x88]), 0, 0x4000)
    cases = {
        "tile load count": ({(0, v1 + 3): 0x3E}, "tile load 4010 x61"),
        "glyph table entry": ({(8, 0x6B05 + 0x41): 0x0C}, "glyph table entry $41"),
        "glyph value range": ({(8, 0x6B05 + 0x7F): 0x25}, "out of the 37-tile font"),
        "blank font tile": ({(8, 0x6B85): 0x01}, "encoded font tile 0"),
        "metatile tile range": ({(8, 0x43E0): 0x80}, "metatile 0: tile byte"),
        "metatile attribute": ({(8, 0x43E1): 0x40}, "metatile 0: attribute"),
        "palette bit 15": ({(8, 0x691D + 3): 0x80}, "palette $691D word 1"),
        "frame table pointer": ({(2, 0x4575): 0xF8}, "is not one 8-byte palette record"),
        "effect record pointer": ({(5, 0x59E0 + 1): 0x98}, "overlaps"),
        "effect read outside area": ({(5, 0x59E0 + 2): 0x40}, "outside sprite area"),
        "palette record colour 0": ({(8, 0x5100): 0x01}, "palette record 5100"),
        "unused palette record": ({(8, 0x6113): 0x80}, "unused palette record $6112"),
        "duplicate interface tile": ({(8, 0x6250): 0x00}, "duplicate interface tile $6250"),
        "effect table end": ({(5, 0x6358 + 6 * 72): 0x01}, "does not end after 72"),
        "effect countdown": ({(0, rom.find(bytes.fromhex("3e4bea59c9"), 0, 0x4000) + 1): 0x4C}, "$C959 = $4B"),
        "palette index value": ({(8, 0x67F3): 0x04}, "palette index table"),
        "status-4 type bound": ({(4, 0x4043): 0x0A}, "status-4 level-record types"),
        "interrupt-time audio bank save": ({(0, 0x2F2F): 0x00}, "Audio_Update no longer saves"),
        "unreferenced palette": ({(8, 0x6AFE): 0x98}, "unreferenced palette $6AFD has bit 15 set"),
        "fill byte": ({(8, 0x7000): 0x01}, "non-zero byte in fill"),
        "bank marker": ({(8, 0x7FFF): 0x07}, "bank marker"),
    }
    n = 0
    for name, (chg, expect) in cases.items():
        try:
            parse(poke(chg))
        except Bank08Error as exc:
            check(expect in str(exc), f"negative test {name} rejected for the wrong reason: {exc}")
            n += 1
            continue
        raise Bank08Error(f"negative test not rejected: {name}")
    good = parse(rom)
    for name, bad, expect in (("uncovered range", [x for x in good if x[3] != "Bank08UnreferencedTiles6A7D"], "gap"),
                              ("overlapping range", good + [(0x6A00, 0x6A10, "x", "x")], "overlap")):
        try:
            check_coverage(bad)
        except Bank08Error as exc:
            check(expect in str(exc), f"negative test {name}: {exc}")
            n += 1
            continue
        raise Bank08Error(f"negative test not rejected: {name}")
    import shutil
    import tempfile
    expected = asset_bytes(rom, good)
    with tempfile.TemporaryDirectory() as tmp:
        t = pathlib.Path(tmp)
        for rel in ["src/bank_08.asm"] + list(expected):
            (t / rel).parent.mkdir(parents=True, exist_ok=True)
            shutil.copy(root / rel, t / rel)
        syms = dict(SYMBOLS)
        check_project_files(t, expected, syms)
        src = t / "src/bank_08.asm"
        text = src.read_text()
        asset = t / "assets/bank_08/effect_tiles.bin"
        data = asset.read_bytes()
        bad_syms = dict(syms)
        bad_syms["EncodedGlyphTable"] = (0x08, 0x6B04)
        trials = [
            ("opaque blob", lambda: src.write_text(text + 'INCBIN "assets/bank_08/unknown_46F0.bin"\n'),
             lambda: src.write_text(text), syms, "superseded opaque asset"),
            ("missing asset", lambda: asset.unlink(), lambda: asset.write_bytes(data), syms, "missing source asset"),
            ("asset size", lambda: asset.write_bytes(data[:-16]), lambda: asset.write_bytes(data), syms, "has size"),
            ("asset hash", lambda: asset.write_bytes(data[:-1] + b"\x01"), lambda: asset.write_bytes(data), syms,
             "differs from the ROM range"),
            ("symbol address", lambda: None, lambda: None, bad_syms, "symbol EncodedGlyphTable"),
        ]
        for name, mutate, restore, sy, expect in trials:
            mutate()
            try:
                check_project_files(t, expected, sy)
            except Bank08Error as exc:
                check(expect in str(exc), f"negative test {name}: {exc}")
                n += 1
            else:
                raise Bank08Error(f"negative test not rejected: {name}")
            finally:
                restore()
    return n


def accounting(ranges) -> dict:
    tot = {}
    for s, e, c, _ in ranges:
        tot[c] = tot.get(c, 0) + e - s
    return tot


def validate_all(root: pathlib.Path) -> str:
    rom = (root / "baserom.gbc").read_bytes()
    ranges = parse(rom)
    check_project_files(root, asset_bytes(rom, ranges), read_symbols(root / "battletanx.sym"))
    n = negative_tests(rom, root)
    tot = accounting(ranges)
    return ("bank 08: every byte classified (" + ", ".join(f"{k} {v}" for k, v in sorted(tot.items()))
            + f"), {n} negative tests rejected")


if __name__ == "__main__":
    import sys
    rom = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "baserom.gbc").read_bytes()
    for s, e, c, label in parse(rom):
        print(f"{s:04X}-{e - 1:04X} {e - s:5d} {c:42s} {label}")
    print(accounting(parse(rom)))
