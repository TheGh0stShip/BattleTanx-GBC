; BattleTanx (USA) - ROM bank $29

SECTION "ROM Bank $29", ROMX[$4000], BANK[$29]
Bank29SpriteData:
	INCBIN "assets/bank_29/sprite_data_4000.bin"
Bank29ObjectPalette:
	dw $0006, $1CFF, $52BF
	INCBIN "assets/bank_29/sprite_data_4518.bin"
	ds $33FF, 0
	db $29 ; bank marker at $7FFF
