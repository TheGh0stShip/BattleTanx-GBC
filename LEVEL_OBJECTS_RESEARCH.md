# Bank $04 per-level object initialization data

## Result

The former opaque range at bank `$04:$4000-$601B` consists of three exact,
contiguous structures:

| Range | Bytes | Content |
| --- | ---: | --- |
| `$4000-$5C1F` | 7,200 | fifteen tables of 40 twelve-byte object initialization records |
| `$5C20-$5FDF` | 960 | fifteen tables of 8 eight-byte auxiliary records |
| `$5FE0-$601B` | 60 | fifteen pairs of pointers to the two tables above |

`InitializeLevelObjects` selects one pointer pair using `wLevelNumber`. It
iterates exactly 40 initialization records, creates or configures objects, and
passes the two little-endian coordinate words at offsets +1 and +3 to the
object-position helper. Records whose first byte has bit 7 set are skipped;
all 52 such records use one identical padding form. The remaining 548 records
use type values 0, 1, 2, 3, 5, or 6.

The same routine then visits exactly eight auxiliary records. It tests byte +6;
when nonzero it copies all eight bytes into one of eight ten-byte WRAM entries
and clears the final two bytes. There are 37 enabled auxiliary records. Their
later consumer is the bank-$03 routine at `$6923`, but their gameplay purpose
and field meanings are not yet established.

The later object-management path is now named from its verified mechanics.
`QueuePendingLevelObject` records a level-object index in a 20-entry WRAM
queue. `UpdatePendingLevelObjects` services that queue every 75 calls, and
`TrySpawnPendingLevelObject` reads the corresponding 12-byte initialization
record and creates it once its coordinates enter the checked camera window.
`AbsoluteDifferenceBCDE` is the shared unsigned 16-bit difference helper used
for both axes; it returns the magnitude in `DE` and the original sign in `A`.

## Representation and validation

`src/level_objects.asm` writes all 600 initialization records, all 120
auxiliary records, and all 30 pointers explicitly. `tools/level_objects.py`
checks the derived addresses, fixed record counts and widths, padding records,
observed type ranges, source labels, and removal of the former binary asset.
Three controlled corruptions cover a directory pointer, padding record, and
auxiliary control field. `tools/gen_level_objects_asm.py` is the one-time
generator; the assembly source is authoritative.

## Unresolved

1. Behavioral names for most fields in the twelve-byte initialization record.
2. The gameplay purpose and field meanings of the eight-byte auxiliary record.
3. Gameplay identities for individual records.
4. Physical-hardware validation.
