local Enum = require("vyzor.enum")
-- Title: GradientMode

--[[
    Array: _enum
        Defines options for GradientMode.

    Fields:
        Linear - A gradient in which color changes in a straight line.
        Radial - A gradient which color changes radiating outward from
                    a single point an in all directions.
        Conical - A gradient in which color changes in a cone shape from
                    a single point, with a direction and angle.
]]
local _enum = {
    Linear = "linear",
    Radial = "radial",
    Conical = "conical"
}

--[[
    Enum: GradientMode
        Specifies operating modes for <Gradient> Components.
]]
local GradientMode = Enum("GradientMode", _enum)

return GradientMode
