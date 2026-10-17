#!/usr/bin/env python3
"""Apply reviewed names to function entries and branch labels in banks $01/$03.

Input JSON: {"functions": [{"label": "Func_01_XXXX", "name": "NewName"}],
             "locals":    [{"old": "Jump_01_XXXX", "new": "NewName"}]}

Function entries keep their automatic `Func_XX_XXXX` label (used by
`make progress` and by legacy references); the reviewed name is added as a
companion label on the line above. Branch labels are renamed in place; when
the old name is used outside banks $01-$05 the old label stays as an alias.
This is a one-time edit tool; it owns nothing. Usage: add_function_names.py NAMES.json
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SCOPE = [ROOT / "src" / f"bank_{b:02X}.asm" for b in (1, 3)]
LABEL = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


def all_names():
    names = set()
    for p in list((ROOT / "src").glob("*.asm")) + list((ROOT / "include").glob("*.inc")):
        t = p.read_text()
        names |= set(re.findall(r"^([A-Za-z_][A-Za-z0-9_]*):", t, re.M))
        names |= set(re.findall(r"^DEF ([A-Za-z_][A-Za-z0-9_]*)", t, re.M))
    return names


def used_outside(name):
    pat = re.compile(rf"\b{re.escape(name)}\b")
    files = [p for p in (ROOT / "src").glob("*.asm") if p not in SCOPE]
    files += list((ROOT / "include").glob("*.inc")) + list((ROOT / "tools").glob("*.py")) + list(ROOT.glob("reports/*.json"))
    return [str(p.relative_to(ROOT)) for p in files if p.name != pathlib.Path(__file__).name and pat.search(p.read_text())]


def main():
    data = json.loads(pathlib.Path(sys.argv[1]).read_text())
    texts = {p: p.read_text() for p in SCOPE}
    existing = all_names()
    log = []
    for e in data.get("functions", []):
        old, new = e["label"], e["name"]
        assert LABEL.match(new) and new not in existing, new
        hits = [p for p, t in texts.items() if re.search(rf"^{old}:", t, re.M)]
        assert len(hits) == 1, old
        texts[hits[0]] = re.sub(rf"^{old}:", f"{new}:\n{old}:", texts[hits[0]], count=1, flags=re.M)
        existing.add(new)
        log.append(f"{old}: companion {new}")
    for e in data.get("locals", []):
        old, new = e["old"], e["new"]
        assert LABEL.match(new) and new not in existing, new
        hits = [p for p, t in texts.items() if re.search(rf"^{old}:", t, re.M)]
        assert len(hits) == 1, old
        ext = used_outside(old)
        for p in SCOPE:
            texts[p] = re.sub(rf"\b{re.escape(old)}\b", new, texts[p])
        if ext:
            texts[hits[0]] = re.sub(rf"^{new}:", f"{new}:\n{old}: ; legacy alias", texts[hits[0]], count=1, flags=re.M)
        existing.add(new)
        log.append(f"{old} -> {new}" + (f" (alias: {', '.join(ext)})" if ext else ""))
    for p, t in texts.items():
        p.write_text(t)
    print("\n".join(log))
    print(f"{len(data.get('functions', []))} function names, {len(data.get('locals', []))} branch labels applied")


if __name__ == "__main__":
    main()
