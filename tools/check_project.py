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


def check_tracing() -> None:
    sys.path.insert(0, str(ROOT / "tools"))
    import hints  # pylint: disable=import-outside-toplevel
    import trace  # pylint: disable=import-outside-toplevel

    rom = (ROOT / "baserom.gbc").read_bytes()
    traced = trace.run(rom, hints.extra_entries(rom), hints.DATA_RANGES)
    direct_bytes = sum(traced.code.values())
    if direct_bytes != 37612 or len(traced.loads) != 38:
        fail(
            "tracing baseline changed; review it and update docs deliberately "
            f"(bytes={direct_bytes}, loads={len(traced.loads)})"
        )
    trace.gap_fill(traced, hints.CODE_BANKS, hints.DATA_RANGES)
    total_bytes = sum(traced.code.values())
    if total_bytes != 37612:
        fail(f"gap-fill baseline changed; review it deliberately (bytes={total_bytes})")
    print(
        "trace: "
        f"{direct_bytes} direct bytes, {total_bytes - direct_bytes} heuristic bytes, "
        f"{len(traced.loads)} RAM loads"
    )


def main() -> None:
    check_toolchain()
    entries = read_manifest()
    check_assets(entries)
    check_tracing()
    digest = hashlib.sha1((ROOT / "baserom.gbc").read_bytes()).hexdigest()
    print(f"project: OK ({len(entries)} assets, baserom sha1 {digest})")


if __name__ == "__main__":
    main()
