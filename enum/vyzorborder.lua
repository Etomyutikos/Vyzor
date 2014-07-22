--- Used to identify the Border @{Frame}s Vyzor creates and manages.
--- @classmod VyzorBorder

local Enum = require("vyzor.enum")

--- VyzorBorder options.
--- @table VyzorBorder
local _enum = {
    Top = "Top",
    Bottom = "Bottom",
    Right = "Right",
    Left = "Left"
}

local VyzorBorder = Enum("VyzorBorder", _enum)

return VyzorBorder