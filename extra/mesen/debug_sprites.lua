--==============================================================================
-- DEBUG SPRITES
--==============================================================================

-- This is a script for highlighting some aspects of SMW sprites.
-- Custom font copied from Snes9x-rr.

-- Notes: 
--   - The script requires PIXI to be installed in the ROM.
--   - The script works only for normal sprites, not cluster, extended, etc.

-- Features:
--   - Draw clipping box around Mario.
--   - Draw object and sprite clipping box around sprites.
--   - Draw sprite number next to sprites.
--   - Show list of sprites with some of their properties.
--   - Select sprite on click. You can chose which tables to display for
--     selected sprites.


--------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------

function config()
	font = MONOSPACE_FONT -- MONOSPACE_FONT or nil (default Mesen font)

	show_player_clipping  = true
	player_clipping_color = 0xFF0000

	min_sprite_status_to_show = 8

	show_sprite_index     = true
	sprite_index_offset_x = 0
	sprite_index_offset_y = -8
	
	show_sprite_clipping_obj  = true
	show_sprite_clipping_spr  = true
	clipping_spr_rect_opacity = 0xC0
	
	sprites_info_offset_x   = 4
	sprites_info_offset_y   = 12 -- 42 is below status bar
	sprites_info_row_height = 8
	
	show_sprite_info_number   = true
	show_sprite_info_status   = true
	show_sprite_info_position = true
	show_inactive_sprite_info = false
	
	sprite_custom_suffix = "c"
	sprite_normal_suffix = "n"
	
	selected_sprite_info_offset_x     = 4
	selected_sprite_info_offset_y     = 12 -- 42 is below status bar
	selected_sprite_info_row_height   = 8
	selected_sprite_info_default_base = 16
	
	-- Table entries are either:
	--   - number (RAM address)
	--   - { ram   = number (required), label = string (default = ram), base = number (default = 16) }
	sprite_tables_to_print = {
		{ label = "Blocked", ram = ram_sprite_blocked_status, base = 2 },
		{ label = "Speed X", ram = ram_sprite_speed_x },
		{ label = "Speed Y", ram = ram_sprite_speed_y },
	}
	
	sprite_color_fgs = {
	  0xFF6B6B, 0xFFB86B, 0xFFEB6B, 0x6BFF92, 0x6BCFFF, 0xC06BFF, 0xFF6BDC, 0x6BE6FF,
	  0xFFA07A, 0xB3E06B, 0x50D9B3, 0x6B86FF, 0xFF5691, 0x4DDC74, 0xFF4F5E, 0xFF9C4F,
	  0xE84A4A, 0x4A96E8, 0xA04AE8, 0xC04A4A, 0xFF8282, 0xC1FF4A, 0x4AFFE6, 0xFF4A9D,
	}
	
	sprite_color_bgs = {
	  0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000,
	  0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000,
	  0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000,
	}
	
	inactive_sprite_color_fg = 0xAAAAAA
	inactive_sprite_color_bg = 0x000000
end


--------------------------------------------------------------------------------
-- Defines
--------------------------------------------------------------------------------

function defines()
	screen_offset_y = 7
	
	ram_screen_x = ram_addr(0x1A)
	ram_screen_y = ram_addr(0x1C)
	
	ram_player_x          = ram_addr(0x94)
	ram_player_y          = ram_addr(0x96)
	ram_player_is_ducking = ram_addr(0x73)
	ram_player_on_yoshi   = ram_addr(0x187A)
	ram_player_powerup    = ram_addr(0x19)
	
	rom_player_clipping_disp_x = rom_addr(0x03B669)
	rom_player_clipping_disp_y = rom_addr(0x03B65C)
	rom_player_clipping_width  = rom_addr(0x03B673)
	rom_player_clipping_height = rom_addr(0x03B660)
	
	sprites_count                = is_sa1 and 0x16 or 0x0C
	ram_sprite_number_regular    = ram_addr(0x9E, 0x3200)
	ram_sprite_number_custom     = ram_addr(0x7FAB9E, 0x6083)
	ram_sprite_extra_bits        = ram_addr(0x7FAB10, 0x6040)
	ram_sprite_extra_byte_1      = ram_addr(0x7FAB40, 0x6099)
	ram_sprite_extra_byte_2      = ram_addr(0x7FAB4C, 0x60AF)
	ram_sprite_extra_byte_3      = ram_addr(0x7FAB58, 0x60C5)
	ram_sprite_extra_byte_4      = ram_addr(0x7FAB64, 0x60DB)
	ram_sprite_extra_prop_1      = ram_addr(0x7FAB28, 0x6057)
	ram_sprite_extra_prop_2      = ram_addr(0x7FAB34, 0x606D)
	ram_sprite_tweaker_1         = ram_addr(0x1656, 0x75D0)
	ram_sprite_tweaker_2         = ram_addr(0x1662, 0x75EA)
	ram_sprite_tweaker_3         = ram_addr(0x166E, 0x7600)
	ram_sprite_tweaker_4         = ram_addr(0x167A, 0x7616)
	ram_sprite_tweaker_5         = ram_addr(0x1686, 0x762C)
	ram_sprite_tweaker_6         = ram_addr(0x190F, 0x7658)
	ram_sprite_oam_index         = ram_addr(0x15EA, 0x33A2)
	ram_sprite_oam_properties    = ram_addr(0x15F6, 0x33B8)
	ram_sprite_status            = ram_addr(0x14C8, 0x3242)
	ram_sprite_x_l               = ram_addr(0xE4, 0x322C)
	ram_sprite_x_h               = ram_addr(0x14E0, 0x326E)
	ram_sprite_y_l               = ram_addr(0xD8, 0x3216)
	ram_sprite_y_h               = ram_addr(0x14D4, 0x3258)
	ram_sprite_speed_x           = ram_addr(0xB6, 0xB6)
	ram_sprite_speed_x_frac      = ram_addr(0x14F8, 0x74DE)
	ram_sprite_speed_y           = ram_addr(0xAA, 0x9E)
	ram_sprite_speed_y_frac      = ram_addr(0x14EC, 0x74C8)
	ram_sprite_behind_scenery    = ram_addr(0x1632, 0x75A4)
	ram_sprite_being_eaten       = ram_addr(0x15D0, 0x754C)
	ram_sprite_blocked_status    = ram_addr(0x1588, 0x334A)
	ram_sprite_cape_disable_time = ram_addr(0x1FE2, 0x7FD6)
	ram_sprite_in_water          = ram_addr(0x164A, 0x75BA)
	ram_sprite_index_in_level    = ram_addr(0x161A, 0x7578)
	ram_sprite_obj_interact      = ram_addr(0x15DC, 0x7562)
	ram_sprite_off_screen        = ram_addr(0x15C4, 0x7536)
	ram_sprite_off_screen_horz   = ram_addr(0x15A0, 0x3376)
	ram_sprite_off_screen_vert   = ram_addr(0x186C, 0x7642)
	ram_sprite_slope             = ram_addr(0x15B8, 0x7520)
	ram_sprite_misc_C2           = ram_addr(0xC2, 0xD8)
	ram_sprite_misc_1504         = ram_addr(0x1504, 0x74F4)
	ram_sprite_misc_1510         = ram_addr(0x1510, 0x750A)
	ram_sprite_misc_151C         = ram_addr(0x151C, 0x3284)
	ram_sprite_misc_1528         = ram_addr(0x1528, 0x329A)
	ram_sprite_misc_1534         = ram_addr(0x1534, 0x32B0)
	ram_sprite_misc_1540         = ram_addr(0x1540, 0x32C6)
	ram_sprite_misc_154C         = ram_addr(0x154C, 0x32DC)
	ram_sprite_misc_1558         = ram_addr(0x1558, 0x32F2)
	ram_sprite_misc_1564         = ram_addr(0x1564, 0x3308)
	ram_sprite_misc_1570         = ram_addr(0x1570, 0x331E)
	ram_sprite_misc_157C         = ram_addr(0x157C, 0x3334)
	ram_sprite_misc_1594         = ram_addr(0x1594, 0x3360)
	ram_sprite_misc_15AC         = ram_addr(0x15AC, 0x338C)
	ram_sprite_misc_1602         = ram_addr(0x1602, 0x33CE)
	ram_sprite_misc_160E         = ram_addr(0x160E, 0x33E4)
	ram_sprite_misc_1626         = ram_addr(0x1626, 0x758E)
	ram_sprite_misc_163E         = ram_addr(0x163E, 0x33FA)
	ram_sprite_misc_187B         = ram_addr(0x187B, 0x3410)
	ram_sprite_misc_1FD6         = ram_addr(0x1FD6, 0x766E)
	
	ram_sprite_oam_x     = ram_addr(0x0300)
	ram_sprite_oam_y     = ram_addr(0x0301)
	ram_sprite_oam_tile  = ram_addr(0x0302)
	ram_sprite_oam_props = ram_addr(0x0303)
	
	rom_sprite_clipping_obj_x = rom_addr(0x0190BA)
	rom_sprite_clipping_obj_y = rom_addr(0x0190F7)
	
	rom_sprite_clipping_spr_disp_x = rom_addr(0x03B56C)
	rom_sprite_clipping_spr_disp_y = rom_addr(0x03B5E4)
	rom_sprite_clipping_spr_width  = rom_addr(0x03B5A8)
	rom_sprite_clipping_spr_height = rom_addr(0x03B620)
end


--------------------------------------------------------------------------------
-- Utils
--------------------------------------------------------------------------------

function ram_addr(addr_lorom, addr_sa1)
	if not is_sa1 then return addr_lorom end
	if addr_sa1 ~= nil then
		return addr_sa1 > 0xFF and addr_sa1 or addr_sa1 | 0x3000
	end
	addr_sa1 = addr_lorom & 0x1FFFF
	if addr_sa1 < 0x100   then return addr_sa1 | 0x3000 end
    if addr_sa1 < 0x10000 then return addr_sa1 | 0x6000 end
	return addr_sa1 | 0x400000
end

function rom_addr(addr)
    local bank = addr >> 16
    local offset = addr & 0x7FFF
    return bank * 0x8000 + offset
end

function read_ram_byte(addr, signed)
	return emu.read(addr, emu.memType.snesMemory, signed)
end

function read_ram_word(addr, signed)
	return emu.read16(addr, emu.memType.snesMemory, signed)
end

function read_rom_byte(addr, signed)
	return emu.read(addr, emu.memType.snesPrgRom, signed)
end

function read_rom_word(addr, signed)
	return emu.read16(addr, emu.memType.snesPrgRom, signed)
end

function format_byte(byte)
	return string.format("%02X", byte)
end

function format_word(word)
	return string.format("%04X", word)
end

function format_sprite_info(sprite)
	local info = (sprite.is_selected and "> " or "  ") .. "#" .. format_byte(sprite.index)
	if show_sprite_info_number   then info = info .. " " .. format_byte(sprite.number) .. (sprite.is_custom and sprite_custom_suffix or sprite_normal_suffix) end
	if show_sprite_info_status   then info = info .. " " .. format_byte(read_ram_byte(ram_sprite_status + sprite.index)) end
	if show_sprite_info_position then info = info .. " " .. "(" .. format_word(sprite.x) .. ", " .. format_word(sprite.y) .. ")" end
	return info
end

function format_sprite_table(sprite_table, index)
	local value = read_ram_byte(sprite_table.ram + index)
	local label = sprite_table.label or format_word(sprite_table.ram)
	local base  = sprite_table.base or selected_sprite_info_default_base
	return label .. ": " .. number_to_string(value, base)
end

function format_sprite_oam(sprite_oam_index, slot)
	local index = sprite_oam_index + slot * 4
	return "OAM " .. (slot + 1) .. " >> " ..
		"X: " .. format_byte(read_ram_byte(ram_sprite_oam_x + index)) .. " " ..
		"Y: " .. format_byte(read_ram_byte(ram_sprite_oam_y + index)) .. " " ..
		"Tile: " .. format_byte(read_ram_byte(ram_sprite_oam_tile + index)) .. " " ..
		"Props: " .. number_to_string(read_ram_byte(ram_sprite_oam_props + index), 2)
end

function number_to_string(number, base)
	local formatted_number = ""
	repeat
	  local remainder = math.fmod(number, base)
	  formatted_number = digits[remainder] .. formatted_number
	  number = (number - remainder) / base
	until number == 0
	local digits_count = math.floor(math.log(255, base)) + 1
	return string.rep("0", digits_count - #formatted_number) .. formatted_number
end

function draw_clipping_spr(clipping, color)
	emu.drawRectangle(clipping.screen_x, clipping.screen_y, clipping.width, clipping.height, color)
	emu.drawRectangle(clipping.screen_x, clipping.screen_y, clipping.width, clipping.height, (clipping_spr_rect_opacity << 24) | color, true)
end

function draw_clipping_obj(clipping, color)
	local top    = { x = clipping.top_screen_x,    y = clipping.top_screen_y    }
	local bottom = { x = clipping.bottom_screen_x, y = clipping.bottom_screen_y }
	local left   = { x = clipping.left_screen_x,   y = clipping.left_screen_y   }
	local right  = { x = clipping.right_screen_x,  y = clipping.right_screen_y  }
	emu.drawLine(top.x,    top.y,    top.x,        top.y    + 2, color)
	emu.drawLine(bottom.x, bottom.y, bottom.x,     bottom.y - 2, color)
	emu.drawLine(left.x,   left.y,   left.x   + 2, left.y,       color)
	emu.drawLine(right.x,  right.y,  right.x  - 2, right.y,      color)
		
	--local x = math.min(top.x, bottom.x, left.x, right.x)
	--local y = math.min(top.y, bottom.y, left.y, right.y)
	--local w = math.max(top.x, bottom.x, left.x, right.x) - x + 1
	--local h = math.max(top.y, bottom.y, left.y, right.y) - y + 1
	--emu.drawRectangle(x, y, w, h, 0x77000000)
end

function draw_selected_sprite_info_row(sprite, text)
	draw_string(
		selected_sprite_info_offset_x,
		selected_sprite_info_offset_y + selected_sprite_info_row_height * selected_sprite_info_row_index,
		text,
		sprite.color.fg,
		sprite.color.bg)
	selected_sprite_info_row_index = selected_sprite_info_row_index + 1
end

function draw_sprites_info_row(sprite)
	local sprite_info = format_sprite_info(sprite)
	local char_width = font ~= nil and font.width - 1 or 6

	draw_string(
		SCREEN_W - #sprite_info * char_width - sprites_info_offset_x,
		sprites_info_offset_y + sprites_info_row_height * sprites_info_row_index,
		sprite_info,
		sprite.color.fg,
		sprite.color.bg)
	sprites_info_row_index = sprites_info_row_index + 1
end


--------------------------------------------------------------------------------
-- Debug Sprites
--------------------------------------------------------------------------------

function debug_sprites()
	sprites_info_row_index = 0
	selected_sprite_info_row_index = 0

	local screen_x = read_ram_word(ram_screen_x)
	local screen_y = read_ram_word(ram_screen_y) - screen_offset_y
	
	local mouse_state = emu.getMouseState()
	local is_left_mouse_click = not prev_mouse_left and mouse_state.left
	prev_mouse_left = mouse_state.left
	local sprite_overlapping_with_mouse = nil
	
	local player = {}
	
	player.x = read_ram_word(ram_player_x)
	player.y = read_ram_word(ram_player_y)
	
	player.screen_x = player.x - screen_x
	player.screen_y = player.y - screen_y
	
	player.clipping = {}
	
	player.clipping.index = (read_ram_byte(ram_player_is_ducking) > 0 or read_ram_byte(ram_player_powerup) == 0) and 1 or 0
	if read_ram_byte(ram_player_on_yoshi) > 0 then player.clipping.index = player.clipping.index + 2 end
	
	player.clipping.disp_x = read_rom_byte(rom_player_clipping_disp_x)
	player.clipping.disp_y = read_rom_byte(rom_player_clipping_disp_y + player.clipping.index)
	player.clipping.width  = read_rom_byte(rom_player_clipping_width)
	player.clipping.height = read_rom_byte(rom_player_clipping_height + player.clipping.index)
	
	player.clipping.screen_x = player.screen_x + player.clipping.disp_x
	player.clipping.screen_y = player.screen_y + player.clipping.disp_y
	if show_player_clipping then draw_clipping_spr(player.clipping, player_clipping_color) end

	for i = 0, sprites_count - 1 do
		local sprite = {}
		
		sprite.index = i
		sprite.is_custom = (read_ram_byte(ram_sprite_extra_bits + i) & 0x08) ~= 0
		sprite.number = sprite.is_custom
			and read_ram_byte(ram_sprite_number_custom + i)
			or  read_ram_byte(ram_sprite_number_regular + i)
		
		sprite.x = (read_ram_byte(ram_sprite_x_h + i) << 8) + read_ram_byte(ram_sprite_x_l + i)
		sprite.y = (read_ram_byte(ram_sprite_y_h + i) << 8) + read_ram_byte(ram_sprite_y_l + i)
		
		sprite.screen_x = sprite.x - screen_x
		sprite.screen_y = sprite.y - screen_y
		
		local oci = (read_ram_byte(ram_sprite_tweaker_1 + i) & 0x0F) << 2 -- Object clipping index
		local sci = (read_ram_byte(ram_sprite_tweaker_2 + i) & 0x3F)      -- Sprite clipping index
		
		sprite.clipping_obj                 = {}
		sprite.clipping_obj.index           = oci
		sprite.clipping_obj.right_x         = read_rom_byte(rom_sprite_clipping_obj_x + oci)
		sprite.clipping_obj.right_y         = read_rom_byte(rom_sprite_clipping_obj_y + oci)
		sprite.clipping_obj.left_x          = read_rom_byte(rom_sprite_clipping_obj_x + oci + 1)
		sprite.clipping_obj.left_y          = read_rom_byte(rom_sprite_clipping_obj_y + oci + 1)
		sprite.clipping_obj.bottom_x        = read_rom_byte(rom_sprite_clipping_obj_x + oci + 2)
		sprite.clipping_obj.bottom_y        = read_rom_byte(rom_sprite_clipping_obj_y + oci + 2)
		sprite.clipping_obj.top_x           = read_rom_byte(rom_sprite_clipping_obj_x + oci + 3)
		sprite.clipping_obj.top_y           = read_rom_byte(rom_sprite_clipping_obj_y + oci + 3)
		sprite.clipping_obj.right_screen_x  = sprite.screen_x + sprite.clipping_obj.right_x
		sprite.clipping_obj.right_screen_y  = sprite.screen_y + sprite.clipping_obj.right_y
		sprite.clipping_obj.left_screen_x   = sprite.screen_x + sprite.clipping_obj.left_x
		sprite.clipping_obj.left_screen_y   = sprite.screen_y + sprite.clipping_obj.left_y
		sprite.clipping_obj.bottom_screen_x = sprite.screen_x + sprite.clipping_obj.bottom_x
		sprite.clipping_obj.bottom_screen_y = sprite.screen_y + sprite.clipping_obj.bottom_y
		sprite.clipping_obj.top_screen_x    = sprite.screen_x + sprite.clipping_obj.top_x
		sprite.clipping_obj.top_screen_y    = sprite.screen_y + sprite.clipping_obj.top_y
		
		sprite.clipping_spr          = {}
		sprite.clipping_spr.index    = sci
		sprite.clipping_spr.disp_x   = read_rom_byte(rom_sprite_clipping_spr_disp_x + sci, true)
		sprite.clipping_spr.disp_y   = read_rom_byte(rom_sprite_clipping_spr_disp_y + sci, true)
		sprite.clipping_spr.width    = read_rom_byte(rom_sprite_clipping_spr_width  + sci)
		sprite.clipping_spr.height   = read_rom_byte(rom_sprite_clipping_spr_height + sci)
		sprite.clipping_spr.x        = sprite.x + sprite.clipping_spr.disp_x
		sprite.clipping_spr.y        = sprite.y + sprite.clipping_spr.disp_y
		sprite.clipping_spr.screen_x = sprite.screen_x + sprite.clipping_spr.disp_x
		sprite.clipping_spr.screen_y = sprite.screen_y + sprite.clipping_spr.disp_y
		
		if selected_sprite ~= nil and selected_sprite.index == i then
			selected_sprite = sprite
			sprite.is_selected = true
		end
		
		if sprite.clipping_spr.screen_x <= mouse_state.x                              and
	   	mouse_state.x <= sprite.clipping_spr.screen_x + sprite.clipping_spr.width  and
	   	sprite.clipping_spr.screen_y <= mouse_state.y                              and
	   	mouse_state.y <= sprite.clipping_spr.screen_y + sprite.clipping_spr.height then
			sprite_overlapping_with_mouse = sprite
		end
		
		local is_active = read_ram_byte(ram_sprite_status + i) >= min_sprite_status_to_show
		sprite.color = is_active
			and { fg = sprite_color_fgs[sprite.index + 1], bg = sprite_color_bgs[sprite.index + 1] }
			 or { fg = inactive_sprite_color_fg,           bg = inactive_sprite_color_bg           }
		
		if is_active or show_inactive_sprite_info then
			draw_sprites_info_row(sprite)
		end
		
		if is_active then
			if show_sprite_clipping_spr then draw_clipping_spr(sprite.clipping_spr, sprite.color.fg) end
			if show_sprite_clipping_obj then draw_clipping_obj(sprite.clipping_obj, sprite.color.fg) end
				
			if show_sprite_index then
				draw_string(
					sprite.screen_x + sprite_index_offset_x,
					sprite.screen_y + sprite_index_offset_y,
					"#" .. format_byte(sprite.index),
					sprite.color.fg,
					sprite.color.bg)
			end
		end
	end
	
	if is_left_mouse_click then
		selected_sprite = sprite_overlapping_with_mouse
	end
	
	if selected_sprite == nil then
		return
	end
		
	if read_ram_byte(ram_sprite_status + selected_sprite.index) < 8 then
		selected_sprite = nil
		return
	end
	
	if show_sprite_oam then
		local sprite_oam_index = read_ram_byte(ram_sprite_oam_index + selected_sprite.index)
		draw_selected_sprite_info_row(selected_sprite, format_sprite_oam(sprite_oam_index, 0))
		draw_selected_sprite_info_row(selected_sprite, format_sprite_oam(sprite_oam_index, 1))
		draw_selected_sprite_info_row(selected_sprite, format_sprite_oam(sprite_oam_index, 2))
		draw_selected_sprite_info_row(selected_sprite, format_sprite_oam(sprite_oam_index, 3))
	end
		
	for i = 1, #sprite_tables_to_print do
		local sprite_table = type(sprite_tables_to_print[i]) == "table"
			and sprite_tables_to_print[i]
			or  { ram = sprite_tables_to_print[i] }
		draw_selected_sprite_info_row(selected_sprite, format_sprite_table(sprite_table, selected_sprite.index))
	end
end


--------------------------------------------------------------------------------
-- Draw String
--------------------------------------------------------------------------------

MONOSPACE_FONT = {
  width = 5,
  height = 8,
  bitmap = {
    --    Outline           Fill
                0,             0, --  
     984240509824,    8866766848, -- !
    1088437616640,   11072962560, -- "
    1088293492704,   11218135040, -- #
     542906306496,    6849507328, -- $
     987770909920,    8661501952, -- %
     510761035232,    4635039744, -- &
     984247959552,    8858370048, -- '
     509713541568,    4572057600, -- (
     493289385408,    4364242944, -- )
      15957088224,     149039104, -- *
      15957080064,     149028864, -- +
           486108,          4352, -- ,
       1059028992,      14680064, -- -
           938880,          8192, -- .
     246335494812,    2218926336, -- /
     510754745792,    4641329152, -- 0
     509585205696,    4701949952, -- 1
    1052195407840,   12956481536, -- 2
    1052187217856,   12964671488, -- 3
     509747983584,    4574349312, -- 4
    1084198145984,   15313481728, -- 5
     509712461248,    4576317440, -- 6
    1084390451648,   15103823872, -- 7
     510761037248,    4635037696, -- 8
     510758661568,    4636872704, -- 9
        961434496,       8396800, -- :
        480733916,       4198656, -- ;
     255406748896,    2290223104, -- <
      33889516544,     470220800, -- =
     986615503744,    8726388736, -- >
    1052178328000,   12956209152, -- ?
     493709212672,    4506976256, -- @
     510750545888,    4645529600, -- A
    1051918520256,   13233369088, -- B
     543041512928,    6719543296, -- C
    1051920617408,   13231271936, -- D
    1084196898784,   15313680384, -- E
    1084196868992,   15313674240, -- F
     543034107360,    6721705984, -- G
    1088423647200,   11087980544, -- H
    1084322858976,   15170942976, -- I
     246085774784,    2217021440, -- J
    1088425744352,   11085883392, -- K
     984240343008,    8867035136, -- L
    1088293623776,   11218003968, -- M
    1051920619488,   13231269888, -- N
    1084132870112,   15378757632, -- O
    1051918553984,   13233299456, -- P
    1084132870055,   15378757696, -- Q
    1051918587872,   13233367040, -- R
     543040655296,    6715158528, -- S
    1084322294208,   15170932736, -- T
    1088427837408,   11083790336, -- U
    1088428026304,   11083583488, -- V
    1088427710432,   11083917312, -- W
    1088434132960,   11077494784, -- X
    1088433760704,   11077292032, -- Y
    1084407662560,   15103965184, -- Z
    1050879413184,   13162000384, -- [
     984313345191,    8862697536, -- \
     525501638112,    6511728640, -- ]
     510764515328,    4630511616, -- ^
          1034208,         14336, -- _
     986582089728,    8724152320, -- `
      16967722464,     212146176, -- a
     984306339776,    8871292928, -- b
      16969885152,     209983488, -- c
     246350013920,    2221217792, -- d
      16963593696,     216274944, -- e
     543030989696,    6723739648, -- f
      16967857790,     212011392, -- g
     984306341856,    8871290880, -- h
     984508683136,    8598593536, -- i
     492254358236,    4299297024, -- j
     984341927904,    8869259264, -- k
     984240318912,    8867024896, -- l
      34277611488,     350562304, -- m
      32872519648,     413476864, -- n
      15961091520,     145035264, -- o
      15961021084,     145105152, -- p
      15961207975,     144902208, -- q
      34011304832,     348397568, -- r
      16969945024,     209924096, -- s
     510626477280,    4769056768, -- t
      34013373920,     346363904, -- u
      34013638080,     346361856, -- v
      34013239264,     346499072, -- w
      34019661792,     340076544, -- x
      34013571804,     346165504, -- y
      33885505504,     474232832, -- z
     525985490400,    6589388800, -- {
     492120123840,    4433514496, -- |
    1051035814848,   13025554432, -- }
    1052173664256,   12952010752, -- ~
  },
}

function draw_string(x, y, text, color_fg, color_bg)
	if font ~= nil then
		for i = 1, #text do
			local char_index = (string.byte(text, i) - 32) * 2 + 1
			if char_index < 1 or #font.bitmap < char_index then char_index = 1 end
			
			local char_outline = font.bitmap[char_index]
			local char_fill = font.bitmap[char_index + 1]
			
			for row = 0, font.height - 1 do
				for col = 0, font.width - 1 do
					local bit_index = 1 << ((font.height - 1 - row) * font.width + (font.width - 1 - col))
					if char_outline & bit_index ~= 0 then emu.drawPixel(x + col, y + row, color_bg) end
					if char_fill & bit_index ~= 0 then emu.drawPixel(x + col, y + row, color_fg) end
				end
			end
			
			x = x + 4
		end
	else
		emu.drawString(x, y, text, color_fg, color_bg)
	end
end


--------------------------------------------------------------------------------
-- Setup
--------------------------------------------------------------------------------

SCREEN_W = 256
SCREEN_H = 224

is_sa1 = read_rom_byte(rom_addr(0x00FFD5)) == 0x23

defines()
config()

selected_sprite = nil
prev_mouse_left = false

digits = {}
for i = 0, 9 do digits[i] = string.char(string.byte('0') + i) end
for i = 10, 36 do digits[i] = string.char(string.byte('A') + i - 10) end

emu.addEventCallback(debug_sprites, emu.eventType.endFrame);
