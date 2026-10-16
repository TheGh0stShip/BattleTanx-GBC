; BattleTanx (USA) - ROM bank $15: level 6 cell map, tiles, attribute
; lookup table and BG palettes. Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $15", ROMX[$4000], BANK[$15]

; 88 x 80 bytes, row-major. ROM0 $1AA4 copies it to WRAM banks 2-3
; at $D000; ROM0 $1D93 tests bits 6-7 (all clear in ROM). Low bits: unknown.
Level06_CellMap:
	INCBIN "assets/levels/level_06/cellmap.bin"

; 2bpp tiles. ROM0 $1A33 always copies 440 tiles from here; only the first
; LEVEL06_TILE_COUNT belong to this block (the highest tile any map cell uses is
; LEVEL06_TILE_COUNT - 1).
Level06_Tiles:
	INCBIN "assets/levels/level_06/tiles.2bpp"

	db $00 ; never read: the lookup below is addressed as table - 1 + value

; 160 bytes, pointer and bank from $05:$513E. ROM0 $1D93 returns entry
; (value - 1) as the attribute byte for cells with bit 7 set.
Level06_AttrLookup:
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $04, $04, $04, $01, $01, $01, $01, $02, $02, $02, $02, $02, $02, $02
	db $02, $01, $01, $01, $01, $02, $02, $02, $02, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $03, $03, $03, $03, $03, $03, $04, $03, $03, $03, $03
	db $03, $03, $03, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $04, $04, $04, $01, $02, $02, $02, $02, $01, $01, $02, $02, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $00, $04, $04, $04, $04, $80, $80, $80, $80, $80, $02

; RGB555 BG palettes 0-4, loaded by ROM0 $1A86.
Level06_BGPalettes:
	dw $0C02, $314A, $277F, $7FFF ; palette 0
	dw $0141, $0154, $02CA, $02B9 ; palette 1
	dw $006B, $0154, $02B9, $63FF ; palette 2
	dw $2400, $4922, $7A68, $7FB2 ; palette 3
	dw $0C02, $34E7, $59ED, $6738 ; palette 4

	level_bank_end

	ASSERT Level06_Tiles - Level06_CellMap == LEVEL06_WIDTH * LEVEL06_HEIGHT
	ASSERT Level06_AttrLookup - Level06_Tiles == LEVEL06_TILE_COUNT * 16 + 1
	ASSERT Level06_BGPalettes - Level06_AttrLookup == 160
