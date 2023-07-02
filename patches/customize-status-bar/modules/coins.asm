;===============================================================================
; COINS
;===============================================================================

; Coin indicator in form "S0TU", where S is the coin symbol, followed by a
; hardcoded 0, T is the tens, and U is the units.


;-------------------------------------------------------------------------------
; Methods Definition
;-------------------------------------------------------------------------------

!Coins = AreCoinsVisible, ShowCoins


;-------------------------------------------------------------------------------
; Visibility Checks
;-------------------------------------------------------------------------------

; Check if coins are visible when !CoinsVisibility = 2.
; @return A (16-bit): #$0000 if coins are not visible, #$0001 otherwise.
; @return Z: 1 if coins are not visible, 1 otherwise.
macro are_coins_visible_mode_2()
    %lda_coins_limit() : CMP #$00 : BEQ + ; If coin limit is not zero
    REP #$20 : LDA #$0001 : BRA ++        ; Then return 1
+   REP #$20 : LDA #$0000                 ; Else return 0
++
endmacro

; Check if coins are visible.
; @return A (16-bit): #$0000 if coins are not visible, #$0001 otherwise.
; @return Z: 1 if coins are not visible, 0 otherwise.
AreCoinsVisible:
    %check_visibility(!CoinsVisibility, 1, 0, are_coins_visible_mode_2)


;-------------------------------------------------------------------------------
; Render
;-------------------------------------------------------------------------------

; Handle increasing coins and draw coin counter on status bar.
; @param A (16-bit): Slot position.
ShowCoins:
    ; Backup X/Y, move A into Y, and set A 8-bit.
    PHX : PHY : TAY : SEP #$20

    ; Increase coin count if necessary.
    LDA $13CC|!addr : BEQ +         ; If there is a "coin increase"
    DEC $13CC|!addr                 ; Then decrease it.
    %lda_coins_limit() : STA $00    ; If the limit of coins...
    DEC A : CMP $0DBF|!addr : BCC + ; ...has not been reached yet
    INC $0DBF|!addr                 ; Then increase coin count by 1

    ; Skip ahead if coin limit has not been reached.
    LDA $00 : CMP $0DBF|!addr : BNE +

    ; Limit reached, add life and reset counter if necessary.
    if !AddLifeIfCoinLimitReached : INC $18E4
    if !ResetCoinsIfCoinLimitReached : LDA $0DBF : SEC : SBC $00 : STA $0DBF

    ; Draw the coin counter on the status bar.
+   LDA $0DBF|!addr : %draw_counter_with_two_digits(!CoinsSymbol)

    ; Restore X/Y, set A 16-bit, and return.
    REP #$20 : PLY : PLX
    RTS
