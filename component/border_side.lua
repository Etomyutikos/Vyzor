-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base 			= require("vyzor.base")
local BorderStyle 	= require("vyzor.enum.border_style")

--[[
	Class: BorderSide
		Defines a BorderSide Component.
]]
local BorderSide = Base( "Subcomponent", "BorderSide" )

--[[
	Constructor: new
		Should only be used as an argument to a <Border> Component.

	Parameters:
		init_width 		- The BorderSide's initial width.
		init_style 		- The BorderSide's initial <BorderStyle>. Defaults to None.
		init_content 	- The BorderSide's initial Brush or Image.
		init_radius 	- The radius of the BorderSide's corners. Only relevant
							for top and bottom BorderSides.

	Returns:
		A new BorderSide Subcomponent.
]]
local function new (_, init_width, init_style, init_content, init_radius)
	--[[
		Structure: New BorderSide
			A Subcomponent that defines individual sides of a <Border>
			component.
	]]
	local new_borderside = {}

	-- Boolean: is_side
	-- Is it a Left or Right? Only Top and Bottom use radius, as per QT.
	local is_side = false

	-- Double: width
	-- BorderSide's width.
	local width = init_width

	-- Object: style
	-- BorderSide's <BorderStyle>. Defaults to None.
	local style = init_style or BorderStyle.None

	-- Object: brush
	-- BorderSide's Brush Component.
	local content = init_content

	-- Double: radius
	-- BorderSide's radius. Defaults to 0.
	local radius = init_radius or 0

	-- Array: styletable
	-- A table holding the Stylesheets of all Components.
	-- This makes indexing easier for the <Border> Component.
	local styletable

	--[[
		Function: updateStyletable
			Updates the BorderSide's stylesheet table.
	]]
	local function updateStyletable ()
		styletable = {
			string.format( "width: %s", width ),
			string.format( "style: %s", style ),
			string.format( "%s: %s",
				(content.Subtype == "Brush" and content.Stylesheet) or
				(content.Subtype == "Image" and string.format( "image: %s", content.Url))
			),
			(content.Subtype == "Image" and string.format( "image-position: %s", content.Alignment )),
		}

		if not is_side then
			if type( radius == "table" ) then
				styletable[#styletable+1] = string.format( "left-radius: %s", radius[1] )
				styletable[#styletable+1] = string.format( "right-radius: %s", radius[2] )
			else
				styletable[#styletable+1] = string.format( "radius: %s", radius )
			end
		end
	end

	--[[
		Properties: BorderSide Properties
			Width 		- Gets and sets the BorderSide Subcomponent's width.
			Style 		- Gets and sets the BorderSide's <BorderStyle>.
			Content		- Gets and sets the BorderSide's Brush or Image Component.
			Radius 		- Gets and sets the BorderSide's radius.
			IsSide 		- Gets and sets the BorderSide's <is_side> value. Must be boolean.
			Styletable 	- Updates and returns the BorderSide's stylesheet table.
	]]
	local properties = {
		Width = {
			get = function ()
				return width
			end,
			set = function (value)
				width = value
			end,
		},
		Style = {
			get = function ()
				return style
			end,
			set = function (value)
				assert( BorderStyle:IsValid( value ), "Vyzor: Invalid BorderStyle passed to BorderSide." )
				style = value
			end,
		},
		Content = {
			get = function ()
				return content
			end,
			set = function (value)
				content = value
			end,
		},
		Radius = {
			get = function ()
				return radius
			end,
			set = function (value)
				radius = value
			end,
		},
		IsSide = {
			get = function ()
				return is_side
			end,
			set = function (value)
				if type( value ) == "boolean" then
					is_side = value
				end
			end,
		},
		Styletable = {
			get = function ()
				if not styletable then
					updateStyletable()
				end
				return styletable
			end,
		},
	}

	setmetatable( new_borderside, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or BorderSide[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set( value )
			end
		end,
		} )
	return new_borderside
end

setmetatable( BorderSide, {
	__index = getmetatable( BorderSide ).__index,
	__call = new
} )
return BorderSide
