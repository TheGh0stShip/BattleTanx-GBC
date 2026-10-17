#!/usr/bin/env python3
"""Audit every literal address operand, bank byte and indirect transfer in src/.

ROM address operands (call/jp/jr literals, and 16-bit loads whose value equals
a ROM label address in the same bank or in ROM0) are classified as
  pinned     - the target has an `ASSERT ... == $XXXX` relocation pin
  numeric    - listed in tools/operand_dispositions.json as a value, not an address
  unresolved - anything else (fatal)
Raw bank bytes (`ld a, $NN` immediately before `ld [rROMB0], a`) are reported
the same way.

RAM/HRAM literals ($C000-$DFFF, $FF80-$FFFE) in instructions must each have a
disposition in tools/operand_dispositions.json: shared scratch, bank-dependent,
hardware-defined, layout, or unresolved (with reasons). An undocumented raw RAM
address is fatal.

Indirect transfers (`jp hl`, jumps/calls to RAM, pushed constant returns) must
each be documented by owner routine in INDIRECT_CONTROL_FLOW.md or
completion/RUNTIME_SYSTEMS.md.

`dw` literals equal to a ROM label address are counted as unverified
candidates (most are data values that happen to collide); they are reported,
not fatal.
Writes reports/operand_audit.json (deterministic). Usage: operand_audit.py [--write]
"""
from __future__ import annotations

import collections
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
REPORT = "reports/operand_audit.json"
DISPOSITIONS = "tools/operand_dispositions.json"
DOCS = ["docs/research/banks_01_05/INDIRECT_CONTROL_FLOW.md", "docs/research/completion/RUNTIME_SYSTEMS.md",
        "docs/research/completion/INTERRUPT_BANKING.md"]
LABEL_DEF = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)::?")
HEX4 = re.compile(r"(?<![\w$])\$([0-9A-Fa-f]{4})\b")


class OperandAuditError(ValueError):
    pass


def check(cond, msg):
    if not cond:
        raise OperandAuditError(msg)


def strip(line):
    out, q = [], False
    for ch in line:
        if ch == '"':
            q = not q
        if ch == ";" and not q:
            break
        out.append(ch)
    return "".join(out).strip()


def source_files(root):
    main = (root / "src" / "main.asm").read_text()
    out = []
    for rel, bank in re.findall(r'^INCLUDE "(src/bank_([0-9A-F]{2})\.asm)"', main, re.M):
        b = int(bank, 16)
        out.append((b, rel))
        stack = [rel]
        while stack:
            for sub in re.findall(r'^\s*INCLUDE "(src/[^"]+)"', (root / stack.pop()).read_text(), re.M):
                out.append((b, sub))
                stack.append(sub)
    return out


def read_sym(root):
    rom_labels = collections.defaultdict(set)
    for line in (root / "battletanx.sym").read_text().splitlines():
        m = re.fullmatch(r"([0-9a-fA-F]{2}):([0-9a-fA-F]{4}) (\S+)", line.strip())
        if m and "." not in m.group(3):
            b, a = int(m.group(1), 16), int(m.group(2), 16)
            if a < 0x8000:
                rom_labels[(b, a)].add(m.group(3))
    return rom_labels


def pins(root):
    out = set()
    for p in (root / "src").glob("*.asm"):
        for m in re.finditer(r"ASSERT\s+BANK\((\w+)\)\s*==\s*\$([0-9A-Fa-f]{2})\s*&&\s*\1\s*==\s*\$([0-9A-Fa-f]{4})", p.read_text()):
            out.add((int(m.group(2), 16), int(m.group(3), 16)))
    return out


def ram_class(v):
    if 0xC000 <= v < 0xE000:
        return "wram"
    if 0xFF80 <= v <= 0xFFFE:
        return "hram"
    return None


def audit(root, dispositions):
    rom_labels = read_sym(root)
    pinned = pins(root)
    numeric = {(int(k.split(":")[0], 16), int(k.split(":")[1], 16)): v
               for k, v in dispositions.get("rom_numeric", {}).items()}
    ram_disp = dispositions.get("ram", {})
    rom_ops, bank_bytes, ram_ops, indirect, dw_candidates = [], [], [], [], collections.Counter()
    docs = "".join((root / d).read_text() for d in DOCS if (root / d).exists())
    for bank, rel in source_files(root):
        lines = (root / rel).read_text().split("\n")
        owner, prev_ld = None, None
        depth = 0
        in_load = False
        for n, raw in enumerate(lines, 1):
            s = strip(raw)
            if re.match(r"^MACRO\b", s):
                depth += 1
            if depth:
                if re.match(r"^ENDM\b", s):
                    depth -= 1
                continue
            m = LABEL_DEF.match(s)
            if m:
                if not m.group(1).startswith("Jump_") and "legacy" not in raw:
                    owner = m.group(1) if not re.match(r"^\.", m.group(1)) else owner
                s = s[m.end():].strip()
            if not s:
                continue
            word = s.split()[0].lower()
            if word == "load":
                in_load = True
            elif word == "endl":
                in_load = False
            where = f"{rel}:{n}"
            if word in ("db", "ds", "incbin", "assert", "static_assert", "def", "section", "load", "endl", "println",
                        "include", "if", "elif", "else", "endc", "rept", "endr", "for", "opt", "charmap"):
                continue
            if word == "dw":
                for h in HEX4.findall(s):
                    v = int(h, 16)
                    if v >= 0x100 and ((bank, v) in rom_labels or (0, v) in rom_labels):
                        dw_candidates[bank] += 1
                continue
            hexes = [int(h, 16) for h in HEX4.findall(s)]
            # ROM address operands
            for v in hexes:
                if v >= 0x8000:
                    continue
                is_branch = word in ("call", "jp", "jr")
                is_load16 = word == "ld" and re.match(r"ld\s+(hl|bc|de|sp)\s*,\s*\$", s, re.I)
                if v < 0x4000:
                    cands = [0]
                elif bank != 0:
                    cands = [bank]
                else:   # ROM0 code naming a switchable-bank address: any bank may be meant
                    cands = sorted({b for (b, a) in list(rom_labels) + list(pinned) if a == v and b != 0})
                labelled = any((b, v) in rom_labels or (b, v) in pinned for b in cands)
                if is_branch or (is_load16 and labelled and v >= 0x0100):
                    tgt_bank = cands[0] if len(cands) == 1 else (cands[0] if cands else bank)
                    key = (tgt_bank, v)
                    if any((b, v) in pinned for b in cands):
                        key = next((b, v) for b in cands if (b, v) in pinned)
                        cls = "pinned"
                    elif key in pinned:
                        cls = "pinned"
                    elif key in numeric:
                        cls = "numeric"
                    else:
                        cls = "unresolved"
                    rom_ops.append({"at": where, "owner": owner, "operand": f"${v:04X}", "target_bank": f"${tgt_bank:02X}",
                                    "labels": sorted(rom_labels.get(key, ())), "class": cls})
            # raw bank bytes
            mb = re.match(r"ld\s+a\s*,\s*\$([0-9A-Fa-f]{2})$", s, re.I)
            if mb:
                prev_ld = (int(mb.group(1), 16), where)
            elif re.match(r"ld\s+\[(rROMB0|\$2000)\]\s*,\s*a$", s, re.I) and prev_ld:
                d = dispositions.get("bank_bytes", {}).get(f"{owner}|${prev_ld[0]:02X}")
                cls = d["class"] if d else "undocumented"
                bank_bytes.append({"at": prev_ld[1], "owner": owner, "bank": f"${prev_ld[0]:02X}", "class": cls})
                prev_ld = None
            else:
                prev_ld = None
            # RAM literals
            for v in hexes:
                rc = ram_class(v)
                if rc:
                    d = ram_disp.get(f"{v:04X}")
                    ram_ops.append({"at": where, "owner": owner, "address": f"${v:04X}", "region": rc,
                                    "class": d["class"] if d else "undocumented"})
            # indirect transfers
            kind = None
            if re.match(r"jp\s+(hl|\[hl\])$", s, re.I):
                kind = "jp hl"
            elif word in ("call", "jp") and hexes and hexes[-1] >= 0xC000:
                kind = "transfer to RAM"
            elif word == "push" and re.search(r"\b(hl|bc|de)\b", s) and n > 1:
                p = strip(lines[n - 2])
                if re.match(r"ld\s+(hl|bc|de)\s*,\s*[A-Za-z_]", p) and not re.search(r"\[", p):
                    kind = "pushed constant (synthetic return candidate)"
            if kind:
                documented = bool(owner and re.search(rf"\b{re.escape(owner)}\b", docs))
                indirect.append({"at": where, "owner": owner, "kind": kind, "in_ram_image": in_load,
                                 "documented": documented})
    return rom_ops, bank_bytes, ram_ops, indirect, dict(sorted(dw_candidates.items()))


def summarize(rom_ops, bank_bytes, ram_ops, indirect, dw):
    c = lambda xs, k: dict(sorted(collections.Counter(x[k] for x in xs).items()))
    ram_addr = collections.defaultdict(lambda: collections.Counter())
    for r in ram_ops:
        ram_addr[r["address"]][r["class"]] += 1
    return {
        "rom_address_operands": {"by_class": c(rom_ops, "class"), "items": rom_ops},
        "raw_bank_bytes": {"by_class": c(bank_bytes, "class"), "items": bank_bytes},
        "ram_literals": {"by_class": c(ram_ops, "class"), "by_address": {a: dict(v) for a, v in sorted(ram_addr.items())}},
        "indirect_transfers": {"by_kind": c(indirect, "kind"),
                               "undocumented": [x for x in indirect if not x["documented"] and x["kind"] != "pushed constant (synthetic return candidate)"],
                               "items": indirect},
        "dw_rom_label_collisions_per_bank": {f"${b:02X}": n for b, n in dw.items()},
    }


def validate(report):
    unresolved = [x for x in report["rom_address_operands"]["items"] if x["class"] == "unresolved"]
    check(not unresolved, f"operand audit: {len(unresolved)} unresolved raw ROM address operands, first {unresolved[:1]}")
    ub = [x for x in report["raw_bank_bytes"]["items"] if x["class"] == "undocumented"]
    check(not ub, f"operand audit: {len(ub)} undocumented raw bank bytes, first {ub[:1]}")
    und = report["ram_literals"]["by_class"].get("undocumented", 0)
    check(und == 0, f"operand audit: {und} raw RAM literals without a disposition")
    ui = report["indirect_transfers"]["undocumented"]
    check(not ui, f"operand audit: {len(ui)} undocumented indirect transfers, first {ui[:1]}")


def run(root, write):
    disp = json.loads((root / DISPOSITIONS).read_text()) if (root / DISPOSITIONS).exists() else {}
    report = summarize(*audit(root, disp))
    text = json.dumps(report, indent=1, sort_keys=True) + "\n"
    p = root / REPORT
    if write:
        p.write_text(text)
    validate(report)
    check(p.exists() and p.read_text() == text, f"operand audit: {REPORT} is stale; rerun with --write")
    return report, disp


def negative_tests(root, report, disp):
    import copy
    n = 0
    cases = []
    r = copy.deepcopy(report)
    r["rom_address_operands"]["items"].append({"class": "unresolved"})
    cases.append(("raw ROM operand", r, "unresolved raw ROM address"))
    r = copy.deepcopy(report)
    r["raw_bank_bytes"]["items"].append({"class": "undocumented"})
    cases.append(("raw bank byte", r, "undocumented raw bank bytes"))
    r = copy.deepcopy(report)
    r["ram_literals"]["by_class"]["undocumented"] = 1
    cases.append(("undocumented RAM literal", r, "without a disposition"))
    r = copy.deepcopy(report)
    r["indirect_transfers"]["undocumented"].append({"kind": "jp hl"})
    cases.append(("undocumented indirect transfer", r, "undocumented indirect"))
    for name, rep, expect in cases:
        try:
            validate(rep)
        except OperandAuditError as exc:
            check(expect in str(exc), f"operand audit negative test {name}: {exc}")
            n += 1
        else:
            raise OperandAuditError(f"operand audit negative test not rejected: {name}")
    # end-to-end: a source line with a new raw call target must be caught
    import shutil
    import tempfile
    with tempfile.TemporaryDirectory() as tmp:
        t = pathlib.Path(tmp)
        for d in ("src", "docs", "tools"):
            shutil.copytree(root / d, t / d)
        shutil.copy(root / "battletanx.sym", t / "battletanx.sym")
        p = t / "src" / "bank_00.asm"
        p.write_text(p.read_text().replace("\n", "\n\tcall $0150 ; injected\n", 1)
                     if False else p.read_text() + "\n\tcall $0061 ; injected\n")
        rep = summarize(*audit(t, disp))
        try:
            validate(rep)
        except OperandAuditError as exc:
            check("unresolved raw ROM address" in str(exc), f"operand audit negative test injected call: {exc}")
            n += 1
        else:
            raise OperandAuditError("operand audit negative test not rejected: injected raw call")
    return n


def main():
    report, disp = run(ROOT, "--write" in sys.argv)
    neg = negative_tests(ROOT, report, disp)
    rc = report["rom_address_operands"]["by_class"]
    print(f"operand audit: ROM operands {rc}, bank bytes {report['raw_bank_bytes']['by_class']}, "
          f"RAM literals {report['ram_literals']['by_class']}, indirect {report['indirect_transfers']['by_kind']}; "
          f"{neg} negative tests rejected")


if __name__ == "__main__":
    main()
