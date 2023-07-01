;===============================================================================
; UTILS
;===============================================================================

; Define utility routines and macros for the main routines.


;-------------------------------------------------------------------------------
; HexToDec
;-------------------------------------------------------------------------------

; Convert hexadecimal number stored in A to decimal.
; The tens' digit is stored in X, the units' digit is stored in A.
HexToDec:
    LDX #$0000       ; X counts the tens
-   CMP #$0A : BCC + ; If A > $0A (10)...
    SBC #$0A : INX   ; ...A -= $0A (-= 10), X += 1
    BRA -            ; Repeat
+   RTL


;-------------------------------------------------------------------------------
; Visibility Checks
;-------------------------------------------------------------------------------

; Check visibility flags, and jump to label based on the content.
; <flags> is an address where flags in the form %AABBCCDD are stored (e.g., see
; "Group 1 Visibility per Level" table). <position> is a value between 0 and 3,
; where 0 points to A, 1 to B, 2 to C, and 3 to D.
; The routine jumps to label .mode0 is the flag is 00 (0), .mode1 if 01 (1),
; .mode2 if 10 (2), and just continues (global settings) if 11 (3).

; Check visibility flags for an element that supports values 0 and 1.
; Based on the value of the flag, it will store in A (16-bit) different values:
; - 00 ($00): #$0000
; - 01 ($01): #$0001
; - 10 ($02): execute <check_mode_2>
; - 11 ($03): #$0000 if global_setting = 0, #$0001 if global_setting = 1
; <global_setting> is the global setting for the current element. <group> is the
; group number in which the element is found (bonus stars, coins, lives, and
; time are in group 1, power up, dragon coins, and score are in group 2).
; <position> is a value between 0 and 3, referencing the position in the byte
; %AABBCCDD in the element's visibility table., where 0 points to A, 1 to B,
; 2 to C, and 3 to D.
; Examples:
; - %check_visibility(!TimeVisibility, 1, 3, check_time_mode_2)
; - %check_visibility_simple(!PowerUpVisibility, 2, 1)
macro check_visibility(global_setting, group, position, check_mode_2)
    SEP #$20 : %lda_level_byte(Group<group>VisibilityTable)
    AND #%11000000>>(<position>*2) : BEQ .mode0
    CMP #%01000000>>(<position>*2) : BEQ .mode1
    CMP #%10000000>>(<position>*2) : BEQ .mode2

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

; Like check_visibility, but if flag is 10 ($02), it behaves like a global
; setting.
macro check_visibility_simple(global_setting, group, position)
    SEP #$20 : %lda_level_byte(Group<group>VisibilityTable)
    AND #%11000000>>(<position>*2) : BEQ .mode0
    CMP #%01000000>>(<position>*2) : BEQ .mode1

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

; Given a hexadecimal number (stored in A 8-bit) and a symbol (macro param), the
; routine will convert the hexadecimal number in decimal and draw it with the
; following format: "S0TU", where "S" is the symbol, "0" is a harcoded 0, "T" is
; the tens' digit, and "U" is the units' digit.
; Params:
; - Register A (8-bit): Hexadecimal number to display
; - Register Y (16-bit): Position on the status bar where to start drawing
; - symbol: Symbol to display before the number
macro draw_counter_with_two_digits(symbol)
    JSL.l HexToDec                   ; Get decimal value
    STA $0003,y                      ; Units
    TXA : STA $0002,y                ; Tens
    LDA #$00 : STA $0001,y           ; Hundreds
    LDA.b #<symbol> : STA $0000,y    ; Symbol
endmacro

; We iterate over items (coins, time, etc.) to display in the status bar. If the
; item can be shown, it will be drawn in the current slot, otherwise we go to
; the next one. Whenever we draw an item into a slot, then we select the next
; slot. This way, items are drawn in slots by their priority. Pseudo-code:
;   x = 0, y = 0
;   while x < items.size && y < slots.size
;     if items[x].shouldShow()
;       items[x].show(slots[j])
;       ++y
;     ++x
; Params:
; - items: Table containin a list of items, where each item is a pair of
;   visibility check routine (i.e., IsItemVisible) and the drawing routine
;   (i.e., DrawItem)
; - slots: Table containing the initial address for each slot.
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

; Given a table, access the byte positioned at the current level's index. The
; byte is stored in A (8-bit).
macro lda_level_byte(level_table)
    SEP #$20 : PHX : LDX $010B|!addr
    LDA.l <level_table>,x : PLX
endmacro
