# BattleTanx GBC audio subsystem

Scope: the sound driver, its RAM state, its callers and the data it reads.
Banks `$2F`-`$3B` and the bank `$01` tables at `$59AB` / `$5A60` were not
examined. All addresses are CPU addresses; `BB:AAAA` is ROM bank `BB`.
ROM offset = `BB * $4000 + (AAAA - $4000)` for `BB > 0`.

Rebuild status: `make check` still produces SHA-1
`5078584e86c0b6f4687c424cc00bbd762ba6573a`.

## 1. Summary

The game uses one small, polled sound driver. Its code is at `06:7CAE-7FD1`
(Audio_Init, Music_HandleEvent, Audio_PlaySound, SfxSequence_Update) plus
four routines in ROM0 at `$2EB8-$2F92` (Audio_InitFar, Music_Update,
Audio_Update, Audio_QueueSound). Every byte the driver reads lives in bank
`$06:$4000-$7CAD`. It has no interrupt or timer hook: game loops call
Audio_Update once per frame. No RAM-executed audio routine exists, but one
RAM routine does call Audio_Update (section 4).

Sound ids form three ranges that one queue carries:

| Id | Meaning | Table |
| --- | --- | --- |
| `$01-$24` | start one sound patch | SoundPatches `06:4000`, 37 x 8 bytes |
| `$40-$58` | start a sound-effect sequence | SfxSequencePointers `06:4128`, 25 words |
| `$80-$89` | start a music sequence | MusicPointers `06:4744`, 10 x 4 bytes |

Id `$00` cannot be queued (section 3.4). Ids that are used as immediates in
source: `$04 $05 $07 $0A $0B $10 $14 $1B $1E $21 $22 $24`, `$44-$58`
(not all), `$80 $82 $83 $87 $88`; `$81-$86` are also chosen at random
(ROM0 `$0236` and `$3AF3`).

Bank `$05` is not audio. Bank `$07` holds an unreferenced partial copy of
the bank-`$06` data (section 6).

## 2. ROM map of bank `$06`

Every range is proven by the routine that reads it; sizes are proven by
adjacency and by parsing every sequence to its terminator.

| Range | Size | Contents | Read by (evidence) |
| --- | --- | --- | --- |
| `4000-4127` | 37 x 8 | SoundPatches | `7E49`/`7F3D`: `ld hl,$4000`, `id*8` |
| `4128-4159` | 25 x 2 | SfxSequencePointers | `7EE6`: `ld hl,$4128`, `(id&$3F)*2` |
| `415A-415B` | 2 | `SfxSequencePointerTablePadding`; `$0000` would be id `$59`, no caller | adjacency and zero readers |
| `415C-4648` | `$4ED` | 24 distinct sfx sequences (ids `$40` and `$4B` share `$43EB`) | parsed to `$FF` |
| `4649-465F` | 23 | AudioRegisterInit -> `$FF10-$FF26` | `7CFD`: `ld hl,$4649`, `d=$17` |
| `4660-4661` | 2 | `AudioRegisterInitPadding` | exact 23-byte register-copy count and zero readers |
| `4662-4715` | 90 x 2 | NoteFrequencies (C2-F9 chromatic register values) | `7DDA`, `7FA4`: `ld hl,$4662`, `note*2`; exact formula checked |
| `4716-4725` | 16 | WaveformPattern -> `$FF30-$FF3F` | `7CEC`: `ld bc,$4716`, `d=$10` |
| `4726-4737` | 9 x 2 | NoiseNoteTable (channel-4 notes `$0C-$14`) | `7D96`: `ld hl,$4726` |
| `4738-473F` | 4 x 2 | ChannelRegisterBases `$FF10,$FF16,$FF1A,$FF20` | `7DB5`, `7E70`, `7F63` |
| `4740-4743` | 4 | `ChannelRegisterBasesPadding` | exact four-entry index bound and zero readers |
| `4744-476B` | 10 x 4 | MusicPointers | `7E9F`: `ld hl,$4744`, `(id&$7F)*4` |
| `476C-476D` | 2 | `MusicPointerTablePadding` | exact ten-entry index bound and zero readers |
| `476E-4799` | 11 x 4 | Instruments | `7DAE`: `ld hl,$476E`, `instrument*4` |
| `479A-7CAD` | `$3514` | 10 music sequences | parsed to `$FE`/`$FF` terminators |
| `7CAE-7FD1` | `$324` | driver code | traced |
| `7FD2-7FFE` | `$2D` | zero fill | — |
| `7FFF` | 1 | bank marker `$06` | `ROM_BANK_MARKER` |

The instrument count (11) is bounded by `$4799`/`$479A` (the first music
sequence) and is consistent with uses: music start assigns defaults 0-3 to
channels 1-4, every explicit `music_instrument` event selects instrument 5
for channel 2, and NoiseNoteTable selects 8-10 for channel 4. Every channel-4
note in the ROM is in the NoiseNoteTable range, so default instrument 3 is
assigned but never reaches the register-write path. Instruments 4, 6 and 7
have no static reference. These facts are checked mechanically.

## 3. Code

### 3.1 ROM0 routines

| Address | Name | Evidence |
| --- | --- | --- |
| `$2EB8` | Audio_InitFar | saves the bank marker, maps `$06`, calls `06:7CAE`, sets `$C8E6` to 1 if it was 0, restores the bank. Called once, from Init (`$0159`). The `$C8E6` side effect is not audio-specific (bank `02:626D` writes 2 there) and stays unnamed. |
| `$2ED5` | Music_Update | returns if `wMusicPtr` high byte or `wMusicEnabled` is 0; decrements `wMusicDelay`; at 1, maps `wMusicBank`, reads 3 bytes, maps `$06`, calls Music_HandleEvent, repeats while the new delay is 0. |
| `$2F21` | Audio_Update | decrements `wNoiseLockTimer`, maps `$06`, calls SfxSequence_Update and Music_Update, then drains the queue from `wSoundQueueNext` through Audio_PlaySound, clearing each slot. Restores the caller's bank. |
| `$2F73` | Audio_QueueSound | `e` = id. Advances `wSoundQueueLast` modulo 30 and stores `e` there. |

### 3.2 Bank `$06` routines

| Address | Name | Evidence |
| --- | --- | --- |
| `$7CAE` | Audio_Init | clears driver state; queue indices last=0, next=1; `wSfxSeqDelay`=1; `wMusicEnabled`=1; channel settings `(n, $11)` for n=0-3; wave RAM from `$4716`; `$FF10-$FF26` from `$4649`; zeroes the queue. |
| `$7D11` | Music_HandleEvent | `b`,`c` = first two event bytes (format 5.3). |
| `$7E41` | Audio_PlaySound | `a` = id. Bit 7: start music. Bit 6: start a sound-effect sequence. Else: start patch. |
| `$7EFD` | SfxSequence_Update | per-frame step of the active sound-effect sequence (format 5.2). |

### 3.3 Bank switching

Only `rROMB0` (`$2000`) is written. Audio_InitFar and Audio_Update save
`[$7FFF]` (the current bank's marker), select `$06`, and restore on exit.
Music_Update selects `wMusicBank` only for its 3-byte read and then
reselects `$06`. `wMusicBank` comes from byte 2 of the MusicPointers entry;
all ten entries hold `$06`, so in this ROM every audio access is to bank
`$06`.

### 3.4 Observed defects (kept unchanged)

- Audio_QueueSound with `e = 0` executes `ret z` after four pushes, so it
  returns to the saved `hl` value. No immediate caller passes 0.
- After each dequeued id, Audio_Update copies the read index into
  `wSoundQueueLast` before advancing `wSoundQueueNext`.
- In Music_HandleEvent channel 2 note-ons, instrument byte 2 is written to
  NR23 and then overwritten by the frequency low byte (channel 2's register
  base is NR21, one register later than channel 1's NR10).

## 4. Callers and timing

Audio_Update is called from 30 sites, all in polled loops after `halt` /
`wVBlankPending`, or an `rLY` wait: ROM0 `$009F`, `$0701`, `$3989`, `$3B84`;
bank `$01`: `40B4`, `47CE`, `5144`, `60D2`, `610A`, `6180`, `61DC`, `7997`,
`7C52`; bank `$02`: `476B`, `5C56`, `5CB9`, `5D06`, `630E` (2x); banks
`$2A`-`$2E` screen update loops (10 sites); and the RAM routine at
`$D6C7` in the image copied from `01:4A6D` to `$D62A` (ROM source of that
instruction stream: `01:4B0A`).

The interrupt vectors do not reach the driver: `$0050` (timer) is `reti`,
and no installed VBlank/LCD handler image calls it.

`01:409E` clears `wSfxSeqPtr`, writes 0 to NR51, then calls Audio_Update
once per frame (`rLY = $14`) until `wMusicPtr` is clear or music is
disabled. It is left unnamed because it also calls `$2FF9`, whose purpose
is not established.

`01:4E35` copies `wMusicSetting` to `wMusicEnabled` and writes 0 to NR51
when music is disabled. ROM0 `$3CFB` sets `wSfxSeqLockId = $4F` and queues
`$4F`. Other direct NR51 writes: `01:4000`, ROM0 `$0127` (Init, before
Audio_InitFar).

## 5. Data formats

### 5.1 Sound patch (8 bytes)

| Offset | Meaning |
| --- | --- |
| +0 | channel (1, 2 or 4 used) |
| +1.. | register bytes for `ChannelRegisterBases[ch-1]`: 5 if bit 0 of channel is set, else 4; bit 7 is forced on the last (trigger) |
| next | NR51 bits ORed in (always `$11 << (ch-1)`) |
| rest | not read; all zero except patch `$00`, which has `22 00` |

Channel 4 patches also set `wNoiseLockTimer = $37`; channel 1 patches
write 1 to `wUnusedChannel1PatchFlag`, which nothing reads.
The source uses channel-specific macros for all 36 ordinary records, exposing
their NR10-NR14 or NR41-NR44 fields. Patch 0 remains split at byte 6 so its
two unread tail bytes retain their own label.

### 5.2 Sound-effect sequence

| Event | Bytes | Behavior |
| --- | --- | --- |
| `$FF` | 1 | end: pointer cleared, `wSfxSeqLock` cleared |
| op, bit0=1, `op&$F0=$20` | op, note, delay | channel 1 tone: NR10=$86, NR11=$40, NR12=$F7, NR13/14 from NoteFrequencies |
| op, bit0=1, other | op, patch, delay | start patch |
| op, bit0=0, bit6=1 | op, delay | NR51 &= `$77`, `wNoiseLockTimer` = 0 |
| op, bit0=0, bit6=0 | op, delay | NR51 &= `$EE` |

Delay 0 runs the next event in the same frame. Op values present: `$11`,
`$21`, `$00`, `$06`, `$12`, `$22`, `$42`; their other bits are not read and
have no run-time effect. They remain raw macro arguments to preserve the
original bytes. Each sequence is followed by `FF 00 FF FF`
(`$42E6`: `FF 00 FF FF 00 00`), which the driver never reaches.

Ids `$40-$7F` are ignored while `wSfxSeqLock` is set. Starting the id in
`wSfxSeqLockId` sets the lock and clears `wSfxSeqLockId`.

### 5.3 Music sequence

| Event | Bytes | Behavior |
| --- | --- | --- |
| `ch<<4 \| 1` | 3: note, delay | note on (ignored while `wMusicNoteOnBlocked` is non-zero) |
| `ch<<4 \| 2` | 2: delay | note off: clears the channel's NR51 bits (channel 4 skipped while the noise lock is active) |
| `ch<<4 \| 3` | 3: instrument, delay | select instrument |
| `ch<<4 \| 4` | 3: bits, delay | set the NR51 bit pattern, shifted by `ch-1` at note-on |
| `$FE`, c < `$F0` | 3: id, delay | queue sound id c (not present in this ROM) |
| `$FE`, c >= `$F0` | 3: delay after jump | loop to `wMusicLoopPtr` |
| other >= `$8F` | 2 (+1 byte read, unused) | stop: pointer cleared, NR51 = 0 |

Channel 4 notes `$0C-$14` take their instrument and NR51 bits from
NoiseNoteTable; channel 4 writes no frequency. Channel 4 note-ons are
dropped while `wNoiseLockTimer` is non-zero and NR52 reports channel 4 on.
Music `$00` is only `FF FF` (stop). Music `$07` ends with stop; the others
loop. Each sequence is followed by `FE FF` (`$07`: `00 FF FF`), never read.

### 5.4 Music pointer entry (4 bytes)

`dw sequence` (also stored as the loop target), `db bank`, `db $00`
(byte 3 is not read).

## 6. Bank classification

| Bank / range | Classification | Evidence |
| --- | --- | --- |
| `06:4000-7CAD` | audio data | all read by the driver (section 2) |
| `06:7CAE-7FD1` | audio code | traced from Audio_InitFar / Audio_Update |
| ROM0 `$2EB8-$2F92` | audio code | as above |
| `$05` | not audio | starts with sprite-layout records (`Y, X, tile, attr`); `05:4088` loads level parameters from `$5120`/`$513E` into `$C8CE-$C8D2`; no audio routine selects bank `$05` |
| `$07` | explicit unused partial copy of bank `$06` data, no audio reference | `07:4000-4007` occupies sound-patch slot 0, but channel `$0C` is invalid for the driver (valid 1-4), so it is a malformed build leftover. Patch slot 1 onward, `07:4008-4BFB`, equals `06:4008-4BFB`; the rest is explicit zero fill up to marker `$07`. The copied residue remains a narrowly typed binary source asset. No `$07` immediate reaches `rROMB0`, and `wMusicBank` is always `$06`. Computed bank selections elsewhere are listed in section 7. |

## 7. Unresolved

1. `wMusicNoteOnBlocked` is initialized to zero and checked before music
   note-ons, but nothing in traced code sets it nonzero.
2. `wUnusedAudioStateC8E4` is initialized to zero and never read;
   `wUnusedChannel1PatchFlag` is set by channel-1 patches and never read.
3. The fixed padding and reserved fields are structurally bounded but their
   build-time purpose is unknown: `SoundPatch00UnreadTail`, the four named
   table-padding ranges, music-pointer byte 3, and sequence trailers.
4. Instruments 4, 6, 7 and music id `$89` (`Music_09`) have no static
   reference; channel 4's assigned default instrument 3 is always replaced
   by NoiseNoteTable before use. Dynamic id sources (ROM0 `$1042` uses `b` in {4, 5, `$1B`};
   random `$81-$86`) were inspected; others may exist in untraced code.
5. Track titles are not assigned. The frequency-table pitches are proven:
   index 0 is C2 and each following index advances one equal-tempered
   semitone through F9. Every value exactly equals
   `floor(2048 - 131072 / frequency)` with A4 = 440 Hz. That names the
   sounding pitches on square channels 1-2; the wave channel uses half their
   clock and sounds the same indexes one octave lower. Channel 4 does not use
   this table: note values `$0C-$14` select NoiseNoteTable entries.
6. Hardware behavior was not checked on a physical Game Boy Color.

## 8. Bank `$07` follow-up

A separate read-only audit traced every computed `rROMB0` write. Items
marked "checked" were re-verified against the ROM for this report.

| Site (bank `$00` unless noted) | Value source | Possible banks |
| --- | --- | --- |
| `bank_00.asm:1050` | `ld b,$3B` before the loop | `$3B` |
| `:2560` | `[$FF80] + $27` | `$27-$29`; the type-1 field is 0-3 and value 3 skips the copy (checked) |
| `:4617-5480` (`$C8B9-$C8BC`) | 18-byte record copied by `$188B` via bank-`$05` pointer table `$4300` (15 records `$4400-$4518`, stride `$14`) | `$09-$26` (checked) |
| `:5241` (`$C8D2`) | bank `$05` table `$513E`, byte +2 | 9, 11, ..., 37 (checked) |
| `:8484` (`wMusicBank`) | MusicPointers byte 2; only writer `06:7EB8` (checked) | 6 for ids `$80-$89`; indexes 15 and 26 past the table would give 7 (ids `$8F`, `$9A`), and no traced caller passes them |
| `:10497`, `:10532` | ScreenModeTable bank byte | `$2A-$2D` |
| `:10654` | caller's `[ROM_BANK_MARKER]` (11 calls) or `[$DBFB]` | caller banks; see next row |
| `bank_01` `3008`, `3110`, `3214`; `bank_00` `10981` | `$DBFB` / `$C943` from bank `$01:$596D` | `$2E` for the three-entry selector, bounded 0-2 (checked) |
| `bank_01` `3813` | bank `$01:$59AB` fixed-scene table | `$30-$33` (checked) |
| `bank_01` `4018`, `4569`, `4725` | `$FF92` from bank `$01:$5A60` scrolling-scene table | `$2F`, `$30`, `$34-$3B` (checked) |

No other write to `$2000-$3FFF` was found. The audit also claimed a second
`wMusicBank` writer in `01:7C3F`; that is wrong (that routine writes no
audio state), and the claim is not used.

All 57 machine-code calls to `Audio_QueueSound` are now inventoried. Fifty
have an adjacent immediate id. The other seven are:

- three random selectors bounded to `$81-$86` (ROM0 `$0242`, `$3AFF`, and
  bank `$01:$5333`);
- ROM0 `$1043`, bounded to `$04`, `$05`, or `$1B`;
- ROM0 `$3D68`, fixed through `a` at `$4F`;
- bank `$01:$6947`, which reuses the input byte only after bits 7-4 have
  branched elsewhere, so the two callers can pass only `$04-$0F`;
- bank `$06:$7D2A`, reachable only from a music `$FE` queue event; none of
  the ten parsed music sequences contains that event.

The call-site set and each bound are checked against the ROM. Consequently
the only music ids are `$80-$89`, every MusicPointers entry names bank `$06`,
and `wMusicBank` is always 6. Together with the now-bounded object, level,
screen and scene selectors, no directly traced program path selects bank
`$07`; it is classified as unused build residue rather than an open selector
risk. This does not make its duplicated bytes semantically meaningful.
