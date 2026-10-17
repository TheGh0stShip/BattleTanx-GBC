#!/usr/bin/env python3
"""Whole-ROM range map: every byte of all 64 banks, derived from the source.

RGBDS has no listing output, so a scratch copy of src/ is assembled with a
`PRINTLN` of the current address before every top-level statement. That gives
an exact statement -> ROM range map. Consecutive statements under the same
source label and of the same kind are merged into one range record:

  bank, start, end (exclusive), kind, label, file:line, asset, readers,
  understanding, evidence, flags

kind:          code | ram code | ram data | data | asset | fill | marker
understanding: named      - behaviour or format name from evidence
               neutral    - address/format placeholder or explicitly unread/unknown
               padding    - fill and bank markers
evidence:      traced     - code reached by tools/rom_trace.py from known entries
               untraced   - instruction source the tracer does not reach
               referenced - data whose label (or label+offset) appears in code
               unreferenced
               layout     - fill, markers, end-of-bank padding
flags:         unused, unreachable, duplicated, residue, padding, runtime code

Checks (all fatal): full coverage of $0000-$3FFF and 63 x $4000-$7FFF with no
gap or overlap; the assembled scratch ROM equals baserom.gbc; every
assets.txt entry exists, has the right size and bytes, and lies in a range the
source fills with INCBIN; every literal INCBIN path is either listed in
assets.txt or (for files split into slices around labels) covered exactly once,
byte for byte, by its direct INCBIN slices; TAIL_SCOPE labels cover their
declared byte count; INDEXED_MEMBERS offsets agree with the base, origin and
stride derived from the reading routine; COMPUTED_READS anchors are really read
by the named routine; SEPARATORS are single bytes after a RAM image; the
committed report is fresh.

Readers: ASSERT lines never count. A RAM image entry label is credited when its
WRAM address is the target of a numeric jp/call (interrupt vectors) and its ROM
image label is a copy source, or when the ROM image label itself is called.

Outputs (deterministic): reports/rom_range_map.json, and the derived
inventory reports/rom_unresolved_inventory.json.
Usage: rom_range_map.py [--write] [--no-negative]
"""
from __future__ import annotations

import collections
import hashlib
import json
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
REPORT = "reports/rom_range_map.json"
INVENTORY = "reports/rom_unresolved_inventory.json"
DIRECTIVE = re.compile(r"^(SECTION|INCLUDE|IF|ELIF|ELSE|ENDC|ENDR|ENDM|MACRO|REPT|FOR|DEF|REDEF|ASSERT|STATIC_ASSERT|"
                       r"PRINT|PRINTLN|EXPORT|PURGE|OPT|PUSHO|POPO|PUSHS|POPS|CHARMAP|NEWCHARMAP|SETCHARMAP|ALIGN|UNION|NEXTU|ENDU|"
                       r"FAIL|WARN|SHIFT|BREAK|RSRESET|RSSET|RB|RW|RL)\b", re.I)
LABEL_DEF = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)::?")
# automatic/address names and explicit "meaning unknown" names; Unused*/Residue*
# names are understood (identity known, no reader) and only flagged
NEUTRAL = re.compile(r"^(Func|Jump|RAM)_[0-9A-F]{2,4}|_[0-9A-F]{4}$|Data_[0-9A-F]{4}|Unread|Unknown|Gap|Unclassified")
AUTO = re.compile(r"^(Func|Jump|RAM)_[0-9A-F]{2,4}|_[0-9A-F]{4}$|Data_[0-9A-F]{4}")
DUPLICATED = re.compile(r"Copy|copy_|Duplicate", re.I)
RESIDUE = re.compile(r"[Rr]esidue")
UNUSED = re.compile(r"Unread|Unused|Unreferenced")
# Bytes after a sequence end marker: identity known (never read), so named, not neutral.
TRAILER = re.compile(r"^(SfxSequence|Music)_[0-9A-F]{2}_UnreadTrailer$")
# Labels that name only their first N statements. The statements after them
# belong to the label before the tail, not to the tail (worker w20 C10).
# label -> (statement count, byte count, reason); the byte count is asserted.
TAIL_SCOPE = {}
# Members of indexed tables, reached only by base + origin + index * stride (+ field).
# A member counts as read only when its base has readers of its own, lies in the same
# bank before the member, within MAX_INDEXED_SPAN bytes, at a whole stride from the
# origin with index < count, and the reader routine's own code derives the origin and
# stride (worker w20 C12; stride check per v103).
# member -> (base, reader routine, origin, stride, field, count, reason)
MAX_INDEXED_SPAN = 80
_MENU = "MenuState04 record walk: GetMenuChoiceRecord adds $05 to [wMenuState], then $10 per choice"
_CTRL = "ControlTypeTexts + [wControlSetting] * 8 (add a, a x3; DrawOptionsEntryValue_CheckControlType)"
_SKILL = "SkillTexts + [wSkillSetting] * 8 (add a, a x3; DrawOptionsEntryValue_CheckSkill)"
INDEXED_MEMBERS = {
    "OptionsMenuEntries": ("MenuState04", "GetMenuChoiceRecord", 5, 16, 0, 5, _MENU + "; choices 1-3 start here"),
    "OptionsMusicText": ("MenuState04", "GetMenuChoiceRecord", 5, 16, 6, 5, _MENU + "; text field (+6) of choice 1"),
    "OptionsControlText": ("MenuState04", "GetMenuChoiceRecord", 5, 16, 6, 5, _MENU + "; text field (+6) of choice 2"),
    "OptionsSkillText": ("MenuState04", "GetMenuChoiceRecord", 5, 16, 6, 5, _MENU + "; text field (+6) of choice 3"),
    "OptionsMenuEntriesEnd": ("MenuState04", "GetMenuChoiceRecord", 5, 16, 0, 5,
                              _MENU + "; slot 4 holds the $FF that stops the walk"),
    "ControlType2Text": ("ControlTypeTexts", "DrawOptionsEntryValue_CheckControlType", 0, 8, 0, 3, _CTRL),
    "ControlType3Text": ("ControlTypeTexts", "DrawOptionsEntryValue_CheckControlType", 0, 8, 0, 3, _CTRL),
    "SkillMediumText": ("SkillTexts", "DrawOptionsEntryValue_CheckSkill", 0, 8, 0, 3, _SKILL),
    "SkillHardText": ("SkillTexts", "DrawOptionsEntryValue_CheckSkill", 0, 8, 0, 3, _SKILL),
}
# Blocks read only through addresses computed at run time. label -> (reader routine,
# anchor symbol that the reader names in its own code, reason). The anchor must be
# referenced by the reader (ASSERT lines excluded).
COMPUTED_READS = {
    "UiFontTiles": ("LoadInterfaceTilesVRAM1", "Bank08UiFontTiles",
                    "ld bc, Bank08UiFontTiles + $10; CopyTilesToVRAM copies 61 tiles from tile 1"),
    "Bank27OrientationTiles": ("Func_0F43", "ObjectOrientationTilePointers",
                               "CopyObjectOrientationTiles maps bank [$FF80] + $27 and reads "
                               "$05:ObjectOrientationTilePointers[[$FF81]] (raw $4000-$4480)"),
    "Bank28OrientationTiles": ("Func_0F43", "ObjectOrientationTilePointers",
                               "CopyObjectOrientationTiles with [$FF80] = 1 maps bank $28"),
    "Bank29OrientationTiles": ("Func_0F43", "ObjectOrientationTilePointers",
                               "CopyObjectOrientationTiles with [$FF80] = 2 maps bank $29"),
}
# Single bytes between consecutive RAM images, outside every copy length (w104).
# (bank, address) -> (byte, reason)
SEPARATORS = {
    (0x01, 0x5660): (0x00, "after UnusedMenuRamNoOp image ($01:565F, 1 byte) and before the $D7CB image"),
    (0x01, 0x5F09): (0x00, "after the $D2C0 WriteBgPalette7FromD3F8 image and before the $D2F0 image ($01:5F0A)"),
    (0x01, 0x659A): (0x00, "after UnusedSceneRamNoOp image ($01:6599, 1 byte)"),
    (0x02, 0x41C3): (0xD9, "after StatHandlerReti image ($02:41C2, 1 byte) and before the $C7F1 image ($02:41C4)"),
}
ASSERT_LINE = re.compile(r"^(STATIC_)?ASSERT\b", re.I)
SM83 = set("adc add and bit call ccf cp cpl daa dec di ei halt inc jp jr ld ldh ldi ldd nop or pop push res ret "
           "reti rl rla rlc rlca rr rra rrc rrca rst sbc scf set sla sra srl stop sub swap xor".split())


class RangeMapError(ValueError):
    pass


def check(cond, msg):
    if not cond:
        raise RangeMapError(msg)


def strip(line: str) -> str:
    out, q = [], False
    for ch in line:
        if ch == '"':
            q = not q
        if ch == ";" and not q:
            break
        out.append(ch)
    return "".join(out).strip()


def macro_kinds(root: pathlib.Path) -> dict:
    """Classify every macro by what its body emits."""
    kinds = {}
    for p in sorted(list((root / "include").glob("*.inc")) + list((root / "src").glob("*.asm"))):
        text = p.read_text()
        for m in re.finditer(r"^MACRO\s+(\w+)(.*?)^\s*ENDM", text, re.M | re.S):
            ops = set()
            for line in m.group(2).split("\n")[1:]:
                s = strip(line)
                s = re.sub(r"^[A-Za-z_.][A-Za-z0-9_.]*:+\s*", "", s)
                if not s or DIRECTIVE.match(s):
                    continue
                ops.add(s.split()[0].lower())
            if ops & {"incbin"}:
                kinds[m.group(1)] = "asset"
            elif ops - {"db", "dw", "dl", "ds"} and not ops <= {"db", "dw", "dl", "ds"}:
                code = {o for o in ops if o not in ("db", "dw", "dl", "ds")}
                known_macros = set(kinds)
                kinds[m.group(1)] = "code" if code - known_macros else "data"
            elif ops == {"ds"}:
                kinds[m.group(1)] = "fill"
            else:
                kinds[m.group(1)] = "data"
    return kinds


def kind_of(stmt: str, macros: dict):
    s = re.sub(r"^[A-Za-z_.][A-Za-z0-9_.]*:+\s*", "", stmt)
    if not s:
        return None
    word = s.split()[0]
    lw = word.lower()
    if lw in ("load", "endl"):
        return lw
    if DIRECTIVE.match(s):
        return None
    if lw in ("db", "dw", "dl"):
        return "data"
    if lw == "ds":
        return "fill"
    if lw == "incbin":
        return "asset"
    if word in macros:
        return macros[word]
    return "code"


def source_files(root: pathlib.Path):
    """(bank, path) for every bank file and the files it INCLUDEs."""
    main = (root / "src" / "main.asm").read_text()
    out = []
    for inc in re.findall(r'^INCLUDE "(src/bank_([0-9A-F]{2})\.asm)"', main, re.M):
        b = int(inc[1], 16)
        out.append((b, inc[0]))
        stack = [inc[0]]
        while stack:
            for sub in re.findall(r'^\s*INCLUDE "(src/[^"]+)"', (root / stack.pop()).read_text(), re.M):
                out.append((b, sub))
                stack.append(sub)
    return out


def instrument(t: pathlib.Path, files, macros):
    meta = {}     # id -> (bank, file, line, kind, label)
    for fi, (b, rel) in enumerate(files):
        p = t / rel
        lines = p.read_text().split("\n")
        out, depth, label, block_first = [], 0, None, None
        group, aliases = [], ()
        prev_label_line = False
        tail = None    # (statements left, label and aliases to restore)
        for n, raw in enumerate(lines, 1):
            stmt = strip(raw)
            if re.match(r"^MACRO\b", stmt) or re.match(r"^\w+:?\s+MACRO\b", stmt):
                depth += 1
            m = LABEL_DEF.match(stmt) if depth == 0 else None
            if m and not m.group(1).startswith(".") and not (m.group(1).startswith("Jump_") and label):
                if not prev_label_line:
                    if m.group(1) in TAIL_SCOPE:
                        tail = [TAIL_SCOPE[m.group(1)][0], label, aliases]
                    else:
                        tail = None
                    block_first = m.group(1)
                    group = []
                elif AUTO.search(block_first) and not AUTO.search(m.group(1)):
                    block_first = m.group(1)   # prefer the reviewed companion name
                group.append(m.group(1))
                label, aliases = block_first, tuple(sorted(group))
                prev_label_line = True
            elif stmt:
                prev_label_line = False
            k = kind_of(stmt, macros) if depth == 0 and stmt else None
            if k is not None:
                if tail is not None and k not in ("load", "endl"):
                    if tail[0] == 0:
                        label, aliases, tail = tail[1], tail[2], None
                    else:
                        tail[0] -= 1
                ident = fi * 100000 + n
                out.append(f'\tPRINTLN STRFMT("@R {ident} %d", @)')
                meta[ident] = (b, rel, n, k, label, aliases)
                mi = re.match(r'^(?:[A-Za-z_.][A-Za-z0-9_.]*:+\s*)?INCBIN\s+"([^"]+)"\s*(?:,\s*(\d+)\s*(?:,\s*(\d+))?)?$', stmt)
                if mi:
                    INCBINS[ident] = (mi.group(1), int(mi.group(2) or 0), None if mi.group(3) is None else int(mi.group(3)))
            out.append(raw)
            if depth and re.match(r"^ENDM\b", stmt):
                depth -= 1
        if rel.startswith("src/bank_"):
            ident = fi * 100000 + 99999
            out.append(f'\tPRINTLN STRFMT("@R {ident} %d", @)')
            meta[ident] = (b, rel, len(lines) + 1, "end", None, ())
        p.write_text("\n".join(out))
    return meta


ROOT_FOR_CHECK = [ROOT]
DIRECT = []    # (bank, start, end, path, offset, length) of every direct INCBIN in the build
RANGE_FIRST_AT = {}   # label -> (bank, address) of the last ranges_from run
INCBINS = {}   # statement id -> (path, offset, length) for direct INCBIN statements


def references(root: pathlib.Path):
    """(label -> set of owner labels whose statements mention it, labels reached by fall-through).

    A label mentioned inside
    its own block counts only when code falls through into it from a preceding
    instruction, so it is an internal label of a routine entered elsewhere (w20 C11)."""
    defs = set()
    texts = {}
    for p in sorted((root / "src").glob("*.asm")):
        t = p.read_text()
        texts[p] = t
        defs |= set(re.findall(r"^([A-Za-z_][A-Za-z0-9_]*):", t, re.M))
    refs = collections.defaultdict(set)
    word = re.compile(r"\b([A-Za-z_][A-Za-z0-9_]*)\b")
    fall = set()
    loads = []        # [WRAM address, ROM image label, first label inside the LOAD block]
    numeric = collections.defaultdict(set)   # address -> owners of jp/call $address
    calls = collections.defaultdict(set)     # label -> owners that jp/call it
    for p, t in texts.items():
        owner, prev = None, None
        for raw in t.split("\n"):
            s = strip(raw)
            m = LABEL_DEF.match(s)
            if m:
                owner = m.group(1)
                s = s[m.end():].strip()
                if prev is not None:
                    fall.add(owner)
                if loads and loads[-1][2] is None:
                    loads[-1][2] = owner
            if not s:
                continue
            ml = re.match(r"^LOAD\b.*\bWRAM[0X]\[\$([0-9A-Fa-f]{4})\]", s, re.I)
            if ml:
                loads.append([int(ml.group(1), 16), owner, None])
            mj = re.match(r"^(?:jp|call)\s+(?:(?:n?z|n?c)\s*,\s*)?(\$[0-9A-Fa-f]{4}|[A-Za-z_]\w*)$", s, re.I)
            if mj:
                tgt = mj.group(1)
                if tgt.startswith("$"):
                    numeric[int(tgt[1:], 16)].add(owner or p.name)
                else:
                    calls[tgt].add(owner or p.name)
            ws = s.split()
            op = ws[0].lower()
            if op in SM83:
                ends = op in ("ret", "reti") and len(ws) == 1 or op in ("jp", "jr") and "," not in s
                prev = None if ends else s
            else:
                prev = None
            # ASSERT lines are layout checks, not readers. Blocks read only through computed
            # addresses are credited explicitly by COMPUTED_READS instead.
            if ASSERT_LINE.match(s):
                continue
            for w in word.findall(s):
                if w in defs and (w != owner or w in fall):
                    refs[w].add(owner or p.name)
    for addr, image, entry in loads:
        if entry is None or image is None:
            continue
        copiers = refs.get(image, set()) - {image}
        if numeric.get(addr) and copiers:
            # entered through a numeric vector jump after the image is copied to WRAM
            refs[entry] |= numeric[addr] | copiers
        if calls.get(image):
            # the ROM image itself is called (original defect at WriteBgPalette7FromD3F8)
            refs[entry] |= calls[image]
    return refs, fall


def readers_of(refs, fall, aliases, members=INDEXED_MEMBERS):
    """Readers of a label group: references to any alias, plus indexed-table bases."""
    out = set()
    for a in aliases:
        for r in refs.get(a, ()):
            if r not in aliases or a in fall:
                out.add(r)
    return out


def traced_fallthrough_labels(fall, stmts, code_offsets):
    """Keep syntactic fall-through entries only when tracing reaches them."""
    traced = set()
    for b, s, _e, _kind, label, _rel, _n, aliases in stmts:
        if off(b, s) in code_offsets:
            traced.add(label)
            traced.update(aliases)
    return fall & traced


def build(root: pathlib.Path, rom: bytes):
    macros = macro_kinds(root)
    files = source_files(root)
    with tempfile.TemporaryDirectory() as tmp:
        t = pathlib.Path(tmp)
        for d in ("src", "include", "assets"):
            shutil.copytree(root / d, t / d)
        meta = instrument(t, files, macros)
        r = subprocess.run(["rgbasm", "-o", "x.o", "src/main.asm"], cwd=t, capture_output=True, text=True)
        check(r.returncode == 0, "range map: instrumented assembly failed: " + r.stderr[-400:])
        # the real build, for the byte comparison
        shutil.rmtree(t / "src")
        shutil.copytree(root / "src", t / "src")
        r2 = subprocess.run(["rgbasm", "-o", "y.o", "src/main.asm"], cwd=t, capture_output=True, text=True)
        check(r2.returncode == 0, "range map: assembly failed")
        r3 = subprocess.run(["rgblink", "-p", "0xFF", "-o", "y.gbc", "y.o"], cwd=t, capture_output=True, text=True)
        check(r3.returncode == 0, "range map: link failed")
        built = (t / "y.gbc").read_bytes()
    check(built == rom, "range map: the source no longer assembles to baserom.gbc")
    prints = []
    for line in r.stdout.splitlines():
        m = re.fullmatch(r"@R (\d+) (-?\d+)", line.strip())
        if m:
            prints.append((int(m.group(1)), int(m.group(2))))
    sys.path.insert(0, str(root / "tools"))
    import hints  # noqa: E402
    import rom_trace as trace  # noqa: E402
    traced = trace.run(rom, hints.extra_entries(rom), getattr(hints, "DATA_RANGES", None))
    code_offsets = set()
    for o, ln in traced.code.items():
        code_offsets.update(range(o, o + ln))
    stmts = []
    by_bank = collections.defaultdict(list)
    for ident, addr in prints:
        by_bank[meta[ident][0]].append((ident, addr))
    for b, seq in by_bank.items():
        in_load, ram0, rom0 = False, None, None
        for i, (ident, addr) in enumerate(seq[:-1]):
            _, rel, n, kind, label, aliases = meta[ident]
            nxt = seq[i + 1][1]
            if kind == "load":
                in_load, rom0, ram0 = True, addr, None
                continue
            if kind == "endl":
                in_load = False
                continue
            if in_load:
                if ram0 is None:
                    ram0 = addr
                start, end = rom0 + addr - ram0, rom0 + nxt - ram0
                kind = "ram code" if kind == "code" else "ram data"
            else:
                start, end = addr, nxt
            if end > start:
                stmts.append((b, start, end, kind, label, rel, n, aliases))
                if ident in INCBINS:
                    DIRECT.append((b, start, end) + INCBINS[ident])
    return stmts, code_offsets


def off(b, a):
    return a if b == 0 else b * 0x4000 + a - 0x4000


def assets(root: pathlib.Path):
    out = []
    for line in (root / "assets.txt").read_text().split("\n"):
        if line.strip() and not line.lstrip().startswith("#"):
            path, o, n = line.split()
            out.append((path, int(o, 16), int(n, 16)))
    return out


def ranges_from(root, rom, stmts, code_offsets):
    asset_list = assets(root)
    asset_at = {}
    for b, s, e, path, _, _ in DIRECT:
        for a in range(s, e):
            asset_at[off(b, a)] = path
    for path, o, n in asset_list:
        for x in range(o, o + n):
            asset_at[x] = path
    refs, fall = references(root)
    # A syntactic fall-through edge establishes a reader only when tracing also
    # reaches the destination label. This prevents an internal loop in a dead
    # routine from making its own data/code look externally reached.
    fall = traced_fallthrough_labels(fall, stmts, code_offsets)
    recs = []
    for b, s, e, kind, label, rel, n, aliases in sorted(stmts):
        # split code by traced status and data by asset membership
        cur = None
        for a in range(s, e):
            o = off(b, a)
            k = kind
            if kind in ("code",):
                k = "code" if o in code_offsets else "code untraced"
            if (b != 0 and a == 0x7FFF) and kind in ("fill", "data"):
                k = "marker"
            ap = asset_at.get(o)
            key = (k, ap)
            if cur and cur[0] == key and cur[2] == a:
                cur[2] = a + 1
            else:
                if cur:
                    recs.append((b, cur[1], cur[2], cur[0][0], label, rel, n, cur[0][1], aliases))
                cur = [key, a, a + 1]
        if cur:
            recs.append((b, cur[1], cur[2], cur[0][0], label, rel, n, cur[0][1], aliases))
    merged = []
    for r in recs:
        if merged:
            p = merged[-1]
            if p[0] == r[0] and p[2] == r[1] and p[3] == r[3] and p[4] == r[4] and p[7] == r[7] and p[8] == r[8]:
                merged[-1] = (p[0], p[1], r[2], p[3], p[4], p[5], p[6], p[7], p[8])
                continue
        merged.append(r)
    group_readers = {}
    first_at = {}
    for b, s, e, kind, label, rel, n, ap, aliases in merged:
        for a in aliases:
            first_at.setdefault(a, (b, s))
        group_readers[label] = readers_of(refs, fall, aliases or (label,))
    bodies = routine_bodies(root, {v[1] for v in INDEXED_MEMBERS.values()})
    RANGE_FIRST_AT.clear()
    RANGE_FIRST_AT.update(first_at)
    indexed = check_indexed(INDEXED_MEMBERS, first_at, group_readers, bodies)
    computed = check_computed(COMPUTED_READS, first_at, refs)
    out = []
    for b, s, e, kind, label, rel, n, ap, aliases in merged:
        lab = label or ""
        readers = sorted(readers_of(refs, fall, aliases or (lab,)) | indexed.get(lab, set())
                         | computed.get(lab, set()))
        if kind in ("fill", "marker"):
            und, ev = "padding", "layout"
        elif (NEUTRAL.search(lab) and not TRAILER.search(lab)) or not lab:
            und = "neutral"
        else:
            und = "named"
        if kind == "code":
            ev = "traced"
        elif kind == "code untraced":
            ev = "untraced"
        elif kind in ("ram code", "ram data"):
            ev = "referenced" if readers else "unreferenced"
        elif kind not in ("fill", "marker"):
            ev = "referenced" if readers else "unreferenced"
        flags = []
        sep = (b, s) in SEPARATORS
        if sep:
            ev, readers = "layout", []
            flags.append("separator")
        if kind in ("fill", "marker"):
            flags.append("padding")
        if not sep and (UNUSED.search(lab) or (ev == "unreferenced" and kind not in ("fill", "marker"))):
            flags.append("unused")
        if kind == "code untraced":
            flags.append("unreachable")
        if DUPLICATED.search(lab) or "bank04_copy" in lab.lower():
            flags.append("duplicated")
        if RESIDUE.search(lab) or (ap and "residue" in ap):
            flags.append("residue")
        if kind == "ram code":
            flags.append("runtime code")
        data = rom[off(b, s):off(b, e)]
        out.append({"bank": b, "start": s, "end": e, "kind": kind, "label": lab, "source": f"{rel}:{n}",
                    "asset": ap, "readers": readers[:8], "reader_count": len(readers), "understanding": und,
                    "evidence": ev, "flags": flags, "sha1": hashlib.sha1(data).hexdigest()[:12]})
    return out, asset_list


def routine_bodies(root, names):
    """name -> normalized statements from its label to the next label that is not name_*."""
    out = {}
    for p in sorted((root / "src").glob("*.asm")):
        cur = None
        for raw in p.read_text().split("\n"):
            s = strip(raw)
            m = LABEL_DEF.match(s)
            if m:
                if cur and not m.group(1).startswith(cur + "_"):
                    cur = None
                if m.group(1) in names:
                    cur = m.group(1)
                    out[cur] = []
                s = s[m.end():].strip()
            if cur and s:
                out[cur].append(re.sub(r"\s+", " ", re.sub(r"\s*,\s*", ", ", s)).lower())
    return out


def code_derives(body, base, origin, stride):
    """True when the reader's code builds base + origin + index * stride."""
    def adds(n):
        return any(body[i] == f"ld a, ${n:02x}" and body[i + 1] == "add a, l" for i in range(len(body) - 1))
    lb = f"ld hl, {base.lower()}"
    if lb in body:
        i = body.index(lb)
        k = stride.bit_length() - 1
        return (origin == 0 and stride == 1 << k and k > 0 and i >= k
                and body[i - k:i] == ["add a, a"] * k and (i < k + 1 or body[i - k - 1] != "add a, a"))
    return (origin == 0 or adds(origin)) and adds(stride) and origin != stride


def check_indexed(members, first_at, group_readers, bodies):
    """label -> {"indexed via <base>"}; every allowlist entry must satisfy its conditions."""
    out = {}
    for member, (base, reader, origin, stride, field, count, _why) in sorted(members.items()):
        check(member in first_at, f"range map: indexed member {member} is not a range label")
        check(base in first_at, f"range map: indexed base {base} of {member} is not a range label")
        (mb, ma), (bb, ba) = first_at[member], first_at[base]
        check(mb == bb and 0 < ma - ba <= MAX_INDEXED_SPAN,
              f"range map: indexed member {member} is not within {MAX_INDEXED_SPAN} bytes after {base}")
        check(group_readers.get(base), f"range map: indexed base {base} of {member} has no reader")
        rel = ma - ba - origin - field
        check(stride > 0 and rel >= 0 and rel % stride == 0,
              f"range map: indexed member {member} is not a whole stride {stride} from {base}+{origin}+{field}")
        check(rel // stride < count, f"range map: indexed member {member} is index {rel // stride}, past count {count}")
        check(reader in bodies and code_derives(bodies[reader], base, origin, stride),
              f"range map: reader {reader} does not derive {base}+{origin}+n*{stride} for {member}")
        out[member] = {f"indexed via {base}"}
    return out


def check_computed(computed, first_at, refs):
    """label -> {"computed by <reader>"}; the reader must name the anchor in its own code."""
    out = {}
    for label, (reader, anchor, _why) in sorted(computed.items()):
        check(label in first_at, f"range map: computed-read label {label} is not a range label")
        check(reader in first_at, f"range map: computed reader {reader} of {label} is not a range label")
        check(reader in refs.get(anchor, ()), f"range map: computed reader {reader} does not read anchor {anchor} for {label}")
        out[label] = {f"computed by {reader}"}
    return out


def check_tails(out, tails=TAIL_SCOPE):
    size = collections.Counter()
    for r in out:
        if r["label"] in tails:
            size[r["label"]] += r["end"] - r["start"]
    for label, (_n, want, _why) in sorted(tails.items()):
        check(size.get(label) == want, f"range map: tail {label} covers {size.get(label, 0)} bytes, expected {want}")


def check_separators(out, rom, seps=SEPARATORS):
    prev = {}
    at = {}
    for i, r in enumerate(out):
        at[(r["bank"], r["start"])] = r
        if i:
            prev[(r["bank"], r["start"])] = out[i - 1]
    for (b, a), (byte, _why) in sorted(seps.items()):
        r = at.get((b, a))
        check(r is not None and r["end"] - r["start"] == 1 and r["kind"] == "data",
              f"range map: separator ${b:02X}:{a:04X} is not a 1-byte data range")
        check(rom[off(b, a)] == byte, f"range map: separator ${b:02X}:{a:04X} is not ${byte:02X}")
        p = prev.get((b, a))
        check(p is not None and p["bank"] == b and p["kind"] in ("ram code", "ram data"),
              f"range map: separator ${b:02X}:{a:04X} does not follow a RAM image")


def check_incbins(root, asset_list, direct):
    """Every literal INCBIN path is listed in assets.txt or covered exactly once by its slices."""
    listed = {p for p, _, _ in asset_list}
    slices = collections.defaultdict(list)
    for b, s, e, path, o, n in direct:
        slices[path].append((o, o + (e - s)))
    for path in sorted(incbin_paths(root)):
        if path in listed:
            continue
        f = root / path
        check(f.exists(), f"range map: missing asset {path}")
        size = len(f.read_bytes())
        pos = 0
        for lo, hi in sorted(slices.get(path, [])):
            check(lo == pos, f"range map: INCBIN {path} is neither in assets.txt nor covered exactly once "
                             f"by slices (at byte {pos})")
            pos = hi
        check(pos == size, f"range map: INCBIN {path} is neither in assets.txt nor covered exactly once "
                           f"by slices (ends at {pos} of {size})")


def check_ranges(out, rom, asset_list, incbins):
    by_bank = collections.defaultdict(list)
    for r in out:
        by_bank[r["bank"]].append(r)
    check(sorted(by_bank) == list(range(64)), f"range map: banks covered {sorted(by_bank)[:3]}... not all 64")
    for b, rs in by_bank.items():
        lo, hi = (0, 0x4000) if b == 0 else (0x4000, 0x8000)
        pos = lo
        for r in sorted(rs, key=lambda r: r["start"]):
            check(r["start"] >= pos, f"range map: overlap in bank ${b:02X} at ${r['start']:04X}")
            check(r["start"] == pos, f"range map: gap in bank ${b:02X} at ${pos:04X}-${r['start']:04X}")
            check(r["end"] <= hi, f"range map: bank ${b:02X} range runs past the bank")
            pos = r["end"]
        check(pos == hi, f"range map: gap at the end of bank ${b:02X}")
    for r in out:
        b = r["bank"]
        data = rom[off(b, r["start"]):off(b, r["end"])]
        check(hashlib.sha1(data).hexdigest()[:12] == r["sha1"],
              f"range map: ${b:02X}:{r['start']:04X} {r['label']} no longer matches its source bytes")
    covered = collections.defaultdict(int)
    for r in out:
        if r["asset"]:
            covered[r["asset"]] += r["end"] - r["start"]
    for path, o, n in asset_list:
        check(covered.get(path, 0) == n, f"range map: asset {path} is not fully inside source ranges")
    for b, s, e, path, o, n in incbins:
        f = ROOT_FOR_CHECK[0] / path
        check(f.exists(), f"range map: missing asset {path}")
        d = f.read_bytes()
        want = d[o:] if n is None else d[o:o + n]
        check(want == rom[off(b, s):off(b, e)], f"range map: INCBIN {path} at ${b:02X}:{s:04X} differs from its slice")


def check_assets(root, rom, asset_list):
    for path, o, n in asset_list:
        f = root / path
        check(f.exists(), f"range map: missing asset {path}")
        d = f.read_bytes()
        check(len(d) == n, f"range map: asset {path} has size {len(d)}, expected {n}")
        check(d == rom[o:o + n], f"range map: asset {path} differs from ROM ${o:X}")


def incbin_paths(root):
    out = set()
    for p in list((root / "src").glob("*.asm")) + list((root / "include").glob("*.inc")):
        for m in re.finditer(r'^\s*INCBIN\s+"([^"]+)"', p.read_text(), re.M):
            if "\\" not in m.group(1):
                out.add(m.group(1))
    return out


def inventory(out):
    """Unresolved inventory derived from the range records (not from prose)."""
    inv = collections.defaultdict(lambda: {"ranges": 0, "bytes": 0, "labels": set()})
    for r in out:
        reasons = []
        if r["understanding"] == "neutral":
            reasons.append("neutral label")
        if r["kind"] == "code untraced":
            reasons.append("untraced code")
        if "unused" in r["flags"] and r["kind"] not in ("fill", "marker"):
            reasons.append("no reader")
        for why in reasons:
            k = (r["bank"], why)
            inv[k]["ranges"] += 1
            inv[k]["bytes"] += r["end"] - r["start"]
            if len(inv[k]["labels"]) < 40:
                inv[k]["labels"].add(r["label"] or f"${r['start']:04X}")
    rows = [{"bank": f"${b:02X}", "reason": why, "ranges": v["ranges"], "bytes": v["bytes"],
             "examples": sorted(v["labels"])} for (b, why), v in sorted(inv.items())]
    return rows


def summary(out):
    s = collections.defaultdict(int)
    for r in out:
        s[f"{r['kind']}|{r['understanding']}|{r['evidence']}"] += r["end"] - r["start"]
    return dict(sorted(s.items()))


def compact(out):
    keys = ["bank", "start", "end", "kind", "label", "source", "asset", "readers", "reader_count",
            "understanding", "evidence", "flags", "sha1"]
    return {"columns": keys, "rows": [[r[k] for k in keys] for r in out]}


def run(root, rom, write=False, negative=True):
    stmts, code = build(root, rom)
    out, asset_list = ranges_from(root, rom, stmts, code)
    check_assets(root, rom, asset_list)
    ROOT_FOR_CHECK[0] = root
    check_ranges(out, rom, asset_list, list(DIRECT))
    check_incbins(root, asset_list, list(DIRECT))
    check_tails(out)
    check_separators(out, rom)
    report = {"summary": summary(out), "ranges": compact(out)}
    inv = {"derived_from": REPORT, "rows": inventory(out)}
    for rel, value in ((REPORT, report), (INVENTORY, inv)):
        text = json.dumps(value, indent=None, sort_keys=True, separators=(",", ":")) + "\n"
        p = root / rel
        if write:
            p.write_text(text)
        check(p.exists() and p.read_text() == text, f"range map: {rel} is stale; rerun tools/rom_range_map.py --write")
    neg = negative_tests(root, rom, out, asset_list) if negative else 0
    return out, neg


def negative_tests(root, rom, out, asset_list):
    import copy
    n = 0
    incb = list(DIRECT)
    cases = []
    gap = copy.deepcopy(out)
    del gap[len(gap) // 2]
    cases.append(("gap", gap, rom, "gap in bank"))
    ov = copy.deepcopy(out)
    ov[10]["end"] += 1
    ov[11]["start"] += 0  # next range now overlaps
    cases.append(("overlap", ov, rom, "overlap in bank"))
    st = copy.deepcopy(out)
    st[5]["sha1"] = "000000000000"
    cases.append(("stale range bytes", st, rom, "no longer matches"))
    bad = bytearray(rom)
    r = next(x for x in out if x["kind"] == "data" and x["bank"] == 5)
    bad[off(5, r["start"])] ^= 0xFF
    cases.append(("ROM differs from source", out, bytes(bad), "no longer matches"))
    for name, recs, data, expect in cases:
        try:
            check_ranges(recs, data, asset_list, incb)
        except RangeMapError as exc:
            check(expect in str(exc), f"range map negative test {name}: wrong reason: {exc}")
            n += 1
        else:
            raise RangeMapError(f"range map negative test not rejected: {name}")
    try:
        b, s, e, path, o, ln = incb[0]
        check_ranges(out, rom, asset_list, [(b, s, e, path, o + 1, ln)] + incb[1:])
    except RangeMapError as exc:
        check("differs from its slice" in str(exc), f"range map negative test INCBIN slice: {exc}")
        n += 1
    else:
        raise RangeMapError("range map negative test not rejected: INCBIN slice")
    first_at = {"Base": (1, 0x4000), "Member": (1, 0x4008), "Far": (1, 0x4100), "Other": (2, 0x4008),
                "Odd": (1, 0x4006), "Late": (1, 0x4020)}
    readers = {"Base": {"Caller"}, "Member": set(), "Far": set(), "Other": set()}
    bodies = {"R": ["add a, a", "add a, a", "add a, a", "ld hl, base", "add a, l"],
              "R4": ["add a, a", "add a, a", "ld hl, base", "add a, l"],
              "W": ["ld a, $05", "add a, l", "ld a, $10", "add a, l"]}

    def ent(base, reader="R", origin=0, stride=8, field=0, count=3):
        return (base, reader, origin, stride, field, count, "")
    check(check_indexed({"Member": ent("Base")}, first_at, readers, bodies) == {"Member": {"indexed via Base"}},
          "range map negative test: valid indexed control entry rejected")
    for name, members, rd, expect in (
            ("indexed base without reader", {"Member": ent("Base")}, {"Base": set()}, "has no reader"),
            ("indexed member too far", {"Far": ent("Base")}, readers, "is not within"),
            ("indexed member in another bank", {"Other": ent("Base")}, readers, "is not within"),
            ("indexed member before base", {"Base": ent("Member")}, {"Member": {"Caller"}}, "is not within"),
            ("indexed member missing", {"Absent": ent("Base")}, readers, "is not a range label"),
            ("indexed member off stride", {"Odd": ent("Base")}, readers, "is not a whole stride"),
            ("indexed member past count", {"Late": ent("Base")}, readers, "past count"),
            ("indexed stride not in reader code", {"Member": ent("Base", "R4")}, readers, "does not derive"),
            ("indexed reader names another base", {"Member": ent("Base", "W")}, readers, "does not derive"),
            ("indexed reader missing", {"Member": ent("Base", "Nobody")}, readers, "does not derive")):
        try:
            check_indexed(members, first_at, rd, bodies)
        except RangeMapError as exc:
            check(expect in str(exc), f"range map negative test {name}: wrong reason: {exc}")
            n += 1
        else:
            raise RangeMapError(f"range map negative test not rejected: {name}")
    # the real SkillMediumText assigned to the wrong table must fail (v103)
    real_first = {k: v for k, v in RANGE_FIRST_AT.items()}
    wrong = {"SkillMediumText": ("ControlTypeTexts", "DrawOptionsEntryValue_CheckControlType", 0, 8, 0, 3, "")}
    try:
        check_indexed(wrong, real_first, {"ControlTypeTexts": {"x"}},
                      routine_bodies(root, {"DrawOptionsEntryValue_CheckControlType"}))
    except RangeMapError as exc:
        check("past count" in str(exc), f"range map negative test SkillMediumText via ControlTypeTexts: {exc}")
        n += 1
    else:
        raise RangeMapError("range map negative test not rejected: SkillMediumText via ControlTypeTexts")
    refs_c = {"Anchor": {"Reader"}}
    fa = {"Tiles": (8, 0x4000), "Reader": (0, 0x100)}
    for name, comp, expect in (
            ("computed reader does not read anchor", {"Tiles": ("Reader", "Other", "")}, "does not read anchor"),
            ("computed label missing", {"Absent": ("Reader", "Anchor", "")}, "is not a range label"),
            ("computed reader missing", {"Tiles": ("Ghost", "Anchor", "")}, "is not a range label")):
        try:
            check_computed(comp, fa, refs_c)
        except RangeMapError as exc:
            check(expect in str(exc), f"range map negative test {name}: wrong reason: {exc}")
            n += 1
        else:
            raise RangeMapError(f"range map negative test not rejected: {name}")
    for name, fn, expect in (
            ("tail size", lambda: check_tails(out, {"SoundPatch00UnreadTail": (1, 3, "")}), "expected 3"),
            ("tail absent", lambda: check_tails(out, {"NoSuchTail": (1, 2, "")}), "covers 0 bytes"),
            ("separator wrong byte", lambda: check_separators(out, rom, {(2, 0x41C3): (0x00, "")}), "is not $00"),
            ("separator not 1 byte", lambda: check_separators(out, rom, {(1, 0x4000): (rom[0x4000], "")}),
             "not a 1-byte data range"),
            ("INCBIN slice dropped", lambda: check_incbins(root, asset_list,
                                                           [d for d in incb if d[3] != "assets/bank_08/effect_tiles.bin"
                                                            or d[4] != 112]), "covered exactly once"),
            ("INCBIN slice duplicated", lambda: check_incbins(root, asset_list, incb + [
                next(d for d in incb if d[3] == "assets/bank_08/object_animation_tiles.bin")]),
             "covered exactly once")):
        try:
            fn()
        except RangeMapError as exc:
            check(expect in str(exc), f"range map negative test {name}: wrong reason: {exc}")
            n += 1
        else:
            raise RangeMapError(f"range map negative test not rejected: {name}")
    with tempfile.TemporaryDirectory() as tmp:
        t = pathlib.Path(tmp)
        (t / "src").mkdir()
        (t / "src" / "a.asm").write_text("\n".join([
            "Vec:", "\tjp $C729", "Vec2:", "\tjp $C900", "Install:", "\tld hl, ImgA", "\tld hl, ImgB", "\tret",
            "ImgA:", '\tLOAD UNION "a", WRAM0[$C729]', "HandlerA:", "\treti", "\tENDL",
            "ImgB:", '\tLOAD UNION "b", WRAM0[$C800]', "HandlerB:", "\treti", "\tENDL",
            "ImgC:", '\tLOAD UNION "c", WRAM0[$C900]', "HandlerC:", "\treti", "\tENDL",
            "Lonely:", "\tdb 0", "Other:", "\tASSERT Lonely == $4000", "\tret", ""]))
        rr, _ = references(t)
        check(rr.get("HandlerA") == {"Vec", "Install"}, f"range map negative test: vector+copy not credited {rr.get('HandlerA')}")
        check(not rr.get("HandlerB"), "range map negative test: copied image without vector credited")
        check(not rr.get("HandlerC"), "range map negative test: vector to an image never copied credited")
        check(not rr.get("Lonely"), "range map negative test: ASSERT counted as reader")
        n += 1
    # self-reference without fall-through, and a reference only from the alias group itself
    refs = {"Loop": {"Loop"}, "Entry": {"Alias"}, "Alias": set()}
    check(not readers_of(refs, set(), ("Loop",)), "range map negative test: self-loop counted as reader")
    check(not readers_of(refs, set(), ("Alias", "Entry")), "range map negative test: alias self-reference counted")
    check(readers_of(refs, {"Loop"}, ("Loop",)) == {"Loop"}, "range map negative test: fall-through loop not counted")
    synthetic_stmts = [
        (1, 0x4000, 0x4001, "code", "Live", "src/a.asm", 1, ("LiveAlias",)),
        (1, 0x4010, 0x4011, "code", "Dead", "src/a.asm", 1, ("DeadAlias",)),
    ]
    check(traced_fallthrough_labels({"Live", "LiveAlias", "Dead", "DeadAlias"}, synthetic_stmts,
                                    {off(1, 0x4000)}) == {"Live", "LiveAlias"},
          "range map negative test: untraced fall-through entry retained")
    n += 1
    with tempfile.TemporaryDirectory() as tmp:
        t = pathlib.Path(tmp)
        shutil.copytree(root / "assets", t / "assets")
        shutil.copy(root / "assets.txt", t / "assets.txt")
        victim = asset_list[0][0]
        (t / victim).unlink()
        try:
            check_assets(t, rom, asset_list)
        except RangeMapError as exc:
            check("missing asset" in str(exc), f"range map negative test missing asset: {exc}")
            n += 1
        else:
            raise RangeMapError("range map negative test not rejected: missing asset")
    return n


def main():
    rom = (ROOT / "baserom.gbc").read_bytes()
    out, neg = run(ROOT, rom, write="--write" in sys.argv, negative="--no-negative" not in sys.argv)
    total = sum(r["end"] - r["start"] for r in out)
    und = collections.Counter()
    for r in out:
        und[r["understanding"]] += r["end"] - r["start"]
    print(f"rom range map: {len(out)} ranges, {total} bytes in 64 banks, no gaps or overlaps; "
          + ", ".join(f"{k} {v}" for k, v in sorted(und.items())) + f"; {neg} negative tests rejected")


if __name__ == "__main__":
    main()
