--- Specifics options for @{Gauge} fill direction.
--- @classmod GaugeFill

local Enum = require("vyzor.enum")

--- GaugeFill options.
--- @table GaugeFill
local _enum = {
    LeftRight = "left-to-right",
    RightLeft = "right-to-left",
    TopBottom = "top-to-bottom",
    BottomTop = "bottom-to-top"
}

local GaugeFill = Enum("GaugeFill", _enum)

return GaugeFill
