; BattleTanx (USA) - ROM bank $26: level 14 tile map and attribute map.
; Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $26", ROMX[$4000], BANK[$26]

; 64 x 120 BG tile ids, row-major (read by ROM0 $1D93 via $C8C7).
Level14_TileMap:
	INCBIN "assets/levels/level_14/tilemap.bin"

; 64 x 120 CGB BG attribute bytes (read by ROM0 $1D93 via $C8C5):
; bits 0-2 palette, 3 VRAM bank, 5 x flip, 6 y flip, 7 priority; bit 4 clear.
Level14_AttrMap:
	INCBIN "assets/levels/level_14/attrmap.bin"

	level_bank_end

	ASSERT Level14_AttrMap - Level14_TileMap == LEVEL14_WIDTH * LEVEL14_HEIGHT
