; BattleTanx (USA) - ROM bank $29

SECTION "ROM Bank $29", ROMX[$4000], BANK[$29]
Bank29SpriteTiles:
	INCBIN "assets/bank_29/sprite_tiles.bin" ; 192 2bpp tiles
	ds $33FF, 0
	db $29 ; bank marker at $7FFF
