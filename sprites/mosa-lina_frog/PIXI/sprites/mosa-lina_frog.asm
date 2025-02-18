;===============================================================================
; MOSA LINA - FROG
;===============================================================================

; Frog from the Mona Lisa game.

; The frog is a jumping sprite that can jump back and forth or in one direction.
; Mario can ride the frog like a platform.
; If the frog touches a deadly sprite (configured below) it dies (it no longer
; jumps), but Mario can still walk on it.
; If the frog touches a thrown sprite (e.g., shell) or if Mario touches it while
; having star power or sliding down a slope, it dies for good falling offscreen.
; If the frog touches a tasty sprite (configured below) it eats it and becomes
; slow (it jumps about half the way). Tasty sprites can be configured to stay in
; the frog's mouth, it will spit them out when it dies. If the frog eats more
; than one sprite, the last one eaten is the one that counts.
; The frog has a frail variant. frail frogs will be using a different color
; palette and die to cape spin, Mario's fireballs, and spin jumps.

; TODO:
; - Feat: Die when touching specific blocks.
; - Feat: Eat specific blocks.
; - Fix: Use proper clipping for block interactions.


;-------------------------------------------------------------------------------
; Configuration (extra bytes)
;-------------------------------------------------------------------------------

; Extra bit: Frog type. 0 = regular, 1 = frail.

; Extra Byte 1: The frog's behavior. The format is %------di:
; - `i`: Controls whether the frog inverts directions after landing.
;       0 = don't invert direction
;       1 = invert direction (jump back and forth)
; - `d`: Initial direction.
;       0 = right
;       1 = left

; Extra Byte 2: Regular jump X speed. Alway positive ($00-$7F).

; Extra Byte 3: Regular jump Y speed. Alway positive ($00-$7F).


;-------------------------------------------------------------------------------
; Configuration (behavior)
;-------------------------------------------------------------------------------

; Phase durations, in frames.
!phase_rest_duration = $46 ; Idle, waiting to jump
!phase_load_duration = $28 ; Preparing to jump (the frog crouches before jumping)
!phase_land_duration = $04 ; Landing (the frog crouches after landing)

; Minimum amount of bounces the frog should do after landing. The frog will keep
; bouncing if its X speed is nonzero.
!min_bounces = 1

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
; The format is $-cnn:
;   - c: 0 = regular sprite, 1 = custom sprite.
;   - nn: Sprite number.
; N.B.: A sprite cannot be both deadly and tasty.
deadly_sprites:
    dw $0013, $0014
.end

; List of sprites that if they get in contact with the frog, the frog will eat
; them, making them disappear and becoming slow. Add how many as you wish.
; The format is $pcnn:
;   - p: 0 = swallow sprite, 1 = preserve sprite (it will be spit out if the
;     frog dies).
;   - c: 0 = regular sprite, 1 = custom sprite.
;   - nn: Sprite number.
; N.B.: A sprite cannot be both deadly and tasty.
; N.B.: When spitting a sprite, properties of the eaten sprite (extra bit, extra
; bytes, etc.) won't be restored. This is particularly relevant for custom
; sprites.
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
gfx_load: db $40, $42, $60, $62 ; Preparing jump
gfx_leap: db $4C, $4E, $6C, $6E ; Leaping
gfx_land: db $40, $42, $60, $62 ; Landing
gfx_dead: db $48, $4A, $68, $6A ; Dead

; Define clipping hitbox of the frog for each of its phases. Values are
; specified in pixels.
; In order: idle (I), preparing jump (P), jump/leap(J), landing (L), dead (D).
;              I    P    J    L    D
widths:    db $12, $12, $10, $12, $12
heights:   db $10, $0C, $12, $0C, $0D
x_offsets: db $07, $07, $08, $07, $07
y_offsets: db $0C, $10, $04, $10, $0F

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

; Mark frog as dead and spit eaten item.
; @param X The sprite index.
macro kill_frog()
    LDA #!phase_dead : STA !phase,x
    JSR spit_eaten_sprite
endmacro

; Check whether the frog should invert directions after the first landing.
; @param X The sprite index.
; @return Z 1 if it should invert direction, 0 otherwise.
macro should_invert_direction()
    LDA !extra_byte_1,x : AND #$01
endmacro

; Check whether the frog is frail or not.
; @param X The sprite index.
; @return Z 1 if not frail, 0 otherwise.
; @return A $04 if frail, $00 otherwise.
macro is_frail()
    LDA !extra_bits,x : AND #$04
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


;-------------------------------------------------------------------------------
; Init
;-------------------------------------------------------------------------------

; Sprite initialization.
init:
    LDA.b #!phase_rest : STA !phase,x       ;\
    LDA.b #!phase_rest_duration             ;| Initialize phase
    STA !phase_cooldown,x                   ;/

    LDA !extra_byte_1,x                     ;\
    AND #$02 : LSR                          ;| Initialize direction
    STA !direction,x                        ;/

    LDA #$40 : STA !sprite_speed_y,x        ;\ Mark as grounded initially so
    LDA !sprite_blocked_status,x : ORA #$04 ;| that it doesn't make the bounce
    STA !sprite_blocked_status,x            ;/ when spawning

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

    %is_frail() : LSR                   ;\
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
    LDA $9D : BNE .return                   ;> Return if sprites are blocked
    LDA !sprite_status,x : CMP #$08         ;\ If status is 8 the frog is alive,
    BCC .return                             ;| if it's 9 or A it has been spat
    BEQ .check_fall                         ;/ by Yoshi

.spat_by_yoshi
    LDA #$08 : STA !sprite_status,x

.check_fall
    LDA !sprite_blocked_status,x            ;\
    AND #$04 : BNE .handle_phase            ;| If frog is not jumping, but it's
    LDA !phase,x                            ;| not grounded, then pretend as if
    CMP.b #!phase_jump : BEQ .handle_phase  ;| it was jumping (probably it's)
    LDA.b #!phase_jump : STA !phase,x       ;| falling)
    STZ !bounce_count,x                     ;/

.handle_phase
    LDA !phase,x : ASL : TAX                ;\ Update sprite based on which
    JSR (handle_phase,x)                    ;/ phase it is currently in

.interact
    LDA #$00 : %SubOffScreen()              ;> Kill sprite if offscreen
    JSR get_frog_clipping_a
    JSR interact_with_player
    JSR interact_with_sprites
    JSR interact_with_fireballs

    JSL $01802A|!bank                       ;\ Update position and keep track by
    LDA $1491|!addr : STA !x_movement,x     ;/ how many pixels the sprite moved

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

.check_jump
    LDA !jump_speed_y,x                 ;\ Never jump if Y jump speed is 0
    BEQ .return                         ;/

.check_cooldown
    LDA !phase_cooldown,x : BEQ .start_jumping
    DEC !phase_cooldown,x : RTS

.start_jumping
    LDA.b #!phase_load : STA !phase,x
    LDA.b #!phase_load_duration : STA !phase_cooldown,x

.return
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
+   AND #$04 : BEQ .return              ;> If touching ground, then it should land

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
    LDA !bounce_count,x : CMP.b #!min_bounces+1 : BCC .keep_bouncing
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
; @param X Frog's sprite index.
; @params $04/$0A Clipping X position (low/high).
; @params $05/$0B Clipping Y position (low/high).
; @params $06/$07 Clipping width and height.
interact_with_player:
.check_cape_spin
    %is_frail() : BEQ .check_normal     ;\
    LDA $19 : CMP #$02 : BNE .check_normal ;| Frog is frail, Mario has cape and
    LDA $14A6|!addr : ORA $140D|!addr   ;| he's spinning or spin jumping
    BEQ .check_normal                   ;/
    LDA $13E9|!addr : SEC : SBC #$02 : STA $00 ;\
    LDA $13EA|!addr : SBC #$00 : STA $08;|
    LDA $13EB|!addr : STA $01           ;| Get cape clipping
    LDA $13EC|!addr : STA $09           ;|
    LDA #$14 : STA $02                  ;|
    LDA #$10 : STA $03                  ;/
    JSL $03B72B|!bank                   ;\ Check for interaction
    BCC .check_normal                   ;/

.cape_spin_kill
.slide_kill
.star_kill
    %SubHorzPos() : %kill_frog()        ;\ Kill frog, make it fall off screen,
    %Star()                             ;/ give points, spawn collision star, etc.
    RTS

.check_normal
    JSL $03B664|!bank                   ;> Get player clipping
    JSL $03B72B|!bank                   ;\ Check for interaction
    BCS .check_star_or_slide            ;/
    RTS

.check_star_or_slide
    LDA $1490|!addr : BNE .star_kill    ;> Check if Mario has star power
    LDA $13ED|!addr : BNE .slide_kill   ;> Check if Mario is sliding down a slope

.survive_1
    LDA #$06 : STA $07                  ;\
    JSL $03B72B|!bank                   ;| Check for contact with the head of the frog
    BCC .return                         ;/
    LDA $7D : BMI .return               ;> If Mario is moving upwards, return
    LDA $77 : AND #$08 : BNE .return    ;> If Mario is blocked upwards, return
    %is_frail() : BEQ .survive_2        ;\ If frog is frail and Mario spin jumps
    LDA $140D|!addr : BEQ .survive_2    ;/ kill the frog, else it survives

.spin_kill
    %SubHorzPos() : %kill_frog()        ;> Kill frog
    LDA #$04 : STA !sprite_status,x     ;> Status = killed by smoke
    LDA #$1F : STA !1540,x              ;> Set smoke duration timer
    LDA !sprite_x_low,x : CLC : ADC #$08;\
    STA !sprite_x_low,x                 ;|
    LDA !sprite_x_high,x : ADC #$00     ;|
    STA !sprite_x_high,x                ;| Move sprite 8 pixels right and down
    LDA !sprite_y_low,x : CLC : ADC #$08;| so that the smoke will be centered
    STA !sprite_y_low,x                 ;| (the frog is 32x32, the smoke 16x16)
    LDA !sprite_y_high,x : ADC #$00     ;|
    STA !sprite_y_high,x                ;/
    JSL $07FC3B|!bank                   ;> Span collision stars
    LDA #$08 : STA $1DF9|!addr          ;> Play puff sound effect
    STZ $140D|!addr                     ;> Interrupt spin jump

.return
    LDY !phase,x                        ;\ Restore the clipping height of the
    LDA heights,y : STA $07             ;/ frog
    RTS

.survive_2
+   LDA #$10 : STA $7D                  ;\ Set Mario's vertical speed and mark
    LDA #$01 : STA $1471|!addr          ;/ it as standing on top of a sprite
    LDA #$1F-!offset_y                  ;\
    LDY $187A|!addr : BEQ +             ;|
    LDA #$2F-!offset_y                  ;| Set Mario's Y position on top of the
+   STA $0D                             ;| sprite, accounting for Yoshi
    LDA $05 : SEC : SBC $0D : STA $96   ;|
    LDA $0B : SBC #$00 : STA $97        ;/
    LDA $77 : AND #$03 : BNE .return    ;\
    LDY #$00                            ;|
    LDA !1528,x : BPL +                 ;| Move Mario horizontally alongside the
    DEY                                 ;| frog if he's not blocked horizontally
+   CLC : ADC $94 : STA $94             ;|
    TYA : ADC $95 : STA $95             ;/
    BRA .return


;-------------------------------------------------------------------------------
; Interact with Sprites
;-------------------------------------------------------------------------------

; Process interaction with other sprites.
; @param X Frog's sprite index.
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
    LDA !phase,x : CMP #!phase_dead : BEQ .next ;> Skip ahead if frog is already dead
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
    LDA !has_eaten,x : BNE +                    ;\
    LDA !jump_speed_x,x : LSR #2 : STA $01      ;|
    LDA !jump_speed_x,x : SEC : SBC $01         ;| If it's the first time eating
    STA !jump_speed_x,x                         ;| then reduce its jumping speed
    LDA !jump_speed_y,x : LSR #2 : STA $01      ;| by 1/4: speed = speed - speed * 0.25
    LDA !jump_speed_y,x : SEC : SBC $01         ;|
    STA !jump_speed_y,x                         ;/
+   LDA $00                                     ;\ %---p---c | Transform the
    CLC : ROR A : ROR A                         ;| %c----p-- | info byte so that
    BIT #$04 : BEQ +                            ;| if p = 1  | it matches the
    ORA #$40                                    ;| %c1---1-- | format stored in
    AND #$C0                                    ;| %c1------ | `!has_eaten`
+   ORA #$01 : STA !has_eaten,x                 ;/ %cp-----1 |
    %play_sfx(eat)
    RTS

.soft_kill
    LDA !phase,x : CMP.b #!phase_dead : BEQ +   ;\ If not already dead, kill the
    JSR sub_horz_pos_sprite : %kill_frog()      ;| the frog, but keep it on screen,
    %play_sfx(death)                            ;/ so Mario can still ride it
+   RTS

.kill
    JSR sub_horz_pos_sprite : %kill_frog()      ;\ Kill frog and make it fall
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


;-------------------------------------------------------------------------------
; Interact with Fireballs
;-------------------------------------------------------------------------------

; Interact with fireballs shot by Mario or by Yoshi.
; We need to redefine this routine because (1) the default routine that handles
; fireballs interaction doesn't use the custom clipping, (2) we need to spit the
; eaten sprite if the frog is frail.
; @param X Frog's sprite index.
; @params $04/$0A Clipping X position (low/high).
; @params $05/$0B Clipping Y position (low/high).
; @params $06/$07 Clipping width and height.
interact_with_fireballs:
    JSR get_frog_clipping_a
    LDY.b #!ExtendedSize+2-1                ;> !ExtendedSize doesn't include Mario's fireballs, so we add 2
.check_fireball
    LDA !extended_num,y                     ;\
    CMP #$05 : BEQ +                        ;| If not a fireball, check next
    CMP #$11 : BNE .next                    ;/
+   LDA !extended_x_low,y                   ;\ Clipping X displacement, low
    SEC : SBC #$02 : STA $00                ;/
    LDA !extended_x_high,y                  ;\ Clipping X displacement, high
    SBC #$00 : STA $08                      ;/
    LDA !extended_y_low,y                   ;\ Clipping Y displacement, low
    SEC : SBC #$04 : STA $01                ;/
    LDA !extended_y_high,y                  ;\ Clipping X displacement, high
    SBC #$00 : STA $09                      ;/
    LDA #$0C : STA $02                      ;> Clipping width
    LDA #$13 : STA $03                      ;> Clipping height
    JSL $03B72B|!bank : BCS .contact        ;> Check for collision
.next
    DEY : BPL .check_fireball               ;> Go to next
    RTS

.contact
    LDA !extended_num,y                     ;\ If not Mario's fireball (i.e.,
    CMP #$05 : BNE +                        ;/ Yoshi's fireball)
    LDA #$01 : STA !extended_num,y          ;> Turn fireball into smoke
    LDA #$0F : STA !extended_timer,y        ;> Smoke duration timer
    LDA #$01 : STA $1DF9|!addr              ;/ Play sound effect

+   %is_frail() : BEQ .return
    LDA !extended_x_low,y                   ;\
    SEC : SBC !sprite_x_low,x               ;|
    LDA !extended_x_high,y                  ;|
    SBC !sprite_x_high,x                    ;| SubHorzPos with extended sprite
    BPL +                                   ;|
    LDY #$01 : BRA ++                       ;|
+   LDY #$00                                ;/
++  %kill_frog()
    LDA #$03 : STA $1DF9|!addr              ;> Play sound effect
    LDA #$21 : STA !sprite_num,x            ;\
    LDA #$08 : STA !sprite_status,x         ;| Turn frog into a coin
    JSL $07F7D2|!bank                       ;/
    LDA #$D0 : STA !sprite_speed_y,x        ;> Set some vertical speed
    %SubHorzPos() : TYA                     ;\ Face direction opposite of Mario
    EOR #$01 : STA !sprite_misc_157c,x      ;/

.return
    RTS


;-------------------------------------------------------------------------------
; Spit Eaten Sprite
;-------------------------------------------------------------------------------

; Check if the frog has eaten a sprite and spit it.
; Don't use the %SpawnSprite() macro because it doesn't account for sprite
; memory when allocating the sprite slot.
; N.B.: When spitting a sprite, extra bit, extra bytes, and any other property
; won't be restored.
; @param X The frog sprite index.
; @param Y 1 if the sprite should be spat on the right, 0 on the left.
spit_eaten_sprite:
    TYA : XBA                                   ;> Preserve spit direction
    BIT !has_eaten,x : BVC .return              ;> Skip if there is no preserved sprite

    JSL $02A9E4|!bank                           ;\ Look for a sprite empty slot
    BMI .return                                 ;/ If none is found, don't spit

    CLC : LDA !has_eaten,x : BPL + : SEC        ;> C = 0 for regular, C = 1 for custom
+   LDA !eaten_sprite,x : TYX : STA !sprite_num,x ;> Set sprite number
    JSL $07F7D2|!bank                           ;> Reset sprite tables
    BCC +                                       ;\
    LDA !sprite_num,x : STA !new_sprite_num,x   ;| Custom sprite: set number,
    JSL $0187A7|!bank                           ;| reset tables, set extra bit
    LDA #$08 : STA !extra_bits,x                ;/
+   LDA #$01 : STA !sprite_status,x             ;> Make sprite alive

    TXY : LDX !sprite_index

    LDA !sprite_x_low,x : STA !sprite_x_low,y   ;\
    LDA !sprite_x_high,x : STA !sprite_x_high,y ;| Same position as the frog
    LDA !sprite_y_low,x : STA !sprite_y_low,y   ;| (not centered, but eh)
    LDA !sprite_y_high,x : STA !sprite_y_high,y ;/

    XBA : BEQ +                                 ;\
    LDA #$10 : STA !sprite_speed_x,y : BRA ++   ;| Spit sprite with some speed
+   LDA #$F0 : STA !sprite_speed_x,y            ;| depending on killing source
++  LDA #$F0 : STA !sprite_speed_y,y            ;/

    STZ !has_eaten,x                            ;> Frog no longer has eaten sprite

.return
    RTS


;-------------------------------------------------------------------------------
; Get Frog Clipping A
;-------------------------------------------------------------------------------

; Get the frog's clipping for collision detection.
; @param X The frog sprite index.
get_frog_clipping_a:
    LDY !phase,x
    LDA !sprite_x_low,x : CLC : ADC x_offsets,y : STA $04
    LDA !sprite_x_high,x : ADC #$00 : STA $0A
    LDA !sprite_y_low,x : CLC : ADC y_offsets,y : STA $05
    LDA !sprite_y_high,x : ADC #$00 : STA $0B
    LDA widths,y : STA $06
    LDA heights,y : STA $07
    RTS


;-------------------------------------------------------------------------------
; Sub Horz Pos Sprite
;-------------------------------------------------------------------------------

; Check whether sprite Y is on right or left of sprite X.
; @param X Frog sprite index.
; @param Y Other sprite index.
; @return Y 1 if the other sprite (Y) is on the left of the frog (X), else 0.
sub_horz_pos_sprite:
    LDA !sprite_x_low,y : SEC : SBC !sprite_x_low,x
    LDA !sprite_x_high,y : SBC !sprite_x_high,x
    BPL .right
.left
    LDY #$01 : RTS
.right
    LDY #$00 : RTS
