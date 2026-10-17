; BattleTanx (USA) - ROM bank $27: object orientation graphics and palette.
; Layout and evidence: BANKS_27_29_RESEARCH.md.

INCLUDE "include/object_banks.inc"

SECTION "ROM Bank $27", ROMX[$4000], BANK[$27]

; Nine 3x3-tile orientation frames (2bpp, 144 bytes each). ROM0 Func_0F43
; maps bank [$FF80] + $27 and copies 9 tiles from
; $05:ObjectOrientationTilePointers[orientation].
Bank27OrientationTiles:
	orientation_frames "assets/bank_27/orientation_tiles.bin", Bank27Orientation

; One RGB555 word before the palette; nothing reads it (LoadObjectPalettes
; points at Bank27ObjectPalette and Func_057D writes $0000 as colour 0).
Bank27Unknown4510:
	dw $318C

; OBJ palette 0 colours 1-3, loaded by ROM0 LoadObjectPalettes.
Bank27ObjectPalette:
	dw $0040, $0260, $03E5

; Unreferenced copy of bank $26 $4518-$4BFB.
Bank27Bank26Residue:
	bank26_residue

	object_bank_end

	ASSERT Bank27Unknown4510 == $4000 + ORIENTATION_FRAMES * ORIENTATION_FRAME_SIZE
	ASSERT Bank27Bank26Residue == RESIDUE_START
