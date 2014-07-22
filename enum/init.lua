--- A base object for all Enum objects.
--- @classmod Enum

local Base = require("vyzor.base")

local Enum = Base("Enum")

--- Enum constructor.
--- @function Enum
--- @string _subtype A string identifying the Enum.
--- @tparam table _optionsTable A table of valid options for the Enum.
--- @treturn Enum
local function new (_, _subtype, _optionsTable)
	--- @type Enum
	local self = {}

    --- Properties
    --- @section
	local properties = {
		Subtype = {
            --- Returns the subtype of the Enum.
            --- @function self.Subtype.get
            --- @treturn string
			get = function ()
				return _subtype
			end
        }
    }
    --- @section end

    --- Verifies the Enum.
    ---
    --- Searches for matching key or value within the options table to guarantee the passing of valid options
    --- where necessary.
    --- @string option
    --- @treturn bool
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
