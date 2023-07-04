;===============================================================================
; RESET
;===============================================================================

; Load value from settings and write it into RAM.
; @param <name>: Setting name.
macro reset_ram_address(name)
    LDA.b !<name> : STA ram_<name>
endmacro

; Reset RAM when level starts.
reset_ram:
    SEP #$20

    ; General
    %reset_ram_address(enable_status_bar)

    ; Bonus Stars
    %reset_ram_address(bonus_stars_visibility)
    %reset_ram_address(bonus_stars_symbol)
    %reset_ram_address(always_check_bonus_stars)
    %reset_ram_address(start_bonus_game_if_bonus_stars_limit_reached)
    %reset_ram_address(reset_bonus_stars_if_bonus_stars_limit_reached)

    ; Coins
    %reset_ram_address(coins_visibility)
    %reset_ram_address(coins_symbol)
    %reset_ram_address(always_check_coins)
    %reset_ram_address(coins_limit)

    ; Life
    %reset_ram_address(add_life_if_coins_limit_reached)
    %reset_ram_address(reset_coins_if_coins_limit_reached)
    %reset_ram_address(lives_visibility)
    %reset_ram_address(lives_symbol)

    ; Time
    %reset_ram_address(time_visibility)
    %reset_ram_address(time_symbol)
    %reset_ram_address(always_check_time)
    %reset_ram_address(time_frequency)

    ; Dragon Coins
    %reset_ram_address(dragon_coins_visibility)
    %reset_ram_address(dragon_coins_collected_symbol)
    %reset_ram_address(dragon_coins_missing_symbol)
    %reset_ram_address(use_custom_dragon_coins_collected_graphics)
    ; %reset_ram_address_size(custom_dragon_coins_collected_graphics, $07)

    ; Score
    %reset_ram_address(score_visibility)

    ; Power Up
    %reset_ram_address(power_up_visibility)
    %reset_ram_address(power_up_position_x)

    ; Return
    RTL
