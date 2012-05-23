-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base 		= require( "vyzor.base" )
local Alignment = require( "vyzor.enum.alignment" )
local Lib 		= require( "vyzor.lib" )
local Repeat 	= require( "vyzor.enum.repeat" )

--[[
	Class: Background
		Defines a Background Component.
]]
local Background = Base( "Component", "Background" )

--[[
	Constructor: new

	Parameters:
		init_content 	- Either a <Brush> or <Image> Component.
		init_alignment 	- Initial <Alignment> of the Background content. Default is top-left.
		init_repeat 	- Initial <Repeat> rules for the Background content. Default is repeat-xy.

	Returns:
		A new Background Component.
]]
local function new (_, init_content, init_alignment, init_repeat)
	--[[
		Structure: New Background
			A Component defining a <Frame's> background.
	]]
	local new_background = {}

	-- Object: content
	-- Either an Image Component or a Brush Component.
	local content = init_content

	-- Object: alignment
	-- An Alignment Enum. Defaults to TopLeft.
	local alignment = (init_alignment or Alignment.TopLeft)

	-- Object: repetition
	-- A Repeat Enum. Defaults to RepeatXY.
	local repetition = (init_repeat or Repeat.RepeatXY)


	-- String: stylesheet
	-- This Component's Stylesheet. Generated via <updateStylesheet>.
	local stylesheet

	--[[
		Function: updateStylesheet
			Updates the Component's <stylesheet>.
			Used by the containing <Frame>.
	]]
	local function updateStylesheet ()
		local style_table = {
			string.format( "background-position: %s", alignment ),
			string.format( "background-repeat: %s", repetition ),
		}

		if content then
			if content.Subtype == "Brush" then
				if content.Content.Subtype == "Gradient" then
					style_table[#style_table+1] = string.format( "background: %s",
						content.Stylesheet )
				else
					style_table[#style_table+1] = string.format( "background-%s",
						content.Stylesheet )
				end
			else
				style_table[#style_table+1] = string.format( "background-image: %s",
					content.Url )
			end
		end


		stylesheet = table.concat( style_table, "; " )
	end

	--[[
		Properties: Background Properties
			Content 	- Gets and sets the <Image> or <Brush> used by the Background Component.
			Alignment 	- Gets and sets the Background Component's content Alignment.
			Repeat 		- Gets and sets the Background Component's Repeat rule.
			Stylesheet 	- Updates and returns the Background Component's <stylesheet>.
	]]
	local properties = {
		Content = {
			get = function ()
				return content
			end,
			set = function (value)
				content = value
			end,
		},
		Alignment = {
			get = function ()
				return alignment
			end,
			set = function (value)
				if Alignment:IsValid( value ) then
					alignment = value
				end
			end
		},
		Repeat = {
			get = function ()
				return repetition
			end,
			set = function (value)
				if Repeat:IsValid( value ) then
					repetition = value
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

	setmetatable( new_background, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or Background[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set( value )
			end
		end
		} )
	return new_background
end

setmetatable( Background, {
	__index = getmetatable(Background).__index,
	__call = new,
	} )
return Background
