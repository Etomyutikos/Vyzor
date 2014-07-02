-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require("vyzor.base")
local Alignment = require("vyzor.enum.alignment")
local Repeat = require("vyzor.enum.repeat")

--[[
    Class: Background
        Defines a Background Component.
]]
local Background = Base("Component", "Background")

--[[
    Constructor: new

    Parameters:
        initialContent - Either a <Brush> or <Image> Component.
        initialAlignment - Initial <Alignment> of the Background content. Default is top-left.
        initialRepeatMode - Initial <Repeat> rules for the Background content. Default is repeat-xy.

    Returns:
        A new Background Component.
]]
local function new (_, initialContent, initialAlignment, initialRepeatMode)
    --[[
        Structure: New Background
            A Component defining a <Frame's> background.
    ]]
    local self = {}

    -- Object: _content
    -- Either an Image Component or a Brush Component.
    local _content = initialContent

    -- Object: _alignment
    -- An Alignment Enum. Defaults to TopLeft.
    local _alignment = (initialAlignment or Alignment.TopLeft)

    -- Object: _repeatMode
    -- A Repeat Enum. Defaults to RepeatXY.
    local _repeatMode = (initialRepeatMode or Repeat.RepeatXY)


    -- String: _stylesheet
    -- This Component's Stylesheet. Generated via <updateStylesheet>.
    local _stylesheet

    --[[
        Function: updateStylesheet
            Updates the Component's <stylesheet>.
            Used by the containing <Frame>.
    ]]
    local function updateStylesheet ()
        local styleTable = {
            string.format("background-position: %s", _alignment),
            string.format("background-repeat: %s", _repeatMode),
        }

        if _content then
            if _content.Subtype == "Brush" then
                if _content.Content.Subtype == "Gradient" then
                    styleTable[#styleTable + 1] = string.format("background: %s", _content.Stylesheet)
                else
                    styleTable[#styleTable + 1] = string.format("background-%s", _content.Stylesheet)
                end
            else
                styleTable[#styleTable + 1] = string.format("background-image: %s", _content.Url)
            end
        end

        _stylesheet = table.concat(styleTable, "; ")
    end

    --[[
        Properties: Background Properties
            Content - Gets and sets the <Image> or <Brush> used by the Background Component.
            Alignment - Gets and sets the Background Component's content Alignment.
            Repeat - Gets and sets the Background Component's Repeat rule.
            Stylesheet - Updates and returns the Background Component's <stylesheet>.
    ]]
    local properties = {
        Content = {
            get = function ()
                return _content
            end,
            set = function (value)
                _content = value
            end,
        },

        Alignment = {
            get = function ()
                return _alignment
            end,
            set = function (value)
                if Alignment:IsValid(value) then
                    _alignment = value
                end
            end
        },

        Repeat = {
            get = function ()
                return _repeatMode
            end,
            set = function (value)
                if Repeat:IsValid(value) then
                    _repeatMode = value
                end
            end
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
            return (properties[key] and properties[key].get()) or Background[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end
        })

    return self
end

setmetatable(Background, {
    __index = getmetatable(Background).__index,
    __call = new,
    })

return Background
