# Encoded text subsystem

This document records the text format that is currently proven by direct
callers. It does not claim that every visible word in the game is encoded text:
many menu and story captions are baked into background graphics.

## Renderer

ROM0 `$2ACE` (`DrawEncodedText`) consumes a zero-terminated byte string from
`HL`. Four byte values have defined behavior:

| Byte | Meaning |
| --- | --- |
| `$00` | End the string |
| `$01` | Advance one column without drawing |
| `$0C` | Reset the column and row to zero |
| `$0D` | Reset the column and advance one row |

Every other byte is passed to `DrawEncodedGlyph`. That routine maps the byte
through bank `$08:$6B05`, adds `$80` to the resulting tile index, and writes it
to BG map `$9800 + row * 32 + column`. It writes attribute `$0F` to VRAM bank 1
and the tile index to VRAM bank 0 before advancing the cursor column.

`LoadEncodedFontTiles` copies 37 native 2bpp glyphs from bank `$08:$6B85` to
VRAM `$8000`. A RAM-resident menu routine copies the same glyph set to VRAM
bank 1 at `$8800`. The bank `$08` mapping and glyph bytes remain part of the
separately reserved bank recovery and are not duplicated here.

## Referenced strings

The only two direct calls to `DrawEncodedText` are in the options menu. The
three 16-byte option records at bank `$01:$48C0` contain an identifier, value
kind, setting pointer, column, row, and a ten-byte zero-padded label field:

| ID | Kind | Setting | Position | Label |
| ---: | ---: | --- | --- | --- |
| 1 | 2 | `wMusicSetting` | 0, 4 | `MUSIC` |
| 2 | 3 | `wControlSetting` | 3, 8 | `CONTROL` |
| 3 | 4 | `wSkillSetting` | 3, 12 | `SKILL` |

The value renderer selects `ON` or `OFF`, one of three eight-byte control
records (`1`, `2`, `3`), or one of three eight-byte skill records (`EASY`,
`MED `, `HARD`). The fixed record sizes and table boundaries are asserted in
the assembly source.

## Validation and limits

`tools/check_project.py` verifies the three option records, all eleven strings,
terminators, zero padding, supported character range, the two direct renderer
calls, cursor symbols, entry-point addresses, and four controlled corruptions.

The complete set of indirect text paths has not been proven by a relocation or
shift test. The glyph mapping, glyph artwork, and any possible dynamically
constructed strings must be reconciled with the bank `$08` recovery before the
text subsystem can be called globally complete.
