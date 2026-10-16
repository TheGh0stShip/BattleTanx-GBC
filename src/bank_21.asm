; BattleTanx (USA) - ROM bank $21: level 12 cell map, tiles, attribute
; lookup table and BG palettes. Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $21", ROMX[$4000], BANK[$21]

; 120 x 64 bytes, row-major. ROM0 $1AA4 copies it to WRAM banks 2-3
; at $D000; ROM0 $1D93 tests bits 6-7 (all clear in ROM). Low bits: unknown.
Level12_CellMap:
	INCBIN "assets/levels/level_12/cellmap.bin"

; 2bpp tiles. ROM0 $1A33 always copies 440 tiles from here; only the first
; LEVEL12_TILE_COUNT belong to this block (the highest tile any map cell uses is
; LEVEL12_TILE_COUNT - 1).
Level12_Tiles:
	INCBIN "assets/levels/level_12/tiles.2bpp"

	db $00 ; never read: the lookup below is addressed as table - 1 + value

; 160 bytes, pointer and bank from $05:$513E. ROM0 $1D93 returns entry
; (value - 1) as the attribute byte for cells with bit 7 set.
Level12_AttrLookup:
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $04, $04, $04, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $04
	db $02, $02, $02, $00, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $04, $04, $04, $01, $01, $01, $01, $01, $03, $03, $03, $03, $03, $03
	db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

; RGB555 BG palettes 0-6, loaded by ROM0 $1A86.
Level12_BGPalettes:
	dw $1840, $314A, $03FF, $6739 ; palette 0
	dw $1840, $11C0, $3EC1, $2B6F ; palette 1
	dw $1840, $40E2, $660E, $7E76 ; palette 2
	dw $0C84, $314A, $4E73, $6739 ; palette 3
	dw $0C84, $380B, $4D11, $7E7A ; palette 4
	dw $0065, $0850, $0CF6, $3A1B ; palette 5
	dw $380B, $4D11, $3EC1, $7E7A ; palette 6

	level_bank_end

	ASSERT Level12_Tiles - Level12_CellMap == LEVEL12_WIDTH * LEVEL12_HEIGHT
	ASSERT Level12_AttrLookup - Level12_Tiles == LEVEL12_TILE_COUNT * 16 + 1
	ASSERT Level12_BGPalettes - Level12_AttrLookup == 160
