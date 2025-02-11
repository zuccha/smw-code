;===============================================================================
; TIME
;===============================================================================

; Time indicator in form "SHTO", where "S" is the coin symbol, "H" is the 100s,
; "T" is the 10s, and "O" is the 1s.


;-------------------------------------------------------------------------------
; Utilities
;-------------------------------------------------------------------------------

; Check if time is zero.
; @return Z: 1 if it is zero, 0 otherwise.
macro is_time_zero()
    LDA $0F31|!addr : ORA $0F32|!addr : ORA $0F33|!addr
endmacro


;-------------------------------------------------------------------------------
; Handler
;-------------------------------------------------------------------------------

; Draw time counter on status bar.
; @return C: 1 if the indicator has been drawn, 0 otherwise.
time:
    %check_visibility(time)

.visibility2
    LDA $0F30|!addr : CMP #$FF : BEQ .visibility1 ; Draw if timer's timer is $FF (timer reached 0)
    %is_time_zero() : BEQ .visibility0            ; Don't draw if timer is 0 (timer was always 0)
                                                  ; Else draw (timer is not 0)

.visibility1
    JSR check_time

    ; Draw time counter on the status bar.
    LDA ram_time_symbol : %draw_tile() ; Symbol
    LDA $0F31|!addr : %draw_tile()     ; Hundreds
    LDA $0F32|!addr : %draw_tile()     ; Tens
    LDA $0F33|!addr : %draw_tile()     ; Units

    ; Return
    SEC : RTS

.visibility0
    LDA ram_always_check_time : BEQ +
    JSR check_time
+   CLC : RTS


;-------------------------------------------------------------------------------
; Check
;-------------------------------------------------------------------------------

; Original routine that decrements timer, with a few tweaks:
;   1. Customizable decrease frequency.
;   2. Set timer's timer ($0F30) to $FF when time reaches 0, and don't decrease
;   timer if its value is already $FF. This is needed so that if the timer runs
;   out while visibility = 2, the timer doesn't disappear from the status bar
;   (since with visibility = 2, the timer should not appear when it is 0, but
;   only at the start of the level).
;   3. Add custom routine to execute when time runs out.
check_time:
    LDA $1493|!addr : ORA $9D : BNE .return         ; If levels not ending and sprites not locked
    LDA $0D9B|!addr : CMP #$C1 : BEQ .return        ; If not at Bowser's
    LDA $0F30|!addr : CMP #$FF : BEQ .return        ; If timer's timer is not $FF
    DEC $0F30|!addr                                 ; Then decrement timer's timer and
    BPL .return                                     ; If it was 0
    LDA ram_time_frequency : STA $0F30|!addr        ; Then reset it
    %is_time_zero() : BEQ .return                   ; If timer is not 0
    LDX #$02                                        ; Then decrease the timer, digit by digit
-   DEC $0F31|!addr,x : BPL +                       ; If digit was 0
    LDA #$09 : STA $0F31|!addr,x : DEX : BPL -      ; Set it to 9 and go to next
+   LDA $0F31|!addr : BNE +                         ; If the hundreds' digit is 0...
    LDA $0F32|!addr : AND $0F33|!addr               ; ...and tens and ones...
    CMP #$09 : BNE +                                ; ...are 9s (timer is 099)
    LDA #$FF : STA $1DF9|!addr                      ; Then speed up the music
+   %is_time_zero() : BNE .return                   ; If timer is 0
    JSR trigger_time_run_out                        ; Then trigger custom behavior
    LDA ram_kill_player_when_time_runs_out : BEQ +  ; If should kill player
    JSL $00F606|!bank                               ; Then kill player
+   LDA #$FF : STA $0F30|!addr                      ; Set timer's timer to $FF marking time over
.return
    RTS
