;-------------------------------------------------------------------------------
; BONUS STARS
;-------------------------------------------------------------------------------

; Bonus stars indicator in form "S0TU", where S is the star symbol, followed by
; a hardcoded 0, T is the tens, and U is the units.


;-------------------------------------------------------------------------------
; Methods Definition
;-------------------------------------------------------------------------------

!BonusStars = AreBonusStarsVisible, ShowBonusStars


;-------------------------------------------------------------------------------
; Visibility Checks
;-------------------------------------------------------------------------------

; Set Z flag to 0 if bonus stars are visible, 1 otherwise.
; It expects A 16-bit.
AreBonusStarsVisible:
    %check_visibility_simple(!BonusStarsVisibility, 1, 2)


;-------------------------------------------------------------------------------
; Render
;-------------------------------------------------------------------------------

; Draw bonus stars counter on status bar.
; It expects the address for the position to be in A 16-bit.
ShowBonusStars:
    ; Backup X/Y, move A into Y, and set A/X/Y to 8-bit.
    PHX : PHY : PHA : SEP #$30

    ; Check bonus stars amount and setup bonus game if necessary.
    LDX $0DB3|!addr : LDA $0F48|!addr,x ; Get bonus stars for current player
    CMP #$64 : BCC +                    ; If they are greater or equal than 100...
    LDA #$FF : STA $1425|!addr          ; ...start bonus game when level ends, and...
    LDA $0F48|!addr,x : SEC             ; ...subtract 100 ($64) stars.
    SBC #$64 : STA.W $0F48|!addr,x      ; ...

    ; Draw bonus stars.
+   LDA $0F48|!addr,x : REP #$10 : PLY               ; Load bonus stars for current player
    %draw_counter_with_two_digits(!BonusStarsSymbol) ; and draw them

    ; Restore X/Y, set A/X/Y to 16-bit, and return.
    REP #$30 : PLY : PLX
    RTS
