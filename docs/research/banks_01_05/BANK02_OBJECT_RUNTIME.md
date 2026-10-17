# Bank $02: object runtime

## Interrupt images

| Installer | STAT image ($C729) | VBlank image ($C7F1) |
| --- | --- | --- |
| `InstallPaletteStatInterruptHandlers` | `PaletteStatHandler`: switches the HUD palette and sets LCDC bit 4 | `PaletteVBlankHandler` |
| `InstallVBlankOnlyInterruptHandlers` | `StatHandlerReti` | `VBlankHandlerWithSoftReset`: soft reset when the joypad high nibble is all set |

## Nearest-target tracker

- `Func_02_406F` picks a scan routine from the 15-entry table at `$40DD`
  (indexed by `wLevelNumber`). It writes `jp <routine>` / `ret` into
  `wNearestTargetScanJump` (`$C8DB`, 4 bytes).
- `$02:4D58` runs every frame and enters the stub. The targets:
  - `TrackerScanStatus1Objects`: 64 object records, status 1 and `+$26` set;
  - `TrackerScanType2Objects`: the same, plus object type `+$1E` = 2;
  - `TrackerScanAuxRecords`: 8 auxiliary records at `$CD6F`;
  - `TrackerSelectAuxRecord`: a fixed target, `$CD79` or `$CD6F`.
- The best match is stored in `wNearestTargetPtr` and its distance in
  `wNearestTargetDistance`.
- `TrackerDrawPointerSprites` uses `TrackerDirectionLookup` (dx/dy to
  direction; two 4-bit values per byte) to select one of the 64
  4-OAM-entry `TrackerPointerFrames`.
- The `ld bc, Bank02Data_5102/520A/5312/541A/5452` loads near it are dead:
  each value is overwritten before use.

## Object animation frames

`ObjectAnimationFrames4565` ... `45BB` are 9 tables of bank-`$08` tile
pointers, read by ROM0 `Func_3190` through object field `+$21`, indexed by
age (`+$1F`) >> 2. Each table's length equals lifetime (`+$20`) / 4. The OAM
layouts at `$4200/$4204/$4214` are 4-byte entries (dy, dx, tile, attribute).

Effect object initialisers, named from `Func_3090`'s subtype dispatch:
`InitEffectSubtype0Animation`, `InitEffectSubtype1Animation`,
`InitEffectSubtype2Animation`.

## Boot sequence

`RunBootScreenSequence` (`$5C40`, called from `Func_3B9F` on start-up) shows
screen modes `$0A`, `$02`, `$05`, `$07` in order.

## Burst effect ($626D-$66DB)

Reached only through ROM0 `Func_3F1F`.

- **Setup** (`InitBurstEffectScreen`): selects WRAM bank 2, clears the shadow
  OAM at `$D000` and `wBurstObjects` (40 x 8 at `$D0A0`), and loads
  `BurstObjPalettes` and `BurstTiles`.
- **Run**: at least 255 frames, then until a button is pressed.
- **Expiry**: when an object expires, child objects are spawned using
  `BurstChildCountTable` and `BurstChildOffsets`.
- **Randomness**: `Bank02NextTableRandom` reads the 256-byte
  `BurstRandomTable`.
- **Dead code**: `Func_02_635F` and `Func_02_63F4` have no callers.
- **Naming**: "burst" names the effect by its code behaviour (gravity,
  children spawned on expiry). It is a structural label, not a gameplay
  identity.

## Indexed sprite grids and unread bytes

- `IndexedSpriteGridDescriptors` has two four-byte entries containing a tile
  source and screen X/Y position. `LoadIndexedSpriteGrid` selects one with
  `E`, transfers 40 tiles to VRAM bank 1, and builds a 10-by-4 OAM grid.
- `IndexedSpriteGrid1Tiles` (`$4830-$4AAF`) and
  `IndexedSpriteGrid0Tiles` (`$4AD0-$4D4F`) are the two 40-tile sources.
- Only 52 bytes in the former `$481E-$4D51` block remain unread:
  `Bank02Unread481E` (18), `Bank02Unread4AB0` (32), and
  `Bank02Unread4D50` (2).
- `Bank02ObjPalette7Colours` (`$4D52`): read by `LoadIndexedSpriteGrid`, whose only
  caller `Func_3CC2` is itself never called.
- `Bank02Unread5E80` (9 bytes).
