#!/usr/bin/env python3
"""Generate explicit RGBDS source for bank-$03 object sequences.

Superseded: src/level_object_sequences.asm is hand-maintained and uses the
seq_point macro. This generator still emits the older raw `db` form; its output
is for comparison only and must not be written over the source.
"""

from __future__ import annotations

import pathlib
import sys

import object_sequences as sequences


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: gen_object_sequences_asm.py ROM")
    rom = pathlib.Path(sys.argv[1]).read_bytes()
    levels = sequences.parse(rom)
    lines = [
        "; Per-level object sequence tables from bank $03:$4018-$5BF2.",
        "; Each level has 64 object slots. A non-null pointer selects a counted",
        "; sequence of eight-byte records; field meanings remain partly unknown.",
        "",
    ]
    for level in levels:
        number = level["level"]
        lines.append(f"Level{number:02}ObjectSequences:")
        pointers = [
            "$0000" if pointer == 0 else f"Level{number:02}ObjectSequence{slot:02}"
            for slot, pointer in enumerate(level["pointers"])
        ]
        for start in range(0, len(pointers), 8):
            lines.append("\tdw " + ", ".join(pointers[start:start + 8]))
        lines.append("")
        for sequence in level["sequences"]:
            lines.append(f"Level{number:02}ObjectSequence{sequence['slot']:02}:")
            lines.append(f"\tdb {len(sequence['points'])}")
            for index, point in enumerate(sequence["points"]):
                lines.append("\tdb " + ", ".join(f"${value:02X}" for value in point)
                             + f" ; point {index}")
            lines.append("")
        lines.append(f"ASSERT @ == ${level['end']:04X}")
        lines.append("")
    sys.stdout.write("\n".join(lines))


if __name__ == "__main__":
    main()
