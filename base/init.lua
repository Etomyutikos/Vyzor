-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

--[[
	Class: Base
		This is the Base object from which all other objects
		are derived. It defines type handling. Only used
		internally. Should not be exposed.
]]
local Base = {}

--[[
	Constructor: new

	Parameters:
		_type 		- The new object's type.
		_subtype 	- The new object's subtype.

	Returns:
		A new type-defined object.
]]
local function new (_, _type, _subtype)
	-- Structure: New Base
	-- A new Base object.
	local new_base = {}

	--[[
		Properties: Base Properties
			Type - Returns the object's type.
			Subtype - Returns the object's subtype.
	]]
	local properties = {
		Type = {
			get = function ()
				return _type
			end
			},
		Subtype = {
			get = function ()
				return _subtype
			end
			}
		}

	setmetatable( new_base, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or Base[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set( value )
			end
		end,
		} )
	return new_base
end

setmetatable( Base, {
	__call = new,
	} )
return Base
