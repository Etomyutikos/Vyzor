-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

--[[
	Structure: Options
		This object maintains option state for Vyzor.
]]
local Options = {}

-- Array: default_draw_order
-- Default draw order for Border Frames.
local default_draw_order = {"top", "bottom", "left", "right"}

-- Array: draw_order
-- Determines layering for Border Frames.
local draw_order = default_draw_order

-- Array: default_borders
-- Default state for Border Frames.
local default_borders = {
	Top = "dynamic",
	Bottom = "dynamic",
	Right = "dynamic",
	Left = "dynamic"
}

-- Array: borders
-- Determines Border Frame size.
local borders = default_borders

-- Double: default_console_height
-- Default height of main console is window height.
local _,default_console_height = getMainWindowSize()

-- Double: console_height
-- User-defined height for main console.
local console_height = default_console_height

--[[
	Properties: Option Properties
		DrawOrder 		- TODO: Will determine z-layer ordering for Border Frames.
		Borders 		- Returns a table containing options.
							Sets Border options via a table.
		ConsoleHeight 	- Sets and gets a user-defined main console height.
]]
local properties = {
	DrawOrder = {
		get = function ()
			return draw_order
		end,
		set = function (value)
			draw_order = value
		end,
	},
	Borders = {
		get = function ()
			return borders
		end,
		set = function (value)
			local changed = {}
			local last_borders = borders
			borders = {
				Top = value["Top"] or last_borders["Top"],
				Right = value["Right"] or last_borders["Right"],
				Bottom = value["Bottom"] or last_borders["Bottom"],
				Left = value["Left"] or last_borders["Left"]
			}

			-- We really only want to waste time updating changed
			-- values.
			for k,v in pairs( borders ) do
				if v ~= last_borders[k] then
					changed[#changed+1] = k
				end
			end

			if #changed > 0 then
				for _,k in ipairs( changed ) do
					-- Recalculate all these values. This bit of numeric magic,
					-- reused as often as it is, should probably be outsourced to
					-- an independent function.
					if borders[k] ~= "dynamic" then
						if k == "Top" or k == "Bottom" then
							Vyzor.HUD.Frames["Vyzor" .. k].Size.Height = borders[k]
							if k == "Bottom" then
								local cont_height = Vyzor.HUD.Size.ContentHeight
								Vyzor.HUD.Frames["VyzorBottom"].Position.Y =
									(((borders["Bottom"] > 0 and borders["Bottom"] <= 1.0) and 1.0) or cont_height) -
										borders["Bottom"]
							end
						else
							Vyzor.HUD.Frames["Vyzor" .. k].Size.Width = borders[k]
							if k == "Right" then
								local cont_width = Vyzor.HUD.Size.ContentWidth
								Vyzor.HUD.Frames["VyzorRight"].Position.X =
									(((borders["Right"] > 0 and borders["Right"] <= 1.0) and 1.0) or cont_width) -
										borders["Right"]
							end
						end
					else
					end
				end
				raiseEvent( "sysWindowResizeEvent" )
			end
		end
	},
	ConsoleHeight = {
		get = function ()
			return console_height
		end,
		set = function (value)
			console_height = value
			raiseEvent( "sysWindowResizeEvent" )
		end,
	},
}

--[[
	Function: Reset
		Resets all Options to default values.
]]
function Options:Reset ()
	draw_order = default_draw_order
	borders = default_borders
	console_height = default_console_height
	raiseEvent( "sysWindowResizeEvent" )
end

setmetatable( Options, {
	__index = function (_, key)
		return properties[key] and properties[key].get()
	end,
	__newindex = function (_, key, value)
		if properties[key] and properties[key].set then
			properties[key].set( value )
		end
	end,
} )

return Options
