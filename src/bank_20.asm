; BattleTanx (USA) - ROM bank $20: level 11 tile map and attribute map.
; Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $20", ROMX[$4000], BANK[$20]

; 120 x 64 BG tile ids, row-major (read by ROM0 $1D93 via $C8C7).
Level11_TileMap:
	INCBIN "assets/levels/level_11/tilemap.bin"

; 120 x 64 CGB BG attribute bytes (read by ROM0 $1D93 via $C8C5):
; bits 0-2 palette, 3 VRAM bank, 5 x flip, 6 y flip, 7 priority; bit 4 clear.
Level11_AttrMap:
	INCBIN "assets/levels/level_11/attrmap.bin"

	level_bank_end

	ASSERT Level11_AttrMap - Level11_TileMap == LEVEL11_WIDTH * LEVEL11_HEIGHT
