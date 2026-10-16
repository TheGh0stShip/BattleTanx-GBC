#!/usr/bin/env python3
"""Generate the explicit bank-$05 level tile-animation tables once."""

from __future__ import annotations

import pathlib
import sys


BANK = 0x05
BANK_SIZE = 0x4000
TABLES = (
    ("LevelTileAnimationSet0", 0x517A, 87),
    ("LevelTileAnimationSet1", 0x532D, 83),
    ("LevelTileAnimationSet2", 0x54CC, 95),
    ("LevelTileAnimationSet3", 0x56A7, 69),
    ("LevelTileAnimationSet4", 0x5800, 96),
)


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("usage: gen_level_tile_animation_asm.py ROM OUTPUT")
    rom = pathlib.Path(sys.argv[1]).read_bytes()
    lines = [
        "; Level tile-animation records used by GetLevelCellTileAndAttr.\n",
        "; Generated once from the verified ROM; this file is authoritative source.\n\n",
    ]
    for name, address, count in TABLES:
        start = BANK * BANK_SIZE + address - 0x4000
        data = rom[start : start + count * 5]
        if len(data) != count * 5:
            raise SystemExit(f"{name}: truncated ROM range")
        lines.append(f"{name}:\n")
        for index in range(count):
            record = data[index * 5 : index * 5 + 5]
            if record[0] != index + 1:
                raise SystemExit(f"{name}: entry {index + 1} has id {record[0]}")
            values = ", ".join(f"${value:02X}" for value in record)
            lines.append(f"\tlevel_tile_animation {values}\n")
        lines.append("\n")
    pathlib.Path(sys.argv[2]).write_text("".join(lines).rstrip() + "\n")


if __name__ == "__main__":
    main()
