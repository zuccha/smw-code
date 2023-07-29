;===============================================================================
; UTILS
;===============================================================================

; Define utility routines and macros for the main routines.


;-------------------------------------------------------------------------------
; Scratch RAM
;-------------------------------------------------------------------------------

!T0 = $00
!T1 = $01
!T2 = $02
!T3 = $03
!T4 = $04
!T5 = $05
!T6 = $06
!T7 = $07


;-------------------------------------------------------------------------------
; Check Visibility
;-------------------------------------------------------------------------------

; Check visibility flags for an element that supports values 0 and 1.
; This will retrieve the level's setting first (if level settings are enabled)
; and check on that. If the level setting is 11, it falls back to the global
; setting. Depending on the setting's value, the macro will jump to different
; labels.
; @param <item>: The item you want to check visibility for. Must be one of:
;   bonus_stars, coins, lives, time, power_up, dragon_coins, score
; @branch .visibility0: Jump here if the setting is not 1 or 2.
; @branch .visibility1: Jump here if the setting = 1.
; @branch .visibility2: Jump here if the setting = 2.
macro check_visibility(item)
    SEP #$20 : LDA ram_<item>_visibility
    CMP #$02 : BEQ .visibility2
    CMP #$01 : BEQ .visibility1
    BRA .visibility0
endmacro


;-------------------------------------------------------------------------------
; Draw Three-Digits Number
;-------------------------------------------------------------------------------

; Draw a one-byte long hexadecimal number as a three-digits decimal.
; @param A (8-bit): The hexadecimal number to be drawn.
; @param Y (16-bit): Slot position.
draw_3_digits_number:
    LDX #$0000                          ; X counts 100s
-   CMP #$64 : BCC +                    ; While A >= 100
    SBC #$64 : INX                      ; Subtract 100 and increase 100s count
    BRA -                               ; Repeat
+   PHA : TXA : STA $0001|!addr,y : PLA ; Draw 100s.

    LDX #$0000                          ; X counts 10s
-   CMP #$0A : BCC +                    ; While A >= 10
    SBC #$0A : INX                      ; Subtract 10 and increase 10s count
    BRA -                               ; Repeat
+   PHA : TXA : STA $0002|!addr,y : PLA ; Draw 10s.

    STA $0003|!addr,y                   ; Draw 1s.

    RTL

; Draw a hexadecimal number lower than $64 (100) as a two-digits decimal number.
; The number will be drawn in format "SHTO", where "S" is the symbol, "H" is the
; hundreds' digit, "T" is the tens' digit, and "O" is the ones' digit.
; @param A (8-bit): The hexadecimal number.
; @param Y (16-bit): Slot position.
; @param <symbol>: Address (label) containing the symbol to display before the
; number.
macro draw_3_digits_number_with_symbol(symbol)
    JSL.l draw_3_digits_number       ; Draw 100s, 10s, and 1s
    LDA <symbol> : STA $0000|!addr,y ; Draw symbol
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
; Debug Value
;-------------------------------------------------------------------------------

; Draw a value as a 3-digits decimal in the bottom-left corner of the status
; bar, preceded by a ! (e.g., !293).
; @param <value>: The value to debug.
macro debug_value(value)
    PHA : PHY : PHP : SEP #$20
    LDA <value> : LDY #$0F15 : %draw_3_digits_number_with_symbol(#$28)
    PLP : PLY : PLA
endmacro
