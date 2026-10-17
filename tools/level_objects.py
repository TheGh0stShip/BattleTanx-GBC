#!/usr/bin/env python3
"""Parse bank-$04 per-level object initialization data."""

from __future__ import annotations

import pathlib
import re
from collections import Counter


BANK = 4
BANK_BASE = BANK * 0x4000
LEVELS = 15
SPAWN_COUNT = 40
SPAWN_SIZE = 12
AUX_COUNT = 8
AUX_SIZE = 8
SPAWN_START = 0x4000
AUX_START = 0x5C20
DIRECTORY = 0x5FE0


class LevelObjectError(ValueError):
    pass


def check(condition: bool, message: str) -> None:
    if not condition:
        raise LevelObjectError(message)


def offset(address: int) -> int:
    return BANK_BASE + address - 0x4000


def word(rom: bytes, address: int) -> int:
    return int.from_bytes(rom[offset(address):offset(address) + 2], "little")


def parse(rom: bytes) -> list[dict]:
    levels = []
    for level in range(LEVELS):
        spawn_address = SPAWN_START + level * SPAWN_COUNT * SPAWN_SIZE
        aux_address = AUX_START + level * AUX_COUNT * AUX_SIZE
        check(word(rom, DIRECTORY + level * 4) == spawn_address,
              f"level {level}: spawn pointer")
        check(word(rom, DIRECTORY + level * 4 + 2) == aux_address,
              f"level {level}: auxiliary pointer")
        spawns = [
            bytes(rom[offset(spawn_address + i * SPAWN_SIZE):
                      offset(spawn_address + (i + 1) * SPAWN_SIZE)])
            for i in range(SPAWN_COUNT)
        ]
        auxiliaries = [
            bytes(rom[offset(aux_address + i * AUX_SIZE):
                      offset(aux_address + (i + 1) * AUX_SIZE)])
            for i in range(AUX_COUNT)
        ]
        check(all(len(record) == SPAWN_SIZE for record in spawns),
              f"level {level}: truncated spawn record")
        check(all(len(record) == AUX_SIZE for record in auxiliaries),
              f"level {level}: truncated auxiliary record")
        for index, record in enumerate(spawns):
            if record[0] & 0x80:
                check(record == bytes.fromhex("800000000080000000000000"),
                      f"level {level} spawn {index}: padding record changed")
            else:
                check(record[0] in (0, 1, 2, 3, 5, 6),
                      f"level {level} spawn {index}: type {record[0]}")
        check(all(record[6] <= 5 for record in auxiliaries),
              f"level {level}: auxiliary enable/type field")
        levels.append({"level": level, "spawn_address": spawn_address,
                       "aux_address": aux_address, "spawns": spawns,
                       "auxiliaries": auxiliaries})
    check(AUX_START == SPAWN_START + LEVELS * SPAWN_COUNT * SPAWN_SIZE,
          "spawn tables do not meet auxiliary tables")
    check(DIRECTORY == AUX_START + LEVELS * AUX_COUNT * AUX_SIZE,
          "auxiliary tables do not meet directory")
    modes = Counter(record[6] for level in levels for record in level["auxiliaries"] if record[6])
    check(modes == Counter({1: 5, 2: 1, 3: 25, 4: 5, 5: 1}),
          f"auxiliary mode counts changed: {dict(modes)}")
    mode5 = [(level["level"], i, record) for level in levels
             for i, record in enumerate(level["auxiliaries"]) if record[6] == 5]
    check(len(mode5) == 1 and mode5[0][0:2] == (5, 1) and mode5[0][2][7] == 0,
          "mode-5 auxiliary link record changed")
    check(levels[5]["auxiliaries"][0][6] == 2,
          "mode-5 auxiliary link no longer targets the level-5 mode-2 record")
    return levels


def read_symbols(path: pathlib.Path) -> dict[str, tuple[int, int]] | None:
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
    source = (root / "src/bank_04.asm").read_text()
    check("assets/bank_04/4000.bin" not in source, "whole prefix blob returned")
    check("assets/bank_04/4000.bin" not in (root / "assets.txt").read_text(),
          "whole prefix asset returned to manifest")
    check("ld b, $28" in source, "40-record initialization loop changed")
    check("ld a, LEVEL_OBJECT_AUX_COUNT" in source,
          "8-record auxiliary copy loop changed")
    normal_mapping = "ld b, $01\n\tld c, OBJECT_TYPE1_FALLBACK_SPEED\n\tand a"
    deferred_mapping = "ld b, $01\n\tld c, OBJECT_TYPE0_FALLBACK_SPEED ; deferred path swaps the type-0/type-1 speeds\n\tand a"
    for snippet in (normal_mapping, deferred_mapping):
        check(snippet in source, "level objects: fallback-speed mapping changed")
    check(source.count("ld c, OBJECT_TYPE1_FALLBACK_SPEED") == 3 and
          source.count("ld c, OBJECT_TYPE0_FALLBACK_SPEED") == 3 and
          source.count("ld c, OBJECT_TYPE2_FALLBACK_SPEED") == 4,
          "level objects: fallback-speed mapping count changed")
    aux_inc = (root / "include/level_objects.inc").read_text()
    expected_modes = {
        "LEVEL_AUX_MODE_TIMER": 1,
        "LEVEL_AUX_MODE_LINKED_REGION": 2,
        "LEVEL_AUX_MODE_PENDING_REGION": 3,
        "LEVEL_AUX_MODE_NONPLAYER_ACTIVE": 4,
        "LEVEL_AUX_MODE_ACTIVATE_LINK": 5,
    }
    modes = {name: int(value, 16) for name, value in re.findall(
        r"^DEF (LEVEL_AUX_MODE_\w+)\s+EQU \$([0-9A-F]+)", aux_inc, re.MULTILINE)}
    check(modes == expected_modes, f"level objects: auxiliary mode constants changed: {modes}")
    memory = (root / "include/memory.inc").read_text()
    definitions = {
        name: int(address, 16)
        for name, address in re.findall(
            r"^DEF\s+(\w+)\s+EQU\s+\$([0-9A-Fa-f]+)", memory, re.MULTILINE
        )
    }
    expected_memory = {
        "wLevelObjectSpawnTable": 0xCD1E,
        "wLevelObjectAuxTable": 0xCD20,
        "wObjectSlowTickCounter": 0xCD27,
        "wPendingLevelObjectQueue": 0xCD33,
        "wLevelObjectAuxState": 0xCD6F,
    }
    for name, address in expected_memory.items():
        check(definitions.get(name) == address,
              f"memory symbol {name} is {definitions.get(name)}, expected {address:#06x}")
    symbols = read_symbols(root / "battletanx.sym")
    if symbols is not None:
        expected = {
            "LevelObjectDataPointers": (BANK, DIRECTORY),
            "InitializeLevelObjects": (BANK, 0x601C),
            "QueuePendingLevelObject": (BANK, 0x6343),
            "UpdatePendingLevelObjects": (BANK, 0x6392),
            "TrySpawnPendingLevelObject": (BANK, 0x63D0),
            "AbsoluteDifferenceBCDE": (BANK, 0x655C),
            "QueuePendingLevelObjectFar": (0x00, 0x37DF),
            "UpdatePendingLevelObjectsFar": (0x00, 0x37F0),
        }
        for level in levels:
            number = level["level"]
            expected[f"Level{number:02}ObjectSpawns"] = (BANK, level["spawn_address"])
            expected[f"Level{number:02}ObjectAuxRecords"] = (BANK, level["aux_address"])
        for name, where in expected.items():
            check(symbols.get(name) == where,
                  f"symbol {name} is at {symbols.get(name)}, expected {where}")

    cases = []
    changed = bytearray(rom)
    changed[offset(DIRECTORY)] ^= 1
    cases.append((bytes(changed), "spawn pointer"))
    changed = bytearray(rom)
    padding = next(record for level in levels for record in level["spawns"] if record[0] & 0x80)
    address = rom.find(padding, offset(SPAWN_START), offset(AUX_START)) - BANK_BASE + 0x4000
    changed[offset(address) + 1] = 1
    cases.append((bytes(changed), "padding record"))
    changed = bytearray(rom)
    changed[offset(AUX_START) + 6] = 6
    cases.append((bytes(changed), "auxiliary enable/type"))
    changed = bytearray(rom)
    mode5_address = AUX_START + (5 * AUX_COUNT + 1) * AUX_SIZE
    changed[offset(mode5_address) + 7] = 1
    cases.append((bytes(changed), "mode-5 auxiliary link record"))
    for data, expected in cases:
        try:
            parse(data)
        except LevelObjectError as exc:
            check(expected in str(exc), f"negative test failed for wrong reason: {exc}")
        else:
            raise LevelObjectError(f"negative test not rejected: {expected}")

    active = sum(not record[0] & 0x80 for level in levels for record in level["spawns"])
    enabled_aux = sum(record[6] != 0 for level in levels for record in level["auxiliaries"])
    return (f"level objects: {LEVELS} levels, {active}/{LEVELS * SPAWN_COUNT} active "
            f"spawn records, {enabled_aux}/{LEVELS * AUX_COUNT} enabled auxiliary records in 5 modes, "
            f"{len(cases)} negative tests rejected")


if __name__ == "__main__":
    print(validate_project(pathlib.Path(__file__).resolve().parent.parent))
