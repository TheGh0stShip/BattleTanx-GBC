#!/usr/bin/env python3
"""Generate reviewed RGBDS source for the simple scrolling-scene banks $34-$3A."""

from __future__ import annotations

import pathlib
import sys


ROOT = pathlib.Path(__file__).resolve().parent.parent
BANKS = range(0x34, 0x3B)
DESCRIPTOR_START = 0x5A60
DESCRIPTOR_COUNT = 36
ROW_WIDTH = 20


def rom_offset(bank: int, address: int) -> int:
    return bank * 0x4000 - 0x4000 + address


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: gen_scrolling_scene_asm.py ROM")
    rom = pathlib.Path(sys.argv[1]).read_bytes()
    scenes = {bank: [] for bank in BANKS}
    for index in range(DESCRIPTOR_COUNT):
        offset = DESCRIPTOR_START + index * 8
        record = rom[offset:offset + 8]
        bank = record[0]
        if bank not in scenes:
            continue
        graphics = int.from_bytes(record[1:3], "little")
        rows = int.from_bytes(record[3:5], "little")
        row_count = record[5] + 1
        palette = int.from_bytes(record[6:8], "little")
        scenes[bank].append((index, graphics, rows, row_count, palette))

    asset_root = ROOT / "assets" / "scenes"
    asset_root.mkdir(parents=True, exist_ok=True)
    manifest = []
    for bank, records in scenes.items():
        records.sort(key=lambda item: item[1])
        lines = [
            f"; BattleTanx (USA) - scrolling scene data bank ${bank:02X}",
            "",
            f'SECTION "ROM Bank ${bank:02X}", ROMX[$4000], BANK[${bank:02X}]',
        ]
        position = 0x4000
        for index, graphics, rows, row_count, palette in records:
            if graphics != position or rows + row_count * ROW_WIDTH * 2 != palette:
                raise SystemExit(f"bank ${bank:02X} scene {index} is not contiguous")
            tile_data = rom[rom_offset(bank, graphics):rom_offset(bank, rows)]
            asset = pathlib.Path("assets/scenes") / f"scroll_scene_{index:02}_tiles.2bpp"
            (ROOT / asset).write_bytes(tile_data)
            manifest.append((asset, rom_offset(bank, graphics), len(tile_data)))
            lines.extend([
                "",
                f"ScrollScene{index:02}Tiles:",
                f'\tINCBIN "{asset.as_posix()}"',
                f"ASSERT @ == ${rows:04X}",
                "",
                f"ScrollScene{index:02}Rows:",
            ])
            row_start = rom_offset(bank, rows)
            for row in range(row_count):
                data = rom[row_start + row * 40:row_start + (row + 1) * 40]
                values = [
                    int.from_bytes(data[column:column + 2], "little")
                    for column in range(0, 40, 2)
                ]
                lines.append("\tdw " + ", ".join(f"${value:04X}" for value in values))
            lines.extend([
                f"ASSERT @ == ${palette:04X}",
                "",
                f"ScrollScene{index:02}Palette:",
            ])
            palette_data = rom[rom_offset(bank, palette):rom_offset(bank, palette + 8)]
            colors = [
                int.from_bytes(palette_data[offset:offset + 2], "little")
                for offset in range(0, 8, 2)
            ]
            lines.append("\tdw " + ", ".join(f"${color:04X}" for color in colors))
            position = palette + 8

        tail = rom[rom_offset(bank, position):rom_offset(bank, 0x8000)]
        if tail[:-1] != bytes(len(tail) - 1) or tail[-1] != bank:
            raise SystemExit(f"bank ${bank:02X} has unexpected tail data")
        lines.extend([
            "",
            "\tds $7FFF - @, 0",
            f"\tdb ${bank:02X} ; bank marker",
            "ASSERT @ == $8000",
            "",
        ])
        (ROOT / "src" / f"bank_{bank:02X}.asm").write_text("\n".join(lines))

    for path, offset, size in manifest:
        print(f"{path.as_posix()} {offset:#x} {size:#x}")


if __name__ == "__main__":
    main()
