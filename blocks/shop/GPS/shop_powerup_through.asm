;===============================================================================
; SHOP POWERUP THROUGH
;===============================================================================

; A block that allows you to buy powerups for the player, with a cost of your
; choosing.

; The block activates when the player goes through it.
; To buy the item, you need to have enough funds.
; You cannot buy items that you already have in the item box.

; This block should act as 25 (or anything non-solid).


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
!buy_sfx = $3E ; Default = $3E (get powerup)


;-------------------------------------------------------------------------------
; Block Setup
;-------------------------------------------------------------------------------

db $42

JMP Return : JMP Return  : JMP Return   ; MarioBelow, MarioAbove, MarioSide
JMP Return : JMP Return                 ; SpriteV, SpriteH
JMP Return : JMP Return                 ; MarioCape, MarioFireball
JMP Return : JMP BuyItem : JMP Return   ; TopCorner, BodyInside, HeadInside

Return:
    RTL


;-------------------------------------------------------------------------------
; Buy Item
;-------------------------------------------------------------------------------

BuyItem:
    ; Don't buy powerup if player already has it
    LDA $19 : CMP.b #!powerup         ; If player powerup is same as powerup for sale...
    BEQ .return                       ; ...then don't buy

    ; Pay (if possible)
    LDA.b #!bonus_stars_cost : STA $00
    LDA.b #!coins_cost       : STA $01
    LDA.b #!lives_cost       : STA $02
    LDA.b #(!score_cost)     : STA $03
    LDA.b #(!score_cost<<8)  : STA $04
    LDA.b #(!score_cost<<16) : STA $05
    %check_and_pay() : BCC .return

    ; Add item
    LDA.b #!powerup : STA $19         ; Add powerup to player
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

print "Buy a powerup for the player by going through the block"
