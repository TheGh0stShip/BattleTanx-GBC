# Architecture contract

## Target

BattleTanx is a Game Boy Color-only cartridge using the Sharp SM83 and MBC5.
The processor is an 8-bit design with its own instruction encoding, flag
behavior, interrupt entry, stack rules and timing. It is not a Z80 target.

ROM bank 0 occupies `$0000-$3FFF`. MBC5-selected banks occupy
`$4000-$7FFF`. The project preserves bank identity explicitly; an address in a
switchable window is incomplete without its bank.

## Memory and execution

The game uses CGB VRAM and WRAM banking, HRAM scratch storage, DMA/HDMA, and
code copied from ROM into WRAM or HRAM. A copied routine therefore has both a
ROM source range and a RAM execution address. `LOAD` blocks and the range map
preserve that distinction.

Interrupt handlers and display transfers are timing-sensitive. Source cleanup
must not reorder instructions, replace cycle-sensitive loops, or assume that a
successful host-side build establishes behavior on physical hardware.

## Host tools

Python tools decode multi-byte cartridge values explicitly as little-endian
and validate bank bounds and fixed record widths. Host pointer sizes and native
integer layout are not target semantics.

## Build contract

- RGBDS 1.0.4 is pinned.
- The output must have SHA-1
  `5078584e86c0b6f4687c424cc00bbd762ba6573a`.
- `src/` is authoritative.
- Generated previews, linked images, maps and symbols are not source.
- Emulator observations are evidence, not proof of physical-hardware timing.
