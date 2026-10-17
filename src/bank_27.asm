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

; Relocation pins (RELOCATION_AUDIT.md): these addresses are stored as raw
; numbers in banks outside this assignment, so moving them must stop the
; build until those tables use symbols.
	ASSERT BANK(Bank27OrientationFrame0) == $27 && Bank27OrientationFrame0 == $4000, "raw pointer: src/bank_05.asm ObjectOrientationTilePointers (raw $4000-$4480)"
	ASSERT BANK(Bank27OrientationFrame1) == $27 && Bank27OrientationFrame1 == $4090, "raw pointer: src/bank_05.asm ObjectOrientationTilePointers (raw $4000-$4480)"
	ASSERT BANK(Bank27OrientationFrame2) == $27 && Bank27OrientationFrame2 == $4120, "raw pointer: src/bank_05.asm ObjectOrientationTilePointers (raw $4000-$4480)"
	ASSERT BANK(Bank27OrientationFrame3) == $27 && Bank27OrientationFrame3 == $41B0, "raw pointer: src/bank_05.asm ObjectOrientationTilePointers (raw $4000-$4480)"
	ASSERT BANK(Bank27OrientationFrame4) == $27 && Bank27OrientationFrame4 == $4240, "raw pointer: src/bank_05.asm ObjectOrientationTilePointers (raw $4000-$4480)"
	ASSERT BANK(Bank27OrientationFrame5) == $27 && Bank27OrientationFrame5 == $42D0, "raw pointer: src/bank_05.asm ObjectOrientationTilePointers (raw $4000-$4480)"
	ASSERT BANK(Bank27OrientationFrame6) == $27 && Bank27OrientationFrame6 == $4360, "raw pointer: src/bank_05.asm ObjectOrientationTilePointers (raw $4000-$4480)"
	ASSERT BANK(Bank27OrientationFrame7) == $27 && Bank27OrientationFrame7 == $43F0, "raw pointer: src/bank_05.asm ObjectOrientationTilePointers (raw $4000-$4480)"
	ASSERT BANK(Bank27OrientationFrame8) == $27 && Bank27OrientationFrame8 == $4480, "raw pointer: src/bank_05.asm ObjectOrientationTilePointers (raw $4000-$4480)"
