-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Enum = require("vyzor.enum")
-- Title: TabLocation

--[[
    Array: _enum
        Defines the options for the TabLocation Enum.

    Fields:
        Top - Tabs will be placed on top of the Chat MiniConsoles.
        Bottom - Tabs will be placed below the Chat MiniConsoles.
        Right - Tabs will be placed along the rightside of the MiniConsoles.
        Left - Tabs will be placed along the left side of the MiniConsoles.
]]
local _enum = {
    Top = "top",
    Bottom = "bottom",
    Right = "right",
    Left = "left",
}

--[[
    Enum: TabLocation
        Determines where the tabs will be placed within a Chat Compound.
]]
local TabLocation = Enum("TabLocation", _enum)

return TabLocation
