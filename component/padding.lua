-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require("vyzor.base")

--[[
    Class: Padding
        Defines the Padding Component.
]]
local Padding = Base("Component", "Padding")

--[[
    Constructor: new

    Parameters:
        ... - A list of numbers defining the size of each side of the Padding Component.

    Returns:
        A new Padding Component.
]]
local function new (_, ...)
    local arg = { ... }
    if not arg[1] then
        error("Vyzor: Must pass at least one size to a new Padding.", 2)
    end

    --[[
        Structure: New Padding
            This Component defines the Padding of a <Frame>.
            The Padding between the Content and the Border.

        See Also:
            <http://doc.qt.nokia.com/4.7-snapshot/stylesheet-customizing.html>
    ]]
    local self = {}

    -- Double: _top
    -- The size of the top of the Padding.
    local _top = arg[1]

    -- Double: _right
    -- The size of the right side of the Padding.
    -- Defaults to <top>.
    local _right = arg[2] or _top

    -- Double: _bottom
    -- The size of the bottom of the Padding.
    -- Defaults to <top>.
    local _bottom = arg[3] or _top

    -- Double: _left
    -- The size of the left side of the Padding.
    -- Defaults to <right>.
    local _left = arg[4] or _right

    -- String: _stylesheet
    -- The Padding Component's stylesheet. Generated via <updateStylesheet>.
    local _stylesheet

    --[[
        Function: updateStylesheet
            Updates the Padding Component's <stylesheet>.
    ]]
    local function updateStylesheet ()
        _stylesheet = string.format("padding: %s", table.concat({ _top, _right, _bottom, _left }, " "))
    end

    --[[
        Properties: Padding Properties
            Top - Gets and sets the size of a side of the Padding Component.
            Right - Gets and sets the size of a side of the Padding Component.
            Bottom - Gets and sets the size of a side of the Padding Component.
            Left - Gets and sets the size of a side of the Padding Component.
            Stylesheet - Updates and returns the Padding Component's <stylesheet>.
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
            return (properties[key] and properties[key].get()) or Padding[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end,
    })

    return self
end

setmetatable(Padding, {
    __index = getmetatable(Padding).__index,
    __call = new,
})

return Padding

