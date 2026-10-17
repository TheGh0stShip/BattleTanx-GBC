; Per-level object sequence tables from bank $03:$4018-$5BF2.
; Each level has 64 object slots. A non-null pointer selects a counted
; sequence of eight-byte records written with seq_point (include/level_data.inc).
; The count byte before each sequence is layout only; no reader checks it.
; seq_point end_action: 0 and 5 behave identically; +6 is read only for
; action 3 or >= 6.
; tools/gen_object_sequences_asm.py emits the older raw `db` form and is
; superseded by this file; do not regenerate it over this source.

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
	db 4 ; record count: layout only; no reader
	seq_point $04, 72, $2C, $26, 0, $00, $00 ; point 0
	seq_point $08, 64, $35, $26, 0, $00, $00 ; point 1
	seq_point $08, 72, $35, $2E, 0, $00, $00 ; point 2
	seq_point $00, 0, $35, $37, 2, $00, $00 ; point 3

Level00ObjectSequence01:
	db 4 ; record count: layout only; no reader
	seq_point $04, 48, $0C, $27, 0, $00, $00 ; point 0
	seq_point $00, 56, $12, $27, 0, $00, $00 ; point 1
	seq_point $04, 40, $12, $20, 0, $00, $00 ; point 2
	seq_point $0C, 0, $17, $20, 2, $00, $00 ; point 3

Level00ObjectSequence02:
	db 3 ; record count: layout only; no reader
	seq_point $04, 176, $06, $06, 0, $00, $00 ; point 0
	seq_point $08, 64, $1C, $06, 0, $00, $00 ; point 1
	seq_point $00, 134, $1C, $0E, 2, $00, $00 ; point 2

Level00ObjectSequence03:
	db 2 ; record count: layout only; no reader
	seq_point $0C, 144, $3C, $08, 0, $00, $00 ; point 0
	seq_point $04, 64, $2A, $08, 2, $00, $00 ; point 1

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
	db 4 ; record count: layout only; no reader
	seq_point $00, 56, $22, $2A, 0, $00, $00 ; point 0
	seq_point $00, 24, $22, $23, 0, $00, $00 ; point 1
	seq_point $04, 48, $22, $20, 5, $24, $24 ; point 2
	seq_point $0C, 0, $28, $20, 2, $00, $00 ; point 3

Level01ObjectSequence01:
	db 5 ; record count: layout only; no reader
	seq_point $04, 56, $03, $32, 0, $00, $00 ; point 0
	seq_point $04, 112, $0A, $32, 5, $24, $24 ; point 1
	seq_point $04, 40, $18, $32, 0, $00, $00 ; point 2
	seq_point $08, 112, $1D, $32, 5, $28, $28 ; point 3
	seq_point $00, 0, $1D, $40, 2, $00, $00 ; point 4

Level01ObjectSequence02:
	db 5 ; record count: layout only; no reader
	seq_point $0C, 56, $0A, $52, 0, $00, $00 ; point 0
	seq_point $00, 56, $03, $52, 0, $00, $00 ; point 1
	seq_point $04, 64, $03, $4B, 5, $24, $24 ; point 2
	seq_point $08, 48, $0B, $4B, 0, $00, $00 ; point 3
	seq_point $00, 0, $0B, $51, 2, $00, $00 ; point 4

Level01ObjectSequence03:
	db 5 ; record count: layout only; no reader
	seq_point $0C, 56, $1A, $04, 0, $00, $00 ; point 0
	seq_point $08, 32, $13, $04, 0, $00, $00 ; point 1
	seq_point $04, 64, $13, $08, 0, $00, $00 ; point 2
	seq_point $04, 24, $1B, $08, 5, $28, $28 ; point 3
	seq_point $0C, 384, $1E, $08, 2, $00, $00 ; point 4

Level01ObjectSequence04:
	db 2 ; record count: layout only; no reader
	seq_point $04, 112, $0D, $16, 0, $00, $00 ; point 0
	seq_point $0C, 72, $1B, $16, 2, $00, $00 ; point 1

Level01ObjectSequence05:
	db 3 ; record count: layout only; no reader
	seq_point $04, 224, $33, $20, 0, $00, $00 ; point 0
	seq_point $08, 48, $4F, $20, 5, $37, $37 ; point 1
	seq_point $00, 58, $4F, $26, 2, $00, $00 ; point 2

Level01ObjectSequence06:
	db 5 ; record count: layout only; no reader
	seq_point $0C, 56, $44, $04, 0, $00, $00 ; point 0
	seq_point $08, 112, $3D, $04, 0, $00, $00 ; point 1
	seq_point $04, 24, $3D, $12, 0, $00, $00 ; point 2
	seq_point $04, 32, $40, $12, 5, $36, $36 ; point 3
	seq_point $0C, 0, $44, $12, 2, $00, $00 ; point 4

Level01ObjectSequence07:
	db 4 ; record count: layout only; no reader
	seq_point $04, 40, $25, $3F, 0, $00, $00 ; point 0
	seq_point $04, 24, $2A, $3F, 5, $20, $20 ; point 1
	seq_point $04, 144, $2D, $3F, 5, $28, $28 ; point 2
	seq_point $0C, 96, $3F, $3F, 2, $00, $00 ; point 3

Level01ObjectSequence08:
	db 3 ; record count: layout only; no reader
	seq_point $04, 96, $32, $52, 0, $00, $00 ; point 0
	seq_point $00, 48, $3E, $52, 5, $14, $14 ; point 1
	seq_point $08, 0, $3E, $4C, 2, $00, $00 ; point 2

Level01ObjectSequence09:
	db 3 ; record count: layout only; no reader
	seq_point $04, 104, $42, $52, 0, $00, $00 ; point 0
	seq_point $00, 48, $4F, $52, 0, $14, $14 ; point 1
	seq_point $08, 0, $4F, $4C, 2, $00, $00 ; point 2

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
	db 4 ; record count: layout only; no reader
	seq_point $00, 48, $38, $5E, 0, $00, $00 ; point 0
	seq_point $00, 24, $38, $58, 5, $2D, $2D ; point 1
	seq_point $04, 56, $38, $55, 5, $20, $20 ; point 2
	seq_point $0C, 0, $3F, $55, 2, $00, $00 ; point 3

Level02ObjectSequence01:
	db 4 ; record count: layout only; no reader
	seq_point $00, 40, $38, $3B, 0, $00, $00 ; point 0
	seq_point $00, 24, $38, $36, 5, $2C, $2C ; point 1
	seq_point $00, 32, $38, $33, 5, $2C, $2C ; point 2
	seq_point $08, 24, $38, $2F, 2, $17, $17 ; point 3

Level02ObjectSequence02:
	db 3 ; record count: layout only; no reader
	seq_point $08, 80, $30, $28, 0, $00, $00 ; point 0
	seq_point $08, 56, $30, $32, 5, $20, $20 ; point 1
	seq_point $00, 144, $30, $39, 2, $00, $00 ; point 2

Level02ObjectSequence03:
	db 5 ; record count: layout only; no reader
	seq_point $0C, 56, $23, $43, 0, $13, $13 ; point 0
	seq_point $00, 104, $1C, $43, 5, $13, $13 ; point 1
	seq_point $04, 72, $1C, $36, 0, $17, $17 ; point 2
	seq_point $04, 24, $25, $36, 5, $17, $17 ; point 3
	seq_point $0C, 0, $28, $36, 2, $00, $00 ; point 4

Level02ObjectSequence04:
	db 3 ; record count: layout only; no reader
	seq_point $00, 80, $14, $62, 0, $00, $00 ; point 0
	seq_point $00, 88, $14, $58, 5, $20, $20 ; point 1
	seq_point $08, 144, $14, $4D, 2, $00, $00 ; point 2

Level02ObjectSequence05:
	db 3 ; record count: layout only; no reader
	seq_point $08, 96, $0C, $27, 0, $00, $00 ; point 0
	seq_point $08, 88, $0C, $33, 5, $20, $20 ; point 1
	seq_point $00, 144, $0C, $3E, 2, $00, $00 ; point 2

Level02ObjectSequence06:
	db 3 ; record count: layout only; no reader
	seq_point $00, 152, $0C, $1B, 0, $00, $00 ; point 0
	seq_point $04, 32, $0C, $08, 0, $14, $14 ; point 1
	seq_point $0C, 144, $10, $08, 2, $00, $00 ; point 2

Level02ObjectSequence07:
	db 2 ; record count: layout only; no reader
	seq_point $04, 80, $1D, $05, 0, $00, $00 ; point 0
	seq_point $0C, 64, $27, $05, 2, $14, $14 ; point 1

Level02ObjectSequence08:
	db 4 ; record count: layout only; no reader
	seq_point $04, 72, $2F, $08, 0, $00, $00 ; point 0
	seq_point $04, 56, $38, $08, 5, $18, $18 ; point 1
	seq_point $00, 40, $3F, $08, 5, $1C, $1C ; point 2
	seq_point $08, 24, $3F, $03, 2, $17, $17 ; point 3

Level02ObjectSequence09:
	db 6 ; record count: layout only; no reader
	seq_point $04, 80, $18, $1B, 0, $00, $00 ; point 0
	seq_point $08, 24, $22, $1B, 0, $18, $18 ; point 1
	seq_point $04, 32, $22, $1E, 5, $38, $38 ; point 2
	seq_point $00, 24, $26, $1E, 0, $17, $17 ; point 3
	seq_point $04, 104, $26, $1B, 0, $00, $00 ; point 4
	seq_point $0C, 0, $33, $1B, 2, $00, $00 ; point 5

Level02ObjectSequence10:
	db 3 ; record count: layout only; no reader
	seq_point $08, 32, $39, $14, 0, $00, $00 ; point 0
	seq_point $04, 56, $39, $18, 5, $10, $10 ; point 1
	seq_point $0C, 64, $40, $18, 2, $38, $38 ; point 2

Level02ObjectSequence11:
	db 2 ; record count: layout only; no reader
	seq_point $00, 80, $30, $5C, 0, $00, $00 ; point 0
	seq_point $08, 0, $30, $52, 2, $00, $00 ; point 1

Level02ObjectSequence12:
	db 2 ; record count: layout only; no reader
	seq_point $08, 56, $38, $44, 0, $00, $00 ; point 0
	seq_point $00, 96, $38, $4B, 2, $2C, $2C ; point 1

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
	db 5 ; record count: layout only; no reader
	seq_point $0C, 72, $99, $0E, 0, $00, $00 ; point 0
	seq_point $0C, 80, $90, $0E, 5, $2C, $2C ; point 1
	seq_point $0C, 56, $86, $0E, 5, $2C, $2C ; point 2
	seq_point $0C, 32, $7F, $0E, 5, $2C, $2C ; point 3
	seq_point $04, 0, $7B, $0E, 2, $00, $00 ; point 4

Level03ObjectSequence01:
	db 4 ; record count: layout only; no reader
	seq_point $0C, 56, $73, $12, 0, $00, $00 ; point 0
	seq_point $00, 32, $6C, $12, 0, $2C, $2C ; point 1
	seq_point $04, 56, $6C, $0E, 0, $2C, $2C ; point 2
	seq_point $0C, 16, $73, $0E, 2, $2C, $2C ; point 3

Level03ObjectSequence02:
	db 4 ; record count: layout only; no reader
	seq_point $04, 160, $72, $21, 0, $00, $00 ; point 0
	seq_point $08, 72, $86, $21, 0, $2C, $2C ; point 1
	seq_point $0B, 9, $86, $2A, 5, $3B, $3B ; point 2
	seq_point $03, 16, $85, $2A, 2, $2C, $2C ; point 3

Level03ObjectSequence03:
	db 3 ; record count: layout only; no reader
	seq_point $0C, 64, $76, $2A, 0, $00, $00 ; point 0
	seq_point $0C, 56, $6E, $2A, 0, $2C, $2C ; point 1
	seq_point $04, 9, $67, $2A, 2, $3B, $3B ; point 2

Level03ObjectSequence04:
	db 4 ; record count: layout only; no reader
	seq_point $08, 64, $5C, $1F, 0, $00, $00 ; point 0
	seq_point $08, 24, $5C, $27, 0, $2C, $2C ; point 1
	seq_point $04, 56, $5C, $2A, 0, $3B, $3B ; point 2
	seq_point $0C, 16, $63, $2A, 2, $2C, $2C ; point 3

Level03ObjectSequence05:
	db 5 ; record count: layout only; no reader
	seq_point $00, 48, $4B, $29, 0, $00, $00 ; point 0
	seq_point $00, 56, $4B, $23, 5, $10, $10 ; point 1
	seq_point $00, 48, $4B, $1C, 5, $18, $18 ; point 2
	seq_point $00, 24, $4B, $16, 5, $18, $18 ; point 3
	seq_point $08, 0, $4B, $13, 2, $00, $00 ; point 4

Level03ObjectSequence06:
	db 3 ; record count: layout only; no reader
	seq_point $00, 40, $49, $0A, 0, $00, $00 ; point 0
	seq_point $0C, 104, $49, $05, 5, $10, $10 ; point 1
	seq_point $00, 48, $3C, $05, 5, $18, $18 ; point 2

; Sequence 06 advances here after point 2. These bytes are interpreted as the
; pseudo-record 04 0C 30 00 3A 22 00 00, targeting tile (0, $3A).
Level03ObjectSequence06Overread:
Level03ObjectSequence07:
	db 4 ; record count: layout only; no reader
	seq_point $0C, 48, $3A, $22, 0, $00, $00 ; point 0
	seq_point $08, 64, $34, $22, 5, $10, $10 ; point 1
	seq_point $04, 48, $34, $2A, 5, $18, $18 ; point 2
	seq_point $0C, 24, $3A, $2A, 2, $18, $18 ; point 3

Level03ObjectSequence08:
	db 4 ; record count: layout only; no reader
	seq_point $04, 72, $20, $2A, 0, $00, $00 ; point 0
	seq_point $00, 80, $29, $2A, 5, $10, $10 ; point 1
	seq_point $00, 48, $29, $20, 5, $10, $10 ; point 2
	seq_point $08, 24, $29, $1A, 2, $18, $18 ; point 3

Level03ObjectSequence09:
	db 4 ; record count: layout only; no reader
	seq_point $04, 80, $1F, $06, 0, $00, $00 ; point 0
	seq_point $08, 96, $29, $06, 5, $2C, $2C ; point 1
	seq_point $0C, 24, $29, $12, 5, $18, $18 ; point 2
	seq_point $04, 24, $26, $12, 2, $18, $18 ; point 3

Level03ObjectSequence10:
	db 4 ; record count: layout only; no reader
	seq_point $00, 48, $18, $0B, 0, $00, $00 ; point 0
	seq_point $0C, 144, $18, $05, 5, $1C, $1C ; point 1
	seq_point $08, 96, $06, $05, 5, $18, $18 ; point 2
	seq_point $00, 24, $06, $11, 2, $18, $18 ; point 3

Level03ObjectSequence11:
	db 4 ; record count: layout only; no reader
	seq_point $05, 16, $0F, $29, 0, $00, $00 ; point 0
	seq_point $04, 64, $11, $29, 5, $1C, $1C ; point 1
	seq_point $00, 80, $19, $29, 0, $18, $18 ; point 2
	seq_point $08, 24, $19, $1F, 2, $18, $18 ; point 3

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
	db 3 ; record count: layout only; no reader
	seq_point $08, 48, $26, $12, 0, $00, $00 ; point 0
	seq_point $0C, 80, $26, $18, 0, $00, $00 ; point 1
	seq_point $04, 0, $1C, $18, 2, $00, $00 ; point 2

Level04ObjectSequence02:
	db 2 ; record count: layout only; no reader
	seq_point $08, 88, $10, $1B, 0, $00, $00 ; point 0
	seq_point $00, 109, $10, $26, 2, $00, $00 ; point 1

Level04ObjectSequence03:
	db 2 ; record count: layout only; no reader
	seq_point $08, 96, $1A, $21, 0, $00, $00 ; point 0
	seq_point $00, 109, $1A, $2D, 2, $00, $00 ; point 1

Level04ObjectSequence04:
	db 2 ; record count: layout only; no reader
	seq_point $04, 72, $16, $37, 0, $00, $00 ; point 0
	seq_point $0C, 311, $1F, $37, 2, $00, $00 ; point 1

Level04ObjectSequence05:
	db 3 ; record count: layout only; no reader
	seq_point $0C, 64, $0E, $34, 0, $00, $00 ; point 0
	seq_point $08, 120, $06, $34, 0, $20, $20 ; point 1
	seq_point $00, 0, $06, $43, 2, $00, $00 ; point 2

Level04ObjectSequence06:
	db 3 ; record count: layout only; no reader
	seq_point $08, 64, $06, $4A, 0, $00, $00 ; point 0
	seq_point $04, 80, $06, $52, 5, $20, $20 ; point 1
	seq_point $0C, 0, $10, $52, 2, $00, $00 ; point 2

Level04ObjectSequence07:
	db 3 ; record count: layout only; no reader
	seq_point $0C, 64, $22, $51, 0, $00, $00 ; point 0
	seq_point $00, 80, $1A, $51, 5, $2C, $2C ; point 1
	seq_point $08, 0, $1A, $47, 2, $00, $00 ; point 2

Level04ObjectSequence08:
	db 2 ; record count: layout only; no reader
	seq_point $04, 152, $29, $46, 0, $00, $00 ; point 0
	seq_point $0C, 286, $3C, $46, 2, $00, $00 ; point 1

Level04ObjectSequence09:
	db 3 ; record count: layout only; no reader
	seq_point $04, 64, $2E, $52, 0, $00, $00 ; point 0
	seq_point $04, 80, $36, $52, 5, $20, $20 ; point 1
	seq_point $0C, 311, $40, $52, 2, $00, $00 ; point 2

Level04ObjectSequence10:
	db 3 ; record count: layout only; no reader
	seq_point $04, 48, $4B, $52, 0, $00, $00 ; point 0
	seq_point $00, 80, $51, $52, 5, $2C, $2C ; point 1
	seq_point $08, 0, $51, $48, 2, $00, $00 ; point 2

Level04ObjectSequence11:
	db 3 ; record count: layout only; no reader
	seq_point $00, 128, $50, $3A, 0, $00, $00 ; point 0
	seq_point $00, 56, $50, $2A, 5, $18, $18 ; point 1
	seq_point $08, 0, $50, $23, 2, $00, $00 ; point 2

Level04ObjectSequence12:
	db 4 ; record count: layout only; no reader
	seq_point $08, 8, $3D, $05, 0, $00, $00 ; point 0
	seq_point $04, 88, $3D, $06, 0, $00, $00 ; point 1
	seq_point $08, 72, $48, $06, 0, $00, $00 ; point 2
	seq_point $00, 0, $48, $0F, 2, $00, $00 ; point 3

Level04ObjectSequence13:
	db 3 ; record count: layout only; no reader
	seq_point $0C, 72, $3F, $12, 0, $00, $00 ; point 0
	seq_point $0C, 48, $36, $12, 0, $00, $00 ; point 1
	seq_point $04, 311, $30, $12, 2, $00, $00 ; point 2

Level04ObjectSequence14:
	db 2 ; record count: layout only; no reader
	seq_point $08, 72, $36, $1F, 0, $00, $00 ; point 0
	seq_point $00, 256, $36, $28, 2, $00, $00 ; point 1

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
	db 4 ; record count: layout only; no reader
	seq_point $04, 40, $0A, $63, 0, $00, $00 ; point 0
	seq_point $00, 48, $0F, $63, 0, $00, $00 ; point 1
	seq_point $04, 56, $0F, $5D, 5, $24, $24 ; point 2
	seq_point $0C, 64, $16, $5D, 2, $00, $00 ; point 3

Level05ObjectSequence01:
	db 3 ; record count: layout only; no reader
	seq_point $04, 72, $10, $54, 0, $00, $00 ; point 0
	seq_point $00, 56, $19, $54, 5, $38, $38 ; point 1
	seq_point $08, 0, $19, $4D, 2, $00, $00 ; point 2

Level05ObjectSequence02:
	db 4 ; record count: layout only; no reader
	seq_point $0C, 40, $0A, $4E, 0, $00, $00 ; point 0
	seq_point $08, 104, $05, $4E, 0, $00, $00 ; point 1
	seq_point $08, 32, $05, $5B, 5, $0A, $0A ; point 2
	seq_point $00, 0, $05, $5F, 2, $00, $00 ; point 3

Level05ObjectSequence03:
	db 3 ; record count: layout only; no reader
	seq_point $00, 104, $25, $59, 0, $00, $00 ; point 0
	seq_point $04, 152, $25, $4C, 5, $28, $28 ; point 1
	seq_point $0C, 544, $38, $4C, 2, $00, $00 ; point 2

Level05ObjectSequence04:
	db 2 ; record count: layout only; no reader
	seq_point $08, 88, $3E, $33, 0, $00, $00 ; point 0
	seq_point $00, 494, $3E, $3E, 2, $00, $00 ; point 1

Level05ObjectSequence05:
	db 3 ; record count: layout only; no reader
	seq_point $00, 72, $30, $3B, 0, $00, $00 ; point 0
	seq_point $00, 32, $30, $32, 0, $00, $00 ; point 1
	seq_point $08, 544, $30, $2E, 2, $00, $00 ; point 2

Level05ObjectSequence06:
	db 2 ; record count: layout only; no reader
	seq_point $00, 224, $25, $3A, 0, $00, $00 ; point 0
	seq_point $08, 245, $25, $1E, 2, $00, $00 ; point 1

Level05ObjectSequence07:
	db 5 ; record count: layout only; no reader
	seq_point $0C, 32, $1E, $28, 0, $00, $00 ; point 0
	seq_point $08, 8, $1A, $28, 0, $00, $00 ; point 1
	seq_point $0C, 32, $1A, $29, 0, $00, $00 ; point 2
	seq_point $0C, 56, $16, $29, 0, $00, $00 ; point 3
	seq_point $04, 0, $0F, $29, 2, $00, $00 ; point 4

Level05ObjectSequence08:
	db 4 ; record count: layout only; no reader
	seq_point $04, 64, $04, $36, 0, $00, $00 ; point 0
	seq_point $08, 72, $0C, $36, 0, $00, $00 ; point 1
	seq_point $04, 56, $0C, $3F, 0, $00, $00 ; point 2
	seq_point $0C, 162, $13, $3F, 2, $00, $00 ; point 3

Level05ObjectSequence09:
	db 3 ; record count: layout only; no reader
	seq_point $08, 80, $1A, $35, 0, $00, $00 ; point 0
	seq_point $04, 56, $1A, $3F, 0, $2C, $2C ; point 1
	seq_point $0C, 272, $21, $3F, 2, $00, $00 ; point 2

Level05ObjectSequence10:
	db 4 ; record count: layout only; no reader
	seq_point $0C, 128, $1C, $1B, 0, $00, $00 ; point 0
	seq_point $00, 72, $0C, $1B, 5, $24, $24 ; point 1
	seq_point $00, 64, $0C, $12, 5, $28, $28 ; point 2
	seq_point $08, 64, $0C, $0A, 2, $00, $00 ; point 3

Level05ObjectSequence11:
	db 4 ; record count: layout only; no reader
	seq_point $00, 40, $32, $20, 0, $00, $00 ; point 0
	seq_point $04, 96, $32, $1B, 5, $28, $28 ; point 1
	seq_point $08, 40, $3E, $1B, 5, $10, $10 ; point 2
	seq_point $00, 64, $3E, $20, 2, $00, $00 ; point 3

Level05ObjectSequence12:
	db 4 ; record count: layout only; no reader
	seq_point $00, 72, $3E, $14, 0, $00, $00 ; point 0
	seq_point $00, 48, $3E, $0B, 5, $18, $18 ; point 1
	seq_point $0C, 64, $3E, $05, 5, $28, $28 ; point 2
	seq_point $04, 64, $36, $05, 2, $00, $00 ; point 3

Level05ObjectSequence13:
	db 3 ; record count: layout only; no reader
	seq_point $00, 64, $37, $15, 0, $00, $00 ; point 0
	seq_point $0C, 104, $37, $0D, 0, $00, $00 ; point 1
	seq_point $04, 64, $2A, $0D, 2, $00, $00 ; point 2

Level05ObjectSequence14:
	db 3 ; record count: layout only; no reader
	seq_point $04, 96, $12, $0B, 0, $00, $00 ; point 0
	seq_point $08, 72, $1E, $0B, 0, $00, $00 ; point 1
	seq_point $00, 64, $1E, $14, 2, $00, $00 ; point 2

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
	db 3 ; record count: layout only; no reader
	seq_point $08, 32, $50, $3E, 0, $00, $00 ; point 0
	seq_point $0C, 48, $50, $42, 0, $05, $05 ; point 1
	seq_point $04, 0, $4A, $42, 2, $00, $00 ; point 2

Level06ObjectSequence01:
	db 3 ; record count: layout only; no reader
	seq_point $0C, 24, $31, $43, 0, $00, $00 ; point 0
	seq_point $00, 72, $2E, $43, 0, $05, $05 ; point 1
	seq_point $08, 0, $2E, $3A, 2, $00, $00 ; point 2

Level06ObjectSequence02:
	db 2 ; record count: layout only; no reader
	seq_point $00, 72, $1A, $48, 0, $00, $00 ; point 0
	seq_point $08, 322, $1A, $3F, 2, $05, $05 ; point 1

Level06ObjectSequence03:
	db 3 ; record count: layout only; no reader
	seq_point $00, 56, $08, $49, 0, $00, $00 ; point 0
	seq_point $00, 48, $08, $42, 0, $05, $05 ; point 1
	seq_point $08, 0, $08, $3C, 2, $00, $00 ; point 2

Level06ObjectSequence04:
	db 3 ; record count: layout only; no reader
	seq_point $08, 32, $08, $2C, 0, $00, $00 ; point 0
	seq_point $04, 72, $08, $30, 0, $05, $05 ; point 1
	seq_point $0C, 88, $11, $30, 2, $00, $00 ; point 2

Level06ObjectSequence05:
	db 3 ; record count: layout only; no reader
	seq_point $08, 24, $2C, $17, 0, $00, $00 ; point 0
	seq_point $0C, 72, $2C, $1A, 0, $05, $05 ; point 1
	seq_point $04, 107, $23, $1A, 2, $00, $00 ; point 2

Level06ObjectSequence06:
	db 4 ; record count: layout only; no reader
	seq_point $0C, 64, $2F, $25, 0, $00, $00 ; point 0
	seq_point $0C, 48, $27, $25, 0, $05, $05 ; point 1
	seq_point $0C, 24, $21, $25, 0, $00, $00 ; point 2
	seq_point $04, 0, $1E, $25, 2, $00, $00 ; point 3

Level06ObjectSequence07:
	db 3 ; record count: layout only; no reader
	seq_point $04, 80, $10, $06, 0, $00, $00 ; point 0
	seq_point $08, 24, $1A, $06, 0, $05, $05 ; point 1
	seq_point $00, 72, $1A, $09, 2, $00, $00 ; point 2

Level06ObjectSequence08:
	db 3 ; record count: layout only; no reader
	seq_point $08, 80, $26, $06, 0, $00, $00 ; point 0
	seq_point $0C, 40, $26, $10, 0, $05, $05 ; point 1
	seq_point $04, 43, $21, $10, 2, $00, $00 ; point 2

Level06ObjectSequence09:
	db 4 ; record count: layout only; no reader
	seq_point $0C, 40, $4A, $26, 0, $00, $00 ; point 0
	seq_point $00, 32, $45, $26, 0, $05, $05 ; point 1
	seq_point $00, 24, $45, $22, 0, $00, $00 ; point 2
	seq_point $08, 68, $45, $1F, 2, $00, $00 ; point 3

Level06ObjectSequence10:
	db 2 ; record count: layout only; no reader
	seq_point $08, 48, $3F, $34, 0, $00, $00 ; point 0
	seq_point $00, 112, $3F, $3A, 2, $05, $05 ; point 1

Level06ObjectSequence11:
	db 3 ; record count: layout only; no reader
	seq_point $04, 128, $1C, $31, 0, $00, $00 ; point 0
	seq_point $00, 32, $2C, $31, 2, $05, $05 ; point 1
	seq_point $08, 88, $2C, $2D, 2, $00, $00 ; point 2

Level06ObjectSequence12:
	db 3 ; record count: layout only; no reader
	seq_point $0C, 56, $16, $1F, 0, $00, $00 ; point 0
	seq_point $0C, 64, $0F, $1F, 2, $05, $05 ; point 1
	seq_point $04, 72, $07, $1F, 2, $00, $00 ; point 2

Level06ObjectSequence13:
	db 2 ; record count: layout only; no reader
	seq_point $04, 56, $05, $12, 0, $00, $00 ; point 0
	seq_point $0C, 96, $0C, $12, 2, $05, $05 ; point 1

Level06ObjectSequence14:
	db 3 ; record count: layout only; no reader
	seq_point $04, 32, $34, $08, 0, $00, $00 ; point 0
	seq_point $08, 120, $38, $08, 2, $05, $05 ; point 1
	seq_point $00, 113, $38, $17, 2, $00, $00 ; point 2

Level06ObjectSequence15:
	db 2 ; record count: layout only; no reader
	seq_point $04, 80, $4A, $10, 0, $00, $00 ; point 0
	seq_point $0C, 56, $54, $10, 0, $05, $05 ; point 1

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
	db 3 ; record count: layout only; no reader
	seq_point $0C, 88, $3B, $2C, 0, $00, $00 ; point 0
	seq_point $00, 72, $30, $2C, 0, $00, $00 ; point 1
	seq_point $08, 0, $30, $23, 2, $00, $00 ; point 2

Level07ObjectSequence01:
	db 3 ; record count: layout only; no reader
	seq_point $04, 56, $33, $14, 0, $00, $00 ; point 0
	seq_point $00, 48, $3A, $14, 0, $00, $00 ; point 1
	seq_point $08, 0, $3A, $0E, 2, $00, $00 ; point 2

Level07ObjectSequence02:
	db 4 ; record count: layout only; no reader
	seq_point $08, 56, $1F, $05, 0, $00, $00 ; point 0
	seq_point $04, 56, $1F, $0C, 0, $00, $00 ; point 1
	seq_point $00, 56, $26, $0C, 0, $00, $00 ; point 2
	seq_point $08, 0, $26, $05, 2, $00, $00 ; point 3

Level07ObjectSequence03:
	db 3 ; record count: layout only; no reader
	seq_point $0C, 48, $43, $66, 0, $00, $00 ; point 0
	seq_point $00, 88, $3D, $66, 0, $00, $00 ; point 1
	seq_point $08, 85, $3D, $5B, 2, $00, $00 ; point 2

Level07ObjectSequence04:
	db 3 ; record count: layout only; no reader
	seq_point $0C, 120, $42, $54, 0, $00, $00 ; point 0
	seq_point $08, 32, $33, $54, 0, $00, $00 ; point 1
	seq_point $00, 85, $33, $58, 2, $00, $00 ; point 2

Level07ObjectSequence05:
	db 3 ; record count: layout only; no reader
	seq_point $04, 120, $11, $6B, 0, $00, $00 ; point 0
	seq_point $00, 72, $20, $6B, 0, $00, $00 ; point 1
	seq_point $08, 85, $20, $62, 2, $00, $00 ; point 2

Level07ObjectSequence06:
	db 2 ; record count: layout only; no reader
	seq_point $08, 48, $13, $58, 0, $00, $00 ; point 0
	seq_point $00, 440, $13, $5E, 2, $00, $00 ; point 1

Level07ObjectSequence07:
	db 4 ; record count: layout only; no reader
	seq_point $0C, 56, $0B, $4D, 0, $00, $00 ; point 0
	seq_point $00, 88, $04, $4D, 0, $00, $00 ; point 1
	seq_point $04, 64, $04, $42, 0, $00, $00 ; point 2
	seq_point $0C, 0, $0C, $42, 2, $00, $00 ; point 3

Level07ObjectSequence08:
	db 3 ; record count: layout only; no reader
	seq_point $04, 80, $12, $4A, 0, $00, $00 ; point 0
	seq_point $08, 80, $1C, $4A, 0, $00, $00 ; point 1
	seq_point $00, 456, $1C, $54, 2, $00, $00 ; point 2

Level07ObjectSequence09:
	db 3 ; record count: layout only; no reader
	seq_point $04, 112, $28, $46, 0, $00, $00 ; point 0
	seq_point $00, 32, $36, $46, 0, $00, $00 ; point 1
	seq_point $08, 456, $36, $42, 2, $00, $00 ; point 2

Level07ObjectSequence10:
	db 3 ; record count: layout only; no reader
	seq_point $0C, 120, $45, $37, 0, $00, $00 ; point 0
	seq_point $0C, 96, $36, $37, 0, $00, $00 ; point 1
	seq_point $04, 456, $2A, $37, 2, $00, $00 ; point 2

Level07ObjectSequence11:
	db 3 ; record count: layout only; no reader
	seq_point $04, 72, $09, $39, 0, $00, $00 ; point 0
	seq_point $04, 56, $12, $39, 0, $00, $00 ; point 1
	seq_point $0C, 456, $19, $39, 2, $00, $00 ; point 2

Level07ObjectSequence12:
	db 3 ; record count: layout only; no reader
	seq_point $0C, 48, $12, $2C, 0, $00, $00 ; point 0
	seq_point $00, 64, $0C, $2C, 0, $00, $00 ; point 1
	seq_point $08, 456, $0C, $24, 2, $00, $00 ; point 2

Level07ObjectSequence13:
	db 4 ; record count: layout only; no reader
	seq_point $0C, 88, $13, $1C, 0, $00, $00 ; point 0
	seq_point $00, 96, $08, $1C, 0, $00, $00 ; point 1
	seq_point $04, 32, $08, $10, 0, $00, $00 ; point 2
	seq_point $0C, 0, $0C, $10, 2, $00, $00 ; point 3

Level07ObjectSequence14:
	db 3 ; record count: layout only; no reader
	seq_point $04, 72, $39, $1C, 0, $00, $00 ; point 0
	seq_point $00, 40, $42, $1C, 0, $00, $00 ; point 1
	seq_point $08, 0, $42, $17, 2, $00, $00 ; point 2

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
	db 3 ; record count: layout only; no reader
	seq_point $0C, 88, $1A, $0B, 0, $00, $00 ; point 0
	seq_point $00, 48, $0F, $0B, 0, $00, $00 ; point 1
	seq_point $08, 48, $0F, $05, 2, $00, $00 ; point 2

Level08ObjectSequence01:
	db 2 ; record count: layout only; no reader
	seq_point $04, 120, $05, $27, 0, $00, $00 ; point 0
	seq_point $0C, 48, $14, $27, 2, $00, $00 ; point 1

Level08ObjectSequence02:
	db 3 ; record count: layout only; no reader
	seq_point $08, 56, $1F, $20, 0, $00, $00 ; point 0
	seq_point $04, 160, $1F, $27, 2, $00, $00 ; point 1
	seq_point $0C, 48, $33, $27, 2, $00, $00 ; point 2

Level08ObjectSequence03:
	db 3 ; record count: layout only; no reader
	seq_point $04, 48, $37, $42, 0, $00, $00 ; point 0
	seq_point $04, 64, $3D, $42, 0, $00, $00 ; point 1
	seq_point $0C, 48, $45, $42, 2, $00, $00 ; point 2

Level08ObjectSequence04:
	db 2 ; record count: layout only; no reader
	seq_point $04, 144, $1C, $42, 0, $00, $00 ; point 0
	seq_point $0C, 64, $2E, $42, 2, $00, $00 ; point 1

Level08ObjectSequence05:
	db 3 ; record count: layout only; no reader
	seq_point $08, 104, $5D, $35, 0, $00, $00 ; point 0
	seq_point $04, 88, $5D, $42, 0, $00, $00 ; point 1
	seq_point $0C, 48, $68, $42, 2, $00, $00 ; point 2

Level08ObjectSequence06:
	db 2 ; record count: layout only; no reader
	seq_point $04, 152, $38, $2D, 0, $00, $00 ; point 0
	seq_point $0C, 96, $4B, $2D, 2, $00, $00 ; point 1

Level08ObjectSequence07:
	db 3 ; record count: layout only; no reader
	seq_point $08, 80, $68, $08, 0, $00, $00 ; point 0
	seq_point $04, 32, $68, $12, 0, $00, $00 ; point 1
	seq_point $0C, 48, $6C, $12, 2, $00, $00 ; point 2

Level08ObjectSequence08:
	db 2 ; record count: layout only; no reader
	seq_point $0C, 96, $39, $18, 0, $00, $00 ; point 0
	seq_point $04, 64, $2D, $18, 2, $00, $00 ; point 1

Level08ObjectSequence09:
	db 2 ; record count: layout only; no reader
	seq_point $0C, 112, $58, $27, 0, $00, $00 ; point 0
	seq_point $04, 64, $4A, $27, 2, $00, $00 ; point 1

Level08ObjectSequence10:
	db 2 ; record count: layout only; no reader
	seq_point $08, 136, $58, $08, 0, $00, $00 ; point 0
	seq_point $00, 64, $58, $19, 2, $00, $00 ; point 1

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
	db 2 ; record count: layout only; no reader
	seq_point $04, 96, $2D, $1A, 0, $00, $00 ; point 0
	seq_point $0C, 130, $39, $1A, 2, $00, $00 ; point 1

Level09ObjectSequence02:
	db 3 ; record count: layout only; no reader
	seq_point $0C, 32, $0E, $1A, 0, $00, $00 ; point 0
	seq_point $0C, 40, $0A, $1A, 0, $00, $00 ; point 1
	seq_point $04, 32, $05, $1A, 2, $00, $00 ; point 2

Level09ObjectSequence03:
	db 4 ; record count: layout only; no reader
	seq_point $08, 40, $12, $25, 0, $00, $00 ; point 0
	seq_point $0C, 64, $12, $2A, 0, $00, $00 ; point 1
	seq_point $08, 40, $0A, $2A, 0, $14, $14 ; point 2
	seq_point $00, 0, $0A, $2F, 2, $00, $00 ; point 3

Level09ObjectSequence04:
	db 3 ; record count: layout only; no reader
	seq_point $08, 40, $2E, $25, 0, $00, $00 ; point 0
	seq_point $04, 80, $2E, $2A, 0, $00, $00 ; point 1
	seq_point $0C, 176, $38, $2A, 2, $00, $00 ; point 2

Level09ObjectSequence05:
	db 4 ; record count: layout only; no reader
	seq_point $04, 64, $03, $3A, 0, $00, $00 ; point 0
	seq_point $08, 32, $0B, $3A, 0, $00, $00 ; point 1
	seq_point $04, 40, $0B, $3E, 0, $00, $00 ; point 2
	seq_point $0C, 0, $10, $3E, 2, $00, $00 ; point 3

Level09ObjectSequence06:
	db 4 ; record count: layout only; no reader
	seq_point $04, 40, $21, $3F, 0, $00, $00 ; point 0
	seq_point $04, 40, $26, $3F, 0, $00, $00 ; point 1
	seq_point $04, 32, $2B, $3F, 0, $00, $00 ; point 2
	seq_point $0C, 0, $2F, $3F, 2, $00, $00 ; point 3

Level09ObjectSequence07:
	db 5 ; record count: layout only; no reader
	seq_point $08, 32, $33, $32, 0, $00, $00 ; point 0
	seq_point $04, 24, $33, $36, 0, $00, $00 ; point 1
	seq_point $08, 24, $36, $36, 0, $00, $00 ; point 2
	seq_point $04, 40, $36, $39, 0, $00, $00 ; point 3
	seq_point $0C, 0, $3B, $39, 2, $00, $00 ; point 4

Level09ObjectSequence08:
	db 3 ; record count: layout only; no reader
	seq_point $08, 64, $0B, $49, 0, $00, $00 ; point 0
	seq_point $0C, 48, $0B, $51, 0, $00, $00 ; point 1
	seq_point $04, 237, $05, $51, 2, $00, $00 ; point 2

Level09ObjectSequence09:
	db 3 ; record count: layout only; no reader
	seq_point $04, 88, $15, $51, 0, $00, $00 ; point 0
	seq_point $00, 48, $20, $51, 0, $00, $00 ; point 1
	seq_point $08, 237, $20, $4B, 2, $00, $00 ; point 2

Level09ObjectSequence10:
	db 4 ; record count: layout only; no reader
	seq_point $08, 64, $35, $47, 0, $00, $00 ; point 0
	seq_point $08, 16, $35, $4F, 0, $00, $00 ; point 1
	seq_point $04, 48, $35, $51, 0, $00, $00 ; point 2
	seq_point $0C, 291, $3B, $51, 2, $00, $00 ; point 3

Level09ObjectSequence11:
	db 4 ; record count: layout only; no reader
	seq_point $0C, 48, $3B, $5B, 0, $00, $00 ; point 0
	seq_point $08, 64, $35, $5B, 0, $00, $00 ; point 1
	seq_point $0C, 24, $35, $63, 0, $00, $00 ; point 2
	seq_point $04, 291, $32, $63, 2, $00, $00 ; point 3

Level09ObjectSequence12:
	db 3 ; record count: layout only; no reader
	seq_point $08, 88, $20, $58, 0, $00, $00 ; point 0
	seq_point $04, 48, $20, $63, 0, $00, $00 ; point 1
	seq_point $0C, 573, $26, $63, 2, $00, $00 ; point 2

Level09ObjectSequence13:
	db 3 ; record count: layout only; no reader
	seq_point $08, 72, $0B, $5A, 0, $00, $00 ; point 0
	seq_point $04, 40, $0B, $63, 0, $00, $00 ; point 1
	seq_point $0C, 573, $10, $63, 2, $00, $00 ; point 2

Level09ObjectSequence14:
	db 3 ; record count: layout only; no reader
	seq_point $08, 48, $0B, $6C, 0, $00, $00 ; point 0
	seq_point $0C, 56, $0B, $72, 0, $00, $00 ; point 1
	seq_point $04, 573, $04, $72, 2, $00, $00 ; point 2

Level09ObjectSequence15:
	db 3 ; record count: layout only; no reader
	seq_point $04, 48, $1A, $72, 0, $00, $00 ; point 0
	seq_point $08, 16, $20, $72, 0, $00, $00 ; point 1
	seq_point $00, 573, $20, $74, 2, $00, $00 ; point 2

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
	db 2 ; record count: layout only; no reader
	seq_point $00, 40, $45, $41, 0, $00, $00 ; point 0
	seq_point $08, 0, $45, $3C, 2, $00, $00 ; point 1

Level10ObjectSequence01:
	db 4 ; record count: layout only; no reader
	seq_point $0C, 48, $44, $54, 0, $00, $00 ; point 0
	seq_point $00, 56, $3E, $54, 5, $1D, $1D ; point 1
	seq_point $00, 24, $3E, $4D, 5, $13, $13 ; point 2
	seq_point $08, 0, $3E, $4A, 2, $00, $00 ; point 3

Level10ObjectSequence02:
	db 4 ; record count: layout only; no reader
	seq_point $00, 24, $34, $52, 0, $00, $00 ; point 0
	seq_point $0C, 112, $34, $4F, 5, $1C, $1C ; point 1
	seq_point $08, 24, $26, $4F, 5, $24, $24 ; point 2
	seq_point $00, 0, $26, $52, 2, $00, $00 ; point 3

Level10ObjectSequence03:
	db 3 ; record count: layout only; no reader
	seq_point $00, 56, $17, $54, 0, $00, $00 ; point 0
	seq_point $0C, 56, $17, $4D, 5, $24, $24 ; point 1
	seq_point $04, 415, $10, $4D, 2, $00, $00 ; point 2

Level10ObjectSequence04:
	db 3 ; record count: layout only; no reader
	seq_point $00, 104, $06, $51, 0, $00, $00 ; point 0
	seq_point $04, 64, $06, $44, 5, $28, $28 ; point 1
	seq_point $0C, 415, $0E, $44, 2, $00, $00 ; point 2

Level10ObjectSequence05:
	db 3 ; record count: layout only; no reader
	seq_point $08, 88, $12, $2D, 0, $00, $00 ; point 0
	seq_point $04, 48, $12, $38, 5, $14, $14 ; point 1
	seq_point $0C, 415, $18, $38, 2, $00, $00 ; point 2

Level10ObjectSequence06:
	db 4 ; record count: layout only; no reader
	seq_point $00, 32, $1F, $3E, 0, $00, $00 ; point 0
	seq_point $04, 112, $1F, $3A, 5, $28, $28 ; point 1
	seq_point $00, 24, $2D, $3A, 5, $1C, $1C ; point 2
	seq_point $08, 0, $2D, $37, 2, $00, $00 ; point 3

Level10ObjectSequence07:
	db 3 ; record count: layout only; no reader
	seq_point $0C, 32, $22, $2F, 0, $00, $00 ; point 0
	seq_point $0C, 32, $1E, $2F, 0, $00, $00 ; point 1
	seq_point $04, 303, $1A, $2F, 2, $00, $00 ; point 2

Level10ObjectSequence08:
	db 6 ; record count: layout only; no reader
	seq_point $04, 64, $33, $2F, 0, $00, $00 ; point 0
	seq_point $04, 32, $3B, $2F, 0, $00, $00 ; point 1
	seq_point $08, 64, $3F, $2F, 0, $04, $04 ; point 2
	seq_point $0C, 40, $3F, $37, 0, $04, $04 ; point 3
	seq_point $0C, 40, $3A, $37, 0, $00, $00 ; point 4
	seq_point $04, 0, $35, $37, 2, $00, $00 ; point 5

Level10ObjectSequence09:
	db 3 ; record count: layout only; no reader
	seq_point $00, 80, $50, $35, 0, $00, $00 ; point 0
	seq_point $0C, 32, $50, $2B, 0, $00, $00 ; point 1
	seq_point $04, 64, $4C, $2B, 2, $00, $00 ; point 2

Level10ObjectSequence10:
	db 2 ; record count: layout only; no reader
	seq_point $08, 88, $53, $1A, 0, $00, $00 ; point 0
	seq_point $00, 442, $53, $25, 2, $00, $00 ; point 1

Level10ObjectSequence11:
	db 2 ; record count: layout only; no reader
	seq_point $08, 88, $3F, $1A, 0, $00, $00 ; point 0
	seq_point $00, 442, $3F, $25, 2, $00, $00 ; point 1

Level10ObjectSequence12:
	db 2 ; record count: layout only; no reader
	seq_point $04, 72, $45, $10, 0, $00, $00 ; point 0
	seq_point $0C, 442, $4E, $10, 2, $00, $00 ; point 1

Level10ObjectSequence13:
	db 3 ; record count: layout only; no reader
	seq_point $0C, 48, $18, $16, 0, $00, $00 ; point 0
	seq_point $00, 72, $12, $16, 0, $00, $00 ; point 1
	seq_point $08, 64, $12, $0D, 2, $00, $00 ; point 2

Level10ObjectSequence14:
	db 2 ; record count: layout only; no reader
	seq_point $04, 80, $0D, $22, 0, $00, $00 ; point 0
	seq_point $0C, 96, $17, $22, 2, $00, $00 ; point 1

Level10ObjectSequence15:
	db 4 ; record count: layout only; no reader
	seq_point $08, 56, $2E, $0F, 0, $00, $00 ; point 0
	seq_point $04, 80, $2E, $16, 0, $00, $00 ; point 1
	seq_point $08, 32, $38, $16, 0, $00, $00 ; point 2
	seq_point $00, 40, $38, $1A, 2, $00, $00 ; point 3

Level10ObjectSequence16:
	db 2 ; record count: layout only; no reader
	seq_point $08, 72, $26, $0E, 0, $00, $00 ; point 0
	seq_point $00, 51, $26, $17, 2, $00, $00 ; point 1

Level10ObjectSequence17:
	db 3 ; record count: layout only; no reader
	seq_point $08, 16, $31, $21, 0, $00, $00 ; point 0
	seq_point $0C, 40, $31, $23, 0, $00, $00 ; point 1
	seq_point $04, 58, $2C, $23, 2, $00, $00 ; point 2

Level10ObjectSequence19:
	db 2 ; record count: layout only; no reader
	seq_point $00, 88, $06, $3A, 0, $00, $00 ; point 0
	seq_point $08, 198, $06, $2F, 2, $00, $00 ; point 1

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
	db 4 ; record count: layout only; no reader
	seq_point $04, 56, $16, $3C, 0, $00, $00 ; point 0
	seq_point $00, 24, $1D, $3C, 0, $00, $00 ; point 1
	seq_point $04, 64, $1D, $39, 0, $00, $00 ; point 2
	seq_point $0C, 0, $25, $39, 2, $00, $00 ; point 3

Level11ObjectSequence01:
	db 3 ; record count: layout only; no reader
	seq_point $04, 80, $2C, $39, 0, $00, $00 ; point 0
	seq_point $00, 152, $36, $39, 0, $00, $00 ; point 1
	seq_point $08, 168, $36, $26, 2, $00, $00 ; point 2

Level11ObjectSequence03:
	db 2 ; record count: layout only; no reader
	seq_point $08, 72, $09, $03, 0, $00, $00 ; point 0
	seq_point $00, 180, $09, $0C, 2, $00, $00 ; point 1

Level11ObjectSequence04:
	db 3 ; record count: layout only; no reader
	seq_point $04, 32, $05, $31, 0, $00, $00 ; point 0
	seq_point $00, 128, $09, $31, 0, $00, $00 ; point 1
	seq_point $08, 168, $09, $21, 2, $00, $00 ; point 2

Level11ObjectSequence05:
	db 3 ; record count: layout only; no reader
	seq_point $08, 72, $21, $07, 0, $00, $00 ; point 0
	seq_point $0C, 128, $21, $10, 0, $00, $00 ; point 1
	seq_point $04, 168, $11, $10, 2, $00, $00 ; point 2

Level11ObjectSequence06:
	db 3 ; record count: layout only; no reader
	seq_point $04, 32, $2A, $06, 0, $00, $00 ; point 0
	seq_point $08, 64, $2E, $06, 0, $00, $00 ; point 1
	seq_point $00, 168, $2E, $0E, 2, $00, $00 ; point 2

Level11ObjectSequence07:
	db 3 ; record count: layout only; no reader
	seq_point $00, 80, $26, $21, 0, $00, $00 ; point 0
	seq_point $04, 64, $26, $17, 0, $00, $00 ; point 1
	seq_point $0C, 168, $2E, $17, 2, $00, $00 ; point 2

Level11ObjectSequence09:
	db 3 ; record count: layout only; no reader
	seq_point $00, 128, $35, $19, 0, $00, $00 ; point 0
	seq_point $04, 56, $35, $09, 0, $00, $00 ; point 1
	seq_point $0C, 168, $3C, $09, 2, $00, $00 ; point 2

Level11ObjectSequence10:
	db 2 ; record count: layout only; no reader
	seq_point $08, 64, $45, $12, 0, $00, $00 ; point 0
	seq_point $00, 312, $45, $1A, 2, $00, $00 ; point 1

Level11ObjectSequence11:
	db 2 ; record count: layout only; no reader
	seq_point $08, 88, $45, $2C, 0, $00, $00 ; point 0
	seq_point $00, 312, $45, $37, 2, $00, $00 ; point 1

Level11ObjectSequence12:
	db 2 ; record count: layout only; no reader
	seq_point $0C, 56, $73, $05, 0, $00, $00 ; point 0
	seq_point $04, 312, $6C, $05, 2, $00, $00 ; point 1

Level11ObjectSequence13:
	db 3 ; record count: layout only; no reader
	seq_point $08, 56, $6A, $26, 0, $00, $00 ; point 0
	seq_point $04, 80, $6A, $2D, 0, $00, $00 ; point 1
	seq_point $0C, 168, $74, $2D, 2, $00, $00 ; point 2

Level11ObjectSequence14:
	db 3 ; record count: layout only; no reader
	seq_point $0C, 72, $72, $1A, 0, $00, $00 ; point 0
	seq_point $08, 72, $69, $1A, 0, $00, $00 ; point 1
	seq_point $00, 168, $69, $23, 2, $00, $00 ; point 2

Level11ObjectSequence15:
	db 3 ; record count: layout only; no reader
	seq_point $0C, 152, $73, $0F, 0, $00, $00 ; point 0
	seq_point $08, 56, $60, $0F, 0, $00, $00 ; point 1
	seq_point $00, 168, $60, $16, 2, $00, $00 ; point 2

Level11ObjectSequence16:
	db 3 ; record count: layout only; no reader
	seq_point $08, 128, $5F, $20, 0, $00, $00 ; point 0
	seq_point $0C, 48, $5F, $30, 0, $00, $00 ; point 1
	seq_point $04, 168, $59, $30, 2, $00, $00 ; point 2

Level11ObjectSequence17:
	db 3 ; record count: layout only; no reader
	seq_point $08, 48, $58, $05, 0, $00, $00 ; point 0
	seq_point $0C, 40, $58, $0B, 0, $00, $00 ; point 1
	seq_point $04, 168, $53, $0B, 2, $00, $00 ; point 2

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
	db 4 ; record count: layout only; no reader
	seq_point $0C, 80, $36, $05, 0, $00, $00 ; point 0
	seq_point $08, 16, $2C, $05, 0, $00, $00 ; point 1
	seq_point $08, 32, $2C, $07, 0, $00, $00 ; point 2
	seq_point $00, 0, $2C, $0B, 2, $00, $00 ; point 3

Level12ObjectSequence01:
	db 4 ; record count: layout only; no reader
	seq_point $0C, 80, $4C, $05, 0, $00, $00 ; point 0
	seq_point $08, 128, $42, $05, 0, $00, $00 ; point 1
	seq_point $04, 48, $42, $15, 0, $00, $00 ; point 2
	seq_point $0C, 0, $48, $15, 2, $00, $00 ; point 3

Level12ObjectSequence02:
	db 2 ; record count: layout only; no reader
	seq_point $00, 128, $55, $16, 0, $00, $00 ; point 0
	seq_point $08, 439, $55, $06, 2, $00, $00 ; point 1

Level12ObjectSequence03:
	db 3 ; record count: layout only; no reader
	seq_point $08, 104, $55, $2D, 0, $00, $00 ; point 0
	seq_point $0C, 56, $55, $3A, 0, $00, $00 ; point 1
	seq_point $04, 480, $4E, $3A, 2, $00, $00 ; point 2

Level12ObjectSequence04:
	db 2 ; record count: layout only; no reader
	seq_point $04, 104, $56, $1F, 0, $00, $00 ; point 0
	seq_point $0C, 439, $63, $1F, 2, $00, $00 ; point 1

Level12ObjectSequence05:
	db 3 ; record count: layout only; no reader
	seq_point $00, 72, $6B, $18, 0, $00, $00 ; point 0
	seq_point $00, 40, $6B, $0F, 0, $00, $00 ; point 1
	seq_point $08, 480, $6B, $0A, 2, $00, $00 ; point 2

Level12ObjectSequence06:
	db 2 ; record count: layout only; no reader
	seq_point $00, 96, $6B, $34, 0, $00, $00 ; point 0
	seq_point $08, 576, $6B, $28, 2, $00, $00 ; point 1

Level12ObjectSequence07:
	db 2 ; record count: layout only; no reader
	seq_point $0C, 72, $1B, $3A, 0, $00, $00 ; point 0
	seq_point $04, 80, $12, $3A, 2, $00, $00 ; point 1

Level12ObjectSequence08:
	db 3 ; record count: layout only; no reader
	seq_point $04, 64, $42, $2B, 0, $00, $00 ; point 0
	seq_point $00, 64, $4A, $2B, 0, $00, $00 ; point 1
	seq_point $08, 480, $4A, $23, 2, $00, $00 ; point 2

Level12ObjectSequence09:
	db 3 ; record count: layout only; no reader
	seq_point $08, 48, $2C, $34, 0, $00, $00 ; point 0
	seq_point $04, 112, $2C, $3A, 0, $00, $00 ; point 1
	seq_point $0C, 0, $3A, $3A, 2, $00, $00 ; point 2

Level12ObjectSequence10:
	db 2 ; record count: layout only; no reader
	seq_point $08, 128, $18, $18, 0, $00, $00 ; point 0
	seq_point $00, 72, $18, $28, 2, $00, $00 ; point 1

Level12ObjectSequence11:
	db 2 ; record count: layout only; no reader
	seq_point $00, 104, $23, $25, 0, $00, $00 ; point 0
	seq_point $08, 64, $23, $18, 2, $00, $00 ; point 1

Level12ObjectSequence12:
	db 3 ; record count: layout only; no reader
	seq_point $0C, 72, $0B, $11, 0, $00, $00 ; point 0
	seq_point $00, 88, $02, $11, 0, $00, $00 ; point 1
	seq_point $08, 480, $02, $06, 2, $00, $00 ; point 2

Level12ObjectSequence13:
	db 3 ; record count: layout only; no reader
	seq_point $0C, 96, $0E, $2E, 0, $00, $00 ; point 0
	seq_point $08, 72, $02, $2E, 0, $00, $00 ; point 1
	seq_point $00, 192, $02, $37, 2, $00, $00 ; point 2

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
	db 3 ; record count: layout only; no reader
	seq_point $08, 56, $2B, $06, 0, $00, $00 ; point 0
	seq_point $04, 72, $2B, $0D, 5, $08, $08 ; point 1
	seq_point $0C, 33, $34, $0D, 2, $00, $00 ; point 2

Level13ObjectSequence01:
	db 3 ; record count: layout only; no reader
	seq_point $04, 48, $3C, $12, 0, $00, $00 ; point 0
	seq_point $04, 48, $42, $12, 5, $2C, $2C ; point 1
	seq_point $0C, 33, $48, $12, 2, $00, $00 ; point 2

Level13ObjectSequence02:
	db 3 ; record count: layout only; no reader
	seq_point $0C, 136, $18, $45, 0, $00, $00 ; point 0
	seq_point $08, 72, $07, $45, 5, $16, $16 ; point 1
	seq_point $00, 0, $07, $4E, 2, $00, $00 ; point 2

Level13ObjectSequence03:
	db 4 ; record count: layout only; no reader
	seq_point $04, 120, $1C, $55, 0, $00, $00 ; point 0
	seq_point $00, 32, $2B, $55, 0, $00, $00 ; point 1
	seq_point $00, 32, $2B, $51, 5, $20, $20 ; point 2
	seq_point $08, 72, $2B, $4D, 2, $00, $00 ; point 3

Level13ObjectSequence04:
	db 2 ; record count: layout only; no reader
	seq_point $04, 56, $49, $06, 0, $00, $00 ; point 0
	seq_point $0C, 104, $50, $06, 2, $00, $00 ; point 1

Level13ObjectSequence05:
	db 4 ; record count: layout only; no reader
	seq_point $04, 24, $41, $45, 0, $3C, $3C ; point 0
	seq_point $00, 80, $44, $45, 0, $00, $00 ; point 1
	seq_point $04, 40, $44, $3B, 5, $16, $16 ; point 2
	seq_point $0C, 72, $49, $3B, 2, $00, $00 ; point 3

Level13ObjectSequence06:
	db 3 ; record count: layout only; no reader
	seq_point $00, 32, $53, $51, 0, $3C, $3C ; point 0
	seq_point $0C, 56, $53, $4D, 0, $1D, $1D ; point 1
	seq_point $04, 48, $4C, $4D, 2, $16, $16 ; point 2

Level13ObjectSequence07:
	db 2 ; record count: layout only; no reader
	seq_point $04, 48, $32, $3E, 0, $3C, $3C ; point 0
	seq_point $0C, 33, $38, $3E, 2, $00, $00 ; point 1

Level13ObjectSequence08:
	db 2 ; record count: layout only; no reader
	seq_point $04, 32, $1B, $2D, 0, $00, $00 ; point 0
	seq_point $0C, 40, $1F, $2D, 2, $00, $00 ; point 1

Level13ObjectSequence09:
	db 3 ; record count: layout only; no reader
	seq_point $04, 56, $04, $23, 0, $00, $00 ; point 0
	seq_point $00, 96, $0B, $23, 0, $00, $00 ; point 1
	seq_point $08, 33, $0B, $17, 2, $00, $00 ; point 2

Level13ObjectSequence10:
	db 3 ; record count: layout only; no reader
	seq_point $08, 48, $0B, $04, 0, $00, $00 ; point 0
	seq_point $08, 32, $0B, $0A, 0, $00, $00 ; point 1
	seq_point $00, 33, $0B, $0E, 2, $00, $00 ; point 2

Level13ObjectSequence11:
	db 2 ; record count: layout only; no reader
	seq_point $04, 32, $3D, $29, 0, $00, $00 ; point 0
	seq_point $0C, 104, $41, $29, 2, $00, $00 ; point 1

Level13ObjectSequence12:
	db 3 ; record count: layout only; no reader
	seq_point $04, 72, $3B, $4F, 0, $00, $00 ; point 0
	seq_point $08, 40, $44, $4F, 0, $00, $00 ; point 1
	seq_point $00, 33, $44, $54, 2, $00, $00 ; point 2

Level13ObjectSequence13:
	db 2 ; record count: layout only; no reader
	seq_point $04, 40, $1C, $34, 0, $00, $00 ; point 0
	seq_point $0C, 40, $21, $34, 2, $00, $00 ; point 1

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
	db 2 ; record count: layout only; no reader
	seq_point $04, 136, $05, $74, 0, $01, $01 ; point 0
	seq_point $0C, 48, $16, $74, 2, $00, $00 ; point 1

Level14ObjectSequence01:
	db 3 ; record count: layout only; no reader
	seq_point $08, 64, $35, $0A, 0, $00, $00 ; point 0
	seq_point $04, 40, $35, $12, 0, $00, $00 ; point 1
	seq_point $0C, 56, $3A, $12, 2, $01, $01 ; point 2

Level14ObjectSequence02:
	db 3 ; record count: layout only; no reader
	seq_point $08, 72, $0E, $08, 0, $00, $00 ; point 0
	seq_point $0C, 48, $0E, $11, 0, $00, $00 ; point 1
	seq_point $04, 32, $08, $11, 2, $00, $00 ; point 2

Level14ObjectSequence03:
	db 3 ; record count: layout only; no reader
	seq_point $00, 32, $1D, $5E, 0, $00, $00 ; point 0
	seq_point $00, 40, $1D, $5A, 0, $01, $01 ; point 1
	seq_point $08, 128, $1D, $55, 2, $00, $00 ; point 2

Level14ObjectSequence04:
	db 2 ; record count: layout only; no reader
	seq_point $04, 136, $17, $14, 0, $00, $00 ; point 0
	seq_point $0C, 48, $28, $14, 2, $00, $00 ; point 1

Level14ObjectSequence05:
	db 3 ; record count: layout only; no reader
	seq_point $04, 72, $14, $4F, 0, $00, $00 ; point 0
	seq_point $00, 72, $1D, $4F, 0, $00, $00 ; point 1
	seq_point $08, 0, $1D, $46, 2, $00, $00 ; point 2

Level14ObjectSequence06:
	db 3 ; record count: layout only; no reader
	seq_point $04, 104, $25, $5D, 0, $00, $00 ; point 0
	seq_point $08, 56, $32, $5D, 0, $00, $00 ; point 1
	seq_point $00, 56, $32, $64, 2, $01, $01 ; point 2

Level14ObjectSequence07:
	db 3 ; record count: layout only; no reader
	seq_point $08, 56, $3B, $56, 0, $00, $00 ; point 0
	seq_point $0C, 56, $3B, $5D, 0, $00, $00 ; point 1
	seq_point $04, 56, $34, $5D, 2, $01, $01 ; point 2

Level14ObjectSequence08:
	db 3 ; record count: layout only; no reader
	seq_point $00, 64, $3A, $3C, 0, $00, $00 ; point 0
	seq_point $00, 56, $3A, $34, 0, $00, $00 ; point 1
	seq_point $08, 56, $3A, $2D, 2, $01, $01 ; point 2

Level14ObjectSequence09:
	db 3 ; record count: layout only; no reader
	seq_point $04, 72, $04, $5C, 0, $00, $00 ; point 0
	seq_point $00, 48, $0D, $5C, 0, $00, $00 ; point 1
	seq_point $08, 48, $0D, $56, 2, $01, $01 ; point 2

Level14ObjectSequence10:
	db 3 ; record count: layout only; no reader
	seq_point $08, 72, $07, $32, 0, $00, $00 ; point 0
	seq_point $04, 56, $07, $3B, 0, $00, $00 ; point 1
	seq_point $0C, 56, $0E, $3B, 2, $01, $01 ; point 2

Level14ObjectSequence11:
	db 2 ; record count: layout only; no reader
	seq_point $0C, 120, $25, $24, 0, $00, $00 ; point 0
	seq_point $04, 460, $16, $24, 2, $00, $00 ; point 1

Level14ObjectSequence12:
	db 3 ; record count: layout only; no reader
	seq_point $04, 88, $26, $3B, 0, $01, $01 ; point 0
	seq_point $08, 48, $31, $3B, 0, $00, $00 ; point 1
	seq_point $00, 144, $31, $41, 2, $01, $01 ; point 2

Level14ObjectSequence13:
	db 3 ; record count: layout only; no reader
	seq_point $0C, 48, $33, $48, 0, $00, $00 ; point 0
	seq_point $08, 56, $2D, $48, 0, $00, $00 ; point 1
	seq_point $00, 144, $2D, $4F, 2, $01, $01 ; point 2

Level14ObjectSequence14:
	db 4 ; record count: layout only; no reader
	seq_point $04, 64, $23, $71, 0, $00, $00 ; point 0
	seq_point $08, 24, $2B, $71, 0, $00, $00 ; point 1
	seq_point $04, 64, $2B, $74, 0, $01, $01 ; point 2
	seq_point $0C, 0, $33, $74, 2, $00, $00 ; point 3

ASSERT @ - Level14ObjectSequence14 == $21
