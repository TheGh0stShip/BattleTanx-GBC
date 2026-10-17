; BattleTanx (USA) - ROM bank $05

MACRO object_velocity ; X, Y (signed 32-bit, 1/256 px per frame)
	dl \1, \2
ENDM

SECTION "ROM Bank $05", ROMX[$4000], BANK[$05]
ObjectOrientationLayoutPointers:
	dw ObjectLayoutNormal, ObjectLayoutNormal, ObjectLayoutNormal, ObjectLayoutNormal
	dw ObjectLayoutNormal, ObjectLayoutNormal, ObjectLayoutNormal, ObjectLayoutNormal
	dw ObjectLayoutNormal
	dw ObjectLayoutXFlipped, ObjectLayoutXFlipped, ObjectLayoutXFlipped
	dw ObjectLayoutXFlipped, ObjectLayoutXFlipped, ObjectLayoutXFlipped, ObjectLayoutXFlipped

ObjectOrientationTilePointers:
; Offsets into the object bank selected at run time ($27 + [$FF80]); banks $27-$29
; share one layout (pinned in each bank), so bank $27's frame labels give the offsets.
	dw Bank27OrientationFrame0, Bank27OrientationFrame1, Bank27OrientationFrame2, Bank27OrientationFrame3, Bank27OrientationFrame4, Bank27OrientationFrame5, Bank27OrientationFrame6, Bank27OrientationFrame7
	dw Bank27OrientationFrame8, Bank27OrientationFrame7, Bank27OrientationFrame6, Bank27OrientationFrame5, Bank27OrientationFrame4, Bank27OrientationFrame3, Bank27OrientationFrame2, Bank27OrientationFrame1

ObjectLayoutNormal:
	db $F4, $F4, $00, $00, $F4, $FC, $01, $00, $F4, $04, $02, $00, $FC, $F4, $03, $00
	db $FC, $FC, $04, $00, $FC, $04, $05, $00, $04, $F4, $06, $00, $04, $FC, $07, $00
	db $04, $04, $08, $00

ObjectLayoutXFlipped:
	db $F4, $04, $00, $20, $F4, $FC, $01, $20, $F4, $F4, $02, $20
	db $FC, $04, $03, $20, $FC, $FC, $04, $20, $FC, $F4, $05, $20, $04, $04, $06, $20
	db $04, $FC, $07, $20, $04, $F4, $08, $20

LoadLevelLookupPointers:
	ld hl, LevelTileAnimationPointers
	ld a, [wLevelNumber]
	add a, a
	ld c, a
	ld b, $00
	add hl, bc
	ld a, [hli]
	ld [wLevelTileAnimationTable], a
	ld a, [hli]
	ld [wLevelTileAnimationTable + 1], a
	ld hl, LevelAttributeLookupPointers
	ld a, c
	add a, a
	ld c, a
	ld b, $00
	add hl, bc
	ld a, [hli]
	ld [wLevelAttributeLookup], a
	ld a, [hli]
	ld [wLevelAttributeLookup + 1], a
	ld a, [hl]
	ld [wLevelAttributeLookupBank], a
	ret

Bank05Bank04Copy40B1: ; unused byte-identical fragment of bank $04 level-object spawn records
	bank05_bank04_copy_40b1

LevelRecordPointers:
	dw Level00_Record, Level01_Record, Level02_Record, Level03_Record, Level04_Record
	dw Level05_Record, Level06_Record, Level07_Record, Level08_Record, Level09_Record
	dw Level10_Record, Level11_Record, Level12_Record, Level13_Record, Level14_Record

Bank05Bank04Copy431E: ; unused byte-identical fragment of bank $04 level-object spawn records
	bank05_bank04_copy_431e

Level00_Record:
	level_record LEVEL00_WIDTH, LEVEL00_HEIGHT, Level00_Tiles, Level00_BGPalettes, Level00_CellMap, Level00_TileMap, Level00_AttrMap, LEVEL00_TILE_COUNT, LEVEL00_PALETTE_COUNT
Level01_Record:
	level_record LEVEL01_WIDTH, LEVEL01_HEIGHT, Level01_Tiles, Level01_BGPalettes, Level01_CellMap, Level01_TileMap, Level01_AttrMap, LEVEL01_TILE_COUNT, LEVEL01_PALETTE_COUNT
Level02_Record:
	level_record LEVEL02_WIDTH, LEVEL02_HEIGHT, Level02_Tiles, Level02_BGPalettes, Level02_CellMap, Level02_TileMap, Level02_AttrMap, LEVEL02_TILE_COUNT, LEVEL02_PALETTE_COUNT
Level03_Record:
	level_record LEVEL03_WIDTH, LEVEL03_HEIGHT, Level03_Tiles, Level03_BGPalettes, Level03_CellMap, Level03_TileMap, Level03_AttrMap, LEVEL03_TILE_COUNT, LEVEL03_PALETTE_COUNT
Level04_Record:
	level_record LEVEL04_WIDTH, LEVEL04_HEIGHT, Level04_Tiles, Level04_BGPalettes, Level04_CellMap, Level04_TileMap, Level04_AttrMap, LEVEL04_TILE_COUNT, LEVEL04_PALETTE_COUNT
Level05_Record:
	level_record LEVEL05_WIDTH, LEVEL05_HEIGHT, Level05_Tiles, Level05_BGPalettes, Level05_CellMap, Level05_TileMap, Level05_AttrMap, LEVEL05_TILE_COUNT, LEVEL05_PALETTE_COUNT
Level06_Record:
	level_record LEVEL06_WIDTH, LEVEL06_HEIGHT, Level06_Tiles, Level06_BGPalettes, Level06_CellMap, Level06_TileMap, Level06_AttrMap, LEVEL06_TILE_COUNT, LEVEL06_PALETTE_COUNT
Level07_Record:
	level_record LEVEL07_WIDTH, LEVEL07_HEIGHT, Level07_Tiles, Level07_BGPalettes, Level07_CellMap, Level07_TileMap, Level07_AttrMap, LEVEL07_TILE_COUNT, LEVEL07_PALETTE_COUNT
Level08_Record:
	level_record LEVEL08_WIDTH, LEVEL08_HEIGHT, Level08_Tiles, Level08_BGPalettes, Level08_CellMap, Level08_TileMap, Level08_AttrMap, LEVEL08_TILE_COUNT, LEVEL08_PALETTE_COUNT
Level09_Record:
	level_record LEVEL09_WIDTH, LEVEL09_HEIGHT, Level09_Tiles, Level09_BGPalettes, Level09_CellMap, Level09_TileMap, Level09_AttrMap, LEVEL09_TILE_COUNT, LEVEL09_PALETTE_COUNT
Level10_Record:
	level_record LEVEL10_WIDTH, LEVEL10_HEIGHT, Level10_Tiles, Level10_BGPalettes, Level10_CellMap, Level10_TileMap, Level10_AttrMap, LEVEL10_TILE_COUNT, LEVEL10_PALETTE_COUNT
Level11_Record:
	level_record LEVEL11_WIDTH, LEVEL11_HEIGHT, Level11_Tiles, Level11_BGPalettes, Level11_CellMap, Level11_TileMap, Level11_AttrMap, LEVEL11_TILE_COUNT, LEVEL11_PALETTE_COUNT
Level12_Record:
	level_record LEVEL12_WIDTH, LEVEL12_HEIGHT, Level12_Tiles, Level12_BGPalettes, Level12_CellMap, Level12_TileMap, Level12_AttrMap, LEVEL12_TILE_COUNT, LEVEL12_PALETTE_COUNT
Level13_Record:
	level_record LEVEL13_WIDTH, LEVEL13_HEIGHT, Level13_Tiles, Level13_BGPalettes, Level13_CellMap, Level13_TileMap, Level13_AttrMap, LEVEL13_TILE_COUNT, LEVEL13_PALETTE_COUNT
Level14_Record:
	level_record LEVEL14_WIDTH, LEVEL14_HEIGHT, Level14_Tiles, Level14_BGPalettes, Level14_CellMap, Level14_TileMap, Level14_AttrMap, LEVEL14_TILE_COUNT, LEVEL14_PALETTE_COUNT

Bank05Bank04Copy452C: ; unused byte-identical fragment of bank $04 level-object spawn records
	bank05_bank04_copy_452c

ObjectVelocityTable: ; 16 speed classes x 16 directions; X then Y, signed 32-bit, 1/256 px per frame
; Read by ROM0 Func_2241/Func_2295 (class = object +$1A, direction = object +$19).
; Magnitude = (class + 1) * $60; direction 0 = -Y, 4 = +X, 8 = +Y, 12 = -X.
; ObjectTypeParameterTable caps the class index at 14, so class 15 is never selected.
	; speed class 0
	object_velocity 0, -96 ; direction 0
	object_velocity 37, -89 ; direction 1
	object_velocity 68, -68 ; direction 2
	object_velocity 89, -37 ; direction 3
	object_velocity 96, 0 ; direction 4
	object_velocity 89, 37 ; direction 5
	object_velocity 68, 68 ; direction 6
	object_velocity 37, 89 ; direction 7
	object_velocity 0, 96 ; direction 8
	object_velocity -37, 89 ; direction 9
	object_velocity -68, 68 ; direction 10
	object_velocity -89, 37 ; direction 11
	object_velocity -96, 0 ; direction 12
	object_velocity -89, -37 ; direction 13
	object_velocity -68, -68 ; direction 14
	object_velocity -37, -89 ; direction 15
	; speed class 1
	object_velocity 0, -192 ; direction 0
	object_velocity 73, -177 ; direction 1
	object_velocity 136, -136 ; direction 2
	object_velocity 177, -73 ; direction 3
	object_velocity 192, 0 ; direction 4
	object_velocity 177, 73 ; direction 5
	object_velocity 136, 136 ; direction 6
	object_velocity 73, 177 ; direction 7
	object_velocity 0, 192 ; direction 8
	object_velocity -73, 177 ; direction 9
	object_velocity -136, 136 ; direction 10
	object_velocity -177, 73 ; direction 11
	object_velocity -192, 0 ; direction 12
	object_velocity -177, -73 ; direction 13
	object_velocity -136, -136 ; direction 14
	object_velocity -73, -177 ; direction 15
	; speed class 2
	object_velocity 0, -288 ; direction 0
	object_velocity 110, -266 ; direction 1
	object_velocity 204, -204 ; direction 2
	object_velocity 266, -110 ; direction 3
	object_velocity 288, 0 ; direction 4
	object_velocity 266, 110 ; direction 5
	object_velocity 204, 204 ; direction 6
	object_velocity 110, 266 ; direction 7
	object_velocity 0, 288 ; direction 8
	object_velocity -110, 266 ; direction 9
	object_velocity -204, 204 ; direction 10
	object_velocity -266, 110 ; direction 11
	object_velocity -288, 0 ; direction 12
	object_velocity -266, -110 ; direction 13
	object_velocity -204, -204 ; direction 14
	object_velocity -110, -266 ; direction 15
	; speed class 3
	object_velocity 0, -384 ; direction 0
	object_velocity 147, -355 ; direction 1
	object_velocity 272, -272 ; direction 2
	object_velocity 355, -147 ; direction 3
	object_velocity 384, 0 ; direction 4
	object_velocity 355, 147 ; direction 5
	object_velocity 272, 272 ; direction 6
	object_velocity 147, 355 ; direction 7
	object_velocity 0, 384 ; direction 8
	object_velocity -147, 355 ; direction 9
	object_velocity -272, 272 ; direction 10
	object_velocity -355, 147 ; direction 11
	object_velocity -384, 0 ; direction 12
	object_velocity -355, -147 ; direction 13
	object_velocity -272, -272 ; direction 14
	object_velocity -147, -355 ; direction 15
	; speed class 4
	object_velocity 0, -480 ; direction 0
	object_velocity 184, -443 ; direction 1
	object_velocity 339, -339 ; direction 2
	object_velocity 443, -184 ; direction 3
	object_velocity 480, 0 ; direction 4
	object_velocity 443, 184 ; direction 5
	object_velocity 339, 339 ; direction 6
	object_velocity 184, 443 ; direction 7
	object_velocity 0, 480 ; direction 8
	object_velocity -184, 443 ; direction 9
	object_velocity -339, 339 ; direction 10
	object_velocity -443, 184 ; direction 11
	object_velocity -480, 0 ; direction 12
	object_velocity -443, -184 ; direction 13
	object_velocity -339, -339 ; direction 14
	object_velocity -184, -443 ; direction 15
	; speed class 5
	object_velocity 0, -576 ; direction 0
	object_velocity 220, -532 ; direction 1
	object_velocity 407, -407 ; direction 2
	object_velocity 532, -220 ; direction 3
	object_velocity 576, 0 ; direction 4
	object_velocity 532, 220 ; direction 5
	object_velocity 407, 407 ; direction 6
	object_velocity 220, 532 ; direction 7
	object_velocity 0, 576 ; direction 8
	object_velocity -220, 532 ; direction 9
	object_velocity -407, 407 ; direction 10
	object_velocity -532, 220 ; direction 11
	object_velocity -576, 0 ; direction 12
	object_velocity -532, -220 ; direction 13
	object_velocity -407, -407 ; direction 14
	object_velocity -220, -532 ; direction 15
	; speed class 6
	object_velocity 0, -672 ; direction 0
	object_velocity 257, -621 ; direction 1
	object_velocity 475, -475 ; direction 2
	object_velocity 621, -257 ; direction 3
	object_velocity 672, 0 ; direction 4
	object_velocity 621, 257 ; direction 5
	object_velocity 475, 475 ; direction 6
	object_velocity 257, 621 ; direction 7
	object_velocity 0, 672 ; direction 8
	object_velocity -257, 621 ; direction 9
	object_velocity -475, 475 ; direction 10
	object_velocity -621, 257 ; direction 11
	object_velocity -672, 0 ; direction 12
	object_velocity -621, -257 ; direction 13
	object_velocity -475, -475 ; direction 14
	object_velocity -257, -621 ; direction 15
	; speed class 7
	object_velocity 0, -768 ; direction 0
	object_velocity 294, -710 ; direction 1
	object_velocity 543, -543 ; direction 2
	object_velocity 710, -294 ; direction 3
	object_velocity 768, 0 ; direction 4
	object_velocity 710, 294 ; direction 5
	object_velocity 543, 543 ; direction 6
	object_velocity 294, 710 ; direction 7
	object_velocity 0, 768 ; direction 8
	object_velocity -294, 710 ; direction 9
	object_velocity -543, 543 ; direction 10
	object_velocity -710, 294 ; direction 11
	object_velocity -768, 0 ; direction 12
	object_velocity -710, -294 ; direction 13
	object_velocity -543, -543 ; direction 14
	object_velocity -294, -710 ; direction 15
	; speed class 8
	object_velocity 0, -864 ; direction 0
	object_velocity 331, -798 ; direction 1
	object_velocity 611, -611 ; direction 2
	object_velocity 798, -331 ; direction 3
	object_velocity 864, 0 ; direction 4
	object_velocity 798, 331 ; direction 5
	object_velocity 611, 611 ; direction 6
	object_velocity 331, 798 ; direction 7
	object_velocity 0, 864 ; direction 8
	object_velocity -331, 798 ; direction 9
	object_velocity -611, 611 ; direction 10
	object_velocity -798, 331 ; direction 11
	object_velocity -864, 0 ; direction 12
	object_velocity -798, -331 ; direction 13
	object_velocity -611, -611 ; direction 14
	object_velocity -331, -798 ; direction 15
	; speed class 9
	object_velocity 0, -960 ; direction 0
	object_velocity 367, -887 ; direction 1
	object_velocity 679, -679 ; direction 2
	object_velocity 887, -367 ; direction 3
	object_velocity 960, 0 ; direction 4
	object_velocity 887, 367 ; direction 5
	object_velocity 679, 679 ; direction 6
	object_velocity 367, 887 ; direction 7
	object_velocity 0, 960 ; direction 8
	object_velocity -367, 887 ; direction 9
	object_velocity -679, 679 ; direction 10
	object_velocity -887, 367 ; direction 11
	object_velocity -960, 0 ; direction 12
	object_velocity -887, -367 ; direction 13
	object_velocity -679, -679 ; direction 14
	object_velocity -367, -887 ; direction 15
	; speed class 10
	object_velocity 0, -1056 ; direction 0
	object_velocity 404, -976 ; direction 1
	object_velocity 747, -747 ; direction 2
	object_velocity 976, -404 ; direction 3
	object_velocity 1056, 0 ; direction 4
	object_velocity 976, 404 ; direction 5
	object_velocity 747, 747 ; direction 6
	object_velocity 404, 976 ; direction 7
	object_velocity 0, 1056 ; direction 8
	object_velocity -404, 976 ; direction 9
	object_velocity -747, 747 ; direction 10
	object_velocity -976, 404 ; direction 11
	object_velocity -1056, 0 ; direction 12
	object_velocity -976, -404 ; direction 13
	object_velocity -747, -747 ; direction 14
	object_velocity -404, -976 ; direction 15
	; speed class 11
	object_velocity 0, -1152 ; direction 0
	object_velocity 441, -1064 ; direction 1
	object_velocity 815, -815 ; direction 2
	object_velocity 1064, -441 ; direction 3
	object_velocity 1152, 0 ; direction 4
	object_velocity 1064, 441 ; direction 5
	object_velocity 815, 815 ; direction 6
	object_velocity 441, 1064 ; direction 7
	object_velocity 0, 1152 ; direction 8
	object_velocity -441, 1064 ; direction 9
	object_velocity -815, 815 ; direction 10
	object_velocity -1064, 441 ; direction 11
	object_velocity -1152, 0 ; direction 12
	object_velocity -1064, -441 ; direction 13
	object_velocity -815, -815 ; direction 14
	object_velocity -441, -1064 ; direction 15
	; speed class 12
	object_velocity 0, -1248 ; direction 0
	object_velocity 478, -1153 ; direction 1
	object_velocity 882, -882 ; direction 2
	object_velocity 1153, -478 ; direction 3
	object_velocity 1248, 0 ; direction 4
	object_velocity 1153, 478 ; direction 5
	object_velocity 882, 882 ; direction 6
	object_velocity 478, 1153 ; direction 7
	object_velocity 0, 1248 ; direction 8
	object_velocity -478, 1153 ; direction 9
	object_velocity -882, 882 ; direction 10
	object_velocity -1153, 478 ; direction 11
	object_velocity -1248, 0 ; direction 12
	object_velocity -1153, -478 ; direction 13
	object_velocity -882, -882 ; direction 14
	object_velocity -478, -1153 ; direction 15
	; speed class 13
	object_velocity 0, -1344 ; direction 0
	object_velocity 514, -1242 ; direction 1
	object_velocity 950, -950 ; direction 2
	object_velocity 1242, -514 ; direction 3
	object_velocity 1344, 0 ; direction 4
	object_velocity 1242, 514 ; direction 5
	object_velocity 950, 950 ; direction 6
	object_velocity 514, 1242 ; direction 7
	object_velocity 0, 1344 ; direction 8
	object_velocity -514, 1242 ; direction 9
	object_velocity -950, 950 ; direction 10
	object_velocity -1242, 514 ; direction 11
	object_velocity -1344, 0 ; direction 12
	object_velocity -1242, -514 ; direction 13
	object_velocity -950, -950 ; direction 14
	object_velocity -514, -1242 ; direction 15
	; speed class 14
	object_velocity 0, -1440 ; direction 0
	object_velocity 551, -1330 ; direction 1
	object_velocity 1018, -1018 ; direction 2
	object_velocity 1330, -551 ; direction 3
	object_velocity 1440, 0 ; direction 4
	object_velocity 1330, 551 ; direction 5
	object_velocity 1018, 1018 ; direction 6
	object_velocity 551, 1330 ; direction 7
	object_velocity 0, 1440 ; direction 8
	object_velocity -551, 1330 ; direction 9
	object_velocity -1018, 1018 ; direction 10
	object_velocity -1330, 551 ; direction 11
	object_velocity -1440, 0 ; direction 12
	object_velocity -1330, -551 ; direction 13
	object_velocity -1018, -1018 ; direction 14
	object_velocity -551, -1330 ; direction 15
	; speed class 15 (not selected)
	object_velocity 0, -1536 ; direction 0
	object_velocity 588, -1419 ; direction 1
	object_velocity 1086, -1086 ; direction 2
	object_velocity 1419, -588 ; direction 3
	object_velocity 1536, 0 ; direction 4
	object_velocity 1419, 588 ; direction 5
	object_velocity 1086, 1086 ; direction 6
	object_velocity 588, 1419 ; direction 7
	object_velocity 0, 1536 ; direction 8
	object_velocity -588, 1419 ; direction 9
	object_velocity -1086, 1086 ; direction 10
	object_velocity -1419, 588 ; direction 11
	object_velocity -1536, 0 ; direction 12
	object_velocity -1419, -588 ; direction 13
	object_velocity -1086, -1086 ; direction 14
	object_velocity -588, -1419 ; direction 15
ObjectVelocityTableEnd:
	ds $4EA0 - @, $00 ; no reader

	ASSERT ObjectVelocityTableEnd - ObjectVelocityTable == 16 * 16 * 8


; Indexed by the object's type field; GetObjectScoreValue returns the selected
; 16-bit value and AddToScore adds it to the four-byte score accumulator.
ObjectScoreValues:
	dw 500, 1000, 3000, 1000

	ds $5100 - @, $00

ObjectTypeParameterTable:
	object_type_parameters $06, $0F, $50
	object_type_parameters $04, $06, $B4
	object_type_parameters $05, $05, $4B
	object_type_parameters $40, $01, $14

LevelTileAnimationPointers:
	dw LevelTileAnimationSet0, LevelTileAnimationSet0, LevelTileAnimationSet0
	dw LevelTileAnimationSet2, LevelTileAnimationSet2, LevelTileAnimationSet2
	dw LevelTileAnimationSet1, LevelTileAnimationSet1, LevelTileAnimationSet1
	dw LevelTileAnimationSet4, LevelTileAnimationSet4, LevelTileAnimationSet4
	dw LevelTileAnimationSet3, LevelTileAnimationSet3, LevelTileAnimationSet3

LevelAttributeLookupPointers:
	level_attr_lookup Level00_AttrLookup
	level_attr_lookup Level01_AttrLookup
	level_attr_lookup Level02_AttrLookup
	level_attr_lookup Level03_AttrLookup
	level_attr_lookup Level04_AttrLookup
	level_attr_lookup Level05_AttrLookup
	level_attr_lookup Level06_AttrLookup
	level_attr_lookup Level07_AttrLookup
	level_attr_lookup Level08_AttrLookup
	level_attr_lookup Level09_AttrLookup
	level_attr_lookup Level10_AttrLookup
	level_attr_lookup Level11_AttrLookup
	level_attr_lookup Level12_AttrLookup
	level_attr_lookup Level13_AttrLookup
	level_attr_lookup Level14_AttrLookup

	INCLUDE "src/level_tile_animation.asm"

	INCLUDE "src/screen_effect_tables.asm"

	ASSERT LevelRecordPointers == $4300
	ASSERT Level14_Record == $4518
	ASSERT ObjectScoreValues == $4EA0
	ASSERT ObjectTypeParameterTable == $5100
	ASSERT LevelTileAnimationPointers == $5120
	ASSERT LevelAttributeLookupPointers == $513E
	ASSERT LevelTileAnimationSet0 == $517A

; Relocation pin: ROM0 Func_2241/Func_2295 use ld bc, $4600 (src/bank_00.asm is not edited here).
	ASSERT BANK(ObjectVelocityTable) == $05 && ObjectVelocityTable == $4600, "raw pointer: ROM0 ld bc, $4600"
