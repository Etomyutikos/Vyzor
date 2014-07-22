--- A lightweight container for @{Frame}s that will function as a dynamically resized bar.
--- @classmod Gauge

local Background = require("vyzor.component.background")
local Base = require("vyzor.base")
local Brush = require("vyzor.component.brush")
local Color = require("vyzor.component.color")
local ColorMode = require("vyzor.enum.color_mode")
local Frame = require("vyzor.base.frame")
local GaugeFill = require("vyzor.enum.gauge_fill")
local Lib = require("vyzor.lib")

local Gauge = Base("Compound", "Gauge")

local _MasterList = {}

--- A dirty global function to update all Vyzor Gauges.
function VyzorGaugeUpdate ()
    for _, gauge in pairs(_MasterList) do
        gauge:Update()
    end
end

--- Calls update on each Gauge after Vyzor has been drawn.
function VyzorInitializeGauges()
    if #_MasterList > 0 then
        for _, gauge in ipairs(_MasterList) do
            gauge:Update()
        end
    end
end

local function getField(field)
    local v = _G

    for w in string.gfind(field, "[%w_]+") do
        v = v[w]
    end

    return v
end

--- Gauge constructor.
--- @function Gauge
--- @string name The name of the Gauge.
--- @string initialCurrentValueAddress The string address of the current stat to track.
--- @string initialMaximumValueAddress The string address of the current stat to track.
--- @tparam Frame initialBackground The Background @{Frame}.
--- @tparam Frame initialForeground The Foreground @{Frame}. @{Size} and @{Position} values will be overwritten.
--- @tparam[opt=GaugeFill.LeftRight] GaugeFill initialFillMode Determines direction Gauge fills.
--- @tparam[opt] table initialOverflowFrames Numerically indexed table of @{Frame}s to be used for overflow.
--- @treturn Gauge
local function new (_, _name, initialCurrentValueAddress, initialMaximumValueAddress, initialBackground, initialForeground, initialFillMode, initialOverflowFrames)
    assert(initialCurrentValueAddress and initialMaximumValueAddress, "Vyzor: A new Gauge must have both current and maximum addresses to track.")

    --- @type Gauge
    local self = {}

    local _currentValueAddress = initialCurrentValueAddress
    local _currentValue

    local _maximumValueAddress = initialMaximumValueAddress
    local _maximumValue

    local _backgroundFrame = initialBackground
    local _foregroundFrame = initialForeground
    local _overflowFrames = Lib.OrderedTable()

    if initialOverflowFrames and type(initialOverflowFrames) == "table" then
        for _, frame in ipairs(initialOverflowFrames) do
            _overflowFrames[frame.Name] = frame
        end
    end

    local _captionFrame = Frame(_name .. "_caption")
    _captionFrame:Add(
        Background(
            Brush(
                Color(ColorMode.RGBA, 0, 0, 0, 0)
            )
        )
    )

    local _autoEcho = true
    local _textFormat = "<center>%s / %s</center>"

    _backgroundFrame:Add(_foregroundFrame)

    if _overflowFrames:count() > 0 then
        for frame in _overflowFrames:each() do
            _backgroundFrame:Add(frame)
        end
    end

    _backgroundFrame:Add(_captionFrame)

    local _fillMode = initialFillMode or GaugeFill.LeftRight

    --- Properties
    --- @section
    local properties = {
        Name = {
            --- Returns the name of the Gauge.
            --- @function self.Name.get
            --- @treturn string
            get = function ()
                return _name
            end
        },

        Container = {
            --- Returns the Gauge's parent @{Frame}.
            --- @function self.Container.get
            --- @treturn Frame
            get = function ()
                return _backgroundFrame.Container
            end,

            --- Sets the Gauge's parent @{Frame}.
            --- @function self.Container.set
            --- @tparam Frame value
            set = function (value)
                _backgroundFrame.Container = value
            end
        },

        CurrentAddress = {
            --- Returns the address of the Gauge's current value variable.
            --- @function self.CurrentAddress.get
            --- @treturn string
            get = function ()
                return _currentValueAddress
            end,

            --- Sets the address of the Gauge's current value variable.
            --- @function self.CurrentAddress.set
            --- @tparam string value
            set = function (value)
                _currentValueAddress = value
            end
        },

        Current = {
            --- Returns the Gauge's current value.
            --- @function self.Current.get
            --- @treturn number
            get = function ()
                return _currentValue
            end
        },

        MaximumAddress = {
            --- Returns the address of the Gauge's maximum value variable.
            --- @function self.MaximumAddress.get
            --- @treturn string
            get = function ()
                return _maximumValueAddress
            end,

            --- Sets the address of the Gauge's maximum value variable.
            --- @function self.MaximumAddress.set
            --- @tparam string value
            set = function (value)
                _maximumValueAddress = value
            end
        },

        Maximum = {
            --- Returns the Gauge's maximum value.
            --- @function self.Maximum.get
            --- @treturn number
            get = function ()
                return _maximumValue
            end
        },

        Background = {
            --- Returns the background @{Frame} of the Gauge.
            --- @function self.Background.get
            --- @treturn Frame
            get = function ()
                return _backgroundFrame
            end
        },

        Foreground = {
            --- Returns the foreground @{Frame} of the Gauge.
            --- @function self.Foreground.get
            --- @treturn Frame
            get = function ()
                return _foregroundFrame
            end
        },

        AutoEcho = {
            --- Returns a flag determining whether or not the Gauge automatically echoes text on every update.
            --- @function self.AutoEcho.get
            --- @treturn bool
            get = function ()
                return _autoEcho
            end,

            --- Sets a flag determining whether or not the Gauge automatically echoes text on every update.
            --- @function self.AutoEcho.set
            --- @tparam bool value
            set = function (value)
                _autoEcho = value
            end,
        },

        TextFormat = {
            --- Returns the text passed to string.format if AutoEcho is true.
            --- @function self.TextFormat.get
            --- @treturn string
            get = function ()
                return _textFormat
            end,

            --- Sets the text passed to string.format if AutoEcho is true.
            --- @function self.TextFormat.set
            --- @tparam string value
            set = function (value)
                _textFormat = value
            end,
        },

        Overflow = {
            --- Returns the overflow @{Frame}s of the Gauge.
            --- @function self.Overflow.get
            --- @treturn table
            get = function ()
                local copy = {}
                for k, v in _overflowFrames:pairs() do
                    copy[k] = v
                end
                return copy
            end
        },
    }
    --- @section end

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

    --- Updates the Gauge.
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

    --- Displays text on the auto-generated caption @{Frame}.
    --- @param text
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
