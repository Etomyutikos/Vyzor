-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require("vyzor.base")
local FontDecoration = require("vyzor.enum.font_decoration")
local FontStyle = require("vyzor.enum.font_style")
local FontWeight = require("vyzor.enum.font_weight")

--[[
    Class: Font
        Defines the Font Component.
]]
local Font = Base("Component", "Font")

--[[
    Constructor: new

    Parameters:
        initialSize - The Font Component's initial size. Valid sizes are defined by QT, but I can only seem to get numbers to work.
        initialFamily - The font family for this Font Component.
        initialStyle - The Font Component's initial style. Optional. Must be a FontStyle or FontWeight Component.
        initialDecoration - The Font Component's initial FontDecoration. Optional.

    Returns:
        A new Font Component.
]]
local function new (_, initialSize, initialFamily, initialStyle, initialDecoration)
    --[[
        Structure: New Font
            A Component defining certain text manipulations.
    ]]
    local self = {}

    -- Double: _size
    -- The Font's initial size.
    local _size = initialSize

    -- String: _family
    -- The font family for this Font Component.
    local _family = initialFamily or "Bitsteam Vera Sans Mono"

    -- Object: _style
    -- The Font's initial <FontStyle>.
    local _style = initialStyle or FontStyle.Normal

    -- Object: _decoration
    -- The Font's initial <FontDecoration>.
    local _decoration = initialDecoration

    -- String: stylesheet
    -- The Font Component's stylesheet. Generated via <updateStylesheet>.
    local _stylesheet

    --[[
        Function: updateStylesheet
            Updates the Font Component's <stylesheet>.
    ]]
    local function updateStylesheet () -- TODO: Maybe break this up.
        _stylesheet = string.format("font-size: %s; font-family: %s; %s: %s; text-decoration: %s",
            (type(_size) == "number" and tostring(_size) .. "px") or _size,
            _family,
            ((_style and FontStyle:IsValid(_style)) and "font-style")
                or ((_style and FontWeight:IsValid(_style)) and "font-weight"),
            _style or FontStyle.Normal,
            _decoration or FontDecoration.None)
    end

    --[[
        Properties: Font Properties
            Size - Gets and sets the Font's size. Can be a number, or a number string
                            ending in "px" or "pt".
            Family - Gets and sets the Font's family. Must be a string.
            Style - Gets and sets the Font's <FontStyle>.
                            Removes the Font's <FontWeight> if set.
            Weight - Gets and sets the Font's <FontWeight>.
                            Removes the Font's <FontStyle> if set.
            Decoration - Gets and sets the Font's <FontDecoration>.
            Stylesheet - Updates and returns the Font Component's <stylesheet>.
    ]]
    local properties = {
        Size = {
            get = function ()
                return _size
            end,
            set = function (value)
                _size = value
            end,
        },

        Family = {
            get = function ()
                return _family
            end,
            set = function (value)
                _family = value
            end,
        },

        Style = {
            get = function ()
                return _style
            end,
            set = function (value)
                _style = value
            end,
        },

        Decoration = {
            get = function ()
                return _decoration
            end,
            set = function (value)
                _decoration = value
            end,
        },

        Stylesheet = {
            get = function ()
                updateStylesheet()
                return _stylesheet
            end,
        },
    }

    setmetatable(self, {
        __index = function (_, key)
            return (properties[key] and properties[key].get()) or Font[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end
    })

    return self
end

setmetatable(Font, {
    __index = getmetatable(Font).__index,
    __call = new,
})

return Font
