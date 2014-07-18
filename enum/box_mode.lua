local Enum = require("vyzor.enum")
-- Title: BoxMode

--[[
    Array: _enum
        Contains BoxMode options.

    Fields:
        Horizontal - Left to right.
        Vertical - Top to bottom.
        Grid - Left to right, top to bottom.
]]
local _enum = {
    Horizontal = "horizontal",
    Vertical = "vertical",
    Grid = "grid",
}

--[[
    Enum: BoxMode
        Defines options for Box Compounds.
]]
local BoxMode = Enum("BoxMode", _enum)

return BoxMode
