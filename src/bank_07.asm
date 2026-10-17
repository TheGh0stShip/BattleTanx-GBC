; BattleTanx (USA) - ROM bank $07: unused partial copy of bank $06.

SECTION "ROM Bank $07", ROMX[$4000], BANK[$07]

; This occupies sound-patch slot 0 before the byte-identical copy of bank $06
; begins at patch slot 1. Channel $0C is invalid for the bank-$06 driver, so
; this is a malformed build leftover rather than a playable patch.
Bank07MalformedSoundPatch00:
	db $0C, $00, $65, $00, $44, $62, $65, $00
ASSERT @ - Bank07MalformedSoundPatch00 == 8

; Byte-identical to bank $06:$4008-$4BFB. The source asset begins at $4007;
; its first byte was emitted explicitly above to complete the malformed slot.
; No traced path selects bank $07.
Bank07AudioBuildResidue:
	INCBIN "assets/bank_07/audio_build_residue.bin", 1
ASSERT @ == $4BFC

	ds $7FFF - @, 0
	db $07 ; bank marker
ASSERT @ == $8000
