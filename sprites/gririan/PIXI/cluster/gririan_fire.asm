;===============================================================================
; GRIRIAN'S AND WOO'S FIRE AND ICE
;===============================================================================

; Fire and ice projectiles spit by Gririan and Woo enemies from Super Ghouls N'
; Ghosts.

; The projectile has three phases, which can be customized to have different
; durations, graphics, and collisions. The collision with the player and the
; projectile displacement will be the same regardless of the phase.


;-------------------------------------------------------------------------------
; Configuration
;-------------------------------------------------------------------------------

; How long (in frames) every phase lasts.
!duration_1 = $08
!duration_2 = $10
!duration_3 = $10

; Radius of the hitbox colliding with the player for every phase.
!hitbox_radius_1 = $06
!hitbox_radius_2 = $0A
!hitbox_radius_3 = $0A

; Damage effect, what happens when a projectile touches the player.
; - 0 = Hurt player
; - 1 = Kill player
; - 2 = Stun player
!damage_fire = 0
!damage_ice  = 2

; Stun duration (in frames), if chosen as a damae option above.
!stun_duration = $40

; Sound effect to play when player is stunned.
; Check https://www.smwcentral.net/?p=memorymap&game=smw&region=ram&address=7E1DF9&context=
!stun_sfx      = $01
!stun_sfx_bank = $1DF9

; Color palettes to use for the fire and ice projectiles respectively.
!palette_fire = 2                       ; 0-7
!palette_ice  = 3                       ; 0-7

; Controls determining from which SP slot the game will take the graphics from.
; SP1: !gfx_page = 0; !gfx_offset = $00
; SP2: !gfx_page = 0; !gfx_offset = $80
; SP3: !gfx_page = 1; !gfx_offset = $00
; SP4: !gfx_page = 1; !gfx_offset = $80
!gfx_page   = 1                         ; 0 = SP1/SP2; 1 = SP3/SP4
!gfx_offset = $00                       ; $00 = SP1/SP3; $80 = SP2/SP4

; Which graphics tile to use for each phase and each type.
!tile_fire_1 = $5B
!tile_fire_2 = $4C
!tile_fire_3 = $4E
!tile_ice_1  = $7B
!tile_ice_2  = $6C
!tile_ice_3  = $6E

; Size (in pixels) of the tile to render, per phase. Only use:
; - $08 = 8x8 pixels
; - $10 = 16x16 pixels
!tile_size_1 = $08
!tile_size_2 = $10
!tile_size_3 = $10

; How often (in frames) to flip the sprite on the X axis. This should be a power
; of two ($00, $01, $02, $04, $08, $10, $20, $40, $80).
!flip_x_frequency = $04


;-------------------------------------------------------------------------------
; Defines
;-------------------------------------------------------------------------------

; Sprite index.
!sprite_index = $15E9|!addr

; Type of projectile. 0 is fire, 1 is ice.
!type = !cluster_misc_0f5e

; Current phase of the projectile (0-2).
!phase = !cluster_misc_0f4a

; How many phases are there.
!phase_count = 3

; How much time left until the projectile should transition to the next phase.
!phase_timer = !cluster_misc_0f72

; Speed tables.
!speed_x      = !cluster_misc_1e66
!speed_x_frac = !cluster_misc_1e8e
!speed_y      = !cluster_misc_1e52
!speed_y_frac = !cluster_misc_1e7a

; Aliases for OAM addresses.
!oam_pos_x = $0200|!addr
!oam_pos_y = $0201|!addr
!oam_tile  = $0202|!addr
!oam_props = $0203|!addr


;-------------------------------------------------------------------------------
; Utils
;-------------------------------------------------------------------------------

; Play sound effect.
macro play_sfx(sfx)
    if !<sfx>_sfx != 0 : LDA #!<sfx>_sfx : STA !<sfx>_sfx_bank|!addr
endmacro

; Move sprite horizontally or vertically.
; Adapted from original routine $02FFA3.
; @param <axis>: Either x or y.
macro move_on_axis(axis)
    LDA !speed_<axis>,x : ASL #4
    CLC : ADC !speed_<axis>_frac,x
    STA !speed_<axis>_frac,x
    PHP
    LDA !speed_<axis>,x : LSR #4
    CMP #$08
    LDY #$00
    BCC +
    ORA #$F0 : DEY
+   PLP
    ADC !cluster_<axis>_low,x
    STA !cluster_<axis>_low,x
    TYA
    ADC !cluster_<axis>_high,x
    STA !cluster_<axis>_high,x
endmacro


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
    %ClusterGetDrawInfo() : BCS +
    RTS
+

    LDA !type,x : STA $06               ;\ Preload type and phase, we will need them
    LDA !phase,x : STA $07 : TAX        ;/ later for figuring out tile and palette

    LDA $00 : CLC : ADC .offset,x       ;\ X position, add an offset when the
    STA !oam_pos_x,y                    ;/ projectile is small (8x8)

    LDA $01 : CLC : ADC .offset,x       ;\ Y position, add an offset when the
    STA !oam_pos_y,y                    ;/ projectile is small (8x8)

    LDA .tile,x : STA !oam_tile,y       ;> Tile

    LDA #%00100000|!gfx_page : XBA      ;> Base properties
    LDA $13 : AND #!flip_x_frequency    ;\ Flip X every some frames
    BEQ + : XBA : EOR #$40 : BRA ++     ;|
+   XBA                                 ;/
++  LDX $06 : ORA .palette,x            ;> Palette (indexed by type)
    STA !oam_props,y

    TXA : ASL : CLC : ADC $06           ;\ Tile (indexed by type * 3 + phase)
    CLC : ADC $07 : TAX                 ;|
    LDA .tile,x : STA !oam_tile,y       ;/

    TYA : LSR #2 : TAY : LDX $07        ;\ Set tile size and X position's high
    LDA .tile_size,x : ORA $02          ;| bit
    STA $0420|!addr,y                   ;/

    LDX.w !sprite_index                 ;> Restore sprite index

    RTS

.palette: db !palette_fire<<1, !palette_ice<<1
.tile:
    db !tile_fire_1+!gfx_offset, !tile_fire_2+!gfx_offset, !tile_fire_3+!gfx_offset
    db !tile_ice_1+!gfx_offset, !tile_ice_2+!gfx_offset, !tile_ice_3+!gfx_offset
.tile_size: db (!tile_size_1-8)/4, (!tile_size_2-8)/4, (!tile_size_3-8)/4
.offset: db (16-!tile_size_1)/2, (16-!tile_size_2)/2, (16-!tile_size_3)/2


;-------------------------------------------------------------------------------
; Update
;-------------------------------------------------------------------------------

; Update sprite.
update:
    LDA $9D : BEQ + : RTS               ;> Return if sprites are blocked

+   LDA !phase,x : TAY                  ;> Load phase
    LDA !phase_timer,x                  ;\ If timer didn't reach limit,
    CMP .duration,y : BCC .tick         ;/ then continue normally

.go_to_next_phase
    STZ !phase_timer,x                  ;> Reset timer
    INC !phase,x                        ;> Next phase
    LDA !phase,x : TAY                  ;> Reload phase

    CPY.b #!phase_count : BCC .move     ;\ If this is not the last phase,
    STZ !cluster_num,x                  ;/ then kill sprite
    RTS

.tick
    INC !phase_timer,x                  ;> Increase timer

.move
    %move_on_axis("x")
    %move_on_axis("y")

.interact
    LDA .hitbox_radius,y                ;\ Prepare hitbox radius for 16-bit
    STA $00 : STZ $01                   ;/ calculation

    LDA !cluster_x_high,x : XBA         ;\ Sprite clipping X position
    LDA !cluster_x_low,x                ;| Sprite position...
    REP #$20                            ;|
    SEC : SBC $00                       ;| ...minus the hitbox radius
    CLC : ADC #$0008                    ;| ...plus half a tile
    SEP #$20                            ;|
    STA $04 : XBA : STA $0A             ;/

    LDA !cluster_y_high,x : XBA         ;\ Sprite clipping Y position
    LDA !cluster_y_low,x                ;| Sprite position...
    REP #$20                            ;|
    SEC : SBC $00                       ;| ...minus the hitbox radius
    CLC : ADC #$0008                    ;| ...plus half a tile
    SEP #$20                            ;|
    STA $05 : XBA : STA $0B             ;/

    LDA $00 : ASL : STA $06 : STA $07   ;> Size is twice the radius

    JSL $03B664|!bank                   ;> Get player clipping
    JSL $03B72B|!bank : BCC .return     ;> Check for contact

    LDA !type,x : TAY : LDA .damage,y
    CMP #$02 : BEQ .stun_player
    CMP #$01 : BEQ .kill_player

.hurt_player
    JSL $00F5B7|!bank                   ;> Hurt player
    RTS

.kill_player
    JSL $00F606|!bank                   ;> Kill player
    RTS

.stun_player
    LDA #!stun_duration                 ;\ Stun player
    STA $18BD|!addr                     ;/
    %play_sfx(stun)                     ;> Play stun sound effect

.return
    RTS

.damage: db !damage_fire, !damage_ice
.duration: db !duration_1, !duration_2, !duration_3
.hitbox_radius: db !hitbox_radius_1, !hitbox_radius_2, !hitbox_radius_3
