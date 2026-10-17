# Bank $03: object waypoint sequences

## Selection

`InitializeObjectSequenceState` looks up `LevelObjectSequenceTables`
(15 entries) by `wLevelNumber`. That index is proven 0-14 on every writer.
The table is cached at `$CD1C`, and each object stores its sequence slot in
`+$2D`. Slots used are at most 19, and bits 6-7 are flags.

## Record format (count byte + n x 8 bytes; no terminator)

| Field | Meaning | Status |
| --- | --- | --- |
| +0 | heading to the next waypoint (16-step units: 0 = -Y, 4 = +X, 8 = +Y, C = -X) | proven; reversing uses previous heading + 8 |
| +3/+4 | waypoint X/Y in 8-pixel tiles | proven (`LoadObjectSequenceTargetPosition`) |
| +5 | end action: 0/5 continue, 1 restart, 2 reverse, 3 wait (+6), 4 spin 16 headings, >= 6 as 3 | proven (`ApplySequenceRecordEndAction`); values 1/3/4 never occur |
| +1, +2, +7 | unknown | no consumer; +7 always equals +6 |
| +6 | wait argument | read only when +5 = 3, which never occurs |

## Runtime

- **Per-object update**: `UpdateObjectSequenceMovement` (via ROM0
  `UpdateObjectSequenceMovementFar`) turns the object toward the target
  heading.
- **Arrival**: `HandleSequenceWaypointArrival` snaps to the waypoint;
  `AdvanceObjectSequenceRecord` moves the point index forward, or backward
  when the reverse flag `+$31` is set.
- **Data**: 203 sequences, 626 records.
  - 201 sequences end with action 2 (patrol back and forth).
  - Level 3 slot 6 and level 6 slot 15 end in 5/0, and their forward target read
    runs past the sequence (UNRESOLVED.md item 5). Both exceptions are pinned by
    `tools/object_sequence_fields.py`, together with:
    - the unread distance field +1/+2;
    - +7 = +6;
    - the heading/axis rule;
    - the unreachable records.
  - Record 2 of level 6 slots 11, 12, 14 and level 8 slot 2 is unreachable,
    because the reversal happens at record 1.
  - Spawn records select 199 distinct sequences. Every selected slot exists;
    the four unselected sequences are level/slot (3,11), (9,1), (9,2), and
    (10,17). The two terminal exceptions are selected by level 3 spawn 14 and
    level 6 spawn 12. These relationships are enforced by the field validator.

## Level completion

- **`DispatchStateCheck`**: `jp hl` through `StateCheckTable` (15 entries,
  index `wLevelNumber`).
- **Handlers**: each tests one of `wLevelAuxType3Pending`,
  `wLevelAuxType2AllReached`, `wLevelAuxType4Active` or `$CD2A`. Some also
  require a pickup count (`wBonusPickupCount`, `wPowerupType3PickupCount`).
- **`AwardLevelCompletion`**: starts the completion countdown and adds 10,000
  points.

## Recorded path

The `$60AF-$67F9` routines are named in FINAL_FUNCTIONS.md.
- A 64 x 8 ring, `wRecordedPath`, holds X word, Y word and heading entries.
  The appender skips duplicate points.
- A follower snaps an object to the reached entry and moves forward or backward
  (`+$31`).
- Nothing reachable starts recording, so this feature is probably unused.
