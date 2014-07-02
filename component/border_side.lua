-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require("vyzor.base")
local BorderStyle = require("vyzor.enum.border_style")

--[[
    Class: BorderSide
        Defines a BorderSide Component.
]]
local BorderSide = Base("Subcomponent", "BorderSide")

--[[
    Constructor: new
        Should only be used as an argument to a <Border> Component.

    Parameters:
        initialWidth - The BorderSide's initial width.
        initialStyle - The BorderSide's initial <BorderStyle>. Defaults to None.
        initialContent - The BorderSide's initial Brush or Image.
        initialRadius - The radius of the BorderSide's corners. Only relevant for top and bottom BorderSides.

    Returns:
        A new BorderSide Subcomponent.
]]
local function new (_, initialWidth, initialStyle, initialContent, initialRadius)
    --[[
        Structure: New BorderSide
            A Subcomponent that defines individual sides of a <Border>
            component.
    ]]
    local self = {}

    -- Boolean: _isSide
    -- Is it a Left or Right? Only Top and Bottom use radius, as per QT.
    local _isSide = false

    -- Double: _width
    -- BorderSide's width.
    local _width = initialWidth or 0

    -- Object: _style
    -- BorderSide's <BorderStyle>. Defaults to None.
    local _style = initialStyle or BorderStyle.None

    -- Object: _content
    -- BorderSide's Brush Component.
    local _content = initialContent

    -- Double: _radius
    -- BorderSide's radius. Defaults to 0.
    local _radius = initialRadius or 0

    -- Array: _styleTable
    -- A table holding the Stylesheets of all Components.
    -- This makes indexing easier for the <Border> Component.
    local _styleTable

    --[[
        Function: updateStyleTable
            Updates the BorderSide's stylesheet table.
    ]]
    local function updateStyleTable()
        _styleTable = {
            string.format("width: %s", _width),
            string.format("style: %s", _style),
        }

        if _content then
            _styleTable[#_styleTable +1] = string.format("%s: %s",
                (_content.Subtype == "Brush" and _content.Stylesheet) or
                (_content.Subtype == "Image" and string.format("image: %s", _content.Url)))

            if _content.Subtype == "Image" then
                _styleTable[#_styleTable +1] = string.format("image-position: %s", _content.Alignment)
            end
        end

        if not _isSide then
            if type(_radius == "table") then
                _styleTable[#_styleTable +1] = string.format("left-radius: %s", _radius[1])
                _styleTable[#_styleTable +1] = string.format("right-radius: %s", _radius[2])
            else
                _styleTable[#_styleTable +1] = string.format("radius: %s", _radius)
            end
        end
    end

    --[[
        Properties: BorderSide Properties
            Width - Gets and sets the BorderSide Subcomponent's width.
            Style - Gets and sets the BorderSide's <BorderStyle>.
            Content - Gets and sets the BorderSide's Brush or Image Component.
            Radius - Gets and sets the BorderSide's radius.
            IsSide - Gets and sets the BorderSide's <is_side> value. Must be boolean.
            Styletable - Updates and returns the BorderSide's stylesheet table.
    ]]
    local properties = {
        Width = {
            get = function ()
                return _width
            end,
            set = function (value)
                _width = value
            end,
        },

        Style = {
            get = function ()
                return _style
            end,
            set = function (value)
                if BorderStyle:IsValid(value) then
                    _style = value
                end
            end,
        },

        Content = {
            get = function ()
                return _content
            end,
            set = function (value)
                _content = value
            end,
        },

        Radius = {
            get = function ()
                return _radius
            end,
            set = function (value)
                _radius = value
            end,
        },

        IsSide = {
            get = function ()
                return _isSide
            end,
            set = function (value)
                _isSide = value
            end,
        },

        Styletable = {
            get = function ()
                if not _styleTable then
                    updateStyleTable()
                end

                return _styleTable
            end,
        },
    }

    setmetatable(self, {
        __index = function (_, key)
            return (properties[key] and properties[key].get()) or BorderSide[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end,
        })

    return self
end

setmetatable(BorderSide, {
    __index = getmetatable(BorderSide).__index,
    __call = new
})

return BorderSide
