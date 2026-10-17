; Level data constants for ROM banks $09-$26. Values are copied from the
; level records at $05:$4400 (see DATA_BANKS_09_26.md); tools/check_project.py
; verifies that they still match the base ROM.

; Pads a level bank with zeros up to its bank-number marker at $7FFF.
MACRO level_bank_end
	ds $7FFF - @, $00
	db BANK(@)
ENDM

; Twenty-byte record consumed by ROM0 LoadLevelData/LoadLevelRecord.
; Arguments: width, height, tiles, palettes, cell map, tile map, attribute map,
; tile count, palette count.
; +0 width, +1 height, +2 tile bank, +3 palette bank, +4 cell-map bank,
; +5 map bank, +6 map bank again (copied to $C8BD, never read),
; +7/+8 tile count - 1 (copied to $C8BE/$C8BF, never read), +9 palette count,
; +10 tiles, +12 palettes, +14 attribute map, +16 tile map, +18 cell map.
; LEVEL_SEMANTICS_RESEARCH.md lists every reader.
MACRO level_record
	db \1, \2
	db BANK(\3), BANK(\4), BANK(\5), BANK(\6), BANK(\7)
	dw \8 - 1
	db \9
	dw \3, \4, \7, \6, \5
ENDM

; Cell-map byte bits, from the readers in ROM0 (LEVEL_SEMANTICS_RESEARCH.md).
; Only bits 0-3 occur in ROM; bits 6-7 are set at run time.
DEF CELLB_PASSABLE    EQU 0 ; clear: movement rejected (TestLevelCellBit0AtPixel)
DEF CELLB_SOLID       EQU 1 ; set with bit 2 clear: flag-bit-3 objects are rolled back
DEF CELLB_DESTRUCTIBLE EQU 2 ; region converted by ConvertLevelCellBit2ToLookupState
DEF CELLB_TOUCH_REGION EQU 3 ; region converted on contact (ConvertLevelCellBit3RegionAtPixel, +20 score)
DEF CELLB_ANIMATED    EQU 6 ; set by StartLevelCellLookupTransition: tile $BB + frame
DEF CELLB_LOOKUP      EQU 7 ; set on conversion: tile/attribute via $05 table and AttrLookup
; Bits 4-5 are never tested and never set.

; Four-byte entry consumed by bank $05:$4088: address, bank, reserved zero.
MACRO level_attr_lookup
	dw \1
	db BANK(\1), $00
ENDM

; One-based entry number followed by the four tile IDs selected over time.
MACRO level_tile_animation
	db \1, \2, \3, \4, \5
ENDM

; Three object initialization parameters followed by five reserved zeros.
MACRO object_type_parameters
	db \1, \2, \3, $00, $00, $00, $00, $00
ENDM

DEF LEVEL00_WIDTH EQU 64
DEF LEVEL00_HEIGHT EQU 64
DEF LEVEL00_TILE_COUNT EQU 401 ; record +7 holds this minus 1
DEF LEVEL00_PALETTE_COUNT EQU 7

DEF LEVEL01_WIDTH EQU 88
DEF LEVEL01_HEIGHT EQU 88
DEF LEVEL01_TILE_COUNT EQU 367 ; record +7 holds this minus 1
DEF LEVEL01_PALETTE_COUNT EQU 7

DEF LEVEL02_WIDTH EQU 72
DEF LEVEL02_HEIGHT EQU 104
DEF LEVEL02_TILE_COUNT EQU 368 ; record +7 holds this minus 1
DEF LEVEL02_PALETTE_COUNT EQU 7

DEF LEVEL03_WIDTH EQU 168
DEF LEVEL03_HEIGHT EQU 48
DEF LEVEL03_TILE_COUNT EQU 357 ; record +7 holds this minus 1
DEF LEVEL03_PALETTE_COUNT EQU 6

DEF LEVEL04_WIDTH EQU 88
DEF LEVEL04_HEIGHT EQU 88
DEF LEVEL04_TILE_COUNT EQU 294 ; record +7 holds this minus 1
DEF LEVEL04_PALETTE_COUNT EQU 7

DEF LEVEL05_WIDTH EQU 72
DEF LEVEL05_HEIGHT EQU 104
DEF LEVEL05_TILE_COUNT EQU 402 ; record +7 holds this minus 1
DEF LEVEL05_PALETTE_COUNT EQU 7

DEF LEVEL06_WIDTH EQU 88
DEF LEVEL06_HEIGHT EQU 80
DEF LEVEL06_TILE_COUNT EQU 281 ; record +7 holds this minus 1
DEF LEVEL06_PALETTE_COUNT EQU 5

DEF LEVEL07_WIDTH EQU 72
DEF LEVEL07_HEIGHT EQU 112
DEF LEVEL07_TILE_COUNT EQU 415 ; record +7 holds this minus 1
DEF LEVEL07_PALETTE_COUNT EQU 5

DEF LEVEL08_WIDTH EQU 112
DEF LEVEL08_HEIGHT EQU 72
DEF LEVEL08_TILE_COUNT EQU 420 ; record +7 holds this minus 1
DEF LEVEL08_PALETTE_COUNT EQU 7

DEF LEVEL09_WIDTH EQU 64
DEF LEVEL09_HEIGHT EQU 120
DEF LEVEL09_TILE_COUNT EQU 323 ; record +7 holds this minus 1
DEF LEVEL09_PALETTE_COUNT EQU 6

DEF LEVEL10_WIDTH EQU 88
DEF LEVEL10_HEIGHT EQU 88
DEF LEVEL10_TILE_COUNT EQU 264 ; record +7 holds this minus 1
DEF LEVEL10_PALETTE_COUNT EQU 7

DEF LEVEL11_WIDTH EQU 120
DEF LEVEL11_HEIGHT EQU 64
DEF LEVEL11_TILE_COUNT EQU 290 ; record +7 holds this minus 1
DEF LEVEL11_PALETTE_COUNT EQU 7

DEF LEVEL12_WIDTH EQU 120
DEF LEVEL12_HEIGHT EQU 64
DEF LEVEL12_TILE_COUNT EQU 247 ; record +7 holds this minus 1
DEF LEVEL12_PALETTE_COUNT EQU 7

DEF LEVEL13_WIDTH EQU 88
DEF LEVEL13_HEIGHT EQU 88
DEF LEVEL13_TILE_COUNT EQU 254 ; record +7 holds this minus 1
DEF LEVEL13_PALETTE_COUNT EQU 6

DEF LEVEL14_WIDTH EQU 64
DEF LEVEL14_HEIGHT EQU 120
DEF LEVEL14_TILE_COUNT EQU 392 ; record +7 holds this minus 1
DEF LEVEL14_PALETTE_COUNT EQU 7
