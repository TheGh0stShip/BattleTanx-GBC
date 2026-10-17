; Object graphics banks $27-$29 (see BANKS_27_29_RESEARCH.md).
; Included by src/bank_27.asm-src/bank_29.asm; guarded so it can also be
; included from src/main.asm later without redefinition.
IF !DEF(OBJECT_BANKS_INC)
DEF OBJECT_BANKS_INC EQU 1

DEF ORIENTATION_FRAME_TILES EQU 9                 ; 3x3 tiles per frame
DEF ORIENTATION_FRAME_SIZE  EQU ORIENTATION_FRAME_TILES * 16
DEF ORIENTATION_FRAMES      EQU 9                 ; frames 0-8; orientations 9-15 reuse 7-1 x-flipped
DEF ORIENTATION_COUNT       EQU 16                ; entries in $05:ObjectOrientationTilePointers

; Nine orientation frames, sliced from the bank's tile asset.
MACRO orientation_frames ; asset path, label prefix
	FOR ORIENT_I, ORIENTATION_FRAMES
\2Frame{d:ORIENT_I}:
		INCBIN \1, ORIENT_I * ORIENTATION_FRAME_SIZE, ORIENTATION_FRAME_SIZE
	ENDR
ENDM

; Bytes $4518-$4BFB of banks $27-$29 are a byte-identical copy of bank $26
; at the same offsets (part of level 14's tile map). Nothing reads them.
DEF RESIDUE_START EQU $4518
DEF RESIDUE_END   EQU $4BFC
MACRO bank26_residue
	INCBIN "assets/levels/level_14/tilemap.bin", RESIDUE_START - $4000, RESIDUE_END - RESIDUE_START
ENDM

; Zero fill to the bank-number marker at $7FFF.
MACRO object_bank_end
	ds $7FFF - @, $00
	db BANK(@)
ENDM

ENDC
