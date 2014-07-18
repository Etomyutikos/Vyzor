local Enum = require("vyzor.enum")
-- Title: BoundingMode

--[[
    Array: _enum
        Defines option for BoundingMode.

    Fields:
        Size - <Frames> prefer to lose their size when subject to bounding.
        Position - <Frames> prefer to lose their position when subject to bounding.
]]
local _enum = {
    Size = "size",
    Position = "position"
}

--[[
    Enum: BoundingMode
        Determines which aspect a <Frame> prefers to lose
        when subject to bounding.
]]
local BoundingMode = Enum("BoundingMode", _enum)

return BoundingMode
