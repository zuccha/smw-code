;===============================================================================
; MOSA LINA - FROG
;===============================================================================

; Frog enemy from the Mona Lisa game.

; TODO:
; - Reset phase if sprite is falling (and not jumping).
; - Make platform effect less janky.
; - Die when touching specific blocks.
; - Become encumbered when eating specific sprites.
; - Spit out preserved sprite when dying.
; - Don't hurt player on contact when riding Yoshi.
; - Make sprite behaver properly when spit by Yoshi.


;-------------------------------------------------------------------------------
; Configuration (extra bytes)
;-------------------------------------------------------------------------------

; Extra bit: Initial direction. 0 = right, 1 = left.

; Extra Byte 1: The frog's behavior. The format is %-------i:
; - `i`: Controls whether the frog inverts directions after landing.
;       0 = don't invert direction
;       1 = invert direction (jump back and forth)

; Extra Byte 2: Jump X speed. Should alway be a positive value ($00-$7F).

; Extra Byte 3: Jump Y speed. Should alway be a positive value ($00-$7F).


;-------------------------------------------------------------------------------
; Configuration (behavior)
;-------------------------------------------------------------------------------

; Phase durations, in frames.
!phase_rest_duration = $46 ; Idle, waiting to jump
!phase_load_duration = $28 ; Preparing to jump (the frog crouches before jumping)
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

; List of sprites that if they get in contact with the frog, the frog dies
; (Mario can still stand on it). Add how many as you wish.
; N.B.: A sprite cannot be both deadly and tasty.
; The format is $-cnn:
;   - c: 0 = regular sprite, 1 = custom sprite.
;   - nn: Sprite number.
deadly_sprites:
    dw $0013, $0014
.end

; List of sprites that if they get in contact with the frog, the frog will eat
; them, making them disappear and becoming slow. Add how many as you wish.
; N.B.: A sprite cannot be both deadly and tasty.
; The format is $pcnn:
;   - p: 0 = swallow sprite, 1 = preserve sprite (it will be spit out if the
;     frog dies).
;   - c: 0 = regular sprite, 1 = custom sprite.
;   - nn: Sprite number.
tasty_sprites:
    dw $0074, $1080
.end


;-------------------------------------------------------------------------------
; Configuration (appearance)
;-------------------------------------------------------------------------------

; Which graphics page to use.
; - 0 = SP1/SP2
; - 1 = SP3/SP4
!gfx_page = 1

; Graphic tiles to use for each pose of the frog. Each tile is 16x16 pixels.
; Tiles are in this order: top-left, top-right, bottom-left, bottom-right.
gfx_rest: db $00, $02, $20, $22 ; Idle
gfx_load: db $04, $06, $24, $26 ; Preparing jump
gfx_leap: db $0C, $0E, $2C, $2E ; Leaping
gfx_land: db $04, $06, $24, $26 ; Landing
gfx_dead: db $08, $0A, $28, $2A ; Dead

; Define width and height (in pixels) of the sprite for each phase. These are
; used to determine the collision box of the sprite with Mario.
; In order: idle, preparing jump, leaping, landing, dead.
!widths = $13, $13, $11, $13, $13
!heights = $10, $0D, $12, $0D, $0D

; The Y offset (in pixels) needed to make the sprite slightly overlap with the
; ground, making it look like its belly is touching the ground, while its arms
; are slightly below.
!offset_y = $04

; Color palettes to use for the different variants of the frog.
; Each variant has its base color palette and the color palette for when the
; frog has eaten a key.
; Valid values are any of 0-7.
!palette_normal     = 5
!palette_normal_key = 2
!palette_frail      = 4
!palette_frail_key  = 2

; Different sound effects.
; Check https://www.smwcentral.net/?p=memorymap&game=smw&region=ram&address=7E1DF9&context=
; Do not add `|!addr` to the bank, it will be added automatically later.
!jump_sfx       = $13    ; Played when the frog first jumps in the air (not when bouncing)
!jump_sfx_bank  = $1DF9
!land_sfx       = $01    ; Played when the frog lands (also after a bounce)
!land_sfx_bank  = $1DF9
!death_sfx      = $07    ; Played when the frog dies (not falling off screen)
!death_sfx_bank = $1DF9
!eat_sfx        = $06    ; Played when the frog eats a sprite
!eat_sfx_bank   = $1DF9


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

; Whether the frog is frail (1) or not (0).
!is_frail = !sprite_misc_154c

; Whether the frog has eaten a sprite or not. Format is %cp-----e:
;   - c: 1 = eaten a custom sprite, 0 = eaten a regular sprite. Should always be
;     0 if nothing has been eaten.
;   - p: 1 = should preserve sprite and spit it when the frog dies, 0 = should
;     not spit the eaten sprite when the frog dies. Should always be 0 if
;     nothing has been eaten.
;   - e: 1 = has eaten a sprite, 0 = has not eaten a sprite.
!has_eaten = !sprite_misc_151c

; Sprite number of the eaten sprite (relevant only if has_eaten[p] is 1).
!eaten_sprite = !sprite_misc_160e

; Jump X speed.
!jump_speed_x = !extra_byte_2

; Jump Y speed.
!jump_speed_y = !extra_byte_3

; Track the number of pixels the frog moved horizontally during the current
; frame, used to move Mario when he's riding the sprite.
!x_movement = !sprite_misc_1528

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
    dw gfx_load ; Load
    dw gfx_leap ; Jump
    dw gfx_land ; Land
    dw gfx_dead ; Dead


;-------------------------------------------------------------------------------
; Macros & Functions
;-------------------------------------------------------------------------------

; Check whether the frog should invert directions after the first landing.
; @param X The sprite index.
; @return Z 1 if it should invert direction, 0 otherwise.
macro should_invert_direction()
    LDA !extra_byte_1,x : AND #$01
endmacro

; Play a sound effect. If the sound effect is zero, then nothing is played.
; @param <sfx> Name of the sound effect, corresponding `!<sfx>_sfx` and
; `!<sfx>_sfx_bank` defines must exist.
macro play_sfx(sfx)
    if !<sfx>_sfx != 0 : LDA #!<sfx>_sfx : STA !<sfx>_sfx_bank|!addr
endmacro

; Jump to a subroutine that RTSs as if it RTLs.
; @param <jml_addr> Address where you want execution to start.
; @param <rtl_addr> Address of an RTL statement in the same bank as <jml_addr>.
macro simulate_jsl(jml_addr, rtl_addr)
    PHB
    LDA.b #bank(<jml_addr>)|!bank8 : PHA : PLB
    PHK : PEA.w (?+)-1
    PEA.w <rtl_addr>-1
    JML <jml_addr>|!bank
?+  PLB
endmacro

; Utilities to calculate the offset of the collision box of the sprite relative
; to its top-left corner.
function cox(value) = (32-value)/2
function coy(value) = 32-value+!offset_y

; Define widths and x_offsets tables for calculating the sprite's clipping.
macro define_widths(rest, load, jump, land, dead)
widths:    db <rest>, <load>, <jump>, <land>, <dead>
x_offsets: db cox(<rest>), cox(<load>), cox(<jump>), cox(<land>), cox(<dead>)
endmacro

; Define heights and y_offsets tables for calculating the sprite's clipping.
macro define_heights(rest, load, jump, land, dead)
heights:   db <rest>, <load>, <jump>, <land>, <dead>
y_offsets: db coy(<rest>), coy(<load>), coy(<jump>), cox(<land>), coy(<dead>)
endmacro

; Generate clipping tables.
%define_widths(!widths)
%define_heights(!heights)


;-------------------------------------------------------------------------------
; Init
;-------------------------------------------------------------------------------

; Sprite initialization.
init:
    LDA.b #!phase_rest : STA !phase,x
    LDA.b #!phase_rest_duration : STA !phase_cooldown,x
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

    STZ $02 : LDA !sprite_status,x      ;\ Save whether frog is falling off
    CMP #$02 : BNE +                    ;| screen before X is overridden
    LDA #$01 : STA $02                  ;/

+   LDA !direction,x : STA $03          ;> Save direction before X is overridden

    PHY                                 ;\
    LDA !phase,x : ASL : TAY            ;| Load the address of the correct
    LDA gfx_by_phase,y : STA $04        ;| graphics table into $04-$05 for
    LDA gfx_by_phase+1,y : STA $05      ;| later use
    PLY                                 ;/

    LDA !is_frail,x : ASL               ;\
    BIT !has_eaten,x : BVC +            ;| Offset to get the correct palette:
    INC                                 ;|   2 * frail + spit_eaten_sprite
+   TAX                                 ;/

    LDA.b #!base_oam_props              ;\ Preload properties
    ORA .palettes,x                     ;| Palette depends on fragile and eaten key
    LDX $03 : ORA .flip_x,x             ;| Flip X varies depending on the direction
    LDX $02 : ORA .flip_y,x             ;| Flip Y varies depending on falling off screen
    STA $06                             ;/ Save everything for later

    LDX #$03                            ;> Loop 4 times (sprite is split into 4 parts)

-   PHX                                 ;> X tracks which quarter we are drawing

    LDA $00 : CLC : ADC .pos_offset_x,x ;\ X position
    STA !oam_pos_x,y                    ;/ The offset is based on the quarter

    LDA $01 : CLC : ADC .pos_offset_y,x ;\ Y position
    STA !oam_pos_y,y                    ;/ The offset is based on the quarter

    LDA $03 : BNE +                     ;\ Invert X horizontally depending on
    TXA : EOR #$01 : TAX                ;| direction
+   LDA $02 : BEQ +                     ;| Invert Y vertically depending on
    TXA : EOR #$02 : TAX                ;| falling off screen
+   PHY : TXY : LDA ($04),y : PLY       ;| Retrieve the tile from the preloaded
    STA !oam_tile,y                     ;/ table

    LDA $06 : STA !oam_props,y          ;> Properties

    INY #4                              ;> Go to next OAM slot

    PLX : DEX : BPL -                   ;> Loop or break if done

    LDX.w !sprite_index                 ;> Restore sprite index
    LDY #$02                            ;> 16x16 tiles
    LDA #$03                            ;> 4 tiles
    JSL $01B7B3|!bank                   ;> Finalize OAM

    RTS

.flip_x: db $40, $00
.flip_y: db $00, $80
.palettes:
    db !palette_normal<<1, !palette_normal_key<<1
    db !palette_frail<<1,  !palette_frail_key<<1
.pos_offset_x: db $00, $10, $00, $10
.pos_offset_y: db $00+!offset_y, $00+!offset_y, $10+!offset_y, $10+!offset_y


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

.handle_phase
    LDA !phase,x : ASL : TAX            ;\ Update sprite based on which phase it
    JSR (handle_phase,x)                ;/ is currently in

.interact
    LDA #$00 : %SubOffScreen()          ;> Kill sprite if offscreen
    JSR interact_with_player
    JSR interact_with_sprites
    JSL $01802A|!bank                   ;\ Update position and keep track by how
    LDA $1491|!addr : STA !x_movement,x ;/ many pixels the sprite moved

.return
    RTS


;-------------------------------------------------------------------------------
; Handle Phases
;-------------------------------------------------------------------------------

; Update switch.
handle_phase:
    dw handle_rest, handle_load, handle_jump, handle_land, handle_dead

; Resting frog.
handle_rest:
    LDX !sprite_index

    LDA !phase_cooldown,x : BEQ .start_jumping
    DEC !phase_cooldown,x : RTS

.start_jumping
    LDA.b #!phase_load : STA !phase,x
    LDA.b #!phase_load_duration : STA !phase_cooldown,x
    RTS

; Loading a jump.
handle_load:
    LDX !sprite_index

    LDA !phase_cooldown,x : BEQ .jump
    DEC !phase_cooldown,x : RTS

.jump
    LDA.b #!phase_jump : STA !phase,x

    STZ !bounce_count,x                 ;> Reset number of bounces

    LDA !jump_speed_x,x                 ;\
    LDY !direction,x : BEQ +            ;|
    EOR #$FF : INC A                    ;| Set jump speeds, inverting X if frog
+   STA !sprite_speed_x,x               ;| is going left (Y is always upwards,
    LDA !jump_speed_y,x                 ;| so we turn the value negative)
    EOR #$FF : INC A                    ;|
    STA !sprite_speed_y,x               ;/

    %play_sfx(jump)

    RTS

; Jumping.
handle_jump:
    LDX !sprite_index

    LDA !sprite_blocked_status,x        ;> Check if sprite is blocked in any direction
    BIT #$11 : BEQ +                    ;\ If it's blocked horizontally,
    STZ !sprite_speed_x,x               ;/ then stop horizontal momentum
+   BIT #$08 : BEQ +                    ;\ If it's blocked on top,
    STZ !sprite_speed_y,x               ;/ then stop ascending
+   AND #$04 : BEQ .return              ;\ If touching ground, then it should land

.land
    LDA.b #!phase_land : STA !phase,x
    LDA.b #!phase_land_duration : STA !phase_cooldown,x

    LDA !sprite_speed_x,x : BPL +       ;\
    EOR #$FF : INC : LSR.b #!damping_x  ;| Slow down sprite by a factor,
    EOR #$FF : INC : BRA ++             ;| if the value is negative, we need to
+   LSR.b #!damping_x                   ;| make it positive before dividing
++  STA !sprite_speed_x,x               ;/

    LDA !bounce_count,x : BNE +         ;\
    %should_invert_direction() : BEQ +  ;| If it's the first landing after the
    LDA !direction,x : EOR #$01         ;| jump and it should bounce back and
    STA !direction,x                    ;| forth, then invert direction
+   INC !bounce_count,x                 ;/

    %play_sfx(land)

.return
    RTS

; Landing a jump.
handle_land:
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
-   LSR.b #!damping_y : DEY : BPL -     ;| divide the Y jump speed by a factor,
    EOR #$FF : INC A                    ;| then make it negative
    STA !sprite_speed_y,x               ;/
    RTS

.stop_bouncing
    LDA.b #!phase_rest : STA !phase,x
    LDA.b #!phase_rest_duration : STA !phase_cooldown,x
    RTS

; Frog is dead.
handle_dead:
    LDX !sprite_index
    RTS


;-------------------------------------------------------------------------------
; Interact with Player
;-------------------------------------------------------------------------------

; Process interaction with player.
interact_with_player:
    LDY !phase,x

    LDA !sprite_x_low,x : CLC : ADC.b x_offsets,y : STA $04
    LDA !sprite_x_high,x : ADC #$00 : STA $0A

    LDA !sprite_y_low,x : CLC : ADC.b y_offsets,y : STA $05
    LDA !sprite_y_high,x : ADC #$00 : STA $0B

    LDA widths,y : STA $06
    LDA heights,y : STA $07

    JSL $03B664|!bank                   ;> Get player clipping
    JSL $03B72B|!bank : BCC .return     ;> Check for interaction

    LDA $1490|!addr : BEQ .alive        ;\ If making contact with star powered Mario
    LDA #!phase_dead : STA !phase,x     ;| then mark the sprite as dead and use the
    %simulate_jsl($01A847, $01A7E3)     ;/ original kill routine to actually kill it
    RTS

.alive
    ; Adapted version of $01B457
    LDA $05 : SEC : SBC $1C : STA $00   ;\ Check if Mario is on the top part of
    LDA $80 : CLC : ADC #$18            ;| the frog (within the top 24 pixels)
    CMP $00 : BPL .return               ;/
    LDA $7D : BMI .return               ;> If Mario is moving upwards, return
    LDA $77 : AND #$08 : BNE .return    ;> If Mario is blocked upwards, return
    LDA #$10 : STA $7D                  ;\ Set Mario's vertical speed and mark
    LDA #$01 : STA $1471|!addr          ;/ it as standing on top of a sprite
    LDA #$1F                            ;\
    LDY $187A|!addr : BEQ +             ;|
    LDA #$2F                            ;| Set Mario's Y position on top of the
+   STA $01                             ;| sprite, accounting for Yoshi
    LDA $05 : SEC : SBC $01 : STA $96   ;|
    LDA $0B : SBC #$00 : STA $97        ;/
    LDA $77 : AND #$03 : BNE .return    ;\
    LDY #$00                            ;|
    LDA !1528,x : BPL +                 ;| Move Mario horizontally alongside the
    DEY                                 ;| frog if he's not blocked horizontally
+   CLC : ADC $94 : STA $94             ;|
    TYA : ADC $95 : STA $95             ;/

.return
    RTS


;-------------------------------------------------------------------------------
; Interact with Sprites
;-------------------------------------------------------------------------------

; Process interaction with other sprites.
; @params $04/$0A Clipping X position (low/high).
; @params $05/$0B Clipping Y position (low/high).
; @params $06/$07 Clipping width and height.
interact_with_sprites:
    LDY #!SprSize                               ;> Sprite index
-   STY $00 : CPX $00 : BEQ .next               ;> Skip comparison with itself
    LDA !sprite_status,y : CMP #$08 : BCC .next ;> Skip non-active sprites
    TYX : JSL $03B6E5|!bank : LDX !sprite_index ;\ Skip if no collision
    JSL $03B72B|!bank : BCC .next               ;/ (other sprite is clipping B)
    LDA !sprite_status,y : CMP #$0A : BEQ .kill ;> Kill if hit by a thrown sprite
    JSR is_sprite_deadly : BCS .soft_kill       ;> Kill if in contact with a deadly sprite
    JSR is_sprite_tasty : BCS .eat              ;> Eat if in contact with a tasty sprite
.next
    DEY : BPL -                                 ;> Go to next sprite
    RTS                                         ;> No contact

.eat
    STZ !sprite_status,x                        ;> Kill eaten sprite
    LDA !new_sprite_num,x                       ;\
    LDX !sprite_index                           ;| Remember which sprite was eaten
    STA !eaten_sprite,x                         ;/
    LDA $00                                     ;\ %---p---c | Transform the
    CLC : ROR A : ROR A                         ;| %c----p-- | info byte so that
    BIT #$04 : BEQ +                            ;| if p = 1  | it matches the
    ORA #$40                                    ;| %c1---1-- | format stored in
    AND #$C0                                    ;| %c1------ | `!has_eaten`
+   ORA #$01 : STA !has_eaten,x                 ;/ %cp-----1 |
    %play_sfx(eat)
    RTS

.soft_kill
    LDA !phase,x : CMP.b #!phase_dead : BEQ +
    LDA.b #!phase_dead : STA !phase,x           ;\ Kill, but keep frog on screen
    %play_sfx(death)                            ;/ so Mario can still ride it
+   RTS

.kill
    LDA #!phase_dead : STA !phase,x             ;\ Kill frog and make it fall
    %simulate_jsl($01A642, $01A7E3)             ;/ off screen
    RTS

; Check if a sprite is deadly.
; @param Y Sprite index.
; @return C 1 if deadly, 0 otherwise.
is_sprite_deadly:
    TYX : LDA !extra_bits,x                     ;\ $00 = 0 regular sprite
    AND #$08 : LSR #3 : STA $00                 ;/ $00 = 1 custom sprite
    LDY.b #deadly_sprites_end-deadly_sprites-2  ;\
-   BMI .not_deadly                             ;| Iterate over deadly sprites
    LDA $00 : EOR deadly_sprites+1,y : BNE +    ;| If the sprite number matches
    LDA !new_sprite_num,x                       ;| and they are of the same type,
    CMP deadly_sprites,y : BEQ .deadly          ;| then it is deadly
+   DEY #2 : BRA -                              ;/

.not_deadly
    TXY : LDX !sprite_index
    CLC : RTS

.deadly
    TXY : LDX !sprite_index
    SEC : RTS


; Check if a sprite is tasty (it can be eaten).
; @param Y Sprite index.
; @return C 1 if tasty, 0 otherwise.
; @return $00 If sprite is tasty, info about the sprite in the format %---p---c:
;   - p: 0 = sprite should not be preserved, 1 = sprite should be preserved.
;   - c: 0 = sprite is not custom, 1 = sprite is custom.
is_sprite_tasty:
    TYX : LDA !extra_bits,x                     ;\ $00 = 0 regular sprite
    AND #$08 : LSR #3 : STA $00                 ;/ $00 = 1 custom sprite
    LDY.b #tasty_sprites_end-tasty_sprites-2    ;\
-   BMI .not_tasty                              ;| Iterate over tasty sprites
    LDA tasty_sprites+1,y : AND #$01            ;| If the sprite number matches
    EOR $00 : BNE +                             ;| and they are of the same type,
    LDA !new_sprite_num,x                       ;| then it is tasty
    CMP tasty_sprites,y : BEQ .tasty            ;|
+   DEY #2 : BRA -                              ;/

.not_tasty
    TXY : LDX !sprite_index
    CLC : RTS

.tasty
    LDA tasty_sprites+1,y : STA $00
    ; TXY : LDX !sprite_index                   ;> Don't restore X when eaten
    SEC : RTS
