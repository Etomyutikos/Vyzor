-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require("vyzor.base")
local BorderSide = require("vyzor.component.border_side")
local BorderStyle = require("vyzor.enum.border_style")

--[[
    Class: Border
        Defines the Border Component.
]]
local Border = Base("Component", "Border")

--[[
    Constructor: new

    Parameters:
        initialWidth - The Border Component's initial width. May be a number or a table of numbers.
        initialStyle - The Border Component's initial <BorderStyle>. Defaults to None.
        initialContent - The Border Component's initial content. Can be an <Image>, <Brush>, or table of <Brushes>.
        initialRadius - The Border Component's initial radius, for rounded corners. Can be a number or a table of numbers.
        initialBorders - The Border Component's initial <BorderSide> Subcomponents. Must be a table containing one to four <BorderSides>.

    Returns:
        A new Border Component.
]]
local function new (_, initialWidth, initialStyle, initialContent, initialRadius, initialBorders)
    --[[
        Structure: New Border
            A Component that defines a <Frame's> Border.
    ]]
    local self = {}

    -- Double: _width
    -- The Border's width. Defaults to 0.
    local _width = initialWidth or 0

    -- Object: _style
    -- The Border's <BorderStyle>. Defaults to None.
    local _style = initialStyle or BorderStyle.None

    -- Object: _content
    -- The Border's Brush or Image Component.
    local _content = initialContent

    -- Double: _radius
    -- The Border's radius. Makes rounded corners. Defaults to 0.
    local _radius = initialRadius or 0

    -- Array: _borders
    -- A table holding <BorderSide> Subcomponents.
    local _borders

    if initialBorders and type(initialBorders) == "table" then
        local defaultSide = BorderSide(_width, _style, _content, _radius)

        _borders = {}
        _borders["top"] = initialBorders["top"] or initialBorders[1] or defaultSide
        _borders["right"] = initialBorders["right"] or initialBorders[2] or defaultSide
        _borders["bottom"] = initialBorders["bottom"] or initialBorders[3] or defaultSide
        _borders["left"] = initialBorders["left"] or initialBorders[4] or defaultSide
    end

    -- String: _stylesheet
    -- The Border's stylesheet. Generated via <updateStylesheet>.
    local _stylesheet

    --[[
        Function: updateStylesheet
            Updates the Border Component's <stylesheet>.
    ]]
    local function updateStylesheet ()
        local styleTable = {
            string.format("border-width: %s", _width),
            string.format("border-style: %s", _style),
            string.format("border-radius: %s", _radius),
        }

        if _content then
            styleTable[#styleTable +1] = string.format("border-%s",
                (_content.Subtype == "Brush" and _content.Stylesheet) or
                (_content.Subtype == "Image" and string.format("image: %s", _content.Url)))

            if _content.Subtype == "Image" then
                styleTable[#styleTable +1] = string.format("border-image-position: %s", _content.Alignment)
            end
        end

        if _borders then
            for _, side in ipairs({"top", "right", "bottom", "left"}) do
                for _, sideStyleTable in ipairs(_borders[side].Styletable) do
                    styleTable[#styleTable +1] = string.format("border-%s-%s", side, sideStyleTable)
                end
            end
        end

        _stylesheet = table.concat(styleTable, "; ")
    end

    --[[
        Properties: Border Properties
            Style - Gets and sets the <BorderStyle> Component.
            Width - Gets and sets the Border Component's width.
            Content - Gets and sets the Border Component's Brush or Image Component.
            Top - Gets and sets an individual <BorderSide> Subcomponent.
            Right - Gets and sets an individual <BorderSide> Subcomponent.
            Bottom - Gets and sets an individual <BorderSide> Subcomponent.
            Left - Gets and sets an individual <BorderSide> Subcomponent.
            Stylesheet - Updates and returns the Border Component's <stylesheet>.
    ]]
    local properties = {
        Style = {
            get = function ()
                return _style
            end,
            set = function (value)
                assert(BorderStyle:IsValid(value), "Vyzor: Invalid BorderStyle passed to Border.")
                _style = value
            end,
        },

        Width = {
            get = function ()
                if type(_width) == "table" then
                    local copy = {}

                    for i in ipairs(_width) do
                        copy[i] = _width[i]
                    end

                    return copy
                else
                    return _width
                end
            end,
            set = function (value)
                _width = value
            end,
        },

        Content = {
            get = function ()
                if type(_content) ~= "table" then
                    return _content
                else
                    local copy = {}

                    for i in ipairs(_content) do
                        copy[i] = _content[i]
                    end

                    return copy
                end
            end,
            set = function (value)
                _content = value
            end,
        },

        Top = {
            get = function ()
                return (_borders and _borders["top"]) or nil
            end,
            set = function (value)
                _borders["top"] = value
            end
        },

        Right = {
            get = function ()
                return (_borders and _borders["right"]) or nil
            end,
            set = function (value)
                _borders["right"] = value
            end
        },

        Bottom = {
            get = function ()
                return (_borders and _borders["bottom"]) or nil
            end,
            set = function (value)
                _borders["bottom"] = value
            end
        },

        Left = {
            get = function ()
                return (_borders and _borders["left"]) or nil
            end,
            set = function (value)
                _borders["left"] = value
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
            return (properties[key] and properties[key].get()) or Border[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end,
    })

    return self
end

setmetatable(Border, {
    __index = getmetatable(Border).__index,
    __call = new,
})

return Border
