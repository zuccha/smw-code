;===============================================================================
; KILL PLAYER ON BUTTON PRESS (status bar)
;===============================================================================

; Routine that draws the number the button has been pressed in the status bar.


;-------------------------------------------------------------------------------
; Configuration
;-------------------------------------------------------------------------------

; Number of pressed required to hurt/kill the player.
; Must be a value between 1-255 ($01-$FF). 0 won't do anything, any value above
; 255 ($FF) will crash the game.
; N.B.: This needs to be the same as the one defined in the level's ASM!
!button_presses_threshold = $65

; 1 byte of free RAM, keeping track of the number of presses (1 byte).
; N.B.: This needs to be the same as the one defined in the level's ASM!
!ram_button_presses_count = $140B

; 1 byte of free RAM, determining whether the status bar should display the
; counter or not.
; N.B.: This needs to be the same as the one defined in the level's ASM!
!ram_show_presses_in_status_bar = $140C

; Whether to show the inputs left or done.
; 0 = show inputs done (when it reaches the threshold Mario dies)
; 1 = show inputs left (when it reaches zero Mario dies)
!show_inputs_left = 1

; Status bar RAM for deciding where to draw the counter. By default, it replaces
; the "TIME" text, above the timer.
; For more, check out https://smwc.me/m/smw/ram/7E0EF9
!ram_100s = $0F0A
!ram_10s  = $0F0B
!ram_1s   = $0F0C


;-------------------------------------------------------------------------------
; Code
;-------------------------------------------------------------------------------

; Main code.
main:
    LDA.w !ram_show_presses_in_status_bar|!addr ; If we don't need to draw the counter
    BEQ .return                                 ; Then return

if !show_inputs_left == 0
    LDA.w !ram_button_presses_count|!addr       ; Number to show = current count
else
    LDA.b #!button_presses_threshold
    SEC : SBC.w !ram_button_presses_count|!addr ; Number to show = threshold - current count
endif

    LDX #$00                                    ; X counts 100s
-   CMP #$64 : BCC +                            ; While A >= 100
    SBC #$64 : INX                              ; Subtract 100 and increase 100s count
    BRA -                                       ; Repeat
+   PHA : TXA : STA.w !ram_100s|!addr : PLA     ; Draw 100s.

    LDX #$00                                    ; X counts 10s
-   CMP #$0A : BCC +                            ; While A >= 10
    SBC #$0A : INX                              ; Subtract 10 and increase 10s count
    BRA -                                       ; Repeat
+   PHA : TXA : STA.w !ram_10s|!addr : PLA      ; Draw 10s.

    STA.w !ram_1s|!addr                         ; Draw 1s.

.return
    RTS
