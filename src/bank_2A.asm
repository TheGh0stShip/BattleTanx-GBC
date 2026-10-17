; BattleTanx (USA) - ROM bank $2A: full-screen pictures and their
; load/draw routines. Layout and evidence: BANKS_2A_2E_RESEARCH.md.

SECTION "ROM Bank $2A", ROMX[$4000], BANK[$2A]

; Bank $2A fixed screen, drawn and animated by FixedScreen2A_Run.
; 464 tiles; FixedScreen2A_LoadTiles copies 512 from here, so the last
; 48 copied tiles come from the maps below.
FixedScreen2A_Tiles:
	INCBIN "assets/screens/fixedscreen2a_tiles.2bpp"

FixedScreen2A_TileMap:
	db $81, $82, $83, $84, $85, $86, $87, $88, $89, $8A, $8B, $8C, $8D, $8E, $8F, $90, $91, $92, $93, $94
	db $95, $96, $97, $98, $99, $9A, $9B, $9C, $9D, $9E, $9F, $A0, $A1, $A2, $A3, $A4, $A5, $A6, $A7, $A8
	db $A9, $AA, $AB, $AC, $AD, $AE, $AF, $B0, $B0, $B1, $B2, $B3, $B4, $B0, $B0, $B0, $B0, $B5, $B6, $B7
	db $B8, $B9, $BA, $BB, $BC, $BD, $BE, $BF, $B0, $B0, $B0, $B0, $B0, $B0, $B0, $C0, $C1, $C2, $C3, $C4
	db $C5, $C6, $C7, $C8, $C9, $CA, $CB, $CC, $CD, $CE, $B0, $B0, $B0, $B0, $B0, $CF, $D0, $D1, $D2, $D3
	db $D4, $D5, $D6, $D7, $D8, $D9, $DA, $DB, $DC, $DD, $DE, $B0, $B0, $B0, $B0, $DF, $E0, $E1, $E2, $E3
	db $E4, $E5, $E6, $E7, $E8, $E9, $EA, $B0, $B0, $EB, $EC, $ED, $B0, $B0, $EE, $EF, $F0, $F1, $F2, $F3
	db $F4, $F5, $F6, $F7, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF, $00, $01, $02, $03, $04, $05, $06, $07
	db $08, $09, $0A, $0B, $0C, $0D, $0E, $0F, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B
	db $1C, $1D, $1E, $1F, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F
	db $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F, $40, $41, $42, $43
	db $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F, $50, $51, $52, $53, $54, $55, $56, $B0
	db $57, $58, $59, $5A, $5B, $5C, $5D, $5D, $5D, $5E, $5F, $60, $61, $62, $63, $64, $65, $66, $67, $68
	db $69, $6A, $6B, $6C, $6D, $6E, $6F, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B, $7C
	db $7D, $7E, $7F, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $5D, $0F
	db $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F, $20, $21, $22, $23
	db $24, $25, $26, $27, $28, $29, $2A, $2B, $2B, $2B, $2B, $2B, $2B, $2B, $2C, $2D, $2E, $2F, $30, $31
	db $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F, $40, $41, $42, $43, $44, $45

; 20x11 sheet of four 5x11 frames for the BG rectangle at $980F.
FixedScreen2A_FrameTileMap:
	db $90, $91, $92, $93, $94, $90, $91, $92, $46, $47, $90, $91, $92, $48, $49, $90, $91, $4A, $4B, $4C
	db $A4, $A5, $A6, $A7, $A8, $A4, $A5, $B0, $4D, $4E, $A4, $A5, $4F, $50, $51, $A4, $A5, $52, $53, $54
	db $B0, $B0, $B5, $B6, $B7, $B0, $55, $56, $57, $58, $B0, $59, $5A, $5B, $5C, $B0, $B0, $5D, $5E, $5F
	db $C0, $C1, $C2, $C3, $C4, $B0, $60, $61, $62, $63, $B0, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C
	db $CF, $D0, $D1, $D2, $D3, $6D, $6E, $6F, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B
	db $DF, $E0, $E1, $E2, $E3, $7C, $7D, $7E, $7F, $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8A
	db $EF, $F0, $F1, $F2, $F3, $8B, $8C, $8D, $8E, $8F, $90, $91, $92, $93, $94, $95, $96, $97, $98, $99
	db $03, $04, $05, $06, $07, $9A, $9B, $9C, $9D, $9E, $9F, $A0, $A1, $A2, $A3, $A4, $A5, $A6, $A7, $A8
	db $17, $18, $19, $1A, $1B, $A9, $AA, $AB, $AC, $AD, $AE, $AF, $B0, $B1, $B2, $B3, $B4, $B5, $B6, $B7
	db $2B, $2C, $2D, $2E, $2F, $B8, $B9, $BA, $BB, $BC, $BD, $BE, $BF, $C0, $C1, $C2, $C3, $C4, $C5, $C6
	db $3F, $40, $41, $42, $43, $3F, $40, $C7, $C8, $C9, $3F, $40, $CA, $CB, $CC, $3F, $40, $CD, $CE, $CF

FixedScreen2A_AttrMap:
	db $00, $00, $00, $00, $00, $01, $01, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01
	db $00, $00, $00, $00, $00, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01
	db $00, $00, $00, $00, $01, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01
	db $00, $00, $00, $00, $02, $03, $03, $02, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $01
	db $00, $00, $00, $00, $02, $02, $02, $03, $02, $02, $00, $00, $00, $00, $00, $01, $01, $01, $01, $01
	db $00, $00, $00, $00, $00, $00, $00, $02, $02, $02, $02, $00, $00, $00, $00, $01, $01, $01, $01, $07
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $02, $02, $00, $00, $02, $01, $01, $07, $04, $04
	db $00, $00, $00, $00, $00, $02, $02, $02, $02, $02, $03, $03, $02, $02, $03, $01, $01, $04, $04, $04
	db $00, $00, $00, $00, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $01, $04, $04, $04, $01
	db $00, $00, $00, $00, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $04, $04, $04, $04, $01
	db $05, $05, $00, $00, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $02, $04, $01, $01
	db $01, $01, $05, $00, $00, $05, $05, $05, $05, $05, $05, $03, $03, $03, $03, $03, $03, $03, $02, $00
	db $01, $01, $01, $01, $05, $01, $01, $01, $01, $01, $05, $05, $05, $01, $05, $05, $05, $05, $05, $01
	db $05, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0D, $01, $09
	db $09, $09, $0D, $0E, $0E, $0E, $0E, $0A, $0E, $0A, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0D, $09, $09
	db $0D, $09, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $09, $09
	db $0D, $0D, $0D, $0D, $0D, $0D, $0D, $09, $09, $09, $09, $09, $09, $09, $09, $0D, $0D, $0D, $0D, $0D

FixedScreen2A_FrameAttrMap:
	db $00, $00, $00, $01, $01, $00, $00, $00, $09, $09, $00, $00, $00, $09, $09, $00, $00, $08, $09, $09
	db $00, $00, $01, $01, $01, $00, $00, $00, $09, $09, $00, $00, $09, $09, $09, $00, $00, $09, $09, $09
	db $00, $00, $01, $01, $01, $00, $09, $09, $09, $09, $00, $09, $09, $09, $09, $00, $00, $09, $09, $09
	db $01, $01, $01, $01, $01, $00, $09, $09, $09, $09, $00, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $01, $01, $01, $01, $01, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $01, $01, $01, $01, $07, $09, $09, $09, $09, $0C, $09, $09, $09, $0F, $0F, $09, $09, $09, $09, $0F
	db $01, $01, $07, $04, $04, $09, $09, $09, $0C, $0C, $09, $09, $09, $0C, $0C, $09, $09, $09, $0F, $0C
	db $01, $01, $04, $04, $04, $09, $09, $0C, $0C, $0C, $09, $09, $0F, $0C, $0C, $09, $09, $0F, $0C, $0C
	db $01, $04, $04, $04, $01, $09, $0C, $0C, $0C, $09, $09, $0F, $0C, $0C, $0F, $09, $0F, $0C, $0C, $09
	db $04, $04, $04, $04, $01, $0C, $0C, $0C, $0C, $09, $0C, $0C, $0C, $0C, $09, $0C, $0C, $0C, $0C, $09
	db $03, $02, $04, $01, $01, $03, $02, $0C, $09, $09, $03, $02, $0C, $09, $09, $03, $02, $0C, $09, $09

FixedScreen2A_Palettes:
	dw $0C63, $2926, $45EC, $5E90 ; palette 0
	dw $00E9, $0171, $2ED7, $5E90 ; palette 1
	dw $1520, $2A00, $42E0, $5E90 ; palette 2
	dw $0C63, $1520, $2A00, $42E0 ; palette 3
	dw $001F, $0171, $2ED7, $03DD ; palette 4
	dw $0C63, $00E9, $1520, $0171 ; palette 5
	dw $1520, $2A00, $42E0, $4791 ; palette 6
	dw $001F, $00E9, $0171, $03DD ; palette 7

; Frame n: tile and attribute sources of the 5x11 rectangle.
FixedScreen2A_FrameTable:
	dw FixedScreen2A_FrameTileMap + 0, FixedScreen2A_FrameAttrMap + 0
	dw FixedScreen2A_FrameTileMap + 5, FixedScreen2A_FrameAttrMap + 5
	dw FixedScreen2A_FrameTileMap + 10, FixedScreen2A_FrameAttrMap + 10
	dw FixedScreen2A_FrameTileMap + 15, FixedScreen2A_FrameAttrMap + 15

; ScreenModeTable entries 1.
Func_2A_61D8: ; address-based alias kept for other banks
OptionsScreen_LoadTiles: ; MenuState04 (OptionsMenuEntries text MUSIC/CONTROL/SKILL)
ScreenMode01_LoadTiles:
	screen_load_tiles ScreenMode01_Descriptor

Func_2A_6230: ; address-based alias kept for other banks
OptionsScreen_Draw: ; MenuState04 (OptionsMenuEntries text MUSIC/CONTROL/SKILL)
ScreenMode01_Draw: ; fades in from black
	screen_draw_fade ScreenMode01_Descriptor, 0

OptionsScreen_Descriptor: ; MenuState04 (OptionsMenuEntries text MUSIC/CONTROL/SKILL)
ScreenMode01_Descriptor:
	screen_descriptor ScreenMode01_Tiles, ScreenMode01_TileMap, ScreenMode01_AttrMap, ScreenMode01_Palettes, 75, 20, 17, 3, 0

ScreenMode01_Tiles:
	INCBIN "assets/screens/screenmode01_tiles.2bpp"

ScreenMode01_TileMap:
	db $81, $82, $83, $84, $85, $84, $86, $84, $85, $84, $84, $85, $84, $86, $84, $85, $84, $87, $82, $88
	db $89, $8A, $8B, $8C, $8D, $8D, $8E, $8D, $8D, $8D, $8D, $8D, $8D, $8E, $8D, $8D, $8F, $90, $91, $89
	db $92, $93, $94, $95, $96, $97, $96, $96, $97, $96, $96, $97, $96, $96, $97, $96, $98, $99, $9A, $9B
	db $9C, $9D, $9E, $9F, $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A1, $A2, $A3, $A4
	db $A5, $A6, $92, $A7, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A9, $AA, $A5, $A6
	db $9C, $A4, $89, $A7, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A9, $AB, $9C, $A4
	db $AC, $A4, $89, $A7, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A9, $AB, $9C, $AD
	db $9C, $A4, $AE, $A7, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A9, $AF, $9C, $A4
	db $A5, $A6, $89, $A7, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A9, $AB, $A5, $A6
	db $9C, $A4, $B0, $A7, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A9, $B1, $9C, $A4
	db $AC, $A4, $89, $A7, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A9, $AB, $9C, $AD
	db $9C, $A4, $89, $A7, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A9, $AB, $9C, $A4
	db $A5, $A6, $92, $A7, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A9, $AA, $A5, $A6
	db $9C, $B2, $B3, $B4, $B5, $B5, $B5, $B5, $B5, $B5, $B5, $B5, $B5, $B5, $B5, $B5, $B6, $B7, $8C, $A4
	db $92, $B8, $B9, $BA, $BB, $BC, $BB, $BB, $BC, $BB, $BB, $BC, $BB, $BB, $BC, $BB, $BD, $BE, $BF, $92
	db $89, $C0, $C1, $C2, $84, $84, $86, $84, $84, $84, $84, $84, $84, $86, $84, $84, $9D, $C3, $C4, $89
	db $C5, $82, $C6, $C7, $C8, $C7, $C9, $C7, $C8, $C7, $C7, $C8, $C7, $C9, $C7, $C8, $C7, $83, $82, $CA

ScreenMode01_AttrMap:
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00
	db $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00
	db $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00
	db $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00
	db $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00
	db $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00
	db $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00
	db $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00
	db $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00
	db $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00
	db $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

ScreenMode01_Palettes:
	dw $0C63, $1120, $0204, $270A ; palette 0
	dw $0000, $0000, $0C63, $4E91 ; palette 1
	dw $0000, $0000, $6F58, $5E90 ; palette 2

; ScreenModeTable entries 12.
Func_2A_6A22: ; address-based alias kept for other banks
ScreenMode12_LoadTiles:
	screen_load_tiles ScreenMode12_Descriptor

Func_2A_6A7A: ; address-based alias kept for other banks
ScreenMode12_Draw: ; no fade
	screen_draw_plain ScreenMode12_Descriptor

ScreenMode12_Descriptor:
	screen_descriptor ScreenMode12_Tiles, ScreenMode12_TileMap, ScreenMode12_AttrMap, ScreenMode12_Palettes, 148, 20, 18, 3, 0

ScreenMode12_Tiles:
	INCBIN "assets/screens/screenmode12_tiles.2bpp"
	ds 16, $00 ; all-zero tile after the counted tiles; no map refers to it

ScreenMode12_TileMap:
	db $81, $82, $83, $84, $85, $86, $87, $88, $82, $89, $88, $82, $89, $8A, $8B, $8C, $84, $8D, $82, $8E
	db $8F, $90, $91, $92, $93, $94, $95, $96, $96, $96, $96, $96, $96, $97, $98, $99, $9A, $9B, $9C, $8F
	db $9D, $9E, $9F, $A0, $96, $A1, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $A1, $96, $A3, $A4, $A5, $9D
	db $8F, $A6, $A7, $A8, $A9, $AA, $AB, $AC, $AD, $AE, $A2, $AF, $B0, $B1, $B2, $B3, $B4, $B5, $B6, $8F
	db $9D, $B7, $B8, $B9, $BA, $BB, $BC, $BD, $BE, $BF, $A2, $C0, $C1, $C2, $C3, $A2, $C4, $C5, $C6, $9D
	db $8F, $C7, $C8, $C9, $A2, $CA, $CB, $CC, $CD, $CE, $A2, $CF, $D0, $D1, $D2, $A2, $D3, $D4, $D5, $8F
	db $8F, $C7, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $D6, $8F
	db $9D, $C7, $A2, $D7, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D9, $A2, $D6, $9D
	db $8F, $C7, $A2, $DA, $DB, $DB, $DB, $DB, $DB, $DB, $DB, $DB, $DB, $DB, $DB, $DB, $DC, $A2, $D6, $8F
	db $8F, $C7, $A2, $DA, $DB, $DB, $DB, $DB, $DB, $DB, $DB, $DB, $DB, $DB, $DB, $DB, $DC, $A2, $D6, $8F
	db $9D, $C7, $A2, $DD, $DE, $DE, $DE, $DE, $DE, $DE, $DE, $DE, $DE, $DE, $DE, $DE, $DF, $A2, $D6, $9D
	db $8F, $C7, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $D7, $D8, $D8, $D9, $A2, $D6, $8F
	db $8F, $E0, $E1, $E2, $A2, $E3, $E4, $E5, $E6, $E7, $E8, $E9, $EA, $DA, $DB, $DB, $DC, $A2, $D6, $8F
	db $9D, $B7, $EB, $EC, $A2, $ED, $EE, $EF, $F0, $F1, $F2, $F3, $F4, $DA, $DB, $DB, $DC, $A2, $D6, $9D
	db $8F, $F5, $F6, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $A2, $DD, $DE, $DE, $F7, $F8, $F9, $8F
	db $9D, $FA, $FB, $FC, $FD, $FD, $FE, $A2, $A2, $A2, $A2, $A2, $A2, $FF, $FD, $FD, $FE, $00, $01, $9D
	db $02, $03, $FD, $04, $05, $A2, $06, $FD, $FD, $FD, $FD, $FD, $FD, $07, $08, $09, $06, $FD, $0A, $0B
	db $0C, $0D, $0E, $0D, $0D, $0D, $0F, $10, $0D, $0F, $10, $0D, $11, $0D, $0D, $0D, $0D, $12, $0D, $13

ScreenMode12_AttrMap:
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $01, $01, $01, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00, $01, $01, $00
	db $00, $01, $01, $01, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $01, $00
	db $00, $00, $00, $00, $00, $02, $02, $00, $02, $02, $00, $00, $02, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $02, $02, $02, $02, $02, $00, $02, $02, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $02, $02, $02, $02, $02, $00, $02, $02, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00, $00
	db $00, $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $01, $00, $02, $02, $02, $02, $02, $00, $01, $01, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $01, $02, $02, $02, $02, $02, $02, $00, $01, $01, $00, $00, $00, $00
	db $00, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $00
	db $00, $01, $01, $02, $00, $00, $01, $00, $00, $00, $00, $00, $00, $01, $00, $00, $01, $01, $01, $00
	db $00, $00, $00, $01, $00, $00, $01, $00, $00, $00, $00, $00, $00, $01, $00, $00, $01, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

ScreenMode12_Palettes:
	dw $1120, $0204, $270A, $6F58 ; palette 0
	dw $0C63, $1120, $0204, $270A ; palette 1
	dw $0C63, $1120, $0204, $6F58 ; palette 2

FixedScreen2A_LoadTiles: ; loads 512 tiles (4 x 128)
	call Func_3960
	xor a
	ldh [rVBK], a
	ld a, $88
	ld bc, FixedScreen2A_Tiles
	ld d, $80
	ld e, $00
	call Func_0622
	ld a, $90
	ld bc, FixedScreen2A_Tiles + $800
	ld d, $80
	ld e, $00
	call Func_0622
	ld a, $01
	ldh [rVBK], a
	ld a, $90
	ld bc, FixedScreen2A_Tiles + $1000
	ld d, $80
	ld e, $00
	call Func_0622
	ld a, $88
	ld bc, FixedScreen2A_Tiles + $1800
	ld d, $80
	ld e, $00
	call Func_0622
	ret


FixedScreen2A_Draw:
	ld a, $14
	ld [wScreenWidth], a
	ld a, $12
	ld [wScreenHeight], a
	ld hl, $9800
	ld bc, FixedScreen2A_AttrMap
	ld de, FixedScreen2A_TileMap
	call CopyScreenMaps
	ld hl, FixedScreen2A_Palettes
	ld bc, $0008
	call Func_052F
	ret


Func_2A_7774: ; address-based alias kept for ROM0 $3F28
; Draws the fixed screen, then shows frames 0-3 for 10 frames each.
; WaitForButtonOrTimeout exits on a button; after a full cycle this also exits
; when wJoypadHeld is non-zero.
FixedScreen2A_Run:
	call FixedScreen2A_LoadTiles
	call FixedScreen2A_Draw
.restart:
	ld e, $04
.next_frame:
	ld d, $0A
	call Func_3971
	ld a, d
	or a
	jr nz, .done
	ld a, $04
	sub e
	call FixedScreen2A_DrawFrame
	dec e
	jr nz, .next_frame
	ld a, [wJoypadHeld]
	or a
	jr z, .restart
.done:
	ret


; a = frame 0-3: copies its 5x11 tiles and attributes to $980F.
FixedScreen2A_DrawFrame:
	push af
	push bc
	push de
	push hl
	ld hl, FixedScreen2A_FrameTable
	add a, a
	add a, a
	ld a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a
	ld hl, $980F
	xor a
	ld [wVBlankPending], a
.wait_vblank:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, .wait_vblank
	xor a
	ld [wVBlankPending], a
	ld a, $0B
	ldh [$FFC1], a
.row:
	ld a, $05
	ldh [$FFC0], a
.cell:
	ld a, $01
	ldh [rVBK], a
	ld a, [de]
	ld [hl], a
	xor a
	ldh [rVBK], a
	ld a, [bc]
	ld [hli], a
	inc bc
	inc de
	ldh a, [$FFC0]
	dec a
	ldh [$FFC0], a
	jr nz, .cell
	ld a, $0F
	add a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	ld a, $0F
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	ld a, $1B
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ldh a, [$FFC1]
	dec a
	ldh [$FFC1], a
	jr nz, .row
	pop hl
	pop de
	pop bc
	pop af
	ret


	screen_bank_end

	ASSERT FixedScreen2A_TileMap - FixedScreen2A_Tiles == 464 * 16
	ASSERT FixedScreen2A_FrameTable - FixedScreen2A_Palettes == 8 * 8
	ASSERT ScreenMode01_TileMap - ScreenMode01_Tiles == 75 * 16
	ASSERT ScreenMode01_Palettes - ScreenMode01_AttrMap == 20 * 17
	ASSERT ScreenMode12_TileMap - ScreenMode12_Tiles == 148 * 16 + 16
	ASSERT ScreenMode12_Palettes - ScreenMode12_AttrMap == 20 * 18
	ASSERT BANK(Func_2A_61D8) == $2A, "raw bank byte in $01:ScreenModeTable"
	ASSERT BANK(Func_2A_6230) == $2A, "raw bank byte in $01:ScreenModeTable"
	ASSERT BANK(Func_2A_6A22) == $2A, "raw bank byte in $01:ScreenModeTable"
	ASSERT BANK(Func_2A_6A7A) == $2A, "raw bank byte in $01:ScreenModeTable"
