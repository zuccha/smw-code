;===============================================================================
; ORBINAUT SPIKE BALL
;===============================================================================

; A spike ball fluctuating aroung an orbinaut.


;-------------------------------------------------------------------------------
; Configuration (defines)
;-------------------------------------------------------------------------------

; Tile number for the spike ball to use. This is a value between 0 and 255. The
; tile chosen to be drawn is taken from an SP graphics slot base on this value
; and which graphics page to use ("Use second graphics page" property in the
; JSON configuration file):
;   |       | 1st | 2nd |
;   | 00-7F | SP1 | SP3 |
;   | 80-FF | SP2 | SP4 |
!gfx_tile = $E0


;-------------------------------------------------------------------------------
; Defines (don't touch these)
;-------------------------------------------------------------------------------

; These need to be the same as those defined in "orbinaut.asm", without the
; "ball_" prefix.
!rotation_l  = !1504
!rotation_h  = !1510
!orbinaut    = !151C
!angle_l     = !1504
!angle_h     = !1510
!throw_range = !1528
!throw_speed = !1570
!radius      = !157C
!eaten       = !1594


;-------------------------------------------------------------------------------
; Macros
;-------------------------------------------------------------------------------

; Retrieve a 8-bit property of the parent orbinaut.
; @param X: Spike Ball sprite index.
; @param <property>: Address to the sprite table to retrieve.
; @return A: The value of the property.
macro orbinaut(property)
    PHY : TXY
    LDX !orbinaut,y : LDA <property>,x
    TYX : PLY
endmacro


;-------------------------------------------------------------------------------
; Main
;-------------------------------------------------------------------------------

init:
    PHB : PHK : PLB
    JSR orbit                                   ; Orbit once to setup X and Y positions
    PLB : RTL


;-------------------------------------------------------------------------------
; Main
;-------------------------------------------------------------------------------

main:
    PHB : PHK : PLB

    ; Check if orbinaut is dead
    LDA !sprite_speed_x,x : BNE +               ; If ball has not already been thrown...
    %orbinaut(!sprite_status) : CMP #$08 : BNE ++ ; ...and orbinaut is dead...
    %orbinaut(!sprite_num) : CMP #$21 : BNE +   ; ...or orbinaut has been turned into a coin
++  STZ !sprite_status,x                        ; Then kill spike ball too
    PLB : RTL

    ; Check if spike ball has been eaten
+   LDA $15D8|!addr,x : BEQ ++                  ; If ball is on Yoshi's tongue
    LDA #$01 : STA !eaten,x : BRA +             ; Then mark sprite as being eaten
++  LDA !eaten,x : BEQ +                        ; Else if ball was previously marked as eaten (but no longer)
    STZ !sprite_status,x                        ; Then kill spike ball
    PLB : RTL

    ; Render
+   JSR render

    ; Check if sprite needs updates
    LDA $9D : BEQ +                             ; If game is not frozen, then continue
    PLB : RTL                                   ; Then don't update spike ball

    ; Check if sprite needs to be thrown
+   LDA !sprite_speed_x,x : BNE .thrown         ; If ball has not already been thrown...

    LDA !angle_h,x : XBA : LDA !angle_l,x       ; ...and it's at bottom position...
    REP #$20 : CMP #$0080 : SEP #$20 : BNE .orbiting ; (angle is $0080)

    LDA !throw_range,x : STA $00 : STZ $01      ; Load range (high byte is always zero)
    %SubHorzPos() : REP #$20 : LDA $0E          ; Compute distance between sprite and player...
    BPL + : EOR #$FFFF : INC                    ; ...and take its absolute value
+   CMP $00 : SEP #$20                          ; If distance is greater than throw distance
    BCS .orbiting                               ; Then it's orbiting
    JSR throw                                   ; Othwise it's within range, throw ball

.thrown
    LDA #$00 : %SubOffScreen()                  ; Despawn if offscreen
    STZ !sprite_speed_y,x                       ; Vertical speed is always zero (no gravity)
    JSL $01802A|!bank                           ; Move spike ball
    BRA .interactions

.orbiting
    JSR orbit

.interactions
    JSR interact

.return
    PLB : RTL


;-------------------------------------------------------------------------------
; Render
;-------------------------------------------------------------------------------

; Draw spike ball.
render:
    %GetDrawInfo()

    LDA $00 : STA $0300|!addr,y                 ; X position
    LDA $01 : STA $0301|!addr,y                 ; Y position
    LDA.b #!gfx_tile : STA $0302|!addr,y        ; Tile number
    LDA !sprite_oam_properties,x : ORA $64      ; Tile properties
    STA $0303|!addr,y

    LDA #$00                                    ; Draw one tile
    LDY #$02                                    ; 16x16 sprite
    JSL $01B7B3|!bank                           ; Finish OAM

    RTS


;-------------------------------------------------------------------------------
; Throw
;-------------------------------------------------------------------------------

; Set spike ball speed when it is thrown.
throw:
    %orbinaut(!rotation_h)                      ; Check rotation direction
    AND #$80 : BEQ .clockwise                   ; (poor people's BLP .clockwise)

.counterclockwise
    LDA !throw_speed,x                          ; Load speed from extra byte...
    STA !sprite_speed_x,x                       ; ...and store it
    RTS

.clockwise
    LDA !throw_speed,x                          ; Load speed from extra byte...
    EOR #$FF : INC : STA !sprite_speed_x,x      ; ...negate it, and store it
    RTS


;-------------------------------------------------------------------------------
; Orbit
;-------------------------------------------------------------------------------

; Orbit spike ball around orbinaut.
orbit:
    LDA !radius,x : STA $06                     ; Load radius

    %orbinaut(!rotation_l) : STA $04            ;\
    %orbinaut(!rotation_h) : STA $05            ;| Update current angle by
    LDA !angle_h,x : XBA : LDA !angle_l,x       ;| Orbinaut's rotation speed,
    REP #$20 : CLC : ADC $04                    ;| then save it in $04 (for
    AND #$01FF : STA $04 : SEP #$20             ;| later use) and update table
    STA !angle_l,x : XBA : STA !angle_h,x       ;/

    %CircleX()                                  ;\
    %orbinaut(!sprite_x_high) : XBA             ;| Recompute orbital X position
    %orbinaut(!sprite_x_low)                    ;| relative to the Orbinaut's
    REP #$20 : CLC : ADC $07 : SEP #$20         ;| center
    STA !sprite_x_low,x : XBA                   ;|
    STA !sprite_x_high,x                        ;/

    %CircleY()                                  ;\
    %orbinaut(!sprite_y_high) : XBA             ;| Recompute orbital Y position
    %orbinaut(!sprite_y_low)                    ;| relative to the Orbinaut's
    REP #$20 : CLC : ADC $09 : SEP #$20         ;| center
    STA !sprite_y_low,x : XBA                   ;|
    STA !sprite_y_high,x                        ;/

    RTS


;-------------------------------------------------------------------------------
; Interact
;-------------------------------------------------------------------------------

; Handle interactions with player and other sprites.
interact:
    LDA !sprite_speed_x,x : BNE +              ; If ball has not been thrown...
    %orbinaut($15D8|!addr) : CMP #$00 : BEQ +  ; ...and orbinaut's core is not being eaten
    RTS                                        ; Then do not interact

+   JSL $01A7DC|!bank                          ; Check for player contact
    BCC + : %LoseYoshi()                       ; If there is contact, lose Yoshi

+   JSL $018032|!bank                          ; Check for sprite contact

    %FireballContact() : BCC +                 ; If there is contact with a fireball...
    LDA !extended_num+8,y : CMP #$05 : BNE +   ; ...and the fireball is not smoke already
    LDA #$01 : STA $1DF9|!addr                 ; Then play sound effect...
    LDA #$0F : STA !extended_timer+8,y         ; ...reset fireball timer...
    LDA #$01 : STA !extended_num+8,y           ; ...and turn fireball into smoke

+   RTS
