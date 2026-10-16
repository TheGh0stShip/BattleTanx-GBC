; BattleTanx (USA) - ROM bank $19: level 8 cell map, tiles, attribute
; lookup table and BG palettes. Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $19", ROMX[$4000], BANK[$19]

; 112 x 72 bytes, row-major. ROM0 $1AA4 copies it to WRAM banks 2-3
; at $D000; ROM0 $1D93 tests bits 6-7 (all clear in ROM). Low bits: unknown.
Level08_CellMap:
	INCBIN "assets/levels/level_08/cellmap.bin"

; 2bpp tiles. ROM0 $1A33 always copies 440 tiles from here; only the first
; LEVEL08_TILE_COUNT belong to this block (the highest tile any map cell uses is
; LEVEL08_TILE_COUNT - 1).
Level08_Tiles:
	INCBIN "assets/levels/level_08/tiles.2bpp"

	db $00 ; never read: the lookup below is addressed as table - 1 + value

; 160 bytes, pointer and bank from $05:$513E. ROM0 $1D93 returns entry
; (value - 1) as the attribute byte for cells with bit 7 set.
Level08_AttrLookup:
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

; RGB555 BG palettes 0-6, loaded by ROM0 $1A86.
Level08_BGPalettes:
	dw $0C02, $314A, $277F, $7FFF ; palette 0
	dw $0141, $0154, $02CA, $02B9 ; palette 1
	dw $006B, $0154, $02B9, $63FF ; palette 2
	dw $2400, $4922, $7A68, $7FB2 ; palette 3
	dw $0C02, $34E7, $59ED, $6738 ; palette 4
	dw $2400, $1C2E, $5196, $729D ; palette 5
	dw $0154, $015F, $027B, $277F ; palette 6

	level_bank_end

	ASSERT Level08_Tiles - Level08_CellMap == LEVEL08_WIDTH * LEVEL08_HEIGHT
	ASSERT Level08_AttrLookup - Level08_Tiles == LEVEL08_TILE_COUNT * 16 + 1
	ASSERT Level08_BGPalettes - Level08_AttrLookup == 160
