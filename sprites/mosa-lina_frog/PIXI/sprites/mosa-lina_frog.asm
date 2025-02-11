;===============================================================================
; MOSA LINA - FROG
;===============================================================================

; Frog enemy from the Mona Lisa game.


;-------------------------------------------------------------------------------
; Configuration (extra bytes)
;-------------------------------------------------------------------------------

; Extra bit: Initial direction. 0 = right, 1 = left.

; Extra Byte 1: The frog's behavior. The format is %IS:
; - `S`: 0 = stationary, 1 = moves left or right.
; - `I`: 0 = don't invert direction, 1 = invert direction (relevant only if not
;   stationary).


;-------------------------------------------------------------------------------
; Configuration (defines)
;-------------------------------------------------------------------------------

; TODO


;-------------------------------------------------------------------------------
; Configuration (graphics)
;-------------------------------------------------------------------------------

; Which graphics page to use.
; - 0 = SP1/SP2
; - 1 = SP3/SP4
!gfx_page = 1

; Graphic tiles to use for each pose of the frog. Each tile is 16x16 pixels.
; Tile are in this order: top-left, top-right, bottom-left, bottom-right.
gfx_rest: db $00, $02, $20, $22
gfx_bend: db $04, $06, $24, $26
gfx_leap: db $08, $0A, $28, $2A
gfx_dead: db $0C, $0E, $2C, $2E

; Color palettes to use for the different variants of the frog.
; Each variant has its base color palette, and the color palette for when the
; frog has eaten a key.
; Valid values are any of 0-7.
!palette_normal     = 5
!palette_normal_key = 2
!palette_frail      = 4
!palette_frail_key  = 2


;-------------------------------------------------------------------------------
; Defines (don't touch)
;-------------------------------------------------------------------------------

; Sprite index.
!sprite_index = $15E9|!addr

; Sprite pose, representing what the frog is doing.
!phase = !sprite_misc_1504
!phase_rest = 0
!phase_load = 1
!phase_jump = 2
!phase_land = 3
!phase_dead = 4

; Sprite direction. 0 = right, 1 = left.
!direction = !sprite_misc_157c

; Whether the frog is fragile (1) or not (0).
!is_fragile = !sprite_misc_154c

; Whether the frog has eaten a key (1) or not (0).
!has_eaten_key = !sprite_misc_160e

; The X offset (from the center) is needed to center the sprite, since it uses
; 32 pixels, but it's effectively only 24 pixels wide.
!x_offset = $04

; The Y offset (from the center) is needed to make the sprite slightly overlaps
; with the grounds, making it look like its belly is touching the ground, while
; its arms are slightly below.
!y_offset = $04

; Aliases for OAM addresses.
!oam_pos_x = $0300|!addr
!oam_pos_y = $0301|!addr
!oam_tile  = $0302|!addr
!oam_props = $0303|!addr

; Basic OAM props, defining priority and page. Palette and flip X will be
; determined dynamically.
!base_oam_props = %00100000|!gfx_page

; Which graphics to use for each phase.
pose_by_phase:
    dw gfx_rest ; Rest
    dw gfx_bend ; Load
    dw gfx_leap ; Jump
    dw gfx_bend ; Land
    dw gfx_dead ; Dead


;-------------------------------------------------------------------------------
; Init
;-------------------------------------------------------------------------------

; Sprite initialization.
init:
    LDA.b #$!phase_rest : STA !phase
    LDA #$00 : STA !is_fragile
    LDA #$00 : STA !has_eaten_key
    LDA !extra_bits,x : AND #$04 : LSR #2 : STA !direction,x
    RTL


;-------------------------------------------------------------------------------
; Main
;-------------------------------------------------------------------------------

; Sprite main routine.
main:
    PHB : PHK : PLB
    JSR render
    JSR update
    PLB : RTL


;-------------------------------------------------------------------------------
; Render
;-------------------------------------------------------------------------------

; Draw sprite on screen.
render:
    %GetDrawInfo()

    PHY                                 ;\
    LDA !phase,x : ASL : TAY            ;| Load the address of the correct
    LDA pose_by_phase,y : STA $04       ;| graphics table into $04-$05 for
    LDA pose_by_phase+1,y : STA $05     ;| later use
    PLY                                 ;/

    LDA !direction,x : STA $02          ;> Save direction before X is corrupted

    LDA !is_fragile,x : ASL             ;\
    CLC : ADC !has_eaten_key,x          ;| Offset to get correct palette (is_fragile * 2 + has_eaten_key)
    TAX                                 ;/

    LDA.b #!base_oam_props              ;\ Preload properties
    ORA .palettes,x                     ;| Palette depends on fragile and eaten key
    LDX $02 : ORA .flip_x,x : STA $03   ;/ Flip X varies depending on the direction

    LDX #$03                            ;> Loop 4 times (sprite is split into 4 parts)

-   PHX                                 ;> X tracks which quarter we are drawing

    LDA $00 : CLC : ADC .pos_x_offset,x ;\ X position
    PHY : LDY $02                       ;| The offset is based on the quarter
    CLC : ADC .x_offset,y : PLY         ;| and on the direction (required to
    STA !oam_pos_x,y                    ;/ center the sprite)

    LDA $01 : CLC : ADC .pos_y_offset,x ;\ Y position
    STA !oam_pos_y,y                    ;/ The offset is based on the quarter

    LDA $02 : BNE +                     ;\ Tile
    TXA : EOR #$01 : TAX : +            ;| Invert X horizontally depending on direction
    PHY : TXY : LDA ($04),y : PLY       ;| Retrieve the tile from the preloaded table
    STA !oam_tile,y                     ;/

    LDA $03 : STA !oam_props,y          ;> Properties

    INY #4                              ;> Go to next OAM slot

    PLX : DEX : BPL -                   ;> Loop or break if done

    LDX.w !sprite_index                 ;> Restore sprite index
    LDY #$02                            ;> 16x16 tiles
    LDA #$03                            ;> 4 tiles
    JSL $01B7B3|!bank                   ;> Finalize OAM

    RTS

.flip_x: db $40, $00
.palettes:
    db !palette_normal<<1, !palette_normal_key<<1
    db !palette_frail<<1,  !palette_frail_key<<1
.pos_x_offset: db $00, $10, $00, $10
.pos_y_offset: db $00+!y_offset, $00+!y_offset, $10+!y_offset, $10+!y_offset
.x_offset: db -!x_offset, !x_offset


;-------------------------------------------------------------------------------
; Update
;-------------------------------------------------------------------------------

; Update sprite behavior.
update:
    LDA !14C8,x : CMP #$08 : BEQ + : RTS ;> Return if status is not normal
+   LDA $9D : BEQ + : RTS               ;> Return if sprites are blocked
+

    ; Interaction
    LDA #$00 : %SubOffScreen()          ;> Kill sprite if offscreen
    JSL $01802A|!bank                   ;> Update position

    RTS
