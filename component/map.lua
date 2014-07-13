-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require("vyzor.base")

--[[
    Class: Map
        Defines the Map Component.
]]
local Map = Base("Component", "Map")

--[[
    Constructor: new

    Parameters:
        initialX - Mapper's initial X coordinate.
        initialY - Mapper's initial Y coordinate.
        initialWidth - Mapper's initial Width.
        initialHeight - Mapper's initial Height.
]]
local function new (_, initialX, initialY, initialWidth, initialHeight)
    --[[
        Structure: New Map
            A container for Mudlet's built-in Map display.
    ]]
    local self = {}

    -- Object: _container
    -- Parent Frame.
    local _container

    -- Boolean: _isHidden
    -- Special handling for special Map hiding.
    local _isHidden = false

    -- Number: _x
    -- User-defined X coordinate.
    local _x = initialX or 0

    -- Number: _absoluteX
    -- Actual X coordinate.
    local _absoluteX

    -- Number: _y
    -- User-defined Y coordinate.
    local _y = initialY or 0

    -- Number: _absoluteY
    -- Actual Y coordinate.
    local _absoluteY

    -- Number: _width
    -- User-defined width.
    local _width = initialWidth or 1.0

    -- Number: _absoluteWidth
    -- Actual width.
    local _absoluteWidth

    -- Number: _height
    -- User-defined height.
    local _height = initialHeight or 1.0

    -- Number: _absoluteHeight
    -- Actual height.
    local _absoluteHeight

    --[[
        Properties: Map Properties
            Container - Gets and sets the Map's parent Frame.
            X - Gets and sets the user-defined X coordinate.
            AbsoluteX - Returns the actual X coordinate.
            Y - Gets and sets the user-defined Y coordinate.
            AbsoluteY - Returns the actual Y coordinate.
            Width - Gets and sets the user-defined width.
            AbsoluteWidth - Returns the actual width.
            Height - Gets and sets the user-defined height.
            AbsoluteHeight - Returns the actual height.
    ]]
    local properties = {
        Container = {
            get = function ()
                return _container
            end,
            set = function (value)
                if value.Type == "Frame" then
                    _container = value
                end
            end
        },

        X = {
            get = function ()
                return _x
            end,
            set = function (value)
                _x = value
                updateAbsolutes()
            end
        },

        AbsoluteX = {
            get = function ()
                return _absoluteX
            end
        },

        Y = {
            get = function ()
                return _y
            end,
            set = function (value)
                _y = value
                updateAbsolutes()
            end
        },

        AbsoluteY = {
            get = function ()
                return _absoluteY
            end
        },

        Width = {
            get = function ()
                return _width
            end,
            set = function (value)
                _width = value
                updateAbsolutes()
            end
        },

        AbsoluteWidth = {
            get = function ()
                return _absoluteWidth
            end
        },

        Height = {
            get = function ()
                return _height
            end,
            set = function (value)
                _height = value
                updateAbsolutes()
            end
        },

        AbsoluteHeight = {
            get = function ()
                return _absoluteHeight
            end
        }
    }

    --[[
        Function: updateAbsolutes
            Sets the actual size and position of the Map
            using the parent Frame's Content.
    ]]
    local function updateAbsolutes ()
        -- TODO: These are shared. Move to single location?
        local function calculateAbsolutePosition (axis, frameAxis, frameDimension)
            if axis >= 0.0 and axis <= 1.0 then
                return frameAxis + (axis * frameDimension)
            else
                return frameAxis + axis
            end
        end

        local function calculateAbsoluteDimension (dimension, frameDimension)
            if dimension >= 0.0 and dimension <= 1.0 then
                return dimension * frameDimension
            else
                return dimension
            end
        end

        if _container then
            _absoluteX = calculateAbsolutePosition(_x, _container.Position.ContentX, _container.Size.ContentWidth)
            _absoluteY = calculateAbsolutePosition(_y, _container.Position.ContentY, _container.Size.ContentHeight)

            _absoluteWidth = calculateAbsoluteDimension(_width, _container.Size.ContentWidth)
            _absoluteHeight = calculateAbsoluteDimension(_height, _container.Size.ContentHeight)
        end
    end

    --[[
        Function: Draw
            The map magically appears! Probably best used
            internally only.
    ]]
    function self:Draw ()
        updateAbsolutes()

        createMapper(_absoluteX, _absoluteY, _absoluteWidth, _absoluteHeight)
    end

    --[[
        Function: Resize
            Adjusts the Map's size.

        Parameters:
            width - Map's new width.
            height - Map's new height.
    ]]
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

    --[[
        Function: Move
            Moves the Map.

        Parameters:
            x - Map's new relative X coordinate.
            y - Map's new relative Y coordinate.
    ]]
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

    --[[
        Function: Hide
            Hides the Map. Sort of. Makes it very, very tiny.
    ]]
    function self:Hide ()
        _isHidden = true
        createMapper(_absoluteX, _absoluteY, 0, 0)
    end

    --[[
        Function: Show
            Returns the Map to its original size.
    ]]
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
