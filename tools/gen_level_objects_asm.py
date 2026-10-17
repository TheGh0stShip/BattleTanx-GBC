#!/usr/bin/env python3
"""Generate explicit RGBDS source for bank-$04 level object data.

Superseded: output differs from hand-maintained src/level_objects.asm;
comparison only (prints to stdout).
"""

from __future__ import annotations

import pathlib
import sys

import level_objects


def emit_record(lines: list[str], record: bytes, comment: str) -> None:
    lines.append("\tdb " + ", ".join(f"${value:02X}" for value in record) + f" ; {comment}")


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: gen_level_objects_asm.py ROM")
    rom = pathlib.Path(sys.argv[1]).read_bytes()
    levels = level_objects.parse(rom)
    lines = [
        "; Per-level object initialization data from bank $04:$4000-$601B.",
        "; The 12-byte and 8-byte boundaries are fixed by InitializeLevelObjects.",
        "",
    ]
    for level in levels:
        number = level["level"]
        lines.append(f"Level{number:02}ObjectSpawns:")
        for index, record in enumerate(level["spawns"]):
            emit_record(lines, record, f"record {index}")
        lines.extend([f"ASSERT @ == ${level['spawn_address'] + 0x1E0:04X}", ""])
    for level in levels:
        number = level["level"]
        lines.append(f"Level{number:02}ObjectAuxRecords:")
        for index, record in enumerate(level["auxiliaries"]):
            emit_record(lines, record, f"record {index}")
        lines.extend([f"ASSERT @ == ${level['aux_address'] + 0x40:04X}", ""])
    lines.append("LevelObjectDataPointers:")
    for level in levels:
        number = level["level"]
        lines.append(f"\tdw Level{number:02}ObjectSpawns, Level{number:02}ObjectAuxRecords")
    lines.extend(["ASSERT @ == $601C", ""])
    sys.stdout.write("\n".join(lines))


if __name__ == "__main__":
    main()
