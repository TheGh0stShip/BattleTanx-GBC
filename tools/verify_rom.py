#!/usr/bin/env python3
"""Verify a BattleTanx (USA) GBC image against the known-good hashes."""
import hashlib, sys
SHA1 = "5078584e86c0b6f4687c424cc00bbd762ba6573a"
MD5 = "4ca71b12d89a5bcfcc52095081ae9f51"
data = open(sys.argv[1], 'rb').read()
ok = hashlib.sha1(data).hexdigest() == SHA1 and hashlib.md5(data).hexdigest() == MD5
print(f"{sys.argv[1]}: {'OK' if ok else 'MISMATCH'} (sha1 {hashlib.sha1(data).hexdigest()})")
if not ok and len(sys.argv) > 2:
    ref = open(sys.argv[2], 'rb').read()
    diffs = [i for i in range(min(len(ref), len(data))) if ref[i] != data[i]]
    print(f"size {len(data)} vs {len(ref)}, {len(diffs)} differing bytes")
    for i in diffs[:20]:
        print(f"  {i >> 14:02X}:{(i if i < 0x4000 else 0x4000 + (i & 0x3fff)):04X}  got {data[i]:02X} want {ref[i]:02X}")
sys.exit(0 if ok else 1)
