#!/usr/bin/env python3
"""One-time generator for src/screen_effect_tables.asm (bank $05 $59E0-$7FFF).

Replaces assets/bank_05/59E0.bin. The checked-in assembly is authoritative;
do not rerun this over reviewed source. Usage: gen_screen_effect_asm.py baserom.gbc
"""
import pathlib, re, sys

rom = pathlib.Path(sys.argv[1]).read_bytes()
root = pathlib.Path(__file__).resolve().parent.parent
B = lambda a: 5 * 0x4000 + a - 0x4000
w = lambda a: rom[B(a)] | rom[B(a) + 1] << 8
sym = {}
for line in (root / "battletanx.sym").read_text().splitlines():
    m = re.fullmatch(r"([0-9a-f]{2}):([0-9a-f]{4}) (\S+)", line.strip(), re.I)
    if m and "." not in m.group(3):
        sym.setdefault((int(m.group(1), 16), int(m.group(2), 16)), m.group(3))
STEPS, NSTEPS, REACHABLE = 0x6358, 72, 19
recs, tmpls = {}, {}
step_refs = {}
for s in range(NSTEPS):
    for k in range(3):
        p = w(STEPS + 6 * s + 2 * k)
        if p:
            recs[p] = (rom[B(p)], w(p + 1), w(p + 3))
            step_refs.setdefault(p, []).append(s)
for p, (count, src, tp) in recs.items():
    tmpls[tp] = count
out = ["; Screen-effect tables, bank $05:$59E0-$7FFF (see docs/research/banks_01_05/BANK05_SHARED_TABLES.md).",
       "; Generated once by tools/gen_screen_effect_asm.py; this file is now authoritative.",
       "; Part record: tile count, bank-$08 tile source, OAM template (ROM0 LoadScreenEffectPart).",
       "; Template entry: y offset, x offset, tile offset, attribute (ROM0 BuildScreenEffectPartOam ORs in 3).",
       "; Steps $00-$12 are reachable (75-frame countdown); steps $13-$47 are well-formed but never shown.", ""]
a = 0x59E0
while a < STEPS:
    if a in recs:
        count, src, tp = recs[a]
        steps = step_refs[a]
        note = "steps " + ",".join(f"${x:02X}" for x in steps) + ("" if min(steps) < REACHABLE else " (unreachable only)")
        out.append(f"ScreenEffectPart{a:04X}: ; {note}")
        out.append(f"\tscreen_effect_part {count}, {sym[(8, src)]}, ScreenEffectTemplate{tp:04X}")
        a += 5
    elif a in tmpls:
        n = tmpls[a]
        out.append(f"ScreenEffectTemplate{a:04X}:")
        for i in range(n):
            e = rom[B(a + 4 * i):B(a + 4 * i) + 4]
            sv = lambda x: x - 256 if x > 127 else x
            out.append(f"\tdb {sv(e[0])}, {sv(e[1])}, {e[2]}, ${e[3]:02X}")
        a += 4 * n
    else:
        end = a
        while end < STEPS and end not in recs and end not in tmpls:
            end += 1
        out.append(f"ScreenEffectUnusedTemplateEntries{a:04X}: ; {(end - a) // 4} unused OAM entries after a 3-entry template")
        for i in range(a, end, 4):
            out.append("\tdb " + ", ".join(f"${x:02X}" for x in rom[B(i):B(min(end, i + 4))]))
        a = end
out.append("")
out.append("ScreenEffectSteps: ; 72 steps x 3 part pointers; 0 = no part (ROM0 StartScreenEffect starts at step 0)")
for s in range(NSTEPS):
    ps = [w(STEPS + 6 * s + 2 * k) for k in range(3)]
    ops = ", ".join(f"ScreenEffectPart{p:04X}" if p else "0" for p in ps)
    out.append(f"\tdw {ops} ; step ${s:02X}" + ("" if s < REACHABLE else " (unreachable)"))
out += ["ScreenEffectStepsEnd:", "", "\tds $7FFF - @, $00", "\tdb BANK(@)", "",
        f"\tASSERT ScreenEffectSteps == $6358, \"raw pointer: ROM0 StartScreenEffect (ld a,$58 / ld a,$63)\"",
        f"\tASSERT ScreenEffectStepsEnd - ScreenEffectSteps == {NSTEPS} * 6", ""]
(root / "src" / "screen_effect_tables.asm").write_text("\n".join(out))
print(len(recs), "parts,", len(tmpls), "templates")
