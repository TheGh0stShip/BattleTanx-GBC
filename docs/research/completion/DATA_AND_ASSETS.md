# Data and assets: consolidated findings

Scope: level, object-sequence, graphics, palette, effect, audio, scene and
opaque data. Addresses use the form `bank:address`. Labels are the primary
(first) names in the current source; legacy aliases are named only where a
tool still uses them. Each section separates **Proven**, **Inferred** and
**Unknown**. A matching ROM does not mean these structures are understood.
Sources for each claim are kept in `sources.json`, not here.

## 1. Level records ($05:4300 pointers, 20-byte records)

**Proven**
- `level_record` (`include/level_data.inc`) defines the layout.
  `LoadLevelRecord` ($00:188B) copies bytes +2..+19 to $C8B9.
- +6 is the attribute-map bank. It equals +5 in all 15 levels, is copied to
  `wLevelAttributeMapBank`, and is never read.
- +7/+8 is a little-endian word emitted as `\8 - 1` (tile count minus 1),
  copied to `wLevelLastTileIndex` and never read. It equals the highest
  block tile used (`completion_invariants.py` rule 6).

**Inferred / Unknown**
- The unread fields suggest a more general converter format (weak). Whether
  one existed is unknown.

## 2. Level cells, attribute lookup and tile-animation sets

**Proven: read path**
- Reader: `GetLevelCellTileAndAttr` ($00:1D93). In `.mappedCell`,
  `idx = (t+$7F)&$FF`, `b = Set[5*idx + 1 + frame]`; it returns tile `b+$80`
  and attribute `LevelNN_AttrLookup[b-1]`. If map attribute bit 3 is set,
  the map pair is returned unchanged.
- Record byte +0 and the zero byte before each `LevelNN_AttrLookup` are
  never read.
- Sets are selected through `LevelTileAnimationPointers`:

| Set | Address | Records | Levels |
|---|---|---|---|
| `LevelTileAnimationSet0` | $05:517A | 87 | 0-2 |
| `LevelTileAnimationSet2` | $05:54CC | 95 | 3-5 |
| `LevelTileAnimationSet1` | $05:532D | 83 | 6-8 |
| `LevelTileAnimationSet4` | $05:5800 | 96 | 9-11 |
| `LevelTileAnimationSet3` | $05:56A7 | 69 | 12-14 |

- Of 430 records, all except Set4 record 25 ($05:587D, all zero) hold bytes
  in $61-$9A, so lookup entries 0-95 have no read path in any level.
- **Rule E** (`completion_invariants.py` rule 12): for every map cell with
  bit 3 clear and `(t+$7F)&$FF < $A0`, the lookup entry equals the map
  attribute with flip bits ($60) cleared. The largest index read is 153; no
  lookup entry has bit 3 set. The only mismatch is unread entry 159, which
  differs only in flip bits. The older "levels 1 and 13 mismatch" claim is
  withdrawn.

**Proven: animated cells and the VRAM1 loader**
- `.animatedCell` (bit 6, also bits 7:6 = %11) returns tile
  `$BB + ((counter+1)&7)` and attribute `LevelAnimatedCellAttributes[level]`;
  all 15 attributes select VRAM1.
- The last call in `LoadInterfaceTilesVRAM1` ($00:0807; bytes at $00:086C
  `1E 3B 16 08 3E 88 01 FD 69 CD 22 06`) copies 8 tiles from
  `Bank08InterfaceTiles69FD` to VRAM1 $8BB0-$8C2F. `LoadLevelTiles` fills
  only ids $80-$B7 and the UI font starts at $8C30, so nothing overlaps
  (rule 11). Item closed.

**Proven: Set2 overrun (original defect, documented, not fixed)**
- Because $5800-$54CC = 5*164, cells with indices 172-219 read Set4 records
  8, 10, 22, 23, 31, 49, 50, 54, 55.
- Level 3 has 9 such cells: the three $0A columns (indices
  172/174/186/187/195). Level 4 has **6**: (51,8), (56,8), (52..55,10).
  Rule 5 pins both.

**Proven: region shapes and cell $0A**
- `FindLevelCellRunLeftEdge` and related routines scan only the start row
  and column with `and $0C`, giving 911 rectangles. Five contain cells with
  bits 2/3 clear: L3 (102,13)-(104,14); L8 (41,1)-(42,14), (42,1)-(43,14),
  (63,6)-(64,15), (64,6)-(65,15). No rectangle mixes bit-2-only and
  bit-3-only cells.
- `ConvertLevelCellBit2Region`/`ConvertLevelCellBit3Region` test
  `and $04`/`and $08` and skip the holes, so three regions (level 3: 4
  cells; level 8: 28 and 20 cells) convert differently by start cell
  (rule 9).
- Cell $0A: 6 cells, all level 3, at (x,37-38) above a $09 at (x,39) for
  x = 60, 77, 105. A projectile transition fails on `and $04` and
  `StartLevelCellRegionTransitions` gives up after 6 retries; a bit-3 object
  centred on the $09 converts the 1x3 column to $81 (rule 10). No gameplay
  name is claimed.
- Maps contain only $00/01/02/03/06/08/09/0A/0F. Bits 4-5 are preserved by
  the `and $B1`/`and $F1` writers and otherwise unused.

**Proven: never-selected animation records (zero-based)**

| Set | Records |
|---|---|
| 0 | 46, 57, 68, 70, 74 |
| 1 | 4-7, 17-20, 59, 78 |
| 2 | none |
| 3 | 29-34, 38, 52, 55, 57 |
| 4 | 25, 48, 51, 56 (49, 50 only via the level-4 overrun) |

**Inferred**
- These lists are exact relative to code reachability: removing the 66
  bit-3-only cells with no passable anchor (10 in level 6, 56 in level 8)
  changes nothing. Assumes map navigability and that all four frame bytes
  are drawn.

**Unknown**
- Whether the level-6 edge cells and level-8 $08 channels can convert (only
  possible route: the stale-coordinate test in
  `ResolveObjectLevelBit0Movement`).
- Why five rectangles include empty cells; what the 96 dead lookup bytes were.

## 3. Level spawn and object-sequence data

**Proven**
- 103 records have charge 0 (54 type 5, 22 type 0, 19 type 1, 8 type 2; 16
  respawn). `UsePlayerWeaponOrPowerup` decrements +$2A after firing and
  clears +$29 only on 0, so a count of 0 allows **256** uses.
- Spawn byte 7 is read only on the type-3 and type-6 paths; type-5 records
  never respawn (nonzero type-5 values: L7r9=1, L11r1=5, L12r36=5, L14r1=7).
- Sequence byte +6 is read only by the SetTimer branch (action 3 or >= 6).
  All 626 `seq_point` end actions are 0, 2 or 5, so the 135 nonzero +6
  values and "distance 9" are never read. The +1/+2 word and count byte have
  no reader. `OBJECT_SEQUENCE_ACTION_TIMER_OFFSET` (+$3C) is never written
  by shipped data.
- 199 records name 199 distinct slots; (3,11), (9,1), (9,2), (10,17) are
  never selected.
- Two persistent over-reads among 203 sequences: (3,6) loads (0,$3A) from
  $03:461D and walks into (3,7)/(3,8); (6,15) loads ($4D,$56) from $03:4CA7
  inside the Level07 slot table. Action-2 final past-the-end loads are
  overwritten in the same call.

**Inferred**: +$3D-$3F have no direct or stepped access (strong).

**Unknown**: why 103 records carry 0 charges; what +6 meant; whether the
(3,6) and (6,15) objects reach their final point.

## 4. Bank $08: HUD palettes, unknown bytes, palette records, effect steps

**Proven: HUD power-up palettes and alert icon**
- `DrawPlayerPowerupIcon` indexes `HudPowerupFirstTiles` ($00,$4E,$52,$56)
  and `HudPowerupPalettes` with the same index. `LoadInterfaceTilesVRAM0`
  places `Bank08InterfaceTiles68DD` at tile $4E, `Bank08ArrowUpTiles` at
  $52 and `Bank08ArrowDownTiles` at $56. Each palette therefore colours the
  tile block *before* it in ROM; the primary names are now
  `Bank08PowerupIcon1Palette`-`3Palette` (WRAM copies
  `wPowerupIcon1Palette`-`3Palette`). Old `Bank08ArrowUp/ArrowDown/
  AlphanumericFontPalette` names remain as legacy aliases.
- `Bank08HudAlertIconTiles` (= `Bank08InterfaceTiles69B5`; legacy alias
  `Bank08AlphanumericFontTiles`) is 4 tiles loaded to $5A and drawn as
  $5A-$5D with attribute $87 while `wHudAlertActive` is set, blinking on
  bit 4 of `wVBlankCounter`. Nothing reads it as a font.
- `CopyTilesToVRAM` computes (A<<8)+E*16 with A=$80, so the four blocks go
  to VRAM0 tiles $4E-$51, $52-$55, $56-$59, $5A-$5D. The old "$CE-$DD"
  comments were wrong and are corrected.
- `Bank08ArrowUpTiles`/`Bank08ArrowDownTiles` keep names based only on
  appearance (weak). `tools/gen_bank08_asm.py` still emits the old names.

**Proven: palette-shaped records**
- 42 `PaletteRecordXXXX` labels. Two hosts are partly read (colours 1-3
  only): `PaletteRecord46E8` via `Bank08ObjectPalette46EA`, and
  `PaletteRecord5500` via `EffectPalette5502`. The other **40** are unread.

| Group | Colours 0-3 | Records | Relation |
|---|---|---|---|
| A | 0000 001C 025C 03FF | 46E8 + 9 | copy of `Bank08ObjectPalette46EA` |
| B | 0000 7D04 46A0 7FFF | 5500 + 16 | copy of `EffectPalette5502` |
| C | 0000 7D03 46A0 7FFF | 10 | B with colour 1 low byte $03 |
| D | 0000 001F 033F 03FE | 610A, 621A | identical pair |
| - | 0000 10A3 3200 42E0 | 6263 | copy of `Bank08HudIconPalette` ($674B) |
| - | 0000 001F 465F 7FFF | 68D5 | unique in ROM |
| - | 0000 10A3 5818 7E9F | 69F5 | colours 2-3 = $08:6811-$6814 (OBJ pal 7, `Bank08ObjectPalettes67FD`) |

- `PaletteRecord68D5` keeps legacy alias `Bank08InterfacePalette68D5`.
  `semantic_invariants.py` rule 3 and `completion_invariants.py` rule 2
  check the groups.

**Proven: unknown bytes (strong for "no reader")**
- `Bank08Unknown6108` `81 00`; `Bank08Unknown624A` `01 00 01 00 01 00`;
  `Bank08Unknown6260` `80 00 01`.
- The constant interface loads end at $6108, $621A and $6242; the $626B
  load starts after $6262. Every other immediate bank-$08 reader is bounded
  (metatile queue <= $44DF, `SelectObjectSpritePalette` <= $68F2, glyph
  tables above $6B00, effect parts <= $60F0, animation frames <= $5488). A
  whole-ROM pointer scan over $60F8-$6263 gives 5 false hits, and no
  computed bank selector yields $08. Rule 3 checks the tile copies.
- The 16 bytes at $6250 duplicate tile 47 (`Bank08DuplicateInterfaceTile6250`).

**Proven: effect steps** (`ScreenEffectSteps`, $05:6358)
- `StartScreenEffect` sets the countdown to 75; `UpdateScreenEffect`
  advances 6 bytes when the decremented countdown is a nonzero multiple of
  4. Only steps 0-18 are reachable; steps 19-71 alone use 36 part records
  and 12 tile blocks, 992 bytes (rule 1).

**Inferred**: never-loaded bank-$08 graphics total 160 bytes ($4000, $6250,
$6A7D). Group D may be a variant of A.

**Unknown**: what the 11 unknown bytes mean (a tile-header reading fails
for $6108); why groups C/D and steps 19-71 exist.

## 5. Audio data (banks $06, $07)

**Proven: structures**
- 37 patches (`audio_data.asm`). The reader takes the channel byte, 4
  registers (5 if channel bit 0 is set), then NR51. Unread: +7 of each
  channel-1 patch, +6/+7 of each channel-4 patch, and +6/+7 (`22 00`) of
  patch $00, now emitted by `sound_patch_ch2 $86, $F0, $00, $03, $22, $22,
  $00`. The $22 at +6 has no known purpose.
- Music pointers ($06:4744): ten 4-byte entries; byte +3 ($00) is unread.
  `Music_Update` always stores the third byte in `wMusicDelay`, so the $00
  at $06:7543 is a dead store, not unread.
- **Trailers:** 33 `<Parent>_UnreadTrailer` labels mark bytes after an end
  marker (comment `never read: after end marker`):
  - 24 `SfxSequence_XX_UnreadTrailer`, 98 bytes; 23 are `FF 00 FF FF`,
    `SfxSequence_14_UnreadTrailer` is 6 bytes.
  - 8 `Music_XX_UnreadTrailer` holding `FE FF` after `music_loop $FF, 0`
    (16 bytes).
  - `Music_07_UnreadTrailer`: the final `FF FF` after `music_stop` (an
    earlier note placed it under Music_02).
  - `rom_range_map.py` exempts these from the neutral class (`TRAILER`
    regex): they count as named, unreferenced data. Their build-time purpose
    is unknown.
- All eight `$FE` music events are `music_loop $FF`, so the queue path in
  `Music_HandleEvent` never runs.
- **Bank $07:** $07:4008-$4BFB equals $06:4008-$4BFB (3,060 bytes), headed
  by `Bank07MalformedSoundPatch00`; zero to $7FFE; $7FFF = $07. The cut is
  one byte into the event at $06:4BFB. No code selects bank 7.

**Proven: password-entry ids**
- `StorePasswordCharWithSound` queues $0A, then the caller's `e`, the
  pressed-edge mask from `UpdateMenuInputRepeat`. `HandleMenuState03Input`
  tests bits 7..0, so the Down site sees $08-$0F and the Up site $04-$07.
- $0D, $0E, $0F need Up+Down together and are queued nowhere else.
  `ReadJoypad` does not filter opposite directions. $0C is also direct-
  queued only this way, but sfx $45 still sounds it.
- **Latent defect:** `Audio_QueueSound` runs `ret z` after four pushes when
  `e` = 0. No site passes 0.

**Proven: reachability of ids** (structural call graph from Boot, Init and
the five vectors; every witness edge checked against source)
- **57** `Audio_QueueSound` sites (50 immediate, 7 dynamic; an earlier 58
  was a miscount), all in reached code.

| Kind | Never queued |
|---|---|
| Patch (direct) | $00 $02 $03 $1C $1F $20; $0C-$0F without Up+Down |
| Sfx | $40-$43 $47 $48 $4C-$4E $50 ($4B aliases `SfxSequence_00`) |
| Music | $89 |

- Patches $01 and $16 occur only in `SfxSequence_0C` ($4C) and
  `SfxSequence_01` ($41), never queued, and there is no sfx chain command.
  Never-sounded patches: $00 $01 $02 $03 $16 $1C $1F $20 ($0D-$0F need
  Up+Down).

| Music | Starts from |
|---|---|
| $88 | Init; `ReturnToMenuAfterLevel` |
| $83 | `RunNoLivesFlow` |
| $87 | `BeginPlayerDestroyedCountdown` |
| $82 | boot screen sequence; `RunLevelCompletionScreenFlow` |
| $81-$86 | random: `RespawnPlayer`, `RunLevelIntroSceneFlow`, `QueueRandomGridSounds` |
| $80 | `RunBurstEffectUntilButton`, on any nonzero `wJoypadHeld` (directions included) |

- Dead-code lists must be built per address: 22 of the tool's 180
  "unreached labels" are primary names whose callers use a same-address
  alias.

**Inferred**
- Reachability is structural: branches assumed takeable, tables followed in
  full; pickup ids ($49 $4A $4B $51 $53-$56) also depend on unaudited spawn
  data. Instruments 3, 4, 6, 7 never reach a register (not re-checked).
  $BFC = $C00-4 hints at a zeroed 3 KiB tail (weak).

**Unknown**: whether opposing input was intended or physically possible;
what the padding, byte +3, trailers and bank-$07 copy were for.

## 6. Scene palettes

**Proven**
- `LoadFixedSceneResources` ($01:D000, RAM) copies 8 bytes from
  palettes+$38 to $DC40 regardless of count. For F00, F01, F08, F10 that
  window is past the counted palettes and zero (rule 4). It feeds BG
  palette 7 at the window split via $FF98, but none of the 240 window
  attribute bytes uses palette 7, so it is never visible.
- F04 (count 9, before level 9 only): `PrepareBackgroundPaletteFade` puts
  palette 8 at WRAM2 $D800-$D807; nothing reads it and `LoadLevelCellMap`
  overwrites it.
- `CaptureBgPalettesAndFadeToWhite` writes $D7FF, the last byte of
  `wBackgroundPaletteFadeTarget` frame 31.
- `Bank3BGbcWarningUnusedPalette` ($3B:5088) has no pointer; its pattern is
  unique.

**Inferred**: $3B:5088 is a ramp matching the warning screen's BGP=$1B
(weak). The 5,872 dual-use byte figure was not recomputed.

**Unknown**: the purpose of $3B:5088.

## 7. Object record fields (data side)

**Proven**
- 71 raw field immediates and 38 later sites use `OBJECT_*` constants; the
  ROM still matches.
- `OBJECT_VEHICLE_HIDE_TIMER_OFFSET` (+$27) and
  `OBJECT_VEHICLE_HIDE_REVEAL_TIMER_OFFSET` (+$28), set by pickup handler 2,
  suppress drawing and the proximity check while +$27 != 0 and +$28 = 0.
- Projectile +$23: bounce sets it, `ResolveProjectileHit` doubles damage,
  and the owner-exclusion test is skipped, so a bounced shot can hit its
  shooter (original defect, commented).

**Inferred**: a level vehicle could collect kind 3 via
`DispatchNearbyStatus4Pickup`/`PickupScreenEffectCharge` and then write into
$0000-$0FFF when firing (structural only).

**Unknown**: `AimObjectAtPlayerFromProximity` loads `D` from `E` and reads
an unrelated address; possibly an original defect, not run.

## 8. Range map, neutral bytes and assets

**Proven: range-map categories** (`tools/rom_range_map.py --write`, 2,411
ranges, no gaps or overlaps, 28 negative tests)

| Bucket | Bytes |
|---|---|
| asset referenced / unreferenced | 621,328 / 9,808 |
| code traced / untraced | 36,245 / 584 |
| data referenced / unreferenced | 180,101 / 41,617 |
| data layout (separators) | 4 |
| data neutral | 12 |
| RAM code referenced / unreferenced | 2,528 / 2 |
| RAM data referenced | 40 |
| fill / marker padding | 156,244 / 63 |

- ASSERT lines no longer count as readers. Computed reads are allowlisted
  with an anchor the reader must name (`UiFontTiles` via
  `Bank08UiFontTiles + $10`; `Bank27/28/29OrientationTiles` via
  `ObjectOrientationTilePointers`). `Bank27/28/29ObjectPaletteRecord` are
  now unreferenced.
- RAM image entries are credited when vectored by a numeric `jp`/`call`
  and copied by an installer, or when the ROM image is called directly
  (`WriteBgPalette7FromD3F8`, a documented defect). The 2 unreferenced
  bytes are `UnusedMenuRamNoOp` and `UnusedSceneRamNoOp`.
- **Separators:** four 1-byte ranges after RAM images (01:5660, 01:5F09,
  01:659A = $00; 02:41C3 = $D9) are checked for size, value and position
  and reported as layout, not unused.
- Indexed members check stride, origin, count and that the reader's code
  derives them.
- Known limit: fall-through still credits a label without requiring its
  predecessor to be reached.

**Proven: the 12 neutral bytes** (4 ranges)

| Range | Bytes | Status |
|---|---|---|
| $02:5E80 `Bank02Unknown5E80` | `08` | unknown; `BurstBlockTileGrids` ends exactly here |
| $08:6108 / $624A / $6260 | 11 | unknown (section 4) |

No address operand points at any of them. The record at $02:5E81 is a valid
black/black/black/white RGB555 record with no reader.

**Proven: asset placement**
- `assets/` holds 158 files; `assets.txt` lists 156, each matching its ROM
  range. Every file is used.
- 224 textual `INCBIN` lines in `src/` plus 30 expansions of the
  `include/object_banks.inc` macros (`orientation_frames`, bank-$26
  residue) give **254 placed slices**. `asset_slices.txt` records each
  (path, file start, length, ROM offset); `check_asset_slices` in
  `tools/check_project.py` compares every slice with the ROM, rejects
  overlaps, requires every textual INCBIN to be recorded, and requires
  every file to be in `assets.txt` or fully covered by slices.
- **Slice-only assets:** `assets/bank_08/object_animation_tiles.bin` (4,000
  B, 42 slices, $08:44A8-$5487) and `assets/bank_08/effect_tiles.bin`
  (2,960 B, 27 slices, $08:5490-$60EF). Palette and step records sit
  between slices, so the three-field `assets.txt` format cannot describe
  them; `tools/bank08.py` also compares them.
- `make extract-assets` cannot regenerate these two files
  (`extract_bank08.py` writes only to `build/bank08`), so a clean
  re-extraction would lose them. `extract_assets.py` also fails on inline
  `#` comments.
- Slices outside their file's `assets.txt` range (`interface_tiles_626B.bin`
  +$2F0 at $08:6250; `level_14/tilemap.bin`+$518 at $27/$28/$29:4518) were
  covered only indirectly before `check_asset_slices`.
- `audio_build_residue.bin` byte 0 ($07:4007) is emitted as the last `db`
  of `Bank07MalformedSoundPatch00`, not from the file; the file is still
  fully checked.
- **IndexedSpriteGrid:** `IndexedSpriteGridDescriptors` stores raw bytes
  `$D0,$4A` / `$30,$48`, not symbols, for `IndexedSpriteGrid0Tiles`/
  `IndexedSpriteGrid1Tiles`. `banks_01_05.py` pins their addresses, so a
  shift is detected but not tracked.
- `graphics.txt` is an inspection manifest; its ranges deliberately differ
  from the assets.
- `assets/bank_02/tracker_direction_lookup.bin` (2,048 B,
  `TrackerDirectionLookup`) is regenerated from a formula
  (`semantic_invariants.py` rule 1): `TrackerDrawPointerSprites` uses row =
  |dy|>>5, col = |dx|>>5, two nibbles per byte (even columns high), nibble
  `round(15*atan2(col,row)/(pi/2))`; diagonals give 7, (0,0) gives 0. No
  clamp for |dx| or |dy| >= $800. `ld bc, TrackerDirectionLookup + $12` is
  a dead load.
- `assets/bank_07/audio_build_residue.bin` (3,061 B) is build residue,
  ASSERT `@ == $4BFC` (section 5).

**Unknown**: whether |dx| or |dy| can reach $800; nothing validates
`audio_build_residue.bin` beyond equality with bank $06 and its end.

## Machine-checked

| Tool | Rule | Fact |
|---|---|---|
| `completion_invariants.py` | 1 | effect steps 0-18 reachable; 36 records, 12 blocks used only by 19-71 |
| | 2, 3 | bank-$08 duplicate records; tile copies avoid the unknown bytes |
| | 4 | zero +$38 palette windows |
| | 5 | Set2 overrun (level 3: 9, level 4: 6) |
| | 6 | level record +6 = +5; +7/+8 = highest block tile |
| | 9-12 | start-cell regions, $0A columns, VRAM1 $BB-$C2 loader, rule E |
| `semantic_invariants.py` | 1 | tracker table formula |
| | 2 | every queued sound id in range |
| | 3 | bank-$08 palette groups and comments |
| `check_project.py` | audio | exactly one `sound_patch_ch2`; 37 patches, 25 sfx, 10 music |
| | `check_asset_slices` | 254 slices match ROM; full asset coverage |
| `rom_range_map.py` | separators, incbins, computed reads, indexed members, trailers | section 8 |
