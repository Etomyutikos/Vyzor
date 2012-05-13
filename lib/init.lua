-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

--[[
	Structure: Lib
		A utility table, holding miscellaneous functions and
		structures.
]]
local Lib = {}

--[[
	Function: OrderedTable
		Creates a table that preserves order of key->value pairs
		as they're entered. __call metamethod acts as iterator factory
		for purposes of traversing values.

	Returns:
		A proxy table.
]]
function Lib.OrderedTable ()
	local list = {}
	local dict = {}
	local proxy = {}
	setmetatable( proxy, {
		__index = function (_, key)
			if type(key) == "number" then
				return dict[list[key]]
			elseif type(key) == "string" then
				return dict[key]
			end
		end,
		__newindex = function (_, key, value)
			if value then
				if not dict[key] then
					table.insert(list, key)
				end
				dict[key] = value
			else
				local index
				for i,v in ipairs(list) do
					if v == key then
						index = i
						break
					end
				end
				if index then
					table.remove(list, index)
					dict[key] = nil
				else
					error(string.format("No such value (%s) in OrderedTable.", tostring(key)),3)
				end
			end
		end,
		__call = function (_)
			local function iter (_, i)
				i = i+1
				if i > #list then
					return nil
				else
					local k = list[i]
					local v = dict[k]

					return i, k, v
				end
			end

			return iter, nil, 0
		end,
	} )

	return proxy
end

setmetatable( Lib, {
	__newindex = function (_, key, value)
		error( "Vyzor: May not write directly to Lib table.", 2 )
	end,
} )

return Lib
