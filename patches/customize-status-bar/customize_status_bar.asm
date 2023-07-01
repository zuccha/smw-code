;===============================================================================
; CUSTOMIZE STATUS BAR
;===============================================================================

; Author: zuccha
; Date: 2023/07/01
; Version: 1.0.0

; Based on HammerBrother's tutorial for the status bar.
; Credits are optional.

; Code for the patch, you probably don't want to touch any of this.
; For more, check out:
; - README.md: Generic description of what the patch does.
; - configuration/global.asm: Setting for configuring the status bar globally,
; with detailed explanation of what each setting does.
; - configuration/levels.asm: Tables for configuring individual level behaviours
; for the status bar.

; Do not change the order of the includes!

; SA-1 setup
incsrc "code/setup.asm"

; Global settings
incsrc "configuration/global.asm"

; Hijack
incsrc "code/hijack.asm"

; Level settings
incsrc "configuration/levels.asm"

; Utils
incsrc "code/utils.asm"

; Modules
incsrc "modules/coins.asm"
incsrc "modules/bonus_stars.asm"
incsrc "modules/dragon_coins.asm"
incsrc "modules/lives.asm"
incsrc "modules/powerup.asm"
incsrc "modules/score.asm"
incsrc "modules/time.asm"

; Main routine
incsrc "code/main.asm"
