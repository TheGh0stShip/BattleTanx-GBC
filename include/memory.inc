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


; Sound driver state (see AUDIO_RESEARCH.md). Written by Audio_Init
; ($06:$7CAE) and used by the driver in bank $06 and ROM0:$2ED5-$2F92.
; Not named because no behavior is established: $C8E3 (non-zero blocks
; music note-on; only ever cleared), $C8E4 and $C8F6 (written, never read).
DEF wMusicDelay      EQU $C8E7 ; frames until the next music event
DEF wMusicPtr        EQU $C8E8 ; 2 bytes, high byte first; 0 high = no music
DEF wMusicLoopPtr    EQU $C8EA ; 2 bytes, high byte first
DEF wChannelSettings EQU $C8EC ; 4 x (instrument, NR51 bit pattern)
DEF wMusicBank       EQU $C8F4 ; ROM bank holding the current music sequence
DEF wNotePan         EQU $C8F5 ; scratch: NR51 bit pattern for the note being started
DEF wNoiseLockTimer  EQU $C8F7 ; $37 after a channel-4 patch; music ch4 waits
DEF wSfxSeqPtr       EQU $C8F8 ; 2 bytes, little-endian; 0 high = idle
DEF wSfxSeqDelay     EQU $C8FA ; frames until the next sequence event
DEF wSoundQueueNext  EQU $C8FB ; next queue slot Audio_Update reads
DEF wSoundQueueLast  EQU $C8FC ; last queue slot Audio_QueueSound wrote
DEF wSoundQueue      EQU $C8FD ; 30-entry ring of sound ids, 0 = empty
DEF SOUND_QUEUE_SIZE EQU 30
DEF wSfxSeqLock      EQU $C91B ; non-zero: requests for ids $40-$7F are ignored
DEF wSfxSeqLockId    EQU $C91C ; id that sets wSfxSeqLock when started
