# Bank $01: control flow

Evidence: `src/bank_01.asm` and its callers in `src/bank_00.asm`, `src/bank_02.asm`.

## Gameplay support ($4000-$4BFF)

- **`RunPauseHudSequence`**: loops while `wGamePaused` (`$C6C1`) is set.
  ROM0 toggles that flag when the held buttons equal Start.
- **`LosePlayerLifeAndWaitForMusic`**: silences the sound-effect sequence,
  calls `LosePlayerLife`, then waits frame by frame until the music ends.
- **BCD helpers**:
  - `ByteToBcd16` adds powers of two from `$4F00` with `daa` for each set bit;
  - `AddWordToBcd24`;
  - `LongToBcd40`, used for the score.
- **`EntityHandlerTable`**: 10 handlers dispatched by object `+$1E` from the
  collision path (`DispatchEntityHandlerFar`). The handlers:
  - restore 1/4 or 1/2 of maximum health;
  - add 3000 points;
  - grant a life;
  - set powerup kinds 1-3;
  - start the HUD alert;
  - one does nothing;
  - `PickupHandler02` sets `+$27`, whose meaning is unproven.

  The index is proven 0-9.
- **`ScoreThresholdTable`** (`$418F`): twenty 32-bit thresholds (50,000 to
  1,000,000 in steps of 50,000), then `$FFFFFFFF`. ROM0 reads it by raw
  address, so it is pinned.
- **Palette helpers**:
  - `SubtractRgb555Saturating`;
  - `AddRgb555Saturating`;
  - `DarkenAllBgPaletteColors`;
  - `CaptureBgPalettesAndFadeToWhite`.

## Menus and options ($4C00-$57FF)

- **Menu records**: `menu_state` (id, screen mode, x, input handler) and
  `menu_choice`. The RAM loop dispatches input through `jp hl` to the five
  `HandleMenuStateNNInput` handlers.
- **Cursor and input**:
  - `UpdateMenuInputRepeat`: repeat starts after `$14` frames, then every 2;
  - `SetMenuGridRowWrapped` (0-4);
  - `SetMenuGridColumnClamped` (0-2).
- **Options**: `AdjustOptionValue` toggles type-2 values and wraps types 3/4.
  `ApplyOptionsSettings` and `LoadOptionsSettings` copy the settings.
- **Picture selector**: `MenuState05SelectPrevious`/`Next` (RAM code) wrap
  `wMenuState05Selection` within 0-2. `LoadMenuState05Graphics` (`RAM_D7CB`)
  loads the selected picture through `MenuState05PictureDescriptors`.
- **`SubmitEnteredCode`**: submits the five entered characters for decoding.

## Scenes ($5800-$67FF)

- **Setup**: `InitSceneDisplay`, `InstallSceneInterruptHandlers`,
  `InstallSceneRamCode` (16 RAM images at `$D000-$D3D8`).
- **Scrolling**: `RunScrollingScene`, `AdvanceSceneScroll`, `DrawNextSceneRow`.
- **Fades**: `FadeInSceneBackground`, `FadeOutSceneBackground`.
- **Scene selection**: `SelectLevelRowScene` and `SelectLevelScene`, using
  `LevelRowSceneIndexPairs`, `LevelSceneGridCells` and `LevelRowSceneFlags`.
  ROM0 reads `LevelRowSceneFlags` by raw address (`ld hl, $6609`), so it is
  pinned.
- **Descriptors**: `SceneBackgroundDescriptors` and `ScrollingSceneDescriptors`
  are now fully symbolic: `db BANK(label)` plus label pointers. The single
  `db` before each palette pointer is the last-row index.
- **Sprites**: `LoadMenuCursorSprites` copies `MenuCursorSpriteTiles` (8 tiles)
  to tiles `$78-$7F` and writes `MenuCursorSpriteTileIds`. It loads
  `MenuCursorObjectPalette`.

## Password ($6800-$7FFF)

- **Encode**: packs 25 bits into `wPasswordBits`, with bit order shuffled by
  the 25-byte table at `$66DD`:
  - 10 bits of score/1000;
  - 4 bits of lives;
  - 4 bits of next level;
  - 7 bits of checksum.
- **Checksum**: `5 + 3*popcount(level) + 2*popcount(lives) + popcount(score field)`.
- **Character conversion**: five 5-bit characters (`wPasswordChars`), converted
  both ways.
- **Decode (`Func_01_6C24`)**: rejects a level above `$0E` or a checksum
  mismatch and returns A = 0. The caller (`Func_01_5126`) then runs the
  rejection display (`$01:7981`, maps `CodeRejectedTileMap`/`AttrMap` in bank
  `$2C`). On success it loads the level, lives and score.
- **Screen data** (former blob `6E8A.bin`):
  - `PasswordScreenTiles`;
  - `PasswordGlyphTiles`/`Attributes` (34 x 4 each);
  - `PasswordBgPalettes`;
  - `PasswordObjPaletteColours`;
  - `ObjectPaletteCycleTable` (14 x 8);
  - column tables for characters, score and lives digits;
  - two 4-tile sprite blocks;
  - three unread gaps.
- **`FreeObjectsOutsideStatuses1And4`** (`$7D3A`): called only from
  `PreserveScreenEffectObjects`. It frees every object record except statuses
  1 (created by `CreateObjectAtOrigin`) and 4 (created by `Func_372E`).
  Status 2 also runs `Func_2C35` first. The code shows no further reason for
  the choice.

## Address-named routines that remain

`Func_01_4ECF`, `Func_01_66F6`, `Func_01_6746`, `Func_01_6751`,
`Func_01_6789`, `Func_01_696E`, `Func_01_6A1D`, `Func_01_6E44`,
`Func_01_6243` (no caller) and the `7BC5-7CEF` scroll helpers. Their data
sources are now named, but their exact role was not proven.
