;===============================================================================
; CALLBACKS
;===============================================================================

; This are routines that are called at specific times while rendering the status
; bar. They all have their default behaviours, but you can modify it however you
; want.

; N.B.: We are inside CSB's namespace, so you don't have to prefix RAM addresses
; with `csb`. You use the plain RAM address.
; For example, this is correct
;   LDA #$01 : STA ram_status_bar_visibility
; and this is wrong
;   LDA #$01 : STA csb_ram_status_bar_visibility

; Registers come in 8-bit and should be in 8-bit when returning. You don't have
; to worry about pushing registers to the stack or resetting them, this is
; handled automatically.


;-------------------------------------------------------------------------------
; Trigger Bonus Starts Limit Reached
;-------------------------------------------------------------------------------

; Called when the amount of collected bonus stars equals !bonus_stars_limit.
trigger_bonus_stars_limit_reached:
    ; Add your code here.
    RTS


;-------------------------------------------------------------------------------
; Trigger Coins Limit Reached
;-------------------------------------------------------------------------------

; Called when the amount of collected coins equals !coins_limit.
trigger_coins_limit_reached:
    ; Add your code here.
    RTS


;-------------------------------------------------------------------------------
; Trigger Time Run Out
;-------------------------------------------------------------------------------

; Called when the time reaches zero.
trigger_time_run_out:
    ; Add your code here.
    RTS
