;===============================================================================
; RESTORE STATUS BAR
;===============================================================================

; Revert changes applied by Custom Status Bar.

; Restore the original status bar routine.
org $008E1F
    BNE $46

; Restore default X position for the item box, where the item starts falling
; from.
org $028052
    db #$78

; Make sure the item gets stored and falls from the item box.
org $028008
    PHX

; Restore graphics and palettes of all tiles in the status bar.
org $008C81
    ;Top 4 tiles of the item box
    db $3A, %00111000
    db $3B, %00111000
    db $3B, %00111000
    db $3A, %01111000
org $008C89
    ;Top RAM-editable row:
    db $30, %00101000
    db $31, %00101000
    db $32, %00101000
    db $33, %00101000
    db $34, %00101000
    db $FC, %00111000
    db $FC, %00111100
    db $FC, %00111100
    db $FC, %00111100
    db $FC, %00111100
    db $FC, %00111000
    db $FC, %00111000
    db $4A, %00111000
    db $FC, %00111000
    db $FC, %00111000
    db $4A, %01111000
    db $FC, %00111000
    db $3D, %00111100
    db $3E, %00111100
    db $3F, %00111100
    db $FC, %00111000
    db $FC, %00111000
    db $FC, %00111000
    db $2E, %00111100
    db $26, %00111000
    db $FC, %00111000
    db $FC, %00111000
    db $00, %00111000
    ;Bottom RAM-editable row:
    db $26, %00111000
    db $FC, %00111000
    db $00, %00111000
    db $FC, %00111000
    db $FC, %00111000
    db $FC, %00111000
    db $64, %00101000
    db $26, %00111000
    db $FC, %00111000
    db $FC, %00111000
    db $FC, %00111000
    db $4A, %00111000
    db $FC, %00111000
    db $FC, %00111000
    db $4A, %01111000
    db $FC, %00111000
    db $FE, %00111100
    db $FE, %00111100
    db $00, %00111100
    db $FC, %00111000
    db $FC, %00111000
    db $FC, %00111000
    db $FC, %00111000
    db $FC, %00111000
    db $FC, %00111000
    db $FC, %00111000
    db $00, %00111000
org $008CF7
    ;Bottom 4 tiles of the item box
    db $3A, %10111000
    db $3B, %10111000
    db $3B, %10111000
    db $3A, %11111000
