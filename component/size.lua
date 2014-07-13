-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require("vyzor.base")
local BoundingMode = require("vyzor.enum.bounding_mode")

--[[
    Class: Size
        Defines the Size Supercomponent.
]]
local Size = Base("Supercomponent", "Size")

--[[
    Constructor: new

    Parameters:
        _frame - The <Frame> to which this Size Supercomponent belongs.
        initialWidth - Initial width of the <Frame>.
        initialHeight - Initial height of the <Frame>.
        _isFirst - Determines whether or not the parent <Frame> is the <HUD>.

    Returns:
        A new Size Supercomponent.
]]
local function new (_, _frame, initialWidth, initialHeight, _isFirst)
    --[[
        Structure: New Size
            A Supercomponent used only within <Frames> to
            manage space. Only used internally. Should not
            be exposed.
    ]]
    local self = {}

    -- Array: _dimensions
    -- Contains the user-defined dimensions of the <Frame>.
    local _dimensions = {
        Width = (initialWidth or 1),
        Height = (initialHeight or 1),
    }

    -- Array: _absoluteDimensions
    -- Contains the <Frame's> generated, window dimensions.
    local _absoluteDimensions = {}

    -- Array: _contentDimensions
    -- Contains the <Frame's> generated, Content Rectangle dimensions.
    local _contentDimensions = {}

    local function updateContent ()
        -- We must respect QT's Box Model, so we have to find the space the
        -- Content Rectangle occupies.
        -- See: http://doc.qt.nokia.com/4.7-snapshot/stylesheet-customizing.html
        local top = 0
        local right = 0
        local bottom = 0
        local left = 0

        if _frame.Components then
            local border = _frame.Components["Border"]
            if border then
                if border.Top then
                    right = right + border.Right.Width
                    left = left + border.Left.Width

                    top = top + border.Top.Width
                    bottom = bottom + border.Bottom.Width
                else
                    -- TODO: This is internal detail that introduces extra complexity at the call site.
                    if type(border.Width) == "table" then
                        right = right + border.Width[2]
                        left = left + border.Width[4]

                        top = top + borders.Width[1]
                        bottom = bottom + borders.Width[3]
                    else
                        right = right + border.Width
                        left = left + border.Width

                        top = top + border.Width
                        bottom = bottom + border.Width
                    end
                end
            end

            local margin = _frame.Components["Margin"]
            if margin then
                right = right + margin.Right
                left = left + margin.Left

                top = top + margin.Top
                bottom = bottom + margin.Bottom
            end

            local padding = _frame.Components["Padding"]
            if padding then
                right = right + padding.Right
                left = left + padding.Left

                top = top + padding.Top
                bottom = bottom + padding.Bottom
            end
        end

        _contentDimensions = {
            Width = _absoluteDimensions.Width - (right + left),
            Height = _absoluteDimensions.Height - (top + bottom)
        }
    end

    --[[
        Function: updateAbsolute
            Generates the absolute dimensions (<abs_dims>) of
            the <Frame>.
            Also generates content dimensions <content_dims>.
    ]]
    local function updateAbsolute ()
        -- Is HUD.
        if _isFirst then
            _absoluteDimensions = _dimensions
            _contentDimensions = _dimensions
            return
        end

        assert(_frame.Container, "Vyzor: Frame must have container before Size can be determined.")

        local function calculateAbsoluteDimension (rawDimension, containerDimension)
            if rawDimension <= 1 and rawDimension > 0 then
                return containerDimension * rawDimension
            elseif rawDimension < 0 then
                return containerDimension + rawDimension
            else
                return rawDimension
            end
        end

        local frameContainer = _frame.Container
        local containerPosition = frameContainer.Position.Content
        local containerSize = frameContainer.Size.Content

        _absoluteDimensions.Width = calculateAbsoluteDimension(_dimensions.Width, containerSize.Width)
        _absoluteDimensions.Height = calculateAbsoluteDimension(_dimensions.Height, containerSize.Height)

        if frameContainer.IsBounding and _frame.BoundingMode == BoundingMode.Size then
            local function setBoundedDimension (absoluteDimension, maximum, edge, containerEdge)
                if absoluteDimension > maximum then
                    return maximum
                elseif edge > containerEdge then
                    return absoluteDimension - (edge - containerEdge)
                else
                    return absoluteDimension
                end
            end

            _absoluteDimensions.Width = setBoundedDimension(
                _absoluteDimensions.Width,
                containerSize.Width,
                _frame.Position.AbsoluteX + _absoluteDimensions.Width, -- TODO: Edge calculation should be an internal detail.
                containerPosition.X + containerSize.Width)

            _absoluteDimensions.Height = setBoundedDimension(_absoluteDimensions.Height,
                containerSize.Height,
                _frame.Position.AbsoluteY + _absoluteDimensions.Height,
                containerPosition.Y + containerSize.Width)
        end

        updateContent()
    end

    --[[
        Properties: Size Properties
            Dimensions - Gets and sets the relative (user-defined) dimensions
                                (<dims>) of the <Frame>.
            Absolute - Returns the absolute dimensions (<abs_dims>) of the
                                <Frame>.
            Content - Returns dimensions of the Content Rectangle
                                (<content_dims>).
            Width - Gets and sets the relative width of the <Frame>.
            Height - Gets and sets the relative height of the <Frame>.
            AbsoluteWidth - Returns the absolute width of the <Frame>.
            AbsoluteHeight - Returns the absolute height of the <Frame>.
            ContentWidth - Returns the width of the Content Rectangle.
            ContentHeight - Returns the height of the Content Rectangle.
    ]]
    local properties = {
        Dimensions = {
            get = function ()
                local copy = {}

                for i in pairs(_dimensions) do
                    copy[i] = _dimensions[i]
                end

                return copy
            end,
            set = function (value)
                _dimensions.Width = value.Width or value[1]
                _dimensions.Height = value.Height or value[2]
                updateAbsolute()
            end
        },

        Absolute = {
            get = function ()
                if not _absoluteDimensions.Width or not _absoluteDimensions.Height then
                    updateAbsolute()
                end

                local copy = {}

                for i in pairs(_absoluteDimensions) do
                    copy[i] = _absoluteDimensions[i]
                end

                return copy
            end
        },

        Content = {
            get = function ()
                if not _contentDimensions.Width or not _contentDimensions.Height then
                    updateAbsolute()
                end

                local copy = {}

                for i in pairs(_absoluteDimensions) do
                    copy[i] = _contentDimensions[i]
                end

                return copy
            end
        },

        Width = {
            get = function ()
                return _dimensions.Width
            end,
            set = function (value)
                _dimensions.Width = value

                if _frame.Container.IsDrawn then
                    updateAbsolute()
                end
            end
        },

        Height = {
            get = function ()
                return _dimensions.Height
            end,
            set = function (value)
                _dimensions.Height = value

                if _frame.Container.IsDrawn then
                    updateAbsolute()
                end
            end
        },

        AbsoluteWidth = {
            get = function ()
                if not _absoluteDimensions.Width then
                    updateAbsolute()
                end

                return _absoluteDimensions.Width
            end
        },

        AbsoluteHeight = {
            get = function ()
                if not _absoluteDimensions.Height then
                    updateAbsolute()
                end

                return _absoluteDimensions.Height
            end
        },

        ContentWidth = {
            get = function ()
                if not _contentDimensions.Width then
                    updateAbsolute()
                end

                return _contentDimensions.Width
            end
        },

        ContentHeight = {
            get = function ()
                if not _contentDimensions.Height then
                    updateAbsolute()
                end

                return _contentDimensions.Height
            end
        },
    }

    setmetatable(self, {
        __index = function (_, key)
            return (properties[key] and properties[key].get()) or Size[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end,
    })

    return self
end

setmetatable(Size, {
    __index = getmetatable(Size).__index,
    __call = new,
})

return Size
