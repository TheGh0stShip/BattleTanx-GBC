# Data and assets: consolidated findings

Scope: level, graphics, palette, effect, audio, scene and opaque data. Line
numbers refer to the current source tree. Addresses use the form
`bank:address`. Every count and byte quoted here was re-read from the base ROM
or parsed from source. Each section has three parts: **Proven**, **Inferred**
and **Unknown**. A matching ROM does not mean these structures are understood.

## 1. Level records ($05:4300 pointers, 20-byte records)

**Proven**
- The layout is defined by `level_record` (`include/level_data.inc:19-25`).
  `LoadLevelRecord` ($00:188B, `bank_00.asm:4509`) copies bytes +2..+19 to
  $C8B9.
- **+6 is the attribute-map bank.** The macro emits `BANK(\7)` for the
  attribute map. In all 15 levels, +6 equals +5 (the values are $0A, $0C, ...
  $26). There is no `FA`, `EA` or `21` operand for $C8BD, $C8BE or $C8BF
  anywhere in the ROM. The copy loop is the only access to these bytes.
- **+7/+8 is a little-endian word written as `\8 - 1` (tile count minus 1).**
  Nothing reads it.
  - Values by level: 400, 366, 367, 356, 293, 401, 280, 414, 419, 322, 263,
    289, 246, 253, 391.
  - The comment at `level_data.inc:15` still says "map bank again" for +6. It
    should say "attribute-map bank, equal to +5, never read".

**Inferred**
- w11-2 says +7/+8 equals the highest block tile any map cell uses. That
  comparison was not re-run here.
- The unread fields fit the output of a converter whose format is more
  general than this loader (w11-5, weak).

**Unknown**
- Whether such a converter existed.

## 2. Attribute lookup and tile-animation tables

**Proven**
- Reader: `GetLevelCellTileAndAttr` ($00:1D93, `bank_00.asm:5309-5440`). The
  mapped path (`.mappedCell`, `:5367`) works as follows:
  - It computes `idx = (t+$7F)&$FF` from the map tile `t`.
  - It reads `b = Set[5*idx + 1 + frame]`.
  - It returns tile `b+$80` and attribute `AttrLookup[((b+$80)+$7F)&$FF]`,
    which is `AttrLookup[b-1]`.
  - When the map attribute has bit 3 set, the path returns early with the
    original tile and attribute.
- Byte +0 of each 5-byte record is never read.
- Set selection is `LevelTileAnimationPointers` (`bank_05.asm:396-401`):

| Set | Address | Records | Levels |
|---|---|---|---|
| 0 | $05:517A | 87 | 0-2 |
| 2 | $05:54CC | 95 | 3-5 |
| 1 | $05:532D | 83 | 6-8 |
| 4 | $05:5800 | 96 | 9-11 |
| 3 | $05:56A7 | 69 | 12-14 |

- **The zero byte before each `LevelNN_AttrLookup`** (for example
  `bank_09.asm:17`) is never read.
  - The lookup is addressed as `table - 1 + b`.
  - b = 0 would give offset $FF, not -1.
- **Bit-6 (animated) path** (`.animatedCell`, `:5356`):
  - It returns tile `$BB + ((counter+1)&7)`.
  - It returns the attribute `LevelAnimatedCellAttributes[level]`
    (`bank_00.asm:1667`).
  - Bits 7:6 = %11 also take this path, because only $40 and $80 are compared.
- **VRAM1 bypass** (re-derived):
  - level 0: 2 cells;
  - level 3: 10 cells.
- **Set2 overrun** (defect, documented, not fixed):
  - Levels 3 and 4 have convertible cells whose indices are 172-219.
  - Because $5800-$54CC = 5*164, those reads land on Set4 records 8, 10, 22,
    23, 31, 49, 50, 54 and 55.
  - Moving Set4 relative to Set2 would change the output.
- **Unread records** (re-derived over every ROM cell with bit 2 or bit 3 set
  and attribute bit 3 clear):

| Set | Never-selected records (zero-based) |
|---|---|
| 0 | 46, 57, 68, 70, 74 |
| 1 | 4-7, 17-20, 59, 78 |
| 2 | none |
| 3 | 29-34, 38, 52, 55, 57 |
| 4 | 25, 48, 51, 56 (49 and 50 are read only by level 4 through the overrun) |

- Every record byte that a reachable record holds is in $61-$9A. So in every
  level, AttrLookup entries 0-95 and 154-159 cannot be read.
- Set4 record 25 ($05:587D, `1A 00 00 00 00`) is the only record that holds
  $00. It is not reached.
- The per-level unread AttrLookup sets match w12 exactly. For example:
  - level 0: 0-95, 112-113, 142-159;
  - level 5: 0-113, 118, 141-159.

**Inferred**
- The per-level sets are upper bounds. They assume that every cell with bit 2
  or bit 3 set can actually be converted in play.
- No palette rotation takes place on these paths (w12-5).

**Unknown**
- Which code loads VRAM1 tiles $BB-$C2 for the bit-6 path.
- What the 96 dead leading lookup bytes were for.

## 3. Bank $08 unknown bytes, palette records, effect steps

**Proven: unknown bytes**

| Label | Bytes | Evidence |
|---|---|---|
| `Bank08Unknown6108` | `81 00` | no word $6108 or $6109 anywhere in the ROM |
| `Bank08Unknown624A` | `01 00 01 00 01 00` | no word $624A |
| (duplicate tile) $6250 | 16 bytes | equal to tile 47 at $08:655B; now emitted as `INCBIN ... 47*16, 16` (`bank_08.asm:464`) |
| `Bank08Unknown6260` | `80 00 01` | the word $6260 occurs only inside tile or map data, in banks $08, $25, $31, $34, $36, $37 and $3B |

- The neighbouring counted tile loads ($60F8 x1, $611A x16, $6222 x2,
  $626B x78) stop before these bytes (w08-2).

**Proven: palette-shaped records**
- There are 43 eight-byte records. Grouped by colours 1-3:

| Colours 1-3 | Count | Note |
|---|---|---|
| $001C, $025C, $03FF | 10 | same as the loaded $08:46EA |
| $7D04, $46A0, $7FFF | 17 | same as the loaded $08:5502 |
| $7D03, $46A0, $7FFF | 10 | no loader |
| $001F, $033F, $03FE | 2 | $610A = $621A |
| $001F x3 | 1 | $6112 |
| three others | 3 | $6263 = HUD icon palette $674B, $68D5 and $69F5 are unique |

- Code reads only colours 1-3 of $46EA and $5502. The other 41 records are
  entirely unread.
- `Bank08InterfacePalette68D5` is the only record not named
  `PaletteRecordXXXX`.

**Proven: effect steps** (`ScreenEffectSteps` $05:6358)
- The steps are counted as follows:
  - `StartScreenEffect` sets the countdown to `SCREEN_EFFECT_DURATION` = 75
    (`memory.inc:84`).
  - `UpdateScreenEffect` (`bank_00.asm:11846`) advances 6 bytes each time the
    countdown, after its decrement, is a nonzero multiple of 4.
  - That happens 18 times, so only steps 0-18 can be reached.
- Steps 19-71 are well formed but never shown. The comment in
  `screen_effect_tables.asm:5` agrees.

**Inferred**
- The 12 tile blocks (992 bytes) used only by steps 19-71 (w09-2) were not
  recounted here.
- No dynamic reader reaches any record (w09-6).
- The never-loaded graphics total 160 bytes: $4000 (16, skipped by the
  `INCBIN ..., 16` split at `bank_08.asm:12`), $6250 (16) and $6A7D (128,
  `bank_08.asm:561`).

**Unknown**
- What the 11 unknown bytes and the 41 unread records were for.
- Why steps 19-71 exist.

## 4. Audio data (banks $06 and $07)

**Proven**
- **Patches** (`audio_data.asm:8-47`):
  - There are 17 channel-1 patches, 19 channel-4 patches and patch $00
    (channel 2).
  - The reader takes the channel byte, then 4 registers (5 if channel bit 0
    is set), then NR51.
  - Bytes no reader takes:
    - +7 of each channel-1 patch: 17 bytes, all $00;
    - +6/+7 of each channel-4 patch: 38 bytes, all $00;
    - `SoundPatch00UnreadTail` `22 00`.
- **Patch $00:**
  - No sound sequence names patch $00.
  - `Audio_QueueSound` (`bank_00.asm:8861`) returns on `e = 0` with `ret z`
    after four pushes. AUDIO_RESEARCH.md:106 already documents this stack
    defect.
- **Music pointers** ($06:4744):
  - Each entry is 4 bytes. Byte +3 is $00 in all ten entries.
  - `Music_Update` (`bank_00.asm:8761`) does not read that byte.
- **Sound-sequence trailers:** 24 of them, 98 bytes in all. 23 are
  `FF 00 FF FF`, and the one after `SfxSequence_0E` is
  `FF 00 FF FF 00 00`. Each one follows `sfx_end`.
- **Music third byte:**
  - `Music_Update` always fetches three bytes and stores the third in
    `wMusicDelay` before it dispatches (`bank_00.asm:8782-8790`).
  - So the $00 at $06:7543 is read, as a dead store. The comment
    "not reached" at `audio_data.asm:5368` is wrong for that byte. The two
    `FF FF` bytes after it are unread.
- **Bank $07:**
  - $07:4008-$4BFB equals $06:4008-$4BFB byte for byte (3,060 bytes).
  - $07:4000-$4007 is `0C 00 65 00 44 62 65 00`, the malformed slot at
    `bank_07.asm:8-9`.
  - $07:4BFC-$7FFE is zero, and $7FFF holds $07.
  - The copy ends right after opcode $41 at $06:4BFB. That event's operands,
    `0C 08`, are not copied.

**Inferred**
- No code ever maps bank $07 (w16-11).
- Patches $02, $03, $1C, $1F and $20 have no reader. $0E and $0F are reached
  only through the password-entry sound id (w16-3).
- Instruments 3, 4, 6 and 7 never reach a register (w16-9).

**Unknown**
- What the padding, byte +3 and the trailers were for at build time.
- Why the bank-$07 copy is $BFC bytes long.

## 5. Scene palettes: over-reads and dual-use bytes

**Proven**
- `LoadFixedSceneResources` (`bank_01.asm:4592`) has two fixed behaviours:
  - It copies 8 bytes from palettes+$38 to $DC40, whatever the palette count
    (`ld bc,$0038 / add hl,bc / ld bc,$DC40 / ld e,$08`).
  - It starts the same two HDMA transfers for every scene.
- For F00, F01, F08 and F10, that window lies past the counted palettes and
  holds only zero bytes:
  - $33:60E8;
  - $31:7A18;
  - $31:6B98;
  - $31:5028, which is inside `FixedScene09Tiles`.
- The F04 descriptor has palette count `$09` (`bank_01.asm:3794`).
  `PrepareBackgroundPaletteFade` (`bank_00.asm:11096`) does two things:
  - It clears `BACKGROUND_PALETTE_CACHE_SIZE` bytes at $D000 in WRAM bank 2.
  - It copies the palettes to `wBackgroundPaletteFadeTarget`.

**Inferred**
- 72 bytes copied to $D7C0 write $D800-$D807, past the fade cache, and the
  fade uses only 64 bytes (w18-14). The fade-frame size constant was not
  re-checked.
- The 5,872 "dual-use" count from `tools/check_project.py` breaks down as
  given in w18-11 (tile windows over their own maps 2,640, over their own
  attributes 2,296, and so on). Two loaders read 5,864 of those bytes. The
  other 8 ($31:5020-$5027) are counted only because of the validator's
  64-byte palette minimum. This breakdown was not recomputed here.

**Unknown**
- Whether the zero palette entry is ever visible.
- What reads WRAM2 $D800-$D807 later.

## 6. Opaque assets

**Proven**
- The source has 224 `INCBIN` directives. Two are untyped `.bin` files with
  no structural model:

| Asset | Size | Use |
|---|---|---|
| `assets/bank_02/tracker_direction_lookup.bin` (`bank_02.asm:1884`) | 2,048 B | read through `TrackerDirectionLookup` (`:1489`). The nibble format is described only in `tools/rewrite_blobs_01_05.py:68` |
| `assets/bank_07/audio_build_residue.bin` (`bank_07.asm:16`, offset 1) | 3,061 B | build residue. ASSERT `@ == $4BFC` |

- `bank_02.asm:585` loads `ld bc, TrackerDirectionLookup + $12`. w20-5 says
  the constant is dead, but that was not re-traced here.
- The level cell, tile and attribute maps are named `.bin` assets whose
  semantics are described in sections 1-2. The bank-$08 graphics are sliced
  at labelled boundaries.
- `ObjectAnimationFrames4565` (`bank_02.asm:544`) now uses symbolic
  `dw SpriteTilesXXXX` entries, so the raw `db` pairs that w20-1 reported are
  gone in the current source.

**Inferred**
- The tracker table may be an octant (atan-like) grid. It has not been
  reproduced from a formula.

**Unknown**
- A generator formula for `tracker_direction_lookup.bin`.
- No validator checks the content of either opaque file (w20-6).

## Machine-checked since drafting

`tools/completion_invariants.py`, run by `make check`, now verifies three items
that the sections above list as inferred. Each check has a negative test.
- Rule 1: effect steps 19-71 are the only users of 36 part records, which
  reference 12 tile blocks (992 bytes).
- Rule 6: in all 15 level records, +6 equals +5, and +7/+8 equal the highest
  block tile used.
- Rule 5: the `LevelTileAnimationSet2` overrun lands on Set4 records 8, 10, 22,
  23, 31, 49, 50, 54 and 55.
