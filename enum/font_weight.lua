-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Enum = require("vyzor.enum")
-- Title: FontWeight

--[[
	Array: enum_table
		Defines options for FontWeight.

	Fields:
		Normal 	- Applies no weight to the text.
		Bold 	- Makes the text bold.
]]
local enum_table = {
	Normal = "normal",
	Bold = "bold",
}

--[[
	Enum: FontWeight
		Specifies options for <Font> weight.
]]
local FontWeight = Enum("FontWeight", enum_table)

return FontWeight
