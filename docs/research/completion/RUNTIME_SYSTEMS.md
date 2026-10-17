# Runtime systems: consolidated findings

Scope: runtime behaviour in banks $00-$04, the menu and screen flows, and the
original defects found in them. Addresses are `bank:address`. Every quoted
byte was re-read from the base ROM. Line numbers refer to the current source
tree. Labels are the current primary names. A matching ROM does not mean
these systems are understood. Each section separates **Proven** (code paths,
call sites, bytes), **Inferred** and **Unknown**. Nothing here has been run on
hardware or in an emulator.

## 1. Object records: identities

Object records are 64 bytes in the pool at $D000. `UpdateAllObjects`
dispatches on the status byte +$1D: 1 vehicle, 2 projectile, 3 effect,
4 pickup (`bank_00.asm:6403-6411`).

**Proven**
- Flag bit 3 of +$08 (`OBJECT_VISIBLE_FLAG`) is the on-screen flag. The screen
  projection sets and clears it. It gates pickup collection, vehicle bit-3 cell
  conversion and the projectile map response. Off-screen projectiles are freed.
- Earlier documents called the projectile behaviours "states 0/1/2 of flag-bit-3
  objects". They are the **projectile subtype** at +$20
  (`OBJECT_PROJECTILE_SUBTYPE_OFFSET`). `SpawnVehicleProjectile` copies it from
  the shooter's weapon kind (+$29). `HandleObjectLevelBit1And2Cells` has a
  single caller, the projectile update.

| Subtype | Map response | Damage | +$1A | Lifetime | Fire sound |
|---|---|---|---|---|---|
| 0 | bit-1 cell: region transition, then freed | 6 | $0F | 80 | $04 |
| 1 | bit 1: axis rolled back, direction mirrored; bit 1+2: transition | 4 | 6 | 180 | $05 |
| 2 | none; homing | 5 | 5 | 75 | $1B |

- `ProjectileSubtypeParameters` ($05:5100) holds `06 0F 50 / 04 06 B4 / 05 05 4B / 40 01 14`.
  Row 3 is unreachable, because weapon kind 3 calls `StartScreenEffect`. The
  velocity reader does `dec a` on +$1A, so $0F selects class 14. The comment
  agrees. Fire sounds play only when +$26 = 0.
- Pickups (status 4). `Status4PickupHandlerTable` is indexed by +$1E. The collector is an on-screen
  status-1 vehicle within 12 px on both axes.

| Item | Handler | Effect | Sound | Collector |
|---|---|---|---|---|
| 0 / 1 | | health + max/4 / max/2 when below max | $4A/$4B | any |
| 2 | `PickupStartRenderHideTimer` | +$27 = $3C, +$28 = 0 | $53 | +$27 = 0 |
| 3 | | 3000 points, `wBonusPickupCount`++, aux target mark | $54 | player; others free it with no reward |
| 4 | | extra life when lives < 9 | $49 | player |
| 5 | `PickupHomingProjectileCharges` | weapon 2, 6 charges | $55 | no weapon held |
| 6 | `PickupProjectileSubtype1Charges` | weapon 1, 9 charges | $56 | same |
| 7 | `PickupScreenEffectCharge` | weapon 3, 1 charge | $51 | same; no +$26 check |
| 8 | `PickupTriggerHudAlert` | HUD alert; item becomes 9 | $53 | +$26 = 0 |
| 9 | | none | - | - |

- Vehicle types (turn interval / max speed / fire interval / health / score):
  0: 3/5/25/35/500; 1: 4/4/20/50/1000; 2: 5/3/30/65/3000;
  3: 3/0/35/40/1000. Types 0-2 draw sprites from bank $27+type.
- Spawn kinds: 0 creates type 1, 1 creates type 0, 2 creates type 2, 5 creates
  type 3, 3 is the player spawn, 6 is a persistent pickup with subtype byte 7.
  Skill values above 1 behave as 2 in `GetLevelObjectHealthPenalty`.
- The player is the object in `wPlayerObject`. It is the only status-1 vehicle
  with +$26 = 0.
- Destroying an enemy drops a type-0 pickup with lifetime $F0.

**Inferred**
- Type 3 is drawn as a 2x3 background metatile, not as sprites. This path was
  not re-traced.
- The bytes $53-$5A after the no-op pickup handler look like a tile list. No
  reader was found.

**Unknown:** gameplay names (tank, turret and so on), and what the item-8
alert means in play.

## 2. Object records: fields

**Proven** (each site was matched to its record status through callers)

| Offset | Status | Meaning |
|---|---|---|
| +$19 | all | 16-direction heading |
| +$1A | 1, 2, 4 | 1-based velocity-table row; 0 = stationary (`OBJECT_SPEED_OFFSET`) |
| +$1E | 1, 3, 4 | type. No type site runs on a status-2 record |
| +$1F | 1 / 3 | health / effect age |
| +$20 | 2 / 3 | projectile subtype / effect lifetime. The status-4 clear has no reader |
| +$21 | 2 / 3 | lifetime / frame table |
| +$23 | 1 / 2 / 3 | turn interval / bounce ("powered") flag / OAM layout pointer |
| +$24 | 2 / 3 | written at spawn and never read / layout pointer high byte |
| +$27 | 1 | `OBJECT_VEHICLE_HIDE_TIMER_OFFSET` |
| +$28 | 1 | `OBJECT_VEHICLE_HIDE_REVEAL_TIMER_OFFSET` |
| +$29 | 1 / 2 | weapon kind / `OBJECT_PROJECTILE_AIMED_VELOCITY_FLAG_OFFSET` |
| +$38 | 1 | $80 = following (`OBJECT_SEQUENCE_MOVEMENT_FOLLOWING`); $00-$0F = holding, low nibble = saved target heading |
| +$3C | 1 | 0 idle; bit 7 clear = wait countdown; bit 7 set (`OBJECT_SEQUENCE_SPIN_FLAG`) = spin |

- **Hide timers.** `PickupStartRenderHideTimer` sets +$27 = $3C and +$28 = 0.
  `UpdateVehicleTimersAndRemoveDestroyed` decrements +$27 every 16 frames, and
  decrements +$28 only while +$27 is nonzero. `UsePlayerWeaponOrPowerup` sets
  +$28 = 2 when it fires. While +$27 ≠ 0 and +$28 = 0,
  `RenderObjectOrientationGraphic` skips the vehicle and the bank-$03 sequence
  code skips `CheckObjectNearPlayerBox` for the player. "Hide" describes only
  these two effects.
- **Bounce flag.** Spawn clears +$23. Any wall bounce makes it nonzero.
  `ResolveProjectileHit` copies it to $FFA1 and doubles the damage
  (`sla b`) when it is set. A nonzero $FFA1 also skips the owner-exclusion test,
  so **a bounced shot can hit its own shooter** (D24).
- **Aimed-velocity flag.** `AimObjectAtPlayerFromProximity_SetVelToPlayer`
  passes the projectile returned in BC to `SetObjectVelocityTowardPoint`,
  which has only that one caller, and sets +$29 = 1. The only reader,
  `CalculateProjectileNextPosition`, calls `LoadVehicleForwardVelocity` when
  the flag is 0.
- **Kind 3 on a level vehicle.** Spawn byte 10 is clamped to 0-2. However,
  `DispatchNearbyStatus4Pickup` runs for every visible vehicle, and
  `PickupScreenEffectCharge` has no +$26 check, so a level vehicle with no
  weapon can collect kind 3. When it fires, `UsePlayerWeaponOrPowerup`
  returns NZ without spawning. HL is then the stale BC (H = target heading
  0-15), so the aim code writes +$29 and +$0D-$12 into **$0000-$0FFF**, the
  MBC5 RAM-enable range (D25). This is shown to be reachable in the code; it
  has not been run.
- **+$3C is never written by shipped data.** The 626 sequence records use only
  end actions 0, 2 and 5. Action 3 (set timer) and action 4 (spin) never
  occur, so +$3C stays 0. A spin step, when it happens at all, runs only when
  the heading equals +$2F or right after a turn step.
- Allocation (`AllocateObjectRecord`) writes only +$1D. No routine copies one
  record into another.

**Inferred:** +$3D-$3F have no accessor. Only the power-on clear of WRAM banks
1-7 touches them.

**Unknown:** +$2C beyond being the high byte of the last-attacker pointer.
The +$1A read at `bank_00.asm:8372` is overwritten at once; why it is there is
not known.

## 3. Recorded-path subsystem (bank $03)

**Proven**
- `UnusedStartRecordedPathFollow` ($03:61FC) has no route in. Its address word
  `FC 61` occurs only inside level-8 tile data at $19:7675. The instruction
  before it is `jp` (`C3 E5 62`). `$61FC` is not among the 15 entries of
  `StateCheckTable`, which is bank 3's only `jp hl` table.
- The routine also locks itself out: it returns while
  `wRecordedPathWriteIndex` is 0. The only increment is in
  `AppendRecordedPathWaypoint`, and that routine is called only from the
  unreachable start routine.
- The ring has 64 entries of 8 bytes at `wRecordedPath` ($CDEF): X word, Y
  word, heading, and +5..+7, which are never written and keep the $FF fill.
- `wRecordedPathWrapCount` ($CD16) is read only by its own increment.
- When run in reverse, `SnapAndAdvanceRecordedPathWaypoint` reads the heading
  after nine `dec hl`. That lands on the previous entry's +3 (D1). The later
  eight `dec hl` sit between `push hl` and `pop hl` and have no effect.
- `TestPointWithinBoxDistance` ($03:6065) returns L = $03 when both axes are
  within H and L = $00 otherwise. It never reports the axes separately.

**Inferred:** forward following past index 63 would read $CFEF-$CFF2, beyond
the ring.

**Unknown:** what the feature was for.

## 4. Level cells, spawn records, auxiliary records, sequences

**Proven**
- Cell bits: bit 0 = passable (`ResolveObjectLevelBit0Movement`); bits 1-2 are
  read only for projectiles (`HandleObjectLevelBit1And2Cells`); bit 2 and bit 3
  are converted by `ConvertLevelCellBit2ToLookupState` (`and $B1 / or $81`)
  and `ConvertLevelCellBit3ToLookupState` (`and $F1 / or $81`); bits 4-5 are
  never used; bits 6/7 are render state (`GetLevelCellTileAndAttr`). Vehicles
  test bit 0 over a 20x20 box; the comment says 20x16.
- Spawn records are 15 x 40 x 12 bytes: kind, X, Y, sequence slot, byte 6
  (stored and then overwritten), subtype or player type, respawn count, respawn
  delay, weapon kind (clamped 0-2) and charges. Each level has exactly one
  kind-3 player record. 199 records take the sequence path, and the four slots
  that no record names are unreachable.
- Auxiliary records: 8 ROM bytes, expanded to 10 at `wLevelObjectAuxState`
  ($CD6F); 37 of the 120 are enabled. `TriggerAuxActivateLink` writes to
  `idx*10+9` without checking the target's mode. Each `Level00StateCheck`-style
  handler
  tests one flag (`wLevelAuxType4Active`, `wLevelAuxType3Pending`,
  `wLevelAuxType2AllReached` or `wSequenceObjectsInState2Count`) and jumps to
  `AwardLevelCompletion`.
- Mode-1 aux timers have no effect. Their only result,
  `wLevelAuxTimerExpiredCount`, is read once, at $03:640A, by its own
  increment.
- Object sequences: 626 records in 203 sequences. +7 always equals +6. Actions
  0 and 5 both go straight to `ObjectSequenceUpdateExit`. Action values above
  5 would fall into the action-3 handler at $03:5F85, but none occur.

- Bit-2 scan timing: `ConvertLevelCellBit2RegionAtCell` runs from
  `UpdateScreenEffect`'s `.expire` path, which the main loop calls before
  `DrawHudStatus`. The per-cell award `AddToScore` makes no calls, and
  `DrawHudScore` is reached only through `DrawHudStatus` (main loop and
  `RefreshHud`). The scan and the HUD score draw are sequential, never
  nested, so their shared HRAM bytes ($FF90/$FF98) do not conflict.

**Inferred:** the count byte and the +1/+2 distance word of sequence records
have no runtime reader.

**Unknown:** the meaning of type-6 subtypes 0-8, and why mode-1 timers exist.

## 5. Joypad and menu flow

**Proven**
- `ReadJoypad` ($00:0A59) writes $20 to P1 (direction group), then $10
  (button group), and swaps. The result in `wJoypadHeld` and
  `wJoypadPressed` is bit 0 Right, 1 Left, 2 Up, 3 Down, 4 A, 5 B, 6 Select,
  7 Start. This is `PADB_*`/`PADF_*` in `hardware.inc`. `wJoypadPressed` is
  written and never read.
- `UpdateMenuInputRepeat` builds E bit by bit from `wJoypadHeld` and
  `wMenuPreviousButtons`, keeping that layout, with an initial delay of $14 and
  a repeat of $02. The dispatcher reaches the state handler through `jp hl`
  (word +3 of the `menu_state` record) without changing E.
- `and $F0 / cp $F0` (A+B+Select+Start held) is the soft-reset chord in
  gameplay and in the three VBlank RAM images. Start alone (`cp PADF_START`)
  toggles `wPauseActive`.
- `menu_state` byte +1 is the screen mode passed to `ScreenTable_CallInit`.

| State | Screen | Input |
|---|---|---|
| `MenuState00` | top menu | A activates; B, Start and Select return with no effect |
| `MenuState04` | options (mode 1) | A goes to the B handler; values are redrawn every frame |
| `MenuState03` | password entry | Up next char, Down previous, Left/Right move cursor, A submits, B exits |
| `MenuState05` | player-type select (mode 4) | Left/Right cycle `wMenuState05Selection` 0-2 |
| `MenuState06` | level grid (mode $0B) | Left/Right change the row, Up/Down the column (tested first), A starts the level, B exits |

- `ActivateMenuChoice` handles record kinds $01 and $0F and otherwise
  (`ActivateMenuChoice_LoadStatePointer`) copies record+2 into `wMenuState`.
  The target may be a parent state, so it is not always a submenu.

**Inferred:** the row/column pairing in state 6 looks reversed. The names
follow the variables the code updates.

**Unknown:** whether every level 0..$0E can be chosen on the grid. The row
bound in `SetMenuGridRowWrapped` was not checked.

## 6. Game start modes

**Proven**
- `wGameStartMode` ($C6CD) has exactly four writers: `InitMenuSystem` (0,
  through `xor a`); kind $0F (0 unless already 2); password accepted (2); and
  the `MenuState06` confirm (1).

| Value | Constant | Route |
|---|---|---|
| 0 | `GAME_START_NEW` | `MenuState00` choice 1 (kind $0F): level 0, score and lives reset |
| 1 | `GAME_START_LEVEL_SELECT` | `MenuState00` choice 2, then `MenuState05`, then `MenuState06` confirm; kind $01 sets level = row*3+column |
| 2 | `GAME_START_PASSWORD` | `SubmitEnteredCode` and `DecodePasswordBits` succeed, then `MenuState03` choice 2; kind $0F skips the reset |

- Mode 1 differs at five readers: it skips the level advance (`bank_00.asm:79`)
  and the intro scenes (`:11153`), uses the mode-8 exit instead of scene 0 plus
  mode $0C (`:11198`), skips the completion screen (`:11246`), and keeps the
  menu-chosen `wPlayerObjectType` (`bank_04.asm:179`). Modes 0 and 2 behave
  the same at every reader.
- `wSkipInitialMenuTransition` is set only in `Init` and is cleared on the
  first menu entry.

**Inferred:** the constant names come from the menu flow. No on-screen text
confirms them.

**Unknown:** what modes 0 and 1 are called in the game's own wording.

## 7. Screens

**Proven**

| Mode | Screen labels | Shown when |
|---|---|---|
| 4 | `PlayerTypeSelectScreen_*` (bank $2B) | `MenuState05`; pictures 0-2 come from bank $2E |
| $0B | `LevelGridScreen_*` ($2C) | `MenuState06` |
| 6 | `EarnedCodeScreen_*` ($2C), `ShowEarnedPasswordScreen` | after any non-final level in modes 0/2: code, score, lives |
| 8 | `LevelGridCompleteScreen_*` ($2D) | after a grid-started level; then `RunBurstEffectUntilButton` (sound $80, at least 255 frames) |
| $0C | `FinalLevelCompleteScreen_*` ($2A), `ShowScreenMode12WithScoreAndLives` | after level $0E in modes 0/2: score and lives only |
| - | `NoLivesScreen_*` ($2A) | `RunNoLivesFlow`, when lives are 0 at respawn; sound $83, 4 frames of 10 |

- `ScreenModeTable` ($01:47EC) has 13 entries. Entries 9 and 10 are
  byte-identical.
- `UncalledScreen2E_LoadTiles`, `UncalledScreen2E_Draw` and
  `UncalledScreen2E_Descriptor` have no caller. No
  code contains `3E 2E`. The bank's graphics are used, as pictures 0-2 through
  $01:596D.
- After mode 8, `ReturnToMenuAfterLevel` waits for a second button press.

**Inferred:** mode 9 is never selected. This depends on the list of
`menu_state` records being complete.

**Unknown:** what any picture shows. No screen uses encoded text, and the
names come from control flow. The no-lives path from an accepted password with
0 lives was not found.

## 8. Bank writes in the top-level loop

**Proven**
- `RunMenuAndLevelLoop` site 1 ($00:0179) is **needed**.
  `InstallMenuRuntimeCodeFar` reads `ROM_BANK_MARKER` after this write and
  restores it. `InitMenuSystem` ($D56A) and `RunMenuLoop` ($D62A) then call
  bank-$01 ROM directly; the first is `call ClearPasswordEntryChars` at $D59E.
  The entry bank varies (from `Init`, `ReturnToMenuAfterLevel` or
  `RunNoLivesFlow`). The operand is `BANK(ClearPasswordEntryChars)`.
- Site 2 ($00:0187) is **redundant**. `MenuLoopTop` already leaves $01 mapped,
  and `RunLevelIntroSceneFlow` writes $01 again before any banked read.
- The write in `LoadObjectPalettes` ($00:07A7) is **redundant**. The next pair
  writes `BANK(Bank27ObjectPalette)`.

**Inferred:** the write in `UpdateAllObjects` ($00:22F1) is redundant. Every
banked access in its call closure selects its own bank, but the `jp hl`
pickup handlers and the register data flow were not traced.

**Unknown:** none of this has been checked by running the code.

## 9. Stack leak

**Proven**
- The only SP write in the ROM is `ld sp,$C0FF` at $00:0150 (`31 FF C0`). A
  decode of all 23,603 code instructions finds opcodes $31, $F9 and $E8 only
  there.
- `RunMenuAndLevelLoop` does `call RunLevel` ($00:018C, `CD 92 01`).
  `RunLevel` never returns. `ReturnToMenuAfterLevel` and `RunNoLivesFlow`
  re-enter with `jp RunMenuAndLevelLoop`, so each return to the menu leaves the
  2-byte return address $0186 on the stack. Going on to the next level with
  `jp RunLevel` leaks nothing. Only `Init` (on boot or through `RestartGame`)
  resets SP.
- `AdvanceReturnToMenuCounter` has no caller. `HandleLevelEnd`'s
  `.spinForever` ($00:0074, `18 FE`) cannot be reached.
- Interrupt handlers push and pop in balance, and none of them enables
  interrupts, so interrupts do not nest.

**Inferred** (static upper bound)
- The peak depth is 74 bytes of main-line calls plus 38 bytes for the STAT
  handler, 112 in total. Pushes reach `wBootHardwareMode` ($C000) and the
  unbacked $BFFF after the 71st menu return in the worst case, after the 90th
  with no interrupt at the peak, and certainly by the 126th.
- After that, a restart passes the corrupted $C000 to `RequireCgbHardware`,
  which shows the GBC-only screen and halts.

**Unknown:** whether the deepest path and a STAT interrupt ever coincide, and
what open bus returns at $BFFF.

## 10. HRAM scratch and dead routines

**Proven**
- $FF80-$FFA1 is time-shared scratch. Each routine group now uses its own
  aliases in `memory.inc`, each tagged "(time-shared)": `hRemoveObject*`
  (`RemoveObject`), `hOrient*` (`RenderObjectOrientationGraphic` and three
  helpers), `hCenterViewX/Y` (`CenterLevelViewOnObject`), `hLevelCellIndex`,
  `hVelocitySpeedIndex/Direction`, `hProjectileAxisRolledBack`,
  `hHitScanObjectsLeft` and `hHitProjectilePowered` (`ResolveProjectileHit`,
  the $FFA1 of section 2), `hDirectionOctant`, `hFacing*` and
  `hHomingInitArgs`, `hSprite*`, and `hStatus4SpritePalette` (written by
  bank-$08 `SelectObjectSpritePalette`, read by `DrawObjectTypeMarkerSprite`).
  In every group each read follows a write in the same group, and no callee
  touches these bytes except `hScreenMapRowSkip` ($FFC0).
  `hFacingBestDirectionDiff`, `hHomingInitArgs` and `hSpriteType` are written
  and never read.
- Still raw: the `ClearGameMemory` start address, the bank-$02 burst routines
  on $FF80-$FF8A, and two stores in `RunLevelExitScreenFlow` (scene domain).
- Dead routines (no route in, checked per address, not per label):
  `CopyTilemapRows20`, `ClearHardwareOAM`, `ConvertU16ToPackedBcdFar` and
  `AddWordToBcd24`, `GetObjectType`, `ClassifyShadowOamCapacity`,
  `SetTextCursor`/`AdvanceTextRow`/`ClearTextColumn`,
  `AdvanceReturnToMenuCounter`, and `StepBackgroundPaletteColors` with
  `StepRgb555TowardTarget`. Also `UnusedStartRecordedPathFollow`,
  `UncalledScreen2E_*`, `TestLevelCellBits2And3AtPixel` and
  `AnimateBurstSpriteBlock` (sections 3, 7, 12).

**Inferred:** reachability is structural. Branch conditions, numeric db/dw
operands and arithmetically built pointers were not followed.

## 11. Routine-name corrections

**Proven** (each new name is primary; the old names listed remain only as
legacy aliases for tools)

| Old | Current | Reason |
|---|---|---|
| `DispatchEntityUpdateFar` | `UpdateNearestObjectTrackerFar` | single-target thunk |
| `DispatchEntityHandlerFar` | `DispatchStatus4PickupHandlerFar` | |
| `DispatchEntityHandler` | `DispatchStatus4PickupHandler` | jumps through `Status4PickupHandlerTable` |
| `DispatchNearbyType4Entity` | `DispatchNearbyStatus4Pickup` | tests status +$1D, not type +$1E |
| `ShowScreenMode12WithPasswordScoreLives` | `ShowScreenMode12WithScoreAndLives` | draws no password characters |
| `PickupHandler02`, `PickupPowerupType1/2/3` | names in section 1 | |
| `Bank08ArrowUpPalette`, `Bank08ArrowDownPalette`, `Bank08AlphanumericFontPalette` | `Bank08PowerupIcon1-3Palette` (and `wPowerupIcon1-3Palette`) | `DrawPlayerPowerupIcon` pairs each palette with the block after it: tile $4E (`Bank08InterfaceTiles68DD`), `Bank08ArrowUpTiles`, `Bank08ArrowDownTiles` |
| `Bank08AlphanumericFontTiles` | `Bank08HudAlertIconTiles` | 4 tiles at $5A-$5D, drawn with attribute $87 while `wHudAlertActive`; nothing reads them as a font |

`InitializeLevelEntityDispatcherFar` remains an alias of
`ResetNearestObjectTrackerFar`.

The bank-$08 comments now give the VRAM tiles as $4E-$5D (not $CE-$DD) and
the palette as "(value & 3) + 4". `Bank08ArrowUpTiles` and `Bank08ArrowDownTiles` keep
names based only on appearance. Branch labels were normalised to their owner:
`AimObjectAtPlayerFromProximity_*`, `SetObjectVelocityTowardPoint_*`,
`ShowScreenMode12WithScoreAndLives_*`. The aliases `Jump_00DA`, `RAM_D56A`
and `RAM_D62A` are removed; `RestartGame`, `InitMenuSystem` and `RunMenuLoop`
are the only names.

## 12. Original defects (documented, not fixed)

Every row has been checked against ROM bytes. The status of every row is
**documented, not fixed**. "Comment" means that an `; Original` comment is
present in the source.

| ID | Address | Bytes | Defect | Source note |
|---|---|---|---|---|
| D1 | $03:6775 | `2B` x9 | reverse heading read lands on previous +3, not +4; unreachable | comment |
| D2 | $01:7975 | `01 E9 6C 01 E9 6C` | `ld bc` repeated where `ld de` belongs in `UnusedPasswordRejectionVariant` | comment |
| D3 | $02:6436 | `3E 00 8B 5F` | `adc a,e / ld e,a` where `adc a,d / ld d,a` fits; D never advances (`AnimateBurstSpriteBlock`, unreferenced). The earlier address $6432 was the start of the pair | comment |
| D4 | $00:1455 | `28 36` (after `FE 06 28 56`) | second `jr z` never taken; flow falls into `.cellChanged` | comment |
| D5 | $00:26EF | `77` | X bounce stores L into +$23 instead of incrementing; L is nonzero, so the result is the same | comment |
| D6 | $00:16A6 | `F1 C9` | `TestLevelCellBits2And3AtPixel` (no reference) discards its result with `pop af` | comment |
| D7 | $05:54CC data | Set2 indices 172-219 | levels 3 and 4 read past Set2 into Set4 records | data only |
| D8 | $00:1DDC, $00:1E24 | `FA CB C8 3C E6 07` / `... E6 03` | one `wLevelAnimationFrame` counter stepped by two paths with different masks | comment |
| D9 | $00:1005 | `7E 3D 77 20 08` | 103 records with a weapon and 0 charges wrap to $FF on first use; whether intended is unknown | candidate |
| D10 | $03:6923 | `7B EA 23 CD 7A EA 24 CD` | `MarkMatchingAuxTargetReached` uses two level-object variables as scratch | comment |
| D11 | $2C:4000 (macro) | `21 CC 40 16 00` | dead `ld hl / ld d,$00` in `screen_load_tiles` | comment |
| D12 | $00:0074 | `18 FE` | `.spinForever` is unreachable | comment |
| D13 | $00:018C | `CD 92 01` | stack leak per menu return (section 9) | comment |
| D14 | $01:4B8E (RAM $C745) | `2A 7E` | scanline scroll: byte loaded by `ld a,[hli]` is overwritten | comment |
| D15 | $01:4C3A | `D6 01 30 01 AF` | clamp in `UpdateMenuCursorPosition` cannot run | comment |
| D16 | $01:4E81 | `FE 02 18 E6` | dead `cp $02`; `LoadOptionsSettings` search has no bound (latent) | comment |
| D17 | $01:4E9B | `20 00` | `jr nz` to next instruction | comment |
| D18 | $01:5112 | `18 00` | `jr` to next instruction | comment |
| D19 | $01:5322 | `C9` | unreachable extra `ret` | comment |
| D20 | $01:5361 | `3E 00 20 06` | `SetMenuGridColumnClamped`: `jr nz` never taken; correct by accident | comment |
| D21 | $01:54C7 | `1E 01 11 00 00` | dead `ld e,$01` | comment |
| D22 | $01:54E2 | `CB 4F` | `bit 1,a` writes LCDC back unchanged, so OBJ stays enabled on the grid; the State05 path uses `set 1,a` | comment |
| D23 | $01:54E6 | `18 00` | `jr` to next instruction | comment |
| D24 | $00:28FC | `F0 A1 B7 20 0A` | bounced shot skips the owner exclusion and can hit its shooter | comment |
| D25 | $03:62CD | `CD E7 62` | kind 3 on a level vehicle: velocity and +$29 written to $0000-$0FFF | comment |
| D26 | $01:5628 | `FE 01 28 04 FE 02 28 17` | `StepMenuScroll`: other directions fall into the $01 path; unreachable | comment |
| D27 | $01:5BE3 (RAM $D14D) | `CD 26 5F` | calls ROM-image address, not its WRAM copy $D310 | comment |
| D28 | $01:5DA3 | `CD E0 5E` | same, for $D2C0 | comment |
| D29 | $01:5C07 | `E0 A9 E0 A9` | `hSceneLcdStepPending` stored twice | comment |
| D30 | $01:6421 (RAM $D1D0) | `E0 8B 3C E0 8B` | first store overwritten | comment |
| D31 | $01:6CAF | `2E 04` | `ComputePasswordChecksum` clobbers L without saving HL; no caller reads HL | comment |
| D32 | $02:4131 (RAM $C76E) | `38 00` | `jr c` to next instruction | comment |
| D33 | $02:45E3 | `01 52 54` | dead `ld bc` in `SpawnDirectionalOffsetEffect` | comment |
| D34 | $03:5F59 | `2B` x8 then `E1` | `dec hl` run undone by `pop hl` | comment |
| D35 | $03:5FC6 | `28 00` | `jr z` to next instruction | comment |
| D36 | $03:5FA5 | `FE 02 20 11` | redundant `cp $02`; branch never taken | none |
| D37 | $03:6023 | `20 00` | `jr nz` to next instruction | comment |
| D38 | $03:60BD | `06 55` | every case loads b = $55 | comment |
| D39 | $03:6151 | `FE 55` | flags overwritten before any test | comment |
| D40 | $03:62EC, $03:62F2 | `30 01 2F` | absolute difference without `inc` gives \|d\|-1 | comment |
| D41 | $03:6375 | `7E 2F 22` | velocity negated as -v-1 | comment |
| D42 | $03:647C, $03:64C2 | `FE 0C` | negative side uses fixed $0C, positive side the entry width/height | comment |
| D43 | $03:6749 | `20 00` | `jr nz` to next instruction | comment |
| D44 | $03:69B1, $03:69D4 | `2E 00` | `ld l,$00` after `ret nz` has no effect | comment |
| D45 | $01:55F6 | `0E 14` | one repeat timer shared by all buttons; only Right reloads it on a fresh press; intent unknown | behaviour |
| D46 | $00:2E0E | `F0 83 B8 38 33 F0 82 B9 38 2E` | `FindNearestVisibleObjectFacingSource` compares the 16-bit distance byte by byte; best $0100 rejects candidate $00FF | candidate |
| D47 | $00:1988, $00:19E2 | `FA 09 CA D6 15 5F 3E 00 DE 00 16 00` / `FA 0A CA D6 13 ...` | `CenterLevelViewOnObject` discards the borrow (`ld d,$00`); a level narrower than 21 or shorter than 19 cells gets a large maximum origin; whether any level is that small is unchecked | candidate |

D46-D47 are candidates: no source comment yet.

**Not counted as defects:** the second OAM write in
`SnapPasswordCursorSprites` without a new STAT wait is a timing hazard that
has not been demonstrated. The password decoder's extra shift loses no bits.
The two button waits after mode 8 may be intended. The `ld a,a` no-ops in
`DrawOptionsEntryValue` and `AdvanceScoreThresholdIndex` have no exact
addresses here. An `adc a,$00` defect reported at $03:611C was rejected: the
bytes are not there.

**Unknown:** whether the `ld e,$00` in State05 ($01:54C2) is read by any
caller.
