;===============================================================================
; SPEED METER
;===============================================================================

; Speed meter, showing the speed progress towards p-speed.


;-------------------------------------------------------------------------------
; Handler
;-------------------------------------------------------------------------------

; Draw speed meter on status bar.
; @return C: 1 if the indicator has been drawn, 0 otherwise.
speed_meter:
    %check_visibility(speed_meter)

.visibility0
.visibility2
    CLC : RTS

.visibility1
    LDA $13E4|!addr : LSR #4 : STA $00  ; p-speed meter divided by $10 is the number of full indicators
    LDA #$07 : SEC : SBC $00 : STA $01  ; #$07-$00 is the number of empty indicators

.draw_empty_indicators
    LDX $00 : BEQ .draw_full_indicators ; If zero, draw no full indicator
    LDA ram_speed_meter_full_symbol     ; Else, draw full indicators
-   %draw_tile()
    DEX : BNE -

.draw_full_indicators
    LDX $01 : BEQ .return               ; If zero, draw no empty indicator
    LDA ram_speed_meter_empty_symbol    ; Else, draw empty indicators
-   %draw_tile()
    DEX : BNE -

.return
    SEC : RTS
