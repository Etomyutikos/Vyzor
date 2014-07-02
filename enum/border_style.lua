-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Enum = require("vyzor.enum")
-- Title: BorderStyle

--[[
    Array: _enum
        Defines options for BorderStyle.

    Fields:
        Dashed - A series of dashes.
        DotDash - Alternating series of dots and dashes.
        DotDotDash - A repeating series of two dots followed by a dash.
        Dotted - A series of dots.
        Double - No clue.
        Groove - Applies a small groove to the corners.
        Inset - No clue.
        Outset - No clue.
        Ridge - No clue.
        Solid - A solid line.
        None - Applies no style to the <Border>.
]]
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

--[[
    Enum: BorderStyle
        Specifies options for <Border> and <BorderSide>.
]]
local BorderStyle = Enum("BorderStyle", _enum)

return BorderStyle
