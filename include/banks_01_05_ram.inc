; RAM symbols used by banks $01-$05 (docs/research/banks_01_05/MEMORY_SYMBOLS.md).
; Included by src/bank_01.asm; guarded. Widths in bytes; multi-byte values little-endian
; unless noted. HRAM $FF80-$FF8D, $FF97, $FFB0-$FFB1 are shared scratch and stay numeric.
IF !DEF(BANKS_01_05_RAM_INC)
DEF BANKS_01_05_RAM_INC EQU 1
DEF wGamePaused                      EQU $C6C1 ; 1 byte(s)
DEF wGameStartMode                   EQU $C6CD ; 1 byte(s)
DEF wActiveSkillLevel                EQU $C6CF ; 1 byte(s)
DEF wBonusPickupCount                EQU $C6EF ; 1 byte(s)
DEF wPowerupType3PickupCount         EQU $C6F0 ; 1 byte(s)
DEF wBgPalette6To7Shadow             EQU $C719 ; 16 byte(s)
DEF wNearestTargetScanPtr            EQU $C8D4 ; 2 byte(s)
DEF wNearestTargetPtr                EQU $C8D6 ; 2 byte(s)
DEF wNearestTargetDistance           EQU $C8D8 ; 2 byte(s)
DEF wNearestTargetScanIndex          EQU $C8DA ; 1 byte(s)
DEF wNearestTargetScanJump           EQU $C8DB ; 4 byte(s)
DEF wC8E6                            EQU $C8E6 ; 1 byte(s)
DEF wAlertObjectTypePtr              EQU $C91E ; 2 byte(s)
DEF wMenuScrollStep                  EQU $C924 ; 1 byte(s)
DEF wCommittedMusicSetting           EQU $C92E ; 1 byte(s)
DEF wCommittedControlSetting         EQU $C92F ; 1 byte(s)
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
DEF wPlayerSpawnHealthPenalty        EQU $CD1A ; 1 byte(s)
DEF wLevelObjectSkillScratch         EQU $CD22 ; 1 byte(s)
DEF wLevelObjectRecordIndex          EQU $CD23 ; 1 byte(s)
DEF wLevelObjectRespawnsLeft         EQU $CD24 ; 1 byte(s)
DEF wPendingSpawnOutsideView         EQU $CD25 ; 1 byte(s)
DEF wObjectSequenceThrottleCounter   EQU $CD28 ; 1 byte(s)
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
DEF wRecordedPath                    EQU $CDEF ; $200; 64 x 8: X word, Y word, heading, 3 unused
DEF hScenePaletteBuildIndex          EQU $FFA8 ; 1
DEF hSceneRasterFxEnabled            EQU $FFAC ; 1
DEF hSceneWaitCountdown              EQU $FFAD ; 1
DEF hScenePaletteFadeOffset          EQU $FFAE ; 1
DEF hScoreDigitsStarted              EQU $FFB8 ; 1
DEF hPasswordLevelNumber             EQU $FFC6 ; 1
ENDC
