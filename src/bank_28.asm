; BattleTanx (USA) - ROM bank $28

SECTION "ROM Bank $28", ROMX[$4000], BANK[$28]
Bank28OrientationTiles:
	INCBIN "assets/bank_28/orientation_tiles.bin"
Bank28Unknown4510:
	dw $6739
Bank28ObjectPalette:
	dw $7E51, $0000, $60E8
	INCBIN "assets/bank_28/sprite_data_4518.bin"
	ds $33FF, 0
	db $28 ; bank marker at $7FFF
