; BattleTanx (USA) - ROM bank $06

SECTION "ROM Bank $06", ROMX[$4000], BANK[$06]
INCLUDE "src/audio_data.asm"

Audio_Init:
	xor a
	ld [wSoundQueueLast], a
	ld [wMusicPtr], a
	ld [wMusicPtr + 1], a
	ld [wNoiseLockTimer], a
	ld [wUnusedChannel1PatchFlag], a
	ld [wUnusedAudioStateC8E4], a
	ld [wMusicNoteOnBlocked], a
	ld [wSfxSeqPtr], a
	ld [wSfxSeqPtr + 1], a
	ld [wSfxSeqLock], a
	ld [wSfxSeqLockId], a
	inc a
	ld [wSfxSeqDelay], a
	ld [wSoundQueueNext], a
	ld [wMusicEnabled], a
	ld c, $00
	ld b, $04
	ld hl, wChannelSettings
.InitChannelSettingsLoop:
	ld a, c
	ld [hli], a
	ld a, $11
	ld [hli], a
	inc c
	dec b
	jr nz, .InitChannelSettingsLoop
	ld hl, $FF30
	ld bc, WaveformPattern
	ld d, $10
.InitWaveRamLoop:
	ld a, [bc]
	ld [hli], a
	inc bc
	dec d
	jr nz, .InitWaveRamLoop
	ld d, $17
	ld bc, $FF10
	ld hl, AudioRegisterInit
.InitSoundRegistersLoop:
	ld a, [hli]
	ld [bc], a
	inc bc
	dec d
	jr nz, .InitSoundRegistersLoop
	ld hl, wSoundQueue
	ld b, SOUND_QUEUE_SIZE
	xor a
.ClearSoundQueueLoop:
	ld [hli], a
	dec b
	jr nz, .ClearSoundQueueLoop
	ret


Music_HandleEvent:
	ld a, b
	cp $8F
	jr c, .DecodeChannelCommand
	cp $FE
	jr z, .HandleControlCommand
	xor a
	ld [wMusicPtr], a
	ld [wMusicPtr + 1], a
	ldh [rNR51], a
	ret

.HandleControlCommand:
	ld a, c
	cp $F0
	jr nc, .LoopSequence
	ld e, a
	call Audio_QueueSound
	ret

.LoopSequence:
	pop de
	pop hl
	ld hl, wMusicLoopPtr
	ld a, [hli]
	ld [wMusicPtr], a
	ld a, [hl]
	ld l, a
	ld [wMusicPtr + 1], a
	ld a, [wMusicPtr]
	ld h, a
	push hl
	push de
	xor a
	ldh [rNR51], a
	ret

.DecodeChannelCommand:
	and $F0
	swap a
	ld d, a
	ld a, b
	and $0F
	ld b, d
	cp $01
	jr z, .NoteOn
	cp $02
	jp z, .NoteOff
	cp $03
	jp z, .SetInstrument
	cp $04
	jp z, .SetPan
	ret

.NoteOn:
	ld a, [wMusicNoteOnBlocked]
	and a
	ret nz
	ld d, $00
	ld e, b
	dec e
	sla e
	ld hl, wChannelSettings
	add hl, de
	srl e
	ld a, [hli]
	ld d, a
	ld a, [hl]
	ld [wNotePan], a
	ld a, e
	cp $03
	jr nz, .LoadInstrument
	ld a, [wNoiseLockTimer]
	and a
	jr z, .ResolveNoiseNote
	ldh a, [rNR52]
	bit 3, a
	ret nz
	xor a
	ld [wNoiseLockTimer], a
.ResolveNoiseNote:
	ld a, c
	sub $0C
	cp $09
	jr nc, .LoadInstrument
	push hl
	push de
	add a, a
	ld hl, NoiseNoteTable
	ld d, $00
	ld e, a
	add hl, de
	ld a, [hli]
	ld [wNotePan], a
	ld a, [hl]
	pop de
	pop hl
	ld d, a
.LoadInstrument:
	ld a, d
	add a, a
	add a, a
	ld d, $00
	ld e, a
	ld hl, Instruments
	add hl, de
	push hl
	ld e, b
	dec e
	sla e
	ld hl, ChannelRegisterBases
	add hl, de
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a
	ld a, b
	cp $03
	jr nz, .WriteInstrument
	xor a
	ldh [rNR34], a
.WriteInstrument:
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
	jr z, .WriteFrequency
	inc de
.WriteFrequency:
	bit 2, b
	jr nz, .SkipFrequency
	push de
	ld hl, NoteFrequencies
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
	jr .EnableChannel

.SkipFrequency:
	inc de
.EnableChannel:
	ld a, [wNotePan]
	ld c, b
.ShiftPanLoop:
	dec c
	jr z, .TriggerChannel
	add a, a
	jr .ShiftPanLoop

.TriggerChannel:
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

.NoteOff:
	ld a, d
	cp $04
	jr nz, .BuildChannelMask
	ld a, [wNoiseLockTimer]
	cp $00
	jr nz, .SetDelayAndReturn
.BuildChannelMask:
	ld a, $11
.ShiftChannelMaskLoop:
	dec d
	jr z, .ApplyChannelMask
	add a, a
	jr .ShiftChannelMaskLoop

.ApplyChannelMask:
	cpl
	ld d, a
	ldh a, [rNR51]
	and d
	ldh [rNR51], a
.SetDelayAndReturn:
	pop de
	pop hl
	dec hl
	ld a, c
	ld [wMusicDelay], a
	push hl
	push de
	ret

.SetInstrument:
	ld hl, wChannelSettings
	ld d, $00
	ld e, b
	dec e
	sla e
	add hl, de
	ld [hl], c
	ret

.SetPan:
	ld hl, wChannelSettings
	ld d, $00
	ld e, b
	dec e
	sla e
	add hl, de
	inc hl
	ld [hl], c
	ret


Audio_PlaySound:
	bit 7, a
	jr nz, .StartMusic
	bit 6, a
	jp nz, .StartSfxSequence
	ld hl, SoundPatches
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
	jr nz, .PatchChannelReady
	ld a, $37
	ld [wNoiseLockTimer], a
	ld a, $04
.PatchChannelReady:
	cp $01
	jr nz, .FindPatchRegisters
	ld [wUnusedChannel1PatchFlag], a
.FindPatchRegisters:
	dec a
	add a, a
	ld e, a
	ld hl, ChannelRegisterBases
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
	jr z, .TriggerPatch
	ld a, [hli]
	ld [de], a
	inc de
.TriggerPatch:
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

.StartMusic:
	and $7F
	add a, a
	add a, a
	ld hl, MusicPointers
	ld d, $00
	ld e, a
	add hl, de
	ld a, [hli]
	ld [wMusicPtr + 1], a
	ld [wMusicLoopPtr + 1], a
	ld a, [hli]
	ld [wMusicLoopPtr], a
	ld [wMusicPtr], a
	ld a, [hl]
	ld [wMusicBank], a
	ld hl, wChannelSettings
	ld b, $00
	ld c, $04
.ResetChannelSettingsLoop:
	ld a, b
	ld [hli], a
	ld a, $11
	ld [hli], a
	inc b
	dec c
	jr nz, .ResetChannelSettingsLoop
	xor a
	ldh [rNR51], a
	ld a, $01
	ld [wMusicDelay], a
	ret

.StartSfxSequence:
	ld b, a
	ld a, [wSfxSeqLock]
	and a
	ret nz
	ld a, [wSfxSeqLockId]
	cp b
	jr nz, .LoadSfxSequence
	xor a
	ld [wSfxSeqLockId], a
	inc a
	ld [wSfxSeqLock], a
.LoadSfxSequence:
	ld a, b
	and $3F
	ld hl, SfxSequencePointers
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld a, [hli]
	ld [wSfxSeqPtr], a
	ld a, [hl]
	ld [wSfxSeqPtr + 1], a
	ld a, $01
	ld [wSfxSeqDelay], a
	ret


SfxSequence_Update:
	ld a, [wSfxSeqPtr + 1]
	and a
	ret z
	ld a, [wSfxSeqDelay]
	dec a
	ld [wSfxSeqDelay], a
.ProcessNextEvent:
	and a
	ret nz
	ld hl, wSfxSeqPtr
	ld a, [hli]
	ld b, a
	ld h, [hl]
	ld l, b
	ld a, [hli]
	cp $FF
	jp z, .EndSequence
	bit 0, a
	jr nz, .DispatchSound
	bit 6, a
	jr nz, .MuteNoise
	ldh a, [rNR51]
	and $EE
	ldh [rNR51], a
	jp .SetDelay

.MuteNoise:
	ldh a, [rNR51]
	and $77
	ldh [rNR51], a
	xor a
	ld [wNoiseLockTimer], a
	jr .SetDelay

.DispatchSound:
	and $F0
	cp $20
	jr z, .PlayTone
	ld a, [hli]
	push hl
	ld hl, SoundPatches
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
	jr nz, .PatchChannelReady
	ld a, $37
	ld [wNoiseLockTimer], a
	ld a, $04
.PatchChannelReady:
	cp $01
	jr nz, .FindPatchRegisters
	ld [wUnusedChannel1PatchFlag], a
.FindPatchRegisters:
	dec a
	add a, a
	ld e, a
	ld hl, ChannelRegisterBases
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
	jr z, .TriggerPatch
	ld a, [hli]
	ld [de], a
	inc de
.TriggerPatch:
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
	jr .SetDelay

.PlayTone:
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
	ld hl, NoteFrequencies
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
.SetDelay:
	ld a, [hli]
	ld [wSfxSeqDelay], a
	ld b, a
	ld a, l
	ld [wSfxSeqPtr], a
	ld a, h
	ld [wSfxSeqPtr + 1], a
	ld a, b
	jp .ProcessNextEvent

.EndSequence:
	ld hl, wSfxSeqPtr
	xor a
	ld [hli], a
	ld [hli], a
	ld [wSfxSeqLock], a
	inc a
	ld [hl], a
	ret

	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $06
