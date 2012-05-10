-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require( "vyzor.base")

--[[
	Class: Map
		Defines the Map Component.
]]
local Map = Base( "Component", "Map" )

--[[
	Constructor: new

	Parameters:
		init_x 		- Mapper's initial X coordinate.
		init_y 		- Mapper's initial Y coordinate.
		init_width 	- Mapper's initial Width.
		init_height - Mapper's initial Height.
]]
local function new (_, init_x, init_y, init_width, init_height)
	--[[
		Structure: New Map
			A container for Mudlet's built-in Map display.
	]]
	local new_map = {}

	-- Object: container
	-- Parent Frame.
	local container

	-- Boolean: is_hidden
	-- Special handling for special Map hiding.
	local is_hidden = false

	-- Number: x
	-- User-defined X coordinate.
	local x = init_x or 0

	-- Number: absolute_x
	-- Actual X coordinate.
	local absolute_x

	-- Number: y
	-- User-defined Y coordinate.
	local y = init_y or 0

	-- Number: absolute_y
	-- Actual Y coordinate.
	local absolute_y

	-- Number: width
	-- User-defined width.
	local width = init_width or 1.0

	-- Number: absolute_width
	-- Actual width.
	local absolute_width

	-- Number: height
	-- User-defined height.
	local height = init_height or 1.0

	-- Number: absolute_height
	-- Actual height.
	local absolute_height

	--[[
		Properties: Map Properties
			Container 		- Gets and sets the Map's parent Frame.
			X 				- Gets and sets the user-defined X coordinate.
			AbsoluteX 		- Returns the actual X coordinate.
			Y 				- Gets and sets the user-defined Y coordinate.
			AbsoluteY 		- Returns the actual Y coordinate.
			Width 			- Gets and sets the user-defined width.
			AbsoluteWidth 	- Returns the actual width.
			Height 			- Gets and sets the user-defined height.
			AbsoluteHeight 	- Returns the actual height.
	]]
	local properties = {
		Container = {
			get = function ()
				return container
			end,
			set = function (value)
				if value.Type == "Frame" then
					container = value
				end
			end
		},
		X = {
			get = function ()
				return x
			end,
			set = function (value)
				x = value
				updateAbsolutes()
			end
		},
		AbsoluteX = {
			get = function ()
				return absolute_x
			end
		},
		Y = {
			get = function ()
				return y
			end,
			set = function (value)
				y = value
				updateAbsolutes()
			end
		},
		AbsoluteY = {
			get = function ()
				return absolute_y
			end
		},
		Width = {
			get = function ()
				return width
			end,
			set = function (value)
				width = value
				updateAbsolutes()
			end
		},
		AbsoluteWidth = {
			get = function ()
				return absolute_width
			end
		},
		Height = {
			get = function ()
				return height
			end,
			set = function (value)
				height = value
				updateAbsolutes()
			end
		},
		AbsoluteHeight = {
			get = function ()
				return absolute_height
			end
		}
	}

	--[[
		Function: updateAbsolutes
			Sets the actual size and position of the Map
			using the parent Frame's Content.
	]]
	local function updateAbsolutes ()
		if container then
			local frame_pos		= container.Position
			local frame_x 		= frame_pos.ContentX
			local frame_y 		= frame_pos.ContentY

			local frame_siz		= container.Size
			local frame_width 	= frame_siz.ContentWidth
			local frame_height 	= frame_siz.ContentHeight

			if x >= 0.0 and x <= 1.0 then
				absolute_x = frame_x + (x * frame_width)
			else
				absolute_x = frame_x + x
			end

			if y >= 0.0 and y <= 1.0 then
				absolute_y = frame_y + (y * frame_height)
			else
				absolute_y = frame_y + y
			end

			if width >= 0.0 and width <= 1.0 then
				absolute_width = width * frame_width
			else
				absolute_width = width
			end

			if height >= 0.0 and height <= 1.0 then
				absolute_height = height * frame_height
			else
				absolute_height = height
			end
		end
	end

	--[[
		Function: Draw
			The map magically appears! Probably best used
			internally only.
	]]
	function new_map:Draw ()
		updateAbsolutes()

		createMapper( absolute_x, absolute_y, absolute_width, absolute_height )
	end

	--[[
		Function: Resize
			Adjusts the Map's size.

		Parameters:
			new_width 	- Map's new width.
			new_height 	- Map's new height.
	]]
	function new_map:Resize (new_width, new_height)
		width = new_width or width
		height = new_height or height
		updateAbsolutes()

		if not is_hidden then
			createMapper( absolute_x, absolute_y, absolute_width, absolute_height )
		else
			createMapper( absolute_x, absolute_y, 0, 0 )
		end
	end

	--[[
		Function: Move
			Moves the Map.

		Parameters:
			new_x - Map's new relative X coordinate.
			new_y - Map's new relative Y coordinate.
	]]
	function new_map:Move (new_x, new_y)
		x = new_x or x
		y = new_y or y
		updateAbsolutes()

		if not is_hidden then
			createMapper( absolute_x, absolute_y, absolute_width, absolute_height )
		else
			createMapper( absolute_x, absolute_y, 0, 0 )
		end
	end

	--[[
		Function: Hide
			Hides the Map. Sort of. Makes it very, very tiny.
	]]
	function new_map:Hide ()
		is_hidden = true
		createMapper( absolute_x, absolute_y, 0, 0 )
	end

	--[[
		Function: Show
			Returns the Map to its original size.
	]]
	function new_map:Show ()
		is_hidden = false
		createMapper( absolute_x, absolute_y, absolute_width, absolute_height )
	end

	setmetatable( new_map, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or Map[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set( value )
			end
		end,
		} )
	return new_map
end

setmetatable( Map, {
	__index = getmetatable(Map).__index,
	__call = new,
	} )
return Map
