;===============================================================================
; HIJACK
;===============================================================================

pushpc

; Override status bar after UberASMTool's hijack.
org $008E1F
    RTS

; Tweak stored power up horizontal position (where it starts falling from).
org $028052
    db !power_up_position_x

; Prevent item from falling if disabled from settings.
org $028008
if !power_up_visibility == 2
    RTL
else
    PHX
endif

pullpc
