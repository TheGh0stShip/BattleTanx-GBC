#!/usr/bin/env python3
"""Validate project metadata, generated assets, and tracing invariants."""

from __future__ import annotations

import hashlib
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
ROM_SIZE = 0x100000
EXPECTED_RGBDS = "v1.0.4"


def fail(message: str) -> None:
    raise SystemExit(f"check: {message}")


def check_toolchain() -> None:
    for program in ("rgbasm", "rgblink", "rgbfix", "rgbgfx"):
        try:
            line = subprocess.check_output(
                [program, "--version"], text=True, stderr=subprocess.STDOUT
            ).splitlines()[0]
        except (FileNotFoundError, subprocess.CalledProcessError) as exc:
            fail(f"cannot run {program}: {exc}")
        if EXPECTED_RGBDS not in line:
            fail(f"{program} must be RGBDS {EXPECTED_RGBDS}, got {line!r}")


def read_manifest() -> list[tuple[pathlib.Path, int, int]]:
    entries = []
    for number, raw in enumerate((ROOT / "assets.txt").read_text().splitlines(), 1):
        line = raw.split("#", 1)[0].strip()
        if not line:
            continue
        fields = line.split()
        if len(fields) != 3:
            fail(f"assets.txt:{number}: expected path, offset, and size")
        path, start, size = pathlib.Path(fields[0]), int(fields[1], 0), int(fields[2], 0)
        if path.is_absolute() or ".." in path.parts:
            fail(f"assets.txt:{number}: unsafe path {path}")
        if size <= 0 or start < 0 or start + size > ROM_SIZE:
            fail(f"assets.txt:{number}: range is outside the 1 MiB ROM")
        entries.append((path, start, size))
    ordered = sorted(entries, key=lambda item: item[1])
    for left, right in zip(ordered, ordered[1:]):
        if left[1] + left[2] > right[1]:
            fail(f"overlapping asset ranges: {left[0]} and {right[0]}")
    return entries


def check_assets(entries: list[tuple[pathlib.Path, int, int]]) -> None:
    rom_path = ROOT / "baserom.gbc"
    if not rom_path.exists():
        fail("baserom.gbc is required")
    rom = rom_path.read_bytes()
    if len(rom) != ROM_SIZE:
        fail(f"baserom.gbc must be {ROM_SIZE} bytes, got {len(rom)}")
    for relpath, start, size in entries:
        path = ROOT / relpath
        if not path.exists():
            fail(f"missing extracted asset {relpath}")
        data = path.read_bytes()
        if data != rom[start : start + size]:
            fail(f"asset does not match ROM range: {relpath}")


def check_scene_descriptors(rom: bytes) -> None:
    table = 0x599D
    destinations = [
        int.from_bytes(rom[table + offset : table + offset + 2], "little")
        for offset in range(0, 14, 2)
    ]
    if destinations != [0x9000, 0x9140, 0x9280, 0x93C0, 0x9500, 0x9640, 0x8800]:
        fail("scrolling-tile destination table changed")

    table = 0x59AB
    for index in range(11):
        record = rom[table + index * 16 : table + (index + 1) * 16]
        bank = record[0]
        pointers = [
            int.from_bytes(record[offset : offset + 2], "little")
            for offset in (1, 3, 5, 7)
        ]
        graphics, tilemap, attributes, auxiliary = pointers
        auxiliary_count = record[9]
        if bank not in range(0x30, 0x34):
            fail(f"scene descriptor {index} has unexpected bank {bank:#x}")
        if graphics < 0x4000 or graphics + 0xFF0 > 0x8000:
            fail(f"scene descriptor {index} graphics range is outside its bank")
        for kind, pointer in (("tilemap", tilemap), ("attributes", attributes)):
            if pointer < 0x4000 or pointer + 20 * 12 > 0x8000:
                fail(f"scene descriptor {index} {kind} range is outside its bank")
        if auxiliary < 0x4000 or auxiliary + 0x38 + auxiliary_count * 8 > 0x8000:
            fail(f"scene descriptor {index} auxiliary range is outside its bank")
        if record[10:] != bytes(6):
            fail(f"scene descriptor {index} reserved bytes are not zero")

    if rom[0x5A5B:0x5A60] != bytes((6, 7, 8, 9, 10)):
        fail("scene descriptor index table changed")


def check_tracing() -> None:
    sys.path.insert(0, str(ROOT / "tools"))
    import hints  # pylint: disable=import-outside-toplevel
    import trace  # pylint: disable=import-outside-toplevel

    rom = (ROOT / "baserom.gbc").read_bytes()
    for offset, value in hints.TEXT_STRINGS.items():
        if rom[offset : offset + len(value)] != value:
            fail(f"text manifest mismatch at ROM offset {offset:#x}")
    traced = trace.run(rom, hints.extra_entries(rom), hints.DATA_RANGES)
    direct_bytes = sum(traced.code.values())
    if direct_bytes != 37612 or len(traced.loads) != 38:
        fail(
            "tracing baseline changed; review it and update docs deliberately "
            f"(bytes={direct_bytes}, loads={len(traced.loads)})"
        )
    executable_loads = sum(
        any(load.src <= off < load.src + load.len for off in traced.code)
        for load in traced.loads.values()
    )
    if executable_loads != 30:
        fail(
            "RAM image classification changed; review it deliberately "
            f"(code={executable_loads}, data={len(traced.loads) - executable_loads})"
        )
    trace.gap_fill(traced, hints.CODE_BANKS, hints.DATA_RANGES)
    total_bytes = sum(traced.code.values())
    if total_bytes != 37612:
        fail(f"gap-fill baseline changed; review it deliberately (bytes={total_bytes})")
    print(
        "trace: "
        f"{direct_bytes} direct bytes, {total_bytes - direct_bytes} heuristic bytes, "
        f"{executable_loads} RAM code images, "
        f"{len(traced.loads) - executable_loads} RAM data images"
    )


def main() -> None:
    check_toolchain()
    entries = read_manifest()
    check_assets(entries)
    check_scene_descriptors((ROOT / "baserom.gbc").read_bytes())
    check_tracing()
    digest = hashlib.sha1((ROOT / "baserom.gbc").read_bytes()).hexdigest()
    print(f"project: OK ({len(entries)} assets, baserom sha1 {digest})")


if __name__ == "__main__":
    main()
