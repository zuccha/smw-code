;===============================================================================
; RAM
;===============================================================================

; Prepare RAM addresses for usage in the code.
; The patch requires 34 bytes of free contiguous RAM. Its position can be
; configured down below.


;-------------------------------------------------------------------------------
; Base Address
;-------------------------------------------------------------------------------

; This patch requires 34 bytes of free contiguous RAM to store settings that can
; be changed dynamically (mostly used for per-level customization).
; RAM starts at the address indicated here. Unless you have some conflics with
; other custom code, you won't need to change it.
; * Values: Any address in free space.
; * Default: $7FB700
!freeram_address = $7FB700


;-------------------------------------------------------------------------------
; Instructions
;-------------------------------------------------------------------------------

; This file generates labels for all the RAM addresses for CSB. Addresses are
; always in the shape `ram_<setting_name>`, or `csb_ram_<setting_name>` if
; used in UberASMTool. The variant `!ram_<setting_name>` with the exclamation
; mark is also available outside of UberASMTool.

; Example usage in UberASMTool:
;   STA #$00 : LDA csb_ram_coins_visibility

; Example usage in outside UberASMTool (e.g., GPS):
;   STA #$00 : LDA csb_ram_coins_visibility
; or
;   STA #$00 : LDA !csb_ram_coins_visibility

; If you want to use the addresses for blocks or sprites, copy the contents of,
; or include, this file in your code.
; N.B.: If you change !freeram_address here, you'll have to change it in any
; other file where you copied this one!
; If you don't feel like copying too much stuff, you can just copy the base
; address, the `define_ram` macro, and the definitions for the addresses you
; want (don't change the offset!). For example:
;   !freeram_address = $7FB700
;   macro define_ram(offset, name)
;       !ram_<name> = !freeram_address+<offset>
;       base !ram_<name>
;           ram_<name>:
;       base off
;   endmacro
;   %define_ram($07, coins_visibility)
;   %define_ram($08, coins_symbol)

; For UberASMTool you don't need to do anything, since it is automatically
; included.


;-------------------------------------------------------------------------------
; Utils
;-------------------------------------------------------------------------------

; Define an address with a given size.
; This will produce a label accessible with `ram_<name>`. For instance:
;   define_ram_size(status_bar_visibility, $01)
; will make `ram_status_bar_visibility` usable in the code as follows:
;   LDA $01 : STA ram_status_bar_visibility ; Enable status bar
macro define_ram(offset, name)
    !ram_<name> = !freeram_address+<offset>
    base !ram_<name>
        ram_<name>:
    base off
endmacro


;-------------------------------------------------------------------------------
; Definitions
;-------------------------------------------------------------------------------

; Define one address for (almost) every setting.
namespace off

; General
%define_ram($00, status_bar_visibility)

; Bonus Stars
%define_ram($01, bonus_stars_visibility)
%define_ram($02, bonus_stars_symbol)
%define_ram($03, always_check_bonus_stars)
%define_ram($04, bonus_stars_limit)
%define_ram($05, start_bonus_game_when_bonus_stars_limit_reached)
%define_ram($06, reset_bonus_stars_when_bonus_stars_limit_reached)

; Coins
%define_ram($07, coins_visibility)
%define_ram($08, coins_symbol)
%define_ram($09, always_check_coins)
%define_ram($0A, coins_limit)
%define_ram($0B, add_life_when_coins_limit_reached)
%define_ram($0C, reset_coins_when_coins_limit_reached)

; Life
%define_ram($0D, lives_visibility)
%define_ram($0E, lives_symbol)

; Time
%define_ram($0F, time_visibility)
%define_ram($10, time_symbol)
%define_ram($11, always_check_time)
%define_ram($12, kill_player_when_time_runs_out)
%define_ram($13, time_frequency)

; Dragon Coins
%define_ram($14, dragon_coins_visibility)
%define_ram($15, dragon_coins_collected_symbol)
%define_ram($16, dragon_coins_missing_symbol)
%define_ram($17, use_custom_dragon_coins_collected_graphics)
%define_ram($18, custom_dragon_coins_collected_graphics)

; Score
%define_ram($1F, score_visibility)

; Power Up
%define_ram($20, power_up_visibility)
%define_ram($21, power_up_position_x)
