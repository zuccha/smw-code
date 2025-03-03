;===============================================================================
; ORBINAUT
;===============================================================================

; A floating enemy surrounded by four rotating spike balls. The sprite follows
; the player and throws the spike balls at them if close enough.


;-------------------------------------------------------------------------------
; Configuration (extra bytes)
;-------------------------------------------------------------------------------

; Extra bit: If 1, the orbinaut can go through solid walls (blocks), otherwise
; it stops there.

; Extra Byte 1 (bits 0-3): Movement type, it should be one of
; - 0 = Never move
; - 1 = Always move towards player
; - 2 = Move towards player if player is moving
; - 3 = Move towards player if player is not moving
; - 4 = Always move left
; - 5 = Always move right

; Extra Byte 1 (bits 4-7): Spike balls orbit radius relative to orbinaut's
; center. The radius is expressed in tiles (each unit is 16 pixels).

; Extra Byte 2: Orbinaut horizontal speed. It should be a value betwee 0 and 127
; ($00 and $7F).

; Extra Byte 3: Throw range. If the player is within this range, the orbinaut
; will start throwing the spike balls when they are at angle 270 (bottom).

; Extra Byte 4: Throw speed. The horizontal speed of the spike ball once it has
; beed thrown. If zero, the ball will never be thrown.


;-------------------------------------------------------------------------------
; Configuration (defines)
;-------------------------------------------------------------------------------

; Speed for spike balls rotation. Should be one of $00, $01, $02, $04, $08, or
; $10, other values might not behave correctly.
!rotation_speed = $02

; Tile number for the orbinaut to use. This is a value between 0 and 255. The
; tile chosen to be drawn is taken from an SP graphics slot based on this value
; and which graphics page to use ("Use second graphics page" property in the
; JSON configuration file):
;   |       | 1st | 2nd |
;   | 00-7F | SP1 | SP3 |
;   | 80-FF | SP2 | SP4 |
!gfx_tile = $C0

; Number for "orbinaut_spike_ball.json" as defined in PIXI's "list.asm".
!ball_number = $01


;-------------------------------------------------------------------------------
; Defines (don't touch these)
;-------------------------------------------------------------------------------

; Tables keeping track of the rotation speed. The speed can be positive or
; negative and should be either 0, 1, 2, 4, 8, or 16. The speed will be inverted
; when the orbinaut changes direction.
; Sprite: Orbinaut
!rotation_l = !1504
!rotation_h = !1510

; Table keeping track of the index of the parent orbinaut in a spike ball.
; Sprite: Spike Ball
!ball_orbinaut = !151C

; Tables keeping track of the angle with respect to the center in a spike ball.
; Every frame the value will be incremented by the rotation speed.
; Sprite: Spike Ball
!ball_angle_l = !1504
!ball_angle_h = !1510

; Tables keeping track of the throw range and speed for a spike ball.
; Sprite: Spike Ball
!ball_throw_range = !1528
!ball_throw_speed = !1570

; Table keeping track of the radius from the orbinaut's center.
; Sprite: Spike Ball
!ball_radius = !157C

; Table keeping track whether a spike ball is being eaten by Yoshi or not.
; Sprite: Spike Ball
!ball_eaten = !1594

; Rotation values.
!rotation_speed_clockwise        = $0000|!rotation_speed
!rotation_speed_counterclockwise = -($0000|!rotation_speed)


;-------------------------------------------------------------------------------
; Macros
;-------------------------------------------------------------------------------

; Set spike balls rotations speed.
; @param <speed>: 16-bit number.
macro set_rotation_speed(speed)
    LDA.b #<speed> : STA !rotation_l,x
    LDA.b #(<speed>)>>8 : STA !rotation_h,x
endmacro

; Get the movement type from extra byte 1.
macro load_movement_type()
    LDA !extra_byte_1,x : AND #$0F
endmacro

; Get the ball orbit radius from extra byte 1.
macro load_ball_radius()
    LDA !extra_byte_1,x : AND #$F0
endmacro


;-------------------------------------------------------------------------------
; Init
;-------------------------------------------------------------------------------

init:
    PHB : PHK : PLB

    LDA #$00 : STA $04 : LDA #$00 : STA $05    ; $0000
    JSR spawn_spike_ball                       ; Right
    LDA #$80 : STA $04 : LDA #$00 : STA $05    ; $0080
    JSR spawn_spike_ball                       ; Bottom
    LDA #$00 : STA $04 : LDA #$01 : STA $05    ; $0100
    JSR spawn_spike_ball                       ; Left
    LDA #$80 : STA $04 : LDA #$01 : STA $05    ; $0180
    JSR spawn_spike_ball                       ; Top

    %set_rotation_speed(!rotation_speed_clockwise)

    PLB : RTL


;-------------------------------------------------------------------------------
; Main
;-------------------------------------------------------------------------------

main:
    PHB : PHK : PLB

    JSR render
    JSR update

    PLB : RTL


;-------------------------------------------------------------------------------
; Render
;-------------------------------------------------------------------------------

render:
    %GetDrawInfo()

    LDA $00 : STA $0300|!addr,y                ; X position
    LDA $01 : STA $0301|!addr,y                ; Y position
    LDA.b #!gfx_tile : STA $0302|!addr,y       ; Tile number

    LDA !sprite_oam_properties,x : ORA $64     ; Load CFG properties
    PHY                                        ; Preserve Y

    PHA : JSR get_direction : BCS ++           ; If sprite X position < player X position
    PLA : EOR #%01000000 : BRA +               ; Then flip sprite image horizontally
++  PLA                                        ; Restore A

+   PLY : STA $0303|!addr,y                    ; Restore Y and save properties

    LDA #$00                                   ; Draw one tile
    LDY #$02                                   ; 16x16 sprite
    JSL $01B7B3|!bank                          ; Finish OAM

    RTS


;-------------------------------------------------------------------------------
; Update
;-------------------------------------------------------------------------------

update:
    LDA #$00 : %SubOffScreen()                 ; Despawn if offscreen

    LDA !sprite_status,x : CMP #$08 : BNE .return ; If sprite is alive, then continue
    LDA $9D : BNE .return                      ; If game is not frozen, then continue

    JSR invert_rotation                        ; Invert rotation direction if necessary

    STZ !sprite_speed_y,x                      ; Vertical speed is always zero (no gravity)
    JSR get_speed : STA !sprite_speed_x,x      ; Compute horizontal speed and set it

    JSL $018022|!bank                          ; Move orbinaut (only x position)
    JSL $019138|!bank                          ; Check block interaction
    JSL $01A7DC|!bank                          ; Check for player contact
    JSL $018032|!bank                          ; Check for sprite contact

    LDA !extra_bits,x : AND #04 : BEQ .return  ; If extra bit is set...
    LDA !1588,x : AND #$03 : BEQ .return       ; ...and sprite touches a wall
    LDA !sprite_speed_x,x : EOR #$FF : INC     ; Then invert its speed...
    STA !sprite_speed_x,x
    JSL $018022|!bank                          ; ...to undo its movement

.return
    RTS


;-------------------------------------------------------------------------------
; Get Speed
;-------------------------------------------------------------------------------

; Compute the speed of the sprite based on its movement type and the speed and
; position of the player.
; @param X: Sprite index.
; @return A: The speed of the sprite.
get_speed:
    %load_movement_type()
    ASL : TAX : JMP (.get_speed_ptr,x)

.get_speed_ptr:
    dw .dont_move
    dw .move_towards_player
    dw .move_towards_player_if_player_moves
    dw .move_towards_player_if_player_doesnt_move
    dw .move_left
    dw .move_right

.dont_move
    LDX $15E9|!addr
    LDA #$00 : RTS                             ; Don't move

.move_towards_player_if_player_doesnt_move
    LDX $15E9|!addr
    LDA $7B : BEQ .move_towards_player         ; If player is not moving, then move
    LDA #$00 : RTS                             ; Else speed is 0

.move_towards_player_if_player_moves
    LDX $15E9|!addr
    LDA $7B : BNE .move_towards_player         ; If player is moving, then move
    LDA #$00 : RTS                             ; Else speed is 0

.move_towards_player
    LDX $15E9|!addr
    JSR get_direction
    BEQ .dont_move
    BCC .move_right

.move_left
    LDX $15E9|!addr
    LDA !extra_byte_2,x                        ; Load orbinaut speed
    EOR #$FF : INC A                           ; Negate it
    RTS

.move_right
    LDX $15E9|!addr
    LDA !extra_byte_2,x                        ; Load orbinaut speed
    RTS


;-------------------------------------------------------------------------------
; Invert Rotation
;-------------------------------------------------------------------------------

; Invert spike balls rotation if player faces moves on the side of the orbinaut.
invert_rotation:
    JSR get_direction
    BEQ .return : BCC .player_on_right

.player_on_left
    %set_rotation_speed(!rotation_speed_clockwise)
    RTS

.player_on_right
    %set_rotation_speed(!rotation_speed_counterclockwise)
    RTS

.return
    RTS


;-------------------------------------------------------------------------------
; Spawn Spike Ball
;-------------------------------------------------------------------------------

; Spawn a spike ball around the orbinaut.
; N.B.: We don't use PIXI's SpawnSprite because it doesn't take into account
; sprite memory. We use $07F7D2 instead to find an empty sprite slot.
; @param $04-$05: Rotation angle.
spawn_spike_ball:
    PHY                                        ; Preserve Y
    JSL $02A9E4|!bank                          ; Look for empty slot
    BPL +                                      ; If no sprite slot found
    PLY : RTS                                  ; Then return

+   PHX : TYX
    LDA.b #!ball_number                        ;\ Set sprite number
    STA !9E,x : STA !7FAB9E,x                  ;/
    JSL $07F7D2|!bank                          ; Reset sprite tables
    JSL $0187A7|!bank                          ; Reset (other?) sprite tables
    LDA #$08 : STA !7FAB10,x                   ; Set extra bits
    LDA #$01 : STA !14C8,x                     ; Make sprite alive
    PLX

    TXA : STA !ball_orbinaut,y                 ; Save orbinaut as spike ball's parent
    LDA !sprite_x_low,x : STA !sprite_x_low,y  ; Same X position as the orbinaut
    LDA !sprite_x_high,x : STA !sprite_x_high,y
    LDA !sprite_y_low,x : STA !sprite_y_low,y  ; Same Y position as the orbinaut
    LDA !sprite_y_high,x : STA !sprite_y_high,y
    LDA #$00 : STA !sprite_speed_x,y           ; X speed is zero
    STA !sprite_speed_y,y                      ; Y speed is zero
    STA !ball_eaten,y                          ; Not eaten at first
    LDA $04 : STA !ball_angle_l,y              ; Save angle low byte
    LDA $05 : STA !ball_angle_h,y              ; Save angle high byte
    %load_ball_radius() : STA !ball_radius,y   ; Save radius
    LDA !extra_byte_3,x : STA !ball_throw_range,y ; Save throw range
    LDA !extra_byte_4,x : STA !ball_throw_speed,y ; Save throw speed

    PLY : RTS


;-------------------------------------------------------------------------------
; Get Direction
;-------------------------------------------------------------------------------

; Compare spike ball and player X positions.
; @param X: Orbinaut sprite index.
; @return Z: 1 if there is no change in direction, 0 otherwise.
; @return C: 1 if facing right, 0 if facing left.
get_direction:
    %load_movement_type()
    CMP #$05 : BEQ .always_right
    CMP #$04 : BEQ .always_left

    LDA !sprite_x_high,x : XBA : LDA !sprite_x_low,x
    REP #$20 : CMP $94 : SEP #$20
    RTS

.always_left:
    REP #%00000010 : SEC                       ; Z = 0, C = 1
    RTS

.always_right:
    REP #%00000011                             ; Z = 0, C = 0
    RTS
