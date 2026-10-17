#!/usr/bin/env python3
"""Inventory, parser and validator for ROM banks $2A-$2E.

The five banks hold full-screen CGB pictures and the small routines that
load them. Every fact is derived from baserom.gbc; the routines that read
the data are cited in BANKS_2A_2E_RESEARCH.md.

Screen descriptor (14 bytes, copied to $C6D2 by the draw routines):
  +0 dw tiles      +2 dw tile map    +4 dw attribute map  +6 dw palettes
  +8 dw tile count +10 db width      +11 db height
  +12 db palette count               +13 db first palette
Only +10/+11 are read back from the copy ($C6DC/$C6DD by ROM0 $05C5).
"""
from __future__ import annotations

BANK_SIZE = 0x4000
BANKS = range(0x2A, 0x2F)
DESC_SIZE = 14
SCREEN_MODE_TABLE = (0x01, 0x47EC, 13)       # 8-byte entries: bank, 0, init, draw, 0
PICTURE_TABLE = (0x01, 0x596D, 3)           # 16-byte entries used by $01:RAM_D7CB


class ScreenDataError(ValueError):
    pass


def check(cond: bool, msg: str) -> None:
    if not cond:
        raise ScreenDataError(msg)


def off(bank: int, addr: int) -> int:
    return addr if bank == 0 else bank * BANK_SIZE + addr - 0x4000


def read(rom: bytes, bank: int, addr: int, n: int = 1) -> bytes:
    check(0x4000 <= addr and addr + n <= 0x8000, f"read outside ROMX ${bank:02X}:{addr:04X}")
    return rom[off(bank, addr):off(bank, addr) + n]


def word(rom: bytes, bank: int, addr: int) -> int:
    return int.from_bytes(read(rom, bank, addr, 2), "little")


def tile_number(tile: int, attr: int) -> int:
    """Index into a picture's tile block for a BG map entry.

    The loaders copy tiles 0-127 to VRAM0 $8800 (ids $80-$FF), 128-255 to
    VRAM0 $9000 (ids $00-$7F), 256-383 to VRAM1 $9000 (ids $00-$7F); the
    bank-$2A fixed screen also fills VRAM1 $8800 (384-511, ids $80-$FF).
    """
    if attr & 0x08:
        return 256 + tile if tile < 0x80 else 384 + tile - 0x80
    return tile - 0x80 if tile >= 0x80 else 128 + tile


# Screen packages: (name, bank, load routine, draw routine, draw kind, descriptor, modes)
# Draw kinds: "fade" writes $C6D1 = arg and fades in over 32 frames, "plain"
# loads [+12] palettes from [+13] directly. Modes are ScreenModeTable indexes.
PACKAGES = [
    ("ScreenMode00", 0x2D, 0x54FA, 0x5552, ("fade", 0), 0x55C6, (0,)),
    ("ScreenMode01", 0x2A, 0x61D8, 0x6230, ("fade", 0), 0x62A4, (1,)),
    ("ScreenMode02", 0x2C, 0x4000, 0x4058, ("fade", 0), 0x40CC, (2,)),
    ("ScreenMode03", 0x2C, 0x5ED3, 0x5F2B, ("fade", 0), 0x606B, (3,)),
    ("ScreenMode04", 0x2B, 0x6E6C, 0x6EC4, ("plain", None), 0x6F1D, (4,)),
    ("ScreenMode05", 0x2C, 0x4B3A, 0x4B92, ("fade", 0), 0x4C06, (5,)),
    ("ScreenMode06", 0x2C, 0x5F9F, 0x5FF7, ("fade", 0), 0x7DF9, (6,)),
    ("ScreenMode07", 0x2B, 0x4000, 0x4058, ("fade", 1), 0x40CC, (7,)),
    ("ScreenMode08", 0x2D, 0x4000, 0x4058, ("fade", 0), 0x40CC, (8,)),
    ("ScreenMode09", 0x2B, 0x5BDA, 0x5C32, ("fade", 0), 0x5CA6, (9, 10)),
    ("ScreenMode11", 0x2C, 0x55C4, 0x561C, ("plain", None), 0x5675, (11,)),
    ("ScreenMode12", 0x2A, 0x6A22, 0x6A7A, ("plain", None), 0x6AD3, (12,)),
    ("Screen2E", 0x2E, 0x4000, 0x4058, ("fade", 0), 0x40CC, ()),   # no caller found
]
LOAD_SIZE, FADE_SIZE, PLAIN_SIZE = 88, 116, 89
# Packages whose tile block is followed by one unreferenced all-zero tile.
ZERO_TILE_SLOT = {"ScreenMode12", "ScreenMode07", "ScreenMode09", "ScreenMode05"}
# ScreenMode03 interleaves a second 20x18 map pair read by $01:7981
# (bank $2C selected through $C943): $6CE9 (tiles, VRAM0), $6FB9 (attributes, VRAM1).
ALT_MAPS = {"ScreenMode03": (0x6CE9, 0x6FB9)}

# Bank $2A fixed screen, drawn by $2A:7774 (called from ROM0 $3F28).
FIXED_2A = dict(tiles=0x4000, tile_count=464, tilemap=0x5D00, frames_tilemap=0x5E68,
                attrmap=0x5F44, frames_attrmap=0x60AC, palettes=0x6188, palette_count=8,
                frame_table=0x61C8, frames=4, frame_w=5, frame_h=11, sheet_w=20)
FIXED_2A_CODE = [(0x7719, 0x7754, "FixedScreen2A_LoadTiles"),
                 (0x7754, 0x7774, "FixedScreen2A_Draw"),
                 (0x7774, 0x7795, "FixedScreen2A_Run"),
                 (0x7795, 0x7801, "FixedScreen2A_DrawFrame")]
# Pictures in bank $2E addressed only through $01:$596D (no descriptor).
PICTURE_TILE_COUNTS = {0: 272, 1: 260, 2: 273}


class Package:
    def __init__(self, rom, name, bank, load, draw, kind, desc, modes):
        self.name, self.bank, self.load, self.draw = name, bank, load, draw
        self.kind, self.desc, self.modes = kind, desc, modes
        h = read(rom, bank, desc, DESC_SIZE)
        w = lambda i: h[i] | h[i + 1] << 8
        self.tiles, self.tilemap, self.attrmap, self.palettes, self.tile_count = (w(i) for i in range(0, 10, 2))
        self.width, self.height, self.palette_count, self.first_palette = h[10], h[11], h[12], h[13]
        self.header = h

    @property
    def cells(self):
        return self.width * self.height

    @property
    def draw_size(self):
        return FADE_SIZE if self.kind[0] == "fade" else PLAIN_SIZE


def validate_maps(rom, bank, tilemap, attrmap, cells, tile_count, palette_limit, tag,
                  allow_bank1_high=False):
    tiles = read(rom, bank, tilemap, cells)
    attrs = read(rom, bank, attrmap, cells)
    nums = [tile_number(t, a) for t, a in zip(tiles, attrs)]
    check(max(nums) < tile_count, f"{tag}: tile {max(nums)} beyond count {tile_count}")
    check(all(a & 7 < palette_limit for a in attrs), f"{tag}: attribute palette out of range")
    check(not any(a & 0x10 for a in attrs), f"{tag}: attribute bit 4 set")
    if not allow_bank1_high:
        check(not any(t >= 0x80 and a & 8 for t, a in zip(tiles, attrs)),
              f"{tag}: VRAM1 tile id >= $80 is never loaded by this loader")
    return max(nums)


def validate_palettes(rom, bank, addr, count, tag):
    for i in range(count * 4):
        check(not word(rom, bank, addr + 2 * i) & 0x8000, f"{tag}: palette word {i} bit 15 set")


def template(rom, bank, start, size, desc_addr, desc_fields):
    """Routine bytes with every occurrence of the descriptor operand blanked."""
    raw = bytearray(read(rom, bank, start, size))
    lo, hi = desc_addr & 0xFF, desc_addr >> 8
    for i in range(len(raw) - 1):
        if raw[i] == lo and raw[i + 1] == hi and i in desc_fields:
            raw[i] = raw[i + 1] = 0
    return bytes(raw)


def operand_positions(rom, bank, start, size, desc):
    raw = read(rom, bank, start, size)
    return {i for i in range(size - 1) if raw[i] == desc & 0xFF and raw[i + 1] == desc >> 8
            and raw[i - 1] == 0x21}  # only `ld hl, desc` operands


def parse(rom: bytes):
    """Validate everything and return (packages, ranges)."""
    pk = [Package(rom, *p) for p in PACKAGES]
    ranges = []

    def add(bank, start, end, cls, label):
        check(end > start, f"empty range {label}")
        ranges.append((bank, start, end, cls, label))

    # Screen mode table must point at these packages, in order.
    tbank, taddr, tcount = SCREEN_MODE_TABLE
    by_mode = {m: p for p in pk for m in p.modes}
    check(sorted(by_mode) == list(range(tcount)), "screen modes not all assigned")
    for m in range(tcount):
        e = read(rom, tbank, taddr + 8 * m, 8)
        p = by_mode[m]
        check((e[0], e[2] | e[3] << 8, e[4] | e[5] << 8) == (p.bank, p.load, p.draw),
              f"ScreenModeTable entry {m} does not match {p.name}")

    # Templates: every load routine and each draw kind are byte-identical
    # apart from `ld hl, descriptor` operands (and the fade value byte).
    ref_load = ref_fade = ref_plain = None
    for p in pk:
        check(p.draw == p.load + LOAD_SIZE, f"{p.name}: draw routine does not follow load routine")
        lt = template(rom, p.bank, p.load, LOAD_SIZE, p.desc,
                      operand_positions(rom, p.bank, p.load, LOAD_SIZE, p.desc))
        dt = bytearray(template(rom, p.bank, p.draw, p.draw_size, p.desc,
                                operand_positions(rom, p.bank, p.draw, p.draw_size, p.desc)))
        check(len(operand_positions(rom, p.bank, p.load, LOAD_SIZE, p.desc)) == 4,
              f"{p.name}: load routine must reference its descriptor 4 times")
        if p.kind[0] == "fade":
            check(dt[0x4C] == 0x3E and dt[0x4D] == p.kind[1], f"{p.name}: fade value byte")
            dt[0x4D] = 0
        ref_load = ref_load or lt
        check(lt == ref_load, f"{p.name}: load routine differs from the template")
        if p.kind[0] == "fade":
            ref_fade = ref_fade or bytes(dt)
            check(bytes(dt) == ref_fade, f"{p.name}: fade draw routine differs from the template")
        else:
            ref_plain = ref_plain or bytes(dt)
            check(bytes(dt) == ref_plain, f"{p.name}: plain draw routine differs from the template")
        add(p.bank, p.load, p.draw, "code", f"{p.name}_LoadTiles")
        add(p.bank, p.draw, p.draw + p.draw_size, "code", f"{p.name}_Draw")

    # Package data: header, tiles, maps, palettes, laid out contiguously.
    for p in pk:
        tag = p.name
        hdr_end = p.desc + DESC_SIZE
        tiles_end = p.tiles + 16 * p.tile_count
        leading = p.tiles == hdr_end      # descriptor directly before its tiles
        check(p.width == 20 and p.height in (17, 18, 19, 20) or (p.width, p.height) == (22, 20),
              f"{tag}: size {p.width}x{p.height}")
        check(p.first_palette == 0 and 1 <= p.palette_count <= 8, f"{tag}: palette fields")
        slot = 16 if tag in ZERO_TILE_SLOT else 0
        if slot:
            check(not any(read(rom, p.bank, tiles_end, 16)), f"{tag}: extra tile slot not zero")
        cursor = tiles_end + slot
        maps = [("tilemap", p.tilemap), ("attrmap", p.attrmap)]
        if tag in ALT_MAPS:
            alt_t, alt_a = ALT_MAPS[tag]
            maps = [("alt tilemap", alt_t), ("tilemap", p.tilemap), ("alt attrmap", alt_a), ("attrmap", p.attrmap)]
        for name, addr in maps:
            check(addr == cursor, f"{tag}: {name} at {addr:#x}, expected {cursor:#x}")
            cursor += p.cells
        check(p.palettes == cursor, f"{tag}: palettes at {p.palettes:#x}, expected {cursor:#x}")
        pal_end = p.palettes + 8 * p.palette_count
        validate_palettes(rom, p.bank, p.palettes, p.palette_count, tag)
        used = validate_maps(rom, p.bank, p.tilemap, p.attrmap, p.cells, p.tile_count, p.palette_count, tag)
        check(used == p.tile_count - 1, f"{tag}: highest tile {used}, count {p.tile_count}")
        if tag in ALT_MAPS:
            validate_maps(rom, p.bank, ALT_MAPS[tag][0], ALT_MAPS[tag][1], p.cells, p.tile_count,
                          p.palette_count, tag + " alt")
        if leading:
            add(p.bank, p.desc, hdr_end, "data", f"{tag}_Descriptor")
        else:
            check(p.desc == pal_end, f"{tag}: trailing descriptor not after palettes")
        add(p.bank, p.tiles, tiles_end, "graphics", f"{tag}_Tiles")
        if slot:
            add(p.bank, tiles_end, tiles_end + 16, "padding", f"{tag} zero tile slot")
        for name, addr in maps:
            add(p.bank, addr, addr + p.cells, "data", f"{tag} {name}")
        add(p.bank, p.palettes, pal_end, "data", f"{tag}_Palettes")
        if p.desc == pal_end:
            add(p.bank, p.desc, p.desc + DESC_SIZE, "data", f"{tag}_Descriptor")

    # ScreenMode06's tiles follow ScreenMode03's palettes (shared region in $2C).
    m3, m6 = pk[3], pk[6]
    check(m6.tiles == m3.palettes + 8 * m3.palette_count, "ScreenMode06 tiles do not follow ScreenMode03")

    # Bank $2A fixed screen.
    f = FIXED_2A
    b = 0x2A
    check(f["tiles"] + 16 * f["tile_count"] == f["tilemap"], "fixed 2A: tiles/tilemap boundary")
    check(f["tilemap"] + 360 == f["frames_tilemap"] and f["frames_tilemap"] + 220 == f["attrmap"]
          and f["attrmap"] + 360 == f["frames_attrmap"] and f["frames_attrmap"] + 220 == f["palettes"]
          and f["palettes"] + 64 == f["frame_table"], "fixed 2A: layout")
    validate_palettes(rom, b, f["palettes"], 8, "fixed 2A")
    validate_maps(rom, b, f["tilemap"], f["attrmap"], 360, f["tile_count"], 8, "fixed 2A", True)
    used = validate_maps(rom, b, f["frames_tilemap"], f["frames_attrmap"], 220, f["tile_count"], 8,
                         "fixed 2A frames", True)
    check(used == f["tile_count"] - 1, f"fixed 2A: highest tile {used}")
    for i in range(f["frames"]):
        t, a = word(rom, b, f["frame_table"] + 4 * i), word(rom, b, f["frame_table"] + 4 * i + 2)
        check((t, a) == (f["frames_tilemap"] + 5 * i, f["frames_attrmap"] + 5 * i),
              f"fixed 2A: frame table entry {i}")
    check(read(rom, b, 0x7754, 7) == bytes.fromhex("3e14eadcc63e12"),
          "fixed 2A: draw routine width/height immediates")
    add(b, 0x4000, 0x5D00, "graphics", "FixedScreen2A_Tiles")
    add(b, 0x5D00, 0x5E68, "data", "FixedScreen2A_TileMap")
    add(b, 0x5E68, 0x5F44, "data", "FixedScreen2A_FrameTileMap")
    add(b, 0x5F44, 0x60AC, "data", "FixedScreen2A_AttrMap")
    add(b, 0x60AC, 0x6188, "data", "FixedScreen2A_FrameAttrMap")
    add(b, 0x6188, 0x61C8, "data", "FixedScreen2A_Palettes")
    add(b, 0x61C8, 0x61D8, "data", "FixedScreen2A_FrameTable")
    for start, end, name in FIXED_2A_CODE:
        add(b, start, end, "code", name)

    # Bank $2E pictures addressed through $01:$596D.
    pbank, paddr, pcount = PICTURE_TABLE
    pics = []
    for i in range(pcount):
        e = read(rom, pbank, paddr + 16 * i, 16)
        tl, tm, am, pal = (e[1 + 2 * k] | e[2 + 2 * k] << 8 for k in range(4))
        check(e[0] == 0x2E and e[9] == 0x40 and not any(e[10:]), f"picture table entry {i}")
        pics.append((i, tl, tm, am, pal))
    scr2e = pk[-1]
    check((pics[2][1:]) == (scr2e.tiles, scr2e.tilemap, scr2e.attrmap, scr2e.palettes),
          "picture table entry 2 is not the Screen2E picture")
    for i, tl, tm, am, pal in pics[:2]:
        count = PICTURE_TILE_COUNTS[i]
        check(tm == tl + 16 * count and am == tm + 380 and pal == am + 380,
              f"picture {i}: layout")
        validate_palettes(rom, 0x2E, pal, 8, f"picture {i}")
        used = validate_maps(rom, 0x2E, tm, am, 380, count, 8, f"picture {i}")
        check(used == count - 1, f"picture {i}: highest tile {used}")
        add(0x2E, tl, tm, "graphics", f"Picture596D{i}_Tiles")
        add(0x2E, tm, am, "data", f"Picture596D{i}_TileMap")
        add(0x2E, am, pal, "data", f"Picture596D{i}_AttrMap")
        add(0x2E, pal, pal + 64, "data", f"Picture596D{i}_Palettes")
    check(pics[1][1] == scr2e.palettes + 64 and pics[0][1] == pics[1][4] + 64,
          "bank $2E pictures are not contiguous")

    # Zero fill and bank markers close every bank.
    for bank in BANKS:
        last = max(e for bk, s, e, *_ in ranges if bk == bank)
        check(not any(read(rom, bank, last, 0x7FFF - last)), f"bank ${bank:02X}: fill not zero")
        check(read(rom, bank, 0x7FFF)[0] == bank, f"bank ${bank:02X}: marker")
        add(bank, last, 0x7FFF, "padding", "zero fill")
        add(bank, 0x7FFF, 0x8000, "padding", "bank marker")

    # Exact coverage.
    for bank in BANKS:
        cursor = 0x4000
        for bk, s, e, cls, label in sorted(r for r in ranges if r[0] == bank):
            check(s == cursor, f"bank ${bank:02X}: gap/overlap at {cursor:#x} ({label})")
            cursor = e
        check(cursor == 0x8000, f"bank ${bank:02X}: coverage ends at {cursor:#x}")
    return pk, sorted(ranges)


def negative_tests(rom: bytes) -> int:
    """Corrupt one fact per validator family and require the right rejection."""
    def poke(changes):
        data = bytearray(rom)
        for (bank, addr), value in changes.items():
            data[off(bank, addr)] = value
        return bytes(data)

    cases = {
        "mode table target": ({(0x01, 0x47EC + 2): 0x01}, "ScreenModeTable entry 0"),
        "load template": ({(0x2B, 0x4004): 0x01}, "load routine differs"),
        "fade template": ({(0x2C, 0x4058 + 0x60): 0x00}, "fade draw routine differs"),
        "fade value": ({(0x2B, 0x4058 + 0x4D): 0x00}, "fade value byte"),
        "plain template": ({(0x2B, 0x6EC4 + 0x40): 0x00}, "plain draw routine differs"),
        "descriptor tile count": ({(0x2D, 0x40CC + 8): 0x12}, "tilemap at"),
        "map tile range": ({(0x2D, 0x51EA): 0x7F, (0x2D, 0x5352): 0x08}, "beyond count"),
        "attribute palette": ({(0x2C, 0x49A2): 0x07}, "palette out of range"),
        "palette bit 15": ({(0x2C, 0x4B0B): 0x80}, "bit 15"),
        "zero tile slot": ({(0x2B, 0x581A): 0x01}, "extra tile slot"),
        "fixed 2A frame table": ({(0x2A, 0x61C8): 0x00}, "frame table"),
        "picture table": ({(0x01, 0x596D + 1): 0x00}, "picture"),
        "zero fill": ({(0x2D, 0x7000): 0x01}, "fill not zero"),
        "bank marker": ({(0x2E, 0x7FFF): 0x00}, "marker"),
    }
    for name, (change, expect) in cases.items():
        try:
            parse(poke(change))
        except ScreenDataError as exc:
            check(expect in str(exc), f"negative test {name} rejected for the wrong reason: {exc}")
            continue
        raise ScreenDataError(f"negative test not rejected: {name}")
    return len(cases)
