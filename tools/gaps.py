import sys, os; sys.path.insert(0, os.path.dirname(__file__))
import rom_trace as trace, hints
rom = open(sys.argv[1], 'rb').read()
banks = [int(x) for x in sys.argv[2].split(',')]
t = trace.run(rom, hints.extra_entries(rom), hints.DATA_RANGES)
cov = bytearray(len(rom))
for o, l in t.code.items(): cov[o:o+l] = b'\1' * l
for b in banks:
    s, e = b * 0x4000, (b + 1) * 0x4000
    i = s
    while i < e:
        if cov[i]: i += 1; continue
        j = i
        while j < e and not cov[j]: j += 1
        if j - i >= int(sys.argv[3] if len(sys.argv) > 3 else 1):
            print(f"{b:02x}:{(i if b==0 else 0x4000+i-s):04x} len {j-i:5d}  {rom[i:i+16].hex(' ')}")
        i = j
