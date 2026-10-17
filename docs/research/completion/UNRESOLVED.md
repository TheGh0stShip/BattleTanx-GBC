# Unresolved (whole ROM)

Machine-derived inventory: `reports/rom_unresolved_inventory.json`, built from the
range map. It lists the neutral-label, no-reader and untraced-code ranges per
bank. This page lists the open questions behind those numbers. Each item says
what is proven and what is not, and nothing here has been turned into a symbol.

## Interrupt banking (see INTERRUPT_BANKING.md)

1. **`Func_3960` -> `Func_02_46E1` outside `LoadFixedSceneForRow`: unproven.**
   The affected sites are `ClearSceneSplitPalettes`, the intro's final
   `ClearBackgroundPalettes` and `ShowScreenMode12WithPasswordScoreLives`.
   - `hFF80 = 0` and raster effects are on.
   - `hFF86` is not known statically.
   - The window lasts about 31-42 lines and polls STAT.
2. **`Audio_Update` (bank `$06`): unproven** at three call sites.
   - The sites are the first pass of the `610A` loop, the queued-sound `60D2`
     path and the per-frame `62C7` call.
   - They start when `AdvanceSceneScroll` returns, which depends on PPU mode-3
     length.
   - The worst case is only an upper bound (about 8,200 M-cycles); the
     `Music_HandleEvent` and `Audio_PlaySound` paths were not counted exactly.
3. **`LoadScrollingScenePalette` from the two menu-grid callers:** the
   `hSceneRowHdmaPending = 0` entry condition (invariant I2) is not proven.
4. **Stale code at `$D140`** in the exit flow, between the interrupt enable and
   the RAM-code copy, and the **SVBK = 2 windows** in `Func_3A52`/`Func_3A68`.
   Both are strong suspicions, but neither has been timed.
5. **Not run:** the emulator watch. No emulator is installed, and none was
   installed for this work.

## Code and control flow

6. **377 branch labels and 63 RAM-image labels** keep automatic names (bank
   `$01`: 297 `Jump_`, 39 `RAM_`; bank `$03`: 80 `Jump_`; bank `$00`: 24 `RAM_`),
   plus 35 address-named `Bank01RomImage_`/`Bank01Data_` labels.
7. **Raw bank bytes with no proven consumer:**
   - `RunMenuAndLevelLoop` (second site, before ROM0 `RunLevel`);
   - `UpdateAllObjects` (selects bank `$01`, but only ROM0 routines are called);
   - `LoadObjectPalettes` (a redundant first write).
8. **Unreferenced routines whose purpose is unknown:**
   - the five bank-`$01` variants at `$7934-$7BC4`;
   - `UnreferencedBank02FrameRoutine` (`$02:4000`);
   - `SpawnBurstSpriteBlock`/`AnimateBurstSpriteBlock` (`$02:635F`/`$63F4`),
     whose latent `adc a, e` defect is documented;
   - `Bank1NoOpFar` / `Bank01NoOpEntry`;
   - `UnusedLoadScrollVariantForGridCell`;
   - `SubtractBCFromHL`;
   - `TestLevelCellBits2And3AtPixel` (`$00:164F`).
9. **Recorded-path subsystem** (bank `$03`): proven unreachable, and it could
   never record even if entered. Its intended gameplay role is unknown, and so
   is the owner of RAM `$CFEF-$CFF2`, which a forward read from index 63 would
   reach.
10. **Gameplay identities not established:**
    - `wGameStartMode` values;
    - object flag bit 3 and its states 0/1/2;
    - status-4 subtypes 0-8;
    - screen modes 4 and 8 and the bank-`$02` burst activity;
    - scene contents;
    - the purpose of the mode-1 auxiliary timers, whose result
      (`wLevelAuxTimerExpiredCount`) is never read.

## Data

11. **Bank `$02` `$5E80-$5E88`:** `$5E80` is one unknown unread byte. The
    following eight bytes are an unused four-word RGB555-shaped record with no
    reader; its purpose is unknown.
12. **Bank `$08` unknown bytes:** `$6108-$6109`, `$624A-$624F` and
    `$6260-$6262`. No reader, no pointer and no over-read was found; the
    meaning is unknown. 41 palette-shaped records are unread. Effect steps
    19-71 are unreachable, and 12 tile blocks (992 bytes) are referenced only
    from them.
13. **Level data:**
    - bits 4/5 of the cell map are never used;
    - five mixed region rectangles are unexplained (1 in level 3, 4 in level 8);
    - only level 3 uses cell `$0A`;
    - 96 leading lookup bytes per table can never be read;
    - two attribute-table mismatches (levels 1 and 13);
    - the VRAM1 tiles `$BB-$C2` used by the bit-6 path have no loader found;
    - the per-level unused animation records are upper bounds, because
      conversion reachability is not proven.
14. **Spawn records:** 103 records of types 0/1/2/5 have byte 10 != 0 with byte 11 = 0 (zero
    charges, which wraps to 255 uses). Whether that was intended is unknown.
    Byte 7 values on type 5 are never read.
15. **Object sequences:**
    - 135 records store a nonzero +6 that nothing reads;
    - level 3 slot 2 record 2 stores distance 9 where 8 is computed;
    - four sequences can never be selected;
    - the level 3 slot 6 and level 6 slot 15 over-reads are reachable as far as
      the code goes, but whether either object lives long enough is not proven.
16. **Audio:**
    - why the padding, music entry byte 3 and the sequence tails exist;
    - the bank-`$07` head bytes `0C 00 65 00 44 62 65 00`;
    - the `$BFC`-byte length of the bank-`$07` copy;
    - patches `$0E`/`$0F` are reachable only if joypad input can produce `e` =
      `$0E`/`$0F` (not established).
17. **Scenes:**
    - whether the zeroed palette entry from the `+$38` window is ever visible;
    - whether the level loader later overwrites `$D800-$D807` after the F04
      palette spill;
    - the unread record at `$3B:5088`.
18. **RAM:**
    - the meaning of `$CD26` (only ever `$55`) and `$CD29`;
    - the scene use of `$FFAB` (written only) and `$FF97`;
    - the format of `$D7FF` with SVBK 2;
    - `$DC03` stored into `$D564`;
    - whether scene interrupts can run on the password screen, which would
      settle the `$FFB0-$FFB4` / `hSceneRowTileVramAddress` overlap.
19. **Opaque assets:**
    - `assets/bank_07/audio_build_residue.bin` (3,061 bytes, an identical copy
      of bank `$06` data);
    - `assets/bank_02/tracker_direction_lookup.bin` (2,048 bytes, typed by
      reader but not by format validator).
20. **Hardware:** nothing here has been checked on physical hardware.
