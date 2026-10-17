# Tool and target reference

## Normal gates

| Command | Purpose | Retail cartridge required |
| --- | --- | --- |
| `make battletanx.gbc` | Assemble the committed source tree | No |
| `make verify-source` | Build, report, naming and repository-safety gate | No |
| `make compare` | Compare the linked image with the supported cartridge | Yes |
| `make check` | Complete project validation suite | Yes |
| `make report` | Generate the objdiff v2 reconstruction report | No |
| `make progress` | Check reviewed names for all function entries | No |

## Inspection exports

`make graphics`, `maps`, `levels`, `screens`, `objects`, and `bank08` write
ignored inspection output below `build/`. Each exporter reconstructs its source
bytes from the decoded representation and refuses a lossy result.

## Audits

- `tools/rom_range_map.py` accounts for every cartridge byte exactly once.
- `tools/operand_audit.py` inventories raw operands and indirect transfers.
- `tools/relocation_audit.py` and the two shift-test tools distinguish movable
  labels from deliberately pinned layouts.
- `tools/completion_invariants.py` and `tools/semantic_invariants.py` encode
  reviewed cross-subsystem findings and exercise negative mutations.
- `tools/check_repository.py` rejects tracked build products and incomplete
  public metadata.

## Diagnostic and generator commands

`make diag` writes a non-shipping diagnostic cartridge under `build/`; it does
not modify authoritative source.

`make disasm` and scripts named `gen_*`, `apply_*`, `rewrite_*`, `split_*`, or
`symbolize_*` are generator or one-time maintenance tools. Several deliberately
refuse the reviewed tree. Do not run them over `src/` during normal editing.
