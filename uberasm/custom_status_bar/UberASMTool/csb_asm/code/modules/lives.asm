;===============================================================================
; LIVES
;===============================================================================

; Lives indicator in form "SHTO", where "S" is the star symbol, "H" is the 100s'
; digit, "T" is the 10s' digit, and "O" is the 1s' digit.


;-------------------------------------------------------------------------------
; Methods Definition
;-------------------------------------------------------------------------------

!lives = handle_lives


;-------------------------------------------------------------------------------
; Handler
;-------------------------------------------------------------------------------

; Draw lives counter on status bar.
; @param A (16-bit): Slot position.
; @return C: 1 if the indicator has been drawn, 0 otherwise.
handle_lives:
    %check_visibility(lives)

.visibility1
    ; Clamp amount of lives.
    LDA $0DBE|!addr : BMI +     ; If amount of lives is not negative...
    CMP #$62 : BCC +            ; ...and is greater or equal than 98 ($62)
    LDA #$62 : STA $0DBE|!addr  ; Set lives to 98

    ; Draw lives.
+   INC A : %draw_3_digits_number_with_symbol(ram_lives_symbol)

    ; Return
    SEC : RTS

.visibility0
.visibility2
    CLC : RTS
