# Gameplay identities: start modes, screens, joypad, objects, sounds, menu flow

Scope: a summary of research findings that a verifier has accepted, re-checked against `snap8`. Line numbers refer to `snap8/src` unless marked otherwise. Label names are the current primary names in `snap8/src`, after the w130 owner/role normalisation (27 renames) and the w131 removal of the `Jump_00DA`, `RAM_D56A` and `RAM_D62A` aliases. Where a label still has a legacy alias, the alias is given in parentheses at first mention. HRAM scratch bytes are given by their w126 time-shared alias where snap8 uses one at the cited site. Addresses are `bank:addr` from `snap8/battletanx.sym` (unchanged from snap7; the ROM matches SHA-1 5078584e86c0b6f4687c424cc00bbd762ba6573a). `InitMenuSystem` runs from WRAM: its symbol `01:D56A` is the execution address, not a ROM address; its ROM image is at `$01:49CB`. Statement-level provenance is in `w88/sources.json`; per-statement verdicts for earlier revisions are in `v109/verdicts.json` and `v119/verdicts.json`; the changes for this revision are listed in `d5/report.md`.

Status labels:
- **Proven**: the code path, call sites and bytes were checked by a research worker and accepted by a verifier.
- **Inferred**: names based on control flow, or claims rated "strong" rather than proven.
- **Unknown**: open questions.

No gameplay nouns are used. Vehicle types, item subtypes and projectile subtypes are referred to by their numbers.

---

## 1. Game start modes (`wGameStartMode`)

### Proven

There are exactly four writers, and no raw `$C6CD` reference exists:

| Value | Writer | Location | Reached from |
|---|---|---|---|
| 0 | `InitMenuSystem` (`xor a`) | bank_01.asm:1435-1436 (RAM image, exec `01:D56A`) | every menu entry |
| 0 | `ActivateMenuChoice` kind $0F (`ActivateMenuChoice_CheckType0F`) | bank_01.asm:1890-1894, `01:4CDD` | MenuState00 choice 1 (`:1326`). The store is skipped if the mode is already 2. |
| 2 | password accepted (`SubmitEnteredCode_Accepted`) | bank_01.asm:2573-2574, `01:5164` | `SubmitEnteredCode`, then MenuState03 choice 2 (kind $0F, `:1366`) |
| 1 | grid confirm (`HandleMenuState06Input_AStart`) | bank_01.asm:2794-2795, `01:52D7` | MenuState00 choice 2, then MenuState05 choice 2, then MenuState06. The confirm then calls choice 2 (kind $01, `:1380`). |

What each path does:
- **Kind $0F** (bank_01.asm:1887-1902) clears `wLevelNumber`, resets score and lives, and closes the menu. When the mode is 2, the `cp GAME_START_PASSWORD / jr z, ActivateMenuChoice_CloseMenu` at `:1891-1892` skips the mode store and the level, score and lives resets, but still closes the menu, so the level, lives and score decoded from the password (`:2561-2580`) are kept.
- **Kind $01** (bank_01.asm:1867-1885) clears `wMenuActive`, copies `wMenuState05Selection` to `wPlayerObjectType`, sets `wLevelNumber = wMenuGridRow*3 + wMenuGridColumn`, and resets score and lives.

Readers. Modes 0 and 2 behave identically at all five readers. Mode 1 differs at each one:

| Reader | Location | Mode 1 behaviour |
|---|---|---|
| `RunLevelCompleteFlow` (`00:0076`) | bank_00.asm:79-81 | Skips the level advance and returns to the menu |
| `RunLevelIntroSceneFlow` (`Func_3ABF`) | bank_00.asm:11152-11154 | Intro scenes skipped |
| `RunLevelExitScreenFlow` (`Func_3B12`, `00:3B12`) | bank_00.asm:11197-11204 | Mode 1 uses screen mode 8. Modes 0/2 use a scene, then mode $0C. |
| `RunLevelCompletionScreenFlow` (`Func_3B5A`, `00:3B5A`) | bank_00.asm:11245-11247 | Mode-6 screen skipped |
| Spawn record, kind 3 | bank_04.asm:179-181 | Keeps the menu-chosen `wPlayerObjectType` (`jp z, .advanceSpawnRecord`) |

Original oddities, documented and not fixed: `RunLevelExitScreenFlow` does nothing for values above 2 (unreachable, no writer stores one); kind $0F stores `ld a, GAME_START_NEW` after `InitMenuSystem` has already cleared the mode; the MenuState05 selection reaches `wPlayerObjectType` only through kind $01.

Constants (w13 GSM-6, accepted by v30, present in `include/banks_01_05_ram.inc:11-13` beside `wGameStartMode`):

| Constant | Value | Writer path |
|---|---|---|
| `GAME_START_NEW` | 0 | main-menu kind-$0F start |
| `GAME_START_LEVEL_SELECT` | 1 | MenuState06 grid confirm |
| `GAME_START_PASSWORD` | 2 | accepted password |

The patch replaces 11 operands (snap8 bank_00: 80, 11153, 11198, 11200, 11202, 11246; bank_01: 1891, 1893, 2573, 2794; bank_04: 180) and the SHA-1 still matches. The `xor a` at bank_01.asm:1435 is left as is, because it also clears `wMenuGridColumn`, `wMenuGridRow` and `wMenuScrollDirection`.

### Inferred
- The constant names describe the menu flow that writes each value (rated strong, not proven beyond flow).
- No on-screen text supports these names. The menu captions are graphics. `OptionsMenuEntries` (bank_01.asm:1336-1357) are the only text records in the menu tables.

### Grid level range (strong)
- `SetMenuGridRowWrapped` (bank_01.asm:2859, `01:5340`) wraps the row through 0-4 ($FF becomes 4, 5 becomes 0). `SetMenuGridColumnClamped` (bank_01.asm:2877) clamps the column to 0-2. The only direct writers of both variables are these two routines, `InitMenuSystem` (`:1437-1438`) and `HandleMenuState06Input_BExit` (`:2786-2787`), which store 0. `row*3+column` therefore covers 0 to $0E, which agrees with `LAST_LEVEL = $0E` (FLOW-1). Writes through the kind-$03 choice pointer (`menu_choice $01, $03, wMenuGridColumn`) were not traced, so this stays strong.
- `include/memory.inc:112` describes `wMenuGridColumn` as "wraps through 0..2"; the code clamps it.

---

## 2. Screen modes and screen packages

The second byte of each menu-state record is its screen mode. bank_01.asm:1550-1561 loads it and passes it to `ScreenTable_CallInit`. The table is `ScreenModeTable` (`01:47EC`, bank_01.asm:1306).

### Proven

| Mode | Package | Shown when | Evidence |
|---|---|---|---|
| 4 | bank $2B, `$2B:6E6C` (`PlayerTypeSelectScreen_LoadTiles`) | MenuState05 (`menu_state $05,$04`). Left/Right cycle `wMenuState05Selection` from 0 to 2 and load pictures 0-2. | bank_01.asm:1311, :1370, :1872-1873 |
| $0B | bank $2C, `$2C:55C4` (`LevelGridScreen_LoadTiles`) | MenuState06, the level grid. Confirm sets level = row*3+column and mode 1. | bank_01.asm:1318, :1377, :1874-1880, :2794-2795 |
| 8 | bank $2D (`LevelGridCompleteScreen_*`) | After a level started from the grid is completed (mode 1). Shows one picture, then `RunBurstEffectUntilButton` (`02:6306`). | bank_00.asm:63-86, :11205-11232; bank_02.asm:2426 |
| 6 | bank $2C (`EarnedCodeScreen_*`) | After a non-final level in modes 0/2. `ShowEarnedPasswordScreen` (`01:6CF0`) shows the earned code (5 characters), the score on row 4 and lives on row 7; `RunLevelCompletionScreenFlow` then waits for a button. | bank_00.asm:11239-11284; bank_01.asm:6942-6987 |
| $0C | bank $2A (`FinalLevelCompleteScreen_*`) | After level $0E in modes 0/2, following a scene. Shows the score on row 8 and lives on row 12. | bank_00.asm:81-83, :11200-11213; bank_01.asm:7146-7184 (`01:6E44`) |
| none (not in the table) | bank $2A, `NoLivesScreen_Run` (`FixedScreen2A_Run`, `Func_2A_7774`) | Only from `RunNoLivesFlow` (`00:00C7`), through `RunNoLivesScreenFar` (`00:3F28`). That flow is reached only when `wPlayerLives == 0` at bank_00.asm:236-238. | bank_00.asm:118-124, :11912-11920 |

Details:
- After mode 8, `ReturnToMenuAfterLevel` waits for a button a second time (bank_00.asm:89-114). The two waits are original and are documented only.
- The routine `ShowScreenMode12WithScoreAndLives` (aliases `ShowScreenMode12WithPasswordScoreLives`, `Func_01_6E44`) loads the code-screen tiles and palettes. Unlike mode 6 (`:6974-6985`), it does not call `UnpackPasswordChars` or `DrawPasswordEntryChars`, so no code characters are drawn. Its inner wait labels are now `ShowScreenMode12WithScoreAndLives_WaitVBlank1`/`_WaitVBlank2` (w130; formerly `ShowScreenMode12_WaitVBlank1/2`). The proposed name `ShowFinalLevelCompleteScoreLives` is not applied in snap8.
- **Bank $2E** (correction to w15):
  - The package routines and descriptor have no callers or references: `UncalledScreen2E_LoadTiles` (`Screen2E_LoadTiles`, `Func_2E_4000`), `UncalledScreen2E_Draw` (`Screen2E_Draw`, `Func_2E_4058`) and `UncalledScreen2E_Descriptor` (`Screen2E_Descriptor`).
  - The bank's graphics data is still used. The data under `MenuState05Picture2_Tiles` (alias `Screen2E_Tiles`), `Screen2E_TileMap`, `Screen2E_AttrMap` and `Screen2E_Palettes` is MenuState05 picture 2 in `MenuState05PictureDescriptors` (bank_01.asm:3793-3794, `01:596D`). The `Picture596D0_*` and `Picture596D1_*` data are pictures 0 and 1.
  - Only the routines are uncalled. The name `UncalledScreen2E_*` states exactly that.
- **Aux timer result counter**: `wLevelAuxTimerExpiredCount` (`$CD11`) is written at bank_03.asm:1538 and :1615 and at bank_04.asm:11. Its only read is at bank_03.asm:1613 in `UpdateAuxTimerExpired` (`03:640A`), which feeds its own increment. No 16-bit pointer load of `$CD11` exists.

### Inferred
- Structural screen-package names (29 labels; SHA-1 matches), primary in snap8 with the old `ScreenModeNN_*`/`FixedScreen2A_*`/`Screen2E_*` labels as aliases: `PlayerTypeSelectScreen_*` (mode 4), `LevelGridScreen_*` ($0B), `EarnedCodeScreen_*` (6), `LevelGridCompleteScreen_*` (8), `FinalLevelCompleteScreen_*` ($0C), `NoLivesScreen_*`, `UncalledScreen2E_*`.
- The no-lives name comes from control flow, not from what the screen shows.
- That aux record +8 has no other reader is rated strong. It was not exhaustively re-traced.

### Unknown
- **The bank-$2A no-lives screen on the code-accept path is unverified.** w15 cited baseline bank_01.asm:2575-2577 for a path where an accepted code carries 0 lives. Those lines (snap8 :2599-2601) are inside `AdvanceScoreThresholdIndex`, not a lives test.
- None of these screens calls `DrawEncodedText`, so the wording on the pictures cannot be proven from code.
- What the mode-8 burst sprites depict.
- What MenuState05 pictures 0-2 mean in gameplay.

---

## 3. Joypad bit layout

### Proven
`ReadJoypad` (bank_00.asm:1715, `00:0A59`) selects the direction group (P1=$20) and keeps it in the high nibble, then selects the button group (P1=$10), complements and merges it into the low nibble, and swaps the result, so directions end in the low nibble and buttons in the high nibble. It stores `wJoypadPressed = (old XOR new) AND new` and `wJoypadHeld`, and deselects both groups (P1=$30).

| Bit | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| Input | Right | Left | Up | Down | A | B | Select | Start |

This matches the `PADB_*` bit numbers and `PADF_*` masks in include/hardware.inc:63-78.

Readers:
- `wJoypadPressed` is written (bank_00.asm:1741) and never read.
- The chord `and PADF_START | PADF_SELECT | PADF_B | PADF_A` / `cp` the same mask (A+B+Select+Start, $F0) appears at bank_00.asm:10236 during gameplay, and in the VBlank RAM images at bank_01.asm:1714 and :4442 and at bank_02.asm:300.
- `cp PADF_START` at bank_00.asm:10229 means Start alone, with no other input, toggles `wPauseActive`.
- `UpdateMenuInputRepeat` (bank_01.asm:3131, `01:54FA`) builds `e` from `wJoypadHeld` and `wMenuPreviousButtons`. It reports new presses and auto-repeat: initial delay $14, repeat $02. `e` keeps the same bit layout. The menu dispatcher passes it unchanged to the state handlers.

---

## 4. Object identities

Checked by w14 and verified by v40 (all claims confirmed, two with correction or qualification). The renames are byte-neutral (SHA-1 matches) and are present in snap8 as primary labels, with the old names kept as legacy aliases.

### Proven

**Status-4 subtypes 0-9.** `DispatchStatus4PickupHandler` (`DispatchEntityHandler`, `01:44F4`) dispatches through `Status4PickupHandlerTable` (`EntityHandlerTable`, `01:44E0`, bank_01.asm:729-764) by the item's +$1E byte. It is reached only through `DispatchStatus4PickupHandlerFar` (`DispatchEntityHandlerFar`), called from `DispatchNearbyStatus4Pickup` (`DispatchNearbyType4Entity`). The only caller of `DispatchNearbyStatus4Pickup` is the `.resolveVehicleMovement` path (bank_00.asm:6463), so the collector is always a status-1 vehicle. The vehicle is passed in DE and the item in HL. Both must be on screen, the item must be status 4, and the two must be within 12 px on both axes (bank_00.asm:6725-6791).

| Subtype | Handler | Effect on collector | Sound | Restriction |
|---|---|---|---|---|
| 0 | `PickupRestoreQuarterHealth` | health + max/4, if below max | $4A | any status-1 vehicle |
| 1 | `PickupRestoreHalfHealth` | health + max/2, if below max | $4B | any |
| 2 | `PickupStartRenderHideTimer` (`PickupHandler02`) | +$27=$3C, +$28=0 (see section 5) | $53 | +$27=0 |
| 3 | `PickupBonusScore3000` | 3000 points, `wBonusPickupCount`++ | $54 | player only. A non-player touch frees the item with no reward. |
| 4 | `PickupExtraLife` | lives +1 unless lives = 9 | $49 | player only. A non-player touch leaves the item in place. |
| 5 | `PickupHomingProjectileCharges` (`PickupPowerupType2`) | powerup 2, 6 charges | $55 | +$29=0 |
| 6 | `PickupProjectileSubtype1Charges` (`PickupPowerupType1`) | powerup 1, 9 charges | $56 | +$29=0 |
| 7 | `PickupScreenEffectCharge` (`PickupPowerupType3`) | powerup 3 (`StartScreenEffect`), 1 charge; `wPowerupType3PickupCount`++ | $51 | +$29=0 |
| 8 | `PickupTriggerHudAlert` | HUD alert. The item's own +$1E is incremented to 9 and the item is kept; it reverts on frame-state reset. | $53 | collector +$26=0 |
| 9 | `PickupHandlerNoOp` | none | - | - |

Evidence: bank_01.asm:785-1015. When `RemoveObject` runs with a nonzero B, it drops a subtype-0 item with lifetime $F0 (bank_00.asm:1897-1906; the flag and type are the w126 HRAM aliases `hRemoveObjectSpawnFlag` and `hRemoveObjectType`, read at :1898 and :1908).

**Flag bit 3 (+$08, `OBJECT_VISIBLE_FLAG`)** is the on-screen flag. It is set at bank_00.asm:6139 after the X/Y view-bound tests and cleared at :6153. Readers include `DispatchNearbyStatus4Pickup`, `HandleObjectLevelBit3Cell`, `HandleObjectLevelBit1And2Cells`, `ResolveProjectileHit` (bank_00.asm:7579), `FindNearestVisibleObjectFacingSource` (bank_00.asm:8621) and the projectile render gate in `UpdateAllObjects`.

**Projectile subtype (+$20, `OBJECT_PROJECTILE_SUBTYPE_OFFSET`).** `SpawnVehicleProjectile` (`Func_2B86`) stores the shooter's powerup type (+$29) here. The single caller of `HandleObjectLevelBit1And2Cells` is the `.updateProjectile` path (bank_00.asm:6475); flag bit 3 only gates the handler (clear: `.freeDisabledObject`). The older comments that tied these states to flag bit 3 were wrong and have been corrected. `OBJECT_TYPE2_STATE_OFFSET` remains as a literal `$20` alias because tools/check_project.py checks its value.

`ProjectileSubtypeParameters` (`ObjectTypeParameterTable`, `$05:5100`) holds 3 bytes plus 5 zero bytes per row: `06 0F 50 / 04 06 B4 / 05 05 4B / 40 01 14`. `SpawnVehicleProjectile` copies them to +$22 (damage), +$1A (speed row) and +$21 (lifetime).

| Subtype | Map response | Damage | Speed row | Lifetime | Fire sound |
|---|---|---|---|---|---|
| 0 | starts a region transition on a bit-1 cell | 6 | $0F | 80 | $04 |
| 1 | rebounds on a bit-1 cell; transition on a bit-1 + bit-2 cell | 4 | 6 | 180 | $05 |
| 2 | none; homing (`InitializeHomingProjectileTarget`) | 5 | 5 | 75 | $1B |

- Row 3 cannot be reached: `UsePlayerWeaponOrPowerup` sends powerup 3 to `StartScreenEffect`, and it is the only caller.
- Fire sounds are queued only when the shooter's +$26 is 0.
- **The speed-class comment issue is not real.** The velocity reader does `dec a` on +$1A (bank_00.asm:6251-6257), so row $0F selects class 14, matching the bank_05.asm:104-105 comment. Class 15 is never used.

**Vehicle types.** Evidence: `InitializeObjectType` (bank_00.asm:2295-2354), `ObjectMaxHealthByType` (`00:0C3D`, `23 32 41 28`), and the score words at ROM $14EA0 (`F4 01 E8 03 B8 0B E8 03`).

| Type | Turn interval (+$23) | Max speed (+$25) | Fire interval | Health | Score | Graphics |
|---|---|---|---|---|---|---|
| 0 | 3 | 5 | 25 | 35 | 500 | bank $27 |
| 1 | 4 | 4 | 20 | 50 | 1000 | bank $28 |
| 2 | 5 | 3 | 30 | 65 | 3000 | bank $29 |
| 3 | 3 | 0 | 35 | 40 | 1000 | 2x3 BG metatile |

Fire interval = +$20 (`OBJECT_VEHICLE_ACTION_INTERVAL_OFFSET`), the reload of the timer `UsePlayerWeaponOrPowerup` tests.

**Spawn kinds** (bank_04.asm:80-330):

| Kind | Creates |
|---|---|
| 0 | type 1 |
| 1 | type 0 |
| 2 | type 2 |
| 5 | type 3 |
| 3 | player spawn; `wPlayerObjectType` = byte 7 (0-2) unless `wGameStartMode` = `GAME_START_LEVEL_SELECT` |
| 6 | persistent item; the subtype is in byte 7 |

Spawned vehicles start damaged: health = max - penalty from `GetLevelObjectHealthPenalty`. The penalty depends on skill; skill values above 1 behave as 2. Spawned vehicles get +$26=1 (bank_04.asm:272, 836). Kind 3 also makes a dead penalty write (`wUnusedPlayerSpawnHealthPenalty`).

**The player** is the object stored in `wPlayerObject`, created by `SpawnPlayerObject` (`00:35D7`) through `CreateObjectAtOrigin`/`InitializeObjectType`, which sets +$26=0. **The player is the only vehicle with +$26=0.** This holds among status-1 vehicles only; +$26 is not a vehicle field in other statuses. Writers of `wPlayerObjectType`: bank_00:1499, bank_01:1873, bank_04:183.

### Inferred
- Bank-$08 HUD names. snap8 names the three palettes loaded at bank_00.asm:1569-1584 `Bank08PowerupIcon1Palette`-`Bank08PowerupIcon3Palette` (copied to `wPowerupIcon1Palette`-`wPowerupIcon3Palette`, listed at bank_00.asm:9982), and the tiles at `$08:69B5` `Bank08HudAlertIconTiles` (tiles $5A-$5D, drawn with attribute $87 while `wHudAlertActive` is set, per bank_08.asm:556-557). Powerups 1-3 are those given by subtypes 6, 5 and 7, and the HUD alert is the one set by subtype 8. The link from each palette to a powerup kind rests on the bank_08 comments and the `wPowerupIcon*` table order; it was not re-traced through `DrawPlayerPowerupIcon` in this pass. The old `Bank08Arrow*`/`Bank08AlphanumericFont*` labels remain as legacy aliases.
- `PickupStartRenderHideTimer` is a deliberately neutral name: only the render suppression and the skipped proximity check are proven (section 5). Any further effect on enemy behaviour is not traced.
- The bytes $53-$5A after `PickupHandlerNoOp` may be an item tile list. No reader was found (strong).

### Unknown
- All gameplay nouns.
- What the item-8 alert means.
- Byte 6 of spawn kind 3 is never read.
- Not re-traced: the type-3 BG metatile path, and the spawn-data tallies.

---

## 5. Object record field roles

From w37, verified site by site by v57 (71 raw immediates, not the 75 w37 reported; each replacement correct). The record status of each site was established from callers: `UpdateAllObjects` (`Func_22ED`) dispatches on +$1D (bank_00:6407-6415); 1 = vehicle, 2 = projectile, 3 = effect, 4 = item.

### Proven

| Offset | Role | Constant (snap8 `include/object.inc`) |
|---|---|---|
| +$19 | 16-direction heading (low nibble), on every status | `OBJECT_DIRECTION_OFFSET` |
| +$1A | 1-based `ObjectVelocityTable` row; 0 = stationary, on vehicles and projectiles | `OBJECT_SPEED_OFFSET`; `OBJECT_VEHICLE_SPEED_OFFSET` is defined as an alias of it |
| +$1E | type for statuses 1, 3 and 4; owner pointer for status 2 | `OBJECT_TYPE_OFFSET`, `OBJECT_PROJECTILE_OWNER_OFFSET` |
| +$23 | vehicle turn interval / projectile bounce flag / effect OAM layout | `OBJECT_VEHICLE_TURN_INTERVAL_OFFSET`, `OBJECT_PROJECTILE_POWERED_OFFSET`, `OBJECT_OAM_LAYOUT_OFFSET` |
| +$27 | hide timer (vehicle); steering delay on projectiles | `OBJECT_VEHICLE_HIDE_TIMER_OFFSET`, `OBJECT_PROJECTILE_STEERING_DELAY_OFFSET` |
| +$28 | hide-reveal timer (vehicle) | `OBJECT_VEHICLE_HIDE_REVEAL_TIMER_OFFSET` |
| +$29 | projectile aimed-velocity flag (status 2); powerup type on vehicles | `OBJECT_PROJECTILE_AIMED_VELOCITY_FLAG_OFFSET`, `OBJECT_PLAYER_POWERUP_TYPE_OFFSET` |

- **+$1A**: `LoadVehicleForwardVelocity` (`Func_2241`) reads it (`add a, OBJECT_VEHICLE_SPEED_OFFSET` at bank_00.asm:6251, `dec a` at :6256, stored to `hVelocitySpeedIndex` ($FF80) at :6257); projectiles use the same routine when +$29 is 0. The shared constant is used at bank_00.asm:8170, 8283, 8384 and 10450. Vehicles cap it at +$25. Projectiles take it from `ProjectileSubtypeParameters` byte 1.
- **+$1E**: no site that uses it as a type runs on a status-2 record, so the owner meaning never collides.
- **Hide timers (+$27/+$28)**:
  - `PickupStartRenderHideTimer` sets +$27=$3C and +$28=0.
  - `UpdateVehicleTimersAndRemoveDestroyed` (`Func_104B`) decrements +$27 every 16 frames, and decrements +$28 only while +$27 is nonzero.
  - `UsePlayerWeaponOrPowerup` (`Func_0F98`) `.finishSuccess` sets +$28=2.
  - While +$27 ≠ 0 and +$28 = 0, `RenderObjectOrientationGraphic` (`Func_0DB6`) returns without drawing (`ld a, OBJECT_VEHICLE_HIDE_TIMER_OFFSET` at bank_00.asm:2427 and `ld a, OBJECT_VEHICLE_HIDE_REVEAL_TIMER_OFFSET` at :2433), and the bank-3 sequence code (bank_03.asm:243-262) (constants at :249 and :256) skips `CheckObjectNearPlayerBox` (:262) while the player's +$27 ≠ 0 and +$28 = 0.
- **Bounce double damage (+$23 on projectiles)**:
  - Spawn clears it. The Y bounce increments it; the X bounce stores L, which is always nonzero (original defect, already commented; same result).
  - `ResolveProjectileHit` (`Func_28C5`) copies +$23 to `hHitProjectilePowered` ($FFA1, written at bank_00.asm:7559) and doubles the damage (`sla b`, bank_00.asm:7643) when nonzero.
  - A nonzero `hHitProjectilePowered` (`ldh a, [hHitProjectilePowered]` at bank_00.asm:7583, and again at :7640 for the doubling) also skips the owner-exclusion test (bank_00:7583-7591), so a bounced projectile can hit its own shooter. Documented, not fixed.

**Applied constants.** The field constants proposed in `v57/fields_snap2.diff` and `w61/fields2.diff` (accepted by v91) are present in snap8 `include/object.inc`, and tools/check_project.py checks their values:

| Constant | Value | Uses in snap8 |
|---|---|---|
| `OBJECT_SPEED_OFFSET` | $1A | bank_00.asm:8170, 8283, 8384, 10450 |
| `OBJECT_VEHICLE_HIDE_TIMER_OFFSET` | $27 | bank_00.asm:2368, 2427, 2952; bank_01.asm:839, 846; bank_03.asm:249 |
| `OBJECT_VEHICLE_HIDE_REVEAL_TIMER_OFFSET` | $28 | bank_00.asm:2373, 2433, 2870, 2961; bank_01.asm:851; bank_03.asm:256 |
| `OBJECT_PROJECTILE_AIMED_VELOCITY_FLAG_OFFSET` | $29 | bank_00.asm:8196, 8275; bank_03.asm:1374, 1471 |
| `OBJECT_SEQUENCE_MOVEMENT_FOLLOWING` | $80 (value in +$38) | bank_03.asm:1063; bank_04.asm:154, 247, 261, 753, 811, 825 |
| `OBJECT_SEQUENCE_SPIN_FLAG` | $80 (bit in +$3C) | bank_03.asm:709 (`OBJECT_SEQUENCE_SPIN_FLAG \| 17`, the former `$91`) |

The old names `OBJECT_VEHICLE_PICKUP02_TIMER_OFFSET` and `OBJECT_VEHICLE_ACTION_FEEDBACK_TIMER_OFFSET` no longer exist anywhere in src/, include/ or tools/. The ROM assembled from snap8 matches SHA-1 5078584e86c0b6f4687c424cc00bbd762ba6573a.

### Inferred
- +$38 and +$3C. The snap8 comments (include/object.inc:100-101 and :111-116) describe +$38 as $80 (`OBJECT_SEQUENCE_MOVEMENT_FOLLOWING`) or a saved heading $00-$0F, and +$3C as idle (0), a wait countdown (bit 7 clear) or a spin count (bit 7 set, `OBJECT_SEQUENCE_SPIN_FLAG`). These meanings come from the v91-accepted field work; this revision checked only that the constants and comments are present and that the uses listed above load the stated values.
- Projectile +$29: the comment at include/object.inc:65-68 says 0 at spawn and 1 after `SetObjectVelocityTowardPoint` stores an aimed velocity. This revision checked that the constant is used at the four sites listed, not the full write path.

### Unknown
- +$24 on projectiles: zeroed at spawn, and include/object.inc:70 says it is never read (no reader found; not proven exhaustively). +$2C. +$3D-$3F: include/object.inc:117 records that no access was found apart from the power-on WRAM clear.
- bank_03:1064-1069 (`AimObjectAtPlayerFromProximity`, `Func_03_611C`) was reported to form D from E instead of the record page, so that `ld a,[de]` would read an unrelated address. At snap8 :1064-1069 the code is `ld [de], a / ld a, e / and $C0 / add a, OBJECT_TYPE_OFFSET / ld e, a / ld a, [de]`, with D taken from the `pop de` at :1041. Whether D is the record page there was not re-checked; it was not checked at run time either.
- bank_00:8384 (`add a, OBJECT_SPEED_OFFSET`) reads +$1A and immediately overwrites it (dead read).

---

## 6. Sound id reachability

From w55 (verified by v73) and w99 (verified by v119, which corrects three points below). Line numbers converted to snap8.

### Proven
- **There are 57 `Audio_QueueSound` call sites: 50 with an immediate id and 7 dynamic** (v119 correction; w99 said 58 = 51 + 7). A grep of `call Audio_QueueSound` in snap8 gives 20 (bank_00) + 32 (bank_01) + 4 (bank_02) + 1 (bank_06) = 57, and there is no `jp`/`jr` to it. All 57 are structurally reached; branch conditions are not audited.
- `StorePasswordCharWithSound` queues a fixed $0A, then the caller's `e` (push/pop de): the input mask from `UpdateMenuInputRepeat` (via `RunMenuLoop`, bank_01.asm:1598), not the password character.
- `HandleMenuState03Input` tests bits 7 to 0 in order, so the Down site (bank_01 2476, `HandleMenuState03Input_StorePrevChar`) sees $08-$0F and the Up site (2487, `HandleMenuState03Input_StoreNextChar`) sees $04-$07. An exhaustive simulation gives {$08,$09,$0A} / {$04,$05,$06} when opposing directions are never held together.
- **Opposing directions (v119 correction).** At the Down site, $0C (Up+Down), $0D (Right+Up+Down), $0E (Left+Up+Down) and $0F (all four) all need Up and Down together. `ReadJoypad` and `MenuStatHandler` do not filter opposing directions. None of $0C-$0F is queued directly anywhere else. $0D, $0E and $0F are reachable only this way; $0C is also sounded as a patch inside sfx $45, so it is not unreachable. w55/w99 named only $0E/$0F. No `sfx_patch` event uses $0E or $0F.
- The 7 dynamic queue sites: random music $81-$86 (bank_00 292, bank_00 11181 in `RunLevelIntroSceneFlow`, bank_01 2850 in `QueueRandomGridSounds`), `QueueVehicleActionSound` (`Func_1023`) {$04,$05,$1B} (bank_00 2913), constant $4F (bank_00 11596), the password site above (bank_01 6295), and the music $FE event (bank_06 79).
- **Music $80 trigger (v119 correction).** `RunBurstEffectUntilButton` (`02:6306`) queues $80 at bank_02.asm:2445-2446 whenever `wJoypadHeld` is nonzero (`ld a, [wJoypadHeld] / and a / jr z, .nextFrame`, :2442-2444). Any held input, directions included, triggers it; it is not limited to a button press.
- Music ids queued: $88 (init, `ReturnToMenuAfterLevel`), $83, $87, $82 (two sites), $81-$86 (three random sites) and $80. Nothing produces $89.
- The bank_06:79 queue never runs. The 16 $FE events are 8 `music_loop $FF` macros plus 8 unreached raw `db $FE, $FF`; every argument is $FF, so the event can only loop.
- Patches $01 and $16 occur only in `SfxSequence_0C` ($4C) and `SfxSequence_01` ($41). Neither sfx id is queued, there is no sfx chain command, and `Audio_PlaySound` is reached only through the queue drain.
- Latent defect: `Audio_QueueSound` returns early (`ret z`) after four pushes when `e`=0. No site passes 0.
- `v73/sound_ids_check.py snap8` prints "sound ids: ok" (re-run for this revision). It is not yet wired into tools/check_project.py.

### Inferred (strong)
- Tables: 37 patches, 25 sfx, 10 music. No reachable id is out of range.
- Never queued: patches $00 $02 $03 $1C $1F $20 (and $0D-$0F without opposing directions); sfx $40-$43 $47 $48 $4C-$4E $50; music $89. Strong only, because reachability is structural (v119): branch conditions and data-driven pickups were not audited.

### Unknown
- That an intact pad prevents Up+Down is a hardware assumption, not proven by code. Whether the opposing-direction cases were intended.
- Closed: the temporary `sound_sets.py` research script is not part of the
  project. `semantic_invariants.py` checks each dynamic sound call by source
  file, enclosing routine, ordinal within that routine, and preceding
  instruction, and rejects missing, duplicate, moved, or stale reviewed sites.

---

## 7. Menu flow (label work)

### Proven
Menu graph (bank_01.asm:1322-1380):

| State | Address | Screen mode | Choice 0 | Choice 1 | Choice 2 | Choice 3 | Choice 4 |
|---|---|---|---|---|---|---|---|
| 00 | `01:4855` | 0 | stay in MenuState00 | kind $0F (new game) | MenuState05 | MenuState03 | MenuState04 |
| 03 | `01:48F1` | 3 | MenuState00 | MenuState03 | kind $0F | - | - |
| 04 | `01:48AB` | 1 | MenuState00 | - | - | - | - |
| 05 | `01:4927` | 4 | MenuState00 | value `wMenuState05Selection` | MenuState06 | - | - |
| 06 | `01:495D` | $0B | MenuState05 | value `wMenuGridColumn` | kind $01 | - | - |

Kinds other than $01 and $0F copy record+2 into `wMenuState`. For this reason the former `Jump_01_4CFD` is named `ActivateMenuChoice_LoadStatePointer` (`01:4CFD`) and not "EnterSubmenu".

Buttons. The handlers test `e` from `UpdateMenuInputRepeat`.

| State | Up | Down | Left | Right | A | B | Start / Select |
|---|---|---|---|---|---|---|---|
| 03 (`01:507F`) | next character | previous character | cursor left | cursor right | submit | exit | ignored (`$50B1`) |
| 06 (`01:5287`) | previous column | next column | previous row | next row | start game (`$52D7`, sets mode 1) | exit | ignored |
| 00 | previous choice | next choice | - | - | activate (bit 4) | `ret` (`$4D70`) | `ret` (`$4D4C`) |
| 04 | previous choice | next choice | decrease option | increase option | jumps to the B handler | apply settings, choice 0 | ignored |

In state 06, Left/Right change the row variable and Up/Down change the column. This is the code as written, even though the pairing looks reversed. Left/Right are tested before Up/Down, so they take priority.

Original no-ops are kept and commented only: `$4E9B`, `$5361`, `$4E80` (dead `cp $02`; the `RuntimeCallbackTable` search has no bound), `$510C`, `$5322` (unreachable `db $C9`), `ld a,a`, and an unreachable clamp in `UpdateMenuCursorPosition`. In snap8 the corresponding "Original:" comments are at bank_01.asm:2182, 2201, 2501, 2835 and 2881; the individual addresses were not re-matched in this pass.

### Unknown
- Whether `AdvanceScoreThresholdIndex` always terminates. This depends on the end of `ScoreThresholdTable`, which was not checked.
