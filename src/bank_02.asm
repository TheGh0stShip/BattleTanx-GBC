; BattleTanx (USA) - ROM bank $02

SECTION "ROM Bank $02", ROMX[$4000], BANK[$02]
	db $CD, $28, $20, $CD, $58, $20, $CD, $ED, $22, $CD, $FE, $20, $AF, $EA, $C0, $C6
	db $76, $00, $00, $FA, $C0, $C6, $B7, $28, $F7, $AF, $EA, $C0, $C6, $F0, $44, $FE
	db $90, $38, $FA, $FE, $97, $30, $F6, $3E, $01, $E0, $4F, $3E, $C1, $E0, $51, $3E
	db $00, $E0, $52, $3E, $80, $E0, $53, $AF, $E0, $54, $3E, $27, $E0, $55, $CD, $F0
	db $FF, $3E, $01, $E0, $4F, $3E, $C4, $E0, $51, $3E, $00, $E0, $52, $3E, $9C, $E0
	db $53, $AF, $E0, $54, $3E, $04, $E0, $55, $AF, $E0, $4F, $3E, $C4, $E0, $51, $3E
	db $40, $E0, $52, $3E, $9C, $E0, $53, $AF, $E0, $54, $3E, $04, $E0, $55, $C9

ResetNearestObjectTracker:
Func_02_406F: ; legacy alias, used by src/bank_00.asm
	ld a, [wNearestTargetDistance + 1]
	inc a
	ret z
Jump_02_4074:
	xor a
	ld [wNearestTargetScanIndex], a
	ld [wNearestTargetPtr], a
	ld [wNearestTargetPtr + 1], a
	ld a, $FF
	ld [wNearestTargetDistance], a
	ld [wNearestTargetDistance + 1], a
	ld a, [$CA06]
	ld hl, Bank02Data_40DD
	ld c, a
	ld b, $00
	add hl, bc
	ld a, [hl]
	cp $00
	jr nz, Jump_02_409D
	ld de, TrackerScanStatus1Objects
	ld hl, $CFDD
	jr Jump_02_40C7

Jump_02_409D:
	cp $01
	jr nz, Jump_02_40A9
	ld de, TrackerScanAuxRecords
	ld hl, $CD65
	jr Jump_02_40C7

Jump_02_40A9:
	cp $03
	jr nz, Jump_02_40B5
	ld de, TrackerSelectAuxRecord
	ld hl, $CD6F
	jr Jump_02_40C7

Jump_02_40B5:
	cp $02
	jr nz, Jump_02_40C1
	ld de, TrackerScanType2Objects
	ld hl, $CFDD
	jr Jump_02_40C7

Jump_02_40C1:
	ld de, TrackerScanStatus1Objects
	ld hl, $CFDD
Jump_02_40C7:
	ld a, l
	ld [wNearestTargetScanPtr], a
	ld a, h
	ld [wNearestTargetScanPtr + 1], a
	ld hl, wNearestTargetScanJump
	ld a, $C3
	ld [hli], a
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	ld a, $C9
	ld [hli], a
	ret

Bank02Data_40DD:
	db $00, $01, $00, $01, $01, $03, $01, $02, $01, $01, $00, $01, $00, $02, $00

Bank02RomImage_40EC:
	LOAD UNION "RAM code $C729", WRAM0[$C729] ; copied from $02:40EC

PaletteStatHandler:
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

Bank02RomImage_4138:
	LOAD UNION "RAM code $C7F1", WRAM0[$C7F1] ; copied from $02:4138

PaletteVBlankHandler:
	push af
	push bc
	push de
	push hl
	ld hl, wBgPalette6To7Shadow
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

InstallPaletteStatInterruptHandlers:
Func_02_418A: ; legacy alias, used by src/bank_00.asm
	push af
	push bc
	push de
	push hl
	di
	ld hl, Bank02RomImage_40EC
	ld de, $004C
	ld bc, $C729
	call CopyBytes
	ld hl, Bank02RomImage_4138
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


Bank02RomImage_41C2:
	LOAD UNION "RAM code $C729", WRAM0[$C729] ; copied from $02:41C2

StatHandlerReti:
	reti

	ENDL
	db $D9

Bank02RomImage_41C4:
	LOAD UNION "RAM code $C7F1", WRAM0[$C7F1] ; copied from $02:41C4

VBlankHandlerWithSoftReset:
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
Bank02Data_41F7:
	db $D0, $4A, $30, $20, $30, $48, $20, $40, $87
Bank02Data_4200:
	db $FC, $FC, $00, $00
Bank02Data_4204:
	db $F8, $F8, $00
	db $00, $F8, $00, $01, $00, $00, $F8, $02, $00, $00, $00, $03, $00
Bank02Data_4214:
	db $F4, $F4, $00
	db $00, $F4, $FC, $01, $00, $F4, $04, $02, $00, $FC, $F4, $03, $00, $FC, $FC, $04
	db $00, $FC, $04, $05, $00, $04, $F4, $06, $00, $04, $FC, $07, $00, $04, $04, $08
	db $00

InstallVBlankOnlyInterruptHandlers:
Func_02_4238: ; legacy alias, used by src/bank_00.asm
	push af
	push bc
	push de
	push hl
	di
	ld hl, Bank02RomImage_41C2
	ld de, $0001
	ld bc, $C729
	call CopyBytes
	ld hl, Bank02RomImage_41C4
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

GetObjectDirectionalOffsetPosition:
Func_02_43EC: ; legacy alias, used by src/bank_00.asm
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

Bank02Data_4448:
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

GetSignedDirectionDifference:
Func_02_4548: ; legacy alias
	push af
	push hl
	ld hl, Bank02Data_4448
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

ObjectAnimationFrames4565:
	db $A8, $44, $38, $45, $C8, $45, $58, $46, $58, $46, $C8, $45, $38, $45, $A8, $44
ObjectAnimationFrames4575:
	db $F0, $46, $80, $47, $10, $48, $A0, $48, $30, $49
ObjectAnimationFrames457F:
	db $C8, $49, $58, $4A, $E8, $4A
	db $78, $4B, $08, $4C, $98, $4C, $28, $4D, $B8, $4D, $48, $4E, $D8, $4E, $68, $4F
ObjectAnimationFrames4595:
	db $00, $50, $40, $50, $80, $50, $C0, $50
ObjectAnimationFrames459D:
	db $08, $51, $48, $51, $88, $51, $C8, $51
ObjectAnimationFrames45A5:
	db $10, $52, $50, $52, $90, $52, $D0, $52
ObjectAnimationFrames45AD:
	db $18, $53, $58, $53, $98, $53, $D8, $53
ObjectAnimationFrames45B5:
	db $20, $54, $30, $54, $40, $54
ObjectAnimationFrames45BB:
	db $58, $54, $68, $54, $78, $54

SpawnDirectionalOffsetEffect:
Func_02_45C1: ; legacy alias
	push af
	push bc
	push de
	push hl
	call Func_2C24
	ld a, $03
	call AllocateObjectRecord
	call SetObjectPosition
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
	ld de, ObjectAnimationFrames45BB
	ld bc, TrackerDirectionLookup + $12
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
	ld bc, Bank02Data_4200
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


InitEffectSubtype1Animation:
Func_02_4611: ; legacy alias
	push af
	ld de, ObjectAnimationFrames45B5
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
	ld bc, Bank02Data_4200
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


InitEffectSubtype0Animation:
Func_02_463D: ; legacy alias
	push af
	call Func_0421
	and $03
	cp $02
	jr z, Jump_02_4659
	cp $01
	jr z, Jump_02_4652
	ld de, ObjectAnimationFrames4575
	ld a, $14
	jr Jump_02_4660

Jump_02_4652:
	ld de, ObjectAnimationFrames4565
	ld a, $20
	jr Jump_02_4660

Jump_02_4659:
	ld de, ObjectAnimationFrames457F
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
	ld bc, Bank02Data_4214
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


InitEffectSubtype2Animation:
Func_02_4688: ; legacy alias
	push af
	call Func_0421
	and $03
	cp $03
	jr z, Jump_02_46B2
	cp $02
	jr z, Jump_02_46AA
	cp $01
	jr z, Jump_02_46A2
	ld de, ObjectAnimationFrames4595
	ld bc, TrackerPointerFrames + $C2
	jr Jump_02_46BA

Jump_02_46A2:
	ld de, ObjectAnimationFrames459D
	ld bc, TrackerPointerFrames + $1CA
	jr Jump_02_46BA

Jump_02_46AA:
	ld de, ObjectAnimationFrames45A5
	ld bc, TrackerPointerFrames + $2D2
	jr Jump_02_46BA

Jump_02_46B2:
	ld de, ObjectAnimationFrames45AD
	ld bc, TrackerPointerFrames + $3DA
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
	ld bc, Bank02Data_4204
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


ClearBackgroundPalettesImpl:
Func_02_46E1: ; legacy alias
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


DarkenObjectPalettesImpl:
Func_02_4710: ; legacy alias
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


BuildBackgroundPaletteFadeFramesImpl:
Func_02_474B: ; legacy alias
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


DivideScoreByThousand:
Func_02_47AF: ; legacy alias, used by src/bank_00.asm
	ld a, [wScore]
	ldh [$FFC2], a
	ld a, [wScore + 1]
	ldh [$FFC3], a
	ld a, [wScore + 2]
	ldh [$FFC4], a
	ld a, [wScore + 3]
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


ClearAndTransferShadowOam:
Func_02_4810: ; legacy alias
	ld hl, $C600
	xor a
	ld e, $A0
Jump_02_4816:
	ld [hli], a
	dec e
	jr nz, Jump_02_4816
	call $FFF0
	ret


; no reader found
Bank02Unread481E:
	INCBIN "assets/bank_02/unread_481E.bin"

; OBJ palette 7 colours 1-3 (LoadIndexedSpriteGrid via LoadObjectPaletteRange)
Bank02ObjPalette7Colours:
	dw $0000, $001F, $03DF

UpdateNearestObjectTracker:
Func_02_4D58: ; legacy alias, used by src/bank_00.asm
	ld a, [wVisibleStatus1ObjectCount]
	cp $02
	jp nc, ResetNearestObjectTracker
	ld a, [wScreenEffectActive]
	and a
	jp nz, ResetNearestObjectTracker
	jp wNearestTargetScanJump


TrackerScanStatus1Objects:
	ld a, [wNearestTargetScanIndex]
	cp $40
	jp nc, Jump_02_4F7C
	ld a, [wNearestTargetScanPtr]
	ld l, a
	ld a, [wNearestTargetScanPtr + 1]
	ld h, a
	ld bc, $0040
	add hl, bc
	ld a, h
	ld [wNearestTargetScanPtr + 1], a
	ld a, l
	ld [wNearestTargetScanPtr], a
	ld a, [wNearestTargetScanIndex]
	inc a
	ld [wNearestTargetScanIndex], a
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
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
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
TrackerCompareApproxDistance:
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
	ld a, [wNearestTargetDistance + 1]
	cp h
	ret c
	jr nz, Jump_02_4DF9
	ld a, [wNearestTargetDistance]
	cp l
	ret c
Jump_02_4DF9:
	ld a, h
	ld [wNearestTargetDistance + 1], a
	ld a, l
	ld [wNearestTargetDistance], a
	ld a, [wNearestTargetScanPtr]
	ld [wNearestTargetPtr], a
	ld a, [wNearestTargetScanPtr + 1]
	ld [wNearestTargetPtr + 1], a
	ret


TrackerScanAuxRecords:
	ld a, [wNearestTargetScanIndex]
	cp $08
	jp nc, Jump_02_4F43
	ld a, [wNearestTargetScanPtr]
	ld l, a
	ld a, [wNearestTargetScanPtr + 1]
	ld h, a
	ld bc, $000A
	add hl, bc
	ld a, h
	ld [wNearestTargetScanPtr + 1], a
	ld a, l
	ld [wNearestTargetScanPtr], a
	ld a, [wNearestTargetScanIndex]
	inc a
	ld [wNearestTargetScanIndex], a
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
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
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
	jp TrackerCompareApproxDistance


TrackerSelectAuxRecord:
	ld a, [wNearestTargetPtr + 1]
	and a
	jr nz, Jump_02_4F00
	ld hl, $CD79
	ld a, [$C91D]
	and a
	jr z, Jump_02_4E96
	ld hl, $CD6F
Jump_02_4E96:
	ld a, l
	ld [wNearestTargetPtr], a
	ld a, h
	ld [wNearestTargetPtr + 1], a
	ret


TrackerScanType2Objects:
	ld a, [wNearestTargetScanIndex]
	cp $40
	jp nc, Jump_02_4F7C
	ld a, [wNearestTargetScanPtr]
	ld l, a
	ld a, [wNearestTargetScanPtr + 1]
	ld h, a
	ld bc, $0040
	add hl, bc
	ld a, h
	ld [wNearestTargetScanPtr + 1], a
	ld a, l
	ld [wNearestTargetScanPtr], a
	ld a, [wNearestTargetScanIndex]
	inc a
	ld [wNearestTargetScanIndex], a
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
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
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
	jp TrackerCompareApproxDistance

Jump_02_4F00:
	ld a, [wPlayerAlive]
	and a
	ret z
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
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
	ld a, [wNearestTargetPtr]
	ld l, a
	ld a, [wNearestTargetPtr + 1]
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
	jr TrackerDrawPointerSprites

Jump_02_4F43:
	ld a, [wPlayerAlive]
	and a
	ret z
	ld a, [wNearestTargetPtr + 1]
	and a
	jp z, Jump_02_4074
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
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
	ld a, [wNearestTargetPtr]
	ld l, a
	ld a, [wNearestTargetPtr + 1]
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
	jp TrackerDrawPointerSprites

Jump_02_4F7C:
	ld a, [wPlayerAlive]
	and a
	ret z
	ld a, [wNearestTargetPtr + 1]
	and a
	ret z
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
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
	ld a, [wNearestTargetPtr]
	and $C0
	ld l, a
	ld a, [wNearestTargetPtr + 1]
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
TrackerDrawPointerSprites:
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
	ld hl, TrackerDirectionLookup
	add hl, de
	ld a, [hl]
	bit 7, c
	jr nz, Jump_02_4FF3
	swap a
Jump_02_4FF3:
	and $0F
	add a, b
	ld hl, TrackerPointerFrames
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


; 64 frames x 4 OAM entries (y, x, tile, attribute); TrackerDrawPointerSprites
TrackerPointerFrames:
	; frame 0
	db 20, 80, $5D, $0D
	db 20, 88, $5E, $0D
	db 28, 80, $5F, $0D
	db 28, 88, $60, $0D
	; frame 1
	db 20, 85, $5D, $0D
	db 20, 93, $5E, $0D
	db 28, 85, $5F, $0D
	db 28, 93, $60, $0D
	; frame 2
	db 20, 91, $5D, $0D
	db 20, 99, $5E, $0D
	db 28, 91, $5F, $0D
	db 28, 99, $60, $0D
	; frame 3
	db 20, 97, $61, $0D
	db 20, 105, $62, $0D
	db 28, 97, $63, $0D
	db 28, 105, $64, $0D
	; frame 4
	db 20, 103, $61, $0D
	db 20, 111, $62, $0D
	db 28, 103, $63, $0D
	db 28, 111, $64, $0D
	; frame 5
	db 20, 110, $61, $0D
	db 20, 118, $62, $0D
	db 28, 110, $63, $0D
	db 28, 118, $64, $0D
	; frame 6
	db 20, 118, $61, $0D
	db 20, 126, $62, $0D
	db 28, 118, $63, $0D
	db 28, 126, $64, $0D
	; frame 7
	db 20, 127, $61, $0D
	db 20, 135, $62, $0D
	db 28, 127, $63, $0D
	db 28, 135, $64, $0D
	; frame 8
	db 20, 138, $61, $0D
	db 20, 146, $62, $0D
	db 28, 138, $63, $0D
	db 28, 146, $64, $0D
	; frame 9
	db 23, 148, $61, $0D
	db 23, 156, $62, $0D
	db 31, 148, $63, $0D
	db 31, 156, $64, $0D
	; frame 10
	db 33, 148, $61, $0D
	db 33, 156, $62, $0D
	db 41, 148, $63, $0D
	db 41, 156, $64, $0D
	; frame 11
	db 42, 148, $61, $0D
	db 42, 156, $62, $0D
	db 50, 148, $63, $0D
	db 50, 156, $64, $0D
	; frame 12
	db 50, 148, $61, $0D
	db 50, 156, $62, $0D
	db 58, 148, $63, $0D
	db 58, 156, $64, $0D
	; frame 13
	db 58, 148, $65, $0D
	db 58, 156, $66, $0D
	db 66, 148, $67, $0D
	db 66, 156, $68, $0D
	; frame 14
	db 65, 148, $65, $0D
	db 65, 156, $66, $0D
	db 73, 148, $67, $0D
	db 73, 156, $68, $0D
	; frame 15
	db 72, 148, $65, $0D
	db 72, 156, $66, $0D
	db 80, 148, $67, $0D
	db 80, 156, $68, $0D
	; frame 16
	db 124, 80, $5F, $4D
	db 124, 88, $60, $4D
	db 132, 80, $5D, $4D
	db 132, 88, $5E, $4D
	; frame 17
	db 124, 85, $5F, $4D
	db 124, 93, $60, $4D
	db 132, 85, $5D, $4D
	db 132, 93, $5E, $4D
	; frame 18
	db 124, 91, $5F, $4D
	db 124, 99, $60, $4D
	db 132, 91, $5D, $4D
	db 132, 99, $5E, $4D
	; frame 19
	db 124, 97, $63, $4D
	db 124, 105, $64, $4D
	db 132, 97, $61, $4D
	db 132, 105, $62, $4D
	; frame 20
	db 124, 103, $63, $4D
	db 124, 111, $64, $4D
	db 132, 103, $61, $4D
	db 132, 111, $62, $4D
	; frame 21
	db 124, 110, $63, $4D
	db 124, 118, $64, $4D
	db 132, 110, $61, $4D
	db 132, 118, $62, $4D
	; frame 22
	db 124, 118, $63, $4D
	db 124, 126, $64, $4D
	db 132, 118, $61, $4D
	db 132, 126, $62, $4D
	; frame 23
	db 124, 127, $63, $4D
	db 124, 135, $64, $4D
	db 132, 127, $61, $4D
	db 132, 135, $62, $4D
	; frame 24
	db 124, 138, $63, $4D
	db 124, 146, $64, $4D
	db 132, 138, $61, $4D
	db 132, 146, $62, $4D
	; frame 25
	db 121, 148, $63, $4D
	db 121, 156, $64, $4D
	db 129, 148, $61, $4D
	db 129, 156, $62, $4D
	; frame 26
	db 111, 148, $63, $4D
	db 111, 156, $64, $4D
	db 119, 148, $61, $4D
	db 119, 156, $62, $4D
	; frame 27
	db 102, 148, $63, $4D
	db 102, 156, $64, $4D
	db 110, 148, $61, $4D
	db 110, 156, $62, $4D
	; frame 28
	db 94, 148, $63, $4D
	db 94, 156, $64, $4D
	db 102, 148, $61, $4D
	db 102, 156, $62, $4D
	; frame 29
	db 86, 148, $67, $4D
	db 86, 156, $68, $4D
	db 94, 148, $65, $4D
	db 94, 156, $66, $4D
	; frame 30
	db 79, 148, $67, $4D
	db 79, 156, $68, $4D
	db 87, 148, $65, $4D
	db 87, 156, $66, $4D
	; frame 31
	db 72, 148, $67, $4D
	db 72, 156, $68, $4D
	db 80, 148, $65, $4D
	db 80, 156, $66, $4D
	; frame 32
	db 20, 80, $5E, $2D
	db 20, 88, $5D, $2D
	db 28, 80, $60, $2D
	db 28, 88, $5F, $2D
	; frame 33
	db 20, 75, $5E, $2D
	db 20, 83, $5D, $2D
	db 28, 75, $60, $2D
	db 28, 83, $5F, $2D
	; frame 34
	db 20, 69, $5E, $2D
	db 20, 77, $5D, $2D
	db 28, 69, $60, $2D
	db 28, 77, $5F, $2D
	; frame 35
	db 20, 63, $62, $2D
	db 20, 71, $61, $2D
	db 28, 63, $64, $2D
	db 28, 71, $63, $2D
	; frame 36
	db 20, 57, $62, $2D
	db 20, 65, $61, $2D
	db 28, 57, $64, $2D
	db 28, 65, $63, $2D
	; frame 37
	db 20, 50, $62, $2D
	db 20, 58, $61, $2D
	db 28, 50, $64, $2D
	db 28, 58, $63, $2D
	; frame 38
	db 20, 42, $62, $2D
	db 20, 50, $61, $2D
	db 28, 42, $64, $2D
	db 28, 50, $63, $2D
	; frame 39
	db 20, 33, $62, $2D
	db 20, 41, $61, $2D
	db 28, 33, $64, $2D
	db 28, 41, $63, $2D
	; frame 40
	db 20, 22, $62, $2D
	db 20, 30, $61, $2D
	db 28, 22, $64, $2D
	db 28, 30, $63, $2D
	; frame 41
	db 23, 12, $62, $2D
	db 23, 20, $61, $2D
	db 31, 12, $64, $2D
	db 31, 20, $63, $2D
	; frame 42
	db 33, 12, $62, $2D
	db 33, 20, $61, $2D
	db 41, 12, $64, $2D
	db 41, 20, $63, $2D
	; frame 43
	db 42, 12, $62, $2D
	db 42, 20, $61, $2D
	db 50, 12, $64, $2D
	db 50, 20, $63, $2D
	; frame 44
	db 50, 12, $62, $2D
	db 50, 20, $61, $2D
	db 58, 12, $64, $2D
	db 58, 20, $63, $2D
	; frame 45
	db 58, 12, $66, $2D
	db 58, 20, $65, $2D
	db 66, 12, $68, $2D
	db 66, 20, $67, $2D
	; frame 46
	db 65, 12, $66, $2D
	db 65, 20, $65, $2D
	db 73, 12, $68, $2D
	db 73, 20, $67, $2D
	; frame 47
	db 72, 12, $66, $2D
	db 72, 20, $65, $2D
	db 80, 12, $68, $2D
	db 80, 20, $67, $2D
	; frame 48
	db 124, 80, $60, $6D
	db 124, 88, $5F, $6D
	db 132, 80, $5E, $6D
	db 132, 88, $5D, $6D
	; frame 49
	db 124, 75, $60, $6D
	db 124, 83, $5F, $6D
	db 132, 75, $5E, $6D
	db 132, 83, $5D, $6D
	; frame 50
	db 124, 69, $60, $6D
	db 124, 77, $5F, $6D
	db 132, 69, $5E, $6D
	db 132, 77, $5D, $6D
	; frame 51
	db 124, 63, $64, $6D
	db 124, 71, $63, $6D
	db 132, 63, $62, $6D
	db 132, 71, $61, $6D
	; frame 52
	db 124, 57, $64, $6D
	db 124, 65, $63, $6D
	db 132, 57, $62, $6D
	db 132, 65, $61, $6D
	; frame 53
	db 124, 50, $64, $6D
	db 124, 58, $63, $6D
	db 132, 50, $62, $6D
	db 132, 58, $61, $6D
	; frame 54
	db 124, 42, $64, $6D
	db 124, 50, $63, $6D
	db 132, 42, $62, $6D
	db 132, 50, $61, $6D
	; frame 55
	db 124, 33, $64, $6D
	db 124, 41, $63, $6D
	db 132, 33, $62, $6D
	db 132, 41, $61, $6D
	; frame 56
	db 124, 22, $64, $6D
	db 124, 30, $63, $6D
	db 132, 22, $62, $6D
	db 132, 30, $61, $6D
	; frame 57
	db 121, 12, $64, $6D
	db 121, 20, $63, $6D
	db 129, 12, $62, $6D
	db 129, 20, $61, $6D
	; frame 58
	db 111, 12, $64, $6D
	db 111, 20, $63, $6D
	db 119, 12, $62, $6D
	db 119, 20, $61, $6D
	; frame 59
	db 102, 12, $64, $6D
	db 102, 20, $63, $6D
	db 110, 12, $62, $6D
	db 110, 20, $61, $6D
	; frame 60
	db 94, 12, $64, $6D
	db 94, 20, $63, $6D
	db 102, 12, $62, $6D
	db 102, 20, $61, $6D
	; frame 61
	db 86, 12, $68, $6D
	db 86, 20, $67, $6D
	db 94, 12, $66, $6D
	db 94, 20, $65, $6D
	; frame 62
	db 79, 12, $68, $6D
	db 79, 20, $67, $6D
	db 87, 12, $66, $6D
	db 87, 20, $65, $6D
	; frame 63
	db 72, 12, $68, $6D
	db 72, 20, $67, $6D
	db 80, 12, $66, $6D
	db 80, 20, $65, $6D

; $800 bytes, two 4-bit directions per byte indexed by dx/dy (TrackerDrawPointerSprites)
TrackerDirectionLookup:
	INCBIN "assets/bank_02/tracker_direction_lookup.bin"

RunBootScreenSequence:
Func_02_5C40: ; legacy alias, used by src/bank_00.asm, src/bank_2B.asm
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


SetScoreFromThousands:
Func_02_5D33: ; legacy alias, used by src/bank_00.asm
	xor a
	ld [wScore], a
	ld [wScore + 1], a
	ld [wScore + 2], a
	ld [wScore + 3], a
Jump_02_5D40:
	xor a
	or b
	jr nz, Jump_02_5D49
	or c
	jr nz, Jump_02_5D49
	jr Jump_02_5D6C

Jump_02_5D49:
	ld a, [wScore]
	add a, $E8
	ld [wScore], a
	ld a, [wScore + 1]
	adc a, $03
	ld [wScore + 1], a
	ld a, [wScore + 2]
	adc a, $00
	ld [wScore + 2], a
	ld a, [wScore + 3]
	adc a, $00
	ld [wScore + 3], a
	dec bc
	jr Jump_02_5D40

Jump_02_5D6C:
	ret


; Select a four-byte descriptor with E, transfer 40 tiles to VRAM bank 1,
; load OBJ palette 7, build a 4-by-10 shadow-OAM grid, and transfer OAM.
LoadIndexedSpriteGrid:
Func_02_5D6D: ; legacy alias, used by src/bank_00.asm
	ld a, e
	add a, a
	add a, a
	ld hl, Bank02Data_41F7
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
.WaitForVBlankBeforeTileDma:
	ldh a, [rLY]
	cp $90
	jr c, .WaitForVBlankBeforeTileDma
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
	ld hl, Bank02ObjPalette7Colours
	ld b, $07
	ld c, $01
	call Func_057D
	ld hl, $C600
	ld de, $0000
	ldh a, [rSCY]
	ld b, a
	ld c, $80
.BuildRows:
	ld e, $00
.BuildColumns:
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
	jr nz, .BuildColumns
	ld a, d
	add a, $08
	ld d, a
	cp $20
	jr nz, .BuildRows
.WaitForVBlankBeforeOamDma:
	ldh a, [rLY]
	cp $90
	jr c, .WaitForVBlankBeforeOamDma
	call OAMDMARoutine
	ret


; 8 OBJ palettes (Bank02LoadObjPalettes)
BurstObjPalettes:
	dw $0000, $7FFF, $7FFF, $7FFF
	dw $0000, $7D20, $7E41, $7F63
	dw $0000, $4340, $2340, $0741
	dw $0000, $0321, $032A, $03EE
	dw $0000, $03FF, $02DF, $059F
	dw $0000, $001D, $001A, $0018
	dw $0000, $3C3C, $4C1E, $6C1F
	dw $0000, $7815, $780B, $7C03

; six 4x4 tile grids; tile = byte - $62
BurstBlockTileGrids:
	db $64, $64, $64, $64
	db $64, $65, $64, $64
	db $64, $66, $67, $64
	db $64, $64, $64, $64
	db $64, $64, $64, $64
	db $64, $68, $64, $64
	db $64, $69, $6A, $64
	db $64, $64, $64, $64
	db $64, $64, $64, $64
	db $64, $6B, $6C, $64
	db $64, $6D, $6E, $64
	db $64, $64, $64, $64
	db $64, $64, $64, $64
	db $64, $6F, $70, $64
	db $64, $71, $72, $64
	db $64, $73, $64, $64
	db $64, $74, $64, $64
	db $75, $76, $77, $64
	db $65, $78, $79, $64
	db $64, $74, $64, $64
	db $7A, $7B, $64, $7C
	db $64, $7D, $7E, $64
	db $64, $7F, $80, $64
	db $81, $65, $64, $82

; no reader
Bank02Unread5E80:
	db $08, $00, $00, $00, $00, $00, $00, $FF
	db $7F

; 33 tiles; Bank02LoadObjTiles -> VRAM $8000
BurstTiles:
	INCBIN "assets/bank_02/burst_tiles.2bpp"

; pairs read when a burst object expires
BurstChildOffsets:
	db $10, $00
	db $0F, $02
	db $0F, $04
	db $0E, $07
	db $0C, $09
	db $0B, $0B
	db $09, $0C
	db $07, $0E
	db $04, $0F
	db $02, $0F
	db $00, $10
	db $FD, $0F
	db $FB, $0F
	db $F8, $0E
	db $F6, $0C
	db $F4, $0B
	db $F3, $09
	db $F1, $07
	db $F0, $04
	db $F0, $02
	db $F0, $00
	db $F0, $FD
	db $F0, $FB
	db $F1, $F8
	db $F3, $F6
	db $F4, $F4
	db $F6, $F3
	db $F8, $F1
	db $FB, $F0
	db $FD, $F0
	db $FF, $F0
	db $02, $F0
	db $04, $F0
	db $07, $F1
	db $09, $F3
	db $0B, $F4
	db $0C, $F6
	db $0E, $F8
	db $0F, $FB
	db $0F, $FD
	db $10, $FF
	db $0F, $02
	db $0F, $04
	db $0E, $07
	db $0C, $09
	db $0B, $0B
	db $09, $0C
	db $07, $0E
	db $04, $0F
	db $02, $0F
	db $00, $10
	db $FD, $0F
	db $FB, $0F
	db $F8, $0E
	db $F6, $0C
	db $F4, $0B
	db $F3, $09
	db $F1, $07
	db $F0, $04
	db $F0, $02
	db $F0, $00
	db $F0, $FD
	db $F0, $FB
	db $F1, $F8
	db $F3, $F6
	db $F4, $F4
	db $F6, $F3
	db $F8, $F1
	db $FB, $F0
	db $FD, $F0
	db $FF, $F0
	db $02, $F0
	db $04, $F0
	db $07, $F1
	db $09, $F3
	db $0B, $F4
	db $0C, $F6
	db $0E, $F8
	db $0F, $FB
	db $0F, $FD
	db $10, $FF
	db $0F, $02
	db $0F, $04
	db $0E, $07
	db $0C, $09
	db $0B, $0B
	db $09, $0C
	db $07, $0E
	db $04, $0F
	db $02, $0F
	db $00, $10

; 256 bytes indexed by wBurstRandomIndex (Bank02NextTableRandom)
BurstRandomTable:
	db $D8, $CB, $25, $43, $B6, $AE, $4D, $A3, $B2, $13, $A5, $90, $2D, $FB, $54, $5B
	db $8E, $31, $4A, $E2, $59, $49, $2C, $2E, $05, $77, $24, $C6, $83, $CA, $BA, $BF
	db $A9, $50, $68, $9B, $71, $EE, $9E, $DF, $C4, $10, $01, $2B, $61, $69, $9A, $BD
	db $6D, $9F, $40, $B8, $52, $3F, $DE, $D0, $98, $34, $AD, $87, $80, $85, $A2, $D9
	db $79, $E7, $81, $8E, $50, $7C, $E6, $B2, $8C, $A3, $2C, $B3, $5A, $29, $6F, $DB
	db $29, $26, $89, $51, $C5, $65, $C0, $D2, $E3, $B9, $44, $09, $77, $76, $63, $BB
	db $FA, $5E, $43, $39, $46, $07, $9F, $F5, $A7, $6B, $5D, $64, $49, $B3, $DE, $19
	db $EE, $70, $2F, $2E, $42, $B8, $E3, $70, $66, $B6, $09, $38, $04, $9D, $68, $75
	db $65, $60, $39, $54, $17, $36, $12, $4D, $99, $67, $94, $0B, $94, $D8, $2A, $02
	db $A7, $F1, $7F, $80, $31, $36, $BE, $00, $FE, $3F, $52, $9D, $64, $9E, $8E, $41
	db $85, $90, $EB, $8B, $53, $8D, $77, $A8, $9C, $38, $99, $16, $CB, $22, $D6, $17
	db $EE, $E7, $AA, $34, $BC, $DB, $39, $8A, $44, $BD, $94, $C3, $B2, $E0, $D2, $02
	db $08, $1E, $D9, $AA, $2F, $D9, $FE, $ED, $BE, $2F, $DC, $8D, $81, $ED, $62, $5C
	db $F7, $E9, $05, $39, $4F, $F2, $1C, $6E, $03, $DB, $9E, $E1, $3C, $00, $5A, $2F
	db $35, $DF, $73, $37, $EA, $14, $F6, $41, $3C, $8F, $1D, $56, $CB, $0E, $AF, $AB
	db $5C, $60, $F6, $2A, $6F, $8C, $8D, $12, $55, $1A, $86, $14, $A1, $CE, $BE, $7B

; $FF $FF
BurstRandomTableEnd:
	db $FF, $FF

; count pairs
BurstChildCountTable:
	db $04, $0A
	db $07, $06
	db $09, $05
	db $0A, $04
	db $0E, $03
	db $14, $02
	db $28, $01
	db $04, $0A
	db $04, $0A
	db $04, $0A

; four start positions
BurstStartPositions:
	db $46, $44
	db $38, $44
	db $3A, $23
	db $35, $31

InitBurstEffectScreen:
	ld a, $02
	ldh [rSVBK], a
	ld a, $02
	ld [wC8E6], a
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
	ld hl, wBurstObjects
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
	ld [wBurstActiveObjectCount], a
	ld [wBurstBlockAnimTick], a
	ld [wBurstSpawnCooldown], a
	ld a, $FF
	ld [wBurstBlockAnimStep], a
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
	call Bank02LoadObjTiles
	call Bank02LoadObjPalettes
	ld a, $01
	ldh [$FF88], a
	ret


Bank02LoadObjPalettes:
	ld hl, BurstObjPalettes
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


Bank02LoadObjTiles:
	ld hl, $8000
	ld de, BurstTiles
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


RunBurstEffectUntilButton:
Func_02_6306: ; legacy alias, used by src/bank_00.asm
	call InitBurstEffectScreen
	ld a, $FF
	ld [wBurstFrameCountdown], a
Jump_02_630E:
	call UpdateBurstEffectFrame
	call Audio_Update
	call WaitForLY91
	call CopyBurstShadowOamToOam
	ld a, [wBurstFrameCountdown]
	dec a
	ld [wBurstFrameCountdown], a
	jr nz, Jump_02_630E
	inc a
	ld [wBurstFrameCountdown], a
	ld a, [$C6B5]
	and a
	jr z, Jump_02_630E
	ld e, $80
	call Audio_QueueSound
	call Audio_Update
	xor a
	ret


CopyBurstShadowOamToOam:
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


UpdateBurstEffectFrame:
	call SpawnBurstEffectObjectOnTimer
	call UpdateBurstEffectObjects
	ld a, [wBurstSpawnCooldown]
	and a
	ret z
	dec a
	ld [wBurstSpawnCooldown], a
	ret


SpawnBurstSpriteBlock:
	ld a, [wBurstActiveObjectCount]
	cp $18
	ret nc
	ld a, [wBurstSpawnCooldown]
	and a
	ret nz
	ld a, [wBurstBlockAnimStep]
	cp $FF
	ret nz
	xor a
	ld [wBurstBlockAnimTick], a
	ld [wBurstBlockAnimStep], a
	ld a, [wBurstActiveObjectCount]
	add a, $10
	ld [wBurstActiveObjectCount], a
	call Bank02NextTableRandom
	and $03
	add a, a
	ld e, a
	ld d, $00
	ld hl, BurstStartPositions
	add hl, de
	ld a, [hli]
	ldh [$FF80], a
	ld a, [hl]
	ldh [$FF81], a
	ld bc, BurstBlockTileGrids
	ld hl, $D000
	ld de, wBurstObjects
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


AnimateBurstSpriteBlock:
	ld a, [wBurstBlockAnimStep]
	cp $FF
	ret z
	ld b, a
	ld a, [wBurstBlockAnimTick]
	inc a
	ld [wBurstBlockAnimTick], a
	cp $06
	ret nz
	xor a
	ld [wBurstBlockAnimTick], a
	ld a, b
	inc a
	ld [wBurstBlockAnimStep], a
	cp $06
	jr z, Jump_02_6454
	swap a
	ld e, a
	ld d, $00
	ld hl, BurstBlockTileGrids
	add hl, de
	ld de, $D002
	ld bc, wBurstObjects
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
	ld [wBurstBlockAnimStep], a
	call Bank02NextTableRandom
	and $3F
	ld [wBurstSpawnCooldown], a
	ld a, [wBurstActiveObjectCount]
	sub $10
	ld [wBurstActiveObjectCount], a
	ld hl, $D000
	ld de, wBurstObjects
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


UpdateBurstEffectObjects:
	ld hl, wBurstObjects
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
	call z, ExpireBurstEffectObject
	inc hl
	ldh a, [$FF81]
	call AddSignedVelocityToPosition
	sub $10
	cp $91
	jr nc, Jump_02_6506
	ldh a, [$FF80]
	call AddSignedVelocityToPosition
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
	ld a, [wBurstActiveObjectCount]
	dec a
	ld [wBurstActiveObjectCount], a
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


AddSignedVelocityToPosition:
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


ExpireBurstEffectObject:
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
	ld hl, wBurstActiveObjectCount
	dec [hl]
	pop de
	pop hl
	ldh a, [$FF82]
	cp $01
	ret z
	push hl
	ld hl, BurstChildCountTable
	sub $02
	add a, a
	ld c, a
	ld b, $00
	add hl, bc
	ld a, [wBurstActiveObjectCount]
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
	ld a, [wBurstActiveObjectCount]
	add a, b
	ld [wBurstActiveObjectCount], a
	inc hl
	ld a, [hl]
	add a, a
	ldh [$FF89], a
	push de
	ld hl, wBurstObjects
	ld de, $D000
	ld bc, BurstChildOffsets
	call Bank02NextTableRandom
	and $0F
	add a, a
	add a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
Jump_02_65B8:
	call ComputeBurstChildPosition
	ldh a, [$FF89]
	add a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	push bc
	call AllocBurstEffectObject
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


ComputeBurstChildPosition:
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


AllocBurstEffectObject:
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
	jr AllocBurstEffectObject

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
	call Bank02NextTableRandom
	and $07
	ld [de], a
	inc de
	ret


SpawnBurstEffectObjectOnTimer:
	ld hl, $FF88
	dec [hl]
	ret nz
	call Bank02NextTableRandom
	srl a
	srl a
	or $08
	ldh [$FF88], a
	ld a, [wBurstActiveObjectCount]
	cp $1E
	ret nc
	ld hl, wBurstObjects
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
	ld a, [wBurstActiveObjectCount]
	inc a
	ld [wBurstActiveObjectCount], a
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
	call Bank02NextTableRandom
	cp $64
	jr nc, Jump_02_6669
	ld [de], a
	ld b, a
	inc de
	call Bank02NextTableRandom
	and $07
	add a, $02
	ld [hli], a
	ld [de], a
	inc de
	ld c, a
	call Bank02NextTableRandom
	and $07
	ld [de], a
	ld d, c
	call Bank02NextTableRandom
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
	call Bank02NextTableRandom
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


Bank02NextTableRandom:
	push hl
	push de
	ld hl, BurstRandomTable
	ld d, $00
	ld a, [wBurstRandomIndex]
	inc a
	ld [wBurstRandomIndex], a
	ld e, a
	add hl, de
	ld a, [hl]
	pop de
	pop hl
	ret


WaitForLY91:
	ld b, $91
Jump_02_66D6:
	ldh a, [rLY]
	cp b
	jr nz, Jump_02_66D6
	ret

Bank02ZeroFill: ; no reader; zero fill to the bank marker
	ds $7FFF - @, $00
	db BANK(@) ; ROM bank marker
