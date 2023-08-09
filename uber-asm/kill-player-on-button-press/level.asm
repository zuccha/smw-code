;===============================================================================
; KILL PLAYER ON BUTTON PRESS (level)
;===============================================================================

; UberASM that kills the player after a button of your choosing has been pressed
; a given amount of times.

; The button(s), amount of presses, behaviour, and other properties can be
; configured down below.


;-------------------------------------------------------------------------------
; Configuration
;-------------------------------------------------------------------------------

; Number of pressed required to hurt/kill the player.
; Must be a value between 1-255 ($01-$FF). 0 won't do anything, any value above
; 255 ($FF) will crash the game.
!button_presses_threshold = $0A

; Which buttons, when pressed, increase the counter.
; 0 = don't increase the counter, 1 = increase the counter
; If multiple buttons will be pressed simultaneously (in the same frame), the
; counter will be incremented only once.
; For technical reasons, it is not possible to determine if only Y has been
; pressed :(
!button_A      = 1
!button_B      = 0
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
; 0 = hurt, 1 = die
!kill_player = 1

; Determine if the counter should reset after the player has been hurt.
; It should be relevant only if !kill_player = 0 (so that the player can be hurt
; multiple times).
; 0 = don't reset counter, 1 = reset counter
!reset_counter = 1

; Determine if should detect button presses when the game is paused.
; Please note that if this is enabled, the counter in the status bar will only
; be updated once the game is unpaused!
; 0 = don't detect presses if game is paused
; 1 = detect pressed even if game is paused
!increase_counter_if_game_is_paused = 0

; Whether to show the number of presses is the status bar or not.
; 0 = hidden, 1 = visible.
; N.B.: This is relevant only if you are showing the counter in the status bar
; with the custom "status_code.asm" file.
!show_presses_in_status_bar = 0

; 1 byte of free RAM, keeping track of the number of presses (1 byte).
; N.B.: This needs to be the same as the one defined in the status bar's ASM!
!ram_button_presses_count = $140B

; 1 byte of free RAM, determining whether the status bar should display the
; counter or not. You should use an address that resets automatically on level
; load (the default one, $140C, does) or add the following code in game mode 11:
;   STZ.w !ram_show_presses_in_status_bar|!addr
; N.B.: This is relevant only if you are showing the counter in the status bar
; with the custom "status_code.asm" file.
; N.B.: This needs to be the same as the one defined in the status bar's ASM!
!ram_show_presses_in_status_bar = $140C


;-------------------------------------------------------------------------------
; Utilities
;-------------------------------------------------------------------------------

; Format: byetUDLR.
; b = B; y = X or Y; e = select; t = start; U = up; D = down; L = left, R = right.
!controller_mask_1 = (!button_B<<7)|(!button_X_or_Y<<6)|(!button_select<<5)|(!button_start<<4)|(!button_up<<3)|(!button_down<<2)|(!button_left<<1)|!button_right

; Format: axlr----.
; a = A; x = X; l = L; r = R, - = unused.
!controller_mask_2 = (!button_A<<7)|(!button_X<<6)|(!button_L<<5)|(!button_R<<4)


;-------------------------------------------------------------------------------
; Init
;-------------------------------------------------------------------------------

init:
    STZ.w !ram_button_presses_count|!addr       ; Reset counter

    LDA.b #!show_presses_in_status_bar          ; Hide or show the number of
    STA.w !ram_show_presses_in_status_bar|!addr ; presses in the status bar

    RTL


;-------------------------------------------------------------------------------
; Main
;-------------------------------------------------------------------------------

main:
    LDA.w !ram_button_presses_count|!addr       ; If the button has not been
    CMP.b #!button_presses_threshold            ; pressed enough times
    BCC +                                       ; Continue
    RTL                                         ; Else don't count presses

+
if !increase_counter_if_game_is_paused != 1
    LDA $9D : ORA $13D4|!addr                   ; If game is not frozen or paused
    BEQ +                                       ; Then check button presses
    RTL                                         ; Else don't count presses
endif

+   LDA $16 : AND.b #!controller_mask_1         ; If one of the buttons (1) has been pressed
    BNE +                                       ; Then increase button count
    LDA $18 : AND.b #!controller_mask_2         ; Else if one of the buttons (2) has been pressed
    BNE +                                       ; Then increase button count
    RTL                                         ; Else don't increase count

+   INC.w !ram_button_presses_count|!addr       ; Increase button presses count

    LDA.w !ram_button_presses_count|!addr       ; If the button has been pressed
    CMP.b #!button_presses_threshold            ; exactly the required amount
    BEQ +                                       ; Then kill the player
    RTL                                         ; Else don't hurt or kill the player

+

if !kill_player == 0
    JSL $00F5B7|!bank                           ; Hurt player
else
    JSL $00F606|!bank                           ; Kill player
endif

if !reset_counter
    LDA $71 : CMP #$09 : BEQ +                  ; If player is dying, then do nothing
    STZ.w !ram_button_presses_count|!addr       ; Else reset counter
endif

+   RTL
