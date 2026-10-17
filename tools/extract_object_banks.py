#!/usr/bin/env python3
"""Lossless inspection output for object banks $27-$29 (build/ only).

OUTPUT_DIR/bank_XX/: frames.png (9 frames x 9 tiles), orientations.png (16
assembled 3x3 objects using the $05 layout records, flips applied),
layout.csv (per orientation and OAM entry: y, x, tile, attribute, frame),
palette.txt and info.json. Both PNGs are converted back with rgbgfx and
compared with the source tiles; the CSV is compared with the bank-$05 records.
"""
from __future__ import annotations

import csv
import json
import pathlib
import subprocess
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import object_banks as O  # noqa: E402


def flip_x(tile: bytes) -> bytes:
    return bytes(int(f"{b:08b}"[::-1], 2) for b in tile)


def round_trip(stem: pathlib.Path, tiles: bytes, width: int) -> None:
    src, back, png = (stem.with_suffix(s) for s in (".tmp.2bpp", ".rt.2bpp", ".png"))
    src.write_bytes(tiles)
    subprocess.run(["rgbgfx", "-r", str(width), "-o", str(src), str(png)], check=True)
    subprocess.run(["rgbgfx", str(png), "-o", str(back), "-c", "dmg"], check=True)
    ok = back.read_bytes() == tiles
    src.unlink()
    back.unlink()
    if not ok:
        raise SystemExit(f"objects: {png} does not round trip")


def main() -> None:
    rom = pathlib.Path(sys.argv[1]).read_bytes()
    root = pathlib.Path(sys.argv[2])
    O.parse(rom)
    tptr = [O.word(rom, 5, O.TILE_PTRS + 2 * k) for k in range(O.ORIENTATIONS)]
    lptr = [O.word(rom, 5, O.LAYOUT_PTRS + 2 * k) for k in range(O.ORIENTATIONS)]
    for bank in O.BANKS:
        out = root / f"bank_{bank:02X}"
        out.mkdir(parents=True, exist_ok=True)
        frames = rom[O.off(bank, 0x4000):O.off(bank, O.FRAMES_END)]
        round_trip(out / "frames", frames, 9)
        rows, sheet = [], []
        for k in range(O.ORIENTATIONS):
            base = (tptr[k] - 0x4000) // 16
            recs = rom[O.off(5, lptr[k]):O.off(5, lptr[k]) + 36]
            grid = {}
            for e in range(9):
                y, x, t, a = recs[4 * e:4 * e + 4]
                rows.append([k, e, y - 256 if y > 127 else y, x - 256 if x > 127 else x, t, a,
                             (tptr[k] - 0x4000) // O.FRAME_SIZE])
                tile = frames[16 * (base + t):16 * (base + t) + 16]
                grid[((y + 12) & 0xFF) // 8, ((x + 12) & 0xFF) // 8] = flip_x(tile) if a & 0x20 else tile
            # one orientation = 3 tile rows of 3; lay 16 orientations side by side
            sheet.append([grid[r, c] for r in range(3) for c in range(3)])
        expanded = b"".join(sheet[k][r * 3 + c] for r in range(3) for k in range(16) for c in range(3))
        round_trip(out / "orientations", expanded, 48)
        with (out / "layout.csv").open("w", newline="") as f:
            w = csv.writer(f)
            w.writerow(["orientation", "entry", "y", "x", "tile", "attribute", "frame"])
            w.writerows(rows)
        with (out / "layout.csv").open(newline="") as f:
            back = list(csv.reader(f))[1:]
        for r, (k, e, y, x, t, a, _) in zip(back, rows):
            recs = rom[O.off(5, lptr[int(r[0])]):O.off(5, lptr[int(r[0])]) + 36]
            if bytes([int(r[2]) & 0xFF, int(r[3]) & 0xFF, int(r[4]), int(r[5])]) != recs[4 * int(r[1]):4 * int(r[1]) + 4]:
                raise SystemExit("objects: layout.csv does not round trip")
        unused_color0 = O.word(rom, bank, O.PALETTE_RECORD)
        pal = [O.word(rom, bank, O.PALETTE + 2 * c) for c in range(3)]
        (out / "palette.txt").write_text(
            f"source 0: {unused_color0:04X} (unused; Func_057D writes 0000)\n" + "".join(
            f"{c + 1}: {v:04X} #%02X%02X%02X\n" % tuple(((v >> s) & 31) * 255 // 31 for s in (0, 5, 10))
            for c, v in enumerate(pal)))
        (out / "info.json").write_text(json.dumps({
            "bank": f"${bank:02X}", "obj_palette_slot": bank - 0x27,
            "unused_palette_color_0": f"${unused_color0:04X}",
            "orientation_frames": [(p - 0x4000) // O.FRAME_SIZE for p in tptr],
            "orientation_x_flip": [lp == O.LAYOUT_FLIPPED for lp in lptr]}, indent=2) + "\n")
    print("objects: 3 banks; frame, orientation, layout and palette outputs round-trip verified")


if __name__ == "__main__":
    main()
