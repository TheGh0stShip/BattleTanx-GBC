; BattleTanx (USA) - ROM bank $2B

SECTION "ROM Bank $2B", ROMX[$4000], BANK[$2B]

Func_2B_4000:
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


Func_2B_4058:
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
	ld a, [$7FFF]
	ld d, a
	ld e, $40
	call Func_3A88
	ld a, $01
	ld [$C6D1], a
	call Func_3A2F
	ld e, $00
Jump_2B_40AE:
	xor a
	ld [$C6C0], a
Jump_2B_40B2:
	halt
	nop
	nop
	ld a, [$C6C0]
	or a
	jr z, Jump_2B_40B2
	xor a
	ld [$C6C0], a
	call Func_3A52
	call Func_2F21
	inc e
	ld a, e
	cp $20
	jr nz, Jump_2B_40AE
	ret

	INCBIN "assets/bank_2B/40CC.bin" ; $1B0E bytes

Func_2B_5BDA:
	ld hl, $5CA6
	ld d, $00
	xor a
	ldh [rVBK], a
	ld e, $00
	ld d, $80
	ld hl, $5CA6
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
	ld hl, $5CA6
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
	ld hl, $5CA6
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


Func_2B_5C32:
	ld hl, $5CA6
	ld de, $C6D2
	ld bc, $000E
	call Func_05B7
	ld hl, $5CA6
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
	ld hl, $5CA6
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld e, a
	ld hl, $5CA6
	ld a, $06
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [$7FFF]
	ld d, a
	ld e, $40
	call Func_3A88
	ld a, $00
	ld [$C6D1], a
	call Func_3A2F
	ld e, $00
Jump_2B_5C88:
	xor a
	ld [$C6C0], a
Jump_2B_5C8C:
	halt
	nop
	nop
	ld a, [$C6C0]
	or a
	jr z, Jump_2B_5C8C
	xor a
	ld [$C6C0], a
	call Func_3A52
	call Func_2F21
	inc e
	ld a, e
	cp $20
	jr nz, Jump_2B_5C88
	ret

	INCBIN "assets/bank_2B/5CA6.bin" ; $11C6 bytes

Func_2B_6E6C:
	ld hl, $6F1D
	ld d, $00
	xor a
	ldh [rVBK], a
	ld e, $00
	ld d, $80
	ld hl, $6F1D
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
	ld hl, $6F1D
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
	ld hl, $6F1D
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


Func_2B_6EC4:
	ld hl, $6F1D
	ld de, $C6D2
	ld bc, $000E
	call Func_05B7
	ld hl, $6F1D
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
	ld hl, $6F1D
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld hl, $6F1D
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
	ld [$C6C0], a
Jump_2B_6F0F:
	halt
	nop
	nop
	ld a, [$C6C0]
	or a
	jr z, Jump_2B_6F0F
	xor a
	ld [$C6C0], a
	ret

	INCBIN "assets/bank_2B/6F1D.bin" ; $10E3 bytes
