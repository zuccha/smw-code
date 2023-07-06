;===============================================================================
; MAIN ROUTINE
;===============================================================================

; Main status bar routine overriding the original one.


;-------------------------------------------------------------------------------
; Utils
;-------------------------------------------------------------------------------

; Draw empty spaces to erase any previous drawing.
; @param Y: Slot position.
; @param <size>: How many empty spaces to draw.
macro draw_empty_spaces(size)
    SEP #$20 : LDA #$FC
    !i #= 0
    while !i < <size>
        STA $0000+!i,y
        !i #= !i+1
    endif
    REP #$20
endmacro

; Draw a group of items in given slot positions.
; We iterate over items (coins, time, etc.) to display in the status bar. If the
; item can be shown, it will be drawn in the current slot, otherwise we go to
; the next one. Whenever we draw an item into a slot, then we select the next
; slot. This way, items are drawn in slots by their priority. Pseudo-code:
;   x = 0, y = 0
;   while (x < items.size && y < slots.size)
;     if (items[x].handle(slots[y])) ++y
;     ++x
; @param <group>: Number of the group (either 1 or 2).
; @param <size>: Width of the group, in tiles.
macro handle_group(group, size)
    !items = group<group>_items_table
    !slots = group<group>_slots_table
    !items_size = #group<group>_items_table_end-!items
    !slots_size = #group<group>_slots_table_end-!slots
    ; Draw every visible item in a slot.
    LDX #$0000                        ; Track items
    LDY #$0000                        ; Track slots
-   CPX.w !items_size : BCS +         ; If we still have elements...
    CPY.w !slots_size : BCS +         ; ...and slots available
    PHX : TYX : LDA.l !slots,x : PLX  ; "We have `LDA.l <slots>,y` at home"
    JSR (!items,x) : BEQ ++           ; Handle current item X at slot position Y
    INY : INY                         ; Go to the next slot
++  INX : INX                         ; Go to the next item
    BRA -                             ; Loop
+   ; Draw unoccupied slots with empty spaces to erase any previous drawing (in
    ; case elements shifted).
    TYX                               ; We no longer need X, we can use it for slots
-   CPX.w !slots_size : BCS +         ; If we still have slots
    LDA.l !slots,x : TAY              ; Load slot position
    %draw_empty_spaces(<size>)        ; Fill the slot with empty spaces
    INX : INX                         ; Go to the next slot
    BRA -
+
endmacro


;-------------------------------------------------------------------------------
; Main
;-------------------------------------------------------------------------------

; Main routine, draw all the elements of the status bar.
main:
    SEP #$30 : LDA ram_status_bar_visibility : BNE +
    RTL

+   REP #$30
    %handle_group(1, 4)
    %handle_group(2, 7)
    JSR handle_power_up
    SEP #$30
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
