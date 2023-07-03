;===============================================================================
; HIJACK
;===============================================================================

; Hijack at the beginning of the original status bar routine. Rewrite all the
; parts in freespace to avoid conflicts with other patches.
org $008E1A
    autoclean JSL CustomizeStatusBar
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

; Start freecode, no more hijacks from now on.
freecode
