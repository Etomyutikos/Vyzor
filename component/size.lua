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

    --[[
        Function: updateAbsolute
            Generates the absolute dimensions (<abs_dims>) of
            the <Frame>.
            Also generates content dimensions <content_dims>.
    ]]
    local function updateAbsolute () -- TODO: Break this up.
        -- Is HUD.
        if _isFirst then
            _absoluteDimensions = _dimensions
            _contentDimensions = _dimensions
            return
        end

        local frameContainer = _frame.Container
        assert(frameContainer, "Vyzor: Frame must have container before Size can be determined.")

        local containerPosition = frameContainer.Position.Content
        local containerSize = frameContainer.Size.Content

        for dimension, value in pairs(_dimensions) do
            if value <= 1 and value > 0 then
                _absoluteDimensions[dimension] = containerSize[dimension] * value
            elseif value < 0 then
                -- Between 0 and -1 to get inverse percentage. Necessary?
                _absoluteDimensions[dimension] = containerSize[dimension] + value
            else
                _absoluteDimensions[dimension] = value
            end
        end

        -- Bounding rules. Determines Frame manipulation when parent
        -- Frame is resized.
        if frameContainer.IsBounding then
            if _frame.BoundingMode == BoundingMode.Size then
                local frameX = _frame.Position.AbsoluteX
                local frameEdgeX = frameX + _absoluteDimensions.Width
                local containerEdgeX = containerPosition.X + containerSize.Width

                if _absoluteDimensions.Width > containerSize.Width then
                    _absoluteDimensions.Width = containerSize.Width
                elseif frameEdgeX > containerEdgeX then
                    _absoluteDimensions.Width = _absoluteDimensions.Width - (frameEdgeX - containerEdgeX)
                end

                local frameY = _frame.Position.AbsoluteY
                local frameEdgeY = frameY + _absoluteDimensions.Height
                local containerEdgeY = containerPosition.Y + containerSize.Height

                if _absoluteDimensions.Height > containerSize.Height then
                    _absoluteDimensions.Height = containerSize.Height
                elseif frameEdgeY > containerEdgeY then
                    _absoluteDimensions.Height = _absoluteDimensions.Height - (frameEdgeY - containerEdgeY)
                end
            end
        end

        do
        -- We must respect QT's Box Model, so we have to find the space the
        -- Content Rectangle occupies.
        -- See: http://doc.qt.nokia.com/4.7-snapshot/stylesheet-customizing.html
            local topHeight = 0
            local rightWidth = 0
            local bottomHeight = 0
            local leftWidth = 0

            local frameComponents = _frame.Components

            if frameComponents then
                local frameBorder = frameComponents["Border"]

                if frameBorder then
                    local border = frameBorder

                    if border.Top then
                        rightWidth = rightWidth + border.Right.Width
                        leftWidth = leftWidth + border.Left.Width

                        topHeight = topHeight + border.Top.Width
                        bottomHeight = bottomHeight + border.Bottom.Width
                    else
                        if type(border.Width) == "table" then
                            rightWidth = rightWidth + border.Width[2]
                            leftWidth = leftWidth + border.Width[4]

                            topHeight = topHeight + borders.Width[1]
                            bottomHeight = bottomHeight + borders.Width[3]
                        else
                            rightWidth = rightWidth + border.Width
                            leftWidth = leftWidth + border.Width

                            topHeight = topHeight + border.Width
                            bottomHeight = bottomHeight + border.Width
                        end
                    end
                end

                local frameMargin = frameComponents["Margin"]
                if frameMargin then
                    rightWidth = rightWidth + frameMargin.Right
                    leftWidth = leftWidth + frameMargin.Left

                    topHeight = topHeight + frameMargin.Top
                    bottomHeight = bottomHeight + frameMargin.Bottom
                end

                local framePadding = frameComponents["Padding"]
                if framePadding then
                    rightWidth = rightWidth + framePadding.Right
                    leftWidth = leftWidth + framePadding.Left

                    topHeight = topHeight + framePadding.Top
                    bottomHeight = bottomHeight + framePadding.Bottom
                end
            end

            _contentDimensions = {
                Width = _absoluteDimensions.Width - (rightWidth + leftWidth),
                Height = _absoluteDimensions.Height - (topHeight + bottomHeight)
            }
        end
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
