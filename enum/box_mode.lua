--- Defines options for @{Box} Compounds.
-- @classmod BoxMode

local Enum = require("vyzor.enum")

--- BoxMode options.
-- @table BoxMode
local _enum = {
    Horizontal = "horizontal",
    Vertical = "vertical",
    Grid = "grid",
}

local BoxMode = Enum("BoxMode", _enum)

return BoxMode
