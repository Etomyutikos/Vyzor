-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base 			= require( "vyzor.base" )
local BoundingMode 	= require( "vyzor.enum.bounding_mode" )

--[[
	Class: Position
		Defines a Position Supercomponent.
]]
local Position = Base( "Supercomponent", "Position" )

--[[
	Constructor: new

	Parameters:
		frame 		- The <Frame> to which this Supercomponent belongs.
		init_x 		- The initial x coordinate position.
		init_y 		- The initial y coordinate position.
		is_first 	- Determines whether or not the parent <Frame> is the <HUD>.

	Returns:
		A new Position Supercomponent.
]]
local function new (_, frame, init_x, init_y, is_first)
	--[[
		Structure: New Position
			A Supercomponent, for use only with <Frames>.
			Responsible for managing the coordinate
			positioning of the <Frame> within its parent.
			This is only used internally. Not to be exposed.
	]]
	local new_position = {}

	-- Array: coords
	-- Contains the <Frame's> user-defined coordinates.
	local coords = {
		X = (init_x or 0),
		Y = (init_y or 0),
	}

	-- Array: abs_coords
	-- Contains the <Frame's> generated, window coordinates.
	local abs_coords = {}

	-- Array: content_coords
	-- Contains the <Frame's> generated, Content Rectangle coordinates.
	local content_coords = {}

	--[[
		Function: updateAbsolute
			Generates the absolute coordinates (<abs_coords>) of
			the <Frame>.
			Also used to generate the content coordinates (<content_coords>).
	]]
	local function updateAbsolute ()
		-- The HUD.
		if is_first then
			abs_coords = coords
			content_coords = coords
			return
		end

		assert( frame.Container, "Vyzor: Frame must have container before Position can be determined." )
		local container_pos = frame.Container.Position.Content
		local container_size = frame.Container.Size.Content
		-- We convert the size table from width/height to X/Y so we can
		-- use it in our loop below.
		local size_table = {
			X = container_size.Width,
			Y = container_size.Height,
			}

		for coord, value in pairs(coords) do
			if value > 1 then
				abs_coords[coord] = container_pos[coord] + value
			elseif value > 0 then
				abs_coords[coord] = container_pos[coord] + (size_table[coord] * value)
			elseif value < 0 then
				abs_coords[coord] = container_pos[coord] + (size_table[coord] + value)
			else
				abs_coords[coord] = container_pos[coord]
			end
		end

		-- We follow Bounding rules, which determine how to manipulate
		-- child Frames as the parent Frame is resized.
		if frame.Container.IsBounding then
			if frame.BoundingMode == BoundingMode.Position then
				local frame_width = frame.Size.AbsoluteWidth
				local cont_edge_x = container_pos.X + container_size.Width
				if abs_coords.X < container_pos.X then
					abs_coords.X = container_pos.X
				elseif (abs_coords.X + frame_width) > cont_edge_x then
					abs_coords.X = cont_edge_x - frame_width
				end

				local frame_height = frame.Size.AbsoluteHeight
				local cont_edge_y = container_pos.Y + size_table.Y
				if abs_coords.Y < container_pos.Y then
					abs_coords.Y = container_pos.Y
				elseif (abs_coords.Y + frame_height) > cont_edge_y then
					abs_coords.Y = cont_edge_y - frame_height
				end
			end
		end

		do
		-- In order to respect the QT Box Model, we have to determine the
		-- actual position of the Content Rectangle. All child Frames
		-- are placed using the Content Rectangle, not the Absolute Rectangle.
		-- See: http://doc.qt.nokia.com/4.7-snapshot/stylesheet-customizing.html
			local blank_x = 0
			local blank_y = 0
			if frame.Components["Border"] then
				local border = frame.Components["Border"]
				if border.Top then
					blank_x = blank_x + border.Left.Width
					blank_y = blank_y + border.Top.Width
				else
					if type( border.Width ) == "table" then
						blank_x = blank_x + border.Width[4]
						blank_y = blank_y + border.Width[1]
					else
						blank_x = blank_x + border.Width
						blank_y = blank_y + border.Width
					end
				end
			end
			if frame.Components["Margin"] then
				local margin = frame.Components["Margin"]
				blank_x = blank_x + margin.Left
				blank_y = blank_y + margin.Top
			end
			if frame.Components["Padding"] then
				local padding = frame.Components["Padding"]
				blank_x = blank_x + padding.Left
				blank_y = blank_y + padding.Top
			end
			content_coords = {
				X = abs_coords.X + blank_x,
				Y = abs_coords.Y + blank_y
			}
		end
	end

	--[[
		Properties: Position Properties
			Coordinates - Gets and sets the relative (user-defined) coordinates
							(<coords>) of the <Frame>.
			Absolute 	- Returns the coordinates of the <Frame> within the Mudlet window
							(<abs_coords>).
			Content 	- Returns the coordinates of the Content Rectangle within the Mudlet window
							(<content_coords>).
			X 			- Gets and sets the relative (user-defined) x value of the Frame.
			Y 			- Gets and sets the relative (user-defined) y value of the Frame.
			AbsoluteX 	- Returns the X value of the Frame within the Mudlet window.
			AbsoluteY 	- Returns the Y value of the Frame within the Mudlet window.
			ContentX 	- Returns the X value of the Content Rectangle
							within the Mudlet window.
			ContentY 	- Returns the Y value of the Content Rectangle
							within the Mudlet window.
	]]
	local properties = {
		Coordinates = {
			get = function ()
				local copy = {}
				for index in pairs( coords ) do
					copy[index] = coords[index]
				end
				return copy
			end,
			set = function (value)
				coords.X = value.X or value[1]
				coords.Y = value.Y or value[2]
				updateAbsolute()
			end
		},
		Absolute = {
			get = function ()
				if not abs_coords.X or not abs_coords.Y then
					updateAbsolute()
				end
				local copy = {}
				for index in pairs( abs_coords ) do
					copy[index] = abs_coords[index]
				end
				return copy
			end
		},
		Content = {
			get = function ()
				if not content_coords.X or not content_coords.Y then
					updateAbsolute()
				end
				local copy = {}
				for i in pairs( content_coords ) do
					copy[i] = content_coords[i]
				end
				return copy
			end
		},
		X = {
			get = function ()
				return coords.X
			end,
			set = function (value)
				coords.X = value

				if frame.Container.IsDrawn then
					updateAbsolute()
				end
			end
		},
		Y = {
			get = function ()
				return coords.Y
			end,
			set = function (value)
				coords.Y = value

				if frame.Container.IsDrawn then
					updateAbsolute()
				end
			end
		},
		AbsoluteX = {
			get = function ()
				if not abs_coords.X then
					updateAbsolute()
				end
				return abs_coords.X
			end
		},
		AbsoluteY = {
			get = function ()
				if not abs_coords.Y then
					updateAbsolute()
				end
				return abs_coords.Y
			end
		},
		ContentX = {
			get = function ()
				if not content_coords.X then
					updateAbsolute()
				end
				return content_coords.X
			end
		},
		ContentY = {
			get = function ()
				if not content_coords.Y then
					updateAbsolute()
				end
				return content_coords.Y
			end
		},
	}

	setmetatable( new_position, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or Position[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set( value )
			end
		end,
		} )
	return new_position
end

setmetatable( Position, {
	__index = getmetatable(Position).__index,
	__call = new,
	} )
return Position
