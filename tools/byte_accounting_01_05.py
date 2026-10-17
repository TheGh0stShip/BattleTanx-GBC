#!/usr/bin/env python3
"""Exact per-byte classification of ROM banks $01-$05.

RGBDS has no listing output, so this tool assembles a scratch copy in which a
`PRINTLN STRFMT(...)` of the current address precedes every top-level source
line of banks $01-$05. That yields an exact source-line -> ROM-range map.
Each byte is then classified by the directive that produced it:

  code (direct)       instruction bytes reached by tools/trace.py
  code (untraced)     instruction bytes the tracer does not reach
  ram code source     instruction bytes inside a LOAD block (RAM-executed)
  ram data source     db/dw bytes inside a LOAD block
  structured data     db/dw/dl and data-record macro bytes outside LOAD blocks
  asset               INCBIN bytes
  fill                ds bytes
  marker              the bank-number byte at $7FFF

Nothing is assembled from baserom.gbc; the ROM is read only to run the tracer.
Usage: byte_accounting_01_05.py [--json OUT]
"""
from __future__ import annotations

import collections
import json
import os
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
BANKS = range(1, 6)
DIRECTIVE = re.compile(r"^\s*(SECTION|INCLUDE|IF|ELIF|ELSE|ENDC|ENDR|ENDM|MACRO|REPT|FOR|DEF|ASSERT|STATIC_ASSERT|"
                       r"PRINT|PRINTLN|EXPORT|PURGE|OPT|PUSHO|POPO|CHARMAP|NEWCHARMAP|SETCHARMAP|ALIGN|UNION|NEXTU|ENDU)\b", re.I)
DATA_OPS = ("db", "dw", "dl")


def strip(line: str) -> str:
    out, q = [], False
    for ch in line:
        if ch == '"':
            q = not q
        if ch == ";" and not q:
            break
        out.append(ch)
    return "".join(out).strip()


def kind_of(stmt: str, data_macros: set) -> str | None:
    if not stmt:
        return None
    s = re.sub(r"^[A-Za-z_.][A-Za-z0-9_.]*:+\s*", "", stmt)
    if not s:
        return None
    word = s.split()[0]
    lw = word.lower()
    if DIRECTIVE.match(s) or lw in ("load", "endl"):
        return lw if lw in ("load", "endl") else None
    if lw in DATA_OPS:
        return "data"
    if lw == "ds":
        return "fill"
    if lw == "incbin":
        return "asset"
    if word in data_macros:
        return "data"
    return "code"


def instrument(root: pathlib.Path):
    """Rewrite banks $01-$05 with address prints; return line metadata."""
    macros = set()
    for p in list((root / "include").glob("*.inc")) + list((root / "src").glob("*.asm")):
        macros |= set(re.findall(r"^MACRO\s+(\w+)", p.read_text(), re.M))
    meta = {}
    files = [(b, root / "src" / f"bank_{b:02X}.asm") for b in BANKS]
    for b, p in list(files):
        for inc in re.findall(r'^\s*INCLUDE "(src/[^"]+)"', p.read_text(), re.M):
            files.append((b, root / inc))
    for fi, (b, p) in enumerate(files):
        FILES[fi] = str(p.relative_to(root))
        lines = p.read_text().split("\n")
        out, depth, info = [], 0, []
        for n, raw in enumerate(lines, 1):
            stmt = strip(raw)
            head = stmt.split()[0].upper() if stmt.split() else ""
            if head in ("MACRO",) or re.match(r"^\w+:?\s*MACRO", stmt):
                depth += 1
            k = kind_of(stmt, macros) if depth == 0 else None
            if k is not None:
                out.append(f'\tPRINTLN STRFMT("@ACC {b} {fi * 100000 + n} %d", @)')
                info.append((fi * 100000 + n, k))
            out.append(raw)
            if head == "ENDM":
                depth -= 1
        if p.name.startswith("bank_"):
            out.append(f'\tPRINTLN STRFMT("@ACC {b} 99999999 %d", @)')
        p.write_text("\n".join(out))
        meta.setdefault(b, {}).update(dict(info))
    return meta, macros


STATEMENTS = []   # (bank, file index, line, rom_start, rom_end, kind, in_load), filled by classify()
FILES = {}        # file index -> path relative to root
LOADS = []        # (bank, file index, line, rom_start) of each LOAD directive


def classify(root: pathlib.Path, rom: bytes):
    with tempfile.TemporaryDirectory() as tmp:
        t = pathlib.Path(tmp)
        for d in ("src", "include", "assets"):
            shutil.copytree(root / d, t / d)
        meta, _ = instrument(t)
        r = subprocess.run(["rgbasm", "-o", "x.o", "src/main.asm"], cwd=t, capture_output=True, text=True)
        if r.returncode:
            raise SystemExit("accounting assembly failed: " + r.stderr[-400:])
    marks = collections.defaultdict(list)
    for line in r.stdout.splitlines():
        m = re.fullmatch(r"@ACC (\d+) (\d+) (-?\d+)", line.strip())
        if m:
            marks[int(m.group(1))].append((int(m.group(2)), int(m.group(3))))
    sys.path.insert(0, str(root / "tools"))
    import hints  # noqa: E402
    import trace  # noqa: E402
    traced = trace.run(rom, hints.extra_entries(rom), getattr(hints, "DATA_RANGES", None))
    code_offsets = set()
    for o, ln in traced.code.items():
        code_offsets.update(range(o, o + ln))
    result = {}
    for b in BANKS:
        cls = [None] * 0x4000
        seq = marks[b]
        rom_pc, load_base = None, None   # load_base = (ram_start, rom_start)
        rows = []
        for i, (n, addr) in enumerate(seq):
            kind = meta[b].get(n, "end")
            rows.append((n, kind, addr))
        # walk statements; track LOAD context to translate RAM addresses
        in_load, ram0, rom0 = False, 0, 0
        for i, (n, kind, addr) in enumerate(rows[:-1]):
            nxt_kind, nxt_addr = rows[i + 1][1], rows[i + 1][2]
            if kind == "load":
                in_load, rom0 = True, addr
                LOADS.append((b, n // 100000, n % 100000, addr))
                ram0 = None
                continue
            if kind == "endl":
                in_load = False
                continue
            if in_load and ram0 is None:
                ram0 = addr
            if nxt_kind == "endl" or nxt_kind == "load" and False:
                pass
            if in_load:
                start = rom0 + (addr - ram0)
                if nxt_kind == "endl":
                    # ENDL itself prints the RAM address after the last statement
                    end = rom0 + (nxt_addr - ram0)
                else:
                    end = rom0 + (nxt_addr - ram0)
                label = "ram code source" if kind == "code" else "ram data source"
            else:
                start, end = addr, nxt_addr
                if nxt_kind == "load":
                    end = nxt_addr
                label = {"code": "code", "data": "structured data", "asset": "asset", "fill": "fill"}.get(kind)
            if label is not None and end >= start:
                STATEMENTS.append((b, n // 100000, n % 100000, start, end, kind, in_load))
            if label is None or end <= start:
                continue
            for a in range(start, end):
                if 0x4000 <= a < 0x8000:
                    off = b * 0x4000 + a - 0x4000
                    c = label
                    if label == "code":
                        c = "code (direct)" if off in code_offsets else "code (untraced)"
                    if a == 0x7FFF and label in ("structured data", "fill"):
                        c = "marker"
                    cls[a - 0x4000] = c
        missing = [i for i, c in enumerate(cls) if c is None]
        result[b] = {"counts": dict(sorted(collections.Counter(cls).items(), key=lambda x: str(x[0]))),
                     "unclassified": len(missing), "first_unclassified": f"${0x4000 + missing[0]:04X}" if missing else None}
    return result


def main() -> int:
    rom = (ROOT / "baserom.gbc").read_bytes()
    res = classify(ROOT, rom)
    for b, r in res.items():
        tot = sum(v for k, v in r["counts"].items() if k is not None)
        print(f"bank ${b:02X}: " + ", ".join(f"{k} {v}" for k, v in r["counts"].items() if k is not None)
              + f" (total {tot}, unclassified {r['unclassified']})")
    if "--json" in sys.argv:
        out = pathlib.Path(sys.argv[sys.argv.index("--json") + 1])
        out.write_text(json.dumps({f"${b:02X}": r for b, r in res.items()}, indent=1, sort_keys=True) + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
