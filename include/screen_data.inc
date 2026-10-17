; Full-screen picture support for ROM banks $2A-$2E. Evidence and layout:
; BANKS_2A_2E_RESEARCH.md. The three routine macros reproduce, byte for
; byte, routines that occur 13, 10 and 3 times; tools/screen_data.py checks
; that every copy in the ROM still matches its template.

; 14-byte screen descriptor, copied to wScreenDescriptor by the draw routines.
; Only width and height are read back (ROM0 $05C5); the tile count is never
; read but equals the highest tile used + 1 in every picture.
MACRO screen_descriptor ; tiles, tilemap, attrmap, palettes, tile count, width, height, palette count, first palette
	dw \1, \2, \3, \4, \5
	db \6, \7, \8, \9
ENDM

; Load routine (ScreenTable_CallInit target): copies 384 tiles from the
; descriptor's tile pointer to VRAM0 $8800, VRAM0 $9000 and VRAM1 $9000,
; whatever the picture's tile count.
MACRO screen_load_tiles ; descriptor
	ld hl, \1
	ld d, $00
	xor a
	ldh [rVBK], a
	ld e, $00
	ld d, $80
	ld hl, \1
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld a, $88
	call Func_0622
	ld e, $80
	ld d, $00
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	ld hl, \1
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
	ld c, l
	ld b, h
	ld e, $00
	ld d, $80
	ld a, $90
	call Func_0622
	ld a, $01
	ldh [rVBK], a
	ld e, $00
	ld d, $10
	ld hl, \1
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
	ld b, h
	ld c, l
	ld e, $00
	ld d, $80
	ld a, $90
	call Func_0622
	ret
ENDM

; Draw routine with fade-in (ScreenTable_CallUpdate target). Stack argument:
; the BG map offset pushed by ScreenTable_CallUpdate (read at sp+4). Writes
; the maps through ROM0 $05C5, seeds 8 palettes (always $40 bytes, whatever
; the palette count) into ROM0 $3A88's fade buffer, builds 32 fade steps
; (darkening when \2 is 0, brightening otherwise) and shows one per frame.
MACRO screen_draw_fade ; descriptor, wPaletteFadeFromWhite value
	ld hl, \1
	ld de, wScreenDescriptor
	ld bc, $000E
	call Func_05B7
	ld hl, \1
	ld bc, $0002
	add hl, bc
	ld a, [hli]
	ld e, a
	ld d, [hl]
	inc hl
	ld a, [hli]
	ld c, a
	ld b, [hl]
	push bc
	ld hl, sp + 4
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $9800
	add hl, bc
	pop bc
	call Func_05C5
	ld hl, \1
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld e, a
	ld hl, \1
	ld a, $06
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [ROM_BANK_MARKER]
	ld d, a
	ld e, $40
	call Func_3A88
	ld a, \2
	ld [wPaletteFadeFromWhite], a
	call Func_3A2F
	ld e, $00
.fade_step\@:
	xor a
	ld [wVBlankPending], a
.wait_vblank\@:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, .wait_vblank\@
	xor a
	ld [wVBlankPending], a
	call Func_3A52
	call Audio_Update
	inc e
	ld a, e
	cp $20
	jr nz, .fade_step\@
	ret
ENDM

; Draw routine without fade: maps as above, then [+12] palettes from palette
; index [+13] straight to BCPD (ROM0 $052F), then waits for one VBlank.
MACRO screen_draw_plain ; descriptor
	ld hl, \1
	ld de, wScreenDescriptor
	ld bc, $000E
	call Func_05B7
	ld hl, \1
	ld bc, $0002
	add hl, bc
	ld a, [hli]
	ld e, a
	ld d, [hl]
	inc hl
	ld a, [hli]
	ld c, a
	ld b, [hl]
	push bc
	ld hl, sp + 4
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $9800
	add hl, bc
	pop bc
	call Func_05C5
	ld hl, \1
	ld a, $0C
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld hl, \1
	ld a, $06
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call Func_052F
	xor a
	ld [wVBlankPending], a
.wait_vblank\@:
	halt
	nop
	nop
	ld a, [wVBlankPending]
	or a
	jr z, .wait_vblank\@
	xor a
	ld [wVBlankPending], a
	ret
ENDM

; Zero fill up to the bank-number marker at $7FFF.
MACRO screen_bank_end
	ds $7FFF - @, $00
	db BANK(@)
ENDM
