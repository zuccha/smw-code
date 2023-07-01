;===============================================================================
; DRAGON COINS
;===============================================================================

; Dragon coins indicator in form "DDDDD", where each D is a coin, filled or
; empty. The coin is filled if that many coins have been collected, empty
; otherwise. The indicator fills left-to-right.


;-------------------------------------------------------------------------------
; Methods Definition
;-------------------------------------------------------------------------------

!DragonCoins = AreDragonCoinsVisible, ShowDragonCoins


;-------------------------------------------------------------------------------
; Visibility Checks
;-------------------------------------------------------------------------------

; Set Z flag to 0 if all dragon coins are collected, to 1 otherwise.
; See https://www.smwcentral.net/?p=memorymap&game=smw&region=ram&address=7E1F2F&context=)
macro are_dragon_coins_collected()
    SEP #$30
    LDA $13BF : LSR : LSR : LSR : TAY
    LDA $13BF : AND #$07 : TAX
    LDA $1F2F,y : AND $0DA8A6,x
endmacro

; Dragon coins slot is always visible in mode 2, simply put, the coins are not
; shown on screen if all have been collected (handled by ShowDragonCoins).
macro are_dragon_coins_visible_mode_2()
    LDA #$0001
endmacro

; Set Z flag to 0 if dragon coins are visible, 1 otherwise.
; It expects A 16-bit.
AreDragonCoinsVisible:
    %check_visibility(!DragonCoinsVisibility, 2, 3, are_dragon_coins_visible_mode_2)


;-------------------------------------------------------------------------------
; Render
;-------------------------------------------------------------------------------

; Draw collected dragon coins on status bar.
; It expects the address for the position to be in A 16-bit.
ShowDragonCoins:
    ; Backup X/Y, push A onto the stack, and set A 8-bit.
    PHX : PHY : PHA : SEP #$30

    ; Determine how many coins to draw. $1422, the amount collected during
    ; the level (0 if all are collected when level starts). We store the amount
    ; of coins to display in $00.
    if !DragonCoinsVisibility == 1
        ; Always show coins - Ensure coins are show even when entering a level
        ; where all coins have been collected.
        LDA $1422 : STA $00
        %are_dragon_coins_collected() : BEQ .draw ; If all coins have been collected
        LDA #$05 : STA $00                        ; Then show 5 coins as collected
    elseif !DragonCoinsVisibility == 2
        ; Show coins only when not all have been collected (vanilla) - Don't
        ; draw any coin (collected or not) if five have been collected.
        ; Effectively, this makes the coins disappear from the status bar once
        ; the fifth one has been collected during the current level attempt.
        LDA $1422 : STA $00           ; If collected coins:
        CMP #$05 : BCS .skip          ; >= 5 (all collected in current level attempt): don't draw coins
        LDA $1422 : BNE .draw         ; > 0 (some are collected): draw coins (useful to prevent table check)
        %are_dragon_coins_collected() ; all collected in previous level attempt...
        BNE .skip                     ; ...don't draw coins
                                      ; else: draw coins
    endif

    ; Draw one coin for each collected coin and one empty coin for the rest.
    ; The formula is as follows: #Collected = $00, #NotCollected = #$05 - $00.
.draw
    REP #$10 : PLY : LDX #$0000                      ; Dragon coin index
    ; Collected coins.
-   TXA : CMP $00 : BCS +                            ; If index < collected dragon coins...
    CMP #$05 : BCS +                                 ; ...and index < 5
    LDA.b #!DragonCoinsCollectedSymbol : STA $0000,y ; Then draw a coin
    INX : INY                                        ; Go to next coin and next drawing position
    BRA -
+   ; Non-collected coins.
-   CMP #$05 : BCS .return                           ; If index < 5
    LDA.b #!DragonCoinsMissingSymbol : STA $0000,y   ; Then draw a missing coin
    INX : INY                                        ; Go to next coin and next drawing position
    BRA -

    ; Draw five empty spaces (to make sure that we overwrite any previous
    ; drawing of the coins).
.skip
    REP #$10 : PLY : LDA.b #$FC
    STA $0000,y : STA $0001,y : STA $0002,y : STA $0003,y : STA $0004,y

    ; Restore X/Y, set A 16-bit, and return.
.return
    REP #$20 : PLY : PLX
    RTS
