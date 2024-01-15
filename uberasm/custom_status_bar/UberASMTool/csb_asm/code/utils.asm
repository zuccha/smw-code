;===============================================================================
; UTILS
;===============================================================================

; Define utility routines and macros for the main routines.


;-------------------------------------------------------------------------------
; Constants
;-------------------------------------------------------------------------------

; How many tiles are in each group and in total.
!group_1_tiles_count = $04
!group_2_tiles_count = $07
!total_tiles_count   = $37


;-------------------------------------------------------------------------------
; Tilemap
;-------------------------------------------------------------------------------

; We use $0E-$0F to store the address of the next status bar RAM address where
; we want to draw to.
!tile_addr = $0E

; Draw the value in A by storing it in the status bar tilemap RAM address, then
; go to next tile address.
; @param A: The tile to draw in the status bar.
macro draw_tile()
    STA (!tile_addr)
    INC !tile_addr
endmacro


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
    LDA ram_<item>_visibility : ASL : TAX
    JMP (?visibility_ptrs,x)
?visibility_ptrs: dw .visibility0, .visibility1, .visibility2
endmacro


;-------------------------------------------------------------------------------
; Draw Three-Digits Number
;-------------------------------------------------------------------------------

; Draw a one-byte long hexadecimal number as a three-digits decimal.
; @param A (8-bit): The hexadecimal number to be drawn.
draw_3_digits_number:
    LDX #$00                            ; X counts 100s
-   CMP #$64 : BCC +                    ; While A >= 100
    SBC #$64 : INX                      ; Subtract 100 and increase 100s count
    BRA -                               ; Repeat
+   XBA : TXA : %draw_tile() : XBA      ; Draw 100s.

    LDX #$00                            ; X counts 10s
-   CMP #$0A : BCC +                    ; While A >= 10
    SBC #$0A : INX                      ; Subtract 10 and increase 10s count
    BRA -                               ; Repeat
+   XBA : TXA : %draw_tile() : XBA      ; Draw 10s.

    %draw_tile()                        ; Draw 1s.

    RTL

; Draw a hexadecimal number lower than $64 (100) as a two-digits decimal number.
; The number will be drawn in format "SHTO", where "S" is the symbol, "H" is the
; hundreds' digit, "T" is the tens' digit, and "O" is the ones' digit.
; @param A (8-bit): The hexadecimal number.
; @param <symbol>: Address or value containing the symbol to display before the
; number.
macro draw_3_digits_number_with_symbol(symbol)
    PHA : LDA <symbol> : %draw_tile() : PLA ; Draw symbol
    JSL.l draw_3_digits_number              ; Draw 100s, 10s, and 1s
endmacro
