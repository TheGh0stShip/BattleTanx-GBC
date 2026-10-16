; BattleTanx (USA) - ROM bank $1E: level 10 tile map and attribute map.
; Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $1E", ROMX[$4000], BANK[$1E]

; 88 x 88 BG tile ids, row-major (read by ROM0 $1D93 via $C8C7).
Level10_TileMap:
	INCBIN "assets/levels/level_10/tilemap.bin"

; 88 x 88 CGB BG attribute bytes (read by ROM0 $1D93 via $C8C5):
; bits 0-2 palette, 3 VRAM bank, 5 x flip, 6 y flip, 7 priority; bit 4 clear.
Level10_AttrMap:
	INCBIN "assets/levels/level_10/attrmap.bin"

	level_bank_end

	ASSERT Level10_AttrMap - Level10_TileMap == LEVEL10_WIDTH * LEVEL10_HEIGHT
