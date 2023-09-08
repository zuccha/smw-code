;===============================================================================
; BOMB EXPLOSION (GUNSTAR HEROES)
;===============================================================================

; Explosion for the bomb from Gunstar Heroes.


;-------------------------------------------------------------------------------
; Configuration
;-------------------------------------------------------------------------------

; Offset applied to all graphics values. Possible values:
; - $00 = for SP1 and SP3
; - $80 = for SP2 and SP4
; N.B.: If you edit this value, make sure to change also its counterpart in
; "gunstar_heroes_bomb.asm".
!gfx_offset = $80

; Which tile to use for explosion animation frames. Every row represents an
; animation frame. Every animation frame is composed of four 16x16 tiles, in
; order they are top-left, top-right, bottom-left, and bottom-right.
tile_gfx:
;       TL   TR   BL   BR
    db $00, $00, $00, $00 ; 0
    db $02, $02, $02, $02 ; 1
    db $08, $0A, $28, $2A ; 2
    db $0C, $0E, $2C, $2E ; 3
    db $40, $42, $60, $62 ; 4
    db $44, $46, $64, $66 ; 5
    db $48, $4A, $68, $6A ; 6
    db $4C, $4E, $6C, $6E ; 7

; How to flip tiles defined in `tile_gfx`. Flips can be:
; - $00 = no flip
; - $40 = flip X
; - $80 = flip Y
; - $C0 = flip X and Y
tile_flip:
;       TL   TR   BL   BR
    db $00, $40, $80, $C0 ; 0
    db $00, $40, $80, $C0 ; 1
    db $00, $00, $00, $00 ; 2
    db $00, $00, $00, $00 ; 3
    db $00, $00, $00, $00 ; 4
    db $00, $00, $00, $00 ; 5
    db $00, $00, $00, $00 ; 6
    db $00, $00, $00, $00 ; 7

; Radius for the explosion hitbox, for each animation frame (note that the
; hitbox box will be a square, not a circle). You should use values between $00
; and $10.
hitbox_radius:
;       0    1    2    3    4    5    6    7
    db $06, $0A, $0A, $0A, $0A, $0A, $0A, $06

; Duration, in frames, for each animation step. It should be a power of 2 ($01,
; $02, $04, $08, $10, $20, $40, $80).
!animation_duration = $08

; Speed for spike balls rotation. Should be one of $00, $01, $02, $04, $08, or
; $10, other values might not behave correctly.
!rotation_speed = $08

; Factor that determines the amplitude of the explosion blast from the center.
; One column is for the inner blast, the other is for the outer. In practice,
; values are numerator/denominator.
;                               Inner  Outer
rotation_radius_numerator:   dw $0001, $0003
rotation_radius_denominator: dw $0010, $0020


;-------------------------------------------------------------------------------
; Defines (don't touch these)
;-------------------------------------------------------------------------------

; OAM properties for the blast, same as the bomb.
!oam_properties = !cluster_misc_0f4a

; Center coordinates around which the blast rotates.
!center_x_l = !cluster_misc_0f5e
!center_x_h = !cluster_misc_0f72
!center_y_l = !cluster_misc_0f86
!center_y_h = !cluster_misc_0f9a

; Motion type, determines how the blast rotates around the center.
; $00 = inner, clockwise.
; $01 = outer, counter-clockwise.
!motion = !cluster_misc_1e52

; Rotation angle around the center.
!angle_l = !cluster_misc_1e66
!angle_h = !cluster_misc_1e7a

; Current state of the animation, the value goes from $00 to $07.
!animation_frame = !cluster_misc_1e8e


;-------------------------------------------------------------------------------
; Main
;-------------------------------------------------------------------------------

; Execute sprite's code.
main:
    PHB : PHK : PLB

    JSR render
    JSR update

    PLB : RTL


;-------------------------------------------------------------------------------
; Render
;-------------------------------------------------------------------------------

; Draw bomb.
render:
    LDA !animation_frame,x : ASL #2                ; Offset for the animation frame
    INC A : INC A : INC A : STA $05                ; in tile and flip tables

    LDA !oam_properties,x : STA $06                ; Load palette

    PHX : LDX #$03                                 ; 4 tiles

-   LDA .offset_x,x : STA $03                      ; Prepare X offset
    LDA .offset_y,x : STA $04                      ; Prepare Y offset
    JSR get_draw_info                              ; If no free OAM slot or out of screen
    BCC +                                          ; Then draw next

    LDA $00 : STA $0200|!addr,y                    ; Set X position
    LDA $01 : STA $0201|!addr,y                    ; Set Y position

    PHX : LDX $05                                  ; Load tile/flip tables index
    LDA tile_gfx,x : CLC : ADC.b #!gfx_offset      ; Graphics tile, plus offset for SP2 and SP4
    STA $0202|!addr,y                              ; Set tile number
    LDA $06 : ORA tile_flip,x : STA $0203|!addr,y  ; Tile properties with X/Y flip
    DEX : STX $05 : PLX                            ; Update tile/flip tables index in advance

    PHY : TYA : LSR #2 : TAY : LDA #$02            ; Tile is 16x16
    ORA $02 : STA $0420|!addr,y : PLY              ; Add X position's high bit

+   DEX : BPL -                                    ; Draw next tile

    PLX : RTS                                      ; Return restoring sprite index

.offset_x: db $F8, $08, $F8, $08
.offset_y: db $F8, $F8, $08, $08


;-------------------------------------------------------------------------------
; Get Draw Info
;-------------------------------------------------------------------------------

; Compute drawing coordinates and retrieve an OAM slot.
; Adapted from `ClusterGetDrawInfo`.
; @param $03: X offset.
; @param $04: Y offset.
; @return Y: OAM slot index.
; @return $00: X position on screen.
; @return $01: Y position on screen.
; @return $02: X position's high bit.
; @return C: 1 if can be drawn, 0 otherwise.
get_draw_info:
    PHX : LDX $15E9|!addr                          ; Load current sprite index

    ; Y position
    LDA !cluster_y_low,x                           ; Y position...
    CLC : ADC $04                                  ; ...plus offset
    SEC : SBC $1C : STA $01                        ; ...minus layer 1 position
    CMP #$E0 : BCC +                               ; If it's not within screen
    CLC : ADC #$10 : BPL +                         ; boundaries
    PLX : CLC : RTS                                ; Then return

    ; X position
+   STZ $02                                        ; Initially assume no high bit
    LDA !cluster_x_low,x : CLC : ADC $03 : XBA     ; X position...
    BIT $03 : BMI ++                               ; ...plus offset...
    LDA !cluster_x_high,x : ADC #$00 : XBA : BRA + ; (add positive value)
++  LDA !cluster_x_high,x : ADC #$FF : XBA         ; (add negative value)
+   SEC : SBC $1A : STA $00                        ; ...inus layer 1 position
    XBA : SBC $1B : BEQ +                          ; If no high bit, then it's on screen
    XBA : CLC : ADC #$38 : CMP #$70 : BCC ++       ; If it's not on screen
    PLX : CLC : RTS                                ; Then return
++  INC $02                                        ; Else set high bit

    ; Find OAM slot
+   LDY #$00 : SEC                                 ; Start searching at index 0
-   LDA $0201|!addr,y : CMP #$F0                   ; If OAM slot is offscreen
    BEQ +                                          ; Then we consider it free
    INY #4 : BNE -                                 ; Else we check the next slot
    PLX : CLC : RTS                                ; No free slot

    ; Return
+   PLX : SEC : RTS                                ; Slot found and sprite is on screen


;-------------------------------------------------------------------------------
; Update
;-------------------------------------------------------------------------------

; Blast's lifecycle.
update:
    LDA $9D : BEQ +                                ; If sprites are locked
    RTS                                            ; Then skip

+   JSR orbit

    LDA $13 : AND.b #!animation_duration-1 : BNE + ; Every some frames...
    INC !animation_frame,x                         ; ...go to next animation frame
    LDA !animation_frame,x : CMP #$08 : BCC +      ; If we are done with the animation
    STZ !cluster_num,x                             ; Then remove sprite
    RTS

+   JSR get_sprite_clipping_A                      ; Get sprite clipping A
    JSL $03B664|!bank                              ; Get player clipping B
    JSL $03B72B|!bank : BCC +                      ; Check for contact
    JSL $00F5B7|!bank                              ; Hurt Mario

+   RTS


;-------------------------------------------------------------------------------
; Get Sprite Clipping A
;-------------------------------------------------------------------------------

; Get the clipping values for the routine checking collision ($03B72B).
; This works (conceptually) similarly to $03B69F.
; @return $04: X position, low byte.
; @return $05: Y position, low byte.
; @return $06: Width.
; @return $07: height.
; @return $0A: X position, high byte.
; @return $0B: Y position, high byte.
get_sprite_clipping_A:
    LDA !animation_frame,x : TAY                   ; Get the hitbox radius of
    LDA hitbox_radius,y : STA $00 : STZ $01        ; the current animation frame

    LDA !cluster_x_high,x : XBA : LDA !cluster_x_low,x ; X position...
    REP #$20 : SEC : SBC $00                       ; ...minus the radius...
    CLC : ADC #$0008 : SEP #$20                    ; ...plus half a tile
    STA $04 : XBA : STA $0A                        ; Store low and high bytes

    LDA !cluster_y_high,x : XBA : LDA !cluster_y_low,x ; Y position...
    REP #$20 : SEC : SBC $00                       ; ...minus the radius...
    CLC : ADC #$0008 : SEP #$20                    ; ...plus half a tile
    STA $05 : XBA : STA $0B                        ; Store low and high bytes

    LDA $00 : ASL : STA $06 : STA $07              ; Size is twice the radius

    RTS


;-------------------------------------------------------------------------------
; Orbit
;-------------------------------------------------------------------------------

; Orbit explosion around center.
orbit:
    LDA !motion,x : ASL : TAY                   ; Load motion to index tables

    REP #$20
    LDA rotation_radius_numerator,y : STA $06   ; Load rotation radius for later
    LDA rotation_radius_denominator,y : STA $08 ; computations
    SEP #$20

    ; Rotate
    LDA !angle_h,x : XBA : LDA !angle_l,x       ; Load angle
    REP #$20 : CLC : ADC .rotation_speed,y      ; Increase angle by rotation
    AND #$01FF : SEP #$20                       ; And wrap around (modulo)
    STA !angle_l,x : XBA : STA !angle_h,x       ; Store angle

    ; Compute X position
    LDA !angle_l,x : STA $00                    ; Load angle low byte
    LDA !angle_h,x : STA $01                    ; Load angle high byte
    JSR compute_cosine                          ; Compute cosine
    REP #$20 : LDA $02 : STA $00 : SEP #$20     ; Transfer result
    JSR scale_radius                            ; Adjust radius amplitude

    LDA !center_x_h,x : XBA : LDA !center_x_l,x ; Center of the explosion
    REP #$20 : CLC : ADC $00 : SEP #$20         ; Add radius
    STA !cluster_x_low,x : XBA                  ; Update Y coordinate
    STA !cluster_x_high,x

    ; Compute Y position
    LDA !angle_l,x : STA $00                    ; Load angle low byte
    LDA !angle_h,x : STA $01                    ; Load angle high byte
    JSR compute_sine                            ; Compute sine
    REP #$20 : LDA $02 : STA $00 : SEP #$20     ; Transfer result
    JSR scale_radius                            ; Adjust radius amplitude

    LDA !center_y_h,x : XBA : LDA !center_y_l,x ; Center of the explosion
    REP #$20 : CLC : ADC $00 : SEP #$20         ; Add radius
    STA !cluster_y_low,x : XBA                  ; Update Y coordinate
    STA !cluster_y_high,x

    ; Return
    RTS

    ; Rotation speed, indexed by the `motion` value
.rotation_speed:
    dw $0000|!rotation_speed                    ; Clockwise
    dw -($0000|!rotation_speed)                 ; Counter-clockwise


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
; @param $06-$07: Numerator.
; @param $08-$09: Denominator.
; @return $00-$01: Result of the scaling.
scale_radius:
    LDA !motion,x : ASL : TAY                   ; Load motion to index numerator/denominator

.multiplication
    REP #$20 : LDA $06 : STA $02                ; Load numerator
    LDA $00 : BMI .negative_multiplication      ; Handle positive and negative differently

.positive_multiplication
    JSR multiply : BRA .division                ; Multiply and skip ahead

.negative_multiplication
    EOR #$FFFF : INC : STA $00                  ; Convert multiplier to unsigned
    JSR multiply                                ; Unsigned multiplication
    EOR #$FFFF : INC                            ; Convert product to signed

.division
    STA $00                                     ; Preserve product
    LDA $08 : STA $02                           ; Load the denumerator
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
