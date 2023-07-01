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

; AreCoinsVisible if visibility is set to 2.
macro is_time_visible_mode_2()
    LDA #$0000 : SEP #$20
    LDA $0F31|!addr : ORA $0F32|!addr : ORA $0F33|!addr
    REP #$20
endmacro

; Set Z flag to 0 if time is visible, 1 otherwise.
; It expects A 16-bit.
IsTimeVisible:
    %check_visibility(!TimeVisibility, 1, 3, is_time_visible_mode_2)


;-------------------------------------------------------------------------------
; Render
;-------------------------------------------------------------------------------

; Draw time counter on status bar.
; It expects the address for the position to be in A 16-bit.
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
