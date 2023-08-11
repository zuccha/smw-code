;===============================================================================
; KILL PLAYER ON BUTTON PRESS (indicator)
;===============================================================================

; Indicator sprite that follows Mario and keeps track of how many inputs he has
; left.


;-------------------------------------------------------------------------------
; Configuration
;-------------------------------------------------------------------------------

; Number of pressed required to hurt/kill the player.
; Must be a value between 1-255 ($01-$FF). 0 won't do anything, any value above
; 255 ($FF) will crash the game.
; N.B.: This needs to be the same as the one defined in the level's ASM!
!button_presses_threshold = $0A

; 1 byte of free RAM, keeping track of the number of presses (1 byte).
; N.B.: This needs to be the same as the one defined in the level's ASM!
!ram_button_presses_count = $140B

; Whether to show the inputs left or done.
; 0 = show inputs done (when it reaches the threshold Mario dies)
; 1 = show inputs left (when it reaches zero Mario dies)
!show_inputs_left = 1

; Which SP graphics file to use. Valid values range from 1 to 4.
!gfx_sp = 3

; Tile for the first digit (0) in the graphics file. Digits must be on two
; lines, in the following order:
;   0 1 2 3 4
;   5 6 7 8 9
!gfx_initial_tile = $46

; Color palette to use for the digits. Accepted values go from 0 to 7.
!gfx_palette = 6

; How much space, in pixel, a single digit takes (they should be squared).
!digit_size = $08


;-------------------------------------------------------------------------------
; Constants
;-------------------------------------------------------------------------------

; Offset for the initial tile, taking into account which SP has been chosen.
if !gfx_sp == 2 || !gfx_sp == 4
    !gfx_initial_tile_offset = !gfx_initial_tile+$80
else
    !gfx_initial_tile_offset = !gfx_initial_tile
endif

; Which graphics page to use.
if !gfx_sp <= 2
    !gfx_page = 0
else
    !gfx_page = 1
endif

; Tile properties
!tile_properties = #%00100000|(!gfx_palette<<1)|!gfx_page


;-------------------------------------------------------------------------------
; Main
;-------------------------------------------------------------------------------

print "MAIN ",pc
    PHB : PHK : PLB
    JSR draw_indicator_as_number
    PLB
    RTL


;-------------------------------------------------------------------------------
; Draw Indicator as Number
;-------------------------------------------------------------------------------

; Draw the indicator over Mario's head as a number, up to three digits long.
; The routine makes use of the following scratch RAM:
; - $00: Number to show in the counter.
; - $01: Current digit horizontal offset.
; - $02: Current decimal digit to draw.
draw_indicator_as_number:
    LDA $71 : CMP #$09 : BNE +            ; If player is not dying, then show indicator
    RTS                                   ; Else do nothing (to prevent counter visual glitch)

+   PHX                                   ; Preserve X

    LDY !15EA,x                           ; OAM sprite index

if !show_inputs_left == 0
    LDA.w !ram_button_presses_count|!Base2
    STA $00                               ; Number to show = current count
else
    LDA.b #!button_presses_threshold
    SEC : SBC.w !ram_button_presses_count|!Base2
    STA $00                               ; Number to show = threshold - current count
endif

    STZ $01                               ; Initial offset for digits is 0

    CMP #$0A : BCC .digit_1s              ; If number to show < 10, then draw 1 digit
    CMP #$64 : BCC .digit_10s             ; Else if number to show < 100, then draw 2 digits
                                          ; Else draw 3 digits

.digit_100s
    LDA $00 : LDX #$00                    ; A is number to show, X counts 100s
-   CMP #$64 : BCC +                      ; While A >= 100
    SBC #$64 : INX                        ; Subtract 100 and increase 100s count
    BRA -                                 ; Repeat
+   STA $00 : STX $02                     ; Update number to show and set 100s digit
    JSR draw_digit                        ; Draw 100s digit
    LDA $01 : CLC                         ; Increase offset by the specified amount
    ADC.b #!digit_size : STA $01          ; to draw next digit on the right side
    INY : INY : INY : INY                 ; Go to next OAM sprite (every one is 4 bytes)

.digit_10s
    LDA $00 : LDX #$00                    ; A is number to show, X counts 10s
-   CMP #$0A : BCC +                      ; While A >= 10
    SBC #$0A : INX                        ; Subtract 10 and increase 10s count
    BRA -                                 ; Repeat
+   STA $00 : STX $02                     ; Update number to show and set 10s digit
    JSR draw_digit                        ; Draw 10s digit
    LDA $01 : CLC                         ; Increase offset by the specified amount
    ADC.b #!digit_size : STA $01          ; to draw next digit on the right side
    INY : INY : INY : INY                 ; Go to next OAM sprite (every one is 4 bytes)

.digit_1s
    LDA $00 : STA $02                     ; What's left is the 1s digit
    JSR draw_digit                        ; Draw 1s digit

.return
    PLX : RTS


;-------------------------------------------------------------------------------
; Draw Digit
;-------------------------------------------------------------------------------

; Draw a single digit. Effectively, this sets the correct tile in the OAM table.
; @param Y: OAM index.
; @param $01: Digit X offset.
; @param $02: Decimal digit to draw.
draw_digit:
    ; Preserve X and Y
    PHX : PHY

    ; X-position
    LDA $7E                               ; A = Player's X position
    CLC : ADC $01                         ; Add digit offset to player's X position
    STA $0300|!Base2,y                    ; Save X position to OAM

    ; Y-position
    LDA $80                               ; A = Player's Y position
    LDX $19 : SEC : SBC offset,x          ; Subtract Mario's size offset to player's Y position
    STA $0301|!Base2,y                    ; Save X position to OAM

    ; Tile number
    LDA $02 : CMP #$05 : BCC +            ; If digit >= 5
    CLC : ADC #$0B                        ; Then move to the next line
+   CLC : ADC.b #!gfx_initial_tile_offset ; Add the initial tile as offset
    STA $0302|!Base2,y                    ; Save tile number to OAM

    ; Tile properties
    LDA.b !tile_properties                ; No flips, priority 2
    STA $0303|!Base2,y                    ; Save tile properties to OAM

    ; Draw tile
    TYA : LSR : LSR : TAY                 ; Adjust index for tile size table
    LDA #$00 : STA $0460|!Base2,y         ; 8x8 tile

    ; Return
    PLY : PLX : RTS


;-------------------------------------------------------------------------------
; Helper Tables
;-------------------------------------------------------------------------------

; Vertical offset relative to the player for the indicator. Needed to shift the
; indicator slightly up when Mario is big.
; 0 = Small, 1 = Big, 2 = Cape, 3 = Fire
offset:
    db $00, $08, $08, $08
