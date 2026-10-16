; BattleTanx (USA) - ROM bank $24: level 13 tile map and attribute map.
; Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $24", ROMX[$4000], BANK[$24]

; 88 x 88 BG tile ids, row-major (read by ROM0 $1D93 via $C8C7).
Level13_TileMap:
	INCBIN "assets/levels/level_13/tilemap.bin"

; 88 x 88 CGB BG attribute bytes (read by ROM0 $1D93 via $C8C5):
; bits 0-2 palette, 3 VRAM bank, 5 x flip, 6 y flip, 7 priority; bit 4 clear.
Level13_AttrMap:
	INCBIN "assets/levels/level_13/attrmap.bin"

	level_bank_end

	ASSERT Level13_AttrMap - Level13_TileMap == LEVEL13_WIDTH * LEVEL13_HEIGHT
