; BattleTanx (USA) - ROM bank $01

SECTION "ROM Bank $01", ROMX[$4000], BANK[$01]

Func_01_4000:
	xor a
	ldh [rNR51], a
	ld d, $08
Jump_01_4005:
	xor a
	ld [wVBlankPending], a
Jump_01_4009:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_4009
	xor a
	ld [wVBlankPending], a
	ld b, $02
	call Func_3252
	dec d
	jr nz, Jump_01_4005
	call Func_32DE
	ld d, $08
Jump_01_4023:
	xor a
	ld [wVBlankPending], a
Jump_01_4027:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_4027
	xor a
	ld [wVBlankPending], a
	ld b, $FE
	call Func_3252
	dec d
	jr nz, Jump_01_4023
Jump_01_403C:
	xor a
	ld [wVBlankPending], a
Jump_01_4040:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_4040
	xor a
	ld [wVBlankPending], a
	call Func_3608
	ld a, [$C6C1]
	or a
	jp z, Jump_01_4064
	xor a
	ld [wVBlankPending], a
Jump_01_405B:
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_405B
	jp Jump_01_403C

Jump_01_4064:
	ld d, $08
Jump_01_4066:
	xor a
	ld [wVBlankPending], a
Jump_01_406A:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_406A
	xor a
	ld [wVBlankPending], a
	ld b, $02
	call Func_3252
	dec d
	jr nz, Jump_01_4066
	call Func_325B
	ld d, $08
Jump_01_4084:
	xor a
	ld [wVBlankPending], a
Jump_01_4088:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_4088
	xor a
	ld [wVBlankPending], a
	ld b, $FE
	call Func_3252
	dec d
	jr nz, Jump_01_4084
	ret


Func_01_409E:
	push af
	push bc
	push de
	push hl
	xor a
	ld [wSfxSeqPtr], a
	ld [wSfxSeqPtr + 1], a
	ldh [rNR51], a
	call Func_2FF9
Jump_01_40AE:
	ldh a, [rLY]
	cp $14
	jr z, Jump_01_40AE
Jump_01_40B4:
	ldh a, [rLY]
	cp $14
	jr nz, Jump_01_40B4
	call Audio_Update
	ld a, [wMusicEnabled]
	and a
	jr z, Jump_01_40C9
	ld a, [wMusicPtr]
	and a
	jr nz, Jump_01_40AE
Jump_01_40C9:
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_01_40CE:
	push af
	push bc
	push de
	push hl
	xor a
	ld [hli], a
	ld [hl], a
	ld e, l
	ld d, h
	ld hl, $4F00
	ld c, $08
Jump_01_40DC:
	rr b
	jr nc, Jump_01_40F8
	push bc
	push de
	ld c, $02
	ld b, $00
Jump_01_40E6:
	ld a, [de]
	add a, b
	add a, [hl]
	daa
	ld [de], a
	ld b, $00
	rl b
	inc l
	dec de
	dec c
	jr nz, Jump_01_40E6
	pop de
	pop bc
	jr Jump_01_40FA

Jump_01_40F8:
	inc l
	inc l
Jump_01_40FA:
	dec c
	jr nz, Jump_01_40DC
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_01_4102:
	push af
	push bc
	push de
	push hl
	push bc
	ld b, c
	push bc
	inc de
	inc de
	ld hl, $4F10
	ld a, $02
	ldh [$FF80], a
Jump_01_4112:
	pop bc
	ld c, $08
Jump_01_4115:
	rr b
	jr nc, Jump_01_4131
	push bc
	push de
	ld c, $03
	ld b, $00
Jump_01_411F:
	ld a, [de]
	add a, b
	add a, [hl]
	daa
	ld [de], a
	ld b, $00
	rl b
	inc l
	dec de
	dec c
	jr nz, Jump_01_411F
	pop de
	pop bc
	jr Jump_01_4134

Jump_01_4131:
	inc l
	inc l
	inc l
Jump_01_4134:
	dec c
	jr nz, Jump_01_4115
	ldh a, [$FF80]
	dec a
	ldh [$FF80], a
	jr nz, Jump_01_4112
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_01_4143:
	push af
	push bc
	push de
	push hl
	push de
	ld d, e
	push de
	push bc
	ld b, c
	push bc
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld e, l
	ld d, h
	ld hl, $4F40
	ld a, $04
	ldh [$FF80], a
Jump_01_415C:
	pop bc
	ld c, $08
Jump_01_415F:
	rr b
	jr nc, Jump_01_417B
	push bc
	push de
	ld c, $05
	ld b, $00
Jump_01_4169:
	ld a, [de]
	add a, b
	add a, [hl]
	daa
	ld [de], a
	ld b, $00
	rl b
	inc l
	dec de
	dec c
	jr nz, Jump_01_4169
	pop de
	pop bc
	jr Jump_01_4180

Jump_01_417B:
	inc l
	inc l
	inc l
	inc l
	inc l
Jump_01_4180:
	dec c
	jr nz, Jump_01_415F
	ldh a, [$FF80]
	dec a
	ldh [$FF80], a
	jr nz, Jump_01_415C
	pop hl
	pop de
	pop bc
	pop af
	ret

	db $50, $C3, $00, $00, $A0, $86, $01, $00, $F0, $49, $02, $00, $40, $0D, $03, $00
	db $90, $D0, $03, $00, $E0, $93, $04, $00, $30, $57, $05, $00, $80, $1A, $06, $00
	db $D0, $DD, $06, $00, $20, $A1, $07, $00, $70, $64, $08, $00, $C0, $27, $09, $00
	db $10, $EB, $09, $00, $60, $AE, $0A, $00, $B0, $71, $0B, $00, $00, $35, $0C, $00
	db $50, $F8, $0C, $00, $A0, $BB, $0D, $00, $F0, $7E, $0E, $00, $40, $42, $0F, $00
	db $FF, $FF, $FF, $FF, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87
	db $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87
	db $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $00, $01, $2F, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $02
	db $03, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $05

Func_01_4233:
	push af
	push bc
	push de
	push hl
	ld d, $02
	ld hl, $C400
	ld bc, $41E3
	call Func_3202
	ld d, $02
	ld hl, $C440
	ld bc, $420B
	call Func_3202
	pop hl
	pop de
	pop bc
	pop af
	ret

	db $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87
	db $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87
	db $87, $87, $87, $87, $87, $87, $87, $87, $00, $01, $01, $01, $01, $01, $06, $07
	db $08, $09, $0A, $0B, $0C, $0D, $01, $01, $01, $01, $01, $02, $03, $04, $04, $04
	db $04, $04, $0E, $0F, $10, $11, $12, $13, $14, $15, $04, $04, $04, $04, $04, $05

Func_01_42A2:
	push af
	push bc
	push de
	push hl
	ld d, $02
	ld hl, $C400
	ld bc, $4252
	call Func_3202
	ld d, $02
	ld hl, $C440
	ld bc, $427A
	call Func_3202
	ld a, $01
	ldh [rVBK], a
	ld a, $C4
	ldh [rHDMA1], a
	ld a, $00
	ldh [rHDMA2], a
	ld a, $9C
	ldh [rHDMA3], a
	xor a
	ldh [rHDMA4], a
	ld a, $04
	ldh [rHDMA5], a
	xor a
	ldh [rVBK], a
	ld a, $C4
	ldh [rHDMA1], a
	ld a, $40
	ldh [rHDMA2], a
	ld a, $9C
	ldh [rHDMA3], a
	xor a
	ldh [rHDMA4], a
	ld a, $04
	ldh [rHDMA5], a
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_01_42EE:
	ret


Func_01_42EF:
	push af
	push bc
	push de
	push hl
	xor a
	ldh [$FF84], a
	ldh [$FF83], a
	ldh [$FF85], a
	ld d, $40
	ld hl, $D000
Jump_01_42FF:
	ld a, l
	and $C0
	add a, $1D
	ld l, a
	ld a, [hl]
	ld e, a
	cp $02
	jr nz, Jump_01_4310
	ldh a, [$FF84]
	inc a
	ldh [$FF84], a
Jump_01_4310:
	ld a, e
	cp $00
	jr z, Jump_01_431A
	ldh a, [$FF83]
	inc a
	ldh [$FF83], a
Jump_01_431A:
	ld a, e
	cp $01
	jr nz, Jump_01_4324
	ldh a, [$FF85]
	inc a
	ldh [$FF85], a
Jump_01_4324:
	ld a, l
	and $C0
	add a, $40
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	dec d
	jr nz, Jump_01_42FF
	ldh a, [$FF83]
	ld b, a
	ld hl, $FF80
	call Func_06C5
	ld hl, $9C05
	ld c, $87
	ldh a, [$FF81]
	ld e, a
	swap a
	and $0F
	add a, $01
	ld b, a
	ld a, $01
	ldh [rVBK], a
Jump_01_434D:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_434D
	ld [hl], c
	xor a
	ldh [rVBK], a
	ld [hl], b
	inc l
	ld a, e
	and $0F
	add a, $01
	ld b, a
	ld a, $01
	ldh [rVBK], a
Jump_01_4363:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_4363
	ld [hl], c
	xor a
	ldh [rVBK], a
	ld [hl], b
	inc l
	ldh a, [$FF84]
	ld b, a
	ld hl, $FF80
	call Func_06C5
	ld hl, $9C08
	ld c, $87
	ldh a, [$FF81]
	ld e, a
	swap a
	and $0F
	add a, $01
	ld b, a
	ld a, $01
	ldh [rVBK], a
Jump_01_438B:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_438B
	ld [hl], c
	xor a
	ldh [rVBK], a
	ld [hl], b
	inc l
	ld a, e
	and $0F
	add a, $01
	ld b, a
	ld a, $01
	ldh [rVBK], a
Jump_01_43A1:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_43A1
	ld [hl], c
	xor a
	ldh [rVBK], a
	ld [hl], b
	inc l
	ldh a, [$FF85]
	ld b, a
	ld hl, $FF80
	call Func_06C5
	ld hl, $9C0B
	ld c, $87
	ldh a, [$FF81]
	ld e, a
	swap a
	and $0F
	add a, $01
	ld b, a
	ld a, $01
	ldh [rVBK], a
Jump_01_43C9:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_43C9
	ld [hl], c
	xor a
	ldh [rVBK], a
	ld [hl], b
	inc l
	ld a, e
	and $0F
	add a, $01
	ld b, a
	ld a, $01
	ldh [rVBK], a
Jump_01_43DF:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_43DF
	ld [hl], c
	xor a
	ldh [rVBK], a
	ld [hl], b
	inc l
	ld a, [$C6ED]
	ld b, a
	ld hl, $FF80
	call Func_06C5
	ld hl, $9C0E
	ld c, $87
	ldh a, [$FF81]
	ld e, a
	swap a
	and $0F
	add a, $01
	ld b, a
	ld a, $01
	ldh [rVBK], a
Jump_01_4408:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_4408
	ld [hl], c
	xor a
	ldh [rVBK], a
	ld [hl], b
	inc l
	ld a, e
	and $0F
	add a, $01
	ld b, a
	ld a, $01
	ldh [rVBK], a
Jump_01_441E:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_441E
	ld [hl], c
	xor a
	ldh [rVBK], a
	ld [hl], b
	inc l
	ld a, [$C6EE]
	ld b, a
	ld hl, $FF80
	call Func_06C5
	ld hl, $9C11
	ld c, $87
	ldh a, [$FF81]
	ld e, a
	swap a
	and $0F
	add a, $01
	ld b, a
	ld a, $01
	ldh [rVBK], a
Jump_01_4447:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_4447
	ld [hl], c
	xor a
	ldh [rVBK], a
	ld [hl], b
	inc l
	ld a, e
	and $0F
	add a, $01
	ld b, a
	ld a, $01
	ldh [rVBK], a
Jump_01_445D:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_445D
	ld [hl], c
	xor a
	ldh [rVBK], a
	ld [hl], b
	inc l
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_01_446E:
	push hl
	push bc
	ld a, [$CD00]
	ld l, a
	ld a, [$CD01]
	ld h, a
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld a, [hl]
	ld c, a
	ld [hl], $00
Jump_01_4482:
	xor a
	ld [wVBlankPending], a
Jump_01_4486:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_4486
	xor a
	ld [wVBlankPending], a
	ld a, $01
	ldh [rVBK], a
	ld a, $C4
	ldh [rHDMA1], a
	ld a, $00
	ldh [rHDMA2], a
	ld a, $9C
	ldh [rHDMA3], a
	xor a
	ldh [rHDMA4], a
	ld a, $04
	ldh [rHDMA5], a
	xor a
	ldh [rVBK], a
	ld a, $C4
	ldh [rHDMA1], a
	ld a, $40
	ldh [rHDMA2], a
	ld a, $9C
	ldh [rHDMA3], a
	xor a
	ldh [rHDMA4], a
	ld a, $04
	ldh [rHDMA5], a
	ld a, [$C6B7]
	and $01
	jr nz, Jump_01_4482
	ld a, l
	and $C0
	ld l, a
	ld b, $01
	call Func_2FA3
	call Func_334A
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld a, [hl]
	cp c
	jr c, Jump_01_4482
	pop bc
	pop hl
	ret

EntityHandlerTable:
	dw Func_01_451A
	dw Func_01_453D
	dw Func_01_455E
	dw Func_01_4582
	dw Func_01_45AB
	dw Func_01_45CD
	dw Func_01_45EE
	dw Func_01_4615
	dw Func_01_4648
	dw Func_01_467B

DispatchEntityHandler:
	push de
	push bc
	push hl
	push de
	push hl
	pop de
	ld a, l
	and $C0
	add a, $1E
	ld l, a
	ld a, [hl]
	sla a
	add a, LOW(EntityHandlerTable)
	ld l, a
	ld a, HIGH(EntityHandlerTable)
	adc a, $00
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl


Func_01_450F:
	pop hl
	call Func_2044
	pop bc
	pop de
	ret


Func_01_4516:
	pop hl
	pop bc
	pop de
	ret


Func_01_451A:
	pop hl
	call Func_0C41
	ld b, a
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld a, [hl]
	cp b
	jr c, Jump_01_452C
	jp Func_01_4516

Jump_01_452C:
	ld a, b
	sra a
	sra a
	ld b, a
	call Func_2FA3
	ld e, $4A
	call Audio_QueueSound
	jp Func_01_450F


Func_01_453D:
	pop hl
	call Func_0C41
	ld b, a
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld a, [hl]
	cp b
	jr c, Jump_01_454F
	jp Func_01_4516

Jump_01_454F:
	ld a, b
	sra a
	ld b, a
	call Func_2FA3
	ld e, $4B
	call Audio_QueueSound
	jp Func_01_450F


Func_01_455E:
	pop hl
	ld a, l
	and $C0
	add a, $27
	ld l, a
	ld a, [hl]
	or a
	jp nz, Func_01_4516
	ld a, l
	and $C0
	add a, $27
	ld l, a
	ld [hl], $3C
	ld a, l
	and $C0
	add a, $28
	ld l, a
	ld [hl], $00
	ld e, $53
	call Audio_QueueSound
	jp Func_01_450F


Func_01_4582:
	pop hl
	ld a, [$CD00]
	cp l
	jr nz, Func_01_450F
	ld a, [$CD01]
	cp h
	jp nz, Func_01_450F
	call Func_3845
	ld bc, $0BB8
	call AddToScore
	ld e, $54
	call Audio_QueueSound
	ld a, [$C6EF]
	inc a
	ld [$C6EF], a
	call Func_0A48
	jp Func_01_450F


Func_01_45AB:
	pop hl
	ld a, [$CD00]
	cp l
	jp nz, Func_01_4516
	ld a, [$CD01]
	cp h
	jp nz, Func_01_4516
	ld a, [$CD02]
	cp $09
	jp z, Func_01_4516
	call Func_2FED
	ld e, $49
	call Audio_QueueSound
	jp Func_01_450F


Func_01_45CD:
	pop hl
	ld a, l
	and $C0
	add a, $29
	ld l, a
	ld a, [hl]
	cp $00
	jp nz, Func_01_4516
	ld a, $02
	ld [hl], a
	ld a, l
	and $C0
	add a, $2A
	ld l, a
	ld a, $06
	ld [hl], a
	ld e, $55
	call Audio_QueueSound
	jp Func_01_450F


Func_01_45EE:
	pop hl
	ld a, l
	and $C0
	add a, $29
	ld l, a
	ld a, [hl]
	cp $00
	jp nz, Func_01_4516
	ld a, l
	and $C0
	add a, $29
	ld l, a
	ld a, $01
	ld [hl], a
	ld a, l
	and $C0
	add a, $2A
	ld l, a
	ld a, $09
	ld [hl], a
	ld e, $56
	call Audio_QueueSound
	jp Func_01_450F


Func_01_4615:
	pop hl
	ld a, l
	and $C0
	add a, $29
	ld l, a
	ld a, [hl]
	cp $00
	jp nz, Func_01_4516
	push hl
	call Func_3845
	pop hl
	ld a, l
	and $C0
	add a, $29
	ld l, a
	ld a, $03
	ld [hl], a
	ld a, l
	and $C0
	add a, $2A
	ld l, a
	ld a, $01
	ld [hl], a
	ld e, $51
	call Audio_QueueSound
	ld a, [$C6F0]
	inc a
	ld [$C6F0], a
	jp Func_01_450F


Func_01_4648:
	pop hl
	ld a, l
	and $C0
	add a, $26
	ld l, a
	ld a, [hl]
	and a
	jp nz, Func_01_4516
	ld a, $01
	ld [$C91D], a
	ld e, $53
	call Audio_QueueSound
	xor a
	ld [$C8D9], a
	call Func_0A48
	pop hl
	push hl
	ld a, l
	and $C0
	add a, $1E
	ld l, a
	ld a, [hl]
	inc a
	ld [hl], a
	ld a, l
	ld [$C91E], a
	ld a, h
	ld [$C91F], a
	jp Func_01_4516


Func_01_467B:
	pop hl
	jp Func_01_4516

	db $53, $54, $55, $56, $57, $58, $59, $5A

Func_01_4687:
	push de
	push bc
	push hl
	call Func_20B1
	ld a, l
	and $C0
	add a, $07
	ld l, a
	ld a, [hld]
	sub $04
	ld [de], a
	inc e
	ld a, [hl]
	sub $04
	ld [de], a
	inc e
	ld a, l
	and $C0
	add a, $1E
	ld l, a
	ld a, [hl]
	add a, $53
	ld [de], a
	inc e
	ldh a, [$FF80]
	or $08
	ld [de], a
	pop hl
	pop bc
	pop de
	ret


Func_01_46B1:
	push de
	ld a, b
	srl a
	srl a
	and $1F
	sub e
	jr nc, Jump_01_46BD
	xor a
Jump_01_46BD:
	sla a
	sla a
	ld d, a
	ld a, b
	and $03
	or d
	and $7F
	ld b, a
	ld a, b
	swap a
	and $30
	ld d, a
	ld a, c
	swap a
	and $0E
	or d
	srl a
	sub e
	jr nc, Jump_01_46DB
	xor a
Jump_01_46DB:
	sla a
	swap a
	ld d, a
	ld a, b
	and $7C
	ld b, a
	ld a, d
	and $03
	or b
	and $7F
	ld b, a
	ld a, c
	and $1F
	ld c, a
	ld a, d
	and $E0
	or c
	ld c, a
	ld a, c
	and $1F
	sub e
	jr nc, Jump_01_46FB
	xor a
Jump_01_46FB:
	ld d, a
	ld a, c
	and $E0
	or d
	ld c, a
	pop de
	ret


Func_01_4703:
	push de
	ld a, b
	srl a
	srl a
	and $1F
	add a, e
	cp $1F
	jr c, Jump_01_4712
	ld a, $1F
Jump_01_4712:
	sla a
	sla a
	ld d, a
	ld a, b
	and $03
	or d
	and $7F
	ld b, a
	ld a, b
	swap a
	and $30
	ld d, a
	ld a, c
	swap a
	and $0E
	or d
	srl a
	add a, e
	cp $1F
	jr c, Jump_01_4733
	ld a, $1F
Jump_01_4733:
	sla a
	swap a
	ld d, a
	ld a, b
	and $7C
	ld b, a
	ld a, d
	and $03
	or b
	and $7F
	ld b, a
	ld a, c
	and $1F
	ld c, a
	ld a, d
	and $E0
	or c
	ld c, a
	ld a, c
	and $1F
	add a, e
	cp $1F
	jr c, Jump_01_4756
	ld a, $1F
Jump_01_4756:
	ld d, a
	ld a, c
	and $E0
	or d
	ld c, a
	pop de
	ret


Func_01_475E:
	push af
	push bc
	push de
	push hl
	ld d, $00
Jump_01_4764:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_4764
	ld a, d
	ldh [rBCPS], a
	ldh a, [rBCPD]
	ld c, a
	inc d
	ld a, d
	ldh [rBCPS], a
	ldh a, [rBCPD]
	ld b, a
	dec d
	call Func_3856
Jump_01_477B:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_477B
	ld a, d
	ldh [rBCPS], a
	ld a, c
	ldh [rBCPD], a
	inc d
	ld a, d
	ldh [rBCPS], a
	ld a, b
	ldh [rBCPD], a
	inc d
	ld a, $40
	cp d
	jr nz, Jump_01_4764
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_01_4799:
	push af
	push bc
	push de
	push hl
	ldh a, [rSVBK]
	and $03
	push af
	ld a, $02
	ldh [rSVBK], a
	ld hl, $D7FF
	ld e, $3F
Jump_01_47AB:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_47AB
	ld a, e
	ldh [rBCPS], a
	ldh a, [rBCPD]
	ld [hld], a
	dec e
	ld a, e
	cp $FF
	jr nz, Jump_01_47AB
	pop af
	ldh [rSVBK], a
	ld a, $01
	ld [$C6D1], a
	call Func_3A2F
	ld e, $1F
Jump_01_47CA:
	xor a
	ld [wVBlankPending], a
Jump_01_47CE:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_47CE
	xor a
	ld [wVBlankPending], a
	call Audio_Update
	call Func_3A52
	dec e
	ld a, e
	cp $FF
	jr nz, Jump_01_47CA
	pop hl
	pop de
	pop bc
	pop af
	ret

MACRO screen_mode
	db \1, 0
	dw \2, \3, 0
ENDM

MACRO menu_state
	db \1, \2, \3
	dw \4
ENDM

MACRO menu_choice
	db \1, \2
	dw \3
	db \4, \5
	ds 10, 0
ENDM

ScreenModeTable:
	screen_mode $2D, Func_2D_54FA, Func_2D_5552
	screen_mode $2A, Func_2A_61D8, Func_2A_6230
	screen_mode $2C, Func_2C_4000, Func_2C_4058
	screen_mode $2C, Func_2C_5ED3, Func_2C_5F2B
	screen_mode $2B, Func_2B_6E6C, Func_2B_6EC4
	screen_mode $2C, Func_2C_4B3A, Func_2C_4B92
	screen_mode $2C, Func_2C_5F9F, Func_2C_5FF7
	screen_mode $2B, Func_2B_4000, Func_2B_4058
	screen_mode $2D, Func_2D_4000, Func_2D_4058
	screen_mode $2B, Func_2B_5BDA, Func_2B_5C32
	screen_mode $2B, Func_2B_5BDA, Func_2B_5C32
	screen_mode $2C, Func_2C_55C4, Func_2C_561C
	screen_mode $2A, Func_2A_6A22, Func_2A_6A7A

	db $C9

MenuState00:
	menu_state $00, $00, $00, HandleMenuState00Input
	menu_choice $00, $00, MenuState00, $00, $00
	menu_choice $01, $0F, 0, $00, $05
	menu_choice $02, $00, MenuState05, $00, $07
	menu_choice $03, $00, MenuState03, $00, $09
	menu_choice $04, $00, MenuState04, $00, $0B
	db $FF

MenuState04:
	menu_state $04, $01, $00, HandleMenuState04Input
	menu_choice $00, $00, MenuState00, $00, $00

OptionsMenuEntries:
	db $01, $02
	dw wMusicSetting
	db $00, $04
OptionsMusicText:
	db "MUSIC"
	ds 5, 0
	db $02, $03
	dw wControlSetting
	db $03, $08
OptionsControlText:
	db "CONTROL"
	ds 3, 0
	db $03, $04
	dw wSkillSetting
	db $03, $0C
OptionsSkillText:
	db "SKILL"
	ds 5, 0

	db $FF

MenuState03:
	menu_state $03, $03, $00, HandleMenuState03Input
	menu_choice $00, $00, MenuState00, $00, $14
	menu_choice $01, $00, MenuState03, $00, $14
	menu_choice $02, $0F, 0, $00, $14
	db $FF

MenuState05:
	menu_state $05, $04, $00, HandleMenuState05Input
	menu_choice $00, $00, MenuState00, $00, $14
	menu_choice $01, $03, wMenuState05Selection, $00, $14
	menu_choice $02, $00, MenuState06, $00, $14
	db $FF

MenuState06:
	menu_state $06, $0B, $00, HandleMenuState06Input
	menu_choice $00, $00, MenuState05, $00, $14
	menu_choice $01, $03, wMenuGridColumn, $00, $14
	menu_choice $02, $01, 0, $00, $14
	db $FF
OptionsOnText:
	db "ON ", 0
OptionsOffText:
	db "OFF", 0
ControlType1Text:
	db "1"
	ds 7, 0
ControlType2Text:
	db "2"
	ds 7, 0
ControlType3Text:
	db "3"
	ds 7, 0
SkillEasyText:
	db "EASY"
	ds 4, 0
SkillMediumText:
	db "MED "
	ds 4, 0
SkillHardText:
	db "HARD"
	ds 4, 0

	LOAD UNION "RAM code $D56A", WRAMX[$D56A] ; copied from $01:49CB

RAM_D56A:
	ld a, $01
	ldh [rSVBK], a
	ldh a, [rLCDC]
	res 5, a
	ldh [rLCDC], a
	ld a, $14
	ld [wMenuRepeatTimer], a
	ld a, $01
	ldh [rSVBK], a
	ld hl, RAM_D702
	ld a, l
	ld [$D561], a
	ld a, h
	ld [$D562], a
	xor a
	ld [$C6CD], a
	ld [wMenuGridColumn], a
	ld [wMenuGridRow], a
	ld [wMenuScrollDirection], a
	ld [wMenuCursorSpritesEnabled], a
	ld a, [$C6CF]
	ld [wSkillSetting], a
	call Func_01_4A62
	ld a, [$C6B5]
	ld [wMenuPreviousButtons], a
	call Func_01_4B4A
	call Func_0781
	ld a, $01
	ld [wMenuActive], a
	ld [$D550], a
	ld hl, $4855
	ld a, l
	ld [wMenuState], a
	ld [wMenuRenderedState], a
	ld a, h
	ld [wMenuState + 1], a
	ld [wMenuRenderedState + 1], a
	call Func_01_4E90
	call RAM_D9CB
	call Func_01_5377
	call Func_01_6AEF
	ld a, $01
	ld [$D556], a
	xor a
	call Func_01_4C15
	ld a, $00
	call ScreenTable_CallInit
	ld a, $01
	ld [rROMB0], a
	ld a, $00
	ld bc, $0020
	call ScreenTable_CallUpdate
	ld a, $01
	ld [rROMB0], a
	ld a, $01
	ld e, $01
	call Func_01_4D15
	call Func_01_4C15
	call Func_01_5427
	ret

	ENDL
	db $00

Func_01_4A62:
	ld d, $05
	ld hl, $DF00
	xor a
Jump_01_4A68:
	ld [hli], a
	dec d
	jr nz, Jump_01_4A68
	ret


	LOAD UNION "RAM code $D62A", WRAMX[$D62A] ; copied from $01:4A6D

RAM_D62A:
	push af
	push bc
	push de
	push hl
RAM_D62E:
	ld a, [wMenuActive]
	or a
	jr nz, RAM_D650
	pop hl
	pop de
	pop bc
	pop af
	ld a, [wMusicSetting]
	ld [$C92E], a
	ld a, [wControlSetting]
	ld [$C92F], a
	ld a, [wSkillSetting]
	ld [$C6CF], a
	ld a, $01
	ld [rROMB0], a
	ret

RAM_D650:
	ld a, [wMenuState]
	ld b, a
	ld a, [wMenuRenderedState]
	cp b
	jr nz, RAM_D664
	ld a, [wMenuState + 1]
	ld b, a
	ld a, [wMenuRenderedState + 1]
	cp b
	jr z, RAM_D6C7
RAM_D664:
	call Func_06F8
	call Func_01_5400
	ld a, [wMenuState]
	ld l, a
	ld a, [wMenuState + 1]
	ld h, a
	ld a, $01
	ld [$D550], a
	call Func_01_4E90
	ld a, $00
	ldh [rSCX], a
	ld a, $01
	ld [$D556], a
	xor a
	call Func_01_4C15
	ld a, [wMenuState]
	ld l, a
	ld a, [wMenuState + 1]
	ld h, a
	ld a, $01
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	call ScreenTable_CallInit
	ld a, $01
	ld [rROMB0], a
	ld a, [hl]
	ld bc, $0020
	call ScreenTable_CallUpdate
	ld a, $01
	ld [rROMB0], a
	call Func_01_5427
	call Func_01_5448
	ld a, $01
RAM_D6B4:
	call Func_01_4FE0
	cp $FF
	jr nz, RAM_D6B4
	ld a, [wMenuState]
	ld [wMenuRenderedState], a
	ld a, [wMenuState + 1]
	ld [wMenuRenderedState + 1], a
RAM_D6C7:
	call Audio_Update
	xor a
	ld [wVBlankPending], a
RAM_D6CE:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, RAM_D6CE
	xor a
	ld [wVBlankPending], a
	ld a, $00
	call Func_01_4C15
	ld a, [$D555]
	or a
	jp nz, RAM_D62E
	call Func_01_54FA
	ld bc, RAM_D702
	push bc
	ld a, [wMenuState]
	ld l, a
	ld a, [wMenuState + 1]
	ld h, a
	ld a, $03
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

RAM_D702:
	jp RAM_D62E

	ret
	ENDL
	db $00

Func_01_4B4A:
	di
	ld hl, $4B72
	ld bc, $C729
	ld de, $0024
	call CopyBytesShort
	ld hl, $4B96
	ld bc, $C7F1
	ld de, $007F
	call CopyBytesShort
	ldh a, [rSTAT]
	set 3, a
	res 6, a
	ldh [rSTAT], a
	ld a, $03
	ldh [rIE], a
	ei
	nop
	ret


	LOAD UNION "RAM code $C729", WRAM0[$C729] ; copied from $01:4B72

RAM_C729_01_4B72:
	push af
	push hl
	push bc
	ld a, [$D556]
	or a
	jr nz, RAM_C738
	ld a, $08
	ldh [rSCY], a
	jr RAM_C749
RAM_C738:
	ldh a, [rLY]
	ld b, $00
	ld c, a
	sla c
	rl b
	ld hl, $D9FB
	add hl, bc
	ld a, [hli]
	ld a, [hl]
	ldh [rSCY], a
RAM_C749:
	pop bc
	pop hl
	pop af
	reti
	ENDL

	LOAD UNION "RAM code $C7F1", WRAM0[$C7F1] ; copied from $01:4B96

RAM_C7F1_01_4B96:
	push af
	push de
	push bc
	push hl
	ld a, [$D9FC]
	ldh [rSCY], a
	ldh a, [rSVBK]
	and $03
	push af
	ld a, $01
	ldh [rSVBK], a
	ld a, [wMenuCursorSpritesEnabled]
	or a
	jr z, RAM_C828
	ld a, [$D553]
	add a, $10
	ld [$FE00], a
	ld [$FE04], a
	ld [$FE10], a
	ld [$FE14], a
	add a, $08
	ld [$FE08], a
	ld [$FE0C], a
	ld [$FE18], a
	ld [$FE1C], a
RAM_C828:
	ldh a, [rLCDC]
	res 4, a
	ldh [rLCDC], a
	ld a, [$C6B7]
	and $01
	jr z, RAM_C844
	call Func_0A59
	ld a, [$C6B5]
	and $F0
	cp $F0
	jr nz, RAM_C844
	jp Jump_00DA
RAM_C844:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_5619
	pop af
	ld [rROMB0], a
	ld a, [$C6B7]
	inc a
	ld [$C6B7], a
	ld a, [$C6B8]
	adc a, $00
	ld [$C6B8], a
	ld a, $01
	ld [wVBlankPending], a
	pop af
	ldh [rSVBK], a
	pop hl
	pop bc
	pop de
	pop af
	reti
	ENDL

Func_01_4C15:
	push af
	push bc
	push de
	push hl
	ld d, a
	ld a, $01
	ld [$D555], a
	call Func_01_69AB
	or a
	jr z, Jump_01_4C2A
	pop hl
	pop de
	pop bc
	pop af
	ret

Jump_01_4C2A:
	ld a, d
	or a
	jr nz, Jump_01_4C49
	ld a, [$D554]
	ld b, a
	ld a, [$D553]
	cp b
	jr z, Jump_01_4C77
	jr c, Jump_01_4C44
	sub $01
	jr nc, Jump_01_4C3F
	xor a
Jump_01_4C3F:
	ld [$D553], a
	jr Jump_01_4C49

Jump_01_4C44:
	add a, $01
	ld [$D553], a
Jump_01_4C49:
	ld a, $01
	ld [$D555], a
	ld hl, $D9FB
	ld d, $00
	ld e, $08
Jump_01_4C55:
	ld a, $00
	ld [hli], a
	ld a, [$D553]
	cp d
	jr nc, Jump_01_4C6A
	bit 0, d
	jr nz, Jump_01_4C6A
	dec e
	ld a, e
	cp $FF
	jr nz, Jump_01_4C6A
	ld e, $00
Jump_01_4C6A:
	ld a, e
	ld [hli], a
	inc d
	ld a, d
	cp $FF
	jr nz, Jump_01_4C55
	pop hl
	pop de
	pop bc
	pop af
	ret

Jump_01_4C77:
	ld a, $00
	ld [$D555], a
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_01_4C81:
	push de
	ld d, a
	ld a, [wMenuState]
	ld l, a
	ld a, [wMenuState + 1]
	ld h, a
	ld a, $05
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, d
	or a
	jr z, Jump_01_4CA8
	ld d, a
Jump_01_4C98:
	ld a, $10
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	cp $FF
	jr z, Jump_01_4CA8
	dec d
	jr nz, Jump_01_4C98
Jump_01_4CA8:
	pop de
	ret


Func_01_4CAA:
	call Func_01_4C81
	push hl
	ld a, $01
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	cp $01
	jr nz, Jump_01_4CDD
	xor a
	ld [wMenuActive], a
	ld a, [wMenuState05Selection]
	ld [$CD08], a
	ld a, [wMenuGridRow]
	ld b, a
	add a, a
	add a, b
	ld b, a
	ld a, [wMenuGridColumn]
	add a, b
	ld [$CA06], a
	call Func_300A
	call Func_3004
	pop hl
	jr Jump_01_4D14

Jump_01_4CDD:
	cp $0F
	jr nz, Jump_01_4CFD
	ld a, [$C6CD]
	cp $02
	jr z, Jump_01_4CF7
	ld a, $00
	ld [$C6CD], a
	xor a
	ld [$CA06], a
	call Func_300A
	call Func_3004
Jump_01_4CF7:
	xor a
	ld [wMenuActive], a
	pop hl
	ret

Jump_01_4CFD:
	pop hl
	ld a, $02
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld [wMenuState], a
	ld a, [hl]
	ld [wMenuState + 1], a
	ld a, $01
	ld [$D550], a
Jump_01_4D14:
	ret


Func_01_4D15:
	call Func_01_4C81
	cp $FF
	jr nz, Jump_01_4D20
	ld a, e
	call Func_01_4C81
Jump_01_4D20:
	ld [$D550], a
	ld a, $05
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	add a, a
	add a, a
	add a, a
	ld [$D554], a
	ret


HandleMenuState00Input:
	bit 7, e
	jr nz, Jump_01_4D4C
	bit 6, e
	jr nz, Jump_01_4D4C
	bit 5, e
	jr nz, Jump_01_4D70
	bit 4, e
	jr nz, Jump_01_4D4D
	bit 3, e
	jr nz, Jump_01_4D75
	bit 2, e
	jr nz, Jump_01_4D81
	ret

Jump_01_4D4C:
	ret

Jump_01_4D4D:
	ld e, $07
	call Audio_QueueSound
	ld a, [$D550]
	call Func_01_4C81
	ld a, $01
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	cp $01
	jr nz, Jump_01_4D6B
	ld a, $00
	ld [wMenuActive], a
	ret

Jump_01_4D6B:
	ld a, [$D550]
	jr Jump_01_4D71

Jump_01_4D70:
	ret

Jump_01_4D71:
	call Func_01_4CAA
	ret

Jump_01_4D75:
	ld e, $0A
	call Audio_QueueSound
	ld a, [$D550]
	ld e, a
	inc a
	jr Jump_01_4D90

Jump_01_4D81:
	ld e, $0A
	call Audio_QueueSound
	ld a, [$D550]
	dec a
	jr nz, Jump_01_4D8E
	ld a, $01
Jump_01_4D8E:
	jr Jump_01_4D90

Jump_01_4D90:
	call Func_01_4D15
	ret


HandleMenuState04Input:
	bit 7, e
	jr nz, Jump_01_4DC1
	bit 6, e
	jr nz, Jump_01_4DC1
	bit 5, e
	jr nz, Jump_01_4DC2
	bit 4, e
	jr nz, Jump_01_4DCB
	bit 3, e
	jr nz, Jump_01_4DE5
	bit 2, e
	jr nz, Jump_01_4DF1
	bit 1, e
	jr nz, Jump_01_4DCD
	bit 0, e
	jr nz, Jump_01_4DD9
Jump_01_4DB4:
	call Func_01_4E35
	ld a, $01
Jump_01_4DB9:
	call Func_01_5013
	cp $FF
	jr nz, Jump_01_4DB9
	ret

Jump_01_4DC1:
	ret

Jump_01_4DC2:
	call Func_01_4E35
	ld a, $00
	call Func_01_4CAA
	ret

Jump_01_4DCB:
	jr Jump_01_4DC2

Jump_01_4DCD:
	ld e, $0A
	call Audio_QueueSound
	ld b, $FF
	call Func_01_4E04
	jr Jump_01_4DB4

Jump_01_4DD9:
	ld e, $0A
	call Audio_QueueSound
	ld b, $01
	call Func_01_4E04
	jr Jump_01_4DB4

Jump_01_4DE5:
	ld e, $0B
	call Audio_QueueSound
	ld a, [$D550]
	ld e, a
	inc a
	jr Jump_01_4E00

Jump_01_4DF1:
	ld e, $0B
	call Audio_QueueSound
	ld a, [$D550]
	dec a
	jr nz, Jump_01_4DFE
	ld a, $01
Jump_01_4DFE:
	jr Jump_01_4E00

Jump_01_4E00:
	call Func_01_4D15
	ret


Func_01_4E04:
	push bc
	ld a, [$D550]
	call Func_01_4EEC
	pop bc
	ld a, e
	cp $02
	jr nz, Jump_01_4E17
	ld a, [hl]
	xor $01
	ld [hl], a
	jr Jump_01_4E2E

Jump_01_4E17:
	ld a, e
	cp $03
	jr z, Jump_01_4E20
	cp $04
	jr nz, Jump_01_4E2E
Jump_01_4E20:
	ld a, [hl]
	add a, b
	cp d
	jr nz, Jump_01_4E27
	ld a, $00
Jump_01_4E27:
	cp $FF
	jr nz, Jump_01_4E2D
	dec d
	ld a, d
Jump_01_4E2D:
	ld [hl], a
Jump_01_4E2E:
	ret

RuntimeCallbackTable:
	dw Func_364E
	dw Func_367F
	dw Func_36AF

Func_01_4E35:
	ld a, [wMusicSetting]
	ld [wMusicEnabled], a
	and a
	jr nz, Jump_01_4E40
	ldh [rNR51], a
Jump_01_4E40:
	ld a, [wControlSetting]
	add a, a
	ld hl, RuntimeCallbackTable
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	ld [wRuntimeCallback], a
	ld a, h
	ld [wRuntimeCallback + 1], a
	ld a, [wSkillSetting]
	ld [$C6CF], a
	ret


Func_01_4E60:
	ld a, [wMusicEnabled]
	ld [wMusicSetting], a
	ld hl, RuntimeCallbackTable
	ld e, $00
Jump_01_4E6B:
	ld a, [hli]
	ld b, a
	ld a, [wRuntimeCallback]
	cp b
	jr z, Jump_01_4E77
	inc e
	inc hl
	jr Jump_01_4E6B

Jump_01_4E77:
	ld a, [hli]
	ld b, a
	ld a, [wRuntimeCallback + 1]
	cp b
	jr z, Jump_01_4E85
	inc e
	ld a, e
	cp $02
	jr Jump_01_4E6B

Jump_01_4E85:
	ld a, e
	ld [wControlSetting], a
	ld a, [$C6CF]
	ld [wSkillSetting], a
	ret


Func_01_4E90:
	ld a, [wMenuState]
	ld l, a
	ld a, [wMenuState + 1]
	ld h, a
	ld a, [hl]
	cp $03
	jr nz, Jump_01_4E9D
Jump_01_4E9D:
	xor a
	ld [$D556], a
	ld a, $01
	call Func_01_4C81
	ld a, $05
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	add a, a
	add a, a
	add a, a
	ld [$D553], a
	ld [$D554], a
	ld a, $01
	call Func_01_4C15
	xor a
	ld [wVBlankPending], a
Jump_01_4EC1:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_4EC1
	xor a
	ld [wVBlankPending], a
	ret


Func_01_4ECF:
	push af
	push bc
	push de
	push hl
	ld bc, $4E91
	ld d, $07
	ld e, $00
	call Func_0514
	ld bc, $001F
	ld d, $07
	ld e, $03
	call Func_0514
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_01_4EEC:
	call Func_01_4C81
	cp $FF
	ret z
	push af
	inc hl
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hl]
	ld d, a
	ld h, b
	ld l, c
	pop af
	ret

	db $01, $00, $02, $00, $04, $00, $08, $00, $16, $00, $32, $00, $64, $00, $28, $01
	db $01, $00, $00, $02, $00, $00, $04, $00, $00, $08, $00, $00, $16, $00, $00, $32
	db $00, $00, $64, $00, $00, $28, $01, $00, $56, $02, $00, $12, $05, $00, $24, $10
	db $00, $48, $20, $00, $96, $40, $00, $92, $81, $00, $84, $63, $01, $68, $27, $03
	db $01, $00, $00, $00, $00, $02, $00, $00, $00, $00, $04, $00, $00, $00, $00, $08
	db $00, $00, $00, $00, $16, $00, $00, $00, $00, $32, $00, $00, $00, $00, $64, $00
	db $00, $00, $00, $28, $01, $00, $00, $00, $56, $02, $00, $00, $00, $12, $05, $00
	db $00, $00, $24, $10, $00, $00, $00, $48, $20, $00, $00, $00, $96, $40, $00, $00
	db $00, $92, $81, $00, $00, $00, $84, $63, $01, $00, $00, $68, $27, $03, $00, $00
	db $36, $55, $06, $00, $00, $72, $10, $13, $00, $00, $44, $21, $26, $00, $00, $88
	db $42, $52, $00, $00, $76, $85, $04, $01, $00, $52, $71, $09, $02, $00, $04, $43
	db $19, $04, $00, $08, $86, $38, $08, $00, $16, $72, $77, $16, $00, $32, $44, $55
	db $33, $00, $64, $88, $10, $67, $00, $28, $77, $21, $34, $01, $56, $54, $43, $68
	db $02, $12, $09, $87, $36, $05, $24, $18, $74, $73, $10, $48, $36, $48, $47, $21

Func_01_4FE0:
	call Func_01_4C81
	push af
	cp $FF
	jr nz, Jump_01_4FEA
	pop af
	ret

Jump_01_4FEA:
	push hl
	ld a, $05
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	inc a
	ld [$C8E0], a
	ld a, $04
	ld [$C8DF], a
	pop hl
	ld a, $06
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	or a
	jr z, Jump_01_5010
	call Func_01_4ECF
	call Func_2ACE
Jump_01_5010:
	pop af
	inc a
	ret


Func_01_5013:
	call Func_01_4C81
	push af
	cp $FF
	jr nz, Jump_01_501D
	pop af
	ret

Jump_01_501D:
	push hl
	ld a, $05
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	inc a
	ld [$C8E0], a
	ld a, $0C
	ld [$C8DF], a
	pop hl
	ld a, $01
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, e
	cp $02
	jr nz, Jump_01_5051
	ld a, [hl]
	or a
	jr nz, Jump_01_504C
	ld hl, $4997
	jr Jump_01_5079

Jump_01_504C:
	ld hl, $4993
	jr Jump_01_5079

Jump_01_5051:
	ld a, e
	cp $03
	jr nz, Jump_01_5066
	ld a, [hl]
	add a, a
	add a, a
	add a, a
	ld hl, $499B
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	jr Jump_01_5079

Jump_01_5066:
	ld a, e
	cp $04
	jr nz, Jump_01_507C
	ld a, [hl]
	add a, a
	add a, a
	add a, a
	ld hl, $49B3
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
Jump_01_5079:
	call Func_2ACE
Jump_01_507C:
	pop af
	inc a
	ret


HandleMenuState03Input:
	bit 7, e
	jr nz, Jump_01_50B1
	bit 6, e
	jr nz, Jump_01_50B1
	bit 5, e
	jr nz, Jump_01_50B2
	bit 4, e
	jr nz, Jump_01_50BB
	bit 3, e
	jr nz, Jump_01_50C4
	bit 2, e
	jr nz, Jump_01_50D6
	bit 1, e
	jr nz, Jump_01_50E7
	bit 0, e
	jr nz, Jump_01_50FE
	ld c, $00
	ld b, $0B
	call Func_01_6873
	ld a, [$C6B7]
	and $03
	jr nz, Jump_01_50B0
	call Func_01_6762
Jump_01_50B0:
	ret

Jump_01_50B1:
	ret

Jump_01_50B2:
	call Func_01_6AEF
	ld a, $00
	call Func_01_4CAA
	ret

Jump_01_50BB:
	ld e, $07
	call Audio_QueueSound
	call Func_01_5126
	ret

Jump_01_50C4:
	ld a, [$DF07]
	dec a
	bit 5, a
	jr z, Jump_01_50CE
	ld a, $1F
Jump_01_50CE:
	ld [$DF07], a
	call Func_01_6940
	jr Jump_01_5114

Jump_01_50D6:
	ld a, [$DF07]
	inc a
	bit 5, a
	jr z, Jump_01_50DF
	xor a
Jump_01_50DF:
	ld [$DF07], a
	call Func_01_6940
	jr Jump_01_5114

Jump_01_50E7:
	ld e, $0B
	call Audio_QueueSound
	ld a, [$DF0B]
	dec a
	cp $FF
	jr nz, Jump_01_50F6
	ld a, $04
Jump_01_50F6:
	ld [$DF0B], a
	call Func_01_6A72
	jr Jump_01_5114

Jump_01_50FE:
	ld e, $0B
	call Audio_QueueSound
	ld a, [$DF0B]
	inc a
	cp $05
	jr nz, Jump_01_510C
	xor a
Jump_01_510C:
	ld [$DF0B], a
	call Func_01_6A72
	jr Jump_01_5114

Jump_01_5114:
	ld c, $00
	ld b, $0B
	call Func_01_6873
	ld a, [$C6B7]
	and $03
	jr nz, Jump_01_5125
	call Func_01_6762
Jump_01_5125:
	ret


Func_01_5126:
	ld hl, $DF00
	ld bc, $C93B
	ld e, $05
	call CopyBytesShort
	call Func_01_6D99
	call Func_01_6C24
	or a
	jr nz, Jump_01_5164
	call Func_01_6AEF
	call Func_01_7981
Jump_01_5140:
	xor a
	ld [wVBlankPending], a
Jump_01_5144:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_5144
	xor a
	ld [wVBlankPending], a
	call Audio_Update
	ld a, [$C6B5]
	or a
	jr z, Jump_01_5140
	xor a
	ld [wMenuRenderedState], a
	ld a, $01
	call Func_01_4CAA
	ret

Jump_01_5164:
	ld a, [$C939]
	ld [$CA06], a
	ld a, [$C938]
	ld [$CD02], a
	ld a, [$C936]
	ld c, a
	ld a, [$C937]
	ld b, a
	call Func_3BF7
	call Func_01_518D
	ld a, $02
	ld [$C6CD], a
	xor a
	ld [wMenuRenderedState], a
	ld a, $02
	call Func_01_4CAA
	ret


Func_01_518D:
	ld hl, $418F
	ld a, [$C6D0]
	inc a
	ld c, a
	add a, a
	add a, a
	dec a
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hld]
	ld b, a
	ld a, [$CD07]
	cp b
	jr c, Jump_01_51CB
	jr nz, Jump_01_51C5
	ld a, [hld]
	ld b, a
	ld a, [$CD06]
	cp b
	jr c, Jump_01_51CB
	jr nz, Jump_01_51C5
	ld a, [hld]
	ld b, a
	ld a, [$CD05]
	cp b
	jr c, Jump_01_51CB
	jr nz, Jump_01_51C5
	ld a, [hld]
	ld b, a
	ld a, [$CD04]
	cp b
	jr c, Jump_01_51CB
Jump_01_51C5:
	ld a, c
	ld [$C6D0], a
	jr Func_01_518D

Jump_01_51CB:
	ret


	LOAD UNION "RAM code $D70A", WRAMX[$D70A] ; copied from $01:51CC

HandleMenuState05Input:
	ld a, e
	or a
	jr z, RAM_D733
	push de
	call Func_3CD9
	pop de
	bit 7, e
	jr nz, RAM_D734
	bit 6, e
	jr nz, RAM_D735
	bit 5, e
	jr nz, RAM_D736
	bit 4, e
	jr nz, RAM_D73B
	bit 3, e
	jr nz, RAM_D741
	bit 2, e
	jr nz, RAM_D742
	bit 1, e
	jr nz, RAM_D743
	bit 0, e
	jr nz, RAM_D783
RAM_D733:
	ret

RAM_D734:
	ret

RAM_D735:
	ret

RAM_D736:
	xor a
	call Func_01_4CAA
	ret

RAM_D73B:
	ld a, $02
	call Func_01_4CAA
	ret

RAM_D741:
	ret

RAM_D742:
	ret

RAM_D743:
	ld e, $13
	call Audio_QueueSound
	ld a, $02
	ld [wMenuScrollDirection], a
	call Func_01_7CA2
	xor a
	ld [wMenuScrollDirection], a
	call Func_3960
	ld a, [wMenuState05Selection]
	dec a
	cp $FF
	jr nz, RAM_D761
	ld a, $02
RAM_D761:
	ld [wMenuState05Selection], a
	call RAM_D7CB
	call Func_01_7BC5
	ld hl, $DC03
	ld a, l
	ld [$D564], a
	ld a, h
	ld [$D565], a
	ld a, $01
	ld [wMenuScrollDirection], a
	call Func_01_7C3F
	xor a
	ld [wMenuScrollDirection], a
	jr RAM_D7C3

RAM_D783:
	ld e, $13
	call Audio_QueueSound
	ld a, $02
	ld [wMenuScrollDirection], a
	call Func_01_7CEF
	xor a
	ld [wMenuScrollDirection], a
	call Func_3960
	ld a, [wMenuState05Selection]
	inc a
	cp $03
	jr nz, RAM_D7A1
	ld a, $00
RAM_D7A1:
	ld [wMenuState05Selection], a
	call RAM_D7CB
	call Func_01_7BC5
	ld hl, $DC03
	ld a, l
	ld [$D564], a
	ld a, h
	ld [$D565], a
	ld a, $01
	ld [wMenuScrollDirection], a
	call Func_01_7BE0
	xor a
	ld [wMenuScrollDirection], a
	jr RAM_D7C3

RAM_D7C3:
	ret
	ENDL
	db $00

HandleMenuState06Input:
	ld a, e
	or a
	jr z, Jump_01_52B2
	push de
	call Func_3CD9
	pop de
	bit 7, e
	jr nz, Jump_01_52B3
	bit 6, e
	jr nz, Jump_01_52B4
	bit 5, e
	jr nz, Jump_01_52B5
	bit 4, e
	jr nz, Jump_01_52D7
	bit 1, e
	jr nz, Jump_01_52F2
	bit 0, e
	jr nz, Jump_01_52FD
	bit 3, e
	jp nz, Jump_01_5308
	bit 2, e
	jp nz, Jump_01_5315
Jump_01_52B2:
	ret

Jump_01_52B3:
	ret

Jump_01_52B4:
	ret

Jump_01_52B5:
	ld e, $08
	call Audio_QueueSound
	call Func_01_61CE
	call Func_01_4B4A
	call RAM_D130
	call Func_01_5377
	call Func_01_6AEF
	call Func_01_4A62
	xor a
	ld [wMenuGridRow], a
	ld [wMenuGridColumn], a
	call Func_01_4CAA
	ret

Jump_01_52D7:
	ld e, $07
	call Audio_QueueSound
	ld a, $01
	ld [$C6CD], a
	ld a, [wMenuGridRow]
	ld b, a
	ld a, [wMenuGridColumn]
	ld c, a
	call Func_01_6247
	ld a, $02
	call Func_01_4CAA
	ret

Jump_01_52F2:
	call Func_01_5323
	ld a, [wMenuGridRow]
	dec a
	call Func_01_5340
	ret

Jump_01_52FD:
	call Func_01_5323
	ld a, [wMenuGridRow]
	inc a
	call Func_01_5340
	ret

Jump_01_5308:
	ld e, $0B
	call Audio_QueueSound
	ld a, [wMenuGridColumn]
	inc a
	call Func_01_535D
	ret

Jump_01_5315:
	ld e, $0B
	call Audio_QueueSound
	ld a, [wMenuGridColumn]
	dec a
	call Func_01_535D
	ret

	db $C9

Func_01_5323:
	push af
	push bc
	push de
	push hl
Jump_01_5327:
	call Func_0421
	and $07
	cp $06
	jr nc, Jump_01_5327
	add a, $81
	ld e, a
	call Audio_QueueSound
	ld e, $21
	call Audio_QueueSound
	pop hl
	pop de
	pop bc
	pop af
	ret

Func_01_5340:
	cp $FF
	jr nz, Jump_01_5348
	ld a, $04
	jr Jump_01_534E
Jump_01_5348:
	cp $05
	jr nz, Jump_01_534E
	ld a, $00
Jump_01_534E:
	ld b, a
	ld [wMenuGridRow], a
	ld a, [wMenuGridColumn]
	ld c, a
	call Func_01_61CE
	call Func_01_6233
	ret

Func_01_535D:
	cp $FF
	jr nz, Jump_01_5365
	ld a, $00
	jr nz, Jump_01_536B
Jump_01_5365:
	cp $03
	jr nz, Jump_01_536B
	ld a, $02
Jump_01_536B:
	ld c, a
	ld [wMenuGridColumn], a
	ld a, [wMenuGridRow]
	ld b, a
	call Func_01_6367
	ret

Func_01_5377:
	xor a
	ldh [rVBK], a
	ld bc, $58DF
	ld a, $80
	ld e, $78
	ld d, $08
	call Func_0622
	ld bc, $595F
	ld hl, $FE00
	ld d, $08
Jump_01_538E:
	ldh a, [rSTAT]
	and $02
	jr z, Jump_01_538E
Jump_01_5394:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_5394
	ld a, $AA
	ld [hli], a
	ld [hli], a
	ld a, [bc]
	ld [hli], a
	ld a, $00
	ld [hli], a
	inc bc
	dec d
	jr nz, Jump_01_538E
	ld a, $07
	ld e, a
Jump_01_53AA:
	ldh a, [rSTAT]
	and $02
	jr z, Jump_01_53AA
Jump_01_53B0:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_53B0
	ld a, e
	ld [$FE01], a
	ld a, e
	ld [$FE09], a
	add a, $08
	ld e, a
	ld a, e
	ld [$FE05], a
	ld a, e
	ld [$FE0D], a
	ld a, $98
	ld e, a
Jump_01_53CC:
	ldh a, [rSTAT]
	and $02
	jr z, Jump_01_53CC
Jump_01_53D2:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_53D2
	ld a, e
	ld [$FE11], a
	ld a, e
	ld [$FE19], a
	add a, $08
	ld e, a
	ld a, e
	ld [$FE15], a
	ld a, e
	ld [$FE1D], a
	ldh a, [rLCDC]
	or $02
	ldh [rLCDC], a
	ld hl, $5967
	ld b, $00
	call Func_0553
	call Func_01_696E
	call Func_01_6A1D
	ret


Func_01_5400:
	push af
	push bc
	push de
	push hl
	xor a
	ld [wMenuCursorSpritesEnabled], a
	ld e, $08
	ld bc, $0004
	ld hl, $FE00
Jump_01_5410:
	ldh a, [rSTAT]
	and $02
	jr z, Jump_01_5410
Jump_01_5416:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_5416
	xor a
	ld [hl], a
	add hl, bc
	dec e
	jr nz, Jump_01_5410
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_01_5427:
	ld a, $01
	ld [wMenuCursorSpritesEnabled], a
	xor a
	ld [wVBlankPending], a
Jump_01_5430:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_5430
	xor a
	ld [wVBlankPending], a
	ret


Func_01_543E:
	ld a, l
	sub c
	ld l, a
	jr nc, Jump_01_5444
	inc b
Jump_01_5444:
	ld a, h
	sub b
	ld h, a
	ret


Func_01_5448:
	ld hl, $5967
	ld b, $00
	call Func_0553
	ld a, [wMenuState]
	ld l, a
	ld a, [wMenuState + 1]
	ld h, a
	ld a, [hl]
	cp $03
	jr z, Jump_01_5480
	cp $05
	jr z, Jump_01_5493
	cp $06
	jr z, Jump_01_54C7
	call Func_01_5377
	ld a, $01
	ld [wMenuCursorSpritesEnabled], a
	ld a, $00
	ldh [rSCX], a
	ld a, $01
	ld [$D556], a
	call RAM_D9CB
	call Func_01_6AEF
	call Func_01_4E60
	ret

Jump_01_5480:
	ld a, $00
	ld [$D556], a
	call Func_01_66F6
	call Func_01_6A8A
	call Func_01_6751
	call Func_01_6746
	jr Jump_01_54E8

Jump_01_5493:
	call Func_3960
	ld a, $01
	ld [wMenuState05Selection], a
	call RAM_D7CB
	call Func_01_7BC5
	ld hl, $DC03
	ld a, l
	ld [$D564], a
	ld a, h
	ld [$D565], a
	ld a, $01
	ld [wMenuScrollDirection], a
	call Func_01_7C3F
	xor a
	ld [wMenuScrollDirection], a
	ld a, $00
	ld [wMenuCursorSpritesEnabled], a
	ld e, $00
	ldh a, [rLCDC]
	set 1, a
	ldh [rLCDC], a
	jr Jump_01_54E8

Jump_01_54C7:
	ld e, $01
	ld de, $0000
	call Func_01_5BF1
	ld a, [wMenuGridRow]
	ld b, a
	ld a, [wMenuGridColumn]
	ld c, a
	call Func_01_6233
Jump_01_54DA:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_54DA
	ldh a, [rLCDC]
	bit 1, a
	ldh [rLCDC], a
	jr Jump_01_54E8

Jump_01_54E8:
	xor a
	ld [wVBlankPending], a
Jump_01_54EC:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_54EC
	xor a
	ld [wVBlankPending], a
	ret


Func_01_54FA:
	ld a, [wMenuRepeatTimer]
	ld c, a
	ld a, [$C6B5]
	ld d, a
	ld a, [wMenuPreviousButtons]
	ld e, $00
	bit 7, d
	jr z, Jump_01_551E
	bit 7, a
	jr nz, Jump_01_5515
	set 7, e
	set 7, a
	jr Jump_01_5528

Jump_01_5515:
	dec c
	jr nz, Jump_01_551C
	set 7, e
	ld c, $02
Jump_01_551C:
	jr Jump_01_5528

Jump_01_551E:
	bit 7, a
	jr z, Jump_01_5528
	res 7, a
	ld c, $14
	jr Jump_01_5528

Jump_01_5528:
	bit 6, d
	jr z, Jump_01_553F
	bit 6, a
	jr nz, Jump_01_5536
	set 6, e
	set 6, a
	jr Jump_01_5549

Jump_01_5536:
	dec c
	jr nz, Jump_01_553D
	set 6, e
	ld c, $02
Jump_01_553D:
	jr Jump_01_5549

Jump_01_553F:
	bit 6, a
	jr z, Jump_01_5549
	res 6, a
	ld c, $14
	jr Jump_01_5549

Jump_01_5549:
	bit 5, d
	jr z, Jump_01_5560
	bit 5, a
	jr nz, Jump_01_5557
	set 5, e
	set 5, a
	jr Jump_01_556A

Jump_01_5557:
	dec c
	jr nz, Jump_01_555E
	set 5, e
	ld c, $02
Jump_01_555E:
	jr Jump_01_556A

Jump_01_5560:
	bit 5, a
	jr z, Jump_01_556A
	res 5, a
	ld c, $14
	jr Jump_01_556A

Jump_01_556A:
	bit 4, d
	jr z, Jump_01_5581
	bit 4, a
	jr nz, Jump_01_5578
	set 4, e
	set 4, a
	jr Jump_01_558B

Jump_01_5578:
	dec c
	jr nz, Jump_01_557F
	set 4, e
	ld c, $02
Jump_01_557F:
	jr Jump_01_558B

Jump_01_5581:
	bit 4, a
	jr z, Jump_01_558B
	res 4, a
	ld c, $14
	jr Jump_01_558B

Jump_01_558B:
	bit 2, d
	jr z, Jump_01_55A2
	bit 2, a
	jr nz, Jump_01_5599
	set 2, e
	set 2, a
	jr Jump_01_55AC

Jump_01_5599:
	dec c
	jr nz, Jump_01_55A0
	set 2, e
	ld c, $02
Jump_01_55A0:
	jr Jump_01_55AC

Jump_01_55A2:
	bit 2, a
	jr z, Jump_01_55AC
	res 2, a
	ld c, $14
	jr Jump_01_55AC

Jump_01_55AC:
	bit 3, d
	jr z, Jump_01_55C3
	bit 3, a
	jr nz, Jump_01_55BA
	set 3, e
	set 3, a
	jr Jump_01_55CD

Jump_01_55BA:
	dec c
	jr nz, Jump_01_55C1
	set 3, e
	ld c, $02
Jump_01_55C1:
	jr Jump_01_55CD

Jump_01_55C3:
	bit 3, a
	jr z, Jump_01_55CD
	res 3, a
	ld c, $14
	jr Jump_01_55CD

Jump_01_55CD:
	bit 1, d
	jr z, Jump_01_55E4
	bit 1, a
	jr nz, Jump_01_55DB
	set 1, e
	set 1, a
	jr Jump_01_55EE

Jump_01_55DB:
	dec c
	jr nz, Jump_01_55E2
	set 1, e
	ld c, $02
Jump_01_55E2:
	jr Jump_01_55EE

Jump_01_55E4:
	bit 1, a
	jr z, Jump_01_55EE
	res 1, a
	ld c, $14
	jr Jump_01_55EE

Jump_01_55EE:
	bit 0, d
	jr z, Jump_01_5607
	bit 0, a
	jr nz, Jump_01_55FE
	ld c, $14
	set 0, e
	set 0, a
	jr Jump_01_5611

Jump_01_55FE:
	dec c
	jr nz, Jump_01_5605
	set 0, e
	ld c, $02
Jump_01_5605:
	jr Jump_01_5611

Jump_01_5607:
	bit 0, a
	jr z, Jump_01_5611
	res 0, a
	ld c, $14
	jr Jump_01_5611

Jump_01_5611:
	ld [wMenuPreviousButtons], a
	ld a, c
	ld [wMenuRepeatTimer], a
	ret


Func_01_5619:
	ld a, [wMenuScrollDirection]
	or a
	jr z, Jump_01_565E
	ld d, a
	ld a, [$C924]
	ld e, a
	call Func_3A52
	ld a, d
	cp $01
	jr z, Jump_01_5630
	cp $02
	jr z, Jump_01_5647
Jump_01_5630:
	ld a, [$C924]
	inc a
	inc a
	ld [$C924], a
	cp $20
	jr c, Jump_01_565E
	ld a, $1F
	ld [$C924], a
	xor a
	ld [wMenuScrollDirection], a
	jr Jump_01_565E

Jump_01_5647:
	ld a, [$C924]
	dec a
	dec a
	ld [$C924], a
	cp $20
	jr c, Jump_01_565E
	ld a, $00
	ld [$C924], a
	xor a
	ld [wMenuScrollDirection], a
	jr Jump_01_565E

Jump_01_565E:
	ret


	LOAD UNION "RAM data $D7CA", WRAMX[$D7CA] ; copied from $01:565F
	db $C9
	ENDL
	db $00

	LOAD UNION "RAM code $D7CB", WRAMX[$D7CB] ; copied from $01:5661

RAM_D7CB:
	ld hl, $596D
	swap a
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld d, a
	ld [$DBFB], a
	ld a, [hli]
	ld [$DBFD], a
	ld a, [hli]
	ld [$DBFE], a
	ld a, [hli]
	ld [$DBFF], a
	ld a, [hli]
	ld [$DC00], a
	ld a, [hli]
	ld [$DC01], a
	ld a, [hli]
	ld [$DC02], a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld e, a
	ld l, c
	ld h, b
	call Func_3A88
	xor a
	ld [$C6D1], a
	call Func_3A2F
	ld a, $00
	ld [$C924], a
	ld a, [$DBFB]
	ld d, a
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, d
	ld [rROMB0], a
	ld hl, $DBFD
	ld a, [hli]
	ld c, a
	ld a, [hl]
	dec hl
	ld b, a
	xor a
	ldh [rVBK], a
	ld a, $88
	ld e, $00
	ld d, $80
	call Func_0622
	xor a
	ldh [rVBK], a
	ld a, [hli]
	ld c, a
	ld a, [hl]
	dec hl
	ld b, a
	push hl
	ld l, c
	ld h, b
	ld bc, $0800
	add hl, bc
	ld b, h
	ld c, l
	pop hl
	ld a, $90
	ld e, $00
	ld d, $80
	call Func_0622
	ld a, $01
	ldh [rVBK], a
	ld a, [hli]
	ld c, a
	ld a, [hl]
	dec hl
	ld b, a
	push hl
	ld l, c
	ld h, b
	ld bc, $1000
	add hl, bc
	ld b, h
	ld c, l
	pop hl
	ld a, $90
	ld e, $00
	ld d, $80
	call Func_0622
	pop af
	ld [rROMB0], a
	ld hl, $DBFB
	ld a, [hli]
	ld [$C953], a
	inc hl
	inc hl
	inc hl
	ld a, [hli]
	ld [$C94F], a
	ld a, [hli]
	ld [$C950], a
	ld a, [hli]
	ld [$C951], a
	ld a, [hli]
	ld [$C952], a
	ret

	ENDL
	db $00

	LOAD UNION "RAM code $D9CB", WRAMX[$D9CB] ; copied from $01:5718

RAM_D9CB:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $08
	ld [rROMB0], a
	ld a, $01
	ldh [rVBK], a
	ld e, $00
	ld d, $25
	ld a, $88
	ld bc, $6B85
	call Func_0622
	call Func_2AB9
	pop af
	ld [rROMB0], a
	ret

	ENDL
	db $00

	LOAD UNION "RAM code $D91B", WRAMX[$D91B] ; copied from $01:573A

RAM_D91B:
	ld a, [$C943]
	ld b, a
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, b
	ld [rROMB0], a
	ld a, [$C949]
	ld c, a
	ld b, $00
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	ld hl, $9800
	add hl, bc
	ld a, [$C948]
	add a, l
	ld l, a
	ld a, $12
	ld [$C94D], a
	ld a, [$C94A]
	ld [$C94C], a
	ld [$C94B], a
	ld a, [$C944]
	ld c, a
	ld a, [$C945]
	ld b, a
	ld a, [$C946]
	ld e, a
	ld a, [$C947]
	ld d, a
RAM_D968:
	ld a, [$C94B]
	ld [$C94C], a
RAM_D96E:
	ldh a, [rSTAT]
	and $02
	jr nz, RAM_D96E
	ld a, $01
	ldh [rVBK], a
	ld a, [de]
	ld [hl], a
	xor a
	ldh [rVBK], a
	ld a, [bc]
	ld [hli], a
	inc bc
	inc de
	ld a, [$C94C]
	dec a
	ld [$C94C], a
	jr nz, RAM_D96E
	push hl
	ld a, [$C94A]
	ld l, a
	ld a, $14
	sub l
	ld l, a
	ld a, a
	add a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	ld a, l
	ld a, a
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	pop hl
	push bc
	ld a, [$C94A]
	ld c, a
	ld a, $20
	sub c
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	pop bc
	ld a, [$C94D]
	dec a
	ld [$C94D], a
	jp nz, RAM_D968
	pop af
	ld [rROMB0], a
	ret

	ENDL

	LOAD UNION "RAM code $D88B", WRAMX[$D88B] ; copied from $01:57E1

RAM_D88B:
	ld hl, $C943
	ld a, [hli]
	ld b, a
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, b
	ld [rROMB0], a
	ld hl, $C949
	ld a, [hl]
	ld c, a
	ld b, $00
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	ld hl, $9800
	add hl, bc
	push hl
	ld a, $14
	ld [$C94C], a
	ld hl, $C94B
	ld a, [hl]
	ld [$C94D], a
	ld hl, $C943
	ld a, [hli]
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	pop hl
RAM_D8D1:
	ld a, $14
	ld [$C94C], a
RAM_D8D6:
	ldh a, [rSTAT]
	and $02
	jr z, RAM_D8D6
RAM_D8DC:
	ldh a, [rSTAT]
	and $02
	jr nz, RAM_D8DC
	ld a, $01
	ldh [rVBK], a
	ld a, [de]
	ld [hl], a
	xor a
	ldh [rVBK], a
	ld a, [bc]
	ld [hli], a
	inc bc
	inc de
	ld a, [$C94C]
	dec a
	ld [$C94C], a
	or a
	jr nz, RAM_D8D6
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [$C94D]
	dec a
	ld [$C94D], a
	or a
	jr nz, RAM_D8D1
	pop af
	ld [rROMB0], a
	ret

	ENDL
	db $00

Func_01_5867:
	ld de, $0000
	call Func_01_5BF1
	ld hl, $49CB
	ld de, $0096
	ld bc, $D56A
	call CopyBytes
	ld hl, $4A6D
	ld de, $00DC
	ld bc, $D62A
	call CopyBytes
	ld hl, $51CC
	ld de, $00BA
	ld bc, $D70A
	call CopyBytes
	ld hl, $565F
	ld de, $0001
	ld bc, $D7CA
	call CopyBytes
	ld hl, $5661
	ld de, $00B6
	ld bc, $D7CB
	call CopyBytes
	ld hl, $5718
	ld de, $0021
	ld bc, $D9CB
	call CopyBytes
	ld hl, $57E1
	ld de, $0085
	ld bc, $D88B
	call CopyBytes
	ld hl, $573A
	ld de, $00A7
	ld bc, $D91B
	call CopyBytes
	xor a
	ld [wVBlankPending], a
Jump_01_58D1:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_58D1
	xor a
	ld [wVBlankPending], a
	ret

	INCBIN "assets/bank_01/58DF.bin" ; $BE bytes

ScrollingTileRowDestinations:
	dw $9000, $9140, $9280, $93C0, $9500, $9640, $8800

; Each 16-byte scene record contains a graphics bank, a 255-tile source,
; 20x12 tile and attribute maps, a palette-table pointer and record count.
; The final six bytes of every record are reserved and zero.
SceneBackgroundDescriptors:
	db $33
	dw $51A0, $5ED0, $5FC0, $60B0
	db $04
	ds 6, 0
	db $31
	dw $6BA0, $7800, $78F0, $79E0
	db $05
	ds 6, 0
	db $32
	dw $4000, $4EE0, $4FD0, $50C0
	db $08
	ds 6, 0
	db $32
	dw $5100, $5F80, $6070, $6160
	db $08
	ds 6, 0
	db $32
	dw $61A0, $7090, $7180, $7270
	db $09
	ds 6, 0
	db $33
	dw $4000, $4E60, $4F50, $5040
	db $08
	ds 6, 0
	db $30
	dw $5800, $6700, $67F0, $68E0
	db $08
	ds 6, 0
	db $30
	dw $6A00, $7740, $7830, $7920
	db $08
	ds 6, 0
	db $31
	dw $4000, $4E10, $4F00, $4FF0
	db $06
	ds 6, 0
	db $31
	dw $5020, $5DB0, $5EA0, $5F90
	db $08
	ds 6, 0
	db $31
	dw $5FD0, $6980, $6A70, $6B60
	db $07
	ds 6, 0

SceneDescriptorIndexTable:
	db 6, 7, 8, 9, 10

; bank, 16-byte tile graphics, 40-byte index rows, last row index, palette
ScrollingSceneDescriptors:
	db $3B
	dw $6218, $6E88
	db $23
	dw $7428
	db $39
	dw $4000, $5400
	db $28
	dw $5A68
	db $39
	dw $5A70, $6B50
	db $23
	dw $70F0
	db $3A
	dw $4000, $5460
	db $25
	dw $5A50
	db $3A
	dw $5A58, $6A48
	db $25
	dw $7038
	db $3B
	dw $5090, $5D60
	db $1D
	dw $6210
	db $34
	dw $4000, $4E40
	db $19
	dw $5250
	db $34
	dw $5258, $60D8
	db $1A
	dw $6510
	db $34
	dw $6518, $71F8
	db $1A
	dw $7630
	db $35
	dw $4000, $4A60
	db $1A
	dw $4E98
	db $35
	dw $4EA0, $5AD0
	db $19
	dw $5EE0
	db $35
	dw $5EE8, $6D88
	db $1A
	dw $71C0
	db $36
	dw $4000, $4D30
	db $1A
	dw $5168
	db $36
	dw $5170, $5BB0
	db $1A
	dw $5FE8
	db $36
	dw $5FF0, $6D30
	db $1A
	dw $7168
	db $37
	dw $4000, $4B80
	db $1A
	dw $4FB8
	db $37
	dw $4FC0, $5B30
	db $1A
	dw $5F68
	db $37
	dw $5F70, $6AC0
	db $1A
	dw $6EF8
	db $38
	dw $4000, $4B00
	db $19
	dw $4F10
	db $38
	dw $4F18, $5D88
	db $19
	dw $6198
	db $38
	dw $61A0, $6CA0
	db $19
	dw $70B0
	db $2F
	dw $4000, $4460
	db $05
	dw $4550
	db $2F
	dw $4558, $4998
	db $05
	dw $4A88
	db $2F
	dw $4A90, $4EE0
	db $05
	dw $4FD0
	db $2F
	dw $4FD8, $54C8
	db $05
	dw $55B8
	db $2F
	dw $55C0, $5A90
	db $05
	dw $5B80
	db $2F
	dw $5B88, $5FD8
	db $05
	dw $60C8
	db $2F
	dw $60D0, $6520
	db $05
	dw $6610
	db $2F
	dw $6618, $6A28
	db $05
	dw $6B18
	db $2F
	dw $6B20, $6F40
	db $05
	dw $7030
	db $2F
	dw $7038, $7438
	db $05
	dw $7528
	db $2F
	dw $7530, $79F0
	db $05
	dw $7AE0
	db $30
	dw $4000, $44A0
	db $05
	dw $4590
	db $30
	dw $4598, $49F8
	db $05
	dw $4AE8
	db $30
	dw $4AF0, $5020
	db $05
	dw $5110
	db $30
	dw $5118, $5648
	db $05
	dw $5738

SceneScrollVariantIndexTable:
	db $15, $16, $17, $00, $18, $19, $1A, $00, $1B, $1C
	db $1D, $00, $1E, $1F, $20, $00, $21, $22, $23

SceneScrollDescriptorIndexTable:
	db $06, $07, $08, $00, $09, $0A, $0B, $00, $0C, $0D
	db $0E, $00, $0F, $10, $11, $00, $12, $13, $14

SceneScrollInitialRowTable:
	db $13, $14, $14, $00, $14, $14, $14, $00, $14, $14
	db $14, $00, $14, $14, $14, $00, $13, $13, $13
	db $00 ; alignment before the RAM image at $5BBA

	LOAD UNION "RAM code $D120", WRAMX[$D120] ; copied from $01:5BBA

RAM_D120:
	ldh a, [rLCDC]
	set 4, a
	ldh [rLCDC], a
	ld a, $07
	ldh [rWX], a
	ldh a, [$FF86]
	ldh [rWY], a
	ret

	ENDL
	db $00

	LOAD UNION "RAM code $D130", WRAMX[$D130] ; copied from $01:5BCA

RAM_D130:
	ldh a, [rLCDC]
	res 4, a
	ldh [rLCDC], a
	ld a, $B4
	ldh [rWX], a
	ret

	ENDL
	db $00

	LOAD UNION "RAM code $D140", WRAMX[$D140] ; copied from $01:5BD6

RAM_D140:
	ldh a, [$FF86]
	or a
	jr z, RAM_D14B
	dec a
	ldh [$FF86], a
	ldh [rLYC], a
	ret

RAM_D14B:
	ldh [$FF86], a
	call $5F26
	call RAM_D120
	ldh a, [$FF86]
	add a, $5F
	ldh [rLYC], a
	ret

	ENDL
	db $00

Func_01_5BF1:
	call Func_3960
	ld a, $01
	ldh [$FF83], a
	ldh [$FF97], a
	ldh [$FFAC], a
	xor a
	ldh [$FF84], a
	ldh [rLYC], a
	ldh [rSCX], a
	ldh [$FF95], a
	ldh [$FF8C], a
	ldh [$FFA9], a
	ldh [$FFA9], a
	ldh [$FFAB], a
	ldh [$FFB0], a
	ldh [$FFB5], a
	ldh [$FFB6], a
	ld e, $10
	ld hl, $FF98
Jump_01_5C18:
	ld [hli], a
	dec e
	jr nz, Jump_01_5C18
	xor a
	add a, $60
	ldh [$FF87], a
	ldh [rSCY], a
	ld a, $8E
	ldh [$FF86], a
	ld a, $B4
	ldh [$FF85], a
	ld a, $60
	ldh [$FF96], a
	ld a, $07
	ldh [$FFAF], a
	ldh a, [rLCDC]
	and $E3
	or $63
	ldh [rLCDC], a
	call Func_01_5E6C
	call Func_01_6618
	call Func_01_5C56
	xor a
	ld [wVBlankPending], a
Jump_01_5C48:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_5C48
	xor a
	ld [wVBlankPending], a
	ret


Func_01_5C56:
	push af
	push bc
	push de
	push hl
	ld e, $00
	ld d, $08
	ld hl, $8800
	ld bc, $0200
	xor a
	ldh [rVBK], a
Jump_01_5C67:
	ldh a, [rSTAT]
	and $02
	jr z, Jump_01_5C67
Jump_01_5C6D:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_5C6D
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	dec bc
	ld a, b
	or a
	jr nz, Jump_01_5C67
	ld a, c
	or a
	jr nz, Jump_01_5C67
	ld hl, $DC00
	ld bc, $0400
	ld a, $07
	call Func_05AB
	ld hl, $DC00
	ld a, h
	ldh [rHDMA1], a
	ld a, l
	ldh [rHDMA2], a
	ld a, $98
	ldh [rHDMA3], a
	ld a, $00
	ldh [rHDMA4], a
	ld a, $01
	ldh [rVBK], a
	xor a
	ld [wVBlankPending], a
Jump_01_5CA9:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_5CA9
	xor a
	ld [wVBlankPending], a
	ld a, $3F
	ldh [rHDMA5], a
	ld hl, $DC00
	ld bc, $0400
	ld a, $FF
	call Func_05AB
	ld hl, $DC00
	ld a, h
	ldh [rHDMA1], a
	ld a, l
	ldh [rHDMA2], a
	ld a, $98
	ldh [rHDMA3], a
	ld a, $00
	ldh [rHDMA4], a
	xor a
	ldh [rVBK], a
	xor a
	ld [wVBlankPending], a
Jump_01_5CDD:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_5CDD
	xor a
	ld [wVBlankPending], a
	ld a, $3F
	ldh [rHDMA5], a
	ld hl, $DC00
	ld bc, $0400
	ld a, $07
	call Func_05AB
	ld hl, $DC00
	ld a, h
	ldh [rHDMA1], a
	ld a, l
	ldh [rHDMA2], a
	ld a, $9C
	ldh [rHDMA3], a
	ld a, $00
	ldh [rHDMA4], a
	ld a, $01
	ldh [rVBK], a
	xor a
	ld [wVBlankPending], a
Jump_01_5D12:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_5D12
	xor a
	ld [wVBlankPending], a
	ld a, $3F
	ldh [rHDMA5], a
	ld hl, $DC00
	ld bc, $0400
	ld a, $7F
	call Func_05AB
	ld hl, $DC00
	ld a, h
	ldh [rHDMA1], a
	ld a, l
	ldh [rHDMA2], a
	ld a, $9C
	ldh [rHDMA3], a
	ld a, $00
	ldh [rHDMA4], a
	xor a
	ldh [rVBK], a
	xor a
	ld [wVBlankPending], a
Jump_01_5D46:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_5D46
	xor a
	ld [wVBlankPending], a
	ld a, $3F
	ldh [rHDMA5], a
	ld hl, $87F0
	ld d, $04
Jump_01_5D5C:
	ldh a, [rSTAT]
	and $02
	jr z, Jump_01_5D5C
Jump_01_5D62:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_5D62
	ld e, $04
Jump_01_5D6A:
	xor a
	ld [hli], a
	dec e
	jr nz, Jump_01_5D6A
	dec d
	jr nz, Jump_01_5D5C
	pop hl
	pop de
	pop bc
	pop af
	ret


	LOAD UNION "RAM code $C729", WRAM0[$C729] ; copied from $01:5D77

RAM_C729_01_5D77:
	push af
	push bc
	push de
	push hl
	ldh a, [$FF80]
	or a
	jr nz, RAM_C75C
	ldh a, [rSTAT]
	bit 2, a
	jr nz, RAM_C761
	ldh a, [$FFA9]
	or a
	jr z, RAM_C75C
	ldh a, [$FFAC]
	or a
	jr z, RAM_C74A
	ldh a, [$FFAF]
	ld b, a
	ldh a, [$FFAA]
	cp b
	jr nz, RAM_C754
RAM_C74A:
	xor a
	ldh [$FFA9], a
	ldh [$FFAA], a
	call RAM_D2F0
	jr RAM_C75C
RAM_C754:
	ld b, a
	call $5EE0
	ld a, b
	inc a
	ldh [$FFAA], a
RAM_C75C:
	pop hl
	pop de
	pop bc
	pop af
	reti
RAM_C761:
	ldh a, [rLY]
	ld e, a
	ldh a, [$FF86]
	cp e
	jr nz, RAM_C78D
RAM_C769:
	ldh a, [rSTAT]
	and $03
	jr nz, RAM_C769
	call RAM_D310
	call RAM_D120
	ldh a, [$FF86]
	add a, $5F
	cp $8F
	jr nc, RAM_C784
	ldh [rLYC], a
	xor a
	ldh [$FFA9], a
	jr RAM_C7C3
RAM_C784:
	ld a, $8F
	ldh [rLYC], a
	xor a
	ldh [$FFA9], a
	jr RAM_C7C3
RAM_C78D:
	ldh a, [rSTAT]
	and $03
	jr nz, RAM_C78D
	ldh a, [$FFAC]
	or a
	jr z, RAM_C7AA
	ld de, $FF69
	ld a, $B8
	ldh [rBCPS], a
	xor a
	REPT 8
	ld [de], a
	ENDR
	jr RAM_C7AD
RAM_C7AA:
	call RAM_D2F0
RAM_C7AD:
	call RAM_D130
	ldh a, [$FF86]
	add a, $60
	add a, $08
	cp $8F
	jr nc, RAM_C7C0
	ld a, $01
	ldh [$FFA9], a
	jr RAM_C7C3
RAM_C7C0:
	xor a
	ldh [$FFA9], a
RAM_C7C3:
	pop hl
	pop de
	pop bc
	pop af
	reti
	ENDL

	LOAD UNION "RAM code $C7F1", WRAM0[$C7F1] ; copied from $01:5E16

RAM_C7F1_01_5E16:
	push af
	push de
	push bc
	push hl
	ldh a, [$FF80]
	or a
	jr nz, RAM_C7FD
	call RAM_D140
RAM_C7FD:
	ldh a, [$FF96]
	dec a
	ldh [$FF96], a
	or a
	jr nz, RAM_C809
	ld a, $01
	ldh [$FF95], a
RAM_C809:
	ldh a, [$FF87]
	ldh [rSCY], a
	ldh a, [$FFB6]
	or a
	jr z, RAM_C818
	xor a
	ldh [$FFB6], a
	call Func_01_6580
RAM_C818:
	ld a, [$C6B7]
	and $01
	jr z, RAM_C82E
	call Func_0A59
	ld a, [$C6B5]
	and $F0
	cp $F0
	jr nz, RAM_C82E
	jp Jump_00DA

RAM_C82E:
	ld a, [$C6B7]
	inc a
	ld [$C6B7], a
	ld a, [$C6B8]
	adc a, $00
	ld [$C6B8], a
	ld a, $01
	ld [wVBlankPending], a
	pop hl
	pop bc
	pop de
	pop af
	reti

	ENDL

Func_01_5E6C:
	push af
	push bc
	push de
	push hl
	di
	ld hl, $5D77
	ld de, $009F
	ld bc, $C729
	call CopyBytes
	ld hl, $5E16
	ld de, $0056
	ld bc, $C7F1
	call CopyBytes
	ldh a, [rSTAT]
	set 6, a
	set 3, a
	ldh [rSTAT], a
	ld a, $03
	ldh [rIE], a
	ei
	nop
	pop hl
	pop de
	pop bc
	pop af
	ret


	LOAD UNION "RAM code $D270", WRAMX[$D270] ; copied from $01:5E9C

RAM_D270:
	xor a
	ldh [$FFA8], a
RAM_D273:
	ld hl, $DC48
	ldh a, [$FFA8]
	sla a
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld c, a
	ld a, [hl]
	ld b, a
	ld hl, $D3F8
	ldh a, [$FFA8]
	sla a
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld d, $08
RAM_D295:
	ld e, $04
	call Func_3856
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	ld a, $06
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	dec d
	jr nz, RAM_D295
	ldh a, [$FFA8]
	inc a
	ldh [$FFA8], a
	cp $04
	jr c, RAM_D273
	ret

	ENDL
	db $00

	LOAD UNION "RAM code $D2C0", WRAMX[$D2C0] ; copied from $01:5EE0

RAM_D2C0:
	ld c, a
	ld a, $07
	sub c
	add a, a
	add a, a
	add a, a
	ld hl, $D3F8
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld de, $FF69
	ld a, $B8
	ldh [rBCPS], a
	REPT 8
	ld a, [hli]
	ld [de], a
	ENDR
	ret
	ENDL
	db $00

	LOAD UNION "RAM code $D2F0", WRAMX[$D2F0] ; copied from $01:5F0A

RAM_D2F0:
	ld hl, $FFA0
	ld de, $FF69
	ld a, $B8
	ldh [rBCPS], a
	REPT 8
	ld a, [hli]
	ld [de], a
	ENDR
	ret
	ENDL
	db $00

	LOAD UNION "RAM code $D310", WRAMX[$D310] ; copied from $01:5F26

RAM_D310:
	ld hl, $FF98
	ld de, $FF69
	ld a, $B8
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
	ret

	ENDL
	db $00

	LOAD UNION "RAM code $D000", WRAMX[$D000] ; copied from $01:5F42

LoadFixedSceneResources:
	ld hl, wFixedSceneGraphicsBank
	ld a, [hli]
	ld a, a
	ld [rROMB0], a
	ld c, [hl]
	inc hl
	ld b, [hl]
	ld e, $80
	ld a, $01
	ldh [rVBK], a
	xor a
	ld [wVBlankPending], a
RAM_D015:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, RAM_D015
	xor a
	ld [wVBlankPending], a
	ld a, b
	ldh [rHDMA1], a
	ld a, c
	ldh [rHDMA2], a
	ld a, e
	ldh [rHDMA3], a
	xor a
	ldh [rHDMA4], a
	ld a, $7F
	ldh [rHDMA5], a
	xor a
	ldh [rVBK], a
	ld hl, $0800
	add hl, bc
	ld a, h
	ldh [rHDMA1], a
	ld a, l
	ldh [rHDMA2], a
	ld a, e
	ldh [rHDMA3], a
	xor a
	ldh [rHDMA4], a
	xor a
	ld [wVBlankPending], a
RAM_D049:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, RAM_D049
	xor a
	ld [wVBlankPending], a
	ld a, $7E
	ldh [rHDMA5], a
	ld hl, wFixedScenePalettes
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld bc, $0038
	add hl, bc
	ld bc, $DC40
	ld e, $08
	call CopyBytesShort
	ld hl, wFixedSceneTilemap
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld hl, $9C00
	push de
	push hl
	ld a, $01
	ldh [rVBK], a
	ld d, $0C
RAM_D082:
	ld e, $14
RAM_D084:
	ldh a, [rSTAT]
	and $02
	jr z, RAM_D084
RAM_D08A:
	ldh a, [rSTAT]
	and $02
	jr nz, RAM_D08A
	ld a, [bc]
	ld [hli], a
	inc bc
	dec e
	jr nz, RAM_D084
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	dec d
	jr nz, RAM_D082
	pop hl
	pop bc
	xor a
	ld [wVBlankPending], a
RAM_D0A7:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, RAM_D0A7
	xor a
	ld [wVBlankPending], a
	xor a
	ldh [rVBK], a
	ld d, $0C
RAM_D0B9:
	ld e, $14
RAM_D0BB:
	ldh a, [rSTAT]
	and $02
	jr z, RAM_D0BB
RAM_D0C1:
	ldh a, [rSTAT]
	and $02
	jr nz, RAM_D0C1
	ld a, [bc]
	bit 7, a
	jr z, RAM_D0DE
	sub $80
	ld [hl], a
	ld a, $01
	ldh [rVBK], a
	ld a, [hl]
	or $08
	ld [hli], a
	push af
	xor a
	ldh [rVBK], a
	pop af
	jr RAM_D0DF

RAM_D0DE:
	ld [hli], a
RAM_D0DF:
	inc bc
	dec e
	jr nz, RAM_D0BB
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	dec d
	jr nz, RAM_D0B9
	ld hl, wFixedScenePalettes
	ld b, h
	ld c, l
	inc bc
	inc bc
	ld a, [bc]
	add a, a
	add a, a
	add a, a
	ld e, a
	ld hl, wFixedScenePalettes
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [ROM_BANK_MARKER]
	ld d, a
	call Func_3A88
	xor a
	ld [$C6D1], a
	call Func_3A2F
	ld a, $01
	ld [rROMB0], a
	ret

	ENDL
	db $00

	LOAD UNION "RAM code $D160", WRAMX[$D160] ; copied from $01:6057

LoadScrollingScenePalette:
	push af
	push bc
	push de
	push hl
	ld a, $01
	ldh [$FF80], a
	ld hl, wScrollingSceneBank
	ld a, l
	ldh [$FF88], a
	ld a, h
	ldh [$FF89], a
	ld a, [hl]
	ldh [$FF92], a
	ld e, a
	ld hl, wScrollingSceneLastRow
	ld a, [hli]
	ldh [$FF8A], a
	ld a, e
	ld a, a
	ld [rROMB0], a
	ld hl, wScrollingScenePalette
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld bc, $DC48
	ld e, $08
	call CopyBytesShort
	call RAM_D270
	xor a
	ldh [$FF8B], a
	ld a, $01
	ld [rROMB0], a
	pop hl
	pop de
	pop bc
	pop af
	ld a, $00
	ldh [$FF80], a
	ret

	ENDL
	db $00

Func_01_609A:
	xor a
	ld [wVBlankPending], a
Jump_01_609E:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_609E
	xor a
	ld [wVBlankPending], a
	ld a, $01
	ldh [$FF80], a
	call CopyFixedSceneDescriptor
	call CopyScrollingSceneDescriptor
	call LoadFixedSceneResources
	call LoadScrollingScenePalette
	call Func_01_6149
	xor a
	ld [wVBlankPending], a
Jump_01_60C2:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_60C2
	xor a
	ld [wVBlankPending], a
	xor a
	ldh [$FF80], a
Jump_01_60D2:
	call Audio_Update
	xor a
	ld [wVBlankPending], a
Jump_01_60D9:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_60D9
	xor a
	ld [wVBlankPending], a
	ldh a, [$FF95]
	or a
	jr z, Jump_01_60D2
	call RAM_D1B0
	ldh a, [$FF84]
	or a
	jr nz, Jump_01_6126
	ld a, [$C6B5]
	ld e, a
	and $80
	jr nz, Jump_01_6126
	ld a, e
	and $30
	jr z, Jump_01_6107
	ld e, $24
	call Audio_QueueSound
	jr Jump_01_60D2

Jump_01_6107:
	ld a, $03
	ld d, a
Jump_01_610A:
	call Audio_Update
	xor a
	ld [wVBlankPending], a
Jump_01_6111:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_6111
	xor a
	ld [wVBlankPending], a
	halt
	nop
	nop
	dec d
	jr nz, Jump_01_610A
	jr Jump_01_60D2

Jump_01_6126:
	ld d, $3C
	call Func_3971
	call Func_01_61CE
	ld a, $01
	ldh [$FFAB], a
	ret


Func_01_6133:
	push af
	push bc
	push de
	push hl
	call Func_3960
	xor a
	ld e, $10
	ld hl, $FF98
Jump_01_6140:
	ld [hli], a
	dec e
	jr nz, Jump_01_6140
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_01_6149:
	push af
	push bc
	push de
	push hl
	ld hl, $DC40
	ld bc, $FF98
	ld e, $10
Jump_01_6155:
	ld a, [hli]
	ld [bc], a
	inc bc
	dec e
	jr nz, Jump_01_6155
	xor a
	ld [wVBlankPending], a
Jump_01_615F:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_615F
	xor a
	ld [wVBlankPending], a
	ld e, $1F
	call Func_3A52
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_01_6176:
	ld a, $38
	ldh [$FFAE], a
	ld d, $01
Jump_01_617C:
	xor a
	ld [wVBlankPending], a
Jump_01_6180:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_6180
	xor a
	ld [wVBlankPending], a
	call Audio_Update
	ld a, d
	cp $10
	jr nc, Jump_01_61A2
	ld hl, $D3F8
	ldh a, [$FFAE]
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	jr Jump_01_61A5

Jump_01_61A2:
	ld hl, $DC48
Jump_01_61A5:
	ld bc, $FFA0
	ld e, $08
Jump_01_61AA:
	ld a, [hli]
	ld [bc], a
	inc bc
	dec e
	jr nz, Jump_01_61AA
	ldh a, [$FFAE]
	sub $08
	ldh [$FFAE], a
	push de
	ld bc, $FF98
	ld e, d
	ld d, $07
	call Func_3A68
	pop de
	ld e, d
	call Func_3A52
	ld a, d
	add a, $02
	ld d, a
	cp $20
	jr c, Jump_01_617C
	ret


Func_01_61CE:
	push af
	push bc
	push de
	push hl
	ld a, $00
	ldh [$FFAE], a
	ld d, $1E
Jump_01_61D8:
	xor a
	ld [wVBlankPending], a
Jump_01_61DC:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_61DC
	xor a
	ld [wVBlankPending], a
	call Audio_Update
	ld a, d
	cp $10
	jr c, Jump_01_6217
	ldh a, [$FFAF]
	dec a
	cp $FF
	jr nz, Jump_01_61F9
	xor a
Jump_01_61F9:
	ldh [$FFAF], a
	ld hl, $D3F8
	ldh a, [$FFAE]
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld bc, $FFA0
	ld e, $08
Jump_01_620B:
	ld a, [hli]
	ld [bc], a
	inc bc
	dec e
	jr nz, Jump_01_620B
	ldh a, [$FFAE]
	add a, $08
	ldh [$FFAE], a
Jump_01_6217:
	push de
	ld bc, $FF98
	ld e, d
	ld d, $07
	call Func_3A68
	pop de
	ld e, d
	call Func_3A52
	ld a, d
	sub $02
	ld d, a
	cp $20
	jr c, Jump_01_61D8
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_01_6233:
	xor a
	ldh [$FFAC], a
	push bc
	ld a, b
	call Func_01_6309
	pop bc
	call Func_01_6367
	call Func_01_6176
	ret


Func_01_6243:
	call Func_01_6367
	ret

Func_01_6247:
	push bc
	xor a
	ld [wVBlankPending], a
Jump_01_624C:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_624C
	xor a
	ld [wVBlankPending], a
	xor a
	ldh [$FFA0], a
	ldh [$FFA1], a
	ldh [$FFA2], a
	ldh [$FFA3], a
	ldh [$FFA4], a
	ldh [$FFA5], a
	ldh [$FFA6], a
	ldh [$FFA7], a
	ld hl, $9800
	ld b, $FF
	ld d, $20
Jump_01_6271:
	ld e, $14
Jump_01_6273:
	ldh a, [rSTAT]
	and $02
	jr z, Jump_01_6273
Jump_01_6279:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_6279
	ld a, b
	ld [hli], a
	dec e
	jr nz, Jump_01_6273
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	res 2, h
	dec d
	jr nz, Jump_01_6271
	pop bc
	ld a, b
	add a, a
	add a, a
	add a, c
	push af
	ld hl, SceneScrollDescriptorIndexTable
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	ldh [$FF82], a
	xor a
	ldh [$FFB0], a
	ldh [$FFB5], a
	xor a
	ldh [$FFAC], a
	call CopyScrollingSceneDescriptor
	call LoadScrollingScenePalette
	pop af
	ld hl, SceneScrollInitialRowTable
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	ldh [$FF8B], a
	ld a, $38
	ldh [$FFAD], a
	call Func_01_6149
Jump_01_62C7:
	call Audio_Update
	xor a
	ld [wVBlankPending], a
Jump_01_62CE:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_62CE
	xor a
	ld [wVBlankPending], a
	call RAM_D1B0
	ldh a, [$FF84]
	or a
	jr nz, Jump_01_62F6
	ld a, [$C6B5]
	and $80
	jr nz, Jump_01_62F6
	ld e, $24
	call Audio_QueueSound
	ldh a, [$FFAD]
	dec a
	ldh [$FFAD], a
	jr nz, Jump_01_62C7
Jump_01_62F6:
	ld a, $01
	ldh [$FFAB], a
	ld d, $FF
	call Func_3971
	call Func_01_61CE
	call Func_04B6
	call Func_0051
	ret

Func_01_6309:
	ld hl, SceneDescriptorIndexTable
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	ldh [$FF81], a
	ld a, $01
	ldh [$FF80], a
	call CopyFixedSceneDescriptor
	call Func_3960
	ld a, $01
	ldh [$FFAB], a
	xor a
	ld [wVBlankPending], a
Jump_01_6328:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_6328
	xor a
	ld [wVBlankPending], a
	ld a, $B4
	ldh [rWX], a
	ldh [$FF85], a
	xor a
	ldh [rWY], a
	ldh [$FF86], a
	call LoadFixedSceneResources
	xor a
	ldh [$FF80], a
	xor a
	ldh [$FF86], a
	ldh [rWY], a
	ld a, $07
	ldh [$FF85], a
	ldh [rWX], a
	xor a
	ld [wVBlankPending], a
Jump_01_6355:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_6355
	xor a
	ld [wVBlankPending], a
	ld a, $00
	ldh [$FFAB], a
	ret


Func_01_6367:
	ld a, b
	add a, a
	add a, a
	add a, c
	ld hl, SceneScrollVariantIndexTable
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	ldh [$FF82], a
	xor a
	ldh [$FFB0], a
	ldh [$FFB5], a
	ldh [$FF8B], a
	call CopyScrollingSceneDescriptor
	call LoadScrollingScenePalette
	ld e, $06
	push de
Jump_01_6388:
	xor a
	ld [wVBlankPending], a
Jump_01_638C:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_638C
	xor a
	ld [wVBlankPending], a
	ldh a, [$FFB5]
	ld e, a
	call RAM_D330
	ldh a, [$FF8B]
	inc a
	ldh [$FF8B], a
	pop de
	dec e
	push de
	jr nz, Jump_01_6388
	pop de
	ldh a, [$FF87]
	add a, $30
	ldh [$FF87], a
	ldh [rSCY], a
	ret


Func_01_63B3:
	ld hl, $65EB
	add a, a
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	ld hl, $65E1
	add a, a
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ldh [$FF81], a
	ld a, [hl]
	ldh [$FF82], a
	ret


Func_01_63D1:
	ld hl, $65EB
	add a, a
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld b, a
	ld a, [hl]
	ld c, a
	push bc
	ld hl, SceneDescriptorIndexTable
	ld a, b
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	ldh [$FF81], a
	ld hl, SceneScrollDescriptorIndexTable
	pop bc
	ld a, b
	add a, a
	add a, a
	add a, c
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	ldh [$FF82], a
	ret


	LOAD UNION "RAM code $D1B0", WRAMX[$D1B0] ; copied from $01:6401

RAM_D1B0:
	ldh a, [$FF97]
	ld e, a
	ldh a, [$FF87]
	add a, e
	ldh [$FF87], a
	ldh a, [$FF8C]
	add a, e
	cp $08
	jr c, RAM_D1DD
	sub $08
	ldh [$FF8C], a
	ld e, $00
	call RAM_D330
	ldh a, [$FF8A]
	ld e, a
	ldh a, [$FF8B]
	cp e
	jr nc, RAM_D1D7
	ldh [$FF8B], a
	inc a
	ldh [$FF8B], a
	jr RAM_D1DF

RAM_D1D7:
	ld a, $01
	ldh [$FF84], a
	jr RAM_D1DF

RAM_D1DD:
	ldh [$FF8C], a
RAM_D1DF:
	ret

	ENDL
	db $00

	LOAD UNION "RAM code $D1F0", WRAMX[$D1F0] ; copied from $01:6432

RAM_D1F0:
	ldh a, [$FF92]
	ld a, a
	ld [rROMB0], a
	ld hl, wScrollingSceneRows
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ldh a, [$FF8B]
	ld c, a
	ld b, $00
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	ld d, b
	ld e, c
	sla c
	rl b
	sla c
	rl b
	add hl, bc
	add hl, de
	ld a, l
	ldh [$FF8D], a
	ld a, h
	ldh [$FF8E], a
	ld a, $01
	ld [rROMB0], a
	ret

	ENDL
	db $00

	LOAD UNION "RAM code $D230", WRAMX[$D230] ; copied from $01:6468

RAM_D230:
	ldh a, [$FF88]
	ld l, a
	ldh a, [$FF89]
	ld h, a
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push de
	push bc
	ld a, [bc]
	ld e, a
	inc bc
	ld a, [bc]
	ld d, a
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	add hl, de
	pop bc
	pop de
	ret

	ENDL
	db $00

	LOAD UNION "RAM code $D330", WRAMX[$D330] ; copied from $01:648E

RAM_D330:
	call Func_01_64BB
	call Func_01_64F1
	call RAM_D370
	call Func_01_6562
	ld a, $01
	ldh [$FFB6], a
	ldh a, [$FFB5]
	inc a
	cp $07
	jr c, RAM_D348
	xor a
RAM_D348:
	ldh [$FFB5], a
	ldh a, [$FFB0]
	add a, $14
	cp $78
	jr nz, RAM_D354
	ld a, $80
RAM_D354:
	cp $94
	jr c, RAM_D359
	xor a
RAM_D359:
	ldh [$FFB0], a
	ret

	ENDL
	db $00

Func_01_64BB:
	ldh a, [rSCY]
	add a, $07
	srl a
	srl a
	srl a
	add a, $12
	add a, e
	cp $20
	jr c, Jump_01_64CE
	sub $20
Jump_01_64CE:
	ld c, a
	ld b, $00
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	ld hl, $9800
	add hl, bc
	ld a, l
	ldh [$FFB1], a
	ld a, h
	ldh [$FFB2], a
	ret

	db $00

Func_01_64F1:
	ldh a, [$FFB5]
	add a, a
	ld hl, ScrollingTileRowDestinations
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ldh [$FFB3], a
	ld a, [hl]
	ldh [$FFB4], a
	ret

	db $00

	LOAD UNION "RAM code $D370", WRAMX[$D370] ; copied from $01:6505

RAM_D370:
	call RAM_D1F0
	ldh a, [$FF92]
	ld a, a
	ld [rROMB0], a
	ld de, $0000
RAM_D37C:
	ldh a, [$FF8D]
	ld c, a
	ldh a, [$FF8E]
	ld b, a
	call RAM_D230
	call RAM_D3B0
	ldh a, [$FF8D]
	ld c, a
	ldh a, [$FF8E]
	ld b, a
	inc bc
	inc bc
	ld a, c
	ldh [$FF8D], a
	ld a, b
	ldh [$FF8E], a
	inc e
	ld a, e
	cp $14
	jr c, RAM_D37C
	ld a, $01
	ld [rROMB0], a
	ret

	ENDL
	db $00

	LOAD UNION "RAM code $D3B0", WRAMX[$D3B0] ; copied from $01:6538

RAM_D3B0:
	push af
	push bc
	push de
	push hl
	push hl
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	ld hl, $C400
	add hl, de
	ld b, h
	ld c, l
	pop hl
	ld e, $10
RAM_D3CE:
	ld a, [hli]
	ld [bc], a
	inc bc
	dec e
	jr nz, RAM_D3CE
	pop hl
	pop de
	pop bc
	pop af
	ret

	ENDL
	db $00

Func_01_6562:
	ld e, $14
	ldh a, [$FFB1]
	ld l, a
	ld c, a
	ldh a, [$FFB2]
	ld h, a
	ld b, a
	ldh a, [$FFB0]
	ld d, a
Jump_01_656F:
	xor a
	ldh [rVBK], a
Jump_01_6572:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_6572
	ld a, d
	ld [hli], a
	inc d
	dec e
	jr nz, Jump_01_656F
	ret

	db $00

Func_01_6580:
	ldh a, [$FFB4]
	ldh [rHDMA3], a
	ldh a, [$FFB3]
	ldh [rHDMA4], a
	ld bc, $C400
	ld a, b
	ldh [rHDMA1], a
	ld a, c
	ldh [rHDMA2], a
	xor a
	ldh [rVBK], a
	ld a, $13
	ldh [rHDMA5], a
	ret


	LOAD UNION "RAM data $D260", WRAMX[$D260] ; copied from $01:6599
	db $C9
	ENDL
	db $00

CopyScrollingSceneDescriptor:
	ld hl, ScrollingSceneDescriptors
	ldh a, [$FF82]
	ld c, a
	ld b, $00
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	add hl, bc
	ld bc, wScrollingSceneBank
	ld de, $0008
	call CopyBytesShort
	ret


CopyFixedSceneDescriptor:
	ld a, $01
	ldh [rSVBK], a
	ldh a, [$FF81]
	ld c, a
	ld b, $00
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	ld hl, SceneBackgroundDescriptors
	add hl, bc
	ld bc, wFixedSceneGraphicsBank
	ld de, $0010
	call CopyBytesShort
	ret

	db $01, $01, $02, $02, $03, $03, $04, $04, $05, $05, $00, $00, $00, $01, $00, $02
	db $01, $00, $01, $01, $01, $02, $02, $00, $02, $01, $02, $02, $03, $00, $03, $01
	db $03, $02, $04, $00, $04, $01, $04, $02, $01, $00, $00, $01, $00, $00, $01, $00
	db $00, $01, $00, $00, $01, $00, $00

Func_01_6618:
	ld a, $01
	ldh [rSVBK], a
	ld hl, $5F42
	ld de, $0114
	ld bc, $D000
	call CopyBytes
	ld hl, $5BBA
	ld de, $000F
	ld bc, $D120
	call CopyBytes
	ld hl, $5BCA
	ld de, $000B
	ld bc, $D130
	call CopyBytes
	ld hl, $5BD6
	ld de, $001A
	ld bc, $D140
	call CopyBytes
	ld hl, $6057
	ld de, $0042
	ld bc, $D160
	call CopyBytes
	ld hl, $6401
	ld de, $0030
	ld bc, $D1B0
	call CopyBytes
	ld hl, $6432
	ld de, $0035
	ld bc, $D1F0
	call CopyBytes
	ld hl, $6468
	ld de, $0025
	ld bc, $D230
	call CopyBytes
	ld hl, $6599
	ld de, $0001
	ld bc, $D260
	call CopyBytes
	ld hl, $5E9C
	ld de, $0043
	ld bc, $D270
	call CopyBytes
	ld hl, $5EE0
	ld de, $0029
	ld bc, $D2C0
	call CopyBytes
	ld hl, $5F0A
	ld de, $001B
	ld bc, $D2F0
	call CopyBytes
	ld hl, $5F26
	ld de, $001B
	ld bc, $D310
	call CopyBytes
	ld hl, $648E
	ld de, $002C
	ld bc, $D330
	call CopyBytes
	ld hl, $6505
	ld de, $0032
	ld bc, $D370
	call CopyBytes
	ld hl, $6538
	ld de, $0029
	ld bc, $D3B0
	call CopyBytes
	ret

	db $00, $0A, $0E, $12, $01, $0B, $0F, $18, $02, $0C, $10, $13, $03, $0D, $11, $14
	db $04, $05, $15, $16, $06, $07, $17, $08, $09

Func_01_66F6:
	push af
	push bc
	push de
	push hl
	push af
	ld a, $01
	ldh [rVBK], a
	ld bc, $6E8A
	ld a, $80
	add a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	ld a, $88
	ld d, $80
	ld e, $00
	call Func_0622
	ld bc, $6E8A
	ld a, $90
	ld d, $0C
	ld e, $00
	call Func_0622
	call Func_01_6746
	xor a
	ld [$DF0B], a
	call Func_01_695C
	ld a, $0B
	ld [$DF06], a
	ld a, [$DF0B]
	add a, a
	add a, a
	add a, a
	add a, $08
	ld [$DF09], a
	ld [$DF0A], a
	xor a
	ld [$DF0C], a
	pop af
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_01_6746:
	ld hl, $77AA
	ld b, $04
	ld c, $04
	call Func_052F
	ret


Func_01_6751:
	ld hl, $77CA
	ld b, $01
	call Func_0553
	ld hl, $77D0
	ld b, $02
	call Func_0553
	ret


Func_01_6762:
	ld d, $0D
	ld a, [$DF0C]
	cp d
	jr nz, Jump_01_676C
	ld a, $FF
Jump_01_676C:
	inc a
	ld [$DF0C], a
	add a, a
	add a, a
	add a, a
	ld hl, $77E4
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	push hl
	ld b, $01
	call Func_0553
	pop hl
	ld b, $02
	call Func_0553
	ret


Func_01_6789:
	ld d, $00
	bit 7, a
	jr nz, Jump_01_6793
	add a, $02
	ld d, $08
Jump_01_6793:
	res 7, a
	push af
	add a, a
	add a, a
	ld hl, $769A
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld e, $04
	ld bc, $DF0D
	inc bc
Jump_01_67A8:
	ld a, [hli]
	bit 7, a
	jr z, Jump_01_67B1
	cp $89
	jr c, Jump_01_67B5
Jump_01_67B1:
	sub $08
	jr Jump_01_67B7

Jump_01_67B5:
	sub $80
Jump_01_67B7:
	ld [bc], a
	inc bc
	inc bc
	dec e
	jr nz, Jump_01_67A8
	pop af
	add a, a
	add a, a
	ld hl, $7722
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld e, $04
	ld bc, $DF0D
Jump_01_67CF:
	ld a, [hli]
	or $0C
	ld [bc], a
	inc bc
	inc bc
	dec e
	jr nz, Jump_01_67CF
	ret


Func_01_67D9:
	push af
	push bc
	push de
	push hl
	call Func_01_6789
	ld hl, $9800
	ld a, [$DF06]
	ld c, a
	ld b, $00
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	ld a, [$DF05]
	add a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	add hl, bc
Jump_01_6807:
	ldh a, [rSTAT]
	and $02
	jr z, Jump_01_6807
Jump_01_680D:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_680D
	ld a, $01
	ldh [rVBK], a
	ld bc, $DF0D
	ld a, [bc]
	ld [hl], a
	xor a
	ldh [rVBK], a
	ld bc, $DF0E
	ld a, [bc]
	ld [hli], a
	inc a
	ld d, a
	ld a, $01
	ldh [rVBK], a
	ld bc, $DF0F
	ld a, [bc]
	ld [hl], a
	xor a
	ldh [rVBK], a
	ld bc, $DF10
	ld a, [bc]
	ld [hl], a
	inc a
	ld e, a
	dec hl
	ld bc, $0020
	add hl, bc
Jump_01_683E:
	ldh a, [rSTAT]
	and $02
	jr z, Jump_01_683E
Jump_01_6844:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_6844
	ld a, $01
	ldh [rVBK], a
	ld bc, $DF11
	ld a, [bc]
	ld [hl], a
	xor a
	ldh [rVBK], a
	ld bc, $DF12
	ld a, [bc]
	ld [hli], a
	inc a
	ld d, a
	ld a, $01
	ldh [rVBK], a
	ld bc, $DF13
	ld a, [bc]
	ld [hl], a
	xor a
	ldh [rVBK], a
	ld bc, $DF14
	ld a, [bc]
	ld [hl], a
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_01_6873:
	ld a, b
	ld [$DF06], a
	ld e, $05
Jump_01_6879:
	push de
	ld hl, $7854
	ld a, c
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, e
	dec a
	add a, a
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	ld [$DF05], a
	ld a, e
	dec a
	ld hl, $DF00
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	ld b, a
	ld a, $1F
	sub b
	call Func_01_67D9
	pop de
	dec e
	jr nz, Jump_01_6879
	ret


Func_01_68AB:
	ld [$DF06], a
	ld a, [$CD04]
	ld c, a
	ld a, [$CD05]
	ld b, a
	ld a, [$CD06]
	ld e, a
	ld a, [$CD07]
	ld d, a
	ld hl, $FFB0
	call Func_06E7
	ld hl, $7866
	xor a
	ldh [$FFB8], a
	ld bc, $FFB2
	ld e, $05
Jump_01_68CF:
	ld a, e
	and $01
	jr z, Jump_01_68DB
	ld a, [bc]
	swap a
	and $0F
	jr Jump_01_68DF

Jump_01_68DB:
	ld a, [bc]
	and $0F
	inc c
Jump_01_68DF:
	ld d, a
	or a
	jr z, Jump_01_68E7
	ld a, $01
	ldh [$FFB8], a
Jump_01_68E7:
	ld a, d
	or a
	jr nz, Jump_01_68F2
	ldh a, [$FFB8]
	or a
	jr nz, Jump_01_68F2
	jr Jump_01_68FE

Jump_01_68F2:
	ld a, [hl]
	ld [$DF05], a
	ld a, d
	and $0F
	or $80
	call Func_01_67D9
Jump_01_68FE:
	inc hl
	dec e
	jr nz, Jump_01_68CF
	ld a, [hl]
	ld [$DF05], a
	ld a, [bc]
	and $0F
	or $80
	call Func_01_67D9
	ret


Func_01_690F:
	ld [$DF06], a
	ld hl, $786F
	ld a, [hli]
	ld [$DF05], a
	ld a, [$CD02]
	ld b, a
	ld hl, $FFB0
	call Func_06C5
	ldh a, [$FFB1]
	ld d, a
	swap a
	and $0F
	jr z, Jump_01_6931
	or $80
	call Func_01_67D9
Jump_01_6931:
	ld a, [$7870]
	ld [$DF05], a
	ld a, d
	and $0F
	or $80
	call Func_01_67D9
	ret


Func_01_6940:
	push de
	ld e, $0A
	call Audio_QueueSound
	pop de
	call Audio_QueueSound
	ld a, [$DF0B]
	ld hl, $DF00
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [$DF07]
	ld [hl], a
	ret


Func_01_695C:
	ld a, [$DF0B]
	ld hl, $DF00
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	ld [$DF07], a
	ret


Func_01_696E:
	ld bc, $7871
	ld a, $80
	ld d, $04
	ld e, $74
	call Func_0622
	ld e, $74
	ld d, $02
	ld hl, $FE20
Jump_01_6981:
	ld a, $0D
	add a, a
	add a, a
	add a, a
	ld [hli], a
	ld a, $AA
	ld [hli], a
	ld a, e
	ld [hli], a
	ld a, $00
	ld [hli], a
	inc e
	dec d
	jr nz, Jump_01_6981
	ld d, $02
	ld hl, $FE28
Jump_01_6998:
	ld a, $0E
	add a, a
	add a, a
	add a, a
	ld [hli], a
	ld a, $AA
	ld [hli], a
	ld a, e
	ld [hli], a
	ld a, $00
	ld [hli], a
	inc e
	dec d
	jr nz, Jump_01_6998
	ret


Func_01_69AB:
	push hl
	push de
	push bc
	ld a, [$DF0A]
	ld b, a
	ld a, [$DF09]
	ld e, a
	cp b
	jr nz, Jump_01_69BF
	ld a, $00
	pop bc
	pop de
	pop hl
	ret

Jump_01_69BF:
	ld a, b
	cp e
	jr nc, Jump_01_69CC
	sub e
	cp $01
	jr z, Jump_01_69D3
	sra a
	jr Jump_01_69D3

Jump_01_69CC:
	sub e
	cp $01
	jr z, Jump_01_69D3
	srl a
Jump_01_69D3:
	add a, e
	ld [$DF09], a
	ld d, a
	ld hl, $FE21
	ld bc, $FE31
Jump_01_69DE:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_69DE
	ld a, d
	ld [hl], a
	ld [bc], a
	ld hl, $FE29
	ld bc, $FE39
Jump_01_69ED:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_69ED
	ld a, d
	ld [hl], a
	ld [bc], a
	add a, $08
	ld d, a
	ld hl, $FE25
	ld bc, $FE35
Jump_01_69FF:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_69FF
	ld a, d
	ld [hl], a
	ld [bc], a
	ld hl, $FE2D
	ld bc, $FE3D
Jump_01_6A0E:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_6A0E
	ld a, d
	ld [hl], a
	ld [bc], a
	ld a, $01
	pop bc
	pop de
	pop hl
	ret


Func_01_6A1D:
	ld bc, $78B1
	ld a, $80
	ld d, $04
	ld e, $70
	call Func_0622
	ld e, $70
	ld d, $02
	ld hl, $FE30
Jump_01_6A30:
	ldh a, [rSTAT]
	and $02
	jr z, Jump_01_6A30
Jump_01_6A36:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_6A36
	ld a, $0B
	add a, a
	add a, a
	add a, a
	ld [hli], a
	ld a, $AA
	ld [hli], a
	ld a, e
	ld [hli], a
	ld a, $01
	ld [hli], a
	inc e
	dec d
	jr nz, Jump_01_6A30
	ld d, $02
	ld hl, $FE38
Jump_01_6A53:
	ldh a, [rSTAT]
	and $02
	jr z, Jump_01_6A53
Jump_01_6A59:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_6A59
	ld a, $0E
	add a, a
	add a, a
	add a, a
	ld [hli], a
	ld a, $AA
	ld [hli], a
	ld a, e
	ld [hli], a
	ld a, $02
	ld [hli], a
	inc e
	dec d
	jr nz, Jump_01_6A53
	ret


Func_01_6A72:
	ld hl, $7854
	add a, a
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	add a, a
	add a, a
	add a, a
	add a, $08
	ld [$DF0A], a
	call Func_01_695C
	ret


Func_01_6A8A:
	push af
	push bc
	push de
	push hl
	ld a, [$DF0B]
	add a, a
	ld hl, $7854
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	add a, a
	add a, a
	add a, a
	add a, $08
	ld [$DF09], a
	ld [$DF0A], a
	ld d, a
	ld hl, $FE21
	ld bc, $FE31
Jump_01_6AAF:
	ldh a, [rSTAT]
	and $02
	jr z, Jump_01_6AAF
Jump_01_6AB5:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_6AB5
	ld a, d
	ld [hl], a
	ld [bc], a
	ld hl, $FE29
	ld bc, $FE39
	ld a, d
	ld [hl], a
	ld [bc], a
	add a, $08
	ld d, a
	ld hl, $FE25
	ld bc, $FE35
Jump_01_6AD0:
	ldh a, [rSTAT]
	and $02
	jr z, Jump_01_6AD0
Jump_01_6AD6:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_6AD6
	ld a, d
	ld [hl], a
	ld [bc], a
	ld hl, $FE2D
	ld bc, $FE3D
	ld a, d
	ld [hl], a
	ld [bc], a
	ld a, $01
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_01_6AEF:
	xor a
	ld [wVBlankPending], a
Jump_01_6AF3:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_6AF3
	xor a
	ld [wVBlankPending], a
	push af
	push bc
	push de
	push hl
	ld a, $B4
	ld d, a
	ld hl, $FE21
	ld bc, $FE31
	ld a, d
	ld [hl], a
	ld [bc], a
	ld hl, $FE29
	ld bc, $FE39
	ld a, d
	ld [hl], a
	ld [bc], a
	add a, $08
	ld d, a
	ld hl, $FE25
	ld bc, $FE35
	ld a, d
	ld [hl], a
	ld [bc], a
	ld hl, $FE2D
	ld bc, $FE3D
	ld a, d
	ld [hl], a
	ld [bc], a
	ld a, $01
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_01_6B35:
	push hl
	push de
	push bc
	ld e, a
	ld hl, $66DD
	ld a, [$C935]
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	srl a
	srl a
	srl a
	ld bc, $C931
	ld a, a
	add a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	ld a, [bc]
	ld d, a
	ld a, [hl]
	and $07
	or a
	jr z, Jump_01_6B64
Jump_01_6B5F:
	sla e
	dec a
	jr nz, Jump_01_6B5F
Jump_01_6B64:
	ld a, d
	or e
	ld [bc], a
	ld a, [$C935]
	inc a
	ld [$C935], a
	pop bc
	pop de
	pop hl
	ret


Func_01_6B72:
	push hl
	push de
	push bc
	ld hl, $66DD
	ld a, [$C935]
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	srl a
	srl a
	srl a
	ld bc, $C931
	ld a, a
	add a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	ld a, [bc]
	ld d, a
	ld a, [hl]
	and $07
	or a
	jr z, Jump_01_6BA0
Jump_01_6B9B:
	srl d
	dec a
	jr nz, Jump_01_6B9B
Jump_01_6BA0:
	ld a, d
	and $01
	ld d, a
	ld a, [$C935]
	dec a
	ld [$C935], a
	ld a, d
	pop bc
	pop de
	pop hl
	ret


Func_01_6BB0:
	ld hl, $C931
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [$C935], a
	ret


Func_01_6BBC:
	ld a, [$CA06]
	inc a
	ldh [$FFC6], a
	call Func_01_6BB0
	call Func_3BE6
	ld a, c
	ld [$C936], a
	ld a, b
	ld [$C937], a
	ld a, [$CD02]
	and $0F
	ld [$C938], a
	ldh a, [$FFC6]
	and $0F
	ld [$C939], a
	call Func_01_6CA6
	ld e, $0A
Jump_01_6BE4:
	ld a, c
	and $01
	call Func_01_6B35
	srl b
	rr c
	dec e
	jr nz, Jump_01_6BE4
	ld a, [$CD02]
	ld d, a
	ld e, $04
Jump_01_6BF7:
	ld a, d
	and $01
	call Func_01_6B35
	srl d
	dec e
	jr nz, Jump_01_6BF7
	ldh a, [$FFC6]
	ld d, a
	ld e, $04
Jump_01_6C07:
	ld a, d
	and $01
	call Func_01_6B35
	srl d
	dec e
	jr nz, Jump_01_6C07
	ld a, [$C93A]
	ld e, $07
	ld d, a
Jump_01_6C18:
	ld a, d
	and $01
	call Func_01_6B35
	srl d
	dec e
	jr nz, Jump_01_6C18
	ret


Func_01_6C24:
	ld a, $18
	ld [$C935], a
	ld e, $07
	ld c, $00
Jump_01_6C2D:
	call Func_01_6B72
	or c
	sla a
	ld c, a
	dec e
	jr nz, Jump_01_6C2D
	srl c
	ld a, c
	ld [$C93A], a
	ld e, $04
	ld c, $00
Jump_01_6C41:
	call Func_01_6B72
	or c
	sla a
	ld c, a
	dec e
	jr nz, Jump_01_6C41
	srl c
	ld a, c
	ld [$C939], a
	ld b, $0E
	cp b
	jr c, Jump_01_6C58
	jr nz, Jump_01_6C98
Jump_01_6C58:
	ld e, $04
	ld c, $00
Jump_01_6C5C:
	call Func_01_6B72
	or c
	sla a
	ld c, a
	dec e
	jr nz, Jump_01_6C5C
	srl c
	ld a, c
	ld [$C938], a
	ld bc, $0000
	ld e, $0A
Jump_01_6C71:
	call Func_01_6B72
	or c
	ld c, a
	sla c
	rl b
	dec e
	jr nz, Jump_01_6C71
	srl b
	rr c
	ld a, c
	ld [$C936], a
	ld a, b
	ld [$C937], a
	ld a, [$C93A]
	ld d, a
	call Func_01_6CA6
	ld a, [$C93A]
	cp d
	ld a, $01
	jr z, Jump_01_6CA5
Jump_01_6C98:
	xor a
	ld [$C936], a
	ld [$C937], a
	ld [$C938], a
	ld [$C939], a
Jump_01_6CA5:
	ret


Func_01_6CA6:
	push af
	push de
	push bc
	ld d, $05
	ld a, [$C939]
	ld c, a
	ld l, $04
Jump_01_6CB1:
	ld a, c
	and $01
	ld e, a
	ld a, d
	add a, e
	add a, e
	add a, e
	ld d, a
	srl c
	dec l
	jr nz, Jump_01_6CB1
	ld a, [$C938]
	ld c, a
	ld l, $04
Jump_01_6CC5:
	ld a, c
	and $01
	ld e, a
	ld a, d
	add a, e
	add a, e
	ld d, a
	srl c
	dec l
	jr nz, Jump_01_6CC5
	ld a, [$C936]
	ld c, a
	ld a, [$C937]
	ld b, a
	ld l, $0A
Jump_01_6CDC:
	ld a, c
	and $01
	add a, d
	ld d, a
	srl b
	rr c
	dec l
	jr nz, Jump_01_6CDC
	ld a, d
	ld [$C93A], a
	pop bc
	pop de
	pop af
	ret


Func_01_6CF0:
	call Func_3960
	xor a
	ld [wVBlankPending], a
Jump_01_6CF7:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_6CF7
	xor a
	ld [wVBlankPending], a
	ld a, $06
	call ScreenTable_CallInit
	xor a
	ld [wVBlankPending], a
Jump_01_6D0D:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_6D0D
	xor a
	ld [wVBlankPending], a
	ld bc, $0000
	ld a, $06
	call ScreenTable_CallUpdate
	call Func_01_66F6
	call Func_01_6746
	call Func_01_6D48
	ld hl, $C93B
	ld bc, $DF00
	ld e, $05
	call CopyBytesShort
	ld c, $01
	ld b, $0E
	call Func_01_6873
	ld a, $04
	call Func_01_68AB
	ld a, $07
	call Func_01_690F
	ret


Func_01_6D48:
	ld a, [$C931]
	ld c, a
	ld a, [$C932]
	ld b, a
	ld a, [$C933]
	ld l, a
	ld a, [$C934]
	ld h, a
	ld d, $05
Jump_01_6D5A:
	push hl
	ld hl, $C93B
	ld a, $05
	sub d
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, c
	and $1F
	ld [hl], a
	pop hl
	srl h
	rr l
	rr b
	rr c
	srl h
	rr l
	rr b
	rr c
	srl h
	rr l
	rr b
	rr c
	srl h
	rr l
	rr b
	rr c
	srl h
	rr l
	rr b
	rr c
	dec d
	jr nz, Jump_01_6D5A
	ret


Func_01_6D99:
	call Func_01_6BB0
	ld a, [$C931]
	ld c, a
	ld a, [$C932]
	ld b, a
	ld a, [$C933]
	ld l, a
	ld a, [$C934]
	ld h, a
	ld d, $05
Jump_01_6DAE:
	push hl
	ld hl, $C93B
	ld a, d
	dec a
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	and $1F
	or c
	ld c, a
	pop hl
	ld a, d
	dec a
	jr z, Jump_01_6DF0
	sla c
	rl b
	rl l
	rl h
	sla c
	rl b
	rl l
	rl h
	sla c
	rl b
	rl l
	rl h
	sla c
	rl b
	rl l
	rl h
	sla c
	rl b
	rl l
	rl h
	dec d
	jr nz, Jump_01_6DAE
Jump_01_6DF0:
	ld a, c
	ld [$C931], a
	ld a, b
	ld [$C932], a
	ld a, l
	ld [$C933], a
	ld a, h
	ld [$C934], a
	ret


Func_01_6E01:
	xor a
	ld [$CD04], a
	ld [$CD05], a
	ld [$CD06], a
	ld [$CD07], a
Jump_01_6E0E:
	call Func_3BE6
	ld a, [$CD04]
	ld e, a
	ld a, [$CD05]
	ld d, a
	ld a, [$CD06]
	ld c, a
	ld a, [$CD07]
	ld b, a
	ld a, $01
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	ld a, $00
	adc a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	ld a, e
	ld [$CD04], a
	ld a, d
	ld [$CD05], a
	ld a, c
	ld [$CD06], a
	ld a, b
	ld [$CD07], a
	jr Jump_01_6E0E

	db $C9

Func_01_6E44:
	call Func_3960
	call Func_035C
	xor a
	ld [wVBlankPending], a
Jump_01_6E4E:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_6E4E
	xor a
	ld [wVBlankPending], a
	ld a, $0C
	call ScreenTable_CallInit
	xor a
	ld [wVBlankPending], a
Jump_01_6E64:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_6E64
	xor a
	ld [wVBlankPending], a
	ld bc, $0000
	ld a, $0C
	call ScreenTable_CallUpdate
	call Func_01_66F6
	call Func_01_6746
	ld a, $08
	call Func_01_68AB
	ld a, $0C
	call Func_01_690F
	ret

	INCBIN "assets/bank_01/6E8A.bin" ; $A67 bytes

Func_01_78F1:
	ld a, [$C949]
	swap a
	ld c, a
	ld b, $00
	sla c
	rl b
	ld hl, $9800
	add hl, bc
	ld a, [$C948]
	add a, l
	ld l, a
	ld a, [$C94A]
	ld e, a
	ld d, a
	ld c, $12
Jump_01_790D:
	ld e, d
Jump_01_790E:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_01_790E
	ld a, $01
	ldh [rVBK], a
	ld a, [$C956]
	ld [hl], a
	xor a
	ldh [rVBK], a
	ld a, [$C955]
	ld [hli], a
	dec e
	jr nz, Jump_01_790E
	ld a, $20
	sub d
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	dec c
	jr nz, Jump_01_790D
	ret

	db $3E, $2C, $21, $43, $C9, $77, $3E, $11, $01, $E9, $6C, $11, $B9, $6F, $CD, $A3
	db $7A, $3E, $01, $21, $49, $C9, $77, $3E, $01, $21, $4B, $C9, $77, $3E, $11, $F5
	db $AF, $EA, $C0, $C6, $76, $00, $00, $FA, $C0, $C6, $B7, $28, $F7, $AF, $EA, $C0
	db $C6, $CD, $8B, $D8, $21, $4B, $C9, $7E, $3C, $77, $F1, $3D, $FE, $FF, $28, $0C
	db $F5, $01, $E9, $6C, $01, $E9, $6C, $CD, $A3, $7A, $18, $D4, $C9

Func_01_7981:
	ld a, $2C
	ld hl, $C943
	ld [hl], a
	ld a, $01
	ld hl, $C94B
	ld [hl], a
	ld e, $22
	call Audio_QueueSound
	ld a, $08
	ld [$C94E], a
Jump_01_7997:
	call Audio_Update
	xor a
	ld [wVBlankPending], a
Jump_01_799E:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_799E
	xor a
	ld [wVBlankPending], a
	ld a, $01
	ld hl, $C949
	ld [hl], a
	ld a, [$C94E]
	ld bc, $6CE9
	ld de, $6FB9
	call Func_01_7AA3
	call RAM_D88B
	ld a, [$C94E]
	inc a
	add a, $09
	ld hl, $C949
	ld [hl], a
	ld a, $09
	ld bc, $6CE9
	ld de, $6FB9
	call Func_01_7AA3
	call RAM_D88B
	ld a, [$C94E]
	dec a
	ld [$C94E], a
	cp $FF
	jr z, Jump_01_79EB
	ld hl, $C94B
	ld a, [hl]
	inc a
	ld [hl], a
	jr Jump_01_7997

Jump_01_79EB:
	ret

	db $AF, $EA, $54, $C9, $FA, $53, $C9, $21, $43, $C9, $77, $21, $48, $C9, $AF, $77
	db $21, $49, $C9, $3E, $01, $77, $21, $4A, $C9, $3E, $01, $77, $3E, $14, $EA, $4E
	db $C9, $AF, $EA, $C0, $C6, $76, $00, $00, $FA, $C0, $C6, $B7, $28, $F7, $AF, $EA
	db $C0, $C6, $FA, $4F, $C9, $4F, $FA, $50, $C9, $47, $FA, $51, $C9, $5F, $FA, $52
	db $C9, $57, $FA, $4E, $C9, $3D, $CD, $D4, $7A, $CD, $1B, $D9, $21, $4A, $C9, $7E
	db $3C, $77, $FA, $4E, $C9, $3D, $EA, $4E, $C9, $20, $C6, $C9, $AF, $EA, $54, $C9
	db $FA, $53, $C9, $21, $43, $C9, $77, $3E, $13, $EA, $4E, $C9, $EA, $48, $C9, $3E
	db $01, $EA, $49, $C9, $AF, $EA, $C0, $C6, $76, $00, $00, $FA, $C0, $C6, $B7, $28
	db $F7, $AF, $EA, $C0, $C6, $21, $4E, $C9, $3E, $14, $96, $EA, $4A, $C9, $FA, $4E
	db $C9, $EA, $48, $C9, $FA, $4F, $C9, $4F, $FA, $50, $C9, $47, $FA, $51, $C9, $5F
	db $FA, $52, $C9, $57, $AF, $CD, $D4, $7A, $CD, $1B, $D9, $FA, $4E, $C9, $3D, $EA
	db $4E, $C9, $FE, $FF, $20, $BE, $C9

Func_01_7AA3:
	push bc
	ld hl, $0000
	ld c, a
	ld b, $00
	sla c
	rl b
	sla c
	rl b
	add hl, bc
	sla c
	rl b
	sla c
	rl b
	add hl, bc
	pop bc
	push hl
	add hl, bc
	ld b, h
	ld c, l
	ld hl, $C944
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	pop hl
	add hl, de
	ld d, h
	ld e, l
	ld hl, $C946
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	ret


Func_01_7AD4:
	push af
	ld a, a
	add a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	pop af
	ld a, a
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	ld hl, $C944
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	ret

	db $FA, $53, $C9, $EA, $43, $C9, $3E, $00, $EA, $4E, $C9, $EA, $48, $C9, $3E, $01
	db $EA, $49, $C9, $AF, $EA, $C0, $C6, $76, $00, $00, $FA, $C0, $C6, $B7, $28, $F7
	db $AF, $EA, $C0, $C6, $FA, $4F, $C9, $4F, $FA, $50, $C9, $47, $FA, $51, $C9, $5F
	db $FA, $52, $C9, $57, $FA, $4E, $C9, $3C, $CD, $D4, $7A, $AF, $EA, $48, $C9, $FA
	db $4E, $C9, $3C, $47, $3E, $14, $90, $EA, $4A, $C9, $CD, $1B, $D9, $CD, $90, $3C
	db $FA, $4A, $C9, $EA, $48, $C9, $FA, $4E, $C9, $3C, $EA, $4A, $C9, $CD, $F1, $78
	db $FA, $4E, $C9, $3C, $EA, $4E, $C9, $FE, $13, $20, $A8, $C9, $FA, $53, $C9, $EA
	db $43, $C9, $3E, $00, $EA, $4E, $C9, $EA, $48, $C9, $3E, $01, $EA, $49, $C9, $AF
	db $EA, $C0, $C6, $76, $00, $00, $FA, $C0, $C6, $B7, $28, $F7, $AF, $EA, $C0, $C6
	db $FA, $4F, $C9, $4F, $FA, $50, $C9, $47, $FA, $51, $C9, $5F, $FA, $52, $C9, $57
	db $AF, $CD, $D4, $7A, $FA, $4E, $C9, $3C, $EA, $48, $C9, $FA, $4E, $C9, $3C, $47
	db $3E, $14, $90, $EA, $4A, $C9, $CD, $1B, $D9, $CD, $90, $3C, $FA, $48, $C9, $EA
	db $4A, $C9, $AF, $EA, $48, $C9, $CD, $F1, $78, $FA, $4E, $C9, $3C, $EA, $4E, $C9
	db $FE, $13, $20, $AB, $C9

Func_01_7BC5:
	ld a, [$C953]
	ld [$C943], a
	xor a
	ld [$C948], a
	ld a, $01
	ld [$C949], a
	ld a, $20
	ld [$C94A], a
	call Func_3C90
	call Func_01_78F1
	ret

Func_01_7BE0:
	ld a, [$C953]
	ld [$C943], a
	ld a, $14
	ld [$C94E], a
	ld a, $01
	ld [$C949], a
	ld [$C94A], a
Jump_01_7BF3:
	ld a, [$C94F]
	ld c, a
	ld a, [$C950]
	ld b, a
	ld a, [$C951]
	ld e, a
	ld a, [$C952]
	ld d, a
	ld a, [$C94E]
	dec a
	call Func_01_7AD4
	ldh a, [rSCX]
	srl a
	srl a
	srl a
	dec a
	and $1F
	ld [$C948], a
	call RAM_D91B
	call Audio_Update
	xor a
	ld [wVBlankPending], a
Jump_01_7C22:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_7C22
	xor a
	ld [wVBlankPending], a
	ldh a, [rSCX]
	sub $08
	ldh [rSCX], a
	ld a, [$C94E]
	dec a
	ld [$C94E], a
	jr nz, Jump_01_7BF3
	ret

Func_01_7C3F:
	ld a, [$C953]
	ld [$C943], a
	ld a, $14
	ld [$C94E], a
	ld a, $01
	ld [$C949], a
	ld [$C94A], a
Jump_01_7C52:
	ld a, [$C94F]
	ld c, a
	ld a, [$C950]
	ld b, a
	ld a, [$C951]
	ld e, a
	ld a, [$C952]
	ld d, a
	ld a, [$C94E]
	ld l, a
	ld a, $14
	sub l
	call Func_01_7AD4
	ldh a, [rSCX]
	srl a
	srl a
	srl a
	add a, $14
	and $1F
	ld [$C948], a
	call RAM_D91B
	call Audio_Update
	xor a
	ld [wVBlankPending], a
Jump_01_7C85:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_7C85
	xor a
	ld [wVBlankPending], a
	ldh a, [rSCX]
	add a, $08
	ldh [rSCX], a
	ld a, [$C94E]
	dec a
	ld [$C94E], a
	jr nz, Jump_01_7C52
	ret

Func_01_7CA2:
	ld a, [$C953]
	ld [$C943], a
	ld a, $14
	ld [$C94E], a
	ld a, $01
	ld [$C949], a
	ld [$C94A], a
Jump_01_7CB5:
	call Audio_Update
	xor a
	ld [wVBlankPending], a
Jump_01_7CBC:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_7CBC
	xor a
	ld [wVBlankPending], a
	call Func_3C90
	ldh a, [rSCX]
	srl a
	srl a
	srl a
	add a, $14
	and $1F
	ld [$C948], a
	call Func_01_78F1
	ldh a, [rSCX]
	add a, $08
	ldh [rSCX], a
	ld a, [$C94E]
	dec a
	ld [$C94E], a
	jr nz, Jump_01_7CB5
	ret

	db $C9

Func_01_7CEF:
	ld a, [$C953]
	ld [$C943], a
	ld a, $14
	ld [$C94E], a
	ld a, $01
	ld [$C949], a
	ld [$C94A], a
Jump_01_7D02:
	call Audio_Update
	xor a
	ld [wVBlankPending], a
Jump_01_7D09:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_01_7D09
	xor a
	ld [wVBlankPending], a
	call Func_3C90
	ldh a, [rSCX]
	srl a
	srl a
	srl a
	dec a
	and $1F
	ld [$C948], a
	call Func_01_78F1
	ldh a, [rSCX]
	sub $08
	ldh [rSCX], a
	ld a, [$C94E]
	dec a
	ld [$C94E], a
	jr nz, Jump_01_7D02
	ret

Func_01_7D3A:
	ld d, $40
	ld hl, $D000
Jump_01_7D3F:
	ld e, l
	ld a, $1D
	add a, e
	ld l, a
	ld a, [hl]
	ld l, e
	cp $04
	jr z, Jump_01_7D51
	cp $01
	jr z, Jump_01_7D51
	call Func_2044
Jump_01_7D51:
	ld a, e
	add a, $40
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	dec d
	jr nz, Jump_01_7D3F
	ret

	INCBIN "assets/bank_01/7D5D.bin" ; $2A3 bytes
