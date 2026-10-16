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

; Active fixed-background descriptor, copied from SceneBackgroundDescriptors.
DEF wFixedSceneGraphicsBank  EQU $D3E0
DEF wFixedSceneGraphics      EQU $D3E1
DEF wFixedSceneTilemap       EQU $D3E3
DEF wFixedSceneAttributes    EQU $D3E5
DEF wFixedScenePalettes      EQU $D3E7
DEF wFixedScenePaletteCount  EQU $D3E9

; Active scrolling-scene descriptor, copied from ScrollingSceneDescriptors.
DEF wScrollingSceneBank      EQU $D3F0
DEF wScrollingSceneGraphics  EQU $D3F1
DEF wScrollingSceneRows      EQU $D3F3
DEF wScrollingSceneLastRow   EQU $D3F5
DEF wScrollingScenePalette   EQU $D3F6

