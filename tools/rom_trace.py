"""Recursive-descent code tracer for BattleTanx GBC (MBC5, 1 MiB).

Contexts:
  ('rom', bank)       code executing from ROM; bank 0 for $0000-$3FFF code,
                      `cur` tracks which ROMX bank is mapped.
  ('ram', load_id)    code copied into RAM via the engine's memcpy ($0A8F/$0AA4)
"""
import os, sys, collections
sys.path.insert(0, os.path.dirname(__file__))
from sm83 import decode

MEMCPY16 = 0x0A8F   # hl=src, bc=dst, de=len
MEMCPY8 = 0x0AA4    # hl=src, bc=dst, e=len


class Load:
    def __init__(self, src, dst, length):
        self.src, self.dst, self.len = src, dst, length

    def __repr__(self):
        return f"Load(src={self.src:#x}, dst={self.dst:#x}, len={self.len:#x})"


class Tracer:
    def __init__(self, rom, data_ranges=()):
        self.rom = rom
        self.data_ranges = tuple(data_ranges)
        self.code = {}            # rom offset -> instr length
        self.ctxof = {}           # rom offset -> context of first visit
        self.labels = collections.defaultdict(set)
        self.loads = {}           # src offset -> Load
        self.ram_targets = collections.Counter()
        self.jphl = set()
        self.seen = set()
        self.queue = []
        self.unknown_far = set()
        self.notes = []
        self.xref = collections.defaultdict(set)   # instr offset -> target offsets

    # address mapping -----------------------------------------------------
    def to_off(self, ctx, cur, addr):
        """Map a CPU address in ctx to (rom offset, new ctx) or None."""
        if ctx[0] == 'ram':
            ld = self.loads[ctx[1]]
            if ld.dst <= addr < ld.dst + ld.len:
                return ld.src + addr - ld.dst, ctx
            for l2 in self.loads.values():   # jumps into another RAM blob
                if l2.dst <= addr < l2.dst + l2.len and l2.dst >= 0xc000:
                    return l2.src + addr - l2.dst, ('ram', l2.src)
        if addr < 0x4000:
            return addr, ('rom', 0)
        if addr < 0x8000:
            bank = ctx[1] if ctx[0] == 'rom' and ctx[1] else cur
            if not bank:
                return None
            return bank * 0x4000 + addr - 0x4000, ('rom', bank)
        if ctx[0] == 'rom':
            for l2 in self.loads.values():
                if l2.dst <= addr < l2.dst + l2.len:
                    return l2.src + addr - l2.dst, ('ram', l2.src)
        return None

    def add(self, ctx, cur, addr, kind, src=None):
        if addr >= 0x8000:
            hits = [l for l in self.loads.values() if l.dst <= addr < l.dst + l.len]
            if ctx[0] == 'ram' and any(l.src == ctx[1] for l in hits):
                hits = [self.loads[ctx[1]]]
            if not hits:
                self.ram_targets[addr] += 1
            for l in hits:
                off = l.src + addr - l.dst
                if src is not None:
                    self.xref[src].add(off)
                self.labels[off].add(kind)
                c2 = cur or (l.src >> 14) or None
                if (off, c2) not in self.seen:
                    self.seen.add((off, c2))
                    self.queue.append((('ram', l.src), c2, addr))
            return
        m = self.to_off(ctx, cur, addr)
        if m is None:
            if addr >= 0x8000:
                self.ram_targets[addr] += 1
            else:
                self.unknown_far.add(addr)
            return
        off, nctx = m
        self.labels[off].add(kind)
        if src is not None:
            self.xref[src].add(off)
        if nctx[0] == 'rom' and nctx[1]:
            cur = nctx[1]
        key = (off, cur if nctx != ('rom', 0) or True else None)
        if key not in self.seen:
            self.seen.add(key)
            self.queue.append((nctx, cur, addr))

    def run(self):
        while self.queue:
            self.trace(*self.queue.pop())

    def trace(self, ctx, cur, addr):
        rom = self.rom
        regs = {}   # tracked immediate register values
        while True:
            m = self.to_off(ctx, cur, addr)
            if m is None:
                return
            off, ctx = m
            if any(start <= off < end for start, end in self.data_ranges):
                return
            r = decode(rom, off)
            if r is None:
                self.labels[off].add('BAD')
                self.notes.append(f"bad opcode at {off:#x}")
                return
            ln, fmt, opnd, kind, cond = r
            for k in range(1, ln):
                if off + k in self.code:
                    self.labels[off].add('OVERLAP')
            if off in self.code and kind is None and fmt == "nop":
                pass
            self.code[off] = ln
            self.ctxof.setdefault(off, ctx)
            # register tracking (immediates only) ----------------------
            if opnd and opnd[0] in ('n8', 'n16') and fmt.startswith('ld '):
                reg = fmt.split()[1].rstrip(',')
                regs[reg] = opnd[1]
                if reg in ('bc', 'de', 'hl'):
                    regs[reg[0]] = opnd[1] >> 8
                    regs[reg[1]] = opnd[1] & 0xff
            elif fmt == "ld [{}], a" and 0x2000 <= opnd[1] < 0x3000:
                cur = regs.get('a')
            elif fmt.startswith(("ld [", "ldh [", "push", "cp", "jr", "jp", "nop", "di", "ei")):
                pass
            elif fmt.startswith("call"):
                pass
            else:
                dst = fmt.split()[1].rstrip(',') if ' ' in fmt else fmt
                for k in [dst] + ([dst[0], dst[1]] if dst in ('bc', 'de', 'hl') else []) + (['h', 'l', 'hl'] if dst == 'hl' or fmt.startswith(('ld a, [hl', 'ld [hl'))  else []):
                    regs.pop(k, None)
                if dst in ('h', 'l'):
                    regs.pop('hl', None)
                if dst in ('d', 'e'):
                    regs.pop('de', None)
                if dst in ('b', 'c'):
                    regs.pop('bc', None)
            # memcpy loads ---------------------------------------------
            if kind == 'call' and opnd[1] in (MEMCPY16, MEMCPY8) and ctx[0] == 'rom':
                src, dst = regs.get('hl'), regs.get('bc')
                n = regs.get('de') if opnd[1] == MEMCPY16 else regs.get('e')
                if None not in (src, dst, n) and (dst >= 0xc000 and dst < 0xe000 or dst >= 0xff80):
                    sm = self.to_off(ctx, cur, src)
                    if sm:
                        so = sm[0]
                        if so not in self.loads:
                            self.loads[so] = Load(so, dst, n)
                            self.labels[so].add('load')
                            self._retry_ram()
            # code pointers: `ld rr, ptr` followed by a store of l/h or a push
            if (fmt.startswith("ld ") and opnd and opnd[0] == 'n16'
                    and opnd[1] >= 0x40 and fmt[3:5] in ('hl', 'de', 'bc')):
                if self.looks_like_ptr_store(off + ln, fmt[3:5]):
                    self.add(ctx, cur, opnd[1], 'ptr', off)
            if kind == 'call':
                regs = {}
            # control flow ---------------------------------------------
            if opnd and kind in ("jp", "jr", "call", "rst"):
                t = opnd[1]
                if kind == "jr":
                    t = addr + (t - off)
                self.add(ctx, cur, t, kind, off)
            if kind == "jphl":
                self.jphl.add(off)
            addr += ln
            if kind in ("ret", "reti", "jp", "jr", "jphl") and not cond:
                return

    def looks_like_ptr_store(self, off, rr):
        seq = []
        for _ in range(4):
            r = decode(self.rom, off)
            if r is None:
                break
            seq.append(r[1])
            off += r[0]
        lo, hi = rr[1], rr[0]
        if seq and seq[0] == f"push {rr}":
            return True
        if seq[:4] == [f"ld a, {lo}", "ld [{}], a", f"ld a, {hi}", "ld [{}], a"]:
            return True
        if seq[:2] == [f"ld a, {lo}", "ld [hli], a"] or seq[:2] == [f"ld a, {lo}", "ldh [{}], a"]:
            return True
        return False

    def _retry_ram(self):
        pend = list(self.ram_targets)
        self.ram_targets.clear()
        for a in pend:
            self.add(('rom', 0), None, a, 'call')


def run(rom, extra=(), data_ranges=()):
    t = Tracer(rom, data_ranges)
    for v in [0x100, 0x40, 0x48, 0x50, 0x58, 0x60]:
        t.add(('rom', 0), None, v, 'entry')
    for bank, addr in extra:
        t.add(('rom', bank), bank or None, addr, 'entry')
    t.run()
    return t


TERMINATORS = ("ret", "reti", "jp", "jr", "jphl")


def speculative_ok(t, off, end, base_addr):
    """Linear check that bytes at off look like a function ending before end."""
    rom = t.rom
    i, n = off, 0
    if rom[off] in (0x00, 0xFF):
        return False
    while i < end:
        r = decode(rom, i)
        if r is None:
            return False
        ln, fmt, opnd, kind, cond = r
        if i + ln > end:
            return False
        if fmt in ("stop", "halt") or fmt.startswith(("rst", "ld b, b", "ld d, d", "ld e, e", "ld h, h", "ld l, l", "ld c, c")):
            return False
        if kind in ("jp", "call") and (0x8000 <= opnd[1] < 0xc000 or opnd[1] < 0x100):
            return False
        if kind == "jr":
            tgt = i + 2 + ((opnd[1] - i - 2))
            if not (off <= tgt < end + 0x40) and tgt not in t.code:
                return False
        n += 1
        i += ln
        if kind in TERMINATORS and not cond:
            return n >= 2
    return False


def gap_fill(t, banks, data_ranges=()):
    changed = True
    while changed:
        changed = False
        cov = bytearray(len(t.rom))
        for o, l in t.code.items():
            cov[o:o + l] = b'\1' * l
        for b in banks:
            s, e = b * 0x4000, (b + 1) * 0x4000
            i = s
            while i < e:
                if cov[i]:
                    i += 1
                    continue
                j = i
                while j < e and not cov[j]:
                    j += 1
                if any(start < j and i < end for start, end in data_ranges):
                    i = j
                    continue
                in_load = any(l.src <= i < l.src + l.len for l in t.loads.values())
                if not in_load and speculative_ok(t, i, j, None):
                    addr = i if b == 0 else 0x4000 + i - s
                    t.add(('rom', b), b or None, addr, 'gapfill')
                    t.run()
                    changed = True
                    break
                i = j
            if changed:
                break


if __name__ == "__main__":
    import hints
    rom = open(sys.argv[1], 'rb').read()
    t = run(rom, hints.extra_entries(rom), hints.DATA_RANGES)
    gap_fill(t, hints.CODE_BANKS, hints.DATA_RANGES)
    per = collections.Counter()
    for off, ln in t.code.items():
        per[off >> 14] += ln
    print({b: per[b] for b in sorted(per)}, sum(per.values()))
    print('loads', sorted(t.loads.values(), key=lambda l: l.src))
    print('unresolved ram', sorted(hex(k) for k in t.ram_targets))
    print('unknown far', sorted(hex(k) for k in t.unknown_far))
    print('jphl', [hex(x) for x in sorted(t.jphl)])
    print('\n'.join(t.notes[:20]))
    print('overlap', [hex(o) for o, k in t.labels.items() if 'OVERLAP' in k][:40])
