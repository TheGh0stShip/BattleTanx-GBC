; BattleTanx (USA) - ROM bank $02

SECTION "ROM Bank $02", ROMX[$4000], BANK[$02]
	db $CD, $28, $20, $CD, $58, $20, $CD, $ED, $22, $CD, $FE, $20, $AF, $EA, $C0, $C6
	db $76, $00, $00, $FA, $C0, $C6, $B7, $28, $F7, $AF, $EA, $C0, $C6, $F0, $44, $FE
	db $90, $38, $FA, $FE, $97, $30, $F6, $3E, $01, $E0, $4F, $3E, $C1, $E0, $51, $3E
	db $00, $E0, $52, $3E, $80, $E0, $53, $AF, $E0, $54, $3E, $27, $E0, $55, $CD, $F0
	db $FF, $3E, $01, $E0, $4F, $3E, $C4, $E0, $51, $3E, $00, $E0, $52, $3E, $9C, $E0
	db $53, $AF, $E0, $54, $3E, $04, $E0, $55, $AF, $E0, $4F, $3E, $C4, $E0, $51, $3E
	db $40, $E0, $52, $3E, $9C, $E0, $53, $AF, $E0, $54, $3E, $04, $E0, $55, $C9

Func_02_406F:
	ld a, [$C8D9]
	inc a
	ret z
Jump_02_4074:
	xor a
	ld [$C8DA], a
	ld [$C8D6], a
	ld [$C8D7], a
	ld a, $FF
	ld [$C8D8], a
	ld [$C8D9], a
	ld a, [$CA06]
	ld hl, $40DD
	ld c, a
	ld b, $00
	add hl, bc
	ld a, [hl]
	cp $00
	jr nz, Jump_02_409D
	ld de, $4D6A
	ld hl, $CFDD
	jr Jump_02_40C7

Jump_02_409D:
	cp $01
	jr nz, Jump_02_40A9
	ld de, $4E0E
	ld hl, $CD65
	jr Jump_02_40C7

Jump_02_40A9:
	cp $03
	jr nz, Jump_02_40B5
	ld de, $4E84
	ld hl, $CD6F
	jr Jump_02_40C7

Jump_02_40B5:
	cp $02
	jr nz, Jump_02_40C1
	ld de, $4E9F
	ld hl, $CFDD
	jr Jump_02_40C7

Jump_02_40C1:
	ld de, $4D6A
	ld hl, $CFDD
Jump_02_40C7:
	ld a, l
	ld [$C8D4], a
	ld a, h
	ld [$C8D5], a
	ld hl, $C8DB
	ld a, $C3
	ld [hli], a
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	ld a, $C9
	ld [hli], a
	ret

	db $00, $01, $00, $01, $01, $03, $01, $02, $01, $01, $00, $01, $00, $02, $00

	LOAD UNION "RAM code $C729", WRAM0[$C729] ; copied from $02:40EC

RAM_C729_02_40EC:
	push af
	push bc
	push de
	push hl
	ld hl, $C6F1
	ld de, $FF69
	ld a, $B0
	ldh [rBCPS], a
RAM_C737:
	ldh a, [rSTAT]
	and $03
	jr nz, RAM_C737
	REPT 16
	ld a, [hli]
	ld [de], a
	ENDR
	ldh a, [rLCDC]
	or $10
	ldh [rLCDC], a
	ldh a, [rLY]
	call Audio_Update
	ldh a, [rLY]
	ldh a, [rLY]
	cp $8F
	jr c, RAM_C770
RAM_C770:
	pop hl
	pop de
	pop bc
	pop af
	reti
	ENDL

	LOAD UNION "RAM code $C7F1", WRAM0[$C7F1] ; copied from $02:4138

RAM_C7F1_02_4138:
	push af
	push bc
	push de
	push hl
	ld hl, $C719
	ld de, $FF69
	ld a, $B0
	ldh [rBCPS], a
	ld a, [hli]
	ld [de], a
	ld a, [hli]
	ld [de], a
	ld a, [hli]
	ld [de], a
	ld a, [hli]
	ld [de], a
	ld a, [hli]
	ld [de], a
	ld a, [hli]
	ld [de], a
	ld a, [hli]
	ld [de], a
	ld a, [hli]
	ld [de], a
	ld a, [hli]
	ld [de], a
	ld a, [hli]
	ld [de], a
	ld a, [hli]
	ld [de], a
	ld a, [hli]
	ld [de], a
	ld a, [hli]
	ld [de], a
	ld a, [hli]
	ld [de], a
	ld a, [hli]
	ld [de], a
	ld a, [hli]
	ld [de], a
	ldh a, [rLCDC]
	res 4, a
	ldh [rLCDC], a
	ld a, [$C6B7]
	and $01
	jr z, RAM_C82F
	call Func_0A59
RAM_C82F:
	ld hl, $C6B7
	ld a, [hl]
	inc a
	ld [hli], a
	ld a, [hl]
	adc a, $00
	ld [hl], a
	ld a, $01
	ld [wVBlankPending], a
	pop hl
	pop de
	pop bc
	pop af
	reti

	ENDL

Func_02_418A:
	push af
	push bc
	push de
	push hl
	di
	ld hl, $40EC
	ld de, $004C
	ld bc, $C729
	call CopyBytes
	ld hl, $4138
	ld de, $0052
	ld bc, $C7F1
	call CopyBytes
	ldh a, [rWY]
	dec a
	ldh [rLYC], a
	ldh a, [rSTAT]
	set 6, a
	res 3, a
	ldh [rSTAT], a
	xor a
	ldh [rIF], a
	ld a, $03
	ldh [rIE], a
	ei
	nop
	pop hl
	pop de
	pop bc
	pop af
	ret


	LOAD UNION "RAM code $C729", WRAM0[$C729] ; copied from $02:41C2

RAM_C729:
	reti

	ENDL
	db $D9

	LOAD UNION "RAM code $C7F1", WRAM0[$C7F1] ; copied from $02:41C4

RAM_C7F1_02_41C4:
	push af
	push bc
	push de
	push hl
	ld a, [$C6B7]
	and $01
	jr z, RAM_C80B
	call Func_0A59
	ld a, [$C6B5]
	and $F0
	cp $F0
	jr nz, RAM_C80B
	jp Jump_00DA

RAM_C80B:
	ld a, [$C6B7]
	inc a
	ld [$C6B7], a
	ld a, [$C6B8]
	adc a, $00
	ld [$C6B8], a
	ld a, $01
	ld [wVBlankPending], a
	pop hl
	pop de
	pop bc
	pop af
	reti

	ENDL
	db $D0, $4A, $30, $20, $30, $48, $20, $40, $87, $FC, $FC, $00, $00, $F8, $F8, $00
	db $00, $F8, $00, $01, $00, $00, $F8, $02, $00, $00, $00, $03, $00, $F4, $F4, $00
	db $00, $F4, $FC, $01, $00, $F4, $04, $02, $00, $FC, $F4, $03, $00, $FC, $FC, $04
	db $00, $FC, $04, $05, $00, $04, $F4, $06, $00, $04, $FC, $07, $00, $04, $04, $08
	db $00

Func_02_4238:
	push af
	push bc
	push de
	push hl
	di
	ld hl, $41C2
	ld de, $0001
	ld bc, $C729
	call CopyBytes
	ld hl, $41C4
	ld de, $0033
	ld bc, $C7F1
	call CopyBytes
	xor a
	ldh [rIF], a
	ld a, $01
	ldh [rIE], a
	ei
	nop
	pop hl
	pop de
	pop bc
	pop af
	ret


SetLevelViewCellPositionBank2:
	push bc
	push de
	ld e, b
	ld d, $00
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	ld a, e
	ld [wLevelCameraX], a
	ld a, d
	ld [wLevelCameraX + 1], a
	ld e, c
	ld d, $00
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	ld a, e
	ld [wLevelCameraY], a
	ld a, d
	ld [wLevelCameraY + 1], a
	ld a, b
	ld [wLevelViewX], a
	ld a, c
	ld [wLevelViewY], a
	ld a, c
	call CacheLevelViewRowOffset
	pop de
	pop bc
	ret

	db $AC, $42, $EC, $42, $6C, $43, $2C, $43, $AC, $43, $04, $00, $F0, $FF, $0D, $00
	db $F1, $FF, $0F, $00, $F5, $FF, $11, $00, $FB, $FF, $11, $00, $02, $00, $0E, $00
	db $0A, $00, $0A, $00, $0E, $00, $04, $00, $10, $00, $FC, $FF, $10, $00, $F2, $FF
	db $0B, $00, $F0, $FF, $07, $00, $EF, $FF, $01, $00, $F0, $FF, $FB, $FF, $F2, $FF
	db $F5, $FF, $F7, $FF, $F2, $FF, $FC, $FF, $EF, $FF, $FC, $FF, $F0, $FF, $04, $00
	db $EF, $FF, $08, $00, $F2, $FF, $0D, $00, $F6, $FF, $10, $00, $FB, $FF, $12, $00
	db $02, $00, $0F, $00, $09, $00, $0D, $00, $0D, $00, $04, $00, $10, $00, $FC, $FF
	db $10, $00, $F7, $FF, $0D, $00, $F2, $FF, $09, $00, $F0, $FF, $04, $00, $EF, $FF
	db $FC, $FF, $F1, $FF, $F6, $FF, $F5, $FF, $F2, $FF, $00, $00, $EE, $FF, $09, $00
	db $F1, $FF, $0D, $00, $F4, $FF, $0F, $00, $F7, $FF, $10, $00, $FF, $FF, $10, $00
	db $07, $00, $0B, $00, $0A, $00, $09, $00, $0D, $00, $00, $00, $0F, $00, $F7, $FF
	db $0D, $00, $F5, $FF, $0A, $00, $F0, $FF, $07, $00, $F0, $FF, $FF, $FF, $F1, $FF
	db $F7, $FF, $F3, $FF, $F4, $FF, $F7, $FF, $F1, $FF, $00, $00, $EE, $FF, $09, $00
	db $F1, $FF, $0D, $00, $F4, $FF, $0F, $00, $F7, $FF, $10, $00, $FF, $FF, $10, $00
	db $07, $00, $0B, $00, $0A, $00, $09, $00, $0D, $00, $00, $00, $0F, $00, $F7, $FF
	db $0D, $00, $F5, $FF, $0A, $00, $F0, $FF, $07, $00, $F0, $FF, $FF, $FF, $F1, $FF
	db $F7, $FF, $F3, $FF, $F4, $FF, $F7, $FF, $F1, $FF, $00, $00, $EE, $FF, $09, $00
	db $F1, $FF, $0D, $00, $F4, $FF, $0F, $00, $F7, $FF, $10, $00, $FF, $FF, $10, $00
	db $07, $00, $0B, $00, $0A, $00, $09, $00, $0D, $00, $00, $00, $0F, $00, $F7, $FF
	db $0D, $00, $F5, $FF, $0A, $00, $F0, $FF, $07, $00, $F0, $FF, $FF, $FF, $F1, $FF
	db $F7, $FF, $F3, $FF, $F4, $FF, $F7, $FF, $F1, $FF

Func_02_43EC:
	push af
	push hl
	ld a, l
	and $C0
	add a, $1E
	ld l, a
	ld a, [hl]
	and a
	jr nz, Jump_02_4406
	ld a, l
	and $C0
	add a, $08
	ld l, a
	ld a, [hl]
	and $10
	ld a, $FF
	jr z, Jump_02_4406
	inc a
Jump_02_4406:
	add a, $01
	add a, a
	add a, $A2
	ld c, a
	ld a, $00
	add a, $42
	ld b, a
	ld a, [bc]
	ld e, a
	inc bc
	ld a, [bc]
	ld d, a
	ld a, l
	and $C0
	add a, $19
	ld l, a
	ld a, [hl]
	add a, a
	add a, a
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	ld a, l
	and $C0
	inc a
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	ld a, [de]
	inc de
	add a, c
	ld c, a
	ld a, [de]
	inc de
	adc a, b
	ld b, a
	push bc
	inc l
	inc l
	ld c, [hl]
	inc l
	ld b, [hl]
	ld a, [de]
	inc de
	add a, c
	ld c, a
	ld a, [de]
	adc a, b
	ld b, a
	ld e, c
	ld d, b
	pop bc
	pop hl
	pop af
	ret

	db $00, $01, $02, $03, $04, $05, $06, $07, $08, $F9, $FA, $FB, $FC, $FD, $FE, $FF
	db $FF, $00, $01, $02, $03, $04, $05, $06, $07, $08, $F9, $FA, $FB, $FC, $FD, $FE
	db $FE, $FF, $00, $01, $02, $03, $04, $05, $06, $07, $08, $F9, $FA, $FB, $FC, $FD
	db $FD, $FE, $FF, $00, $01, $02, $03, $04, $05, $06, $07, $08, $F9, $FA, $FB, $FC
	db $FC, $FD, $FE, $FF, $00, $01, $02, $03, $04, $05, $06, $07, $08, $F9, $FA, $FB
	db $FB, $FC, $FD, $FE, $FF, $00, $01, $02, $03, $04, $05, $06, $07, $08, $F9, $FA
	db $FA, $FB, $FC, $FD, $FE, $FF, $00, $01, $02, $03, $04, $05, $06, $07, $08, $F9
	db $F9, $FA, $FB, $FC, $FD, $FE, $FF, $00, $01, $02, $03, $04, $05, $06, $07, $08
	db $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF, $00, $01, $02, $03, $04, $05, $06, $07
	db $07, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF, $00, $01, $02, $03, $04, $05, $06
	db $06, $07, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF, $00, $01, $02, $03, $04, $05
	db $05, $06, $07, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF, $00, $01, $02, $03, $04
	db $04, $05, $06, $07, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF, $00, $01, $02, $03
	db $03, $04, $05, $06, $07, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF, $00, $01, $02
	db $02, $03, $04, $05, $06, $07, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF, $00, $01
	db $01, $02, $03, $04, $05, $06, $07, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF, $00

Func_02_4548:
	push af
	push hl
	ld hl, $4448
	ld a, b
	swap a
	and $F0
	or c
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	ld c, a
	bit 7, a
	jr z, Jump_02_4561
	cpl
	inc a
Jump_02_4561:
	ld b, a
	pop hl
	pop af
	ret

	db $A8, $44, $38, $45, $C8, $45, $58, $46, $58, $46, $C8, $45, $38, $45, $A8, $44
	db $F0, $46, $80, $47, $10, $48, $A0, $48, $30, $49, $C8, $49, $58, $4A, $E8, $4A
	db $78, $4B, $08, $4C, $98, $4C, $28, $4D, $B8, $4D, $48, $4E, $D8, $4E, $68, $4F
	db $00, $50, $40, $50, $80, $50, $C0, $50, $08, $51, $48, $51, $88, $51, $C8, $51
	db $10, $52, $50, $52, $90, $52, $D0, $52, $18, $53, $58, $53, $98, $53, $D8, $53
	db $20, $54, $30, $54, $40, $54, $58, $54, $68, $54, $78, $54

Func_02_45C1:
	push af
	push bc
	push de
	push hl
	call Func_2C24
	ld a, $03
	call Func_1FF5
	call Func_2125
	ld a, l
	and $C0
	add a, $1E
	ld l, a
	ld [hl], $03
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld [hl], $00
	ld de, $45BB
	ld bc, $5452
	ld a, l
	and $C0
	add a, $20
	ld l, a
	ld a, $0C
	ld [hl], a
	ld a, l
	and $C0
	add a, $21
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	ld a, l
	and $C0
	add a, $23
	ld l, a
	ld bc, $4200
	ld [hl], c
	inc l
	ld [hl], b
	ld a, l
	and $C0
	add a, $25
	ld l, a
	ld [hl], $01
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_02_4611:
	push af
	ld de, $45B5
	ld a, l
	and $C0
	add a, $20
	ld l, a
	ld a, $0C
	ld [hl], a
	ld a, l
	and $C0
	add a, $21
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	ld a, l
	and $C0
	add a, $23
	ld l, a
	ld bc, $4200
	ld [hl], c
	inc l
	ld [hl], b
	ld a, l
	and $C0
	add a, $25
	ld l, a
	ld [hl], $01
	pop af
	ret


Func_02_463D:
	push af
	call Func_0421
	and $03
	cp $02
	jr z, Jump_02_4659
	cp $01
	jr z, Jump_02_4652
	ld de, $4575
	ld a, $14
	jr Jump_02_4660

Jump_02_4652:
	ld de, $4565
	ld a, $20
	jr Jump_02_4660

Jump_02_4659:
	ld de, $457F
	ld a, $2C
	jr Jump_02_4660

Jump_02_4660:
	push af
	ld a, l
	and $C0
	add a, $20
	ld l, a
	pop af
	ld [hl], a
	ld a, l
	and $C0
	add a, $21
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	ld a, l
	and $C0
	add a, $23
	ld l, a
	ld bc, $4214
	ld [hl], c
	inc l
	ld [hl], b
	ld a, l
	and $C0
	add a, $25
	ld l, a
	ld [hl], $09
	pop af
	ret


Func_02_4688:
	push af
	call Func_0421
	and $03
	cp $03
	jr z, Jump_02_46B2
	cp $02
	jr z, Jump_02_46AA
	cp $01
	jr z, Jump_02_46A2
	ld de, $4595
	ld bc, $5102
	jr Jump_02_46BA

Jump_02_46A2:
	ld de, $459D
	ld bc, $520A
	jr Jump_02_46BA

Jump_02_46AA:
	ld de, $45A5
	ld bc, $5312
	jr Jump_02_46BA

Jump_02_46B2:
	ld de, $45AD
	ld bc, $541A
	jr Jump_02_46BA

Jump_02_46BA:
	ld a, l
	and $C0
	add a, $20
	ld l, a
	ld [hl], $10
	ld a, l
	and $C0
	add a, $21
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	ld a, l
	and $C0
	add a, $23
	ld l, a
	ld bc, $4204
	ld [hl], c
	inc l
	ld [hl], b
	ld a, l
	and $C0
	add a, $25
	ld l, a
	ld [hl], $04
	pop af
	ret


Func_02_46E1:
	push af
	push bc
	push de
	push hl
	ld d, $40
Jump_02_46E7:
	ldh a, [rSTAT]
	and $02
	jr z, Jump_02_46E7
Jump_02_46ED:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_02_46ED
	ld a, d
	ldh [rBCPS], a
	ld a, $00
	ldh [rBCPD], a
	dec d
	ld a, d
	ldh [rBCPS], a
	ld a, $00
	ldh [rBCPD], a
	dec d
	jr nz, Jump_02_46E7
	ld a, $00
	ldh [rBCPS], a
	ldh [rBCPD], a
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_02_4710:
	push af
	push bc
	push de
	push hl
	ld d, $00
Jump_02_4716:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_02_4716
	ld a, d
	ldh [rOCPS], a
	ldh a, [rOCPD]
	ld c, a
	inc d
	ld a, d
	ldh [rOCPS], a
	ldh a, [rOCPD]
	ld b, a
	dec d
	call Func_3856
Jump_02_472D:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_02_472D
	ld a, d
	ldh [rOCPS], a
	ld a, c
	ldh [rOCPD], a
	inc d
	ld a, d
	ldh [rOCPS], a
	ld a, b
	ldh [rOCPD], a
	inc d
	ld a, $40
	cp d
	jr nz, Jump_02_4716
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_02_474B:
	ld a, $02
	ldh [rSVBK], a
	ld a, $1F
	ldh [$FFC0], a
	ld a, $1E
	ldh [$FFC1], a
	ld a, $1F
	ldh [$FFC3], a
Jump_02_475B:
	ldh a, [$FFC1]
	call Func_3A40
	ld e, l
	ld d, h
	ldh a, [$FFC0]
	call Func_3A40
	ld a, $20
	ldh [$FFC2], a
Jump_02_476B:
	ld a, [wVBlankPending]
	or a
	jr z, Jump_02_4778
	call Audio_Update
	xor a
	ld [wVBlankPending], a
Jump_02_4778:
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [$C6D1]
	push de
	ld e, $01
	or a
	jr nz, Jump_02_478A
	call Func_3856
	jr Jump_02_478D

Jump_02_478A:
	call Func_3867
Jump_02_478D:
	pop de
	ld a, c
	ld [de], a
	inc de
	ld a, b
	ld [de], a
	inc de
	ldh a, [$FFC2]
	dec a
	ldh [$FFC2], a
	jr nz, Jump_02_476B
	ldh a, [$FFC0]
	dec a
	ldh [$FFC0], a
	dec a
	ldh [$FFC1], a
	ldh a, [$FFC3]
	dec a
	ldh [$FFC3], a
	jr nz, Jump_02_475B
	ld a, $01
	ldh [rSVBK], a
	ret


Func_02_47AF:
	ld a, [$CD04]
	ldh [$FFC2], a
	ld a, [$CD05]
	ldh [$FFC3], a
	ld a, [$CD06]
	ldh [$FFC4], a
	ld a, [$CD07]
	ldh [$FFC5], a
	xor a
	ldh [$FFC0], a
	ldh [$FFC1], a
Jump_02_47C8:
	ld de, $03E8
	ldh a, [$FFC5]
	or a
	jr nz, Jump_02_47E3
	ldh a, [$FFC4]
	or a
	jr nz, Jump_02_47E3
	ldh a, [$FFC3]
	cp d
	jr c, Jump_02_4809
	jr nz, Jump_02_47E3
	ldh a, [$FFC2]
	cp e
	jr nc, Jump_02_47E3
	jr Jump_02_4809

Jump_02_47E3:
	ldh a, [$FFC2]
	sub $E8
	ldh [$FFC2], a
	ldh a, [$FFC3]
	sbc a, $03
	ldh [$FFC3], a
	ldh a, [$FFC4]
	sbc a, $00
	ldh [$FFC4], a
	ldh a, [$FFC5]
	sbc a, $00
	ldh [$FFC5], a
	ldh a, [$FFC0]
	add a, $01
	ldh [$FFC0], a
	ldh a, [$FFC1]
	adc a, $00
	ldh [$FFC1], a
	jr Jump_02_47C8

Jump_02_4809:
	ldh a, [$FFC0]
	ld c, a
	ldh a, [$FFC1]
	ld b, a
	ret


Func_02_4810:
	ld hl, $C600
	xor a
	ld e, $A0
Jump_02_4816:
	ld [hli], a
	dec e
	jr nz, Jump_02_4816
	call $FFF0
	ret

	INCBIN "assets/bank_02/481E.bin" ; $53A bytes

Func_02_4D58:
	ld a, [$CA08]
	cp $02
	jp nc, Func_02_406F
	ld a, [$C0FF]
	and a
	jp nz, Func_02_406F
	jp $C8DB


Func_02_4D6A:
	ld a, [$C8DA]
	cp $40
	jp nc, Jump_02_4F7C
	ld a, [$C8D4]
	ld l, a
	ld a, [$C8D5]
	ld h, a
	ld bc, $0040
	add hl, bc
	ld a, h
	ld [$C8D5], a
	ld a, l
	ld [$C8D4], a
	ld a, [$C8DA]
	inc a
	ld [$C8DA], a
	ld a, [hl]
	cp $01
	ret nz
	ld bc, $0009
	add hl, bc
	ld a, [hl]
	and a
	ret z
	ld bc, $FFDB
	add hl, bc
	push hl
	ld a, [$CD00]
	ld l, a
	ld a, [$CD01]
	ld h, a
	ld a, l
	and $C0
	inc a
	ld l, a
	ld a, [hli]
	ld c, a
	ld b, [hl]
	inc l
	inc l
	ld a, [hli]
	ld e, a
	ld d, [hl]
	pop hl
	ld a, [hli]
	sub c
	ld c, a
	ld a, [hli]
	sbc a, b
	ld b, a
	inc l
	ld a, [hli]
	sub e
	ld e, a
	ld a, [hl]
	sbc a, d
	ld d, a
Jump_02_4DC0:
	bit 7, b
	jr z, Jump_02_4DCB
	ld a, b
	cpl
	ld b, a
	ld a, c
	cpl
	ld c, a
	inc bc
Jump_02_4DCB:
	bit 7, d
	jr z, Jump_02_4DD6
	ld a, d
	cpl
	ld d, a
	ld a, e
	cpl
	ld e, a
	inc de
Jump_02_4DD6:
	ld a, d
	cp b
	jr c, Jump_02_4DE6
	jr nz, Jump_02_4DE0
	ld a, e
	cp c
	jr c, Jump_02_4DE6
Jump_02_4DE0:
	sra b
	rr c
	jr Jump_02_4DEA

Jump_02_4DE6:
	sra d
	rr e
Jump_02_4DEA:
	ld l, e
	ld h, d
	add hl, bc
	ld a, [$C8D9]
	cp h
	ret c
	jr nz, Jump_02_4DF9
	ld a, [$C8D8]
	cp l
	ret c
Jump_02_4DF9:
	ld a, h
	ld [$C8D9], a
	ld a, l
	ld [$C8D8], a
	ld a, [$C8D4]
	ld [$C8D6], a
	ld a, [$C8D5]
	ld [$C8D7], a
	ret


Func_02_4E0E:
	ld a, [$C8DA]
	cp $08
	jp nc, Jump_02_4F43
	ld a, [$C8D4]
	ld l, a
	ld a, [$C8D5]
	ld h, a
	ld bc, $000A
	add hl, bc
	ld a, h
	ld [$C8D5], a
	ld a, l
	ld [$C8D4], a
	ld a, [$C8DA]
	inc a
	ld [$C8DA], a
	ld bc, $0006
	add hl, bc
	ld a, [hli]
	cp $03
	ret nz
	inc hl
	inc hl
	ld a, [hl]
	and a
	ret nz
	ld bc, $FFF7
	add hl, bc
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	srl a
	add a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	ld a, [hli]
	srl a
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	push de
	push bc
	ld a, [$CD00]
	ld l, a
	ld a, [$CD01]
	ld h, a
	ld a, l
	and $C0
	inc a
	ld l, a
	ld a, [hli]
	ld c, a
	ld b, [hl]
	inc l
	inc l
	ld a, [hli]
	ld e, a
	ld d, [hl]
	pop hl
	ld a, l
	sub c
	ld c, a
	ld a, h
	sbc a, b
	ld b, a
	pop hl
	ld a, l
	sub e
	ld e, a
	ld a, h
	sbc a, d
	ld d, a
	jp Jump_02_4DC0


Func_02_4E84:
	ld a, [$C8D7]
	and a
	jr nz, Jump_02_4F00
	ld hl, $CD79
	ld a, [$C91D]
	and a
	jr z, Jump_02_4E96
	ld hl, $CD6F
Jump_02_4E96:
	ld a, l
	ld [$C8D6], a
	ld a, h
	ld [$C8D7], a
	ret


Func_02_4E9F:
	ld a, [$C8DA]
	cp $40
	jp nc, Jump_02_4F7C
	ld a, [$C8D4]
	ld l, a
	ld a, [$C8D5]
	ld h, a
	ld bc, $0040
	add hl, bc
	ld a, h
	ld [$C8D5], a
	ld a, l
	ld [$C8D4], a
	ld a, [$C8DA]
	inc a
	ld [$C8DA], a
	ld a, [hl]
	cp $01
	ret nz
	ld bc, $0001
	add hl, bc
	ld a, [hl]
	cp $02
	ret nz
	ld bc, $0008
	add hl, bc
	ld a, [hl]
	and a
	ret z
	ld bc, $FFDB
	add hl, bc
	push hl
	ld a, [$CD00]
	ld l, a
	ld a, [$CD01]
	ld h, a
	ld a, l
	and $C0
	inc a
	ld l, a
	ld a, [hli]
	ld c, a
	ld b, [hl]
	inc l
	inc l
	ld a, [hli]
	ld e, a
	ld d, [hl]
	pop hl
	ld a, [hli]
	sub c
	ld c, a
	ld a, [hli]
	sbc a, b
	ld b, a
	inc l
	ld a, [hli]
	sub e
	ld e, a
	ld a, [hl]
	sbc a, d
	ld d, a
	jp Jump_02_4DC0

Jump_02_4F00:
	ld a, [wPlayerAlive]
	and a
	ret z
	ld a, [$CD00]
	ld l, a
	ld a, [$CD01]
	ld h, a
	ld a, l
	and $C0
	inc a
	ld l, a
	ld a, [hli]
	ld c, a
	ld b, [hl]
	inc l
	inc l
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [$C8D6]
	ld l, a
	ld a, [$C8D7]
	ld h, a
	ld a, [hli]
	sub c
	ld c, a
	ld a, [hli]
	sbc a, b
	ld b, a
	ld a, [hli]
	sub e
	ld e, a
	ld a, [hli]
	sbc a, d
	ld d, a
	ld a, [hli]
	srl a
	add a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	ld a, [hli]
	srl a
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	jr Jump_02_4FB8

Jump_02_4F43:
	ld a, [wPlayerAlive]
	and a
	ret z
	ld a, [$C8D7]
	and a
	jp z, Jump_02_4074
	ld a, [$CD00]
	ld l, a
	ld a, [$CD01]
	ld h, a
	ld a, l
	and $C0
	inc a
	ld l, a
	ld a, [hli]
	ld c, a
	ld b, [hl]
	inc l
	inc l
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [$C8D6]
	ld l, a
	ld a, [$C8D7]
	ld h, a
	ld a, [hli]
	sub c
	ld c, a
	ld a, [hli]
	sbc a, b
	ld b, a
	ld a, [hli]
	sub e
	ld e, a
	ld a, [hli]
	sbc a, d
	ld d, a
	jp Jump_02_4FB8

Jump_02_4F7C:
	ld a, [wPlayerAlive]
	and a
	ret z
	ld a, [$C8D7]
	and a
	ret z
	ld a, [$CD00]
	ld l, a
	ld a, [$CD01]
	ld h, a
	ld a, l
	and $C0
	inc a
	ld l, a
	ld a, [hli]
	ld c, a
	ld b, [hl]
	inc l
	inc l
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [$C8D6]
	and $C0
	ld l, a
	ld a, [$C8D7]
	ld h, a
	ld a, l
	and $C0
	inc a
	ld l, a
	ld a, [hli]
	sub c
	ld c, a
	ld a, [hli]
	sbc a, b
	ld b, a
	inc l
	ld a, [hli]
	sub e
	ld e, a
	ld a, [hl]
	sbc a, d
	ld d, a
Jump_02_4FB8:
	ld h, $10
	bit 7, d
	jr z, Jump_02_4FC7
	ld a, e
	cpl
	ld e, a
	ld a, d
	cpl
	ld d, a
	inc de
	res 4, h
Jump_02_4FC7:
	ld a, e
	and $E0
	ld e, a
	sla c
	rl b
	sla c
	rl b
	bit 7, b
	jr z, Jump_02_4FE0
	ld a, c
	cpl
	ld c, a
	ld a, b
	cpl
	ld b, a
	inc bc
	set 5, h
Jump_02_4FE0:
	ld a, b
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	ld b, h
	ld hl, $5440
	add hl, de
	ld a, [hl]
	bit 7, c
	jr nz, Jump_02_4FF3
	swap a
Jump_02_4FF3:
	and $0F
	add a, b
	ld hl, $5040
	add a, a
	add a, a
	ld c, a
	ld b, $00
	sla c
	rl b
	sla c
	rl b
	add hl, bc
	call Func_20B1
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	call Func_20B1
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	call Func_20B1
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	call Func_20B1
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ret

	INCBIN "assets/bank_02/5040.bin" ; $C00 bytes

Func_02_5C40:
	call Func_3BB0
	ld a, $0A
	call ScreenTable_CallInit
	ld a, $0A
	ld bc, $0000
	call ScreenTable_CallUpdate
	ld d, $B4
Jump_02_5C52:
	xor a
	ld [wVBlankPending], a
Jump_02_5C56:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_02_5C56
	xor a
	ld [wVBlankPending], a
	call Audio_Update
	dec d
	jr nz, Jump_02_5C52
	call Func_06F8
	ld a, $02
	call ScreenTable_CallInit
	ld a, $02
	ld bc, $0000
	call ScreenTable_CallUpdate
	ld d, $B4
	call Func_3971
	call Func_06F8
	ld a, $05
	call ScreenTable_CallInit
	ld a, $05
	ld bc, $0000
	call ScreenTable_CallUpdate
	ld d, $B4
	call Func_3971
	call Func_071F
	ld e, $4F
	call Audio_QueueSound
	ld e, $82
	call Audio_QueueSound
	ld a, $08
	ldh [rSCX], a
	ldh [rSCY], a
	ld a, $07
	call ScreenTable_CallInit
	ld a, $07
	ld bc, $0000
	call ScreenTable_CallUpdate
	ld e, $3C
Jump_02_5CB5:
	xor a
	ld [wVBlankPending], a
Jump_02_5CB9:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_02_5CB9
	xor a
	ld [wVBlankPending], a
	call Audio_Update
	call Func_0421
	and $0F
	ld d, a
	call Func_0421
	and $01
	or a
	jr z, Jump_02_5CDA
	ld a, d
	ldh [rSCX], a
Jump_02_5CDA:
	call Func_0421
	and $01
	or a
	jr z, Jump_02_5CE5
	ld a, d
	ldh [rSCY], a
Jump_02_5CE5:
	call Func_0421
	and $03
	or $01
	sla a
	ld d, a
Jump_02_5CEF:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_02_5CEF
	ld a, d
	ldh a, [rBCPD]
	ld c, a
	ld a, $FF
	ld a, d
	inc a
	ldh a, [rBCPD]
	ld b, a
	ld a, $03
	xor a
	ld [wVBlankPending], a
Jump_02_5D06:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_02_5D06
	xor a
	ld [wVBlankPending], a
	call Audio_Update
	ld a, d
	ld a, c
	ld a, d
	inc a
	ld a, b
	dec e
	jp nz, Jump_02_5CB5
	ld a, $08
	ldh [rSCX], a
	ldh [rSCY], a
	ld d, $B4
	call Func_3971
	call Func_06F8
	xor a
	ldh [rSCX], a
	ldh [rSCY], a
	ret


Func_02_5D33:
	xor a
	ld [$CD04], a
	ld [$CD05], a
	ld [$CD06], a
	ld [$CD07], a
Jump_02_5D40:
	xor a
	or b
	jr nz, Jump_02_5D49
	or c
	jr nz, Jump_02_5D49
	jr Jump_02_5D6C

Jump_02_5D49:
	ld a, [$CD04]
	add a, $E8
	ld [$CD04], a
	ld a, [$CD05]
	adc a, $03
	ld [$CD05], a
	ld a, [$CD06]
	adc a, $00
	ld [$CD06], a
	ld a, [$CD07]
	adc a, $00
	ld [$CD07], a
	dec bc
	jr Jump_02_5D40

Jump_02_5D6C:
	ret


Func_02_5D6D:
	ld a, e
	add a, a
	add a, a
	ld hl, $41F7
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ldh [$FFB1], a
	ld a, [hli]
	ldh [$FFB2], a
	ld h, b
	ld l, c
Jump_02_5D86:
	ldh a, [rLY]
	cp $90
	jr c, Jump_02_5D86
	ld a, $01
	ldh [rVBK], a
	ld a, h
	ldh [rHDMA1], a
	ld a, l
	ldh [rHDMA2], a
	ld a, $88
	ldh [rHDMA3], a
	xor a
	ldh [rHDMA4], a
	ld a, $27
	ldh [rHDMA5], a
	ld hl, $4D52
	ld b, $07
	ld c, $01
	call Func_057D
	ld hl, $C600
	ld de, $0000
	ldh a, [rSCY]
	ld b, a
	ld c, $80
Jump_02_5DB6:
	ld e, $00
Jump_02_5DB8:
	ldh a, [$FFB2]
	add a, d
	ld [hli], a
	ldh a, [$FFB1]
	add a, e
	ld [hli], a
	ld a, c
	ld [hli], a
	ld a, $1F
	ld [hli], a
	inc c
	ld a, e
	add a, $08
	ld e, a
	cp $50
	jr nz, Jump_02_5DB8
	ld a, d
	add a, $08
	ld d, a
	cp $20
	jr nz, Jump_02_5DB6
Jump_02_5DD6:
	ldh a, [rLY]
	cp $90
	jr c, Jump_02_5DD6
	call OAMDMARoutine
	ret

	INCBIN "assets/bank_02/5DE0.bin" ; $48D bytes

Func_02_626D:
	ld a, $02
	ldh [rSVBK], a
	ld a, $02
	ld [$C8E6], a
	ld hl, $D000
	xor a
	ld b, $28
Jump_02_627C:
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	dec b
	jr nz, Jump_02_627C
	ld hl, $D0A0
	ld b, $28
Jump_02_6288:
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	dec b
	jr nz, Jump_02_6288
	xor a
	ld [$C9E9], a
	ld [$C9EC], a
	ld [$C9ED], a
	ld a, $FF
	ld [$C9EB], a
	xor a
	ldh [rSCX], a
	ldh [rSCY], a
	xor a
	ld b, $A0
	ld de, $FE00
	ld hl, $D000
Jump_02_62B0:
	ld [de], a
	ld [hli], a
	inc e
	dec b
	jr nz, Jump_02_62B0
	ldh a, [rLCDC]
	res 6, a
	res 5, a
	res 4, a
	set 1, a
	ldh [rLCDC], a
	call Func_02_62EC
	call Func_02_62CD
	ld a, $01
	ldh [$FF88], a
	ret


Func_02_62CD:
	ld hl, $5DE0
Jump_02_62D0:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_02_62D0
	ld a, $80
	ldh [rOCPS], a
	ld b, $20
Jump_02_62DC:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_02_62DC
	ld a, [hli]
	ldh [rOCPD], a
	ld a, [hli]
	ldh [rOCPD], a
	dec b
	jr nz, Jump_02_62DC
	ret


Func_02_62EC:
	ld hl, $8000
	ld de, $5E89
	ld b, $21
Jump_02_62F4:
	ld c, $10
Jump_02_62F6:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_02_62F6
	ld a, [de]
	inc de
	ld [hli], a
	dec c
	jr nz, Jump_02_62F6
	dec b
	jr nz, Jump_02_62F4
	ret


Func_02_6306:
	call Func_02_626D
	ld a, $FF
	ld [$C9EA], a
Jump_02_630E:
	call Func_02_634F
	call Audio_Update
	call Func_02_66D4
	call Func_02_6337
	ld a, [$C9EA]
	dec a
	ld [$C9EA], a
	jr nz, Jump_02_630E
	inc a
	ld [$C9EA], a
	ld a, [$C6B5]
	and a
	jr z, Jump_02_630E
	ld e, $80
	call Audio_QueueSound
	call Audio_Update
	xor a
	ret


Func_02_6337:
	ld de, $FE00
	ld hl, $D000
	ld b, $28
Jump_02_633F:
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	dec b
	jr nz, Jump_02_633F
	ret


Func_02_634F:
	call Func_02_662A
	call Func_02_649E
	ld a, [$C9ED]
	and a
	ret z
	dec a
	ld [$C9ED], a
	ret


Func_02_635F:
	ld a, [$C9E9]
	cp $18
	ret nc
	ld a, [$C9ED]
	and a
	ret nz
	ld a, [$C9EB]
	cp $FF
	ret nz
	xor a
	ld [$C9EC], a
	ld [$C9EB], a
	ld a, [$C9E9]
	add a, $10
	ld [$C9E9], a
	call Func_02_66C0
	and $03
	add a, a
	ld e, a
	ld d, $00
	ld hl, $6265
	add hl, de
	ld a, [hli]
	ldh [$FF80], a
	ld a, [hl]
	ldh [$FF81], a
	ld bc, $5E20
	ld hl, $D000
	ld de, $D0A0
	ld a, $04
	ldh [$FF84], a
Jump_02_639F:
	ld a, $04
	ldh [$FF83], a
Jump_02_63A3:
	ld a, [de]
	and a
	jr z, Jump_02_63B9
	ld a, $08
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	ld a, $04
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	jr Jump_02_63A3

Jump_02_63B9:
	ld a, $FF
	ld [de], a
	ldh a, [$FF81]
	ld [hli], a
	ldh a, [$FF80]
	ld [hli], a
	add a, $08
	ldh [$FF80], a
	ld a, $08
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	ld a, $02
	call Func_004E
	inc bc
	sub $62
	ld [hli], a
	xor a
	ld [hli], a
	ldh a, [$FF83]
	dec a
	ldh [$FF83], a
	jr nz, Jump_02_63A3
	ldh a, [$FF80]
	sub $20
	ldh [$FF80], a
	ldh a, [$FF81]
	add a, $08
	ldh [$FF81], a
	ldh a, [$FF84]
	dec a
	ldh [$FF84], a
	jr nz, Jump_02_639F
	ret


Func_02_63F4:
	ld a, [$C9EB]
	cp $FF
	ret z
	ld b, a
	ld a, [$C9EC]
	inc a
	ld [$C9EC], a
	cp $06
	ret nz
	xor a
	ld [$C9EC], a
	ld a, b
	inc a
	ld [$C9EB], a
	cp $06
	jr z, Jump_02_6454
	swap a
	ld e, a
	ld d, $00
	ld hl, $5E20
	add hl, de
	ld de, $D002
	ld bc, $D0A0
	ld a, $10
	ldh [$FF80], a
Jump_02_6425:
	ld a, [bc]
	cp $FF
	jr z, Jump_02_643C
	ld a, $08
	add a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	ld a, $04
	add a, e
	ld e, a
	ld a, $00
	adc a, e
	ld e, a
	jr Jump_02_6425

Jump_02_643C:
	ld a, [hli]
	sub $62
	ld [de], a
	inc de
	inc de
	inc de
	inc de
	ld a, $08
	add a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	ldh a, [$FF80]
	dec a
	ldh [$FF80], a
	jr nz, Jump_02_6425
	ret

Jump_02_6454:
	jp Jump_02_6457

Jump_02_6457:
	ld a, $FF
	ld [$C9EB], a
	call Func_02_66C0
	and $3F
	ld [$C9ED], a
	ld a, [$C9E9]
	sub $10
	ld [$C9E9], a
	ld hl, $D000
	ld de, $D0A0
	ld b, $10
	xor a
Jump_02_6475:
	ld a, [de]
	cp $FF
	jr z, Jump_02_648C
	ld a, $08
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	ld a, $04
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	jr Jump_02_6475

Jump_02_648C:
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [de], a
	ld a, $08
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	dec b
	jr nz, Jump_02_6475
	ret


Func_02_649E:
	ld hl, $D0A0
	ld de, $D000
	ld a, $28
	ldh [$FF87], a
Jump_02_64A8:
	ld a, [hli]
	ldh [$FF82], a
	and a
	jr z, Jump_02_64F2
	cp $FF
	jr z, Jump_02_64F2
	ld a, [hl]
	cp $7E
	jr c, Jump_02_64BD
	cp $80
	jr nc, Jump_02_64BD
	jr Jump_02_64BF

Jump_02_64BD:
	add a, $02
Jump_02_64BF:
	ld [hli], a
	ldh [$FF81], a
	ld a, [hli]
	ldh [$FF80], a
	dec [hl]
	call z, Func_02_6548
	inc hl
	ldh a, [$FF81]
	call Func_02_652E
	sub $10
	cp $91
	jr nc, Jump_02_6506
	ldh a, [$FF80]
	call Func_02_652E
	sub $08
	cp $A1
	jr nc, Jump_02_6504
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [de]
	inc a
	and $07
	ld [de], a
	inc de
	inc hl
Jump_02_64EA:
	ldh a, [$FF87]
	dec a
	ldh [$FF87], a
	jr nz, Jump_02_64A8
	ret

Jump_02_64F2:
	ld a, $07
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, $04
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	jr Jump_02_64EA

Jump_02_6504:
	dec hl
	dec de
Jump_02_6506:
	ld a, [de]
	and a
	jr z, Jump_02_6511
	ld a, [$C9E9]
	dec a
	ld [$C9E9], a
Jump_02_6511:
	dec hl
	dec hl
	dec de
	xor a
	ld [hld], a
	ld [hld], a
	ld [hld], a
	ld [hld], a
	ld [de], a
	inc de
	ld [de], a
	ld a, $08
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, $04
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	jr Jump_02_64EA


Func_02_652E:
	ld b, $00
	bit 7, a
	jr z, Jump_02_6535
	dec b
Jump_02_6535:
	sla a
	rl b
	sla a
	rl b
	sla a
	rl b
	add a, [hl]
	ld [hli], a
	ld a, [de]
	adc a, b
	ld [de], a
	inc de
	ret


Func_02_6548:
	push hl
	push de
	push af
	push bc
	push de
	push hl
	ld e, $04
	call Audio_QueueSound
	pop hl
	pop de
	pop bc
	pop af
	xor a
	dec hl
	ld [hld], a
	ld [hld], a
	ld [hld], a
	ld a, [de]
	ldh [$FF86], a
	xor a
	ld [de], a
	inc de
	ld a, [de]
	ldh [$FF85], a
	xor a
	ld [de], a
	ld hl, $C9E9
	dec [hl]
	pop de
	pop hl
	ldh a, [$FF82]
	cp $01
	ret z
	push hl
	ld hl, $6251
	sub $02
	add a, a
	ld c, a
	ld b, $00
	add hl, bc
	ld a, [$C9E9]
	ld b, a
	ld a, $28
	sub b
	inc a
	ld b, a
	ld a, [hl]
Jump_02_6587:
	cp b
	jr c, Jump_02_6593
	dec hl
	dec hl
	ld a, [hl]
	cp $FF
	jr nz, Jump_02_6587
	pop hl
	ret

Jump_02_6593:
	ld b, a
	ldh [$FF8A], a
	ld a, [$C9E9]
	add a, b
	ld [$C9E9], a
	inc hl
	ld a, [hl]
	add a, a
	ldh [$FF89], a
	push de
	ld hl, $D0A0
	ld de, $D000
	ld bc, $6099
	call Func_02_66C0
	and $0F
	add a, a
	add a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
Jump_02_65B8:
	call Func_02_65D7
	ldh a, [$FF89]
	add a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	push bc
	call Func_02_65EA
	pop bc
	ldh a, [$FF8A]
	dec a
	ldh [$FF8A], a
	jr nz, Jump_02_65B8
	xor a
	ldh [$FF80], a
	ldh [$FF81], a
	pop de
	pop hl
	ret


Func_02_65D7:
	push de
	ldh a, [$FF80]
	ld d, a
	ldh a, [$FF81]
	ld e, a
	ld a, [bc]
	inc bc
	add a, d
	ldh [$FF83], a
	ld a, [bc]
	inc bc
	add a, e
	ldh [$FF84], a
	pop de
	ret


Func_02_65EA:
	ld a, [hl]
	and a
	jr z, Jump_02_6600
	ld a, $08
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, $04
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	jr Func_02_65EA

Jump_02_6600:
	ld a, $01
	ld [hli], a
	ldh a, [$FF84]
	ld [hli], a
	ldh a, [$FF83]
	ld [hli], a
	ldh a, [$FF82]
	swap a
	ld [hli], a
	xor a
	ld [hli], a
	ld [hli], a
	ld a, $01
	ld [hli], a
	xor a
	ld [hli], a
	ldh a, [$FF86]
	ld [de], a
	inc de
	ldh a, [$FF85]
	ld [de], a
	inc de
	ld a, $02
	ld [de], a
	inc de
	call Func_02_66C0
	and $07
	ld [de], a
	inc de
	ret


Func_02_662A:
	ld hl, $FF88
	dec [hl]
	ret nz
	call Func_02_66C0
	srl a
	srl a
	or $08
	ldh [$FF88], a
	ld a, [$C9E9]
	cp $1E
	ret nc
	ld hl, $D0A0
	ld de, $0008
	ld b, $28
Jump_02_6648:
	ld a, [hl]
	and a
	jr z, Jump_02_6651
	add hl, de
	dec b
	jr nz, Jump_02_6648
	ret

Jump_02_6651:
	ld a, [$C9E9]
	inc a
	ld [$C9E9], a
	ld de, $D000
	ld a, $28
	sub b
	add a, a
	add a, a
	add a, e
	ld e, a
	jr nc, Jump_02_6665
	inc d
Jump_02_6665:
	ld a, $8F
	ld [de], a
	inc de
Jump_02_6669:
	call Func_02_66C0
	cp $64
	jr nc, Jump_02_6669
	ld [de], a
	ld b, a
	inc de
	call Func_02_66C0
	and $07
	add a, $02
	ld [hli], a
	ld [de], a
	inc de
	ld c, a
	call Func_02_66C0
	and $07
	ld [de], a
	ld d, c
	call Func_02_66C0
	and $0F
	add a, $0A
	or $80
	ld [hli], a
	ld e, a
	ld a, b
	srl a
	cp $28
	jr nc, Jump_02_66A6
	sub $28
	ld b, a
	ld a, $28
	sub b
	sra a
	sra a
	sra a
	ld [hli], a
	jr Jump_02_66B1

Jump_02_66A6:
	ld b, a
	ld a, $00
	sub b
	sra a
	sra a
	sra a
	ld [hli], a
Jump_02_66B1:
	call Func_02_66C0
	and $0F
	add a, $28
	ld [hli], a
	xor a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	inc hl
	ld [hli], a
	ret


Func_02_66C0:
	push hl
	push de
	ld hl, $614F
	ld d, $00
	ld a, [$C9E8]
	inc a
	ld [$C9E8], a
	ld e, a
	add hl, de
	ld a, [hl]
	pop de
	pop hl
	ret


Func_02_66D4:
	ld b, $91
Jump_02_66D6:
	ldh a, [rLY]
	cp b
	jr nz, Jump_02_66D6
	ret

	INCBIN "assets/bank_02/66DC.bin" ; $1924 bytes
