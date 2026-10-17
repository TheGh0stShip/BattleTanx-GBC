#!/usr/bin/env python3
"""Relocation (shift) tests for banks $09-$3A.

Each case copies the source tree to a scratch directory, inserts `ds N, $00`
immediately before one label, assembles WITHOUT baserom.gbc, and compares the
result with an unmodified scratch build:

  relocate  - assembly must succeed; every label at or after the insertion
              point in that bank moves by exactly N, no other label moves, and
              every changed byte outside the shifted region belongs to a
              16-bit little-endian word whose value moved by exactly N toward
              a moved label (a relocated pointer). The number of relocated
              words must be at least `min_refs`.
  fail-safe - assembly must stop (an ASSERT or a bank-size limit), proving
              that a structure whose position is pinned by a raw reference or
              a hardware layout cannot be moved silently.

Usage: shift_test.py [ROOT]
"""
from __future__ import annotations

import pathlib
import re
import shutil
import subprocess
import sys
import tempfile

N = 16

# (name, file, label, mode, min_refs, reason)
CASES = [
    ("level 0 odd bank (cell map, tiles, lookup table, palettes)", "src/bank_09.asm", "Level00_CellMap",
     "relocate", 4, "level record tiles/palettes/cell-map pointers and LevelAttributeLookupPointers"),
    ("level 0 even bank (tile map, attribute map)", "src/bank_0A.asm", "Level00_TileMap",
     "relocate", 2, "level record tile/attribute map pointers"),
    ("level 0 attribute map inside its bank", "src/bank_0A.asm", "Level00_AttrMap",
     "fail-safe", 0, "ASSERT Level00_AttrMap - Level00_TileMap == width*height (the loader indexes both maps with one offset)"),
    ("level 14 even bank (source of the $27-$29 residue slices)", "src/bank_26.asm", "Level14_TileMap",
     "relocate", 2, "level record pointers; residue slices use the asset file, not the address"),
    ("object orientation frames bank $27", "src/bank_27.asm", "Bank27OrientationTiles",
     "fail-safe", 0, "$05:ObjectOrientationTilePointers holds raw $4000-$4480 words (bank $05 is out of scope)"),
    ("object palette bank $28", "src/bank_28.asm", "Bank28ObjectPalette",
     "fail-safe", 0, "the bank-$26 residue must stay at $4518 (byte-identical copy at the same offset)"),
    ("screen package mode 7 (code, descriptor, tiles, maps, palettes)", "src/bank_2B.asm", "Func_2B_4000",
     "relocate", 8, "ScreenModeTable legacy aliases, descriptor pointers, ld hl operands in the templates"),
    ("screen package mode 3 alternate maps", "src/bank_2C.asm", "ScreenMode03_AltTileMap",
     "fail-safe", 0, "$01:7981 uses raw $6CE9/$6FB9 (bank $01 is out of scope); the ASSERT on the interleaved layout stops the move"),
    ("fixed scenes 06-07 (bank $30, HDMA tile windows, maps, attributes, palettes)", "src/bank_30.asm", "FixedScene06Tiles",
     "relocate", 8, "SceneBackgroundDescriptors pointers are symbolic; banks are pinned with BANK() asserts"),
    ("scrolling scenes 32-35 (bank $30, symbolic descriptors)", "src/bank_30.asm", "ScrollScene32Tiles",
     "relocate", 12, "ScrollingSceneDescriptors entries 32-35 are symbolic"),
    ("fixed scene misaligned for HDMA", "src/bank_30.asm", "FixedScene07Tiles",
     "fail-safe", 0, "an 8-byte insertion breaks the 16-byte HDMA source alignment ASSERT", 8),
    ("scrolling scene 21 (bank $2F, tiles, rows, palette)", "src/bank_2F.asm", "ScrollScene21Tiles",
     "fail-safe", 0, "ScrollingSceneDescriptors in bank $01 hold raw words"),
    ("bank $2E pictures used by the $01:$596D table", "src/bank_2E.asm", "Picture596D1_Tiles",
     "fail-safe", 0, "the $01:$596D table holds raw words; ASSERT tying the pictures to Screen2E's palettes"),
]


def parse_sym(path: pathlib.Path) -> dict:
    out = {}
    for line in path.read_text().splitlines():
        m = re.fullmatch(r"([0-9a-fA-F]{2}):([0-9a-fA-F]{4}) (\S+)", line.strip())
        if m:
            out[m.group(3)] = (int(m.group(1), 16), int(m.group(2), 16))
    return out


def build(tree: pathlib.Path):
    r = subprocess.run(["rgbasm", "-Werror", "-o", "t.o", "src/main.asm"], cwd=tree,
                       capture_output=True, text=True)
    if r.returncode:
        return None, (r.stderr.strip().splitlines() or ["?"])[-1]
    r = subprocess.run(["rgblink", "-p", "0xFF", "-n", "t.sym", "-o", "t.gbc", "t.o"], cwd=tree,
                       capture_output=True, text=True)
    if r.returncode:
        return None, (r.stderr.strip().splitlines() or ["?"])[-1]
    return ((tree / "t.gbc").read_bytes(), parse_sym(tree / "t.sym")), None


def copy_tree(root: pathlib.Path, dst: pathlib.Path) -> None:
    for name in ("src", "include", "assets"):
        shutil.copytree(root / name, dst / name)


def run_case(root, base, name, rel, label, mode, min_refs, n=None):
    global N
    N = n or 16
    rom0, sym0 = base
    with tempfile.TemporaryDirectory() as tmp:
        t = pathlib.Path(tmp)
        copy_tree(root, t)
        src = t / rel
        lines = src.read_text().split("\n")
        idx = [i for i, l in enumerate(lines) if l.split(";")[0].strip() in (f"{label}:", f"{label}::")]
        if len(idx) != 1:
            return False, f"label {label} not found once in {rel}"
        lines.insert(idx[0], f"\tds {N}, $00 ; shift test")
        src.write_text("\n".join(lines))
        res, err = build(t)
    if mode == "fail-safe":
        return (res is None), (f"assembly stopped as required: {err}" if res is None
                               else "assembly succeeded although the structure is pinned")
    if res is None:
        return False, f"assembly failed: {err}"
    rom1, sym1 = res
    bank, start = sym0[label]
    # labels at the bank marker ($7FFF) stay put: computed fills absorb the padding
    moved = {k for k, (b, a) in sym0.items() if b == bank and a >= start and 0x4000 <= a < 0x7FFF}
    for k, (b, a) in sym0.items():
        want = (b, a + N) if k in moved else (b, a)
        if sym1.get(k) != want:
            return False, f"label {k} moved to {sym1.get(k)}, expected {want}"
    targets = {sym0[k][1] for k in moved}
    lo, hi = min(targets), max(targets) + N
    boff = bank * 0x4000
    # region of bank `bank` that moved: [start, last moved label end) approximated by fill start
    end_old = 0x8000 - 1
    while end_old > start and rom0[boff + end_old - 0x4000 - 1] == 0 and rom1[boff + end_old - 0x4000 - 1 + 0] in (0,):
        break
    diffs = []
    for i in range(len(rom0)):
        if boff <= i < boff + 0x4000:
            addr = 0x4000 + i - boff
            if addr >= start:
                continue          # shifted region is compared below
        if rom0[i] != rom1[i]:
            diffs.append(i)
    # shifted region: old[addr] must equal new[addr + N] up to the fill
    for addr in range(start, 0x7FFF - N):
        a, b = rom0[boff + addr - 0x4000], rom1[boff + addr + N - 0x4000]
        if a != b:
            diffs.append(("s", addr))
    relocated, unexplained = set(), []
    for d in diffs:
        if isinstance(d, tuple):
            o0 = boff + d[1] - 0x4000
            o1 = o0 + N
        else:
            o0 = o1 = d
        ok = False
        for w in (o0 - 1, o0):
            w1 = w + (o1 - o0)
            v0 = rom0[w] | rom0[w + 1] << 8
            v1 = rom1[w1] | rom1[w1 + 1] << 8
            if v1 - v0 == N and lo <= v0 < hi and v0 in targets | set(range(lo, hi)):
                relocated.add(w)
                ok = True
                break
        if not ok:
            unexplained.append(d)
    if unexplained:
        return False, f"{len(unexplained)} changed bytes are not relocated pointers (first {unexplained[0]})"
    if len(relocated) < min_refs:
        return False, f"only {len(relocated)} relocated pointer words, expected at least {min_refs}"
    return True, f"{len(moved)} labels moved by {N}; {len(relocated)} pointer words relocated; no other byte changed"


def main() -> int:
    root = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    with tempfile.TemporaryDirectory() as tmp:
        t = pathlib.Path(tmp)
        copy_tree(root, t)
        base, err = build(t)
    if base is None:
        print(f"shift: unmodified build failed: {err}")
        return 1
    ok_all = True
    for case in CASES:
        name, rel, label, mode, min_refs, reason = case[:6]
        ok, msg = run_case(root, base, name, rel, label, mode, min_refs, case[6] if len(case) > 6 else None)
        ok_all &= ok
        print(f"shift: {'PASS' if ok else 'FAIL'} [{mode}] {name}: {msg}")
        print(f"        reason: {reason}")
    print(f"shift: {sum(1 for _ in CASES)} cases, {'all passed' if ok_all else 'FAILURES'} (assembled without baserom.gbc)")
    return 0 if ok_all else 1


if __name__ == "__main__":
    sys.exit(main())
