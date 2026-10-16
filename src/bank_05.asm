; BattleTanx (USA) - ROM bank $05

SECTION "ROM Bank $05", ROMX[$4000], BANK[$05]
ObjectOrientationLayoutPointers:
	dw ObjectLayoutNormal, ObjectLayoutNormal, ObjectLayoutNormal, ObjectLayoutNormal
	dw ObjectLayoutNormal, ObjectLayoutNormal, ObjectLayoutNormal, ObjectLayoutNormal
	dw ObjectLayoutNormal
	dw ObjectLayoutXFlipped, ObjectLayoutXFlipped, ObjectLayoutXFlipped
	dw ObjectLayoutXFlipped, ObjectLayoutXFlipped, ObjectLayoutXFlipped, ObjectLayoutXFlipped

ObjectOrientationTilePointers:
	dw $4000, $4090, $4120, $41B0, $4240, $42D0, $4360, $43F0
	dw $4480, $43F0, $4360, $42D0, $4240, $41B0, $4120, $4090

ObjectLayoutNormal:
	db $F4, $F4, $00, $00, $F4, $FC, $01, $00, $F4, $04, $02, $00, $FC, $F4, $03, $00
	db $FC, $FC, $04, $00, $FC, $04, $05, $00, $04, $F4, $06, $00, $04, $FC, $07, $00
	db $04, $04, $08, $00

ObjectLayoutXFlipped:
	db $F4, $04, $00, $20, $F4, $FC, $01, $20, $F4, $F4, $02, $20
	db $FC, $04, $03, $20, $FC, $FC, $04, $20, $FC, $F4, $05, $20, $04, $04, $06, $20
	db $04, $FC, $07, $20, $04, $F4, $08, $20

Func_05_4088:
	ld hl, $5120
	ld a, [$CA06]
	add a, a
	ld c, a
	ld b, $00
	add hl, bc
	ld a, [hli]
	ld [$C8CE], a
	ld a, [hli]
	ld [$C8CF], a
	ld hl, LevelAttributeLookupPointers
	ld a, c
	add a, a
	ld c, a
	ld b, $00
	add hl, bc
	ld a, [hli]
	ld [$C8D0], a
	ld a, [hli]
	ld [$C8D1], a
	ld a, [hl]
	ld [$C8D2], a
	ret

	INCBIN "assets/bank_05/40B1.bin"

LevelRecordPointers:
	dw Level00_Record, Level01_Record, Level02_Record, Level03_Record, Level04_Record
	dw Level05_Record, Level06_Record, Level07_Record, Level08_Record, Level09_Record
	dw Level10_Record, Level11_Record, Level12_Record, Level13_Record, Level14_Record

	INCBIN "assets/bank_05/431E.bin"

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

	INCBIN "assets/bank_05/452C.bin"

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

	INCBIN "assets/bank_05/517A.bin"

	ASSERT LevelRecordPointers == $4300
	ASSERT Level14_Record == $4518
	ASSERT LevelAttributeLookupPointers == $513E
