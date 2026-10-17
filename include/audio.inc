; Sound-driver data macros (bank $06). Formats come from the driver routines
; Audio_PlaySound ($06:$7E41), SfxSequence_Update ($06:$7EFD) and
; Music_HandleEvent ($06:$7D11); see AUDIO_RESEARCH.md. Command bytes whose
; other bits are not interpreted by the driver are kept as raw arguments.

DEF INSTRUMENT_CH1_DEFAULT     EQU 0
DEF INSTRUMENT_CH2_DEFAULT     EQU 1
DEF INSTRUMENT_CH3_DEFAULT     EQU 2
DEF INSTRUMENT_CH4_DEFAULT     EQU 3
DEF INSTRUMENT_CH2_ALTERNATE   EQU 5
DEF INSTRUMENT_NOISE_1         EQU 8
DEF INSTRUMENT_NOISE_2         EQU 9
DEF INSTRUMENT_NOISE_3         EQU 10

; Fixed 8-byte SoundPatches records. Odd channels carry five consecutive
; register values; even channels carry four. The driver forces trigger bit 7
; in the last channel register, then ORs the NR51 routing byte into NR51.
MACRO sound_patch_ch1 ; NR10, NR11, NR12, NR13, NR14, NR51, unread
	db 1, \1, \2, \3, \4, \5, \6, \7
ENDM
MACRO sound_patch_ch2 ; NR21, NR22, NR23, NR24, NR51, unread x2
	db 2, \1, \2, \3, \4, \5, \6, \7
ENDM
MACRO sound_patch_ch4 ; NR41, NR42, NR43, NR44, NR51, unread x2
	db 4, \1, \2, \3, \4, \5, \6, \7
ENDM

; Four-byte Instruments records. The first three values are written to the
; named channel registers and the last is ORed into the trigger register.
MACRO instrument_ch1 ; NR10, NR11, NR12, NR14 bits
	db \1, \2, \3, \4
ENDM
MACRO instrument_ch2 ; NR21, NR22, initial NR23, NR24 bits
	; Music_HandleEvent replaces the initial NR23 byte with the note low byte.
	db \1, \2, \3, \4
ENDM
MACRO instrument_ch3 ; NR30, NR31, NR32, NR34 bits
	db \1, \2, \3, \4
ENDM
MACRO instrument_ch4 ; NR41, NR42, NR43, NR44 bits
	db \1, \2, \3, \4
ENDM
MACRO instrument_unreferenced ; four preserved bytes, channel interpretation unknown
	db \1, \2, \3, \4
ENDM

; Sound-effect sequence events -------------------------------------------
; $11 has bit 0 set and a non-$20 high nibble: start sound patch, then wait.
MACRO sfx_patch ; patch id, delay frames
	db $11, \1, \2
ENDM
; $21 selects a channel 1 tone at NoteFrequencies[note].
MACRO sfx_tone ; note, delay frames
	db $21, \1, \2
ENDM
; op has bit 0 clear, bit 6 clear: NR51 &= $EE (channel 1 off).
MACRO sfx_mute_ch1 ; op, delay frames
	db \1, \2
ENDM
; $42 has bit 0 clear and bit 6 set: channel 4 off, noise lock cleared.
MACRO sfx_mute_ch4 ; delay frames
	db $42, \1
ENDM
MACRO sfx_end
	db $FF
ENDM

; Music sequence events: high nibble = channel 1-4, low nibble = command ---
MACRO music_note ; channel, note, delay frames
	db (\1 << 4) | 1, \2, \3
ENDM
MACRO music_off ; channel, delay frames
	db (\1 << 4) | 2, \2
ENDM
MACRO music_instrument ; channel, instrument, delay frames
	db (\1 << 4) | 3, \2, \3
ENDM
MACRO music_pan ; channel, NR51 bit pattern (before channel shift), delay frames
	db (\1 << 4) | 4, \2, \3
ENDM
; $FE with argument >= $F0: restart at the song's loop pointer.
MACRO music_loop ; argument, delay frames after the jump
	db $FE, \1, \2
ENDM
; Any first byte >= $8F other than $FE: stop music.
MACRO music_stop ; command byte, argument
	db \1, \2
ENDM
