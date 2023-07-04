;===============================================================================
; CUSTOMIZE STATUS BAR
;===============================================================================

namespace nested off


;-------------------------------------------------------------------------------
; Private
;-------------------------------------------------------------------------------

; Do not change the order of the includes!
namespace "internal"

macro include_file(filepath)
    incsrc "../csb_asm/<filepath>"
endmacro

macro include_code(filepath)
    %include_file("code/<filepath>")
endmacro

pushpc

; Settings
%include_file("settings.asm")
%include_file("colors.asm")
%include_file("ram.asm")

; Hijack
%include_code("generic/hijacks.asm")

pullpc

; Utils
%include_code("generic/reset.asm")
%include_code("generic/utils.asm")

; Modules
%include_code("modules/coins.asm")
%include_code("modules/bonus_stars.asm")
%include_code("modules/dragon_coins.asm")
%include_code("modules/lives.asm")
%include_code("modules/powerup.asm")
%include_code("modules/score.asm")
%include_code("modules/time.asm")

; Main routine
%include_code("generic/main.asm")

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
