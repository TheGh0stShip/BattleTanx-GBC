# Relocation

## Raw references

- **Own-bank ROM pointers in banks `$01`-`$05`**: none remain. all 107 raw
  operands now use labels: new statement labels, split data lines, typed blob
  regions, or existing labels. The one raw `$4E91` is an RGB555 colour
  for `Func_0514`.
- **Cross-bank pointers in bank `$01`/`$05`**: now symbolic:
  - 32 scrolling-scene descriptor entries, with `BANK()`;
  - 11 fixed-scene and 13 screen-mode bank bytes;
  - the `$596D` descriptors;
  - `$01:7981`;
  - `ObjectOrientationTilePointers`.
- **Raw ROM0 references into banks `$01`-`$05`** (`src/bank_00.asm` not
  edited), each pinned with `ASSERT BANK(..) == .. && .. == ..`:
  - `$01:418F` `ScoreThresholdTable`;
  - `$01:6609` `LevelRowSceneFlags`;
  - `$05:4600` `ObjectVelocityTable`;
  - `$05:6358` `ScreenEffectSteps`.

  Bank `$05`'s fixed layout asserts (`LevelRecordPointers == $4300` and
  others) are kept.

## Shift tests (`tools/shift_test_01_05.py`, part of `make check`)

| Case | Mode | Result |
| --- | --- | --- |
| menu-state record `MenuState03` | fail-safe | pin at `$6609` stops it |
| entity callback target | fail-safe | pins at `$418F`/`$6609` |
| fixed-scene descriptor table | fail-safe | pin at `$6609` |
| password glyph table (after the pinned tables) | relocate | 39 labels, 31 pointer words |
| cross-bank pointer table target (bank `$2B` package) | relocate | 38 labels, 44 words |
| level record table | fail-safe | bank `$05` layout asserts |
| object animation frame table | relocate | 157 labels, 75 words |
| bank `$03` object sequence | relocate | 357 labels, 287 words |
| bank `$04` spawn-record table | relocate | 74 labels, 47 words |
| bank `$05` effect step table | fail-safe | ROM0 immediates pin |
| RAM-code source image (bank `$02`) | relocate | 177 labels, 90 words |
| RAM-code source image (bank `$01`) | fail-safe | pin at `$6609` |
| data block read by raw ROM0 address | fail-safe | pin |
| alignment-sensitive HDMA source | fail-safe | 16-byte alignment assert |

- **Engine change**: labels at `$7FFF` (bank markers) are now excluded from
  the moved set, because computed fills absorb the padding.
- **Assert conversion**: in banks `$03`/`$04`, 50 generator-era absolute
  `ASSERT @ == $xxxx` lines became relative size asserts.
- **Relocation audit**: raw references into `$09-$3A` dropped from 152
  pointers and 80 bank bytes to 62 and 0. The 62 are now symbolic in source.
  The audit still derives them from ROM bytes and keeps their pins.
