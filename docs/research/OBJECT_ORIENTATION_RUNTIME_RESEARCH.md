# Object orientation runtime: banks $27-$29

Baseline `ae8696ef6adf28ad6984acbb64a9954d4cca854c`. Byte layout:
[`BANKS_27_29_RESEARCH.md`](BANKS_27_29_RESEARCH.md) (unchanged).

## Selector `[$FF80] + $27` (ROM0 `Func_0F43`)

`$FF80` = object field `+$1E`. It is set by `Func_0DB6`, which runs only for
objects whose type (`+$1D`) is 1 (bank `$00` dispatch at 6211, *verified*).
The copy is skipped when the value is 3.

Writers of `+$1E` by object type:

| Writer | Object type | Values |
| --- | --- | --- |
| `Func_0D0F` via `Func_0AD5` (allocates type 1) | 1 | bank `$04` immediates 0/1/2, or `[$CD08]`: 0, `wMenuState05Selection` (wraps 0-2), or a level-object byte (`$00-$02` in every type-3 record) |
| bank `$00`:7900 | 2 | parent pointer low byte |
| `Func_3090`, `$02:Func_02_45C1` | 3 | any / 3 |
| `Func_372E` | 4 | `b` |
| `$01:Func_01_4648` | 4 | `inc`, from 8 to 9 |

The increment runs only as `EntityHandlerTable` entry 8. That table is
dispatched by `+$1E` itself (*verified*), and entry 9 (`Func_01_467B`) does
nothing, so the increment cannot repeat. The dispatcher's object list is
gated on type 4 (bank `$00` ~6541).

An object's type is written only into a free slot (`Func_1FF5`), so no
live object changes type.

**Verdict:** for drawn objects (type 1), `+$1E` is 0-3. `Func_0F43`
selects only banks `$27-$29`, never `$2A` or above.

Residual risks, not analysed: `Func_1FF5` with no free slot (it returns with
HL past `$DFFF`, unchecked by `Func_0AD5`), and block copies of object
templates.

## Orientation `+$19`: 0-15

Every writer either masks with `and $0F` (bank `$00`:2098/2132/5800, bank
`$03`:325/2075), writes 0, copies from another object, or writes `[$CD1B]`.
`$CD1B` is level-object byte5 `& $7F`, which in the records is 0/4/8/12.

All 16 entries of `$05:ObjectOrientationTilePointers` and
`ObjectOrientationLayoutPointers` were checked by `tools/object_banks.py`:
- orientations 0-8 use frames 0-8 with the normal layout;
- orientations 9-15 use frames 7-1 with the x-flipped layout.

## Unread bytes

Nothing reads `$4510-$4511` or `$4518-$4BFF`. `Func_0F43` copies exactly 144
bytes from a pointer of at most `$4480`; the palette loader reads
`$4512-$4517`.

Interrupt handlers (`Audio_Update` from the LCD handler) read `$7FFF`
(`ROM_BANK_MARKER`) to save the mapped bank. Each of these banks holds its
own number there, so the save and restore is correct.

The potentially unsafe bank-`$01` scene LCD handler is not installed during
this path. `RunLevel` installs the bank-`$02` gameplay images before entering
the frame loop that renders these objects. Its LCD handler calls the ROM0
audio updater described above, its VBlank handler does not change the ROM
bank, and the pause path does not replace them. The handler copy sites,
interrupt mask, audio save/restore sequence, and bank markers are checked by
`tools/bank08.py` and `tools/object_banks.py`.

## Relocation

`$05:ObjectOrientationTilePointers` stores raw `$4000-$4480` words, and
bank `$05` is out of scope. All 27 frame labels are therefore pinned with
`ASSERT BANK(..) == $2x && .. == $xxxx`. Banks `$28`/`$29` also assert
`BANK = previous + 1`, because the selector is arithmetic. The shift test
confirms that moving frames stops the build.
