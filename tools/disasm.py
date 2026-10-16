#!/usr/bin/env python3
"""Generate RGBDS source for BattleTanx (USA).gbc from the tracer's results.

Usage: disasm.py baserom.gbc outdir

Writes outdir/src/bank_XX.asm, outdir/src/main.asm and the list of binary
assets that tools/extract_assets.py must produce (assets.txt).
"""
import os, sys, collections
sys.path.insert(0, os.path.dirname(__file__))
from sm83 import decode
import trace, hints

INCBIN_MIN = 0x200          # data runs at least this long become INCBIN
HREG = {
    0x00: "rP1", 0x01: "rSB", 0x02: "rSC", 0x04: "rDIV", 0x05: "rTIMA", 0x06: "rTMA",
    0x07: "rTAC", 0x0F: "rIF", 0x10: "rNR10", 0x11: "rNR11", 0x12: "rNR12", 0x13: "rNR13",
    0x14: "rNR14", 0x16: "rNR21", 0x17: "rNR22", 0x18: "rNR23", 0x19: "rNR24", 0x1A: "rNR30",
    0x1B: "rNR31", 0x1C: "rNR32", 0x1D: "rNR33", 0x1E: "rNR34", 0x20: "rNR41", 0x21: "rNR42",
    0x22: "rNR43", 0x23: "rNR44", 0x24: "rNR50", 0x25: "rNR51", 0x26: "rNR52", 0x40: "rLCDC",
    0x41: "rSTAT", 0x42: "rSCY", 0x43: "rSCX", 0x44: "rLY", 0x45: "rLYC", 0x46: "rDMA",
    0x47: "rBGP", 0x48: "rOBP0", 0x49: "rOBP1", 0x4A: "rWY", 0x4B: "rWX", 0x4D: "rKEY1",
    0x4F: "rVBK", 0x51: "rHDMA1", 0x52: "rHDMA2", 0x53: "rHDMA3", 0x54: "rHDMA4",
    0x55: "rHDMA5", 0x56: "rRP", 0x68: "rBCPS", 0x69: "rBCPD", 0x6A: "rOCPS", 0x6B: "rOCPD",
    0x70: "rSVBK", 0xFF: "rIE",
}
NAMED_ADDR = {
    0x2000: "rROMB0",
    0x7FFF: "ROM_BANK_MARKER",
    0xC6BE: "wRuntimeCallback",
    0xC6BF: "wRuntimeCallback + 1",
    0xC6C0: "wVBlankPending",
}


def cpu_addr(off, ctx, loads):
    if ctx and ctx[0] == 'ram':
        ld = loads[ctx[1]]
        return ld.dst + off - ld.src
    return off if off < 0x4000 else 0x4000 + (off & 0x3FFF)


class Emitter:
    def __init__(self, rom):
        self.rom = rom
        t = trace.run(rom, hints.extra_entries(rom), hints.DATA_RANGES)
        trace.gap_fill(t, hints.CODE_BANKS, hints.DATA_RANGES)
        self.t = t
        # drop loads overlapping an earlier one or crossing a bank
        self.loads = {}
        end = -1
        for src in sorted(t.loads):
            ld = t.loads[src]
            if src < end or (src >> 14) != ((src + ld.len - 1) >> 14) or ld.len == 0:
                continue
            self.loads[src] = ld
            end = src + ld.len
        self.load_of = {}
        for ld in self.loads.values():
            for o in range(ld.src, ld.src + ld.len):
                self.load_of[o] = ld
        self.assets = []
        self.make_labels()

    def ctx_at(self, off):
        ld = self.load_of.get(off)
        return ('ram', ld.src) if ld else ('rom', off >> 14)

    def addr_at(self, off):
        return cpu_addr(off, self.ctx_at(off), self.loads)

    def make_labels(self):
        t = self.t
        self.names = {}
        cnt = collections.Counter()
        for off, kinds in t.labels.items():
            if off not in t.code:
                continue
            ld = self.load_of.get(off)
            a = self.addr_at(off)
            if ld:
                cnt[a] += 1
        for off, kinds in sorted(t.labels.items()):
            if off not in t.code:
                continue
            ld = self.load_of.get(off)
            a = self.addr_at(off)
            pre = "Func" if kinds & {'call', 'entry', 'gapfill', 'load', 'ptr'} else "Jump"
            if ld:
                name = f"RAM_{a:04X}" + (f"_{off >> 14:02X}_{0x4000 + (off & 0x3fff):04X}" if cnt[a] > 1 else "")
            elif off < 0x4000:
                name = f"{pre}_{a:04X}"
            else:
                name = f"{pre}_{off >> 14:02X}_{a:04X}"
            self.names[off] = hints.NAMES.get(off, name)

    # ------------------------------------------------------------------
    def fmt_operand(self, off, ln, opnd):
        typ, v = opnd
        if typ == 'rel':
            v = self.addr_at(off) + (v - off)
            typ = 'a16'
            tgt = [x for x in self.t.xref.get(off, ()) if x in self.names]
        else:
            tgt = [x for x in self.t.xref.get(off, ()) if x in self.names]
        if typ == 'a16':
            if len(tgt) == 1 and self.addr_at(tgt[0]) == v and self.label_ok(tgt[0]):
                return self.names[tgt[0]]
            return NAMED_ADDR.get(v, f"${v:04X}")
        if typ == 'n16':
            if len(tgt) == 1 and self.addr_at(tgt[0]) == v and self.label_ok(tgt[0]):
                return self.names[tgt[0]]
            return NAMED_ADDR.get(v, f"${v:04X}")
        if typ == 'n8':
            return f"${v:02X}"
        if typ == 'h8':
            return HREG.get(v, f"$FF{v:02X}")
        if typ == 's8':
            return str(v - 256 if v >= 128 else v)
        if typ == 's8u':
            s = v - 256 if v >= 128 else v
            return f"{s}"
        if typ == 'rst':
            return f"${v:02X}"
        raise ValueError(typ)

    def label_ok(self, off):
        return off in self.emitted_labels

    def plan(self):
        """Decide which offsets are emitted as instructions."""
        t = self.t
        self.insn = {}
        starts = set(t.code)
        for off, ln in t.code.items():
            if any(off + k in starts for k in range(1, ln)):
                continue
            if (off >> 14) != ((off + ln - 1) >> 14):
                continue
            ld = self.load_of.get(off)
            if any(self.load_of.get(off + k) is not ld for k in range(1, ln)):
                continue
            if any((off + k) in self.loads for k in range(1, ln)):
                continue
            self.insn[off] = ln
        # labels are emitted only on instruction boundaries
        self.emitted_labels = {o for o in self.names if o in self.insn}

    def emit_bank(self, b):
        rom = self.rom
        s, e = b * 0x4000, (b + 1) * 0x4000
        out = []
        if b == 0:
            out.append('SECTION "ROM Bank $00", ROM0[$0000]\n')
        else:
            out.append(f'SECTION "ROM Bank ${b:02X}", ROMX[$4000], BANK[${b:02X}]\n')
        i = s
        in_load = None
        data = []

        def flush():
            if not data:
                return
            start = data[0]
            n = len(data)
            if n >= INCBIN_MIN:
                path = f"assets/bank_{b:02X}/{0x4000 * (b > 0) + (start & 0x3fff):04X}.bin"
                self.assets.append((path, start, n))
                out.append(f'\tINCBIN "{path}" ; ${n:X} bytes\n')
            else:
                for k in range(0, n, 16):
                    chunk = rom[start + k:start + min(n, k + 16)]
                    out.append("\tdb " + ", ".join(f"${x:02X}" for x in chunk) + "\n")
            data.clear()

        while i < e:
            if b == 0 and i == 0x104:
                flush()
                out.append(self.header())
                i = 0x150
                continue
            if in_load and i == in_load.src + in_load.len:
                flush()
                out.append("\tENDL\n")
                in_load = None
            if i in self.loads:
                flush()
                ld = self.loads[i]
                region = "HRAM" if ld.dst >= 0xFF80 else ("WRAM0" if ld.dst < 0xD000 else "WRAMX")
                has_code = any(ld.src <= off < ld.src + ld.len for off in self.insn)
                kind = "code" if has_code else "data"
                out.append(f'\n\tLOAD UNION "RAM {kind} ${ld.dst:04X}", {region}[${ld.dst:04X}] ; copied from ${b:02X}:{self.addr_rom(i):04X}\n')
                in_load = ld
            if i in self.emitted_labels:
                flush()
                if i in self.insn and self.t.labels[i] & {'call', 'entry', 'gapfill', 'load'}:
                    out.append("\n")
                out.append(f"{self.names[i]}:\n")
            if i in self.insn:
                flush()
                ln = self.insn[i]
                r = decode(rom, i)
                _, fmt, opnd, kind, cond = r
                text = fmt.format(self.fmt_operand(i, ln, opnd)) if opnd else fmt
                if text.startswith("ld hl, sp+"):
                    v = int(text[10:])
                    text = f"ld hl, sp + {v}" if v >= 0 else f"ld hl, sp - {-v}"
                out.append(f"\t{text}\n")
                i += ln
                if kind in trace.TERMINATORS and not cond:
                    out.append("\n")
                continue
            data.append(i)
            i += 1
        flush()
        if in_load:
            out.append("\tENDL\n")
        return "".join(out)

    def header(self):
        h = self.rom
        title = h[0x134:0x13F].decode('ascii')
        hx = lambda a, n: ", ".join(f"${x:02X}" for x in h[a:a + n])
        return (
            "\n; Cartridge header ($0104-$014F)\n"
            "NintendoLogo:\n"
            + "".join(f"\tdb {hx(0x104 + k, 16)}\n" for k in range(0, 48, 16))
            + f'\tdb "{title}" ; title\n'
            f'\tdb "{h[0x13F:0x143].decode("ascii")}" ; manufacturer code\n'
            f"\tdb ${h[0x143]:02X} ; CGB flag: CGB only\n"
            f'\tdb "{h[0x144:0x146].decode("ascii")}" ; new licensee code\n'
            f"\tdb ${h[0x146]:02X} ; SGB flag\n"
            f"\tdb ${h[0x147]:02X} ; cartridge type: MBC5\n"
            f"\tdb ${h[0x148]:02X} ; ROM size: 1 MiB\n"
            f"\tdb ${h[0x149]:02X} ; RAM size: none\n"
            f"\tdb ${h[0x14A]:02X} ; destination: non-Japanese\n"
            f"\tdb ${h[0x14B]:02X} ; old licensee code: use new\n"
            f"\tdb ${h[0x14C]:02X} ; mask ROM version\n"
            f"\tdb ${h[0x14D]:02X} ; header checksum\n"
            f"\tdb ${h[0x14E]:02X}, ${h[0x14F]:02X} ; global checksum\n\n")

    def addr_rom(self, off):
        return off if off < 0x4000 else 0x4000 + (off & 0x3fff)


def main():
    rom = open(sys.argv[1], 'rb').read()
    outdir = sys.argv[2]
    em = Emitter(rom)
    em.plan()
    os.makedirs(os.path.join(outdir, "src"), exist_ok=True)
    nbanks = len(rom) // 0x4000
    for b in range(nbanks):
        with open(os.path.join(outdir, "src", f"bank_{b:02X}.asm"), "w") as f:
            f.write(f"; BattleTanx (USA) - ROM bank ${b:02X}\n\n")
            f.write(em.emit_bank(b))
    with open(os.path.join(outdir, "src", "main.asm"), "w") as f:
        f.write('INCLUDE "include/hardware.inc"\n')
        f.write('INCLUDE "include/memory.inc"\n\n')
        for b in range(nbanks):
            f.write(f'INCLUDE "src/bank_{b:02X}.asm"\n')
    with open(os.path.join(outdir, "assets.txt"), "w") as f:
        for path, start, n in em.assets:
            f.write(f"{path} {start:#x} {n:#x}\n")
    cov = sum(em.insn.values())
    print(f"code bytes: {cov} ({cov * 100 / len(rom):.2f}% of ROM), "
          f"labels: {len(em.emitted_labels)}, loads: {len(em.loads)}, assets: {len(em.assets)}")


if __name__ == "__main__":
    main()
