# ROM banks $2A-$2E: full-screen pictures

## 1. Scope and baseline

- Scope: ROM banks `$2A`-`$2E` (5 x `$4000` bytes). Other banks were read only.
- Immutable baseline: commit `42b4125d1c11b96ddc99383009bd9c24924d72dc`,
  exported with `git archive` into `BattleTanx-GBC-banks2A-2E-baseline`.
- Baseline `make clean && make check`: SHA-1
  `5078584e86c0b6f4687c424cc00bbd762ba6573a`; trace 38,772 direct bytes,
  0 heuristic, 31 RAM code images, 7 RAM data images. At the baseline,
  banks `$2A`-`$2E` had 59 address-based labels and 13 opaque INCBIN ranges
  (63,613 bytes).
- After this pass the SHA-1 and trace counts are unchanged.

Addresses are CPU addresses; `BB:AAAA` is bank `BB`. Words are little-endian.

## 2. Summary

The five banks hold **17 full-screen CGB pictures** and **30 routines**. No
byte is left opaque.

- 13 *screen packages*. Each is a load routine, a draw routine, a 14-byte
  descriptor, 2bpp tiles, a tile map, an attribute map and BG palettes.
  Twelve of them are the 13 entries of `ScreenModeTable` (`01:47EC`;
  entries 9 and 10 share one package). The thirteenth, in bank `$2E`, has no
  caller.
- One fixed, animated screen in bank `$2A`: 4 routines, a 4-frame sheet and
  a frame table.
- Two pictures in bank `$2E` with no descriptor, reached through the bank-`$01`
  table at `$596D`. Entry 2 of that table is the bank-`$2E` package picture.

There are no `jp hl`, jump tables, RAM-copied code, object records or text
strings in these banks. Text appears only inside pictures.

## 3. Byte inventory

See section 17 for the full range map. Classes:
- **code**: decoded instructions;
- **structured data**: descriptors, maps, palettes, frame table;
- **tiles**: native 2bpp, held as typed INCBINs;
- **padding**: zero fill, bank markers, and four all-zero tile slots.

| Bank | Total | Code | Structured data | Tiles (typed payload) | Padding | Opaque | Routines named | Address-only routines |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `$2A` | 16384 | 613 | 2716 | 10992 | 2063 | 0 | 8 | 0 |
| `$2B` | 16384 | 585 | 2450 | 10976 | 2373 | 0 | 6 | 0 |
| `$2C` | 16384 | 993 | 4534 | 10336 | 521 | 0 | 10 | 0 |
| `$2D` | 16384 | 408 | 1508 | 6608 | 7860 | 0 | 4 | 0 |
| `$2E` | 16384 | 204 | 2486 | 12880 | 814 | 0 | 2 | 0 |

Indirect branches in these banks: 0 resolved / 0 unresolved. External dispatch into them: 2 sites (ROM0 `$39C3`, `$39F0`), both resolved.

Direct traced instruction bytes equal the code column (2,803). Heuristic
decoding: 0. Bank `$2E`'s 204 code bytes are reached only from the
tracer's seeded entry `(0x2E, 0x4000)`. They are byte-identical to the
template routines, but no caller is known.

## 4. Call graph summary

```
ROM0 ScreenTable_CallInit  (a = mode, jp hl at $39C3) -> ScreenModeNN_LoadTiles
ROM0 ScreenTable_CallUpdate (a = mode, bc = BG offset pushed, jp hl at $39F0) -> ScreenModeNN_Draw
ScreenModeNN_LoadTiles -> Func_0622 (VRAM tile copy) x3
ScreenModeNN_Draw (fade)  -> Func_05B7 (copy descriptor to wScreenDescriptor), Func_05C5 (maps),
                             Func_3A88 (fade buffer, 8 palettes), Func_3A2F -> $02:474B (32 steps),
                             Func_3A52 + Audio_Update per frame (32 frames)
ScreenModeNN_Draw (plain) -> Func_05B7, Func_05C5, Func_052F (palettes), one VBlank wait
ROM0 $3F28 -> FixedScreen2A_Run -> FixedScreen2A_LoadTiles, FixedScreen2A_Draw,
                                   Func_3971 (wait), FixedScreen2A_DrawFrame
```

## 5. Entry points

| Routine | Address | Caller / dispatch | Notes |
| --- | --- | --- | --- |
| ScreenModeNN_LoadTiles (12) | see section 17 | `ScreenModeTable` +2, via `$39C3` | copies 384 tiles |
| ScreenModeNN_Draw (12) | load + 88 | `ScreenModeTable` +4, via `$39F0` | BG offset at sp+4 |
| Screen2E_LoadTiles / _Draw | `2E:4000` / `2E:4058` | none found | identical to the template |
| FixedScreen2A_Run | `2A:7774` | ROM0 `$3F28` | loops until `$C6B5` != 0 |
| FixedScreen2A_LoadTiles, _Draw, _DrawFrame | `2A:7719`, `7754`, `7795` | FixedScreen2A_Run | |

## 6. Cross-bank calls

From these banks into ROM0: `Func_0622`, `Func_05B7`, `Func_05C5`,
`Func_052F`, `Func_3A88`, `Func_3A2F` (which maps bank `$02`), `Func_3A52`,
`Func_3960` (bank `$02:46E1`), `Func_3971`, `Audio_Update`. None of these
routines switches banks directly; `Func_3A88` maps the caller's own bank
(`[ROM_BANK_MARKER]`) while it copies palettes.

Into these banks: the ScreenTable dispatchers (ROM0), ROM0 `$3F28`, and the
bank-`$01` routines `$01:7981`, `RAM_D7CB` and `RAM_D88B`. Those read
picture data with bank `$2C` or `$2E` selected through `$C943`/`$DBFB`.

## 7. Indirect control flow

| Site | Calculation | Bounds | Targets |
| --- | --- | --- | --- |
| ROM0 `$39C3` (`jp hl`) | `ScreenModeTable + 8*a`, word +2, bank +0 | `a` is an immediate {0,2,5,6,7,8,10,12} or menu-state byte +1 {0,1,3,4,11} | 12 LoadTiles routines (entry 9 is never selected but equals entry 10) |
| ROM0 `$39F0` (`jp hl`) | same entry, word +4; pushes return `$39F1` | same | 12 Draw routines |

Inside banks `$2A`-`$2E`: 0 indirect branches. Every target set above is
resolved. The validator checks each table entry against the parsed packages.
One assumption remains: `wMenuState` always points at a `menu_state` record.

## 8. RAM variables (added to `include/memory.inc`)

| Symbol | Address | Evidence |
| --- | --- | --- |
| `wPaletteFadeFromWhite` | `$C6D1` | read by `$02:474B`: 0 selects `$01:46B1` (subtract per channel), non-zero `$01:4703` (add) while building the 32 steps backward from the target |
| `wScreenDescriptor` | `$C6D2` | 14-byte copy by Func_05B7 in every draw routine |
| `wScreenWidth` / `wScreenHeight` | `$C6DC` / `$C6DD` | descriptor +10/+11, read by ROM0 `$05C5`; FixedScreen2A_Draw stores 20/18 |

Not named: `$C6B5`, the stop signal for FixedScreen2A_Run. It is cleared by
`Func_3971` and set elsewhere for reasons not traced.

## 9. Data formats

**Screen descriptor (14 bytes, `screen_descriptor` macro):**

| Offset | Size | Field |
| --- | --- | --- |
| +0 | 2 | tiles pointer |
| +2 | 2 | tile map pointer |
| +4 | 2 | attribute map pointer |
| +6 | 2 | palettes pointer |
| +8 | 2 | tile count (never read; equals highest tile used + 1 in every picture) |
| +10 | 1 | width |
| +11 | 1 | height |
| +12 | 1 | palette count (plain draw only) |
| +13 | 1 | first palette (plain draw only; always 0) |

The fade draw reads byte +12 into `e` and then overwrites it with `$40`, so it
always copies 8 palettes (64 bytes). For packages with fewer palettes, those
64 bytes include whatever follows the palettes.

**Layout:** descriptor, tiles, tile map, attribute map, palettes, all
contiguous. There are three exceptions:
- `ScreenMode06`'s descriptor follows its palettes (`2C:7DF9`).
- `ScreenMode03`'s descriptor sits after `ScreenMode06`'s code, and its maps
  are interleaved as alt tile map, tile map, alt attribute map, attribute map.
- Four packages (`ScreenMode05`, `07`, `09`, `12`) carry one all-zero tile
  after the counted tiles that no map references.

Map sizes are 20 x 17, 18 or 19, and 22 x 20 (`ScreenMode07`).

**Tile numbering:** VRAM0 ids `$80-$FF` map to tiles 0-127, ids `$00-$7F` to
tiles 128-255, and VRAM1 ids `$00-$7F` to tiles 256-383. The fixed `$2A`
screen also uses VRAM1 ids `$80-$FF` for tiles 384-511.

**Attributes:**
- bits 0-2 palette, always below the palette count;
- bit 3 VRAM bank;
- bits 5/6 flips (only in `ScreenMode02`);
- bit 4 always clear.

**Fixed screen (`2A:4000-61D7`):**
- 464 tiles;
- 20x18 tile map and attribute map;
- a 20x11 frame sheet holding four 5x11 frames;
- 8 palettes;
- `FixedScreen2A_FrameTable`: 4 entries of (`dw` frame tiles, `dw` frame
  attributes) at `sheet + 5*n`.

The loader copies 512 tiles, so 48 of them come from the maps.

**`$01:$596D` table** (bank `$01`, outside this scope; read only):
- 16-byte entries: `db bank`, `dw` tiles, tile map, attribute map,
  palettes, `db $40`, then zeros.
- Entries 0-2 name bank `$2E`; entry 2 is `Screen2E`.
- Entry 3 onward is not this format. The index used by `RAM_D7CB` is not
  bounded by this work.

## 10. RAM-copied regions

No code or data from these banks is copied into a `LOAD` image. At run
time, Func_3A88 copies 64 palette bytes to WRAM bank 2 `$D7C0`, and maps
and tiles go directly to VRAM.

## 11. Shared structure

| Routine family | Copies | Size | Differences |
| --- | --- | --- | --- |
| `screen_load_tiles` | 13 | 88 | descriptor operand only |
| `screen_draw_fade` | 10 | 116 | descriptor; `wPaletteFadeFromWhite` value (1 only in ScreenMode07) |
| `screen_draw_plain` | 3 | 89 | descriptor only |

The validator compares every copy byte for byte with the first copy of its
family, with descriptor operands masked. The macros only take the
descriptor and the fade value as parameters, so no difference is hidden.

The earlier note that `$4000`/`$4058` was a shared bank layout was half
right. Every package in all five banks uses the same template, and
`$4000`/`$4058` is simply where the first package of a bank starts.

## 12. Rename ledger

| Old symbol | New symbol | Address | Evidence | Confidence |
| --- | --- | --- | --- | --- |
| Func_2D_54FA | ScreenMode00_LoadTiles (alias kept) | 2D:54FA | ScreenModeTable entries 0; 3 x Func_0622 from descriptor tiles | high |
| Func_2D_5552 | ScreenMode00_Draw (alias kept) | 2D:5552 | descriptor copy, Func_05C5 maps, fade from black | high |
| Func_2A_61D8 | ScreenMode01_LoadTiles (alias kept) | 2A:61D8 | ScreenModeTable entries 1; 3 x Func_0622 from descriptor tiles | high |
| Func_2A_6230 | ScreenMode01_Draw (alias kept) | 2A:6230 | descriptor copy, Func_05C5 maps, fade from black | high |
| Func_2C_4000 | ScreenMode02_LoadTiles (alias kept) | 2C:4000 | ScreenModeTable entries 2; 3 x Func_0622 from descriptor tiles | high |
| Func_2C_4058 | ScreenMode02_Draw (alias kept) | 2C:4058 | descriptor copy, Func_05C5 maps, fade from black | high |
| Func_2C_5ED3 | ScreenMode03_LoadTiles (alias kept) | 2C:5ED3 | ScreenModeTable entries 3; 3 x Func_0622 from descriptor tiles | high |
| Func_2C_5F2B | ScreenMode03_Draw (alias kept) | 2C:5F2B | descriptor copy, Func_05C5 maps, fade from black | high |
| Func_2B_6E6C | ScreenMode04_LoadTiles (alias kept) | 2B:6E6C | ScreenModeTable entries 4; 3 x Func_0622 from descriptor tiles | high |
| Func_2B_6EC4 | ScreenMode04_Draw (alias kept) | 2B:6EC4 | descriptor copy, Func_05C5 maps, no fade | high |
| Func_2C_4B3A | ScreenMode05_LoadTiles (alias kept) | 2C:4B3A | ScreenModeTable entries 5; 3 x Func_0622 from descriptor tiles | high |
| Func_2C_4B92 | ScreenMode05_Draw (alias kept) | 2C:4B92 | descriptor copy, Func_05C5 maps, fade from black | high |
| Func_2C_5F9F | ScreenMode06_LoadTiles (alias kept) | 2C:5F9F | ScreenModeTable entries 6; 3 x Func_0622 from descriptor tiles | high |
| Func_2C_5FF7 | ScreenMode06_Draw (alias kept) | 2C:5FF7 | descriptor copy, Func_05C5 maps, fade from black | high |
| Func_2B_4000 | ScreenMode07_LoadTiles (alias kept) | 2B:4000 | ScreenModeTable entries 7; 3 x Func_0622 from descriptor tiles | high |
| Func_2B_4058 | ScreenMode07_Draw (alias kept) | 2B:4058 | descriptor copy, Func_05C5 maps, fade from white | high |
| Func_2D_4000 | ScreenMode08_LoadTiles (alias kept) | 2D:4000 | ScreenModeTable entries 8; 3 x Func_0622 from descriptor tiles | high |
| Func_2D_4058 | ScreenMode08_Draw (alias kept) | 2D:4058 | descriptor copy, Func_05C5 maps, fade from black | high |
| Func_2B_5BDA | ScreenMode09_LoadTiles (alias kept) | 2B:5BDA | ScreenModeTable entries 9,10; 3 x Func_0622 from descriptor tiles | high |
| Func_2B_5C32 | ScreenMode09_Draw (alias kept) | 2B:5C32 | descriptor copy, Func_05C5 maps, fade from black | high |
| Func_2C_55C4 | ScreenMode11_LoadTiles (alias kept) | 2C:55C4 | ScreenModeTable entries 11; 3 x Func_0622 from descriptor tiles | high |
| Func_2C_561C | ScreenMode11_Draw (alias kept) | 2C:561C | descriptor copy, Func_05C5 maps, no fade | high |
| Func_2A_6A22 | ScreenMode12_LoadTiles (alias kept) | 2A:6A22 | ScreenModeTable entries 12; 3 x Func_0622 from descriptor tiles | high |
| Func_2A_6A7A | ScreenMode12_Draw (alias kept) | 2A:6A7A | descriptor copy, Func_05C5 maps, no fade | high |
| Func_2E_4000 | Screen2E_LoadTiles (alias kept) | 2E:4000 | no caller; template-identical; 3 x Func_0622 from descriptor tiles | high |
| Func_2E_4058 | Screen2E_Draw (alias kept) | 2E:4058 | descriptor copy, Func_05C5 maps, fade from black | high |
| Func_2A_7719 | FixedScreen2A_LoadTiles | 2A:7719 | 4 x Func_0622 from `$4000` | high |
| Func_2A_7754 | FixedScreen2A_Draw | 2A:7754 | sets width/height, Func_05C5, 8 palettes | high |
| Func_2A_7774 | FixedScreen2A_Run (alias kept) | 2A:7774 | loop over frames until `$C6B5` | high |
| Func_2A_7795 | FixedScreen2A_DrawFrame | 2A:7795 | 5x11 copy to `$980F` from frame table | high |

The address-based labels of the 26 package routines and of `Func_2A_7774`
are kept as aliases at the same addresses, so `ScreenModeTable` (bank
`$01`) and ROM0 `$3F28` need no edits. Internal `Jump_*` labels became
local labels.

## 13. Rejected hypotheses

- **"Init/update" routine pairs.** The second routine is a one-shot draw that
  takes a BG-map offset argument, not a per-frame update.
- **`$01:7981` reading `$6CE9`/`$6FB9` in bank `$2E`.** `$01:7981` writes `$2C` to
  `$C943` before the draw (`RAM_D88B` maps `[$C943]`), so the bank is `$2C`.
  Those addresses are exactly ScreenMode03's interleaved alternate maps.
- **The fade draw honouring the palette count.** It always loads 8 palettes.
- **The 360-byte surplus after ScreenMode03's tiles being tile data.** It is a
  complete 20x18 map; `max tile = count - 1` holds without it.
- **Naming from visible text.** The ScreenMode03 picture reads "ENTER PASSWORD"
  and its alternate maps "ACCESS DENIED". That is noted here only; the labels
  stay neutral because the gameplay path selecting them was not traced.

## 14. Unresolved

1. `Screen2E_LoadTiles`/`_Draw` (`2E:4000-40CB`): no caller found.
2. `$C6B5`: what sets it (FixedScreen2A_Run's exit condition).
3. Descriptor +8, and +12/+13 in fade packages, are never read.
4. The `$01:$596D` index bound (entries 0-2 valid).
5. ScreenModeTable entry 9 is never selected.
6. The `wMenuState` record assumption (section 7).
7. Picture meanings and screen names are not assigned.
8. Nothing was checked on hardware.

## 15. Validation and negative tests

- `tools/screen_data.py` derives everything from the ROM:
  - mode-table targets;
  - routine templates;
  - the fade value;
  - descriptor layout and contiguity;
  - tile counts against map use;
  - palette bit 15;
  - attribute ranges;
  - zero tile slots;
  - alternate maps;
  - the fixed-screen layout and frame table;
  - the `$596D` entries;
  - zero fill, markers, and exact byte coverage.
- `tools/check_project.py` (`check_screen_banks`) adds three checks: the
  typed `assets.txt` ranges, the absence of whole-bank blobs, and linked
  symbol addresses.
- 18 controlled negative tests mutate an in-memory ROM copy, manifest,
  source text or symbol table. Each must be rejected for its own reason:
  - mode table target;
  - load template;
  - fade template;
  - fade value;
  - plain template;
  - descriptor tile count;
  - map tile range;
  - attribute palette;
  - palette bit 15;
  - zero tile slot;
  - fixed-screen frame table;
  - picture table;
  - zero fill;
  - bank marker;
  - manifest missing range;
  - manifest shifted range;
  - opaque blob in source;
  - symbol address.
- `make screens` (`tools/extract_screen_data.py`) writes CSV, JSON, palette
  and PNG files under `build/screens`. All of them round-trip back to the
  original bytes.

## 16. Clean build output

```
make clean
make check
baserom.gbc: OK (sha1 5078584e86c0b6f4687c424cc00bbd762ba6573a)
battletanx.gbc: OK (sha1 5078584e86c0b6f4687c424cc00bbd762ba6573a)
trace: 38772 direct bytes, 0 heuristic bytes, 31 RAM code images, 7 RAM data images
audio: 37 patches, 25 sfx sequences, 10 music sequences, 32 queued ids checked
screens: banks $2A-$2E fully classified (code 2803, data 13694, graphics 51792, padding 13631), 13 screen packages, 18 negative tests rejected
project: OK (98 assets, baserom sha1 5078584e86c0b6f4687c424cc00bbd762ba6573a)
graphics: 61 sheets extracted and round-trip verified
scene maps: 11 fixed scenes (2640 cells), 36 scrolling scenes (709 rows, 14180 cells) rendered and verified
screens: 17 pictures; CSV, palette and PNG outputs round-trip verified
```

## 17. Integration notes

- New files: `include/screen_data.inc`, `tools/screen_data.py`,
  `tools/extract_screen_data.py`, `tools/gen_screen_asm.py`, and this
  document.
- Shared-file edits, each a small addition:
  - `include/memory.inc`: 4 symbols at the end;
  - `src/main.asm`: one include after `memory.inc`;
  - `assets.txt`: 13 bank lines become 16 typed tile ranges;
  - `Makefile`: `screens` target, and `screens` added to `check`;
  - `tools/check_project.py`: `SCREEN_SYMBOLS`, `check_screen_banks`, one call;
  - `docs/STATUS.md`: one row and a short section.
- `tools/gen_screen_asm.py` was run once. It owns no file now and must not
  be rerun over edited source.

## 18. Range map

| Bank | Start | End | Bytes | Class | Item |
| --- | --- | --- | ---: | --- | --- |
| `$2A` | `4000` | `5D00` | 7424 | graphics | FixedScreen2A_Tiles |
| `$2A` | `5D00` | `5E68` | 360 | data | FixedScreen2A_TileMap |
| `$2A` | `5E68` | `5F44` | 220 | data | FixedScreen2A_FrameTileMap |
| `$2A` | `5F44` | `60AC` | 360 | data | FixedScreen2A_AttrMap |
| `$2A` | `60AC` | `6188` | 220 | data | FixedScreen2A_FrameAttrMap |
| `$2A` | `6188` | `61C8` | 64 | data | FixedScreen2A_Palettes |
| `$2A` | `61C8` | `61D8` | 16 | data | FixedScreen2A_FrameTable |
| `$2A` | `61D8` | `6230` | 88 | code | ScreenMode01_LoadTiles |
| `$2A` | `6230` | `62A4` | 116 | code | ScreenMode01_Draw |
| `$2A` | `62A4` | `62B2` | 14 | data | ScreenMode01_Descriptor |
| `$2A` | `62B2` | `6762` | 1200 | graphics | ScreenMode01_Tiles |
| `$2A` | `6762` | `68B6` | 340 | data | ScreenMode01 tilemap |
| `$2A` | `68B6` | `6A0A` | 340 | data | ScreenMode01 attrmap |
| `$2A` | `6A0A` | `6A22` | 24 | data | ScreenMode01_Palettes |
| `$2A` | `6A22` | `6A7A` | 88 | code | ScreenMode12_LoadTiles |
| `$2A` | `6A7A` | `6AD3` | 89 | code | ScreenMode12_Draw |
| `$2A` | `6AD3` | `6AE1` | 14 | data | ScreenMode12_Descriptor |
| `$2A` | `6AE1` | `7421` | 2368 | graphics | ScreenMode12_Tiles |
| `$2A` | `7421` | `7431` | 16 | padding | ScreenMode12 zero tile slot |
| `$2A` | `7431` | `7599` | 360 | data | ScreenMode12 tilemap |
| `$2A` | `7599` | `7701` | 360 | data | ScreenMode12 attrmap |
| `$2A` | `7701` | `7719` | 24 | data | ScreenMode12_Palettes |
| `$2A` | `7719` | `7754` | 59 | code | FixedScreen2A_LoadTiles |
| `$2A` | `7754` | `7774` | 32 | code | FixedScreen2A_Draw |
| `$2A` | `7774` | `7795` | 33 | code | FixedScreen2A_Run |
| `$2A` | `7795` | `7801` | 108 | code | FixedScreen2A_DrawFrame |
| `$2A` | `7801` | `7FFF` | 2046 | padding | zero fill |
| `$2A` | `7FFF` | `8000` | 1 | padding | bank marker |
| `$2B` | `4000` | `4058` | 88 | code | ScreenMode07_LoadTiles |
| `$2B` | `4058` | `40CC` | 116 | code | ScreenMode07_Draw |
| `$2B` | `40CC` | `40DA` | 14 | data | ScreenMode07_Descriptor |
| `$2B` | `40DA` | `581A` | 5952 | graphics | ScreenMode07_Tiles |
| `$2B` | `581A` | `582A` | 16 | padding | ScreenMode07 zero tile slot |
| `$2B` | `582A` | `59E2` | 440 | data | ScreenMode07 tilemap |
| `$2B` | `59E2` | `5B9A` | 440 | data | ScreenMode07 attrmap |
| `$2B` | `5B9A` | `5BDA` | 64 | data | ScreenMode07_Palettes |
| `$2B` | `5BDA` | `5C32` | 88 | code | ScreenMode09_LoadTiles |
| `$2B` | `5C32` | `5CA6` | 116 | code | ScreenMode09_Draw |
| `$2B` | `5CA6` | `5CB4` | 14 | data | ScreenMode09_Descriptor |
| `$2B` | `5CB4` | `6B84` | 3792 | graphics | ScreenMode09_Tiles |
| `$2B` | `6B84` | `6B94` | 16 | padding | ScreenMode09 zero tile slot |
| `$2B` | `6B94` | `6CFC` | 360 | data | ScreenMode09 tilemap |
| `$2B` | `6CFC` | `6E64` | 360 | data | ScreenMode09 attrmap |
| `$2B` | `6E64` | `6E6C` | 8 | data | ScreenMode09_Palettes |
| `$2B` | `6E6C` | `6EC4` | 88 | code | ScreenMode04_LoadTiles |
| `$2B` | `6EC4` | `6F1D` | 89 | code | ScreenMode04_Draw |
| `$2B` | `6F1D` | `6F2B` | 14 | data | ScreenMode04_Descriptor |
| `$2B` | `6F2B` | `73FB` | 1232 | graphics | ScreenMode04_Tiles |
| `$2B` | `73FB` | `7563` | 360 | data | ScreenMode04 tilemap |
| `$2B` | `7563` | `76CB` | 360 | data | ScreenMode04 attrmap |
| `$2B` | `76CB` | `76DB` | 16 | data | ScreenMode04_Palettes |
| `$2B` | `76DB` | `7FFF` | 2340 | padding | zero fill |
| `$2B` | `7FFF` | `8000` | 1 | padding | bank marker |
| `$2C` | `4000` | `4058` | 88 | code | ScreenMode02_LoadTiles |
| `$2C` | `4058` | `40CC` | 116 | code | ScreenMode02_Draw |
| `$2C` | `40CC` | `40DA` | 14 | data | ScreenMode02_Descriptor |
| `$2C` | `40DA` | `483A` | 1888 | graphics | ScreenMode02_Tiles |
| `$2C` | `483A` | `49A2` | 360 | data | ScreenMode02 tilemap |
| `$2C` | `49A2` | `4B0A` | 360 | data | ScreenMode02 attrmap |
| `$2C` | `4B0A` | `4B3A` | 48 | data | ScreenMode02_Palettes |
| `$2C` | `4B3A` | `4B92` | 88 | code | ScreenMode05_LoadTiles |
| `$2C` | `4B92` | `4C06` | 116 | code | ScreenMode05_Draw |
| `$2C` | `4C06` | `4C14` | 14 | data | ScreenMode05_Descriptor |
| `$2C` | `4C14` | `52D4` | 1728 | graphics | ScreenMode05_Tiles |
| `$2C` | `52D4` | `52E4` | 16 | padding | ScreenMode05 zero tile slot |
| `$2C` | `52E4` | `544C` | 360 | data | ScreenMode05 tilemap |
| `$2C` | `544C` | `55B4` | 360 | data | ScreenMode05 attrmap |
| `$2C` | `55B4` | `55C4` | 16 | data | ScreenMode05_Palettes |
| `$2C` | `55C4` | `561C` | 88 | code | ScreenMode11_LoadTiles |
| `$2C` | `561C` | `5675` | 89 | code | ScreenMode11_Draw |
| `$2C` | `5675` | `5683` | 14 | data | ScreenMode11_Descriptor |
| `$2C` | `5683` | `5BF3` | 1392 | graphics | ScreenMode11_Tiles |
| `$2C` | `5BF3` | `5D5B` | 360 | data | ScreenMode11 tilemap |
| `$2C` | `5D5B` | `5EC3` | 360 | data | ScreenMode11 attrmap |
| `$2C` | `5EC3` | `5ED3` | 16 | data | ScreenMode11_Palettes |
| `$2C` | `5ED3` | `5F2B` | 88 | code | ScreenMode03_LoadTiles |
| `$2C` | `5F2B` | `5F9F` | 116 | code | ScreenMode03_Draw |
| `$2C` | `5F9F` | `5FF7` | 88 | code | ScreenMode06_LoadTiles |
| `$2C` | `5FF7` | `606B` | 116 | code | ScreenMode06_Draw |
| `$2C` | `606B` | `6079` | 14 | data | ScreenMode03_Descriptor |
| `$2C` | `6079` | `6CE9` | 3184 | graphics | ScreenMode03_Tiles |
| `$2C` | `6CE9` | `6E51` | 360 | data | ScreenMode03 alt tilemap |
| `$2C` | `6E51` | `6FB9` | 360 | data | ScreenMode03 tilemap |
| `$2C` | `6FB9` | `7121` | 360 | data | ScreenMode03 alt attrmap |
| `$2C` | `7121` | `7289` | 360 | data | ScreenMode03 attrmap |
| `$2C` | `7289` | `72A9` | 32 | data | ScreenMode03_Palettes |
| `$2C` | `72A9` | `7B09` | 2144 | graphics | ScreenMode06_Tiles |
| `$2C` | `7B09` | `7C71` | 360 | data | ScreenMode06 tilemap |
| `$2C` | `7C71` | `7DD9` | 360 | data | ScreenMode06 attrmap |
| `$2C` | `7DD9` | `7DF9` | 32 | data | ScreenMode06_Palettes |
| `$2C` | `7DF9` | `7E07` | 14 | data | ScreenMode06_Descriptor |
| `$2C` | `7E07` | `7FFF` | 504 | padding | zero fill |
| `$2C` | `7FFF` | `8000` | 1 | padding | bank marker |
| `$2D` | `4000` | `4058` | 88 | code | ScreenMode08_LoadTiles |
| `$2D` | `4058` | `40CC` | 116 | code | ScreenMode08_Draw |
| `$2D` | `40CC` | `40DA` | 14 | data | ScreenMode08_Descriptor |
| `$2D` | `40DA` | `51EA` | 4368 | graphics | ScreenMode08_Tiles |
| `$2D` | `51EA` | `5352` | 360 | data | ScreenMode08 tilemap |
| `$2D` | `5352` | `54BA` | 360 | data | ScreenMode08 attrmap |
| `$2D` | `54BA` | `54FA` | 64 | data | ScreenMode08_Palettes |
| `$2D` | `54FA` | `5552` | 88 | code | ScreenMode00_LoadTiles |
| `$2D` | `5552` | `55C6` | 116 | code | ScreenMode00_Draw |
| `$2D` | `55C6` | `55D4` | 14 | data | ScreenMode00_Descriptor |
| `$2D` | `55D4` | `5E94` | 2240 | graphics | ScreenMode00_Tiles |
| `$2D` | `5E94` | `5FE8` | 340 | data | ScreenMode00 tilemap |
| `$2D` | `5FE8` | `613C` | 340 | data | ScreenMode00 attrmap |
| `$2D` | `613C` | `614C` | 16 | data | ScreenMode00_Palettes |
| `$2D` | `614C` | `7FFF` | 7859 | padding | zero fill |
| `$2D` | `7FFF` | `8000` | 1 | padding | bank marker |
| `$2E` | `4000` | `4058` | 88 | code | Screen2E_LoadTiles |
| `$2E` | `4058` | `40CC` | 116 | code | Screen2E_Draw |
| `$2E` | `40CC` | `40DA` | 14 | data | Screen2E_Descriptor |
| `$2E` | `40DA` | `51EA` | 4368 | graphics | Screen2E_Tiles |
| `$2E` | `51EA` | `5366` | 380 | data | Screen2E tilemap |
| `$2E` | `5366` | `54E2` | 380 | data | Screen2E attrmap |
| `$2E` | `54E2` | `5522` | 64 | data | Screen2E_Palettes |
| `$2E` | `5522` | `6562` | 4160 | graphics | Picture596D1_Tiles |
| `$2E` | `6562` | `66DE` | 380 | data | Picture596D1_TileMap |
| `$2E` | `66DE` | `685A` | 380 | data | Picture596D1_AttrMap |
| `$2E` | `685A` | `689A` | 64 | data | Picture596D1_Palettes |
| `$2E` | `689A` | `799A` | 4352 | graphics | Picture596D0_Tiles |
| `$2E` | `799A` | `7B16` | 380 | data | Picture596D0_TileMap |
| `$2E` | `7B16` | `7C92` | 380 | data | Picture596D0_AttrMap |
| `$2E` | `7C92` | `7CD2` | 64 | data | Picture596D0_Palettes |
| `$2E` | `7CD2` | `7FFF` | 813 | padding | zero fill |
| `$2E` | `7FFF` | `8000` | 1 | padding | bank marker |
