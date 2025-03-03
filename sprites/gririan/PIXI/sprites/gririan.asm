;===============================================================================
; GRIRIAN AND WOO
;===============================================================================

; Gririan/Woo enemy from Super Ghouls N' Ghosts.

; The Gririan/Woo can be in any of the following phases:
; - Idle: It's not moving, and turns to face the player. If it can walk, it will
;   start walking. If the player is close enough, the Gririan can start spitting
;   fire/ice to the player.
; - Walk: The Gririan walks towards the player. If an obstacle is in the way, it
;   will go back to idle. If the plkayer is close enough, the Gririan can start
;   spitting fire/ice to the player.
; - Begin spitting: The Gririan is preparing to spit fire/ice. In this phase it
;   doesn't walk, but it still turns to face the player.
; - Spit: The Gririan emits fire/ice projectiles in the player's direction. In
;   this phase it doesn't walk, but it still turns to face the player.
; - End spitting: The Gririan is cooling down after spitting fire/ice. In this
;   phase it doesn't walk, but it still turns to face the player.
; - Hurt: The Gririan has been hurt by the player (or an object thrown by the
;   player), it will be frozen, doesn't move, and doesn't turn to face the
;   player. It cannot be hurt again while in this phase, but the player can
;   still bounce on its head (like a Chuck). After a while the Gririan recovers
;   and goes back to idle.
; - Dead: The Gririan is dying and falling off screen. It doesn't interact with
;   anything and doesn't move.
;
; The Gririan can be hurt by the player jumping on its head or by throwing
; sprites at it. If hurt, it will stop doing anything and it will be stun for a
; while.
;
; The Gririan doesn't interacy with sprites, other than thrown ones.


;-------------------------------------------------------------------------------
; Configuration (extra bytes)
;-------------------------------------------------------------------------------

; Extra bit: Gririan or Woo. If set (1), use Woo (ice spitting), otherwise
; use Gririan (fire spitting).

; Extra Byte 1: Gririan's behavior, determining if it moves and/or spits fire/.
; The format is %------MS:
; - `M`: If 1, the Gririan moves towards the player, otherwise it always stands
;   still.
; - `S`: If 1, Gririan spits fire/ice if the player is close enough, otherwise it
;   never does.
; - `-`: Unused and reserved for future use, should be set to 0.


;-------------------------------------------------------------------------------
; Configuration (defines)
;-------------------------------------------------------------------------------

; Sprite number for "gririan_fire.asm", as defined in PIXI's "list.txt".
!fire_sprite = $10

; Walking speed
!walk_speed = $10

; How much health the Gririan/Woo has when spawned.
!max_health = $06                       ; $01-$80

; How much damage the Gririan/Woo takes.
!damage_player          = $02           ; When player jumps on its head
!damage_sprite          = $02           ; When hit by a throwable (throw block, shell, etc.)
!damage_yoshi_fireball  = $02           ; When hit by a fireball shot from Yoshi
!damage_player_fireball = $01           ; When hit by a fireball shot from Fire Mario

; How close (in pixels) the player must be for the Gririan to begin spitting
; fire/ice.
!spit_radius = $0040

; How often (in frames) the Gririan spawns a fire/ice ball during the spit phase.
!spit_frequency = $08

; Offset position, relative to the top-left corner of the left-facing Gririan,
; for determining where the fire/ice should spawn from (basically, the mouths
; position). The code will reflect this offset automatically for when the sprite
; is facing right.
!spit_offset_x = $01
!spit_offset_y = $07

; Speed of the projectile.
!spit_speed = $20

; Height (in pixels) of the head of the sprite, used for determining if the
; player is succesfully jumping on the sprite's head and hurting it.
!head_height = $04

; Speed applied to the player when it successfully bounces on the sprite's head.
; It should be a negative value ($FF-$80, where $FF = -1 and $80 = -128).
!bounce_speed = $B0

; Sound effect played when Gririan has been hurt.
; Check https://www.smwcentral.net/?p=memorymap&game=smw&region=ram&address=7E1DF9&context=
!hurt_sfx      = $28
!hurt_sfx_bank = $1DFC

; Sound effect played when Gririan dies.
; Check https://www.smwcentral.net/?p=memorymap&game=smw&region=ram&address=7E1DF9&context=
!dead_sfx      = $03
!dead_sfx_bank = $1DF9

; Sound effect played when Gririan spits fire.
; Check https://www.smwcentral.net/?p=memorymap&game=smw&region=ram&address=7E1DF9&context=
!fire_sfx      = $17
!fire_sfx_bank = $1DFC

; Sound effect played when Gririan spits ice.
; Check https://www.smwcentral.net/?p=memorymap&game=smw&region=ram&address=7E1DF9&context=
!ice_sfx      = $10
!ice_sfx_bank = $1DF9

; How many score points the Gririan rewards when killed. Check valid values here:
; https://www.smwcentral.net/?p=memorymap&a=detail&game=smw&region=ram&detail=befc37dd6e48
!score_points = $00

; Minimum duration (in frames) for each phase. For idle and walk, it means the
; sprite cannot start spitting fire unless this amount of time as passed since
; transitioning to this phase. For dead, after the timeout the sprite is erased.
; For other phases, this is their exact duration, after which they will
; automatically transition to the next.
; Every entry in the table corresponds to a different phase. In order, they are:
; idle, walk, begin spitting, spit, end spitting, hurt, dead.
phase_min_duration: db $20, $20, $40, $80, $20, $40, $80

; Color palettes to use for the Gririan and Woo respectively.
!palette_gririan = 3                     ; 0-7
!palette_woo    = 7                     ; 0-7

; Controls determining from which SP slot the game will take the graphics from.
; SP1: !gfx_page = 0; !gfx_offset = $00
; SP2: !gfx_page = 0; !gfx_offset = $80
; SP3: !gfx_page = 1; !gfx_offset = $00
; SP4: !gfx_page = 1; !gfx_offset = $80
!gfx_page   = 1                         ; 0 = SP1/SP2; 1 = SP3/SP4
!gfx_offset = $00                       ; $00 = SP1/SP3; $80 = SP2/SP4


;-------------------------------------------------------------------------------
; Animation
;-------------------------------------------------------------------------------

; How often (in frames) the animation frame changes for each phase.
; Every entry in the table corresponds to a different phase. In order, they are:
; idle, walk, begin spitting, spit, end spitting, hurt, dead.
animation_frequency: db $10, $18, $00, $00, $00, $00, $00

; How many animation frames are present for each phase.
; Every entry in the table corresponds to a different phase. In order, they are:
; idle, walk, begin spitting, spit, end spitting, hurt, dead.
animation_size: db $02, $02, $01, $01, $01, $01, $01

; Animation frames for every state. The amount of values for each entry should
; match the values defined in frame_count.
animation_idle: dw idle_frame_1, idle_frame_2
animation_walk: dw walk_frame_1, walk_frame_2
animation_spit_begin: dw spit_begin_frame
animation_spit_shoot: dw spit_shoot_frame
animation_spit_end: dw spit_end_frame
animation_hurt: dw hurt_frame
animation_dead: dw hurt_frame

; Frames for animations. Every frame is made of four 16x16 pixel tiles, the
; numbers are the positions of the tile in the GFX file. In order, they are:
; top-left, top-right, bottom-left, bottom-right.
idle_frame_1: db $00, $02, $20, $22
idle_frame_2: db $00, $02, $44, $22
walk_frame_1: db $00, $02, $40, $22
walk_frame_2: db $00, $02, $44, $42
spit_begin_frame: db $04, $06, $24, $26
spit_shoot_frame: db $08, $0A, $28, $2A
spit_end_frame: db $0C, $0E, $2C, $2E
hurt_frame: db $0C, $0E, $2C, $2E


;-------------------------------------------------------------------------------
; Defines
;-------------------------------------------------------------------------------

; Sprite index.
!sprite_index = $15E9|!addr

; Gririan's behavior.
!behavior = !extra_byte_1

; Blocked status, only updated when the sprite moves horizontally.
!sprite_blocked_horizontally = !sprite_misc_1626

; Health table and max health. We reduce max health here because it eases coding
; and having always positive numbers is easier for the user to understand.
!health     =  !sprite_misc_1504
!max_health #= !max_health-1

; Table for the phase in which the Gririan/Woo is in and aliases for making the
; code more readable.
!phase            = !sprite_misc_1528
!phase_idle       = 0
!phase_walk       = 1
!phase_spit_begin = 2
!phase_spit_shoot = 3
!phase_spit_end   = 4
!phase_hurt       = 5
!phase_dead       = 6

; Timer keeping track of how many frames need to pass before the sprite can
; transition to the next phase.
!phase_cooldown = !sprite_misc_160e

; How long before shoting the next fire/ice projectile when in spitting phase.
; Auto decrements itself.
!spit_cooldown = !sprite_misc_154c

; Table tracking sprite direction. 0 = right, 1 = left.
!direction = !sprite_misc_157c

; Aliases for OAM addresses.
!oam_pos_x = $0300|!addr
!oam_pos_y = $0301|!addr
!oam_tile  = $0302|!addr
!oam_props = $0303|!addr

; Basic OAM props, defining priority and page. Palette and flip X will be
; determined dynamically.
!base_oam_props = %00100000|!gfx_page

; Table storing the current animation frame.
!animation_frame = !sprite_misc_1594

; Table storing the animation timer, when the timer hits zero we switch to the
; next animation frame.
!animation_timer = !sprite_misc_1602

; Projectile tables, they should the same as those defined in "gririan_fire.asm".
!fire_type         = !cluster_misc_0f5e
!fire_phase        = !cluster_misc_0f4a
!fire_phase_timer  = !cluster_misc_0f72
!fire_speed_x      = !cluster_misc_1e66
!fire_speed_x_frac = !cluster_misc_1e8e
!fire_speed_y      = !cluster_misc_1e52
!fire_speed_y_frac = !cluster_misc_1e7a


;-------------------------------------------------------------------------------
; Utils
;-------------------------------------------------------------------------------

macro can_spit()
    LDA !behavior,x : AND #$01
endmacro

macro can_move()
    LDA !behavior,x : AND #$02
endmacro

macro play_sfx(sfx)
    if !<sfx>_sfx != 0 : LDA #!<sfx>_sfx : STA !<sfx>_sfx_bank|!addr
endmacro

macro load_type()
    LDA !extra_bits,x : AND #$04
endmacro

macro load_phase(phase)
    LDY.b #!phase_<phase> : JSR set_phase
endmacro


;-------------------------------------------------------------------------------
; Init
;-------------------------------------------------------------------------------

; Sprite initialization.
init:
    LDA.b #!max_health : STA !health,x  ;> Initialize health
    STZ !direction,x                    ;> Initialize direction (right)
    %load_phase(idle)                   ;> Set phase
    STZ !sprite_blocked_horizontally,x  ;> Sprite not blocked
    STZ !phase_cooldown,x               ;> No cooldown initially
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

    LDA !direction,x : STA $02          ;> Save direction

    JSR get_tile_table                  ;> Preload tile table

    LDA.b #!base_oam_props              ;\ Preload properties
    XBA : %load_type()                  ;| The palette varies depending on the
    LSR #2 : TAX : XBA : ORA .palette,x ;| extra bit being set (Woo) or not (Gririan)
    LDX $02 : ORA .flip_x,x : STA $03   ;/ Flip X varies depending on the direction

    LDX #$03                            ;> Loop 4 times (sprite is split into 4 parts)

-   PHX                                 ;> X tracks which quarter we are drawing

    LDA $00 : CLC : ADC .pos_x_offset,x ;\ X position
    STA !oam_pos_x,y                    ;/ The offset is based on the quarter

    LDA $01 : CLC : ADC .pos_y_offset,x ;\ Y position
    STA !oam_pos_y,y                    ;/ The offset is based on the quarter

    LDA $02 : BNE +                     ;\ Tile
    TXA : EOR #$01 : TAX : +            ;| Invert X horizontally depending on direction
    PHY : TXY : LDA ($04),y : PLY       ;| Retrieve the tile from the preloaded table
    if !gfx_offset > 0 : CLC : ADC.b #!gfx_offset ;| Add the graphics offset
    STA !oam_tile,y                     ;/

    LDA $03 : STA !oam_props,y          ;> Properties

    INY #4                              ;> Go to next OAM slot

    PLX : DEX : BPL -                   ;> Loop or break if done

    LDX.w !sprite_index                 ;> Restore sprite index
    LDY #$02                            ;> 16x16 tiles
    LDA #$03                            ;> 4 tiles
    JSL $01B7B3|!bank                   ;> Finalize OAM

    RTS

.pos_x_offset: db $00, $10, $00, $10
.pos_y_offset: db $00, $00, $10, $10
.palette: db !palette_gririan<<1, !palette_woo<<1
.flip_x: db $40, $00


;-------------------------------------------------------------------------------
; Get Tile Table
;-------------------------------------------------------------------------------

; Load the tiles table based on the sprite phase and its animation frame.
; @return $04-$05: Address of the tiles table to use.
; @destroy $06-$07.
get_tile_table:
    PHY

    LDA !phase,x : ASL : TAY            ;\ Retrieve the address of the animation
    LDA .animation,y : STA $06          ;| table for the current sprite phase
    LDA .animation+1,y : STA $07        ;/

    LDA !animation_frame,x : ASL : TAY  ;\ Retrieve the address of the animation
    LDA ($06),y : STA $04 : INY         ;| table for the current animation frame
    LDA ($06),y : STA $05               ;/

    PLY : RTS

.animation
    dw animation_idle, animation_walk
    dw animation_spit_begin, animation_spit_shoot, animation_spit_end
    dw animation_hurt, animation_dead


;-------------------------------------------------------------------------------
; Update
;-------------------------------------------------------------------------------

; Update sprite behavior.
update:
    LDA !14C8,x : CMP #$08 : BEQ + : RTS ;> Return if status is not normal
+   LDA $9D : BEQ + : RTS               ;> Return if sprites are blocked
+

    ; Direction
    LDA !phase,x                        ;\ If current phase is not hurt or dead,
    CMP.b #!phase_hurt : BCS +          ;| then update sprite direction
    %SubHorzPos()                       ;| always facing Mario
    TYA : STA !direction,x              ;/
+

    ; Cooldown
    LDA !phase_cooldown,x : BEQ +       ;\ Reduce cooldown if not already zero
    DEC !phase_cooldown,x               ;/
+

    ; Update based on phase
    LDA !phase,x : ASL : TAX            ;\ Update sprite based on which phase it
    JSR (update_by_phase,x)             ;/ is currently

    ; Interaction
    LDA !phase,x                        ;\ No interaction if dead
    CMP.b #!phase_dead : BCS +          ;/
    LDA #$00 : %SubOffScreen()          ;> Kill sprite if offscreen
    JSR interact_with_player : BCS +
    JSR interact_with_sprites : BCS +
    JSR interact_with_yoshi_fireballs : BCS +
    JSR interact_with_player_fireballs
+

    ; Update animation frame
    LDA !phase,x : TAY                  ;> Y = current phase
    DEC !animation_timer,x : BPL +      ;> If timer > 0, skip
    LDA animation_frequency,y           ;\ Reset animation timer
    STA !animation_timer,x              ;/
    INC !animation_frame,x              ;\ Go to next animation frame
    LDA !animation_frame,x              ;| and wrap to zero if animation frame
    CMP animation_size,y : BCC +        ;| exceeds the animation count
    STZ !animation_frame,x              ;/
+

    ; Return
    RTS

update_by_phase:
    dw update_idle, update_walk
    dw update_spit_begin, update_spit_shoot, update_spit_end
    dw update_hurt, update_dead

update_idle:
    LDX.w !sprite_index                 ;> Restore sprite index
    LDA !phase_cooldown,x : BNE +       ;> If cooldown is not over, do nothing
    JSR is_in_range : BCC ++            ;\ If player is in spitting range
    %load_phase(spit_begin)             ;| then begin spitting
    STZ !spit_cooldown,x                ;|
    BRA update_spit_begin               ;/
++  %can_move() : BEQ +                 ;\ If the sprite is can move,
    %load_phase(walk)                   ;| then start walking
    BRA update_walk                     ;/
+   JSL $01802A|!bank                   ;> Update position
    RTS

update_walk:
    LDX.w !sprite_index                 ;> Restore sprite index

    LDA !phase_cooldown,x : BNE +       ;\ If cooldown is over and the player is
    JSR is_in_range : BCC +             ;| in spitting range
    %load_phase(spit_begin)             ;| then begin spitting
    STZ !spit_cooldown,x                ;|
    BRA update_spit_begin               ;/

+   %SubHorzPos()                       ;\ If sprite sprite is far enough from
    LDA $0F : BNE +                     ;| the player, then walk
    LDA $0E : CMP #$08 : BCS +          ;| If the sprite is too close, then
    BRA ++                              ;/ stay idle

    LDY !direction,x                    ;\ Is sprite is not blocked in the
    LDA !sprite_blocked_horizontally,x  ;| direction it is headed, then keep
    AND .blocked_by_direction,y : BEQ + ;/ walking (skip ahead)
++  %load_phase(idle)                   ;> Stop walking
    JSL $01802A|!bank                   ;> Update position
    RTS

+   LDA.b #!walk_speed                  ;\ Set walking speed
    LDY !direction,x : BEQ +            ;| (invert the value if going left)
    EOR #$FF : INC                      ;|
+   STA !sprite_speed_x,x               ;/
    JSL $01802A|!bank                   ;> Update position
    LDA !sprite_blocked_status,x        ;\ Update blocked status
    STA !sprite_blocked_horizontally,x  ;/
    RTS

.blocked_by_direction: db $01, $02

update_spit_begin:
    LDX.w !sprite_index                 ;> Restore sprite index
    LDA !phase_cooldown,x : BNE +       ;\ If cooldown is over
    %load_phase(spit_shoot)             ;| then shoot fire/ice
    %load_type() : BEQ ++               ;| and, depending on being Gririan or Woo,
    %play_sfx(ice)                      ;| play the corresponding sound effect
    BRA update_spit_shoot               ;|
++  %play_sfx(fire)                     ;|
    BRA update_spit_shoot               ;/
+   JSL $01802A|!bank                   ;> Update position
    RTS

update_spit_shoot:
    LDX.w !sprite_index                 ;> Restore sprite index
    LDA !phase_cooldown,x : BNE +       ;\ If cooldown is over
    %load_phase(spit_end)               ;| then stop shooting
    BRA update_spit_end                 ;/
+   JSL $01802A|!bank                   ;> Update position
    LDA !spit_cooldown,x : BNE +        ;\ Spit a new projectile if cooldown is
    LDA.b #!spit_frequency              ;| over
    STA !spit_cooldown,x                ;|
    JSR spit                            ;/
    RTS

update_spit_end:
    LDX.w !sprite_index                 ;> Restore sprite index
    LDA !phase_cooldown,x : BNE +       ;\ If cooldown is over
    %load_phase(idle)                   ;| then go back to idle
    JMP update_idle                     ;/
+   JSL $01802A|!bank                   ;> Update position
    RTS

update_hurt:
    LDX.w !sprite_index                 ;> Restore sprite index
    LDA !phase_cooldown,x : BNE +       ;\ If cooldown is over
    %load_phase(idle)                   ;| then go back to idle
    JMP update_idle                     ;/
+   JSL $01802A|!bank                   ;> Update position
    RTS

update_dead:
    LDX.w !sprite_index                 ;> Restore sprite index
    LDA !phase_cooldown,x : BNE +       ;\ If cooldown is over,
    STZ !sprite_status,x                ;/ then erase sprite
+   JSL $01802A|!bank                   ;> Update position
    RTS


;-------------------------------------------------------------------------------
; Set Phase
;-------------------------------------------------------------------------------

; Set a phase and reset all generic tables.
; @param Y: The phase number.
; @param X: Sprite index.
set_phase:
    TYA : STA !phase,x                  ;> Initialize phase (idle)
    STZ !animation_frame,x              ;> Initialize animation frame
    LDA animation_frequency,y           ;\ Initialize animation timer
    STA !animation_timer,x              ;/
    LDA phase_min_duration,y            ;\ Initialize phase cooldown
    STA !phase_cooldown,x               ;/
    STZ !sprite_speed_x,x               ;> Zero speed
    RTS


;-------------------------------------------------------------------------------
; Hurt
;-------------------------------------------------------------------------------

; Hurt sprite.
; @param A: Amount of damage.
; @param $09: Kill horizontal speed.
; @param $0A: Kill vertical speed.
hurt:
    STA $08                                 ;> Save damage.
    LDA !phase,x                            ;\ If already hurt, the don't reduce
    CMP #!phase_hurt : BEQ .already_hurt    ;/ health
    LDA !health,x : SEC : SBC $08           ;\ Reduce health
    STA !health,x : BPL .alive              ;/

.dead
    %play_sfx(dead)                         ;> Play death sound effect
    %load_phase(dead)                       ;> Kill sprite
    LDA !1686,x : ORA #$80 : STA !1686,x    ;> Disable interaction with objects
    LDA $09 : STA !sprite_speed_x,x         ;\ Add some speed when killed to
    LDA $0A : STA !sprite_speed_y,x         ;/ (possibly) make a jump effect
if $00 < !score_points && !score_points < $16
    LDA $10 : STA $00 : LDA #$04 : STA $01  ;\ Spawn and award score
    LDA !sprite_x_low,x : STA $04           ;|
    LDA !sprite_x_high,x : STA $05          ;|
    LDA !sprite_y_low,x : STA $06           ;|
    LDA !sprite_y_high,x : STA $07          ;|
    LDA #!score_points : XBA                ;/
    %SpawnScoreGeneric()
endif
    RTS

.alive
    %load_phase(hurt)

.already_hurt
    %play_sfx(hurt)
    RTS


;-------------------------------------------------------------------------------
; Spawn Star
;-------------------------------------------------------------------------------

; Spawn a contact graphic star for when the player or another sprite collides
; with the Gririan.
macro spawn_star(pos_x_l, pos_x_h, pos_y_l, pos_y_h, offset_x, offset_y)
    LDA <offset_x> : STA $00            ;> X position
    LDA <offset_y> : STA $01            ;> Y position
    LDA #$04 : STA $02                  ;> Duration
    LDA <pos_x_l> : STA $04             ;\ X position
    LDA <pos_x_h> : STA $05             ;/
    LDA <pos_y_l> : STA $06             ;\ Y position
    LDA <pos_y_h> : STA $07             ;/
    LDA #$02 : XBA                      ;> Contact graphic
    %SpawnSmokeGeneric()                ;/
endmacro


;-------------------------------------------------------------------------------
; Interact with Player
;-------------------------------------------------------------------------------

; Interact with player. If player touches the top part of the sprite while the
; player is falling, the sprite is hurt, otherwise if the player touches the
; sprite, the player is hurt.
; @return C: 1 if sprite was hurt, 0 otherwise.
interact_with_player:
    JSL $03B69F|!bank                   ;> Get sprite clipping
    JSL $03B664|!bank                   ;> Get player clipping
    JSL $03B72B|!bank                   ;> Check for interaction
    BCC .return

.check_star
    LDA $1490|!addr : BEQ .check_fall   ;\ If player has a star,
    LDA $7B : BPL +                     ;\ then kill Gririan, making it jump
    LDA #$F0 : BRA ++                   ;| The jump's X speed is in the
+   LDA #$10                            ;| same direction as the player
++  STA $09                             ;|
    LDA #$D0 : STA $0A                  ;|
    JSR hurt_dead                       ;/ fall down
    RTS

.check_fall
    LDA $7D                             ;\ If player is falling, then check
    BEQ .hurt_player : BMI .hurt_player ;/ contact with head, else hurt player

.check_head
    LDA.b #!head_height : STA $07       ;> Sprite head height
    JSL $03B72B|!bank                   ;> Check for interaction
    BCC .hurt_player                    ;> If no interaction with head, hurt player

.hurt_sprite
    LDA.b #!bounce_speed : STA $7D      ;> Make player bounce
    %spawn_star($94, $95, $96, $97, #$00, #$10)
    STZ $09 : STZ $0A                   ;\ Hurt sprite, making it fall straight
    LDA.b #!damage_player : JSR hurt    ;/ down if killed
    SEC : RTS

.hurt_player
    JSL $00F5B7|!bank                   ;> Hurt player

.return
    CLC : RTS


;-------------------------------------------------------------------------------
; Interact with Sprites
;-------------------------------------------------------------------------------

; Interact with other sprites. If then Gririan is touched by a thrown sprite or
; by a fireball, it takes damage and destroys that sprite.
; @return C: 1 if sprite was hurt, 0 otherwise.
interact_with_sprites:
    LDY #!SprSize                               ;> Sprite index
    JSL $03B69F|!bank                           ;> Current sprite is clipping A
-   STY $00 : CPX $00 : BEQ ++                  ;> Skip comparison with itself
    LDA !sprite_status,y : CMP #$09 : BCC ++    ; Skip non-active sprites
    LDA !1686,y : AND #$08 : BNE ++             ;> Skip sprites with no interaction
    TYX : JSL $03B6E5|!bank : LDX !sprite_index ;> Other sprite is clipping B
    JSL $03B72B|!bank : BCS +                   ;\ If no collision
++  DEY : BPL -                                 ;/ Then go to next sprite
    CLC : RTS                                   ;> No contact
+   LDA #$00 : STA !sprite_status,y             ;> Destroy sprite
    %spawn_star("!sprite_x_low,y", "!sprite_x_high,y", "!sprite_y_low,y", "!sprite_y_high,y", #$00, #$00)
    LDA !sprite_speed_x,y : BPL +               ;\ Hurt Gririan, making it jump
    LDA #$F0 : BRA ++                           ;| if killed
+   LDA #$10                                    ;| The jump's X speed is in the
++  STA $09                                     ;| same direction as the sprite
    LDA #$D0 : STA $0A                          ;|
    LDA.b #!damage_sprite : JSR hurt            ;/
    SEC : RTS


;-------------------------------------------------------------------------------
; Interact with Yoshi Fireballs
;-------------------------------------------------------------------------------

; Interact with fireball shot by Yoshi.
; @return C: 1 if sprite was hurt, 0 otherwise.
interact_with_yoshi_fireballs:
    LDY #!ExtendedSize                          ;> Extended sprite index
    JSL $03B69F|!bank                           ;> Current sprite is clipping A
-   LDA !extended_num,y : CMP #$11 : BNE ++     ;> Skip if it's not a Yoshi fireball
    LDA !extended_x_low,y : STA $00             ;\ Fireball clipping
    LDA !extended_x_high,y : STA $08            ;|
    LDA !extended_y_low,y : STA $01             ;|
    LDA !extended_y_high,y : STA $09            ;|
    LDA #$10 : STA $02 : STA $03                ;/
    JSL $03B72B|!bank : BCS +                   ;\ If no collision
++  DEY : BPL -                                 ;/ Then go to next sprite
    CLC : RTS                                   ;> No contact
+   LDA #$00 : STA !sprite_status,y             ;> Destroy sprite
    STZ $09 : STZ $0A                           ;\ Hurt Gririan, making it fall
    LDA.b #!damage_yoshi_fireball : JSR hurt    ;/ down if killed
    SEC : RTS


;-------------------------------------------------------------------------------
; Interact with Player Fireballs
;-------------------------------------------------------------------------------

; Interact with fireballs shot by Fire Mario.
interact_with_player_fireballs:
    %FireballContact()                      ;\ If there is no contact,
    BCC .return                             ;/ then return

    LDA #$00 : STA !extended_num+8,y        ;\ Destroy fireball
    LDA #$01 : STA $1DF9|!addr              ;/ and play sound effect
    LDA !health,x                           ;\ Reduce health
    SEC : SBC.b #!damage_player_fireball    ;|
    STA !health,x                           ;/
    BPL .return                             ;\ If health reaches zero,
    STZ $09 : STZ $0A                       ;| then kill sprite and making it
    JSR hurt_dead                           ;/ fall straight

.return
    RTS


;-------------------------------------------------------------------------------
; Is in Range
;-------------------------------------------------------------------------------

; Check if player is in spitting range. Instead of a circle, we use a square,
; which makes calculations easier.
; @return C: 1 if the player is in range, 0 otherwise.
is_in_range:
    %can_spit() : BNE +                 ;\ If Gririan cannot spit, then player is
    CLC : RTS                           ;/ never in range

+   JSL $03B664|!bank                   ;> Get player clipping

    LDA !sprite_x_high,x : XBA          ;\ X origin for the spitting range hitbox
    LDA !sprite_x_low,x                 ;| Position of the Gririan plus half its
    REP #$20                            ;| width (to get the center), minus the
    CLC : ADC #$0010                    ;| spitting radius
    SEC : SBC.w #!spit_radius           ;|
    SEP #$20                            ;|
    STA $04 : XBA : STA $0A             ;/

    LDA !sprite_y_high,x : XBA          ;\ Y origin for the spitting range hitbox
    LDA !sprite_y_low,x                 ;| Position of the Gririan plus half its
    REP #$20                            ;| height (to get the center), minus the
    CLC : ADC #$0010                    ;| spitting radius
    SEC : SBC.w #!spit_radius           ;|
    SEP #$20                            ;|
    STA $05 : XBA : STA $0B             ;/

    LDA.b #!spit_radius*2               ;\ The size of the spitting range hitbox
    STA $06 : STA $07                   ;/ is twice the radius

    JSL $03B72B|!bank                   ;> Check for interaction
    RTS


;-------------------------------------------------------------------------------
; Spit
;-------------------------------------------------------------------------------

; Spit a fire/ice ball in player's direction.
spit:
    LDA #$01 : STA $18B8|!addr          ;> Run cluster sprite code

    LDA !direction,x : TAX              ;\ X offset
    LDA .spit_offset_x,x : STA $00      ;| It depends on the sprite's direction
    LDX.w !sprite_index                 ;/

    LDA.b #!spit_offset_y : STA $01     ;> Y offset

    LDA.b #!fire_sprite+!ClusterOffset
    %SpawnCluster()
    BCS .return

    %load_type() : LSR #2               ;\ 0 if no extra bit (Gririan, fire)
    STA !fire_type,y                    ;/ 1 if extra bit (Woo, ice)

    LDA #$00
    STA !fire_phase,y
    STA !fire_phase_timer,y
    STA !fire_speed_x_frac,y
    STA !fire_speed_y_frac,y

    STZ $01                             ;> Prepare X offset high byte to 0 for 16-bit load
    REP #$20
    LDA $04                             ;\ Delta X =
    CLC : ADC $00                       ;| (gririan pos x + spit offset x) -
    SEC : SBC $94                       ;| (player pos x + half player width)
    CLC : ADC.w #$0008                  ;|
    STA $00                             ;/
    LDA $06                             ;\ Delta Y =
    CLC : ADC.w #!spit_offset_y         ;| (gririan pos y + spit offset y) -
    SEC : SBC $96                       ;| (player pos y - half player height)
    SEC : SBC.w #$0008                  ;| Not adjusted for big Mario, but who
    STA $02                             ;/ cares, it's good enough
    SEP #$20

    LDA.b #!spit_speed
    %Aiming()

    LDA $00 : STA !fire_speed_x,y
    LDA $02 : STA !fire_speed_y,y

.return
    RTS

.spit_offset_x: db $10-!spit_offset_x, !spit_offset_x
