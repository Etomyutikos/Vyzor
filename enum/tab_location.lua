--- Determines where the tabs will be placed within a @{Chat} Compound.
--- @classmod TabLocation

local Enum = require("vyzor.enum")

--- TabLocation options.
--- @table TabLocation.
local _enum = {
    Top = "top",
    Bottom = "bottom",
    Right = "right",
    Left = "left",
}

local TabLocation = Enum("TabLocation", _enum)

return TabLocation
