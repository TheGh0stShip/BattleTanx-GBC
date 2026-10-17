#!/usr/bin/env python3
"""One-time source edit: replace raw ROM bank bytes with BANK(label).

For each `ld a, $NN` immediately followed by `ld [rROMB0], a`, the following
instructions up to the next bank write, `ret` or unconditional jump are
scanned for a ROM label (call/jp target or 16-bit load operand). The first
such label whose bank (from battletanx.sym) equals $NN replaces the literal.
Sites with no such label are left raw and listed. The edit is byte-neutral;
`make compare` must still pass. It owns nothing and is not meant to be rerun.
Usage: symbolize_bank_bytes.py
"""
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent


def main():
    bank_of = {}
    for line in (ROOT / "battletanx.sym").read_text().splitlines():
        m = re.fullmatch(r"([0-9a-fA-F]{2}):([0-9a-fA-F]{4}) (\S+)", line.strip())
        if m and "." not in m.group(3) and int(m.group(2), 16) < 0x8000:
            bank_of[m.group(3)] = int(m.group(1), 16)
    done, left = 0, []
    for p in sorted((ROOT / "src").glob("*.asm")):
        lines = p.read_text().split("\n")
        changed = False
        for i in range(len(lines) - 1):
            m = re.match(r"^(\s*ld\s+a\s*,\s*)\$([0-9A-Fa-f]{2})(\s*(;.*)?)$", lines[i])
            if not (m and re.match(r"^\s*ld\s+\[rROMB0\]\s*,\s*a", lines[i + 1])):
                continue
            want = int(m.group(2), 16)
            pick = None
            for j in range(i + 2, min(i + 40, len(lines))):
                s = lines[j].split(";")[0].strip()
                if re.match(r"^(ret|reti|jp\s+hl)\b", s) or "rROMB0" in s:
                    break
                for lab in re.findall(r"^(?:call|jp|ld\s+(?:hl|de|bc)\s*,)\s*(?:[a-z]+\s*,\s*)?([A-Za-z_][A-Za-z0-9_]*)", s):
                    if bank_of.get(lab) == want and want != 0:
                        pick = lab
                        break
                if pick or re.match(r"^jp\s+[A-Za-z_]", s):
                    break
            if pick:
                lines[i] = f"{m.group(1)}BANK({pick}){m.group(3)}"
                changed, done = True, done + 1
            else:
                left.append(f"{p.relative_to(ROOT)}:{i + 1} ${want:02X}")
        if changed:
            p.write_text("\n".join(lines))
    print(f"{done} bank bytes symbolised; {len(left)} left raw")
    print("\n".join(left))


if __name__ == "__main__":
    main()
