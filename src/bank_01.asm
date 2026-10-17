; BattleTanx (USA) - ROM bank $01

INCLUDE "include/banks_01_05_ram.inc"

SECTION "ROM Bank $01", ROMX[$4000], BANK[$01]

RunPauseHudSequence:
Func_01_4000: ; legacy alias, used by src/bank_00.asm
	xor a
	ldh [rNR51], a
	ld d, $08
RunPauseHudSequence_SlideInStep:
	xor a
	ld [wVBlankPending], a
RunPauseHudSequence_SlideInWaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, RunPauseHudSequence_SlideInWaitVBlank
	xor a
	ld [wVBlankPending], a
	ld b, $02
	call MoveHudWindow
	dec d
	jr nz, RunPauseHudSequence_SlideInStep
	call LoadPauseHudMapsFar
	ld d, $08
RunPauseHudSequence_SlideOutStep:
	xor a
	ld [wVBlankPending], a
RunPauseHudSequence_SlideOutWaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, RunPauseHudSequence_SlideOutWaitVBlank
	xor a
	ld [wVBlankPending], a
	ld b, $FE
	call MoveHudWindow
	dec d
	jr nz, RunPauseHudSequence_SlideOutStep
RunPauseHudSequence_PausedFrameLoop:
	xor a
	ld [wVBlankPending], a
RunPauseHudSequence_PausedWaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, RunPauseHudSequence_PausedWaitVBlank
	xor a
	ld [wVBlankPending], a
	call ProcessGameplayInput
	ld a, [wGamePaused]
	or a
	jp z, RunPauseHudSequence_Unpaused
	xor a
	ld [wVBlankPending], a
RunPauseHudSequence_PausedSpinVBlank:
	ld a, [wVBlankPending]
	or a
	jr z, RunPauseHudSequence_PausedSpinVBlank
	jp RunPauseHudSequence_PausedFrameLoop

RunPauseHudSequence_Unpaused:
	ld d, $08
RunPauseHudSequence_ResumeSlideInStep:
	xor a
	ld [wVBlankPending], a
RunPauseHudSequence_ResumeSlideInWaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, RunPauseHudSequence_ResumeSlideInWaitVBlank
	xor a
	ld [wVBlankPending], a
	ld b, $02
	call MoveHudWindow
	dec d
	jr nz, RunPauseHudSequence_ResumeSlideInStep
	call RefreshHud
	ld d, $08
RunPauseHudSequence_ResumeSlideOutStep:
	xor a
	ld [wVBlankPending], a
RunPauseHudSequence_ResumeSlideOutWaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, RunPauseHudSequence_ResumeSlideOutWaitVBlank
	xor a
	ld [wVBlankPending], a
	ld b, $FE
	call MoveHudWindow
	dec d
	jr nz, RunPauseHudSequence_ResumeSlideOutStep
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
LosePlayerLifeAndWaitForMusic_WaitLeaveLine14:
	ldh a, [rLY]
	cp $14
	jr z, LosePlayerLifeAndWaitForMusic_WaitLeaveLine14
LosePlayerLifeAndWaitForMusic_WaitLine14:
	ldh a, [rLY]
	cp $14
	jr nz, LosePlayerLifeAndWaitForMusic_WaitLine14
	call Audio_Update
	ld a, [wMusicEnabled]
	and a
	jr z, LosePlayerLifeAndWaitForMusic_Done
	ld a, [wMusicPtr]
	and a
	jr nz, LosePlayerLifeAndWaitForMusic_WaitLeaveLine14
LosePlayerLifeAndWaitForMusic_Done:
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
	ld hl, BcdPowersOfTwo16
	ld c, $08
ByteToBcd16_NextBit:
	rr b
	jr nc, ByteToBcd16_SkipBitEntry
	push bc
	push de
	ld c, $02
	ld b, $00
ByteToBcd16_AddDigitPairLoop:
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
	jr nz, ByteToBcd16_AddDigitPairLoop
	pop de
	pop bc
	jr ByteToBcd16_BitDone

ByteToBcd16_SkipBitEntry:
	inc l
	inc l
ByteToBcd16_BitDone:
	dec c
	jr nz, ByteToBcd16_NextBit
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
	ld hl, BcdPowersOfTwo24
	ld a, $02
	ldh [hBcdByteCounter], a
AddWordToBcd24_NextByte:
	pop bc
	ld c, $08
AddWordToBcd24_NextBit:
	rr b
	jr nc, AddWordToBcd24_SkipBitEntry
	push bc
	push de
	ld c, $03
	ld b, $00
AddWordToBcd24_AddDigitPairLoop:
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
	jr nz, AddWordToBcd24_AddDigitPairLoop
	pop de
	pop bc
	jr AddWordToBcd24_BitDone

AddWordToBcd24_SkipBitEntry:
	inc l
	inc l
	inc l
AddWordToBcd24_BitDone:
	dec c
	jr nz, AddWordToBcd24_NextBit
	ldh a, [hBcdByteCounter]
	dec a
	ldh [hBcdByteCounter], a
	jr nz, AddWordToBcd24_NextByte
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
	ld hl, BcdPowersOfTwo40
	ld a, $04
	ldh [hBcdByteCounter], a
LongToBcd40_NextByte:
	pop bc
	ld c, $08
LongToBcd40_NextBit:
	rr b
	jr nc, LongToBcd40_SkipBitEntry
	push bc
	push de
	ld c, $05
	ld b, $00
LongToBcd40_AddDigitPairLoop:
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
	jr nz, LongToBcd40_AddDigitPairLoop
	pop de
	pop bc
	jr LongToBcd40_BitDone

LongToBcd40_SkipBitEntry:
	inc l
	inc l
	inc l
	inc l
	inc l
LongToBcd40_BitDone:
	dec c
	jr nz, LongToBcd40_NextBit
	ldh a, [hBcdByteCounter]
	dec a
	ldh [hBcdByteCounter], a
	jr nz, LongToBcd40_NextByte
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
HudTopRowAttributes:
	db $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87
	db $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87
	db $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87
HudTopRowTiles:
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
	ld bc, HudTopRowAttributes
	call CopyMapRows20Wide
	ld d, $02
	ld hl, wVramDmaStagingBuffer + $40
	ld bc, HudTopRowTiles
	call CopyMapRows20Wide
	pop hl
	pop de
	pop bc
	pop af
	ret

PauseHudTopRowAttributes:
	db $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87
	db $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87
	db $87, $87, $87, $87, $87, $87, $87, $87
PauseHudTopRowTiles:
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
	ld bc, PauseHudTopRowAttributes
	call CopyMapRows20Wide
	ld d, $02
	ld hl, wVramDmaStagingBuffer + $40
	ld bc, PauseHudTopRowTiles
	call CopyMapRows20Wide
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
	ldh [hStatusCountStatus2], a
	ldh [hStatusCountNonZero], a
	ldh [hStatusCountStatus1], a
	ld d, $40
	ld hl, $D000
DrawObjectStatusCountsToWindow_ObjectLoop:
	ld a, l
	and $C0
	add a, $1D
	ld l, a
	ld a, [hl]
	ld e, a
	cp $02
	jr nz, DrawObjectStatusCountsToWindow_CheckNonZero
	ldh a, [hStatusCountStatus2]
	inc a
	ldh [hStatusCountStatus2], a
DrawObjectStatusCountsToWindow_CheckNonZero:
	ld a, e
	cp $00
	jr z, DrawObjectStatusCountsToWindow_CheckStatus1
	ldh a, [hStatusCountNonZero]
	inc a
	ldh [hStatusCountNonZero], a
DrawObjectStatusCountsToWindow_CheckStatus1:
	ld a, e
	cp $01
	jr nz, DrawObjectStatusCountsToWindow_NextObject
	ldh a, [hStatusCountStatus1]
	inc a
	ldh [hStatusCountStatus1], a
DrawObjectStatusCountsToWindow_NextObject:
	ld a, l
	and $C0
	add a, $40
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	dec d
	jr nz, DrawObjectStatusCountsToWindow_ObjectLoop
	ldh a, [hStatusCountNonZero]
	ld b, a
	ld hl, hStatusCountBcd
	call ConvertU8ToPackedBcdFar
	ld hl, $9C05
	ld c, $87
	ldh a, [hStatusCountBcd + 1]
	ld e, a
	swap a
	and $0F
	add a, $01
	ld b, a
	ld a, $01
	ldh [rVBK], a
DrawObjectStatusCountsToWindow_WaitField0Tens:
	ldh a, [rSTAT]
	and $02
	jr nz, DrawObjectStatusCountsToWindow_WaitField0Tens
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
DrawObjectStatusCountsToWindow_WaitField0Ones:
	ldh a, [rSTAT]
	and $02
	jr nz, DrawObjectStatusCountsToWindow_WaitField0Ones
	ld [hl], c
	xor a
	ldh [rVBK], a
	ld [hl], b
	inc l
	ldh a, [hStatusCountStatus2]
	ld b, a
	ld hl, hStatusCountBcd
	call ConvertU8ToPackedBcdFar
	ld hl, $9C08
	ld c, $87
	ldh a, [hStatusCountBcd + 1]
	ld e, a
	swap a
	and $0F
	add a, $01
	ld b, a
	ld a, $01
	ldh [rVBK], a
DrawObjectStatusCountsToWindow_WaitField1Tens:
	ldh a, [rSTAT]
	and $02
	jr nz, DrawObjectStatusCountsToWindow_WaitField1Tens
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
DrawObjectStatusCountsToWindow_WaitField1Ones:
	ldh a, [rSTAT]
	and $02
	jr nz, DrawObjectStatusCountsToWindow_WaitField1Ones
	ld [hl], c
	xor a
	ldh [rVBK], a
	ld [hl], b
	inc l
	ldh a, [hStatusCountStatus1]
	ld b, a
	ld hl, hStatusCountBcd
	call ConvertU8ToPackedBcdFar
	ld hl, $9C0B
	ld c, $87
	ldh a, [hStatusCountBcd + 1]
	ld e, a
	swap a
	and $0F
	add a, $01
	ld b, a
	ld a, $01
	ldh [rVBK], a
DrawObjectStatusCountsToWindow_WaitField2Tens:
	ldh a, [rSTAT]
	and $02
	jr nz, DrawObjectStatusCountsToWindow_WaitField2Tens
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
DrawObjectStatusCountsToWindow_WaitField2Ones:
	ldh a, [rSTAT]
	and $02
	jr nz, DrawObjectStatusCountsToWindow_WaitField2Ones
	ld [hl], c
	xor a
	ldh [rVBK], a
	ld [hl], b
	inc l
	ld a, [wUnwrittenStatusDisplayValue0]
	ld b, a
	ld hl, hStatusCountBcd
	call ConvertU8ToPackedBcdFar
	ld hl, $9C0E
	ld c, $87
	ldh a, [hStatusCountBcd + 1]
	ld e, a
	swap a
	and $0F
	add a, $01
	ld b, a
	ld a, $01
	ldh [rVBK], a
DrawObjectStatusCountsToWindow_WaitField3Tens:
	ldh a, [rSTAT]
	and $02
	jr nz, DrawObjectStatusCountsToWindow_WaitField3Tens
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
DrawObjectStatusCountsToWindow_WaitField3Ones:
	ldh a, [rSTAT]
	and $02
	jr nz, DrawObjectStatusCountsToWindow_WaitField3Ones
	ld [hl], c
	xor a
	ldh [rVBK], a
	ld [hl], b
	inc l
	ld a, [wUnwrittenStatusDisplayValue1]
	ld b, a
	ld hl, hStatusCountBcd
	call ConvertU8ToPackedBcdFar
	ld hl, $9C11
	ld c, $87
	ldh a, [hStatusCountBcd + 1]
	ld e, a
	swap a
	and $0F
	add a, $01
	ld b, a
	ld a, $01
	ldh [rVBK], a
DrawObjectStatusCountsToWindow_WaitField4Tens:
	ldh a, [rSTAT]
	and $02
	jr nz, DrawObjectStatusCountsToWindow_WaitField4Tens
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
DrawObjectStatusCountsToWindow_WaitField4Ones:
	ldh a, [rSTAT]
	and $02
	jr nz, DrawObjectStatusCountsToWindow_WaitField4Ones
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
	add a, OBJECT_HEALTH_OFFSET
	ld l, a
	ld a, [hl]
	ld c, a
	ld [hl], $00
AnimatePlayerHealthRefill_FrameLoop:
	xor a
	ld [wVBlankPending], a
AnimatePlayerHealthRefill_WaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, AnimatePlayerHealthRefill_WaitVBlank
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
	ld a, [wVBlankCounter]
	and $01
	jr nz, AnimatePlayerHealthRefill_FrameLoop
	ld a, l
	and $C0
	ld l, a
	ld b, $01
	call AddObjectHealth
	call DrawPlayerHealthBar
	ld a, l
	and $C0
	add a, OBJECT_HEALTH_OFFSET
	ld l, a
	ld a, [hl]
	cp c
	jr c, AnimatePlayerHealthRefill_FrameLoop
	pop bc
	pop hl
	ret

; Indexed by status-4 object +$1E (item type 0-9); the collector is the
; on-screen status-1 vehicle that DispatchNearbyStatus4Pickup found within 12 px
; (status +$1D == 4; the type at +$1E selects the entry).
Status4PickupHandlerTable:
EntityHandlerTable: ; legacy alias, used by tools/hints.py, tools/banks_01_05.py and reports
	dw PickupRestoreQuarterHealth
	dw PickupRestoreHalfHealth
	dw PickupStartRenderHideTimer
	dw PickupBonusScore3000
	dw PickupExtraLife
	dw PickupHomingProjectileCharges
	dw PickupProjectileSubtype1Charges
	dw PickupScreenEffectCharge
	dw PickupTriggerHudAlert
	dw PickupHandlerNoOp

DispatchStatus4PickupHandler:
DispatchEntityHandler: ; legacy alias
	push de
	push bc
	push hl
	push de
	push hl
	pop de
	ld a, l
	and $C0
	add a, OBJECT_TYPE_OFFSET
	ld l, a
	ld a, [hl]
	sla a
	add a, LOW(Status4PickupHandlerTable)
	ld l, a
	ld a, HIGH(Status4PickupHandlerTable)
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
	add a, OBJECT_HEALTH_OFFSET
	ld l, a
	ld a, [hl]
	cp b
	jr c, PickupRestoreQuarterHealth_Apply
	jp FinishPickupKeepObject

PickupRestoreQuarterHealth_Apply:
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
	add a, OBJECT_HEALTH_OFFSET
	ld l, a
	ld a, [hl]
	cp b
	jr c, PickupRestoreHalfHealth_Apply
	jp FinishPickupKeepObject

PickupRestoreHalfHealth_Apply:
	ld a, b
	sra a
	ld b, a
	call AddObjectHealth
	ld e, $4B
	call Audio_QueueSound
	jp FinishPickupFreeObject


; Item 2: start +$27 at 60 (16-frame steps); RenderObjectOrientationGraphic
; skips the holder while +$27 != 0 and +$28 == 0.
PickupStartRenderHideTimer:
PickupHandler02: ; legacy alias, used by docs
	pop hl
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_HIDE_TIMER_OFFSET
	ld l, a
	ld a, [hl]
	or a
	jp nz, FinishPickupKeepObject
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_HIDE_TIMER_OFFSET
	ld l, a
	ld [hl], $3C
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_HIDE_REVEAL_TIMER_OFFSET
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
	call ActivateMatchingLevelObjectAuxStateFar
	ld bc, $0BB8
	call AddToScore
	ld e, $54
	call Audio_QueueSound
	ld a, [wBonusPickupCount]
	inc a
	ld [wBonusPickupCount], a
	call ResetNearestObjectTrackerFar
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


; Item 5: powerup 2 = projectile subtype 2 (homing), 6 charges.
PickupHomingProjectileCharges:
PickupPowerupType2: ; legacy alias, used by reports
	pop hl
	ld a, l
	and $C0
	add a, OBJECT_PLAYER_POWERUP_TYPE_OFFSET
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


; Item 6: powerup 1 = projectile subtype 1, 9 charges.
PickupProjectileSubtype1Charges:
PickupPowerupType1: ; legacy alias, used by reports
	pop hl
	ld a, l
	and $C0
	add a, OBJECT_PLAYER_POWERUP_TYPE_OFFSET
	ld l, a
	ld a, [hl]
	cp $00
	jp nz, FinishPickupKeepObject
	ld a, l
	and $C0
	add a, OBJECT_PLAYER_POWERUP_TYPE_OFFSET
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


; Item 7: powerup 3 = StartScreenEffect (UsePlayerWeaponOrPowerup), 1 charge.
PickupScreenEffectCharge:
PickupPowerupType3: ; legacy alias, used by reports
	pop hl
	ld a, l
	and $C0
	add a, OBJECT_PLAYER_POWERUP_TYPE_OFFSET
	ld l, a
	ld a, [hl]
	cp $00
	jp nz, FinishPickupKeepObject
	push hl
	call ActivateMatchingLevelObjectAuxStateFar
	pop hl
	ld a, l
	and $C0
	add a, OBJECT_PLAYER_POWERUP_TYPE_OFFSET
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
	call ResetNearestObjectTrackerFar
	pop hl
	push hl
	ld a, l
	and $C0
	add a, OBJECT_TYPE_OFFSET
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
	add a, OBJECT_TYPE_OFFSET
	ld l, a
	ld a, [hl]
	add a, $53
	ld [de], a
	inc e
	ldh a, [hStatus4SpritePalette]
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
	jr nc, SubtractRgb555Saturating_StoreBlue
	xor a
SubtractRgb555Saturating_StoreBlue:
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
	jr nc, SubtractRgb555Saturating_StoreGreen
	xor a
SubtractRgb555Saturating_StoreGreen:
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
	jr nc, SubtractRgb555Saturating_StoreRed
	xor a
SubtractRgb555Saturating_StoreRed:
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
	jr c, AddRgb555Saturating_StoreBlue
	ld a, $1F
AddRgb555Saturating_StoreBlue:
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
	jr c, AddRgb555Saturating_StoreGreen
	ld a, $1F
AddRgb555Saturating_StoreGreen:
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
	jr c, AddRgb555Saturating_StoreRed
	ld a, $1F
AddRgb555Saturating_StoreRed:
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
DarkenAllBgPaletteColors_NextColor:
	ldh a, [rSTAT]
	and $02
	jr nz, DarkenAllBgPaletteColors_NextColor
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
DarkenAllBgPaletteColors_WaitWriteMode:
	ldh a, [rSTAT]
	and $02
	jr nz, DarkenAllBgPaletteColors_WaitWriteMode
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
	jr nz, DarkenAllBgPaletteColors_NextColor
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
	ld hl, wBackgroundPaletteFadeTarget + BACKGROUND_PALETTE_FRAME_SIZE - 1 ; $D7FF, last byte (WRAM bank 2)
	ld e, $3F
CaptureBgPalettesAndFadeToWhite_CaptureLoop:
	ldh a, [rSTAT]
	and $02
	jr nz, CaptureBgPalettesAndFadeToWhite_CaptureLoop
	ld a, e
	ldh [rBCPS], a
	ldh a, [rBCPD]
	ld [hld], a
	dec e
	ld a, e
	cp $FF
	jr nz, CaptureBgPalettesAndFadeToWhite_CaptureLoop
	pop af
	ldh [rSVBK], a
	ld a, $01
	ld [wPaletteFadeFromWhite], a
	call Func_3A2F
	ld e, $1F
CaptureBgPalettesAndFadeToWhite_FadeStep:
	xor a
	ld [wVBlankPending], a
CaptureBgPalettesAndFadeToWhite_WaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, CaptureBgPalettesAndFadeToWhite_WaitVBlank
	xor a
	ld [wVBlankPending], a
	call Audio_Update
	call Func_3A52
	dec e
	ld a, e
	cp $FF
	jr nz, CaptureBgPalettesAndFadeToWhite_FadeStep
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

InitMenuSystemRomImage:
	LOAD UNION "RAM code $D56A", WRAMX[$D56A] ; copied from $01:49CB

InitMenuSystem:
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
	ld a, [wJoypadHeld]
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
	ld a, BANK(SetMenuCursorChoice)
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


RunMenuLoopRomImage:
	LOAD UNION "RAM code $D62A", WRAMX[$D62A] ; copied from $01:4A6D

RunMenuLoop:
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
	call FadePalettesToBlackWithSound
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
	ld a, BANK(EnableMenuCursorSpritesWaitVBlank)
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
RunMenuLoop_WaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, RunMenuLoop_WaitVBlank
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
	ld hl, MenuStatHandlerRomImage
	ld bc, $C729
	ld de, $0024
	call CopyBytesShort
	ld hl, MenuVBlankHandlerRomImage
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


MenuStatHandlerRomImage:
	LOAD UNION "RAM code $C729", WRAM0[$C729] ; copied from $01:4B72

MenuStatHandler:
	push af
	push hl
	push bc
	ld a, [wMenuScanlineScrollEnabled]
	or a
	jr nz, MenuStatHandler_ApplyScanlineScroll
	ld a, $08
	ldh [rSCY], a
	jr MenuStatHandler_Return
MenuStatHandler_ApplyScanlineScroll:
	ldh a, [rLY]
	ld b, $00
	ld c, a
	sla c
	rl b
	ld hl, wMenuScanlineScrollTable
	add hl, bc
	; Original: the byte loaded by ld a, [hli] is overwritten by ld a, [hl]; only the odd byte of each 2-byte entry reaches rSCY.
	ld a, [hli]
	ld a, [hl]
	ldh [rSCY], a
MenuStatHandler_Return:
	pop bc
	pop hl
	pop af
	reti
	ENDL

MenuVBlankHandlerRomImage:
	LOAD UNION "RAM code $C7F1", WRAM0[$C7F1] ; copied from $01:4B96

MenuVBlankHandler:
	push af
	push de
	push bc
	push hl
	ld a, [wMenuScanlineScrollTable + 1]
	ldh [rSCY], a
	ldh a, [rSVBK]
	and $03
	push af
	ld a, $01
	ldh [rSVBK], a
	ld a, [wMenuCursorSpritesEnabled]
	or a
	jr z, MenuVBlankHandler_ClearLcdcBit4
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
MenuVBlankHandler_ClearLcdcBit4:
	ldh a, [rLCDC]
	res 4, a
	ldh [rLCDC], a
	ld a, [wVBlankCounter]
	and $01
	jr z, MenuVBlankHandler_StepScroll
	call Func_0A59
	ld a, [wJoypadHeld]
	and PADF_START | PADF_SELECT | PADF_B | PADF_A
	cp PADF_START | PADF_SELECT | PADF_B | PADF_A
	jr nz, MenuVBlankHandler_StepScroll
	jp RestartGame
MenuVBlankHandler_StepScroll:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, BANK(StepMenuScroll)
	ld [rROMB0], a
	call StepMenuScroll
	pop af
	ld [rROMB0], a
	ld a, [wVBlankCounter]
	inc a
	ld [wVBlankCounter], a
	ld a, [wVBlankCounter + 1]
	adc a, $00
	ld [wVBlankCounter + 1], a
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
	jr z, UpdateMenuCursorPosition_SpritesSettled
	pop hl
	pop de
	pop bc
	pop af
	ret

UpdateMenuCursorPosition_SpritesSettled:
	ld a, d
	or a
	jr nz, UpdateMenuCursorPosition_BuildScrollTable
	ld a, [wMenuCursorTargetY]
	ld b, a
	ld a, [wMenuCursorY]
	cp b
	jr z, UpdateMenuCursorPosition_AtTarget
	jr c, UpdateMenuCursorPosition_StepYDown
	; Original: this path runs only when Y > target, so sub $01 never borrows and the xor a clamp never runs.
	sub $01
	jr nc, UpdateMenuCursorPosition_StoreYUp
	xor a
UpdateMenuCursorPosition_StoreYUp:
	ld [wMenuCursorY], a
	jr UpdateMenuCursorPosition_BuildScrollTable

UpdateMenuCursorPosition_StepYDown:
	add a, $01
	ld [wMenuCursorY], a
UpdateMenuCursorPosition_BuildScrollTable:
	ld a, $01
	ld [wMenuCursorMoving], a
	ld hl, wMenuScanlineScrollTable
	ld d, $00
	ld e, $08
UpdateMenuCursorPosition_ScrollTableLoop:
	ld a, $00
	ld [hli], a
	ld a, [wMenuCursorY]
	cp d
	jr nc, UpdateMenuCursorPosition_StoreLineScroll
	bit 0, d
	jr nz, UpdateMenuCursorPosition_StoreLineScroll
	dec e
	ld a, e
	cp $FF
	jr nz, UpdateMenuCursorPosition_StoreLineScroll
	ld e, $00
UpdateMenuCursorPosition_StoreLineScroll:
	ld a, e
	ld [hli], a
	inc d
	ld a, d
	cp $FF
	jr nz, UpdateMenuCursorPosition_ScrollTableLoop
	pop hl
	pop de
	pop bc
	pop af
	ret

UpdateMenuCursorPosition_AtTarget:
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
	jr z, GetMenuChoiceRecord_Done
	ld d, a
GetMenuChoiceRecord_NextRecord:
	ld a, $10
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	cp $FF
	jr z, GetMenuChoiceRecord_Done
	dec d
	jr nz, GetMenuChoiceRecord_NextRecord
GetMenuChoiceRecord_Done:
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
	jr nz, ActivateMenuChoice_CheckType0F
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
	ld [wLevelNumber], a
	call ResetScore
	call ResetPlayerLives
	pop hl
	jr ActivateMenuChoice_Return

ActivateMenuChoice_CheckType0F:
	cp $0F
	jr nz, ActivateMenuChoice_LoadStatePointer
	ld a, [wGameStartMode]
	cp GAME_START_PASSWORD
	jr z, ActivateMenuChoice_CloseMenu
	ld a, GAME_START_NEW
	ld [wGameStartMode], a
	xor a
	ld [wLevelNumber], a
	call ResetScore
	call ResetPlayerLives
ActivateMenuChoice_CloseMenu:
	xor a
	ld [wMenuActive], a
	pop hl
	ret

ActivateMenuChoice_LoadStatePointer:
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
ActivateMenuChoice_Return:
	ret


SetMenuCursorChoice:
	call GetMenuChoiceRecord
	cp $FF
	jr nz, SetMenuCursorChoice_StoreChoice
	ld a, e
	call GetMenuChoiceRecord
SetMenuCursorChoice_StoreChoice:
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
	bit PADB_START, e
	jr nz, HandleMenuState00Input_IgnoreStartSelect
	bit PADB_SELECT, e
	jr nz, HandleMenuState00Input_IgnoreStartSelect
	bit PADB_B, e
	jr nz, HandleMenuState00Input_IgnoreB
	bit PADB_A, e
	jr nz, HandleMenuState00Input_PressA
	bit PADB_DOWN, e
	jr nz, HandleMenuState00Input_PressDown
	bit PADB_UP, e
	jr nz, HandleMenuState00Input_PressUp
	ret

HandleMenuState00Input_IgnoreStartSelect:
	ret

HandleMenuState00Input_PressA:
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
	jr nz, HandleMenuState00Input_ActivateChoice
	ld a, $00
	ld [wMenuActive], a
	ret

HandleMenuState00Input_ActivateChoice:
	ld a, [wMenuCursorChoice]
	jr HandleMenuState00Input_CallActivate

HandleMenuState00Input_IgnoreB:
	ret

HandleMenuState00Input_CallActivate:
	call ActivateMenuChoice
	ret

HandleMenuState00Input_PressDown:
	ld e, $0A
	call Audio_QueueSound
	ld a, [wMenuCursorChoice]
	ld e, a
	inc a
	jr HandleMenuState00Input_SetChoice

HandleMenuState00Input_PressUp:
	ld e, $0A
	call Audio_QueueSound
	ld a, [wMenuCursorChoice]
	dec a
	jr nz, HandleMenuState00Input_ApplyUp
	ld a, $01
HandleMenuState00Input_ApplyUp:
	jr HandleMenuState00Input_SetChoice

HandleMenuState00Input_SetChoice:
	call SetMenuCursorChoice
	ret


HandleMenuState04Input:
	bit PADB_START, e
	jr nz, HandleMenuState04Input_IgnoreStartSelect
	bit PADB_SELECT, e
	jr nz, HandleMenuState04Input_IgnoreStartSelect
	bit PADB_B, e
	jr nz, HandleMenuState04Input_PressB
	bit PADB_A, e
	jr nz, HandleMenuState04Input_PressA
	bit PADB_DOWN, e
	jr nz, HandleMenuState04Input_PressDown
	bit PADB_UP, e
	jr nz, HandleMenuState04Input_PressUp
	bit PADB_LEFT, e
	jr nz, HandleMenuState04Input_PressLeft
	bit PADB_RIGHT, e
	jr nz, HandleMenuState04Input_PressRight
HandleMenuState04Input_Redraw:
	call ApplyOptionsSettings
	ld a, $01
HandleMenuState04Input_DrawEntryLoop:
	call DrawOptionsEntryValue
	cp $FF
	jr nz, HandleMenuState04Input_DrawEntryLoop
	ret

HandleMenuState04Input_IgnoreStartSelect:
	ret

HandleMenuState04Input_PressB:
	call ApplyOptionsSettings
	ld a, $00
	call ActivateMenuChoice
	ret

HandleMenuState04Input_PressA:
	jr HandleMenuState04Input_PressB

HandleMenuState04Input_PressLeft:
	ld e, $0A
	call Audio_QueueSound
	ld b, $FF
	call AdjustOptionValue
	jr HandleMenuState04Input_Redraw

HandleMenuState04Input_PressRight:
	ld e, $0A
	call Audio_QueueSound
	ld b, $01
	call AdjustOptionValue
	jr HandleMenuState04Input_Redraw

HandleMenuState04Input_PressDown:
	ld e, $0B
	call Audio_QueueSound
	ld a, [wMenuCursorChoice]
	ld e, a
	inc a
	jr HandleMenuState04Input_SetChoice

HandleMenuState04Input_PressUp:
	ld e, $0B
	call Audio_QueueSound
	ld a, [wMenuCursorChoice]
	dec a
	jr nz, HandleMenuState04Input_ApplyUp
	ld a, $01
HandleMenuState04Input_ApplyUp:
	jr HandleMenuState04Input_SetChoice

HandleMenuState04Input_SetChoice:
	call SetMenuCursorChoice
	ret


AdjustOptionValue:
	push bc
	ld a, [wMenuCursorChoice]
	call GetMenuChoiceValueInfo
	pop bc
	ld a, e
	cp $02
	jr nz, AdjustOptionValue_CheckRanged
	ld a, [hl]
	xor $01
	ld [hl], a
	jr AdjustOptionValue_Return

AdjustOptionValue_CheckRanged:
	ld a, e
	cp $03
	jr z, AdjustOptionValue_StepRanged
	cp $04
	jr nz, AdjustOptionValue_Return
AdjustOptionValue_StepRanged:
	ld a, [hl]
	add a, b
	cp d
	jr nz, AdjustOptionValue_CheckUnderflow
	ld a, $00
AdjustOptionValue_CheckUnderflow:
	cp $FF
	jr nz, AdjustOptionValue_Store
	dec d
	ld a, d
AdjustOptionValue_Store:
	ld [hl], a
AdjustOptionValue_Return:
	ret

RuntimeCallbackTable:
	dw Func_364E
	dw Func_367F
	dw Func_36AF

ApplyOptionsSettings:
	ld a, [wMusicSetting]
	ld [wMusicEnabled], a
	and a
	jr nz, ApplyOptionsSettings_SelectCallback
	ldh [rNR51], a
ApplyOptionsSettings_SelectCallback:
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
LoadOptionsSettings_MatchLowByte:
	ld a, [hli]
	ld b, a
	ld a, [wRuntimeCallback]
	cp b
	jr z, LoadOptionsSettings_MatchHighByte
	inc e
	inc hl
	jr LoadOptionsSettings_MatchLowByte

LoadOptionsSettings_MatchHighByte:
	ld a, [hli]
	ld b, a
	ld a, [wRuntimeCallback + 1]
	cp b
	jr z, LoadOptionsSettings_StoreControlIndex
	inc e
	ld a, e
	; Original: cp $02 has no effect because the jr is unconditional. The search has no bound if wRuntimeCallback matches no table entry.
	cp $02
	jr LoadOptionsSettings_MatchLowByte

LoadOptionsSettings_StoreControlIndex:
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
	; Original: jr nz targets the next instruction (no effect).
	jr nz, InitMenuCursorForState_SetCursorRow
InitMenuCursorForState_SetCursorRow:
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
InitMenuCursorForState_WaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, InitMenuCursorForState_WaitVBlank
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

BcdPowersOfTwo16:
	db $01, $00, $02, $00, $04, $00, $08, $00, $16, $00, $32, $00, $64, $00, $28, $01
BcdPowersOfTwo24:
	db $01, $00, $00, $02, $00, $00, $04, $00, $00, $08, $00, $00, $16, $00, $00, $32
	db $00, $00, $64, $00, $00, $28, $01, $00, $56, $02, $00, $12, $05, $00, $24, $10
	db $00, $48, $20, $00, $96, $40, $00, $92, $81, $00, $84, $63, $01, $68, $27, $03
BcdPowersOfTwo40:
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

Bank01Data_4F40End:
; ByteToBcd16/AddWordToBcd24/LongToBcd40 step through these tables with inc l only
	ASSERT HIGH(BcdPowersOfTwo16) == HIGH(Bank01Data_4F40End - 1)
	ASSERT BcdPowersOfTwo24 - BcdPowersOfTwo16 == 8 * 2
	ASSERT BcdPowersOfTwo40 - BcdPowersOfTwo24 == 16 * 3
	ASSERT Bank01Data_4F40End - BcdPowersOfTwo40 == 32 * 5

DrawOptionsEntryLabel:
	call GetMenuChoiceRecord
	push af
	cp $FF
	jr nz, DrawOptionsEntryLabel_HaveRecord
	pop af
	ret

DrawOptionsEntryLabel_HaveRecord:
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
	jr z, DrawOptionsEntryLabel_Done
	call SetOptionLabelBgPalette7Colors
	call DrawEncodedText
DrawOptionsEntryLabel_Done:
	pop af
	inc a
	ret


DrawOptionsEntryValue:
	call GetMenuChoiceRecord
	push af
	cp $FF
	jr nz, DrawOptionsEntryValue_HaveRecord
	pop af
	ret

DrawOptionsEntryValue_HaveRecord:
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
	jr nz, DrawOptionsEntryValue_CheckControlType
	ld a, [hl]
	or a
	jr nz, DrawOptionsEntryValue_SelectOnText
	ld hl, OptionsOffText
	jr DrawOptionsEntryValue_DrawText

DrawOptionsEntryValue_SelectOnText:
	ld hl, OptionsOnText
	jr DrawOptionsEntryValue_DrawText

DrawOptionsEntryValue_CheckControlType:
	ld a, e
	cp $03
	jr nz, DrawOptionsEntryValue_CheckSkill
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
	jr DrawOptionsEntryValue_DrawText

DrawOptionsEntryValue_CheckSkill:
	ld a, e
	cp $04
	jr nz, DrawOptionsEntryValue_Done
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
DrawOptionsEntryValue_DrawText:
	call DrawEncodedText
DrawOptionsEntryValue_Done:
	pop af
	inc a
	ret


HandleMenuState03Input:
	bit PADB_START, e
	jr nz, HandleMenuState03Input_IgnoreStartSelect
	bit PADB_SELECT, e
	jr nz, HandleMenuState03Input_IgnoreStartSelect
	bit PADB_B, e
	jr nz, HandleMenuState03Input_BExit
	bit PADB_A, e
	jr nz, HandleMenuState03Input_ASubmit
	bit PADB_DOWN, e
	jr nz, HandleMenuState03Input_DownPrevChar
	bit PADB_UP, e
	jr nz, HandleMenuState03Input_UpNextChar
	bit PADB_LEFT, e
	jr nz, HandleMenuState03Input_LeftMoveCursor
	bit PADB_RIGHT, e
	jr nz, HandleMenuState03Input_RightMoveCursor
	ld c, $00
	ld b, $0B
	call DrawPasswordEntryChars
	ld a, [wVBlankCounter]
	and $03
	jr nz, HandleMenuState03Input_IdleReturn
	call CycleObjectPalettes12
HandleMenuState03Input_IdleReturn:
	ret

HandleMenuState03Input_IgnoreStartSelect:
	ret

HandleMenuState03Input_BExit:
	call MovePasswordCursorOffscreen
	ld a, $00
	call ActivateMenuChoice
	ret

HandleMenuState03Input_ASubmit:
	ld e, $07
	call Audio_QueueSound
	call SubmitEnteredCode
	ret

HandleMenuState03Input_DownPrevChar:
	ld a, [wPasswordSelectedChar]
	dec a
	bit 5, a
	jr z, HandleMenuState03Input_StorePrevChar
	ld a, $1F
HandleMenuState03Input_StorePrevChar:
	ld [wPasswordSelectedChar], a
	call StorePasswordCharWithSound
	jr HandleMenuState03Input_Redraw

HandleMenuState03Input_UpNextChar:
	ld a, [wPasswordSelectedChar]
	inc a
	bit 5, a
	jr z, HandleMenuState03Input_StoreNextChar
	xor a
HandleMenuState03Input_StoreNextChar:
	ld [wPasswordSelectedChar], a
	call StorePasswordCharWithSound
	jr HandleMenuState03Input_Redraw

HandleMenuState03Input_LeftMoveCursor:
	ld e, $0B
	call Audio_QueueSound
	ld a, [wPasswordCursorIndex]
	dec a
	cp $FF
	jr nz, HandleMenuState03Input_StoreCursorLeft
	ld a, $04
HandleMenuState03Input_StoreCursorLeft:
	ld [wPasswordCursorIndex], a
	call SetPasswordCursorTargetX
	; Original: jr targets the next instruction (no effect).
	jr HandleMenuState03Input_Redraw

HandleMenuState03Input_RightMoveCursor:
	ld e, $0B
	call Audio_QueueSound
	ld a, [wPasswordCursorIndex]
	inc a
	cp $05
	jr nz, HandleMenuState03Input_StoreCursorRight
	xor a
HandleMenuState03Input_StoreCursorRight:
	ld [wPasswordCursorIndex], a
	call SetPasswordCursorTargetX
	jr HandleMenuState03Input_Redraw

HandleMenuState03Input_Redraw:
	ld c, $00
	ld b, $0B
	call DrawPasswordEntryChars
	ld a, [wVBlankCounter]
	and $03
	jr nz, HandleMenuState03Input_Return
	call CycleObjectPalettes12
HandleMenuState03Input_Return:
	ret


SubmitEnteredCode:
	ld hl, wPasswordEntryChars
	ld bc, wPasswordChars
	ld e, $05
	call CopyBytesShort
	call PackPasswordChars
	call DecodePasswordBits
	or a
	jr nz, SubmitEnteredCode_Accepted
	call MovePasswordCursorOffscreen
	call ShowPasswordRejection
SubmitEnteredCode_RejectFrameLoop:
	xor a
	ld [wVBlankPending], a
SubmitEnteredCode_RejectWaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, SubmitEnteredCode_RejectWaitVBlank
	xor a
	ld [wVBlankPending], a
	call Audio_Update
	ld a, [wJoypadHeld]
	or a
	jr z, SubmitEnteredCode_RejectFrameLoop
	xor a
	ld [wMenuRenderedState], a
	ld a, $01
	call ActivateMenuChoice
	ret

SubmitEnteredCode_Accepted:
	ld a, [wPasswordLevel]
	ld [wLevelNumber], a
	ld a, [wPasswordLives]
	ld [wPlayerLives], a
	ld a, [wPasswordScoreThousands]
	ld c, a
	ld a, [wPasswordScoreThousands + 1]
	ld b, a
	call SetScoreFromThousandsFar
	call AdvanceScoreThresholdIndex
	ld a, GAME_START_PASSWORD
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
	jr c, AdvanceScoreThresholdIndex_Done
	jr nz, AdvanceScoreThresholdIndex_Advance
	ld a, [hld]
	ld b, a
	ld a, [wScore + 2]
	cp b
	jr c, AdvanceScoreThresholdIndex_Done
	jr nz, AdvanceScoreThresholdIndex_Advance
	ld a, [hld]
	ld b, a
	ld a, [wScore + 1]
	cp b
	jr c, AdvanceScoreThresholdIndex_Done
	jr nz, AdvanceScoreThresholdIndex_Advance
	ld a, [hld]
	ld b, a
	ld a, [wScore]
	cp b
	jr c, AdvanceScoreThresholdIndex_Done
AdvanceScoreThresholdIndex_Advance:
	ld a, c
	ld [wScoreThresholdIndex], a
	jr AdvanceScoreThresholdIndex

AdvanceScoreThresholdIndex_Done:
	ret


HandleMenuState05InputRomImage:
	LOAD UNION "RAM code $D70A", WRAMX[$D70A] ; copied from $01:51CC

HandleMenuState05Input:
	ld a, e
	or a
	jr z, HandleMenuState05Input_NoInput
	push de
	call ClearShadowOamAndTransferFar
	pop de
	bit PADB_START, e
	jr nz, HandleMenuState05Input_IgnoreBit7
	bit PADB_SELECT, e
	jr nz, HandleMenuState05Input_IgnoreBit6
	bit PADB_B, e
	jr nz, HandleMenuState05Input_ActivateChoice0
	bit PADB_A, e
	jr nz, HandleMenuState05Input_ActivateChoice2
	bit PADB_DOWN, e
	jr nz, HandleMenuState05Input_IgnoreBit3
	bit PADB_UP, e
	jr nz, HandleMenuState05Input_IgnoreBit2
	bit PADB_LEFT, e
	jr nz, MenuState05SelectPrevious
	bit PADB_RIGHT, e
	jr nz, MenuState05SelectNext
HandleMenuState05Input_NoInput:
	ret

HandleMenuState05Input_IgnoreBit7:
	ret

HandleMenuState05Input_IgnoreBit6:
	ret

HandleMenuState05Input_ActivateChoice0:
	xor a
	call ActivateMenuChoice
	ret

HandleMenuState05Input_ActivateChoice2:
	ld a, $02
	call ActivateMenuChoice
	ret

HandleMenuState05Input_IgnoreBit3:
	ret

HandleMenuState05Input_IgnoreBit2:
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
	jr nz, MenuState05SelectPrevious_StoreSelection
	ld a, $02
MenuState05SelectPrevious_StoreSelection:
	ld [wMenuState05Selection], a
	call LoadMenuState05Graphics
	call FillSceneBgRowsWithTrailingTile
	ld hl, $DC03
	ld a, l
	ld [wMenuState05UnreadPtr], a
	ld a, h
	ld [wMenuState05UnreadPtr + 1], a
	ld a, $01
	ld [wMenuScrollDirection], a
	call ScrollSceneInFromRight
	xor a
	ld [wMenuScrollDirection], a
	jr HandleMenuState05Input_Return

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
	jr nz, MenuState05SelectNext_StoreSelection
	ld a, $00
MenuState05SelectNext_StoreSelection:
	ld [wMenuState05Selection], a
	call LoadMenuState05Graphics
	call FillSceneBgRowsWithTrailingTile
	ld hl, $DC03
	ld a, l
	ld [wMenuState05UnreadPtr], a
	ld a, h
	ld [wMenuState05UnreadPtr + 1], a
	ld a, $01
	ld [wMenuScrollDirection], a
	call ScrollSceneInFromLeft
	xor a
	ld [wMenuScrollDirection], a
	jr HandleMenuState05Input_Return

HandleMenuState05Input_Return:
	ret
	ENDL
	db $00

HandleMenuState06Input:
	ld a, e
	or a
	jr z, HandleMenuState06Input_Return
	push de
	call ClearShadowOamAndTransferFar
	pop de
	bit PADB_START, e
	jr nz, HandleMenuState06Input_IgnoreStart
	bit PADB_SELECT, e
	jr nz, HandleMenuState06Input_IgnoreSelect
	bit PADB_B, e
	jr nz, HandleMenuState06Input_BExit
	bit PADB_A, e
	jr nz, HandleMenuState06Input_AStart
	bit PADB_LEFT, e
	jr nz, HandleMenuState06Input_LeftPrevRow
	bit PADB_RIGHT, e
	jr nz, HandleMenuState06Input_RightNextRow
	bit PADB_DOWN, e
	jp nz, HandleMenuState06Input_DownNextColumn
	bit PADB_UP, e
	jp nz, HandleMenuState06Input_UpPrevColumn
HandleMenuState06Input_Return:
	ret

HandleMenuState06Input_IgnoreStart:
	ret

HandleMenuState06Input_IgnoreSelect:
	ret

HandleMenuState06Input_BExit:
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

HandleMenuState06Input_AStart:
	ld e, $07
	call Audio_QueueSound
	ld a, GAME_START_LEVEL_SELECT
	ld [wGameStartMode], a
	ld a, [wMenuGridRow]
	ld b, a
	ld a, [wMenuGridColumn]
	ld c, a
	call RunMenuGridSceneScroll
	ld a, $02
	call ActivateMenuChoice
	ret

HandleMenuState06Input_LeftPrevRow:
	call QueueRandomGridSounds
	ld a, [wMenuGridRow]
	dec a
	call SetMenuGridRowWrapped
	ret

HandleMenuState06Input_RightNextRow:
	call QueueRandomGridSounds
	ld a, [wMenuGridRow]
	inc a
	call SetMenuGridRowWrapped
	ret

HandleMenuState06Input_DownNextColumn:
	ld e, $0B
	call Audio_QueueSound
	ld a, [wMenuGridColumn]
	inc a
	call SetMenuGridColumnClamped
	ret

HandleMenuState06Input_UpPrevColumn:
	ld e, $0B
	call Audio_QueueSound
	ld a, [wMenuGridColumn]
	dec a
	call SetMenuGridColumnClamped
	ret

	; Original: extra ret byte after the ret above; no known reference reaches it.
	db $C9

QueueRandomGridSounds:
	push af
	push bc
	push de
	push hl
QueueRandomGridSounds_RetryRandom:
	call Func_0421
	and $07
	cp $06
	jr nc, QueueRandomGridSounds_RetryRandom
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
	jr nz, SetMenuGridRowWrapped_CheckHigh
	ld a, $04
	jr SetMenuGridRowWrapped_Store
SetMenuGridRowWrapped_CheckHigh:
	cp $05
	jr nz, SetMenuGridRowWrapped_Store
	ld a, $00
SetMenuGridRowWrapped_Store:
	ld b, a
	ld [wMenuGridRow], a
	ld a, [wMenuGridColumn]
	ld c, a
	call FadeOutSceneBackground
	call ShowMenuGridScene
	ret

SetMenuGridColumnClamped:
	cp $FF
	jr nz, SetMenuGridColumnClamped_CheckHigh
	ld a, $00
	; Original: Z is still set from cp $FF, so this jr nz is never taken; cp $03 below then sets NZ and still reaches the store.
	jr nz, SetMenuGridColumnClamped_Store
SetMenuGridColumnClamped_CheckHigh:
	cp $03
	jr nz, SetMenuGridColumnClamped_Store
	ld a, $02
SetMenuGridColumnClamped_Store:
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
LoadMenuCursorSprites_OamWaitMode2or3:
	ldh a, [rSTAT]
	and $02
	jr z, LoadMenuCursorSprites_OamWaitMode2or3
LoadMenuCursorSprites_OamWaitMode0or1:
	ldh a, [rSTAT]
	and $02
	jr nz, LoadMenuCursorSprites_OamWaitMode0or1
	ld a, $AA
	ld [hli], a
	ld [hli], a
	ld a, [bc]
	ld [hli], a
	ld a, $00
	ld [hli], a
	inc bc
	dec d
	jr nz, LoadMenuCursorSprites_OamWaitMode2or3
	ld a, $07
	ld e, a
LoadMenuCursorSprites_XWaitMode2or3:
	ldh a, [rSTAT]
	and $02
	jr z, LoadMenuCursorSprites_XWaitMode2or3
LoadMenuCursorSprites_XWaitMode0or1:
	ldh a, [rSTAT]
	and $02
	jr nz, LoadMenuCursorSprites_XWaitMode0or1
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
LoadMenuCursorSprites_X2WaitMode2or3:
	ldh a, [rSTAT]
	and $02
	jr z, LoadMenuCursorSprites_X2WaitMode2or3
LoadMenuCursorSprites_X2WaitMode0or1:
	ldh a, [rSTAT]
	and $02
	jr nz, LoadMenuCursorSprites_X2WaitMode0or1
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
HideMenuCursorSprites_WaitStatBusy:
	ldh a, [rSTAT]
	and $02
	jr z, HideMenuCursorSprites_WaitStatBusy
HideMenuCursorSprites_WaitStatFree:
	ldh a, [rSTAT]
	and $02
	jr nz, HideMenuCursorSprites_WaitStatFree
	xor a
	ld [hl], a
	add hl, bc
	dec e
	jr nz, HideMenuCursorSprites_WaitStatBusy
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
EnableMenuCursorSpritesWaitVBlank_WaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, EnableMenuCursorSpritesWaitVBlank_WaitVBlank
	xor a
	ld [wVBlankPending], a
	ret


SubtractBCFromHL:
	ld a, l
	sub c
	ld l, a
	jr nc, SubtractBCFromHL_SubHigh
	inc b
SubtractBCFromHL_SubHigh:
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
	jr z, InitMenuStateScreen_State03
	cp $05
	jr z, InitMenuStateScreen_State05
	cp $06
	jr z, InitMenuStateScreen_State06
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

InitMenuStateScreen_State03:
	ld a, $00
	ld [wMenuScanlineScrollEnabled], a
	call LoadPasswordScreenTilesAndCursor
	call SnapPasswordCursorSprites
	call LoadPasswordObjPalettes1And2
	call LoadPasswordBgPalettes4To7
	jr InitMenuStateScreen_Finish

InitMenuStateScreen_State05:
	call Func_3960
	ld a, $01
	ld [wMenuState05Selection], a
	call LoadMenuState05Graphics
	call FillSceneBgRowsWithTrailingTile
	ld hl, $DC03
	ld a, l
	ld [wMenuState05UnreadPtr], a
	ld a, h
	ld [wMenuState05UnreadPtr + 1], a
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
	jr InitMenuStateScreen_Finish

InitMenuStateScreen_State06:
	; Original: ld e, $01 is overwritten by ld de, $0000 before any read (dead store).
	ld e, $01
	ld de, $0000
	call InitSceneDisplay
	ld a, [wMenuGridRow]
	ld b, a
	ld a, [wMenuGridColumn]
	ld c, a
	call ShowMenuGridScene
InitMenuStateScreen_WaitStatFree:
	ldh a, [rSTAT]
	and $02
	jr nz, InitMenuStateScreen_WaitStatFree
	ldh a, [rLCDC]
	; Original: bit 1, a changes only flags, so LCDC is written back unchanged (the State05 path uses set 1, a here).
	bit 1, a
	ldh [rLCDC], a
	; Original: jr targets the next instruction (no effect).
	jr InitMenuStateScreen_Finish

InitMenuStateScreen_Finish:
	xor a
	ld [wVBlankPending], a
InitMenuStateScreen_WaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, InitMenuStateScreen_WaitVBlank
	xor a
	ld [wVBlankPending], a
	ret


UpdateMenuInputRepeat:
	ld a, [wMenuRepeatTimer]
	ld c, a
	ld a, [wJoypadHeld]
	ld d, a
	ld a, [wMenuPreviousButtons]
	ld e, $00
	bit 7, d
	jr z, UpdateMenuInputRepeat_StartNotHeld
	bit PADB_START, a
	jr nz, UpdateMenuInputRepeat_StartHeld
	set PADB_START, e
	set PADB_START, a
	jr UpdateMenuInputRepeat_CheckSelect

UpdateMenuInputRepeat_StartHeld:
	dec c
	jr nz, UpdateMenuInputRepeat_StartDone
	set PADB_START, e
	ld c, $02
UpdateMenuInputRepeat_StartDone:
	jr UpdateMenuInputRepeat_CheckSelect

UpdateMenuInputRepeat_StartNotHeld:
	bit PADB_START, a
	jr z, UpdateMenuInputRepeat_CheckSelect
	res PADB_START, a
	ld c, $14
	jr UpdateMenuInputRepeat_CheckSelect

UpdateMenuInputRepeat_CheckSelect:
	bit PADB_SELECT, d
	jr z, UpdateMenuInputRepeat_SelectNotHeld
	bit PADB_SELECT, a
	jr nz, UpdateMenuInputRepeat_SelectHeld
	set PADB_SELECT, e
	set PADB_SELECT, a
	jr UpdateMenuInputRepeat_CheckB

UpdateMenuInputRepeat_SelectHeld:
	dec c
	jr nz, UpdateMenuInputRepeat_SelectDone
	set PADB_SELECT, e
	ld c, $02
UpdateMenuInputRepeat_SelectDone:
	jr UpdateMenuInputRepeat_CheckB

UpdateMenuInputRepeat_SelectNotHeld:
	bit PADB_SELECT, a
	jr z, UpdateMenuInputRepeat_CheckB
	res PADB_SELECT, a
	ld c, $14
	jr UpdateMenuInputRepeat_CheckB

UpdateMenuInputRepeat_CheckB:
	bit PADB_B, d
	jr z, UpdateMenuInputRepeat_BNotHeld
	bit PADB_B, a
	jr nz, UpdateMenuInputRepeat_BHeld
	set PADB_B, e
	set PADB_B, a
	jr UpdateMenuInputRepeat_CheckA

UpdateMenuInputRepeat_BHeld:
	dec c
	jr nz, UpdateMenuInputRepeat_BDone
	set PADB_B, e
	ld c, $02
UpdateMenuInputRepeat_BDone:
	jr UpdateMenuInputRepeat_CheckA

UpdateMenuInputRepeat_BNotHeld:
	bit PADB_B, a
	jr z, UpdateMenuInputRepeat_CheckA
	res PADB_B, a
	ld c, $14
	jr UpdateMenuInputRepeat_CheckA

UpdateMenuInputRepeat_CheckA:
	bit PADB_A, d
	jr z, UpdateMenuInputRepeat_ANotHeld
	bit PADB_A, a
	jr nz, UpdateMenuInputRepeat_AHeld
	set PADB_A, e
	set PADB_A, a
	jr UpdateMenuInputRepeat_CheckUp

UpdateMenuInputRepeat_AHeld:
	dec c
	jr nz, UpdateMenuInputRepeat_ADone
	set PADB_A, e
	ld c, $02
UpdateMenuInputRepeat_ADone:
	jr UpdateMenuInputRepeat_CheckUp

UpdateMenuInputRepeat_ANotHeld:
	bit PADB_A, a
	jr z, UpdateMenuInputRepeat_CheckUp
	res PADB_A, a
	ld c, $14
	jr UpdateMenuInputRepeat_CheckUp

UpdateMenuInputRepeat_CheckUp:
	bit PADB_UP, d
	jr z, UpdateMenuInputRepeat_UpNotHeld
	bit PADB_UP, a
	jr nz, UpdateMenuInputRepeat_UpHeld
	set PADB_UP, e
	set PADB_UP, a
	jr UpdateMenuInputRepeat_CheckDown

UpdateMenuInputRepeat_UpHeld:
	dec c
	jr nz, UpdateMenuInputRepeat_UpDone
	set PADB_UP, e
	ld c, $02
UpdateMenuInputRepeat_UpDone:
	jr UpdateMenuInputRepeat_CheckDown

UpdateMenuInputRepeat_UpNotHeld:
	bit PADB_UP, a
	jr z, UpdateMenuInputRepeat_CheckDown
	res PADB_UP, a
	ld c, $14
	jr UpdateMenuInputRepeat_CheckDown

UpdateMenuInputRepeat_CheckDown:
	bit PADB_DOWN, d
	jr z, UpdateMenuInputRepeat_DownNotHeld
	bit PADB_DOWN, a
	jr nz, UpdateMenuInputRepeat_DownHeld
	set PADB_DOWN, e
	set PADB_DOWN, a
	jr UpdateMenuInputRepeat_CheckLeft

UpdateMenuInputRepeat_DownHeld:
	dec c
	jr nz, UpdateMenuInputRepeat_DownDone
	set PADB_DOWN, e
	ld c, $02
UpdateMenuInputRepeat_DownDone:
	jr UpdateMenuInputRepeat_CheckLeft

UpdateMenuInputRepeat_DownNotHeld:
	bit PADB_DOWN, a
	jr z, UpdateMenuInputRepeat_CheckLeft
	res PADB_DOWN, a
	ld c, $14
	jr UpdateMenuInputRepeat_CheckLeft

UpdateMenuInputRepeat_CheckLeft:
	bit PADB_LEFT, d
	jr z, UpdateMenuInputRepeat_LeftNotHeld
	bit PADB_LEFT, a
	jr nz, UpdateMenuInputRepeat_LeftHeld
	set PADB_LEFT, e
	set PADB_LEFT, a
	jr UpdateMenuInputRepeat_CheckRight

UpdateMenuInputRepeat_LeftHeld:
	dec c
	jr nz, UpdateMenuInputRepeat_LeftDone
	set PADB_LEFT, e
	ld c, $02
UpdateMenuInputRepeat_LeftDone:
	jr UpdateMenuInputRepeat_CheckRight

UpdateMenuInputRepeat_LeftNotHeld:
	bit PADB_LEFT, a
	jr z, UpdateMenuInputRepeat_CheckRight
	res PADB_LEFT, a
	ld c, $14
	jr UpdateMenuInputRepeat_CheckRight

UpdateMenuInputRepeat_CheckRight:
	bit PADB_RIGHT, d
	jr z, UpdateMenuInputRepeat_RightNotHeld
	bit PADB_RIGHT, a
	jr nz, UpdateMenuInputRepeat_RightHeld
	ld c, $14
	set PADB_RIGHT, e
	set PADB_RIGHT, a
	jr UpdateMenuInputRepeat_Store

UpdateMenuInputRepeat_RightHeld:
	dec c
	jr nz, UpdateMenuInputRepeat_RightDone
	set PADB_RIGHT, e
	ld c, $02
UpdateMenuInputRepeat_RightDone:
	jr UpdateMenuInputRepeat_Store

UpdateMenuInputRepeat_RightNotHeld:
	bit PADB_RIGHT, a
	jr z, UpdateMenuInputRepeat_Store
	res PADB_RIGHT, a
	ld c, $14
	jr UpdateMenuInputRepeat_Store

UpdateMenuInputRepeat_Store:
	ld [wMenuPreviousButtons], a
	ld a, c
	ld [wMenuRepeatTimer], a
	ret


StepMenuScroll:
	ld a, [wMenuScrollDirection]
	or a
	jr z, StepMenuScroll_Return
	ld d, a
	ld a, [wMenuScrollStep]
	ld e, a
	call Func_3A52
	ld a, d
	cp $01
	jr z, StepMenuScroll_Advance
	; Original: any direction other than $01/$02 falls through into the $01 path; all known writers store only 0, $01 or $02.
	cp $02
	jr z, StepMenuScroll_Retreat
StepMenuScroll_Advance:
	ld a, [wMenuScrollStep]
	inc a
	inc a
	ld [wMenuScrollStep], a
	cp $20
	jr c, StepMenuScroll_Return
	ld a, $1F
	ld [wMenuScrollStep], a
	xor a
	ld [wMenuScrollDirection], a
	jr StepMenuScroll_Return

StepMenuScroll_Retreat:
	ld a, [wMenuScrollStep]
	dec a
	dec a
	ld [wMenuScrollStep], a
	cp $20
	jr c, StepMenuScroll_Return
	ld a, $00
	ld [wMenuScrollStep], a
	xor a
	ld [wMenuScrollDirection], a
	jr StepMenuScroll_Return

StepMenuScroll_Return:
	ret


UnusedMenuRamNoOpRomImage:
	LOAD UNION "RAM code (callerless) $D7CA", WRAMX[$D7CA] ; copied from $01:565F
UnusedMenuRamNoOp:
	ret
	ENDL
	db $00

LoadMenuState05GraphicsRomImage:
	LOAD UNION "RAM code $D7CB", WRAMX[$D7CB] ; copied from $01:5661

LoadMenuState05Graphics:
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
	ld [wPaletteFadeFromWhite], a
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

LoadEncodedFontTilesToVram1RomImage:
	LOAD UNION "RAM code $D9CB", WRAMX[$D9CB] ; copied from $01:5718

LoadEncodedFontTilesToVram1:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, BANK(EncodedFontTiles)
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

CopyBankedTilemapRectToBGRomImage:
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
	ld [wBgCopyReloadCount], a
	ld a, [wBankedBgSourcePtrs]
	ld c, a
	ld a, [wBankedBgSourcePtrs + 1]
	ld b, a
	ld a, [wBankedBgSourcePtrs + 2]
	ld e, a
	ld a, [wBankedBgSourcePtrs + 3]
	ld d, a
CopyBankedTilemapRectToBG_RowLoop:
	ld a, [wBgCopyReloadCount]
	ld [wBgCopyColumnsLeft], a
CopyBankedTilemapRectToBG_ColumnLoop:
	ldh a, [rSTAT]
	and $02
	jr nz, CopyBankedTilemapRectToBG_ColumnLoop
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
	jr nz, CopyBankedTilemapRectToBG_ColumnLoop
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
	jp nz, CopyBankedTilemapRectToBG_RowLoop
	pop af
	ld [rROMB0], a
	ret

	ENDL

CopyBankedTilemapRowsToBGRomImage:
	LOAD UNION "RAM code $D88B", WRAMX[$D88B] ; copied from $01:57E1

CopyBankedTilemapRowsToBG:
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
	ld hl, wBgCopyReloadCount
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
CopyBankedTilemapRowsToBG_RowLoop:
	ld a, $14
	ld [wBgCopyColumnsLeft], a
CopyBankedTilemapRowsToBG_WaitHBlankStart:
	ldh a, [rSTAT]
	and $02
	jr z, CopyBankedTilemapRowsToBG_WaitHBlankStart
CopyBankedTilemapRowsToBG_WaitHBlank:
	ldh a, [rSTAT]
	and $02
	jr nz, CopyBankedTilemapRowsToBG_WaitHBlank
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
	jr nz, CopyBankedTilemapRowsToBG_WaitHBlankStart
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
	jr nz, CopyBankedTilemapRowsToBG_RowLoop
	pop af
	ld [rROMB0], a
	ret

	ENDL
	db $00

InstallMenuRamCode:
Func_01_5867: ; legacy alias, used by src/bank_00.asm
	ld de, $0000
	call InitSceneDisplay
	ld hl, InitMenuSystemRomImage
	ld de, $0096
	ld bc, $D56A
	call CopyBytes
	ld hl, RunMenuLoopRomImage
	ld de, $00DC
	ld bc, $D62A
	call CopyBytes
	ld hl, HandleMenuState05InputRomImage
	ld de, $00BA
	ld bc, $D70A
	call CopyBytes
	ld hl, UnusedMenuRamNoOpRomImage
	ld de, $0001
	ld bc, $D7CA
	call CopyBytes
	ld hl, LoadMenuState05GraphicsRomImage
	ld de, $00B6
	ld bc, $D7CB
	call CopyBytes
	ld hl, LoadEncodedFontTilesToVram1RomImage
	ld de, $0021
	ld bc, $D9CB
	call CopyBytes
	ld hl, CopyBankedTilemapRowsToBGRomImage
	ld de, $0085
	ld bc, $D88B
	call CopyBytes
	ld hl, CopyBankedTilemapRectToBGRomImage
	ld de, $00A7
	ld bc, $D91B
	call CopyBytes
	xor a
	ld [wVBlankPending], a
InstallMenuRamCode_WaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, InstallMenuRamCode_WaitVBlank
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

; read by LoadMenuState05Graphics; index wMenuState05Selection 0-2
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

EnableSceneWindowRomImage:
	LOAD UNION "RAM code $D120", WRAMX[$D120] ; copied from $01:5BBA

EnableSceneWindow:
	ldh a, [rLCDC]
	set 4, a
	ldh [rLCDC], a
	ld a, $07
	ldh [rWX], a
	ldh a, [hSceneWindowSplitCountdown]
	ldh [rWY], a
	ret

	ENDL
	db $00

DisableSceneWindowRomImage:
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

StepSceneWindowSplitRomImage:
	LOAD UNION "RAM code $D140", WRAMX[$D140] ; copied from $01:5BD6

StepSceneWindowSplit:
	ldh a, [hSceneWindowSplitCountdown]
	or a
	jr z, StepSceneWindowSplit_SplitLineZero
	dec a
	ldh [hSceneWindowSplitCountdown], a
	ldh [rLYC], a
	ret

StepSceneWindowSplit_SplitLineZero:
	ldh [hSceneWindowSplitCountdown], a
	; Original: calls the ROM-side image address $5F26, not its WRAM copy at $D310; this reaches the intended code only while bank 1 is mapped.
	call WriteBgPalette7FromFF98RomImage
	call EnableSceneWindow
	ldh a, [hSceneWindowSplitCountdown]
	add a, $5F
	ldh [rLYC], a
	ret

	ENDL
	db $00

InitSceneDisplay:
Func_01_5BF1: ; legacy alias, used by src/bank_00.asm
	call Func_3960
	ld a, $01
	ldh [hSceneInitWriteOnly], a
	ldh [hSceneScrollStep], a
	ldh [hSceneRasterFxEnabled], a
	xor a
	ldh [hSceneScrollEnded], a
	ldh [rLYC], a
	ldh [rSCX], a
	ldh [hSceneScrollStarted], a
	ldh [hSceneRowPixelPhase], a
	ldh [hSceneLcdStepPending], a
	; Original: the same hSceneLcdStepPending store is repeated (no effect).
	ldh [hSceneLcdStepPending], a
	ldh [hSceneWriteOnlyFlag], a
	ldh [hSceneRowTileBase], a
	ldh [hSceneTileSlot], a
	ldh [hSceneRowHdmaPending], a
	ld e, $10
	ld hl, hScenePalette7BufferA
InitSceneDisplay_ClearHramLoop:
	ld [hli], a
	dec e
	jr nz, InitSceneDisplay_ClearHramLoop
	xor a
	add a, $60
	ldh [hSceneScrollY], a
	ldh [rSCY], a
	ld a, $8E
	ldh [hSceneWindowSplitCountdown], a
	ld a, $B4
	ldh [hSceneWxCopy], a
	ld a, $60
	ldh [hSceneScrollDelay], a
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
InitSceneDisplay_WaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, InitSceneDisplay_WaitVBlank
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
ClearSceneVram_WaitStatBusy:
	ldh a, [rSTAT]
	and $02
	jr z, ClearSceneVram_WaitStatBusy
ClearSceneVram_WaitStatFree:
	ldh a, [rSTAT]
	and $02
	jr nz, ClearSceneVram_WaitStatFree
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
	jr nz, ClearSceneVram_WaitStatBusy
	ld a, c
	or a
	jr nz, ClearSceneVram_WaitStatBusy
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
ClearSceneVram_WaitVBlankBg0Attr:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, ClearSceneVram_WaitVBlankBg0Attr
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
ClearSceneVram_WaitVBlankBg0Tiles:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, ClearSceneVram_WaitVBlankBg0Tiles
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
ClearSceneVram_WaitVBlankBg1Attr:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, ClearSceneVram_WaitVBlankBg1Attr
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
ClearSceneVram_WaitVBlankBg1Tiles:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, ClearSceneVram_WaitVBlankBg1Tiles
	xor a
	ld [wVBlankPending], a
	ld a, $3F
	ldh [rHDMA5], a
	ld hl, $87F0
	ld d, $04
ClearSceneVram_TileGroupWaitDraw:
	ldh a, [rSTAT]
	and $02
	jr z, ClearSceneVram_TileGroupWaitDraw
ClearSceneVram_TileGroupWaitBlank:
	ldh a, [rSTAT]
	and $02
	jr nz, ClearSceneVram_TileGroupWaitBlank
	ld e, $04
ClearSceneVram_ClearByteLoop:
	xor a
	ld [hli], a
	dec e
	jr nz, ClearSceneVram_ClearByteLoop
	dec d
	jr nz, ClearSceneVram_TileGroupWaitDraw
	pop hl
	pop de
	pop bc
	pop af
	ret


SceneStatHandlerRomImage:
	LOAD UNION "RAM code $C729", WRAM0[$C729] ; copied from $01:5D77

SceneStatHandler:
	push af
	push bc
	push de
	push hl
	ldh a, [hSceneBankSwitchGuard]
	or a
	jr nz, SceneStatHandler_Return
	ldh a, [rSTAT]
	bit 2, a
	jr nz, SceneStatHandler_LycMatch
	ldh a, [hSceneLcdStepPending]
	or a
	jr z, SceneStatHandler_Return
	ldh a, [hSceneRasterFxEnabled]
	or a
	jr z, SceneStatHandler_FinishLcdSteps
	ldh a, [hSceneLcdStepLimit]
	ld b, a
	ldh a, [hSceneLcdStepIndex]
	cp b
	jr nz, SceneStatHandler_ApplyLcdStep
SceneStatHandler_FinishLcdSteps:
	xor a
	ldh [hSceneLcdStepPending], a
	ldh [hSceneLcdStepIndex], a
	call WriteBgPalette7FromFFA0
	jr SceneStatHandler_Return
SceneStatHandler_ApplyLcdStep:
	ld b, a
	; Original: calls the ROM-side image address $5EE0, not its WRAM copy at $D2C0; this reaches the intended code only while bank 1 is mapped.
	call WriteBgPalette7FromD3F8RomImage
	ld a, b
	inc a
	ldh [hSceneLcdStepIndex], a
SceneStatHandler_Return:
	pop hl
	pop de
	pop bc
	pop af
	reti
SceneStatHandler_LycMatch:
	ldh a, [rLY]
	ld e, a
	ldh a, [hSceneWindowSplitCountdown]
	cp e
	jr nz, SceneStatHandler_WaitHBlankForWindowEnd
SceneStatHandler_WaitHBlankForSplit:
	ldh a, [rSTAT]
	and $03
	jr nz, SceneStatHandler_WaitHBlankForSplit
	call WriteBgPalette7FromFF98
	call EnableSceneWindow
	ldh a, [hSceneWindowSplitCountdown]
	add a, $5F
	cp $8F
	jr nc, SceneStatHandler_ClampLycToLine8F
	ldh [rLYC], a
	xor a
	ldh [hSceneLcdStepPending], a
	jr SceneStatHandler_LycReturn
SceneStatHandler_ClampLycToLine8F:
	ld a, $8F
	ldh [rLYC], a
	xor a
	ldh [hSceneLcdStepPending], a
	jr SceneStatHandler_LycReturn
SceneStatHandler_WaitHBlankForWindowEnd:
	ldh a, [rSTAT]
	and $03
	jr nz, SceneStatHandler_WaitHBlankForWindowEnd
	ldh a, [hSceneRasterFxEnabled]
	or a
	jr z, SceneStatHandler_RestorePalette7
	ld de, $FF69
	ld a, $B8
	ldh [rBCPS], a
	xor a
	REPT 8
	ld [de], a
	ENDR
	jr SceneStatHandler_DisableWindow
SceneStatHandler_RestorePalette7:
	call WriteBgPalette7FromFFA0
SceneStatHandler_DisableWindow:
	call DisableSceneWindow
	ldh a, [hSceneWindowSplitCountdown]
	add a, $60
	add a, $08
	cp $8F
	jr nc, SceneStatHandler_ClearStepPending
	ld a, $01
	ldh [hSceneLcdStepPending], a
	jr SceneStatHandler_LycReturn
SceneStatHandler_ClearStepPending:
	xor a
	ldh [hSceneLcdStepPending], a
SceneStatHandler_LycReturn:
	pop hl
	pop de
	pop bc
	pop af
	reti
	ENDL

SceneVBlankHandlerRomImage:
	LOAD UNION "RAM code $C7F1", WRAM0[$C7F1] ; copied from $01:5E16

SceneVBlankHandler:
	push af
	push de
	push bc
	push hl
	ldh a, [hSceneBankSwitchGuard]
	or a
	jr nz, SceneVBlankHandler_StepScrollDelay
	call StepSceneWindowSplit
SceneVBlankHandler_StepScrollDelay:
	ldh a, [hSceneScrollDelay]
	dec a
	ldh [hSceneScrollDelay], a
	or a
	jr nz, SceneVBlankHandler_ApplyScroll
	ld a, $01
	ldh [hSceneScrollStarted], a
SceneVBlankHandler_ApplyScroll:
	ldh a, [hSceneScrollY]
	ldh [rSCY], a
	ldh a, [hSceneRowHdmaPending]
	or a
	jr z, SceneVBlankHandler_PollJoypad
	xor a
	ldh [hSceneRowHdmaPending], a
	call StartSceneTileRowHdma
SceneVBlankHandler_PollJoypad:
	ld a, [wVBlankCounter]
	and $01
	jr z, SceneVBlankHandler_CountFrame
	call Func_0A59
	ld a, [wJoypadHeld]
	and PADF_START | PADF_SELECT | PADF_B | PADF_A
	cp PADF_START | PADF_SELECT | PADF_B | PADF_A
	jr nz, SceneVBlankHandler_CountFrame
	jp RestartGame

SceneVBlankHandler_CountFrame:
	ld a, [wVBlankCounter]
	inc a
	ld [wVBlankCounter], a
	ld a, [wVBlankCounter + 1]
	adc a, $00
	ld [wVBlankCounter + 1], a
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
	ld hl, SceneStatHandlerRomImage
	ld de, $009F
	ld bc, $C729
	call CopyBytes
	ld hl, SceneVBlankHandlerRomImage
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


BuildScenePaletteFadeTableRomImage:
	LOAD UNION "RAM code $D270", WRAMX[$D270] ; copied from $01:5E9C

BuildScenePaletteFadeTable:
	xor a
	ldh [hScenePaletteBuildIndex], a
BuildScenePaletteFadeTable_ColorLoop:
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
BuildScenePaletteFadeTable_StepLoop:
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
	jr nz, BuildScenePaletteFadeTable_StepLoop
	ldh a, [hScenePaletteBuildIndex]
	inc a
	ldh [hScenePaletteBuildIndex], a
	cp $04
	jr c, BuildScenePaletteFadeTable_ColorLoop
	ret

	ENDL
	db $00

WriteBgPalette7FromD3F8RomImage:
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

WriteBgPalette7FromFFA0RomImage:
	LOAD UNION "RAM code $D2F0", WRAMX[$D2F0] ; copied from $01:5F0A

WriteBgPalette7FromFFA0:
	ld hl, hScenePalette7BufferB
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

WriteBgPalette7FromFF98RomImage:
	LOAD UNION "RAM code $D310", WRAMX[$D310] ; copied from $01:5F26

WriteBgPalette7FromFF98:
	ld hl, hScenePalette7BufferA
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

LoadFixedSceneResourcesRomImage:
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
LoadFixedSceneResources_WaitVBlankBeforeVram1Dma:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, LoadFixedSceneResources_WaitVBlankBeforeVram1Dma
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
LoadFixedSceneResources_WaitVBlankBeforeVram0Dma:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, LoadFixedSceneResources_WaitVBlankBeforeVram0Dma
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
LoadFixedSceneResources_AttrRowLoop:
	ld e, $14
LoadFixedSceneResources_AttrWaitHBlankStart:
	ldh a, [rSTAT]
	and $02
	jr z, LoadFixedSceneResources_AttrWaitHBlankStart
LoadFixedSceneResources_AttrWaitHBlank:
	ldh a, [rSTAT]
	and $02
	jr nz, LoadFixedSceneResources_AttrWaitHBlank
	ld a, [bc]
	ld [hli], a
	inc bc
	dec e
	jr nz, LoadFixedSceneResources_AttrWaitHBlankStart
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	dec d
	jr nz, LoadFixedSceneResources_AttrRowLoop
	pop hl
	pop bc
	xor a
	ld [wVBlankPending], a
LoadFixedSceneResources_WaitVBlankBeforeTilemap:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, LoadFixedSceneResources_WaitVBlankBeforeTilemap
	xor a
	ld [wVBlankPending], a
	xor a
	ldh [rVBK], a
	ld d, $0C
LoadFixedSceneResources_TileRowLoop:
	ld e, $14
LoadFixedSceneResources_TileWaitHBlankStart:
	ldh a, [rSTAT]
	and $02
	jr z, LoadFixedSceneResources_TileWaitHBlankStart
LoadFixedSceneResources_TileWaitHBlank:
	ldh a, [rSTAT]
	and $02
	jr nz, LoadFixedSceneResources_TileWaitHBlank
	ld a, [bc]
	bit 7, a
	jr z, LoadFixedSceneResources_StorePlainTile
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
	jr LoadFixedSceneResources_NextTile

LoadFixedSceneResources_StorePlainTile:
	ld [hli], a
LoadFixedSceneResources_NextTile:
	inc bc
	dec e
	jr nz, LoadFixedSceneResources_TileWaitHBlankStart
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	dec d
	jr nz, LoadFixedSceneResources_TileRowLoop
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
	ld [wPaletteFadeFromWhite], a
	call Func_3A2F
	ld a, $01
	ld [rROMB0], a
	ret

	ENDL
	db $00

LoadScrollingScenePaletteRomImage:
	LOAD UNION "RAM code $D160", WRAMX[$D160] ; copied from $01:6057

LoadScrollingScenePalette:
	push af
	push bc
	push de
	push hl
	ld a, $01
	ldh [hSceneBankSwitchGuard], a
	ld hl, wScrollingSceneBank
	ld a, l
	ldh [hSceneDescriptorPointer], a
	ld a, h
	ldh [hSceneDescriptorPointer + 1], a
	ld a, [hl]
	ldh [hSceneRomBank], a
	ld e, a
	ld hl, wScrollingSceneLastRow
	ld a, [hli]
	ldh [hSceneLastRow], a
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
	ldh [hSceneRow], a
	ld a, $01
	ld [rROMB0], a
	pop hl
	pop de
	pop bc
	pop af
	ld a, $00
	ldh [hSceneBankSwitchGuard], a
	ret

	ENDL
	db $00

RunScrollingScene:
Func_01_609A: ; legacy alias, used by src/bank_00.asm
	xor a
	ld [wVBlankPending], a
RunScrollingScene_WaitVBlankBeforeLoad:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, RunScrollingScene_WaitVBlankBeforeLoad
	xor a
	ld [wVBlankPending], a
	ld a, $01
	ldh [hSceneBankSwitchGuard], a
	call CopyFixedSceneDescriptor
	call CopyScrollingSceneDescriptor
	call LoadFixedSceneResources
	call LoadScrollingScenePalette
	call ApplySceneTargetPalettes
	xor a
	ld [wVBlankPending], a
RunScrollingScene_WaitVBlankAfterLoad:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, RunScrollingScene_WaitVBlankAfterLoad
	xor a
	ld [wVBlankPending], a
	xor a
	ldh [hSceneBankSwitchGuard], a
RunScrollingScene_FrameLoop:
	call Audio_Update
	xor a
	ld [wVBlankPending], a
RunScrollingScene_WaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, RunScrollingScene_WaitVBlank
	xor a
	ld [wVBlankPending], a
	ldh a, [hSceneScrollStarted]
	or a
	jr z, RunScrollingScene_FrameLoop
	call AdvanceSceneScroll
	ldh a, [hSceneScrollEnded]
	or a
	jr nz, RunScrollingScene_Exit
	ld a, [wJoypadHeld]
	ld e, a
	and PADF_START
	jr nz, RunScrollingScene_Exit
	ld a, e
	and PADF_B | PADF_A
	jr z, RunScrollingScene_ABNotHeldDelay
	ld e, $24
	call Audio_QueueSound
	jr RunScrollingScene_FrameLoop

RunScrollingScene_ABNotHeldDelay:
	ld a, $03
	ld d, a
RunScrollingScene_ABNotHeldDelayLoop:
	call Audio_Update
	xor a
	ld [wVBlankPending], a
RunScrollingScene_ABNotHeldDelayWaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, RunScrollingScene_ABNotHeldDelayWaitVBlank
	xor a
	ld [wVBlankPending], a
	halt
	nop
	nop
	dec d
	jr nz, RunScrollingScene_ABNotHeldDelayLoop
	jr RunScrollingScene_FrameLoop

RunScrollingScene_Exit:
	ld d, $3C
	call Func_3971
	call FadeOutSceneBackground
	ld a, $01
	ldh [hSceneWriteOnlyFlag], a
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
	ld hl, hScenePalette7BufferA
ClearSceneSplitPalettes_ClearLoop:
	ld [hli], a
	dec e
	jr nz, ClearSceneSplitPalettes_ClearLoop
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
	ld bc, hScenePalette7BufferA
	ld e, $10
ApplySceneTargetPalettes_CopyLoop:
	ld a, [hli]
	ld [bc], a
	inc bc
	dec e
	jr nz, ApplySceneTargetPalettes_CopyLoop
	xor a
	ld [wVBlankPending], a
ApplySceneTargetPalettes_WaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, ApplySceneTargetPalettes_WaitVBlank
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
FadeInSceneBackground_StepLoop:
	xor a
	ld [wVBlankPending], a
FadeInSceneBackground_WaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, FadeInSceneBackground_WaitVBlank
	xor a
	ld [wVBlankPending], a
	call Audio_Update
	ld a, d
	cp $10
	jr nc, FadeInSceneBackground_UseFinalColors
	ld hl, wScenePaletteFadeTable
	ldh a, [hScenePaletteFadeOffset]
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	jr FadeInSceneBackground_CopyColors

FadeInSceneBackground_UseFinalColors:
	ld hl, wScrollingSceneColours
FadeInSceneBackground_CopyColors:
	ld bc, hScenePalette7BufferB
	ld e, $08
FadeInSceneBackground_CopyColorsLoop:
	ld a, [hli]
	ld [bc], a
	inc bc
	dec e
	jr nz, FadeInSceneBackground_CopyColorsLoop
	ldh a, [hScenePaletteFadeOffset]
	sub $08
	ldh [hScenePaletteFadeOffset], a
	push de
	ld bc, hScenePalette7BufferA
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
	jr c, FadeInSceneBackground_StepLoop
	ret


FadeOutSceneBackground:
	push af
	push bc
	push de
	push hl
	ld a, $00
	ldh [hScenePaletteFadeOffset], a
	ld d, $1E
FadeOutSceneBackground_StepLoop:
	xor a
	ld [wVBlankPending], a
FadeOutSceneBackground_WaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, FadeOutSceneBackground_WaitVBlank
	xor a
	ld [wVBlankPending], a
	call Audio_Update
	ld a, d
	cp $10
	jr c, FadeOutSceneBackground_ApplySplitFade
	ldh a, [hSceneLcdStepLimit]
	dec a
	cp $FF
	jr nz, FadeOutSceneBackground_StoreLcdStepLimit
	xor a
FadeOutSceneBackground_StoreLcdStepLimit:
	ldh [hSceneLcdStepLimit], a
	ld hl, wScenePaletteFadeTable
	ldh a, [hScenePaletteFadeOffset]
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld bc, hScenePalette7BufferB
	ld e, $08
FadeOutSceneBackground_CopyColorsLoop:
	ld a, [hli]
	ld [bc], a
	inc bc
	dec e
	jr nz, FadeOutSceneBackground_CopyColorsLoop
	ldh a, [hScenePaletteFadeOffset]
	add a, $08
	ldh [hScenePaletteFadeOffset], a
FadeOutSceneBackground_ApplySplitFade:
	push de
	ld bc, hScenePalette7BufferA
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
	jr c, FadeOutSceneBackground_StepLoop
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
RunMenuGridSceneScroll_WaitVBlankBeforeFill:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, RunMenuGridSceneScroll_WaitVBlankBeforeFill
	xor a
	ld [wVBlankPending], a
	xor a
	ldh [hScenePalette7BufferB], a
	ldh [hScenePalette7BufferB + 1], a
	ldh [hScenePalette7BufferB + 2], a
	ldh [hScenePalette7BufferB + 3], a
	ldh [hScenePalette7BufferB + 4], a
	ldh [hScenePalette7BufferB + 5], a
	ldh [hScenePalette7BufferB + 6], a
	ldh [hScenePalette7BufferB + 7], a
	ld hl, $9800
	ld b, $FF
	ld d, $20
RunMenuGridSceneScroll_FillRowLoop:
	ld e, $14
RunMenuGridSceneScroll_FillWaitDraw:
	ldh a, [rSTAT]
	and $02
	jr z, RunMenuGridSceneScroll_FillWaitDraw
RunMenuGridSceneScroll_FillWaitBlank:
	ldh a, [rSTAT]
	and $02
	jr nz, RunMenuGridSceneScroll_FillWaitBlank
	ld a, b
	ld [hli], a
	dec e
	jr nz, RunMenuGridSceneScroll_FillWaitDraw
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	res 2, h
	dec d
	jr nz, RunMenuGridSceneScroll_FillRowLoop
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
	ldh [hSceneScrollIndex], a
	xor a
	ldh [hSceneRowTileBase], a
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
	ldh [hSceneRow], a
	ld a, $38
	ldh [hSceneWaitCountdown], a
	call ApplySceneTargetPalettes
RunMenuGridSceneScroll_FrameLoop:
	call Audio_Update
	xor a
	ld [wVBlankPending], a
RunMenuGridSceneScroll_FrameWaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, RunMenuGridSceneScroll_FrameWaitVBlank
	xor a
	ld [wVBlankPending], a
	call AdvanceSceneScroll
	ldh a, [hSceneScrollEnded]
	or a
	jr nz, RunMenuGridSceneScroll_Exit
	ld a, [wJoypadHeld]
	and PADF_START
	jr nz, RunMenuGridSceneScroll_Exit
	ld e, $24
	call Audio_QueueSound
	ldh a, [hSceneWaitCountdown]
	dec a
	ldh [hSceneWaitCountdown], a
	jr nz, RunMenuGridSceneScroll_FrameLoop
RunMenuGridSceneScroll_Exit:
	ld a, $01
	ldh [hSceneWriteOnlyFlag], a
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
	ldh [hSceneFixedIndex], a
	ld a, $01
	ldh [hSceneBankSwitchGuard], a
	call CopyFixedSceneDescriptor
	call Func_3960
	ld a, $01
	ldh [hSceneWriteOnlyFlag], a
	xor a
	ld [wVBlankPending], a
LoadFixedSceneForRow_WaitVBlankBeforeLoad:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, LoadFixedSceneForRow_WaitVBlankBeforeLoad
	xor a
	ld [wVBlankPending], a
	ld a, $B4
	ldh [rWX], a
	ldh [hSceneWxCopy], a
	xor a
	ldh [rWY], a
	ldh [hSceneWindowSplitCountdown], a
	call LoadFixedSceneResources
	xor a
	ldh [hSceneBankSwitchGuard], a
	xor a
	ldh [hSceneWindowSplitCountdown], a
	ldh [rWY], a
	ld a, $07
	ldh [hSceneWxCopy], a
	ldh [rWX], a
	xor a
	ld [wVBlankPending], a
LoadFixedSceneForRow_WaitVBlankAfterLoad:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, LoadFixedSceneForRow_WaitVBlankAfterLoad
	xor a
	ld [wVBlankPending], a
	ld a, $00
	ldh [hSceneWriteOnlyFlag], a
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
	ldh [hSceneScrollIndex], a
	xor a
	ldh [hSceneRowTileBase], a
	ldh [hSceneTileSlot], a
	ldh [hSceneRow], a
	call CopyScrollingSceneDescriptor
	call LoadScrollingScenePalette
	ld e, $06
	push de
LoadScrollVariantForGridCell_RowLoop:
	xor a
	ld [wVBlankPending], a
LoadScrollVariantForGridCell_WaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, LoadScrollVariantForGridCell_WaitVBlank
	xor a
	ld [wVBlankPending], a
	ldh a, [hSceneTileSlot]
	ld e, a
	call DrawNextSceneRow
	ldh a, [hSceneRow]
	inc a
	ldh [hSceneRow], a
	pop de
	dec e
	push de
	jr nz, LoadScrollVariantForGridCell_RowLoop
	pop de
	ldh a, [hSceneScrollY]
	add a, $30
	ldh [hSceneScrollY], a
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
	ldh [hSceneFixedIndex], a
	ld a, [hl]
	ldh [hSceneScrollIndex], a
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
	ldh [hSceneFixedIndex], a
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
	ldh [hSceneScrollIndex], a
	ret


AdvanceSceneScrollRomImage:
	LOAD UNION "RAM code $D1B0", WRAMX[$D1B0] ; copied from $01:6401

AdvanceSceneScroll:
	ldh a, [hSceneScrollStep]
	ld e, a
	ldh a, [hSceneScrollY]
	add a, e
	ldh [hSceneScrollY], a
	ldh a, [hSceneRowPixelPhase]
	add a, e
	cp $08
	jr c, AdvanceSceneScroll_StoreFineScroll
	sub $08
	ldh [hSceneRowPixelPhase], a
	ld e, $00
	call DrawNextSceneRow
	ldh a, [hSceneLastRow]
	ld e, a
	ldh a, [hSceneRow]
	cp e
	jr nc, AdvanceSceneScroll_RowLimitReached
	; Original: this store is overwritten by the store after inc a (redundant).
	ldh [hSceneRow], a
	inc a
	ldh [hSceneRow], a
	jr AdvanceSceneScroll_Return

AdvanceSceneScroll_RowLimitReached:
	ld a, $01
	ldh [hSceneScrollEnded], a
	jr AdvanceSceneScroll_Return

AdvanceSceneScroll_StoreFineScroll:
	ldh [hSceneRowPixelPhase], a
AdvanceSceneScroll_Return:
	ret

	ENDL
	db $00

ComputeSceneRowPointerRomImage:
	LOAD UNION "RAM code $D1F0", WRAMX[$D1F0] ; copied from $01:6432

ComputeSceneRowPointer:
	ldh a, [hSceneRomBank]
	ld a, a
	ld [rROMB0], a
	ld hl, wScrollingSceneRows
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ldh a, [hSceneRow]
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
	ldh [hSceneRowSourcePointer], a
	ld a, h
	ldh [hSceneRowSourcePointer + 1], a
	ld a, $01
	ld [rROMB0], a
	ret

	ENDL
	db $00

GetSceneTileSourceAddressRomImage:
	LOAD UNION "RAM code $D230", WRAMX[$D230] ; copied from $01:6468

GetSceneTileSourceAddress:
	ldh a, [hSceneDescriptorPointer]
	ld l, a
	ldh a, [hSceneDescriptorPointer + 1]
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

DrawNextSceneRowRomImage:
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
	jr c, DrawNextSceneRow_StoreTileSlot
	xor a
DrawNextSceneRow_StoreTileSlot:
	ldh [hSceneTileSlot], a
	ldh a, [hSceneRowTileBase]
	add a, $14
	cp $78
	jr nz, DrawNextSceneRow_CheckTileIndexWrap
	ld a, $80
DrawNextSceneRow_CheckTileIndexWrap:
	cp $94
	jr c, DrawNextSceneRow_StoreTileIndex
	xor a
DrawNextSceneRow_StoreTileIndex:
	ldh [hSceneRowTileBase], a
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
	jr c, ComputeSceneRowMapAddress_RowToOffset
	sub $20
ComputeSceneRowMapAddress_RowToOffset:
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
	ldh [hSceneRowMapAddress], a
	ld a, h
	ldh [hSceneRowMapAddress + 1], a
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

StageSceneRowTilesRomImage:
	LOAD UNION "RAM code $D370", WRAMX[$D370] ; copied from $01:6505

StageSceneRowTiles:
	call ComputeSceneRowPointer
	ldh a, [hSceneRomBank]
	ld a, a
	ld [rROMB0], a
	ld de, $0000
StageSceneRowTiles_TileLoop:
	ldh a, [hSceneRowSourcePointer]
	ld c, a
	ldh a, [hSceneRowSourcePointer + 1]
	ld b, a
	call GetSceneTileSourceAddress
	call CopySceneTileToStaging
	ldh a, [hSceneRowSourcePointer]
	ld c, a
	ldh a, [hSceneRowSourcePointer + 1]
	ld b, a
	inc bc
	inc bc
	ld a, c
	ldh [hSceneRowSourcePointer], a
	ld a, b
	ldh [hSceneRowSourcePointer + 1], a
	inc e
	ld a, e
	cp $14
	jr c, StageSceneRowTiles_TileLoop
	ld a, $01
	ld [rROMB0], a
	ret

	ENDL
	db $00

CopySceneTileToStagingRomImage:
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
CopySceneTileToStaging_ByteLoop:
	ld a, [hli]
	ld [bc], a
	inc bc
	dec e
	jr nz, CopySceneTileToStaging_ByteLoop
	pop hl
	pop de
	pop bc
	pop af
	ret

	ENDL
	db $00

WriteSceneRowTileIndices:
	ld e, $14
	ldh a, [hSceneRowMapAddress]
	ld l, a
	ld c, a
	ldh a, [hSceneRowMapAddress + 1]
	ld h, a
	ld b, a
	ldh a, [hSceneRowTileBase]
	ld d, a
WriteSceneRowTileIndices_TileLoop:
	xor a
	ldh [rVBK], a
WriteSceneRowTileIndices_WaitBlank:
	ldh a, [rSTAT]
	and $02
	jr nz, WriteSceneRowTileIndices_WaitBlank
	ld a, d
	ld [hli], a
	inc d
	dec e
	jr nz, WriteSceneRowTileIndices_TileLoop
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


UnusedSceneRamNoOpRomImage:
	LOAD UNION "RAM code (callerless) $D260", WRAMX[$D260] ; copied from $01:6599
UnusedSceneRamNoOp:
	ret
	ENDL
	db $00

CopyScrollingSceneDescriptor:
	ld hl, ScrollingSceneDescriptors
	ldh a, [hSceneScrollIndex]
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
	ldh a, [hSceneFixedIndex]
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
	ld hl, LoadFixedSceneResourcesRomImage
	ld de, $0114
	ld bc, $D000
	call CopyBytes
	ld hl, EnableSceneWindowRomImage
	ld de, $000F
	ld bc, $D120
	call CopyBytes
	ld hl, DisableSceneWindowRomImage
	ld de, $000B
	ld bc, $D130
	call CopyBytes
	ld hl, StepSceneWindowSplitRomImage
	ld de, $001A
	ld bc, $D140
	call CopyBytes
	ld hl, LoadScrollingScenePaletteRomImage
	ld de, $0042
	ld bc, $D160
	call CopyBytes
	ld hl, AdvanceSceneScrollRomImage
	ld de, $0030
	ld bc, $D1B0
	call CopyBytes
	ld hl, ComputeSceneRowPointerRomImage
	ld de, $0035
	ld bc, $D1F0
	call CopyBytes
	ld hl, GetSceneTileSourceAddressRomImage
	ld de, $0025
	ld bc, $D230
	call CopyBytes
	ld hl, UnusedSceneRamNoOpRomImage
	ld de, $0001
	ld bc, $D260
	call CopyBytes
	ld hl, BuildScenePaletteFadeTableRomImage
	ld de, $0043
	ld bc, $D270
	call CopyBytes
	ld hl, WriteBgPalette7FromD3F8RomImage
	ld de, $0029
	ld bc, $D2C0
	call CopyBytes
	ld hl, WriteBgPalette7FromFFA0RomImage
	ld de, $001B
	ld bc, $D2F0
	call CopyBytes
	ld hl, WriteBgPalette7FromFF98RomImage
	ld de, $001B
	ld bc, $D310
	call CopyBytes
	ld hl, DrawNextSceneRowRomImage
	ld de, $002C
	ld bc, $D330
	call CopyBytes
	ld hl, StageSceneRowTilesRomImage
	ld de, $0032
	ld bc, $D370
	call CopyBytes
	ld hl, CopySceneTileToStagingRomImage
	ld de, $0029
	ld bc, $D3B0
	call CopyBytes
	ret

PasswordBitPositionTable:
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
	jr nz, CycleObjectPalettes12_NextFrame
	ld a, $FF
CycleObjectPalettes12_NextFrame:
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
Draw2x2GlyphTiles_TopRowWaitDraw:
	ldh a, [rSTAT]
	and $02
	jr z, Draw2x2GlyphTiles_TopRowWaitDraw
Draw2x2GlyphTiles_TopRowWaitBlank:
	ldh a, [rSTAT]
	and $02
	jr nz, Draw2x2GlyphTiles_TopRowWaitBlank
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
Draw2x2GlyphTiles_BottomRowWaitDraw:
	ldh a, [rSTAT]
	and $02
	jr z, Draw2x2GlyphTiles_BottomRowWaitDraw
Draw2x2GlyphTiles_BottomRowWaitBlank:
	ldh a, [rSTAT]
	and $02
	jr nz, Draw2x2GlyphTiles_BottomRowWaitBlank
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
DrawPasswordEntryChars_CharLoop:
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
	jr nz, DrawPasswordEntryChars_CharLoop
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
	call ConvertU32ToPackedBcdFar
	ld hl, ScoreDigitColumns
	xor a
	ldh [hScoreDigitsStarted], a
	ld bc, $FFB2
	ld e, $05
DrawScoreDigitsAtRow_DigitLoop:
	ld a, e
	and $01
	jr z, DrawScoreDigitsAtRow_LowNibble
	ld a, [bc]
	swap a
	and $0F
	jr DrawScoreDigitsAtRow_CheckLeadingZero

DrawScoreDigitsAtRow_LowNibble:
	ld a, [bc]
	and $0F
	inc c
DrawScoreDigitsAtRow_CheckLeadingZero:
	ld d, a
	or a
	jr z, DrawScoreDigitsAtRow_TestDraw
	ld a, $01
	ldh [hScoreDigitsStarted], a
DrawScoreDigitsAtRow_TestDraw:
	ld a, d
	or a
	jr nz, DrawScoreDigitsAtRow_DrawDigit
	ldh a, [hScoreDigitsStarted]
	or a
	jr nz, DrawScoreDigitsAtRow_DrawDigit
	jr DrawScoreDigitsAtRow_NextDigit

DrawScoreDigitsAtRow_DrawDigit:
	ld a, [hl]
	ld [wGlyphColumn], a
	ld a, d
	and $0F
	or $80
	call Draw2x2GlyphTiles
DrawScoreDigitsAtRow_NextDigit:
	inc hl
	dec e
	jr nz, DrawScoreDigitsAtRow_DigitLoop
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
	call ConvertU8ToPackedBcdFar
	ldh a, [$FFB1]
	ld d, a
	swap a
	and $0F
	jr z, DrawLivesDigitsAtRow_DrawOnes
	or $80
	call Draw2x2GlyphTiles
DrawLivesDigitsAtRow_DrawOnes:
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
	jr nz, StepPasswordCursorSprites_Move
	ld a, $00
	pop bc
	pop de
	pop hl
	ret

StepPasswordCursorSprites_Move:
	ld a, b
	cp e
	jr nc, StepPasswordCursorSprites_MoveRight
	sub e
	cp $01
	jr z, StepPasswordCursorSprites_ApplyStep
	sra a
	jr StepPasswordCursorSprites_ApplyStep

StepPasswordCursorSprites_MoveRight:
	sub e
	cp $01
	jr z, StepPasswordCursorSprites_ApplyStep
	srl a
StepPasswordCursorSprites_ApplyStep:
	add a, e
	ld [wPasswordCursorX], a
	ld d, a
	ld hl, $FE21
	ld bc, $FE31
StepPasswordCursorSprites_WaitOam21:
	ldh a, [rSTAT]
	and $02
	jr nz, StepPasswordCursorSprites_WaitOam21
	ld a, d
	ld [hl], a
	ld [bc], a
	ld hl, $FE29
	ld bc, $FE39
StepPasswordCursorSprites_WaitOam29:
	ldh a, [rSTAT]
	and $02
	jr nz, StepPasswordCursorSprites_WaitOam29
	ld a, d
	ld [hl], a
	ld [bc], a
	add a, $08
	ld d, a
	ld hl, $FE25
	ld bc, $FE35
StepPasswordCursorSprites_WaitOam25:
	ldh a, [rSTAT]
	and $02
	jr nz, StepPasswordCursorSprites_WaitOam25
	ld a, d
	ld [hl], a
	ld [bc], a
	ld hl, $FE2D
	ld bc, $FE3D
StepPasswordCursorSprites_WaitOam2D:
	ldh a, [rSTAT]
	and $02
	jr nz, StepPasswordCursorSprites_WaitOam2D
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
SnapPasswordCursorSprites_WaitBusy1:
	ldh a, [rSTAT]
	and $02
	jr z, SnapPasswordCursorSprites_WaitBusy1
SnapPasswordCursorSprites_WaitFree1:
	ldh a, [rSTAT]
	and $02
	jr nz, SnapPasswordCursorSprites_WaitFree1
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
SnapPasswordCursorSprites_WaitBusy2:
	ldh a, [rSTAT]
	and $02
	jr z, SnapPasswordCursorSprites_WaitBusy2
SnapPasswordCursorSprites_WaitFree2:
	ldh a, [rSTAT]
	and $02
	jr nz, SnapPasswordCursorSprites_WaitFree2
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
MovePasswordCursorOffscreen_WaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, MovePasswordCursorOffscreen_WaitVBlank
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
	ld hl, PasswordBitPositionTable
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
	jr z, PasswordBitsWriteNext_Store
PasswordBitsWriteNext_ShiftLoop:
	sla e
	dec a
	jr nz, PasswordBitsWriteNext_ShiftLoop
PasswordBitsWriteNext_Store:
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
	ld hl, PasswordBitPositionTable
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
	jr z, PasswordBitsReadPrev_ExtractBit
PasswordBitsReadPrev_ShiftLoop:
	srl d
	dec a
	jr nz, PasswordBitsReadPrev_ShiftLoop
PasswordBitsReadPrev_ExtractBit:
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
	ld a, [wLevelNumber]
	inc a
	ldh [hPasswordLevelNumber], a
	call ClearPasswordBits
	call GetScoreThousandsFar
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
EncodePasswordFromProgress_ScoreBitLoop:
	ld a, c
	and $01
	call PasswordBitsWriteNext
	srl b
	rr c
	dec e
	jr nz, EncodePasswordFromProgress_ScoreBitLoop
	ld a, [wPlayerLives]
	ld d, a
	ld e, $04
EncodePasswordFromProgress_LivesBitLoop:
	ld a, d
	and $01
	call PasswordBitsWriteNext
	srl d
	dec e
	jr nz, EncodePasswordFromProgress_LivesBitLoop
	ldh a, [hPasswordLevelNumber]
	ld d, a
	ld e, $04
EncodePasswordFromProgress_LevelBitLoop:
	ld a, d
	and $01
	call PasswordBitsWriteNext
	srl d
	dec e
	jr nz, EncodePasswordFromProgress_LevelBitLoop
	ld a, [wPasswordChecksum]
	ld e, $07
	ld d, a
EncodePasswordFromProgress_ChecksumBitLoop:
	ld a, d
	and $01
	call PasswordBitsWriteNext
	srl d
	dec e
	jr nz, EncodePasswordFromProgress_ChecksumBitLoop
	ret


DecodePasswordBits:
Func_01_6C24: ; legacy alias, used by src/bank_2C.asm
	ld a, $18
	ld [wPasswordBitIndex], a
	ld e, $07
	ld c, $00
DecodePasswordBits_ChecksumBitLoop:
	call PasswordBitsReadPrev
	or c
	sla a
	ld c, a
	dec e
	jr nz, DecodePasswordBits_ChecksumBitLoop
	srl c
	ld a, c
	ld [wPasswordChecksum], a
	ld e, $04
	ld c, $00
DecodePasswordBits_LevelBitLoop:
	call PasswordBitsReadPrev
	or c
	sla a
	ld c, a
	dec e
	jr nz, DecodePasswordBits_LevelBitLoop
	srl c
	ld a, c
	ld [wPasswordLevel], a
	ld b, $0E
	cp b
	jr c, DecodePasswordBits_ReadLives
	jr nz, DecodePasswordBits_Reject
DecodePasswordBits_ReadLives:
	ld e, $04
	ld c, $00
DecodePasswordBits_LivesBitLoop:
	call PasswordBitsReadPrev
	or c
	sla a
	ld c, a
	dec e
	jr nz, DecodePasswordBits_LivesBitLoop
	srl c
	ld a, c
	ld [wPasswordLives], a
	ld bc, $0000
	ld e, $0A
DecodePasswordBits_ScoreBitLoop:
	call PasswordBitsReadPrev
	or c
	ld c, a
	sla c
	rl b
	dec e
	jr nz, DecodePasswordBits_ScoreBitLoop
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
	jr z, DecodePasswordBits_Return
DecodePasswordBits_Reject:
	xor a
	ld [wPasswordScoreThousands], a
	ld [wPasswordScoreThousands + 1], a
	ld [wPasswordLives], a
	ld [wPasswordLevel], a
DecodePasswordBits_Return:
	ret


ComputePasswordChecksum:
	push af
	push de
	push bc
	ld d, $05
	ld a, [wPasswordLevel]
	ld c, a
	; Original: L is used as a loop counter but HL is not saved; callers do not read HL afterwards.
	ld l, $04
ComputePasswordChecksum_LevelBitLoop:
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
	jr nz, ComputePasswordChecksum_LevelBitLoop
	ld a, [wPasswordLives]
	ld c, a
	ld l, $04
ComputePasswordChecksum_LivesBitLoop:
	ld a, c
	and $01
	ld e, a
	ld a, d
	add a, e
	add a, e
	ld d, a
	srl c
	dec l
	jr nz, ComputePasswordChecksum_LivesBitLoop
	ld a, [wPasswordScoreThousands]
	ld c, a
	ld a, [wPasswordScoreThousands + 1]
	ld b, a
	ld l, $0A
ComputePasswordChecksum_ScoreBitLoop:
	ld a, c
	and $01
	add a, d
	ld d, a
	srl b
	rr c
	dec l
	jr nz, ComputePasswordChecksum_ScoreBitLoop
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
ShowEarnedPasswordScreen_WaitVBlank1:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, ShowEarnedPasswordScreen_WaitVBlank1
	xor a
	ld [wVBlankPending], a
	ld a, $06
	call ScreenTable_CallInit
	xor a
	ld [wVBlankPending], a
ShowEarnedPasswordScreen_WaitVBlank2:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, ShowEarnedPasswordScreen_WaitVBlank2
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
UnpackPasswordChars_CharLoop:
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
	jr nz, UnpackPasswordChars_CharLoop
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
PackPasswordChars_CharLoop:
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
	jr z, PackPasswordChars_Store
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
	jr nz, PackPasswordChars_CharLoop
PackPasswordChars_Store:
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
	call GetScoreThousandsFar
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

; Draws score and lives only; the password tiles and palettes are loaded but no
; password characters are unpacked or drawn.
ShowScreenMode12WithScoreAndLives:
ShowScreenMode12WithPasswordScoreLives: ; legacy alias
Func_01_6E44: ; legacy alias (automatic entry label)
	call Func_3960
	call PrepareDisplayForScreenTransition
	xor a
	ld [wVBlankPending], a
ShowScreenMode12WithScoreAndLives_WaitVBlank1:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, ShowScreenMode12WithScoreAndLives_WaitVBlank1
	xor a
	ld [wVBlankPending], a
	ld a, $0C
	call ScreenTable_CallInit
	xor a
	ld [wVBlankPending], a
ShowScreenMode12WithScoreAndLives_WaitVBlank2:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, ShowScreenMode12WithScoreAndLives_WaitVBlank2
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
FillBgRectWithTileAttr_RowLoop:
	ld e, d
FillBgRectWithTileAttr_TileLoop:
	ldh a, [rSTAT]
	and $02
	jr nz, FillBgRectWithTileAttr_TileLoop
	ld a, $01
	ldh [rVBK], a
	ld a, [wBgFillTileAttr + 1]
	ld [hl], a
	xor a
	ldh [rVBK], a
	ld a, [wBgFillTileAttr]
	ld [hli], a
	dec e
	jr nz, FillBgRectWithTileAttr_TileLoop
	ld a, $20
	sub d
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	dec c
	jr nz, FillBgRectWithTileAttr_RowLoop
	ret

; Unreferenced. Earlier form of ShowPasswordRejection: no sound, counter $11, one
; CopyBankedTilemapRowsToBG call per frame. Original defect kept: the reload repeats `ld bc` where
; the first pass loads `ld de`, so DE is never reloaded.
UnusedPasswordRejectionVariant:
	ld a, $2C
	ld hl, wBankedBgSourceBank
	ld [hl], a
	ld a, $11
	ld bc, CodeRejectedTileMap
	ld de, CodeRejectedAttrMap
	call SetBankedRowSourcePtrs
	ld a, $01
	ld hl, wBgCopyRow
	ld [hl], a
	ld a, $01
	ld hl, wBgCopyReloadCount
	ld [hl], a
	ld a, $11
	push af
.l7954:
	xor a
	ld [wVBlankPending], a
.l7958:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, .l7958
	xor a
	ld [wVBlankPending], a
	call CopyBankedTilemapRowsToBG
	ld hl, wBgCopyReloadCount
	ld a, [hl]
	inc a
	ld [hl], a
	pop af
	dec a
	cp $FF
	jr z, .l7980
	push af
	ld bc, CodeRejectedTileMap
	ld bc, CodeRejectedTileMap
	call SetBankedRowSourcePtrs
	jr .l7954
.l7980:
	ret
	ASSERT @ - UnusedPasswordRejectionVariant == 77

ShowPasswordRejection:
	ld a, $2C
	ld hl, wBankedBgSourceBank
	ld [hl], a
	ld a, $01
	ld hl, wBgCopyReloadCount
	ld [hl], a
	ld e, $22
	call Audio_QueueSound
	ld a, $08
	ld [wBgRevealCounter], a
ShowPasswordRejection_FrameLoop:
	call Audio_Update
	xor a
	ld [wVBlankPending], a
ShowPasswordRejection_WaitVBlank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, ShowPasswordRejection_WaitVBlank
	xor a
	ld [wVBlankPending], a
	ld a, $01
	ld hl, wBgCopyRow
	ld [hl], a
	ld a, [wBgRevealCounter]
	ld bc, CodeRejectedTileMap
	ld de, CodeRejectedAttrMap
	call SetBankedRowSourcePtrs
	call CopyBankedTilemapRowsToBG
	ld a, [wBgRevealCounter]
	inc a
	add a, $09
	ld hl, wBgCopyRow
	ld [hl], a
	ld a, $09
	ld bc, CodeRejectedTileMap
	ld de, CodeRejectedAttrMap
	call SetBankedRowSourcePtrs
	call CopyBankedTilemapRowsToBG
	ld a, [wBgRevealCounter]
	dec a
	ld [wBgRevealCounter], a
	cp $FF
	jr z, ShowPasswordRejection_Done
	ld hl, wBgCopyReloadCount
	ld a, [hl]
	inc a
	ld [hl], a
	jr ShowPasswordRejection_FrameLoop

ShowPasswordRejection_Done:
	ret

; Unreferenced variant of ScrollSceneInFromLeft: grows the copy width instead of
; stepping SCX. Only writer of wUnusedC954.
UnusedWipeSceneInFromLeft:
	xor a
	ld [wUnusedC954], a
	ld a, [wSceneBank]
	ld hl, wBankedBgSourceBank
	ld [hl], a
	ld hl, wBgCopyColumn
	xor a
	ld [hl], a
	ld hl, wBgCopyRow
	ld a, $01
	ld [hl], a
	ld hl, wBgCopyWidth
	ld a, $01
	ld [hl], a
	ld a, $14
	ld [wBgRevealCounter], a
.l7A0D:
	xor a
	ld [wVBlankPending], a
.l7A11:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, .l7A11
	xor a
	ld [wVBlankPending], a
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
	call CopyBankedTilemapRectToBG
	ld hl, wBgCopyWidth
	ld a, [hl]
	inc a
	ld [hl], a
	ld a, [wBgRevealCounter]
	dec a
	ld [wBgRevealCounter], a
	jr nz, .l7A0D
	ret

; Unreferenced variant of ScrollSceneInFromRight (width grows, no SCX step).
UnusedWipeSceneInFromRight:
	xor a
	ld [wUnusedC954], a
	ld a, [wSceneBank]
	ld hl, wBankedBgSourceBank
	ld [hl], a
	ld a, $13
	ld [wBgRevealCounter], a
	ld [wBgCopyColumn], a
	ld a, $01
	ld [wBgCopyRow], a
.l7A60:
	xor a
	ld [wVBlankPending], a
.l7A64:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, .l7A64
	xor a
	ld [wVBlankPending], a
	ld hl, wBgRevealCounter
	ld a, $14
	sub [hl]
	ld [wBgCopyWidth], a
	ld a, [wBgRevealCounter]
	ld [wBgCopyColumn], a
	ld a, [wSceneTileAttrPtrs]
	ld c, a
	ld a, [wSceneTileAttrPtrs + 1]
	ld b, a
	ld a, [wSceneTileAttrPtrs + 2]
	ld e, a
	ld a, [wSceneTileAttrPtrs + 3]
	ld d, a
	xor a
	call SetBankedSourcePtrsOffset
	call CopyBankedTilemapRectToBG
	ld a, [wBgRevealCounter]
	dec a
	ld [wBgRevealCounter], a
	cp $FF
	jr nz, .l7A60
	ret
	ASSERT @ - UnusedWipeSceneInFromLeft == 183

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

; Unreferenced variant of ScrollSceneOutFillFromLeft: counts 0 up to $12, copies then
; fills, no SCX step.
UnusedRevealSceneFillFromLeft:
	ld a, [wSceneBank]
	ld [wBankedBgSourceBank], a
	ld a, $00
	ld [wBgRevealCounter], a
	ld [wBgCopyColumn], a
	ld a, $01
	ld [wBgCopyRow], a
.l7B03:
	xor a
	ld [wVBlankPending], a
.l7B07:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, .l7B07
	xor a
	ld [wVBlankPending], a
	ld a, [wSceneTileAttrPtrs]
	ld c, a
	ld a, [wSceneTileAttrPtrs + 1]
	ld b, a
	ld a, [wSceneTileAttrPtrs + 2]
	ld e, a
	ld a, [wSceneTileAttrPtrs + 3]
	ld d, a
	ld a, [wBgRevealCounter]
	inc a
	call SetBankedSourcePtrsOffset
	xor a
	ld [wBgCopyColumn], a
	ld a, [wBgRevealCounter]
	inc a
	ld b, a
	ld a, $14
	sub b
	ld [wBgCopyWidth], a
	call CopyBankedTilemapRectToBG
	call LoadScrollingScreenFillCell
	ld a, [wBgCopyWidth]
	ld [wBgCopyColumn], a
	ld a, [wBgRevealCounter]
	inc a
	ld [wBgCopyWidth], a
	call FillBgRectWithTileAttr
	ld a, [wBgRevealCounter]
	inc a
	ld [wBgRevealCounter], a
	cp $13
	jr nz, .l7B03
	ret

; Unreferenced variant of ScrollSceneOutFillFromRight (see above).
UnusedRevealSceneFillFromRight:
	ld a, [wSceneBank]
	ld [wBankedBgSourceBank], a
	ld a, $00
	ld [wBgRevealCounter], a
	ld [wBgCopyColumn], a
	ld a, $01
	ld [wBgCopyRow], a
.l7B6F:
	xor a
	ld [wVBlankPending], a
.l7B73:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, .l7B73
	xor a
	ld [wVBlankPending], a
	ld a, [wSceneTileAttrPtrs]
	ld c, a
	ld a, [wSceneTileAttrPtrs + 1]
	ld b, a
	ld a, [wSceneTileAttrPtrs + 2]
	ld e, a
	ld a, [wSceneTileAttrPtrs + 3]
	ld d, a
	xor a
	call SetBankedSourcePtrsOffset
	ld a, [wBgRevealCounter]
	inc a
	ld [wBgCopyColumn], a
	ld a, [wBgRevealCounter]
	inc a
	ld b, a
	ld a, $14
	sub b
	ld [wBgCopyWidth], a
	call CopyBankedTilemapRectToBG
	call LoadScrollingScreenFillCell
	ld a, [wBgCopyColumn]
	ld [wBgCopyWidth], a
	xor a
	ld [wBgCopyColumn], a
	call FillBgRectWithTileAttr
	ld a, [wBgRevealCounter]
	inc a
	ld [wBgRevealCounter], a
	cp $13
	jr nz, .l7B6F
	ret
	ASSERT @ - UnusedRevealSceneFillFromLeft == 213

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
	call LoadScrollingScreenFillCell
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
	call LoadScrollingScreenFillCell
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
	call LoadScrollingScreenFillCell
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
FreeObjectsOutsideStatuses1And4_ObjectLoop:
	ld e, l
	ld a, $1D
	add a, e
	ld l, a
	ld a, [hl]
	ld l, e
	cp $04
	jr z, FreeObjectsOutsideStatuses1And4_NextObject
	cp $01
	jr z, FreeObjectsOutsideStatuses1And4_NextObject
	call FreeObjectRecord
FreeObjectsOutsideStatuses1And4_NextObject:
	ld a, e
	add a, $40
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	dec d
	jr nz, FreeObjectsOutsideStatuses1And4_ObjectLoop
	ret

Bank01ZeroFill: ; no reader; zero fill to the bank marker
	ds $7FFF - @, $00
	db BANK(@) ; ROM bank marker

; Relocation pins: ROM0 refers to these with raw numbers (src/bank_00.asm is not edited here).
