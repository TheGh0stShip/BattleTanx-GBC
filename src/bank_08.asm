; BattleTanx (USA) - ROM bank $08

SECTION "ROM Bank $08", ROMX[$4000], BANK[$08]
Bank08UiFontTiles:
	INCBIN "assets/bank_08/ui_font_tiles.bin" ; 74 native 2bpp tiles

Bank08UiFontPalette:
	LOAD UNION "RAM data $C721", WRAM0[$C721] ; copied from $08:44A0
wUiFontPalette:
	dw $0C84, $314A, $4E51, $6738
	ENDL
	INCBIN "assets/bank_08/44A8.bin" ; $22A3 bytes

Bank08HudIconPalette:
	LOAD UNION "RAM data $C6F9", WRAM0[$C6F9] ; copied from $08:674B
wHudIconPalette:
	dw $0000, $10A3, $3200, $42E0
	ENDL
Bank08HudIconTiles:
	INCBIN "assets/bank_08/hud_icon_tiles.bin" ; 10 native 2bpp tiles

Bank08PaletteIndexTable:
	db 0, 1, 0, 2, 3, 1, 2, 0, 3, 0

Bank08SpriteLayout67FD:
	db $00, $00, $02, $70, $FE, $03, $12, $0C
	db $1F, $00, $FF, $7F, $15, $15, $DE, $15

Bank08InterfacePalette680D:
	dw $1FFF, $0000, $5818, $7E9F

Bank08InterfaceTiles6815:
	INCBIN "assets/bank_08/interface_tiles_6815.bin" ; 12 native 2bpp tiles

Bank08InterfacePalette68D5:
	dw $0000, $001F, $465F, $7FFF

Bank08InterfaceTiles68DD:
	INCBIN "assets/bank_08/interface_tiles_68DD.bin" ; 4 native 2bpp tiles

Bank08ArrowUpPalette:
	LOAD UNION "RAM data $C701", WRAM0[$C701] ; copied from $08:691D
wArrowUpPalette:
	dw $0000, $10A3, $1515, $1FFF
	ENDL
Bank08ArrowUpTiles:
	INCBIN "assets/bank_08/arrow_up_tiles.bin" ; 4 native 2bpp tiles

Bank08ArrowDownPalette:
	LOAD UNION "RAM data $C709", WRAM0[$C709] ; copied from $08:6965
wArrowDownPalette:
	dw $0000, $001F, $10A3, $7FFF
	ENDL
Bank08ArrowDownTiles:
	INCBIN "assets/bank_08/arrow_down_tiles.bin" ; 4 native 2bpp tiles

Bank08AlphanumericFontPalette:
	LOAD UNION "RAM data $C711", WRAM0[$C711] ; copied from $08:69AD
wAlphanumericFontPalette:
	dw $0000, $0000, $0000, $03FE
	ENDL
Bank08AlphanumericFontTiles:
	INCBIN "assets/bank_08/alphanumeric_font_tiles.bin" ; 66 native 2bpp tiles

Func_08_6DD5:
	push bc
	push hl
	ld a, l
	and $C0
	add a, $1E
	ld l, a
	ld a, [hl]
	add a, LOW(Bank08PaletteIndexTable)
	ld l, a
	ld a, $00
	adc a, HIGH(Bank08PaletteIndexTable)
	ld h, a
	ld a, [hl]
	and $03
	add a, $04
	ldh [$FF80], a
	pop hl
	pop bc
	ret

	ds $120F, 0
	db $08 ; ROM bank marker
