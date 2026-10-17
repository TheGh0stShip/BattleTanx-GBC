# Scene interrupt banking

All counts are SM83 M-cycles in CGB double speed: 228 per line, 2,280 per
VBlank period, 35,112 per frame. `Boot` -> `Init` toggles the speed once
through `EnableDoubleSpeed` (KEY1 + `stop`), so the game runs in double speed.
`EnableDoubleSpeed` does not test KEY1 bit 7 before toggling; a soft reset
(`RestartGame`) therefore toggles again. Whether a soft reset can leave the
CPU in normal speed is original behaviour still to be checked (section 6).

Every timing figure comes from hand counts or a host-side SM83 interpreter run
over the shipped ROM bytes. A deterministic PyBoy smoke test now confirms that
the rebuilt ROM boots and reaches chromatic CGB output, but it does not exercise
the narrowly timed interrupt scenarios below. Nothing has been checked on
physical hardware. Label names follow the current source.

Classes used below:
- **proven safe**: excluded by code paths and cycle counts with a margin far
  larger than the hardware uncertainties;
- **safe under invariant**: safe if a named invariant (I1-I4) holds;
- **unsafe (static model)**: a concrete scenario reaches the forbidden
  condition under the static timing model;
- **unproven**: neither excluded nor shown reachable.

## 1. Forbidden conditions

**F1 (ROM bank).** The CPU executes bank-`$01` ROM at `$5EE0`, `$5F26` or
`$6580` while ROM bank 1 is not mapped. The mapped bank's bytes run instead
(bank `$02` has zeros at `$5EE0`).

| Exec | ROM | Bytes | Caller | Fires when |
| --- | --- | --- | --- | --- |
| `$C755` | `$01:5DA3` | `CD E0 5E` | `SceneStatHandler` (HBlank path) | `hSceneBankSwitchGuard = 0`, STAT bit 2 clear, `hSceneLcdStepPending != 0`, `hSceneRasterFxEnabled != 0`, index != limit |
| `$D14D` | `$01:5BE3` | `CD 26 5F` | `StepSceneWindowSplit` (VBlank) | `hSceneBankSwitchGuard = 0` and `hSceneWindowSplitCountdown = 0`; once 0 it stays 0, so this fires every VBlank |
| `$C815` | `$01:5E3A` | `CD 80 65` | `SceneVBlankHandler` | `hSceneRowHdmaPending != 0`, whatever the guard holds |

**F2 (WRAM bank).** A scene handler executes WRAMX code (`$D120`
`EnableSceneWindow`, `$D130` `DisableSceneWindow`, `$D140`
`StepSceneWindowSplit`, `$D2F0` `WriteBgPalette7FromFFA0`, `$D310`
`WriteBgPalette7FromFF98`) while SVBK != 1, or before `InstallSceneRamCode`
has written it. Neither handler saves or forces SVBK.

**Original slip (documented, not fixed).** `$5EE0` and `$5F26` have
byte-identical WRAM copies at `$D2C0` and `$D310`. The same STAT handler calls
the `$D310` copy at `$C76F`, but ROM `$5EE0` at `$C755`.
`StartSceneTileRowHdma` (`$6580`) has no WRAM copy. `tools/banks_01_05.py`
pins this set of ROM calls.

## 2. Handler facts

- **Installation (verified).** `InstallSceneInterruptHandlers` (only caller
  `InitSceneDisplay`) copies the WRAM0 handlers (`$C729`/`$9F` and
  `$C7F1`/`$56` bytes) under `di`, sets IE = `$03` and STAT bits 6 (LYC) and
  3 (HBlank), and ends with `ei; nop` without clearing IF.
  `InstallSceneRamCode` then copies `$D000`, `$D120`, `$D130`, `$D140` and
  `$D160` with SVBK = 1 from constant ROM images. STAT bits 4/5 are never set.
- **HBlank and VBlank costs (verified).** Dispatch 5, vector `jp` 4 and `reti`
  included; the 0-5 cycles to finish the interrupted instruction excluded.

| Path | M-cycles |
| --- | --- |
| STAT HBlank, guard set | 48 |
| STAT HBlank, pending 0 | 61 (exact 57; 61 used as the safe value) |
| STAT HBlank, `$5EE0` step | 150 (+89 over idle) |
| STAT HBlank, clear (fx off / index == limit) | 130 / 139 |
| VBlank best (guard set, even frame) | 106 (128 with countdown != 0) |
| VBlank worst returning (countdown 0, row HDMA, odd frame) | 671 (511 if GDMA is 8 M per block) |

- **LYC path costs (verified, v98).** The mode-0 wait polls on a fixed 8-M
  grid, so exact worst totals with dispatch at the line start are:

| LYC path | mode 3 <= 289 dots | mode 3 <= 185 dots (no objects) |
| --- | --- | --- |
| Split (`LycMatch` -> `WaitHBlankForSplit`, clamped) | **312** | **264** |
| End, fx on, pending set | 285 | 229 |
| End, fx off, pending set | **311** | **255** |

  No-wait totals are split 173/176, end 149/146 (fx on) and 175/172 (fx off).
  Earlier figures of 316/288 rounded the wait up; an older 356/322 came from a
  simulator that truncated the `$C729` image at `$60` bytes and is withdrawn.
- **LYC count (verified).** rLYC writers are `InitSceneDisplay` (0),
  `StepSceneWindowSplit` (countdown-1, or `$5F` at 0) and the split path
  (`min(c+$5F, $8F)`). At most 2 LYC interrupts per frame; rLYC stays in
  0..143. **Line-153 caveat:** with LYC = 0, LY reads 0 early in line 153, so
  the split path runs there and polls through mode 1 until line-0 mode 0 (up
  to about 541 total, at most 313 of it inside line 0). The line keeps its
  count of 2 LYC; the extra cost falls mainly in the VBlank period.
- **`$5EE0` sequences (proven).** Armed only on the second LYC hit, at line
  `countdown+$5F`, and only if `countdown+$68 < $8F` (c <= 38). Steps land on
  lines 96-141 and every sequence finishes in its frame. A sequence makes
  `limit - index` calls followed by one clear. `hSceneLcdStepLimit` is 7 at
  init and only decremented by `FadeOutSceneBackground`; it reaches 0 after the
  fade. `hSceneLcdStepIndex` is not reset by `InitSceneDisplay`.
- **At most 7 `$5EE0` calls per frame: proven** (section 5, H1).
- **`hSceneRowHdmaPending`** is set only at the end of `DrawNextSceneRow`,
  after `StageSceneRowTiles` restores bank 1. It is cleared by
  `InitSceneDisplay` and by `SceneVBlankHandler` before the `$6580` call, so it
  is 0 after any halt-synchronised VBlank.
- **Main-code budgets (verified, v98).** From the VBlank IRQ, main code has
  **15,613** cycles before line 95 (15,662 with no objects) and **22,871**
  before line 144 (22,976 with no objects), after the worst state-constrained
  STAT load. VBlank-period time is not counted.

## 3. Audio_Update bounds (host model)

"Window" runs from the bank-`$06` write to the restore. Total = window + 60,
plus 4 when `wNoiseLockTimer != 0` (the decrement happens before the bank
write). The +4 correction is from v77.

| Quantity | Window | Total |
| --- | --- | --- |
| Idle call | 58 | 118 |
| Worst music call (Music_08 loop) | 1,654 | **1,718** |
| Worst SFX addition | +474 | +474 |
| Per queued entry / ring wrap | +156 / +10 | same |
| **Absolute per call** (30 entries) | **6,818** | **6,882** |
| `$60D2` first call, intro scene 2 (old music + `$10` + `$8x`) | 2,433 | 2,497 |
| `$60D2` first call, exit (`$88`) | - | 2,342 + untraced earlier entries |
| `$60D2` first call, intro scene 1 (menu/level queue untraced) | - | <= 6,882 |
| `$60D2` steady state (`$24`) | - | 2,347 |
| `$610A` delay loop; `WaitForButtonOrTimeout` fade calls 1-15 | - | 2,192 |
| Fade call 16: intro 2 / exit / intro 1 | - | 1,739 / 1,985 / 2,192 |

The 1,654 music maximum is strong, not proven: repeated noise locks were not
enumerated. The noise lock changes pointer progression (`.NoteOff` on channel
4 with the lock set takes `.SetDelayAndReturn`). No ISR and no scene RAM image
queues sounds; the fade loop queues nothing.

## 4. Window classification for F1

| Window (bank mapped) | Class | Basis |
| --- | --- | --- |
| `LoadFixedSceneResources` (`$D000`) and nested far calls | **proven safe** | Guard = 1 before the bank write, cleared only after bank 1 returns. Entered right after a VBlank wait, so pending = 0 |
| `ClearBackgroundPalettes` -> `ClearBackgroundPalettesImpl` in `LoadFixedSceneForRow` | **proven safe** | Guard = 1 throughout; pending 0 |
| `ClearShadowOamAndTransferFar` (bank `$02`; legacy alias `Func_3CD9`) | **proven safe** | Starts <= 708 after VBlank dispatch; ends inside VBlank (2,280) |
| `LoadScrollingScenePalette` (`$D160`), callers `RunMenuGridSceneScroll`, `ShowMenuGridScene` -> `LoadScrollVariantForGridCell`, `SetMenuGridColumnClamped` | **proven safe** | I2 holds at every caller: each follows a halt-synchronised VBlank (for `SetMenuGridColumnClamped`, the one in `ClearShadowOamAndTransferFar`) with no `DrawNextSceneRow` or installer in between. Premise: no non-scene handler calls `$6580` |
| `Audio_Update` at `$60D2` / `$610A` / `$62C7`, frames with no row drawn (includes the 2,497 first call) | **proven safe** | Starts by line 147, ends early in the next frame; pending 0. `$62C7` cannot reach `$5EE0`: raster fx is cleared before its loop |
| `Audio_Update` at the same sites, row-drawing frames | **safe under I3** (OAM proven empty, v70) | L3/L4 never reach an OAM writer after their clears; at `$62C7`, `HandleMenuState06Input` calls `ClearShadowOamAndTransferFar` on every nonzero input before `RunMenuGridSceneScroll`. Mode 3 <= 185 dots, the call ends by about line 70, so neither line 95 nor 144 is reached |
| `ComputeSceneRowPointer` (`$D1F0`), `StageSceneRowTiles` (`$D370`) | **safe under I1** | `$6580` impossible (pending 0); timing excludes `$5F26`/`$5EE0`. Restore by about LY `$35` (about LY `$70` in single speed) |
| `ClearBackgroundPalettes` -> `ClearBackgroundPalettesImpl` after the scroll: `ClearSceneSplitPalettes`, final intro `ClearBackgroundPalettes`, exit flow's `ShowScreenMode12WithScoreAndLives` | **safe under I1 + I3** | `$6580` excluded (16+ fade VBlanks clear the flag). `$5EE0` excluded: limit 0 and index 0 at entry (I4 is now proven). `$5F26` excluded: the windows end by line 79 at the per-flow audio bounds, by line **107** at the absolute 6,882, and stay below line 144 for any last-fade `Audio_Update` up to about **12,969** (v77) |

Entry lines of the three `ClearBackgroundPalettes` windows (v77 model: VBlank 306 + halt 19,
then hand-counted tails; copy >= 2 bytes per line; 6-line LYC allowance):

| Window | Audio total | Audio ends | Bank write | `ClearBackgroundPalettesImpl` lines |
| --- | --- | --- | --- | --- |
| Intro 2 | 1,743 | LY 153 | LY 38 | 39-76 |
| Exit | 1,989 | LY 0 | LY 40 | 41-78 |
| Intro 1 | 2,196 | LY 1 | LY 41 | 42-79 |
| Absolute | 6,882 | LY 29 | LY 69 | 70-107 |
| Short path | 118 | LY 145 | LY 151 | 0-37 |

**Invariant I1.** A bank-switched window that starts after a halt-synchronised
VBlank ends before line 95 whenever `$5EE0` is armed, and before line 144
whenever the countdown is 0 or pending is set. Requires double speed and the
6,882 total `Audio_Update` bound.

**Invariant I2 (proven).** `hSceneRowHdmaPending = 0` on entry to
`LoadScrollingScenePalette`.

**Invariant I3 (hardware).** With all 40 OAM entries at Y = 0 or X >= 168,
mode 3 <= 172 + SCX%8 + ~6 (window) <= 185 dots, leaving HBlank >= 95 M. SCX
is 0 in the scene flows (only scene-block rSCX write is the 0 in
`InitSceneDisplay`); the window stays enabled and is moved through WX.

**Invariant I4 (now proven, section 5).** In each decrementing fade frame, the
`hSceneLcdStepLimit` store comes before line 96.

**Unsafe under the static model for F1:** none on a traced path.
**Unproven for F1:** none on a traced path; the residual is the I3 OAM claim
(arithmetic-built OAM pointers not exhaustively excluded) and the hardware
assumptions.

## 5. Hazards

### H1. Step-limit race: proven impossible (v75, w87)

`FadeOutSceneBackground` decrements the limit from main code. A race would
need the store to land after the L-th `$5EE0` call and before the clear, so
index > limit and up to about 256 runaway calls.

The store runs only in iterations with d >= `$10`, always after a wake with
`wVBlankPending = 1`, which only the VBlank handler sets; an overrun iteration
re-waits. Main time from the wake to the store is 31 + A.

| Case | Store lands |
| --- | --- |
| Earliest (VBlank 106, A = 118) | line 145 |
| Normal worst (VBlank 671, A = 2,196) | about line 3-4 |
| Absolute (A = 6,818 window) | by line 34 |
| Lost wakeup (VBlank between clear and `halt`; next wake is line-0 HBlank) | about line 15 (A = 2,196), 41-43 (A = 6,818) |

The race window is one line wide, at the limit read on line b+L, between
line 96 and line 141 (L = 7 gives 102/103). Reaching it needs A >= about
15,450 even on the lost-wakeup path, against a bound of 6,882: a margin of
about 8,600 M (52 lines). There is a single limit writer and no ISR writes it.
**Result: index never passes the limit; at most 7 `$5EE0` calls per frame is
proven**, subject only to hardware timing uncertainties of hundreds of cycles.

### H2. Stale WRAM code during installation (F2)

Between `ei` and the end of the `$D140` copy there are 4,497 cycles plus the
HBlank load, about 26-29 lines. The images are constant; the `$D000` image
ends at `$D113` and never reaches `$D120`, so a re-install over an earlier
identical install runs correct code even when partial.

| `InitSceneDisplay` caller | Class |
| --- | --- |
| Exit flow (`ReturnToMenuAfterLevel`) | **proven safe**. Basic handlers with IF cleared; `ei` at LY 46-47; copy ends about LY 74; no VBlank or LYC = 0 in the window |
| First intro call, menu path and `jp RunLevel` path | **proven safe** (v92). `ei` about LY 47-49, copy ends about LY 76-78; margin > 60 lines from LY 144 and LY 0. At those lines STAT bit 2 = 0, so the immediate `SceneStatHandler` takes the plain return |
| `bank_01:3072` menu grid | **proven safe** (single derivation). Entered inside VBlank; ends about LY 75 |
| `bank_01:3696`, non-boot | **proven safe** (single derivation). Same argument as the exit flow |
| Second intro call, no-row levels | **proven safe** (v76): predecessor is the first call's VBlank halt |
| Second intro call after a row scene | **safe under I3 + v76 start bound** (w108). `FadeOutSceneBackground` returns on X = 22..29; the window ends at L+43 with L = X+65, so a VBlank lands in it only for X >= 36: margin 7 lines. X = 36 needs the `LoadBackgroundPaletteFrame` copy to start at LY >= 8, about 1,500 M later than v76's estimate (which rests on the 2,196 audio bound). Content is safe anyway: a VBlank runs the identical image (countdown `$8E`: decrement, LYC = `$8D`) |
| `bank_01:3696`, boot | **content safe (proven); timing unproven** (margin < 25 lines). Image identical to the one `InstallSceneRuntimeCodeFar` installed |

A stale-content hit needs an intervening WRAM1 writer. The only one found is
the gameplay object pool (`$D000-$DFFF`); computed-pointer writers are not
excluded (strong). The exit flow, which crosses it, is proven safe by timing.

Side note (v92): after `InitializeLevelRuntime` calls
`InstallBasicInterruptHandlersFar`, STAT/LYC interrupts reach
`StatHandlerReti` until the gameplay handler install; on the menu path STAT
bit 3 is still set, costing about 13 cycles per line. Harmless.

### H3. SVBK = 2 windows (F2)

`CopyBackgroundPaletteFromFrame` holds SVBK = 2 for 131 M (switch about +2 M after the logged
store at both ends). `LoadBackgroundPaletteFrame` holds it for 1,042 M in VBlank. From LY 0 each
byte waits for mode 0 (the poll in `LoadBackgroundPaletteRange`); with empty
OAM and the 57-61 M HBlank ISR it completes **2-4 bytes per line** (w108,
exhaustive phase sweep; worst average 2.33; never 0-1; a copy started on line
S ends on S+21..S+28). A long-handler line (LYC hit, `$5EE0` step) loses all
its bytes. A spill into visible lines stretches the window by many lines. The STAT LYC path
(`SceneStatHandler_LycMatch` -> `SceneStatHandler_WaitHBlankForSplit`) calls `$D310` (`WriteBgPalette7FromFF98`) and
`$D120` (`EnableSceneWindow`) on LY == countdown with no SVBK save.

| Path | Class |
| --- | --- |
| VBlank -> `$D140` during scene fades | **safe under I1** |
| `ApplySceneTargetPalettes` | **proven safe**: guard = 1, window ends by 1,734, before LY 153 |
| `CaptureBgPalettesAndFadeToWhite` (boot, via `FadeBackgroundPalettesToWhiteWithSound` -> `FadeBackgroundPalettesToWhite`) | **proven safe** (v76, w94): `InstallSceneRuntimeCodeFar` handlers (STAT `reti` stub, IE = `$01`) touch only WRAM0, I/O and P1 |
| Soft reset while SVBK = 2 | **proven safe** (v76): IE = 0 and SP in WRAM0 until `ClearGameMemory` sets SVBK explicitly |
| Menu `StepMenuScroll` | **proven safe**: runs inside `MenuVBlankHandler`, which forces SVBK = 1 |
| Menu-grid fades (`bank_01` B-exit, row wrap -> `ShowMenuGridScene`, state-6 entry -> `ShowMenuGridScene` fade-in) | **proven safe** (w94, verified v129; OAM slots 16-39 zero is strong). `LoadFixedSceneForRow` leaves countdown 0, so LYC = 95 only; there `SceneStatHandler_WaitHBlankForWindowEnd` calls `$D2F0` then `$D130`, all after the window. `$D310`/`$D120` need an LYC IRQ at LY 0, impossible. Window starts by LY 32-33 (v129 correction of 25-27) and ends by LY 62-66 even at A = 6,808, before line 72 (first object line), 95 and 144 |
| STAT HBlank path -> `$D2F0` | **proven safe**: pending is 0 at every VBlank and set only at line >= 95; the window ends by about LY 93 |
| **STAT LYC -> `$D310`/`$D120` in `FadeOutSceneBackground`, no-row intro, LYC = 1** | **unsafe (static model)** when the burst residue leaves the guard nonzero (w89, v112). v111 modelled only guard = 0 and does not settle this row. Scenario and effect below |
| Same, LYC = 0 frame (edge at LY 153) | **proven safe** for F0 = 142: calls 139/141 cost <= 308, window ends by 1,869, before 2,052 |
| Same, guard = 0 entries (normal level advance, row-scene levels) | **unsafe only with input (static model, v111)**. Full-system simulation gives N = 10, F0 = 132 on every path (131 for a row level's second scene after a heavy last audio call). Music `$86` (1 in 6) plus Start pressed so a `FadeOutSceneBackground` frame is frame 131: call 130 covers the LYC edge (all variants at H = 215). `$83` hits only if mode 3 ends at 150 M or later; `$81/$82/$84/$85` never. With no input it is safe: the 96-frame scroll delay, at least 32 scroll frames and the 60-frame `WaitForButtonOrTimeout` timeout put the fade after frame 132, when LYC = 95. Intro scene 1 (row scene) stays unproven: its music state is not traced. Effect as below |
| Same, exit scene, `3072`/`3696` flows | **safe (static model, v111)** with music `$88`: no hit at F0 = 132 or 142 |

**SVBK = 2 scenario (w50 trace, verified by v90; reachability w89).** Let F0
be the countdown value at the start of the scene's lock-stepped fade, so after
VBlank j the countdown is F0 - j and `Audio_Update` call j-1 runs.

- **Guard nonzero at the second `InitSceneDisplay` (F0 = 142).** On no-row
  levels (`LevelRowSceneFlags` = 0: levels 1, 2, 4, 5, 7, 8, 10, 11, 13, 14),
  nothing between the start of `RunLevelIntroSceneFlow` and the second
  `InitSceneDisplay` writes `$FF80`. The guard is normally nonzero after a password
  start that follows a completed level-select game: `UpdateBurstEffectObjects`
  in `RunBurstEffectUntilButton` leaves the last live slot's horizontal
  velocity in `$FF80` (v112; not X). Top-level objects have `$05-$0A` or
  `$F9-$FB`; a child (parent + `BurstChildOffsets`) can be 0, and an empty final
  pass leaves an older value, so nonzero is not guaranteed. The password route
  never opens the grid, so the value survives (v112). Steps: complete a level-select game; at the burst screen wait for
  input and press, then press again at the exit wait; go straight to password
  entry (not the grid) and enter a no-row level password; random music must be
  `$86` (1/6); hold Start so `WaitForButtonOrTimeout` returns at V133-V140. On the frame
  after V141 (countdown = LYC = 1), track `$86` call 140 costs 830/995/1,015.
  The SVBK = 2 window covers the LY 1 edge at 2,508 exactly when **H + A >=
  985** (w108; H = VBlank cost): H = 215 covers all three costs (ends from
  2,946), H = 128 covers A = 995/1,015 but not 830 (ends 2,489-2,501).
- **Guard zero (normal level advance: `LongToBcd40` exits with `$FF80` = 0).**
  At least 9 scene VBlanks (`ClearSceneVram` loop and waits,
  `InitSceneDisplay_WaitVBlank`, `RunScrollingScene` wait) decrement the
  countdown before the scene, so F0 <= 133 (exact N, likely 9-12, unknown).
  Hits for both mode-3 ends: F0 = 130 (tracks `$84`/`$85`, call 129, LYC 0);
  F0 = 131-133 (track `$86`, call 130, LYC 0/1/2); F0 = 134 (`$81`, call 133).
  Row-scene levels have the guard proven 0 (v112) and are probably affected too.

**Effect (w113, host interpreter; 4,096 phase/LY/SP cases per scene, outcome
identical across cases).** WRAM bank 2 `$D000-$D7FF` holds the 32-frame fade
cache built by `PrepareBackgroundPaletteFade`/`BuildBackgroundPaletteFadeFrames`, fixed per scene: `$D310` is frame 12,
`$D120` frame 4 (mostly `00` with sparse opcodes). By the second scene:

| Scene (levels) | Outcome |
| --- | --- |
| 6 (0-2), 9 (9-11) | crash: `rROMB0` written with `$C0`, SP corrupted, `rst $28` |
| 7 (3-5) | crash: `ld sp,$0001`, MBC writes, `jp nz,$0024` |
| 10 (12-14) | crash: `ld sp,$0007`/`ret nz` to `$0000` with SP in ROM |
| 8 (6-8) | returns: five `stop`s in `$D120` freeze CPU and LCD until a button line goes low; `[$C700/$C701]` (via echo `$E700`) get SP bytes (two palette bytes); palette-7/window update skipped |
| Row scenes 0-5 | **unresolved** (unmodelled VRAM/HRAM reads, loops, `call $0004`) |

Unmodelled: `stop` under double speed (KEY1), the ROM0 path after a crash.

Dependencies: the w16 audio-state model (NR52/noise variants), the STAT
blocking assumption that the LY 1 LYC edge fires right after the line-0 mode-0
source, and the exact N. w108 confirmed the W50-7 timing (cover condition above) and w113 the effect;
v111 fixed F0 = 132 for guard = 0 (rejecting the F0 = 140 used by w50/w89)
and classified those entries as unsafe only with input; the nonzero-guard row
rests on w89/v112.

## 6. Hardware assumptions

None has been tested on an emulator or on hardware.

1. **Opcode timing.** `jr cc` 3/2, `jp cc` 4/3, `call cc` 6/3, `ret cc` 5/2,
   CB `(hl)` 4 (3 for `bit`), interrupt dispatch 5.
2. **Double speed.** 1 M-cycle = 2 dots; a line is 456 dots = 228 M. The game
   is assumed to stay in double speed after a soft reset (see the
   `EnableDoubleSpeed` note in the header).
3. **Mode lengths.** Mode 2 is 80 dots. Mode 3 is 172-289 dots: 172 + SCX%8 +
   ~6 (window) + up to ~11 per object. Objects with Y = 0 add nothing; objects
   with X >= 168 are assumed to add nothing.
4. **GDMA.** 16 M per 16-byte block in double speed (320 for the row), plus
   unmodelled overhead.
5. **Interrupts.** Latency <= 6 M. STAT is requested at mode-0 start (HBlank)
   or on the LY == LYC edge; on the LYC line STAT blocking yields no second
   HBlank interrupt. The LY 1 LYC edge fires right after the line-0 mode-0
   source.
6. **LY 153.** LY reads 0 and LYC = 0 matches 0-8 cycles into line 153.
7. **halt.** Waking with IME = 1 costs about +1; the pending interrupt is
   serviced first.
8. **STAT mode bits.** The mode bits read by the 8-M poll loop change exactly
   at the mode boundary.
9. **Cartridge.** MBC5, 1 MiB (`$0148 = $05`, 64 banks); each bank stores its
   number at `$7FFF`.

## 7. Watch procedure

Run on any CGB emulator with conditional breakpoints.

1. **F1.** Break at PC `$5EE0`, `$5F26`, `$6580` when `[$7FFF] != 1`.
2. **F2.** Break at PC `$D120`, `$D130`, `$D140`, `$D2F0`, `$D310` when
   `[$FF70] & 7` is not 1 (treat 0 as 1).
3. **Stale code.** Break at PC `$D140` when `[$D140] != $F0` or
   `[$D141] != $86`.
4. **Handlers.** Confirm `$C755` = `CD E0 5E` and `$C815` = `CD 80 65`.
5. **Log on each hit:** LY, SVBK, `hSceneBankSwitchGuard`,
   `hSceneWindowSplitCountdown`, `hSceneLcdStepPending`/`Index`/`Limit`,
   `hSceneRasterFxEnabled`, `hSceneRowHdmaPending`, and the PC of the last
   write to `$2000-$2FFF`.
6. **Sanity.** Break when `hSceneLcdStepIndex > hSceneLcdStepLimit` (expected
   never, H1).
7. **Coverage.**
   - Menu state 6 grid browsing and grid fades (L2).
   - Every level intro (L3), including no-row levels after normal level
     advance, with Start held so the scene exits near V130-V141.
   - The H3 scenario: password start after a completed level-select game,
     no-row level, music `$86`, Start released for a V133-V140 return. Retry
     until the music pick is `$86`.
   - The level exit / password flow (L4) and the boot sequence.

A hit proves the hazard. No hits across the plan is evidence, not proof.

### Diagnostic bank-trap build (`make diag`)

`make diag` builds a separate ROM in a temporary copy without touching `src/`:
it requires the shipping SHA-1 `5078584e…`, adds three checker stubs and a
trap routine in the ROM0 zero fill at `$3F39-$3F92`, and retargets only the
operands of the three `CD lo hi` calls (`$5EE0` -> `$3F39`, `$5F26` ->
`$3F49`, `$6580` -> `$3F59`). It checks that the size is 1,048,576, no
shipping symbol moved, only 95 bytes differ, and `src/` hashes are unchanged.
Result SHA-1: **`27aea214475a791b88c4bce91dc56d8ac2003b13`**.

- **Pass path.** With `[$7FFF] == 1` the stub is transparent (registers,
  flags, return address preserved); +19 cycles per call, +2 bytes of stack.
- **Trap path.** `di`; writes `$C000 = $D1`, `$C001 = $A6`, `$C002` = site
  (1 = `$5EE0`, 2 = `$5F26`, 3 = `$6580`), `$C003` = mapped bank, `$C004` =
  LY; fills BG palette RAM red; `ld b,b`; hangs. Read the WRAM signature, not
  the colour.
- **Side effects.** Destroys `wBootHardwareMode` (`$C000`), so do not trust a
  soft reset after a trap. Global checksum stale; header checksum unaffected.
- **Limits.** **Covers the ROM-bank hazard (F1) only.** It does not detect the
  SVBK = 2 hazard (H3) or stale code (H2); use watch steps 2-3. The extra 19
  cycles per call slightly shift timing-sensitive windows.

## 8. Summary

| Item | Class |
| --- | --- |
| All F1 windows | proven safe, or safe under I1/I3 |
| H1 step-limit race | proven impossible (7-call bound proven) |
| H2 stale code | proven safe; second intro after a row scene safe under I3 (7-line margin); boot `3696` timing unproven, content safe |
| H3 SVBK = 2, nonzero-guard password start; guard-zero fades with music `$86` and a timed Start press (F0 = 132, v111); exit fades safe | unsafe (static model): crash on scenes 6/7/9/10, `stop` freeze + 2 palette bytes on scene 8, row scenes unresolved |
| H3 menu-grid fades | proven safe |
| H3 exit scene, `3072`/`3696` fades | unproven |
| All other H3 paths | proven safe or safe under I1 |
