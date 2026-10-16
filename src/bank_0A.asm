; BattleTanx (USA) - ROM bank $0A: level 0 tile map and attribute map.
; Layout and evidence: DATA_BANKS_09_26.md.

SECTION "ROM Bank $0A", ROMX[$4000], BANK[$0A]

; 64 x 64 BG tile ids, row-major (read by ROM0 $1D93 via $C8C7).
Level00_TileMap:
	INCBIN "assets/levels/level_00/tilemap.bin"

; 64 x 64 CGB BG attribute bytes (read by ROM0 $1D93 via $C8C5):
; bits 0-2 palette, 3 VRAM bank, 5 x flip, 6 y flip, 7 priority; bit 4 clear.
Level00_AttrMap:
	INCBIN "assets/levels/level_00/attrmap.bin"

	level_bank_end

	ASSERT Level00_AttrMap - Level00_TileMap == LEVEL00_WIDTH * LEVEL00_HEIGHT
