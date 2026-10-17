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


def check_bank08_graphics_assets(entries: list[tuple[pathlib.Path, int, int]]) -> None:
    expected = {
        pathlib.Path("assets/bank_08/ui_font_tiles.bin"): (0x20000, 0x4A0),
        pathlib.Path("assets/bank_08/interface_tiles_60F8.bin"): (0x220F8, 0x10),
        pathlib.Path("assets/bank_08/interface_tiles_611A.bin"): (0x2211A, 0x100),
        pathlib.Path("assets/bank_08/interface_tiles_6222.bin"): (0x22222, 0x20),
        pathlib.Path("assets/bank_08/interface_tiles_626B.bin"): (0x2226B, 0x4E0),
        pathlib.Path("assets/bank_08/hud_icon_tiles.bin"): (0x22753, 0xA0),
        pathlib.Path("assets/bank_08/interface_tiles_6815.bin"): (0x22815, 0xC0),
        pathlib.Path("assets/bank_08/interface_tiles_68DD.bin"): (0x228DD, 0x40),
        pathlib.Path("assets/bank_08/arrow_up_tiles.bin"): (0x22925, 0x40),
        pathlib.Path("assets/bank_08/arrow_down_tiles.bin"): (0x2296D, 0x40),
        pathlib.Path("assets/bank_08/alphanumeric_font_tiles.bin"): (0x229B5, 0x420),
    }
    manifest = {path: (start, size) for path, start, size in entries}
    for path, where in expected.items():
        if manifest.get(path) != where:
            fail(f"bank 08 graphics asset {path} is {manifest.get(path)}, expected {where}")
        if where[1] % 16:
            fail(f"bank 08 graphics asset {path} is not tile aligned")

    source = (ROOT / "src" / "bank_08.asm").read_text()
    for path in expected:
        if f'INCBIN "{path.as_posix()}"' not in source:
            fail(f"bank 08 source does not include named graphics asset {path}")
    for old_name in ("4000.bin", "69B5.bin"):
        if old_name in source:
            fail(f"bank 08 source returned to opaque asset name {old_name}")

    rom = (ROOT / "baserom.gbc").read_bytes()
    palettes = {
        0x204A0: (0x0C84, 0x314A, 0x4E51, 0x6738),
        0x2274B: (0x0000, 0x10A3, 0x3200, 0x42E0),
        0x228D5: (0x0000, 0x001F, 0x465F, 0x7FFF),
        0x2291D: (0x0000, 0x10A3, 0x1515, 0x1FFF),
        0x22965: (0x0000, 0x001F, 0x10A3, 0x7FFF),
        0x229AD: (0x0000, 0x0000, 0x0000, 0x03FE),
    }
    for offset, expected_colors in palettes.items():
        colors = tuple(
            int.from_bytes(rom[pos : pos + 2], "little")
            for pos in range(offset, offset + 8, 2)
        )
        if colors != expected_colors or any(color & 0x8000 for color in colors):
            fail(f"bank 08 palette at ROM offset {offset:#x} changed")

    if rom[0x227F3:0x227FD] != bytes((0, 1, 0, 2, 3, 1, 2, 0, 3, 0)):
        fail("bank 08 palette-index table changed")
    object_palettes = {
        0x206EA: (0x001C, 0x025C, 0x03FF),
        0x227FD: (
            0x0000, 0x7002, 0x03FE,
            0x0C12, 0x001F, 0x7FFF,
            0x1515, 0x15DE, 0x1FFF,
            0x0000, 0x5818, 0x7E9F,
        ),
    }
    for offset, expected_colors in object_palettes.items():
        colors = tuple(
            int.from_bytes(rom[pos : pos + 2], "little")
            for pos in range(offset, offset + len(expected_colors) * 2, 2)
        )
        if colors != expected_colors or any(color & 0x8000 for color in colors):
            fail(f"bank 08 object palette at ROM offset {offset:#x} changed")

    sym = ROOT / "battletanx.sym"
    if sym.exists():
        expected_symbols = {
            "SelectObjectSpritePaletteFar": (0x00, 0x37AC),
            "LoadObjectPalettes": (0x00, 0x07A7),
            "LoadInterfaceTilesVRAM1": (0x00, 0x0807),
            "LoadInterfaceTilesVRAM0": (0x00, 0x0879),
            "LoadInterfacePalettes": (0x00, 0x092F),
            "Bank08UiFontTiles": (0x08, 0x4000),
            "Bank08UiFontPalette": (0x08, 0x44A0),
            "Bank08ObjectPalette46EA": (0x08, 0x46EA),
            "Bank08InterfaceTiles60F8": (0x08, 0x60F8),
            "Bank08InterfaceTiles611A": (0x08, 0x611A),
            "Bank08InterfaceTiles6222": (0x08, 0x6222),
            "Bank08InterfaceTiles626B": (0x08, 0x626B),
            "Bank08HudIconPalette": (0x08, 0x674B),
            "Bank08HudIconTiles": (0x08, 0x6753),
            "Bank08ArrowUpPalette": (0x08, 0x691D),
            "Bank08ArrowUpTiles": (0x08, 0x6925),
            "Bank08ArrowDownPalette": (0x08, 0x6965),
            "Bank08ArrowDownTiles": (0x08, 0x696D),
            "Bank08AlphanumericFontPalette": (0x08, 0x69AD),
            "Bank08AlphanumericFontTiles": (0x08, 0x69B5),
            "ObjectSpritePaletteIndexTable": (0x08, 0x67F3),
            "Bank08ObjectPalettes67FD": (0x08, 0x67FD),
            "Bank08InterfaceTiles6815": (0x08, 0x6815),
            "Bank08InterfacePalette68D5": (0x08, 0x68D5),
            "Bank08InterfaceTiles68DD": (0x08, 0x68DD),
            "SelectObjectSpritePalette": (0x08, 0x6DD5),
            "wHudIconPalette": (0x00, 0xC6F9),
            "wArrowUpPalette": (0x00, 0xC701),
            "wArrowDownPalette": (0x00, 0xC709),
            "wAlphanumericFontPalette": (0x00, 0xC711),
            "wUiFontPalette": (0x00, 0xC721),
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
        for name, where in expected_symbols.items():
            if symbols.get(name) != where:
                fail(f"bank 08 symbol {name} is at {symbols.get(name)}, expected {where}")


def check_sprite_bank_palettes(entries: list[tuple[pathlib.Path, int, int]]) -> None:
    expected_assets = {
        pathlib.Path(f"assets/bank_{bank:02X}/orientation_tiles.bin"):
            (bank * 0x4000, 0x510)
        for bank in (0x27, 0x28, 0x29)
    }
    manifest = {path: (start, size) for path, start, size in entries}
    for path, where in expected_assets.items():
        if manifest.get(path) != where:
            fail(f"sprite data asset {path} is {manifest.get(path)}, expected {where}")

    rom = (ROOT / "baserom.gbc").read_bytes()
    layout_pointers = tuple(
        int.from_bytes(rom[0x14000 + pos : 0x14002 + pos], "little")
        for pos in range(0, 0x20, 2)
    )
    if layout_pointers != (0x4040,) * 9 + (0x4064,) * 7:
        fail("object orientation layout-pointer table changed")

    tile_pointers = tuple(
        int.from_bytes(rom[0x14020 + pos : 0x14022 + pos], "little")
        for pos in range(0, 0x20, 2)
    )
    expected_tile_pointers = (
        0x4000, 0x4090, 0x4120, 0x41B0, 0x4240, 0x42D0, 0x4360, 0x43F0,
        0x4480, 0x43F0, 0x4360, 0x42D0, 0x4240, 0x41B0, 0x4120, 0x4090,
    )
    if tile_pointers != expected_tile_pointers:
        fail("object orientation tile-pointer table changed")
    if sorted(set(tile_pointers)) != list(range(0x4000, 0x4510, 0x90)):
        fail("object orientation frames no longer cover $4000-$450F exactly")

    if tuple(rom[offset : offset + 2] for offset in (0x9C510, 0xA0510, 0xA4510)) != (
        bytes.fromhex("8c31"), bytes.fromhex("3967"), bytes.fromhex("3967")
    ):
        fail("unknown words preceding the object palettes changed")

    palettes = {
        0x9C512: (0x0040, 0x0260, 0x03E5),
        0xA0512: (0x7E51, 0x0000, 0x60E8),
        0xA4512: (0x0006, 0x1CFF, 0x52BF),
    }
    for offset, expected in palettes.items():
        colors = tuple(
            int.from_bytes(rom[pos : pos + 2], "little")
            for pos in range(offset, offset + 6, 2)
        )
        if colors != expected or any(color & 0x8000 for color in colors):
            fail(f"object palette at ROM offset {offset:#x} changed")

    for bank in (0x27, 0x28, 0x29):
        source = (ROOT / "src" / f"bank_{bank:02X}.asm").read_text()
        if "sprite_tiles.bin" in source or "sprite_data_4000.bin" in source:
            fail(f"bank {bank:#04x} returned to an overbroad graphics asset")

    sym = ROOT / "battletanx.sym"
    if sym.exists():
        expected_symbols = {
            "Bank27OrientationTiles": (0x27, 0x4000),
            "Bank28OrientationTiles": (0x28, 0x4000),
            "Bank29OrientationTiles": (0x29, 0x4000),
            "Bank27Unknown4510": (0x27, 0x4510),
            "Bank28Unknown4510": (0x28, 0x4510),
            "Bank29Unknown4510": (0x29, 0x4510),
            "Bank27ObjectPalette": (0x27, 0x4512),
            "Bank28ObjectPalette": (0x28, 0x4512),
            "Bank29ObjectPalette": (0x29, 0x4512),
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
        for name, where in expected_symbols.items():
            if symbols.get(name) != where:
                fail(f"sprite palette symbol {name} is at {symbols.get(name)}, expected {where}")

    # Banks $27-$29 full layout, assets and negative tests (BANKS_27_29_RESEARCH.md).
    sys.path.insert(0, str(ROOT / "tools"))
    import object_banks  # pylint: disable=import-outside-toplevel

    try:
        print(object_banks.validate_all(ROOT))
    except object_banks.ObjectBankError as exc:
        fail(f"object banks: {exc}")


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


def check_structured_scrolling_scene_banks(
    rom: bytes, entries: list[tuple[pathlib.Path, int, int]]
) -> None:
    """Validate explicit scrolling-scene source in banks $2F/$34-$3B."""
    banks = (0x2F, *range(0x34, 0x3C))
    prefix_ends = {0x3B: 0x5090}
    scenes = {bank: [] for bank in banks}
    for index in range(36):
        record = rom[0x5A60 + index * 8:0x5A68 + index * 8]
        bank = record[0]
        if bank not in scenes:
            continue
        graphics = int.from_bytes(record[1:3], "little")
        rows = int.from_bytes(record[3:5], "little")
        row_count = record[5] + 1
        palette = int.from_bytes(record[6:8], "little")
        scenes[bank].append((index, graphics, rows, row_count, palette))

    expected_assets = {}
    expected_symbols = {}
    counts = {
        "graphics": 0, "structured": 0, "rows": 0, "palettes": 0,
        "padding": 0, "unknown": 0
    }
    for bank, records in scenes.items():
        position = prefix_ends.get(bank, 0x4000)
        bank_base = bank * 0x4000 - 0x4000
        if position != 0x4000:
            # Bank $3B starts with an unreferenced package matching the fixed
            # 20x12 background format: tiles, map, attributes, 8 palettes.
            path = pathlib.Path("assets/scenes/bank_3B_gbc_warning_tiles.2bpp")
            expected_assets[path] = (bank_base + 0x4000, 0x0E70)
            tilemap = rom[bank_base + 0x4E70:bank_base + 0x4F60]
            attributes = rom[bank_base + 0x4F60:bank_base + 0x5050]
            palettes = rom[bank_base + 0x5050:bank_base + 0x5090]
            if len(tilemap) != 240 or len(attributes) != 240 or any(attributes):
                fail("scrolling source: bank $3B orphan fixed maps changed")
            if any(
                int.from_bytes(palettes[i:i + 2], "little") & 0x8000
                for i in range(0, len(palettes), 2)
            ):
                fail("scrolling source: bank $3B orphan palette has bit 15 set")
            source_indices = [
                (value & 0x7F) + (0 if value & 0x80 else 128)
                for value in tilemap
            ]
            if max(source_indices) >= 231:
                fail("scrolling source: bank $3B warning map exceeds its graphics span")
            expected_symbols.update({
                "Bank3BGbcWarningTiles": (0x3B, 0x4000),
                "Bank3BGbcWarningTileMap": (0x3B, 0x4E70),
                "Bank3BGbcWarningAttributes": (0x3B, 0x4F60),
                "Bank3BGbcWarningPalettes": (0x3B, 0x5050),
            })
            counts["graphics"] += 0x0E70
            counts["structured"] += 0x220
        for index, graphics, rows, row_count, palette in sorted(
            records, key=lambda item: item[1]
        ):
            if graphics != position or rows + row_count * 40 != palette:
                fail(f"scrolling source: bank ${bank:02X} scene {index} is not contiguous")
            path = pathlib.Path(f"assets/scenes/scroll_scene_{index:02}_tiles.2bpp")
            expected_assets[path] = (bank_base + graphics, rows - graphics)
            expected_symbols.update({
                f"ScrollScene{index:02}Tiles": (bank, graphics),
                f"ScrollScene{index:02}Rows": (bank, rows),
                f"ScrollScene{index:02}Palette": (bank, palette),
            })
            counts["graphics"] += rows - graphics
            counts["rows"] += row_count * 40
            counts["palettes"] += 8
            position = palette + 8
        tail = rom[bank_base + position:bank_base + 0x8000]
        if tail[:-1] != bytes(len(tail) - 1) or tail[-1:] != bytes((bank,)):
            fail(f"scrolling source: bank ${bank:02X} tail or marker changed")
        counts["padding"] += len(tail)

    manifest = {path: (offset, size) for path, offset, size in entries}
    for path, where in expected_assets.items():
        if manifest.get(path) != where:
            fail(f"scrolling source: asset {path} is {manifest.get(path)}, expected {where}")
    if any(
        offset // 0x4000 in banks and path not in expected_assets
        for path, offset, _ in entries
    ):
        fail("scrolling source: structured banks contain an unexpected asset")
    for bank in banks:
        source = (ROOT / "src" / f"bank_{bank:02X}.asm").read_text()
        if f'assets/bank_{bank:02X}/4000.bin' in source:
            fail(f"scrolling source: bank ${bank:02X} returned to a whole-bank blob")

    sym = ROOT / "battletanx.sym"
    if sym.exists():
        symbols = {}
        for line in sym.read_text().splitlines():
            match = re.fullmatch(
                r"([0-9a-fA-F]{2}):([0-9a-fA-F]{4}) (\S+)", line.strip()
            )
            if match:
                symbols[match.group(3)] = (
                    int(match.group(1), 16), int(match.group(2), 16)
                )
        for name, where in expected_symbols.items():
            if symbols.get(name) != where:
                fail(f"scrolling source: symbol {name} is at {symbols.get(name)}, expected {where}")

    missing = dict(manifest)
    missing.pop(next(iter(expected_assets)))
    if all(missing.get(path) == where for path, where in expected_assets.items()):
        fail("scrolling source: missing-asset negative test was not rejected")
    if 'assets/bank_34/4000.bin' not in '\tINCBIN "assets/bank_34/4000.bin"':
        fail("scrolling source: blob-name negative test was not rejected")

    total = sum(counts.values())
    if total != len(banks) * 0x4000:
        fail(f"scrolling source: accounted for {total} bytes, expected {len(banks) * 0x4000}")
    print(
        f"scrolling source: 32 scenes in banks $2F/$34-$3B "
        f"({counts['graphics']} graphics, {counts['structured']} structured, "
        f"{counts['rows']} rows, "
        f"{counts['palettes']} palettes, {counts['padding']} padding, "
        f"{counts['unknown']} unknown)"
    )


def check_fixed_scene_source(
    rom: bytes, entries: list[tuple[pathlib.Path, int, int]]
) -> None:
    """Validate overlapping fixed/scrolling layouts in banks $30-$33."""
    banks = range(0x30, 0x34)
    ranges = {bank: [] for bank in banks}
    labels = {}

    def add(bank, start, end, kind, name):
        if not 0x4000 <= start < end <= 0x8000:
            fail(f"fixed source: {name} lies outside bank ${bank:02X}")
        ranges[bank].append((start, end, kind, name))
        labels[name] = (bank, start)

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

    for index in range(32, 36):
        record = rom[0x5A60 + index * 8:0x5A68 + index * 8]
        bank = record[0]
        graphics = int.from_bytes(record[1:3], "little")
        rows = int.from_bytes(record[3:5], "little")
        palette = int.from_bytes(record[6:8], "little")
        add(bank, graphics, rows, "graphics", f"ScrollScene{index:02}Tiles")
        add(bank, rows, palette, "rows", f"ScrollScene{index:02}Rows")
        add(bank, palette, palette + 8, "palette", f"ScrollScene{index:02}Palette")

    expected_assets = {}
    physical = {"graphics": 0, "structured": 0, "padding": 0}
    overlap_bytes = 0
    for bank in banks:
        points = {0x4000, 0x7FFF, 0x8000}
        for start, end, _, _ in ranges[bank]:
            points.update((start, end))
        points = sorted(points)
        bank_base = bank * 0x4000 - 0x4000
        if points[0] != 0x4000 or points[-1] != 0x8000:
            fail(f"fixed source: bank ${bank:02X} event coverage is incomplete")
        for start, end in zip(points, points[1:]):
            active = [item for item in ranges[bank] if item[0] <= start and end <= item[1]]
            if len(active) > 1:
                overlap_bytes += end - start
            structured = [item for item in active if item[2] != "graphics"]
            data = rom[bank_base + start:bank_base + end]
            if start == 0x7FFF:
                if data != bytes((bank,)):
                    fail(f"fixed source: bank ${bank:02X} marker changed")
                physical["padding"] += 1
            elif structured:
                physical["structured"] += end - start
            elif active:
                path = pathlib.Path(
                    f"assets/scenes/bank_{bank:02X}_tiles_{start:04X}_{end - 1:04X}.2bpp"
                )
                expected_assets[path] = (bank_base + start, end - start)
                physical["graphics"] += end - start
            else:
                if data != bytes(len(data)):
                    fail(f"fixed source: bank ${bank:02X} unclassified bytes are not zero")
                physical["padding"] += end - start

    manifest = {path: (offset, size) for path, offset, size in entries}
    for path, where in expected_assets.items():
        if manifest.get(path) != where:
            fail(f"fixed source: asset {path} is {manifest.get(path)}, expected {where}")
    if any(
        offset // 0x4000 in banks and path not in expected_assets
        for path, offset, _ in entries
    ):
        fail("fixed source: banks $30-$33 contain an unexpected asset")
    for bank in banks:
        source = (ROOT / "src" / f"bank_{bank:02X}.asm").read_text()
        if f'assets/bank_{bank:02X}/4000.bin' in source:
            fail(f"fixed source: bank ${bank:02X} returned to a whole-bank blob")

    loader = (ROOT / "src" / "bank_01.asm").read_text()
    if "ld bc, $0038\n\tadd hl, bc\n\tld bc, $DC40\n\tld e, $08" not in loader:
        fail("fixed source: final-palette read no longer proves the 64-byte palette block")

    sym = ROOT / "battletanx.sym"
    if sym.exists():
        symbols = {}
        for line in sym.read_text().splitlines():
            match = re.fullmatch(
                r"([0-9a-fA-F]{2}):([0-9a-fA-F]{4}) (\S+)", line.strip()
            )
            if match:
                symbols[match.group(3)] = (
                    int(match.group(1), 16), int(match.group(2), 16)
                )
        for name, where in labels.items():
            if symbols.get(name) != where:
                fail(f"fixed source: symbol {name} is at {symbols.get(name)}, expected {where}")

    total = sum(physical.values())
    if total != len(banks) * 0x4000:
        fail(f"fixed source: accounted for {total} bytes, expected {len(banks) * 0x4000}")
    print(
        f"fixed source: 11 fixed and 4 scrolling scenes in banks $30-$33 "
        f"({physical['graphics']} graphics, {physical['structured']} structured, "
        f"{physical['padding']} padding; {overlap_bytes} dual-use bytes)"
    )


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


def check_menu_memory_symbols() -> None:
    expected = {
        "wMenuState": 0xD557,
        "wMenuRenderedState": 0xD559,
        "wMenuActive": 0xD55E,
        "wMenuPreviousButtons": 0xD55F,
        "wMenuRepeatTimer": 0xD560,
        "wMenuScrollDirection": 0xD563,
        "wMenuState05Selection": 0xD566,
        "wMenuGridColumn": 0xD567,
        "wMenuGridRow": 0xD568,
        "wMenuCursorSpritesEnabled": 0xD569,
    }
    memory = (ROOT / "include" / "memory.inc").read_text()
    definitions = {
        match.group(1): int(match.group(2), 16)
        for match in re.finditer(
            r"^DEF\s+(\w+)\s+EQU\s+\$([0-9A-Fa-f]+)", memory, re.MULTILINE
        )
    }
    for name, address in expected.items():
        if definitions.get(name) != address:
            fail(
                f"menu memory symbol {name} is {definitions.get(name)}, "
                f"expected {address:#06x}"
            )

    source = (ROOT / "src" / "bank_01.asm").read_text()
    for address in expected.values():
        if re.search(rf"\${address:04X}\b", source):
            fail(f"raw menu address {address:#06x} returned to bank 1 source")


def check_executable_ram_source() -> None:
    """Require executable copied images to be assembly, not raw byte arrays."""
    images = 0
    for path in sorted((ROOT / "src").glob("bank_*.asm")):
        in_image = False
        start = 0
        for number, line in enumerate(path.read_text().splitlines(), 1):
            if 'LOAD UNION "RAM code' in line:
                if in_image:
                    fail(f"{path.name}:{number}: nested RAM code image")
                in_image = True
                start = number
                images += 1
            elif in_image and line.strip() == "ENDL":
                in_image = False
            elif in_image and line.strip().startswith("db "):
                fail(
                    f"{path.name}:{number}: executable RAM image beginning at "
                    f"line {start} contains raw bytes"
                )
        if in_image:
            fail(f"{path.name}:{start}: unterminated RAM code image")
    if images != 31:
        fail(f"expected 31 executable RAM source images, found {images}")


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


def check_level_banks() -> None:
    """Banks $09-$26: level data boundaries, formats, source and manifest."""
    import re  # pylint: disable=import-outside-toplevel

    sys.path.insert(0, str(ROOT / "tools"))
    import level_data as lvl  # pylint: disable=import-outside-toplevel

    rom = (ROOT / "baserom.gbc").read_bytes()
    try:
        levels = lvl.parse_levels(rom)
        negatives = lvl.negative_tests(rom)
    except lvl.LevelDataError as exc:
        fail(f"levels: {exc}")

    expected = set()
    for level in levels:
        base = f"assets/levels/level_{level.number:02}"
        odd = level.cell_bank * 0x4000 - 0x4000
        even = level.map_bank * 0x4000 - 0x4000
        expected |= {
            (f"{base}/cellmap.bin", odd + level.cellmap_addr, level.cells),
            (f"{base}/tiles.2bpp", odd + level.tiles_addr, 16 * level.tile_count),
            (f"{base}/tilemap.bin", even + level.tilemap_addr, level.cells),
            (f"{base}/attrmap.bin", even + level.attrmap_addr, level.cells),
        }
    actual = set()
    for path, start, size in read_manifest():
        if lvl.FIRST_BANK * 0x4000 <= start < (lvl.LAST_BANK + 1) * 0x4000:
            actual.add((str(path), start, size))
    if actual != expected:
        fail(f"levels: assets.txt ranges differ: {sorted(actual ^ expected)[:4]}")

    manifest = {str(path): (start, size) for path, start, size in read_manifest()}
    bank5_assets = {
        "assets/bank_05/40B1.bin": (0x140B1, 0x24F),
        "assets/bank_05/431E.bin": (0x1431E, 0xE2),
        "assets/bank_05/452C.bin": (0x1452C, 0x974),
        "assets/bank_05/59E0.bin": (0x159E0, 0x2620),
    }
    for path, where in bank5_assets.items():
        if manifest.get(path) != where:
            fail(f"levels: bank $05 asset {path} is {manifest.get(path)}, expected {where}")

    if tuple(
        int.from_bytes(rom[position : position + 2], "little")
        for position in range(0x14EA0, 0x14EA8, 2)
    ) != (500, 1000, 3000, 1000):
        fail("levels: object score-value table changed")
    parameter_records = rom[0x15100:0x15120]
    if tuple(parameter_records[offset : offset + 3] for offset in range(0, 0x20, 8)) != (
        bytes.fromhex("06 0f 50"), bytes.fromhex("04 06 b4"),
        bytes.fromhex("05 05 4b"), bytes.fromhex("40 01 14"),
    ) or any(parameter_records[offset] for record in range(4) for offset in range(record * 8 + 3, record * 8 + 8)):
        fail("levels: object-type parameter table changed")

    inc = (ROOT / "include" / "level_data.inc").read_text()
    consts = {
        match[0]: int(match[1])
        for match in re.findall(r"DEF (LEVEL\d\d_\w+) EQU (\d+)", inc)
    }
    for level in levels:
        prefix = f"LEVEL{level.number:02}"
        expected_constants = {
            f"{prefix}_WIDTH": level.width,
            f"{prefix}_HEIGHT": level.height,
            f"{prefix}_TILE_COUNT": level.tile_count,
            f"{prefix}_PALETTE_COUNT": level.palette_count,
        }
        for name, value in expected_constants.items():
            if consts.get(name) != value:
                fail(f"levels: {name} is {consts.get(name)}, ROM record says {value}")

    for bank in range(lvl.FIRST_BANK, lvl.LAST_BANK + 1):
        source = (ROOT / "src" / f"bank_{bank:02X}.asm").read_text()
        if f"assets/bank_{bank:02X}/" in source or "level_bank_end" not in source:
            fail(f"levels: src/bank_{bank:02X}.asm lost its structured layout")
        if bank % 2 and ("_AttrLookup:" not in source or "_BGPalettes:" not in source):
            fail(f"levels: src/bank_{bank:02X}.asm must define its tables explicitly")

    bank5_source = (ROOT / "src" / "bank_05.asm").read_text()
    for symbol in ("LevelRecordPointers", "Level00_Record", "Level14_Record",
                   "LevelTileAnimationPointers", "LevelAttributeLookupPointers"):
        if f"{symbol}:" not in bank5_source:
            fail(f"levels: bank $05 is missing {symbol}")

    sym = ROOT / "battletanx.sym"
    if sym.exists():
        symbols = {}
        for line in sym.read_text().splitlines():
            match = re.fullmatch(r"([0-9a-fA-F]{2}):([0-9a-fA-F]{4}) (\S+)", line.strip())
            if match:
                symbols[match.group(3)] = (int(match.group(1), 16), int(match.group(2), 16))
        expected_symbols = {
            "LoadLevelRecord": (0x00, 0x188B),
            "LoadLevelData": (0x00, 0x18EE),
            "BuildLevelRowOffsets": (0x00, 0x1A10),
            "LoadLevelTiles": (0x00, 0x1A33),
            "LoadLevelPalettes": (0x00, 0x1A86),
            "LoadLevelCellMap": (0x00, 0x1AA4),
            "GetLevelCellTileAndAttr": (0x00, 0x1D93),
            "DrawLevelCellIfVisible": (0x00, 0x1D26),
            "WriteLevelCellToBGMap": (0x00, 0x1E84),
            "DrawLevelRow21": (0x00, 0x1E97),
            "DrawLevelColumn19": (0x00, 0x1EC5),
            "GetLevelBGMapAddress": (0x00, 0x1EF3),
            "DrawLevelRightColumn": (0x00, 0x1F12),
            "DrawLevelLeftColumn": (0x00, 0x1F2F),
            "DrawLevelTopRow": (0x00, 0x1F4A),
            "DrawLevelBottomRow": (0x00, 0x1F65),
            "DrawLevelViewport": (0x00, 0x1F82),
            "UpdateLevelCamera": (0x00, 0x1804),
            "RefreshLevelViewport": (0x00, 0x1AE4),
            "SetLevelScrollPosition": (0x00, 0x1B18),
            "SetLevelViewCellPosition": (0x00, 0x1B07),
            "CacheLevelRingRowOffset": (0x00, 0x1B3A),
            "CacheLevelViewRowOffset": (0x00, 0x1B4F),
            "ScrollLevelRight": (0x00, 0x1B75),
            "ScrollLevelLeft": (0x00, 0x1BE4),
            "ScrollLevelDown": (0x00, 0x1C4D),
            "ScrollLevelUp": (0x00, 0x1CBC),
            "ClassifyLevelXBoundary": (0x00, 0x243B),
            "ClassifyLevelYBoundary": (0x00, 0x246C),
            "TestLevelCellBit0AtPixel": (0x00, 0x16FF),
            "TestLevelCellBit1AtPixel": (0x00, 0x1756),
            "TestLevelCellBit2AtPixel": (0x00, 0x17AD),
            "TestLevelCellBit3AtPixel": (0x00, 0x16A8),
            "TestLevelCellBit0Footprint": (0x00, 0x23B6),
            "FindLevelCellRunLeftEdge": (0x00, 0x1531),
            "FindLevelCellRunRightEdge": (0x00, 0x1578),
            "FindLevelCellRunTopEdge": (0x00, 0x15C0),
            "FindLevelCellRunBottomEdge": (0x00, 0x1607),
            "ConvertLevelCellBit2ToLookupState": (0x00, 0x132E),
            "ConvertLevelCellBit3ToLookupState": (0x00, 0x1399),
            "StartLevelCellLookupTransition": (0x00, 0x14B3),
            "ConvertLevelCellBit3Region": (0x00, 0x12A1),
            "ConvertLevelCellBit2Region": (0x00, 0x12D8),
            "StartLevelCellRegionTransitionAtPixel": (0x00, 0x10E6),
            "ConvertVisibleLevelCellBit2Regions": (0x00, 0x1163),
            "ConvertLevelCellBit2RegionAtCell": (0x00, 0x11BB),
            "ConvertLevelCellBit3RegionAtPixel": (0x00, 0x1219),
            "ChooseRandomLevelRegionCell": (0x00, 0x1404),
            "StartLevelCellRegionTransitions": (0x00, 0x1425),
            "UpdateObjectFrameDisplacement": (0x00, 0x249E),
            "ObjectsWithin12Pixels": (0x00, 0x2523),
            "ResolveObjectLevelBit0Movement": (0x00, 0x2589),
            "HandleObjectLevelBit3Cell": (0x00, 0x2644),
            "DispatchNearbyType4Entity": (0x00, 0x24D0),
            "DispatchEntityHandlerFar": (0x00, 0x3764),
            "HandleObjectLevelBit1And2Cells": (0x00, 0x267F),
            "ResolveObjectType1ProximityMovement": (0x00, 0x27E8),
            "ObjectCandidatesWithin20Pixels": (0x00, 0x285B),
            "GetObjectScoreValue": (0x00, 0x0C1A),
            "AddToScore": (0x00, 0x3019),
            "LoadLevelLookupPointers": (0x05, 0x4088),
            "ObjectScoreValues": (0x05, 0x4EA0),
            "ObjectTypeParameterTable": (0x05, 0x5100),
            "LevelRecordPointers": (0x05, 0x4300),
            "Level00_Record": (0x05, 0x4400),
            "Level14_Record": (0x05, 0x4518),
            "LevelTileAnimationPointers": (0x05, 0x5120),
            "LevelAttributeLookupPointers": (0x05, 0x513E),
            "LevelTileAnimationSet0": (0x05, 0x517A),
            "LevelTileAnimationSet1": (0x05, 0x532D),
            "LevelTileAnimationSet2": (0x05, 0x54CC),
            "LevelTileAnimationSet3": (0x05, 0x56A7),
            "LevelTileAnimationSet4": (0x05, 0x5800),
            "SetLevelViewCellPositionBank2": (0x02, 0x4263),
        }
        for name, where in expected_symbols.items():
            if symbols.get(name) != where:
                fail(f"levels: symbol {name} is at {symbols.get(name)}, expected {where}")

    memory_source = (ROOT / "include" / "memory.inc").read_text()
    memory_symbols = {
        name: int(address, 16)
        for name, address in re.findall(r"DEF (wLevel\w+)\s+EQU \$([0-9A-Fa-f]+)", memory_source)
    }
    expected_memory = {
        "wLevelTileBank": 0xC8B9, "wLevelPaletteBank": 0xC8BA,
        "wLevelCellMapBank": 0xC8BB, "wLevelMapBank": 0xC8BC,
        "wLevelPaletteCount": 0xC8C0, "wLevelTiles": 0xC8C1,
        "wLevelPalettes": 0xC8C3, "wLevelAttributeMap": 0xC8C5,
        "wLevelTileMap": 0xC8C7, "wLevelCellMap": 0xC8C9,
        "wLevelAnimationFrame": 0xC8CB, "wLevelTileAnimationTable": 0xC8CE,
        "wLevelAttributeLookup": 0xC8D0, "wLevelAttributeLookupBank": 0xC8D2,
        "wLevelCameraX": 0xCA00, "wLevelCameraY": 0xCA02,
        "wLevelScrollX": 0xCA04, "wLevelScrollY": 0xCA05,
        "wLevelNumber": 0xCA06, "wLevelWidth": 0xCA09,
        "wLevelHeight": 0xCA0A, "wLevelPixelWidth": 0xCA0B,
        "wLevelPixelHeight": 0xCA0D, "wLevelViewY": 0xCA0F,
        "wLevelViewX": 0xCA10, "wLevelViewRowOffset": 0xCA11,
        "wLevelRingY": 0xCA13, "wLevelRingX": 0xCA14,
        "wLevelRingRowOffset": 0xCA15, "wLevelRowOffsets": 0xCA17,
    }
    if memory_symbols != expected_memory:
        fail(f"levels: WRAM symbols differ: {memory_symbols.items() ^ expected_memory.items()}")

    hram_symbols = {
        name: int(address, 16)
        for name, address in re.findall(
            r"DEF (hLevelRegion\w+)\s+EQU \$([0-9A-Fa-f]+)", memory_source
        )
    }
    expected_hram = {
        "hLevelRegionLeft": 0xFF90, "hLevelRegionRight": 0xFF91,
        "hLevelRegionTop": 0xFF92, "hLevelRegionBottom": 0xFF93,
        "hLevelRegionY": 0xFF94, "hLevelRegionX": 0xFF95,
        "hLevelRegionRetryCount": 0xFF9C,
        "hLevelRegionChangedCount": 0xFF9D,
        "hLevelRegionScore": 0xFF9E,
    }
    if hram_symbols != expected_hram:
        fail(f"levels: HRAM symbols differ: {hram_symbols.items() ^ expected_hram.items()}")

    print(
        f"levels: {len(levels)} levels in banks $09-$26, every byte in one range, "
        f"{negatives} negative tests rejected"
    )


SCREEN_SYMBOLS = {
    # name: (bank, address) for standalone routine entries in banks $2A-$2E
    "FixedScreen2A_LoadTiles": (0x2A, 0x7719),
    "FixedScreen2A_Draw": (0x2A, 0x7754),
    "FixedScreen2A_Run": (0x2A, 0x7774),
    "FixedScreen2A_DrawFrame": (0x2A, 0x7795),
}


def check_screen_banks(entries: list[tuple[pathlib.Path, int, int]]) -> None:
    """Banks $2A-$2E: coverage, templates, tables, assets, source, symbols."""
    sys.path.insert(0, str(ROOT / "tools"))
    import screen_data as scr  # pylint: disable=import-outside-toplevel

    rom = (ROOT / "baserom.gbc").read_bytes()
    try:
        packages, ranges = scr.parse(rom)
        negatives = scr.negative_tests(rom)
    except scr.ScreenDataError as exc:
        fail(f"screens: {exc}")

    def manifest_problem(manifest):
        want = {
            (scr.off(bank, start), end - start)
            for bank, start, end, kind, _ in ranges
            if kind == "graphics"
        }
        have = {
            (start, size)
            for _, start, size in manifest
            if 0x2A * 0x4000 <= start < 0x2F * 0x4000
        }
        return (
            None
            if want == have
            else f"assets.txt tile ranges differ: {sorted(want ^ have)[:4]}"
        )

    def source_problem(bank, source):
        if f"assets/bank_{bank:02X}/" in source:
            return f"src/bank_{bank:02X}.asm includes an opaque bank blob"
        return None

    symbols = dict(SCREEN_SYMBOLS)
    for package in packages:
        symbols[f"{package.name}_LoadTiles"] = (package.bank, package.load)
        symbols[f"{package.name}_Draw"] = (package.bank, package.draw)
        symbols[f"{package.name}_Descriptor"] = (package.bank, package.desc)
        symbols[f"{package.name}_TileMap"] = (package.bank, package.tilemap)
        symbols[f"{package.name}_Palettes"] = (package.bank, package.palettes)

    def symbol_problem(table):
        for name, where in symbols.items():
            if table.get(name) != where:
                return f"symbol {name} at {table.get(name)}, expected {where}"
        return None

    problems = [manifest_problem(entries)]
    problems.extend(
        source_problem(
            bank, (ROOT / "src" / f"bank_{bank:02X}.asm").read_text()
        )
        for bank in scr.BANKS
    )
    for problem in problems:
        if problem:
            fail(f"screens: {problem}")

    sym = ROOT / "battletanx.sym"
    table = {}
    if sym.exists():
        for line in sym.read_text().splitlines():
            match = re.fullmatch(
                r"([0-9a-fA-F]{2}):([0-9a-fA-F]{4}) (\S+)", line.strip()
            )
            if match:
                table[match.group(3)] = (
                    int(match.group(1), 16), int(match.group(2), 16)
                )
        problem = symbol_problem(table)
        if problem:
            fail(f"screens: {problem}")

    # Controlled negative tests for manifest, source, and symbol checks.
    graphics = [
        entry
        for entry in entries
        if 0x2A * 0x4000 <= entry[1] < 0x2F * 0x4000
    ]
    shifted = list(entries)
    shifted_entry = graphics[0]
    shifted[shifted.index(shifted_entry)] = (
        shifted_entry[0], shifted_entry[1] + 1, shifted_entry[2]
    )
    bad_table = dict(symbols)
    bad_table["ScreenMode07_Draw"] = (0x2B, 0x4059)
    checks = [
        manifest_problem([entry for entry in entries if entry != graphics[0]]),
        manifest_problem(shifted),
        source_problem(0x2B, '\tINCBIN "assets/bank_2B/40CC.bin"\n'),
        symbol_problem(bad_table),
    ]
    if not all(checks):
        fail("screens: a manifest/source/symbol negative test was not rejected")
    negatives += len(checks)

    counts = {}
    for _, start, end, kind, _ in ranges:
        counts[kind] = counts.get(kind, 0) + end - start
    print(
        "screens: banks $2A-$2E fully classified ("
        + ", ".join(f"{kind} {count}" for kind, count in sorted(counts.items()))
        + f"), {len(packages)} screen packages, {negatives} negative tests rejected"
        + ("" if sym.exists() else "; symbol check skipped (no battletanx.sym)")
    )


TEXT_SYMBOLS = {
    "LoadEncodedFontTiles": (0x00, 0x2A99),
    "ClearTextCursor": (0x00, 0x2AB9),
    "AdvanceTextColumn": (0x00, 0x2AC4),
    "DrawEncodedText": (0x00, 0x2ACE),
    "DrawEncodedGlyph": (0x00, 0x2AF7),
    "SetTextCursor": (0x00, 0x2B58),
    "StartTextRow": (0x00, 0x2B67),
    "AdvanceTextRow": (0x00, 0x2B75),
    "ClearTextColumn": (0x00, 0x2B7F),
    "OptionsMenuEntries": (0x01, 0x48C0),
    "ControlTypeTexts": (0x01, 0x499B),
    "SkillTexts": (0x01, 0x49B3),
    "DrawOptionsEntryLabel": (0x01, 0x4FE0),
    "DrawOptionsEntryValue": (0x01, 0x5013),
}


def check_text(rom: bytes) -> None:
    """Validate the presently referenced encoded strings and their renderers."""
    option_expected = [
        (1, 2, 0xD55B, 0, 4, b"MUSIC"),
        (2, 3, 0xD55C, 3, 8, b"CONTROL"),
        (3, 4, 0xD55D, 3, 12, b"SKILL"),
    ]

    def option_problem(data: bytes):
        for index, expected in enumerate(option_expected):
            record = data[index * 16:(index + 1) * 16]
            if len(record) != 16:
                return f"option record {index} is truncated"
            ident, kind = record[:2]
            pointer = int.from_bytes(record[2:4], "little")
            column, row = record[4:6]
            text = record[6:]
            actual = (ident, kind, pointer, column, row)
            if actual != expected[:5]:
                return f"option record {index} fields are {actual}, expected {expected[:5]}"
            terminator = text.find(0)
            if terminator < 0:
                return f"option record {index} has no terminator"
            if text[:terminator] != expected[5] or any(text[terminator:]):
                return f"option record {index} text or padding differs"
            if any(not (byte == 0x20 or 0x30 <= byte <= 0x39 or 0x41 <= byte <= 0x5A)
                   for byte in text[:terminator]):
                return f"option record {index} has an unsupported character"
        return None

    def fixed_problem(data: bytes, address: int, width: int, expected: list[bytes]):
        for index, value in enumerate(expected):
            record = data[address + index * width:address + (index + 1) * width]
            if record != value + bytes(width - len(value)):
                return f"text record at ${address + index * width:04X} differs"
        return None

    options = rom[0x48C0:0x48F0]
    problems = [
        option_problem(options),
        fixed_problem(rom, 0x4993, 4, [b"ON ", b"OFF"]),
        fixed_problem(rom, 0x499B, 8, [b"1", b"2", b"3"]),
        fixed_problem(rom, 0x49B3, 8, [b"EASY", b"MED ", b"HARD"]),
    ]
    for problem in problems:
        if problem:
            fail(f"text: {problem}")

    # Only the two options-menu routines call the zero-terminated interpreter.
    if rom.count(b"\xCD\xCE\x2A") != 2:
        fail("text: expected exactly two direct calls to DrawEncodedText")

    bank0_source = (ROOT / "src" / "bank_00.asm").read_text()
    bank1_source = (ROOT / "src" / "bank_01.asm").read_text()
    if bank1_source.count("call DrawEncodedText") != 2:
        fail("text: source must contain exactly two DrawEncodedText calls")
    for raw in ("$C8DF", "$C8E0"):
        if raw in bank0_source or raw in bank1_source:
            fail(f"text: source returned to raw cursor address {raw}")
    for raw in ("$4993", "$4997", "$499B", "$49B3"):
        if raw in bank1_source:
            fail(f"text: bank $01 returned to raw address {raw}")

    memory_source = (ROOT / "include" / "memory.inc").read_text()
    for name, address in (("wTextColumn", 0xC8DF), ("wTextRow", 0xC8E0)):
        match = re.search(rf"DEF {name}\s+EQU \$([0-9A-Fa-f]+)", memory_source)
        actual = int(match.group(1), 16) if match else None
        if actual != address:
            fail(f"text: {name} is at {actual}, expected {address:#06x}")

    sym = ROOT / "battletanx.sym"
    if sym.exists():
        symbols = {}
        for line in sym.read_text().splitlines():
            match = re.fullmatch(
                r"([0-9a-fA-F]{2}):([0-9a-fA-F]{4}) (\S+)", line.strip()
            )
            if match:
                symbols[match.group(3)] = (
                    int(match.group(1), 16), int(match.group(2), 16)
                )
        for name, where in TEXT_SYMBOLS.items():
            if symbols.get(name) != where:
                fail(f"text: symbol {name} is at {symbols.get(name)}, expected {where}")

    corruptions = []
    mutated = bytearray(options)
    mutated[11:16] = b"XXXXX"
    corruptions.append(option_problem(mutated))
    mutated = bytearray(options)
    mutated[2] ^= 1
    corruptions.append(option_problem(mutated))
    mutated = bytearray(options)
    mutated[6] = ord("a")
    corruptions.append(option_problem(mutated))
    mutated = bytearray(rom)
    mutated[0x499B] = ord("4")
    corruptions.append(fixed_problem(mutated, 0x499B, 8, [b"1", b"2", b"3"]))
    if not all(corruptions):
        fail("text: a controlled corruption was not rejected")

    print("text: 3 option entries, 11 strings, 2 renderer calls, 4 negative tests rejected")


def check_unused_banks(rom: bytes, entries: list[tuple[pathlib.Path, int, int]]) -> None:
    """Banks $3C-$3F are entirely unprogrammed $FF cartridge capacity."""
    start = 0x3C * 0x4000
    if rom[start:] != bytes([0xFF]) * (4 * 0x4000):
        fail("unused banks: banks $3C-$3F contain a non-$FF byte")
    if any(start <= offset for _, offset, _ in entries):
        fail("unused banks: banks $3C-$3F returned to the asset manifest")
    for bank in range(0x3C, 0x40):
        source = (ROOT / "src" / f"bank_{bank:02X}.asm").read_text()
        if 'INCBIN "assets/' in source or "ds $4000, $FF" not in source:
            fail(f"unused banks: bank ${bank:02X} is not explicit $FF padding")
    print("unused banks: $3C-$3F are 65536 checked $FF padding bytes")


def main() -> None:
    check_toolchain()
    entries = read_manifest()
    check_assets(entries)
    check_bank08_graphics_assets(entries)
    check_sprite_bank_palettes(entries)
    rom = (ROOT / "baserom.gbc").read_bytes()
    check_unused_banks(rom, entries)
    check_scene_descriptors(rom)
    check_structured_scrolling_scene_banks(rom, entries)
    check_fixed_scene_source(rom, entries)
    check_menu_states(rom)
    check_menu_memory_symbols()
    check_text(rom)
    check_executable_ram_source()
    check_tracing()
    check_audio()
    check_screen_banks(entries)
    check_level_banks()
    digest = hashlib.sha1((ROOT / "baserom.gbc").read_bytes()).hexdigest()
    print(f"project: OK ({len(entries)} assets, baserom sha1 {digest})")


if __name__ == "__main__":
    main()
