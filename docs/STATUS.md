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

This is complete binary reconstruction. It is not complete semantic recovery.

## Source recovery

| Area | Current state | Next gate |
| --- | --- | --- |
| Reviewed code | 38,772 bytes traced from known entries, pointers, executable RAM images, and reviewed standalone entries | Name and document routines from behavior |
| Heuristic decoding | 0 additional bytes accepted by gap fill | Keep this at zero as more data boundaries are recovered |
| Symbols | Interrupts, startup, copy helpers, screen and menu-state dispatch, OAM DMA, MBC5/VBlank state, both active scene descriptors, and their copy/load routines are named | Continue naming routines and RAM state from evidence |
| RAM images | 31 executable and 7 data-only images retain ROM source and runtime addresses with `LOAD` blocks | Name each image and verify every copy site |
| Graphics | 55 confirmed 2bpp sheets extract to PNG and round-trip byte-exactly: five UI sheets, three sprite sheets, eleven fixed backgrounds, and 36 scrolling-scene sheets | Identify palettes, final layouts, and remaining graphics ranges |
| Maps | Eleven fixed backgrounds and 36 scrolling scenes render from 2,640 fixed cells plus 709 scrolling rows/14,180 cells, with validated indices, attributes, flips, and palettes | Name the individual scenes and connect them to game progression |
| Audio | Driver code and all of its data (bank `$06:$4000-$7CAD`) are explicit source in `src/audio_data.asm`; see the Audio section below | Name remaining unknown fields; physical-hardware check |
| Text | Options-menu labels and value strings are represented directly in source | Extract and round-trip remaining strings and encodings |

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

## Immediate roadmap

1. Introduce evidence-based WRAM/HRAM symbols and hardware-state documentation.
2. Split mixed code/data banks into named tables and resources.
3. Add lossless graphics, map, and text extraction/rebuild paths.
4. Run relocation/shift tests before declaring source freely editable.
5. Validate timing-sensitive and RAM-executed behavior on physical hardware.

## Confirmed graphics boundaries

Banks `$27`, `$28`, and `$29` each begin with exactly `$0C00` bytes (192
tiles) of native Game Boy 2bpp graphics. Code selects these banks and copies
16-byte tile records from them; each graphics range is followed by `$33FF`
zero bytes and its one-byte bank marker at `$7FFF`. The three sheets are kept
separate because their gameplay role and palette relationship have not yet
been established.

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
