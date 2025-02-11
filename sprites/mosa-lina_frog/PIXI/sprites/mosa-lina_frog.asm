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

; Extra Byte 2: Jump X speed. Should alway be a positive value ($00-$7F).

; Extra Byte 3: Jump Y speed. Should alway be a positive value ($00-$7F).


;-------------------------------------------------------------------------------
; Configuration (behavior)
;-------------------------------------------------------------------------------

phase_durations:
    db $46 ; Idle
    db $28 ; Load jump
    db $28 ; Jump (should be 0, since it lasts indefinitely until the frog lands)
    db $14 ; Land (the frog crouches after landing)


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
gfx_leap: db $0C, $0E, $2C, $2E
gfx_dead: db $08, $0A, $28, $2A

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

; Which phase comes next, indexed by current phase.
next_phases: db 1, 2, 3, 0, 4

; Timer keeping track of how many frames need to pass before the sprite can
; transition to the next phase.
!phase_cooldown = !sprite_misc_1626

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

; Jump X speed.
!jump_speed_x = !extra_byte_2

; Jump Y speed.
!jump_speed_y = !extra_byte_3

; Aliases for OAM addresses.
!oam_pos_x = $0300|!addr
!oam_pos_y = $0301|!addr
!oam_tile  = $0302|!addr
!oam_props = $0303|!addr

; Basic OAM props, defining priority and page. Palette and flip X will be
; determined dynamically.
!base_oam_props = %00100000|!gfx_page

; Which graphics to use for each phase.
gfx_by_phase:
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
    LDA.b #!phase_rest : STA !phase,x : TAY
    LDA phase_durations,y : STA !phase_cooldown
    LDA #$00 : STA !is_fragile,x
    LDA #$00 : STA !has_eaten_key,x
    LDA !extra_bits,x : AND #$04 : LSR #2 : STA !direction,x
    LDA !jump_speed_y,x : EOR #$FF : INC A : STA !jump_speed_y,x
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
    LDA gfx_by_phase,y : STA $04        ;| graphics table into $04-$05 for
    LDA gfx_by_phase+1,y : STA $05      ;| later use
    PLY                                 ;/

    LDA !direction,x : STA $02          ;> Save direction before X is corrupted

    LDA !is_fragile,x : ASL             ;\
    CLC : ADC !has_eaten_key,x          ;| Offset to get correct palette
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
+   LDA $9D : BEQ .check_jump : RTS      ;> Return if sprites are blocked

.check_jump
    LDA !jump_speed_y,x                 ;\ Changing phase doesn't matter if the
    BEQ .interact                       ;/ frog cannot jump

.check_phase
    LDA !phase,x                         ;\
    CMP.b #!phase_jump : BEQ .jump_phase ;| Handle phases with special behaviors
    CMP.b #!phase_dead : BEQ .interact   ;| (not based on cooldown)
    BRA .other_phases                    ;/

.jump_phase
    LDA !sprite_blocked_status,x        ;\ If touching ground, then it's done
    AND #$04 : BNE .go_to_next_phase    ;| jumping, otherwise keep jumping and
    BRA .interact                       ;/ process interaction

.other_phases
    LDA !phase_cooldown,x               ;\ If cooldown is 0
    BEQ .go_to_next_phase               ;/ Then go to the next phase
    DEC !phase_cooldown,x               ;\ Else reduce cooldown...
    BRA .interact                       ;/ ...and process interaction

.go_to_next_phase
    LDY !phase,x                        ;\
    LDA next_phases,y : STA !phase,x    ;|
    TAY                                 ;| Update phase and reset cooldown
    LDA phase_durations,y               ;|
    STA !phase_cooldown,x               ;/

    CPY.b #!phase_jump : BEQ .start_jumping
    CPY.b #!phase_land : BEQ .start_landing
    BRA .interact

.start_jumping
    LDA !jump_speed_x,x                 ;\
    LDY !direction,x : BEQ +            ;|
    EOR #$FF : INC A                    ;| Set jump speeds, inverting X if frog
+   STA !sprite_speed_x,x               ;| is going left (Y is always upwards)
    LDA !jump_speed_y,x                 ;|
    STA !sprite_speed_y,x               ;/
    BRA .interact

.start_landing
    STZ !sprite_speed_x,x               ;\
    LDA !direction,x : EOR #$01         ;| Stop momentum and invert direction
    STA !direction,x                    ;/

.interact
    LDA #$00 : %SubOffScreen()          ;> Kill sprite if offscreen
    JSL $01802A|!bank                   ;> Update position

.return
    RTS
