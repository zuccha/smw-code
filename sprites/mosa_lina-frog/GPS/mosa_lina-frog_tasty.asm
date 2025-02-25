;===============================================================================
; MOSA LINA - FROG TASTY
;===============================================================================

; A block that can be eaten by the Frog sprite from Mosa Lina.


;-------------------------------------------------------------------------------
; Configuration
;-------------------------------------------------------------------------------

; Act as: 25 (blank) or 45-47 (berries).

; Number for the frog sprite, as specified in Pixi. When this sprite touches the
; block, the block will disappear and the frog will become slow.
!frog_sprite_number = $00

; What the block should turn into after the frog eats it.
; $02 = blank, $04 = solid bush (for berries). For all possible values, check
; https://www.smwcentral.net/?p=memorymap&a=detail&game=smw&region=ram&detail=dd11aeb933a0
!block_after_eating = $02


;-------------------------------------------------------------------------------
; Defines (don't touch)
;-------------------------------------------------------------------------------

; Should be the same as those defined in the frog sprite ASM file.
!action = !sprite_misc_1534
!action_eat = $80


;-------------------------------------------------------------------------------
; Block Setup
;-------------------------------------------------------------------------------

db $42

JMP return : JMP return : JMP return   ; MarioBelow, MarioAbove, MarioSide
JMP eat    : JMP eat                   ; SpriteV, SpriteH
JMP return : JMP return                ; MarioCape, MarioFireball
JMP return : JMP return : JMP return   ; TopCorner, BodyInside, HeadInside

return:
    RTL


;-------------------------------------------------------------------------------
; Eat
;-------------------------------------------------------------------------------

eat:
    LDA !sprite_extra_bits,x                ;\
    AND #$08 : BEQ return                   ;| Ignore if it's not a frog
    LDA !sprite_custom_num,x                ;|
    CMP.b #!frog_sprite_number : BNE return ;/

    LDA !action,x                           ;\
    ORA #!action_eat                        ;| Queue an "eat" action
    STA !action,x                           ;/

    PHY                                     ;\
    %sprite_block_position()                ;|
    LDA.b #!block_after_eating : STA $9C    ;| Transform the block
    JSL $00BEB0|!bank                       ;|
    PLY                                     ;/

    RTL


;-------------------------------------------------------------------------------
; Lunar Message Tooltip
;-------------------------------------------------------------------------------

print "Block that can be eaten by a Frog from Mosa Lina."
