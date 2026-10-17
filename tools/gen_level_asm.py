#!/usr/bin/env python3
"""Write structured RGBDS source for level banks $09-$26.

Used once to replace the 30 whole-bank INCBINs. The generated bank files,
include/level_data.inc and the assets.txt lines are then maintained by hand;
`make compare` proves the bytes either way.

Usage: gen_level_asm.py baserom.gbc   (writes src/bank_09.asm-bank_26.asm,
       include/level_data.inc, and prints assets.txt lines)

Superseded: output differs from hand-maintained include/level_data.inc
(bank files still match); comparison only. Do not rerun in the tree.
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
import level_data as L

rom = open(sys.argv[1], "rb").read()
levels = L.parse_levels(rom)
h = lambda bs: ", ".join(f"${x:02X}" for x in bs)
inc = ["; Level data constants for ROM banks $09-$26. Values are copied from the\n"
       "; level records at $05:$4400 (see DATA_BANKS_09_26.md); tools/check_project.py\n"
       "; verifies that they still match the base ROM.\n\n"
       "; Pads a level bank with zeros up to its bank-number marker at $7FFF.\n"
       "MACRO level_bank_end\n\tds $7FFF - @, $00\n\tdb BANK(@)\nENDM\n\n"
       "; Twenty-byte record consumed by ROM0 LoadLevelData/LoadLevelRecord.\n"
       "MACRO level_record\n\tdb \\1, \\2\n"
       "\tdb BANK(\\3), BANK(\\4), BANK(\\5), BANK(\\6), BANK(\\7)\n"
       "\tdw \\8 - 1\n\tdb \\9\n\tdw \\3, \\4, \\7, \\6, \\5\nENDM\n\n"
       "; Address, bank, and reserved zero for bank $05:$4088.\n"
       "MACRO level_attr_lookup\n\tdw \\1\n\tdb BANK(\\1), $00\nENDM\n\n"
       "; One-based index followed by four animation-frame tile IDs.\n"
       "MACRO level_tile_animation\n\tdb \\1, \\2, \\3, \\4, \\5\nENDM\n\n"
       "; Three object parameters followed by five reserved zeros.\n"
       "MACRO object_type_parameters\n"
       "\tdb \\1, \\2, \\3, $00, $00, $00, $00, $00\nENDM\n"]
assets = []
for lv in levels:
    n, p = lv.number, f"LEVEL{lv.number:02}"
    d = f"assets/levels/level_{n:02}"
    inc.append(f"\nDEF {p}_WIDTH EQU {lv.width}\nDEF {p}_HEIGHT EQU {lv.height}\n"
               f"DEF {p}_TILE_COUNT EQU {lv.tile_count} ; record +7 holds this minus 1\n"
               f"DEF {p}_PALETTE_COUNT EQU {lv.palette_count}\n")
    odd, even = lv.cell_bank, lv.map_bank
    ob = lambda a, n=1: L.read(rom, odd, a, n)
    off = lambda bank, a: bank * L.BANK_SIZE + a - 0x4000
    assets += [
        f"{d}/cellmap.bin {off(odd, 0x4000):#x} {lv.cells:#x}",
        f"{d}/tiles.2bpp {off(odd, lv.tiles_addr):#x} {16 * lv.tile_count:#x}",
        f"{d}/tilemap.bin {off(even, 0x4000):#x} {lv.cells:#x}",
        f"{d}/attrmap.bin {off(even, lv.attrmap_addr):#x} {lv.cells:#x}",
    ]
    pal = []
    for i in range(lv.palette_count):
        ws = [L.word(rom, odd, lv.palettes_addr + 8 * i + 2 * k) for k in range(4)]
        pal.append("\tdw " + ", ".join(f"${x:04X}" for x in ws) + f" ; palette {i}\n")
    tab = "".join(f"\tdb {h(ob(lv.attr_table_addr + k, 16))}\n" for k in range(0, L.ATTR_TABLE_SIZE, 16))
    with open(f"src/bank_{odd:02X}.asm", "w") as f:
        f.write(f"""; BattleTanx (USA) - ROM bank ${odd:02X}: level {n} cell map, tiles, attribute
; lookup table and BG palettes. Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank ${odd:02X}", ROMX[$4000], BANK[${odd:02X}]

; {lv.width} x {lv.height} bytes, row-major. ROM0 $1AA4 copies it to WRAM banks 2-3
; at $D000; ROM0 $1D93 tests bits 6-7 (all clear in ROM). Low bits: unknown.
Level{n:02}_CellMap:
	INCBIN "{d}/cellmap.bin"

; 2bpp tiles. ROM0 $1A33 always copies 440 tiles from here; only the first
; {p}_TILE_COUNT belong to this block (the highest tile any map cell uses is
; {p}_TILE_COUNT - 1).
Level{n:02}_Tiles:
	INCBIN "{d}/tiles.2bpp"

	db $00 ; never read: the lookup below is addressed as table - 1 + value

; 160 bytes, pointer and bank from $05:$513E. ROM0 $1D93 returns entry
; (value - 1) as the attribute byte for cells with bit 7 set.
Level{n:02}_AttrLookup:
{tab}
; RGB555 BG palettes 0-{lv.palette_count - 1}, loaded by ROM0 $1A86.
Level{n:02}_BGPalettes:
{"".join(pal)}
	level_bank_end

	ASSERT Level{n:02}_Tiles - Level{n:02}_CellMap == {p}_WIDTH * {p}_HEIGHT
	ASSERT Level{n:02}_AttrLookup - Level{n:02}_Tiles == {p}_TILE_COUNT * 16 + 1
	ASSERT Level{n:02}_BGPalettes - Level{n:02}_AttrLookup == 160
""")
    with open(f"src/bank_{even:02X}.asm", "w") as f:
        f.write(f"""; BattleTanx (USA) - ROM bank ${even:02X}: level {n} tile map and attribute map.
; Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank ${even:02X}", ROMX[$4000], BANK[${even:02X}]

; {lv.width} x {lv.height} BG tile ids, row-major (read by ROM0 $1D93 via $C8C7).
Level{n:02}_TileMap:
	INCBIN "{d}/tilemap.bin"

; {lv.width} x {lv.height} CGB BG attribute bytes (read by ROM0 $1D93 via $C8C5):
; bits 0-2 palette, 3 VRAM bank, 5 x flip, 6 y flip, 7 priority; bit 4 clear.
Level{n:02}_AttrMap:
	INCBIN "{d}/attrmap.bin"

	level_bank_end

	ASSERT Level{n:02}_AttrMap - Level{n:02}_TileMap == {p}_WIDTH * {p}_HEIGHT
""")
with open("include/level_data.inc", "w") as f:
    f.write("".join(inc))
print("\n".join(assets))
