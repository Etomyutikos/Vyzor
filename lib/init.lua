--- A utility module, holding miscellaneous functions and structures.
-- @module Lib

local Lib = {}

--- Creates a table that preserves order of key->value pairs as they're entered.
-- @treturn table
function Lib.OrderedTable ()
    --- @type OrderedTable
    local list = {}
    local dictionary = {}
    local self = {}

    --- Returns the number of items in the ordered table.
    function self:count ()
        return #list
    end

    --- Iterates over each item in the table, returning only that item.
    function self:each()
        local i = 0

        local function iter(_)
            i = i + 1
            if i > #list then
                return nil
            else
                local k = list[i]
                local v = dictionary[k]

                return v
            end
        end

        return iter, nil, i
    end

    --- Iterates over each item in the table, returning the index and the item.
    function self:ipairs ()
        local function iter(_, i)
            i = i + 1
            if i > #list then
                return nil
            else
                local k = list[i]
                return i, dictionary[k]
            end
        end

        return iter, nil, 0
    end

    --- Iterates over each item in the table, returning the index, the key, and the item.
    function self:opairs ()
        local function iter(_, i)
            i = i + 1
            if i > #list then
                return nil
            else
                local k = list[i]
                local v = dictionary[k]

                return i, k, v
            end
        end

        return iter, nil, 0
    end

    --- Iterates over each item in the table, returning the key and the item.
    function self:pairs ()
        local i = 0

        local function iter(_)
            i = i + 1
            if i > #list then
                return nil
            else
                local k = list[i]
                local v = dictionary[k]

                return k, v
            end
        end

        return iter, nil, i
    end

    return setmetatable(self, {
        __index = function (_, key)
            if type(key) == "number" then
                return dictionary[list[key]]
            elseif type(key) == "string" then
                return dictionary[key]
            end
        end,
        __newindex = function (_, key, value)
            if value then
                if not dictionary[key] then
                    table.insert(list, key)
                end

                dictionary[key] = value
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
                    dictionary[key] = nil
                else
                    error(string.format("No such value (%s) in OrderedTable.", tostring(key)),3)
                end
            end
        end
    })
end

setmetatable(Lib, {
    __newindex = function (_, key, value)
        error("Vyzor: May not write directly to Lib table.", 2)
    end,
})

return Lib
