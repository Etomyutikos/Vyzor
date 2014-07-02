-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require("vyzor.base")
local ColorMode = require("vyzor.enum.color_mode")

--[[
    Class: Color
        Defines the Brush Component.
]]
local Color = Base("Component", "Color")

--[[
    Constructor: new
        Expected arguments differ depending on mode.

        RGB and HSV modes expect a comma-separated list of 3-4 numbers.

        Name mode expects a single string.

        Hex mode expects a single Hex string.

    Parameters:
        mode - A <ColorMode> enum, used to determine handling of color data.
        ... - Color data. See description.

    Returns:
        A new Color Component.
]]
local function new (_, _mode, ...)
    local arg = { ... }

    --[[
        Structure: New Color
            A Component that defines color information. Used
            primarily in a <Brush> Component.
    ]]
    local self = {}

    -- Variable: color_data
    -- Holds the Component's color data.
    local _colorData

    if _mode:find(ColorMode.RGB) then
        _colorData = {
            red = arg[1],
            blue = arg[2],
            green = arg[3],
            alpha = (arg[4] or 255)
        }
    elseif _mode:find(ColorMode.HSV) then
        _colorData = {
            hue = arg[1],
            saturation = arg[2],
            value = arg[3],
            alpha = (arg[4] or 255)
        }
    elseif _mode:match(ColorMode.Name) then
        _colorData = arg[1]
    elseif _mode:match(ColorMode.Hex) then
        if not arg[1]:find("#") then
            _colorData = "#" .. arg[1]
        else
            _colorData = arg[1]
        end
    end

    -- String: stylesheet
    -- The Color Component's stylesheet. Generated via <updateStylesheet>.
    local _stylesheet

    --[[
        Function: updateStylesheet
            Updates the Color Component's <stylesheet>.
            Actual output is dependent on ColorMode.
    ]]
    local function updateStylesheet ()
        if _mode:find(ColorMode.RGB) then
            _stylesheet = string.format("color: rgba(%s, %s, %s, %s)",
                _colorData.red,
                _colorData.blue,
                _colorData.green,
                _colorData.alpha)
        elseif _mode:find(ColorMode.HSV) then
            _stylesheet = string.format("color: hsva(%s, %s, %s, %s)",
                _colorData.hue,
                _colorData.saturation,
                _colorData.value,
                _colorData.alpha)
        elseif _mode:match(ColorMode.Name) then
            _stylesheet = string.format("color: %s", _colorData)
        elseif _mode:match(ColorMode.Hex) then
            _stylesheet = string.format("color: %s", _colorData)
        end
    end

    --[[
        Properties: Color Properties
            Mode - Returns the Color Component's <ColorMode> Enum.
            Data - Returns the <color_data> passed to the Color Component.
            Stylesheet - Updates and returns the Color's <stylesheet>.
    ]]
    local properties = {
        Mode = {
            get = function ()
                return _mode
            end
        },

        Data = {
            get = function ()
                if type(_colorData) == "table" then
                    local copy = {}

                    for i in pairs(_colorData) do
                        copy[i] = _colorData[i]
                    end

                    return copy
                else
                    return _colorData
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
            return (properties[key] and properties[key].get()) or Color[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end
    })

    return self
end

setmetatable(Color, {
    __index = getmetatable(Color).__index,
    __call = new
})

return Color
