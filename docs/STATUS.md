# Decompilation status

Last audited: 2026-10-16

## Prior-work search

No earlier public BattleTanx Game Boy Color source-reconstruction project was
found in searches by title, platform, cartridge code (`AVNE`), ROM SHA-1, ROM
MD5, or assembly terminology on 2026-10-16. Results were ROM catalogs, general
game information, and projects for the Nintendo 64 games. Private, removed, or
unindexed work may still exist; recheck before making a stronger provenance
claim.

## Reconstruction

- Retail image: BattleTanx (USA), SHA-1
  `5078584e86c0b6f4687c424cc00bbd762ba6573a`
- Toolchain: RGBDS 1.0.4
- Whole-ROM match: 1,048,576 / 1,048,576 bytes (100%)
- ROM banks represented: 64 / 64
- Copied RAM images detected: 38 (31 executable, 7 data-only)
- Banks `$3C-$3F` are confirmed unused cartridge capacity: all 65,536 bytes
  are explicit `$FF` padding rather than opaque assets.
- Bank `$07` is explicit as a seven-byte unknown prefix, an unread `$0BF5`-byte
  copy of bank `$06`, zero fill, and its marker; its former whole-bank asset is
  removed.

This is complete binary reconstruction. It is not complete semantic recovery.

## Source recovery

| Area | Current state | Next gate |
| --- | --- | --- |
| Reviewed code | 38,772 bytes traced from known entries, pointers, executable RAM images, and reviewed standalone entries | Name and document routines from behavior |
| Heuristic decoding | 0 additional bytes accepted by gap fill | Keep this at zero as more data boundaries are recovered |
| Symbols | Interrupts, startup, copy helpers, screen and menu-state dispatch, OAM DMA, MBC5/VBlank state, both active scene descriptors, and their copy/load routines are named | Continue naming routines and RAM state from evidence |
| RAM images | All 31 executable images are explicit instructions, while 7 data-only images remain bytes; every image retains its ROM source and runtime address with a `LOAD` block | Name remaining images and verify every copy site |
| Graphics | 62 confirmed 2bpp sheets extract to PNG and round-trip byte-exactly: eleven interface sheets, three fully classified orientation sets, twelve fixed-background packages, and 36 scrolling-scene sheets | Resolve the remaining mixed ranges in bank `$08` and identify individual layouts |
| Maps | All eleven referenced fixed backgrounds, the unreferenced Game Boy Color warning in bank `$3B`, all 36 scrolling scenes, and all 15 two-bank levels have lossless inspection renderers and explicit map/row/palette source with checked dimensions, indices, attributes, flips, and palettes | Name individual scenes and levels and find whether the warning package ever had a caller |
| Level data | Every byte of banks `$09-$26` is classified across 15 levels: cell maps, tiles, lookup tables, palettes, tile maps, attribute maps, fill, and markers | Determine the unknown cell-map bits and unused record fields |
| Audio | Driver code and all of its data (bank `$06:$4000-$7CAD`) are explicit source in `src/audio_data.asm`; see the Audio section below | Name remaining unknown fields; physical-hardware check |
| Banks `$2A-$2E` | All 81,920 bytes classified: 17 full-screen pictures (typed 2bpp INCBINs, explicit maps and palettes) and 30 load/draw routines expressed through three byte-checked templates; see `BANKS_2A_2E_RESEARCH.md` | Trace the caller-less bank-`$2E` routines, `$C6B5`, and picture meanings |
| Text | The ROM0 encoded-text interpreter, cursor state, three option records, and all eleven directly referenced option strings are named and checked; see `TEXT_RESEARCH.md` | Reconcile the bank `$08` glyph map/artwork and rule out indirect or constructed strings |

## Known control-flow gaps

Six indirect `jp hl` sites are present in the directly traced graph:

- Bank `$00`: `$364D`, `$39C3`, `$39F0`
- Bank `$01`: `$450E`, `$4B44`

The screen init/update dispatch sites at `$39C3` and `$39F0` use the 13-entry
banked screen table at bank `$01:$47EC`; its known destinations are seeded into
the tracer. Bank `$03:$6886` has been resolved as a 15-entry state-check table
at `$685A`, and bank `$01:$450E` uses the 10-entry entity-handler table at
`$44E0`. The callback at `$364D` is selected from the three-entry table at
bank `$01:$4E2F`. The site at `$4B44` reads one of five callbacks from the
menu/flow-state headers at `$4855`, `$48AB`, `$48F1`, `$4927`, and `$495D`.
Those headers and their fourteen 16-byte choice records are now explicit
source, and all five callback destinations are seeded into the tracer. One
callback is copied from bank `$01:$51CC` and executes from WRAM at `$D70A`.
Every known indirect site is therefore structurally modeled, although each
remains an indirect transfer at runtime.

## Menu state

The main menu loop keeps separate two-byte pointers for the requested state
and the last state rendered. It rebuilds the screen only when those pointers
differ, then dispatches the input callback stored in the requested state's
header. The associated WRAM fields now have checked symbols for the active
flag, previous button state, repeat timer, horizontal scroll direction, the
three-value state-`$05` selection, and the state-`$06` 3-by-5 grid selection.
The cursor-sprite enable flag is also named from its use in the installed STAT
interrupt routine. Fields whose behavior is not yet established remain raw.

## Immediate roadmap

1. Introduce evidence-based WRAM/HRAM symbols and hardware-state documentation.
2. Split mixed code/data banks into named tables and resources.
3. Add lossless graphics, map, and text extraction/rebuild paths.
4. Run relocation/shift tests before declaring source freely editable.
5. Validate timing-sensitive and RAM-executed behavior on physical hardware.

## Level banks `$09-$26`

The 30 banks are structured as 15 two-bank levels through the record table at
bank `$05:$4300`. Each odd bank contains a cell map, native 2bpp tiles, an
attribute lookup table, BG palettes, fill, and its bank marker. Its paired even
bank contains equally sized tile and attribute maps, followed by fill and its
marker. All 491,520 bytes are covered exactly once.

The source now uses typed assets for the four large ranges in each level,
explicit lookup tables and palettes, and assembly assertions for every derived
boundary. Bank `$05` also expresses all 15 record pointers, 20-byte records,
and lookup references symbolically. The record, tile, palette, cell-map,
row-offset, and cell-lookup routines now have behavioral names.
`tools/level_data.py` validates all 15 record layouts, legal palette
and tile indexes, zero-filled intervals, markers, and total coverage. Eleven
deliberate corruptions must be rejected. `make levels` emits CSV, JSON, palette,
tile, and map inspection outputs and verifies their round trips.

The same bank contains five tile-animation tables selected by a 15-entry
per-level pointer table. Their 430 five-byte records are explicit source: a
one-based record index followed by four frame tile IDs. The cell lookup chooses
a frame with a two-bit counter. Table addresses, record counts, sequential IDs,
and the level-to-table mapping are checked. Eighteen active-level WRAM fields
now have checked names for banks, pointers, dimensions, lookup state, and row
offsets.

The level renderer now names its cell resolver/writer, 21-cell row and
19-cell column loops, four scrolling-edge updates, BG-map address calculation,
and 20-by-18 viewport refresh. Its world-space viewport origin and wrapped
32-by-32 BG-map origin fields are also named and checked.

The camera update follows the active object within horizontal and vertical
screen margins. Four directional scroll routines maintain 16-bit level-space
pixel coordinates, the hardware scroll bytes, the viewport cell origin, and
the wrapped BG-map origin; crossing a cell boundary redraws only the newly
exposed row or column. Their entry points and camera fields are named and
address-checked.

Level initialization also names the banked cell-position setter and its ROM0
wrapper. Checked cache fields retain the level's pixel dimensions, the current
view-row offset into the cell map, and the wrapped BG-map row offset.
Horizontal and vertical boundary classifiers now document their signed input
registers and directional return codes against those pixel dimensions. The
cell-map accessors for bits 0 through 3 and the eight-point bit-0 footprint
test are named; their callers establish use by movement logic, but the gameplay
meaning of each flag remains unknown. Four directional scanners find the
bounding rectangle of a contiguous run whose bits 2-3 are nonzero. ROM cell
maps never set bits 4 through 7. Run-time writers are now proven: bit-2 cells
enter bit-6 or bit-7 rendering states depending on bit 3, while two completion
routines clear bits 1-3 and select the bit-7 lookup path before redrawing.
The inclusive region bounds and iteration scratch in HRAM are named; the
bit-2 region pass also accumulates and awards five points per changed cell.
Named entry points cover pixel-to-region lookup, visible-area bit-2 cleanup,
the fixed 20-point bit-3 conversion, random transition selection, and its
bounded retry/fallback behavior.

The adjacent object update path now names frame-displacement calculation, a
checked 12-pixel two-axis proximity predicate, independent axis rejection
against level bounds and cell bit 0, and the flag-bit-3 object region trigger.
The larger state-dependent bit-1/2 response remains unnamed.
The same update chain names the 64-record proximity scan that selects the
first active type-4 entity within 12 pixels on both axes, plus the banked
entity-handler dispatcher it invokes.
The remaining map response is now structurally named: object state 0 starts a
region transition on cell bit 1; state 1 rolls back an axis for bit 1 alone or
starts a transition when bit 2 is also set; state 2 ignores these bits. A
separate 64-record scan rejects movement within 20 pixels of a type-1 entity.

Bank `$05:$4EA0` contains four 16-bit score awards selected by an object's
type; the two callers and the four-byte score-accumulation routine now have
behavioral names. Four eight-byte object-type parameter records at `$5100`
have three consumed bytes and five reserved zeros apiece. Both tables are
explicit source with checked values and addresses.

The gameplay meanings of cell-map bits 0 through 3, record fields +6 and
+7/+8, and the role of one unread byte preceding each lookup table remain
unknown. No ROM cell sets bits 4 through 7, so the bit-6/7 lookup-table paths
are entered only after the run-time transformations described above.

## Confirmed graphics boundaries

Bank `$08` contains eleven independently checked native 2bpp interface sheets:
74 UI-font tiles at `$4000`; groups of 1, 16, 2, and 78 tiles at `$60F8`,
`$611A`, `$6222`, and `$626B`; groups of 10, 12, and 4 tiles at `$6753`,
`$6815`, and `$68DD`; two four-tile arrow sets at `$6925` and `$696D`; and 66
alphanumeric-font tiles at `$69B5`. Every range is backed by a loader call
whose tile count fixes its exact length. They
now use narrowly named binary assets that are extracted from the verified ROM
and round-trip through the graphics checker. Each sheet's four-color 15-bit
palette is explicit source at `$44A0`, `$674B`, `$691D`, `$6965`, or `$69AD`;
startup copies those five records into named WRAM buffers. Their boundaries,
colors, copy destinations, and symbols are checked. The interval between the
first two interface-tile groups is now split into a ten-byte palette-index
table used by `SelectObjectSpritePalette` at bank `$08:$6DD5` and four
consecutive six-byte object-palette records; their loader supplies the
transparent first color. The routine maps an object's type field to sprite
palette indices 4 through 7 before bank `$01:$4687` writes the OAM attribute.
A further six-byte object palette is present at `$46EA`. Another complete
four-color palette separates the second and third tile groups. The unresolved
portions are now limited to `$44A8-$46E9`, `$46F0-$60F7`, `$6108-$6119`,
`$621A-$6221`, and `$6242-$626A` (7,309 bytes total); they are not counted as
understood graphics.

ROM0 now names the object-palette loader, both interface-tile loaders by VRAM
bank, and the interface-palette loader. Their explicit sources include the UI
font, complete alphanumeric font, numeric subset, arrows, and HUD sheets.

Banks `$27`, `$28`, and `$29` each start with nine orientation frames of nine
native 2bpp tiles. Bank `$05:$4020` contains the 16-entry orientation lookup:
the first nine entries select the nine consecutive `$90`-byte frames and the
last seven select them in reverse, reusing the mirrored layouts at `$4064`.
The loader copies exactly nine 16-byte tiles from the selected frame. These
three `$510`-byte ranges now round-trip as confirmed graphics. Each is followed
by an unidentified two-byte value at `$4510` and an explicit three-color object
palette at `$4512`; the palette loader supplies the transparent color and loads
these records into object palette slots 0, 1, and 2.

The orientation graphics end at `$450F`. The word at `$4510` resembles an
RGB555 color but is unread and remains unnamed. Each palette occupies six bytes
at `$4512-$4517`. Bytes `$4518-$4BFB` are an unread, byte-identical copy of the
same offsets in bank `$26` (part of level 14's tile map), not sprite data.
Zero fill begins at `$4BFC` and continues to the bank marker at `$7FFF`.
Every byte in banks `$27-$29` is now classified, with the unknown meaning of
the `$4510` word and the run-time bound of one bank selector retained as open
questions. `make objects` emits frame, assembled-orientation, layout, and
palette inspection files and verifies their round trips.

## Scene-background descriptors

Bank `$01:$59AB` contains eleven 16-byte scene descriptors. Each selects one
of banks `$30`-`$33`, a `$0FF0`-byte source used to load 255 tiles, separate
20x12 tile and attribute maps, and a table of eight-byte four-color palette
records. The loader copies the recorded number of palettes into its fade
target buffer. Six trailing bytes in every descriptor are reserved zeros. The
five-entry table at `$5A5B` maps a later group of scenes to descriptor indices
6 through 10. Individual scene identities remain unknown.

Bank `$01:$5A60` contains 36 eight-byte scrolling-scene descriptors. Their
callers establish the data bank, pointer to 16-byte native tile graphics,
pointer to 40-byte scrolling rows (twenty little-endian tile indices), last
valid row index, and eight-byte palette source. Every index has been checked
against its scene's tile count, and each palette begins exactly after the final
row. Three
19-byte lookup tables select descriptors and initial rows; validation ensures
that every selection and row lies within its referenced table. The precise
meaning of each scene still needs to be documented.

`make maps` expands those indexed rows into 36 lossless scene previews and
emits the original indices as CSV plus the four 15-bit palette values. Across
the table, 709 rows and 14,180 indices are checked; every index resolves inside
its descriptor's graphics table. These generated files are inspection aids,
not substitutes for the source descriptors.

The same target also renders the eleven fixed backgrounds. Their 240-byte
tilemaps and attribute maps form 20x12 scenes; the tilemap high bit and final
attribute bank bit select between the two VRAM tile banks, while attribute
flip bits are applied to the preview. All 2,640 resolved source-tile indices
fit inside the corresponding 255-tile graphics range. The original attributes
and resolved indices are emitted separately as CSV.

All 11 fixed-background tile sources and all 36 scrolling-scene graphics
ranges now have lossless PNG extraction. The fixed loader establishes a size
of `$0FF0` bytes (255 tiles). Each scrolling range ends at its descriptor's
row-data pointer, and every resulting range is an exact multiple of the
16-byte native 2bpp tile size. Layout-only padding lets non-rectangular tile
counts use readable 16-tile-wide previews without changing the round trip.

Banks `$2F` and `$34-$3B` contain thirty-two of the scrolling scenes. Their 16-bit row
indices and four-color palettes are now explicit assembly, their graphics are
narrowly typed tracked 2bpp assets, and their zero-filled tails and one-byte
bank markers are explicit source. Bank `$3B:$4000-$508F` is an additional,
unreferenced Game Boy Color compatibility warning in the fixed-background
format: 231 physical 2bpp tiles, a 20x12 tile map, a zeroed 20x12 attribute map,
and eight palette records. Its map resolves entirely within those 231 tiles,
and its
render is coherent, but no descriptor or code reference has been found. The
source therefore records the format without assigning it a gameplay role.
The four remaining scrolling scenes and all eleven fixed scenes share banks
`$30-$33`. Their maps, attributes, rows, and palette blocks are explicit source;
graphics-only intervals are narrowly typed assets. Some fixed-scene tile loads
deliberately include map, attribute, palette, or later-scene bytes. The source
therefore emits every physical byte once while retaining labels for all
overlapping semantic ranges. The checker rebuilds that interval partition,
validates every label and asset, and records the number of dual-use bytes. The
64-byte palette blocks are supported by the loader's unconditional eight-byte
read at palette pointer +`$38`, even for descriptors with fewer active palettes.


## Banks `$2A-$2E`

Details: `BANKS_2A_2E_RESEARCH.md`.

- Reconstruction: every byte is represented as code (2,803), structured data
  (13,694), typed 2bpp tiles (51,792), or padding (13,631); no opaque ranges
  remain. The matching ROM hash is unchanged.
- Understood: screen descriptor format, picture layouts, the 13-entry
  screen-mode dispatch and its index bounds, the three routine templates, the
  palette-fade direction flag, and the fixed animated screen in bank `$2A`.
- Not understood: what sets `$C6B5`, why the bank-`$2E` package routines have
  no caller, the unread descriptor fields, the bank `$01:$596D` index bound,
  and what each picture is used for.

## Audio

Details and evidence: `AUDIO_RESEARCH.md`.

Reconstruction completeness (bytes represented as explicit, structured
source rather than opaque INCBIN):

- Bank `$06:$4000-$7CAD` (15,534 bytes): 37 sound patches, 25 sound-effect
  sequence pointers + 24 distinct sequences, register init, 90 note
  frequencies, waveform, noise-note table, channel register bases, 10 music
  pointers, 11 instruments, 10 music sequences. `assets/bank_06/4000.bin` is
  no longer used.
- Driver code: ROM0 `$2EB8-$2F92`, bank `$06:$7CAE-$7FD1` (already traced).
- Byte match is unchanged: SHA-1 `5078584e86c0b6f4687c424cc00bbd762ba6573a`.

Semantic understanding:

- Understood (format, boundaries and every reference checked): queue,
  sound-id ranges, patch / sfx-sequence / music event formats, all bank-`$06`
  table boundaries, bank switching, callers and frame timing.
- Named in source: 8 routines (`Audio_InitFar`, `Music_Update`,
  `Audio_Update`, `Audio_QueueSound`, `Audio_Init`, `Music_HandleEvent`,
  `Audio_PlaySound`, `SfxSequence_Update`), 9 data tables, 14 WRAM symbols
  in `include/memory.inc`.
- Kept numeric and unknown: `$C8E3`, `$C8E4`, `$C8F6`; unread bytes
  `06:415A-415B`, `4660-4661`, `4740-4743`, `476C-476D`, patch `$00`
  bytes 6-7, music-pointer byte 3, the bytes after each sequence
  terminator; raw sfx op bytes; musical meaning of notes and tracks.
- Not audio: bank `$05` (sprite layouts and level parameters).
- Bank `$07`: `$4007-$4BFB` duplicates bank `$06`; no traced path maps it.
  Not proven unused, because some computed bank indexes are unbounded.
- Not checked on hardware.

`tools/check_project.py` re-derives every table boundary, record format and
range listed above from `baserom.gbc`, rejects any return of a bank-`$06`
INCBIN, checks every immediate sound id in `src/`, and checks the audio
symbol addresses in `battletanx.sym`.
