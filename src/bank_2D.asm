; BattleTanx (USA) - ROM bank $2D

SECTION "ROM Bank $2D", ROMX[$4000], BANK[$2D]

Func_2D_4000:
	ld hl, $40CC
	ld d, $00
	xor a
	ldh [rVBK], a
	ld e, $00
	ld d, $80
	ld hl, $40CC
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld a, $88
	call Func_0622
	ld e, $80
	ld d, $00
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	ld hl, $40CC
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
	ld c, l
	ld b, h
	ld e, $00
	ld d, $80
	ld a, $90
	call Func_0622
	ld a, $01
	ldh [rVBK], a
	ld e, $00
	ld d, $10
	ld hl, $40CC
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
	ld b, h
	ld c, l
	ld e, $00
	ld d, $80
	ld a, $90
	call Func_0622
	ret


Func_2D_4058:
	ld hl, $40CC
	ld de, $C6D2
	ld bc, $000E
	call Func_05B7
	ld hl, $40CC
	ld bc, $0002
	add hl, bc
	ld a, [hli]
	ld e, a
	ld d, [hl]
	inc hl
	ld a, [hli]
	ld c, a
	ld b, [hl]
	push bc
	ld hl, sp + 4
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $9800
	add hl, bc
	pop bc
	call Func_05C5
	ld hl, $40CC
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld e, a
	ld hl, $40CC
	ld a, $06
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [ROM_BANK_MARKER]
	ld d, a
	ld e, $40
	call Func_3A88
	ld a, $00
	ld [$C6D1], a
	call Func_3A2F
	ld e, $00
Jump_2D_40AE:
	xor a
	ld [wVBlankPending], a
Jump_2D_40B2:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_2D_40B2
	xor a
	ld [wVBlankPending], a
	call Func_3A52
	call Audio_Update
	inc e
	ld a, e
	cp $20
	jr nz, Jump_2D_40AE
	ret

	INCBIN "assets/bank_2D/40CC.bin" ; $142E bytes

Func_2D_54FA:
	ld hl, $55C6
	ld d, $00
	xor a
	ldh [rVBK], a
	ld e, $00
	ld d, $80
	ld hl, $55C6
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld a, $88
	call Func_0622
	ld e, $80
	ld d, $00
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	ld hl, $55C6
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
	ld c, l
	ld b, h
	ld e, $00
	ld d, $80
	ld a, $90
	call Func_0622
	ld a, $01
	ldh [rVBK], a
	ld e, $00
	ld d, $10
	ld hl, $55C6
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
	ld b, h
	ld c, l
	ld e, $00
	ld d, $80
	ld a, $90
	call Func_0622
	ret


Func_2D_5552:
	ld hl, $55C6
	ld de, $C6D2
	ld bc, $000E
	call Func_05B7
	ld hl, $55C6
	ld bc, $0002
	add hl, bc
	ld a, [hli]
	ld e, a
	ld d, [hl]
	inc hl
	ld a, [hli]
	ld c, a
	ld b, [hl]
	push bc
	ld hl, sp + 4
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $9800
	add hl, bc
	pop bc
	call Func_05C5
	ld hl, $55C6
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld e, a
	ld hl, $55C6
	ld a, $06
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [ROM_BANK_MARKER]
	ld d, a
	ld e, $40
	call Func_3A88
	ld a, $00
	ld [$C6D1], a
	call Func_3A2F
	ld e, $00
Jump_2D_55A8:
	xor a
	ld [wVBlankPending], a
Jump_2D_55AC:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_2D_55AC
	xor a
	ld [wVBlankPending], a
	call Func_3A52
	call Audio_Update
	inc e
	ld a, e
	cp $20
	jr nz, Jump_2D_55A8
	ret

	INCBIN "assets/bank_2D/55C6.bin" ; $2A3A bytes
