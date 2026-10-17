# Unresolved (whole ROM)

Machine-derived inventory: `reports/rom_unresolved_inventory.json`, built from the
range map. This page lists the open questions behind those numbers. Each item
says what is proven and what is not. Nothing here has been turned into a symbol.
Timing figures come from host models over the shipped ROM bytes. None has been
checked on an emulator or on hardware.

## Closed in this pass

- **Second intro call, stale `$D140`:** `FadeOutSceneBackground` returns on
  X = 22..29; a VBlank needs X >= 36 (margin 7 lines). (w108)
- **Menu-grid fades and boot fade:** windows end by LY 66, before the first
  object line (72). (w94/v129)
- **HRAM aliases:** w100's 13 scene/score groups verified (v114); 42 object
  scratch aliases added in 11 proven groups (w126); raw shared-scratch literals
  219 -> 59.
- **Bank `$08` names:** `Bank08PowerupIcon1-3Palette`, `Bank08HudAlertIconTiles`;
  VRAM tile comments corrected to `$4E-$5D`. (v115)
- **Sound patch `$00`:** one `sound_patch_ch2` line; 33 `_UnreadTrailer` labels
  (24 sfx, 98 bytes; 8 `FE FF` music; the final `FF FF` under `Music_07`). (w125)
- **Range map:** INCBIN slice check, ASSERTs no longer count as readers, RAM-image
  vector crediting, separators, stricter indexed members (w116); neutral bytes
  14 -> **12**.
- **Asset slices:** `asset_slices.txt` and `check_asset_slices` cover all 254
  placed INCBIN slices. (w127)
- **Legacy aliases** `Jump_00DA`, `RAM_D56A`, `RAM_D62A` removed. (w131)
- **Sound sites:** 57 (50 immediate, 7 dynamic), all structurally reached. (v119)
- Earlier passes: start modes, object flags, screen modes, bank bytes, named RAM,
  scene HRAM, tracker table, level-data loaders, scene palettes, `$D140` exit
  flow, scene handler bounds, I2, BCD tables (see git history).

## Interrupt banking (see INTERRUPT_BANKING.md)

1. **`ClearBackgroundPalettes` -> `ClearBackgroundPalettesImpl` at the three
   non-fixed sites.** Every window ends by LY 143 for any last-fade
   `Audio_Update` up to about 12,969 M (v77, strong). The second intro call is
   now covered (w108, strong): `LoadBackgroundPaletteFrame` copies 2-4 bytes per
   visible line (not 0-3), and the following `ClearBackgroundPalettesImpl` run
   does one iteration per line. Remaining dependencies:
   - the CGB mode-3 length (172-185 dots modelled) and the empty-OAM premise;
   - w108 reuses w18's L+15/L+43 offsets, w47's 2,196 bound and v76's start
     estimate (copy start <= LY1+65 M); X = 36 needs about 1,500 M more.
2. **`Audio_Update` at `60D2`, `610A`, `62C7`.** Safe under the invariant model
   (v70). Bounds: 6,882 M absolute, 2,497 first intro-2 call, 2,192 last fade
   frame (v71/v77). Remaining dependencies:
   - hardware mode-3 length, GDMA stall and IRQ latency;
   - repeated noise locks (the 1,654 music maximum is strong only);
   - w16's simulator truncated RAM images at `$60` bytes; recount needed for
     `$C7F1`, `$D140`, `$D330`, `$D3B0` (v98);
   - OAM writes through arithmetic pointers were not excluded.
3. **Unguarded VBlank call to bank-`$01` `$6580`** while another bank is mapped:
   I2 holds (v49); whether that closes this case has not been re-checked.
4. **SVBK = 2 windows** in `LoadBackgroundPaletteFrame`: reachable under the
   static model (v90); the STAT handler can call `$D310`/`$D120` while WRAM
   bank 2 is mapped.
   - **Effect (w113, model trace):** bank 2 holds the 32-frame fade cache, so
     the handler executes palette bytes as code. Second-scene fixed scenes 6, 7,
     9, 10 (levels 0-5 and 9-14) **crash** (ROMB0 <- `$C0`, SP corrupted).
     Scene 8 (levels 6-8) returns after 5 `stop`s (freeze until joypad input)
     and two corrupted HUD palette bytes.
   - **Open:** row scenes 0-5 (unmodelled VRAM/HRAM reads, loops, `$0004`
     calls); `stop` under double speed (modelled as resume); the ROM0
     continuation after a crash.
   - **Trigger:** LYC=0/1 route needs `hSceneBankSwitchGuard != 0` at the second
     `InitSceneDisplay` (password start after a level-select game, music `$86`;
     w89). The residue is a burst **horizontal velocity**, not X: top-level
     values are never 0, child values can be 0, and an empty final pass leaves an
     older value (v112). The no-lives route is unconfirmed (needs a camera
     scroll that draws on the expiry frame).
   - Guard 0: >= 9 VBlanks decrement `hSceneWindowSplitCountdown` first
     (F0 <= 133; v90). v111's full-system simulation fixes N = 10, F0 = 132
     on every path, which makes the hazard depend on input: music `$86` plus a
     Start press timed so a fade frame is frame 131. With no input it is
     safe. The exit fades are safe; intro scene 1 is still open.
   - W50-7 (w108): the window covers 2,508 M exactly when H + A >= 985.
5. **Not run:** the emulator watch.

## Code and control flow

6. **Labels (recounted from snap8/src and include):** no `Jump_BB_XXXX`,
   `Call_`, `RAM_XXXX` or `Bank01RomImage_` labels remain. One address-named
   end marker remains: `Bank01Data_4F40End`. 288 `Func_` labels remain, all as
   aliases beside a descriptive name (172 commented "legacy alias"); 78 are
   still used as operands (176 operand lines, comments excluded).
7. **`UpdateAllObjects` bank `$01` write:** strong, not proven. The `jp hl`
   handler targets are untraced. (w11/v41, w106)
8. **Unreferenced routines** (unreached in w99/v119's graph; dead-code lists must
   be built per address, since 22 "unreached" labels are primary names of live
   code reached through an alias, e.g. `ReadJoypad`, `FillBytes`,
   `WaitForButtonOrTimeout`, `NoLivesScreen_*`):
   - the five bank-`$01` variants at `$7934-$7BC4`;
   - `UnreferencedBank02FrameRoutine` (`$02:4000`);
   - `SpawnBurstSpriteBlock`/`AnimateBurstSpriteBlock`;
   - `Bank1NoOpFar`/`Bank01NoOpEntry`, `UnusedMenuRamNoOp`, `UnusedSceneRamNoOp`;
   - `UnusedLoadScrollVariantForGridCell`, `SubtractBCFromHL`,
     `TestLevelCellBits2And3AtPixel`;
   - `AdvanceReturnToMenuCounter` (v58);
   - `DrawObjectStatusCountsToWindow` (only reader of `$C6ED/$C6EE`; v56);
   - `UncalledScreen2E_*`;
   - not previously documented (v119): `CopyTilemapRows20`, `ClearHardwareOAM`,
     `ConvertU16ToPackedBcdFar` + `AddWordToBcd24`, `GetObjectType`,
     `ClassifyShadowOamCapacity`, `SetTextCursor`/`AdvanceTextRow`/
     `ClearTextColumn`, `StepBackgroundPaletteColors` + `StepRgb555TowardTarget`.
   - Limits: reachability is structural; db/dw numeric operands and
     arithmetically built pointers are not followed.
9. **Recorded-path subsystem** (bank `$03`): unreachable. Its role and the owner
   of `$CFEF-$CFF2` are unknown.
10. **Gameplay identities still open:**
    - scene contents; what MenuState05 pictures 0-2 and the mode-8 burst depict;
    - why the mode-1 auxiliary timers exist (their count is never used; v34);
    - object field +$3D-$3F: no access found (strong; v91);
    - +$3C: never written by shipped data (626 records use end actions 0, 2, 5;
      v91);
    - whether `PickupStartRenderHideTimer` has effects beyond hiding and the
      proximity skip (v40, v57);
    - the bank-`$2A` no-lives screen on the code-accept path (v109).

## Data

11. **Bank `$02` `$5E80`** (`Bank02Unknown5E80`): one unread byte, meaning
    unknown; `$5E81` is an unread RGB555 record. (w104)
12. **Bank `$08`:**
    - `$6108-$6109`, `$624A-$624F`, `$6260-$6262`: no operand, header or overrun
      reaches them (w104, strong). With `$02:5E80` these are the **12 remaining
      neutral bytes** (four ranges). Meaning unknown.
    - 40 unread palette records (groups A-D plus `$6263`, `$68D5`, `$69F5`).
      Why C and D exist is unknown. (w12/v42)
    - Effect steps 19-71 and their 12 tile blocks: unreachable.
    - `Bank08ArrowUpTiles`/`Bank08ArrowDownTiles` are named from appearance only.
13. **Level data:**
    - Bits 4/5 of the cell map are never used.
    - Lookup entries 0-95 have no read path (w64).
    - **Rule E** (v93): for every map cell with attribute bit 3 clear and index
      `(tile+$7F)&$FF < $A0`, `LevelAttributeLookup[index]` equals the map
      attribute with `$60` cleared; every index read is below `$A0`.
    - Set2 overrun cells: 9 in level 3, 6 in level 4. (v93)
    - 66 bit-3-only cells are suspected never to convert; the stale-coordinate
      diagonal step in `ResolveObjectLevelBit0Movement` is not excluded. (w39)
    - Why five region rectangles contain empty cells.
    - Whether any type-7 pickup source exists besides static spawns.
    - Whether any level is narrower than 21 or shorter than 19 cells (decides the
      `CenterLevelViewOnObject` defect below).
14. **Spawn records:** 103 records of types 0/1/2/5 have byte 10 != 0 and
    byte 11 = 0; zero charges allow 256 uses (w64). Intent unknown. Type-5
    byte 7 is never read.
15. **Object sequences** (w64): 135 unread nonzero +6 bytes; distance 9 at level 3
    slot 2 record 2 has no reader; four sequences are unselectable. Two
    persistent over-reads, (3,6) and (6,15); whether either object reaches its
    final point is unknown.
16. **Audio:**
    - The padding, music entry byte 3 and the bank-`$07` head. The 33 trailers
      are proven unread; their build-time purpose is not.
    - The `$BFC` copy length (`$C00-4`): weak hint of a truncated build copy.
    - Never-queued ids (strong; w99/v119): patches `$00 $02 $03 $1C $1F $20`,
      sfx `$40-$43 $47 $48 $4C-$4E $50`, music `$89`. Never-sounded patches:
      `$00 $01 $02 $03 $16 $1C $1F $20`.
    - Patches `$0C`-`$0F` are direct-queued only by the password site's
      pressed-edge nibble and need opposing input; `$0D`-`$0F` need Up+Down
      (`$0C` also sounds via sfx `$45`). Whether hardware reports Up+Down is
      unknown. (w55/v73, v119)
    - Patch `$00` +6 is `$22`; why is unknown.
17. **Scenes:** the unread `$3B:5088` record (`Bank3BGbcWarningUnusedPalette`);
    a grey-ramp reading is weak. (w64)
18. **RAM:**
    - the menu-grid scroll order after a level return (strong only);
    - the meaning of `$DC03`;
    - whether scene interrupts can run on the password screen (`$FFB0-$FFB4`);
    - indirect `[hl]`/`[c]` HRAM writes were not excluded (w66);
    - still raw: the bank-`$02` burst routines on `$FF80-$FF8A`, and
      `RunLevelExitScreenFlow`'s `$FF81`/`$FF82` clears (w126);
    - `operand_dispositions.json` is stale for `$FF80-$FF8D`, `$FF90`, `$FFA0`,
      `$FFA1` after w126.
19. **Opaque assets:** `assets/bank_07/audio_build_residue.bin` (3,061 bytes, a
    copy of bank `$06` data; byte 0 is emitted by `Bank07MalformedSoundPatch00`).
20. **Tooling:**
    - Closed 2026-10-17: `make extract-assets` now uses
      `tools/prepare_assets.py`, accepts commented manifests, verifies both
      cartridge hashes before writing, and regenerates all 158 files including
      `object_animation_tiles.bin` and `effect_tiles.bin` from their
      non-contiguous slices.
    - `IndexedSpriteGridDescriptors` stores raw `$D0,$4A`/`$30,$48` instead of
      `IndexedSpriteGrid0Tiles`/`IndexedSpriteGrid1Tiles`; a shift is detected by
      address pins, not tracked (w127).
    - `tools/gen_bank08_asm.py` still emits the old bank-`$08` names (v115).
    - `sound_sets.py` and `semantic_invariants.py` key dynamic sound sites by
      line or routine, not by label/site (v119, v103).
    - The range map's fall-through rule credits a label without requiring its
      predecessor to be reached (w116).
21. **Hardware:** nothing here has been checked on physical hardware.

## Original defects (documented, not fixed)

- **Stack leak.** `RunMenuAndLevelLoop` calls `RunLevel`, which never returns;
  each menu return leaves `$0186` on the stack. Pushes reach `$C000` after
  71 menu returns (90 with no interrupt at the peak, 126 at the latest), and a
  later `RestartGame` halts in `RequireCgbHardware`. Open: whether peak and
  interrupt coincide; the open-bus value. (w46/v58)
- **SVBK = 2 STAT entry** (item 4): executes the bank-2 fade cache as code;
  crash for second-scene fixed scenes 6/7/9/10. (v90, w113)
- **Kind 3 on a level vehicle.** Firing returns NZ without spawning; +$29 and the
  velocity are written through a stale HL into `$0000-$0FFF`. Structural
  reachability only. (v91)
- **A bounced shot can hit its own shooter** (`$FFA1` = `hHitProjectilePowered`
  skips the owner test in `ResolveProjectileHit`). (v57/v91)
- **`FindNearestVisibleObjectFacingSource`** compares the 16-bit best distance
  byte by byte; a best of `$0100` rejects `$00FF`. (w126)
- **`CenterLevelViewOnObject`** discards the borrow of `sub $15`; a level under
  21 x 19 cells gets a large maximum. Strong; reachability depends on item 13.
  (w126)
- **Menu-grid OBJ left on.** `bit 1,a` where `res 1,a` fits. (w43/v70)
- **X-axis bounce stores L** instead of incrementing; no effect. (w37)
- **`WriteBgPalette7FromD3F8`** is called at its ROM address; its WRAM copy at
  `$D2C0` is never called. (w104)
- **`EnableDoubleSpeed`** executes `stop` without testing KEY1 bit 7. Not
  verified. (v76)
- **Basic handlers during HUD setup** reach `StatHandlerReti`; harmless. (v92)
- **`Audio_QueueSound` with `e = 0`** returns after four pushes; all callers
  pass nonzero E. (w55/v73, v112)
- **Dead loads:** `ld bc,TrackerDirectionLookup+$12` (bank_02) and an overwritten
  read of +$1A (bank_00). (w20/v54, v57)
- **`LoadOptionsSettings`:** `cp $02` has no branch after it. (w46)
- **Two button waits after mode 8.** May be intended. (w15/v34)
- **Latent `adc a,e`** in the burst sprite routines.
