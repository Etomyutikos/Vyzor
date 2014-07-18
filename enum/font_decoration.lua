local Enum = require("vyzor.enum")
-- Title: FontDecoration

--[[
    Array: _enum
        Defines options for FontDecoration.

    Fields:
        None - Does nothing to the text.
        Underline - Draws a line beneath the text.
        Overline - Draws a line over the text.
        LineThrough - Draws a line through the text.
]]
local _enum = {
    None = "none",
    Underline = "underline",
    Overline = "overline",
    LineThrough = "line-through",
}

--[[
    Enum: FontDecoration
        Specifices <Font> markup options.
]]
local FontDecoration = Enum("FontDecoration", _enum)

return FontDecoration
