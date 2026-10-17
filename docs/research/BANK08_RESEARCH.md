# ROM bank $08: interface and object graphics

Baseline: commit `eec41ed5169b91017703cdc4689f43ebf8e34da7`. Rebuild SHA-1
unchanged: `5078584e86c0b6f4687c424cc00bbd762ba6573a`.

## 1. Summary

Every one of the 16,384 bytes is in exactly one range (section 9), checked by
`tools/bank08.py`. The previous description had seven boundary errors, all
corrected here:
1. The UI font is 62 tiles (`$4000-$43DF`), not 74. The last 192 bytes of
   the old asset are a 16-record metatile table.
2. `$44A8-$60EF` holds 69 sprite-tile blocks for two object systems,
   separated by 8-byte palette-shaped records.
3. The "66-tile alphanumeric font" at `$69B5` is actually five things in a
   row: 4 tiles, a palette-shaped record, 8 tiles, 136 unknown bytes, and the
   128-byte glyph table.
4. The encoded-text font is the 37 tiles at `$6B85`.
5. `Bank08ObjectPalette46EA` and `EffectPalette5502` are colours 1-3 of
   8-byte records that start 2 bytes earlier.
6. ROM0 reads BG palette 7 from `$44A2`, 8 bytes, so the read runs 2 bytes
   into the first sprite tile.
7. Unknown bytes dropped from 7,309 to **171**.

| Class | Bytes |
| --- | ---: |
| code | 27 |
| graphics, reader-proven | 9824 |
| graphics, referenced only by unreachable effect steps | 992 |
| graphics, never loaded (UI font tile 0, blank) | 16 |
| palettes read by code | 64 |
| palette-shaped records (12 bytes of them are read: `$46EA`, `$5502`) | 336 |
| tables (metatiles 192, palette-index 10, glyph 128) | 330 |
| unknown | 171 |
| fill + marker | 4624 |
| **total** | **16384** |

**Understood** (format, boundary and reader proven): 14,881 bytes.
- code 27;
- reader-proven graphics 9,824;
- read palettes 64 plus the 12 read bytes in records;
- tables 330;
- fill and marker 4,624.

**Bounded only**: 1,503 bytes.
- 992 graphics reached only by unreachable table entries;
- the 16-byte unloaded tile;
- 324 bytes of unread palette-shaped records;
- 171 unknown bytes.

The two totals sum to 16,384.

## 2. Readers (all verified against ROM code bytes)

| Reader | Bank $08 source | Read | Destination |
| --- | --- | --- | --- |
| `LoadInterfaceTilesVRAM1` | `$60F8` x1, `$6222` x2, `$611A` x16, `$6753` x10, `$6815` x12, `$4010` x61, `$69FD` x8 | `Func_0622` (e, d, page) | VRAM1 BG tiles `$C0`, `$C1`, `$C3`, `$D3`, `$DD`; `$C3-$FF` (font); `$BB` |
| `LoadInterfaceTilesVRAM0` | `$626B` x78, `$68DD` x4, `$6925` x4, `$696D` x4, `$69B5` x4 | same | VRAM0 tiles `$80`, `$CE`, `$D2`, `$D6`, `$DA` |
| `LoadEncodedFontTiles` (ROM0) and `$01:RAM_D9CB` (RAM image of `$01:5718`) | `$6B85` x37 | same | VRAM0 `$8000`; VRAM1 `$8800` |
| `DrawEncodedGlyph` | `$6B05 + char` | 1 byte | BG tile `glyph + $80`, attribute `$0F` (palette 7, VRAM1) |
| `Func_0DB6` type-3 path (`Jump_0E39`) | `$43E0 + 12 * (obj+$19)`; `obj+$19` stored `& $0F` | 12 bytes | 2x3 BG metatile: tile + `$42`, attribute OR `$0F` |
| `Func_3190` (object animation) | bank-`$02` frame tables `$4565-$45BB` (9 tables) | `[obj+$25]` tiles | WRAM staging `$C100+`, HDMA to VRAM1 `$8000`; OAM attribute OR `$0B` |
| `RenderScreenEffect` / `CopyScreenEffectPartTiles` | bank-`$05` step table `$6358` (72 steps x 3 record words; 5-byte records: count, tile source, OAM template) | count x 16 | WRAM staging; OAM attribute OR 3 (OBJ palette 3, VRAM1) |
| `LoadObjectPalettes` | `$46EA` (3 colours, OBJ 3), `$67FD` (4 x 3 colours, OBJ 4-7), `$44A2` (8 bytes, BG 7) | `Func_057D` / `Func_052F` | OCPD / BCPD |
| ROM0 `$3CFB` effect start / ROM0 `$3F00` | `$5502` / `$46EA` (3 colours, OBJ 3) | `Func_057D` | OCPD |
| `LoadInterfacePalettes` | `$44A0`, `$674B`, `$691D`, `$6965`, `$69AD` (8 bytes each) | `CopyBytesShort` | `wUiFontPalette`, `wHudIconPalette`, `wArrowUpPalette`, `wArrowDownPalette`, `wAlphanumericFontPalette` (LOAD blocks kept) |
| `SelectObjectSpritePalette` (`$6DD5`, bank-`$08` code) | `$67F3 + obj+$1E` | 1 byte | `$FF80` = (value & 3) + 4 |

**Selectors.** All bank-`$08` selections are the immediate `$08`. No
computed selector found in earlier audits can produce `$08`.

**Effect step bound.** `wScreenEffectCountdown` starts at 75. `UpdateScreenEffect`
decrements it and advances `wScreenEffectStepTable` by 6 at each non-zero multiple of 4, so steps 0-18 are
reachable. Steps 19-71 are well-formed but unreachable by traced code, and
they are the only references to 992 bytes of tiles (section 9).

The palette-index table index (`obj+$1E`, 10 entries) is bounded only by the
layout. Whether interrupts read `$7FFF` while bank `$08` is mapped was not
checked.

## 3. Formats

- **Glyph table** (`$6B05`, 128 bytes): ASCII code → font tile.
  - `0`-`9` map to 1-10, `A`-`Z` to 11-36, and everything else to 0 (blank).
  - Control codes `$00`, `$01`, `$0C` and `$0D` are handled by
    `DrawEncodedText` before lookup.
  - There is no lowercase or punctuation.
  - All 11 referenced strings (`$01:48C6-49C6`) decode under this table; see
    `build/bank08/strings.csv`.
- **Metatile record** (12 bytes): 3 rows x 2 entries of (tile byte, attribute).
  - Tile bytes `$81-$BD`, plus `$42`, give BG ids `$C3-$FF` = UI font tiles 1-61.
  - Attributes use only bit 5 (x flip). Records 9-15 mirror records 7..1.
- **Effect record** (bank `$05`, 5 bytes): tile count, `dw` tile source in
  bank `$08`, `dw` OAM template (bank `$05`; 4-byte entries y, x, tile,
  attribute).
- **Palette-shaped record**: 4 RGB555 words, colour 0 = `$0000`, bit 15 clear.
  Each one immediately precedes a tile block. Only `$46EA` and `$5502` (colours
  1-3) are read; the others' meaning is unproven.

## 4. Source and assets

`src/bank_08.asm` (generated once by `tools/gen_bank08_asm.py`, now
hand-maintained):
- explicit palettes, tables, unknown bytes and code;
- typed tile INCBINs, with sprite blocks sliced from two concatenated assets;
- legacy labels kept at their addresses (`Bank08AlphanumericFontTiles` = `$69B5`);
- ASSERTs on the key boundaries.

Bank `$00`/`$01` raw addresses `$44A2`, `$46EA`, `$5502`, `$6B05`, `$6B85` and
`Bank08AlphanumericFontTiles + $48` became symbols. The bytes are identical.

The asset lists are in `handoff/`. The two concatenated sprite assets are not
single ROM ranges, so they are not in `assets.txt`. `tools/bank08.py`
derives and checks them.

## 5. Validation

`tools/bank08.py` runs from `check_bank08_graphics_assets` in
`tools/check_project.py`. Its 23 negative tests are each rejected for the
intended reason:
- tile load count;
- glyph table entry;
- glyph value range;
- blank font tile;
- metatile tile range;
- metatile attribute;
- palette bit 15;
- frame-table pointer;
- effect record pointer;
- effect read outside area;
- palette-record colour 0;
- effect table end;
- effect countdown immediate;
- palette-index value;
- fill byte;
- bank marker;
- coverage gap;
- coverage overlap;
- opaque asset reintroduced;
- missing asset;
- asset size;
- asset hash;
- symbol address.

`make bank08` (`tools/extract_bank08.py`) writes `build/bank08/`:
- 83 graphics sheets;
- glyph CSV/JSON;
- strings CSV;
- metatiles PNG/CSV;
- palette report;
- range CSV.

All of them round-trip to the original bytes.

## 6. Rejected hypotheses

- **A 74-tile UI font.** It is 62 tiles plus a metatile table.
- **A 66-tile alphanumeric font at `$69B5`.**
- **`$44A8-$60F7` as one opaque range or duplicated data.** No 32-byte match
  exists elsewhere in the ROM, and there is no previous-bank residue.
- **`$6112-$6119` as a palette.** Its colour 0 is `$001F`, so it stays unknown.
- **The step table ending at step 18.** It has 72 coherent steps; 19-71 are
  unreachable.

## 7. Unresolved

1. 171 unknown bytes: `$6108-$6109` (`81 00`), `$6112-$6119` (`$001F` x4),
   `$624A-$6262` (25 bytes; 16 of them are tile-shaped), and `$6A7D-$6B04`
   (136 high-entropy bytes).
2. The purpose of the 40 unread palette-shaped records (42 in total).
3. Why effect steps 19-71 exist but cannot be reached.
4. The bound on `obj+$1E` for `SelectObjectSpritePalette`.
5. Gameplay identities of the sprites and metatiles. The renders suggest
   effects and a rotating BG object, which is not evidence.
6. Interrupt reads of `$7FFF`.

## 8. Integration order

1. `tools/bank08.py`, then the bank-`$08` assets (add/remove).
2. `src/bank_08.asm`, then the bank `$00`/`$01` symbol edits.
3. `assets.txt` and `graphics.txt`, then `tools/check_project.py`.
4. `tools/extract_bank08.py` and `Makefile`.
5. Docs.

## 9. Range map

| Range | Bytes | Class | Label |
| --- | ---: | --- | --- |
| `4000-400F` | 16 | graphics (not loaded) | UiFontTile0 |
| `4010-43DF` | 976 | graphics | UiFontTiles |
| `43E0-449F` | 192 | table | InterfaceMetatiles |
| `44A0-44A7` | 8 | palette | Bank08UiFontPalette |
| `44A8-4537` | 144 | graphics | SpriteTiles44A8 |
| `4538-45C7` | 144 | graphics | SpriteTiles4538 |
| `45C8-4657` | 144 | graphics | SpriteTiles45C8 |
| `4658-46E7` | 144 | graphics | SpriteTiles4658 |
| `46E8-46EF` | 8 | palette record | PaletteRecord46E8 |
| `46F0-477F` | 144 | graphics | SpriteTiles46F0 |
| `4780-480F` | 144 | graphics | SpriteTiles4780 |
| `4810-489F` | 144 | graphics | SpriteTiles4810 |
| `48A0-492F` | 144 | graphics | SpriteTiles48A0 |
| `4930-49BF` | 144 | graphics | SpriteTiles4930 |
| `49C0-49C7` | 8 | palette record | PaletteRecord49C0 |
| `49C8-4A57` | 144 | graphics | SpriteTiles49C8 |
| `4A58-4AE7` | 144 | graphics | SpriteTiles4A58 |
| `4AE8-4B77` | 144 | graphics | SpriteTiles4AE8 |
| `4B78-4C07` | 144 | graphics | SpriteTiles4B78 |
| `4C08-4C97` | 144 | graphics | SpriteTiles4C08 |
| `4C98-4D27` | 144 | graphics | SpriteTiles4C98 |
| `4D28-4DB7` | 144 | graphics | SpriteTiles4D28 |
| `4DB8-4E47` | 144 | graphics | SpriteTiles4DB8 |
| `4E48-4ED7` | 144 | graphics | SpriteTiles4E48 |
| `4ED8-4F67` | 144 | graphics | SpriteTiles4ED8 |
| `4F68-4FF7` | 144 | graphics | SpriteTiles4F68 |
| `4FF8-4FFF` | 8 | palette record | PaletteRecord4FF8 |
| `5000-503F` | 64 | graphics | SpriteTiles5000 |
| `5040-507F` | 64 | graphics | SpriteTiles5040 |
| `5080-50BF` | 64 | graphics | SpriteTiles5080 |
| `50C0-50FF` | 64 | graphics | SpriteTiles50C0 |
| `5100-5107` | 8 | palette record | PaletteRecord5100 |
| `5108-5147` | 64 | graphics | SpriteTiles5108 |
| `5148-5187` | 64 | graphics | SpriteTiles5148 |
| `5188-51C7` | 64 | graphics | SpriteTiles5188 |
| `51C8-5207` | 64 | graphics | SpriteTiles51C8 |
| `5208-520F` | 8 | palette record | PaletteRecord5208 |
| `5210-524F` | 64 | graphics | SpriteTiles5210 |
| `5250-528F` | 64 | graphics | SpriteTiles5250 |
| `5290-52CF` | 64 | graphics | SpriteTiles5290 |
| `52D0-530F` | 64 | graphics | SpriteTiles52D0 |
| `5310-5317` | 8 | palette record | PaletteRecord5310 |
| `5318-5357` | 64 | graphics | SpriteTiles5318 |
| `5358-5397` | 64 | graphics | SpriteTiles5358 |
| `5398-53D7` | 64 | graphics | SpriteTiles5398 |
| `53D8-5417` | 64 | graphics | SpriteTiles53D8 |
| `5418-541F` | 8 | palette record | PaletteRecord5418 |
| `5420-542F` | 16 | graphics | SpriteTiles5420 |
| `5430-543F` | 16 | graphics | SpriteTiles5430 |
| `5440-544F` | 16 | graphics | SpriteTiles5440 |
| `5450-5457` | 8 | palette record | PaletteRecord5450 |
| `5458-5467` | 16 | graphics | SpriteTiles5458 |
| `5468-5477` | 16 | graphics | SpriteTiles5468 |
| `5478-5487` | 16 | graphics | SpriteTiles5478 |
| `5488-548F` | 8 | palette record | PaletteRecord5488 |
| `5490-54FF` | 112 | graphics | SpriteTiles5490 |
| `5500-5507` | 8 | palette record | PaletteRecord5500 |
| `5508-5597` | 144 | graphics | SpriteTiles5508 |
| `5598-559F` | 8 | palette record | PaletteRecord5598 |
| `55A0-560F` | 112 | graphics | SpriteTiles55A0 |
| `5610-5617` | 8 | palette record | PaletteRecord5610 |
| `5618-5687` | 112 | graphics | SpriteTiles5618 |
| `5688-568F` | 8 | palette record | PaletteRecord5688 |
| `5690-56EF` | 96 | graphics | SpriteTiles5690 |
| `56F0-56F7` | 8 | palette record | PaletteRecord56F0 |
| `56F8-5757` | 96 | graphics | SpriteTiles56F8 |
| `5758-575F` | 8 | palette record | PaletteRecord5758 |
| `5760-57DF` | 128 | graphics | SpriteTiles5760 |
| `57E0-57E7` | 8 | palette record | PaletteRecord57E0 |
| `57E8-5877` | 144 | graphics | SpriteTiles57E8 |
| `5878-587F` | 8 | palette record | PaletteRecord5878 |
| `5880-590F` | 144 | graphics | SpriteTiles5880 |
| `5910-5917` | 8 | palette record | PaletteRecord5910 |
| `5918-5987` | 112 | graphics (unreachable table entries only) | SpriteTiles5918 |
| `5988-598F` | 8 | palette record | PaletteRecord5988 |
| `5990-59EF` | 96 | graphics (unreachable table entries only) | SpriteTiles5990 |
| `59F0-59F7` | 8 | palette record | PaletteRecord59F0 |
| `59F8-5A57` | 96 | graphics (unreachable table entries only) | SpriteTiles59F8 |
| `5A58-5A5F` | 8 | palette record | PaletteRecord5A58 |
| `5A60-5ACF` | 112 | graphics | SpriteTiles5A60 |
| `5AD0-5AD7` | 8 | palette record | PaletteRecord5AD0 |
| `5AD8-5B57` | 128 | graphics | SpriteTiles5AD8 |
| `5B58-5B5F` | 8 | palette record | PaletteRecord5B58 |
| `5B60-5BEF` | 144 | graphics | SpriteTiles5B60 |
| `5BF0-5BF7` | 8 | palette record | PaletteRecord5BF0 |
| `5BF8-5C37` | 64 | graphics (unreachable table entries only) | SpriteTiles5BF8 |
| `5C38-5C3F` | 8 | palette record | PaletteRecord5C38 |
| `5C40-5C9F` | 96 | graphics (unreachable table entries only) | SpriteTiles5C40 |
| `5CA0-5CA7` | 8 | palette record | PaletteRecord5CA0 |
| `5CA8-5D07` | 96 | graphics (unreachable table entries only) | SpriteTiles5CA8 |
| `5D08-5D0F` | 8 | palette record | PaletteRecord5D08 |
| `5D10-5D3F` | 48 | graphics (unreachable table entries only) | SpriteTiles5D10 |
| `5D40-5D47` | 8 | palette record | PaletteRecord5D40 |
| `5D48-5D87` | 64 | graphics (unreachable table entries only) | SpriteTiles5D48 |
| `5D88-5D8F` | 8 | palette record | PaletteRecord5D88 |
| `5D90-5DBF` | 48 | graphics (unreachable table entries only) | SpriteTiles5D90 |
| `5DC0-5DC7` | 8 | palette record | PaletteRecord5DC0 |
| `5DC8-5E37` | 112 | graphics | SpriteTiles5DC8 |
| `5E38-5E3F` | 8 | palette record | PaletteRecord5E38 |
| `5E40-5F0F` | 208 | graphics | SpriteTiles5E40 |
| `5F10-5F17` | 8 | palette record | PaletteRecord5F10 |
| `5F18-5FC7` | 176 | graphics | SpriteTiles5F18 |
| `5FC8-5FCF` | 8 | palette record | PaletteRecord5FC8 |
| `5FD0-602F` | 96 | graphics (unreachable table entries only) | SpriteTiles5FD0 |
| `6030-6037` | 8 | palette record | PaletteRecord6030 |
| `6038-6077` | 64 | graphics (unreachable table entries only) | SpriteTiles6038 |
| `6078-607F` | 8 | palette record | PaletteRecord6078 |
| `6080-60EF` | 112 | graphics (unreachable table entries only) | SpriteTiles6080 |
| `60F0-60F7` | 8 | palette record | PaletteRecord60F0 |
| `60F8-6107` | 16 | graphics | Bank08InterfaceTiles60F8 |
| `6108-6109` | 2 | unknown | Bank08Unknown6108 |
| `610A-6111` | 8 | palette record | PaletteRecord610A |
| `6112-6119` | 8 | unknown | Bank08Unknown6112 |
| `611A-6219` | 256 | graphics | Bank08InterfaceTiles611A |
| `621A-6221` | 8 | palette record | PaletteRecord621A |
| `6222-6241` | 32 | graphics | Bank08InterfaceTiles6222 |
| `6242-6249` | 8 | palette record | PaletteRecord6242 |
| `624A-6262` | 25 | unknown | Bank08Unknown624A |
| `6263-626A` | 8 | palette record | PaletteRecord6263 |
| `626B-674A` | 1248 | graphics | Bank08InterfaceTiles626B |
| `674B-6752` | 8 | palette | Bank08HudIconPalette |
| `6753-67F2` | 160 | graphics | Bank08HudIconTiles |
| `67F3-67FC` | 10 | table | ObjectSpritePaletteIndexTable |
| `67FD-6814` | 24 | palette | Bank08ObjectPalettes67FD |
| `6815-68D4` | 192 | graphics | Bank08InterfaceTiles6815 |
| `68D5-68DC` | 8 | palette record | Bank08InterfacePalette68D5 |
| `68DD-691C` | 64 | graphics | Bank08InterfaceTiles68DD |
| `691D-6924` | 8 | palette | Bank08ArrowUpPalette |
| `6925-6964` | 64 | graphics | Bank08ArrowUpTiles |
| `6965-696C` | 8 | palette | Bank08ArrowDownPalette |
| `696D-69AC` | 64 | graphics | Bank08ArrowDownTiles |
| `69AD-69B4` | 8 | palette | Bank08AlphanumericFontPalette |
| `69B5-69F4` | 64 | graphics | Bank08InterfaceTiles69B5 |
| `69F5-69FC` | 8 | palette record | PaletteRecord69F5 |
| `69FD-6A7C` | 128 | graphics | Bank08InterfaceTiles69FD |
| `6A7D-6B04` | 136 | unknown | Bank08Unknown6A7D |
| `6B05-6B84` | 128 | table | EncodedGlyphTable |
| `6B85-6DD4` | 592 | graphics | EncodedFontTiles |
| `6DD5-6DEF` | 27 | code | SelectObjectSpritePalette |
| `6DF0-7FFE` | 4623 | fill | fill |
| `7FFF-7FFF` | 1 | marker | bank marker |
