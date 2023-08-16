;===============================================================================
; ORBINAUT SPIKE BALL
;===============================================================================

; A spike ball fluctuating aroung an orbinaut.


;-------------------------------------------------------------------------------
; Configuration (extra bytes)
;-------------------------------------------------------------------------------

; Extra Property Byte 1: Tile number for the spike ball to use. This is a value
; between 0 and 255. The tile chosen to be drawn is taken from an SP graphics
; slot base on this value and which graphics page to use ("Use second graphics
; page" property in the CFG/JSON configuration file):
;   |       | 1st | 2nd |
;   | 00-7F | SP1 | SP3 |
;   | 80-FF | SP2 | SP4 |


;-------------------------------------------------------------------------------
; Defines (don't touch these)
;-------------------------------------------------------------------------------

; These need to be the same as those defined in "orbinaut.asm".
!rotation_l = !1504
!rotation_h = !1510
!orbinaut   = !151C
!angle_l    = !1504
!angle_h    = !1510


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

    ; Render
+   JSR render

    ; Check if sprite needs updates
    LDA $9D : BEQ +                             ; If game is not frozen, then continue
    PLB : RTL                                   ; Then don't update spike ball

    ; Check if sprite needs to be thrown
+   LDA !sprite_speed_x,x : BNE .thrown         ; If ball has not already been thrown...

    LDA !angle_h,x : XBA : LDA !angle_l,x       ; ...and it's at bottom position...
    REP #$20 : CMP #$0080 : SEP #$20 : BNE .orbiting ; (angle is $0080)

    LDA !sprite_x_low,x : STA $00               ; ...and it's within player's range
    LDA !sprite_x_high,x : STA $01              ; (preload ball position)
    %orbinaut(!extra_byte_3) : STA $02          ; (preload range, only low byte)
    STZ $03                                     ; (preload range, high byte is always zero)
    REP #$20 : LDA $7E : SEC : SBC $00 : BPL +  ; (player X - ball X)
    EOR #$FFFF : INC                            ; (take absolute value)
+   CMP $02 : SEP #$20 : BCS .orbiting          ; (distance < range)

    JSR throw                                   ; Then start throw

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
    LDA !extra_prop_1,x : STA $0302|!addr,y     ; Tile number
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
    %orbinaut(!extra_byte_4)                    ; Load speed from extra byte...
    STA !sprite_speed_x,x                       ; ...and store it
    RTS

.clockwise
    %orbinaut(!extra_byte_4)                    ; Load speed from extra byte...
    EOR #$FF : INC : STA !sprite_speed_x,x      ; ...negate it, and store it
    RTS


;-------------------------------------------------------------------------------
; Orbit
;-------------------------------------------------------------------------------

; Orbit spike ball around orbinaut.
orbit:
.rotate
    %orbinaut(!rotation_l) : STA $00            ; Load rotation speed low byte
    %orbinaut(!rotation_h) : STA $01            ; Load rotation speed high byte
    LDA !angle_h,x : XBA : LDA !angle_l,x       ; Load angle
    REP #$20 : CLC : ADC $00                    ; Increase angle by rotation
    AND #$01FF : SEP #$20                       ; And wrap around (modulo)
    STA !angle_l,x : XBA : STA !angle_h,x       ; Store angle

.compute_position_x
    LDA !angle_l,x : STA $00                    ; Load angle low byte
    LDA !angle_h,x : STA $01                    ; Load angle high byte
    JSR compute_cosine                          ; Compute sine
    REP #$20 : LDA $02 : STA $00 : SEP #$20     ; Transfer result
    JSR scale_radius                            ; Adjust radius amplitude

    %orbinaut(!sprite_x_high) : XBA             ; Use orbinaut's coordinates as center
    %orbinaut(!sprite_x_low)
    REP #$20 : CLC : ADC $00 : SEP #$20         ; Add radius
    STA !sprite_x_low,x : XBA                   ; Update Y coordinate
    STA !sprite_x_high,x

.compute_position_y
    LDA !angle_l,x : STA $00                    ; Load angle low byte
    LDA !angle_h,x : STA $01                    ; Load angle high byte
    JSR compute_sine                            ; Compute sine
    REP #$20 : LDA $02 : STA $00 : SEP #$20     ; Transfer result
    JSR scale_radius                            ; Adjust radius amplitude

    %orbinaut(!sprite_y_high) : XBA             ; Use orbinaut's coordinates as center
    %orbinaut(!sprite_y_low)
    REP #$20 : CLC : ADC $00 : SEP #$20         ; Add radius
    STA !sprite_y_low,x : XBA                   ; Update Y coordinate
    STA !sprite_y_high,x

.return
    RTS


;-------------------------------------------------------------------------------
; Interact
;-------------------------------------------------------------------------------

; Handle interactions with player and other sprites.
interact:
    JSL $01A7DC|!bank                          ; Check for player contact
    BCC + : %LoseYoshi()                       ; If there is contact, lose Yoshi

+   JSL $018032|!bank                          ; Check for sprite contact

    %FireballContact() : BCC +                 ; If there is contact with a fireball...
    LDA !extended_num+8,y : CMP #$05 : BNE +   ; ...and the fireball is not smoke already
    LDA #$01 : STA $1DF9|!addr                 ; Then play sound effect...
    LDA #$0F : STA !extended_timer+8,y         ; ...reset fireball timer...
    LDA #$01 : STA !extended_num+8,y           ; ...and turn fireball into smoke

+   RTS


;-------------------------------------------------------------------------------
; Compute Sine/Cosine
;-------------------------------------------------------------------------------

; Compute sine, signed.
; @param $00-$01: Degree (#$0000-#$01FF).
; @return $02-$03: Sine.
compute_sine:
    PHX
    REP #$30 : LDA $00 : AND #$00FF             ; Remove high byte (since there are 0-255 items)
    ASL : TAX : LDA $07F7DB,x : STA $02         ; Load value form table
    SEP #$30 : LDA $01 : BEQ +                  ; If degree value is >= #$0100 (180)
    REP #$20 : LDA $02 : EOR #$FFFF : INC       ; Then we need to flip the result...
    STA $02 : SEP #$20                          ; ...and store the value back
+   PLX : RTS

; Compute cosine, signed.
; @param $00-$01: Degree (#$0000-#$01FF).
; @return $02-$03: Cosine.
compute_cosine:
    PHX : REP #$30
    LDA $00 : CLC : ADC #$0080                  ; Shift by 90 degrees, because cosine = sine + 90
    CMP #$0100 : BCC .first_half                ; If bigger than 180 degrees...
    CMP #$0200 : BCS .first_half                ; ...or if approaching final quadrant

.second_half                                    ; $0100-$01FF
    AND #$00FF                                  ; Modulo by 256
    ASL : TAX : LDA $07F7DB,x                   ; Load value from table
    EOR #$FFFF : INC A : STA $02                ; Store the negated value
    SEP #$30 : PLX : RTS

.first_half                                     ; $0000-$00FF or $0200-$02FF
    AND #$00FF                                  ; Remove high byte (if final quadrant)
    ASL : TAX : LDA $07F7DB,x : STA $02         ; Load and store value from table
    SEP #$30 : PLX : RTS


;-------------------------------------------------------------------------------
; Scale Radius
;-------------------------------------------------------------------------------

; Scale sine/cosine value. The value can be controlled with the defines below:
;   sine * !numerator / !denominator
; By default, those values are 1/16.
; @param $00-$01: Sine/cosine.
; @return $00-$01: Result of the scaling.
!numerator = #$0001
!denominator = #$0010
scale_radius:
    REP #$20 : LDA !numerator : STA $02         ; First multiplier is 1
    LDA $00 : BMI .negative_multiplication      ; Handle positive and negative differently

.positive_multiplication
    JSR multiply : BRA .division                ; Multiply and skip ahead

.negative_multiplication
    EOR #$FFFF : INC : STA $00                  ; Convert multiplier to unsigned
    JSR multiply                                ; Unsigned multiplication
    EOR #$FFFF : INC                            ; Convert product to signed

.division
    STA $00                                     ; Preserve product
    LDA !denominator : STA $02                  ; Divisor
    LDA $00 : BMI .negative_division            ; Handle positive and negative differently

.positive_division
    JSR divide                                  ; Divide
    SEP #$20 : RTS

.negative_division
    EOR #$FFFF : INC : STA $00                  ; Convert dividend to unsigned
    JSR divide : REP #$20                       ; Divide (A is 8-bit)
    LDA $00 : EOR #$FFFF : INC : STA $00        ; Convert result to signed
    SEP #$20 : RTS

; Multiplication (8/16-bit).
; @param $00: First multiplicand.
; @param $02/$04: Second multiplicand.
; @return A: Product.
multiply:
    STA $04
-	LSR $02 : BEQ ++ : BCC +
    CLC : ADC $00
+	ASL $00 : BRA -
++  CLC : ADC $00
    SEC : SBC $04
    RTS

; Division (16-bit).
; @param $00-$01: Dividend.
; @param $02-$03: Divisor.
; @return $00-$01: Quotient.
; @return $02-$03: Remainder.
divide:
    REP #$20
    ASL $00
    LDY #$0F : LDA #$0000
-   ROL A
    CMP $02 : BCC +
    SBC $02
+   ROL $00
    DEY : BPL -
    STA $02
    SEP #$20
    RTS
