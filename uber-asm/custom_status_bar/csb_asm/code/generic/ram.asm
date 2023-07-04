;===============================================================================
; RAM
;===============================================================================

; Prepare RAM addresses for usage in the code.
; The patch required 32 bytes of free contiguous RAM. Its position can be
; configured in `settings.asm`.


;-------------------------------------------------------------------------------
; Utils
;-------------------------------------------------------------------------------

; Define an address with a given size.
; This will produce a label accessible with `ram_<name>`. For instance:
;   define_ram_address_size(enable_status_bar, $01)
; will make `ram_enable_status_bar` usable in the code as follows:
;   LDA ram_enable_status_bar
macro define_ram_address(offset, name)
    base !freeram_address+<offset>
        ram_<name>:
    base off
endmacro


;-------------------------------------------------------------------------------
; Definitions
;-------------------------------------------------------------------------------

; Define one address for (almost) every setting.

; General
%define_ram_address($00, enable_status_bar)

; Bonus Stars
%define_ram_address($01, bonus_stars_visibility)
%define_ram_address($02, bonus_stars_symbol)
%define_ram_address($03, always_check_bonus_stars)
%define_ram_address($04, start_bonus_game_if_bonus_stars_limit_reached)
%define_ram_address($05, reset_bonus_stars_if_bonus_stars_limit_reached)

; Coins
%define_ram_address($06, coins_visibility)
%define_ram_address($07, coins_symbol)
%define_ram_address($08, always_check_coins)
%define_ram_address($09, coins_limit)

; Life
%define_ram_address($0A, add_life_if_coins_limit_reached)
%define_ram_address($0B, reset_coins_if_coins_limit_reached)
%define_ram_address($0C, lives_visibility)
%define_ram_address($0D, lives_symbol)

; Time
%define_ram_address($0E, time_visibility)
%define_ram_address($0F, time_symbol)
%define_ram_address($10, always_check_time)
%define_ram_address($11, time_frequency)

; Dragon Coins
%define_ram_address($12, dragon_coins_visibility)
%define_ram_address($13, dragon_coins_collected_symbol)
%define_ram_address($14, dragon_coins_missing_symbol)
%define_ram_address($15, use_custom_dragon_coins_collected_graphics)
%define_ram_address($16, custom_dragon_coins_collected_graphics)

; Score
%define_ram_address($1D, score_visibility)

; Power Up
%define_ram_address($1E, power_up_visibility)
%define_ram_address($1F, power_up_position_x)

