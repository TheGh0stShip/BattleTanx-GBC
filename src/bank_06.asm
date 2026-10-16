; BattleTanx (USA) - ROM bank $06

SECTION "ROM Bank $06", ROMX[$4000], BANK[$06]
	INCBIN "assets/bank_06/4000.bin" ; $3CAE bytes

Func_06_7CAE:
	xor a
	ld [$C8FC], a
	ld [$C8E8], a
	ld [$C8E9], a
	ld [$C8F7], a
	ld [$C8F6], a
	ld [$C8E4], a
	ld [$C8E3], a
	ld [$C8F8], a
	ld [$C8F9], a
	ld [$C91B], a
	ld [$C91C], a
	inc a
	ld [$C8FA], a
	ld [$C8FB], a
	ld [wMusicEnabled], a
	ld c, $00
	ld b, $04
	ld hl, $C8EC
Jump_06_7CE1:
	ld a, c
	ld [hli], a
	ld a, $11
	ld [hli], a
	inc c
	dec b
	jr nz, Jump_06_7CE1
	ld hl, $FF30
	ld bc, $4716
	ld d, $10
Jump_06_7CF2:
	ld a, [bc]
	ld [hli], a
	inc bc
	dec d
	jr nz, Jump_06_7CF2
	ld d, $17
	ld bc, $FF10
	ld hl, $4649
Jump_06_7D00:
	ld a, [hli]
	ld [bc], a
	inc bc
	dec d
	jr nz, Jump_06_7D00
	ld hl, $C8FD
	ld b, $1E
	xor a
Jump_06_7D0C:
	ld [hli], a
	dec b
	jr nz, Jump_06_7D0C
	ret


Func_06_7D11:
	ld a, b
	cp $8F
	jr c, Jump_06_7D46
	cp $FE
	jr z, Jump_06_7D24
	xor a
	ld [$C8E8], a
	ld [$C8E9], a
	ldh [rNR51], a
	ret

Jump_06_7D24:
	ld a, c
	cp $F0
	jr nc, Jump_06_7D2E
	ld e, a
	call Func_2F73
	ret

Jump_06_7D2E:
	pop de
	pop hl
	ld hl, $C8EA
	ld a, [hli]
	ld [$C8E8], a
	ld a, [hl]
	ld l, a
	ld [$C8E9], a
	ld a, [$C8E8]
	ld h, a
	push hl
	push de
	xor a
	ldh [rNR51], a
	ret

Jump_06_7D46:
	and $F0
	swap a
	ld d, a
	ld a, b
	and $0F
	ld b, d
	cp $01
	jr z, Jump_06_7D63
	cp $02
	jp z, Jump_06_7E03
	cp $03
	jp z, Jump_06_7E28
	cp $04
	jp z, Jump_06_7E34
	ret

Jump_06_7D63:
	ld a, [$C8E3]
	and a
	ret nz
	ld d, $00
	ld e, b
	dec e
	sla e
	ld hl, $C8EC
	add hl, de
	srl e
	ld a, [hli]
	ld d, a
	ld a, [hl]
	ld [$C8F5], a
	ld a, e
	cp $03
	jr nz, Jump_06_7DA7
	ld a, [$C8F7]
	and a
	jr z, Jump_06_7D8E
	ldh a, [rNR52]
	bit 3, a
	ret nz
	xor a
	ld [$C8F7], a
Jump_06_7D8E:
	ld a, c
	sub $0C
	cp $09
	jr nc, Jump_06_7DA7
	push hl
	push de
	add a, a
	ld hl, $4726
	ld d, $00
	ld e, a
	add hl, de
	ld a, [hli]
	ld [$C8F5], a
	ld a, [hl]
	pop de
	pop hl
	ld d, a
Jump_06_7DA7:
	ld a, d
	add a, a
	add a, a
	ld d, $00
	ld e, a
	ld hl, $476E
	add hl, de
	push hl
	ld e, b
	dec e
	sla e
	ld hl, $4738
	add hl, de
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a
	ld a, b
	cp $03
	jr nz, Jump_06_7DC6
	xor a
	ldh [rNR34], a
Jump_06_7DC6:
	pop hl
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	push hl
	bit 0, b
	jr z, Jump_06_7DD5
	inc de
Jump_06_7DD5:
	bit 2, b
	jr nz, Jump_06_7DEB
	push de
	ld hl, $4662
	ld a, c
	sla a
	ld d, $00
	ld e, a
	add hl, de
	pop de
	ld a, [hl]
	ld [de], a
	inc hl
	inc de
	jr Jump_06_7DEC

Jump_06_7DEB:
	inc de
Jump_06_7DEC:
	ld a, [$C8F5]
	ld c, b
Jump_06_7DF0:
	dec c
	jr z, Jump_06_7DF6
	add a, a
	jr Jump_06_7DF0

Jump_06_7DF6:
	ld c, a
	ldh a, [rNR51]
	or c
	ldh [rNR51], a
	ld a, [hl]
	pop hl
	or [hl]
	or $80
	ld [de], a
	ret

Jump_06_7E03:
	ld a, d
	cp $04
	jr nz, Jump_06_7E0F
	ld a, [$C8F7]
	cp $00
	jr nz, Jump_06_7E1E
Jump_06_7E0F:
	ld a, $11
Jump_06_7E11:
	dec d
	jr z, Jump_06_7E17
	add a, a
	jr Jump_06_7E11

Jump_06_7E17:
	cpl
	ld d, a
	ldh a, [rNR51]
	and d
	ldh [rNR51], a
Jump_06_7E1E:
	pop de
	pop hl
	dec hl
	ld a, c
	ld [$C8E7], a
	push hl
	push de
	ret

Jump_06_7E28:
	ld hl, $C8EC
	ld d, $00
	ld e, b
	dec e
	sla e
	add hl, de
	ld [hl], c
	ret

Jump_06_7E34:
	ld hl, $C8EC
	ld d, $00
	ld e, b
	dec e
	sla e
	add hl, de
	inc hl
	ld [hl], c
	ret


Func_06_7E41:
	bit 7, a
	jr nz, Jump_06_7E9A
	bit 6, a
	jp nz, Jump_06_7ED0
	ld hl, $4000
	add a, a
	add a, a
	add a, a
	ld e, a
	ld a, $00
	adc a, a
	ld d, a
	add hl, de
	ld d, $00
	ld a, [hli]
	ld c, a
	push hl
	cp $04
	jr nz, Jump_06_7E66
	ld a, $37
	ld [$C8F7], a
	ld a, $04
Jump_06_7E66:
	cp $01
	jr nz, Jump_06_7E6D
	ld [$C8F6], a
Jump_06_7E6D:
	dec a
	add a, a
	ld e, a
	ld hl, $4738
	add hl, de
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	pop hl
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
	inc de
	bit 0, c
	jr z, Jump_06_7E8C
	ld a, [hli]
	ld [de], a
	inc de
Jump_06_7E8C:
	ld b, a
	ld a, [hl]
	ld c, a
	ldh a, [rNR51]
	or c
	ldh [rNR51], a
	dec de
	ld a, b
	or $80
	ld [de], a
	ret

Jump_06_7E9A:
	and $7F
	add a, a
	add a, a
	ld hl, $4744
	ld d, $00
	ld e, a
	add hl, de
	ld a, [hli]
	ld [$C8E9], a
	ld [$C8EB], a
	ld a, [hli]
	ld [$C8EA], a
	ld [$C8E8], a
	ld a, [hl]
	ld [$C8F4], a
	ld hl, $C8EC
	ld b, $00
	ld c, $04
Jump_06_7EBE:
	ld a, b
	ld [hli], a
	ld a, $11
	ld [hli], a
	inc b
	dec c
	jr nz, Jump_06_7EBE
	xor a
	ldh [rNR51], a
	ld a, $01
	ld [$C8E7], a
	ret

Jump_06_7ED0:
	ld b, a
	ld a, [$C91B]
	and a
	ret nz
	ld a, [$C91C]
	cp b
	jr nz, Jump_06_7EE4
	xor a
	ld [$C91C], a
	inc a
	ld [$C91B], a
Jump_06_7EE4:
	ld a, b
	and $3F
	ld hl, $4128
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld a, [hli]
	ld [$C8F8], a
	ld a, [hl]
	ld [$C8F9], a
	ld a, $01
	ld [$C8FA], a
	ret


Func_06_7EFD:
	ld a, [$C8F9]
	and a
	ret z
	ld a, [$C8FA]
	dec a
	ld [$C8FA], a
Jump_06_7F09:
	and a
	ret nz
	ld hl, $C8F8
	ld a, [hli]
	ld b, a
	ld h, [hl]
	ld l, b
	ld a, [hli]
	cp $FF
	jp z, Jump_06_7FC5
	bit 0, a
	jr nz, Jump_06_7F35
	bit 6, a
	jr nz, Jump_06_7F29
	ldh a, [rNR51]
	and $EE
	ldh [rNR51], a
	jp Jump_06_7FB4

Jump_06_7F29:
	ldh a, [rNR51]
	and $77
	ldh [rNR51], a
	xor a
	ld [$C8F7], a
	jr Jump_06_7FB4

Jump_06_7F35:
	and $F0
	cp $20
	jr z, Jump_06_7F8F
	ld a, [hli]
	push hl
	ld hl, $4000
	add a, a
	add a, a
	add a, a
	ld e, a
	ld a, $00
	adc a, a
	ld d, a
	add hl, de
	ld d, $00
	ld a, [hli]
	ld c, a
	push hl
	cp $04
	jr nz, Jump_06_7F59
	ld a, $37
	ld [$C8F7], a
	ld a, $04
Jump_06_7F59:
	cp $01
	jr nz, Jump_06_7F60
	ld [$C8F6], a
Jump_06_7F60:
	dec a
	add a, a
	ld e, a
	ld hl, $4738
	add hl, de
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	pop hl
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
	inc de
	bit 0, c
	jr z, Jump_06_7F7F
	ld a, [hli]
	ld [de], a
	inc de
Jump_06_7F7F:
	ld b, a
	ld a, [hl]
	ld c, a
	ldh a, [rNR51]
	or c
	ldh [rNR51], a
	dec de
	ld a, b
	or $80
	ld [de], a
	pop hl
	jr Jump_06_7FB4

Jump_06_7F8F:
	ld a, $86
	ldh [rNR10], a
	ld a, $40
	ldh [rNR11], a
	ld a, $F7
	ldh [rNR12], a
	ldh a, [rNR51]
	or $11
	ldh [rNR51], a
	ld a, [hli]
	push hl
	ld hl, $4662
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld a, [hli]
	ldh [rNR13], a
	ld a, [hl]
	or $80
	ldh [rNR14], a
	pop hl
Jump_06_7FB4:
	ld a, [hli]
	ld [$C8FA], a
	ld b, a
	ld a, l
	ld [$C8F8], a
	ld a, h
	ld [$C8F9], a
	ld a, b
	jp Jump_06_7F09

Jump_06_7FC5:
	ld hl, $C8F8
	xor a
	ld [hli], a
	ld [hli], a
	ld [$C91B], a
	inc a
	ld [hl], a
	ret

	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $06
