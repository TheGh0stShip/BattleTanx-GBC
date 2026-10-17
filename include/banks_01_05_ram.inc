; RAM symbols used by banks $01-$05 (docs/research/banks_01_05/MEMORY_SYMBOLS.md).
; Included by src/bank_01.asm; guarded. Widths in bytes; multi-byte values little-endian
; unless noted. HRAM $FF80-$FF8D, $FF97, $FFB0-$FFB2 are time-shared scratch; bank $01 scene aliases below name their scene role only.
IF !DEF(BANKS_01_05_RAM_INC)
DEF BANKS_01_05_RAM_INC EQU 1
DEF hSceneWriteOnlyFlag              EQU $FFAB ; 1; write-only: set 0/1 by scene code, never read
DEF wBgCopyReloadCount               EQU $C94B ; 1; reload for wBgCopyColumnsLeft (CopyBankedTilemapRectToBG) or wBgCopyRowsLeft (CopyBankedTilemapRowsToBG)
DEF wMenuState05UnreadPtr            EQU $D564 ; 2, little-endian; write-only: always $DC03, never read
DEF wGamePaused                      EQU $C6C1 ; 1 byte(s)
DEF wGameStartMode                   EQU $C6CD ; 1 byte(s); GAME_START_* value
DEF GAME_START_NEW                   EQU 0 ; main-menu kind-$0F start
DEF GAME_START_LEVEL_SELECT          EQU 1 ; MenuState06 grid confirm
DEF GAME_START_PASSWORD              EQU 2 ; accepted password
DEF wActiveSkillLevel                EQU $C6CF ; 1 byte(s)
DEF wUnwrittenStatusDisplayValue0    EQU $C6ED ; displayed by DrawObjectStatusCountsToWindow; no direct writer
DEF wUnwrittenStatusDisplayValue1    EQU $C6EE ; displayed by DrawObjectStatusCountsToWindow; no direct writer
DEF wBonusPickupCount                EQU $C6EF ; 1 byte(s)
DEF wPowerupType3PickupCount         EQU $C6F0 ; 1 byte(s)
DEF wBgPalette6To7Shadow             EQU $C719 ; 16 byte(s)
DEF wNearestTargetScanPtr            EQU $C8D4 ; 2 byte(s)
DEF wNearestTargetPtr                EQU $C8D6 ; 2 byte(s)
DEF wNearestTargetDistance           EQU $C8D8 ; 2 byte(s)
DEF wNearestTargetScanIndex          EQU $C8DA ; 1 byte(s)
DEF wNearestTargetScanJump           EQU $C8DB ; 4 byte(s)
DEF wVestigialStateC8E6              EQU $C8E6 ; boot writes 1, burst screen writes 2; no later reader
DEF wAlertObjectTypePtr              EQU $C91E ; 2 byte(s)
DEF wMenuScrollStep                  EQU $C924 ; 1 byte(s)
DEF wUnusedCommittedMusicSetting     EQU $C92E ; written when leaving the menu; never read
DEF wUnusedCommittedControlSetting   EQU $C92F ; written when leaving the menu; never read
DEF wPasswordBits                    EQU $C931 ; 4 byte(s)
DEF wPasswordBitIndex                EQU $C935 ; 1 byte(s)
DEF wPasswordScoreThousands          EQU $C936 ; 2 byte(s)
DEF wPasswordLives                   EQU $C938 ; 1 byte(s)
DEF wPasswordLevel                   EQU $C939 ; 1 byte(s)
DEF wPasswordChecksum                EQU $C93A ; 1 byte(s)
DEF wPasswordChars                   EQU $C93B ; 5 byte(s)
DEF wBankedBgSourceBank              EQU $C943 ; 1 byte(s)
DEF wBankedBgSourcePtrs              EQU $C944 ; 4 byte(s)
DEF wBgCopyColumn                    EQU $C948 ; 1 byte(s)
DEF wBgCopyRow                       EQU $C949 ; 1 byte(s)
DEF wBgCopyWidth                     EQU $C94A ; 1 byte(s)
DEF wSceneTileAttrPtrs               EQU $C94F ; 4 byte(s)
DEF wSceneBank                       EQU $C953 ; 1 byte(s)
DEF wBgFillTileAttr                  EQU $C955 ; 2 byte(s)
DEF wBurstRandomIndex                EQU $C9E8 ; 1 byte(s)
DEF wBurstActiveObjectCount          EQU $C9E9 ; 1 byte(s)
DEF wBurstFrameCountdown             EQU $C9EA ; 1 byte(s)
DEF wBurstBlockAnimStep              EQU $C9EB ; 1 byte(s)
DEF wBurstBlockAnimTick              EQU $C9EC ; 1 byte(s)
DEF wBurstSpawnCooldown              EQU $C9ED ; 1 byte(s)
DEF wActiveFlag26ObjectCount         EQU $CA07 ; 1 byte(s)
DEF wVisibleStatus1ObjectCount       EQU $CA08 ; 1 byte(s)
DEF wLevelAuxTimerDivider            EQU $CD10 ; 1 byte(s)
DEF wLevelAuxTimerExpiredCount       EQU $CD11 ; 1 byte(s)
DEF wLevelAuxType3Pending            EQU $CD12 ; 1 byte(s)
DEF wLevelAuxType2AllReached         EQU $CD13 ; 1 byte(s)
DEF wLevelAuxType4Active             EQU $CD14 ; 1 byte(s)
DEF wLevelSpawnHealthPenalty         EQU $CD18 ; 1 byte(s)
DEF wLevelObjectRecordType           EQU $CD19 ; 1 byte(s)
DEF wUnusedPlayerSpawnHealthPenalty  EQU $CD1A ; written once; never read
DEF wLevelObjectSkillScratch         EQU $CD22 ; 1 byte(s)
DEF wLevelObjectRecordIndex          EQU $CD23 ; 1 byte(s)
DEF wLevelObjectRespawnsLeft         EQU $CD24 ; 1 byte(s)
DEF wPendingSpawnOutsideView         EQU $CD25 ; 1 byte(s)
DEF wObjectProximityThreshold        EQU $CD26 ; 1 byte(s); distance-box threshold, always $55
DEF wObjectSequenceThrottleCounter   EQU $CD28 ; 1 byte(s)
DEF wForceRecordedPathAppend         EQU $CD29 ; 1 byte(s); bypasses duplicate-waypoint check
DEF wSequenceObjectsInState2Count    EQU $CD2A ; 1 byte(s)
DEF wBurstShadowOam                  EQU $D000 ; 160 byte(s) ; WRAM bank 2 (SVBK=2)
DEF wBurstObjects                    EQU $D0A0 ; 320 byte(s) ; WRAM bank 2 (SVBK=2); overlaps wObjectPool in bank 1
DEF wScenePaletteFadeTable           EQU $D3F8 ; 32 byte(s)
DEF wMenuCursorChoice                EQU $D550 ; 1 byte(s)
DEF wMenuCursorY                     EQU $D553 ; 1 byte(s)
DEF wMenuCursorTargetY               EQU $D554 ; 1 byte(s)
DEF wMenuCursorMoving                EQU $D555 ; 1 byte(s)
DEF wMenuScanlineScrollEnabled       EQU $D556 ; 1 byte(s)
DEF wMenuScanlineScrollTable         EQU $D9FB ; 128 byte(s)
DEF wScrollingSceneColours           EQU $DC48 ; 8 byte(s)
DEF wPasswordEntryChars              EQU $DF00 ; 5 byte(s)
DEF wGlyphColumn                     EQU $DF05 ; 1 byte(s)
DEF wGlyphRow                        EQU $DF06 ; 1 byte(s)
DEF wPasswordSelectedChar            EQU $DF07 ; 1 byte(s)
DEF wPasswordCursorX                 EQU $DF09 ; 1 byte(s)
DEF wPasswordCursorTargetX           EQU $DF0A ; 1 byte(s)
DEF wPasswordCursorIndex             EQU $DF0B ; 1 byte(s)
DEF wPasswordCursorPaletteFrame      EQU $DF0C ; 1 byte(s)
DEF wGlyphTileBuffer                 EQU $DF0D ; 8 byte(s)
DEF hSceneLcdStepPending             EQU $FFA9 ; 1 byte(s)
DEF hSceneLcdStepIndex               EQU $FFAA ; 1 byte(s)
DEF hSceneLcdStepLimit               EQU $FFAF ; 1 byte(s)
DEF hSceneRowTileVramAddress         EQU $FFB3 ; 2 byte(s)
DEF hSceneTileSlot                   EQU $FFB5 ; 1 byte(s)
DEF hSceneRowHdmaPending             EQU $FFB6 ; 1 byte(s)
; added in the final banks $01/$03 pass (bank-local roles; see docs/research/banks_01_05/MEMORY_SYMBOLS.md)
DEF wVramDmaStagingBuffer            EQU $C400 ; $140; HDMA source for HUD rows and scene row tiles
DEF wBgCopyColumnsLeft               EQU $C94C ; 1
DEF wBgCopyRowsLeft                  EQU $C94D ; 1
DEF wBgRevealCounter                 EQU $C94E ; 1; step counter/row-column index for scroll, fill and rejection draws
DEF wRecordedPathWriteIndex          EQU $CD15 ; 1; 0-63
DEF wRecordedPathWrapCount           EQU $CD16 ; 1; written only
DEF wRecordedPathStarted             EQU $CD17 ; 1
DEF wRecordedPath                    EQU $CDEF ; $200; 64 x 8: X word, Y word, heading; +5-+7 never written (keep $FF fill), never read
DEF hScenePaletteBuildIndex          EQU $FFA8 ; 1
DEF hSceneRasterFxEnabled            EQU $FFAC ; 1
DEF hSceneWaitCountdown              EQU $FFAD ; 1
DEF hScenePaletteFadeOffset          EQU $FFAE ; 1
; Bank $01 scene roles; these HRAM bytes are time-shared with bank $00 hLevelRegion* scratch.
DEF hSceneRomBank                    EQU $FF92 ; 1, copied from wScrollingSceneBank; written to rROMB0 (time-shared with hLevelRegionTop)
DEF hSceneScrollStarted              EQU $FF95 ; 1 (time-shared with hLevelRegionX)
DEF hSceneScrollDelay                EQU $FF96 ; 1, VBlank countdown that sets hSceneScrollStarted at 0 (time-shared with hBit2ScanLeft)
DEF hSceneBankSwitchGuard            EQU $FF80 ; 1, nonzero skips SceneStatHandler and StepSceneWindowSplit while a ROM/resource bank is switched (time-shared)
DEF hSceneFixedIndex                 EQU $FF81 ; 1, SceneBackgroundDescriptors index read by CopyFixedSceneDescriptor (time-shared)
DEF hSceneScrollIndex                EQU $FF82 ; 1, ScrollingSceneDescriptors index read by CopyScrollingSceneDescriptor (time-shared)
DEF hSceneScrollEnded                EQU $FF84 ; 1, set to 1 by AdvanceSceneScroll when hSceneRow reaches hSceneLastRow (time-shared)
DEF hSceneWindowSplitCountdown       EQU $FF86 ; 1, VBlank countdown written to LYC; also WY and the STAT split line (time-shared)
DEF hSceneScrollY                    EQU $FF87 ; 1, copied to rSCY each scene VBlank (time-shared)
DEF hSceneDescriptorPointer          EQU $FF88 ; 2, little-endian address of wScrollingSceneBank (time-shared)
DEF hSceneLastRow                    EQU $FF8A ; 1, copied from wScrollingSceneLastRow (time-shared)
DEF hSceneRow                        EQU $FF8B ; 1, scrolling-scene row index used by ComputeSceneRowPointer (time-shared)
DEF hSceneRowPixelPhase              EQU $FF8C ; 1, pixels scrolled since the last row draw, 0-7 (time-shared)
DEF hSceneRowSourcePointer           EQU $FF8D ; 2, little-endian pointer into the current row's cell words (time-shared)
DEF hSceneScrollStep                 EQU $FF97 ; 1, pixels added to hSceneScrollY per AdvanceSceneScroll (time-shared)
DEF hSceneRowTileBase                EQU $FFB0 ; 1, first BG tile index written for the next row (time-shared)
DEF hSceneRowMapAddress              EQU $FFB1 ; 2, little-endian BG map address of the next row (time-shared)
DEF hScoreDigitsStarted              EQU $FFB8 ; 1
DEF hPasswordLevelNumber             EQU $FFC6 ; 1
DEF wUnusedC954                     EQU $C954 ; written only by the unreferenced UnusedWipeSceneIn* routines
; Bank $01 BCD helpers (time-shared).
DEF hBcdByteCounter                  EQU $FF80 ; 1, input bytes left in AddWordToBcd24 (2) and LongToBcd40 (4) (time-shared)

; DrawObjectStatusCountsToWindow counters and digit buffer (time-shared).
DEF hStatusCountBcd                  EQU $FF80 ; 2, ByteToBcd16 output; +1 holds the two digits drawn (time-shared)
DEF hStatusCountNonZero              EQU $FF83 ; 1, objects whose byte +$1D is nonzero (time-shared)
DEF hStatusCountStatus2              EQU $FF84 ; 1, objects whose byte +$1D is 2 (time-shared)
DEF hStatusCountStatus1              EQU $FF85 ; 1, objects whose byte +$1D is 1 (time-shared)

; Scene init/load write-only bytes (time-shared).
DEF hSceneInitWriteOnly              EQU $FF83 ; 1, set to 1 by InitSceneDisplay, never read by scene code (time-shared)
DEF hSceneWxCopy                     EQU $FF85 ; 1, write-only copy of values written to rWX ($B4, $07) (time-shared)

; Scene BG palette 7 buffers, 4 RGB555 colours each (time-shared).
DEF hScenePalette7BufferA            EQU $FF98 ; 8, read by WriteBgPalette7FromFF98; Func_3A68 target (time-shared)
DEF hScenePalette7BufferB            EQU $FFA0 ; 8, read by WriteBgPalette7FromFFA0 (time-shared)

ENDC
