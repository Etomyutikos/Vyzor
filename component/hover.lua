--- This Component defines @{Frame} behaviour on mouse-over and may contain other Components.
--- @classmod Hover

local Base = require("vyzor.base")
local Lib = require("vyzor.lib")

local Hover = Base("Component", "Hover")

--- Hover constructor.
--- @function Hover
--- @tparam[opt] table initialComponents A table of Components to be contained in this Hover Component.
local function new (_, initialComponents)
    --- @type Hover
    local self = {}

    local _components = Lib.OrderedTable()

    if initialComponents then
        for _, component in ipairs(initialComponents) do
            assert(not _components[component.Subtype], "Vyzor: Attempt to add duplicate Component to Hover Component.")
            assert(component.Subtype ~= "Hover", "Vyzor: May not add Hover Component to Hover Component.")

            _components[component.Subtype] = component
        end
    end

    local _stylesheet

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

    --- Properties
    --- @section
    local properties = {
        Components = {
            --- Returns the Hover Component's Components.
            --- @function self.Components.get
            --- @treturn table
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
            --- Updates and returns the Hover Component's stylesheet.
            --- @function self.Stylesheet.get
            --- @treturn string
            get = function ()
                if not _stylesheet then
                    updateStylesheet()
                end

                return _stylesheet
            end,
        },
    }
    --- @section end

    --- Adds a new Component.
    --- @tparam Component component
    function self:Add (component)
        if not _components[component.Subtype] then
            _components[component.Subtype] = component
        end
    end

    --- Removes a Component.
    --- @string subtype The Subtype of the Component to be removed.
    function self:Remove (subtype)
        if _components[subtype] then
            _components[subtype] = nil
        end
    end

    --- Replaces a Component.
    --- @tparam Component component The Component to be added.
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
