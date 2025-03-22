;===============================================================================
; MOSA LINA - FROG DEADLY
;===============================================================================

; A block that kills the Frog sprite from Mosa Lina.

; The frog will die but stay in place, so Mario can still walk on it.
; The frog will spit an eaten item when dying.


;-------------------------------------------------------------------------------
; Configuration
;-------------------------------------------------------------------------------

; Act as: 12F (piranha plant) or 130 (cement).

; Number for the frog sprite, as specified in Pixi. When this sprite touches the
; block, the block will disappear and the frog will become slow.
!frog_sprite_number = $00


;-------------------------------------------------------------------------------
; Defines (don't touch)
;-------------------------------------------------------------------------------

; Should be the same as those defined in the frog sprite ASM file.
!action = !sprite_misc_1534
!action_die = $40


;-------------------------------------------------------------------------------
; Block Setup
;-------------------------------------------------------------------------------

db $42

JMP return : JMP return : JMP return   ; MarioBelow, MarioAbove, MarioSide
JMP kill   : JMP kill                  ; SpriteV, SpriteH
JMP return : JMP return                ; MarioCape, MarioFireball
JMP return : JMP return : JMP return   ; TopCorner, BodyInside, HeadInside

return:
    RTL


;-------------------------------------------------------------------------------
; Kill
;-------------------------------------------------------------------------------

kill:
    LDA !sprite_extra_bits,x                ;\
    AND #$08 : BEQ return                   ;| Ignore if it's not a frog
    LDA !sprite_custom_num,x                ;|
    CMP.b #!frog_sprite_number : BNE return ;/

    LDA !action,x                           ;\
    ORA #!action_die                        ;| Queue a "death" action
    STA !action,x                           ;/

    RTL


;-------------------------------------------------------------------------------
; Lunar Message Tooltip
;-------------------------------------------------------------------------------

print "Block that will kill a Frog from Mosa Lina."
