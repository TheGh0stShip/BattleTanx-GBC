; BattleTanx (USA) - ROM bank $0E: level 2 tile map and attribute map.
; Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $0E", ROMX[$4000], BANK[$0E]

; 72 x 104 BG tile ids, row-major (read by ROM0 $1D93 via $C8C7).
Level02_TileMap:
	INCBIN "assets/levels/level_02/tilemap.bin"

; 72 x 104 CGB BG attribute bytes (read by ROM0 $1D93 via $C8C5):
; bits 0-2 palette, 3 VRAM bank, 5 x flip, 6 y flip, 7 priority; bit 4 clear.
Level02_AttrMap:
	INCBIN "assets/levels/level_02/attrmap.bin"

	level_bank_end

	ASSERT Level02_AttrMap - Level02_TileMap == LEVEL02_WIDTH * LEVEL02_HEIGHT
