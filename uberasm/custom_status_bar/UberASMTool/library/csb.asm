;===============================================================================
; CUSTOM STATUS BAR
;===============================================================================

; Library file Custom Status Bar.


;-------------------------------------------------------------------------------
; Setup
;-------------------------------------------------------------------------------

namespace nested off

namespace "internal"


;-------------------------------------------------------------------------------
; Utilities
;-------------------------------------------------------------------------------

macro include_file(filepath)
    incsrc "../csb_asm/<filepath>"
endmacro

macro include_code(filepath)
    %include_file("code/<filepath>")
endmacro


;-------------------------------------------------------------------------------
; Includes
;-------------------------------------------------------------------------------

; Do not change the order of the includes!

; Settings
pushpc
%include_file("settings.asm")
%include_file("colors.asm")
pullpc

; Hijack
%include_code("hijacks.asm")

; RAM
%include_file("ram.asm") ; RAM turns off namespace
namespace "internal"

; Utils
%include_code("utils.asm")
%include_code("reset.asm")
%include_file("callbacks.asm")

; Modules
%include_code("modules/coins.asm")
%include_code("modules/bonus_stars.asm")
%include_code("modules/dragon_coins.asm")
%include_code("modules/lives.asm")
%include_code("modules/power_up.asm")
%include_code("modules/score.asm")
%include_code("modules/time.asm")

; Main routine
%include_code("main.asm")

; Public stuff
%include_code("public.asm")
