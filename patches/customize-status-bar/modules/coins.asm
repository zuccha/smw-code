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

; AreCoinsVisible if visibility is set to 2.
macro are_coins_visible_mode_2()
    %lda_level_byte(CoinLimitTable) : CMP #$00 : BEQ + ; If coin limit is not zero
    REP #$20 : LDA #$0001 : BRA ++                     ; Then return 1
+   REP #$20 : LDA #$0000                              ; Else return 0
++
endmacro

; Set Z flag to 0 if coins are visible, 1 otherwise.
; It expects A 16-bit. 11 00 00 00
AreCoinsVisible:
    %check_visibility(!CoinsVisibility, 1, 0, are_coins_visible_mode_2)


;-------------------------------------------------------------------------------
; Render
;-------------------------------------------------------------------------------

; Handle increasing coins and draw coin counter on status bar.
; It expects the address for the position to be in A 16-bit.
ShowCoins:
    ; Backup X/Y, move A into Y, and set A 8-bit.
    PHX : PHY : TAY : SEP #$20

    ; Increase coin count if necessary.
    LDA $13CC|!addr : BEQ +                   ; If there is a "coin increase"
    DEC $13CC|!addr                           ; Then decrease it.
    %lda_level_byte(CoinLimitTable) : STA $00 ; If the limit of coins...
    DEC A : CMP $0DBF|!addr : BCC +           ; ...has not been reached yet
    INC $0DBF|!addr                           ; Then increase coin count by 1.

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
