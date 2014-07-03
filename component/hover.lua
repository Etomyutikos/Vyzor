-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require("vyzor.base")
local Lib = require("vyzor.lib")

--[[
    Class: Hover
        Defines a Hover Component.
]]
local Hover = Base("Component", "Hover")

--[[
    Constructor: new

    Parameters:
        initialComponents - A table of Components to be contained in this Hover Component. Optional.

    Returns:
        A new Hover Component.
]]
local function new (_, initialComponents)
    --[[
        Structure: New Hover
            This Component defines <Frame> behaviour on mouse-over,
            and may contain other Components much like <Frames>.
    ]]
    local self = {}

    -- Array: _components
    -- A table of Components.
    local _components = Lib.OrderedTable()

    if initialComponents then
        for _, component in ipairs(initialComponents) do
            assert(not _components[component.Subtype], "Vyzor: Attempt to add duplicate Component to Hover Component.")
            assert(component.Subtype ~= "Hover", "Vyzor: May not add Hover Component to Hover Component.")

            _components[component.Subtype] = component
        end
    end

    -- String: _stylesheet
    -- Hover Component's stylesheet. Generated via <updateStylesheet>.
    local _stylesheet

    --[[
        Function: updateStylesheet
            Updates the Hover Component's <stylesheet>.
            The string generated is a combination of all Components'
            stylesheets.
    ]]
    local function updateStylesheet ()
        if _components:count() > 0 then
            local _styleTable = {}

            for component in _components:each() do
                _styleTable[#_styleTable + 1] = component.Stylesheet
            end

            -- I don't know why that opening brace is there. I assume
            -- it's some weird artifact caused by Mudlet's handling
            -- of QT's Stylesheets. But it has to be there.
            _stylesheet = string.format("}QLabel::Hover{ %s }", table.concat(_styleTable, "; "))
        end
    end

    --[[
        Properties: Hover Properties
            Components - Returns a table copy of Hover Component's contained Components.
            Stylesheet - Updates and returns the Hover Component's <stylesheet>.
    ]]
    local properties = {
        Components = {
            get = function ()
                if _components:count() > 0 then
                    local copy = {}

                    for i in _components:ipairs() do
                        copy[i] = _components[i]
                    end

                    return copy
                end
            end,
        },

        Stylesheet = {
            get = function ()
                if not _stylesheet then
                    updateStylesheet()
                end

                return _stylesheet
            end,
        },
    }

    --[[
        Function: Add
            Adds a new Component to the Hover Component.

        Parameters:
            component - The Component to be added.
    ]]
    function self:Add (component)
        if not _components[component.Subtype] then
            _components[component.Subtype] = component
        end
    end

    --[[
        Function: Remove
            Removes a Component from the Hover Component.

        Paramaters:
            subtype - The Subtype of the Component to be removed.
    ]]
    function self:Remove (subtype)
        if _components[subtype] then
            _components[subtype] = nil
        end
    end

    --[[
        Function: Replace
            Replaces a Component in the Hover Component.

        Parameters:
            component - The Component to be added.
    ]]
    function self:Replace (component)
        _components[component.Subtype] = component
    end

    setmetatable(self, {
        __index = function (_, key)
            return (properties[key] and properties[key].get()) or Hover[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set()
            end
        end,
    })

    return self
end

setmetatable(Hover, {
    __index = getmetatable(Hover).__index,
    __call = new,
})

return Hover
