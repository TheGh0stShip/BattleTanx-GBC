#!/usr/bin/env python3
"""Generate the overlapping fixed/scrolling scene layouts in banks $30-$33."""

from __future__ import annotations

import pathlib
import sys


ROOT = pathlib.Path(__file__).resolve().parent.parent
BANKS = range(0x30, 0x34)


def rom_offset(bank: int, address: int) -> int:
    return bank * 0x4000 - 0x4000 + address


def emit_bytes(lines: list[str], data: bytes, width: int = 16) -> None:
    for offset in range(0, len(data), width):
        chunk = data[offset:offset + width]
        lines.append("\tdb " + ", ".join(f"${byte:02X}" for byte in chunk))


def emit_words(lines: list[str], data: bytes, width: int = 4) -> None:
    values = [
        int.from_bytes(data[offset:offset + 2], "little")
        for offset in range(0, len(data), 2)
    ]
    for offset in range(0, len(values), width):
        lines.append("\tdw " + ", ".join(
            f"${value:04X}" for value in values[offset:offset + width]
        ))


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: gen_fixed_scene_asm.py ROM")
    rom = pathlib.Path(sys.argv[1]).read_bytes()
    ranges = {bank: [] for bank in BANKS}
    labels = {bank: {} for bank in BANKS}

    def add(bank: int, start: int, end: int, kind: str, name: str) -> None:
        ranges[bank].append((start, end, kind, name))
        labels[bank].setdefault(start, []).append(name)

    for index in range(11):
        record = rom[0x59AB + index * 16:0x59BB + index * 16]
        bank = record[0]
        graphics, tilemap, attributes, palettes = (
            int.from_bytes(record[offset:offset + 2], "little")
            for offset in (1, 3, 5, 7)
        )
        palette_size = max(record[9] * 8, 0x40)
        add(bank, graphics, graphics + 0xFF0, "graphics", f"FixedScene{index:02}Tiles")
        add(bank, tilemap, tilemap + 240, "map", f"FixedScene{index:02}TileMap")
        add(bank, attributes, attributes + 240, "attributes", f"FixedScene{index:02}Attributes")
        add(bank, palettes, palettes + palette_size, "palette", f"FixedScene{index:02}Palettes")

    for index in range(36):
        record = rom[0x5A60 + index * 8:0x5A68 + index * 8]
        bank = record[0]
        if bank not in ranges:
            continue
        graphics = int.from_bytes(record[1:3], "little")
        rows = int.from_bytes(record[3:5], "little")
        palette = int.from_bytes(record[6:8], "little")
        add(bank, graphics, rows, "graphics", f"ScrollScene{index:02}Tiles")
        add(bank, rows, palette, "rows", f"ScrollScene{index:02}Rows")
        add(bank, palette, palette + 8, "palette", f"ScrollScene{index:02}Palette")

    asset_root = ROOT / "assets" / "scenes"
    asset_root.mkdir(parents=True, exist_ok=True)
    manifest = []
    for bank in BANKS:
        points = {0x4000, 0x7FFF, 0x8000}
        for start, end, _, _ in ranges[bank]:
            points.update((start, end))
        points = sorted(points)
        lines = [
            f"; BattleTanx (USA) - overlapping scene data bank ${bank:02X}",
            "",
            f'SECTION "ROM Bank ${bank:02X}", ROMX[$4000], BANK[${bank:02X}]',
        ]
        for start, end in zip(points, points[1:]):
            if start == 0x7FFF:
                lines.extend(["", f"\tdb ${bank:02X} ; bank marker"])
                continue
            active = [item for item in ranges[bank] if item[0] <= start and end <= item[1]]
            for name in labels[bank].get(start, []):
                lines.extend(["", f"{name}:"])
            data = rom[rom_offset(bank, start):rom_offset(bank, end)]
            structured = [item for item in active if item[2] != "graphics"]
            kinds = {item[2] for item in structured}
            if "rows" in kinds or "palette" in kinds:
                emit_words(lines, data, 20 if kinds == {"rows"} else 4)
            elif "map" in kinds or "attributes" in kinds:
                emit_bytes(lines, data, 20)
            elif active:
                asset = pathlib.Path("assets/scenes") / (
                    f"bank_{bank:02X}_tiles_{start:04X}_{end - 1:04X}.2bpp"
                )
                (ROOT / asset).write_bytes(data)
                manifest.append((asset, rom_offset(bank, start), len(data)))
                lines.append(f'\tINCBIN "{asset.as_posix()}"')
            else:
                if data != bytes(len(data)):
                    raise SystemExit(
                        f"bank ${bank:02X} unknown ${start:04X}-${end - 1:04X} is not zero"
                    )
                lines.append(f"\tds ${end - start:X}, 0")
            lines.append(f"ASSERT @ == ${end:04X}")
        lines.extend(["ASSERT @ == $8000", ""])
        (ROOT / "src" / f"bank_{bank:02X}.asm").write_text("\n".join(lines))

    for path, offset, size in manifest:
        print(f"{path.as_posix()} {offset:#x} {size:#x}")


if __name__ == "__main__":
    main()
