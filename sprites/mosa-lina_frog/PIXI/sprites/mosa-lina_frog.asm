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

; Phase durations, in frames.
!phase_rest_duration = $46 ; Idle, waiting to jump
!phase_load_duration = $28 ; Preparing to jump (the frog crouches before landing)
!phase_land_duration = $04 ; Landing (the frog crouches after landing)

; Minimum amount of bounces the frog should do after landing. The frog will keep
; bouncing if its X speed is nonzero.
!min_bounces = 2

; `!damping_x` controls how fast the X speed will decrease after a jump.
; Every time the frog touches the ground after landing, its X speed will be
; halved `!damping_x` times.
!damping_x = 3

; `!damping_y` controls how much the frog will bounce in the air after any
; landing. When the frog bounces, its Y speed will be the jump Y speed (set via
; Extra Byte 2) halved `!damping_y` times for each time the frog landed after a
; jump.
!damping_y = 2

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
; Each variant has its base color palette and the color palette for when the
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

; Timer keeping track of how many frames need to pass before the sprite can
; transition to the next phase.
!phase_cooldown = !sprite_misc_1626

; Sprite direction. 0 = right, 1 = left.
!direction = !sprite_misc_157c

; Bounce count, how many times the frog landed after a jump/bounce.
!bounce_count = !sprite_misc_1510

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
    LDA.b #!phase_rest_duration : STA !phase_cooldown,x
    LDA #$00 : STA !is_fragile,x
    LDA #$00 : STA !has_eaten_key,x
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

.update_by_phase
    LDA !phase,x : ASL : TAX            ;\ Update sprite based on which phase it
    JSR (update_by_phase,x)             ;/ is currently

.interact
    LDA #$00 : %SubOffScreen()          ;> Kill sprite if offscreen
    JSL $01802A|!bank                   ;> Update position

.return
    RTS

; Update switch.
update_by_phase:
    dw update_rest, update_load, update_jump, update_land, update_dead

; Update rest.
update_rest:
    LDX !sprite_index

    LDA !phase_cooldown,x : BEQ .go_to_next_phase
    DEC !phase_cooldown,x : RTS

.go_to_next_phase
    LDA.b #!phase_load : STA !phase,x
    LDA.b #!phase_load_duration : STA !phase_cooldown,x
    RTS

; Update load.
update_load:
    LDX !sprite_index

    LDA !phase_cooldown,x : BEQ .go_to_next_phase
    DEC !phase_cooldown,x : RTS

.go_to_next_phase
    LDA.b #!phase_jump : STA !phase,x

    STZ !bounce_count,x                 ;> Reset number of bounces

    LDA !jump_speed_x,x                 ;\
    LDY !direction,x : BEQ +            ;|
    EOR #$FF : INC A                    ;| Set jump speeds, inverting X if frog
+   STA !sprite_speed_x,x               ;| is going left (Y is always upwards,
    LDA !jump_speed_y,x                 ;| so we turn the value negative)
    EOR #$FF : INC A                    ;|
    STA !sprite_speed_y,x               ;/

    RTS

; Update jump.
update_jump:
    LDX !sprite_index

    LDA !sprite_blocked_status,x        ;\ If touching ground, then it's done
    AND #$04 : BNE .go_to_next_phase    ;| jumping, otherwise keep jumping and
    RTS                                 ;/ continue

.go_to_next_phase
    LDA.b #!phase_land : STA !phase,x
    LDA.b #!phase_land_duration : STA !phase_cooldown,x

    LDA !sprite_speed_x,x : BPL +       ;\
    EOR #$FF : INC : LSR.b #!damping_x  ;| Slow down sprite by a factor,
    EOR #$FF : INC : BRA ++             ;| if the value is negative, we need to
+   LSR.b #!damping_x                   ;| make it positive before dividing
++  STA !sprite_speed_x,x               ;/

    LDA !bounce_count,x : BNE +         ;\
    LDA !direction,x : EOR #$01         ;| If it's the first landing after the
    STA !direction,x                    ;| jump, invert direction
+   INC !bounce_count,x                 ;/

    RTS

; Update land.
update_land:
    LDX !sprite_index

    LDA !phase_cooldown,x : BEQ .go_to_next_phase
    DEC !phase_cooldown,x : RTS

.go_to_next_phase
    LDA !bounce_count,x : CMP.b #!min_bounces : BCC .keep_bouncing
    LDA !sprite_speed_x,x : BEQ .stop_bouncing

.keep_bouncing
    LDA.b #!phase_jump : STA !phase,x
    LDA !jump_speed_y,x                 ;\
    LDY !bounce_count,x : DEY           ;| For every time we already bounced,
-   LSR.b #!damping_y : DEY : BPL -     ;| divide the Y jump speed by 8, then
    EOR #$FF : INC A                    ;| make it negative
    STA !sprite_speed_y,x               ;/
    RTS

.stop_bouncing
    LDA.b #!phase_rest : STA !phase,x
    LDA.b #!phase_rest_duration : STA !phase_cooldown,x
    RTS

; Update dead.
update_dead:
    RTS
