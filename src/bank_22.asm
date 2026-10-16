; BattleTanx (USA) - ROM bank $22: level 12 tile map and attribute map.
; Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $22", ROMX[$4000], BANK[$22]

; 120 x 64 BG tile ids, row-major (read by ROM0 $1D93 via $C8C7).
Level12_TileMap:
	INCBIN "assets/levels/level_12/tilemap.bin"

; 120 x 64 CGB BG attribute bytes (read by ROM0 $1D93 via $C8C5):
; bits 0-2 palette, 3 VRAM bank, 5 x flip, 6 y flip, 7 priority; bit 4 clear.
Level12_AttrMap:
	INCBIN "assets/levels/level_12/attrmap.bin"

	level_bank_end

	ASSERT Level12_AttrMap - Level12_TileMap == LEVEL12_WIDTH * LEVEL12_HEIGHT
