; BattleTanx (USA) - ROM bank $04

SECTION "ROM Bank $04", ROMX[$4000], BANK[$04]
	INCLUDE "src/level_objects.asm"

InitializeLevelObjects:
	xor a
	ld [$CD10], a
	ld [$C6EF], a
	ld [$C6F0], a
	ld [$CD11], a
	ld [$CD12], a
	ld [$CD13], a
	ld a, $01
	ld [$CD14], a
	xor a
	ld [$CD15], a
	ld [$CD16], a
	ld [$CD17], a
	ld [$CD19], a
	ld [wLevelObjectSequenceTable], a
	ld [wLevelObjectSpawnTable], a
	ld [wLevelObjectAuxTable], a
	ld [$CD23], a
	ld [$CD26], a
	ld [$CD24], a
	ld [wObjectSlowTickCounter], a
	ld [$CD28], a
	ld [$CD29], a
	ld a, [$CA06]
	ld h, $00
	ld l, a
	add hl, hl
	add hl, hl
	ld bc, LevelObjectDataPointers
	add hl, bc
	ld a, [hli]
	ld [wLevelObjectSpawnTable], a
	ld a, [hli]
	ld [wLevelObjectSpawnTable + 1], a
	ld a, [hli]
	ld [wLevelObjectAuxTable], a
	ld a, [hl]
	ld [wLevelObjectAuxTable + 1], a
	ld bc, $0200
	ld hl, $CDEF
Jump_04_607E:
	ld a, $FF
	ld [hli], a
	dec bc
	ld a, c
	or b
	jr nz, Jump_04_607E
	ld bc, PENDING_LEVEL_OBJECT_COUNT * PENDING_LEVEL_OBJECT_SIZE
	ld hl, wPendingLevelObjectQueue
Jump_04_608C:
	ld a, $FF
	ld [hli], a
	dec bc
	ld a, c
	or b
	jr nz, Jump_04_608C
	xor a
	ld [$CD17], a
	ld [$CD15], a
	ld [$CD16], a
	ld a, [wLevelObjectSpawnTable]
	ld l, a
	ld a, [wLevelObjectSpawnTable + 1]
	ld h, a
	ld b, $28
	xor a
	ld [$CD23], a
Jump_04_60AC:
	push bc
	push hl
	ld a, [hli]
	bit 7, a
	jp nz, Jump_04_6243
	ld [$CD19], a
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	inc hl
	ld a, [hl]
	ld [$CD22], a
	dec hl
	ld a, [$CD19]
	cp $06
	jr nz, Jump_04_60DE
	inc hl
	inc hl
	push bc
	push de
	ld b, [hl]
	ld c, $FF
	call Func_372E
	pop de
	pop bc
	call Func_2125
	jp Jump_04_6243

Jump_04_60DE:
	ld a, [hl]
	bit 7, a
	jr nz, Jump_04_6133
	push hl
	ld a, [$CD19]
	push de
	call Func_04_62A7
	ld a, d
	ld [$CD18], a
	pop de
	ld a, [$CD19]
	ld b, $01
	ld c, $04
	and a
	jr z, Jump_04_6106
	ld b, $00
	ld c, $05
	cp $01
	jr z, Jump_04_6106
	ld b, $02
	ld c, $03
Jump_04_6106:
	ld a, b
	push bc
	call Func_0AD5
	ld a, [$CD18]
	ld b, a
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld a, [hl]
	sub b
	ld [hl], a
	pop bc
	ld a, l
	and $C0
	add a, $39
	ld l, a
	ld a, c
	ld [hl], a
	ld a, l
	and $C0
	add a, $38
	ld l, a
	ld a, $80
	ld [hl], a
	pop de
	ld a, [de]
	ld b, a
	call InitializeObjectSequenceStateFar
	jp Jump_04_61E7

Jump_04_6133:
	ld a, [$CD19]
	cp $03
	jr nz, Jump_04_616B
	ld a, [hl]
	and $7F
	ld [$CD1B], a
	ld a, c
	ld [$CD0B], a
	ld a, b
	ld [$CD0C], a
	ld a, e
	ld [$CD0D], a
	ld a, d
	ld [$CD0E], a
	inc hl
	inc hl
	ld a, [$C6CD]
	cp $01
	jp z, Jump_04_6243
	ld a, [hl]
	ld [$CD08], a
	ld a, [$CD19]
	call Func_04_62A7
	ld a, d
	ld [$CD1A], a
	jp Jump_04_6243

Jump_04_616B:
	cp $05
	jr nz, Jump_04_6182
	push bc
	ld a, [$CD19]
	push de
	call Func_04_62A7
	ld a, d
	ld [$CD18], a
	pop de
	ld b, $03
	ld c, $00
	jr Jump_04_61A5

Jump_04_6182:
	push bc
	ld a, [$CD19]
	push de
	call Func_04_62A7
	ld a, d
	ld [$CD18], a
	pop de
	ld a, [$CD19]
	ld b, $01
	ld c, $04
	and a
	jr z, Jump_04_61A5
	ld b, $00
	ld c, $05
	cp $01
	jr z, Jump_04_61A5
	ld b, $02
	ld c, $03
Jump_04_61A5:
	ld a, b
	push bc
	call Func_0AD5
	ld a, [$CD18]
	ld b, a
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld a, [hl]
	sub b
	ld [hl], a
	pop bc
	ld a, l
	and $C0
	add a, $39
	ld l, a
	ld a, c
	ld [hl], a
	ld a, l
	and $C0
	add a, $38
	ld l, a
	ld a, $80
	ld [hl], a
	pop bc
	call Func_2125
	ld a, l
	and $C0
	add a, $2D
	ld l, a
	ld a, $80
	ld [hl], a
	ld a, l
	and $C0
	add a, $38
	ld l, a
	ld a, $80
	ld [hl], a
	ld a, l
	and $C0
	add a, $1A
	ld l, a
	xor a
	ld [hl], a
Jump_04_61E7:
	ld a, l
	and $C0
	add a, $26
	ld l, a
	ld a, $01
	ld [hl], a
	ld a, l
	and $C0
	add a, $33
	ld l, a
	ld a, $28
	ld [hl], a
	ld e, l
	ld d, h
	pop hl
	push hl
	ld bc, $0008
	add hl, bc
	ld a, e
	and $C0
	add a, $3A
	ld e, a
	ld a, [hli]
	ld [de], a
	inc hl
	ld a, e
	and $C0
	add a, $3B
	ld e, a
	ld a, [$CD23]
	ld [de], a
	ld a, e
	and $C0
	add a, $3C
	ld e, a
	xor a
	ld [de], a
	ld a, [hli]
	ld b, $00
	and a
	jr z, Jump_04_622A
	ld b, $01
	cp $01
	jr z, Jump_04_622A
	ld b, $02
Jump_04_622A:
	ld a, e
	and $C0
	add a, $29
	ld e, a
	ld a, b
	ld [de], a
	ld a, e
	and $C0
	add a, $2A
	ld e, a
	ld a, [hl]
	ld [de], a
	ld a, e
	and $C0
	add a, $32
	ld e, a
	ld a, $01
	ld [de], a
Jump_04_6243:
	ld a, [$CD23]
	inc a
	ld [$CD23], a
	pop hl
	ld de, $000C
	add hl, de
	pop af
	dec a
	ld b, a
	jp nz, Jump_04_60AC
	ld a, [wLevelObjectAuxTable]
	ld l, a
	ld a, [wLevelObjectAuxTable + 1]
	ld h, a
	ld de, $CD6F
	ld a, $08
Jump_04_6262:
	push af
	push hl
	push de
	push hl
	push de
	ld b, $0A
Jump_04_6269:
	xor a
	ld [de], a
	ld a, b
	dec a
	ld b, a
	jr nz, Jump_04_6269
	pop de
	ld bc, $0006
	add hl, bc
	ld a, [hl]
	pop hl
	and a
	jr z, Jump_04_6296
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
	xor a
	ld [de], a
	inc de
	ld [de], a
Jump_04_6296:
	pop hl
	ld bc, $000A
	add hl, bc
	ld d, h
	ld e, l
	pop hl
	ld bc, $0008
	add hl, bc
	pop af
	dec a
	jr nz, Jump_04_6262
	ret


Func_04_62A7:
	ld e, a
	ld a, [$C6CF]
	ld [$CD22], a
	ld d, $26
	and a
	jr z, Jump_04_62BB
	ld d, $20
	cp $01
	jr z, Jump_04_62BB
	ld d, $1C
Jump_04_62BB:
	ld a, e
	and a
	ret z
	ld a, [$CD22]
	ld d, $1D
	and a
	jr z, Jump_04_62CE
	ld d, $17
	cp $01
	jr z, Jump_04_62CE
	ld d, $11
Jump_04_62CE:
	ld a, e
	cp $01
	ret z
	ld a, [$CD22]
	ld d, $2F
	and a
	jr z, Jump_04_62E2
	ld d, $29
	cp $01
	jr z, Jump_04_62E2
	ld d, $23
Jump_04_62E2:
	ld a, e
	cp $02
	ret z
	ld a, [$CD22]
	ld d, $1C
	and a
	jr z, Jump_04_62F6
	ld d, $16
	cp $01
	jr z, Jump_04_62F6
	ld d, $10
Jump_04_62F6:
	ret


Func_04_62F7:
	ld a, [$CD22]
	ld d, $26
	and a
	jr z, Jump_04_6307
	ld d, $20
	cp $01
	jr z, Jump_04_6307
	ld d, $1C
Jump_04_6307:
	ld a, e
	and a
	ret z
	ld a, [$CD22]
	ld d, $1D
	and a
	jr z, Jump_04_631A
	ld d, $17
	cp $01
	jr z, Jump_04_631A
	ld d, $11
Jump_04_631A:
	ld a, e
	cp $01
	ret z
	ld a, [$CD22]
	ld d, $2F
	and a
	jr z, Jump_04_632E
	ld d, $29
	cp $01
	jr z, Jump_04_632E
	ld d, $23
Jump_04_632E:
	ld a, e
	cp $02
	ret z
	ld a, [$CD22]
	ld d, $1C
	and a
	jr z, Jump_04_6342
	ld d, $16
	cp $01
	jr z, Jump_04_6342
	ld d, $10
Jump_04_6342:
	ret


QueuePendingLevelObject:
	ld a, l
	and $C0
	add a, $3A
	ld l, a
	ld a, [hl]
	and a
	ret z
	ld e, l
	ld d, h
	ld hl, wPendingLevelObjectQueue
	ld b, PENDING_LEVEL_OBJECT_COUNT
Jump_04_6353:
	push bc
	ld a, [hl]
	bit 7, a
	jr z, Jump_04_6389
	ld a, e
	and $C0
	add a, $3B
	ld e, a
	ld a, [de]
	and $7F
	ld [hli], a
	ld b, a
	ld a, e
	and $C0
	add a, $3A
	ld e, a
	ld a, [de]
	dec a
	ld [hli], a
	push hl
	ld h, $00
	ld l, b
	add hl, hl
	add hl, hl
	push hl
	add hl, hl
	pop bc
	add hl, bc
	ld a, [wLevelObjectSpawnTable]
	ld c, a
	ld a, [wLevelObjectSpawnTable + 1]
	ld b, a
	add hl, bc
	ld bc, $0009
	add hl, bc
	ld a, [hl]
	pop hl
	ld [hl], a
	pop af
	ret

Jump_04_6389:
	inc hl
	inc hl
	inc hl
	pop af
	dec a
	ld b, a
	jr nz, Jump_04_6353
	ret


UpdatePendingLevelObjects:
	ld a, [wObjectSlowTickCounter]
	inc a
	ld [wObjectSlowTickCounter], a
	cp OBJECT_SLOW_TICK_PERIOD
	ret nz
	xor a
	ld [wObjectSlowTickCounter], a
	ld hl, wPendingLevelObjectQueue
	ld b, PENDING_LEVEL_OBJECT_COUNT
Jump_04_63A5:
	push bc
	push hl
	ld a, [hli]
	bit 7, a
	jr nz, Jump_04_63C6
	ld b, a
	ld a, [hli]
	ld c, a
	ld a, [hl]
	dec [hl]
	and a
	jr nz, Jump_04_63C6
	push hl
	call TrySpawnPendingLevelObject
	pop hl
	and a
	jr nz, Jump_04_63BF
	inc [hl]
	jr Jump_04_63C6

Jump_04_63BF:
	ld a, $FF
	ld [hl], a
	dec hl
	ld [hl], a
	dec hl
	ld [hl], a
Jump_04_63C6:
	pop hl
	inc hl
	inc hl
	inc hl
	pop af
	dec a
	ld b, a
	jr nz, Jump_04_63A5
	ret


TrySpawnPendingLevelObject:
	ld a, c
	ld [$CD24], a
	ld a, b
	ld [$CD23], a
	ld h, $00
	ld l, a
	add hl, hl
	add hl, hl
	push hl
	add hl, hl
	pop bc
	add hl, bc
	ld a, [wLevelObjectSpawnTable]
	ld c, a
	ld a, [wLevelObjectSpawnTable + 1]
	ld b, a
	add hl, bc
	push hl
	ld a, [hli]
	ld [$CD19], a
	ld a, [wLevelCameraX + 1]
	ld d, a
	ld a, [wLevelCameraX]
	add a, $50
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	xor a
	ld [$CD25], a
	push bc
	push de
	call AbsoluteDifferenceBCDE
	ld a, d
	and a
	jr nz, Jump_04_6418
	ld a, $50
	sub e
	jr nc, Jump_04_6418
	ld a, $01
	ld [$CD25], a
Jump_04_6418:
	pop de
	pop bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	push bc
	push de
	ld a, [wLevelCameraY + 1]
	ld b, a
	ld a, [wLevelCameraY]
	add a, $48
	ld c, a
	ld a, b
	adc a, $00
	ld b, a
	call AbsoluteDifferenceBCDE
	ld a, d
	and a
	jr nz, Jump_04_643F
	ld a, $48
	sub e
	jr nc, Jump_04_643F
	ld a, $01
	ld [$CD25], a
Jump_04_643F:
	pop de
	pop bc
	ld a, [$CD25]
	and a
	jr nz, Jump_04_6449
	pop hl
	ret

Jump_04_6449:
	ld a, [hl]
	bit 7, a
	jr nz, Jump_04_6495
	ld a, [$CD19]
	call Func_04_62A7
	push hl
	ld a, [$CD19]
	ld b, $01
	ld c, $05
	and a
	jr z, Jump_04_646B
	ld b, $00
	ld c, $04
	cp $01
	jr z, Jump_04_646B
	ld b, $02
	ld c, $03
Jump_04_646B:
	ld a, b
	push bc
	push de
	call Func_0AD5
	pop de
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld a, [hl]
	sub d
	ld [hl], a
	pop bc
	ld a, l
	and $C0
	add a, $39
	ld l, a
	ld a, c
	ld [hl], a
	ld a, l
	and $C0
	add a, $38
	ld l, a
	ld a, $80
	ld [hl], a
	pop de
	ld a, [de]
	ld b, a
	call InitializeObjectSequenceStateFar
	jr Jump_04_6506

Jump_04_6495:
	ld a, [$CD19]
	cp $05
	jr nz, Jump_04_64A9
	ld a, [$CD19]
	call Func_04_62A7
	push bc
	ld b, $03
	ld c, $00
	jr Jump_04_64C6

Jump_04_64A9:
	push bc
	ld a, [$CD19]
	call Func_04_62A7
	ld a, [$CD19]
	ld b, $01
	ld c, $04
	and a
	jr z, Jump_04_64C6
	ld b, $00
	ld c, $05
	cp $01
	jr z, Jump_04_64C6
	ld b, $02
	ld c, $03
Jump_04_64C6:
	ld a, b
	push bc
	push de
	call Func_0AD5
	pop de
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld a, [hl]
	sub d
	ld [hl], a
	pop bc
	ld a, l
	and $C0
	add a, $39
	ld l, a
	ld a, c
	ld [hl], a
	ld a, l
	and $C0
	add a, $38
	ld l, a
	ld a, $80
	ld [hl], a
	pop bc
	call Func_2125
	ld a, l
	and $C0
	add a, $2D
	ld l, a
	ld a, $80
	ld [hl], a
	ld a, l
	and $C0
	add a, $38
	ld l, a
	ld a, $80
	ld [hl], a
	ld a, l
	and $C0
	add a, $1A
	ld l, a
	xor a
	ld [hl], a
Jump_04_6506:
	ld a, l
	and $C0
	add a, $26
	ld l, a
	ld a, $01
	ld [hl], a
	ld a, l
	and $C0
	add a, $3C
	ld l, a
	xor a
	ld [hl], a
	ld e, l
	ld d, h
	pop hl
	ld bc, $0008
	add hl, bc
	ld a, e
	and $C0
	add a, $3A
	ld e, a
	ld a, [$CD24]
	ld [de], a
	inc hl
	inc hl
	ld a, e
	and $C0
	add a, $3B
	ld e, a
	ld a, [$CD23]
	ld [de], a
	ld a, [hli]
	ld b, $00
	and a
	jr z, Jump_04_6542
	ld b, $01
	cp $01
	jr z, Jump_04_6542
	ld b, $02
Jump_04_6542:
	ld a, e
	and $C0
	add a, $29
	ld e, a
	ld a, b
	ld [de], a
	ld a, e
	and $C0
	add a, $2A
	ld e, a
	ld a, [hl]
	ld [de], a
	ld a, e
	and $C0
	add a, $32
	ld e, a
	ld a, $01
	ld [de], a
	ret


AbsoluteDifferenceBCDE:
	ld a, c
	sub e
	ld e, a
	ld a, b
	sbc a, d
	ld d, a
	and $80
	jr z, Jump_04_6573
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

Jump_04_6573:
	xor a
	ret

Bank04ZeroFill:
	ds $7FFF - @, 0
Bank04BankMarker:
	db $04
ASSERT @ == $8000
