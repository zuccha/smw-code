;===============================================================================
; RAM
;===============================================================================

; Prepare RAM addresses for usage in the code.
; The patch required 33 bytes of free contiguous RAM. Its position can be
; configured in `settings.asm`.


;-------------------------------------------------------------------------------
; Utils
;-------------------------------------------------------------------------------

; Define an address with a given size.
; This will produce a label accessible with `ram_<name>`. For instance:
;   define_ram_size(enable_status_bar, $01)
; will make `ram_enable_status_bar` usable in the code as follows:
;   LDA $01 : STA ram_enable_status_bar ; Enable status bar
macro define_ram(offset, name)
    !ram_<name> = !freeram_address+<offset>
    base !ram_<name>
        ram_<name>:
    base off
endmacro


;-------------------------------------------------------------------------------
; Definitions
;-------------------------------------------------------------------------------

; Define one address for (almost) every setting.
namespace off

; General
%define_ram($00, enable_status_bar)

; Bonus Stars
%define_ram($01, bonus_stars_visibility)
%define_ram($02, bonus_stars_symbol)
%define_ram($03, always_check_bonus_stars)
%define_ram($04, bonus_stars_limit)
%define_ram($05, start_bonus_game_if_bonus_stars_limit_reached)
%define_ram($06, reset_bonus_stars_if_bonus_stars_limit_reached)

; Coins
%define_ram($07, coins_visibility)
%define_ram($08, coins_symbol)
%define_ram($09, always_check_coins)
%define_ram($0A, coins_limit)
%define_ram($0B, add_life_if_coins_limit_reached)
%define_ram($0C, reset_coins_if_coins_limit_reached)

; Life
%define_ram($0D, lives_visibility)
%define_ram($0E, lives_symbol)

; Time
%define_ram($0F, time_visibility)
%define_ram($10, time_symbol)
%define_ram($11, always_check_time)
%define_ram($12, time_frequency)

; Dragon Coins
%define_ram($13, dragon_coins_visibility)
%define_ram($14, dragon_coins_collected_symbol)
%define_ram($15, dragon_coins_missing_symbol)
%define_ram($16, use_custom_dragon_coins_collected_graphics)
%define_ram($17, custom_dragon_coins_collected_graphics)

; Score
%define_ram($1E, score_visibility)

; Power Up
%define_ram($1F, power_up_visibility)
%define_ram($20, power_up_position_x)

