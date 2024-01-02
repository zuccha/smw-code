;===============================================================================
; HIJACKS
;===============================================================================

; This patch uses the following hijacks:
; 1. Disable original status bar.
; 2. Retrieve custom item box's horizontal position.
; 3. Prevent item box from dropping item if power_up_visibility = 2 (disabled).
; 4. Conditionally turn off IRQ (credits KevinM).
; 5. Overwrite status bar tilemap's tiles and palettes (in `colors.asm`).


;-------------------------------------------------------------------------------
pushpc ; Hijacks
;-------------------------------------------------------------------------------

; Status bar IRQ setup.
org $008294
    JML check_irq_setup

; Status bar tilemap transfer from ROM.
org $008CFF
    JML check_tilemap_transfer_from_rom

; Status bar tilemap transfer from RAM.
org $008DAC
    JML check_tilemap_transfer_from_ram

; Override status bar after UberASMTool's hijack.
org $008E1F
    RTS

; Tweak stored power up horizontal position (where it starts falling from).
org $028051
    JSL get_power_up_x_position

; Prevent item from falling if disabled from settings.
org $028008
    JML check_if_item_should_drop


;-------------------------------------------------------------------------------
pullpc ; Utilities
;-------------------------------------------------------------------------------

; Replace LDA #$78 with position from settings.
get_power_up_x_position:
    LDA ram_power_up_position_x ; Retrieve position
    CLC : ADC $1A               ; Restore original code
    RTL

; Restore code for dropping item.
check_if_item_should_drop:
    LDA ram_power_up_visibility ; If visibility = 2
    CMP #$02 : BNE +            ; Then don't drop item
    JML $028071|!bank           ; (jump to the end of the routine)
+   PHX : LDA $0DC2|!addr       ; Else restore original code
    JML $02800C|!bank           ; (jump back into the routine)

; Disable IRQ if status bar is disabled.
check_irq_setup:
    LDA $0D9B|!addr : BMI .enable ; Always enable the IRQ in mode 7 boss rooms
    LDA ram_status_bar_visibility : BNE .enable
.disable:
if !sa1
    LDX #$81
else
    LDA #$81 : STA $4200
endif
    LDA $22 : STA $2111
    LDA $23 : STA $2111
    LDA $24 : STA $2112
    LDA $25 : STA $2112
    LDA $3E : STA $2105
    LDA $40 : STA $2131
    JML $0082B0|!bank
.enable:
    LDA $4211 : STY $4209 ; Restore original code
    JML $00829A|!bank     ; Jump back into the routine

; Skip tilemap transfer from ROM if status bar is disabled.
check_tilemap_transfer_from_rom:
    LDA ram_status_bar_visibility : BNE .enable
.disable:
    JML $008D8F|!bank    ; Jump to the end of the routine
.enable:
    LDA #$80 : STA $2115 ; Restore original code
    JML $008D04|!bank    ; Jump back into the routine

; Skip tilemap transfer from RAM if status bar is disabled.
check_tilemap_transfer_from_ram:
    LDA ram_status_bar_visibility : BNE .enable
.disable:
    JML $008DE6|!bank    ; Jump to the end of the routine
.enable:
    STZ $2115 : LDA #$42 ; Restore original code
    JML $008DB1|!bank    ; Jump back into the routine
