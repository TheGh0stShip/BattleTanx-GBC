#!/usr/bin/env python3
"""Extract confirmed Game Boy 2bpp ranges as lossless preview PNGs."""

from __future__ import annotations

import pathlib
import subprocess
import sys


def fail(message: str) -> None:
    raise SystemExit(f"graphics: {message}")


def main() -> None:
    if len(sys.argv) != 4:
        fail("usage: extract_graphics.py ROM MANIFEST OUTPUT_DIR")
    rom_path, manifest_path, output_root = map(pathlib.Path, sys.argv[1:])
    rom = rom_path.read_bytes()
    count = 0
    for number, raw_line in enumerate(manifest_path.read_text().splitlines(), 1):
        line = raw_line.split("#", 1)[0].strip()
        if not line:
            continue
        fields = line.split()
        if len(fields) != 4:
            fail(f"{manifest_path}:{number}: expected path, offset, size, width")
        relpath = pathlib.Path(fields[0])
        offset, size, width = (int(value, 0) for value in fields[1:])
        if relpath.is_absolute() or ".." in relpath.parts:
            fail(f"{manifest_path}:{number}: unsafe output path {relpath}")
        if size <= 0 or size % 16:
            fail(f"{manifest_path}:{number}: 2bpp size must be a positive multiple of 16")
        tiles = size // 16
        if width <= 0:
            fail(f"{manifest_path}:{number}: width must be positive")
        padding = -tiles % width
        if offset < 0 or offset + size > len(rom):
            fail(f"{manifest_path}:{number}: range lies outside the ROM")

        png_path = output_root / relpath
        png_path.parent.mkdir(parents=True, exist_ok=True)
        tile_path = png_path.with_suffix(".2bpp")
        check_path = png_path.with_suffix(".roundtrip.2bpp")
        original = rom[offset : offset + size]
        tile_path.write_bytes(original)
        reverse_args = ["rgbgfx", "-r", str(width)]
        forward_args = ["rgbgfx", str(png_path)]
        if padding:
            # Reverse mode restores tiles omitted by a prior -x; using the same
            # option in forward mode removes those blank layout-only tiles.
            reverse_args += ["-x", str(padding)]
            forward_args += ["-x", str(padding)]
        subprocess.run(reverse_args + ["-o", str(tile_path), str(png_path)], check=True)
        subprocess.run(
            forward_args + ["-o", str(check_path), "-c", "dmg"], check=True
        )
        rebuilt = check_path.read_bytes()
        tile_path.unlink()
        check_path.unlink()
        if rebuilt != original:
            fail(f"round trip changed bytes for {relpath}")
        count += 1
    print(f"graphics: {count} sheets extracted and round-trip verified")


if __name__ == "__main__":
    main()
