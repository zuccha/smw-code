;===============================================================================
; SHOP PAY
;===============================================================================

; Routine that checks if there are enough funds and, if so, it will subtract
; them from their relative counters.
; Costs are defined via defines. All costs must be met for buying; if all costs
; are met, the routine will subtract them from the counter.
; This routine doesn't determine what's going to happen after paying, that's up
; to the user.

; Inputs and outputs:
; @param !bonus_stars_cost: Cost in bonus stars. Values: 0-255 ($00-$FF).
; @param !coins_cost: Cost in coins. Values: 0-255 ($00-$FF).
; @param !lives_cost: Cost in lives. Values: 0-255 ($00-$FF).
; @param !score_cost: Cost in score. Values: 0-16777216 ($000000-$FFFFFF).
; N.B.: The value you specify here for the score is divided by 10! E.g., if you
; want an item to cost 200 score points (so, decrease the score on the status
; bar by 200), here you need to specify 20. This is because the score on the
; status bar has a hardcoded 0.
; @param A (8-bit): Any value.
; @param X (8-bit): Any value.
; @return A (8-bit): $00 if didn't pay (insufficient funds), $01 if it paid.
; @return Z: 1 if didn't pay (insufficient funds), 0 if it paid.

; Usage example:
;   !bonus_stars_cost = 0
;   !coins_cost = 10
;   !lives_cost = 0
;   !score_cost = 0
;   SEP #$30 : JSL ShopPay : BEQ .not_paid
; .paid
;   ; Handle payment successful
;   RTL
; .not_paid
;   ; Handle insufficient funds
;   RTL


;-------------------------------------------------------------------------------
; Routine
;-------------------------------------------------------------------------------

ShopPay:

if !bonus_stars_cost > 0
  LDX $0DB3|!addr : LDA $0F48,x        ; Get current player's bonus stars
  CMP.b #!bonus_stars_cost             ; If player doesn't have enough bonus stars...
  BCC .dont_buy                        ; ...then don't buy
endif

if !coins_cost > 0
  LDA $0DBF|!addr                      ; Get current player's coins
  CMP.b #!coins_cost                   ; If player doesn't have enough coins...
  BCC .dont_buy                        ; ...then don't buy
endif

if !lives_cost > 0
  LDA $0DBE|!addr                      ; Get current player's lives
  CMP.b #!lives_cost                   ; If player doesn't have enough lives...
  BCC .dont_buy                        ; ...then don't buy
endif

if !score_cost > 0
  LDA $0DB3|!addr                      ; Load current player (0 =  Mario, 1 = Luigi)...
  ASL : CLC : ADC $0DB3|!addr : TAX    ; ...and multiply it by 3 (0 = Mario, 3 = Luigi)
  LDA $0F36,x : CMP.b #!score_cost>>16 ; \
  BCC .dont_buy : BNE .buy             ; | Compare score and cost, from high to low bytes:
  LDA $0F35,x : CMP.b #!score_cost>>8  ; | - if cost byte is greater don't buy
  BCC .dont_buy : BNE .buy             ; | - else if cost is smaller (not equal) buy
  LDA $0F34,x : CMP.b #!score_cost     ; | - else (they are equal) go to next byte
  BCC .dont_buy                        ; /
endif

.buy

if !bonus_stars_cost > 0
  LDX $0DB3|!addr : LDA $0F48,x        ; Get current player's bonus stars
  SEC : SBC.b #!bonus_stars_cost       ; Subtract cost from bonus stars counter
  STA $0F48,x                          ; Update counter
endif

if !coins_cost > 0
  LDA $0DBF|!addr                      ; Get current player's bonus stars
  SEC : SBC.b #!coins_cost             ; Subtract cost from bonus stars counter
  STA $0DBF|!addr                      ; Update counter
endif

if !lives_cost > 0
  LDA $0DBE|!addr                      ; Get current player's bonus stars
  SEC : SBC.b #!lives_cost             ; Subtract cost from bonus stars counter
  STA $0DBE|!addr                      ; Update counter
endif

if !score_cost > 0
  LDA $0DB3|!addr                      ; Load current player (0 =  Mario, 1 = Luigi)...
  ASL : CLC : ADC $0DB3|!addr : TAX    ; ...and multiply it by 3 (0 = Mario, 3 = Luigi)
  LDA $0F34,x : SEC                    ; \
  SBC.b #!score_cost     : STA $0F34,x ; | Subtract cost from score, byte-by-byte,
  LDA $0F35,x                          ; | starting from the low byte going up
  SBC.b #!score_cost>>8  : STA $0F35,x ; | up to the high byte, setting the carry
  LDA $0F36,x                          ; | flag only on the first subtraction
  SBC.b #!score_cost>>16 : STA $0F36,x ; /
endif

  LDA #$01 : RTL

.dont_buy

  LDA #$00 : RTL
