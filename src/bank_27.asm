; BattleTanx (USA) - ROM bank $27

SECTION "ROM Bank $27", ROMX[$4000], BANK[$27]
Bank27SpriteTiles:
	INCBIN "assets/bank_27/sprite_tiles.bin" ; 192 2bpp tiles
	ds $33FF, 0
	db $27 ; bank marker at $7FFF
