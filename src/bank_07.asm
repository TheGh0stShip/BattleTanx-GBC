; BattleTanx (USA) - ROM bank $07: unused partial copy of bank $06.

SECTION "ROM Bank $07", ROMX[$4000], BANK[$07]

; No reader or structure is known for this seven-byte prefix.
Bank07UnknownPrefix:
	db $0C, $00, $65, $00, $44, $62, $65

; Byte-identical to bank $06:$4007-$4BFB. No traced path selects bank $07.
Bank07AudioBuildResidue:
	INCBIN "assets/bank_07/audio_build_residue.bin"
ASSERT @ == $4BFC

	ds $7FFF - @, 0
	db $07 ; bank marker
ASSERT @ == $8000
