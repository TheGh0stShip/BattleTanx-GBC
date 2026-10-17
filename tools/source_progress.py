#!/usr/bin/env python3
"""Report evidence-based names attached to automatic function labels."""

from __future__ import annotations

import pathlib
import re
import sys
from collections import defaultdict


SYMBOL_RE = re.compile(r"([0-9A-Fa-f]{2}):([0-9A-Fa-f]{4}) (\S+)$")
AUTO_FUNCTION_RE = re.compile(r"Func_(?:[0-9A-F]{2}_)?[0-9A-F]{4}$")


def read_symbols(path: pathlib.Path) -> dict[tuple[int, int], list[str]]:
    addresses: dict[tuple[int, int], list[str]] = defaultdict(list)
    for line_number, line in enumerate(path.read_text().splitlines(), 1):
        match = SYMBOL_RE.fullmatch(line.strip())
        if not match:
            continue
        key = (int(match.group(1), 16), int(match.group(2), 16))
        name = match.group(3)
        if name in addresses[key]:
            raise ValueError(f"{path}:{line_number}: duplicate symbol {name}")
        addresses[key].append(name)
    if not addresses:
        raise ValueError(f"{path}: no RGBDS symbols found")
    return addresses


def is_companion_name(name: str) -> bool:
    """Return whether a same-address label is a reviewed, nonautomatic name."""
    return (
        not AUTO_FUNCTION_RE.fullmatch(name)
        and not name.startswith(("Jump_", "RAM_"))
        and "." not in name
    )


def summarize(path: pathlib.Path) -> tuple[int, int]:
    symbols = read_symbols(path)
    by_bank: dict[int, list[bool]] = defaultdict(list)

    for (bank, _address), names in symbols.items():
        automatic = [name for name in names if AUTO_FUNCTION_RE.fullmatch(name)]
        if not automatic:
            continue
        if len(automatic) != 1:
            raise ValueError(
                f"{path}: expected one automatic function label at "
                f"{bank:02X}:{_address:04X}, found {automatic}"
            )
        by_bank[bank].append(any(is_companion_name(name) for name in names))

    total = sum(len(entries) for entries in by_bank.values())
    named = sum(sum(entries) for entries in by_bank.values())
    if not total:
        raise ValueError(f"{path}: no automatic function labels found")

    print("source names: reviewed companions for automatic function entries")
    for bank in sorted(by_bank):
        entries = by_bank[bank]
        recovered = sum(entries)
        print(
            f"  bank ${bank:02X}: {recovered}/{len(entries)} named; "
            f"{len(entries) - recovered} remain"
        )
    print(f"source names: {named}/{total} named; {total - named} remain")
    return named, total


def main() -> None:
    if len(sys.argv) > 2:
        raise SystemExit(f"usage: {pathlib.Path(sys.argv[0]).name} [SYMBOLS]")
    symbols = pathlib.Path(sys.argv[1] if len(sys.argv) == 2 else "battletanx.sym")
    try:
        summarize(symbols)
    except (OSError, ValueError) as exc:
        raise SystemExit(f"source names: {exc}") from exc


if __name__ == "__main__":
    main()
