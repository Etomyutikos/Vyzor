-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base 			= require( "vyzor.base" )
local Lib 			= require( "vyzor.lib" )
local Options		= require( "vyzor.base.options" )
local Position 		= require( "vyzor.component.position" )
local Size 			= require( "vyzor.component.size" )
local BoundingMode 	= require( "vyzor.enum.bounding_mode" )

--[[
	Class: Frame
		Defines the primary container for
		Vyzor Components. Frames are modified via Components,
		and may hold other Frames.
]]
local Frame = Base("Frame")

-- Boolean: first_frame
-- Used for very specific handling of the master Vyzor HUD.
local first_frame = true

-- Array: master_list
-- Holds all Frames for reference.
local master_list = {}

--[[
	Constructor: new

	Parameters:
		name 	- The name of the Frame, used for addressing.
		x 		- Initial X position of the Frame. Defaults to 0.
		y 		- Initial Y position of the Frame. Defaults to 0.
		width 	- Initial width of the Frame. Defaults to 1.
		height 	- Initial height of the Frame. Defaults to 1.

	Returns:
		A new Frame.
]]
local function new (_, name, x, y, width, height)
	assert( name, "Vyzor: Must define a name for new Frame." )
	assert( type( name ) == "string", "Vyzor: New Frame's name must be a string." )

	-- Structure: New Frame
	-- A new Frame object.
	local new_frame = {}

	-- Boolean: is_first
	-- Is this the HUD?
	local is_first = first_frame

	-- Boolean: is_drawn
	-- Has this Frame been drawn?
	local is_drawn = is_first

	-- Boolean: is_bounding
	-- Does this object obey bounding rules?
	local is_bounding = false

	-- String: bounding_type
	-- The <BoundingMode> rules to which this object adheres.
	local bounding_type = BoundingMode.Size

	-- Object: container
	-- The Frame that contains this one.
	local container

	-- Array: components
	-- A list of Components this Frame contains.
	local components = {}
	local component_count = 0

	-- Array: mini_consoles
	-- Stores MiniConsole Components.
	local mini_consoles = {}
	local mini_console_count = 0

	-- Array: compounds
	-- Stores Compounds.
	local compounds = {}
	local compound_count = 0

	-- Array: frames
	-- A list of Frames this Frame contains.
	local frames = Lib.OrderedTable()
	local frame_count = 0

	-- String: callback
	-- The name of a function to be used as a Label callback.
	local callback

	-- Array: callback_args
	-- A table holding the arguments for a Label callback.
	local callback_args

	-- Object: position
	-- The Position Supercomponent managing this Frame's
	-- location.
	local position = Position( new_frame, x, y, is_first )

	-- Object: size
	-- The Size Supercomponent managing this Frame's space.
	local size = Size( new_frame, width, height, is_first )

	first_frame = false

	-- String: stylesheet
	-- This Frame's Stylesheet. Generated via <updateStylesheet>.
	local stylesheet
	--[[
		Function: updateStylesheet
			Polls all Component's for their Stylesheets.
			Constructs the final <stylesheet> applied by setLabelStyleSheet.
	]]
	local function updateStylesheet ()
		if component_count > 0 then
			local style_table = {}
			for i,v in pairs( components ) do
				-- Hover is a special case. It must be last, and it will
				-- contain its own components. So we save it for last.
				if v.Subtype ~= "Hover" or v.Subtype ~= "MiniConsole" or v.Subtype ~= "Map" then
					style_table[#style_table+1] = v.Stylesheet
				end
			end
			style_table[#style_table+1] = components["Hover"] and components["Hover"].Stylesheet

			stylesheet = table.concat( style_table, "; " )
			stylesheet = string.format( "%s;", stylesheet )
		end
	end

	--[[
		Properties: Frame Properties
			Name 				- Return the Frame's name.
			IsBounding 			- Gets and sets a boolean value.
			Container 			- Gets and sets the parent Frame for this Frame.
			Components 			- Returns a copy of the Frame's Components.
			MiniConsoles 		- Returns a copy of the Frame's MiniConsoles.
			Compounds 			- Returns a copy of the Frame's Compounds.
			Frames 				- Returns a copy of the Frame's child Frames.
			Position 			- Returns this Frame's Position Supercomponent.
			Size 				- Returns this Frame's Size Supercomponent.
			Stylesheet 			- Updates and returns this Frame's Stylesheet.
			Callback			- Gets and sets a Callback for this Frame.
			CallbackArguments 	- Gets and sets the arguments passed to the Callback.
									Should be a table.
			IsDrawn				- Has this Frame been drawn?
	]]
	local properties = {
		Name = {
			get = function ()
				return name
			end,
		},
		IsBounding = {
			get = function ()
				return is_bounding
			end,
			set = function (value)
				is_bounding = value
			end
		},
		Container = {
			get = function ()
				return container
			end,
			set = function (value)
				container = value
			end,
		},
		Components = {
			get = function ()
				if component_count > 0 then
					local copy = {}
					for i in pairs( components ) do
						copy[i] = components[i]
					end
					return copy
				else
					return {}
				end
			end,
		},
		MiniConsoles = {
			get = function ()
				if mini_console_count > 0 then
					local copy = {}
					for i in pairs( mini_consoles ) do
						copy[i] = mini_consoles[i]
					end
					return copy
				else
					return {}
				end
			end,
		},
		Compounds = {
			get = function ()
				if compound_count > 0 then
					local copy = {}
					for i in pairs( compounds ) do
						copy[i] = compounds[i]
					end
					return copy
				else
					return {}
				end
			end
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
			end
		},
		Position = {
			get = function ()
				return position
			end
		},
		Size = {
			get = function ()
				return size
			end
		},
		Stylesheet = {
			get = function ()
				if not stylesheet then
					updateStylesheet()
				end
				return stylesheet
			end
		},
		Callback = {
			get = function ()
				return callback
			end,
			set = function (value)
				callback = value
				if callback_args then
					setLabelClickCallback( name, callback, unpack(callback_args) )
				else
					setLabelClickCallback( name, callback )
				end
			end,
		},
		CallbackArguments = {
			get = function ()
				return callback_args
			end,
			set = function (value)
				callback_args = value
				if callback then
					setLabelClickCallback( name, callback, unpack(value) )
				end
			end,
		},
		IsDrawn = {
			get = function ()
				return is_drawn
			end,
		},
	}

	--[[
		Function: Add
			Adds a new object to this Frame.
			Objects can be a string (must be a valid Frame name),
			a Frame object, or a Component object.

		Parameters:
			object - A valid Frame name or object, or a Component.
	]]
	function new_frame:Add (object)
		if type( object ) == "string" then
			if master_list[object] then
				master_list[object].Container = master_list[name]
				frames[object] = master_list[object]
				frame_count = frame_count + 1
			else
				error( string.format(
					"Vyzor: Invalid Frame (%s) passed to %s:Add.",
					object, name ), 2 )
			end
		elseif type( object ) == "table" then
			if object.Type then
				if object.Type == "Frame" then
					master_list[object.Name].Container = master_list[name]
					frames[object.Name] = master_list[object.Name]
					frame_count = frame_count + 1
				elseif object.Type == "Component" then
					if not components[object.Subtype] then
						if object.Subtype == "MiniConsole" then
							mini_consoles[object.Name] = object
							mini_console_count = mini_console_count + 1
						else
							components[object.Subtype] = object
							component_count = component_count + 1
						end

						if object.Subtype == "MiniConsole" or object.Subtype == "Map" then
							object.Container = master_list[name]
						end
					else
						error( string.format(
							"Vyzor: %s (Frame) already contains Component (%s).",
							name, object.Subtype ), 2 )
					end
				elseif object.Type == "Compound" then
					compounds[object.Name] = object
					compound_count = compound_count + 1
					object.Container = master_list[name]

					if object.Subtype == "Box" then
						frames[object.Frame.Name] = master_list[object.Frame.Name]
						frame_count = frame_count + 1
					end
				else
					error( string.format(
						"Vyzor: Invalid Type (%s) passed to %s:Add.",
						object.Type, name ), 2 )
				end
			else
				error( string.format(
					"Vyzor: Invalid object (%s) passed to %s:Add.",
					type( object ), name ), 2 )
			end
		else
			error( string.format(
				"Vyzor: Invalid object (%s) passed to %s:Add.",
				type( object ), name ), 2 )
		end
	end

	--[[
		Function: Remove
			Removes an object from this Frame.
			Objects must be a string (must be a valid Frame's name or
			Component Subtype), a Frame object, or a Component object.

		Parameters:
			object - A valid Frame name or object, or a Component
				Subtype or object.
	]]
	function new_frame:Remove (object)
		if type( object ) == "string" then
			if master_list[object] then
				master_list[object].Container = nil
				frames[object] = nil
				frame_count = frame_count - 1
			elseif components[object] or mini_consoles[object] then
				if mini_consoles[object] then
					mini_consoles[object].Container = nil
					mini_consoles[object] = nil
					mini_console_count = mini_console_count - 1
				else
					if object == "Map" then
						components[object].Container = nil
					end
					components[object] = nil
					component_count = component_count - 1
				end
--~ 			elseif compounds[object] then
--~ 				compounds[object].Container = nil
--~ 				compounds[object] = nil
--~ 				compound_count = compound_count - 1
			else
				error( string.format(
					"Vyzor: Invalid string '%s' passed to %s:Remove.",
					object, name ), 2 )
			end
		elseif type( object ) == "table" then
			if object.Type then
				if object.Type == "Frame" then
					for _, name, frame in frames() do
						if frame == object then
							master_list[name].Container = nil
							frames[name] = nil
							frame_count = frame_count - 1
							break
						end
					end
				elseif object.Type == "Component" then
					if mini_consoles[object.Name] then
						mini_consoles[object.Name] = nil
						mini_console_count = mini_console_count - 1
					elseif components[object.Subtype] then
						components[object.Subtype] = nil
						component_count = component_count - 1

						if object.Subtype == "MiniConsole" or object.Subtype == "Map" then
							object.Container = nil
						end
					else
						error( string.format(
							"Vyzor: %s (Frame) does not contain Component (%s).",
							name, object.Subtype ), 2 )
					end
				elseif object.Type == "Compound" then
					if compounds[object.Name] then
						compounds[object.Name] = nil
						compound_count = compound_count -1
						object.Container = nil

						if object.Subtype == "Box" then
							frames[object.Frame.Name] = nil
							frame_count = frame_count - 1
						end
					end
				else
					error( string.format(
						"Vyzor: Invalid Type (%s) passed to %s:Remove.",
						object.Type, name ), 2 )
				end
			else
				error( string.format(
					"Vyzor: Invalid object (%s) passed to %s:Remove.",
					type( object ), name ), 2 )
			end
		else
			error( string.format(
				"Vyzor: Invalid object (%s) passed to %s:Remove.",
				type( object ), name ), 2 )
		end
	end

	--[[
		Function: Draw
			Draws this Frame. Is only called via Vyzor:Draw().
			Should not be used directly on a Frame.
	]]
	function new_frame:Draw ()
		-- We don't draw the master Frame, because it covers
		-- everything. Think of it as a virtual Frame.
		if not is_first then
			createLabel( name,
				position.AbsoluteX, position.AbsoluteY,
				size.AbsoluteWidth, size.AbsoluteHeight, 1
			)
			updateStylesheet()
			if stylesheet then
				setLabelStyleSheet( name, stylesheet )
			end

			if mini_console_count > 0 then
				for _, console in pairs(mini_consoles) do
					console:Draw()
				end
			end
			if components["Map"] then
				components["Map"]:Draw()
			end

			if callback then
				if callback_args then
					setLabelClickCallback( name, callback, unpack(callback_args) )
				else
					setLabelClickCallback( name, callback )
				end
			end

			is_drawn = true
		end

		local draw_order = Options.DrawOrder
		if is_first then
			local function title (text)
				local first = text:sub( 1, 1 ):upper()
				local rest = text:sub( 2 ):lower()
				return first .. rest
			end

			for _,v in ipairs( draw_order ) do
				local side = "Vyzor" .. title( v )
				if Vyzor.HUD.Frames[side] then
					Vyzor.HUD.Frames[side]:Draw()
				else
					error("Vyzor: Invalid entry in Options.DrawOrder. Must be top, bottom, left, or right.", 2)
				end
			end
		else
			if frame_count > 0 then
				for _, _, frame in frames() do
					frame:Draw()
				end
			end
		end

		if is_first then
			VyzorResize()
		end
	end

	--[[
		Function: Resize
			Resizes the Frame.

		Parameters:
			new_width 	- The Frame's new width.
			new_height 	- The Frame's new height.
	]]
	function new_frame:Resize (new_width, new_height)
		size.Dimensions = {new_width or size.Width, new_height or size.Height}
		if not is_first then
			resizeWindow( name, size.AbsoluteWidth, size.AbsoluteHeight )
		end

		if mini_console_count > 0 then
			for _, console in pairs(mini_consoles) do
				console:Resize()
			end
		end
		if components["Map"] then
			components["Map"]:Resize()
		end

		if frame_count > 0 then
			for _, _, frame in frames() do
				frame:Resize()
			end
		end
	end

	--[[
		Function: Move
			Repositions the Frame.

		Parameters:
			new_x - The Frame's new X position.
			new_y - The Frame's new Y position.
	]]
	function new_frame:Move (new_x, new_y)
		position.Coordinates = {new_x or position.X, new_y or position.Y}
		if not is_first then
			moveWindow( name, position.AbsoluteX, position.AbsoluteY )
		end

		if mini_console_count > 0 then
			for _, console in pairs(mini_consoles) do
				console:Move()
			end
		end
		if components["Map"] then
			components["Map"]:Move()
		end

		if frame_count > 0 then
			for _, _, frame in frames() do
				frame:Move()
			end
		end
	end

	--[[
		Function: Hide
			Hides the Frame.
			Iterates through the Frame's children first, hiding
			each of them before hiding itself.
	]]
	function new_frame:Hide ()
		if frame_count > 0 then
			for _, _, frame in frames() do
				frame:Hide()
			end
		end

		if mini_console_count > 0 then
			for _, console in pairs(mini_consoles) do
				console:Hide()
			end
		end
		if components["Map"] then
			components["Map"]:Hide()
		end

		if not is_first then
			hideWindow( name )
		end
	end

	--[[
		Function: Show
			Reveals the Frame.
			Reveals itself first, then iterates through each of its
			children, revealing them.
	]]
	function new_frame:Show ()
		if not is_first then
			showWindow( name )
		end

		if mini_console_count > 0 then
			for _, console in pairs(mini_consoles) do
				console:Show()
			end
		end
		if components["Map"] then
			components["Map"]:Show()
		end

		if frame_count > 0 then
			for _, _, frame in frames() do
				frame:Show()
			end
		end
	end

	--[[
		Function: Echo
			Displays text on a Frame.

		Parameters:
			text - The text to be displayed.
	]]
	function new_frame:Echo (text)
		echo( name, text )
	end

	--[[
		Function: HEcho
			Displays text on a Frame with Hex color formatting.

		Paramaters:
			text - The text to be displayed.
	]]
	function new_frame:HEcho (text)
		hecho( name, text )
	end

	--[[
		Function: CEcho
			Displays text on a Frame with colour tags.

		Paramaters:
			text - The text to be displayed.
	]]
	function new_frame:CEcho (text)
		cecho( name, text )
	end

	--[[
		Function: DEcho
			Displays text on a frame with some crazy-ass formatting.

		Paramaters:
			text 	- The text to be displayed.
			fore 	- The foreground color of the text.
			back 	- The background color of the text.
			insert 	- If true, uses InsertText() instead of echo().
	]]
	function new_frame:DEcho (text, fore, back, insert)
		decho( text, fore, back, insert, name )
	end

	--[[
		Function: EchoLink
			Displays a clickable line of text in a Frame.

		Parameters:
			text 		- The text to be displayed.
			command 	- Script to be executed when clicked.
			hint 		- Tooltip text.
			keep_format - If true, uses Frame text formatting.
			insert		- If true, uses InsertText() instead of Echo()
	]]
	function new_frame:EchoLink (text, command, hint, keep_format, insert)
		if not insert then
			echoLink( name, text, command, hint, keep_format)
		else
			insertLink( name, text, command, hint, keep_format)
		end
	end

	--[[
		Function: EchoPopup
			Clickable text that expands out to a menu.

		Parameters:
			text 		- The text to be displayed.
			commands 	- A table of scripts to be executed.
			hints 		- A table of tooltips.
			keep_format - If true, uses Frame text formatting.
			insert		- If true, uses InsertText() insead of Echo().
	]]
	function new_frame:EchoPopup (text, commands, hints, keep_format, insert)
		if not insert then
			echoPopup( name, text, commands, hints, keep_format )
		else
			insertPopup( name, text, commands, hints, keep_format )
		end
	end

	--[[
		Function: Paste
			Copies text to the Frame from the clipboard (via copy()).
	]]
	function new_frame:Paste ()
		paste( name )
	end

	--[[
		Function: Clear
			Clears all text from the Frame.

		Paramaters:
			do_children - Will call clear on child Frames if true.
	]]
	function new_frame:Clear (do_children)
		clearWindow( name )

		if do_children then
			for _, _, frame in frames() do
				frame:Clear(true)
			end
		end
	end

	setmetatable( new_frame, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or Frame[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set( value )
			end
		end,
		__tostring = function (_)
			return name
		end,
		} )
	master_list[name] = new_frame
	return new_frame
end

setmetatable( Frame, {
	__index = getmetatable(Frame).__index,
	__call = new,
	} )
return Frame
