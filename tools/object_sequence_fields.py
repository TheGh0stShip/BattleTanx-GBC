#!/usr/bin/env python3
"""Field-level invariants of the bank $03 object sequence records.

tools/object_sequences.py checks the layout (pointer tables, counts, packing).
This checks what the readers in bank $03 depend on, and pins the known
exceptions so a data change cannot slip past silently:

  SEQ03  2..6 records per sequence (the initialiser reads record 1 as the first
         target); 203 sequences, 626 records
  SEQ04  heading byte +0 < 16 (copied unmasked into object +$2F; rotation compares
         against a value masked with $0F)
  SEQ05  end action +5 in {0, 2, 5}
  SEQ06  record 0 never has action 2; every last record has action 2 except
         TERMINAL_EXCEPTIONS, whose forward target read runs past the sequence
  SEQ07  records after an earlier action-2 record are unreachable; exactly
         UNREACHABLE
  SEQ08  +7 == +6 (no reader of +7)
  SEQ09  +1/+2 (no reader) is the little-endian pixel distance 8*(|dX|+|dY|) to
         the next waypoint, except DISTANCE_EXCEPTIONS
  SEQ10  consecutive waypoints differ in one axis and +0 points along it
         (0 -Y, 4 +X, 8 +Y, 12 -X), except HEADING_EXCEPTIONS
  SEQ11  waypoint tiles X <= $99, Y <= $74
Usage: object_sequence_fields.py
"""
from __future__ import annotations

import pathlib
import re
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import object_sequences as S  # noqa: E402
import level_objects as O  # noqa: E402
import level_data as L  # noqa: E402

SEQUENCES, RECORDS = 203, 626
TERMINAL_EXCEPTIONS = {(3, 6): 5, (6, 15): 0}
UNREACHABLE = {(6, 11, 2), (6, 12, 2), (6, 14, 2), (8, 2, 2)}
DISTANCE_EXCEPTIONS = {(3, 2, 2): (9, 8)}
HEADING_EXCEPTIONS = {(3, 2, 2): 0x0B, (3, 11, 0): 0x05}
AXIS = {0: (0, -1), 4: (1, 0), 8: (0, 1), 12: (-1, 0)}
UNUSED_SEQUENCES = {(3, 11), (9, 1), (9, 2), (10, 17)}
TERMINAL_EXCEPTION_SPAWNS = {(3, 6): (14,), (6, 15): (12,)}
TERMINAL_EXCEPTION_OVERREADS = {
    (3, 6): bytes.fromhex("040c30003a220000"),
    (6, 15): bytes.fromhex("244d3d4d564d774d"),
}


class FieldError(ValueError):
    pass


def check(cond, msg):
    if not cond:
        raise FieldError(msg)


def sign(v):
    return (v > 0) - (v < 0)


def validate(rom: bytes) -> tuple[int, int]:
    try:
        levels = S.parse(rom)
    except S.SequenceError as exc:
        raise FieldError(f"layout: {exc}") from exc
    seqs = [(lv["level"], s["slot"], s["points"]) for lv in levels for s in lv["sequences"]]
    check(len(seqs) == SEQUENCES and sum(len(p) for *_, p in seqs) == RECORDS,
          f"SEQ03: {len(seqs)} sequences / {sum(len(p) for *_, p in seqs)} records")
    unreachable = set()
    for lv, slot, pts in seqs:
        where = f"level {lv} slot {slot}"
        check(2 <= len(pts) <= 6, f"SEQ03: {where} has {len(pts)} records")
        for i, p in enumerate(pts):
            check(p[0] < 16, f"SEQ04: {where} record {i} heading ${p[0]:02X}")
            check(p[5] in (0, 2, 5), f"SEQ05: {where} record {i} action {p[5]}")
            check(p[7] == p[6], f"SEQ08: {where} record {i} +7 differs from +6")
            check(p[3] <= 0x99 and p[4] <= 0x74, f"SEQ11: {where} record {i} tile out of range")
            if any(q[5] == 2 for q in pts[:i]):
                unreachable.add((lv, slot, i))
        check(pts[0][5] != 2, f"SEQ06: {where} record 0 has action 2")
        last = pts[-1][5]
        if (lv, slot) in TERMINAL_EXCEPTIONS:
            check(last == TERMINAL_EXCEPTIONS[(lv, slot)], f"SEQ06: {where} terminal exception list is stale")
        else:
            check(last == 2, f"SEQ06: {where} terminal action not 2")
        for i in range(len(pts) - 1):
            a, b = pts[i], pts[i + 1]
            dx, dy = b[3] - a[3], b[4] - a[4]
            stored, want = a[1] | a[2] << 8, 8 * (abs(dx) + abs(dy))
            key = (lv, slot, i)
            if key in DISTANCE_EXCEPTIONS:
                check((stored, want) == DISTANCE_EXCEPTIONS[key], f"SEQ09: {where} record {i} distance exception is stale")
            else:
                check(stored == want, f"SEQ09: {where} record {i} distance {stored} != {want}")
            on_axis = (dx == 0) != (dy == 0) and AXIS.get(a[0]) == (sign(dx), sign(dy))
            if key in HEADING_EXCEPTIONS:
                check(a[0] == HEADING_EXCEPTIONS[key] and not on_axis, f"SEQ10: {where} record {i} heading exception is stale")
            else:
                check(on_axis, f"SEQ10: {where} record {i} heading ${a[0]:02X} does not point at the next waypoint")
    check(unreachable == UNREACHABLE, f"SEQ07: unreachable records {sorted(unreachable ^ UNREACHABLE)} differ from the list")
    try:
        objects = O.parse(rom)
    except O.LevelObjectError as exc:
        raise FieldError(f"SEQ12: level objects: {exc}") from exc
    sequence_keys = {(lv, slot) for lv, slot, _ in seqs}
    references = {}
    for level in objects:
        for index, record in enumerate(level["spawns"]):
            # Padding, type-6 effects, and records with byte-5 bit 7 set do not
            # take InitializeLevelObjects' ordinary sequence path.
            if record[0] & 0x80 or record[0] == 6 or record[5] & 0x80:
                continue
            key = (level["level"], record[5] & 0x3F)
            references.setdefault(key, []).append(index)
            check(key in sequence_keys,
                  f"SEQ12: level {key[0]} spawn {index} selects missing sequence slot {key[1]}")
    unused = sequence_keys - set(references)
    check(unused == UNUSED_SEQUENCES,
          f"SEQ12: unused sequences {sorted(unused ^ UNUSED_SEQUENCES)} differ from the list")
    exception_spawns = {key: tuple(references.get(key, ())) for key in TERMINAL_EXCEPTIONS}
    check(exception_spawns == TERMINAL_EXCEPTION_SPAWNS,
          f"SEQ12: terminal-exception spawn references changed: {exception_spawns}")
    level_data = L.parse_levels(rom)
    for key, spawn_indices in TERMINAL_EXCEPTION_SPAWNS.items():
        level, slot = key
        sequence = next(points for lv, candidate, points in seqs
                        if (lv, candidate) == key)
        spawn = objects[level]["spawns"][spawn_indices[0]]
        check(spawn[0] in (0, 1, 2),
              f"SEQ13: level {level} slot {slot} is no longer a persistent vehicle")
        start = (int.from_bytes(spawn[1:3], "little") // 8,
                 int.from_bytes(spawn[3:5], "little") // 8)
        check(start == (sequence[0][3], sequence[0][4]),
              f"SEQ13: level {level} slot {slot} spawn no longer starts at waypoint 0")
        lv = level_data[level]
        cells = L.read(rom, lv.cell_bank, lv.cellmap_addr, lv.cells)
        for i in range(len(sequence) - 1):
            x0, y0 = sequence[i][3], sequence[i][4]
            x1, y1 = sequence[i + 1][3], sequence[i + 1][4]
            dx, dy = sign(x1 - x0), sign(y1 - y0)
            x, y = x0, y0
            while True:
                check(cells[y * lv.width + x] & 1,
                      f"SEQ13: level {level} slot {slot} route blocked at ({x}, {y})")
                if (x, y) == (x1, y1):
                    break
                x, y = x + dx, y + dy
        end = next(s["address"] + 1 + 8 * len(s["points"])
                   for parsed in levels for s in parsed["sequences"]
                   if (parsed["level"], s["slot"]) == key)
        got = rom[S.offset(end):S.offset(end) + 8]
        check(got == TERMINAL_EXCEPTION_OVERREADS[key],
              f"SEQ14: level {level} slot {slot} overread bytes changed")
    return len(seqs), sum(len(p) for *_, p in seqs)


def negative_tests(rom: bytes) -> int:
    levels = S.parse(rom)
    first = {(lv["level"], s["slot"]): s["address"] for lv in levels for s in lv["sequences"]}

    def rec(lv, slot, i, field):
        return S.offset(first[(lv, slot)] + 1 + 8 * i + field)

    base = levels[0]["sequences"][0]
    n0 = len(base["points"])
    cases = [
        ("heading", {rec(0, base["slot"], 0, 0): 0x10}, "SEQ04"),
        ("action", {rec(0, base["slot"], 0, 5): 3}, "layout"),  # also outside the layout parser's observed set
        ("terminal", {rec(0, base["slot"], n0 - 1, 5): 0}, "SEQ06: level 0"),
        ("terminal list", {rec(3, 6, len(next(s for lv in levels for s in lv["sequences"] if lv["level"] == 3 and s["slot"] == 6)["points"]) - 1, 5): 2}, "terminal exception list is stale"),
        ("unreachable", {rec(0, base["slot"], 1, 5): 2}, "SEQ07"),
        ("field 7", {rec(0, base["slot"], 0, 7): rom[rec(0, base["slot"], 0, 7)] ^ 1}, "SEQ08"),
        ("distance", {rec(0, base["slot"], 0, 1): (rom[rec(0, base["slot"], 0, 1)] + 8) & 0xFF}, "SEQ09"),
        ("distance list", {rec(3, 2, 2, 1): 8}, "distance exception is stale"),
        ("heading axis", {rec(0, base["slot"], 0, 0): (rom[rec(0, base["slot"], 0, 0)] + 4) & 0x0F}, "SEQ10"),
        ("tile range", {rec(0, base["slot"], n0 - 1, 3): 0xFF}, "SEQ11"),
    ]
    objects = O.parse(rom)
    first_spawn = next((level, i, record) for level in objects for i, record in enumerate(level["spawns"])
                       if not record[0] & 0x80 and record[0] != 6 and not record[5] & 0x80)
    level, index, _ = first_spawn
    spawn_slot_offset = O.offset(level["spawn_address"] + index * O.SPAWN_SIZE + 5)
    cases.append(("spawn sequence reference", {spawn_slot_offset: 0x3F}, "SEQ12: level 0"))
    level3 = L.parse_levels(rom)[3]
    route_address = level3.cellmap_addr + 10 * level3.width + 73
    route_cell = level3.cell_bank * L.BANK_SIZE + route_address - 0x4000
    cases.append(("terminal route", {route_cell: 0x00}, "SEQ13: level 3 slot 6 route blocked"))
    level3_slot6 = next(s for lv in levels for s in lv["sequences"]
                        if (lv["level"], s["slot"]) == (3, 6))
    overread = S.offset(level3_slot6["address"] + 1 + 8 * len(level3_slot6["points"]))
    # The pseudo-record begins at sequence 7's count byte, so corruption is
    # rejected first by the underlying sequence-layout check.
    cases.append(("terminal overread", {overread: rom[overread] ^ 1}, "layout: level 3 slot 7"))
    n = 0
    for name, changes, expect in cases:
        data = bytearray(rom)
        for o, v in changes.items():
            data[o] = v
        try:
            validate(bytes(data))
        except FieldError as exc:
            check(expect in str(exc), f"negative test {name} rejected for the wrong reason: {exc}")
            n += 1
        else:
            raise FieldError(f"negative test not rejected: {name}")
    return n


def validate_source(root: pathlib.Path) -> int:
    inc = (root / "include/object.inc").read_text()
    definitions = {name: int(value, 16) for name, value in re.findall(
        r"^DEF (OBJECT_(?:SEQUENCE_\w+|RESPAWNS_LEFT|LEVEL_SPAWN_INDEX_FLAGS)_OFFSET)\s+EQU \$([0-9A-F]+)",
        inc, re.MULTILINE)}
    expected = {
        "OBJECT_SEQUENCE_SLOT_FLAGS_OFFSET": 0x2D,
        "OBJECT_SEQUENCE_RECORD_INDEX_OFFSET": 0x2E,
        "OBJECT_SEQUENCE_TARGET_HEADING_OFFSET": 0x2F,
        "OBJECT_SEQUENCE_TURN_DELAY_OFFSET": 0x30,
        "OBJECT_SEQUENCE_REVERSE_FLAG_OFFSET": 0x31,
        "OBJECT_SEQUENCE_TURN_STEP_OFFSET": 0x32,
        "OBJECT_SEQUENCE_PROXIMITY_DELAY_OFFSET": 0x33,
        "OBJECT_SEQUENCE_TARGET_X_OFFSET": 0x34,
        "OBJECT_SEQUENCE_TARGET_Y_OFFSET": 0x36,
        "OBJECT_SEQUENCE_MOVEMENT_STATE_OFFSET": 0x38,
        "OBJECT_SEQUENCE_FALLBACK_SPEED_OFFSET": 0x39,
        "OBJECT_RESPAWNS_LEFT_OFFSET": 0x3A,
        "OBJECT_LEVEL_SPAWN_INDEX_FLAGS_OFFSET": 0x3B,
        "OBJECT_SEQUENCE_ACTION_TIMER_OFFSET": 0x3C,
    }
    check(definitions == expected, f"source: object sequence field constants changed: {definitions}")
    source = (root / "src/bank_03.asm").read_text() + (root / "src/bank_04.asm").read_text()
    for value in expected.values():
        check(f"add a, ${value:02X}" not in source,
              f"source: raw object sequence offset ${value:02X} remains")
    return len(expected)


def main():
    root = pathlib.Path(__file__).resolve().parent.parent
    rom = (root / "baserom.gbc").read_bytes()
    seqs, recs = validate(rom)
    fields = validate_source(root)
    neg = negative_tests(rom)
    print(f"object sequence fields: {seqs} sequences, {recs} records, 199 spawn-selected, "
          f"{len(UNUSED_SEQUENCES)} unused, "
          f"{len(TERMINAL_EXCEPTIONS) + len(UNREACHABLE) + len(DISTANCE_EXCEPTIONS) + len(HEADING_EXCEPTIONS)} pinned exceptions; "
          f"{fields} field constants, {neg} negative tests rejected")


if __name__ == "__main__":
    main()
