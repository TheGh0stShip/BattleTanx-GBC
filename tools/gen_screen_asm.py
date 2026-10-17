#!/usr/bin/env python3
"""Write structured RGBDS source for ROM banks $2A-$2E (one-time generator).

Owns nothing after the first run: it produced include/screen_data.inc,
src/bank_2A.asm-src/bank_2E.asm and the assets.txt lines it prints. Those
files are hand-maintained from then on; do not rerun this over edited source.
Routine template text is taken from the baseline bank_2B.asm.
Usage: gen_screen_asm.py baserom.gbc BASELINE_SRC_DIR
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(__file__))
import screen_data as S

rom = open(sys.argv[1], "rb").read()
base = sys.argv[2]
pk, ranges = S.parse(rom)
b2b = open(os.path.join(base, "bank_2B.asm")).read()
b2a = open(os.path.join(base, "bank_2A.asm")).read()


def block(text, start, stop):
    i = text.index(f"\n{start}:\n") + len(start) + 3
    j = text.index(stop, i)
    return text[i:j].rstrip("\n").split("\n")


def body(lines, desc, local):
    out = []
    for l in lines:
        if not l.strip():
            continue
        l = l.replace(desc, "\\1")
        l = l.replace("$C6D2", "wScreenDescriptor")
        for old, new in local.items():
            l = l.replace(old, new)
        out.append(l)
    return "\n".join(out)


load = body(block(b2b, "Func_2B_4000", "\nFunc_2B_4058"), "$40CC", {})
fade = body(block(b2b, "Func_2B_5C32", "\tINCBIN"), "$5CA6",
            {"Jump_2B_5C88:": ".fade_step\\@:", "Jump_2B_5C8C:": ".wait_vblank\\@:",
             "jr nz, Jump_2B_5C88": "jr nz, .fade_step\\@", "jr z, Jump_2B_5C8C": "jr z, .wait_vblank\\@",
             "ld a, $00\n": "ld a, \\2\n"})
fade = fade.replace("\tld a, $00\n\tld [$C6D1], a", "\tld a, \\2\n\tld [wPaletteFadeFromWhite], a")
plain = body(block(b2b, "Func_2B_6EC4", "\tINCBIN"), "$6F1D",
             {"Jump_2B_6F0F:": ".wait_vblank\\@:", "jr z, Jump_2B_6F0F": "jr z, .wait_vblank\\@"})
assert "\\2" in fade and "Jump_" not in load + fade + plain, "template substitution failed"

inc = f"""; Full-screen picture support for ROM banks $2A-$2E. Evidence and layout:
; BANKS_2A_2E_RESEARCH.md. The three routine macros reproduce, byte for
; byte, routines that occur 13, 10 and 3 times; tools/screen_data.py checks
; that every copy in the ROM still matches its template.

; 14-byte screen descriptor, copied to wScreenDescriptor by the draw routines.
; Only width and height are read back (ROM0 $05C5); the tile count is never
; read but equals the highest tile used + 1 in every picture.
MACRO screen_descriptor ; tiles, tilemap, attrmap, palettes, tile count, width, height, palette count, first palette
	dw \\1, \\2, \\3, \\4, \\5
	db \\6, \\7, \\8, \\9
ENDM

; Load routine (ScreenTable_CallInit target): copies 384 tiles from the
; descriptor's tile pointer to VRAM0 $8800, VRAM0 $9000 and VRAM1 $9000,
; whatever the picture's tile count.
MACRO screen_load_tiles ; descriptor
{load}
ENDM

; Draw routine with fade-in (ScreenTable_CallUpdate target). Stack argument:
; the BG map offset pushed by ScreenTable_CallUpdate (read at sp+4). Writes
; the maps through ROM0 $05C5, seeds 8 palettes (always $40 bytes, whatever
; the palette count) into ROM0 $3A88's fade buffer, builds 32 fade steps
; (darkening when \\2 is 0, brightening otherwise) and shows one per frame.
MACRO screen_draw_fade ; descriptor, wPaletteFadeFromWhite value
{fade}
ENDM

; Draw routine without fade: maps as above, then [+12] palettes from palette
; index [+13] straight to BCPD (ROM0 $052F), then waits for one VBlank.
MACRO screen_draw_plain ; descriptor
{plain}
ENDM

; Zero fill up to the bank-number marker at $7FFF.
MACRO screen_bank_end
	ds $7FFF - @, $00
	db BANK(@)
ENDM
"""
open("include/screen_data.inc", "w").write(inc)

assets = []
h = lambda bs: ", ".join(f"${x:02X}" for x in bs)


def maprows(bank, addr, w, hgt, ind="\t"):
    return "".join(f"{ind}db {h(S.read(rom, bank, addr + r * w, w))}\n" for r in range(hgt))


def pals(bank, addr, n):
    return "".join("\tdw " + ", ".join(f"${S.word(rom, bank, addr + 8 * i + 2 * k):04X}" for k in range(4))
                   + f" ; palette {i}\n" for i in range(n))


def tiles_incbin(name, bank, addr, count):
    path = f"assets/screens/{name}.2bpp"
    assets.append(f"{path} {S.off(bank, addr):#x} {16 * count:#x}")
    return f'\tINCBIN "{path}"\n'


out = {b: [] for b in S.BANKS}
by_start = {}
for bank, s, e, cls, label in ranges:
    by_start[(bank, s)] = (e, cls, label)
pk_by = {p.name: p for p in pk}


def emit_package_code(p):
    old_l = f"Func_{p.bank:02X}_{p.load:04X}"
    old_d = f"Func_{p.bank:02X}_{p.draw:04X}"
    callers = (f"ScreenModeTable entries {', '.join(str(m) for m in p.modes)}" if p.modes
               else "no caller found; the picture is also reached through $01:$596D entry 2")
    kind = (f"screen_draw_fade {p.name}_Descriptor, {p.kind[1]}" if p.kind[0] == "fade"
            else f"screen_draw_plain {p.name}_Descriptor")
    fade_note = {0: "fades in from black", 1: "fades in from white", None: "no fade"}[p.kind[1]]
    return (f"\n; {callers}.\n{old_l}: ; address-based alias kept for other banks\n"
            f"{p.name}_LoadTiles:\n\tscreen_load_tiles {p.name}_Descriptor\n\n"
            f"{old_d}: ; address-based alias kept for other banks\n"
            f"{p.name}_Draw: ; {fade_note}\n\t{kind}\n")


def emit_descriptor(p):
    return (f"\n{p.name}_Descriptor:\n\tscreen_descriptor {p.name}_Tiles, {p.name}_TileMap, "
            f"{p.name}_AttrMap, {p.name}_Palettes, {p.tile_count}, {p.width}, {p.height}, "
            f"{p.palette_count}, {p.first_palette}\n")


def emit_package_data(p):
    t = f"\n{p.name}_Tiles:\n" + tiles_incbin(f"{p.name.lower()}_tiles", p.bank, p.tiles, p.tile_count)
    if p.name in S.ZERO_TILE_SLOT:
        t += "\tds 16, $00 ; all-zero tile after the counted tiles; no map refers to it\n"
    maps = [("TileMap", p.tilemap), ("AttrMap", p.attrmap)]
    if p.name in S.ALT_MAPS:
        a, b = S.ALT_MAPS[p.name]
        maps = [("AltTileMap", a), ("TileMap", p.tilemap), ("AltAttrMap", b), ("AttrMap", p.attrmap)]
    for nm, addr in maps:
        note = {"AltTileMap": "; second 20x18 tile map, drawn by $01:7981 with bank $2C selected via $C943\n",
                "AltAttrMap": "; attributes for the second map ($01:7981, VRAM1)\n"}.get(nm, "")
        t += f"\n{note}{p.name}_{nm}:\n" + maprows(p.bank, addr, p.width, p.height)
    t += f"\n{p.name}_Palettes:\n" + pals(p.bank, p.palettes, p.palette_count)
    return t


def emit_asserts(p):
    return (f"\tASSERT {p.name}_TileMap - {p.name}_Tiles == {p.tile_count} * 16"
            + (" + 16" if p.name in S.ZERO_TILE_SLOT else "")
            + (f" + {p.width} * {p.height}" if p.name in S.ALT_MAPS else "") + "\n"
            f"\tASSERT {p.name}_Palettes - {p.name}_AttrMap == {p.width} * {p.height}\n")


asserts = {b: [] for b in S.BANKS}
done = set()
for bank, s, e, cls, label in ranges:
    o = out[bank]
    name = label.split("_")[0].split(" ")[0]
    if label.endswith("_LoadTiles") and name in pk_by:
        o.append(emit_package_code(pk_by[name]))
    elif label.endswith("_Descriptor"):
        p = pk_by[name]
        o.append(emit_descriptor(p))
        asserts[bank].append(emit_asserts(p))
    elif label.endswith("_Tiles") and name in pk_by:
        o.append(emit_package_data(pk_by[name]))
    elif label == "zero fill":
        o.append("\n\tscreen_bank_end\n")
    elif label.startswith("FixedScreen2A_Tiles"):
        f = S.FIXED_2A
        o.append("\n; Bank $2A fixed screen, drawn and animated by FixedScreen2A_Run.\n"
                 "; 464 tiles; FixedScreen2A_LoadTiles copies 512 from here, so the last\n"
                 "; 48 copied tiles come from the maps below.\nFixedScreen2A_Tiles:\n"
                 + tiles_incbin("fixedscreen2a_tiles", 0x2A, 0x4000, f["tile_count"]))
        o.append("\nFixedScreen2A_TileMap:\n" + maprows(0x2A, 0x5D00, 20, 18))
        o.append("\n; 20x11 sheet of four 5x11 frames for the BG rectangle at $980F.\n"
                 "FixedScreen2A_FrameTileMap:\n" + maprows(0x2A, 0x5E68, 20, 11))
        o.append("\nFixedScreen2A_AttrMap:\n" + maprows(0x2A, 0x5F44, 20, 18))
        o.append("\nFixedScreen2A_FrameAttrMap:\n" + maprows(0x2A, 0x60AC, 20, 11))
        o.append("\nFixedScreen2A_Palettes:\n" + pals(0x2A, 0x6188, 8))
        o.append("\n; Frame n: tile and attribute sources of the 5x11 rectangle.\nFixedScreen2A_FrameTable:\n"
                 + "".join(f"\tdw FixedScreen2A_FrameTileMap + {5 * i}, FixedScreen2A_FrameAttrMap + {5 * i}\n"
                           for i in range(4)))
        asserts[0x2A].append("\tASSERT FixedScreen2A_TileMap - FixedScreen2A_Tiles == 464 * 16\n"
                             "\tASSERT FixedScreen2A_FrameTable - FixedScreen2A_Palettes == 8 * 8\n")
    elif label == "FixedScreen2A_LoadTiles":
        code = b2a[b2a.index("\nFunc_2A_7719:\n") + 1:b2a.index("\tINCBIN", b2a.index("\nFunc_2A_7719:\n"))]
        rep = [("Func_2A_7719:", "FixedScreen2A_LoadTiles: ; loads 512 tiles (4 x 128)"),
               ("Func_2A_7754:", "FixedScreen2A_Draw:"),
               ("Func_2A_7774:", "Func_2A_7774: ; address-based alias kept for ROM0 $3F28\n"
                "; Draws the fixed screen, then shows frames 0-3 for 10 frames each\n"
                "; (Func_3971) until $C6B5 becomes non-zero.\nFixedScreen2A_Run:"),
               ("Func_2A_7795:", "; a = frame 0-3: copies its 5x11 tiles and attributes to $980F.\nFixedScreen2A_DrawFrame:"),
               ("call Func_2A_7719", "call FixedScreen2A_LoadTiles"),
               ("call Func_2A_7754", "call FixedScreen2A_Draw"),
               ("call Func_2A_7795", "call FixedScreen2A_DrawFrame"),
               ("ld bc, $4000", "ld bc, FixedScreen2A_Tiles"),
               ("ld bc, $4800", "ld bc, FixedScreen2A_Tiles + $800"),
               ("ld bc, $5000", "ld bc, FixedScreen2A_Tiles + $1000"),
               ("ld bc, $5800", "ld bc, FixedScreen2A_Tiles + $1800"),
               ("ld bc, $5F44", "ld bc, FixedScreen2A_AttrMap"),
               ("ld de, $5D00", "ld de, FixedScreen2A_TileMap"),
               ("ld hl, $6188", "ld hl, FixedScreen2A_Palettes"),
               ("ld hl, $61C8", "ld hl, FixedScreen2A_FrameTable"),
               ("[$C6DC]", "[wScreenWidth]"), ("[$C6DD]", "[wScreenHeight]"),
               ("Jump_2A_777A", ".restart"), ("Jump_2A_777C", ".next_frame"), ("Jump_2A_7794", ".done"),
               ("Jump_2A_77B4", ".wait_vblank"), ("Jump_2A_77C5", ".row"), ("Jump_2A_77C9", ".cell")]
        for a, b in rep:
            code = code.replace(a, b)
        assert "$4000" not in code and "Jump_" not in code
        o.append("\n" + code)
    elif label.startswith("Picture596D") and label.endswith("_Tiles"):
        i = int(label[11])
        _, tl, tm, am, pal = [None, 0, 0, 0, 0]
        e2 = S.read(rom, 0x01, 0x596D + 16 * i, 10)
        tl, tm, am, pal = (e2[1 + 2 * k] | e2[2 + 2 * k] << 8 for k in range(4))
        n = f"Picture596D{i}"
        o.append(f"\n; Bank $2E picture {i} of the $01:$596D table (no descriptor; drawn by bank\n"
                 f"; $01 routines through $C943-$C952). 20x19 maps, 8 palettes.\n{n}_Tiles:\n"
                 + tiles_incbin(f"picture596d{i}_tiles", 0x2E, tl, S.PICTURE_TILE_COUNTS[i])
                 + f"\n{n}_TileMap:\n" + maprows(0x2E, tm, 20, 19)
                 + f"\n{n}_AttrMap:\n" + maprows(0x2E, am, 20, 19)
                 + f"\n{n}_Palettes:\n" + pals(0x2E, pal, 8))
        asserts[0x2E].append(f"\tASSERT {n}_TileMap - {n}_Tiles == {S.PICTURE_TILE_COUNTS[i]} * 16\n"
                             f"\tASSERT {n}_Palettes - {n}_AttrMap == 20 * 19\n")
for bank in S.BANKS:
    with open(f"src/bank_{bank:02X}.asm", "w") as f:
        f.write(f"; BattleTanx (USA) - ROM bank ${bank:02X}: full-screen pictures and their\n"
                f"; load/draw routines. Layout and evidence: BANKS_2A_2E_RESEARCH.md.\n\n"
                f'SECTION "ROM Bank ${bank:02X}", ROMX[$4000], BANK[${bank:02X}]\n')
        f.write("".join(out[bank]))
        f.write("\n" + "".join(asserts[bank]))
print("\n".join(assets))
