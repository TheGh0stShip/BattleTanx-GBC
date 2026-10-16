; BattleTanx (USA) - ROM bank $28

SECTION "ROM Bank $28", ROMX[$4000], BANK[$28]
Bank28SpriteTiles:
	INCBIN "assets/bank_28/sprite_tiles.bin" ; 192 2bpp tiles
	ds $33FF, 0
	db $28 ; bank marker at $7FFF
