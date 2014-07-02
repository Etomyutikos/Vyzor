-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Background = require("vyzor.component.background")
local Base = require("vyzor.base")
local Box = require("vyzor.compound.box")
local BoxMode = require("vyzor.enum.box_mode")
local Brush = require("vyzor.component.brush")
local Color = require("vyzor.component.color")
local ColorMode = require("vyzor.enum.color_mode")
local Frame = require("vyzor.base.frame")
local Lib = require("vyzor.lib")
local MiniConsole = require("vyzor.component.mini_console")
local TabLocation = require("vyzor.enum.tab_location")

--[[
	Class: Chat
		Manages a number of MiniConsoles and tabs for a clean interface for text.
]]
local Chat = Base("Compound", "Chat")

--[[
	Constructor: new

	Parameters:
		_name - Name of the Chat Compound. Used to create unique event handler functions.
		initialBackground - The Background Frame for this Chat Compound.
		initialChannels - The names of the channels managed by this Compound. Passed as a table.
		initialTabLocation - Optional. A TabLocation Enum that determines on which side of the consoles the tabs sit. Default is top.
		initialSize - Optional. This is the size of the unmanaged portion of the tabs. Must be between 0.0 and 1.0. Default is 0.05.
		initialWordWrap - Optional. This is the word wrap of the MiniConsole text. Default is "dynamic".
		initialFont - Optional. This is the font size of the MiniConsole text. Default is 10. Can be "dynamic"
		initialComponents - Optional. A table of Components. These are used to decorate the tabs.
]]
local function new (_, _name, initialBackground, initialChannels, initialTabLocation, initialTabSize, initialWordWrap, initialFont, initialComponents)
	--[[
		Structure: New Chat
			A Compound composed of MiniConsoles and tabs that can be echoed to,
			displaying one MiniConsole at a time, with tabs to switch between the
			active MiniConsole.
	]]
	local self = {}

	-- Object: _background
	-- The background Frame that houses the Chat Compound.
	local _background = initialBackground

	-- List: _channelList
	-- A string list of channel names. There will be one tab and MiniConsole
	-- per name.
	local _channelList = {}
	for _, channel in ipairs(initialChannels) do
		_channelList[#_channelList + 1] = channel
	end

	-- List: _miniConsoles
	-- The MiniConsoles managed by this Chat Compound.
	local _miniConsoles = {}

	-- Number: _tabSize
	-- The size of the unmanaged portion of the tabs. If TabLocation is Top or
	-- Bottom, then this is height. Otherwise, width.
	local _tabSize = initialTabSize or 0.05

	-- Number: _fontSize
	-- The font size of the MiniConsole text. Can be "dynamic" if word wrap is static.
	local _fontSize = initialFont or 10

	-- Number: _wordWrap
	-- The word wrap of the MiniConsole text. Can be "dynamic" if font size is static.
	local _wordWrap = initialWordWrap or "dynamic"

	-- Variable: _tabLocation
	-- Determines on which side of the MiniConsoles the tabs will sit.
	local _tabLocation = initialTabLocation or TabLocation.Top

	-- List: _tabs
	-- The tab Frames managed by this Chat Compound.
	local _tabs = Lib.OrderedTable()

	-- Object: _tabContainer
	-- A Frame that holds the tabs' Box Compound.
	local _tabContainer

	-- List: _components
	-- A table of Components that all tabs will share.
	local _components = initialComponents

	-- Object: _activeBackground
	-- The default background color of the active tab. If a Background
	-- component exists in the components passed, it will override this.
	local _activeBackground = Background(Brush(Color(ColorMode.RGB, 130, 130, 130)))

	-- Object: _inactiveBackground
	-- The default background color of tabs when they're not the active tab.
	local _inactiveBackground = Background(Brush(Color(ColorMode.RGB, 50, 50, 50)))

	-- Object: _pendingBackground
	-- The default background color of a tab when there's a message waiting to be viewed.
	local _pendingBackground = Background(Brush(Color(ColorMode.RGB, 200, 200, 200)))

	-- String: _currentChannel
	-- The channel currently active.
	local _currentChannel = _channelList["All"] or _channelList[1]

	-- List: _pendingChannels
	-- Channels with text to be viewed, waiting to be clicked on.
	local _pendingChannels = {}

	-- String: _switchFunction
	-- The name of the global function that will be used to switch MiniConsoles
	-- when the tab is clicked.
	local _switchFunction = _name .. "ChatSwitch"

	-- Here we set up the parent->child hierarchy that makes the Chat Compound work.
	do
		local activeSet = false

		for _, channel in ipairs(_channelList) do
			local consoleName = _name .. channel .. "Console"
			local tabName = _name .. channel .. "Tab"

			if _tabLocation == TabLocation.Top then
				_miniConsoles[channel] = MiniConsole(consoleName,
					0, _tabSize, 1, (1.0 - _tabSize),
                    _wordWrap, _fontSize)

				_background:Add(_miniConsoles[channel])

			elseif _tabLocation == TabLocation.Bottom then
				_miniConsoles[channel] = MiniConsole(consoleName,
					0, 0, 1, (1.0 - _tabSize),
                    _wordWrap, _fontSize)

				_background:Add(_miniConsoles[channel])

			elseif _tabLocation == TabLocation.Left then
				_miniConsoles[channel] = MiniConsole(consoleName,
                    _tabSize, 0, (1.0 - _tabSize), 1,
                    _wordWrap, _fontSize)

				_background:Add(_miniConsoles[channel])

			else
				_miniConsoles[channel] = MiniConsole(consoleName,
					0, 0, (1.0 - _tabSize), 1,
                    _wordWrap, _fontSize)

				_background:Add(_miniConsoles[channel])
			end

			_tabs[channel] = Frame(tabName)
			_tabs[channel].Callback = _switchFunction
			_tabs[channel].CallbackArguments = channel

			if _components then
				for _, component in ipairs(_components) do
					_tabs[channel]:Add(component)

					if not activeSet then
						if component.Subtype == "Background" then
							_activeBackground = component
							activeSet = true
						end
					end
				end
			else
				_tabs[channel]:Add(_inactiveBackground)
			end
		end

		local tabBox
		local indexedTabs = {}

		for i, _, tab in _tabs() do
			indexedTabs[i] = tab
        end

		local tabContainerName = _name .. "TabsBackground"
		local tabBoxName = _name .. "TabsBox"

		if _tabLocation == TabLocation.Top then
			_tabContainer = Frame(tabContainerName,
				0, 0, 1, _tabSize)

			tabBox = Box(tabBoxName, BoxMode.Horizontal, _tabContainer, indexedTabs)
		elseif _tabLocation == TabLocation.Bottom then
			_tabContainer = Frame(tabContainerName,
				0, (1.0 - _tabSize), 1, _tabSize)

			tabBox = Box(tabBoxName, BoxMode.Horizontal, _tabContainer, indexedTabs)
		elseif _tabLocation == TabLocation.Right then
			_tabContainer = Frame(tabContainerName,
				(1.0 - _tabSize), 0, _tabSize, 1)

			tabBox = Box(tabBoxName, BoxMode.Vertical, _tabContainer, indexedTabs)
		else
			_tabContainer = Frame(tabContainerName,
				0, 0, _tabSize, 1)

			tabBox = Box(tabBoxName, BoxMode.Vertical, _tabContainer, indexedTabs)
		end

		for _, console in ipairs(_miniConsoles) do
			_background:Add(console)
		end

		_background:Add(tabBox)
	end

	--[[
		Properties: Chat Properties
			Name - Returns the Chat Compound's name.
			Background - Returns the background Frame of the Chat Compound.
			Container - Gets and sets the Chat Compound's parent Frame.
			Channels - Returns a copied list of the channels this Compound covers.
			TabSize - Gets and sets the size of the un-managed dimension of the tabs.
			FontSize - Gets and sets the size of the font in the MiniConsoles.
			WordWrap - Gets and sets the word wrap of the MiniConsoles.
			TabLocation - Gets and sets the location of the tabs surrouding the MiniConsoles.
			Components - Returns a copied list of the Compound's Tab's Components.
			ActiveBackground - Gets and sets the Background Component of the tab currently active.
			InactiveBackground - Gets and sets the Background Component of the tabs that are currently inactive.
			PendingBackground - Gets and sets the Background Component of any tabs with text waiting to be read.
			CurrentChannel - Returns the current channel of the Chat Compound.
			MiniConsoles - Returns a copied list of the MiniConsoles in the Compound.
			Tabs - Returns a copied list of the Tabs in the Compound.
	]]
	local properties = {
		Name = {
			get = function ()
				return _name
			end,
		},

		Background = {
			get = function ()
				return _background
			end,
		},

		Container = {
			get = function ()
				return _background.Container
			end,
			set = function (value)
				_background.Container = value
			end
		},

		Channels = {
			get = function ()
				local copy = {}

				for i, channel in ipairs(_channelList) do
					copy[i] = channel
                end

				return copy
			end,
		},

		TabSize = {
			get = function ()
				return _tabSize
			end,
			set = function (value)
				_tabSize = value

				for _, _, tab in _tabs() do
					if _tabLocation == TabLocation.Top or _tabLocation == TabLocation.Bottom then
						tab.Height = _tabSize
					else
						tab.Width = _tabSize
					end
				end
			end,
		},

		FontSize = {
			get = function ()
				return _fontSize
			end,
			set = function (value)
				_fontSize = value

				for _, console in pairs(_miniConsoles) do
					console.FontSize = _fontSize
				end
			end,
		},

		WordWrap = {
			get = function ()
				return _wordWrap
			end,
			set = function (value)
				_wordWrap = value

				for _, console in pairs(_miniConsoles) do
					console.WordWrap = _wordWrap
				end
			end,
		},

		TabLocation = {
			get = function ()
				return _tabLocation
			end,
			set = function (value)
				_tabLocation = value
			end
		},

		Components = {
			get = function ()
				local copy = {}

				for i, component in ipairs(_components) do
					copy[i] = component
                end

				return copy
			end
		},

		ActiveBackground = {
			get = function ()
				return _activeBackground
			end,
			set = function (value)
				_activeBackground = value
			end
		},

		InactiveBackground = {
			get = function ()
				return _inactiveBackground
			end,
			set = function (value)
				_inactiveBackground = value
			end
		},

		PendingBackground = {
			get = function ()
				return _pendingBackground
			end,
			set = function (value)
				_pendingBackground = value
			end
		},

		CurrentChannel = {
			get = function ()
				return _currentChannel
			end
		},

		MiniConsoles = {
			get = function ()
				local copy = {}
				local index = 1

				for _, miniConsole in pairs(_miniConsoles) do
					copy[index] = miniConsole
					index = index + 1
                end

				return copy
			end
		},

		Tabs = {
			get = function ()
				local copy = {}

				for i, _, tab in _tabs() do
					copy[i] = tab
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
			text - The text to be echoed.
	]]
	function self:Echo (channel, text)
		if _miniConsoles["All"] then
			_miniConsoles["All"]:Echo(text)
        end

		if channel and channel ~= "All" then
			_miniConsoles[channel]:Echo(text)

			if channel ~= _currentChannel and _currentChannel ~= "All" then
				if _tabs[channel].Components["Background"] then
					_tabs[channel]:Remove("Background")
                end

				_tabs[channel]:Add(_pendingBackground)
				_pendingChannels[channel] = true
			end
		end
	end

	--[[
		Function: Append
			Appends text to a channel from the buffer.

		Parameters:
			channel - The into which the text should be appended.
	]]
	function self:Append (channel)
		if _miniConsoles["All"] then
			_miniConsoles["All"]:Append()
        end

		if channel and channel ~= "All" then
			_miniConsoles[channel]:Append()

			if channel ~= _currentChannel and _currentChannel ~= "All" then
				if _tabs[channel].Components["Background"] then
					_tabs[channel]:Remove("Background")
                end

				_tabs[channel]:Add(_pendingBackground)
				_pendingChannels[channel] = true
			end
		end
	end

	--[[
		Function: Paste
			Pastes copy()'d text into a channel.

		Parameters:
			channel - The channel into which the text should be pasted.
	]]
	function self:Paste (channel)
		if _miniConsoles["All"] then
			_miniConsoles["All"]:Paste()
        end

		if channel and channel ~= "All" then
			_miniConsoles[channel]:Paste()

			if channel ~= _currentChannel and _currentChannel ~= "All" then
				if _tabs[channel].Components["Background"] then
					_tabs[channel]:Remove("Background")
                end

				_tabs[channel]:Add(_pendingBackground)
				_pendingChannels[channel] = true
			end
		end
	end

	--[[
		Function: Clear
			Removes all text from a channel.

		Parameters:
			channel - The channel to be cleared.
	]]
	function self:Clear (channel)
		if channel and channel ~= "All" then
			_miniConsoles[channel]:Clear()
		else
			for _, console in pairs(_miniConsoles) do
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
	_G[_switchFunction] = function (channel)
		if channel == _currentChannel then
			return
        end

		for name, console in pairs(_miniConsoles) do
			if name == channel then
				console:Show()
			else
				console:Hide()
			end
		end

		for _, name, tab in _tabs() do
			if name == channel then
				if tab.Components["Background"] then
					tab:Remove("Background")
                end

				tab:Add(_activeBackground)

				if _pendingChannels[name] then
					_pendingChannels[name] = nil
				end
			else
				if not _pendingChannels[name] or channel == "All" then
					if tab.Components["Background"] then
						tab:Remove("Background")
                    end

					tab:Add(_inactiveBackground)
				end
			end
		end

		_currentChannel = channel
	end

	--[[
		Function: <name>InitializeChat
			A global function, registered as an event handler for
			the VyzorDrawnEvent. Makes sure the proper consoles
			are visible.

			Vyzor creates one of these for each Chat Compound.
	]]
	-- String: _initializeFunction
	-- The name of the global initialization function for this Chat Compound.
	local _initializeFunction = _name .. "InitializeChat"

	_G[_initializeFunction] = function ()
		for name, console in pairs(_miniConsoles) do
			if name == _currentChannel then
				console:Show()
			else
				console:Hide()
			end
		end

		for _, name, tab in _tabs() do
			tab:Echo("<center>" .. name .. "</center>")

			if name == _currentChannel then
				if tab.Components["Background"] then
					tab:Remove("Background")
                end

				tab:Add(_activeBackground)
			else
				if tab.Components["Background"] then
					tab:Remove("Background")
                end
                
				tab:Add(_inactiveBackground)
			end
		end
	end

	registerAnonymousEventHandler("VyzorDrawnEvent", _initializeFunction)

	setmetatable(self, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or Chat[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set(value)
			end
		end,
		})
	return self
end

setmetatable(Chat, {
	__index = getmetatable(Chat).__index,
	__call = new,
	})
return Chat
