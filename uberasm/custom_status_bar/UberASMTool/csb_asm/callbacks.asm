;===============================================================================
; CALLBACKS
;===============================================================================

; This are routines that are called at specific times while rendering the status
; bar. They all have their default behaviours, but you can modify it however you
; want.

; N.B.: We are inside CSB's namespace, so you don't have to prefix RAM addresses
; with `csb`. You use the plain RAM address.
; For example, this is correct
;   LDA #$ 00 : STA ram_status_bar_visibility
; and this is wrong
;   LDA #$ 00 : STA csb_ram_status_bar_visibility

; Every routine specifies in which modes the registers are in. You don't have to
; worry about pushing registers to the stack or resetting them, this is handled
; automatically.


;-------------------------------------------------------------------------------
; Trigger Bonus Starts Limit Reached
;-------------------------------------------------------------------------------

; Called when the amount of collected bonus stars equals !bonus_stars_limit.
; Registers: A (8-bit), X/Y (16-bit)
trigger_bonus_stars_limit_reached:
    ; Add your code here.
    RTS


;-------------------------------------------------------------------------------
; Trigger Coins Limit Reached
;-------------------------------------------------------------------------------

; Called when the amount of collected coins equals !coins_limit.
; Registers: A (8-bit), X/Y (16-bit)
trigger_coins_limit_reached:
    ; Add your code here.
    RTS


;-------------------------------------------------------------------------------
; Trigger Time Run Out
;-------------------------------------------------------------------------------

; Called when the time reaches zero.
; Registers: A (8-bit), X/Y (16-bit)
trigger_time_run_out:
    ; Add your code here.
    RTS
