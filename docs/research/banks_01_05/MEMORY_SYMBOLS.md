# RAM symbols (include/banks_01_05_ram.inc)

77 symbols, accepted after cross-checking every reader and writer in all banks.
Raw operands replaced: 455.

Rejected:
- `$C400` (main pass): used as HUD map buffers in bank `$00` and as scene staging in bank `$01`. Accepted in the final pass as `wVramDmaStagingBuffer`. In both banks the buffer is filled and then sent by HDMA (bank `$00` writes `$C4` as the HDMA source high byte), so one staging name fits; see below.
- `$D000`: already `wObjectPool`.
- HRAM `$FF80-$FF8D`, `$FF97`, `$FFB0-$FFB1`: shared scratch.
- `$CD23`/`$CD24`: different meanings in banks `$03` and `$04`.

Not symbolised: `$C729`/`$C7F1`, which are `LOAD` destinations for the swappable interrupt images.

| Address | Name | Width | Evidence |
| --- | --- | ---: | --- |
| `$C6C1` | `wGamePaused` | 1 | All 6 refs consistent: cleared bank_00:205, cpl-toggled 10056, tested 384/10054/10080 and bank_01:56. Not defined in include/. |
| `$C6CD` | `wGameStartMode` | 1 | 10 refs (bank_00 Func_3ABF/3B12/3B5A, bank_01 menu, bank_04:6133), all one menu/start-mode byte; no include/ name. |
| `$C6CF` | `wActiveSkillLevel` | 1 | Duplicate proposals (w01 wActiveSkill, w15 wActiveSkillLevel) describe the same byte; 6 refs consistent. Picked w15's name. |
| `$C6EF` | `wBonusPickupCount` | 1 | Both proposals give the same meaning (incremented by Func_01_4582, cleared by InitializeLevelObjects, compared in Level01/08StateCheck). Picked w01's name. |
| `$C6F0` | `wPowerupType3PickupCount` | 1 | w01 and w15 agree; Func_01_4615 ++, InitializeLevelObjects clears, Level09StateCheck reads. |
| `$C719` | `wBgPalette6To7Shadow` | 16 | Name changed: the proposed 'wVBlankBgPalette3' has the wrong palette index. bank_00:1550 LoadInterfacePalettes reads palette 6 back from BCPD ($B0 = auto-increm |
| `$C8D4` | `wNearestTargetScanPtr` | 2 | w05 and w15 agree on the meaning; only bank_02 nearest-target scan code uses it, as a 16-bit value (40C7, 4D6A, 4E0E, 4E9F). Picked w15's name. |
| `$C8D6` | `wNearestTargetPtr` | 2 | 3 proposals, same meaning. Used by the bank_02 scan; cleared by bank_00 Func_0A23 (1631). Consistent. |
| `$C8D8` | `wNearestTargetDistance` | 2 | Used as 16-bit in bank_02:1002-1013. The other refs (bank_00 Jump_01B4:222, Jump_09F1:1615, bank_01:963) only clear it on reset. Consistent. |
| `$C8DA` | `wNearestTargetScanIndex` | 1 | Only bank_02 scan loops use it. Consistent. |
| `$C8DB` | `wNearestTargetScanJump` | 4 | Width is 4, not 3: bank_02:65-73 writes C3 lo hi C9 (jp nn; ret), and bank_02:901 does jp $C8DB. |
| `$C8E6` | `wC8E6` | 1 | Neutral name kept. Audio_InitFar sets it to 1 if 0 (bank_00:8608) and Func_02_626D sets it to 2 (bank_02:1688). No reader found that shows what it means. |
| `$C91E` | `wAlertObjectTypePtr` | 2 | w01 and w15 agree: bank_01:975 stores a pointer to object field +$1E after incrementing it; Func_0A23 decrements through it and clears it. Picked w15's name. Ne |
| `$C924` | `wMenuScrollStep` | 1 | 8 refs, all in the bank_01 menu scroll code. Consistent. |
| `$C92E` | `wCommittedMusicSetting` | 1 | Only ref is a write at bank_01:1473 (RAM_D62E); no reader found. The name comes from the source value only. Medium confidence. |
| `$C92F` | `wCommittedControlSetting` | 1 | Only ref is a write at bank_01:1475; no reader found. Medium confidence. |
| `$C931` | `wPasswordBits` | 4 | w04 and w15 agree; all 4 bytes used only by the password routines 6B35-6DF0. |
| `$C935` | `wPasswordBitIndex` | 1 | Same meaning in both proposals; only the bank_01 password bit routines use it. |
| `$C936` | `wPasswordScoreThousands` | 2 | 16-bit field decoded from the password and applied at Jump_01_5164 (score). Picked w04's more specific name. |
| `$C938` | `wPasswordLives` | 1 | w04 and w15 agree. |
| `$C939` | `wPasswordLevel` | 1 | Same meaning; picked w04's name. |
| `$C93A` | `wPasswordChecksum` | 1 | w04 and w15 agree. |
| `$C93B` | `wPasswordChars` | 5 | w04 and w15 agree; base-addressed refs only. |
| `$C943` | `wBankedBgSourceBank` | 1 | 10 refs, all in the banked BG copy path (bank_00 Func_3C90, bank_01 7981-7CEF). Consistent. |
| `$C944` | `wBankedBgSourcePtrs` | 4 | Two 16-bit pointers written by Func_01_7AA3 (bank_01:7176-7187) and read by RAM_D91B. |
| `$C948` | `wBgCopyColumn` | 1 | Consistent within the BG copy routines. |
| `$C949` | `wBgCopyRow` | 1 | Consistent. |
| `$C94A` | `wBgCopyWidth` | 1 | Consistent. |
| `$C94F` | `wSceneTileAttrPtrs` | 4 | Every byte accessed by the same 4 sites (Func_3C90, RAM_D7CB, 7BF3, 7C52). |
| `$C953` | `wSceneBank` | 1 | Written by RAM_D7CB and read by the bank_01 BG copy routines. |
| `$C955` | `wBgFillTileAttr` | 2 | 2 sites (Func_3C90, Jump_01_790E). Consistent. |
| `$C9E8` | `wBurstRandomIndex` | 1 | Only Func_02_66C0 uses it (bank_02:2459-2461), as the index into the $614F random table. Picked w07's name. |
| `$C9E9` | `wBurstActiveObjectCount` | 1 | 15 refs, all in the bank_02 burst routines. |
| `$C9EA` | `wBurstFrameCountdown` | 1 | Burst code only. |
| `$C9EB` | `wBurstBlockAnimStep` | 1 | Burst code only. Func_02_63F4 uses it as the grid index ($5E20 + n*16, ends at 6). |
| `$C9EC` | `wBurstBlockAnimTick` | 1 | Burst code only. |
| `$C9ED` | `wBurstSpawnCooldown` | 1 | Burst code only. |
| `$CA07` | `wActiveFlag26ObjectCount` | 1 | Counted in bank_00 Func_22ED and read in bank_03. Consistent. Medium confidence. |
| `$CA08` | `wVisibleStatus1ObjectCount` | 1 | Counted in Func_22ED and read in Func_02_4D58. Medium confidence. |
| `$CD10` | `wLevelAuxTimerDivider` | 1 | Only Func_03_6391 and InitializeLevelObjects use it. |
| `$CD11` | `wLevelAuxTimerExpiredCount` | 1 | Consistent. |
| `$CD12` | `wLevelAuxType3Pending` | 1 | 11 refs: level state checks plus the aux timer. Consistent. |
| `$CD13` | `wLevelAuxType2AllReached` | 1 | Consistent. |
| `$CD14` | `wLevelAuxType4Active` | 1 | Consistent. |
| `$CD18` | `wLevelSpawnHealthPenalty` | 1 | Same meaning in both proposals; only bank_04 level spawn code uses it. Picked a name that matches the $CD1A naming. |
| `$CD19` | `wLevelObjectRecordType` | 1 | 17 refs, all in bank_04 level-object spawning. Picked w10's name. |
| `$CD1A` | `wPlayerSpawnHealthPenalty` | 1 | One write only (bank_04:187); no reader. Medium confidence. |
| `$CD22` | `wLevelObjectSkillScratch` | 1 | Only bank_04 Func_04_62A7/62F7 code uses it. Scratch-like, but used in one place. |
| `$CD23` | `wLevelObjectRecordIndex` | 1 | Only bank_03/04 level-object code uses it. |
| `$CD24` | `wLevelObjectRespawnsLeft` | 1 | Consistent. |
| `$CD25` | `wPendingSpawnOutsideView` | 1 | Same meaning in both proposals; only TrySpawnPendingLevelObject uses it. |
| `$CD28` | `wObjectSequenceThrottleCounter` | 1 | Address was given without '$' in the input. Uses: Jump_03_5CED and InitializeLevelObjects. |
| `$CD2A` | `wSequenceObjectsInState2Count` | 1 | Address was given without '$' in the input. Counted in Func_03_5CD0 and read in the level checks. |
| `$D0A0` | `wBurstObjects` | 320 | Only bank_02 burst code refs it, with rSVBK=2 (Func_02_626D). Caveat: in WRAM bank 1 this address lies inside wObjectPool, so the comment must state WRAM bank 2 |
| `$D3F8` | `wScenePaletteFadeTable` | 32 | Only bank_01 scene code uses it (RAM_D273, RAM_D2C0, 6180, 61F9). No overlap with wScrollingScenePalette at $D3F6 if that field is 2 bytes. |
| `$D550` | `wMenuCursorChoice` | 1 | 11 refs, all in the bank_01 menu. |
| `$D553` | `wMenuCursorY` | 1 | w01 and w02 agree. |
| `$D554` | `wMenuCursorTargetY` | 1 | Consistent. |
| `$D555` | `wMenuCursorMoving` | 1 | Set while the cursor animates; the input handler is skipped when it is set. Picked w02's more specific name. |
| `$D556` | `wMenuScanlineScrollEnabled` | 1 | Consistent in the bank_01 menu and STAT RAM code. |
| `$D9FB` | `wMenuScanlineScrollTable` | 128 | Only the bank_01 menu STAT/VBlank RAM code uses it. |
| `$DC48` | `wScrollingSceneColours` | 8 | Only bank_01 scene palette code uses it. |
| `$DF00` | `wPasswordEntryChars` | 5 | 3 proposals; picked the w04/w15 name. The code-entry routines (50C4-510C) and the password screen routines (66F6-6A8A) share this buffer for the same 5-characte |
| `$DF05` | `wGlyphColumn` | 1 | Only the bank_01 glyph renderer uses it. |
| `$DF06` | `wGlyphRow` | 1 | Consistent. |
| `$DF07` | `wPasswordSelectedChar` | 1 | Picked w04's name. w02's code-entry refs (50C4-50DF) use it the same way. |
| `$DF09` | `wPasswordCursorX` | 1 | Consistent. |
| `$DF0A` | `wPasswordCursorTargetX` | 1 | Consistent. |
| `$DF0B` | `wPasswordCursorIndex` | 1 | Picked w04's name. w02's refs use it as the same cursor position. |
| `$DF0C` | `wPasswordCursorPaletteFrame` | 1 | Cursor palette cycle index into $77E4, 0..$0D (Func_01_6762). |
| `$DF0D` | `wGlyphTileBuffer` | 8 | Only the glyph renderer uses it. |
| `$FFA9` | `hSceneLcdStepPending` | 1 | Only bank_01 scene code and its STAT RAM handlers use it. No reuse found. |
| `$FFAA` | `hSceneLcdStepIndex` | 1 | Only the bank_01 scene STAT RAM code uses it. |
| `$FFAF` | `hSceneLcdStepLimit` | 1 | Only bank_01 scene code uses it. |
| `$FFB3` | `hSceneRowTileVramAddress` | 2 | Only Func_01_64F1 and Func_01_6580 (scene row upload) use it. Flagged as HRAM: no reuse found, but nearby bytes are scratch. |
| `$FFB5` | `hSceneTileSlot` | 1 | Only bank_01 scene code uses it. Flagged as HRAM: no reuse found. |
| `$FFB6` | `hSceneRowHdmaPending` | 1 | Only bank_01 scene code and its VBlank RAM code use it. |

## Final bank $01/$03 pass (14 symbols, 85 raw operands)

| Symbol | Address | Evidence |
| --- | --- | --- |
| `wVramDmaStagingBuffer` | `$C400` (`$140`) | HDMA source for the HUD rows and scene row tiles; `$C440` stays raw as +`$40` |
| `wBgCopyColumnsLeft` / `wBgCopyRowsLeft` | `$C94C` / `$C94D` | down-counters in the bank-`$01` background copy loops |
| `wBgRevealCounter` | `$C94E` | step and row/column counter for the four scene scroll routines and `ShowPasswordRejection` |
| `wRecordedPathWriteIndex` | `$CD15` | ring index 0-63, copied to object `+$2E` |
| `wRecordedPathWrapCount` | `$CD16` | incremented on wrap; never read |
| `wRecordedPathStarted` | `$CD17` | 0: the next append reuses the current index |
| `wRecordedPath` | `$CDEF` (`$200`) | 64 x 8 ring of X word, Y word, heading |
| `hScenePaletteBuildIndex` | `$FFA8` | bank `$01` only |
| `hSceneRasterFxEnabled` | `$FFAC` | gates the scene STAT step |
| `hSceneWaitCountdown` | `$FFAD` | bank `$01` only |
| `hScenePaletteFadeOffset` | `$FFAE` | bank `$01` only |
| `hScoreDigitsStarted` | `$FFB8` | leading-zero suppression while drawing the score |
| `hPasswordLevelNumber` | `$FFC6` | bank `$01` only |

**Rejected**, with reasons:
- HRAM reused by other banks (`$FF80-$FF8E`, `$FF96-$FFA7`, `$FFB0-$FFB2`);
- written but never read (`$FFAB`, `$CD2B-$CD32`, `$D561-$D565`);
- a role that differs by routine (`$C94B`);
- an unclear role (`$CD26`, `$CD29`);
- no writer found (`$C6ED`/`$C6EE`);
- a time-shared or bank-dependent region (`$DBFB-$DC40`, `$D7FF`).
