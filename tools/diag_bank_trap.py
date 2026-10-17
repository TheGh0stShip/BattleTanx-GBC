#!/usr/bin/env python3
"""Build the diagnostic mapped-bank-trap ROM without touching src/.

Copies src/, include/ and assets/ into a work directory, assembles the
unmodified copy and requires SHA-1 5078584e... (shipping), then rewrites the
copy so the three RAM-image calls into bank 1 go through ROM0 checkers placed
in the trailing ROM0 zero fill ($3F39-$3FFF), assembles it, and checks that
only the checker range and the three 2-byte call operands differ.

Usage: tools/diag_bank_trap.py [--repo DIR] [--out DIR] [--keep-work]
Output: <out>/battletanx_diag.gbc and .sym (default out: build/diag).
The diagnostic ROM is not a shipping build; its global checksum is stale.
"""
import os, sys
# tools/dis.py in this repo shadows the stdlib "dis" module (pulled in by
# argparse on Python 3.14); drop the script directory from the import path.
_here = os.path.dirname(os.path.abspath(__file__))
sys.path[:] = [p for p in sys.path if os.path.abspath(p or ".") != _here]
import argparse, hashlib, shutil, subprocess, tempfile

SHIPPING_SHA1 = "5078584e86c0b6f4687c424cc00bbd762ba6573a"
DIAG_SHA1 = "27aea214475a791b88c4bce91dc56d8ac2003b13"  # stub+operand bytes are label-independent
STUB_START, STUB_END = 0x3F39, 0x4000          # ROM0 zero fill replaced
CALL_SITES = {  # ROM offset of CALL opcode: (old target, new target symbol)
    0x5BE3: (0x5F26, "DiagCheck_5F26"),        # exec $D14B area -> $D14D
    0x5DA3: (0x5EE0, "DiagCheck_5EE0"),        # exec $C755
    0x5E3A: (0x6580, "DiagCheck_6580"),        # exec $C815
}

STUB = """; ---- DIAGNOSTIC BUILD ONLY (not shipping): mapped-bank checker ----
; Replaces the trailing ROM0 zero fill ($3F39-$3FFF). ROM0 is always mapped,
; so these run whatever bank is in $4000-$7FFF. AF, BC, DE, HL and SP are
; unchanged on the pass path (pop af discards the flags set by cp).
DiagCheck_5EE0: ; called from RAM $C755 (SceneStatHandler)
	push af
	ld a, [$7FFF]
	cp $01
	jr nz, .trap
	pop af
	jp {T_5EE0}
.trap
	ld a, $01
	jr DiagTrap
DiagCheck_5F26: ; called from RAM $D14D (StepSceneWindowSplit)
	push af
	ld a, [$7FFF]
	cp $01
	jr nz, .trap
	pop af
	jp {T_5F26}
.trap
	ld a, $02
	jr DiagTrap
DiagCheck_6580: ; called from RAM $C815 (SceneVBlankHandler)
	push af
	ld a, [$7FFF]
	cp $01
	jr nz, .trap
	pop af
	jp {T_6580}
.trap
	ld a, $03
; Signature at WRAM0 $C000: $D1 $A6 site mapped-bank LY; solid red BG; hang.
DiagTrap:
	di
	ld [$C002], a
	ld a, [$7FFF]
	ld [$C003], a
	ldh a, [$FF44]
	ld [$C004], a
	ld a, $D1
	ld [$C000], a
	ld a, $A6
	ld [$C001], a
	ld a, $80
	ldh [$FF68], a
	ld b, $20
.pal
	ld a, $1F
	ldh [$FF69], a
	xor a
	ldh [$FF69], a
	dec b
	jr nz, .pal
	ld b, b ; source breakpoint for emulators that honour it
.hang
	jr .hang
	ds $4000 - @, $00
"""

# Each site: candidate ROM-side target labels (current names first, then the
# 1a57207 names). The call line is matched by exact instruction text; the
# label that is actually called is also the stub's jump target.
SITES = [  # (key, candidate labels, stub symbol)
    ("T_5F26", ("WriteBgPalette7FromFF98RomImage", "Bank01RomImage_5F26"), "DiagCheck_5F26"),
    ("T_5EE0", ("WriteBgPalette7FromD3F8RomImage", "Bank01RomImage_5EE0"), "DiagCheck_5EE0"),
    ("T_6580", ("StartSceneTileRowHdma",), "DiagCheck_6580"),
]


def die(msg):
    sys.exit("diag_bank_trap: " + msg)


def build(work, tag):
    o, sym, gbc = (os.path.join(work, tag + e) for e in (".o", ".sym", ".gbc"))
    for cmd in (["rgbasm", "-Werror", "-o", o, "src/main.asm"],
                ["rgblink", "-p", "0xFF", "-n", sym, "-o", gbc, o]):
        r = subprocess.run(cmd, cwd=work, capture_output=True, text=True)
        if r.returncode:
            die("%s failed:\n%s%s" % (cmd[0], r.stdout, r.stderr))
    data = open(gbc, "rb").read()
    return data, hashlib.sha1(data).hexdigest(), sym, gbc


def patch(work):
    p = os.path.join(work, "src", "bank_00.asm")
    lines = open(p).read().split("\n")
    # Trailing zero fill: maximal run of "\tdb $00, ..." / blank lines at EOF.
    i = len(lines)
    while i and (lines[i - 1] == "" or
                 (lines[i - 1].startswith("\tdb ") and
                  set(lines[i - 1][4:].replace(",", " ").split()) == {"$00"})):
        i -= 1
    if not any(l.startswith("\tdb ") for l in lines[i:]):
        die("no trailing ROM0 zero fill found in bank_00.asm")
    head = "\n".join(lines[:i] + [""])
    p = os.path.join(work, "src", "bank_01.asm")
    s = open(p).read()
    targets = {}
    for key, cands, stub in SITES:
        found = [c for c in cands if s.count("\tcall %s\n" % c) == 1]
        if len(found) != 1:
            die("call site for %s not found exactly once (tried %s)" % (stub, ", ".join(cands)))
        a = "\tcall %s\n" % found[0]
        s = s.replace(a, "\tcall %s ; DIAG (was %s)\n" % (stub, found[0]))
        targets[key] = found[0]
    open(p, "w").write(s)
    p0 = os.path.join(work, "src", "bank_00.asm")
    open(p0, "w").write(head + STUB.format(**targets))
    return targets


def read_sym(path):
    out = {}
    for line in open(path):
        parts = line.split(";")[0].split()
        if len(parts) == 2 and ":" in parts[0]:
            b, a = parts[0].split(":")
            out[parts[1]] = (int(b, 16), int(a, 16))
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--repo", default=os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    ap.add_argument("--out", default=None, help="output dir (default <repo>/build/diag)")
    ap.add_argument("--keep-work", action="store_true")
    args = ap.parse_args()
    repo = os.path.abspath(args.repo)
    out = os.path.abspath(args.out or os.path.join(repo, "build", "diag"))
    if os.path.commonpath([out, os.path.join(repo, "src")]) == os.path.join(repo, "src"):
        die("refusing to write under src/")
    v = subprocess.run(["rgbasm", "--version"], capture_output=True, text=True).stdout.strip()
    if "1.0.4" not in v:
        die("RGBDS 1.0.4 required, found %r" % v)

    src_hash = {}
    for root, _, files in os.walk(os.path.join(repo, "src")):
        for f in files:
            q = os.path.join(root, f)
            src_hash[q] = hashlib.sha1(open(q, "rb").read()).hexdigest()

    work = tempfile.mkdtemp(prefix="diag_bank_trap.")
    try:
        for d in ("src", "include", "assets"):
            shutil.copytree(os.path.join(repo, d), os.path.join(work, d))
        ship, ship_sha, ship_sym, _ = build(work, "ship")
        if ship_sha != SHIPPING_SHA1:
            die("unmodified copy builds %s, expected %s" % (ship_sha, SHIPPING_SHA1))
        ship_syms = read_sym(ship_sym)
        targets = patch(work)
        for key, _, _ in SITES:
            if ship_syms[targets[key]][1] != int(key[2:], 16):
                die("%s is not at $%s" % (targets[key], key[2:]))
        diag, diag_sha, diag_sym, diag_gbc = build(work, "diag")
        if len(diag) != len(ship):
            die("ROM size changed")
        syms = read_sym(diag_sym)
        # Nothing moved: every shipping symbol keeps its bank:address.
        moved = [k for k, a in ship_syms.items() if syms.get(k) != a]
        if moved:
            die("symbols moved: %s" % moved[:10])
        for k in ("DiagCheck_5EE0", "DiagCheck_5F26", "DiagCheck_6580", "DiagTrap"):
            b, a = syms[k]
            if b != 0 or not STUB_START <= a < STUB_END:
                die("%s at %02X:%04X outside ROM0 fill" % (k, b, a))
        allowed = set(range(STUB_START, STUB_END))
        for off, (old, new) in CALL_SITES.items():
            if ship[off] != 0xCD or ship[off + 1] | ship[off + 2] << 8 != old:
                die("shipping call at %04X is not CALL $%04X" % (off, old))
            tgt = diag[off + 1] | diag[off + 2] << 8
            if diag[off] != 0xCD or tgt != syms[new][1]:
                die("diag call at %04X not retargeted to %s" % (off, new))
            allowed |= {off + 1, off + 2}
        diffs = [i for i in range(len(ship)) if ship[i] != diag[i]]
        stray = [i for i in diffs if i not in allowed]
        if stray:
            die("unexpected byte changes at %s" % ", ".join("%X" % i for i in stray[:16]))
        if any(ship[i] for i in range(STUB_START, STUB_END)):
            die("shipping $3F39-$3FFF is not zero fill")
        for q, h in src_hash.items():
            if hashlib.sha1(open(q, "rb").read()).hexdigest() != h:
                die("src/ changed during run: " + q)
        os.makedirs(out, exist_ok=True)
        shutil.copy(diag_gbc, os.path.join(out, "battletanx_diag.gbc"))
        shutil.copy(diag_sym, os.path.join(out, "battletanx_diag.sym"))
        print("shipping copy  %s OK" % ship_sha)
        print("diagnostic     %s%s" % (diag_sha, "" if diag_sha == DIAG_SHA1 else
              " (differs from 1a57207 reference %s; byte-range checks passed)" % DIAG_SHA1))
        print("%d bytes differ, all in $%04X-$%04X or call operands" % (len(diffs), STUB_START, STUB_END - 1))
        print("written to " + out)
    finally:
        if args.keep_work:
            print("work dir kept: " + work)
        else:
            shutil.rmtree(work, ignore_errors=True)


if __name__ == "__main__":
    main()
