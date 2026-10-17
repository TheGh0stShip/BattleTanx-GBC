; BattleTanx (USA) - ROM bank $04

SECTION "ROM Bank $04", ROMX[$4000], BANK[$04]
	INCLUDE "src/level_objects.asm"

InitializeLevelObjects:
	xor a
	ld [wLevelAuxTimerDivider], a
	ld [wBonusPickupCount], a
	ld [wPowerupType3PickupCount], a
	ld [wLevelAuxTimerExpiredCount], a
	ld [wLevelAuxType3Pending], a
	ld [wLevelAuxType2AllReached], a
	ld a, $01
	ld [wLevelAuxType4Active], a
	xor a
	ld [wRecordedPathWriteIndex], a
	ld [wRecordedPathWrapCount], a
	ld [wRecordedPathStarted], a
	ld [wLevelObjectRecordType], a
	ld [wLevelObjectSequenceTable], a
	ld [wLevelObjectSpawnTable], a
	ld [wLevelObjectAuxTable], a
	ld [wLevelObjectRecordIndex], a
	ld [$CD26], a
	ld [wLevelObjectRespawnsLeft], a
	ld [wObjectSlowTickCounter], a
	ld [wObjectSequenceThrottleCounter], a
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
	ld hl, wRecordedPath
.fillObjectState:
	ld a, $FF
	ld [hli], a
	dec bc
	ld a, c
	or b
	jr nz, .fillObjectState
	ld bc, PENDING_LEVEL_OBJECT_COUNT * PENDING_LEVEL_OBJECT_SIZE
	ld hl, wPendingLevelObjectQueue
.fillPendingQueue:
	ld a, $FF
	ld [hli], a
	dec bc
	ld a, c
	or b
	jr nz, .fillPendingQueue
	xor a
	ld [wRecordedPathStarted], a
	ld [wRecordedPathWriteIndex], a
	ld [wRecordedPathWrapCount], a
	ld a, [wLevelObjectSpawnTable]
	ld l, a
	ld a, [wLevelObjectSpawnTable + 1]
	ld h, a
	ld b, $28
	xor a
	ld [wLevelObjectRecordIndex], a
.nextSpawnRecord:
	push bc
	push hl
	ld a, [hli]
	bit 7, a
	jp nz, .advanceSpawnRecord
	ld [wLevelObjectRecordType], a
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
	ld [wLevelObjectSkillScratch], a
	dec hl
	ld a, [wLevelObjectRecordType]
	cp $06
	jr nz, .handleObjectRecord
	inc hl
	inc hl
	push bc
	push de
	ld b, [hl]
	ld c, $FF
	call Func_372E
	pop de
	pop bc
	call SetObjectPosition
	jp .advanceSpawnRecord

.handleObjectRecord:
	ld a, [hl]
	bit 7, a
	jr nz, .handleSpecialRecord
	push hl
	ld a, [wLevelObjectRecordType]
	push de
	call GetLevelObjectHealthPenalty
	ld a, d
	ld [wLevelSpawnHealthPenalty], a
	pop de
	ld a, [wLevelObjectRecordType]
	ld b, $01
	ld c, OBJECT_TYPE1_FALLBACK_SPEED
	and a
	jr z, .createObject
	ld b, $00
	ld c, OBJECT_TYPE0_FALLBACK_SPEED
	cp $01
	jr z, .createObject
	ld b, $02
	ld c, OBJECT_TYPE2_FALLBACK_SPEED
.createObject:
	ld a, b
	push bc
	call CreateObjectAtOrigin
	ld a, [wLevelSpawnHealthPenalty]
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
	add a, OBJECT_SEQUENCE_FALLBACK_SPEED_OFFSET
	ld l, a
	ld a, c
	ld [hl], a
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_MOVEMENT_STATE_OFFSET
	ld l, a
	ld a, $80
	ld [hl], a
	pop de
	ld a, [de]
	ld b, a
	call InitializeObjectSequenceStateFar
	jp .initializeCommonFields

.handleSpecialRecord:
	ld a, [wLevelObjectRecordType]
	cp $03
	jr nz, .checkType5
	ld a, [hl]
	and $7F
	ld [wPlayerSpawnDirection], a
	ld a, c
	ld [wPlayerSpawnX], a
	ld a, b
	ld [wPlayerSpawnX + 1], a
	ld a, e
	ld [wPlayerSpawnY], a
	ld a, d
	ld [wPlayerSpawnY + 1], a
	inc hl
	inc hl
	ld a, [wGameStartMode]
	cp $01
	jp z, .advanceSpawnRecord
	ld a, [hl]
	ld [wPlayerObjectType], a
	ld a, [wLevelObjectRecordType]
	call GetLevelObjectHealthPenalty
	ld a, d
	ld [wUnusedPlayerSpawnHealthPenalty], a ; dead write: player creation never reads it
	jp .advanceSpawnRecord

.checkType5:
	cp $05
	jr nz, .selectSpecialObjectType
	push bc
	ld a, [wLevelObjectRecordType]
	push de
	call GetLevelObjectHealthPenalty
	ld a, d
	ld [wLevelSpawnHealthPenalty], a
	pop de
	ld b, $03
	ld c, $00
	jr .createSpecialObject

.selectSpecialObjectType:
	push bc
	ld a, [wLevelObjectRecordType]
	push de
	call GetLevelObjectHealthPenalty
	ld a, d
	ld [wLevelSpawnHealthPenalty], a
	pop de
	ld a, [wLevelObjectRecordType]
	ld b, $01
	ld c, $04
	and a
	jr z, .createSpecialObject
	ld b, $00
	ld c, $05
	cp $01
	jr z, .createSpecialObject
	ld b, $02
	ld c, OBJECT_TYPE2_FALLBACK_SPEED
.createSpecialObject:
	ld a, b
	push bc
	call CreateObjectAtOrigin
	ld a, [wLevelSpawnHealthPenalty]
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
	add a, OBJECT_SEQUENCE_FALLBACK_SPEED_OFFSET
	ld l, a
	ld a, c
	ld [hl], a
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_MOVEMENT_STATE_OFFSET
	ld l, a
	ld a, $80
	ld [hl], a
	pop bc
	call SetObjectPosition
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_SLOT_FLAGS_OFFSET
	ld l, a
	ld a, $80
	ld [hl], a
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_MOVEMENT_STATE_OFFSET
	ld l, a
	ld a, $80
	ld [hl], a
	ld a, l
	and $C0
	add a, $1A
	ld l, a
	xor a
	ld [hl], a
.initializeCommonFields:
	ld a, l
	and $C0
	add a, OBJECT_NONPLAYER_CONTROLLED_FLAG_OFFSET
	ld l, a
	ld a, $01
	ld [hl], a
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_PROXIMITY_DELAY_OFFSET
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
	add a, OBJECT_RESPAWNS_LEFT_OFFSET
	ld e, a
	ld a, [hli]
	ld [de], a
	inc hl
	ld a, e
	and $C0
	add a, OBJECT_LEVEL_SPAWN_INDEX_FLAGS_OFFSET
	ld e, a
	ld a, [wLevelObjectRecordIndex]
	ld [de], a
	ld a, e
	and $C0
	add a, OBJECT_SEQUENCE_ACTION_TIMER_OFFSET
	ld e, a
	xor a
	ld [de], a
	ld a, [hli]
	ld b, $00
	and a
	jr z, .storeBehaviorMode
	ld b, $01
	cp $01
	jr z, .storeBehaviorMode
	ld b, $02
.storeBehaviorMode:
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
	add a, OBJECT_SEQUENCE_TURN_STEP_OFFSET
	ld e, a
	ld a, $01
	ld [de], a
.advanceSpawnRecord:
	ld a, [wLevelObjectRecordIndex]
	inc a
	ld [wLevelObjectRecordIndex], a
	pop hl
	ld de, $000C
	add hl, de
	pop af
	dec a
	ld b, a
	jp nz, .nextSpawnRecord
	ld a, [wLevelObjectAuxTable]
	ld l, a
	ld a, [wLevelObjectAuxTable + 1]
	ld h, a
	ld de, wLevelObjectAuxState
	ld a, LEVEL_OBJECT_AUX_COUNT
.nextAuxRecord:
	push af
	push hl
	push de
	push hl
	push de
	ld b, LEVEL_OBJECT_AUX_STATE_SIZE
.clearAuxStateByte:
	xor a
	ld [de], a
	ld a, b
	dec a
	ld b, a
	jr nz, .clearAuxStateByte
	pop de
	ld bc, $0006
	add hl, bc
	ld a, [hl]
	pop hl
	and a
	jr z, .advanceAuxRecord
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
.advanceAuxRecord:
	pop hl
	ld bc, LEVEL_OBJECT_AUX_STATE_SIZE
	add hl, bc
	ld d, h
	ld e, l
	pop hl
	ld bc, $0008
	add hl, bc
	pop af
	dec a
	jr nz, .nextAuxRecord
	ret


GetLevelObjectHealthPenalty:
	ld e, a
	ld a, [wActiveSkillLevel]
	ld [wLevelObjectSkillScratch], a
	ld d, $26
	and a
	jr z, .type0Penalty
	ld d, $20
	cp $01
	jr z, .type0Penalty
	ld d, $1C
.type0Penalty:
	ld a, e
	and a
	ret z
	ld a, [wLevelObjectSkillScratch]
	ld d, $1D
	and a
	jr z, .type1Penalty
	ld d, $17
	cp $01
	jr z, .type1Penalty
	ld d, $11
.type1Penalty:
	ld a, e
	cp $01
	ret z
	ld a, [wLevelObjectSkillScratch]
	ld d, $2F
	and a
	jr z, .type2Penalty
	ld d, $29
	cp $01
	jr z, .type2Penalty
	ld d, $23
.type2Penalty:
	ld a, e
	cp $02
	ret z
	ld a, [wLevelObjectSkillScratch]
	ld d, $1C
	and a
	jr z, .return
	ld d, $16
	cp $01
	jr z, .return
	ld d, $10
.return:
	ret


GetLevelObjectHealthPenaltyNoLoad:
	ld a, [wLevelObjectSkillScratch]
	ld d, $26
	and a
	jr z, .type0Penalty
	ld d, $20
	cp $01
	jr z, .type0Penalty
	ld d, $1C
.type0Penalty:
	ld a, e
	and a
	ret z
	ld a, [wLevelObjectSkillScratch]
	ld d, $1D
	and a
	jr z, .type1Penalty
	ld d, $17
	cp $01
	jr z, .type1Penalty
	ld d, $11
.type1Penalty:
	ld a, e
	cp $01
	ret z
	ld a, [wLevelObjectSkillScratch]
	ld d, $2F
	and a
	jr z, .type2Penalty
	ld d, $29
	cp $01
	jr z, .type2Penalty
	ld d, $23
.type2Penalty:
	ld a, e
	cp $02
	ret z
	ld a, [wLevelObjectSkillScratch]
	ld d, $1C
	and a
	jr z, .return
	ld d, $16
	cp $01
	jr z, .return
	ld d, $10
.return:
	ret


QueuePendingLevelObject:
	ld a, l
	and $C0
	add a, OBJECT_RESPAWNS_LEFT_OFFSET
	ld l, a
	ld a, [hl]
	and a
	ret z
	ld e, l
	ld d, h
	ld hl, wPendingLevelObjectQueue
	ld b, PENDING_LEVEL_OBJECT_COUNT
.findFreeEntry:
	push bc
	ld a, [hl]
	bit 7, a
	jr z, .advanceEntry
	ld a, e
	and $C0
	add a, OBJECT_LEVEL_SPAWN_INDEX_FLAGS_OFFSET
	ld e, a
	ld a, [de]
	and $7F
	ld [hli], a
	ld b, a
	ld a, e
	and $C0
	add a, OBJECT_RESPAWNS_LEFT_OFFSET
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

.advanceEntry:
	inc hl
	inc hl
	inc hl
	pop af
	dec a
	ld b, a
	jr nz, .findFreeEntry
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
.nextEntry:
	push bc
	push hl
	ld a, [hli]
	bit 7, a
	jr nz, .advanceEntry
	ld b, a
	ld a, [hli]
	ld c, a
	ld a, [hl]
	dec [hl]
	and a
	jr nz, .advanceEntry
	push hl
	call TrySpawnPendingLevelObject
	pop hl
	and a
	jr nz, .clearEntry
	inc [hl]
	jr .advanceEntry

.clearEntry:
	ld a, $FF
	ld [hl], a
	dec hl
	ld [hl], a
	dec hl
	ld [hl], a
.advanceEntry:
	pop hl
	inc hl
	inc hl
	inc hl
	pop af
	dec a
	ld b, a
	jr nz, .nextEntry
	ret


TrySpawnPendingLevelObject:
	ld a, c
	ld [wLevelObjectRespawnsLeft], a
	ld a, b
	ld [wLevelObjectRecordIndex], a
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
	ld [wLevelObjectRecordType], a
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
	ld [wPendingSpawnOutsideView], a
	push bc
	push de
	call AbsoluteDifferenceBCDE
	ld a, d
	and a
	jr nz, .checkYDistance
	ld a, $50
	sub e
	jr nc, .checkYDistance
	ld a, $01
	ld [wPendingSpawnOutsideView], a
.checkYDistance:
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
	jr nz, .checkOutsideView
	ld a, $48
	sub e
	jr nc, .checkOutsideView
	ld a, $01
	ld [wPendingSpawnOutsideView], a
.checkOutsideView:
	pop de
	pop bc
	ld a, [wPendingSpawnOutsideView]
	and a
	jr nz, .spawnObject
	pop hl
	ret

.spawnObject:
	ld a, [hl]
	bit 7, a
	jr nz, .spawnSpecialObject
	ld a, [wLevelObjectRecordType]
	call GetLevelObjectHealthPenalty
	push hl
	ld a, [wLevelObjectRecordType]
	ld b, $01
	ld c, OBJECT_TYPE0_FALLBACK_SPEED ; deferred path swaps the type-0/type-1 speeds
	and a
	jr z, .createObject
	ld b, $00
	ld c, OBJECT_TYPE1_FALLBACK_SPEED
	cp $01
	jr z, .createObject
	ld b, $02
	ld c, OBJECT_TYPE2_FALLBACK_SPEED
.createObject:
	ld a, b
	push bc
	push de
	call CreateObjectAtOrigin
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
	add a, OBJECT_SEQUENCE_FALLBACK_SPEED_OFFSET
	ld l, a
	ld a, c
	ld [hl], a
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_MOVEMENT_STATE_OFFSET
	ld l, a
	ld a, $80
	ld [hl], a
	pop de
	ld a, [de]
	ld b, a
	call InitializeObjectSequenceStateFar
	jr .initializeCommonFields

.spawnSpecialObject:
	ld a, [wLevelObjectRecordType]
	cp $05
	jr nz, .selectSpecialObjectType
	ld a, [wLevelObjectRecordType]
	call GetLevelObjectHealthPenalty
	push bc
	ld b, $03
	ld c, $00
	jr .createSpecialObject

.selectSpecialObjectType:
	push bc
	ld a, [wLevelObjectRecordType]
	call GetLevelObjectHealthPenalty
	ld a, [wLevelObjectRecordType]
	ld b, $01
	ld c, OBJECT_TYPE1_FALLBACK_SPEED
	and a
	jr z, .createSpecialObject
	ld b, $00
	ld c, OBJECT_TYPE0_FALLBACK_SPEED
	cp $01
	jr z, .createSpecialObject
	ld b, $02
	ld c, OBJECT_TYPE2_FALLBACK_SPEED
.createSpecialObject:
	ld a, b
	push bc
	push de
	call CreateObjectAtOrigin
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
	add a, OBJECT_SEQUENCE_FALLBACK_SPEED_OFFSET
	ld l, a
	ld a, c
	ld [hl], a
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_MOVEMENT_STATE_OFFSET
	ld l, a
	ld a, $80
	ld [hl], a
	pop bc
	call SetObjectPosition
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_SLOT_FLAGS_OFFSET
	ld l, a
	ld a, $80
	ld [hl], a
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_MOVEMENT_STATE_OFFSET
	ld l, a
	ld a, $80
	ld [hl], a
	ld a, l
	and $C0
	add a, $1A
	ld l, a
	xor a
	ld [hl], a
.initializeCommonFields:
	ld a, l
	and $C0
	add a, OBJECT_NONPLAYER_CONTROLLED_FLAG_OFFSET
	ld l, a
	ld a, $01
	ld [hl], a
	ld a, l
	and $C0
	add a, OBJECT_SEQUENCE_ACTION_TIMER_OFFSET
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
	add a, OBJECT_RESPAWNS_LEFT_OFFSET
	ld e, a
	ld a, [wLevelObjectRespawnsLeft]
	ld [de], a
	inc hl
	inc hl
	ld a, e
	and $C0
	add a, OBJECT_LEVEL_SPAWN_INDEX_FLAGS_OFFSET
	ld e, a
	ld a, [wLevelObjectRecordIndex]
	ld [de], a
	ld a, [hli]
	ld b, $00
	and a
	jr z, .storeBehaviorMode
	ld b, $01
	cp $01
	jr z, .storeBehaviorMode
	ld b, $02
.storeBehaviorMode:
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
	add a, OBJECT_SEQUENCE_TURN_STEP_OFFSET
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
	jr z, .nonnegative
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

.nonnegative:
	xor a
	ret

Bank04ZeroFill:
	ds $7FFF - @, 0
Bank04BankMarker:
	db $04
