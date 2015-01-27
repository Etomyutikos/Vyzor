--- Specifies @{Font} markup options.
-- @classmod FontDecoration

local Enum = require("vyzor.enum")

--- FontDecoration options.
-- @table FontDecoration
local _enum = {
  None = "none",
  Underline = "underline",
  Overline = "overline",
  LineThrough = "line-through",
}

local FontDecoration = Enum("FontDecoration", _enum)

return FontDecoration
