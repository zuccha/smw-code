;===============================================================================
; Main Routine
;===============================================================================

; Main routine, draw all the elements of the status bar.
CustomizeStatusBar:
    REP #$30                                       ; A, X, and Y 16-bit
    %draw_group(Group1Items, Group1Slots)          ; Draw group 1
    %draw_group(Group2Items, Group2Slots)          ; Draw group 2
    JSR IsPowerUpVisible : BEQ + : JSR ShowPowerUp ; Draw powerup
+   SEP #$30                                       ; A, X, and Y 8-bit
    RTL

; Group 1.
Group1Items: dw !Group1Order
.end
Group1Slots: dw !Group1Slots
.end

; Group 2.
Group2Items: dw !Group2Order
.end
Group2Slots: dw !Group2Slots
.end
