load:
    ; Set coins visibility to $00 (not visible)
    LDA #$00 : STA csb_ram_coins_visibility
    LDA #$01 : STA csb_ram_power_up_visibility
    RTL
