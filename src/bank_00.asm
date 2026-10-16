; BattleTanx (USA) - ROM bank $00

SECTION "ROM Bank $00", ROM0[$0000]
RestartVectorData:
	db $0C, $00, $67, $00, $98, $8B, $67, $00
	ds $38, 0

VBlankInterrupt:
	jp $C7F1


Func_0043:
	call Func_3812
	ret

	db $C9

LCDInterrupt:
	jp $C729

	db $C9, $C9, $C9

Func_004E:
	ret

	db $00

TimerInterrupt:
	reti


Func_0051:
	ldh a, [rLCDC]
	or $80
	ldh [rLCDC], a
	ret


SerialInterrupt:
	reti


Func_0059:
	xor a
Jump_005A:
	ld [hli], a
	dec b
	jr nz, Jump_005A
	ret

	db $00

JoypadInterrupt:
	reti

Jump_0061:
	ld a, [$C6CE]
	or a
	jp nz, Jump_0076
	ld a, [$CD09]
	or a
	jr nz, Jump_0074
	call Func_034B
	jp Jump_01B4

Jump_0074:
	jr Jump_0074

Jump_0076:
	call Func_3B5A
	ld a, [$C6CD]
	cp $01
	jp z, Jump_0090
	ld a, [wLevelNumber]
	cp $0E
	jp z, Jump_0090
	inc a
	ld [wLevelNumber], a
	jp Func_0192

Jump_0090:
	call Func_035C
	ld e, $88
	call Audio_QueueSound
	call Func_3B12
	xor a
	ld [$C6B5], a
Jump_009F:
	call Audio_Update
	xor a
	ld [wVBlankPending], a
Jump_00A6:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_00A6
	xor a
	ld [wVBlankPending], a
	nop
	ld a, [$C6B5]
	or a
	jr z, Jump_009F
	call Func_06F8
	call Func_0AC4
	jp Jump_016C

	db $C3, $C3, $00, $C9
Jump_00C7:
	ld e, $83
	call Audio_QueueSound
	call Func_035C
	call Func_3F28
	call Func_06F8
	jp Jump_016C

	db $18, $FE
Jump_00DA:
	ldh a, [rLCDC]
	res 5, a
	ldh [rLCDC], a
	di
	xor a
	ldh [rIE], a
	ldh [rIF], a
	ldh [rNR51], a
	ei
	call EnableDoubleSpeed
	call Func_04CD
	ld a, $91
	ldh [rLCDC], a
	ld a, [$C000]
	jp Init


Func_00F9:
	ldh a, [rLCDC]
	or $01
	ldh [rLCDC], a
	ret


Boot:
	nop
	jp Init


; Cartridge header ($0104-$014F)
NintendoLogo:
	db $CE, $ED, $66, $66, $CC, $0D, $00, $0B, $03, $73, $00, $83, $00, $0C, $00, $0D
	db $00, $08, $11, $1F, $88, $89, $00, $0E, $DC, $CC, $6E, $E6, $DD, $DD, $D9, $99
	db $BB, $BB, $67, $63, $6E, $0E, $EC, $CC, $DD, $DC, $99, $9F, $BB, $B9, $33, $3E
	db "BATTLETANX " ; title
	db "AVNE" ; manufacturer code
	db $C0 ; CGB flag: CGB only
	db "5H" ; new licensee code
	db $00 ; SGB flag
	db $19 ; cartridge type: MBC5
	db $05 ; ROM size: 1 MiB
	db $00 ; RAM size: none
	db $01 ; destination: non-Japanese
	db $33 ; old licensee code: use new
	db $00 ; mask ROM version
	db $17 ; header checksum
	db $E6, $42 ; global checksum

Init:
	ld sp, $C0FF
	call Func_08C6
	call EnableDoubleSpeed
	call Audio_InitFar
	ld e, $88
	call Audio_QueueSound
	ld a, $01
	ld [wMusicEnabled], a
	ld [$C6E2], a
	call Func_3B9F
Jump_016C:
	ld a, [$C6E2]
	or a
	jr nz, Jump_0175
	call Func_035C
Jump_0175:
	xor a
	ld [$C6E2], a
	ld a, $01
	ld [rROMB0], a
	call Func_3AAE
	call RAM_D56A
	call RAM_D62A
	ld a, $01
	ld [rROMB0], a
	call Func_0192
	jp Jump_016C


Func_0192:
	call Func_3ABF
	xor a
	ld [$C6C1], a
	call Func_04CD
	call Func_09AB
	call Func_0807
	call Func_0879
	call Func_35D7
	call Func_37CE
	call Func_0402
	ld hl, $D000
	call Func_2044
Jump_01B4:
	call Func_04CD
	xor a
	ldh [rSCX], a
	ldh [rSCY], a
	ld [$C6B0], a
	ld [$C6B1], a
	ld [$C8D9], a
	ldh a, [rLCDC]
	res 4, a
	ldh [rLCDC], a
	call Func_35D7
	ld a, [$CD02]
	or a
	jp z, Jump_00C7
	call Func_3C19
	ld a, [$CD00]
	ld l, a
	ld a, [$CD01]
	ld h, a
	call Func_2F93
	ld a, l
	and $C0
	add a, $19
	ld l, a
	ld a, [$CD1B]
	ld [hl], a
	ld b, $00
	ld c, $00
	call Func_03CB
	call Func_1B18
	call Func_1927
	call Func_194B
	call Func_1AE4
	call Func_0781
	call Func_322D
	call LoadLevelPalettes
	call Func_092F
	call Func_07A7
	call Func_0AB3
	ld d, $08
Jump_0214:
	xor a
	ld [wVBlankPending], a
Jump_0218:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_0218
	xor a
	ld [wVBlankPending], a
	ld b, $FE
	call Func_3252
	dec d
	jr nz, Jump_0214
	call Func_35F7
	ld a, [wMusicPtr]
	and a
	jr nz, Jump_0245
Jump_0236:
	call Func_0421
	and $07
	cp $06
	jr nc, Jump_0236
	add a, $81
	ld e, a
	call Audio_QueueSound
Jump_0245:
	ld e, $58
	call Audio_QueueSound
	call Func_0A48
	call Func_0A23
Jump_0250:
	xor a
	ld [wVBlankPending], a
Jump_0254:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_0254
	xor a
	ld [wVBlankPending], a
Jump_0261:
	ldh a, [rLY]
	cp $90
	jr c, Jump_0261
	cp $97
	jr nc, Jump_0261
	ld a, $01
	ldh [rVBK], a
	ld a, $C1
	ldh [rHDMA1], a
	ld a, $00
	ldh [rHDMA2], a
	ld a, $80
	ldh [rHDMA3], a
	xor a
	ldh [rHDMA4], a
	ld a, $27
	ldh [rHDMA5], a
	call OAMDMARoutine
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
	ld a, [$C6B0]
	ldh [rSCX], a
	ld a, [$C6B1]
	ldh [rSCY], a
	ld a, [$CA04]
	ld [$C6B0], a
	ld a, [$CA05]
	ld [$C6B1], a
	call Func_3C56
	call Func_2058
	xor a
	ld [$CD2A], a
	ld hl, $C6B9
	ld a, [hl]
	add a, $01
	ld [hli], a
	ld a, [hl]
	adc a, $00
	ld [hl], a
	ld a, [$C0FF]
	or a
	jr z, Jump_02E9
	call Func_3E05
	call Func_3ED1
Jump_02E9:
	call Func_22ED
	call Func_3823
	call Func_20FE
	call Func_2FCE
	ldh a, [rLY]
	call Func_3302
	ldh a, [rLY]
	call Func_302D
	ld a, [$CD00]
	ld l, a
	ld a, [$CD01]
	ld h, a
	call Func_1804
	call Func_03DB
	jp c, Jump_0061
	ld a, [$C6C1]
	or a
	call nz, Func_033A
	ld a, [$C0FF]
	or a
	jr nz, Jump_0320
	call Func_3608
Jump_0320:
	call Func_2A88
	call Func_3834
	ld a, [wVBlankPending]
	or a
	jp nz, Jump_0250
	xor a
	ld [wVBlankPending], a
Jump_0331:
	ld a, [wVBlankPending]
	or a
	jr z, Jump_0331
	jp Jump_0250


Func_033A:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_4000
	pop af
	ld [rROMB0], a
	ret


Func_034B:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_409E
	pop af
	ld [rROMB0], a
	ret


Func_035C:
	xor a
	ld [wVBlankPending], a
Jump_0360:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_0360
	xor a
	ld [wVBlankPending], a
	call Func_32EF
	call Func_04CD
	call Func_0AC4
	call Func_0781
	call Func_3CD9
	xor a
	ldh [rSCY], a
	ldh [rSCX], a
	ldh a, [rLCDC]
	and $EF
	ldh [rLCDC], a
	ret


Func_0388:
	ld a, c
	ld [$C6EB], a
	ld a, b
	ld [$C6EC], a
	ld a, $01
	ld [$C6CE], a
	ret


Func_0396:
	ld a, c
	ld [$C6EB], a
	ld a, b
	ld [$C6EC], a
	xor a
	ld [$CD09], a
	ld e, $87
	call Audio_QueueSound
	ld a, [$C91D]
	and a
	ret z
	ld c, $01
	ld b, $87
	ld hl, $9C0A
	call Func_049E
	inc hl
	call Func_049E
	ld c, $04
	ld hl, $9C2A
	call Func_049E
	inc hl
	call Func_049E
	xor a
	ld [$C91D], a
	ret


Func_03CB:
	xor a
	ld [$C6EB], a
	ld [$C6EC], a
	ld [$C6CE], a
	ld a, $01
	ld [$CD09], a
	ret


Func_03DB:
	ld a, [$CD09]
	or a
	jr z, Jump_03EA
	ld a, [$C6CE]
	or a
	jr nz, Jump_03EA
Jump_03E7:
	scf
	ccf
	ret

Jump_03EA:
	ld a, [$C6EB]
	ld c, a
	ld a, [$C6EC]
	ld b, a
	or c
	jr z, Jump_0400
	dec bc
	ld a, c
	ld [$C6EB], a
	ld a, b
	ld [$C6EC], a
	jr Jump_03E7

Jump_0400:
	scf
	ret


Func_0402:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $05
	ld [rROMB0], a
	call LoadLevelLookupPointers
	pop af
	ld [rROMB0], a
	ret


Func_0413:
	push hl
	ld hl, $C6B2
	ld [hl], $C7
	inc hl
	ld [hl], $A4
	inc hl
	ld [hl], $9F
	pop hl
	ret


Func_0421:
	push hl
	ld hl, $C6B2
	ld a, [hli]
	sra a
	sra a
	sra a
	xor [hl]
	inc hl
	rra
	rl [hl]
	dec hl
	rl [hl]
	dec hl
	rl [hl]
	ldh a, [rDIV]
	add a, [hl]
	pop hl
	ret


Func_043C:
	push de
	push bc
	push hl
	call Func_0421
	ld e, b
	ld b, $00
	ld d, b
	ld h, b
	ld l, b
	add a, a
	jr nc, Jump_044D
	add hl, de
	adc a, b
Jump_044D:
	add hl, hl
	adc a, a
	jr nc, Jump_0453
	add hl, de
	adc a, b
Jump_0453:
	add hl, hl
	adc a, a
	jr nc, Jump_0459
	add hl, de
	adc a, b
Jump_0459:
	add hl, hl
	adc a, a
	jr nc, Jump_045F
	add hl, de
	adc a, b
Jump_045F:
	add hl, hl
	adc a, a
	jr nc, Jump_0465
	add hl, de
	adc a, b
Jump_0465:
	add hl, hl
	adc a, a
	jr nc, Jump_046B
	add hl, de
	adc a, b
Jump_046B:
	add hl, hl
	adc a, a
	jr nc, Jump_0471
	add hl, de
	adc a, b
Jump_0471:
	add hl, hl
	adc a, a
	jr nc, Jump_0477
	add hl, de
	adc a, b
Jump_0477:
	ld a, h
	pop hl
	pop bc
	pop de
	ret


Func_047C:
	push af
	push bc
	push de
	push hl
Jump_0480:
	ld e, $14
Jump_0482:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_0482
	ld a, [bc]
	ld [hli], a
	inc bc
	dec e
	jr nz, Jump_0482
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	dec d
	jr nz, Jump_0480
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_049E:
	push af
	ld a, $01
	ldh [rVBK], a
Jump_04A3:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_04A3
	ld [hl], b
	xor a
	ldh [rVBK], a
Jump_04AD:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_04AD
	ld [hl], c
	pop af
	ret


Func_04B6:
	ldh a, [rLCDC]
	add a, a
	ret nc
Jump_04BA:
	ldh a, [rLY]
	cp $92
	jr nc, Jump_04BA
Jump_04C0:
	ldh a, [rLY]
	cp $91
	jr c, Jump_04C0
	ldh a, [rLCDC]
	and $7F
	ldh [rLCDC], a
	ret


Func_04CD:
	push af
	push de
	ld d, $40
Jump_04D1:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_04D1
	ld a, d
	ldh [rBCPS], a
	xor a
	ldh [rBCPD], a
	dec d
	jr nz, Jump_04D1
	ld d, $40
Jump_04E2:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_04E2
	ld a, d
	ldh [rOCPS], a
	xor a
	ldh [rOCPD], a
	dec d
	jr nz, Jump_04E2
	pop de
	pop af
	ret


Func_04F4:
	push af
	push de
	push hl
	ld d, $A0
	ld hl, $FE00
Jump_04FC:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_04FC
	xor a
	ld [hli], a
	dec d
	jr nz, Jump_04FC
	pop hl
	pop de
	pop af
	ret


Func_050B:
	xor a
Jump_050C:
	ld [hli], a
	dec c
	jr nz, Jump_050C
	dec b
	jr nz, Jump_050C
	ret


Func_0514:
	ld a, d
	add a, a
	add a, a
	add a, a
	add a, e
	add a, e
	ld e, a
Jump_051B:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_051B
	ld a, e
	ldh [rBCPS], a
	ld a, c
	ldh [rBCPD], a
	inc e
	ld a, e
	ldh [rBCPS], a
	ld a, b
	ldh [rBCPD], a
	ret


Func_052F:
	ld a, b
	add a, a
	add a, a
	add a, a
	or $80
	ld b, a
	ld a, c
	add a, a
	add a, a
	add a, a
	ld c, a
Jump_053B:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_053B
	ld a, b
	ldh [rBCPS], a
	ld de, $FF69
Jump_0547:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_0547
	ld a, [hli]
	ld [de], a
	dec c
	jr nz, Jump_0547
	ret


Func_0553:
	ld a, b
	add a, a
	add a, a
	add a, a
	or $80
	ld b, a
Jump_055A:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_055A
	ld a, b
	ldh [rOCPS], a
	ld de, $FF6B
Jump_0566:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_0566
	xor a
	ld [de], a
	ld [de], a
	ld c, $06
Jump_0571:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_0571
	ld a, [hli]
	ld [de], a
	dec c
	jr nz, Jump_0571
	ret


Func_057D:
	ld a, b
	add a, a
	add a, a
	add a, a
	or $80
	ld b, a
Jump_0584:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_0584
	ld a, b
	ldh [rOCPS], a
	ld de, $FF6B
Jump_0590:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_0590
	xor a
	ld [de], a
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
	dec c
	xor a
	cp c
	jr nz, Jump_0590
	ret


Func_05AB:
	inc b
	inc c
	jr Jump_05B0

Jump_05AF:
	ld [hli], a
Jump_05B0:
	dec c
	jr nz, Jump_05AF
	dec b
	jr nz, Jump_05AF
	ret


Func_05B7:
	inc b
	inc c
	jr Jump_05BE

Jump_05BB:
	ld a, [hli]
	ld [de], a
	inc de
Jump_05BE:
	dec c
	jr nz, Jump_05BB
	dec b
	jr nz, Jump_05BB
	ret


Func_05C5:
	push af
	push bc
	push de
	push hl
	push de
	push hl
	push bc
	ld a, [$C6DC]
	ld b, a
	ld a, $20
	sub b
	ldh [$FFC0], a
	pop bc
	ld a, $01
	ldh [rVBK], a
	ld a, [$C6DD]
	ld d, a
Jump_05DE:
	ld a, [$C6DC]
	ld e, a
Jump_05E2:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_05E2
	ld a, [bc]
	ld [hli], a
	inc bc
	dec e
	jr nz, Jump_05E2
	ldh a, [$FFC0]
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	dec d
	jr nz, Jump_05DE
	pop hl
	pop bc
	xor a
	ldh [rVBK], a
	ld a, [$C6DD]
	ld d, a
Jump_0602:
	ld a, [$C6DC]
	ld e, a
Jump_0606:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_0606
	ld a, [bc]
	ld [hli], a
	inc bc
	dec e
	jr nz, Jump_0606
	ldh a, [$FFC0]
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	dec d
	jr nz, Jump_0602
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_0622:
	push af
	push bc
	push de
	push hl
	ld h, $00
	ld l, e
	sla l
	rl h
	sla l
	rl h
	sla l
	rl h
	sla l
	rl h
	add a, h
	ld h, a
Jump_063B:
	ld e, $10
Jump_063D:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_063D
	ld a, [bc]
	ld [hli], a
	inc bc
	dec e
	jr nz, Jump_063D
	dec d
	jr nz, Jump_063B
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_0651:
	ld a, [$C000]
	cp $11
	ret z
	ld a, $C1
	ldh [rLCDC], a
	ld b, $3B
Jump_065D:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_065D
	ld a, $1B
	ldh [rBGP], a
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, b
	ld [rROMB0], a
	ld a, $88
	ld d, $DD
	ld e, $00
	ld bc, $4000
	call Func_0622
	ld bc, $4DE0
	ld hl, $9800
	ld d, $11
Jump_0683:
	ld e, $14
Jump_0685:
	ldh a, [rSTAT]
	and $02
	jr z, Jump_0685
Jump_068B:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_068B
	ld a, [bc]
	ld [hli], a
	inc bc
	dec e
	jr nz, Jump_0685
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	dec d
	jr nz, Jump_0683
	call Func_0051
	pop af
	ld [rROMB0], a
Jump_06A9:
	jr Jump_06A9


EnableDoubleSpeed:
	push hl
	di
	ld hl, $FFFF
	ld a, [hl]
	push af
	xor a
	ld [hl], a
	ldh [rIF], a
	ld a, $30
	ldh [rP1], a
	ld a, $01
	ldh [rKEY1], a
	stop
	pop af
	ld [hl], a
	ei
	pop hl
	ret


Func_06C5:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_40CE
	pop af
	ld [rROMB0], a
	ret


Func_06D6:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_4102
	pop af
	ld [rROMB0], a
	ret


Func_06E7:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_4143
	pop af
	ld [rROMB0], a
	ret


Func_06F8:
	ld e, $57
	call Audio_QueueSound
	ld d, $20
	ld e, $01
Jump_0701:
	call Audio_Update
	xor a
	ld [wVBlankPending], a
Jump_0708:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_0708
	xor a
	ld [wVBlankPending], a
	call Func_3878
	call Func_3A1E
	dec d
	jr nz, Jump_0701
	ret


Func_071F:
	ld e, $57
	call Audio_QueueSound
	ld d, $20
	ld e, $01
	call Func_3889
	ret


Func_072C:
	push af
	push bc
	push de
	push hl
	ld hl, $C0FF
	ld bc, $0F01
	call Func_050B
	ld hl, $FE00
	ld b, $A0
	call Func_0059
	ld hl, $FF80
	ld b, $7F
	call Func_0059
	ld a, $07
Jump_074B:
	ldh [rSVBK], a
	ld hl, $D000
	ld bc, $1000
	push af
	call Func_050B
	pop af
	dec a
	jr nz, Jump_074B
	ld a, $01
	ldh [rSVBK], a
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_0764:
	call Func_04B6
	xor a
	ldh [rSCX], a
	ldh [rSCY], a
	ldh [rSTAT], a
	ldh [rWY], a
	ldh [rWX], a
	ld a, $E4
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	ldh a, [rLCDC]
	and $EF
	ldh [rLCDC], a
	ret


Func_0781:
	ldh a, [rLY]
	cp $90
	jr nz, Func_0781
	ld hl, $FE00
	ld b, $A0
	xor a
Jump_078D:
	ld [hl], a
	inc l
	dec b
	jr nz, Jump_078D
	ld hl, $C600
	ld b, $A0
	call Func_0059
	ldh a, [rLCDC]
	and $FB
	ldh [rLCDC], a
	ldh a, [rLCDC]
	or $02
	ldh [rLCDC], a
	ret


Func_07A7:
	ld a, $08
	ld [rROMB0], a
	ld a, $27
	ld [rROMB0], a
	ld hl, Bank27ObjectPalette
	ld b, $00
	ld c, $01
	call Func_057D
	ld a, $28
	ld [rROMB0], a
	ld hl, Bank28ObjectPalette
	ld b, $01
	ld c, $01
	call Func_057D
	ld a, $29
	ld [rROMB0], a
	ld hl, Bank29ObjectPalette
	ld b, $02
	ld c, $01
	call Func_057D
	ld a, $08
	ld [rROMB0], a
	ld hl, Bank08ObjectPalette46EA
	ld b, $03
	ld c, $01
	call Func_057D
	ld a, $08
	ld [rROMB0], a
	ld hl, Bank08ObjectPalettes67FD
	ld b, $04
	ld c, $04
	call Func_057D
	ld a, $08
	ld [rROMB0], a
	ld hl, $44A2
	ld b, $07
	ld c, $01
	call Func_052F
	ret


Func_0807:
	ld a, $08
	ld [rROMB0], a
	ld a, $01
	ldh [rVBK], a
	ld e, $40
	ld d, $01
	ld a, $80
	ld bc, Bank08InterfaceTiles60F8
	call Func_0622
	ld e, $41
	ld d, $02
	ld a, $80
	ld bc, Bank08InterfaceTiles6222
	call Func_0622
	ld e, $43
	ld d, $10
	ld a, $80
	ld bc, Bank08InterfaceTiles611A
	call Func_0622
	ld a, $08
	ld [rROMB0], a
	ld e, $53
	ld d, $0A
	ld a, $80
	ld bc, Bank08HudIconTiles
	call Func_0622
	ld a, $08
	ld [rROMB0], a
	ld e, $5D
	ld d, $0C
	ld a, $80
	ld bc, Bank08InterfaceTiles6815
	call Func_0622
	ld a, $08
	ld [rROMB0], a
	ld e, $43
	ld d, $3D
	ld a, $88
	ld bc, Bank08UiFontTiles + $10
	call Func_0622
	ld a, $08
	ld [rROMB0], a
	ld e, $3B
	ld d, $08
	ld a, $88
	ld bc, Bank08AlphanumericFontTiles + $48
	call Func_0622
	ret


Func_0879:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $08
	ld [rROMB0], a
	xor a
	ldh [rVBK], a
	ld e, $00
	ld d, $4E
	ld a, $80
	ld bc, Bank08InterfaceTiles626B
	call Func_0622
	ld e, $4E
	ld d, $04
	ld a, $80
	ld bc, Bank08InterfaceTiles68DD
	call Func_0622
	ld e, $52
	ld d, $04
	ld a, $80
	ld bc, Bank08ArrowUpTiles
	call Func_0622
	ld e, $56
	ld d, $04
	ld a, $80
	ld bc, Bank08ArrowDownTiles
	call Func_0622
	ld e, $5A
	ld d, $04
	ld a, $80
	ld bc, Bank08AlphanumericFontTiles
	call Func_0622
	pop af
	ld [rROMB0], a
	ret


Func_08C6:
	di
	ld d, a
	xor a
	ldh [rIE], a
	ldh [rIF], a
	call Func_04B6
	call Func_072C
	ld a, d
	ld [$C000], a
	call Func_0651
	call Func_0764
	call LoadOAMDMARoutine
	call Func_0AC4
	call Func_0051
	ld hl, Func_367F
	ld a, l
	ld [wRuntimeCallback], a
	ld a, h
	ld [wRuntimeCallback + 1], a
	xor a
	ldh [rIF], a
	xor a
	ld [$CD08], a
	ld a, $00
	ld [$C6CF], a
	call Func_0413
	ei
	nop
	ret


Func_0903:
	ld a, [wLevelNumber]
	call LoadLevelData
	ld b, $00
	ld c, $00
	call Func_1B07
	ret


LoadOAMDMARoutine:
	push af
	push bc
	push de
	push hl
	ld hl, $0925
	ld bc, $FFF0
	ld e, $0A
	call CopyBytesShort
	pop hl
	pop de
	pop bc
	pop af
	ret


	LOAD UNION "RAM code $FFF0", HRAM[$FFF0] ; copied from $00:0925

OAMDMARoutine:
	ld a, $C6
	ldh [rDMA], a
	ld a, $28
RAM_FFF6:
	dec a
	jr nz, RAM_FFF6
	ret

	ENDL

Func_092F:
	push af
	push bc
	push de
	push hl
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $08
	ld [rROMB0], a
	ld hl, Bank08HudIconPalette
	ld bc, wHudIconPalette
	ld e, $08
	call CopyBytesShort
	ld a, $08
	ld [rROMB0], a
	ld hl, Bank08UiFontPalette
	ld bc, wUiFontPalette
	ld e, $08
	call CopyBytesShort
	ld a, $08
	ld [rROMB0], a
	ld hl, Bank08ArrowUpPalette
	ld bc, wArrowUpPalette
	ld e, $08
	call CopyBytesShort
	ld a, $08
	ld [rROMB0], a
	ld hl, Bank08ArrowDownPalette
	ld bc, wArrowDownPalette
	ld e, $08
	call CopyBytesShort
	ld a, $08
	ld [rROMB0], a
	ld hl, Bank08AlphanumericFontPalette
	ld bc, wAlphanumericFontPalette
	ld e, $08
	call CopyBytesShort
	ld hl, $C719
	ld de, $FF69
	ld c, $08
	ld b, $00
Jump_0991:
	ld a, b
	add a, $B0
	ldh [rBCPS], a
Jump_0996:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_0996
	ld a, [de]
	ld [hli], a
	inc b
	dec c
	jr nz, Jump_0991
	pop af
	ld [rROMB0], a
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_09AB:
	call Func_0AC4
	call Func_04CD
	ld hl, $D000
	ld bc, $1000
	call Func_050B
	call Func_2028
	call Func_2058
	call Func_00F9
	call Func_0781
	call Func_0903
	call Func_2A99
	ld a, [$CD06]
	ld b, a
	ld a, [$CD07]
	or b
	jr nz, Jump_09E6
	ld a, [$CD05]
	cp $C3
	jr c, Jump_09ED
	jr nz, Jump_09E6
	ld a, [$CD04]
	cp $50
	jr c, Jump_09ED
Jump_09E6:
	ld a, $01
	ld [$CD0A], a
	jr Jump_09F1

Jump_09ED:
	xor a
	ld [$CD0A], a
Jump_09F1:
	xor a
	ld [$C0FF], a
	ld [$C91D], a
	ld [$C91E], a
	ld [$C91F], a
	xor a
	ld [$C8D8], a
	ld [$C8D9], a
	ld b, $00
	ld a, [wLevelNumber]
	ld c, a
	ld hl, $0A14
	add hl, bc
	ld a, [hl]
	ld [$C8D3], a
	ret

	db $0A, $0A, $0A, $09, $09, $0A, $0B, $0B, $0B, $0A, $0A, $0A, $0A, $0A, $0A

Func_0A23:
	xor a
	ld [$C91D], a
	ld [$C8D7], a
	ld [$C8D6], a
	ld [$C6B9], a
	ld [$C6BA], a
	ld a, [$C91F]
	and a
	ret z
	ld h, a
	ld a, [$C91E]
	ld l, a
	ld a, [hl]
	dec a
	ld [hl], a
	xor a
	ld [$C91E], a
	ld [$C91F], a
	ret


Func_0A48:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_406F
	pop af
	ld [rROMB0], a
	ret


Func_0A59:
	ld a, $20
	ldh [rP1], a
	ldh a, [rP1]
	ldh a, [rP1]
	cpl
	and $0F
	swap a
	ld b, a
	ld a, $10
	ldh [rP1], a
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	cpl
	and $0F
	or b
	swap a
	ld b, a
	ld a, [$C6B5]
	xor b
	and b
	ld [$C6B6], a
	ld a, b
	ld [$C6B5], a
	ld a, $30
	ldh [rP1], a
	ret


CopyBytes:
	push af
	push bc
	push de
	push hl
Jump_0A93:
	ld a, [hli]
	ld [bc], a
	inc bc
	dec de
	ld a, e
	or a
	jr nz, Jump_0A93
	ld a, d
	or a
	jr nz, Jump_0A93
	pop hl
	pop de
	pop bc
	pop af
	ret


CopyBytesShort:
	push af
	push bc
	push de
	push hl
Jump_0AA8:
	ld a, [hli]
	ld [bc], a
	inc bc
	dec e
	jr nz, Jump_0AA8
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_0AB3:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_418A
	pop af
	ld [rROMB0], a
	ret


Func_0AC4:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_4238
	pop af
	ld [rROMB0], a
	ret


Func_0AD5:
	push bc
	push de
	push af
	ld a, $01
	call Func_1FF5
	ld bc, $0000
	ld de, $0000
	call Func_2125
	xor a
	call Func_2115
	pop af
	call Func_0D0F
	ld a, l
	and $C0
	ld l, a
	pop de
	pop bc
	ret


Func_0AF5:
	push de
	push bc
	push hl
	push af
	push bc
	push de
	push hl
	call Func_37DF
	pop hl
	pop de
	pop bc
	pop af
	ldh [$FF81], a
	ld a, b
	ldh [$FF80], a
	ld a, l
	and $C0
	add a, $1E
	ld l, a
	ld a, [hl]
	ldh [$FF82], a
	ld a, l
	and $C0
	inc a
	ld l, a
	ld a, [hli]
	ld c, a
	ldh [$FF83], a
	ld a, [hli]
	ld b, a
	ldh [$FF84], a
	inc l
	ld a, [hli]
	ld e, a
	ldh [$FF85], a
	ld a, [hl]
	ld d, a
	ldh [$FF86], a
	call Func_2044
	ldh a, [$FF81]
	or a
	jr z, Jump_0B3B
	push de
	ld e, $46
	call Audio_QueueSound
	pop de
	ld a, $00
	call Func_3090
Jump_0B3B:
	ldh a, [$FF80]
	or a
	jr z, Jump_0B4C
	push bc
	ld b, $00
	ld c, $F0
	call Func_372E
	pop bc
	call Func_2125
Jump_0B4C:
	ldh a, [$FF82]
	cp $03
	jr nz, Jump_0B61
	ldh a, [$FF83]
	ld c, a
	ldh a, [$FF84]
	ld b, a
	ldh a, [$FF85]
	ld e, a
	ldh a, [$FF86]
	ld d, a
	call Func_0B65
Jump_0B61:
	pop hl
	pop bc
	pop de
	ret


Func_0B65:
	push af
	push bc
	push de
	push hl
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	dec c
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	dec e
	call Func_1D26
	inc c
	call Func_1D26
	dec c
	inc e
	call Func_1D26
	inc c
	call Func_1D26
	dec c
	inc e
	call Func_1D26
	inc c
	call Func_1D26
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_0BA1:
	push de
	push bc
	push hl
	ld a, l
	and $C0
	add a, $08
	ld l, a
	ld a, [hl]
	and $01
	jr z, Jump_0BB8
	ld a, l
	and $C0
	ld l, a
	call Func_2295
	jr Jump_0BBF

Jump_0BB8:
	ld a, l
	and $C0
	ld l, a
	call Func_2241
Jump_0BBF:
	ld a, l
	and $C0
	add a, $1A
	ld l, a
	ld a, [hl]
	or a
	jp z, Jump_0C12
	ld a, l
	and $C0
	add a, $0D
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	inc l
	ld e, [hl]
	ld a, l
	and $C0
	ld l, a
	ld a, [hli]
	add a, c
	ld c, a
	ld a, [hli]
	adc a, b
	ld b, a
	ld a, [hl]
	adc a, e
	ld e, a
	ld a, l
	and $C0
	add a, $13
	ld l, a
	ld [hl], c
	inc l
	ld [hl], b
	inc l
	ld [hl], e
	ld a, l
	and $C0
	add a, $10
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	inc l
	ld e, [hl]
	ld a, l
	and $C0
	add a, $03
	ld l, a
	ld a, [hli]
	add a, c
	ld c, a
	ld a, [hli]
	adc a, b
	ld b, a
	ld a, [hl]
	adc a, e
	ld e, a
	ld a, l
	and $C0
	add a, $16
	ld l, a
	ld [hl], c
	inc l
	ld [hl], b
	inc l
	ld [hl], e
Jump_0C12:
	ld a, l
	and $C0
	ld l, a
	pop hl
	pop bc
	pop de
	ret


GetObjectScoreValue:
	push af
	push hl
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $05
	ld [rROMB0], a
	ld a, l
	and $C0
	add a, $1E
	ld l, a
	ld a, [hl]
	sla a
	ld hl, ObjectScoreValues
	add a, l
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	pop af
	ld [rROMB0], a
	pop hl
	pop af
	ret

	db $23, $32, $41, $28

Func_0C41:
	push hl
	ld a, l
	and $C0
	add a, $1E
	ld l, a
	ld a, [hl]
	ld hl, $0C3D
	add a, l
	ld l, a
	ld a, [hl]
	pop hl
	ret


Func_0C51:
	push af
	push hl
	ld a, l
	and $C0
	add a, $08
	ld l, a
	ld a, [hl]
	or $01
	ld [hl], a
	ld a, l
	and $C0
	add a, $25
	ld l, a
	ld b, [hl]
	ld a, l
	and $C0
	add a, $1A
	ld l, a
	ld a, [hl]
	cp b
	jr nc, Jump_0C70
	inc a
	ld b, a
Jump_0C70:
	ld [hl], b
	pop hl
	pop af
	ret


Func_0C74:
	push af
	push hl
	ld a, l
	and $C0
	add a, $08
	ld l, a
	ld a, [hl]
	and $FE
	ld [hl], a
	ld a, l
	and $C0
	add a, $25
	ld l, a
	ld b, [hl]
	ld a, l
	and $C0
	add a, $1A
	ld l, a
	ld a, [hl]
	cp b
	jr nc, Jump_0C93
	inc a
	ld b, a
Jump_0C93:
	ld [hl], b
	pop hl
	pop af
	ret


Func_0C97:
	push af
	push hl
	ld a, l
	and $C0
	add a, $1A
	ld l, a
	ld a, [hl]
	or a
	jr z, Jump_0CA5
	dec a
	ld [hl], a
Jump_0CA5:
	pop hl
	pop af
	ret


Func_0CA8:
	push af
	push hl
	ld a, l
	and $C0
	add a, $1A
	ld l, a
	xor a
	ld [hl], a
	pop hl
	pop af
	ret


Func_0CB5:
	push af
	push hl
	ld a, l
	and $C0
	add a, $24
	ld l, a
	ld a, [hl]
	or a
	jr nz, Jump_0CDA
	ld a, l
	and $C0
	add a, $23
	ld l, a
	ld b, [hl]
	ld a, l
	and $C0
	add a, $24
	ld l, a
	ld [hl], b
	ld a, l
	and $C0
	add a, $19
	ld l, a
	ld a, [hl]
	dec a
	and $0F
	ld [hl], a
Jump_0CDA:
	pop hl
	pop af
	ret


Func_0CDD:
	push af
	push hl
	ld a, l
	and $C0
	add a, $24
	ld l, a
	ld a, [hl]
	or a
	jr nz, Jump_0D02
	ld a, l
	and $C0
	add a, $23
	ld l, a
	ld b, [hl]
	ld a, l
	and $C0
	add a, $24
	ld l, a
	ld [hl], b
	ld a, l
	and $C0
	add a, $19
	ld l, a
	ld a, [hl]
	inc a
	and $0F
	ld [hl], a
Jump_0D02:
	pop hl
	pop af
	ret


Func_0D05:
	push hl
	ld a, l
	and $C0
	add a, $1E
	ld l, a
	ld a, [hl]
	pop hl
	ret


Func_0D0F:
	push hl
	push de
	push bc
	ld b, a
	ld a, l
	and $C0
	add a, $1E
	ld l, a
	ld [hl], b
	ld a, b
	cp $00
	jr z, Jump_0D33
	cp $01
	jr z, Jump_0D3B
	cp $02
	jr z, Jump_0D2B
	cp $03
	jr z, Jump_0D43
Jump_0D2B:
	ld b, $05
	ld c, $03
	ld d, $1E
	jr Jump_0D4B

Jump_0D33:
	ld b, $03
	ld c, $05
	ld d, $19
	jr Jump_0D4B

Jump_0D3B:
	ld b, $04
	ld c, $04
	ld d, $14
	jr Jump_0D4B

Jump_0D43:
	ld b, $03
	ld c, $00
	ld d, $23
	jr Jump_0D4B

Jump_0D4B:
	ld a, l
	and $C0
	add a, $23
	ld l, a
	ld [hl], b
	ld a, l
	and $C0
	add a, $25
	ld l, a
	ld [hl], c
	ld a, l
	and $C0
	add a, $20
	ld l, a
	ld [hl], d
	ld b, $00
	ld a, l
	and $C0
	add a, $26
	ld l, a
	ld [hl], b
	ld a, l
	and $C0
	add a, $1A
	ld l, a
	ld [hl], b
	ld a, l
	and $C0
	add a, $27
	ld l, a
	ld [hl], b
	ld a, l
	and $C0
	add a, $28
	ld l, a
	ld [hl], b
	ld a, l
	and $C0
	add a, $2A
	ld l, a
	ld [hl], b
	ld a, l
	and $C0
	add a, $29
	ld l, a
	ld [hl], $00
	ld a, l
	and $C0
	add a, $22
	ld l, a
	ld [hl], b
	ld a, l
	and $C0
	add a, $21
	ld l, a
	ld [hl], b
	ld a, l
	and $C0
	add a, $24
	ld l, a
	ld [hl], b
	ld a, l
	and $C0
	add a, $2B
	ld l, a
	ld [hl], b
	inc l
	ld [hl], b
	ld a, l
	and $C0
	ld l, a
	call Func_2F93
	pop bc
	pop de
	pop hl
	ret


Func_0DB6:
	push de
	push bc
	push hl
	ld e, l
	ld a, $27
	add a, e
	ld l, a
	ld a, [hl]
	or a
	jr z, Jump_0DCB
	ld a, $28
	add a, e
	ld l, a
	ld a, [hl]
	or a
	jp z, Jump_0E35
Jump_0DCB:
	ld a, $1E
	add a, e
	ld l, a
	ld a, [hl]
	ldh [$FF80], a
	ld a, $06
	add a, e
	ld l, a
	ld a, [hli]
	ldh [$FF82], a
	ld a, [hl]
	ldh [$FF83], a
	ld a, $01
	add a, e
	ld l, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	ld a, c
	ldh [$FF86], a
	inc l
	ld a, [hli]
	ld c, a
	ld a, [hl]
	ld b, a
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	ld a, c
	ldh [$FF87], a
	ld a, $19
	add a, e
	ld l, a
	ld a, [hl]
	ldh [$FF81], a
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $05
	ld [rROMB0], a
	ldh a, [$FF80]
	cp $03
	jr z, Jump_0E39
	ld a, $09
	call Func_20D2
	cp $FF
	jr z, Jump_0E31
	ldh [$FF84], a
	call Func_0F43
	call Func_0F91
	call Func_0F0C
Jump_0E31:
	pop af
	ld [rROMB0], a
Jump_0E35:
	pop hl
	pop bc
	pop de
	ret

Jump_0E39:
	ldh a, [$FF86]
	ld c, a
	ldh a, [$FF87]
	ld e, a
	ld a, [$CA10]
	ld l, a
	ld a, c
	sub l
	dec a
	ld c, a
	ld a, [$CA14]
	add a, c
	and $1F
	ld c, a
	ld a, [$CA0F]
	ld l, a
	ld a, e
	sub l
	dec a
	ld e, a
	ld a, [$CA13]
	add a, e
	and $1F
	ld e, a
	ld d, $00
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	ld a, e
	add a, c
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	ld hl, $9800
	add hl, de
	ld a, l
	ldh [$FF88], a
	ld a, h
	ldh [$FF89], a
	ldh a, [$FF81]
	add a, a
	ld c, a
	add a, a
	add a, c
	add a, a
	ld bc, $43E0
	add a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	ld a, c
	ldh [$FF8A], a
	ld a, b
	ldh [$FF8B], a
	ld a, $08
	ld [rROMB0], a
	ld a, $03
	ldh [$FF8C], a
Jump_0EA3:
	ldh a, [$FF8A]
	ld l, a
	ldh a, [$FF8B]
	ld h, a
	ld a, [hli]
	add a, $42
	ld c, a
	ld a, [hli]
	or $0F
	ld b, a
	ldh a, [$FF88]
	ld e, a
	ldh a, [$FF89]
	ld d, a
	call Func_3C28
	ld a, [hli]
	add a, $42
	ld c, a
	ld a, [hli]
	or $0F
	ld b, a
	ld a, l
	ldh [$FF8A], a
	ld a, h
	ldh [$FF8B], a
	ldh a, [$FF88]
	ld l, a
	ldh a, [$FF89]
	ld h, a
	push af
	push de
	ld a, l
	and $E0
	ld e, a
	ld a, l
	inc a
	and $1F
	or e
	ld l, a
	pop de
	pop af
	ld e, l
	ld d, h
	call Func_3C28
	ldh a, [$FF88]
	ld l, a
	ldh a, [$FF89]
	ld h, a
	push af
	ld a, $20
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	and $03
	or $98
	ld h, a
	pop af
	ld a, l
	ldh [$FF88], a
	ld a, h
	ldh [$FF89], a
	ldh a, [$FF8C]
	dec a
	or a
	jr z, Jump_0F05
	ldh [$FF8C], a
	jr Jump_0EA3

Jump_0F05:
	pop af
	ld [rROMB0], a
	jp Jump_0E35


Func_0F0C:
	ld a, $05
	ld [rROMB0], a
	ld hl, ObjectOrientationLayoutPointers
	ldh a, [$FF81]
	sla a
	add a, l
	ld l, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld c, $09
Jump_0F1F:
	call Func_2090
	ldh a, [$FF83]
	ld b, a
	ld a, [hli]
	add a, b
	ld [de], a
	inc e
	ldh a, [$FF82]
	ld b, a
	ld a, [hli]
	add a, b
	ld [de], a
	inc e
	ldh a, [$FF84]
	ld b, a
	ld a, [hli]
	add a, b
	ld [de], a
	inc e
	ld a, [hli]
	or $08
	ld b, a
	ldh a, [$FF85]
	add a, b
	ld [de], a
	dec c
	jr nz, Jump_0F1F
	ret


Func_0F43:
	ld a, $05
	ld [rROMB0], a
	ld hl, ObjectOrientationTilePointers
	ldh a, [$FF81]
	sla a
	add a, l
	ld l, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ldh a, [$FF80]
	add a, $27
	ld [rROMB0], a
	ld b, $09
Jump_0F5D:
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
	inc de
	dec b
	jr nz, Jump_0F5D
	ret


Func_0F91:
	ldh a, [$FF80]
	add a, $00
	ldh [$FF85], a
	ret


Func_0F98:
	push de
	push hl
	ld a, l
	and $C0
	add a, $21
	ld l, a
	ld a, [hl]
	or a
	jr nz, Jump_101F
	ld a, l
	and $C0
	add a, $22
	ld l, a
	ld a, [hl]
	cp $03
	jr z, Jump_101F
	ld a, l
	and $C0
	add a, $20
	ld l, a
	ld e, [hl]
	ld a, l
	and $C0
	add a, $21
	ld l, a
	ld [hl], e
	ld a, l
	and $C0
	add a, $29
	ld l, a
	ld e, [hl]
	ld a, $03
	cp e
	jr nz, Jump_0FCE
	call Func_3CFB
	jr Jump_0FFA

Jump_0FCE:
	ld a, l
	and $C0
	add a, $22
	ld l, a
	ld a, [hl]
	inc a
	ld [hl], a
	ld a, l
	and $C0
	ld l, a
	ld b, e
	call Func_2B86
	jr z, Jump_101F
	call Func_307F
	push bc
	ld a, l
	and $C0
	add a, $08
	ld l, a
	ld a, [hl]
	ld b, a
	cpl
	and $10
	ld c, a
	ld a, b
	and $EF
	or c
	ld [hl], a
	pop bc
	call Func_1023
Jump_0FFA:
	ld a, e
	cp $00
	jr z, Jump_1012
	ld a, l
	and $C0
	add a, $2A
	ld l, a
	ld a, [hl]
	dec a
	ld [hl], a
	jr nz, Jump_1012
	ld a, l
	and $C0
	add a, $29
	ld l, a
	ld [hl], $00
Jump_1012:
	ld a, l
	and $C0
	add a, $28
	ld l, a
	ld [hl], $02
	xor a
	inc a
	pop hl
	pop de
	ret

Jump_101F:
	xor a
	pop hl
	pop de
	ret


Func_1023:
	push af
	push bc
	push de
	push hl
	ld a, l
	and $C0
	add a, $26
	ld l, a
	ld a, [hl]
	and a
	jr nz, Jump_1046
	ld a, e
	ld b, $04
	cp $01
	jr nz, Jump_103C
	ld b, $05
	jr Jump_1042

Jump_103C:
	cp $02
	jr nz, Jump_1042
	ld b, $1B
Jump_1042:
	ld e, b
	call Audio_QueueSound
Jump_1046:
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_104B:
	push de
	push bc
	push hl
	ld a, l
	and $C0
	add a, $21
	ld l, a
	ld a, [hl]
	or a
	jr z, Jump_105A
	dec a
	ld [hl], a
Jump_105A:
	ld a, l
	and $C0
	add a, $24
	ld l, a
	ld a, [hl]
	or a
	jr z, Jump_1066
	dec a
	ld [hl], a
Jump_1066:
	ld a, [$C6B9]
	and $0F
	jr nz, Jump_1085
	ld a, l
	and $C0
	add a, $27
	ld l, a
	ld a, [hl]
	or a
	jr z, Jump_1085
	dec a
	ld [hl], a
	ld a, l
	and $C0
	add a, $28
	ld l, a
	ld a, [hl]
	or a
	jr z, Jump_1085
	dec a
	ld [hl], a
Jump_1085:
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld a, [hl]
	or a
	jr nz, Jump_10E0
	ld a, l
	and $C0
	ld l, a
	ld a, [$CD00]
	cp l
	jr nz, Jump_109F
	ld a, [$CD01]
	cp h
	jr z, Jump_10CA
Jump_109F:
	ld a, l
	and $C0
	add a, $2B
	ld l, a
	ld b, [hl]
	inc l
	ld a, [$CD00]
	cp b
	jr nz, Jump_10BA
	ld b, [hl]
	ld a, [$CD01]
	cp b
	jr nz, Jump_10BA
	call GetObjectScoreValue
	call AddToScore
Jump_10BA:
	ld a, l
	and $C0
	ld l, a
	ld a, $01
	ld b, $01
	call Func_0AF5
	xor a
	pop hl
	pop bc
	pop de
	ret

Jump_10CA:
	ld a, l
	and $C0
	ld l, a
	ld a, $01
	ld b, $00
	call Func_0AF5
	ld bc, $0078
	call Func_0396
	xor a
	pop hl
	pop bc
	pop de
	ret

Jump_10E0:
	xor a
	inc a
	pop hl
	pop bc
	pop de
	ret


Func_10E6:
	push af
	push bc
	push de
	push hl
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	push bc
	push de
	push bc
	push de
	ld d, $00
	sla e
	rl d
	ld hl, wLevelRowOffsets
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, c
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop de
	pop bc
	push hl
	ldh a, [rSVBK]
	ld b, a
	ld a, h
	and $10
	swap a
	add a, $02
	ldh [rSVBK], a
	ld a, h
	and $0F
	ld h, a
	xor a
	add a, l
	ld l, a
	ld a, $D0
	adc a, h
	ld h, a
	ld c, [hl]
	ld a, b
	ldh [rSVBK], a
	pop hl
	ld a, c
	and $0C
	jr z, Jump_115C
	pop de
	pop bc
	call Func_1531
	ldh [$FF90], a
	call Func_1578
	ldh [$FF91], a
	call Func_15C0
	ldh [$FF92], a
	call Func_1607
	ldh [$FF93], a
	call Func_1425
	pop hl
	pop de
	pop bc
	pop af
	ret

Jump_115C:
	pop de
	pop bc
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_1163:
	push af
	push bc
	push de
	push hl
	ld a, [$CA0F]
	ldh [$FF98], a
	add a, $12
	ld c, a
	ld a, [wLevelHeight]
	dec a
	cp c
	jr nc, Jump_1177
	ld c, a
Jump_1177:
	ld a, c
	ldh [$FF99], a
	ld a, [$CA10]
	ldh [$FF96], a
	add a, $14
	ld c, a
	ld a, [wLevelWidth]
	dec a
	cp c
	jr nc, Jump_118A
	ld c, a
Jump_118A:
	ld a, c
	ldh [$FF97], a
	ldh a, [$FF98]
	ldh [$FF9A], a
Jump_1191:
	ldh a, [$FF96]
	ldh [$FF9B], a
Jump_1195:
	ldh a, [$FF9B]
	ld c, a
	ldh a, [$FF9A]
	ld e, a
	call Func_11BB
	ldh a, [$FF97]
	inc a
	ld b, a
	ldh a, [$FF9B]
	inc a
	ldh [$FF9B], a
	cp b
	jr c, Jump_1195
	ldh a, [$FF99]
	inc a
	ld b, a
	ldh a, [$FF9A]
	inc a
	ldh [$FF9A], a
	cp b
	jr c, Jump_1191
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_11BB:
	push af
	push bc
	push de
	push hl
	push bc
	push de
	push bc
	push de
	ld d, $00
	sla e
	rl d
	ld hl, wLevelRowOffsets
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, c
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop de
	pop bc
	push hl
	ldh a, [rSVBK]
	ld b, a
	ld a, h
	and $10
	swap a
	add a, $02
	ldh [rSVBK], a
	ld a, h
	and $0F
	ld h, a
	xor a
	add a, l
	ld l, a
	ld a, $D0
	adc a, h
	ld h, a
	ld c, [hl]
	ld a, b
	ldh [rSVBK], a
	pop hl
	ld a, c
	and $0C
	pop de
	pop bc
	jr z, Jump_1214
	call Func_1531
	ldh [$FF90], a
	call Func_1578
	ldh [$FF91], a
	call Func_15C0
	ldh [$FF92], a
	call Func_1607
	ldh [$FF93], a
	call Func_12D8
Jump_1214:
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_1219:
	push af
	push bc
	push de
	push hl
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	push bc
	push de
	push bc
	push de
	ld d, $00
	sla e
	rl d
	ld hl, wLevelRowOffsets
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, c
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop de
	pop bc
	push hl
	ldh a, [rSVBK]
	ld b, a
	ld a, h
	and $10
	swap a
	add a, $02
	ldh [rSVBK], a
	ld a, h
	and $0F
	ld h, a
	xor a
	add a, l
	ld l, a
	ld a, $D0
	adc a, h
	ld h, a
	ld c, [hl]
	ld a, b
	ldh [rSVBK], a
	pop hl
	ld a, c
	and $08
	jr z, Jump_129A
	pop de
	pop bc
	call Func_1531
	ldh [$FF90], a
	call Func_1578
	ldh [$FF91], a
	call Func_15C0
	ldh [$FF92], a
	call Func_1607
	ldh [$FF93], a
	call Func_12A1
	ld e, $21
	call Audio_QueueSound
	ld bc, $0014
	call AddToScore
	pop hl
	pop de
	pop bc
	pop af
	ret

Jump_129A:
	pop de
	pop bc
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_12A1:
	push af
	push bc
	push de
	push hl
	ldh a, [$FF92]
	ldh [$FF94], a
Jump_12A9:
	ldh a, [$FF90]
	ldh [$FF95], a
Jump_12AD:
	ldh a, [$FF95]
	ld c, a
	ldh a, [$FF94]
	ld e, a
	call Func_1399
	jr z, Jump_12BB
	call Func_1D26
Jump_12BB:
	ldh a, [$FF91]
	inc a
	ld b, a
	ldh a, [$FF95]
	inc a
	ldh [$FF95], a
	cp b
	jr c, Jump_12AD
	ldh a, [$FF93]
	inc a
	ld b, a
	ldh a, [$FF94]
	inc a
	ldh [$FF94], a
	cp b
	jr c, Jump_12A9
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_12D8:
	push af
	push bc
	push de
	push hl
	xor a
	ldh [$FF9E], a
	ldh [$FF9F], a
	ld e, $45
	call Audio_QueueSound
	ldh a, [$FF92]
	ldh [$FF94], a
Jump_12EA:
	ldh a, [$FF90]
	ldh [$FF95], a
Jump_12EE:
	ldh a, [$FF95]
	ld c, a
	ldh a, [$FF94]
	ld e, a
	call Func_132E
	jr z, Jump_1308
	ldh a, [$FF9E]
	add a, $05
	ldh [$FF9E], a
	ldh a, [$FF9F]
	adc a, $00
	ldh [$FF9F], a
	call Func_1D26
Jump_1308:
	ldh a, [$FF91]
	inc a
	ld b, a
	ldh a, [$FF95]
	inc a
	ldh [$FF95], a
	cp b
	jr c, Jump_12EE
	ldh a, [$FF93]
	inc a
	ld b, a
	ldh a, [$FF94]
	inc a
	ldh [$FF94], a
	cp b
	jr c, Jump_12EA
	ldh a, [$FF9E]
	ld c, a
	ldh a, [$FF9F]
	ld b, a
	call AddToScore
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_132E:
	push de
	push bc
	push hl
	push bc
	push de
	ld d, $00
	sla e
	rl d
	ld hl, wLevelRowOffsets
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, c
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop de
	pop bc
	push hl
	ldh a, [rSVBK]
	ld b, a
	ld a, h
	and $10
	swap a
	add a, $02
	ldh [rSVBK], a
	ld a, h
	and $0F
	ld h, a
	xor a
	add a, l
	ld l, a
	ld a, $D0
	adc a, h
	ld h, a
	ld c, [hl]
	ld a, b
	ldh [rSVBK], a
	pop hl
	ld a, c
	and $04
	jr z, Jump_1394
	ld a, c
	and $B1
	or $81
	ld c, a
	push hl
	ldh a, [rSVBK]
	ld b, a
	ld a, h
	and $10
	swap a
	add a, $02
	ldh [rSVBK], a
	ld a, h
	and $0F
	ld h, a
	xor a
	add a, l
	ld l, a
	ld a, $D0
	adc a, h
	ld h, a
	ld [hl], c
	ld a, b
	ldh [rSVBK], a
	pop hl
	xor a
	inc a
	pop hl
	pop bc
	pop de
	ret

Jump_1394:
	xor a
	pop hl
	pop bc
	pop de
	ret


Func_1399:
	push de
	push bc
	push hl
	push bc
	push de
	ld d, $00
	sla e
	rl d
	ld hl, wLevelRowOffsets
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, c
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop de
	pop bc
	push hl
	ldh a, [rSVBK]
	ld b, a
	ld a, h
	and $10
	swap a
	add a, $02
	ldh [rSVBK], a
	ld a, h
	and $0F
	ld h, a
	xor a
	add a, l
	ld l, a
	ld a, $D0
	adc a, h
	ld h, a
	ld c, [hl]
	ld a, b
	ldh [rSVBK], a
	pop hl
	ld a, c
	and $08
	jr z, Jump_13FF
	ld a, c
	and $F1
	or $81
	ld c, a
	push hl
	ldh a, [rSVBK]
	ld b, a
	ld a, h
	and $10
	swap a
	add a, $02
	ldh [rSVBK], a
	ld a, h
	and $0F
	ld h, a
	xor a
	add a, l
	ld l, a
	ld a, $D0
	adc a, h
	ld h, a
	ld [hl], c
	ld a, b
	ldh [rSVBK], a
	pop hl
	xor a
	inc a
	pop hl
	pop bc
	pop de
	ret

Jump_13FF:
	xor a
	pop hl
	pop bc
	pop de
	ret


Func_1404:
	ldh a, [$FF92]
	ld b, a
	ldh a, [$FF93]
	sub b
	inc a
	ld b, a
	call Func_043C
	ld b, a
	ldh a, [$FF92]
	add a, b
	ld e, a
	ldh a, [$FF90]
	ld b, a
	ldh a, [$FF91]
	sub b
	inc a
	ld b, a
	call Func_043C
	ld b, a
	ldh a, [$FF90]
	add a, b
	ld c, a
	ret


Func_1425:
	push af
	push bc
	push de
	push hl
	ld e, $44
	call Audio_QueueSound
	xor a
	ldh [$FF9D], a
	ldh [$FF9C], a
	ldh a, [$FF92]
	ldh [$FF94], a
Jump_1437:
	ldh a, [$FF90]
	ldh [$FF95], a
Jump_143B:
	call Func_1404
	call Func_14B3
	jr nz, Jump_1457
	ldh a, [$FF95]
	ld c, a
	ldh a, [$FF94]
	ld e, a
	call Func_14B3
	ldh a, [$FF9C]
	inc a
	ldh [$FF9C], a
	cp $06
	jr z, Jump_14AB
	jr z, Jump_148D
Jump_1457:
	call Func_1D26
	ldh a, [$FF9D]
	inc a
	ldh [$FF9D], a
	push af
	call Func_0421
	and $03
	jr nz, Jump_1488
	ld b, $00
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	ld d, $00
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	ld a, $02
	call Func_3090
Jump_1488:
	pop af
	cp $09
	jr z, Jump_14AE
Jump_148D:
	ldh a, [$FF91]
	inc a
	ld b, a
	ldh a, [$FF95]
	inc a
	ldh [$FF95], a
	cp b
	jr c, Jump_143B
	ldh a, [$FF93]
	inc a
	ld b, a
	ldh a, [$FF94]
	inc a
	ldh [$FF94], a
	cp b
	jr c, Jump_1437
	ldh a, [$FF9D]
	cp $05
	jr nc, Jump_14AE
Jump_14AB:
	call Func_12D8
Jump_14AE:
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_14B3:
	push de
	push bc
	push hl
	push bc
	push de
	ld d, $00
	sla e
	rl d
	ld hl, wLevelRowOffsets
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, c
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop de
	pop bc
	push hl
	ldh a, [rSVBK]
	ld b, a
	ld a, h
	and $10
	swap a
	add a, $02
	ldh [rSVBK], a
	ld a, h
	and $0F
	ld h, a
	xor a
	add a, l
	ld l, a
	ld a, $D0
	adc a, h
	ld h, a
	ld c, [hl]
	ld a, b
	ldh [rSVBK], a
	pop hl
	ld a, c
	and $04
	jr z, Jump_152C
	ld a, c
	and $C0
	jr nz, Jump_152C
	ld a, c
	and $0C
	cp $04
	jr z, Jump_1500
	cp $0C
	jr z, Jump_1505
Jump_1500:
	ld a, c
	or $40
	jr Jump_1508

Jump_1505:
	ld a, c
	or $80
Jump_1508:
	ld c, a
	push hl
	ldh a, [rSVBK]
	ld b, a
	ld a, h
	and $10
	swap a
	add a, $02
	ldh [rSVBK], a
	ld a, h
	and $0F
	ld h, a
	xor a
	add a, l
	ld l, a
	ld a, $D0
	adc a, h
	ld h, a
	ld [hl], c
	ld a, b
	ldh [rSVBK], a
	pop hl
	xor a
	inc a
	pop hl
	pop bc
	pop de
	ret

Jump_152C:
	xor a
	pop hl
	pop bc
	pop de
	ret


Func_1531:
	push bc
Jump_1532:
	push bc
	push bc
	push de
	ld d, $00
	sla e
	rl d
	ld hl, wLevelRowOffsets
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, c
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop de
	pop bc
	push hl
	ldh a, [rSVBK]
	ld b, a
	ld a, h
	and $10
	swap a
	add a, $02
	ldh [rSVBK], a
	ld a, h
	and $0F
	ld h, a
	xor a
	add a, l
	ld l, a
	ld a, $D0
	adc a, h
	ld h, a
	ld c, [hl]
	ld a, b
	ldh [rSVBK], a
	pop hl
	ld a, c
	pop bc
	and $0C
	jr z, Jump_1574
	dec c
	ld a, $FF
	cp c
	jr nz, Jump_1532
Jump_1574:
	inc c
	ld a, c
	pop bc
	ret


Func_1578:
	push bc
Jump_1579:
	push bc
	push bc
	push de
	ld d, $00
	sla e
	rl d
	ld hl, wLevelRowOffsets
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, c
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop de
	pop bc
	push hl
	ldh a, [rSVBK]
	ld b, a
	ld a, h
	and $10
	swap a
	add a, $02
	ldh [rSVBK], a
	ld a, h
	and $0F
	ld h, a
	xor a
	add a, l
	ld l, a
	ld a, $D0
	adc a, h
	ld h, a
	ld c, [hl]
	ld a, b
	ldh [rSVBK], a
	pop hl
	ld a, c
	pop bc
	and $0C
	jr z, Jump_15BC
	inc c
	ld a, [wLevelWidth]
	cp c
	jr nz, Jump_1579
Jump_15BC:
	dec c
	ld a, c
	pop bc
	ret


Func_15C0:
	push de
Jump_15C1:
	push bc
	push bc
	push de
	ld d, $00
	sla e
	rl d
	ld hl, wLevelRowOffsets
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, c
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop de
	pop bc
	push hl
	ldh a, [rSVBK]
	ld b, a
	ld a, h
	and $10
	swap a
	add a, $02
	ldh [rSVBK], a
	ld a, h
	and $0F
	ld h, a
	xor a
	add a, l
	ld l, a
	ld a, $D0
	adc a, h
	ld h, a
	ld c, [hl]
	ld a, b
	ldh [rSVBK], a
	pop hl
	ld a, c
	pop bc
	and $0C
	jr z, Jump_1603
	dec e
	ld a, $FF
	cp e
	jr nz, Jump_15C1
Jump_1603:
	inc e
	ld a, e
	pop de
	ret


Func_1607:
	push de
Jump_1608:
	push bc
	push bc
	push de
	ld d, $00
	sla e
	rl d
	ld hl, wLevelRowOffsets
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, c
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop de
	pop bc
	push hl
	ldh a, [rSVBK]
	ld b, a
	ld a, h
	and $10
	swap a
	add a, $02
	ldh [rSVBK], a
	ld a, h
	and $0F
	ld h, a
	xor a
	add a, l
	ld l, a
	ld a, $D0
	adc a, h
	ld h, a
	ld c, [hl]
	ld a, b
	ldh [rSVBK], a
	pop hl
	ld a, c
	pop bc
	and $0C
	jr z, Jump_164B
	inc e
	ld a, [wLevelHeight]
	cp e
	jr nz, Jump_1608
Jump_164B:
	dec e
	ld a, e
	pop de
	ret


Func_164F:
	push af
	push bc
	push de
	push hl
	push bc
	push de
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	ld d, $00
	sla e
	rl d
	ld hl, wLevelRowOffsets
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, c
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop de
	pop bc
	push hl
	ldh a, [rSVBK]
	ld b, a
	ld a, h
	and $10
	swap a
	add a, $02
	ldh [rSVBK], a
	ld a, h
	and $0F
	ld h, a
	xor a
	add a, l
	ld l, a
	ld a, $D0
	adc a, h
	ld h, a
	ld c, [hl]
	ld a, b
	ldh [rSVBK], a
	pop hl
	ld a, c
	and $0C
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_16A8:
	push bc
	push de
	push hl
	push bc
	push de
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	ld d, $00
	sla e
	rl d
	ld hl, wLevelRowOffsets
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, c
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop de
	pop bc
	push hl
	ldh a, [rSVBK]
	ld b, a
	ld a, h
	and $10
	swap a
	add a, $02
	ldh [rSVBK], a
	ld a, h
	and $0F
	ld h, a
	xor a
	add a, l
	ld l, a
	ld a, $D0
	adc a, h
	ld h, a
	ld c, [hl]
	ld a, b
	ldh [rSVBK], a
	pop hl
	ld a, c
	and $08
	pop hl
	pop de
	pop bc
	ret


Func_16FF:
	push bc
	push de
	push hl
	push bc
	push de
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	ld d, $00
	sla e
	rl d
	ld hl, wLevelRowOffsets
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, c
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop de
	pop bc
	push hl
	ldh a, [rSVBK]
	ld b, a
	ld a, h
	and $10
	swap a
	add a, $02
	ldh [rSVBK], a
	ld a, h
	and $0F
	ld h, a
	xor a
	add a, l
	ld l, a
	ld a, $D0
	adc a, h
	ld h, a
	ld c, [hl]
	ld a, b
	ldh [rSVBK], a
	pop hl
	ld a, c
	and $01
	pop hl
	pop de
	pop bc
	ret


Func_1756:
	push bc
	push de
	push hl
	push bc
	push de
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	ld d, $00
	sla e
	rl d
	ld hl, wLevelRowOffsets
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, c
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop de
	pop bc
	push hl
	ldh a, [rSVBK]
	ld b, a
	ld a, h
	and $10
	swap a
	add a, $02
	ldh [rSVBK], a
	ld a, h
	and $0F
	ld h, a
	xor a
	add a, l
	ld l, a
	ld a, $D0
	adc a, h
	ld h, a
	ld c, [hl]
	ld a, b
	ldh [rSVBK], a
	pop hl
	ld a, c
	and $02
	pop hl
	pop de
	pop bc
	ret


Func_17AD:
	push bc
	push de
	push hl
	push bc
	push de
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	ld d, $00
	sla e
	rl d
	ld hl, wLevelRowOffsets
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, c
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop de
	pop bc
	push hl
	ldh a, [rSVBK]
	ld b, a
	ld a, h
	and $10
	swap a
	add a, $02
	ldh [rSVBK], a
	ld a, h
	and $0F
	ld h, a
	xor a
	add a, l
	ld l, a
	ld a, $D0
	adc a, h
	ld h, a
	ld c, [hl]
	ld a, b
	ldh [rSVBK], a
	pop hl
	ld a, c
	and $04
	pop hl
	pop de
	pop bc
	ret


Func_1804:
	push de
	push bc
	push hl
	ld a, [$CA00]
	ld e, a
	ld a, l
	and $C0
	inc a
	ld l, a
	ld a, [hl]
	sub e
	cp $48
	jr nc, Jump_1826
	ld a, l
	and $C0
	add a, $1B
	ld l, a
	ld a, [hl]
	bit 7, a
	jr z, Jump_1826
	dec a
	cpl
	call Func_1BE4
Jump_1826:
	ld a, [$CA00]
	ld e, a
	ld a, l
	and $C0
	inc a
	ld l, a
	ld a, [hl]
	sub e
	ld e, a
	ld a, $58
	cp e
	jp nc, Jump_1846
	ld a, l
	and $C0
	add a, $1B
	ld l, a
	ld a, [hl]
	bit 7, a
	jr nz, Jump_1846
	call Func_1B75
Jump_1846:
	ld a, [$CA02]
	ld e, a
	ld a, l
	and $C0
	add a, $04
	ld l, a
	ld a, [hl]
	sub e
	cp $38
	jr nc, Jump_1866
	ld a, l
	and $C0
	add a, $1C
	ld l, a
	ld a, [hl]
	bit 7, a
	jr z, Jump_1866
	dec a
	cpl
	call Func_1CBC
Jump_1866:
	ld a, [$CA02]
	ld e, a
	ld a, l
	and $C0
	add a, $04
	ld l, a
	ld a, [hl]
	sub e
	ld e, a
	ld a, $48
	cp e
	jp nc, Jump_1887
	ld a, l
	and $C0
	add a, $1C
	ld l, a
	ld a, [hl]
	bit 7, a
	jr nz, Jump_1887
	call Func_1C4D
Jump_1887:
	pop hl
	pop bc
	pop de
	ret


LoadLevelRecord:
	push af
	push bc
	push de
	push hl
	ld a, $05
	ld [rROMB0], a
	ld e, l
	ld a, $00
	add a, e
	ld l, a
	ld a, [hl]
	ld [wLevelWidth], a
	ld c, a
	ld b, $00
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	push af
	ld a, c
	ld [$CA0B], a
	ld a, b
	ld [$CA0C], a
	pop af
	ld a, $01
	add a, e
	ld l, a
	ld a, [hl]
	ld [wLevelHeight], a
	ld c, a
	ld b, $00
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	push af
	ld a, c
	ld [$CA0D], a
	ld a, b
	ld [$CA0E], a
	pop af
	ld a, $02
	add a, e
	ld l, a
	ld bc, wLevelTileBank
	ld d, $12
Jump_18E0:
	ld a, [hli]
	ld [bc], a
	inc bc
	dec d
	jr nz, Jump_18E0
	call BuildLevelRowOffsets
	pop hl
	pop de
	pop bc
	pop af
	ret


LoadLevelData:
	push af
	push bc
	push de
	push hl
	ld [wLevelNumber], a
	ld b, a
	ld a, $05
	ld [rROMB0], a
	ld a, b
	sla a
	ld hl, LevelRecordPointers
	add a, l
	ld l, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call LoadLevelRecord
	ld b, $00
	ld c, $00
	call Func_1B07
	ld b, $00
	ld c, $00
	call Func_1B18
	call LoadLevelTiles
	call LoadLevelCellMap
	ld a, $01
	ld [rROMB0], a
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_1927:
	push af
	push bc
	push de
	push hl
	ld a, [$CD0B]
	ld c, a
	ld a, [$CD0C]
	ld b, a
	ld a, [$CD0D]
	ld e, a
	ld a, [$CD0E]
	ld d, a
	ld a, [$CD00]
	ld l, a
	ld a, [$CD01]
	ld h, a
	call Func_2125
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_194B:
	push af
	push bc
	push de
	push hl
	ld a, l
	and $C0
	inc a
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	ld a, e
	ldh [$FF80], a
	ld a, d
	ldh [$FF81], a
	ldh a, [$FF80]
	sub $0B
	ld e, a
	ldh a, [$FF81]
	sbc a, $00
	ld d, a
	ld a, d
	add a, $80
	cp $80
	jr nz, Jump_197D
	ld a, e
	cp $00
Jump_197D:
	jr nc, Jump_1982
	ld de, $0000
Jump_1982:
	ld a, e
	ldh [$FF80], a
	ld a, d
	ldh [$FF81], a
	ld a, [wLevelWidth]
	sub $15
	ld e, a
	ld a, $00
	sbc a, $00
	ld d, $00
	ldh a, [$FF80]
	ld c, a
	ldh a, [$FF81]
	ld b, a
	ld a, d
	cp b
	jr nz, Jump_19A0
	ld a, e
	cp c
Jump_19A0:
	jr nc, Jump_19A8
	ld a, e
	ldh [$FF80], a
	ld a, d
	ldh [$FF81], a
Jump_19A8:
	ld a, l
	and $C0
	add a, $04
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	ld a, e
	ldh [$FF82], a
	ld a, d
	ldh [$FF83], a
	ldh a, [$FF82]
	sub $0A
	ld e, a
	ldh a, [$FF83]
	sbc a, $00
	ld d, a
	ld a, d
	add a, $80
	cp $80
	jr nz, Jump_19D7
	ld a, e
	cp $00
Jump_19D7:
	jr nc, Jump_19DC
	ld de, $0000
Jump_19DC:
	ld a, e
	ldh [$FF82], a
	ld a, d
	ldh [$FF83], a
	ld a, [wLevelHeight]
	sub $13
	ld e, a
	ld a, $00
	sbc a, $00
	ld d, $00
	ldh a, [$FF82]
	ld c, a
	ldh a, [$FF83]
	ld b, a
	ld a, d
	cp b
	jr nz, Jump_19FA
	ld a, e
	cp c
Jump_19FA:
	jr nc, Jump_1A02
	ld a, e
	ldh [$FF82], a
	ld a, d
	ldh [$FF83], a
Jump_1A02:
	ldh a, [$FF80]
	ld b, a
	ldh a, [$FF82]
	ld c, a
	call Func_1B07
	pop hl
	pop de
	pop bc
	pop af
	ret


BuildLevelRowOffsets:
	push af
	push bc
	push de
	push hl
	ld bc, $0000
	ld hl, wLevelRowOffsets
	ld a, [wLevelHeight]
	ld d, a
Jump_1A1E:
	ld [hl], c
	inc hl
	ld [hl], b
	inc hl
	ld a, [wLevelWidth]
	add a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	dec d
	jr nz, Jump_1A1E
	pop hl
	pop de
	pop bc
	pop af
	ret


LoadLevelTiles:
	ld e, l
	xor a
	ldh [rVBK], a
	ld a, [wLevelTiles]
	ld c, a
	ld a, [wLevelTiles + 1]
	ld b, a
	ld a, [wLevelTileBank]
	ld [rROMB0], a
	ld d, $80
	ld e, $00
	ld a, $88
	call Func_0622
	ld a, $00
	add a, c
	ld c, a
	ld a, $08
	adc a, b
	ld b, a
	ld d, $80
	ld e, $00
	ld a, $90
	call Func_0622
	ld a, $01
	ldh [rVBK], a
	ld a, $00
	add a, c
	ld c, a
	ld a, $08
	adc a, b
	ld b, a
	ld d, $80
	ld e, $00
	ld a, $90
	call Func_0622
	ld a, $00
	add a, c
	ld c, a
	ld a, $08
	adc a, b
	ld b, a
	ld d, $38
	ld e, $00
	ld a, $88
	call Func_0622
	ret


LoadLevelPalettes:
	ldh a, [rLY]
	cp $90
	jr c, LoadLevelPalettes
	ld a, [wLevelPaletteBank]
	ld [rROMB0], a
	ld a, [wLevelPalettes]
	ld l, a
	ld a, [wLevelPalettes + 1]
	ld h, a
	ld b, $00
	ld a, [wLevelPaletteCount]
	ld c, a
	call Func_052F
	ret


LoadLevelCellMap:
	push af
	push bc
	push de
	push hl
	ldh a, [rSVBK]
	push af
	ld a, [wLevelCellMapBank]
	ld [rROMB0], a
	ld a, $02
	ldh [rSVBK], a
	ld bc, $D000
	ld a, [wLevelCellMap]
	ld l, a
	ld a, [wLevelCellMap + 1]
	ld h, a
	ld a, [wLevelHeight]
	ld e, a
Jump_1AC4:
	ld a, [wLevelWidth]
	ld d, a
Jump_1AC8:
	ld a, [hli]
	ld [bc], a
	inc bc
	ld a, $E0
	cp b
	jr nz, Jump_1AD6
	ld b, $D0
	ld a, $03
	ldh [rSVBK], a
Jump_1AD6:
	dec d
	jr nz, Jump_1AC8
	dec e
	jr nz, Jump_1AC4
	pop af
	ldh [rSVBK], a
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_1AE4:
	call Func_3C19
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_1F82
	call Func_1F2F
	call Func_1F12
	call Func_1F4A
	call Func_1F65
	call Func_3C56
	pop af
	ld [rROMB0], a
	ret


Func_1B07:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_4263
	pop af
	ld [rROMB0], a
	ret


Func_1B18:
	push af
	push bc
	ld a, b
	ld [$CA04], a
	srl a
	srl a
	srl a
	ld [$CA14], a
	ld a, c
	ld [$CA05], a
	srl a
	srl a
	srl a
	ld [$CA13], a
	call Func_1B3A
	pop bc
	pop af
	ret


Func_1B3A:
	push af
	push hl
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, l
	ld [$CA15], a
	ld a, h
	ld [$CA16], a
	pop hl
	pop af
	ret


Func_1B4F:
	push af
	push bc
	push de
	push hl
	ld c, a
	ld a, [wLevelWidth]
	ld e, a
	ld d, $00
	ld h, $00
	ld l, $00
	ld a, c
	or a
Jump_1B60:
	jr z, Jump_1B66
	add hl, de
	dec a
	jr Jump_1B60

Jump_1B66:
	push af
	ld a, l
	ld [$CA11], a
	ld a, h
	ld [$CA12], a
	pop af
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_1B75:
	ld e, a
	ld a, [$CA14]
	ld d, a
	ld a, [$CA04]
	add a, e
	srl a
	srl a
	srl a
	cp d
	jr z, Jump_1BCD
	ld a, [wLevelWidth]
	sub $15
	ld b, a
	ld a, [$CA10]
	cp b
	ret z
	ld a, [$CA00]
	add a, e
	ld [$CA00], a
	ld a, [$CA01]
	adc a, $00
	ld [$CA01], a
	ld a, [$CA04]
	add a, e
	ld [$CA04], a
	srl a
	srl a
	srl a
	ld [$CA14], a
	ld a, [$CA00]
	ld c, a
	ld a, [$CA01]
	ld b, a
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	ld a, c
	ld [$CA10], a
	call Func_1F12
	ret

Jump_1BCD:
	ld a, [$CA00]
	add a, e
	ld [$CA00], a
	ld a, [$CA01]
	adc a, $00
	ld [$CA01], a
	ld a, [$CA04]
	add a, e
	ld [$CA04], a
	ret


Func_1BE4:
	ld e, a
	ld a, [$CA14]
	ld d, a
	ld a, [$CA04]
	sub e
	srl a
	srl a
	srl a
	cp d
	jr z, Jump_1C36
	ld a, [$CA10]
	or a
	ret z
	ld a, [$CA00]
	sub e
	ld [$CA00], a
	ld a, [$CA01]
	sbc a, $00
	ld [$CA01], a
	ld a, [$CA04]
	sub e
	ld [$CA04], a
	srl a
	srl a
	srl a
	ld [$CA14], a
	ld a, [$CA00]
	ld c, a
	ld a, [$CA01]
	ld b, a
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	ld a, c
	ld [$CA10], a
	call Func_1F2F
	ret

Jump_1C36:
	ld a, [$CA00]
	sub e
	ld [$CA00], a
	ld a, [$CA01]
	sbc a, $00
	ld [$CA01], a
	ld a, [$CA04]
	sub e
	ld [$CA04], a
	ret


Func_1C4D:
	ld e, a
	ld a, [$CA13]
	ld d, a
	ld a, [$CA05]
	add a, e
	srl a
	srl a
	srl a
	cp d
	jr z, Jump_1CA5
	ld a, [wLevelHeight]
	sub $13
	ld b, a
	ld a, [$CA0F]
	cp b
	ret z
	ld a, [$CA02]
	add a, e
	ld [$CA02], a
	ld a, [$CA03]
	adc a, $00
	ld [$CA03], a
	ld a, [$CA05]
	add a, e
	ld [$CA05], a
	srl a
	srl a
	srl a
	ld [$CA13], a
	ld a, [$CA02]
	ld c, a
	ld a, [$CA03]
	ld b, a
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	ld a, c
	ld [$CA0F], a
	call Func_1F65
	ret

Jump_1CA5:
	ld a, [$CA02]
	add a, e
	ld [$CA02], a
	ld a, [$CA03]
	adc a, $00
	ld [$CA03], a
	ld a, [$CA05]
	add a, e
	ld [$CA05], a
	ret


Func_1CBC:
	ld e, a
	ld a, [$CA13]
	ld d, a
	ld a, [$CA05]
	sub e
	srl a
	srl a
	srl a
	cp d
	jr z, Jump_1D0F
	ld a, [$CA0F]
	or a
	ret z
	ld a, [$CA02]
	sub e
	ld [$CA02], a
	ld a, [$CA03]
	sbc a, $00
	ld [$CA03], a
	ld a, [$CA05]
	sub e
	ld [$CA05], a
	srl a
	srl a
	srl a
	ld [$CA13], a
	ld a, [$CA02]
	ld c, a
	ld a, [$CA03]
	ld b, a
	dec bc
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	ld a, c
	ld [$CA0F], a
	call Func_1F4A
	ret

Jump_1D0F:
	ld a, [$CA02]
	sub e
	ld [$CA02], a
	ld a, [$CA03]
	sbc a, $00
	ld [$CA03], a
	ld a, [$CA05]
	sub e
	ld [$CA05], a
	ret


Func_1D26:
	push af
	push bc
	push de
	push hl
	ld a, c
	ldh [$FFA0], a
	ld a, e
	ldh [$FFA1], a
	ld a, [$CA10]
	ld l, a
	ld a, c
	sub l
	ld c, a
	cp $20
	jp nc, Jump_1D8E
	ld a, [$CA14]
	add a, c
	and $1F
	ld c, a
	ld a, [$CA0F]
	ld l, a
	ld a, e
	sub l
	ld e, a
	cp $20
	jp nc, Jump_1D8E
	ld a, [$CA13]
	add a, e
	and $1F
	ld e, a
	ld d, $00
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	ld a, e
	add a, c
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	ld hl, $9800
	add hl, de
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, [wLevelMapBank]
	ld [rROMB0], a
	ldh a, [$FFA0]
	ld b, a
	ldh a, [$FFA1]
	ld c, a
	call Func_1E84
	pop af
	ld [rROMB0], a
Jump_1D8E:
	pop hl
	pop de
	pop bc
	pop af
	ret


GetLevelCellTileAndAttr:
	push hl
	push bc
	ld d, $00
	ld e, c
	sla e
	rl d
	ld hl, wLevelRowOffsets
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld d, $00
	ld e, b
	add hl, de
	ld a, l
	ldh [$FF80], a
	ld a, h
	ldh [$FF81], a
	push hl
	ldh a, [rSVBK]
	ld b, a
	ld a, h
	and $10
	swap a
	add a, $02
	ldh [rSVBK], a
	ld a, h
	and $0F
	ld h, a
	xor a
	add a, l
	ld l, a
	ld a, $D0
	adc a, h
	ld h, a
	ld c, [hl]
	ld a, b
	ldh [rSVBK], a
	pop hl
	ld a, c
	and $C0
	jp z, Jump_1E5F
	cp $40
	jr z, Jump_1DD8
	cp $80
	jr z, Jump_1DEB
Jump_1DD8:
	ld a, [$C8D3]
	ld d, a
	ld a, [wLevelAnimationFrame]
	inc a
	and $07
	ld [wLevelAnimationFrame], a
	add a, $BB
	ld e, a
	jp Jump_1E81

Jump_1DEB:
	ldh a, [$FF80]
	ld l, a
	ldh a, [$FF81]
	ld h, a
	ld a, [wLevelAttributeMap]
	add a, l
	ld l, a
	ld a, [wLevelAttributeMap + 1]
	adc a, h
	ld h, a
	ld d, [hl]
	ldh a, [$FF80]
	ld l, a
	ldh a, [$FF81]
	ld h, a
	ld a, [wLevelTileMap]
	add a, l
	ld l, a
	ld a, [wLevelTileMap + 1]
	adc a, h
	ld h, a
	ld e, [hl]
	ld a, d
	and $08
	jr nz, Jump_1E81
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $05
	ld [rROMB0], a
	ld a, e
	add a, $7F
	ld c, a
	ld b, $00
	ld l, c
	ld h, b
	inc bc
	ld a, [wLevelAnimationFrame]
	inc a
	and $03
	ld [wLevelAnimationFrame], a
	add a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	add hl, hl
	add hl, hl
	add hl, bc
	ld a, [wLevelTileAnimationTable]
	ld c, a
	ld a, [wLevelTileAnimationTable + 1]
	ld b, a
	add hl, bc
	ld a, [hl]
	add a, $80
	ld e, a
	ld a, [wLevelAttributeLookup + 1]
	ld h, a
	ld a, [wLevelAttributeLookup]
	ld l, a
	ld a, e
	add a, $7F
	ld c, a
	ld b, $00
	add hl, bc
	ld a, [wLevelAttributeLookupBank]
	ld [rROMB0], a
	ld d, [hl]
	pop af
	ld [rROMB0], a
	jr Jump_1E81

Jump_1E5F:
	ldh a, [$FF80]
	ld l, a
	ldh a, [$FF81]
	ld h, a
	ld a, [wLevelAttributeMap]
	add a, l
	ld l, a
	ld a, [wLevelAttributeMap + 1]
	adc a, h
	ld h, a
	ld d, [hl]
	ldh a, [$FF80]
	ld l, a
	ldh a, [$FF81]
	ld h, a
	ld a, [wLevelTileMap]
	add a, l
	ld l, a
	ld a, [wLevelTileMap + 1]
	adc a, h
	ld h, a
	ld e, [hl]
Jump_1E81:
	pop bc
	pop hl
	ret


Func_1E84:
	push af
	push bc
	push de
	push hl
	call GetLevelCellTileAndAttr
	ld b, d
	ld c, e
	ld e, l
	ld d, h
	call Func_3C28
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_1E97:
	push af
	push bc
	push de
	push hl
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, [wLevelMapBank]
	ld [rROMB0], a
	ld e, $15
Jump_1EA7:
	call Func_1E84
	push af
	push de
	ld a, l
	and $E0
	ld e, a
	ld a, l
	inc a
	and $1F
	or e
	ld l, a
	pop de
	pop af
	inc b
	dec e
	jr nz, Jump_1EA7
	pop af
	ld [rROMB0], a
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_1EC5:
	push af
	push bc
	push de
	push hl
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, [wLevelMapBank]
	ld [rROMB0], a
	ld e, $13
Jump_1ED5:
	call Func_1E84
	push af
	ld a, $20
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	and $03
	or $98
	ld h, a
	pop af
	inc c
	dec e
	jr nz, Jump_1ED5
	pop af
	ld [rROMB0], a
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_1EF3:
	push af
	push bc
	ld a, [$CA13]
	add a, c
	and $1F
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, $98
	add a, h
	ld h, a
	ld a, [$CA14]
	add a, b
	and $1F
	or l
	ld l, a
	pop bc
	pop af
	ret


Func_1F12:
	push af
	push bc
	push de
	push hl
	ld b, $14
	ld c, $00
	call Func_1EF3
	ld a, [$CA10]
	add a, $14
	ld b, a
	ld a, [$CA0F]
	ld c, a
	call Func_1EC5
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_1F2F:
	push af
	push bc
	push de
	push hl
	ld b, $00
	ld c, $00
	call Func_1EF3
	ld a, [$CA10]
	ld b, a
	ld a, [$CA0F]
	ld c, a
	call Func_1EC5
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_1F4A:
	push af
	push bc
	push de
	push hl
	ld b, $00
	ld c, $00
	call Func_1EF3
	ld a, [$CA10]
	ld b, a
	ld a, [$CA0F]
	ld c, a
	call Func_1E97
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_1F65:
	push af
	push bc
	push de
	push hl
	ld b, $00
	ld c, $12
	call Func_1EF3
	ld a, [$CA10]
	ld b, a
	ld a, [$CA0F]
	add a, $12
	ld c, a
	call Func_1E97
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_1F82:
	push af
	push bc
	push de
	push hl
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, [wLevelMapBank]
	ld [rROMB0], a
	ld a, $00
	ldh [$FF94], a
	ldh [$FF95], a
	ld a, [$CA10]
	ldh [$FF92], a
	ld a, [$CA0F]
	ldh [$FF93], a
	ld a, $12
	ldh [$FF91], a
Jump_1FA4:
	ldh a, [$FF94]
	ld b, a
	ldh a, [$FF95]
	ld c, a
	inc a
	ldh [$FF95], a
	call Func_1EF3
	ld a, $14
	ldh [$FF90], a
	ldh a, [$FF92]
	ld b, a
	ldh a, [$FF93]
	ld c, a
	inc a
	ldh [$FF93], a
Jump_1FBD:
	call GetLevelCellTileAndAttr
	ld a, $01
	ldh [rVBK], a
Jump_1FC4:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_1FC4
	ld [hl], d
	xor a
	ldh [rVBK], a
	ld [hl], e
	inc b
	push af
	push de
	ld a, l
	and $E0
	ld e, a
	ld a, l
	inc a
	and $1F
	or e
	ld l, a
	pop de
	pop af
	ldh a, [$FF90]
	dec a
	ldh [$FF90], a
	jr nz, Jump_1FBD
	ldh a, [$FF91]
	dec a
	ldh [$FF91], a
	jr nz, Jump_1FA4
	pop af
	ld [rROMB0], a
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_1FF5:
	push bc
	push de
	ld d, $40
	ld c, a
	ld hl, $D000
Jump_1FFD:
	ld a, l
	and $C0
	add a, $1D
	ld l, a
	ld a, [hl]
	cp $00
	jr z, Jump_2018
	ld a, l
	and $C0
	add a, $40
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	dec d
	jr nz, Jump_1FFD
	xor a
	jr Jump_2025

Jump_2018:
	ld a, l
	and $C0
	add a, $1D
	ld l, a
	ld [hl], c
	ld a, l
	and $C0
	ld l, a
	xor a
	inc a
Jump_2025:
	pop de
	pop bc
	ret


Func_2028:
	push de
	push af
	push hl
	ld d, $40
	ld hl, $D000
Jump_2030:
	call Func_2044
	ld a, l
	and $C0
	add a, $40
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	dec d
	jr nz, Jump_2030
	pop hl
	pop af
	pop de
	ret


Func_2044:
	push af
	push hl
	ld a, l
	and $C0
	add a, $1D
	ld l, a
	ld a, [hl]
	cp $02
	call z, Func_2C35
	ld a, $00
	ld [hl], a
	pop hl
	pop af
	ret


Func_2058:
	ld a, $00
	ld [$C6C3], a
	ld a, $C6
	ld [$C6C4], a
	ld a, $9C
	ld [$C6C5], a
	ld a, $C6
	ld [$C6C6], a
	ld a, $28
	ld [$C6C2], a
	xor a
	ld [$C6C7], a
	ld a, $00
	ld [$C6C8], a
	ld a, $C1
	ld [$C6C9], a
	ret


Func_2080:
	push bc
	ld b, a
	ld a, [$C6C2]
	sub b
	jr c, Jump_208C
	ld a, $01
	pop bc
	ret

Jump_208C:
	ld a, $02
	pop bc
	ret


Func_2090:
	ld a, [$C6C2]
	or a
	jr nz, Jump_209A
	ld de, $C6A0
	ret

Jump_209A:
	dec a
	ld [$C6C2], a
	ld a, [$C6C3]
	ld e, a
	add a, $04
	ld [$C6C3], a
	ld a, [$C6C4]
	ld d, a
	adc a, $00
	ld [$C6C4], a
	ret


Func_20B1:
	ld a, [$C6C2]
	or a
	jr nz, Jump_20BB
	ld de, $C6A0
	ret

Jump_20BB:
	dec a
	ld [$C6C2], a
	ld a, [$C6C5]
	ld e, a
	sub $04
	ld [$C6C5], a
	ld a, [$C6C6]
	ld d, a
	sbc a, $00
	ld [$C6C6], a
	ret


Func_20D2:
	ld d, a
	ld a, [$C6C7]
	ld c, a
	add a, d
	cp $31
	jr nc, Jump_20F8
	ld [$C6C7], a
	ld a, d
	add a, a
	add a, a
	add a, a
	add a, a
	ld b, a
	ld a, [$C6C8]
	ld e, a
	add a, b
	ld [$C6C8], a
	ld a, [$C6C9]
	ld d, a
	adc a, $00
	ld [$C6C9], a
	ld a, c
	ret

Jump_20F8:
	xor a
	ld d, a
	ld e, a
	ld a, $FF
	ret


Func_20FE:
	ld a, [$C6C3]
	ld l, a
	ld a, [$C6C4]
	ld h, a
	ld a, [$C6C2]
	or a
	ret z
	ld d, a
	xor a
Jump_210D:
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	dec d
	jr nz, Jump_210D
	ret


Func_2115:
	push hl
	push af
	push af
	ld a, l
	and $C0
	add a, $19
	ld l, a
	pop af
	and $0F
	ld [hl], a
	pop af
	pop hl
	ret


Func_2125:
	push af
	push bc
	push de
	push hl
	ld a, l
	and $C0
	add a, $13
	ld l, a
	xor a
	ld [hli], a
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	xor a
	ld [hli], a
	ld a, e
	ld [hli], a
	ld a, d
	ld [hl], a
	pop hl
	push hl
	call Func_221F
	call Func_21F7
	pop hl
	push hl
	call Func_214D
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_214D:
	push af
	push bc
	push de
	push hl
	ld a, l
	and $C0
	inc a
	ld l, a
	ld a, [$CA00]
	ld c, a
	ld a, [hli]
	sub c
	ld c, a
	ld a, [$CA01]
	ld b, a
	ld a, [hl]
	sbc a, b
	ld b, a
	ld de, $FFF4
	ld a, d
	add a, $80
	ld d, a
	ld a, b
	add a, $80
	cp d
	jr nz, Jump_2173
	ld a, c
	cp e
Jump_2173:
	jr c, Jump_21DF
	ld de, $00AC
	ld a, d
	add a, $80
	ld d, a
	ld a, b
	add a, $80
	cp d
	jr nz, Jump_2184
	ld a, c
	cp e
Jump_2184:
	jr nc, Jump_21DF
	ld a, l
	and $C0
	add a, $06
	ld l, a
	ld a, c
	add a, $08
	ld [hl], a
	ld a, l
	and $C0
	add a, $04
	ld l, a
	ld a, [$CA02]
	ld c, a
	ld a, [hli]
	sub c
	ld c, a
	ld a, [$CA03]
	ld b, a
	ld a, [hl]
	sbc a, b
	ld b, a
	ld de, $FFF4
	ld a, d
	add a, $80
	ld d, a
	ld a, b
	add a, $80
	cp d
	jr nz, Jump_21B3
	ld a, c
	cp e
Jump_21B3:
	jr c, Jump_21DF
	ld de, $009C
	ld a, d
	add a, $80
	ld d, a
	ld a, b
	add a, $80
	cp d
	jr nz, Jump_21C4
	ld a, c
	cp e
Jump_21C4:
	jr nc, Jump_21DF
	ld a, l
	and $C0
	add a, $07
	ld l, a
	ld a, c
	add a, $10
	ld [hl], a
	ld a, l
	and $C0
	add a, $08
	ld l, a
	ld a, [hl]
	or $08
	ld [hl], a
	pop hl
	pop de
	pop bc
	pop af
	ret

Jump_21DF:
	ld a, l
	and $C0
	add a, $08
	ld l, a
	ld a, [hl]
	and $F7
	ld [hl], a
	ld a, l
	and $C0
	add a, $06
	ld l, a
	xor a
	ld [hli], a
	ld [hl], a
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_21F7:
	push hl
	push bc
	ld a, l
	and $C0
	inc a
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	ld a, l
	and $C0
	add a, $09
	ld l, a
	ld [hl], c
	inc l
	ld [hl], b
	ld a, l
	and $C0
	add a, $04
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	ld a, l
	and $C0
	add a, $0B
	ld l, a
	ld [hl], c
	inc l
	ld [hl], b
	pop bc
	pop hl
	ret


Func_221F:
	push de
	push hl
	ld e, l
	ld d, h
	ld a, l
	and $C0
	add a, $13
	ld l, a
	ld a, e
	and $C0
	ld e, a
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
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hl]
	ld [de], a
	pop hl
	pop de
	ret


Func_2241:
	push af
	push bc
	push de
	push hl
	ld e, l
	ld d, h
	ld a, l
	and $C0
	add a, $1A
	ld l, a
	ld a, [hl]
	cp $00
	jr z, Jump_2290
	dec a
	ldh [$FF80], a
	ld a, l
	and $C0
	add a, $19
	ld l, a
	ld a, [hl]
	ldh [$FF81], a
	ld a, $05
	ld [rROMB0], a
	ldh a, [$FF80]
	ld h, a
	ld l, $00
	srl h
	rr l
	ldh a, [$FF81]
	add a, a
	add a, a
	add a, a
	ld c, a
	ld b, $00
	add hl, bc
	ld bc, $4600
	add hl, bc
	ld a, $0D
	add a, e
	ld c, a
	ld b, d
	ld a, [hli]
	ld [bc], a
	inc c
	ld a, [hli]
	ld [bc], a
	inc c
	ld a, [hli]
	ld [bc], a
	inc c
	inc l
	ld a, [hli]
	ld [bc], a
	inc c
	ld a, [hli]
	ld [bc], a
	inc c
	ld a, [hli]
	ld [bc], a
Jump_2290:
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_2295:
	push af
	push bc
	push de
	push hl
	ld e, l
	ld d, h
	ld a, l
	and $C0
	add a, $1A
	ld l, a
	ld a, [hl]
	cp $00
	jr z, Jump_22E8
	dec a
	ldh [$FF80], a
	ld a, l
	and $C0
	add a, $19
	ld l, a
	ld a, [hl]
	add a, $08
	and $0F
	ldh [$FF81], a
	ld a, $05
	ld [rROMB0], a
	ldh a, [$FF80]
	ld h, a
	ld l, $00
	srl h
	rr l
	ldh a, [$FF81]
	add a, a
	add a, a
	add a, a
	ld c, a
	ld b, $00
	add hl, bc
	ld bc, $4600
	add hl, bc
	ld a, $0D
	add a, e
	ld c, a
	ld b, d
	ld a, [hli]
	ld [bc], a
	inc c
	ld a, [hli]
	ld [bc], a
	inc c
	ld a, [hli]
	ld [bc], a
	inc c
	inc l
	ld a, [hli]
	ld [bc], a
	inc c
	ld a, [hli]
	ld [bc], a
	inc c
	ld a, [hli]
	ld [bc], a
Jump_22E8:
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_22ED:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	xor a
	ld [$CA07], a
	ld [$CA08], a
	ld d, $40
	ld hl, $D000
Jump_2302:
	ld e, l
	call Func_214D
	ld a, $08
	add a, e
	ld l, a
	ld a, [hl]
	and $08
	ld b, a
	ld a, $1D
	add a, e
	ld l, a
	ld a, [hl]
	ld l, e
	cp $00
	jr z, Jump_2335
	cp $02
	jr z, Jump_237C
	cp $01
	jr z, Jump_2345
	cp $03
	jp z, Jump_23A9
	cp $04
	jr z, Jump_239D
	jr Jump_2335

Jump_232B:
	ld l, e
	call Func_21F7
	call Func_221F
	call Func_249E
Jump_2335:
	ld a, e
	add a, $40
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	dec d
	jr nz, Jump_2302
	pop af
	ld [rROMB0], a
	ret

Jump_2345:
	xor a
	or b
	jr z, Jump_2353
	call Func_0DB6
	ld a, [$CA08]
	inc a
	ld [$CA08], a
Jump_2353:
	call Func_0BA1
	call Func_104B
	jr z, Jump_2335
	ld a, $26
	add a, e
	ld l, a
	ld a, [hl]
	ld l, e
	or a
	jr z, Jump_236E
	call Func_0043
	ld a, [$CA07]
	inc a
	ld [$CA07], a
Jump_236E:
	call Func_27E8
	call Func_2589
	call Func_2644
	call Func_24D0
	jr Jump_232B

Jump_237C:
	xor a
	or b
	jr z, Jump_2383
	call Func_2D4C
Jump_2383:
	call Func_2C58
	call Func_2CC3
	jr z, Jump_2335
	call Func_267F
	ld a, $1D
	add a, e
	ld l, a
	ld a, [hl]
	cp $02
	jr nz, Jump_232B
	ld l, e
	call Func_28C5
	jr Jump_232B

Jump_239D:
	xor a
	or b
	jr z, Jump_23A4
	call Func_3793
Jump_23A4:
	call Func_3775
	jr Jump_232B

Jump_23A9:
	xor a
	or b
	jr z, Jump_23B0
	call Func_3104
Jump_23B0:
	call Func_31E3
	jp Jump_232B


Func_23B6:
	push bc
	push de
	ld a, c
	sub $0A
	ld c, a
	ld a, b
	sbc a, $00
	ld b, a
	ld a, e
	sub $08
	ld e, a
	ld a, d
	sbc a, $00
	ld d, a
	call Func_16FF
	or a
	jp z, Jump_2438
	ld a, c
	add a, $0A
	ld c, a
	ld a, b
	adc a, $00
	ld b, a
	call Func_16FF
	or a
	jp z, Jump_2438
	ld a, c
	add a, $0A
	ld c, a
	ld a, b
	adc a, $00
	ld b, a
	call Func_16FF
	or a
	jp z, Jump_2438
	ld a, e
	add a, $0A
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	call Func_16FF
	or a
	jp z, Jump_2438
	ld a, e
	add a, $0A
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	call Func_16FF
	or a
	jp z, Jump_2438
	ld a, c
	sub $0A
	ld c, a
	ld a, b
	sbc a, $00
	ld b, a
	call Func_16FF
	or a
	jp z, Jump_2438
	ld a, c
	sub $0A
	ld c, a
	ld a, b
	sbc a, $00
	ld b, a
	call Func_16FF
	or a
	jp z, Jump_2438
	ld a, e
	sub $0A
	ld e, a
	ld a, d
	sbc a, $00
	ld d, a
	call Func_16FF
	or a
	jp z, Jump_2438
Jump_2438:
	pop de
	pop bc
	ret


Func_243B:
	push bc
	push de
	ld a, b
	add a, $80
	cp $80
	jr nz, Jump_2447
	ld a, c
	cp $00
Jump_2447:
	jr nc, Jump_244E
	ld a, $01
	pop de
	pop bc
	ret

Jump_244E:
	ld a, [$CA0C]
	add a, $80
	ld e, a
	ld a, b
	add a, $80
	cp e
	jr nz, Jump_2460
	ld a, [$CA0B]
	ld e, a
	ld a, c
	cp e
Jump_2460:
	jp nc, Jump_2467
	xor a
	pop de
	pop bc
	ret

Jump_2467:
	ld a, $02
	pop de
	pop bc
	ret


Func_246C:
	push bc
	push de
	ld a, d
	add a, $80
	cp $80
	jr nz, Jump_2478
	ld a, e
	cp $00
Jump_2478:
	jp nc, Jump_2480
	ld a, $04
	pop de
	pop bc
	ret

Jump_2480:
	ld a, [$CA0E]
	add a, $80
	ld c, a
	ld a, d
	add a, $80
	cp c
	jr nz, Jump_2492
	ld a, [$CA0D]
	ld c, a
	ld a, e
	cp c
Jump_2492:
	jp nc, Jump_2499
	xor a
	pop de
	pop bc
	ret

Jump_2499:
	ld a, $02
	pop de
	pop bc
	ret


Func_249E:
	push de
	ld e, l
	ld a, l
	and $C0
	add a, $09
	ld l, a
	ld d, [hl]
	ld a, l
	and $C0
	inc a
	ld l, a
	ld a, [hl]
	sub d
	ld d, a
	ld a, l
	and $C0
	add a, $1B
	ld l, a
	ld [hl], d
	ld a, l
	and $C0
	add a, $0B
	ld l, a
	ld d, [hl]
	ld a, l
	and $C0
	add a, $04
	ld l, a
	ld a, [hl]
	sub d
	ld d, a
	ld a, l
	and $C0
	add a, $1C
	ld l, a
	ld [hl], d
	ld l, e
	pop de
	ret


Func_24D0:
	push de
	push bc
	push hl
	ld a, l
	and $C0
	add a, $08
	ld l, a
	ld a, [hl]
	and $08
	jr z, Jump_250C
	ld d, $40
	ld bc, $D000
Jump_24E3:
	ld a, c
	and $C0
	add a, $1D
	ld c, a
	ld a, [bc]
	cp $04
	jr nz, Jump_24FF
	ld a, c
	and $C0
	add a, $08
	ld c, a
	ld a, [bc]
	and $08
	jr z, Jump_24FF
	call Func_2523
	or a
	jr nz, Jump_2510
Jump_24FF:
	ld a, c
	and $C0
	add a, $40
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	dec d
	jr nz, Jump_24E3
Jump_250C:
	pop hl
	pop bc
	pop de
	ret

Jump_2510:
	ld e, l
	ld d, h
	ld l, c
	ld h, b
	ld a, e
	and $C0
	ld e, a
	ld a, l
	and $C0
	ld l, a
	call Func_3764
	pop hl
	pop bc
	pop de
	ret


Func_2523:
	push hl
	push bc
	push de
	ld a, l
	and $C0
	inc a
	ld l, a
	ld a, c
	and $C0
	inc a
	ld c, a
	ld a, [bc]
	ld e, [hl]
	inc c
	inc l
	sub e
	ld e, a
	ld a, [bc]
	ld d, [hl]
	sbc a, d
	ld d, a
	and $80
	jr z, Jump_2548
	ld a, e
	cpl
	add a, $01
	ld e, a
	ld a, d
	cpl
	adc a, $00
	ld d, a
Jump_2548:
	xor a
	cp d
	jr nz, Jump_2584
	ld a, $0C
	cp e
	jr c, Jump_2584
	ld a, l
	and $C0
	add a, $04
	ld l, a
	ld a, c
	and $C0
	add a, $04
	ld c, a
	ld a, [bc]
	ld e, [hl]
	inc c
	inc l
	sub e
	ld e, a
	ld a, [bc]
	ld d, [hl]
	sbc a, d
	ld d, a
	and $80
	jr z, Jump_2575
	ld a, e
	cpl
	add a, $01
	ld e, a
	ld a, d
	cpl
	adc a, $00
	ld d, a
Jump_2575:
	xor a
	cp d
	jr nz, Jump_2584
	ld a, $0C
	cp e
	jr c, Jump_2584
	pop de
	pop bc
	pop hl
	xor a
	inc a
	ret

Jump_2584:
	pop de
	pop bc
	pop hl
	xor a
	ret


Func_2589:
	push hl
	ld a, l
	and $C0
	add a, $1A
	ld l, a
	ld a, [hl]
	or a
	jp z, Jump_2642
	push bc
	push de
	ld a, l
	and $C0
	add a, $08
	ld l, a
	ld a, [hl]
	and $FB
	ld [hl], a
	ld a, l
	and $C0
	add a, $14
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	ld a, l
	and $C0
	add a, $04
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	call Func_243B
	or a
	jr nz, Jump_25D2
	ld a, l
	and $C0
	add a, $08
	ld l, a
	ld a, [hl]
	and $08
	jr z, Jump_25CC
	call Func_23B6
	or a
	jr nz, Jump_25F0
	jr Jump_25D2

Jump_25CC:
	call Func_16FF
	or a
	jr nz, Jump_25F0
Jump_25D2:
	ld a, l
	and $C0
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	inc l
	ld e, [hl]
	ld a, l
	and $C0
	add a, $13
	ld l, a
	ld [hl], c
	inc l
	ld [hl], b
	inc l
	ld [hl], e
	ld a, l
	and $C0
	add a, $08
	ld l, a
	ld a, [hl]
	or $04
	ld [hl], a
Jump_25F0:
	ld a, l
	and $C0
	inc a
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	ld a, l
	and $C0
	add a, $17
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	call Func_246C
	or a
	jr nz, Jump_2620
	ld a, l
	and $C0
	add a, $08
	ld l, a
	ld a, [hl]
	and $08
	jr z, Jump_261A
	call Func_23B6
	or a
	jr nz, Jump_2640
	jr Jump_2620

Jump_261A:
	call Func_16FF
	or a
	jr nz, Jump_2640
Jump_2620:
	ld a, l
	and $C0
	add a, $03
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	inc l
	ld e, [hl]
	ld a, l
	and $C0
	add a, $16
	ld l, a
	ld [hl], c
	inc l
	ld [hl], b
	inc l
	ld [hl], e
	ld a, l
	and $C0
	add a, $08
	ld l, a
	ld a, [hl]
	or $04
	ld [hl], a
Jump_2640:
	pop de
	pop bc
Jump_2642:
	pop hl
	ret


Func_2644:
	push hl
	ld a, l
	and $C0
	add a, $08
	ld l, a
	ld a, [hl]
	and $08
	jr z, Jump_267D
	ld a, l
	and $C0
	add a, $1A
	ld l, a
	ld a, [hl]
	or a
	jr z, Jump_267D
	push de
	push bc
	ld a, l
	and $C0
	inc a
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	ld a, l
	and $C0
	add a, $04
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	call Func_16A8
	or a
	jr z, Jump_267B
	call Func_1219
	ld a, $02
	call Func_3090
Jump_267B:
	pop bc
	pop de
Jump_267D:
	pop hl
	ret


Func_267F:
	push af
	push bc
	push de
	push hl
	ld a, l
	and $C0
	add a, $08
	ld l, a
	ld a, [hl]
	and $08
	jp z, Jump_27AE
	ld a, l
	and $C0
	add a, $20
	ld l, a
	ld a, [hl]
	cp $02
	jp z, Jump_27E3
	cp $00
	jp z, Jump_277C
	cp $01
	jp z, Jump_26A8
	jp Jump_277C

Jump_26A8:
	xor a
	ldh [$FF80], a
	ld a, l
	and $C0
	add a, $14
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	ld a, l
	and $C0
	add a, $04
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	call Func_1756
	jr z, Jump_26F6
	call Func_17AD
	jp nz, Jump_27BA
	ld a, l
	and $C0
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	inc l
	ld e, [hl]
	ld a, l
	and $C0
	add a, $13
	ld l, a
	ld [hl], c
	inc l
	ld [hl], b
	inc l
	ld [hl], e
	ld a, l
	and $C0
	add a, $19
	ld l, a
	ld b, [hl]
	ld a, $10
	sub b
	and $0F
	ld [hl], a
	ld a, l
	and $C0
	add a, $23
	ld l, a
	ld [hl], a
	inc a
	ld a, [hl]
	ld a, $01
	ldh [$FF80], a
Jump_26F6:
	ld a, l
	and $C0
	inc a
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	ld a, l
	and $C0
	add a, $17
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	call Func_1756
	jr z, Jump_2744
	call Func_17AD
	jp nz, Jump_27BA
	ld a, l
	and $C0
	add a, $03
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	inc l
	ld e, [hl]
	ld a, l
	and $C0
	add a, $16
	ld l, a
	ld [hl], c
	inc l
	ld [hl], b
	inc l
	ld [hl], e
	ld a, l
	and $C0
	add a, $19
	ld l, a
	ld b, [hl]
	ld a, $0F
	sub b
	add a, $09
	and $0F
	ld [hl], a
	ld a, l
	and $C0
	add a, $23
	ld l, a
	ld a, [hl]
	inc a
	ld [hl], a
	ld a, $01
	ldh [$FF80], a
Jump_2744:
	ldh a, [$FF80]
	or a
	jr z, Jump_2777
	ld a, l
	and $C0
	inc a
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	ld a, l
	and $C0
	add a, $04
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	ld a, $01
	call Func_3090
	ld e, $1E
	call Audio_QueueSound
	ld a, l
	and $C0
	add a, $21
	ld l, a
	ld a, [hl]
	cp $B3
	jr c, Jump_2777
	ld a, l
	and $C0
	ld l, a
	call Func_2044
	xor a
Jump_2777:
	pop hl
	pop de
	pop bc
	pop af
	ret

Jump_277C:
	ld a, l
	and $C0
	add a, $14
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	ld a, l
	and $C0
	add a, $04
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	call Func_1756
	jr nz, Jump_27BA
	ld a, l
	and $C0
	inc a
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	ld a, l
	and $C0
	add a, $17
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	call Func_1756
	jr nz, Jump_27BA
	pop hl
	pop de
	pop bc
	pop af
	ret

Jump_27AE:
	ld a, l
	and $C0
	ld l, a
	call Func_2044
	pop hl
	pop de
	pop bc
	pop af
	ret

Jump_27BA:
	ld a, l
	and $C0
	ld l, a
	call Func_10E6
	ld a, l
	and $C0
	inc a
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	ld a, l
	and $C0
	add a, $04
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	ld a, l
	and $C0
	ld l, a
	call Func_2044
	ld a, $01
	call Func_3090
	pop hl
	pop de
	pop bc
	pop af
	ret

Jump_27E3:
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_27E8:
	push af
	push bc
	push de
	push hl
	ld a, l
	and $C0
	add a, $1A
	ld l, a
	ld a, [hl]
	or a
	jp z, Jump_2856
	ld a, l
	and $C0
	ld l, a
	ld e, $40
	ld bc, $D000
Jump_2800:
	ld a, c
	and $C0
	add a, $1D
	ld c, a
	ld a, [bc]
	cp $01
	jr nz, Jump_2848
	ld a, c
	and $C0
	ld c, a
	ld a, l
	cp c
	jr nz, Jump_2817
	ld a, h
	cp b
	jr z, Jump_2848
Jump_2817:
	call Func_285B
	jr z, Jump_2848
	ld a, l
	and $C0
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	inc l
	ld e, [hl]
	ld a, l
	and $C0
	add a, $13
	ld l, a
	ld [hl], c
	inc l
	ld [hl], b
	inc l
	ld [hl], e
	ld a, l
	and $C0
	add a, $03
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	inc l
	ld e, [hl]
	ld a, l
	and $C0
	add a, $16
	ld l, a
	ld [hl], c
	inc l
	ld [hl], b
	inc l
	ld [hl], e
	jr Jump_2856

Jump_2848:
	ld a, c
	and $C0
	add a, $40
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	dec e
	jp nz, Jump_2800
Jump_2856:
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_285B:
	push de
	push bc
	push hl
	ld a, l
	and $C0
	add a, $14
	ld l, a
	ld a, c
	and $C0
	add a, $14
	ld c, a
	ld a, [bc]
	ld e, [hl]
	inc c
	inc l
	sub e
	ld e, a
	ld a, [bc]
	ld d, [hl]
	sbc a, d
	ld d, a
	and $80
	jr z, Jump_2882
	ld a, e
	cpl
	add a, $01
	ld e, a
	ld a, d
	cpl
	adc a, $00
	ld d, a
Jump_2882:
	ld a, $00
	cp d
	jr nz, Jump_28C0
	ld a, $14
	cp e
	jr c, Jump_28C0
	ld a, l
	and $C0
	add a, $17
	ld l, a
	ld a, c
	and $C0
	add a, $17
	ld c, a
	ld a, [bc]
	ld e, [hl]
	inc c
	inc l
	sub e
	ld e, a
	ld a, [bc]
	ld d, [hl]
	sbc a, d
	ld d, a
	and $80
	jr z, Jump_28B0
	ld a, e
	cpl
	add a, $01
	ld e, a
	ld a, d
	cpl
	adc a, $00
	ld d, a
Jump_28B0:
	ld a, $00
	cp d
	jr nz, Jump_28C0
	ld a, $14
	cp e
	jr c, Jump_28C0
	pop hl
	pop bc
	pop de
	xor a
	inc a
	ret

Jump_28C0:
	pop hl
	pop bc
	pop de
	xor a
	ret


Func_28C5:
	push af
	push bc
	push de
	push hl
	ld a, l
	and $C0
	add a, $1E
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	ld a, l
	and $C0
	add a, $23
	ld l, a
	ld a, [hl]
	ldh [$FFA1], a
	ld a, l
	and $C0
	ld l, a
	ld a, $40
	ldh [$FFA0], a
	ld bc, $D000
Jump_28E6:
	ld a, c
	and $C0
	add a, $1D
	ld c, a
	ld a, [bc]
	cp $01
	jr nz, Jump_2911
	ld a, c
	and $C0
	add a, $08
	ld c, a
	ld a, [bc]
	and $08
	jr z, Jump_2911
	ldh a, [$FFA1]
	or a
	jr nz, Jump_290B
	ld a, c
	and $C0
	cp e
	jr nz, Jump_290B
	ld a, b
	cp d
	jr z, Jump_2911
Jump_290B:
	call Func_2977
	or a
	jr nz, Jump_2927
Jump_2911:
	ld a, c
	and $C0
	add a, $40
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	ldh a, [$FFA0]
	dec a
	ldh [$FFA0], a
	jr nz, Jump_28E6
	pop hl
	pop de
	pop bc
	pop af
	ret

Jump_2927:
	ld a, c
	and $C0
	add a, $2B
	ld c, a
	ld a, e
	ld [bc], a
	inc c
	ld a, d
	ld [bc], a
	ld a, l
	and $C0
	add a, $22
	ld l, a
	ld d, [hl]
	ld a, l
	and $C0
	ld l, a
	push hl
	ld a, c
	and $C0
	ld c, a
	ld l, c
	ld h, b
	ld b, d
	ldh a, [$FFA1]
	or a
	jr z, Jump_294C
	sla b
Jump_294C:
	call Func_2FBB
	pop hl
	ld a, l
	and $C0
	inc a
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	ld a, l
	and $C0
	add a, $04
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	ld a, l
	and $C0
	ld l, a
	call Func_2044
	ld a, $01
	call Func_3090
	ld e, $14
	call Audio_QueueSound
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_2977:
	push hl
	push bc
	push de
	ld a, l
	and $C0
	add a, $06
	ld l, a
	ld a, c
	and $C0
	add a, $06
	ld c, a
	ld a, [bc]
	ld d, [hl]
	cp d
	jr nc, Jump_298E
	ld e, a
	ld a, d
	ld d, e
Jump_298E:
	sub d
	cp $0C
	jr nc, Jump_29B3
	ld a, l
	and $C0
	add a, $07
	ld l, a
	ld a, c
	and $C0
	add a, $07
	ld c, a
	ld a, [bc]
	ld d, [hl]
	cp d
	jr nc, Jump_29A7
	ld e, a
	ld a, d
	ld d, e
Jump_29A7:
	sub d
	cp $0C
	jr nc, Jump_29B3
	pop de
	pop bc
	pop hl
	ld a, $01
	or a
	ret

Jump_29B3:
	pop de
	pop bc
	pop hl
	xor a
	ret


Func_29B8:
	push de
	push hl
	ld a, l
	and $C0
	inc a
	ld l, a
	ld a, e
	and $C0
	inc a
	ld e, a
	ld a, [de]
	sub [hl]
	inc e
	inc l
	ld c, a
	ld a, [de]
	sbc a, [hl]
	ld b, a
	and $80
	jr z, Jump_29DA
	ld a, c
	cpl
	add a, $01
	ld c, a
	ld a, b
	cpl
	adc a, $00
	ld b, a
Jump_29DA:
	push bc
	ld a, l
	and $C0
	add a, $04
	ld l, a
	ld a, e
	and $C0
	add a, $04
	ld e, a
	ld a, [de]
	ld c, [hl]
	inc e
	inc l
	sub c
	ld c, a
	ld a, [de]
	ld b, [hl]
	sbc a, b
	ld b, a
	and $80
	jr z, Jump_29FF
	ld a, c
	cpl
	add a, $01
	ld c, a
	ld a, b
	cpl
	adc a, $00
	ld b, a
Jump_29FF:
	pop de
	ld a, e
	add a, c
	ld c, a
	ld a, d
	adc a, b
	ld b, a
	srl b
	rr c
	pop hl
	pop de
	ret

	db $0E, $00, $08, $06, $0C, $02, $0A, $04

Func_2A15:
	push de
	push bc
	push hl
	xor a
	ldh [$FF90], a
	ld a, l
	and $C0
	inc a
	ld l, a
	ld a, e
	and $C0
	inc a
	ld e, a
	ld a, [de]
	ld c, [hl]
	inc e
	inc l
	sub c
	ld c, a
	ld a, [de]
	ld b, [hl]
	sbc a, b
	ld b, a
	and $80
	jr z, Jump_2A43
	ldh a, [$FF90]
	or $01
	ldh [$FF90], a
	ld a, c
	cpl
	add a, $01
	ld c, a
	ld a, b
	cpl
	adc a, $00
	ld b, a
Jump_2A43:
	push bc
	ld a, l
	and $C0
	add a, $04
	ld l, a
	ld a, e
	and $C0
	add a, $04
	ld e, a
	ld a, [de]
	ld c, [hl]
	inc e
	inc l
	sub c
	ld c, a
	ld a, [de]
	ld b, [hl]
	sbc a, b
	ld b, a
	and $80
	jr z, Jump_2A6E
	ldh a, [$FF90]
	or $02
	ldh [$FF90], a
	ld a, c
	cpl
	add a, $01
	ld c, a
	ld a, b
	cpl
	adc a, $00
	ld b, a
Jump_2A6E:
	pop de
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc a, d
	ld b, a
	ldh a, [$FF90]
	jr nc, Jump_2A7B
	or $04
Jump_2A7B:
	add a, $0D
	ld l, a
	ld a, $2A
	adc a, $00
	ld h, a
	ld a, [hl]
	pop hl
	pop bc
	pop de
	ret


Func_2A88:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_4D58
	pop af
	ld [rROMB0], a
	ret


Func_2A99:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $08
	ld [rROMB0], a
	xor a
	ldh [rVBK], a
	ld e, $00
	ld d, $25
	ld a, $80
	ld bc, $6B85
	call Func_0622
	call Func_2AB9
	pop af
	ld [rROMB0], a
	ret


Func_2AB9:
	push af
	ld a, $00
	ld [$C8DF], a
	ld [$C8E0], a
	pop af
	ret


Func_2AC4:
	push af
	ld a, [$C8DF]
	inc a
	ld [$C8DF], a
	pop af
	ret


Func_2ACE:
	push hl
	push af
Jump_2AD0:
	ld a, [hli]
	or a
	jr z, Jump_2AF4
	cp $0D
	jr nz, Jump_2ADD
	call Func_2B67
	jr Jump_2AD0

Jump_2ADD:
	cp $0C
	jr nz, Jump_2AE6
	call Func_2AB9
	jr Jump_2AD0

Jump_2AE6:
	cp $01
	jr nz, Jump_2AEF
	call Func_2AC4
	jr Jump_2AD0

Jump_2AEF:
	call Func_2AF7
	jr Jump_2AD0

Jump_2AF4:
	pop af
	pop hl
	ret


Func_2AF7:
	push af
	push bc
	push de
	push hl
	ld c, a
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $08
	ld [rROMB0], a
	ld b, $00
	ld hl, $6B05
	add hl, bc
	ld c, [hl]
	ld a, [$C8E0]
	ld e, a
	ld d, $00
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	ld a, [$C8DF]
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	ld hl, $9800
	add hl, de
	ld a, $01
	ldh [rVBK], a
Jump_2B37:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_2B37
	ld [hl], $0F
	xor a
	ldh [rVBK], a
Jump_2B42:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_2B42
	ld a, c
	add a, $80
	ld [hl], a
	call Func_2AC4
	pop af
	ld [rROMB0], a
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_2B58:
	push af
	ld a, b
	and $1F
	ld [$C8DF], a
	ld a, c
	and $1F
	ld [$C8E0], a
	pop af
	ret


Func_2B67:
	push af
	xor a
	ld [$C8DF], a
	ld a, [$C8E0]
	inc a
	ld [$C8E0], a
	pop af
	ret


Func_2B75:
	push af
	ld a, [$C8E0]
	inc a
	ld [$C8E0], a
	pop af
	ret


Func_2B7F:
	push af
	xor a
	ld [$C8DF], a
	pop af
	ret


Func_2B86:
	push de
	push hl
	push bc
	push hl
	call Func_2C24
	ld a, $02
	call Func_1FF5
	jp z, Jump_2C1F
	call Func_2125
	ld c, l
	ld b, h
	pop hl
	ld a, c
	and $C0
	add a, $19
	ld c, a
	ld a, l
	and $C0
	add a, $19
	ld l, a
	ld a, [hl]
	ld [bc], a
	ld a, l
	and $C0
	ld l, a
	ld a, c
	and $C0
	add a, $1E
	ld c, a
	ld a, l
	ld [bc], a
	inc c
	ld a, h
	ld [bc], a
	ld a, c
	and $C0
	add a, $20
	ld c, a
	pop de
	ld a, d
	ld [bc], a
	ld a, c
	and $C0
	ld c, a
	ld a, $02
	cp d
	call z, Func_2E67
	ld a, d
	sla a
	sla a
	sla a
	ld de, ObjectTypeParameterTable
	add a, e
	ld e, a
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $05
	ld [rROMB0], a
	ld a, c
	and $C0
	add a, $22
	ld c, a
	ld a, [de]
	ld [bc], a
	inc e
	ld a, c
	and $C0
	add a, $1A
	ld c, a
	ld a, [de]
	ld [bc], a
	inc e
	ld a, c
	and $C0
	add a, $21
	ld c, a
	ld a, [de]
	ld [bc], a
	ld a, c
	and $C0
	add a, $23
	ld c, a
	xor a
	ld [bc], a
	ld a, c
	and $C0
	add a, $24
	ld c, a
	xor a
	ld [bc], a
	ld a, c
	and $C0
	add a, $29
	ld c, a
	xor a
	ld [bc], a
	pop af
	ld [rROMB0], a
	ld a, c
	and $C0
	ld c, a
	xor a
	inc a
	pop hl
	pop de
	ret

Jump_2C1F:
	xor a
	pop bc
	pop hl
	pop de
	ret


Func_2C24:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_43EC
	pop af
	ld [rROMB0], a
	ret


Func_2C35:
	push hl
	ld a, l
	and $C0
	add a, $1E
	ld l, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	and $C0
	add a, $1D
	ld l, a
	ld a, [hl]
	cp $01
	jr nz, Jump_2C56
	ld a, l
	and $C0
	add a, $22
	ld l, a
	ld a, [hl]
	or a
	jr z, Jump_2C56
	dec a
	ld [hl], a
Jump_2C56:
	pop hl
	ret


Func_2C58:
	push de
	push bc
	push hl
	ld e, l
	ld a, l
	and $C0
	add a, $29
	ld l, a
	ld a, [hl]
	and a
	ld l, e
	call z, Func_2241
	ld a, l
	and $C0
	add a, $1A
	ld l, a
	ld a, [hl]
	or a
	jp z, Jump_2CBB
	ld a, l
	and $C0
	add a, $0D
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	inc l
	ld e, [hl]
	ld a, l
	and $C0
	ld l, a
	ld a, [hli]
	add a, c
	ld c, a
	ld a, [hli]
	adc a, b
	ld b, a
	ld a, [hl]
	adc a, e
	ld e, a
	ld a, l
	and $C0
	add a, $13
	ld l, a
	ld [hl], c
	inc l
	ld [hl], b
	inc l
	ld [hl], e
	ld a, l
	and $C0
	add a, $10
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	inc l
	ld e, [hl]
	ld a, l
	and $C0
	add a, $03
	ld l, a
	ld a, [hli]
	add a, c
	ld c, a
	ld a, [hli]
	adc a, b
	ld b, a
	ld a, [hl]
	adc a, e
	ld e, a
	ld a, l
	and $C0
	add a, $16
	ld l, a
	ld [hl], c
	inc l
	ld [hl], b
	inc l
	ld [hl], e
Jump_2CBB:
	ld a, l
	and $C0
	ld l, a
	pop hl
	pop bc
	pop de
	ret


Func_2CC3:
	push hl
	ld a, l
	and $C0
	add a, $21
	ld l, a
	ld a, [hl]
	dec a
	ld [hl], a
	or a
	jr nz, Jump_2CDA
	ld a, l
	and $C0
	ld l, a
	call Func_2044
	xor a
	pop hl
	ret

Jump_2CDA:
	ld a, l
	and $C0
	add a, $1A
	ld l, a
	ld a, [hl]
	ld a, l
	and $C0
	add a, $20
	ld l, a
	ld a, [hl]
	cp $02
	call z, Func_2CF1
	xor a
	inc a
	pop hl
	ret


Func_2CF1:
	push af
	push bc
	push de
	push hl
	ld a, l
	and $C0
	add a, $25
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	ld a, e
	or d
	jr z, Jump_2D47
	ld a, e
	and $C0
	add a, $1D
	ld e, a
	ld a, [de]
	cp $00
	jr z, Jump_2D47
	ld a, l
	and $C0
	add a, $27
	ld l, a
	ld a, [hl]
	or a
	jr z, Jump_2D22
	dec a
	ld [hl], a
	jr Jump_2D47

	db $FA, $B9, $C6, $E6, $03, $20, $25
Jump_2D22:
	ld a, l
	and $C0
	ld l, a
	ld a, e
	and $C0
	ld e, a
	call Func_2A15
	ld c, a
	ld a, l
	and $C0
	add a, $19
	ld l, a
	ld b, [hl]
	ld e, b
	call Func_2EA7
	ld a, c
	and $80
	jr z, Jump_2D42
	ld a, e
	inc a
	jr Jump_2D44

Jump_2D42:
	ld a, e
	dec a
Jump_2D44:
	and $0F
	ld [hl], a
Jump_2D47:
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_2D4C:
	push de
	push bc
	push hl
	ld a, l
	and $C0
	add a, $20
	ld l, a
	ld a, [hl]
	cp $01
	jr z, Jump_2D7C
	cp $02
	jr z, Jump_2DA6
	call Func_2090
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
	ld a, $40
	ld [de], a
	inc e
	ld a, $0B
	ld [de], a
	pop hl
	pop bc
	pop de
	ret

Jump_2D7C:
	call Func_2090
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
	ld b, $00
	ld a, [$C6B7]
	bit 4, a
	jr z, Jump_2D9A
	ld b, $01
Jump_2D9A:
	ld a, b
	add a, $41
	ld [de], a
	inc e
	ld a, $0B
	ld [de], a
	pop hl
	pop bc
	pop de
	ret

Jump_2DA6:
	call Func_2090
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
	add a, $19
	ld l, a
	ld a, [hl]
	add a, $43
	ld [de], a
	inc e
	ld a, $0B
	ld [de], a
	pop hl
	pop bc
	pop de
	ret


Func_2DCB:
	push de
	push bc
	push hl
	ld a, $FF
	ldh [$FF82], a
	ldh [$FF83], a
	xor a
	ldh [$FF80], a
	ldh [$FF81], a
	ldh [$FF86], a
	ld e, l
	ld d, h
	ld a, l
	and $C0
	add a, $19
	ld l, a
	ld a, [hl]
	ldh [$FF89], a
	ld a, $40
	ldh [$FF85], a
	ld hl, $D000
Jump_2DED:
	ld a, e
	cp l
	jr nz, Jump_2DF5
	ld a, d
	cp h
	jr z, Jump_2E46
Jump_2DF5:
	ld a, l
	and $C0
	add a, $1D
	ld l, a
	ld a, [hl]
	cp $01
	jr nz, Jump_2E46
	ld a, l
	and $C0
	add a, $08
	ld l, a
	ld a, [hl]
	and $08
	jr z, Jump_2E46
	call Func_29B8
	ldh a, [$FF83]
	cp b
	jr c, Jump_2E46
	ldh a, [$FF82]
	cp c
	jr c, Jump_2E46
	ld a, c
	ldh [$FF87], a
	ld a, b
	ldh [$FF88], a
	call Func_2A15
	ld b, a
	ldh a, [$FF89]
	ld c, a
	call Func_2EA7
	ld a, $03
	cp b
	jr c, Jump_2E46
	ld a, b
	ldh [$FF84], a
	ld a, l
	and $C0
	ld l, a
	ld a, l
	ldh [$FF80], a
	ld a, h
	ldh [$FF81], a
	ldh a, [$FF87]
	ldh [$FF82], a
	ldh a, [$FF88]
	ldh [$FF83], a
	ld a, $01
	ldh [$FF86], a
Jump_2E46:
	ld a, l
	and $C0
	add a, $40
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ldh a, [$FF85]
	dec a
	ldh [$FF85], a
	jr nz, Jump_2DED
	ldh a, [$FF86]
	or a
	jr nz, Jump_2E61
	xor a
	pop hl
	pop bc
	pop de
	ret

Jump_2E61:
	xor a
	inc a
	pop hl
	pop bc
	pop de
	ret


Func_2E67:
	push af
	push bc
	push de
	push hl
	ld a, c
	and $C0
	add a, $27
	ld c, a
	ld a, $14
	ld [bc], a
	ld a, c
	and $C0
	ld c, a
	ld a, l
	ldh [$FF8A], a
	ld a, h
	ldh [$FF8B], a
	ld a, c
	ldh [$FF8C], a
	ld a, b
	ldh [$FF8D], a
	call Func_2DCB
	jr z, Jump_2E98
	ld a, c
	and $C0
	add a, $25
	ld c, a
	ldh a, [$FF80]
	ld [bc], a
	inc c
	ldh a, [$FF81]
	ld [bc], a
	jr Jump_2EA2

Jump_2E98:
	ld a, c
	and $C0
	add a, $25
	ld c, a
	xor a
	ld [bc], a
	inc c
	ld [bc], a
Jump_2EA2:
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_2EA7:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_4548
	pop af
	ld [rROMB0], a
	ret


Audio_InitFar:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $06
	ld [rROMB0], a
	call Audio_Init
	ld a, [$C8E6]
	cp $00
	jr nz, Jump_2ED0
	ld a, $01
	ld [$C8E6], a
Jump_2ED0:
	pop af
	ld [rROMB0], a
	ret


Music_Update:
	ld a, [wMusicPtr]
	cp $00
	ret z
	ld a, [wMusicEnabled]
	and a
	ret z
	ld a, [wMusicDelay]
	cp $01
	jr z, Jump_2EEC
	dec a
	ld [wMusicDelay], a
	ret

Jump_2EEC:
	ld hl, wMusicPtr
	ld a, [hli]
	ld b, a
	ld a, [hl]
	ld h, b
	ld l, a
Jump_2EF4:
	ld a, [wMusicBank]
	ld [rROMB0], a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld [wMusicDelay], a
	ld a, $06
	ld [rROMB0], a
	push hl
	call Music_HandleEvent
	pop hl
	ld a, [wMusicPtr]
	and a
	ret z
	ld a, h
	ld [wMusicPtr], a
	ld a, l
	ld [wMusicPtr + 1], a
	ld a, [wMusicDelay]
	cp $00
	jr z, Jump_2EF4
	ret


Audio_Update:
	push af
	push bc
	push de
	push hl
	ld a, [wNoiseLockTimer]
	and a
	jr z, Jump_2F2F
	dec a
	ld [wNoiseLockTimer], a
Jump_2F2F:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $06
	ld [rROMB0], a
	call SfxSequence_Update
	call Music_Update
	ld hl, wSoundQueue
	ld a, [wSoundQueueNext]
	ld d, $00
	ld e, a
	add hl, de
Jump_2F48:
	ld a, [hl]
	and a
	jr z, Jump_2F6A
	push hl
	call Audio_PlaySound
	pop hl
	xor a
	ld [hli], a
	ld a, [wSoundQueueNext]
	ld [wSoundQueueLast], a
	inc a
	ld [wSoundQueueNext], a
	cp SOUND_QUEUE_SIZE
	jr nz, Jump_2F48
	ld hl, wSoundQueue
	xor a
	ld [wSoundQueueNext], a
	jr Jump_2F48

Jump_2F6A:
	pop af
	ld [rROMB0], a
	pop hl
	pop de
	pop bc
	pop af
	ret


Audio_QueueSound:
	push af
	push bc
	push de
	push hl
	ld a, e
	and a
	ret z
	ld a, [wSoundQueueLast]
	inc a
	cp SOUND_QUEUE_SIZE
	jr nz, Jump_2F83
	xor a
Jump_2F83:
	ld [wSoundQueueLast], a
	ld b, $00
	ld c, a
	ld hl, wSoundQueue
	add hl, bc
	ld [hl], e
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_2F93:
	push bc
	push hl
	call Func_0C41
	ld b, a
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld [hl], b
	pop hl
	pop bc
	ret


Func_2FA3:
	push bc
	push hl
	call Func_0C41
	ld c, a
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld a, b
	and $3F
	add a, [hl]
	cp c
	jr c, Jump_2FB7
	ld a, c
Jump_2FB7:
	ld [hl], a
	pop hl
	pop bc
	ret


Func_2FBB:
	push hl
	ld a, b
	and $3F
	ld b, a
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld a, [hl]
	sub b
	jr nc, Jump_2FCB
	xor a
Jump_2FCB:
	ld [hl], a
	pop hl
	ret


Func_2FCE:
	ld a, [$CD03]
	or a
	ret z
	ld b, a
	ld a, [$C6B7]
	and $01
	ret z
	ld a, b
	dec a
	ld [$CD03], a
	ld a, [$CD00]
	ld l, a
	ld a, [$CD01]
	ld h, a
	ld b, $01
	call Func_2FA3
	ret


Func_2FED:
	ld a, [$CD02]
	cp $09
	jr z, Jump_2FF8
	inc a
	ld [$CD02], a
Jump_2FF8:
	ret


Func_2FF9:
	ld a, [$CD02]
	or a
	jr z, Jump_3003
	dec a
	ld [$CD02], a
Jump_3003:
	ret


Func_3004:
	ld a, $03
	ld [$CD02], a
	ret


Func_300A:
	push hl
	xor a
	ld [$C6D0], a
	ld hl, $CD04
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	pop hl
	ret


AddToScore:
	push hl
	ld hl, $CD04
	ld a, [hl]
	add a, c
	ld [hli], a
	ld a, [hl]
	adc a, b
	ld [hli], a
	ld a, [hl]
	adc a, $00
	ld [hli], a
	ld a, [hl]
	adc a, $00
	ld [hli], a
	pop hl
	ret


Func_302D:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
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
	jr c, Jump_307A
	jr nz, Jump_306E
	ld a, [hld]
	ld b, a
	ld a, [$CD06]
	cp b
	jr c, Jump_307A
	jr nz, Jump_306E
	ld a, [hld]
	ld b, a
	ld a, [$CD05]
	cp b
	jr c, Jump_307A
	jr nz, Jump_306E
	ld a, [hld]
	ld b, a
	ld a, [$CD04]
	cp b
	jr c, Jump_307A
Jump_306E:
	call Func_2FED
	ld e, $52
	call Audio_QueueSound
	ld a, c
	ld [$C6D0], a
Jump_307A:
	pop af
	ld [rROMB0], a
	ret


Func_307F:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_45C1
	pop af
	ld [rROMB0], a
	ret


Func_3090:
	push hl
	push bc
	push de
	push af
	ld a, $03
	call Func_1FF5
	call Func_2125
	xor a
	call Func_2115
	ld a, l
	and $C0
	add a, $1E
	ld l, a
	pop af
	ld d, a
	ld [hl], a
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld [hl], $00
	ld a, d
	cp $00
	jr z, Jump_30CA
	cp $02
	jr z, Jump_30C5
	cp $01
	jr z, Jump_30C0
	jr Jump_30CD

Jump_30C0:
	call Func_30D1
	jr Jump_30CD

Jump_30C5:
	call Func_30F3
	jr Jump_30CD

Jump_30CA:
	call Func_30E2
Jump_30CD:
	pop de
	pop bc
	pop hl
	ret


Func_30D1:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_4611
	pop af
	ld [rROMB0], a
	ret


Func_30E2:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_463D
	pop af
	ld [rROMB0], a
	ret


Func_30F3:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_4688
	pop af
	ld [rROMB0], a
	ret


Func_3104:
	push de
	push bc
	push hl
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $05
	ld [rROMB0], a
	ld e, l
	ld a, $06
	add a, e
	ld l, a
	ld a, [hli]
	ldh [$FF81], a
	ld a, [hl]
	ldh [$FF82], a
	ld a, $1F
	add a, e
	ld l, a
	ld a, [hl]
	srl a
	srl a
	ldh [$FF85], a
	ld a, $1E
	add a, e
	ld l, a
	ld a, [hl]
	ldh [$FF80], a
	ld a, $21
	add a, e
	ld l, a
	ld a, [hli]
	ldh [$FF86], a
	ld a, [hl]
	ldh [$FF87], a
	ld a, $23
	add a, e
	ld l, a
	ld a, [hli]
	ldh [$FF88], a
	ld a, [hl]
	ldh [$FF89], a
	ld a, $25
	add a, e
	ld l, a
	ld a, [hl]
	ldh [$FF8A], a
	call Func_20D2
	cp $FF
	jr z, Jump_3157
	ldh [$FF84], a
	call Func_3190
	call Func_315F
Jump_3157:
	pop af
	ld [rROMB0], a
	pop hl
	pop bc
	pop de
	ret


Func_315F:
	ld a, $02
	ld [rROMB0], a
	ldh a, [$FF88]
	ld l, a
	ldh a, [$FF89]
	ld h, a
	ldh a, [$FF8A]
	ld c, a
Jump_316D:
	call Func_2090
	ldh a, [$FF82]
	ld b, a
	ld a, [hli]
	add a, b
	ld [de], a
	inc e
	ldh a, [$FF81]
	ld b, a
	ld a, [hli]
	add a, b
	ld [de], a
	inc e
	ldh a, [$FF84]
	ld b, a
	ld a, [hli]
	add a, b
	ld [de], a
	inc e
	ld b, [hl]
	ld a, $0B
	or b
	inc l
	ld [de], a
	inc e
	dec c
	jr nz, Jump_316D
	ret


Func_3190:
	ld a, $02
	ld [rROMB0], a
	ldh a, [$FF86]
	ld l, a
	ldh a, [$FF87]
	ld h, a
	ldh a, [$FF85]
	add a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, $08
	ld [rROMB0], a
	ldh a, [$FF8A]
	ld b, a
Jump_31AF:
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
	inc de
	dec b
	jr nz, Jump_31AF
	ret


Func_31E3:
	push de
	push hl
	ld a, l
	and $C0
	add a, $20
	ld l, a
	ld d, [hl]
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld a, [hl]
	inc a
	ld [hl], a
	cp d
	jr c, Jump_31FF
	ld a, l
	and $C0
	ld l, a
	call Func_2044
Jump_31FF:
	pop hl
	pop de
	ret


Func_3202:
	push af
	push bc
	push de
	push hl
Jump_3206:
	ld e, $14
Jump_3208:
	ld a, [bc]
	ld [hli], a
	inc bc
	dec e
	jr nz, Jump_3208
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	dec d
	jr nz, Jump_3206
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_321E:
	push af
	push hl
	ld [hl], b
	ld a, l
	add a, $40
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld [hl], c
	pop hl
	pop af
	ret


Func_322D:
	ld a, $90
	ldh [rWY], a
	ld a, $07
	ldh [rWX], a
	ldh a, [rLCDC]
	or $40
	or $20
	ldh [rLCDC], a
	ldh a, [rWY]
	dec a
	ldh [rLYC], a
	ldh a, [rSTAT]
	set 6, a
	ldh [rSTAT], a
	ldh a, [rIE]
	set 1, a
	ldh [rIE], a
	call Func_325B
	ret


Func_3252:
	ldh a, [rWY]
	add a, b
	ldh [rWY], a
	dec a
	ldh [rLYC], a
	ret


Func_325B:
	call Func_32A3
	call Func_3302
	call Func_32B4
	xor a
	ld [wVBlankPending], a
Jump_3268:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_3268
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
	ret


Func_32A3:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_4233
	pop af
	ld [rROMB0], a
	ret


Func_32B4:
	push de
	push hl
	ld d, $87
	ld hl, $C421
	ld [hl], d
	inc l
	ld [hl], d
	inc l
	ld [hl], d
	inc l
	ld [hl], d
	inc l
	ld [hl], d
	inc l
	ld [hl], d
	inc l
	ld hl, $C461
	ld d, $16
	ld [hl], d
	inc l
	ld d, $1E
	ld [hl], d
	inc l
	ld [hl], d
	inc l
	ld [hl], d
	inc l
	ld [hl], d
	inc l
	ld d, $27
	ld [hl], d
	pop hl
	pop de
	ret


Func_32DE:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_42A2
	pop af
	ld [rROMB0], a
	ret


Func_32EF:
	ldh a, [rLCDC]
	and $DF
	ldh [rLCDC], a
	ldh a, [rSTAT]
	res 6, a
	ldh [rSTAT], a
	ldh a, [rIE]
	res 1, a
	ldh [rIE], a
	ret


Func_3302:
	call Func_356B
	call Func_334A
	call Func_3439
	call Func_3533
	ret


Func_330F:
	ld a, c
	ld b, $00
	ld h, b
	ld l, b
	add a, a
	jr nc, Jump_3319
	add hl, de
	adc a, b
Jump_3319:
	add hl, hl
	adc a, a
	jr nc, Jump_331F
	add hl, de
	adc a, b
Jump_331F:
	add hl, hl
	adc a, a
	jr nc, Jump_3325
	add hl, de
	adc a, b
Jump_3325:
	add hl, hl
	adc a, a
	jr nc, Jump_332B
	add hl, de
	adc a, b
Jump_332B:
	add hl, hl
	adc a, a
	jr nc, Jump_3331
	add hl, de
	adc a, b
Jump_3331:
	add hl, hl
	adc a, a
	jr nc, Jump_3337
	add hl, de
	adc a, b
Jump_3337:
	add hl, hl
	adc a, a
	jr nc, Jump_333D
	add hl, de
	adc a, b
Jump_333D:
	add hl, hl
	adc a, a
	jr nc, Jump_3343
	add hl, de
	adc a, b
Jump_3343:
	ret

	db $50, $01, $EB, $00, $B5, $00

Func_334A:
	push af
	push bc
	push de
	push hl
	ld a, [$CD00]
	ld l, a
	ld a, [$CD01]
	ld h, a
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld c, [hl]
	ld b, $00
	ld a, l
	and $C0
	add a, $1E
	ld l, a
	ld a, [$CD09]
	and a
	jr nz, Jump_336C
	ld c, a
Jump_336C:
	ld a, [hl]
	add a, a
	add a, $44
	ld l, a
	ld a, $00
	adc a, $33
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	call Func_330F
	ld d, h
	ld hl, $C421
	ld a, d
	sub $07
	jr nc, Jump_338A
	ld a, d
	ld d, $00
	jr Jump_338D

Jump_338A:
	ld d, a
	ld a, $07
Jump_338D:
	add a, $16
	ld e, a
	ld [hl], $87
	push hl
	ld a, l
	add a, $40
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld [hl], e
	pop hl
	inc hl
	ld a, d
	sub $08
	jr nc, Jump_33A8
	ld a, d
	ld d, $00
	jr Jump_33AB

Jump_33A8:
	ld d, a
	ld a, $08
Jump_33AB:
	add a, $1E
	ld e, a
	ld [hl], $87
	push hl
	ld a, l
	add a, $40
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld [hl], e
	pop hl
	inc hl
	ld a, d
	sub $08
	jr nc, Jump_33C6
	ld a, d
	ld d, $00
	jr Jump_33C9

Jump_33C6:
	ld d, a
	ld a, $08
Jump_33C9:
	add a, $1E
	ld e, a
	ld [hl], $87
	push hl
	ld a, l
	add a, $40
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld [hl], e
	pop hl
	inc hl
	ld a, d
	sub $08
	jr nc, Jump_33E4
	ld a, d
	ld d, $00
	jr Jump_33E7

Jump_33E4:
	ld d, a
	ld a, $08
Jump_33E7:
	add a, $1E
	ld e, a
	ld [hl], $87
	push hl
	ld a, l
	add a, $40
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld [hl], e
	pop hl
	inc hl
	ld a, d
	sub $08
	jr nc, Jump_3402
	ld a, d
	ld d, $00
	jr Jump_3405

Jump_3402:
	ld d, a
	ld a, $08
Jump_3405:
	add a, $1E
	ld e, a
	ld [hl], $87
	push hl
	ld a, l
	add a, $40
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld [hl], e
	pop hl
	inc hl
	ld a, d
	sub $07
	jr nc, Jump_3420
	ld a, d
	ld d, $00
	jr Jump_3423

Jump_3420:
	ld d, a
	ld a, $07
Jump_3423:
	add a, $27
	ld e, a
	ld [hl], $87
	push hl
	ld a, l
	add a, $40
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld [hl], e
	pop hl
	inc hl
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_3439:
	push af
	push bc
	push de
	push hl
	ld b, $87
	ld a, [$CD00]
	ld l, a
	ld a, [$CD01]
	ld h, a
	ld a, l
	and $C0
	add a, $29
	ld l, a
	ld a, [hl]
	cp $00
	jr z, Jump_346E
	ld d, a
	call Func_34DF
	ld a, l
	and $C0
	add a, $2A
	ld l, a
	ld a, [hl]
	cp $0A
	jr c, Jump_3463
	ld a, $09
Jump_3463:
	add a, $30
	ld c, a
	ld hl, $C407
	call Func_321E
	jr Jump_348A

Jump_346E:
	ld c, $01
	ld hl, $C407
	call Func_321E
	inc hl
	call Func_321E
	inc hl
	call Func_321E
	ld c, $04
	ld hl, $C428
	call Func_321E
	inc hl
	call Func_321E
Jump_348A:
	ld a, [$C91D]
	and a
	jr z, Jump_34CE
	ld a, [$C6B7]
	bit 4, a
	jr z, Jump_34B4
	ld c, $5A
	ld b, $87
	ld hl, $C40A
	call Func_321E
	inc hl
	inc c
	call Func_321E
	inc c
	ld hl, $C42A
	call Func_321E
	inc hl
	inc c
	call Func_321E
	jr Jump_34CE

Jump_34B4:
	ld c, $01
	ld b, $87
	ld hl, $C40A
	call Func_321E
	inc hl
	call Func_321E
	ld c, $04
	ld hl, $C42A
	call Func_321E
	inc hl
	call Func_321E
Jump_34CE:
	pop hl
	pop de
	pop bc
	pop af
	ret

	db $00, $4E, $52, $56, $00, $00, $01, $C7, $09, $C7, $11, $C7

Func_34DF:
	push af
	push bc
	push de
	push hl
	ld a, d
	add a, $D3
	ld l, a
	ld a, $00
	adc a, $34
	ld h, a
	ld c, [hl]
	ld b, $86
	ld hl, $C408
	call Func_321E
	inc hl
	inc c
	call Func_321E
	inc c
	ld hl, $C428
	call Func_321E
	inc hl
	inc c
	call Func_321E
	ld a, d
	add a, a
	add a, $D7
	ld l, a
	ld a, $00
	adc a, $34
	ld h, a
	ld bc, $C6F1
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hli]
	ld [bc], a
	inc bc
	ld a, [hli]
	ld [bc], a
	inc bc
	ld a, [hli]
	ld [bc], a
	inc bc
	ld a, [hli]
	ld [bc], a
	inc bc
	ld a, [hli]
	ld [bc], a
	inc bc
	ld a, [hli]
	ld [bc], a
	inc bc
	ld a, [hli]
	ld [bc], a
	inc bc
	ld a, [hli]
	ld [bc], a
	inc bc
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_3533:
	push hl
	push bc
	ld b, $87
	ld a, [$CD02]
	add a, $30
	ld c, a
	ld hl, $C401
	call Func_321E
	pop bc
	pop hl
	ret


Func_3546:
	push af
	push bc
	push hl
	ld a, d
	add a, a
	add a, $3A
	ld b, a
	push hl
	ld c, $87
	ld [hl], c
	ld a, $20
	add a, l
	ld l, a
	ld [hl], c
	pop hl
	ld a, l
	add a, $40
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld [hl], b
	ld a, $20
	add a, l
	ld l, a
	inc b
	ld [hl], b
	pop hl
	pop bc
	pop af
	ret


Func_356B:
	push af
	push bc
	push de
	push hl
	ld a, [$CD04]
	ld c, a
	ld a, [$CD05]
	ld b, a
	ld a, [$CD06]
	ld e, a
	ld a, [$CD07]
	ld d, a
	ld hl, $FF90
	call Func_06E7
	ld hl, $C40D
	xor a
	ldh [$FF98], a
	ld bc, $FF92
	ld e, $05
Jump_3590:
	ld a, e
	and $01
	jr z, Jump_359C
	ld a, [bc]
	swap a
	and $0F
	jr Jump_35A0

Jump_359C:
	ld a, [bc]
	and $0F
	inc c
Jump_35A0:
	ld d, a
	or a
	jr z, Jump_35A8
	ld a, $01
	ldh [$FF98], a
Jump_35A8:
	ld a, d
	or a
	jr nz, Jump_35B3
	ldh a, [$FF98]
	or a
	jr nz, Jump_35B3
	jr Jump_35B6

Jump_35B3:
	call Func_3546
Jump_35B6:
	inc hl
	dec e
	jr nz, Jump_3590
	ld a, [bc]
	and $0F
	ld d, a
	call Func_3546
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_35C6:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_42EE
	pop af
	ld [rROMB0], a
	ret


Func_35D7:
	push af
	push bc
	push de
	push hl
	ld a, [$CD08]
	call Func_0AD5
	ld a, l
	ld [$CD00], a
	ld a, h
	ld [$CD01], a
	ld bc, $0028
	ld de, $003C
	call Func_2125
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_35F7:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_446E
	pop af
	ld [rROMB0], a
	ret


Func_3608:
	ld a, [$CD00]
	ld l, a
	ld a, [$CD01]
	ld h, a
	push hl
	ld a, [$C6B5]
	ld e, a
	ld a, e
	cp $80
	jr nz, Jump_3621
	ld a, [$C6C1]
	cpl
	ld [$C6C1], a
Jump_3621:
	ld a, e
	and $F0
	cp $F0
	jr nz, Jump_362B
	jp Jump_00DA

Jump_362B:
	jr Jump_363B


Func_362D:
	ld a, [$CD0F]
	inc a
	ld [$CD0F], a
	cp $14
	jr nz, Jump_363F
	jp Jump_016C

Jump_363B:
	xor a
	ld [$CD0F], a
Jump_363F:
	ld a, [$C6C1]
	or a
	jr z, Jump_3647
	pop hl
	ret

Jump_3647:
	ld hl, wRuntimeCallback
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl


Func_364E:
	pop hl
	ld a, e
	and $02
	jr z, Jump_3657
	call Func_0CB5
Jump_3657:
	ld a, e
	and $01
	jr z, Jump_365F
	call Func_0CDD
Jump_365F:
	ld a, e
	and $04
	jr z, Jump_3669
	call Func_0C74
	jr Jump_3676

Jump_3669:
	ld a, e
	and $08
	jr z, Jump_3673
	call Func_0C51
	jr Jump_3676

Jump_3673:
	call Func_0C97
Jump_3676:
	ld a, e
	and $10
	jr z, Jump_367E
	call Func_0F98
Jump_367E:
	ret

Func_367F:
	pop hl
	ld a, e
	and $02
	jr z, Jump_3688
	call Func_0CB5
Jump_3688:
	ld a, e
	and $01
	jr z, Jump_3690
	call Func_0CDD
Jump_3690:
	ld a, e
	and $14
	jr z, Jump_369A
	call Func_0C74
	jr Jump_36A7

Jump_369A:
	ld a, e
	and $08
	jr z, Jump_36A4
	call Func_0C51
	jr Jump_36A7

Jump_36A4:
	call Func_0C97
Jump_36A7:
	ld a, e
	and $20
	ret z
	call Func_0F98
	ret


Func_36AF:
	pop hl
	ld a, e
	and $0F
	cp $02
	jr nz, Jump_36C1
	ld a, $0C
	call Func_2115
	call Func_0C74
	jr Jump_3726

Jump_36C1:
	cp $01
	jr nz, Jump_36CF
	ld a, $04
	call Func_2115
	call Func_0C74
	jr Jump_3726

Jump_36CF:
	cp $04
	jr nz, Jump_36DD
	ld a, $00
	call Func_2115
	call Func_0C74
	jr Jump_3726

Jump_36DD:
	cp $08
	jr nz, Jump_36EB
	ld a, $08
	call Func_2115
	call Func_0C74
	jr Jump_3726

Jump_36EB:
	cp $06
	jr nz, Jump_36F9
	ld a, $0E
	call Func_2115
	call Func_0C74
	jr Jump_3726

Jump_36F9:
	cp $0A
	jr nz, Jump_3707
	ld a, $0A
	call Func_2115
	call Func_0C74
	jr Jump_3726

Jump_3707:
	cp $05
	jr nz, Jump_3715
	ld a, $02
	call Func_2115
	call Func_0C74
	jr Jump_3726

Jump_3715:
	cp $09
	jr nz, Jump_3723
	ld a, $06
	call Func_2115
	call Func_0C74
	jr Jump_3726

Jump_3723:
	call Func_0C97
Jump_3726:
	ld a, e
	and $10
	ret z
	call Func_0F98
	ret


Func_372E:
	push de
	push bc
	ld a, $04
	call Func_1FF5
	jr z, Jump_3761
	ld a, l
	and $C0
	add a, $1E
	ld l, a
	ld [hl], b
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld [hl], c
	ld a, l
	and $C0
	add a, $19
	ld l, a
	ld [hl], $00
	ld a, l
	and $C0
	add a, $1A
	ld l, a
	ld [hl], $00
	ld a, l
	and $C0
	add a, $20
	ld l, a
	xor a
	ld [hl], a
	ld a, l
	and $C0
	ld l, a
Jump_3761:
	pop bc
	pop de
	ret


Func_3764:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call DispatchEntityHandler
	pop af
	ld [rROMB0], a
	ret


Func_3775:
	push hl
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld a, [hl]
	cp $FF
	jr z, Jump_378F
	dec a
	ld [hl], a
	jr nz, Jump_378F
	ld a, l
	and $C0
	ld l, a
	call Func_2044
	xor a
	pop hl
	ret

Jump_378F:
	xor a
	inc a
	pop hl
	ret


Func_3793:
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld a, [hl]
	cp $FF
	jr z, Jump_37A5
	ld a, [$C6B7]
	and $10
	jr z, Jump_37AB
Jump_37A5:
	call SelectObjectSpritePaletteFar
	call Func_37BD
Jump_37AB:
	ret


SelectObjectSpritePaletteFar:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $08
	ld [rROMB0], a
	call SelectObjectSpritePalette
	pop af
	ld [rROMB0], a
	ret


Func_37BD:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_4687
	pop af
	ld [rROMB0], a
	ret


Func_37CE:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $04
	ld [rROMB0], a
	call Func_04_601C
	pop af
	ld [rROMB0], a
	ret


Func_37DF:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $04
	ld [rROMB0], a
	call Func_04_6343
	pop af
	ld [rROMB0], a
	ret


Func_37F0:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $04
	ld [rROMB0], a
	call Func_04_6392
	pop af
	ld [rROMB0], a
	ret


Func_3801:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $03
	ld [rROMB0], a
	call Func_03_5C11
	pop af
	ld [rROMB0], a
	ret


Func_3812:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $03
	ld [rROMB0], a
	call Func_03_5CD0
	pop af
	ld [rROMB0], a
	ret


Func_3823:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $03
	ld [rROMB0], a
	call Func_03_6391
	pop af
	ld [rROMB0], a
	ret


Func_3834:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $03
	ld [rROMB0], a
	call DispatchStateCheck
	pop af
	ld [rROMB0], a
	ret


Func_3845:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $03
	ld [rROMB0], a
	call Func_03_6923
	pop af
	ld [rROMB0], a
	ret


Func_3856:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_46B1
	pop af
	ld [rROMB0], a
	ret


Func_3867:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_4703
	pop af
	ld [rROMB0], a
	ret


Func_3878:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_475E
	pop af
	ld [rROMB0], a
	ret


Func_3889:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_4799
	pop af
	ld [rROMB0], a
	ret


Func_389A:
	push af
	push bc
	push de
	push hl
	ld d, $00
Jump_38A0:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_38A0
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
	call Func_38E2
Jump_38B7:
	ldh a, [rSTAT]
	and $02
	jr z, Jump_38B7
Jump_38BD:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_38BD
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
	push hl
	ld hl, sp + 12
	ld a, [hl]
	pop hl
	inc hl
	inc hl
	sla a
	cp d
	jr nz, Jump_38A0
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_38E2:
	push de
	push hl
	push bc
	ld a, [hli]
	ld c, a
	ld a, [hl]
	ld b, a
	ld h, b
	ld l, c
	pop bc
	push hl
	ld a, h
	srl a
	srl a
	and $1F
	ld h, a
	ld a, b
	srl a
	srl a
	and $1F
	cp h
	jr z, Jump_390C
	add a, e
	sla a
	sla a
	ld d, a
	ld a, b
	and $03
	or d
	and $7F
	ld b, a
Jump_390C:
	pop hl
	push hl
	sla l
	rl h
	sla l
	rl h
	sla l
	rl h
	ld a, h
	and $1F
	ld h, a
	ld a, b
	swap a
	and $30
	ld d, a
	ld a, c
	swap a
	and $0E
	or d
	srl a
	and $1F
	cp h
	jr z, Jump_394B
	add a, e
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
Jump_394B:
	pop hl
	ld a, l
	and $1F
	ld l, a
	ld a, c
	and $1F
	cp l
	jr z, Jump_395D
	add a, e
	ld d, a
	ld a, c
	and $E0
	or d
	ld c, a
Jump_395D:
	pop hl
	pop de
	ret


Func_3960:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_46E1
	pop af
	ld [rROMB0], a
	ret


Func_3971:
	xor a
	ld [$C6B5], a
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
Jump_3989:
	ld a, [$C6B5]
	or a
	jr nz, Jump_39A6
	call Audio_Update
	xor a
	ld [wVBlankPending], a
Jump_3996:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_3996
	xor a
	ld [wVBlankPending], a
	dec d
	jr nz, Jump_3989
Jump_39A6:
	ret


ScreenTable_CallInit:
	push af
	push bc
	push de
	push hl
	call ScreenTable_LoadEntry
	ld hl, $C6E3
	ld a, [hli]
	ld e, a
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, e
	ld [rROMB0], a
	ld de, Func_39C4
	push de
	jp hl

Func_39C4:
	pop af
	ld [rROMB0], a
	pop hl
	pop de
	pop bc
	pop af
	ret


ScreenTable_CallUpdate:
	push af
	push bc
	push de
	push hl
	push bc
	call ScreenTable_LoadEntry
	ld hl, $C6E3
	ld a, [hli]
	ld e, a
	inc hl
	ld bc, $0002
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop bc
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, e
	ld [rROMB0], a
	push bc
	ld de, Func_39F1
	push de
	jp hl

Func_39F1:
	pop bc
	pop af
	ld [rROMB0], a
	pop hl
	pop de
	pop bc
	pop af
	ret


ScreenTable_LoadEntry:
	ld hl, ScreenModeTable
	add a, a
	add a, a
	add a, a
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld bc, $C6E3
	ld e, $08
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call CopyBytesShort
	pop af
	ld [rROMB0], a
	ret


Func_3A1E:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_4710
	pop af
	ld [rROMB0], a
	ret


Func_3A2F:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_474B
	pop af
	ld [rROMB0], a
	ret


Func_3A40:
	push bc
	ld hl, $D000
	ld b, a
	ld c, $00
	srl b
	rr c
	srl b
	rr c
	add hl, bc
	pop bc
	ret


Func_3A52:
	ld a, $02
	ldh [rSVBK], a
	ld a, e
	call Func_3A40
	ld c, $08
	ld b, $00
	push de
	call Func_052F
	ld a, $01
	ldh [rSVBK], a
	pop de
	ret


Func_3A68:
	ld a, $02
	ldh [rSVBK], a
	ld a, e
	call Func_3A40
	ld a, d
	add a, a
	add a, a
	add a, a
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld e, $08
Jump_3A7D:
	ld a, [hli]
	ld [bc], a
	inc bc
	dec e
	jr nz, Jump_3A7D
	ld a, $01
	ldh [rSVBK], a
	ret


Func_3A88:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, d
	ld [rROMB0], a
	ld a, $02
	ldh [rSVBK], a
	push hl
	ld hl, $D000
	ld bc, $0800
	call Func_050B
	pop hl
	ld bc, $D7C0
	call CopyBytesShort
	ld a, $01
	ldh [rSVBK], a
	pop af
	ld [rROMB0], a
	ret


Func_3AAE:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_5867
	pop af
	ld [rROMB0], a
	ret


Func_3ABF:
	ld a, $01
	ld [rROMB0], a
	call Func_3CD9
	ld a, [$C6CD]
	cp $01
	jr z, Jump_3B11
	call Func_01_5BF1
	ld a, [wLevelNumber]
	ld hl, $6609
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	or a
	ld a, [wLevelNumber]
	jr z, Jump_3AEE
	call Func_01_63B3
	call Func_01_609A
	call Func_01_6133
Jump_3AEE:
	ld e, $10
	call Audio_QueueSound
Jump_3AF3:
	call Func_0421
	and $07
	cp $06
	jr nc, Jump_3AF3
	add a, $81
	ld e, a
	call Audio_QueueSound
	call Func_01_5BF1
	ld a, [wLevelNumber]
	call Func_01_63D1
	call Func_01_609A
	call Func_3960
Jump_3B11:
	ret


Func_3B12:
	ld a, $01
	ld [rROMB0], a
	ld a, [$C6CD]
	cp $00
	jr z, Jump_3B28
	cp $02
	jr z, Jump_3B28
	cp $01
	jr z, Jump_3B38
	jr Jump_3B59

Jump_3B28:
	call Func_01_5BF1
	xor a
	ldh [$FF82], a
	ldh [$FF81], a
	call Func_01_609A
	call Func_3C08
	jr Jump_3B59

Jump_3B38:
	ld a, $08
	call ScreenTable_CallInit
	ld a, $08
	ld bc, $0000
	call ScreenTable_CallUpdate
	xor a
	ld [wVBlankPending], a
Jump_3B49:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_3B49
	xor a
	ld [wVBlankPending], a
	call Func_3F1F
Jump_3B59:
	ret


Func_3B5A:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	ld a, [$C6CD]
	cp $01
	jr z, Jump_3B9A
	call Func_035C
	ld e, $82
	call Audio_QueueSound
	ld a, [wLevelNumber]
	cp $0E
	jp z, Jump_3B9A
	call Func_01_6BBC
	call Func_3BC4
Jump_3B80:
	xor a
	ld [wVBlankPending], a
Jump_3B84:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_3B84
	xor a
	ld [wVBlankPending], a
	call Audio_Update
	ld a, [$C6B5]
	or a
	jr z, Jump_3B80
Jump_3B9A:
	pop af
	ld [rROMB0], a
	ret


Func_3B9F:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_5C40
	pop af
	ld [rROMB0], a
	ret


Func_3BB0:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_0AC4
	call Func_01_6618
	pop af
	ld [rROMB0], a
	ret


Func_3BC4:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_6CF0
	pop af
	ld [rROMB0], a
	ret


Func_3BD5:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_6E01
	pop af
	ld [rROMB0], a
	ret


Func_3BE6:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_47AF
	pop af
	ld [rROMB0], a
	ret


Func_3BF7:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_5D33
	pop af
	ld [rROMB0], a
	ret


Func_3C08:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_6E44
	pop af
	ld [rROMB0], a
	ret


Func_3C19:
	ld a, $00
	ld [$C941], a
	ld a, $D0
	ld [$C942], a
	xor a
	ld [$C940], a
	ret


Func_3C28:
	push af
	push hl
	ldh a, [rSVBK]
	push af
	ld a, $04
	ldh [rSVBK], a
	ld a, [$C941]
	ld l, a
	ld a, [$C942]
	ld h, a
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	ld a, b
	ld [hli], a
	ld a, c
	ld [hli], a
	ld a, l
	ld [$C941], a
	ld a, h
	ld [$C942], a
	ld a, [$C940]
	inc a
	ld [$C940], a
	pop af
	ldh [rSVBK], a
	pop hl
	pop af
	ret


Func_3C56:
	push af
	push bc
	push hl
	ld a, [$C940]
	or a
	jr z, Jump_3C76
	ld b, a
	ldh a, [rSVBK]
	push af
	ld a, $04
	ldh [rSVBK], a
	ld hl, $D000
Jump_3C6A:
	call Func_3C7A
	dec b
	jr nz, Jump_3C6A
	pop af
	ldh [rSVBK], a
	call Func_3C19
Jump_3C76:
	pop hl
	pop bc
	pop af
	ret


Func_3C7A:
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, $01
	ldh [rVBK], a
Jump_3C82:
	ldh a, [rSTAT]
	and $02
	jr nz, Jump_3C82
	ld a, [hli]
	ld [de], a
	xor a
	ldh [rVBK], a
	ld a, [hli]
	ld [de], a
	ret


Func_3C90:
	ld hl, $C943
	ld a, [hli]
	ld b, a
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, b
	ld [rROMB0], a
	ld a, [$C94F]
	ld l, a
	ld a, [$C950]
	ld h, a
	ld bc, $0168
	add hl, bc
	ld a, [hl]
	ld [$C955], a
	ld a, [$C951]
	ld e, a
	ld a, [$C952]
	ld d, a
	ld hl, $0168
	add hl, de
	ld a, [hl]
	ld [$C956], a
	pop af
	ld [rROMB0], a
	ret


Func_3CC2:
	ldh a, [rLCDC]
	res 1, a
	ldh [rLCDC], a
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_5D6D
	pop af
	ld [rROMB0], a
	ret


Func_3CD9:
	xor a
	ld [wVBlankPending], a
Jump_3CDD:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, Jump_3CDD
	xor a
	ld [wVBlankPending], a
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_4810
	pop af
	ld [rROMB0], a
	ret


Func_3CFB:
	push af
	push bc
	push de
	push hl
	ld a, [$CD00]
	ld l, a
	ld a, [$CD01]
	ld h, a
	ld a, l
	and $C0
	add a, $06
	ld l, a
	ld a, [hli]
	ld [$C957], a
	ld a, [hli]
	ld [$C958], a
	ld [$C95B], a
	sub $10
	ld [$C95A], a
	call Func_0CA8
	ld a, $4B
	ld [$C959], a
	ld a, $1E
	ld [$C95C], a
	ld a, $58
	ld [$C95D], a
	ld a, $63
	ld [$C95E], a
	ld a, $00
	ld [$C965], a
	ld a, $D0
	ld [$C966], a
	ld a, $40
	ld [$C967], a
	call Func_3D70
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $08
	ld [rROMB0], a
	ld hl, $5502
	ld b, $03
	ld c, $01
	call Func_057D
	pop af
	ld [rROMB0], a
	ld a, $01
	ld [$C0FF], a
	ld a, $4F
	ld [wSfxSeqLockId], a
	ld e, a
	call Audio_QueueSound
	pop hl
	pop de
	pop bc
	pop af
	ret


Func_3D70:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_7D3A
	pop af
	ld [rROMB0], a
	ret


Func_3D81:
	ld a, [$C967]
	or a
	jr z, Jump_3DD7
	ld d, a
	ld a, [$C965]
	ld l, a
	ld a, [$C966]
	ld h, a
Jump_3D90:
	ld e, l
	ld a, $08
	add a, e
	ld l, a
	ld a, [hl]
	and $08
	jr z, Jump_3DAC
	ld a, $1D
	add a, e
	ld l, a
	ld a, [hl]
	ld l, e
	cp $01
	jr nz, Jump_3DAC
	ld a, $26
	add a, e
	ld l, a
	ld a, [hl]
	or a
	jr nz, Jump_3DBC
Jump_3DAC:
	ld a, e
	add a, $40
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	dec d
	jr nz, Jump_3D90
	xor a
	ld [$C967], a
	ret

Jump_3DBC:
	ld a, d
	ld [$C967], a
	ld a, e
	ld [$C965], a
	ld a, h
	ld [$C966], a
	ld l, e
	call GetObjectScoreValue
	call AddToScore
	ld l, e
	ld a, $01
	ld b, $01
	call Func_0AF5
Jump_3DD7:
	ret


Func_3DD8:
	ld a, $05
	ld [rROMB0], a
	ld a, [$C95D]
	add a, b
	ld l, a
	ld a, [$C95E]
	adc a, $00
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, h
	or a
	ret z
	ld a, [hli]
	ld [$C95F], a
	ld a, [hli]
	ld [$C960], a
	ld a, [hli]
	ld [$C961], a
	ld a, [hli]
	ld [$C962], a
	ld a, [hl]
	ld [$C963], a
	xor a
	inc a
	ret


Func_3E05:
	ld a, [$C959]
	cp $03
	ret c
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $08
	ld [rROMB0], a
	ld b, $00
	ld c, $03
Jump_3E18:
	call Func_3DD8
	jr z, Jump_3E32
	push bc
	ld a, [$C95F]
	call Func_20D2
	cp $FF
	jr z, Jump_3E31
	ld [$C964], a
	call Func_3E3C
	call Func_3E81
Jump_3E31:
	pop bc
Jump_3E32:
	inc b
	inc b
	dec c
	jr nz, Jump_3E18
	pop af
	ld [rROMB0], a
	ret


Func_3E3C:
	ld a, [$C960]
	ld l, a
	ld a, [$C961]
	ld h, a
	ld a, $08
	ld [rROMB0], a
	ld a, [$C95F]
	ld b, a
Jump_3E4D:
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
	inc de
	dec b
	jr nz, Jump_3E4D
	ret


Func_3E81:
	ld a, [$C962]
	ld l, a
	ld a, [$C963]
	ld h, a
	ld a, $05
	ld [rROMB0], a
	ld a, [$C95F]
	ld c, a
Jump_3E92:
	call Func_2090
	ld a, [$C958]
	ld b, a
	ld a, [hli]
	add a, b
	ld [de], a
	inc e
	ld a, [$C957]
	ld b, a
	ld a, [hli]
	add a, b
	ld [de], a
	inc e
	ld a, [$C964]
	ld b, a
	ld a, [hli]
	add a, b
	ld [de], a
	inc e
	ld a, [hli]
	or $03
	ld b, a
	ld a, $00
	add a, b
	ld [de], a
	dec c
	jr nz, Jump_3E92
	ret


Func_3EB9:
	call Func_0421
	and $03
	ret z
	call Func_04B6
	ld b, $64
Jump_3EC4:
	ld c, $FF
Jump_3EC6:
	nop
	dec c
	jr nz, Jump_3EC6
	dec b
	jr nz, Jump_3EC4
	call Func_0051
	ret


Func_3ED1:
	ld a, [$C959]
	dec a
	ld [$C959], a
	or a
	jr z, Jump_3F00
	and $03
	jr nz, Jump_3EFF
	ld a, [$C95C]
	or a
	jr z, Jump_3EEC
	dec a
	ld [$C95C], a
	call Func_3EB9
Jump_3EEC:
	ld a, [$C95D]
	add a, $06
	ld [$C95D], a
	ld a, [$C95E]
	adc a, $00
	ld [$C95E], a
	call Func_3D81
Jump_3EFF:
	ret

Jump_3F00:
	call Func_1163
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $08
	ld [rROMB0], a
	ld hl, $46EA
	ld b, $03
	ld c, $01
	call Func_057D
	pop af
	ld [rROMB0], a
	xor a
	ld [$C0FF], a
	ret


Func_3F1F:
	ld a, $02
	ld [rROMB0], a
	call Func_02_6306
	ret


Func_3F28:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $2A
	ld [rROMB0], a
	call Func_2A_7774
	pop af
	ld [rROMB0], a
	ret

	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00
