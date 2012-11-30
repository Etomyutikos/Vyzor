-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base 				= require("vyzor.base")
local FontDecoration 	= require("vyzor.enum.font_decoration")
local FontStyle 		= require("vyzor.enum.font_style")
local FontWeight 		= require("vyzor.enum.font_weight")

--[[
	Class: Font
		Defines the Font Component.
]]
local Font = Base( "Component", "Font" )

--[[
	Constructor: new

	Parameters:
		init_size 		- The Font Component's initial size.
							Valid sizes are defined by QT, but I can only seem
							to get numbers to work.
		init_style 		- The Font Component's initial style. Optional.
							Must be a FontStyle or FontWeight Component.
		init_decoration - The Font Component's initial FontDecoration. Optional.

	Returns:
		A new Font Component.
]]
local function new (_, init_size, init_style, init_decoration)
	--[[
		Structure: New Font
			A Component defining certain text manipulations.
	]]
	local new_font = {}

	-- Double: size
	-- The Font's initial size.
	local size = init_size

	-- Object: style
	-- The Font's initial <FontStyle>.
	local style = init_style

	-- Object: decoration
	-- The Font's initial <FontDecoration>.
	local decoration = init_decoration

	-- String: stylesheet
	-- The Font Component's stylesheet. Generated via <updateStylesheet>.
	local stylesheet

	--[[
		Function: updateStylesheet
			Updates the Font Component's <stylesheet>.
	]]
	local function updateStylesheet ()
		stylesheet = string.format( "font-size: %s; %s: %s; text-decoration: %s",
			size,
			((style and FontStyle:IsValid( style )) and "font-style")
				or ((style and FontWeight:IsValid( style )) and "font-weight"),
			style or FontStyle.Normal,
			decoration or FontDecoration.Normal )
	end

	--[[
		Properties: Font Properties
			Size 		- Gets and sets the Font's size. Should probably be a number.
			Style 		- Gets and sets the Font's <FontStyle>.
							Removes the Font's <FontWeight> if set.
			Weight 		- Gets and sets the Font's <FontWeight>.
							Removes the Font's <FontStyle> if set.
			Decoration 	- Gets and sets the Font's <FontDecoration>.
			Stylesheet 	- Updates and returns the Font Component's <stylesheet>.
	]]
	local properties = {
		Size = {
			get = function ()
				return size
			end,
			set = function (value)
				size = value
			end,
			},
		Style = {
			get = function ()
				return style
			end,
			set = function (value)
				style = value
			end,
			},
		Decoration = {
			get = function ()
				return decoration
			end,
			set = function (value)
				decoration = value
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

	setmetatable( new_font, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or Font[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set( value )
			end
		end
		} )
	return new_font
end

setmetatable( Font, {
	__index = getmetatable(Font).__index,
	__call = new,
	} )
return Font
