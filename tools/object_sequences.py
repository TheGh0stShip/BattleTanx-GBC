#!/usr/bin/env python3
"""Parse and validate the per-level object sequences in bank $03."""

from __future__ import annotations

import pathlib
import re


BANK = 0x03
BANK_BASE = BANK * 0x4000
DATA_START = 0x4018
LEVEL_TABLE = 0x5BF3
LEVEL_COUNT = 15
SLOTS = 64
POINT_SIZE = 8


class SequenceError(ValueError):
    pass


def check(condition: bool, message: str) -> None:
    if not condition:
        raise SequenceError(message)


def offset(address: int) -> int:
    return BANK_BASE + address - 0x4000


def word(rom: bytes, address: int) -> int:
    return int.from_bytes(rom[offset(address):offset(address) + 2], "little")


def parse(rom: bytes) -> list[dict]:
    check(rom[offset(0x4000):offset(DATA_START)] == bytes.fromhex(
        "0040400008383808103030101828321820202020408000c0"
    ), "direction lookup tables changed")
    starts = [word(rom, LEVEL_TABLE + 2 * level) for level in range(LEVEL_COUNT)]
    check(starts[0] == DATA_START and starts == sorted(starts), "level sequence table order")
    levels = []
    for level, start in enumerate(starts):
        end = starts[level + 1] if level + 1 < LEVEL_COUNT else LEVEL_TABLE
        check(start + SLOTS * 2 <= end, f"level {level}: pointer table exceeds block")
        pointers = [word(rom, start + 2 * slot) for slot in range(SLOTS)]
        active = [(slot, pointer) for slot, pointer in enumerate(pointers) if pointer]
        check(active, f"level {level}: no sequences")
        targets = [pointer for _, pointer in active]
        check(targets == sorted(set(targets)), f"level {level}: sequence pointers are not ordered")
        check(targets[0] == start + SLOTS * 2, f"level {level}: gap after pointer table")
        sequences = []
        for index, (slot, pointer) in enumerate(active):
            sequence_end = targets[index + 1] if index + 1 < len(targets) else end
            check(pointer < sequence_end <= end, f"level {level} slot {slot}: bad bounds")
            count = rom[offset(pointer)]
            check(count > 0, f"level {level} slot {slot}: empty sequence")
            check(pointer + 1 + count * POINT_SIZE == sequence_end,
                  f"level {level} slot {slot}: count does not meet next sequence")
            points = [
                bytes(rom[offset(pointer + 1 + i * POINT_SIZE):
                          offset(pointer + 1 + (i + 1) * POINT_SIZE)])
                for i in range(count)
            ]
            check(all(len(point) == POINT_SIZE for point in points),
                  f"level {level} slot {slot}: truncated point")
            check(all(point[2] <= 2 and point[5] in (0, 2, 5) for point in points),
                  f"level {level} slot {slot}: record fields outside observed format")
            sequences.append({"slot": slot, "address": pointer, "points": points})
        levels.append({"level": level, "start": start, "end": end,
                       "pointers": pointers, "sequences": sequences})
    return levels


def symbols(path: pathlib.Path) -> dict[str, tuple[int, int]] | None:
    if not path.exists():
        return None
    result = {}
    for line in path.read_text().splitlines():
        match = re.fullmatch(r"([0-9A-Fa-f]{2}):([0-9A-Fa-f]{4}) (\S+)", line.strip())
        if match:
            result[match.group(3)] = (int(match.group(1), 16), int(match.group(2), 16))
    return result


def validate_project(root: pathlib.Path) -> str:
    rom = (root / "baserom.gbc").read_bytes()
    levels = parse(rom)
    source = (root / "src/bank_03.asm").read_text()
    check('assets/bank_03/4000.bin' not in source, "whole prefix blob returned")
    check('assets/bank_03/4000.bin' not in (root / "assets.txt").read_text(),
          "whole prefix asset returned to manifest")
    table = symbols(root / "battletanx.sym")
    if table is not None:
        expected = {
            "SignedVectorDirectionLookup": (BANK, 0x4000),
            "SignedVectorQuadrantOffsets": (BANK, 0x4014),
            "LevelObjectSequenceTables": (BANK, LEVEL_TABLE),
            "InitializeObjectSequenceState": (BANK, 0x5C11),
            "InitializeObjectSequenceStateFar": (0x00, 0x3801),
            "QuantizeSignedVectorDirection": (BANK, 0x67FA),
            "StateCheckTable": (BANK, 0x685A),
            "DispatchStateCheck": (BANK, 0x6878),
        }
        for level, address in enumerate((
            0x6887, 0x688F, 0x689D, 0x68A5, 0x68AD,
            0x68B5, 0x68BD, 0x68C5, 0x68CD, 0x68DB,
            0x68E9, 0x68F1, 0x68F9, 0x6901, 0x6909,
        )):
            expected[f"Level{level:02}StateCheck"] = (BANK, address)
        for level in levels:
            expected[f"Level{level['level']:02}ObjectSequences"] = (BANK, level["start"])
            for sequence in level["sequences"]:
                expected[f"Level{level['level']:02}ObjectSequence{sequence['slot']:02}"] = (
                    BANK, sequence["address"]
                )
        for name, where in expected.items():
            check(table.get(name) == where, f"symbol {name} is at {table.get(name)}, expected {where}")

    cases = []
    changed = bytearray(rom)
    changed[offset(DATA_START)] = 0
    changed[offset(DATA_START) + 1] = 0
    cases.append((bytes(changed), "gap after pointer table"))
    first = levels[0]["sequences"][0]["address"]
    changed = bytearray(rom)
    changed[offset(first)] += 1
    cases.append((bytes(changed), "count does not meet"))
    changed = bytearray(rom)
    changed[offset(first + 1) + 2] = 3
    cases.append((bytes(changed), "record fields"))
    changed = bytearray(rom)
    changed[offset(0x4000)] ^= 1
    cases.append((bytes(changed), "direction lookup"))
    for data, expected in cases:
        try:
            parse(data)
        except SequenceError as exc:
            check(expected in str(exc), f"negative test failed for wrong reason: {exc}")
        else:
            raise SequenceError(f"negative test not rejected: {expected}")

    sequence_count = sum(len(level["sequences"]) for level in levels)
    record_count = sum(len(sequence["points"]) for level in levels for sequence in level["sequences"])
    return (f"object sequences: {LEVEL_COUNT} level tables, {sequence_count} sequences, "
            f"{record_count} records, {len(cases)} negative tests rejected")


if __name__ == "__main__":
    print(validate_project(pathlib.Path(__file__).resolve().parent.parent))
