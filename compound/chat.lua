-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Background 	= require( "vyzor.component.background" )
local Base 			= require( "vyzor.base" )
local Box 			= require( "vyzor.compound.box" )
local BoxMode 		= require( "vyzor.enum.box_mode" )
local Brush 		= require( "vyzor.component.brush" )
local Color 		= require( "vyzor.component.color" )
local ColorMode 	= require( "vyzor.enum.color_mode" )
local Frame 		= require( "vyzor.base.frame" )
local Lib 			= require( "vyzor.lib" )
local MiniConsole 	= require( "vyzor.component.mini_console" )
local TabLocation 	= require( "vyzor.enum.tab_location" )

--[[
	Class: Chat
		Manages a number of MiniConsoles and tabs for a clean interface for text.
]]
local Chat = Base( "Compound", "Chat" )

--[[
	Constructor: new

	Parameters:
		name 			- Name of the Chat Compound. Used to create unique event
							handler functions.
		init_back 		- The Background Frame for this Chat Compound.
		init_channels 	- The names of the channels managed by this Compound.
								Passed as a table.
		init_tabloc		- Optional. A TabLocation Enum that determines on which
								side of the consoles the tabs sit. Default is top.
		init_size 		- Optional. This is the size of the unmanaged portion of the
								tabs. Must be between 0.0 and 1.0. Default is 0.05.
		init_wrap 		- Optional. This is the word wrap of the MiniConsole text.
								Default is "dynamic".
		init_font		- Optional. This is the font size of the MiniConsole text.
								Default is 10. Can be "dynamic"
		init_components - Optional. A table of Components. These are used to decorate
								the tabs.
]]
local function new (_, name, init_back, init_channels, init_tabloc, init_size,
						init_wrap, init_font, init_components)

	--[[
		Structure: New Chat
			A Compound composed of MiniConsoles and tabs that can be echoed to,
			displaying one MiniConsole at a time, with tabs to switch between the
			active MiniConsole.
	]]
	local new_chat = {}

	-- Object: background
	-- The background Frame that houses the Chat Compound.
	local background = init_back

	-- List: channel_list
	-- A string list of channel names. There will be one tab and MiniConsole
	-- per name.
	local channel_list = {}
	for _, c in ipairs( init_channels ) do
		channel_list[#channel_list+1] = c
	end

	-- List: mini_consoles
	-- The MiniConsoles managed by this Chat Compound.
	local mini_consoles = {}

	-- Number: size
	-- The size of the unmanaged portion of the tabs. If TabLocation is Top or
	-- Bottom, then this is height. Otherwise, width.
	local size = init_size or 0.05

	-- Number: font_size
	-- The font size of the MiniConsole text. Can be "dynamic" if word wrap is static.
	local font_size = init_font or 10

	-- Number: word_wrap
	-- The word wrap of the MiniConsole text. Can be "dynamic" if font size is static.
	local word_wrap = init_wrap or "dynamic"

	-- Variable: tab_location
	-- Determines on which side of the MiniConsoles the tabs will sit.
	local tab_location = init_tabloc or TabLocation.Top

	-- List: tabs
	-- The tab Frames managed by this Chat Compound.
	local tabs = Lib.OrderedTable()

	-- Object: tab_container
	-- A Frame that holds the tabs' Box Compound.
	local tab_container

	-- List: components
	-- A table of Components that all tabs will share.
	local components = init_components

	-- Object: active_background
	-- The default background color of the active tab. If a Background
	-- component exists in the components passed, it will override this.
	local active_background = Background( Brush( Color( ColorMode.RGB, 130, 130, 130 ) ) )

	-- Object: inactive_background
	-- The default background color of tabs when they're not the active tab.
	local inactive_background = Background( Brush( Color( ColorMode.RGB, 50, 50, 50 ) ) )

	-- Object: pending_background
	-- The default background color of a tab when there's a message waiting to be viewed.
	local pending_background = Background( Brush( Color( ColorMode.RGB, 200, 200, 200 ) ) )

	-- String: current_channel
	-- The channel currently active.
	local current_channel = channel_list["All"] or channel_list[1]

	-- List: pending_channels
	-- Channels with text to be viewed, waiting to be clicked on.
	local pending_channels = {}

	-- String: switch_func
	-- The name of the global function that will be used to switch MiniConsoles
	-- when the tab is clicked.
	local switch_func = name .. "ChatSwitch"
	-- Here we set up the parent->child hierarchy that makes the Chat Compound work.
	do
		local active_set = false
		for i, channel in ipairs( channel_list ) do
			local console_name 	= name .. channel .. "Console"
			local tab_name 		= name .. channel .. "Tab"
			if tab_location == TabLocation.Top then
				mini_consoles[channel] = MiniConsole( console_name,
					0, size, 1, (1.0 - size),
					word_wrap, font_size )
				background:Add( mini_consoles[channel] )

			elseif tab_location == TabLocation.Bottom then
				mini_consoles[channel] = MiniConsole( console_name,
					0, 0, 1, (1.0 - size),
					word_wrap, font_size )
				background:Add( mini_consoles[channel] )

			elseif tab_location == TabLocation.Right then
				mini_consoles[channel] = MiniConsole( console_name,
					size, 0, (1.0 - size), 1,
					word_wrap, font_size )
				background:Add( mini_consoles[channel] )
			else
				mini_consoles[channel] = MiniConsole( console_name,
					0, 0, (1.0 - size), 1,
					word_wrap, font_size )
				background:Add( mini_consoles[channel] )
			end

			tabs[channel] = Frame( tab_name )
			tabs[channel].Callback 				= switch_func
			tabs[channel].CallbackArguments 	= channel

			if components then
				for _, component in ipairs( components ) do
					tabs[channel]:Add( component )

					if not active_set then
						if component.Subtype == "Background" then
							active_background = component
							active_set = true
						end
					end
				end
			end
		end

		local tab_box
		local indexed_tabs = {}
		for i, name, tab in tabs() do
			indexed_tabs[i] = tab
		end
		local tab_cont_name = name .. "TabsBackground"
		local tab_box_name 	= name .. "TabsBox"
		if tab_location == TabLocation.Top then
			tab_container = Frame( tab_cont_name,
				0, 0, 1, size )

			tab_box = Box( tab_box_name, BoxMode.Horizontal, tab_container, indexed_tabs )
		elseif tab_location == TabLocation.Bottom then
			tab_container = Frame( tab_cont_name,
				0, (1.0 - size), 1, size )

			tab_box = Box( tab_box_name, BoxMode.Horizontal, tab_container, indexed_tabs )
		elseif tab_location == TabLocation.Right then
			tab_container = Frame( tab_cont_name,
				(1.0 - size), 0, size, 1 )

			tab_box = Box( tab_box_name, BoxMode.Vertical, tab_container, indexed_tabs )
		else
			tab_container = Frame( tab_cont_name,
				0, 0, size, 1 )

			tab_box = Box( tab_box_name, BoxMode.Vertical, tab_container, indexed_tabs )
		end

		for i, console in ipairs( mini_consoles ) do
			background:Add( console )
		end

		background:Add( tab_box )
	end

	--[[
		Properties: Chat Properties
			Name 				- Returns the Chat Compound's name.
			Background 			- Returns the background Frame of the Chat Compound.
			Container 			- Gets and sets the Chat Compound's parent Frame.
			Channels 			- Returns a copied list of the channels this Compound covers.
			TabSize 			- Gets and sets the size of the un-managed dimension
									of the tabs.
			FontSize 			- Gets and sets the size of the font in the MiniConsoles.
			WordWrap 			- Gets and sets the word wrap of the MiniConsoles.
			TabLocation 		- Gets and sets the location of the tabs surrouding the
									MiniConsoles.
			Components 			- Returns a copied list of the Compound's Tab's
									Components.
			ActiveBackground 	- Gets and sets the Background Component of the tab
									currently active.
			InactiveBackground 	- Gets and sets the Background Component of the tabs
									that are currently inactive.
			PendingBackground 	- Gets and sets the Background Component of any tabs
									with text waiting to be read.
			CurrentChannel 		- Returns the current channel of the Chat Compound.
			MiniConsoles 		- Returns a copied list of the MiniConsoles in the
									Compound.
			Tabs 				- Returns a copied list of the Tabs in the Compound.
	]]
	local properties = {
		Name = {
			get = function ()
				return name
			end,
		},
		Background = {
			get = function ()
				return background
			end,
		},
		Container = {
			get = function ()
				return background.Container
			end,
			set = function (value)
				background.Container = value
			end
		},
		Channels = {
			get = function ()
				local copy = {}
				for i, c in ipairs( channel_list ) do
					copy[i] = c
				end
				return copy
			end,
		},
		TabSize = {
			get = function ()
				return size
			end,
			set = function (value)
				size = value
				for i, name, tab in tabs() do
					if tab_location == TabLocation.Top or
							tab_location == TabLocation.Bottom then
						tab.Height = size
					else
						tab.Width = size
					end
				end
			end,
		},
		FontSize = {
			get = function ()
				return font_size
			end,
			set = function (value)
				font_size = value
				for name, console in pairs( mini_consoles ) do
					console.FontSize = font_size
				end
			end,
		},
		WordWrap = {
			get = function ()
				return word_wrap
			end,
			set = function (value)
				word_wrap = value
				for name, console in pairs( mini_consoles ) do
					console.WordWrap = word_wrap
				end
			end,
		},
		TabLocation = {
			get = function ()
				return tab_location
			end,
			set = function (value)
				tab_location = value
			end
		},
		Components = {
			get = function ()
				local copy = {}
				for i, c in ipairs( components ) do
					copy[i] = c
				end
				return copy
			end
		},
		ActiveBackground = {
			get = function ()
				return active_background
			end,
			set = function (value)
				active_background = value
			end
		},
		InactiveBackground = {
			get = function ()
				return inactive_background
			end,
			set = function (value)
				inactive_background = value
			end
		},
		PendingBackground = {
			get = function ()
				return pending_background
			end,
			set = function (value)
				pending_background = value
			end
		},
		CurrentChannel = {
			get = function ()
				return current_channel
			end
		},
		MiniConsoles = {
			get = function ()
				local copy = {}
				for i, m in ipairs( mini_consoles ) do
					copy[i] = m
				end
				return copy
			end
		},
		Tabs = {
			get = function ()
				local copy = {}
				for i, _, t in tabs() do
					copy[i] = t
				end
				return copy
			end
		},
	}

	--[[
		Function: Echo
			Echos any kind of text into a specific channel.

		Parameters:
			channel - The channel into which to echo.
			text 	- The text to be echoed.
	]]
	function new_chat:Echo (channel, text)
		if mini_consoles["All"] then
			mini_consoles["All"]:Echo( text )
		end
		if channel and channel ~= "All" then
			mini_consoles[channel]:Echo( text )

			if channel ~= current_channel and current_channel ~= "All" then
				if tabs[channel].Components["Background"] then
					tabs[channel]:Remove( "Background" )
				end
				tabs[channel]:Add( pending_background )
				pending_channels[channel] = true
			end
		end
	end

	--[[
		Function: Append
			Appends text to a channel from the buffer.

		Parameters:
			channel - The into which the text should be appended.
	]]
	function new_chat:Append (channel)
		if mini_consoles["All"] then
			mini_consoles["All"]:Append()
		end
		if channel and channel ~= "All" then
			mini_consoles[channel]:Append()

			if channel ~= current_channel and current_channel ~= "All" then
				if tabs[channel].Components["Background"] then
					tabs[channel]:Remove( "Background" )
				end
				tabs[channel]:Add( pending_background )
				pending_channels[channel] = true
			end
		end
	end

	--[[
		Function: Paste
			Pastes copy()'d text into a channel.

		Parameters:
			channel - The channel into which the text should be pasted.
	]]
	function new_chat:Paste (channel)
		if mini_consoles["All"] then
			mini_consoles["All"]:Paste()
		end
		if channel and channel ~= "All" then
			mini_consoles[channel]:Paste()

			if channel ~= current_channel and current_channel ~= "All" then
				if tabs[channel].Components["Background"] then
					tabs[channel]:Remove( "Background" )
				end
				tabs[channel]:Add( pending_background )
				pending_channels[channel] = true
			end
		end
	end

	--[[
		Function: Clear
			Removes all text from a channel.

		Parameters:
			channel - The channel to be cleared.
	]]
	function new_chat:Clear (channel)
		if channel and channel ~= "All" then
			mini_consoles[channel]:Clear()
		else
			for name, console in pairs( mini_consoles ) do
				console:Clear()
			end
		end
	end

	--[[
		Function: <name>ChatSwitch
			A dirty global function used as a callback for tabs. Vyzor creates
			one of these functions for each Chat Compound.

		Parameters:
			channel - The channel to be switched to.
	]]
	_G[switch_func] = function (channel)
		if channel == current_channel then
			return
		end
		for n, console in pairs( mini_consoles ) do
			if n == channel then
				console:Show()
			else
				console:Hide()
			end
		end

		for i, n, tab in tabs() do
			if n == channel then
				if tab.Components["Background"] then
					tab:Remove( "Background" )
				end
				tab:Add( active_background )

				if pending_channels[n] then
					pending_channels[n] = nil
				end
			else
				if not pending_channels[n] or channel == "All" then
					if tab.Components["Background"] then
						tab:Remove( "Background" )
					end
					tab:Add( inactive_background )
				end
			end
		end

		current_channel = channel
	end

	--[[
		Function: <name>InitializeChat
			A global function, registered as an event handler for
			the VyzorDrawnEvent. Makes sure the proper consoles
			are visible.

			Vyzor creates one of these for each Chat Compound.
	]]
	-- String: init_func
	-- The name of the global initialization function for this Chat Compound.
	local init_func = name .. "InitializeChat"
	_G[init_func] = function ()
		for n, console in pairs( mini_consoles ) do
			if n == current_channel then
				console:Show()
			else
				console:Hide()
			end
		end

		for i, n, tab in tabs() do
			tab:Echo( "<center>" .. n .. "</center>" )

			if n == current_channel then
				if tab.Components["Background"] then
					tab:Remove( "Background" )
				end
				tab:Add( active_background )
			else
				if tab.Components["Background"] then
					tab:Remove( "Background" )
				end
				tab:Add( inactive_background )
			end
		end
	end

	registerAnonymousEventHandler( "VyzorDrawnEvent", init_func )

	setmetatable( new_chat, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or Chat[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set( value )
			end
		end,
		} )
	return new_chat
end

setmetatable( Chat, {
	__index = getmetatable(Chat).__index,
	__call = new,
	} )
return Chat
