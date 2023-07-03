;===============================================================================
; COINS
;===============================================================================

; Coin indicator in form "S0TU", where S is the coin symbol, followed by a
; hardcoded 0, T is the tens, and U is the units.


;-------------------------------------------------------------------------------
; Methods Definition
;-------------------------------------------------------------------------------

!Coins = HandleCoins


;-------------------------------------------------------------------------------
; Handler
;-------------------------------------------------------------------------------

; Handle increasing coins and draw coin counter on status bar.
; @param A (16-bit): Slot position.
; @return A (16-bit): #$0001 if the indicator has been drawn, #$0000 otherwise.
; @return Z: 0 if the indicator has been drawn, 1 otherwise.
HandleCoins:
    ; Backup registers and check visibility.
    PHX : PHY : PHA ; Stack: X, Y, Slot <-
    %check_visibility(!CoinsVisibility, 1, 0)

.visibility2
    ; If coin limit is zero, then coins are not visible
    SEP #$20 : LDA.b #!CoinsLimit : BEQ .visibility0

.visibility1
    JSR CheckCoins

    ; Draw the coin counter on the status bar.
    PLY ; Stack: X, Y <-
    LDA $0DBF|!addr : %draw_3_digits_number_with_symbol(!CoinsSymbol)

    ; Return
    %return_handler_visible()

.visibility0
    if !AlwaysCheckCoins == 1 : JSR CheckCoins
    %return_handler_hidden()

CheckCoins:
    ; Increase coin count if necessary.
    SEP #$20
    LDA $13CC|!addr : BEQ + ; If there is a "coin increase"
    DEC $13CC|!addr         ; Then decrease it.
    LDA.b #!CoinsLimit      ; Load coins limit
    CMP $0DBF|!addr : BEQ + ; If coins count != coins limit
    INC $0DBF|!addr         ; Then increase coins count by 1

    ; Skip ahead if coin limit has not been reached.
    LDA.b #!CoinsLimit : CMP $0DBF|!addr : BNE +

    ; Limit reached
    if !AddLifeIfCoinsLimitReached : INC $18E4|!addr ; Add life
    if !ResetCoinsIfCoinsLimitReached
        LDA $0DBF|!addr                              ; Decrease by coins limit
        SEC : SBC.b #!CoinsLimit
        STA $0DBF|!addr
    else
        LDA.b #!CoinsLimit : STA $0F48|!addr,x       ; Don't exceed limit
    endif

    ; Return
+   RTS
