;===============================================================================
; PLAYER
;===============================================================================

; Indicates whether the current player is Mario or Luigi.


;-------------------------------------------------------------------------------
; Handler
;-------------------------------------------------------------------------------

; Draw player letter on status bar.
player:
    %check_visibility(player)

.visibility0
.visibility2
    LDA #$FC
    STA !player_slot
    RTS

.visibility1
    LDX $0DB3|!addr
    LDA ram_player_mario_symbol,x
    STA !player_slot
    RTS
