-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Background	= require( "vyzor.component.background" )
local Base 			= require( "vyzor.base" )
local Brush			= require( "vyzor.component.brush" )
local Color			= require( "vyzor.component.color" )
local ColorMode		= require( "vyzor.enum.color_mode" )
local Frame			= require( "vyzor.base.frame" )
local GaugeFill 	= require( "vyzor.enum.gauge_fill" )
local Lib			= require( "vyzor.lib" )

--[[
	Class: Gauge
		Defines a Gauge Compound.
]]
local Gauge = Base( "Compound", "Gauge" )

-- Array: master_list
-- A list of Gauges, used to update all Gauges.
local master_list = {}

--[[
	Function: VyzorGaugeUpdate
		A dirty global function to update all Vyzor Gauges.
]]
function VyzorGaugeUpdate ()
	for _, gauge in pairs( master_list ) do
		gauge:Update()
	end
end

--[[
	Constructor: new

	Parameters:
		name 		- The name of the Gauge.
		current 	- The string address of the current stat to track.
		maximum 	- The string address of the current stat to track.
		init_back 	- The Background Frame.
		init_fore 	- The Foreground Frame. Size and Position values will be overwritten.
		fill_enum 	- GaugeFill Enum. Determines direction Gauge fills.
						Defaults to LeftRight.
		init_over	- Numerically indexed table of Frames to be used for overflow.
]]
local function new (_, name, current, maximum, init_back, init_fore, fill_enum, init_over)
	assert( current and maximum, "Vyzor: A new Gauge must have both current and maximum addresses to track." )

	--[[
		Structure: New Gauge
			A lightweight container for Frames that will function as
			a dynamically resized bar.
	]]
	local new_gauge = {}

	-- String: current_address
	-- Index of current variable.
	local current_address = current

	-- Number: current_stat
	-- Numeric value of current variable.
	local current_stat

	-- String: maximum_address
	-- Index of maximum variable.
	local maximum_address = maximum

	-- Number: maximum_stat
	-- Numeric value of maximum stat.
	local maximum_stat

	-- Object: background_frame
	-- Frame serving as Gauge's background.
	local background_frame = init_back

	-- Object: foreground_frame
	-- Frame serving as Gauge's foreground.
	local foreground_frame = init_fore

	-- Array: overflow_frames
	-- Contains the Gauge's overflow frames.
	local overflow_frames = Lib.OrderedTable()
	local overflow_count = 0
	if init_over and type(init_over) == "table" then
		for i, frame in ipairs( init_over ) do
			overflow_frames[frame.Name] = frame
			overflow_count = overflow_count + 1
		end
	end

	-- Object: caption_frame
	-- Generated frame that can be echoed to.
	local caption_frame = Frame( name .. "_caption" )
	caption_frame:Add(
		Background(
			Brush(
				Color( ColorMode.RGBA, 0, 0, 0, 0 )
			)
		)
	)

	-- Boolean: auto_echo
	-- Should this Gauge echo every update?
	local auto_echo = true

	-- String: text_format
	-- Format used when auto_echo is true.
	local text_format = "<center>%s / %s</center>"

	-- The foreground is a child of the background. Let's do that.
	background_frame:Add( foreground_frame )
	if overflow_count > 0 then
		for _, name, frame in overflow_frames() do
			background_frame:Add( frame )
		end
	end
	background_frame:Add( caption_frame )

	-- Object: fill_mode
	-- Determines direction Gauge fills.
	local fill_mode = fill_enum or GaugeFill.LeftRight

	--[[
		Properties: Gauge Properties
			Name 			- Returns the Gauge's name.
			Container 		- Gets and sets the Gauge's container.
			CurrentAddress 	- Gets and sets the Gauge's current variable index.
			Current 		- Returns the numeric value of the current variable.
			MaximumAddress 	- Gets and sets the Gauge's maximum variable index.
			Maximum 		- Returns the numeric value of the maximum variable.
			Background 		- Returns the Gauge's Background Frame.
			Foreground 		- Returns the Gauge's Foreground Frame.
			FillMode 		- Gets and sets the Gauge's fill direction.
			AutoEcho		- Gets and sets the Gauge's <auto_echo> property.
			TextFormat		- Gets and sets the format used by <auto_echo>.
								Must be compatible with string.format.
			Overflow		- Returns a copy of the Gauge's overflow Frames.
	]]
	local properties = {
		Name = {
			get = function ()
				return name
			end
		},
		Container = {
			get = function ()
				return background_frame.Container
			end,
			set = function (value)
				background_frame.Container = value
			end
		},
		CurrentAddress = {
			get = function ()
				return current_address
			end,
			set = function (value)
				current_address = value
			end
		},
		Current = {
			get = function ()
				return current_stat
			end
		},
		MaximumAddress = {
			get = function ()
				return maximum_address
			end,
			set = function (value)
				maximum_address = value
			end
		},
		Maximum = {
			get = function ()
				return maximum_stat
			end
		},
		Background = {
			get = function ()
				return background_frame
			end
		},
		Foreground = {
			get = function ()
				return foreground_frame
			end
		},
		AutoEcho = {
			get = function ()
				return auto_echo
			end,
			set = function (value)
				auto_echo = value
			end,
		},
		TextFormat = {
			get = function ()
				return text_format
			end,
			set = function (value)
				text_format = value
			end,
		},
		Overflow = {
			get = function ()
				local copy = {}
				for _, k, v in overflow_frames() do
					copy[k] = v
				end
				return copy
			end
		},
	}

	--[[
		Function: getField
			Retrieves the value of the given index.

		Parameters:
			field - The index of the value to be retrieved.
	]]
	local function getField (field)
		local v = _G
		for w in string.gfind(field, "[%w_]+") do
			v = v[w]
		end
		return v
	end

	--[[
		Function: Update
			Updates the Gauge.
	]]
	function new_gauge:Update ()
		current_stat = getField( current_address ) or 1
		maximum_stat = getField( maximum_address ) or 1
		local scalar = current_stat / maximum_stat

		local over_scalars = {}
		if scalar > 1 then
			local current_scalar = scalar - 1
			scalar = 1

			if overflow_count > 0 then
				local i = 1
				while current_scalar > 1 do
					over_scalars[i] = 1
					current_scalar = current_scalar - 1
					i = i + 1
				end
				over_scalars[i] = current_scalar
			end
		end

		if fill_mode == GaugeFill.LeftRight then
			foreground_frame.Size.Width = scalar
			if overflow_count > 0 then
				for _, _, frame in overflow_frames() do
					frame:Hide()
				end
			end

			if #over_scalars > 0 then
				for index, name, frame in overflow_frames() do
					local overage = over_scalars[index]
					if overage then
						frame:Show()
						frame.Size.Width = overage
					end
				end
			end
		elseif fill_mode == GaugeFill.RightLeft then
			foreground_frame.Size.Width = scalar
			foreground_frame.Position.X = 1.0 - scalar

			if #over_scalars > 0 then
				for index, name, frame in overflow_frames() do
					local overage = over_scalars[index]
					if overage then
						frame:Show()
						frame.Size.Width = over_scalars[index]
						frame.Position.X = 1.0 - over_scalars[index]
					end
				end
			end
		elseif fill_mode == GaugeFill.TopBottom then
			foreground_frame.Size.Height = scalar

			if #over_scalars > 0 then
				for index, name, frame in overflow_frames() do
					local overage = over_scalars[index]
					if overage then
						frame:Show()
						frame.Size.Height = over_scalars[index]
					end
				end
			end
		elseif fill_mode == GaugeFill.BottomTop then
			foreground_frame.Size.Height = scalar
			foreground_frame.Position.Y = 1.0 - scalar

			if #over_scalars > 0 then
				for index, name, frame in overflow_frames() do
					frame.Size.Height = over_scalars[index] or 0
					frame.Position.Y = 1.0 - over_scalars[index] or 0
				end
			end
		end

		foreground_frame:Resize()
		foreground_frame:Move()
		if overflow_count> 0 then
			for _, _, frame in overflow_frames() do
				frame:Resize()
				frame:Move()
			end
		end

		if auto_echo then
			new_gauge:Echo()
		end
	end

	--[[
		Function: Echo
			Displays text on the auto-generated caption
			Frame.

		Parameters:
			text - The text to be displayed.
	]]
	function new_gauge:Echo (text)
		if text then
			echo( caption_frame.Name, text )
		else
			echo( caption_frame.Name,
				string.format( text_format, current_stat, maximum_stat )
			)
		end
	end

	--[[
		Function: VyzorInitializeGauges
			Calls update on each Gauge after Vyzor has been drawn.
	]]
	function VyzorInitializeGauges ()
		if #master_list > 0 then
			for _, gauge in ipairs( master_list ) do
				gauge:Update()
			end
		end
	end

	registerAnonymousEventHandler( "VyzorDrawnEvent", "VyzorInitializeGauges" )

	setmetatable( new_gauge, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or Gauge[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set( value )
			end
		end,
		} )
	master_list[#master_list+1] = new_gauge
	return new_gauge
end

setmetatable( Gauge, {
	__index = getmetatable(Gauge).__index,
	__call = new,
	} )
return Gauge
