-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

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
