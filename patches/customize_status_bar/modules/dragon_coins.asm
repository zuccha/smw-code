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

; Check if dragon coins have been collected for a specific level.
; Note that this checks the flag and not the coin count!
; For an explanation on how the check works, see this explanation:
;   https://www.smwcentral.net/?p=memorymap&game=smw&region=ram&address=7E1F2F&context=
; @return Z: 0 if all coins have been collected, 1 otherwise.
AreDragonCoinsCollected:
    SEP #$30
    LDA $13BF : LSR : LSR : LSR : TAY
    LDA $13BF : AND #$07 : TAX
    LDA $1F2F,y : AND $0DA8A6,x
    RTS

; Check if dragon coins are visible when !DragonCoinsVisibility = 2.
; If the dragon coin count is 0 (meaning either all or none have been collected)
; and the "dragon coin collected" flag is present, it means player collected all
; dragon coins in a previous level attempt, so we don't show the indicator. If
; the coins have been collected in the current level attempt (dragon coin count
; is greater than 0), we still render the indicator (empty) to prevent shifts in
; the UI.
; @return A (16-bit): #$0000 if dragon coins are not visible, #$0001 otherwise.
; @return Z: 1 if dragon coins are not visible, 1 otherwise.
macro are_dragon_coins_visible_mode_2()
    PHX : PHY                           ; Save X/Y as they are used by AreDragonCoinsCollected
    SEP #$20 : LDA $1422 : BNE +        ; If coins = 0...
    JSR AreDragonCoinsCollected : BEQ + ; ...and all have been collected
    REP #$30 : LDA #$0000 : BRA ++      ; Then the indicator is not visible
+   REP #$30 : LDA #$0001               ; Else the indicator is visible
++  PLY : PLX : AND #$0001              ; Restore X/Y and the flags matching A
endmacro

; Check if dragon coins are visible.
; @return A (16-bit): #$0000 if dragon coins are not visible, #$0001 otherwise.
; @return Z: 1 if dragon coins are not visible, 0 otherwise.
AreDragonCoinsVisible:
    %check_visibility(!DragonCoinsVisibility, 2, 3, are_dragon_coins_visible_mode_2)


;-------------------------------------------------------------------------------
; Render
;-------------------------------------------------------------------------------

; Draw the custom graphics for when all dragon coins are collected.
; @param Y (16-bit): Slot position
; $param $00 (8-bit): The amount of collected coins.
; @branch .return: If collected coins >= 5.
; @branch +: If collected coins < 5.
macro draw_dragon_coins_custom_collected_graphics()
    if !UseCustomDragonCoinsCollectedGraphics = 1
        LDA $00 : CMP #$05 : BCC + ; Skip if dragon coins are less than 5
        !i #= 0
        while !i < 7
            LDA.l CustomDragonCoinsCollectedGraphicsTable+!i : STA $000!i,y
            !i #= !i+1
        endif
        BRA .return
    endif
endmacro

; Table listing the custom graphics for the "all coins collected" message.
CustomDragonCoinsCollectedGraphicsTable: db !CustomDragonCoinsCollectedGraphics

; Draw collected dragon coins on status bar.
; @param A (16-bit): Slot position.
ShowDragonCoins:
    ; Backup X/Y, push A onto the stack, and set A 8-bit.
    PHX : PHY : PHA : SEP #$30

    ; Level settings.
    if !EnableLevelConfiguration == 1
        %lda_level_byte(Group1VisibilityTable)
        AND #%00000011
        CMP #%00000001 : BEQ .mode1
        CMP #%00000010 : BEQ .mode2
    endif

    ; Global settings.
    if !DragonCoinsVisibility == 2 : BRA .mode2

.mode1
    ; Always show coins - Ensure coins are shown even when entering a level
    ; where all coins have been collected.
    LDA $1422 : STA $00
    JSR AreDragonCoinsCollected : BEQ .draw ; If all coins have been collected
    LDA #$05 : STA $00 : BRA .draw          ; Then show 5 coins as collected

.mode2
    ; Show coins only when not all have been collected (vanilla) - Don't
    ; draw any coin (collected or not) if five have been collected.
    ; Effectively, this makes the coins disappear from the status bar once
    ; the fifth one has been collected during the current level attempt.
    LDA $1422 : STA $00         ; If collected coins:
    CMP #$05 : BCS .skip        ; >= 5 (all collected in current level attempt) then don't draw coins
    LDA $1422 : BNE .draw       ; > 0 (some are collected) then draw coins
    JSR AreDragonCoinsCollected ; All collected in previous level attempt...
    BNE .skip                   ; ...Then don't draw coins
                                ; Else draw coins


.draw
    ; Slot position is on the stack, $00 holds the amount of collected coins.
    REP #$10 : PLY
    ; Draw custom collected graphics if necessary. If draw, this will skip ahead
    ; to .return, otherwise it will continue normally.
    %draw_dragon_coins_custom_collected_graphics()
    ; Draw one coin for each collected coin and one empty coin for the rest.
    ; The formula is as follows: #Collected = $00, #NotCollected = #$05 - $00.
+   LDX #$0000                                       ; Dragon coins index
    ; Collected coins.
-   TXA : CMP $00 : BCS +                            ; If index < collected dragon coins...
    CMP #$05 : BCS .return                           ; ...and index < 5
    LDA.b #!DragonCoinsCollectedSymbol : STA $0000,y ; Then draw a coin
    INX : INY                                        ; Go to next coin and next drawing position
    BRA -
+   ; Non-collected coins.
-   CPX #$0005 : BCS .return                         ; If index < 5
    LDA.b #!DragonCoinsMissingSymbol : STA $0000,y   ; Then draw a missing coin
    INX : INY                                        ; Go to next coin and next drawing position
    BRA -

.skip
    ; The slot position is on the stack.
    REP #$10 : PLY
    ; Draw custom collected graphics if necessary. If draw, this will skip ahead
    ; to .return, otherwise it will continue normally.
    %draw_dragon_coins_custom_collected_graphics()
    ; Draw empty spaces to erase the indicator.
+   LDA.b #$FC
    STA $0000,y : STA $0001,y : STA $0002,y : STA $0003,y
    STA $0004,y : STA $0005,y : STA $0006,y

.return
    ; Restore X/Y, set A 16-bit, and return.
    REP #$20 : PLY : PLX
    RTS
