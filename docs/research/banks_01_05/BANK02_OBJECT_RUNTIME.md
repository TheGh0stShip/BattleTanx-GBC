# Bank $02: object runtime

## Interrupt images

| Installer | STAT image ($C729) | VBlank image ($C7F1) |
| --- | --- | --- |
| `InstallPaletteStatInterruptHandlers` | `PaletteStatHandler`: switches the HUD palette and sets LCDC bit 4 | `PaletteVBlankHandler` |
| `InstallVBlankOnlyInterruptHandlers` | `StatHandlerReti` | `VBlankHandlerWithSoftReset`: soft reset when the joypad high nibble is all set |

## Nearest-target tracker

- `ResetNearestObjectTracker` picks a scan routine from the 15-entry table at `$40DD`
  (indexed by `wLevelNumber`). It writes `jp <routine>` / `ret` into
  `wNearestTargetScanJump` (`$C8DB`, 4 bytes).
- `$02:4D58` runs every frame and enters the stub. The targets:
  - `TrackerScanStatus1Objects`: 64 object records, status 1 and
    `OBJECT_NONPLAYER_CONTROLLED_FLAG_OFFSET` set;
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
pointers, read by ROM0 `LoadObjectAnimationTiles` through object field `+$21`, indexed by
age (`+$1F`) >> 2. Each table's length equals lifetime (`+$20`) / 4. The OAM
layouts at `$4200/$4204/$4214` are 4-byte entries (dy, dx, tile, attribute).

Effect object initialisers, named from `SpawnTimedObjectEffect`'s subtype dispatch:
`InitEffectSubtype0Animation`, `InitEffectSubtype1Animation`,
`InitEffectSubtype2Animation`.

## Boot sequence

`RunBootScreenSequence` (`$5C40`, called from `RunBootScreenSequenceFar` on start-up) shows
screen modes `$0A`, `$02`, `$05`, `$07` in order.

## Burst effect ($626D-$66DB)

Reached only through ROM0 `RunScreenMode8ActivityFar`.

- **Setup** (`InitBurstEffectScreen`): selects WRAM bank 2, clears the shadow
  OAM at `$D000` and `wBurstObjects` (40 x 8 at `$D0A0`), and loads
  `BurstObjPalettes` and `BurstTiles`.
- **Run**: at least 255 frames, then until a button is pressed.
- **Expiry**: when an object expires, child objects are spawned using
  `BurstChildCountTable` and `BurstChildOffsets`.
- **Randomness**: `Bank02NextTableRandom` reads the 256-byte
  `BurstRandomTable`.
- **Dead code**: `SpawnBurstSpriteBlock` and `AnimateBurstSpriteBlock` have no callers.
- **Naming**: "burst" names the effect by its code behaviour (gravity,
  children spawned on expiry). It is a structural label, not a gameplay
  identity.

## Indexed sprite grids and unread bytes

- `IndexedSpriteGridDescriptors` has two four-byte entries containing a tile
  source and screen X/Y position. `LoadIndexedSpriteGrid` selects one with
  `E`, transfers 40 tiles to VRAM bank 1, and builds a 10-by-4 OAM grid.
- `IndexedSpriteGrid1Tiles` (`$4830-$4AAF`) and
  `IndexedSpriteGrid0Tiles` (`$4AD0-$4D4F`) are the two 40-tile sources.
- The 32 bytes between the grids are two unused 2bpp tiles. Before the first
  grid, `Bank01ScreenMode06PointerResidue` is an unread same-address copy of
  bank `$01:$481E`, the `EarnedCodeScreen_LoadTiles` pointer, followed by 16 zero
  bytes that align the grid to `$4830`.
- `Bank02ObjPalette7` (`$4D50`) is a complete four-colour record. The loader
  supplies colour 0 itself and reads colours 1-3 from `Bank02ObjPalette7Colours`
  at `$4D52`. Its only
  caller `LoadIndexedSpriteGridFar` is itself never called.
- `Bank02UnreferencedByte5E80` is one unread byte whose purpose is unknown.
- `Bank02UnusedPaletteRecord5E81` is an unread eight-byte record containing
  four valid RGB555 words (`$0000`, `$0000`, `$0000`, `$7FFF`). Its format and
  boundary are established, but no runtime palette use was found.
