#!/usr/bin/env python3
"""Extract binary asset blobs listed in assets.txt from the base ROM."""
import os, sys
rom = open(sys.argv[1], 'rb').read()
for line in open(sys.argv[2]):
    if not line.strip() or line.lstrip().startswith("#"):
        continue
    path, start, n = line.split()
    start, n = int(start, 0), int(n, 0)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    data = rom[start:start + n]
    if not os.path.exists(path) or open(path, 'rb').read() != data:
        open(path, 'wb').write(data)
