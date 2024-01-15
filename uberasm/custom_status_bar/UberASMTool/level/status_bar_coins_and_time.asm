load:
    ; Always enable status bar
    LDA #$02 : STA csb_ram_status_bar_visibility

    ; Hidden: Bonus Stars, Lives, Dragon Coins, Score, Power Up
    LDA #$00
    STA csb_ram_bonus_stars_visibility
    STA csb_ram_lives_visibility
    STA csb_ram_dragon_coins_visibility
    STA csb_ram_score_visibility
    STA csb_ram_power_up_visibility

    ; Visible: Coins, Time
    LDA #$01
    STA csb_ram_coins_visibility
    STA csb_ram_time_visibility

    RTL
