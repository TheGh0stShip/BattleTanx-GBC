; BattleTanx (USA) - ROM bank $17: level 7 cell map, tiles, attribute
; lookup table and BG palettes. Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $17", ROMX[$4000], BANK[$17]

; 72 x 112 bytes, row-major. ROM0 $1AA4 copies it to WRAM banks 2-3
; at $D000; ROM0 $1D93 tests bits 6-7 (all clear in ROM). Low bits: unknown.
Level07_CellMap:
	INCBIN "assets/levels/level_07/cellmap.bin"

; 2bpp tiles. ROM0 $1A33 always copies 440 tiles from here; only the first
; LEVEL07_TILE_COUNT belong to this block (the highest tile any map cell uses is
; LEVEL07_TILE_COUNT - 1).
Level07_Tiles:
	INCBIN "assets/levels/level_07/tiles.2bpp"

	db $00 ; never read: the lookup below is addressed as table - 1 + value

; 160 bytes, pointer and bank from $05:$513E. ROM0 $1D93 returns entry
; (value - 1) as the attribute byte for cells with bit 7 set.
Level07_AttrLookup:
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $04, $04, $04, $01, $01, $01, $01, $02, $02, $02, $02, $02, $02, $02
	db $02, $01, $01, $01, $01, $02, $02, $02, $02, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $03, $03, $03, $03, $03, $03, $04, $03, $03, $03, $03
	db $03, $03, $03, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $04, $04, $04, $01, $02, $02, $02, $02, $01, $01, $02, $02, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $00, $04, $04, $04, $04, $80, $80, $80, $80, $80, $04

; RGB555 BG palettes 0-4, loaded by ROM0 $1A86.
Level07_BGPalettes:
	dw $0C02, $314A, $277F, $7FFF ; palette 0
	dw $0141, $0154, $02CA, $02B9 ; palette 1
	dw $006B, $0154, $02B9, $63FF ; palette 2
	dw $2400, $4922, $7A68, $7FB2 ; palette 3
	dw $0C02, $34E7, $59ED, $6738 ; palette 4

	level_bank_end

	ASSERT Level07_Tiles - Level07_CellMap == LEVEL07_WIDTH * LEVEL07_HEIGHT
	ASSERT Level07_AttrLookup - Level07_Tiles == LEVEL07_TILE_COUNT * 16 + 1
	ASSERT Level07_BGPalettes - Level07_AttrLookup == 160
