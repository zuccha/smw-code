;===============================================================================
; TIME
;===============================================================================

; Time indicator in form "SHTU", where S is the coin symbol, H is the hundreds,
; T is the tens, and U is the units.


;-------------------------------------------------------------------------------
; Methods Definition
;-------------------------------------------------------------------------------

; Methods.
!Time = HandleTime


;-------------------------------------------------------------------------------
; Handler
;-------------------------------------------------------------------------------

; Draw time counter on status bar.
; @param A (16-bit): Slot position.
; @return A (16-bit): #$0001 if the indicator has been drawn, #$0000 otherwise.
; @return Z: 0 if the indicator has been drawn, 1 otherwise.
HandleTime:
    ; Backup registers and check visibility.
    PHX : PHY : PHA ; Stack: X, Y, Slot <-
    %check_visibility(!TimeVisibility, 1, 3)

.visibility2
    ; If time is 0, don't draw.
    SEP #$20
    LDA $0F31|!addr : ORA $0F32|!addr : ORA $0F33|!addr
    BEQ .visibility0

.visibility1
    ; Draw time counter on the status bar.
    PLY : SEP #$20                               ; Stack: X, Y <-
    LDA.b #!TimeSymbol : STA $0000|!addr,y : INY ; Symbol
    LDA $0F31|!addr : STA $0000|!addr,y : INY    ; Hundreds
    LDA $0F32|!addr : STA $0000|!addr,y : INY    ; Tens
    LDA $0F33|!addr : STA $0000|!addr,y          ; Units

    ; Return
    %return_handler_visible()

.visibility0
    %return_handler_hidden()
