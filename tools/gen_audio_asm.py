#!/usr/bin/env python3
"""Print RGBDS source for sound-driver data at bank $06:$4000-$7CAD.

Used once to replace the opaque assets/bank_06/4000.bin inclusion; the output
lives in src/audio_data.asm and is now the source of truth. Running this again
only serves as a cross-check: `make compare` proves the bytes either way.
"""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from audio import *

rom = open(sys.argv[1], 'rb').read()
out = []
w = out.append
h = lambda bs: ", ".join(f"${x:02X}" for x in bs)


def raw(addr, end, note):
    if end > addr:
        w(f"\tdb {h(b6(rom, addr, end - addr))} ; {note}\n")


w("; Sound-driver data, ROM bank $06:$4000-$7CAD. Generated once by\n"
  "; tools/gen_audio_asm.py, then maintained by hand. See AUDIO_RESEARCH.md.\n\n")

w("; 37 x 8 bytes, indexed by sound ids $00-$3F (Audio_PlaySound) and by\n"
  "; sfx_patch events. +0 channel (1-4); then 5 register bytes for odd\n"
  "; channels or 4 for even, written from ChannelRegisterBases[channel-1]\n"
  "; with bit 7 forced on the last; then the NR51 bits to set; rest unread.\n")
w("SoundPatches:\n")
for i in range(PATCH_COUNT):
    r = b6(rom, PATCHES + 8 * i, 8)
    n = 5 if r[0] & 1 else 4
    w(f"\tdb {r[0]}, {h(r[1:1+n])}, ${r[1+n]:02X}, {h(r[2+n:])} ; ${i:02X}\n")

w("\n; Indexed by (sound id & $3F) for ids $40-$7F. Ids $40-$58 are used.\n")
w("SfxSequencePointers:\n")
ptrs = sfx_seq_pointers(rom)
names = {}
for i, p in enumerate(ptrs):
    names.setdefault(p, f"SfxSequence_{i:02X}")
for i, p in enumerate(ptrs):
    w(f"\tdw {names[p]} ; ${0x40 + i:02X}\n")
w(f"\tdw ${word(rom, SFX_SEQ_PTRS + 2 * SFX_SEQ_COUNT):04X} ; $59: null word, no caller found\n")

order = sorted(set(ptrs))
for k, p in enumerate(order):
    nxt = order[k + 1] if k + 1 < len(order) else SFX_SEQ_END
    ev, end = parse_sfx_seq(rom, p)
    w(f"\n{names[p]}:\n")
    for e in ev:
        if e[0] == "end": w("\tsfx_end\n")
        elif e[0] == "patch": w(f"\tsfx_patch ${e[1]:02X}, ${e[2]:02X}, {e[3]}\n")
        elif e[0] == "tone": w(f"\tsfx_tone ${e[1]:02X}, {e[2]}, {e[3]}\n")
        elif e[0] == "mute1": w(f"\tsfx_mute_ch1 ${e[1]:02X}, {e[2]}\n")
        else: w(f"\tsfx_mute_ch4 ${e[1]:02X}, {e[2]}\n")
    raw(end, nxt, "not reached by SfxSequence_Update")

w("\n; Copied to rNR10-rNR52 ($FF10-$FF26) by Audio_Init.\n")
w(f"AudioRegisterInit:\n\tdb {h(b6(rom, REG_INIT, 12))}\n\tdb {h(b6(rom, REG_INIT + 12, REG_INIT_SIZE - 12))}\n")
raw(REG_INIT + REG_INIT_SIZE, NOTE_FREQS, "no reference found")

w("\n; 90 little-endian 11-bit channel frequency values, indexed by note.\n")
w("NoteFrequencies:\n")
for i in range(0, NOTE_COUNT, 8):
    vals = [word(rom, NOTE_FREQS + 2 * j) for j in range(i, min(NOTE_COUNT, i + 8))]
    w("\tdw " + ", ".join(f"${v:04X}" for v in vals) + f" ; notes {i}-{i + len(vals) - 1}\n")

w("\n; Copied to wave RAM ($FF30-$FF3F) by Audio_Init.\n")
w(f"WaveformPattern:\n\tdb {h(b6(rom, WAVE, WAVE_SIZE))}\n")

w("\n; Music notes $0C-$14 on channel 4 use these pairs instead of the\n"
  "; channel's instrument: +0 NR51 bit pattern, +1 instrument index.\n")
w("NoiseNoteTable:\n")
for i in range(NOISE_NOTE_COUNT):
    r = b6(rom, NOISE_NOTES + 2 * i, 2)
    w(f"\tdb ${r[0]:02X}, {r[1]} ; note ${0x0C + i:02X}\n")

w("\n; First sound register of channels 1-4.\n")
w("ChannelRegisterBases:\n\tdw rNR10, rNR21, rNR30, rNR41\n")
raw(CHANNEL_REGS + 8, MUSIC_PTRS, "no reference found")

w("\n; Indexed by (sound id & $7F) for ids $80-$FF. +0 dw sequence (also the\n"
  "; loop target), +2 ROM bank of the sequence, +3 not read. Ids $80-$88 used.\n")
w("MusicPointers:\n")
for i, (p, bank, unk) in enumerate(music_pointers(rom)):
    w(f"\tdw Music_{i:02X}\n\tdb BANK(Music_{i:02X}), ${unk:02X}\n")
raw(MUSIC_PTRS + 4 * MUSIC_COUNT, INSTRUMENTS, "no reference found")

w("\n; 11 x 4 bytes, selected per channel by music_instrument (and channel\n"
  "; defaults 0-3, NoiseNoteTable 8-10). +0..+2 are written to the channel's\n"
  "; first three registers; +3 is ORed into the trigger register with bit 7.\n")
w("Instruments:\n")
for i in range(INSTRUMENT_COUNT):
    w(f"\tdb {h(b6(rom, INSTRUMENTS + 4 * i, 4))} ; {i}\n")

mp = music_pointers(rom)
for i, (p, bank, unk) in enumerate(mp):
    nxt = mp[i + 1][0] if i + 1 < len(mp) else MUSIC_END
    ev, end = parse_music(rom, p)
    w(f"\nMusic_{i:02X}:\n")
    for e in ev:
        k = e[0]
        if k == "note": w(f"\tmusic_note {e[1] >> 4}, {e[2]}, {e[3]}\n")
        elif k == "off": w(f"\tmusic_off {e[1] >> 4}, {e[2]}\n")
        elif k == "instrument": w(f"\tmusic_instrument {e[1] >> 4}, {e[2]}, {e[3]}\n")
        elif k == "pan": w(f"\tmusic_pan {e[1] >> 4}, ${e[2]:02X}, {e[3]}\n")
        elif k == "loop": w(f"\tmusic_loop ${e[2]:02X}, {e[3]}\n")
        elif k == "stop": w(f"\tmusic_stop ${e[1]:02X}, ${e[2]:02X}\n")
        else: raise SystemExit(f"unexpected music event {e}")
    raw(end, nxt, "not reached by Music_HandleEvent")
sys.stdout.write("".join(out))
