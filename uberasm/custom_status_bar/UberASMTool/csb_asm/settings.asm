;===============================================================================
; SETTINGS
;===============================================================================

; Settings for controlling the visibility and behaviors of elements on the
; status bar.

; Each setting comes with:
; 1. A brief description of what it does.
; 2. A list of valid values it accepts.
; 3. The default value, i.e. the value it had prior to any modifications.
; Useful to know if you changed it and wanted to set it back to the initial
; value, but forgot what it was.
; 4. The RAM name that controls the setting. The name can be used in any
; UberASMTool's code to change the value of the setting; this is especially
; useful to edit the settings on a level basis. For instance:
;   LDA $01 : STA csb_ram_coins_visibility
; could be used to enable the coin indicator when globally set to not-visible.
; N.B.: It's `csb_ram_coins_visibility`, not `!csb_ram_coins_visibility` with an
; exclamation mark.
; N/A means "Not Available".


;-------------------------------------------------------------------------------
; General
;-------------------------------------------------------------------------------

; Whether to enable the status bar or not.
; When disabled, nothing will render and layer 3 is free.
; * Values:
;     0 = Hidden, and free layer 3 space
;     1 = Hidden
;     2 = Visible (vanilla)
; * Default: 2
; * RAM: csb_ram_status_bar_visibility
; N.B.: Visibility = 0 should be used only in levels with a layer 3 background,
; where you need the extra space at the top. You should set the value in the
; level init, and don't change it mid-level (e.g., via toggle block), since the
; status bar will reappear with the wrong colors. Also, don't use message boxes,
; or the status bar will reappear, but broken (why would you use message boxes
; in a layer 3 level anyway, right?).
; N.B.: When 0 and 1, status bar features will never work, even if the related
; !always_check_<feature> flag is turned on. For example, time will not tick
; even if !always_check_time = 1.
!status_bar_visibility = 2


;-------------------------------------------------------------------------------
; Bonus Stars
;-------------------------------------------------------------------------------

; Global setting for showing the bonus stars counter in the status bar.
; * Values:
;     0 = Hidden
;     1 = Visible (vanilla)
; * Default: 1
; * RAM: csb_ram_bonus_stars_visibility
!bonus_stars_visibility = 1

; Symbol in front of the bonus stars counter.
; The value is the position of the 8x8 tile in "GFX28".
; * Values: $00-$7F/$FC
; * Default: $64 (star)
; * RAM: csb_ram_bonus_stars_symbol
; If you are using the modified GFX28 bundled with this patch, you can also use
; $3F (star, alternative), which replaces the second part of the "TIME" text, no
; longer used.
!bonus_stars_symbol = $64

; Whether the bonus stars amount is always checked, even if the indicator is not
; shown in the status bar (!bonus_stars_visibility = 0). If bonus stars reach
; a specific threshold (default 100), the bonus game starts after the level.
; N.B.: This has not effect if !bonus_stars_visibility = 1.
; * Values:
;     0 = Don't check bonus stars if indicator is disabled in status bar
;     1 = Check bonus stars even if indicator is disabled in status bar
; * Default: 0
; * RAM: csb_ram_always_check_bonus_stars
!always_check_bonus_stars = 0

; Bonus stars limit. If reached, the bonus game is triggered.
; * Values: $00-$FF
; * Default: $64 (100) (vanilla)
; * RAM: csb_ram_bonus_stars_limit
!bonus_stars_limit = $64

; Whether the bonus game should start after the level if the bonus stars limit
; is reached.
; N.B.: This doesn't control whether the limit is reset, for that refer to
; !reset_bonus_stars_when_bonus_stars_limit_reached.
; * Values:
;     0 = Don't start bonus game
;     1 = Start bonus game (vanilla)
; * Default: 1
; * RAM: csb_ram_start_bonus_game_when_bonus_stars_limit_reached
!start_bonus_game_when_bonus_stars_limit_reached = 1

; Whether the game should reset the counter when the coin limit is reached.
; N.B.: This doesn't control whether the bonus game will start, for that refer
; to !start_bonus_game_when_bonus_stars_limit_reached.
; * Values:
;     0 = Don't reset counter
;     1 = Reset counter (vanilla)
; * Default: 1
; * RAM: csb_ram_reset_bonus_stars_when_bonus_stars_limit_reached
!reset_bonus_stars_when_bonus_stars_limit_reached = 1


;-------------------------------------------------------------------------------
; Coins
;-------------------------------------------------------------------------------

; Global setting for showing the coins counter in the status bar.
; * Values:
;     0 = Hidden
;     1 = Visible (vanilla)
;     2 = Visible if !coins_limit > 0
; * Default: 1
; * RAM: csb_ram_coins_visibility
!coins_visibility = 1

; Symbol in front of the coins counter.
; The value is the position of the 8x8 tile in "GFX28".
; * Values: $00-$7F/$FC
; * Default: $2E (coin)
; * RAM: csb_ram_coins_symbol
; If you are using the modified GFX28 bundled with this patch, you can also use
; $3B (star, alternative), which replaces part of the now unused item box.
!coins_symbol = $2E

; Whether the bonus stars amount is always checked, even if the indicator is not
; shown in the status bar (!coins_visibility = 0). If the bonus stars reach a
; specific threshold (default 100), the bonus game starts after the level.
; N.B.: This has not effect if !coins_visibility = 1.
; * Values:
;     0 = Don't check bonus stars if indicator is disabled in status bar
;     1 = Check bonus stars even if indicator is disabled in status bar
; * Default: 0
; * RAM: csb_ram_always_check_coins
!always_check_coins = 0

; Coin limit. When the limit is reached, the vanilla game adds a life.
; * Values: $00-$FF
; * Default: $64 (100) (vanilla)
; * RAM: csb_ram_coins_limit
!coins_limit = $64

; Whether the game should add a life when the coin limit is reached.
; N.B.: This doesn't control whether the limit is reset, for that refer to
; !reset_coins_when_coins_limit_reached.
; * Values:
;     0 = Don't increase coins
;     1 = Increase coins (vanilla)
; * Default: 1
; * RAM: csb_ram_add_life_when_coins_limit_reached
!add_life_when_coins_limit_reached = 1

; Whether the game should reset the counter when the coin limit is reached.
; N.B.: This doesn't control whether a life is added, for that refer to
; !add_life_when_coins_limit_reached.
; * Values:
;     0 = Don't reset counter
;     1 = Reset counter (vanilla)
; * Default: 1
; * RAM: csb_ram_reset_coins_when_coins_limit_reached
!reset_coins_when_coins_limit_reached = 1


;-------------------------------------------------------------------------------
; Lives
;-------------------------------------------------------------------------------

; Global setting for showing the lives counter in the status bar.
; * Values:
;     0 = Hidden
;     1 = Visible (vanilla)
; * Default: 1
; * RAM: csb_ram_lives_visibility
; N.B.: Disabling this will not prevent the player to lose lives and game over.
!lives_visibility = 1

; Symbol in front of the lives counter.
; The value is the position of the 8x8 tile in "GFX28".
; * Values: $00-$7F/$FC
; * Default: $26 (x)
; * RAM: csb_ram_lives_symbol
; If you are using the modified GFX28 bundled with this patch, you can also use
; $3E (heart), which replaces the second part of the "TIME" text, no longer used.
!lives_symbol = $26


;-------------------------------------------------------------------------------
; Time
;-------------------------------------------------------------------------------

; Global setting for showing the time counter in the status bar.
; * Values:
;     0 = Hidden
;     1 = Visible (vanilla)
;     2 = Visible if limit > 0 (limit set via Lunar Magic)
; * Default: 1
; * RAM: csb_ram_time_visibility
!time_visibility = 1

; Symbol in front of the time counter.
; The value is the position of the 8x8 tile in "GFX28".
; * Values: $00-$7F/$FC
; * Default: $76 (clock)
; * RAM: csb_ram_time_symbol
; If you are using the modified GFX28 bundled with this patch, the clock graphic
; has been lowered by 1 px, which is much better ;).
!time_symbol = $76

; Whether the time is always checked, even if the indicator is not shown in the
; status bar (!time_visibility = 0). If the timer reaches zero, the player will
; be killed.
; N.B.: This has not effect if !time_visibility = 1.
; * Values:
;     0 = Don't decrease timer
;     1 = Decrease timer
; * Default: 0
; * RAM: csb_ram_always_check_time
!always_check_time = 0

; Whether the game should kill the player when time runs out.
; * Values:
;     0 = Don't kill player
;     1 = Kill player (vanilla)
; * Default: 1
; * RAM: csb_ram_kill_player_when_time_runs_out
!kill_player_when_time_runs_out = 1

; Frequency for decreasing the timer. The timer will decrease every
; !time_frequency frames.
; * Values: $00-$FE
; * Default: $28 (vanilla)
; * RAM: csb_ram_time_frequency
; You can set this value to $3C (60) to make the timer decrease every second (if
; the game runs at 60 FPS).
; N.B.: Don't use $FF as it is a reserved value (why would you use that anyway).
!time_frequency = $28


;-------------------------------------------------------------------------------
; Dragon Coins
;-------------------------------------------------------------------------------

; Global setting for showing the dragon coins counter in the status bar.
; * Values:
;     0 = Hidden
;     1 = Visible
;     2 = Visible if not all coins have been collected (vanilla)
; * Default: 2
; * RAM: csb_ram_dragon_coins_visibility
!dragon_coins_visibility = 2

; Symbol for collected dragon coins.
; The value is the position of the 8x8 tile in "GFX28".
; * Values: $00-$7F/$FC
; * Default: $2E (coin)
; * RAM: csb_ram_dragon_coins_collected_symbol
!dragon_coins_collected_symbol = $2E

; Symbol for missing dragon coins.
; The value is the position of the 8x8 tile in "GFX28".
; * Values: $00-$7F/$FC
; * Default: $FC (empty)
; * RAM: csb_ram_dragon_coins_missing_symbol
; If you are using the modified GFX28 bundled with this patch, you can also use
; $3D (empty coin), which replaces the first part of the "TIME" text, no longer
; used.
!dragon_coins_missing_symbol = $FC

; Show custom graphics if all dragon coins have been collected. The graphics
; can be configured using !DragonCoinsCollectedGraphics.
; * Values:
;     0 = Disabled (vanilla)
;     - If !dragon_coins_visibility = 1: You will see 5 coins
;     - If !dragon_coins_visibility = 2: You will see nothing
;     1 = Enabled
;     - If !dragon_coins_visibility = 1: You will see !custom_dragon_coins_collected_graphics
;     - If !dragon_coins_visibility = 2: You will see !custom_dragon_coins_collected_graphics
;     if you collected the coins in the current level attempt, otherwise the
;     indicator will not be visible at all (it will not occupy the slot).
; * Default: 0
; * RAM: csb_ram_use_custom_dragon_coins_collected_graphics
!use_custom_dragon_coins_collected_graphics = 0

; List of graphics tiles to show when all coins have been collected in a level.
; This only applies if !use_custom_dragon_coins_collected_graphics = 1.
; Every element is a 8x8 tile in GFX28, $FC is an empty space.
; The list must have exactly 7 elements!
; * Values: $00-$7F/$FC x7
; * Default: $0A, $15, $15, $28, $FC, $FC, $FC ("ALL!   ")
; * RAM: csb_ram_custom_dragon_coins_collected_graphics
; If you are using the modified GFX28 bundled with this patch, you can also use
; `$2E, $2E, $2E, $2E, $2E, $3A, $FC`, where $2E are the coin symbol and $3A is
; a checkmark that replaces the corner of the item box in the graphics file.
!custom_dragon_coins_collected_graphics = $0A, $15, $15, $28, $FC, $FC, $FC


;-------------------------------------------------------------------------------
; Score
;-------------------------------------------------------------------------------

; Global setting for showing the score counter in the status bar.
; * Values:
;     0 = Hidden
;     1 = Visible (vanilla)
; * Default: 1
; * RAM: csb_ram_score_visibility
; N.B.: Even when hidden, the score will still be increased.
!score_visibility = 1


;-------------------------------------------------------------------------------
; Power Up
;-------------------------------------------------------------------------------

; Global setting for showing the power up in the item box in the status bar.
; * Values:
;     0 = Hidden, items can still be stored and dropped
;     1 = Visible (vanilla)
;     2 = Hidden, items cannot be stored and dropped
; * Default: 1
; * RAM: csb_ram_power_up_visibility
!power_up_visibility = 1

; X-coordinate for the powerup. This will modify both where the item is shown in
; the status bar and from where it drops (they are synced).
; * Values: $00-$FF
; * Default: $78 (vanilla)
; * RAM: csb_ram_power_up_position_x
!power_up_position_x = $78


;-------------------------------------------------------------------------------
; Group 1
;-------------------------------------------------------------------------------

; Group 1 consists of: Bonus Stars, Coins, Lives, and Time. Slot size: 4x1.
; For an explanation on how groups and slots work, check "README.md".

; Order in which group 1 elements fill available slots. Reorder the elements to
; change their priority (leftmost elements have the highest priority).
; * Values: !bonus_stars, !coins, !lives, !time
; * Default: !lives, !bonus_stars, !time, !coins
; * RAM: N/A
; N.B.: Make sure to leave a space after every comma!
!group1_order = !lives, !bonus_stars, !time, !coins

; Position of each slot where elements are displayed.
; The values are the RAM address for the status bar tiles (see "colors.asm").
; The address represents the first of the four tiles that the group 1 element
; occupies. The first tile is used for the symbol and the other three for the
; digits of the counter.
; N.B.: The color palette of each tile cannot be controlled dynamically. By
; default it is set to be GWWW, that is gold for the symbol (tile 0) and white
; for the digits (tiles 1-3). The palette is configured the same way for all
; slots in "colors.asm".
; * Values: $0EF9-$0F11/$0F15-$0F2C
; * Default: $0F11, $0F2C, $0F0C, $0F27
; * RAM: N/A
; N.B.: You don't need to worry about SA-1, use vanilla values here. The UberASM
; will automatically convert the addresses into SA-1.
; N.B.: Make sure to leave a space after every comma!
!group1_slots = $0F11, $0F2C, $0F0C, $0F27


;-------------------------------------------------------------------------------
; Group 2
;-------------------------------------------------------------------------------

; Group 2 consists of: Dragon Coins and Score. Slot size: 7x1.
; For an explanation on how groups and slots work, check "README.md".

; Order in which group 2 elements fill available slots. Reorder the elements to
; change their priority (leftmost elements have the highest priority).
; * Values: !dragon_coins, !score
; * Default: !score, !dragon_coins
; * RAM: N/A
; N.B.: Make sure to leave a space after every comma!
!group2_order = !score, !dragon_coins

; Position of each slot where elements are displayed.
; The values are the RAM address for the status bar tiles (see "colors.asm").
; The address represents the first of the six tiles that the group 2 element
; occupies.
; N.B.: The color palette of each tile cannot be controlled dynamically. By
; default, all seven tiles are set to gold. The palette is configured the same
; way for all slots in the "colors.asm".
; * Values: $0EF9-$0F0E/$0F15-$0F29
; * Default: $0EF9, $0F15
; * RAM: N/A
; N.B.: You don't need to worry about SA-1, use vanilla values here. The UberASM
; will automatically convert the addresses into SA-1.
; N.B.: Make sure to leave a space after every comma!
!group2_slots = $0EF9, $0F15


