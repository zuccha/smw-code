;===============================================================================
; POWERUP
;===============================================================================

; Power up item box, will display an item if it is present in the box.


;-------------------------------------------------------------------------------
; Methods Definition
;-------------------------------------------------------------------------------

!PowerUp = HandlePowerUp


;-------------------------------------------------------------------------------
; Handler
;-------------------------------------------------------------------------------

; Draw power up on status bar.
; @return A (16-bit): #$0001 if the indicator has been drawn, #$0000 otherwise.
; @return Z: 0 if the indicator has been drawn, 1 otherwise.
HandlePowerUp:
    ; Backup registers and check visibility.
    PHX : PHY ; Stack: X, Y <-
    %check_visibility(!PowerUpVisibility, 2, 1)

.visibility1
    ; Slightly modified version of routine found at $009079 to draw the power up
    ; sprite.
    ; FIXME: Invoke original routine instead?
    SEP #$30 : LDX #$E0                        ; Default power up sprite is feather
    BIT $0D9B|!addr : BVC +                    ; If Reznor's, Morton's, or Roy's battle mode
    LDX #$00                                   ; Then set power up sprite to none
    LDA $0D9B|!addr : CMP #$C1 : BEQ +         ; If not Bowser's battle mode
    LDA #$F0 : STA $0201|!addr,x               ; Then set power up sprite as unused (out of screen)
+   STX !T1                                    ; Save sprite number in !T1 for later use
    LDX $0DC2|!addr : BEQ .return              ; If there is a power up in the item box
    LDA.l PowerUpPal1,x : STA !T0              ; Then load palette for current power up
    CPX #$03 : BNE +                           ; If power up is Star
    LDA $13|!addr : LSR : AND #$03 : TAX       ; Then every second frame change the palette
    LDA.l PowerUpPal2,x : STA !T0              ; of the star in the item box (store in $00)
+   LDY !T1                                    ; Set power up...
    LDA #!PowerUpPositionX : STA $0200|!addr,y ; ...X position
    LDA #$0F : STA $0201|!addr,y               ; ...Y position
    LDA #$30 : ORA !T0 : STA $0203|!addr,y     ; ...palette
    LDX $0DC2|!addr : LDA.l PowerUpTile,x      ; ...tile
    STA $0202|!addr,y                          ;
    TYA : LSR : LSR : TAY                      ; Divide power up sprite by 4...
    LDA #$02 : STA $0420|!addr,y               ; ...and set it's size to $02

.return
    REP #$30 : PLY : PLX
    RTS

.visibility0
.visibility2
    REP #$30 : PLY : PLX
    RTS


; Palette for mushroom, feather, and flower.
PowerUpPal1: db $02,$08,$0A,$00,$04

; The (alternating) palette for the star.
PowerUpPal2: db $00,$02,$04

; Tiles for the powerup.
PowerUpTile: db $44,$24,$26,$48,$0E
