; BattleTanx (USA) - ROM bank $14: level 5 tile map and attribute map.
; Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $14", ROMX[$4000], BANK[$14]

; 72 x 104 BG tile ids, row-major (read by ROM0 $1D93 via $C8C7).
Level05_TileMap:
	INCBIN "assets/levels/level_05/tilemap.bin"

; 72 x 104 CGB BG attribute bytes (read by ROM0 $1D93 via $C8C5):
; bits 0-2 palette, 3 VRAM bank, 5 x flip, 6 y flip, 7 priority; bit 4 clear.
Level05_AttrMap:
	INCBIN "assets/levels/level_05/attrmap.bin"

	level_bank_end

	ASSERT Level05_AttrMap - Level05_TileMap == LEVEL05_WIDTH * LEVEL05_HEIGHT
