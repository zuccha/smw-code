;===============================================================================
; CUSTOMIZE STATUS BAR
;===============================================================================

; Do not change the order of the includes!
namespace nested off

; Global settings
incsrc "../status_bar_asm/settings.asm"

; Hijack
incsrc "../status_bar_asm/generic/hijack.asm"

; Utils
incsrc "../status_bar_asm/generic/reset.asm"
incsrc "../status_bar_asm/generic/utils.asm"

; Modules
incsrc "../status_bar_asm/modules/coins.asm"
incsrc "../status_bar_asm/modules/bonus_stars.asm"
incsrc "../status_bar_asm/modules/dragon_coins.asm"
incsrc "../status_bar_asm/modules/lives.asm"
incsrc "../status_bar_asm/modules/powerup.asm"
incsrc "../status_bar_asm/modules/score.asm"
incsrc "../status_bar_asm/modules/time.asm"

; Main routine
incsrc "../status_bar_asm/generic/main.asm"
