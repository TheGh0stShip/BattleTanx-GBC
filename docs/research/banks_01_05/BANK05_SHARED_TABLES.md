# Bank $05: shared tables

| Range | Structure | Reader | Notes |
| --- | --- | --- | --- |
| `$4000-$401F` | `ObjectOrientationLayoutPointers` (16) | ROM0 `WriteObjectOrientationOam` | 9 normal, 7 x-flipped |
| `$4020-$403F` | `ObjectOrientationTilePointers` (16) | ROM0 `CopyObjectOrientationTiles` | now `Bank27OrientationFrameN` labels; banks `$27-$29` share the layout |
| `$4040-$4087` | normal and x-flipped OAM layouts | `WriteObjectOrientationOam` | |
| `$4088` | `LoadLevelLookupPointers` | ROM0 `LoadLevelLookupPointersFar` | only code in the bank |
| `$40B1-$42FF`, `$431E-$43FF`, `$452C-$45FF` | unused fragments of bank `$04` level-object spawn records at the same addresses | none | explicit residue macros; byte equality checked |
| `$4300` | `LevelRecordPointers` and 15 level records | `LoadLevelData` | |
| `$4600-$4DFF` | `ObjectVelocityTable`: 16 speed classes x 16 directions x (X, Y) signed 32-bit, 1/256 px | ROM0 `LoadVehicleForwardVelocity`/`LoadVehicleReverseVelocity` (raw `ld bc, $4600`, pinned) | magnitude = (class + 1) x `$60`; class 15 is never selected (classes come from `ProjectileSubtypeParameters`, at most 14) |
| `$4E00-$4E9F` | zero | none | |
| `$4EA0` | `ObjectScoreValues` | | |
| `$5100` | `ProjectileSubtypeParameters` | | |
| `$5120` | `LevelTileAnimationPointers` | | |
| `$513E` | `LevelAttributeLookupPointers` | | |
| `$517A-$59DF` | level tile-animation sets | | |
| `$59E0-$6357` | 24 groups of three `ScreenEffectPartXXXX` records + their `ScreenEffectTemplateXXXX` | ROM0 `LoadScreenEffectPart`/`BuildScreenEffectPartOam` | 72 parts, 72 templates; seven unused OAM-template entries at `$62CD` and `$62F5` |
| `$6358-$6507` | `ScreenEffectSteps`: 72 steps x 3 part pointers (0 = none) | ROM0 `StartScreenEffect`/`UpdateScreenEffect` | raw `$58`/`$63` immediates in ROM0, pinned |
| `$6508-$7FFE` | zero fill | | |
| `$7FFF` | bank marker | `ROM_BANK_MARKER` | |

## Screen-effect timing

- **Countdown**: `$C959` starts at `$4B`.
- **Advance**: the step pointer moves on at each non-zero multiple of 4,
  which is 18 advances.
- **Rendering**: stops below 3.
- **Result**: only steps 0-18 are shown. Steps 19-71 are well-formed, and 36
  parts with their templates are used only by them.
- **Gameplay identity**: not assigned. It would rest on appearance.
