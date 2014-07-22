--- Specifies operating modes for @{Gradient} Components.
--- @classmod GradientMode

local Enum = require("vyzor.enum")

--- GradientMode options.
--- @table GradientMode
local _enum = {
    Linear = "linear",
    Radial = "radial",
    Conical = "conical"
}

local GradientMode = Enum("GradientMode", _enum)

return GradientMode
