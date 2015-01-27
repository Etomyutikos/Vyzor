--- Specifies options for @{Font} styles.
-- @classmod FontStyle

local Enum = require("vyzor.enum")

--- FontStyle options.
-- @table FontStyle
local _enum = {
    Normal = "normal",
    Italic = "italic",
    Oblique = "oblique",
}

local FontStyle = Enum("FontStyle", _enum)

return FontStyle
