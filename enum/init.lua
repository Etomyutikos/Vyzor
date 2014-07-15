-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require("vyzor.base")

--[[
	Class: Enum
		Defines the Enum object.
]]
local Enum = Base("Enum")

--[[
	Constructor: new

	Parameters:
		_subtype - A string identifying the Enum.
		options_table - A table of valid options for the Enum.

	Returns:
		A new Enum object.
]]
local function new (_, _subtype, _optionsTable)
	--[[
		Structure: New Enum
			A base object for all Enum objects.
	]]
	local self = {}

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
			option - The option to be tested.

		Returns:
			A boolean value.
	]]
	function self:IsValid (option)
		local isValid = false

		for index, value in pairs(_optionsTable) do
			if ((option == value) or (option == index)) then
				isValid = true
            end

			if isValid then
				return isValid
			end
        end

		return isValid
	end

	setmetatable(self, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or _optionsTable[key] or Enum[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set(value)
			end
		end
		})
	return self
end

setmetatable(Enum, {
	__index = getmetatable(Enum).__index,
	__call = new,
	})
return Enum
