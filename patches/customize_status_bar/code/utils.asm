;===============================================================================
; UTILS
;===============================================================================

; Define utility routines and macros for the main routines.


;-------------------------------------------------------------------------------
; Scratch RAM
;-------------------------------------------------------------------------------

!T0 = $00|!addr
!T1 = $01|!addr
!T2 = $02|!addr
!T3 = $03|!addr
!T4 = $04|!addr
!T5 = $05|!addr
!T6 = $06|!addr
!T7 = $07|!addr


;-------------------------------------------------------------------------------
; Hex To Dec
;-------------------------------------------------------------------------------

; Convert hexadecimal number to decimal.
; The tens' digit is stored in X, the units' digit is stored in A.
; @param A (8-bit): The hexadecimal number to be converted.
; @return A (8-bit): The low digit of the decimal number.
; @return X: The high digit of the decimal number.
HexToDec:
    LDX #$0000       ; X counts the tens
-   CMP #$0A : BCC + ; If A > $0A (10)...
    SBC #$0A : INX   ; ...A -= $0A (-= 10), X += 1
    BRA -            ; Repeat
+   RTL


;-------------------------------------------------------------------------------
; Check Visibility
;-------------------------------------------------------------------------------

; Check visibility flags for an element that supports values 0 and 1.
; This will retrieve the level's setting first (if level settings are enabled)
; and check on that. If the level setting is 11, it falls back to the global
; setting. Depending on the setting's value, the macro will jump to different
; labels.
; @param <global_setting>: The global setting to use for the current element.
; @param <group>: Group number for the element (bonus stars, coins, lives, and
; time are in group 1; power up, dragon coins, and score are in group 2).
; @param <position>: A value between 0 and 3, referencing the position in the
; byte %AABBCCDD in the element's visibility table, where 0 points to A, 1 to B,
; 2 to C, and 3 to D.
; @branch .visibility0: Jump here if the setting is not 1 or 2.
; @branch .visibility1: Jump here if the setting = 1.
; @branch .visibility2: Jump here if the setting = 2.
; Examples:
; - %check_visibility(!BonusStarsVisibility, 1, 2)
; - %check_visibility(!PowerUpVisibility, 2, 1)
macro check_visibility(global_setting, group, position)
    if !EnableLevelConfiguration == 1
        SEP #$20 : %lda_level_byte(Group<group>VisibilityTable)
        AND #%11000000>>(<position>*2) : BEQ .visibility0
        CMP #%01000000>>(<position>*2) : BEQ .visibility1
        CMP #%10000000>>(<position>*2) : BEQ .visibility2
    endif

    if <global_setting> == 2
        BRA .visibility2
    elseif <global_setting> == 1
        BRA .visibility1
    else
        BRA .visibility0
    endif
endmacro


;-------------------------------------------------------------------------------
; Draw Counter With Two Digits
;-------------------------------------------------------------------------------

; Draw a hexadecimal number lower than $64 (100) as a two-digits decimal number.
; The number will be drawn in format "S0TU", where "S" is the symbol, "0" is a
; harcoded 0, "T" is the tens' digit, and "U" is the units' digit.
; @param A (8-bit): The hexadecimal number.
; @param Y (16-bit): Slot position.
; @param <symbol>: Symbol to display before the number.
macro draw_counter_with_two_digits(symbol)
    JSL.l HexToDec                      ; Get decimal value
    STA $0003|!addr,y                   ; Units
    TXA : STA $0002|!addr,y             ; Tens
    LDA #$00 : STA $0001|!addr,y        ; Hundreds, hardcoded
    LDA.b #<symbol> : STA $0000|!addr,y ; Symbol
endmacro


;-------------------------------------------------------------------------------
; Return Handler Hidden/Visible
;-------------------------------------------------------------------------------

; Cleanup an element handler for elements that have not been rendered.
; Reset A/X/Y to 16-bit, restore previous X/Y values, and set Z flag to 1.
; @return A (16-bit): Always #$0000.
; @return Z: Always 1.
macro return_handler_hidden()
    REP #$30 : PLA : PLY : PLX
    LDA #$0000
    RTS
endmacro

; Cleanup an element handler for elements that have been rendered.
; Reset A/X/Y to 16-bit, restore previous X/Y values, and set Z flag to 0.
; @return A (16-bit): Always #$0001.
; @return Z: Always 0.
macro return_handler_visible()
    REP #$30 : PLY : PLX
    LDA #$0001
    RTS
endmacro


;-------------------------------------------------------------------------------
; LDA Level Byte
;-------------------------------------------------------------------------------

; Access the byte positioned at the current level's index in a given table.
; @param <level_table>: A table with a list of bytes, one for each level.
; @return A (8-bit): The byte for the level.
macro lda_level_byte(level_table)
    SEP #$20 : PHX : LDX $010B|!addr
    LDA.l <level_table>,x : PLX
endmacro