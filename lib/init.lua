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

--[[
	Function: do_error
		A local function to output uniform error messages.

	Parameters:
		kind 	- The types that failed to match.
		depth 	- The depth of the CheckInput call.
		obj 	- The object or property that received the bad input.
		pos 	- If this was an argument to a constructor, this is
					the argument's position.
]]
local function do_error (kind, depth, obj, pos)
	local kind_str
	if type( kind ) == "table" then
		if #kind == 2 then
			kind_str = kind[1] .. " or " .. kind[2]
		else
			kind_str = string.format( "%s, or %s",
				table.concat( kind, ", ", 1, #kind - 1 ),
				kind[#kind]
			)
		end
	end

	local msg = string.format(
		"Vyzor: Invalid %s argument to %s. Must be %s.",
		(pos or ""),
		obj,
		kind_str
	)

	error( msg, depth + 1 )
end

--[[
	Function: CheckInput
		Does some input checking for sanity's sake.

	Parameters:
		check 	- The type of check to be done.
		value 	- The thing to check.
		kind 	- What said thing needs to be.
		depth 	- Where in the stack the error is being called.
		obj 	- The object or function name receiving the input.
		pos 	- If this is a multiple argument call, this is the position
					of the argument.
]]
function Lib.CheckInput (check, value, kind, depth, obj, pos)
	local depth = depth + 1

	if check == "lua" then
		if not value then
			do_error( kind, depth, obj, pos )
		else
			if type( kind ) == "table" then
				local ok = false
				for _, t in ipairs( kind ) do
					if type( value ) == t then
						ok = true
						break
					end
				end
				if not ok then
					do_error( kind, depth, obj, pos )
				end
			else
				if type( value ) ~= kind then
					do_error( kind, depth, obj, pos )
				end
			end
		end

	elseif check == "vyzor" then
		if not value then
			do_error( kind, depth, obj, pos )
		else
			if not value.Type then
				do_error( kind, depth, obj, pos )
			else
				if type( kind ) == "table" then
					local ok = false
					for _, st in ipairs( kind ) do
						if value.Subtype == st then
							ok = true
							break
						end
					end
					if not ok then
						do_error( kind, depth, obj, pos )
					end
				else
					if value.Subtype ~= kind then
						do_error( kind, depth, obj, pos )
					end
				end
			end
		end
	end
end

setmetatable( Lib, {
	__newindex = function (_, key, value)
		error( "Vyzor: May not write directly to Lib table.", 2 )
	end,
} )

return Lib
