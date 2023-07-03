;===============================================================================
; SCORE
;===============================================================================

; Score indicator in form "XXXXXX0", where X is the score in six digits,
; followed by a hardcoded 0.


;-------------------------------------------------------------------------------
; Methods Definition
;-------------------------------------------------------------------------------

!Score = HandleScore


;-------------------------------------------------------------------------------
; Handler
;-------------------------------------------------------------------------------

; Draw score counter on status bar.
; @param A (16-bit): Slot position.
; @return A (16-bit): #$0001 if the indicator has been drawn, #$0000 otherwise.
; @return Z: 0 if the indicator has been drawn, 1 otherwise.
HandleScore:
    ; Backup registers and check visibility.
    PHX : PHY : PHA ; Stack: X, Y, Slot <-
    %check_visibility(!ScoreVisibility, 2, 2)

.visibility0
.visibility2
    %return_handler_hidden()

.visibility1
    ; Draw last hardcoded zero, before we start incrementing X.
    PLX : SEP #$20 : LDA #$00 : STA $0006|!addr,x : PHX ; Stack: X, Y, Slot <-

    ; This part draws the three-bytes hexadecimal number as six decimal digits.
    ;   00 00 FF => 000255
    ;   0F 32 4F => 999999
    ; Taken (and slightly adapted) from the original code, I don't really
    ; understand what the formula is for the conversion. I suggest to take a
    ; look at the original code at address $009012.
    ; https://www.smwcentral.net/?p=memorymap&game=smw&region=rom&address=009012&context=
    SEP #$10 : LDA $0DB3|!addr : ASL ; Load player number * 3 in Y
    CLC : ADC $0DB3|!addr : TAY      ; $00 = Mario, $03 = Luigi
    LDA $0F36|!addr,y : STA !T0      ; Setup for drawing numbers:
    STZ !T1                          ; - $00-$01: High word of subtraend
    LDA $0F35|!addr,y : STA !T3      ; - $02-$03: Low word of subtraend
    LDA $0F34|!addr,y : STA !T2      ; Check original code for more info
    REP #$10 : PLX : LDY #$0000      ; Setup indices, Stack: X, Y <-
.draw_six_digits_number
    SEP #$20
    STZ $0000|!addr,x
-   REP #$20
    PHX : TYX ; We need to use X for this because `SBC.l addr,y` doesn't exist
    LDA !T2 : SEC : SBC.l TableDigits6L,x : STA !T6
    LDA !T0 : SBC.l TableDigits6H,x : STA !T4
    PLX
    BCC +
    LDA !T6 : STA !T2
    LDA !T4 : STA !T0
    SEP #$20 : INC $0000|!addr,x
    BRA -
+   INX : INY : INY : INY : INY
    CPY #$0018 : BNE .draw_six_digits_number

    ; Return
    %return_handler_visible()

TableDigits6H: dw $0001
TableDigits6L: dw $86A0
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
