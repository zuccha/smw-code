;-------------------------------------------------------------------------------
; BONUS STARS
;-------------------------------------------------------------------------------

; Bonus stars indicator in form "S0TU", where S is the star symbol, followed by
; a hardcoded 0, T is the tens, and U is the units.


;-------------------------------------------------------------------------------
; Methods Definition
;-------------------------------------------------------------------------------

!BonusStars = HandleBonusStars


;-------------------------------------------------------------------------------
; Handler
;-------------------------------------------------------------------------------

; Handle drawing bonus stars counter on status bar.
; @param A (16-bit): Slot position.
; @return A (16-bit): #$0001 if the indicator has been drawn, #$0000 otherwise.
; @return Z: 0 if the indicator has been drawn, 1 otherwise.
HandleBonusStars:
    ; Backup registers and check visibility.
    PHX : PHY : PHA ; Stack: X, Y, Slot <-
    %check_visibility(!BonusStarsVisibility, 1, 2)

.visibility1
    ; Check bonus stars amount and setup bonus game if necessary.
    SEP #$30
    LDX $0DB3|!addr : LDA $0F48|!addr,x ; Get bonus stars for current player
    CMP #$64 : BCC +                    ; If they are greater or equal than 100...
    LDA #$FF : STA $1425|!addr          ; Then start bonus game when level ends, and...
    LDA $0F48|!addr,x : SEC             ; ...subtract 100 ($64) stars
    SBC #$64 : STA.W $0F48|!addr,x      ; ...

    ; Draw bonus stars.
+   LDA $0F48|!addr,x : REP #$10 : PLY               ; Load bonus stars for current player
    %draw_counter_with_two_digits(!BonusStarsSymbol) ; and draw them

    ; Return
    %return_handler_visible()

.visibility0
.visibility2
    %return_handler_hidden()
