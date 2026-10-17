; Sound-driver data, ROM bank $06:$4000-$7CAD. Generated once by
; tools/gen_audio_asm.py, then maintained by hand. See AUDIO_RESEARCH.md.

; 37 x 8 bytes, indexed by sound ids $00-$3F (Audio_PlaySound) and by
; sfx_patch events. +0 channel (1-4); then 5 register bytes for odd
; channels or 4 for even, written from ChannelRegisterBases[channel-1]
; with bit 7 forced on the last; then the NR51 bits to set; rest unread.
SoundPatches:
	db 2, $86, $F0, $00, $03, $22 ; $00: channel, four registers, NR51
SoundPatch00UnreadTail:
	db $22, $00 ; fixed record tail, never read
	sound_patch_ch1 $77, $87, $F7, $82, $47, $11, $00 ; $01
	sound_patch_ch1 $2C, $84, $F7, $82, $47, $11, $00 ; $02
	sound_patch_ch1 $25, $41, $F2, $A8, $01, $11, $00 ; $03
	sound_patch_ch1 $1E, $42, $F2, $73, $06, $11, $00 ; $04
	sound_patch_ch1 $76, $81, $F4, $E4, $05, $11, $00 ; $05
	sound_patch_ch1 $73, $C2, $F5, $FC, $01, $11, $00 ; $06
	sound_patch_ch1 $65, $01, $F7, $A8, $06, $11, $00 ; $07
	sound_patch_ch1 $27, $41, $F1, $A8, $01, $11, $00 ; $08
	sound_patch_ch1 $6A, $C1, $F2, $DF, $02, $11, $00 ; $09
	sound_patch_ch4 $00, $F1, $2A, $40, $88, $00, $00 ; $0A
	sound_patch_ch4 $00, $F1, $2F, $40, $88, $00, $00 ; $0B
	sound_patch_ch1 $1B, $81, $F2, $8D, $05, $11, $00 ; $0C
	sound_patch_ch1 $13, $41, $F1, $A8, $01, $11, $00 ; $0D
	sound_patch_ch1 $23, $41, $F1, $A8, $01, $11, $00 ; $0E
	sound_patch_ch1 $2F, $C8, $F1, $DF, $02, $11, $00 ; $0F
	sound_patch_ch4 $06, $F5, $54, $00, $88, $00, $00 ; $10
	sound_patch_ch4 $06, $F5, $72, $00, $88, $00, $00 ; $11
	sound_patch_ch4 $09, $F5, $57, $00, $88, $00, $00 ; $12
	sound_patch_ch4 $09, $F5, $62, $00, $88, $00, $00 ; $13
	sound_patch_ch4 $18, $F3, $64, $00, $88, $00, $00 ; $14
	sound_patch_ch4 $00, $F7, $22, $00, $88, $00, $00 ; $15
	sound_patch_ch4 $04, $FF, $63, $40, $88, $00, $00 ; $16
	sound_patch_ch4 $06, $F4, $70, $00, $88, $00, $00 ; $17
	sound_patch_ch4 $00, $F7, $70, $00, $88, $00, $00 ; $18
	sound_patch_ch4 $36, $F1, $00, $40, $88, $00, $00 ; $19
	sound_patch_ch4 $3A, $F1, $11, $40, $88, $00, $00 ; $1A
	sound_patch_ch1 $5D, $41, $F7, $16, $07, $11, $00 ; $1B
	sound_patch_ch1 $9C, $41, $F6, $56, $07, $11, $00 ; $1C
	sound_patch_ch1 $A7, $51, $F6, $26, $07, $11, $00 ; $1D
	sound_patch_ch4 $00, $F1, $2C, $00, $88, $00, $00 ; $1E
	sound_patch_ch4 $00, $F1, $12, $00, $88, $00, $00 ; $1F
	sound_patch_ch1 $27, $42, $F7, $26, $07, $11, $00 ; $20
	sound_patch_ch4 $00, $F5, $34, $00, $88, $00, $00 ; $21
	sound_patch_ch4 $00, $F5, $36, $00, $88, $00, $00 ; $22
	sound_patch_ch4 $00, $00, $70, $40, $88, $00, $00 ; $23
	sound_patch_ch4 $3A, $31, $11, $40, $88, $00, $00 ; $24

; Indexed by (sound id & $3F) for ids $40-$7F. Ids $40-$58 are used.
SfxSequencePointers:
	dw SfxSequence_00 ; $40
	dw SfxSequence_01 ; $41
	dw SfxSequence_02 ; $42
	dw SfxSequence_03 ; $43
	dw SfxSequence_04 ; $44
	dw SfxSequence_05 ; $45
	dw SfxSequence_06 ; $46
	dw SfxSequence_07 ; $47
	dw SfxSequence_08 ; $48
	dw SfxSequence_09 ; $49
	dw SfxSequence_0A ; $4A
	dw SfxSequence_00 ; $4B
	dw SfxSequence_0C ; $4C
	dw SfxSequence_0D ; $4D
	dw SfxSequence_0E ; $4E
	dw SfxSequence_0F ; $4F
	dw SfxSequence_10 ; $50
	dw SfxSequence_11 ; $51
	dw SfxSequence_12 ; $52
	dw SfxSequence_13 ; $53
	dw SfxSequence_14 ; $54
	dw SfxSequence_15 ; $55
	dw SfxSequence_16 ; $56
	dw SfxSequence_17 ; $57
	dw SfxSequence_18 ; $58
SfxSequencePointerTablePadding:
	dw $0000 ; would be id $59; no caller and not part of the 25-entry table

SfxSequence_18:
	sfx_patch $1A, 6
	sfx_mute_ch1 $22, 1
	sfx_mute_ch4 3
	sfx_patch $1A, 4
	sfx_mute_ch4 0
	sfx_patch $1A, 3
	sfx_mute_ch4 0
	sfx_patch $1A, 4
	sfx_mute_ch4 0
	sfx_patch $1A, 3
	sfx_mute_ch4 7
	sfx_patch $1A, 7
	sfx_mute_ch4 4
	sfx_patch $1A, 7
	sfx_mute_ch4 3
	sfx_patch $1A, 4
	sfx_mute_ch4 0
	sfx_patch $1A, 3
	sfx_mute_ch4 0
	sfx_patch $1A, 4
	sfx_mute_ch4 0
	sfx_patch $1A, 3
	sfx_mute_ch4 7
	sfx_patch $1A, 7
	sfx_mute_ch4 4
	sfx_patch $1A, 7
	sfx_mute_ch4 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_17:
	sfx_patch $17, 54
	sfx_patch $23, 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_10:
	sfx_tone 41, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 44, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 47, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 43, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 47, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 48, 4
	sfx_mute_ch1 $22, 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_11:
	sfx_tone 48, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 47, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 43, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 48, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 47, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 43, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 48, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 47, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 43, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 47, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 48, 8
	sfx_mute_ch1 $22, 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_12:
	sfx_tone 41, 8
	sfx_mute_ch1 $22, 0
	sfx_tone 44, 8
	sfx_mute_ch1 $22, 0
	sfx_tone 49, 8
	sfx_mute_ch1 $22, 0
	sfx_tone 48, 8
	sfx_mute_ch1 $22, 0
	sfx_tone 43, 8
	sfx_mute_ch1 $22, 0
	sfx_tone 47, 8
	sfx_mute_ch1 $22, 0
	sfx_tone 43, 8
	sfx_mute_ch1 $22, 0
	sfx_tone 47, 8
	sfx_mute_ch1 $22, 0
	sfx_tone 48, 8
	sfx_mute_ch1 $22, 0
	sfx_tone 41, 8
	sfx_mute_ch1 $22, 0
	sfx_tone 44, 8
	sfx_mute_ch1 $22, 0
	sfx_tone 49, 8
	sfx_mute_ch1 $22, 0
	sfx_tone 48, 8
	sfx_mute_ch1 $22, 0
	sfx_tone 43, 8
	sfx_mute_ch1 $22, 0
	sfx_tone 47, 8
	sfx_mute_ch1 $22, 0
	sfx_tone 43, 8
	sfx_mute_ch1 $22, 0
	sfx_tone 47, 8
	sfx_mute_ch1 $22, 0
	sfx_tone 48, 8
	sfx_mute_ch1 $22, 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_13:
	sfx_tone 36, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 39, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 43, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 38, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 42, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 45, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 39, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 36, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 38, 4
	sfx_mute_ch1 $22, 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_14:
	sfx_tone 36, 3
	sfx_mute_ch1 $22, 0
	sfx_tone 40, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 43, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 50, 3
	sfx_mute_ch1 $22, 0
	sfx_tone 47, 4
	sfx_mute_ch1 $22, 4
	sfx_tone 48, 4
	sfx_mute_ch1 $22, 3
	sfx_tone 47, 4
	sfx_mute_ch1 $22, 4
	sfx_tone 43, 4
	sfx_mute_ch1 $22, 3
	sfx_tone 40, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 41, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 43, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 45, 3
	sfx_mute_ch1 $22, 0
	sfx_tone 47, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 48, 4
	sfx_mute_ch1 $22, 0
	sfx_end
	db $FF, $00, $FF, $FF, $00, $00 ; not reached by SfxSequence_Update

SfxSequence_0E:
	sfx_patch $1A, 0
	sfx_tone 36, 13
	sfx_mute_ch1 $22, 2
	sfx_mute_ch4 7
	sfx_patch $1A, 0
	sfx_tone 40, 8
	sfx_mute_ch4 0
	sfx_patch $1A, 3
	sfx_mute_ch1 $22, 4
	sfx_mute_ch4 0
	sfx_patch $1A, 8
	sfx_mute_ch4 0
	sfx_patch $1A, 0
	sfx_tone 43, 7
	sfx_mute_ch4 1
	sfx_mute_ch1 $22, 14
	sfx_patch $1A, 0
	sfx_tone 46, 8
	sfx_mute_ch1 $22, 0
	sfx_tone 46, 7
	sfx_mute_ch4 0
	sfx_mute_ch1 $22, 0
	sfx_tone 46, 8
	sfx_patch $1A, 0
	sfx_mute_ch1 $22, 0
	sfx_tone 48, 15
	sfx_mute_ch4 7
	sfx_patch $1A, 8
	sfx_mute_ch4 0
	sfx_patch $1A, 3
	sfx_mute_ch1 $22, 4
	sfx_mute_ch4 0
	sfx_patch $1A, 8
	sfx_mute_ch4 0
	sfx_patch $1A, 7
	sfx_mute_ch4 15
	sfx_patch $1A, 15
	sfx_mute_ch4 8
	sfx_patch $1A, 15
	sfx_mute_ch4 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_0D:
	sfx_patch $09, 0
	sfx_patch $1A, 5
	sfx_mute_ch1 $12, 0
	sfx_patch $09, 6
	sfx_mute_ch1 $12, 0
	sfx_patch $09, 4
	sfx_mute_ch4 1
	sfx_mute_ch1 $12, 0
	sfx_patch $09, 6
	sfx_patch $09, 0
	sfx_patch $1A, 6
	sfx_mute_ch1 $12, 2
	sfx_mute_ch4 0
	sfx_patch $1A, 3
	sfx_mute_ch1 $12, 0
	sfx_patch $09, 4
	sfx_mute_ch4 0
	sfx_patch $1A, 2
	sfx_mute_ch1 $12, 0
	sfx_patch $09, 6
	sfx_mute_ch1 $12, 0
	sfx_mute_ch4 0
	sfx_patch $1A, 0
	sfx_patch $09, 5
	sfx_mute_ch1 $12, 0
	sfx_patch $09, 2
	sfx_mute_ch4 4
	sfx_mute_ch1 $12, 0
	sfx_patch $09, 5
	sfx_mute_ch1 $12, 0
	sfx_patch $09, 6
	sfx_patch $09, 0
	sfx_patch $1A, 6
	sfx_mute_ch1 $12, 5
	sfx_mute_ch1 $12, 0
	sfx_patch $09, 4
	sfx_mute_ch4 0
	sfx_patch $1A, 2
	sfx_mute_ch1 $12, 0
	sfx_patch $09, 6
	sfx_mute_ch1 $12, 0
	sfx_mute_ch4 0
	sfx_patch $1A, 15
	sfx_mute_ch4 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_0C:
	sfx_patch $01, 7
	sfx_mute_ch1 $12, 0
	sfx_patch $01, 7
	sfx_mute_ch1 $12, 0
	sfx_patch $01, 8
	sfx_mute_ch1 $12, 0
	sfx_patch $01, 7
	sfx_mute_ch1 $12, 0
	sfx_patch $01, 8
	sfx_mute_ch1 $12, 0
	sfx_patch $01, 7
	sfx_mute_ch1 $12, 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_00:
	sfx_patch $19, 0
	sfx_tone 29, 5
	sfx_mute_ch4 0
	sfx_mute_ch1 $22, 0
	sfx_tone 33, 6
	sfx_patch $19, 0
	sfx_mute_ch1 $22, 0
	sfx_tone 36, 5
	sfx_mute_ch4 0
	sfx_mute_ch1 $22, 0
	sfx_tone 39, 6
	sfx_patch $19, 0
	sfx_mute_ch1 $22, 0
	sfx_tone 41, 6
	sfx_mute_ch4 0
	sfx_mute_ch1 $22, 0
	sfx_tone 43, 5
	sfx_patch $19, 0
	sfx_mute_ch1 $22, 0
	sfx_tone 47, 6
	sfx_mute_ch4 0
	sfx_mute_ch1 $22, 0
	sfx_tone 50, 6
	sfx_patch $19, 0
	sfx_mute_ch1 $22, 0
	sfx_tone 53, 5
	sfx_mute_ch4 0
	sfx_mute_ch1 $22, 0
	sfx_tone 55, 6
	sfx_patch $19, 0
	sfx_mute_ch1 $22, 0
	sfx_tone 57, 5
	sfx_mute_ch1 $22, 6
	sfx_mute_ch4 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_0A:
	sfx_tone 36, 5
	sfx_mute_ch1 $22, 0
	sfx_tone 40, 6
	sfx_mute_ch1 $22, 0
	sfx_tone 43, 5
	sfx_mute_ch1 $22, 0
	sfx_tone 46, 6
	sfx_mute_ch1 $22, 0
	sfx_tone 48, 6
	sfx_mute_ch1 $22, 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_09:
	sfx_tone 48, 3
	sfx_mute_ch1 $22, 0
	sfx_tone 53, 3
	sfx_mute_ch1 $22, 0
	sfx_tone 52, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 55, 3
	sfx_mute_ch1 $22, 0
	sfx_tone 48, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 53, 3
	sfx_mute_ch1 $22, 0
	sfx_tone 52, 4
	sfx_mute_ch1 $22, 0
	sfx_tone 48, 3
	sfx_mute_ch1 $22, 0
	sfx_tone 60, 4
	sfx_mute_ch1 $22, 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_08:
	sfx_patch $18, 0
	sfx_patch $07, 3
	sfx_mute_ch1 $12, 3
	sfx_patch $07, 3
	sfx_mute_ch1 $12, 3
	sfx_patch $07, 4
	sfx_mute_ch1 $12, 3
	sfx_patch $07, 3
	sfx_mute_ch1 $12, 3
	sfx_patch $07, 3
	sfx_mute_ch1 $12, 4
	sfx_patch $07, 3
	sfx_mute_ch1 $12, 3
	sfx_patch $07, 3
	sfx_mute_ch1 $12, 3
	sfx_patch $07, 4
	sfx_mute_ch1 $12, 3
	sfx_mute_ch4 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_0F:
	sfx_mute_ch1 $00, 17
	sfx_mute_ch1 $06, 0
	sfx_patch $15, 14
	sfx_mute_ch1 $12, 15
	sfx_patch $07, 8
	sfx_mute_ch1 $12, 7
	sfx_patch $07, 4
	sfx_mute_ch4 0
	sfx_patch $13, 11
	sfx_mute_ch1 $12, 0
	sfx_mute_ch4 0
	sfx_patch $11, 8
	sfx_patch $07, 15
	sfx_mute_ch1 $12, 7
	sfx_patch $07, 8
	sfx_mute_ch4 0
	sfx_patch $17, 7
	sfx_mute_ch1 $12, 8
	sfx_patch $07, 15
	sfx_mute_ch4 0
	sfx_mute_ch1 $12, 0
	sfx_patch $10, 11
	sfx_mute_ch4 0
	sfx_patch $13, 11
	sfx_mute_ch4 0
	sfx_patch $18, 60
	sfx_mute_ch4 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_07:
	sfx_patch $14, 0
	sfx_patch $08, 3
	sfx_mute_ch4 0
	sfx_patch $11, 3
	sfx_mute_ch1 $12, 0
	sfx_patch $07, 6
	sfx_mute_ch1 $12, 36
	sfx_mute_ch4 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_06:
	sfx_patch $13, 0
	sfx_patch $08, 6
	sfx_mute_ch1 $12, 0
	sfx_mute_ch4 0
	sfx_patch $12, 0
	sfx_patch $07, 6
	sfx_mute_ch1 $12, 7
	sfx_patch $09, 13
	sfx_mute_ch1 $12, 19
	sfx_mute_ch4 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_05:
	sfx_patch $13, 0
	sfx_patch $0C, 6
	sfx_mute_ch1 $12, 6
	sfx_patch $0C, 6
	sfx_mute_ch1 $12, 6
	sfx_patch $0C, 6
	sfx_mute_ch1 $12, 6
	sfx_patch $0C, 6
	sfx_mute_ch1 $12, 6
	sfx_patch $0C, 6
	sfx_mute_ch1 $12, 6
	sfx_patch $0C, 6
	sfx_mute_ch1 $12, 6
	sfx_patch $0C, 6
	sfx_mute_ch1 $12, 12
	sfx_mute_ch4 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_04:
	sfx_patch $14, 20
	sfx_mute_ch1 $12, 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_02:
	sfx_patch $09, 3
	sfx_mute_ch1 $12, 0
	sfx_patch $04, 3
	sfx_mute_ch1 $12, 0
	sfx_patch $18, 3
	sfx_mute_ch4 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_03:
	sfx_patch $07, 0
	sfx_patch $18, 6
	sfx_mute_ch4 0
	sfx_mute_ch1 $12, 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_01:
	sfx_patch $16, 0
	sfx_patch $06, 6
	sfx_mute_ch1 $12, 0
	sfx_mute_ch4 0
	sfx_patch $12, 0
	sfx_patch $07, 6
	sfx_mute_ch1 $12, 0
	sfx_mute_ch4 7
	sfx_patch $12, 0
	sfx_patch $07, 6
	sfx_mute_ch1 $12, 0
	sfx_mute_ch4 7
	sfx_patch $13, 0
	sfx_patch $08, 6
	sfx_mute_ch1 $12, 0
	sfx_mute_ch4 6
	sfx_patch $06, 0
	sfx_patch $14, 7
	sfx_mute_ch4 0
	sfx_mute_ch1 $12, 0
	sfx_patch $10, 0
	sfx_patch $06, 6
	sfx_mute_ch1 $12, 0
	sfx_mute_ch4 0
	sfx_patch $12, 0
	sfx_patch $07, 7
	sfx_mute_ch1 $12, 0
	sfx_mute_ch4 6
	sfx_patch $14, 0
	sfx_patch $0D, 7
	sfx_mute_ch1 $12, 0
	sfx_mute_ch4 3
	sfx_patch $15, 0
	sfx_patch $08, 6
	sfx_mute_ch1 $12, 0
	sfx_mute_ch4 7
	sfx_patch $09, 0
	sfx_patch $12, 6
	sfx_mute_ch4 13
	sfx_mute_ch1 $12, 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_15:
	sfx_patch $1D, 7
	sfx_mute_ch1 $12, 0
	sfx_patch $1D, 7
	sfx_mute_ch1 $12, 0
	sfx_patch $1D, 8
	sfx_mute_ch1 $12, 0
	sfx_patch $1D, 7
	sfx_mute_ch1 $12, 0
	sfx_patch $1D, 8
	sfx_mute_ch1 $12, 0
	sfx_patch $1D, 25
	sfx_mute_ch1 $12, 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

SfxSequence_16:
	sfx_patch $05, 7
	sfx_mute_ch1 $12, 0
	sfx_patch $06, 7
	sfx_mute_ch1 $12, 0
	sfx_patch $05, 8
	sfx_mute_ch1 $12, 0
	sfx_patch $06, 7
	sfx_mute_ch1 $12, 0
	sfx_patch $05, 25
	sfx_mute_ch1 $12, 0
	sfx_end
	db $FF, $00, $FF, $FF ; not reached by SfxSequence_Update

; Copied to rNR10-rNR52 ($FF10-$FF26) by Audio_Init.
AudioRegisterInit:
	db $77, $87, $97, $82, $07, $00, $80, $F7, $82, $07, $80, $00
	db $20, $82, $07, $00, $00, $F7, $08, $00, $77, $FF, $8F
AudioRegisterInitPadding:
	db $00, $00 ; lies between tables; never read

; 90 little-endian 11-bit channel frequency values, indexed chromatically.
; Index 0 is C2 and index 89 is F9 for square channels 1-2. Channel 3 uses
; half the square-channel clock, so the same indexes sound one octave lower.
; Values are floor(2048 - 131072 / frequency) using A4 = 440 Hz.
NoteFrequencies:
	dw $002C, $009C, $0106, $016A, $01C9, $0222, $0276, $02C6 ; C2-G2
	dw $0311, $0358, $039B, $03DA, $0416, $044E, $0483, $04B5 ; G#2-D#3
	dw $04E4, $0511, $053B, $0563, $0588, $05AC, $05CD, $05ED ; E3-B3
	dw $060B, $0627, $0641, $065A, $0672, $0688, $069D, $06B1 ; C4-G4
	dw $06C4, $06D6, $06E6, $06F6, $0705, $0713, $0720, $072D ; G#4-D#5
	dw $0739, $0744, $074E, $0758, $0762, $076B, $0773, $077B ; E5-B5
	dw $0782, $0789, $0790, $0796, $079C, $07A2, $07A7, $07AC ; C6-G6
	dw $07B1, $07B5, $07B9, $07BD, $07C1, $07C4, $07C8, $07CB ; G#6-D#7
	dw $07CE, $07D1, $07D3, $07D6, $07D8, $07DA, $07DC, $07DE ; E7-B7
	dw $07E0, $07E2, $07E4, $07E5, $07E7, $07E8, $07E9, $07EB ; C8-G8
	dw $07EC, $07ED, $07EE, $07EF, $07F0, $07F1, $07F2, $07F2 ; G#8-D#9
	dw $07F3, $07F4 ; E9-F9

; Copied to wave RAM ($FF30-$FF3F) by Audio_Init.
WaveformPattern:
	db $00, $11, $11, $22, $33, $33, $44, $55, $55, $66, $77, $77, $88, $99, $99, $AA

; Music notes $0C-$14 on channel 4 use these pairs instead of the
; channel's instrument: +0 NR51 bit pattern, +1 instrument index.
NoiseNoteTable:
	db $11, INSTRUMENT_NOISE_1 ; note $0C
	db $11, INSTRUMENT_NOISE_2 ; note $0D
	db $11, INSTRUMENT_NOISE_3 ; note $0E
	db $10, INSTRUMENT_NOISE_1 ; note $0F
	db $10, INSTRUMENT_NOISE_2 ; note $10
	db $10, INSTRUMENT_NOISE_3 ; note $11
	db $01, INSTRUMENT_NOISE_1 ; note $12
	db $01, INSTRUMENT_NOISE_2 ; note $13
	db $01, INSTRUMENT_NOISE_3 ; note $14

; First sound register of channels 1-4.
ChannelRegisterBases:
	dw rNR10, rNR21, rNR30, rNR41
ChannelRegisterBasesPadding:
	db $FF, $FF, $FF, $FF ; lies between tables; never read

; Indexed by (sound id & $7F) for ids $80-$FF. +0 dw sequence (also the
; loop target), +2 ROM bank of the sequence, +3 not read. Ids $80-$88 used.
MusicPointers:
	dw Music_00
	db BANK(Music_00), $00
	dw Music_01
	db BANK(Music_01), $00
	dw Music_02
	db BANK(Music_02), $00
	dw Music_03
	db BANK(Music_03), $00
	dw Music_04
	db BANK(Music_04), $00
	dw Music_05
	db BANK(Music_05), $00
	dw Music_06
	db BANK(Music_06), $00
	dw Music_07
	db BANK(Music_07), $00
	dw Music_08
	db BANK(Music_08), $00
	dw Music_09
	db BANK(Music_09), $00
MusicPointerTablePadding:
	db $FF, $FF ; lies between tables; never read

; 11 x 4 bytes, selected per channel by music_instrument (and channel
; defaults 0-3, NoiseNoteTable 8-10). +0..+2 are written to the channel's
; first three registers; +3 is ORed into the trigger register with bit 7.
Instruments:
	instrument_ch1 $8E, $47, $70, $00 ; 0: channel 1 default
	instrument_ch2 $47, $77, $00, $00 ; 1: channel 2 default
	instrument_ch3 $80, $00, $20, $00 ; 2: channel 3 default
	instrument_ch4 $00, $63, $40, $00 ; 3: assigned, but every ROM note overrides it
	instrument_unreferenced $8E, $07, $77, $00 ; 4
	instrument_ch2 $07, $77, $00, $00 ; 5: channel 2 alternate
	instrument_unreferenced $1F, $67, $26, $40 ; 6
	instrument_unreferenced $00, $C1, $72, $00 ; 7
	instrument_ch4 $3A, $41, $99, $40 ; 8: noise instrument 1
	instrument_ch4 $3A, $41, $00, $40 ; 9: noise instrument 2
	instrument_ch4 $0D, $43, $5A, $40 ; 10: noise instrument 3

Music_00:
	music_stop $FF, $FF

Music_01:
	music_instrument 2, INSTRUMENT_CH2_ALTERNATE, 0
	music_note 3, 16, 0
	music_note 4, 12, 7
	music_off 4, 2
	music_note 4, 12, 8
	music_off 4, 1
	music_note 4, 13, 7
	music_off 3, 1
	music_off 4, 2
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 4, 2
	music_note 3, 16, 9
	music_off 3, 0
	music_note 3, 21, 0
	music_note 4, 13, 8
	music_off 4, 2
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 4, 12, 8
	music_off 4, 2
	music_note 3, 16, 9
	music_note 4, 12, 5
	music_off 3, 3
	music_off 4, 2
	music_note 3, 16, 9
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 4, 2
	music_note 3, 16, 7
	music_off 3, 2
	music_note 3, 21, 0
	music_note 4, 19, 8
	music_off 4, 9
	music_off 3, 2
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 11
	music_note 4, 13, 3
	music_off 3, 5
	music_off 4, 1
	music_note 3, 16, 10
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 4, 1
	music_note 3, 16, 9
	music_off 3, 1
	music_note 3, 21, 0
	music_note 4, 13, 8
	music_off 4, 1
	music_note 4, 12, 8
	music_off 4, 2
	music_note 3, 26, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 3, 25, 10
	music_note 3, 23, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 3, 21, 10
	music_note 3, 19, 0
	music_note 4, 14, 7
	music_off 4, 2
	music_note 3, 20, 0
	music_note 4, 12, 8
	music_off 4, 2
	music_note 3, 21, 0
	music_note 4, 16, 7
	music_off 4, 2
	music_note 4, 12, 8
	music_off 4, 0
	music_off 3, 1
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 11
	music_note 4, 13, 4
	music_off 3, 4
	music_off 4, 2
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_off 3, 0
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 4, 1
	music_off 3, 1
	music_note 3, 16, 7
	music_off 3, 2
	music_note 3, 21, 0
	music_note 4, 13, 8
	music_off 4, 1
	music_off 3, 1
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 4, 12, 3
	music_off 3, 5
	music_off 4, 2
	music_note 3, 16, 9
	music_note 4, 12, 5
	music_off 3, 3
	music_off 4, 2
	music_note 3, 16, 9
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 4, 2
	music_note 3, 16, 7
	music_off 3, 2
	music_note 3, 21, 0
	music_note 4, 19, 8
	music_off 4, 10
	music_off 3, 1
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 11
	music_note 4, 13, 1
	music_off 3, 7
	music_off 4, 1
	music_note 3, 16, 10
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 4, 1
	music_note 3, 16, 10
	music_note 3, 21, 0
	music_note 4, 13, 8
	music_off 4, 1
	music_note 4, 12, 8
	music_off 4, 2
	music_note 3, 26, 0
	music_note 4, 12, 8
	music_off 4, 11
	music_note 4, 13, 8
	music_off 4, 1
	music_note 3, 27, 10
	music_note 4, 14, 7
	music_off 4, 9
	music_off 3, 3
	music_note 3, 28, 0
	music_note 4, 16, 7
	music_off 4, 6
	music_off 3, 5
	music_note 3, 16, 0
	music_note 4, 12, 1
	music_note 2, 19, 7
	music_off 4, 2
	music_note 4, 12, 8
	music_off 4, 1
	music_note 4, 13, 5
	music_off 2, 2
	music_off 3, 1
	music_note 2, 18, 0
	music_off 4, 2
	music_note 3, 16, 0
	music_note 4, 12, 2
	music_note 2, 19, 6
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 4, 2
	music_note 3, 16, 7
	music_note 2, 18, 2
	music_off 3, 0
	music_note 3, 21, 0
	music_note 4, 13, 2
	music_note 2, 19, 6
	music_off 4, 2
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 4, 12, 2
	music_note 2, 18, 3
	music_note 2, 19, 3
	music_off 4, 2
	music_note 3, 16, 9
	music_note 4, 12, 5
	music_off 3, 3
	music_off 4, 2
	music_note 3, 16, 9
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 4, 2
	music_note 3, 16, 7
	music_off 3, 2
	music_note 2, 16, 0
	music_note 3, 21, 0
	music_note 4, 19, 8
	music_off 4, 1
	music_note 2, 14, 8
	music_off 3, 2
	music_note 2, 19, 0
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 11
	music_note 2, 16, 0
	music_note 4, 13, 3
	music_off 3, 5
	music_off 4, 1
	music_note 2, 14, 0
	music_note 3, 16, 10
	music_note 2, 19, 0
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 4, 1
	music_note 2, 19, 0
	music_note 3, 16, 9
	music_off 3, 1
	music_note 2, 16, 0
	music_note 3, 21, 0
	music_note 4, 13, 8
	music_off 4, 1
	music_note 2, 14, 0
	music_note 4, 12, 8
	music_off 4, 2
	music_note 2, 19, 0
	music_note 3, 26, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 2, 16, 0
	music_note 3, 25, 10
	music_note 2, 14, 0
	music_note 3, 23, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 2, 19, 0
	music_note 3, 21, 10
	music_note 2, 16, 0
	music_note 3, 19, 0
	music_note 4, 14, 7
	music_off 4, 2
	music_note 2, 14, 0
	music_note 3, 20, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 2, 19, 0
	music_note 3, 21, 0
	music_note 4, 13, 8
	music_off 4, 2
	music_note 2, 16, 0
	music_note 4, 16, 8
	music_off 4, 0
	music_off 3, 1
	music_note 2, 14, 0
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 2
	music_note 2, 21, 9
	music_note 2, 16, 0
	music_note 4, 13, 4
	music_off 3, 4
	music_off 4, 2
	music_note 2, 14, 0
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_off 3, 0
	music_note 2, 19, 0
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 4, 1
	music_off 3, 1
	music_note 2, 16, 0
	music_note 3, 16, 7
	music_off 3, 2
	music_note 2, 14, 0
	music_note 3, 21, 0
	music_note 4, 13, 8
	music_off 4, 1
	music_off 3, 1
	music_note 2, 19, 0
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 2, 16, 0
	music_note 4, 12, 3
	music_off 3, 5
	music_off 4, 2
	music_note 2, 14, 0
	music_note 3, 16, 9
	music_note 2, 16, 0
	music_note 4, 12, 5
	music_off 3, 3
	music_off 4, 2
	music_note 3, 16, 9
	music_note 2, 14, 0
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 4, 2
	music_note 3, 16, 7
	music_off 3, 2
	music_note 2, 16, 0
	music_note 3, 21, 0
	music_note 4, 19, 8
	music_off 4, 1
	music_note 2, 14, 9
	music_off 3, 1
	music_note 2, 13, 0
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 11
	music_note 2, 16, 0
	music_note 4, 13, 1
	music_off 3, 7
	music_off 4, 1
	music_note 2, 13, 0
	music_note 3, 16, 10
	music_note 2, 12, 0
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 4, 1
	music_note 3, 16, 9
	music_off 2, 1
	music_note 2, 16, 0
	music_note 3, 21, 0
	music_note 4, 13, 8
	music_off 4, 1
	music_note 2, 12, 0
	music_note 4, 12, 8
	music_off 4, 2
	music_note 2, 11, 0
	music_note 3, 26, 0
	music_note 4, 12, 8
	music_off 4, 10
	music_off 2, 1
	music_note 2, 12, 0
	music_note 4, 13, 7
	music_off 4, 2
	music_note 2, 10, 0
	music_note 3, 27, 10
	music_note 4, 14, 7
	music_off 4, 2
	music_note 2, 9, 7
	music_off 3, 2
	music_note 2, 7, 0
	music_note 3, 28, 0
	music_note 4, 16, 8
	music_off 4, 6
	music_off 3, 5
	music_note 2, 19, 0
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 2
	music_note 4, 12, 8
	music_off 4, 1
	music_note 4, 13, 3
	music_off 2, 2
	music_note 2, 18, 2
	music_off 3, 1
	music_off 4, 2
	music_note 2, 19, 0
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 4, 2
	music_note 3, 16, 4
	music_note 2, 18, 5
	music_off 3, 0
	music_note 2, 19, 0
	music_note 3, 21, 0
	music_note 4, 13, 8
	music_off 4, 2
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 2, 20, 0
	music_note 4, 12, 5
	music_note 2, 21, 3
	music_off 4, 2
	music_note 3, 16, 9
	music_note 4, 12, 5
	music_off 3, 3
	music_off 4, 2
	music_note 3, 16, 9
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 4, 1
	music_note 3, 16, 8
	music_off 3, 2
	music_note 2, 19, 0
	music_note 3, 21, 0
	music_note 4, 19, 8
	music_off 4, 1
	music_note 2, 21, 8
	music_off 3, 2
	music_note 2, 22, 0
	music_note 3, 16, 0
	music_note 4, 12, 5
	music_note 2, 23, 3
	music_off 4, 11
	music_note 4, 13, 3
	music_off 3, 5
	music_off 4, 1
	music_note 3, 16, 10
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 4, 1
	music_note 3, 16, 9
	music_off 3, 1
	music_note 3, 21, 0
	music_note 4, 13, 8
	music_off 4, 1
	music_note 4, 12, 8
	music_off 4, 2
	music_note 3, 26, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 3, 25, 10
	music_off 2, 0
	music_note 2, 21, 0
	music_note 3, 23, 0
	music_note 4, 12, 7
	music_off 4, 2
	music_note 2, 23, 0
	music_note 3, 21, 10
	music_note 2, 26, 0
	music_note 3, 19, 0
	music_note 4, 14, 7
	music_off 4, 2
	music_note 3, 20, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 3, 21, 0
	music_note 4, 13, 8
	music_off 4, 2
	music_note 4, 16, 8
	music_off 4, 0
	music_off 3, 1
	music_note 2, 25, 0
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 11
	music_note 4, 13, 4
	music_off 3, 4
	music_off 4, 2
	music_note 2, 21, 0
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_off 3, 0
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 4, 1
	music_off 3, 1
	music_note 3, 16, 7
	music_off 3, 2
	music_note 2, 23, 0
	music_note 3, 21, 0
	music_note 4, 13, 8
	music_off 4, 1
	music_off 3, 1
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 4, 12, 2
	music_off 3, 6
	music_off 4, 2
	music_note 3, 16, 9
	music_note 4, 12, 5
	music_off 3, 3
	music_off 4, 2
	music_note 3, 16, 9
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 4, 1
	music_note 3, 16, 8
	music_off 3, 2
	music_note 3, 21, 0
	music_note 4, 19, 8
	music_off 4, 10
	music_off 3, 1
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 11
	music_note 2, 21, 0
	music_note 4, 13, 1
	music_off 3, 7
	music_off 4, 1
	music_note 3, 16, 10
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 4, 1
	music_note 3, 16, 10
	music_note 2, 19, 0
	music_note 3, 21, 0
	music_note 4, 13, 8
	music_off 4, 1
	music_note 4, 12, 8
	music_off 4, 2
	music_note 3, 26, 0
	music_note 4, 12, 8
	music_off 4, 11
	music_note 2, 18, 0
	music_note 4, 13, 7
	music_off 4, 2
	music_note 3, 27, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 2, 19, 0
	music_note 4, 14, 8
	music_off 4, 2
	music_note 2, 18, 0
	music_note 4, 14, 7
	music_off 3, 1
	music_off 4, 1
	music_note 2, 16, 0
	music_note 3, 28, 0
	music_note 4, 16, 8
	music_off 4, 6
	music_off 3, 0
	music_loop $FF, 0
	db $FE, $FF ; not reached by Music_HandleEvent

Music_02:
	music_instrument 2, INSTRUMENT_CH2_ALTERNATE, 0
	music_pan 2, $11, 0
	music_note 2, 4, 0
	music_note 4, 12, 6
	music_off 4, 3
	music_off 2, 7
	music_note 2, 16, 0
	music_note 4, 12, 5
	music_off 2, 2
	music_off 4, 10
	music_note 2, 16, 0
	music_note 4, 14, 7
	music_off 4, 8
	music_off 2, 1
	music_note 2, 4, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_off 2, 1
	music_note 2, 16, 0
	music_note 4, 14, 7
	music_off 4, 1
	music_note 2, 4, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_note 2, 16, 0
	music_note 4, 14, 7
	music_off 4, 2
	music_off 2, 0
	music_note 2, 14, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_off 2, 0
	music_note 2, 4, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_off 2, 0
	music_note 2, 17, 0
	music_note 4, 12, 7
	music_off 4, 10
	music_note 2, 14, 0
	music_note 4, 14, 7
	music_off 4, 1
	music_note 4, 12, 7
	music_off 4, 2
	music_note 2, 4, 0
	music_note 4, 12, 7
	music_off 4, 9
	music_note 2, 16, 0
	music_note 4, 12, 6
	music_off 2, 1
	music_off 4, 10
	music_note 2, 16, 0
	music_note 4, 14, 7
	music_off 4, 9
	music_off 2, 1
	music_note 2, 4, 0
	music_note 4, 13, 5
	music_off 2, 2
	music_off 4, 1
	music_note 2, 16, 0
	music_note 4, 12, 6
	music_off 2, 1
	music_off 4, 1
	music_note 4, 13, 7
	music_off 4, 2
	music_note 2, 4, 0
	music_note 4, 12, 2
	music_off 2, 5
	music_off 4, 1
	music_note 2, 14, 0
	music_note 4, 12, 7
	music_off 4, 4
	music_off 2, 6
	music_note 2, 16, 0
	music_note 4, 14, 7
	music_off 4, 5
	music_off 2, 4
	music_note 2, 17, 0
	music_note 4, 12, 7
	music_off 4, 8
	music_off 2, 2
	music_note 2, 4, 0
	music_note 4, 12, 7
	music_off 4, 3
	music_off 2, 7
	music_note 2, 16, 0
	music_note 4, 12, 4
	music_off 2, 3
	music_off 4, 9
	music_note 2, 16, 0
	music_note 4, 14, 7
	music_off 4, 6
	music_off 2, 4
	music_note 2, 4, 0
	music_note 4, 12, 4
	music_off 2, 3
	music_off 4, 1
	music_note 2, 16, 0
	music_note 4, 14, 7
	music_off 4, 0
	music_off 2, 2
	music_note 4, 12, 7
	music_off 4, 1
	music_note 2, 16, 0
	music_note 4, 20, 6
	music_off 2, 1
	music_off 4, 1
	music_note 2, 14, 0
	music_note 4, 17, 7
	music_off 4, 2
	music_off 2, 0
	music_note 2, 4, 0
	music_note 4, 12, 7
	music_off 4, 0
	music_off 2, 1
	music_note 2, 17, 0
	music_note 4, 14, 7
	music_off 4, 9
	music_off 2, 1
	music_note 2, 14, 0
	music_note 4, 12, 7
	music_off 4, 9
	music_off 2, 0
	music_note 2, 4, 0
	music_note 4, 12, 7
	music_off 4, 0
	music_off 2, 10
	music_note 2, 16, 0
	music_note 4, 12, 5
	music_off 2, 2
	music_off 4, 10
	music_note 2, 16, 0
	music_note 4, 14, 7
	music_off 4, 3
	music_off 2, 6
	music_note 2, 4, 0
	music_note 4, 12, 7
	music_off 2, 0
	music_off 4, 2
	music_note 2, 16, 0
	music_note 4, 14, 6
	music_off 2, 1
	music_off 4, 1
	music_note 4, 12, 7
	music_off 4, 1
	music_note 2, 4, 0
	music_note 4, 20, 3
	music_off 2, 4
	music_off 4, 2
	music_note 2, 17, 0
	music_note 4, 17, 7
	music_off 4, 1
	music_note 4, 12, 4
	music_off 2, 3
	music_off 4, 1
	music_note 2, 16, 0
	music_note 4, 14, 7
	music_off 4, 6
	music_off 2, 4
	music_note 2, 14, 0
	music_note 4, 12, 7
	music_off 4, 6
	music_off 2, 4
	music_note 3, 23, 0
	music_note 4, 12, 5
	music_off 3, 2
	music_off 4, 1
	music_note 3, 23, 8
	music_note 4, 13, 2
	music_off 3, 5
	music_off 4, 2
	music_note 3, 22, 4
	music_off 3, 4
	music_note 3, 22, 0
	music_note 4, 12, 7
	music_off 4, 5
	music_off 3, 5
	music_note 3, 21, 0
	music_note 4, 16, 5
	music_off 3, 2
	music_off 4, 1
	music_note 3, 21, 8
	music_note 4, 16, 4
	music_off 3, 3
	music_off 4, 2
	music_note 3, 20, 4
	music_off 3, 4
	music_note 3, 20, 0
	music_note 4, 12, 7
	music_off 4, 5
	music_off 3, 5
	music_note 3, 19, 0
	music_note 4, 19, 7
	music_off 4, 6
	music_off 3, 3
	music_note 3, 18, 0
	music_note 4, 19, 7
	music_off 4, 10
	music_off 3, 0
	music_note 3, 23, 0
	music_note 4, 12, 6
	music_off 3, 1
	music_off 4, 1
	music_note 3, 23, 9
	music_note 4, 13, 4
	music_off 3, 3
	music_off 4, 1
	music_note 3, 22, 5
	music_off 3, 3
	music_note 3, 22, 0
	music_note 4, 12, 7
	music_off 4, 6
	music_off 3, 4
	music_note 3, 21, 0
	music_note 4, 16, 5
	music_off 3, 2
	music_off 4, 1
	music_note 3, 21, 9
	music_note 4, 16, 4
	music_off 3, 3
	music_off 4, 1
	music_note 3, 20, 5
	music_off 3, 3
	music_note 3, 20, 0
	music_note 4, 12, 7
	music_off 4, 8
	music_off 3, 2
	music_note 3, 19, 0
	music_note 4, 19, 7
	music_off 4, 9
	music_off 3, 1
	music_note 3, 18, 0
	music_note 4, 19, 6
	music_off 4, 9
	music_off 3, 1
	music_pan 2, $10, 0
	music_note 2, 11, 0
	music_note 3, 23, 0
	music_note 4, 12, 4
	music_off 3, 3
	music_off 4, 2
	music_note 3, 23, 6
	music_off 2, 2
	music_note 2, 11, 0
	music_note 4, 13, 2
	music_off 3, 5
	music_off 4, 1
	music_note 3, 22, 0
	music_off 2, 5
	music_off 3, 4
	music_note 2, 11, 0
	music_note 3, 22, 0
	music_note 4, 12, 6
	music_off 2, 0
	music_off 4, 5
	music_off 3, 5
	music_note 2, 11, 0
	music_note 3, 21, 0
	music_note 4, 16, 5
	music_off 3, 2
	music_off 4, 2
	music_note 3, 21, 1
	music_off 2, 7
	music_note 2, 11, 0
	music_note 4, 16, 4
	music_off 3, 3
	music_off 2, 0
	music_off 4, 1
	music_note 3, 20, 5
	music_off 3, 4
	music_note 2, 11, 0
	music_note 3, 20, 0
	music_note 4, 12, 6
	music_off 2, 0
	music_off 4, 7
	music_off 3, 3
	music_note 2, 11, 0
	music_note 3, 19, 0
	music_note 4, 19, 6
	music_off 2, 1
	music_off 4, 8
	music_off 3, 2
	music_note 2, 11, 0
	music_note 3, 18, 0
	music_note 4, 19, 5
	music_off 2, 2
	music_off 4, 8
	music_off 3, 2
	music_pan 2, $01, 0
	music_note 2, 11, 0
	music_note 3, 23, 0
	music_note 4, 12, 4
	music_off 3, 0
	music_off 2, 2
	music_off 4, 2
	music_note 3, 23, 8
	music_note 2, 11, 0
	music_note 4, 13, 3
	music_off 3, 4
	music_off 4, 1
	music_note 3, 22, 6
	music_off 3, 0
	music_off 2, 3
	music_note 2, 11, 0
	music_note 3, 22, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_off 2, 5
	music_off 3, 3
	music_note 2, 11, 0
	music_note 3, 21, 0
	music_note 4, 13, 6
	music_off 3, 1
	music_off 4, 2
	music_note 3, 21, 7
	music_off 2, 1
	music_pan 2, $10, 0
	music_note 2, 12, 0
	music_note 4, 12, 2
	music_off 3, 5
	music_off 4, 1
	music_note 3, 20, 0
	music_note 4, 20, 6
	music_off 3, 1
	music_off 4, 1
	music_off 2, 1
	music_pan 2, $01, 0
	music_note 2, 11, 0
	music_note 3, 20, 0
	music_note 4, 17, 7
	music_off 4, 1
	music_note 4, 12, 4
	music_off 3, 3
	music_off 2, 0
	music_off 4, 1
	music_pan 2, $10, 0
	music_note 2, 12, 0
	music_note 3, 19, 0
	music_note 4, 14, 7
	music_off 4, 10
	music_off 3, 0
	music_off 2, 0
	music_pan 2, $01, 0
	music_note 2, 11, 0
	music_note 3, 18, 0
	music_note 4, 14, 7
	music_off 4, 6
	music_off 2, 4
	music_off 3, 0
	music_pan 2, $11, 0
	music_note 2, 4, 0
	music_note 3, 28, 0
	music_note 4, 12, 7
	music_off 4, 5
	music_off 2, 4
	music_note 2, 16, 0
	music_note 4, 12, 7
	music_off 4, 2
	music_off 3, 0
	music_note 3, 31, 3
	music_off 2, 5
	music_note 4, 14, 7
	music_off 4, 10
	music_off 3, 0
	music_note 3, 28, 0
	music_note 4, 13, 7
	music_off 4, 1
	music_note 2, 4, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_off 3, 0
	music_note 3, 34, 0
	music_note 4, 12, 1
	music_off 2, 6
	music_off 4, 2
	music_note 2, 4, 3
	music_off 2, 5
	music_note 2, 4, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_off 3, 0
	music_note 3, 33, 4
	music_off 3, 1
	music_note 3, 34, 2
	music_off 2, 2
	music_note 2, 4, 0
	music_note 4, 14, 7
	music_off 4, 7
	music_off 3, 2
	music_note 2, 16, 0
	music_note 3, 33, 0
	music_note 4, 12, 4
	music_off 3, 1
	music_note 3, 34, 2
	music_off 4, 10
	music_note 2, 14, 0
	music_note 4, 12, 7
	music_off 4, 7
	music_off 2, 3
	music_note 2, 14, 0
	music_note 4, 16, 7
	music_off 4, 4
	music_off 2, 5
	music_note 4, 14, 7
	music_off 4, 10
	music_note 4, 19, 4
	music_off 3, 3
	music_off 4, 1
	music_note 2, 4, 0
	music_note 3, 33, 0
	music_note 4, 12, 4
	music_off 3, 1
	music_note 3, 34, 2
	music_off 4, 2
	music_off 2, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_note 2, 4, 4
	music_off 2, 4
	music_note 2, 4, 0
	music_note 4, 12, 7
	music_off 4, 2
	music_off 3, 0
	music_note 3, 33, 7
	music_off 2, 1
	music_note 2, 16, 0
	music_note 4, 14, 7
	music_off 4, 8
	music_off 2, 2
	music_note 2, 14, 0
	music_note 3, 31, 0
	music_note 4, 12, 7
	music_off 4, 8
	music_off 2, 1
	music_note 2, 13, 0
	music_note 3, 28, 0
	music_note 4, 12, 7
	music_off 4, 6
	music_off 2, 4
	music_note 2, 13, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_off 3, 0
	music_note 3, 31, 3
	music_off 2, 6
	music_note 4, 14, 7
	music_off 4, 8
	music_off 3, 1
	music_note 3, 28, 0
	music_note 4, 13, 7
	music_off 4, 2
	music_note 2, 4, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_off 2, 0
	music_off 3, 0
	music_note 3, 33, 0
	music_note 4, 12, 3
	music_off 3, 1
	music_note 3, 34, 3
	music_off 4, 1
	music_note 2, 4, 4
	music_off 2, 5
	music_note 2, 4, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_off 3, 0
	music_note 3, 33, 7
	music_off 2, 1
	music_note 2, 14, 0
	music_note 4, 14, 7
	music_off 4, 7
	music_off 2, 3
	music_note 2, 13, 0
	music_off 3, 0
	music_note 3, 31, 0
	music_note 4, 12, 7
	music_off 4, 7
	music_off 2, 3
	music_note 2, 12, 0
	music_off 3, 0
	music_note 3, 28, 0
	music_note 4, 12, 7
	music_off 4, 8
	music_off 2, 1
	music_note 4, 16, 7
	music_off 4, 10
	music_note 2, 12, 0
	music_note 4, 14, 7
	music_off 4, 7
	music_off 2, 3
	music_note 2, 4, 0
	music_note 4, 19, 3
	music_off 2, 4
	music_off 4, 1
	music_note 2, 12, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_note 4, 12, 1
	music_off 2, 6
	music_off 4, 2
	music_note 2, 12, 4
	music_off 3, 0
	music_note 3, 27, 3
	music_off 3, 1
	music_off 2, 0
	music_note 2, 11, 0
	music_note 3, 28, 0
	music_note 4, 12, 7
	music_off 4, 7
	music_off 2, 3
	music_note 2, 11, 0
	music_note 4, 14, 7
	music_off 4, 9
	music_note 2, 4, 0
	music_note 4, 12, 6
	music_off 3, 1
	music_off 4, 10
	music_note 2, 4, 0
	music_note 3, 28, 0
	music_note 4, 12, 7
	music_off 4, 5
	music_off 2, 5
	music_note 2, 16, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_note 3, 31, 3
	music_off 2, 5
	music_note 4, 14, 7
	music_off 4, 10
	music_note 3, 28, 0
	music_note 4, 13, 7
	music_off 4, 1
	music_note 2, 4, 0
	music_note 4, 12, 7
	music_off 4, 2
	music_note 3, 34, 0
	music_note 4, 12, 0
	music_off 2, 7
	music_off 4, 1
	music_note 2, 4, 3
	music_off 2, 5
	music_note 2, 4, 0
	music_note 4, 12, 7
	music_off 4, 2
	music_note 3, 33, 3
	music_off 3, 1
	music_note 3, 34, 2
	music_off 2, 2
	music_note 2, 4, 0
	music_note 4, 14, 7
	music_off 4, 7
	music_off 3, 3
	music_note 2, 16, 0
	music_note 3, 33, 0
	music_note 4, 12, 3
	music_off 3, 1
	music_note 3, 34, 3
	music_off 4, 9
	music_note 2, 14, 0
	music_note 4, 12, 7
	music_off 4, 7
	music_off 2, 3
	music_note 2, 14, 0
	music_note 4, 16, 7
	music_off 4, 5
	music_off 2, 5
	music_note 4, 14, 6
	music_off 4, 10
	music_off 3, 0
	music_note 3, 28, 0
	music_note 4, 19, 7
	music_off 4, 2
	music_note 2, 4, 0
	music_note 4, 12, 6
	music_off 4, 2
	music_off 2, 0
	music_note 3, 34, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_note 2, 4, 4
	music_off 2, 5
	music_note 2, 4, 0
	music_note 4, 12, 6
	music_off 4, 2
	music_note 3, 33, 7
	music_off 2, 1
	music_note 2, 16, 0
	music_note 4, 14, 7
	music_off 4, 9
	music_off 2, 1
	music_note 2, 14, 0
	music_note 3, 31, 0
	music_note 4, 12, 7
	music_off 4, 8
	music_off 2, 2
	music_note 2, 13, 0
	music_note 3, 28, 0
	music_note 4, 12, 6
	music_off 4, 6
	music_off 2, 4
	music_note 2, 13, 0
	music_note 4, 12, 7
	music_off 4, 2
	music_note 3, 31, 2
	music_off 2, 6
	music_note 4, 14, 7
	music_off 4, 9
	music_note 3, 28, 0
	music_note 4, 13, 7
	music_off 4, 2
	music_note 2, 4, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_off 2, 0
	music_off 3, 0
	music_note 3, 33, 0
	music_note 4, 12, 4
	music_off 3, 0
	music_note 3, 34, 3
	music_off 4, 1
	music_note 2, 4, 4
	music_off 2, 5
	music_note 2, 4, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_off 3, 0
	music_note 3, 33, 7
	music_off 2, 1
	music_note 2, 14, 0
	music_note 4, 14, 7
	music_off 4, 7
	music_off 2, 3
	music_note 2, 13, 0
	music_note 3, 31, 0
	music_note 4, 12, 7
	music_off 4, 7
	music_off 2, 3
	music_note 2, 12, 0
	music_note 4, 12, 7
	music_off 4, 8
	music_off 2, 1
	music_note 4, 16, 7
	music_off 4, 10
	music_note 2, 12, 0
	music_note 4, 14, 7
	music_off 4, 7
	music_off 2, 3
	music_note 2, 4, 0
	music_note 3, 28, 0
	music_note 4, 19, 4
	music_off 2, 3
	music_off 4, 1
	music_note 2, 12, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_off 3, 0
	music_note 3, 40, 0
	music_note 4, 12, 1
	music_off 2, 6
	music_off 4, 2
	music_note 2, 12, 8
	music_off 2, 0
	music_note 2, 11, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_off 3, 0
	music_note 3, 39, 4
	music_off 3, 1
	music_note 3, 40, 1
	music_off 2, 3
	music_note 2, 11, 0
	music_note 4, 14, 7
	music_off 4, 7
	music_off 3, 2
	music_note 2, 4, 0
	music_note 3, 39, 0
	music_note 4, 12, 4
	music_off 3, 1
	music_note 3, 40, 2
	music_off 4, 10
	music_off 3, 0
	music_loop $FF, 0
	db $FE, $FF ; not reached by Music_HandleEvent

Music_03:
	music_note 2, 16, 0
	music_note 3, 40, 0
	music_note 4, 20, 6
	music_off 4, 3
	music_off 2, 2
	music_off 3, 3
	music_note 2, 16, 0
	music_note 3, 35, 0
	music_note 4, 17, 7
	music_off 4, 3
	music_off 2, 5
	music_note 2, 16, 0
	music_note 3, 42, 0
	music_note 4, 12, 7
	music_off 4, 3
	music_off 2, 5
	music_note 2, 16, 0
	music_note 3, 35, 0
	music_note 4, 14, 7
	music_off 4, 1
	music_note 4, 14, 1
	music_off 2, 5
	music_off 4, 1
	music_note 2, 16, 0
	music_off 3, 0
	music_note 3, 43, 0
	music_note 4, 14, 7
	music_off 4, 1
	music_note 4, 14, 2
	music_off 2, 4
	music_off 4, 0
	music_off 3, 1
	music_note 2, 16, 0
	music_note 3, 35, 0
	music_note 4, 14, 7
	music_off 4, 2
	music_off 3, 0
	music_off 2, 6
	music_note 2, 16, 0
	music_note 3, 35, 0
	music_note 4, 12, 7
	music_off 4, 5
	music_off 2, 0
	music_off 3, 3
	music_note 2, 19, 0
	music_note 3, 40, 11
	music_off 2, 2
	music_off 3, 2
	music_note 2, 19, 0
	music_note 3, 35, 0
	music_note 4, 12, 7
	music_off 4, 3
	music_off 2, 5
	music_note 2, 19, 0
	music_note 3, 42, 10
	music_off 2, 5
	music_note 2, 19, 0
	music_note 3, 35, 0
	music_note 4, 12, 7
	music_off 4, 2
	music_off 2, 6
	music_off 3, 0
	music_note 2, 19, 0
	music_note 3, 43, 0
	music_note 4, 14, 7
	music_off 4, 1
	music_note 4, 14, 1
	music_off 2, 5
	music_off 3, 0
	music_off 4, 1
	music_note 2, 19, 0
	music_note 3, 35, 0
	music_note 4, 20, 7
	music_off 4, 3
	music_off 2, 5
	music_note 2, 19, 0
	music_note 3, 42, 0
	music_note 4, 17, 7
	music_off 4, 4
	music_off 2, 4
	music_note 2, 19, 0
	music_note 3, 35, 0
	music_note 4, 14, 7
	music_off 4, 1
	music_note 4, 14, 2
	music_off 3, 0
	music_off 2, 4
	music_off 4, 1
	music_note 2, 19, 0
	music_note 3, 35, 0
	music_note 4, 14, 7
	music_off 4, 8
	music_off 2, 0
	music_note 2, 12, 0
	music_note 3, 40, 0
	music_note 4, 20, 7
	music_off 4, 6
	music_off 2, 2
	music_note 2, 12, 0
	music_note 3, 35, 0
	music_note 4, 14, 7
	music_off 4, 1
	music_note 4, 14, 0
	music_off 2, 6
	music_off 4, 1
	music_note 2, 12, 0
	music_note 3, 42, 0
	music_note 4, 12, 7
	music_off 4, 3
	music_off 2, 5
	music_note 2, 12, 0
	music_note 3, 35, 0
	music_note 4, 14, 7
	music_off 4, 1
	music_note 4, 14, 2
	music_off 2, 4
	music_off 4, 1
	music_note 2, 12, 0
	music_note 3, 43, 0
	music_note 4, 17, 7
	music_off 4, 4
	music_off 2, 4
	music_note 2, 12, 0
	music_note 3, 35, 0
	music_note 4, 14, 7
	music_off 4, 1
	music_note 4, 14, 1
	music_off 2, 2
	music_off 3, 3
	music_off 4, 1
	music_note 2, 12, 0
	music_note 3, 35, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_off 2, 7
	music_note 2, 12, 0
	music_note 3, 40, 0
	music_note 4, 14, 7
	music_off 4, 1
	music_note 4, 14, 6
	music_off 2, 0
	music_off 4, 1
	music_note 2, 11, 0
	music_note 3, 35, 0
	music_note 4, 20, 7
	music_off 4, 5
	music_off 2, 3
	music_note 2, 11, 0
	music_note 3, 42, 0
	music_note 4, 17, 7
	music_off 4, 3
	music_off 2, 5
	music_note 2, 11, 0
	music_note 3, 35, 0
	music_note 4, 20, 6
	music_off 4, 4
	music_off 2, 5
	music_off 3, 0
	music_note 2, 11, 0
	music_note 3, 43, 0
	music_note 4, 14, 6
	music_off 4, 2
	music_note 4, 14, 1
	music_off 2, 5
	music_off 4, 0
	music_off 3, 1
	music_note 2, 11, 0
	music_note 3, 35, 0
	music_note 4, 17, 6
	music_off 4, 3
	music_off 2, 6
	music_note 2, 11, 0
	music_note 3, 45, 0
	music_note 4, 14, 6
	music_off 4, 2
	music_note 4, 14, 1
	music_off 2, 5
	music_off 4, 1
	music_note 2, 11, 0
	music_note 3, 42, 0
	music_note 4, 14, 6
	music_off 4, 2
	music_off 2, 7
	music_note 2, 11, 0
	music_note 3, 35, 0
	music_note 4, 20, 6
	music_off 4, 5
	music_off 2, 1
	music_off 3, 3
	music_note 2, 16, 0
	music_note 3, 52, 0
	music_note 4, 12, 6
	music_off 4, 3
	music_off 2, 4
	music_off 3, 2
	music_note 2, 16, 0
	music_note 3, 47, 0
	music_note 4, 12, 6
	music_off 4, 3
	music_off 2, 6
	music_note 2, 16, 0
	music_off 3, 0
	music_note 3, 54, 0
	music_note 4, 14, 6
	music_off 4, 3
	music_off 2, 5
	music_off 3, 1
	music_note 2, 16, 0
	music_note 3, 47, 0
	music_note 4, 12, 6
	music_off 4, 3
	music_off 2, 5
	music_off 3, 1
	music_note 2, 16, 0
	music_note 3, 55, 0
	music_note 4, 12, 6
	music_off 4, 3
	music_off 2, 5
	music_off 3, 1
	music_note 2, 16, 0
	music_note 3, 47, 9
	music_off 2, 1
	music_off 3, 5
	music_note 2, 16, 0
	music_note 3, 47, 0
	music_note 4, 14, 6
	music_off 4, 6
	music_off 2, 2
	music_off 3, 1
	music_note 2, 19, 0
	music_note 3, 52, 0
	music_note 4, 12, 6
	music_off 4, 4
	music_off 2, 3
	music_off 3, 2
	music_note 2, 19, 0
	music_note 3, 47, 0
	music_note 4, 16, 6
	music_off 4, 4
	music_off 2, 5
	music_note 2, 19, 0
	music_note 3, 54, 0
	music_note 4, 12, 6
	music_off 4, 3
	music_off 2, 6
	music_note 2, 19, 0
	music_note 3, 47, 0
	music_note 4, 14, 6
	music_off 4, 2
	music_off 2, 7
	music_note 2, 19, 0
	music_note 3, 55, 0
	music_note 4, 12, 6
	music_off 4, 2
	music_off 2, 7
	music_note 2, 19, 0
	music_note 3, 47, 0
	music_note 4, 12, 6
	music_off 4, 4
	music_off 2, 1
	music_off 3, 4
	music_note 2, 19, 0
	music_note 3, 47, 0
	music_note 4, 12, 6
	music_off 4, 4
	music_off 2, 4
	music_off 3, 1
	music_note 2, 31, 0
	music_note 3, 52, 0
	music_note 4, 14, 6
	music_off 4, 4
	music_off 2, 2
	music_off 3, 3
	music_note 2, 31, 0
	music_note 3, 47, 0
	music_note 4, 12, 6
	music_off 4, 8
	music_off 2, 1
	music_note 2, 24, 0
	music_note 3, 52, 0
	music_note 4, 12, 6
	music_off 4, 7
	music_off 2, 2
	music_note 2, 24, 0
	music_note 3, 47, 0
	music_note 4, 12, 6
	music_off 4, 2
	music_off 2, 7
	music_note 2, 24, 0
	music_note 3, 54, 0
	music_note 4, 14, 6
	music_off 4, 4
	music_off 2, 5
	music_note 2, 24, 0
	music_note 3, 47, 0
	music_note 4, 12, 6
	music_off 4, 4
	music_off 2, 5
	music_note 2, 24, 0
	music_note 3, 55, 0
	music_note 4, 12, 6
	music_off 4, 5
	music_off 2, 4
	music_note 2, 24, 0
	music_note 3, 47, 0
	music_note 4, 12, 6
	music_off 4, 3
	music_off 2, 1
	music_off 3, 5
	music_note 2, 24, 0
	music_note 3, 47, 0
	music_note 4, 14, 6
	music_off 4, 2
	music_off 2, 6
	music_off 3, 1
	music_note 2, 24, 0
	music_note 3, 52, 0
	music_note 4, 12, 6
	music_off 4, 7
	music_off 3, 1
	music_off 2, 1
	music_note 2, 23, 0
	music_note 3, 47, 0
	music_note 4, 19, 6
	music_off 4, 6
	music_off 2, 3
	music_note 2, 23, 0
	music_note 3, 54, 0
	music_note 4, 12, 6
	music_off 4, 3
	music_off 2, 6
	music_note 2, 23, 0
	music_note 3, 47, 0
	music_note 4, 14, 6
	music_off 4, 3
	music_off 2, 5
	music_off 3, 1
	music_note 2, 23, 0
	music_note 3, 55, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 4, 14, 2
	music_off 2, 4
	music_off 3, 1
	music_off 4, 1
	music_note 2, 23, 0
	music_note 3, 47, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 4, 14, 1
	music_off 2, 6
	music_off 4, 1
	music_note 2, 23, 0
	music_note 3, 57, 0
	music_note 4, 12, 6
	music_off 4, 3
	music_off 2, 6
	music_note 2, 23, 0
	music_note 3, 54, 0
	music_note 4, 14, 6
	music_off 4, 2
	music_off 2, 7
	music_note 2, 23, 0
	music_note 3, 47, 0
	music_note 4, 12, 6
	music_off 4, 5
	music_off 2, 4
	music_note 2, 24, 0
	music_note 4, 12, 6
	music_off 4, 5
	music_off 2, 4
	music_note 2, 24, 0
	music_note 4, 12, 6
	music_off 4, 5
	music_off 2, 4
	music_note 2, 24, 0
	music_note 4, 14, 6
	music_off 4, 4
	music_off 2, 5
	music_note 2, 24, 0
	music_note 3, 30, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_off 3, 0
	music_note 3, 31, 3
	music_off 2, 5
	music_note 2, 24, 0
	music_off 3, 0
	music_note 3, 33, 0
	music_note 4, 12, 6
	music_off 4, 4
	music_off 2, 5
	music_note 2, 24, 0
	music_note 4, 12, 6
	music_off 4, 4
	music_off 2, 5
	music_note 2, 24, 0
	music_note 4, 14, 6
	music_off 4, 5
	music_off 2, 4
	music_note 2, 24, 0
	music_off 3, 0
	music_note 3, 31, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_off 3, 0
	music_note 3, 33, 6
	music_off 2, 2
	music_note 2, 21, 0
	music_off 3, 0
	music_note 3, 35, 0
	music_note 4, 12, 6
	music_off 4, 5
	music_off 2, 4
	music_note 2, 21, 5
	music_off 3, 0
	music_note 3, 33, 4
	music_off 2, 6
	music_note 2, 21, 0
	music_note 4, 14, 6
	music_off 4, 4
	music_off 2, 0
	music_off 3, 0
	music_note 3, 35, 5
	music_note 2, 21, 0
	music_note 4, 12, 6
	music_off 4, 5
	music_off 2, 4
	music_note 2, 21, 0
	music_off 3, 0
	music_note 3, 36, 0
	music_note 4, 12, 6
	music_off 4, 6
	music_off 2, 3
	music_note 2, 21, 0
	music_note 4, 12, 5
	music_off 3, 0
	music_note 3, 35, 1
	music_off 4, 5
	music_off 2, 4
	music_note 2, 21, 0
	music_note 4, 14, 6
	music_off 4, 4
	music_off 2, 0
	music_off 3, 0
	music_note 3, 36, 5
	music_note 2, 21, 0
	music_note 4, 12, 6
	music_off 4, 8
	music_off 2, 1
	music_note 2, 16, 0
	music_off 3, 0
	music_note 3, 37, 0
	music_note 4, 12, 3
	music_off 3, 0
	music_note 3, 38, 3
	music_off 4, 4
	music_off 2, 5
	music_note 2, 16, 0
	music_note 4, 12, 6
	music_off 4, 5
	music_off 2, 4
	music_note 2, 16, 0
	music_note 4, 14, 6
	music_off 4, 5
	music_off 2, 4
	music_note 2, 16, 0
	music_note 4, 12, 6
	music_off 4, 3
	music_off 2, 6
	music_note 2, 16, 0
	music_note 4, 12, 6
	music_off 4, 3
	music_off 2, 6
	music_note 2, 16, 9
	music_off 2, 6
	music_note 2, 16, 0
	music_note 4, 14, 6
	music_off 4, 3
	music_off 2, 6
	music_note 2, 16, 0
	music_off 3, 0
	music_note 3, 36, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 3, 35, 2
	music_off 2, 6
	music_note 2, 16, 0
	music_note 3, 37, 0
	music_note 4, 12, 3
	music_off 3, 0
	music_note 3, 38, 3
	music_off 4, 5
	music_off 2, 4
	music_note 2, 16, 0
	music_note 4, 12, 6
	music_off 4, 4
	music_off 2, 5
	music_note 2, 16, 0
	music_note 4, 14, 6
	music_off 4, 5
	music_off 2, 4
	music_note 2, 16, 0
	music_note 4, 12, 6
	music_off 4, 4
	music_off 2, 1
	music_off 3, 4
	music_note 2, 16, 0
	music_note 3, 37, 0
	music_note 4, 12, 3
	music_off 3, 0
	music_note 3, 38, 3
	music_off 4, 4
	music_off 2, 5
	music_note 2, 16, 0
	music_note 4, 12, 3
	music_off 3, 2
	music_note 3, 36, 1
	music_off 4, 3
	music_off 2, 6
	music_note 2, 16, 0
	music_note 4, 14, 6
	music_off 4, 4
	music_off 3, 0
	music_note 3, 35, 3
	music_off 2, 2
	music_note 2, 23, 0
	music_note 4, 12, 6
	music_off 4, 7
	music_off 2, 2
	music_note 2, 24, 0
	music_off 3, 0
	music_note 3, 33, 0
	music_note 4, 12, 6
	music_off 4, 4
	music_off 2, 5
	music_note 2, 24, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_off 3, 0
	music_note 3, 35, 5
	music_off 2, 3
	music_note 2, 24, 0
	music_note 4, 14, 6
	music_off 4, 3
	music_off 2, 5
	music_off 3, 1
	music_note 2, 24, 0
	music_note 3, 31, 0
	music_note 4, 12, 6
	music_off 4, 4
	music_off 2, 5
	music_note 2, 24, 0
	music_note 4, 12, 6
	music_off 4, 3
	music_off 2, 6
	music_note 2, 24, 9
	music_off 2, 6
	music_note 2, 24, 0
	music_off 3, 0
	music_note 3, 35, 0
	music_note 4, 14, 6
	music_off 4, 4
	music_off 2, 5
	music_note 2, 24, 0
	music_off 3, 0
	music_note 3, 30, 13
	music_off 2, 2
	music_note 2, 21, 0
	music_note 4, 12, 6
	music_off 4, 3
	music_off 2, 4
	music_off 3, 1
	music_note 2, 21, 0
	music_note 3, 35, 10
	music_off 2, 5
	music_note 2, 21, 0
	music_note 4, 14, 7
	music_off 4, 2
	music_off 2, 6
	music_note 2, 21, 0
	music_off 3, 0
	music_note 3, 28, 0
	music_note 4, 12, 7
	music_off 4, 3
	music_off 2, 5
	music_note 2, 21, 0
	music_note 4, 12, 7
	music_off 4, 3
	music_off 2, 5
	music_note 2, 21, 0
	music_off 3, 0
	music_note 3, 35, 0
	music_note 4, 12, 7
	music_off 4, 4
	music_off 2, 4
	music_note 2, 21, 0
	music_note 4, 14, 7
	music_off 4, 3
	music_off 2, 5
	music_off 3, 0
	music_note 2, 21, 0
	music_note 3, 26, 0
	music_note 4, 12, 7
	music_off 4, 8
	music_off 2, 0
	music_note 2, 16, 0
	music_note 4, 12, 7
	music_off 4, 4
	music_off 2, 4
	music_note 2, 16, 0
	music_note 4, 12, 7
	music_off 4, 4
	music_off 2, 4
	music_note 2, 16, 0
	music_note 4, 14, 7
	music_off 4, 3
	music_off 2, 5
	music_note 2, 16, 0
	music_note 4, 12, 7
	music_off 4, 3
	music_off 2, 5
	music_note 2, 16, 0
	music_note 4, 12, 7
	music_off 4, 2
	music_off 2, 6
	music_note 2, 16, 10
	music_off 2, 5
	music_note 2, 16, 0
	music_note 4, 14, 7
	music_off 4, 2
	music_off 2, 6
	music_note 2, 16, 9
	music_off 3, 1
	music_off 2, 5
	music_note 2, 16, 0
	music_note 3, 25, 0
	music_note 4, 12, 3
	music_off 3, 1
	music_note 3, 26, 3
	music_off 4, 2
	music_off 2, 6
	music_note 2, 16, 0
	music_note 4, 12, 6
	music_off 3, 1
	music_off 4, 1
	music_note 3, 25, 3
	music_off 2, 0
	music_off 3, 1
	music_note 3, 26, 3
	music_note 2, 16, 0
	music_note 4, 14, 7
	music_off 4, 3
	music_off 3, 0
	music_off 2, 2
	music_note 3, 25, 3
	music_off 3, 0
	music_note 2, 16, 0
	music_note 3, 26, 0
	music_note 4, 12, 7
	music_off 4, 3
	music_off 2, 4
	music_off 3, 1
	music_note 2, 16, 0
	music_note 3, 25, 0
	music_note 4, 12, 3
	music_off 3, 1
	music_note 3, 26, 3
	music_off 4, 2
	music_off 2, 6
	music_note 2, 16, 0
	music_note 4, 14, 7
	music_off 4, 1
	music_off 3, 0
	music_note 3, 24, 0
	music_off 2, 7
	music_note 2, 16, 0
	music_note 4, 12, 7
	music_off 4, 2
	music_off 2, 6
	music_note 2, 16, 0
	music_note 3, 23, 0
	music_note 4, 14, 7
	music_off 4, 6
	music_off 2, 0
	music_loop $FF, 0
	db $FE, $FF ; not reached by Music_HandleEvent

Music_04:
	music_note 3, 31, 0
	music_note 4, 12, 7
	music_off 4, 4
	music_off 3, 7
	music_note 4, 12, 8
	music_off 4, 1
	music_note 3, 29, 9
	music_note 4, 14, 4
	music_off 3, 4
	music_off 4, 1
	music_note 4, 12, 8
	music_off 4, 2
	music_note 3, 26, 0
	music_note 4, 13, 7
	music_off 4, 2
	music_note 4, 14, 4
	music_off 3, 3
	music_off 4, 2
	music_note 4, 12, 8
	music_off 4, 1
	music_note 3, 24, 0
	music_note 4, 14, 8
	music_off 4, 0
	music_off 3, 1
	music_note 4, 12, 8
	music_off 4, 1
	music_note 3, 22, 0
	music_note 4, 12, 7
	music_off 3, 1
	music_off 4, 2
	music_note 3, 24, 0
	music_note 4, 14, 7
	music_off 3, 0
	music_off 4, 2
	music_note 3, 22, 0
	music_note 4, 12, 6
	music_off 3, 1
	music_off 4, 2
	music_note 3, 21, 0
	music_note 4, 12, 7
	music_off 3, 1
	music_off 4, 1
	music_note 3, 24, 0
	music_note 4, 14, 8
	music_off 4, 1
	music_off 3, 0
	music_note 2, 7, 0
	music_note 3, 43, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_off 2, 1
	music_note 2, 9, 0
	music_note 4, 12, 4
	music_off 2, 3
	music_off 4, 2
	music_note 2, 9, 0
	music_note 4, 16, 4
	music_off 2, 3
	music_off 4, 2
	music_note 2, 9, 5
	music_off 2, 4
	music_note 2, 9, 0
	music_note 4, 14, 5
	music_off 2, 3
	music_off 4, 10
	music_note 2, 7, 0
	music_note 4, 19, 8
	music_off 4, 1
	music_off 2, 1
	music_note 2, 9, 0
	music_note 4, 12, 4
	music_off 2, 3
	music_off 4, 2
	music_note 2, 9, 0
	music_note 4, 12, 4
	music_off 2, 3
	music_off 4, 2
	music_note 2, 9, 4
	music_off 2, 5
	music_note 2, 9, 0
	music_note 4, 12, 5
	music_off 2, 3
	music_off 4, 11
	music_note 2, 9, 0
	music_note 4, 14, 7
	music_off 4, 1
	music_off 2, 1
	music_note 2, 10, 5
	music_off 2, 4
	music_note 2, 10, 0
	music_note 4, 13, 8
	music_off 4, 9
	music_off 2, 1
	music_note 2, 7, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_off 2, 0
	music_note 2, 9, 5
	music_off 2, 5
	music_note 2, 9, 0
	music_note 4, 16, 4
	music_off 2, 3
	music_off 4, 2
	music_note 2, 9, 4
	music_off 2, 5
	music_note 2, 9, 0
	music_note 4, 14, 4
	music_off 2, 4
	music_off 4, 5
	music_off 3, 5
	music_note 2, 9, 0
	music_note 3, 43, 0
	music_note 4, 19, 8
	music_off 4, 1
	music_off 2, 0
	music_off 3, 1
	music_note 2, 10, 0
	music_note 3, 45, 0
	music_note 4, 12, 4
	music_off 2, 3
	music_off 4, 1
	music_off 3, 1
	music_note 2, 10, 0
	music_note 3, 46, 0
	music_note 4, 12, 4
	music_off 2, 3
	music_off 4, 2
	music_note 2, 10, 4
	music_off 2, 5
	music_note 2, 10, 0
	music_note 4, 12, 5
	music_off 2, 3
	music_off 4, 10
	music_note 2, 10, 0
	music_note 4, 14, 8
	music_off 4, 1
	music_off 2, 1
	music_note 2, 12, 0
	music_note 4, 12, 5
	music_off 2, 2
	music_off 4, 1
	music_off 3, 1
	music_note 2, 12, 0
	music_note 3, 45, 0
	music_note 4, 13, 7
	music_off 4, 1
	music_off 3, 1
	music_note 3, 46, 0
	music_note 4, 12, 8
	music_off 4, 0
	music_off 2, 0
	music_off 3, 1
	music_note 2, 7, 0
	music_note 3, 45, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_off 2, 0
	music_note 2, 9, 5
	music_off 2, 5
	music_note 2, 9, 0
	music_note 4, 16, 4
	music_off 2, 3
	music_off 4, 2
	music_note 2, 9, 0
	music_note 4, 12, 4
	music_off 2, 3
	music_off 4, 2
	music_note 2, 9, 0
	music_note 4, 14, 4
	music_off 2, 4
	music_off 4, 10
	music_note 2, 7, 0
	music_note 4, 19, 8
	music_off 4, 1
	music_off 2, 0
	music_note 2, 9, 0
	music_note 4, 12, 5
	music_off 2, 3
	music_off 4, 1
	music_off 3, 1
	music_note 2, 9, 0
	music_note 3, 41, 0
	music_note 4, 12, 3
	music_off 2, 4
	music_off 4, 2
	music_note 2, 9, 4
	music_off 2, 5
	music_note 2, 9, 0
	music_note 4, 12, 4
	music_off 2, 4
	music_off 4, 10
	music_note 2, 9, 0
	music_note 4, 14, 8
	music_off 4, 1
	music_off 2, 0
	music_note 2, 10, 5
	music_off 2, 5
	music_note 2, 10, 0
	music_note 4, 13, 7
	music_off 4, 10
	music_off 2, 1
	music_note 2, 7, 0
	music_note 4, 12, 8
	music_off 4, 0
	music_off 2, 1
	music_note 2, 9, 0
	music_note 4, 12, 4
	music_off 2, 4
	music_off 4, 1
	music_note 2, 9, 0
	music_note 4, 16, 5
	music_off 2, 3
	music_off 4, 2
	music_note 2, 9, 4
	music_off 2, 5
	music_note 2, 9, 0
	music_note 4, 14, 4
	music_off 2, 3
	music_off 4, 11
	music_note 2, 7, 0
	music_note 4, 19, 8
	music_off 4, 1
	music_off 2, 0
	music_note 2, 9, 0
	music_note 4, 12, 5
	music_off 2, 3
	music_off 4, 1
	music_note 2, 9, 0
	music_note 4, 12, 4
	music_off 2, 4
	music_off 4, 2
	music_note 2, 9, 4
	music_off 2, 5
	music_note 2, 9, 0
	music_note 4, 12, 5
	music_off 2, 2
	music_off 4, 11
	music_note 2, 10, 0
	music_note 4, 14, 8
	music_off 4, 0
	music_off 2, 1
	music_note 2, 3, 0
	music_note 4, 12, 6
	music_off 2, 2
	music_off 3, 0
	music_off 4, 2
	music_note 2, 2, 0
	music_note 3, 38, 0
	music_note 4, 13, 7
	music_off 4, 1
	music_off 3, 1
	music_note 3, 41, 1
	music_off 2, 7
	music_off 3, 1
	music_note 2, 7, 0
	music_note 3, 43, 0
	music_note 4, 12, 8
	music_off 4, 0
	music_off 2, 1
	music_note 2, 9, 0
	music_note 4, 12, 5
	music_off 2, 3
	music_off 4, 1
	music_note 2, 9, 0
	music_note 4, 16, 5
	music_off 2, 3
	music_off 4, 1
	music_note 2, 9, 5
	music_off 2, 5
	music_note 2, 9, 0
	music_note 4, 14, 4
	music_off 2, 3
	music_off 4, 11
	music_note 2, 7, 0
	music_note 4, 19, 8
	music_off 4, 1
	music_off 2, 0
	music_note 2, 9, 0
	music_note 4, 12, 4
	music_off 2, 4
	music_off 4, 1
	music_note 2, 9, 0
	music_note 4, 12, 4
	music_off 2, 4
	music_off 4, 2
	music_note 2, 9, 4
	music_off 2, 5
	music_note 2, 9, 0
	music_note 4, 12, 4
	music_off 2, 3
	music_off 4, 11
	music_note 2, 9, 0
	music_note 4, 14, 8
	music_off 4, 0
	music_off 2, 1
	music_note 2, 10, 5
	music_off 2, 4
	music_note 2, 10, 0
	music_note 4, 13, 8
	music_off 4, 9
	music_off 2, 2
	music_note 2, 7, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_off 2, 1
	music_note 2, 9, 5
	music_off 2, 4
	music_note 2, 9, 0
	music_note 4, 16, 5
	music_off 2, 3
	music_off 4, 1
	music_note 2, 9, 5
	music_off 2, 5
	music_note 2, 9, 0
	music_note 4, 14, 4
	music_off 2, 3
	music_off 4, 11
	music_note 2, 9, 0
	music_note 4, 19, 8
	music_off 4, 0
	music_off 2, 1
	music_note 2, 10, 0
	music_note 4, 12, 5
	music_off 2, 3
	music_off 4, 0
	music_off 3, 1
	music_note 2, 10, 0
	music_note 3, 46, 0
	music_note 4, 12, 5
	music_off 2, 3
	music_off 4, 1
	music_note 2, 10, 5
	music_off 2, 5
	music_note 2, 10, 0
	music_note 4, 12, 5
	music_off 2, 2
	music_off 4, 11
	music_note 2, 10, 0
	music_note 4, 14, 8
	music_off 4, 0
	music_off 2, 1
	music_note 2, 12, 0
	music_note 4, 12, 5
	music_off 2, 3
	music_off 4, 1
	music_off 3, 0
	music_note 2, 12, 0
	music_note 3, 45, 0
	music_note 4, 13, 8
	music_off 4, 1
	music_off 3, 0
	music_note 3, 46, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_off 2, 0
	music_off 3, 1
	music_note 2, 7, 0
	music_note 3, 48, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_off 2, 1
	music_note 2, 9, 5
	music_off 2, 4
	music_note 2, 9, 0
	music_note 4, 16, 4
	music_off 2, 4
	music_off 4, 1
	music_note 2, 9, 0
	music_note 4, 12, 5
	music_off 2, 3
	music_off 4, 1
	music_note 2, 9, 0
	music_note 4, 14, 5
	music_off 2, 3
	music_off 4, 11
	music_note 2, 7, 0
	music_note 4, 19, 7
	music_off 4, 2
	music_off 2, 0
	music_note 2, 9, 0
	music_note 4, 12, 4
	music_off 2, 4
	music_off 4, 0
	music_off 3, 1
	music_note 2, 9, 0
	music_note 3, 45, 0
	music_note 4, 12, 4
	music_off 2, 4
	music_off 4, 1
	music_note 2, 9, 4
	music_off 2, 5
	music_note 2, 9, 0
	music_note 4, 12, 5
	music_off 2, 3
	music_off 4, 11
	music_note 2, 9, 0
	music_note 4, 14, 7
	music_off 4, 1
	music_off 2, 1
	music_note 2, 10, 5
	music_off 2, 4
	music_note 2, 10, 0
	music_note 4, 13, 8
	music_off 4, 10
	music_off 2, 1
	music_note 2, 7, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_off 2, 1
	music_note 2, 9, 0
	music_note 4, 12, 4
	music_off 2, 3
	music_off 4, 2
	music_note 2, 9, 0
	music_note 4, 16, 4
	music_off 2, 4
	music_off 4, 1
	music_note 2, 9, 5
	music_off 2, 4
	music_note 2, 9, 0
	music_note 4, 14, 5
	music_off 2, 3
	music_off 4, 11
	music_note 2, 7, 0
	music_note 4, 19, 7
	music_off 4, 1
	music_off 2, 1
	music_note 2, 9, 0
	music_note 4, 12, 4
	music_off 2, 3
	music_off 4, 1
	music_off 3, 1
	music_note 2, 9, 0
	music_note 3, 50, 0
	music_note 4, 12, 4
	music_off 2, 4
	music_off 4, 1
	music_note 2, 9, 5
	music_off 2, 4
	music_note 2, 9, 0
	music_note 4, 12, 6
	music_off 2, 2
	music_off 4, 11
	music_note 2, 10, 0
	music_note 4, 14, 7
	music_off 4, 1
	music_off 2, 1
	music_note 2, 3, 0
	music_note 4, 12, 6
	music_off 2, 2
	music_off 4, 1
	music_note 2, 2, 0
	music_note 4, 13, 8
	music_off 4, 1
	music_note 4, 12, 2
	music_off 2, 6
	music_off 4, 1
	music_off 3, 0
	music_note 3, 14, 0
	music_note 4, 12, 8
	music_off 4, 6
	music_off 3, 5
	music_note 3, 14, 0
	music_note 4, 12, 7
	music_off 4, 8
	music_off 3, 3
	music_note 4, 20, 8
	music_off 4, 20
	music_note 3, 14, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_off 3, 1
	music_note 3, 15, 0
	music_note 4, 12, 8
	music_off 4, 6
	music_off 3, 4
	music_note 3, 15, 0
	music_note 4, 12, 8
	music_off 4, 9
	music_off 3, 2
	music_note 4, 17, 7
	music_off 4, 29
	music_note 4, 12, 8
	music_off 4, 29
	music_note 4, 20, 8
	music_off 4, 10
	music_note 4, 12, 8
	music_off 4, 2
	music_note 4, 17, 7
	music_off 4, 2
	music_note 4, 12, 7
	music_off 4, 11
	music_note 3, 15, 0
	music_note 4, 12, 8
	music_off 4, 10
	music_note 4, 14, 5
	music_off 3, 3
	music_off 4, 2
	music_note 3, 15, 8
	music_off 3, 1
	music_note 3, 17, 18
	music_off 3, 0
	music_note 3, 14, 0
	music_note 4, 12, 8
	music_off 4, 7
	music_off 3, 4
	music_note 3, 14, 0
	music_note 4, 12, 7
	music_off 4, 8
	music_off 3, 3
	music_note 4, 20, 8
	music_off 4, 19
	music_note 3, 14, 0
	music_note 4, 12, 8
	music_off 4, 0
	music_off 3, 2
	music_note 3, 15, 0
	music_note 4, 12, 7
	music_off 4, 7
	music_off 3, 4
	music_note 3, 15, 0
	music_note 4, 12, 8
	music_off 4, 10
	music_note 4, 17, 0
	music_off 3, 8
	music_off 4, 29
	music_note 4, 12, 8
	music_off 4, 10
	music_note 4, 12, 8
	music_off 4, 11
	music_note 4, 20, 7
	music_off 4, 11
	music_note 4, 12, 8
	music_off 4, 1
	music_note 4, 17, 8
	music_off 4, 2
	music_note 4, 12, 7
	music_off 4, 2
	music_note 4, 14, 7
	music_off 4, 2
	music_note 3, 15, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 4, 12, 8
	music_off 4, 0
	music_off 3, 1
	music_note 3, 14, 0
	music_note 4, 14, 8
	music_off 3, 0
	music_off 4, 1
	music_note 3, 15, 0
	music_note 4, 12, 7
	music_off 3, 1
	music_off 4, 2
	music_note 3, 17, 0
	music_note 4, 12, 7
	music_off 4, 2
	music_note 4, 14, 7
	music_off 4, 1
	music_off 3, 1
	music_note 2, 19, 0
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 4, 0
	music_off 2, 1
	music_note 2, 21, 5
	music_off 2, 4
	music_note 2, 21, 0
	music_note 4, 20, 5
	music_off 2, 3
	music_off 4, 1
	music_note 2, 21, 0
	music_note 4, 14, 5
	music_off 2, 3
	music_off 4, 2
	music_note 2, 21, 0
	music_note 4, 17, 4
	music_off 2, 3
	music_off 4, 11
	music_note 2, 19, 9
	music_off 2, 0
	music_note 2, 21, 4
	music_off 2, 5
	music_note 2, 21, 5
	music_off 2, 5
	music_note 2, 21, 4
	music_off 2, 5
	music_note 2, 21, 0
	music_note 4, 14, 4
	music_off 2, 3
	music_off 4, 2
	music_note 4, 20, 8
	music_off 4, 1
	music_note 2, 21, 0
	music_note 4, 14, 8
	music_off 4, 0
	music_off 2, 1
	music_note 2, 22, 0
	music_note 4, 17, 5
	music_off 2, 3
	music_off 4, 1
	music_note 2, 22, 0
	music_off 3, 0
	music_note 4, 14, 8
	music_off 4, 9
	music_off 2, 2
	music_note 2, 19, 8
	music_off 2, 1
	music_note 2, 21, 5
	music_off 2, 4
	music_note 2, 21, 5
	music_off 2, 4
	music_note 2, 21, 5
	music_off 2, 5
	music_note 2, 21, 4
	music_off 2, 14
	music_note 2, 21, 8
	music_off 2, 1
	music_note 2, 22, 5
	music_off 2, 4
	music_note 2, 22, 0
	music_note 4, 14, 5
	music_off 2, 3
	music_off 4, 1
	music_note 2, 22, 5
	music_off 2, 5
	music_note 2, 22, 0
	music_note 4, 20, 5
	music_off 2, 2
	music_off 4, 2
	music_note 4, 14, 7
	music_off 4, 2
	music_note 2, 22, 0
	music_note 4, 17, 8
	music_off 4, 0
	music_off 2, 1
	music_note 2, 24, 5
	music_off 2, 4
	music_note 2, 24, 0
	music_note 4, 17, 8
	music_off 4, 10
	music_off 2, 1
	music_note 2, 19, 0
	music_note 3, 19, 0
	music_note 4, 14, 4
	music_off 3, 3
	music_off 4, 1
	music_off 2, 1
	music_note 2, 21, 0
	music_note 3, 19, 4
	music_off 3, 1
	music_off 2, 4
	music_note 2, 21, 0
	music_note 3, 19, 0
	music_note 4, 20, 4
	music_off 3, 0
	music_off 2, 4
	music_off 4, 1
	music_note 2, 21, 0
	music_note 3, 19, 0
	music_note 4, 14, 4
	music_off 3, 1
	music_off 2, 3
	music_off 4, 1
	music_note 2, 21, 0
	music_note 3, 19, 0
	music_note 4, 17, 5
	music_off 2, 0
	music_off 3, 3
	music_off 4, 11
	music_note 2, 19, 0
	music_note 3, 19, 0
	music_note 4, 14, 4
	music_off 3, 3
	music_off 4, 2
	music_off 2, 0
	music_note 2, 21, 0
	music_note 3, 19, 0
	music_note 4, 20, 4
	music_off 3, 0
	music_off 2, 4
	music_off 4, 1
	music_note 2, 21, 0
	music_note 3, 19, 0
	music_note 4, 14, 4
	music_off 2, 0
	music_off 3, 4
	music_off 4, 1
	music_note 2, 21, 0
	music_note 3, 19, 0
	music_note 4, 17, 4
	music_off 3, 1
	music_off 2, 3
	music_off 4, 2
	music_note 2, 21, 0
	music_note 3, 19, 0
	music_note 4, 14, 3
	music_off 3, 1
	music_off 2, 3
	music_off 4, 11
	music_note 2, 21, 0
	music_note 3, 19, 4
	music_off 3, 4
	music_off 2, 1
	music_note 2, 22, 0
	music_note 3, 19, 4
	music_off 3, 1
	music_off 2, 4
	music_note 2, 22, 0
	music_note 3, 19, 13
	music_off 3, 5
	music_off 2, 1
	music_note 2, 19, 0
	music_note 3, 19, 6
	music_off 3, 2
	music_off 2, 1
	music_note 2, 21, 0
	music_note 3, 19, 4
	music_off 2, 0
	music_off 3, 5
	music_note 2, 21, 0
	music_note 3, 19, 0
	music_note 4, 14, 4
	music_off 3, 0
	music_off 2, 4
	music_off 4, 1
	music_note 2, 21, 0
	music_note 3, 19, 0
	music_note 4, 20, 4
	music_off 3, 1
	music_off 2, 3
	music_off 4, 1
	music_note 2, 21, 0
	music_note 3, 19, 0
	music_note 4, 14, 5
	music_off 2, 0
	music_off 3, 3
	music_off 4, 11
	music_note 2, 19, 0
	music_note 3, 19, 0
	music_note 4, 17, 4
	music_off 3, 3
	music_off 4, 1
	music_off 2, 1
	music_note 2, 21, 0
	music_note 3, 19, 4
	music_off 3, 1
	music_off 2, 4
	music_note 2, 21, 0
	music_note 3, 19, 0
	music_note 4, 17, 4
	music_off 2, 0
	music_off 3, 4
	music_off 4, 1
	music_note 2, 21, 0
	music_note 3, 19, 0
	music_note 4, 14, 4
	music_off 3, 1
	music_off 2, 3
	music_off 4, 1
	music_note 2, 21, 0
	music_note 3, 19, 0
	music_note 4, 20, 6
	music_off 3, 0
	music_off 2, 2
	music_off 4, 11
	music_note 2, 22, 0
	music_note 3, 19, 0
	music_note 4, 14, 4
	music_off 3, 3
	music_off 4, 1
	music_off 2, 1
	music_note 2, 15, 0
	music_note 3, 19, 0
	music_note 4, 17, 4
	music_off 3, 2
	music_off 2, 2
	music_off 4, 1
	music_note 2, 14, 0
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 4, 2
	music_off 3, 1
	music_off 2, 0
	music_loop $FF, 0
	db $FE, $FF ; not reached by Music_HandleEvent

Music_05:
	music_note 3, 31, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 4, 17, 6
	music_off 4, 0
	music_off 3, 1
	music_note 3, 33, 0
	music_note 4, 12, 5
	music_off 3, 1
	music_off 4, 8
	music_note 3, 19, 0
	music_note 4, 17, 7
	music_off 4, 5
	music_off 3, 2
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 4, 0
	music_note 4, 20, 5
	music_off 3, 2
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 4, 20, 3
	music_off 3, 3
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 4, 5
	music_off 3, 3
	music_note 3, 19, 0
	music_note 4, 14, 7
	music_off 4, 3
	music_off 3, 4
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 4, 6
	music_off 3, 2
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 4, 17, 2
	music_off 3, 4
	music_off 4, 1
	music_note 3, 31, 0
	music_note 4, 12, 7
	music_off 4, 7
	music_off 3, 0
	music_note 3, 33, 0
	music_note 4, 17, 7
	music_off 3, 0
	music_off 4, 8
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 4, 20, 4
	music_off 3, 2
	music_off 4, 1
	music_note 3, 33, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 4, 20, 7
	music_off 4, 0
	music_off 3, 0
	music_note 3, 34, 0
	music_note 4, 12, 7
	music_off 4, 0
	music_off 3, 7
	music_note 3, 19, 0
	music_note 4, 14, 7
	music_off 4, 6
	music_off 3, 2
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 4, 6
	music_off 3, 2
	music_note 3, 43, 0
	music_note 4, 12, 7
	music_off 4, 0
	music_note 4, 17, 7
	music_off 4, 0
	music_off 3, 0
	music_note 3, 45, 0
	music_note 4, 12, 6
	music_off 3, 1
	music_off 4, 8
	music_note 3, 19, 0
	music_note 4, 17, 6
	music_off 4, 3
	music_off 3, 5
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 4, 20, 5
	music_off 3, 2
	music_off 4, 0
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 4, 0
	music_note 4, 20, 3
	music_off 3, 4
	music_off 4, 0
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 4, 4
	music_off 3, 4
	music_note 3, 19, 0
	music_note 4, 14, 6
	music_off 4, 4
	music_off 3, 4
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 4, 3
	music_off 3, 4
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 4, 0
	music_note 4, 17, 3
	music_off 3, 4
	music_off 4, 1
	music_note 3, 43, 0
	music_note 4, 12, 6
	music_off 4, 8
	music_off 3, 0
	music_note 3, 45, 0
	music_note 4, 17, 6
	music_off 3, 0
	music_off 4, 8
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 4, 0
	music_note 4, 20, 7
	music_off 3, 0
	music_off 4, 0
	music_note 3, 45, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_note 4, 20, 6
	music_off 4, 0
	music_off 3, 1
	music_note 3, 46, 0
	music_note 4, 12, 6
	music_off 4, 8
	music_off 3, 0
	music_note 3, 48, 0
	music_note 4, 14, 7
	music_off 4, 0
	music_note 2, 14, 7
	music_off 2, 0
	music_off 3, 0
	music_note 2, 19, 0
	music_note 3, 31, 0
	music_note 4, 12, 7
	music_off 2, 0
	music_off 4, 0
	music_note 2, 22, 6
	music_off 3, 1
	music_off 2, 1
	music_note 2, 21, 0
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 4, 14, 6
	music_off 4, 0
	music_off 3, 1
	music_note 3, 22, 11
	music_off 3, 3
	music_note 3, 21, 0
	music_note 4, 12, 7
	music_off 4, 5
	music_off 3, 2
	music_note 3, 22, 8
	music_note 4, 14, 4
	music_off 3, 2
	music_off 4, 1
	music_note 3, 24, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 4, 14, 3
	music_off 3, 3
	music_off 4, 1
	music_note 3, 22, 11
	music_off 3, 3
	music_off 2, 0
	music_note 2, 17, 0
	music_note 3, 21, 0
	music_note 4, 12, 7
	music_off 4, 3
	music_off 3, 4
	music_off 2, 1
	music_note 2, 14, 0
	music_note 3, 22, 0
	music_note 4, 20, 6
	music_off 4, 6
	music_off 3, 2
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 4, 14, 2
	music_off 3, 5
	music_off 4, 0
	music_note 3, 22, 12
	music_off 3, 2
	music_note 3, 21, 0
	music_note 4, 12, 7
	music_off 4, 4
	music_off 3, 4
	music_note 3, 22, 7
	music_note 4, 14, 4
	music_off 3, 2
	music_off 4, 1
	music_note 3, 24, 0
	music_note 4, 12, 7
	music_off 4, 0
	music_note 4, 14, 3
	music_off 3, 4
	music_off 4, 0
	music_note 3, 22, 9
	music_off 3, 6
	music_note 3, 24, 0
	music_note 4, 12, 2
	music_off 2, 4
	music_off 4, 1
	music_note 2, 14, 5
	music_off 3, 1
	music_off 2, 1
	music_note 2, 19, 0
	music_note 3, 19, 0
	music_note 4, 20, 6
	music_off 2, 0
	music_off 4, 1
	music_note 2, 22, 5
	music_off 3, 2
	music_off 2, 0
	music_note 2, 21, 0
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 4, 0
	music_note 4, 14, 3
	music_off 3, 4
	music_off 4, 0
	music_note 3, 22, 14
	music_off 3, 1
	music_note 3, 21, 0
	music_note 4, 12, 6
	music_off 4, 4
	music_off 3, 4
	music_note 3, 22, 7
	music_note 4, 14, 5
	music_off 3, 2
	music_off 4, 0
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 4, 0
	music_note 4, 14, 3
	music_off 3, 4
	music_off 4, 1
	music_note 3, 22, 10
	music_off 3, 4
	music_note 3, 21, 0
	music_note 4, 12, 6
	music_off 4, 4
	music_off 3, 4
	music_off 2, 0
	music_note 2, 19, 0
	music_note 3, 22, 0
	music_note 4, 20, 7
	music_off 4, 3
	music_off 3, 4
	music_off 2, 0
	music_note 2, 26, 0
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_note 4, 14, 2
	music_off 3, 4
	music_off 4, 1
	music_note 3, 22, 10
	music_off 3, 4
	music_note 3, 21, 0
	music_note 4, 12, 7
	music_off 4, 4
	music_off 3, 3
	music_note 3, 22, 7
	music_note 4, 14, 3
	music_off 3, 4
	music_off 4, 1
	music_note 3, 24, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 4, 14, 3
	music_off 3, 3
	music_off 4, 1
	music_note 3, 22, 10
	music_off 3, 4
	music_off 2, 0
	music_note 3, 24, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_off 3, 6
	music_note 2, 14, 0
	music_note 3, 26, 0
	music_note 4, 20, 7
	music_off 2, 0
	music_off 4, 1
	music_note 2, 19, 5
	music_off 3, 1
	music_off 2, 1
	music_note 2, 22, 0
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 2, 0
	music_off 4, 1
	music_note 2, 21, 0
	music_note 4, 14, 6
	music_off 4, 1
	music_off 3, 0
	music_note 3, 22, 11
	music_off 3, 3
	music_note 3, 21, 0
	music_note 4, 12, 7
	music_off 4, 5
	music_off 3, 3
	music_note 3, 22, 7
	music_note 4, 14, 4
	music_off 3, 2
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 4, 14, 3
	music_off 3, 4
	music_off 4, 0
	music_note 3, 22, 11
	music_off 3, 3
	music_note 3, 21, 0
	music_note 4, 12, 7
	music_off 4, 4
	music_off 3, 3
	music_off 2, 1
	music_note 2, 17, 0
	music_note 3, 22, 0
	music_note 4, 20, 6
	music_off 4, 6
	music_off 3, 1
	music_off 2, 1
	music_note 2, 14, 0
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 4, 0
	music_note 4, 14, 2
	music_off 3, 5
	music_off 4, 0
	music_note 3, 22, 12
	music_off 3, 3
	music_note 3, 21, 0
	music_note 4, 12, 6
	music_off 4, 4
	music_off 3, 3
	music_off 2, 1
	music_note 2, 12, 0
	music_note 3, 22, 6
	music_off 2, 1
	music_note 2, 14, 0
	music_note 4, 14, 4
	music_off 3, 3
	music_off 2, 0
	music_off 4, 0
	music_note 2, 15, 0
	music_note 3, 24, 0
	music_note 4, 12, 7
	music_off 4, 0
	music_note 4, 14, 4
	music_off 3, 3
	music_off 2, 0
	music_off 4, 0
	music_note 2, 14, 0
	music_note 3, 22, 9
	music_off 3, 5
	music_off 2, 1
	music_note 2, 12, 0
	music_note 3, 24, 0
	music_note 4, 12, 6
	music_off 4, 6
	music_off 3, 1
	music_off 2, 1
	music_note 2, 15, 0
	music_note 3, 19, 0
	music_note 4, 20, 7
	music_off 4, 5
	music_off 3, 2
	music_off 2, 0
	music_note 2, 14, 0
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 4, 0
	music_note 4, 14, 3
	music_off 3, 4
	music_off 4, 1
	music_note 3, 19, 13
	music_off 3, 1
	music_note 3, 22, 0
	music_note 4, 12, 6
	music_off 4, 4
	music_off 3, 4
	music_note 3, 19, 7
	music_note 4, 14, 5
	music_off 3, 2
	music_off 4, 0
	music_note 3, 22, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_note 4, 14, 2
	music_off 3, 4
	music_off 4, 1
	music_note 3, 21, 10
	music_off 3, 4
	music_note 3, 22, 0
	music_note 4, 12, 7
	music_off 4, 3
	music_off 3, 4
	music_note 3, 24, 0
	music_note 4, 20, 7
	music_off 4, 3
	music_off 3, 5
	music_note 3, 26, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 4, 14, 2
	music_off 3, 4
	music_off 4, 1
	music_note 3, 24, 10
	music_off 3, 4
	music_note 3, 26, 0
	music_note 4, 12, 7
	music_off 4, 4
	music_off 3, 3
	music_note 3, 24, 8
	music_note 4, 14, 2
	music_off 3, 4
	music_off 4, 1
	music_note 3, 27, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 4, 14, 3
	music_off 3, 3
	music_off 4, 1
	music_note 3, 24, 10
	music_off 3, 4
	music_note 3, 26, 0
	music_note 4, 12, 7
	music_off 4, 2
	music_off 3, 6
	music_note 3, 24, 0
	music_note 4, 20, 6
	music_off 4, 3
	music_off 2, 3
	music_off 3, 2
	music_note 3, 19, 0
	music_note 4, 12, 3
	music_off 3, 3
	music_off 4, 1
	music_note 3, 19, 6
	music_off 3, 1
	music_note 4, 12, 7
	music_off 4, 0
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 3, 0
	music_off 4, 0
	music_note 4, 14, 7
	music_off 4, 1
	music_note 3, 19, 3
	music_off 3, 4
	music_note 3, 19, 0
	music_note 4, 12, 5
	music_off 3, 1
	music_off 4, 1
	music_note 4, 14, 6
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 4, 0
	music_note 4, 14, 6
	music_off 3, 1
	music_off 4, 0
	music_note 3, 22, 0
	music_note 4, 12, 7
	music_off 4, 0
	music_note 4, 12, 1
	music_off 3, 6
	music_off 4, 1
	music_note 3, 22, 0
	music_note 4, 14, 6
	music_off 4, 7
	music_off 3, 1
	music_note 3, 24, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 4, 14, 7
	music_off 3, 0
	music_off 4, 0
	music_note 3, 19, 0
	music_note 4, 12, 4
	music_off 3, 3
	music_off 4, 0
	music_note 3, 19, 6
	music_off 3, 1
	music_note 4, 12, 7
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 3, 0
	music_off 4, 1
	music_note 4, 14, 6
	music_off 4, 1
	music_note 3, 19, 3
	music_off 3, 4
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 3, 1
	music_off 4, 0
	music_note 4, 14, 7
	music_off 4, 0
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 4, 0
	music_note 4, 14, 7
	music_off 3, 0
	music_off 4, 1
	music_note 3, 22, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 4, 12, 1
	music_off 3, 5
	music_off 4, 1
	music_note 3, 22, 0
	music_note 4, 14, 6
	music_off 4, 8
	music_off 3, 0
	music_note 3, 21, 0
	music_note 4, 16, 7
	music_off 4, 7
	music_off 3, 0
	music_note 2, 31, 0
	music_note 3, 19, 0
	music_note 4, 12, 4
	music_off 2, 1
	music_off 3, 2
	music_off 4, 1
	music_note 2, 31, 0
	music_note 3, 19, 4
	music_off 2, 3
	music_note 4, 12, 0
	music_off 3, 6
	music_off 4, 1
	music_note 2, 31, 0
	music_note 3, 19, 0
	music_note 4, 12, 4
	music_off 2, 2
	music_off 3, 0
	music_off 4, 1
	music_note 4, 14, 7
	music_off 4, 0
	music_note 2, 31, 0
	music_note 3, 19, 3
	music_off 2, 1
	music_off 3, 3
	music_note 2, 31, 0
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 2, 1
	music_off 3, 0
	music_off 4, 0
	music_note 4, 14, 7
	music_off 4, 1
	music_note 2, 31, 0
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 4, 14, 6
	music_off 3, 0
	music_off 2, 0
	music_off 4, 1
	music_note 2, 33, 0
	music_note 3, 22, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 4, 12, 2
	music_off 3, 5
	music_off 2, 0
	music_off 4, 0
	music_note 2, 34, 0
	music_note 3, 22, 0
	music_note 4, 14, 7
	music_off 4, 7
	music_off 2, 0
	music_off 3, 0
	music_note 2, 36, 0
	music_note 3, 24, 0
	music_note 4, 12, 7
	music_off 4, 1
	music_note 4, 14, 6
	music_off 2, 0
	music_off 3, 0
	music_off 4, 1
	music_note 2, 31, 0
	music_note 3, 19, 0
	music_note 4, 12, 4
	music_off 3, 2
	music_off 4, 1
	music_note 3, 19, 6
	music_off 3, 1
	music_note 4, 12, 7
	music_off 2, 0
	music_off 4, 0
	music_note 2, 33, 0
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 3, 1
	music_off 4, 0
	music_note 4, 14, 7
	music_off 4, 0
	music_note 3, 19, 5
	music_off 3, 2
	music_off 2, 1
	music_note 2, 34, 0
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 3, 0
	music_off 4, 1
	music_note 4, 14, 6
	music_off 2, 0
	music_off 4, 1
	music_note 2, 33, 0
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 4, 1
	music_note 4, 14, 6
	music_off 3, 1
	music_off 4, 0
	music_note 3, 22, 0
	music_note 4, 12, 7
	music_off 2, 0
	music_off 4, 0
	music_note 2, 34, 0
	music_note 4, 12, 4
	music_off 3, 3
	music_off 4, 0
	music_note 3, 22, 0
	music_note 4, 14, 7
	music_off 4, 7
	music_off 2, 0
	music_off 3, 1
	music_note 2, 36, 0
	music_note 3, 21, 0
	music_note 4, 19, 6
	music_off 4, 5
	music_off 3, 2
	music_off 2, 1
	music_note 2, 38, 0
	music_note 3, 15, 0
	music_note 4, 12, 7
	music_off 4, 4
	music_off 3, 3
	music_note 3, 29, 0
	music_note 4, 12, 7
	music_off 4, 2
	music_off 3, 6
	music_note 3, 27, 0
	music_note 4, 14, 6
	music_off 4, 4
	music_off 3, 4
	music_note 3, 22, 0
	music_note 4, 12, 6
	music_off 4, 4
	music_off 3, 4
	music_note 3, 15, 0
	music_note 4, 12, 7
	music_off 4, 4
	music_off 3, 3
	music_note 3, 22, 7
	music_off 2, 1
	music_note 2, 36, 3
	music_off 3, 4
	music_note 3, 27, 0
	music_note 4, 14, 6
	music_off 4, 4
	music_off 3, 3
	music_off 2, 1
	music_note 2, 34, 0
	music_note 3, 22, 14
	music_off 2, 0
	music_off 3, 0
	music_note 2, 33, 0
	music_note 3, 17, 0
	music_note 4, 12, 7
	music_off 4, 3
	music_off 3, 5
	music_note 3, 31, 0
	music_note 4, 12, 6
	music_off 2, 0
	music_off 4, 1
	music_note 2, 34, 2
	music_off 3, 5
	music_note 3, 29, 0
	music_note 4, 14, 6
	music_off 4, 3
	music_off 3, 4
	music_off 2, 1
	music_note 2, 33, 0
	music_note 3, 24, 0
	music_note 4, 12, 7
	music_off 4, 3
	music_off 3, 4
	music_off 2, 0
	music_note 2, 31, 0
	music_note 3, 17, 0
	music_note 4, 12, 7
	music_off 4, 4
	music_off 3, 4
	music_note 3, 24, 6
	music_off 2, 1
	music_note 2, 33, 4
	music_off 3, 3
	music_note 3, 29, 0
	music_note 4, 14, 6
	music_off 4, 3
	music_off 3, 5
	music_off 2, 0
	music_note 2, 31, 0
	music_note 3, 24, 14
	music_off 2, 0
	music_off 3, 1
	music_note 2, 33, 0
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 2, 0
	music_off 4, 1
	music_note 2, 34, 2
	music_off 3, 4
	music_off 2, 1
	music_note 2, 33, 0
	music_note 3, 21, 0
	music_note 4, 12, 6
	music_off 2, 0
	music_off 4, 1
	music_note 2, 31, 3
	music_off 3, 3
	music_off 2, 1
	music_note 2, 26, 0
	music_note 3, 22, 0
	music_note 4, 14, 7
	music_off 4, 3
	music_off 3, 4
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 4, 3
	music_off 3, 5
	music_note 3, 21, 0
	music_note 4, 12, 6
	music_off 4, 3
	music_off 3, 5
	music_note 3, 22, 10
	music_off 3, 4
	music_note 3, 24, 0
	music_note 4, 14, 7
	music_off 4, 2
	music_off 3, 6
	music_note 3, 21, 0
	music_note 4, 17, 6
	music_off 4, 1
	music_note 4, 14, 2
	music_off 3, 4
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 4, 3
	music_off 3, 4
	music_off 2, 1
	music_note 2, 19, 0
	music_note 3, 21, 0
	music_note 4, 12, 7
	music_off 4, 3
	music_off 3, 4
	music_off 2, 0
	music_note 2, 21, 0
	music_note 3, 22, 0
	music_note 4, 14, 7
	music_off 4, 4
	music_off 3, 3
	music_off 2, 1
	music_note 2, 22, 0
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 4, 3
	music_off 3, 4
	music_off 2, 1
	music_note 2, 24, 0
	music_note 3, 21, 0
	music_note 4, 12, 6
	music_off 4, 3
	music_off 3, 5
	music_note 3, 22, 7
	music_off 2, 0
	music_note 2, 22, 4
	music_off 3, 3
	music_note 3, 24, 0
	music_note 4, 14, 7
	music_off 4, 4
	music_off 3, 3
	music_off 2, 1
	music_note 2, 24, 0
	music_note 3, 21, 13
	music_off 3, 0
	music_off 2, 1
	music_note 2, 26, 0
	music_note 3, 15, 0
	music_note 4, 12, 7
	music_off 4, 3
	music_off 3, 4
	music_note 3, 29, 0
	music_note 4, 12, 7
	music_off 4, 5
	music_off 3, 3
	music_note 3, 27, 0
	music_note 4, 14, 6
	music_off 4, 4
	music_off 3, 4
	music_note 3, 22, 0
	music_note 4, 12, 6
	music_off 4, 4
	music_off 3, 4
	music_off 2, 0
	music_note 2, 22, 0
	music_note 3, 15, 0
	music_note 4, 12, 7
	music_off 4, 5
	music_off 3, 2
	music_note 3, 22, 11
	music_off 3, 4
	music_note 3, 27, 0
	music_note 4, 14, 6
	music_off 4, 4
	music_off 3, 4
	music_note 3, 22, 0
	music_note 4, 12, 7
	music_off 4, 0
	music_note 4, 14, 5
	music_off 2, 1
	music_off 3, 1
	music_off 4, 0
	music_note 2, 24, 0
	music_note 3, 17, 0
	music_note 4, 12, 7
	music_off 4, 5
	music_off 3, 3
	music_note 3, 31, 0
	music_note 4, 12, 6
	music_off 2, 0
	music_off 4, 1
	music_note 2, 22, 3
	music_off 3, 4
	music_note 3, 29, 0
	music_note 4, 14, 6
	music_off 4, 4
	music_off 3, 4
	music_off 2, 0
	music_note 2, 21, 0
	music_note 3, 24, 0
	music_note 4, 12, 7
	music_off 4, 4
	music_off 3, 3
	music_off 2, 0
	music_note 2, 24, 0
	music_note 3, 17, 0
	music_note 4, 12, 7
	music_off 4, 4
	music_off 3, 4
	music_note 3, 24, 0
	music_note 4, 12, 6
	music_off 2, 0
	music_off 4, 1
	music_note 2, 22, 4
	music_off 3, 3
	music_note 3, 17, 0
	music_note 4, 14, 7
	music_off 4, 3
	music_off 3, 4
	music_off 2, 0
	music_note 2, 21, 0
	music_note 3, 24, 0
	music_note 4, 12, 7
	music_off 4, 7
	music_off 2, 0
	music_off 3, 1
	music_note 2, 22, 0
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 2, 0
	music_off 4, 1
	music_note 2, 21, 5
	music_off 3, 1
	music_off 2, 1
	music_note 2, 19, 0
	music_note 3, 21, 10
	music_off 3, 4
	music_note 3, 22, 0
	music_note 4, 14, 7
	music_off 4, 3
	music_off 3, 4
	music_note 3, 19, 11
	music_off 3, 4
	music_note 3, 21, 0
	music_note 4, 12, 6
	music_off 4, 3
	music_off 3, 5
	music_note 3, 22, 0
	music_note 4, 12, 7
	music_off 4, 3
	music_off 3, 4
	music_note 3, 24, 0
	music_note 4, 14, 7
	music_off 4, 3
	music_off 3, 5
	music_note 3, 21, 0
	music_note 4, 12, 6
	music_off 4, 5
	music_off 3, 3
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 4, 7
	music_off 3, 1
	music_note 3, 21, 0
	music_note 4, 14, 7
	music_off 4, 2
	music_off 3, 5
	music_note 3, 22, 0
	music_note 4, 14, 7
	music_off 4, 2
	music_off 3, 6
	music_note 3, 21, 0
	music_note 4, 12, 6
	music_off 4, 3
	music_off 3, 5
	music_note 3, 22, 0
	music_note 4, 14, 7
	music_off 4, 2
	music_off 3, 5
	music_note 3, 24, 0
	music_note 4, 20, 7
	music_off 4, 2
	music_off 3, 6
	music_note 3, 26, 0
	music_note 4, 12, 6
	music_off 4, 3
	music_off 3, 5
	music_note 3, 29, 0
	music_note 4, 14, 6
	music_off 4, 1
	music_off 2, 3
	music_off 3, 0
	music_loop $FF, 0
	db $FE, $FF ; not reached by Music_HandleEvent

Music_06:
	music_note 3, 19, 0
	music_note 4, 12, 9
	music_off 4, 0
	music_note 4, 12, 10
	music_off 4, 0
	music_note 4, 16, 7
	music_off 3, 3
	music_off 4, 0
	music_note 3, 19, 0
	music_note 4, 12, 10
	music_off 3, 0
	music_off 4, 0
	music_note 3, 17, 0
	music_note 4, 14, 10
	music_off 3, 0
	music_off 4, 0
	music_note 3, 19, 10
	music_note 4, 19, 10
	music_off 3, 0
	music_off 4, 0
	music_note 3, 17, 0
	music_note 4, 14, 10
	music_off 4, 0
	music_off 3, 0
	music_note 3, 19, 0
	music_note 4, 12, 10
	music_off 4, 10
	music_note 4, 12, 7
	music_off 3, 3
	music_off 4, 0
	music_note 3, 19, 10
	music_off 3, 0
	music_note 3, 17, 0
	music_note 4, 14, 10
	music_off 3, 0
	music_off 4, 0
	music_note 3, 19, 0
	music_note 4, 12, 10
	music_off 3, 0
	music_off 4, 0
	music_note 3, 22, 0
	music_note 4, 12, 10
	music_off 4, 0
	music_note 4, 12, 10
	music_off 3, 0
	music_off 4, 0
	music_note 3, 19, 0
	music_note 4, 12, 10
	music_off 4, 0
	music_note 4, 12, 10
	music_off 4, 0
	music_note 4, 16, 6
	music_off 3, 4
	music_off 4, 0
	music_note 3, 19, 0
	music_note 4, 12, 10
	music_off 3, 0
	music_off 4, 0
	music_note 3, 17, 0
	music_note 4, 14, 10
	music_off 3, 0
	music_off 4, 0
	music_note 3, 19, 10
	music_note 4, 19, 10
	music_off 3, 0
	music_off 4, 0
	music_note 3, 17, 0
	music_note 4, 12, 8
	music_off 3, 2
	music_off 4, 0
	music_note 3, 19, 0
	music_note 4, 12, 10
	music_off 4, 7
	music_off 3, 3
	music_note 3, 19, 0
	music_note 4, 12, 9
	music_off 4, 10
	music_off 3, 1
	music_note 3, 17, 0
	music_note 4, 14, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 16, 0
	music_note 4, 13, 9
	music_off 4, 1
	music_note 4, 12, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 9
	music_off 4, 1
	music_note 4, 12, 9
	music_off 4, 1
	music_note 4, 16, 3
	music_off 3, 6
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 17, 0
	music_note 4, 14, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 9
	music_off 4, 1
	music_note 4, 19, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 17, 0
	music_note 4, 12, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 9
	music_off 4, 11
	music_note 4, 12, 6
	music_off 3, 3
	music_off 4, 1
	music_note 3, 19, 9
	music_off 3, 1
	music_note 3, 17, 0
	music_note 4, 14, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 22, 0
	music_note 4, 13, 9
	music_off 4, 1
	music_note 4, 12, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 9
	music_off 4, 1
	music_note 4, 12, 9
	music_off 4, 1
	music_note 4, 13, 2
	music_off 3, 7
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 17, 0
	music_note 4, 14, 9
	music_off 4, 1
	music_off 3, 0
	music_note 3, 19, 10
	music_note 4, 12, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 17, 0
	music_note 4, 14, 9
	music_off 4, 0
	music_off 3, 1
	music_note 3, 19, 0
	music_note 4, 12, 9
	music_off 4, 1
	music_note 4, 14, 5
	music_off 3, 4
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 17, 9
	music_off 4, 1
	music_note 4, 12, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 17, 0
	music_note 4, 14, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 20, 9
	music_off 3, 0
	music_off 4, 1
	music_note 2, 19, 0
	music_note 3, 16, 0
	music_note 4, 12, 9
	music_off 4, 1
	music_note 4, 14, 8
	music_off 3, 1
	music_off 4, 1
	music_note 2, 26, 0
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 3, 3
	music_off 4, 1
	music_note 3, 19, 5
	music_off 3, 5
	music_note 3, 19, 0
	music_note 4, 14, 5
	music_off 3, 4
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 3, 3
	music_off 4, 1
	music_note 2, 25, 0
	music_note 3, 17, 0
	music_note 4, 12, 4
	music_off 2, 1
	music_note 2, 26, 3
	music_off 3, 1
	music_off 4, 1
	music_note 3, 19, 8
	music_off 3, 0
	music_off 2, 2
	music_note 2, 25, 0
	music_note 3, 17, 0
	music_note 4, 14, 4
	music_off 2, 1
	music_note 2, 26, 2
	music_off 3, 2
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 3, 1
	music_off 2, 1
	music_off 4, 1
	music_note 2, 25, 0
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 3, 3
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 3, 3
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 14, 5
	music_off 3, 4
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 5
	music_off 3, 4
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 3, 3
	music_off 4, 1
	music_note 3, 19, 5
	music_off 3, 5
	music_note 3, 19, 0
	music_note 4, 14, 5
	music_off 3, 4
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 5
	music_off 3, 4
	music_off 4, 1
	music_off 2, 0
	music_note 2, 17, 0
	music_note 3, 19, 0
	music_note 4, 12, 5
	music_off 3, 4
	music_off 2, 0
	music_off 4, 1
	music_note 2, 19, 0
	music_note 3, 19, 5
	music_off 3, 5
	music_note 3, 19, 0
	music_note 4, 14, 6
	music_off 3, 3
	music_off 2, 0
	music_off 4, 1
	music_note 2, 17, 0
	music_note 3, 19, 0
	music_note 4, 12, 5
	music_off 3, 4
	music_off 2, 0
	music_off 4, 1
	music_note 2, 22, 0
	music_note 3, 19, 0
	music_note 4, 12, 5
	music_off 3, 4
	music_off 4, 1
	music_note 3, 19, 4
	music_off 3, 6
	music_note 3, 19, 0
	music_note 4, 14, 5
	music_off 3, 4
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 5
	music_off 3, 4
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 16, 5
	music_off 3, 4
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 5
	music_off 3, 4
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 14, 5
	music_off 3, 4
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 5
	music_off 3, 4
	music_off 4, 1
	music_note 3, 17, 0
	music_note 4, 12, 9
	music_off 4, 0
	music_off 3, 1
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 3, 2
	music_off 4, 1
	music_note 3, 17, 0
	music_note 4, 14, 5
	music_off 3, 4
	music_off 2, 0
	music_off 4, 1
	music_note 2, 19, 0
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 3, 3
	music_off 4, 1
	music_note 2, 26, 0
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 3, 3
	music_off 4, 1
	music_note 3, 19, 5
	music_off 3, 5
	music_note 3, 19, 0
	music_note 4, 14, 5
	music_off 3, 4
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 5
	music_off 3, 4
	music_off 4, 1
	music_note 2, 25, 0
	music_note 3, 19, 0
	music_note 4, 12, 4
	music_off 2, 1
	music_note 2, 26, 1
	music_off 3, 3
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 5
	music_off 3, 4
	music_off 2, 0
	music_off 4, 1
	music_note 2, 25, 0
	music_note 3, 19, 0
	music_note 4, 14, 4
	music_off 2, 1
	music_note 2, 26, 1
	music_off 3, 3
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 3, 3
	music_off 2, 0
	music_off 4, 1
	music_note 2, 25, 0
	music_note 3, 19, 0
	music_note 4, 19, 6
	music_off 3, 3
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 5
	music_off 3, 4
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 14, 6
	music_off 3, 3
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 5
	music_off 3, 4
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 3, 3
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 5
	music_off 3, 4
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 14, 6
	music_off 3, 3
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 5
	music_off 3, 1
	music_off 2, 3
	music_off 4, 1
	music_note 2, 17, 0
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 3, 3
	music_off 2, 0
	music_off 4, 1
	music_note 2, 19, 0
	music_note 3, 19, 6
	music_off 3, 4
	music_note 3, 19, 0
	music_note 4, 14, 6
	music_off 3, 3
	music_off 2, 0
	music_off 4, 1
	music_note 2, 17, 0
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 3, 3
	music_off 2, 0
	music_off 4, 1
	music_note 2, 22, 0
	music_note 3, 17, 0
	music_note 4, 12, 9
	music_off 4, 0
	music_off 3, 1
	music_note 3, 19, 6
	music_off 3, 3
	music_off 2, 1
	music_note 2, 17, 0
	music_note 3, 17, 0
	music_note 4, 14, 9
	music_off 2, 0
	music_off 4, 0
	music_off 3, 1
	music_note 2, 19, 0
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 3, 3
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 3, 3
	music_off 4, 0
	music_off 2, 1
	music_note 2, 17, 0
	music_note 3, 19, 0
	music_note 4, 14, 6
	music_off 3, 3
	music_off 2, 0
	music_off 4, 1
	music_note 2, 22, 0
	music_note 3, 19, 0
	music_note 4, 20, 6
	music_off 3, 3
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 3, 3
	music_off 2, 0
	music_off 4, 1
	music_note 2, 17, 0
	music_note 3, 17, 0
	music_note 4, 14, 9
	music_off 2, 0
	music_off 3, 0
	music_off 4, 1
	music_note 2, 19, 0
	music_note 3, 19, 0
	music_note 4, 17, 8
	music_off 3, 1
	music_off 2, 0
	music_off 4, 1
	music_note 2, 21, 0
	music_note 3, 17, 0
	music_note 4, 12, 9
	music_off 2, 0
	music_off 3, 0
	music_off 4, 1
	music_note 2, 22, 0
	music_note 3, 19, 8
	music_off 3, 1
	music_off 2, 1
	music_note 2, 4, 0
	music_note 4, 12, 5
	music_off 2, 4
	music_off 4, 1
	music_note 2, 4, 0
	music_note 4, 12, 8
	music_off 2, 1
	music_off 4, 1
	music_note 4, 16, 9
	music_off 4, 1
	music_note 2, 4, 0
	music_note 4, 12, 9
	music_off 2, 0
	music_off 4, 1
	music_note 2, 5, 0
	music_note 4, 14, 7
	music_off 2, 2
	music_off 4, 1
	music_note 2, 5, 8
	music_off 2, 2
	music_note 4, 19, 9
	music_off 4, 1
	music_note 2, 5, 0
	music_note 4, 12, 9
	music_off 2, 0
	music_off 4, 1
	music_note 2, 7, 0
	music_note 4, 12, 7
	music_off 2, 2
	music_off 4, 1
	music_note 2, 7, 9
	music_off 2, 1
	music_note 4, 12, 9
	music_off 4, 1
	music_note 2, 7, 9
	music_off 2, 1
	music_note 2, 8, 0
	music_note 4, 14, 7
	music_off 2, 2
	music_off 4, 1
	music_note 2, 8, 0
	music_note 4, 12, 7
	music_off 2, 2
	music_off 4, 1
	music_note 4, 13, 9
	music_off 4, 1
	music_note 2, 8, 0
	music_note 4, 12, 8
	music_off 2, 1
	music_off 4, 1
	music_note 2, 4, 0
	music_note 3, 28, 0
	music_note 4, 12, 6
	music_off 3, 0
	music_off 2, 3
	music_off 4, 1
	music_note 2, 4, 0
	music_note 3, 28, 0
	music_note 4, 12, 7
	music_off 3, 0
	music_off 2, 2
	music_off 4, 1
	music_note 4, 13, 9
	music_off 4, 1
	music_note 2, 4, 0
	music_note 3, 28, 0
	music_note 4, 12, 6
	music_off 2, 2
	music_off 3, 1
	music_off 4, 1
	music_note 2, 5, 0
	music_note 3, 29, 0
	music_note 4, 14, 5
	music_off 2, 1
	music_off 3, 3
	music_off 4, 1
	music_note 2, 5, 0
	music_note 3, 29, 6
	music_off 3, 1
	music_off 2, 3
	music_note 4, 12, 9
	music_off 4, 1
	music_note 2, 5, 0
	music_note 3, 29, 0
	music_note 4, 14, 9
	music_off 2, 0
	music_off 3, 0
	music_off 4, 1
	music_note 2, 7, 0
	music_note 3, 31, 0
	music_note 4, 12, 6
	music_off 3, 0
	music_off 2, 3
	music_off 4, 1
	music_note 2, 7, 0
	music_note 3, 31, 0
	music_note 4, 14, 8
	music_off 3, 0
	music_off 2, 1
	music_off 4, 1
	music_note 4, 12, 9
	music_off 4, 1
	music_note 2, 7, 0
	music_note 3, 31, 0
	music_note 4, 12, 8
	music_off 2, 1
	music_off 4, 0
	music_off 3, 1
	music_note 2, 8, 0
	music_note 3, 32, 0
	music_note 4, 14, 7
	music_off 2, 2
	music_off 3, 0
	music_off 4, 0
	music_note 2, 8, 0
	music_note 3, 31, 8
	music_off 2, 2
	music_off 3, 0
	music_note 3, 32, 0
	music_note 4, 12, 10
	music_off 4, 0
	music_note 2, 8, 0
	music_note 4, 12, 9
	music_off 2, 1
	music_off 3, 0
	music_off 4, 0
	music_note 3, 16, 0
	music_note 4, 12, 6
	music_off 3, 4
	music_off 4, 0
	music_note 3, 16, 10
	music_note 4, 16, 3
	music_off 3, 7
	music_off 4, 0
	music_note 3, 16, 0
	music_note 4, 12, 10
	music_off 3, 0
	music_off 4, 0
	music_note 3, 17, 0
	music_note 4, 14, 8
	music_off 3, 2
	music_off 4, 0
	music_note 3, 17, 10
	music_off 3, 0
	music_note 4, 12, 10
	music_off 4, 0
	music_note 3, 17, 0
	music_note 4, 14, 10
	music_off 3, 0
	music_off 4, 0
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 3, 3
	music_off 4, 0
	music_note 3, 19, 10
	music_off 3, 0
	music_note 4, 12, 10
	music_off 4, 0
	music_note 3, 19, 10
	music_off 3, 0
	music_note 3, 20, 0
	music_note 4, 14, 8
	music_off 3, 2
	music_off 4, 0
	music_note 3, 20, 10
	music_note 4, 12, 3
	music_off 3, 7
	music_off 4, 0
	music_note 3, 20, 0
	music_note 4, 14, 8
	music_off 3, 2
	music_off 4, 0
	music_note 2, 27, 0
	music_note 3, 16, 0
	music_note 4, 12, 4
	music_off 2, 1
	music_note 2, 28, 2
	music_off 3, 3
	music_off 4, 0
	music_note 3, 16, 9
	music_off 2, 1
	music_note 2, 27, 0
	music_note 4, 19, 1
	music_off 3, 3
	music_off 2, 1
	music_note 2, 28, 5
	music_off 4, 0
	music_note 3, 16, 0
	music_note 4, 12, 9
	music_off 2, 0
	music_off 3, 1
	music_off 4, 0
	music_note 2, 29, 0
	music_note 3, 17, 0
	music_note 4, 14, 7
	music_off 3, 3
	music_off 4, 0
	music_note 3, 17, 8
	music_off 2, 2
	music_note 2, 29, 0
	music_note 4, 12, 1
	music_off 3, 8
	music_off 4, 1
	music_note 3, 17, 0
	music_note 4, 14, 9
	music_off 2, 0
	music_off 3, 0
	music_off 4, 1
	music_note 2, 31, 0
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 3, 2
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 14, 9
	music_off 2, 0
	music_off 4, 1
	music_note 2, 29, 0
	music_note 4, 20, 1
	music_off 3, 8
	music_off 2, 0
	music_off 4, 1
	music_note 2, 31, 0
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 3, 2
	music_off 2, 0
	music_off 4, 1
	music_note 2, 32, 0
	music_note 3, 20, 0
	music_note 4, 14, 6
	music_off 3, 3
	music_off 4, 1
	music_off 2, 0
	music_note 2, 31, 0
	music_note 3, 20, 0
	music_note 4, 17, 9
	music_off 2, 0
	music_off 3, 0
	music_off 4, 1
	music_note 2, 32, 0
	music_note 4, 12, 9
	music_off 2, 0
	music_off 4, 1
	music_note 2, 34, 0
	music_note 3, 20, 8
	music_off 3, 2
	music_note 3, 19, 0
	music_note 4, 12, 3
	music_off 2, 4
	music_off 3, 2
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 9
	music_off 4, 1
	music_note 4, 16, 2
	music_off 3, 7
	music_off 4, 1
	music_note 3, 17, 0
	music_note 4, 12, 6
	music_off 3, 3
	music_off 4, 1
	music_note 3, 17, 0
	music_note 4, 14, 9
	music_off 4, 2
	music_off 3, 9
	music_note 3, 19, 0
	music_note 4, 19, 6
	music_off 3, 3
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 14, 9
	music_off 3, 0
	music_off 4, 1
	music_note 4, 12, 9
	music_off 4, 11
	music_note 4, 12, 9
	music_off 4, 11
	music_note 4, 14, 9
	music_off 4, 1
	music_note 4, 12, 9
	music_off 4, 1
	music_note 4, 12, 9
	music_off 4, 1
	music_note 4, 12, 9
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 3, 3
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 9
	music_off 4, 1
	music_note 4, 16, 2
	music_off 3, 7
	music_off 4, 1
	music_note 3, 17, 0
	music_note 4, 12, 7
	music_off 3, 2
	music_off 4, 1
	music_note 3, 17, 0
	music_note 4, 14, 9
	music_off 4, 3
	music_off 3, 8
	music_note 3, 19, 0
	music_note 4, 19, 6
	music_off 3, 3
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 9
	music_off 4, 1
	music_off 3, 0
	music_note 4, 12, 9
	music_off 4, 11
	music_note 4, 12, 9
	music_off 4, 11
	music_note 4, 14, 9
	music_off 4, 1
	music_note 4, 12, 9
	music_off 4, 1
	music_note 4, 13, 9
	music_off 4, 1
	music_note 4, 12, 9
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 3, 2
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 9
	music_off 4, 1
	music_note 4, 16, 3
	music_off 3, 6
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 8
	music_off 3, 1
	music_off 4, 1
	music_note 3, 17, 0
	music_note 4, 14, 9
	music_off 4, 1
	music_note 4, 12, 3
	music_off 3, 6
	music_off 4, 1
	music_note 3, 17, 0
	music_note 4, 19, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 9
	music_off 4, 1
	music_note 4, 12, 2
	music_off 3, 7
	music_off 4, 1
	music_note 3, 19, 7
	music_off 3, 3
	music_note 3, 17, 0
	music_note 4, 12, 9
	music_off 4, 7
	music_off 3, 4
	music_note 3, 19, 0
	music_note 4, 14, 9
	music_off 4, 1
	music_note 4, 12, 4
	music_off 3, 5
	music_off 4, 1
	music_note 3, 20, 0
	music_note 4, 13, 9
	music_off 4, 1
	music_note 4, 12, 3
	music_off 3, 6
	music_off 4, 1
	music_note 2, 30, 0
	music_note 3, 19, 0
	music_note 4, 12, 4
	music_off 2, 1
	music_note 2, 31, 1
	music_off 3, 3
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 12, 9
	music_off 4, 1
	music_note 4, 13, 2
	music_off 3, 7
	music_off 2, 0
	music_off 4, 1
	music_note 2, 29, 0
	music_note 3, 19, 0
	music_note 4, 12, 7
	music_off 3, 2
	music_off 4, 1
	music_note 3, 17, 0
	music_note 4, 14, 9
	music_off 4, 8
	music_off 3, 2
	music_off 2, 1
	music_note 2, 31, 0
	music_note 3, 17, 0
	music_note 4, 12, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 14, 9
	music_off 2, 0
	music_off 4, 1
	music_note 2, 31, 0
	music_note 4, 12, 1
	music_off 3, 3
	music_off 2, 1
	music_note 2, 32, 4
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 14, 8
	music_off 3, 1
	music_off 4, 1
	music_note 3, 17, 0
	music_note 4, 20, 9
	music_off 2, 0
	music_off 4, 1
	music_note 2, 31, 0
	music_note 4, 12, 7
	music_off 3, 2
	music_off 4, 1
	music_note 3, 19, 0
	music_note 4, 14, 9
	music_off 4, 1
	music_note 4, 17, 2
	music_off 3, 7
	music_off 2, 0
	music_off 4, 1
	music_note 2, 32, 0
	music_note 3, 20, 0
	music_note 4, 12, 9
	music_off 4, 1
	music_note 4, 14, 4
	music_off 3, 5
	music_off 2, 0
	music_off 4, 0
	music_loop $FF, 0
	db $FE, $FF ; not reached by Music_HandleEvent

Music_07:
	music_off 1, 15
	music_instrument 2, INSTRUMENT_CH2_ALTERNATE, 0
	music_pan 1, $11, 0
	music_note 1, 39, 0
	music_pan 2, $01, 0
	music_note 2, 28, 0
	music_pan 3, $10, 0
	music_note 3, 16, 0
	music_note 4, 12, 3
	music_off 1, 1
	music_note 1, 40, 4
	music_off 4, 10
	music_note 4, 13, 9
	music_off 2, 0
	music_off 3, 0
	music_off 4, 0
	music_note 1, 31, 0
	music_note 2, 19, 0
	music_note 3, 19, 10
	music_note 4, 14, 8
	music_off 4, 9
	music_off 2, 0
	music_off 3, 1
	music_note 1, 33, 0
	music_note 2, 21, 0
	music_note 3, 21, 0
	music_note 4, 12, 9
	music_off 4, 9
	music_off 1, 0
	music_off 2, 0
	music_off 3, 1
	music_note 1, 33, 0
	music_note 2, 22, 0
	music_note 3, 22, 0
	music_note 4, 12, 4
	music_off 1, 0
	music_note 1, 34, 4
	music_off 4, 1
	music_note 4, 20, 8
	music_off 4, 1
	music_note 4, 16, 6
	music_off 3, 2
	music_off 2, 1
	music_off 4, 1
	music_note 1, 33, 0
	music_note 2, 21, 0
	music_note 3, 21, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 4, 17, 8
	music_off 4, 10
	music_off 2, 0
	music_off 3, 0
	music_note 1, 31, 0
	music_note 2, 19, 0
	music_note 3, 19, 0
	music_note 4, 19, 9
	music_off 4, 9
	music_off 1, 0
	music_off 2, 0
	music_off 3, 1
	music_note 1, 28, 0
	music_note 2, 16, 0
	music_note 3, 16, 0
	music_note 4, 12, 8
	music_off 4, 138
	music_off 1, 0
	music_off 2, 0
	music_off 3, 0
	music_stop $FF, $FF
	db $00, $FF, $FF ; not reached by Music_HandleEvent

Music_08:
	music_instrument 2, INSTRUMENT_CH2_ALTERNATE, 0
	music_pan 1, $11, 0
	music_pan 2, $01, 0
	music_note 2, 39, 0
	music_pan 3, $10, 0
	music_note 3, 15, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 4, 12, 0
	music_off 2, 9
	music_off 4, 0
	music_note 4, 16, 7
	music_off 3, 2
	music_off 4, 1
	music_note 3, 15, 0
	music_note 4, 12, 9
	music_off 3, 0
	music_off 4, 0
	music_note 3, 13, 0
	music_note 4, 14, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 15, 9
	music_off 3, 0
	music_note 3, 13, 0
	music_note 4, 19, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 15, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 4, 12, 8
	music_off 3, 1
	music_off 4, 1
	music_note 3, 15, 9
	music_note 2, 39, 0
	music_note 4, 12, 5
	music_off 3, 4
	music_off 4, 1
	music_note 3, 15, 0
	music_off 2, 8
	music_off 3, 1
	music_note 3, 18, 0
	music_note 4, 14, 8
	music_off 3, 1
	music_off 4, 1
	music_note 3, 15, 7
	music_off 3, 2
	music_note 3, 18, 0
	music_note 4, 13, 9
	music_off 4, 8
	music_off 3, 2
	music_note 3, 15, 0
	music_note 4, 12, 9
	music_off 4, 10
	music_note 4, 16, 6
	music_off 3, 3
	music_off 4, 0
	music_note 3, 15, 9
	music_off 3, 1
	music_note 3, 13, 0
	music_note 4, 14, 9
	music_off 3, 0
	music_off 4, 0
	music_note 3, 15, 9
	music_off 3, 1
	music_note 3, 13, 0
	music_note 4, 19, 8
	music_off 3, 0
	music_off 4, 1
	music_note 3, 15, 0
	music_note 4, 12, 9
	music_off 4, 1
	music_note 2, 39, 0
	music_note 4, 12, 7
	music_off 3, 1
	music_off 4, 0
	music_off 2, 1
	music_note 3, 15, 10
	music_note 4, 12, 4
	music_off 3, 4
	music_off 4, 1
	music_note 3, 15, 9
	music_off 3, 1
	music_note 2, 42, 0
	music_note 3, 13, 0
	music_note 4, 14, 7
	music_off 3, 1
	music_off 4, 1
	music_note 3, 15, 0
	music_note 4, 12, 3
	music_off 2, 5
	music_off 3, 1
	music_off 4, 1
	music_note 3, 20, 0
	music_note 4, 13, 8
	music_off 4, 1
	music_note 4, 12, 8
	music_off 3, 1
	music_off 4, 0
	music_note 1, 27, 0
	music_note 2, 39, 0
	music_note 3, 15, 0
	music_note 4, 12, 9
	music_off 2, 0
	music_off 4, 1
	music_note 4, 12, 9
	music_off 4, 0
	music_note 4, 16, 7
	music_off 3, 2
	music_off 4, 1
	music_note 3, 15, 0
	music_note 4, 12, 9
	music_off 3, 0
	music_off 4, 0
	music_note 3, 13, 0
	music_note 4, 14, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 15, 8
	music_off 3, 1
	music_note 3, 13, 0
	music_note 4, 19, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 15, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 4, 12, 8
	music_off 3, 1
	music_off 4, 1
	music_note 3, 15, 9
	music_note 2, 39, 0
	music_note 4, 12, 5
	music_off 3, 4
	music_off 4, 1
	music_note 3, 15, 0
	music_off 2, 4
	music_off 1, 4
	music_off 3, 1
	music_note 1, 27, 0
	music_note 3, 18, 0
	music_note 4, 14, 8
	music_off 3, 1
	music_off 4, 1
	music_note 3, 15, 7
	music_off 3, 1
	music_off 1, 1
	music_note 1, 30, 0
	music_note 3, 18, 0
	music_note 4, 13, 9
	music_off 4, 8
	music_off 3, 2
	music_note 3, 15, 0
	music_note 4, 12, 9
	music_off 4, 10
	music_note 2, 39, 0
	music_note 4, 16, 6
	music_off 3, 3
	music_off 4, 0
	music_note 3, 15, 1
	music_off 2, 8
	music_off 3, 1
	music_note 3, 13, 0
	music_note 4, 14, 9
	music_off 3, 0
	music_off 4, 0
	music_note 3, 15, 9
	music_off 3, 1
	music_note 2, 37, 0
	music_note 3, 13, 0
	music_note 4, 19, 8
	music_off 3, 0
	music_off 4, 1
	music_note 3, 15, 0
	music_note 4, 12, 2
	music_off 2, 7
	music_off 4, 1
	music_note 4, 12, 7
	music_off 3, 1
	music_off 4, 1
	music_note 3, 15, 10
	music_note 2, 37, 0
	music_note 4, 12, 4
	music_off 3, 4
	music_off 4, 1
	music_off 2, 0
	music_note 3, 15, 9
	music_off 3, 1
	music_note 2, 36, 0
	music_note 3, 13, 0
	music_note 4, 14, 7
	music_off 3, 1
	music_off 4, 1
	music_note 3, 15, 0
	music_note 4, 12, 3
	music_off 2, 5
	music_off 3, 1
	music_off 4, 1
	music_note 2, 36, 0
	music_note 3, 20, 0
	music_note 4, 13, 7
	music_off 2, 1
	music_off 4, 1
	music_note 4, 12, 8
	music_off 3, 1
	music_off 1, 0
	music_off 4, 0
	music_note 1, 27, 0
	music_note 2, 39, 0
	music_note 3, 15, 0
	music_note 4, 12, 9
	music_off 4, 1
	music_note 4, 12, 0
	music_off 2, 9
	music_off 4, 0
	music_note 4, 16, 7
	music_off 3, 2
	music_off 4, 1
	music_note 3, 15, 0
	music_note 4, 12, 9
	music_off 3, 0
	music_off 4, 0
	music_note 3, 13, 0
	music_note 4, 14, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 15, 8
	music_off 3, 1
	music_note 3, 13, 0
	music_note 4, 19, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 15, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 4, 12, 8
	music_off 3, 1
	music_off 4, 1
	music_note 3, 15, 9
	music_note 2, 39, 0
	music_note 4, 12, 5
	music_off 3, 4
	music_off 4, 1
	music_note 3, 15, 0
	music_off 2, 8
	music_off 3, 1
	music_note 3, 18, 0
	music_note 4, 14, 8
	music_off 3, 1
	music_off 4, 1
	music_note 3, 15, 7
	music_off 3, 1
	music_off 1, 1
	music_note 1, 25, 0
	music_note 3, 18, 0
	music_note 4, 13, 9
	music_off 1, 0
	music_off 4, 0
	music_note 1, 27, 8
	music_off 3, 1
	music_off 1, 1
	music_note 1, 24, 0
	music_note 3, 15, 0
	music_note 4, 12, 9
	music_off 4, 10
	music_note 4, 16, 6
	music_off 3, 3
	music_off 4, 0
	music_note 3, 15, 9
	music_off 3, 1
	music_note 3, 13, 0
	music_note 4, 14, 8
	music_off 3, 0
	music_off 4, 1
	music_note 3, 15, 9
	music_off 3, 1
	music_note 3, 13, 0
	music_note 4, 19, 8
	music_off 3, 0
	music_off 4, 1
	music_note 3, 15, 0
	music_note 4, 12, 9
	music_off 4, 1
	music_note 2, 39, 0
	music_note 4, 12, 7
	music_off 3, 1
	music_off 4, 0
	music_off 2, 1
	music_note 3, 15, 10
	music_note 4, 12, 4
	music_off 3, 4
	music_off 4, 1
	music_note 3, 15, 9
	music_off 3, 1
	music_note 2, 42, 0
	music_note 3, 13, 0
	music_note 4, 14, 7
	music_off 3, 1
	music_off 4, 1
	music_note 3, 15, 0
	music_note 4, 12, 3
	music_off 2, 5
	music_off 3, 1
	music_off 1, 0
	music_off 4, 0
	music_note 1, 25, 0
	music_note 3, 20, 0
	music_note 4, 13, 9
	music_off 1, 0
	music_off 4, 1
	music_note 1, 27, 0
	music_note 4, 12, 8
	music_off 3, 1
	music_off 1, 0
	music_off 4, 0
	music_note 1, 30, 0
	music_note 2, 39, 0
	music_note 3, 15, 0
	music_note 4, 12, 9
	music_off 2, 0
	music_off 4, 1
	music_note 4, 12, 8
	music_off 1, 1
	music_off 4, 0
	music_note 1, 27, 0
	music_note 4, 16, 7
	music_off 3, 2
	music_off 1, 0
	music_off 4, 1
	music_note 1, 30, 0
	music_note 3, 15, 0
	music_note 4, 12, 9
	music_off 1, 0
	music_off 3, 0
	music_off 4, 0
	music_note 1, 32, 0
	music_note 3, 13, 0
	music_note 4, 14, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 15, 8
	music_off 1, 0
	music_off 3, 1
	music_note 1, 30, 0
	music_note 3, 13, 0
	music_note 4, 19, 9
	music_off 1, 0
	music_off 3, 0
	music_off 4, 1
	music_note 1, 32, 0
	music_note 3, 15, 0
	music_note 4, 12, 8
	music_off 1, 0
	music_off 4, 1
	music_note 1, 34, 0
	music_note 4, 12, 8
	music_off 3, 1
	music_off 4, 1
	music_note 3, 15, 8
	music_off 1, 1
	music_note 1, 30, 0
	music_note 2, 39, 0
	music_note 4, 12, 5
	music_off 3, 4
	music_off 1, 0
	music_off 4, 1
	music_note 1, 32, 0
	music_note 3, 15, 0
	music_off 2, 8
	music_off 1, 0
	music_off 3, 1
	music_note 1, 34, 0
	music_note 3, 18, 0
	music_note 4, 14, 7
	music_off 1, 1
	music_off 3, 1
	music_off 4, 1
	music_note 1, 34, 0
	music_note 3, 15, 7
	music_off 3, 1
	music_off 1, 1
	music_note 1, 32, 0
	music_note 3, 18, 0
	music_note 4, 13, 9
	music_off 1, 0
	music_off 4, 0
	music_note 1, 34, 8
	music_off 3, 1
	music_off 1, 1
	music_note 1, 37, 0
	music_note 3, 15, 0
	music_note 4, 12, 9
	music_off 1, 0
	music_off 4, 0
	music_note 1, 32, 9
	music_off 1, 1
	music_note 1, 34, 0
	music_note 2, 39, 0
	music_note 4, 16, 6
	music_off 3, 3
	music_off 1, 0
	music_off 4, 0
	music_note 1, 39, 0
	music_note 3, 15, 0
	music_off 2, 9
	music_off 1, 0
	music_off 3, 1
	music_note 1, 34, 0
	music_note 3, 13, 0
	music_note 4, 14, 8
	music_off 1, 0
	music_off 3, 0
	music_off 4, 1
	music_note 1, 37, 0
	music_note 3, 15, 9
	music_off 1, 0
	music_off 3, 1
	music_note 1, 39, 0
	music_note 2, 37, 0
	music_note 3, 13, 0
	music_note 4, 19, 8
	music_off 1, 0
	music_off 3, 0
	music_off 4, 1
	music_note 1, 37, 0
	music_note 3, 15, 0
	music_note 4, 12, 2
	music_off 2, 7
	music_off 1, 0
	music_off 4, 1
	music_note 1, 39, 0
	music_note 4, 12, 7
	music_off 3, 1
	music_off 1, 0
	music_off 4, 1
	music_note 1, 42, 0
	music_note 3, 15, 9
	music_off 1, 1
	music_note 1, 39, 0
	music_note 4, 12, 4
	music_off 3, 4
	music_off 1, 0
	music_off 4, 1
	music_note 1, 42, 0
	music_note 3, 15, 9
	music_off 1, 1
	music_note 1, 44, 0
	music_note 2, 36, 0
	music_note 3, 13, 0
	music_note 4, 14, 8
	music_off 4, 1
	music_off 2, 0
	music_note 3, 15, 0
	music_note 4, 12, 8
	music_off 3, 1
	music_off 1, 0
	music_off 4, 0
	music_note 1, 39, 0
	music_note 3, 20, 0
	music_note 4, 13, 9
	music_off 1, 0
	music_off 4, 1
	music_note 1, 42, 0
	music_note 4, 12, 8
	music_off 3, 1
	music_off 1, 0
	music_off 4, 0
	music_note 1, 44, 0
	music_note 2, 39, 0
	music_note 3, 15, 0
	music_note 4, 12, 9
	music_off 4, 1
	music_off 2, 0
	music_note 4, 12, 9
	music_off 4, 0
	music_note 4, 16, 7
	music_off 3, 2
	music_off 4, 1
	music_note 3, 15, 0
	music_note 4, 12, 8
	music_off 3, 0
	music_off 4, 1
	music_note 3, 13, 0
	music_note 4, 14, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 15, 8
	music_off 3, 1
	music_note 3, 13, 0
	music_note 4, 19, 9
	music_off 3, 0
	music_off 4, 1
	music_note 3, 15, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_note 2, 37, 0
	music_note 4, 12, 8
	music_off 3, 1
	music_off 4, 1
	music_note 3, 15, 1
	music_off 2, 7
	music_off 1, 1
	music_note 1, 42, 0
	music_note 4, 12, 5
	music_off 3, 4
	music_off 1, 0
	music_off 4, 1
	music_note 1, 44, 0
	music_note 3, 15, 8
	music_off 1, 0
	music_off 3, 1
	music_note 1, 45, 0
	music_note 3, 18, 0
	music_note 4, 14, 8
	music_off 3, 1
	music_off 4, 0
	music_note 3, 15, 8
	music_off 3, 1
	music_off 1, 1
	music_note 1, 44, 0
	music_note 3, 18, 0
	music_note 4, 13, 9
	music_off 1, 0
	music_off 4, 0
	music_note 1, 42, 8
	music_off 3, 1
	music_off 1, 1
	music_note 1, 45, 0
	music_note 3, 15, 0
	music_note 4, 12, 9
	music_off 4, 9
	music_off 1, 1
	music_note 1, 44, 0
	music_note 2, 39, 0
	music_note 4, 16, 6
	music_off 3, 3
	music_off 1, 0
	music_off 4, 0
	music_note 1, 42, 0
	music_note 3, 15, 1
	music_off 2, 8
	music_off 1, 0
	music_off 3, 1
	music_note 1, 45, 0
	music_note 3, 13, 0
	music_note 4, 14, 8
	music_off 1, 0
	music_off 3, 0
	music_off 4, 1
	music_note 1, 44, 0
	music_note 3, 15, 9
	music_off 1, 0
	music_off 3, 1
	music_note 1, 42, 0
	music_note 3, 13, 0
	music_note 4, 19, 8
	music_off 1, 0
	music_off 3, 0
	music_off 4, 1
	music_note 1, 44, 0
	music_note 3, 15, 0
	music_note 4, 12, 9
	music_off 1, 0
	music_off 4, 1
	music_note 1, 42, 0
	music_note 2, 37, 0
	music_note 4, 12, 7
	music_off 3, 1
	music_off 1, 0
	music_off 4, 1
	music_note 1, 39, 0
	music_note 3, 15, 9
	music_off 2, 0
	music_off 1, 1
	music_note 1, 42, 0
	music_note 2, 39, 0
	music_note 4, 12, 4
	music_off 3, 4
	music_off 1, 0
	music_off 4, 1
	music_note 1, 37, 0
	music_note 3, 15, 3
	music_off 2, 6
	music_off 1, 0
	music_off 3, 1
	music_note 1, 39, 0
	music_note 3, 13, 0
	music_note 4, 14, 7
	music_off 3, 1
	music_off 4, 1
	music_note 3, 15, 0
	music_note 4, 12, 8
	music_off 3, 1
	music_off 1, 0
	music_off 4, 0
	music_note 1, 38, 0
	music_note 3, 20, 0
	music_note 4, 13, 4
	music_off 1, 1
	music_note 1, 39, 4
	music_off 4, 1
	music_note 4, 12, 8
	music_off 3, 1
	music_off 1, 0
	music_off 4, 0
	music_note 1, 37, 0
	music_note 2, 32, 0
	music_note 3, 25, 0
	music_note 4, 12, 9
	music_off 4, 16
	music_off 2, 1
	music_off 1, 0
	music_off 3, 3
	music_note 1, 38, 0
	music_note 2, 33, 0
	music_note 3, 26, 0
	music_note 4, 14, 8
	music_off 4, 15
	music_off 1, 0
	music_off 3, 0
	music_off 2, 5
	music_note 1, 39, 0
	music_note 2, 34, 0
	music_note 3, 27, 0
	music_note 4, 12, 9
	music_off 4, 1
	music_note 4, 12, 4
	music_off 1, 0
	music_off 3, 1
	music_off 2, 3
	music_off 4, 34
	music_note 4, 12, 4
	music_off 4, 1
	music_note 4, 14, 9
	music_off 4, 0
	music_note 4, 17, 9
	music_off 4, 0
	music_loop $FF, 0
	db $FE, $FF ; not reached by Music_HandleEvent

Music_09:
	music_instrument 2, INSTRUMENT_CH2_ALTERNATE, 0
	music_pan 2, $01, 0
	music_note 2, 4, 0
	music_pan 3, $10, 0
	music_note 3, 16, 0
	music_note 4, 12, 5
	music_off 2, 1
	music_off 3, 1
	music_off 4, 1
	music_note 2, 4, 0
	music_note 3, 16, 0
	music_note 4, 12, 6
	music_off 2, 1
	music_off 4, 1
	music_note 4, 13, 1
	music_off 3, 7
	music_off 4, 0
	music_note 2, 4, 0
	music_note 3, 16, 0
	music_note 4, 12, 5
	music_off 2, 1
	music_off 3, 2
	music_off 4, 1
	music_note 2, 4, 0
	music_note 3, 19, 0
	music_note 4, 14, 6
	music_off 2, 1
	music_off 4, 4
	music_off 3, 5
	music_note 2, 4, 0
	music_note 3, 19, 0
	music_note 4, 12, 6
	music_off 2, 1
	music_off 3, 1
	music_off 4, 1
	music_note 2, 4, 0
	music_note 3, 21, 0
	music_note 4, 14, 7
	music_off 2, 0
	music_off 4, 1
	music_note 4, 12, 3
	music_off 3, 5
	music_off 4, 0
	music_note 2, 4, 0
	music_note 3, 21, 0
	music_note 4, 14, 8
	music_off 2, 0
	music_off 4, 1
	music_note 4, 17, 2
	music_off 3, 5
	music_off 4, 1
	music_note 2, 4, 0
	music_note 3, 21, 0
	music_note 4, 12, 4
	music_off 2, 2
	music_off 3, 2
	music_off 4, 0
	music_note 2, 4, 0
	music_note 3, 23, 0
	music_note 4, 14, 7
	music_off 2, 1
	music_off 4, 3
	music_off 3, 6
	music_note 2, 4, 0
	music_note 3, 26, 0
	music_note 4, 20, 2
	music_pan 1, $01, 5
	music_off 2, 1
	music_off 4, 0
	music_note 4, 12, 4
	music_off 3, 4
	music_off 4, 1
	music_note 1, 39, 0
	music_note 2, 28, 0
	music_note 3, 28, 0
	music_note 4, 14, 3
	music_off 1, 1
	music_note 1, 40, 1
	music_off 2, 0
	music_off 3, 2
	music_off 4, 1
	music_note 2, 28, 0
	music_note 3, 28, 0
	music_note 4, 12, 8
	music_off 4, 3
	music_off 2, 0
	music_off 3, 6
	music_note 1, 38, 0
	music_note 2, 26, 0
	music_note 3, 26, 0
	music_note 4, 14, 4
	music_off 2, 0
	music_off 3, 3
	music_off 4, 1
	music_note 2, 26, 0
	music_note 3, 26, 0
	music_note 4, 12, 8
	music_off 4, 1
	music_off 2, 0
	music_off 3, 8
	music_note 1, 40, 0
	music_note 2, 28, 0
	music_note 3, 28, 0
	music_note 4, 14, 6
	music_off 2, 0
	music_off 3, 1
	music_off 4, 1
	music_note 2, 28, 0
	music_note 3, 28, 0
	music_note 4, 12, 5
	music_off 2, 0
	music_off 3, 3
	music_off 4, 8
	music_off 1, 0
	music_loop $FF, 0
	db $FE, $FF ; not reached by Music_HandleEvent
