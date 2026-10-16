; BattleTanx (USA) - ROM bank $08

SECTION "ROM Bank $08", ROMX[$4000], BANK[$08]
Bank08UiFontTiles:
	INCBIN "assets/bank_08/ui_font_tiles.bin" ; 74 native 2bpp tiles

Bank08UiFontPalette:
	LOAD UNION "RAM data $C721", WRAM0[$C721] ; copied from $08:44A0
wUiFontPalette:
	dw $0C84, $314A, $4E51, $6738
	ENDL
	INCBIN "assets/bank_08/unknown_44A8.bin"

Bank08ObjectPalette4512:
	dw $0000, $0000, $0000

	INCBIN "assets/bank_08/unknown_4518.bin"

Bank08ObjectPalette46EA:
	dw $001C, $025C, $03FF

	INCBIN "assets/bank_08/unknown_46F0.bin"

Bank08InterfaceTiles60F8:
	INCBIN "assets/bank_08/interface_tiles_60F8.bin" ; 1 native 2bpp tile
	INCBIN "assets/bank_08/unknown_6108.bin"

Bank08InterfaceTiles611A:
	INCBIN "assets/bank_08/interface_tiles_611A.bin" ; 16 native 2bpp tiles
	INCBIN "assets/bank_08/unknown_621A.bin"

Bank08InterfaceTiles6222:
	INCBIN "assets/bank_08/interface_tiles_6222.bin" ; 2 native 2bpp tiles
	INCBIN "assets/bank_08/unknown_6242.bin"

Bank08InterfaceTiles626B:
	INCBIN "assets/bank_08/interface_tiles_626B.bin" ; 78 native 2bpp tiles

Bank08HudIconPalette:
	LOAD UNION "RAM data $C6F9", WRAM0[$C6F9] ; copied from $08:674B
wHudIconPalette:
	dw $0000, $10A3, $3200, $42E0
	ENDL
Bank08HudIconTiles:
	INCBIN "assets/bank_08/hud_icon_tiles.bin" ; 10 native 2bpp tiles

ObjectSpritePaletteIndexTable:
	db 0, 1, 0, 2, 3, 1, 2, 0, 3, 0

; Four object palettes. The loader supplies color zero, then reads these three
; 15-bit colors into the remaining slots of each palette.
Bank08ObjectPalettes67FD:
	dw $0000, $7002, $03FE
	dw $0C12, $001F, $7FFF
	dw $1515, $15DE, $1FFF
	dw $0000, $5818, $7E9F

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

SelectObjectSpritePalette:
	push bc
	push hl
	ld a, l
	and $C0
	add a, $1E
	ld l, a
	ld a, [hl]
	add a, LOW(ObjectSpritePaletteIndexTable)
	ld l, a
	ld a, $00
	adc a, HIGH(ObjectSpritePaletteIndexTable)
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
