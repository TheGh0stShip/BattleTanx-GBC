; Evidence-based BattleTanx memory symbols.

; Every populated switchable ROM bank stores its bank number in its last byte.
; Banked-call helpers read this marker before changing the MBC5 bank register.
DEF ROM_BANK_MARKER EQU $7FFF

; Set to 1 by the installed VBlank handler and cleared by frame-wait loops.
DEF wVBlankPending EQU $C6C0

; Boot register A is preserved here before work memory is initialized.  CGB
; hardware reports $11; RequireCgbHardware rejects every other value.
DEF wBootHardwareMode EQU $C000

; Scroll values staged for the next frame's SCX/SCY write, plus the 16-bit
; gameplay frame counter incremented once per main-loop iteration.
DEF wPendingScrollX EQU $C6B0
DEF wPendingScrollY EQU $C6B1
DEF wFrameCounter   EQU $C6B9 ; 2-byte little-endian counter
DEF wJoypadHeld     EQU $C6B5
DEF wJoypadPressed  EQU $C6B6 ; rising edges: (previous XOR held) AND held
DEF wVBlankCounter  EQU $C6B7 ; 2-byte little-endian interrupt counter
; Toggled by Start.  While set, the gameplay callback is suppressed and the
; bank-$01 pause loop hides the HUD, waits for Start, then restores it.
DEF wPauseActive    EQU $C6C1

; Level termination state. Completion checks and the player-destruction path
; start the shared countdown; UpdateLevelEndCountdown reports expiry in carry.
DEF wLevelEndCountdown EQU $C6EB ; 2-byte little-endian frame count
DEF wLevelComplete     EQU $C6CE
DEF wPlayerAlive       EQU $CD09

; Four-byte little-endian score and the index of the last reached entry in
; the bank-$01 threshold table.
DEF wScore               EQU $CD04 ; 32-bit little-endian accumulator
DEF wScoreThresholdIndex EQU $C6D0

; Player state. SpawnPlayerObject creates the selected object type and stores
; its 64-byte object-record pointer here. Lives are clamped to 0..9.
DEF wPlayerObject     EQU $CD00 ; 2-byte pointer
DEF wPlayerLives      EQU $CD02
DEF wPlayerHealthRecoveryTicks EQU $CD03 ; decremented every other VBlank
DEF wPlayerObjectType EQU $CD08
DEF wPlayerSpawnX     EQU $CD0B ; 2-byte little-endian pixel coordinate
DEF wPlayerSpawnY     EQU $CD0D ; 2-byte little-endian pixel coordinate
DEF wPlayerSpawnDirection EQU $CD1B ; low seven bits from level record

; HUD state. The power-up renderer copies one eight-byte CGB palette here for
; the scanline palette uploader. The alert flag blinks a four-tile indicator.
DEF wHudPowerupPalette EQU $C6F1 ; 8-byte CGB palette
DEF wBackgroundPalette6 EQU $C719 ; 8-byte palette preserved for VBlank upload
DEF wHudAlertActive    EQU $C91D

; Per-frame sprite construction. Shadow OAM is allocated from both ends; when
; exhausted, writers receive the four-byte discard entry immediately after it.
DEF wDynamicSpriteTiles        EQU $C100
DEF wShadowOam                 EQU $C600 ; 40 four-byte entries
DEF wDiscardedOamEntry         EQU $C6A0
DEF wShadowOamFreeCount        EQU $C6C2
DEF wShadowOamFrontPtr         EQU $C6C3 ; 2-byte pointer
DEF wShadowOamBackPtr          EQU $C6C5 ; 2-byte pointer
DEF wDynamicSpriteTileCount    EQU $C6C7
DEF wDynamicSpriteTileWritePtr EQU $C6C8 ; 2-byte pointer
DEF SHADOW_OAM_ENTRY_COUNT     EQU 40
DEF DYNAMIC_SPRITE_TRANSFER_TILE_COUNT EQU 40
DEF DYNAMIC_SPRITE_TILE_REJECT_AT EQU 49

; Seventy-five-frame screen effect.  Three bank-$05 part records select
; bank-$08 tiles and OAM templates for each step.  The update also walks the
; object pool and converts visible level-cell bit-2 regions when it expires.
DEF wScreenEffectActive           EQU $C0FF
DEF wScreenEffectX                EQU $C957
DEF wScreenEffectY                EQU $C958
DEF wScreenEffectCountdown        EQU $C959
DEF wScreenEffectTopY             EQU $C95A
DEF wScreenEffectBottomY          EQU $C95B
DEF wScreenEffectBlankCount       EQU $C95C
DEF wScreenEffectStepTable        EQU $C95D ; 2-byte pointer into bank $05
DEF wScreenEffectPartTileCount    EQU $C95F
DEF wScreenEffectPartTiles        EQU $C960 ; 2-byte bank-$08 pointer
DEF wScreenEffectPartOam          EQU $C962 ; 2-byte bank-$05 pointer
DEF wScreenEffectPartFirstTile    EQU $C964
DEF wScreenEffectObjectPtr        EQU $C965 ; 2-byte object-pool pointer
DEF wScreenEffectObjectsRemaining EQU $C967
DEF SCREEN_EFFECT_DURATION         EQU 75
DEF SCREEN_EFFECT_BLANK_COUNT      EQU 30
DEF SCREEN_EFFECT_PART_COUNT       EQU 3

; Sixty-four 64-byte runtime object records.
DEF wObjectPool EQU $D000

; Little-endian callback selected from RuntimeCallbackTable and dispatched by
; the indirect jump at ROM0:$364D.
DEF wRuntimeCallback EQU $C6BE

; Options-menu values. The table at ROMX:$48C0 associates these addresses with
; the visible MUSIC, CONTROL, and SKILL labels.
DEF wMusicEnabled   EQU $C6BB
DEF wMusicSetting   EQU $D55B
DEF wControlSetting EQU $D55C
DEF wSkillSetting   EQU $D55D

; Menu/flow state. The state pointers address the five-byte headers followed
; by their fixed-size choice records in bank 1. The input loop compares the
; requested state with the last rendered state before rebuilding the screen.
DEF wMenuState                EQU $D557 ; 2-byte pointer
DEF wMenuRenderedState        EQU $D559 ; 2-byte pointer
DEF wMenuActive               EQU $D55E
DEF wMenuPreviousButtons      EQU $D55F
DEF wMenuRepeatTimer          EQU $D560
DEF wMenuScrollDirection      EQU $D563 ; 0 idle, 1 right, 2 left
DEF wMenuState05Selection     EQU $D566 ; wraps through 0..2
DEF wMenuGridColumn           EQU $D567 ; wraps through 0..2
DEF wMenuGridRow              EQU $D568 ; wraps through 0..4
DEF wMenuCursorSpritesEnabled EQU $D569

; Active fixed-background descriptor, copied from SceneBackgroundDescriptors.
DEF wFixedSceneGraphicsBank  EQU $D3E0
DEF wFixedSceneGraphics      EQU $D3E1
DEF wFixedSceneTilemap       EQU $D3E3
DEF wFixedSceneAttributes    EQU $D3E5
DEF wFixedScenePalettes      EQU $D3E7
DEF wFixedScenePaletteCount  EQU $D3E9

; Active scrolling-scene descriptor, copied from ScrollingSceneDescriptors.
DEF wScrollingSceneBank      EQU $D3F0
DEF wScrollingSceneGraphics  EQU $D3F1
DEF wScrollingSceneRows      EQU $D3F3
DEF wScrollingSceneLastRow   EQU $D3F5
DEF wScrollingScenePalette   EQU $D3F6

; Active level record and derived lookup state. LoadLevelRecord copies the
; bank and pointer fields from the selected 20-byte bank-$05 record.
DEF wLevelTileBank             EQU $C8B9
DEF wLevelPaletteBank          EQU $C8BA
DEF wLevelCellMapBank          EQU $C8BB
DEF wLevelMapBank              EQU $C8BC
DEF wLevelAttributeMapBank     EQU $C8BD ; written by LoadLevelRecord, never read
DEF wLevelLastTileIndex        EQU $C8BE ; 2 bytes LE, written by LoadLevelRecord, never read
DEF wLevelPaletteCount         EQU $C8C0
DEF wLevelTiles                EQU $C8C1 ; 2-byte pointer
DEF wLevelPalettes             EQU $C8C3 ; 2-byte pointer
DEF wLevelAttributeMap         EQU $C8C5 ; 2-byte pointer
DEF wLevelTileMap              EQU $C8C7 ; 2-byte pointer
DEF wLevelCellMap              EQU $C8C9 ; 2-byte pointer
DEF wLevelAnimationFrame       EQU $C8CB
DEF wLevelTileAnimationTable   EQU $C8CE ; 2-byte pointer
DEF wLevelAttributeLookup      EQU $C8D0 ; 2-byte pointer
DEF wLevelAttributeLookupBank  EQU $C8D2
DEF wLevelAnimatedCellAttribute EQU $C8D3 ; selected by level for cell-map bit 6

; Camera position in level-space pixels. The scroll bytes are written to
; SCX/SCY and may wrap while the 16-bit camera coordinates do not.
DEF wLevelCameraX              EQU $CA00 ; 2-byte little-endian position
DEF wLevelCameraY              EQU $CA02 ; 2-byte little-endian position
DEF wLevelScrollX              EQU $CA04
DEF wLevelScrollY              EQU $CA05
DEF wLevelNumber               EQU $CA06
DEF wLevelWidth                EQU $CA09
DEF wLevelHeight               EQU $CA0A
DEF wLevelPixelWidth           EQU $CA0B ; 2-byte width multiplied by 8
DEF wLevelPixelHeight          EQU $CA0D ; 2-byte height multiplied by 8
DEF wLevelViewY                EQU $CA0F
DEF wLevelViewX                EQU $CA10
DEF wLevelViewRowOffset        EQU $CA11 ; 2-byte view Y multiplied by width
DEF wLevelRingY                EQU $CA13
DEF wLevelRingX                EQU $CA14
DEF wLevelRingRowOffset        EQU $CA15 ; 2-byte ring Y multiplied by 32
DEF wLevelRowOffsets           EQU $CA17 ; little-endian offset per row

; Active bank-$03 object-sequence table for the current level.
DEF wLevelObjectSequenceTable  EQU $CD1C ; 2-byte pointer to 64 sequence slots

; Active bank-$04 level-object tables and delayed-spawn state. The pending
; queue has 20 three-byte entries: object index, countdown, and record byte +9.
DEF wLevelObjectSpawnTable      EQU $CD1E ; 2-byte pointer, 40 x 12-byte records
DEF wLevelObjectAuxTable        EQU $CD20 ; 2-byte pointer, 8 x 8-byte records
DEF wObjectSlowTickCounter      EQU $CD27 ; wraps every 75 update calls
DEF wPendingLevelObjectQueue    EQU $CD33 ; 20 x 3-byte entries, $FF = unused
DEF wLevelObjectAuxState        EQU $CD6F ; 8 x 10-byte runtime records
DEF PENDING_LEVEL_OBJECT_COUNT  EQU 20
DEF PENDING_LEVEL_OBJECT_SIZE   EQU 3
DEF OBJECT_SLOW_TICK_PERIOD     EQU 75
DEF LEVEL_OBJECT_AUX_COUNT      EQU 8
DEF LEVEL_OBJECT_AUX_STATE_SIZE EQU 10

; Shared HRAM scratch while processing a rectangular cell-map region.
DEF hLevelRegionLeft           EQU $FF90
DEF hLevelRegionRight          EQU $FF91
DEF hLevelRegionTop            EQU $FF92
DEF hLevelRegionBottom         EQU $FF93
DEF hLevelRegionY              EQU $FF94
DEF hLevelRegionX              EQU $FF95
DEF hLevelRegionRetryCount     EQU $FF9C
DEF hLevelRegionChangedCount   EQU $FF9D
DEF hLevelRegionScore          EQU $FF9E ; 2-byte little-endian accumulator

; DrawLevelViewport loop state (time-shared).
DEF hViewportCellsLeft         EQU $FF90 ; cells left in the current row, from $14 (time-shared)
DEF hViewportRowsLeft          EQU $FF91 ; rows left, from $12 (time-shared)
DEF hViewportMapColumn         EQU $FF92 ; first map column, from wLevelViewX (time-shared)
DEF hViewportMapRow            EQU $FF93 ; current map row, from wLevelViewY, +1 per row (time-shared)
DEF hViewportBgColumn          EQU $FF94 ; B for GetLevelBGMapAddress, always 0 (time-shared)
DEF hViewportBgRow             EQU $FF95 ; C for GetLevelBGMapAddress, +1 per row (time-shared)

; ConvertVisibleLevelCellBit2Regions scan bounds and cursor (time-shared).
DEF hBit2ScanLeft              EQU $FF96 ; wLevelViewX (time-shared)
DEF hBit2ScanRight             EQU $FF97 ; inclusive, clamped to wLevelWidth - 1 (time-shared)
DEF hBit2ScanTop               EQU $FF98 ; wLevelViewY (time-shared)
DEF hBit2ScanBottom            EQU $FF99 ; inclusive, clamped to wLevelHeight - 1 (time-shared)
DEF hBit2ScanRow               EQU $FF9A ; E for ConvertLevelCellBit2RegionAtCell (time-shared)
DEF hBit2ScanColumn            EQU $FF9B ; C for ConvertLevelCellBit2RegionAtCell (time-shared)

; DrawHudScore buffers (time-shared).
DEF hHudScoreBcd               EQU $FF90 ; 5 bytes packed BCD from LongToBcd40, most significant first (time-shared)
DEF hHudScoreDigitShown        EQU $FF98 ; nonzero once a nonzero digit is seen; ends zero suppression (time-shared)

; DrawLevelCellIfVisible saved input cell (time-shared).
DEF hDrawLevelCellX            EQU $FFA0 ; input C, passed back as B to WriteLevelCellToBGMap (time-shared)
DEF hDrawLevelCellY            EQU $FFA1 ; input E, passed back as C to WriteLevelCellToBGMap (time-shared)

; CopyScreenMaps destination row stride remainder (time-shared).
DEF hScreenMapRowSkip          EQU $FFC0 ; $20 - wScreenWidth, added to HL after each row (time-shared)

; Bank $02 BuildBackgroundPaletteFadeFramesImpl loop state (time-shared).
DEF hFadeBuildSourceFrame      EQU $FFC0 ; Func_3A40 index read from, from $1F, -1 per frame (time-shared)
DEF hFadeBuildDestFrame        EQU $FFC1 ; Func_3A40 index written to, source - 1 (time-shared)
DEF hFadeBuildColoursLeft      EQU $FFC2 ; colours left in the frame, from $20 (time-shared)
DEF hFadeBuildFramesLeft       EQU $FFC3 ; frames left, from $1F (time-shared)

; Bank $02 DivideScoreByThousand work registers (time-shared).
DEF hScoreThousands            EQU $FFC0 ; 2-byte little-endian quotient, returned in BC (time-shared)
DEF hScoreRemainder            EQU $FFC2 ; 4-byte little-endian copy of wScore reduced by 1000s (time-shared)

; Bank $2A FixedScreen2A_DrawFrame 5x11 copy counters (time-shared).
DEF hFixedScreen2AColumnsLeft  EQU $FFC0 ; from 5 (time-shared)
DEF hFixedScreen2ARowsLeft     EQU $FFC1 ; from $0B (time-shared)

; RemoveObject saved inputs and removed-object fields (time-shared).
DEF hRemoveObjectSpawnFlag     EQU $FF80 ; input B; nonzero spawns a status-4 type-0 object (time-shared)
DEF hRemoveObjectEffectFlag    EQU $FF81 ; input A; nonzero plays sound $46 and spawns timed effect 0 (time-shared)
DEF hRemoveObjectType          EQU $FF82 ; object +OBJECT_TYPE_OFFSET; 3 redraws the 2x3 footprint (time-shared)
DEF hRemoveObjectX             EQU $FF83 ; 2-byte little-endian object +$01 pixel X (time-shared)
DEF hRemoveObjectY             EQU $FF85 ; 2-byte little-endian object +$04 pixel Y (time-shared)

; RenderObjectOrientationGraphic and its WriteObjectOrientationOam,
; CopyObjectOrientationTiles and SelectObjectOrientationPalette helpers (time-shared).
DEF hOrientVariant             EQU $FF80 ; object type 0-3; tile bank $27 + value, palette offset; 3 = metatile (time-shared)
DEF hOrientDirection           EQU $FF81 ; object direction; orientation layout/tile/metatile index (time-shared)
DEF hOrientScreenX             EQU $FF82 ; object screen X, added to OAM X (time-shared)
DEF hOrientScreenY             EQU $FF83 ; object screen Y, added to OAM Y (time-shared)
DEF hOrientTileBase            EQU $FF84 ; AllocateDynamicSpriteTiles result, added to OAM tile (time-shared)
DEF hOrientPalette             EQU $FF85 ; hOrientVariant + 0, added to OAM attributes (time-shared)
DEF hOrientCellX               EQU $FF86 ; object pixel X / 8 (low byte) (time-shared)
DEF hOrientCellY               EQU $FF87 ; object pixel Y / 8 (low byte) (time-shared)
DEF hOrientBgMapPointer        EQU $FF88 ; 2-byte little-endian BG map address, +$20 per metatile row (time-shared)
DEF hOrientMetatilePointer     EQU $FF8A ; 2-byte little-endian InterfaceMetatiles entry cursor (time-shared)
DEF hOrientMetatileRowsLeft    EQU $FF8C ; metatile rows left, from 3 (time-shared)

; CenterLevelViewOnObject clamped view origin in cells (time-shared).
DEF hCenterViewX               EQU $FF80 ; 2-byte little-endian, X/8 - $0B clamped to 0..wLevelWidth - $15 (time-shared)
DEF hCenterViewY               EQU $FF82 ; 2-byte little-endian, Y/8 - $0A clamped to 0..wLevelHeight - $13 (time-shared)

; GetLevelCellTileAndAttr cell index (time-shared).
DEF hLevelCellIndex            EQU $FF80 ; 2-byte little-endian wLevelRowOffsets[C] + B (time-shared)

; LoadVehicleForwardVelocity / LoadVehicleReverseVelocity table selectors (time-shared).
DEF hVelocitySpeedIndex        EQU $FF80 ; vehicle speed - 1; selects a $80-byte ObjectVelocityTable block (time-shared)
DEF hVelocityDirection         EQU $FF81 ; direction (reverse: +8 mod 16); selects an 8-byte entry (time-shared)

; HandleObjectLevelBit1And2Cells subtype-1 rollback flag (time-shared).
DEF hProjectileAxisRolledBack  EQU $FF80 ; set to 1 when either axis was rolled back (time-shared)

; ResolveProjectileHit scan state (time-shared).
DEF hHitScanObjectsLeft        EQU $FFA0 ; object records left to scan, from $40 (time-shared)
DEF hHitProjectilePowered      EQU $FFA1 ; projectile +OBJECT_PROJECTILE_POWERED_OFFSET; nonzero doubles damage (time-shared)

; GetDirectionTowardObject octant bits (time-shared).
DEF hDirectionOctant           EQU $FF90 ; bit 0: dX negative, bit 1: dY negative; OctantDirectionValues index (time-shared)

; FindNearestVisibleObjectFacingSource / InitializeHomingProjectileTarget (time-shared).
DEF hFacingBestObject          EQU $FF80 ; 2-byte little-endian best object pointer, returned to the caller (time-shared)
DEF hFacingBestDistance        EQU $FF82 ; 2-byte little-endian best half-Manhattan distance, from $FFFF (time-shared)
DEF hFacingBestDirectionDiff   EQU $FF84 ; absolute direction difference of the best object; never read (time-shared)
DEF hFacingObjectsLeft         EQU $FF85 ; object records left to scan, from $40 (time-shared)
DEF hFacingFound               EQU $FF86 ; 1 once an object qualifies (time-shared)
DEF hFacingCandidateDistance   EQU $FF87 ; 2-byte little-endian candidate half-Manhattan distance (time-shared)
DEF hFacingSourceDirection     EQU $FF89 ; source object direction (time-shared)
DEF hHomingInitArgs            EQU $FF8A ; 4 bytes: input L, H, C, B; written and never read (time-shared)

; RenderObjectSprite, BuildObjectOamEntries and LoadObjectAnimationTiles (time-shared).
DEF hSpriteType                EQU $FF80 ; object +OBJECT_TYPE_OFFSET; written and never read (time-shared)
DEF hSpriteScreenX             EQU $FF81 ; object +$06, added to OAM X (time-shared)
DEF hSpriteScreenY             EQU $FF82 ; object +$07, added to OAM Y (time-shared)
DEF hSpriteTileBase            EQU $FF84 ; AllocateDynamicSpriteTiles result, added to OAM tile (time-shared)
DEF hSpriteFrame               EQU $FF85 ; object +OBJECT_HEALTH_OR_AGE_OFFSET / 4, frame-table index (time-shared)
DEF hSpriteFrameTable          EQU $FF86 ; 2-byte little-endian bank-$02 frame pointer table (time-shared)
DEF hSpriteOamLayout           EQU $FF88 ; 2-byte little-endian bank-$02 OAM layout records (time-shared)
DEF hSpriteTileCount           EQU $FF8A ; tiles copied and OAM entries built (time-shared)

; Bank $08 SelectObjectSpritePalette -> bank $01 DrawObjectTypeMarkerSprite (time-shared).
DEF hStatus4SpritePalette      EQU $FF80 ; ObjectSpritePaletteIndexTable[type] & 3 + 4; OAM attribute low bits (time-shared)


; Sound driver state (see AUDIO_RESEARCH.md). Written by Audio_Init
; ($06:$7CAE) and used by the driver in bank $06 and ROM0:$2ED5-$2F92.
DEF wMusicNoteOnBlocked EQU $C8E3 ; nonzero suppresses music note-on; initialized only to zero
DEF wUnusedAudioStateC8E4 EQU $C8E4 ; initialized to zero, never read
DEF wMusicDelay      EQU $C8E7 ; frames until the next music event
DEF wMusicPtr        EQU $C8E8 ; 2 bytes, high byte first; 0 high = no music
DEF wMusicLoopPtr    EQU $C8EA ; 2 bytes, high byte first
DEF wChannelSettings EQU $C8EC ; 4 x (instrument, NR51 bit pattern)
DEF wMusicBank       EQU $C8F4 ; ROM bank holding the current music sequence
DEF wNotePan         EQU $C8F5 ; scratch: NR51 bit pattern for the note being started
DEF wUnusedChannel1PatchFlag EQU $C8F6 ; set to 1 by channel-1 patches, never read
DEF wNoiseLockTimer  EQU $C8F7 ; $37 after a channel-4 patch; music ch4 waits
DEF wSfxSeqPtr       EQU $C8F8 ; 2 bytes, little-endian; 0 high = idle
DEF wSfxSeqDelay     EQU $C8FA ; frames until the next sequence event
DEF wSoundQueueNext  EQU $C8FB ; next queue slot Audio_Update reads
DEF wSoundQueueLast  EQU $C8FC ; last queue slot Audio_QueueSound wrote
DEF wSoundQueue      EQU $C8FD ; 30-entry ring of sound ids, 0 = empty
DEF SOUND_QUEUE_SIZE EQU 30
DEF wSfxSeqLock      EQU $C91B ; non-zero: requests for ids $40-$7F are ignored
DEF wSfxSeqLockId    EQU $C91C ; id that sets wSfxSeqLock when started

; Full-screen picture state (banks $2A-$2E; see BANKS_2A_2E_RESEARCH.md).
DEF wRandomState          EQU $C6B2 ; 3-byte state mixed with DIV by RandomByte
DEF wPaletteFadeFromWhite EQU $C6D1 ; 0: fade steps darken (fade from black); else brighten
DEF wScreenDescriptor     EQU $C6D2 ; 14-byte copy of the current screen descriptor
DEF wScreenWidth          EQU $C6DC ; descriptor +10, CopyScreenMaps width
DEF wScreenHeight         EQU $C6DD ; descriptor +11, CopyScreenMaps height
DEF wSkipInitialMenuTransition EQU $C6E2 ; nonzero only for the first menu pass after boot

; Eight-byte entry copied from bank 1's ScreenModeTable before its banked
; initialization or drawing callback is dispatched.
DEF wScreenModeEntry  EQU $C6E3 ; bank, reserved, init, draw, reserved word
DEF wScreenModeBank   EQU wScreenModeEntry
DEF wScreenModeInit   EQU wScreenModeEntry + 2 ; 2-byte pointer
DEF wScreenModeDraw   EQU wScreenModeEntry + 4 ; 2-byte pointer
DEF SCREEN_MODE_ENTRY_SIZE EQU 8
DEF SCREEN_MODE_COUNT      EQU 13

; WRAM bank 2 holds 32 complete eight-palette frames for full-screen fades.
; The final frame is the target and frames 0-30 are generated intermediates.
DEF wBackgroundPaletteFadeFrames EQU $D000
DEF BACKGROUND_PALETTE_FRAME_SIZE EQU 64
DEF BACKGROUND_PALETTE_FRAME_COUNT EQU 32
DEF BACKGROUND_PALETTE_CACHE_SIZE EQU BACKGROUND_PALETTE_FRAME_SIZE * BACKGROUND_PALETTE_FRAME_COUNT
DEF wBackgroundPaletteFadeTarget EQU wBackgroundPaletteFadeFrames + BACKGROUND_PALETTE_FRAME_SIZE * (BACKGROUND_PALETTE_FRAME_COUNT - 1)

; Deferred BG-map writes. Records live in WRAM bank 4 and contain a 16-bit
; destination followed by one attribute byte and one tile byte.
DEF wBgMapWriteCount EQU $C940
DEF wBgMapWritePtr   EQU $C941 ; 2-byte pointer
DEF wBgMapWriteQueue EQU $D000 ; WRAM bank 4
DEF BG_MAP_WRITE_RECORD_SIZE EQU 4

; Encoded text cursor used by the options menu text renderer.
DEF wTextColumn EQU $C8DF
DEF wTextRow    EQU $C8E0

; ROM0-only state.
DEF wScoreAtLeast50000   EQU $CD0A ; boolean, written during level initialization
DEF wReturnToMenuCounter EQU $CD0F ; dormant gameplay return-to-menu counter
