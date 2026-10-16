; BattleTanx (USA) - ROM bank $0B: level 1 cell map, tiles, attribute
; lookup table and BG palettes. Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $0B", ROMX[$4000], BANK[$0B]

; 88 x 88 bytes, row-major. ROM0 $1AA4 copies it to WRAM banks 2-3
; at $D000; ROM0 $1D93 tests bits 6-7 (all clear in ROM). Low bits: unknown.
Level01_CellMap:
	INCBIN "assets/levels/level_01/cellmap.bin"

; 2bpp tiles. ROM0 $1A33 always copies 440 tiles from here; only the first
; LEVEL01_TILE_COUNT belong to this block (the highest tile any map cell uses is
; LEVEL01_TILE_COUNT - 1).
Level01_Tiles:
	INCBIN "assets/levels/level_01/tiles.2bpp"

	db $00 ; never read: the lookup below is addressed as table - 1 + value

; 160 bytes, pointer and bank from $05:$513E. ROM0 $1D93 returns entry
; (value - 1) as the attribute byte for cells with bit 7 set.
Level01_AttrLookup:
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $03, $03, $03, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $01, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $01, $02, $02, $01, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $80, $80, $80, $80, $80, $80, $80, $80, $80
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $03, $03, $03, $01, $01, $01, $01, $01, $03, $03, $03, $03, $03, $03
	db $03, $03, $03, $03, $03, $03, $03, $03, $00, $03, $03, $03, $03, $03, $80, $80
	db $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $04

; RGB555 BG palettes 0-6, loaded by ROM0 $1A86.
Level01_BGPalettes:
	dw $0C84, $314A, $2F7F, $62F7 ; palette 0
	dw $00A8, $00EF, $1A39, $4F9F ; palette 1
	dw $2400, $5127, $7A8C, $7FD7 ; palette 2
	dw $0C84, $314A, $5694, $62F7 ; palette 3
	dw $0C84, $2508, $39AE, $5694 ; palette 4
	dw $2400, $386E, $6DFA, $7F5D ; palette 5
	dw $0080, $0141, $128E, $37DA ; palette 6

	level_bank_end

	ASSERT Level01_Tiles - Level01_CellMap == LEVEL01_WIDTH * LEVEL01_HEIGHT
	ASSERT Level01_AttrLookup - Level01_Tiles == LEVEL01_TILE_COUNT * 16 + 1
	ASSERT Level01_BGPalettes - Level01_AttrLookup == 160
