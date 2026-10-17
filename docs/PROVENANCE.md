# Provenance

The project began from a recursive SM83 trace of the verified USA cartridge.
The tracer followed reset and interrupt vectors, MBC5 bank changes, recovered
dispatch tables, stored function pointers, and ROM images copied into RAM.
Generated assembly established a byte-exact baseline; reviewed source then
replaced automatic structure with evidence-backed labels, tables, macros and
typed assets.

Evidence is retained in three layers:

1. `src/`, `include/` and `assets/` are the authoritative reconstruction.
2. `reports/` contains deterministic machine-readable inventories.
3. `docs/research/` records the readers, boundaries, invariants, rejected
   interpretations and unresolved questions behind semantic claims.

Names are accepted from behavior, callers, data flow, checked table formats or
stable visible text. Appearance alone is insufficient for gameplay names.
Legacy address aliases may remain where they provide compatibility, but they
do not count as semantic understanding.

The committed binary source assets were sliced from the supported cartridge.
Their placement and contents are verified by `assets.txt`, `asset_slices.txt`,
the whole-ROM range map and subsystem-specific round-trip tools. Their presence
does not imply ownership of the original game data.

No claim of original source-language recovery is made. The original cartridge
semantics are represented in RGBDS assembly; higher-level explanations are
documentation unless separately implemented and byte-verified.
