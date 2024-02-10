;===============================================================================
; CHECK AND PAY
;===============================================================================

; Routine that checks if there are enough funds and, if so, it will subtract
; them from their relative counters.
; Costs are defined via scratch RAM. All costs must be met for buying; if all
; costs are met, the routine will subtract them from the counters.
; This routine doesn't determine what's going to happen after paying, that's up
; to the user.

; Inputs and outputs:
; @input $00: Cost in bonus stars. Values: 0-255 ($00-$FF).
; @input $01: Cost in coins. Values: 0-255 ($00-$FF).
; @input $02: Cost in lives. Values: 0-255 ($00-$FF).
; @input $03-05: Cost in score. Values: 0-16777216 ($000000-$FFFFFF).
; N.B.: The value you specify here for the score is divided by 10! E.g., if you
; want an item to cost 200 score points (so, decrease the score on the status
; bar by 200), here you need to specify 20. This is because the score on the
; status bar has a hardcoded 0.
; @output C: 0 if didn't pay (insufficient funds), 1 if it paid.

; Usage example:
;   STZ $00                             ; Bonus Stars = 0
;   LDA #$10 : STA $01                  ; Coins       = 10
;   STZ $02                             ; Lives       = 0
;   STZ $03 : STZ $04 : STZ $05         ; Score       = 0
;   %check_and_pay() : BCC .not_paid
; .paid
;   ; Handle payment successful
;   RTL
; .not_paid
;   ; Handle insufficient funds
;   RTL

; %check_and_pay()
?check
    ; Bonus Stars
    LDX $0DB3|!addr : LDA $0F48|!addr,x  ; Get current player's bonus stars
    CMP $00                              ; If player doesn't have enough bonus stars...
    BCC ?dont_pay                        ; ...then don't buy

    ; Coins
    LDA $0DBF|!addr                      ; Get current player's coins
    CMP $01                              ; If player doesn't have enough coins...
    BCC ?dont_pay                        ; ...then don't buy

    ; Lives
    LDA $0DBE|!addr                      ; Get current player's lives
    CMP $02                              ; If player doesn't have enough lives...
    BCC ?dont_pay                        ; ...then don't buy

    ; Score
    LDA $0DB3|!addr                      ; Load current player (0 = Mario, 1 = Luigi)...
    ASL : CLC : ADC $0DB3|!addr : TAX    ; ...and multiply it by 3 (0 = Mario, 3 = Luigi)
    LDA $0F36|!addr,x : CMP $05          ; \
    BCC ?dont_pay : BNE ?pay             ; | Compare score and cost, from high to low bytes:
    LDA $0F35|!addr,x : CMP $04          ; | - if cost byte is greater don't buy
    BCC ?dont_pay : BNE ?pay             ; | - else if cost is smaller (not equal) buy
    LDA $0F34|!addr,x : CMP $03          ; | - else (they are equal) go to next byte
    BCC ?dont_pay                        ; /

?pay
    ; Bonus Stars
    LDX $0DB3|!addr : LDA $0F48|!addr,x  ; Get current player's bonus stars
    SEC : SBC $00                        ; Subtract cost from bonus stars counter
    STA $0F48|!addr,x                    ; Update counter

    ; Coins
    LDA $0DBF|!addr                      ; Get current player's coins
    SEC : SBC $01                        ; Subtract cost from coins counter
    STA $0DBF|!addr                      ; Update counter

    ; Lives
    LDA $0DBE|!addr                      ; Get current player's lives
    SEC : SBC $02                        ; Subtract cost from lives counter
    STA $0DBE|!addr                      ; Update counter

    ; Score
    LDA $0DB3|!addr                      ; Load current player (0 = Mario, 1 = Luigi)...
    ASL : CLC : ADC $0DB3|!addr : TAX    ; ...and multiply it by 3 (0 = Mario, 3 = Luigi)
    LDA $0F34|!addr,x : SEC              ; \
    SBC $03 : STA $0F34|!addr,x          ; | Subtract cost from score, byte-by-byte,
    LDA $0F35|!addr,x                    ; | starting from the low byte going up
    SBC $04 : STA $0F35|!addr,x          ; | up to the high byte, setting the carry
    LDA $0F36|!addr,x                    ; | flag only on the first subtraction
    SBC $05 : STA $0F36|!addr,x          ; /

    ; Return
    SEC : RTL

?dont_pay
    CLC : RTL
