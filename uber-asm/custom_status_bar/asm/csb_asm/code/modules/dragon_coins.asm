;===============================================================================
; DRAGON COINS
;===============================================================================

; Dragon coins indicator in form "DDDDD", where each D is a coin, filled or
; empty. The coin is filled if that many coins have been collected, empty
; otherwise. The indicator fills left-to-right.


;-------------------------------------------------------------------------------
; Methods Definition
;-------------------------------------------------------------------------------

!dragon_coins = handle_dragon_coins


;-------------------------------------------------------------------------------
; Utilities
;-------------------------------------------------------------------------------

; Check if dragon coins have been collected for a specific level.
; Note that this checks the flag and not the coin count!
; For an explanation on how the check works, see this explanation:
;   https://www.smwcentral.net/?p=memorymap&game=smw&region=ram&address=7E1F2F&context=
; @return Z: 0 if all coins have been collected, 1 otherwise.
are_dragon_coins_collected:
    SEP #$10
    LDA $13BF|!addr : LSR : LSR : LSR : TAY
    LDA $13BF|!addr : AND #$07 : TAX
    LDA $1F2F|!addr,y : AND $0DA8A6,x
    REP #$10
    RTS

; Draw the custom graphics for when all dragon coins are collected.
; @param Y (16-bit): Slot position
; $param !T0 (8-bit): The amount of collected coins.
; @return Z: 0 if the custom graphics have been drawn, 1 otherwise.
draw_dragon_coins_custom_collected_graphics:
    LDA ram_use_custom_dragon_coins_collected_graphics : BEQ +
    LDA !T0 : CMP #$05 : BCC +
    !i #= 0
    while !i < 7
        LDA ram_custom_dragon_coins_collected_graphics+!i : STA.w $!i,y
        !i #= !i+1
    endif
    LDA #$01 : RTS
+   LDA #$00 : RTS

; Table listing the custom graphics for the "all coins collected" message.
; This is used when resetting ram_custom_dragon_coins_collected_graphics.
custom_dragon_coins_collected_graphics_table:
    db !custom_dragon_coins_collected_graphics


;-------------------------------------------------------------------------------
; Handler
;-------------------------------------------------------------------------------

; Draw collected dragon coins on status bar.
; @param A (16-bit): Slot position.
; @return A (16-bit): #$0001 if the indicator has been drawn, #$0000 otherwise.
; @return Z: 0 if the indicator has been drawn, 1 otherwise.
handle_dragon_coins:
    ; Backup registers and check visibility.
    PHX : PHY : PHA ; Stack: X, Y, Slot
    %check_visibility(dragon_coins)

.visibility2
    ; Show coins only when not all have been collected (vanilla) - Don't
    ; draw any coin (collected or not) if five have been collected, or if they
    ; have been collected in a previous level attempt. The difference is that
    ; if collected during current attempt ($1422 >= 5) the indicator will be
    ; drawn empty to prevent sudden shifts in the UI, while if the coins have
    ; been collected in a previous attempt (are_dragon_coins_collected -> Z = 0),
    ; then the indicator will not be drawn at all.
    SEP #$20
    LDA $1422|!addr : STA !T0      ; If coins:
    CMP #$05 : BCS .skip           ;   >= 5, then don't draw coins (draw an empty indicator)
    CMP #$00 : BNE .draw           ;   != 0, then draw them
    JSR are_dragon_coins_collected ; If all have been collected in a previous attempt
    BNE .visibility0               ; Then don't show the indicator
    BRA .draw                      ; Else draw coins

.visibility1
    ; Always show coins - Ensure coins are shown even when entering a level
    ; where all coins have been collected, since $1422 = 0 if coins have been
    ; collected in a previous level attempt.
    SEP #$20 : LDA $1422|!addr : STA !T0       ; By default, show amount of collected coins
    JSR are_dragon_coins_collected : BEQ .draw ; If all coins have been collected
    LDA #$05 : STA !T0 : BRA .draw             ; Then show 5 coins as collected

.visibility0
    %return_handler_hidden()

.skip
    ; The slot position is on the stack.
    PLY
    ; Draw custom collected graphics if necessary.
    JSR draw_dragon_coins_custom_collected_graphics : BNE .return
    ; Draw empty spaces to erase the indicator.
    LDA.b #$FC
    !i #= 0
    while !i < 7
        STA $000!i|!addr,y
        !i #= !i+1
    endif
    BRA .return

.draw
    ; Slot position is on the stack, !T0 holds the amount of collected coins.
    PLY
    ; Draw custom collected graphics if necessary.
    JSR draw_dragon_coins_custom_collected_graphics : BNE .return
    ; Draw one coin for each collected coin and one empty coin for the rest.
    ; The formula is as follows: #Collected = $00, #NotCollected = #$05 - $00.
    LDX #$0000               ; Dragon coins index
    ; Collected coins.
-   TXA : CMP !T0 : BCS +    ; If index < collected dragon coins...
    CMP #$05 : BCS .pad   ; ...and index < 5
    LDA ram_dragon_coins_collected_symbol
    STA $0000|!addr,y        ; Then draw a coin
    INX : INY                ; Go to next coin and next drawing position
    BRA -
+   ; Non-collected coins.
-   CPX #$0005 : BCS .pad ; If index < 5
    LDA ram_dragon_coins_missing_symbol
    STA $0000|!addr,y        ; Then draw a missing coin
    INX : INY                ; Go to next coin and next drawing position
    BRA -
.pad
    ; Draw two empty spaces to fill the slot entirely.
    LDA #$FC : STA $0005|!addr,y : STA $0006|!addr,y

.return
    %return_handler_visible()
