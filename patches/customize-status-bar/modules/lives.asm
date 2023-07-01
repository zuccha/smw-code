;===============================================================================
; LIVES
;===============================================================================

; Lives indicator in form "S0TU", where S is the life symbol, followed by a
; hardcoded 0, T is the tens, and U is the units.


;-------------------------------------------------------------------------------
; Methods Definition
;-------------------------------------------------------------------------------

!Lives = AreLivesVisible, ShowLives


;-------------------------------------------------------------------------------
; Visibility Checks
;-------------------------------------------------------------------------------

; Set Z flag to 0 if lives are visible, 1 otherwise.
; It expects A 16-bit.
AreLivesVisible:
    %check_visibility_simple(!LivesVisibility, 1, 1)


;-------------------------------------------------------------------------------
; Render
;-------------------------------------------------------------------------------

; Draw lives counter on status bar.
; It expects the address for the position to be in A 16-bit.
ShowLives:
    ; Backup X/Y, move A into Y, and set A 8-bit.
    PHX : PHY : TAY : SEP #$20

    ; Clamp amount of lives.
    LDA $0DBE : BMI +    ; If amount of lives is not negative...
    CMP #$62 : BCC +     ; ...and is greater or equal than 98 ($62)
    LDA #$62 : STA $0DBE ; Set lives to 98

    ; Draw lives.
+   INC A : %draw_counter_with_two_digits(!LivesSymbol)

    ; Restore X/Y, set A 16-bit, and return.
    REP #$20 : PLY : PLX
    RTS
