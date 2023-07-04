;===============================================================================
; RAM
;===============================================================================

; Prepare RAM addresses for usage in the code.
; The patch required 32 bytes of free contiguous RAM. Its position can be
; configured in `settings.asm`.


;-------------------------------------------------------------------------------
; Utils
;-------------------------------------------------------------------------------

; Offset relative to the base freeram address.
; It will be increased each time an address is defined, by its size.
!ram_offset #= 0

; Define an address with a given size.
; This will produce a label accessible with `ram_<name>`. For instance:
;   define_ram_address_size(enable_status_bar, $01)
; will make `ram_enable_status_bar` usable in the code as follows:
;   LDA ram_enable_status_bar
macro define_ram_address_size(name, size)
    base !freeram_address+!ram_offset
        ram_<name>:
    base off
    !ram_offset #= !ram_offset+<size>
endmacro

; Same as `define_ram_address_size`, but with fixed size of $01.
macro define_ram_address(name)
    %define_ram_address_size(<name>, $01)
endmacro


;-------------------------------------------------------------------------------
; Definitions
;-------------------------------------------------------------------------------

; Define one address for (almost) every setting.

; General
%define_ram_address(enable_status_bar)

; Bonus Stars
%define_ram_address(bonus_stars_visibility)
%define_ram_address(bonus_stars_symbol)
%define_ram_address(always_check_bonus_stars)
%define_ram_address(start_bonus_game_if_bonus_stars_limit_reached)
%define_ram_address(reset_bonus_stars_if_bonus_stars_limit_reached)

; Coins
%define_ram_address(coins_visibility)
%define_ram_address(coins_symbol)
%define_ram_address(always_check_coins)
%define_ram_address(coins_limit)

; Life
%define_ram_address(add_life_if_coins_limit_reached)
%define_ram_address(reset_coins_if_coins_limit_reached)
%define_ram_address(lives_visibility)
%define_ram_address(lives_symbol)

; Time
%define_ram_address(time_visibility)
%define_ram_address(time_symbol)
%define_ram_address(always_check_time)
%define_ram_address(time_frequency)

; Dragon Coins
%define_ram_address(dragon_coins_visibility)
%define_ram_address(dragon_coins_collected_symbol)
%define_ram_address(dragon_coins_missing_symbol)
%define_ram_address(use_custom_dragon_coins_collected_graphics)
%define_ram_address_size(custom_dragon_coins_collected_graphics, $07)

; Score
%define_ram_address(score_visibility)

; Power Up
%define_ram_address(power_up_visibility)
%define_ram_address(power_up_position_x)

