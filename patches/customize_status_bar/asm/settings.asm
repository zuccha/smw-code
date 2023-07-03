;-------------------------------------------------------------------------------
; Bonus Stars
;-------------------------------------------------------------------------------

; Global setting for showing the bonus stars counter in the status bar.
; Values:
;   0 = Never
;   1 = Always (vanilla)
!BonusStarsVisibility = 1

; Symbol in front of the bonus stars counter.
; The value is the position of the 8x8 tile in "GFX28".
; Values: $00-$7F/$FC.
; Default: $64 (star).
; If you are using the modified GFX28 bundled with this patch, you can also use
; $3F (star, alternative), which replaces the second part of the "TIME" text, no
; longer used.
!BonusStarsSymbol = $64

; Whether the bonus stars amount is always checked, even if the indicator is not
; shown in the status bar (!BonusStarsVisibility = 0). If the bonus stars reach
; a specific threshold (default 100), the bonus game starts after the level.
; N.B.: This has not effect if !BonusStarsVisibility = 1.
; Values:
;   0 = Don't check bonus stars if indicator is disabled in status bar.
;   1 = Check bonus stars even if indicator is disabled in status bar.
!AlwaysCheckBonusStars = 0

; Bonus stars limit. If reached, the bonus game is triggered.
; Values: $00-$FF.
; Default: $64 (100) (vanilla).
!BonusStarsLimit = $64

; Whether the bonus game should start after the level if the bonus stars limit
; is reached.
; N.B.: This doesn't control whether the limit is reset, for that refer to
; !ResetBonusStarsIfBonusStarsLimitReached.
; Values:
;   0 = Don't add bonus stars when completing level
;   1 = Add bonus stars when completing level (vanilla)
!StartBonusGameIfBonusStarsLimitReached = 1

; Whether the game should reset the counter when the coin limit is reached.
; N.B.: This doesn't control whether the bonus game will start, for that refer
; to !StartBonusGameIfBonusStarsLimitReached.
; Values:
;   0 = Don't reset counter
;   1 = Reset counter (vanilla)
!ResetBonusStarsIfBonusStarsLimitReached = 1


;-------------------------------------------------------------------------------
; Coins
;-------------------------------------------------------------------------------

; Global setting for showing the coins counter in the status bar.
; Values:
;   0 = Never
;   1 = Always (vanilla)
;   2 = If limit > 0 (see "CoinLimitTable" in "configuration/levels.asm")
!CoinsVisibility = 1

; Symbol in front of the coins counter.
; The value is the position of the 8x8 tile in "GFX28".
; Values: $00-$7F/$FC.
; Default: $2E (coin).
!CoinsSymbol = $2E

; Whether the bonus stars amount is always checked, even if the indicator is not
; shown in the status bar (!CoinsVisibility = 0). If the bonus stars reach a
; specific threshold (default 100), the bonus game starts after the level.
; N.B.: This has not effect if !CoinsVisibility = 1.
; Values:
;   0 = Don't check bonus stars if indicator is disabled in status bar.
;   1 = Check bonus stars even if indicator is disabled in status bar.
!AlwaysCheckCoins = 0

; Coin limit. When the limit is reached, the vanilla game adds a life.
; Values: $00-$FF.
; Default: $64 (100) (vanilla).
!CoinsLimit = $64

; Whether the game should add a life when the coin limit is reached.
; N.B.: This doesn't control whether the limit is reset, for that refer to
; !ResetCoinsIfCoinsLimitReached.
; Values:
;   0 = Don't increase coins
;   1 = Increase coins (vanilla)
!AddLifeIfCoinsLimitReached = 1

; Whether the game should reset the counter when the coin limit is reached.
; N.B.: This doesn't control whether a life is added, for that refer to
; !AddLifeIfCoinsLimitReached.
; Values:
;   0 = Don't reset counter
;   1 = Reset counter (vanilla)
!ResetCoinsIfCoinsLimitReached = 1


;-------------------------------------------------------------------------------
; Lives
;-------------------------------------------------------------------------------

; Global setting for showing the lives counter in the status bar.
; Values:
;   0 = Never
;   1 = Always (vanilla)
!LivesVisibility = 1

; Symbol in front of the lives counter.
; The value is the position of the 8x8 tile in "GFX28".
; Values: $00-$7F/$FC.
; Default: $26 (x).
; If you are using the modified GFX28 bundled with this patch, you can also use
; $3E (heart), which replaces the second part of the "TIME" text, no longer used.
!LivesSymbol = $26


;-------------------------------------------------------------------------------
; Time
;-------------------------------------------------------------------------------

; Global setting for showing the time counter in the status bar.
; Values:
;   0 = Never
;   1 = Always (vanilla)
;   2 = If limit > 0 (via Lunar Magic)
!TimeVisibility = 1

; Symbol in front of the time counter.
; The value is the position of the 8x8 tile in "GFX28".
; Values: $00-$7F/$FC.
; Default: $76 (clock).
; If you are using the modified GFX28 bundled with this patch, the clock graphic
; has been lowered by 1 px, which is much better ;).
!TimeSymbol = $76

; Whether the time is always checked, even if the indicator is not shown in the
; status bar (!TimeVisibility = 0). If the timer reaches zero, the player will
; be killed.
; N.B.: This has not effect if !TimeVisibility = 1.
; Values:
;   0 = Don't decrease timer
;   1 = Decrease timer
!AlwaysCheckTime = 0

; Frequency for decreasing the timer. The timer will decrease every
; !TimeFrequency frames.
; Values: $00-$FE.
; Default: $28 (vanilla).
; You can set this value to $3C (60) to make the timer decrease every second (if
; the game runs at 60 FPS).
; N.B.: Don't use $FF as it is a reserved value (why would you use that anyway).
!TimeFrequency = $28


;-------------------------------------------------------------------------------
; Dragon Coins
;-------------------------------------------------------------------------------

; Global setting for showing the dragon coins counter in the status bar.
; Values:
;   0 = Never
;   1 = Always
;   2 = If not all coins have been collected (vanilla)
!DragonCoinsVisibility = 2

; Symbol for collected dragon coins.
; The value is the position of the 8x8 tile in "GFX28".
; Values: $00-$7F/$FC.
; Default: $2E (coin).
!DragonCoinsCollectedSymbol = $2E

; Symbol for missing dragon coins.
; The value is the position of the 8x8 tile in "GFX28".
; Values: $00-$7F/$FC.
; Default: $FC (empty).
; If you are using the modified GFX28 bundled with this patch, you can also use
; $3D (empty coin), which replaces the first part of the "TIME" text, no longer
; used.
!DragonCoinsMissingSymbol = $FC

; Show custom graphics if all dragon coins have been collected. The graphics
; can be configured using !DragonCoinsCollectedGraphics.
; Values:
;   0 = Disabled (vanilla)
;   - If !DragonCoinsVisibility = 1: You will see 5 coins.
;   - If !DragonCoinsVisibility = 2: You will see nothing.
;   1 = Enabled
;   - If !DragonCoinsVisibility = 1: You will see !DragonCoinsCollectedGraphics.
;   - If !DragonCoinsVisibility = 2: You will see !DragonCoinsCollectedGraphics
;   if you collected the coins in the current level attempt, otherwise the
;   indicator will not be visible at all (it will not occupy the slot).
!UseCustomDragonCoinsCollectedGraphics = 0

; List of graphics tiles to show when all coins have been collected in a level.
; This only applies if !UseCustomDragonCoinsCollectedGraphics = 1.
; Every element is a 8x8 tile in GFX28, $FC is an empty space.
; The list must have exactly 7 elements!
; Values: $00-$7F/$FC, $00-$7F/$FC, $00-$7F/$FC, $00-$7F/$FC, $00-$7F/$FC, $00-$7F/$FC, $00-$7F/$FC.
; Default: $0A, $15, $15, $28, $FC, $FC, $FC ("ALL!   ").
; If you are using the modified GFX28 bundled with this patch, you can also use
; `$2E, $2E, $2E, $2E, $2E, $3A, $FC`, where $2E are the coin symbol and $3A is
; a checkmark that replaces the corner of the item box in the graphics file.
!CustomDragonCoinsCollectedGraphics = $0A, $15, $15, $28, $FC, $FC, $FC


;-------------------------------------------------------------------------------
; Score
;-------------------------------------------------------------------------------

; Global setting for showing the score counter in the status bar.
; Values:
;   0 = Never
;   1 = Always (vanilla)
!ScoreVisibility = 1


;-------------------------------------------------------------------------------
; Power Up
;-------------------------------------------------------------------------------

; Global setting for showing the power up in the item box in the status bar.
; Values:
;   0 = Hidden if present in the item box, items can still be stored and dropped
;   1 = Visible if present in the item box (vanilla)
;   2 = Items cannot be stored and dropped
!PowerUpVisibility = 1

; X-coordinate for the powerup. This will modify both where the item is shown in
; the status bar and from where it drops (they are synced).
; Default: $78 (vanilla)
!PowerUpPositionX = $78


;-------------------------------------------------------------------------------
; Group 1
;-------------------------------------------------------------------------------

; Group 1 consists of: Bonus Stars, Coins, Lives, and Time. Slot size: 4x1.
; For an explanation on how groups and slots work, check "README.md".

; Order in which group 1 elements fill available slots. Reorder the elements to
; change their priority (leftmost elements have the highest priority).
; Values: !BonusStars, !Coins, !Lives, !Time.
; N.B.: Make sure to leave a space after every comma!
!Group1Order = !Lives, !BonusStars, !Time, !Coins

; Position of each slot where elements are displayed.
; The value is the RAM address for the status bar tiles (check "Status Bar
; Static Configuration" below). The address represents the first of the four
; tiles that the group 1 element occupies. The first tile is used for the symbol
; and the other three for the digits of the counter.
; N.B.: The color palette of each tile cannot be controlled dynamically. By
; default, it is set to be GWWW, that is gold for the symbol (tile 0) and white
; for the digits (tiles 1-3). The palette is configured the same way for all
; slots in the "Status Bar Static Configuration" down below.
; Values: $0EF9-$0F11/$0F15-$0F2C
; Default: $0F11, $0F2C, $0F0C, $0F27
!Group1Slots = $0F11, $0F2C, $0F0C, $0F27


;-------------------------------------------------------------------------------
; Group 2
;-------------------------------------------------------------------------------

; Group 2 consists of: Dragon Coins and Score. Slot size: 7x1. Notice that even
; if the Power Up per-level visibility is controlled in "Group2VisibilityTable",
; Power Up is not actually in group 2, its setting is stored there just to be
; space efficient.
; For an explanation on how groups and slots work, check "README.md".

; Order in which group 2 elements fill available slots. Reorder the elements to
; change their priority (leftmost elements have the highest priority).
; Values: !DragonCoins, !Score.
; N.B.: Make sure to leave a space after every comma!
!Group2Order = !Score, !DragonCoins

; Position of each slot where elements are displayed.
; The value is the RAM address for the status bar tiles (check "Status Bar
; Static Configuration" below). The address represents the first of the six
; tiles that the group 2 element occupies.
; N.B.: The color palette of each tile cannot be controlled dynamically. By
; default, all siz tiles are set to gold. The palette is configured the same way
; for all slots in the "Status Bar Static Configuration" down below.
; Values: $0EF9-$0F0E/$0F15-$0F29
; Default: $0EF9, $0F15
!Group2Slots = $0EF9, $0F15


;-------------------------------------------------------------------------------
; Status Bar Static Configuration
;-------------------------------------------------------------------------------

; Status bar configuration. Every line represents an 8x8 tile.
; Use only for static elements and for customizing the color palette of a given
; tile. N.B.: The color palette cannot be customized at runtime via RAM address!
; Without further modification, the patch erases the entirety of the status bar.
; Format: db <graphics>, <palette>
; - graphics: Hex address (e.g., $1A) in graphics file GFX28 to be used for the
;   8x8 tile. $FC means empty.
; - palette: Configuration for the color palette, formatted as %YXPCCCTT.
; To better understand how this works, I suggest you check out HammerBrother's
; tutorial on the status bar: https://www.smwcentral.net/?p=section&a=details&id=26018
!ColorEmpty = %00000000
!ColorGold  = %00111100
!ColorWhite = %00111000

org $008C81
    ; Top 4 tiles of the item box
    db $FC, !ColorWhite ; (14,01), ($0E,$01), RAM: N/A
    db $FC, !ColorWhite ; (15,01), ($0F,$01), RAM: N/A
    db $FC, !ColorWhite ; (16,01), ($10,$01), RAM: N/A
    db $FC, !ColorWhite ; (17,01), ($11,$01), RAM: N/A
org $008C89
    ; Top row:
    db $FC, !ColorGold  ; (02,02), ($02,$02), RAM: $0EF9
    db $FC, !ColorGold  ; (03,02), ($03,$02), RAM: $0EFA
    db $FC, !ColorGold  ; (04,02), ($04,$02), RAM: $0EFB
    db $FC, !ColorGold  ; (05,02), ($05,$02), RAM: $0EFC
    db $FC, !ColorGold  ; (06,02), ($06,$02), RAM: $0EFD
    db $FC, !ColorGold  ; (07,02), ($07,$02), RAM: $0EFE
    db $FC, !ColorGold  ; (08,02), ($08,$02), RAM: $0EFF
    db $FC, !ColorEmpty ; (09,02), ($09,$02), RAM: $0F00
    db $FC, !ColorEmpty ; (10,02), ($0A,$02), RAM: $0F01
    db $FC, !ColorEmpty ; (11,02), ($0B,$02), RAM: $0F02
    db $FC, !ColorEmpty ; (12,02), ($0C,$02), RAM: $0F03
    db $FC, !ColorEmpty ; (13,02), ($0D,$02), RAM: $0F04
    db $FC, !ColorEmpty ; (14,02), ($0E,$02), RAM: $0F05
    db $FC, !ColorWhite ; (15,02), ($0F,$02), RAM: $0F06
    db $FC, !ColorWhite ; (16,02), ($10,$02), RAM: $0F07
    db $FC, !ColorEmpty ; (17,02), ($11,$02), RAM: $0F08
    db $FC, !ColorEmpty ; (18,02), ($12,$02), RAM: $0F09
    db $FC, !ColorEmpty ; (19,02), ($13,$02), RAM: $0F0A
    db $FC, !ColorEmpty ; (20,02), ($14,$02), RAM: $0F0B
    db $FC, !ColorGold  ; (21,02), ($15,$02), RAM: $0F0C
    db $FC, !ColorWhite ; (22,02), ($16,$02), RAM: $0F0D
    db $FC, !ColorWhite ; (23,02), ($17,$02), RAM: $0F0E
    db $FC, !ColorWhite ; (24,02), ($18,$02), RAM: $0F0F
    db $FC, !ColorEmpty ; (25,02), ($19,$02), RAM: $0F10
    db $FC, !ColorGold  ; (26,02), ($1A,$02), RAM: $0F11
    db $FC, !ColorWhite ; (27,02), ($1B,$02), RAM: $0F12
    db $FC, !ColorWhite ; (28,02), ($1C,$02), RAM: $0F13
    db $FC, !ColorWhite ; (29,02), ($1D,$02), RAM: $0F14
    ; Bottom row:
    ; Not available :(  ; (02,03), ($02,$03), RAM: N/A
    db $FC, !ColorGold  ; (03,03), ($03,$03), RAM: $0F15
    db $FC, !ColorGold  ; (04,03), ($04,$03), RAM: $0F16
    db $FC, !ColorGold  ; (05,03), ($05,$03), RAM: $0F17
    db $FC, !ColorGold  ; (06,03), ($06,$03), RAM: $0F18
    db $FC, !ColorGold  ; (07,03), ($07,$03), RAM: $0F19
    db $FC, !ColorGold  ; (08,03), ($08,$03), RAM: $0F1A
    db $FC, !ColorGold  ; (09,03), ($09,$03), RAM: $0F1B
    db $FC, !ColorEmpty ; (10,03), ($0A,$03), RAM: $0F1C
    db $FC, !ColorEmpty ; (11,03), ($0B,$03), RAM: $0F1D
    db $FC, !ColorEmpty ; (12,03), ($0C,$03), RAM: $0F1E
    db $FC, !ColorEmpty ; (13,03), ($0D,$03), RAM: $0F1F
    db $FC, !ColorEmpty ; (14,03), ($0E,$03), RAM: $0F20
    db $FC, !ColorWhite ; (15,03), ($0F,$03), RAM: $0F21
    db $FC, !ColorWhite ; (16,03), ($10,$03), RAM: $0F22
    db $FC, !ColorEmpty ; (17,03), ($11,$03), RAM: $0F23
    db $FC, !ColorEmpty ; (18,03), ($12,$03), RAM: $0F24
    db $FC, !ColorEmpty ; (19,03), ($13,$03), RAM: $0F25
    db $FC, !ColorEmpty ; (20,03), ($14,$03), RAM: $0F26
    db $FC, !ColorGold  ; (21,03), ($15,$03), RAM: $0F27
    db $FC, !ColorWhite ; (22,03), ($16,$03), RAM: $0F28
    db $FC, !ColorWhite ; (23,03), ($17,$03), RAM: $0F29
    db $FC, !ColorWhite ; (24,03), ($18,$03), RAM: $0F2A
    db $FC, !ColorEmpty ; (25,03), ($19,$03), RAM: $0F2B
    db $FC, !ColorGold  ; (26,03), ($1A,$03), RAM: $0F2C
    db $FC, !ColorWhite ; (27,03), ($1B,$03), RAM: $0F2D
    db $FC, !ColorWhite ; (28,03), ($1C,$03), RAM: $0F2E
    db $FC, !ColorWhite ; (29,03), ($1D,$03), RAM: $0F2F
org $008CF7
    ; Bottom 4 tiles of the item box
    db $FC, !ColorWhite ; (14,04), ($0E,$04), RAM: N/A
    db $FC, !ColorWhite ; (15,04), ($0F,$04), RAM: N/A
    db $FC, !ColorWhite ; (16,04), ($10,$04), RAM: N/A
    db $FC, !ColorWhite ; (17,04), ($11,$04), RAM: N/A
