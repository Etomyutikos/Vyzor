-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base 		= require("vyzor.base")
local BoxMode 	= require("vyzor.enum.box_mode")
local Lib		= require("vyzor.lib")

--[[
	Class: Box
		Defines a dynamically arranged collection
		of Frames.
]]
local Box = Base( "Compound", "Box" )

--[[
	Constructor: new

	Parameters:
		name 		- The name of the Box and the automatically
						generated container Frame.
		init_mode 	- Alignment of Frames. Defaults to Horizontal.
		init_back	- The background Frame for this Box.
		init_frames	- A numerically indexed table holding the Frames this Box contains.
]]
local function new (_, name, init_mode, init_back, init_frames)
	assert(name, "Vyzor: New Box must be supplied with a name")

	--[[
		Structure: New Box
			A container that holds and maintains a dynamically
			arranged collection of Frames.
	]]
	local new_box = {}

	-- Variable: mode
	-- The alignment of the Frames within the Box.
	local mode = init_mode or BoxMode.Horizontal

	-- Array: frames
	-- Holds this Box's Frames.
	local frames = Lib.OrderedTable()
	local frame_count = 0
	if init_frames and type(init_frames) == "table" then
		for i, frame in ipairs(init_frames) do
			frames[frame.Name] = frame
			frame_count = frame_count + 1
		end
	end

	-- Object: background_frame
	-- The Frame containing all other Frames.
	local background_frame = init_back
	if frame_count > 0 then
		for _, name, frame in frames() do
			background_frame:Add( frame )
		end
	end

	--[[
		Function: updateFrames()
			Updates the Box's Frames based on BoxMode.
	]]
	local function updateFrames()
		if mode == BoxMode.Horizontal then
			for index, name, frame in frames() do
				frame.Position.X 	= (1 / frame_count) * (index - 1)
				frame.Position.Y 	= 0
				frame.Size.Width 	= (1 / frame_count)
				frame.Size.Height 	= 1
			end
		elseif mode == BoxMode.Vertical then
			for index, name, frame in frames() do
				frame.Position.X 		= 0
				frame.Position.Y 		= (1 / frame_count) * (index - 1)
				frame.Size.Width 		= 1
				frame.Size.Height 		= (1 / frame_count)
			end
		elseif mode == BoxMode.Grid then
			local rows 		= math.floor(math.sqrt(frame_count))
			local columns 	= math.ceil(frame_count / rows)

			local cur_hori = 1
			local cur_vert = 1
			for index, name, frame in frames() do
				if cur_hori > rows then
					cur_hori = 1
					cur_vert = cur_vert + 1
				end

				frame.Position.X 	= (1 / rows) * (cur_hori - 1)
				frame.Position.Y 	= (1 / columns) * (cur_vert - 1)
				frame.Size.Width 	= (1 / rows)
				frame.Size.Height 	= (1 / columns)

				cur_hori = cur_hori + 1
			end
		end
	end

	--[[
		Properties: Box Properties
			Name 		- Returns the Box's name.
			Background 	- Exposes the Box's background Frame.
			Frames 		- Returns a copy of the Box's Frames.
			Container 	- Gets and sets the parent Frame of this Box.
			Mode 		- Gets and sets the Box's BoxMode.
	]]
	local properties = {
		Name = {
			get = function ()
				return name
			end,
		},
		Background = {
			get = function ()
				return background_frame
			end,
		},
		Frames = {
			get = function ()
				if frame_count > 0 then
					local copy = {}
					for _, k, v in frames() do
						copy[k] = v
					end
					return copy
				else
					return {}
				end
			end,
		},
		Container = {
			get = function ()
				return background_frame.Container
			end,
			set = function (value)
				background_frame.Container = value
			end
		},
		Mode = {
			get = function ()
				return box_mode
			end,
			set = function (value)
				if BoxMode:IsValid( value ) then
					box_mode = value
					updateFrames()
				else
					error(
						string.format("Vyzor: Invalid BoxMode Enum passed to %s", name), 3
					)
				end
			end
		},
	}

	updateFrames()
	setmetatable( new_box, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or Box[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set( value )
			end
		end,
	} )
	return new_box
end

setmetatable( Box, {
	__index = getmetatable(Box).__index,
	__call = new,
} )
return Box
