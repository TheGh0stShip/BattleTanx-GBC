# Whole-ROM audit

Every number on this page is produced by a tool that `make check` runs. The
tables are a snapshot of the reports at handoff. The JSON reports are
authoritative and are checked for freshness.

| Tool | Report | Fails on |
| --- | --- | --- |
| `tools/rom_range_map.py` | `reports/rom_range_map.json`, `reports/rom_unresolved_inventory.json` | any gap or overlap in the 64 banks; a range whose bytes no longer match; source that no longer assembles to the base ROM; a missing asset; an asset whose size or bytes differ; an `INCBIN` slice that differs from its ROM range; a stale report |
| `tools/operand_audit.py` | `reports/operand_audit.json` | an unpinned raw ROM address operand; a raw bank byte, RAM literal or indirect transfer without a disposition or documentation |
| `tools/completion_invariants.py` | (stdout) | the eight completion rules (screen-effect reach, bank-`$08` duplicates and tile copies, scene tables, level-tile overrun layout, level records, interrupt images, `Func_3960` sites) |
| `tools/banks_01_05.py`, `tools/object_sequence_fields.py` | existing reports | bank `$01`-`$05` tables, scene-interrupt calls, sequence/spawn/auxiliary rules |

## Range map

The range map is built from the source itself. A scratch copy is assembled with
an address print before every statement, so every byte maps to the source line,
label and asset that emit it. Consecutive statements under the same label and of
the same kind are merged into 2,002 range records.

**Kinds (bytes):**

| Kind | Bytes |
| --- | ---: |
| asset (typed `INCBIN`) | 631,136 |
| data (`db`/`dw` and data macros) | 221,734 |
| fill (`ds`) | 156,244 |
| code, traced from known entries | 36,245 |
| RAM-executed code (ROM source) | 2,530 |
| code, not reached by the tracer | 584 |
| bank markers | 63 |
| RAM data images | 40 |
| **total** | **1,048,576** |

**Understanding:**
- 890,373 bytes are covered by a reviewed (non-automatic) label.
- 156,307 bytes are padding or markers.
- 1,896 bytes are under automatic or "unread" labels.

A reviewed label is not the same as full understanding. The flags below record
what is still unknown or unused.

**Flags (bytes):**

| Flag | Bytes |
| --- | ---: |
| unused (no reader found, or an `Unused`/`Unread`/`Unreferenced` name) | 53,709 |
| residue (build residue: banks `$07`, `$27`-`$29`, bank `$05` copies) | 61,619 |
| duplicated | 1,677 |
| unreachable code | 584 |
| runtime (RAM-executed) code | 2,530 |

**Untraced code:** the 584 bytes are the five unreferenced bank-`$01` routines
and the unreferenced bank-`$02` frame routine. They are explicit instructions
in source. Heuristic decoding still adds 0 bytes.

`reports/rom_unresolved_inventory.json` groups the non-understood ranges per
bank and reason (neutral label, no reader, untraced code). It is derived from the
range map, not maintained by hand.

## Code and function progress

**Function entries:** `make progress` reports 288/288. Every automatic function
entry has a reviewed companion name.

**Labels that are still only automatic names:**

| Bank | Branch labels (`Jump_`) | RAM-image labels (`RAM_`) | Other |
| --- | ---: | ---: | --- |
| `$00` | 0 | 24 | |
| `$01` | 297 | 39 | 35 `Bank01RomImage_`/`Bank01Data_` |
| `$03` | 80 | 0 | |

`Bank01RomImage_` labels are deliberately address-named. They mark the ROM side
of RAM-executed images, while the run-time label carries the behaviour name.

## Address operands and bank bytes (`reports/operand_audit.json`)

- **Raw ROM address operands in code:** 0. The four raw pointers
  previously pinned (`$418F`, `$6609`, `$4600`, and the split `$6358`) are now
  label operands (`LOW()`/`HIGH()` for the split one), and their pins are gone.
- **Raw bank bytes:** 90 of 117 became `BANK(label)` (89 via the one-time
  `tools/symbolize_bank_bytes.py`, 1 by hand). The remaining 27 each have a
  written disposition:
  - 15 select a data bank for a pointer computed at run time;
  - 8 restore the caller's bank `$01` in RAM code;
  - 4 sites under 3 owners are unresolved: `RunMenuAndLevelLoop` (2 sites),
    `LoadObjectPalettes` (a redundant write overwritten by the next instruction),
    and `UpdateAllObjects`.
- **`dw` literals equal to a ROM label address:** 20, reported per bank. They are
  palette, note or tile-index values (w20), not pointers.

## RAM and HRAM literals

Each raw `$C000-$DFFF`/`$FF80-$FFFE` literal left in code has a disposition in
`tools/operand_dispositions.json`:

| Disposition | Uses |
| --- | ---: |
| shared scratch (HRAM time-shared between banks; users listed) | 444 |
| bank-dependent (SVBK, WRAMX `$D000-$DFFF`) | 36 |
| RAM code address (`LOAD` destinations) | 33 |
| write-only | 16 |
| layout (stack top, negative 16-bit constants) | 7 |

Raw literals that already had a symbol were replaced: `wJoypadHeld`,
`wVBlankCounter`, `wPaletteFadeFromWhite`, `wLevelNumber`, `wHudAlertActive`,
`wVramDmaStagingBuffer + n`, `wMenuScanlineScrollTable + 1` and `OAMDMARoutine`.
New aliases cover the bank-`$01` scene roles of time-shared HRAM:
`hSceneRomBank`, `hSceneScrollStarted` and `hSceneScrollDelay`.

## Indirect transfers

Every `jp hl`, transfer to RAM and pushed constant return is listed by owner in
`docs/research/banks_01_05/INDIRECT_CONTROL_FLOW.md`. The audit fails on any
undocumented site.
