; Sound-driver data macros (bank $06). Formats come from the driver routines
; Audio_PlaySound ($06:$7E41), SfxSequence_Update ($06:$7EFD) and
; Music_HandleEvent ($06:$7D11); see AUDIO_RESEARCH.md. Command bytes whose
; other bits are not interpreted by the driver are kept as raw arguments.

; Sound-effect sequence events -------------------------------------------
; op has bit 0 set and (op & $F0) != $20: start sound patch, then wait.
MACRO sfx_patch ; op, patch id, delay frames
	db \1, \2, \3
ENDM
; op has bit 0 set and (op & $F0) == $20: channel 1 tone at NoteFrequencies[note].
MACRO sfx_tone ; op, note, delay frames
	db \1, \2, \3
ENDM
; op has bit 0 clear, bit 6 clear: NR51 &= $EE (channel 1 off).
MACRO sfx_mute_ch1 ; op, delay frames
	db \1, \2
ENDM
; op has bit 0 clear, bit 6 set: NR51 &= $77 (channel 4 off), noise lock cleared.
MACRO sfx_mute_ch4 ; op, delay frames
	db \1, \2
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
