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
    local dictionary = {}
    local proxy = {}

    function proxy:count ()
        return #list
    end

    function proxy:each()
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

    function proxy:ipairs ()
        local function iter(_, i)
            i = i + 1
            if i > #list then
                return nil
            else
                return i, dictionary[k]
            end
        end

        return iter, nil, 0
    end

    function proxy:opairs ()
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

    function proxy:pairs ()
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

    return setmetatable(proxy, {
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

--[[
    Function: do_error
        A local function to output uniform error messages.

    Parameters:
        kind - The types that failed to match.
        depth - The depth of the CheckInput call.
        object - The object or property that received the bad input.
        position - If this was an argument to a constructor, this is
                    the argument's position.
]]
local function doError (kind, depth, object, position)
    local kindString

    if type(kind) == "table" then
        if #kind == 2 then
            kindString = kind[1] .. " or " .. kind[2]
        else
            kindString = string.format("%s, or %s",
                table.concat(kind, ", ", 1, #kind - 1),
                kind[#kind]
        )
        end
    end

    local message = string.format(
        "Vyzor: Invalid %s argument to %s. Must be %s.",
        (position or ""),
        object,
        kindString
)

    error(message, depth + 1)
end

--[[
    Function: CheckInput
        Does some input checking for sanity's sake.

    Parameters:
        check - The type of check to be done.
        value - The thing to check.
        kinds - What said thing needs to be.
        depth - Where in the stack the error is being called.
        object - The object or function name receiving the input.
        position - If this is a multiple argument call, this is the position
                    of the argument.
]]
function Lib.CheckInput (check, value, kinds, depth, object, position)
    local depth = depth + 1

    if check == "lua" then
        if not value then
            doError(kinds, depth, object, position)
        else
            if type(kinds) == "table" then
                local ok = false

                for _, kind in ipairs(kinds) do
                    if type(value) == kind then
                        ok = true
                        break
                    end
                end

                if not ok then
                    doError(kinds, depth, object, position)
                end
            else
                if type(value) ~= kinds then
                    doError(kinds, depth, object, position)
                end
            end
        end

    elseif check == "vyzor" then
        if not value then
            doError(kinds, depth, object, position)
        else
            if not value.Type then
                doError(kinds, depth, object, position)
            else
                if type(kinds) == "table" then
                    local ok = false

                    for _, kind in ipairs(kinds) do
                        if value.Subtype == kind then
                            ok = true
                            break
                        end
                    end

                    if not ok then
                        doError(kinds, depth, object, position)
                    end
                else
                    if value.Subtype ~= kinds then
                        doError(kinds, depth, object, position)
                    end
                end
            end
        end
    end
end

setmetatable(Lib, {
    __newindex = function (_, key, value)
        error("Vyzor: May not write directly to Lib table.", 2)
    end,
})

return Lib
