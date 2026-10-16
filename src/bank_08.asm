; BattleTanx (USA) - ROM bank $08

SECTION "ROM Bank $08", ROMX[$4000], BANK[$08]
	INCBIN "assets/bank_08/4000.bin" ; $4A0 bytes

	LOAD UNION "RAM code $C721", WRAM0[$C721] ; copied from $08:44A0
	db $84, $0C, $4A, $31, $51, $4E, $38, $67
	ENDL
	INCBIN "assets/bank_08/44A8.bin" ; $22A3 bytes

	LOAD UNION "RAM code $C6F9", WRAM0[$C6F9] ; copied from $08:674B
	db $00, $00, $A3, $10, $00, $32, $E0, $42
	ENDL
	db $E7, $00, $BD, $42, $81, $7E, $BD, $42, $99, $66, $C3, $3C, $66, $18, $3C, $00
	db $FF, $FF, $E7, $FF, $E7, $FF, $81, $FF, $81, $FF, $E7, $FF, $E7, $FF, $FF, $FF
	db $1E, $1E, $FE, $F2, $FE, $02, $FF, $E3, $7F, $41, $FF, $AA, $FF, $80, $FF, $FF
	db $00, $3C, $3C, $7E, $7E, $FF, $7E, $FF, $7E, $FF, $BD, $7E, $42, $3C, $3C, $00
	db $00, $78, $30, $4F, $3F, $40, $38, $C7, $7C, $82, $AA, $55, $FE, $01, $00, $FF
	db $00, $08, $00, $1C, $1C, $08, $00, $1C, $1C, $08, $1C, $08, $14, $2A, $14, $6B
	db $1C, $00, $1C, $08, $1F, $0A, $FF, $0A, $FF, $7A, $FF, $02, $3F, $3E, $3F, $00
	db $FF, $3C, $FF, $7E, $FF, $3C, $FF, $18, $FF, $00, $FF, $E7, $FF, $C3, $FF, $81
	db $00, $00, $00, $10, $10, $54, $00, $92, $82, $D6, $00, $7C, $54, $7C, $00, $7C
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $01, $00, $02, $03, $01, $02, $00, $03, $00, $00, $00, $02, $70, $FE, $03
	db $12, $0C, $1F, $00, $FF, $7F, $15, $15, $DE, $15, $FF, $1F, $00, $00, $18, $58
	db $9F, $7E, $01, $01, $02, $03, $05, $06, $0B, $0C, $17, $18, $2F, $30, $5F, $60
	db $BF, $C0, $80, $80, $40, $C0, $A0, $60, $D0, $30, $E8, $18, $F4, $0C, $FA, $06
	db $FD, $03, $FF, $80, $FF, $F8, $0F, $08, $0F, $08, $0F, $08, $0F, $08, $0F, $08
	db $0F, $0F, $FF, $01, $FF, $1F, $F0, $10, $F0, $10, $F0, $10, $F0, $10, $F0, $10
	db $F0, $F0, $00, $00, $7F, $7F, $5F, $60, $2F, $30, $17, $18, $0B, $0C, $17, $18
	db $2F, $30, $00, $00, $FE, $FE, $FE, $02, $FE, $02, $FE, $02, $FE, $02, $FE, $02
	db $FE, $02, $5F, $60, $BF, $C0, $FF, $C0, $7F, $60, $3F, $30, $1E, $19, $0D, $0F
	db $06, $06, $FE, $02, $FE, $02, $DE, $22, $AE, $72, $56, $DA, $8A, $8E, $06, $06
	db $00, $00, $03, $03, $03, $02, $03, $02, $03, $02, $FF, $FE, $FF, $80, $FF, $80
	db $FF, $80, $80, $80, $40, $C0, $A0, $60, $D0, $30, $E8, $18, $F4, $0C, $FA, $06
	db $FD, $03, $FF, $80, $FF, $80, $FF, $80, $FF, $FE, $03, $02, $03, $02, $03, $02
	db $03, $03, $FD, $03, $FA, $06, $F4, $0C, $E8, $18, $D0, $30, $A0, $60, $40, $C0
	db $80, $80, $00, $00, $1F, $00, $5F, $46, $FF, $7F, $FC, $03, $FC, $03, $FC, $03
	db $FC, $03, $FC, $03, $FC, $03, $00, $FF, $00, $FF, $0F, $F0, $0F, $F0, $CF, $F0
	db $CF, $F0, $CF, $F0, $CC, $FF, $CC, $FF, $CC, $FF, $3F, $FF, $3F, $FF, $00, $FF
	db $00, $FF, $FF, $0F, $FF, $0F, $F0, $0F, $F0, $0F, $CC, $FF, $CC, $FF, $0C, $FF
	db $0C, $FF, $FC, $FF, $FC, $FF, $00, $FF, $00, $FF

	LOAD UNION "RAM code $C701", WRAM0[$C701] ; copied from $08:691D
	db $00, $00, $A3, $10, $15, $15, $FF, $1F
	ENDL
	db $00, $FF, $01, $FE, $03, $FC, $07, $F8, $07, $F8, $07, $FF, $07, $FF, $07, $FF
	db $00, $FF, $80, $7F, $C0, $3F, $E0, $1F, $E0, $1F, $E0, $FF, $E0, $FF, $E0, $FF
	db $07, $FF, $07, $FF, $07, $FF, $07, $FE, $0F, $F6, $1F, $E6, $3F, $C6, $7F, $86
	db $E0, $FF, $E0, $FF, $E0, $FF, $E0, $7F, $F0, $6F, $F8, $67, $FC, $63, $FE, $61

	LOAD UNION "RAM code $C709", WRAM0[$C709] ; copied from $08:6965
	db $00, $00, $1F, $00, $A3, $10, $FF, $7F
	ENDL
	db $07, $FF, $07, $FF, $1F, $FF, $0F, $FF, $07, $FF, $07, $FF, $03, $FF, $01, $FF
	db $C0, $FF, $C0, $FF, $F0, $FF, $E0, $FF, $C0, $FF, $C0, $FF, $80, $FF, $00, $FF
	db $00, $FF, $FE, $FF, $FE, $FF, $FC, $FF, $FC, $FF, $78, $FF, $78, $FF, $30, $FF
	db $00, $FF, $7F, $FF, $7F, $FF, $3F, $FF, $3F, $FF, $1E, $FF, $1E, $FF, $0C, $FF

	LOAD UNION "RAM code $C711", WRAM0[$C711] ; copied from $08:69AD
	db $00, $00, $00, $00, $00, $00, $FE, $03
	ENDL
	INCBIN "assets/bank_08/69B5.bin" ; $420 bytes

Func_08_6DD5:
	push bc
	push hl
	ld a, l
	and $C0
	add a, $1E
	ld l, a
	ld a, [hl]
	add a, $F3
	ld l, a
	ld a, $00
	adc a, $67
	ld h, a
	ld a, [hl]
	and $03
	add a, $04
	ldh [$FF80], a
	pop hl
	pop bc
	ret

	INCBIN "assets/bank_08/6DF0.bin" ; $1210 bytes
