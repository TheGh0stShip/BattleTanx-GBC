# BattleTanx (Game Boy Color) disassembly

A matching disassembly of **BattleTanx** for Game Boy Color (USA). The source in
`src/` assembles with RGBDS into a ROM that is byte-for-byte identical to the
retail cartridge.

No ROM or ROM-derived binary assets are included. Supply your own dump.

## Supported ROM

- Title: `BATTLETANX`, game code `AVNE`, CGB-only, MBC5, 1 MiB (60 used banks)
- SHA-1: `5078584e86c0b6f4687c424cc00bbd762ba6573a`
- MD5: `4ca71b12d89a5bcfcc52095081ae9f51`

## Building

Requires RGBDS 1.0.x and Python 3.

```sh
cp /path/to/BattleTanx.gbc baserom.gbc
make            # verifies baserom, extracts assets, builds, compares
```

`make compare` fails unless `battletanx.gbc` hashes identically to the retail ROM.

## Layout

- `src/main.asm` - includes every bank; `src/bank_XX.asm` - one file per ROM bank
- `include/hardware.inc` - hardware register names
- `assets/` - binary blobs (graphics, maps, tables) extracted from `baserom.gbc`
  by `make assets`; untracked
- `tools/` - tracer/disassembler used to generate the initial source

## Method

1. `tools/verify_rom.py` verifies the base ROM hash before anything else.
2. `tools/trace.py` does recursive-descent tracing from the reset/interrupt vectors,
   tracking MBC5 bank writes (`ld a, n` / `ld [$2000], a`), the bank-1 screen table at
   `$47EC`, stored code pointers, and code copied into WRAM/HRAM by `CopyBytes`
   (`$0A8F`) / `CopyBytesShort` (`$0AA4`). A conservative gap-fill pass picks up
   functions reached only indirectly.
3. `tools/disasm.py` emits RGBDS source. RAM-resident code is emitted inside
   `LOAD UNION` blocks so its labels carry the run-time addresses. A label replaces an
   address operand only when it resolves to exactly the same value, so every
   generated file assembles to the original bytes.
4. `make compare` is the gate: every change must still produce the identical ROM.

`make disasm` regenerates `src/` from scratch and **overwrites hand edits**. Use it
only to bootstrap; from then on `src/` is the source of truth.

## Status

All 1,048,576 bytes reconstruct exactly. That establishes a complete binary
rebuild, not a complete understanding of the source. The tracer currently reaches
37,612 instruction bytes from known entry points, pointers, RAM relocations, and
reviewed standalone routine entries. The optional gap pass currently adds zero
bytes; confirmed data ranges are explicitly excluded from instruction tracing.

Detailed recovery status, control-flow gaps, and the current roadmap are tracked
in [`docs/STATUS.md`](docs/STATUS.md). Run `make check` before committing; it pins
RGBDS 1.0.4, validates every extracted asset against its ROM range, checks tracing
invariants, rebuilds the cartridge, and verifies the retail hashes.
