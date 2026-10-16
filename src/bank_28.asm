; BattleTanx (USA) - ROM bank $28

SECTION "ROM Bank $28", ROMX[$4000], BANK[$28]
Bank28SpriteData:
	INCBIN "assets/bank_28/sprite_data_4000.bin"
Bank28ObjectPalette:
	dw $7E51, $0000, $60E8
	INCBIN "assets/bank_28/sprite_data_4518.bin"
	ds $33FF, 0
	db $28 ; bank marker at $7FFF
