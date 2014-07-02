-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Enum = require("vyzor.enum")
-- Title: GaugeFill

--[[
    Array: _enum

    Fields:
        LeftRight - Gauge fills from left to right.
        RightLeft - Gauge fills from right to left.
        TopBottom - Gauge fills from top to bottom.
        BottomTop - Gauge fills from bottom to top.
]]
local _enum = {
    LeftRight = "left-to-right",
    RightLeft = "right-to-left",
    TopBottom = "top-to-bottom",
    BottomTop = "bottom-to-top"
}

--[[
    Enum: GaugeFill
        Specifics options for Gauge fill direction.
]]
local GaugeFill = Enum("GaugeFill", _enum)

return GaugeFill
