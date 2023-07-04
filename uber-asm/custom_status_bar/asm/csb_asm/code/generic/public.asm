;===============================================================================
; PUBLIC
;===============================================================================

; List of name that will be usable in all UberASMTool's code. Routines and
; labels that are not public are prefixed with "internal".
; N.B.: This file turns off the namespace.


;-------------------------------------------------------------------------------
; Utils
;-------------------------------------------------------------------------------

; This will make a given label public (i.e., without the "interal" prefix).
; @param <label>: the name to make public.
macro make_public(label)
    base internal_<label>
        <label>:
    base off
endmacro


;-------------------------------------------------------------------------------
; Public Stuff
;-------------------------------------------------------------------------------

namespace off

; In the comment you find the name to use in UberASM code.
%make_public(main)      ; csb_main
%make_public(reset_ram) ; csb_reset_ram
