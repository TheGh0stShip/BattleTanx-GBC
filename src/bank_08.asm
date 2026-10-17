; BattleTanx (USA) - ROM bank $08: interface and object graphics.
; Layout and evidence: BANK08_RESEARCH.md. Every range is checked by tools/bank08.py.

SECTION "ROM Bank $08", ROMX[$4000], BANK[$08]

; Blank tile 0 of the UI font; no loader copies it (LoadInterfaceTilesVRAM1 starts at +$10).
Bank08UiFontTiles:
	INCBIN "assets/bank_08/ui_font_tiles.bin", 0, 16

; UI font tiles 1-61, LoadInterfaceTilesVRAM1 -> VRAM1 tiles $C3-$FF.
UiFontTiles:
	INCBIN "assets/bank_08/ui_font_tiles.bin", 16

; 16 records x 3 rows x 2 tiles (tile - $42, attribute without palette/bank bits).
; Func_0DB6 (type-3 objects) draws record (obj+$19 & $0F) with tile + $42 and attr | $0F.
InterfaceMetatiles:
	db $81, $00, $81, $20, $82, $00, $83, $00, $84, $00, $85, $00 ; 0
	db $86, $00, $87, $00, $88, $00, $89, $00, $84, $00, $85, $00 ; 1
	db $8A, $00, $8B, $00, $8C, $00, $8D, $00, $84, $00, $85, $00 ; 2
	db $8E, $00, $8F, $00, $90, $00, $91, $00, $84, $00, $92, $00 ; 3
	db $93, $00, $94, $00, $95, $00, $96, $00, $84, $00, $97, $00 ; 4
	db $98, $00, $99, $00, $9A, $00, $9B, $00, $84, $00, $9C, $00 ; 5
	db $9D, $00, $9E, $00, $9F, $00, $A0, $00, $84, $00, $A1, $00 ; 6
	db $A2, $00, $A3, $00, $A4, $00, $A5, $00, $84, $00, $A6, $00 ; 7
	db $A7, $00, $A7, $20, $A8, $00, $A9, $00, $AA, $00, $AB, $00 ; 8
	db $A3, $20, $A2, $20, $AC, $00, $AD, $00, $AE, $00, $85, $00 ; 9
	db $9E, $20, $9D, $20, $AF, $00, $B0, $00, $B1, $00, $85, $00 ; 10
	db $99, $20, $98, $20, $B2, $00, $B3, $00, $B4, $00, $85, $00 ; 11
	db $94, $20, $93, $20, $B5, $00, $B6, $00, $B7, $00, $85, $00 ; 12
	db $8F, $20, $8E, $20, $B8, $00, $B9, $00, $BA, $00, $85, $00 ; 13
	db $8B, $20, $8A, $20, $BB, $00, $BC, $00, $84, $00, $85, $00 ; 14
	db $87, $20, $86, $20, $BD, $00, $BC, $00, $84, $00, $85, $00 ; 15

Bank08UiFontPalette:
	LOAD UNION "RAM data $C721", WRAM0[$C721] ; copied from $08:44A0
wUiFontPalette:
	dw $0C84, $314A, $4E51, $6738
	ENDL

; Func_3190 frame: frame table $02:4565[0] (9 tiles); frame table $02:4565[7] (9 tiles)
SpriteTiles44A8:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 0, 144

; Func_3190 frame: frame table $02:4565[1] (9 tiles); frame table $02:4565[6] (9 tiles)
SpriteTiles4538:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 144, 144

; Func_3190 frame: frame table $02:4565[2] (9 tiles); frame table $02:4565[5] (9 tiles)
SpriteTiles45C8:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 288, 144

; Func_3190 frame: frame table $02:4565[3] (9 tiles); frame table $02:4565[4] (9 tiles)
SpriteTiles4658:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 432, 144

; Colour 0 slot; OBJ palette 3 colours 1-3 follow (Func_057D).
PaletteRecord46E8:
	dw $0000
Bank08ObjectPalette46EA:
	dw $001C, $025C, $03FF

; Func_3190 frame: frame table $02:4575[0] (9 tiles)
SpriteTiles46F0:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 576, 144

; Func_3190 frame: frame table $02:4575[1] (9 tiles)
SpriteTiles4780:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 720, 144

; Func_3190 frame: frame table $02:4575[2] (9 tiles)
SpriteTiles4810:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 864, 144

; Func_3190 frame: frame table $02:4575[3] (9 tiles)
SpriteTiles48A0:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 1008, 144

; Func_3190 frame: frame table $02:4575[4] (9 tiles)
SpriteTiles4930:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 1152, 144

PaletteRecord49C0: ; byte-identical to PaletteRecord46E8 / Bank08ObjectPalette46EA (unread)
	dw $0000, $001C, $025C, $03FF

; Func_3190 frame: frame table $02:457F[0] (9 tiles)
SpriteTiles49C8:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 1296, 144

; Func_3190 frame: frame table $02:457F[1] (9 tiles)
SpriteTiles4A58:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 1440, 144

; Func_3190 frame: frame table $02:457F[2] (9 tiles)
SpriteTiles4AE8:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 1584, 144

; Func_3190 frame: frame table $02:457F[3] (9 tiles)
SpriteTiles4B78:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 1728, 144

; Func_3190 frame: frame table $02:457F[4] (9 tiles)
SpriteTiles4C08:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 1872, 144

; Func_3190 frame: frame table $02:457F[5] (9 tiles)
SpriteTiles4C98:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 2016, 144

; Func_3190 frame: frame table $02:457F[6] (9 tiles)
SpriteTiles4D28:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 2160, 144

; Func_3190 frame: frame table $02:457F[7] (9 tiles)
SpriteTiles4DB8:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 2304, 144

; Func_3190 frame: frame table $02:457F[8] (9 tiles)
SpriteTiles4E48:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 2448, 144

; Func_3190 frame: frame table $02:457F[9] (9 tiles)
SpriteTiles4ED8:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 2592, 144

; Func_3190 frame: frame table $02:457F[10] (9 tiles)
SpriteTiles4F68:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 2736, 144

PaletteRecord4FF8: ; byte-identical to PaletteRecord46E8 / Bank08ObjectPalette46EA (unread)
	dw $0000, $001C, $025C, $03FF

; Func_3190 frame: frame table $02:4595[0] (4 tiles)
SpriteTiles5000:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 2880, 64

; Func_3190 frame: frame table $02:4595[1] (4 tiles)
SpriteTiles5040:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 2944, 64

; Func_3190 frame: frame table $02:4595[2] (4 tiles)
SpriteTiles5080:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 3008, 64

; Func_3190 frame: frame table $02:4595[3] (4 tiles)
SpriteTiles50C0:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 3072, 64

PaletteRecord5100: ; byte-identical to PaletteRecord46E8 / Bank08ObjectPalette46EA (unread)
	dw $0000, $001C, $025C, $03FF

; Func_3190 frame: frame table $02:459D[0] (4 tiles)
SpriteTiles5108:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 3136, 64

; Func_3190 frame: frame table $02:459D[1] (4 tiles)
SpriteTiles5148:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 3200, 64

; Func_3190 frame: frame table $02:459D[2] (4 tiles)
SpriteTiles5188:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 3264, 64

; Func_3190 frame: frame table $02:459D[3] (4 tiles)
SpriteTiles51C8:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 3328, 64

PaletteRecord5208: ; byte-identical to PaletteRecord46E8 / Bank08ObjectPalette46EA (unread)
	dw $0000, $001C, $025C, $03FF

; Func_3190 frame: frame table $02:45A5[0] (4 tiles)
SpriteTiles5210:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 3392, 64

; Func_3190 frame: frame table $02:45A5[1] (4 tiles)
SpriteTiles5250:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 3456, 64

; Func_3190 frame: frame table $02:45A5[2] (4 tiles)
SpriteTiles5290:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 3520, 64

; Func_3190 frame: frame table $02:45A5[3] (4 tiles)
SpriteTiles52D0:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 3584, 64

PaletteRecord5310: ; byte-identical to PaletteRecord46E8 / Bank08ObjectPalette46EA (unread)
	dw $0000, $001C, $025C, $03FF

; Func_3190 frame: frame table $02:45AD[0] (4 tiles)
SpriteTiles5318:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 3648, 64

; Func_3190 frame: frame table $02:45AD[1] (4 tiles)
SpriteTiles5358:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 3712, 64

; Func_3190 frame: frame table $02:45AD[2] (4 tiles)
SpriteTiles5398:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 3776, 64

; Func_3190 frame: frame table $02:45AD[3] (4 tiles)
SpriteTiles53D8:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 3840, 64

PaletteRecord5418: ; byte-identical to PaletteRecord46E8 / Bank08ObjectPalette46EA (unread)
	dw $0000, $001C, $025C, $03FF

; Func_3190 frame: frame table $02:45B5[0] (1 tiles)
SpriteTiles5420:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 3904, 16

; Func_3190 frame: frame table $02:45B5[1] (1 tiles)
SpriteTiles5430:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 3920, 16

; Func_3190 frame: frame table $02:45B5[2] (1 tiles)
SpriteTiles5440:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 3936, 16

PaletteRecord5450: ; byte-identical to PaletteRecord46E8 / Bank08ObjectPalette46EA (unread)
	dw $0000, $001C, $025C, $03FF

; Func_3190 frame: frame table $02:45BB[0] (1 tiles)
SpriteTiles5458:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 3952, 16

; Func_3190 frame: frame table $02:45BB[1] (1 tiles)
SpriteTiles5468:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 3968, 16

; Func_3190 frame: frame table $02:45BB[2] (1 tiles)
SpriteTiles5478:
	INCBIN "assets/bank_08/object_animation_tiles.bin", 3984, 16

PaletteRecord5488: ; byte-identical to PaletteRecord46E8 / Bank08ObjectPalette46EA (unread)
	dw $0000, $001C, $025C, $03FF

; Func_3E3C effect tiles: 7 tiles
SpriteTiles5490:
	INCBIN "assets/bank_08/effect_tiles.bin", 0, 112

; Colour 0 slot; OBJ palette 3 colours 1-3 loaded at the effect start ($3CFB).
PaletteRecord5500:
	dw $0000
EffectPalette5502:
	dw $7D04, $46A0, $7FFF

; Func_3E3C effect tiles: 9 tiles
SpriteTiles5508:
	INCBIN "assets/bank_08/effect_tiles.bin", 112, 144

PaletteRecord5598: ; byte-identical to PaletteRecord5500 / EffectPalette5502 (unread)
	dw $0000, $7D04, $46A0, $7FFF

; Func_3E3C effect tiles: 7 tiles
SpriteTiles55A0:
	INCBIN "assets/bank_08/effect_tiles.bin", 256, 112

PaletteRecord5610: ; byte-identical to PaletteRecord5500 / EffectPalette5502 (unread)
	dw $0000, $7D04, $46A0, $7FFF

; Func_3E3C effect tiles: 7 tiles
SpriteTiles5618:
	INCBIN "assets/bank_08/effect_tiles.bin", 368, 112

PaletteRecord5688: ; byte-identical to PaletteRecord5500 / EffectPalette5502 (unread)
	dw $0000, $7D04, $46A0, $7FFF

; Func_3E3C effect tiles: 6 tiles
SpriteTiles5690:
	INCBIN "assets/bank_08/effect_tiles.bin", 480, 96

PaletteRecord56F0: ; byte-identical to PaletteRecord5500 / EffectPalette5502 (unread)
	dw $0000, $7D04, $46A0, $7FFF

; Func_3E3C effect tiles: 6 tiles
SpriteTiles56F8:
	INCBIN "assets/bank_08/effect_tiles.bin", 576, 96

PaletteRecord5758: ; byte-identical to PaletteRecord5500 / EffectPalette5502 (unread)
	dw $0000, $7D04, $46A0, $7FFF

; Func_3E3C effect tiles: 8 tiles
SpriteTiles5760:
	INCBIN "assets/bank_08/effect_tiles.bin", 672, 128

PaletteRecord57E0: ; byte-identical to PaletteRecord5500 / EffectPalette5502 (unread)
	dw $0000, $7D04, $46A0, $7FFF

; Func_3E3C effect tiles: 9 tiles
SpriteTiles57E8:
	INCBIN "assets/bank_08/effect_tiles.bin", 800, 144

PaletteRecord5878: ; byte-identical to PaletteRecord5500 / EffectPalette5502 (unread)
	dw $0000, $7D04, $46A0, $7FFF

; Func_3E3C effect tiles: 9 tiles
SpriteTiles5880:
	INCBIN "assets/bank_08/effect_tiles.bin", 944, 144

PaletteRecord5910: ; colours 1-3 = EffectPalette5502 with colour 1 $7D03 (unread)
	dw $0000, $7D03, $46A0, $7FFF

; Func_3E3C effect tiles: 7 tiles (referenced only by unreachable steps 19-71)
SpriteTiles5918:
	INCBIN "assets/bank_08/effect_tiles.bin", 1088, 112

PaletteRecord5988: ; colours 1-3 = EffectPalette5502 with colour 1 $7D03 (unread)
	dw $0000, $7D03, $46A0, $7FFF

; Func_3E3C effect tiles: 6 tiles (referenced only by unreachable steps 19-71)
SpriteTiles5990:
	INCBIN "assets/bank_08/effect_tiles.bin", 1200, 96

PaletteRecord59F0: ; byte-identical to PaletteRecord5500 / EffectPalette5502 (unread)
	dw $0000, $7D04, $46A0, $7FFF

; Func_3E3C effect tiles: 6 tiles (referenced only by unreachable steps 19-71)
SpriteTiles59F8:
	INCBIN "assets/bank_08/effect_tiles.bin", 1296, 96

PaletteRecord5A58: ; byte-identical to PaletteRecord5500 / EffectPalette5502 (unread)
	dw $0000, $7D04, $46A0, $7FFF

; Func_3E3C effect tiles: 7 tiles
SpriteTiles5A60:
	INCBIN "assets/bank_08/effect_tiles.bin", 1392, 112

PaletteRecord5AD0: ; byte-identical to PaletteRecord5500 / EffectPalette5502 (unread)
	dw $0000, $7D04, $46A0, $7FFF

; Func_3E3C effect tiles: 8 tiles
SpriteTiles5AD8:
	INCBIN "assets/bank_08/effect_tiles.bin", 1504, 128

PaletteRecord5B58: ; byte-identical to PaletteRecord5500 / EffectPalette5502 (unread)
	dw $0000, $7D04, $46A0, $7FFF

; Func_3E3C effect tiles: 9 tiles
SpriteTiles5B60:
	INCBIN "assets/bank_08/effect_tiles.bin", 1632, 144

PaletteRecord5BF0: ; byte-identical to PaletteRecord5500 / EffectPalette5502 (unread)
	dw $0000, $7D04, $46A0, $7FFF

; Func_3E3C effect tiles: 4 tiles (referenced only by unreachable steps 19-71)
SpriteTiles5BF8:
	INCBIN "assets/bank_08/effect_tiles.bin", 1776, 64

PaletteRecord5C38: ; colours 1-3 = EffectPalette5502 with colour 1 $7D03 (unread)
	dw $0000, $7D03, $46A0, $7FFF

; Func_3E3C effect tiles: 6 tiles (referenced only by unreachable steps 19-71)
SpriteTiles5C40:
	INCBIN "assets/bank_08/effect_tiles.bin", 1840, 96

PaletteRecord5CA0: ; colours 1-3 = EffectPalette5502 with colour 1 $7D03 (unread)
	dw $0000, $7D03, $46A0, $7FFF

; Func_3E3C effect tiles: 6 tiles (referenced only by unreachable steps 19-71)
SpriteTiles5CA8:
	INCBIN "assets/bank_08/effect_tiles.bin", 1936, 96

PaletteRecord5D08: ; colours 1-3 = EffectPalette5502 with colour 1 $7D03 (unread)
	dw $0000, $7D03, $46A0, $7FFF

; Func_3E3C effect tiles: 3 tiles (referenced only by unreachable steps 19-71)
SpriteTiles5D10:
	INCBIN "assets/bank_08/effect_tiles.bin", 2032, 48

PaletteRecord5D40: ; byte-identical to PaletteRecord5500 / EffectPalette5502 (unread)
	dw $0000, $7D04, $46A0, $7FFF

; Func_3E3C effect tiles: 4 tiles (referenced only by unreachable steps 19-71)
SpriteTiles5D48:
	INCBIN "assets/bank_08/effect_tiles.bin", 2080, 64

PaletteRecord5D88: ; byte-identical to PaletteRecord5500 / EffectPalette5502 (unread)
	dw $0000, $7D04, $46A0, $7FFF

; Func_3E3C effect tiles: 3 tiles (referenced only by unreachable steps 19-71)
SpriteTiles5D90:
	INCBIN "assets/bank_08/effect_tiles.bin", 2144, 48

PaletteRecord5DC0: ; byte-identical to PaletteRecord5500 / EffectPalette5502 (unread)
	dw $0000, $7D04, $46A0, $7FFF

; Func_3E3C effect tiles: 7 tiles
SpriteTiles5DC8:
	INCBIN "assets/bank_08/effect_tiles.bin", 2192, 112

PaletteRecord5E38: ; colours 1-3 = EffectPalette5502 with colour 1 $7D03 (unread)
	dw $0000, $7D03, $46A0, $7FFF

; Func_3E3C effect tiles: 13 tiles
SpriteTiles5E40:
	INCBIN "assets/bank_08/effect_tiles.bin", 2304, 208

PaletteRecord5F10: ; colours 1-3 = EffectPalette5502 with colour 1 $7D03 (unread)
	dw $0000, $7D03, $46A0, $7FFF

; Func_3E3C effect tiles: 11 tiles
SpriteTiles5F18:
	INCBIN "assets/bank_08/effect_tiles.bin", 2512, 176

PaletteRecord5FC8: ; byte-identical to PaletteRecord5500 / EffectPalette5502 (unread)
	dw $0000, $7D04, $46A0, $7FFF

; Func_3E3C effect tiles: 3 tiles, 6 tiles (referenced only by unreachable steps 19-71)
SpriteTiles5FD0:
	INCBIN "assets/bank_08/effect_tiles.bin", 2688, 96

PaletteRecord6030: ; colours 1-3 = EffectPalette5502 with colour 1 $7D03 (unread)
	dw $0000, $7D03, $46A0, $7FFF

; Func_3E3C effect tiles: 4 tiles (referenced only by unreachable steps 19-71)
SpriteTiles6038:
	INCBIN "assets/bank_08/effect_tiles.bin", 2784, 64

PaletteRecord6078: ; colours 1-3 = EffectPalette5502 with colour 1 $7D03 (unread)
	dw $0000, $7D03, $46A0, $7FFF

; Func_3E3C effect tiles: 3 tiles, 7 tiles (referenced only by unreachable steps 19-71)
SpriteTiles6080:
	INCBIN "assets/bank_08/effect_tiles.bin", 2848, 112

PaletteRecord60F0: ; colours 1-3 = EffectPalette5502 with colour 1 $7D03 (unread)
	dw $0000, $7D03, $46A0, $7FFF

; LoadInterfaceTilesVRAM1: 1 tile -> VRAM1 tile $C0.
Bank08InterfaceTiles60F8:
	INCBIN "assets/bank_08/interface_tiles_60F8.bin" ; 1 tiles

Bank08UnreferencedData6108: ; 2 bytes, no reader found; original purpose unknown
	db $81, $00

PaletteRecord610A: ; byte-identical to PaletteRecord621A; $033F is in no loaded palette (unread)
	dw $0000, $001F, $033F, $03FE

; Complete, valid RGB555 palette record; no reader was found. All four entries
; are the same blue colour.
Bank08UnusedPalette6112:
	dw $001F, $001F, $001F, $001F

; LoadInterfaceTilesVRAM1: 16 tiles -> VRAM1 tiles $C3-$D2.
Bank08InterfaceTiles611A:
	INCBIN "assets/bank_08/interface_tiles_611A.bin" ; 16 tiles

PaletteRecord621A: ; byte-identical to PaletteRecord610A; $033F is in no loaded palette (unread)
	dw $0000, $001F, $033F, $03FE

; LoadInterfaceTilesVRAM1: 2 tiles -> VRAM1 tiles $C1-$C2.
Bank08InterfaceTiles6222:
	INCBIN "assets/bank_08/interface_tiles_6222.bin" ; 2 tiles

PaletteRecord6242: ; byte-identical to PaletteRecord46E8 / Bank08ObjectPalette46EA (unread)
	dw $0000, $001C, $025C, $03FF

Bank08UnreferencedData624A: ; 6 bytes, no reader found; original purpose unknown
	db $01, $00, $01, $00, $01, $00

; Unread duplicate of tile 47 in Bank08InterfaceTiles626B.
Bank08DuplicateInterfaceTile6250:
	INCBIN "assets/bank_08/interface_tiles_626B.bin", 47 * 16, 16

Bank08UnreferencedData6260: ; 3 bytes, no reader found; original purpose unknown
	db $80, $00, $01

PaletteRecord6263: ; byte-identical to Bank08HudIconPalette (unread)
	dw $0000, $10A3, $3200, $42E0

; LoadInterfaceTilesVRAM0: 78 tiles -> VRAM0 tiles $80-$CD.
Bank08InterfaceTiles626B:
	INCBIN "assets/bank_08/interface_tiles_626B.bin" ; 78 tiles

Bank08HudIconPalette:
	LOAD UNION "RAM data $C6F9", WRAM0[$C6F9] ; copied from $08:674B
wHudIconPalette:
	dw $0000, $10A3, $3200, $42E0
	ENDL

; LoadInterfaceTilesVRAM1: 10 tiles -> VRAM1 tiles $D3-$DC.
Bank08HudIconTiles:
	INCBIN "assets/bank_08/hud_icon_tiles.bin" ; 10 tiles

; Indexed by status-4 object type 0-9 in SelectObjectSpritePalette
; (OBJ palette = (value & 3) + 4).
ObjectSpritePaletteIndexTable:
	db 0 ; type 0
	db 1 ; type 1
	db 0 ; type 2
	db 2 ; type 3
	db 3 ; type 4
	db 1 ; type 5
	db 2 ; type 6
	db 0 ; type 7
	db 3 ; type 8
	db 0 ; type 9
ASSERT @ - ObjectSpritePaletteIndexTable == 10

; OBJ palettes 4-7, colours 1-3 each (Func_057D supplies colour 0).
Bank08ObjectPalettes67FD:
	dw $0000, $7002, $03FE
	dw $0C12, $001F, $7FFF
	dw $1515, $15DE, $1FFF
	dw $0000, $5818, $7E9F

; LoadInterfaceTilesVRAM1: 12 tiles -> VRAM1 tiles $DD-$E8.
Bank08InterfaceTiles6815:
	INCBIN "assets/bank_08/interface_tiles_6815.bin" ; 12 tiles

PaletteRecord68D5: ; unique; $465F is in no loaded palette (unread)
Bank08InterfacePalette68D5: ; legacy alias, used by tools/bank08.py and reports/
	dw $0000, $001F, $465F, $7FFF

; LoadInterfaceTilesVRAM0: 4 tiles -> VRAM0 tiles $4E-$51 (VRAM $84E0).
Bank08InterfaceTiles68DD:
	INCBIN "assets/bank_08/interface_tiles_68DD.bin" ; 4 tiles

; HudPowerupPalettes entry 1: palette of HUD power-up kind 1, tile $4E (Bank08InterfaceTiles68DD).
Bank08PowerupIcon1Palette:
Bank08ArrowUpPalette: ; legacy alias, used by tools/bank08.py and docs
	LOAD UNION "RAM data $C701", WRAM0[$C701] ; copied from $08:691D
wPowerupIcon1Palette:
wArrowUpPalette: ; legacy alias, used by tools/bank08.py and docs
	dw $0000, $10A3, $1515, $1FFF
	ENDL

; LoadInterfaceTilesVRAM0: 4 tiles -> VRAM0 tiles $52-$55.
Bank08ArrowUpTiles:
	INCBIN "assets/bank_08/arrow_up_tiles.bin" ; 4 tiles

; HudPowerupPalettes entry 2: palette of HUD power-up kind 2, tile $52 (Bank08ArrowUpTiles).
Bank08PowerupIcon2Palette:
Bank08ArrowDownPalette: ; legacy alias, used by tools/bank08.py and docs
	LOAD UNION "RAM data $C709", WRAM0[$C709] ; copied from $08:6965
wPowerupIcon2Palette:
wArrowDownPalette: ; legacy alias, used by tools/bank08.py and docs
	dw $0000, $001F, $10A3, $7FFF
	ENDL

; LoadInterfaceTilesVRAM0: 4 tiles -> VRAM0 tiles $56-$59.
Bank08ArrowDownTiles:
	INCBIN "assets/bank_08/arrow_down_tiles.bin" ; 4 tiles

; HudPowerupPalettes entry 3: palette of HUD power-up kind 3, tile $56 (Bank08ArrowDownTiles).
Bank08PowerupIcon3Palette:
Bank08AlphanumericFontPalette: ; legacy alias, used by tools/bank08.py and docs
	LOAD UNION "RAM data $C711", WRAM0[$C711] ; copied from $08:69AD
wPowerupIcon3Palette:
wAlphanumericFontPalette: ; legacy alias, used by tools/bank08.py and docs
	dw $0000, $0000, $0000, $03FE
	ENDL

; LoadInterfaceTilesVRAM0: 4 tiles -> VRAM0 tiles $5A-$5D.
; HUD alert icon: tiles $5A-$5D, drawn with attribute $87 while wHudAlertActive is set.
Bank08InterfaceTiles69B5:
Bank08HudAlertIconTiles:
Bank08AlphanumericFontTiles: ; legacy alias, used by tools/bank08.py and docs
	INCBIN "assets/bank_08/interface_tiles_69B5.bin" ; 4 tiles

PaletteRecord69F5: ; colours 2-3 = OBJ palette 7 of Bank08ObjectPalettes67FD colours 2-3 (unread)
	dw $0000, $10A3, $5818, $7E9F

; LoadInterfaceTilesVRAM1: 8 tiles -> VRAM1 tiles $BB-$C2.
Bank08InterfaceTiles69FD:
	INCBIN "assets/bank_08/interface_tiles_69FD.bin" ; 8 tiles

; Eight native 2bpp tiles followed by a dark-to-light RGB555 palette. No ROM
; pointer or traced reader reaches either range, so their gameplay role remains
; unknown and they are deliberately named only by format and address.
Bank08UnreferencedTiles6A7D:
	INCBIN "assets/bank_08/unreferenced_tiles_6A7D.bin" ; 8 tiles

Bank08UnreferencedPalette6AFD:
	dw $1840, $3989, $560E, $7315

; DrawEncodedGlyph: tile = [EncodedGlyphTable + char] + $80 (VRAM1, attribute $0F).
; ASCII '0'-'9' -> 1-10, 'A'-'Z' -> 11-36, every other code -> 0 (blank).
EncodedGlyphTable:
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; $00-$0F
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; $10-$1F
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; $20-$2F
	db $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $00, $00, $00, $00, $00, $00 ; $30-$3F
	db $00, $0B, $0C, $0D, $0E, $0F, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19 ; $40-$4F
	db $1A, $1B, $1C, $1D, $1E, $1F, $20, $21, $22, $23, $24, $00, $00, $00, $00, $00 ; $50-$5F
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; $60-$6F
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; $70-$7F

; 37 tiles (blank, 0-9, A-Z): LoadEncodedFontTiles -> VRAM0 $8000 and
; $01:LoadEncodedFontTilesToVram1 -> VRAM1 $8800.
EncodedFontTiles:
	INCBIN "assets/bank_08/encoded_font_tiles.bin" ; 37 tiles

SelectObjectSpritePalette:
	push bc
	push hl
	ld a, l
	and $C0
	add a, OBJECT_TYPE_OFFSET
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
	ldh [hStatus4SpritePalette], a
	pop hl
	pop bc
	ret

	ds $7FFF - @, $00
	db BANK(@) ; ROM bank marker

	ASSERT InterfaceMetatiles == UiFontTiles + 61 * 16
	ASSERT Bank08UiFontPalette == InterfaceMetatiles + 16 * 12
	ASSERT EncodedFontTiles == EncodedGlyphTable + 128
	ASSERT SelectObjectSpritePalette == EncodedFontTiles + 37 * 16
