-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base 			= require( "vyzor.base" )
local GradientMode 	= require( "vyzor.enum.gradient_mode" )

--[[
	Class: Gradient
		Defines a Gradient Component.
]]
local Gradient = Base( "Component", "Gradient" )

--[[
	Constructor: new
		Expected arguments differ depending on mode.

		Linear mode expects a comma-separated list of
		numbers (x1, y1, x2, y2) followed by any number of
		stop, color (number, Color Component) pairs.

		Radial mode expects a comma-separated list of
		numbers (cx, cy, radius, fx, fy) following by any number of
		stop, color (number, Color Component) pairs.

		Conical mode expects a comma-separated list of
		numbers (cx, cy, radius, angle) following by any number of
		stop, color (number, Color Component) pairs.

		All numeric values are expected to between 0.0 and 1.0,
		to be understood as percentage of Frame size.

		I wish Gradients were easier, but there it is. =p

	Parameters:
		mode 	- The Gradient's mode. Must be a valid <GradientMode> Enum.
		... 	- Gradient data. See description.

	Returns:
		A new Gradient Component.
]]
local function new (_, mode, ...)
	assert( GradientMode:IsValid( mode ), "Vyzor: Invalid mode passed to Gradient." )

	local arg = {...}
	--[[
		Structure: New Gradient
			A Component that defines gradient data. Used
			primarily in a <Brush> Component.
	]]
	local new_gradient = {}

	-- Array: gradient_data
	-- Contains the Gradient's data.
	local gradient_data
	do
		local index
		if mode:match( GradientMode.Linear ) then
			gradient_data = {
				x1 = arg[1],
				y1 = arg[2],
				x2 = arg[3],
				y2 = arg[4],
				stops = {},
			}
			index = 5
		elseif mode:match( GradientMode.Radial ) then
			gradient_data = {
				cx = arg[1],
				cy = arg[2],
				radius = arg[3],
				fx = arg[4],
				fy = arg[5],
				stops = {},
			}
			index = 6
		elseif mode:match( GradientMode.Conical ) then
			gradient_data = {
				cx = arg[1],
				cy = arg[2],
				angle = arg[3],
				stops = {},
			}
			index = 4
		end

		-- Had to find a generic way to iterate through arguments to grab
		-- any number of stop, color pairs. I was pretty proud of this
		-- solution.
		local stop_num = 1
		for i=index, #arg do
			gradient_data.stops[stop_num] = gradient_data.stops[stop_num] or {}
			if (index % 2 == 0) then
				if (i % 2 == 0) then
					gradient_data.stops[stop_num].n = arg[i]
				else
					gradient_data.stops[stop_num].color = arg[i]
					stop_num = stop_num + 1
				end
			else
				if (i % 2 == 0) then
					gradient_data.stops[stop_num].color = arg[i]
					stop_num = stop_num + 1
				else
					gradient_data.stops[stop_num].n = arg[i]
				end
			end
		end
	end

	-- String: stylesheet
	-- The Gradient Component's stylesheet. Generated via <updateStylesheet>.
	local stylesheet

	--[[
		Function: updateStylesheet
			Updates the Gradient's <stylesheet>.
			Output is based on <GradientMode>.
	]]
	local function updateStylesheet ()
		local style_stops = {}
		for _,stop in ipairs( gradient_data.stops ) do
			style_stops[#style_stops+1] = string.format( "stop:%s %s",
				stop.n,
				stop.color.Stylesheet:sub(8) or stop.color )
		end

		if mode:match( GradientMode.Linear ) then
			stylesheet = string.format( "qlineargradient(x1:%s, y1:%s, x2:%s, y2:%s, %s)",
				gradient_data.x1,
				gradient_data.y1,
				gradient_data.x2,
				gradient_data.y2,
				table.concat( style_stops, ", " ) )
		elseif mode:match( GradientMode.Radial ) then
			stylesheet = string.format( "qradialgradient(cx:%s, cy:%s, radius: %s, fx:%s, fy:%s, %s)",
				gradient_data.cx,
				gradient_data.cy,
				gradient_data.radius,
				gradient_data.fx,
				gradient_data.fy,
				table.concat( style_stops, ", " ) )
		elseif mode:match( GradientMode.Conical ) then
			stylesheet = string.format( "qconicalgradient(cx:%s, cy:%s, angle:%s, %s)",
				gradient_data.cx,
				gradient_data.cy,
				gradient_data.angle,
				table.concat( style_stops, ", " ) )
		end
	end

	--[[
		Properties: Gradient Properties
			Mode 		- Returns the Gradient's <GradientMode> Enum.
			Data 		- Returns a copy of the Gradient's <gradient_data>.
			Stylesheet 	- Updates and returns the Gradient Component's <stylesheet>.
	]]
	local properties = {
		Mode = {
			get = function ()
				return mode
			end,
		},
		Data = {
			get = function ()
				local copy = {}
				for i in pairs( gradient_data ) do
					copy[i] = gradient_data[i]
				end
				return copy
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

	setmetatable( new_gradient, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or Gradient[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set( value )
			end
		end
	} )
	return new_gradient
end

setmetatable( Gradient, {
	__index = getmetatable(Gradient).__index,
	__call = new
} )
return Gradient
