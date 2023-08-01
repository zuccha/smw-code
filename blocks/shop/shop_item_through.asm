;===============================================================================
; SHOP ITEM THROUGH
;===============================================================================

; A block that allows you to buy items for the item box, with a cost of your
; choosing.

; The block activates when the player goes through it.
; To buy the item, you need to have enough funds.
; You cannot buy items that you already have in the item box.

; This block should act as 25 (or anything non-solid).


;-------------------------------------------------------------------------------
; Configuration
;-------------------------------------------------------------------------------

; Item for sale, that will be added to the item box after buying it.
; 0 = none
; 1 = mushroom
; 2 = fire flower
; 3 = star
; 4 = feather
!item = 1

; How many time the player can buy the item.
; Right now only either one or infinite times is supported, you cannot specify
; arbitrary amounts.
!availability = 1 ; 0 = infinite, 1 = one

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

; Sound effect for when buying the item. The list of values can be found here:
; https://www.smwcentral.net/?p=memorymap&a=detail&game=smw&region=ram&detail=294be88c9dcc
!buy_sfx = $0B


;-------------------------------------------------------------------------------
; Block setup
;-------------------------------------------------------------------------------

db $42

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV    : JMP SpriteH
JMP MarioCape  : JMP MarioFireball
JMP TopCorner  : JMP BodyInside : JMP HeadInside

BodyInside:
  JMP BuyItem
MarioBelow:
MarioAbove:
MarioSide:
SpriteV:
SpriteH:
MarioCape:
MarioFireball:
TopCorner:
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
  ; Don't buy item if player already has it
  LDA $0DC2|!addr : CMP.b #!item    ; If item in item box is same as item for sale...
  BEQ .return                       ; ...then don't buy

  ; Pay (if possible)
  JSL ShopPay : BEQ .return

  ; Add item
  LDA.b #!item : STA $0DC2|!addr    ; Add item to item box
  LDA.b #!buy_sfx : STA $1DFC|!addr ; Play sound effect

  ; Remove Block
if !availability > 0
  %erase_block()
endif

  ; Return
.return
  RTL


;-------------------------------------------------------------------------------
; Lunar Message Tooltip
;-------------------------------------------------------------------------------

print "Buy an item for the item box by going through the block"
