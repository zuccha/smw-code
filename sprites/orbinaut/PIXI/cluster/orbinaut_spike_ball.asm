;===============================================================================
; ORBINAUT SPIKE BALL
;===============================================================================

; A spike ball fluctuating aroung an orbinaut.


;-------------------------------------------------------------------------------
; Defines
;-------------------------------------------------------------------------------

; These need to be the same as those defined in "orbinaut.asm".
!orbinaut   = $0F72|!addr
!angle_l    = $0F4A|!addr
!angle_h    = $0F86|!addr
!rotation_l = !1504
!rotation_h = !1510


;-------------------------------------------------------------------------------
; Macros
;-------------------------------------------------------------------------------

; Retrieve a 8-bit property of the parent orbinaut.
; @param Y: Cluster sprite index.
; @param <property>: Address to the sprite table to retrieve.
; @return A: The value of the property.
macro get_orbinaut(property)
    PHX : LDX !orbinaut,y : LDA <property>,x : PLX
endmacro


;-------------------------------------------------------------------------------
; Main
;-------------------------------------------------------------------------------

print "MAIN ",pc
    PHB : PHK : PLB

    ; Check if orbinaut is dead
    %get_orbinaut(!14C8) : CMP #$08 : BEQ +     ; If orbinaut is dead
    LDA #$00 : STA !cluster_num,y               ; Then kill spike ball too
    PLB : RTL

    ; Render
+   JSR render

    ; Check if sprite needs updates
    LDY $15E9|!addr
    LDA $9D : BNE .return                       ; If game is not frozen, then continue

    ; Update
    JSR move
    JSR check_player_interaction

    ; Return
.return
    PLB : RTL


;-------------------------------------------------------------------------------
; Render
;-------------------------------------------------------------------------------

; Draw spike ball.
render:
    LDA !cluster_x_low,y : STA $00
    LDA !cluster_x_high,y : STA $01
    LDA !cluster_y_low,y : STA $02
    LDA !cluster_y_high,y : STA $03

    REP #$20
    LDA $00 : SEC : SBC $1A : STA $00           ; Compute X-position on screen
    BMI .offscreen                              ; If < 0, then sprite is offscreen (left)
    CMP #$00F8 : BCC + : BRA .offscreen         ; If > $F8, then sprite is offscreen (right)
+   LDA $02 : SEC : SBC $1C : STA $02           ; Compute Y-position on screen
    CMP #$FFF0 : BCS +                          ; If < 0, then sprite is offscreen (left)
    CMP #$00F0 : BCC + : BRA .offscreen         ; If > $F8, then sprite is offscreen (rightn
+   SEP #$20

    LDY #$00 : JSR find_oam_slot

    LDA $00 : STA $0200|!addr,y                 ; X position
    LDA $02 : STA $0201|!addr,y                 ; Y position
    LDA #$02 : STA $0202|!addr,y                ; Tile number
    LDA #%00101111 : STA $0203|!addr,y          ; Tile properties

    TYA : LSR #2 : TAY
    LDA #$02 : STA $0420|!addr,y

    RTS

.offscreen
    SEP #$20 : RTS


;-------------------------------------------------------------------------------
; Move
;-------------------------------------------------------------------------------

; Move spike ball, following orbinaut and rotating around it.
move:
.rotate
    %get_orbinaut(!rotation_l) : STA $00        ; Load rotation speed low byte
    %get_orbinaut(!rotation_h) : STA $01        ; Load rotation speed high byte
    LDA !angle_h,y : XBA : LDA !angle_l,y       ; Load angle
    REP #$20 : CLC : ADC $00                    ; Increase it
    AND #$01FF : SEP #$20                       ; And wrap around (modulo)
    STA !angle_l,y : XBA : STA !angle_h,y       ; Store angle

.compute_position_x
    LDA !angle_l,y : STA $00                    ; Load angle low byte
    LDA !angle_h,y : STA $01                    ; Load angle high byte
    JSR compute_cosine                          ; Compute sine
    REP #$20 : LDA $02 : STA $00 : SEP #$20     ; Transfer result
    JSR scale_radius                            ; Adjust radius amplitude

    LDY $15E9|!addr
    %get_orbinaut("!sprite_x_high") : XBA       ; Use orbinaut's coordinates as center
    %get_orbinaut("!sprite_x_low")
    REP #$20 : CLC : ADC $00 : SEP #$20         ; Add radius
    STA !cluster_x_low,y : XBA                  ; Update Y coordinate
    STA !cluster_x_high,y

.compute_position_y
    LDA !angle_l,y : STA $00                    ; Load angle low byte
    LDA !angle_h,y : STA $01                    ; Load angle high byte
    JSR compute_sine                            ; Compute sine
    REP #$20 : LDA $02 : STA $00 : SEP #$20     ; Transfer result
    JSR scale_radius                            ; Adjust radius amplitude

    LDY $15E9|!addr
    %get_orbinaut("!sprite_y_high") : XBA       ; Use orbinaut's coordinates as center
    %get_orbinaut("!sprite_y_low")
    REP #$20 : CLC : ADC $00 : SEP #$20         ; Add radius
    STA !cluster_y_low,y : XBA                  ; Update Y coordinate
    STA !cluster_y_high,y

.return
    RTS


;-------------------------------------------------------------------------------
; Check Player Interaction
;-------------------------------------------------------------------------------

; Check interaction with player. If the two touch, the player is hurt.
check_player_interaction:
    ; Check horizontal position
    LDA !cluster_x_low,y : STA $00              ; Load X position's low and high bytes
    LDA !cluster_x_high,y : STA $01 : REP #$20  ; for 16-bit calculations
    LDA $94 : SEC : SBC $00 : CLC : ADC #$000A  ; If player doesn't overlap ball horizontally
    SEP #$20 : CMP #$14 : BCS .return           ; Then no interaction

    ; Check vertical position
    LDA #$14                                    ; Player height (small)
    LDX $73 : BNE +                             ; If player is not ducking...
    LDX $19 : BEQ +                             ; ...and player is big
    LDA #$20                                    ; The update player height
+   STA $00                                     ; Save player height
    LDA $96 : SEC : SBC !cluster_y_low,y        ; If player doesn't overlap ball vertically
    CLC : ADC #$1C : CMP $00 : BCS .return      ; Then no interaction

    ; Handle interaction
    PHY : JSL $00F5B7|!bank : PLY               ; Hurt player

.return
    RTS


;-------------------------------------------------------------------------------
; Check Sprites Interaction
;-------------------------------------------------------------------------------

; check_sprites_interaction:
;     TXA : BNE + : RTS                           ; If X != 0, return
; +   TAY : DEX                                   ; Y tracks spike ball, X tracks other sprite

; check_sprites_interaction_loop:
;     LDA $14C8,x : CMP #$08
;     BCS CODE_01A421
;     JMP check_sprites_interaction_next

;     ; Check ???.
;     LDA.W RAM_Tweaker1686,X
;     ORA.W RAM_Tweaker1686,Y
;     AND.B #$08
;     ORA.W $1564,X
;     ORA.W $1564,Y
;     ORA.W $15D0,X
;     ORA.W RAM_SprBehindScrn,X
;     EOR.W RAM_SprBehindScrn,Y
;     BNE check_sprites_interaction_next

;     ; Save other sprite's index.
;     STX $1695

;     ; Check horizontal overlap.
;     LDA RAM_SpriteXLo,x : STA $00
;     LDA RAM_SpriteXHi,x : STA $01
;     LDA RAM_SpriteXLo,y : STA $02
;     LDA RAM_SpriteXHi,y : STA $03
;     REP #$20 : LDA $00 : SEC : SBC $02
;     CLC : ADC #$0010 : CMP.W #$0020 : SEP #$20
;     BCS check_sprites_interaction_next

; CODE_01A462:        A0 00         LDY.B #$00
; CODE_01A464:        BD 62 16      LDA.W RAM_Tweaker1662,X
; CODE_01A467:        29 0F         AND.B #$0F
; CODE_01A469:        F0 01         BEQ CODE_01A46C
; CODE_01A46B:        C8            INY

;     LDA RAM_SpriteYLo,x : CLC : ADC.W DATA_01A40B,y : STA $00
;     LDA RAM_SpriteYHi,x : ADC #$00 : STA $01

;     LDY $15E9               ; Y = Sprite index
; CODE_01A47E:        A2 00         LDX.B #$00
; CODE_01A480:        B9 62 16      LDA.W RAM_Tweaker1662,Y
; CODE_01A483:        29 0F         AND.B #$0F
; CODE_01A485:        F0 01         BEQ +
; CODE_01A487:        E8            INX
; +   LDA.W RAM_SpriteYLo,Y
; CODE_01A48B:        18            CLC
; CODE_01A48C:        7D 0B A4      ADC.W DATA_01A40B,X
; CODE_01A48F:        85 02         STA $02
; CODE_01A491:        B9 D4 14      LDA.W RAM_SpriteYHi,Y
; CODE_01A494:        69 00         ADC.B #$00
; CODE_01A496:        85 03         STA $03
; CODE_01A498:        AE 95 16      LDX.W $1695
; CODE_01A49B:        C2 20         REP #$20                  ; Accum (16 bit)
; CODE_01A49D:        A5 00         LDA $00
; CODE_01A49F:        38            SEC
; CODE_01A4A0:        E5 02         SBC $02
; CODE_01A4A2:        18            CLC
; CODE_01A4A3:        69 0C 00      ADC.W #$000C
; CODE_01A4A6:        C9 18 00      CMP.W #$0018
; CODE_01A4A9:        E2 20         SEP #$20                  ; Accum (8 bit)
; CODE_01A4AB:        B0 03         BCS skip
; CODE_01A4AD:        20 BA A4      JSR.W CODE_01A4BA
; check_sprites_interaction_next:
;     DEX : BMI +
;     JMP.W check_sprites_interaction_loop

; +   LDX.W $15E9 : RTS

;-------------------------------------------------------------------------------
; Utils
;-------------------------------------------------------------------------------

; Find a free OAM slot for the current cluster sprite.
; @return Y: OAM index for table $0200-$02FF.
find_oam_slot:
    LDY #$00                                    ; OAM position, start from index 0
-   LDA $0201|!addr,y                           ; Loop through OAM $0200-$02FF
    CMP #$F0 : BEQ +                            ; If slot is free (off screen), then select slot
    INY #4 : BNE -                              ; Else check next slot
    LDY $15E9|!addr                             ; We didn't find a free slot
    LDA #$00 : STA !cluster_num,y               ; So we kill this sprite...
    LDY #$00                                    ; ...and use index 0
+   RTS

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
