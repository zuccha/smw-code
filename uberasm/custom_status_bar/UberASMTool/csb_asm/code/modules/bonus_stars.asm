;-------------------------------------------------------------------------------
; BONUS STARS
;-------------------------------------------------------------------------------

; Bonus stars indicator in form "SHTO", where "S" is the star symbol, "H" is the
; 100s' digit, "T" is the 10s' digit, and "O" is the 1s' digit.


;-------------------------------------------------------------------------------
; Handler
;-------------------------------------------------------------------------------

; Handle drawing bonus stars counter on status bar.
; @return C: 1 if the indicator has been drawn, 0 otherwise.
bonus_stars:
    %check_visibility(bonus_stars)

.visibility1
    ; Check bonus stars amount and setup bonus game if necessary.
    JSR check_bonus_stars ; X contains the current player (0 = Mario, 1 = Luigi)

    ; Draw bonus stars.
+   LDA $0F48|!addr,x                                         ; Load bonus stars for current player
    %draw_3_digits_number_with_symbol(ram_bonus_stars_symbol) ; and draw them

    ; Return
    SEC : RTS

.visibility0
.visibility2
    LDA ram_always_check_bonus_stars : BEQ + ; If should always check bonus stars
    JSR check_bonus_stars                    ; Then run checks
+   CLC : RTS


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
; @return X: $00 if current player is Mario, $01 if it's Luigi.
check_bonus_stars:
    ; Get bonus stars for current player
    LDX $0DB3|!addr : LDA $0F48|!addr,x

    ; Skip ahead if bonus stars limit has not been reached.
    CMP ram_bonus_stars_limit : BCC +

    ; Limit reached.
    PHX : JSR trigger_bonus_stars_limit_reached : PLX

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
