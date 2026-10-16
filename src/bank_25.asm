; BattleTanx (USA) - ROM bank $25: level 14 cell map, tiles, attribute
; lookup table and BG palettes. Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $25", ROMX[$4000], BANK[$25]

; 64 x 120 bytes, row-major. ROM0 $1AA4 copies it to WRAM banks 2-3
; at $D000; ROM0 $1D93 tests bits 6-7 (all clear in ROM). Low bits: unknown.
Level14_CellMap:
	INCBIN "assets/levels/level_14/cellmap.bin"

; 2bpp tiles. ROM0 $1A33 always copies 440 tiles from here; only the first
; LEVEL14_TILE_COUNT belong to this block (the highest tile any map cell uses is
; LEVEL14_TILE_COUNT - 1).
Level14_Tiles:
	INCBIN "assets/levels/level_14/tiles.2bpp"

	db $00 ; never read: the lookup below is addressed as table - 1 + value

; 160 bytes, pointer and bank from $05:$513E. ROM0 $1D93 returns entry
; (value - 1) as the attribute byte for cells with bit 7 set.
Level14_AttrLookup:
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $05, $05, $05, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $05
	db $02, $02, $02, $00, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $05, $05, $05, $01, $01, $01, $01, $01, $03, $03, $03, $03, $03, $03
	db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01

; RGB555 BG palettes 0-6, loaded by ROM0 $1A86.
Level14_BGPalettes:
	dw $1840, $314A, $03FF, $6739 ; palette 0
	dw $1840, $11C0, $3EC1, $2B6F ; palette 1
	dw $1840, $40E2, $660E, $7E76 ; palette 2
	dw $0C84, $314A, $4E73, $6739 ; palette 3
	dw $3806, $550E, $7E76, $7EF9 ; palette 4
	dw $0C84, $380B, $4D11, $7E7A ; palette 5
	dw $0065, $0850, $0CF6, $3A1B ; palette 6

	level_bank_end

	ASSERT Level14_Tiles - Level14_CellMap == LEVEL14_WIDTH * LEVEL14_HEIGHT
	ASSERT Level14_AttrLookup - Level14_Tiles == LEVEL14_TILE_COUNT * 16 + 1
	ASSERT Level14_BGPalettes - Level14_AttrLookup == 160
