#!/usr/bin/env python3
"""One-time source edit: replace the opaque blobs of banks $01/$02 with typed regions.

Each blob is described below as consecutive regions covering every byte. A
region is emitted as explicit source (palettes, tables, descriptors, unread
bytes) or as a narrowly named binary asset (tile data, the direction lookup).
Raw-pointer labels created earlier (`BankNNData_XXXX`) are rewritten to the new
labels or `label + offset`. Asset files are written from baserom.gbc once; the
checked-in source and assets are authoritative afterwards.
Usage: rewrite_blobs_01_05.py
"""
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent
ROM = (ROOT / "baserom.gbc").read_bytes()


def rd(bank, a, n):
    o = bank * 0x4000 + a - 0x4000
    return ROM[o:o + n]


def hx(bs):
    return ", ".join(f"${x:02X}" for x in bs)


def words(bank, a, n):
    return [rd(bank, a + 2 * i, 2)[0] | rd(bank, a + 2 * i, 2)[1] << 8 for i in range(n // 2)]


# (start, end, kind, label, comment, extra)
BLOBS = {
    ("src/bank_01.asm", "assets/bank_01/58DF.bin", 1, 0x58DF, 0x599D): [
        (0x58DF, 0x595F, "bin", "MenuCursorSpriteTiles", "8 tiles; LoadMenuCursorSprites -> VRAM $8780 (tiles $78-$7F)", "assets/bank_01/menu_cursor_sprite_tiles.2bpp"),
        (0x595F, 0x5967, "db8", "MenuCursorSpriteTileIds", "OAM tile ids written by LoadMenuCursorSprites", None),
        (0x5967, 0x596D, "dw3", "MenuCursorObjectPalette", "OBJ palette 0 colours 1-3 (LoadSingleObjectPalette)", None),
        (0x596D, 0x599D, "pictures", "MenuState05PictureDescriptors", "read by LoadMenuState05Graphics (RAM_D7CB); index wMenuState05Selection 0-2", None),
    ],
    ("src/bank_01.asm", "assets/bank_01/6E8A.bin", 1, 0x6E8A, 0x78F1): [
        (0x6E8A, 0x769A, "bin", "PasswordScreenTiles", "Func_01_66F6 copies 12 tiles from here and $80 tiles from +$80; the second copy runs on into the glyph tables", "assets/bank_01/password_screen_tiles.2bpp"),
        (0x769A, 0x7722, "db4", "PasswordGlyphTiles", "34 x 4 tile indices per glyph (Func_01_6789)", None),
        (0x7722, 0x77AA, "db4", "PasswordGlyphAttributes", "34 x 4 BG attributes, ORed with $0C (Func_01_6789)", None),
        (0x77AA, 0x77CA, "dw4", "PasswordBgPalettes", "BG palettes 4-7 (Func_01_6746)", None),
        (0x77CA, 0x77D6, "dw3", "PasswordObjPaletteColours", "OBJ palettes 1 and 2, colours 1-3 (Func_01_6751)", None),
        (0x77D6, 0x77E4, "unread", "Bank01Unread77D6", "no reader", None),
        (0x77E4, 0x7854, "db8", "ObjectPaletteCycleTable", "14 x 8: bytes 0-5 = OBJ colours 1-3 for palettes 1 and 2, bytes 6-7 unread (CycleObjectPalettes12)", None),
        (0x7854, 0x785E, "db2", "PasswordCharColumns", "5 x 2 BG columns per character slot (DrawPasswordEntryChars)", None),
        (0x785E, 0x7866, "unread", "Bank01Unread785E", "no reader", None),
        (0x7866, 0x786C, "db6", "ScoreDigitColumns", "BG columns for the score digits (DrawScoreDigitsAtRow)", None),
        (0x786C, 0x786F, "unread", "Bank01Unread786C", "no reader", None),
        (0x786F, 0x7871, "db2", "LivesDigitColumns", "BG columns for the lives digits (DrawLivesDigitsAtRow)", None),
        (0x7871, 0x78B1, "bin", "Bank01SpriteTiles7871", "4 tiles; Func_01_696E -> VRAM $8740 (tiles $74-$77)", "assets/bank_01/sprite_tiles_7871.2bpp"),
        (0x78B1, 0x78F1, "bin", "Bank01SpriteTiles78B1", "4 tiles; Func_01_6A1D -> VRAM $8700 (tiles $70-$73)", "assets/bank_01/sprite_tiles_78B1.2bpp"),
    ],
    ("src/bank_02.asm", "assets/bank_02/481E.bin", 2, 0x481E, 0x4D58): [
        (0x481E, 0x4D52, "bin", "Bank02Unread481E", "no reader found", "assets/bank_02/unread_481E.bin"),
        (0x4D52, 0x4D58, "dw3", "Bank02ObjPalette7Colours", "OBJ palette 7 colours 1-3 (LoadIndexedSpriteGrid via LoadObjectPaletteRange)", None),
    ],
    ("src/bank_02.asm", "assets/bank_02/5040.bin", 2, 0x5040, 0x5C40): [
        (0x5040, 0x5440, "oam", "TrackerPointerFrames", "64 frames x 4 OAM entries (y, x, tile, attribute); TrackerDrawPointerSprites", None),
        (0x5440, 0x5C40, "bin", "TrackerDirectionLookup", "$800 bytes, two 4-bit directions per byte indexed by dx/dy (TrackerDrawPointerSprites)", "assets/bank_02/tracker_direction_lookup.bin"),
    ],
    ("src/bank_02.asm", "assets/bank_02/5DE0.bin", 2, 0x5DE0, 0x626D): [
        (0x5DE0, 0x5E20, "dw4", "BurstObjPalettes", "8 OBJ palettes (Bank02LoadObjPalettes)", None),
        (0x5E20, 0x5E80, "db4", "BurstBlockTileGrids", "six 4x4 tile grids; tile = byte - $62", None),
        (0x5E80, 0x5E89, "unread", "Bank02Unread5E80", "no reader", None),
        (0x5E89, 0x6099, "bin", "BurstTiles", "33 tiles; Bank02LoadObjTiles -> VRAM $8000", "assets/bank_02/burst_tiles.2bpp"),
        (0x6099, 0x614F, "db2", "BurstChildOffsets", "pairs read when a burst object expires", None),
        (0x614F, 0x624F, "db16", "BurstRandomTable", "256 bytes indexed by wBurstRandomIndex (Bank02NextTableRandom)", None),
        (0x624F, 0x6251, "db2", "BurstRandomTableEnd", "$FF $FF", None),
        (0x6251, 0x6265, "db2", "BurstChildCountTable", "count pairs", None),
        (0x6265, 0x626D, "db2", "BurstStartPositions", "four start positions", None),
    ],
}


def emit(bank, region, sym_by_addr):
    s, e, kind, label, comment, asset = region
    n = e - s
    out = [f"\n; {comment}", f"{label}:"]
    if kind == "bin":
        out.append(f'\tINCBIN "{asset}"')
    elif kind.startswith("db"):
        k = int(kind[2:]) if kind[2:] else 16
        for i in range(0, n, k):
            out.append("\tdb " + hx(rd(bank, s + i, min(k, n - i))))
    elif kind == "unread":
        for i in range(0, n, 8):
            out.append("\tdb " + hx(rd(bank, s + i, min(8, n - i))))
    elif kind in ("dw4", "dw3"):
        k = int(kind[2])
        ws = words(bank, s, n)
        for i in range(0, len(ws), k):
            out.append("\tdw " + ", ".join(f"${w:04X}" for w in ws[i:i + k]))
    elif kind == "oam":
        for f in range(n // 16):
            out.append(f"\t; frame {f}")
            for j in range(4):
                b = rd(bank, s + 16 * f + 4 * j, 4)
                out.append(f"\tdb {b[0]}, {b[1]}, ${b[2]:02X}, ${b[3]:02X}")
    elif kind == "pictures":
        for i in range(3):
            r = rd(bank, s + 16 * i, 16)
            ptr = [r[1 + 2 * k] | r[2 + 2 * k] << 8 for k in range(4)]
            names = []
            for p in ptr:
                cands = [x for x in sym_by_addr.get((r[0], p), []) if x.startswith("MenuState05Picture") or x.startswith("Picture596D") or x.startswith("Screen2E")]
                names.append(sorted(cands)[0] if cands else f"${p:04X}")
            out.append(f"\tdb BANK({names[0]})")
            out.append(f"\tdw {', '.join(names)}")
            out.append(f"\tdb ${r[9]:02X} ; palette bytes copied")
            out.append(f"\tds 6, $00 ; unread padding")
    else:
        raise SystemExit(kind)
    return out


def main():
    sym_by_addr = {}
    for line in (ROOT / "battletanx.sym").read_text().splitlines():
        m = re.fullmatch(r"([0-9a-fA-F]{2}):([0-9a-fA-F]{4}) (\S+)", line.strip())
        if m and "." not in m.group(3):
            sym_by_addr.setdefault((int(m.group(1), 16), int(m.group(2), 16)), []).append(m.group(3))
    assets_txt = (ROOT / "assets.txt").read_text()
    for (src, asset, bank, start, end), regions in BLOBS.items():
        assert regions[0][0] == start and regions[-1][1] == end
        for a, b in zip(regions, regions[1:]):
            assert a[1] == b[0], (asset, hex(a[1]))
        p = ROOT / src
        text = p.read_text()
        lines = text.split("\n")
        idx = [i for i, l in enumerate(lines) if f'INCBIN "{asset}"' in l]
        first, last = idx[0], idx[-1]
        while first > 0 and re.match(rf"^Bank{bank:02X}Data_[0-9A-F]{{4}}:$", lines[first - 1]):
            first -= 1
        block = []
        for r in regions:
            block += emit(bank, r, sym_by_addr)
            if r[2] == "bin":
                o = bank * 0x4000 + r[0] - 0x4000
                (ROOT / r[5]).write_bytes(ROM[o:o + r[1] - r[0]])
                assets_txt += f"{r[5]} {o:#x} {r[1] - r[0]:#x}\n"
        lines[first:last + 1] = block
        text = "\n".join(lines)
        # retarget earlier raw-pointer labels into these regions
        for m in set(re.findall(rf"\bBank{bank:02X}Data_([0-9A-F]{{4}})\b", text)):
            a = int(m, 16)
            if start <= a < end and not re.search(rf"^Bank{bank:02X}Data_{m}:", text, re.M):
                r = next(r for r in regions if r[0] <= a < r[1])
                expr = r[3] if a == r[0] else f"{r[3]} + ${a - r[0]:02X}"
                text = re.sub(rf"\bBank{bank:02X}Data_{m}\b", expr, text)
        p.write_text(text)
        assets_txt = "\n".join(l for l in assets_txt.split("\n") if not l.startswith(asset + " ")) + "\n"
        (ROOT / asset).unlink()
    (ROOT / "assets.txt").write_text(re.sub(r"\n+$", "\n", assets_txt))
    print("rewrote", len(BLOBS), "blobs")


if __name__ == "__main__":
    main()
