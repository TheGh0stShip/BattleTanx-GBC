; BattleTanx (USA) - ROM bank $1B: level 9 cell map, tiles, attribute
; lookup table and BG palettes. Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $1B", ROMX[$4000], BANK[$1B]

; 64 x 120 bytes, row-major. ROM0 $1AA4 copies it to WRAM banks 2-3
; at $D000; ROM0 $1D93 tests bits 6-7 (all clear in ROM). Low bits: unknown.
Level09_CellMap:
	INCBIN "assets/levels/level_09/cellmap.bin"

; 2bpp tiles. ROM0 $1A33 always copies 440 tiles from here; only the first
; LEVEL09_TILE_COUNT belong to this block (the highest tile any map cell uses is
; LEVEL09_TILE_COUNT - 1).
Level09_Tiles:
	INCBIN "assets/levels/level_09/tiles.2bpp"

	db $00 ; never read: the lookup below is addressed as table - 1 + value

; 160 bytes, pointer and bank from $05:$513E. ROM0 $1D93 returns entry
; (value - 1) as the attribute byte for cells with bit 7 set.
Level09_AttrLookup:
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $03, $03, $03, $01, $01, $01, $01, $80, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $01, $01, $02, $02, $02, $02, $02, $02, $02, $02
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $03, $03, $03, $01, $01, $01, $01, $01, $01, $01, $01, $03, $03, $03
	db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00, $03, $03, $03, $03
	db $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $05

; RGB555 BG palettes 0-5, loaded by ROM0 $1A86.
Level09_BGPalettes:
	dw $0C84, $314A, $033B, $7FFF ; palette 0
	dw $00A0, $00EF, $0141, $02CA ; palette 1
	dw $1800, $3CA2, $79C6, $7F34 ; palette 2
	dw $0C84, $2908, $3DCD, $5EB4 ; palette 3
	dw $0C84, $314A, $3DCD, $5EB4 ; palette 4
	dw $0028, $00EF, $2A39, $57BF ; palette 5

	level_bank_end

	ASSERT Level09_Tiles - Level09_CellMap == LEVEL09_WIDTH * LEVEL09_HEIGHT
	ASSERT Level09_AttrLookup - Level09_Tiles == LEVEL09_TILE_COUNT * 16 + 1
	ASSERT Level09_BGPalettes - Level09_AttrLookup == 160
