;===============================================================================
; ORBINAUT
;===============================================================================

; A floating enemy surrounded by four rotating spike balls. The sprite follows
; the player and throws the spike balls at them if close enough.


;-------------------------------------------------------------------------------
; Configuration (extra bytes)
;-------------------------------------------------------------------------------

; Extra Property Byte 1: Tile number for the orbinaut to use. This is a value
; between 0 and 255. The tile chosen to be drawn is taken from an SP graphics
; slot base on this value and which graphics page to use ("Use second graphics
; page" property in the CFG/JSON configuration file):
;   |       | 1st | 2nd |
;   | 00-7F | SP1 | SP3 |
;   | 80-FF | SP2 | SP4 |

; Extra Property Byte 2: Number for "orbinaut_spike_ball.cfg" as defined in
; PIXI's "list.asm".

; Extra bit: If 1, the orbinaut can go through solid walls (blocks), otherwise
; it stops there.

; Extra Byte 1: Movement type, it should be one of
; - 00 = Never move
; - 01 = Always move towards player
; - 02 = Move towards player if player is moving
; - 03 = Move towards player if player is not moving

; Extra Byte 2: Orbinaut horizontal speed. It should be a value betwee 0 and 127
; ($00 and $7F).

; Extra Byte 3: Throw range. If the player is within this range, the orbinaut
; will start shoting the spike balls when they are at angle 270 (bottom).

; Extra Byte 4: Throw speed. The horizontal speed of the spike ball once it has
; beed thrown.


;-------------------------------------------------------------------------------
; Configuration (defines)
;-------------------------------------------------------------------------------

; Speed for spike balls rotation. Should be one of $00, $01, $02, $04, $08, or
; $10, other values might not behave correctly.
!rotation_speed = $02


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
!orbinaut = !151C

; Tables keeping track of the angle with respect to the center in a spike ball.
; Every frame the value will be incremented by the rotation speed.
; Sprite: Spike Ball
!angle_l = !1504
!angle_h = !1510

; Rotation values.
!rotation_speed_clockwise        = $0000|!rotation_speed
!rotation_speed_counterclockwise = -($0000|!rotation_speed)


;-------------------------------------------------------------------------------
; Macros
;-------------------------------------------------------------------------------

; Set spike balls rotations speed.
; @param <speed>: 16-bit number.
macro set_rotation_speed(speed)
    LDA.b #<speed> : STA !rotation_l,x           ; Low byte
    LDA.b #(<speed>)>>8 : STA !rotation_h,x      ; High byte
endmacro

; Compare spike ball and player X positions.
; @param X: Spike ball sprite index.
macro cmp_sprite_player_x()
    LDA !sprite_x_high,x : XBA : LDA !sprite_x_low,x
    REP #$20 : CMP $94 : SEP #$20
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
    LDA !extra_prop_1,x : STA $0302|!addr,y    ; Tile number

    LDA !sprite_oam_properties,x : ORA $64     ; Load CFG properties
    PHY                                        ; Preserve Y

    PHA : %cmp_sprite_player_x() : BCS ++      ; If sprite X position < player X position
    PLA : EOR #%01000000 : BRA +               ; Then flip sprite image horizontally
++  PLA                                        ; Restore A

+   LDY !sprite_status,x : CPY #$02 : BCS +    ; If sprite has been killed
    EOR #%10000000                             ; Then flip sprite image vertically

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

    JSL $01802A|!bank                          ; Move orbinaut
    JSL $01A7DC|!bank                          ; Check for player contact
    JSL $018032|!bank                          ; Check for sprite contact

    LDA !extra_bits,x : AND #04 : BEQ .return  ; If extra bit is set...
    LDA !1588,x : AND #$03 : BEQ .return       ; ...and sprite touches a wall
    LDA !sprite_speed_x,x : EOR #$FF : INC     ; Then invert its speed...
    STA !sprite_speed_x,x
    JSL $01802A|!bank                          ; ...to undo its movement

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
    LDA !extra_byte_1,x
    CMP #$03 : BEQ .move_if_player_doesnt_move
    CMP #$02 : BEQ .move_if_player_moves
    CMP #$01 : BEQ .move

.dont_move
    LDA #$00 : RTS                             ; Don't move

.move_if_player_doesnt_move
    LDA $7B : BEQ .move                        ; If player is not moving, then move
    LDA #$00 : RTS                             ; Else speed if 0

.move_if_player_moves
    LDA $7B : BNE .move                        ; If player is moving, then move
    LDA #$00 : RTS                             ; Else speed if 0

.move
    %cmp_sprite_player_x()
    BEQ .zero_speed
    BCC .positive_speed

.negative_speed
    LDA !extra_byte_2,x                        ; Load orbinaut speed
    EOR #$FF : INC A                           ; Negate it
    RTS

.positive_speed
    LDA !extra_byte_2,x                        ; Load orbinaut speed
    RTS

.zero_speed
    LDA #$00                                   ; Set zero speed
    RTS


;-------------------------------------------------------------------------------
; Invert Rotation
;-------------------------------------------------------------------------------

; Invert spike balls rotation if player faces moves on the side of the orbinaut.
invert_rotation:
    %cmp_sprite_player_x()
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

; Spawn a spike ball around the orbinaut
; @param $04-$05: Rotation angle.
spawn_spike_ball:
    PHY                                        ; Preserve X and Y, and store orbinaut index in Y
    LDA !extra_prop_2,x                        ; Sprite number to spawn
    STZ $00 : STZ $01 : STZ $02 : STZ $03      ; Zero offset and speed
    ; LDX.b #!sprite_slots-1                     ; Number of slots to look through
    SEC                                        ; Custom sprite
    %SpawnSprite()                             ; Spawn Spike Ball

    BCC +                                      ; If sprite failed to spawn
    PLY : RTS                                  ; Then return

+   TXA : STA !orbinaut,y                      ; Save orbinaut as spike ball's parent
    LDA $04 : STA !angle_l,y                   ; Save angle low byte
    LDA $05 : STA !angle_h,y                   ; Save angle high byte

    PLY : RTS
