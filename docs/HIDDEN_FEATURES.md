# Passwords, reset chord, and hidden-feature audit

This audit is derived from the reconstructed source and verified ROM bytes. It
does not use an external cheat list. The reproducible password list is in
[`PASSWORDS.txt`](PASSWORDS.txt).

## Passwords are saved-state codes

The password entry screen accepts five symbols. `PackPasswordChars` converts
them to 25 bits, and `DecodePasswordBits` restores the level, lives, and score
after checking the level bound and checksum. This is a general state encoder,
not a table of special cheat words. Different lives or scores produce different
valid passwords for the same level.

The source-derived generator and checker is `tools/passwords.py`.

## Confirmed special input

Holding **Start + Select + B + A** restarts the game. The comparison occurs in
the gameplay input path and in the installed VBlank handlers. This is a soft
reset/return-to-menu chord, not a stat-altering cheat.

## Level selection

The main menu has an ordinary, reachable level-selection flow:

- `MenuState00` choice 2 opens `MenuState05`;
- `MenuState05` selects one of three player vehicles;
- `MenuState06` selects a level and sets `GAME_START_LEVEL_SELECT`.

No secret input sequence is required, so this is a normal menu feature rather
than a developer menu.

## Easter eggs, cheats, and developer menus

No confirmed Easter egg, arbitrary cheat-code dispatcher, hidden developer
menu, or debug-menu activation path has been found in the ROM.

The audit checked the menu-state records and handlers, every explicit
Start/Select test, the password validator, indirect control-flow tables, the
known strings, and callerless/unreachable routines. The notable remnants are:

- `RunScoreIncrementLoopFar` and `ClearScoreThenIncrementForever` form an
  uncalled score-test loop. No menu record, function table, or input path calls
  the wrapper, so it is development residue rather than an accessible cheat.
- screen mode 9 is an unreachable duplicate of boot-sequence mode `$0A`;
- the bank `$2E` screen routine pair is callerless;
- `UnusedPasswordRejectionVariant` is an unreachable older copy containing an
  original duplicated-operand defect;
- the recorded-path subsystem and later screen-effect steps are unreachable.

These are preserved and documented because they are part of the original ROM,
but none currently has a proven player-accessible activation route. A future
new caller or indirect route would revise this conclusion.
