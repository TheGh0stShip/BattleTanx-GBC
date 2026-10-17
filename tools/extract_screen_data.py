#!/usr/bin/env python3
"""Write lossless inspection outputs for the pictures in banks $2A-$2E.

OUTPUT_DIR/<picture>/: tilemap.csv, attrmap.csv (raw bytes, one map row
per line), cells.csv (decoded tile number, palette, VRAM bank, flips,
priority), palettes.txt, info.json, tiles.png and render.png (grayscale
inspection aids). Every CSV is parsed back and compared with the ROM;
both PNGs go back through rgbgfx and must reproduce the source tiles.
"""
from __future__ import annotations

import csv
import json
import pathlib
import subprocess
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import screen_data as S  # noqa: E402


def fail(msg: str) -> None:
    raise SystemExit(f"screens: {msg}")


def flip(tile: bytes, attr: int) -> bytes:
    rows = [tile[i:i + 2] for i in range(0, 16, 2)]
    if attr & 0x40:
        rows.reverse()
    if attr & 0x20:
        rows = [bytes(int(f"{b:08b}"[::-1], 2) for b in r) for r in rows]
    return b"".join(rows)


def rgb(w: int) -> str:
    return "#%02X%02X%02X" % tuple(((w >> s) & 31) * 255 // 31 for s in (0, 5, 10))


def png_round_trip(stem: pathlib.Path, tiles: bytes, width: int) -> None:
    pad = -(len(tiles) // 16) % width
    src, back, png = (stem.with_suffix(s) for s in (".tmp.2bpp", ".roundtrip.2bpp", ".png"))
    src.write_bytes(tiles)
    extra = ["-x", str(pad)] if pad else []
    subprocess.run(["rgbgfx", "-r", str(width), *extra, "-o", str(src), str(png)], check=True)
    subprocess.run(["rgbgfx", str(png), *extra, "-o", str(back), "-c", "dmg"], check=True)
    ok = back.read_bytes() == tiles
    src.unlink()
    back.unlink()
    if not ok:
        fail(f"{png} does not round trip")


def grid(path: pathlib.Path, data: bytes, width: int) -> None:
    with path.open("w", newline="") as f:
        csv.writer(f).writerows(data[r * width:(r + 1) * width] for r in range(len(data) // width))
    with path.open(newline="") as f:
        if bytes(int(v) for row in csv.reader(f) for v in row) != data:
            fail(f"{path} does not round trip")


def pictures(rom):
    pk, _ = S.parse(rom)
    for p in pk:
        maps = [("", p.tilemap, p.attrmap)]
        if p.name in S.ALT_MAPS:
            maps.append(("alt_", *S.ALT_MAPS[p.name]))
        yield (p.name, p.bank, p.tiles, p.tile_count, p.width, p.height, maps, p.palettes, p.palette_count)
    f = S.FIXED_2A
    yield ("FixedScreen2A", 0x2A, f["tiles"], f["tile_count"], 20, 18,
           [("", f["tilemap"], f["attrmap"])], f["palettes"], 8)
    yield ("FixedScreen2A_Frames", 0x2A, f["tiles"], f["tile_count"], 20, 11,
           [("", f["frames_tilemap"], f["frames_attrmap"])], f["palettes"], 8)
    for i in range(2):
        e = S.read(rom, 0x01, 0x596D + 16 * i, 9)
        tl, tm, am, pal = (e[1 + 2 * k] | e[2 + 2 * k] << 8 for k in range(4))
        yield (f"Picture596D{i}", 0x2E, tl, S.PICTURE_TILE_COUNTS[i], 20, 19, [("", tm, am)], pal, 8)


def main() -> None:
    if len(sys.argv) != 3:
        fail("usage: extract_screen_data.py ROM OUTPUT_DIR")
    rom = pathlib.Path(sys.argv[1]).read_bytes()
    root = pathlib.Path(sys.argv[2])
    count = 0
    for name, bank, tl, n, w, h, maps, pal, npal in pictures(rom):
        out = root / name
        out.mkdir(parents=True, exist_ok=True)
        tiles = S.read(rom, bank, tl, 16 * n)
        png_round_trip(out / "tiles", tiles, 16)
        for prefix, tm, am in maps:
            t, a = S.read(rom, bank, tm, w * h), S.read(rom, bank, am, w * h)
            grid(out / f"{prefix}tilemap.csv", t, w)
            grid(out / f"{prefix}attrmap.csv", a, w)
            with (out / f"{prefix}cells.csv").open("w", newline="") as f:
                wr = csv.writer(f)
                wr.writerow(["x", "y", "tile_id", "attributes", "block_tile", "palette",
                             "vram_bank", "x_flip", "y_flip", "priority"])
                for i, (ti, at) in enumerate(zip(t, a)):
                    wr.writerow([i % w, i // w, ti, at, S.tile_number(ti, at), at & 7,
                                 at >> 3 & 1, at >> 5 & 1, at >> 6 & 1, at >> 7 & 1])
            render = b"".join(flip(tiles[16 * S.tile_number(ti, at):][:16], at) for ti, at in zip(t, a))
            png_round_trip(out / f"{prefix}render", render, w)
        with (out / "palettes.txt").open("w") as f:
            for i in range(npal):
                ws = [S.word(rom, bank, pal + 8 * i + 2 * k) for k in range(4)]
                f.write(f"{i}: " + " ".join(f"{x:04X}" for x in ws) + " | " + " ".join(map(rgb, ws)) + "\n")
        (out / "info.json").write_text(json.dumps({
            "bank": f"${bank:02X}", "tiles": f"${tl:04X}", "tile_count": n, "width": w, "height": h,
            "maps": [{"prefix": p, "tilemap": f"${tm:04X}", "attrmap": f"${am:04X}"} for p, tm, am in maps],
            "palettes": f"${pal:04X}", "palette_count": npal}, indent=2) + "\n")
        count += 1
    print(f"screens: {count} pictures; CSV, palette and PNG outputs round-trip verified")


if __name__ == "__main__":
    main()
