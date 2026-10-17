# Research index

These reports preserve the evidence behind source names, data boundaries, and
remaining unknowns. The concise project-wide summary and roadmap live in
[`../STATUS.md`](../STATUS.md).

## Program and runtime behavior

- [`GBC_WARNING_RESEARCH.md`](GBC_WARNING_RESEARCH.md) — CGB warning path
- [`TEXT_RESEARCH.md`](TEXT_RESEARCH.md) — encoded text and option strings
- [`OBJECT_SEQUENCES_RESEARCH.md`](OBJECT_SEQUENCES_RESEARCH.md) — bank `$03`
  per-level object sequences
- [`LEVEL_OBJECTS_RESEARCH.md`](LEVEL_OBJECTS_RESEARCH.md) — bank `$04` spawn
  and auxiliary object records
- [`LEVEL_SEMANTICS_RESEARCH.md`](LEVEL_SEMANTICS_RESEARCH.md) — level records,
  cell bits, and runtime consumers
- [`OBJECT_ORIENTATION_RUNTIME_RESEARCH.md`](OBJECT_ORIENTATION_RUNTIME_RESEARCH.md)
  — object orientation selection and bounds
- [`SCREEN_RUNTIME_RESEARCH.md`](SCREEN_RUNTIME_RESEARCH.md) — full-screen
  picture dispatch and callers
- [`SCENE_RUNTIME_RESEARCH.md`](SCENE_RUNTIME_RESEARCH.md) — fixed and scrolling
  scene runtime behavior

## Bank and asset formats

- [`AUDIO_RESEARCH.md`](AUDIO_RESEARCH.md) — audio driver and bank `$06` data
- [`BANK08_RESEARCH.md`](BANK08_RESEARCH.md) — bank `$08` graphics, tables,
  palettes, and remaining unknown bytes
- [`DATA_BANKS_09_26.md`](DATA_BANKS_09_26.md) — fifteen two-bank level packages
- [`BANKS_27_29_RESEARCH.md`](BANKS_27_29_RESEARCH.md) — object orientation banks
- [`BANKS_2A_2E_RESEARCH.md`](BANKS_2A_2E_RESEARCH.md) — full-screen picture banks
- [`BANKS_09_3A_SEMANTIC_RECOVERY.md`](BANKS_09_3A_SEMANTIC_RECOVERY.md) — combined
  semantic audit for banks `$09–$3A`

## Build integrity

- [`RELOCATION_AUDIT.md`](RELOCATION_AUDIT.md) — raw references, address pins,
  and shift-test coverage
