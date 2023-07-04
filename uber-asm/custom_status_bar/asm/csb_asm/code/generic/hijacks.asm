;===============================================================================
; HIJACKS
;===============================================================================

; This patch uses three highjacks:
; 1. Disable original status bar.
; 2. Retrieve custom item box's horizontal position.
; 3. Prevent item box from dropping item if power_up_visibility = 2 (disabled).


;-------------------------------------------------------------------------------
pushpc ; Hijacks
;-------------------------------------------------------------------------------

; Override status bar after UberASMTool's hijack.
org $008E1F
    RTS

; Tweak stored power up horizontal position (where it starts falling from).
org $028051
    JSL get_power_up_x_position

; Prevent item from falling if disabled from settings.
org $028008
    JML check_if_item_should_drop


;-------------------------------------------------------------------------------
pullpc ; Utilities
;-------------------------------------------------------------------------------

; Replace LDA #$78 with position from settings.
get_power_up_x_position:
    LDA ram_power_up_position_x ; Retrieve position
    CLC : ADC $1A               ; Restore original code
    RTL

; Restore code for dropping item.
check_if_item_should_drop:
    LDA ram_power_up_visibility ; If visibility = 2
    CMP #$02 : BNE +            ; Then don't drop item
    JML $028071|!bank           ; (jump to the end of the routine)
+   PHX : LDA $0DC2             ; Else restore original code
    JML $02800C|!bank           ; (jump back into the routine)
