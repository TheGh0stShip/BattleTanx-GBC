# Screen runtime: banks $2A-$2E

Baseline `ae8696ef6adf28ad6984acbb64a9954d4cca854c`. Byte layout and templates:
BANKS_2A_2E_RESEARCH.md.

## Mode -> caller -> proven role

Dispatch: `ScreenTable_CallInit`/`CallUpdate` (ROM0) index `$01:ScreenModeTable`.
Mode sources: immediates, plus `menu_state` byte +1 through `wMenuState`.
`wMenuState` is written only at bank `$01`:1414 (MenuState00) and :1870 (a
choice's state pointer: MenuState00/03/04/05/06).

| Mode | Package | Caller | Proven role | Alias added |
| --- | --- | --- | --- | --- |
| 0 | `$2D:54FA` | `$01`:1427, MenuState00 | top menu state (4 choices) | — |
| 1 | `$2A:61D8` | MenuState04 | Options: OptionsMenuEntries text MUSIC/CONTROL/SKILL | `OptionsScreen_*` |
| 2 | `$2C:4000` | `$02:Func_02_5C40` | 2nd boot-sequence screen (*verified* order) | `BootSequenceScreen2_*` |
| 3 | `$2C:5ED3` | MenuState03 | code-entry result screen; alternate maps on rejection (below) | `CodeRejected*Map` |
| 4 | `$2B:6E6C` | MenuState05 | selector over `wMenuState05Selection` 0-2 | — |
| 5 | `$2C:4B3A` | `Func_02_5C40` | 3rd boot-sequence screen | `BootSequenceScreen3_*` |
| 6 | `$2C:5F9F` | `$01:Func_01_6CF0` after a level ends | post-level screen (purpose inferred, not proven) | — |
| 7 | `$2B:4000` | `Func_02_5C40` | 4th (last) boot-sequence screen | `BootSequenceScreen4_*` |
| 8 | `$2D:4000` | `Func_3B12` when `$C6CD` == 1, reached from the level-`$0E` branch | after the last level (purpose inferred) | — |
| 9 | `$2B:5BDA` | **none** | unreachable alias of mode `$0A` | — |
| `$0A` | `$2B:5BDA` | `Func_02_5C40` | 1st boot-sequence screen | `BootSequenceScreen1_*` |
| `$0B` | `$2C:55C4` | MenuState06 (`HandleMenuState06Input`) | code-entry grid (inferred from the exit path) | — |
| `$0C` | `$2A:6A22` | `$01` around `Func_01_6E44` | unresolved | — |

The boot sequence (`Func_02_5C40`, called from `Func_3B9F` on the startup path)
shows `$0A`, 2, 5 and 7 in order. Modes 2 and 5 wait up to `$B4` frames
and can be skipped.

## Other findings

- **`$2E` package routines (`$2E:4000/4058`)**: no `ScreenModeTable` entry, no
  `ld a,$2E` bank write, and `RAM_D7CB` only copies picture data. No caller
  was found. Indirect `push`/`jp hl` paths with a RAM-held bank were not
  exhaustively excluded.
- **`$C6B5`**: the joypad state written by `Func_0A59` from rP1 (held buttons;
  `$C6B6` holds new presses; *verified*). `Func_3971` clears it and waits.
  `FixedScreen2A_Run` animates until a button is pressed.
- **`$01:7981`**: reached from `Func_01_5126` when `Func_01_6C24` rejects the
  five entered bytes. That routine decodes a level index and range-checks it
  against `$0E`. `$01:7981` queues sound `$22` and draws
  `CodeRejectedTileMap`/`AttrMap` (bank `$2C`). Calling the input a "password"
  is an inference from the level decode.
- **`$01:$596D` pictures**: the `RAM_D7CB` index is `wMenuState05Selection`,
  which wraps within 0-2. Aliases: `MenuState05Picture0-2_Tiles`.
- **Descriptor fields**: unchanged from BANKS_2A_2E_RESEARCH.md. +8 (tile
  count) is never read; +12/+13 are read only by the plain draw routine.

## Relocation

- `ScreenModeTable` stores raw bank bytes. Each target routine is pinned
  with `ASSERT BANK(..)`; addresses are symbolic.
- `CodeRejected*Map` (raw in `$01:7981`) and the bank-`$2E` pictures (raw in
  `$01:$596D`) are pinned.
- The shift test moved the whole mode-7 package: 38 labels and 44 pointer
  words relocated.
