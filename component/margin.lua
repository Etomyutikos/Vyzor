-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require("vyzor.base")

--[[
	Class: Margin
		Defines a Margin Component.
]]
local Margin = Base( "Component", "Margin" )

--[[
	Constructor: new

	Parameters:
		... - A list of numbers defining the size of each side of the Margin.

	Returns:
		A new Margin Component.
]]
local function new (_, ...)
	--[[
		Structure: New Margin
			This Component defines the Margin of a <Frame>.
			The Margin is the exterior part of the <Frame>.

		See Also:
			<http://doc.qt.nokia.com/4.7-snapshot/stylesheet-customizing.html>
	]]
	local new_margin = {}

	local arg = {...}
	if not arg[1] then
		error( "Vyzor: Must pass at least one size to new Margin.", 2 )
	end

	-- Double: top
	-- The size of the top of the Margin.
	local top = arg[1]

	-- Double: right
	-- The size of the right side of the Margin.
	-- Defaults to <top>.
	local right = arg[2] or top

	-- Double: bottom
	-- The size of the bottom of the Margin.
	-- Defaults to <top>.
	local bottom = arg[3] or top

	-- Double: left
	-- The size of the left side of the Margin.
	-- Defaults to <right>.
	local left = arg[4] or right

	-- String: stylesheet
	-- The Margin Component's stylesheet. Generated via <updateStylesheet>.
	local stylesheet

	--[[
		Function: updateStylesheet
			Updates the Margin Component's <stylesheet>.
	]]
	local function updateStylesheet ()
		stylesheet = string.format( "margin: %s",
			table.concat( {top, right, bottom, left}, " " ) )
	end

	--[[
		Properties: Margin Properties
			Top 		- Gets and sets the size of a side of the Margin Component.
			Right 		- Gets and sets the size of a side of the Margin Component.
			Bottom 		- Gets and sets the size of a side of the Margin Component.
			Left 		- Gets and sets the size of a side of the Margin Component.
			Stylesheet 	- Updates and returns the Margin Component's <stylesheet>.
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

	setmetatable( new_margin, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or Margin[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set( value )
			end
		end,
		} )
	return new_margin
end

setmetatable( Margin, {
	__index = getmetatable(Margin).__index,
	__call = new,
	} )
return Margin
