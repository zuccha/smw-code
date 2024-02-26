;===============================================================================
; COLORS
;===============================================================================

; Status bar colors' configuration. Every line represents an 8x8 tile.
; Use only for customizing the color palette of a given tile. Lines can also be
; use to specify static graphics on the status bar, but it is advised to leave
; those empty ($FC) and let this patch set them as needed.

; The palette should be appropriate for the given slot that occupies it (also,
; all slots in a group should have the same palette pattern). You can configure
; slots' position in `settings.asm`.

; Let's see an example. By default, in `settings.asm`, group 1's slots are
; defined as:
;
;   !group1_slots = $0F11, $0F2C, $0F0C, $0F27
;
; This means the slots start at RAM addresses $0F11, $0F2C, $0F0C, and $0F27
; respectively. In other words, they start at coordinates (26,02), (26,03),
; (21,02), and (21,03) respectively. For every slot starting at the listed
; positions we have the following configuration:
;
;   db $FC, !color_gold
;   db $FC, !color_white
;   db $FC, !color_white
;   db $FC, !color_white
;
; We configure four tiles because slots from group 1 are four tiles wide. The
; first tile is a symbol, and the last three tiles are the three digits of the
; counter, then in this case the symbol will use the gold palette and the digits
; the white palette. If you change the position of any of the slots in
; "settings.asm" make sure to adapt the color palette for tiles, too!

; N.B.: The color palette cannot be customized at runtime via RAM address!
; Without further modification, the patch erases the entirety of the status bar.

; Format: db <graphics>, <palette>
; - graphics: Hex address (e.g., $1A) in graphics file GFX28 to be used for the
;   8x8 tile. $FC means empty.
; - palette: Configuration for the color palette, formatted as %YXPCCCTT.
; To better understand how this works, I suggest you check out HammerBrother's
; tutorial on the status bar: https://www.smwcentral.net/?p=section&a=details&id=26018

!color_empty = %00000000
!color_gold  = %00111100
!color_green = %00101000
!color_white = %00111000

org $008C81
    ; Top 4 tiles of the item box
    db $FC, !color_white ; (14,01), ($0E,$01), RAM: N/A
    db $FC, !color_white ; (15,01), ($0F,$01), RAM: N/A
    db $FC, !color_white ; (16,01), ($10,$01), RAM: N/A
    db $FC, !color_white ; (17,01), ($11,$01), RAM: N/A
org $008C89
    ; Top row
    db $FC, !color_green ; (02,02), ($02,$02), RAM: $0EF9
    db $FC, !color_empty ; (03,02), ($03,$02), RAM: $0EFA
    db $FC, !color_gold  ; (04,02), ($04,$02), RAM: $0EFB
    db $FC, !color_gold  ; (05,02), ($05,$02), RAM: $0EFC
    db $FC, !color_gold  ; (06,02), ($06,$02), RAM: $0EFD
    db $FC, !color_gold  ; (07,02), ($07,$02), RAM: $0EFE
    db $FC, !color_gold  ; (08,02), ($08,$02), RAM: $0EFF
    db $FC, !color_gold  ; (09,02), ($09,$02), RAM: $0F00
    db $FC, !color_gold  ; (10,02), ($0A,$02), RAM: $0F01
    db $FC, !color_empty ; (11,02), ($0B,$02), RAM: $0F02
    db $FC, !color_empty ; (12,02), ($0C,$02), RAM: $0F03
    db $FC, !color_empty ; (13,02), ($0D,$02), RAM: $0F04
    db $FC, !color_empty ; (14,02), ($0E,$02), RAM: $0F05
    db $FC, !color_white ; (15,02), ($0F,$02), RAM: $0F06
    db $FC, !color_white ; (16,02), ($10,$02), RAM: $0F07
    db $FC, !color_empty ; (17,02), ($11,$02), RAM: $0F08
    db $FC, !color_empty ; (18,02), ($12,$02), RAM: $0F09
    db $FC, !color_empty ; (19,02), ($13,$02), RAM: $0F0A
    db $FC, !color_empty ; (20,02), ($14,$02), RAM: $0F0B
    db $FC, !color_gold  ; (21,02), ($15,$02), RAM: $0F0C
    db $FC, !color_white ; (22,02), ($16,$02), RAM: $0F0D
    db $FC, !color_white ; (23,02), ($17,$02), RAM: $0F0E
    db $FC, !color_white ; (24,02), ($18,$02), RAM: $0F0F
    db $FC, !color_empty ; (25,02), ($19,$02), RAM: $0F10
    db $FC, !color_gold  ; (26,02), ($1A,$02), RAM: $0F11
    db $FC, !color_white ; (27,02), ($1B,$02), RAM: $0F12
    db $FC, !color_white ; (28,02), ($1C,$02), RAM: $0F13
    db $FC, !color_white ; (29,02), ($1D,$02), RAM: $0F14
    ; Bottom row
    ; Not available :(   ; (02,03), ($02,$03), RAM: N/A
    db $FC, !color_empty ; (03,03), ($03,$03), RAM: $0F15
    db $FC, !color_gold  ; (04,03), ($04,$03), RAM: $0F16
    db $FC, !color_gold  ; (05,03), ($05,$03), RAM: $0F17
    db $FC, !color_gold  ; (06,03), ($06,$03), RAM: $0F18
    db $FC, !color_gold  ; (07,03), ($07,$03), RAM: $0F19
    db $FC, !color_gold  ; (08,03), ($08,$03), RAM: $0F1A
    db $FC, !color_gold  ; (09,03), ($09,$03), RAM: $0F1B
    db $FC, !color_gold  ; (10,03), ($0A,$03), RAM: $0F1C
    db $FC, !color_empty ; (11,03), ($0B,$03), RAM: $0F1D
    db $FC, !color_empty ; (12,03), ($0C,$03), RAM: $0F1E
    db $FC, !color_empty ; (13,03), ($0D,$03), RAM: $0F1F
    db $FC, !color_empty ; (14,03), ($0E,$03), RAM: $0F20
    db $FC, !color_white ; (15,03), ($0F,$03), RAM: $0F21
    db $FC, !color_white ; (16,03), ($10,$03), RAM: $0F22
    db $FC, !color_empty ; (17,03), ($11,$03), RAM: $0F23
    db $FC, !color_empty ; (18,03), ($12,$03), RAM: $0F24
    db $FC, !color_empty ; (19,03), ($13,$03), RAM: $0F25
    db $FC, !color_empty ; (20,03), ($14,$03), RAM: $0F26
    db $FC, !color_gold  ; (21,03), ($15,$03), RAM: $0F27
    db $FC, !color_white ; (22,03), ($16,$03), RAM: $0F28
    db $FC, !color_white ; (23,03), ($17,$03), RAM: $0F29
    db $FC, !color_white ; (24,03), ($18,$03), RAM: $0F2A
    db $FC, !color_empty ; (25,03), ($19,$03), RAM: $0F2B
    db $FC, !color_gold  ; (26,03), ($1A,$03), RAM: $0F2C
    db $FC, !color_white ; (27,03), ($1B,$03), RAM: $0F2D
    db $FC, !color_white ; (28,03), ($1C,$03), RAM: $0F2E
    db $FC, !color_white ; (29,03), ($1D,$03), RAM: $0F2F
org $008CF7
    ; Bottom 4 tiles of the item box
    db $FC, !color_white ; (14,04), ($0E,$04), RAM: N/A
    db $FC, !color_white ; (15,04), ($0F,$04), RAM: N/A
    db $FC, !color_white ; (16,04), ($10,$04), RAM: N/A
    db $FC, !color_white ; (17,04), ($11,$04), RAM: N/A
