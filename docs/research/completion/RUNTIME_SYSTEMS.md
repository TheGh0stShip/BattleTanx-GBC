# Runtime systems: consolidated findings

Scope: runtime behaviour in banks $00-$04 and the screen and scene flows. Line
numbers refer to the current source tree (`src/`, `include/`). Addresses are
`bank:address`, and every byte quoted here was re-read from the base ROM. A
matching ROM does not mean these systems are understood. Each section keeps
three groups apart: **Proven** (from code paths, call sites and bytes),
**Inferred** (a strong reading that has not been proven) and **Unknown**.

## 1. Recorded-path subsystem (bank $03)

**Proven**
- `UnusedStartRecordedPathFollow` ($03:61FC, `bank_03.asm:1196`) has no route
  in.
  - The bytes `FC 61` occur once in the ROM, at $19:7675, inside level-8 tile
    data.
  - The instruction before the routine is `jp` (`C3 E5 62` at $03:61F9).
  - Bank 3's only `jp hl` is in `DispatchStateCheck` (`bank_03.asm:2500`).
    It indexes `StateCheckTable` ($03:685A), and $61FC is not one of that
    table's 15 entries.
- The routine also locks itself out. It returns when `wRecordedPathWriteIndex`
  is 0 (`bank_03.asm:1200-1202`). Level init clears that index
  (`bank_04.asm:17`, `:65`). The index's only other writer is the increment in
  `AppendRecordedPathWaypoint` (`bank_03.asm:2002-2005`), and that routine's
  only caller is the unreachable start routine.
- Each helper has exactly one reference:
  - Append is called from $03:621C.
  - `SnapAndAdvanceRecordedPathWaypoint` is reached through a pushed return
    (`ld bc` at $03:6689).
  - `LoadAdjacentPathWaypointTarget` is called from $03:67B8.
- Bit 6 of object +$2D (`OBJECT_SEQUENCE_SLOT_FLAGS_OFFSET`, `object.inc:75`):
  - Tested at `bank_03.asm:234` and `:1208`.
  - Set only by the `or $40` at `bank_03.asm:1210`.
  - The other writers store either a spawn slot (`bank_03.asm:48`) or the
    constant $80 (`bank_04.asm:253`, `:817`).
  - Every spawn record that takes the sequence path has byte 5 in
    $00-$11 or $13. None of these values has bit 6 set.
- Ring entry (8 bytes, 64 entries at `wRecordedPath`, $CDEF):

| Offset | Contents |
|---|---|
| +0/+1 | X word, from object +$14/+$15 |
| +2/+3 | Y word, from object +$17/+$18 |
| +4 | heading, from object +$19 |
| +5..+7 | never written; they keep the $FF from the level-init fill |

- `wRecordedPathWrapCount` ($CD16) is read only by its own increment
  (`bank_03.asm:2007-2010`). Its only `FA 16 CD` read is at $03:6615.
- When run in reverse, `SnapAndAdvance` reads the heading after nine `dec hl`
  (`2B` x9 at $03:6775-$677D, `bank_03.asm:2284-2292`). That lands on the
  previous entry's +3 (the Y high byte), not on its +4 (heading). See defect
  D1.
- The second run of eight `dec hl` (`bank_03.asm:2329-2336`) sits between
  `push hl` and `pop hl`, so it has no effect.

**Inferred**
- If forward following reached index 63, the next-entry read would land at
  $CFEF-$CFF2, past the ring.
- Reverse following cannot pass index 0, because the +$31 direction flag only
  ever holds 0 or $FF.

**Unknown:** what the feature was for.

## 2. Level cell bits and regions (ROM0)

**Proven** (the readers are in `bank_00.asm`)

| Bit | Reader | Effect |
|---|---|---|
| 0 | `ResolveObjectLevelBit0Movement` (`:6882`) | If the bit is clear, the axis is rejected and the old position is restored |
| 1 | `HandleObjectLevelBit1And2Cells` (`:7078`), only for objects with flag bit 3 | State 0: the object tries a region transition and is then freed. State 1, bit 2 clear: the axis is rolled back and the direction is mirrored |
| 2 | the bit-1/2 handler, `ConvertLevelCellBit2ToLookupState` (`:3460`) and `StartLevelCellLookupTransition` (`:3754`) | Region conversion (`and $B1 / or $81`) |
| 3 | `HandleObjectLevelBit3Cell` (`:7028`) and `ConvertLevelCellBit3ToLookupState` (`:3548`) | Conversion (`and $F1 / or $81`) |
| 4-5 | none | never tested or set |
| 6/7 | `GetLevelCellTileAndAttr` (`:5309`) | Render states set at run time |

- Objects with flag bit 3 test bit 0 at x offsets -10/0/+10 and y offsets
  -8/+2/+12 (`bank_00.asm:6505-6580`). That box is 20 by 20 pixels, but the
  comment at `:6501` says 20 by 16.
- Both converters set bit 0. A converted cell therefore becomes passable and
  no longer triggers any bit-1, bit-2 or bit-3 response.
- Value counts in the ROM cell maps, re-derived for all 15 levels:
  - bit 2 occurs only in $06 and $0F;
  - bit 3 occurs only in $08, $09, $0A and $0F;
  - no cell has bits 4-7 set;
  - level 6 has no cells with bit 1 or bit 2;
  - the per-level counts match the w10 table (for example, level 0:
    $00 410, $01 2124, $02 1293, $03 11, $06 60, $08 2, $09 120, $0F 76).

**Inferred**
- A "region" is the rectangle spanned by the run along the start row and the
  run down the start column. It is not a flood fill (w10-8).
- The rectangle statistics (911 rectangles, 5 with holes) were not re-derived
  here.

**Unknown**
- The gameplay identity of flag-bit-3 objects and of their states.
- What object +$21 and +$23 mean.
- Whether the `4F 16` words at $01:5FC1 and $01:5FF8 are pointers.

## 3. Spawn records (bank $04, 15 x 40 x 12 bytes)

**Proven** (from parsing `src/level_objects.asm` and reading `bank_04.asm`)

| Byte | Meaning | Values |
|---|---|---|
| 0 | kind; bit 7 means skip | 0:71, 1:113, 2:24, 3:15, 5:84, 6:241, padding:52 |
| 1-2, 3-4 | X and Y, little-endian words | |
| 5 | sequence slot (sequence path), or $80/$84/$88/$8C | sequence-path values $00-$11 and $13 |
| 6 | stored to scratch and overwritten before any read (see w14-4) | |
| 7 | type 6: subtype; type 3: player object type | |
| 8 | respawn count | 85 records are nonzero, all of type 0, 1 or 2 |
| 9 | respawn delay (`QueuePendingLevelObject`, `:515`) | 0, 4, 6, 12, 20, 21, 30 |
| 10 | powerup kind, clamped to 0/1/2 and stored at +$29 | 0, 1, 2 |
| 11 | charges, stored at +$2A | 0, 2, 3, 4, 5, 6, 8, 9 |

- Sequence path condition: `(b0&$80)==0`, `b0!=6` and `(b5&$80)==0`.
  - 199 records meet it.
  - Every one names a non-null slot, and no slot is used twice.
  - Four non-null slots are never named: (3,11), (9,1), (9,2) and (10,17).
- Each level has exactly one type-3 (player) record: record 0, or record 17 in
  level 14.
- All 84 type-5 records have byte 5 = $80.
- The type-6 path (`bank_04.asm:96-106`) reads only byte 7. The byte is passed
  to `Func_372E`, with C = $FF.
- The powerup charge is consumed at `bank_00.asm:2849-2865`:
  `ld a,[hl] / dec a / ld [hl],a / jr nz`. Only a result of 0 clears +$29.
  See defect D9.

**Inferred**
- The skill-penalty constants (w14-9) were not re-read byte by byte. Only the
  `wActiveSkillLevel` read in `GetLevelObjectHealthPenalty`
  (`bank_04.asm:415`) was checked.

**Unknown**
- The meaning of type-6 subtypes 0-8.
- What `wGameStartMode == 1` represents in play.

## 4. Auxiliary records and level completion

**Proven**
- Format, 8 ROM bytes:
  - +0/+1 X, +2/+3 Y;
  - +4/+5 extents;
  - +6 mode (0 means disabled);
  - +7 parameter.
- At run time each record is 10 bytes at `wLevelObjectAuxState` ($CD6F).
  Bytes +8/+9 are runtime state, and init clears them (`bank_04.asm:345-410`).
- Data: 37 of the 120 records are enabled.
  - By mode: 1 x5, 2 x1, 3 x25, 4 x5, 5 x1.
  - The only mode-5 link is level 5 record 1, which points to record 0
    (mode 2).
  - Level 14 record 1 has mode 0 but nonzero bytes.
- `TriggerAuxActivateLink` ($03:6517, `bank_03.asm:1790-1821`) computes the
  target as `idx*10+9` and writes 1 there without checking the target's mode.
- `MarkMatchingAuxTargetReached` ($03:6923, `bank_03.asm:2637`) begins
  `7B EA 23 CD 7A EA 24 CD`. It stores the object pointer in
  `wLevelObjectRecordIndex` and `wLevelObjectRespawnsLeft`, which overwrites
  both (D10).
- `wLevelAuxTimerExpiredCount` ($CD11) is used only by its own increment
  (`bank_03.asm:1593-1595`). Its single `FA 11 CD` read is at $03:640A, so the
  counter has no consumer.
- $CD2B-$CD32 have exactly one `EA` store each and no `FA` read.
- Each `LevelNNStateCheck` (`bank_03.asm:2513` onward) does `ld a,[flag]` and
  then `and a`, followed by a conditional `jp` to `AwardLevelCompletion`:

| Levels | Flag | Completes when |
|---|---|---|
| 00, 02, 10, 12, 14 | `wLevelAuxType4Active` | zero |
| 03, 04, 06, 11 | `wLevelAuxType3Pending` | zero |
| 01 / 08 / 09 | pickup count `cp` 6 / 8 / 7 first, then `wLevelAuxType3Pending` | zero |
| 05 | `wLevelAuxType2AllReached` | nonzero |
| 07, 13 | `wSequenceObjectsInState2Count` | zero (`ret nz`, then `jp`) |

- Every level contains the mode its check needs. The mode-3 counts in levels
  1, 8 and 9 are 6, 8 and 7, which equal their pickup thresholds.

**Inferred**
- The mode-3 records in levels 1, 8 and 9 are the pickup sites, cleared
  through the exact-coordinate match. Pickup coordinates were not compared.

**Unknown**
- Why mode-1 timers exist.
- Why +7 is nonzero on records whose mode never reads it.
- Where the level 14 record 1 residue bytes came from.

## 5. Object sequences (bank $03)

**Proven** (626 records in 203 sequences, parsed from
`src/level_object_sequences.asm`)
- Layout: a count byte, then n x 8 bytes:
  - +0 heading;
  - +1/+2 distance, a little-endian word;
  - +3/+4 tile X and Y;
  - +5 end action;
  - +6 argument;
  - +7 a copy of +6.
- +7 equals +6 in all 626 records.
- In every non-final record, +1/+2 equals 8*(|dX|+|dY|) to the next point.
  The one exception is (3,2,2), which stores 9 where 8 is computed. The high
  byte is never above 2.
- Actions in the data: 0 x351, 2 x205, 5 x70. Nonzero +6 values with these
  actions: 70 with action 5, 36 with action 0, 29 with action 2.
- `ApplySequenceRecordEndAction` (`bank_03.asm:677`) sends actions 0 and 5
  straight to `ObjectSequenceUpdateExit` (`:737`). They behave the same at
  run time.
- Object +$2D has three writers (section 1). Only the two
  `InitializeObjectSequenceStateFar` calls (`bank_04.asm:159`, `:758`) pass a
  variable slot. The four unnamed slots are unreachable: $03:469E, $03:508E,
  $03:509F and $03:5466.

**Inferred** (w13-1 and w13-2, from the reader listing; not re-traced line by
line)
- The count byte and the +1/+2 word have no runtime reader.

**Unknown**
- What the unread +6 values meant to the authoring tool.
- Why (3,2,2) stores 9.

## 6. Screen modes and bank $2E

**Proven**
- `ScreenModeTable` ($01:47EC, `bank_01.asm:1292`) holds 13 eight-byte
  entries followed by `$C9`. Entries 9 and 10 are byte-identical
  (`2B 00 DA 5B 32 5C 00 00`).
- Mode 8 runs from `RunLevelExitScreenFlow` (`bank_00.asm:11179`) when
  `wGameStartMode == 1`.
- `RunLevelCompletionScreenFlow` (`bank_00.asm:11225`) returns early in two
  cases: when `wGameStartMode == 1`, and when `wLevelNumber == $0E`. In all
  other cases it runs the mode-6 setup.
- Bank $2E routines: `Screen2E_LoadTiles` and `Screen2E_Draw`
  (`bank_2E.asm:8`, `:12`).
  - No code contains `3E 2E`. The only hit is in tile data at $31:4AB7.
  - The only `CD 00 40` is at $00:0343. It runs right after
    `ld a,$01 / ld [$2000],a`, so bank $01 is mapped.
- The `screen_load_tiles` macro (`screen_data.inc:17-24`) begins
  `ld hl,desc / ld d,$00`. Both values are overwritten before use (D11). In
  bank $2C the bytes are `21 CC 40 16 00` at $2C:4000.

**Inferred**
- Mode 9 is never selected. This depends on the list of `menu_state` records
  being complete (w17-3).
- The roles of modes 6 and $0C as the earned-code screen and the final screen.

**Unknown**
- Indirect paths into bank $2E, for example a `push`/`ret` sequence or a bank
  number held in RAM.

## 7. Scene selection

**Proven**
- The fixed loader always starts two HDMA transfers (`bank_01.asm:4615-4650`):
  - `HDMA5=$7F` to VRAM bank 1;
  - `HDMA5=$7E` from source+$0800 to VRAM bank 0.
- It then copies 8 bytes from palettes+$38 to $DC40, regardless of the
  palette count.
- `RunLevelExitScreenFlow` passes scene 0 for both indices, and only for
  `wGameStartMode` values 0 and 2 (`bank_00.asm:11179-11200`).
- Selection paths: `SelectLevelRowScene` (`bank_01.asm:5352`, gated by
  `LevelRowSceneFlags`, `:5786`), `SelectLevelScene` (`:5378`) and
  `RunMenuGridSceneScroll` (`:5123`).

**Inferred** (w18-3 to w18-7, not re-traced here)
- Every fixed index 0-10 and every scrolling index 0-$23 is reachable.
- The fourth-column zero slots in the three scroll tables are never read.

**Unknown**
- Whether confirming in menu state 6 sets `wLevelNumber`.

## 8. Unreferenced routines in banks $01 and $02

**Proven** (whole-ROM word scans)

| Routine | Evidence |
|---|---|
| `Bank1NoOpFar` $00:35C6 (`bank_00.asm:10161`) | no `C6 35` word in the ROM |
| `DrawObjectStatusCountsToWindow` $01:42EF (`bank_01.asm:414`) | no `EF 42` word in the ROM |
| `SubtractBCFromHL` $01:543E (`:2996`) | the word hits are inside data (w06-3) |
| `UnusedLoadScrollVariantForGridCell` $01:6243 (`:5118`) | every `43 62` word is in bank $04 or $1A |
| five former `db` blocks $01:7934-$7BC4 (`:7340`, `:7444`, `:7496`, `:7609`, `:7664`) | already explicit instructions in source, pinned by size ASSERTs |
| `UnreferencedBank02FrameRoutine` $02:4000 (`bank_02.asm:6`) | bytes $400C-$406D equal $00:0250-$02B1; $406E is `C9` |
| `SpawnBurstSpriteBlock` $02:635F, `AnimateBurstSpriteBlock` $02:63F4 | no `F4 63` word; both `5F 63` hits are in bank $18 data |

- `$C954` is written only by the dead wipe routines. There are exactly two
  `EA 54 C9` stores and no read.

**Inferred**
- The bank-$01 blocks are earlier forms of the routines that replaced them.

**Unknown**
- Computed `jp hl` targets cannot be fully ruled out by pattern scans.

## 9. Original defects (documented, not fixed)

| ID | Address | Bytes | Defect | Status |
|---|---|---|---|---|
| D1 | $03:6775-$677D | `2B` x9 | Reverse heading read lands one byte short (previous +3, not +4). Unreachable | new |
| D2 | $01:7975-$797A | `01 E9 6C 01 E9 6C` | `ld bc` repeated where `ld de,$6FB9` belongs, so DE is never reloaded. Unreachable | commented at `bank_01.asm:7337` |
| D3 | $02:6432 | `3E 04 83 5F 3E 00 8B 5F` | `adc a,e / ld e,a` should be `adc a,d / ld d,a`. Unreachable | new |
| D4 | $00:1451 | `FE 06 28 56 28 36` | Second `jr z` is dead. The result of the sequential retry is never tested, and flow falls into `.cellChanged` (`bank_00.asm:3691-3693`) | new |
| D5 | $00:26EE | `77 3C 7E` | X rollback stores L into +$23 (`bank_00.asm:7154`). The Y path at $00:273C uses `7E 3C 77` (increment) | new |
| D6 | $00:164F | `F5 ...` | `TestLevelCellBits2And3AtPixel` has no reference, and its `pop af` discards the result (w10-14, inferred) | new |
| D7 | $05:54CC data | Set2 indices 172-219 | Levels 3 and 4 read past Set2 into Set4 records 8, 10, 22, 23, 31, 49, 50, 54 and 55 ($5800-$54CC = 5*164) | new |
| D8 | $00:1DD8, $00:1DEB paths (`bank_00.asm:5359-5362`, `:5404-5407`) | `wLevelAnimationFrame` ($C8CB) | One counter, incremented by both render paths with masks `&7` and `&3`, so the chosen frame depends on draw order | new |
| D9 | `bank_00.asm:2857-2860` | `dec a / jr nz` | 103 type-0/1/2/5 records have kind != 0 and charges 0, so the first use wraps the count to $FF. Whether this was intended is unknown | candidate |
| D10 | $03:6923 | `7B EA 23 CD 7A EA 24 CD` | Two level-object variables are overwritten as scratch | new |
| D11 | $2C:4000 (macro) | `21 CC 40 16 00` | Dead `ld hl / ld d,$00` | new |
