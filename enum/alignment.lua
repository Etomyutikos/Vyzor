-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Enum = require("vyzor.enum")
-- Title: Alignment

--[[
    Array: _enum
        Defines the options for Alignment.

    Fields:
        Top - Up top somewhere.
        TopLeft - Top left corner.
        TopRight - Top right corner.
        TopCenter - In the middle of the top.
        Bottom - Somewhere down below.
        BottomLeft - Bottom left corner.
        BottomRight - Bottom right corner.
        BottomCenter - Right where the split would be.
        Left - Somewhere leftward.
        LeftCenter - Middle of the left side.
        Right - Yonder rightward.
        RightCenter - Middle of the right side.
        Center - Smack-dab in the middle.
]]
local _enum = {
    Top = "top",
    TopLeft = "top left",
    TopRight = "top right",
    TopCenter = "top center",
    Bottom = "bottom",
    BottomLeft = "bottom left",
    BottomRight = "bottom right",
    BottomCenter = "bottom center",
    Left = "left",
    LeftCenter = "left center",
    Right = "right",
    RightCenter = "right center",
    Center = "center",
    }

--[[
    Enum: Alignment
        Specifies options for Component alignments.
]]
local Alignment = Enum("Alignment", _enum)

return Alignment
