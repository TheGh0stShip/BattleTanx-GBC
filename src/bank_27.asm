; BattleTanx (USA) - ROM bank $27

SECTION "ROM Bank $27", ROMX[$4000], BANK[$27]
Bank27OrientationTiles:
	INCBIN "assets/bank_27/orientation_tiles.bin"
Bank27Unknown4510:
	dw $318C
Bank27ObjectPalette:
	dw $0040, $0260, $03E5
	INCBIN "assets/bank_27/sprite_data_4518.bin"
	ds $33FF, 0
	db $27 ; bank marker at $7FFF
