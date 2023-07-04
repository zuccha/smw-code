;===============================================================================
; RESET
;===============================================================================

; Load byte from settings and write it into RAM.
; @param <name>: Setting name.
macro reset_ram_byte(name)
    LDA.b #!<name> : STA ram_<name>
endmacro

; Load bytes from settings' tabke and write them into RAM.
; A table named <name>_table of size <size> must exist!
; @param <name>: Setting name.
; @param <size>: Size of the table.
macro reset_ram_table(name, size)
    !i #= 0
    while !i < <size>
        LDA.l <name>_table+!i : STA ram_<name>+!i
        !i #= !i+1
    endif
endmacro

; Reset RAM when level starts.
reset_ram:
    SEP #$20

    ; General
    %reset_ram_byte(enable_status_bar)

    ; Bonus Stars
    %reset_ram_byte(bonus_stars_visibility)
    %reset_ram_byte(bonus_stars_symbol)
    %reset_ram_byte(always_check_bonus_stars)
    %reset_ram_byte(bonus_stars_limit)
    %reset_ram_byte(start_bonus_game_if_bonus_stars_limit_reached)
    %reset_ram_byte(reset_bonus_stars_if_bonus_stars_limit_reached)

    ; Coins
    %reset_ram_byte(coins_visibility)
    %reset_ram_byte(coins_symbol)
    %reset_ram_byte(always_check_coins)
    %reset_ram_byte(coins_limit)

    ; Life
    %reset_ram_byte(add_life_if_coins_limit_reached)
    %reset_ram_byte(reset_coins_if_coins_limit_reached)
    %reset_ram_byte(lives_visibility)
    %reset_ram_byte(lives_symbol)

    ; Time
    %reset_ram_byte(time_visibility)
    %reset_ram_byte(time_symbol)
    %reset_ram_byte(always_check_time)
    %reset_ram_byte(time_frequency)

    ; Dragon Coins
    %reset_ram_byte(dragon_coins_visibility)
    %reset_ram_byte(dragon_coins_collected_symbol)
    %reset_ram_byte(dragon_coins_missing_symbol)
    %reset_ram_byte(use_custom_dragon_coins_collected_graphics)
    %reset_ram_table(custom_dragon_coins_collected_graphics, $07)

    ; Score
    %reset_ram_byte(score_visibility)

    ; Power Up
    %reset_ram_byte(power_up_visibility)
    %reset_ram_byte(power_up_position_x)

    ; Return
    RTL
