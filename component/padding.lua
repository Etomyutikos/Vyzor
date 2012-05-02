-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require("vyzor.base")

--[[
	Class: Padding
		Defines the Padding Component.
]]
local Padding = Base( "Component", "Padding" )

--[[
	Constructor: new

	Parameters:
		... - A list of numbers defining the size of each side of the Padding Component.

	Returns:
		A new Padding Component.
]]
local function new (_, ...)
	--[[
		Structure: New Padding
			This Component defines the Padding of a <Frame>.
			The Padding between the Content and the Border.

		See Also:
			<http://doc.qt.nokia.com/4.7-snapshot/stylesheet-customizing.html>
	]]
	local new_padding = {}

	local arg = {...}
	if not arg[1] then
		error( "Vyzor: Must pass at least one size to a new Padding.", 2 )
	end

	-- Double: top
	-- The size of the top of the Padding.
	local top = arg[1]

	-- Double: right
	-- The size of the right side of the Padding.
	-- Defaults to <top>.
	local right = arg[2] or top

	-- Double: bottom
	-- The size of the bottom of the Padding.
	-- Defaults to <top>.
	local bottom = arg[3] or top

	-- Double: left
	-- The size of the left side of the Padding.
	-- Defaults to <right>.
	local left = arg[4] or right

	-- String: stylesheet
	-- The Padding Component's stylesheet. Generated via <updateStylesheet>.
	local stylesheet

	--[[
		Function: updateStylesheet
			Updates the Padding Component's <stylesheet>.
	]]
	local function updateStylesheet ()
		stylesheet = string.format( "padding: %s",
			table.concat( {top, right, bottom, left}, " " ) )
	end

	--[[
		Properties: Padding Properties
			Top 		- Gets and sets the size of a side of the Padding Component.
			Right 		- Gets and sets the size of a side of the Padding Component.
			Bottom 		- Gets and sets the size of a side of the Padding Component.
			Left 		- Gets and sets the size of a side of the Padding Component.
			Stylesheet 	- Updates and returns the Padding Component's <stylesheet>.
	]]
	local properties = {
		Top = {
			get = function ()
				return top
			end,
			set = function (value)
				top = value
			end,
			},
		Right = {
			get = function ()
				return right
			end,
			set = function (value)
				right = value
			end,
			},
		Bottom = {
			get = function ()
				return bottom
			end,
			set = function (value)
				bottom = value
			end,
			},
		Left = {
			get = function ()
				return left
			end,
			set = function (value)
				left = value
			end,
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

	setmetatable( new_padding, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or Padding[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set( value )
			end
		end,
		} )
	return new_padding
end

setmetatable( Padding, {
	__index = getmetatable(Padding).__index,
	__call = new,
	} )
return Padding

