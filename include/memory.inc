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


; Sound driver state (see AUDIO_RESEARCH.md). Written by Audio_Init
; ($06:$7CAE) and used by the driver in bank $06 and ROM0:$2ED5-$2F92.
; Not named because no behavior is established: $C8E3 (non-zero blocks
; music note-on; only ever cleared), $C8E4 and $C8F6 (written, never read).
DEF wMusicDelay      EQU $C8E7 ; frames until the next music event
DEF wMusicPtr        EQU $C8E8 ; 2 bytes, high byte first; 0 high = no music
DEF wMusicLoopPtr    EQU $C8EA ; 2 bytes, high byte first
DEF wChannelSettings EQU $C8EC ; 4 x (instrument, NR51 bit pattern)
DEF wMusicBank       EQU $C8F4 ; ROM bank holding the current music sequence
DEF wNotePan         EQU $C8F5 ; scratch: NR51 bit pattern for the note being started
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
DEF wScreenWidth          EQU $C6DC ; descriptor +10, BG map width read by ROM0 $05C5
DEF wScreenHeight         EQU $C6DD ; descriptor +11, BG map height read by ROM0 $05C5

; Encoded text cursor used by the options menu text renderer.
DEF wTextColumn EQU $C8DF
DEF wTextRow    EQU $C8E0
