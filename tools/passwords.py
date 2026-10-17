#!/usr/bin/env python3
"""Encode and decode BattleTanx GBC passwords from the recovered ROM format."""

from __future__ import annotations

import argparse
import functools
import pathlib
import re


ROOT = pathlib.Path(__file__).resolve().parent.parent
SOURCE = ROOT / "src/bank_01.asm"
DOCUMENT = ROOT / "docs/PASSWORDS.txt"

# Display order for the 32 values used by password entry. The game's numeric
# renderer also uses glyphs 0 and 1, but password characters start at glyph 2.
DISPLAY_GLYPHS = (
    "2", "3", "4", "5", "6", "7", "8", "9",
    "A", "B", "C", "D", "E", "F", "G", "H",
    "J", "K", "L", "M", "N", "P", "Q", "R",
    "S", "T", "V", "W", "X", "Y", "Z", "[TANK]",
)


@functools.cache
def password_bit_positions() -> tuple[int, ...]:
    """Read the permutation bytes from the authoritative assembly source."""
    source = SOURCE.read_text()
    match = re.search(
        r"^PasswordBitPositionTable:\n((?:\s+db [^\n]+\n)+)", source, re.MULTILINE
    )
    if not match:
        raise SystemExit("passwords: PasswordBitPositionTable not found")
    values = tuple(
        int(token[1:], 16)
        for token in re.findall(r"\$[0-9A-Fa-f]{2}", match.group(1))
    )
    if len(values) != 25 or sorted(values) != list(range(25)):
        raise SystemExit("passwords: invalid 25-bit permutation in bank_01.asm")
    return values


def checksum(level: int, lives: int, score_thousands: int) -> int:
    return (
        5
        + 3 * level.bit_count()
        + 2 * lives.bit_count()
        + score_thousands.bit_count()
    )


def encode_values(level: int, lives: int, score_thousands: int) -> tuple[int, ...]:
    if not 0 <= level <= 14:
        raise ValueError("level must be 0..14")
    if not 0 <= lives <= 15:
        raise ValueError("lives must be 0..15")
    if not 0 <= score_thousands <= 1023:
        raise ValueError("score-thousands must be 0..1023")

    fields = (
        (score_thousands, 10),
        (lives, 4),
        (level, 4),
        (checksum(level, lives, score_thousands), 7),
    )
    bits = [((value >> bit) & 1) for value, width in fields for bit in range(width)]
    packed = 0
    for bit, position in zip(bits, password_bit_positions()):
        packed |= bit << position
    return tuple((packed >> (5 * index)) & 0x1F for index in range(5))


def decode_values(values: tuple[int, ...]) -> tuple[int, int, int]:
    if len(values) != 5 or any(not 0 <= value <= 31 for value in values):
        raise ValueError("password must contain five values in the range 0..31")
    packed = sum(value << (5 * index) for index, value in enumerate(values))
    ordered = [((packed >> position) & 1) for position in password_bit_positions()]

    cursor = 0
    fields = []
    for width in (10, 4, 4, 7):
        fields.append(sum(ordered[cursor + bit] << bit for bit in range(width)))
        cursor += width
    score_thousands, lives, level, stored_checksum = fields
    if level > 14 or stored_checksum != checksum(level, lives, score_thousands):
        raise ValueError("password is rejected by the ROM's validation rules")
    return level, lives, score_thousands


def format_password(values: tuple[int, ...]) -> str:
    # DrawPasswordEntryChars computes glyph index 31-value, then
    # BuildGlyphTileAttrBuffer adds 2. This reverses the visible glyph list.
    value_glyphs = tuple(reversed(DISPLAY_GLYPHS))
    return " ".join(value_glyphs[value] for value in values)


def document_text() -> str:
    rows = []
    for level in range(15):
        values = encode_values(level, lives=3, score_thousands=0)
        assert decode_values(values) == (level, 3, 0)
        rows.append(f"Level {level + 1:2}:  {format_password(values)}")

    return """BattleTanx (USA) Game Boy Color passwords
================================================

These passwords are derived from the reconstructed ROM routines in
src/bank_01.asm, not from an external password list:

  PasswordBitPositionTable
  EncodePasswordFromProgress
  DecodePasswordBits
  ComputePasswordChecksum
  UnpackPasswordChars / PackPasswordChars

Canonical list
--------------

The game stores level, lives, and score in every password. Consequently there
is not one unique password per level. For a reproducible list, every entry
below uses 3 lives and a score of 0. The decoder restores exactly that state.

""" + "\n".join(rows) + """

`[TANK]` means the tank-shaped glyph at the end of the password alphabet.
The other 31 symbols are 2-9 and A-Z without I, O, or U, exactly as drawn by
the password glyph tables in the ROM.

Format recovered from the ROM
-----------------------------

The five glyphs carry 25 bits:

  10 bits  score divided by 1000 (0-1023)
   4 bits  lives (0-15)
   4 bits  zero-based level number (0-14 accepted)
   7 bits  checksum

The checksum is:

  5 + 3*popcount(level) + 2*popcount(lives) + popcount(score/1000)

PasswordBitPositionTable shuffles those 25 bits before they are divided into
five 5-bit glyph values. There are therefore many valid passwords for each
level. The game-generated post-level password uses the player's current lives
and score, and stores the next level number. The final level does not generate
another password.

Reproduction
------------

  python3 tools/passwords.py --check
  python3 tools/passwords.py --level 8 --lives 3 --score-thousands 0

`--level` is the human-facing level number 1-15. The tool reads the bit
permutation from the authoritative assembly source and round-trips every
generated entry through the recovered decoder rules.
"""


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="check docs/PASSWORDS.txt")
    parser.add_argument("--write", action="store_true", help="write docs/PASSWORDS.txt")
    parser.add_argument("--level", type=int, help="level number, 1..15")
    parser.add_argument("--lives", type=int, default=3)
    parser.add_argument("--score-thousands", type=int, default=0)
    args = parser.parse_args()

    if args.level is not None:
        values = encode_values(args.level - 1, args.lives, args.score_thousands)
        print(format_password(values))
        assert decode_values(values) == (args.level - 1, args.lives, args.score_thousands)
        return

    expected = document_text()
    if args.write:
        DOCUMENT.write_text(expected)
        print(f"passwords: wrote {DOCUMENT.relative_to(ROOT)}")
        return
    if args.check:
        if not DOCUMENT.exists() or DOCUMENT.read_text() != expected:
            raise SystemExit("passwords: docs/PASSWORDS.txt is stale; run with --write")
        seen = set()
        for level in range(15):
            for lives in range(16):
                for score_thousands in range(1024):
                    values = encode_values(level, lives, score_thousands)
                    if values in seen:
                        raise SystemExit("passwords: encoder collision")
                    seen.add(values)
                    if decode_values(values) != (level, lives, score_thousands):
                        raise SystemExit("passwords: encoder/decoder round-trip failed")
        print(
            "passwords: canonical list and 245760 accepted states "
            "round-trip without collisions"
        )
        return
    parser.error("choose --check, --write, or --level")


if __name__ == "__main__":
    main()
