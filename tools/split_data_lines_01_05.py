#!/usr/bin/env python3
"""One-time source edit: split db/dw lines so raw pointer targets inside them get labels.

For each target (bank, address) that falls strictly inside a `db`/`dw` statement
outside a LOAD block, the statement is split at that byte (dw only at word
boundaries), a label `BankNNData_XXXX` is inserted, and raw operands equal to
the address in the listed files are replaced by the label.
Usage: split_data_lines_01_05.py RAW.json
"""
import json, pathlib, re, sys
ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))
import byte_accounting_01_05 as A

rom = (ROOT / "baserom.gbc").read_bytes()
A.classify(ROOT, rom)
entries = json.loads(pathlib.Path(sys.argv[1]).read_text())
targets = sorted({(int(e["target_bank"][1:], 16), int(e["value"][1:], 16)) for e in entries})
texts = {fi: (ROOT / p).read_text().split("\n") for fi, p in A.FILES.items()}
done, skipped, names = [], [], {}
edits = {}
for b, v in targets:
    hit = [s for s in A.STATEMENTS if s[0] == b and s[3] < v < s[4] and s[5] == "data" and not s[6]]
    if not hit:
        skipped.append(f"${b:02X}:{v:04X}")
        continue
    _, fi, ln, s0, e0, _, _ = hit[0]
    edits.setdefault((fi, ln), []).append((v - s0, f"Bank{b:02X}Data_{v:04X}", s0))
    names[(b, v)] = f"Bank{b:02X}Data_{v:04X}"
for (fi, ln), cuts in sorted(edits.items(), key=lambda x: (x[0][0], -x[0][1])):
    raw = texts[fi][ln - 1]
    m = re.match(r"^(\s*)(db|dw)\s+([^;]*)(;.*)?$", raw)
    if not m:
        skipped += [f"line {A.FILES[fi]}:{ln} not a plain db/dw"]
        continue
    ind, op, body, comment = m.group(1) or "\t", m.group(2), m.group(3), m.group(4) or ""
    items = [x.strip() for x in body.split(",") if x.strip()]
    size = 1 if op == "db" else 2
    if any('"' in x for x in items):
        skipped.append(f"line {A.FILES[fi]}:{ln} has strings")
        continue
    out, pos, start = [], 0, 0
    cut_at = {c[0]: c[1] for c in cuts}
    if any(c % size for c in cut_at):
        skipped.append(f"line {A.FILES[fi]}:{ln} cut not on a {op} boundary")
        continue
    for i, it in enumerate(items):
        if pos in cut_at and i > start:
            out.append(f"{ind}{op} " + ", ".join(items[start:i]))
            out.append(f"{cut_at[pos]}:")
            start = i
        pos += size
    out.append(f"{ind}{op} " + ", ".join(items[start:]) + (f" {comment}" if comment else ""))
    texts[fi][ln - 1:ln] = out
    done += [c[1] for c in cuts]
for fi, p in A.FILES.items():
    lines = texts[fi]
    for e in entries:
        if e["file"] != p:
            continue
        key = (int(e["target_bank"][1:], 16), int(e["value"][1:], 16))
        if key in names:
            for i, l in enumerate(lines):
                if l.strip().split(";")[0].strip() == e["text"].strip():
                    lines[i] = l.replace(e["value"], names[key], 1)
    (ROOT / p).write_text("\n".join(lines))
print(len(done), "labels inserted by splitting data lines;", len(skipped), "skipped:", skipped)
