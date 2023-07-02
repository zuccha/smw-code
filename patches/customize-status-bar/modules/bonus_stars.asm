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

; Check if bonus stars are visible.
; @return A (16-bit): #$0000 if bonus stars are not visible, #$0001 otherwise.
; @return Z: 1 if bonus stars are not visible, 0 otherwise.
AreBonusStarsVisible:
    %check_visibility_simple(!BonusStarsVisibility, 1, 2)


;-------------------------------------------------------------------------------
; Render
;-------------------------------------------------------------------------------

; Activate and decrease bonus stars if necessary and draw them on status bar.
; @param A (16-bit): Slot position.
ShowBonusStars:
    ; Backup X/Y, push A (slot position) onto the stack, and set A/X/Y to 8-bit.
    PHX : PHY : PHA : SEP #$30

    ; Check bonus stars amount and setup bonus game if necessary.
    LDX $0DB3|!addr : LDA $0F48|!addr,x ; Get bonus stars for current player
    CMP #$64 : BCC +                    ; If they are greater or equal than 100...
    LDA #$FF : STA $1425|!addr          ; Then start bonus game when level ends, and...
    LDA $0F48|!addr,x : SEC             ; ...subtract 100 ($64) stars
    SBC #$64 : STA.W $0F48|!addr,x      ; ...

    ; Draw bonus stars.
+   LDA $0F48|!addr,x : REP #$10 : PLY               ; Load bonus stars for current player
    %draw_counter_with_two_digits(!BonusStarsSymbol) ; and draw them

    ; Restore X/Y, set A/X/Y to 16-bit, and return.
    REP #$30 : PLY : PLX
    RTS
