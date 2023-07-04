;===============================================================================
; MAIN ROUTINE
;===============================================================================

; Main status bar routine overriding the original one.


;-------------------------------------------------------------------------------
; Utils
;-------------------------------------------------------------------------------

; Draw a group of items in given slot positions.
; We iterate over items (coins, time, etc.) to display in the status bar. If the
; item can be shown, it will be drawn in the current slot, otherwise we go to
; the next one. Whenever we draw an item into a slot, then we select the next
; slot. This way, items are drawn in slots by their priority. Pseudo-code:
;   x = 0, y = 0
;   while (x < items.size && y < slots.size)
;     if (items[x].handle(slots[y])) ++y
;     ++x
; @param <items>: Table containin a list of items, each item is a pair of:
; - visibility check routine (i.e., IsItemVisible)
; - drawing routine (i.e., DrawItem)
; @param <slots>: Table containing drawing slots.
macro handle_group(group)
    !items = group<group>_items_table
    !slots = group<group>_slots_table
    !items_size = #group<group>_items_table_end-!items
    !slots_size = #group<group>_slots_table_end-!slots
    LDX #$0000                        ; Track items
    LDY #$0000                        ; Track slots
-   CPX.w !items_size : BCS +         ; If we still have elements...
    CPY.w !slots_size : BCS +         ; ...and slots available
    PHX : TYX : LDA.l !slots,x : PLX  ; "We have `LDA.l <slots>,y` at home"
    JSR (!items,x) : BEQ ++           ; Handle current item X at slot position Y
    INY : INY                         ; Go to next slot
++  INX : INX                         ; Go to next item
    BRA -                             ; Loop
+
endmacro


;-------------------------------------------------------------------------------
; Main
;-------------------------------------------------------------------------------

; Main routine, draw all the elements of the status bar.
main:
    REP #$30            ; A, X, and Y 16-bit
    %handle_group(1)    ; Draw group 1
    %handle_group(2)    ; Draw group 2
    JSR handle_power_up ; Draw power up
    SEP #$30            ; A, X, and Y 8-bit
    RTL


;-------------------------------------------------------------------------------
; Group Definitions
;-------------------------------------------------------------------------------

; Group 1.
group1_items_table: dw !group1_order
.end
group1_slots_table: dw !group1_slots
.end

; Group 2.
group2_items_table: dw !group2_order
.end
group2_slots_table: dw !group2_slots
.end
