# ROM banks $09-$26: level data

Scope: ROM banks `$09`-`$26` (30 banks, 491,520 bytes). The other banks were
read only to trace references; I didn't modify them. Addresses are CPU
addresses; `BB:AAAA` is bank `BB`. ROM offset = `BB * $4000 + AAAA - $4000`.
Multi-byte values are little-endian 16-bit words.

Baseline: local commit `92fc02e`. Rebuild SHA-1 is unchanged:
`5078584e86c0b6f4687c424cc00bbd762ba6573a`.

## 1. Result

The 30 banks are 15 levels, two banks per level:

- **Odd bank** (`$09`, `$0B`, ... `$25`): cell map, 2bpp tiles, one unread
  zero byte, a 160-byte attribute lookup table, BG palettes, zero fill,
  bank marker.
- **Even bank** (`$0A`, `$0C`, ... `$26`): BG tile map, BG attribute map,
  zero fill, bank marker.

Every byte belongs to exactly one range below. `tools/level_data.py` checks
the coverage and boundaries from the ROM. There is no code, text, sprite
layout, collision table or compressed stream anywhere in these banks. The
cell map's low six bits have unknown meaning (section 6).

| Class | Bytes | Share |
| --- | ---: | ---: |
| Cell maps | 112,000 | 22.8% |
| Tile maps | 112,000 | 22.8% |
| Attribute maps | 112,000 | 22.8% |
| 2bpp tiles | 81,200 | 16.5% |
| Zero fill | 71,091 | 14.5% |
| Attribute lookup tables | 2,400 | 0.5% |
| BG palettes | 784 | 0.2% |
| Bank markers | 30 | — |
| Unread zero byte before each lookup table | 15 | — |
| **Total** | **491,520** | 100% |

## 2. References into these banks

Only the level loader selects these banks. Every selection is a computed
bank from the level record, never an immediate:

| Site | Bank source | Range read |
| --- | --- | --- |
| ROM0 `$18EE` | `a` = level; record pointer from `05:4300 + 2a` | — |
| ROM0 `$188B` | copies record +0 to `$CA09`, +1 to `$CA0A`, +2..+19 to `$C8B9-$C8CA` (`ld d,$12`) | — |
| ROM0 `$1A33` | `[$C8B9]` (record +2) | 440 tiles from `[$C8C1]` (record +10): 128 to VRAM0 `$8800`, 128 to VRAM0 `$9000`, 128 to VRAM1 `$9000`, 56 to VRAM1 `$8800` (`Func_0622`, 16 bytes per tile) |
| ROM0 `$1A86` | `[$C8BA]` (record +3) | `[$C8C0]` (record +9) palettes x 8 bytes from `[$C8C3]` (record +12) to BCPS/BCPD (`Func_052F`) |
| ROM0 `$1AA4` | `[$C8BB]` (record +4) | width x height bytes from `[$C8C9]` (record +18) to WRAM banks 2-3 at `$D000` |
| ROM0 `$1D93`/`$1E84` and row/column drawers `$1D26`, `$1E97`, `$1EC5`, `$1F82` | `[$C8BC]` (record +5) | tile id `[$C8C7 + off]` (record +16), attribute `[$C8C5 + off]` (record +14), off = row table `$CA17[y] + x`, rows = `$CA09` bytes (`$1A10`) |
| ROM0 `$1D93` (cells with bit 7 set) | `[$C8D2]` from `05:513E` (via `05:4088`) | one byte of the 160-byte table at `[$C8D0]` |

Record table `05:4300`: 15 words `$4400`-`$4518`, stride `$14`; the 16th word is
`$0100` (not a record). `05:513E`: 15 entries of `dw table, db bank, db 0`;
the bank bytes are 9, 11, ..., 37.

Bounds on the level number `[$CA06]`:
- The in-game advance at ROM0 `$0078` stops at 14 (`cp $0E`).
- `01:4CAA` (routine) sets it to `3*[$D568] + [$D567]`, and `01:5164` copies `[$C939]`.
  Neither is bounded by this work.
- Every level index 0-14 is valid. Index 15 would read the `$0100` word.

Earlier reads of other computed bank selectors elsewhere in the ROM give
`$27`+ (`[$FF80]+$27`), `$2A-$2D` (screen table), `$2E`, `$2F-$3B`. None
falls in `$09-$26` within their known index ranges.

## 3. Level record (`05:4400 + $14*n`, 20 bytes)

| Offset | Size | Meaning | Evidence |
| --- | --- | --- | --- |
| +0 | 1 | map width in cells | `$CA09`; `$1A10` row stride; `$1AA4` inner loop |
| +1 | 1 | map height in cells | `$CA0A`; `$1AA4` outer loop |
| +2 | 1 | bank of tiles | `$C8B9`, `$1A33` |
| +3 | 1 | bank of palettes | `$C8BA`, `$1A86` |
| +4 | 1 | bank of cell map | `$C8BB`, `$1AA4` |
| +5 | 1 | bank of tile/attribute maps | `$C8BC`, `$1D93` callers |
| +6 | 1 | copy of +5; `$C8BD` never read | unknown purpose |
| +7 | 2 | tile count - 1; `$C8BE` never read | equals highest used tile in all 15 levels |
| +9 | 1 | BG palette count | `$C8C0`, `$1A86` |
| +10 | 2 | tiles pointer (= `$4000` + cells) | `$C8C1` |
| +12 | 2 | palettes pointer | `$C8C3` |
| +14 | 2 | attribute map pointer (= `$4000` + cells) | `$C8C5` |
| +16 | 2 | tile map pointer (`$4000`) | `$C8C7` |
| +18 | 2 | cell map pointer (`$4000`) | `$C8C9` |

+2, +3 and +4 are equal (the odd bank); +5 and +6 are equal (the next bank).

## 4. Formats

### 4.1 Cell map (odd bank `$4000`, width x height bytes, row-major)

Copied to WRAM. In `$1D93`, bits 6-7 select the lookup path: `00` uses the
tile/attribute maps; `$40`/`$C0` returns tile `$BB + (counter & 7)` with
attribute `[$C8D3]`; `$80` uses the bank-`$05` table at `[$C8CE]` and
the attribute lookup table. **Every cell byte in ROM has bits 6-7 clear.**
Low-bit values seen: 0, 1, 2, 3, 6, 8, 9, 10, 15. Their meaning is not
established. The WRAM copy may be changed at run time, which was not traced.

### 4.2 Tiles (odd bank, `16 * (record+7 + 1)` bytes)

Native Game Boy 2bpp. The loader always copies 440 tiles, so it also copies
the lookup table, palettes and zero fill into unused VRAM. The block
boundary comes from layout and use: the lookup table pointer from `05:513E`
equals `tiles + 16 * count + 1` in every level, and the highest block tile
any map cell uses is exactly `count - 1` in every level.

Block tile number for a tile id `t` with attribute `a` (from the `$1A33`
copy order):

| VRAM bank (attr bit 3) | id | block tile |
| --- | --- | --- |
| 0 | `$80-$FF` | `t - $80` (0-127) |
| 0 | `$00-$7F` | `128 + t` |
| 1 | `$00-$7F` | `256 + t` |
| 1 | `$80-$B7` | `384 + t - $80` |

### 4.3 Unread zero byte and attribute lookup table

`$1D93` adds `(v + $80) + $7F` (8-bit) to `[$C8D0]`, so it reads entry
`v - 1` for `v >= 1`. The table is 160 bytes at the `05:513E` pointer. The
byte before it is zero in every level and is never read. It is kept as an
explicit `db $00`, because the source can't show whether it belongs to the
tiles, the table or neither. Table values seen: `$00-$05`, `$80`.

### 4.4 Level tile-animation tables

Bank `$05:$5120` contains one pointer per level. Levels are grouped in threes
and select five tables at `$517A`, `$532D`, `$54CC`, `$56A7`, and `$5800`.
They contain 87, 83, 95, 69, and 96 five-byte records respectively, ending
exactly at `$59E0`. Each record is its one-based index followed by four tile
IDs. `GetLevelCellTileAndAttr` selects one of those four IDs with the low two
bits of the shared animation counter. For input tile ID `t`, its zero-based
record index is the 8-bit value `t + $7F`; the selected byte is therefore
`table + 5 * index + 1 + frame`.

The pointer table and all 430 records are explicit source. Validation checks
all pointers, table boundaries, counts, and sequential record IDs. The visual
meaning of individual animated tiles is not assigned.

### 4.5 BG palettes

`record+9` palettes x 4 RGB555 words, bit 15 clear in every word, loaded
from BG palette 0 upward. Every attribute byte names a palette below the
count.

### 4.6 Tile map and attribute map (even bank)

Tile map at `$4000`, attribute map right after it, each width x height
bytes, row-major. Attribute bits: 0-2 palette, 3 VRAM bank, 5 x flip,
6 y flip, 7 priority (used only in level 12); bit 4 is clear everywhere.

### 4.7 Padding and markers

From the end of the palettes (odd) or attribute map (even) to `$7FFE` all
bytes are zero; `$7FFF` holds the bank number.

## 5. Source representation

- `src/bank_09.asm`-`src/bank_26.asm`: labelled layout per bank,
  `level_bank_end` padding macro, `ASSERT`s tying the layout to the
  constants. Lookup tables and palettes are explicit `db` / `dw`.
- Maps and tiles are `INCBIN`s of typed ranges (`cellmap.bin`, `tiles.2bpp`,
  `tilemap.bin`, `attrmap.bin` under `assets/levels/level_NN/`). These are
  extracted from the ROM by `make assets`, untracked, and listed one per
  range in `assets.txt`; they replace the 30 whole-bank blobs.
- `include/level_data.inc`: per-level width, height, tile count and palette
  count, plus macros for bank endings, level records, and lookup references.
- `src/bank_05.asm`: the 15 record pointers, 20-byte records, and attribute
  lookup references are explicit symbolic source. Its 15 tile-animation
  pointers and all 430 fixed-size animation records are also explicit; the
  former `$40B1-$7FFF` opaque asset is split around every proven structure.
  The adjacent four-entry score-value table and four eight-byte object-type
  parameter records are also explicit; the latter retain five reserved zero
  bytes per record because only the first three fields have known readers.
- `make levels` (`tools/extract_level_data.py`) writes `build/levels/level_NN/`:
  `record.json`, `cellmap.csv`, `tilemap.csv`, `attrmap.csv`, `cells.csv`
  (decoded tile number, palette, bank, flips, priority, cell byte),
  `palettes.txt`, and `tiles.png` / `render.png` (inspection only). CSVs are
  parsed back and compared with the ROM; PNGs go back through rgbgfx and are
  compared with the source tiles.

## 6. Understood vs unknown

| Range class | Bytes | Status |
| --- | ---: | --- |
| Tiles, tile maps, attribute maps, palettes | 305,984 | boundaries, references and representation checked |
| Zero fill and markers | 71,121 | checked |
| Cell maps | 112,000 | boundaries and bits 6-7 checked; low 6 bits unknown |
| Attribute lookup tables | 2,400 | boundaries and indexing checked; the reading path is never triggered by ROM cell data |
| Zero byte before each table | 15 | never read; role unknown |

Direct traced code bytes: 38,772 in the integrated project, unchanged by this
work because none are in these banks. Heuristic
decoding: none. Two facts are layout inferences rather than direct reads:
record +7 as tile count - 1, and the unread byte. Both are enforced by the
validator. Visual renders were only used as a sanity check, not as evidence.

## 7. Unresolved

1. Meaning of the cell-map low bits (likely read by game logic in WRAM;
   not traced).
2. Whether run-time code sets cell bits 6-7, which would exercise the
   `$40`/`$80` paths and the lookup tables.
3. Record +6 and +7..+8 are never read.
4. The level number set in `01:4CAA` (`3*[$D568]+[$D567]`) and `01:5164`
   (`[$C939]`) is not bounded.
5. No level names or themes are assigned.
6. Nothing was checked on hardware.

## 8. Suggested `docs/STATUS.md` text

> **Level banks $09-$26:** recovered as 15 two-bank levels (record table
> `05:4300`). All 491,520 bytes are classified with no gaps: cell maps,
> 2bpp tiles, attribute lookup tables, BG palettes, tile maps, attribute
> maps, zero fill and markers. Source is structured per bank with typed
> INCBINs, explicit palettes and tables, and layout ASSERTs.
> `tools/level_data.py` validates every boundary from the ROM, with 11
> negative tests. Unknown: cell-map low bits, record +6/+7, the role of one
> unread byte per level, and the run-time use of the lookup tables.

## 9. Validation

```
make clean
make check
```

Result (clean tree, no stale assets):

```
battletanx.gbc: OK (sha1 5078584e86c0b6f4687c424cc00bbd762ba6573a)
trace: 38772 direct bytes, 0 heuristic bytes, 31 RAM code images, 7 RAM data images
audio: 37 patches, 25 sfx sequences, 10 music sequences, 32 queued ids checked
levels: 15 levels in banks $09-$26, every byte in one range, 11 negative tests rejected
project: OK (129 assets, baserom sha1 5078584e86c0b6f4687c424cc00bbd762ba6573a)
graphics: 61 sheets extracted and round-trip verified
scene maps: 11 fixed scenes (2640 cells), 36 scrolling scenes (709 rows, 14180 cells) rendered and verified
levels: 15 levels, 112000 cells; CSV, palette and PNG outputs round-trip verified
```

Negative tests (each must fail for the stated reason): bank marker, zero
fill, record bank byte, record tile count, lookup-table pointer, palette
bit 15, attribute palette range, tile beyond count, cell bits 6-7, and the
unread byte, plus the tile-animation pointer table.

## 10. Range map

Generated from `tools/level_data.py` (`range_map`). End addresses are
inclusive.

| Bank | Level | Range | Bytes | Contents |
| --- | --- | --- | ---: | --- |
| `$09` | 0 | `4000-4FFF` | 4096 | cellmap |
| `$09` | 0 | `5000-690F` | 6416 | tiles |
| `$09` | 0 | `6910-6910` | 1 | zero byte, not read |
| `$09` | 0 | `6911-69B0` | 160 | attribute lookup table |
| `$09` | 0 | `69B1-69E8` | 56 | bg palettes |
| `$09` | 0 | `69E9-7FFE` | 5654 | zero fill |
| `$09` | 0 | `7FFF-7FFF` | 1 | bank marker |
| `$0A` | 0 | `4000-4FFF` | 4096 | tilemap |
| `$0A` | 0 | `5000-5FFF` | 4096 | attribute map |
| `$0A` | 0 | `6000-7FFE` | 8191 | zero fill |
| `$0A` | 0 | `7FFF-7FFF` | 1 | bank marker |
| `$0B` | 1 | `4000-5E3F` | 7744 | cellmap |
| `$0B` | 1 | `5E40-752F` | 5872 | tiles |
| `$0B` | 1 | `7530-7530` | 1 | zero byte, not read |
| `$0B` | 1 | `7531-75D0` | 160 | attribute lookup table |
| `$0B` | 1 | `75D1-7608` | 56 | bg palettes |
| `$0B` | 1 | `7609-7FFE` | 2550 | zero fill |
| `$0B` | 1 | `7FFF-7FFF` | 1 | bank marker |
| `$0C` | 1 | `4000-5E3F` | 7744 | tilemap |
| `$0C` | 1 | `5E40-7C7F` | 7744 | attribute map |
| `$0C` | 1 | `7C80-7FFE` | 895 | zero fill |
| `$0C` | 1 | `7FFF-7FFF` | 1 | bank marker |
| `$0D` | 2 | `4000-5D3F` | 7488 | cellmap |
| `$0D` | 2 | `5D40-743F` | 5888 | tiles |
| `$0D` | 2 | `7440-7440` | 1 | zero byte, not read |
| `$0D` | 2 | `7441-74E0` | 160 | attribute lookup table |
| `$0D` | 2 | `74E1-7518` | 56 | bg palettes |
| `$0D` | 2 | `7519-7FFE` | 2790 | zero fill |
| `$0D` | 2 | `7FFF-7FFF` | 1 | bank marker |
| `$0E` | 2 | `4000-5D3F` | 7488 | tilemap |
| `$0E` | 2 | `5D40-7A7F` | 7488 | attribute map |
| `$0E` | 2 | `7A80-7FFE` | 1407 | zero fill |
| `$0E` | 2 | `7FFF-7FFF` | 1 | bank marker |
| `$0F` | 3 | `4000-5F7F` | 8064 | cellmap |
| `$0F` | 3 | `5F80-75CF` | 5712 | tiles |
| `$0F` | 3 | `75D0-75D0` | 1 | zero byte, not read |
| `$0F` | 3 | `75D1-7670` | 160 | attribute lookup table |
| `$0F` | 3 | `7671-76A0` | 48 | bg palettes |
| `$0F` | 3 | `76A1-7FFE` | 2398 | zero fill |
| `$0F` | 3 | `7FFF-7FFF` | 1 | bank marker |
| `$10` | 3 | `4000-5F7F` | 8064 | tilemap |
| `$10` | 3 | `5F80-7EFF` | 8064 | attribute map |
| `$10` | 3 | `7F00-7FFE` | 255 | zero fill |
| `$10` | 3 | `7FFF-7FFF` | 1 | bank marker |
| `$11` | 4 | `4000-5E3F` | 7744 | cellmap |
| `$11` | 4 | `5E40-709F` | 4704 | tiles |
| `$11` | 4 | `70A0-70A0` | 1 | zero byte, not read |
| `$11` | 4 | `70A1-7140` | 160 | attribute lookup table |
| `$11` | 4 | `7141-7178` | 56 | bg palettes |
| `$11` | 4 | `7179-7FFE` | 3718 | zero fill |
| `$11` | 4 | `7FFF-7FFF` | 1 | bank marker |
| `$12` | 4 | `4000-5E3F` | 7744 | tilemap |
| `$12` | 4 | `5E40-7C7F` | 7744 | attribute map |
| `$12` | 4 | `7C80-7FFE` | 895 | zero fill |
| `$12` | 4 | `7FFF-7FFF` | 1 | bank marker |
| `$13` | 5 | `4000-5D3F` | 7488 | cellmap |
| `$13` | 5 | `5D40-765F` | 6432 | tiles |
| `$13` | 5 | `7660-7660` | 1 | zero byte, not read |
| `$13` | 5 | `7661-7700` | 160 | attribute lookup table |
| `$13` | 5 | `7701-7738` | 56 | bg palettes |
| `$13` | 5 | `7739-7FFE` | 2246 | zero fill |
| `$13` | 5 | `7FFF-7FFF` | 1 | bank marker |
| `$14` | 5 | `4000-5D3F` | 7488 | tilemap |
| `$14` | 5 | `5D40-7A7F` | 7488 | attribute map |
| `$14` | 5 | `7A80-7FFE` | 1407 | zero fill |
| `$14` | 5 | `7FFF-7FFF` | 1 | bank marker |
| `$15` | 6 | `4000-5B7F` | 7040 | cellmap |
| `$15` | 6 | `5B80-6D0F` | 4496 | tiles |
| `$15` | 6 | `6D10-6D10` | 1 | zero byte, not read |
| `$15` | 6 | `6D11-6DB0` | 160 | attribute lookup table |
| `$15` | 6 | `6DB1-6DD8` | 40 | bg palettes |
| `$15` | 6 | `6DD9-7FFE` | 4646 | zero fill |
| `$15` | 6 | `7FFF-7FFF` | 1 | bank marker |
| `$16` | 6 | `4000-5B7F` | 7040 | tilemap |
| `$16` | 6 | `5B80-76FF` | 7040 | attribute map |
| `$16` | 6 | `7700-7FFE` | 2303 | zero fill |
| `$16` | 6 | `7FFF-7FFF` | 1 | bank marker |
| `$17` | 7 | `4000-5F7F` | 8064 | cellmap |
| `$17` | 7 | `5F80-796F` | 6640 | tiles |
| `$17` | 7 | `7970-7970` | 1 | zero byte, not read |
| `$17` | 7 | `7971-7A10` | 160 | attribute lookup table |
| `$17` | 7 | `7A11-7A38` | 40 | bg palettes |
| `$17` | 7 | `7A39-7FFE` | 1478 | zero fill |
| `$17` | 7 | `7FFF-7FFF` | 1 | bank marker |
| `$18` | 7 | `4000-5F7F` | 8064 | tilemap |
| `$18` | 7 | `5F80-7EFF` | 8064 | attribute map |
| `$18` | 7 | `7F00-7FFE` | 255 | zero fill |
| `$18` | 7 | `7FFF-7FFF` | 1 | bank marker |
| `$19` | 8 | `4000-5F7F` | 8064 | cellmap |
| `$19` | 8 | `5F80-79BF` | 6720 | tiles |
| `$19` | 8 | `79C0-79C0` | 1 | zero byte, not read |
| `$19` | 8 | `79C1-7A60` | 160 | attribute lookup table |
| `$19` | 8 | `7A61-7A98` | 56 | bg palettes |
| `$19` | 8 | `7A99-7FFE` | 1382 | zero fill |
| `$19` | 8 | `7FFF-7FFF` | 1 | bank marker |
| `$1A` | 8 | `4000-5F7F` | 8064 | tilemap |
| `$1A` | 8 | `5F80-7EFF` | 8064 | attribute map |
| `$1A` | 8 | `7F00-7FFE` | 255 | zero fill |
| `$1A` | 8 | `7FFF-7FFF` | 1 | bank marker |
| `$1B` | 9 | `4000-5DFF` | 7680 | cellmap |
| `$1B` | 9 | `5E00-722F` | 5168 | tiles |
| `$1B` | 9 | `7230-7230` | 1 | zero byte, not read |
| `$1B` | 9 | `7231-72D0` | 160 | attribute lookup table |
| `$1B` | 9 | `72D1-7300` | 48 | bg palettes |
| `$1B` | 9 | `7301-7FFE` | 3326 | zero fill |
| `$1B` | 9 | `7FFF-7FFF` | 1 | bank marker |
| `$1C` | 9 | `4000-5DFF` | 7680 | tilemap |
| `$1C` | 9 | `5E00-7BFF` | 7680 | attribute map |
| `$1C` | 9 | `7C00-7FFE` | 1023 | zero fill |
| `$1C` | 9 | `7FFF-7FFF` | 1 | bank marker |
| `$1D` | 10 | `4000-5E3F` | 7744 | cellmap |
| `$1D` | 10 | `5E40-6EBF` | 4224 | tiles |
| `$1D` | 10 | `6EC0-6EC0` | 1 | zero byte, not read |
| `$1D` | 10 | `6EC1-6F60` | 160 | attribute lookup table |
| `$1D` | 10 | `6F61-6F98` | 56 | bg palettes |
| `$1D` | 10 | `6F99-7FFE` | 4198 | zero fill |
| `$1D` | 10 | `7FFF-7FFF` | 1 | bank marker |
| `$1E` | 10 | `4000-5E3F` | 7744 | tilemap |
| `$1E` | 10 | `5E40-7C7F` | 7744 | attribute map |
| `$1E` | 10 | `7C80-7FFE` | 895 | zero fill |
| `$1E` | 10 | `7FFF-7FFF` | 1 | bank marker |
| `$1F` | 11 | `4000-5DFF` | 7680 | cellmap |
| `$1F` | 11 | `5E00-701F` | 4640 | tiles |
| `$1F` | 11 | `7020-7020` | 1 | zero byte, not read |
| `$1F` | 11 | `7021-70C0` | 160 | attribute lookup table |
| `$1F` | 11 | `70C1-70F8` | 56 | bg palettes |
| `$1F` | 11 | `70F9-7FFE` | 3846 | zero fill |
| `$1F` | 11 | `7FFF-7FFF` | 1 | bank marker |
| `$20` | 11 | `4000-5DFF` | 7680 | tilemap |
| `$20` | 11 | `5E00-7BFF` | 7680 | attribute map |
| `$20` | 11 | `7C00-7FFE` | 1023 | zero fill |
| `$20` | 11 | `7FFF-7FFF` | 1 | bank marker |
| `$21` | 12 | `4000-5DFF` | 7680 | cellmap |
| `$21` | 12 | `5E00-6D6F` | 3952 | tiles |
| `$21` | 12 | `6D70-6D70` | 1 | zero byte, not read |
| `$21` | 12 | `6D71-6E10` | 160 | attribute lookup table |
| `$21` | 12 | `6E11-6E48` | 56 | bg palettes |
| `$21` | 12 | `6E49-7FFE` | 4534 | zero fill |
| `$21` | 12 | `7FFF-7FFF` | 1 | bank marker |
| `$22` | 12 | `4000-5DFF` | 7680 | tilemap |
| `$22` | 12 | `5E00-7BFF` | 7680 | attribute map |
| `$22` | 12 | `7C00-7FFE` | 1023 | zero fill |
| `$22` | 12 | `7FFF-7FFF` | 1 | bank marker |
| `$23` | 13 | `4000-5E3F` | 7744 | cellmap |
| `$23` | 13 | `5E40-6E1F` | 4064 | tiles |
| `$23` | 13 | `6E20-6E20` | 1 | zero byte, not read |
| `$23` | 13 | `6E21-6EC0` | 160 | attribute lookup table |
| `$23` | 13 | `6EC1-6EF0` | 48 | bg palettes |
| `$23` | 13 | `6EF1-7FFE` | 4366 | zero fill |
| `$23` | 13 | `7FFF-7FFF` | 1 | bank marker |
| `$24` | 13 | `4000-5E3F` | 7744 | tilemap |
| `$24` | 13 | `5E40-7C7F` | 7744 | attribute map |
| `$24` | 13 | `7C80-7FFE` | 895 | zero fill |
| `$24` | 13 | `7FFF-7FFF` | 1 | bank marker |
| `$25` | 14 | `4000-5DFF` | 7680 | cellmap |
| `$25` | 14 | `5E00-767F` | 6272 | tiles |
| `$25` | 14 | `7680-7680` | 1 | zero byte, not read |
| `$25` | 14 | `7681-7720` | 160 | attribute lookup table |
| `$25` | 14 | `7721-7758` | 56 | bg palettes |
| `$25` | 14 | `7759-7FFE` | 2214 | zero fill |
| `$25` | 14 | `7FFF-7FFF` | 1 | bank marker |
| `$26` | 14 | `4000-5DFF` | 7680 | tilemap |
| `$26` | 14 | `5E00-7BFF` | 7680 | attribute map |
| `$26` | 14 | `7C00-7FFE` | 1023 | zero fill |
| `$26` | 14 | `7FFF-7FFF` | 1 | bank marker |

| Level | Banks | Size (tiles) | Tiles | Palettes | Record | Lookup table |
| --- | --- | --- | ---: | ---: | --- | --- |
| 0 | `$09`/`$0A` | 64 x 64 | 401 | 7 | `05:4400` | `09:6911` |
| 1 | `$0B`/`$0C` | 88 x 88 | 367 | 7 | `05:4414` | `0B:7531` |
| 2 | `$0D`/`$0E` | 72 x 104 | 368 | 7 | `05:4428` | `0D:7441` |
| 3 | `$0F`/`$10` | 168 x 48 | 357 | 6 | `05:443C` | `0F:75D1` |
| 4 | `$11`/`$12` | 88 x 88 | 294 | 7 | `05:4450` | `11:70A1` |
| 5 | `$13`/`$14` | 72 x 104 | 402 | 7 | `05:4464` | `13:7661` |
| 6 | `$15`/`$16` | 88 x 80 | 281 | 5 | `05:4478` | `15:6D11` |
| 7 | `$17`/`$18` | 72 x 112 | 415 | 5 | `05:448C` | `17:7971` |
| 8 | `$19`/`$1A` | 112 x 72 | 420 | 7 | `05:44A0` | `19:79C1` |
| 9 | `$1B`/`$1C` | 64 x 120 | 323 | 6 | `05:44B4` | `1B:7231` |
| 10 | `$1D`/`$1E` | 88 x 88 | 264 | 7 | `05:44C8` | `1D:6EC1` |
| 11 | `$1F`/`$20` | 120 x 64 | 290 | 7 | `05:44DC` | `1F:7021` |
| 12 | `$21`/`$22` | 120 x 64 | 247 | 7 | `05:44F0` | `21:6D71` |
| 13 | `$23`/`$24` | 88 x 88 | 254 | 6 | `05:4504` | `23:6E21` |
| 14 | `$25`/`$26` | 64 x 120 | 392 | 7 | `05:4518` | `25:7681` |
