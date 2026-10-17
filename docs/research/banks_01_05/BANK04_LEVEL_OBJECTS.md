# Bank $04: level objects

## Spawn records (15 levels x 40 x 12 bytes)

- **Active**: 548 of 600. The other 52 are padding (byte 0 = `$80` and
  byte 5 = `$80`), skipped by `bit 7`.
- **Types**: 6: 241, 1: 113, 5: 84, 0: 71, 2: 24, 3: 15.
- **Respawning**: 85 records can respawn (at most 3 times, delay at most 30).
- **Byte 5**: with bit 7 clear, it is the index into the level's bank-`$03`
  sequence table.
- **Byte 6**: stored, then always overwritten by the skill setting
  (`wActiveSkillLevel`).
- **Runtime ownership flag**: ordinary level vehicles set
  `OBJECT_NONPLAYER_CONTROLLED_FLAG_OFFSET`; player-created vehicles leave it
  clear. It gates enemy action sounds, pickup handling, tracking, and
  auxiliary-region behavior.
- **Inconsistency**: on the respawn path, types 0 and 1 swap their `+$39`
  values relative to the initial load. This is recorded, not changed.

## Auxiliary records (15 x 8 x 8 bytes)

37 of 120 are enabled (byte 6 non-zero). An enabled record is copied into the
10-byte runtime state; bytes 8-9 are cleared. Bank `$03` treats byte 6 as a
mode 1-4. One record has mode 5, which no case handles.

## Respawn queue (20 x 3 bytes: index, respawns left, delay)

- **Filling**: `Func_0AF5` (object destroyed) adds an entry only when the
  object has respawns left.
- **Overflow**: a full queue silently drops the respawn. There is no flag
  and no duplicate check.
- **Update rate**: every 75 calls; a delay d gives d + 1 ticks.
- **Spawning**: a spawn happens only when the record position is outside the
  view box; otherwise it is retried next tick.

## Full object pool

`AllocateObjectRecord` returns A = 0 when the pool is full, but callers ignore
it. HL has then run past the pool to `$E000` (echo RAM), so the new object's
fields overwrite `$C000-$C03F`. The respawn path still treats the spawn as
done and frees the queue entry.

## Routines

- `GetLevelObjectHealthPenalty`: chooses a health reduction by record type and
  skill setting.
- `GetLevelObjectHealthPenaltyNoLoad`: has no caller.
