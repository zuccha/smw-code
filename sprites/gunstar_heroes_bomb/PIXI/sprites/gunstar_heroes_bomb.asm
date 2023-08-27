;===============================================================================
; BOMB (GUNSTAR HEROES)
;===============================================================================

; A bomb from Gunstar Heroes.


;-------------------------------------------------------------------------------
; Configuration
;-------------------------------------------------------------------------------

; Sprite number for "gunstar_heroes_bomb_blast.asm", as defined in PIXI's
; "list.txt".
!blast_sprite = $10

; Color palette for the bomb if set on a timer. When the bomb is set to explode
; on a timer, it blinks changing color palette. The color palette alternates
; between the normal one (set with the "Palette" property in the JSON config
; file) and this one. Use value from $00 to $07 (sprite palette 0-7, aka
; palettes 8-F).
!bomb_alternate_palette = $03

; Interval, in frames, for alternating the color palette if the bomb is set on
; a timer.
!bomb_blink_interval = $04

; Threshold, in frames, under which the bomb starts blinking if the bomb is set
; on a timer. The default value corresponds to 2 seconds, assuming 60 FPS.
!bomb_blink_threshold = $78

; Explosion sound and bank for playing the sound.
; Bank can be either $1DF9 or $1DFC. Check these links for the available sounds:
; - $1DF9: https://www.smwcentral.net/?p=memorymap&a=detail&game=smw&region=ram&detail=3312ee563909
; - $1DFC: https://www.smwcentral.net/?p=memorymap&a=detail&game=smw&region=ram&detail=294be88c9dcc
!explosion_sfx      = $09
!explosion_sfx_bank = $1DFC

; Tile to use for the parachute graphics. It should be $00-$7F for SP1 and SP3,
; and $80-$FF for SP2 and SP4.
!parachute_gfx = $04


;-------------------------------------------------------------------------------
; Defines (don't touch these)
;-------------------------------------------------------------------------------

; Tile to use for the bomb graphics. It should be $00-$7F for SP1 and SP3,
; and $80-$FF for SP2 and SP4. With the included graphics file:
; - SP1/SP3: use $20 for the skull bomb, $22 for the pokéball bomb.
; - SP2/SP4: use $A0 for the skull bomb, $A2 for the pokéball bomb.
!bomb_gfx = !sprite_misc_151c

; When the bomb should explode, in the format %---FPSGT
; - `F`: If 1, the bomb explodes when touching Mario's fireballs.
; - `P`: If 1, the bomb explodes when touching player.
; - `S`: If 1, the bomb explodes when touching another sprite.
; - `G`: If 1, the bomb explodes when touching the ground.
; - `T`: If 1, the bomb explodes when the timer (see `!bomb_timer`) goes off.
; - `-`: Unused, should be set to 0.
!bomb_mode = !sprite_misc_1510
!bomb_mode_F = %00010000
!bomb_mode_P = %00001000
!bomb_mode_S = %00000100
!bomb_mode_G = %00000010
!bomb_mode_T = %00000001

; If the `T` flag of `!bomb_mode` is set, the number of frames before the bomb
; explodes. This value decrements once each frame.
!bomb_timer = !sprite_misc_154c

; Whether the parachute is visible or not. $00 = not visible, $01 = visible.
; The parachute will be removed once the bomb touches the ground.
!parachute_visibility = !sprite_misc_1504

; Same as their counterparts in "gunstar_heroes_bomb_blast.asm" (here the
; defines are prefixed with "explosion_").
!explosion_oam_properties    = !cluster_misc_0f4a
!explosion_center_x_l = !cluster_misc_0f5e
!explosion_center_x_h = !cluster_misc_0f72
!explosion_center_y_l = !cluster_misc_0f86
!explosion_center_y_h = !cluster_misc_0f9a
!explosion_motion     = !cluster_misc_1e52
!explosion_angle_l    = !cluster_misc_1e66
!explosion_angle_h    = !cluster_misc_1e7a
!explosion_frame      = !cluster_misc_1e8e


;-------------------------------------------------------------------------------
; Init
;-------------------------------------------------------------------------------

init:
    PHB : PHK : PLB

    LDA #$22 : STA !bomb_gfx,x
    LDA #%00001001 : STA !bomb_mode,x
    LDA #$FF : STA !bomb_timer,x
    LDA #$01 : STA !parachute_visibility,x
    LDA #$20 : STA !sprite_speed_x,x
    LDA #$C0 : STA !sprite_speed_y,x

    PLB : RTL


;-------------------------------------------------------------------------------
; Main
;-------------------------------------------------------------------------------

main:
    PHB : PHK : PLB

    JSR render
    JSR update

    PLB : RTL


;-------------------------------------------------------------------------------
; Update
;-------------------------------------------------------------------------------

update:
    LDA #$01 : STA $18B8|!addr                      ; Run cluster sprite code

    ; Game status
    LDA $9D : BEQ +                                 ; If game is frozen
    RTS                                             ; Then do nothing

    ; Movement
+   JSL $01802A|!bank                               ; Move bomb

    ; Player interaction
    LDA !bomb_mode,x : AND #!bomb_mode_F : BEQ +    ; If bomb explodes on Mario fireball touch...
    %FireballContact() : BCC +                      ; ...and is touching player
    LDA #$00 : STA !extended_num+8,y                ; Then kill fireball...
    JSR explode : RTS                               ; ...and make the bomb explode

    ; Player interaction
+   LDA !bomb_mode,x : AND #!bomb_mode_P : BEQ +    ; If bomb explodes on player touch...
    JSL $01A7DC|!bank : BCC +                       ; ...and is touching player
    JSR explode : RTS                               ; Then make the bomb explode

    ; Sprite interaction
+   LDA !bomb_mode,x : AND #!bomb_mode_S : BEQ +    ; If bomb explodes on sprite touch...
    BRA + ; TODO                                    ; ...and is touching another sprite
    JSR explode : RTS                               ; Then make the bomb explode

    ; Ground interaction
+   LDA !sprite_blocked_status,x : AND #$04 : BEQ + ; If bomb is touching the ground
    STZ !parachute_visibility,x                     ; Then remove parachute...
    STZ !sprite_speed_x,x : STZ !sprite_speed_y,x   ; ...and set speed to zero
    LDA !bomb_mode,x : AND #!bomb_mode_G : BEQ +    ; If bomb explodes on ground touch
    JSR explode : RTS                               ; Then make the bomb explode

    ; Timer
+   LDA !bomb_mode,x : AND #!bomb_mode_T : BEQ +    ; If bomb explodes when timer goes off...
    LDA !bomb_timer,x : BNE +                       ; ...and timer is zero
    JSR explode : RTS                               ; Then make the bomb explode

    ; Return
+   RTS


;-------------------------------------------------------------------------------
; Render
;-------------------------------------------------------------------------------

; Draw bomb.
render:
    %GetDrawInfo()

    LDA $00 : STA $0300|!addr,y                     ; X position
    LDA $01 : STA $0301|!addr,y                     ; Y position
    LDA !bomb_gfx,x : STA $0302|!addr,y             ; Tile number
    LDA !sprite_oam_properties,x : ORA $64          ; Load CFG properties
    JSR alternate_palette : STA $0303|!addr,y       ; Tile properties

    LDA !parachute_visibility,x : BEQ +             ; If parachute is visible...
    INY #4                                          ; Next OAM slot
    LDA $00 : STA $0300|!addr,y                     ; X position (same as bomb)
    LDA $01 : SEC : SBC #$10 : STA $0301|!addr,y    ; Y position (one tile above bomb)
    LDA #!parachute_gfx : STA $0302|!addr,y         ; Tile number
    LDA !sprite_oam_properties,x : ORA $64          ; Load CFG properties
    STA $0303|!addr,y                               ; Tile properties

+   LDA !parachute_visibility,x : LDY #$02          ; One-two tiles, 16x16
    JSL $01B7B3|!bank                               ; Finish OAM

    RTS


;-------------------------------------------------------------------------------
; Alternate Palette
;-------------------------------------------------------------------------------

; Every other X frames, alternate color palette if the bomb is on a timer.
; @param A: OAM properties.
; @return A: OAM properties with updated palette.
alternate_palette:
    XBA                                             ; Preserve properties

    LDA !bomb_mode,x : AND #!bomb_mode_T : BEQ +    ; If bomb is on a timer...
    LDA $13 : AND #!bomb_blink_interval : BEQ +     ; ...and every other two frames...
    LDA !bomb_timer,x                               ; ...and the bomb timer is
    CMP #!bomb_blink_threshold : BCS +              ; lower than the blink threshold
    XBA : AND #%11110001                            ; Then replace current color palette
    ORA #!bomb_alternate_palette<<1 : RTS           ; with alternate one

+   XBA : RTS                                       ; Return properties with no changes


;-------------------------------------------------------------------------------
; Explode
;-------------------------------------------------------------------------------

; Make the bomb explode. This kills the bomb and spawns four blasts orbting the
; position of the bomb.
explode:
    STZ !sprite_status,x                            ; Erase bomb sprite

    LDA #!explosion_sfx                             ; Play explosion sound
    STA !explosion_sfx_bank|!addr                   ;

    STZ $00 : STZ $01                               ; X and Y offset

    LDA !sprite_x_low,x : STA $02                   ; X position
    LDA !sprite_x_high,x : STA $03                  ;

    LDA !sprite_y_low,x : STA $04                   ; Y position
    LDA !sprite_y_high,x : STA $05                  ;

    LDA #!blast_sprite+!ClusterOffset : XBA         ; Explosion sprite

    LDA #$00 : STA $06 : LDA #$00 : STA $07         ; Angle $0000
    STZ $08                                         ; Inner, clockwise
    JSR spawn_explosion

    LDA #$00 : STA $06 : LDA #$01 : STA $07         ; Angle $0100
    STZ $08                                         ; Inner, clockwise
    JSR spawn_explosion

    LDA #$80 : STA $06 : LDA #$00 : STA $07         ; Angle $0080
    LDA #$01 : STA $08                              ; Outer, counter-clockwise
    JSR spawn_explosion

    LDA #$80 : STA $06 : LDA #$01 : STA $07         ; Angle $0180
    LDA #$01 : STA $08                              ; Outer, counter-clockwise
    JSR spawn_explosion

    RTS


;-------------------------------------------------------------------------------
; Spawn Explosion
;-------------------------------------------------------------------------------

; Spawn an explosion blast around the bomb.
; @param $00: X offset.
; @param $01: Y offset.
; @param $02-$03: X position.
; @param $04-$05: Y position.
; @param $06-$07: Initial rotation angle.
; @param $08: Motion. $00 = inner, clockwise; $01 = outer, counter-clockwise.
spawn_explosion:
    ; Spawn sprite
    LDA #!blast_sprite+!ClusterOffset : XBA
    %SpawnClusterGeneric()

    ; Set OAM properties
    LDA !sprite_oam_properties,x : ORA $64
    STA !explosion_oam_properties,y

    ; Set center (the explosion will rotate around this)
    LDA !sprite_x_low,x : STA !explosion_center_x_l,y
    LDA !sprite_x_high,x : STA !explosion_center_x_h,y
    LDA !sprite_y_low,x : STA !explosion_center_y_l,y
    LDA !sprite_y_high,x : STA !explosion_center_y_h,y

    ; Set rotation angle
    LDA $06 : STA !explosion_angle_l,y
    LDA $07 : STA !explosion_angle_h,y

    ; Set motion
    LDA $08 : STA !explosion_motion,y

    ; The animation frame starts from 0 (and it will increase up to 7)
    LDA #$00 : STA !explosion_frame,y

    ; Return
    RTS
