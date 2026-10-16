#!/usr/bin/env python3
"""Decoder for the BattleTanx GBC sound driver data in ROM bank $06.

Formats are derived from the driver routines at $06:$7CAE-$7FD1 (see
AUDIO_RESEARCH.md). Every address here is a bank-$06 CPU address.
"""
from __future__ import annotations

AUDIO_BANK = 0x06
PATCHES, PATCH_COUNT, PATCH_SIZE = 0x4000, 37, 8
SFX_SEQ_PTRS, SFX_SEQ_COUNT = 0x4128, 25          # + one $0000 word at $415A
SFX_SEQ_DATA, SFX_SEQ_END = 0x415C, 0x4649
REG_INIT, REG_INIT_SIZE = 0x4649, 0x17             # copied to $FF10-$FF26
NOTE_FREQS, NOTE_COUNT = 0x4662, 90                # dw per note
WAVE, WAVE_SIZE = 0x4716, 0x10                     # copied to $FF30-$FF3F
NOISE_NOTES, NOISE_NOTE_COUNT = 0x4726, 9          # notes $0C-$14 on channel 4
CHANNEL_REGS = 0x4738                              # dw x4
MUSIC_PTRS, MUSIC_COUNT = 0x4744, 10
INSTRUMENTS, INSTRUMENT_COUNT = 0x476E, 11
MUSIC_DATA, MUSIC_END = 0x479A, 0x7CAE
DRIVER_CODE, DRIVER_END = 0x7CAE, 0x7FD2


def bank6(rom: bytes) -> bytes:
    return rom[AUDIO_BANK * 0x4000:(AUDIO_BANK + 1) * 0x4000]


def b6(rom: bytes, addr: int, n: int = 1) -> bytes:
    return bank6(rom)[addr - 0x4000:addr - 0x4000 + n]


def word(rom: bytes, addr: int) -> int:
    lo, hi = b6(rom, addr, 2)
    return lo | hi << 8


def sfx_seq_pointers(rom: bytes) -> list[int]:
    return [word(rom, SFX_SEQ_PTRS + 2 * i) for i in range(SFX_SEQ_COUNT)]


def parse_sfx_seq(rom: bytes, addr: int) -> tuple[list[tuple[int, ...]], int]:
    """Return (events, end address) for a sound-effect sequence (driver $7EFD)."""
    events = []
    while True:
        op = b6(rom, addr)[0]
        if op == 0xFF:
            events.append(("end",))
            return events, addr + 1
        if op & 0x01:
            arg, delay = b6(rom, addr + 1, 2)
            kind = "tone" if op & 0xF0 == 0x20 else "patch"
            events.append((kind, op, arg, delay))
            addr += 3
        else:
            delay = b6(rom, addr + 1)[0]
            events.append(("mute4" if op & 0x40 else "mute1", op, delay))
            addr += 2


def music_pointers(rom: bytes) -> list[tuple[int, int, int]]:
    out = []
    for i in range(MUSIC_COUNT):
        lo, hi, bank, unk = b6(rom, MUSIC_PTRS + 4 * i, 4)
        out.append((lo | hi << 8, bank, unk))
    return out


def parse_music(rom: bytes, addr: int) -> tuple[list[tuple[int, ...]], int]:
    """Return (events, end address) for a music sequence (driver $7D11)."""
    events = []
    while True:
        b, c = b6(rom, addr, 2)
        if b >= 0x8F:
            if b == 0xFE and c < 0xF0:
                events.append(("queue", b, c, b6(rom, addr + 2)[0]))
                addr += 3
                continue
            if b == 0xFE:                  # loop: third byte is the delay after the jump
                events.append(("loop", b, c, b6(rom, addr + 2)[0]))
                return events, addr + 3
            events.append(("stop", b, c))  # driver also reads (and discards) one more byte
            return events, addr + 2
        cmd = b & 0x0F
        if cmd == 2:                       # note off: c is the delay
            events.append(("off", b, c))
            addr += 2
        else:
            events.append(({1: "note", 3: "instrument", 4: "pan"}.get(cmd, "nop"),
                           b, c, b6(rom, addr + 2)[0]))
            addr += 3
