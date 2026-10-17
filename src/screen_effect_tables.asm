; Screen-effect tables, bank $05:$59E0-$7FFF (see docs/research/banks_01_05/BANK05_SHARED_TABLES.md).
; Generated once by tools/gen_screen_effect_asm.py; this file is now authoritative.
; Part record: tile count, bank-$08 tile source, OAM template (ROM0 LoadScreenEffectPart).
; Template entry: y offset, x offset, tile offset, attribute (ROM0 BuildScreenEffectPartOam ORs in 3).
; Steps $00-$12 are reachable (75-frame countdown); steps $13-$47 are well-formed but never shown.

MACRO screen_effect_part ; tile count, bank-$08 tile source, OAM template
	db \1
	dw \2, \3
ENDM

ScreenEffectPart59E0: ; steps $00,$2C
	screen_effect_part 7, SpriteTiles5490, ScreenEffectTemplate59EF
ScreenEffectPart59E5: ; steps $01,$2D
	screen_effect_part 9, SpriteTiles5508, ScreenEffectTemplate5A0B
ScreenEffectPart59EA: ; steps $02,$2E
	screen_effect_part 7, SpriteTiles55A0, ScreenEffectTemplate5A2F
ScreenEffectTemplate59EF:
	db -32, -32, 0, $08
	db -24, -32, 1, $08
	db -24, -24, 2, $08
	db -24, -16, 3, $08
	db -16, -16, 4, $08
	db -8, -16, 5, $08
	db -8, -8, 6, $08
ScreenEffectTemplate5A0B:
	db -32, -32, 0, $08
	db -24, -32, 1, $08
	db -24, -24, 2, $08
	db -24, -16, 3, $08
	db -16, -24, 4, $08
	db -16, -16, 5, $08
	db -8, -24, 6, $08
	db -8, -16, 7, $08
	db -8, -8, 8, $08
ScreenEffectTemplate5A2F:
	db -32, -32, 0, $08
	db -32, -24, 1, $08
	db -24, -24, 2, $08
	db -16, -24, 3, $08
	db -16, -16, 4, $08
	db -16, -8, 5, $08
	db -8, -8, 6, $08
ScreenEffectPart5A4B: ; steps $03,$32
	screen_effect_part 7, SpriteTiles5490, ScreenEffectTemplate5A5A
ScreenEffectPart5A50: ; steps $04,$33
	screen_effect_part 9, SpriteTiles5508, ScreenEffectTemplate5A76
ScreenEffectPart5A55: ; steps $05,$34
	screen_effect_part 7, SpriteTiles55A0, ScreenEffectTemplate5A9A
ScreenEffectTemplate5A5A:
	db -32, 32, 0, $28
	db -24, 32, 1, $28
	db -24, 24, 2, $28
	db -24, 16, 3, $28
	db -16, 16, 4, $28
	db -8, 16, 5, $28
	db -8, 8, 6, $28
ScreenEffectTemplate5A76:
	db -32, 32, 0, $28
	db -24, 32, 1, $28
	db -24, 24, 2, $28
	db -24, 16, 3, $28
	db -16, 24, 4, $28
	db -16, 16, 5, $28
	db -8, 24, 6, $28
	db -8, 16, 7, $28
	db -8, 8, 8, $28
ScreenEffectTemplate5A9A:
	db -32, 32, 0, $28
	db -32, 24, 1, $28
	db -24, 24, 2, $28
	db -16, 24, 3, $28
	db -16, 16, 4, $28
	db -16, 8, 5, $28
	db -8, 8, 6, $28
ScreenEffectPart5AB6: ; steps $02,$06,$35
	screen_effect_part 7, SpriteTiles5490, ScreenEffectTemplate5AC5
ScreenEffectPart5ABB: ; steps $03,$07,$36
	screen_effect_part 9, SpriteTiles5508, ScreenEffectTemplate5AE1
ScreenEffectPart5AC0: ; steps $04,$08,$37
	screen_effect_part 7, SpriteTiles55A0, ScreenEffectTemplate5B05
ScreenEffectTemplate5AC5:
	db 32, -32, 0, $48
	db 24, -32, 1, $48
	db 24, -24, 2, $48
	db 24, -16, 3, $48
	db 16, -16, 4, $48
	db 8, -16, 5, $48
	db 8, -8, 6, $48
ScreenEffectTemplate5AE1:
	db 32, -32, 0, $48
	db 24, -32, 1, $48
	db 24, -24, 2, $48
	db 24, -16, 3, $48
	db 16, -24, 4, $48
	db 16, -16, 5, $48
	db 8, -24, 6, $48
	db 8, -16, 7, $48
	db 8, -8, 8, $48
ScreenEffectTemplate5B05:
	db 32, -32, 0, $48
	db 32, -24, 1, $48
	db 24, -24, 2, $48
	db 16, -24, 3, $48
	db 16, -16, 4, $48
	db 16, -8, 5, $48
	db 8, -8, 6, $48
ScreenEffectPart5B21: ; steps $09,$2B,$38
	screen_effect_part 7, SpriteTiles5490, ScreenEffectTemplate5B30
ScreenEffectPart5B26: ; steps $0A,$2C,$39
	screen_effect_part 9, SpriteTiles5508, ScreenEffectTemplate5B4C
ScreenEffectPart5B2B: ; steps $0B,$2D,$3A
	screen_effect_part 7, SpriteTiles55A0, ScreenEffectTemplate5B70
ScreenEffectTemplate5B30:
	db 32, 32, 0, $68
	db 24, 32, 1, $68
	db 24, 24, 2, $68
	db 24, 16, 3, $68
	db 16, 16, 4, $68
	db 8, 16, 5, $68
	db 8, 8, 6, $68
ScreenEffectTemplate5B4C:
	db 32, 32, 0, $68
	db 24, 32, 1, $68
	db 24, 24, 2, $68
	db 24, 16, 3, $68
	db 16, 24, 4, $68
	db 16, 16, 5, $68
	db 8, 24, 6, $68
	db 8, 16, 7, $68
	db 8, 8, 8, $68
ScreenEffectTemplate5B70:
	db 32, 32, 0, $68
	db 32, 24, 1, $68
	db 24, 24, 2, $68
	db 16, 24, 3, $68
	db 16, 16, 4, $68
	db 16, 8, 5, $68
	db 8, 8, 6, $68
ScreenEffectPart5B8C: ; steps $0C,$3B
	screen_effect_part 7, SpriteTiles5618, ScreenEffectTemplate5B9B
ScreenEffectPart5B91: ; steps $0D,$3C
	screen_effect_part 6, SpriteTiles5690, ScreenEffectTemplate5BB7
ScreenEffectPart5B96: ; steps $0E,$3D
	screen_effect_part 6, SpriteTiles56F8, ScreenEffectTemplate5BCF
ScreenEffectTemplate5B9B:
	db -24, -24, 0, $08
	db -24, -16, 1, $08
	db -24, -8, 2, $08
	db -16, -24, 3, $08
	db -16, -16, 4, $08
	db -16, -8, 5, $08
	db -8, -8, 6, $08
ScreenEffectTemplate5BB7:
	db -24, -24, 0, $08
	db -24, -16, 1, $08
	db -16, -24, 2, $08
	db -16, -16, 3, $08
	db -8, -16, 4, $08
	db -8, -8, 5, $08
ScreenEffectTemplate5BCF:
	db -24, -24, 0, $08
	db -24, -16, 1, $08
	db -16, -16, 2, $08
	db -16, -8, 3, $08
	db -8, -16, 4, $08
	db -8, -8, 5, $08
ScreenEffectPart5BE7: ; steps $0F,$3E
	screen_effect_part 7, SpriteTiles5618, ScreenEffectTemplate5BF6
ScreenEffectPart5BEC: ; steps $10,$3F
	screen_effect_part 6, SpriteTiles5690, ScreenEffectTemplate5C12
ScreenEffectPart5BF1: ; steps $11,$40
	screen_effect_part 6, SpriteTiles56F8, ScreenEffectTemplate5C2A
ScreenEffectTemplate5BF6:
	db -24, 24, 0, $28
	db -24, 16, 1, $28
	db -24, 8, 2, $28
	db -16, 24, 3, $28
	db -16, 16, 4, $28
	db -16, 8, 5, $28
	db -8, 8, 6, $28
ScreenEffectTemplate5C12:
	db -24, 24, 0, $28
	db -24, 16, 1, $28
	db -16, 24, 2, $28
	db -16, 16, 3, $28
	db -8, 16, 4, $28
	db -8, 8, 5, $28
ScreenEffectTemplate5C2A:
	db -24, 24, 0, $28
	db -24, 16, 1, $28
	db -16, 16, 2, $28
	db -16, 8, 3, $28
	db -8, 16, 4, $28
	db -8, 8, 5, $28
ScreenEffectPart5C42: ; steps $12,$41
	screen_effect_part 7, SpriteTiles5618, ScreenEffectTemplate5C51
ScreenEffectPart5C47: ; steps $13,$42 (unreachable only)
	screen_effect_part 6, SpriteTiles5690, ScreenEffectTemplate5C6D
ScreenEffectPart5C4C: ; steps $14,$43 (unreachable only)
	screen_effect_part 6, SpriteTiles56F8, ScreenEffectTemplate5C85
ScreenEffectTemplate5C51:
	db 24, -24, 0, $48
	db 24, -16, 1, $48
	db 24, -8, 2, $48
	db 16, -24, 3, $48
	db 16, -16, 4, $48
	db 16, -8, 5, $48
	db 8, -8, 6, $48
ScreenEffectTemplate5C6D:
	db 24, -24, 0, $48
	db 24, -16, 1, $48
	db 16, -24, 2, $48
	db 16, -16, 3, $48
	db 8, -16, 4, $48
	db 8, -8, 5, $48
ScreenEffectTemplate5C85:
	db 24, -24, 0, $48
	db 24, -16, 1, $48
	db 16, -16, 2, $48
	db 16, -8, 3, $48
	db 8, -16, 4, $48
	db 8, -8, 5, $48
ScreenEffectPart5C9D: ; steps $15,$44 (unreachable only)
	screen_effect_part 7, SpriteTiles5618, ScreenEffectTemplate5CAC
ScreenEffectPart5CA2: ; steps $16,$45 (unreachable only)
	screen_effect_part 6, SpriteTiles5690, ScreenEffectTemplate5CC8
ScreenEffectPart5CA7: ; steps $17,$46 (unreachable only)
	screen_effect_part 6, SpriteTiles56F8, ScreenEffectTemplate5CE0
ScreenEffectTemplate5CAC:
	db 24, 24, 0, $68
	db 24, 16, 1, $68
	db 24, 8, 2, $68
	db 16, 24, 3, $68
	db 16, 16, 4, $68
	db 16, 8, 5, $68
	db 8, 8, 6, $68
ScreenEffectTemplate5CC8:
	db 24, 24, 0, $68
	db 24, 16, 1, $68
	db 16, 24, 2, $68
	db 16, 16, 3, $68
	db 8, 16, 4, $68
	db 8, 8, 5, $68
ScreenEffectTemplate5CE0:
	db 24, 24, 0, $68
	db 24, 16, 1, $68
	db 16, 16, 2, $68
	db 16, 8, 3, $68
	db 8, 16, 4, $68
	db 8, 8, 5, $68
ScreenEffectPart5CF8: ; steps $18 (unreachable only)
	screen_effect_part 7, SpriteTiles5DC8, ScreenEffectTemplate5D07
ScreenEffectPart5CFD: ; steps $19 (unreachable only)
	screen_effect_part 13, SpriteTiles5E40, ScreenEffectTemplate5D23
ScreenEffectPart5D02: ; steps $1A (unreachable only)
	screen_effect_part 11, SpriteTiles5F18, ScreenEffectTemplate5D57
ScreenEffectTemplate5D07:
	db -32, -32, 0, $08
	db -24, -32, 1, $08
	db -24, -24, 2, $08
	db -16, -24, 3, $08
	db -16, -16, 4, $08
	db -16, -8, 5, $08
	db -8, -8, 6, $08
ScreenEffectTemplate5D23:
	db -32, -32, 0, $08
	db -32, -24, 1, $08
	db -32, -16, 2, $08
	db -32, -8, 3, $08
	db -24, -32, 4, $08
	db -24, -24, 5, $08
	db -24, -16, 6, $08
	db -16, -24, 7, $08
	db -16, -16, 8, $08
	db -16, -8, 9, $08
	db -8, -24, 10, $08
	db -8, -16, 11, $08
	db -8, -8, 12, $08
ScreenEffectTemplate5D57:
	db -32, -32, 0, $08
	db -32, -24, 1, $08
	db -32, -16, 2, $08
	db -24, -24, 3, $08
	db -24, -16, 4, $08
	db -16, -32, 5, $08
	db -16, -24, 6, $08
	db -16, -16, 7, $08
	db -16, -8, 8, $08
	db -8, -16, 9, $08
	db -8, -8, 10, $08
ScreenEffectPart5D83: ; steps $05,$1B
	screen_effect_part 7, SpriteTiles5DC8, ScreenEffectTemplate5D92
ScreenEffectPart5D88: ; steps $06,$1C
	screen_effect_part 13, SpriteTiles5E40, ScreenEffectTemplate5DAE
ScreenEffectPart5D8D: ; steps $07,$1D
	screen_effect_part 11, SpriteTiles5F18, ScreenEffectTemplate5DE2
ScreenEffectTemplate5D92:
	db -32, 32, 0, $28
	db -24, 32, 1, $28
	db -24, 24, 2, $28
	db -16, 24, 3, $28
	db -16, 16, 4, $28
	db -16, 8, 5, $28
	db -8, 8, 6, $28
ScreenEffectTemplate5DAE:
	db -32, 32, 0, $28
	db -32, 24, 1, $28
	db -32, 16, 2, $28
	db -32, 8, 3, $28
	db -24, 32, 4, $28
	db -24, 24, 5, $28
	db -24, 16, 6, $28
	db -16, 24, 7, $28
	db -16, 16, 8, $28
	db -16, 8, 9, $28
	db -8, 24, 10, $28
	db -8, 16, 11, $28
	db -8, 8, 12, $28
ScreenEffectTemplate5DE2:
	db -32, 32, 0, $28
	db -32, 24, 1, $28
	db -32, 16, 2, $28
	db -24, 24, 3, $28
	db -24, 16, 4, $28
	db -16, 32, 5, $28
	db -16, 24, 6, $28
	db -16, 16, 7, $28
	db -16, 8, 8, $28
	db -8, 16, 9, $28
	db -8, 8, 10, $28
ScreenEffectPart5E0E: ; steps $08,$1E
	screen_effect_part 7, SpriteTiles5DC8, ScreenEffectTemplate5E1D
ScreenEffectPart5E13: ; steps $09,$1F
	screen_effect_part 13, SpriteTiles5E40, ScreenEffectTemplate5E39
ScreenEffectPart5E18: ; steps $0A,$20
	screen_effect_part 11, SpriteTiles5F18, ScreenEffectTemplate5E6D
ScreenEffectTemplate5E1D:
	db 32, -32, 0, $48
	db 24, -32, 1, $48
	db 24, -24, 2, $48
	db 16, -24, 3, $48
	db 16, -16, 4, $48
	db 16, -8, 5, $48
	db 8, -8, 6, $48
ScreenEffectTemplate5E39:
	db 32, -32, 0, $48
	db 32, -24, 1, $48
	db 32, -16, 2, $48
	db 32, -8, 3, $48
	db 24, -32, 4, $48
	db 24, -24, 5, $48
	db 24, -16, 6, $48
	db 16, -24, 7, $48
	db 16, -16, 8, $48
	db 16, -8, 9, $48
	db 8, -24, 10, $48
	db 8, -16, 11, $48
	db 8, -8, 12, $48
ScreenEffectTemplate5E6D:
	db 32, -32, 0, $48
	db 32, -24, 1, $48
	db 32, -16, 2, $48
	db 24, -24, 3, $48
	db 24, -16, 4, $48
	db 16, -32, 5, $48
	db 16, -24, 6, $48
	db 16, -16, 7, $48
	db 16, -8, 8, $48
	db 8, -16, 9, $48
	db 8, -8, 10, $48
ScreenEffectPart5E99: ; steps $0B,$21
	screen_effect_part 7, SpriteTiles5DC8, ScreenEffectTemplate5EA8
ScreenEffectPart5E9E: ; steps $0C,$22
	screen_effect_part 13, SpriteTiles5E40, ScreenEffectTemplate5EC4
ScreenEffectPart5EA3: ; steps $0D,$23
	screen_effect_part 11, SpriteTiles5F18, ScreenEffectTemplate5EF8
ScreenEffectTemplate5EA8:
	db 32, 32, 0, $68
	db 24, 32, 1, $68
	db 24, 24, 2, $68
	db 16, 24, 3, $68
	db 16, 16, 4, $68
	db 16, 8, 5, $68
	db 8, 8, 6, $68
ScreenEffectTemplate5EC4:
	db 32, 32, 0, $68
	db 32, 24, 1, $68
	db 32, 16, 2, $68
	db 32, 8, 3, $68
	db 24, 32, 4, $68
	db 24, 24, 5, $68
	db 24, 16, 6, $68
	db 16, 24, 7, $68
	db 16, 16, 8, $68
	db 16, 8, 9, $68
	db 8, 24, 10, $68
	db 8, 16, 11, $68
	db 8, 8, 12, $68
ScreenEffectTemplate5EF8:
	db 32, 32, 0, $68
	db 32, 24, 1, $68
	db 32, 16, 2, $68
	db 24, 24, 3, $68
	db 24, 16, 4, $68
	db 16, 32, 5, $68
	db 16, 24, 6, $68
	db 16, 16, 7, $68
	db 16, 8, 8, $68
	db 8, 16, 9, $68
	db 8, 8, 10, $68
ScreenEffectPart5F24: ; steps $0E,$24
	screen_effect_part 8, SpriteTiles5760, ScreenEffectTemplate5F33
ScreenEffectPart5F29: ; steps $0F,$25
	screen_effect_part 9, SpriteTiles57E8, ScreenEffectTemplate5F53
ScreenEffectPart5F2E: ; steps $10,$26
	screen_effect_part 9, SpriteTiles5880, ScreenEffectTemplate5F77
ScreenEffectTemplate5F33:
	db -32, -8, 0, $08
	db -32, 0, 1, $08
	db -24, -8, 2, $08
	db -24, 0, 3, $08
	db -16, -8, 4, $08
	db -16, 0, 5, $08
	db -8, -8, 6, $08
	db -8, 0, 7, $08
ScreenEffectTemplate5F53:
	db -32, -8, 0, $08
	db -32, 0, 1, $08
	db -24, -16, 2, $08
	db -24, -8, 3, $08
	db -24, 0, 4, $08
	db -16, -8, 5, $08
	db -16, 0, 6, $08
	db -8, -8, 7, $08
	db -8, 0, 8, $08
ScreenEffectTemplate5F77:
	db -32, -8, 0, $08
	db -24, -8, 1, $08
	db -24, 0, 2, $08
	db -24, 8, 3, $08
	db -16, -16, 4, $08
	db -16, -8, 5, $08
	db -16, 0, 6, $08
	db -8, -8, 7, $08
	db -8, 0, 8, $08
ScreenEffectPart5F9B: ; steps $11,$27
	screen_effect_part 8, SpriteTiles5760, ScreenEffectTemplate5FAA
ScreenEffectPart5FA0: ; steps $12,$28
	screen_effect_part 9, SpriteTiles57E8, ScreenEffectTemplate5FCA
ScreenEffectPart5FA5: ; steps $13,$29 (unreachable only)
	screen_effect_part 9, SpriteTiles5880, ScreenEffectTemplate5FEE
ScreenEffectTemplate5FAA:
	db 32, -8, 0, $48
	db 32, 0, 1, $48
	db 24, -8, 2, $48
	db 24, 0, 3, $48
	db 16, -8, 4, $48
	db 16, 0, 5, $48
	db 8, -8, 6, $48
	db 8, 0, 7, $48
ScreenEffectTemplate5FCA:
	db 32, -8, 0, $48
	db 32, 0, 1, $48
	db 24, -16, 2, $48
	db 24, -8, 3, $48
	db 24, 0, 4, $48
	db 16, -8, 5, $48
	db 16, 0, 6, $48
	db 8, -8, 7, $48
	db 8, 0, 8, $48
ScreenEffectTemplate5FEE:
	db 32, -8, 0, $48
	db 24, -8, 1, $48
	db 24, 0, 2, $48
	db 24, 8, 3, $48
	db 16, -16, 4, $48
	db 16, -8, 5, $48
	db 16, 0, 6, $48
	db 8, -8, 7, $48
	db 8, 0, 8, $48
ScreenEffectPart6012: ; steps $14,$2A (unreachable only)
	screen_effect_part 7, SpriteTiles5918, ScreenEffectTemplate6021
ScreenEffectPart6017: ; steps $15,$2B (unreachable only)
	screen_effect_part 6, SpriteTiles5990, ScreenEffectTemplate603D
ScreenEffectPart601C: ; steps $16,$2C (unreachable only)
	screen_effect_part 6, SpriteTiles59F8, ScreenEffectTemplate6055
ScreenEffectTemplate6021:
	db -24, -16, 0, $08
	db -24, -8, 1, $08
	db -24, 0, 2, $08
	db -16, -8, 3, $08
	db -16, 0, 4, $08
	db -8, -8, 5, $08
	db -8, 0, 6, $08
ScreenEffectTemplate603D:
	db -24, -8, 0, $08
	db -24, 0, 1, $08
	db -16, -8, 2, $08
	db -16, 0, 3, $08
	db -8, -8, 4, $08
	db -8, 0, 5, $08
ScreenEffectTemplate6055:
	db -24, -8, 0, $08
	db -24, 0, 1, $08
	db -16, -8, 2, $08
	db -16, 0, 3, $08
	db -8, -8, 4, $08
	db -8, 0, 5, $08
ScreenEffectPart606D: ; steps $17,$2D (unreachable only)
	screen_effect_part 7, SpriteTiles5918, ScreenEffectTemplate607C
ScreenEffectPart6072: ; steps $18,$2E (unreachable only)
	screen_effect_part 6, SpriteTiles5990, ScreenEffectTemplate6098
ScreenEffectPart6077: ; steps $19,$2F (unreachable only)
	screen_effect_part 6, SpriteTiles59F8, ScreenEffectTemplate60B0
ScreenEffectTemplate607C:
	db 24, -16, 0, $48
	db 24, -8, 1, $48
	db 24, 0, 2, $48
	db 16, -8, 3, $48
	db 16, 0, 4, $48
	db 8, -8, 5, $48
	db 8, 0, 6, $48
ScreenEffectTemplate6098:
	db 24, -8, 0, $48
	db 24, 0, 1, $48
	db 16, -8, 2, $48
	db 16, 0, 3, $48
	db 8, -8, 4, $48
	db 8, 0, 5, $48
ScreenEffectTemplate60B0:
	db 24, -8, 0, $48
	db 24, 0, 1, $48
	db 16, -8, 2, $48
	db 16, 0, 3, $48
	db 8, -8, 4, $48
	db 8, 0, 5, $48
ScreenEffectPart60C8: ; steps $0F,$1A,$30
	screen_effect_part 7, SpriteTiles5A60, ScreenEffectTemplate60D7
ScreenEffectPart60CD: ; steps $10,$1B,$31
	screen_effect_part 8, SpriteTiles5AD8, ScreenEffectTemplate60F3
ScreenEffectPart60D2: ; steps $11,$1C,$32
	screen_effect_part 9, SpriteTiles5B60, ScreenEffectTemplate6113
ScreenEffectTemplate60D7:
	db -8, -24, 0, $08
	db -8, -16, 1, $08
	db 0, -32, 2, $08
	db 0, -24, 3, $08
	db 0, -16, 4, $08
	db 0, -8, 5, $08
	db 8, -24, 6, $08
ScreenEffectTemplate60F3:
	db -8, -24, 0, $08
	db -8, -16, 1, $08
	db 0, -32, 2, $08
	db 0, -24, 3, $08
	db 0, -16, 4, $08
	db 0, -8, 5, $08
	db 8, -24, 6, $08
	db 8, -16, 7, $08
ScreenEffectTemplate6113:
	db -8, -32, 0, $08
	db -8, -24, 1, $08
	db -8, -16, 2, $08
	db -8, -8, 3, $08
	db 0, -32, 4, $08
	db 0, -24, 5, $08
	db 0, -16, 6, $08
	db 0, -8, 7, $08
	db 8, -16, 8, $08
ScreenEffectPart6137: ; steps $1D,$33 (unreachable only)
	screen_effect_part 7, SpriteTiles5A60, ScreenEffectTemplate6146
ScreenEffectPart613C: ; steps $1E,$34 (unreachable only)
	screen_effect_part 8, SpriteTiles5AD8, ScreenEffectTemplate6162
ScreenEffectPart6141: ; steps $1F,$35 (unreachable only)
	screen_effect_part 9, SpriteTiles5B60, ScreenEffectTemplate6182
ScreenEffectTemplate6146:
	db -8, 24, 0, $28
	db -8, 16, 1, $28
	db 0, 32, 2, $28
	db 0, 24, 3, $28
	db 0, 16, 4, $28
	db 0, 8, 5, $28
	db 8, 24, 6, $28
ScreenEffectTemplate6162:
	db -8, 24, 0, $28
	db -8, 16, 1, $28
	db 0, 32, 2, $28
	db 0, 24, 3, $28
	db 0, 16, 4, $28
	db 0, 8, 5, $28
	db 8, 24, 6, $28
	db 8, 16, 7, $28
ScreenEffectTemplate6182:
	db -8, 32, 0, $28
	db -8, 24, 1, $28
	db -8, 16, 2, $28
	db -8, 8, 3, $28
	db 0, 32, 4, $28
	db 0, 24, 5, $28
	db 0, 16, 6, $28
	db 0, 8, 7, $28
	db 8, 16, 8, $28
ScreenEffectPart61A6: ; steps $20,$36,$43 (unreachable only)
	screen_effect_part 4, SpriteTiles5BF8, ScreenEffectTemplate61B5
ScreenEffectPart61AB: ; steps $21,$37,$44 (unreachable only)
	screen_effect_part 6, SpriteTiles5C40, ScreenEffectTemplate61C5
ScreenEffectPart61B0: ; steps $22,$38,$45 (unreachable only)
	screen_effect_part 6, SpriteTiles5CA8, ScreenEffectTemplate61DD
ScreenEffectTemplate61B5:
	db -8, -16, 0, $08
	db 0, -24, 1, $08
	db 0, -16, 2, $08
	db 0, -8, 3, $08
ScreenEffectTemplate61C5:
	db -8, -24, 0, $08
	db -8, -8, 1, $08
	db 0, -24, 2, $08
	db 0, -16, 3, $08
	db 0, -8, 4, $08
	db 8, -16, 5, $08
ScreenEffectTemplate61DD:
	db -8, -16, 0, $08
	db 0, -24, 1, $08
	db 0, -16, 2, $08
	db 0, -8, 3, $08
	db 8, -16, 4, $08
	db 8, -8, 5, $08
ScreenEffectPart61F5: ; steps $23,$39 (unreachable only)
	screen_effect_part 4, SpriteTiles5BF8, ScreenEffectTemplate6204
ScreenEffectPart61FA: ; steps $24,$3A (unreachable only)
	screen_effect_part 6, SpriteTiles5C40, ScreenEffectTemplate6214
ScreenEffectPart61FF: ; steps $25,$3B (unreachable only)
	screen_effect_part 6, SpriteTiles5CA8, ScreenEffectTemplate622C
ScreenEffectTemplate6204:
	db -8, 16, 0, $28
	db 0, 24, 1, $28
	db 0, 16, 2, $28
	db 0, 8, 3, $28
ScreenEffectTemplate6214:
	db -8, 24, 0, $28
	db -8, 8, 1, $28
	db 0, 24, 2, $28
	db 0, 16, 3, $28
	db 0, 8, 4, $28
	db 8, 16, 5, $28
ScreenEffectTemplate622C:
	db -8, 16, 0, $28
	db 0, 24, 1, $28
	db 0, 16, 2, $28
	db 0, 8, 3, $28
	db 8, 16, 4, $28
	db 8, 8, 5, $28
ScreenEffectPart6244: ; steps $26,$3C (unreachable only)
	screen_effect_part 3, SpriteTiles5D10, ScreenEffectTemplate6253
ScreenEffectPart6249: ; steps $27,$3D (unreachable only)
	screen_effect_part 4, SpriteTiles5D48, ScreenEffectTemplate625F
ScreenEffectPart624E: ; steps $28,$3E (unreachable only)
	screen_effect_part 3, SpriteTiles5D90, ScreenEffectTemplate626F
ScreenEffectTemplate6253:
	db -8, -24, 0, $08
	db -8, -16, 1, $08
	db -8, -8, 2, $08
ScreenEffectTemplate625F:
	db -8, -8, 0, $08
	db 0, -24, 1, $08
	db 0, -16, 2, $08
	db 0, -8, 3, $08
ScreenEffectTemplate626F:
	db -8, -24, 0, $08
	db -8, -16, 1, $08
	db -8, -8, 2, $08
ScreenEffectPart627B: ; steps $1C,$3F (unreachable only)
	screen_effect_part 3, SpriteTiles5D10, ScreenEffectTemplate628A
ScreenEffectPart6280: ; steps $1D,$40 (unreachable only)
	screen_effect_part 4, SpriteTiles5D48, ScreenEffectTemplate6296
ScreenEffectPart6285: ; steps $1E,$41 (unreachable only)
	screen_effect_part 3, SpriteTiles5D90, ScreenEffectTemplate62A6
ScreenEffectTemplate628A:
	db -8, 24, 0, $28
	db -8, 16, 1, $28
	db -8, 8, 2, $28
ScreenEffectTemplate6296:
	db -8, 8, 0, $28
	db 0, 24, 1, $28
	db 0, 16, 2, $28
	db 0, 8, 3, $28
ScreenEffectTemplate62A6:
	db -8, 24, 0, $28
	db -8, 16, 1, $28
	db -8, 8, 2, $28
ScreenEffectPart62B2: ; steps $42 (unreachable only)
	screen_effect_part 3, SpriteTiles5FD0, ScreenEffectTemplate62C1
ScreenEffectPart62B7: ; steps $43 (unreachable only)
	screen_effect_part 4, SpriteTiles6038, ScreenEffectTemplate62D9
ScreenEffectPart62BC: ; steps $44 (unreachable only)
	screen_effect_part 3, SpriteTiles6080, ScreenEffectTemplate62E9
ScreenEffectTemplate62C1:
	db -32, -8, 0, $08
	db -32, 0, 1, $08
	db -24, -8, 2, $08
ScreenEffectUnusedTemplateEntries62CD: ; three unused OAM entries after a 3-entry template
	db $E8, $00, $03, $08
	db $F0, $F8, $04, $08
	db $F8, $F8, $05, $08
ScreenEffectTemplate62D9:
	db -32, 0, 0, $08
	db -24, 0, 1, $08
	db -16, 0, 2, $08
	db -8, 0, 3, $08
ScreenEffectTemplate62E9:
	db -32, -8, 0, $08
	db -32, 0, 1, $08
	db -24, -8, 2, $08
ScreenEffectUnusedTemplateEntries62F5: ; four unused OAM entries after a 3-entry template
	db $F0, $F8, $03, $08
	db $F0, $00, $04, $08
	db $F8, $F8, $05, $08
	db $F8, $00, $06, $08
ScreenEffectPart6305: ; steps $29,$45 (unreachable only)
	screen_effect_part 6, SpriteTiles5FD0, ScreenEffectTemplate6314
ScreenEffectPart630A: ; steps $2A,$46 (unreachable only)
	screen_effect_part 4, SpriteTiles6038, ScreenEffectTemplate632C
ScreenEffectPart630F: ; steps $2B,$47 (unreachable only)
	screen_effect_part 7, SpriteTiles6080, ScreenEffectTemplate633C
ScreenEffectTemplate6314:
	db 32, -8, 0, $48
	db 32, 0, 1, $48
	db 24, -8, 2, $48
	db 24, 0, 3, $48
	db 16, -8, 4, $48
	db 8, -8, 5, $48
ScreenEffectTemplate632C:
	db 32, 0, 0, $48
	db 24, 0, 1, $48
	db 16, 0, 2, $48
	db 8, 0, 3, $48
ScreenEffectTemplate633C:
	db 32, -8, 0, $48
	db 32, 0, 1, $48
	db 24, -8, 2, $48
	db 16, -8, 3, $48
	db 16, 0, 4, $48
	db 8, -8, 5, $48
	db 8, 0, 6, $48

ScreenEffectSteps: ; 72 steps x 3 part pointers; 0 = no part (ROM0 StartScreenEffect starts at step 0)
	dw ScreenEffectPart59E0, 0, 0 ; step $00
	dw ScreenEffectPart59E5, 0, 0 ; step $01
	dw ScreenEffectPart59EA, ScreenEffectPart5AB6, 0 ; step $02
	dw ScreenEffectPart5A4B, ScreenEffectPart5ABB, 0 ; step $03
	dw ScreenEffectPart5A50, ScreenEffectPart5AC0, 0 ; step $04
	dw ScreenEffectPart5A55, ScreenEffectPart5D83, 0 ; step $05
	dw ScreenEffectPart5AB6, ScreenEffectPart5D88, 0 ; step $06
	dw ScreenEffectPart5ABB, ScreenEffectPart5D8D, 0 ; step $07
	dw ScreenEffectPart5AC0, ScreenEffectPart5E0E, 0 ; step $08
	dw ScreenEffectPart5B21, ScreenEffectPart5E13, 0 ; step $09
	dw ScreenEffectPart5B26, ScreenEffectPart5E18, 0 ; step $0A
	dw ScreenEffectPart5B2B, ScreenEffectPart5E99, 0 ; step $0B
	dw ScreenEffectPart5B8C, ScreenEffectPart5E9E, 0 ; step $0C
	dw ScreenEffectPart5B91, ScreenEffectPart5EA3, 0 ; step $0D
	dw ScreenEffectPart5B96, ScreenEffectPart5F24, 0 ; step $0E
	dw ScreenEffectPart5BE7, ScreenEffectPart5F29, ScreenEffectPart60C8 ; step $0F
	dw ScreenEffectPart5BEC, ScreenEffectPart5F2E, ScreenEffectPart60CD ; step $10
	dw ScreenEffectPart5BF1, ScreenEffectPart5F9B, ScreenEffectPart60D2 ; step $11
	dw ScreenEffectPart5C42, ScreenEffectPart5FA0, 0 ; step $12
	dw ScreenEffectPart5C47, ScreenEffectPart5FA5, 0 ; step $13 (unreachable)
	dw ScreenEffectPart5C4C, ScreenEffectPart6012, 0 ; step $14 (unreachable)
	dw ScreenEffectPart5C9D, ScreenEffectPart6017, 0 ; step $15 (unreachable)
	dw ScreenEffectPart5CA2, ScreenEffectPart601C, 0 ; step $16 (unreachable)
	dw ScreenEffectPart5CA7, ScreenEffectPart606D, 0 ; step $17 (unreachable)
	dw ScreenEffectPart5CF8, ScreenEffectPart6072, 0 ; step $18 (unreachable)
	dw ScreenEffectPart5CFD, ScreenEffectPart6077, 0 ; step $19 (unreachable)
	dw ScreenEffectPart5D02, ScreenEffectPart60C8, 0 ; step $1A (unreachable)
	dw ScreenEffectPart5D83, ScreenEffectPart60CD, 0 ; step $1B (unreachable)
	dw ScreenEffectPart5D88, ScreenEffectPart60D2, ScreenEffectPart627B ; step $1C (unreachable)
	dw ScreenEffectPart5D8D, ScreenEffectPart6137, ScreenEffectPart6280 ; step $1D (unreachable)
	dw ScreenEffectPart5E0E, ScreenEffectPart613C, ScreenEffectPart6285 ; step $1E (unreachable)
	dw ScreenEffectPart5E13, ScreenEffectPart6141, 0 ; step $1F (unreachable)
	dw ScreenEffectPart5E18, ScreenEffectPart61A6, 0 ; step $20 (unreachable)
	dw ScreenEffectPart5E99, ScreenEffectPart61AB, 0 ; step $21 (unreachable)
	dw ScreenEffectPart5E9E, ScreenEffectPart61B0, 0 ; step $22 (unreachable)
	dw ScreenEffectPart5EA3, ScreenEffectPart61F5, 0 ; step $23 (unreachable)
	dw ScreenEffectPart5F24, ScreenEffectPart61FA, 0 ; step $24 (unreachable)
	dw ScreenEffectPart5F29, ScreenEffectPart61FF, 0 ; step $25 (unreachable)
	dw ScreenEffectPart5F2E, ScreenEffectPart6244, 0 ; step $26 (unreachable)
	dw ScreenEffectPart5F9B, ScreenEffectPart6249, 0 ; step $27 (unreachable)
	dw ScreenEffectPart5FA0, ScreenEffectPart624E, 0 ; step $28 (unreachable)
	dw ScreenEffectPart5FA5, ScreenEffectPart6305, 0 ; step $29 (unreachable)
	dw ScreenEffectPart6012, ScreenEffectPart630A, 0 ; step $2A (unreachable)
	dw ScreenEffectPart6017, ScreenEffectPart630F, ScreenEffectPart5B21 ; step $2B (unreachable)
	dw ScreenEffectPart601C, ScreenEffectPart59E0, ScreenEffectPart5B26 ; step $2C (unreachable)
	dw ScreenEffectPart606D, ScreenEffectPart59E5, ScreenEffectPart5B2B ; step $2D (unreachable)
	dw ScreenEffectPart6072, ScreenEffectPart59EA, 0 ; step $2E (unreachable)
	dw ScreenEffectPart6077, 0, 0 ; step $2F (unreachable)
	dw ScreenEffectPart60C8, 0, 0 ; step $30 (unreachable)
	dw ScreenEffectPart60CD, 0, 0 ; step $31 (unreachable)
	dw ScreenEffectPart60D2, ScreenEffectPart5A4B, 0 ; step $32 (unreachable)
	dw ScreenEffectPart6137, ScreenEffectPart5A50, 0 ; step $33 (unreachable)
	dw ScreenEffectPart613C, ScreenEffectPart5A55, 0 ; step $34 (unreachable)
	dw ScreenEffectPart6141, ScreenEffectPart5AB6, 0 ; step $35 (unreachable)
	dw ScreenEffectPart61A6, ScreenEffectPart5ABB, 0 ; step $36 (unreachable)
	dw ScreenEffectPart61AB, ScreenEffectPart5AC0, 0 ; step $37 (unreachable)
	dw ScreenEffectPart61B0, ScreenEffectPart5B21, 0 ; step $38 (unreachable)
	dw ScreenEffectPart61F5, ScreenEffectPart5B26, 0 ; step $39 (unreachable)
	dw ScreenEffectPart61FA, ScreenEffectPart5B2B, 0 ; step $3A (unreachable)
	dw ScreenEffectPart61FF, ScreenEffectPart5B8C, 0 ; step $3B (unreachable)
	dw ScreenEffectPart6244, ScreenEffectPart5B91, 0 ; step $3C (unreachable)
	dw ScreenEffectPart6249, ScreenEffectPart5B96, 0 ; step $3D (unreachable)
	dw ScreenEffectPart624E, ScreenEffectPart5BE7, 0 ; step $3E (unreachable)
	dw ScreenEffectPart627B, ScreenEffectPart5BEC, 0 ; step $3F (unreachable)
	dw ScreenEffectPart6280, ScreenEffectPart5BF1, 0 ; step $40 (unreachable)
	dw ScreenEffectPart6285, ScreenEffectPart5C42, 0 ; step $41 (unreachable)
	dw ScreenEffectPart62B2, ScreenEffectPart5C47, 0 ; step $42 (unreachable)
	dw ScreenEffectPart62B7, ScreenEffectPart5C4C, ScreenEffectPart61A6 ; step $43 (unreachable)
	dw ScreenEffectPart62BC, ScreenEffectPart5C9D, ScreenEffectPart61AB ; step $44 (unreachable)
	dw ScreenEffectPart6305, ScreenEffectPart5CA2, ScreenEffectPart61B0 ; step $45 (unreachable)
	dw ScreenEffectPart630A, ScreenEffectPart5CA7, 0 ; step $46 (unreachable)
	dw ScreenEffectPart630F, 0, 0 ; step $47 (unreachable)
ScreenEffectStepsEnd:

	ds $7FFF - @, $00
	db BANK(@)

	ASSERT ScreenEffectSteps == $6358, "raw pointer: ROM0 StartScreenEffect (ld a,$58 / ld a,$63)"
	ASSERT ScreenEffectStepsEnd - ScreenEffectSteps == 72 * 6
