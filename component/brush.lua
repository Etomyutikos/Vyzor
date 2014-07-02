-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require("vyzor.base")

--[[
    Class: Brush
        Defines a Brush Component.
]]
local Brush = Base("Component", "Brush")

--[[
    Constructor: new

    Parameters:
        initialContent - The initial content of this Brush Component. Must be a <Color> or <Gradient> Component.

    Returns:
        A new Brush Component.
]]
local function new ( _, initialContent)
    -- Structure: New Brush
    -- A Component container that holds either a <Color> Component
    -- or a <Gradient> Component.
    local self = {}

    -- Object: _content
    -- The <Color> or <Gradient> Component this Brush contains.
    local _content = initialContent

    --[[
        Properties: Brush Properties
            Content - Gets and sets the Brush's content. Must be a <Color> or <Gradient> Component.
            Stylesheet - Returns the Brush's content's Stylesheet.
    ]]
    local properties = {
        Content = {
            get = function ()
                return _content
            end,
            set = function (value)
                _content = value
            end
        },

        Stylesheet = {
            get = function ()
                return _content.Stylesheet
            end,
        },
    }

    setmetatable(self, {
        __index = function (_, key)
            return (properties[key] and properties[key].get()) or Brush[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end
    })

    return self
end

setmetatable(Brush, {
    __index = getmetatable(Brush).__index,
    __call = new
})

return Brush

