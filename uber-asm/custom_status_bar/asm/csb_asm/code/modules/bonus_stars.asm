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
    %check_visibility(bonus_stars)

.visibility1
    ; Check bonus stars amount and setup bonus game if necessary.
    JSR check_bonus_stars ; X (8-bit) contains the current player (0 = Mario, 1 = Luigi)

    ; Draw bonus stars.
+   LDA $0F48|!addr,x : REP #$10 : PLY                        ; Load bonus stars for current player
    %draw_3_digits_number_with_symbol(ram_bonus_stars_symbol) ; and draw them

    ; Return
    %return_handler_visible()

.visibility0
.visibility2
    SEP #$20
    LDA ram_always_check_bonus_stars : BEQ + ; If should always check bonus stars
    JSR check_bonus_stars                    ; Then run checks
+   %return_handler_hidden()


;-------------------------------------------------------------------------------
; Check
;-------------------------------------------------------------------------------

; Check amount of bonus stars.
; Logic:
; - If amount > limit && start_bonus_game_when_bonus_stars_limit_reached == 1
;   -> Then start bonus game after the level finishes
; - If amount > limit &&  reset_bonus_stars_when_bonus_stars_limit_reached == 1
;   -> Then remove `limit` bonus stars from amount (remove the stars required to
;      "pay" the entrance to the bonus game)
;   -> Else set the amount to `limit`, so that it doesn't exceed it
; @return A (8-bit)
; @return X/Y (8-bit)
check_bonus_stars:
    SEP #$30

    ; Get bonus stars for current player
    LDX $0DB3|!addr : LDA $0F48|!addr,x

    ; Skip ahead if bonus stars limit has not been reached.
    CMP ram_bonus_stars_limit : BCC +

    ; Limit reached.
    PHX : JSR trigger_bonus_stars_limit_reached : SEP #$20 : REP #$10 : PLX

    ; Start a bonus game if enabled.
    LDA ram_start_bonus_game_when_bonus_stars_limit_reached : BEQ ++
    LDA #$FF : STA $1425|!addr

    ; Reset starts by removing limit if enabled.
++  LDA ram_reset_bonus_stars_when_bonus_stars_limit_reached : BEQ ++
    LDA $0F48|!addr,x
    SEC : SBC ram_bonus_stars_limit
    STA $0F48|!addr,x
    BRA +
    ; Otherwise clamp to limit.
++  LDA ram_bonus_stars_limit
    STA $0F48|!addr,x

    ; Return.
+   RTS
