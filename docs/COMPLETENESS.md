# What “100%” means

BattleTanx GBC is completely reconstructed but not completely understood.
Those are separate, independently measured claims.

## Complete

- All 1,048,576 cartridge bytes are represented exactly once.
- The linked cartridge matches the supported retail image byte for byte.
- All 64 ROM banks have source coverage with no gaps or overlaps.
- All 288 identified function entries have reviewed descriptive companion
  names.
- All decoded code in the report matches: 39,359 of 39,359 bytes.
- All reported data, assets, padding, and markers match: 1,009,217 of
  1,009,217 bytes.
- Graphics, levels, scenes, screens, object banks, and typed asset ranges have
  lossless extraction or round-trip checks.
- The build, asset preparation, audits, report generation, and inspection
  exports have reproducible commands in `docs/REPRODUCTION.md`.

## Not complete

- Twelve bytes remain deliberately neutral because no reader or meaning has
  been established.
- One 3,061-byte bank-$07 asset is understood as unread build residue copied
  from audio data, but its build-time origin is not known.
- Some record fields, palette records, scene identities, object identities,
  audio meanings, and unreachable routines have no proven gameplay meaning.
- Several original defects and timing-sensitive interrupt paths still require
  emulator or physical-hardware confirmation.
- Structural reachability cannot rule out every arithmetically constructed or
  self-modified reference without runtime evidence.
- Some source layouts remain intentionally pinned; successful byte matching
  does not mean every block can be freely relocated.
- Tooling limitations remain listed in
  `docs/research/completion/UNRESOLVED.md`, including generator drift and a few
  audits keyed to source presentation rather than stable site identifiers.

## Progress terminology

Use these phrases precisely:

- **100% reconstructed / byte-matching:** correct.
- **100% function entries named:** correct for the 288 identified entries.
- **Every byte accounted for:** correct as a source/range statement.
- **100% semantically decompiled:** incorrect.
- **Nothing left to research:** incorrect.
- **Hardware verified:** incorrect.

The detailed open list is
[`research/completion/UNRESOLVED.md`](research/completion/UNRESOLVED.md), and
the current priorities are in [`STATUS.md`](STATUS.md).
