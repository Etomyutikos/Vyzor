--- Maintains option state for all of Vyzor.
--- @module Options

local Lib = require("vyzor.lib")
local VyzorBorder = require("vyzor.enum.vyzorborder")

local Options = {}

local DEFAULT_DRAW_ORDER = { VyzorBorder.Top, VyzorBorder.Bottom, VyzorBorder.Left, VyzorBorder.Right }
local _drawOrder = DEFAULT_DRAW_ORDER

local DEFAULT_BORDERS = {
	Top = "dynamic",
	Bottom = "dynamic",
	Right = "dynamic",
	Left = "dynamic"
}
local _borders = DEFAULT_BORDERS

local DEFAULT_BORDER_HANDLING = "auto"
local _borderHandling = DEFAULT_BORDER_HANDLING

local _, DEFAULT_CONSOLE_HEIGHT = getMainWindowSize()
local _consoleHeight = DEFAULT_CONSOLE_HEIGHT

--- Resets all option to their default values.
function Options:Reset()
    _drawOrder = DEFAULT_DRAW_ORDER
    _borders = DEFAULT_BORDERS
    _consoleHeight = DEFAULT_CONSOLE_HEIGHT
    _borderHandling = DEFAULT_BORDER_HANDLING

    raiseEvent("sysWindowResizeEvent")
end

local properties = {
	DrawOrder = {
        --- Returns the z-layer ordering for Border Frames.
        --- @function DrawOrder.get
        --- @treturn table
		get = function ()
			return _drawOrder
		end,

        --- Sets the z-layer ordering for Border Frames.
        --- @function DrawOrder.set
        --- @tparam table value A table containing VyzorBorder enums.
		set = function (value)
			_drawOrder = value
		end,
	},

	Borders = {
        --- Returns the options for Border Frame resizing.
        --- @function Borders.get
        --- @treturn table
		get = function ()
			return _borders
		end,

        --- Sets the options for Border Frame resizing.
        --- @function Borders.set
        --- @tparam table value A table containing VyzorBorder keys.
		set = function (value)
			local changedBorders = {}
			local previousBorders = _borders

			_borders = {
				Top = value[VyzorBorder.Top] or previousBorders[VyzorBorder.Top],
				Right = value[VyzorBorder.Right] or previousBorders[VyzorBorder.Right],
				Bottom = value[VyzorBorder.Bottom] or previousBorders[VyzorBorder.Bottom],
				Left = value[VyzorBorder.Left] or previousBorders[VyzorBorder.Left]
			}

			-- We really only want to waste time updating changed
			-- values.
			for name, border in pairs(_borders) do
				if border ~= previousBorders[name] then
					changedBorders[#changedBorders + 1] = name
				end
			end

			if #changedBorders > 0 then
				for _, border in ipairs(changedBorders) do
                    -- Recalculate all these values. This bit of numeric magic,
					-- reused as often as it is, should probably be outsourced to
					-- an independent function.
					if _borders[border] ~= "dynamic" then
                        local vyzorBorder = "Vyzor" .. border

						if border == VyzorBorder.Top or border == VyzorBorder.Bottom then
							Vyzor.HUD.Frames[vyzorBorder].Size.Height = _borders[border]

							if border == VyzorBorder.Bottom then
								local contentHeight = Vyzor.HUD.Size.ContentHeight

								Vyzor.HUD.Frames[vyzorBorder].Position.Y =
									(((_borders[VyzorBorder.Bottom] > 0 and _borders[VyzorBorder.Bottom] <= 1.0) and 1.0) or contentHeight) -
										_borders[VyzorBorder.Bottom]
							end
						else
							Vyzor.HUD.Frames[vyzorBorder].Size.Width = _borders[border]

							if border == VyzorBorder.Right then
								local contentWidth = Vyzor.HUD.Size.ContentWidth

								Vyzor.HUD.Frames[vyzorBorder].Position.X =
									(((_borders[VyzorBorder.Right] > 0 and _borders[VyzorBorder.Right] <= 1.0) and 1.0) or contentWidth) -
										_borders[VyzorBorder.Right]
							end
						end
					end
                end

				raiseEvent("sysWindowResizeEvent")
			end
		end
	},

	ConsoleHeight = {
        --- Returns the console height as managed by Vyzor.
        --- @function ConsoleHeight.get
        --- @treturn number
		get = function ()
			return _consoleHeight
		end,

        --- Sets the console height to be managed by Vyzor.
        --- @function ConsoleHeight.set
        --- @number value The height of the main console.
		set = function (value)
			_consoleHeight = value
			raiseEvent("sysWindowResizeEvent")
		end,
	},

	HandleBorders = {
        --- Returns the method Vyzor is using to handle resizing Border Frames.
        --- @function HandleBorders.get
        --- @treturn string|bool
		get = function ()
			return _borderHandling
		end,

        --- Determines how Vyzor handles the resizing of Border Frames.
        --- @function HandleBorders.set
        --- @tparam string|bool value If true, then Vyzor will always resize Mudlet's borders.
        --- If auto, it will only assume control after the Vyzor.HUD:Draw() has been called.
		set = function (value)
			_borderHandling = value

			if value == true then
				raiseEvent("sysWindowResizeEvent")
			end
		end
	},
}

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
