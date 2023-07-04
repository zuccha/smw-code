;===============================================================================
; CUSTOMIZE STATUS BAR
;===============================================================================

; Do not change the order of the includes!
namespace nested off

; Global settings
incsrc "../csb_asm/settings.asm"

; Hijack
incsrc "../csb_asm/generic/hijacks.asm"

; Utils
incsrc "../csb_asm/generic/reset.asm"
incsrc "../csb_asm/generic/utils.asm"

; Modules
incsrc "../csb_asm/modules/coins.asm"
incsrc "../csb_asm/modules/bonus_stars.asm"
incsrc "../csb_asm/modules/dragon_coins.asm"
incsrc "../csb_asm/modules/lives.asm"
incsrc "../csb_asm/modules/powerup.asm"
incsrc "../csb_asm/modules/score.asm"
incsrc "../csb_asm/modules/time.asm"

; Main routine
incsrc "../csb_asm/generic/main.asm"
