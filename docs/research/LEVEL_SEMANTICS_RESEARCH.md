# Level semantics: banks $09-$26

Baseline `ae8696ef6adf28ad6984acbb64a9954d4cca854c`. All claims below were
traced in `src/bank_00.asm`, `src/bank_01.asm` and `src/bank_05.asm` and
rechecked against the cartridge bytes.

## Record format (`$05:LevelNN_Record`, 20 bytes; `level_record` macro)

`LoadLevelRecord` copies +0/+1 to `wLevelWidth`/`wLevelHeight` (`$CA09`/`$CA0A`)
and +2..+19 to `$C8B9-$C8CA`.

| Byte | RAM | Meaning | Readers (bank $00 lines) |
| --- | --- | --- | --- |
| +0 | `$CA09` | width | 2993, 3808, 4518, 4625, 4725, 4825, 4863 |
| +1 | `$CA0A` | height | 2981, 3926, 4577, 4618, 4722, 4976 |
| +2 | `$C8B9` | tile bank | 4648 (`LoadLevelTiles`) |
| +3 | `$C8BA` | palette bank | 4693 |
| +4 | `$C8BB` | cell-map bank | 4713 (`LoadLevelCellMap`) |
| +5 | `$C8BC` | tile/attribute map bank | 5131, 5333, 5369, 5511 |
| +6 | `$C8BD` | equals +5; **never read** | none |
| +7/+8 | `$C8BE/F` | tile count - 1; **never read** | none |
| +9 | `$C8C0` | BG palette count | 4700 |
| +10 | `$C8C1` | tiles | 4644 |
| +12 | `$C8C3` | palettes | 4695 |
| +14 | `$C8C5` | attribute map | 5211, 5284 |
| +16 | `$C8C7` | tile map | 5222, 5295 |
| +18 | `$C8C9` | cell map | 4718 |

**+6/+7/+8 remain unresolved.** There is no literal or symbol for
`$C8BD-$C8BF`, and the only pointer into the block (`ld bc, wLevelTileBank`,
the copy loop) writes. +7/+8 matching the tile count in all 15 levels is a
layout fact; nothing consumes it.

## Cell-map bytes (WRAM banks 2-3, `$D000 + wLevelRowOffsets[y] + x`)

Every access goes through `wLevelRowOffsets` (`$CA17`). Offset bit 12 selects
rSVBK 2 or 3. There are 17 access sites.

| Bit | Constant (include/level_data.inc) | Proven effect |
| --- | --- | --- |
| 0 | `CELLB_PASSABLE` | clear: `ResolveObjectLevelBit0Movement` rejects the move (`and $01`, bank $00:4122) |
| 1 | `CELLB_SOLID` | set with bit 2 clear: `HandleObjectLevelBit1And2Cells` rolls flag-bit-3 objects back |
| 2 | `CELLB_DESTRUCTIBLE` | region (cells with bits 2/3) converted by `ConvertLevelCellBit2ToLookupState`: `and $B1 / or $81`, 5 points per cell |
| 3 | `CELLB_TOUCH_REGION` | `HandleObjectLevelBit3Cell` converts the region on contact: sound and 20 points; `and $F1`, bits 0/7 set |
| 4-5 | — | never tested, never set (all masks seen: `$01/$02/$04/$08/$0C/$C0`) |
| 6 | `CELLB_ANIMATED` | set by `StartLevelCellLookupTransition` when bits 2-3 = `%01`; draws tile `$BB + (frame+1)&7`, attribute `[$C8D3]` |
| 7 | `CELLB_LOOKUP` | set on conversion. The tile comes from the `$05` table at `[$C8CE]` (per-tile, 2-bit frame); the attribute comes from `LevelNN_AttrLookup` (`[$C8D0]`, bank `[$C8D2]`) at `newtile + $7F` |

ROM values are only `$00 $01 $02 $03 $06 $08 $09 $0A $0F`. `$0A` appears only
in level 3 (6 cells). Writers after loading are only the three conversion
routines; nothing restores original cells.

The names "destructible" and "touch region" describe the code effects
(conversion and score), not visual content. Bit 1 is named for its
movement rollback.

## Level index (`wLevelNumber`, `$CA06`): bounded to 0-14 on every writer

1. bank $00:78: `inc` only when the old value is not `$0E`.
2. `LoadLevelData` stores its argument; its only caller passes `wLevelNumber`.
3. bank $01:1836: 3 x `wMenuGridRow` (wraps 0-4) + `wMenuGridColumn` (clamped 0-2).
4. bank $01:1851: 0.
5. bank $01:2505: `[$C939]`, reached only when the decoder `Func_01_6C24` accepts
   a value of at most `$0E`.

Uninitialised-RAM and corruption cases were not analysed.

## Per-level comparison and sharing

Machine-readable: `reports/level_comparison.json`.

| Level | Size | Tiles | Palettes | Tiles used | VRAM1 / x-flip / y-flip / priority | Lookup table | Theme |
|---|---|---:|---:|---:|---|---|---|
|0|64x64|401|7|300|984/280/264/0|09:6911|517A|
|1|88x88|367|7|241|1172/991/516/0|0B:7531|517A|
|2|72x104|368|7|277|1130/1769/501/0|0D:7441|517A|
|3|168x48|357|6|240|905/429/359/0|0F:75D1|54CC|
|4|88x88|294|7|164|270/120/70/0|11:70A1|54CC|
|5|72x104|402|7|301|1688/443/197/0|13:7661|54CC|
|6|88x80|281|5|160|164/259/235/0|15:6D11|532D|
|7|72x112|415|5|305|1002/661/379/0|17:7971|532D|
|8|112x72|420|7|317|540/648/502/0|19:79C1|532D|
|9|64x120|323|6|210|596/319/351/0|1B:7231|5800|
|10|88x88|264|7|145|49/668/639/0|1D:6EC1|5800|
|11|120x64|290|7|166|467/177/160/0|1F:7021|5800|
|12|120x64|247|7|144|0/1223/599/42|21:6D71|56A7|
|13|88x88|254|6|141|0/1199/940/0|23:6E21|56A7|
|14|64x120|392|7|289|3920/1367/737/0|25:7681|56A7|

Data is shared within the five theme groups (`$05:$5120`, levels 0-2, 3-5,
6-8, 9-11, 12-14) and stored as separate copies per level:
- tile blocks 0-159 are identical within groups {0,1,2}, {6,7,8}, {9,10,11}
  and {12,13,14};
- lookup tables are identical for {0,1,2}, {7,8}, {10,11} and {13,14}; the
  first level of a group differs by 1-8 bytes;
- full palette sets are equal only for 1=2 and 6=7;
- no map row repeats between levels.

Shared tiles across all levels (28-60 non-blank tiles) look like a common
graphics set placed at shifted offsets. Treating these copies as
intentional sharing is an inference; the code always reads per-level
copies.

Level 14's tile map bytes `$4518-$4BFB` are the source copied into banks
`$27-$29` as unread residue
([`OBJECT_ORIENTATION_RUNTIME_RESEARCH.md`](OBJECT_ORIENTATION_RUNTIME_RESEARCH.md)).
