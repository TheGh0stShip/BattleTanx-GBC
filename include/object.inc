; Runtime object records are 64-byte aligned within their WRAM page.
DEF OBJECT_RECORD_SIZE       EQU $40
DEF OBJECT_RECORD_ALIGN_MASK EQU $C0

; Coordinate fields established by movement, collision, camera, and spawn code.
DEF OBJECT_X_SUBPIXEL_OFFSET  EQU $00
DEF OBJECT_X_OFFSET           EQU $01 ; 16-bit little-endian pixel coordinate
DEF OBJECT_Y_SUBPIXEL_OFFSET  EQU $03
DEF OBJECT_Y_OFFSET           EQU $04 ; 16-bit little-endian pixel coordinate
DEF OBJECT_SCREEN_X_OFFSET    EQU $06
DEF OBJECT_SCREEN_Y_OFFSET    EQU $07
DEF OBJECT_FLAGS_OFFSET       EQU $08
DEF OBJECT_VISIBLE_FLAG       EQU $08
DEF OBJECT_PREVIOUS_X_OFFSET  EQU $09 ; 16-bit little-endian pixel coordinate
DEF OBJECT_PREVIOUS_Y_OFFSET  EQU $0B ; 16-bit little-endian pixel coordinate
DEF OBJECT_VEHICLE_VELOCITY_X_OFFSET EQU $0D ; signed 24-bit 16.8 delta
DEF OBJECT_VEHICLE_VELOCITY_Y_OFFSET EQU $10 ; signed 24-bit 16.8 delta
DEF OBJECT_NEXT_X_SUBPIXEL_OFFSET EQU $13
DEF OBJECT_NEXT_X_OFFSET      EQU $14 ; 16-bit little-endian pixel coordinate
DEF OBJECT_NEXT_Y_SUBPIXEL_OFFSET EQU $16
DEF OBJECT_NEXT_Y_OFFSET      EQU $17 ; 16-bit little-endian pixel coordinate
DEF OBJECT_DIRECTION_OFFSET   EQU $19 ; low nibble, 16 directions
; Vehicle-only drive controls. Flag bit 0 selects the direction+$08 velocity
; vector; speed is bounded by the maximum selected from the vehicle type.
DEF OBJECT_VEHICLE_SPEED_OFFSET         EQU $1A
DEF OBJECT_VEHICLE_REVERSE_FLAG         EQU $01
DEF OBJECT_VEHICLE_TURN_INTERVAL_OFFSET EQU $23
DEF OBJECT_VEHICLE_TURN_TIMER_OFFSET    EQU $24
DEF OBJECT_VEHICLE_MAX_SPEED_OFFSET     EQU $25
DEF OBJECT_FRAME_DX_OFFSET    EQU $1B ; current X low minus previous X low
DEF OBJECT_FRAME_DY_OFFSET    EQU $1C ; current Y low minus previous Y low
DEF OBJECT_STATUS_OFFSET      EQU $1D ; 0 free, nonzero allocated

; Fields established from initialization and the sprite-rendering path.
; Byte +$1F is type-dependent: core vehicle records use it as health, while
; timed type-3 effect records use it as their current animation age.
DEF OBJECT_TYPE_OFFSET             EQU $1E
DEF OBJECT_HEALTH_OR_AGE_OFFSET    EQU $1F
DEF OBJECT_HEALTH_OFFSET           EQU OBJECT_HEALTH_OR_AGE_OFFSET
DEF OBJECT_EFFECT_AGE_OFFSET       EQU OBJECT_HEALTH_OR_AGE_OFFSET
DEF OBJECT_STATUS4_LIFETIME_OFFSET EQU OBJECT_HEALTH_OR_AGE_OFFSET
; Byte +$20 is status-dependent. Vehicles use the type-initialized value to
; reload their action timer; timed effects compare their age against it; the
; status-2 update path treats values 0, 1, and 2 as distinct states.
DEF OBJECT_TYPE_STATE_OR_LIMIT_OFFSET      EQU $20
DEF OBJECT_VEHICLE_ACTION_INTERVAL_OFFSET  EQU $20
DEF OBJECT_EFFECT_LIFETIME_OFFSET          EQU $20
DEF OBJECT_TYPE2_STATE_OFFSET              EQU $20
DEF OBJECT_VEHICLE_ACTION_TIMER_OFFSET     EQU $21
DEF OBJECT_VEHICLE_ACTIVE_SHOTS_OFFSET     EQU $22
DEF OBJECT_FRAME_TABLE_OFFSET      EQU $21 ; bank-$02 pointer
DEF OBJECT_OAM_LAYOUT_OFFSET       EQU $23 ; bank-$02 pointer
DEF OBJECT_TILE_COUNT_OFFSET       EQU $25
DEF OBJECT_PLAYER_POWERUP_TYPE_OFFSET    EQU $29 ; 0 none, 1..3 active kind
DEF OBJECT_PLAYER_POWERUP_CHARGES_OFFSET EQU $2A
DEF OBJECT_HEALTH_DELTA_MASK       EQU $3F
DEF OBJECT_COUNT                   EQU $40
