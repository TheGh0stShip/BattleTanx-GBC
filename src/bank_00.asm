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


EnableLCD:
Func_0051:
	ldh a, [rLCDC]
	or $80
	ldh [rLCDC], a
	ret


SerialInterrupt:
	reti


; Clear B bytes starting at HL.
ClearBytes:
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
	ld a, [wLevelComplete]
	or a
	jp nz, Jump_0076
	ld a, [wPlayerAlive]
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
	call PrepareDisplayForScreenTransition
	ld e, $88
	call Audio_QueueSound
	call Func_3B12
	xor a
	ld [wJoypadHeld], a
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
	ld a, [wJoypadHeld]
	or a
	jr z, Jump_009F
	call FadePalettesToBlackWithSound
	call InstallBasicInterruptHandlersFar
	jp Jump_016C

	db $C3, $C3, $00, $C9
Jump_00C7:
	ld e, $83
	call Audio_QueueSound
	call PrepareDisplayForScreenTransition
	call Func_3F28
	call FadePalettesToBlackWithSound
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
	call ClearCgbPalettes
	ld a, $91
	ldh [rLCDC], a
	ld a, [wBootHardwareMode]
	jp Init


EnableBackground:
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
	call InitializeHardware
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
	call PrepareDisplayForScreenTransition
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
	ld [wPauseActive], a
	call ClearCgbPalettes
	call InitializeLevelRuntime
	call LoadInterfaceTilesVRAM1
	call LoadInterfaceTilesVRAM0
	call SpawnPlayerObject
	call Func_37CE
	call LoadLevelLookupPointersFar
	ld hl, $D000
	call FreeObjectRecord
Jump_01B4:
	call ClearCgbPalettes
	xor a
	ldh [rSCX], a
	ldh [rSCY], a
	ld [wPendingScrollX], a
	ld [wPendingScrollY], a
	ld [$C8D9], a
	ldh a, [rLCDC]
	res 4, a
	ldh [rLCDC], a
	call SpawnPlayerObject
	ld a, [wPlayerLives]
	or a
	jp z, Jump_00C7
	call ResetBgMapWriteQueue
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
	ld h, a
	call SetObjectHealthToMax
	ld a, l
	and $C0
	add a, OBJECT_DIRECTION_OFFSET
	ld l, a
	ld a, [wPlayerSpawnDirection]
	ld [hl], a
	ld b, $00
	ld c, $00
	call ResetLevelEndState
	call SetLevelScrollPosition
	call PositionPlayerAtSpawn
	call CenterLevelViewOnObject
	call RefreshLevelViewport
	call ResetOamState
	call InitializeHudWindow
	call LoadLevelPalettes
	call LoadInterfacePalettes
	call LoadObjectPalettes
	call InstallGameplayInterruptHandlersFar
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
	call MoveHudWindow
	dec d
	jr nz, Jump_0214
	call Func_35F7
	ld a, [wMusicPtr]
	and a
	jr nz, Jump_0245
Jump_0236:
	call RandomByte
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
	ld a, HIGH(wDynamicSpriteTiles)
	ldh [rHDMA1], a
	ld a, LOW(wDynamicSpriteTiles)
	ldh [rHDMA2], a
	ld a, $80
	ldh [rHDMA3], a
	xor a
	ldh [rHDMA4], a
	ld a, DYNAMIC_SPRITE_TRANSFER_TILE_COUNT - 1
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
	ld a, [wPendingScrollX]
	ldh [rSCX], a
	ld a, [wPendingScrollY]
	ldh [rSCY], a
	ld a, [wLevelScrollX]
	ld [wPendingScrollX], a
	ld a, [wLevelScrollY]
	ld [wPendingScrollY], a
	call FlushBgMapWriteQueue
	call ResetSpriteAllocators
	xor a
	ld [$CD2A], a
	ld hl, wFrameCounter
	ld a, [hl]
	add a, $01
	ld [hli], a
	ld a, [hl]
	adc a, $00
	ld [hl], a
	ld a, [wScreenEffectActive]
	or a
	jr z, Jump_02E9
	call RenderScreenEffect
	call UpdateScreenEffect
Jump_02E9:
	call Func_22ED
	call Func_3823
	call ClearUnusedShadowOamEntries
	call UpdatePlayerHealthRecovery
	ldh a, [rLY]
	call DrawHudStatus
	ldh a, [rLY]
	call CheckNextScoreThreshold
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
	ld h, a
	call UpdateLevelCamera
	call UpdateLevelEndCountdown
	jp c, Jump_0061
	ld a, [wPauseActive]
	or a
	call nz, RunPauseLoopFar
	ld a, [wScreenEffectActive]
	or a
	jr nz, Jump_0320
	call ProcessGameplayInput
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


RunPauseLoopFar:
Func_033A: ; legacy alias
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


; Wait for VBlank, hide and clear the HUD/palettes, install the basic interrupt
; mode, clear both OAM copies, reset scrolling, and select unsigned BG tiles.
PrepareDisplayForScreenTransition:
Func_035C: ; legacy alias
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
	call DisableHudWindow
	call ClearCgbPalettes
	call InstallBasicInterruptHandlersFar
	call ResetOamState
	call ClearShadowOamAndTransferFar
	xor a
	ldh [rSCY], a
	ldh [rSCX], a
	ldh a, [rLCDC]
	and $EF
	ldh [rLCDC], a
	ret


BeginLevelCompleteCountdown:
Func_0388:
	ld a, c
	ld [wLevelEndCountdown], a
	ld a, b
	ld [wLevelEndCountdown + 1], a
	ld a, $01
	ld [wLevelComplete], a
	ret


BeginPlayerDestroyedCountdown:
Func_0396:
	ld a, c
	ld [wLevelEndCountdown], a
	ld a, b
	ld [wLevelEndCountdown + 1], a
	xor a
	ld [wPlayerAlive], a
	ld e, $87
	call Audio_QueueSound
	ld a, [wHudAlertActive]
	and a
	ret z
	ld c, $01
	ld b, $87
	ld hl, $9C0A
	call WriteBgMapTileAndAttribute
	inc hl
	call WriteBgMapTileAndAttribute
	ld c, $04
	ld hl, $9C2A
	call WriteBgMapTileAndAttribute
	inc hl
	call WriteBgMapTileAndAttribute
	xor a
	ld [wHudAlertActive], a
	ret


ResetLevelEndState:
Func_03CB:
	xor a
	ld [wLevelEndCountdown], a
	ld [wLevelEndCountdown + 1], a
	ld [wLevelComplete], a
	ld a, $01
	ld [wPlayerAlive], a
	ret


; Return carry once an active completion/destruction countdown expires.
UpdateLevelEndCountdown:
Func_03DB:
	ld a, [wPlayerAlive]
	or a
	jr z, Jump_03EA
	ld a, [wLevelComplete]
	or a
	jr nz, Jump_03EA
Jump_03E7:
	scf
	ccf
	ret

Jump_03EA:
	ld a, [wLevelEndCountdown]
	ld c, a
	ld a, [wLevelEndCountdown + 1]
	ld b, a
	or c
	jr z, Jump_0400
	dec bc
	ld a, c
	ld [wLevelEndCountdown], a
	ld a, b
	ld [wLevelEndCountdown + 1], a
	jr Jump_03E7

Jump_0400:
	scf
	ret


LoadLevelLookupPointersFar:
Func_0402: ; legacy alias
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $05
	ld [rROMB0], a
	call LoadLevelLookupPointers
	pop af
	ld [rROMB0], a
	ret


SeedRandomNumberGenerator:
Func_0413:
	push hl
	ld hl, wRandomState
	ld [hl], $C7
	inc hl
	ld [hl], $A4
	inc hl
	ld [hl], $9F
	pop hl
	ret


; Advance the three-byte random state and mix in DIV.
; Returns the generated byte in A.
RandomByte:
Func_0421:
	push hl
	ld hl, wRandomState
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


; For nonzero B, return floor(RandomByte() * B / 256), producing a value below B.
RandomBelowB:
Func_043C:
	push de
	push bc
	push hl
	call RandomByte
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


; Copy D rows of 20 bytes from BC to HL, advancing the destination by 32
; bytes per row.
CopyTilemapRows20:
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


; Write attribute B to VRAM bank 1 and tile C to bank 0 at map address HL.
WriteBgMapTileAndAttribute:
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


; Wait for VBlank line 145 before disabling the LCD.  Turning the display off
; outside VBlank is unsafe on real hardware.
DisableLCDSafely:
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


; Clear all 64 bytes of CGB background palette RAM and all 64 bytes of CGB
; object palette RAM.
ClearCgbPalettes:
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


ClearHardwareOAM:
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


; Clear the byte count encoded by nonzero B at HL: B * $100 bytes when C is
; zero, otherwise (B - 1) * $100 + C bytes.
ClearMemory:
Func_050B:
	xor a
Jump_050C:
	ld [hli], a
	dec c
	jr nz, Jump_050C
	dec b
	jr nz, Jump_050C
	ret


; Set one CGB background-palette colour: D = palette, E = colour, BC = RGB555.
SetBackgroundPaletteColor:
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


; Load C complete CGB background palettes at index B from HL.
LoadBackgroundPaletteRange:
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


; Load one CGB object palette at index B from the three RGB555 colours at HL;
; colour 0 is synthesized as black/transparent.
LoadSingleObjectPalette:
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


; Load C consecutive CGB object palettes starting at index B.  Each source
; record contains colours 1-3; colour 0 is synthesized as black/transparent.
LoadObjectPaletteRange:
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


; Fill exactly BC bytes at HL with A.  The pre-incremented counters make both
; a zero low byte and a sub-$100 length work with the shared decrement loop.
FillBytes:
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


; Copy exactly BC bytes from HL to DE.
CopyBytesBC:
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


; Copy the wScreenWidth x wScreenHeight rectangle at BC to VRAM bank 1 and
; the matching rectangle at DE to VRAM bank 0. HL is the BG-map destination;
; each source row is tightly packed while each destination row is 32 bytes.
; All input registers are preserved.
CopyScreenMaps:
Func_05C5: ; legacy alias
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


; Copy D 16-byte tiles from BC to VRAM.  A is the high byte of the VRAM
; destination and E is its first tile number.
CopyTilesToVRAM:
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


RequireCgbHardware:
	ld a, [wBootHardwareMode]
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
	ld bc, Bank3BGbcWarningTiles
	call CopyTilesToVRAM
	ld bc, Bank3BGbcWarningTileMap
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
	call EnableLCD
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


; Over 32 VBlanks, darken both CGB palette memories toward black while sound
; continues to update. Sound sequence $57 is queued before the first frame.
FadePalettesToBlackWithSound:
Func_06F8: ; legacy alias
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
	call DarkenBackgroundPalettes
	call DarkenObjectPalettes
	dec d
	jr nz, Jump_0701
	ret


; Queue sound sequence $57 and run the 32-frame background-palette fade toward
; white. The bank-$01 implementation performs its own frame waits.
FadeBackgroundPalettesToWhiteWithSound:
Func_071F: ; legacy alias
	ld e, $57
	call Audio_QueueSound
	ld d, $20
	ld e, $01
	call FadeBackgroundPalettesToWhite
	ret


; Clear $C0FF-$CEFF, OAM, HRAM, and all seven switchable WRAM banks.  Fixed
; WRAM at $C000-$C0FE and $CF00-$CFFF survives.
ClearGameMemory:
Func_072C:
	push af
	push bc
	push de
	push hl
	ld hl, $C0FF
	ld bc, $0F01
	call ClearMemory
	ld hl, $FE00
	ld b, $A0
	call ClearBytes
	ld hl, $FF80
	ld b, $7F
	call ClearBytes
	ld a, $07
Jump_074B:
	ldh [rSVBK], a
	ld hl, $D000
	ld bc, $1000
	push af
	call ClearMemory
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


ResetDisplayState:
Func_0764:
	call DisableLCDSafely
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


; At the first VBlank line, clear hardware and shadow OAM, select 8x8 sprites,
; and enable object rendering.
ResetOamState:
Func_0781:
	ldh a, [rLY]
	cp $90
	jr nz, ResetOamState
	ld hl, $FE00
	ld b, $A0
	xor a
Jump_078D:
	ld [hl], a
	inc l
	dec b
	jr nz, Jump_078D
	ld hl, wShadowOam
	ld b, $A0
	call ClearBytes
	ldh a, [rLCDC]
	and $FB
	ldh [rLCDC], a
	ldh a, [rLCDC]
	or $02
	ldh [rLCDC], a
	ret


LoadObjectPalettes:
	ld a, $08
	ld [rROMB0], a
	ld a, $27
	ld [rROMB0], a
	ld hl, Bank27ObjectPalette
	ld b, $00
	ld c, $01
	call LoadObjectPaletteRange
	ld a, $28
	ld [rROMB0], a
	ld hl, Bank28ObjectPalette
	ld b, $01
	ld c, $01
	call LoadObjectPaletteRange
	ld a, $29
	ld [rROMB0], a
	ld hl, Bank29ObjectPalette
	ld b, $02
	ld c, $01
	call LoadObjectPaletteRange
	ld a, $08
	ld [rROMB0], a
	ld hl, Bank08ObjectPalette46EA
	ld b, $03
	ld c, $01
	call LoadObjectPaletteRange
	ld a, $08
	ld [rROMB0], a
	ld hl, Bank08ObjectPalettes67FD
	ld b, $04
	ld c, $04
	call LoadObjectPaletteRange
	ld a, $08
	ld [rROMB0], a
	ld hl, Bank08UiFontPalette + 2 ; colours 1-3 + 2 bytes of SpriteTiles44A8
	ld b, $07
	ld c, $01
	call LoadBackgroundPaletteRange
	ret


; Load the interface sheets used in VRAM bank 1, including the UI font and
; the numeric subset of the alphanumeric font.
LoadInterfaceTilesVRAM1:
	ld a, $08
	ld [rROMB0], a
	ld a, $01
	ldh [rVBK], a
	ld e, $40
	ld d, $01
	ld a, $80
	ld bc, Bank08InterfaceTiles60F8
	call CopyTilesToVRAM
	ld e, $41
	ld d, $02
	ld a, $80
	ld bc, Bank08InterfaceTiles6222
	call CopyTilesToVRAM
	ld e, $43
	ld d, $10
	ld a, $80
	ld bc, Bank08InterfaceTiles611A
	call CopyTilesToVRAM
	ld a, $08
	ld [rROMB0], a
	ld e, $53
	ld d, $0A
	ld a, $80
	ld bc, Bank08HudIconTiles
	call CopyTilesToVRAM
	ld a, $08
	ld [rROMB0], a
	ld e, $5D
	ld d, $0C
	ld a, $80
	ld bc, Bank08InterfaceTiles6815
	call CopyTilesToVRAM
	ld a, $08
	ld [rROMB0], a
	ld e, $43
	ld d, $3D
	ld a, $88
	ld bc, Bank08UiFontTiles + $10
	call CopyTilesToVRAM
	ld a, $08
	ld [rROMB0], a
	ld e, $3B
	ld d, $08
	ld a, $88
	ld bc, Bank08InterfaceTiles69FD
	call CopyTilesToVRAM
	ret


; Load the interface sheets used in VRAM bank 0, including arrows and the
; complete alphanumeric font.
LoadInterfaceTilesVRAM0:
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
	call CopyTilesToVRAM
	ld e, $4E
	ld d, $04
	ld a, $80
	ld bc, Bank08InterfaceTiles68DD
	call CopyTilesToVRAM
	ld e, $52
	ld d, $04
	ld a, $80
	ld bc, Bank08ArrowUpTiles
	call CopyTilesToVRAM
	ld e, $56
	ld d, $04
	ld a, $80
	ld bc, Bank08ArrowDownTiles
	call CopyTilesToVRAM
	ld e, $5A
	ld d, $04
	ld a, $80
	ld bc, Bank08InterfaceTiles69B5
	call CopyTilesToVRAM
	pop af
	ld [rROMB0], a
	ret


InitializeHardware:
Func_08C6:
	di
	ld d, a
	xor a
	ldh [rIE], a
	ldh [rIF], a
	call DisableLCDSafely
	call ClearGameMemory
	ld a, d
	ld [wBootHardwareMode], a
	call RequireCgbHardware
	call ResetDisplayState
	call LoadOAMDMARoutine
	call InstallBasicInterruptHandlersFar
	call EnableLCD
	ld hl, HandleControlScheme1
	ld a, l
	ld [wRuntimeCallback], a
	ld a, h
	ld [wRuntimeCallback + 1], a
	xor a
	ldh [rIF], a
	xor a
	ld [wPlayerObjectType], a
	ld a, $00
	ld [$C6CF], a
	call SeedRandomNumberGenerator
	ei
	nop
	ret


LoadCurrentLevel:
Func_0903:
	ld a, [wLevelNumber]
	call LoadLevelData
	ld b, $00
	ld c, $00
	call SetLevelViewCellPosition
	ret


LoadOAMDMARoutine:
	push af
	push bc
	push de
	push hl
	ld hl, OAMDMARoutineSource
	ld bc, OAMDMARoutine
	ld e, OAMDMARoutineSourceEnd - OAMDMARoutineSource
	call CopyBytesShort
	pop hl
	pop de
	pop bc
	pop af
	ret


OAMDMARoutineSource:
	LOAD UNION "RAM code $FFF0", HRAM[$FFF0] ; copied from OAMDMARoutineSource

OAMDMARoutine:
	ld a, HIGH(wShadowOam)
	ldh [rDMA], a
	ld a, $28
RAM_FFF6:
	dec a
	jr nz, RAM_FFF6
	ret

	ENDL
OAMDMARoutineSourceEnd:
	ASSERT OAMDMARoutineSourceEnd - OAMDMARoutineSource == 10

LoadInterfacePalettes:
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
	ld hl, wBackgroundPalette6
	ld de, rBCPD
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


; Reset per-level object, sprite, display, and transient state; load the active
; level and interface font; and select its animated-cell CGB attribute.
InitializeLevelRuntime:
Func_09AB: ; legacy alias
	call InstallBasicInterruptHandlersFar
	call ClearCgbPalettes
	ld hl, $D000
	ld bc, $1000
	call ClearMemory
	call ClearObjectPool
	call ResetSpriteAllocators
	call EnableBackground
	call ResetOamState
	call LoadCurrentLevel
	call LoadEncodedFontTiles
	ld a, [wScore + 2]
	ld b, a
	ld a, [wScore + 3]
	or b
	jr nz, Jump_09E6
	ld a, [wScore + 1]
	cp $C3
	jr c, Jump_09ED
	jr nz, Jump_09E6
	ld a, [wScore]
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
	ld [wScreenEffectActive], a
	ld [wHudAlertActive], a
	ld [$C91E], a
	ld [$C91F], a
	xor a
	ld [$C8D8], a
	ld [$C8D9], a
	ld b, $00
	ld a, [wLevelNumber]
	ld c, a
	ld hl, LevelAnimatedCellAttributes
	add hl, bc
	ld a, [hl]
	ld [wLevelAnimatedCellAttribute], a
	ret


; One CGB attribute per level for the tiles drawn by cell-map bit 6.
LevelAnimatedCellAttributes:
	db $0A, $0A, $0A, $09, $09, $0A, $0B, $0B, $0B, $0A, $0A, $0A, $0A, $0A, $0A

Func_0A23:
	xor a
	ld [wHudAlertActive], a
	ld [$C8D7], a
	ld [$C8D6], a
	ld [wFrameCounter], a
	ld [wFrameCounter + 1], a
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


; Poll both P1 key groups. Directions occupy bits 0-3 and A/B/Select/Start
; occupy bits 4-7; also derive newly pressed edges from the previous sample.
ReadJoypad:
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
	ld a, [wJoypadHeld]
	xor b
	and b
	ld [wJoypadPressed], a
	ld a, b
	ld [wJoypadHeld], a
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


; Install the WRAM LCD/VBlank handlers used during gameplay and enable both
; interrupt sources through the bank-$02 implementation.
InstallGameplayInterruptHandlersFar:
Func_0AB3: ; legacy alias
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_418A
	pop af
	ld [rROMB0], a
	ret


; Install a one-byte LCD reti and the minimal WRAM VBlank handler, then enable
; only VBlank interrupts through the bank-$02 implementation.
InstallBasicInterruptHandlersFar:
Func_0AC4: ; legacy alias
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_4238
	pop af
	ld [rROMB0], a
	ret


; Create a status-1 object of type A at position 0,0 with direction 0.  The
; original code does not test AllocateObjectRecord's failure return.
CreateObjectAtOrigin:
Func_0AD5:
	push bc
	push de
	push af
	ld a, $01
	call AllocateObjectRecord
	ld bc, $0000
	ld de, $0000
	call SetObjectPosition
	xor a
	call SetObjectDirection
	pop af
	call InitializeObjectType
	ld a, l
	and $C0
	ld l, a
	pop de
	pop bc
	ret


; Remove the object at HL after recording it in the pending-level-object path.
; Nonzero A plays sound $46 and invokes the score/effect helper; nonzero B
; creates a status-4 type-0 object at the old position. Type 3 also redraws its
; two-by-three-cell map footprint. The higher-level meanings of A and B remain
; unresolved.
RemoveObject:
Func_0AF5: ; legacy alias
	push de
	push bc
	push hl
	push af
	push bc
	push de
	push hl
	call QueuePendingLevelObjectFar
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
	call FreeObjectRecord
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
	call SetObjectPosition
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
	call RedrawLevelCells2x3AroundPixel
Jump_0B61:
	pop hl
	pop bc
	pop de
	ret


; Convert pixel X in BC and pixel Y in DE to cells, then redraw the two columns
; from X-1 through X across the three rows from Y-1 through Y+1.
RedrawLevelCells2x3AroundPixel:
Func_0B65: ; legacy alias
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
	call DrawLevelCellIfVisible
	inc c
	call DrawLevelCellIfVisible
	dec c
	inc e
	call DrawLevelCellIfVisible
	inc c
	call DrawLevelCellIfVisible
	dec c
	inc e
	call DrawLevelCellIfVisible
	inc c
	call DrawLevelCellIfVisible
	pop hl
	pop de
	pop bc
	pop af
	ret


CalculateVehicleNextPosition:
Func_0BA1: ; legacy alias
	push de
	push bc
	push hl
	ld a, l
	and $C0
	add a, OBJECT_FLAGS_OFFSET
	ld l, a
	ld a, [hl]
	and OBJECT_VEHICLE_REVERSE_FLAG
	jr z, Jump_0BB8
	ld a, l
	and $C0
	ld l, a
	call LoadVehicleReverseVelocity
	jr Jump_0BBF

Jump_0BB8:
	ld a, l
	and $C0
	ld l, a
	call LoadVehicleForwardVelocity
Jump_0BBF:
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_SPEED_OFFSET
	ld l, a
	ld a, [hl]
	or a
	jp z, Jump_0C12
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_VELOCITY_X_OFFSET
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
	add a, OBJECT_VEHICLE_VELOCITY_Y_OFFSET
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
	and OBJECT_RECORD_ALIGN_MASK
	add a, OBJECT_TYPE_OFFSET
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

ObjectMaxHealthByType:
	db $23, $32, $41, $28

GetObjectMaxHealth:
Func_0C41:
	push hl
	ld a, l
	and OBJECT_RECORD_ALIGN_MASK
	add a, OBJECT_TYPE_OFFSET
	ld l, a
	ld a, [hl]
	ld hl, ObjectMaxHealthByType
	add a, l
	ld l, a
	ld a, [hl]
	pop hl
	ret


AccelerateVehicleReverse:
Func_0C51: ; legacy alias
	push af
	push hl
	ld a, l
	and $C0
	add a, OBJECT_FLAGS_OFFSET
	ld l, a
	ld a, [hl]
	or OBJECT_VEHICLE_REVERSE_FLAG
	ld [hl], a
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_MAX_SPEED_OFFSET
	ld l, a
	ld b, [hl]
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_SPEED_OFFSET
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


AccelerateVehicleForward:
Func_0C74: ; legacy alias
	push af
	push hl
	ld a, l
	and $C0
	add a, OBJECT_FLAGS_OFFSET
	ld l, a
	ld a, [hl]
	and ~OBJECT_VEHICLE_REVERSE_FLAG
	ld [hl], a
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_MAX_SPEED_OFFSET
	ld l, a
	ld b, [hl]
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_SPEED_OFFSET
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


DecelerateVehicle:
Func_0C97: ; legacy alias
	push af
	push hl
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_SPEED_OFFSET
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


StopVehicle:
Func_0CA8: ; legacy alias
	push af
	push hl
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_SPEED_OFFSET
	ld l, a
	xor a
	ld [hl], a
	pop hl
	pop af
	ret


TurnVehicleCounterclockwise:
Func_0CB5: ; legacy alias
	push af
	push hl
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_TURN_TIMER_OFFSET
	ld l, a
	ld a, [hl]
	or a
	jr nz, Jump_0CDA
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_TURN_INTERVAL_OFFSET
	ld l, a
	ld b, [hl]
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_TURN_TIMER_OFFSET
	ld l, a
	ld [hl], b
	ld a, l
	and $C0
	add a, OBJECT_DIRECTION_OFFSET
	ld l, a
	ld a, [hl]
	dec a
	and $0F
	ld [hl], a
Jump_0CDA:
	pop hl
	pop af
	ret


TurnVehicleClockwise:
Func_0CDD: ; legacy alias
	push af
	push hl
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_TURN_TIMER_OFFSET
	ld l, a
	ld a, [hl]
	or a
	jr nz, Jump_0D02
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_TURN_INTERVAL_OFFSET
	ld l, a
	ld b, [hl]
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_TURN_TIMER_OFFSET
	ld l, a
	ld [hl], b
	ld a, l
	and $C0
	add a, OBJECT_DIRECTION_OFFSET
	ld l, a
	ld a, [hl]
	inc a
	and $0F
	ld [hl], a
Jump_0D02:
	pop hl
	pop af
	ret


GetObjectType:
Func_0D05:
	push hl
	ld a, l
	and $C0
	add a, OBJECT_TYPE_OFFSET
	ld l, a
	ld a, [hl]
	pop hl
	ret


InitializeObjectType:
Func_0D0F:
	push hl
	push de
	push bc
	ld b, a
	ld a, l
	and $C0
	add a, OBJECT_TYPE_OFFSET
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
	add a, OBJECT_VEHICLE_TURN_INTERVAL_OFFSET
	ld l, a
	ld [hl], b
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_MAX_SPEED_OFFSET
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
	add a, OBJECT_VEHICLE_SPEED_OFFSET
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
	add a, OBJECT_VEHICLE_TURN_TIMER_OFFSET
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
	call SetObjectHealthToMax
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
	call AllocateDynamicSpriteTiles
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
	ld a, [wLevelViewX]
	ld l, a
	ld a, c
	sub l
	dec a
	ld c, a
	ld a, [wLevelRingX]
	add a, c
	and $1F
	ld c, a
	ld a, [wLevelViewY]
	ld l, a
	ld a, e
	sub l
	dec a
	ld e, a
	ld a, [wLevelRingY]
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
	ld bc, InterfaceMetatiles
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
	call QueueBgMapWrite
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
	call QueueBgMapWrite
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
	call AllocateShadowOamFront
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
	call StartScreenEffect
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
	add a, OBJECT_VEHICLE_TURN_TIMER_OFFSET
	ld l, a
	ld a, [hl]
	or a
	jr z, Jump_1066
	dec a
	ld [hl], a
Jump_1066:
	ld a, [wFrameCounter]
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
	ld a, [wPlayerObject]
	cp l
	jr nz, Jump_109F
	ld a, [wPlayerObject + 1]
	cp h
	jr z, Jump_10CA
Jump_109F:
	ld a, l
	and $C0
	add a, $2B
	ld l, a
	ld b, [hl]
	inc l
	ld a, [wPlayerObject]
	cp b
	jr nz, Jump_10BA
	ld b, [hl]
	ld a, [wPlayerObject + 1]
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
	call RemoveObject
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
	call RemoveObject
	ld bc, $0078
	call BeginPlayerDestroyedCountdown
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


; At pixel coordinate BC,DE, find its bits-2/3 region and begin up to nine
; lookup-state transitions within that rectangle.
StartLevelCellRegionTransitionAtPixel:
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
	call FindLevelCellRunLeftEdge
	ldh [hLevelRegionLeft], a
	call FindLevelCellRunRightEdge
	ldh [hLevelRegionRight], a
	call FindLevelCellRunTopEdge
	ldh [hLevelRegionTop], a
	call FindLevelCellRunBottomEdge
	ldh [hLevelRegionBottom], a
	call StartLevelCellRegionTransitions
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


; Visit the visible 21-by-19-cell area and complete every bit-2 region found.
ConvertVisibleLevelCellBit2Regions:
	push af
	push bc
	push de
	push hl
	ld a, [wLevelViewY]
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
	ld a, [wLevelViewX]
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
	call ConvertLevelCellBit2RegionAtCell
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


; At cell coordinate C,E, find its bits-2/3 region and complete its bit-2
; cells, including redraws and per-cell score awards.
ConvertLevelCellBit2RegionAtCell:
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
	call FindLevelCellRunLeftEdge
	ldh [hLevelRegionLeft], a
	call FindLevelCellRunRightEdge
	ldh [hLevelRegionRight], a
	call FindLevelCellRunTopEdge
	ldh [hLevelRegionTop], a
	call FindLevelCellRunBottomEdge
	ldh [hLevelRegionBottom], a
	call ConvertLevelCellBit2Region
Jump_1214:
	pop hl
	pop de
	pop bc
	pop af
	ret


; At pixel coordinate BC,DE, complete the containing bit-3 region, then play
; its sound and award the fixed 20-point bonus.
ConvertLevelCellBit3RegionAtPixel:
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
	call FindLevelCellRunLeftEdge
	ldh [hLevelRegionLeft], a
	call FindLevelCellRunRightEdge
	ldh [hLevelRegionRight], a
	call FindLevelCellRunTopEdge
	ldh [hLevelRegionTop], a
	call FindLevelCellRunBottomEdge
	ldh [hLevelRegionBottom], a
	call ConvertLevelCellBit3Region
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


; Convert every bit-3 cell in the inclusive HRAM region and redraw changes.
ConvertLevelCellBit3Region:
	push af
	push bc
	push de
	push hl
	ldh a, [hLevelRegionTop]
	ldh [hLevelRegionY], a
Jump_12A9:
	ldh a, [hLevelRegionLeft]
	ldh [hLevelRegionX], a
Jump_12AD:
	ldh a, [hLevelRegionX]
	ld c, a
	ldh a, [hLevelRegionY]
	ld e, a
	call ConvertLevelCellBit3ToLookupState
	jr z, Jump_12BB
	call DrawLevelCellIfVisible
Jump_12BB:
	ldh a, [hLevelRegionRight]
	inc a
	ld b, a
	ldh a, [hLevelRegionX]
	inc a
	ldh [hLevelRegionX], a
	cp b
	jr c, Jump_12AD
	ldh a, [hLevelRegionBottom]
	inc a
	ld b, a
	ldh a, [hLevelRegionY]
	inc a
	ldh [hLevelRegionY], a
	cp b
	jr c, Jump_12A9
	pop hl
	pop de
	pop bc
	pop af
	ret


; Convert every bit-2 cell in the inclusive HRAM region, redraw it, and award
; five points per changed cell.
ConvertLevelCellBit2Region:
	push af
	push bc
	push de
	push hl
	xor a
	ldh [hLevelRegionScore], a
	ldh [hLevelRegionScore + 1], a
	ld e, $45
	call Audio_QueueSound
	ldh a, [hLevelRegionTop]
	ldh [hLevelRegionY], a
Jump_12EA:
	ldh a, [hLevelRegionLeft]
	ldh [hLevelRegionX], a
Jump_12EE:
	ldh a, [hLevelRegionX]
	ld c, a
	ldh a, [hLevelRegionY]
	ld e, a
	call ConvertLevelCellBit2ToLookupState
	jr z, Jump_1308
	ldh a, [hLevelRegionScore]
	add a, $05
	ldh [hLevelRegionScore], a
	ldh a, [hLevelRegionScore + 1]
	adc a, $00
	ldh [hLevelRegionScore + 1], a
	call DrawLevelCellIfVisible
Jump_1308:
	ldh a, [hLevelRegionRight]
	inc a
	ld b, a
	ldh a, [hLevelRegionX]
	inc a
	ldh [hLevelRegionX], a
	cp b
	jr c, Jump_12EE
	ldh a, [hLevelRegionBottom]
	inc a
	ld b, a
	ldh a, [hLevelRegionY]
	inc a
	ldh [hLevelRegionY], a
	cp b
	jr c, Jump_12EA
	ldh a, [hLevelRegionScore]
	ld c, a
	ldh a, [hLevelRegionScore + 1]
	ld b, a
	call AddToScore
	pop hl
	pop de
	pop bc
	pop af
	ret


; If cell C,E has bit 2 set, clear bits 1-3 and 6, set bits 0 and 7,
; preserve bits 4-5, and report success in A.
ConvertLevelCellBit2ToLookupState:
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


; If cell C,E has bit 3 set, clear bits 1-3, set bits 0 and 7, preserve the
; high nibble, and report success in A.
ConvertLevelCellBit3ToLookupState:
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


ChooseRandomLevelRegionCell:
	ldh a, [hLevelRegionTop]
	ld b, a
	ldh a, [hLevelRegionBottom]
	sub b
	inc a
	ld b, a
	call RandomBelowB
	ld b, a
	ldh a, [hLevelRegionTop]
	add a, b
	ld e, a
	ldh a, [hLevelRegionLeft]
	ld b, a
	ldh a, [hLevelRegionRight]
	sub b
	inc a
	ld b, a
	call RandomBelowB
	ld b, a
	ldh a, [hLevelRegionLeft]
	add a, b
	ld c, a
	ret


; Start lookup-state transitions at random cells in the current region. Stop
; after nine reported changes; fall back to completing all bit-2 cells after
; six retries or when fewer than five changes were reported in a full pass.
StartLevelCellRegionTransitions:
	push af
	push bc
	push de
	push hl
	ld e, $44
	call Audio_QueueSound
	xor a
	ldh [hLevelRegionChangedCount], a
	ldh [hLevelRegionRetryCount], a
	ldh a, [hLevelRegionTop]
	ldh [hLevelRegionY], a
Jump_1437:
	ldh a, [hLevelRegionLeft]
	ldh [hLevelRegionX], a
Jump_143B:
	call ChooseRandomLevelRegionCell
	call StartLevelCellLookupTransition
	jr nz, Jump_1457
	ldh a, [hLevelRegionX]
	ld c, a
	ldh a, [hLevelRegionY]
	ld e, a
	call StartLevelCellLookupTransition
	ldh a, [hLevelRegionRetryCount]
	inc a
	ldh [hLevelRegionRetryCount], a
	cp $06
	jr z, Jump_14AB
	jr z, Jump_148D
Jump_1457:
	call DrawLevelCellIfVisible
	ldh a, [hLevelRegionChangedCount]
	inc a
	ldh [hLevelRegionChangedCount], a
	push af
	call RandomByte
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
	ldh a, [hLevelRegionRight]
	inc a
	ld b, a
	ldh a, [hLevelRegionX]
	inc a
	ldh [hLevelRegionX], a
	cp b
	jr c, Jump_143B
	ldh a, [hLevelRegionBottom]
	inc a
	ld b, a
	ldh a, [hLevelRegionY]
	inc a
	ldh [hLevelRegionY], a
	cp b
	jr c, Jump_1437
	ldh a, [hLevelRegionChangedCount]
	cp $05
	jr nc, Jump_14AE
Jump_14AB:
	call ConvertLevelCellBit2Region
Jump_14AE:
	pop hl
	pop de
	pop bc
	pop af
	ret


; For an unconverted bit-2 cell, set bit 6 when bit 3 is clear or bit 7 when
; bit 3 is set. These states select the alternate rendering paths at $1D93.
StartLevelCellLookupTransition:
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


; Starting inside a cell whose bits 2-3 are nonzero, return the left edge of
; its contiguous horizontal run. C and E are cell coordinates.
FindLevelCellRunLeftEdge:
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


; Return the right edge of the same bits-2/3 horizontal run.
FindLevelCellRunRightEdge:
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


; Return the top edge of the same bits-2/3 vertical run.
FindLevelCellRunTopEdge:
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


; Return the bottom edge of the same bits-2/3 vertical run.
FindLevelCellRunBottomEdge:
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


; Return cell-map bit 3 for the cell containing pixel coordinate BC,DE.
TestLevelCellBit3AtPixel:
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


; Return cell-map bit 0 for the cell containing pixel coordinate BC,DE.
TestLevelCellBit0AtPixel:
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


; Return cell-map bit 1 for the cell containing pixel coordinate BC,DE.
TestLevelCellBit1AtPixel:
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


; Return cell-map bit 2 for the cell containing pixel coordinate BC,DE.
TestLevelCellBit2AtPixel:
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


UpdateLevelCamera:
	push de
	push bc
	push hl
	ld a, [wLevelCameraX]
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
	call ScrollLevelLeft
Jump_1826:
	ld a, [wLevelCameraX]
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
	call ScrollLevelRight
Jump_1846:
	ld a, [wLevelCameraY]
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
	call ScrollLevelUp
Jump_1866:
	ld a, [wLevelCameraY]
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
	call ScrollLevelDown
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
	ld [wLevelPixelWidth], a
	ld a, b
	ld [wLevelPixelWidth + 1], a
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
	ld [wLevelPixelHeight], a
	ld a, b
	ld [wLevelPixelHeight + 1], a
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
	call SetLevelViewCellPosition
	ld b, $00
	ld c, $00
	call SetLevelScrollPosition
	call LoadLevelTiles
	call LoadLevelCellMap
	ld a, $01
	ld [rROMB0], a
	pop hl
	pop de
	pop bc
	pop af
	ret


PositionPlayerAtSpawn:
Func_1927:
	push af
	push bc
	push de
	push hl
	ld a, [wPlayerSpawnX]
	ld c, a
	ld a, [wPlayerSpawnX + 1]
	ld b, a
	ld a, [wPlayerSpawnY]
	ld e, a
	ld a, [wPlayerSpawnY + 1]
	ld d, a
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
	ld h, a
	call SetObjectPosition
	pop hl
	pop de
	pop bc
	pop af
	ret


; Center the 21x19-cell viewport on the object at HL, clamped to level bounds.
CenterLevelViewOnObject:
Func_194B:
	push af
	push bc
	push de
	push hl
	ld a, l
	and $C0
	inc a ; OBJECT_X_OFFSET
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
	add a, OBJECT_Y_OFFSET
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
	call SetLevelViewCellPosition
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
	call CopyTilesToVRAM
	ld a, $00
	add a, c
	ld c, a
	ld a, $08
	adc a, b
	ld b, a
	ld d, $80
	ld e, $00
	ld a, $90
	call CopyTilesToVRAM
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
	call CopyTilesToVRAM
	ld a, $00
	add a, c
	ld c, a
	ld a, $08
	adc a, b
	ld b, a
	ld d, $38
	ld e, $00
	ld a, $88
	call CopyTilesToVRAM
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
	call LoadBackgroundPaletteRange
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


RefreshLevelViewport:
	call ResetBgMapWriteQueue
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call DrawLevelViewport
	call DrawLevelLeftColumn
	call DrawLevelRightColumn
	call DrawLevelTopRow
	call DrawLevelBottomRow
	call FlushBgMapWriteQueue
	pop af
	ld [rROMB0], a
	ret


SetLevelViewCellPosition:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call SetLevelViewCellPositionBank2
	pop af
	ld [rROMB0], a
	ret


SetLevelScrollPosition:
	push af
	push bc
	ld a, b
	ld [wLevelScrollX], a
	srl a
	srl a
	srl a
	ld [wLevelRingX], a
	ld a, c
	ld [wLevelScrollY], a
	srl a
	srl a
	srl a
	ld [wLevelRingY], a
	call CacheLevelRingRowOffset
	pop bc
	pop af
	ret


CacheLevelRingRowOffset:
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
	ld [wLevelRingRowOffset], a
	ld a, h
	ld [wLevelRingRowOffset + 1], a
	pop hl
	pop af
	ret


CacheLevelViewRowOffset:
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
	ld [wLevelViewRowOffset], a
	ld a, h
	ld [wLevelViewRowOffset + 1], a
	pop af
	pop hl
	pop de
	pop bc
	pop af
	ret


ScrollLevelRight:
	ld e, a
	ld a, [wLevelRingX]
	ld d, a
	ld a, [wLevelScrollX]
	add a, e
	srl a
	srl a
	srl a
	cp d
	jr z, Jump_1BCD
	ld a, [wLevelWidth]
	sub $15
	ld b, a
	ld a, [wLevelViewX]
	cp b
	ret z
	ld a, [wLevelCameraX]
	add a, e
	ld [wLevelCameraX], a
	ld a, [wLevelCameraX + 1]
	adc a, $00
	ld [wLevelCameraX + 1], a
	ld a, [wLevelScrollX]
	add a, e
	ld [wLevelScrollX], a
	srl a
	srl a
	srl a
	ld [wLevelRingX], a
	ld a, [wLevelCameraX]
	ld c, a
	ld a, [wLevelCameraX + 1]
	ld b, a
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	ld a, c
	ld [wLevelViewX], a
	call DrawLevelRightColumn
	ret

Jump_1BCD:
	ld a, [wLevelCameraX]
	add a, e
	ld [wLevelCameraX], a
	ld a, [wLevelCameraX + 1]
	adc a, $00
	ld [wLevelCameraX + 1], a
	ld a, [wLevelScrollX]
	add a, e
	ld [wLevelScrollX], a
	ret


ScrollLevelLeft:
	ld e, a
	ld a, [wLevelRingX]
	ld d, a
	ld a, [wLevelScrollX]
	sub e
	srl a
	srl a
	srl a
	cp d
	jr z, Jump_1C36
	ld a, [wLevelViewX]
	or a
	ret z
	ld a, [wLevelCameraX]
	sub e
	ld [wLevelCameraX], a
	ld a, [wLevelCameraX + 1]
	sbc a, $00
	ld [wLevelCameraX + 1], a
	ld a, [wLevelScrollX]
	sub e
	ld [wLevelScrollX], a
	srl a
	srl a
	srl a
	ld [wLevelRingX], a
	ld a, [wLevelCameraX]
	ld c, a
	ld a, [wLevelCameraX + 1]
	ld b, a
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	ld a, c
	ld [wLevelViewX], a
	call DrawLevelLeftColumn
	ret

Jump_1C36:
	ld a, [wLevelCameraX]
	sub e
	ld [wLevelCameraX], a
	ld a, [wLevelCameraX + 1]
	sbc a, $00
	ld [wLevelCameraX + 1], a
	ld a, [wLevelScrollX]
	sub e
	ld [wLevelScrollX], a
	ret


ScrollLevelDown:
	ld e, a
	ld a, [wLevelRingY]
	ld d, a
	ld a, [wLevelScrollY]
	add a, e
	srl a
	srl a
	srl a
	cp d
	jr z, Jump_1CA5
	ld a, [wLevelHeight]
	sub $13
	ld b, a
	ld a, [wLevelViewY]
	cp b
	ret z
	ld a, [wLevelCameraY]
	add a, e
	ld [wLevelCameraY], a
	ld a, [wLevelCameraY + 1]
	adc a, $00
	ld [wLevelCameraY + 1], a
	ld a, [wLevelScrollY]
	add a, e
	ld [wLevelScrollY], a
	srl a
	srl a
	srl a
	ld [wLevelRingY], a
	ld a, [wLevelCameraY]
	ld c, a
	ld a, [wLevelCameraY + 1]
	ld b, a
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	ld a, c
	ld [wLevelViewY], a
	call DrawLevelBottomRow
	ret

Jump_1CA5:
	ld a, [wLevelCameraY]
	add a, e
	ld [wLevelCameraY], a
	ld a, [wLevelCameraY + 1]
	adc a, $00
	ld [wLevelCameraY + 1], a
	ld a, [wLevelScrollY]
	add a, e
	ld [wLevelScrollY], a
	ret


ScrollLevelUp:
	ld e, a
	ld a, [wLevelRingY]
	ld d, a
	ld a, [wLevelScrollY]
	sub e
	srl a
	srl a
	srl a
	cp d
	jr z, Jump_1D0F
	ld a, [wLevelViewY]
	or a
	ret z
	ld a, [wLevelCameraY]
	sub e
	ld [wLevelCameraY], a
	ld a, [wLevelCameraY + 1]
	sbc a, $00
	ld [wLevelCameraY + 1], a
	ld a, [wLevelScrollY]
	sub e
	ld [wLevelScrollY], a
	srl a
	srl a
	srl a
	ld [wLevelRingY], a
	ld a, [wLevelCameraY]
	ld c, a
	ld a, [wLevelCameraY + 1]
	ld b, a
	dec bc
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	ld a, c
	ld [wLevelViewY], a
	call DrawLevelTopRow
	ret

Jump_1D0F:
	ld a, [wLevelCameraY]
	sub e
	ld [wLevelCameraY], a
	ld a, [wLevelCameraY + 1]
	sbc a, $00
	ld [wLevelCameraY + 1], a
	ld a, [wLevelScrollY]
	sub e
	ld [wLevelScrollY], a
	ret


DrawLevelCellIfVisible:
	push af
	push bc
	push de
	push hl
	ld a, c
	ldh [$FFA0], a
	ld a, e
	ldh [$FFA1], a
	ld a, [wLevelViewX]
	ld l, a
	ld a, c
	sub l
	ld c, a
	cp $20
	jp nc, Jump_1D8E
	ld a, [wLevelRingX]
	add a, c
	and $1F
	ld c, a
	ld a, [wLevelViewY]
	ld l, a
	ld a, e
	sub l
	ld e, a
	cp $20
	jp nc, Jump_1D8E
	ld a, [wLevelRingY]
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
	call WriteLevelCellToBGMap
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
	ld a, [wLevelAnimatedCellAttribute]
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


WriteLevelCellToBGMap:
	push af
	push bc
	push de
	push hl
	call GetLevelCellTileAndAttr
	ld b, d
	ld c, e
	ld e, l
	ld d, h
	call QueueBgMapWrite
	pop hl
	pop de
	pop bc
	pop af
	ret


DrawLevelRow21:
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
	call WriteLevelCellToBGMap
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


DrawLevelColumn19:
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
	call WriteLevelCellToBGMap
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


GetLevelBGMapAddress:
	push af
	push bc
	ld a, [wLevelRingY]
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
	ld a, [wLevelRingX]
	add a, b
	and $1F
	or l
	ld l, a
	pop bc
	pop af
	ret


DrawLevelRightColumn:
	push af
	push bc
	push de
	push hl
	ld b, $14
	ld c, $00
	call GetLevelBGMapAddress
	ld a, [wLevelViewX]
	add a, $14
	ld b, a
	ld a, [wLevelViewY]
	ld c, a
	call DrawLevelColumn19
	pop hl
	pop de
	pop bc
	pop af
	ret


DrawLevelLeftColumn:
	push af
	push bc
	push de
	push hl
	ld b, $00
	ld c, $00
	call GetLevelBGMapAddress
	ld a, [wLevelViewX]
	ld b, a
	ld a, [wLevelViewY]
	ld c, a
	call DrawLevelColumn19
	pop hl
	pop de
	pop bc
	pop af
	ret


DrawLevelTopRow:
	push af
	push bc
	push de
	push hl
	ld b, $00
	ld c, $00
	call GetLevelBGMapAddress
	ld a, [wLevelViewX]
	ld b, a
	ld a, [wLevelViewY]
	ld c, a
	call DrawLevelRow21
	pop hl
	pop de
	pop bc
	pop af
	ret


DrawLevelBottomRow:
	push af
	push bc
	push de
	push hl
	ld b, $00
	ld c, $12
	call GetLevelBGMapAddress
	ld a, [wLevelViewX]
	ld b, a
	ld a, [wLevelViewY]
	add a, $12
	ld c, a
	call DrawLevelRow21
	pop hl
	pop de
	pop bc
	pop af
	ret


DrawLevelViewport:
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
	ld a, [wLevelViewX]
	ldh [$FF92], a
	ld a, [wLevelViewY]
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
	call GetLevelBGMapAddress
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


; Allocate the first free object record, set its status to A, and return HL at
; the record base with A = 1. Return A = 0 if all 64 records are occupied.
AllocateObjectRecord:
Func_1FF5:
	push bc
	push de
	ld d, OBJECT_COUNT
	ld c, a
	ld hl, wObjectPool
Jump_1FFD:
	ld a, l
	and $C0
	add a, OBJECT_STATUS_OFFSET
	ld l, a
	ld a, [hl]
	cp $00
	jr z, Jump_2018
	ld a, l
	and $C0
	add a, OBJECT_RECORD_SIZE
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
	add a, OBJECT_STATUS_OFFSET
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


ClearObjectPool:
Func_2028:
	push de
	push af
	push hl
	ld d, OBJECT_COUNT
	ld hl, wObjectPool
Jump_2030:
	call FreeObjectRecord
	ld a, l
	and $C0
	add a, OBJECT_RECORD_SIZE
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


FreeObjectRecord:
Func_2044:
	push af
	push hl
	ld a, l
	and $C0
	add a, OBJECT_STATUS_OFFSET
	ld l, a
	ld a, [hl]
	cp $02
	call z, Func_2C35
	ld a, $00
	ld [hl], a
	pop hl
	pop af
	ret


; Reset the per-frame shadow-OAM and dynamic sprite-tile allocators. Ordinary
; entries grow upward from $C600; priority/overlay entries grow downward from
; $C69C. Dynamic tile bytes grow upward from $C100.
ResetSpriteAllocators:
Func_2058:
	ld a, $00
	ld [wShadowOamFrontPtr], a
	ld a, $C6
	ld [wShadowOamFrontPtr + 1], a
	ld a, $9C
	ld [wShadowOamBackPtr], a
	ld a, $C6
	ld [wShadowOamBackPtr + 1], a
	ld a, SHADOW_OAM_ENTRY_COUNT
	ld [wShadowOamFreeCount], a
	xor a
	ld [wDynamicSpriteTileCount], a
	ld a, LOW(wDynamicSpriteTiles)
	ld [wDynamicSpriteTileWritePtr], a
	ld a, HIGH(wDynamicSpriteTiles)
	ld [wDynamicSpriteTileWritePtr + 1], a
	ret


; Return 1 when A shadow-OAM entries remain available, otherwise return 2.
ClassifyShadowOamCapacity:
Func_2080:
	push bc
	ld b, a
	ld a, [wShadowOamFreeCount]
	sub b
	jr c, Jump_208C
	ld a, $01
	pop bc
	ret

Jump_208C:
	ld a, $02
	pop bc
	ret


; Allocate one shadow-OAM entry from the front in DE. Once exhausted, return
; the discard entry so callers may keep writing without corrupting live OAM.
AllocateShadowOamFront:
Func_2090:
	ld a, [wShadowOamFreeCount]
	or a
	jr nz, Jump_209A
	ld de, wDiscardedOamEntry
	ret

Jump_209A:
	dec a
	ld [wShadowOamFreeCount], a
	ld a, [wShadowOamFrontPtr]
	ld e, a
	add a, $04
	ld [wShadowOamFrontPtr], a
	ld a, [wShadowOamFrontPtr + 1]
	ld d, a
	adc a, $00
	ld [wShadowOamFrontPtr + 1], a
	ret


; Allocate one shadow-OAM entry from the back in DE, or return the discard
; entry when all 40 slots have already been consumed.
AllocateShadowOamBack:
Func_20B1:
	ld a, [wShadowOamFreeCount]
	or a
	jr nz, Jump_20BB
	ld de, wDiscardedOamEntry
	ret

Jump_20BB:
	dec a
	ld [wShadowOamFreeCount], a
	ld a, [wShadowOamBackPtr]
	ld e, a
	sub $04
	ld [wShadowOamBackPtr], a
	ld a, [wShadowOamBackPtr + 1]
	ld d, a
	sbc a, $00
	ld [wShadowOamBackPtr + 1], a
	ret


; Reserve A native 16-byte tiles in the dynamic sprite staging buffer. Return
; its first tile index in A and byte destination in DE; return A=$FF, DE=0 if
; the resulting count would reach 49. The VBlank path only transfers 40 tiles.
AllocateDynamicSpriteTiles:
Func_20D2:
	ld d, a
	ld a, [wDynamicSpriteTileCount]
	ld c, a
	add a, d
	cp DYNAMIC_SPRITE_TILE_REJECT_AT
	jr nc, Jump_20F8
	ld [wDynamicSpriteTileCount], a
	ld a, d
	add a, a
	add a, a
	add a, a
	add a, a
	ld b, a
	ld a, [wDynamicSpriteTileWritePtr]
	ld e, a
	add a, b
	ld [wDynamicSpriteTileWritePtr], a
	ld a, [wDynamicSpriteTileWritePtr + 1]
	ld d, a
	adc a, $00
	ld [wDynamicSpriteTileWritePtr + 1], a
	ld a, c
	ret

Jump_20F8:
	xor a
	ld d, a
	ld e, a
	ld a, $FF
	ret


; Clear every still-unallocated shadow-OAM entry between the front and back
; allocations so stale sprites cannot survive into the next hardware DMA.
ClearUnusedShadowOamEntries:
Func_20FE:
	ld a, [wShadowOamFrontPtr]
	ld l, a
	ld a, [wShadowOamFrontPtr + 1]
	ld h, a
	ld a, [wShadowOamFreeCount]
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


SetObjectDirection:
Func_2115:
	push hl
	push af
	push af
	ld a, l
	and $C0
	add a, OBJECT_DIRECTION_OFFSET
	ld l, a
	pop af
	and $0F
	ld [hl], a
	pop af
	pop hl
	ret


; Initialize the candidate 16.8 position from BC,DE, commit it, snapshot it as
; the previous position, and recalculate screen coordinates.
SetObjectPosition:
Func_2125:
	push af
	push bc
	push de
	push hl
	ld a, l
	and $C0
	add a, OBJECT_NEXT_X_SUBPIXEL_OFFSET
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
	call CommitObjectNextPosition
	call SaveObjectPreviousPosition
	pop hl
	push hl
	call UpdateObjectScreenPosition
	pop hl
	pop de
	pop bc
	pop af
	ret


UpdateObjectScreenPosition:
Func_214D:
	push af
	push bc
	push de
	push hl
	ld a, l
	and $C0
	inc a ; OBJECT_X_OFFSET
	ld l, a
	ld a, [wLevelCameraX]
	ld c, a
	ld a, [hli]
	sub c
	ld c, a
	ld a, [wLevelCameraX + 1]
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
	add a, OBJECT_SCREEN_X_OFFSET
	ld l, a
	ld a, c
	add a, $08
	ld [hl], a
	ld a, l
	and $C0
	add a, OBJECT_Y_OFFSET
	ld l, a
	ld a, [wLevelCameraY]
	ld c, a
	ld a, [hli]
	sub c
	ld c, a
	ld a, [wLevelCameraY + 1]
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
	add a, OBJECT_SCREEN_Y_OFFSET
	ld l, a
	ld a, c
	add a, $10
	ld [hl], a
	ld a, l
	and $C0
	add a, OBJECT_FLAGS_OFFSET
	ld l, a
	ld a, [hl]
	or OBJECT_VISIBLE_FLAG
	ld [hl], a
	pop hl
	pop de
	pop bc
	pop af
	ret

Jump_21DF:
	ld a, l
	and $C0
	add a, OBJECT_FLAGS_OFFSET
	ld l, a
	ld a, [hl]
	and ~OBJECT_VISIBLE_FLAG
	ld [hl], a
	ld a, l
	and $C0
	add a, OBJECT_SCREEN_X_OFFSET
	ld l, a
	xor a
	ld [hli], a
	ld [hl], a
	pop hl
	pop de
	pop bc
	pop af
	ret


SaveObjectPreviousPosition:
Func_21F7:
	push hl
	push bc
	ld a, l
	and $C0
	inc a ; OBJECT_X_OFFSET
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	ld a, l
	and $C0
	add a, OBJECT_PREVIOUS_X_OFFSET
	ld l, a
	ld [hl], c
	inc l
	ld [hl], b
	ld a, l
	and $C0
	add a, OBJECT_Y_OFFSET
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	ld a, l
	and $C0
	add a, OBJECT_PREVIOUS_Y_OFFSET
	ld l, a
	ld [hl], c
	inc l
	ld [hl], b
	pop bc
	pop hl
	ret


CommitObjectNextPosition:
Func_221F:
	push de
	push hl
	ld e, l
	ld d, h
	ld a, l
	and OBJECT_RECORD_ALIGN_MASK
	add a, OBJECT_NEXT_X_SUBPIXEL_OFFSET
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


LoadVehicleForwardVelocity:
Func_2241: ; legacy alias
	push af
	push bc
	push de
	push hl
	ld e, l
	ld d, h
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_SPEED_OFFSET
	ld l, a
	ld a, [hl]
	cp $00
	jr z, Jump_2290
	dec a
	ldh [$FF80], a
	ld a, l
	and $C0
	add a, OBJECT_DIRECTION_OFFSET
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
	ld a, OBJECT_VEHICLE_VELOCITY_X_OFFSET
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


LoadVehicleReverseVelocity:
Func_2295: ; legacy alias
	push af
	push bc
	push de
	push hl
	ld e, l
	ld d, h
	ld a, l
	and $C0
	add a, OBJECT_VEHICLE_SPEED_OFFSET
	ld l, a
	ld a, [hl]
	cp $00
	jr z, Jump_22E8
	dec a
	ldh [$FF80], a
	ld a, l
	and $C0
	add a, OBJECT_DIRECTION_OFFSET
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
	ld a, OBJECT_VEHICLE_VELOCITY_X_OFFSET
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
	call UpdateObjectScreenPosition
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
	call SaveObjectPreviousPosition
	call CommitObjectNextPosition
	call UpdateObjectFrameDisplacement
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
	call CalculateVehicleNextPosition
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
	call ResolveObjectType1ProximityMovement
	call ResolveObjectLevelBit0Movement
	call HandleObjectLevelBit3Cell
	call DispatchNearbyType4Entity
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
	call HandleObjectLevelBit1And2Cells
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
	call RenderObjectSprite
Jump_23B0:
	call AdvanceTimedObjectEffect
	jp Jump_232B


; Require cell-map bit 0 at eight points around a 20-by-16-pixel footprint.
TestLevelCellBit0Footprint:
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
	call TestLevelCellBit0AtPixel
	or a
	jp z, Jump_2438
	ld a, c
	add a, $0A
	ld c, a
	ld a, b
	adc a, $00
	ld b, a
	call TestLevelCellBit0AtPixel
	or a
	jp z, Jump_2438
	ld a, c
	add a, $0A
	ld c, a
	ld a, b
	adc a, $00
	ld b, a
	call TestLevelCellBit0AtPixel
	or a
	jp z, Jump_2438
	ld a, e
	add a, $0A
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	call TestLevelCellBit0AtPixel
	or a
	jp z, Jump_2438
	ld a, e
	add a, $0A
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	call TestLevelCellBit0AtPixel
	or a
	jp z, Jump_2438
	ld a, c
	sub $0A
	ld c, a
	ld a, b
	sbc a, $00
	ld b, a
	call TestLevelCellBit0AtPixel
	or a
	jp z, Jump_2438
	ld a, c
	sub $0A
	ld c, a
	ld a, b
	sbc a, $00
	ld b, a
	call TestLevelCellBit0AtPixel
	or a
	jp z, Jump_2438
	ld a, e
	sub $0A
	ld e, a
	ld a, d
	sbc a, $00
	ld d, a
	call TestLevelCellBit0AtPixel
	or a
	jp z, Jump_2438
Jump_2438:
	pop de
	pop bc
	ret


; Classify signed BC against the horizontal level bounds.
; Returns 0 inside, 1 left of zero, or 2 at/right of the pixel width.
ClassifyLevelXBoundary:
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
	ld a, [wLevelPixelWidth + 1]
	add a, $80
	ld e, a
	ld a, b
	add a, $80
	cp e
	jr nz, Jump_2460
	ld a, [wLevelPixelWidth]
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


; Classify signed DE against the vertical level bounds.
; Returns 0 inside, 4 above zero, or 2 at/below the pixel height.
ClassifyLevelYBoundary:
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
	ld a, [wLevelPixelHeight + 1]
	add a, $80
	ld c, a
	ld a, d
	add a, $80
	cp c
	jr nz, Jump_2492
	ld a, [wLevelPixelHeight]
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


; Store current-minus-previous X and Y low-byte displacement in the object's
; frame-delta fields. HL addresses one 64-byte object record.
UpdateObjectFrameDisplacement:
	push de
	ld e, l
	ld a, l
	and $C0
	add a, OBJECT_PREVIOUS_X_OFFSET
	ld l, a
	ld d, [hl]
	ld a, l
	and $C0
	inc a ; OBJECT_X_OFFSET
	ld l, a
	ld a, [hl]
	sub d
	ld d, a
	ld a, l
	and $C0
	add a, OBJECT_FRAME_DX_OFFSET
	ld l, a
	ld [hl], d
	ld a, l
	and $C0
	add a, OBJECT_PREVIOUS_Y_OFFSET
	ld l, a
	ld d, [hl]
	ld a, l
	and $C0
	add a, OBJECT_Y_OFFSET
	ld l, a
	ld a, [hl]
	sub d
	ld d, a
	ld a, l
	and $C0
	add a, OBJECT_FRAME_DY_OFFSET
	ld l, a
	ld [hl], d
	ld l, e
	pop de
	ret


; For an entity with flag bit 3, scan the 64 records for the first flag-bit-3
; type-4 entity within 12 pixels on both axes and dispatch its handler.
DispatchNearbyType4Entity:
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
	call ObjectsWithin12Pixels
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
	call DispatchEntityHandlerFar
	pop hl
	pop bc
	pop de
	ret


; Return 1 when the objects at HL and BC differ by at most 12 pixels on both
; 16-bit position axes, otherwise return 0.
ObjectsWithin12Pixels:
	push hl
	push bc
	push de
	ld a, l
	and $C0
	inc a ; OBJECT_X_OFFSET
	ld l, a
	ld a, c
	and $C0
	inc a ; OBJECT_X_OFFSET
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
	add a, OBJECT_Y_OFFSET
	ld l, a
	ld a, c
	and $C0
	add a, OBJECT_Y_OFFSET
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


; Reject each movement axis independently when its candidate coordinate is
; outside the level or reaches a cell whose bit 0 is clear. Objects with flag
; bit 3 test an eight-point footprint; other objects test one coordinate.
ResolveObjectLevelBit0Movement:
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
	call ClassifyLevelXBoundary
	or a
	jr nz, Jump_25D2
	ld a, l
	and $C0
	add a, $08
	ld l, a
	ld a, [hl]
	and $08
	jr z, Jump_25CC
	call TestLevelCellBit0Footprint
	or a
	jr nz, Jump_25F0
	jr Jump_25D2

Jump_25CC:
	call TestLevelCellBit0AtPixel
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
	call ClassifyLevelYBoundary
	or a
	jr nz, Jump_2620
	ld a, l
	and $C0
	add a, $08
	ld l, a
	ld a, [hl]
	and $08
	jr z, Jump_261A
	call TestLevelCellBit0Footprint
	or a
	jr nz, Jump_2640
	jr Jump_2620

Jump_261A:
	call TestLevelCellBit0AtPixel
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


; Active objects with flag bit 3 complete a bit-3 cell region at their current
; position.
HandleObjectLevelBit3Cell:
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
	call TestLevelCellBit3AtPixel
	or a
	jr z, Jump_267B
	call ConvertLevelCellBit3RegionAtPixel
	ld a, $02
	call Func_3090
Jump_267B:
	pop bc
	pop de
Jump_267D:
	pop hl
	ret


; For flag-bit-3 objects, apply the state-$20 response to cell bits 1 and 2.
; State 0 starts a region transition on bit 1. State 1 handles each axis,
; rolling it back on bit 1 alone or starting a transition when bit 2 is also
; set. State 2 has no map response.
HandleObjectLevelBit1And2Cells:
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
	call TestLevelCellBit1AtPixel
	jr z, Jump_26F6
	call TestLevelCellBit2AtPixel
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
	call TestLevelCellBit1AtPixel
	jr z, Jump_2744
	call TestLevelCellBit2AtPixel
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
	call FreeObjectRecord
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
	call TestLevelCellBit1AtPixel
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
	call TestLevelCellBit1AtPixel
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
	call FreeObjectRecord
	pop hl
	pop de
	pop bc
	pop af
	ret

Jump_27BA:
	ld a, l
	and $C0
	ld l, a
	call StartLevelCellRegionTransitionAtPixel
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
	call FreeObjectRecord
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


; Reject candidate movement when an active object comes within 20 pixels on
; both axes of another type-1 entity. The first match restores both axes from
; the object's current coordinates.
ResolveObjectType1ProximityMovement:
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
	call ObjectCandidatesWithin20Pixels
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


; Return 1 when candidate positions +$14/+17 of the objects at HL and BC are
; within 20 pixels on both axes.
ObjectCandidatesWithin20Pixels:
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
	call SubtractObjectHealth
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
	call FreeObjectRecord
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


LoadEncodedFontTiles:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $08
	ld [rROMB0], a
	xor a
	ldh [rVBK], a
	ld e, $00
	ld d, $25
	ld a, $80
	ld bc, EncodedFontTiles
	call CopyTilesToVRAM
	call ClearTextCursor
	pop af
	ld [rROMB0], a
	ret


ClearTextCursor:
	push af
	ld a, $00
	ld [wTextColumn], a
	ld [wTextRow], a
	pop af
	ret


AdvanceTextColumn:
	push af
	ld a, [wTextColumn]
	inc a
	ld [wTextColumn], a
	pop af
	ret


DrawEncodedText:
	push hl
	push af
Jump_2AD0:
	ld a, [hli]
	or a
	jr z, Jump_2AF4
	cp $0D
	jr nz, Jump_2ADD
	call StartTextRow
	jr Jump_2AD0

Jump_2ADD:
	cp $0C
	jr nz, Jump_2AE6
	call ClearTextCursor
	jr Jump_2AD0

Jump_2AE6:
	cp $01
	jr nz, Jump_2AEF
	call AdvanceTextColumn
	jr Jump_2AD0

Jump_2AEF:
	call DrawEncodedGlyph
	jr Jump_2AD0

Jump_2AF4:
	pop af
	pop hl
	ret


DrawEncodedGlyph:
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
	ld hl, EncodedGlyphTable
	add hl, bc
	ld c, [hl]
	ld a, [wTextRow]
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
	ld a, [wTextColumn]
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
	call AdvanceTextColumn
	pop af
	ld [rROMB0], a
	pop hl
	pop de
	pop bc
	pop af
	ret


SetTextCursor:
	push af
	ld a, b
	and $1F
	ld [wTextColumn], a
	ld a, c
	and $1F
	ld [wTextRow], a
	pop af
	ret


StartTextRow:
	push af
	xor a
	ld [wTextColumn], a
	ld a, [wTextRow]
	inc a
	ld [wTextRow], a
	pop af
	ret


AdvanceTextRow:
	push af
	ld a, [wTextRow]
	inc a
	ld [wTextRow], a
	pop af
	ret


ClearTextColumn:
	push af
	xor a
	ld [wTextColumn], a
	pop af
	ret


Func_2B86:
	push de
	push hl
	push bc
	push hl
	call Func_2C24
	ld a, $02
	call AllocateObjectRecord
	jp z, Jump_2C1F
	call SetObjectPosition
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
	call z, LoadVehicleForwardVelocity
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
	call FreeObjectRecord
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
	call AllocateShadowOamFront
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
	call AllocateShadowOamFront
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
	ld a, [wVBlankCounter]
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
	call AllocateShadowOamFront
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


SetObjectHealthToMax:
Func_2F93:
	push bc
	push hl
	call GetObjectMaxHealth
	ld b, a
	ld a, l
	and OBJECT_RECORD_ALIGN_MASK
	add a, OBJECT_HEALTH_OFFSET
	ld l, a
	ld [hl], b
	pop hl
	pop bc
	ret


AddObjectHealth:
Func_2FA3:
	push bc
	push hl
	call GetObjectMaxHealth
	ld c, a
	ld a, l
	and OBJECT_RECORD_ALIGN_MASK
	add a, OBJECT_HEALTH_OFFSET
	ld l, a
	ld a, b
	and OBJECT_HEALTH_DELTA_MASK
	add a, [hl]
	cp c
	jr c, Jump_2FB7
	ld a, c
Jump_2FB7:
	ld [hl], a
	pop hl
	pop bc
	ret


SubtractObjectHealth:
Func_2FBB:
	push hl
	ld a, b
	and OBJECT_HEALTH_DELTA_MASK
	ld b, a
	ld a, l
	and OBJECT_RECORD_ALIGN_MASK
	add a, OBJECT_HEALTH_OFFSET
	ld l, a
	ld a, [hl]
	sub b
	jr nc, Jump_2FCB
	xor a
Jump_2FCB:
	ld [hl], a
	pop hl
	ret


UpdatePlayerHealthRecovery:
Func_2FCE:
	ld a, [wPlayerHealthRecoveryTicks]
	or a
	ret z
	ld b, a
	ld a, [wVBlankCounter]
	and $01
	ret z
	ld a, b
	dec a
	ld [wPlayerHealthRecoveryTicks], a
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
	ld h, a
	ld b, $01
	call AddObjectHealth
	ret


GainPlayerLife:
Func_2FED:
	ld a, [wPlayerLives]
	cp $09
	jr z, Jump_2FF8
	inc a
	ld [wPlayerLives], a
Jump_2FF8:
	ret


LosePlayerLife:
Func_2FF9:
	ld a, [wPlayerLives]
	or a
	jr z, Jump_3003
	dec a
	ld [wPlayerLives], a
Jump_3003:
	ret


ResetPlayerLives:
Func_3004:
	ld a, $03
	ld [wPlayerLives], a
	ret


ResetScore:
Func_300A:
	push hl
	xor a
	ld [wScoreThresholdIndex], a
	ld hl, wScore
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	pop hl
	ret


AddToScore:
	push hl
	ld hl, wScore
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


CheckNextScoreThreshold:
Func_302D:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	ld hl, $418F
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
	jr c, Jump_307A
	jr nz, Jump_306E
	ld a, [hld]
	ld b, a
	ld a, [wScore + 2]
	cp b
	jr c, Jump_307A
	jr nz, Jump_306E
	ld a, [hld]
	ld b, a
	ld a, [wScore + 1]
	cp b
	jr c, Jump_307A
	jr nz, Jump_306E
	ld a, [hld]
	ld b, a
	ld a, [wScore]
	cp b
	jr c, Jump_307A
Jump_306E:
	call GainPlayerLife
	ld e, $52
	call Audio_QueueSound
	ld a, c
	ld [wScoreThresholdIndex], a
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
	call AllocateObjectRecord
	call SetObjectPosition
	xor a
	call SetObjectDirection
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


; Render the object at HL through the shared tile and shadow-OAM allocators.
; The frame index is byte +$1F divided by four: health for core vehicles and
; elapsed age for timed effects. Frame and layout pointers reside in bank $02;
; the selected native 2bpp frame resides in bank $08.
RenderObjectSprite:
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
	ld a, OBJECT_HEALTH_OR_AGE_OFFSET
	add a, e
	ld l, a
	ld a, [hl]
	srl a
	srl a
	ldh [$FF85], a
	ld a, OBJECT_TYPE_OFFSET
	add a, e
	ld l, a
	ld a, [hl]
	ldh [$FF80], a
	ld a, OBJECT_FRAME_TABLE_OFFSET
	add a, e
	ld l, a
	ld a, [hli]
	ldh [$FF86], a
	ld a, [hl]
	ldh [$FF87], a
	ld a, OBJECT_OAM_LAYOUT_OFFSET
	add a, e
	ld l, a
	ld a, [hli]
	ldh [$FF88], a
	ld a, [hl]
	ldh [$FF89], a
	ld a, OBJECT_TILE_COUNT_OFFSET
	add a, e
	ld l, a
	ld a, [hl]
	ldh [$FF8A], a
	call AllocateDynamicSpriteTiles
	cp $FF
	jr z, Jump_3157
	ldh [$FF84], a
	call LoadObjectAnimationTiles
	call BuildObjectOamEntries
Jump_3157:
	pop af
	ld [rROMB0], a
	pop hl
	pop bc
	pop de
	ret


; Append the object's bank-$02 four-byte layout records to shadow OAM, adding
; its screen position and the tile index allocated by RenderObjectSprite.
BuildObjectOamEntries:
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
	call AllocateShadowOamFront
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


; Resolve the selected frame through a bank-$02 pointer table and copy the
; requested number of 16-byte tiles from bank $08 to the staging buffer at DE.
LoadObjectAnimationTiles:
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


; Increment a timed type-3 effect's age and release its object record once the
; age reaches byte +$20. Core vehicle records interpret the same two offsets as
; current and maximum health, so this routine is only used by the type-3 path.
AdvanceTimedObjectEffect:
Func_31E3:
	push de
	push hl
	ld a, l
	and $C0
	add a, OBJECT_MAX_HEALTH_OR_LIFE_OFFSET
	ld l, a
	ld d, [hl]
	ld a, l
	and $C0
	add a, OBJECT_EFFECT_AGE_OFFSET
	ld l, a
	ld a, [hl]
	inc a
	ld [hl], a
	cp d
	jr c, Jump_31FF
	ld a, l
	and $C0
	ld l, a
	call FreeObjectRecord
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


; Write attribute B to the HUD staging cell at HL and tile C to its matching
; cell $40 bytes later. RefreshHud transfers the two staging maps separately.
WriteHudTileAndAttribute:
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


; Position the HUD window below the screen, enable its LCD/LYC machinery, and
; build and transfer the initial tile and attribute maps.
InitializeHudWindow:
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
	call RefreshHud
	ret


; Move the HUD window by signed delta B and keep its LYC trigger one line above.
MoveHudWindow:
Func_3252:
	ldh a, [rWY]
	add a, b
	ldh [rWY], a
	dec a
	ldh [rLYC], a
	ret


; Rebuild the two 5-row HUD maps at $C400/$C440, wait for VBlank, then transfer
; them to VRAM bank 1 and bank 0 at $9C00.
RefreshHud:
Func_325B:
	call Func_32A3
	call DrawHudStatus
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


; Hide the HUD window and disable the STAT LYC interrupt used at its boundary.
DisableHudWindow:
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


DrawHudStatus:
Func_3302:
	call DrawHudScore
	call DrawPlayerHealthBar
	call DrawHudPowerupAndAlert
	call DrawPlayerLivesDigit
	ret


; Multiply unsigned C by unsigned DE. Return the 24-bit product in A:HL.
MultiplyU8ByU16:
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

HudHealthScaleByType:
	dw $0150, $00EB, $00B5

; Draw the player's health as six horizontal bar cells. Each object type uses
; a fixed-point scale chosen so its maximum health fills the complete meter.
DrawPlayerHealthBar:
Func_334A:
	push af
	push bc
	push de
	push hl
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
	ld h, a
	ld a, l
	and $C0
	add a, OBJECT_HEALTH_OFFSET
	ld l, a
	ld c, [hl]
	ld b, $00
	ld a, l
	and $C0
	add a, OBJECT_TYPE_OFFSET
	ld l, a
	ld a, [wPlayerAlive]
	and a
	jr nz, Jump_336C
	ld c, a
Jump_336C:
	ld a, [hl]
	add a, a
	add a, LOW(HudHealthScaleByType)
	ld l, a
	ld a, LOW(HudHealthScaleByType) - LOW(HudHealthScaleByType)
	adc a, HIGH(HudHealthScaleByType)
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	call MultiplyU8ByU16
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


; Draw the active power-up icon and charge digit, plus the independent blinking
; four-tile HUD alert controlled by wHudAlertActive.
DrawHudPowerupAndAlert:
Func_3439:
	push af
	push bc
	push de
	push hl
	ld b, $87
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
	ld h, a
	ld a, l
	and $C0
	add a, OBJECT_PLAYER_POWERUP_TYPE_OFFSET
	ld l, a
	ld a, [hl]
	cp $00
	jr z, Jump_346E
	ld d, a
	call DrawPlayerPowerupIcon
	ld a, l
	and $C0
	add a, OBJECT_PLAYER_POWERUP_CHARGES_OFFSET
	ld l, a
	ld a, [hl]
	cp $0A
	jr c, Jump_3463
	ld a, $09
Jump_3463:
	add a, $30
	ld c, a
	ld hl, $C407
	call WriteHudTileAndAttribute
	jr Jump_348A

Jump_346E:
	ld c, $01
	ld hl, $C407
	call WriteHudTileAndAttribute
	inc hl
	call WriteHudTileAndAttribute
	inc hl
	call WriteHudTileAndAttribute
	ld c, $04
	ld hl, $C428
	call WriteHudTileAndAttribute
	inc hl
	call WriteHudTileAndAttribute
Jump_348A:
	ld a, [wHudAlertActive]
	and a
	jr z, Jump_34CE
	ld a, [wVBlankCounter]
	bit 4, a
	jr z, Jump_34B4
	ld c, $5A
	ld b, $87
	ld hl, $C40A
	call WriteHudTileAndAttribute
	inc hl
	inc c
	call WriteHudTileAndAttribute
	inc c
	ld hl, $C42A
	call WriteHudTileAndAttribute
	inc hl
	inc c
	call WriteHudTileAndAttribute
	jr Jump_34CE

Jump_34B4:
	ld c, $01
	ld b, $87
	ld hl, $C40A
	call WriteHudTileAndAttribute
	inc hl
	call WriteHudTileAndAttribute
	ld c, $04
	ld hl, $C42A
	call WriteHudTileAndAttribute
	inc hl
	call WriteHudTileAndAttribute
Jump_34CE:
	pop hl
	pop de
	pop bc
	pop af
	ret

HudPowerupFirstTiles:
	db $00, $4E, $52, $56
HudPowerupPalettes:
	dw $0000, wArrowUpPalette, wArrowDownPalette, wAlphanumericFontPalette

; Draw power-up kind D as a 2-by-2 icon and copy its eight-byte CGB palette to
; the buffer consumed by the installed scanline palette uploader.
DrawPlayerPowerupIcon:
Func_34DF:
	push af
	push bc
	push de
	push hl
	ld a, d
	add a, LOW(HudPowerupFirstTiles)
	ld l, a
	ld a, LOW(HudPowerupFirstTiles) - LOW(HudPowerupFirstTiles)
	adc a, HIGH(HudPowerupFirstTiles)
	ld h, a
	ld c, [hl]
	ld b, $86
	ld hl, $C408
	call WriteHudTileAndAttribute
	inc hl
	inc c
	call WriteHudTileAndAttribute
	inc c
	ld hl, $C428
	call WriteHudTileAndAttribute
	inc hl
	inc c
	call WriteHudTileAndAttribute
	ld a, d
	add a, a
	add a, LOW(HudPowerupPalettes)
	ld l, a
	ld a, LOW(HudPowerupPalettes) - LOW(HudPowerupPalettes)
	adc a, HIGH(HudPowerupPalettes)
	ld h, a
	ld bc, wHudPowerupPalette
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


DrawPlayerLivesDigit:
Func_3533:
	push hl
	push bc
	ld b, $87
	ld a, [wPlayerLives]
	add a, $30
	ld c, a
	ld hl, $C401
	call WriteHudTileAndAttribute
	pop bc
	pop hl
	ret


; Draw decimal digit D as a two-tile-high glyph at HUD attribute cell HL.
DrawHudScoreDigit:
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


; Convert the 32-bit score to packed decimal, suppress leading zeroes, and draw
; its six least-significant digits into the HUD staging maps.
DrawHudScore:
Func_356B:
	push af
	push bc
	push de
	push hl
	ld a, [wScore]
	ld c, a
	ld a, [wScore + 1]
	ld b, a
	ld a, [wScore + 2]
	ld e, a
	ld a, [wScore + 3]
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
	call DrawHudScoreDigit
Jump_35B6:
	inc hl
	dec e
	jr nz, Jump_3590
	ld a, [bc]
	and $0F
	ld d, a
	call DrawHudScoreDigit
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


SpawnPlayerObject:
Func_35D7:
	push af
	push bc
	push de
	push hl
	ld a, [wPlayerObjectType]
	call CreateObjectAtOrigin
	ld a, l
	ld [wPlayerObject], a
	ld a, h
	ld [wPlayerObject + 1], a
	ld bc, $0028
	ld de, $003C
	call SetObjectPosition
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


ProcessGameplayInput:
Func_3608: ; legacy alias
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
	ld h, a
	push hl
	ld a, [wJoypadHeld]
	ld e, a
	ld a, e
	cp $80
	jr nz, Jump_3621
	ld a, [wPauseActive]
	cpl
	ld [wPauseActive], a
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
	ld a, [wPauseActive]
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


HandleControlScheme0:
Func_364E: ; legacy alias
	pop hl
	ld a, e
	and $02
	jr z, Jump_3657
	call TurnVehicleCounterclockwise
Jump_3657:
	ld a, e
	and $01
	jr z, Jump_365F
	call TurnVehicleClockwise
Jump_365F:
	ld a, e
	and $04
	jr z, Jump_3669
	call AccelerateVehicleForward
	jr Jump_3676

Jump_3669:
	ld a, e
	and $08
	jr z, Jump_3673
	call AccelerateVehicleReverse
	jr Jump_3676

Jump_3673:
	call DecelerateVehicle
Jump_3676:
	ld a, e
	and $10
	jr z, Jump_367E
	call Func_0F98
Jump_367E:
	ret

HandleControlScheme1:
Func_367F: ; legacy alias
	pop hl
	ld a, e
	and $02
	jr z, Jump_3688
	call TurnVehicleCounterclockwise
Jump_3688:
	ld a, e
	and $01
	jr z, Jump_3690
	call TurnVehicleClockwise
Jump_3690:
	ld a, e
	and $14
	jr z, Jump_369A
	call AccelerateVehicleForward
	jr Jump_36A7

Jump_369A:
	ld a, e
	and $08
	jr z, Jump_36A4
	call AccelerateVehicleReverse
	jr Jump_36A7

Jump_36A4:
	call DecelerateVehicle
Jump_36A7:
	ld a, e
	and $20
	ret z
	call Func_0F98
	ret


HandleControlScheme2:
Func_36AF: ; legacy alias
	pop hl
	ld a, e
	and $0F
	cp $02
	jr nz, Jump_36C1
	ld a, $0C
	call SetObjectDirection
	call AccelerateVehicleForward
	jr Jump_3726

Jump_36C1:
	cp $01
	jr nz, Jump_36CF
	ld a, $04
	call SetObjectDirection
	call AccelerateVehicleForward
	jr Jump_3726

Jump_36CF:
	cp $04
	jr nz, Jump_36DD
	ld a, $00
	call SetObjectDirection
	call AccelerateVehicleForward
	jr Jump_3726

Jump_36DD:
	cp $08
	jr nz, Jump_36EB
	ld a, $08
	call SetObjectDirection
	call AccelerateVehicleForward
	jr Jump_3726

Jump_36EB:
	cp $06
	jr nz, Jump_36F9
	ld a, $0E
	call SetObjectDirection
	call AccelerateVehicleForward
	jr Jump_3726

Jump_36F9:
	cp $0A
	jr nz, Jump_3707
	ld a, $0A
	call SetObjectDirection
	call AccelerateVehicleForward
	jr Jump_3726

Jump_3707:
	cp $05
	jr nz, Jump_3715
	ld a, $02
	call SetObjectDirection
	call AccelerateVehicleForward
	jr Jump_3726

Jump_3715:
	cp $09
	jr nz, Jump_3723
	ld a, $06
	call SetObjectDirection
	call AccelerateVehicleForward
	jr Jump_3726

Jump_3723:
	call DecelerateVehicle
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
	call AllocateObjectRecord
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


DispatchEntityHandlerFar:
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
	call FreeObjectRecord
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
	ld a, [wVBlankCounter]
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
	call InitializeLevelObjects
	pop af
	ld [rROMB0], a
	ret


QueuePendingLevelObjectFar:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $04
	ld [rROMB0], a
	call QueuePendingLevelObject
	pop af
	ld [rROMB0], a
	ret


UpdatePendingLevelObjectsFar:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $04
	ld [rROMB0], a
	call UpdatePendingLevelObjects
	pop af
	ld [rROMB0], a
	ret


InitializeObjectSequenceStateFar:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $03
	ld [rROMB0], a
	call InitializeObjectSequenceState
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


; Subtract E from each RGB555 channel in BC, saturating at zero.
DarkenRgb555:
Func_3856:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_46B1
	pop af
	ld [rROMB0], a
	ret


; Add E to each RGB555 channel in BC, saturating at 31.
BrightenRgb555:
Func_3867:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_4703
	pop af
	ld [rROMB0], a
	ret


; Darken all 32 background-palette colours by E through the bank-$01 helper.
DarkenBackgroundPalettes:
Func_3878:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call Func_01_475E
	pop af
	ld [rROMB0], a
	ret


; Capture the current background palettes, build a fade toward white, and play
; its frames through the bank-$01 implementation.
FadeBackgroundPalettesToWhite:
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


; Clear all 32 background-palette colours through the bank-$02 implementation.
ClearBackgroundPalettes:
Func_3960:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_46E1
	pop af
	ld [rROMB0], a
	ret


; Wait for any held button or for D VBlanks, whichever happens first.
WaitForButtonOrTimeout:
Func_3971:
	xor a
	ld [wJoypadHeld], a
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
	ld a, [wJoypadHeld]
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
	ld hl, wScreenModeBank
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
	ld hl, wScreenModeBank
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
	ld bc, wScreenModeEntry
	ld e, SCREEN_MODE_ENTRY_SIZE
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call CopyBytesShort
	pop af
	ld [rROMB0], a
	ret


; Darken all 32 object-palette colours by E through the bank-$02 helper.
DarkenObjectPalettes:
Func_3A1E:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_4710
	pop af
	ld [rROMB0], a
	ret


; Build 31 intermediate 64-byte background-palette frames in WRAM bank 2.
; Frame 31 is the target prepared by PrepareBackgroundPaletteFade.
BuildBackgroundPaletteFadeFrames:
Func_3A2F:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $02
	ld [rROMB0], a
	call Func_02_474B
	pop af
	ld [rROMB0], a
	ret


; Return wBackgroundPaletteFadeFrames + A * 64 in HL (WRAM bank 2).
GetBackgroundPaletteFrameAddress:
Func_3A40:
	push bc
	ld hl, wBackgroundPaletteFadeFrames
	ld b, a
	ld c, $00
	srl b
	rr c
	srl b
	rr c
	add hl, bc
	pop bc
	ret


; Load all eight background palettes from cached frame E in WRAM bank 2.
LoadBackgroundPaletteFrame:
Func_3A52:
	ld a, $02
	ldh [rSVBK], a
	ld a, e
	call GetBackgroundPaletteFrameAddress
	ld c, $08
	ld b, $00
	push de
	call LoadBackgroundPaletteRange
	ld a, $01
	ldh [rSVBK], a
	pop de
	ret


; Copy palette D from cached frame E to the eight-byte buffer at BC.
CopyBackgroundPaletteFromFrame:
Func_3A68:
	ld a, $02
	ldh [rSVBK], a
	ld a, e
	call GetBackgroundPaletteFrameAddress
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


; Clear the 32-frame palette cache, then copy E target bytes from bank D and
; source HL to frame 31. Unwritten target colours remain black.
PrepareBackgroundPaletteFade:
Func_3A88:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, d
	ld [rROMB0], a
	ld a, $02
	ldh [rSVBK], a
	push hl
	ld hl, wBackgroundPaletteFadeFrames
	ld bc, BACKGROUND_PALETTE_CACHE_SIZE
	call ClearMemory
	pop hl
	ld bc, wBackgroundPaletteFadeTarget
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
	call ClearShadowOamAndTransferFar
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
	call RandomByte
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
	call ClearBackgroundPalettes
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
	call PrepareDisplayForScreenTransition
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
	ld a, [wJoypadHeld]
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
	call InstallBasicInterruptHandlersFar
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


; Reset the WRAM-bank-4 deferred BG-map queue.
ResetBgMapWriteQueue:
Func_3C19: ; legacy alias
	ld a, LOW(wBgMapWriteQueue)
	ld [wBgMapWritePtr], a
	ld a, HIGH(wBgMapWriteQueue)
	ld [wBgMapWritePtr + 1], a
	xor a
	ld [wBgMapWriteCount], a
	ret


; Append DE destination, B attribute, and C tile as one four-byte record in
; WRAM bank 4. The original code does not check count or pointer overflow.
QueueBgMapWrite:
Func_3C28: ; legacy alias
	push af
	push hl
	ldh a, [rSVBK]
	push af
	ld a, $04
	ldh [rSVBK], a
	ld a, [wBgMapWritePtr]
	ld l, a
	ld a, [wBgMapWritePtr + 1]
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
	ld [wBgMapWritePtr], a
	ld a, h
	ld [wBgMapWritePtr + 1], a
	ld a, [wBgMapWriteCount]
	inc a
	ld [wBgMapWriteCount], a
	pop af
	ldh [rSVBK], a
	pop hl
	pop af
	ret


; Apply every queued record to both VRAM banks, then reset the queue.
FlushBgMapWriteQueue:
Func_3C56: ; legacy alias
	push af
	push bc
	push hl
	ld a, [wBgMapWriteCount]
	or a
	jr z, Jump_3C76
	ld b, a
	ldh a, [rSVBK]
	push af
	ld a, $04
	ldh [rSVBK], a
	ld hl, wBgMapWriteQueue
Jump_3C6A:
	call ApplyBgMapWrite
	dec b
	jr nz, Jump_3C6A
	pop af
	ldh [rSVBK], a
	call ResetBgMapWriteQueue
Jump_3C76:
	pop hl
	pop bc
	pop af
	ret


; Apply one HL record: attribute to VRAM bank 1, then tile to bank 0.
ApplyBgMapWrite:
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


; On the next VBlank, clear all 40 shadow OAM entries in bank 2 and invoke the
; HRAM DMA routine so hardware OAM is cleared as well.
ClearShadowOamAndTransferFar:
Func_3CD9: ; legacy alias
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


StartScreenEffect:
	push af
	push bc
	push de
	push hl
	ld a, [wPlayerObject]
	ld l, a
	ld a, [wPlayerObject + 1]
	ld h, a
	ld a, l
	and $C0
	add a, $06
	ld l, a
	ld a, [hli]
	ld [wScreenEffectX], a
	ld a, [hli]
	ld [wScreenEffectY], a
	ld [wScreenEffectBottomY], a
	sub $10
	ld [wScreenEffectTopY], a
	call StopVehicle
	ld a, SCREEN_EFFECT_DURATION
	ld [wScreenEffectCountdown], a
	ld a, SCREEN_EFFECT_BLANK_COUNT
	ld [wScreenEffectBlankCount], a
	ld a, $58
	ld [wScreenEffectStepTable], a
	ld a, $63
	ld [wScreenEffectStepTable + 1], a
	ld a, $00
	ld [wScreenEffectObjectPtr], a
	ld a, $D0
	ld [wScreenEffectObjectPtr + 1], a
	ld a, $40
	ld [wScreenEffectObjectsRemaining], a
	call PreserveScreenEffectObjects
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $08
	ld [rROMB0], a
	ld hl, EffectPalette5502
	ld b, $03
	ld c, $01
	call LoadObjectPaletteRange
	pop af
	ld [rROMB0], a
	ld a, $01
	ld [wScreenEffectActive], a
	ld a, $4F
	ld [wSfxSeqLockId], a
	ld e, a
	call Audio_QueueSound
	pop hl
	pop de
	pop bc
	pop af
	ret


PreserveScreenEffectObjects:
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $01
	ld [rROMB0], a
	call FreeObjectsOutsideStatuses1And4
	pop af
	ld [rROMB0], a
	ret


ProcessNextScreenEffectObject:
	ld a, [wScreenEffectObjectsRemaining]
	or a
	jr z, Jump_3DD7
	ld d, a
	ld a, [wScreenEffectObjectPtr]
	ld l, a
	ld a, [wScreenEffectObjectPtr + 1]
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
	ld [wScreenEffectObjectsRemaining], a
	ret

Jump_3DBC:
	ld a, d
	ld [wScreenEffectObjectsRemaining], a
	ld a, e
	ld [wScreenEffectObjectPtr], a
	ld a, h
	ld [wScreenEffectObjectPtr + 1], a
	ld l, e
	call GetObjectScoreValue
	call AddToScore
	ld l, e
	ld a, $01
	ld b, $01
	call RemoveObject
Jump_3DD7:
	ret


LoadScreenEffectPart:
	ld a, $05
	ld [rROMB0], a
	ld a, [wScreenEffectStepTable]
	add a, b
	ld l, a
	ld a, [wScreenEffectStepTable + 1]
	adc a, $00
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, h
	or a
	ret z
	ld a, [hli]
	ld [wScreenEffectPartTileCount], a
	ld a, [hli]
	ld [wScreenEffectPartTiles], a
	ld a, [hli]
	ld [wScreenEffectPartTiles + 1], a
	ld a, [hli]
	ld [wScreenEffectPartOam], a
	ld a, [hl]
	ld [wScreenEffectPartOam + 1], a
	xor a
	inc a
	ret


RenderScreenEffect:
	ld a, [wScreenEffectCountdown]
	cp $03
	ret c
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $08
	ld [rROMB0], a
	ld b, $00
	ld c, SCREEN_EFFECT_PART_COUNT
Jump_3E18:
	call LoadScreenEffectPart
	jr z, Jump_3E32
	push bc
	ld a, [wScreenEffectPartTileCount]
	call AllocateDynamicSpriteTiles
	cp $FF
	jr z, Jump_3E31
	ld [wScreenEffectPartFirstTile], a
	call CopyScreenEffectPartTiles
	call BuildScreenEffectPartOam
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


CopyScreenEffectPartTiles:
	ld a, [wScreenEffectPartTiles]
	ld l, a
	ld a, [wScreenEffectPartTiles + 1]
	ld h, a
	ld a, $08
	ld [rROMB0], a
	ld a, [wScreenEffectPartTileCount]
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


BuildScreenEffectPartOam:
	ld a, [wScreenEffectPartOam]
	ld l, a
	ld a, [wScreenEffectPartOam + 1]
	ld h, a
	ld a, $05
	ld [rROMB0], a
	ld a, [wScreenEffectPartTileCount]
	ld c, a
Jump_3E92:
	call AllocateShadowOamFront
	ld a, [wScreenEffectY]
	ld b, a
	ld a, [hli]
	add a, b
	ld [de], a
	inc e
	ld a, [wScreenEffectX]
	ld b, a
	ld a, [hli]
	add a, b
	ld [de], a
	inc e
	ld a, [wScreenEffectPartFirstTile]
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


RandomlyBlankDisplay:
	call RandomByte
	and $03
	ret z
	call DisableLCDSafely
	ld b, $64
Jump_3EC4:
	ld c, $FF
Jump_3EC6:
	nop
	dec c
	jr nz, Jump_3EC6
	dec b
	jr nz, Jump_3EC4
	call EnableLCD
	ret


UpdateScreenEffect:
	ld a, [wScreenEffectCountdown]
	dec a
	ld [wScreenEffectCountdown], a
	or a
	jr z, Jump_3F00
	and $03
	jr nz, Jump_3EFF
	ld a, [wScreenEffectBlankCount]
	or a
	jr z, Jump_3EEC
	dec a
	ld [wScreenEffectBlankCount], a
	call RandomlyBlankDisplay
Jump_3EEC:
	ld a, [wScreenEffectStepTable]
	add a, $06
	ld [wScreenEffectStepTable], a
	ld a, [wScreenEffectStepTable + 1]
	adc a, $00
	ld [wScreenEffectStepTable + 1], a
	call ProcessNextScreenEffectObject
Jump_3EFF:
	ret

Jump_3F00:
	call ConvertVisibleLevelCellBit2Regions
	ld a, [ROM_BANK_MARKER]
	push af
	ld a, $08
	ld [rROMB0], a
	ld hl, Bank08ObjectPalette46EA
	ld b, $03
	ld c, $01
	call LoadObjectPaletteRange
	pop af
	ld [rROMB0], a
	xor a
	ld [wScreenEffectActive], a
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
