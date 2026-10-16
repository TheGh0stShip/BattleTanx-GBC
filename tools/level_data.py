#!/usr/bin/env python3
"""Parser and validator for the level data in ROM banks $09-$26.

Every fact here is derived from baserom.gbc and from the routines that read
it (see DATA_BANKS_09_26.md):

  ROM0 $18EE  level load: a = level, reads pointer table $05:$4300
  ROM0 $188B  copies record bytes +2..+19 to $C8B9-$C8CA
  ROM0 $1A33  copies 440 tiles from [$C8C1] in bank [$C8B9] to VRAM
  ROM0 $1A86  loads [$C8C0] BG palettes from [$C8C3] in bank [$C8BA]
  ROM0 $1AA4  copies width*height cell bytes from [$C8C9] in bank [$C8BB]
              to WRAM banks 2-3 at $D000
  ROM0 $1D93  per-cell lookup: tile = [$C8C7 + off], attributes =
              [$C8C5 + off] in bank [$C8BC]; cells with bit 7 set use the
              160-byte table at [$C8D0] in bank [$C8D2]
  $05:$4088   copies $05:$513E entry (dw table, db bank) to $C8D0-$C8D2

All multi-byte values are little-endian 16-bit words. Addresses are bank
CPU addresses ($4000-$7FFF).
"""
from __future__ import annotations


BANK_SIZE = 0x4000
LEVEL_COUNT = 15
FIRST_BANK, LAST_BANK = 0x09, 0x26
RECORD_PTRS = (0x05, 0x4300)       # dw x 15 -> 20-byte records
RECORD_SIZE = 0x14
ATTR_TABLE_PTRS = (0x05, 0x513E)   # 4 bytes x 15: dw table, db bank, db 0
ATTR_TABLE_SIZE = 0xA0
VRAM_TILE_WINDOW = 440             # tiles copied by ROM0 $1A33
PALETTE_SIZE = 8


class LevelDataError(ValueError):
    pass


def bank_bytes(rom: bytes, bank: int) -> bytes:
    return rom[bank * BANK_SIZE:(bank + 1) * BANK_SIZE]


def read(rom: bytes, bank: int, addr: int, size: int = 1) -> bytes:
    if not 0x4000 <= addr <= addr + size <= 0x8000:
        raise LevelDataError(f"read outside ROMX: ${bank:02X}:{addr:04X}+{size:#x}")
    base = bank * BANK_SIZE + addr - 0x4000
    return rom[base:base + size]


def word(rom: bytes, bank: int, addr: int) -> int:
    return int.from_bytes(read(rom, bank, addr, 2), "little")


def tile_number(tile: int, attributes: int) -> int:
    """Position of a tilemap entry in the level tile block.

    ROM0 $1A33 copies the block as: tiles 0-127 to VRAM0 $8800 (ids $80-$FF),
    128-255 to VRAM0 $9000 (ids $00-$7F), 256-383 to VRAM1 $9000 (ids
    $00-$7F) and 384-439 to VRAM1 $8800 (ids $80-$B7). Attribute bit 3
    selects the VRAM bank.
    """
    if attributes & 0x08:
        return 256 + tile if tile < 0x80 else 384 + tile - 0x80
    return tile - 0x80 if tile >= 0x80 else 128 + tile


class Level:
    # tools/ is on sys.path and tools/dis.py shadows the standard dis module,
    # so this file avoids dataclasses (which import inspect -> dis).
    def __init__(self, **fields):
        self.__dict__.update(fields)
        self.ranges = []


    @property
    def cells(self) -> int:
        return self.width * self.height

    @property
    def tile_count(self) -> int:
        return self.tile_count_minus_1 + 1


def parse_level(rom: bytes, n: int) -> Level:
    pbank, ptable = RECORD_PTRS
    addr = word(rom, pbank, ptable + 2 * n)
    rec = read(rom, pbank, addr, RECORD_SIZE)
    abank, atable = ATTR_TABLE_PTRS
    ent = read(rom, abank, atable + 4 * n, 4)
    w = lambda i: rec[i] | rec[i + 1] << 8
    return Level(
        number=n, record_addr=addr, record=rec, width=rec[0], height=rec[1],
        cell_bank=rec[2], map_bank=rec[5], tile_count_minus_1=w(7),
        palette_count=rec[9], tiles_addr=w(10), palettes_addr=w(12),
        attrmap_addr=w(14), tilemap_addr=w(16), cellmap_addr=w(18),
        attr_table_addr=ent[0] | ent[1] << 8, attr_table_bank=ent[2],
        attr_table_unknown=ent[3],
    )


def check(cond: bool, message: str) -> None:
    if not cond:
        raise LevelDataError(message)


def validate_level(rom: bytes, lv: Level) -> None:
    """Check every claimed boundary and value range of one level."""
    n, rec = lv.number, lv.record
    tag = f"level {n}"
    check(lv.record_addr == 0x4400 + RECORD_SIZE * n, f"{tag}: record at {lv.record_addr:#x}")
    check(lv.width and lv.height, f"{tag}: empty map")
    check(rec[2] == rec[3] == rec[4] == FIRST_BANK + 2 * n, f"{tag}: odd-bank bytes {rec[2:5].hex()}")
    check(rec[5] == rec[6] == rec[2] + 1, f"{tag}: even-bank bytes {rec[5:7].hex()}")
    check(1 <= lv.palette_count <= 8, f"{tag}: palette count {lv.palette_count}")
    check(lv.cellmap_addr == 0x4000 and lv.tilemap_addr == 0x4000, f"{tag}: map starts")
    check(lv.tiles_addr == 0x4000 + lv.cells, f"{tag}: tiles do not follow the cell map")
    check(lv.attrmap_addr == 0x4000 + lv.cells, f"{tag}: attributes do not follow the tile map")
    check(lv.tile_count <= VRAM_TILE_WINDOW, f"{tag}: {lv.tile_count} tiles exceed the copy window")
    check(lv.attr_table_bank == lv.cell_bank, f"{tag}: attribute table bank {lv.attr_table_bank}")
    check(lv.attr_table_unknown == 0, f"{tag}: $513E byte 3 is {lv.attr_table_unknown}")
    gap = lv.tiles_addr + 16 * lv.tile_count
    check(lv.attr_table_addr == gap + 1, f"{tag}: attribute table at {lv.attr_table_addr:#x}, tiles end {gap:#x}")
    check(lv.palettes_addr == lv.attr_table_addr + ATTR_TABLE_SIZE, f"{tag}: palettes not after attribute table")
    pal_end = lv.palettes_addr + PALETTE_SIZE * lv.palette_count
    odd, even = lv.cell_bank, lv.map_bank

    # Odd bank layout
    check(read(rom, odd, gap)[0] == 0, f"{tag}: byte before the attribute table is not zero")
    for i in range(lv.palette_count * 4):
        check(not word(rom, odd, lv.palettes_addr + 2 * i) & 0x8000, f"{tag}: palette word {i} bit 15 set")
    check(not any(read(rom, odd, pal_end, 0x7FFF - pal_end)), f"{tag}: odd-bank fill not zero")
    check(read(rom, odd, 0x7FFF)[0] == odd, f"{tag}: odd-bank marker")
    cells = read(rom, odd, lv.cellmap_addr, lv.cells)
    check(not any(c & 0xC0 for c in cells), f"{tag}: cell byte with bit 6/7 set")

    # Even bank layout
    map_end = lv.attrmap_addr + lv.cells
    check(map_end <= 0x7FFF, f"{tag}: maps overflow the bank")
    check(not any(read(rom, even, map_end, 0x7FFF - map_end)), f"{tag}: even-bank fill not zero")
    check(read(rom, even, 0x7FFF)[0] == even, f"{tag}: even-bank marker")
    tiles = read(rom, even, lv.tilemap_addr, lv.cells)
    attrs = read(rom, even, lv.attrmap_addr, lv.cells)
    used = max(tile_number(t, a) for t, a in zip(tiles, attrs))
    check(used == lv.tile_count - 1, f"{tag}: highest tile {used}, tile count {lv.tile_count}")
    check(all(a & 7 < lv.palette_count for a in attrs), f"{tag}: attribute palette out of range")
    check(not any(a & 0x10 for a in attrs), f"{tag}: attribute bit 4 set")

    lv.ranges = [
        (odd, 0x4000, lv.tiles_addr, "cellmap"),
        (odd, lv.tiles_addr, gap, "tiles"),
        (odd, gap, gap + 1, "zero byte, not read"),
        (odd, lv.attr_table_addr, lv.palettes_addr, "attribute lookup table"),
        (odd, lv.palettes_addr, pal_end, "bg palettes"),
        (odd, pal_end, 0x7FFF, "zero fill"),
        (odd, 0x7FFF, 0x8000, "bank marker"),
        (even, 0x4000, lv.attrmap_addr, "tilemap"),
        (even, lv.attrmap_addr, map_end, "attribute map"),
        (even, map_end, 0x7FFF, "zero fill"),
        (even, 0x7FFF, 0x8000, "bank marker"),
    ]


def parse_levels(rom: bytes) -> list[Level]:
    levels = [parse_level(rom, n) for n in range(LEVEL_COUNT)]
    for lv in levels:
        validate_level(rom, lv)
    # Coverage: every byte of banks $09-$26 in exactly one range.
    covered = {}
    for lv in levels:
        for bank, start, end, _ in lv.ranges:
            covered.setdefault(bank, []).append((start, end))
    check(sorted(covered) == list(range(FIRST_BANK, LAST_BANK + 1)), "banks $09-$26 not all covered")
    for bank, spans in covered.items():
        cursor = 0x4000
        for start, end in sorted(spans):
            check(start == cursor and end > start, f"bank ${bank:02X}: gap/overlap at {cursor:#x}")
            cursor = end
        check(cursor == 0x8000, f"bank ${bank:02X}: coverage ends at {cursor:#x}")
    return levels


def range_map(levels: list[Level]) -> list[tuple[int, int, int, str, int]]:
    out = []
    for lv in levels:
        for bank, start, end, kind in lv.ranges:
            out.append((bank, start, end, kind, lv.number))
    return sorted(out)


def negative_tests(rom: bytes) -> int:
    """Corrupt one fact per format family and require rejection."""
    def poke(mutations):
        data = bytearray(rom)
        for (bank, addr), value in mutations.items():
            data[bank * BANK_SIZE + addr - 0x4000] = value
        return bytes(data)

    lv0 = parse_level(rom, 0)
    # name: (mutation, text the rejection message must contain)
    cases = {
        "bank marker": ({(0x09, 0x7FFF): 0x08}, "odd-bank marker"),
        "zero fill": ({(0x0A, 0x7FFE): 0x01}, "even-bank fill"),
        "record bank byte": ({(0x05, 0x4400 + 3): 0x0B}, "odd-bank bytes"),
        "record tile count": ({(0x05, 0x4400 + 7): lv0.record[7] + 1}, "attribute table at"),
        "attribute table pointer": ({(0x05, 0x513E): lv0.attr_table_addr & 0xFF ^ 0x10}, "attribute table at"),
        "palette word": ({(0x09, lv0.palettes_addr + 1): 0x80}, "bit 15"),
        "attribute palette": ({(0x0A, lv0.attrmap_addr): 0x07}, "palette out of range"),
        "tile beyond count": ({(0x0A, 0x4000): 0xB7, (0x0A, lv0.attrmap_addr): 0x08}, "highest tile"),
        "cell flag bits": ({(0x09, 0x4000): 0x80}, "bit 6/7"),
        "gap byte": ({(0x09, lv0.attr_table_addr - 1): 0x01}, "byte before"),
    }
    for name, (mutation, expect) in cases.items():
        try:
            parse_levels(poke(mutation))
        except LevelDataError as exc:
            if expect not in str(exc):
                raise LevelDataError(f"negative test {name} rejected for the wrong reason: {exc}")
            continue
        raise LevelDataError(f"negative test not rejected: {name}")
    return len(cases)
