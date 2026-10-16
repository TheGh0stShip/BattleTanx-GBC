; BattleTanx (USA) - ROM bank $11: level 4 cell map, tiles, attribute
; lookup table and BG palettes. Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $11", ROMX[$4000], BANK[$11]

; 88 x 88 bytes, row-major. ROM0 $1AA4 copies it to WRAM banks 2-3
; at $D000; ROM0 $1D93 tests bits 6-7 (all clear in ROM). Low bits: unknown.
Level04_CellMap:
	INCBIN "assets/levels/level_04/cellmap.bin"

; 2bpp tiles. ROM0 $1A33 always copies 440 tiles from here; only the first
; LEVEL04_TILE_COUNT belong to this block (the highest tile any map cell uses is
; LEVEL04_TILE_COUNT - 1).
Level04_Tiles:
	INCBIN "assets/levels/level_04/tiles.2bpp"

	db $00 ; never read: the lookup below is addressed as table - 1 + value

; 160 bytes, pointer and bank from $05:$513E. ROM0 $1D93 returns entry
; (value - 1) as the attribute byte for cells with bit 7 set.
Level04_AttrLookup:
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $02, $02, $02, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $04
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $02, $02, $02, $04, $04, $04, $04, $04, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $00, $02, $02, $02, $02, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $01

; RGB555 BG palettes 0-6, loaded by ROM0 $1A86.
Level04_BGPalettes:
	dw $0C84, $314A, $277F, $7FFF ; palette 0
	dw $2C40, $5147, $7A08, $7F74 ; palette 1
	dw $0C84, $314A, $4E51, $6738 ; palette 2
	dw $0048, $00EF, $1A39, $3F7F ; palette 3
	dw $001F, $005E, $314A, $02BB ; palette 4
	dw $005E, $314A, $02BB, $7A08 ; palette 5
	dw $0048, $00EF, $7A08, $7F74 ; palette 6

	level_bank_end

	ASSERT Level04_Tiles - Level04_CellMap == LEVEL04_WIDTH * LEVEL04_HEIGHT
	ASSERT Level04_AttrLookup - Level04_Tiles == LEVEL04_TILE_COUNT * 16 + 1
	ASSERT Level04_BGPalettes - Level04_AttrLookup == 160
