;===============================================================================
; BOMB (GUNSTAR HEROES)
;===============================================================================

; A bomb from Gunstar Heroes.


;-------------------------------------------------------------------------------
; Configuration (extra bytes)
;-------------------------------------------------------------------------------

; Extra bit: What bomb graphics to use. If set (1), use `!bomb_gfx_2`, otherwise
; use `!bomb_gfx_1` (check the next section for the defines).

; Extra Byte 1: Bomb's behaviour, like when it should explode, or whether the
; the parachute opens or not. The format is %--PFMSGT:
; - `P`: If 1, when the bomb is falling its Y speed is limited to the value set
;   with `!parachute_speed`. Also, a parachute will be draw above the bomb.
; - `F`: If 1, the bomb explodes when touching Mario's fireballs.
; - `M`: If 1, the bomb explodes when touching the player (Mario), hurting them.
; - `S`: If 1, the bomb explodes when touching another sprite, killing it.
; - `G`: If 1, the bomb explodes when touching the ground. If this is not set,
;   the bomb looses all momentum when touching the ground (i.e., X and Y speed
;   are set to 0).
; - `T`: If 1, the bomb explodes when the timer (see `!bomb_timer`) goes off.
; - `-`: Unused, should be set to 0.

; Extra Byte 2: If the `T` flag in `Extra Byte 1` is set, the number of frames
; before the bomb explodes. This value decrements once each frame.

; Extra Byte 3: Initial X speed. $00-$7F are positive values (move right),
; $80-$FF are negative values (move left).

; Extra Byte 4: Initial Y speed. $00-$7F are positive values (move down),
; $80-$FF are negative values (move up).


;-------------------------------------------------------------------------------
; Configuration (defines)
;-------------------------------------------------------------------------------

; Sprite number for "gunstar_heroes_bomb_blast.asm", as defined in PIXI's
; "list.txt".
!blast_sprite = $10

; Offset applied to all graphics values. Possible values:
; - $00 = for SP1 and SP3
; - $80 = for SP2 and SP4
; N.B.: If you edit this value, make sure to change also its counterpart in
; "gunstar_heroes_bomb_blast.asm".
!gfx_offset = $80

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

; Graphics tiles to use for the bomb. The first value is used if the extra bit
; is not set, the second one if it is set. They should be values from $00-$7F,
; that is the index of the tile within the graphics file.
; Extra bit   0    1
bomb_gfx: db $20, $22

; Explosion sound and bank for playing the sound.
; Bank can be either $1DF9 or $1DFC. Check these links for the available sounds:
; - $1DF9: https://www.smwcentral.net/?p=memorymap&a=detail&game=smw&region=ram&detail=3312ee563909
; - $1DFC: https://www.smwcentral.net/?p=memorymap&a=detail&game=smw&region=ram&detail=294be88c9dcc
!explosion_sfx      = $09
!explosion_sfx_bank = $1DFC

; Tile to use for the parachute graphics. It should be a value from $00-$7F,
; that is the index of the tile within the graphics file.
!parachute_gfx = $04

; Max falling (vertical) speed the bomb can reach when falling with a parachute.
; It should be a value between $00 and $7F.
!parachute_speed = $10


;-------------------------------------------------------------------------------
; Defines (don't touch these)
;-------------------------------------------------------------------------------

; Aliases for readability in the code.
!bomb_mode  = !extra_byte_1
!bomb_timer = !sprite_misc_154c

; Utilities for checking the bomb's mode.
!bomb_mode_P = %00100000
!bomb_mode_F = %00010000
!bomb_mode_M = %00001000
!bomb_mode_S = %00000100
!bomb_mode_G = %00000010
!bomb_mode_T = %00000001

; Same as their counterparts in "gunstar_heroes_bomb_blast.asm" (here the
; defines are prefixed with "explosion_").
!explosion_oam_properties = !cluster_misc_0f4a
!explosion_center_x_l     = !cluster_misc_0f5e
!explosion_center_x_h     = !cluster_misc_0f72
!explosion_center_y_l     = !cluster_misc_0f86
!explosion_center_y_h     = !cluster_misc_0f9a
!explosion_motion         = !cluster_misc_1e52
!explosion_angle_l        = !cluster_misc_1e66
!explosion_angle_h        = !cluster_misc_1e7a
!explosion_frame          = !cluster_misc_1e8e


;-------------------------------------------------------------------------------
; Init
;-------------------------------------------------------------------------------

; Initialize sprite.
init:
    PHB : PHK : PLB

    LDA !extra_byte_2,x : STA !bomb_timer,x        ; Initialize timer
    LDA !extra_byte_3,x : STA !sprite_speed_x,x    ; Initialize X speed
    LDA !extra_byte_4,x : STA !sprite_speed_y,x    ; Initialize Y speed

    PLB : RTL


;-------------------------------------------------------------------------------
; Main
;-------------------------------------------------------------------------------

; Execute sprite's code.
main:
    PHB : PHK : PLB

    JSR render
    JSR update

    PLB : RTL


;-------------------------------------------------------------------------------
; Render
;-------------------------------------------------------------------------------

; Draw bomb.
render:
    %GetDrawInfo()

    LDA $00 : STA $0300|!addr,y                     ; X position
    LDA $01 : STA $0301|!addr,y                     ; Y position
    LDA !extra_bits,x : AND #$04 : LSR #2 : PHX     ; Tile number, depending on
    TAX : LDA bomb_gfx,x : CLC : ADC #!gfx_offset   ; extra bit being set or not,
    PLX : STA $0302|!addr,y                         ; plus the GFX offset
    LDA !sprite_oam_properties,x : ORA $64          ; Load CFG properties
    JSR alternate_palette : STA $0303|!addr,y       ; Tile properties

    LDA !bomb_mode,x : AND #!bomb_mode_P : BEQ ++   ; If parachute is visible...
    LDA !sprite_speed_y,x : BEQ ++ : BMI ++         ; ...and speed is positive (falling)
    INY #4                                          ; Next OAM slot
    LDA $00 : STA $0300|!addr,y                     ; X position (same as bomb)
    LDA $01 : SEC : SBC #$10 : STA $0301|!addr,y    ; Y position (one tile above bomb)
    LDA #!parachute_gfx+!gfx_offset : STA $0302|!addr,y ; Tile number
    LDA !sprite_oam_properties,x : ORA $64          ; Load CFG properties
    STA $0303|!addr,y                               ; Tile properties
    LDA #$01 : BRA +                                ; 2 tiles
++  LDA #$00                                        ; 1 tile

+   LDY #$02                                        ; 16x16
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
    LDA $13 : AND #!bomb_blink_interval : BEQ +     ; ...and every other frames...
    LDA !bomb_timer,x                               ; ...and the bomb timer is
    CMP #!bomb_blink_threshold : BCS +              ; lower than the blink threshold
    XBA : AND #%11110001                            ; Then replace current color
    ORA #!bomb_alternate_palette<<1 : RTS           ; palette with alternate one

+   XBA : RTS                                       ; Return properties with no changes


;-------------------------------------------------------------------------------
; Update
;-------------------------------------------------------------------------------

; Bomb's lifecycle.
update:
    LDA #$00 : %SubOffScreen()                      ; Kill sprite if offscreen
    LDA #$01 : STA $18B8|!addr                      ; Run cluster sprite code

    ; Game status
    LDA $9D : BEQ +                                 ; If game is frozen
    RTS                                             ; Then do nothing

    ; Falling speed check
+   LDA !bomb_mode,x : AND #!bomb_mode_P : BEQ +    ; If bomb has parachute...
    LDA !sprite_speed_y,x : BMI +                   ; ...and is falling...
    CMP #!parachute_speed : BCC +                   ; ...too fast
    LDA #!parachute_speed : STA !sprite_speed_y,x   ; Then limit falling speed

    ; Movement
+   JSL $01802A|!bank                               ; Move bomb

    ; Player interaction
    LDA !bomb_mode,x : AND #!bomb_mode_F : BEQ +    ; If bomb explodes on Mario fireball touch...
    %FireballContact() : BCC +                      ; ...and is touching fireball
    LDA #$00 : STA !extended_num+8,y                ; Then kill fireball...
    JSR explode : RTS                               ; ...and make the bomb explode

    ; Player interaction
+   LDA !bomb_mode,x : AND #!bomb_mode_M : BEQ +    ; If bomb explodes on player touch...
    JSL $01A7DC|!bank : BCC +                       ; ...and is touching player
    JSR explode : RTS                               ; Then make the bomb explode

    ; Sprite interaction
+   LDA !bomb_mode,x : AND #!bomb_mode_S : BEQ +    ; If bomb explodes on sprite touch...
    JSR check_sprite_interaction : BCC +            ; ...and is touching another sprite
    LDA #$00 : STA !sprite_status,y                 ; Then kill other sprite...
    JSR explode : RTS                               ; ...and make the bomb explode

    ; Ground interaction
+   LDA !sprite_blocked_status,x : AND #$04 : BEQ + ; If bomb is touching the ground
    STZ !sprite_speed_x,x : STZ !sprite_speed_y,x   ; Then set speed to zero
    LDA !bomb_mode,x : AND #!bomb_mode_G : BEQ +    ; If bomb explodes on ground touch
    JSR explode : RTS                               ; Then make the bomb explode

    ; Timer
+   LDA !bomb_mode,x : AND #!bomb_mode_T : BEQ +    ; If bomb explodes when timer goes off...
    LDA !bomb_timer,x : BNE +                       ; ...and timer is zero
    JSR explode : RTS                               ; Then make the bomb explode

    ; Return
+   RTS


;-------------------------------------------------------------------------------
; Check Sprite Interaction
;-------------------------------------------------------------------------------

; Check collision with all other sprites.
; @return Y: Index of the sprite colliding, $FF if not colliding.
; @return C: 1 if there is collision, 0 otherwise.
check_sprite_interaction:
    LDY #!SprSize                                   ; Sprite index
    JSL $03B69F|!bank                               ; Current sprite is clipping A
-   STY $00 : CPX $00 : BEQ ++                      ; Skip comparison with itself
    LDA !sprite_status,y : CMP #$08 : BCC ++        ; Skip non-active sprites
    LDA !sprite_tweaker_1686,y : AND #$08 : BNE ++  ; Skip sprites with no interaction
    PHX : TYX : JSL $03B6E5|!bank : PLX             ; Other sprite is clipping B
    JSL $03B72B|!bank : BCS +                       ; If no collision
++  DEY : BPL -                                     ; Then go to next sprite
    CLC : RTS                                       ; No contact
+   SEC : RTS                                       ; Contact


;-------------------------------------------------------------------------------
; Explode
;-------------------------------------------------------------------------------

; Make the bomb explode. This kills the bomb and spawns four blasts orbting the
; position of the bomb.
; Note that the values stored in $00-$05 are used by `SpawnClusterGeneric`.
explode:
    STZ !sprite_status,x                            ; Erase bomb sprite

    LDA #!explosion_sfx                             ; Play explosion sound
    STA !explosion_sfx_bank|!addr                   ;

    STZ $00 : STZ $01                               ; X and Y offset

    LDA !sprite_x_low,x : STA $02                   ; X position
    LDA !sprite_x_high,x : STA $03                  ;

    LDA !sprite_y_low,x : STA $04                   ; Y position
    LDA !sprite_y_high,x : STA $05                  ;

    LDA #$00 : STA $06 : LDA #$00 : STA $07         ; Angle $0000 (0)
    STZ $08                                         ; Inner, clockwise
    JSR spawn_explosion_blast

    LDA #$00 : STA $06 : LDA #$01 : STA $07         ; Angle $0100 (180)
    STZ $08                                         ; Inner, clockwise
    JSR spawn_explosion_blast

    LDA #$80 : STA $06 : LDA #$00 : STA $07         ; Angle $0080 (90)
    LDA #$01 : STA $08                              ; Outer, counter-clockwise
    JSR spawn_explosion_blast

    LDA #$80 : STA $06 : LDA #$01 : STA $07         ; Angle $0180 (270)
    LDA #$01 : STA $08                              ; Outer, counter-clockwise
    JSR spawn_explosion_blast

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
spawn_explosion_blast:
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
