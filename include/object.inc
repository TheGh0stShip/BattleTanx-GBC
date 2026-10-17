; Runtime object records are 64-byte aligned within their WRAM page.
DEF OBJECT_RECORD_SIZE       EQU $40
DEF OBJECT_RECORD_ALIGN_MASK EQU $C0

; Fields established from initialization and every health reader/writer.
DEF OBJECT_TYPE_OFFSET       EQU $1E
DEF OBJECT_HEALTH_OFFSET     EQU $1F
DEF OBJECT_HEALTH_DELTA_MASK EQU $3F
