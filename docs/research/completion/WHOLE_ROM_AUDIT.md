# Whole-ROM audit

Every number on this page is produced by a tool that `make check` runs. The
tables are a snapshot of the reports at handoff. The JSON reports are
authoritative and are checked for freshness.

| Tool | Report | Fails on |
| --- | --- | --- |
| `tools/rom_range_map.py` | `reports/rom_range_map.json`, `reports/rom_unresolved_inventory.json` | any gap or overlap in the 64 banks; a range whose bytes no longer match; source that no longer assembles to the base ROM; a missing asset; an asset whose size or bytes differ; an `INCBIN` slice that differs from its ROM range; a stale report |
| `tools/operand_audit.py` | `reports/operand_audit.json` | an unpinned raw ROM address operand; a raw bank byte, RAM literal or indirect transfer without a disposition or documentation |
| `tools/completion_invariants.py` | (stdout) | any of the twelve completion rules (screen-effect reach, bank-`$08` duplicates and tile copies, scene tables, level-tile overrun layout, level records, interrupt images, `Func_3960` call sites, cell-bit regions, `$0A` columns, VRAM-bank-1 tile loads, lookup/map attributes) |
| `tools/semantic_invariants.py` | (stdout) | the tracker lookup formula, audio-id classes and queue sites, and bank-`$08` palette-group relations |
| `tools/check_project.py` | (stdout) | an `INCBIN` slice in `asset_slices.txt` (254 entries) that differs from its ROM range, among the project checks |
| `tools/banks_01_05.py`, `tools/object_sequence_fields.py` | existing reports | bank `$01`-`$05` tables, scene-interrupt calls, sequence/spawn/auxiliary rules |

## Range map

The range map is built from the source itself. A scratch copy is assembled with
an address print before every statement, so every byte maps to the source line,
label and asset that emit it. Consecutive statements under the same label and of
the same kind are merged into 2,411 range records.

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
- 892,269 bytes are covered by a reviewed (non-automatic) label.
- No range remains under a neutral/address-placeholder label. Twelve bytes are
  explicitly preserved as unreferenced data with unknown original purpose:
  `Bank02UnreferencedByte5E80` (1 byte), `Bank08UnreferencedData6108`,
  `Bank08UnreferencedData624A`, and `Bank08UnreferencedData6260` (11 bytes).
- 156,307 bytes are padding or markers.

A reviewed label is not the same as full understanding. The flags below record
what is still unknown or unused.

**Flags (bytes):**

| Flag | Bytes |
| --- | ---: |
| unused (no reader found, or an `Unused`/`Unread`/`Unreferenced` name) | 50,942 |
| residue (build residue: banks `$07`, `$27`-`$29`, bank `$05` copies) | 61,619 |
| duplicated | 1,976 |
| unreachable code | 584 |
| runtime (RAM-executed) code | 2,530 |
| separator | 4 |

**Untraced code:** the 584 bytes are the five unreferenced bank-`$01` routines
and the unreferenced bank-`$02` frame routine. They are explicit instructions
in source. Heuristic decoding still adds 0 bytes.

`reports/rom_unresolved_inventory.json` groups the non-understood ranges per
bank and reason (no reader or untraced code). It is derived from the range map,
not maintained by hand. Totals by reason: no reader 50,942; untraced code 584.

Negative tests: the range map rejects 28 deliberate corruptions, the operand
audit 5, the completion invariants 24 and the semantic invariants 28.

## Code and function progress

**Function entries:** `make progress` reports 288/288. Every automatic function
entry has a reviewed companion name.

**Automatic labels:** none remain. No `Jump_`, `RAM_XXXX`, `BankNNData_` or
`Bank01RomImage_` label is left in `src/` or `include/`. A name records the
local role of the code or data at that address; it is not a claim of
gameplay meaning.

## Address operands and bank bytes (`reports/operand_audit.json`)

- **Raw ROM address operands in code:** 0. The four raw pointers
  previously pinned (`$418F`, `$6609`, `$4600`, and the split `$6358`) are now
  label operands (`LOW()`/`HIGH()` for the split one), and their pins are gone.
- **Raw bank bytes:** 26 remain, each with a written disposition:
  - 15 select a data bank for a pointer computed at run time;
  - 8 restore the caller's bank `$01` in RAM code;
  - 1 is redundant because the same bank is re-mapped before any banked read
    (`RunMenuAndLevelLoop`);
  - 1 is redundant because another bank write overwrites it before any banked
    read (`LoadObjectPalettes`);
  - 1 is redundant because no banked reader was found (`UpdateAllObjects`;
    strong, not proven).
- **`dw` literals equal to a ROM label address:** 20, reported per bank. They are
  palette, note or tile-index values (w20), not pointers.

## RAM and HRAM literals

Each raw `$C000-$DFFF`/`$FF80-$FFFE` literal left in code has a disposition in
`tools/operand_dispositions.json`:

| Disposition | Uses |
| --- | ---: |
| shared scratch (HRAM time-shared between banks; users listed) | 59 |
| bank-dependent (SVBK, WRAMX `$D000-$DFFF`) | 35 |
| RAM code address (`LOAD` destinations) | 33 |
| write-only | 10 |
| layout (stack top, negative 16-bit constants) | 7 |

Raw literals that already had a symbol were replaced: `wJoypadHeld`,
`wVBlankCounter`, `wPaletteFadeFromWhite`, `wLevelNumber`, `wHudAlertActive`,
`wVramDmaStagingBuffer + n`, `wMenuScanlineScrollTable + 1` and `OAMDMARoutine`.
New aliases cover the bank-`$01` scene roles of time-shared HRAM:
`hSceneRomBank`, `hSceneScrollStarted` and `hSceneScrollDelay`.

## Indirect transfers

Every `jp hl`, transfer to RAM and pushed constant return is listed by owner in
`docs/research/banks_01_05/INDIRECT_CONTROL_FLOW.md`. The audit fails on any
undocumented site. Current counts: 6 `jp hl`, 6 pushed constant returns
(synthetic return candidates) and 2 transfers to RAM.
