;===============================================================================
; UTILS
;===============================================================================

; Define utility routines and macros for the main routines.


;-------------------------------------------------------------------------------
; HexToDec
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
; Visibility Checks
;-------------------------------------------------------------------------------

; Check visibility flags for an element that supports values 0, 1 and 2.
; This will retrieve the level's setting first (if level settings are enabled)
; and check on that. If the level setting is 11, it falls back to the global
; setting. If the setting is 0, the element is not visible; if the setting is 1,
; the element is visible; if the setting is 2, visibility is handled by
; <check_mode_2>.
; @param <global_setting>: The global setting to use for the current element.
; @param <group>: Group number for the element (bonus stars, coins, lives, and
; time are in group 1; power up, dragon coins, and score are in group 2).
; @param <position>: A value between 0 and 3, referencing the position in the
; byte %AABBCCDD in the element's visibility table, where 0 points to A, 1 to B,
; 2 to C, and 3 to D.
; @param <check_mode_2>: Name of the macro that checks visibility when the
; setting's value is 2.
; @return A (16-bit): #$0000 if the element is not visible, #$0001 otherwise.
; @return Z: 1 if element is not visible, 0 otherwise.
; Examples:
; - %check_visibility(!TimeVisibility, 1, 3, check_time_mode_2)
; - %check_visibility(!DragonCoinsVisibility, 2, 3, check_dragon_coins_mode_2)
macro check_visibility(global_setting, group, position, check_mode_2)
    if !EnableLevelConfiguration == 1
        SEP #$20 : %lda_level_byte(Group<group>VisibilityTable)
        AND #%11000000>>(<position>*2) : BEQ .mode0
        CMP #%01000000>>(<position>*2) : BEQ .mode1
        CMP #%10000000>>(<position>*2) : BEQ .mode2
    endif

    REP #$20
    if <global_setting> == 2
        %<check_mode_2>()
    elseif <global_setting> == 1
        LDA #$0001
    else
        LDA #$0000
    endif
    RTS

.mode0: REP #$20 : LDA #$0000 : RTS
.mode1: REP #$20 : LDA #$0001 : RTS
.mode2: REP #$20 : %<check_mode_2>() : RTS
endmacro

; Check visibility flags for an element that supports values 0 and 1.
; This will retrieve the level's setting first (if level settings are enabled)
; and check on that. If the level setting is 11, it falls back to the global
; setting. If the setting is 0, the element is not visible; if the setting is 1,
; the element is visible.
; @param <global_setting>: The global setting to use for the current element.
; @param <group>: Group number for the element (bonus stars, coins, lives, and
; time are in group 1; power up, dragon coins, and score are in group 2).
; @param <position>: A value between 0 and 3, referencing the position in the
; byte %AABBCCDD in the element's visibility table, where 0 points to A, 1 to B,
; 2 to C, and 3 to D.
; @return A (16-bit): #$0000 if the element is not visible, #$0001 otherwise.
; Examples:
; - %check_visibility_simple(!BonusStarsVisibility, 1, 2)
; - %check_visibility_simple(!PowerUpVisibility, 2, 1)
macro check_visibility_simple(global_setting, group, position)
    if !EnableLevelConfiguration == 1
        SEP #$20 : %lda_level_byte(Group<group>VisibilityTable)
        AND #%11000000>>(<position>*2) : BEQ .mode0
        CMP #%01000000>>(<position>*2) : BEQ .mode1
    endif

    REP #$20
    if <global_setting> == 1
        LDA #$0001
    else
        LDA #$0000
    endif
    RTS

.mode0: REP #$20 : LDA #$0000 : RTS
.mode1: REP #$20 : LDA #$0001 : RTS
endmacro


;-------------------------------------------------------------------------------
; Render
;-------------------------------------------------------------------------------

; Draw a hexadecimal number lower than $64 (100) as a two-digits decimal number.
; The number will be drawn in format "S0TU", where "S" is the symbol, "0" is a
; harcoded 0, "T" is the tens' digit, and "U" is the units' digit.
; @param A (8-bit): The hexadecimal number.
; @param Y (16-bit): Slot position.
; @param <symbol>: Symbol to display before the number.
macro draw_counter_with_two_digits(symbol)
    JSL.l HexToDec                ; Get decimal value
    STA $0003,y                   ; Units
    TXA : STA $0002,y             ; Tens
    LDA #$00 : STA $0001,y        ; Hundreds, hardcoded
    LDA.b #<symbol> : STA $0000,y ; Symbol
endmacro

; Draw a group of items in given slot positions.
; We iterate over items (coins, time, etc.) to display in the status bar. If the
; item can be shown, it will be drawn in the current slot, otherwise we go to
; the next one. Whenever we draw an item into a slot, then we select the next
; slot. This way, items are drawn in slots by their priority. Pseudo-code:
;   x = 0, y = 0
;   while x < items.size && y < slots.size
;     if items[x].isVisible()
;       items[x].show(slots[j])
;       ++y
;     ++x
; @param <items>: Table containin a list of items, each item is a pair of:
; - visibility check routine (i.e., IsItemVisible)
; - drawing routine (i.e., DrawItem)
; @param <slots>: Table containing drawing slots.
macro draw_group(items, slots)
    LDX #$0000                               ; Track items
    LDY #$0000                               ; Track slots
-   TXA : CMP.w #<items>_end-<items> : BCS + ; If we still have elements...
    TYA : CMP.w #<slots>_end-<slots> : BCS + ; ...and slots available
    JSR (<items>,x) : BEQ ++                 ; If current item should be shown
    ; LDA.l <slots>,y : JSR (<items>+2,x)    ; Then show current item in current slot
    PHX : TYX : LDA.l <slots>,x : PLX        ; "We have `LDA.l <slots>,y` at home"
    JSR (<items>+2,x)                        ; A is the parameter for the routine
    INY : INY                                ; Go to next slot
++  INX : INX : INX : INX                    ; Go to next item
    BRA -                                    ; Loop
+
endmacro


;-------------------------------------------------------------------------------
; Table Access
;-------------------------------------------------------------------------------

; Access the byte positioned at the current level's index in a given table.
; @param <level_table>: A table with a list of bytes, one for each level.
; @return A (8-bit): The byte for the level.
macro lda_level_byte(level_table)
    SEP #$20 : PHX : LDX $010B|!addr
    LDA.l <level_table>,x : PLX
endmacro

; Load the coins' limit for a given level (or global if level configuration is
; disabled) into A (8-bit).
; @return A (8-bit): Coins limit.
macro lda_coins_limit()
    if !EnableLevelConfiguration == 1
        %lda_level_byte(CoinsLimitTable)
    else
        SEP #$20 : LDA !CoinsLimit
    endif
endmacro
