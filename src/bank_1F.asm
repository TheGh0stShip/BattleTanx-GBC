; BattleTanx (USA) - ROM bank $1F: level 11 cell map, tiles, attribute
; lookup table and BG palettes. Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $1F", ROMX[$4000], BANK[$1F]

; 120 x 64 bytes, row-major. ROM0 $1AA4 copies it to WRAM banks 2-3
; at $D000; ROM0 $1D93 tests bits 6-7 (all clear in ROM). Low bits: unknown.
Level11_CellMap:
	INCBIN "assets/levels/level_11/cellmap.bin"

; 2bpp tiles. ROM0 $1A33 always copies 440 tiles from here; only the first
; LEVEL11_TILE_COUNT belong to this block (the highest tile any map cell uses is
; LEVEL11_TILE_COUNT - 1).
Level11_Tiles:
	INCBIN "assets/levels/level_11/tiles.2bpp"

	db $00 ; never read: the lookup below is addressed as table - 1 + value

; 160 bytes, pointer and bank from $05:$513E. ROM0 $1D93 returns entry
; (value - 1) as the attribute byte for cells with bit 7 set.
Level11_AttrLookup:
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $03, $03, $03, $01, $01, $01, $01, $80, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $01, $01, $02, $02, $02, $02, $02, $02, $02, $02
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $03, $03, $03, $01, $01, $01, $01, $01, $01, $01, $01, $03, $03, $03
	db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00, $03, $03, $03, $03
	db $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $04

; RGB555 BG palettes 0-6, loaded by ROM0 $1A86.
Level11_BGPalettes:
	dw $0C84, $314A, $033B, $7FFF ; palette 0
	dw $00A0, $00EF, $0141, $02CA ; palette 1
	dw $1800, $3CA2, $79C6, $7F34 ; palette 2
	dw $0C84, $2908, $3DCD, $5EB4 ; palette 3
	dw $0028, $00EF, $2A39, $57BF ; palette 4
	dw $0028, $00EF, $79C6, $7F34 ; palette 5
	dw $0C84, $314A, $3DCD, $5EB4 ; palette 6

	level_bank_end

	ASSERT Level11_Tiles - Level11_CellMap == LEVEL11_WIDTH * LEVEL11_HEIGHT
	ASSERT Level11_AttrLookup - Level11_Tiles == LEVEL11_TILE_COUNT * 16 + 1
	ASSERT Level11_BGPalettes - Level11_AttrLookup == 160
