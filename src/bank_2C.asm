; BattleTanx (USA) - ROM bank $2C

SECTION "ROM Bank $2C", ROMX[$4000], BANK[$2C]

Func_2C_4000:
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


Func_2C_4058:
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
Jump_2C_40AE:
	xor a
	ld [wVBlankPending], a
Jump_2C_40B2:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_2C_40B2
	xor a
	ld [wVBlankPending], a
	call Func_3A52
	call Func_2F21
	inc e
	ld a, e
	cp $20
	jr nz, Jump_2C_40AE
	ret

	INCBIN "assets/bank_2C/40CC.bin" ; $A6E bytes

Func_2C_4B3A:
	ld hl, $4C06
	ld d, $00
	xor a
	ldh [rVBK], a
	ld e, $00
	ld d, $80
	ld hl, $4C06
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
	ld hl, $4C06
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
	ld hl, $4C06
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


Func_2C_4B92:
	ld hl, $4C06
	ld de, $C6D2
	ld bc, $000E
	call Func_05B7
	ld hl, $4C06
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
	ld hl, $4C06
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld e, a
	ld hl, $4C06
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
Jump_2C_4BE8:
	xor a
	ld [wVBlankPending], a
Jump_2C_4BEC:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_2C_4BEC
	xor a
	ld [wVBlankPending], a
	call Func_3A52
	call Func_2F21
	inc e
	ld a, e
	cp $20
	jr nz, Jump_2C_4BE8
	ret

	INCBIN "assets/bank_2C/4C06.bin" ; $9BE bytes

Func_2C_55C4:
	ld hl, $5675
	ld d, $00
	xor a
	ldh [rVBK], a
	ld e, $00
	ld d, $80
	ld hl, $5675
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
	ld hl, $5675
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
	ld hl, $5675
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


Func_2C_561C:
	ld hl, $5675
	ld de, $C6D2
	ld bc, $000E
	call Func_05B7
	ld hl, $5675
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
	ld hl, $5675
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld hl, $5675
	ld a, $06
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call Func_052F
	xor a
	ld [wVBlankPending], a
Jump_2C_5667:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_2C_5667
	xor a
	ld [wVBlankPending], a
	ret

	INCBIN "assets/bank_2C/5675.bin" ; $85E bytes

Func_2C_5ED3:
	ld hl, $606B
	ld d, $00
	xor a
	ldh [rVBK], a
	ld e, $00
	ld d, $80
	ld hl, $606B
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
	ld hl, $606B
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
	ld hl, $606B
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


Func_2C_5F2B:
	ld hl, $606B
	ld de, $C6D2
	ld bc, $000E
	call Func_05B7
	ld hl, $606B
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
	ld hl, $606B
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld e, a
	ld hl, $606B
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
Jump_2C_5F81:
	xor a
	ld [wVBlankPending], a
Jump_2C_5F85:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_2C_5F85
	xor a
	ld [wVBlankPending], a
	call Func_3A52
	call Func_2F21
	inc e
	ld a, e
	cp $20
	jr nz, Jump_2C_5F81
	ret


Func_2C_5F9F:
	ld hl, $7DF9
	ld d, $00
	xor a
	ldh [rVBK], a
	ld e, $00
	ld d, $80
	ld hl, $7DF9
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
	ld hl, $7DF9
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
	ld hl, $7DF9
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


Func_2C_5FF7:
	ld hl, $7DF9
	ld de, $C6D2
	ld bc, $000E
	call Func_05B7
	ld hl, $7DF9
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
	ld hl, $7DF9
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld e, a
	ld hl, $7DF9
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
Jump_2C_604D:
	xor a
	ld [wVBlankPending], a
Jump_2C_6051:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_2C_6051
	xor a
	ld [wVBlankPending], a
	call Func_3A52
	call Func_2F21
	inc e
	ld a, e
	cp $20
	jr nz, Jump_2C_604D
	ret

	INCBIN "assets/bank_2C/606B.bin" ; $1F95 bytes
