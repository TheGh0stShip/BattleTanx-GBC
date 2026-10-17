; Per-level object sequence tables from bank $03:$4018-$5BF2.
; Each level has 64 object slots. A non-null pointer selects a counted
; sequence of eight-byte records; field meanings remain partly unknown.

Level00ObjectSequences:
	dw Level00ObjectSequence00, Level00ObjectSequence01, Level00ObjectSequence02, Level00ObjectSequence03, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

Level00ObjectSequence00:
	db 4
	db $04, $48, $00, $2C, $26, $00, $00, $00 ; point 0
	db $08, $40, $00, $35, $26, $00, $00, $00 ; point 1
	db $08, $48, $00, $35, $2E, $00, $00, $00 ; point 2
	db $00, $00, $00, $35, $37, $02, $00, $00 ; point 3

Level00ObjectSequence01:
	db 4
	db $04, $30, $00, $0C, $27, $00, $00, $00 ; point 0
	db $00, $38, $00, $12, $27, $00, $00, $00 ; point 1
	db $04, $28, $00, $12, $20, $00, $00, $00 ; point 2
	db $0C, $00, $00, $17, $20, $02, $00, $00 ; point 3

Level00ObjectSequence02:
	db 3
	db $04, $B0, $00, $06, $06, $00, $00, $00 ; point 0
	db $08, $40, $00, $1C, $06, $00, $00, $00 ; point 1
	db $00, $86, $00, $1C, $0E, $02, $00, $00 ; point 2

Level00ObjectSequence03:
	db 2
	db $0C, $90, $00, $3C, $08, $00, $00, $00 ; point 0
	db $04, $40, $00, $2A, $08, $02, $00, $00 ; point 1

ASSERT @ - Level00ObjectSequence03 == $11

Level01ObjectSequences:
	dw Level01ObjectSequence00, Level01ObjectSequence01, Level01ObjectSequence02, Level01ObjectSequence03, Level01ObjectSequence04, Level01ObjectSequence05, Level01ObjectSequence06, Level01ObjectSequence07
	dw Level01ObjectSequence08, Level01ObjectSequence09, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

Level01ObjectSequence00:
	db 4
	db $00, $38, $00, $22, $2A, $00, $00, $00 ; point 0
	db $00, $18, $00, $22, $23, $00, $00, $00 ; point 1
	db $04, $30, $00, $22, $20, $05, $24, $24 ; point 2
	db $0C, $00, $00, $28, $20, $02, $00, $00 ; point 3

Level01ObjectSequence01:
	db 5
	db $04, $38, $00, $03, $32, $00, $00, $00 ; point 0
	db $04, $70, $00, $0A, $32, $05, $24, $24 ; point 1
	db $04, $28, $00, $18, $32, $00, $00, $00 ; point 2
	db $08, $70, $00, $1D, $32, $05, $28, $28 ; point 3
	db $00, $00, $00, $1D, $40, $02, $00, $00 ; point 4

Level01ObjectSequence02:
	db 5
	db $0C, $38, $00, $0A, $52, $00, $00, $00 ; point 0
	db $00, $38, $00, $03, $52, $00, $00, $00 ; point 1
	db $04, $40, $00, $03, $4B, $05, $24, $24 ; point 2
	db $08, $30, $00, $0B, $4B, $00, $00, $00 ; point 3
	db $00, $00, $00, $0B, $51, $02, $00, $00 ; point 4

Level01ObjectSequence03:
	db 5
	db $0C, $38, $00, $1A, $04, $00, $00, $00 ; point 0
	db $08, $20, $00, $13, $04, $00, $00, $00 ; point 1
	db $04, $40, $00, $13, $08, $00, $00, $00 ; point 2
	db $04, $18, $00, $1B, $08, $05, $28, $28 ; point 3
	db $0C, $80, $01, $1E, $08, $02, $00, $00 ; point 4

Level01ObjectSequence04:
	db 2
	db $04, $70, $00, $0D, $16, $00, $00, $00 ; point 0
	db $0C, $48, $00, $1B, $16, $02, $00, $00 ; point 1

Level01ObjectSequence05:
	db 3
	db $04, $E0, $00, $33, $20, $00, $00, $00 ; point 0
	db $08, $30, $00, $4F, $20, $05, $37, $37 ; point 1
	db $00, $3A, $00, $4F, $26, $02, $00, $00 ; point 2

Level01ObjectSequence06:
	db 5
	db $0C, $38, $00, $44, $04, $00, $00, $00 ; point 0
	db $08, $70, $00, $3D, $04, $00, $00, $00 ; point 1
	db $04, $18, $00, $3D, $12, $00, $00, $00 ; point 2
	db $04, $20, $00, $40, $12, $05, $36, $36 ; point 3
	db $0C, $00, $00, $44, $12, $02, $00, $00 ; point 4

Level01ObjectSequence07:
	db 4
	db $04, $28, $00, $25, $3F, $00, $00, $00 ; point 0
	db $04, $18, $00, $2A, $3F, $05, $20, $20 ; point 1
	db $04, $90, $00, $2D, $3F, $05, $28, $28 ; point 2
	db $0C, $60, $00, $3F, $3F, $02, $00, $00 ; point 3

Level01ObjectSequence08:
	db 3
	db $04, $60, $00, $32, $52, $00, $00, $00 ; point 0
	db $00, $30, $00, $3E, $52, $05, $14, $14 ; point 1
	db $08, $00, $00, $3E, $4C, $02, $00, $00 ; point 2

Level01ObjectSequence09:
	db 3
	db $04, $68, $00, $42, $52, $00, $00, $00 ; point 0
	db $00, $30, $00, $4F, $52, $00, $14, $14 ; point 1
	db $08, $00, $00, $4F, $4C, $02, $00, $00 ; point 2

ASSERT @ - Level01ObjectSequence09 == $19

Level02ObjectSequences:
	dw Level02ObjectSequence00, Level02ObjectSequence01, Level02ObjectSequence02, Level02ObjectSequence03, Level02ObjectSequence04, Level02ObjectSequence05, Level02ObjectSequence06, Level02ObjectSequence07
	dw Level02ObjectSequence08, Level02ObjectSequence09, Level02ObjectSequence10, Level02ObjectSequence11, Level02ObjectSequence12, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

Level02ObjectSequence00:
	db 4
	db $00, $30, $00, $38, $5E, $00, $00, $00 ; point 0
	db $00, $18, $00, $38, $58, $05, $2D, $2D ; point 1
	db $04, $38, $00, $38, $55, $05, $20, $20 ; point 2
	db $0C, $00, $00, $3F, $55, $02, $00, $00 ; point 3

Level02ObjectSequence01:
	db 4
	db $00, $28, $00, $38, $3B, $00, $00, $00 ; point 0
	db $00, $18, $00, $38, $36, $05, $2C, $2C ; point 1
	db $00, $20, $00, $38, $33, $05, $2C, $2C ; point 2
	db $08, $18, $00, $38, $2F, $02, $17, $17 ; point 3

Level02ObjectSequence02:
	db 3
	db $08, $50, $00, $30, $28, $00, $00, $00 ; point 0
	db $08, $38, $00, $30, $32, $05, $20, $20 ; point 1
	db $00, $90, $00, $30, $39, $02, $00, $00 ; point 2

Level02ObjectSequence03:
	db 5
	db $0C, $38, $00, $23, $43, $00, $13, $13 ; point 0
	db $00, $68, $00, $1C, $43, $05, $13, $13 ; point 1
	db $04, $48, $00, $1C, $36, $00, $17, $17 ; point 2
	db $04, $18, $00, $25, $36, $05, $17, $17 ; point 3
	db $0C, $00, $00, $28, $36, $02, $00, $00 ; point 4

Level02ObjectSequence04:
	db 3
	db $00, $50, $00, $14, $62, $00, $00, $00 ; point 0
	db $00, $58, $00, $14, $58, $05, $20, $20 ; point 1
	db $08, $90, $00, $14, $4D, $02, $00, $00 ; point 2

Level02ObjectSequence05:
	db 3
	db $08, $60, $00, $0C, $27, $00, $00, $00 ; point 0
	db $08, $58, $00, $0C, $33, $05, $20, $20 ; point 1
	db $00, $90, $00, $0C, $3E, $02, $00, $00 ; point 2

Level02ObjectSequence06:
	db 3
	db $00, $98, $00, $0C, $1B, $00, $00, $00 ; point 0
	db $04, $20, $00, $0C, $08, $00, $14, $14 ; point 1
	db $0C, $90, $00, $10, $08, $02, $00, $00 ; point 2

Level02ObjectSequence07:
	db 2
	db $04, $50, $00, $1D, $05, $00, $00, $00 ; point 0
	db $0C, $40, $00, $27, $05, $02, $14, $14 ; point 1

Level02ObjectSequence08:
	db 4
	db $04, $48, $00, $2F, $08, $00, $00, $00 ; point 0
	db $04, $38, $00, $38, $08, $05, $18, $18 ; point 1
	db $00, $28, $00, $3F, $08, $05, $1C, $1C ; point 2
	db $08, $18, $00, $3F, $03, $02, $17, $17 ; point 3

Level02ObjectSequence09:
	db 6
	db $04, $50, $00, $18, $1B, $00, $00, $00 ; point 0
	db $08, $18, $00, $22, $1B, $00, $18, $18 ; point 1
	db $04, $20, $00, $22, $1E, $05, $38, $38 ; point 2
	db $00, $18, $00, $26, $1E, $00, $17, $17 ; point 3
	db $04, $68, $00, $26, $1B, $00, $00, $00 ; point 4
	db $0C, $00, $00, $33, $1B, $02, $00, $00 ; point 5

Level02ObjectSequence10:
	db 3
	db $08, $20, $00, $39, $14, $00, $00, $00 ; point 0
	db $04, $38, $00, $39, $18, $05, $10, $10 ; point 1
	db $0C, $40, $00, $40, $18, $02, $38, $38 ; point 2

Level02ObjectSequence11:
	db 2
	db $00, $50, $00, $30, $5C, $00, $00, $00 ; point 0
	db $08, $00, $00, $30, $52, $02, $00, $00 ; point 1

Level02ObjectSequence12:
	db 2
	db $08, $38, $00, $38, $44, $00, $00, $00 ; point 0
	db $00, $60, $00, $38, $4B, $02, $2C, $2C ; point 1

ASSERT @ - Level02ObjectSequence12 == $11

Level03ObjectSequences:
	dw Level03ObjectSequence00, Level03ObjectSequence01, Level03ObjectSequence02, Level03ObjectSequence03, Level03ObjectSequence04, Level03ObjectSequence05, Level03ObjectSequence06, Level03ObjectSequence07
	dw Level03ObjectSequence08, Level03ObjectSequence09, Level03ObjectSequence10, Level03ObjectSequence11, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

Level03ObjectSequence00:
	db 5
	db $0C, $48, $00, $99, $0E, $00, $00, $00 ; point 0
	db $0C, $50, $00, $90, $0E, $05, $2C, $2C ; point 1
	db $0C, $38, $00, $86, $0E, $05, $2C, $2C ; point 2
	db $0C, $20, $00, $7F, $0E, $05, $2C, $2C ; point 3
	db $04, $00, $00, $7B, $0E, $02, $00, $00 ; point 4

Level03ObjectSequence01:
	db 4
	db $0C, $38, $00, $73, $12, $00, $00, $00 ; point 0
	db $00, $20, $00, $6C, $12, $00, $2C, $2C ; point 1
	db $04, $38, $00, $6C, $0E, $00, $2C, $2C ; point 2
	db $0C, $10, $00, $73, $0E, $02, $2C, $2C ; point 3

Level03ObjectSequence02:
	db 4
	db $04, $A0, $00, $72, $21, $00, $00, $00 ; point 0
	db $08, $48, $00, $86, $21, $00, $2C, $2C ; point 1
	db $0B, $09, $00, $86, $2A, $05, $3B, $3B ; point 2
	db $03, $10, $00, $85, $2A, $02, $2C, $2C ; point 3

Level03ObjectSequence03:
	db 3
	db $0C, $40, $00, $76, $2A, $00, $00, $00 ; point 0
	db $0C, $38, $00, $6E, $2A, $00, $2C, $2C ; point 1
	db $04, $09, $00, $67, $2A, $02, $3B, $3B ; point 2

Level03ObjectSequence04:
	db 4
	db $08, $40, $00, $5C, $1F, $00, $00, $00 ; point 0
	db $08, $18, $00, $5C, $27, $00, $2C, $2C ; point 1
	db $04, $38, $00, $5C, $2A, $00, $3B, $3B ; point 2
	db $0C, $10, $00, $63, $2A, $02, $2C, $2C ; point 3

Level03ObjectSequence05:
	db 5
	db $00, $30, $00, $4B, $29, $00, $00, $00 ; point 0
	db $00, $38, $00, $4B, $23, $05, $10, $10 ; point 1
	db $00, $30, $00, $4B, $1C, $05, $18, $18 ; point 2
	db $00, $18, $00, $4B, $16, $05, $18, $18 ; point 3
	db $08, $00, $00, $4B, $13, $02, $00, $00 ; point 4

Level03ObjectSequence06:
	db 3
	db $00, $28, $00, $49, $0A, $00, $00, $00 ; point 0
	db $0C, $68, $00, $49, $05, $05, $10, $10 ; point 1
	db $00, $30, $00, $3C, $05, $05, $18, $18 ; point 2

; Sequence 06 advances here after point 2. These bytes are interpreted as the
; pseudo-record 04 0C 30 00 3A 22 00 00, targeting tile (0, $3A).
Level03ObjectSequence06Overread:
Level03ObjectSequence07:
	db 4
	db $0C, $30, $00, $3A, $22, $00, $00, $00 ; point 0
	db $08, $40, $00, $34, $22, $05, $10, $10 ; point 1
	db $04, $30, $00, $34, $2A, $05, $18, $18 ; point 2
	db $0C, $18, $00, $3A, $2A, $02, $18, $18 ; point 3

Level03ObjectSequence08:
	db 4
	db $04, $48, $00, $20, $2A, $00, $00, $00 ; point 0
	db $00, $50, $00, $29, $2A, $05, $10, $10 ; point 1
	db $00, $30, $00, $29, $20, $05, $10, $10 ; point 2
	db $08, $18, $00, $29, $1A, $02, $18, $18 ; point 3

Level03ObjectSequence09:
	db 4
	db $04, $50, $00, $1F, $06, $00, $00, $00 ; point 0
	db $08, $60, $00, $29, $06, $05, $2C, $2C ; point 1
	db $0C, $18, $00, $29, $12, $05, $18, $18 ; point 2
	db $04, $18, $00, $26, $12, $02, $18, $18 ; point 3

Level03ObjectSequence10:
	db 4
	db $00, $30, $00, $18, $0B, $00, $00, $00 ; point 0
	db $0C, $90, $00, $18, $05, $05, $1C, $1C ; point 1
	db $08, $60, $00, $06, $05, $05, $18, $18 ; point 2
	db $00, $18, $00, $06, $11, $02, $18, $18 ; point 3

Level03ObjectSequence11:
	db 4
	db $05, $10, $00, $0F, $29, $00, $00, $00 ; point 0
	db $04, $40, $00, $11, $29, $05, $1C, $1C ; point 1
	db $00, $50, $00, $19, $29, $00, $18, $18 ; point 2
	db $08, $18, $00, $19, $1F, $02, $18, $18 ; point 3

ASSERT @ - Level03ObjectSequence11 == $21

Level04ObjectSequences:
	dw Level04ObjectSequence00, $0000, Level04ObjectSequence02, Level04ObjectSequence03, Level04ObjectSequence04, Level04ObjectSequence05, Level04ObjectSequence06, Level04ObjectSequence07
	dw Level04ObjectSequence08, Level04ObjectSequence09, Level04ObjectSequence10, Level04ObjectSequence11, Level04ObjectSequence12, Level04ObjectSequence13, Level04ObjectSequence14, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

Level04ObjectSequence00:
	db 3
	db $08, $30, $00, $26, $12, $00, $00, $00 ; point 0
	db $0C, $50, $00, $26, $18, $00, $00, $00 ; point 1
	db $04, $00, $00, $1C, $18, $02, $00, $00 ; point 2

Level04ObjectSequence02:
	db 2
	db $08, $58, $00, $10, $1B, $00, $00, $00 ; point 0
	db $00, $6D, $00, $10, $26, $02, $00, $00 ; point 1

Level04ObjectSequence03:
	db 2
	db $08, $60, $00, $1A, $21, $00, $00, $00 ; point 0
	db $00, $6D, $00, $1A, $2D, $02, $00, $00 ; point 1

Level04ObjectSequence04:
	db 2
	db $04, $48, $00, $16, $37, $00, $00, $00 ; point 0
	db $0C, $37, $01, $1F, $37, $02, $00, $00 ; point 1

Level04ObjectSequence05:
	db 3
	db $0C, $40, $00, $0E, $34, $00, $00, $00 ; point 0
	db $08, $78, $00, $06, $34, $00, $20, $20 ; point 1
	db $00, $00, $00, $06, $43, $02, $00, $00 ; point 2

Level04ObjectSequence06:
	db 3
	db $08, $40, $00, $06, $4A, $00, $00, $00 ; point 0
	db $04, $50, $00, $06, $52, $05, $20, $20 ; point 1
	db $0C, $00, $00, $10, $52, $02, $00, $00 ; point 2

Level04ObjectSequence07:
	db 3
	db $0C, $40, $00, $22, $51, $00, $00, $00 ; point 0
	db $00, $50, $00, $1A, $51, $05, $2C, $2C ; point 1
	db $08, $00, $00, $1A, $47, $02, $00, $00 ; point 2

Level04ObjectSequence08:
	db 2
	db $04, $98, $00, $29, $46, $00, $00, $00 ; point 0
	db $0C, $1E, $01, $3C, $46, $02, $00, $00 ; point 1

Level04ObjectSequence09:
	db 3
	db $04, $40, $00, $2E, $52, $00, $00, $00 ; point 0
	db $04, $50, $00, $36, $52, $05, $20, $20 ; point 1
	db $0C, $37, $01, $40, $52, $02, $00, $00 ; point 2

Level04ObjectSequence10:
	db 3
	db $04, $30, $00, $4B, $52, $00, $00, $00 ; point 0
	db $00, $50, $00, $51, $52, $05, $2C, $2C ; point 1
	db $08, $00, $00, $51, $48, $02, $00, $00 ; point 2

Level04ObjectSequence11:
	db 3
	db $00, $80, $00, $50, $3A, $00, $00, $00 ; point 0
	db $00, $38, $00, $50, $2A, $05, $18, $18 ; point 1
	db $08, $00, $00, $50, $23, $02, $00, $00 ; point 2

Level04ObjectSequence12:
	db 4
	db $08, $08, $00, $3D, $05, $00, $00, $00 ; point 0
	db $04, $58, $00, $3D, $06, $00, $00, $00 ; point 1
	db $08, $48, $00, $48, $06, $00, $00, $00 ; point 2
	db $00, $00, $00, $48, $0F, $02, $00, $00 ; point 3

Level04ObjectSequence13:
	db 3
	db $0C, $48, $00, $3F, $12, $00, $00, $00 ; point 0
	db $0C, $30, $00, $36, $12, $00, $00, $00 ; point 1
	db $04, $37, $01, $30, $12, $02, $00, $00 ; point 2

Level04ObjectSequence14:
	db 2
	db $08, $48, $00, $36, $1F, $00, $00, $00 ; point 0
	db $00, $00, $01, $36, $28, $02, $00, $00 ; point 1

ASSERT @ - Level04ObjectSequence14 == $11

Level05ObjectSequences:
	dw Level05ObjectSequence00, Level05ObjectSequence01, Level05ObjectSequence02, Level05ObjectSequence03, Level05ObjectSequence04, Level05ObjectSequence05, Level05ObjectSequence06, Level05ObjectSequence07
	dw Level05ObjectSequence08, Level05ObjectSequence09, Level05ObjectSequence10, Level05ObjectSequence11, Level05ObjectSequence12, Level05ObjectSequence13, Level05ObjectSequence14, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

Level05ObjectSequence00:
	db 4
	db $04, $28, $00, $0A, $63, $00, $00, $00 ; point 0
	db $00, $30, $00, $0F, $63, $00, $00, $00 ; point 1
	db $04, $38, $00, $0F, $5D, $05, $24, $24 ; point 2
	db $0C, $40, $00, $16, $5D, $02, $00, $00 ; point 3

Level05ObjectSequence01:
	db 3
	db $04, $48, $00, $10, $54, $00, $00, $00 ; point 0
	db $00, $38, $00, $19, $54, $05, $38, $38 ; point 1
	db $08, $00, $00, $19, $4D, $02, $00, $00 ; point 2

Level05ObjectSequence02:
	db 4
	db $0C, $28, $00, $0A, $4E, $00, $00, $00 ; point 0
	db $08, $68, $00, $05, $4E, $00, $00, $00 ; point 1
	db $08, $20, $00, $05, $5B, $05, $0A, $0A ; point 2
	db $00, $00, $00, $05, $5F, $02, $00, $00 ; point 3

Level05ObjectSequence03:
	db 3
	db $00, $68, $00, $25, $59, $00, $00, $00 ; point 0
	db $04, $98, $00, $25, $4C, $05, $28, $28 ; point 1
	db $0C, $20, $02, $38, $4C, $02, $00, $00 ; point 2

Level05ObjectSequence04:
	db 2
	db $08, $58, $00, $3E, $33, $00, $00, $00 ; point 0
	db $00, $EE, $01, $3E, $3E, $02, $00, $00 ; point 1

Level05ObjectSequence05:
	db 3
	db $00, $48, $00, $30, $3B, $00, $00, $00 ; point 0
	db $00, $20, $00, $30, $32, $00, $00, $00 ; point 1
	db $08, $20, $02, $30, $2E, $02, $00, $00 ; point 2

Level05ObjectSequence06:
	db 2
	db $00, $E0, $00, $25, $3A, $00, $00, $00 ; point 0
	db $08, $F5, $00, $25, $1E, $02, $00, $00 ; point 1

Level05ObjectSequence07:
	db 5
	db $0C, $20, $00, $1E, $28, $00, $00, $00 ; point 0
	db $08, $08, $00, $1A, $28, $00, $00, $00 ; point 1
	db $0C, $20, $00, $1A, $29, $00, $00, $00 ; point 2
	db $0C, $38, $00, $16, $29, $00, $00, $00 ; point 3
	db $04, $00, $00, $0F, $29, $02, $00, $00 ; point 4

Level05ObjectSequence08:
	db 4
	db $04, $40, $00, $04, $36, $00, $00, $00 ; point 0
	db $08, $48, $00, $0C, $36, $00, $00, $00 ; point 1
	db $04, $38, $00, $0C, $3F, $00, $00, $00 ; point 2
	db $0C, $A2, $00, $13, $3F, $02, $00, $00 ; point 3

Level05ObjectSequence09:
	db 3
	db $08, $50, $00, $1A, $35, $00, $00, $00 ; point 0
	db $04, $38, $00, $1A, $3F, $00, $2C, $2C ; point 1
	db $0C, $10, $01, $21, $3F, $02, $00, $00 ; point 2

Level05ObjectSequence10:
	db 4
	db $0C, $80, $00, $1C, $1B, $00, $00, $00 ; point 0
	db $00, $48, $00, $0C, $1B, $05, $24, $24 ; point 1
	db $00, $40, $00, $0C, $12, $05, $28, $28 ; point 2
	db $08, $40, $00, $0C, $0A, $02, $00, $00 ; point 3

Level05ObjectSequence11:
	db 4
	db $00, $28, $00, $32, $20, $00, $00, $00 ; point 0
	db $04, $60, $00, $32, $1B, $05, $28, $28 ; point 1
	db $08, $28, $00, $3E, $1B, $05, $10, $10 ; point 2
	db $00, $40, $00, $3E, $20, $02, $00, $00 ; point 3

Level05ObjectSequence12:
	db 4
	db $00, $48, $00, $3E, $14, $00, $00, $00 ; point 0
	db $00, $30, $00, $3E, $0B, $05, $18, $18 ; point 1
	db $0C, $40, $00, $3E, $05, $05, $28, $28 ; point 2
	db $04, $40, $00, $36, $05, $02, $00, $00 ; point 3

Level05ObjectSequence13:
	db 3
	db $00, $40, $00, $37, $15, $00, $00, $00 ; point 0
	db $0C, $68, $00, $37, $0D, $00, $00, $00 ; point 1
	db $04, $40, $00, $2A, $0D, $02, $00, $00 ; point 2

Level05ObjectSequence14:
	db 3
	db $04, $60, $00, $12, $0B, $00, $00, $00 ; point 0
	db $08, $48, $00, $1E, $0B, $00, $00, $00 ; point 1
	db $00, $40, $00, $1E, $14, $02, $00, $00 ; point 2

ASSERT @ - Level05ObjectSequence14 == $19

Level06ObjectSequences:
	dw Level06ObjectSequence00, Level06ObjectSequence01, Level06ObjectSequence02, Level06ObjectSequence03, Level06ObjectSequence04, Level06ObjectSequence05, Level06ObjectSequence06, Level06ObjectSequence07
	dw Level06ObjectSequence08, Level06ObjectSequence09, Level06ObjectSequence10, Level06ObjectSequence11, Level06ObjectSequence12, Level06ObjectSequence13, Level06ObjectSequence14, Level06ObjectSequence15
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

Level06ObjectSequence00:
	db 3
	db $08, $20, $00, $50, $3E, $00, $00, $00 ; point 0
	db $0C, $30, $00, $50, $42, $00, $05, $05 ; point 1
	db $04, $00, $00, $4A, $42, $02, $00, $00 ; point 2

Level06ObjectSequence01:
	db 3
	db $0C, $18, $00, $31, $43, $00, $00, $00 ; point 0
	db $00, $48, $00, $2E, $43, $00, $05, $05 ; point 1
	db $08, $00, $00, $2E, $3A, $02, $00, $00 ; point 2

Level06ObjectSequence02:
	db 2
	db $00, $48, $00, $1A, $48, $00, $00, $00 ; point 0
	db $08, $42, $01, $1A, $3F, $02, $05, $05 ; point 1

Level06ObjectSequence03:
	db 3
	db $00, $38, $00, $08, $49, $00, $00, $00 ; point 0
	db $00, $30, $00, $08, $42, $00, $05, $05 ; point 1
	db $08, $00, $00, $08, $3C, $02, $00, $00 ; point 2

Level06ObjectSequence04:
	db 3
	db $08, $20, $00, $08, $2C, $00, $00, $00 ; point 0
	db $04, $48, $00, $08, $30, $00, $05, $05 ; point 1
	db $0C, $58, $00, $11, $30, $02, $00, $00 ; point 2

Level06ObjectSequence05:
	db 3
	db $08, $18, $00, $2C, $17, $00, $00, $00 ; point 0
	db $0C, $48, $00, $2C, $1A, $00, $05, $05 ; point 1
	db $04, $6B, $00, $23, $1A, $02, $00, $00 ; point 2

Level06ObjectSequence06:
	db 4
	db $0C, $40, $00, $2F, $25, $00, $00, $00 ; point 0
	db $0C, $30, $00, $27, $25, $00, $05, $05 ; point 1
	db $0C, $18, $00, $21, $25, $00, $00, $00 ; point 2
	db $04, $00, $00, $1E, $25, $02, $00, $00 ; point 3

Level06ObjectSequence07:
	db 3
	db $04, $50, $00, $10, $06, $00, $00, $00 ; point 0
	db $08, $18, $00, $1A, $06, $00, $05, $05 ; point 1
	db $00, $48, $00, $1A, $09, $02, $00, $00 ; point 2

Level06ObjectSequence08:
	db 3
	db $08, $50, $00, $26, $06, $00, $00, $00 ; point 0
	db $0C, $28, $00, $26, $10, $00, $05, $05 ; point 1
	db $04, $2B, $00, $21, $10, $02, $00, $00 ; point 2

Level06ObjectSequence09:
	db 4
	db $0C, $28, $00, $4A, $26, $00, $00, $00 ; point 0
	db $00, $20, $00, $45, $26, $00, $05, $05 ; point 1
	db $00, $18, $00, $45, $22, $00, $00, $00 ; point 2
	db $08, $44, $00, $45, $1F, $02, $00, $00 ; point 3

Level06ObjectSequence10:
	db 2
	db $08, $30, $00, $3F, $34, $00, $00, $00 ; point 0
	db $00, $70, $00, $3F, $3A, $02, $05, $05 ; point 1

Level06ObjectSequence11:
	db 3
	db $04, $80, $00, $1C, $31, $00, $00, $00 ; point 0
	db $00, $20, $00, $2C, $31, $02, $05, $05 ; point 1
	db $08, $58, $00, $2C, $2D, $02, $00, $00 ; point 2

Level06ObjectSequence12:
	db 3
	db $0C, $38, $00, $16, $1F, $00, $00, $00 ; point 0
	db $0C, $40, $00, $0F, $1F, $02, $05, $05 ; point 1
	db $04, $48, $00, $07, $1F, $02, $00, $00 ; point 2

Level06ObjectSequence13:
	db 2
	db $04, $38, $00, $05, $12, $00, $00, $00 ; point 0
	db $0C, $60, $00, $0C, $12, $02, $05, $05 ; point 1

Level06ObjectSequence14:
	db 3
	db $04, $20, $00, $34, $08, $00, $00, $00 ; point 0
	db $08, $78, $00, $38, $08, $02, $05, $05 ; point 1
	db $00, $71, $00, $38, $17, $02, $00, $00 ; point 2

Level06ObjectSequence15:
	db 2
	db $04, $50, $00, $4A, $10, $00, $00, $00 ; point 0
	db $0C, $38, $00, $54, $10, $00, $05, $05 ; point 1

ASSERT @ - Level06ObjectSequence15 == $11

; Sequence 15 advances here after point 1. The pointer table begins with the
; pseudo-record 24 4D 3D 4D 56 4D 77 4D; heading $24 cannot match a direction
; masked to $0F, so the object remains in its turn loop.
Level06ObjectSequence15Overread:
Level07ObjectSequences:
	dw Level07ObjectSequence00, Level07ObjectSequence01, Level07ObjectSequence02, Level07ObjectSequence03, Level07ObjectSequence04, Level07ObjectSequence05, Level07ObjectSequence06, Level07ObjectSequence07
	dw Level07ObjectSequence08, Level07ObjectSequence09, Level07ObjectSequence10, Level07ObjectSequence11, Level07ObjectSequence12, Level07ObjectSequence13, Level07ObjectSequence14, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

Level07ObjectSequence00:
	db 3
	db $0C, $58, $00, $3B, $2C, $00, $00, $00 ; point 0
	db $00, $48, $00, $30, $2C, $00, $00, $00 ; point 1
	db $08, $00, $00, $30, $23, $02, $00, $00 ; point 2

Level07ObjectSequence01:
	db 3
	db $04, $38, $00, $33, $14, $00, $00, $00 ; point 0
	db $00, $30, $00, $3A, $14, $00, $00, $00 ; point 1
	db $08, $00, $00, $3A, $0E, $02, $00, $00 ; point 2

Level07ObjectSequence02:
	db 4
	db $08, $38, $00, $1F, $05, $00, $00, $00 ; point 0
	db $04, $38, $00, $1F, $0C, $00, $00, $00 ; point 1
	db $00, $38, $00, $26, $0C, $00, $00, $00 ; point 2
	db $08, $00, $00, $26, $05, $02, $00, $00 ; point 3

Level07ObjectSequence03:
	db 3
	db $0C, $30, $00, $43, $66, $00, $00, $00 ; point 0
	db $00, $58, $00, $3D, $66, $00, $00, $00 ; point 1
	db $08, $55, $00, $3D, $5B, $02, $00, $00 ; point 2

Level07ObjectSequence04:
	db 3
	db $0C, $78, $00, $42, $54, $00, $00, $00 ; point 0
	db $08, $20, $00, $33, $54, $00, $00, $00 ; point 1
	db $00, $55, $00, $33, $58, $02, $00, $00 ; point 2

Level07ObjectSequence05:
	db 3
	db $04, $78, $00, $11, $6B, $00, $00, $00 ; point 0
	db $00, $48, $00, $20, $6B, $00, $00, $00 ; point 1
	db $08, $55, $00, $20, $62, $02, $00, $00 ; point 2

Level07ObjectSequence06:
	db 2
	db $08, $30, $00, $13, $58, $00, $00, $00 ; point 0
	db $00, $B8, $01, $13, $5E, $02, $00, $00 ; point 1

Level07ObjectSequence07:
	db 4
	db $0C, $38, $00, $0B, $4D, $00, $00, $00 ; point 0
	db $00, $58, $00, $04, $4D, $00, $00, $00 ; point 1
	db $04, $40, $00, $04, $42, $00, $00, $00 ; point 2
	db $0C, $00, $00, $0C, $42, $02, $00, $00 ; point 3

Level07ObjectSequence08:
	db 3
	db $04, $50, $00, $12, $4A, $00, $00, $00 ; point 0
	db $08, $50, $00, $1C, $4A, $00, $00, $00 ; point 1
	db $00, $C8, $01, $1C, $54, $02, $00, $00 ; point 2

Level07ObjectSequence09:
	db 3
	db $04, $70, $00, $28, $46, $00, $00, $00 ; point 0
	db $00, $20, $00, $36, $46, $00, $00, $00 ; point 1
	db $08, $C8, $01, $36, $42, $02, $00, $00 ; point 2

Level07ObjectSequence10:
	db 3
	db $0C, $78, $00, $45, $37, $00, $00, $00 ; point 0
	db $0C, $60, $00, $36, $37, $00, $00, $00 ; point 1
	db $04, $C8, $01, $2A, $37, $02, $00, $00 ; point 2

Level07ObjectSequence11:
	db 3
	db $04, $48, $00, $09, $39, $00, $00, $00 ; point 0
	db $04, $38, $00, $12, $39, $00, $00, $00 ; point 1
	db $0C, $C8, $01, $19, $39, $02, $00, $00 ; point 2

Level07ObjectSequence12:
	db 3
	db $0C, $30, $00, $12, $2C, $00, $00, $00 ; point 0
	db $00, $40, $00, $0C, $2C, $00, $00, $00 ; point 1
	db $08, $C8, $01, $0C, $24, $02, $00, $00 ; point 2

Level07ObjectSequence13:
	db 4
	db $0C, $58, $00, $13, $1C, $00, $00, $00 ; point 0
	db $00, $60, $00, $08, $1C, $00, $00, $00 ; point 1
	db $04, $20, $00, $08, $10, $00, $00, $00 ; point 2
	db $0C, $00, $00, $0C, $10, $02, $00, $00 ; point 3

Level07ObjectSequence14:
	db 3
	db $04, $48, $00, $39, $1C, $00, $00, $00 ; point 0
	db $00, $28, $00, $42, $1C, $00, $00, $00 ; point 1
	db $08, $00, $00, $42, $17, $02, $00, $00 ; point 2

ASSERT @ - Level07ObjectSequence14 == $19

Level08ObjectSequences:
	dw Level08ObjectSequence00, Level08ObjectSequence01, Level08ObjectSequence02, Level08ObjectSequence03, Level08ObjectSequence04, Level08ObjectSequence05, Level08ObjectSequence06, Level08ObjectSequence07
	dw Level08ObjectSequence08, Level08ObjectSequence09, Level08ObjectSequence10, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

Level08ObjectSequence00:
	db 3
	db $0C, $58, $00, $1A, $0B, $00, $00, $00 ; point 0
	db $00, $30, $00, $0F, $0B, $00, $00, $00 ; point 1
	db $08, $30, $00, $0F, $05, $02, $00, $00 ; point 2

Level08ObjectSequence01:
	db 2
	db $04, $78, $00, $05, $27, $00, $00, $00 ; point 0
	db $0C, $30, $00, $14, $27, $02, $00, $00 ; point 1

Level08ObjectSequence02:
	db 3
	db $08, $38, $00, $1F, $20, $00, $00, $00 ; point 0
	db $04, $A0, $00, $1F, $27, $02, $00, $00 ; point 1
	db $0C, $30, $00, $33, $27, $02, $00, $00 ; point 2

Level08ObjectSequence03:
	db 3
	db $04, $30, $00, $37, $42, $00, $00, $00 ; point 0
	db $04, $40, $00, $3D, $42, $00, $00, $00 ; point 1
	db $0C, $30, $00, $45, $42, $02, $00, $00 ; point 2

Level08ObjectSequence04:
	db 2
	db $04, $90, $00, $1C, $42, $00, $00, $00 ; point 0
	db $0C, $40, $00, $2E, $42, $02, $00, $00 ; point 1

Level08ObjectSequence05:
	db 3
	db $08, $68, $00, $5D, $35, $00, $00, $00 ; point 0
	db $04, $58, $00, $5D, $42, $00, $00, $00 ; point 1
	db $0C, $30, $00, $68, $42, $02, $00, $00 ; point 2

Level08ObjectSequence06:
	db 2
	db $04, $98, $00, $38, $2D, $00, $00, $00 ; point 0
	db $0C, $60, $00, $4B, $2D, $02, $00, $00 ; point 1

Level08ObjectSequence07:
	db 3
	db $08, $50, $00, $68, $08, $00, $00, $00 ; point 0
	db $04, $20, $00, $68, $12, $00, $00, $00 ; point 1
	db $0C, $30, $00, $6C, $12, $02, $00, $00 ; point 2

Level08ObjectSequence08:
	db 2
	db $0C, $60, $00, $39, $18, $00, $00, $00 ; point 0
	db $04, $40, $00, $2D, $18, $02, $00, $00 ; point 1

Level08ObjectSequence09:
	db 2
	db $0C, $70, $00, $58, $27, $00, $00, $00 ; point 0
	db $04, $40, $00, $4A, $27, $02, $00, $00 ; point 1

Level08ObjectSequence10:
	db 2
	db $08, $88, $00, $58, $08, $00, $00, $00 ; point 0
	db $00, $40, $00, $58, $19, $02, $00, $00 ; point 1

ASSERT @ - Level08ObjectSequence10 == $11

Level09ObjectSequences:
	dw $0000, Level09ObjectSequence01, Level09ObjectSequence02, Level09ObjectSequence03, Level09ObjectSequence04, Level09ObjectSequence05, Level09ObjectSequence06, Level09ObjectSequence07
	dw Level09ObjectSequence08, Level09ObjectSequence09, Level09ObjectSequence10, Level09ObjectSequence11, Level09ObjectSequence12, Level09ObjectSequence13, Level09ObjectSequence14, Level09ObjectSequence15
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

Level09ObjectSequence01:
	db 2
	db $04, $60, $00, $2D, $1A, $00, $00, $00 ; point 0
	db $0C, $82, $00, $39, $1A, $02, $00, $00 ; point 1

Level09ObjectSequence02:
	db 3
	db $0C, $20, $00, $0E, $1A, $00, $00, $00 ; point 0
	db $0C, $28, $00, $0A, $1A, $00, $00, $00 ; point 1
	db $04, $20, $00, $05, $1A, $02, $00, $00 ; point 2

Level09ObjectSequence03:
	db 4
	db $08, $28, $00, $12, $25, $00, $00, $00 ; point 0
	db $0C, $40, $00, $12, $2A, $00, $00, $00 ; point 1
	db $08, $28, $00, $0A, $2A, $00, $14, $14 ; point 2
	db $00, $00, $00, $0A, $2F, $02, $00, $00 ; point 3

Level09ObjectSequence04:
	db 3
	db $08, $28, $00, $2E, $25, $00, $00, $00 ; point 0
	db $04, $50, $00, $2E, $2A, $00, $00, $00 ; point 1
	db $0C, $B0, $00, $38, $2A, $02, $00, $00 ; point 2

Level09ObjectSequence05:
	db 4
	db $04, $40, $00, $03, $3A, $00, $00, $00 ; point 0
	db $08, $20, $00, $0B, $3A, $00, $00, $00 ; point 1
	db $04, $28, $00, $0B, $3E, $00, $00, $00 ; point 2
	db $0C, $00, $00, $10, $3E, $02, $00, $00 ; point 3

Level09ObjectSequence06:
	db 4
	db $04, $28, $00, $21, $3F, $00, $00, $00 ; point 0
	db $04, $28, $00, $26, $3F, $00, $00, $00 ; point 1
	db $04, $20, $00, $2B, $3F, $00, $00, $00 ; point 2
	db $0C, $00, $00, $2F, $3F, $02, $00, $00 ; point 3

Level09ObjectSequence07:
	db 5
	db $08, $20, $00, $33, $32, $00, $00, $00 ; point 0
	db $04, $18, $00, $33, $36, $00, $00, $00 ; point 1
	db $08, $18, $00, $36, $36, $00, $00, $00 ; point 2
	db $04, $28, $00, $36, $39, $00, $00, $00 ; point 3
	db $0C, $00, $00, $3B, $39, $02, $00, $00 ; point 4

Level09ObjectSequence08:
	db 3
	db $08, $40, $00, $0B, $49, $00, $00, $00 ; point 0
	db $0C, $30, $00, $0B, $51, $00, $00, $00 ; point 1
	db $04, $ED, $00, $05, $51, $02, $00, $00 ; point 2

Level09ObjectSequence09:
	db 3
	db $04, $58, $00, $15, $51, $00, $00, $00 ; point 0
	db $00, $30, $00, $20, $51, $00, $00, $00 ; point 1
	db $08, $ED, $00, $20, $4B, $02, $00, $00 ; point 2

Level09ObjectSequence10:
	db 4
	db $08, $40, $00, $35, $47, $00, $00, $00 ; point 0
	db $08, $10, $00, $35, $4F, $00, $00, $00 ; point 1
	db $04, $30, $00, $35, $51, $00, $00, $00 ; point 2
	db $0C, $23, $01, $3B, $51, $02, $00, $00 ; point 3

Level09ObjectSequence11:
	db 4
	db $0C, $30, $00, $3B, $5B, $00, $00, $00 ; point 0
	db $08, $40, $00, $35, $5B, $00, $00, $00 ; point 1
	db $0C, $18, $00, $35, $63, $00, $00, $00 ; point 2
	db $04, $23, $01, $32, $63, $02, $00, $00 ; point 3

Level09ObjectSequence12:
	db 3
	db $08, $58, $00, $20, $58, $00, $00, $00 ; point 0
	db $04, $30, $00, $20, $63, $00, $00, $00 ; point 1
	db $0C, $3D, $02, $26, $63, $02, $00, $00 ; point 2

Level09ObjectSequence13:
	db 3
	db $08, $48, $00, $0B, $5A, $00, $00, $00 ; point 0
	db $04, $28, $00, $0B, $63, $00, $00, $00 ; point 1
	db $0C, $3D, $02, $10, $63, $02, $00, $00 ; point 2

Level09ObjectSequence14:
	db 3
	db $08, $30, $00, $0B, $6C, $00, $00, $00 ; point 0
	db $0C, $38, $00, $0B, $72, $00, $00, $00 ; point 1
	db $04, $3D, $02, $04, $72, $02, $00, $00 ; point 2

Level09ObjectSequence15:
	db 3
	db $04, $30, $00, $1A, $72, $00, $00, $00 ; point 0
	db $08, $10, $00, $20, $72, $00, $00, $00 ; point 1
	db $00, $3D, $02, $20, $74, $02, $00, $00 ; point 2

ASSERT @ - Level09ObjectSequence15 == $19

Level10ObjectSequences:
	dw Level10ObjectSequence00, Level10ObjectSequence01, Level10ObjectSequence02, Level10ObjectSequence03, Level10ObjectSequence04, Level10ObjectSequence05, Level10ObjectSequence06, Level10ObjectSequence07
	dw Level10ObjectSequence08, Level10ObjectSequence09, Level10ObjectSequence10, Level10ObjectSequence11, Level10ObjectSequence12, Level10ObjectSequence13, Level10ObjectSequence14, Level10ObjectSequence15
	dw Level10ObjectSequence16, Level10ObjectSequence17, $0000, Level10ObjectSequence19, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

Level10ObjectSequence00:
	db 2
	db $00, $28, $00, $45, $41, $00, $00, $00 ; point 0
	db $08, $00, $00, $45, $3C, $02, $00, $00 ; point 1

Level10ObjectSequence01:
	db 4
	db $0C, $30, $00, $44, $54, $00, $00, $00 ; point 0
	db $00, $38, $00, $3E, $54, $05, $1D, $1D ; point 1
	db $00, $18, $00, $3E, $4D, $05, $13, $13 ; point 2
	db $08, $00, $00, $3E, $4A, $02, $00, $00 ; point 3

Level10ObjectSequence02:
	db 4
	db $00, $18, $00, $34, $52, $00, $00, $00 ; point 0
	db $0C, $70, $00, $34, $4F, $05, $1C, $1C ; point 1
	db $08, $18, $00, $26, $4F, $05, $24, $24 ; point 2
	db $00, $00, $00, $26, $52, $02, $00, $00 ; point 3

Level10ObjectSequence03:
	db 3
	db $00, $38, $00, $17, $54, $00, $00, $00 ; point 0
	db $0C, $38, $00, $17, $4D, $05, $24, $24 ; point 1
	db $04, $9F, $01, $10, $4D, $02, $00, $00 ; point 2

Level10ObjectSequence04:
	db 3
	db $00, $68, $00, $06, $51, $00, $00, $00 ; point 0
	db $04, $40, $00, $06, $44, $05, $28, $28 ; point 1
	db $0C, $9F, $01, $0E, $44, $02, $00, $00 ; point 2

Level10ObjectSequence05:
	db 3
	db $08, $58, $00, $12, $2D, $00, $00, $00 ; point 0
	db $04, $30, $00, $12, $38, $05, $14, $14 ; point 1
	db $0C, $9F, $01, $18, $38, $02, $00, $00 ; point 2

Level10ObjectSequence06:
	db 4
	db $00, $20, $00, $1F, $3E, $00, $00, $00 ; point 0
	db $04, $70, $00, $1F, $3A, $05, $28, $28 ; point 1
	db $00, $18, $00, $2D, $3A, $05, $1C, $1C ; point 2
	db $08, $00, $00, $2D, $37, $02, $00, $00 ; point 3

Level10ObjectSequence07:
	db 3
	db $0C, $20, $00, $22, $2F, $00, $00, $00 ; point 0
	db $0C, $20, $00, $1E, $2F, $00, $00, $00 ; point 1
	db $04, $2F, $01, $1A, $2F, $02, $00, $00 ; point 2

Level10ObjectSequence08:
	db 6
	db $04, $40, $00, $33, $2F, $00, $00, $00 ; point 0
	db $04, $20, $00, $3B, $2F, $00, $00, $00 ; point 1
	db $08, $40, $00, $3F, $2F, $00, $04, $04 ; point 2
	db $0C, $28, $00, $3F, $37, $00, $04, $04 ; point 3
	db $0C, $28, $00, $3A, $37, $00, $00, $00 ; point 4
	db $04, $00, $00, $35, $37, $02, $00, $00 ; point 5

Level10ObjectSequence09:
	db 3
	db $00, $50, $00, $50, $35, $00, $00, $00 ; point 0
	db $0C, $20, $00, $50, $2B, $00, $00, $00 ; point 1
	db $04, $40, $00, $4C, $2B, $02, $00, $00 ; point 2

Level10ObjectSequence10:
	db 2
	db $08, $58, $00, $53, $1A, $00, $00, $00 ; point 0
	db $00, $BA, $01, $53, $25, $02, $00, $00 ; point 1

Level10ObjectSequence11:
	db 2
	db $08, $58, $00, $3F, $1A, $00, $00, $00 ; point 0
	db $00, $BA, $01, $3F, $25, $02, $00, $00 ; point 1

Level10ObjectSequence12:
	db 2
	db $04, $48, $00, $45, $10, $00, $00, $00 ; point 0
	db $0C, $BA, $01, $4E, $10, $02, $00, $00 ; point 1

Level10ObjectSequence13:
	db 3
	db $0C, $30, $00, $18, $16, $00, $00, $00 ; point 0
	db $00, $48, $00, $12, $16, $00, $00, $00 ; point 1
	db $08, $40, $00, $12, $0D, $02, $00, $00 ; point 2

Level10ObjectSequence14:
	db 2
	db $04, $50, $00, $0D, $22, $00, $00, $00 ; point 0
	db $0C, $60, $00, $17, $22, $02, $00, $00 ; point 1

Level10ObjectSequence15:
	db 4
	db $08, $38, $00, $2E, $0F, $00, $00, $00 ; point 0
	db $04, $50, $00, $2E, $16, $00, $00, $00 ; point 1
	db $08, $20, $00, $38, $16, $00, $00, $00 ; point 2
	db $00, $28, $00, $38, $1A, $02, $00, $00 ; point 3

Level10ObjectSequence16:
	db 2
	db $08, $48, $00, $26, $0E, $00, $00, $00 ; point 0
	db $00, $33, $00, $26, $17, $02, $00, $00 ; point 1

Level10ObjectSequence17:
	db 3
	db $08, $10, $00, $31, $21, $00, $00, $00 ; point 0
	db $0C, $28, $00, $31, $23, $00, $00, $00 ; point 1
	db $04, $3A, $00, $2C, $23, $02, $00, $00 ; point 2

Level10ObjectSequence19:
	db 2
	db $00, $58, $00, $06, $3A, $00, $00, $00 ; point 0
	db $08, $C6, $00, $06, $2F, $02, $00, $00 ; point 1

ASSERT @ - Level10ObjectSequence19 == $11

Level11ObjectSequences:
	dw Level11ObjectSequence00, Level11ObjectSequence01, $0000, Level11ObjectSequence03, Level11ObjectSequence04, Level11ObjectSequence05, Level11ObjectSequence06, Level11ObjectSequence07
	dw $0000, Level11ObjectSequence09, Level11ObjectSequence10, Level11ObjectSequence11, Level11ObjectSequence12, Level11ObjectSequence13, Level11ObjectSequence14, Level11ObjectSequence15
	dw Level11ObjectSequence16, Level11ObjectSequence17, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

Level11ObjectSequence00:
	db 4
	db $04, $38, $00, $16, $3C, $00, $00, $00 ; point 0
	db $00, $18, $00, $1D, $3C, $00, $00, $00 ; point 1
	db $04, $40, $00, $1D, $39, $00, $00, $00 ; point 2
	db $0C, $00, $00, $25, $39, $02, $00, $00 ; point 3

Level11ObjectSequence01:
	db 3
	db $04, $50, $00, $2C, $39, $00, $00, $00 ; point 0
	db $00, $98, $00, $36, $39, $00, $00, $00 ; point 1
	db $08, $A8, $00, $36, $26, $02, $00, $00 ; point 2

Level11ObjectSequence03:
	db 2
	db $08, $48, $00, $09, $03, $00, $00, $00 ; point 0
	db $00, $B4, $00, $09, $0C, $02, $00, $00 ; point 1

Level11ObjectSequence04:
	db 3
	db $04, $20, $00, $05, $31, $00, $00, $00 ; point 0
	db $00, $80, $00, $09, $31, $00, $00, $00 ; point 1
	db $08, $A8, $00, $09, $21, $02, $00, $00 ; point 2

Level11ObjectSequence05:
	db 3
	db $08, $48, $00, $21, $07, $00, $00, $00 ; point 0
	db $0C, $80, $00, $21, $10, $00, $00, $00 ; point 1
	db $04, $A8, $00, $11, $10, $02, $00, $00 ; point 2

Level11ObjectSequence06:
	db 3
	db $04, $20, $00, $2A, $06, $00, $00, $00 ; point 0
	db $08, $40, $00, $2E, $06, $00, $00, $00 ; point 1
	db $00, $A8, $00, $2E, $0E, $02, $00, $00 ; point 2

Level11ObjectSequence07:
	db 3
	db $00, $50, $00, $26, $21, $00, $00, $00 ; point 0
	db $04, $40, $00, $26, $17, $00, $00, $00 ; point 1
	db $0C, $A8, $00, $2E, $17, $02, $00, $00 ; point 2

Level11ObjectSequence09:
	db 3
	db $00, $80, $00, $35, $19, $00, $00, $00 ; point 0
	db $04, $38, $00, $35, $09, $00, $00, $00 ; point 1
	db $0C, $A8, $00, $3C, $09, $02, $00, $00 ; point 2

Level11ObjectSequence10:
	db 2
	db $08, $40, $00, $45, $12, $00, $00, $00 ; point 0
	db $00, $38, $01, $45, $1A, $02, $00, $00 ; point 1

Level11ObjectSequence11:
	db 2
	db $08, $58, $00, $45, $2C, $00, $00, $00 ; point 0
	db $00, $38, $01, $45, $37, $02, $00, $00 ; point 1

Level11ObjectSequence12:
	db 2
	db $0C, $38, $00, $73, $05, $00, $00, $00 ; point 0
	db $04, $38, $01, $6C, $05, $02, $00, $00 ; point 1

Level11ObjectSequence13:
	db 3
	db $08, $38, $00, $6A, $26, $00, $00, $00 ; point 0
	db $04, $50, $00, $6A, $2D, $00, $00, $00 ; point 1
	db $0C, $A8, $00, $74, $2D, $02, $00, $00 ; point 2

Level11ObjectSequence14:
	db 3
	db $0C, $48, $00, $72, $1A, $00, $00, $00 ; point 0
	db $08, $48, $00, $69, $1A, $00, $00, $00 ; point 1
	db $00, $A8, $00, $69, $23, $02, $00, $00 ; point 2

Level11ObjectSequence15:
	db 3
	db $0C, $98, $00, $73, $0F, $00, $00, $00 ; point 0
	db $08, $38, $00, $60, $0F, $00, $00, $00 ; point 1
	db $00, $A8, $00, $60, $16, $02, $00, $00 ; point 2

Level11ObjectSequence16:
	db 3
	db $08, $80, $00, $5F, $20, $00, $00, $00 ; point 0
	db $0C, $30, $00, $5F, $30, $00, $00, $00 ; point 1
	db $04, $A8, $00, $59, $30, $02, $00, $00 ; point 2

Level11ObjectSequence17:
	db 3
	db $08, $30, $00, $58, $05, $00, $00, $00 ; point 0
	db $0C, $28, $00, $58, $0B, $00, $00, $00 ; point 1
	db $04, $A8, $00, $53, $0B, $02, $00, $00 ; point 2

ASSERT @ - Level11ObjectSequence17 == $19

Level12ObjectSequences:
	dw Level12ObjectSequence00, Level12ObjectSequence01, Level12ObjectSequence02, Level12ObjectSequence03, Level12ObjectSequence04, Level12ObjectSequence05, Level12ObjectSequence06, Level12ObjectSequence07
	dw Level12ObjectSequence08, Level12ObjectSequence09, Level12ObjectSequence10, Level12ObjectSequence11, Level12ObjectSequence12, Level12ObjectSequence13, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

Level12ObjectSequence00:
	db 4
	db $0C, $50, $00, $36, $05, $00, $00, $00 ; point 0
	db $08, $10, $00, $2C, $05, $00, $00, $00 ; point 1
	db $08, $20, $00, $2C, $07, $00, $00, $00 ; point 2
	db $00, $00, $00, $2C, $0B, $02, $00, $00 ; point 3

Level12ObjectSequence01:
	db 4
	db $0C, $50, $00, $4C, $05, $00, $00, $00 ; point 0
	db $08, $80, $00, $42, $05, $00, $00, $00 ; point 1
	db $04, $30, $00, $42, $15, $00, $00, $00 ; point 2
	db $0C, $00, $00, $48, $15, $02, $00, $00 ; point 3

Level12ObjectSequence02:
	db 2
	db $00, $80, $00, $55, $16, $00, $00, $00 ; point 0
	db $08, $B7, $01, $55, $06, $02, $00, $00 ; point 1

Level12ObjectSequence03:
	db 3
	db $08, $68, $00, $55, $2D, $00, $00, $00 ; point 0
	db $0C, $38, $00, $55, $3A, $00, $00, $00 ; point 1
	db $04, $E0, $01, $4E, $3A, $02, $00, $00 ; point 2

Level12ObjectSequence04:
	db 2
	db $04, $68, $00, $56, $1F, $00, $00, $00 ; point 0
	db $0C, $B7, $01, $63, $1F, $02, $00, $00 ; point 1

Level12ObjectSequence05:
	db 3
	db $00, $48, $00, $6B, $18, $00, $00, $00 ; point 0
	db $00, $28, $00, $6B, $0F, $00, $00, $00 ; point 1
	db $08, $E0, $01, $6B, $0A, $02, $00, $00 ; point 2

Level12ObjectSequence06:
	db 2
	db $00, $60, $00, $6B, $34, $00, $00, $00 ; point 0
	db $08, $40, $02, $6B, $28, $02, $00, $00 ; point 1

Level12ObjectSequence07:
	db 2
	db $0C, $48, $00, $1B, $3A, $00, $00, $00 ; point 0
	db $04, $50, $00, $12, $3A, $02, $00, $00 ; point 1

Level12ObjectSequence08:
	db 3
	db $04, $40, $00, $42, $2B, $00, $00, $00 ; point 0
	db $00, $40, $00, $4A, $2B, $00, $00, $00 ; point 1
	db $08, $E0, $01, $4A, $23, $02, $00, $00 ; point 2

Level12ObjectSequence09:
	db 3
	db $08, $30, $00, $2C, $34, $00, $00, $00 ; point 0
	db $04, $70, $00, $2C, $3A, $00, $00, $00 ; point 1
	db $0C, $00, $00, $3A, $3A, $02, $00, $00 ; point 2

Level12ObjectSequence10:
	db 2
	db $08, $80, $00, $18, $18, $00, $00, $00 ; point 0
	db $00, $48, $00, $18, $28, $02, $00, $00 ; point 1

Level12ObjectSequence11:
	db 2
	db $00, $68, $00, $23, $25, $00, $00, $00 ; point 0
	db $08, $40, $00, $23, $18, $02, $00, $00 ; point 1

Level12ObjectSequence12:
	db 3
	db $0C, $48, $00, $0B, $11, $00, $00, $00 ; point 0
	db $00, $58, $00, $02, $11, $00, $00, $00 ; point 1
	db $08, $E0, $01, $02, $06, $02, $00, $00 ; point 2

Level12ObjectSequence13:
	db 3
	db $0C, $60, $00, $0E, $2E, $00, $00, $00 ; point 0
	db $08, $48, $00, $02, $2E, $00, $00, $00 ; point 1
	db $00, $C0, $00, $02, $37, $02, $00, $00 ; point 2

ASSERT @ - Level12ObjectSequence13 == $19

Level13ObjectSequences:
	dw Level13ObjectSequence00, Level13ObjectSequence01, Level13ObjectSequence02, Level13ObjectSequence03, Level13ObjectSequence04, Level13ObjectSequence05, Level13ObjectSequence06, Level13ObjectSequence07
	dw Level13ObjectSequence08, Level13ObjectSequence09, Level13ObjectSequence10, Level13ObjectSequence11, Level13ObjectSequence12, Level13ObjectSequence13, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

Level13ObjectSequence00:
	db 3
	db $08, $38, $00, $2B, $06, $00, $00, $00 ; point 0
	db $04, $48, $00, $2B, $0D, $05, $08, $08 ; point 1
	db $0C, $21, $00, $34, $0D, $02, $00, $00 ; point 2

Level13ObjectSequence01:
	db 3
	db $04, $30, $00, $3C, $12, $00, $00, $00 ; point 0
	db $04, $30, $00, $42, $12, $05, $2C, $2C ; point 1
	db $0C, $21, $00, $48, $12, $02, $00, $00 ; point 2

Level13ObjectSequence02:
	db 3
	db $0C, $88, $00, $18, $45, $00, $00, $00 ; point 0
	db $08, $48, $00, $07, $45, $05, $16, $16 ; point 1
	db $00, $00, $00, $07, $4E, $02, $00, $00 ; point 2

Level13ObjectSequence03:
	db 4
	db $04, $78, $00, $1C, $55, $00, $00, $00 ; point 0
	db $00, $20, $00, $2B, $55, $00, $00, $00 ; point 1
	db $00, $20, $00, $2B, $51, $05, $20, $20 ; point 2
	db $08, $48, $00, $2B, $4D, $02, $00, $00 ; point 3

Level13ObjectSequence04:
	db 2
	db $04, $38, $00, $49, $06, $00, $00, $00 ; point 0
	db $0C, $68, $00, $50, $06, $02, $00, $00 ; point 1

Level13ObjectSequence05:
	db 4
	db $04, $18, $00, $41, $45, $00, $3C, $3C ; point 0
	db $00, $50, $00, $44, $45, $00, $00, $00 ; point 1
	db $04, $28, $00, $44, $3B, $05, $16, $16 ; point 2
	db $0C, $48, $00, $49, $3B, $02, $00, $00 ; point 3

Level13ObjectSequence06:
	db 3
	db $00, $20, $00, $53, $51, $00, $3C, $3C ; point 0
	db $0C, $38, $00, $53, $4D, $00, $1D, $1D ; point 1
	db $04, $30, $00, $4C, $4D, $02, $16, $16 ; point 2

Level13ObjectSequence07:
	db 2
	db $04, $30, $00, $32, $3E, $00, $3C, $3C ; point 0
	db $0C, $21, $00, $38, $3E, $02, $00, $00 ; point 1

Level13ObjectSequence08:
	db 2
	db $04, $20, $00, $1B, $2D, $00, $00, $00 ; point 0
	db $0C, $28, $00, $1F, $2D, $02, $00, $00 ; point 1

Level13ObjectSequence09:
	db 3
	db $04, $38, $00, $04, $23, $00, $00, $00 ; point 0
	db $00, $60, $00, $0B, $23, $00, $00, $00 ; point 1
	db $08, $21, $00, $0B, $17, $02, $00, $00 ; point 2

Level13ObjectSequence10:
	db 3
	db $08, $30, $00, $0B, $04, $00, $00, $00 ; point 0
	db $08, $20, $00, $0B, $0A, $00, $00, $00 ; point 1
	db $00, $21, $00, $0B, $0E, $02, $00, $00 ; point 2

Level13ObjectSequence11:
	db 2
	db $04, $20, $00, $3D, $29, $00, $00, $00 ; point 0
	db $0C, $68, $00, $41, $29, $02, $00, $00 ; point 1

Level13ObjectSequence12:
	db 3
	db $04, $48, $00, $3B, $4F, $00, $00, $00 ; point 0
	db $08, $28, $00, $44, $4F, $00, $00, $00 ; point 1
	db $00, $21, $00, $44, $54, $02, $00, $00 ; point 2

Level13ObjectSequence13:
	db 2
	db $04, $28, $00, $1C, $34, $00, $00, $00 ; point 0
	db $0C, $28, $00, $21, $34, $02, $00, $00 ; point 1

ASSERT @ - Level13ObjectSequence13 == $11

Level14ObjectSequences:
	dw Level14ObjectSequence00, Level14ObjectSequence01, Level14ObjectSequence02, Level14ObjectSequence03, Level14ObjectSequence04, Level14ObjectSequence05, Level14ObjectSequence06, Level14ObjectSequence07
	dw Level14ObjectSequence08, Level14ObjectSequence09, Level14ObjectSequence10, Level14ObjectSequence11, Level14ObjectSequence12, Level14ObjectSequence13, Level14ObjectSequence14, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

Level14ObjectSequence00:
	db 2
	db $04, $88, $00, $05, $74, $00, $01, $01 ; point 0
	db $0C, $30, $00, $16, $74, $02, $00, $00 ; point 1

Level14ObjectSequence01:
	db 3
	db $08, $40, $00, $35, $0A, $00, $00, $00 ; point 0
	db $04, $28, $00, $35, $12, $00, $00, $00 ; point 1
	db $0C, $38, $00, $3A, $12, $02, $01, $01 ; point 2

Level14ObjectSequence02:
	db 3
	db $08, $48, $00, $0E, $08, $00, $00, $00 ; point 0
	db $0C, $30, $00, $0E, $11, $00, $00, $00 ; point 1
	db $04, $20, $00, $08, $11, $02, $00, $00 ; point 2

Level14ObjectSequence03:
	db 3
	db $00, $20, $00, $1D, $5E, $00, $00, $00 ; point 0
	db $00, $28, $00, $1D, $5A, $00, $01, $01 ; point 1
	db $08, $80, $00, $1D, $55, $02, $00, $00 ; point 2

Level14ObjectSequence04:
	db 2
	db $04, $88, $00, $17, $14, $00, $00, $00 ; point 0
	db $0C, $30, $00, $28, $14, $02, $00, $00 ; point 1

Level14ObjectSequence05:
	db 3
	db $04, $48, $00, $14, $4F, $00, $00, $00 ; point 0
	db $00, $48, $00, $1D, $4F, $00, $00, $00 ; point 1
	db $08, $00, $00, $1D, $46, $02, $00, $00 ; point 2

Level14ObjectSequence06:
	db 3
	db $04, $68, $00, $25, $5D, $00, $00, $00 ; point 0
	db $08, $38, $00, $32, $5D, $00, $00, $00 ; point 1
	db $00, $38, $00, $32, $64, $02, $01, $01 ; point 2

Level14ObjectSequence07:
	db 3
	db $08, $38, $00, $3B, $56, $00, $00, $00 ; point 0
	db $0C, $38, $00, $3B, $5D, $00, $00, $00 ; point 1
	db $04, $38, $00, $34, $5D, $02, $01, $01 ; point 2

Level14ObjectSequence08:
	db 3
	db $00, $40, $00, $3A, $3C, $00, $00, $00 ; point 0
	db $00, $38, $00, $3A, $34, $00, $00, $00 ; point 1
	db $08, $38, $00, $3A, $2D, $02, $01, $01 ; point 2

Level14ObjectSequence09:
	db 3
	db $04, $48, $00, $04, $5C, $00, $00, $00 ; point 0
	db $00, $30, $00, $0D, $5C, $00, $00, $00 ; point 1
	db $08, $30, $00, $0D, $56, $02, $01, $01 ; point 2

Level14ObjectSequence10:
	db 3
	db $08, $48, $00, $07, $32, $00, $00, $00 ; point 0
	db $04, $38, $00, $07, $3B, $00, $00, $00 ; point 1
	db $0C, $38, $00, $0E, $3B, $02, $01, $01 ; point 2

Level14ObjectSequence11:
	db 2
	db $0C, $78, $00, $25, $24, $00, $00, $00 ; point 0
	db $04, $CC, $01, $16, $24, $02, $00, $00 ; point 1

Level14ObjectSequence12:
	db 3
	db $04, $58, $00, $26, $3B, $00, $01, $01 ; point 0
	db $08, $30, $00, $31, $3B, $00, $00, $00 ; point 1
	db $00, $90, $00, $31, $41, $02, $01, $01 ; point 2

Level14ObjectSequence13:
	db 3
	db $0C, $30, $00, $33, $48, $00, $00, $00 ; point 0
	db $08, $38, $00, $2D, $48, $00, $00, $00 ; point 1
	db $00, $90, $00, $2D, $4F, $02, $01, $01 ; point 2

Level14ObjectSequence14:
	db 4
	db $04, $40, $00, $23, $71, $00, $00, $00 ; point 0
	db $08, $18, $00, $2B, $71, $00, $00, $00 ; point 1
	db $04, $40, $00, $2B, $74, $00, $01, $01 ; point 2
	db $0C, $00, $00, $33, $74, $02, $00, $00 ; point 3

ASSERT @ - Level14ObjectSequence14 == $21
