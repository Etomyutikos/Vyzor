--- Specifies options for @{Font} weights.
-- @classmod FontWeight

local Enum = require("vyzor.enum")

--- FontWeight options.
-- @table FontWeight
local _enum = {
  Normal = "normal",
  Bold = "bold",
}

local FontWeight = Enum("FontWeight", _enum)

return FontWeight
