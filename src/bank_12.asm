; BattleTanx (USA) - ROM bank $12: level 4 tile map and attribute map.
; Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $12", ROMX[$4000], BANK[$12]

; 88 x 88 BG tile ids, row-major (read by ROM0 $1D93 via $C8C7).
Level04_TileMap:
	INCBIN "assets/levels/level_04/tilemap.bin"

; 88 x 88 CGB BG attribute bytes (read by ROM0 $1D93 via $C8C5):
; bits 0-2 palette, 3 VRAM bank, 5 x flip, 6 y flip, 7 priority; bit 4 clear.
Level04_AttrMap:
	INCBIN "assets/levels/level_04/attrmap.bin"

	level_bank_end

	ASSERT Level04_AttrMap - Level04_TileMap == LEVEL04_WIDTH * LEVEL04_HEIGHT
