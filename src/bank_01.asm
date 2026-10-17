; BattleTanx (USA) - ROM bank $01

INCLUDE "include/banks_01_05_ram.inc"

SECTION "ROM Bank $01", ROMX[$4000], BANK[$01]

RunPauseHudSequence:
Func_01_4000: ; legacy alias, used by src/bank_00.asm
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
	call MoveHudWindow
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
	call MoveHudWindow
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
	ld a, [wGamePaused]
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
	call MoveHudWindow
	dec d
	jr nz, Jump_01_4066
	call RefreshHud
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
	call MoveHudWindow
	dec d
	jr nz, Jump_01_4084
	ret


LosePlayerLifeAndWaitForMusic:
Func_01_409E: ; legacy alias, used by src/bank_00.asm
	push af
	push bc
	push de
	push hl
	xor a
	ld [wSfxSeqPtr], a
	ld [wSfxSeqPtr + 1], a
	ldh [rNR51], a
	call LosePlayerLife
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


ByteToBcd16:
Func_01_40CE: ; legacy alias, used by src/bank_00.asm
	push af
	push bc
	push de
	push hl
	xor a
	ld [hli], a
	ld [hl], a
	ld e, l
	ld d, h
	ld hl, Bank01Data_4F00
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


AddWordToBcd24:
Func_01_4102: ; legacy alias, used by src/bank_00.asm
	push af
	push bc
	push de
	push hl
	push bc
	ld b, c
	push bc
	inc de
	inc de
	ld hl, Bank01Data_4F10
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


LongToBcd40:
Func_01_4143: ; legacy alias, used by src/bank_00.asm
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
	ld hl, Bank01Data_4F40
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

ScoreThresholdTable:
	db $50, $C3, $00, $00, $A0, $86, $01, $00, $F0, $49, $02, $00, $40, $0D, $03, $00
	db $90, $D0, $03, $00, $E0, $93, $04, $00, $30, $57, $05, $00, $80, $1A, $06, $00
	db $D0, $DD, $06, $00, $20, $A1, $07, $00, $70, $64, $08, $00, $C0, $27, $09, $00
	db $10, $EB, $09, $00, $60, $AE, $0A, $00, $B0, $71, $0B, $00, $00, $35, $0C, $00
	db $50, $F8, $0C, $00, $A0, $BB, $0D, $00, $F0, $7E, $0E, $00, $40, $42, $0F, $00
	db $FF, $FF, $FF, $FF
Bank01Data_41E3:
	db $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87
	db $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87
	db $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87
Bank01Data_420B:
	db $00, $01, $2F, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $02
	db $03, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $05

LoadHudTopRows:
Func_01_4233: ; legacy alias, used by src/bank_00.asm
	push af
	push bc
	push de
	push hl
	ld d, $02
	ld hl, wVramDmaStagingBuffer
	ld bc, Bank01Data_41E3
	call Func_3202
	ld d, $02
	ld hl, $C440
	ld bc, Bank01Data_420B
	call Func_3202
	pop hl
	pop de
	pop bc
	pop af
	ret

Bank01Data_4252:
	db $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87
	db $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87
	db $87, $87, $87, $87, $87, $87, $87, $87
Bank01Data_427A:
	db $00, $01, $01, $01, $01, $01, $06, $07
	db $08, $09, $0A, $0B, $0C, $0D, $01, $01, $01, $01, $01, $02, $03, $04, $04, $04
	db $04, $04, $0E, $0F, $10, $11, $12, $13, $14, $15, $04, $04, $04, $04, $04, $05

LoadPauseHudTopRowsAndTransfer:
Func_01_42A2: ; legacy alias, used by src/bank_00.asm
	push af
	push bc
	push de
	push hl
	ld d, $02
	ld hl, wVramDmaStagingBuffer
	ld bc, Bank01Data_4252
	call Func_3202
	ld d, $02
	ld hl, $C440
	ld bc, Bank01Data_427A
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


Bank01NoOpEntry:
Func_01_42EE: ; legacy alias (automatic entry label)
	ret


DrawObjectStatusCountsToWindow:
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
	ld a, [wUnwrittenStatusDisplayValue0]
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
	ld a, [wUnwrittenStatusDisplayValue1]
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


AnimatePlayerHealthRefill:
Func_01_446E: ; legacy alias, used by src/bank_00.asm
	push hl
	push bc
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
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
	call AddObjectHealth
	call DrawPlayerHealthBar
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
	dw PickupRestoreQuarterHealth
	dw PickupRestoreHalfHealth
	dw PickupHandler02
	dw PickupBonusScore3000
	dw PickupExtraLife
	dw PickupPowerupType2
	dw PickupPowerupType1
	dw PickupPowerupType3
	dw PickupTriggerHudAlert
	dw PickupHandlerNoOp

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


FinishPickupFreeObject:
	pop hl
	call FreeObjectRecord
	pop bc
	pop de
	ret


FinishPickupKeepObject:
	pop hl
	pop bc
	pop de
	ret


PickupRestoreQuarterHealth:
	pop hl
	call GetObjectMaxHealth
	ld b, a
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld a, [hl]
	cp b
	jr c, Jump_01_452C
	jp FinishPickupKeepObject

Jump_01_452C:
	ld a, b
	sra a
	sra a
	ld b, a
	call AddObjectHealth
	ld e, $4A
	call Audio_QueueSound
	jp FinishPickupFreeObject


PickupRestoreHalfHealth:
	pop hl
	call GetObjectMaxHealth
	ld b, a
	ld a, l
	and $C0
	add a, $1F
	ld l, a
	ld a, [hl]
	cp b
	jr c, Jump_01_454F
	jp FinishPickupKeepObject

Jump_01_454F:
	ld a, b
	sra a
	ld b, a
	call AddObjectHealth
	ld e, $4B
	call Audio_QueueSound
	jp FinishPickupFreeObject


PickupHandler02:
	pop hl
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_PICKUP02_TIMER_OFFSET
	ld l, a
	ld a, [hl]
	or a
	jp nz, FinishPickupKeepObject
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_PICKUP02_TIMER_OFFSET
	ld l, a
	ld [hl], $3C
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_ACTION_FEEDBACK_TIMER_OFFSET
	ld l, a
	ld [hl], $00
	ld e, $53
	call Audio_QueueSound
	jp FinishPickupFreeObject


PickupBonusScore3000:
	pop hl
	ld a, [wPlayerObject]
	cp l
	jr nz, FinishPickupFreeObject
	ld a, [wPlayerObject + 1]
	cp h
	jp nz, FinishPickupFreeObject
	call Func_3845
	ld bc, $0BB8
	call AddToScore
	ld e, $54
	call Audio_QueueSound
	ld a, [wBonusPickupCount]
	inc a
	ld [wBonusPickupCount], a
	call Func_0A48
	jp FinishPickupFreeObject


PickupExtraLife:
	pop hl
	ld a, [wPlayerObject]
	cp l
	jp nz, FinishPickupKeepObject
	ld a, [wPlayerObject + 1]
	cp h
	jp nz, FinishPickupKeepObject
	ld a, [wPlayerLives]
	cp $09
	jp z, FinishPickupKeepObject
	call GainPlayerLife
	ld e, $49
	call Audio_QueueSound
	jp FinishPickupFreeObject


PickupPowerupType2:
	pop hl
	ld a, l
	and $C0
	add a, $29
	ld l, a
	ld a, [hl]
	cp $00
	jp nz, FinishPickupKeepObject
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
	jp FinishPickupFreeObject


PickupPowerupType1:
	pop hl
	ld a, l
	and $C0
	add a, $29
	ld l, a
	ld a, [hl]
	cp $00
	jp nz, FinishPickupKeepObject
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
	jp FinishPickupFreeObject


PickupPowerupType3:
	pop hl
	ld a, l
	and $C0
	add a, $29
	ld l, a
	ld a, [hl]
	cp $00
	jp nz, FinishPickupKeepObject
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
	ld a, [wPowerupType3PickupCount]
	inc a
	ld [wPowerupType3PickupCount], a
	jp FinishPickupFreeObject


PickupTriggerHudAlert:
	pop hl
	ld a, l
	and $C0
	add a, OBJECT_NONPLAYER_CONTROLLED_FLAG_OFFSET
	ld l, a
	ld a, [hl]
	and a
	jp nz, FinishPickupKeepObject
	ld a, $01
	ld [wHudAlertActive], a
	ld e, $53
	call Audio_QueueSound
	xor a
	ld [wNearestTargetDistance + 1], a
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
	ld [wAlertObjectTypePtr], a
	ld a, h
	ld [wAlertObjectTypePtr + 1], a
	jp FinishPickupKeepObject


PickupHandlerNoOp:
	pop hl
	jp FinishPickupKeepObject

	db $53, $54, $55, $56, $57, $58, $59, $5A

DrawObjectTypeMarkerSprite:
Func_01_4687: ; legacy alias, used by src/bank_00.asm
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


SubtractRgb555Saturating:
Func_01_46B1: ; legacy alias, used by src/bank_00.asm
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


AddRgb555Saturating:
Func_01_4703: ; legacy alias, used by src/bank_00.asm
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


DarkenAllBgPaletteColors:
Func_01_475E: ; legacy alias, used by src/bank_00.asm
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


CaptureBgPalettesAndFadeToWhite:
Func_01_4799: ; legacy alias, used by src/bank_00.asm
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
	screen_mode BANK(Func_2D_54FA), Func_2D_54FA, Func_2D_5552
	screen_mode BANK(Func_2A_61D8), Func_2A_61D8, Func_2A_6230
	screen_mode BANK(Func_2C_4000), Func_2C_4000, Func_2C_4058
	screen_mode BANK(Func_2C_5ED3), Func_2C_5ED3, Func_2C_5F2B
	screen_mode BANK(Func_2B_6E6C), Func_2B_6E6C, Func_2B_6EC4
	screen_mode BANK(Func_2C_4B3A), Func_2C_4B3A, Func_2C_4B92
	screen_mode BANK(Func_2C_5F9F), Func_2C_5F9F, Func_2C_5FF7
	screen_mode BANK(Func_2B_4000), Func_2B_4000, Func_2B_4058
	screen_mode BANK(Func_2D_4000), Func_2D_4000, Func_2D_4058
	screen_mode BANK(Func_2B_5BDA), Func_2B_5BDA, Func_2B_5C32
	screen_mode BANK(Func_2B_5BDA), Func_2B_5BDA, Func_2B_5C32
	screen_mode BANK(Func_2C_55C4), Func_2C_55C4, Func_2C_561C
	screen_mode BANK(Func_2A_6A22), Func_2A_6A22, Func_2A_6A7A

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
ASSERT @ - OptionsMenuEntries == 16
	db $02, $03
	dw wControlSetting
	db $03, $08
OptionsControlText:
	db "CONTROL"
	ds 3, 0
ASSERT @ - OptionsMenuEntries == 32
	db $03, $04
	dw wSkillSetting
	db $03, $0C
OptionsSkillText:
	db "SKILL"
	ds 5, 0
OptionsMenuEntriesEnd:
ASSERT OptionsMenuEntriesEnd - OptionsMenuEntries == 3 * 16

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
ControlTypeTexts:
ControlType1Text:
	db "1"
	ds 7, 0
ASSERT @ - ControlType1Text == 8
ControlType2Text:
	db "2"
	ds 7, 0
ASSERT @ - ControlType2Text == 8
ControlType3Text:
	db "3"
	ds 7, 0
ASSERT @ - ControlType3Text == 8
ControlTypeTextsEnd:
ASSERT ControlTypeTextsEnd - ControlTypeTexts == 3 * 8
SkillTexts:
SkillEasyText:
	db "EASY"
	ds 4, 0
ASSERT @ - SkillEasyText == 8
SkillMediumText:
	db "MED "
	ds 4, 0
ASSERT @ - SkillMediumText == 8
SkillHardText:
	db "HARD"
	ds 4, 0
ASSERT @ - SkillHardText == 8
SkillTextsEnd:
ASSERT SkillTextsEnd - SkillTexts == 3 * 8

Bank01RomImage_49CB:
	LOAD UNION "RAM code $D56A", WRAMX[$D56A] ; copied from $01:49CB

InitMenuSystem:
RAM_D56A: ; legacy alias, used by src/bank_00.asm
	ld a, $01
	ldh [rSVBK], a
	ldh a, [rLCDC]
	res 5, a
	ldh [rLCDC], a
	ld a, $14
	ld [wMenuRepeatTimer], a
	ld a, $01
	ldh [rSVBK], a
	ld hl, MenuHandlerReturn
	ld a, l
	ld [$D561], a
	ld a, h
	ld [$D562], a
	xor a
	ld [wGameStartMode], a
	ld [wMenuGridColumn], a
	ld [wMenuGridRow], a
	ld [wMenuScrollDirection], a
	ld [wMenuCursorSpritesEnabled], a
	ld a, [wActiveSkillLevel]
	ld [wSkillSetting], a
	call ClearPasswordEntryChars
	ld a, [$C6B5]
	ld [wMenuPreviousButtons], a
	call InstallMenuInterruptHandlers
	call Func_0781
	ld a, $01
	ld [wMenuActive], a
	ld [wMenuCursorChoice], a
	ld hl, MenuState00
	ld a, l
	ld [wMenuState], a
	ld [wMenuRenderedState], a
	ld a, h
	ld [wMenuState + 1], a
	ld [wMenuRenderedState + 1], a
	call InitMenuCursorForState
	call LoadEncodedFontTilesToVram1
	call LoadMenuCursorSprites
	call MovePasswordCursorOffscreen
	ld a, $01
	ld [wMenuScanlineScrollEnabled], a
	xor a
	call UpdateMenuCursorPosition
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
	call SetMenuCursorChoice
	call UpdateMenuCursorPosition
	call EnableMenuCursorSpritesWaitVBlank
	ret

	ENDL
	db $00

ClearPasswordEntryChars:
Func_01_4A62: ; legacy alias (automatic entry label)
	ld d, $05
	ld hl, wPasswordEntryChars
	xor a
ClearPasswordEntryCharsLoop:
	ld [hli], a
	dec d
	jr nz, ClearPasswordEntryCharsLoop
	ret


Bank01RomImage_4A6D:
	LOAD UNION "RAM code $D62A", WRAMX[$D62A] ; copied from $01:4A6D

RunMenuLoop:
RAM_D62A: ; legacy alias, used by src/bank_00.asm
	push af
	push bc
	push de
	push hl
MenuLoopTop:
	ld a, [wMenuActive]
	or a
	jr nz, MenuCheckStateChange
	pop hl
	pop de
	pop bc
	pop af
	ld a, [wMusicSetting]
	ld [wUnusedCommittedMusicSetting], a
	ld a, [wControlSetting]
	ld [wUnusedCommittedControlSetting], a
	ld a, [wSkillSetting]
	ld [wActiveSkillLevel], a
	ld a, $01
	ld [rROMB0], a
	ret

MenuCheckStateChange:
	ld a, [wMenuState]
	ld b, a
	ld a, [wMenuRenderedState]
	cp b
	jr nz, MenuEnterNewState
	ld a, [wMenuState + 1]
	ld b, a
	ld a, [wMenuRenderedState + 1]
	cp b
	jr z, MenuFrameWait
MenuEnterNewState:
	call Func_06F8
	call HideMenuCursorSprites
	ld a, [wMenuState]
	ld l, a
	ld a, [wMenuState + 1]
	ld h, a
	ld a, $01
	ld [wMenuCursorChoice], a
	call InitMenuCursorForState
	ld a, $00
	ldh [rSCX], a
	ld a, $01
	ld [wMenuScanlineScrollEnabled], a
	xor a
	call UpdateMenuCursorPosition
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
	call EnableMenuCursorSpritesWaitVBlank
	call InitMenuStateScreen
	ld a, $01
MenuDrawOptionLabelsLoop:
	call DrawOptionsEntryLabel
	cp $FF
	jr nz, MenuDrawOptionLabelsLoop
	ld a, [wMenuState]
	ld [wMenuRenderedState], a
	ld a, [wMenuState + 1]
	ld [wMenuRenderedState + 1], a
MenuFrameWait:
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
	call UpdateMenuCursorPosition
	ld a, [wMenuCursorMoving]
	or a
	jp nz, MenuLoopTop
	call UpdateMenuInputRepeat
	ld bc, MenuHandlerReturn
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

MenuHandlerReturn:
	jp MenuLoopTop

	ret
	ENDL
	db $00

InstallMenuInterruptHandlers:
	di
	ld hl, Bank01RomImage_4B72
	ld bc, $C729
	ld de, $0024
	call CopyBytesShort
	ld hl, Bank01RomImage_4B96
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


Bank01RomImage_4B72:
	LOAD UNION "RAM code $C729", WRAM0[$C729] ; copied from $01:4B72

MenuStatHandler:
	push af
	push hl
	push bc
	ld a, [wMenuScanlineScrollEnabled]
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
	ld hl, wMenuScanlineScrollTable
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

Bank01RomImage_4B96:
	LOAD UNION "RAM code $C7F1", WRAM0[$C7F1] ; copied from $01:4B96

MenuVBlankHandler:
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
	ld a, [wMenuCursorY]
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
	call StepMenuScroll
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

UpdateMenuCursorPosition:
	push af
	push bc
	push de
	push hl
	ld d, a
	ld a, $01
	ld [wMenuCursorMoving], a
	call StepPasswordCursorSprites
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
	ld a, [wMenuCursorTargetY]
	ld b, a
	ld a, [wMenuCursorY]
	cp b
	jr z, Jump_01_4C77
	jr c, Jump_01_4C44
	sub $01
	jr nc, Jump_01_4C3F
	xor a
Jump_01_4C3F:
	ld [wMenuCursorY], a
	jr Jump_01_4C49

Jump_01_4C44:
	add a, $01
	ld [wMenuCursorY], a
Jump_01_4C49:
	ld a, $01
	ld [wMenuCursorMoving], a
	ld hl, wMenuScanlineScrollTable
	ld d, $00
	ld e, $08
Jump_01_4C55:
	ld a, $00
	ld [hli], a
	ld a, [wMenuCursorY]
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
	ld [wMenuCursorMoving], a
	pop hl
	pop de
	pop bc
	pop af
	ret


GetMenuChoiceRecord:
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


ActivateMenuChoice:
	call GetMenuChoiceRecord
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
	ld [wPlayerObjectType], a
	ld a, [wMenuGridRow]
	ld b, a
	add a, a
	add a, b
	ld b, a
	ld a, [wMenuGridColumn]
	add a, b
	ld [$CA06], a
	call ResetScore
	call ResetPlayerLives
	pop hl
	jr Jump_01_4D14

Jump_01_4CDD:
	cp $0F
	jr nz, Jump_01_4CFD
	ld a, [wGameStartMode]
	cp $02
	jr z, Jump_01_4CF7
	ld a, $00
	ld [wGameStartMode], a
	xor a
	ld [$CA06], a
	call ResetScore
	call ResetPlayerLives
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
	ld [wMenuCursorChoice], a
Jump_01_4D14:
	ret


SetMenuCursorChoice:
	call GetMenuChoiceRecord
	cp $FF
	jr nz, Jump_01_4D20
	ld a, e
	call GetMenuChoiceRecord
Jump_01_4D20:
	ld [wMenuCursorChoice], a
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
	ld [wMenuCursorTargetY], a
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
	ld a, [wMenuCursorChoice]
	call GetMenuChoiceRecord
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
	ld a, [wMenuCursorChoice]
	jr Jump_01_4D71

Jump_01_4D70:
	ret

Jump_01_4D71:
	call ActivateMenuChoice
	ret

Jump_01_4D75:
	ld e, $0A
	call Audio_QueueSound
	ld a, [wMenuCursorChoice]
	ld e, a
	inc a
	jr Jump_01_4D90

Jump_01_4D81:
	ld e, $0A
	call Audio_QueueSound
	ld a, [wMenuCursorChoice]
	dec a
	jr nz, Jump_01_4D8E
	ld a, $01
Jump_01_4D8E:
	jr Jump_01_4D90

Jump_01_4D90:
	call SetMenuCursorChoice
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
	call ApplyOptionsSettings
	ld a, $01
Jump_01_4DB9:
	call DrawOptionsEntryValue
	cp $FF
	jr nz, Jump_01_4DB9
	ret

Jump_01_4DC1:
	ret

Jump_01_4DC2:
	call ApplyOptionsSettings
	ld a, $00
	call ActivateMenuChoice
	ret

Jump_01_4DCB:
	jr Jump_01_4DC2

Jump_01_4DCD:
	ld e, $0A
	call Audio_QueueSound
	ld b, $FF
	call AdjustOptionValue
	jr Jump_01_4DB4

Jump_01_4DD9:
	ld e, $0A
	call Audio_QueueSound
	ld b, $01
	call AdjustOptionValue
	jr Jump_01_4DB4

Jump_01_4DE5:
	ld e, $0B
	call Audio_QueueSound
	ld a, [wMenuCursorChoice]
	ld e, a
	inc a
	jr Jump_01_4E00

Jump_01_4DF1:
	ld e, $0B
	call Audio_QueueSound
	ld a, [wMenuCursorChoice]
	dec a
	jr nz, Jump_01_4DFE
	ld a, $01
Jump_01_4DFE:
	jr Jump_01_4E00

Jump_01_4E00:
	call SetMenuCursorChoice
	ret


AdjustOptionValue:
	push bc
	ld a, [wMenuCursorChoice]
	call GetMenuChoiceValueInfo
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

ApplyOptionsSettings:
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
	ld [wActiveSkillLevel], a
	ret


LoadOptionsSettings:
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
	ld a, [wActiveSkillLevel]
	ld [wSkillSetting], a
	ret


InitMenuCursorForState:
	ld a, [wMenuState]
	ld l, a
	ld a, [wMenuState + 1]
	ld h, a
	ld a, [hl]
	cp $03
	jr nz, Jump_01_4E9D
Jump_01_4E9D:
	xor a
	ld [wMenuScanlineScrollEnabled], a
	ld a, $01
	call GetMenuChoiceRecord
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
	ld [wMenuCursorY], a
	ld [wMenuCursorTargetY], a
	ld a, $01
	call UpdateMenuCursorPosition
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


SetOptionLabelBgPalette7Colors:
Func_01_4ECF: ; legacy alias (automatic entry label)
	push af
	push bc
	push de
	push hl
	ld bc, $4E91 ; RGB555 colour value passed to Func_0514 (not an address)
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


GetMenuChoiceValueInfo:
	call GetMenuChoiceRecord
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

Bank01Data_4F00:
	db $01, $00, $02, $00, $04, $00, $08, $00, $16, $00, $32, $00, $64, $00, $28, $01
Bank01Data_4F10:
	db $01, $00, $00, $02, $00, $00, $04, $00, $00, $08, $00, $00, $16, $00, $00, $32
	db $00, $00, $64, $00, $00, $28, $01, $00, $56, $02, $00, $12, $05, $00, $24, $10
	db $00, $48, $20, $00, $96, $40, $00, $92, $81, $00, $84, $63, $01, $68, $27, $03
Bank01Data_4F40:
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

DrawOptionsEntryLabel:
	call GetMenuChoiceRecord
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
	ld [wTextRow], a
	ld a, $04
	ld [wTextColumn], a
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
	call SetOptionLabelBgPalette7Colors
	call DrawEncodedText
Jump_01_5010:
	pop af
	inc a
	ret


DrawOptionsEntryValue:
	call GetMenuChoiceRecord
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
	ld [wTextRow], a
	ld a, $0C
	ld [wTextColumn], a
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
	ld hl, OptionsOffText
	jr Jump_01_5079

Jump_01_504C:
	ld hl, OptionsOnText
	jr Jump_01_5079

Jump_01_5051:
	ld a, e
	cp $03
	jr nz, Jump_01_5066
	ld a, [hl]
	add a, a
	add a, a
	add a, a
	ld hl, ControlTypeTexts
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
	ld hl, SkillTexts
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
Jump_01_5079:
	call DrawEncodedText
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
	call DrawPasswordEntryChars
	ld a, [$C6B7]
	and $03
	jr nz, Jump_01_50B0
	call CycleObjectPalettes12
Jump_01_50B0:
	ret

Jump_01_50B1:
	ret

Jump_01_50B2:
	call MovePasswordCursorOffscreen
	ld a, $00
	call ActivateMenuChoice
	ret

Jump_01_50BB:
	ld e, $07
	call Audio_QueueSound
	call SubmitEnteredCode
	ret

Jump_01_50C4:
	ld a, [wPasswordSelectedChar]
	dec a
	bit 5, a
	jr z, Jump_01_50CE
	ld a, $1F
Jump_01_50CE:
	ld [wPasswordSelectedChar], a
	call StorePasswordCharWithSound
	jr Jump_01_5114

Jump_01_50D6:
	ld a, [wPasswordSelectedChar]
	inc a
	bit 5, a
	jr z, Jump_01_50DF
	xor a
Jump_01_50DF:
	ld [wPasswordSelectedChar], a
	call StorePasswordCharWithSound
	jr Jump_01_5114

Jump_01_50E7:
	ld e, $0B
	call Audio_QueueSound
	ld a, [wPasswordCursorIndex]
	dec a
	cp $FF
	jr nz, Jump_01_50F6
	ld a, $04
Jump_01_50F6:
	ld [wPasswordCursorIndex], a
	call SetPasswordCursorTargetX
	jr Jump_01_5114

Jump_01_50FE:
	ld e, $0B
	call Audio_QueueSound
	ld a, [wPasswordCursorIndex]
	inc a
	cp $05
	jr nz, Jump_01_510C
	xor a
Jump_01_510C:
	ld [wPasswordCursorIndex], a
	call SetPasswordCursorTargetX
	jr Jump_01_5114

Jump_01_5114:
	ld c, $00
	ld b, $0B
	call DrawPasswordEntryChars
	ld a, [$C6B7]
	and $03
	jr nz, Jump_01_5125
	call CycleObjectPalettes12
Jump_01_5125:
	ret


SubmitEnteredCode:
	ld hl, wPasswordEntryChars
	ld bc, wPasswordChars
	ld e, $05
	call CopyBytesShort
	call PackPasswordChars
	call DecodePasswordBits
	or a
	jr nz, Jump_01_5164
	call MovePasswordCursorOffscreen
	call ShowPasswordRejection
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
	call ActivateMenuChoice
	ret

Jump_01_5164:
	ld a, [wPasswordLevel]
	ld [$CA06], a
	ld a, [wPasswordLives]
	ld [wPlayerLives], a
	ld a, [wPasswordScoreThousands]
	ld c, a
	ld a, [wPasswordScoreThousands + 1]
	ld b, a
	call Func_3BF7
	call AdvanceScoreThresholdIndex
	ld a, $02
	ld [wGameStartMode], a
	xor a
	ld [wMenuRenderedState], a
	ld a, $02
	call ActivateMenuChoice
	ret


AdvanceScoreThresholdIndex:
	ld hl, ScoreThresholdTable
	ld a, [wScoreThresholdIndex]
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
	ld a, [wScore + 3]
	cp b
	jr c, Jump_01_51CB
	jr nz, Jump_01_51C5
	ld a, [hld]
	ld b, a
	ld a, [wScore + 2]
	cp b
	jr c, Jump_01_51CB
	jr nz, Jump_01_51C5
	ld a, [hld]
	ld b, a
	ld a, [wScore + 1]
	cp b
	jr c, Jump_01_51CB
	jr nz, Jump_01_51C5
	ld a, [hld]
	ld b, a
	ld a, [wScore]
	cp b
	jr c, Jump_01_51CB
Jump_01_51C5:
	ld a, c
	ld [wScoreThresholdIndex], a
	jr AdvanceScoreThresholdIndex

Jump_01_51CB:
	ret


Bank01RomImage_51CC:
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
	jr nz, MenuState05SelectPrevious
	bit 0, e
	jr nz, MenuState05SelectNext
RAM_D733:
	ret

RAM_D734:
	ret

RAM_D735:
	ret

RAM_D736:
	xor a
	call ActivateMenuChoice
	ret

RAM_D73B:
	ld a, $02
	call ActivateMenuChoice
	ret

RAM_D741:
	ret

RAM_D742:
	ret

MenuState05SelectPrevious:
	ld e, $13
	call Audio_QueueSound
	ld a, $02
	ld [wMenuScrollDirection], a
	call ScrollSceneOutFillFromRight
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
	call LoadMenuState05Graphics
	call FillSceneBgRowsWithTrailingTile
	ld hl, $DC03
	ld a, l
	ld [$D564], a
	ld a, h
	ld [$D565], a
	ld a, $01
	ld [wMenuScrollDirection], a
	call ScrollSceneInFromRight
	xor a
	ld [wMenuScrollDirection], a
	jr RAM_D7C3

MenuState05SelectNext:
	ld e, $13
	call Audio_QueueSound
	ld a, $02
	ld [wMenuScrollDirection], a
	call ScrollSceneOutFillFromLeft
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
	call LoadMenuState05Graphics
	call FillSceneBgRowsWithTrailingTile
	ld hl, $DC03
	ld a, l
	ld [$D564], a
	ld a, h
	ld [$D565], a
	ld a, $01
	ld [wMenuScrollDirection], a
	call ScrollSceneInFromLeft
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
	call FadeOutSceneBackground
	call InstallMenuInterruptHandlers
	call DisableSceneWindow
	call LoadMenuCursorSprites
	call MovePasswordCursorOffscreen
	call ClearPasswordEntryChars
	xor a
	ld [wMenuGridRow], a
	ld [wMenuGridColumn], a
	call ActivateMenuChoice
	ret

Jump_01_52D7:
	ld e, $07
	call Audio_QueueSound
	ld a, $01
	ld [wGameStartMode], a
	ld a, [wMenuGridRow]
	ld b, a
	ld a, [wMenuGridColumn]
	ld c, a
	call RunMenuGridSceneScroll
	ld a, $02
	call ActivateMenuChoice
	ret

Jump_01_52F2:
	call QueueRandomGridSounds
	ld a, [wMenuGridRow]
	dec a
	call SetMenuGridRowWrapped
	ret

Jump_01_52FD:
	call QueueRandomGridSounds
	ld a, [wMenuGridRow]
	inc a
	call SetMenuGridRowWrapped
	ret

Jump_01_5308:
	ld e, $0B
	call Audio_QueueSound
	ld a, [wMenuGridColumn]
	inc a
	call SetMenuGridColumnClamped
	ret

Jump_01_5315:
	ld e, $0B
	call Audio_QueueSound
	ld a, [wMenuGridColumn]
	dec a
	call SetMenuGridColumnClamped
	ret

	db $C9

QueueRandomGridSounds:
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

SetMenuGridRowWrapped:
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
	call FadeOutSceneBackground
	call ShowMenuGridScene
	ret

SetMenuGridColumnClamped:
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
	call LoadScrollVariantForGridCell
	ret

LoadMenuCursorSprites:
	xor a
	ldh [rVBK], a
	ld bc, MenuCursorSpriteTiles
	ld a, $80
	ld e, $78
	ld d, $08
	call Func_0622
	ld bc, MenuCursorSpriteTileIds
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
	ld hl, MenuCursorObjectPalette
	ld b, $00
	call Func_0553
	call InitPasswordCursorOamSlots8To11
	call InitPasswordCursorOamSlots12To15
	ret


HideMenuCursorSprites:
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


EnableMenuCursorSpritesWaitVBlank:
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


SubtractBCFromHL:
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


InitMenuStateScreen:
	ld hl, MenuCursorObjectPalette
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
	call LoadMenuCursorSprites
	ld a, $01
	ld [wMenuCursorSpritesEnabled], a
	ld a, $00
	ldh [rSCX], a
	ld a, $01
	ld [wMenuScanlineScrollEnabled], a
	call LoadEncodedFontTilesToVram1
	call MovePasswordCursorOffscreen
	call LoadOptionsSettings
	ret

Jump_01_5480:
	ld a, $00
	ld [wMenuScanlineScrollEnabled], a
	call LoadPasswordScreenTilesAndCursor
	call SnapPasswordCursorSprites
	call LoadPasswordObjPalettes1And2
	call LoadPasswordBgPalettes4To7
	jr Jump_01_54E8

Jump_01_5493:
	call Func_3960
	ld a, $01
	ld [wMenuState05Selection], a
	call LoadMenuState05Graphics
	call FillSceneBgRowsWithTrailingTile
	ld hl, $DC03
	ld a, l
	ld [$D564], a
	ld a, h
	ld [$D565], a
	ld a, $01
	ld [wMenuScrollDirection], a
	call ScrollSceneInFromRight
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
	call InitSceneDisplay
	ld a, [wMenuGridRow]
	ld b, a
	ld a, [wMenuGridColumn]
	ld c, a
	call ShowMenuGridScene
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


UpdateMenuInputRepeat:
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


StepMenuScroll:
	ld a, [wMenuScrollDirection]
	or a
	jr z, Jump_01_565E
	ld d, a
	ld a, [wMenuScrollStep]
	ld e, a
	call Func_3A52
	ld a, d
	cp $01
	jr z, Jump_01_5630
	cp $02
	jr z, Jump_01_5647
Jump_01_5630:
	ld a, [wMenuScrollStep]
	inc a
	inc a
	ld [wMenuScrollStep], a
	cp $20
	jr c, Jump_01_565E
	ld a, $1F
	ld [wMenuScrollStep], a
	xor a
	ld [wMenuScrollDirection], a
	jr Jump_01_565E

Jump_01_5647:
	ld a, [wMenuScrollStep]
	dec a
	dec a
	ld [wMenuScrollStep], a
	cp $20
	jr c, Jump_01_565E
	ld a, $00
	ld [wMenuScrollStep], a
	xor a
	ld [wMenuScrollDirection], a
	jr Jump_01_565E

Jump_01_565E:
	ret


Bank01RomImage_565F:
	LOAD UNION "RAM code (callerless) $D7CA", WRAMX[$D7CA] ; copied from $01:565F
UnusedMenuRamNoOp:
	ret
	ENDL
	db $00

Bank01RomImage_5661:
	LOAD UNION "RAM code $D7CB", WRAMX[$D7CB] ; copied from $01:5661

LoadMenuState05Graphics:
RAM_D7CB: ; legacy alias, used by src/bank_2E.asm, tools/screen_data.py
	ld hl, MenuState05PictureDescriptors
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
	ld [wMenuScrollStep], a
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
	ld [wSceneBank], a
	inc hl
	inc hl
	inc hl
	ld a, [hli]
	ld [wSceneTileAttrPtrs], a
	ld a, [hli]
	ld [wSceneTileAttrPtrs + 1], a
	ld a, [hli]
	ld [wSceneTileAttrPtrs + 2], a
	ld a, [hli]
	ld [wSceneTileAttrPtrs + 3], a
	ret

	ENDL
	db $00

Bank01RomImage_5718:
	LOAD UNION "RAM code $D9CB", WRAMX[$D9CB] ; copied from $01:5718

LoadEncodedFontTilesToVram1:
RAM_D9CB: ; legacy alias, used by src/bank_08.asm, tools/bank08.py, tools/gen_bank08_asm.py
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $08
	ld [rROMB0], a
	ld a, $01
	ldh [rVBK], a
	ld e, $00
	ld d, $25
	ld a, $88
	ld bc, EncodedFontTiles
	call Func_0622
	call ClearTextCursor
	pop af
	ld [rROMB0], a
	ret

	ENDL
	db $00

Bank01RomImage_573A:
	LOAD UNION "RAM code $D91B", WRAMX[$D91B] ; copied from $01:573A

CopyBankedTilemapRectToBG:
	ld a, [wBankedBgSourceBank]
	ld b, a
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, b
	ld [rROMB0], a
	ld a, [wBgCopyRow]
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
	ld a, [wBgCopyColumn]
	add a, l
	ld l, a
	ld a, $12
	ld [wBgCopyRowsLeft], a
	ld a, [wBgCopyWidth]
	ld [wBgCopyColumnsLeft], a
	ld [$C94B], a
	ld a, [wBankedBgSourcePtrs]
	ld c, a
	ld a, [wBankedBgSourcePtrs + 1]
	ld b, a
	ld a, [wBankedBgSourcePtrs + 2]
	ld e, a
	ld a, [wBankedBgSourcePtrs + 3]
	ld d, a
RAM_D968:
	ld a, [$C94B]
	ld [wBgCopyColumnsLeft], a
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
	ld a, [wBgCopyColumnsLeft]
	dec a
	ld [wBgCopyColumnsLeft], a
	jr nz, RAM_D96E
	push hl
	ld a, [wBgCopyWidth]
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
	ld a, [wBgCopyWidth]
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
	ld a, [wBgCopyRowsLeft]
	dec a
	ld [wBgCopyRowsLeft], a
	jp nz, RAM_D968
	pop af
	ld [rROMB0], a
	ret

	ENDL

Bank01RomImage_57E1:
	LOAD UNION "RAM code $D88B", WRAMX[$D88B] ; copied from $01:57E1

RAM_D88B:
	ld hl, wBankedBgSourceBank
	ld a, [hli]
	ld b, a
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, b
	ld [rROMB0], a
	ld hl, wBgCopyRow
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
	ld [wBgCopyColumnsLeft], a
	ld hl, $C94B
	ld a, [hl]
	ld [wBgCopyRowsLeft], a
	ld hl, wBankedBgSourceBank
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
	ld [wBgCopyColumnsLeft], a
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
	ld a, [wBgCopyColumnsLeft]
	dec a
	ld [wBgCopyColumnsLeft], a
	or a
	jr nz, RAM_D8D6
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [wBgCopyRowsLeft]
	dec a
	ld [wBgCopyRowsLeft], a
	or a
	jr nz, RAM_D8D1
	pop af
	ld [rROMB0], a
	ret

	ENDL
	db $00

InstallMenuRamCode:
Func_01_5867: ; legacy alias, used by src/bank_00.asm
	ld de, $0000
	call InitSceneDisplay
	ld hl, Bank01RomImage_49CB
	ld de, $0096
	ld bc, $D56A
	call CopyBytes
	ld hl, Bank01RomImage_4A6D
	ld de, $00DC
	ld bc, $D62A
	call CopyBytes
	ld hl, Bank01RomImage_51CC
	ld de, $00BA
	ld bc, $D70A
	call CopyBytes
	ld hl, Bank01RomImage_565F
	ld de, $0001
	ld bc, $D7CA
	call CopyBytes
	ld hl, Bank01RomImage_5661
	ld de, $00B6
	ld bc, $D7CB
	call CopyBytes
	ld hl, Bank01RomImage_5718
	ld de, $0021
	ld bc, $D9CB
	call CopyBytes
	ld hl, Bank01RomImage_57E1
	ld de, $0085
	ld bc, $D88B
	call CopyBytes
	ld hl, Bank01RomImage_573A
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


; 8 tiles; LoadMenuCursorSprites -> VRAM $8780 (tiles $78-$7F)
MenuCursorSpriteTiles:
	INCBIN "assets/bank_01/menu_cursor_sprite_tiles.2bpp"

; OAM tile ids written by LoadMenuCursorSprites
MenuCursorSpriteTileIds:
	db $78, $79, $7A, $7B, $7C, $7D, $7E, $7F

; OBJ palette 0 colours 1-3 (LoadSingleObjectPalette)
MenuCursorObjectPalette:
	dw $001F, $03FF, $7C00

; read by LoadMenuState05Graphics (RAM_D7CB); index wMenuState05Selection 0-2
MenuState05PictureDescriptors:
	db BANK(MenuState05Picture0_Tiles)
	dw MenuState05Picture0_Tiles, Picture596D0_TileMap, Picture596D0_AttrMap, Picture596D0_Palettes
	db $40 ; palette bytes copied
	ds 6, $00 ; unread padding
	db BANK(MenuState05Picture1_Tiles)
	dw MenuState05Picture1_Tiles, Picture596D1_TileMap, Picture596D1_AttrMap, Picture596D1_Palettes
	db $40 ; palette bytes copied
	ds 6, $00 ; unread padding
	db BANK(MenuState05Picture2_Tiles)
	dw MenuState05Picture2_Tiles, Screen2E_TileMap, Screen2E_AttrMap, Screen2E_Palettes
	db $40 ; palette bytes copied
	ds 6, $00 ; unread padding

ScrollingTileRowDestinations:
	dw $9000, $9140, $9280, $93C0, $9500, $9640, $8800

; Each 16-byte scene record contains a graphics bank, a 255-tile source,
; 20x12 tile and attribute maps, a palette-table pointer and record count.
; The final six bytes of every record are reserved and zero.
SceneBackgroundDescriptors:
	db BANK(FixedScene00Tiles)
	dw FixedScene00Tiles, FixedScene00TileMap, FixedScene00Attributes, FixedScene00Palettes
	db $04
	ds 6, 0
	db BANK(FixedScene01Tiles)
	dw FixedScene01Tiles, FixedScene01TileMap, FixedScene01Attributes, FixedScene01Palettes
	db $05
	ds 6, 0
	db BANK(FixedScene02Tiles)
	dw FixedScene02Tiles, FixedScene02TileMap, FixedScene02Attributes, FixedScene02Palettes
	db $08
	ds 6, 0
	db BANK(FixedScene03Tiles)
	dw FixedScene03Tiles, FixedScene03TileMap, FixedScene03Attributes, FixedScene03Palettes
	db $08
	ds 6, 0
	db BANK(FixedScene04Tiles)
	dw FixedScene04Tiles, FixedScene04TileMap, FixedScene04Attributes, FixedScene04Palettes
	db $09
	ds 6, 0
	db BANK(FixedScene05Tiles)
	dw FixedScene05Tiles, FixedScene05TileMap, FixedScene05Attributes, FixedScene05Palettes
	db $08
	ds 6, 0
	db BANK(FixedScene06Tiles)
	dw FixedScene06Tiles, FixedScene06TileMap, FixedScene06Attributes, FixedScene06Palettes
	db $08
	ds 6, 0
	db BANK(FixedScene07Tiles)
	dw FixedScene07Tiles, FixedScene07TileMap, FixedScene07Attributes, FixedScene07Palettes
	db $08
	ds 6, 0
	db BANK(FixedScene08Tiles)
	dw FixedScene08Tiles, FixedScene08TileMap, FixedScene08Attributes, FixedScene08Palettes
	db $06
	ds 6, 0
	db BANK(FixedScene09Tiles)
	dw FixedScene09Tiles, FixedScene09TileMap, FixedScene09Attributes, FixedScene09Palettes
	db $08
	ds 6, 0
	db BANK(FixedScene10Tiles)
	dw FixedScene10Tiles, FixedScene10TileMap, FixedScene10Attributes, FixedScene10Palettes
	db $07
	ds 6, 0

SceneDescriptorIndexTable:
	db 6, 7, 8, 9, 10

; bank, 16-byte tile graphics, 40-byte index rows, last row index, palette
ScrollingSceneDescriptors:
	db BANK(ScrollScene00Tiles)
	dw ScrollScene00Tiles, ScrollScene00Rows
	db $23
	dw ScrollScene00Palette
	db BANK(ScrollScene01Tiles)
	dw ScrollScene01Tiles, ScrollScene01Rows
	db $28
	dw ScrollScene01Palette
	db BANK(ScrollScene02Tiles)
	dw ScrollScene02Tiles, ScrollScene02Rows
	db $23
	dw ScrollScene02Palette
	db BANK(ScrollScene03Tiles)
	dw ScrollScene03Tiles, ScrollScene03Rows
	db $25
	dw ScrollScene03Palette
	db BANK(ScrollScene04Tiles)
	dw ScrollScene04Tiles, ScrollScene04Rows
	db $25
	dw ScrollScene04Palette
	db BANK(ScrollScene05Tiles)
	dw ScrollScene05Tiles, ScrollScene05Rows
	db $1D
	dw ScrollScene05Palette
	db BANK(ScrollScene06Tiles)
	dw ScrollScene06Tiles, ScrollScene06Rows
	db $19
	dw ScrollScene06Palette
	db BANK(ScrollScene07Tiles)
	dw ScrollScene07Tiles, ScrollScene07Rows
	db $1A
	dw ScrollScene07Palette
	db BANK(ScrollScene08Tiles)
	dw ScrollScene08Tiles, ScrollScene08Rows
	db $1A
	dw ScrollScene08Palette
	db BANK(ScrollScene09Tiles)
	dw ScrollScene09Tiles, ScrollScene09Rows
	db $1A
	dw ScrollScene09Palette
	db BANK(ScrollScene10Tiles)
	dw ScrollScene10Tiles, ScrollScene10Rows
	db $19
	dw ScrollScene10Palette
	db BANK(ScrollScene11Tiles)
	dw ScrollScene11Tiles, ScrollScene11Rows
	db $1A
	dw ScrollScene11Palette
	db BANK(ScrollScene12Tiles)
	dw ScrollScene12Tiles, ScrollScene12Rows
	db $1A
	dw ScrollScene12Palette
	db BANK(ScrollScene13Tiles)
	dw ScrollScene13Tiles, ScrollScene13Rows
	db $1A
	dw ScrollScene13Palette
	db BANK(ScrollScene14Tiles)
	dw ScrollScene14Tiles, ScrollScene14Rows
	db $1A
	dw ScrollScene14Palette
	db BANK(ScrollScene15Tiles)
	dw ScrollScene15Tiles, ScrollScene15Rows
	db $1A
	dw ScrollScene15Palette
	db BANK(ScrollScene16Tiles)
	dw ScrollScene16Tiles, ScrollScene16Rows
	db $1A
	dw ScrollScene16Palette
	db BANK(ScrollScene17Tiles)
	dw ScrollScene17Tiles, ScrollScene17Rows
	db $1A
	dw ScrollScene17Palette
	db BANK(ScrollScene18Tiles)
	dw ScrollScene18Tiles, ScrollScene18Rows
	db $19
	dw ScrollScene18Palette
	db BANK(ScrollScene19Tiles)
	dw ScrollScene19Tiles, ScrollScene19Rows
	db $19
	dw ScrollScene19Palette
	db BANK(ScrollScene20Tiles)
	dw ScrollScene20Tiles, ScrollScene20Rows
	db $19
	dw ScrollScene20Palette
	db BANK(ScrollScene21Tiles)
	dw ScrollScene21Tiles, ScrollScene21Rows
	db $05
	dw ScrollScene21Palette
	db BANK(ScrollScene22Tiles)
	dw ScrollScene22Tiles, ScrollScene22Rows
	db $05
	dw ScrollScene22Palette
	db BANK(ScrollScene23Tiles)
	dw ScrollScene23Tiles, ScrollScene23Rows
	db $05
	dw ScrollScene23Palette
	db BANK(ScrollScene24Tiles)
	dw ScrollScene24Tiles, ScrollScene24Rows
	db $05
	dw ScrollScene24Palette
	db BANK(ScrollScene25Tiles)
	dw ScrollScene25Tiles, ScrollScene25Rows
	db $05
	dw ScrollScene25Palette
	db BANK(ScrollScene26Tiles)
	dw ScrollScene26Tiles, ScrollScene26Rows
	db $05
	dw ScrollScene26Palette
	db BANK(ScrollScene27Tiles)
	dw ScrollScene27Tiles, ScrollScene27Rows
	db $05
	dw ScrollScene27Palette
	db BANK(ScrollScene28Tiles)
	dw ScrollScene28Tiles, ScrollScene28Rows
	db $05
	dw ScrollScene28Palette
	db BANK(ScrollScene29Tiles)
	dw ScrollScene29Tiles, ScrollScene29Rows
	db $05
	dw ScrollScene29Palette
	db BANK(ScrollScene30Tiles)
	dw ScrollScene30Tiles, ScrollScene30Rows
	db $05
	dw ScrollScene30Palette
	db BANK(ScrollScene31Tiles)
	dw ScrollScene31Tiles, ScrollScene31Rows
	db $05
	dw ScrollScene31Palette
	db BANK(ScrollScene32Tiles)
	dw ScrollScene32Tiles, ScrollScene32Rows
	db $05
	dw ScrollScene32Palette
	db BANK(ScrollScene33Tiles)
	dw ScrollScene33Tiles, ScrollScene33Rows
	db $05
	dw ScrollScene33Palette
	db BANK(ScrollScene34Tiles)
	dw ScrollScene34Tiles, ScrollScene34Rows
	db $05
	dw ScrollScene34Palette
	db BANK(ScrollScene35Tiles)
	dw ScrollScene35Tiles, ScrollScene35Rows
	db $05
	dw ScrollScene35Palette

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

Bank01RomImage_5BBA:
	LOAD UNION "RAM code $D120", WRAMX[$D120] ; copied from $01:5BBA

EnableSceneWindow:
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

Bank01RomImage_5BCA:
	LOAD UNION "RAM code $D130", WRAMX[$D130] ; copied from $01:5BCA

DisableSceneWindow:
	ldh a, [rLCDC]
	res 4, a
	ldh [rLCDC], a
	ld a, $B4
	ldh [rWX], a
	ret

	ENDL
	db $00

Bank01RomImage_5BD6:
	LOAD UNION "RAM code $D140", WRAMX[$D140] ; copied from $01:5BD6

StepSceneWindowSplit:
	ldh a, [$FF86]
	or a
	jr z, RAM_D14B
	dec a
	ldh [$FF86], a
	ldh [rLYC], a
	ret

RAM_D14B:
	ldh [$FF86], a
	call Bank01RomImage_5F26
	call EnableSceneWindow
	ldh a, [$FF86]
	add a, $5F
	ldh [rLYC], a
	ret

	ENDL
	db $00

InitSceneDisplay:
Func_01_5BF1: ; legacy alias, used by src/bank_00.asm
	call Func_3960
	ld a, $01
	ldh [$FF83], a
	ldh [$FF97], a
	ldh [hSceneRasterFxEnabled], a
	xor a
	ldh [$FF84], a
	ldh [rLYC], a
	ldh [rSCX], a
	ldh [$FF95], a
	ldh [$FF8C], a
	ldh [hSceneLcdStepPending], a
	ldh [hSceneLcdStepPending], a
	ldh [$FFAB], a
	ldh [$FFB0], a
	ldh [hSceneTileSlot], a
	ldh [hSceneRowHdmaPending], a
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
	ldh [hSceneLcdStepLimit], a
	ldh a, [rLCDC]
	and $E3
	or $63
	ldh [rLCDC], a
	call InstallSceneInterruptHandlers
	call InstallSceneRamCode
	call ClearSceneVram
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


ClearSceneVram:
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


Bank01RomImage_5D77:
	LOAD UNION "RAM code $C729", WRAM0[$C729] ; copied from $01:5D77

SceneStatHandler:
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
	ldh a, [hSceneLcdStepPending]
	or a
	jr z, RAM_C75C
	ldh a, [hSceneRasterFxEnabled]
	or a
	jr z, RAM_C74A
	ldh a, [hSceneLcdStepLimit]
	ld b, a
	ldh a, [hSceneLcdStepIndex]
	cp b
	jr nz, RAM_C754
RAM_C74A:
	xor a
	ldh [hSceneLcdStepPending], a
	ldh [hSceneLcdStepIndex], a
	call WriteBgPalette7FromFFA0
	jr RAM_C75C
RAM_C754:
	ld b, a
	call Bank01RomImage_5EE0
	ld a, b
	inc a
	ldh [hSceneLcdStepIndex], a
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
	call WriteBgPalette7FromFF98
	call EnableSceneWindow
	ldh a, [$FF86]
	add a, $5F
	cp $8F
	jr nc, RAM_C784
	ldh [rLYC], a
	xor a
	ldh [hSceneLcdStepPending], a
	jr RAM_C7C3
RAM_C784:
	ld a, $8F
	ldh [rLYC], a
	xor a
	ldh [hSceneLcdStepPending], a
	jr RAM_C7C3
RAM_C78D:
	ldh a, [rSTAT]
	and $03
	jr nz, RAM_C78D
	ldh a, [hSceneRasterFxEnabled]
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
	call WriteBgPalette7FromFFA0
RAM_C7AD:
	call DisableSceneWindow
	ldh a, [$FF86]
	add a, $60
	add a, $08
	cp $8F
	jr nc, RAM_C7C0
	ld a, $01
	ldh [hSceneLcdStepPending], a
	jr RAM_C7C3
RAM_C7C0:
	xor a
	ldh [hSceneLcdStepPending], a
RAM_C7C3:
	pop hl
	pop de
	pop bc
	pop af
	reti
	ENDL

Bank01RomImage_5E16:
	LOAD UNION "RAM code $C7F1", WRAM0[$C7F1] ; copied from $01:5E16

SceneVBlankHandler:
	push af
	push de
	push bc
	push hl
	ldh a, [$FF80]
	or a
	jr nz, RAM_C7FD
	call StepSceneWindowSplit
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
	ldh a, [hSceneRowHdmaPending]
	or a
	jr z, RAM_C818
	xor a
	ldh [hSceneRowHdmaPending], a
	call StartSceneTileRowHdma
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

InstallSceneInterruptHandlers:
	push af
	push bc
	push de
	push hl
	di
	ld hl, Bank01RomImage_5D77
	ld de, $009F
	ld bc, $C729
	call CopyBytes
	ld hl, Bank01RomImage_5E16
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


Bank01RomImage_5E9C:
	LOAD UNION "RAM code $D270", WRAMX[$D270] ; copied from $01:5E9C

BuildScenePaletteFadeTable:
	xor a
	ldh [hScenePaletteBuildIndex], a
RAM_D273:
	ld hl, wScrollingSceneColours
	ldh a, [hScenePaletteBuildIndex]
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
	ld hl, wScenePaletteFadeTable
	ldh a, [hScenePaletteBuildIndex]
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
	ldh a, [hScenePaletteBuildIndex]
	inc a
	ldh [hScenePaletteBuildIndex], a
	cp $04
	jr c, RAM_D273
	ret

	ENDL
	db $00

Bank01RomImage_5EE0:
	LOAD UNION "RAM code $D2C0", WRAMX[$D2C0] ; copied from $01:5EE0

WriteBgPalette7FromD3F8:
	ld c, a
	ld a, $07
	sub c
	add a, a
	add a, a
	add a, a
	ld hl, wScenePaletteFadeTable
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

Bank01RomImage_5F0A:
	LOAD UNION "RAM code $D2F0", WRAMX[$D2F0] ; copied from $01:5F0A

WriteBgPalette7FromFFA0:
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

Bank01RomImage_5F26:
	LOAD UNION "RAM code $D310", WRAMX[$D310] ; copied from $01:5F26

WriteBgPalette7FromFF98:
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

Bank01RomImage_5F42:
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

Bank01RomImage_6057:
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
	ld bc, wScrollingSceneColours
	ld e, $08
	call CopyBytesShort
	call BuildScenePaletteFadeTable
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

RunScrollingScene:
Func_01_609A: ; legacy alias, used by src/bank_00.asm
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
	call ApplySceneTargetPalettes
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
	call AdvanceSceneScroll
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
	call FadeOutSceneBackground
	ld a, $01
	ldh [$FFAB], a
	ret


ClearSceneSplitPalettes:
Func_01_6133: ; legacy alias, used by src/bank_00.asm
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


ApplySceneTargetPalettes:
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


FadeInSceneBackground:
	ld a, $38
	ldh [hScenePaletteFadeOffset], a
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
	ld hl, wScenePaletteFadeTable
	ldh a, [hScenePaletteFadeOffset]
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	jr Jump_01_61A5

Jump_01_61A2:
	ld hl, wScrollingSceneColours
Jump_01_61A5:
	ld bc, $FFA0
	ld e, $08
Jump_01_61AA:
	ld a, [hli]
	ld [bc], a
	inc bc
	dec e
	jr nz, Jump_01_61AA
	ldh a, [hScenePaletteFadeOffset]
	sub $08
	ldh [hScenePaletteFadeOffset], a
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


FadeOutSceneBackground:
	push af
	push bc
	push de
	push hl
	ld a, $00
	ldh [hScenePaletteFadeOffset], a
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
	ldh a, [hSceneLcdStepLimit]
	dec a
	cp $FF
	jr nz, Jump_01_61F9
	xor a
Jump_01_61F9:
	ldh [hSceneLcdStepLimit], a
	ld hl, wScenePaletteFadeTable
	ldh a, [hScenePaletteFadeOffset]
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
	ldh a, [hScenePaletteFadeOffset]
	add a, $08
	ldh [hScenePaletteFadeOffset], a
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


ShowMenuGridScene:
	xor a
	ldh [hSceneRasterFxEnabled], a
	push bc
	ld a, b
	call LoadFixedSceneForRow
	pop bc
	call LoadScrollVariantForGridCell
	call FadeInSceneBackground
	ret


UnusedLoadScrollVariantForGridCell:
Func_01_6243: ; legacy alias (automatic entry label)
	call LoadScrollVariantForGridCell
	ret

RunMenuGridSceneScroll:
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
	ldh [hSceneTileSlot], a
	xor a
	ldh [hSceneRasterFxEnabled], a
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
	ldh [hSceneWaitCountdown], a
	call ApplySceneTargetPalettes
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
	call AdvanceSceneScroll
	ldh a, [$FF84]
	or a
	jr nz, Jump_01_62F6
	ld a, [$C6B5]
	and $80
	jr nz, Jump_01_62F6
	ld e, $24
	call Audio_QueueSound
	ldh a, [hSceneWaitCountdown]
	dec a
	ldh [hSceneWaitCountdown], a
	jr nz, Jump_01_62C7
Jump_01_62F6:
	ld a, $01
	ldh [$FFAB], a
	ld d, $FF
	call Func_3971
	call FadeOutSceneBackground
	call Func_04B6
	call Func_0051
	ret

LoadFixedSceneForRow:
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


LoadScrollVariantForGridCell:
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
	ldh [hSceneTileSlot], a
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
	ldh a, [hSceneTileSlot]
	ld e, a
	call DrawNextSceneRow
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


SelectLevelRowScene:
Func_01_63B3: ; legacy alias, used by src/bank_00.asm
	ld hl, LevelSceneGridCells
	add a, a
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	ld hl, LevelRowSceneIndexPairs
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


SelectLevelScene:
Func_01_63D1: ; legacy alias, used by src/bank_00.asm
	ld hl, LevelSceneGridCells
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


Bank01RomImage_6401:
	LOAD UNION "RAM code $D1B0", WRAMX[$D1B0] ; copied from $01:6401

AdvanceSceneScroll:
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
	call DrawNextSceneRow
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

Bank01RomImage_6432:
	LOAD UNION "RAM code $D1F0", WRAMX[$D1F0] ; copied from $01:6432

ComputeSceneRowPointer:
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

Bank01RomImage_6468:
	LOAD UNION "RAM code $D230", WRAMX[$D230] ; copied from $01:6468

GetSceneTileSourceAddress:
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

Bank01RomImage_648E:
	LOAD UNION "RAM code $D330", WRAMX[$D330] ; copied from $01:648E

DrawNextSceneRow:
	call ComputeSceneRowMapAddress
	call SelectSceneTileRowDestination
	call StageSceneRowTiles
	call WriteSceneRowTileIndices
	ld a, $01
	ldh [hSceneRowHdmaPending], a
	ldh a, [hSceneTileSlot]
	inc a
	cp $07
	jr c, RAM_D348
	xor a
RAM_D348:
	ldh [hSceneTileSlot], a
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

ComputeSceneRowMapAddress:
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

SelectSceneTileRowDestination:
	ldh a, [hSceneTileSlot]
	add a, a
	ld hl, ScrollingTileRowDestinations
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ldh [hSceneRowTileVramAddress], a
	ld a, [hl]
	ldh [hSceneRowTileVramAddress + 1], a
	ret

	db $00

Bank01RomImage_6505:
	LOAD UNION "RAM code $D370", WRAMX[$D370] ; copied from $01:6505

StageSceneRowTiles:
	call ComputeSceneRowPointer
	ldh a, [$FF92]
	ld a, a
	ld [rROMB0], a
	ld de, $0000
RAM_D37C:
	ldh a, [$FF8D]
	ld c, a
	ldh a, [$FF8E]
	ld b, a
	call GetSceneTileSourceAddress
	call CopySceneTileToStaging
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

Bank01RomImage_6538:
	LOAD UNION "RAM code $D3B0", WRAMX[$D3B0] ; copied from $01:6538

CopySceneTileToStaging:
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
	ld hl, wVramDmaStagingBuffer
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

WriteSceneRowTileIndices:
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

StartSceneTileRowHdma:
	ldh a, [hSceneRowTileVramAddress + 1]
	ldh [rHDMA3], a
	ldh a, [hSceneRowTileVramAddress]
	ldh [rHDMA4], a
	ld bc, wVramDmaStagingBuffer
	ld a, b
	ldh [rHDMA1], a
	ld a, c
	ldh [rHDMA2], a
	xor a
	ldh [rVBK], a
	ld a, $13
	ldh [rHDMA5], a
	ret


Bank01RomImage_6599:
	LOAD UNION "RAM code (callerless) $D260", WRAMX[$D260] ; copied from $01:6599
UnusedSceneRamNoOp:
	ret
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

LevelRowSceneIndexPairs:
	db $01, $01, $02, $02, $03, $03, $04, $04, $05, $05
LevelSceneGridCells:
	db $00, $00, $00, $01, $00, $02
	db $01, $00, $01, $01, $01, $02, $02, $00, $02, $01, $02, $02, $03, $00, $03, $01
	db $03, $02, $04, $00, $04, $01, $04, $02
LevelRowSceneFlags:
	db $01, $00, $00, $01, $00, $00, $01, $00
	db $00, $01, $00, $00, $01, $00, $00

InstallSceneRamCode:
Func_01_6618: ; legacy alias, used by src/bank_00.asm
	ld a, $01
	ldh [rSVBK], a
	ld hl, Bank01RomImage_5F42
	ld de, $0114
	ld bc, $D000
	call CopyBytes
	ld hl, Bank01RomImage_5BBA
	ld de, $000F
	ld bc, $D120
	call CopyBytes
	ld hl, Bank01RomImage_5BCA
	ld de, $000B
	ld bc, $D130
	call CopyBytes
	ld hl, Bank01RomImage_5BD6
	ld de, $001A
	ld bc, $D140
	call CopyBytes
	ld hl, Bank01RomImage_6057
	ld de, $0042
	ld bc, $D160
	call CopyBytes
	ld hl, Bank01RomImage_6401
	ld de, $0030
	ld bc, $D1B0
	call CopyBytes
	ld hl, Bank01RomImage_6432
	ld de, $0035
	ld bc, $D1F0
	call CopyBytes
	ld hl, Bank01RomImage_6468
	ld de, $0025
	ld bc, $D230
	call CopyBytes
	ld hl, Bank01RomImage_6599
	ld de, $0001
	ld bc, $D260
	call CopyBytes
	ld hl, Bank01RomImage_5E9C
	ld de, $0043
	ld bc, $D270
	call CopyBytes
	ld hl, Bank01RomImage_5EE0
	ld de, $0029
	ld bc, $D2C0
	call CopyBytes
	ld hl, Bank01RomImage_5F0A
	ld de, $001B
	ld bc, $D2F0
	call CopyBytes
	ld hl, Bank01RomImage_5F26
	ld de, $001B
	ld bc, $D310
	call CopyBytes
	ld hl, Bank01RomImage_648E
	ld de, $002C
	ld bc, $D330
	call CopyBytes
	ld hl, Bank01RomImage_6505
	ld de, $0032
	ld bc, $D370
	call CopyBytes
	ld hl, Bank01RomImage_6538
	ld de, $0029
	ld bc, $D3B0
	call CopyBytes
	ret

Bank01Data_66DD:
	db $00, $0A, $0E, $12, $01, $0B, $0F, $18, $02, $0C, $10, $13, $03, $0D, $11, $14
	db $04, $05, $15, $16, $06, $07, $17, $08, $09

LoadPasswordScreenTilesAndCursor:
Func_01_66F6: ; legacy alias (automatic entry label)
	push af
	push bc
	push de
	push hl
	push af
	ld a, $01
	ldh [rVBK], a
	ld bc, PasswordScreenTiles
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
	ld bc, PasswordScreenTiles
	ld a, $90
	ld d, $0C
	ld e, $00
	call Func_0622
	call LoadPasswordBgPalettes4To7
	xor a
	ld [wPasswordCursorIndex], a
	call LoadSelectedPasswordChar
	ld a, $0B
	ld [wGlyphRow], a
	ld a, [wPasswordCursorIndex]
	add a, a
	add a, a
	add a, a
	add a, $08
	ld [wPasswordCursorX], a
	ld [wPasswordCursorTargetX], a
	xor a
	ld [wPasswordCursorPaletteFrame], a
	pop af
	pop hl
	pop de
	pop bc
	pop af
	ret


LoadPasswordBgPalettes4To7:
Func_01_6746: ; legacy alias (automatic entry label)
	ld hl, PasswordBgPalettes
	ld b, $04
	ld c, $04
	call Func_052F
	ret


LoadPasswordObjPalettes1And2:
Func_01_6751: ; legacy alias (automatic entry label)
	ld hl, PasswordObjPaletteColours
	ld b, $01
	call Func_0553
	ld hl, PasswordObjPaletteColours + $06
	ld b, $02
	call Func_0553
	ret


CycleObjectPalettes12:
	ld d, $0D
	ld a, [wPasswordCursorPaletteFrame]
	cp d
	jr nz, Jump_01_676C
	ld a, $FF
Jump_01_676C:
	inc a
	ld [wPasswordCursorPaletteFrame], a
	add a, a
	add a, a
	add a, a
	ld hl, ObjectPaletteCycleTable
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


BuildGlyphTileAttrBuffer:
Func_01_6789: ; legacy alias (automatic entry label)
	ld d, $00
	bit 7, a
	jr nz, BuildGlyph_HaveIndex
	add a, $02
	ld d, $08
BuildGlyph_HaveIndex:
	res 7, a
	push af
	add a, a
	add a, a
	ld hl, PasswordGlyphTiles
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld e, $04
	ld bc, wGlyphTileBuffer
	inc bc
BuildGlyph_TileLoop:
	ld a, [hli]
	bit 7, a
	jr z, BuildGlyph_TileSub8
	cp $89
	jr c, BuildGlyph_TileSub80
BuildGlyph_TileSub8:
	sub $08
	jr BuildGlyph_StoreTile

BuildGlyph_TileSub80:
	sub $80
BuildGlyph_StoreTile:
	ld [bc], a
	inc bc
	inc bc
	dec e
	jr nz, BuildGlyph_TileLoop
	pop af
	add a, a
	add a, a
	ld hl, PasswordGlyphAttributes
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld e, $04
	ld bc, wGlyphTileBuffer
BuildGlyph_AttrLoop:
	ld a, [hli]
	or $0C
	ld [bc], a
	inc bc
	inc bc
	dec e
	jr nz, BuildGlyph_AttrLoop
	ret


Draw2x2GlyphTiles:
	push af
	push bc
	push de
	push hl
	call BuildGlyphTileAttrBuffer
	ld hl, $9800
	ld a, [wGlyphRow]
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
	ld a, [wGlyphColumn]
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
	ld bc, wGlyphTileBuffer
	ld a, [bc]
	ld [hl], a
	xor a
	ldh [rVBK], a
	ld bc, wGlyphTileBuffer + 1
	ld a, [bc]
	ld [hli], a
	inc a
	ld d, a
	ld a, $01
	ldh [rVBK], a
	ld bc, wGlyphTileBuffer + 2
	ld a, [bc]
	ld [hl], a
	xor a
	ldh [rVBK], a
	ld bc, wGlyphTileBuffer + 3
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
	ld bc, wGlyphTileBuffer + 4
	ld a, [bc]
	ld [hl], a
	xor a
	ldh [rVBK], a
	ld bc, wGlyphTileBuffer + 5
	ld a, [bc]
	ld [hli], a
	inc a
	ld d, a
	ld a, $01
	ldh [rVBK], a
	ld bc, wGlyphTileBuffer + 6
	ld a, [bc]
	ld [hl], a
	xor a
	ldh [rVBK], a
	ld bc, wGlyphTileBuffer + 7
	ld a, [bc]
	ld [hl], a
	pop hl
	pop de
	pop bc
	pop af
	ret


DrawPasswordEntryChars:
	ld a, b
	ld [wGlyphRow], a
	ld e, $05
Jump_01_6879:
	push de
	ld hl, PasswordCharColumns
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
	ld [wGlyphColumn], a
	ld a, e
	dec a
	ld hl, wPasswordEntryChars
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
	call Draw2x2GlyphTiles
	pop de
	dec e
	jr nz, Jump_01_6879
	ret


DrawScoreDigitsAtRow:
	ld [wGlyphRow], a
	ld a, [wScore]
	ld c, a
	ld a, [wScore + 1]
	ld b, a
	ld a, [wScore + 2]
	ld e, a
	ld a, [wScore + 3]
	ld d, a
	ld hl, $FFB0
	call Func_06E7
	ld hl, ScoreDigitColumns
	xor a
	ldh [hScoreDigitsStarted], a
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
	ldh [hScoreDigitsStarted], a
Jump_01_68E7:
	ld a, d
	or a
	jr nz, Jump_01_68F2
	ldh a, [hScoreDigitsStarted]
	or a
	jr nz, Jump_01_68F2
	jr Jump_01_68FE

Jump_01_68F2:
	ld a, [hl]
	ld [wGlyphColumn], a
	ld a, d
	and $0F
	or $80
	call Draw2x2GlyphTiles
Jump_01_68FE:
	inc hl
	dec e
	jr nz, Jump_01_68CF
	ld a, [hl]
	ld [wGlyphColumn], a
	ld a, [bc]
	and $0F
	or $80
	call Draw2x2GlyphTiles
	ret


DrawLivesDigitsAtRow:
	ld [wGlyphRow], a
	ld hl, LivesDigitColumns
	ld a, [hli]
	ld [wGlyphColumn], a
	ld a, [wPlayerLives]
	ld b, a
	ld hl, $FFB0
	call Func_06C5
	ldh a, [$FFB1]
	ld d, a
	swap a
	and $0F
	jr z, Jump_01_6931
	or $80
	call Draw2x2GlyphTiles
Jump_01_6931:
	ld a, [LivesDigitColumns + $01]
	ld [wGlyphColumn], a
	ld a, d
	and $0F
	or $80
	call Draw2x2GlyphTiles
	ret


StorePasswordCharWithSound:
	push de
	ld e, $0A
	call Audio_QueueSound
	pop de
	call Audio_QueueSound
	ld a, [wPasswordCursorIndex]
	ld hl, wPasswordEntryChars
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [wPasswordSelectedChar]
	ld [hl], a
	ret


LoadSelectedPasswordChar:
	ld a, [wPasswordCursorIndex]
	ld hl, wPasswordEntryChars
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	ld [wPasswordSelectedChar], a
	ret


InitPasswordCursorOamSlots8To11:
Func_01_696E: ; legacy alias (automatic entry label)
	ld bc, Bank01SpriteTiles7871
	ld a, $80
	ld d, $04
	ld e, $74
	call Func_0622
	ld e, $74
	ld d, $02
	ld hl, $FE20
InitPwCursorOam8Loop:
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
	jr nz, InitPwCursorOam8Loop
	ld d, $02
	ld hl, $FE28
InitPwCursorOam10Loop:
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
	jr nz, InitPwCursorOam10Loop
	ret


StepPasswordCursorSprites:
	push hl
	push de
	push bc
	ld a, [wPasswordCursorTargetX]
	ld b, a
	ld a, [wPasswordCursorX]
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
	ld [wPasswordCursorX], a
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


InitPasswordCursorOamSlots12To15:
Func_01_6A1D: ; legacy alias (automatic entry label)
	ld bc, Bank01SpriteTiles78B1
	ld a, $80
	ld d, $04
	ld e, $70
	call Func_0622
	ld e, $70
	ld d, $02
	ld hl, $FE30
InitPwCursorOam12WaitBusy:
	ldh a, [rSTAT]
	and $02
	jr z, InitPwCursorOam12WaitBusy
InitPwCursorOam12WaitFree:
	ldh a, [rSTAT]
	and $02
	jr nz, InitPwCursorOam12WaitFree
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
	jr nz, InitPwCursorOam12WaitBusy
	ld d, $02
	ld hl, $FE38
InitPwCursorOam14WaitBusy:
	ldh a, [rSTAT]
	and $02
	jr z, InitPwCursorOam14WaitBusy
InitPwCursorOam14WaitFree:
	ldh a, [rSTAT]
	and $02
	jr nz, InitPwCursorOam14WaitFree
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
	jr nz, InitPwCursorOam14WaitBusy
	ret


SetPasswordCursorTargetX:
	ld hl, PasswordCharColumns
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
	ld [wPasswordCursorTargetX], a
	call LoadSelectedPasswordChar
	ret


SnapPasswordCursorSprites:
	push af
	push bc
	push de
	push hl
	ld a, [wPasswordCursorIndex]
	add a, a
	ld hl, PasswordCharColumns
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
	ld [wPasswordCursorX], a
	ld [wPasswordCursorTargetX], a
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


MovePasswordCursorOffscreen:
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


PasswordBitsWriteNext:
	push hl
	push de
	push bc
	ld e, a
	ld hl, Bank01Data_66DD
	ld a, [wPasswordBitIndex]
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
	ld bc, wPasswordBits
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
	ld a, [wPasswordBitIndex]
	inc a
	ld [wPasswordBitIndex], a
	pop bc
	pop de
	pop hl
	ret


PasswordBitsReadPrev:
	push hl
	push de
	push bc
	ld hl, Bank01Data_66DD
	ld a, [wPasswordBitIndex]
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
	ld bc, wPasswordBits
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
	ld a, [wPasswordBitIndex]
	dec a
	ld [wPasswordBitIndex], a
	ld a, d
	pop bc
	pop de
	pop hl
	ret


ClearPasswordBits:
	ld hl, wPasswordBits
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [wPasswordBitIndex], a
	ret


EncodePasswordFromProgress:
Func_01_6BBC: ; legacy alias, used by src/bank_00.asm
	ld a, [$CA06]
	inc a
	ldh [hPasswordLevelNumber], a
	call ClearPasswordBits
	call Func_3BE6
	ld a, c
	ld [wPasswordScoreThousands], a
	ld a, b
	ld [wPasswordScoreThousands + 1], a
	ld a, [wPlayerLives]
	and $0F
	ld [wPasswordLives], a
	ldh a, [hPasswordLevelNumber]
	and $0F
	ld [wPasswordLevel], a
	call ComputePasswordChecksum
	ld e, $0A
Jump_01_6BE4:
	ld a, c
	and $01
	call PasswordBitsWriteNext
	srl b
	rr c
	dec e
	jr nz, Jump_01_6BE4
	ld a, [wPlayerLives]
	ld d, a
	ld e, $04
Jump_01_6BF7:
	ld a, d
	and $01
	call PasswordBitsWriteNext
	srl d
	dec e
	jr nz, Jump_01_6BF7
	ldh a, [hPasswordLevelNumber]
	ld d, a
	ld e, $04
Jump_01_6C07:
	ld a, d
	and $01
	call PasswordBitsWriteNext
	srl d
	dec e
	jr nz, Jump_01_6C07
	ld a, [wPasswordChecksum]
	ld e, $07
	ld d, a
Jump_01_6C18:
	ld a, d
	and $01
	call PasswordBitsWriteNext
	srl d
	dec e
	jr nz, Jump_01_6C18
	ret


DecodePasswordBits:
Func_01_6C24: ; legacy alias, used by src/bank_2C.asm
	ld a, $18
	ld [wPasswordBitIndex], a
	ld e, $07
	ld c, $00
Jump_01_6C2D:
	call PasswordBitsReadPrev
	or c
	sla a
	ld c, a
	dec e
	jr nz, Jump_01_6C2D
	srl c
	ld a, c
	ld [wPasswordChecksum], a
	ld e, $04
	ld c, $00
Jump_01_6C41:
	call PasswordBitsReadPrev
	or c
	sla a
	ld c, a
	dec e
	jr nz, Jump_01_6C41
	srl c
	ld a, c
	ld [wPasswordLevel], a
	ld b, $0E
	cp b
	jr c, Jump_01_6C58
	jr nz, Jump_01_6C98
Jump_01_6C58:
	ld e, $04
	ld c, $00
Jump_01_6C5C:
	call PasswordBitsReadPrev
	or c
	sla a
	ld c, a
	dec e
	jr nz, Jump_01_6C5C
	srl c
	ld a, c
	ld [wPasswordLives], a
	ld bc, $0000
	ld e, $0A
Jump_01_6C71:
	call PasswordBitsReadPrev
	or c
	ld c, a
	sla c
	rl b
	dec e
	jr nz, Jump_01_6C71
	srl b
	rr c
	ld a, c
	ld [wPasswordScoreThousands], a
	ld a, b
	ld [wPasswordScoreThousands + 1], a
	ld a, [wPasswordChecksum]
	ld d, a
	call ComputePasswordChecksum
	ld a, [wPasswordChecksum]
	cp d
	ld a, $01
	jr z, Jump_01_6CA5
Jump_01_6C98:
	xor a
	ld [wPasswordScoreThousands], a
	ld [wPasswordScoreThousands + 1], a
	ld [wPasswordLives], a
	ld [wPasswordLevel], a
Jump_01_6CA5:
	ret


ComputePasswordChecksum:
	push af
	push de
	push bc
	ld d, $05
	ld a, [wPasswordLevel]
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
	ld a, [wPasswordLives]
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
	ld a, [wPasswordScoreThousands]
	ld c, a
	ld a, [wPasswordScoreThousands + 1]
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
	ld [wPasswordChecksum], a
	pop bc
	pop de
	pop af
	ret


ShowEarnedPasswordScreen:
Func_01_6CF0: ; legacy alias, used by src/bank_00.asm
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
	call LoadPasswordScreenTilesAndCursor
	call LoadPasswordBgPalettes4To7
	call UnpackPasswordChars
	ld hl, wPasswordChars
	ld bc, wPasswordEntryChars
	ld e, $05
	call CopyBytesShort
	ld c, $01
	ld b, $0E
	call DrawPasswordEntryChars
	ld a, $04
	call DrawScoreDigitsAtRow
	ld a, $07
	call DrawLivesDigitsAtRow
	ret


UnpackPasswordChars:
	ld a, [wPasswordBits]
	ld c, a
	ld a, [wPasswordBits + 1]
	ld b, a
	ld a, [wPasswordBits + 2]
	ld l, a
	ld a, [wPasswordBits + 3]
	ld h, a
	ld d, $05
Jump_01_6D5A:
	push hl
	ld hl, wPasswordChars
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


PackPasswordChars:
	call ClearPasswordBits
	ld a, [wPasswordBits]
	ld c, a
	ld a, [wPasswordBits + 1]
	ld b, a
	ld a, [wPasswordBits + 2]
	ld l, a
	ld a, [wPasswordBits + 3]
	ld h, a
	ld d, $05
Jump_01_6DAE:
	push hl
	ld hl, wPasswordChars
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
	ld [wPasswordBits], a
	ld a, b
	ld [wPasswordBits + 1], a
	ld a, l
	ld [wPasswordBits + 2], a
	ld a, h
	ld [wPasswordBits + 3], a
	ret


ClearScoreThenIncrementForever:
Func_01_6E01: ; legacy alias (automatic entry label)
	xor a
	ld [wScore], a
	ld [wScore + 1], a
	ld [wScore + 2], a
	ld [wScore + 3], a
ClearScoreThenIncrementForever_Loop:
	call Func_3BE6
	ld a, [wScore]
	ld e, a
	ld a, [wScore + 1]
	ld d, a
	ld a, [wScore + 2]
	ld c, a
	ld a, [wScore + 3]
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
	ld [wScore], a
	ld a, d
	ld [wScore + 1], a
	ld a, c
	ld [wScore + 2], a
	ld a, b
	ld [wScore + 3], a
	jr ClearScoreThenIncrementForever_Loop

	db $C9

ShowScreenMode12WithPasswordScoreLives:
Func_01_6E44: ; legacy alias (automatic entry label)
	call Func_3960
	call Func_035C
	xor a
	ld [wVBlankPending], a
ShowScreenMode12_WaitVBlank1:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, ShowScreenMode12_WaitVBlank1
	xor a
	ld [wVBlankPending], a
	ld a, $0C
	call ScreenTable_CallInit
	xor a
	ld [wVBlankPending], a
ShowScreenMode12_WaitVBlank2:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, ShowScreenMode12_WaitVBlank2
	xor a
	ld [wVBlankPending], a
	ld bc, $0000
	ld a, $0C
	call ScreenTable_CallUpdate
	call LoadPasswordScreenTilesAndCursor
	call LoadPasswordBgPalettes4To7
	ld a, $08
	call DrawScoreDigitsAtRow
	ld a, $0C
	call DrawLivesDigitsAtRow
	ret


; LoadPasswordScreenTilesAndCursor copies 12 tiles from here and $80 tiles from +$80; the second copy runs on into the glyph tables
PasswordScreenTiles:
	INCBIN "assets/bank_01/password_screen_tiles.2bpp"

; 34 x 4 tile indices per glyph (BuildGlyphTileAttrBuffer)
PasswordGlyphTiles:
	db $81, $82, $83, $84
	db $85, $86, $87, $88
	db $89, $8A, $8B, $8C
	db $8D, $8E, $8F, $90
	db $91, $92, $93, $94
	db $95, $96, $97, $98
	db $99, $9A, $9B, $9C
	db $9D, $9E, $9F, $A0
	db $A1, $8E, $A2, $A3
	db $A4, $A5, $A6, $A7
	db $95, $A8, $A9, $AA
	db $AB, $AC, $AD, $AE
	db $AF, $B0, $B1, $B2
	db $B3, $B4, $B5, $B6
	db $AB, $B7, $B8, $B9
	db $BA, $BB, $B5, $BC
	db $BD, $BE, $BF, $C0
	db $C1, $C2, $C3, $C4
	db $C5, $C6, $C7, $C8
	db $C9, $CA, $CB, $CC
	db $CD, $CE, $CF, $D0
	db $D1, $D2, $D3, $D4
	db $D5, $D6, $D7, $D8
	db $D1, $D2, $D9, $DA
	db $DB, $DC, $A6, $9C
	db $DD, $DE, $DF, $E0
	db $E1, $E2, $E3, $E4
	db $E5, $E6, $E7, $E8
	db $E9, $EA, $EB, $EC
	db $ED, $EE, $EF, $F0
	db $F1, $F2, $F3, $F4
	db $F5, $F6, $F7, $F8
	db $F9, $FA, $FB, $FC
	db $FD, $FE, $FF, $00

; 34 x 4 BG attributes, ORed with $0C (BuildGlyphTileAttrBuffer)
PasswordGlyphAttributes:
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $00, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $03, $03, $03, $03
	db $00, $00, $00, $00
	db $01, $01, $01, $01
	db $02, $02, $02, $02

; BG palettes 4-7 (LoadPasswordBgPalettes4To7)
PasswordBgPalettes:
	dw $0000, $0C64, $03E0, $02C0
	dw $0000, $0C64, $7E60, $61A0
	dw $0000, $0C64, $001F, $325F
	dw $0000, $0000, $0C64, $001F

; OBJ palettes 1 and 2, colours 1-3 (LoadPasswordObjPalettes1And2)
PasswordObjPaletteColours:
	dw $0BE0, $26E0, $1180
	dw $0BE0, $26E0, $1180

; Valid RGB555 records adjacent to the password palettes, but no reader found.
UnusedPasswordBgPalette:
	dw $0000, $7C00, $03E0, $001F
UnusedPasswordObjPaletteColours:
	dw $7C00, $03FF, $001F

; 14 x 8: bytes 0-5 = OBJ colours 1-3 for palettes 1 and 2, bytes 6-7 unread (CycleObjectPalettes12)
ObjectPaletteCycleTable:
	db $E0, $00, $00, $06, $20, $0F, $21, $00
	db $20, $01, $43, $12, $45, $1F, $21, $00
	db $60, $05, $87, $1E, $69, $2F, $21, $00
	db $80, $05, $EA, $2A, $8E, $3F, $00, $00
	db $C0, $09, $2D, $37, $92, $4F, $00, $00
	db $01, $0A, $70, $43, $B6, $5F, $00, $00
	db $41, $0E, $B3, $4F, $DB, $6F, $00, $00
	db $81, $0E, $F6, $5B, $FF, $7F, $00, $00
	db $41, $0E, $B3, $4F, $DB, $6F, $00, $00
	db $01, $0A, $70, $43, $B6, $5F, $00, $00
	db $C0, $09, $2D, $37, $92, $4F, $00, $00
	db $80, $05, $EA, $2A, $8E, $3F, $00, $00
	db $60, $05, $87, $1E, $69, $2F, $21, $00
	db $20, $01, $43, $12, $45, $1F, $21, $00

; 5 x 2 BG columns per character slot (DrawPasswordEntryChars)
PasswordCharColumns:
	db $05, $05
	db $07, $07
	db $09, $09
	db $0B, $0B
	db $0D, $0D

; Four unused (column, row) pairs following PasswordCharColumns.
UnusedPasswordColumnRowPairs:
	db $0F, $04, $11, $04, $13, $04, $15, $04

; BG columns for the score digits (DrawScoreDigitsAtRow)
ScoreDigitColumns:
	db $04, $06, $08, $0A, $0C, $0E

PasswordTablePadding:
	ds 3, $00

; BG columns for the lives digits (DrawLivesDigitsAtRow)
LivesDigitColumns:
	db $0C, $0E

; 4 tiles; InitPasswordCursorOamSlots8To11 -> VRAM $8740 (tiles $74-$77)
Bank01SpriteTiles7871:
	INCBIN "assets/bank_01/sprite_tiles_7871.2bpp"

; 4 tiles; InitPasswordCursorOamSlots12To15 -> VRAM $8700 (tiles $70-$73)
Bank01SpriteTiles78B1:
	INCBIN "assets/bank_01/sprite_tiles_78B1.2bpp"

FillBgRectWithTileAttr:
	ld a, [wBgCopyRow]
	swap a
	ld c, a
	ld b, $00
	sla c
	rl b
	ld hl, $9800
	add hl, bc
	ld a, [wBgCopyColumn]
	add a, l
	ld l, a
	ld a, [wBgCopyWidth]
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
	ld a, [wBgFillTileAttr + 1]
	ld [hl], a
	xor a
	ldh [rVBK], a
	ld a, [wBgFillTileAttr]
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

ShowPasswordRejection:
	ld a, $2C
	ld hl, wBankedBgSourceBank
	ld [hl], a
	ld a, $01
	ld hl, $C94B
	ld [hl], a
	ld e, $22
	call Audio_QueueSound
	ld a, $08
	ld [wBgRevealCounter], a
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
	ld hl, wBgCopyRow
	ld [hl], a
	ld a, [wBgRevealCounter]
	ld bc, CodeRejectedTileMap
	ld de, CodeRejectedAttrMap
	call SetBankedRowSourcePtrs
	call RAM_D88B
	ld a, [wBgRevealCounter]
	inc a
	add a, $09
	ld hl, wBgCopyRow
	ld [hl], a
	ld a, $09
	ld bc, CodeRejectedTileMap
	ld de, CodeRejectedAttrMap
	call SetBankedRowSourcePtrs
	call RAM_D88B
	ld a, [wBgRevealCounter]
	dec a
	ld [wBgRevealCounter], a
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

SetBankedRowSourcePtrs:
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
	ld hl, wBankedBgSourcePtrs
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	pop hl
	add hl, de
	ld d, h
	ld e, l
	ld hl, wBankedBgSourcePtrs + 2
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	ret


SetBankedSourcePtrsOffset:
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
	ld hl, wBankedBgSourcePtrs
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

FillSceneBgRowsWithTrailingTile:
Func_01_7BC5: ; legacy alias (automatic entry label)
	ld a, [wSceneBank]
	ld [wBankedBgSourceBank], a
	xor a
	ld [wBgCopyColumn], a
	ld a, $01
	ld [wBgCopyRow], a
	ld a, $20
	ld [wBgCopyWidth], a
	call Func_3C90
	call FillBgRectWithTileAttr
	ret

ScrollSceneInFromLeft:
Func_01_7BE0: ; legacy alias (automatic entry label)
	ld a, [wSceneBank]
	ld [wBankedBgSourceBank], a
	ld a, $14
	ld [wBgRevealCounter], a
	ld a, $01
	ld [wBgCopyRow], a
	ld [wBgCopyWidth], a
ScrollSceneInFromLeft_ColumnLoop:
	ld a, [wSceneTileAttrPtrs]
	ld c, a
	ld a, [wSceneTileAttrPtrs + 1]
	ld b, a
	ld a, [wSceneTileAttrPtrs + 2]
	ld e, a
	ld a, [wSceneTileAttrPtrs + 3]
	ld d, a
	ld a, [wBgRevealCounter]
	dec a
	call SetBankedSourcePtrsOffset
	ldh a, [rSCX]
	srl a
	srl a
	srl a
	dec a
	and $1F
	ld [wBgCopyColumn], a
	call CopyBankedTilemapRectToBG
	call Audio_Update
	xor a
	ld [wVBlankPending], a
ScrollSceneInFromLeft_WaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, ScrollSceneInFromLeft_WaitVBlank
	xor a
	ld [wVBlankPending], a
	ldh a, [rSCX]
	sub $08
	ldh [rSCX], a
	ld a, [wBgRevealCounter]
	dec a
	ld [wBgRevealCounter], a
	jr nz, ScrollSceneInFromLeft_ColumnLoop
	ret

ScrollSceneInFromRight:
Func_01_7C3F: ; legacy alias (automatic entry label)
	ld a, [wSceneBank]
	ld [wBankedBgSourceBank], a
	ld a, $14
	ld [wBgRevealCounter], a
	ld a, $01
	ld [wBgCopyRow], a
	ld [wBgCopyWidth], a
ScrollSceneInFromRight_ColumnLoop:
	ld a, [wSceneTileAttrPtrs]
	ld c, a
	ld a, [wSceneTileAttrPtrs + 1]
	ld b, a
	ld a, [wSceneTileAttrPtrs + 2]
	ld e, a
	ld a, [wSceneTileAttrPtrs + 3]
	ld d, a
	ld a, [wBgRevealCounter]
	ld l, a
	ld a, $14
	sub l
	call SetBankedSourcePtrsOffset
	ldh a, [rSCX]
	srl a
	srl a
	srl a
	add a, $14
	and $1F
	ld [wBgCopyColumn], a
	call CopyBankedTilemapRectToBG
	call Audio_Update
	xor a
	ld [wVBlankPending], a
ScrollSceneInFromRight_WaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, ScrollSceneInFromRight_WaitVBlank
	xor a
	ld [wVBlankPending], a
	ldh a, [rSCX]
	add a, $08
	ldh [rSCX], a
	ld a, [wBgRevealCounter]
	dec a
	ld [wBgRevealCounter], a
	jr nz, ScrollSceneInFromRight_ColumnLoop
	ret

ScrollSceneOutFillFromRight:
Func_01_7CA2: ; legacy alias (automatic entry label)
	ld a, [wSceneBank]
	ld [wBankedBgSourceBank], a
	ld a, $14
	ld [wBgRevealCounter], a
	ld a, $01
	ld [wBgCopyRow], a
	ld [wBgCopyWidth], a
ScrollSceneOutFillFromRight_FrameLoop:
	call Audio_Update
	xor a
	ld [wVBlankPending], a
ScrollSceneOutFillFromRight_WaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, ScrollSceneOutFillFromRight_WaitVBlank
	xor a
	ld [wVBlankPending], a
	call Func_3C90
	ldh a, [rSCX]
	srl a
	srl a
	srl a
	add a, $14
	and $1F
	ld [wBgCopyColumn], a
	call FillBgRectWithTileAttr
	ldh a, [rSCX]
	add a, $08
	ldh [rSCX], a
	ld a, [wBgRevealCounter]
	dec a
	ld [wBgRevealCounter], a
	jr nz, ScrollSceneOutFillFromRight_FrameLoop
	ret

	db $C9

ScrollSceneOutFillFromLeft:
Func_01_7CEF: ; legacy alias (automatic entry label)
	ld a, [wSceneBank]
	ld [wBankedBgSourceBank], a
	ld a, $14
	ld [wBgRevealCounter], a
	ld a, $01
	ld [wBgCopyRow], a
	ld [wBgCopyWidth], a
ScrollSceneOutFillFromLeft_FrameLoop:
	call Audio_Update
	xor a
	ld [wVBlankPending], a
ScrollSceneOutFillFromLeft_WaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, ScrollSceneOutFillFromLeft_WaitVBlank
	xor a
	ld [wVBlankPending], a
	call Func_3C90
	ldh a, [rSCX]
	srl a
	srl a
	srl a
	dec a
	and $1F
	ld [wBgCopyColumn], a
	call FillBgRectWithTileAttr
	ldh a, [rSCX]
	sub $08
	ldh [rSCX], a
	ld a, [wBgRevealCounter]
	dec a
	ld [wBgRevealCounter], a
	jr nz, ScrollSceneOutFillFromLeft_FrameLoop
	ret

FreeObjectsOutsideStatuses1And4:
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
	call FreeObjectRecord
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

Bank01ZeroFill: ; no reader; zero fill to the bank marker
	ds $7FFF - @, $00
	db BANK(@) ; ROM bank marker

; Relocation pins: ROM0 refers to these with raw numbers (src/bank_00.asm is not edited here).
	ASSERT BANK(ScoreThresholdTable) == $01 && ScoreThresholdTable == $418F, "raw pointer: ROM0 ld hl, $418F"
	ASSERT BANK(LevelRowSceneFlags) == $01 && LevelRowSceneFlags == $6609, "raw pointer: ROM0 ld hl, $6609"
