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
    !Items = Group<group>Items
    !Slots = Group<group>Slots
    !ItemsSize = #Group<group>Items_end-!Items
    !SlotsSize = #Group<group>Slots_end-!Slots
    LDX #$0000                       ; Track items
    LDY #$0000                       ; Track slots
-   CPX.w !ItemsSize : BCS +         ; If we still have elements...
    CPY.w !SlotsSize : BCS +         ; ...and slots available
    PHX : TYX : LDA.l !Slots,x : PLX ; "We have `LDA.l <slots>,y` at home"
    JSR (!Items,x) : BEQ ++          ; Handle current item X at slot position Y
    INY : INY                        ; Go to next slot
++  INX : INX                        ; Go to next item
    BRA -                            ; Loop
+
endmacro


;-------------------------------------------------------------------------------
; Main
;-------------------------------------------------------------------------------

; Main routine, draw all the elements of the status bar.
main:
    REP #$30          ; A, X, and Y 16-bit
    %handle_group(1)  ; Draw group 1
    %handle_group(2)  ; Draw group 2
    JSR HandlePowerUp ; Draw power up
    SEP #$30          ; A, X, and Y 8-bit
    RTL


;-------------------------------------------------------------------------------
; Group Definitions
;-------------------------------------------------------------------------------

; Group 1.
Group1Items: dw !Group1Order
.end
Group1Slots: dw !Group1Slots
.end

; Group 2.
Group2Items: dw !Group2Order
.end
Group2Slots: dw !Group2Slots
.end
