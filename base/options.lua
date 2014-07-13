-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Lib = require("vyzor.lib")

--[[
	Structure: Options
		This object maintains option state for Vyzor.
]]
local Options = {}

-- Array: DEFAULT_DRAW_ORDER
-- Default draw order for Border Frames.
local DEFAULT_DRAW_ORDER = {"top", "bottom", "left", "right"}

-- Array: _drawOrder
-- Determines layering for Border Frames.
local _drawOrder = DEFAULT_DRAW_ORDER

-- Array: DEFAULT_BORDERS
-- Default state for Border Frames.
local DEFAULT_BORDERS = {
	Top = "dynamic",
	Bottom = "dynamic",
	Right = "dynamic",
	Left = "dynamic"
}

-- Array: _borders
-- Determines Border Frame size.
local _borders = DEFAULT_BORDERS

-- Boolean: DEFAULT_BORDER_HANDLING
-- Default setting for determing whether or not Vyzor handles
-- Mudlet's borders.
local DEFAULT_BORDER_HANDLING = "auto"

-- Boolean: _borderHandling
-- Determines whether or not Vyzor handles Mudlet's borders.
local _borderHandling = DEFAULT_BORDER_HANDLING

-- Double: DEFAULT_CONSOLE_HEIGHT
-- Default height of main console is window height.
local _, DEFAULT_CONSOLE_HEIGHT = getMainWindowSize()

-- Double: _consoleHeight
-- User-defined height for main console.
local _consoleHeight = DEFAULT_CONSOLE_HEIGHT

--[[
	Properties: Option Properties
		DrawOrder 		- Determines z-layer ordering for Border Frames.
		Borders 		- Returns a table containing options.
							Sets Border options via a table.
		ConsoleHeight 	- Sets and gets a user-defined main console height.
		HandleBorders	- Gets and sets a value that determines whether or not Vyzor
							handles Mudlet's borders. If true, then Vyzor will always
							resize Mudlet's borders. If auto, it will only assume control
							after the Vyzor.HUD:Draw() has been called.
]]
local properties = {
	DrawOrder = {
		get = function ()
			return _drawOrder
		end,
		set = function (value)
			_drawOrder = value
		end,
	},

	Borders = {
		get = function ()
			return _borders
		end,
		set = function (value)
			local changedBorders = {}
			local previousBorders = _borders

			_borders = {
				Top = value["Top"] or previousBorders["Top"],
				Right = value["Right"] or previousBorders["Right"],
				Bottom = value["Bottom"] or previousBorders["Bottom"],
				Left = value["Left"] or previousBorders["Left"]
			}

			-- We really only want to waste time updating changed
			-- values.
			for name, border in pairs(_borders) do
				if border ~= previousBorders[name] then
					changedBorders[#changedBorders +1] = name
				end
			end

			if #changedBorders > 0 then
				for _, border in ipairs(changedBorders) do
					-- Recalculate all these values. This bit of numeric magic,
					-- reused as often as it is, should probably be outsourced to
					-- an independent function.
					if _borders[border] ~= "dynamic" then
						if border == "Top" or border == "Bottom" then
							Vyzor.HUD.Frames["Vyzor" .. border].Size.Height = _borders[border]

							if border == "Bottom" then
								local contentHeight = Vyzor.HUD.Size.ContentHeight

								Vyzor.HUD.Frames["VyzorBottom"].Position.Y =
									(((_borders["Bottom"] > 0 and _borders["Bottom"] <= 1.0) and 1.0) or contentHeight) -
										_borders["Bottom"]
							end
						else
							Vyzor.HUD.Frames["Vyzor" .. border].Size.Width = _borders[border]

							if border == "Right" then
								local contentWidth = Vyzor.HUD.Size.ContentWidth

								Vyzor.HUD.Frames["VyzorRight"].Position.X =
									(((_borders["Right"] > 0 and _borders["Right"] <= 1.0) and 1.0) or contentWidth) -
										_borders["Right"]
							end
						end
					end
                end

				raiseEvent("sysWindowResizeEvent")
			end
		end
	},

	ConsoleHeight = {
		get = function ()
			return _consoleHeight
		end,
		set = function (value)
			_consoleHeight = value
			raiseEvent("sysWindowResizeEvent")
		end,
	},

	HandleBorders = {
		get = function ()
			return _borderHandling
		end,
		set = function (value)
			_borderHandling = value

			if value == true then
				raiseEvent("sysWindowResizeEvent")
			end
		end
	},
}

--[[
	Function: Reset
		Resets all Options to default values.
]]
function Options:Reset ()
	_drawOrder = DEFAULT_DRAW_ORDER
	_borders = DEFAULT_BORDERS
	_consoleHeight = DEFAULT_CONSOLE_HEIGHT
	_borderHandling = DEFAULT_BORDER_HANDLING

	raiseEvent("sysWindowResizeEvent")
end

setmetatable(Options, {
	__index = function (_, key)
		return properties[key] and properties[key].get()
	end,
	__newindex = function (_, key, value)
		if properties[key] and properties[key].set then
			properties[key].set(value)
		end
	end,
})

return Options
