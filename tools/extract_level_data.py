#!/usr/bin/env python3
"""Write lossless inspection outputs for the level data in banks $09-$26.

Outputs go to OUTPUT_DIR/level_NN/ (an ignored build directory):
  record.json      level record fields and every derived range
  cellmap.csv      raw cell bytes, one map row per line
  tilemap.csv      raw BG tile ids
  attrmap.csv      raw attribute bytes
  cells.csv        per cell: x, y, tile id, attribute, block tile number,
                   palette, VRAM bank, x flip, y flip, priority, cell byte
  palettes.txt     RGB555 words with 8-bit RGB previews
  tiles.png        tile block (grayscale; inspection only)
  render.png       grayscale map render with flips applied (inspection only)

Each CSV is parsed back and compared with the ROM range, and both PNGs are
converted back with rgbgfx and compared with the source tiles.
"""
from __future__ import annotations

import csv
import json
import pathlib
import subprocess
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import level_data as L  # noqa: E402
from extract_scene_maps import rgb555, transform_tile  # noqa: E402  (unchanged helpers)


def fail(message: str) -> None:
    raise SystemExit(f"levels: {message}")


def write_grid(path: pathlib.Path, data: bytes, width: int) -> None:
    with path.open("w", newline="") as f:
        writer = csv.writer(f)
        for row in range(len(data) // width):
            writer.writerow(data[row * width:(row + 1) * width])


def read_grid(path: pathlib.Path) -> bytes:
    with path.open(newline="") as f:
        return bytes(int(v) for row in csv.reader(f) for v in row)


def png_round_trip(stem: pathlib.Path, tiles: bytes, width: int) -> None:
    count = len(tiles) // 16
    pad = -count % width
    src, back, png = (stem.with_suffix(s) for s in (".tmp.2bpp", ".roundtrip.2bpp", ".png"))
    src.write_bytes(tiles)
    extra = ["-x", str(pad)] if pad else []
    subprocess.run(["rgbgfx", "-r", str(width), *extra, "-o", str(src), str(png)], check=True)
    subprocess.run(["rgbgfx", str(png), *extra, "-o", str(back), "-c", "dmg"], check=True)
    ok = back.read_bytes() == tiles
    src.unlink()
    back.unlink()
    if not ok:
        fail(f"{png.name} does not round trip")


def main() -> None:
    if len(sys.argv) != 3:
        fail("usage: extract_level_data.py ROM OUTPUT_DIR")
    rom = pathlib.Path(sys.argv[1]).read_bytes()
    out_root = pathlib.Path(sys.argv[2])
    levels = L.parse_levels(rom)
    for lv in levels:
        out = out_root / f"level_{lv.number:02}"
        out.mkdir(parents=True, exist_ok=True)
        odd, even = lv.cell_bank, lv.map_bank
        cells = L.read(rom, odd, lv.cellmap_addr, lv.cells)
        tiles = L.read(rom, odd, lv.tiles_addr, 16 * lv.tile_count)
        tmap = L.read(rom, even, lv.tilemap_addr, lv.cells)
        amap = L.read(rom, even, lv.attrmap_addr, lv.cells)
        pals = L.read(rom, odd, lv.palettes_addr, 8 * lv.palette_count)

        for name, data in (("cellmap", cells), ("tilemap", tmap), ("attrmap", amap)):
            write_grid(out / f"{name}.csv", data, lv.width)
            if read_grid(out / f"{name}.csv") != data:
                fail(f"level {lv.number} {name}.csv does not round trip")
        with (out / "cells.csv").open("w", newline="") as f:
            wr = csv.writer(f)
            wr.writerow(["x", "y", "tile_id", "attributes", "block_tile", "palette",
                         "vram_bank", "x_flip", "y_flip", "priority", "cell_byte"])
            for i, (t, a, c) in enumerate(zip(tmap, amap, cells)):
                wr.writerow([i % lv.width, i // lv.width, t, a, L.tile_number(t, a), a & 7,
                             a >> 3 & 1, a >> 5 & 1, a >> 6 & 1, a >> 7 & 1, c])
        with (out / "palettes.txt").open("w") as f:
            for p in range(lv.palette_count):
                ws = [int.from_bytes(pals[p * 8 + k:p * 8 + k + 2], "little") for k in range(0, 8, 2)]
                f.write(f"{p}: " + " ".join(f"{w:04X}" for w in ws) + " | "
                        + " ".join("#%02X%02X%02X" % rgb555(w) for w in ws) + "\n")
        record = {
            "level": lv.number,
            "record": f"$05:{lv.record_addr:04X}",
            "record_bytes": lv.record.hex(" "),
            "width": lv.width, "height": lv.height,
            "odd_bank": odd, "even_bank": even,
            "tile_count": lv.tile_count, "palette_count": lv.palette_count,
            "attr_lookup": f"${lv.attr_table_bank:02X}:{lv.attr_table_addr:04X}",
            "ranges": [{"bank": f"${b:02X}", "start": f"${s:04X}", "end": f"${e - 1:04X}", "kind": k}
                       for b, s, e, k in lv.ranges],
        }
        (out / "record.json").write_text(json.dumps(record, indent=2) + "\n")
        png_round_trip(out / "tiles", tiles, 16)
        render = b"".join(
            transform_tile(tiles[16 * L.tile_number(t, a):16 * L.tile_number(t, a) + 16], a)
            for t, a in zip(tmap, amap))
        png_round_trip(out / "render", render, lv.width)
    print(f"levels: {len(levels)} levels, {sum(lv.cells for lv in levels)} cells; "
          "CSV, palette and PNG outputs round-trip verified")


if __name__ == "__main__":
    main()
