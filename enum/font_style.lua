local Enum = require("vyzor.enum")
-- Title: FontStyle

--[[
    Array: _enum
        Defines options for FontStyle.

    Fields:
        Normal - Applies no style to the text.
        Italic - Makes the text italic.
        Oblique - Your guess is as good as mine.
]]
local _enum = {
    Normal = "normal",
    Italic = "italic",
    Oblique = "oblique",
}

--[[
    Enum: FontStyle
        Specifies options for <Font> styles.
]]
local FontStyle = Enum("FontStyle", _enum)

return FontStyle
