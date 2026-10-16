; BattleTanx (USA) - ROM bank $1A: level 8 tile map and attribute map.
; Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $1A", ROMX[$4000], BANK[$1A]

; 112 x 72 BG tile ids, row-major (read by ROM0 $1D93 via $C8C7).
Level08_TileMap:
	INCBIN "assets/levels/level_08/tilemap.bin"

; 112 x 72 CGB BG attribute bytes (read by ROM0 $1D93 via $C8C5):
; bits 0-2 palette, 3 VRAM bank, 5 x flip, 6 y flip, 7 priority; bit 4 clear.
Level08_AttrMap:
	INCBIN "assets/levels/level_08/attrmap.bin"

	level_bank_end

	ASSERT Level08_AttrMap - Level08_TileMap == LEVEL08_WIDTH * LEVEL08_HEIGHT
