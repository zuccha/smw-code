;===============================================================================
; HIJACK
;===============================================================================

pushpc

; Override status bar after UberASMTool's hijack.
org $008E1F
    RTS

; Tweak stored power up horizontal position (where it starts falling from).
org $028052
    db !PowerUpPositionX

; Prevent item from falling if disabled from settings.
org $028008
if !PowerUpVisibility == 2
    RTL
else
    PHX
endif

pullpc
