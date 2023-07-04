;===============================================================================
; CUSTOMIZE STATUS BAR
;===============================================================================

namespace nested off


;-------------------------------------------------------------------------------
; Private
;-------------------------------------------------------------------------------

; Do not change the order of the includes!
namespace "internal"

pushpc

; Global settings
incsrc "../csb_asm/settings.asm"

; Hijack
incsrc "../csb_asm/generic/hijacks.asm"

pullpc

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

namespace off


;-------------------------------------------------------------------------------
; Public
;-------------------------------------------------------------------------------

; This will make a given label public (i.e., without the "interal" prefix).
macro make_public(label)
    base internal_<label>
        <label>:
    base off
endmacro

; In the comment you find the name to use in UberASM code.
%make_public(main)      ; csb_main
%make_public(reset_ram) ; csb_reset_ram
