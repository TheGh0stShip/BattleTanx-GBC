; BattleTanx (USA) - ROM bank $03

SECTION "ROM Bank $03", ROMX[$4000], BANK[$03]

; Five four-byte lookup rows selected from the magnitudes of signed B/C inputs.
SignedVectorDirectionLookup:
	db $00, $40, $40, $00
	db $08, $38, $38, $08
	db $10, $30, $30, $10
	db $18, $28, $32, $18
	db $20, $20, $20, $20

; Added to that lookup according to the input vector's sign quadrant.
SignedVectorQuadrantOffsets:
	db $40, $80, $00, $C0

	INCLUDE "src/level_object_sequences.asm"

LevelObjectSequenceTables:
	dw Level00ObjectSequences, Level01ObjectSequences, Level02ObjectSequences
	dw Level03ObjectSequences, Level04ObjectSequences, Level05ObjectSequences
	dw Level06ObjectSequences, Level07ObjectSequences, Level08ObjectSequences
	dw Level09ObjectSequences, Level10ObjectSequences, Level11ObjectSequences
	dw Level12ObjectSequences, Level13ObjectSequences, Level14ObjectSequences
ASSERT @ == $5C11

InitializeObjectSequenceState:
	push af
	push bc
	push de
	push hl
	push hl
	push bc
	push hl
	ld a, [$CA06]
	ld h, $00
	ld l, a
	add hl, hl
	ld bc, LevelObjectSequenceTables
	add hl, bc
	ld a, [hli]
	ld [wLevelObjectSequenceTable], a
	ld a, [hl]
	ld [wLevelObjectSequenceTable + 1], a
	pop hl
	ld a, l
	and $C0
	add a, $2D
	ld l, a
	pop af
	ld [hl], a
	ld a, l
	and $C0
	add a, $32
	ld l, a
	ld a, $01
	ld [hl], a
	ld a, l
	and $C0
	add a, $2E
	ld l, a
	xor a
	ld [hl], a
	ld a, l
	and $C0
	add a, $31
	ld l, a
	xor a
	ld [hl], a
	pop de
	ld a, e
	and $C0
	add a, $2D
	ld e, a
	ld a, [de]
	ld l, a
	ld h, $00
	add hl, hl
	ld b, h
	ld c, l
	ld a, [wLevelObjectSequenceTable]
	ld l, a
	ld a, [wLevelObjectSequenceTable + 1]
	ld h, a
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc hl
	push hl
	ld a, e
	and $C0
	add a, $2E
	ld e, a
	ld a, [de]
	ld h, $00
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld b, h
	ld c, l
	pop hl
	add hl, bc
	ld a, e
	and $C0
	add a, $2F
	ld e, a
	ld a, [hli]
	ld [de], a
	inc hl
	inc hl
	push de
	push hl
	push de
	ld a, [hli]
	push hl
	ld h, $00
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld b, h
	ld c, l
	pop de
	ld a, [de]
	ld h, $00
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld d, h
	ld e, l
	pop hl
	call SetObjectPosition
	pop hl
	ld bc, $0008
	add hl, bc
	ld a, [hli]
	push hl
	ld h, $00
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld b, h
	ld c, l
	pop de
	ld a, [de]
	ld h, $00
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld d, h
	ld e, l
	pop hl
	ld a, l
	and $C0
	add a, $34
	ld l, a
	ld [hl], c
	inc hl
	ld [hl], b
	ld a, l
	and $C0
	add a, $36
	ld l, a
	ld [hl], e
	inc hl
	ld [hl], d
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_03_5CD0:
	push af
	push bc
	push de
	push hl
	ld e, l
	ld d, h
	xor a
	ld [$CD29], a
	ld a, e
	and $C0
	add a, $1E
	ld e, a
	ld a, [de]
	cp $02
	jp nz, Jump_03_5CED
	ld a, [$CD2A]
	inc a
	ld [$CD2A], a
Jump_03_5CED:
	ld a, e
	and $C0
	add a, $08
	ld e, a
	ld a, [de]
	and $08
	jr nz, Jump_03_5D1A
	ld a, e
	and $C0
	add a, $1E
	ld e, a
	ld a, [de]
	cp $03
	jp z, Jump_03_5FBA
	ld a, [$CD28]
	inc a
	ld [$CD28], a
	and $07
	jr z, Jump_03_5D1A
	ld a, e
	and $C0
	add a, $1A
	ld e, a
	xor a
	ld [de], a
	jp Jump_03_5FBA

Jump_03_5D1A:
	call Func_03_6429
	ld a, e
	and $C0
	add a, $2D
	ld e, a
	ld a, [de]
	bit 6, a
	jp nz, Jump_03_661F
	ld a, e
	and $C0
	add a, $33
	ld e, a
	ld a, [de]
	and a
	jr nz, Jump_03_5D54
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
	ld h, a
	ld a, l
	and $C0
	add a, $27
	ld l, a
	ld a, [hl]
	and a
	jr z, Jump_03_5D4F
	ld a, l
	and $C0
	add a, $28
	ld l, a
	ld a, [hl]
	and a
	jr z, Jump_03_5D65
Jump_03_5D4F:
	call Func_03_60AF
	jr Jump_03_5D65

Jump_03_5D54:
	dec a
	ld [de], a
	cp $20
	jr c, Jump_03_5D65
	ld a, e
	and $C0
	add a, $1A
	ld e, a
	xor a
	ld [de], a
	jp Jump_03_5FBA

Jump_03_5D65:
	ld a, e
	and $C0
	add a, $19
	ld e, a
	ld a, [de]
	ld b, a
	ld a, e
	and $C0
	add a, $2F
	ld e, a
	ld a, [de]
	cp b
	jr z, Jump_03_5DB9
	ld a, e
	and $C0
	add a, $1A
	ld e, a
	xor a
	ld [de], a
	ld a, e
	and $C0
	add a, $30
	ld e, a
	ld a, [de]
	and a
	jr z, Jump_03_5D8E
	dec a
	ld [de], a
	jp Jump_03_5FBA

Jump_03_5D8E:
	push de
	ld a, e
	and $C0
	add a, $23
	ld e, a
	ld a, [de]
	pop de
	ld [de], a
	ld a, e
	and $C0
	add a, $32
	ld e, a
	ld a, [de]
	ld c, a
	ld a, e
	and $C0
	add a, $19
	ld e, a
	ld a, [de]
	add a, c
	and $0F
	ld [de], a
	ld a, e
	and $C0
	add a, $3C
	ld e, a
	ld a, [de]
	bit 7, a
	jr nz, Jump_03_5DB9
	jp Jump_03_5FBA

Jump_03_5DB9:
	ld a, e
	and $C0
	add a, $3C
	ld e, a
	ld a, [de]
	ld b, a
	and a
	jr z, Jump_03_5DF5
	bit 7, a
	jr z, Jump_03_5DE2
	and $7F
	dec a
	jr nz, Jump_03_5DD1
	xor a
	ld [de], a
	jr Jump_03_5DF5

Jump_03_5DD1:
	or $80
	ld [de], a
	ld a, e
	and $C0
	add a, $2F
	ld e, a
	ld a, [de]
	inc a
	and $0F
	ld [de], a
	jp Jump_03_5FBA

Jump_03_5DE2:
	ld a, [wObjectSlowTickCounter]
	and a
	jp nz, Jump_03_5FBA
	ld a, e
	and $C0
	add a, $3C
	ld e, a
	ld a, b
	dec a
	ld [de], a
	jp Jump_03_5FBA

Jump_03_5DF5:
	ld a, e
	and $C0
	add a, $2D
	ld e, a
	ld a, [de]
	bit 7, a
	jp nz, Jump_03_5FBA
	ld a, e
	and $C0
	add a, $2F
	ld e, a
	ld a, [de]
	ld b, a
	ld a, e
	and $C0
	add a, $19
	ld e, a
	ld a, [de]
	cp b
	jp nz, Jump_03_5FBA
	ld a, e
	and $C0
	add a, $38
	ld e, a
	ld a, [de]
	and $F0
	jp z, Jump_03_5FBA
	push de
	ld l, e
	ld h, d
	ld bc, Func_03_5E5C
	push bc
	ld a, l
	and $C0
	add a, $36
	ld l, a
	ld a, [hli]
	ld e, a
	ld d, [hl]
	ld a, l
	and $C0
	add a, $16
	ld l, a
	inc hl
	ld a, [hli]
	ld c, a
	ld b, [hl]
	push bc
	push de
	ld a, l
	and $C0
	add a, $34
	ld l, a
	ld a, [hli]
	ld e, a
	ld d, [hl]
	ld a, l
	and $C0
	add a, $13
	ld l, a
	inc hl
	ld a, [hli]
	ld c, a
	ld b, [hl]
	push bc
	push de
	ld a, l
	and $C0
	add a, $2F
	ld l, a
	ld a, [hl]
	ld h, a
	jp Jump_03_6987

Func_03_5E5C:
	pop de
	ld a, l
	and a
	jr z, Jump_03_5E91
	ld a, e
	and $C0
	add a, $34
	ld e, a
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	ld b, a
	ld a, e
	and $C0
	add a, $13
	ld e, a
	inc de
	ld a, c
	ld [de], a
	inc de
	ld a, b
	ld [de], a
	ld a, e
	and $C0
	add a, $36
	ld e, a
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	ld b, a
	ld a, e
	and $C0
	add a, $16
	ld e, a
	inc de
	ld a, c
	ld [de], a
	inc de
	ld a, b
	ld [de], a
	jr Jump_03_5EB0

Jump_03_5E91:
	ld a, e
	and $C0
	add a, $38
	ld e, a
	ld a, [de]
	and $F0
	jp z, Jump_03_5FBA
	ld a, e
	and $C0
	add a, $39
	ld e, a
	ld a, [de]
	push af
	ld a, e
	and $C0
	add a, $1A
	ld e, a
	pop af
	ld [de], a
	jp Jump_03_5FBA

Jump_03_5EB0:
	ld a, e
	and $C0
	add a, $2E
	ld e, a
	ld a, [de]
	ld b, a
	ld a, e
	and $C0
	add a, $31
	ld e, a
	ld a, [de]
	and a
	jr z, Jump_03_5ED3
	dec b
	ld a, b
	and a
	jr nz, Jump_03_5ED2
	ld a, e
	and $C0
	add a, $31
	ld e, a
	ld a, [de]
	cpl
	ld [de], a
	ld b, $00
Jump_03_5ED2:
	dec b
Jump_03_5ED3:
	ld a, e
	and $C0
	add a, $2E
	ld e, a
	inc b
	ld a, b
	ld [de], a
	ld a, e
	and $C0
	add a, $1A
	ld e, a
	xor a
	ld [de], a
	ld a, e
	and $C0
	add a, $2D
	ld e, a
	ld a, [de]
	ld h, $00
	ld l, a
	add hl, hl
	ld b, h
	ld c, l
	ld a, [wLevelObjectSequenceTable]
	ld l, a
	ld a, [wLevelObjectSequenceTable + 1]
	ld h, a
	add hl, bc
	ld a, [hl]
	ld c, a
	inc hl
	ld a, [hl]
	ld h, a
	ld l, c
	inc hl
	push hl
	ld a, e
	and $C0
	add a, $2E
	ld e, a
	ld a, [de]
	ld h, $00
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld b, h
	ld c, l
	pop hl
	add hl, bc
	ld a, [hli]
	ld b, a
	ld a, e
	and $C0
	add a, $31
	ld e, a
	ld a, [de]
	and a
	jr z, Jump_03_5F30
	push hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	ld a, [hl]
	add a, $08
	and $0F
	ld b, a
	pop hl
Jump_03_5F30:
	ld a, e
	and $C0
	add a, $2F
	ld e, a
	ld a, b
	ld [de], a
	ld c, $FF
	ld a, e
	and $C0
	add a, $19
	ld e, a
	ld a, [de]
	sub b
	jr nc, Jump_03_5F46
	ld c, $01
Jump_03_5F46:
	ld a, e
	and $C0
	add a, $32
	ld e, a
	ld a, c
	ld [de], a
	ld a, e
	and $C0
	add a, $31
	ld e, a
	ld a, [de]
	and a
	jr z, Jump_03_5F66
	push hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	pop hl
	inc hl
	inc hl
	jr Jump_03_5F68

Jump_03_5F66:
	inc hl
	inc hl
Jump_03_5F68:
	call Func_03_5FF2
	inc hl
	inc hl
	ld a, [hli]
	and a
	jr z, Jump_03_5FBA
	cp $01
	jr z, Jump_03_5F9A
	cp $02
	jr z, Jump_03_5FA5
	cp $03
	jr z, Jump_03_5F85
	cp $04
	jr z, Jump_03_5F8F
	cp $05
	jr z, Jump_03_5FBA
Jump_03_5F85:
	ld a, e
	and $C0
	add a, $3C
	ld e, a
	ld a, [hl]
	ld [de], a
	jr Jump_03_5FBA

Jump_03_5F8F:
	ld a, e
	and $C0
	add a, $3C
	ld e, a
	ld a, $91
	ld [de], a
	jr Jump_03_5FBA

Jump_03_5F9A:
	ld a, e
	and $C0
	add a, $2E
	ld e, a
	ld a, $FF
	ld [de], a
	jr Jump_03_5FBA

Jump_03_5FA5:
	cp $02
	jr nz, Jump_03_5FBA
	ld a, e
	and $C0
	add a, $31
	ld e, a
	ld a, [de]
	cpl
	ld [de], a
	dec hl
	dec hl
	dec hl
	call Func_03_5FF2
	jr Jump_03_5FBA

Jump_03_5FBA:
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_03_5FBF:
	push de
	push hl
	push de
	inc hl
	inc hl
	ld a, [hl]
	and a
	jr z, Jump_03_5FC8
Jump_03_5FC8:
	ld bc, $0008
	add hl, bc
	ld a, [hli]
	push hl
	ld h, $00
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld b, h
	ld c, l
	pop de
	ld a, [de]
	ld h, $00
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld d, h
	ld e, l
	pop hl
	ld a, l
	and $C0
	add a, $34
	ld l, a
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	ld a, e
	ld [hli], a
	ld a, d
	ld [hl], a
	pop hl
	pop de
	ret


Func_03_5FF2:
	push de
	push hl
	push de
	inc hl
	inc hl
	ld a, [hl]
	and a
	jr z, Jump_03_6025
	cp $01
	jr nz, Jump_03_6021
	ld a, e
	and $C0
	add a, $2D
	ld e, a
	ld a, [de]
	ld l, a
	ld h, $00
	add hl, hl
	ld b, h
	ld c, l
	ld a, [wLevelObjectSequenceTable]
	ld l, a
	ld a, [wLevelObjectSequenceTable + 1]
	ld h, a
	add hl, bc
	ld a, [hl]
	ld c, a
	inc hl
	ld a, [hl]
	ld h, a
	ld l, c
	inc hl
	inc hl
	inc hl
	inc hl
	jr Jump_03_603F

Jump_03_6021:
	cp $02
	jr nz, Jump_03_6025
Jump_03_6025:
	dec hl
	dec hl
	ld a, e
	and $C0
	add a, $31
	ld e, a
	ld a, [de]
	and a
	jr z, Jump_03_603B
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	jr Jump_03_603F

Jump_03_603B:
	ld bc, $0008
	add hl, bc
Jump_03_603F:
	ld a, [hli]
	push hl
	ld h, $00
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld b, h
	ld c, l
	pop de
	ld a, [de]
	ld h, $00
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld d, h
	ld e, l
	pop hl
	ld a, l
	and $C0
	add a, $34
	ld l, a
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	ld a, e
	ld [hli], a
	ld a, d
	ld [hl], a
	pop hl
	pop de
	ret

Jump_03_6065:
	pop bc
	pop de
	ld a, c
	sub e
	ld e, a
	ld a, b
	sbc a, d
	ld d, a
	and $80
	jr z, Jump_03_607B
	ld a, e
	cpl
	add a, $01
	ld e, a
	ld a, d
	cpl
	adc a, $00
	ld d, a
Jump_03_607B:
	ld a, $00
	cp d
	jr nz, Jump_03_60AA
	ld a, h
	cp e
	jr c, Jump_03_60AA
	ld l, $01
	pop bc
	pop de
	ld a, c
	sub e
	ld e, a
	ld a, b
	sbc a, d
	ld d, a
	and $80
	jr z, Jump_03_609C
	ld a, e
	cpl
	add a, $01
	ld e, a
	ld a, d
	cpl
	adc a, $00
	ld d, a
Jump_03_609C:
	ld a, $00
	cp d
	jr nz, Jump_03_60AC
	ld a, h
	cp e
	jr c, Jump_03_60AC
	ld a, l
	or $02
	ld l, a
	ret

Jump_03_60AA:
	pop bc
	pop de
Jump_03_60AC:
	ld l, $00
	ret


Func_03_60AF:
	push de
	ld bc, Func_03_611C
	push bc
	ld l, e
	ld h, d
	ld a, l
	and $C0
	add a, $1E
	ld l, a
	ld a, [hl]
	ld b, $55
	cp $00
	jr z, Jump_03_60D1
	ld b, $55
	cp $02
	jr z, Jump_03_60D1
	ld b, $55
	cp $01
	jr z, Jump_03_60D1
	ld b, $55
Jump_03_60D1:
	ld a, b
	ld [$CD26], a
	ld a, l
	and $C0
	add a, $16
	ld l, a
	inc hl
	ld a, [hli]
	ld e, a
	ld d, [hl]
	push hl
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
	ld h, a
	ld a, l
	and $C0
	add a, $16
	ld l, a
	inc hl
	ld a, [hli]
	ld c, a
	ld b, [hl]
	pop hl
	push bc
	push de
	ld a, l
	and $C0
	add a, $13
	ld l, a
	inc hl
	ld a, [hli]
	ld e, a
	ld d, [hl]
	push hl
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
	ld h, a
	ld a, l
	and $C0
	add a, $13
	ld l, a
	inc hl
	ld a, [hli]
	ld c, a
	ld b, [hl]
	pop hl
	push bc
	push de
	ld a, [$CD26]
	ld h, a
	jp Jump_03_6065

Func_03_611C:
	pop de
	ld a, l
	and a
	jr nz, Jump_03_614E
	ld a, e
	and $C0
	add a, $3B
	ld e, a
	ld a, [de]
	bit 7, a
	jr nz, Jump_03_615D
	ld a, e
	and $C0
	add a, $38
	ld e, a
	ld a, [de]
	and $F0
	ret nz
	ld a, [de]
	ld b, a
	ld a, $80
	ld [de], a
	ld a, e
	and $C0
	add a, $1E
	ld e, a
	ld a, [de]
	cp $03
	ret z
	ld a, e
	and $C0
	add a, $2F
	ld e, a
	ld a, b
	ld [de], a
	ret

Jump_03_614E:
	ld a, [$CD26]
	cp $55
	ld a, e
	and $C0
	add a, $3B
	ld e, a
	ld a, [de]
	or $80
	ld [de], a
Jump_03_615D:
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
	ld h, a
	ld a, l
	and $C0
	add a, $06
	ld l, a
	ld c, [hl]
	ld a, e
	and $C0
	add a, $06
	ld e, a
	ld a, [de]
	sub c
	ld c, a
	ld a, l
	and $C0
	add a, $07
	ld l, a
	ld b, [hl]
	ld a, e
	and $C0
	add a, $07
	ld e, a
	ld a, [de]
	sub b
	ld b, a
	push de
	call QuantizeSignedVectorDirection
	pop de
	srl a
	srl a
	srl a
	srl a
	sub $08
	and $0F
	ld b, a
	ld c, $FF
	ld a, e
	and $C0
	add a, $19
	ld e, a
	ld a, [de]
	sub b
	jr nc, Jump_03_61A5
	ld c, $01
Jump_03_61A5:
	ld a, e
	and $C0
	add a, $32
	ld e, a
	ld a, c
	ld [de], a
	ld a, e
	and $C0
	add a, $2F
	ld e, a
	ld a, [de]
	ld c, a
	ld a, b
	ld [de], a
	ld a, e
	and $C0
	add a, $38
	ld e, a
	ld a, [de]
	and $F0
	jr z, Jump_03_61C5
	ld a, c
	ld [de], a
	ret

Jump_03_61C5:
	ld a, e
	and $C0
	add a, $2F
	ld e, a
	ld a, [de]
	ld b, a
	ld a, e
	and $C0
	add a, $19
	ld e, a
	ld a, [de]
	cp b
	ret nz
	ld a, e
	and $C0
	add a, $33
	ld e, a
	ld a, $28
	ld [de], a
	push de
	ld l, e
	ld h, d
	ld a, [wPlayerAlive]
	and a
	jp z, Jump_03_62E5
	ld a, l
	and $C0
	add a, $3B
	ld l, a
	ld a, [hl]
	and $7F
	ld [hl], a
	call Func_0F98
	jp nz, Jump_03_62A8
	jp Jump_03_62E5


Func_03_61FC:
	ld l, e
	ld h, d
	ld a, [$CD15]
	and a
	jp z, Jump_03_62A5
	ld a, l
	and $C0
	add a, $2D
	ld l, a
	ld a, [hl]
	bit 6, a
	jp nz, Jump_03_62A5
	or $40
	ld [hl], a
	ld [$CD29], a
	xor a
	ld [$CD17], a
	call Func_03_6575
	xor a
	ld [$CD29], a
	push bc
	push hl
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
	ld h, a
	ld a, l
	and $C0
	add a, $06
	ld l, a
	ld c, [hl]
	ld a, e
	and $C0
	add a, $06
	ld e, a
	ld a, [de]
	sub c
	ld c, a
	ld a, l
	and $C0
	add a, $07
	ld l, a
	ld b, [hl]
	ld a, e
	and $C0
	add a, $07
	ld e, a
	ld a, [de]
	sub b
	ld b, a
	push de
	push hl
	call QuantizeSignedVectorDirection
	pop hl
	pop de
	srl a
	srl a
	srl a
	srl a
	sub $08
	and $0F
	ld b, a
	ld a, l
	and $C0
	add a, $2F
	ld l, a
	ld [hl], b
	pop hl
	pop bc
	push bc
	push hl
	ld a, l
	and $C0
	add a, $2E
	ld l, a
	ld a, [$CD15]
	ld [hl], a
	pop hl
	push hl
	ld a, l
	and $C0
	add a, $2E
	ld l, a
	ld a, [hl]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, $CDEF
	add hl, de
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld a, [hl]
	pop hl
	ld a, l
	and $C0
	add a, $34
	ld l, a
	ld [hl], c
	inc hl
	ld [hl], b
	ld a, l
	and $C0
	add a, $36
	ld l, a
	ld [hl], e
	inc hl
	ld [hl], d
	pop bc
Jump_03_62A5:
	push hl
	jr Jump_03_62E5

Jump_03_62A8:
	push bc
	ld a, l
	and $C0
	add a, $06
	ld l, a
	ld b, [hl]
	ld a, l
	and $C0
	add a, $07
	ld l, a
	ld c, [hl]
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
	ld h, a
	ld a, l
	and $C0
	add a, $06
	ld l, a
	ld d, [hl]
	ld a, l
	and $C0
	add a, $07
	ld l, a
	ld e, [hl]
	pop hl
	call Func_03_62E7
	pop de
	ld a, e
	and $C0
	add a, $29
	ld e, a
	ld a, [de]
	cp $00
	ret z
	ld a, l
	and $C0
	add a, $29
	ld l, a
	xor a
	ld [hl], a
	ret

Jump_03_62E5:
	pop de
	ret


Func_03_62E7:
	push bc
	push de
	push hl
	ld a, b
	sub d
	jr nc, Jump_03_62EF
	cpl
Jump_03_62EF:
	ld b, a
	ld a, c
	sub e
	jr nc, Jump_03_62F5
	cpl
Jump_03_62F5:
	ld c, a
	push bc
	add a, b
	srl a
	ld c, a
	and a
	ld de, $0000
	jr z, Jump_03_6312
	ld h, b
	ld l, $00
Jump_03_6304:
	ld a, l
	sub c
	ld l, a
	jr nc, Jump_03_630F
	ld a, h
	sub $01
	ld h, a
	jr c, Jump_03_6312
Jump_03_630F:
	inc de
	jr Jump_03_6304

Jump_03_6312:
	pop bc
	ld a, c
	add a, b
	srl a
	ld b, a
	and a
	push de
	ld de, $0000
	jr z, Jump_03_6330
	ld h, c
	ld l, $00
Jump_03_6322:
	ld a, l
	sub b
	ld l, a
	jr nc, Jump_03_632D
	ld a, h
	sub $01
	ld h, a
	jr c, Jump_03_6330
Jump_03_632D:
	inc de
	jr Jump_03_6322

Jump_03_6330:
	pop bc
	ld a, $03
	ld hl, $0000
Jump_03_6336:
	add hl, bc
	dec a
	jr nz, Jump_03_6336
	ld b, h
	ld c, l
	ld a, $03
	ld hl, $0000
Jump_03_6341:
	add hl, de
	dec a
	jr nz, Jump_03_6341
	ld d, h
	ld e, l
	pop hl
	ld a, l
	and $C0
	add a, $29
	ld l, a
	ld a, $01
	ld [hl], a
	ld a, l
	and $C0
	add a, $0D
	ld l, a
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	xor a
	ld [hl], a
	ld a, l
	and $C0
	add a, $10
	ld l, a
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	xor a
	ld [hl], a
	pop de
	pop bc
	ld a, d
	sub b
	jr nc, Jump_03_637E
	ld a, l
	and $C0
	add a, $0D
	ld l, a
	ld a, [hl]
	cpl
	ld [hli], a
	ld a, [hl]
	cpl
	ld [hli], a
	ld a, $FF
	ld [hl], a
Jump_03_637E:
	ld a, e
	sub c
	ret nc
	ld a, l
	and $C0
	add a, $10
	ld l, a
	ld a, [hl]
	cpl
	ld [hli], a
	ld a, [hl]
	cpl
	ld [hli], a
	ld a, $FF
	ld [hl], a
	ret


Func_03_6391:
	call UpdatePendingLevelObjectsFar
	ld a, $01
	ld [$CD13], a
	xor a
	ld [$CD11], a
	ld [$CD12], a
	ld a, [wPlayerObject]
	ld e, a
	ld a, [wPlayerObject + 1]
	ld d, a
	call Func_03_6429
	ld e, $01
	ld a, [$CD10]
	inc a
	cp $1E
	jr nz, Jump_03_63B6
	xor a
Jump_03_63B6:
	ld [$CD10], a
	ld e, $01
	and a
	jr z, Jump_03_63BF
	dec e
Jump_03_63BF:
	ld hl, wLevelObjectAuxState
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	ld a, LEVEL_OBJECT_AUX_COUNT
Jump_03_63CA:
	push af
	push hl
	ld a, [hli]
	and a
	jr z, Jump_03_641F
	cp $01
	jr z, Jump_03_63FF
	cp $02
	jr z, Jump_03_63F2
	cp $03
	jr z, Jump_03_6413
	cp $04
	jr z, Jump_03_63E2
	jr Jump_03_641F

Jump_03_63E2:
	ld a, $01
	ld [$CD14], a
	ld a, [$CA07]
	and a
	jr nz, Jump_03_641F
	ld [$CD14], a
	jr Jump_03_641F

Jump_03_63F2:
	inc hl
	inc hl
	ld a, [hli]
	cp $02
	jr z, Jump_03_641F
	xor a
	ld [$CD13], a
	jr Jump_03_641F

Jump_03_63FF:
	ld a, [hli]
	inc a
	ld d, a
	ld a, [hl]
	cp d
	jr z, Jump_03_640A
	add a, e
	ld [hl], a
	jr Jump_03_641F

Jump_03_640A:
	ld a, [$CD11]
	inc a
	ld [$CD11], a
	jr Jump_03_641F

Jump_03_6413:
	inc hl
	inc hl
	ld a, [hli]
	cp $01
	jr z, Jump_03_641F
	ld a, $01
	ld [$CD12], a
Jump_03_641F:
	pop hl
	ld bc, LEVEL_OBJECT_AUX_STATE_SIZE
	add hl, bc
	pop af
	dec a
	jr nz, Jump_03_63CA
	ret


Func_03_6429:
	push de
	ld hl, wLevelObjectAuxState
	ld bc, LEVEL_OBJECT_AUX_STATE_SIZE
	ld a, LEVEL_OBJECT_AUX_COUNT
Jump_03_6432:
	push af
	push bc
	push hl
	ld bc, $0006
	add hl, bc
	ld a, [hl]
	and a
	jp z, Jump_03_6552
	pop hl
	push hl
	ld a, e
	and $C0
	add a, $13
	ld e, a
	inc de
	ld a, [de]
	ld [$CD2B], a
	ld c, a
	inc de
	ld a, [de]
	ld [$CD2C], a
	ld b, a
	push de
	ld a, [hli]
	ld [$CD2F], a
	ld e, a
	ld a, [hli]
	ld [$CD30], a
	ld d, a
	call Func_03_655C
	push af
	inc hl
	inc hl
	ld a, [hli]
	ld b, a
	inc hl
	inc hl
	pop af
	and a
	jr nz, Jump_03_6477
	ld a, d
	and a
	jr nz, Jump_03_6473
	ld a, e
	cp b
	jr c, Jump_03_6484
Jump_03_6473:
	pop de
	jp Jump_03_6552

Jump_03_6477:
	ld a, d
	and a
	jr nz, Jump_03_6473
	ld a, e
	cp $0C
	jr c, Jump_03_6484
	pop de
	jp Jump_03_6552

Jump_03_6484:
	pop de
	pop hl
	push hl
	inc hl
	inc hl
	ld a, e
	and $C0
	add a, $16
	ld e, a
	inc de
	ld a, [de]
	ld [$CD2D], a
	ld c, a
	inc de
	ld a, [de]
	ld [$CD2E], a
	ld b, a
	push de
	ld a, [hli]
	ld [$CD31], a
	ld e, a
	ld a, [hli]
	ld [$CD32], a
	ld d, a
	call Func_03_655C
	push af
	inc hl
	ld a, [hli]
	ld b, a
	pop af
	and a
	jr nz, Jump_03_64BD
	ld a, d
	and a
	jr nz, Jump_03_64B9
	ld a, e
	cp b
	jr c, Jump_03_64CA
Jump_03_64B9:
	pop de
	jp Jump_03_6552

Jump_03_64BD:
	ld a, d
	and a
	jr nz, Jump_03_64B9
	ld a, e
	cp $0C
	jr c, Jump_03_64CA
	pop de
	jp Jump_03_6552

Jump_03_64CA:
	pop de
	ld a, [hli]
	inc hl
	cp $01
	jp z, Jump_03_6541
	cp $02
	jr z, Jump_03_64E1
	cp $03
	jr z, Jump_03_64FE
	cp $05
	jr z, Jump_03_6517
	jp Jump_03_6552

Jump_03_64E1:
	ld a, e
	and $C0
	add a, $26
	ld e, a
	ld a, [de]
	and a
	jp nz, Jump_03_6552
	ld a, [$C91D]
	and a
	jr z, Jump_03_6552
	inc hl
	ld a, [hl]
	cp $01
	jr nz, Jump_03_6552
	inc a
	ld [hl], a
	ld l, e
	ld h, d
	jr Jump_03_654D

Jump_03_64FE:
	ld a, e
	and $C0
	add a, $26
	ld e, a
	ld a, [de]
	and a
	jr nz, Jump_03_6552
	inc hl
	ld a, [hl]
	cp $01
	jr z, Jump_03_6552
	inc a
	ld [hl], a
	call Func_0A48
	ld l, e
	ld h, d
	jr Jump_03_654D

Jump_03_6517:
	ld a, e
	and $C0
	add a, $26
	ld e, a
	ld a, [de]
	and a
	jr nz, Jump_03_6552
	ld a, [hl]
	and a
	jr nz, Jump_03_6552
	inc a
	ld [hl], a
	dec hl
	ld a, [hl]
	ld h, $00
	ld l, a
	add hl, hl
	push hl
	add hl, hl
	add hl, hl
	pop bc
	add hl, bc
	ld bc, $0009
	add hl, bc
	ld bc, wLevelObjectAuxState
	add hl, bc
	ld a, $01
	ld [hl], a
	ld l, e
	ld h, d
	jr Jump_03_654D

Jump_03_6541:
	ld a, e
	and $C0
	add a, $26
	ld e, a
	ld a, [de]
	and a
	jr z, Jump_03_6552
	xor a
	ld [hl], a
Jump_03_654D:
	pop hl
	pop bc
	pop af
	pop de
	ret

Jump_03_6552:
	pop hl
	pop bc
	add hl, bc
	pop af
	dec a
	jp nz, Jump_03_6432
	pop de
	ret


Func_03_655C:
	ld a, c
	sub e
	ld e, a
	ld a, b
	sbc a, d
	ld d, a
	and $80
	jr z, Jump_03_6573
	ld a, e
	cpl
	add a, $01
	ld e, a
	ld a, d
	cpl
	adc a, $00
	ld d, a
	ld a, $01
	ret

Jump_03_6573:
	xor a
	ret


Func_03_6575:
	ld a, [wPlayerAlive]
	and a
	ret z
	ld a, [$CD15]
	ld h, $00
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, $CDEF
	add hl, bc
	ld a, e
	and $C0
	add a, $13
	ld e, a
	inc de
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	ld b, a
	push bc
	push hl
	ld a, [$CD29]
	and a
	jr nz, Jump_03_65C2
	ld a, [hli]
	cp c
	jr nz, Jump_03_65C2
	ld a, [hli]
	cp b
	jr nz, Jump_03_65C2
	ld a, e
	and $C0
	add a, $16
	ld e, a
	inc de
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	ld b, a
	ld a, [hli]
	cp c
	jr nz, Jump_03_65CE
	ld a, [hli]
	cp b
	jr nz, Jump_03_65CE
	ld a, e
	and $C0
	add a, $19
	ld e, a
	ld a, [de]
	ld [hl], a
	pop hl
	pop bc
	ret

Jump_03_65C2:
	ld a, e
	and $C0
	add a, $16
	ld e, a
	inc de
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	ld b, a
Jump_03_65CE:
	pop hl
	inc hl
	inc hl
	inc hl
	inc hl
	ld a, [$CD17]
	and a
	jr nz, Jump_03_65EF
	inc a
	ld [$CD17], a
	ld a, e
	and $C0
	add a, $19
	ld e, a
	ld a, [de]
	ld [hl], a
	dec hl
	ld [hl], b
	dec hl
	ld [hl], c
	dec hl
	pop bc
	ld [hl], b
	dec hl
	ld [hl], c
	ret

Jump_03_65EF:
	ld a, e
	and $C0
	add a, $19
	ld e, a
	ld a, [de]
	cp [hl]
	jr nz, Jump_03_65FB
	pop bc
	ret

Jump_03_65FB:
	push bc
	ld bc, $0008
	add hl, bc
	pop bc
	ld [hl], a
	dec hl
	ld [hl], b
	dec hl
	ld [hl], c
	dec hl
	pop bc
	ld [hl], b
	dec hl
	ld [hl], c
	ld a, [$CD15]
	inc a
	and $3F
	ld [$CD15], a
	ret nz
	ld a, [$CD16]
	inc a
	and $3F
	ld [$CD16], a
	ret

Jump_03_661F:
	ld a, e
	and $C0
	add a, $33
	ld e, a
	ld a, [de]
	and a
	jr nz, Jump_03_662B
	jr Jump_03_663C

Jump_03_662B:
	dec a
	ld [de], a
	cp $20
	jr c, Jump_03_663C
	ld a, e
	and $C0
	add a, $1A
	ld e, a
	xor a
	ld [de], a
	jp Jump_03_67BA

Jump_03_663C:
	ld a, e
	and $C0
	add a, $19
	ld e, a
	ld a, [de]
	ld b, a
	ld a, e
	and $C0
	add a, $2F
	ld e, a
	ld a, [de]
	cp b
	jr z, Jump_03_6685
	ld a, e
	and $C0
	add a, $1A
	ld e, a
	xor a
	ld [de], a
	ld a, e
	and $C0
	add a, $30
	ld e, a
	ld a, [de]
	and a
	jr z, Jump_03_6665
	dec a
	ld [de], a
	jp Jump_03_67BA

Jump_03_6665:
	push de
	ld a, e
	and $C0
	add a, $23
	ld e, a
	ld a, [de]
	pop de
	ld [de], a
	ld a, e
	and $C0
	add a, $32
	ld e, a
	ld a, [de]
	ld c, a
	ld a, e
	and $C0
	add a, $19
	ld e, a
	ld a, [de]
	add a, c
	and $0F
	ld [de], a
	jp Jump_03_67BA

Jump_03_6685:
	push de
	ld l, e
	ld h, d
	ld bc, Func_03_66BB
	push bc
	ld a, l
	and $C0
	add a, $36
	ld l, a
	ld a, [hli]
	ld e, a
	ld d, [hl]
	ld a, l
	and $C0
	add a, $16
	ld l, a
	inc hl
	ld a, [hli]
	ld c, a
	ld b, [hl]
	push bc
	push de
	ld a, l
	and $C0
	add a, $34
	ld l, a
	ld a, [hli]
	ld e, a
	ld d, [hl]
	ld a, l
	and $C0
	add a, $13
	ld l, a
	inc hl
	ld a, [hli]
	ld c, a
	ld b, [hl]
	push bc
	push de
	ld h, $04
	jp Jump_03_6065

Func_03_66BB:
	pop de
	ld a, l
	and a
	jr z, Jump_03_66FE
	and $01
	jr z, Jump_03_66DB
	ld a, e
	and $C0
	add a, $34
	ld e, a
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	ld b, a
	ld a, e
	and $C0
	add a, $13
	ld e, a
	inc de
	ld a, c
	ld [de], a
	inc de
	ld a, b
	ld [de], a
Jump_03_66DB:
	ld a, l
	and $02
	jr z, Jump_03_66FE
	ld a, e
	and $C0
	add a, $36
	ld e, a
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	ld b, a
	ld a, e
	and $C0
	add a, $16
	ld e, a
	inc de
	ld a, c
	ld [de], a
	inc de
	ld a, b
	ld [de], a
	ld a, l
	cp $03
	jr nz, Jump_03_66FE
	jr Jump_03_6711

Jump_03_66FE:
	ld a, e
	and $C0
	add a, $39
	ld e, a
	ld a, [de]
	push af
	ld a, e
	and $C0
	add a, $1A
	ld e, a
	pop af
	ld [de], a
	jp Jump_03_67BA

Jump_03_6711:
	ld a, e
	and $C0
	add a, $2E
	ld e, a
	ld a, [de]
	ld b, a
	ld a, e
	and $C0
	add a, $31
	ld e, a
	ld a, [de]
	and a
	jr z, Jump_03_6734
	dec b
	ld a, b
	and a
	jr nz, Jump_03_6733
	ld a, e
	and $C0
	add a, $31
	ld e, a
	ld a, [de]
	cpl
	ld [de], a
	ld b, $00
Jump_03_6733:
	dec b
Jump_03_6734:
	ld a, e
	and $C0
	add a, $2E
	ld e, a
	inc b
	ld a, b
	and $3F
	ld c, a
	ld a, [$CD15]
	cp c
	jr nz, Jump_03_6747
	jr Jump_03_674B

Jump_03_6747:
	ld a, c
	ld [de], a
	jr nz, Jump_03_674B
Jump_03_674B:
	ld a, e
	and $C0
	add a, $1A
	ld e, a
	xor a
	ld [de], a
	ld a, e
	and $C0
	add a, $2E
	ld e, a
	ld a, [de]
	ld h, $00
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, $CDEF
	add hl, bc
	inc hl
	inc hl
	inc hl
	inc hl
	ld a, [hl]
	ld b, a
	ld a, e
	and $C0
	add a, $31
	ld e, a
	ld a, [de]
	and a
	jr z, Jump_03_6785
	push hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	ld a, [hl]
	add a, $08
	and $0F
	ld b, a
	pop hl
Jump_03_6785:
	ld a, e
	and $C0
	add a, $2F
	ld e, a
	ld a, b
	ld [de], a
	ld c, $FF
	ld a, e
	and $C0
	add a, $19
	ld e, a
	ld a, [de]
	sub b
	jr nc, Jump_03_679B
	ld c, $01
Jump_03_679B:
	ld a, e
	and $C0
	add a, $32
	ld e, a
	ld a, c
	ld [de], a
	ld a, e
	and $C0
	add a, $31
	ld e, a
	ld a, [de]
	and a
	jr z, Jump_03_67B7
	push hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	pop hl
Jump_03_67B7:
	call Func_03_67BF
Jump_03_67BA:
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_03_67BF:
	push de
	push hl
	push de
	ld a, e
	and $C0
	add a, $31
	ld e, a
	ld a, [de]
	and a
	jr z, Jump_03_67D6
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	jr Jump_03_67DA

Jump_03_67D6:
	ld bc, $0008
	add hl, bc
Jump_03_67DA:
	dec hl
	ld d, [hl]
	dec hl
	ld e, [hl]
	dec hl
	ld b, [hl]
	dec hl
	ld c, [hl]
	pop hl
	ld a, l
	and $C0
	add a, $34
	ld l, a
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	ld a, l
	and $C0
	add a, $36
	ld l, a
	ld a, e
	ld [hli], a
	ld a, d
	ld [hl], a
	pop hl
	pop de
	ret


QuantizeSignedVectorDirection:
	ld de, $0000
	bit 7, b
	jr z, Jump_03_6807
	ld a, b
	cpl
	inc a
	ld b, a
	set 1, e
Jump_03_6807:
	bit 7, c
	jr z, Jump_03_6811
	ld a, c
	cpl
	inc a
	ld c, a
	set 0, e
Jump_03_6811:
	push de
	ld hl, SignedVectorDirectionLookup
	ld a, b
	cp c
	jr nc, Jump_03_681C
	inc hl
	ld b, c
	ld c, a
Jump_03_681C:
	ld a, e
	cp $03
	jr z, Jump_03_6824
	and a
	jr nz, Jump_03_6826
Jump_03_6824:
	inc hl
	inc hl
Jump_03_6826:
	ld a, b
	srl a
	ld e, $00
	add a, c
	cp b
	jr z, Jump_03_6833
	jr c, Jump_03_6833
	sub b
	inc e
Jump_03_6833:
	add a, c
	cp b
	jr z, Jump_03_683B
	jr c, Jump_03_683B
	sub b
	inc e
Jump_03_683B:
	add a, c
	cp b
	jr z, Jump_03_6843
	jr c, Jump_03_6843
	sub b
	inc e
Jump_03_6843:
	add a, c
	cp b
	jr z, Jump_03_684B
	jr c, Jump_03_684B
	sub b
	inc e
Jump_03_684B:
	ld d, $00
	sla e
	sla e
	add hl, de
	ld a, [hl]
	pop de
	ld hl, SignedVectorQuadrantOffsets
	add hl, de
	add a, [hl]
	ret


StateCheckTable:
	dw Level00StateCheck
	dw Level01StateCheck
	dw Level02StateCheck
	dw Level03StateCheck
	dw Level04StateCheck
	dw Level05StateCheck
	dw Level06StateCheck
	dw Level07StateCheck
	dw Level08StateCheck
	dw Level09StateCheck
	dw Level10StateCheck
	dw Level11StateCheck
	dw Level12StateCheck
	dw Level13StateCheck
	dw Level14StateCheck

DispatchStateCheck:
	ld a, [$CA06]
	ld l, a
	ld h, $00
	add hl, hl
	ld de, StateCheckTable
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl


Level00StateCheck:
	ld a, [$CD14]
	and a
	jp z, Jump_03_6911
	ret


Level01StateCheck:
	ld a, [$C6EF]
	cp $06
	ret nz
	ld a, [$CD12]
	and a
	jp z, Jump_03_6911
	ret


Level02StateCheck:
	ld a, [$CD14]
	and a
	jp z, Jump_03_6911
	ret


Level03StateCheck:
	ld a, [$CD12]
	and a
	jp z, Jump_03_6911
	ret


Level04StateCheck:
	ld a, [$CD12]
	and a
	jp z, Jump_03_6911
	ret


Level05StateCheck:
	ld a, [$CD13]
	and a
	jp nz, Jump_03_6911
	ret


Level06StateCheck:
	ld a, [$CD12]
	and a
	jp z, Jump_03_6911
	ret


Level07StateCheck:
	ld a, [$CD2A]
	and a
	ret nz
	jp Jump_03_6911


Level08StateCheck:
	ld a, [$C6EF]
	cp $08
	ret nz
	ld a, [$CD12]
	and a
	jp z, Jump_03_6911
	ret


Level09StateCheck:
	ld a, [$C6F0]
	cp $07
	ret nz
	ld a, [$CD12]
	and a
	jp z, Jump_03_6911
	ret


Level10StateCheck:
	ld a, [$CD14]
	and a
	jp z, Jump_03_6911
	ret


Level11StateCheck:
	ld a, [$CD12]
	and a
	jp z, Jump_03_6911
	ret


Level12StateCheck:
	ld a, [$CD14]
	and a
	jp z, Jump_03_6911
	ret


Level13StateCheck:
	ld a, [$CD2A]
	and a
	ret nz
	jp Jump_03_6911


Level14StateCheck:
	ld a, [$CD14]
	and a
	jp z, Jump_03_6911
	ret

Jump_03_6911:
	ld a, [wLevelComplete]
	and a
	ret nz
	ld bc, $003C
	call BeginLevelCompleteCountdown
	ld bc, $2710
	call AddToScore
	ret


Func_03_6923:
	ld a, e
	ld [$CD23], a
	ld a, d
	ld [$CD24], a
	ld hl, wLevelObjectAuxState
	ld a, LEVEL_OBJECT_AUX_COUNT
Jump_03_6930:
	push af
	push hl
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	inc hl
	inc hl
	ld a, [hli]
	and a
	jr z, Jump_03_697D
	cp $03
	jr z, Jump_03_6946
	jr Jump_03_697D

Jump_03_6946:
	push hl
	ld a, [$CD23]
	ld l, a
	ld a, [$CD24]
	ld h, a
	ld a, l
	and $C0
	add a, $13
	ld l, a
	inc hl
	ld a, [hli]
	cp c
	jr nz, Jump_03_697C
	ld a, [hl]
	cp b
	jr nz, Jump_03_697C
	ld a, l
	and $C0
	add a, $16
	ld l, a
	inc hl
	ld a, [hli]
	cp e
	jr nz, Jump_03_697C
	ld a, [hl]
	cp d
	jr nz, Jump_03_697C
	pop hl
	inc hl
	inc hl
	ld a, [hl]
	cp $01
	jr z, Jump_03_697D
	ld a, $01
	ld [hl], a
	ld [$CD12], a
	push hl
Jump_03_697C:
	pop hl
Jump_03_697D:
	pop hl
	ld bc, LEVEL_OBJECT_AUX_STATE_SIZE
	add hl, bc
	pop af
	dec a
	jr nz, Jump_03_6930
	ret

Jump_03_6987:
	pop bc
	pop de
	ld a, h
	and a
	jr z, Jump_03_69B4
	cp $08
	jr z, Jump_03_69B4
	ld l, $00
	ld a, c
	sub e
	ld e, a
	ld a, b
	sbc a, d
	ld d, a
	jr nc, Jump_03_699D
	ld l, $01
Jump_03_699D:
	pop bc
	pop de
	ld a, h
	cp $08
	jr c, Jump_03_69AE
	ld a, l
	and a
	jr nz, Jump_03_69AB
	ld l, $01
	ret

Jump_03_69AB:
	ld l, $00
	ret

Jump_03_69AE:
	ld a, l
	and a
	ret nz
	ld l, $00
	ret

Jump_03_69B4:
	pop bc
	pop de
	ld l, $00
	ld a, c
	sub e
	ld e, a
	ld a, b
	sbc a, d
	ld d, a
	jr nc, Jump_03_69C2
	ld l, $01
Jump_03_69C2:
	ld a, h
	cp $08
	jr z, Jump_03_69D1
	ld a, l
	and a
	jr nz, Jump_03_69CE
	ld l, $01
	ret

Jump_03_69CE:
	ld l, $00
	ret

Jump_03_69D1:
	ld a, l
	and a
	ret nz
	ld l, $00
	ret

; Four unreachable instruction-shaped bytes remain after the final traced
; return.  No direct or indirect reference to this range is known, so keep
; them as data rather than claiming another routine.
Bank03UnreferencedTailBytes:
	db $C9, $C1, $D1, $C9
ASSERT @ == $69DB

Bank03ZeroFill:
	ds $7FFF - @, 0
Bank03BankMarker:
	db $03
ASSERT @ == $8000
