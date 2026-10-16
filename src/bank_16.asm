; BattleTanx (USA) - ROM bank $16: level 6 tile map and attribute map.
; Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $16", ROMX[$4000], BANK[$16]

; 88 x 80 BG tile ids, row-major (read by ROM0 $1D93 via $C8C7).
Level06_TileMap:
	INCBIN "assets/levels/level_06/tilemap.bin"

; 88 x 80 CGB BG attribute bytes (read by ROM0 $1D93 via $C8C5):
; bits 0-2 palette, 3 VRAM bank, 5 x flip, 6 y flip, 7 priority; bit 4 clear.
Level06_AttrMap:
	INCBIN "assets/levels/level_06/attrmap.bin"

	level_bank_end

	ASSERT Level06_AttrMap - Level06_TileMap == LEVEL06_WIDTH * LEVEL06_HEIGHT
