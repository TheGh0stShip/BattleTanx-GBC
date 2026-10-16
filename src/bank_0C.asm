; BattleTanx (USA) - ROM bank $0C: level 1 tile map and attribute map.
; Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $0C", ROMX[$4000], BANK[$0C]

; 88 x 88 BG tile ids, row-major (read by ROM0 $1D93 via $C8C7).
Level01_TileMap:
	INCBIN "assets/levels/level_01/tilemap.bin"

; 88 x 88 CGB BG attribute bytes (read by ROM0 $1D93 via $C8C5):
; bits 0-2 palette, 3 VRAM bank, 5 x flip, 6 y flip, 7 priority; bit 4 clear.
Level01_AttrMap:
	INCBIN "assets/levels/level_01/attrmap.bin"

	level_bank_end

	ASSERT Level01_AttrMap - Level01_TileMap == LEVEL01_WIDTH * LEVEL01_HEIGHT
