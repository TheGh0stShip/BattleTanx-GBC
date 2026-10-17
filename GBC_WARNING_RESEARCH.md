# Game Boy Color hardware warning

## Result

ROM0 `RequireCgbHardware` at `$0651` checks the boot value saved at `$C000`.
It returns only when that byte is `$11`. Otherwise it selects bank `$3B`,
loads a monochrome warning screen, enables the LCD, restores the previous
bank, and deliberately loops forever.

This resolves the former claim that bank `$3B:$4000-$508F` was an unreferenced
fixed-background package. Its actual loader-defined layout is:

| Range | Bytes | Content |
| --- | ---: | --- |
| `$4000-$4DCF` | 3,536 | 221 native 2bpp tiles copied to VRAM `$8800` |
| `$4DD0-$4DDF` | 16 | unread zero alignment gap |
| `$4DE0-$4F33` | 340 | 20-by-17 DMG tile map written to `$9800` |
| `$4F34-$5087` | 340 | unread zero fill |
| `$5088-$508F` | 8 | unread palette-shaped record |

The loader writes `LCDC = $C1` and `BGP = $1B`; it does not load a CGB
attribute map or CGB palettes. With signed `$8800` tile addressing, every map
entry resolves inside the 221 loaded tiles. The lossless renderer shows the
BattleTanx logo followed by the message that the game can only be played on a
Game Boy Color.

## Evidence and checks

- ROM0 `$0651-$0657` contains the `$11` hardware guard.
- ROM0 `$066C-$0685` fixes bank `$3B`, source `$4000`, 221 tiles, map `$4DE0`,
  17 rows and 20 columns.
- `tools/check_project.py` verifies those operands, every range above, the map
  indexes, the tracked tile asset, and all relevant symbol addresses.
- `tools/extract_scene_maps.py` renders the complete 20-by-17 map and verifies
  its expanded native 2bpp data through `rgbgfx` round-trip.
- The rebuilt ROM remains byte-identical.

## Unresolved

The purpose of the unread palette-shaped record at `$5088` is unknown. It is
not used by the warning path and is kept separate from the preceding fill.
