;===============================================================================
; DRAGON COINS
;===============================================================================

; Dragon coins indicator in form "DDDDD", where each D is a coin, filled or
; empty. The coin is filled if that many coins have been collected, empty
; otherwise. The indicator fills left-to-right.


;-------------------------------------------------------------------------------
; Utilities
;-------------------------------------------------------------------------------

; Check if dragon coins have been collected for a specific level.
; Note that this checks the flag and not the coin count!
; For an explanation on how the check works, see this explanation:
;   https://www.smwcentral.net/?p=memorymap&game=smw&region=ram&address=7E1F2F&context=
; @return Z: 0 if all coins have been collected, 1 otherwise.
are_dragon_coins_collected:
    LDA $13BF|!addr : LSR : LSR : LSR : TAY
    LDA $13BF|!addr : AND #$07 : TAX
    LDA $1F2F|!addr,y : AND $0DA8A6,x
    RTS

; Draw the custom graphics for when all dragon coins are collected.
; $param $00 (8-bit): The amount of collected coins.
; @return C: 1 if the custom graphics have been drawn, 0 otherwise.
draw_dragon_coins_custom_collected_graphics:
    LDA ram_use_custom_dragon_coins_collected_graphics : BEQ +
    LDA $00 : CMP #$05 : BCC +
    LDX #!group_2_tiles_count-1
-   LDA ram_custom_dragon_coins_collected_graphics,x
    TXY : STA (!tile_addr),y
    DEX : BPL -
    SEC : RTS
+   CLC : RTS

; Table listing the custom graphics for the "all coins collected" message.
; This is used when resetting ram_custom_dragon_coins_collected_graphics.
custom_dragon_coins_collected_graphics_table:
    db !custom_dragon_coins_collected_graphics


;-------------------------------------------------------------------------------
; Handler
;-------------------------------------------------------------------------------

; Draw collected dragon coins on status bar.
; @return C: 1 if the indicator has been drawn, 0 otherwise.
dragon_coins:
    %check_visibility(dragon_coins)

.visibility2
    ; Show coins only when not all have been collected (vanilla) - Don't
    ; draw any coin (collected or not) if five have been collected, or if they
    ; have been collected in a previous level attempt. The difference is that
    ; if collected during current attempt ($1422 >= 5) the indicator will be
    ; drawn empty to prevent sudden shifts in the UI, while if the coins have
    ; been collected in a previous attempt (are_dragon_coins_collected -> Z = 0),
    ; then the indicator will not be drawn at all.
    LDA $1422|!addr : STA $00      ; If coins:
    CMP #$05 : BCS .skip           ;   >= 5, then don't draw coins (draw an empty indicator)
    CMP #$00 : BNE .draw           ;   != 0, then draw them
    JSR are_dragon_coins_collected ; If all have been collected in a previous attempt
    BNE .visibility0               ; Then don't show the indicator
    BRA .draw                      ; Else draw coins

.visibility1
    ; Always show coins - Ensure coins are shown even when entering a level
    ; where all coins have been collected, since $1422 = 0 if coins have been
    ; collected in a previous level attempt.
    LDA $1422|!addr : STA $00                  ; By default, show amount of collected coins
    JSR are_dragon_coins_collected : BEQ .draw ; If all coins have been collected
    LDA #$05 : STA $00 : BRA .draw             ; Then show 5 coins as collected

.visibility0
    CLC : RTS

.skip
    ; Draw custom collected graphics if necessary.
    JSR draw_dragon_coins_custom_collected_graphics : BCS .return
    ; Draw empty spaces to erase the indicator.
    LDA #$FC
    LDY #!group_2_tiles_count-1
-   %draw_tile()
    DEY : BPL -
    BRA .return

.draw
    ; Draw custom collected graphics if necessary.
    JSR draw_dragon_coins_custom_collected_graphics : BCS .return
    ; Draw one coin for each collected coin and one empty coin for the rest.
    ; The formula is as follows: #Collected = $00, #NotCollected = #$05 - $00.
    LDX #$00                 ; Dragon coins index
    ; Collected coins (while X < collected).
    LDA ram_dragon_coins_collected_symbol
-   CPX $00 : BCS +
    %draw_tile()
    INX : BRA -
    ; Non-collected coins (while X < 5).
+   LDA ram_dragon_coins_missing_symbol
-   CPX #$05 : BCS .pad
    %draw_tile()
    INX : BRA -
.pad
    ; Draw two empty spaces to fill the slot entirely.
    LDA #$FC : %draw_tile() : %draw_tile()

.return
    SEC : RTS
