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
ASSERT @ - LevelObjectSequenceTables == $1E

InitializeObjectSequenceState:
	push af
	push bc
	push de
	push hl
	push hl
	push bc
	push hl
	ld a, [wLevelNumber]
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
	add a, OBJECT_SEQUENCE_SLOT_FLAGS_OFFSET
	ld l, a
	pop af
	ld [hl], a
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_TURN_STEP_OFFSET
	ld l, a
	ld a, $01
	ld [hl], a
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_RECORD_INDEX_OFFSET
	ld l, a
	xor a
	ld [hl], a
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_REVERSE_FLAG_OFFSET
	ld l, a
	xor a
	ld [hl], a
	pop de
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_SLOT_FLAGS_OFFSET
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
	add a, OBJECT_SEQUENCE_RECORD_INDEX_OFFSET
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
	add a, OBJECT_SEQUENCE_TARGET_HEADING_OFFSET
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
	add a, OBJECT_SEQUENCE_TARGET_X_OFFSET
	ld l, a
	ld [hl], c
	inc hl
	ld [hl], b
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_TARGET_Y_OFFSET
	ld l, a
	ld [hl], e
	inc hl
	ld [hl], d
	pop hl
	pop de
	pop bc
	pop af
	ret


UpdateObjectSequenceMovement:
Func_03_5CD0: ; legacy alias, used by src/bank_00.asm
	push af
	push bc
	push de
	push hl
	ld e, l
	ld d, h
	xor a
	ld [wForceRecordedPathAppend], a
	ld a, e
	and $C0
	add a, OBJECT_TYPE_OFFSET
	ld e, a
	ld a, [de]
	cp $02
	jp nz, UpdateObjectSequenceMovement_CheckThrottleBypass
	ld a, [wSequenceObjectsInState2Count]
	inc a
	ld [wSequenceObjectsInState2Count], a
UpdateObjectSequenceMovement_CheckThrottleBypass:
	ld a, e
	and $C0
	add a, $08
	ld e, a
	ld a, [de]
	and $08
	jr nz, UpdateObjectSequenceMovement_RunUpdate
	ld a, e
	and $C0
	add a, OBJECT_TYPE_OFFSET
	ld e, a
	ld a, [de]
	cp $03
	jp z, ObjectSequenceUpdateExit
	ld a, [wObjectSequenceThrottleCounter]
	inc a
	ld [wObjectSequenceThrottleCounter], a
	and $07
	jr z, UpdateObjectSequenceMovement_RunUpdate
	ld a, e
	and $C0
	add a, OBJECT_VEHICLE_SPEED_OFFSET
	ld e, a
	xor a
	ld [de], a
	jp ObjectSequenceUpdateExit

UpdateObjectSequenceMovement_RunUpdate:
	call CheckObjectAuxRegionTriggers
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_SLOT_FLAGS_OFFSET
	ld e, a
	ld a, [de]
	bit 6, a
	jp nz, UpdateObjectSequenceMovement_FollowRecordedPath
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_PROXIMITY_DELAY_OFFSET
	ld e, a
	ld a, [de]
	and a
	jr nz, UpdateObjectSequenceMovement_TickProximityDelay
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
	ld h, a
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_HIDE_TIMER_OFFSET
	ld l, a
	ld a, [hl]
	and a
	jr z, UpdateObjectSequenceMovement_CheckNearPlayer
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_HIDE_REVEAL_TIMER_OFFSET
	ld l, a
	ld a, [hl]
	and a
	jr z, UpdateObjectSequenceMovement_CompareHeading
UpdateObjectSequenceMovement_CheckNearPlayer:
	call CheckObjectNearPlayerBox
	jr UpdateObjectSequenceMovement_CompareHeading

UpdateObjectSequenceMovement_TickProximityDelay:
	dec a
	ld [de], a
	cp $20
	jr c, UpdateObjectSequenceMovement_CompareHeading
	ld a, e
	and $C0
	add a, OBJECT_VEHICLE_SPEED_OFFSET
	ld e, a
	xor a
	ld [de], a
	jp ObjectSequenceUpdateExit

UpdateObjectSequenceMovement_CompareHeading:
	ld a, e
	and $C0
	add a, OBJECT_DIRECTION_OFFSET
	ld e, a
	ld a, [de]
	ld b, a
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_TARGET_HEADING_OFFSET
	ld e, a
	ld a, [de]
	cp b
	jr z, UpdateObjectSequenceMovement_CheckActionTimer
	ld a, e
	and $C0
	add a, OBJECT_VEHICLE_SPEED_OFFSET
	ld e, a
	xor a
	ld [de], a
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_TURN_DELAY_OFFSET
	ld e, a
	ld a, [de]
	and a
	jr z, UpdateObjectSequenceMovement_TurnStep
	dec a
	ld [de], a
	jp ObjectSequenceUpdateExit

UpdateObjectSequenceMovement_TurnStep:
	push de
	ld a, e
	and $C0
	add a, OBJECT_VEHICLE_TURN_INTERVAL_OFFSET
	ld e, a
	ld a, [de]
	pop de
	ld [de], a
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_TURN_STEP_OFFSET
	ld e, a
	ld a, [de]
	ld c, a
	ld a, e
	and $C0
	add a, OBJECT_DIRECTION_OFFSET
	ld e, a
	ld a, [de]
	add a, c
	and $0F
	ld [de], a
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_ACTION_TIMER_OFFSET
	ld e, a
	ld a, [de]
	bit 7, a
	jr nz, UpdateObjectSequenceMovement_CheckActionTimer
	jp ObjectSequenceUpdateExit

UpdateObjectSequenceMovement_CheckActionTimer:
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_ACTION_TIMER_OFFSET
	ld e, a
	ld a, [de]
	ld b, a
	and a
	jr z, UpdateObjectSequenceMovement_CheckWaypoint
	bit 7, a
	jr z, UpdateObjectSequenceMovement_CountdownTimer
	and $7F
	dec a
	jr nz, UpdateObjectSequenceMovement_SpinStep
	xor a
	ld [de], a
	jr UpdateObjectSequenceMovement_CheckWaypoint

UpdateObjectSequenceMovement_SpinStep:
	or $80
	ld [de], a
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_TARGET_HEADING_OFFSET
	ld e, a
	ld a, [de]
	inc a
	and $0F
	ld [de], a
	jp ObjectSequenceUpdateExit

UpdateObjectSequenceMovement_CountdownTimer:
	ld a, [wObjectSlowTickCounter]
	and a
	jp nz, ObjectSequenceUpdateExit
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_ACTION_TIMER_OFFSET
	ld e, a
	ld a, b
	dec a
	ld [de], a
	jp ObjectSequenceUpdateExit

UpdateObjectSequenceMovement_CheckWaypoint:
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_SLOT_FLAGS_OFFSET
	ld e, a
	ld a, [de]
	bit 7, a
	jp nz, ObjectSequenceUpdateExit
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_TARGET_HEADING_OFFSET
	ld e, a
	ld a, [de]
	ld b, a
	ld a, e
	and $C0
	add a, OBJECT_DIRECTION_OFFSET
	ld e, a
	ld a, [de]
	cp b
	jp nz, ObjectSequenceUpdateExit
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_MOVEMENT_STATE_OFFSET
	ld e, a
	ld a, [de]
	and $F0
	jp z, ObjectSequenceUpdateExit
	push de
	ld l, e
	ld h, d
	ld bc, HandleSequenceWaypointArrival
	push bc
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_TARGET_Y_OFFSET
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
	add a, OBJECT_SEQUENCE_TARGET_X_OFFSET
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
	add a, OBJECT_SEQUENCE_TARGET_HEADING_OFFSET
	ld l, a
	ld a, [hl]
	ld h, a
	jp TestObjectPassedSequenceTarget

HandleSequenceWaypointArrival:
	pop de
	ld a, l
	and a
	jr z, HandleSequenceWaypointArrival_NotPassed
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_TARGET_X_OFFSET
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
	add a, OBJECT_SEQUENCE_TARGET_Y_OFFSET
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
	jr AdvanceObjectSequenceRecord

HandleSequenceWaypointArrival_NotPassed:
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_MOVEMENT_STATE_OFFSET
	ld e, a
	ld a, [de]
	and $F0
	jp z, ObjectSequenceUpdateExit
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_FALLBACK_SPEED_OFFSET
	ld e, a
	ld a, [de]
	push af
	ld a, e
	and $C0
	add a, OBJECT_VEHICLE_SPEED_OFFSET
	ld e, a
	pop af
	ld [de], a
	jp ObjectSequenceUpdateExit

AdvanceObjectSequenceRecord:
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_RECORD_INDEX_OFFSET
	ld e, a
	ld a, [de]
	ld b, a
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_REVERSE_FLAG_OFFSET
	ld e, a
	ld a, [de]
	and a
	jr z, AdvanceObjectSequenceRecord_StoreIndex
	dec b
	ld a, b
	and a
	jr nz, AdvanceObjectSequenceRecord_StepBack
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_REVERSE_FLAG_OFFSET
	ld e, a
	ld a, [de]
	cpl
	ld [de], a
	ld b, $00
AdvanceObjectSequenceRecord_StepBack:
	dec b
AdvanceObjectSequenceRecord_StoreIndex:
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_RECORD_INDEX_OFFSET
	ld e, a
	inc b
	ld a, b
	ld [de], a
	ld a, e
	and $C0
	add a, OBJECT_VEHICLE_SPEED_OFFSET
	ld e, a
	xor a
	ld [de], a
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_SLOT_FLAGS_OFFSET
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
	add a, OBJECT_SEQUENCE_RECORD_INDEX_OFFSET
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
	add a, OBJECT_SEQUENCE_REVERSE_FLAG_OFFSET
	ld e, a
	ld a, [de]
	and a
	jr z, AdvanceObjectSequenceRecord_SetTargetHeading
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
AdvanceObjectSequenceRecord_SetTargetHeading:
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_TARGET_HEADING_OFFSET
	ld e, a
	ld a, b
	ld [de], a
	ld c, $FF
	ld a, e
	and $C0
	add a, OBJECT_DIRECTION_OFFSET
	ld e, a
	ld a, [de]
	sub b
	jr nc, AdvanceObjectSequenceRecord_StoreTurnStep
	ld c, $01
AdvanceObjectSequenceRecord_StoreTurnStep:
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_TURN_STEP_OFFSET
	ld e, a
	ld a, c
	ld [de], a
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_REVERSE_FLAG_OFFSET
	ld e, a
	ld a, [de]
	and a
	jr z, AdvanceObjectSequenceRecord_SkipForward
	push hl
	; Original: the eight dec hl are undone by the pop hl that follows (no effect).
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
	jr ApplySequenceRecordEndAction

AdvanceObjectSequenceRecord_SkipForward:
	inc hl
	inc hl
ApplySequenceRecordEndAction:
	call LoadObjectSequenceTargetPosition
	inc hl
	inc hl
	ld a, [hli]
	and a
	jr z, ObjectSequenceUpdateExit
	cp $01
	jr z, ApplySequenceRecordEndAction_Restart
	cp $02
	jr z, ApplySequenceRecordEndAction_Reverse
	cp $03
	jr z, ApplySequenceRecordEndAction_SetTimer
	cp $04
	jr z, ApplySequenceRecordEndAction_StartSpin
	cp $05
	jr z, ObjectSequenceUpdateExit
ApplySequenceRecordEndAction_SetTimer:
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_ACTION_TIMER_OFFSET
	ld e, a
	ld a, [hl]
	ld [de], a
	jr ObjectSequenceUpdateExit

ApplySequenceRecordEndAction_StartSpin:
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_ACTION_TIMER_OFFSET
	ld e, a
	ld a, OBJECT_SEQUENCE_SPIN_FLAG | 17
	ld [de], a
	jr ObjectSequenceUpdateExit

ApplySequenceRecordEndAction_Restart:
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_RECORD_INDEX_OFFSET
	ld e, a
	ld a, $FF
	ld [de], a
	jr ObjectSequenceUpdateExit

ApplySequenceRecordEndAction_Reverse:
	cp $02
	jr nz, ObjectSequenceUpdateExit
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_REVERSE_FLAG_OFFSET
	ld e, a
	ld a, [de]
	cpl
	ld [de], a
	dec hl
	dec hl
	dec hl
	call LoadObjectSequenceTargetPosition
	jr ObjectSequenceUpdateExit

ObjectSequenceUpdateExit:
	pop hl
	pop de
	pop bc
	pop af
	ret


LoadFollowingSequenceTargetPosition:
	push de
	push hl
	push de
	inc hl
	inc hl
	ld a, [hl]
	and a
	; Original: jr z targets the next instruction (no effect).
	jr z, LoadFollowingSequenceTargetPosition_Load
LoadFollowingSequenceTargetPosition_Load:
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
	add a, OBJECT_SEQUENCE_TARGET_X_OFFSET
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


LoadObjectSequenceTargetPosition:
	push de
	push hl
	push de
	inc hl
	inc hl
	ld a, [hl]
	and a
	jr z, LoadObjectSequenceTargetPosition_Relative
	cp $01
	jr nz, LoadObjectSequenceTargetPosition_CheckMode2
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_SLOT_FLAGS_OFFSET
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
	jr LoadObjectSequenceTargetPosition_Store

LoadObjectSequenceTargetPosition_CheckMode2:
	cp $02
	; Original: jr nz targets the next instruction (no effect).
	jr nz, LoadObjectSequenceTargetPosition_Relative
LoadObjectSequenceTargetPosition_Relative:
	dec hl
	dec hl
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_REVERSE_FLAG_OFFSET
	ld e, a
	ld a, [de]
	and a
	jr z, LoadObjectSequenceTargetPosition_NextRecord
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	jr LoadObjectSequenceTargetPosition_Store

LoadObjectSequenceTargetPosition_NextRecord:
	ld bc, $0008
	add hl, bc
LoadObjectSequenceTargetPosition_Store:
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
	add a, OBJECT_SEQUENCE_TARGET_X_OFFSET
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

TestPointWithinBoxDistance:
	pop bc
	pop de
	ld a, c
	sub e
	ld e, a
	ld a, b
	sbc a, d
	ld d, a
	and $80
	jr z, TestPointWithinBoxDistance_CheckX
	ld a, e
	cpl
	add a, $01
	ld e, a
	ld a, d
	cpl
	adc a, $00
	ld d, a
TestPointWithinBoxDistance_CheckX:
	ld a, $00
	cp d
	jr nz, TestPointWithinBoxDistance_FailX
	ld a, h
	cp e
	jr c, TestPointWithinBoxDistance_FailX
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
	jr z, TestPointWithinBoxDistance_CheckY
	ld a, e
	cpl
	add a, $01
	ld e, a
	ld a, d
	cpl
	adc a, $00
	ld d, a
TestPointWithinBoxDistance_CheckY:
	ld a, $00
	cp d
	jr nz, TestPointWithinBoxDistance_Fail
	ld a, h
	cp e
	jr c, TestPointWithinBoxDistance_Fail
	ld a, l
	or $02
	ld l, a
	ret

TestPointWithinBoxDistance_FailX:
	pop bc
	pop de
TestPointWithinBoxDistance_Fail:
	ld l, $00
	ret


CheckObjectNearPlayerBox:
Func_03_60AF: ; legacy alias (automatic entry label)
	push de
	ld bc, AimObjectAtPlayerFromProximity
	push bc
	ld l, e
	ld h, d
	ld a, l
	and $C0
	add a, OBJECT_TYPE_OFFSET
	ld l, a
	ld a, [hl]
	; Original: every case loads b = $55, so the state compares have no effect on the threshold.
	ld b, $55
	cp $00
	jr z, CheckObjectNearPlayerBox_StoreThreshold
	ld b, $55
	cp $02
	jr z, CheckObjectNearPlayerBox_StoreThreshold
	ld b, $55
	cp $01
	jr z, CheckObjectNearPlayerBox_StoreThreshold
	ld b, $55
CheckObjectNearPlayerBox_StoreThreshold:
	ld a, b
	ld [wObjectProximityThreshold], a
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
	ld a, [wObjectProximityThreshold]
	ld h, a
	jp TestPointWithinBoxDistance

AimObjectAtPlayerFromProximity:
Func_03_611C: ; legacy alias (automatic entry label)
	pop de
	ld a, l
	and a
	jr nz, AimObjectAtPlayerFromProximity_SetLatch
	ld a, e
	and $C0
	add a, OBJECT_LEVEL_SPAWN_INDEX_FLAGS_OFFSET
	ld e, a
	ld a, [de]
	bit 7, a
	jr nz, AimObjectAtPlayerFromProximity_ComputeDirection
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_MOVEMENT_STATE_OFFSET
	ld e, a
	ld a, [de]
	and $F0
	ret nz
	; Entering follow mode: the low nibble saved by the hold path is restored as
	; the target heading below (not for type 3).
	ld a, [de]
	ld b, a
	ld a, OBJECT_SEQUENCE_MOVEMENT_FOLLOWING
	ld [de], a
	ld a, e
	and $C0
	add a, OBJECT_TYPE_OFFSET
	ld e, a
	ld a, [de]
	cp $03
	ret z
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_TARGET_HEADING_OFFSET
	ld e, a
	ld a, b
	ld [de], a
	ret

AimObjectAtPlayerFromProximity_SetLatch:
	ld a, [wObjectProximityThreshold]
	; Original: the flags from cp $55 are overwritten before any test (no effect).
	cp $55
	ld a, e
	and $C0
	add a, OBJECT_LEVEL_SPAWN_INDEX_FLAGS_OFFSET
	ld e, a
	ld a, [de]
	or $80
	ld [de], a
AimObjectAtPlayerFromProximity_ComputeDirection:
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
	add a, OBJECT_DIRECTION_OFFSET
	ld e, a
	ld a, [de]
	sub b
	jr nc, AimObjectAtPlayerFromProximity_StoreTurnSign
	ld c, $01
AimObjectAtPlayerFromProximity_StoreTurnSign:
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_TURN_STEP_OFFSET
	ld e, a
	ld a, c
	ld [de], a
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_TARGET_HEADING_OFFSET
	ld e, a
	ld a, [de]
	ld c, a
	ld a, b
	ld [de], a
	ld a, e
	and $C0
	; Leaving follow mode: +$38 becomes the previous target heading (0-15).
	add a, OBJECT_SEQUENCE_MOVEMENT_STATE_OFFSET
	ld e, a
	ld a, [de]
	and $F0
	jr z, AimObjectAtPlayerFromProximity_CheckFacing
	ld a, c
	ld [de], a
	ret

AimObjectAtPlayerFromProximity_CheckFacing:
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_TARGET_HEADING_OFFSET
	ld e, a
	ld a, [de]
	ld b, a
	ld a, e
	and $C0
	add a, OBJECT_DIRECTION_OFFSET
	ld e, a
	ld a, [de]
	cp b
	ret nz
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_PROXIMITY_DELAY_OFFSET
	ld e, a
	ld a, $28
	ld [de], a
	push de
	ld l, e
	ld h, d
	ld a, [wPlayerAlive]
	and a
	jp z, AimObjectAtPlayerFromProximity_Return
	ld a, l
	and $C0
	add a, OBJECT_LEVEL_SPAWN_INDEX_FLAGS_OFFSET
	ld l, a
	ld a, [hl]
	and $7F
	ld [hl], a
	call UsePlayerWeaponOrPowerup
	jp nz, AimObjectAtPlayerFromProximity_SetVelToPlayer
	jp AimObjectAtPlayerFromProximity_Return


; Locks itself out: wRecordedPathWriteIndex ($CD15) is 0 at level start, and its
; only increment is in AppendRecordedPathWaypoint, which is reached only from
; here after the zero-index exit test below.
UnusedStartRecordedPathFollow:
Func_03_61FC: ; legacy alias (automatic entry label)
	ld l, e
	ld h, d
	ld a, [wRecordedPathWriteIndex]
	and a
	jp z, UnusedStartRecordedPathFollow_Return
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_SLOT_FLAGS_OFFSET
	ld l, a
	ld a, [hl]
	bit 6, a
	jp nz, UnusedStartRecordedPathFollow_Return
	or $40
	ld [hl], a
	ld [wForceRecordedPathAppend], a
	xor a
	ld [wRecordedPathStarted], a
	call AppendRecordedPathWaypoint
	xor a
	ld [wForceRecordedPathAppend], a
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
	add a, OBJECT_SEQUENCE_TARGET_HEADING_OFFSET
	ld l, a
	ld [hl], b
	pop hl
	pop bc
	push bc
	push hl
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_RECORD_INDEX_OFFSET
	ld l, a
	ld a, [wRecordedPathWriteIndex]
	ld [hl], a
	pop hl
	push hl
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_RECORD_INDEX_OFFSET
	ld l, a
	ld a, [hl]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, wRecordedPath
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
	add a, OBJECT_SEQUENCE_TARGET_X_OFFSET
	ld l, a
	ld [hl], c
	inc hl
	ld [hl], b
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_TARGET_Y_OFFSET
	ld l, a
	ld [hl], e
	inc hl
	ld [hl], d
	pop bc
UnusedStartRecordedPathFollow_Return:
	push hl
	jr AimObjectAtPlayerFromProximity_Return

AimObjectAtPlayerFromProximity_SetVelToPlayer:
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
	call SetObjectVelocityTowardPoint
	; HL is the new projectile (BC from UsePlayerWeaponOrPowerup), DE the shooter.
	; Original defect: with shooter +$29 = 3 (a level vehicle can collect
	; PickupScreenEffectCharge while its +$29 is 0), that call returns NZ through
	; StartScreenEffect without spawning. HL is then the stale BC from
	; AimObjectAtPlayerFromProximity_CheckFacing (H = target heading 0-15), so the call above
	; writes +$29 and +$0D-$12 into $0000-$0FFF, the MBC5 RAM-enable range.
	; The single charge is consumed first, so the +$29 test below returns.
	pop de
	ld a, e
	and $C0
	add a, OBJECT_PLAYER_POWERUP_TYPE_OFFSET
	ld e, a
	ld a, [de]
	cp $00
	ret z
	ld a, l
	and $C0
	add a, OBJECT_PROJECTILE_AIMED_VELOCITY_FLAG_OFFSET
	ld l, a
	xor a
	ld [hl], a
	ret

AimObjectAtPlayerFromProximity_Return:
	pop de
	ret


SetObjectVelocityTowardPoint:
Func_03_62E7: ; legacy alias (automatic entry label)
	push bc
	push de
	push hl
	ld a, b
	sub d
	jr nc, SetObjectVelocityTowardPoint_AbsDx
	; Original: cpl without inc; a negative difference becomes |difference| - 1 (same for Y below).
	cpl
SetObjectVelocityTowardPoint_AbsDx:
	ld b, a
	ld a, c
	sub e
	jr nc, SetObjectVelocityTowardPoint_AbsDy
	cpl
SetObjectVelocityTowardPoint_AbsDy:
	ld c, a
	push bc
	add a, b
	srl a
	ld c, a
	and a
	ld de, $0000
	jr z, SetObjectVelocityTowardPoint_DivY
	ld h, b
	ld l, $00
SetObjectVelocityTowardPoint_DivXLoop:
	ld a, l
	sub c
	ld l, a
	jr nc, SetObjectVelocityTowardPoint_DivXCount
	ld a, h
	sub $01
	ld h, a
	jr c, SetObjectVelocityTowardPoint_DivY
SetObjectVelocityTowardPoint_DivXCount:
	inc de
	jr SetObjectVelocityTowardPoint_DivXLoop

SetObjectVelocityTowardPoint_DivY:
	pop bc
	ld a, c
	add a, b
	srl a
	ld b, a
	and a
	push de
	ld de, $0000
	jr z, SetObjectVelocityTowardPoint_Scale
	ld h, c
	ld l, $00
SetObjectVelocityTowardPoint_DivYLoop:
	ld a, l
	sub b
	ld l, a
	jr nc, SetObjectVelocityTowardPoint_DivYCount
	ld a, h
	sub $01
	ld h, a
	jr c, SetObjectVelocityTowardPoint_Scale
SetObjectVelocityTowardPoint_DivYCount:
	inc de
	jr SetObjectVelocityTowardPoint_DivYLoop

SetObjectVelocityTowardPoint_Scale:
	pop bc
	ld a, $03
	ld hl, $0000
SetObjectVelocityTowardPoint_MulX3:
	add hl, bc
	dec a
	jr nz, SetObjectVelocityTowardPoint_MulX3
	ld b, h
	ld c, l
	ld a, $03
	ld hl, $0000
SetObjectVelocityTowardPoint_MulY3:
	add hl, de
	dec a
	jr nz, SetObjectVelocityTowardPoint_MulY3
	ld d, h
	ld e, l
	pop hl
	ld a, l
	and $C0
	add a, OBJECT_PROJECTILE_AIMED_VELOCITY_FLAG_OFFSET
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
	jr nc, SetObjectVelocityTowardPoint_CheckY
	; Original: cpl without inc negates each velocity as -v - 1, not -v (same for Y below).
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
SetObjectVelocityTowardPoint_CheckY:
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


UpdateLevelObjectAuxState:
Func_03_6391: ; legacy alias (automatic entry label)
	call UpdatePendingLevelObjectsFar
	ld a, $01
	ld [wLevelAuxType2AllReached], a
	xor a
	ld [wLevelAuxTimerExpiredCount], a
	ld [wLevelAuxType3Pending], a
	ld a, [wPlayerObject]
	ld e, a
	ld a, [wPlayerObject + 1]
	ld d, a
	call CheckObjectAuxRegionTriggers
	ld e, $01
	ld a, [wLevelAuxTimerDivider]
	inc a
	cp $1E
	jr nz, UpdateLevelObjectAuxState_StoreDivider
	xor a
UpdateLevelObjectAuxState_StoreDivider:
	ld [wLevelAuxTimerDivider], a
	ld e, $01
	and a
	jr z, UpdateLevelObjectAuxState_ScanEntries
	dec e
UpdateLevelObjectAuxState_ScanEntries:
	ld hl, wLevelObjectAuxState
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	ld a, LEVEL_OBJECT_AUX_COUNT
UpdateAuxState_Loop:
	push af
	push hl
	ld a, [hli]
	and a
	jr z, UpdateAuxState_Next
	cp LEVEL_AUX_MODE_TIMER
	jr z, UpdateAuxTimer
	cp LEVEL_AUX_MODE_LINKED_REGION
	jr z, UpdateAuxLinkedRegion
	cp LEVEL_AUX_MODE_PENDING_REGION
	jr z, UpdateAuxPendingRegion
	cp LEVEL_AUX_MODE_NONPLAYER_ACTIVE
	jr z, UpdateAuxNonplayerActive
	jr UpdateAuxState_Next

UpdateAuxNonplayerActive:
	ld a, $01
	ld [wLevelAuxType4Active], a
	ld a, [wActiveFlag26ObjectCount]
	and a
	jr nz, UpdateAuxState_Next
	ld [wLevelAuxType4Active], a
	jr UpdateAuxState_Next

UpdateAuxLinkedRegion:
	inc hl
	inc hl
	ld a, [hli]
	cp $02
	jr z, UpdateAuxState_Next
	xor a
	ld [wLevelAuxType2AllReached], a
	jr UpdateAuxState_Next

UpdateAuxTimer:
	ld a, [hli]
	inc a
	ld d, a
	ld a, [hl]
	cp d
	jr z, UpdateAuxTimerExpired
	add a, e
	ld [hl], a
	jr UpdateAuxState_Next

UpdateAuxTimerExpired:
	ld a, [wLevelAuxTimerExpiredCount]
	inc a
	ld [wLevelAuxTimerExpiredCount], a
	jr UpdateAuxState_Next

UpdateAuxPendingRegion:
	inc hl
	inc hl
	ld a, [hli]
	cp $01
	jr z, UpdateAuxState_Next
	ld a, $01
	ld [wLevelAuxType3Pending], a
UpdateAuxState_Next:
	pop hl
	ld bc, LEVEL_OBJECT_AUX_STATE_SIZE
	add hl, bc
	pop af
	dec a
	jr nz, UpdateAuxState_Loop
	ret


CheckObjectAuxRegionTriggers:
Func_03_6429: ; legacy alias (automatic entry label)
	push de
	ld hl, wLevelObjectAuxState
	ld bc, LEVEL_OBJECT_AUX_STATE_SIZE
	ld a, LEVEL_OBJECT_AUX_COUNT
CheckAuxRegion_Loop:
	push af
	push bc
	push hl
	ld bc, $0006
	add hl, bc
	ld a, [hl]
	and a
	jp z, CheckAuxRegion_Next
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
	call SubWordAbs
	push af
	inc hl
	inc hl
	ld a, [hli]
	ld b, a
	inc hl
	inc hl
	pop af
	and a
	jr nz, CheckObjectAuxRegionTriggers_XNegative
	ld a, d
	and a
	jr nz, CheckObjectAuxRegionTriggers_XOutOfRange
	ld a, e
	cp b
	jr c, CheckObjectAuxRegionTriggers_CheckY
CheckObjectAuxRegionTriggers_XOutOfRange:
	pop de
	jp CheckAuxRegion_Next

CheckObjectAuxRegionTriggers_XNegative:
	ld a, d
	and a
	jr nz, CheckObjectAuxRegionTriggers_XOutOfRange
	; Original: the negative X side tests a fixed $0C, while the positive side uses the entry's width byte.
	ld a, e
	cp $0C
	jr c, CheckObjectAuxRegionTriggers_CheckY
	pop de
	jp CheckAuxRegion_Next

CheckObjectAuxRegionTriggers_CheckY:
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
	call SubWordAbs
	push af
	inc hl
	ld a, [hli]
	ld b, a
	pop af
	and a
	jr nz, CheckObjectAuxRegionTriggers_YNegative
	ld a, d
	and a
	jr nz, CheckObjectAuxRegionTriggers_YOutOfRange
	ld a, e
	cp b
	jr c, CheckObjectAuxRegionTriggers_DispatchMode
CheckObjectAuxRegionTriggers_YOutOfRange:
	pop de
	jp CheckAuxRegion_Next

CheckObjectAuxRegionTriggers_YNegative:
	ld a, d
	and a
	jr nz, CheckObjectAuxRegionTriggers_YOutOfRange
	; Original: the negative Y side tests a fixed $0C, while the positive side uses the entry's height byte.
	ld a, e
	cp $0C
	jr c, CheckObjectAuxRegionTriggers_DispatchMode
	pop de
	jp CheckAuxRegion_Next

CheckObjectAuxRegionTriggers_DispatchMode:
	pop de
	ld a, [hli]
	inc hl
	cp LEVEL_AUX_MODE_TIMER
	jp z, TriggerAuxTimer
	cp LEVEL_AUX_MODE_LINKED_REGION
	jr z, TriggerAuxLinkedRegion
	cp LEVEL_AUX_MODE_PENDING_REGION
	jr z, TriggerAuxPendingRegion
	cp LEVEL_AUX_MODE_ACTIVATE_LINK
	jr z, TriggerAuxActivateLink
	jp CheckAuxRegion_Next

TriggerAuxLinkedRegion:
	ld a, e
	and $C0
	add a, OBJECT_NONPLAYER_CONTROLLED_FLAG_OFFSET
	ld e, a
	ld a, [de]
	and a
	jp nz, CheckAuxRegion_Next
	ld a, [wHudAlertActive]
	and a
	jr z, CheckAuxRegion_Next
	inc hl
	ld a, [hl]
	cp $01
	jr nz, CheckAuxRegion_Next
	inc a
	ld [hl], a
	ld l, e
	ld h, d
	jr CheckAuxRegion_Triggered

TriggerAuxPendingRegion:
	ld a, e
	and $C0
	add a, OBJECT_NONPLAYER_CONTROLLED_FLAG_OFFSET
	ld e, a
	ld a, [de]
	and a
	jr nz, CheckAuxRegion_Next
	inc hl
	ld a, [hl]
	cp $01
	jr z, CheckAuxRegion_Next
	inc a
	ld [hl], a
	call ResetNearestObjectTrackerFar
	ld l, e
	ld h, d
	jr CheckAuxRegion_Triggered

TriggerAuxActivateLink:
	ld a, e
	and $C0
	add a, OBJECT_NONPLAYER_CONTROLLED_FLAG_OFFSET
	ld e, a
	ld a, [de]
	and a
	jr nz, CheckAuxRegion_Next
	ld a, [hl]
	and a
	jr nz, CheckAuxRegion_Next
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
	jr CheckAuxRegion_Triggered

TriggerAuxTimer:
	ld a, e
	and $C0
	add a, OBJECT_NONPLAYER_CONTROLLED_FLAG_OFFSET
	ld e, a
	ld a, [de]
	and a
	jr z, CheckAuxRegion_Next
	xor a
	ld [hl], a
CheckAuxRegion_Triggered:
	pop hl
	pop bc
	pop af
	pop de
	ret

CheckAuxRegion_Next:
	pop hl
	pop bc
	add hl, bc
	pop af
	dec a
	jp nz, CheckAuxRegion_Loop
	pop de
	ret


SubWordAbs:
Func_03_655C: ; legacy alias (automatic entry label)
	ld a, c
	sub e
	ld e, a
	ld a, b
	sbc a, d
	ld d, a
	and $80
	jr z, SubWordAbs_NonNegative
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

SubWordAbs_NonNegative:
	xor a
	ret


AppendRecordedPathWaypoint:
Func_03_6575: ; legacy alias (automatic entry label)
	ld a, [wPlayerAlive]
	and a
	ret z
	ld a, [wRecordedPathWriteIndex]
	ld h, $00
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, wRecordedPath
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
	ld a, [wForceRecordedPathAppend]
	and a
	jr nz, AppendRecordedPathWaypoint_LoadSecondWord
	ld a, [hli]
	cp c
	jr nz, AppendRecordedPathWaypoint_LoadSecondWord
	ld a, [hli]
	cp b
	jr nz, AppendRecordedPathWaypoint_LoadSecondWord
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
	jr nz, AppendRecordedPathWaypoint_StorePosition
	ld a, [hli]
	cp b
	jr nz, AppendRecordedPathWaypoint_StorePosition
	ld a, e
	and $C0
	add a, OBJECT_DIRECTION_OFFSET
	ld e, a
	ld a, [de]
	ld [hl], a
	pop hl
	pop bc
	ret

AppendRecordedPathWaypoint_LoadSecondWord:
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
AppendRecordedPathWaypoint_StorePosition:
	pop hl
	inc hl
	inc hl
	inc hl
	inc hl
	ld a, [wRecordedPathStarted]
	and a
	jr nz, AppendRecordedPathWaypoint_Primed
	inc a
	ld [wRecordedPathStarted], a
	ld a, e
	and $C0
	add a, OBJECT_DIRECTION_OFFSET
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

AppendRecordedPathWaypoint_Primed:
	ld a, e
	and $C0
	add a, OBJECT_DIRECTION_OFFSET
	ld e, a
	ld a, [de]
	cp [hl]
	jr nz, AppendRecordedPathWaypoint_AppendEntry
	pop bc
	ret

AppendRecordedPathWaypoint_AppendEntry:
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
	ld a, [wRecordedPathWriteIndex]
	inc a
	and $3F
	ld [wRecordedPathWriteIndex], a
	ret nz
	ld a, [wRecordedPathWrapCount]
	inc a
	and $3F
	ld [wRecordedPathWrapCount], a
	ret

UpdateObjectSequenceMovement_FollowRecordedPath:
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_PROXIMITY_DELAY_OFFSET
	ld e, a
	ld a, [de]
	and a
	jr nz, UpdateObjectSequenceMovement_PathTickProxDelay
	jr UpdateObjectSequenceMovement_CheckHeading

UpdateObjectSequenceMovement_PathTickProxDelay:
	dec a
	ld [de], a
	cp $20
	jr c, UpdateObjectSequenceMovement_CheckHeading
	ld a, e
	and $C0
	add a, OBJECT_VEHICLE_SPEED_OFFSET
	ld e, a
	xor a
	ld [de], a
	jp UpdateObjectSequenceMovement_PathExit

UpdateObjectSequenceMovement_CheckHeading:
	ld a, e
	and $C0
	add a, OBJECT_DIRECTION_OFFSET
	ld e, a
	ld a, [de]
	ld b, a
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_TARGET_HEADING_OFFSET
	ld e, a
	ld a, [de]
	cp b
	jr z, UpdateObjectSequenceMovement_TestWaypointArrival
	ld a, e
	and $C0
	add a, OBJECT_VEHICLE_SPEED_OFFSET
	ld e, a
	xor a
	ld [de], a
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_TURN_DELAY_OFFSET
	ld e, a
	ld a, [de]
	and a
	jr z, UpdateObjectSequenceMovement_PathTurnStep
	dec a
	ld [de], a
	jp UpdateObjectSequenceMovement_PathExit

UpdateObjectSequenceMovement_PathTurnStep:
	push de
	ld a, e
	and $C0
	add a, OBJECT_VEHICLE_TURN_INTERVAL_OFFSET
	ld e, a
	ld a, [de]
	pop de
	ld [de], a
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_TURN_STEP_OFFSET
	ld e, a
	ld a, [de]
	ld c, a
	ld a, e
	and $C0
	add a, OBJECT_DIRECTION_OFFSET
	ld e, a
	ld a, [de]
	add a, c
	and $0F
	ld [de], a
	jp UpdateObjectSequenceMovement_PathExit

UpdateObjectSequenceMovement_TestWaypointArrival:
	push de
	ld l, e
	ld h, d
	ld bc, SnapAndAdvanceRecordedPathWaypoint
	push bc
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_TARGET_Y_OFFSET
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
	add a, OBJECT_SEQUENCE_TARGET_X_OFFSET
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
	jp TestPointWithinBoxDistance

SnapAndAdvanceRecordedPathWaypoint:
Func_03_66BB: ; legacy alias (automatic entry label)
	pop de
	ld a, l
	and a
	jr z, PathSnap_NotArrived
	and $01
	jr z, PathSnap_CheckYAxis
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_TARGET_X_OFFSET
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
PathSnap_CheckYAxis:
	ld a, l
	and $02
	jr z, PathSnap_NotArrived
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_TARGET_Y_OFFSET
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
	jr nz, PathSnap_NotArrived
	jr PathSnap_AdvanceIndex

PathSnap_NotArrived:
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_FALLBACK_SPEED_OFFSET
	ld e, a
	ld a, [de]
	push af
	ld a, e
	and $C0
	add a, OBJECT_VEHICLE_SPEED_OFFSET
	ld e, a
	pop af
	ld [de], a
	jp UpdateObjectSequenceMovement_PathExit

PathSnap_AdvanceIndex:
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_RECORD_INDEX_OFFSET
	ld e, a
	ld a, [de]
	ld b, a
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_REVERSE_FLAG_OFFSET
	ld e, a
	ld a, [de]
	and a
	jr z, SnapAndAdvanceRecordedPathWaypoint_StepIndex
	dec b
	ld a, b
	and a
	jr nz, SnapAndAdvanceRecordedPathWaypoint_StepBack
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_REVERSE_FLAG_OFFSET
	ld e, a
	ld a, [de]
	cpl
	ld [de], a
	ld b, $00
SnapAndAdvanceRecordedPathWaypoint_StepBack:
	dec b
SnapAndAdvanceRecordedPathWaypoint_StepIndex:
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_RECORD_INDEX_OFFSET
	ld e, a
	inc b
	ld a, b
	and $3F
	ld c, a
	ld a, [wRecordedPathWriteIndex]
	cp c
	jr nz, SnapAndAdvanceRecordedPathWaypoint_StoreIndex
	jr SnapAndAdvanceRecordedPathWaypoint_LoadHeading

SnapAndAdvanceRecordedPathWaypoint_StoreIndex:
	ld a, c
	ld [de], a
	; Original: jr nz targets the next instruction (no effect).
	jr nz, SnapAndAdvanceRecordedPathWaypoint_LoadHeading
SnapAndAdvanceRecordedPathWaypoint_LoadHeading:
	ld a, e
	and $C0
	add a, OBJECT_VEHICLE_SPEED_OFFSET
	ld e, a
	xor a
	ld [de], a
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_RECORD_INDEX_OFFSET
	ld e, a
	ld a, [de]
	ld h, $00
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, wRecordedPath
	add hl, bc
	inc hl
	inc hl
	inc hl
	inc hl
	ld a, [hl]
	ld b, a
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_REVERSE_FLAG_OFFSET
	ld e, a
	ld a, [de]
	and a
	jr z, PathSnap_SetDesiredHeading
	; Original defect: hl is entry +4, so nine dec hl land on the previous
	; entry's +3 (Y high byte), not its +4 heading byte.
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
PathSnap_SetDesiredHeading:
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_TARGET_HEADING_OFFSET
	ld e, a
	ld a, b
	ld [de], a
	ld c, $FF
	ld a, e
	and $C0
	add a, OBJECT_DIRECTION_OFFSET
	ld e, a
	ld a, [de]
	sub b
	jr nc, SnapAndAdvanceRecordedPathWaypoint_StoreTurnStep
	ld c, $01
SnapAndAdvanceRecordedPathWaypoint_StoreTurnStep:
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_TURN_STEP_OFFSET
	ld e, a
	ld a, c
	ld [de], a
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_REVERSE_FLAG_OFFSET
	ld e, a
	ld a, [de]
	and a
	jr z, SnapAndAdvanceRecordedPathWaypoint_LoadTarget
	; This push/pop-wrapped dec hl run restores hl unchanged and has no effect.
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
SnapAndAdvanceRecordedPathWaypoint_LoadTarget:
	call LoadAdjacentPathWaypointTarget
UpdateObjectSequenceMovement_PathExit:
	pop hl
	pop de
	pop bc
	pop af
	ret


LoadAdjacentPathWaypointTarget:
Func_03_67BF: ; legacy alias (automatic entry label)
	push de
	push hl
	push de
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_REVERSE_FLAG_OFFSET
	ld e, a
	ld a, [de]
	and a
	jr z, PathTarget_Forward
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	jr LoadAdjacentPathWaypointTarget_ReadEntry

PathTarget_Forward:
	ld bc, $0008
	add hl, bc
LoadAdjacentPathWaypointTarget_ReadEntry:
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
	add a, OBJECT_SEQUENCE_TARGET_X_OFFSET
	ld l, a
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_TARGET_Y_OFFSET
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
	jr z, QuantizeSignedVectorDirection_CheckC
	ld a, b
	cpl
	inc a
	ld b, a
	set 1, e
QuantizeSignedVectorDirection_CheckC:
	bit 7, c
	jr z, QuantizeSignedVectorDirection_OrderAxes
	ld a, c
	cpl
	inc a
	ld c, a
	set 0, e
QuantizeSignedVectorDirection_OrderAxes:
	push de
	ld hl, SignedVectorDirectionLookup
	ld a, b
	cp c
	jr nc, QuantizeSignedVectorDirection_CheckQuadrant
	inc hl
	ld b, c
	ld c, a
QuantizeSignedVectorDirection_CheckQuadrant:
	ld a, e
	cp $03
	jr z, QuantizeSignedVectorDirection_SameSignColumn
	and a
	jr nz, QuantizeSignedVectorDirection_DivideRatio
QuantizeSignedVectorDirection_SameSignColumn:
	inc hl
	inc hl
QuantizeSignedVectorDirection_DivideRatio:
	ld a, b
	srl a
	ld e, $00
	add a, c
	cp b
	jr z, QuantizeSignedVectorDirection_RatioStep2
	jr c, QuantizeSignedVectorDirection_RatioStep2
	sub b
	inc e
QuantizeSignedVectorDirection_RatioStep2:
	add a, c
	cp b
	jr z, QuantizeSignedVectorDirection_RatioStep3
	jr c, QuantizeSignedVectorDirection_RatioStep3
	sub b
	inc e
QuantizeSignedVectorDirection_RatioStep3:
	add a, c
	cp b
	jr z, QuantizeSignedVectorDirection_RatioStep4
	jr c, QuantizeSignedVectorDirection_RatioStep4
	sub b
	inc e
QuantizeSignedVectorDirection_RatioStep4:
	add a, c
	cp b
	jr z, QuantizeSignedVectorDirection_Lookup
	jr c, QuantizeSignedVectorDirection_Lookup
	sub b
	inc e
QuantizeSignedVectorDirection_Lookup:
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
	ld a, [wLevelNumber]
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
	ld a, [wLevelAuxType4Active]
	and a
	jp z, AwardLevelCompletion
	ret


Level01StateCheck:
	ld a, [wBonusPickupCount]
	cp $06
	ret nz
	ld a, [wLevelAuxType3Pending]
	and a
	jp z, AwardLevelCompletion
	ret


Level02StateCheck:
	ld a, [wLevelAuxType4Active]
	and a
	jp z, AwardLevelCompletion
	ret


Level03StateCheck:
	ld a, [wLevelAuxType3Pending]
	and a
	jp z, AwardLevelCompletion
	ret


Level04StateCheck:
	ld a, [wLevelAuxType3Pending]
	and a
	jp z, AwardLevelCompletion
	ret


Level05StateCheck:
	ld a, [wLevelAuxType2AllReached]
	and a
	jp nz, AwardLevelCompletion
	ret


Level06StateCheck:
	ld a, [wLevelAuxType3Pending]
	and a
	jp z, AwardLevelCompletion
	ret


Level07StateCheck:
	ld a, [wSequenceObjectsInState2Count]
	and a
	ret nz
	jp AwardLevelCompletion


Level08StateCheck:
	ld a, [wBonusPickupCount]
	cp $08
	ret nz
	ld a, [wLevelAuxType3Pending]
	and a
	jp z, AwardLevelCompletion
	ret


Level09StateCheck:
	ld a, [wPowerupType3PickupCount]
	cp $07
	ret nz
	ld a, [wLevelAuxType3Pending]
	and a
	jp z, AwardLevelCompletion
	ret


Level10StateCheck:
	ld a, [wLevelAuxType4Active]
	and a
	jp z, AwardLevelCompletion
	ret


Level11StateCheck:
	ld a, [wLevelAuxType3Pending]
	and a
	jp z, AwardLevelCompletion
	ret


Level12StateCheck:
	ld a, [wLevelAuxType4Active]
	and a
	jp z, AwardLevelCompletion
	ret


Level13StateCheck:
	ld a, [wSequenceObjectsInState2Count]
	and a
	ret nz
	jp AwardLevelCompletion


Level14StateCheck:
	ld a, [wLevelAuxType4Active]
	and a
	jp z, AwardLevelCompletion
	ret

AwardLevelCompletion:
	ld a, [wLevelComplete]
	and a
	ret nz
	ld bc, $003C
	call BeginLevelCompleteCountdown
	ld bc, $2710
	call AddToScore
	ret


MarkMatchingAuxTargetReached:
Func_03_6923: ; legacy alias, used by src/bank_00.asm
	; Original: E and D are stored into wLevelObjectRecordIndex and wLevelObjectRespawnsLeft as scratch, overwriting those variables.
	ld a, e
	ld [wLevelObjectRecordIndex], a
	ld a, d
	ld [wLevelObjectRespawnsLeft], a
	ld hl, wLevelObjectAuxState
	ld a, LEVEL_OBJECT_AUX_COUNT
MarkMatchingAuxTargetReached_Loop:
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
	jr z, MarkMatchingAuxTargetReached_Next
	cp $03
	jr z, MarkMatchingAuxTargetReached_CompareXY
	jr MarkMatchingAuxTargetReached_Next

MarkMatchingAuxTargetReached_CompareXY:
	push hl
	ld a, [wLevelObjectRecordIndex]
	ld l, a
	ld a, [wLevelObjectRespawnsLeft]
	ld h, a
	ld a, l
	and $C0
	add a, $13
	ld l, a
	inc hl
	ld a, [hli]
	cp c
	jr nz, MarkMatchingAuxTargetReached_DropEntry
	ld a, [hl]
	cp b
	jr nz, MarkMatchingAuxTargetReached_DropEntry
	ld a, l
	and $C0
	add a, $16
	ld l, a
	inc hl
	ld a, [hli]
	cp e
	jr nz, MarkMatchingAuxTargetReached_DropEntry
	ld a, [hl]
	cp d
	jr nz, MarkMatchingAuxTargetReached_DropEntry
	pop hl
	inc hl
	inc hl
	ld a, [hl]
	cp $01
	jr z, MarkMatchingAuxTargetReached_Next
	ld a, $01
	ld [hl], a
	ld [wLevelAuxType3Pending], a
	push hl
MarkMatchingAuxTargetReached_DropEntry:
	pop hl
MarkMatchingAuxTargetReached_Next:
	pop hl
	ld bc, LEVEL_OBJECT_AUX_STATE_SIZE
	add hl, bc
	pop af
	dec a
	jr nz, MarkMatchingAuxTargetReached_Loop
	ret

TestObjectPassedSequenceTarget:
	pop bc
	pop de
	ld a, h
	and a
	jr z, TestObjectPassedSequenceTarget_UseYAxis
	cp $08
	jr z, TestObjectPassedSequenceTarget_UseYAxis
	ld l, $00
	ld a, c
	sub e
	ld e, a
	ld a, b
	sbc a, d
	ld d, a
	jr nc, TestObjectPassedSequenceTarget_XSelectSense
	ld l, $01
TestObjectPassedSequenceTarget_XSelectSense:
	pop bc
	pop de
	ld a, h
	cp $08
	jr c, TestObjectPassedSequenceTarget_XReturnBorrow
	ld a, l
	and a
	jr nz, TestObjectPassedSequenceTarget_XReturnNotPassed
	ld l, $01
	ret

TestObjectPassedSequenceTarget_XReturnNotPassed:
	ld l, $00
	ret

TestObjectPassedSequenceTarget_XReturnBorrow:
	ld a, l
	and a
	; Original: ld l, $00 has no effect: ret nz above leaves only the L = 0 case.
	ret nz
	ld l, $00
	ret

TestObjectPassedSequenceTarget_UseYAxis:
	pop bc
	pop de
	ld l, $00
	ld a, c
	sub e
	ld e, a
	ld a, b
	sbc a, d
	ld d, a
	jr nc, TestObjectPassedSequenceTarget_YSelectSense
	ld l, $01
TestObjectPassedSequenceTarget_YSelectSense:
	ld a, h
	cp $08
	jr z, TestObjectPassedSequenceTarget_YReturnBorrow
	ld a, l
	and a
	jr nz, TestObjectPassedSequenceTarget_YReturnNotPassed
	ld l, $01
	ret

TestObjectPassedSequenceTarget_YReturnNotPassed:
	ld l, $00
	ret

TestObjectPassedSequenceTarget_YReturnBorrow:
	ld a, l
	and a
	; Original: ld l, $00 has no effect: ret nz above leaves only the L = 0 case.
	ret nz
	ld l, $00
	ret

; Four unreachable instruction-shaped bytes remain after the final traced
; return.  No direct or indirect reference to this range is known, so keep
; them as data rather than claiming another routine.
Bank03UnreferencedTailBytes:
	db $C9, $C1, $D1, $C9
ASSERT @ - Bank03UnreferencedTailBytes == $4

Bank03ZeroFill:
	ds $7FFF - @, 0
Bank03BankMarker:
	db $03
