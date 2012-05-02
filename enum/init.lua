-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require( "vyzor.base" )

--[[
	Class: Enum
		Defines the Enum object.
]]
local Enum = Base( "Enum" )

--[[
	Constructor: new

	Parameters:
		_subtype 		- A string identifying the Enum.
		options_table 	- A table of valid options for the Enum.

	Returns:
		A new Enum object.
]]
local function new (_, _subtype, options_table)
	--[[
		Structure: New Enum
			A base object for all Enum objects.
	]]
	local new_enum = {}

	--[[
		Properties:
			Subtype - Returns the Enum's Subtype.
	]]
	local properties = {
		Subtype = {
			get = function ()
				return _subtype
			end
			}
		}

	--[[
		Function: IsValid
			Verifies the Enum.
			Searches for matching key or value within
			the options_table to guarantee the passing
			of valid options where necessary.

		Paramaters:
			key - The option to be tested.

		Returns:
			A boolean value.
	]]
	function new_enum:IsValid (key)
		local is_valid = false
		for index, value in pairs( options_table ) do
			if ((key == value) or (key == index)) then
				is_valid = true
			end
			if is_valid then
				return is_valid
			end
		end
		return is_valid
	end

	setmetatable( new_enum, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or options_table[key] or Enum[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set( value )
			end
		end
		} )
	return new_enum
end

setmetatable( Enum, {
	__index = getmetatable(Enum).__index,
	__call = new,
	} )
return Enum
