;===============================================================================
; POWERUP
;===============================================================================

; Power up item box, will display an item if it is present in the box.


;-------------------------------------------------------------------------------
; Methods Definition
;-------------------------------------------------------------------------------

!PowerUp = IsPowerUpVisible, ShowPowerUp


;-------------------------------------------------------------------------------
; Visibility Checks
;-------------------------------------------------------------------------------

IsPowerUpVisible:
    %check_visibility_simple(!PowerUpVisibility, 2, 1)


;-------------------------------------------------------------------------------
; Render
;-------------------------------------------------------------------------------

; Draw power up on status bar.
ShowPowerUp:
    ; Backup X/Y, move A into Y, and set A 8-bit.
    PHX : PHY : SEP #$30

    ; Slightly modified version of routine found at $009079 to draw the power up
    ; sprite.
    LDX #$E0                             ; Default power up sprite is feather
    BIT $0D9B : BVC +                    ; If ???
    LDX #$00                             ; Then set power up sprite to none
    LDA $0D9B : CMP #$C1 : BEQ +         ; If not Bowser's battle mode
    LDA #$F0 : STA $0201,x               ; Then set power up sprite as unused (out of screen)
+   STX $01                              ; Save sprite number in $01 for later use
    LDX $0DC2 : BEQ .return              ; If there is a power up in the item box
    LDA.l PowerUpPal1,x : STA $00        ; Then load palette for current power up
    CPX #$03 : BNE +                     ; If power up is Star
    LDA $13 : LSR : AND #$03 : TAX       ; Then every second frame change the palette
    LDA.l PowerUpPal2,x : STA $00        ; of the star in the item box (store in $00)
+   LDY $01                              ; Set power up...
    LDA #!PowerUpPositionX : STA $0200,y ; ...X position
    LDA #$0F : STA $0201,y               ; ...Y position
    LDA #$30 : ORA $00 : STA $0203,y     ; ...palette
    LDX $0DC2 : LDA.l PowerUpTile,x      ; ...tile
    STA $0202,y                          ;
    TYA : LSR : LSR : TAY                ; Divide power up sprite by 4...
    LDA #$02 : STA $0420,y               ; ...and set it's size to $02

    ; Restore X/Y, set A 16-bit, and return.
.return
    REP #$30 : PLY : PLX
    RTS

; Palette for mushroom, feather, and flower.
PowerUpPal1: db $02,$08,$0A,$00,$04

; The (alternating) palette for the star.
PowerUpPal2: db $00,$02,$04

; Tiles for the powerup.
PowerUpTile: db $44,$24,$26,$48,$0E
