--- A container for Mudlet's built-in Map display.
-- @classmod Map

local Base = require("vyzor.base")

local Map = Base("Component", "Map")

local function calculateAbsolutePosition(axisValue, frameAxis, frameDimension)
    if axisValue >= 0.0 and axisValue <= 1.0 then
        return frameAxis + (axisValue * frameDimension)
    else
        return frameAxis + axisValue
    end
end

local function calculateAbsoluteDimension(dimension, frameDimension)
    if dimension >= 0.0 and dimension <= 1.0 then
        return dimension * frameDimension
    else
        return dimension
    end
end

--- Map constructor.
-- @function Map
-- @number[opt=0] initialX The Map's initial X coordinate.
-- @number[opt=0] initialY The Map's initial Y coordinate.
-- @number[opt=1.0] initialWidth The Map's initial Width.
-- @number[opt=1.0] initialHeight The Map's initial Height.
-- @treturn Map
local function new (_, initialX, initialY, initialWidth, initialHeight)
    --- @type Map
    local self = {}

    local _container
    local _isHidden = false
    local _x = initialX or 0
    local _absoluteX
    local _y = initialY or 0
    local _absoluteY
    local _width = initialWidth or 1.0
    local _absoluteWidth
    local _height = initialHeight or 1.0
    local _absoluteHeight

    --- Properties
    --- @section
    local properties = {
        Container = {
            --- Returns the Map's parent @{Frame}.
            --- @function self.Container.get
            --- @treturn Frame
            get = function ()
                return _container
            end,

            --- Sets the Map's parent @{Frame}.
            --- @function self.Container.set
            --- @tparam Frame value
            set = function (value)
                if value.Type == "Frame" then
                    _container = value
                end
            end
        },

        X = {
            --- Returns the Map's user-defined X coordinate.
            --- @function self.X.get
            --- @treturn number
            get = function ()
                return _x
            end,

            --- Sets the Map's user-defined X coordinate.
            --- @function self.X.set
            --- @tparam number value
            set = function (value)
                _x = value
                updateAbsolutes()
            end
        },

        AbsoluteX = {
            --- Returns the Map's actual X coordinate.
            --- @function self.AbsoluteX.get
            --- @treturn number
            get = function ()
                return _absoluteX
            end
        },

        Y = {
            --- Returns the Map's user-defined Y coordinate.
            --- @function self.Y.get
            --- @treturn number
            get = function ()
                return _y
            end,

            --- Sets the Map's user-defined Y coordinate.
            --- @function self.Y.set
            --- @tparam number value
            set = function (value)
                _y = value
                updateAbsolutes()
            end
        },

        AbsoluteY = {
            --- Returns the Map's actual Y coordinate.
            --- @function self.AbsoluteY.get
            --- @treturn number
            get = function ()
                return _absoluteY
            end
        },

        Width = {
            --- Returns the Map's user-defined width.
            --- @function self.Width.get
            --- @treturn number
            get = function ()
                return _width
            end,

            --- Sets the Map's user-defined width.
            --- @function self.Width.set
            --- @tparam number value
            set = function (value)
                _width = value
                updateAbsolutes()
            end
        },

        AbsoluteWidth = {
            --- Returns the Map's actual width.
            --- @function self.AbsoluteWidth.get
            --- @treturn number
            get = function ()
                return _absoluteWidth
            end
        },

        Height = {
            --- Returns the Map's user-defined height.
            --- @function self.Height.get
            --- @treturn number
            get = function ()
                return _height
            end,

            --- Sets the Map's user-defined height.
            --- @function self.Height.set
            --- @tparam number value
            set = function (value)
                _height = value
                updateAbsolutes()
            end
        },

        AbsoluteHeight = {
            --- Returns the Map's actual height.
            --- @function self.AbsoluteHeight.get
            --- @treturn number
            get = function ()
                return _absoluteHeight
            end
        }
    }
    --- @section end

    local function updateAbsolutes ()
        if _container then
            _absoluteX = calculateAbsolutePosition(_x, _container.Position.ContentX, _container.Size.ContentWidth)
            _absoluteY = calculateAbsolutePosition(_y, _container.Position.ContentY, _container.Size.ContentHeight)

            _absoluteWidth = calculateAbsoluteDimension(_width, _container.Size.ContentWidth)
            _absoluteHeight = calculateAbsoluteDimension(_height, _container.Size.ContentHeight)
        end
    end

    --- The map magically appears!
    ---
    --- Best used internally only.
    function self:Draw ()
        updateAbsolutes()

        createMapper(_absoluteX, _absoluteY, _absoluteWidth, _absoluteHeight)
    end

    --- Adjusts the Map's size.
    --- @number[opt] width Map's new width.
    --- @number[opt] height Map's new height.
    function self:Resize (width, height)
        _width = width or _width
        _height = height or _height

        updateAbsolutes()

        if not _isHidden then
            createMapper(_absoluteX, _absoluteY, _absoluteWidth, _absoluteHeight)
        else
            createMapper(_absoluteX, _absoluteY, 0, 0)
        end
    end

    --- Moves the Map.
    --- @number x Map's new relative X coordinate.
    --- @number y Map's new relative Y coordinate.
    function self:Move (x, y)
        _x = x or _x
        _y = y or _y

        updateAbsolutes()

        if not _isHidden then
            createMapper(_absoluteX, _absoluteY, _absoluteWidth, _absoluteHeight)
        else
            createMapper(_absoluteX, _absoluteY, 0, 0)
        end
    end

    --- Hides the Map.
    ---
    --- Technically, it makes the Map very, very tiny.
    function self:Hide ()
        _isHidden = true
        createMapper(_absoluteX, _absoluteY, 0, 0)
    end

    --- Returns the Map to its original size.
    function self:Show ()
        _isHidden = false
        createMapper(_absoluteX, _absoluteY, _absoluteWidth, _absoluteHeight)
    end

    setmetatable(self, {
        __index = function (_, key)
            return (properties[key] and properties[key].get()) or Map[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end,
    })

    return self
end

setmetatable(Map, {
    __index = getmetatable(Map).__index,
    __call = new,
})

return Map
