; BattleTanx (USA) - ROM bank $1C: level 9 tile map and attribute map.
; Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $1C", ROMX[$4000], BANK[$1C]

; 64 x 120 BG tile ids, row-major (read by ROM0 $1D93 via $C8C7).
Level09_TileMap:
	INCBIN "assets/levels/level_09/tilemap.bin"

; 64 x 120 CGB BG attribute bytes (read by ROM0 $1D93 via $C8C5):
; bits 0-2 palette, 3 VRAM bank, 5 x flip, 6 y flip, 7 priority; bit 4 clear.
Level09_AttrMap:
	INCBIN "assets/levels/level_09/attrmap.bin"

	level_bank_end

	ASSERT Level09_AttrMap - Level09_TileMap == LEVEL09_WIDTH * LEVEL09_HEIGHT
