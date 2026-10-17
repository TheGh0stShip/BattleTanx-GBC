# BattleTanx — Game Boy Color matching disassembly

[![Reconstruction](https://img.shields.io/badge/reconstruction-100%25-brightgreen)](docs/VERIFICATION.md)
[![Functions](https://img.shields.io/badge/functions-288%2F288-brightgreen)](docs/VERIFICATION.md)
[![Code](https://img.shields.io/badge/code-39359%2F39359-brightgreen)](docs/VERIFICATION.md)
[![Data](https://img.shields.io/badge/data-1009217%2F1009217-brightgreen)](docs/VERIFICATION.md)
[![Verify](https://github.com/TheGh0stShip/BattleTanx-GBC/actions/workflows/verify.yml/badge.svg?branch=main)](https://github.com/TheGh0stShip/BattleTanx-GBC/actions/workflows/verify.yml?query=branch%3Amain)
[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue)](LICENSE)

This repository contains a byte-exact RGBDS disassembly of **BattleTanx** for
Game Boy Color (USA). All 1,048,576 cartridge bytes are reconstructed from the
committed source tree and assets. All 288 catalogued function entries have
reviewed names, every ROM byte belongs to a checked range, and generated gap
decoding contributes zero bytes.

Binary reconstruction is complete; semantic recovery is still active. A
matching cartridge proves that the source preserves the original bytes, not
that every table, variable, routine, timing dependency, or original defect is
fully understood.

## Supported cartridge

- Title: `BATTLETANX`
- Game code: `AVNE`
- Region: USA
- Hardware: Game Boy Color only, MBC5
- Size: 1 MiB, 64 banks (60 populated and four `$FF` banks)
- SHA-1: `5078584e86c0b6f4687c424cc00bbd762ba6573a`
- SHA-256: `b449bab1b0a422fdb462d0dc5c55fbc8e50d8c18a5e2fd836e7db016ee63aa62`
- MD5: `4ca71b12d89a5bcfcc52095081ae9f51`

## Quick start

Requires Python 3 and RGBDS 1.0.4.

```sh
make battletanx.gbc  # builds entirely from committed source and assets
make verify-source  # no retail cartridge required

cp /path/to/BattleTanx.gbc baserom.gbc
make check          # complete comparison, structure and round-trip suite
```

`make compare` verifies that the output is identical to the supported retail
cartridge. `make check` additionally validates every asset slice, range map,
control-flow invariant, relocation case, and lossless graphics/map export.

## Current status

```text
cartridge   [████████████████████] 100.00%  1,048,576 / 1,048,576 bytes
code        [████████████████████] 100.00%     39,359 /    39,359 bytes
data        [████████████████████] 100.00%  1,009,217 / 1,009,217 bytes
functions   [████████████████████] 100.00%        288 /       288 named
```

The code total is the byte-match report's program and RAM-executed-code scope.
The trace separately reports 35,303 bytes reached from architectural roots and
recovered tables, 3,265 reviewed standalone bytes, 206 callerless bytes, and
zero heuristic bytes. These measurements answer different questions and are
deliberately not merged.

The whole-ROM range map currently contains 2,411 non-overlapping ranges:
892,269 bytes under reviewed names and 156,307 bytes of padding or bank
markers, with no neutral/address-placeholder ranges. Twelve explicitly
preserved unreferenced bytes still have unknown original purpose. See
[`docs/STATUS.md`](docs/STATUS.md) for the live recovery ledger and open work.

## Source strategy

Human-readable SM83 assembly is the authoritative target. The game depends on
SM83 register behavior, MBC5 banking, interrupt timing, CGB VRAM/WRAM banks,
and routines copied from ROM into WRAM or HRAM. Keeping those operations
explicit preserves both meaning and the exact cartridge image.

Large graphics and data ranges remain committed as typed binary source assets
when that is the clearest lossless representation. Their ROM ranges, sizes,
hashes, consumers, and round trips are checked. An opaque inclusion is never
presented as fully understood merely because it rebuilds correctly.

See the [architecture contract](docs/ARCHITECTURE.md),
[source-maturity policy](docs/SOURCE_MATURITY.md), and
[research provenance](docs/PROVENANCE.md) before changing source labels or
formats.

For a clean-checkout setup with exact commands and expected output, follow the
[reproduction manual](docs/REPRODUCTION.md). The separate
[completeness statement](docs/COMPLETENESS.md) explains why a 100% byte match
does not mean every byte's gameplay meaning is known.

## Repository map

- `src/` — authoritative RGBDS source, one file per ROM bank plus recovered
  shared data modules.
- `include/` — hardware constants, memory symbols, record layouts and macros.
- `assets/` — committed typed source assets used by the exact build.
- `assets.txt` and `asset_slices.txt` — extraction origins and placed-slice
  ledger.
- `reports/` — deterministic range, operand, asset and semantic inventories.
- `tools/` — tracing, assembly emission, extraction, validation and reporting.
- `docs/STATUS.md` — concise progress and unresolved-work ledger.
- `docs/REPRODUCTION.md` — legal-ROM setup, asset recovery, build, validation,
  and expected outputs.
- `docs/COMPLETENESS.md` — exact boundary between reconstruction and semantic
  recovery.
- `docs/PASSWORDS.txt` — ROM-derived canonical passwords and recovered format.
- `docs/HIDDEN_FEATURES.md` — audited reset chord, menus, and unreachable
  development remnants.
- `docs/research/` — detailed evidence for each recovered subsystem.
- `.recomp.json` — public project metadata for compatible catalogs.

The [tool and target reference](docs/TOOLS.md) explains the major commands and
which outputs are authoritative, generated, diagnostic, or one-time-only.

## Progress reporting

`make report` writes an objdiff v2 report with separate code and data totals.
The default-branch workflow publishes it as `USA_report` for compatible
trackers. The report measures exact reconstruction only; it does not turn
unknown data into understood source.

The exact hashes, category definitions, latest gate expectations, and report
contract are recorded in [the verification guide](docs/VERIFICATION.md).

## Important editing rule

`make disasm` regenerates `src/` from the supported cartridge and overwrites
reviewed edits. It is a bootstrap and generator-development command, not part
of ordinary source maintenance. The checked-in `src/` tree is authoritative.

## License

Project-authored material is licensed under GNU GPL version 3; see
[`LICENSE`](LICENSE). Committed extracted game resources are included for
reconstruction and research and remain subject to the rights of their original
owners. BattleTanx and its copyrights and trademarks remain the property of
their respective holders.
