--- Specifies modes for @{Color} Components.
-- @classmod ColorMode

local Enum = require("vyzor.enum")

--- ColorMode options.
-- @table ColorMode
local _enum = {
    RGB = "rgb",
    RGBA = "rgba",
    HSV = "hsv",
    HSVA = "hsva",
    Hex = "hex",
    Name = "name",
}

local ColorMode = Enum("ColorMode", _enum)

return ColorMode
