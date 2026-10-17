# Indirect control flow

| Site | Target source | Targets | Bounds | Complete |
| --- | --- | --- | --- | --- |
| ROM0 `$364D` `jp hl` | `wRuntimeCallback` from `RuntimeCallbackTable[wControlSetting]` | 3 bank-0 routines | `wControlSetting` 0-2 | yes |
| ROM0 `$39C3`/`$39F0` `jp hl` | `ScreenModeTable` (bank byte + init/draw) | 12 distinct packages in `$2A-$2E` | modes {0..8, $0A, $0B, $0C}; 9 unused | yes |
| `$01:$450E` `jp hl` | `EntityHandlerTable[+$1E]` | 10 handlers | type-4 objects only; `+$1E` 0-9 (spawn byte 7 is at most 8, +1 once) | yes |
| `$03:$6885` `jp hl` | `StateCheckTable[wLevelNumber]` | 15 handlers | 0-14 | yes |
| WRAM `$D701` `jp hl` (from `$01:4A6D`) | menu-state record handler | 5 `HandleMenuStateNNInput` | menu-state pointers come only from records | yes |
| WRAM `$C8DB` `jp nn` stub (`wNearestTargetScanJump`) | written by `$02:406F` from table `$02:40DD[wLevelNumber]` | 4 tracker scan routines | 0-14 | yes |
| ROM0 `$39C4`/`$39F1` pushed returns | synthetic return to restore the bank | — | — | yes |

Interrupts: every bank switch saves `[$7FFF]`, which holds each bank's own
number, so a save and restore interrupted mid-sequence is safe. The scene interrupt
images call bank-`$01` ROM without mapping it, in three places:
- `SceneStatHandler` -> `Bank01RomImage_5EE0`;
- `SceneVBlankHandler` -> `StartSceneTileRowHdma`;
- `StepSceneWindowSplit` -> `Bank01RomImage_5F26`.

These calls are direct, not indirect. `tools/banks_01_05.py` decodes the three
images and fails if the set changes. The timing invariant and its open sites
are in UNRESOLVED.md item 1.

None of the 27 entries named in FINAL_FUNCTIONS.md is the target of a `jp hl`,
a table or a stored pointer. Two are reached by a pushed return:
`AimObjectAtPlayerFromProximity` from `CheckObjectNearPlayerBox`, and
`SnapAndAdvanceRecordedPathWaypoint` from the path-follow branch.

## Site owners (checked by `tools/operand_audit.py`)

Every indirect transfer in `src/` is listed below by the routine that contains it.
The audit fails if a new `jp hl` or transfer to RAM appears in a routine that is
not listed here or in `docs/research/completion/`.

| Owner | Kind | Target set |
| --- | --- | --- |
| `VBlankInterrupt` (`$0040`) | `jp $C7F1` | VBlank handler image installed by one of the four installers (menu, scene, bank-`$02` gameplay, bank-`$02` basic) |
| `LCDInterrupt` (`$0048`) | `jp $C729` | STAT handler image, same installers |
| `DispatchRuntimeCallbackUnlessPaused` | `jp hl` | `wRuntimeCallback` (3 routines) |
| `ScreenTable_CallInit`, `ScreenTable_CallUpdate` | `jp hl` | `ScreenModeTable` packages (12 distinct) |
| `DispatchEntityHandler` | `jp hl` | `EntityHandlerTable` (10) |
| `RAM_D6CE` (menu RAM image) | `jp hl` | menu-state record handler (5 `HandleMenuStateNNInput`); return pushed as `MenuHandlerReturn` (`$D702`) |
| `DispatchStateCheck` | `jp hl` | `StateCheckTable` (15) |

Pushed constant returns, besides the screen dispatcher's:
- **`UpdateObjectSequenceMovement`** (`src/bank_03.asm`) pushes
  `HandleSequenceWaypointArrival` (`$03:5E5C`).
- **The path-follow branch** pushes `SnapAndAdvanceRecordedPathWaypoint`.
- **`CheckObjectNearPlayerBox`** pushes `AimObjectAtPlayerFromProximity`.
- **`RAM_D6CE`** pushes `MenuHandlerReturn`.

Stack rewrite: `Music_HandleEvent .SetDelayAndReturn` (`src/bank_06.asm`) pops the
saved sequence pointer, steps it back one byte and pushes it again, so two-byte
note-off events re-read their last byte. It returns to the original caller.
