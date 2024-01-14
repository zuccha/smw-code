;===============================================================================
; SCORE
;===============================================================================

; Score indicator in form "XXXXXX0", where X is the score in six digits,
; followed by a hardcoded 0.


;-------------------------------------------------------------------------------
; Methods Definition
;-------------------------------------------------------------------------------

!score = handle_score


;-------------------------------------------------------------------------------
; Handler
;-------------------------------------------------------------------------------

; Draw score counter on status bar.
; @return C: 1 if the indicator has been drawn, 0 otherwise.
handle_score:
    %check_visibility(score)

.visibility0
.visibility2
    CLC : RTS

.visibility1
    ; This part draws the three-bytes hexadecimal number as six decimal digits.
    ;   00 00 FF => 000255
    ;   0F 32 4F => 999999
    ; Taken (and slightly adapted) from the original code, I don't really
    ; understand what the formula is for the conversion. I suggest to take a
    ; look at the original code at address $009012.
    ; https://www.smwcentral.net/?p=memorymap&game=smw&region=rom&address=009012&context=
    LDA $0DB3|!addr : ASL           ; Load player number * 3 in Y
    CLC : ADC $0DB3|!addr : TAY     ; $00 = Mario, $03 = Luigi
    LDA $0F36|!addr,y : STA $00     ; Setup for drawing numbers:
    STZ $01                         ; - $00-$01: High word of subtraend
    LDA $0F35|!addr,y : STA $03     ; - $02-$03: Low word of subtraend
    LDA $0F34|!addr,y : STA $02     ; Check original code for more info
    LDX #$00                        ; X iterates something ¯\_(ツ)_/¯
.draw_six_digits_number
    LDA #$00 : STA (!tile_addr)
-   REP #$20
    LDA $02 : SEC : SBC.l six_digits_low_byte_table,x : STA $06
    LDA $00 : SBC.l six_digits_high_byte_table,x : STA $04
    BCC +
    LDA $06 : STA $02
    LDA $04 : STA $00
    SEP #$20
    LDA (!tile_addr) : INC A : STA (!tile_addr)
    BRA -
+   SEP #$20 : INX #4 : INC !tile_addr
    CPX #$18 : BNE .draw_six_digits_number

    ; Draw last hardcoded zero
    LDA #$00 : %draw_tile()

    ; Return
    SEC : RTS

; Tables for computing offset.
six_digits_high_byte_table: dw $0001
six_digits_low_byte_table:  dw $86A0
                            dw $0000
                            dw $2710
                            dw $0000
                            dw $03E8
                            dw $0000
                            dw $0064
                            dw $0000
                            dw $000A
                            dw $0000
                            dw $0001
