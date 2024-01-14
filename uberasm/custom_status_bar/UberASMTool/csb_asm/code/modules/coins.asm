;===============================================================================
; COINS
;===============================================================================

; Coin indicator in form "SHTO", where "S" is the star symbol, "H" is the 100s'
; digit, "T" is the 10s' digit, and "O" is the 1s' digit.


;-------------------------------------------------------------------------------
; Methods Definition
;-------------------------------------------------------------------------------

!coins = handle_coins


;-------------------------------------------------------------------------------
; Handler
;-------------------------------------------------------------------------------

; Handle increasing coins and draw coin counter on status bar.
; @return C: 1 if the indicator has been drawn, 0 otherwise.
handle_coins:
    %check_visibility(coins)

.visibility2
    ; If coin limit is zero, then coins are not visible
    LDA ram_coins_limit : BEQ .visibility0

.visibility1
    JSR check_coins

    ; Draw the coin counter on the status bar.
    LDA $0DBF|!addr
    %draw_3_digits_number_with_symbol(ram_coins_symbol)

    ; Return
    SEC : RTS

.visibility0
    LDA ram_always_check_coins : BEQ +
    JSR check_coins
+   CLC : RTS


;-------------------------------------------------------------------------------
; Check
;-------------------------------------------------------------------------------

; Check amount of coins.
; - If amount > limit && add_life_when_coins_limit_reached == 1
;   -> Then add a life
; - If amount > limit &&  reset_coins_when_coins_limit_reached == 1
;   -> Then remove `limit` coins from amount (remove the coin required to "pay"
;      for the extra life)
;   -> Else set the amount to `limit`, so that it doesn't exceed it
check_coins:
    ; Increase coin count if necessary.
    LDA $13CC|!addr : BEQ + ; If there is a "coin increase"
    DEC $13CC|!addr         ; Then decrease it.
    LDA ram_coins_limit     ; Load coins limit
    CMP $0DBF|!addr : BEQ + ; If coins count != coins limit
    INC $0DBF|!addr         ; Then increase coins count by 1

    ; Skip ahead if coin limit has not been reached.
    LDA ram_coins_limit : CMP $0DBF|!addr : BNE +

    ; Limit reached
    JSR trigger_coins_limit_reached

    ; Add a life if enabled.
    LDA ram_add_life_when_coins_limit_reached : BEQ ++
    INC $18E4|!addr

    ; Reset counter decreasing by limit if enabled.
++  LDA ram_reset_coins_when_coins_limit_reached : BEQ ++
    LDA $0DBF|!addr
    SEC : SBC ram_coins_limit
    STA $0DBF|!addr
    BRA +
    ; Otherwise clamp to limit.
++  LDA ram_coins_limit : STA $0DBF|!addr

    ; Return
+   RTS
