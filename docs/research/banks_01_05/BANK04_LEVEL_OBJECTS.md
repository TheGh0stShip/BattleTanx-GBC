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
- **Deferred-spawn inconsistency**: ordinary and special initial creation pair
  runtime type 0 with fallback speed 5 and runtime type 1 with speed 4. The
  deferred respawn path keeps the runtime types but swaps only those two speed
  values. The source names and validator pin this original behavior rather
  than correcting it.

## Auxiliary records (15 x 8 x 8 bytes)

37 of 120 are enabled (byte 6 non-zero). An enabled record is copied into the
10-byte runtime state; bytes 8-9 are cleared. Byte 6 selects five modes named
in `include/level_objects.inc`: timer, linked region, pending region,
non-player-active, and activate-link.

Mode 5 is not an unhandled value. Level 5 auxiliary record 1 is the only mode-5
record; when the player enters it, the handler sets runtime byte +9 of linked
record 0 (selected by source byte +7). Record 0 is the level's sole mode-2
record, which then advances +9 from 1 to 2 when its non-player object reaches
the linked region. The validator pins this relationship and all mode counts.

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
