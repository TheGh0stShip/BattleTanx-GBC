# Overview

## Byte accounting (exact; `tools/byte_accounting_01_05.py`)

Each byte is classified by the source statement that produces it, using an
address print before every statement in a scratch assembly.

| Bank | Code (direct) | RAM code source | RAM data source | Structured data | Binary assets | Fill | Marker | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `$01` | 8,442 | 2,308 | 2 | 2,507 | 2,320 | 804 | 1 | 16,384 |
| `$02` | 3,293 | 210 | 0 | 2,537 | 3,908 | 6,435 | 1 | 16,384 |
| `$03` | 3,496 | 0 | 0 | 7,219 | 0 | 5,668 | 1 | 16,384 |
| `$04` | 1,369 | 0 | 0 | 8,220 | 0 | 6,794 | 1 | 16,384 |
| `$05` | 41 | 0 | 0 | 7,650 | 1,029 | 7,663 | 1 | 16,384 |

- **Code**: every instruction byte is reached by the tracer; untraced code
  is 0 and heuristic code is 0.
- **Binary assets**:
  - `$01`: tile data, 2,320 bytes;
  - `$02`: tiles 528, the dx/dy direction lookup 2,048, one unread block
    1,332;
  - `$05`: three byte-copies of bank `$04`, 1,029.
- **Dual use**: `Func_01_66F6` copies 128 tiles from `PasswordScreenTiles + $80`.
  That copy reads 112 bytes of `PasswordGlyphTiles` as tile data.

## Levels of understanding

| Category | Bytes | Notes |
| --- | ---: | --- |
| Exact reconstruction | 81,920 | all five banks match |
| Behaviour understood (code with evidence names, tables with traced readers, fill/marker) | most | 251 of 278 routine entries carry behaviour names |
| Bounded, meaning unknown | 2,423 | `Bank02Unread481E` (1,332), bank `$05` copies of bank `$04` (1,029, no reader), unread gaps (`Bank01Unread77D6/785E/786C` 25, `Bank02Unread5E80` 9, two effect gaps 28) |
| Unresolved control flow | 0 indirect sites | see INDIRECT_CONTROL_FLOW.md; open interrupt-bank question in UNRESOLVED.md |
| Speculative visual interpretation | none used for naming | |

## Source changes in this pass

- 178 routine and table renames (aliases kept where other files use the old
  name), plus 13 table names.
- 77 RAM symbols (`include/banks_01_05_ram.inc`), replacing 455 raw operands.
- **Every raw own-bank ROM pointer in banks `$01`-`$05` is now a label.** The one
  remaining raw `$4E91` operand is an RGB555 colour value.
- **Bank `$01` descriptor tables are symbolic**: scrolling scenes (bank bytes
  and pointers), fixed scenes (bank bytes), `ScreenModeTable` (bank bytes),
  the `$596D` picture descriptors, and the `$01:7981` operands. The bank `$05`
  orientation pointers are symbolic too.
- **Nine opaque blobs promoted** to explicit source or typed assets (see
  ASSET_MANIFEST.md).
- Generator-era absolute `ASSERT @ == $xxxx` pins in banks `$03`/`$04` were
  replaced by relative size asserts.
- Pins remain only where bank `$00` uses raw addresses (`$01:418F`,
  `$01:6609`, `$05:4600`, `$05:6358`).
