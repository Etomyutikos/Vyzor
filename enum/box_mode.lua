-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Enum = require("vyzor.enum")
-- Title: BoxMode

--[[
	Array: enum_table
		Contains BoxMode options.

	Fields:
		Horizontal 	- Left to right.
		Vertical 	- Top to bottom.
		Grid 		- Left to right, top to bottom.
]]
local enum_table = {
	Horizontal = "horizontal",
	Vertical = "vertical",
	Grid = "grid",
}

--[[
	Enum: BoxMode
		Defines options for Box Compounds.
]]
local BoxMode = Enum( "BoxMode", enum_table )

return BoxMode
