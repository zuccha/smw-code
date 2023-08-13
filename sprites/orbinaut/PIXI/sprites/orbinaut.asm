;===============================================================================
; ORBINAUT
;===============================================================================

; A floating enemy surrounded by four rotating spike balls. The sprite follows
; the player and throws the spike balls at them if close enough.


;-------------------------------------------------------------------------------
; Configuration
;-------------------------------------------------------------------------------

; Number for "orbinaut_spike_ball.asm" as defined in PIXI's "list.asm".
!spike_ball_sprite_number = $11

; Offset, in pixels, of spike balls with respect to the center of the orbinaut.
!spike_ball_offset = $10

; Movement mode. When the orbinaut should move. If moving, the orbinaut will
; always target Mario.
; 0 = never
; 1 = always
; 2 = only when player is moving
; 3 = only when player is not moving
!movement_type = 1

; Movement speed. It should be a value betwee 0 and 127 ($00 and $7F).
!speed = $08

; Speed for spike balls rotation. Should be one of $00, $01, $02, $04, $08, or
; $10, other values might not behave correctly.
!rotation_speed = $02

; Whether the sprite can go through solid blocks or not.
; 0 = can't go through solid block, 1 = can go through solid blocks
!can_go_through_solid_block = 0

; Tile for the first digit (0) in the graphics file. Digits must be on two
; lines, in the following order:
;   0 1 2 3 4
;   5 6 7 8 9
!gfx_initial_tile = $46


;-------------------------------------------------------------------------------
; Defines
;-------------------------------------------------------------------------------

; Table keeping track of the index of the parent orbinaut in a spike ball.
; Type: Cluster sprite table.
!orbinaut = $0F72|!addr

; Tables keeping track of the angle with respect to the center in a spike ball.
; Every frame the value will be incremented by the rotation speed.
; Type: Cluster sprite table.
!angle_l = $0F4A|!addr
!angle_h = $0F86|!addr

; Tables keeping track of the rotation speed. The speed can be positive or
; negative and should be either 0, 1, 2, 4, 8, or 16. The speed will be inverted
; when the orbinaut changes direction.
; Type: Normal sprite table.
!rotation_l = !1504
!rotation_h = !1510


;-------------------------------------------------------------------------------
; Set Rotation Speed
;-------------------------------------------------------------------------------

; Utility defines.
!rotation_speed_clockwise        = $0000|!rotation_speed
!rotation_speed_counterclockwise = (($0000|!rotation_speed)^$FFFF)+1

; Set spike balls rotations speed.
; @param <speed>: 16-bit number.
macro set_rotation_speed(speed)
    LDA.b #<speed> : STA !rotation_l,x           ; Low byte
    LDA.b #(<speed>)>>8 : STA !rotation_h,x      ; High byte
endmacro

;-------------------------------------------------------------------------------
; Init
;-------------------------------------------------------------------------------

print "INIT ",pc
    PHB : PHK : PLB

    LDA #$01 : STA $18B8|!addr                 ; Run cluster sprite code

    LDA #$00 : STA $00 : LDA #$00 : STA $01    ; $0000
    JSR spawn_spike_ball                       ; Right

    LDA #$80 : STA $00 : LDA #$00 : STA $01    ; $0080
    JSR spawn_spike_ball                       ; Bottom

    LDA #$00 : STA $00 : LDA #$01 : STA $01    ; $0100
    JSR spawn_spike_ball                       ; Left

    LDA #$80 : STA $00 : LDA #$01 : STA $01    ; $0180
    JSR spawn_spike_ball                       ; Top

    %set_rotation_speed(!rotation_speed_clockwise)

    PLB : RTL


;-------------------------------------------------------------------------------
; Main
;-------------------------------------------------------------------------------

print "MAIN ",pc
    PHB : PHK : PLB

    JSR render
    JSR update

    PLB : RTL


;-------------------------------------------------------------------------------
; Render
;-------------------------------------------------------------------------------

render:
    %GetDrawInfo()

    LDA $00 : STA $0300|!Base2,y               ; X position
    LDA $01 : STA $0301|!Base2,y               ; Y position
    LDA #$00 : STA $0302|!Base2,y              ; Tile number

    LDA !15F6,x : ORA $64                      ; Load CFG properties
    PHY                                        ; Preserve Y
    LDY $E4,x : CPY $7E : BCS +                ; If sprite X position < player X position
    EOR #%01000000                             ; Then flip sprite image horizontally
+   LDY !14C8,x : CPY #$02 : BCS +             ; If sprite has been killed
    EOR #%10000000                             ; Then flip sprite image vertically
+   PLY : STA $0303|!Base2,y                   ; Restore Y and save properties

    LDA #$00                                   ; Tile to draw - 1
    LDY #$02                                   ; 16x16 sprite
    JSL $01B7B3|!bank                          ; Finish OAM

    RTS


;-------------------------------------------------------------------------------
; Update
;-------------------------------------------------------------------------------

update:
    LDA #$00
    %SubOffScreen()	                           ; Check if offscreen

    LDA !14C8,x : CMP #$08 : BNE .return       ; If sprite is alive, then continue
    LDA $9D : BNE .return                      ; If game is not frozen, then continue

    JSR invert_rotation                        ; Invert rotation direction if necessary

    STZ $AA,x                                  ; Vertical speed is always zero (no gravity)
    JSR get_speed : STA $B6,x                  ; Compute horizontal speed and set it

+   JSL $01802A|!bank                          ; Set movement with gravity and ground contact
    JSL $01A7DC|!bank                          ; Check for player contact
    JSL $018032|!bank                          ; Check for sprite contact

if !can_go_through_solid_block == 1
    LDA !1588,x : AND #$03 : BEQ .return       ; If sprite touches a wall
    LDA $B6,x : EOR #$FF : INC : STA $B6,x     ; Then invert its speed...
    JSL $01802A|!bank                          ; ...to undo its movement
endif

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
    LDA #!movement_type
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
    PHY : LDY $E4,x : CPY $7E                  ; Compare sprite X position
    BEQ .zero_speed : BCC .positive_speed      ; with player X position

.negative_speed
+   LDA #-!speed                                ; Set negative speed
    PLY : RTS

.positive_speed
+   LDA #!speed                                 ; Set positive speed
    PLY : RTS

.zero_speed
    LDA #$00                                    ; Set zero speed
    PLY : RTS


;-------------------------------------------------------------------------------
; Invert Rotation
;-------------------------------------------------------------------------------

; Invert spike balls rotation if player faces moves on the side of the orbinaut.
invert_rotation:
    PHY : LDY $E4,x : CPY $7E                  ; Compare sprite X position
    BEQ .return : BCC .player_on_right         ; with player X position

.player_on_left
    %set_rotation_speed(!rotation_speed_clockwise)
    PLY : RTS

.player_on_right
    %set_rotation_speed(!rotation_speed_counterclockwise)
    PLY : RTS

.return
    PLY : RTS

;-------------------------------------------------------------------------------
; Spawn Spike Ball
;-------------------------------------------------------------------------------

; Spawn a spike ball around the orbinaut
; @param A: Position relative to the orbinaut. 0 = top, 1 = bottom, 2 = left,
; and 3 = right.
spawn_spike_ball:
    LDY #$13                                   ; There are 20 ($14) cluster slots available
-   LDA !cluster_num,y : BEQ +                 ; If the slot is not free
    DEY : BPL -                                ; The we look at the next one
    RTS                                        ; No free slot, we don't spawn the spike ball

+   LDA.b #!spike_ball_sprite_number+!ClusterOffset
    STA !cluster_num,y                         ; Store spike ball number in free cluster slot

    TXA : STA !orbinaut,y                      ; Save orbinaut as spike ball's parent
    LDA $00 : STA !angle_l,y                   ; Save angle low byte
    LDA $01 : STA !angle_h,y                   ; Save angle high byte

    RTS
