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

    --[[
        Function: updateAbsolute
            Generates the absolute coordinates (<abs_coords>) of
            the <Frame>.
            Also used to generate the content coordinates (<content_coords>).
    ]]
    local function updateAbsolute () -- TODO: Break this up.
        -- The HUD.
        if _isFirst then
            _absoluteCoordinates = _coordinates
            _contentCoordinates = _coordinates
            return
        end

        local frameContainer = _frame.Container
        assert(frameContainer, "Vyzor: Frame must have container before Position can be determined.")

        local containerPosition = frameContainer.Position.Content
        local containerSize = frameContainer.Size.Content

        -- We convert the size table from width/height to X/Y so we can
        -- use it in our loop below.
        local sizeTable = { -- TODO: This seems like a hack.
            X = containerSize.Width,
            Y = containerSize.Height,
        }

        for axis, value in pairs(_coordinates) do
            if value > 1 then
                _absoluteCoordinates[axis] = containerPosition[axis] + value
            elseif value > 0 then
                _absoluteCoordinates[axis] = containerPosition[axis] + (sizeTable[axis] * value)
            elseif value < 0 then
                _absoluteCoordinates[axis] = containerPosition[axis] + (sizeTable[axis] + value)
            else
                _absoluteCoordinates[axis] = containerPosition[axis]
            end
        end

        -- We follow Bounding rules, which determine how to manipulate
        -- child Frames as the parent Frame is resized.
        if frameContainer.IsBounding then
            if _frame.BoundingMode == BoundingMode.Position then
                local frameWidth = _frame.Size.AbsoluteWidth
                local containerEdgeX = containerPosition.X + containerSize.Width

                if _absoluteCoordinates.X < containerPosition.X then
                    _absoluteCoordinates.X = containerPosition.X
                elseif (_absoluteCoordinates.X + frameWidth) > containerEdgeX then
                    _absoluteCoordinates.X = containerEdgeX - frameWidth
                end

                local frameHeight = _frame.Size.AbsoluteHeight
                local containerEdgeY = containerPosition.Y + sizeTable.Y

                if _absoluteCoordinates.Y < containerPosition.Y then
                    _absoluteCoordinates.Y = containerPosition.Y
                elseif (_absoluteCoordinates.Y + frameHeight) > containerEdgeY then
                    _absoluteCoordinates.Y = containerEdgeY - frameHeight
                end
            end
        end

        do
            -- In order to respect the QT Box Model, we have to determine the
            -- actual position of the Content Rectangle. All child Frames
            -- are placed using the Content Rectangle, not the Absolute Rectangle.
            -- See: http://doc.qt.nokia.com/4.7-snapshot/stylesheet-customizing.html
            local blankX = 0 -- TODO: Are these the best names?
            local blankY = 0

            local frameComponents = _frame.Components

            if frameComponents then
                local frameBorder = frameComponents["Border"]

                if frameBorder then
                    local border = frameBorder

                    if border.Top then
                        blankX = blankX + border.Left.Width
                        blankY = blankY + border.Top.Width
                    else
                        if type(border.Width) == "table" then
                            blankX = blankX + border.Width[4]
                            blankY = blankY + border.Width[1]
                        else
                            blankX = blankX + border.Width
                            blankY = blankY + border.Width
                        end
                    end
                end

                local frameMargin = frameComponents["Margin"]
                if frameMargin then
                    blankX = blankX + frameMargin.Left
                    blankY = blankY + frameMargin.Top
                end

                local framePadding = frameComponents["Padding"]
                if framePadding then
                    blankX = blankX + framePadding.Left
                    blankY = blankY + framePadding.Top
                end
            end

            _contentCoordinates = {
                X = _absoluteCoordinates.X + blankX,
                Y = _absoluteCoordinates.Y + blankY
            }
        end
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
                updateAbsolute()
            end
        },

        Absolute = {
            get = function ()
                if not _absoluteCoordinates.X or not _absoluteCoordinates.Y then
                    updateAbsolute()
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
                    updateAbsolute()
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
                    updateAbsolute()
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
                    updateAbsolute()
                end
            end
        },

        AbsoluteX = {
            get = function ()
                if not _absoluteCoordinates.X then
                    updateAbsolute()
                end
                return _absoluteCoordinates.X
            end
        },
        AbsoluteY = {
            get = function ()
                if not _absoluteCoordinates.Y then
                    updateAbsolute()
                end

                return _absoluteCoordinates.Y
            end
        },

        ContentX = {
            get = function ()
                if not _contentCoordinates.X then
                    updateAbsolute()
                end

                return _contentCoordinates.X
            end
        },

        ContentY = {
            get = function ()
                if not _contentCoordinates.Y then
                    updateAbsolute()
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
