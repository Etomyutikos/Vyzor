local Enum = require("vyzor.enum")
-- Title: FontWeight

--[[
    Array: _enum
        Defines options for FontWeight.

    Fields:
        Normal - Applies no weight to the text.
        Bold - Makes the text bold.
]]
local _enum = {
    Normal = "normal",
    Bold = "bold",
}

--[[
    Enum: FontWeight
        Specifies options for <Font> weight.
]]
local FontWeight = Enum("FontWeight", _enum)

return FontWeight
