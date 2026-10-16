; BattleTanx (USA) - ROM bank $18: level 7 tile map and attribute map.
; Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $18", ROMX[$4000], BANK[$18]

; 72 x 112 BG tile ids, row-major (read by ROM0 $1D93 via $C8C7).
Level07_TileMap:
	INCBIN "assets/levels/level_07/tilemap.bin"

; 72 x 112 CGB BG attribute bytes (read by ROM0 $1D93 via $C8C5):
; bits 0-2 palette, 3 VRAM bank, 5 x flip, 6 y flip, 7 priority; bit 4 clear.
Level07_AttrMap:
	INCBIN "assets/levels/level_07/attrmap.bin"

	level_bank_end

	ASSERT Level07_AttrMap - Level07_TileMap == LEVEL07_WIDTH * LEVEL07_HEIGHT
