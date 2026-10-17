#!/usr/bin/env python3
"""Apply reviewed label renames to src/bank_01.asm-src/bank_05.asm.

Input: a JSON list of {"old": label, "new": label, "evidence": text}.
For each entry the label definition must exist exactly once in banks
$01-$05. Every whole-word use inside those five files is renamed. When the
old name is still used anywhere else in the project (other source files,
tools, reports), a legacy alias `Old:` is kept on the line after the new
definition so those users keep resolving to the same address.

This tool edits reviewed source; it is not a generator and owns nothing.
Usage: apply_renames_01_05.py RENAMES.json [--dry-run]
"""
from __future__ import annotations

import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SCOPE = [ROOT / "src" / f"bank_{b:02X}.asm" for b in range(1, 6)]
LABEL = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


def external_users(name: str) -> list[str]:
    users = []
    pat = re.compile(rf"\b{re.escape(name)}\b")
    for p in list((ROOT / "src").glob("*.asm")) + list((ROOT / "include").glob("*.inc")) + \
            list((ROOT / "tools").glob("*.py")) + list(ROOT.glob("reports/*.json")):
        if p in SCOPE or p.name == pathlib.Path(__file__).name:
            continue
        if pat.search(p.read_text(errors="replace")):
            users.append(str(p.relative_to(ROOT)))
    return users


def all_labels() -> set[str]:
    names = set()
    for p in list((ROOT / "src").glob("*.asm")) + list((ROOT / "include").glob("*.inc")):
        for m in re.finditer(r"^([A-Za-z_][A-Za-z0-9_]*):", p.read_text(), re.M):
            names.add(m.group(1))
        for m in re.finditer(r"^DEF ([A-Za-z_][A-Za-z0-9_]*)", p.read_text(), re.M):
            names.add(m.group(1))
    return names


def main() -> int:
    entries = json.loads(pathlib.Path(sys.argv[1]).read_text())
    dry = "--dry-run" in sys.argv
    texts = {p: p.read_text() for p in SCOPE}
    existing = all_labels()
    log = []
    for e in entries:
        old, new = e["old"], e["new"]
        if not (LABEL.match(old) and LABEL.match(new)) or old == new:
            raise SystemExit(f"bad rename {old} -> {new}")
        if new in existing:
            raise SystemExit(f"{new} already exists")
        defs = [p for p, t in texts.items() if re.search(rf"^{re.escape(old)}:", t, re.M)]
        if len(defs) != 1:
            raise SystemExit(f"{old}: defined {len(defs)} times in banks $01-$05")
        ext = external_users(old)
        pat = re.compile(rf"\b{re.escape(old)}\b")
        for p in SCOPE:
            texts[p] = pat.sub(new, texts[p])
        if ext:
            p = defs[0]
            texts[p] = re.sub(rf"^{re.escape(new)}:(.*)$",
                              lambda m: f"{new}:{m.group(1)}\n{old}: ; legacy alias, used by {', '.join(sorted(set(ext)))[:120]}",
                              texts[p], count=1, flags=re.M)
        existing.add(new)
        log.append(f"{old} -> {new}" + (f" (alias kept: {', '.join(ext)})" if ext else ""))
    if not dry:
        for p, t in texts.items():
            p.write_text(t)
    print("\n".join(log))
    print(f"{len(entries)} renames {'checked' if dry else 'applied'}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
