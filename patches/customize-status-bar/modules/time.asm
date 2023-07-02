;===============================================================================
; TIME
;===============================================================================

; Time indicator in form "SHTU", where S is the coin symbol, H is the hundreds,
; T is the tens, and U is the units.


;-------------------------------------------------------------------------------
; Methods Definition
;-------------------------------------------------------------------------------

; Methods.
!Time = IsTimeVisible, ShowTime


;-------------------------------------------------------------------------------
; Visibility Checks
;-------------------------------------------------------------------------------

; Check if time is visible. If any of the three time digits (hundreds, tens, and
; units) is greater than zero, then it is visible.
; @return A (16-bit): #$0000 if time is not visible, #$0001 otherwise.
macro is_time_visible_mode_2()
    LDA #$0000 : SEP #$20
    LDA $0F31|!addr : ORA $0F32|!addr : ORA $0F33|!addr
    REP #$20
endmacro

; Check if time is visible.
; @param A (16-bit): Slot position.
; @return A (16-bit): #$0000 if time is not visible, #$0001 otherwise.
; @return Z: 1 if time is not visible, 0 otherwise.
IsTimeVisible:
    %check_visibility(!TimeVisibility, 1, 3, is_time_visible_mode_2)


;-------------------------------------------------------------------------------
; Render
;-------------------------------------------------------------------------------

; Draw time counter on status bar.
; @param A (16-bit): Slot position.
ShowTime:
    ; Backup X/Y, move A into Y, and set A 8-bit
    PHX : PHY : TAY : SEP #$20

    ; Draw time counter on the status bar.
    LDA.b #!TimeSymbol : STA $0000,y : INY ; Symbol
    LDA $0F31|!addr : STA $0000,y : INY    ; Hundreds
    LDA $0F32|!addr : STA $0000,y : INY    ; Tens
    LDA $0F33|!addr : STA $0000,y          ; Units

    ; Restore X/Y, set A 16-bit, and return
    REP #$20 : PLY : PLX
    RTS
