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
number, so a save and restore interrupted mid-sequence is safe. The remaining
interrupt-time question (bank `$01` code called from interrupt images without
mapping) is in UNRESOLVED.md.
