; BattleTanx (USA) - ROM bank $28: object orientation graphics and palette.
; Layout and evidence: BANKS_27_29_RESEARCH.md.

INCLUDE "include/object_banks.inc"

SECTION "ROM Bank $28", ROMX[$4000], BANK[$28]

; Nine 3x3-tile orientation frames (2bpp, 144 bytes each). ROM0 Func_0F43
; maps bank [$FF80] + $27 and copies 9 tiles from
; $05:ObjectOrientationTilePointers[orientation].
Bank28OrientationTiles:
	orientation_frames "assets/bank_28/orientation_tiles.bin", Bank28Orientation

; One RGB555 word before the palette; nothing reads it (LoadObjectPalettes
; points at Bank28ObjectPalette and Func_057D writes $0000 as colour 0).
Bank28Unknown4510:
	dw $6739

; OBJ palette 1 colours 1-3, loaded by ROM0 LoadObjectPalettes.
Bank28ObjectPalette:
	dw $7E51, $0000, $60E8

; Unreferenced copy of bank $26 $4518-$4BFB.
Bank28Bank26Residue:
	bank26_residue

	object_bank_end

	ASSERT Bank28Unknown4510 == $4000 + ORIENTATION_FRAMES * ORIENTATION_FRAME_SIZE
	ASSERT Bank28Bank26Residue == RESIDUE_START
