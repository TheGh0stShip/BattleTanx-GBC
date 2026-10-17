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

At this revision, 168 of 381 surviving automatic function-entry labels have a
reviewed companion name; 213 remain. `make progress` recomputes the per-bank
breakdown from the linked symbol file. This measures naming progress only: it
does not substitute for traced-byte coverage or semantic verification.

| Area | Current state | Next gate |
| --- | --- | --- |
| Reviewed code | 38,772 bytes traced from known entries, pointers, executable RAM images, and reviewed standalone entries | Name and document routines from behavior |
| Heuristic decoding | 0 additional bytes accepted by gap fill | Keep this at zero as more data boundaries are recovered |
| Symbols | `make progress` reports reviewed companion names for automatic function entries per bank, separately from traced-byte coverage; interrupts, startup, copy helpers, screen dispatch, OAM DMA, rendering state, and scene descriptors are among the recovered groups | Continue naming routines and RAM state from evidence |
| RAM images | All 31 executable images are explicit instructions, while 7 data-only images remain bytes; every image retains its ROM source and runtime address with a `LOAD` block | Name remaining images and verify every copy site |
| Graphics | 64 confirmed 2bpp sheets extract to PNG and round-trip byte-exactly; bank `$08` additionally has a lossless 83-range inspection export for its interleaved interface/object graphics | Identify gameplay roles for the remaining neutral graphics labels |
| Maps | All eleven descriptor-driven fixed backgrounds, the referenced Game Boy Color warning in bank `$3B`, all 36 scrolling scenes, and all 15 two-bank levels have lossless inspection renderers and explicit map/row/palette source with checked dimensions and indices | Name individual scenes and levels |
| Level data | Every byte of banks `$09-$26` is classified across 15 levels: cell maps, tiles, lookup tables, palettes, tile maps, attribute maps, fill, and markers | Determine the unknown cell-map bits and unused record fields |
| Object sequences | Bank `$03:$4000-$5C10` is explicit source: two signed-vector tables, fifteen 64-slot per-level pointer tables, 203 counted sequences, and 626 eight-byte records; the vector-direction quantizer and all 15 level-state checks are named | Determine the remaining record-field meanings and name individual sequences |
| Level objects | Bank `$04:$4000-$601B` is explicit source: 600 fixed-size object initialization records, 120 auxiliary records, and the per-level pointer directory; the 20-entry deferred-spawn queue, active-table pointers, slow-tick counter, and camera-window spawn path are named | Determine the remaining field meanings and the role of enabled auxiliary records |
| Audio | Driver code and all of its data (bank `$06:$4000-$7CAD`) are explicit source in `src/audio_data.asm`; see the Audio section below | Name remaining unknown fields; physical-hardware check |
| Banks `$2A-$2E` | All 81,920 bytes classified: 17 full-screen pictures (typed 2bpp INCBINs, explicit maps and palettes) and 30 load/draw routines expressed through three byte-checked templates; see [`research/BANKS_2A_2E_RESEARCH.md`](research/BANKS_2A_2E_RESEARCH.md) | Trace the caller-less bank-`$2E` routines and picture meanings |
| Text | The ROM0 encoded-text interpreter, cursor state, three option records, and all eleven directly referenced option strings are named and checked; see [`research/TEXT_RESEARCH.md`](research/TEXT_RESEARCH.md) | Glyph map reconciled ([`research/BANK08_RESEARCH.md`](research/BANK08_RESEARCH.md)); rule out indirect or constructed strings |

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

1. Continue replacing automatic routine and RAM labels with evidence-backed names.
2. Split the remaining mixed ranges in code banks `$01`, `$02`, and `$05`.
3. Identify neutral level, scene, screen, object, and audio names from behavior.
4. Run relocation/shift tests before declaring source freely editable.
5. Validate timing-sensitive and RAM-executed behavior on physical hardware.

## ROM0 hardware helpers

The shared display primitives now have behavioral names while retaining their
original `Func_XXXX` aliases for compatibility with work in other banks.
`DisableLCDSafely` waits for VBlank line 145 before clearing LCDC bit 7;
`EnableLCD` sets that bit again. `CopyTilesToVRAM` copies `D` complete
16-byte tiles from `BC`, using `A` as the destination page and `E` as the first
tile number while avoiding VRAM mode 3. `ClearGameMemory` preserves
`$C000-$C0FE` and `$CF00-$CFFF` but clears fixed WRAM `$C0FF-$CEFF`, OAM,
HRAM, and every switchable WRAM bank. `ResetDisplayState` uses the safe
LCD-off helper before resetting scroll/window registers, DMG palettes, and the
tile-data selection
bit. `ClearCgbPalettes` resets both 64-byte CGB palette memories, while the
background and object palette writers expose their verified start-index and
count contracts. These names describe proven mechanics, not higher-level
gameplay roles.

The same ROM0 pass identifies the three-byte random-state seed and update,
the multiply-based `RandomBelowB` sampler, the 20-byte tilemap-row copier,
and the paired tile/attribute writer. Hardware initialization and OAM reset
retain compatibility aliases at their original addresses so banked callers do
not need coordinated edits.

The ten-byte OAM DMA helper has separate `OAMDMARoutineSource` and
`OAMDMARoutine` labels for its ROM0 `$0925` storage and HRAM `$FFF0` execution
addresses. Its loader derives the copy length from the ROM boundaries, and an
assertion prevents the source image from drifting silently.

The two ROM0 interrupt-installation wrappers are now distinguished. The
gameplay installer copies the WRAM LCD and VBlank handlers and enables both
sources. The basic installer places an LCD `reti`, copies the minimal VBlank
handler, and enables VBlank alone. Original address aliases remain available
to banked callers.

`PrepareDisplayForScreenTransition` now names the common VBlank-synchronized
path that hides and clears the HUD and palettes, installs the basic interrupt
mode, resets scrolling and tile selection, and clears both OAM copies.
`ClearShadowOamAndTransferFar` identifies the final bank-`$02` clear plus HRAM
DMA step.

The object-removal path's ROM0 `$0B65` helper is now
`RedrawLevelCells2x3AroundPixel`: it converts BC/DE pixel coordinates to cells
and redraws exactly two columns by three rows around that point through
`DrawLevelCellIfVisible`.
Its caller is now `RemoveObject`, which first sends the record through the
pending-level-object path, preserves its type and position, frees the runtime
slot, and then performs two optional caller-controlled effects. Their
higher-level meanings remain unresolved.

BG-map writes generated by level and interface drawing are now represented as
a deferred queue in WRAM bank 4. Each four-byte record contains a destination,
attribute, and tile. `QueueBgMapWrite` appends records without an overflow
check; `FlushBgMapWriteQueue` writes attributes to VRAM bank 1 and tiles to
bank 0 before resetting the queue. The main loop flushes it once per frame.

Boot register A is preserved as `wBootHardwareMode` before the memory clear;
the compatibility guard accepts only the CGB value `$11`. The main loop stages
SCX and SCY through `wPendingScrollX` and `wPendingScrollY`, then increments the
16-bit `wFrameCounter`; its low nibble gates one observed 16-frame update.

Level completion and player destruction share `wLevelEndCountdown`. The
completion path sets `wLevelComplete`; the destruction path clears
`wPlayerAlive`. `UpdateLevelEndCountdown` distinguishes those states and
returns carry only when an active countdown expires.

The score is a 32-bit little-endian accumulator at `wScore`. `AddToScore`
adds a 16-bit `BC` value with carry propagation through all four bytes;
`CheckNextScoreThreshold` compares it to the next four-byte bank-$01 table
entry and advances `wScoreThresholdIndex` after awarding that threshold.

`ReadJoypad` polls both P1 groups and stores held buttons in `wJoypadHeld` and
rising edges in `wJoypadPressed`; direction bits are 0-3 and A/B/Select/Start
are 4-7. `wVBlankCounter` drives the every-other-frame polling cadence.
Start toggles `wPauseActive`. While it is set, the normal runtime callback is
suppressed and `RunPauseLoopFar` enters the bank-`$01` pause loop, which hides
the HUD, waits for Start to clear the flag, refreshes the HUD, and restores its
position. `ProcessGameplayInput` owns that toggle, recognizes the simultaneous
A/B/Select/Start reset chord, and otherwise tail-dispatches the selected
control callback with the player-object pointer and held-button byte.
The three callback targets are conservatively named `HandleControlScheme0`,
`HandleControlScheme1`, and `HandleControlScheme2` from their proven selection
by `wControlSetting`; their button layouts retain scheme-neutral names. The
shared vehicle fields now identify the bounded speed, maximum speed,
reverse-vector flag, turn-repeat interval, and turn timer; their acceleration,
deceleration, stop, and clockwise/counterclockwise turn helpers are named
accordingly. Forward and reverse velocity loaders index eight-byte bank-`$05`
records by speed and direction, copy signed 24-bit X/Y deltas into the object,
and `CalculateVehicleNextPosition` integrates them into its candidate 16.8
position. `UpdateAllObjects` walks all 64 runtime records and dispatches their
status-specific paths; its vehicle path updates motion, timers, collision, and
destruction. `UpdateVehicleTimersAndRemoveDestroyed` also attributes score to
the player when its recorded attacker pointer matches the player object.
The earlier `$20` field description has been corrected: vehicle health is at
`$1F`, while `$20` is status-dependent—a vehicle action-repeat interval, a
timed-effect lifetime, or a state byte in the status-2 update path.
`UsePlayerWeaponOrPowerup` is gated by the vehicle action timer and a maximum
of three outstanding shots. It reloads that timer from the type-specific `$20`
interval, then either spawns the selected shot or consumes the screen-effect
power-up. `SpawnVehicleProjectile` creates the status-2 record, links it to its
firing vehicle, and applies the selected bank-`$05` subtype parameters;
`QueueVehicleActionSound` queues its subtype-specific sound unless unresolved
vehicle byte `$26` suppresses it.
`GetVehicleMuzzlePositionFar` obtains the direction/type-adjusted firing point;
`SpawnVehicleMuzzleEffectFar` creates its short visual effect. The shared
`SpawnTimedObjectEffect` allocator creates the status-3 effects also used by
destruction and level-cell interactions.
The ROM0 interfaces `InitializeLevelObjectsFar` and
`DispatchLevelStateCheckFar` now identify the bank-`$04` level-object setup and
the bank-`$03` per-level state-check table without renaming unresolved adjacent
banked routines.
Status-4 objects now have a complete named lifetime/render path. Byte `$1F` is
an optional lifetime (`$FF` persists); finite records blink on VBlank-counter
bit 4, render as one back-allocated OAM entry using tile `$53 + type`, and are
freed when their lifetime reaches zero. `SpawnStatus4Object` creates these
records from a caller-supplied type and lifetime with motion/state cleared.
The three ROM0 numeric wrappers now expose their complete contracts: unsigned
8-, 16-, and 32-bit values are converted through bank `$01` into two, three,
or five packed-BCD bytes for HUD and menu digit rendering.
After player destruction, `HandlePlayerLifeLossFar` clears active sound,
decrements lives, and waits for the current music sequence to finish.
`AnimatePlayerHealthBarFillFar` exposes the bank-`$01` VBlank-paced health-bar
animation that restores the saved health one point at a time.
`CopyMapRows20Wide` exposes the shared 20-byte-row copier with its 32-byte
destination stride. `LoadHudBaseMapsFar` uses it through bank `$01` to seed the
HUD attribute and tile staging maps before dynamic status fields are drawn.
`DrawEmptyHudHealthBar` writes the verified zero-health six-cell pattern used
when the HUD is first transferred; later frame updates replace it with the
scaled live-health pattern.
`LoadPauseHudMapsFar` identifies the alternate HUD maps transferred only by
the active pause loop. `RunNoLivesScreenFar` identifies the bank-`$2A`
animated fixed-screen path reached only after the player's lives reach zero;
neither label guesses the pictures' wording from appearance.
`WaitForButtonOrTimeout` explains the bank-`$2A` fixed screen's `$C6B5` test:
it exits on any held button or after its caller-provided VBlank timeout.

The selected `wPlayerObjectType` is instantiated by `SpawnPlayerObject`, which
stores the resulting 64-byte record pointer in `wPlayerObject`. Player lives
are held in `wPlayerLives`, initialized to three, clamped to nine by
`GainPlayerLife`, decremented on the destruction flow, and rendered as one HUD
digit by `DrawPlayerLivesDigit`.

Object-record byte `+$1F` is type-dependent. Core vehicle types use it as
health: `ObjectMaxHealthByType` supplies maxima 35, 50, 65, and 40, and the
set/add/subtract helpers clamp against those bounds. Timed type-3 effects reuse
the byte as animation age and release their record when it reaches byte `+$20`.
`wPlayerHealthRecoveryTicks` restores one vehicle-health point every other
VBlank while nonzero; its direct producer remains unknown. These interpretations
and the six-bit health-delta mask are centralized in `include/object.inc`.
The same include now records current and previous 16-bit pixel-coordinate
offsets and the two per-frame displacement bytes. `CenterLevelViewOnObject`
converts those coordinates to cells and clamps the 21-by-19 visible region to
the current level bounds.
The runtime pool is 64 records at `wObjectPool`. `AllocateObjectRecord` scans
status byte `+$1D` for a free slot, and `FreeObjectRecord` performs the
status-2 cleanup before releasing a slot. `ClearObjectPool` applies that path
to every record rather than discarding active state blindly.
Sprite construction uses a bidirectional 40-entry shadow-OAM allocator at
`wShadowOam`: ordinary entries grow from the front, overlays grow from the
back, and exhausted writers receive a separate discard entry. The unused
middle is cleared before DMA so stale sprites cannot survive. Native 16-byte
sprite tiles are staged separately at `wDynamicSpriteTiles`; its allocator
rejects totals of 49 or more, although the observed VBlank HDMA transfers only
the first 40 tiles. That capacity mismatch is preserved as an unresolved
original behavior rather than normalized.
Object positions use 16.8 fixed point: an 8-bit fractional byte followed by a
16-bit pixel coordinate for each axis. Candidate bytes `+$13-$18` are committed
to current bytes `+$00-$05`; the previous integer coordinates, screen
coordinates, visibility flag, and 16-way direction field are then refreshed
through named helpers.
The level-object loader identifies its player-start record and stores
`wPlayerSpawnX`, `wPlayerSpawnY`, and `wPlayerSpawnDirection`.
`PositionPlayerAtSpawn` applies those coordinates to `wPlayerObject`; the
direction is installed in the same initialization path.
`CreateObjectAtOrigin` combines allocation, zero position/direction, the
four-entry type profile, and maximum-health setup. The original routine does
not test allocation failure before initializing the returned record; this
behavior remains unchanged and is not presented as safe.
`RenderObjectSprite` derives a frame index from byte `+$1F`, resolves the
bank-`$08` tile frame through the bank-`$02` pointer at `+$21`, copies the
`+$25` tile count into the shared staging buffer, and emits shadow-OAM entries
from the bank-`$02` layout pointer at `+$23`. `AdvanceTimedObjectEffect` is
confined to the type-3 update path, establishing the age/lifetime reuse above.
The HUD window setup, signed vertical movement, two-bank tilemap refresh, and
shutdown paths are now named; the refresh transfers five 16-byte blocks from
each of `$C400` and `$C440` to VRAM `$9C00` during VBlank.
The status builder converts the 32-bit score to six decimal digits, scales the
player's health through one of three fixed-point constants into a six-cell
meter, renders the lives digit, and draws the active power-up. Player-object
bytes `+$29` and `+$2A` hold the power-up kind and remaining charges. Its
2-by-2 icon selects one of three eight-byte CGB palettes copied through
`wHudPowerupPalette`.
An independent four-tile indicator blinks while `wHudAlertActive` is nonzero;
its gameplay meaning is not yet named.

The interface palette buffers are now connected end to end. Five bank-`$08`
palettes are copied into named eight-byte WRAM records. `LoadInterfacePalettes`
also snapshots hardware BG palette 6 into `wBackgroundPalette6`; the VBlank
routine uploads that saved palette followed by `wUiFontPalette` to BG palette
slots 6 and 7. Power-up palette pointers now use the corresponding WRAM labels
instead of raw addresses.

Background fades use a 2 KiB cache in WRAM bank 2: 32 complete 64-byte CGB
palette frames from `wBackgroundPaletteFadeFrames` through `$D7FF`.
`PrepareBackgroundPaletteFade` clears the cache and copies the target colours
into frame 31 at `wBackgroundPaletteFadeTarget`;
`BuildBackgroundPaletteFadeFrames` constructs the preceding RGB555 steps.
`LoadBackgroundPaletteFrame` installs any complete frame, while
`CopyBackgroundPaletteFromFrame` extracts one eight-byte palette for scrolling
scene transitions. The separate RGB555 helpers saturate each channel while
brightening or darkening. ROM0 `$389A` is a coherent palette-step routine but
has no call or jump reference in the cartridge, so it remains unnamed.

## Level banks `$09-$26`

The 30 banks are structured as 15 two-bank levels through the record table at
bank `$05:$4300`. Each odd bank contains a cell map, native 2bpp tiles, an
attribute lookup table, BG palettes, fill, and its bank marker. Its paired even
bank contains equally sized tile and attribute maps, followed by fill and its
marker. All 491,520 bytes are covered exactly once.

The broader banks `$09-$3A` relocation audit accounts for 152 raw pointer
references to 131 labelled targets and 80 raw bank bytes. Bank-aware assertions
pin every target that is still stored numerically, and thirteen shift tests
prove six movable structures relocate correctly while seven hardware- or
raw-reference-constrained structures stop the build. Cell-map bit semantics,
all level-index writers, object-bank selectors, screen routes, and scene routes
are documented in [`research/BANKS_09_3A_SEMANTIC_RECOVERY.md`](research/BANKS_09_3A_SEMANTIC_RECOVERY.md); five controlled audit
corruptions must fail for their intended reason.

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

`InitializeLevelRuntime` now names the ROM0 per-level reset/load path. Its
trailing 15-byte `LevelAnimatedCellAttributes` table supplies one CGB attribute
per level to the bit-6 animated-cell renderer; the table and its WRAM cache are
labelled and address-checked.

## Confirmed graphics boundaries

Bank `$08` is fully classified; see [`research/BANK08_RESEARCH.md`](research/BANK08_RESEARCH.md). Every boundary is
derived from loader operands, palette loads, the bank-`$02` object animation
frame tables, the bank-`$05` effect step table, the glyph table and the
metatile table, and checked by `tools/bank08.py` (23 negative tests).
Corrections to the earlier description: the UI font is 62 tiles (`$4000`;
tile 0 is never loaded) followed by a 16-record metatile table at `$43E0`;
`$69B5` holds 4 tiles, not a 66-tile font; the encoded-text font is 37 tiles
(blank, 0-9, A-Z) at `$6B85`, selected through the 128-entry ASCII glyph
table at `$6B05`. `$44A8-$60EF` is object-animation and effect sprite tiles
separated by 8-byte palette-shaped records. Byte totals: code 27, graphics
10,832 (992 referenced only by unreachable effect steps, 16 never loaded),
palettes 64, palette-shaped records 336, tables 330, fill/marker 4,624,
unknown 171 (`$6108-$6109`, `$6112-$6119`, `$624A-$6262`, `$6A7D-$6B04`).

The ROM0 screen-effect path is now named through its full 75-frame lifetime.
It renders three parts per frame from the bank-`$05` step records, copying
their bank-`$08` tiles into the dynamic sprite staging area and building OBJ
palette-3 OAM entries. Every fourth non-final frame it advances six bytes in
the step table and processes one eligible object. Up to 30 of those advances
can briefly blank the display, gated by a random two-bit value. Expiry converts
visible cell-bit-2 regions, restores OBJ palette 3, and clears the active flag.
The trigger's gameplay identity is not yet proven, so its names remain neutral.

The shared full-screen map copier at ROM0 `$05C5` is now `CopyScreenMaps`.
It copies a packed width-by-height attribute rectangle to VRAM bank 1 and the
matching tile rectangle to bank 0, applying the 32-byte BG-map row stride and
preserving all input registers. The paired 32-frame black and white palette
transitions and the far level-lookup initializer also have behavioral names.
The screen dispatcher now exposes its eight-byte WRAM entry explicitly:
bank byte, reserved byte, initialization pointer, drawing pointer, and a
reserved word. Its 13-entry count and copied size are checked constants.

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
bank markers are explicit source. Bank `$3B:$4000-$508F` additionally contains
the Game Boy Color compatibility warning used by `RequireCgbHardware` during
startup when the boot value is not `$11`. Its actual DMG-format layout is 221
physical 2bpp tiles, a 16-byte alignment gap, and a 20x17 tile map. The loader
sets `BGP` directly and does not read attributes or CGB palettes. Zero fill and
one trailing unread palette-shaped record occupy the rest of the prefix.
Detailed loader and range evidence is recorded in [`research/GBC_WARNING_RESEARCH.md`](research/GBC_WARNING_RESEARCH.md).
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

Details: [`research/BANKS_2A_2E_RESEARCH.md`](research/BANKS_2A_2E_RESEARCH.md).

- Reconstruction: every byte is represented as code (2,803), structured data
  (13,694), typed 2bpp tiles (51,792), or padding (13,631); no opaque ranges
  remain. The matching ROM hash is unchanged.
- Understood: screen descriptor format, picture layouts, the 13-entry
  screen-mode dispatch and its index bounds, the three routine templates, the
  palette-fade direction flag, and the fixed animated screen in bank `$2A`.
- Not understood: why the bank-`$2E` package routines have no caller, the
  unread descriptor fields, the bank `$01:$596D` index bound, and what each
  picture is used for.

## Audio

Details and evidence: [`research/AUDIO_RESEARCH.md`](research/AUDIO_RESEARCH.md).

Reconstruction completeness (bytes represented as explicit, structured
source rather than opaque INCBIN):

- Banks `$03` and `$04` are explicit through `$7FFF`. Bank `$03:$69D7-$69DA`
  retains four unreferenced instruction-shaped bytes as data, followed by
  checked zero fill and its bank marker. Bank `$04:$6575-$7FFE` is checked
  zero fill followed by its bank marker. Neither bank has a remaining opaque
  suffix asset.

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
