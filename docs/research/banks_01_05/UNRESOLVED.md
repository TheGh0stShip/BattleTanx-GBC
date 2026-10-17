# Unresolved

1. **Interrupt-time banking (not proven safe).** Three scene interrupt paths
   call bank-`$01` ROM without mapping bank `$01`:
   - the STAT image (`SceneStatHandler`, `$C729`) calls `WriteBgPalette7FromD3F8RomImage`;
   - the VBlank image (`SceneVBlankHandler`, `$C7F1`) calls `StartSceneTileRowHdma`
     (`$6580`) when `hSceneRowHdmaPending` is set;
   - `StepSceneWindowSplit` (`$D140`, run from VBlank) calls `WriteBgPalette7FromFF98RomImage`.

   They are safe only under this invariant: while these handlers are installed,
   IME = 1 and `[$7FFF] != 1`, no VBlank may arrive unless (`hFF80 != 0` or
   `hFF86 != 0`) and `hSceneRowHdmaPending == 0`, and no STAT may arrive unless
   `hFF80 != 0`, or `hSceneLcdStepPending == 0`, or (`hSceneRasterFxEnabled != 0`
   and index == limit).

   `LoadFixedSceneResources` (`$D000`) and `LoadScrollingScenePalette` (`$D160`)
   keep it by raising `hFF80` around their bank switches. These sites switch
   banks with `hFF80 = 0` and depend on timing:
   - `Audio_Update` (bank `$06`);
   - `ClearBackgroundPalettes` -> `ClearBackgroundPalettesImpl` (bank `$02`);
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
   - `SpawnBurstSpriteBlock` (`$02:635F`) and
     `AnimateBurstSpriteBlock` (`$02:63F4`);
   - `LoadFollowingSequenceTargetPosition` (`$03:5FBF`);
   - `UnusedStartRecordedPathFollow` (`$03:61FC`);
   - `GetLevelObjectHealthPenaltyNoLoad` (`$04:62F7`).

   `$02:4000-$406E` and the five bank-`$01` routines at `$7934-$7BC4` are now
   explicit instruction source (see completion/RUNTIME_SYSTEMS.md).
3. **Recorded-path following.** The feature cannot start through any recovered
   route. `wRecordedPath` is written only by `AppendRecordedPathWaypoint`, whose
   sole caller is `UnusedStartRecordedPathFollow`; that entry has no direct,
   table, stored-pointer, pushed-return, or resolved indirect caller. It is also
   the only routine that sets object `+$2D` bit 6. A source validator fails if
   either caller set changes.

   Each ring entry is X word, Y word, heading, then three unused bytes.
   `LoadAdjacentPathWaypointTarget` moves by exactly one eight-byte entry and
   reads only X/Y (`+0..+3`); the earlier claim that its reverse path read `+5`
   was incorrect. Bytes `+5..+7` are never read or written. The real anomaly
   is the nine `dec hl` in `SnapAndAdvanceRecordedPathWaypoint`, which read the
   previous entry's +3. This original defect is documented, not corrected.
4. **Bank `$03` sequences** (`tools/object_sequence_fields.py`):
   - **Unread fields.** Nothing reads +1, +2, +7 or the count byte. +1/+2 is the
     pixel distance to the next waypoint (one exception: level 3 slot 2
     record 2 stores 9, computed 8), and +7 always equals +6.
   - **Original terminal-record defects.** Level 3 slot 6 ends in action 5 and
     advances into `Level03ObjectSequence07`, interpreting
     `04 0C 30 00 3A 22 00 00` as a record targeting tile (0, `$3A`). Level 6
     slot 15 ends in action 0 and advances into the `Level07ObjectSequences`
     pointer table. Its pseudo-record begins with heading `$24`; object
     direction is masked to `$0F`, so it remains in the turn loop forever.

     These are dynamically reachable data defects, not merely theoretical
     reads. Level 3 spawn 14 and level 6 spawn 12 are persistent vehicles,
     start exactly at waypoint 0, and have all-passable (`$01`) cell-map routes
     through their last authored waypoint. Player destruction or interference
     can prevent an individual occurrence. The validator pins both routes and
     both exact overread records. Level 6's stored distance `$38` still suggests
     a lost third waypoint, but the missing intended data cannot be recovered.
   - **Unused sequences.** No spawn record uses (3, 11), (9, 1), (9, 2) or
     (10, 17). The complete spawn-to-sequence cross-check is enforced by
     `tools/object_sequence_fields.py`.
5. **Unread bytes**:
   - `Bank02Unknown5E80` (one byte); the following eight bytes form the
     bounded `Bank02UnusedPaletteRecord5E81`, but that record's purpose is
     unknown and it has no reader.
   - The copied `$D7CA`/`$D260` bytes are now explicit callerless `ret` stubs,
     not unread data; their intended call sites remain unknown.
6. **RAM**:
   - Bank `$01` writes `hLevelRegionTop` (`$FF92`) to `rROMB0` and clears
     `hLevelRegionX` (`$FF95`), which looks like reuse of HRAM.
   - The score BCD buffer at `$FFB0-$FFB4` overlaps
     `hSceneRowTileVramAddress`.
7. **Gameplay identities**: these are not assigned for the burst effect, the
    screen effect, the tracker pointer, the scenes and the pictures.
