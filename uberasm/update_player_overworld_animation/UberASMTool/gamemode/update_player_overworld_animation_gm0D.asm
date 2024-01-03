;===============================================================================
; UPDATE PLAYER OVERWORLD ANIMATION
;===============================================================================


;-------------------------------------------------------------------------------
; Code
;-------------------------------------------------------------------------------

init:
    LDA $0DD6|!addr   ; \
    LSR               ; | Get player (initially, 0 is Mario, 4 is Luigi) and
    AND #$02          ; | convert the values to 0 or 2 respectively.
    TAX               ; /

    LDA $13C1|!addr   ; \
    CMP #$80          ; | If the tile where player is standing is one of
    BEQ .water        ; | 6A-6D/80, then it is a water tile, otherwise it's
    CMP #$6A          ; | ground (we assume it's ground, and not climbing or
    BCC .ground       ; | others, since it's the only plausible option during
    CMP #$6E          ; | overworld load).
    BCS .ground       ; /

.water
    LDA $1F13|!addr,X ; \
    ORA #$08          ; | Set player animation to water animation.
    STA $1F13|!addr,X ; /
    BRA .return

.ground
    LDA $1F13|!addr,X ; \
    AND #$F7          ; | Set player animation to walk animation.
    STA $1F13|!addr,X ; /

.return
    ; Before returning, invoke original routine that draws the player on the
    ; overworld, so that we ensure the correct animation is drawn (otherwise the
    ; correct animation will be visible only during the next frame).
    PHB
    LDA.b #$04|!bank8 : PHA : PLB
    PHK : PEA.w (+)-1
    PEA.w $048414-1
    JML $04862E|!bank
+   PLB
    RTL
