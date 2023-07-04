;-------------------------------------------------------------------------------
; BONUS STARS
;-------------------------------------------------------------------------------

; Bonus stars indicator in form "S0TU", where S is the star symbol, followed by
; a hardcoded 0, T is the tens, and U is the units.


;-------------------------------------------------------------------------------
; Methods Definition
;-------------------------------------------------------------------------------

!bonus_stars = handle_bonus_stars


;-------------------------------------------------------------------------------
; Handler
;-------------------------------------------------------------------------------

; Handle drawing bonus stars counter on status bar.
; @param A (16-bit): Slot position.
; @return A (16-bit): #$0001 if the indicator has been drawn, #$0000 otherwise.
; @return Z: 0 if the indicator has been drawn, 1 otherwise.
handle_bonus_stars:
    ; Backup registers and check visibility.
    PHX : PHY : PHA ; Stack: X, Y, Slot <-
    %check_visibility(!bonus_stars_visibility, 1, 2)

.visibility1
    ; Check bonus stars amount and setup bonus game if necessary.
    JSR check_bonus_stars ; X (8-bit) contains the current player (0 = Mario, 1 = Luigi)

    ; Draw bonus stars.
+   LDA $0F48|!addr,x : REP #$10 : PLY                     ; Load bonus stars for current player
    %draw_3_digits_number_with_symbol(!bonus_stars_symbol) ; and draw them

    ; Return
    %return_handler_visible()

.visibility0
.visibility2
    if !always_check_bonus_stars == 1 : JSR check_bonus_stars
    %return_handler_hidden()


;-------------------------------------------------------------------------------
; Check
;-------------------------------------------------------------------------------

; Check amount of bonus stars.
; Logic:
; - If amount > limit && start_bonus_game_if_bonus_stars_limit_reached == 1
;   -> Then start bonus game after the level finishes
; - If amount > limit &&  reset_bonus_stars_if_bonus_stars_limit_reached == 1
;   -> Then remove `limit` bonus stars from amount (remove the stars required to
;      "pay" the entrance to the bonus game)
;   -> Else set the amount to `limit`, so that it doesn't exceed it
; @return A (8-bit)
; @return X/Y (8-bit)
check_bonus_stars:
    SEP #$30
    LDX $0DB3|!addr : LDA $0F48|!addr,x ; Get bonus stars for current player
    CMP.b #!bonus_stars_limit : BCC +   ; If they are greater or equal than !bonus_stars_limit...
    if !start_bonus_game_if_bonus_stars_limit_reached == 1
        LDA #$FF : STA $1425|!addr      ; Then start bonus game when level ends, and...
    endif
    if !reset_bonus_stars_if_bonus_stars_limit_reached == 1
        LDA $0F48|!addr,x               ; ...subtract !bonus_stars_limit stars
        SEC : SBC.b #!bonus_stars_limit
        STA $0F48|!addr,x
    else
        LDA.b #!bonus_stars_limit       ; ...prevent value from exceeding limit
        STA $0F48|!addr,x
    endif
+   RTS
