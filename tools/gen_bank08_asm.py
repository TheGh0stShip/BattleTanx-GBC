#!/usr/bin/env python3
"""One-time generator for src/bank_08.asm and its tile assets.

Owns nothing after its first run: src/bank_08.asm and assets/bank_08/*.bin are
hand-maintained source. Rerunning overwrites them; do not rerun over edits.
Usage: gen_bank08_asm.py baserom.gbc
"""
import pathlib, sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import bank08 as K

rom = pathlib.Path(sys.argv[1]).read_bytes()
ranges = K.parse(rom)
r = lambda a, n: rom[K.B + a:K.B + a + n]
h = lambda bs: ", ".join(f"${x:02X}" for x in bs)
assets = K.asset_bytes(rom, ranges)
for rel, data in assets.items():
    p = pathlib.Path(rel)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_bytes(data)

frame_refs, effect_refs = {}, {}
for a, n, why in K.frame_reads(rom):
    frame_refs.setdefault(a, []).append(f"{why} ({n // 16} tiles)")
for a, n, why, reach in K.effect_reads(rom):
    effect_refs.setdefault(a, set()).add(f"{n // 16} tiles")

LOADS = {
    0x6DD5: None,
}
PAL_COPIES = {0x44A0: ("C721", "wUiFontPalette"), 0x674B: ("C6F9", "wHudIconPalette"),
              0x691D: ("C701", "wArrowUpPalette"), 0x6965: ("C709", "wArrowDownPalette"),
              0x69AD: ("C711", "wAlphanumericFontPalette")}
STATIC_ASSET = {s: rel for rel, span in K.ASSETS.items() if span for s in [span[0]]}
COMMENTS = {
    "UiFontTile0": "Blank tile 0 of the UI font; no loader copies it (LoadInterfaceTilesVRAM1 starts at +$10).",
    "UiFontTiles": "UI font tiles 1-61, LoadInterfaceTilesVRAM1 -> VRAM1 tiles $C3-$FF.",
    "InterfaceMetatiles": "16 records x 3 rows x 2 tiles (tile - $42, attribute without palette/bank bits).\n"
                          "; Func_0DB6 (type-3 objects) draws record (obj+$19 & $0F) with tile + $42 and attr | $0F.",
    "Bank08InterfaceTiles60F8": "LoadInterfaceTilesVRAM1: 1 tile -> VRAM1 tile $C0.",
    "Bank08InterfaceTiles611A": "LoadInterfaceTilesVRAM1: 16 tiles -> VRAM1 tiles $C3-$D2.",
    "Bank08InterfaceTiles6222": "LoadInterfaceTilesVRAM1: 2 tiles -> VRAM1 tiles $C1-$C2.",
    "Bank08InterfaceTiles626B": "LoadInterfaceTilesVRAM0: 78 tiles -> VRAM0 tiles $80-$CD.",
    "Bank08HudIconTiles": "LoadInterfaceTilesVRAM1: 10 tiles -> VRAM1 tiles $D3-$DC.",
    "ObjectSpritePaletteIndexTable": "Indexed by object +$1E in SelectObjectSpritePalette (palette = value + 4).",
    "Bank08InterfaceTiles6815": "LoadInterfaceTilesVRAM1: 12 tiles -> VRAM1 tiles $DD-$E8.",
    "Bank08InterfaceTiles68DD": "LoadInterfaceTilesVRAM0: 4 tiles -> VRAM0 tiles $CE-$D1.",
    "Bank08ArrowUpTiles": "LoadInterfaceTilesVRAM0: 4 tiles -> VRAM0 tiles $D2-$D5.",
    "Bank08ArrowDownTiles": "LoadInterfaceTilesVRAM0: 4 tiles -> VRAM0 tiles $D6-$D9.",
    "Bank08InterfaceTiles69B5": "LoadInterfaceTilesVRAM0: 4 tiles -> VRAM0 tiles $DA-$DD.",
    "Bank08InterfaceTiles69FD": "LoadInterfaceTilesVRAM1: 8 tiles -> VRAM1 tiles $BB-$C2.",
    "EncodedGlyphTable": "DrawEncodedGlyph: tile = [EncodedGlyphTable + char] + $80 (VRAM1, attribute $0F).\n"
                         "; ASCII '0'-'9' -> 1-10, 'A'-'Z' -> 11-36, every other code -> 0 (blank).",
    "EncodedFontTiles": "37 tiles (blank, 0-9, A-Z): LoadEncodedFontTiles -> VRAM0 $8000 and\n"
                        "; $01:RAM_D9CB -> VRAM1 $8800.",
}
out = ['; BattleTanx (USA) - ROM bank $08: interface and object graphics.\n'
       '; Layout and evidence: BANK08_RESEARCH.md. Every range is checked by tools/bank08.py.\n\n'
       'SECTION "ROM Bank $08", ROMX[$4000], BANK[$08]\n']
anim_off = effect_off = 0
for s, e, cls, label in ranges:
    n = e - s
    note = COMMENTS.get(label)
    if note:
        out.append(f"\n; {note}")
    if label == "UiFontTile0":
        out.append("\nBank08UiFontTiles:\n\tINCBIN \"assets/bank_08/ui_font_tiles.bin\", 0, 16\n")
    elif label == "UiFontTiles":
        out.append("\nUiFontTiles:\n\tINCBIN \"assets/bank_08/ui_font_tiles.bin\", 16\n")
    elif label == "InterfaceMetatiles":
        out.append("\nInterfaceMetatiles:\n" + "".join(
            f"\tdb {h(r(s + 12 * i, 12))} ; {i}\n" for i in range(16)))
    elif cls == "palette" and s in PAL_COPIES:
        ram, sym = PAL_COPIES[s]
        words = ", ".join(f"${K.word(rom, 8, s + 2 * k):04X}" for k in range(4))
        out.append(f"\n{label}:\n\tLOAD UNION \"RAM data ${ram}\", WRAM0[${ram}] ; copied from $08:{s:04X}\n"
                   f"{sym}:\n\tdw {words}\n\tENDL\n")
    elif cls in ("palette", "palette record"):
        words = [K.word(rom, 8, a) for a in range(s, e, 2)]
        body = "".join("\tdw " + ", ".join(f"${x:04X}" for x in words[i:i + 4]) + "\n" for i in range(0, len(words), 4))
        if s == 0x46E8:
            out.append(f"\n; Colour 0 slot; OBJ palette 3 colours 1-3 follow (Func_057D).\n{label}:\n"
                       f"\tdw ${words[0]:04X}\nBank08ObjectPalette46EA:\n\tdw " + ", ".join(f"${x:04X}" for x in words[1:]) + "\n")
        elif s == 0x5500:
            out.append(f"\n; Colour 0 slot; OBJ palette 3 colours 1-3 loaded at the effect start ($3CFB).\n{label}:\n"
                       f"\tdw ${words[0]:04X}\nEffectPalette5502:\n\tdw " + ", ".join(f"${x:04X}" for x in words[1:]) + "\n")
        elif s == 0x67FD:
            out.append("\n; OBJ palettes 4-7, colours 1-3 each (Func_057D supplies colour 0).\n"
                       f"{label}:\n" + "".join("\tdw " + ", ".join(f"${x:04X}" for x in words[i:i + 3]) + "\n"
                                               for i in range(0, 12, 3)))
        else:
            tag = "" if cls == "palette" else " ; palette-shaped record, no reader found"
            out.append(f"\n{label}:{tag}\n{body}")
    elif cls.startswith("graphics") and 0x44A8 <= s < 0x60F0:
        if s < 0x5490:
            refs = "; ".join(sorted(set(frame_refs.get(s, []))))
            out.append(f"\n; Func_3190 frame: {refs}\n" if refs else "\n")
            out.append(f"SpriteTiles{s:04X}:\n\tINCBIN \"assets/bank_08/object_animation_tiles.bin\", {anim_off}, {n}\n")
            anim_off += n
        else:
            reach = "" if cls == "graphics" else " (referenced only by unreachable steps 19-71)"
            out.append(f"\n; Func_3E3C effect tiles: {', '.join(sorted(effect_refs[s]))}{reach}\n"
                       f"SpriteTiles{s:04X}:\n\tINCBIN \"assets/bank_08/effect_tiles.bin\", {effect_off}, {n}\n")
            effect_off += n
    elif cls == "graphics":
        rel = STATIC_ASSET[s]
        alias = "\nBank08AlphanumericFontTiles: ; legacy name; only 4 tiles are loaded from here" if s == 0x69B5 else ""
        out.append(f"\n{label}:{alias}\n\tINCBIN \"{rel}\" ; {n // 16} tiles\n")
    elif cls == "table" and label == "ObjectSpritePaletteIndexTable":
        out.append(f"\n{label}:\n\tdb {', '.join(str(x) for x in r(s, n))}\n")
    elif cls == "table" and label == "EncodedGlyphTable":
        out.append(f"\n{label}:\n" + "".join(f"\tdb {h(r(s + i, 16))} ; ${i:02X}-${i + 15:02X}\n" for i in range(0, 128, 16)))
    elif cls == "unknown":
        out.append(f"\n{label}: ; {n} bytes, no reader found; meaning unknown\n"
                   + "".join(f"\tdb {h(r(a, min(16, e - a)))}\n" for a in range(s, e, 16)))
    elif cls == "code":
        out.append("""
SelectObjectSpritePalette:
	push bc
	push hl
	ld a, l
	and $C0
	add a, $1E
	ld l, a
	ld a, [hl]
	add a, LOW(ObjectSpritePaletteIndexTable)
	ld l, a
	ld a, $00
	adc a, HIGH(ObjectSpritePaletteIndexTable)
	ld h, a
	ld a, [hl]
	and $03
	add a, $04
	ldh [$FF80], a
	pop hl
	pop bc
	ret
""")
    elif cls == "fill":
        out.append("\n\tds $7FFF - @, $00\n")
    elif cls == "marker":
        out.append("\tdb BANK(@) ; ROM bank marker\n")
    else:
        raise SystemExit(f"unhandled range {label}")
out.append("""
	ASSERT InterfaceMetatiles == UiFontTiles + 61 * 16
	ASSERT Bank08UiFontPalette == InterfaceMetatiles + 16 * 12
	ASSERT EncodedFontTiles == EncodedGlyphTable + 128
	ASSERT SelectObjectSpritePalette == EncodedFontTiles + 37 * 16
""")
pathlib.Path("src/bank_08.asm").write_text("".join(out))
print("wrote src/bank_08.asm and", len(assets), "assets")
