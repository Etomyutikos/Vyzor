-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require("vyzor.base")

--[[
    Class: Margin
        Defines a Margin Component.
]]
local Margin = Base("Component", "Margin")

--[[
    Constructor: new

    Parameters:
        ... - A list of numbers defining the size of each side of the Margin.

    Returns:
        A new Margin Component.
]]
local function new (_, ...)
    local arg = { ... }
    if not arg[1] then
        error("Vyzor: Must pass at least one size to new Margin.", 2)
    end

    --[[
        Structure: New Margin
            This Component defines the Margin of a <Frame>.
            The Margin is the exterior part of the <Frame>.

        See Also:
            <http://doc.qt.nokia.com/4.7-snapshot/stylesheet-customizing.html>
    ]]
    local self = {}

    -- Double: _top
    -- The size of the top of the Margin.
    local _top = arg[1]

    -- Double: _right
    -- The size of the right side of the Margin.
    -- Defaults to <top>.
    local _right = arg[2] or _top

    -- Double: _bottom
    -- The size of the bottom of the Margin.
    -- Defaults to <top>.
    local _bottom = arg[3] or _top

    -- Double: _left
    -- The size of the left side of the Margin.
    -- Defaults to <right>.
    local _left = arg[4] or _right

    -- String: stylesheet
    -- The Margin Component's stylesheet. Generated via <updateStylesheet>.
    local _stylesheet

    --[[
        Function: updateStylesheet
            Updates the Margin Component's <stylesheet>.
    ]]
    local function updateStylesheet ()
        _stylesheet = string.format("margin: %s", table.concat({ _top, _right, _bottom, _left }, " "))
    end

    --[[
        Properties: Margin Properties
            Top - Gets and sets the size of a side of the Margin Component.
            Right - Gets and sets the size of a side of the Margin Component.
            Bottom - Gets and sets the size of a side of the Margin Component.
            Left - Gets and sets the size of a side of the Margin Component.
            Stylesheet - Updates and returns the Margin Component's <stylesheet>.
    ]]
    local properties = {
        Top = {
            get = function ()
                return _top
            end,
            set = function (value)
                _top = value
            end,
        },

        Right = {
            get = function ()
                return _right
            end,
            set = function (value)
                _right = value
            end,
        },

        Bottom = {
            get = function ()
                return _bottom
            end,
            set = function (value)
                _bottom = value
            end,
        },

        Left = {
            get = function ()
                return _left
            end,
            set = function (value)
                _left = value
            end,
        },

        Stylesheet = {
            get = function ()
                if not _stylesheet then
                    updateStylesheet()
                end

                return _stylesheet
            end,
        },
    }

    setmetatable(self, {
        __index = function (_, key)
            return (properties[key] and properties[key].get()) or Margin[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end,
    })

    return self
end

setmetatable(Margin, {
    __index = getmetatable(Margin).__index,
    __call = new,
})

return Margin
