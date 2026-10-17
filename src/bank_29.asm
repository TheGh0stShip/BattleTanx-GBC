; BattleTanx (USA) - ROM bank $29: object orientation graphics and palette.
; Layout and evidence: BANKS_27_29_RESEARCH.md.

INCLUDE "include/object_banks.inc"

SECTION "ROM Bank $29", ROMX[$4000], BANK[$29]

; Nine 3x3-tile orientation frames (2bpp, 144 bytes each). ROM0 Func_0F43
; maps bank [$FF80] + $27 and copies 9 tiles from
; $05:ObjectOrientationTilePointers[orientation].
Bank29OrientationTiles:
	orientation_frames "assets/bank_29/orientation_tiles.bin", Bank29Orientation

; One RGB555 word before the palette; nothing reads it (LoadObjectPalettes
; points at Bank29ObjectPalette and Func_057D writes $0000 as colour 0).
Bank29Unknown4510:
	dw $6739

; OBJ palette 2 colours 1-3, loaded by ROM0 LoadObjectPalettes.
Bank29ObjectPalette:
	dw $0006, $1CFF, $52BF

; Unreferenced copy of bank $26 $4518-$4BFB.
Bank29Bank26Residue:
	bank26_residue

	object_bank_end

	ASSERT Bank29Unknown4510 == $4000 + ORIENTATION_FRAMES * ORIENTATION_FRAME_SIZE
	ASSERT Bank29Bank26Residue == RESIDUE_START

; Relocation pins (RELOCATION_AUDIT.md): these addresses are stored as raw
; numbers in banks outside this assignment, so moving them must stop the
; build until those tables use symbols.
	ASSERT BANK(Bank29OrientationFrame0) == $29 && Bank29OrientationFrame0 == $4000, "raw pointer: src/bank_05.asm ObjectOrientationTilePointers (raw $4000-$4480)"
	ASSERT BANK(Bank29OrientationFrame1) == $29 && Bank29OrientationFrame1 == $4090, "raw pointer: src/bank_05.asm ObjectOrientationTilePointers (raw $4000-$4480)"
	ASSERT BANK(Bank29OrientationFrame2) == $29 && Bank29OrientationFrame2 == $4120, "raw pointer: src/bank_05.asm ObjectOrientationTilePointers (raw $4000-$4480)"
	ASSERT BANK(Bank29OrientationFrame3) == $29 && Bank29OrientationFrame3 == $41B0, "raw pointer: src/bank_05.asm ObjectOrientationTilePointers (raw $4000-$4480)"
	ASSERT BANK(Bank29OrientationFrame4) == $29 && Bank29OrientationFrame4 == $4240, "raw pointer: src/bank_05.asm ObjectOrientationTilePointers (raw $4000-$4480)"
	ASSERT BANK(Bank29OrientationFrame5) == $29 && Bank29OrientationFrame5 == $42D0, "raw pointer: src/bank_05.asm ObjectOrientationTilePointers (raw $4000-$4480)"
	ASSERT BANK(Bank29OrientationFrame6) == $29 && Bank29OrientationFrame6 == $4360, "raw pointer: src/bank_05.asm ObjectOrientationTilePointers (raw $4000-$4480)"
	ASSERT BANK(Bank29OrientationFrame7) == $29 && Bank29OrientationFrame7 == $43F0, "raw pointer: src/bank_05.asm ObjectOrientationTilePointers (raw $4000-$4480)"
	ASSERT BANK(Bank29OrientationFrame8) == $29 && Bank29OrientationFrame8 == $4480, "raw pointer: src/bank_05.asm ObjectOrientationTilePointers (raw $4000-$4480)"
	ASSERT BANK(Bank29OrientationTiles) == BANK(Bank28OrientationTiles) + 1, "Func_0F43 selects bank $27 + [$FF80]"
