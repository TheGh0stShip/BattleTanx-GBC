; BattleTanx (USA) - ROM bank $2A

SECTION "ROM Bank $2A", ROMX[$4000], BANK[$2A]
	INCBIN "assets/bank_2A/4000.bin" ; $21D8 bytes

Func_2A_61D8:
	ld hl, $62A4
	ld d, $00
	xor a
	ldh [rVBK], a
	ld e, $00
	ld d, $80
	ld hl, $62A4
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
	ld hl, $62A4
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
	ld hl, $62A4
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


Func_2A_6230:
	ld hl, $62A4
	ld de, $C6D2
	ld bc, $000E
	call Func_05B7
	ld hl, $62A4
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
	ld hl, $62A4
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld e, a
	ld hl, $62A4
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
Jump_2A_6286:
	xor a
	ld [wVBlankPending], a
Jump_2A_628A:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_2A_628A
	xor a
	ld [wVBlankPending], a
	call Func_3A52
	call Audio_Update
	inc e
	ld a, e
	cp $20
	jr nz, Jump_2A_6286
	ret

	INCBIN "assets/bank_2A/62A4.bin" ; $77E bytes

Func_2A_6A22:
	ld hl, $6AD3
	ld d, $00
	xor a
	ldh [rVBK], a
	ld e, $00
	ld d, $80
	ld hl, $6AD3
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
	ld hl, $6AD3
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
	ld hl, $6AD3
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


Func_2A_6A7A:
	ld hl, $6AD3
	ld de, $C6D2
	ld bc, $000E
	call Func_05B7
	ld hl, $6AD3
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
	ld hl, $6AD3
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld hl, $6AD3
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
Jump_2A_6AC5:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_2A_6AC5
	xor a
	ld [wVBlankPending], a
	ret

	INCBIN "assets/bank_2A/6AD3.bin" ; $C46 bytes

Func_2A_7719:
	call Func_3960
	xor a
	ldh [rVBK], a
	ld a, $88
	ld bc, $4000
	ld d, $80
	ld e, $00
	call Func_0622
	ld a, $90
	ld bc, $4800
	ld d, $80
	ld e, $00
	call Func_0622
	ld a, $01
	ldh [rVBK], a
	ld a, $90
	ld bc, $5000
	ld d, $80
	ld e, $00
	call Func_0622
	ld a, $88
	ld bc, $5800
	ld d, $80
	ld e, $00
	call Func_0622
	ret


Func_2A_7754:
	ld a, $14
	ld [$C6DC], a
	ld a, $12
	ld [$C6DD], a
	ld hl, $9800
	ld bc, $5F44
	ld de, $5D00
	call Func_05C5
	ld hl, $6188
	ld bc, $0008
	call Func_052F
	ret


Func_2A_7774:
	call Func_2A_7719
	call Func_2A_7754
Jump_2A_777A:
	ld e, $04
Jump_2A_777C:
	ld d, $0A
	call Func_3971
	ld a, d
	or a
	jr nz, Jump_2A_7794
	ld a, $04
	sub e
	call Func_2A_7795
	dec e
	jr nz, Jump_2A_777C
	ld a, [$C6B5]
	or a
	jr z, Jump_2A_777A
Jump_2A_7794:
	ret


Func_2A_7795:
	push af
	push bc
	push de
	push hl
	ld hl, $61C8
	add a, a
	add a, a
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
	ld e, a
	ld a, [hl]
	ld d, a
	ld hl, $980F
	xor a
	ld [wVBlankPending], a
Jump_2A_77B4:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_2A_77B4
	xor a
	ld [wVBlankPending], a
	ld a, $0B
	ldh [$FFC1], a
Jump_2A_77C5:
	ld a, $05
	ldh [$FFC0], a
Jump_2A_77C9:
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
	ldh a, [$FFC0]
	dec a
	ldh [$FFC0], a
	jr nz, Jump_2A_77C9
	ld a, $0F
	add a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	ld a, $0F
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	ld a, $1B
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ldh a, [$FFC1]
	dec a
	ldh [$FFC1], a
	jr nz, Jump_2A_77C5
	pop hl
	pop de
	pop bc
	pop af
	ret

	INCBIN "assets/bank_2A/7801.bin" ; $7FF bytes
