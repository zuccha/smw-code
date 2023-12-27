;===============================================================================
; KILL PLAYER ON BUTTON PRESS (indicator)
;===============================================================================

; Indicator sprite that follows Mario and keeps track of how many inputs he has
; left.


;-------------------------------------------------------------------------------
; Configuration (extra bit)
;-------------------------------------------------------------------------------

; Extra bit: If 1, the indicator will show the amount of inputs left (when it
; reaches zero Mario dies), otherwise it shows the inputs done (when it reaches
; the threshold Mario dies).


;-------------------------------------------------------------------------------
; Configuration (defines)
;-------------------------------------------------------------------------------

; Number of pressed required to hurt/kill the player.
; Must be a value between 1-255 ($01-$FF). 0 won't do anything, any value above
; 255 ($FF) will crash the game.
; N.B.: This needs to be the same as the one defined in the level's ASM!
!button_presses_threshold = $0A

; 1 byte of free RAM, keeping track of the number of presses (1 byte).
; N.B.: This needs to be the same as the one defined in the level's ASM!
!ram_button_presses_count = $140B|!addr

; Which SP graphics file to use. Valid values range from 1 to 4.
!gfx_sp = 3

; Tiles for the digits in the graphics file. Each digit must be 8x8 pixels.
;              0    1    2    3    4    5    6    7    8    9
gfx_tiles: db $46, $47, $48, $49, $4A, $56, $57, $58, $59, $5A

; Color palette to use for the digits. Accepted values go from 0 to 7.
!gfx_palette = 6

; How much space, in pixels, a single digit takes (they should be squares).
!digit_size = $08

; Vertical offset, in pixels, relative to the player for the indicator. Needed
; to shift the indicator slightly up when Mario is big.
player_offset:
    db $00, $08, $08, $08 ; Small, Big, Cape, Fire


;-------------------------------------------------------------------------------
; Constants
;-------------------------------------------------------------------------------

; Offset for the initial tile, taking into account which SP has been chosen.
if !gfx_sp == 2 || !gfx_sp == 4
    !gfx_offset = $80
else
    !gfx_offset = $00
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
; Macros
;-------------------------------------------------------------------------------

; Since the value can exceed the threshold, we clamp it.
macro lda_ram_button_presses_count()
    LDA.w !ram_button_presses_count
    CMP.b #!button_presses_threshold : BCC ?+
    LDA.b #!button_presses_threshold
?+
endmacro


;-------------------------------------------------------------------------------
; Main
;-------------------------------------------------------------------------------

main:
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

    %lda_ram_button_presses_count() : STA $00 ; Number to show = current count
    LDA !extra_bits,x : AND #04 : BEQ +  ; If the extra bit is set
    LDA.b #!button_presses_threshold     ; Then number to show = threshold - current count
    SEC : SBC $00 : STA $00

+   STZ $01                               ; Initial offset for digits is 0

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
    STA $0300|!addr,y                     ; Save X position to OAM

    ; Y-position
    LDA $80                               ; A = Player's Y position
    LDX $19 : SEC : SBC player_offset,x   ; Subtract Mario's size offset to player's Y position
    STA $0301|!addr,y                     ; Save X position to OAM

    ; Tile number
    LDX $02 : LDA gfx_tiles,x             ; GFX tile based on digit
    CLC : ADC.b #!gfx_offset              ; Plus the offset (first or second page)
    STA $0302|!addr,y                     ; Save tile number to OAM

    ; Tile properties
    LDA.b !tile_properties                ; No flips, priority 2
    STA $0303|!addr,y                     ; Save tile properties to OAM

    ; Draw tile
    TYA : LSR : LSR : TAY                 ; Adjust index for tile size table
    LDA #$00 : STA $0460|!addr,y          ; 8x8 tile

    ; Return
    PLY : PLX : RTS
