#!/usr/bin/env python3
"""Recreate every binary source asset from a verified retail cartridge."""

from __future__ import annotations

import argparse
import hashlib
import pathlib


ROOT = pathlib.Path(__file__).resolve().parent.parent
EXPECTED_SIZE = 1_048_576
EXPECTED_SHA1 = "5078584e86c0b6f4687c424cc00bbd762ba6573a"
EXPECTED_SHA256 = "b449bab1b0a422fdb462d0dc5c55fbc8e50d8c18a5e2fd836e7db016ee63aa62"


def records(path: pathlib.Path, fields: int):
    for number, raw in enumerate(path.read_text().splitlines(), 1):
        line = raw.split("#", 1)[0].strip()
        if not line:
            continue
        parts = line.split()
        if len(parts) != fields:
            raise SystemExit(f"{path.name}:{number}: expected {fields} fields")
        yield number, parts


def verify_rom(path: pathlib.Path) -> bytes:
    data = path.read_bytes()
    sha1 = hashlib.sha1(data).hexdigest()
    sha256 = hashlib.sha256(data).hexdigest()
    if len(data) != EXPECTED_SIZE or sha1 != EXPECTED_SHA1 or sha256 != EXPECTED_SHA256:
        raise SystemExit(
            "assets: unsupported cartridge\n"
            f"  file: {path}\n"
            f"  size: {len(data)} (expected {EXPECTED_SIZE})\n"
            f"  sha1: {sha1} (expected {EXPECTED_SHA1})\n"
            f"  sha256: {sha256} (expected {EXPECTED_SHA256})"
        )
    print(f"assets: cartridge OK (sha1 {sha1})")
    return data


def expected_assets(rom: bytes) -> dict[pathlib.Path, bytes]:
    assets: dict[pathlib.Path, bytes] = {}

    for number, parts in records(ROOT / "assets.txt", 3):
        rel = pathlib.Path(parts[0])
        start, size = (int(value, 0) for value in parts[1:])
        if rel.is_absolute() or ".." in rel.parts:
            raise SystemExit(f"assets.txt:{number}: unsafe path {rel}")
        if size <= 0 or start < 0 or start + size > len(rom):
            raise SystemExit(f"assets.txt:{number}: range outside cartridge")
        assets[rel] = rom[start : start + size]

    slices: dict[pathlib.Path, list[tuple[int, int, int, int]]] = {}
    for number, parts in records(ROOT / "asset_slices.txt", 4):
        rel = pathlib.Path(parts[0])
        file_start, size, rom_start = (int(value, 0) for value in parts[1:])
        if rel.is_absolute() or ".." in rel.parts:
            raise SystemExit(f"asset_slices.txt:{number}: unsafe path {rel}")
        if size <= 0 or file_start < 0 or rom_start < 0 or rom_start + size > len(rom):
            raise SystemExit(f"asset_slices.txt:{number}: range outside file or cartridge")
        slices.setdefault(rel, []).append((file_start, size, rom_start, number))

    # Files absent from assets.txt are assembled from non-contiguous ROM slices.
    # Files already present in assets.txt are still cross-checked below.
    for rel, rows in slices.items():
        size = max(file_start + length for file_start, length, _, _ in rows)
        image = bytearray(size)
        covered = bytearray(size)
        for file_start, length, rom_start, number in rows:
            chunk = rom[rom_start : rom_start + length]
            for index, value in enumerate(chunk, file_start):
                if covered[index] and image[index] != value:
                    raise SystemExit(
                        f"asset_slices.txt:{number}: conflicting destination byte "
                        f"{rel}+{index:#x}"
                    )
                image[index] = value
                covered[index] = 1
        if rel not in assets:
            if not all(covered):
                gap = covered.index(0)
                raise SystemExit(f"asset_slices.txt: uncovered byte {gap:#x} in {rel}")
            assets[rel] = bytes(image)
        else:
            direct = assets[rel]
            if len(direct) != len(image):
                raise SystemExit(f"asset manifests disagree on size of {rel}")
            for offset, is_covered in enumerate(covered):
                if is_covered and direct[offset] != image[offset]:
                    raise SystemExit(f"asset manifests disagree at {rel}+{offset:#x}")

    return assets


def main() -> None:
    parser = argparse.ArgumentParser(
        description="recreate all source assets from BattleTanx (USA)"
    )
    parser.add_argument("rom", type=pathlib.Path, help="legally obtained cartridge dump")
    parser.add_argument(
        "--output-root", type=pathlib.Path, default=ROOT,
        help="repository-shaped output root (default: project root)",
    )
    parser.add_argument(
        "--check", action="store_true",
        help="compare existing assets without writing them",
    )
    args = parser.parse_args()

    rom = verify_rom(args.rom)
    assets = expected_assets(rom)
    changed = 0
    for rel, expected in sorted(assets.items(), key=lambda item: str(item[0])):
        target = args.output_root / rel
        actual = target.read_bytes() if target.exists() else None
        if actual == expected:
            continue
        if args.check:
            state = "missing" if actual is None else "different"
            raise SystemExit(f"assets: {rel} is {state}")
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(expected)
        changed += 1

    verb = "verified" if args.check else "prepared"
    print(f"assets: {verb} {len(assets)} files ({changed} written)")


if __name__ == "__main__":
    main()
