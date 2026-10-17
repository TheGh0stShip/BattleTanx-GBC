#!/usr/bin/env python3
"""Render descriptor-driven fixed and scrolling scenes with verified indices."""

from __future__ import annotations

import pathlib
import subprocess
import sys


FIXED_DESCRIPTOR_OFFSET = 0x59AB
FIXED_DESCRIPTOR_COUNT = 11
SCROLL_DESCRIPTOR_OFFSET = 0x5A60
SCROLL_DESCRIPTOR_COUNT = 36
ROW_WIDTH = 20


def fail(message: str) -> None:
    raise SystemExit(f"scene maps: {message}")


def rgb555(value: int) -> tuple[int, int, int]:
    return tuple(((value >> shift) & 0x1F) * 255 // 31 for shift in (0, 5, 10))


def transform_tile(tile: bytes, attributes: int) -> bytes:
    rows = [tile[offset : offset + 2] for offset in range(0, 16, 2)]
    if attributes & 0x40:
        rows.reverse()
    if attributes & 0x20:
        rows = [bytes((int(f"{byte:08b}"[::-1], 2) for byte in row)) for row in rows]
    return b"".join(rows)


def write_render(stem: pathlib.Path, expanded: bytes) -> None:
    expanded_path = stem.with_suffix(".expanded.2bpp")
    check_path = stem.with_suffix(".roundtrip.2bpp")
    png_path = stem.with_suffix(".png")
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
        fail(f"{stem.name} rendered tiles do not round trip")
    expanded_path.unlink()
    check_path.unlink()


def write_palette(path: pathlib.Path, raw_palette: bytes) -> None:
    colors = [
        int.from_bytes(raw_palette[offset : offset + 2], "little")
        for offset in range(0, 8, 2)
    ]
    lines = [
        f"{color:04X} #{red:02X}{green:02X}{blue:02X}"
        for color in colors
        for red, green, blue in (rgb555(color),)
    ]
    path.write_text("\n".join(lines) + "\n")


def write_palette_records(path: pathlib.Path, data: bytes) -> None:
    lines = []
    for record in range(len(data) // 8):
        colors = [
            int.from_bytes(data[record * 8 + offset : record * 8 + offset + 2], "little")
            for offset in range(0, 8, 2)
        ]
        encoded = " ".join(f"{color:04X}" for color in colors)
        decoded = " ".join(
            f"#{red:02X}{green:02X}{blue:02X}"
            for color in colors
            for red, green, blue in (rgb555(color),)
        )
        lines.append(f"{record:02}: {encoded} | {decoded}")
    path.write_text("\n".join(lines) + "\n")


def main() -> None:
    if len(sys.argv) != 3:
        fail("usage: extract_scene_maps.py ROM OUTPUT_DIR")
    rom_path, output_root = map(pathlib.Path, sys.argv[1:])
    rom = rom_path.read_bytes()
    output_root.mkdir(parents=True, exist_ok=True)

    fixed_cells = 0
    for index in range(FIXED_DESCRIPTOR_COUNT):
        start = FIXED_DESCRIPTOR_OFFSET + index * 16
        record = rom[start : start + 16]
        bank = record[0]
        graphics, tilemap, attribute_map, palettes = (
            int.from_bytes(record[offset : offset + 2], "little")
            for offset in (1, 3, 5, 7)
        )
        palette_count = record[9]
        bank_base = bank * 0x4000 - 0x4000
        tile_data = rom[bank_base + graphics : bank_base + graphics + 0xFF0]
        tilemap_data = rom[bank_base + tilemap : bank_base + tilemap + 240]
        attributes = rom[bank_base + attribute_map : bank_base + attribute_map + 240]
        source_indices = [
            (value & 0x7F) + (0 if (value & 0x80) or (attr & 0x08) else 128)
            for value, attr in zip(tilemap_data, attributes)
        ]
        if any(tile >= 255 for tile in source_indices):
            fail(f"fixed descriptor {index} references a nonexistent tile")
        expanded = b"".join(
            transform_tile(tile_data[tile * 16 : tile * 16 + 16], attr)
            for tile, attr in zip(source_indices, attributes)
        )
        stem = output_root / f"fixed_scene_{index:02}"
        write_render(stem, expanded)
        stem.with_suffix(".tilemap.csv").write_text(
            "\n".join(
                ",".join(f"{tile:04X}" for tile in source_indices[offset : offset + ROW_WIDTH])
                for offset in range(0, len(source_indices), ROW_WIDTH)
            )
            + "\n"
        )
        stem.with_suffix(".attributes.csv").write_text(
            "\n".join(
                ",".join(f"{attr:02X}" for attr in attributes[offset : offset + ROW_WIDTH])
                for offset in range(0, len(attributes), ROW_WIDTH)
            )
            + "\n"
        )
        write_palette(
            stem.with_suffix(".palette.txt"),
            rom[bank_base + palettes + 0x38 : bank_base + palettes + 0x40],
        )
        write_palette_records(
            stem.with_suffix(".palettes.txt"),
            rom[
                bank_base + palettes : bank_base + palettes + palette_count * 8
            ],
        )
        fixed_cells += len(source_indices)

    # RequireCgbHardware uses this DMG-format warning on non-CGB startup.
    bank_base = 0x3B * 0x4000 - 0x4000
    graphics, graphics_end, tilemap = 0x4000, 0x4DD0, 0x4DE0
    tile_data = rom[bank_base + graphics:bank_base + graphics_end]
    tilemap_data = rom[bank_base + tilemap:bank_base + tilemap + 20 * 17]
    source_indices = [
        (value & 0x7F) + (0 if value & 0x80 else 128)
        for value in tilemap_data
    ]
    if any(tile >= len(tile_data) // 16 for tile in source_indices):
        fail("bank $3B warning package references a nonexistent tile")
    expanded = b"".join(
        tile_data[tile * 16:tile * 16 + 16]
        for tile in source_indices
    )
    stem = output_root / "bank_3B_gbc_warning"
    write_render(stem, expanded)
    stem.with_suffix(".tilemap.csv").write_text(
        "\n".join(
            ",".join(f"{tile:04X}" for tile in source_indices[offset:offset + ROW_WIDTH])
            for offset in range(0, len(source_indices), ROW_WIDTH)
        ) + "\n"
    )
    write_palette(
        stem.with_suffix(".unused_palette.txt"),
        rom[bank_base + 0x5088:bank_base + 0x5090],
    )

    total_rows = 0
    total_cells = 0
    for index in range(SCROLL_DESCRIPTOR_COUNT):
        start = SCROLL_DESCRIPTOR_OFFSET + index * 8
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

        stem = output_root / f"scrolling_scene_{index:02}"
        csv_path = stem.with_suffix(".tilemap.csv")
        palette_path = stem.with_suffix(".palette.txt")
        expanded = b"".join(
            tile_data[tile * 16 : tile * 16 + 16] for tile in indices
        )
        write_render(stem, expanded)

        csv_lines = [
            ",".join(f"{tile:04X}" for tile in indices[offset : offset + ROW_WIDTH])
            for offset in range(0, len(indices), ROW_WIDTH)
        ]
        csv_path.write_text("\n".join(csv_lines) + "\n")

        write_palette(palette_path, rom[bank_base + palette : bank_base + palette + 8])
        total_rows += row_count
        total_cells += len(indices)

    print(
        f"scene maps: {FIXED_DESCRIPTOR_COUNT} fixed scenes ({fixed_cells} cells) "
        f"plus the referenced bank-$3B compatibility warning, "
        f"{SCROLL_DESCRIPTOR_COUNT} scrolling scenes ({total_rows} rows, "
        f"{total_cells} cells) rendered and verified"
    )


if __name__ == "__main__":
    main()
