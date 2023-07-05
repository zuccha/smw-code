;===============================================================================
; COINS
;===============================================================================

; Coin indicator in form "S0TU", where S is the coin symbol, followed by a
; hardcoded 0, T is the tens, and U is the units.


;-------------------------------------------------------------------------------
; Methods Definition
;-------------------------------------------------------------------------------

!coins = handle_coins


;-------------------------------------------------------------------------------
; Handler
;-------------------------------------------------------------------------------

; Handle increasing coins and draw coin counter on status bar.
; @param A (16-bit): Slot position.
; @return A (16-bit): #$0001 if the indicator has been drawn, #$0000 otherwise.
; @return Z: 0 if the indicator has been drawn, 1 otherwise.
handle_coins:
    ; Backup registers and check visibility.
    PHX : PHY : PHA ; Stack: X, Y, Slot <-
    %check_visibility(coins)

.visibility2
    ; If coin limit is zero, then coins are not visible
    SEP #$20 : LDA ram_coins_limit : BEQ .visibility0

.visibility1
    JSR check_coins

    ; Draw the coin counter on the status bar.
    PLY ; Stack: X, Y <-
    LDA $0DBF|!addr : %draw_3_digits_number_with_symbol(ram_coins_symbol)

    ; Return
    %return_handler_visible()

.visibility0
    LDA ram_always_check_coins : BEQ +
    JSR check_coins
+   %return_handler_hidden()


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
; @return A (8-bit)
check_coins:
    ; Increase coin count if necessary.
    SEP #$20
    LDA $13CC|!addr : BEQ + ; If there is a "coin increase"
    DEC $13CC|!addr         ; Then decrease it.
    LDA ram_coins_limit     ; Load coins limit
    CMP $0DBF|!addr : BEQ + ; If coins count != coins limit
    INC $0DBF|!addr         ; Then increase coins count by 1

    ; Skip ahead if coin limit has not been reached.
    LDA ram_coins_limit : CMP $0DBF|!addr : BNE +

    ; Limit reached
    JSR trigger_coins_limit_reached : SEP #$20 : REP #$10

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
