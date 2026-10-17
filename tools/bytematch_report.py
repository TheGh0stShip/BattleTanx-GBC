#!/usr/bin/env python3
"""Build an objdiff v2 byte-match report from the whole-ROM range map.

This reports reconstruction only: a byte is matched when the assembled ROM
matches the verified USA cartridge.  It deliberately does not treat byte
identity as evidence that a routine or data format is understood.
"""

from __future__ import annotations

import hashlib
import json
import sys
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EXPECTED_SHA1 = "5078584e86c0b6f4687c424cc00bbd762ba6573a"
ROM_SIZE = 64 * 0x4000
CODE_KINDS = {"code", "code untraced", "ram code"}
PADDING_KINDS = {"fill", "marker"}


def fail(message: str) -> None:
    raise SystemExit(f"bytematch report: {message}")


def percent(matched: int, total: int) -> float:
    return 100.0 if total == 0 or matched == total else matched * 100.0 / total


def measures(code: int, data: int, functions: int, units: int) -> dict:
    return {
        "fuzzy_match_percent": percent(code + data, code + data),
        "total_code": str(code),
        "matched_code": str(code),
        "matched_code_percent": percent(code, code),
        "total_data": str(data),
        "matched_data": str(data),
        "matched_data_percent": percent(data, data),
        "total_functions": functions,
        "matched_functions": functions,
        "matched_functions_percent": percent(functions, functions),
        "complete_code": str(code),
        "complete_code_percent": percent(code, code),
        "complete_data": str(data),
        "complete_data_percent": percent(data, data),
        "total_units": units,
        "complete_units": units,
    }


def load_ranges(path: Path) -> list[dict]:
    raw = json.loads(path.read_text())
    table = raw.get("ranges", {})
    columns = table.get("columns")
    rows = table.get("rows")
    if not isinstance(columns, list) or not isinstance(rows, list):
        fail(f"invalid range map {path}")
    return [dict(zip(columns, row, strict=True)) for row in rows]


def validate_ranges(ranges: list[dict], rom: bytes) -> None:
    cursors = {0: 0, **{bank: 0x4000 for bank in range(1, 64)}}
    for row in ranges:
        start, end = row["start"], row["end"]
        bank = row["bank"]
        if start != cursors[bank]:
            fail(f"range map gap or overlap in bank ${bank:02X} at 0x{cursors[bank]:04X}")
        limit = 0x4000 if bank == 0 else 0x8000
        if not cursors[bank] <= start < end <= limit:
            fail(f"invalid range in bank ${bank:02X}: 0x{start:X}-0x{end:X}")
        rom_start = start if bank == 0 else bank * 0x4000 + start - 0x4000
        digest = hashlib.sha1(rom[rom_start:rom_start + end - start]).hexdigest()[:12]
        if digest != row["sha1"]:
            fail(f"stale range {row['label'] or hex(start)}")
        cursors[bank] = end
    for bank, cursor in cursors.items():
        expected = 0x4000 if bank == 0 else 0x8000
        if cursor != expected:
            fail(f"range map for bank ${bank:02X} ends at 0x{cursor:X}, expected 0x{expected:X}")


def rom_offset(row: dict) -> int:
    return row["start"] if row["bank"] == 0 else row["bank"] * 0x4000 + row["start"] - 0x4000


def item_name(row: dict) -> str:
    label = row["label"] or row["kind"].replace(" ", "_").title()
    return f"{label} [{row['bank']:02X}:{row['start']:04X}]"


def report(ranges: list[dict]) -> dict:
    by_bank: dict[int, list[dict]] = defaultdict(list)
    category_sizes = defaultdict(int)
    for row in ranges:
        by_bank[row["bank"]].append(row)
        size = row["end"] - row["start"]
        category = "code" if row["kind"] in CODE_KINDS else "padding" if row["kind"] in PADDING_KINDS else "data"
        category_sizes[category] += size

    units = []
    for bank in range(64):
        rows = by_bank[bank]
        code = sum(r["end"] - r["start"] for r in rows if r["kind"] in CODE_KINDS)
        data = 0x4000 - code
        funcs = [r for r in rows if r["kind"] in CODE_KINDS]
        sections = []
        for row in rows:
            sections.append({
                "name": item_name(row),
                "size": str(row["end"] - row["start"]),
                "fuzzy_match_percent": 100.0,
                "address": str(rom_offset(row)),
                "metadata": {"virtual_address": str(rom_offset(row))},
            })
        functions = [
            {
                "name": item_name(row),
                "size": str(row["end"] - row["start"]),
                "fuzzy_match_percent": 100.0,
                "address": str(rom_offset(row)),
                "metadata": {"virtual_address": str(rom_offset(row))},
            }
            for row in funcs
        ]
        categories = []
        if code:
            categories.append("code")
        if any(r["kind"] not in CODE_KINDS | PADDING_KINDS for r in rows):
            categories.append("data")
        if any(r["kind"] in PADDING_KINDS for r in rows):
            categories.append("padding")
        units.append({
            "name": f"ROM bank ${bank:02X}",
            "measures": measures(code, data, len(functions), 1),
            "sections": sections,
            "functions": functions,
            "metadata": {
                "complete": True,
                "source_path": f"src/bank_{bank:02X}.asm",
                "progress_categories": categories,
            },
        })

    code_size = category_sizes["code"]
    function_count = sum(len(unit["functions"]) for unit in units)
    categories = [
        {"id": "code", "name": "Program and RAM-executed code", "measures": measures(code_size, 0, function_count, 64)},
        {"id": "data", "name": "Data and assets", "measures": measures(0, category_sizes["data"], 0, 64)},
        {"id": "padding", "name": "Padding and bank markers", "measures": measures(0, category_sizes["padding"], 0, 64)},
    ]
    return {
        "measures": measures(code_size, ROM_SIZE - code_size, function_count, 64),
        "units": units,
        "version": 2,
        "categories": categories,
    }


def main() -> None:
    values = {
        "--rom": ROOT / "battletanx.gbc",
        "--ranges": ROOT / "reports/rom_range_map.json",
        "--out": ROOT / "report.json",
    }
    argv = iter(sys.argv[1:])
    for option in argv:
        if option not in values:
            fail(f"unknown option {option}")
        try:
            values[option] = Path(next(argv))
        except StopIteration:
            fail(f"missing value for {option}")

    rom = values["--rom"].read_bytes()
    if len(rom) != ROM_SIZE:
        fail(f"ROM size is {len(rom)}, expected {ROM_SIZE}")
    digest = hashlib.sha1(rom).hexdigest()
    if digest != EXPECTED_SHA1:
        fail(f"ROM SHA-1 is {digest}, expected {EXPECTED_SHA1}")

    ranges = load_ranges(values["--ranges"])
    validate_ranges(ranges, rom)
    value = report(ranges)
    values["--out"].write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")
    m = value["measures"]
    print(
        "bytematch report: "
        f"{m['matched_code']}/{m['total_code']} code bytes, "
        f"{m['matched_data']}/{m['total_data']} data bytes, "
        f"{m['matched_functions']}/{m['total_functions']} code ranges"
    )


if __name__ == "__main__":
    main()
