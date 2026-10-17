# Scene interrupt banking

**Forbidden condition:** the CPU executes bank-`$01` ROM at `$5EE0`, `$5F26` or
`$6580` while ROM bank 1 is not mapped. If it happens, the CPU runs whatever
the mapped bank holds at that address. For example, bank `$02` has zeros at
`$5EE0`.

**Conclusion:** not proven safe overall. Each window is classified below. No
emulator or debugger is installed, so the watch procedure in section 6 has not
been run.

All counts are SM83 M-cycles. The game runs in CGB double speed, so a line
is 228 M-cycles and a frame is 35,112. `Boot` -> `Init` toggles the speed once,
via `EnableDoubleSpeed`, which is a KEY1 + `stop` toggle (`src/bank_00.asm`). A
soft reset (`RestartGame`) toggles twice, so the game always ends up in double
speed.

## 1. The three calls (byte-verified)

| Exec | ROM | Bytes | Caller | Fires when |
| --- | --- | --- | --- | --- |
| `$C755` | `$01:5DA3` | `CD E0 5E` | `SceneStatHandler` (STAT) | `hFF80 = 0`, not the LYC interrupt, `hSceneLcdStepPending != 0`, `hSceneRasterFxEnabled != 0`, and index != limit |
| `$D14D` | `$01:5BE3` | `CD 26 5F` | `StepSceneWindowSplit` (from VBlank) | `hFF80 = 0` and `hFF86 = 0`; once `hFF86` reaches 0 this is every VBlank |
| `$C815` | `$01:5E3A` | `CD 80 65` | `SceneVBlankHandler` | `hSceneRowHdmaPending != 0`, whatever `hFF80` holds |

**Original slip (documented, not fixed):** `$5EE0` and `$5F26` already have
byte-identical WRAM copies at `$D2C0` and `$D310`, copied by
`InstallSceneRamCode` (`src/bank_01.asm`). The same STAT handler calls the
`$D310` copy at `$C76F` (`CD 10 D3`), but calls ROM `$5EE0` at `$C755`.
`StartSceneTileRowHdma` (`$6580`) has no WRAM copy.

`tools/banks_01_05.py` (`check_scene_interrupt_calls`) decodes the three images
and fails if this set of bank-`$01` ROM calls changes.

## 2. Handler lifetime and interrupt state

- **Installer:** `InstallSceneInterruptHandlers` is the only installer. Its
  only caller is `InitSceneDisplay`. It sets IE = `$03` and rSTAT bits 6 (LYC)
  and 3 (HBlank). STAT bits 4/5 are never set anywhere.
- **di/ei:** the scene paths contain `di`/`ei` only in the installer and
  `InstallMenuInterruptHandlers`. The other di/ei pairs are in ROM0 hardware
  setup.
- **Lifetimes, from tracing the source:**
  - L2: menu state 6, until `Jump_01_52B5` or game start.
  - L3: level intro, until `InitializeLevelRuntime`.
  - L4: level exit flow, until `PrepareDisplayForScreenTransition`.
- **STAT cost:** each visible-line HBlank STAT costs the main code about 61
  M-cycles, or 48 when `hFF80` is set.
- **`$5EE0` lines:** `hSceneLcdStepPending` is set only on line
  `hFF86 + $5F`, and only while `hFF86 <= $26`. So a `$5EE0` call can only land
  on the HBlanks of lines 95-140, and only while raster effects are on.
- **`hSceneRowHdmaPending`:** set only at the end of `DrawNextSceneRow`, after
  `StageSceneRowTiles` has restored bank 1. `SceneVBlankHandler` clears it
  before calling `$6580`, so it is 0 after any halt-synchronised VBlank wait.

## 3. Window classification

| Window (bank mapped) | Length | Class | Basis |
| --- | --- | --- | --- |
| `LoadFixedSceneResources` (`$D000`) and nested far calls | unbounded (halt loops) | **proven safe** | `hFF80 = 1` before the bank write and cleared only after bank 1 is restored; its caller enters right after a VBlank wait, so the pending flag is 0 |
| `Func_3960` -> `Func_02_46E1` inside `LoadFixedSceneForRow` | ~31-42 lines | **proven safe** | `hFF80 = 1` is set before the call; pending flag 0 |
| `ClearShadowOamAndTransferFar` (bank `$02`) | 1158 | **proven safe** | starts at most 708 after VBlank dispatch and ends inside VBlank (2280) |
| `ComputeSceneRowPointer` (`$D1F0`) | 54 | **safe under invariant I1** | VBlank `$6580` is impossible (pending flag 0); `$5F26` and `$5EE0` are excluded by timing |
| `StageSceneRowTiles` (`$D370`) | 54 + 12 + 6588 | **safe under invariant I1** | as above; the restore lands by about LY `$35` when started after a VBlank |
| `LoadScrollingScenePalette` (`$D160`) | depends on `Func_3856` | **safe under invariant I2** | `hFF80 = 1` blocks the STAT and `$5F26` paths but not `$6580`. Its caller at `src/bank_01.asm` (`Jump_01_609E` path) enters right after a VBlank wait; for the two menu-grid callers the entry value of the pending flag is not proven |
| `Audio_Update` (bank `$06`) | best 58, worst about 8,200 (upper bound) | **safe under invariant I1 at the post-VBlank call sites; unproven** at the first pass of the `610A` loop, the queued-sound `60D2` path and the per-frame `62C7` call | those calls start when `AdvanceSceneScroll` returns, which depends on PPU mode-3 length |
| `Func_3960` -> `Func_02_46E1` (bank `$02`) at the other call sites (`ClearSceneSplitPalettes`, final `ClearBackgroundPalettes` in the intro, `ShowScreenMode12WithPasswordScoreLives` in the exit flow) | ~31-42 lines, polling STAT | **unproven** | `hFF80 = 0`, raster effects on, and `hFF86` is not statically known (1-`$26` on the shortest path) |

**Invariant I1:** a bank-switched window that starts after a halt-synchronised
VBlank must end before line 95 whenever `$5EE0` is armed. It must also end
before line 144 whenever `hFF86 = 0` or the pending flag is set. Worst cases:
- the row windows end by about LY `$35`;
- `Audio_Update` ends by about line 40 when started in VBlank;
- in single speed the row restore would reach about LY `$70`, inside the `$5EE0`
  window, so double speed is part of the invariant.

**Invariant I2:** `hSceneRowHdmaPending = 0` on entry to
`LoadScrollingScenePalette`.

## 4. Related hazards (strong, not proven)

- **Stale code at `$D140`:** `InstallSceneInterruptHandlers` enables
  interrupts without clearing IF, and only then copies `$D000-$D159`.
  In the level exit flow, WRAM bank 1 `$D000-$DFFF` still holds the gameplay
  object pool. A VBlank with `hFF80 = 0` in that roughly 7.7k M-cycle span
  would execute object data at `$D140`.
- **SVBK:** `Func_3A52`/`Func_3A68` set SVBK = 2 while `hFF80 = 0`, and the
  VBlank handler always calls `$D140` in WRAMX. These windows were not counted.
- **`LoadScrollingScenePalette` callers:** the two menu-grid callers run
  `CopyScrollingSceneDescriptor` and the palette load without a preceding
  VBlank wait in the same routine.

## 5. Static checks in `make check`

- `tools/banks_01_05.py`: the set of bank-`$01` ROM calls in the three scene
  images is pinned.
- `tools/completion_invariants.py`:
  - the row images (`$D1F0`, `$D230`, `$D370`, `$D3B0`) contain no
    di/ei/halt/reti;
  - in `DrawNextSceneRow` the pending-flag store follows
    `call StageSceneRowTiles`;
  - the `Func_3960` call sites are pinned, so a new site fails the check.

## 6. Reproducible watch procedure

Run on any CGB emulator with conditional breakpoints:
1. Break at PC `$5EE0`, `$5F26` and `$6580` with condition `[$7FFF] != 1`. Each
   bank holds its own number at `$7FFF`, so this reads the mapped bank.
2. Confirm the scene handlers are installed: bytes at `$C755` = `CD E0 5E` and
   `$C815` = `CD 80 65`.
3. On each hit, log LY, `hFF80`, `hFF86`, `hSceneLcdStepPending`,
   `hSceneRasterFxEnabled`, `hSceneRowHdmaPending`, and the PC of the last write
   to `$2000-$2FFF`.
4. For the stale-code hazard, break at PC `$D140` when `[$D140] != $F0` or
   `[$D141] != $86`.
5. Coverage: menu state 6 grid browsing (L2), every level intro (L3), and the
   level exit / password flow (L4), with varied input timing; also scenes that
   draw rows often.

A hit proves the hazard. No hits across the coverage plan is evidence, not
proof.
