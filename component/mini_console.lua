-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require( "vyzor.base" )

--[[
	Class: MiniConsole
		Defines the MiniConsole Component.
]]
local MiniConsole = Base( "Component", "MiniConsole" )

-- Array: master_list
-- Holds all MiniConsoles for consistent reference.
local master_list = {}

--[[
	Constructor: new

	Parameters:
		name 		- Used for echoing and other Mudlet referencing.
		init_x		- X coordinate position.
		init_y 		- Y coordinate position.
		init_width 	- Width of the MiniConsole.
		init_height - Height of the MiniConsole.
		word_wrap 	- Sets the MiniConsole's word wrap in characters. Default is dynamic
						or 80 if font_size is dynamic.
		font_size 	- Sets the MiniConsole's font size. Default is dynamic or 8
						if word_wrap is dynamic.
]]
local function new (_, name, init_x, init_y, init_width, init_height, word_wrap, font_size)
	assert( name, "Vyzor: New MiniConsole must have a name." )

	--[[
		Structure: New MiniConsole
			A Mudlet text container allowing that mimicks the
			main console.
	]]
	local new_console = {}

	-- Object: container
	-- The MiniConsole's parent frame. Usually set automatically when added to a Frame.
	local container

	-- Number: x
	-- User-defined X coordinate of the MiniConsole.
	local x = init_x or 0

	-- Number: absolute_x
	-- Actual X coordinate of the MiniConsole.
	local absolute_x

	-- Number: y
	-- User-defined Y Coordinate of the MiniConsole.
	local y = init_y or 0

	-- Number: absolute_y
	-- Actual Y Coordinate of the MiniConsole.
	local absolute_y

	-- Number: width
	-- User-defined Width of the MiniConsole.
	local width = init_width or 1.0

	-- Number: absolute_width
	-- Actual Width of the MiniConsole.
	local absolute_width

	-- Number: height
	-- User-defined Height of the MiniConsole.
	local height = init_height or 1.0

	-- Number: absolute_height
	-- Actual Height of the MiniConsole.
	local absolute_height

	-- Variable: wrap
	-- Number of characters at which the MiniConsole will wrap.
	local wrap = word_wrap or "dynamic"

	-- Number: absolute_wrap
	-- Actual word wrap of the MiniConsole.
	local absolute_wrap

	-- Variable: size
	-- Font size of the text in MiniConsole.
	local size = font_size or ((wrap == "dynamic" and 8) or "dynamic")

	-- Number: absolute_size
	-- Actual font size of the MiniConsole.
	local absolute_size

	if size == "dynamic" and wrap == "dynamic" then
		wrap = 80
	end

	--[[
		Function: updateAbsolutes
			Sets the actual size and position of the MiniConsole
			using the parent Frame's Content.
	]]
	local function updateAbsolutes ()
		if container then
			local frame_x 		= container.Position.ContentX
			local frame_y 		= container.Position.ContentY
			local frame_width 	= container.Size.ContentWidth
			local frame_height 	= container.Size.ContentHeight

			if x > 0.0 and x <= 1.0 then
				absolute_x = frame_x + (x * frame_width)
			else
				absolute_x = frame_x + x
			end

			if y > 0.0 and y <= 1.0 then
				absolute_y = frame_y + (y * frame_height)
			else
				absolute_y = frame_y + y
			end

			if width > 0.0 and width <= 1.0 then
				absolute_width = width * frame_width
			else
				absolute_width = width
			end

			if height > 0.0 and height <= 1.0 then
				absolute_height = height * frame_height
			else
				absolute_height = height
			end

			if wrap == "dynamic" then
				absolute_size = size
				local font_width = calcFontSize( absolute_size )
				absolute_wrap = absolute_width / font_width
			else
				absolute_wrap = wrap
				local current_size = 39
				local total_width = wrap * calcFontSize(current_size)
				while total_width > absolute_width do
					if current_size == 1 then
						break
					end
					current_size = current_size - 1
					total_width = wrap * calcFontSize(current_size)
				end
				absolute_size = current_size
			end
		end
	end

	--[[
		Properties: MiniConsole Properties
			Name 			- Returns the MiniConsole's name.
			Container 		- Gets and sets the MiniConsole's parent Frame.
			X 				- Gets and sets the MiniConsole's relative X coordinate.
			AbsoluteX 		- Returns the MiniConsole's actual X coordinate.
			Y 				- Gets and sets the MiniConsole's relative Y coordinate.
			AbsoluteY 		- Returns the MiniConsole's actual Y coordinate.
			Width 			- Gets and sets the MiniConsole's relative width.
			AbsoluteWidth 	- Returns the MiniConsole's actual width.
			Height 			- Gets and sets the MiniConsole's relative height.
			AbsoluteHeight 	- Returns the MiniConsole's actual height.
			WordWrap 		- Gets and sets the MiniConsole's word wrap. If <size> is
								dynamic, <size> is set to 8.
			AbsoluteWrap 	- Returns the actual word <wrap> of the MiniConsole.
			FontSize 		- Gets and sets the MiniConsole's font size. If <wrap> is
								dynamic, <wrap> is set to 80.
			AbsoluteSize 	- Returns the actual <size> of the MiniConsole's text.
	]]
	local properties = {
		Name = {
			get = function ()
				return name
			end
		},
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
		},
		WordWrap = {
			get = function ()
				return wrap
			end,
			set = function (value)
				wrap = value
				if wrap == "dynamic" and size == "dynamic" then
					size = 8
				end

				if container then
					updateAbsolutes()
					setWindowWrap( name, absolute_wrap )
				end
			end
		},
		AbsoluteWrap = {
			get = function ()
				return absolute_wrap
			end
		},
		FontSize = {
			get = function ()
				return size
			end,
			set = function (value)
				size = value
				if size == "dynamic" and wrap == "dynamic" then
					wrap = 80
				end

				if container then
					updateAbsolutes()
					setMiniConsoleFontSize( name, absolute_size )
				end
			end
		},
		AbsoluteSize = {
			get = function ()
				return absolute_size
			end
		}
	}

	--[[
		Function: Draw
			Draws the MiniConsole. Should only be called internally.
	]]
	function new_console:Draw ()
		if not container then
			error( string.format("Vyzor: Tried to Draw a MiniConsole (%s) without a parent Frame.",
				name), 2 )
		end

		updateAbsolutes()

		createMiniConsole( name, absolute_x, absolute_y, absolute_width, absolute_height )
		setMiniConsoleFontSize( name, absolute_size )
		setWindowWrap( name, absolute_wrap )
	end

	--[[
		Function: Resize

		Parameters:
			new_width 	- New relative width of the MiniConsole.
			new_height 	- New relative height of the MiniConsole.
	]]
	function new_console:Resize (new_width, new_height)
		width = new_width or width
		height = new_height or height
		updateAbsolutes()

		resizeWindow( name, absolute_width, absolute_height )
		setWindowWrap( name, absolute_wrap )
		setMiniConsoleFontSize( name, absolute_size )
	end

	--[[
		Function: Move

		Parameters:
			new_x - New relative X coordinate of the MiniConsole.
			new_y - New relative Y coordinate of the MiniConsole.
	]]
	function new_console:Move (new_x, new_y)
		x = new_x or x
		y = new_y or y
		updateAbsolutes()

		moveWindow( name, absolute_x, absolute_y )
	end

	--[[
		Function: Hide
	]]
	function new_console:Hide ()
		hideWindow( name )
	end

	--[[
		Function: Show
	]]
	function new_console:Show ()
		showWindow( name )
	end

	--[[
		Function: Echo
			Displays text on a MiniConsole. Starts where the last
			line left off.

		Parameters:
			text - The text to be displayed.
	]]
	function new_console:Echo (text)
		echo( name, text )
	end

	--[[
		Function: HEcho
			Displays text on a MiniConsole with Hex color formatting.

		Paramaters:
			text - The text to be displayed.
	]]
	function new_console:HEcho (text)
		hecho( name, text )
	end

	--[[
		Function: CEcho
			Displays text on a MiniConsole with colour tags.

		Paramaters:
			text - The text to be displayed.
	]]
	function new_console:CEcho (text)
		cecho( name, text )
	end

	--[[
		Function: DEcho
			Displays text on a MiniConsole with some crazy-ass formatting.

		Paramaters:
			text 	- The text to be displayed.
			fore 	- The foreground color of the text.
			back 	- The background color of the text.
			insert 	- If true, uses InsertText() instead of echo().
	]]
	function new_console:DEcho (text, fore, back, insert)
		decho( text, fore, back, insert, name )
	end

	--[[
		Function: EchoLink
			Displays a clickable line of text in a MiniConsole.

		Parameters:
			text 		- The text to be displayed.
			command 	- Script to be executed when clicked.
			hint 		- Tooltip text.
			keep_format - If true, uses Frame text formatting.
			insert		- If true, uses InsertText() instead of Echo()
	]]
	function new_console:EchoLink (text, command, hint, keep_format, insert)
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
			keep_format - If true, uses MiniConsole text formatting.
			insert		- If true, uses InsertText() insead of Echo().
	]]
	function new_console:EchoPopup (text, commands, hints, keep_format, insert)
		if not insert then
			echoPopup( name, text, commands, hints, keep_format )
		else
			insertPopup( name, text, commands, hints, keep_format )
		end
	end

	--[[
		Function: Paste
			Copies text to the MiniConsole from the clipboard (via copy()).
			Clears the window first.
	]]
	function new_console:Paste ()
		selectCurrentLine()
		copy()
		paste( name )
	end

	--[[
		Function: Append
			Copies text to the MiniConsole from a buffer or
			the clipboard (via copy()).
			Adds the text beginning at a new line.
	]]
	function new_console:Append ()
		selectCurrentLine()
		copy()
		appendBuffer( name )
	end

	--[[
		Function: Clear
			Clears all text from the MiniConsole.
	]]
	function new_console:Clear ()
		clearWindow( name )
	end

	setmetatable( new_console, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or MiniConsole[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set( value )
			end
		end,
		} )
	master_list[name] = new_console
	return new_console
end

setmetatable( MiniConsole, {
	__index = getmetatable(MiniConsole).__index,
	__call = new,
	} )
return MiniConsole
