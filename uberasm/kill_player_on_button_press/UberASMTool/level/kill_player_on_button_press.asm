;===============================================================================
; KILL PLAYER ON BUTTON PRESS
;===============================================================================

; UberASM that kills the player after a button of your choosing has been pressed
; a given amount of times.

; The button(s), amount of presses, behavior, and other properties can be
; configured down below.


;-------------------------------------------------------------------------------
; Configuration - Behavior
;-------------------------------------------------------------------------------

; 1 byte of free RAM, keeping track of the number of presses.
!ram_button_presses_count = $140B|!addr

; Number of pressed required to hurt/kill the player.
; Must be a value between 0-254 ($00-$FE). 0 will affect the player instantly,
; while 255 will not work properly.
!button_presses_threshold = $0A

; Which buttons, when pressed, increase the counter.
; 0 = don't increase the counter, 1 = increase the counter
; If multiple buttons will be pressed simultaneously (in the same frame), the
; counter will be incremented only once.
; For technical reasons, it is not possible to determine if only Y has been
; pressed :(
!button_A      = 1
!button_B      = 1
!button_X      = 0
!button_X_or_Y = 0
!button_L      = 0
!button_R      = 0
!button_start  = 0
!button_select = 0
!button_down   = 0
!button_left   = 0
!button_right  = 0
!button_up     = 0

; Determine if the player should die or being hurt when reaching the threshold.
; 0 = hurt
; 1 = die
!kill_player = 0

; Determine if the counter should reset after the player has been hurt.
; It should be relevant only if !kill_player = 0 (so that the player can be hurt
; multiple times).
; 0 = don't reset counter
; 1 = reset counter
!reset_counter = 1

; Determine if it should detect button presses when the player is hurt.
; 0 = don't detect presses if player is being hurt
; 1 = detect presses if player is being hurt
!increase_counter_if_player_is_hurt = 0

; Determine if it should detect button presses when the game is paused.
; Please note that if this is enabled, the player will be affected and the
; counter in the status bar will be updated only once the game is unpaused!
; 0 = don't detect presses if game is paused
; 1 = detect pressed even if game is paused
!increase_counter_if_game_is_paused = 0


;-------------------------------------------------------------------------------
; Configuration - Status Bar Indicator
;-------------------------------------------------------------------------------

; Visibility of the indicator in the status bar.
; 0 = None
; 1 = Display number of presses done
; 2 = Display number of presses left
!statusbar_visibility = 1

; Status bar RAM for deciding where to draw the counter. By default, it replaces
; the "TIME" text, above the timer.
; For more, check out https://smwc.me/m/smw/ram/7E0EF9
!statusbar_100s = $0F0A|!addr
!statusbar_10s  = $0F0B|!addr
!statusbar_1s   = $0F0C|!addr


;-------------------------------------------------------------------------------
; Configuration - Sprite Indicator
;-------------------------------------------------------------------------------

; Visibility of the indicator as a sprite that follows the player.
; 0 = None
; 1 = Display number of presses done
; 2 = Display number of presses left
!sprite_visibility = 2

; Which SP graphics file to use. Valid values range from 1 to 4.
!sprite_sp = 3

; Tiles for the digits in the graphics file. Each digit must be 8x8 pixels.
; These are configured to work with the included "Indicator (SP3).bin" graphics.
;                 0    1    2    3    4    5    6    7    8    9
sprite_tiles: db $46, $47, $48, $49, $4A, $56, $57, $58, $59, $5A

; Color palette to use for the digits. Accepted values go from 0 to 7.
!sprite_palette = 6

; How much space, in pixels, a single digit takes (they should be squares).
!sprite_digit_size = $08

; OAM index (from $0200) for the sprite indicator. Up to three OAM slots (one
; per digit) are required. `$00E4-$00EC` seem to be used only for boss fights,
; change them if you have some conflict. You can check available slots here:
; https://docs.google.com/spreadsheets/d/1sndhAA9zoRrNFdsGVL0CEq71VJBhKUjUmi14qGIfDpI/edit#gid=0
!sprite_oam_index = $00E4


;-------------------------------------------------------------------------------
; Defines (don't touch)
;-------------------------------------------------------------------------------

; Format: byetUDLR.
; b = B; y = X or Y; e = select; t = start; U = up; D = down; L = left, R = right.
!controller_mask_1 = (!button_B<<7)|(!button_X_or_Y<<6)|(!button_select<<5)|(!button_start<<4)|(!button_up<<3)|(!button_down<<2)|(!button_left<<1)|!button_right

; Format: axlr----.
; a = A; x = X; l = L; r = R, - = unused.
!controller_mask_2 = (!button_A<<7)|(!button_X<<6)|(!button_L<<5)|(!button_R<<4)

; Offset for the initial tile, taking into account which SP has been chosen.
if !sprite_sp == 2 || !sprite_sp == 4
    !sprite_offset = $80
else
    !sprite_offset = $00
endif

; Which graphics page to use.
if !sprite_sp <= 2
    !sprite_page = 0
else
    !sprite_page = 1
endif

; Tile properties
!sprite_properties = %00100000|(!sprite_palette<<1)|!sprite_page


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
; Init
;-------------------------------------------------------------------------------

init:
    ; Reset counter.
    STZ.w !ram_button_presses_count

    ; Draw indicator once to erase "TIME" text before first frame is rendered.
    if !statusbar_visibility > 0 : JSR draw_statusbar_indicator

    ; Return
    RTL


;-------------------------------------------------------------------------------
; Main
;-------------------------------------------------------------------------------

; Draw indicators and update counter.
main:
    ; Draw indicators if required.
    if !statusbar_visibility > 0 : JSR draw_statusbar_indicator
    if !sprite_visibility    > 0 : JSR draw_sprite_indicator

    ; !ram_button_presses_count determines what needs to be done. If it's
    ; smaller than the threshold, then we keep monitoring inputs; if it's the
    ; same, we need to affect the player; otherwise there is nothing more to do.
    ; We do it this way, instead of triggering the affect part after detecting
    ; the final button press, to avoid triggering Mario's death while the game
    ; is paused (which crashes the game).
    LDA.w !ram_button_presses_count             ; Check how many times the
    CMP.b #!button_presses_threshold            ; button has been pressed
    BCC .update_count                           ; count < threshold
    BEQ .affect_player                          ; count = threshold
    RTL                                         ; count > threshold

    ; Increase count by one if all conditions are met: player is not hurt or
    ; it's allowed to be hurt; game is not paused or it's allowed to increase
    ; when paused; one of the configured buttons has been pressed.
.update_count
if !increase_counter_if_player_is_hurt != 1
    LDA $71 : CMP #$01 : BEQ ++                 ; If player is hurt
    LDA $1497|!addr : BEQ +                     ; or has iframes
++  RTL                                         ; Then return
+
endif

if !increase_counter_if_game_is_paused != 1
    LDA $9D : ORA $13D4|!addr : BEQ +           ; If game is paused
    RTL                                         ; Then return
+
endif

    LDA $16 : AND.b #!controller_mask_1         ; If one of the buttons (1) has been pressed
    BNE .increase_counter                       ; Then increase button count
    LDA $18 : AND.b #!controller_mask_2         ; Else if one of the buttons (2) has been pressed
    BNE .increase_counter                       ; Then increase button count
    RTL                                         ; Else don't increase count

.increase_counter
    INC.w !ram_button_presses_count             ; Increase button presses count
    RTL

    ; Affect player by hurting/killing them. We do this only if the game is not
    ; paused to prevent the game from crashing. After affecting the player, we
    ; reset the counter if we need to do so and the player is not dying,
    ; otherwise we increase the counter by one so this routine doesn't trigger
    ; again.
.affect_player:
    LDA $9D : ORA $13D4|!addr : BEQ +           ; If game is paused
    RTL                                         ; Then return

+
if !kill_player == 0
    JSL $00F5B7|!bank                           ; Hurt player
else
    JSL $00F606|!bank                           ; Kill player
endif

if !reset_counter
    LDA $71 : CMP #$09 : BEQ +                  ; If player is not dying
    STZ.w !ram_button_presses_count             ; Then reset counter
    RTL
+
endif

    INC !ram_button_presses_count               ; Increase the counter over the threshold
    RTL


;-------------------------------------------------------------------------------
; Draw Status Bar Indicator
;-------------------------------------------------------------------------------

if !statusbar_visibility > 0

; Draw the indicator in the status bar.
draw_statusbar_indicator:
    %lda_ram_button_presses_count()             ; Number to show = current count
if !statusbar_visibility = 2
    STA $00                                     ; Number to show =
    LDA.b #!button_presses_threshold            ;   threshold
    SEC : SBC $00                               ;   - current count
endif

    LDX #$00                                    ; X counts 100s
-   CMP #$64 : BCC +                            ; While A >= 100
    SBC #$64 : INX                              ; Subtract 100 and increase 100s count
    BRA -                                       ; Repeat
+   PHA : TXA : STA.w !statusbar_100s : PLA     ; Draw 100s.

    LDX #$00                                    ; X counts 10s
-   CMP #$0A : BCC +                            ; While A >= 10
    SBC #$0A : INX                              ; Subtract 10 and increase 10s count
    BRA -                                       ; Repeat
+   PHA : TXA : STA.w !statusbar_10s : PLA      ; Draw 10s.

    STA.w !statusbar_1s                         ; Draw 1s.

    RTS

endif


;-------------------------------------------------------------------------------
; Draw Sprite Indicator
;-------------------------------------------------------------------------------

if !sprite_visibility > 0

; Draw the indicator over Mario's head as a number, up to three digits long.
; The routine makes use of the following scratch RAM:
; - $00: Number to show in the counter.
; - $01: Current digit horizontal offset.
; - $02: Current decimal digit to draw.
draw_sprite_indicator:
    LDA $71 : CMP #$09 : BNE +            ; If player is not dying, then show indicator
    RTS                                   ; Else do nothing (to prevent counter visual glitch)

+   LDY !sprite_oam_index                 ; OAM sprite index

    %lda_ram_button_presses_count()       ; Number to show = current count
    STA $00
if !sprite_visibility = 2
    LDA.b #!button_presses_threshold      ; Number to show = threshold - current count
    SEC : SBC $00 : STA $00
endif

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
    JSR draw_sprite_indicator_digit       ; Draw 100s digit
    LDA $01 : CLC                         ; Increase offset by the specified amount
    ADC.b #!sprite_digit_size : STA $01   ; to draw next digit on the right side
    INY #4                                ; Go to next OAM sprite (every one is 4 bytes)

.digit_10s
    LDA $00 : LDX #$00                    ; A is number to show, X counts 10s
-   CMP #$0A : BCC +                      ; While A >= 10
    SBC #$0A : INX                        ; Subtract 10 and increase 10s count
    BRA -                                 ; Repeat
+   STA $00 : STX $02                     ; Update number to show and set 10s digit
    JSR draw_sprite_indicator_digit       ; Draw 10s digit
    LDA $01 : CLC                         ; Increase offset by the specified amount
    ADC.b #!sprite_digit_size : STA $01   ; to draw next digit on the right side
    INY #4                                ; Go to next OAM sprite (every one is 4 bytes)

.digit_1s
    LDA $00 : STA $02                     ; What's left is the 1s digit
    JSR draw_sprite_indicator_digit       ; Draw 1s digit

.return
    RTS

; Draw a single digit. Effectively, this sets the correct tile in the OAM table.
; @param Y: OAM index.
; @param $01: Digit X offset.
; @param $02: Decimal digit to draw.
draw_sprite_indicator_digit:
    ; X-position
    LDA $7E                               ; A = Player's X position
    CLC : ADC $01                         ; Add digit offset to player's X position
    STA $0200|!addr,y                     ; Save X position to OAM

    ; Y-position
    LDA $80                               ; A = Player's Y position
    LDX $19 : BEQ +                       ; If player is big
    SEC : SBC #$08                        ; Then raise the indicator by half of Mario's size
+   STA $0201|!addr,y                     ; Save Y position to OAM

    ; Tile number
    LDX $02 : LDA sprite_tiles,x          ; GFX tile based on digit
    CLC : ADC.b #!sprite_offset           ; Plus the offset (first or second page)
    STA $0202|!addr,y                     ; Save tile number to OAM

    ; Tile properties
    LDA.b #!sprite_properties             ; No flips, priority 2
    STA $0203|!addr,y                     ; Save tile properties to OAM

    ; Draw tile
    TYA : LSR #2 : TAX                    ; Adjust index for tile size table
    STZ $0420|!addr,x                     ; 8x8 tile

    ; Return
    RTS

endif
