#!/usr/bin/env python3
"""Semantic invariants for three verified data facts.

Rules:
  1 TrackerDirectionLookup ($02, 2048 bytes) equals its generating formula,
    both in the ROM at the symbol address and in the INCBIN asset file
  2 every queued sound id lies inside the patch, sfx or music table; the
    class boundaries are derived from Audio_PlaySound/Audio_QueueSound and
    every non-immediate call site is reviewed individually
  3 bank $08 duplicate palette-shaped records, their source comments, and
    the "(unread)" claim (no reference to the label anywhere in src/include)

Informational (never a failure): patches referenced only by sfx sequences
that no code or music event queues, so they can never sound.

Inputs: ROOT/baserom.gbc, ROOT/battletanx.sym, ROOT/src, ROOT/assets.
Data is located by symbol.  Each rule has negative tests that corrupt one
input in memory and must be rejected for the rule's own reason.  Nothing on
disk is modified.  Output is deterministic.

usage: semantic_invariants.py [ROOT]
"""
from __future__ import annotations

import copy
import math
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


def read_sym(text):
    sym = {}
    for line in text.splitlines():
        m = re.match(r"([0-9A-Fa-f]{2}):([0-9A-Fa-f]{4}) (\S+)", line)
        if m:
            sym[m.group(3)] = (int(m.group(1), 16), int(m.group(2), 16))
    return sym


class Ctx:
    """All inputs; negative tests deep-copy and corrupt one field."""

    def __init__(self, root):
        self.rom = bytearray((root / "baserom.gbc").read_bytes())
        self.sym = read_sym((root / "battletanx.sym").read_text())
        self.src = {p.name: p.read_text() for p in sorted((root / "src").glob("*.asm"))}
        self.inc = {p.name: p.read_text() for p in sorted((root / "include").glob("*.inc"))}
        self.root = root
        self.assets = {}

    def label(self, name):
        check(name in self.sym, f"symbol {name} missing from battletanx.sym")
        return self.sym[name]

    def asset(self, rel):
        if rel not in self.assets:
            p = self.root / rel
            check(p.is_file(), f"asset {rel} missing")
            self.assets[rel] = p.read_bytes()
        return self.assets[rel]

    def rd(self, name, n, delta=0):
        bank, addr = self.label(name)
        o = off(bank, addr) + delta
        return bytes(self.rom[o:o + n])


def mut(ctx, **fields):
    c = copy.copy(ctx)
    c.rom = bytearray(ctx.rom)
    c.sym = dict(ctx.sym)
    c.src = dict(ctx.src)
    c.inc = dict(ctx.inc)
    c.assets = dict(ctx.assets)
    for k, v in fields.items():
        setattr(c, k, v)
    return c


# ------------------------------------------------------------- rule 1 tracker
# Reader TrackerDrawPointerSprites: index = row*32 + col//2, row = |dy|>>5,
# col = |dx|>>5 (0..63); even col -> high nibble.  nibble =
# round(15*atan2(col,row)/(pi/2)); exact diagonal ties (7.5) give 7; (0,0) -> 0.
TRACKER_SIZE = 0x800


def tracker_nibble(row, col):
    if row == col:
        return 0 if row == 0 else 7
    return int(math.floor(15.0 * math.atan2(col, row) / (math.pi / 2) + 0.5))


def tracker_table():
    out = bytearray(TRACKER_SIZE)
    for row in range(64):
        for col in range(0, 64, 2):
            out[row * 32 + col // 2] = tracker_nibble(row, col) << 4 | tracker_nibble(row, col + 1)
    return bytes(out)


def tracker_asset_path(ctx):
    m = re.search(r"^TrackerDirectionLookup:[^\n]*\n(?:\s*;[^\n]*\n|\s*\n)*\s*INCBIN \"([^\"]+)\"\s*$",
                  ctx.src.get("bank_02.asm", ""), re.M)
    check(m, "rule 1: TrackerDirectionLookup INCBIN not found in bank_02.asm")
    return m.group(1)


def compare_tracker(where, data):
    check(len(data) == TRACKER_SIZE, f"rule 1: {where} is {len(data)} bytes, expected {TRACKER_SIZE}")
    exp = tracker_table()
    bad = [i for i in range(TRACKER_SIZE) if exp[i] != data[i]]
    check(not bad, f"rule 1: {where} differs from formula at +${bad[0]:03X}" if bad else "")


def check_tracker(ctx):
    bank, addr = ctx.label("TrackerDirectionLookup")
    check(bank == 0x02, f"rule 1: TrackerDirectionLookup in bank ${bank:02X}, expected $02")
    following = sorted(a for b, a in ctx.sym.values() if b == bank and a > addr)
    check(following and following[0] - addr == TRACKER_SIZE,
          "rule 1: TrackerDirectionLookup label span is not 2048 bytes")
    compare_tracker("ROM TrackerDirectionLookup", ctx.rd("TrackerDirectionLookup", TRACKER_SIZE))
    rel = tracker_asset_path(ctx)
    compare_tracker(f"asset {rel}", ctx.asset(rel))
    return bank, addr, rel


# ------------------------------------------------------------ rule 2 sound ids
# Class boundaries are derived from the audio code (see sound_classes):
# Audio_PlaySound tests `bit 7` (music, index `and $7F`) then `bit 6` (sfx,
# index `and $3F`), else patch; Audio_QueueSound drops id 0 with `ret z`
# (a latent stack defect), so 0 is rejected.
# Reviewed non-immediate sites, keyed by call site: (file, enclosing routine,
# ordinal of the Audio_QueueSound call within that routine (1-based), the
# preceding instruction).  Each key must match exactly one site.
DYNAMIC_SITES = {
    ("bank_00.asm", "RespawnPlayer", 1, "ld e, a"): set(range(0x81, 0x87)),   # RandomByte&7 <6, +$81
    ("bank_00.asm", "QueueVehicleActionSound", 1, "ld e, b"): {0x04, 0x05, 0x1B},
    ("bank_00.asm", "RunLevelIntroSceneFlow", 2, "ld e, a"): set(range(0x81, 0x87)),
    ("bank_00.asm", "StartScreenEffect", 1, "ld e, a"): {0x4F},              # ld a,$4F / ld e,a
    ("bank_01.asm", "QueueRandomGridSounds", 1, "ld e, a"): set(range(0x81, 0x87)),
    # UpdateMenuInputRepeat mask filtered by HandleMenuState03Input
    ("bank_01.asm", "StorePasswordCharWithSound", 2, "pop de"): set(range(0x04, 0x10)),
    # argument < $F0 of a music $FE event; checked against event data below
    ("bank_06.asm", "Music_HandleEvent", 1, "ld e, a"): None,
}
ROUTINE_RE = re.compile(r"^([A-Za-z_]\w*):")
SITE_RE = re.compile(r"^\s*(call|jp|jr)\s+(?:\w+\s*,\s*)?Audio_QueueSound\b")
LDE_RE = re.compile(r"^ld e, \$([0-9A-Fa-f]{1,2})$")


def strip(line):
    return line.split(";", 1)[0].strip()


def num(tok):
    tok = tok.strip()
    if tok.startswith("$"):
        return int(tok[1:], 16)
    if tok.startswith("%"):
        return int(tok[1:], 2)
    return int(tok, 10)


def sound_table_counts(ctx):
    check("audio_data.asm" in ctx.src, "rule 2: src/audio_data.asm missing")
    sec, n = None, {"patch": 0, "sfx": 0, "music": 0}
    for line in ctx.src["audio_data.asm"].split("\n"):
        s = strip(line)
        m = ROUTINE_RE.match(line)
        if m:
            sec = {"SoundPatches": "patch", "SfxSequencePointers": "sfx", "MusicPointers": "music"}.get(m.group(1))
            continue
        if sec == "patch":
            if s.startswith("sound_patch_"):
                n["patch"] += 1
            elif s.startswith("db") and n["patch"] == 0 and "$00:" in line:
                n["patch"] += 1   # leading id-$00 record written as raw db
        elif sec in ("sfx", "music") and s.startswith("dw "):
            n[sec] += 1
    return n


def routine_body(ctx, fn, name):
    check(fn in ctx.src, f"rule 2: src/{fn} missing")
    lines = ctx.src[fn].split("\n")
    start = next((i for i, l in enumerate(lines) if l.startswith(name + ":")), None)
    check(start is not None, f"rule 2: {name} not found in {fn}")
    body = []
    for l in lines[start + 1:]:
        m = ROUTINE_RE.match(l)
        if m and not m.group(1).startswith(("Jump_", "Func_")):
            break
        if strip(l):
            body.append(strip(l))
    return body


def sound_classes(ctx):
    """Derive (sfx_base, music_base) from the dispatch in Audio_PlaySound."""
    q = routine_body(ctx, "bank_00.asm", "Audio_QueueSound")
    check("ld a, e" in q and q.index("ld a, e") + 2 < len(q) and
          q[q.index("ld a, e") + 1:q.index("ld a, e") + 3] == ["and a", "ret z"],
          "rule 2: Audio_QueueSound no longer drops id 0 with `ld a, e / and a / ret z`")
    p = routine_body(ctx, "bank_06.asm", "Audio_PlaySound")
    head = p[:4]
    m1 = re.fullmatch(r"bit ([0-7]), a", head[0]) if len(head) == 4 else None
    m2 = re.fullmatch(r"bit ([0-7]), a", head[2]) if m1 else None
    check(m1 and m2 and re.fullmatch(r"(jr|jp) nz, \.StartMusic", head[1]) and
          re.fullmatch(r"(jr|jp) nz, \.StartSfxSequence", head[3]),
          "rule 2: Audio_PlaySound dispatch is not `bit M,a / nz .StartMusic / bit S,a / nz .StartSfxSequence`")
    bm, bs = int(m1.group(1)), int(m2.group(1))
    check(bm == 7, f"rule 2: Audio_PlaySound music test is bit {bm}; classes must partition $00-$FF from the top bit")
    check(bs < bm, f"rule 2: Audio_PlaySound sfx bit {bs} not below music bit {bm}")
    music_base, sfx_base = 1 << bm, 1 << bs

    def first_and(label, table):
        i = p.index(label + ":") if label + ":" in p else None
        check(i is not None, f"rule 2: Audio_PlaySound {label} missing")
        seg = p[i + 1:]
        t = next((k for k, x in enumerate(seg) if x == f"ld hl, {table}"), None)
        check(t is not None, f"rule 2: Audio_PlaySound {label} does not index {table}")
        ands = [x for x in seg[:t] if x.startswith("and $")]
        check(ands, f"rule 2: Audio_PlaySound {label} has no index mask before {table}")
        return int(ands[-1][5:], 16)
    mm, ms = first_and(".StartMusic", "MusicPointers"), first_and(".StartSfxSequence", "SfxSequencePointers")
    check(mm == music_base - 1, f"rule 2: music index mask ${mm:02X} != ${music_base - 1:02X} implied by bit {bm}")
    check(ms == sfx_base - 1, f"rule 2: sfx index mask ${ms:02X} != ${sfx_base - 1:02X} implied by bit {bs}")
    return sfx_base, music_base


def sound_valid(i, n):
    sb, mb = n["classes"]
    return ((0x01 <= i < n["patch"] and i < sb) or
            (sb <= i < sb + n["sfx"] and n["sfx"] <= mb - sb) or
            (mb <= i < mb + n["music"] and n["music"] <= 0x100 - mb))


def classes_txt(n):
    sb, mb = n["classes"]
    return f"[classes from audio code: patch $01-${sb - 1:02X}, sfx ${sb:02X}-${mb - 1:02X}, music ${mb:02X}-$FF]"


def check_sound_ids(ctx):
    n = sound_table_counts(ctx)
    n["classes"] = sound_classes(ctx)
    for a, b, size, key in (("SoundPatches", "SfxSequencePointers", 8, "patch"),
                            ("SfxSequencePointers", "SfxSequencePointerTablePadding", 2, "sfx"),
                            ("MusicPointers", "MusicPointerTablePadding", 4, "music")):
        (ba, aa), (bb, ab) = ctx.label(a), ctx.label(b)
        check(ba == bb == 0x06, f"rule 2: {a}/{b} not in bank $06")
        check(ab - aa == size * n[key], f"rule 2: {a}..{b} is {ab - aa} bytes, expected {n[key]} x {size}")
    queued, seen, sites = set(), {}, 0
    for fn in sorted(ctx.src):
        lines = ctx.src[fn].split("\n")
        owner, ordinal = None, {}
        for i, line in enumerate(lines):
            m = ROUTINE_RE.match(line)
            if m:
                lab = m.group(1)
                if not (owner and (lab.startswith(("Jump_", "RAM_", "Func_")) or lab.startswith(owner + "_"))):
                    owner = lab
            if not SITE_RE.match(line):
                continue
            sites += 1
            ordinal[owner] = ordinal.get(owner, 0) + 1
            j = i - 1
            while j >= 0 and strip(lines[j]) == "":
                j -= 1
            prev = strip(lines[j])
            where = f"{fn}:{i + 1} ({owner})"
            mm = LDE_RE.match(prev)
            if mm:
                v = int(mm.group(1), 16)
                queued.add(v)
                check(sound_valid(v, n), f"rule 2: {where} queues out-of-range id ${v:02X} {classes_txt(n)}")
                continue
            key = (fn, owner, ordinal[owner], prev)
            check(key in DYNAMIC_SITES,
                  f"rule 2: {where} unreviewed non-immediate id (call #{ordinal[owner]} in routine, after '{prev}')")
            check(key not in seen, f"rule 2: {where} reviewed key {key} matches more than one site")
            seen[key] = where
            ids = DYNAMIC_SITES[key]
            if ids is not None:
                queued |= ids
                for v in sorted(ids):
                    check(sound_valid(v, n), f"rule 2: {where} reviewed set contains out-of-range ${v:02X}")
    for key in sorted(DYNAMIC_SITES):
        check(key in seen, f"rule 2: stale DYNAMIC_SITES entry {key[0]}:{key[1]} call #{key[2]} after '{key[3]}'")
    direct = set(queued)
    seq_patches, seq_of, cur, ended = {}, {}, None, set()
    for i, line in enumerate(ctx.src["audio_data.asm"].split("\n")):
        s = strip(line)
        lm = ROUTINE_RE.match(line)
        if lm and lm.group(1).endswith("_UnreadTrailer"):
            lm = None   # bytes after the parent's end marker; part of the parent sequence
        if lm:
            check(cur is None or cur in ended, f"rule 2: {cur} has no sfx_end before {lm.group(1)}")
            cur = lm.group(1) if lm.group(1).startswith("SfxSequence_") else None
            if cur:
                seq_patches[cur] = set()
        if cur and s == "sfx_end":
            ended.add(cur)
        m = re.match(r"sfx_patch\s+([^,]+),", s)
        if m:
            v = num(m.group(1))
            check(cur is not None and cur not in ended,
                  f"rule 2: audio_data.asm:{i + 1} sfx_patch outside a live SfxSequence body")
            seq_patches[cur].add(v)
            queued.add(v)
            check(0x01 <= v < n["patch"], f"rule 2: audio_data.asm:{i + 1} sfx_patch ${v:02X} outside patch table")
        m = re.match(r"music_loop\s+([^,]+),", s)
        if m and num(m.group(1)) < 0xF0:
            v = num(m.group(1))
            queued.add(v)
            direct.add(v)
            check(sound_valid(v, n), f"rule 2: audio_data.asm:{i + 1} music $FE event queues out-of-range ${v:02X}")
        m = re.match(r"db \$FE, \$([0-9A-Fa-f]{2})\b", s)
        check(not (m and int(m.group(1), 16) < 0xF0),
              f"rule 2: audio_data.asm:{i + 1} raw $FE event with queue argument")
    # sfx id -> sequence label, from SfxSequencePointers order
    sb = n["classes"][0]
    ptr = re.search(r"^SfxSequencePointers:\n((?:[^\n]*\n)*?)^SfxSequencePointerTablePadding:",
                    ctx.src["audio_data.asm"], re.M)
    check(ptr, "rule 2: SfxSequencePointers block not found")
    labels = re.findall(r"^\s*dw (\w+)", ptr.group(1), re.M)
    check(len(labels) == n["sfx"], "rule 2: SfxSequencePointers dw count mismatch")
    for k, lab in enumerate(labels):
        check(lab in seq_patches, f"rule 2: SfxSequencePointers ${sb + k:02X} -> unknown {lab}")
        seq_of[sb + k] = lab
    live = {seq_of[v] for v in direct if v in seq_of}
    sounded = {v for v in direct if v < sb}
    for lab in live:
        sounded |= seq_patches[lab]
    dead_only = sorted({v for lab in seq_patches if lab not in live for v in seq_patches[lab]} - sounded)
    info = [(v, sorted(f"{lab} (sfx " + ",".join(f"${k:02X}" for k in sorted(seq_of) if seq_of[k] == lab) + ")"
                       for lab in seq_patches if v in seq_patches[lab])) for v in dead_only]
    n["unsounded"] = info
    unq = {k: [v for v in range(lo, lo + n[k]) if v not in queued]
           for k, lo in (("patch", 0), ("sfx", sb), ("music", n["classes"][1]))}
    return n, sites, unq


# ----------------------------------------------------- rule 3 bank-$08 palettes
GROUP_A = [0x49C0, 0x4FF8, 0x5100, 0x5208, 0x5310, 0x5418, 0x5450, 0x5488, 0x6242]
GROUP_B = [0x5598, 0x5610, 0x5688, 0x56F0, 0x5758, 0x57E0, 0x5878, 0x59F0, 0x5A58,
           0x5AD0, 0x5B58, 0x5BF0, 0x5D40, 0x5D88, 0x5DC0, 0x5FC8]
GROUP_C = [0x5910, 0x5988, 0x5C38, 0x5CA0, 0x5D08, 0x5E38, 0x5F10, 0x6030, 0x6078, 0x60F0]
GROUP_D = [0x610A, 0x621A]


def words(b):
    return [b[i] | b[i + 1] << 8 for i in range(0, len(b), 2)]


def precord(ctx, name, n=8, delta=0):
    bank, _ = ctx.label(name)
    check(bank == 0x08, f"rule 3: {name} in bank ${bank:02X}, expected $08")
    return ctx.rd(name, n, delta)


def prec_addr(ctx, a):
    name = f"PaletteRecord{a:04X}"
    check(ctx.label(name) == (0x08, a), f"rule 3: {name} not at $08:{a:04X}")
    return name


def check_bank08_palettes(ctx):
    check(ctx.rom[off(8, 0x7FFF)] == 0x08, "rule 3: bank $08 number byte at $7FFF wrong")
    ref_a = precord(ctx, "PaletteRecord46E8")   # host of loaded Bank08ObjectPalette46EA
    ref_b = precord(ctx, "PaletteRecord5500")   # host of loaded EffectPalette5502
    check(words(ref_a) == [0x0000, 0x001C, 0x025C, 0x03FF], "rule 3: A reference PaletteRecord46E8 changed")
    check(words(ref_b) == [0x0000, 0x7D04, 0x46A0, 0x7FFF], "rule 3: B reference PaletteRecord5500 changed")
    for a in GROUP_A:
        check(precord(ctx, prec_addr(ctx, a)) == ref_a, f"rule 3: A PaletteRecord{a:04X} != PaletteRecord46E8")
    for a in GROUP_B:
        check(precord(ctx, prec_addr(ctx, a)) == ref_b, f"rule 3: B PaletteRecord{a:04X} != PaletteRecord5500")
    for a in GROUP_C:
        check(words(precord(ctx, prec_addr(ctx, a))) == [0x0000, 0x7D03] + words(ref_b)[2:],
              f"rule 3: C PaletteRecord{a:04X} is not PaletteRecord5500 with colour 1 $7D03")
    d0, d1 = (precord(ctx, prec_addr(ctx, a)) for a in GROUP_D)
    check(d0 == d1 and words(d0) == [0, 0x001F, 0x033F, 0x03FE], "rule 3: D PaletteRecord610A != PaletteRecord621A")
    check(precord(ctx, prec_addr(ctx, 0x6263)) == precord(ctx, "Bank08HudIconPalette"),
          "rule 3: 6263 PaletteRecord6263 != Bank08HudIconPalette")
    # PaletteRecord69F5 colours 2-3 == Bank08ObjectPalettes67FD row 3 colours 2-3
    check(precord(ctx, prec_addr(ctx, 0x69F5), 4, 4) == precord(ctx, "Bank08ObjectPalettes67FD", 4, 20),
          "rule 3: 69F5 colours 2-3 != Bank08ObjectPalettes67FD row 3 colours 2-3")
    need = {a: "Bank08ObjectPalette46EA" for a in GROUP_A}
    need.update({a: "byte-identical to PaletteRecord5500" for a in GROUP_B})
    need.update({a: "colour 1 $7D03" for a in GROUP_C})
    need.update({0x610A: "PaletteRecord621A", 0x621A: "PaletteRecord610A", 0x6263: "Bank08HudIconPalette"})
    src = ctx.src.get("bank_08.asm", "")
    for a, text in sorted(need.items()):
        m = re.search(r"^PaletteRecord%04X:(.*)$" % a, src, re.M)
        check(m and text in m.group(1) and "(unread)" in m.group(1),
              f"rule 3: comment PaletteRecord{a:04X} must name {text!r} and '(unread)'")
    check_unread(ctx, sorted(need))
    return len(need)


def check_unread(ctx, addrs):
    """Each '(unread)' record label has no reference outside its definition
    and ASSERT lines, in src/*.asm and include/*.inc (comments stripped)."""
    files = dict(ctx.src)
    files.update(ctx.inc)
    pats = {a: re.compile(r"(?<![\w.])PaletteRecord%04X(?!\w)" % a) for a in addrs}
    for fn in sorted(files):
        for i, line in enumerate(files[fn].split("\n")):
            code = strip(line)
            if not code or code.upper().startswith("ASSERT"):
                continue
            for a in addrs:
                if pats[a].search(code):
                    if re.match(r"^PaletteRecord%04X::?$" % a, code):
                        continue
                    raise InvariantError(f"rule 3: PaletteRecord{a:04X} marked (unread) has reader at {fn}:{i + 1}: {code}")


# ------------------------------------------------------------------- negatives
def expect_fail(name, fn, ctx, needle):
    needles = needle if isinstance(needle, tuple) else (needle,)
    try:
        fn(ctx)
    except InvariantError as e:
        check(all(n in str(e) for n in needles), f"negative test '{name}' failed for wrong reason: {e}")
        return f"    rejected: {name}: {e}"
    raise InvariantError(f"negative test '{name}' was not rejected")


def negative_tests(ctx):
    out = []
    # 1
    bank, addr = ctx.label("TrackerDirectionLookup")
    c = mut(ctx)
    c.rom[off(bank, addr) + 0x123] ^= 0x10
    out.append(expect_fail("ROM tracker high nibble flipped at +$123", check_tracker, c, ("ROM", "+$123")))
    rel = tracker_asset_path(ctx)
    a = bytearray(ctx.asset(rel))
    a[0x7FF] ^= 0x01
    out.append(expect_fail("asset tracker low nibble flipped at +$7FF", check_tracker,
                           mut(ctx, assets={**ctx.assets, rel: bytes(a)}), ("asset", "+$7FF")))
    out.append(expect_fail("asset tracker truncated", check_tracker,
                           mut(ctx, assets={**ctx.assets, rel: ctx.asset(rel)[:-1]}), "2047 bytes"))
    c = mut(ctx)
    c.sym["TrackerDirectionLookup"] = (bank, addr + 1)
    out.append(expect_fail("tracker symbol moved by one", check_tracker, c, "label span"))

    # 2
    def sub(fn, old, new):
        check(old in ctx.src[fn], f"negative setup: {old!r} not in {fn}")
        return mut(ctx, src={**ctx.src, fn: ctx.src[fn].replace(old, new, 1)})
    for name, c, needle in (
            ("music id past table", sub("bank_02.asm", "ld e, $82", "ld e, $8A"), "out-of-range id $8A"),
            ("sfx id past table", sub("bank_02.asm", "ld e, $4F", "ld e, $59"), "out-of-range id $59"),
            ("patch id past table", sub("bank_02.asm", "ld e, $80", "ld e, $25"), "out-of-range id $25"),
            ("id zero", sub("bank_02.asm", "ld e, $80", "ld e, $00"), "out-of-range id $00"),
            ("sfx_patch past table", sub("audio_data.asm", "sfx_patch $1A, 6", "sfx_patch $25, 6"), "sfx_patch $25"),
            ("unreviewed dynamic site", sub("bank_02.asm", "ld e, $82", "ld e, c"), "unreviewed non-immediate"),
            ("music queue event", sub("audio_data.asm", "music_loop $FF, 0", "music_loop $9A, 0"), "out-of-range $9A"),
            ("RespawnPlayer ld e,$58 made dynamic",
             sub("bank_00.asm", ".beginGameplay:\n\tld e, $58\n", ".beginGameplay:\n\tld e, c\n"),
             ("unreviewed non-immediate", "RespawnPlayer", "call #2", "ld e, c")),
            ("reviewed site preceding instruction changed",
             sub("bank_00.asm", "\tadd a, $81\n\tld e, a\n\tcall Audio_QueueSound\n.beginGameplay:",
                 "\tadd a, $81\n\tld e, b\n\tcall Audio_QueueSound\n.beginGameplay:"),
             ("unreviewed non-immediate", "RespawnPlayer", "call #1", "ld e, b")),
            ("sfx class bit lowered in Audio_PlaySound",
             sub("bank_06.asm", "\tjr nz, .StartMusic\n\tbit 6, a\n", "\tjr nz, .StartMusic\n\tbit 5, a\n"),
             "sfx index mask $3F != $1F implied by bit 5"),
            ("sfx class bit and mask lowered together",
             sub(*(lambda t: ("bank_06.asm", t, t.replace("\tbit 6, a\n", "\tbit 5, a\n", 1)
                                .replace("\tand $3F\n\tld hl, SfxSequencePointers", "\tand $1F\n\tld hl, SfxSequencePointers")))(
                 ctx.src["bank_06.asm"][ctx.src["bank_06.asm"].index("Audio_PlaySound:"):
                                        ctx.src["bank_06.asm"].index("ld hl, SfxSequencePointers") + 26])),
             ("out-of-range id", "sfx $20-$7F")),
            ("Audio_QueueSound zero-id drop removed",
             sub("bank_00.asm", "\tld a, e\n\tand a\n\tret z\n", "\tld a, e\n\tand a\n"), "drops id 0"),
            ("music table shrunk in source", sub("audio_data.asm",
             "\tdw Music_08\n\tdb BANK(Music_08), $00\n\tdw Music_09\n\tdb BANK(Music_09), $00\n", ""),
             "MusicPointers..MusicPointerTablePadding")):
        out.append(expect_fail(name, check_sound_ids, c, needle))
    c = mut(ctx)
    b, a2 = ctx.sym["MusicPointerTablePadding"]
    c.sym["MusicPointerTablePadding"] = (b, a2 - 4)
    out.append(expect_fail("music table symbol span short by one entry", check_sound_ids, c, "is 36 bytes"))

    # 3
    for g, label, d, needle in (("A", "PaletteRecord5310", 3, "A PaletteRecord5310"),
                                ("B", "PaletteRecord5A58", 6, "B PaletteRecord5A58"),
                                ("C", "PaletteRecord5D08", 2, "C PaletteRecord5D08"),
                                ("D", "PaletteRecord621A", 5, "D PaletteRecord610A"),
                                ("6263", "PaletteRecord6263", 4, "6263 PaletteRecord6263"),
                                ("69F5", "PaletteRecord69F5", 7, "69F5 colours")):
        c = mut(ctx)
        b, a2 = ctx.label(label)
        c.rom[off(b, a2) + d] ^= 0x01
        out.append(expect_fail(f"group {g} byte flipped at $08:{a2 + d:04X}", check_bank08_palettes, c, needle))
    s = ctx.src["bank_08.asm"]
    old = "PaletteRecord5D88: ; byte-identical to PaletteRecord5500"
    check(old in s, "negative setup: PaletteRecord5D88 comment not found")
    out.append(expect_fail("PaletteRecord5D88 comment loses relation", check_bank08_palettes,
                           mut(ctx, src={**ctx.src, "bank_08.asm": s.replace(old, "PaletteRecord5D88: ; palette", 1)}),
                           "comment PaletteRecord5D88"))
    hud = "Bank08HudIconPalette:"
    check(hud in s, "negative setup: Bank08HudIconPalette not found")
    out.append(expect_fail("reader added for (unread) PaletteRecord5D88", check_bank08_palettes,
                           mut(ctx, src={**ctx.src, "bank_08.asm": s.replace(hud, "\tdw PaletteRecord5D88\n" + hud, 1)}),
                           ("PaletteRecord5D88 marked (unread) has reader", "bank_08.asm")))
    out.append(expect_fail("include reader for (unread) PaletteRecord49C0", check_bank08_palettes,
                           mut(ctx, inc={**ctx.inc, "zz_neg.inc": "DEF X EQU PaletteRecord49C0 + 2 ; x\n"}),
                           ("PaletteRecord49C0 marked (unread) has reader", "zz_neg.inc")))
    c = mut(ctx)
    del c.sym["PaletteRecord5910"]
    out.append(expect_fail("PaletteRecord5910 symbol missing", check_bank08_palettes, c, "PaletteRecord5910 missing"))
    return out


def run(root):
    ctx = Ctx(root)
    lines = []
    bank, addr, rel = check_tracker(ctx)
    lines.append(f"rule 1: TrackerDirectionLookup ${bank:02X}:{addr:04X} and {rel}: {TRACKER_SIZE} bytes match formula")
    n, sites, unq = check_sound_ids(ctx)
    lines.append(f"rule 2: {sites} Audio_QueueSound sites in range; tables patches={n['patch']} "
                 f"sfx={n['sfx']} music={n['music']} match symbol spans")
    for k in ("patch", "sfx", "music"):
        lines.append(f"    never queued {k}: " + " ".join(f"${v:02X}" for v in unq[k]))
    sb, mb = n["classes"]
    lines.append(f"    classes derived from Audio_PlaySound: patch $01-${sb - 1:02X}, sfx ${sb:02X}-${mb - 1:02X}, "
                 f"music ${mb:02X}-$FF; 7 dynamic sites matched by call site")
    lines.append("info: patches referenced only by never-queued sfx sequences (never sounded):")
    for v, where in n["unsounded"]:
        lines.append(f"    ${v:02X}: " + "; ".join(where))
    ncom = check_bank08_palettes(ctx)
    lines.append(f"rule 3: bank $08 duplicates A={len(GROUP_A)} B={len(GROUP_B)} C={len(GROUP_C)} "
                 f"D={len(GROUP_D)} +6263 +69F5; {ncom} record comments name the relation")
    neg = negative_tests(ctx)
    lines.append(f"{len(neg)} negative tests rejected:")
    lines.extend(neg)
    return lines


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    root = pathlib.Path(args[0]).resolve() if args else ROOT
    try:
        print("\n".join(run(root)))
    except InvariantError as e:
        print(f"FAIL: {e}")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
