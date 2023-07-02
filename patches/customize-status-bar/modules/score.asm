;===============================================================================
; SCORE
;===============================================================================

; Score indicator in form "XXXXXX0", where X is the score in six digits,
; followed by a hardcoded 0.


;-------------------------------------------------------------------------------
; Methods Definition
;-------------------------------------------------------------------------------

!Score = IsScoreVisible, ShowScore


;-------------------------------------------------------------------------------
; Visibility Checks
;-------------------------------------------------------------------------------

; Check if score is visible.
; @return A (16-bit): #$0000 if score is not visible, #$0001 otherwise.
; @return Z: 1 if score is not visible, 0 otherwise.
IsScoreVisible:
    %check_visibility_simple(!ScoreVisibility, 2, 2)


;-------------------------------------------------------------------------------
; Render
;-------------------------------------------------------------------------------

; Draw score counter on status bar.
; @param A (16-bit): Slot position.
ShowScore:
    ; Backup X/Y, move A into X, and set A (8-bit).
    PHX : PHY : TAX : SEP #$20

    ; Draw last hardcoded zero, before we start incrementing X.
    LDA #$00 : STA $0006,x : PHX

    ; This part draws the three-bytes hexadecimal number as six decimal digits.
    ;   00 00 FF => 000255
    ;   0F 32 4F => 999999
    ; Taken (and slightly adapted) from the original code, I don't really
    ; understand what the formula is for the conversion. I suggest to take a
    ; look at the original code at address $009012.
    ; https://www.smwcentral.net/?p=memorymap&game=smw&region=rom&address=009012&context=
    SEP #$10 : LDA $0DB3 : ASL  ; Load player number * 3 in Y
    CLC : ADC $0DB3 : TAY       ; $00 = Mario, $03 = Luigi
    LDA $0F36,y : STA $00       ; Setup for drawing numbers:
    STZ $01                     ; - $00-$01: High word of subtraend
    LDA $0F35,y : STA $03       ; - $02-$03: Low word of subtraend
    LDA $0F34,y : STA $02       ; Check original code for more info
    REP #$10 : PLX : LDY #$0000 ; Setup indices
.draw_six_digits_number
    SEP #$20
    STZ $0000,x
-   REP #$20
    PHX : TYX ; We need to use X for this because `SBC.l addr,y` doesn't exist
    LDA $02 : SEC : SBC.l TableDigits6L,x : STA $06
    LDA $00 : SBC.l TableDigits6H,x : STA $04
    PLX
    BCC +
    LDA $06 : STA $02
    LDA $04 : STA $00
    SEP #$20 : INC $0000,x
    BRA -
+   INX : INY : INY : INY : INY
    CPY #$0018 : BNE .draw_six_digits_number

    ; Restore X/Y, set A 16-bit, and return.
    REP #$20 : PLY : PLX
    RTS

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
