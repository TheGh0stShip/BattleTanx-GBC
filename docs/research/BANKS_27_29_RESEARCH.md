# ROM banks $27-$29: object orientation graphics

Rebuild SHA-1 is unchanged: `5078584e86c0b6f4687c424cc00bbd762ba6573a`.

## 1. Result

All three banks share one layout:

| Range | Bytes | Class | Content |
| --- | ---: | --- | --- |
| `$4000-$450F` | 1,296 | graphics | 9 orientation frames x 9 tiles (2bpp) |
| `$4510-$4511` | 2 | accounted, meaning unknown | one RGB555-valued word, no reader |
| `$4512-$4517` | 6 | structured data | OBJ palette colours 1-3 |
| `$4518-$4BFB` | 1,764 | accounted, not data | byte-identical copy of bank `$26` at the same offsets; no reader |
| `$4BFC-$7FFE` | 13,315 | fill | `$00` |
| `$7FFF` | 1 | marker | bank number |
| **Total** | **16,384** | | per bank |

Per bank: directly traced code 0, heuristic code 0, structured data 6,
graphics 1,296, fill 13,316 (including the marker), residue 1,764, and 2
bytes whose boundaries are established but whose meaning remains unknown.
No byte remains opaque or unbounded.

The banks differ only in their frame graphics, the `$4510` word and the
palette. The residue and fill are identical in all three.

**`$4518-$4BFF` is not sprite data.** It is a byte-for-byte copy of
`$26:$4518-$4BFB`, the middle of level 14's tile map. The same build
residue appears elsewhere:
- bank `$07` repeats bank `$06` at `$4008-$4BFB` after one malformed
  sound-patch slot;
- bank `$28` repeats `$27`, and `$29` repeats `$28`, over the same range.

Every copy ends exactly at `$4BFB`. The validator checks the equality against
bank `$26`. The four bytes `$4BFC-$4BFF` that the old asset carried are zero
fill.

## 2. Readers

| Routine | Bank selection | Reads |
| --- | --- | --- |
| ROM0 `LoadObjectPalettes` | immediates `$27`, `$28`, `$29` | `Bank2xObjectPalette` (`$4512`) through `Func_057D` with `b` = 0/1/2 (OBJ palette slot) and `c` = 1 |
| ROM0 `Func_057D` | — | writes OCPS = `$80 + 8*b`, writes colour 0 as `$0000`, then 6 bytes (colours 1-3) |
| ROM0 `Func_0F43` | `[$FF80] + $27` | 9 tiles (`ld b,$09`, 16 bytes each) from `$05:ObjectOrientationTilePointers[[$FF81]]` to `[de]` |
| ROM0 `Func_0F0C` | `$05` | 9 OAM entries from `$05:ObjectOrientationLayoutPointers[[$FF81]]`; y/x/tile offsets added from `$FF83`/`$FF82`/`$FF84`; attribute = record OR `$08` (VRAM bank 1) + `[$FF85]` |

**Bank-selection audit.** Every `rROMB0` write was checked: 201 in bank `$00`
and 23 in bank `$01`, including the RAM `LOAD` images. Only two places can map
`$27-$29`: `LoadObjectPalettes` (immediates) and `Func_0F43` (`[$FF80] + $27`).
- **`Func_0F43`'s only caller** is ROM0 `Func_0DB6` (`$0DB6`), the object
  draw path for object type 1.
  - `$FF80` = object field +`$1E`. The copy is skipped when it equals 3
    (`cp $03 / jr z`).
  - `$FF81` = object field +`$19`, stored masked with `and $0F` (ROM0 `$2115`
    path) or copied from another object. So 0-15, the exact table size.
- **Field +`$1E`** is set through `Func_0AD5` from immediates 0-2 or `[$CD08]`
  (0, the menu selection 0-2, or a level byte).
- **Exception:** `$01` code increments +`$1E` on a destruction path. Repeated
  increments are not excluded, so the `+$27` selector is **not proven bounded**.
  Even so, any reachable value only reads `$4000-$450F` of the selected bank.
- The interrupt handlers may read `$7FFF` (bank marker) while these banks are
  mapped; this was not checked.

No routine reads `$4510-$4511` or `$4518-$4BFF`. The highest orientation
pointer is `$4480`, and `$4480 + 144 = $4510`. The palette loader starts at
`$4512` and reads 6 bytes.

## 3. Orientation mechanism

- `$05:ObjectOrientationTilePointers` (16 words) holds `$4000 + 144*f` with
  f = 0-8 for orientations 0-8 and f = 7..1 for orientations 9-15.
- `$05:ObjectOrientationLayoutPointers` selects `ObjectLayoutNormal` for
  orientations 0-8 and `ObjectLayoutXFlipped` for 9-15.
- Each layout is 9 records of 4 bytes: y, x, tile, attribute, with y/x
  signed offsets (`-12`, `-4`, `+4`). The flipped records mirror x (`x' = -8 - x`)
  and set attribute bit 5 (x flip).
- So the reverse orientations reuse frames through lookup order plus OAM
  x-flip. There is no y-flip, and the graphics are not transformed.

## 4. Palettes

| Bank | OBJ slot | Colour 0 | Colours 1-3 | `$4510` word |
| --- | ---: | --- | --- | --- |
| `$27` | 0 | `$0000` (loader) | `$0040` #001000, `$0260` #009C00, `$03E5` #29FF00 | `$318C` #626262 |
| `$28` | 1 | `$0000` (loader) | `$7E51` #8B94FF, `$0000` #000000, `$60E8` #4139C5 | `$6739` #CDCDCD |
| `$29` | 2 | `$0000` (loader) | `$0006` #310000, `$1CFF` #FF3939, `$52BF` #FFACA4 | `$6739` #CDCDCD |

All words have bit 15 clear. The `$4510` word fits colour 0 of a
four-colour palette record whose first colour the loader skips. That's an
unproven reading, so the label stays `Bank2xUnknown4510`.

## 5. Source representation

- `include/object_banks.inc`, included by each bank file with a guard:
  - frame constants;
  - `orientation_frames` (one label per frame, sliced from the existing
    asset with `INCBIN path, offset, length`);
  - `bank26_residue` (an INCBIN slice of `assets/levels/level_14/tilemap.bin`);
  - `object_bank_end`.
- `src/bank_27.asm`-`src/bank_29.asm`: legacy labels kept, plus
  `Bank2xOrientationFrame0-8`, `Bank2xBank26Residue`, and ASSERTs on the
  layout.

New labels: `Bank27/28/29OrientationFrame0`-`8` (27), and
`Bank27/28/29Bank26Residue` (3). Retained labels:
`Bank2xOrientationTiles`, `Bank2xUnknown4510`, `Bank2xObjectPalette`.

## 6. Assets

- Added: none.
- Renamed: none.
- Retained: `assets/bank_27/orientation_tiles.bin`,
  `assets/bank_28/orientation_tiles.bin`, `assets/bank_29/orientation_tiles.bin`.
- Newly referenced from these banks: `assets/levels/level_14/tilemap.bin`
  (bytes `$518-$BFB`).
- Removed: `assets/bank_27/sprite_data_4518.bin`,
  `assets/bank_28/sprite_data_4518.bin`, `assets/bank_29/sprite_data_4518.bin`
  (the opaque residue + 4 fill bytes).

Asset sizes and SHA-1 values are checked directly against the verified ROM by
`tools/object_banks.py`.

## 7. Validation

`tools/object_banks.py` checks the recovered layout against `baserom.gbc`. It
runs from `check_sprite_bank_palettes` in `tools/check_project.py`.

20 negative tests, each rejected for its expected reason:
- **bank selection:** `add a,$27` changed;
- **bank identity:** palette loader bank immediate;
- **palette destination:** OBJ slot;
- **orientation table entry;**
- **frame boundary:** misaligned pointer;
- **tile count:** loop count;
- **layout record:** flip attribute;
- **layout pointer;**
- **palette value range:** bit 15;
- **`$4510` value;**
- **residue byte;**
- **non-fill byte;**
- **bank marker;**
- **coverage:** uncovered range and overlapping range;
- **reintroduced opaque blob;**
- **assets:** missing, wrong size, wrong hash;
- **symbol address.**

There are no terminators or sentinels in these banks; all counts are fixed
loop immediates (9 tiles, 9 OAM entries), which the validator checks.

`tools/extract_object_banks.py ROM build/objects` writes `frames.png`,
`orientations.png` (16 assembled objects with flips), `layout.csv`,
`palette.txt` and `info.json`. All of them round-trip to the source bytes.

## 8. Rejected hypotheses

- **`$4518-$4BFF` as sprite, metasprite or animation data.** It is an exact
  copy of `$26:$4518-$4BFB` and has no reader.
- **`$4510` as colour 0 actually loaded.** `Func_057D` writes `$0000` itself and
  the pointer starts at `$4512`.
- **Reverse orientations as separate graphics.** They are lookup reuse plus
  x-flip.
- **Fill starting at `$4C00`.** Fill starts at `$4BFC`; `$4BFC-$4BFF` are zero.

## 9. Suggested follow-up names

Recommended RAM names (not applied): `hObjectBankIndex`
(`$FF80`, bank = value + `$27`), `hObjectOrientation` (`$FF81`).
Recommended routine names: `CopyObjectOrientationTiles` (`Func_0F43`),
`WriteObjectOrientationOam` (`Func_0F0C`), `LoadObjPaletteColors1To3`
(`Func_057D`). All of these are subject to the bounds in section 2.

## 10. Unresolved

1. What the `$4510` word means (unread).
2. What the three banks represent in gameplay; the renders suggest vehicle
   variants, which is not evidence.
3. Whether the destruction-path increment of object field +$1E can push
   `$FF80` past 2 (it would select bank `$2B`+ in `Func_0F43`).
4. Whether interrupt code reads `$7FFF` while these banks are mapped.
5. Why the build left bank-`$26` residue here (the same pattern appears in
   bank `$07`); only the byte equality is proven.
