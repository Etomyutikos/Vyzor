-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require("vyzor.base")
local BoundingMode = require("vyzor.enum.bounding_mode")

--[[
    Class: Position
        Defines a Position Supercomponent.
]]
local Position = Base("Supercomponent", "Position")

local function calculateAbsoluteCoordinate(rawAxis, containerAxis, dimension)
    if rawAxis > 1 then
        return containerAxis + rawAxis
    elseif rawAxis > 0 then
        return containerAxis + (dimension * rawAxis)
    elseif rawAxis < 0 then
        return containerAxis + (dimension + rawAxis)
    else
        return containerAxis
    end
end

local function setBoundedCoordinate(absoluteAxis, minimum, maximum, dimension)
    if absoluteAxis < minimum then
        return minimum
    elseif (absoluteAxis + dimension) > maximum then
        return maximum - dimension
    else
        return absoluteAxis
    end
end

--[[
    Constructor: new

    Parameters:
        _frame - The <Frame> to which this Supercomponent belongs.
        initialX - The initial x coordinate position.
        initialY - The initial y coordinate position.
        _isFirst - Determines whether or not the parent <Frame> is the <HUD>.

    Returns:
        A new Position Supercomponent.
]]
local function new (_, _frame, initialX, initialY, _isFirst)
    --[[
        Structure: New Position
            A Supercomponent, for use only with <Frames>.
            Responsible for managing the coordinate
            positioning of the <Frame> within its parent.
            This is only used internally. Not to be exposed.
    ]]
    local self = {}

    -- Array: _coordinates
    -- Contains the <Frame's> user-defined coordinates.
    local _coordinates = {
        X = (initialX or 0),
        Y = (initialY or 0),
    }

    -- Array: _absoluteCoordinates
    -- Contains the <Frame's> generated, window coordinates.
    local _absoluteCoordinates = {}

    -- Array: _contentCoordinates
    -- Contains the <Frame's> generated, Content Rectangle coordinates.
    local _contentCoordinates = {}

    local function updateContent()
        -- In order to respect the QT Box Model, we have to determine the
        -- actual position of the Content Rectangle. All child Frames
        -- are placed using the Content Rectangle, not the Absolute Rectangle.
        -- See: http://doc.qt.nokia.com/4.7-snapshot/stylesheet-customizing.html
        local x = 0
        local y = 0

        if _frame.Components then
            local border = _frame.Components["Border"]
            if border then
                if border.Top then
                    x = x + border.Left.Width
                    y = y + border.Top.Width
                else
                    if type(border.Width) == "table" then
                        x = x + border.Width[4]
                        y = y + border.Width[1]
                    else
                        x = x + border.Width
                        y = y + border.Width
                    end
                end
            end

            local margin = _frame.Components["Margin"]
            if margin then
                x = x + margin.Left
                y = y + margin.Top
            end

            local padding = _frame.Components["Padding"]
            if padding then
                x = x + padding.Left
                y = y + padding.Top
            end
        end

        _contentCoordinates = {
            X = _absoluteCoordinates.X + x,
            Y = _absoluteCoordinates.Y + y
        }
    end

    --[[
        Function: updateAbsolute
            Generates the absolute coordinates (<abs_coords>) of
            the <Frame>.
            Also used to generate the content coordinates (<content_coords>).
    ]]
    local function updateAbsolutes()
        -- The HUD.
        if _isFirst then
            _absoluteCoordinates = _coordinates
            _contentCoordinates = _coordinates
            return
        end

        assert(_frame.Container, "Vyzor: Frame must have container before Position can be determined.")

        local container = _frame.Container
        local containerPosition = container.Position.Content
        local containerSize = container.Size.Content

        _absoluteCoordinates.X = calculateAbsoluteCoordinate(_coordinates.X, containerPosition.X, containerSize.Width)
        _absoluteCoordinates.Y = calculateAbsoluteCoordinate(_coordinates.Y, containerPosition.Y, containerSize.Height)

        if container.IsBounding and _frame.BoundingMode == BoundingMode.Position then
            _absoluteCoordinates.X = setBoundedCoordinate(
                _absoluteCoordinates.X,
                containerPosition.X,
                containerPosition.X + containerSize.Width,
                _frame.Size.AbsoluteWidth)

            _absoluteCoordinates.Y = setBoundedCoordinate(
                _absoluteCoordinates.Y,
                containerPosition.Y,
                containerPosition.Y + containerSize.Height,
                _frame.Size.AbsoluteHeight)
        end

        updateContent()
    end

    --[[
        Properties: Position Properties
            Coordinates - Gets and sets the relative (user-defined) coordinates (<coords>) of the <Frame>.
            Absolute - Returns the coordinates of the <Frame> within the Mudlet window (<abs_coords>).
            Content - Returns the coordinates of the Content Rectangle within the Mudlet window (<content_coords>).
            X - Gets and sets the relative (user-defined) x value of the Frame.
            Y - Gets and sets the relative (user-defined) y value of the Frame.
            AbsoluteX - Returns the X value of the Frame within the Mudlet window.
            AbsoluteY - Returns the Y value of the Frame within the Mudlet window.
            ContentX - Returns the X value of the Content Rectangle within the Mudlet window.
            ContentY - Returns the Y value of the Content Rectangle within the Mudlet window.
    ]]
    local properties = {
        Coordinates = {
            get = function ()
                local copy = {}

                for index in pairs(_coordinates) do
                    copy[index] = _coordinates[index]
                end

                return copy
            end,
            set = function (value)
                _coordinates.X = value.X or value[1]
                _coordinates.Y = value.Y or value[2]
                updateAbsolutes()
            end
        },

        Absolute = {
            get = function ()
                if not _absoluteCoordinates.X or not _absoluteCoordinates.Y then
                    updateAbsolutes()
                end

                local copy = {}

                for index in pairs(_absoluteCoordinates) do
                    copy[index] = _absoluteCoordinates[index]
                end

                return copy
            end
        },

        Content = {
            get = function ()
                if not _contentCoordinates.X or not _contentCoordinates.Y then
                    updateAbsolutes()
                end

                local copy = {}

                for i in pairs(_contentCoordinates) do
                    copy[i] = _contentCoordinates[i]
                end

                return copy
            end
        },

        X = {
            get = function ()
                return _coordinates.X
            end,
            set = function (value)
                _coordinates.X = value

                if _frame.Container.IsDrawn then
                    updateAbsolutes()
                end
            end
        },

        Y = {
            get = function ()
                return _coordinates.Y
            end,
            set = function (value)
                _coordinates.Y = value

                if _frame.Container.IsDrawn then
                    updateAbsolutes()
                end
            end
        },

        AbsoluteX = {
            get = function ()
                if not _absoluteCoordinates.X then
                    updateAbsolutes()
                end
                return _absoluteCoordinates.X
            end
        },
        AbsoluteY = {
            get = function ()
                if not _absoluteCoordinates.Y then
                    updateAbsolutes()
                end

                return _absoluteCoordinates.Y
            end
        },

        ContentX = {
            get = function ()
                if not _contentCoordinates.X then
                    updateAbsolutes()
                end

                return _contentCoordinates.X
            end
        },

        ContentY = {
            get = function ()
                if not _contentCoordinates.Y then
                    updateAbsolutes()
                end

                return _contentCoordinates.Y
            end
        },
    }

    setmetatable(self, {
        __index = function (_, key)
            return (properties[key] and properties[key].get()) or Position[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end,
    })

    return self
end

setmetatable(Position, {
    __index = getmetatable(Position).__index,
    __call = new,
})

return Position
