;===============================================================================
; TOGGLE STATUS BAR
;===============================================================================

; A block that allows you to toggle the status bar's visibility.
; The block activates when the player hits it from below.

; This block should act as 130 (or anything solid).


;-------------------------------------------------------------------------------
; Setup
;-------------------------------------------------------------------------------

; Redefine RAM base address.
; It has to be the same as the one in ram.asm!
!freeram_address     = $7FB700
!freeram_address_sa1 = $40A700

; Update freeram address if SA-1.
if read1($00FFD5) == $23
    !freeram_address = !freeram_address_sa1
endif

; Macro for generating addresses.
macro define_ram(offset, name)
    !ram_<name> = !freeram_address+<offset>
    base !ram_<name>
        ram_<name>:
    base off
endmacro

; Define the addresses we need for the block.
; Do not change the offset ($00)!
%define_ram($00, status_bar_visibility)

; Sound effects for when bonking on the block. The list of values can be found here:
; https://www.smwcentral.net/?p=memorymap&a=detail&game=smw&region=ram&detail=294be88c9dcc
!bonk_sfx      = $35         ; Default = $35 (hit head)
!bonk_sfx_bank = $1DFC|!addr ; Default = $1DFC (hit head)


;-------------------------------------------------------------------------------
; Block Setup
;-------------------------------------------------------------------------------

db $42

JMP Toggle : JMP Return : JMP Return   ; MarioBelow, MarioAbove, MarioSide
JMP Return : JMP Return                ; SpriteV, SpriteH
JMP Return : JMP Return                ; MarioCape, MarioFireball
JMP Return : JMP Return : JMP Return   ; TopCorner, BodyInside, HeadInside

Return:
    RTL


;-------------------------------------------------------------------------------
; Toggle Visibility
;-------------------------------------------------------------------------------

Toggle:
    ; Ensure block is hit only once
    LDA $7D : BMI +                       ; If Mario is falling
    LDA.b #!bonk_sfx : STA !bonk_sfx_bank ; Then play sound effect
    RTL

    ; If visibility is 1 set it to 0, if it is 0 set it to 1.
+   LDA ram_status_bar_visibility : CMP #$02 : BEQ +
    LDA #$02 : STA ram_status_bar_visibility : RTL
+   LDA #$01 : STA ram_status_bar_visibility : RTL


;-------------------------------------------------------------------------------
; Lunar Message Tooltip
;-------------------------------------------------------------------------------

print "Toggle status bar when hit from below"
