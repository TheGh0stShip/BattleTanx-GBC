#!/usr/bin/env python3
"""One-time source edit: give raw own-bank ROM pointers in banks $01-$05 labels.

Input: a JSON list of {"file", "text", "value", "target_bank"} (raw operands
that are own-bank ROM pointers). For each target address:
  * a statement starting there outside a LOAD block -> label placed before it;
  * a statement starting there inside a LOAD block  -> a ROM-side label is placed
    before the LOAD directive and the operand becomes `Label + offset`;
  * an existing ROM label at the address is reused;
  * anything else (inside a db line or INCBIN) is reported and left raw.
The edited assembly is authoritative; this tool owns nothing.
Usage: label_raw_pointers_01_05.py RAW.json REPORT.json

Do not rerun.
"""
import json, pathlib, re, sys
ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))
import byte_accounting_01_05 as A

rom = (ROOT / "baserom.gbc").read_bytes()
A.classify(ROOT, rom)
sym = {}
for line in (ROOT / "battletanx.sym").read_text().splitlines():
    m = re.fullmatch(r"([0-9a-fA-F]{2}):([0-9a-fA-F]{4}) (\S+)", line.strip())
    if m and "." not in m.group(3):
        sym.setdefault((int(m.group(1), 16), int(m.group(2), 16)), []).append(m.group(3))
entries = json.loads(pathlib.Path(sys.argv[1]).read_text())
starts = {}
for b, fi, ln, s0, e0, kind, in_load in A.STATEMENTS:
    starts.setdefault((b, s0), (fi, ln, kind, in_load))
loads = sorted(A.LOADS)
texts = {fi: (ROOT / p).read_text().split("\n") for fi, p in A.FILES.items()}
inserts = {}            # (fi, line) -> label text to insert before
operand = {}            # (bank, value) -> replacement expression
report = []
for b, v in sorted({(int(e["target_bank"][1:], 16), int(e["value"][1:], 16)) for e in entries}):
    rom_labels = [n for n in sym.get((b, v), []) if not n.startswith(("w", "h", "RAM_"))]
    hit = starts.get((b, v))
    if hit and not hit[3]:
        if rom_labels and not rom_labels[0].startswith("Jump_"):
            operand[(b, v)] = rom_labels[0]
        else:
            name = f"Bank{b:02X}{'Code' if hit[2] == 'code' else 'Data'}_{v:04X}"
            inserts[(hit[0], hit[1])] = name
            operand[(b, v)] = name
        report.append({"target": f"${b:02X}:{v:04X}", "disposition": "labelled", "label": operand[(b, v)]})
        continue
    # inside a LOAD block?
    owner = None
    for lb, lfi, lln, lrom in loads:
        if lb == b and lrom <= v:
            owner = (lfi, lln, lrom)
    in_load_hit = hit and hit[3]
    if in_load_hit and owner:
        lfi, lln, lrom = owner
        name = f"Bank{b:02X}RomImage_{lrom:04X}"
        inserts[(lfi, lln)] = name
        operand[(b, v)] = name if v == lrom else f"{name} + ${v - lrom:02X}"
        report.append({"target": f"${b:02X}:{v:04X}", "disposition": "labelled (ROM side of RAM image)", "label": operand[(b, v)]})
        continue
    report.append({"target": f"${b:02X}:{v:04X}", "disposition": "left raw: not at a statement boundary (inside db data or an INCBIN)"})
for (fi, ln), name in sorted(inserts.items(), key=lambda x: (x[0][0], -x[0][1])):
    lines = texts[fi]
    if not any(l.startswith(name + ":") for l in lines):
        lines.insert(ln - 1, f"{name}:")
by_file = {}
for e in entries:
    b, v = int(e["target_bank"][1:], 16), int(e["value"][1:], 16)
    if (b, v) in operand:
        by_file.setdefault(e["file"], set()).add((e["text"].strip(), e["value"], operand[(b, v)]))
for fi, p in A.FILES.items():
    lines = texts[fi]
    for i, l in enumerate(lines):
        for text, val, rep in by_file.get(p, ()):
            if l.strip().split(";")[0].strip() == text:
                lines[i] = l.replace(val, rep, 1)
    (ROOT / p).write_text("\n".join(lines))
pathlib.Path(sys.argv[2]).write_text(json.dumps(report, indent=1) + "\n")
print(sum(1 for r in report if r["disposition"].startswith("labelled")), "targets labelled;",
      sum(1 for r in report if r["disposition"].startswith("left")), "left raw")
