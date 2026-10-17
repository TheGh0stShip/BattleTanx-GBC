# Banks $09-$3A: semantic recovery and relocation audit

## 1. Baseline and verification

The audit began at commit `ae8696ef6adf28ad6984acbb64a9954d4cca854c`.
Every result was rechecked against the cartridge and the final integrated
source. Two preliminary inventory claims were corrected during that review:

- the raw inventory missed the `$01:7981` operands and filed the raw bank
  bytes in the wrong class;
- generated pins for the symbolic scrolling entries 32-35 were withdrawn.

## 2. Per-bank byte accounting

Every bank totals `$4000`. Banks `$09-$2E` come from the level, object and
screen parsers. Banks `$2F-$3A` come from the linked-symbol range map, where
trailing fill is counted inside the last structure.

| Bank | Code | Graphics | Structured | Padding/fill/marker | Unknown/residue | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `$09` | 0 | 6416 | 4312 | 5656 | 0 | 16384 |
| `$0A` | 0 | 0 | 8192 | 8192 | 0 | 16384 |
| `$0B` | 0 | 5872 | 7960 | 2552 | 0 | 16384 |
| `$0C` | 0 | 0 | 15488 | 896 | 0 | 16384 |
| `$0D` | 0 | 5888 | 7704 | 2792 | 0 | 16384 |
| `$0E` | 0 | 0 | 14976 | 1408 | 0 | 16384 |
| `$0F` | 0 | 5712 | 8272 | 2400 | 0 | 16384 |
| `$10` | 0 | 0 | 16128 | 256 | 0 | 16384 |
| `$11` | 0 | 4704 | 7960 | 3720 | 0 | 16384 |
| `$12` | 0 | 0 | 15488 | 896 | 0 | 16384 |
| `$13` | 0 | 6432 | 7704 | 2248 | 0 | 16384 |
| `$14` | 0 | 0 | 14976 | 1408 | 0 | 16384 |
| `$15` | 0 | 4496 | 7240 | 4648 | 0 | 16384 |
| `$16` | 0 | 0 | 14080 | 2304 | 0 | 16384 |
| `$17` | 0 | 6640 | 8264 | 1480 | 0 | 16384 |
| `$18` | 0 | 0 | 16128 | 256 | 0 | 16384 |
| `$19` | 0 | 6720 | 8280 | 1384 | 0 | 16384 |
| `$1A` | 0 | 0 | 16128 | 256 | 0 | 16384 |
| `$1B` | 0 | 5168 | 7888 | 3328 | 0 | 16384 |
| `$1C` | 0 | 0 | 15360 | 1024 | 0 | 16384 |
| `$1D` | 0 | 4224 | 7960 | 4200 | 0 | 16384 |
| `$1E` | 0 | 0 | 15488 | 896 | 0 | 16384 |
| `$1F` | 0 | 4640 | 7896 | 3848 | 0 | 16384 |
| `$20` | 0 | 0 | 15360 | 1024 | 0 | 16384 |
| `$21` | 0 | 3952 | 7896 | 4536 | 0 | 16384 |
| `$22` | 0 | 0 | 15360 | 1024 | 0 | 16384 |
| `$23` | 0 | 4064 | 7952 | 4368 | 0 | 16384 |
| `$24` | 0 | 0 | 15488 | 896 | 0 | 16384 |
| `$25` | 0 | 6272 | 7896 | 2216 | 0 | 16384 |
| `$26` | 0 | 0 | 15360 | 1024 | 0 | 16384 |
| `$27` | 0 | 1296 | 6 | 13316 | 1766 | 16384 |
| `$28` | 0 | 1296 | 6 | 13316 | 1766 | 16384 |
| `$29` | 0 | 1296 | 6 | 13316 | 1766 | 16384 |
| `$2A` | 613 | 10992 | 2716 | 2063 | 0 | 16384 |
| `$2B` | 585 | 10976 | 2450 | 2373 | 0 | 16384 |
| `$2C` | 993 | 10336 | 4534 | 521 | 0 | 16384 |
| `$2D` | 408 | 6608 | 1508 | 7860 | 0 | 16384 |
| `$2E` | 204 | 12880 | 2486 | 814 | 0 | 16384 |
| `$2F` | 0 | 12352 | 4032 | 0 | 0 | 16384 |
| `$30` | 0 | 12192 | 4192 | 0 | 0 | 16384 |
| `$31` | 0 | 12720 | 3664 | 0 | 0 | 16384 |
| `$32` | 0 | 11344 | 5040 | 0 | 0 | 16384 |
| `$33` | 0 | 7056 | 9328 | 0 | 0 | 16384 |
| `$34` | 0 | 10656 | 5728 | 0 | 0 | 16384 |
| `$35` | 0 | 9520 | 6864 | 0 | 0 | 16384 |
| `$36` | 0 | 9392 | 6992 | 0 | 0 | 16384 |
| `$37` | 0 | 8768 | 7616 | 0 | 0 | 16384 |
| `$38` | 0 | 9328 | 7056 | 0 | 0 | 16384 |
| `$39` | 0 | 9440 | 6944 | 0 | 0 | 16384 |
| `$3A` | 0 | 9296 | 7088 | 0 | 0 | 16384 |

Exact scene totals from the validators:
- scrolling (`$2F`, `$34-$3B`): 88,752 graphics, 348 structured, 27,400 rows,
  256 palettes, 30,700 padding, 0 unknown;
- fixed (`$30-$33`): 43,968 graphics, 6,984 structured, 14,584 padding,
  5,872 dual-use.

Reviewed code: 38,774 bytes (35,303 root/table traced, 3,265 reviewed
standalone-seed bytes, and 206 callerless bytes: two copied RAM no-op stubs
plus 204 bank-`$2E` template bytes).
Heuristic gap-fill: 0.

## 3. Recovered structures and consumers

See [`LEVEL_SEMANTICS_RESEARCH.md`](LEVEL_SEMANTICS_RESEARCH.md),
[`OBJECT_ORIENTATION_RUNTIME_RESEARCH.md`](OBJECT_ORIENTATION_RUNTIME_RESEARCH.md),
[`SCREEN_RUNTIME_RESEARCH.md`](SCREEN_RUNTIME_RESEARCH.md), and
[`SCENE_RUNTIME_RESEARCH.md`](SCENE_RUNTIME_RESEARCH.md). Highlights:
- **Level record**: all 20 bytes traced to readers; +6, +7 and +8 have none.
- **Cell bits**: passable / solid / destructible / touch-region / animated /
  lookup (bits 0-3, 6, 7); bits 4-5 are unused.
- **Level index**: 0-14 on every writer.
- **Object selector**: 0-3 for drawn objects, so banks `$2A`+ can never be
  selected.
- **Screens**: mode 9 is unreachable (an alias of `$0A`); the boot sequence
  is `$0A`, 2, 5, 7; mode 1 is Options; `$C6B5` is the joypad state;
  `$01:7981` is the code-rejected path; the `$596D` pictures follow
  `wMenuState05Selection` 0-2.
- **Scenes**: a complete descriptor-to-caller graph; scrolling runtime;
  dual-use bytes and over-reads explained.

## 4. Renames (aliases; no label removed)

| Address | New label | Old label kept | Evidence |
| --- | --- | --- | --- |
| `$2A:61D8/6230/62A4` | `OptionsScreen_LoadTiles/Draw/Descriptor` | `ScreenMode01_*`, `Func_2A_*` | MenuState04 + OptionsMenuEntries text |
| `$2B:5BDA...` | `BootSequenceScreen1_*` | `ScreenMode09_*` | `Func_02_5C40` order (*verified*) |
| `$2C:4000...` | `BootSequenceScreen2_*` | `ScreenMode02_*` | same |
| `$2C:4B3A...` | `BootSequenceScreen3_*` | `ScreenMode05_*` | same |
| `$2B:4000...` | `BootSequenceScreen4_*` | `ScreenMode07_*` | same |
| `$2C:6CE9/6FB9` | `CodeRejectedTileMap/AttrMap` | `ScreenMode03_Alt*Map` | `$01:7981` failure path |
| `$2E` pictures | `MenuState05Picture0-2_Tiles` | `Picture596D0/1_Tiles`, `Screen2E_Tiles` | `RAM_D7CB` index |
| cell bits | `CELLB_*` constants | — | level report |

Rejected names: "title", "ending", "password" (screens 7, 8, 3/`$0B`),
vehicle names for banks `$27-$29`, and world names for scenes. In each case
only appearance or inference supports them.

## 5. Unresolved

1. Level record +6/+7/+8 have no reader.
2. Purpose of modes 0, 3, 4, 6, 8, `$0B`, `$0C` beyond structure.
3. The `$2E` package pair has no caller found (indirect paths not
   exhaustively excluded).
4. Scene identities (no text).
5. Visual meaning of the per-level tiles.
6. F04's 72-byte palette copy into a 64-byte buffer (effect unknown).
7. `Func_1FF5` slot exhaustion.
8. The bank-`$01` LCD handler's `call $5EE0` while object banks are mapped.
9. Bits 6-7 table semantics: tile choice traced, gameplay meaning not.

## 6. Indirect branches and selectors

- **Screen dispatch** (`$39C3`/`$39F0` `jp hl`): 13 entries, mode set
  {0..8, $0A, $0B, $0C}.
- **Object bank** `$27 + [$FF80]`: 0-2 (3 skips the copy).
- **Level bank selectors**: record bytes `BANK()`-derived; index 0-14.
- **Scene selectors**: `$FF81` 0-10, `$FF82` 0-`$23`.
- **`EntityHandlerTable`**: dispatched by `+$1E` (0-9).

## 7. Raw ROM addresses

[`RELOCATION_AUDIT.md`](RELOCATION_AUDIT.md) and
`../../reports/raw_references_09_3A.json`: 152 raw
pointer references (131 targets) and 80 raw bank bytes. All of them live in
out-of-scope banks `$00/$01/$05` and are pinned. No scoped file contains a
raw pointer.

## 8. Shift tests

13 cases (6 relocate, 7 fail-safe), all passing, assembled without
`baserom.gbc`. See [`RELOCATION_AUDIT.md`](RELOCATION_AUDIT.md).

## 9. Negative tests

| Suite | Count | Cases (each must fail for its stated reason) |
| --- | ---: | --- |
| Relocation audit | 5 | dropped address pin, wrong pin address, dropped bank pin, stale report, moved table value |
| Shift tests | 7 fail-safe | each must stop assembly |
| Existing suites | unchanged | still pass |

## 10. Assets

- Added, removed, renamed or modified: **none**.
- Retained: 126 assets used by banks `$09-$3A`.
- `reports/asset_manifest_09_3A.json` lists size, SHA-1, ROM range and
  consumers for each.
- Level map assets keep `.bin` names; renaming would touch five tools and the
  `$27-$29` residue slices with no change in meaning.

## 11. Project files

- New reports:
  - `BANKS_09_3A_SEMANTIC_RECOVERY.md`
  - `LEVEL_SEMANTICS_RESEARCH.md`
  - `OBJECT_ORIENTATION_RUNTIME_RESEARCH.md`
  - `SCREEN_RUNTIME_RESEARCH.md`
  - `SCENE_RUNTIME_RESEARCH.md`
  - `RELOCATION_AUDIT.md`
- New machine-readable reports: `reports/range_map_09_3A.json`,
  `reports/raw_references_09_3A.json`, `reports/asset_manifest_09_3A.json`,
  `reports/level_comparison.json`.
- New tools: `tools/relocation_audit.py`, `tools/shift_test.py`,
  `tools/level_comparison.py`.
- Source: `src/bank_27.asm`-`src/bank_3A.asm` (pins, aliases, markers,
  fills); `include/level_data.inc` (record and cell documentation, `CELLB_*`).
- Shared: `Makefile` (`relocation` target, added to `check`).

## 12. Clean build

```
make clean
make check
battletanx.gbc: OK (sha1 5078584e86c0b6f4687c424cc00bbd762ba6573a)
bank 08: every byte classified (code 27, fill 4623, graphics 9824, graphics (duplicate, not loaded) 16, graphics (not loaded) 144, graphics (unreachable table entries only) 992, marker 1, palette 64, palette (not loaded) 8, palette record 336, palette record (unused) 8, table 330, unknown 11), 28 negative tests rejected
object banks: $27-$29 fully accounted (fill 39945, graphics 3888, marker 3, palette 24, residue 5292), 20 negative tests rejected
unused banks: $3C-$3F are 65536 checked $FF padding bytes
code-bank tails: banks $03/$04 explicit through their bank markers
scrolling source: 32 scenes in banks $2F/$34-$3B (88752 graphics, 348 structured, 27400 rows, 256 palettes, 30700 padding, 0 unknown)
fixed source: 11 fixed and 4 scrolling scenes in banks $30-$33 (43968 graphics, 6984 structured, 14584 padding; 5872 dual-use bytes)
text: 3 option entries, 11 strings, 2 renderer calls, 4 negative tests rejected
object sequences: 15 level tables, 203 sequences, 626 records, 4 negative tests rejected
level objects: 15 levels, 548/600 active spawn records, 37/120 enabled auxiliary records, 3 negative tests rejected
trace: 35303 root/table bytes, 3265 reviewed standalone bytes, 206 callerless bytes, 0 heuristic bytes, 33 RAM code images, 5 RAM data images
audio: 37 patches, 25 sfx sequences, 10 music sequences, 32 queued ids and 57 call sites checked
screens: banks $2A-$2E fully classified (code 2803, data 13694, graphics 51792, padding 13631), 13 screen packages, 18 negative tests rejected
levels: 15 levels in banks $09-$26, every byte in one range, 11 negative tests rejected
project: OK (158 assets, baserom sha1 5078584e86c0b6f4687c424cc00bbd762ba6573a)
baserom.gbc: OK (sha1 5078584e86c0b6f4687c424cc00bbd762ba6573a)
graphics: 65 sheets extracted and round-trip verified
scene maps: 11 fixed scenes (2640 cells) plus the referenced bank-$3B compatibility warning, 36 scrolling scenes (709 rows, 14180 cells) rendered and verified
levels: 15 levels, 112000 cells; CSV, palette and PNG outputs round-trip verified
screens: 17 pictures; CSV, palette and PNG outputs round-trip verified
objects: 3 banks; frame, orientation, layout and palette outputs round-trip verified
bank08: 85 graphics ranges, glyph map, 11 strings, 16 metatiles; all outputs round-trip verified
relocation: 152 raw pointers and 80 raw bank bytes pinned; 384 ranges cover banks $09-$3A; 126 assets; 5 negative tests rejected
level comparison: report matches all 15 levels
shift: PASS [relocate] level 0 odd bank (cell map, tiles, lookup table, palettes): 4 labels moved by 16; 4 pointer words relocated; no other byte changed
shift: PASS [relocate] level 0 even bank (tile map, attribute map): 2 labels moved by 16; 2 pointer words relocated; no other byte changed
shift: PASS [fail-safe] level 0 attribute map inside its bank: assembly stopped as required: Assembly aborted with 1 error
shift: PASS [relocate] level 14 even bank (source of the $27-$29 residue slices): 2 labels moved by 16; 2 pointer words relocated; no other byte changed
shift: PASS [fail-safe] object orientation frames bank $27: assembly stopped as required: Assembly aborted with 11 errors
shift: PASS [fail-safe] object palette bank $28: assembly stopped as required: Assembly aborted with 2 errors
shift: PASS [relocate] screen package mode 7 (code, descriptor, tiles, maps, palettes): 38 labels moved by 16; 44 pointer words relocated; no other byte changed
shift: PASS [fail-safe] screen package mode 3 alternate maps: assembly stopped as required: Assembly aborted with 3 errors
shift: PASS [relocate] fixed scenes 06-07 (bank $30, HDMA tile windows, maps, attributes, palettes): 8 labels moved by 16; 8 pointer words relocated; no other byte changed
shift: PASS [relocate] scrolling scenes 32-35 (bank $30, symbolic descriptors): 20 labels moved by 16; 20 pointer words relocated; no other byte changed
shift: PASS [fail-safe] fixed scene misaligned for HDMA: assembly stopped as required: Assembly aborted with 1 error
shift: PASS [fail-safe] scrolling scene 21 (bank $2F, tiles, rows, palette): assembly stopped as required: Assembly aborted with 55 errors
shift: PASS [fail-safe] bank $2E pictures used by the $01:$596D table: assembly stopped as required: Assembly aborted with 8 errors
shift: 13 cases, all passed (assembled without baserom.gbc)
exit=0
```

## 13. Build without the ROM image

An isolated source build with no `baserom.gbc` present:
- `rgbasm`/`rgblink` output SHA-1 `5078584e86c0b6f4687c424cc00bbd762ba6573a`;
- all 13 shift tests pass;
- with the verified ROM restored, `make clean && make check` exits 0.
