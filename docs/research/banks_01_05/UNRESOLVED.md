# Unresolved

1. **Interrupt-time banking.** The scene VBlank image calls `Func_01_6580`,
   and the scene STAT image calls `Bank01RomImage_5EE0`, without mapping bank
   `$01`. These are safe only if bank `$01` is mapped whenever they fire.
   During `LoadFixedSceneResources` a graphics bank is mapped, and `hFF80 = 1`
   blocks only the STAT path. Not proven either way.
2. **Address-named routines (27)**, including `Func_01_4ECF`, `Func_01_66F6`,
   `Func_01_6746`, `Func_01_6751`, `Func_01_6789`, `Func_01_696E`,
   `Func_01_6A1D`, `Func_01_6E44`, the `$01:7BC5-$7CEF` scroll helpers, and
   ten bank-`$03` entries. Their roles are not proven.
3. **Routines with no callers**:
   - `Func_01_42EF` (`DrawObjectStatusCountsToWindow`);
   - `Func_01_543E`;
   - `Func_01_6243`;
   - `Func_02_635F`, `Func_02_63F4`;
   - `Func_03_5FBF`, `Func_03_61FC`;
   - `Func_04_62F7`.

   Also `$02:4000-$406E` and the `db` blocks at `$01:7938`, `$01:79EC` and
   `$01:7AF1`, which decode as code but are never referenced.
4. **Object fields** `+$26`, `+$27`, `+$28`, `+$32`, `+$33`, `+$38`, `+$39`,
   `+$3C`: partial or no proven meaning.
5. **Bank `$03` sequences**: record fields +1, +2, +7 have no consumer.
   Level 3 slot 6 and level 6 slot 15 may read past their end.
6. **Bank `$04`**:
   - auxiliary mode 5 is unhandled;
   - the meaning of the 512-byte `$FF` fill at `$CDEF` is unknown;
   - `wPlayerSpawnHealthPenalty` (`$CD1A`) is written but never read;
   - the type-0/1 `+$39` swap on the respawn path is unexplained.
7. **Unread bytes**:
   - `Bank02Unread481E` (1,332);
   - the bank `$05` copies of bank `$04` (1,029);
   - `Bank01Unread77D6/785E/786C`;
   - `Bank02Unread5E80`;
   - two screen-effect gaps;
   - `$D7CA`/`$D260` single-`ret` data images.
8. **RAM**: `wC8E6` (written, purpose unknown); `wCommittedMusicSetting` and
   `wCommittedControlSetting` are write-only.
9. **Gameplay identities**: these are not assigned for the burst effect, the
   screen effect, the tracker pointer, the scenes and the pictures.
