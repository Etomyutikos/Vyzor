--- Specifies option for @{Border} and @{BorderSide} Components.
--- @classmod BorderStyle

local Enum = require("vyzor.enum")

--- BorderStyle options.
--- @table BorderStyle
local _enum = {
    Dashed = "dashed",
    DotDash = "dot-dash",
    DotDotDash = "dot-dot-dash",
    Dotted = "dotted",
    Double = "double",
    Groove = "groove",
    Inset = "inset",
    Outset = "outset",
    Ridge = "ridge",
    Solid = "solid",
    None = "none",
}

local BorderStyle = Enum("BorderStyle", _enum)

return BorderStyle
