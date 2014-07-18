local Enum = require("vyzor.enum")
-- Title: Repeat

--[[
    Array: _enum
        Defines options for Repeat.

    Fields:
        RepeatX - Repeats element horizontally.
        RepeatY - Repeats element vertically.
        RepeatXY - Repeats element both horizontally and vertically.
        NoRepeat - Does not repeat the element.
]]
local _enum = {
    RepeatX = "repeat-x",
    RepeatY = "repeat-y",
    RepeatXY = "repeat-xy",
    NoRepeat = "no-repeat",
}

--[[
    Enum: Repeat
        Specifies options for Component with repeating elements.
]]
local Repeat = Enum("Repeat", _enum)

return Repeat
