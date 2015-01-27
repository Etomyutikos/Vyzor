--- A Compound composed of @{MiniConsole}s and tabs that can be echoed to.
-- One @{MiniConsole} is displayed at a time. The tabs are used to switch the active @{MiniConsole}.
-- @classmod Chat

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

local Chat = Base("Compound", "Chat")

--- A dirty global function used as a callback for tabs.
-- Vyzor creates one of these functions for each Chat Compound.
--
-- Replace the underscore with the Chat Compound's name.
-- @function _ChatSwitch
-- @string channel The channel to be switched to.

--- A global function, registered as an event handler for the VyzorDrawnEvent.
-- Makes sure the proper consoles are visible.
--
-- Replace the underscore with the Chat Compound's name.
-- @function _InitializeChat

--- Chat constructor.
-- @function Chat
-- @string _name Name of the Chat Compound. Used to create unique event handler functions.
-- @tparam Frame initialBackground The Background @{Frame} for this Chat Compound.
-- @tparam table initialChannels The names of the channels managed by this Compound. Passed as a table.
-- @tparam[opt=TabLocation.Top] TabLocation initialTabLocation A @{TabLocation} @{Enum} that determines on which side of the consoles the tabs sit.
-- @number[opt=0.05] initialSize This is the size of the unmanaged portion of the tabs. Must be between 0.0 and 1.0.
-- @tparam[opt="dynamic"] number|string initialWordWrap This is the word wrap of the @{MiniConsole} text.
-- @tparam[opt=10] number|string initialFont This is the font size of the @{MiniConsole} text.
-- @tparam[opt] table initialComponents A table of Components. These are used to decorate the tabs.
-- @treturn Chat
local function new (_, _name, initialBackground, initialChannels, initialTabLocation, initialTabSize, initialWordWrap, initialFont, initialComponents)
	--- @type Chat
	local self = {}

	local _background = initialBackground

	local _channelList = {}
	for _, channel in ipairs(initialChannels) do
		_channelList[#_channelList + 1] = channel
	end

	local _miniConsoles = {}
	local _tabSize = initialTabSize or 0.05
	local _fontSize = initialFont or 10
	local _wordWrap = initialWordWrap or "dynamic"
	local _tabLocation = initialTabLocation or TabLocation.Top
	local _tabs = Lib.OrderedTable()
	local _tabContainer
	local _components = initialComponents
	local _activeBackground = Background(Brush(Color(ColorMode.RGB, 130, 130, 130)))
	local _inactiveBackground = Background(Brush(Color(ColorMode.RGB, 50, 50, 50)))
	local _pendingBackground = Background(Brush(Color(ColorMode.RGB, 200, 200, 200)))
	local _currentChannel = _channelList["All"] or _channelList[1]
	local _pendingChannels = {}

	local _switchFunction = _name .. "ChatSwitch"
  local _initializeFunction = _name .. "InitializeChat"

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

		for i, tab in _tabs:ipairs() do
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

  --- Properties
  --- @section
	local properties = {
		Name = {
			--- Returns the name of the Chat Compound.
			-- @function self.Name.get
			-- @treturn string
			get = function ()
				return _name
			end,
		},

		Background = {
			--- Returns the background @{Frame} of the Chat Compound.
			-- @function self.Background.get
			-- @treturn Frame
			get = function ()
				return _background
			end,
		},

		Container = {
			--- Returns the parent @{Frame} of the Chat Compound.
			-- @function self.Container.get
			-- @treturn Frame
			get = function ()
				return _background.Container
			end,

			--- Sets the parent @{Frame} of the Chat Compound.
			-- @function self.Container.set
			-- @tparam Frame value
			set = function (value)
				_background.Container = value
			end
		},

		Channels = {
			--- Returns the channels this Chat Compound manages.
			-- @function self.Channels.get
			-- @treturn table
			get = function ()
				local copy = {}

				for i, channel in ipairs(_channelList) do
					copy[i] = channel
        end

				return copy
			end,
		},

		TabSize = {
			--- Returns the size of the Chat Compound's tabs.
			-- @function self.TabSize.get
			-- @treturn number
			get = function ()
				return _tabSize
			end,

			--- Sets the size of the Chat Compound's tabs.
			-- @function self.TabSize.set
			-- @tparam number value
			set = function (value)
				_tabSize = value

				for tab in _tabs:each() do
					if _tabLocation == TabLocation.Top or _tabLocation == TabLocation.Bottom then
						tab.Height = _tabSize
					else
						tab.Width = _tabSize
					end
				end
			end,
		},

		FontSize = {
			--- Returns the font size of the Chat Compound's @{MiniConsole}s.
			-- @function self.FontSize.get
			-- @treturn number
			get = function ()
				return _fontSize
			end,

			--- Sets the font size of the Chat Compound's @{MiniConsole}s.
			-- @function self.FontSize.set
			-- @tparam number value
			set = function (value)
				_fontSize = value

				for _, console in pairs(_miniConsoles) do
					console.FontSize = _fontSize
				end
			end,
		},

		WordWrap = {
			--- Returns the word wrap of the Chat Compound's @{MiniConsole}s.
			-- @function self.WordWrap.get
			-- @treturn number
			get = function ()
				return _wordWrap
			end,

			--- Sets the word wrap of the Chat Compoound's @{MiniConsole}s.
			-- @function self.WordWrap.set
			-- @tparam number value
			set = function (value)
				_wordWrap = value

				for _, console in pairs(_miniConsoles) do
					console.WordWrap = _wordWrap
				end
			end,
		},

		TabLocation = {
			--- Returns the Chat Compound's @{TabLocation}.
			-- @function self.TabLocation.get
			-- @treturn TabLocation
			get = function ()
				return _tabLocation
			end,

			--- Sets the Chat Compound's @{TabLocation}.
			-- @function self.TabLocation.set
			-- @tparam TabLocation value
			set = function (value)
				_tabLocation = value
			end
		},

		Components = {
			--- Returns the Components used to decorate the Chat Compound's tabs.
			-- @function self.Components.get
			-- @treturn table
			get = function ()
				local copy = {}

				for i, component in ipairs(_components) do
					copy[i] = component
        end

				return copy
			end
		},

		ActiveBackground = {
			--- Returns the @{Background} used to style the active tab.
			-- @function self.ActiveBackground.get
			-- @treturn Background
			get = function ()
				return _activeBackground
			end,

			--- Sets the @{Background} used to style the active tab.
			-- @function self.ActiveBackground.set
			-- @tparam Background value
			set = function (value)
				_activeBackground = value
			end
		},

		InactiveBackground = {
			--- Returns the @{Background} used to style inactive tabs.
			-- @function self.InactiveBackgrounds.get
			-- @treturn Background
			get = function ()
				return _inactiveBackground
			end,

			--- Sets the @{Background} used to style style inactive tabs.
			-- @function self.InactiveBackground.set
			-- @tparam Background value
			set = function (value)
				_inactiveBackground = value
			end
		},

		PendingBackground = {
			--- Returns the @{Background} used to style a tab with new text.
			-- @function self.PendingBackground.get
			-- @treturn Background
			get = function ()
				return _pendingBackground
			end,

			--- Sets the @{Background} used to style a tab with new text.
			-- @function self.PendingBackground.set
			-- @tparam Background value
			set = function (value)
				_pendingBackground = value
			end
		},

		CurrentChannel = {
			--- Returns the channel of the active @{MiniConsole}.
			-- @function self.CurrentChannel.get
			-- @treturn string
			get = function ()
				return _currentChannel
			end
		},

		MiniConsoles = {
			--- Returns the @{MiniConsole}s the Chat Compound manages.
			-- @function self.MiniConsoles.get
			-- @treturn table
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
			--- Returns the tabs the Chat Compound manages.
			-- @function self.Tabs.get
			-- @treturn table
			get = function ()
				local copy = {}

				for i, tab in _tabs:ipairs() do
					copy[i] = tab
        end

				return copy
			end
		},
  }
  --- @section end

  --- Echos any kind of text into a specific channel.
  -- @string channel The channel into which to echo.
  -- @string text
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

  --- Appends text to a channel from the buffer.
  -- @string channel The channel into which the text should be appended.
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

  --- Pastes copy()'d text into a channel.
  -- @string channel The channel into which the text should be pasted.
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

  --- Removes all text from a channel.
  -- @string[opt="All"] channel The channel to be cleared.
	function self:Clear (channel)
		if channel and channel ~= "All" then
			_miniConsoles[channel]:Clear()
		else
			for _, console in pairs(_miniConsoles) do
				console:Clear()
			end
		end
	end

  -- Documented above.
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

		for name, tab in _tabs:pairs() do
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

  -- Documented above.
	_G[_initializeFunction] = function ()
		for name, console in pairs(_miniConsoles) do
			if name == _currentChannel then
				console:Show()
			else
				console:Hide()
			end
		end

		for name, tab in _tabs:pairs() do
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
