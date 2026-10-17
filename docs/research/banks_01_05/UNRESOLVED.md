# Unresolved

1. **Interrupt-time banking (not proven safe).** Three scene interrupt paths
   call bank-`$01` ROM without mapping bank `$01`:
   - the STAT image (`SceneStatHandler`, `$C729`) calls `Bank01RomImage_5EE0`;
   - the VBlank image (`SceneVBlankHandler`, `$C7F1`) calls `StartSceneTileRowHdma`
     (`$6580`) when `hSceneRowHdmaPending` is set;
   - `StepSceneWindowSplit` (`$D140`, run from VBlank) calls `Bank01RomImage_5F26`.

   They are safe only under this invariant: while these handlers are installed,
   IME = 1 and `[$7FFF] != 1`, no VBlank may arrive unless (`hFF80 != 0` or
   `hFF86 != 0`) and `hSceneRowHdmaPending == 0`, and no STAT may arrive unless
   `hFF80 != 0`, or `hSceneLcdStepPending == 0`, or (`hSceneRasterFxEnabled != 0`
   and index == limit).

   `LoadFixedSceneResources` (`$D000`) and `LoadScrollingScenePalette` (`$D160`)
   keep it by raising `hFF80` around their bank switches. These sites switch
   banks with `hFF80 = 0` and depend on timing:
   - `Audio_Update` (bank `$06`);
   - `Func_3960` -> `Func_02_46E1` (bank `$02`);
   - `ComputeSceneRowPointer`;
   - `StageSceneRowTiles`.

   Proving it needs cycle counting or an emulator watch: break on PC in
   {`$5EE0`, `$5F26`, `$6580`} with `[$7FFF] != 1`. `tools/banks_01_05.py`
   pins the set of such calls so a new one fails the check.
2. **Routines with no callers**:
   - `Bank01NoOpEntry` (`$01:42EE`, reached only from the uncalled
     `Bank1NoOpFar`);
   - `SubtractBCFromHL` (`$01:543E`);
   - `UnusedLoadScrollVariantForGridCell` (`$01:6243`);
   - `Func_02_635F`, `Func_02_63F4`;
   - `Func_03_5FBF`;
   - `UnusedStartRecordedPathFollow` (`$03:61FC`);
   - `Func_04_62F7`.

   Also `$02:4000-$406E` and three superseded instruction-shaped `db` blocks at
   `$01:7934`, `$01:79EC` and `$01:7AF0` (see FINAL_FUNCTIONS.md).
3. **Recorded-path following.** `wRecordedPath` is written only by
   `AppendRecordedPathWaypoint`, which is reached only from
   `UnusedStartRecordedPathFollow`. Whether the `+$2D` bit-6 path-follow branch
   can run at all is unknown.

   `LoadAdjacentPathWaypointTarget` reads byte `+5` of a ring entry going
   backward, and nothing writes that byte.
4. **Object fields** `+$26`, `+$27`, `+$28`, `+$32`, `+$33`, `+$38`, `+$39`,
   `+$3C`: partial or no proven meaning.
5. **Bank `$03` sequences** (`tools/object_sequence_fields.py`):
   - **Unread fields.** Nothing reads +1, +2, +7 or the count byte. +1/+2 is the
     pixel distance to the next waypoint (one exception: level 3 slot 2
     record 2 stores 9, computed 8), and +7 always equals +6.
   - **Level 3 slot 6** ends in action 5. Its forward target read runs into
     `Level03ObjectSequence07`, giving tile (0, `$3A`).
   - **Level 6 slot 15** ends in action 0. Its read runs into the
     `Level07ObjectSequences` pointer table, giving heading `$24`. The rotation is
     masked to `$0F`, so an object that gets there would turn forever. The stored
     distance `$38` suggests a lost third waypoint.

     Both slots are used by spawn records. Whether the objects survive to their
     last waypoint is not known.
   - **Unused sequences.** No spawn record uses (3, 11), (9, 1), (9, 2) or
     (10, 17). Spawn-record cross-checks are not yet in a validator.
6. **Bank `$04`**:
   - auxiliary mode 5 is unhandled;
   - `wPlayerSpawnHealthPenalty` (`$CD1A`) is written but never read;
   - the type-0/1 `+$39` swap on the respawn path is unexplained.
7. **Unread bytes**:
   - `Bank02Unread481E` (1,332);
   - the bank `$05` copies of bank `$04` (1,029);
   - `Bank01Unread77D6/785E/786C`;
   - `Bank02Unread5E80`;
   - two screen-effect gaps;
   - `$D7CA`/`$D260` single-`ret` data images.
8. **RAM**:
   - `wC8E6` is written, but its purpose is unknown.
   - `wCommittedMusicSetting` and `wCommittedControlSetting` are write-only.
   - `$CD26` only ever holds `$55`.
   - `$CD29` is a short-lived flag.
   - No writer was found for `$C6ED`/`$C6EE`.
   - Bank `$01` writes `hLevelRegionTop` (`$FF92`) to `rROMB0` and clears
     `hLevelRegionX` (`$FF95`), which looks like reuse of HRAM.
   - The score BCD buffer at `$FFB0-$FFB4` overlaps
     `hSceneRowTileVramAddress`.
9. **Gameplay identities**: these are not assigned for the burst effect, the
    screen effect, the tracker pointer, the scenes and the pictures.
