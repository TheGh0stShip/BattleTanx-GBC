#!/usr/bin/env python3
"""Relocation (shift) tests for banks $01-$05, using tools/shift_test.py's engine.

Each case inserts padding before one label in a scratch copy, assembles without
baserom.gbc, and requires either a clean relocation (every changed byte is a
pointer that moved with its target) or an assembly stop from a documented ASSERT.
Usage: shift_test_01_05.py [ROOT]
"""
import pathlib
import sys
import tempfile

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import shift_test as S  # noqa: E402

CASES = [
    ("menu-state record MenuState03", "src/bank_01.asm", "MenuState03", "relocate", 1,
     "ROM0 now names the table by label (formerly a raw pinned address)"),
    ("entity callback target (first pickup handler)", "src/bank_01.asm", "PickupRestoreQuarterHealth", "fail-safe", 0,
     "shifts ScoreThresholdTable ($418F) and LevelRowSceneFlags, both raw in ROM0; pinned"),
    ("fixed-scene descriptor table", "src/bank_01.asm", "SceneBackgroundDescriptors", "relocate", 1,
     "ROM0 now names the table by label (formerly a raw pinned address)"),
    ("bank $01 password glyph table (after the ROM0-pinned tables)", "src/bank_01.asm", "PasswordGlyphTiles", "relocate", 2,
     "Func_01_6789 operands are labels"),
    ("cross-bank pointer table target: screen package in bank $2B", "src/bank_2B.asm", "Func_2B_4000", "relocate", 8,
     "ScreenModeTable uses BANK(label) and label operands"),
    ("level record table", "src/bank_05.asm", "LevelRecordPointers", "fail-safe", 0,
     "ASSERT LevelRecordPointers == $4300 (fixed layout of bank $05 used by ROM0)"),
    ("object animation frame table", "src/bank_02.asm", "ObjectAnimationFrames4565", "relocate", 9,
     "frame tables are stored into object field +$21 through labels"),
    ("bank $03 object sequence", "src/level_object_sequences.asm", "Level02ObjectSequence02", "relocate", 1,
     "LevelObjectSequenceTables entries are symbolic"),
    ("bank $04 spawn-record table", "src/level_objects.asm", "Level03ObjectSpawns", "relocate", 1,
     "per-level spawn pointers are symbolic"),
    ("bank $05 screen-effect step table", "src/screen_effect_tables.asm", "ScreenEffectSteps", "relocate", 1,
     "ROM0 now names the table by label (formerly a raw pinned address)"),
    ("RAM-code source image (bank $02 interrupt handler image)", "src/bank_02.asm", "PaletteStatHandlerImage", "relocate", 1,
     "CopyBytes source operands use the ROM-side label; RAM labels keep their run-time addresses"),
    ("RAM-code source image in bank $01", "src/bank_01.asm", "InitMenuSystemRomImage", "relocate", 1,
     "ROM0 now names the table by label (formerly a raw pinned address)"),
    ("data block referenced by a raw ROM0 address", "src/bank_01.asm", "ScoreThresholdTable", "relocate", 1,
     "ROM0 now names the table by label (formerly a raw pinned address)"),
    ("alignment-sensitive HDMA source", "src/bank_30.asm", "FixedScene07Tiles", "fail-safe", 0,
     "8-byte move breaks the 16-byte HDMA alignment ASSERT", 8),
    ("final pass: named bank $01 scroll routine", "src/bank_01.asm", "ScrollSceneInFromLeft", "relocate", 2,
     "callers and the RAM-image call use the label"),
    ("final pass: named bank $01 entry before the formerly pinned tables", "src/bank_01.asm", "ClearPasswordEntryChars", "relocate", 1,
     "ROM0 now names the table by label (formerly a raw pinned address)"),
    ("final pass: named bank $03 recorded-path appender", "src/bank_03.asm", "AppendRecordedPathWaypoint", "relocate", 1,
     "only caller uses the label"),
]


def main():
    root = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    with tempfile.TemporaryDirectory() as tmp:
        t = pathlib.Path(tmp)
        S.copy_tree(root, t)
        base, err = S.build(t)
    if base is None:
        print(f"shift 01-05: unmodified build failed: {err}")
        return 1
    ok_all = True
    for case in CASES:
        name, rel, label, mode, min_refs, reason = case[:6]
        ok, msg = S.run_case(root, base, name, rel, label, mode, min_refs, case[6] if len(case) > 6 else None)
        ok_all &= ok
        print(f"shift 01-05: {'PASS' if ok else 'FAIL'} [{mode}] {name}: {msg}")
    print(f"shift 01-05: {len(CASES)} cases, {'all passed' if ok_all else 'FAILURES'} (assembled without baserom.gbc)")
    return 0 if ok_all else 1


if __name__ == "__main__":
    sys.exit(main())
