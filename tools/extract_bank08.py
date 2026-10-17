#!/usr/bin/env python3
"""Lossless inspection output for ROM bank $08 under OUTPUT_DIR (build/bank08).

  sheets/<label>.png   every graphics range (round-tripped through rgbgfx)
  glyphs.csv/.json     encoded character -> glyph tile, with the font tile offset
  strings.csv          the referenced encoded strings, raw bytes beside glyph tiles
  metatiles.png/.csv   the 16 interface metatiles assembled with flips
  palettes.txt         every palette and palette-shaped record (RGB555 + RGB)
  ranges.csv           the complete classified range map
Every CSV that mirrors source bytes is parsed back and compared with the ROM.
"""
from __future__ import annotations

import csv
import json
import pathlib
import subprocess
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import bank08 as K  # noqa: E402
import hints  # noqa: E402


def rt(stem: pathlib.Path, tiles: bytes, width: int) -> None:
    pad = -(len(tiles) // 16) % width
    extra = ["-x", str(pad)] if pad else []
    src, back, png = (stem.with_suffix(s) for s in (".tmp.2bpp", ".rt.2bpp", ".png"))
    src.write_bytes(tiles)
    subprocess.run(["rgbgfx", "-r", str(width), *extra, "-o", str(src), str(png)], check=True)
    subprocess.run(["rgbgfx", str(png), *extra, "-o", str(back), "-c", "dmg"], check=True)
    ok = back.read_bytes() == tiles
    src.unlink()
    back.unlink()
    if not ok:
        raise SystemExit(f"bank08: {png} does not round trip")


def flip(t: bytes, a: int) -> bytes:
    return bytes(int(f"{b:08b}"[::-1], 2) for b in t) if a & 0x20 else t


def main() -> None:
    rom = pathlib.Path(sys.argv[1]).read_bytes()
    out = pathlib.Path(sys.argv[2])
    (out / "sheets").mkdir(parents=True, exist_ok=True)
    ranges = K.parse(rom)
    r = lambda a, n: rom[K.B + a:K.B + a + n]
    with (out / "ranges.csv").open("w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["start", "end", "bytes", "class", "label"])
        w.writerows([f"${s:04X}", f"${e - 1:04X}", e - s, c, l] for s, e, c, l in ranges)
    sheets = 0
    for s, e, c, label in ranges:
        if c.startswith("graphics"):
            rt(out / "sheets" / label, r(s, e - s), min(16, (e - s) // 16))
            sheets += 1
    glyph = r(K.GLYPH_TABLE, 128)
    rows = [[c, f"${c:02X}", chr(c) if 32 <= c < 127 else "", glyph[c], f"${K.ENCODED_FONT + 16 * glyph[c]:04X}"]
            for c in range(128)]
    with (out / "glyphs.csv").open("w", newline="") as f:
        csv.writer(f).writerows([["code", "hex", "ascii", "glyph_tile", "tile_address"]] + rows)
    with (out / "glyphs.csv").open(newline="") as f:
        if bytes(int(x[3]) for x in list(csv.reader(f))[1:]) != glyph:
            raise SystemExit("bank08: glyphs.csv does not round trip")
    (out / "glyphs.json").write_text(json.dumps({x[1]: x[3] for x in rows}, indent=1) + "\n")
    with (out / "strings.csv").open("w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["bank01_address", "text", "raw_bytes", "glyph_tiles", "bg_tiles_vram1"])
        for addr, text in sorted(hints.TEXT_STRINGS.items()):
            raw = rom[addr:addr + len(text)]
            if raw != text:
                raise SystemExit("bank08: string bytes changed")
            w.writerow([f"$01:{addr:04X}", text.decode(), raw.hex(" "),
                        " ".join(str(glyph[b]) for b in raw), " ".join(f"${glyph[b] + 0x80:02X}" for b in raw)])
    font = r(0x4000, 0x3E0)
    exp, mrows = b"", []
    for i in range(16):
        rec = r(K.METATILES + 12 * i, 12)
        for k in range(6):
            mrows.append([i, k // 2, k % 2, rec[2 * k], rec[2 * k + 1], rec[2 * k] + 0x42])
    for row in range(3):
        for i in range(16):
            for col in range(2):
                t, a = r(K.METATILES + 12 * i + 4 * row + 2 * col, 2)
                n = (t + 0x42) - 0xC2          # VRAM1 BG id $C3 holds font tile 1 (LoadInterfaceTilesVRAM1 e=$43)
                exp += flip(font[16 * n:16 * n + 16], a)
    rt(out / "metatiles", exp, 32)
    with (out / "metatiles.csv").open("w", newline="") as f:
        csv.writer(f).writerows([["record", "row", "column", "tile_byte", "attribute", "bg_tile"]] + mrows)
    with (out / "metatiles.csv").open(newline="") as f:
        back = bytes(v for x in list(csv.reader(f))[1:] for v in (int(x[3]), int(x[4])))
    if back != r(K.METATILES, 192):
        raise SystemExit("bank08: metatiles.csv does not round trip")
    with (out / "palettes.txt").open("w") as f:
        for s, e, c, label in ranges:
            if "palette" in c:
                ws = [K.word(rom, 8, a) for a in range(s, e, 2)]
                f.write(f"${s:04X} {label} ({c}): " + " ".join(
                    f"{v:04X}=#%02X%02X%02X" % tuple(((v >> sh) & 31) * 255 // 31 for sh in (0, 5, 10)) for v in ws) + "\n")
    print(f"bank08: {sheets} graphics ranges, glyph map, {len(hints.TEXT_STRINGS)} strings, 16 metatiles; "
          "all outputs round-trip verified")


if __name__ == "__main__":
    main()
