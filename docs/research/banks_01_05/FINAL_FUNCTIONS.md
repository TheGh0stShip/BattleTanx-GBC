# Final bank $01/$03 function entries

These are the 27 automatic entries that `make progress` still reported at frozen commit
`e7566ceb909e19f999fc95985a961d748c943fea`. Each one now has a behaviour name as a
companion label. The automatic `Func_XX_XXXX` label stays on the next line as a
legacy alias. Call sites in `src/` use the new name.

Each name was proposed from the code and its callers, then checked again
independently against `src/` and the base ROM bytes.

## Bank $01

| Entry | Name | Evidence | Callers |
| --- | --- | --- | --- |
| `$42EE` | `Bank01NoOpEntry` | single `ret` | ROM0 `Bank1NoOpFar` (`$35C6`), which has no caller |
| `$4A62` | `ClearPasswordEntryChars` | zeroes `wPasswordEntryChars` (5 bytes) | `InitMenuSystem` RAM image, `HandleMenuState06Input` |
| `$4ECF` | `SetOptionLabelBgPalette7Colors` | BG palette 7: colour 0 = `$4E91`, colour 3 = `$001F` (via `Func_0514`) | `DrawOptionsEntryLabel` |
| `$6243` | `UnusedLoadScrollVariantForGridCell` | `call LoadScrollVariantForGridCell` / `ret`; follows a `ret`, no reference | none |
| `$66F6` | `LoadPasswordScreenTilesAndCursor` | VRAM bank 1 tiles from `PasswordScreenTiles`, BG palettes, cursor RAM reset | `InitMenuStateScreen`, `ShowEarnedPasswordScreen`, `ShowScreenMode12WithPasswordScoreLives` |
| `$6746` | `LoadPasswordBgPalettes4To7` | `PasswordBgPalettes`, B = 4, C = 4 | `LoadPasswordScreenTilesAndCursor` |
| `$6751` | `LoadPasswordObjPalettes1And2` | `PasswordObjPaletteColours` into OBJ palettes 1 and 2 | `InitMenuStateScreen` |
| `$6789` | `BuildGlyphTileAttrBuffer` | glyph index (bit 7 = raw, else +2) into `PasswordGlyphTiles`/`Attributes`; interleaves tiles and attributes (OR `$0C`) in `wGlyphTileBuffer`. No bounds check | `Draw2x2GlyphTiles` |
| `$696E` | `InitPasswordCursorOamSlots8To11` | 4 tiles to `$8740`, OAM `$FE20-$FE2F` | end of `LoadMenuCursorSprites` |
| `$6A1D` | `InitPasswordCursorOamSlots12To15` | 4 tiles to `$8700`, OAM `$FE30-$FE3F` | end of `LoadMenuCursorSprites` |
| `$6E01` | `ClearScoreThenIncrementForever` | zero `wScore`, then a loop with no exit that increments it | ROM0 `Func_3BD5` (no caller) |
| `$6E44` | `ShowScreenMode12WithPasswordScoreLives` | mode `$0C` screen: password tiles and palettes, score row 8, lives row `$0C` | `RunLevelExitScreenFlow` path via `Func_3C08` |
| `$7BC5` | `FillSceneBgRowsWithTrailingTile` | fills BG rows from row 1 with the scene fill tile (`Func_3C90`) | the scroll-in pair below |
| `$7BE0` | `ScrollSceneInFromLeft` | SCX -= 8 for 20 frames; draws each incoming left column | `MenuState05SelectNext` |
| `$7C3F` | `ScrollSceneInFromRight` | SCX += 8 for 20 frames; draws each incoming right column | `MenuState05SelectPrevious`, `InitMenuStateScreen` |
| `$7CA2` | `ScrollSceneOutFillFromRight` | SCX += 8 for 20 frames; fills each incoming column with the fill tile | `MenuState05SelectPrevious` |
| `$7CEF` | `ScrollSceneOutFillFromLeft` | mirror of `$7CA2` | `MenuState05SelectNext` |

`$C94E` is now `wBgRevealCounter`. It is shared by the four scroll routines and
by `ShowPasswordRejection`, which counts 8 row draws with it and no scrolling.

`CycleObjectPalettes12` shares its address with
`InitPasswordCursorOamSlots8To11`. The routine loads sprite tiles and OAM; it
does not cycle palettes, so the older label looks misattributed (see
UNRESOLVED.md).

## Bank $03

| Entry | Name | Evidence | Callers |
| --- | --- | --- | --- |
| `$60AF` | `CheckObjectNearPlayerBox` | L = 3 if both \|dX\| and \|dY\| against the player are <= `$55`; pushes `$611C` as its return | `UpdateObjectSequenceMovement` |
| `$611C` | `AimObjectAtPlayerFromProximity` | continuation reached by the pushed return. Sets the wanted heading toward the player and may tail-jump into the shared fire path (`$62A8`) | pushed return only |
| `$61FC` | `UnusedStartRecordedPathFollow` | sets object `+$2D` bit 6, clears `wRecordedPathStarted`, appends a waypoint, copies the write index to `+$2E`, loads the target. Follows an unconditional `jp`; no pointer | none |
| `$62E7` | `SetObjectVelocityTowardPoint` | `+$29` = 1; signed 24-bit X/Y velocity in `+$0D-$12` | shared fire path `$62A8` in `AimObjectAtPlayerFromProximity`, after `UsePlayerWeaponOrPowerup` (`Func_0F98`) creates the projectile |
| `$6391` | `UpdateLevelObjectAuxState` | per-object auxiliary state update | ROM0 `UpdateLevelObjectAuxStateFar` |
| `$6429` | `CheckObjectAuxRegionTriggers` | updates auxiliary record `+8/+9` states; HL = object on trigger | `UpdateLevelObjectAuxState`, `UpdateObjectSequenceMovement` |
| `$655C` | `SubWordAbs` | DE = \|BC - DE\|, A = 1 if negative else 0; BC and HL preserved | `CheckObjectAuxRegionTriggers` (two calls) |
| `$6575` | `AppendRecordedPathWaypoint` | writes the `+$14` X word, `+$17` Y word and `+$19` heading to the 64 x 8 ring `wRecordedPath`; skips duplicates | `UnusedStartRecordedPathFollow` only |
| `$66BB` | `SnapAndAdvanceRecordedPathWaypoint` | snaps to the reached waypoint and advances `+$2E` along the ring | pushed return in the path-follow branch |
| `$67BF` | `LoadAdjacentPathWaypointTarget` | `+$34/$36` = X/Y of the next (`+$31` = 0) or previous ring entry | `SnapAndAdvanceRecordedPathWaypoint` |

Ring RAM: `wRecordedPathWriteIndex` (`$CD15`), `wRecordedPathWrapCount` (`$CD16`,
written only), `wRecordedPathStarted` (`$CD17`), `wRecordedPath` (`$CDEF`, `$200`
bytes; bank `$04` fills it with `$FF` at level start). The only writer of the
ring, `AppendRecordedPathWaypoint`, is reached only from
`UnusedStartRecordedPathFollow`, which has no caller. So recorded-path following
probably cannot start in the shipped game. The branch that tests `+$2D` bit 6 is
still present.

## Branch labels (separate from `make progress`)

49 `Jump_` labels whose role is clear were renamed: 24 in bank `$01` and 25 in
bank `$03`. Remaining automatic branch labels: bank `$01` 297 (321 before), bank
`$03` 89 (114 before). The tool `tools/add_function_names.py` applied all names
and branch renames, and it checks every new name for uniqueness.

## Rechecked regions

- **`Func_01_543E`** is `SubtractBCFromHL` and has no route in. The same bytes at
  `$03:52D2` sit inside the sequence data (`$4018-$5BF2`), not in code.
- **`$01:7934-$7980`, `$79EC-$7AA2` and `$7AF0-$7BC4`** have no reference, fall-through,
  table or pushed return. `$7938` is the operand byte of `ld hl, $C943`, and
  `$7AF1` decodes as `ld d, e` / `ret`. The first block is an earlier copy of
  `ShowPasswordRejection` with its `ld bc` duplicated. They read as superseded
  routine copies and stay as `db`.
