--- Specifies options for Component with repeating elements.
--- @classmod Repeat

local Enum = require("vyzor.enum")

--- Repeat options.
--- @table Repeat
local _enum = {
    RepeatX = "repeat-x",
    RepeatY = "repeat-y",
    RepeatXY = "repeat-xy",
    NoRepeat = "no-repeat",
}

local Repeat = Enum("Repeat", _enum)

return Repeat
