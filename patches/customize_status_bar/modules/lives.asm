;===============================================================================
; LIVES
;===============================================================================

; Lives indicator in form "S0TU", where S is the life symbol, followed by a
; hardcoded 0, T is the tens, and U is the units.


;-------------------------------------------------------------------------------
; Methods Definition
;-------------------------------------------------------------------------------

!Lives = HandleLives


;-------------------------------------------------------------------------------
; Handler
;-------------------------------------------------------------------------------

; Draw lives counter on status bar.
; @param A (16-bit): Slot position.
; @return A (16-bit): #$0001 if the indicator has been drawn, #$0000 otherwise.
; @return Z: 0 if the indicator has been drawn, 1 otherwise.
HandleLives:
    ; Backup registers and check visibility.
    PHX : PHY : PHA ; Stack: X, Y, Slot <-
    %check_visibility(!LivesVisibility, 1, 1)

.visibility1
    ; Clamp amount of lives.
    SEP #$20 : LDA $0DBE|!addr : BMI + ; If amount of lives is not negative...
    CMP #$62 : BCC +                   ; ...and is greater or equal than 98 ($62)
    LDA #$62 : STA $0DBE|!addr         ; Set lives to 98

    ; Draw lives.
+   PLY ; Stack: X, Y <-
    INC A : %draw_counter_with_two_digits(!LivesSymbol)

    ; Return
    %return_handler_visible()

.visibility0
.visibility2
    %return_handler_hidden()