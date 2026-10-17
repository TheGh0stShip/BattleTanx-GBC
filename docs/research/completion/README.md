# Completion pass: research index

Frozen baseline `41fccac7cedc579e3604fe0df4021867cce9e0d0`. Rebuild SHA-1
`5078584e86c0b6f4687c424cc00bbd762ba6573a`.

- [WHOLE_ROM_AUDIT.md](WHOLE_ROM_AUDIT.md): range map, operand, RAM and indirect audits (tool-derived numbers)
- [INTERRUPT_BANKING.md](INTERRUPT_BANKING.md): scene interrupt banking proof attempt, invariants, watch procedure
- [RUNTIME_SYSTEMS.md](RUNTIME_SYSTEMS.md): recorded path, cell bits, spawn and auxiliary records, sequences, screens, scenes, unreferenced code, new defects
- [DATA_AND_ASSETS.md](DATA_AND_ASSETS.md): level records and tables, bank `$08`, audio data, scene palettes, opaque assets
- [UNRESOLVED.md](UNRESOLVED.md): open questions across the ROM

Tools added in this pass, all run by `make check`:
- `tools/rom_range_map.py`: whole-ROM range map and unresolved inventory;
- `tools/operand_audit.py` with `tools/operand_dispositions.json`: ROM/RAM
  operands, bank bytes and indirect transfers;
- `tools/completion_invariants.py`: eight cross-checked data and code rules.

One-time edit tools (they own nothing; do not rerun):
`tools/symbolize_bank_bytes.py`.
`tools/gen_object_sequences_asm.py` is superseded by the hand-maintained
`src/level_object_sequences.asm`, which uses the `seq_point` macro.
