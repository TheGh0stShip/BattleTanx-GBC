# Bank $03 per-level object sequences

## Result

Bank `$03:$4000-$5C10` is no longer an opaque binary range. It contains two
signed-vector lookup tables, fifteen per-level sequence blocks, and a final
table that selects the active block by `wLevelNumber`.

| Range | Bytes | Content |
| --- | ---: | --- |
| `$4000-$4013` | 20 | five four-byte signed-vector lookup rows used by `QuantizeSignedVectorDirection` |
| `$4014-$4017` | 4 | four quadrant offsets used by the same routine |
| `$4018-$5BF2` | 7,131 | fifteen contiguous per-level object-sequence blocks |
| `$5BF3-$5C10` | 30 | fifteen pointers selected by `wLevelNumber` |

There are 203 non-null sequences and 626 eight-byte records. Every byte in the
former 7,185-byte asset is now explicit RGBDS source.

## Level block format

Each of the fifteen blocks begins with 64 little-endian pointers, one for each
object slot. A null word means that slot has no sequence. Every non-null pointer
targets a counted sequence in the same level block:

```text
db point_count
rept point_count
    db field_0, field_1, field_2, field_3
    db field_4, field_5, field_6, field_7
endr
```

The sequence lists immediately follow the 128-byte pointer table, are ordered by
slot, and occupy the rest of the block without gaps or padding. The next level
pointer therefore proves the final sequence boundary.

`InitializeObjectSequenceState` selects the active level block, indexes its
64-entry table with an object field, and indexes the chosen sequence using
another object field. The update code at `$03:$5ED2` and `$03:$5FF2` repeats
the same lookup. The active table pointer is retained in
`wLevelObjectSequenceTable`.

`QuantizeSignedVectorDirection` takes signed eight-bit vector components in
`B` and `C`, folds their signs and relative magnitudes through the two lookup
tables, and returns the game's eight-bit direction value in `A`. Its two known
callers reduce that result to a 16-direction object orientation.

The adjacent `StateCheckTable` is independently indexed by `wLevelNumber`.
Its fifteen destinations are therefore named `Level00StateCheck` through
`Level14StateCheck`; their individual victory-condition semantics remain
unnamed where the tested WRAM flags have not yet been identified.

The eight-byte records are structurally proven, but not every field has a safe
gameplay name yet. Fields +3 and +4 are scaled by eight when establishing a
position. Field +0 is copied into an object field and also scaled by eight.
Field +2 only uses values 0-2, field +5 only uses 0, 2, or 5, and fields +6/+7
carry small parameters. These constraints are checked without assigning
speculative meanings.

## Validation

`tools/object_sequences.py` verifies:

- the two direction tables and their addresses;
- all fifteen level-table pointers;
- all 64 pointers in each level block;
- ordered, unique, in-bank sequence targets;
- each count byte against the following sequence boundary;
- the observed constrained record fields;
- all generated labels when a linked symbol file exists;
- removal of the former whole-range asset.

Four controlled corruptions cover the direction table, pointer-table gap,
sequence count, and record format. `tools/gen_object_sequences_asm.py` is the
one-time source generator; `src/level_object_sequences.asm` is authoritative.

## Unresolved

1. Behavioral names for all eight sequence-record fields.
2. The precise meaning of the 64 object-slot indexes.
3. Gameplay names for the individual sequences.
4. Physical-hardware validation of sequence behavior.
