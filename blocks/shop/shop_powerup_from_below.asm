;===============================================================================
; SHOP POWERUP FROM BELOW
;===============================================================================

; A block that allows you to buy powerups for the player, with a cost of your
; choosing.

; The block activates when the player hits it from below.
; To buy the item, you need to have enough funds.
; You cannot buy items that you already have in the item box.

; This block should act as 130 (or anything solid).


;-------------------------------------------------------------------------------
; Configuration
;-------------------------------------------------------------------------------

; Powerup that will be granted to the player after buying it.
; 0 = small
; 1 = big
; 2 = cape
; 3 = fire
!powerup = 1

; How many time the player can buy the item.
; Right now only either one or infinite times is supported, you cannot specify
; arbitrary amounts.
; 0 = infinite
; 1 = one
!availability = 1

; Cost of the item.
; The item can be bought only if ALL the specified costs are met. Once bought,
; the specified amounts will be subtracted from the current player's counters.
; Bonus stars, coins, and lives are values between 0 and 255. The score is a
; value between 0 and 16777216. If all values are 0, the item is free!
; N.B.: The value you specify here for the score is divided by 10! E.g., if you
; want an item to cost 200 score points (so, decrease the score on the status
; bar by 200), here you need to specify 20. This is because the score on the
; status bar has a hardcoded 0.
!bonus_stars_cost = 0 ; 0-255 ($00-$FF)
!coins_cost       = 0 ; 0-255 ($00-$FF)
!lives_cost       = 0 ; 0-255 ($00-$FF)
!score_cost       = 0 ; 0-16777216 ($000000-$FFFFFF)

; Sound effects for when buying the item. The list of values can be found here:
; https://www.smwcentral.net/?p=memorymap&a=detail&game=smw&region=ram&detail=294be88c9dcc
!buy_sfx      = $3E ; Default = $3E (get powerup)
!dont_buy_sfx = $35 ; Default = $35 (hit head)

; What the shop block turns into after the item has been bought. It applies only
; if !availability = 1. By default it is set to become a solid block (like after
; hitting a question block). The list of values can be found here:
; https://www.smwcentral.net/?p=memorymap&a=detail&game=smw&region=ram&detail=dd11aeb933a0
!shop_after_usage = $0D


;-------------------------------------------------------------------------------
; Block setup
;-------------------------------------------------------------------------------

db $42

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV    : JMP SpriteH
JMP MarioCape  : JMP MarioFireball
JMP TopCorner  : JMP BodyInside : JMP HeadInside

MarioBelow:
  JMP BuyItem
MarioAbove:
MarioSide:
SpriteV:
SpriteH:
MarioCape:
MarioFireball:
TopCorner:
BodyInside:
HeadInside:
  RTL


;-------------------------------------------------------------------------------
; Include
;-------------------------------------------------------------------------------

incsrc shop__pay.asm


;-------------------------------------------------------------------------------
; Buy Item
;-------------------------------------------------------------------------------

BuyItem:
  ; Ensure block is hit only once
  LDA $7D                           ; If Mario is falling...
  BPL .dont_buy                     ; ...then don't buy

  ; Don't buy powerup if player already has it
  LDA $19 : CMP.b #!powerup         ; If player powerup is same as powerup for sale...
  BEQ .dont_buy                     ; ...then don't buy

  ; Pay (if possible)
  JSL ShopPay : BEQ .dont_buy

  ; Add item
  LDA.b #!powerup : STA $19         ; Add powerup to player
  LDA.b #!buy_sfx : STA $1DFC|!addr ; Play sound effect

  ; Transform block
if !availability > 0
  PHY : LDA.b #!shop_after_usage : STA $9C : JSL $00BEB0 : PLY
endif

  ; Finish
  RTL

  ; Don't buy
.dont_buy
  LDA.b #!dont_buy_sfx : STA $1DFC|!addr ; Play sound effect
  RTL


;-------------------------------------------------------------------------------
; Lunar Message Tooltip
;-------------------------------------------------------------------------------

print "Buy a powerup for the player by hitting the block from below"
