;===============================================================================
; HIJACK
;===============================================================================

; Hijack after the original game decreases the time counter. We rewrite all the
; other parts in freespace to avoid conflicts with other patches.
org $008E6F
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
