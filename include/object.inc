; Runtime object records are 64-byte aligned within their WRAM page.
DEF OBJECT_RECORD_SIZE       EQU $40
DEF OBJECT_RECORD_ALIGN_MASK EQU $C0

; Coordinate fields established by movement, collision, camera, and spawn code.
DEF OBJECT_X_OFFSET           EQU $01 ; 16-bit little-endian pixel coordinate
DEF OBJECT_Y_OFFSET           EQU $04 ; 16-bit little-endian pixel coordinate
DEF OBJECT_PREVIOUS_X_OFFSET  EQU $09 ; 16-bit little-endian pixel coordinate
DEF OBJECT_PREVIOUS_Y_OFFSET  EQU $0B ; 16-bit little-endian pixel coordinate
DEF OBJECT_FRAME_DX_OFFSET    EQU $1B ; current X low minus previous X low
DEF OBJECT_FRAME_DY_OFFSET    EQU $1C ; current Y low minus previous Y low

; Fields established from initialization and every health reader/writer.
DEF OBJECT_TYPE_OFFSET       EQU $1E
DEF OBJECT_HEALTH_OFFSET     EQU $1F
DEF OBJECT_HEALTH_DELTA_MASK EQU $3F
