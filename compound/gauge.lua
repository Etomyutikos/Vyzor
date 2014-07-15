-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Background = require("vyzor.component.background")
local Base = require("vyzor.base")
local Brush = require("vyzor.component.brush")
local Color = require("vyzor.component.color")
local ColorMode = require("vyzor.enum.color_mode")
local Frame = require("vyzor.base.frame")
local GaugeFill = require("vyzor.enum.gauge_fill")
local Lib = require("vyzor.lib")

--[[
    Class: Gauge
        Defines a Gauge Compound.
]]
local Gauge = Base("Compound", "Gauge")

-- Array: master_list
-- A list of Gauges, used to update all Gauges.
local _MasterList = {}

--[[
    Function: VyzorGaugeUpdate
        A dirty global function to update all Vyzor Gauges.
]]
function VyzorGaugeUpdate ()
    for _, gauge in pairs(_MasterList) do
        gauge:Update()
    end
end

--[[
     Function: VyzorInitializeGauges
         Calls update on each Gauge after Vyzor has been drawn.
 ]]
function VyzorInitializeGauges()
    if #_MasterList > 0 then
        for _, gauge in ipairs(_MasterList) do
            gauge:Update()
        end
    end
end

--[[
    Function: getField
        Retrieves the value of the given index.

    Parameters:
        field - The index of the value to be retrieved.
]]
local function getField(field)
    local v = _G

    for w in string.gfind(field, "[%w_]+") do
        v = v[w]
    end

    return v
end

--[[
    Constructor: new

    Parameters:
        name - The name of the Gauge.
        initialCurrentValueAddress - The string address of the current stat to track.
        initialMaximumValueAddress - The string address of the current stat to track.
        initialBackground - The Background Frame.
        initialForeground - The Foreground Frame. Size and Position values will be overwritten.
        initialFillMode - GaugeFill Enum. Determines direction Gauge fills.
                        Defaults to LeftRight.
        initialOverflowFrames - Numerically indexed table of Frames to be used for overflow.
]]
local function new (_, _name, initialCurrentValueAddress, initialMaximumValueAddress, initialBackground, initialForeground, initialFillMode, initialOverflowFrames)
    assert(initialCurrentValueAddress and initialMaximumValueAddress, "Vyzor: A new Gauge must have both current and maximum addresses to track.")

    --[[
        Structure: New Gauge
            A lightweight container for Frames that will function as
            a dynamically resized bar.
    ]]
    local self = {}

    -- String: _currentValueAddress
    -- Index of current variable.
    local _currentValueAddress = initialCurrentValueAddress

    -- Number: _currentValue
    -- Numeric value of current variable.
    local _currentValue

    -- String: _maximumValueAddress
    -- Index of maximum variable.
    local _maximumValueAddress = initialMaximumValueAddress

    -- Number: _maximumValue
    -- Numeric value of maximum stat.
    local _maximumValue

    -- Object: _backgroundFrame
    -- Frame serving as Gauge's background.
    local _backgroundFrame = initialBackground

    -- Object: _foregroundFrame
    -- Frame serving as Gauge's foreground.
    local _foregroundFrame = initialForeground

    -- Array: _overflowFrames
    -- Contains the Gauge's overflow frames.
    local _overflowFrames = Lib.OrderedTable()

    if initialOverflowFrames and type(initialOverflowFrames) == "table" then
        for _, frame in ipairs(initialOverflowFrames) do
            _overflowFrames[frame.Name] = frame
        end
    end

    -- Object: _captionFrame
    -- Generated frame that can be echoed to.
    local _captionFrame = Frame(_name .. "_caption")
    _captionFrame:Add(
        Background(
            Brush(
                Color(ColorMode.RGBA, 0, 0, 0, 0)
          )
      )
  )

    -- Boolean: _autoEcho
    -- Should this Gauge echo every update?
    local _autoEcho = true

    -- String: _textFormat
    -- Format used when auto_echo is true.
    local _textFormat = "<center>%s / %s</center>"

    -- The foreground is a child of the background. Let's do that.
    _backgroundFrame:Add(_foregroundFrame)

    if _overflowFrames:count() > 0 then
        for frame in _overflowFrames:each() do
            _backgroundFrame:Add(frame)
        end
    end

    _backgroundFrame:Add(_captionFrame)

    -- Object: _fillMode
    -- Determines direction Gauge fills.
    local _fillMode = initialFillMode or GaugeFill.LeftRight

    --[[
        Properties: Gauge Properties
            Name - Returns the Gauge's name.
            Container - Gets and sets the Gauge's container.
            CurrentAddress - Gets and sets the Gauge's current variable index.
            Current - Returns the numeric value of the current variable.
            MaximumAddress - Gets and sets the Gauge's maximum variable index.
            Maximum - Returns the numeric value of the maximum variable.
            Background - Returns the Gauge's Background Frame.
            Foreground - Returns the Gauge's Foreground Frame.
            FillMode - Gets and sets the Gauge's fill direction.
            AutoEcho - Gets and sets the Gauge's <auto_echo> property.
            TextFormat - Gets and sets the format used by <auto_echo>. Must be compatible with string.format.
            Overflow - Returns a copy of the Gauge's overflow Frames.
    ]]
    local properties = {
        Name = {
            get = function ()
                return _name
            end
        },

        Container = {
            get = function ()
                return _backgroundFrame.Container
            end,
            set = function (value)
                _backgroundFrame.Container = value
            end
        },

        CurrentAddress = {
            get = function ()
                return _currentValueAddress
            end,
            set = function (value)
                _currentValueAddress = value
            end
        },

        Current = {
            get = function ()
                return _currentValue
            end
        },

        MaximumAddress = {
            get = function ()
                return _maximumValueAddress
            end,
            set = function (value)
                _maximumValueAddress = value
            end
        },

        Maximum = {
            get = function ()
                return _maximumValue
            end
        },

        Background = {
            get = function ()
                return _backgroundFrame
            end
        },

        Foreground = {
            get = function ()
                return _foregroundFrame
            end
        },

        AutoEcho = {
            get = function ()
                return _autoEcho
            end,
            set = function (value)
                _autoEcho = value
            end,
        },

        TextFormat = {
            get = function ()
                return _textFormat
            end,
            set = function (value)
                _textFormat = value
            end,
        },

        Overflow = {
            get = function ()
                local copy = {}
                for k, v in _overflowFrames:pairs() do
                    copy[k] = v
                end
                return copy
            end
        },
    }

    local function getOverflowScalars(currentScalar)
        local scalar = currentScalar - 1
        local overflowScalars = {}

        if _overflowFrames:count() > 0 then
            local i = 1

            while scalar > 1 do
                overflowScalars[i] = 1
                scalar = scalar - 1
                i = i + 1
            end

            overflowScalars[i] = scalar
        end

        return overflowScalars
    end

    local function fillLeftRight (scalar, overflowScalars)
        _foregroundFrame.Size.Width = scalar

        if _overflowFrames:count() > 0 then
            for frame in _overflowFrames:each() do
                frame:Hide()
            end
        end

        if #overflowScalars > 0 then
            for index, frame in _overflowFrames:ipairs() do
                local overage = overflowScalars[index]

                if overage then
                    frame:Show()
                    frame.Size.Width = overage
                end
            end
        end
    end

    local function fillRightLeft (scalar, overflowScalars)
        _foregroundFrame.Size.Width = scalar
        _foregroundFrame.Position.X = 1.0 - scalar

        if #overflowScalars > 0 then
            for index, frame in _overflowFrames:ipairs() do
                local overage = overflowScalars[index]

                if overage then
                    frame:Show()
                    frame.Size.Width = overflowScalars[index]
                    frame.Position.X = 1.0 - overflowScalars[index]
                end
            end
        end
    end

    local function fillTopBottom (scalar, overflowScalars)
        _foregroundFrame.Size.Height = scalar

        if #overflowScalars > 0 then
            for index, frame in _overflowFrames:ipairs() do
                local overage = overflowScalars[index]

                if overage then
                    frame:Show()
                    frame.Size.Height = overflowScalars[index]
                end
            end
        end
    end

    local function fillBottomTop (scalar, overflowScalars)
        _foregroundFrame.Size.Height = scalar
        _foregroundFrame.Position.Y = 1.0 - scalar

        if #overflowScalars > 0 then
            for index, frame in _overflowFrames:ipairs() do
                frame.Size.Height = overflowScalars[index] or 0
                frame.Position.Y = 1.0 - overflowScalars[index] or 0
            end
        end
    end

    local function fillGauge (scalar, overflowScalars)
        if _fillMode == GaugeFill.LeftRight then
            fillLeftRight(scalar, overflowScalars)
        elseif _fillMode == GaugeFill.RightLeft then
            fillRightLeft(scalar, overflowScalars)
        elseif _fillMode == GaugeFill.TopBottom then
            fillTopBottom(scalar, overflowScalars)
        elseif _fillMode == GaugeFill.BottomTop then
            fillBottomTop(scalar, overflowScalars)
        end
    end

    --[[
        Function: Update
            Updates the Gauge.
    ]]
    function self:Update ()
        _currentValue = getField(_currentValueAddress) or 1
        _maximumValue = getField(_maximumValueAddress) or 1

        local scalar = _currentValue / _maximumValue

        local overflowScalars = {}
        if scalar > 1 then
            overflowScalars = getOverflowScalars(scalar)
            scalar = 1
        end

        fillGauge(scalar, overflowScalars)

        _foregroundFrame:Resize()
        _foregroundFrame:Move()

        if _overflowFrames:count() > 0 then
            for frame in _overflowFrames:each() do
                frame:Resize()
                frame:Move()
            end
        end

        if _autoEcho then
            self:Echo()
        end
    end

    --[[
        Function: Echo
            Displays text on the auto-generated caption
            Frame.

        Parameters:
            text - The text to be displayed.
    ]]
    function self:Echo (text)
        if text then
            echo(_captionFrame.Name, text)
        else
            echo(_captionFrame.Name, string.format(_textFormat, _currentValue, _maximumValue))
        end
    end

    registerAnonymousEventHandler("VyzorDrawnEvent", "VyzorInitializeGauges")

    setmetatable(self, {
        __index = function (_, key)
            return (properties[key] and properties[key].get()) or Gauge[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end,
        })

    _MasterList[#_MasterList +1] = self
    return self
end

setmetatable(Gauge, {
    __index = getmetatable(Gauge).__index,
    __call = new,
    })
return Gauge
