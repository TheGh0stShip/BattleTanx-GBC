; Evidence-based BattleTanx memory symbols.

; Every populated switchable ROM bank stores its bank number in its last byte.
; Banked-call helpers read this marker before changing the MBC5 bank register.
DEF ROM_BANK_MARKER EQU $7FFF

; Set to 1 by the installed VBlank handler and cleared by frame-wait loops.
DEF wVBlankPending EQU $C6C0

; Little-endian callback selected from RuntimeCallbackTable and dispatched by
; the indirect jump at ROM0:$364D.
DEF wRuntimeCallback EQU $C6BE

; Options-menu values. The table at ROMX:$48C0 associates these addresses with
; the visible MUSIC, CONTROL, and SKILL labels.
DEF wMusicEnabled   EQU $C6BB
DEF wMusicSetting   EQU $D55B
DEF wControlSetting EQU $D55C
DEF wSkillSetting   EQU $D55D

