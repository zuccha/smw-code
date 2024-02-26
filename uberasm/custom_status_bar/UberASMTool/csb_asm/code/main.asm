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
;   while (x < slots.size && y < items.size)
;     if (items[y].handle(slots[x])) ++x
;     ++y
; @param <group>: Number of the group (either 1 or 2).
macro handle_group(group)
    !items = group_<group>_items
    !slots = group_<group>_slots
    !items_count = group_<group>_items_end-!items
    !slots_count = group_<group>_slots_end-!slots
    !tiles_count = !group_<group>_tiles_count-1

    ; Draw every visible item in a slot.
    LDX #$00                            ; Track slots
    LDY #$00                            ; Track items
?-  CPY.b #!items_count : BCS ?cleanup  ; If we still have elements...
    CPX.b #!slots_count : BCS ?cleanup  ; ...and slots available

    REP #$20                            ; Fetch and store the next tile address
    LDA.l !slots,x : STA !tile_addr     ; that will be used by handlers to draw
    SEP #$20                            ; in the status bar

    PHX : PHY                           ; Invoke item handler
    TYX : JSR (!items,x)                ; We have `JSR (!items,y)` at home
    PLY : PLX                           ; If handler didn't draw anything
    BCC ?++                             ; Then don't shift slot

    INX #2                              ; Go to the next slot
?++ INY #2                              ; Go to the next item
    BRA ?-                              ; Loop

    ; Draw unoccupied slots with empty spaces to erase any previous drawing (in
    ; case elements shifted).
?cleanup
    CPX.b #!slots_count : BCS ?+        ; If we still have slots

    REP #$20                            ; Fetch and store the next tile address
    LDA.l !slots,x : STA !tile_addr     ; that will be used by handlers to draw
    SEP #$20                            ; in the status bar

    LDA #$FC                            ; Draw a number of empty spaces
    LDY.b #!tiles_count                 ; equal to the size of the slot
?-  %draw_tile()
    DEY : BPL ?-

    INX #2 : BRA ?cleanup               ; Go to the next slot
?+
endmacro


;-------------------------------------------------------------------------------
; Main
;-------------------------------------------------------------------------------

; Main routine, draw all the elements of the status bar.
main:
    LDA ram_status_bar_visibility
    CMP #$02 : BEQ .visible
    CMP #$01 : BEQ .hidden

.disabled
    RTL

.hidden
    LDA #$FC                    ;\
    LDX #!total_tiles_count-1   ;| Clear each tile of the status bar tilemap
-   STA $0EF9|!addr,x           ;|
    DEX : BPL -                 ;/
    RTL

.visible
    %handle_group(1)
    %handle_group(2)
    JSR player
    JSR power_up
    RTL
