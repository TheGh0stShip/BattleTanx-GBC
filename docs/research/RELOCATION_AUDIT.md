# Relocation audit: banks $09-$3A

Baseline `ae8696ef6adf28ad6984acbb64a9954d4cca854c`.

## Method

1. **Raw-operand inventory**: every raw `$4000-$7FFF` operand in all 64
   bank files was classified (709 occurrences). The only raw
   pointers into scoped banks live in banks `$01` and `$05`, which this
   assignment may not edit. No scoped file contains a raw operand that is a
   pointer: the 486 constants are palette words and map/row data.
2. **Machine-derived references**: `tools/relocation_audit.py` derives every
   raw reference from the ROM tables themselves and requires a pin for each:
   - `$01:ScrollingSceneDescriptors`, the raw entries in scope;
   - `$01:$596D`;
   - `$05:ObjectOrientationTilePointers`;
   - `$01:7981`'s `ld bc/ld de`.

   The pin form is `ASSERT BANK(Label) == $BB && Label == $AAAA, "raw pointer: <source>"`.
   Raw bank bytes (`$01:ScreenModeTable`, scene descriptor bank bytes) need
   `ASSERT BANK(Label) == $BB`. Result: 152 raw pointer references (131
   distinct targets) and 80 raw bank bytes, all pinned and all labelled.
   Symbolic scrolling entries 32-35 are recognised from the source and
   exempt.
3. **Shift tests** (`tools/shift_test.py`, part of `make check`): each case
   inserts padding in a scratch copy and assembles *without* `baserom.gbc`.
   - A relocate case requires every later label in the bank to move by
     exactly N, and every other changed byte to be a 16-bit word that moved
     by N toward a moved label.
   - A fail-safe case requires the build to stop.

## Shift-test results

| Case | Mode | Result |
| --- | --- | --- |
| Level 0 odd bank (cell map, tiles, lookup, palettes) | relocate | 4 labels, 4 pointer words (level record + LevelAttributeLookupPointers) |
| Level 0 even bank | relocate | 2 labels, 2 words |
| Level 0 attribute map inside its bank | fail-safe | ASSERT (both maps share one offset) |
| Level 14 even bank | relocate | 2 labels, 2 words |
| Object frames bank `$27` | fail-safe | pins (raw `$05` table) |
| Object palette bank `$28` | fail-safe | residue must stay at `$4518` |
| Screen package mode 7 | relocate | 38 labels, 44 words (cross-bank pointer table `ScreenModeTable` + descriptors + template operands) |
| Mode 3 alternate maps | fail-safe | pins (raw `$01:7981`) |
| Fixed scenes 06-07 | relocate | 8 labels, 8 words |
| Scrolling scenes 32-35 | relocate | 20 labels, 20 words |
| Fixed scene misaligned (8 bytes) | fail-safe | HDMA alignment ASSERT |
| Scrolling scene 21 | fail-safe | pins (raw `$01` descriptors) |
| Bank `$2E` pictures | fail-safe | pins (raw `$01:$596D`) |

Before this pass the bank-`$2E` pictures case **assembled silently** with a
stale table. That was a real relocation hazard, and the new pins close it.

## Remaining hard-coded addresses

All of them remain in their owning source files. Each target is pinned so a
move fails at assembly. Machine-readable list:
`reports/raw_references_09_3A.json`.

| Location | Count | Targets | Fix for the owning assignment |
| --- | ---: | --- | --- |
| `$01:ScrollingSceneDescriptors` (30 raw entries targeting scoped banks) | 90 words + bank bytes | `$2F`, `$34-$3A` scene tiles/rows/palettes | write `dw ScrollSceneNNTiles, ...` and `db BANK(...)` |
| `$01:$596D` table | 12 words + 3 bank bytes | `MenuState05Picture0-2_*` (`$2E`) | `dw` labels, `db BANK(...)` |
| `$01:7981` | 2 operands | `CodeRejectedTileMap`/`AttrMap` (`$2C`) | `ld bc, CodeRejectedTileMap` |
| `$05:ObjectOrientationTilePointers` | 16 words | `Bank27OrientationFrame0-8` | `dw Bank27OrientationFrameN - Bank27OrientationTiles + $4000`, or labels |
| `$01:ScreenModeTable` bank bytes | 26 | `$2A-$2E` routines | `BANK(label)` |
| `$01` scene descriptor bank bytes | 54 | `$2F-$3A` | `BANK(label)` |
| ROM0 `CopyObjectOrientationTiles` `add a, $27` | 1 | bank arithmetic | `BANK(Bank27OrientationTiles)` |

## Other changes made for relocation safety

- Scene banks `$2F-$3A`: `db BANK(@)` markers.
- Banks `$30-$33`: computed fills; absolute pins replaced by bank and
  alignment asserts.
- 131 address pins and 80 bank pins added.

## Validation

- `make relocation`: the audit runs 5 negative tests (dropped address pin,
  wrong pin address, dropped bank pin, stale report, moved table value), then
  the 13 shift cases run.
- Reports: `reports/range_map_09_3A.json` (384 ranges, every byte of
  `$09-$3A`), `reports/raw_references_09_3A.json`,
  `reports/asset_manifest_09_3A.json` (126 assets: size, SHA-1, ROM range,
  consumers).
