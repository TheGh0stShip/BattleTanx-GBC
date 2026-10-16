# Decompilation status

Last audited: 2026-10-16

## Prior-work search

No earlier public BattleTanx Game Boy Color source-reconstruction project was
found in searches by title, platform, cartridge code (`AVNE`), ROM SHA-1, ROM
MD5, or assembly terminology on 2026-10-16. Results were ROM catalogs, general
game information, and projects for the Nintendo 64 games. Private, removed, or
unindexed work may still exist; recheck before making a stronger provenance
claim.

## Reconstruction

- Retail image: BattleTanx (USA), SHA-1
  `5078584e86c0b6f4687c424cc00bbd762ba6573a`
- Toolchain: RGBDS 1.0.4
- Whole-ROM match: 1,048,576 / 1,048,576 bytes (100%)
- ROM banks represented: 64 / 64
- Copied RAM images detected: 38 (30 executable, 8 data-only)

This is complete binary reconstruction. It is not complete semantic recovery.

## Source recovery

| Area | Current state | Next gate |
| --- | --- | --- |
| Reviewed code | 37,612 bytes traced from known entries, pointers, executable RAM images, and reviewed standalone entries | Name and document routines from behavior |
| Heuristic decoding | 0 additional bytes accepted by gap fill | Keep this at zero as more data boundaries are recovered |
| Symbols | Interrupts, startup, copy helpers, screen dispatch, OAM DMA, MBC5 bank selection, VBlank synchronization, and the runtime callback named | Continue naming routines and RAM state from evidence |
| RAM images | 30 executable and 8 data-only images retain ROM source and runtime addresses with `LOAD` blocks | Name each image and verify every copy site |
| Graphics | Preserved in extracted binary ranges | Identify formats and add lossless conversion tools |
| Maps | Preserved in extracted binary ranges | Identify pointer tables, compression, and layouts |
| Audio | Preserved in extracted binary ranges | Identify engine, sequences, instruments, and samples |
| Text | Options-menu labels and value strings are represented directly in source | Extract and round-trip remaining strings and encodings |

## Known control-flow gaps

Six indirect `jp hl` sites are present in the directly traced graph:

- Bank `$00`: `$364D`, `$39C3`, `$39F0`
- Bank `$01`: `$450E`, `$4B44`

The screen init/update dispatch sites at `$39C3` and `$39F0` use the 13-entry
banked screen table at bank `$01:$47EC`; its known destinations are seeded into
the tracer. Bank `$03:$6886` has been resolved as a 15-entry state-check table
at `$685A`, and bank `$01:$450E` uses the 10-entry entity-handler table at
`$44E0`. The callback at `$364D` is selected from the three-entry table at
bank `$01:$4E2F`. The remaining site at `$4B44` dispatches through a pointer in
a runtime object record and still needs a complete record/table model; the
screen dispatch sites are already modeled despite remaining indirect at runtime.

## Immediate roadmap

1. Model the runtime object records used by the remaining indirect jump.
2. Introduce evidence-based WRAM/HRAM symbols and hardware-state documentation.
3. Split mixed code/data banks into named tables and resources.
4. Add lossless graphics, map, text, and audio extraction/rebuild paths.
5. Run relocation/shift tests before declaring source freely editable.
6. Validate timing-sensitive and RAM-executed behavior on physical hardware.

