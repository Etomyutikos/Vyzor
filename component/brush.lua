-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base 			= require( "vyzor.base" )
local ColorMode 	= require( "vyzor.enum.color_mode" )
local GradientMode 	= require( "vyzor.enum.gradient_mode" )

--[[
	Class: Brush
		Defines a Brush Component.
]]
local Brush = Base( "Component", "Brush" )

--[[
	Constructor: new

	Parameters:
		init_content - The initial content of this Brush Component.
			Must be a <Color> or <Gradient> Component.

	Returns:
		A new Brush Component.
]]
local function new ( _, init_content )
	assert( (ColorMode:IsValid( init_content.Mode ) or GradientMode:IsValid( init_content.Mode )),
		"Vyzor: Must pass a ColorMode or GradientMode Enum option to new Brush." )

	-- Structure: New Brush
	-- A Component container that holds either a <Color> Component
	-- or a <Gradient> Component.
	local new_brush = {}

	-- Object: content
	-- The <Color> or <Gradient> Component this Brush contains.
	local content = init_content

	--[[
		Properties: Brush Properties
			Content 	- Gets and sets the Brush's content.
							Must be a <Color> or <Gradient> Component.
			Stylesheet 	- Returns the Brush's content's Stylesheet.
	]]
	local properties = {
		Content = {
			get = function ()
				return content
			end,
			set = function (value)
				if ColorMode:IsValid( value.Mode ) then
					content = value
				elseif GradientMode:IsValid( value.Mode ) then
					content = value
				else
					assert( false, "Vyzor: Content passed to Brush must be Color or Gradient." )
				end
			end
		},
		Stylesheet = {
			get = function ()
				return content.Stylesheet
			end,
		},
	}

	setmetatable( new_brush, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or Brush[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set( value )
			end
		end
	} )
	return new_brush
end

setmetatable( Brush, {
	__index = getmetatable(Brush).__index,
	__call = new
} )
return Brush

