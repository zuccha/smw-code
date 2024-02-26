;===============================================================================
; POWER UP
;===============================================================================

; Power up item box, will display an item if it is present in the box.


;-------------------------------------------------------------------------------
; Handler
;-------------------------------------------------------------------------------

; Draw power up on status bar.
power_up:
    %check_visibility(power_up)

.visibility1
    ; Slightly modified version of routine found at $009079 to draw the power up
    ; sprite. The X position is customizable.
    LDX #$E0                                        ; Default power up sprite is feather
    BIT $0D9B|!addr : BVC +                         ; If Reznor's, Morton's, or Roy's battle mode
    LDX #$00                                        ; Then set power up sprite to none
    LDA $0D9B|!addr : CMP #$C1 : BEQ +              ; If not Bowser's battle mode
    LDA #$F0 : STA $0201|!addr,x                    ; Then set power up sprite as unused (out of screen)
+   STX $01                                         ; Save sprite number in $01 for later use
    LDX $0DC2|!addr : BEQ .return                   ; If there is a power up in the item box
    LDA.l power_up_pal1_table,x : STA $00           ; Then load palette for current power up
    CPX #$03 : BNE +                                ; If power up is Star
    LDA $13|!addr : LSR : AND #$03 : TAX            ; Then every second frame change the palette
    LDA.l power_up_pal2_table,x : STA $00           ; of the star in the item box (store in $00)
+   LDY $01                                         ; Set power up...
    LDA ram_power_up_position_x : STA $0200|!addr,y ; ...X position
    LDA #$0F : STA $0201|!addr,y                    ; ...Y position
    LDA #$30 : ORA $00 : STA $0203|!addr,y          ; ...palette
    LDX $0DC2|!addr : LDA.l power_up_tile_table,x   ; ...tile
    STA $0202|!addr,y                               ;
    TYA : LSR : LSR : TAY                           ; Divide power up sprite by 4...
    LDA #$02 : STA $0420|!addr,y                    ; ...and set it's size to $02

.return
.visibility0
.visibility2
    RTS


; Palette for mushroom, feather, and flower.
power_up_pal1_table: db $02,$08,$0A,$00,$04

; The (alternating) palette for the star.
power_up_pal2_table: db $00,$02,$04

; Tiles for the powerup.
power_up_tile_table: db $44,$24,$26,$48,$0E
