;===============================================================================
; TIME
;===============================================================================

; Time indicator in form "SHTU", where S is the coin symbol, H is the hundreds,
; T is the tens, and U is the units.


;-------------------------------------------------------------------------------
; Methods Definition
;-------------------------------------------------------------------------------

; Methods.
!time = handle_time


;-------------------------------------------------------------------------------
; Handler
;-------------------------------------------------------------------------------

; Draw time counter on status bar.
; @param A (16-bit): Slot position.
; @return A (16-bit): #$0001 if the indicator has been drawn, #$0000 otherwise.
; @return Z: 0 if the indicator has been drawn, 1 otherwise.
handle_time:
    ; Backup registers and check visibility.
    PHX : PHY : PHA ; Stack: X, Y, Slot <-
    %check_visibility(time)

.visibility2
    SEP #$20
    LDA $0F30|!addr : CMP #$FF         ; If timer's timer is $FF (timer reached 0)
    BEQ .visibility1                   ; Then draw
    LDA $0F31|!addr : ORA $0F32|!addr  ; If timer is zero
    ORA $0F33|!addr : BEQ .visibility0 ; Then don't draw

.visibility1
    JSR check_time : REP #$10

    ; Draw time counter on the status bar.
    PLY : SEP #$20                                ; Stack: X, Y <-
    LDA.b #!time_symbol : STA $0000|!addr,y : INY ; Symbol
    LDA $0F31|!addr : STA $0000|!addr,y : INY     ; Hundreds
    LDA $0F32|!addr : STA $0000|!addr,y : INY     ; Tens
    LDA $0F33|!addr : STA $0000|!addr,y           ; Units

    ; Return
    %return_handler_visible()

.visibility0
    if !always_check_time == 1 : JSR check_time
    %return_handler_hidden()


;-------------------------------------------------------------------------------
; Check
;-------------------------------------------------------------------------------

; Original routine that decrements timer, with a few tweaks:
; 1. Customizable decrease frequency.
; 2. Set timer's timer ($0F30) to $FF when time reaches 0, and don't decrease
; timer if it's value is already $FF. This is needed so that if the timer runs
; out while visibility = 2, the timer doesn't disappear from the status bar
; (since with visibility = 2, the timer should not appear when it is 0, but only
; at the start of the level).
; @return A (8-bit)
; @return X/Y (8-bit)
check_time:
    SEP #$30
    LDA $1493|!addr : ORA $9D|!addr : BNE +    ; If levels not ending and sprites not locked
    LDA $0D9B|!addr : CMP #$C1 : BEQ +         ; If not at Bowser's
    LDA $0F30|!addr : CMP #$FF : BEQ +         ; If timer's timer is not $FF
    DEC $0F30|!addr                            ; Then decrement timer's timer and
    BPL +                                      ; If it was 0
    LDA.b #!time_frequency : STA $0F30|!addr   ; Then reset it
    LDA $0F31|!addr : ORA $0F32|!addr : ORA $0F33|!addr
    BEQ +                                      ; If timer is not 0
    LDX #$02                                   ; Then decrease the timer, digit by digit
-   DEC $0F31|!addr,x : BPL ++                 ; If digit was 0
    LDA #$09 : STA $0F31|!addr,x : DEX : BPL - ; Set it to 9 and go to next
++  LDA $0F31|!addr : BNE ++                   ; If the hundreds' digit is 0...
    LDA $0F32|!addr : AND $0F32|!addr          ; ...and tens and units...
    CMP #$09 : BNE ++                          ; ...are 9s (timer is 099)
    LDA #$FF : STA $1DF9|!addr                 ; Then speed up the music
++  LDA $0F31|!addr : ORA $0F32|!addr : ORA $0F33|!addr
    BNE +                                      ; If timer is 000
    JSL $00F606                                ; Then kill player
    LDA #$FF : STA $0F30|!addr                 ; Set timer's timer to $FF marking time over
+   RTS
