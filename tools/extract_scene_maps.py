#!/usr/bin/env python3
"""Render the descriptor-driven scrolling scenes and verify every tile index."""

from __future__ import annotations

import pathlib
import subprocess
import sys


DESCRIPTOR_OFFSET = 0x5A60
DESCRIPTOR_COUNT = 36
ROW_WIDTH = 20


def fail(message: str) -> None:
    raise SystemExit(f"scene maps: {message}")


def rgb555(value: int) -> tuple[int, int, int]:
    return tuple(((value >> shift) & 0x1F) * 255 // 31 for shift in (0, 5, 10))


def main() -> None:
    if len(sys.argv) != 3:
        fail("usage: extract_scene_maps.py ROM OUTPUT_DIR")
    rom_path, output_root = map(pathlib.Path, sys.argv[1:])
    rom = rom_path.read_bytes()
    output_root.mkdir(parents=True, exist_ok=True)

    total_rows = 0
    total_cells = 0
    for index in range(DESCRIPTOR_COUNT):
        start = DESCRIPTOR_OFFSET + index * 8
        record = rom[start : start + 8]
        bank = record[0]
        graphics = int.from_bytes(record[1:3], "little")
        rows = int.from_bytes(record[3:5], "little")
        last_row = record[5]
        palette = int.from_bytes(record[6:8], "little")
        bank_base = bank * 0x4000 - 0x4000
        tile_count, remainder = divmod(rows - graphics, 16)
        if remainder or tile_count <= 0:
            fail(f"descriptor {index} has an invalid graphics span")
        row_count = last_row + 1
        row_size = ROW_WIDTH * 2
        if rows + row_count * row_size != palette:
            fail(f"descriptor {index} rows do not end at its palette")

        tile_data = rom[bank_base + graphics : bank_base + rows]
        row_data = rom[bank_base + rows : bank_base + palette]
        indices = [
            int.from_bytes(row_data[offset : offset + 2], "little")
            for offset in range(0, len(row_data), 2)
        ]
        invalid = [tile for tile in indices if tile >= tile_count]
        if invalid:
            fail(f"descriptor {index} references tile {invalid[0]} of {tile_count}")

        stem = output_root / f"scene_{index:02}"
        expanded_path = stem.with_suffix(".expanded.2bpp")
        check_path = stem.with_suffix(".roundtrip.2bpp")
        png_path = stem.with_suffix(".png")
        csv_path = stem.with_suffix(".tilemap.csv")
        palette_path = stem.with_suffix(".palette.txt")
        expanded = b"".join(
            tile_data[tile * 16 : tile * 16 + 16] for tile in indices
        )
        expanded_path.write_bytes(expanded)
        subprocess.run(
            ["rgbgfx", "-r", str(ROW_WIDTH), "-o", str(expanded_path), str(png_path)],
            check=True,
        )
        subprocess.run(
            ["rgbgfx", str(png_path), "-o", str(check_path), "-c", "dmg"],
            check=True,
        )
        if check_path.read_bytes() != expanded:
            fail(f"descriptor {index} rendered tiles do not round trip")
        expanded_path.unlink()
        check_path.unlink()

        csv_lines = [
            ",".join(f"{tile:04X}" for tile in indices[offset : offset + ROW_WIDTH])
            for offset in range(0, len(indices), ROW_WIDTH)
        ]
        csv_path.write_text("\n".join(csv_lines) + "\n")

        raw_palette = rom[bank_base + palette : bank_base + palette + 8]
        colors = [
            int.from_bytes(raw_palette[offset : offset + 2], "little")
            for offset in range(0, 8, 2)
        ]
        palette_lines = [
            f"{color:04X} #{red:02X}{green:02X}{blue:02X}"
            for color in colors
            for red, green, blue in (rgb555(color),)
        ]
        palette_path.write_text("\n".join(palette_lines) + "\n")
        total_rows += row_count
        total_cells += len(indices)

    print(
        f"scene maps: {DESCRIPTOR_COUNT} scenes, {total_rows} rows, "
        f"{total_cells} tile indices rendered and verified"
    )


if __name__ == "__main__":
    main()
