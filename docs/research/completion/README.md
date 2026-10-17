# Completion pass: research index

Rebuild SHA-1 `5078584e86c0b6f4687c424cc00bbd762ba6573a`.

A matching ROM establishes reconstruction completeness, not omniscience about
the original authors' intent. The repository-wide source, byte, operand,
control-flow, asset and documentation audit is complete. `UNRESOLVED.md`
records the smaller set of evaluated limits: dead bytes whose intended purpose
is absent from the retail ROM, behavior that requires a physical-hardware
measurement, and original defects whose outcome depends on live timing or
player interference. These are not unaudited gaps.

- [README.md](README.md): this index
- [WHOLE_ROM_AUDIT.md](WHOLE_ROM_AUDIT.md): range map, operand, RAM and indirect audits (tool-derived numbers)
- [INTERRUPT_BANKING.md](INTERRUPT_BANKING.md): scene interrupt banking, invariants and watch procedure (summary below)
- [RUNTIME_SYSTEMS.md](RUNTIME_SYSTEMS.md): recorded path, cell bits, spawn and auxiliary records, sequences, screens, scenes, unreferenced code, defects
- [DATA_AND_ASSETS.md](DATA_AND_ASSETS.md): level records and tables, bank `$08` (including palette groups), audio data, scene palettes, opaque assets
- [GAMEPLAY_IDENTITIES.md](GAMEPLAY_IDENTITIES.md): object, screen and game-start identities, with the readers that establish them
- [HARDWARE_VERIFICATION.md](HARDWARE_VERIFICATION.md): planned physical-hardware checks; none has been run
- [EMULATOR_VERIFICATION.md](EMULATOR_VERIFICATION.md): reproducible CGB colour-rendering smoke test
- [UNRESOLVED.md](UNRESOLVED.md): evaluated evidentiary limits across the ROM

## Interrupt banking summary

All results are static (code paths and hand-counted cycles). Nothing has
been run on hardware.

- ROM-bank hazards: every scene-interrupt window that maps another ROM bank
  over bank `$01` is proven safe or safe under the invariants stated in
  INTERRUPT_BANKING.md. Boot stale-image timing at `bank_01:3696` is unproven
  (content proven safe).
- SVBK=2 STAT hazard: unsafe under the static model after a password start
  that leaves the guard nonzero, and on guard-0 entries only with music `$86`
  plus a timed Start press (F0 = 132); safe with no input; exit fades safe;
  intro scene 1 unproven. An SVBK=2 palette-fade
  window can cover a scene STAT edge; the handler then calls `$D310`/`$D120`
  in WRAM bank 2, which hold palette-fade cache bytes. Traced from those
  bytes, second-scene fixed scenes 6, 7, 9 and 10 (12 of 15 levels) crash and
  scene 8 freezes on STOP until joypad input, with palette corruption. Fixed
  scenes 0-5 are not modelled.

Open:
- confirm or refute the SVBK=2 hazard on hardware; its cycle model, the
  audio-state model and the exact count of scene VBlanks before the scene
  starts are unmeasured;
- confirm the ROM-bank invariants on hardware;
- every item in HARDWARE_VERIFICATION.md.

## Naming state at this revision

- Automatic labels left: 0 (no `Jump_`, `RAM_XXXX`, `BankNNData_` or
  `Bank01RomImage_` labels in `src/` or `include/`).
- `make progress`: 288/288 function entries named.
- 38 `; Original:` comments document original defects; bytes are unchanged.
- Constants: `PADB_*`/`PADF_*`, `GAME_START_*`, `hScene*` HRAM aliases.

## Tools

Run by `make check` (`completion` target):
- `tools/rom_range_map.py`: whole-ROM range map and unresolved inventory
  (28 negative tests);
- `tools/operand_audit.py` with `tools/operand_dispositions.json`: ROM/RAM
  operands, bank bytes and indirect transfers (5 negative tests);
- `tools/completion_invariants.py`: twelve cross-checked data and code rules
  (24 negative tests);
- `tools/semantic_invariants.py`: lookup-table, audio-id and bank-`$08`
  palette-group rules (28 negative tests).

Run by `make check` (`check-project` target):
- `tools/check_project.py`, which also checks every `INCBIN` slice placement
  listed in `asset_slices.txt` (254 slices: asset path, file start, length,
  ROM offset).

Diagnostic only, run by `make diag` and not by `make check`:
- `tools/diag_bank_trap.py`.

Renamed: the disassembler is `tools/sm83_dis.py` and the tracer is
`tools/rom_trace.py`.

One-time edit tools (they own nothing; do not rerun):
`tools/symbolize_bank_bytes.py`.
`tools/gen_object_sequences_asm.py` is superseded by the hand-maintained
`src/level_object_sequences.asm`, which uses the `seq_point` macro.
