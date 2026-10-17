# BattleTanx (Game Boy Color) disassembly

A matching disassembly of **BattleTanx** for Game Boy Color (USA). The source in
`src/` assembles with RGBDS into a ROM that is byte-for-byte identical to the
retail cartridge.

All data required to assemble the cartridge, including graphics, maps, and other
binary resources that have not yet been promoted to explicit assembly, is kept
in the repository. A verified retail dump is still required for the comparison
and structural-validation gates.

## Source strategy

Human-readable RGBDS assembly is the authoritative decompilation target. The
original program depends on SM83 register behavior, MBC5 banking, interrupt
entry, code copied into WRAM/HRAM, and timing-sensitive display transfers;
keeping those operations explicit also preserves the byte-identical build.

Routines are promoted from generated listings to reviewed source by recovering
their control flow, names, RAM state, tables, and data formats. C-like
descriptions may accompany algorithms when they improve understanding, but a
forced C rewrite is not treated as recovered source and is not allowed to
replace exact target semantics. A future portable implementation can use this
tree as its verified behavioral reference.

## Supported ROM

- Title: `BATTLETANX`, game code `AVNE`, CGB-only, MBC5, 1 MiB (60 used banks)
- SHA-1: `5078584e86c0b6f4687c424cc00bbd762ba6573a`
- MD5: `4ca71b12d89a5bcfcc52095081ae9f51`

## Building

Requires RGBDS 1.0.x and Python 3.

```sh
cp /path/to/BattleTanx.gbc baserom.gbc
make            # builds from committed sources/assets and compares with baserom
```

`make compare` fails unless `battletanx.gbc` hashes identically to the retail ROM.

## Layout

- `src/main.asm` - includes every bank; `src/bank_XX.asm` - one file per ROM bank
- `include/hardware.inc` - hardware register names
- `assets/` - committed source assets for graphics, maps, and data ranges that
  have not yet been expressed directly as assembly
- `graphics.txt` - confirmed native 2bpp ranges rendered losslessly by
  `make graphics`; generated PNG previews are under `build/graphics/`
- `make maps` - renders all descriptor-driven fixed and scrolling scenes and
  writes tile-index/attribute CSV plus decoded palette values under `build/maps/`
- `tools/` - tracer/disassembler used to generate the initial source

## Method

1. `tools/verify_rom.py` verifies the base ROM used by the comparison and
   structural-validation gates.
2. `tools/trace.py` does recursive-descent tracing from the reset/interrupt vectors,
   tracking MBC5 bank writes (`ld a, n` / `ld [$2000], a`), the bank-1 screen table at
   `$47EC`, stored code pointers, and regions copied into WRAM/HRAM by `CopyBytes`
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
37,612 instruction bytes from known entry points, pointers, executable RAM images, and
reviewed standalone routine entries. The optional gap pass currently adds zero
bytes; confirmed data ranges are explicitly excluded from instruction tracing.

Detailed recovery status, control-flow gaps, and the current roadmap are tracked
in [`docs/STATUS.md`](docs/STATUS.md). Run `make check` before committing; it pins
RGBDS 1.0.4, validates every committed asset against its ROM range, checks tracing
invariants, round-trips confirmed graphics through PNG, rebuilds the cartridge,
renders and validates every recovered scene tilemap, and verifies the retail
hashes.
