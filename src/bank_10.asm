; BattleTanx (USA) - ROM bank $10: level 3 tile map and attribute map.
; Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $10", ROMX[$4000], BANK[$10]

; 168 x 48 BG tile ids, row-major (read by ROM0 $1D93 via $C8C7).
Level03_TileMap:
	INCBIN "assets/levels/level_03/tilemap.bin"

; 168 x 48 CGB BG attribute bytes (read by ROM0 $1D93 via $C8C5):
; bits 0-2 palette, 3 VRAM bank, 5 x flip, 6 y flip, 7 priority; bit 4 clear.
Level03_AttrMap:
	INCBIN "assets/levels/level_03/attrmap.bin"

	level_bank_end

	ASSERT Level03_AttrMap - Level03_TileMap == LEVEL03_WIDTH * LEVEL03_HEIGHT
