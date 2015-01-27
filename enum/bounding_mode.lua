--- Determines which aspect a @{Frame} prefers to lose when subject to bounding.
-- @classmod BoundingMode

local Enum = require("vyzor.enum")

--- BoundingMode options.
-- @table BoundingMode
local _enum = {
    Size = "size",
    Position = "position"
}

local BoundingMode = Enum("BoundingMode", _enum)

return BoundingMode
