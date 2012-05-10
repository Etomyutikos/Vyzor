-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base 			= require("vyzor.base")
local Brush 		= require("vyzor.component.brush")
local BorderStyle 	= require("vyzor.enum.border_style")

--[[
	Class: Border
		Defines the Border Component.
]]
local Border = Base( "Component", "Border" )

--[[
	Constructor: new

	Parameters:
		init_width 		- The Border Component's initial width.
							May be a number or a table of numbers.
		init_style 		- The Border Component's initial <BorderStyle>.
							Defaults to None.
		init_content 		- The Border Component's initial content.
							Can be an <Image>, <Brush>, or table of <Brushes>.
		init_radius 	- The Border Component's initial radius, for rounded corners.
							Can be a number or a table of numbers.
		init_borders 	- The Border Component's initial <BorderSide> Subcomponents.
							Must be a table containing one to four <BorderSides>.

	Returns:
		A new Border Component.
]]
local function new (_, init_width, init_style, init_content, init_radius, init_borders)
	--[[
		Structure: New Border
			A Component that defines a <Frame's> Border.
	]]
	local new_border = {}

	-- Double: width
	-- The Border's width. Defaults to 0.
	local width = init_width or 0

	-- Object: style
	-- The Border's <BorderStyle>. Defaults to None.
	local style = init_style or BorderStyle.None

	-- Object: content
	-- The Border's Brush or Image Component.
	local content = init_content

	-- Double: radius
	-- The Border's radius. Makes rounded corners. Defaults to 0.
	local radius = init_radius or 0

	-- Array: borders
	-- A table holding <BorderSide> Subcomponents.
	local borders

	if init_borders and type( init_borders ) == "table" then
		borders = {}
		borders["top"] = init_borders[1]
		borders["right"] = init_borders[2] or top
		borders["bottom"] = init_borders[3] or top
		borders["left"] = init_borders[4] or right
	end

	-- String: stylesheet
	-- The Border's stylesheet. Generated via <updateStylesheet>.
	local stylesheet

	--[[
		Function: updateStylesheet
			Updates the Border Component's <stylesheet>.
	]]
	local function updateStylesheet ()
		local style_table = {
			string.format( "border-width: %s", width ),
			string.format( "border-style: %s", style ),
			string.format( "border-radius: %s", radius ),
		}
		if content then
			style_table[#style_table+1] = string.format( "border-%s",
				(content.Subtype == "Brush" and content.Stylesheet) or
				(content.Subtype == "Image" and string.format( "image: %s", content.Url))
				)
		end
		if content.Subtype == "Image" then
			style_table[#style_table+1] = string.format( "border-image-position: %s",
				content.Alignment )
		end

		if borders then
			for _,k in ipairs( {"top", "right", "bottom", "left"} ) do
				for _,v in ipairs( borders[k].Styletable ) do
					style_table[#style_table+1] = string.format( "border-%s-%s", k, v )
				end
			end
		end

		stylesheet = table.concat( style_table, "; " )
	end

	--[[
		Properties: Border Properties
			Style 		- Gets and sets the <BorderStyle> Component.
			Width 		- Gets and sets the Border Component's width.
			Content		- Gets and sets the Border Component's Brush or Image Component.
			Top 		- Gets and sets an individual <BorderSide> Subcomponent.
			Right 		- Gets and sets an individual <BorderSide> Subcomponent.
			Bottom 		- Gets and sets an individual <BorderSide> Subcomponent.
			Left 		- Gets and sets an individual <BorderSide> Subcomponent.
			Stylesheet 	- Updates and returns the Border Component's <stylesheet>.
	]]
	local properties = {
		Style = {
			get = function ()
				return style
			end,
			set = function (value)
				assert( BorderStyle:IsValid( value ), "Vyzor: Invalid BorderStyle passed to Border.")
				style = value
			end,
		},
		Width = {
			get = function ()
				if type( width ) == "table" then
					local copy = {}
					for i in ipairs( width ) do
						copy[i] = width[i]
					end
					return copy
				else
					return width
				end
			end,
			set = function (value)
				width = value
			end,
		},
		Content = {
			get = function ()
				if type( content ) ~= "table" then
					return content
				else
					local copy = {}
					for i in ipairs( content ) do
						copy[i] = content[i]
					end
					return copy
				end
			end,
			set = function (value)
				content = value
			end,
		},
		Top = {
			get = function ()
				return (borders and borders["top"]) or nil
			end,
			set = function (value)
				assert( value.Subtype == "BorderSide", "Vyzor: Invalid Border Subcomponent passed to Border.Top")
				borders["top"] = value
			end
		},
		Right = {
			get = function ()
				return (borders and borders["right"]) or nil
			end,
			set = function (value)
				assert( value.Subtype == "BorderSide", "Vyzor: Invalid Border Subcomponent passed to Border.Right.")
				borders["right"] = value
			end
		},
		Bottom = {
			get = function ()
				return (borders and borders["bottom"]) or nil
			end,
			set = function (value)
				assert( value.Subtype == "BorderSide", "Vyzor: Invalid Border Subcomponent passed to Border.Bottom.")
				borders["bottom"] = value
			end
		},
		Left = {
			get = function ()
				return (borders and borders["left"]) or nil
			end,
			set = function (value)
				assert( value.Subtype == "BorderSide", "Vyzor: Invalid Border Subcomponent passed to Border.Left.")
				borders["left"] = value
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

	setmetatable( new_border, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or Border[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set( value )
			end
		end,
	} )
	return new_border
end

setmetatable( Border, {
	__index = getmetatable(Border).__index,
	__call = new,
} )
return Border
