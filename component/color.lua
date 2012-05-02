-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base 		= require( "vyzor.base" )
local ColorMode = require( "vyzor.enum.color_mode" )

--[[
	Class: Color
		Defines the Brush Component.
]]
local Color = Base( "Component", "Color" )

--[[
	Constructor: new
		Expected arguments differ depending on mode.

		RGB and HSV modes expect a comma-separated list of 3-4 numbers.

		Name mode expects a single string.

		Hex mode expects a single Hex string.

	Parameters:
		mode 	- A <ColorMode> enum, used to determine handling of color data.
		... 	- Color data. See description.

	Returns:
		A new Color Component.
]]
local function new (_, mode, ...)
	assert( ColorMode:IsValid( mode ), "Vyzor: Invalid mode passed to Color." )
	--[[
		Structure: New Color
			A Component that defines color information. Used
			primarily in a <Brush> Component.
	]]
	local new_color = {}

	local arg = {...}

	-- Variable: color_data
	-- Holds the Component's color data.
	local color_data

	if mode:find( ColorMode.RGB ) then
		color_data = {
			red = arg[1],
			blue = arg[2],
			green = arg[3],
			alpha = (arg[4] or 255)
			}
	elseif mode:find( ColorMode.HSV ) then
		color_data = {
			hue = arg[1],
			saturation = arg[2],
			value = arg[3],
			alpha = (arg[4] or 255)
			}
	elseif mode:match( ColorMode.Name ) then
		color_data = arg[1]
	elseif mode:match( ColorMode.Hex ) then
		if not arg[1]:find( "#" ) then
			color_data = "#" .. arg[1]
		else
			color_data = arg[1]
		end
	end

	-- String: stylesheet
	-- The Color Component's stylesheet. Generated via <updateStylesheet>.
	local stylesheet

	--[[
		Function: updateStylesheet
			Updates the Color Component's <stylesheet>.
			Actual output is dependent on ColorMode.
	]]
	local function updateStylesheet ()
		if mode:find( ColorMode.RGB ) then
			stylesheet = string.format( "color: rgba(%s, %s, %s, %s)",
				color_data.red,
				color_data.blue,
				color_data.green,
				color_data.alpha )
		elseif mode:find( ColorMode.HSV ) then
			stylesheet = string.format( "color: hsva(%s, %s, %s, %s)",
				color_data.hue,
				color_data.saturation,
				color_data.value,
				color_data.alpha )
		elseif mode:match( ColorMode.Name ) then
			stylesheet = string.format( "color: %s", color_data )
		elseif mode:match( ColorMode.Hex ) then
			stylesheet = string.format( "color: %s", color_data )
		end
	end

	--[[
		Properties: Color Properties
			Mode 		- Returns the Color Component's <ColorMode> Enum.
			Data 		- Returns the <color_data> passed to the Color Component.
			Stylesheet 	- Updates and returns the Color's <stylesheet>.
	]]
	local properties = {
		Mode = {
			get = function ()
				return mode
			end
			},
		Data = {
			get = function ()
				if type( color_data ) == "table" then
					local copy = {}
					for i in pairs( color_data ) do
						copy[i] = color_data[i]
					end
					return copy
				else
					return color_data
				end
			end
			},
		Stylesheet = {
			get = function ()
				if not stylesheet then
					updateStylesheet()
				end
				return stylesheet
			end,
			},
		}

	setmetatable( new_color, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or Color[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set( value )
			end
		end
	} )
	return new_color
end

setmetatable( Color, {
	__index = getmetatable(Color).__index,
	__call = new
} )
return Color
