-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base 			= require( "vyzor.base" )
local BoundingMode 	= require( "vyzor.enum.bounding_mode" )

--[[
	Class: Size
		Defines the Size Supercomponent.
]]
local Size = Base( "Supercomponent", "Size" )

--[[
	Constructor: new

	Parameters:
		frame 		- The <Frame> to which this Size Supercomponent belongs.
		init_width 	- Initial width of the <Frame>.
		init_height - Initial height of the <Frame>.
		is_first 	- Determines whether or not the parent <Frame> is the <HUD>.

	Returns:
		A new Size Supercomponent.
]]
local function new (_, frame, init_width, init_height, is_first)
	--[[
		Structure: New Size
			A Supercomponent used only within <Frames> to
			manage space. Only used internally. Should not
			be exposed.
	]]
	local new_size = {}

	-- Array: dims
	-- Contains the user-defined dimensions of the <Frame>.
	local dims = {
		Width = (init_width or 1),
		Height = (init_height or 1),
	}

	-- Array: abs_dims
	-- Contains the <Frame's> generated, window dimensions.
	local abs_dims = {}

	-- Array: content_dims
	-- Contains the <Frame's> generated, Content Rectangle dimensions.
	local content_dims = {}

	--[[
		Function: updateAbsolute
			Generates the absolute dimensions (<abs_dims>) of
			the <Frame>.
			Also generates content dimensions <content_dims>.
	]]
	local function updateAbsolute ()
		-- Is HUD.
		if is_first then
			abs_dims = dims
			content_dims = dims
			return
		end

		local frame_container = frame.Container
		assert( frame_container, "Vyzor: Frame must have container before Size can be determined." )
		local container_pos 	= frame_container.Position.Content
		local container_size 	= frame_container.Size.Content

		for dim, value in pairs(dims) do
			if value <= 1 and value > 0 then
				abs_dims[dim] = container_size[dim] * value
			elseif value < 0 then
				-- Between 0 and -1 to get inverse percentage. Necessary?
				abs_dims[dim] = container_size[dim] + value
			else
				abs_dims[dim] = value
			end
		end

		-- Bounding rules. Determines Frame manipulation when parent
		-- Frame is resized.
		if frame_container.IsBounding then
			if frame.BoundingMode == BoundingMode.Size then
				local frame_x = frame.Position.AbsoluteX
				local frame_edge_x = frame_x + abs_dims.Width
				local cont_edge_x = container_pos.X + container_size.Width
				if abs_dims.Width > container_size.Width then
					abs_dims.Width = container_size.Width
				elseif frame_edge_x > cont_edge_x then
					abs_dims.Width = abs_dims.Width - (frame_edge_x - cont_edge_x)
				end

				local frame_y = frame.Position.AbsoluteY
				local frame_edge_y = frame_y + abs_dims.Height
				local cont_edge_y = container_pos.Y + container_size.Height
				if abs_dims.Height > container_size.Height then
					abs_dims.Height = container_size.Height
				elseif frame_edge_y > cont_edge_y then
					abs_dims.Height = abs_dims.Height - (frame_edge_y - cont_edge_y)
				end
			end
		end

		do
		-- We must respect QT's Box Model, so we have to find the space the
		-- Content Rectangle occupies.
		-- See: http://doc.qt.nokia.com/4.7-snapshot/stylesheet-customizing.html
			local top_height = 0
			local right_width = 0
			local bottom_height = 0
			local left_width = 0

			local frame_comps = frame.Components

			local frame_border = frame_comps["Border"]
			if frame_border then
				local border = frame_border
				if border.Top then
					right_width = right_width + border.Right.Width
					left_width = left_width + border.Left.Width

					top_height = top_height + border.Top.Width
					bottom_height = bottom_height + border.Bottom.Width
				else
					if type( border.Width ) == "table" then
						right_width = right_width + border.Width[2]
						left_width = left_width + border.Width[4]

						top_height = top_height + borders.Width[1]
						bottom_height = bottom_height + borders.Width[3]
					else
						right_width = right_width + border.Width
						left_width = left_width + border.Width

						top_height = top_height + border.Width
						bottom_height = bottom_height + border.Width
					end
				end
			end

			local frame_margin = frame_comps["Margin"]
			if frame_margin then
				local margin = frame_margin
				right_width = right_width + margin.Right
				left_width = left_width + margin.Left

				top_height = top_height + margin.Top
				bottom_height = bottom_height + margin.Bottom
			end

			local frame_padding = frame_comps["Padding"]
			if frame_padding then
				local padding = frame_padding
				right_width = right_width + padding.Right
				left_width = left_width + padding.Left

				top_height = top_height + padding.Top
				bottom_height = bottom_height + padding.Bottom
			end

			content_dims = {
				Width = abs_dims.Width - (right_width + left_width),
				Height = abs_dims.Height - (top_height + bottom_height)
			}
		end
	end

	--[[
		Properties: Size Properties
			Dimensions 		- Gets and sets the relative (user-defined) dimensions
								(<dims>) of the <Frame>.
			Absolute 		- Returns the absolute dimensions (<abs_dims>) of the
								<Frame>.
			Content 		- Returns dimensions of the Content Rectangle
								(<content_dims>).
			Width 			- Gets and sets the relative width of the <Frame>.
			Height 			- Gets and sets the relative height of the <Frame>.
			AbsoluteWidth 	- Returns the absolute width of the <Frame>.
			AbsoluteHeight 	- Returns the absolute height of the <Frame>.
			ContentWidth 	- Returns the width of the Content Rectangle.
			ContentHeight 	- Returns the height of the Content Rectangle.
	]]
	local properties = {
		Dimensions = {
			get = function ()
				local copy = {}
				for i in pairs( dims ) do
					copy[i] = dims[i]
				end
				return copy
			end,
			set = function (value)
				dims.Width = value.Width or value[1]
				dims.Height = value.Height or value[2]
				updateAbsolute()
			end
		},
		Absolute = {
			get = function ()
				if not abs_dims.Width or not abs_dims.Height then
					updateAbsolute()
				end
				local copy = {}
				for i in pairs( abs_dims ) do
					copy[i] = abs_dims[i]
				end
				return copy
			end
		},
		Content = {
			get = function ()
				if not content_dims.Width or not content_dims.Height then
					updateAbsolute()
				end
				local copy = {}
				for i in pairs( abs_dims ) do
					copy[i] = content_dims[i]
				end
				return copy
			end
		},
		Width = {
			get = function ()
				return dims.Width
			end,
			set = function (value)
				dims.Width = value

				if frame.Container.IsDrawn then
					updateAbsolute()
				end
			end
		},
		Height = {
			get = function ()
				return dims.Height
			end,
			set = function (value)
				dims.Height = value

				if frame.Container.IsDrawn then
					updateAbsolute()
				end
			end
		},
		AbsoluteWidth = {
			get = function ()
				if not abs_dims.Width then
					updateAbsolute()
				end
				return abs_dims.Width
			end
		},
		AbsoluteHeight = {
			get = function ()
				if not abs_dims.Height then
					updateAbsolute()
				end
				return abs_dims.Height
			end
		},
		ContentWidth = {
			get = function ()
				if not content_dims.Width then
					updateAbsolute()
				end
				return content_dims.Width
			end
		},
		ContentHeight = {
			get = function ()
				if not content_dims.Height then
					updateAbsolute()
				end
				return content_dims.Height
			end
		},
	}

	setmetatable( new_size, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or Size[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set( value )
			end
		end,
		} )
	return new_size
end

setmetatable( Size, {
	__index = getmetatable(Size).__index,
	__call = new,
	} )
return Size
