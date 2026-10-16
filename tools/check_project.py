#!/usr/bin/env python3
"""Validate project metadata, generated assets, and tracing invariants."""

from __future__ import annotations

import hashlib
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
ROM_SIZE = 0x100000
EXPECTED_RGBDS = "v1.0.4"


def fail(message: str) -> None:
    raise SystemExit(f"check: {message}")


def check_toolchain() -> None:
    for program in ("rgbasm", "rgblink", "rgbfix", "rgbgfx"):
        try:
            line = subprocess.check_output(
                [program, "--version"], text=True, stderr=subprocess.STDOUT
            ).splitlines()[0]
        except (FileNotFoundError, subprocess.CalledProcessError) as exc:
            fail(f"cannot run {program}: {exc}")
        if EXPECTED_RGBDS not in line:
            fail(f"{program} must be RGBDS {EXPECTED_RGBDS}, got {line!r}")


def read_manifest() -> list[tuple[pathlib.Path, int, int]]:
    entries = []
    for number, raw in enumerate((ROOT / "assets.txt").read_text().splitlines(), 1):
        line = raw.split("#", 1)[0].strip()
        if not line:
            continue
        fields = line.split()
        if len(fields) != 3:
            fail(f"assets.txt:{number}: expected path, offset, and size")
        path, start, size = pathlib.Path(fields[0]), int(fields[1], 0), int(fields[2], 0)
        if path.is_absolute() or ".." in path.parts:
            fail(f"assets.txt:{number}: unsafe path {path}")
        if size <= 0 or start < 0 or start + size > ROM_SIZE:
            fail(f"assets.txt:{number}: range is outside the 1 MiB ROM")
        entries.append((path, start, size))
    ordered = sorted(entries, key=lambda item: item[1])
    for left, right in zip(ordered, ordered[1:]):
        if left[1] + left[2] > right[1]:
            fail(f"overlapping asset ranges: {left[0]} and {right[0]}")
    return entries


def check_assets(entries: list[tuple[pathlib.Path, int, int]]) -> None:
    rom_path = ROOT / "baserom.gbc"
    if not rom_path.exists():
        fail("baserom.gbc is required")
    rom = rom_path.read_bytes()
    if len(rom) != ROM_SIZE:
        fail(f"baserom.gbc must be {ROM_SIZE} bytes, got {len(rom)}")
    for relpath, start, size in entries:
        path = ROOT / relpath
        if not path.exists():
            fail(f"missing extracted asset {relpath}")
        data = path.read_bytes()
        if data != rom[start : start + size]:
            fail(f"asset does not match ROM range: {relpath}")


def check_scene_descriptors(rom: bytes) -> None:
    table = 0x599D
    destinations = [
        int.from_bytes(rom[table + offset : table + offset + 2], "little")
        for offset in range(0, 14, 2)
    ]
    if destinations != [0x9000, 0x9140, 0x9280, 0x93C0, 0x9500, 0x9640, 0x8800]:
        fail("scrolling-tile destination table changed")

    table = 0x59AB
    for index in range(11):
        record = rom[table + index * 16 : table + (index + 1) * 16]
        bank = record[0]
        pointers = [
            int.from_bytes(record[offset : offset + 2], "little")
            for offset in (1, 3, 5, 7)
        ]
        graphics, tilemap, attributes, palettes = pointers
        palette_count = record[9]
        if bank not in range(0x30, 0x34):
            fail(f"scene descriptor {index} has unexpected bank {bank:#x}")
        if graphics < 0x4000 or graphics + 0xFF0 > 0x8000:
            fail(f"scene descriptor {index} graphics range is outside its bank")
        for kind, pointer in (("tilemap", tilemap), ("attributes", attributes)):
            if pointer < 0x4000 or pointer + 20 * 12 > 0x8000:
                fail(f"scene descriptor {index} {kind} range is outside its bank")
        palette_span = max(palette_count * 8, 0x40)
        if palettes < 0x4000 or palettes + palette_span > 0x8000:
            fail(f"scene descriptor {index} palette range is outside its bank")
        if record[10:] != bytes(6):
            fail(f"scene descriptor {index} reserved bytes are not zero")
        bank_base = bank * 0x4000 - 0x4000
        tilemap_data = rom[bank_base + tilemap : bank_base + tilemap + 240]
        attribute_data = rom[bank_base + attributes : bank_base + attributes + 240]
        source_indices = [
            (value & 0x7F) + (0 if (value & 0x80) or (attr & 0x08) else 128)
            for value, attr in zip(tilemap_data, attribute_data)
        ]
        if any(tile >= 255 for tile in source_indices):
            fail(f"scene descriptor {index} references a nonexistent tile")
        palette_data = rom[
            bank_base + palettes : bank_base + palettes + palette_count * 8
        ]
        for offset in range(0, len(palette_data), 2):
            color = int.from_bytes(palette_data[offset : offset + 2], "little")
            if color & 0x8000:
                fail(f"scene descriptor {index} palette contains invalid color {color:#x}")

    if rom[0x5A5B:0x5A60] != bytes((6, 7, 8, 9, 10)):
        fail("scene descriptor index table changed")

    table = 0x5A60
    last_rows = []
    for index in range(36):
        record = rom[table + index * 8 : table + (index + 1) * 8]
        bank = record[0]
        metatiles = int.from_bytes(record[1:3], "little")
        rows = int.from_bytes(record[3:5], "little")
        last_row = record[5]
        palette = int.from_bytes(record[6:8], "little")
        if bank not in range(0x2F, 0x3C):
            fail(f"scrolling-scene descriptor {index} has unexpected bank {bank:#x}")
        if not 0x4000 <= metatiles < 0x8000:
            fail(f"scrolling-scene descriptor {index} metatiles lie outside its bank")
        row_end = rows + (last_row + 1) * 40
        if rows < 0x4000 or row_end != palette:
            fail(f"scrolling-scene descriptor {index} rows do not end at its palette")
        if palette < 0x4000 or palette + 8 > 0x8000:
            fail(f"scrolling-scene descriptor {index} palette lies outside its bank")
        bank_base = bank * 0x4000 - 0x4000
        tile_count = (rows - metatiles) // 16
        for offset in range(bank_base + rows, bank_base + row_end, 2):
            tile = int.from_bytes(rom[offset : offset + 2], "little")
            if tile >= tile_count:
                fail(f"scrolling-scene descriptor {index} has invalid tile index {tile}")
        last_rows.append(last_row)

    variant_indices = rom[0x5B80:0x5B93]
    descriptor_indices = rom[0x5B93:0x5BA6]
    initial_rows = rom[0x5BA6:0x5BB9]
    if max(variant_indices) >= 36 or max(descriptor_indices) >= 36:
        fail("scrolling-scene lookup selects a nonexistent descriptor")
    for slot, (index, row) in enumerate(zip(descriptor_indices, initial_rows)):
        if row > last_rows[index]:
            fail(f"scrolling-scene lookup {slot} starts outside its row data")


def check_menu_states(rom: bytes) -> None:
    """Validate the five headers and their fixed-size menu choice records."""
    states = (
        (0x4855, 0x00, 0x00, 0x00, 0x4D33, 5, 0x48AA),
        (0x48AB, 0x04, 0x01, 0x00, 0x4D94, 4, 0x48F0),
        (0x48F1, 0x03, 0x03, 0x00, 0x507F, 3, 0x4926),
        (0x4927, 0x05, 0x04, 0x00, 0xD70A, 3, 0x495C),
        (0x495D, 0x06, 0x0B, 0x00, 0x5287, 3, 0x4992),
    )
    state_addresses = {state[0] for state in states}
    value_addresses = {0xD55B, 0xD55C, 0xD55D, 0xD566, 0xD567}
    for address, state_id, init, update, callback, count, terminator in states:
        header = rom[address : address + 5]
        if header[:3] != bytes((state_id, init, update)):
            fail(f"menu state {state_id:#04x} header changed")
        if int.from_bytes(header[3:5], "little") != callback:
            fail(f"menu state {state_id:#04x} callback changed")
        if init >= 13 or update >= 13:
            fail(f"menu state {state_id:#04x} selects an invalid screen mode")
        if terminator != address + 5 + count * 16 or rom[terminator] != 0xFF:
            fail(f"menu state {state_id:#04x} record boundary changed")
        for index in range(count):
            record = rom[address + 5 + index * 16 : address + 21 + index * 16]
            if record[0] != index:
                fail(f"menu state {state_id:#04x} choice order changed")
            target = int.from_bytes(record[2:4], "little")
            if target and target not in state_addresses | value_addresses:
                fail(
                    f"menu state {state_id:#04x} choice {index} has unknown "
                    f"target {target:#06x}"
                )
            # Only the options state's three value choices carry inline text.
            if not (state_id == 0x04 and index > 0) and record[6:] != bytes(10):
                fail(f"menu state {state_id:#04x} choice {index} payload changed")

    if [state[0] for state in states[1:]] != [state[6] + 1 for state in states[:-1]]:
        fail("menu states are no longer contiguous")

    sym = ROOT / "battletanx.sym"
    if sym.exists():
        expected = {
            "MenuState00": (0x01, 0x4855),
            "MenuState04": (0x01, 0x48AB),
            "MenuState03": (0x01, 0x48F1),
            "MenuState05": (0x01, 0x4927),
            "MenuState06": (0x01, 0x495D),
            "HandleMenuState00Input": (0x01, 0x4D33),
            "HandleMenuState04Input": (0x01, 0x4D94),
            "HandleMenuState03Input": (0x01, 0x507F),
            "HandleMenuState05Input": (0x01, 0xD70A),
            "HandleMenuState06Input": (0x01, 0x5287),
        }
        symbols = {}
        for line in sym.read_text().splitlines():
            match = re.fullmatch(
                r"([0-9a-fA-F]{2}):([0-9a-fA-F]{4}) (\S+)", line.strip()
            )
            if match:
                symbols[match.group(3)] = (
                    int(match.group(1), 16),
                    int(match.group(2), 16),
                )
        for name, where in expected.items():
            if symbols.get(name) != where:
                fail(f"menu symbol {name} is at {symbols.get(name)}, expected {where}")


def check_tracing() -> None:
    sys.path.insert(0, str(ROOT / "tools"))
    import hints  # pylint: disable=import-outside-toplevel
    import trace  # pylint: disable=import-outside-toplevel

    rom = (ROOT / "baserom.gbc").read_bytes()
    for offset, value in hints.TEXT_STRINGS.items():
        if rom[offset : offset + len(value)] != value:
            fail(f"text manifest mismatch at ROM offset {offset:#x}")
    traced = trace.run(rom, hints.extra_entries(rom), hints.DATA_RANGES)
    direct_bytes = sum(traced.code.values())
    if direct_bytes != 38772 or len(traced.loads) != 38:
        fail(
            "tracing baseline changed; review it and update docs deliberately "
            f"(bytes={direct_bytes}, loads={len(traced.loads)})"
        )
    executable_loads = sum(
        any(load.src <= off < load.src + load.len for off in traced.code)
        for load in traced.loads.values()
    )
    if executable_loads != 31:
        fail(
            "RAM image classification changed; review it deliberately "
            f"(code={executable_loads}, data={len(traced.loads) - executable_loads})"
        )
    trace.gap_fill(traced, hints.CODE_BANKS, hints.DATA_RANGES)
    total_bytes = sum(traced.code.values())
    if total_bytes != 38772:
        fail(f"gap-fill baseline changed; review it deliberately (bytes={total_bytes})")
    print(
        "trace: "
        f"{direct_bytes} direct bytes, {total_bytes - direct_bytes} heuristic bytes, "
        f"{executable_loads} RAM code images, "
        f"{len(traced.loads) - executable_loads} RAM data images"
    )


AUDIO_SYMBOLS = {
    "Audio_InitFar": (0x00, 0x2EB8),
    "Music_Update": (0x00, 0x2ED5),
    "Audio_Update": (0x00, 0x2F21),
    "Audio_QueueSound": (0x00, 0x2F73),
    "SoundPatches": (0x06, 0x4000),
    "SfxSequencePointers": (0x06, 0x4128),
    "AudioRegisterInit": (0x06, 0x4649),
    "NoteFrequencies": (0x06, 0x4662),
    "WaveformPattern": (0x06, 0x4716),
    "NoiseNoteTable": (0x06, 0x4726),
    "ChannelRegisterBases": (0x06, 0x4738),
    "MusicPointers": (0x06, 0x4744),
    "Instruments": (0x06, 0x476E),
    "Music_00": (0x06, 0x479A),
    "Audio_Init": (0x06, 0x7CAE),
    "Music_HandleEvent": (0x06, 0x7D11),
    "Audio_PlaySound": (0x06, 0x7E41),
    "SfxSequence_Update": (0x06, 0x7EFD),
}


def check_audio() -> None:
    """Re-derive every recovered sound-driver invariant from the base ROM."""
    sys.path.insert(0, str(ROOT / "tools"))
    import audio as au  # pylint: disable=import-outside-toplevel

    rom = (ROOT / "baserom.gbc").read_bytes()
    b6 = au.b6

    # Driver code entry bytes (guards against the tables being mis-sized).
    if b6(rom, au.DRIVER_CODE, 4) != bytes.fromhex("afeafcc8"):
        fail("audio: Audio_Init does not start at $06:$7CAE")
    if rom[0x1BFD2:0x1BFFF] != bytes(0x2D) or rom[0x1BFFF] != 0x06:
        fail("audio: bank $06 tail after the driver is not zero fill + marker")

    # Patches: channel 1, 2 or 4; register count from channel bit 0; padding.
    patches = [b6(rom, au.PATCHES + 8 * i, 8) for i in range(au.PATCH_COUNT)]
    if au.PATCHES + 8 * au.PATCH_COUNT != au.SFX_SEQ_PTRS:
        fail("audio: patch table does not end at the sequence pointer table")
    for i, rec in enumerate(patches):
        if rec[0] not in (1, 2, 4):
            fail(f"audio: patch {i:#x} has channel {rec[0]}")
        mask = rec[1 + (5 if rec[0] & 1 else 4)]
        if mask != (0x11 << (rec[0] - 1)):
            fail(f"audio: patch {i:#x} NR51 bits {mask:#x} do not match its channel")
        pad = rec[2 + (5 if rec[0] & 1 else 4):]
        if any(pad) and not (i == 0 and pad == b"\x22\x00"):
            fail(f"audio: patch {i:#x} has unexpected padding {pad.hex()}")

    # Sound-effect sequences: 25 pointers, a null word, contiguous data.
    ptrs = au.sfx_seq_pointers(rom)
    if au.word(rom, au.SFX_SEQ_PTRS + 2 * au.SFX_SEQ_COUNT) != 0:
        fail("audio: word after the 25 sequence pointers is not $0000")
    cursor = au.SFX_SEQ_DATA
    for start in sorted(set(ptrs)):
        if start != cursor:
            fail(f"audio: sfx sequence gap/overlap at {cursor:#x}->{start:#x}")
        events, end = au.parse_sfx_seq(rom, start)
        for event in events:
            if event[0] == "patch" and event[2] >= au.PATCH_COUNT:
                fail(f"audio: sequence {start:#x} uses patch {event[2]:#x}")
            if event[0] == "tone" and event[2] >= au.NOTE_COUNT:
                fail(f"audio: sequence {start:#x} uses note {event[2]}")
        trailer = b6(rom, end, 6)
        extra = 6 if trailer == bytes.fromhex("ff00ffff0000") else 4
        if trailer[:4] != bytes.fromhex("ff00ffff"):
            fail(f"audio: sequence {start:#x} trailer is {trailer.hex()}")
        cursor = end + extra
    if cursor != au.SFX_SEQ_END or ptrs[0x00] != ptrs[0x0B]:
        fail("audio: sound-effect sequence data boundaries changed")

    # Fixed tables.
    if b6(rom, au.REG_INIT + au.REG_INIT_SIZE, 2) != bytes(2):
        fail("audio: bytes between AudioRegisterInit and NoteFrequencies changed")
    freqs = [au.word(rom, au.NOTE_FREQS + 2 * i) for i in range(au.NOTE_COUNT)]
    if any(f > 0x7FF for f in freqs) or freqs != sorted(freqs):
        fail("audio: note frequencies are not ascending 11-bit values")
    if au.NOTE_FREQS + 2 * au.NOTE_COUNT != au.WAVE:
        fail("audio: note table does not end at the waveform")
    noise = [b6(rom, au.NOISE_NOTES + 2 * i, 2) for i in range(au.NOISE_NOTE_COUNT)]
    if any(r[1] >= au.INSTRUMENT_COUNT for r in noise):
        fail("audio: noise note table names a missing instrument")
    bases = [au.word(rom, au.CHANNEL_REGS + 2 * i) for i in range(4)]
    if bases != [0xFF10, 0xFF16, 0xFF1A, 0xFF20]:
        fail(f"audio: channel register bases changed {bases}")

    # Music: 10 entries in bank $06, sequences contiguous up to the driver.
    music = au.music_pointers(rom)
    for i, (start, bank, unknown) in enumerate(music):
        if bank != au.AUDIO_BANK or unknown != 0:
            fail(f"audio: music {i} bank/unknown byte changed")
    for i, (start, _, _) in enumerate(music):
        nxt = music[i + 1][0] if i + 1 < len(music) else au.MUSIC_END
        events, end = au.parse_music(rom, start)
        for event in events:
            if event[0] in ("note", "off", "instrument", "pan") and not 1 <= event[1] >> 4 <= 4:
                fail(f"audio: music {i} uses channel {event[1] >> 4}")
            if event[0] == "note" and event[2] >= au.NOTE_COUNT:
                fail(f"audio: music {i} uses note {event[2]}")
            if event[0] == "instrument" and event[2] >= au.INSTRUMENT_COUNT:
                fail(f"audio: music {i} uses instrument {event[2]}")
        if nxt - end > 3 or (i and music[i][0] == music[i - 1][0]):
            fail(f"audio: music {i} ends at {end:#x}, next sequence at {nxt:#x}")
    if music[0][0] != au.MUSIC_DATA:
        fail("audio: first music sequence does not follow the instrument table")

    # Bank $07 duplicates bank $06 $4007-$4BFB (see AUDIO_RESEARCH.md).
    bank7 = rom[0x1C000:0x20000]
    if bank7[7:0xBFC] != rom[0x18007:0x18BFC] or any(bank7[0xBFC:0x3FFF]):
        fail("audio: bank $07 is no longer a partial copy of bank $06")

    # Source representation: no opaque blob for the decoded range.
    manifest = (ROOT / "assets.txt").read_text()
    if "bank_06/" in manifest:
        fail("audio: bank $06 data is back in the asset manifest")
    if "INCBIN" in (ROOT / "src" / "audio_data.asm").read_text():
        fail("audio: src/audio_data.asm must stay explicit source")

    # Every immediate sound id passed to Audio_QueueSound must be playable.
    import re  # pylint: disable=import-outside-toplevel
    ids = set()
    for path in sorted((ROOT / "src").glob("bank_*.asm")):
        lines = path.read_text().splitlines()
        for n, line in enumerate(lines):
            if line.strip() == "call Audio_QueueSound":
                for prev in reversed(lines[max(0, n - 3):n]):
                    m = re.fullmatch(r"\s*ld e, \$([0-9A-F]{2})", prev)
                    if m:
                        ids.add(int(m.group(1), 16))
                        break
    for sid in ids:
        ok = (
            (sid < 0x40 and sid < au.PATCH_COUNT)
            or (0x40 <= sid < 0x80 and sid - 0x40 < au.SFX_SEQ_COUNT)
            or (sid >= 0x80 and sid - 0x80 < au.MUSIC_COUNT)
        )
        if not ok or sid == 0:
            fail(f"audio: source queues unplayable sound id {sid:#04x}")

    # Symbol placement, when a linked symbol file is available.
    sym = ROOT / "battletanx.sym"
    if sym.exists():
        table = {}
        for line in sym.read_text().splitlines():
            m = re.fullmatch(r"([0-9a-fA-F]{2}):([0-9a-fA-F]{4}) (\S+)", line.strip())
            if m:
                table[m.group(3)] = (int(m.group(1), 16), int(m.group(2), 16))
        for name, where in AUDIO_SYMBOLS.items():
            if table.get(name) != where:
                fail(f"audio: symbol {name} is at {table.get(name)}, expected {where}")

    print(
        f"audio: {au.PATCH_COUNT} patches, {au.SFX_SEQ_COUNT} sfx sequences, "
        f"{au.MUSIC_COUNT} music sequences, {len(ids)} queued ids checked"
        + ("" if sym.exists() else " (symbol check skipped: no battletanx.sym)")
    )


def main() -> None:
    check_toolchain()
    entries = read_manifest()
    check_assets(entries)
    rom = (ROOT / "baserom.gbc").read_bytes()
    check_scene_descriptors(rom)
    check_menu_states(rom)
    check_tracing()
    check_audio()
    digest = hashlib.sha1((ROOT / "baserom.gbc").read_bytes()).hexdigest()
    print(f"project: OK ({len(entries)} assets, baserom sha1 {digest})")


if __name__ == "__main__":
    main()
