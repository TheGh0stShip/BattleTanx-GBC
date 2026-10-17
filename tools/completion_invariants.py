#!/usr/bin/env python3
"""Completion invariants for facts established by the remaining-work study.

Each rule is derived from baserom.gbc, battletanx.sym and the checked-in
source, and each has a negative test that corrupts one input in memory and
must be rejected for the rule's own reason.  Nothing on disk is modified.

Rules:
  1 screen-effect reachable steps and the unreachable-only part records
  2 bank $08 duplicate palette-shaped records
  3 bank $08 counted tile copies avoid the unexplained bytes
  4 scene grid columns, unread column-3 slots, zero +$38 palette windows
  5 LevelTileAnimationSet2 overrun lands on Set4
  6 level record fields +6, +7/+8 and tile-block end
  7 scene RAM images contain no di/ei/halt/reti; HDMA flag set after staging
  8 pinned Func_3960 call sites
"""
from __future__ import annotations

import copy
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent


class InvariantError(ValueError):
    pass


def check(cond, msg):
    if not cond:
        raise InvariantError(msg)


def off(bank, addr):
    return addr if bank == 0 else bank * 0x4000 + addr - 0x4000


def rd(rom, bank, addr, n=1):
    return bytes(rom[off(bank, addr):off(bank, addr) + n])


def byte(rom, bank, addr):
    return rom[off(bank, addr)]


def word(rom, bank, addr):
    return rom[off(bank, addr)] | rom[off(bank, addr) + 1] << 8


def read_sym(path):
    sym = {}
    for line in path.read_text().splitlines():
        m = re.match(r"([0-9A-Fa-f]{2}):([0-9A-Fa-f]{4}) (\S+)", line)
        if m:
            sym[m.group(3)] = (int(m.group(1), 16), int(m.group(2), 16))
    return sym


class Ctx:
    """All inputs; negative tests deep-copy and corrupt one field."""

    def __init__(self, root):
        self.rom = bytearray((root / "baserom.gbc").read_bytes())
        self.sym = read_sym(root / "battletanx.sym")
        self.src = {p.name: p.read_text() for p in sorted((root / "src").glob("*.asm"))}
        self.memory_inc = (root / "include" / "memory.inc").read_text()

    def label(self, name):
        check(name in self.sym, f"symbol {name} missing from battletanx.sym")
        return self.sym[name]


# ------------------------------------------------------------------ SM83 lengths
# Opcode lengths in bytes; CB-prefixed opcodes are 2 bytes.  None = undefined opcode.
SM83_INVALID = {0xD3, 0xDB, 0xDD, 0xE3, 0xE4, 0xEB, 0xEC, 0xED, 0xF4, 0xFC, 0xFD}
SM83_LEN2 = {0x06, 0x0E, 0x16, 0x1E, 0x26, 0x2E, 0x36, 0x3E, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38,
             0xC6, 0xCE, 0xD6, 0xDE, 0xE6, 0xEE, 0xF6, 0xFE, 0xE0, 0xF0, 0xE8, 0xF8, 0xCB}
SM83_LEN3 = {0x01, 0x11, 0x21, 0x31, 0x08, 0xC2, 0xC3, 0xC4, 0xCA, 0xCC, 0xCD, 0xD2, 0xD4, 0xDA,
             0xDC, 0xEA, 0xFA}
IME_OPCODES = {0xF3: "di", 0xFB: "ei", 0x76: "halt", 0xD9: "reti"}


def sm83_len(op):
    if op in SM83_INVALID:
        return None
    if op in SM83_LEN3:
        return 3
    if op in SM83_LEN2:
        return 2
    return 1


def decode_stream(buf):
    """Linear decode of straight code; returns [(offset, opcode)]."""
    out, i = [], 0
    while i < len(buf):
        n = sm83_len(buf[i])
        check(n is not None, f"undefined opcode {buf[i]:02X} at image offset {i:#x}")
        check(i + n <= len(buf), f"instruction at image offset {i:#x} crosses the image end")
        out.append((i, buf[i]))
        i += n
    return out


def global_blocks(text):
    """Map each global label to the list of (line number, line) of its body."""
    blocks, cur = {}, None
    for no, line in enumerate(text.splitlines(), 1):
        m = re.match(r"([A-Za-z_][A-Za-z0-9_]*):", line)
        if m:
            cur = m.group(1)
            blocks.setdefault(cur, [])
            continue
        if cur:
            blocks[cur].append((no, line))
    return blocks


# ------------------------------------------------------------------ rule 1
EFFECT_STEP_COUNT = 72
EFFECT_REACHABLE = 19
EFFECT_UNREACHABLE_ONLY_RECORDS = 36
EFFECT_UNREACHABLE_ONLY_BLOCKS = {0x5918: 112, 0x5990: 96, 0x59F8: 96, 0x5BF8: 64, 0x5C40: 96, 0x5CA8: 96,
                                  0x5D10: 48, 0x5D48: 64, 0x5D90: 48, 0x5FD0: 96, 0x6038: 64, 0x6080: 112}


def effect_duration(ctx):
    m = re.search(r"^DEF SCREEN_EFFECT_DURATION\s+EQU\s+(\$[0-9A-Fa-f]+|\d+)", ctx.memory_inc, re.M)
    check(m, "rule 1: SCREEN_EFFECT_DURATION not found in include/memory.inc")
    v = m.group(1)
    return int(v[1:], 16) if v.startswith("$") else int(v)


def check_effect_advance_rule(ctx):
    body = [l.split(";")[0].strip() for _, l in global_blocks(ctx.src["bank_00.asm"])["UpdateScreenEffect"]]
    want = ["ld a, [wScreenEffectCountdown]", "dec a", "ld [wScreenEffectCountdown], a", "or a",
            "jr z, .expire", "and $03", "jr nz, .return"]
    check(body[:len(want)] == want, "rule 1: UpdateScreenEffect no longer advances only when (countdown & 3) == 0")
    check("add a, $06" in body, "rule 1: UpdateScreenEffect step stride is not 6")


def check_screen_effect(ctx):
    check_effect_advance_rule(ctx)
    dur = effect_duration(ctx)
    # countdown starts at dur; each frame dec; 0 expires; advance on nonzero multiples of 4
    reachable = 1 + sum(1 for v in range(dur - 1, 0, -1) if v % 4 == 0)
    check(reachable == (dur - 1) // 4 + 1, "rule 1: simulation disagrees with closed form")
    check(reachable <= EFFECT_STEP_COUNT, f"rule 1: {reachable} reachable steps exceed the {EFFECT_STEP_COUNT}-step table")
    check(reachable == EFFECT_REACHABLE, f"rule 1: {reachable} reachable steps, pinned {EFFECT_REACHABLE} (DURATION {dur})")
    bank, base = ctx.label("ScreenEffectSteps")
    end = ctx.label("ScreenEffectStepsEnd")[1]
    check(end - base == 6 * EFFECT_STEP_COUNT, "rule 1: ScreenEffectSteps is not 72 six-byte steps")

    def recs(steps):
        s = set()
        for st in steps:
            for k in range(3):
                p = word(ctx.rom, bank, base + 6 * st + 2 * k)
                if p:
                    s.add(p)
        return s
    live = recs(range(reachable))
    dead = recs(range(reachable, EFFECT_STEP_COUNT)) - live
    check(len(dead) == EFFECT_UNREACHABLE_ONLY_RECORDS,
          f"rule 1: {len(dead)} part records used only by unreachable steps, pinned {EFFECT_UNREACHABLE_ONLY_RECORDS}")
    live_src = {word(ctx.rom, bank, p + 1) for p in live}
    blocks = {}
    for p in dead:
        cnt, src = byte(ctx.rom, bank, p), word(ctx.rom, bank, p + 1)
        if src not in live_src:
            blocks[src] = max(blocks.get(src, 0), 16 * cnt)
    check(blocks == EFFECT_UNREACHABLE_ONLY_BLOCKS,
          f"rule 1: unreachable-only tile blocks {sorted((hex(k), v) for k, v in blocks.items())} differ from the pinned set")
    return reachable, len(dead), len(blocks), sum(blocks.values())


# ------------------------------------------------------------------ rule 2
def check_bank08_duplicates(ctx):
    pairs = [("PaletteRecord6263", 0x6263, "Bank08HudIconPalette", 0x674B),
             ("PaletteRecord610A", 0x610A, "PaletteRecord621A", 0x621A)]
    for a, aa, b, ba in pairs:
        check(ctx.label(a) == (8, aa) and ctx.label(b) == (8, ba), f"rule 2: {a}/{b} not at $08:{aa:04X}/$08:{ba:04X}")
        check(rd(ctx.rom, 8, aa, 8) == rd(ctx.rom, 8, ba, 8), f"rule 2: {a} ($08:{aa:04X}) no longer equals {b} ($08:{ba:04X})")
    return len(pairs)


# ------------------------------------------------------------------ rule 3
BANK08_UNEXPLAINED = [(0x6108, 0x6109), (0x624A, 0x6262)]


def bank08_tile_copies(ctx):
    copies = []
    lines = ctx.src["bank_00.asm"].splitlines()
    for i, line in enumerate(lines):
        if not re.match(r"\s*call (CopyTilesToVRAM|Func_0622)\b", line):
            continue
        d = bc = None
        for back in lines[max(0, i - 6):i][::-1]:
            back = back.split(";")[0].strip()
            if back.startswith("call") or back.endswith(":") or back == "ret":
                break
            m = re.fullmatch(r"ld d, \$([0-9A-Fa-f]{2})", back)
            if m and d is None:
                d = int(m.group(1), 16)
            m = re.fullmatch(r"ld bc, ([A-Za-z_][A-Za-z0-9_]*)(?: \+ \$([0-9A-Fa-f]+))?", back)
            if m and bc is None:
                bc = (m.group(1), int(m.group(2) or "0", 16))
        if d is None or bc is None or bc[0] not in ctx.sym:
            continue          # register-computed source (level tiles): not a bank-$08 literal
        bank, addr = ctx.sym[bc[0]]
        if bank != 8:
            continue
        copies.append((i + 1, bc[0], addr + bc[1], d or 256))
    return copies


def check_bank08_tile_copies(ctx):
    copies = bank08_tile_copies(ctx)
    check(len(copies) >= 12, f"rule 3: only {len(copies)} bank-$08 tile copies parsed")
    for line, name, src, n in copies:
        lo, hi = src, src + 16 * n - 1
        for a, b in BANK08_UNEXPLAINED:
            check(hi < a or lo > b,
                  f"rule 3: src/bank_00.asm:{line} copies {name} ${lo:04X}-${hi:04X} into unexplained ${a:04X}-${b:04X}")
    return len(copies)


# ------------------------------------------------------------------ rule 4
FIXED_PALETTE_WINDOWS = ["FixedScene00Palettes", "FixedScene01Palettes", "FixedScene08Palettes", "FixedScene10Palettes"]


def check_scene_grid(ctx):
    bank, a = ctx.label("LevelSceneGridCells")
    n = ctx.label("LevelRowSceneFlags")[1] - a
    check(n == 30, f"rule 4: LevelSceneGridCells is {n} bytes, expected 15 (row, column) pairs")
    for lv in range(15):
        c = byte(ctx.rom, bank, a + 2 * lv + 1)
        check(c <= 2, f"rule 4: level {lv} grid column {c} > 2")
    return 15


def check_scene_column3(ctx):
    for name in ("SceneScrollVariantIndexTable", "SceneScrollDescriptorIndexTable", "SceneScrollInitialRowTable"):
        bank, a = ctx.label(name)
        for slot in (3, 7, 11, 15):
            v = byte(ctx.rom, bank, a + slot)
            check(v == 0, f"rule 4: {name} column-3 slot {slot} is ${v:02X}, not $00")
    check(ctx.label("SceneScrollDescriptorIndexTable")[1] - ctx.label("SceneScrollVariantIndexTable")[1] == 19
          and ctx.label("SceneScrollInitialRowTable")[1] - ctx.label("SceneScrollDescriptorIndexTable")[1] == 19,
          "rule 4: scroll tables are not 19 bytes apart")
    return 12


def check_fixed_palette_windows(ctx):
    for name in FIXED_PALETTE_WINDOWS:
        bank, a = ctx.label(name)
        w = rd(ctx.rom, bank, a + 0x38, 8)
        check(w == bytes(8), f"rule 4: {name}+$38 window ${bank:02X}:{a + 0x38:04X} is {w.hex()}, not zero")
    return len(FIXED_PALETTE_WINDOWS)


# ------------------------------------------------------------------ level helpers
def level_record(ctx, lv):
    bank, ptrs = ctx.label("LevelRecordPointers")
    return rd(ctx.rom, bank, word(ctx.rom, bank, ptrs + 2 * lv), 20)


def le(r, i):
    return r[i] | r[i + 1] << 8


# ------------------------------------------------------------------ rule 5
SET_RECORDS = 5
SET2_RECORDS = 95
SET2_OVERRUN = {3: [172, 174, 186, 187, 195], 4: [213, 214, 218, 219]}


def set2_overrun(ctx):
    _, set2 = ctx.label("LevelTileAnimationSet2")
    _, anims = ctx.label("LevelTileAnimationPointers")
    out = {}
    for lv in range(15):
        if word(ctx.rom, 5, anims + 2 * lv) != set2:
            continue
        r = level_record(ctx, lv)
        w, h, cb, mb = r[0], r[1], r[4], r[5]
        attr, tmap, cmap = le(r, 14), le(r, 16), le(r, 18)
        idx = set()
        for i in range(w * h):
            if byte(ctx.rom, cb, cmap + i) & 0x0C == 0 or byte(ctx.rom, mb, attr + i) & 0x08:
                continue      # not convertible to the mapped state, or VRAM bank 1 (tables skipped)
            k = (byte(ctx.rom, mb, tmap + i) + 0x7F) & 0xFF
            if k >= SET2_RECORDS:
                idx.add(k)
        if idx:
            out[lv] = sorted(idx)
    return out


def check_set2_layout(ctx):
    s2, s3, s4 = (ctx.label(f"LevelTileAnimationSet{k}")[1] for k in (2, 3, 4))
    check((s3 - s2) == SET_RECORDS * SET2_RECORDS, f"rule 5: Set2 is {(s3 - s2) / 5} records, expected {SET2_RECORDS}")
    check(s4 - s2 == SET_RECORDS * 164, f"rule 5: LevelTileAnimationSet4 - Set2 = {s4 - s2}, expected 5*164 = 820")


def check_set2_overrun(ctx):
    check_set2_layout(ctx)
    got = set2_overrun(ctx)
    check(got == SET2_OVERRUN, f"rule 5: Set2 overrun indices {got} differ from pinned {SET2_OVERRUN}")
    s4 = ctx.label("LevelTileAnimationSet4")[1]
    s4_end = s4 + SET_RECORDS * 96
    landed = sorted({k - 164 for v in got.values() for k in v})
    for k in landed:
        check(s4 + 5 * k + 5 <= s4_end, f"rule 5: overrun record {k + 164} lands past Set4")
    return landed


# ------------------------------------------------------------------ rule 6
def block_tile(t, a):
    if a & 0x08:
        return 256 + t if t < 0x80 else 384 + t - 0x80
    return 128 + t if t < 0x80 else t - 0x80


def check_level_field6(ctx):
    for lv in range(15):
        r = level_record(ctx, lv)
        check(r[6] == r[5], f"rule 6: level {lv} record +6 ${r[6]:02X} != +5 ${r[5]:02X}")
    return 15


def check_level_last_tile(ctx):
    for lv in range(15):
        r = level_record(ctx, lv)
        w, h, mb = r[0], r[1], r[5]
        attr, tmap = le(r, 14), le(r, 16)
        top = max(block_tile(byte(ctx.rom, mb, tmap + i), byte(ctx.rom, mb, attr + i)) for i in range(w * h))
        check(le(r, 7) == top, f"rule 6: level {lv} record +7/+8 {le(r, 7)} != highest used block tile {top}")
    return 15


def check_level_tile_end(ctx):
    _, lut = ctx.label("LevelAttributeLookupPointers")
    for lv in range(15):
        r = level_record(ctx, lv)
        end = le(r, 10) + 16 * (le(r, 7) + 1)
        lk, lb = word(ctx.rom, 5, lut + 4 * lv), byte(ctx.rom, 5, lut + 4 * lv + 2)
        check(lb == r[2] and end == lk - 1,
              f"rule 6: level {lv} tiles end ${r[2]:02X}:{end:04X}, lookup ${lb:02X}:{lk:04X} (want lookup - 1)")
        check(byte(ctx.rom, lb, lk - 1) == 0, f"rule 6: level {lv} byte before the lookup table is not $00")
    return 15


# ------------------------------------------------------------------ rule 7
SCENE_IMAGES = {0xD1F0: "Bank01RomImage_6432", 0xD230: "Bank01RomImage_6468",
                0xD370: "Bank01RomImage_6505", 0xD3B0: "Bank01RomImage_6538"}


def scene_image_copies(ctx):
    """(label, length) for each image, parsed from ld hl/ld de/ld bc/call CopyBytes in the source."""
    found = {}
    for text in ctx.src.values():
        for m in re.finditer(r"ld hl, (Bank01RomImage_[0-9A-F]{4})\s*\n\s*ld de, \$([0-9A-Fa-f]{4})\s*\n"
                             r"\s*ld bc, \$([0-9A-Fa-f]{4})\s*\n\s*call CopyBytes", text):
            found[int(m.group(3), 16)] = (m.group(1), int(m.group(2), 16))
    return found


def check_scene_images(ctx):
    copies = scene_image_copies(ctx)
    total = 0
    for dest, name in sorted(SCENE_IMAGES.items()):
        check(dest in copies and copies[dest][0] == name, f"rule 7: no CopyBytes of {name} to ${dest:04X}")
        bank, addr = ctx.label(name)
        n = copies[dest][1]
        for o, op in decode_stream(rd(ctx.rom, bank, addr, n)):
            if op in IME_OPCODES:
                raise InvariantError(f"rule 7: {IME_OPCODES[op]} at RAM ${dest + o:04X} (ROM ${bank:02X}:{addr + o:04X}) in image {name}")
        total += n
    return total


def check_hdma_flag_order(ctx):
    body = [(n, l.split(";")[0].strip()) for n, l in global_blocks(ctx.src["bank_01.asm"])["DrawNextSceneRow"]]
    calls = [n for n, l in body if l == "call StageSceneRowTiles"]
    stores = [n for n, l in body if l == "ldh [hSceneRowHdmaPending], a"]
    check(calls and stores, "rule 7: DrawNextSceneRow lacks the staging call or the hSceneRowHdmaPending store")
    check(min(stores) > min(calls),
          f"rule 7: src/bank_01.asm:{min(stores)} sets hSceneRowHdmaPending before call StageSceneRowTiles")
    return 1


# ------------------------------------------------------------------ rule 8
def func_3960_sites(ctx):
    sites = {}
    for fname, text in ctx.src.items():
        cur = None
        for line in text.splitlines():
            m = re.match(r"([A-Za-z_][A-Za-z0-9_]*):", line)
            if m and "legacy alias" not in line:
                cur = m.group(1)
            m = re.match(r"\s*(?:call|jp)\s+(?:(?:nz|z|nc|c),\s*)?(Func_3960|ClearBackgroundPalettes|\$3960)\b", line)
            if m:
                k = (fname, cur, m.group(1))
                sites[k] = sites.get(k, 0) + 1
    return sorted((f, g, t, n) for (f, g, t), n in sites.items())


def check_func_3960_sites(ctx):
    got = func_3960_sites(ctx)
    check(got == FUNC_3960_PINNED, f"rule 8: Func_3960 call sites {got} differ from the pinned list")
    return sum(n for *_, n in got)


# ------------------------------------------------------------------ negative tests
def expect_fail(name, fn, ctx, needle):
    try:
        fn(ctx)
    except InvariantError as exc:
        needles = needle if isinstance(needle, tuple) else (needle,)
        check(all(x in str(exc) for x in needles), f"negative test {name}: rejected for the wrong reason: {exc}")
        return f"  {name}: rejected: {exc}"
    raise InvariantError(f"negative test not rejected: {name}")


def mut(ctx, **kw):
    c = copy.deepcopy(ctx)
    for k, v in kw.items():
        setattr(c, k, v)
    return c


def first_boundary_opcode(ctx, name, n, op):
    bank, addr = ctx.label(name)
    for o, x in decode_stream(rd(ctx.rom, bank, addr, n)):
        if x == op:
            return off(bank, addr + o)
    raise InvariantError(f"negative setup: no ${op:02X} in {name}")


def negative_tests(ctx):
    out = []

    # 1: DURATION 79
    m = re.sub(r"(DEF SCREEN_EFFECT_DURATION\s+EQU\s+)\d+", r"\g<1>79", ctx.memory_inc)
    out.append(expect_fail("screen effect DURATION 79", check_screen_effect, mut(ctx, memory_inc=m), "reachable steps, pinned 19"))

    # 2: flip a byte of each duplicate
    for a, label in ((0x6263, "PaletteRecord6263"), (0x610A, "PaletteRecord610A")):
        c = mut(ctx)
        c.rom[off(8, a + 3)] ^= 0x01
        out.append(expect_fail(f"flip byte in {label}", check_bank08_duplicates, c, f"{label} ($08:{a:04X}) no longer equals"))

    # 3: tile count of the $60F8 copy 1 -> 2 runs into $6108
    s = ctx.src["bank_00.asm"].replace("\tld d, $01\n\tld a, $80\n\tld bc, Bank08InterfaceTiles60F8",
                                       "\tld d, $02\n\tld a, $80\n\tld bc, Bank08InterfaceTiles60F8", 1)
    check(s != ctx.src["bank_00.asm"], "negative setup: $60F8 copy not found")
    out.append(expect_fail("tile count of Bank08InterfaceTiles60F8 copy 1 -> 2", check_bank08_tile_copies,
                           mut(ctx, src={**ctx.src, "bank_00.asm": s}), "into unexplained $6108-$6109"))

    # 4: grid column 3, column-3 slot nonzero, F08 window nonzero
    c = mut(ctx)
    b, a = ctx.label("LevelSceneGridCells")
    c.rom[off(b, a + 1)] = 3
    out.append(expect_fail("LevelSceneGridCells+1 = $03", check_scene_grid, c, "level 0 grid column 3 > 2"))
    c = mut(ctx)
    b, a = ctx.label("SceneScrollDescriptorIndexTable")
    c.rom[off(b, a + 7)] = 0x01
    out.append(expect_fail("SceneScrollDescriptorIndexTable slot 7 = $01", check_scene_column3, c, "column-3 slot 7"))
    c = mut(ctx)
    b, a = ctx.label("FixedScene08Palettes")
    c.rom[off(b, a + 0x38)] = 0x01
    out.append(expect_fail("FixedScene08Palettes+$38 = $01", check_fixed_palette_windows, c, "FixedScene08Palettes+$38"))

    # 5: move Set4 by one record; add an overrun cell to level 3
    sym = dict(ctx.sym)
    b, a = sym["LevelTileAnimationSet4"]
    sym["LevelTileAnimationSet4"] = (b, a + 5)
    out.append(expect_fail("LevelTileAnimationSet4 moved by one record", check_set2_overrun, mut(ctx, sym=sym), "expected 5*164"))
    c = mut(ctx)
    r = level_record(ctx, 3)
    w, h, cb, mb, attr, tmap, cmap = r[0], r[1], r[4], r[5], le(r, 14), le(r, 16), le(r, 18)
    for i in range(w * h):
        if byte(ctx.rom, cb, cmap + i) & 0x0C and not byte(ctx.rom, mb, attr + i) & 0x08 \
                and (byte(ctx.rom, mb, tmap + i) + 0x7F) & 0xFF < SET2_RECORDS:
            c.rom[off(mb, tmap + i)] = 0x30          # index $AF = 175, new overrun record
            break
    out.append(expect_fail("level 3 convertible cell tile -> $30", check_set2_overrun, c, "overrun indices"))

    # 6: +6, +7, lookup pointer
    bank, ptrs = ctx.label("LevelRecordPointers")
    rec0 = word(ctx.rom, bank, ptrs)
    c = mut(ctx)
    c.rom[off(5, rec0 + 6)] ^= 0x01
    out.append(expect_fail("level 0 record +6 changed", check_level_field6, c, "level 0 record +6"))
    c = mut(ctx)
    c.rom[off(5, rec0 + 7)] ^= 0x01
    out.append(expect_fail("level 0 record +7 changed", check_level_last_tile, c, "level 0 record +7/+8"))
    c = mut(ctx)
    c.rom[off(5, ctx.label("LevelAttributeLookupPointers")[1])] += 1
    out.append(expect_fail("level 0 lookup pointer +1", check_level_tile_end, c, "level 0 tiles end"))

    # 7: di in an image; store moved before the call
    for dest, name in ((0xD1F0, "Bank01RomImage_6432"), (0xD3B0, "Bank01RomImage_6538")):
        n = scene_image_copies(ctx)[dest][1]
        c = mut(ctx)
        op = 0x7F if dest == 0xD1F0 else 0xF5      # ld a, a / push af: one-byte instructions
        c.rom[first_boundary_opcode(ctx, name, n, op)] = 0xF3
        out.append(expect_fail(f"di written into {name}", check_scene_images, c, ("rule 7: di at RAM", f"in image {name}")))
    s = ctx.src["bank_01.asm"]
    old = "\tcall StageSceneRowTiles\n\tcall WriteSceneRowTileIndices\n\tld a, $01\n\tldh [hSceneRowHdmaPending], a\n"
    new = "\tld a, $01\n\tldh [hSceneRowHdmaPending], a\n\tcall StageSceneRowTiles\n\tcall WriteSceneRowTileIndices\n"
    check(old in s, "negative setup: DrawNextSceneRow sequence not found")
    out.append(expect_fail("hSceneRowHdmaPending store moved before the call", check_hdma_flag_order,
                           mut(ctx, src={**ctx.src, "bank_01.asm": s.replace(old, new, 1)}), "before call StageSceneRowTiles"))

    # 8: a new call site
    s = ctx.src["bank_01.asm"].replace("DrawNextSceneRow:\n", "DrawNextSceneRow:\n\tcall Func_3960\n", 1)
    out.append(expect_fail("new call Func_3960 in DrawNextSceneRow", check_func_3960_sites,
                           mut(ctx, src={**ctx.src, "bank_01.asm": s}), "differ from the pinned list"))
    return out


def run(root):
    ctx = Ctx(root)
    lines = []
    reach, recs, blocks, nbytes = check_screen_effect(ctx)
    lines.append(f"rule 1: {reach} reachable screen-effect steps of 72; {recs} part records used only by steps "
                 f"{reach}-71, {blocks} tile blocks, {nbytes} bytes")
    lines.append(f"rule 2: {check_bank08_duplicates(ctx)} duplicate palette-shaped record pairs in bank $08")
    copies = bank08_tile_copies(ctx)
    check_bank08_tile_copies(ctx)
    lines.append(f"rule 3: {len(copies)} bank-$08 counted tile copies avoid $6108-$6109 and $624A-$6262")
    for line, name, src, n in copies:
        lines.append(f"    src/bank_00.asm:{line} {name} ${src:04X}-${src + 16 * n - 1:04X} ({n} tiles)")
    lines.append(f"rule 4: {check_scene_grid(ctx)} grid columns <= 2; {check_scene_column3(ctx)} column-3 slots zero; "
                 f"{check_fixed_palette_windows(ctx)} fixed-scene +$38 windows zero")
    landed = check_set2_overrun(ctx)
    lines.append(f"rule 5: Set4 - Set2 = 5*164; overrun indices {SET2_OVERRUN} land on Set4 records {landed}")
    lines.append(f"rule 6: +6 == +5 ({check_level_field6(ctx)} levels); +7/+8 == highest block tile "
                 f"({check_level_last_tile(ctx)}); tiles end at the zero byte before the lookup ({check_level_tile_end(ctx)})")
    lines.append(f"rule 7: {check_scene_images(ctx)} image bytes decoded with no di/ei/halt/reti; "
                 f"hSceneRowHdmaPending set after StageSceneRowTiles")
    lines.append(f"rule 8: {check_func_3960_sites(ctx)} Func_3960 call sites match the pinned list")
    neg = negative_tests(ctx)
    lines.append(f"{len(neg)} negative tests rejected:")
    lines.extend(neg)
    return lines


# (file, enclosing non-alias global label, target name, count); w03 lists these 10 sites.
FUNC_3960_PINNED = [
    ("bank_00.asm", "RunLevelIntroSceneFlow", "ClearBackgroundPalettes", 1),
    ("bank_01.asm", "ClearSceneSplitPalettes", "Func_3960", 1),
    ("bank_01.asm", "InitSceneDisplay", "Func_3960", 1),
    ("bank_01.asm", "Jump_01_5493", "Func_3960", 1),
    ("bank_01.asm", "LoadFixedSceneForRow", "Func_3960", 1),
    ("bank_01.asm", "MenuState05SelectNext", "Func_3960", 1),
    ("bank_01.asm", "MenuState05SelectPrevious", "Func_3960", 1),
    ("bank_01.asm", "ShowEarnedPasswordScreen", "Func_3960", 1),
    ("bank_01.asm", "ShowScreenMode12WithPasswordScoreLives", "Func_3960", 1),
    ("bank_2A.asm", "FixedScreen2A_LoadTiles", "Func_3960", 1),
]


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    root = pathlib.Path(args[0]).resolve() if args else ROOT
    if "--list-func3960" in sys.argv:
        for s in func_3960_sites(Ctx(root)):
            print(s)
        return
    print("\n".join(run(root)))


if __name__ == "__main__":
    main()
