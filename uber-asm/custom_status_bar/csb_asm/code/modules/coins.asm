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
    SEP #$20 : LDA.b #!coins_limit : BEQ .visibility0

.visibility1
    JSR check_coins

    ; Draw the coin counter on the status bar.
    PLY ; Stack: X, Y <-
    LDA $0DBF|!addr : %draw_3_digits_number_with_symbol(ram_coins_symbol)

    ; Return
    %return_handler_visible()

.visibility0
    if !always_check_coins == 1 : JSR check_coins
    %return_handler_hidden()


;-------------------------------------------------------------------------------
; Check
;-------------------------------------------------------------------------------

; Check amount of coins.
; - If amount > limit && add_life_if_coins_limit_reached == 1
;   -> Then add a life
; - If amount > limit &&  reset_coins_if_coins_limit_reached == 1
;   -> Then remove `limit` coins from amount (remove the coin required to "pay"
;      for the extra life)
;   -> Else set the amount to `limit`, so that it doesn't exceed it
; @return A (8-bit)
check_coins:
    ; Increase coin count if necessary.
    SEP #$20
    LDA $13CC|!addr : BEQ + ; If there is a "coin increase"
    DEC $13CC|!addr         ; Then decrease it.
    LDA.b #!coins_limit     ; Load coins limit
    CMP $0DBF|!addr : BEQ + ; If coins count != coins limit
    INC $0DBF|!addr         ; Then increase coins count by 1

    ; Skip ahead if coin limit has not been reached.
    LDA.b #!coins_limit : CMP $0DBF|!addr : BNE +

    ; Limit reached
    if !add_life_if_coins_limit_reached == 1 : INC $18E4|!addr ; Add life
    if !reset_coins_if_coins_limit_reached == 1
        LDA $0DBF|!addr                         ; Decrease by coins limit
        SEC : SBC.b #!coins_limit
        STA $0DBF|!addr
    else
        LDA.b #!coins_limit : STA $0F48|!addr,x ; Don't exceed limit
    endif

    ; Return
+   RTS
