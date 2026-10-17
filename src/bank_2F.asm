; BattleTanx (USA) - scrolling scene data bank $2F

SECTION "ROM Bank $2F", ROMX[$4000], BANK[$2F]

ScrollScene21Tiles:
	INCBIN "assets/scenes/scroll_scene_21_tiles.2bpp"
ASSERT @ == $4460

ScrollScene21Rows:
	dw $0001, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0003
	dw $0004, $0005, $0006, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $000D, $000E, $000F, $0010, $0011, $0012, $0006, $0006, $0013, $0014
	dw $0004, $0015, $0006, $0006, $0016, $0017, $0018, $0019, $001A, $001B, $001C, $001D, $001E, $001F, $0020, $0021, $0006, $0006, $0022, $0014
	dw $0004, $0023, $0024, $0006, $0025, $0026, $0027, $0028, $0029, $002A, $002B, $002C, $002D, $002E, $002F, $0030, $0006, $0006, $0031, $0032
	dw $0004, $0033, $0034, $0006, $0035, $0036, $0037, $0038, $0039, $003A, $003B, $003C, $003D, $003E, $003F, $0040, $0006, $0006, $0041, $0042
	dw $0043, $0044, $0044, $0044, $0044, $0044, $0044, $0044, $0044, $0044, $0044, $0044, $0044, $0044, $0044, $0044, $0044, $0044, $0044, $0045
ASSERT @ == $4550

ScrollScene21Palette:
	dw $1120, $0204, $270A, $63D9

ScrollScene22Tiles:
	INCBIN "assets/scenes/scroll_scene_22_tiles.2bpp"
ASSERT @ == $4998

ScrollScene22Rows:
	dw $0001, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0003
	dw $0004, $0005, $0006, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $000D, $000E, $000F, $0010, $0011, $0012, $0006, $0006, $0013, $0014
	dw $0004, $0015, $0006, $0006, $0016, $0017, $0018, $0019, $001A, $001B, $001C, $001D, $001E, $001F, $0020, $0021, $0006, $0006, $0022, $0014
	dw $0023, $0024, $0025, $0006, $0006, $0026, $0027, $0028, $0027, $0029, $002A, $002B, $002C, $002D, $002E, $0006, $0006, $0006, $002F, $0030
	dw $0031, $0032, $0033, $0006, $0006, $0034, $0035, $0036, $0037, $0038, $0039, $003A, $003B, $003C, $003D, $0006, $0006, $003E, $003F, $0040
	dw $0041, $0042, $0042, $0042, $0042, $0042, $0042, $0042, $0042, $0042, $0042, $0042, $0042, $0042, $0042, $0042, $0042, $0042, $0042, $0043
ASSERT @ == $4A88

ScrollScene22Palette:
	dw $1120, $0204, $270A, $63D9

ScrollScene23Tiles:
	INCBIN "assets/scenes/scroll_scene_23_tiles.2bpp"
ASSERT @ == $4EE0

ScrollScene23Rows:
	dw $0001, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0003
	dw $0004, $0005, $0006, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $000D, $000E, $000F, $0010, $0011, $0012, $0006, $0006, $0013, $0014
	dw $0004, $0015, $0006, $0006, $0016, $0017, $0018, $0019, $001A, $001B, $001C, $001D, $001E, $001F, $0020, $0021, $0006, $0006, $0022, $0014
	dw $0023, $0006, $0006, $0024, $0025, $0026, $0027, $0028, $0029, $002A, $002B, $002B, $002B, $002B, $002B, $002C, $002D, $0006, $002E, $0014
	dw $002F, $0030, $0006, $0031, $0032, $0033, $0034, $0035, $0036, $0037, $0038, $0039, $003A, $003B, $003C, $003D, $003E, $003F, $0040, $0014
	dw $0041, $0042, $0042, $0042, $0042, $0042, $0042, $0042, $0042, $0042, $0042, $0042, $0042, $0042, $0042, $0043, $0042, $0042, $0042, $0044
ASSERT @ == $4FD0

ScrollScene23Palette:
	dw $1120, $0204, $270A, $63D9

ScrollScene24Tiles:
	INCBIN "assets/scenes/scroll_scene_24_tiles.2bpp"
ASSERT @ == $54C8

ScrollScene24Rows:
	dw $0001, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0003
	dw $0004, $0005, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $000D, $000E, $000F, $0010, $0011, $0012, $0013, $0014, $0006, $0015, $0016
	dw $0004, $0017, $0006, $0018, $0019, $001A, $001B, $001C, $001D, $001E, $001F, $0020, $0021, $0022, $0023, $0024, $0025, $0006, $0026, $0016
	dw $0004, $0027, $0028, $0029, $002A, $002B, $002C, $002D, $002E, $002F, $0030, $0031, $0032, $0033, $0034, $0035, $0036, $0006, $0037, $0038
	dw $0004, $0039, $003A, $003B, $003C, $003D, $003E, $003F, $0040, $0041, $0042, $0043, $0044, $0045, $0046, $0047, $0048, $0006, $0049, $004A
	dw $004B, $004C, $004C, $004C, $004D, $004C, $004C, $004C, $004C, $004C, $004C, $004C, $004C, $004C, $004C, $004C, $004C, $004C, $004C, $004E
ASSERT @ == $55B8

ScrollScene24Palette:
	dw $1120, $0204, $270A, $63D9

ScrollScene25Tiles:
	INCBIN "assets/scenes/scroll_scene_25_tiles.2bpp"
ASSERT @ == $5A90

ScrollScene25Rows:
	dw $0001, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0003
	dw $0004, $0005, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $000D, $000E, $000F, $0010, $0011, $0012, $0013, $0014, $0006, $0015, $0016
	dw $0004, $0017, $0006, $0018, $0019, $001A, $001B, $001C, $001D, $001E, $001F, $0020, $0021, $0022, $0023, $0024, $0025, $0006, $0026, $0016
	dw $0027, $0028, $0029, $0006, $002A, $002B, $002C, $002D, $002E, $002F, $0030, $0031, $0032, $0033, $0034, $0035, $0006, $0006, $0036, $0037
	dw $0038, $0039, $003A, $0006, $003B, $003C, $003D, $003E, $003F, $0040, $0041, $0042, $0043, $0044, $0045, $0046, $0006, $0047, $0048, $0049
	dw $004A, $004B, $004B, $004B, $004B, $004B, $004B, $004B, $004B, $004B, $004B, $004B, $004B, $004B, $004B, $004B, $004B, $004B, $004B, $004C
ASSERT @ == $5B80

ScrollScene25Palette:
	dw $1120, $0204, $270A, $63D9

ScrollScene26Tiles:
	INCBIN "assets/scenes/scroll_scene_26_tiles.2bpp"
ASSERT @ == $5FD8

ScrollScene26Rows:
	dw $0001, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0003
	dw $0004, $0005, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $000D, $000E, $000F, $0010, $0011, $0012, $0013, $0014, $0006, $0015, $0016
	dw $0004, $0017, $0006, $0018, $0019, $001A, $001B, $001C, $001D, $001E, $001F, $0020, $0021, $0022, $0023, $0024, $0025, $0006, $0026, $0016
	dw $0027, $0006, $0006, $0006, $0006, $0028, $0029, $002A, $002A, $002B, $002C, $002D, $002E, $002F, $0030, $0006, $0006, $0006, $0031, $0016
	dw $0032, $0033, $0006, $0006, $0006, $0034, $0035, $0036, $0037, $0038, $0039, $003A, $003B, $003C, $003D, $0006, $0006, $003E, $003F, $0016
	dw $0040, $0041, $0041, $0041, $0041, $0042, $0043, $0041, $0041, $0041, $0041, $0041, $0041, $0041, $0041, $0041, $0041, $0041, $0041, $0044
ASSERT @ == $60C8

ScrollScene26Palette:
	dw $1120, $0204, $270A, $63D9

ScrollScene27Tiles:
	INCBIN "assets/scenes/scroll_scene_27_tiles.2bpp"
ASSERT @ == $6520

ScrollScene27Rows:
	dw $0001, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0003
	dw $0004, $0005, $0006, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $000D, $000E, $000F, $0010, $0011, $0012, $0006, $0006, $0013, $0014
	dw $0004, $0015, $0006, $0006, $0016, $0017, $0018, $0019, $001A, $001B, $001C, $001D, $001E, $001F, $0020, $0021, $0006, $0006, $0022, $0014
	dw $0004, $0023, $0024, $0006, $0025, $0025, $0026, $0027, $0028, $0029, $002A, $002B, $002C, $002D, $002E, $002F, $0006, $0006, $0030, $0031
	dw $0004, $0032, $0033, $0006, $0034, $0035, $0036, $0037, $0038, $0039, $003A, $003B, $003C, $003D, $003E, $003F, $0006, $0006, $0040, $0041
	dw $0042, $0043, $0043, $0043, $0043, $0043, $0043, $0043, $0043, $0043, $0043, $0043, $0043, $0043, $0043, $0043, $0043, $0043, $0043, $0044
ASSERT @ == $6610

ScrollScene27Palette:
	dw $1120, $0204, $270A, $63D9

ScrollScene28Tiles:
	INCBIN "assets/scenes/scroll_scene_28_tiles.2bpp"
ASSERT @ == $6A28

ScrollScene28Rows:
	dw $0001, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0003
	dw $0004, $0005, $0006, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $000D, $000E, $000F, $0010, $0011, $0012, $0006, $0006, $0013, $0014
	dw $0004, $0015, $0006, $0006, $0016, $0017, $0018, $0019, $001A, $001B, $001C, $001D, $001E, $001F, $0020, $0021, $0006, $0006, $0022, $0014
	dw $0023, $0024, $0025, $0006, $0006, $0006, $0026, $0027, $0028, $0029, $002A, $002B, $002C, $002D, $0006, $0006, $0006, $0006, $002E, $002F
	dw $0030, $0031, $0032, $0006, $0006, $0006, $0033, $0034, $0035, $0036, $0037, $0038, $0039, $003A, $0006, $0006, $0006, $003B, $003C, $003D
	dw $003E, $003F, $003F, $003F, $003F, $003F, $003F, $003F, $003F, $003F, $003F, $003F, $003F, $003F, $003F, $003F, $003F, $003F, $003F, $0040
ASSERT @ == $6B18

ScrollScene28Palette:
	dw $1120, $0204, $270A, $63D9

ScrollScene29Tiles:
	INCBIN "assets/scenes/scroll_scene_29_tiles.2bpp"
ASSERT @ == $6F40

ScrollScene29Rows:
	dw $0001, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0003
	dw $0004, $0005, $0006, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $000D, $000E, $000F, $0010, $0011, $0012, $0006, $0006, $0013, $0014
	dw $0004, $0015, $0006, $0006, $0016, $0017, $0018, $0019, $001A, $001B, $001C, $001D, $001E, $001F, $0020, $0021, $0006, $0006, $0022, $0014
	dw $0023, $0006, $0006, $0006, $0024, $0025, $0026, $0027, $0028, $0029, $0006, $002A, $002B, $002C, $002D, $0006, $0006, $0006, $002E, $0014
	dw $002F, $0030, $0006, $0006, $0031, $0032, $0033, $0034, $0035, $0036, $0006, $0037, $0038, $0039, $003A, $003B, $0006, $003C, $003D, $0014
	dw $003E, $003F, $003F, $003F, $003F, $003F, $003F, $003F, $003F, $003F, $003F, $0040, $003F, $003F, $003F, $003F, $003F, $003F, $003F, $0041
ASSERT @ == $7030

ScrollScene29Palette:
	dw $1120, $0204, $270A, $63D9

ScrollScene30Tiles:
	INCBIN "assets/scenes/scroll_scene_30_tiles.2bpp"
ASSERT @ == $7438

ScrollScene30Rows:
	dw $0001, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0003
	dw $0004, $0005, $0006, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $000D, $000E, $000F, $0010, $0011, $0012, $0006, $0006, $0013, $0014
	dw $0004, $0015, $0006, $0006, $0016, $0017, $0018, $0019, $001A, $001B, $001C, $001D, $001E, $001F, $0020, $0021, $0006, $0006, $0022, $0014
	dw $0004, $0023, $0024, $0006, $0006, $0025, $0026, $0027, $0028, $0029, $002A, $002B, $0026, $002C, $002D, $0006, $0006, $0006, $002E, $002F
	dw $0004, $0030, $0031, $0006, $0006, $0032, $0033, $0034, $0035, $0036, $0037, $0038, $0033, $0039, $003A, $0006, $0006, $0006, $003B, $003C
	dw $003D, $003E, $003E, $003E, $003E, $003E, $003E, $003E, $003E, $003E, $003E, $003E, $003E, $003E, $003E, $003E, $003E, $003E, $003E, $003F
ASSERT @ == $7528

ScrollScene30Palette:
	dw $1120, $0204, $270A, $63D9

ScrollScene31Tiles:
	INCBIN "assets/scenes/scroll_scene_31_tiles.2bpp"
ASSERT @ == $79F0

ScrollScene31Rows:
	dw $0001, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0003
	dw $0004, $0005, $0006, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $000D, $000E, $000F, $0010, $0011, $0012, $0006, $0006, $0013, $0014
	dw $0004, $0015, $0006, $0006, $0016, $0017, $0018, $0019, $001A, $001B, $001C, $001D, $001E, $001F, $0020, $0021, $0006, $0006, $0022, $0014
	dw $0023, $0024, $0025, $0026, $0027, $0028, $0029, $002A, $0028, $002B, $002C, $002D, $002E, $002F, $0030, $0031, $0032, $0033, $0034, $0035
	dw $0036, $0037, $0038, $0039, $003A, $003B, $003C, $003D, $003A, $003E, $003F, $0040, $0041, $0042, $0043, $0044, $0045, $0046, $0047, $0048
	dw $0049, $004A, $004A, $004A, $004A, $004A, $004A, $004A, $004A, $004A, $004A, $004A, $004A, $004A, $004A, $004A, $004A, $004A, $004A, $004B
ASSERT @ == $7AE0

ScrollScene31Palette:
	dw $1120, $0204, $270A, $63D9

	ds $7FFF - @, 0
	db BANK(@) ; bank marker
ASSERT @ == $8000

; Relocation pins (RELOCATION_AUDIT.md): these addresses are stored as raw
; numbers in banks outside this assignment, so moving them must stop the
; build until those tables use symbols.
	ASSERT BANK(ScrollScene21Tiles) == $2F && ScrollScene21Tiles == $4000, "raw pointer: src/bank_01.asm:3841"
	ASSERT BANK(ScrollScene21Rows) == $2F && ScrollScene21Rows == $4460, "raw pointer: src/bank_01.asm:3841"
	ASSERT BANK(ScrollScene21Palette) == $2F && ScrollScene21Palette == $4550, "raw pointer: src/bank_01.asm:3843"
	ASSERT BANK(ScrollScene22Tiles) == $2F && ScrollScene22Tiles == $4558, "raw pointer: src/bank_01.asm:3845"
	ASSERT BANK(ScrollScene22Rows) == $2F && ScrollScene22Rows == $4998, "raw pointer: src/bank_01.asm:3845"
	ASSERT BANK(ScrollScene22Palette) == $2F && ScrollScene22Palette == $4A88, "raw pointer: src/bank_01.asm:3847"
	ASSERT BANK(ScrollScene23Tiles) == $2F && ScrollScene23Tiles == $4A90, "raw pointer: src/bank_01.asm:3849"
	ASSERT BANK(ScrollScene23Rows) == $2F && ScrollScene23Rows == $4EE0, "raw pointer: src/bank_01.asm:3849"
	ASSERT BANK(ScrollScene23Palette) == $2F && ScrollScene23Palette == $4FD0, "raw pointer: src/bank_01.asm:3851"
	ASSERT BANK(ScrollScene24Tiles) == $2F && ScrollScene24Tiles == $4FD8, "raw pointer: src/bank_01.asm:3853"
	ASSERT BANK(ScrollScene24Rows) == $2F && ScrollScene24Rows == $54C8, "raw pointer: src/bank_01.asm:3853"
	ASSERT BANK(ScrollScene24Palette) == $2F && ScrollScene24Palette == $55B8, "raw pointer: src/bank_01.asm:3855"
	ASSERT BANK(ScrollScene25Tiles) == $2F && ScrollScene25Tiles == $55C0, "raw pointer: src/bank_01.asm:3857"
	ASSERT BANK(ScrollScene25Rows) == $2F && ScrollScene25Rows == $5A90, "raw pointer: src/bank_01.asm:3857"
	ASSERT BANK(ScrollScene25Palette) == $2F && ScrollScene25Palette == $5B80, "raw pointer: src/bank_01.asm:3859"
	ASSERT BANK(ScrollScene26Tiles) == $2F && ScrollScene26Tiles == $5B88, "raw pointer: src/bank_01.asm:3861"
	ASSERT BANK(ScrollScene26Rows) == $2F && ScrollScene26Rows == $5FD8, "raw pointer: src/bank_01.asm:3861"
	ASSERT BANK(ScrollScene26Palette) == $2F && ScrollScene26Palette == $60C8, "raw pointer: src/bank_01.asm:3863"
	ASSERT BANK(ScrollScene27Tiles) == $2F && ScrollScene27Tiles == $60D0, "raw pointer: src/bank_01.asm:3865"
	ASSERT BANK(ScrollScene27Rows) == $2F && ScrollScene27Rows == $6520, "raw pointer: src/bank_01.asm:3865"
	ASSERT BANK(ScrollScene27Palette) == $2F && ScrollScene27Palette == $6610, "raw pointer: src/bank_01.asm:3867"
	ASSERT BANK(ScrollScene28Tiles) == $2F && ScrollScene28Tiles == $6618, "raw pointer: src/bank_01.asm:3869"
	ASSERT BANK(ScrollScene28Rows) == $2F && ScrollScene28Rows == $6A28, "raw pointer: src/bank_01.asm:3869"
	ASSERT BANK(ScrollScene28Palette) == $2F && ScrollScene28Palette == $6B18, "raw pointer: src/bank_01.asm:3871"
	ASSERT BANK(ScrollScene29Tiles) == $2F && ScrollScene29Tiles == $6B20, "raw pointer: src/bank_01.asm:3873"
	ASSERT BANK(ScrollScene29Rows) == $2F && ScrollScene29Rows == $6F40, "raw pointer: src/bank_01.asm:3873"
	ASSERT BANK(ScrollScene29Palette) == $2F && ScrollScene29Palette == $7030, "raw pointer: src/bank_01.asm:3875"
	ASSERT BANK(ScrollScene30Tiles) == $2F && ScrollScene30Tiles == $7038, "raw pointer: src/bank_01.asm:3877"
	ASSERT BANK(ScrollScene30Rows) == $2F && ScrollScene30Rows == $7438, "raw pointer: src/bank_01.asm:3877"
	ASSERT BANK(ScrollScene30Palette) == $2F && ScrollScene30Palette == $7528, "raw pointer: src/bank_01.asm:3879"
	ASSERT BANK(ScrollScene31Tiles) == $2F && ScrollScene31Tiles == $7530, "raw pointer: src/bank_01.asm:3881"
	ASSERT BANK(ScrollScene31Rows) == $2F && ScrollScene31Rows == $79F0, "raw pointer: src/bank_01.asm:3881"
	ASSERT BANK(ScrollScene31Palette) == $2F && ScrollScene31Palette == $7AE0, "raw pointer: src/bank_01.asm:3883"
