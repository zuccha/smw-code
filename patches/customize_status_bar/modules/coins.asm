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
; Utils
;-------------------------------------------------------------------------------

; Load the coins' limit for a given level (or global if level configuration is
; disabled) into A (8-bit).
; @return A (8-bit): Coins limit.
macro lda_coins_limit()
    if !EnableLevelConfiguration == 1
        %lda_level_byte(CoinsLimitTable)
    else
        LDA #!CoinsLimit
    endif
endmacro


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
    SEP #$20 : %lda_coins_limit() : BEQ .visibility0

.visibility1
    ; Increase coin count if necessary.
    SEP #$20
    LDA $13CC|!addr : BEQ +      ; If there is a "coin increase"
    DEC $13CC|!addr              ; Then decrease it.
    %lda_coins_limit() : STA !T0 ; Load coins limit
    CMP $0DBF|!addr : BEQ +      ; If coins count != coins limit
    INC $0DBF|!addr              ; Then increase coins count by 1

    ; Skip ahead if coin limit has not been reached.
    LDA !T0 : CMP $0DBF|!addr : BNE +

    ; Limit reached, add life and reset counter if necessary.
    if !AddLifeIfCoinsLimitReached : INC $18E4|!addr
    if !ResetCoinsIfCoinsLimitReached : LDA $0DBF|!addr : SEC : SBC !T0 : STA $0DBF|!addr

    ; Draw the coin counter on the status bar.
+   PLY ; Stack: X, Y <-
    LDA $0DBF|!addr : %draw_counter_with_two_digits(!CoinsSymbol)

    ; Return
    %return_handler_visible()

.visibility0
    %return_handler_hidden()
