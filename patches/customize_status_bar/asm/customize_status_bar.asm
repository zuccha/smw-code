;===============================================================================
; CUSTOMIZE STATUS BAR
;===============================================================================

; Do not change the order of the includes!

; SA-1 setup
incsrc "patch/generic/setup.asm"

; Global settings
incsrc "settings.asm"

; Hijack
incsrc "patch/generic/hijack.asm"

; Utils
incsrc "patch/generic/utils.asm"

; Modules
incsrc "patch/modules/coins.asm"
incsrc "patch/modules/bonus_stars.asm"
incsrc "patch/modules/dragon_coins.asm"
incsrc "patch/modules/lives.asm"
incsrc "patch/modules/powerup.asm"
incsrc "patch/modules/score.asm"
incsrc "patch/modules/time.asm"

; Main routine
incsrc "patch/generic/main.asm"
