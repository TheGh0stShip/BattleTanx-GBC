# Hardware and emulator verification plan

Status: **plan only. None of these tests has been run on an emulator or on hardware.**
Revision: matrix updated against `snap8` with w108 (copy throughput, X range), w113 (what
`$D310`/`$D120` execute under SVBK=2), w94 as verified by v129 (menu-grid and boot fades),
and v112 (burst-velocity precondition). v111 adds F0 = 132 for guard 0: the hazard needs music `$86`
and a Start press timed so a fade frame is frame 131 (about a 16-frame window). Line numbers refer to `snap8/src`.
Every "safe" verdict in INTERRUPT_BANKING.md that rests on timing is a host-model
result (exact-cycle SM83 interpreter plus Pan Docs PPU figures). This file lists the
tests that would confirm or refute those verdicts, the diagnostic build, and the
capture procedure.

Units: M-cycles, CGB double speed, 228 M per line, 35,112 M per frame.

## 1. Assumption register

Each test below exists to check one of these. "Source" is the analysis that relies on it.

| ID | Assumption | Kind | Relied on by |
| --- | --- | --- | --- |
| A1 | KEY1 bit 7 = 1 (double speed) on every frame after Init and after each RestartGame | hardware/code | all timing |
| A2 | Mode 2 = 80 dots; mode 3 = 172-289 dots; with no objects mode 3 <= 172 + SCX%8 + ~6 (window) | hardware | w16, w50, w66, v70 |
| A3 | GDMA costs 16 M per 16-byte block in double speed (VBlank row stall 320 M) | hardware | w16 |
| A4 | Interrupt dispatch latency <= 6 M (5 M dispatch + up to 1 M halt wake) | hardware | w16, w50, w66 |
| A5 | STAT IRQ line blocking: on the LYC line, the mode-0 source does not raise a second edge while the LYC source holds the line high | hardware | w66 (LYC-line charge), w16 |
| A6 | LY 153 coincidence fires 0-8 M into line 153 (LYC=0 edge) | hardware | w50 safe-by-computation case |
| I1 | Bank windows close before LY 95 when $5EE0 is armed and before LY 144 when hFF86=0 or a row is pending | invariant | INTERRUPT_BANKING s3 |
| I2 | Row-drawing frames: per-line mode 3 <= 228 dots (OAM all zero) at $01:60D2, $01:610A, $01:62C7 | invariant | w16, v70 "safe under stated invariant" |
| I3 | N($5EE0 calls per frame) <= hSceneLcdStepLimit <= 7; FadeOut decrement of the limit never lands between the last step and the clear | invariant | w66 (strong, race not excluded) |
| I4 | hFF80 (`hSceneBankSwitchGuard`) at the second-scene InitSceneDisplay (no row scene) is nonzero, so F0 = 142 and the w50 SVBK=2 trace is reachable. Proven 0 on the normal level-advance path (w89/v112). On the password-after-level-select route it is the horizontal velocity of the last live burst slot, normally nonzero but possibly 0 for a child slot (v112) | game state | w50, w89, v112 |
| I5 | Menu-grid fades (hFF86=0, LYC=95): the Func_3A52 window ends before LY 72 (first object line) and before LY 95. **Proven safe on code grounds** by w94/v129 under A2/A4: window starts by LY 32-33 and ends by LY 62 (LY 66 with a 67-M ISR); OAM is empty above LY 72 | invariant | w50, w94, v129 |
| I6 | Copy throughput under the scene STAT handler (w108): Func_3A52 completes 2-4 bytes per visible line (worst 2.33 average), Func_02_46E1 exactly 1 iteration per line; a copy started on line S ends on S+21..S+28 | model | w108 |
| I7 | Second intro call (w108 Q1): FadeOutSceneBackground returns on X = 22..29 (30 only through the undefined SVBK=2 LYC case). A VBlank in the stale-`$D140` window needs X >= 36, so the margin is 7 lines | model | w108 |

## 2. Test matrix

L2 = menu state 6 grid, L3 = level intros, L4 = exit/password flow (coverage segments from w19).
"Diag" = diagnostic build (section 3); "Emu" = cycle-accurate emulator with write/exec watch and LY log; "HW" = real CGB/GBA.

### 2.1 Interrupt banking (updated)

| Test | Checks | Setup / reach | Observable | Pass | Fail |
| --- | --- | --- | --- | --- | --- |
| T1 | STAT site $C755 -> ROM $5EE0 with wrong bank | Diag, Emu, HW. L2/L3/L4 raster scenes; fires only LY 96-143 with a sequence armed | $C000-$C004 = D1 A6 01 bank LY | no signature over full coverage | signature present |
| T2 | VBlank split site $D14D -> ROM $5F26 | Diag, Emu, HW. L2/L3/L4 once countdown = 0; concentrate on Func_3960/Func_02_46E1 windows | site byte 02 | none | signature |
| T3 | VBlank HDMA site $C815 -> ROM $6580 | Diag, Emu, HW. Row-drawing scrolling scenes and menu-grid LoadScrollingScenePalette callers | site byte 03 | none | signature |
| T4 | A1 double speed | Emu: watch KEY1 at each scene entry and after soft reset (toggles twice). HW: LY span of StageSceneRowTiles | KEY1 bit 7; restore near LY $35 vs ~$70 | bit 7 = 1 everywhere | single-speed frame found |
| T5 | I1 window timing | Emu: write watch $2000-$2FFF with LY+cycle log, every window of INTERRUPT_BANKING s3 | LY at bank write and restore | all windows close inside I1 limits | any overrun (record frame, hFF86, pending) |
| T6 | Stale code at $D140 / SVBK (I7) | Emu: exec break PC=$D140 if [$D140..1] != F0 86 or SVBK != 1. L4, Func_3A52/3A68 windows. On the second intro call also log the line X on which FadeOutSceneBackground returns | hit log; X | no hit; X in 22..29 (w108) | hit, or X >= 30 (X >= 36 would reach the stale window) |
| T7 | Palette 7 over-read visibility | Emu: dump BCPD and VRAM1 attrs after LoadFixedSceneResources | palette 7 contents vs attr use | not visible or matches doc | visible difference |

### 2.2 Documented defects (unchanged scope)

| Test | Defect | Method | Pass |
| --- | --- | --- | --- |
| T8 | D1 $03:6775 | exec break with [$7FFF]=$03 over all levels with recorded paths | never hit |
| T9 | D2 $01:7975, D3 $02:6432 | exec break with bank check | never hit |
| T10 | D4 $00:1451 | break at retry path; count .cellChanged after failed retry | reachability classified |
| T11 | D5 $00:26EE | break; log object +$23 before/after | path never hit, or effect recorded |
| T12 | D6 $00:164F | exec break over full coverage | never executed |
| T13 | D7, D8 (Set2 172-219, shared $C8CB) | levels 3-4, read watch $05:5800+ in GetLevelCellTileAndAttr | effect recorded per cell |
| T14 | D9, D10, D11 | D9 count after first use (expect $FF); D10 write watch $CD23/$CD24; D11 none observable | effect recorded |

Defect tests document behaviour. They never justify a source change.

### 2.3 New tests: "safe under invariant" claims

| Test | Checks | Method | Pass | Fail |
| --- | --- | --- | --- | --- |
| T15 | I2 at $01:60D2 / $01:610A (L3/L4) | Emu: on each row-drawing frame log OAM (all 40 Y) and per-line mode-3 length; log LY at Audio_Update bank write/restore | OAM all zero; window ends before LY 95 | any visible object, or window >= LY 95 |
| T16 | I2 at $01:62C7 (L2) | Same; confirm ClearShadowOamAndTransferFar DMA precedes the loop | OAM zero; window ends ~LY 70, never at LY 144 with pending set | window reaches LY 144 with hSceneRowHdmaPending set (bank $06 mapped) |
| T17 | I3 FadeOut race | Emu: write watch hSceneLcdStepLimit with LY; flag stores where new L < hSceneLcdStepIndex | no such store; <= 7 $5EE0 calls per frame | store lands inside a sequence (count runaway calls) |
| T18 | I4 / w50 SVBK=2 trace; outcome per w113 | Emu and HW, recipe in section 5. Password start of a no-row level after a completed level-select game; hFF80 != 0 at $3B02; music $86; Start held so Func_3971 returns at V133-V140 | Emu: exec of $D310 with SVBK=2. Expected outcome by fixed scene: 6, 7, 9, 10 crash (MBC bank write such as ROMB0 <- $C0, SP corrupted, `rst $28` / `jp nz,$0024` / `ret` to $0000); 8 returns after 5x STOP inside $D120 (freeze until a button line goes low) with [$C700/$C701] overwritten | No STAT entry calls $D310/$D2F0 with SVBK=2 on any qualifying attempt (hazard not reachable under real timing) | Hit: document as the original defect, never fix. Record which outcome occurred; a different outcome from w113's table refutes the trace model, not the defect |
| T19 | I5 menu-grid fades (snap8 bank_01 2779, 2873 + 2874, 3104 -> 5146) and boot CaptureBgPalettesAndFadeToWhite | Emu: log the Func_3A52 SVBK=2 window per line, OAM Y per slot, and installed handlers. Confirmation only: w94/v129 already prove these safe under A2/A4 | window starts ~LY 32-33 at worst, ends by LY 62-66; no object above LY 72; boot STAT vector is the 1-byte `reti` at $C729 with IE=$01 | window reaches LY 72, 95 or the next VBlank with SVBK=2 (would refute A2/A4, not the code analysis) |
| T20 | Row-scene LYC=9 margin (w50, 9 M) | Emu: $86 call 130 frame, log mode-3 end and SVBK at LYC edge | SVBK = 1 at edge | SVBK = 2 at edge |
| T27 | I6 copy throughput (w108) | Emu: during any scene fade with the scene STAT handler installed, log LY at each BCPD write from Func_3A52 and each Func_02_46E1 iteration | 2-4 Func_3A52 bytes per visible line; 1 Func_02_46E1 iteration per line; none lost except on LYC and pending/$5EE0 lines | 0-1 bytes on a normal line, or a 46E1 line with 0 or 2 iterations |
| T28 | W50-7 cover condition (w108 Q2) | Emu, same frame as T18: log H (VBlank handler cost, 128 or 215 M) and A (Audio_Update cost) on V141 | SVBK=2 at the LY 1 LYC edge exactly when H+A >= 985 | mismatch with the H+A rule |

### 2.4 New tests: hardware assumptions

| Test | Checks | Method | Pass criterion |
| --- | --- | --- | --- |
| T21 | A2 mode-3 length | HW test ROM (separate, not the game): poll STAT mode per line in double speed with 0, 10 objects and window on/off; also log game scenes in Emu | 0 objects: mode 3 <= 172+SCX%8+~6 dots; measured table recorded |
| T22 | A3 GDMA rate | HW test ROM: DIV/timer delta across GDMA of 1, 8, 20 blocks in double speed | ~16 M per block (320 M for 20) |
| T23 | A5 STAT blocking on the LYC line | HW test ROM: enable LYC+mode-0 sources, count STAT IRQs on the LYC line and adjacent lines | one IRQ on the LYC line while LYC holds the line |
| T24 | A4 interrupt latency | HW test ROM: halt and non-halt wake, timer-stamped first handler instruction | dispatch 5 M, +1 M from halt; <= 6 M total |
| T25 | A6 LY 153 coincidence | HW test ROM: LYC=0, timestamp edge relative to VBlank | edge 0-8 M into line 153 |
| T26 | A1 speed switch | HW: KEY1 before/after STOP in Init and RestartGame; Emu: watch STOP sequence | KEY1 bit 7 = 1 after each switch; no frame in single speed |

T21-T25 need small standalone test ROMs; results apply to the game only via the models.
Run them on more than one CGB revision (CGB-CPU-B/C/E, GBA/GBA SP) where possible.

## 3. Diagnostic build

Tool: `tools/diag_bank_trap.py` (works on both the 1a57207 tree and the renamed tree).

- Copies src/, include/, assets/ to a temp work dir; src/ is never written (hashes checked).
- Builds the unmodified copy and requires SHA-1 `5078584e86c0b6f4687c424cc00bbd762ba6573a`.
- Replaces the trailing ROM0 zero fill ($3F39-$3FFF) with three checkers and a trap,
  and retargets the three RAM-image calls (only the 2-byte operands change):

| Site | RAM exec addr | Original target | Checker | Site byte |
| --- | --- | --- | --- | --- |
| STAT step | $C755 | $5EE0 WriteBgPalette7FromD3F8RomImage | DiagCheck_5EE0 $3F39 | 01 |
| VBlank split | $D14D | $5F26 WriteBgPalette7FromFF98RomImage | DiagCheck_5F26 $3F49 | 02 |
| VBlank HDMA | $C815 | $6580 StartSceneTileRowHdma | DiagCheck_6580 $3F59 | 03 |

- Checker: if [$7FFF] = $01, restore AF and `jp` the original target (AF, BC, DE, HL, SP unchanged; +19 M per call; +2 bytes stack).
  Otherwise trap: `di`, write $C000-$C004 = `D1 A6 site bank LY`, fill BG palette RAM with $001F, `ld b,b`, hang.
- Checks: size unchanged, no shipping symbol moved, exactly 95 bytes differ (89 in $3F39-$3F92, 6 operand bytes at $01:5BE4-5, $5DA4-5, $5E3B-C).
- Output: `build/diag/battletanx_diag.gbc` + `.sym`. Expected SHA-1 `27aea214475a791b88c4bce91dc56d8ac2003b13` (labels do not affect bytes).

Corrections carried from verification:
- Cartridge: MBC5 ($0147=$19), **1 MiB** = 64 banks ($0148=$05), no SRAM ($0149=$00). Not 4 MiB.
- **The WRAM signature $C000-$C004 is the reliable observable.** The red screen is advisory:
  the trap writes BCPD without waiting for VBlank, and T1 traps on visible lines where mode-3 writes are dropped.
- The trap overwrites wBootHardwareMode ($C000); power-cycle after a trap, do not soft reset.
- Header global checksum is stale (stored $E642); header checksum $014D is valid. Some flash tools warn; this is expected.
- The +19 M per checked call perturbs timing slightly. A clean T1-T3 run on diag must be followed by T5/T15-T20 on the shipping ROM.

## 4. Capture procedure

1. Build: `make check` (shipping SHA-1), then `python3 tools/diag_bank_trap.py`. Record both SHA-1s.
2. Emulator pass (first): load diag ROM in a cycle-accurate emulator. Set exec breakpoint on DiagTrap (from battletanx_diag.sym) and on the `ld b,b`. For each segment L2, L3, L4 play to completion; for T18 follow section 5. On a hit, save state and dump $C000-$C004, SVBK, KEY1, LY, hFF86, hSceneLcdStepPending, hSceneLcdStepIndex/Limit, stack.
3. Emulator timing pass: shipping ROM, with the watches of T4-T7, T15-T20; export per-frame logs (frame, LY, cycle, register written).
4. Hardware pass: flash diag ROM to an MBC5 flash cart (>= 1 MiB). Run on CGB and GBA. Record 60 fps video per segment with a frame counter.
5. On a hang on hardware: read $C000-$C004 with a cart/debugger that can dump WRAM (or a link-cable dumper). Without a WRAM dump, record the hang only as "possible trap, unconfirmed".
6. Hardware test ROMs T21-T26: run each, record raw counts per console revision.
7. Record results in docs/STATUS.md and INTERRUPT_BANKING.md: ROM SHA-1, emulator name and version, console model and revision, segment, inputs, raw dumps. Emulator results never count as hardware validation.

## 5. SVBK=2 reproduction recipe (T18)

Background. The scene STAT handler (`SceneStatHandler`, exec $C729) calls WRAMX code without
saving or forcing SVBK. On the LYC path with LY == hFF86 it calls $D310
(`WriteBgPalette7FromFF98`) and then $D120 (`EnableSceneWindow`). If this happens while
`LoadBackgroundPaletteFrame` (Func_3A52, $00:3A52) holds SVBK=2, those addresses hold the
32-frame fade cache built by LoadFixedSceneResources, and the CPU executes palette bytes (w113).

### 5.1 Preconditions (all required)

| # | Condition | Source | How to check |
| --- | --- | --- | --- |
| P1 | Password start (`wGameStartMode` $C6CD = 2) of a level with no row scene: `wLevelNumber` ($CA06) in {1, 2, 4, 5, 7, 8, 10, 11, 13, 14} (`LevelRowSceneFlags`, $01:6609, byte = 0) | w89 | read $C6CD, $CA06 at $3B02 |
| P2 | hFF80 != 0 on entry to the second InitSceneDisplay (PC $00:3B02, `call InitSceneDisplay`), so F0 = 142 | w50, w89 | read [$FF80] at PC $3B02 |
| P3 | The previous session ended with a completed level-select game, the mode-8 burst screen (`RunBurstEffectUntilButton`, $02:6306), and a return to the menu, with the level-select grid **not** reopened afterwards (the grid writes hFF80 = 0 through LoadScrollingScenePalette, LoadFixedSceneForRow and RunScrollingScene) | w89, v112 | |
| P4 | The burst residue is nonzero. `UpdateBurstEffectObjects` stores record+2, the **horizontal velocity**, in $FF80 (not X). Top-level objects have $05-$0A or $F9-$FB (never 0); a child's velocity is parent + `BurstChildOffsets` and can be 0 ($05+$FB, $08+$F8, $0A+$F6, $F9+$07). An empty final pass leaves an older value. So P2 normally holds but is not guaranteed | v112 | P2 check |
| P5 | Intro random music = $86 (`ld e,a` at $00:3AFE has A = $86). Chance 1/6 (RandomByte plus DIV) | w50 | A at PC $3AFE |
| P6 | Func_3971 returns (button held) on V133-V140, counted from the first Audio_Update of RunScrollingScene ($01:60D2) | w50 | count VBlanks from the first hit of $01:60D2 to Func_3971.return ($00:39A6) |
| P7 | On V141, H + A >= 985 M (H = VBlank handler cost 128 or 215 by `wVBlankCounter` parity; A = Audio_Update cost of $86 call 140: 830, 995 or 1015). H = 215 always qualifies; H = 128 needs A >= 995 | w50, w108 | timing log |

The no-lives route (game over, then a password start) also carries a residue only if a camera
cell draw happens on the countdown-expiry frame (v112). It is unconfirmed; do not use it.

Expected outcome by level (second scene = fixed scene, w113; deterministic per scene across
4096 swept entry states, entry state A=0, B=$80, D=$FF, E=LY, IME=0):

| Levels | Fixed scene | Expected observable |
| --- | --- | --- |
| 1, 2 | 6 | crash: write of $C0 to ROMB0 (bank 0 mapped at $4000), `ld sp,$0000`, ..., `rst $28` |
| 4, 5 | 7 | crash: `ld sp,$0001`, MBC writes, `jp nz,$0024` |
| 7, 8 | 8 | returns: $D310 runs to `ret nz` at $D31C; $D120 executes STOP five times before `ret nz` at $D2EE; CPU and LCD stop until a button line goes low; [$C700]/[$C701] (written through echo $E700) receive SP bytes; palette 7 / window update skipped |
| 10, 11 | 9 | crash: ROMB0 <- $C0, SP corrupted, `rst $28` |
| 13, 14 | 10 | crash: `ld sp,$0007 / ret nz` to $0000 with SP in ROM |

Where control goes after a crash, and how STOP interacts with double speed (KEY1) on scene 8,
were not traced. On scene 8 the held Start button may wake STOP at once, so the freeze can be
invisible on hardware.

### 5.2 Emulator watch

Use the shipping ROM (SHA-1 5078584e86c0b6f4687c424cc00bbd762ba6573a), not the diagnostic build:
the diag checkers cover only the $5EE0/$5F26/$6580 sites and add 19 M per checked call.

Setup:
1. Play a NEW game through at least level 0 and note the code shown on the mode-6 earned-code
   screen (`ShowEarnedPasswordScreen`). Pick a code whose level is in P1. Which level an earned
   code starts was not traced here; confirm it by reading $CA06 at $3B02 on a trial run. Prefer
   levels 7/8 (scene 8, non-crashing) for a first run, and 1/2 for a crash run.
2. From the main menu open level select (MenuState00 choice 2, MenuState05, MenuState06), confirm
   any level and complete it.
3. On the mode-8 burst screen wait until it accepts input and press a button; press again at
   the exit wait. Save state **S0** here, back at the menu.
4. From S0 go straight to password entry (MenuState00 choice 3). Do not open the grid. Enter the
   code from step 1.

Breakpoints and watches:
- B1: exec $00:3AFE: log A (music id). Off-target (A != $86): reload S0 and vary input timing,
  or, for a mechanism-only run, set A = $86 and mark the run "forced".
- B2: exec $00:3B02: log [$FF80], [$C6CD], [$CA06]. If [$FF80] = 0 (P4 failed), reload S0 and
  repeat step 3 with different timing. Forcing [$FF80] nonzero is allowed only in a run marked
  "forced"; it does not show reachability.
- B3: exec $01:60D2: start a VBlank count V at the first hit.
- B4: exec $00:39A6 (Func_3971.return): log V. Drive input with a script that holds Start from
  frame V = 131 + k, k = 0..9, one run per k from the save state taken at B3.
- W1: write $FF70 (SVBK): log PC, value, LY, cycle.
- B5 (the hit): exec $D310 or $D120 with ([$FF70] & 7) = 2. Log LY, [$FF86], [$FF80], SP,
  [$C700..$C701], stack bytes, and the last write to $2000-$2FFF.
- W2: write $2000-$3FFF (ROMB0/ROMB1) after B5: log PC and value (expect $C0 for scenes 6/9).
- B6: exec of opcode $10 (STOP) at PC in $D120-$D2EE (scene 8).
- Timing log for V141: VBlank handler cost H, Audio_Update cost A, LY at each SVBK write (T28).

Result: a B5 hit proves the hazard on that emulator. Compare the outcome with the table in
5.1. No hit over all k with P1-P6 met is evidence against the timing model, not proof.

### 5.3 Hardware

Hardware has no breakpoints, so the outcome table in 5.1 is the observable.
1. Use a CGB (and a GBA/GBA SP) with the shipping ROM on an MBC5 flash cart of at least 1 MiB.
   Record 60 fps video with a frame counter in view. Start the timer when the second intro
   scene appears.
2. Prepare as in 5.2 steps 1-4. P2 and P5 cannot be read on hardware, so each attempt has about
   a 1/6 chance from the music alone (identify track $86 by ear from an emulator recording).
3. Hold Start once about 133-140 frames (about 2.2-2.35 s) have passed since the start of the
   intro scroll. The window is about 8 frames wide, so repeat many times.
4. Each attempt consumes the precondition: once the level runs, DrawHudScore leaves hFF80 = 0.
   Every new attempt needs steps 2-4 again (level-select completion, burst screen, password).
5. Observable for levels 1/2, 4/5, 10/11, 13/14: hang, garbage screen, or a reset-like restart
   as the intro fade begins. For 7/8: a frozen picture until a button is pressed (may be
   invisible while Start is held), a wrong palette 7 / missing window on that frame.
6. If the cart or a debugger can dump WRAM, read $C700/$C701 after a scene-8 freeze and compare
   with an unaffected run. Without a dump, record the event as "possible hit, unconfirmed".
7. A hit on hardware is the original defect; document it and never change the source.

Results: none recorded yet.
