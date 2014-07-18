--- The base object from which all other Vyzor objects are derived.
--- Defines type handling.
--- Internal.
--- @classmod Base

local Base = {}

--- Base constructor.
--- @function Base
--- @string _type The new object's type.
--- @string _subtype The new object's subtype.
--- #treturn Base
local function new (_, _type, _subtype)
    --- @type Base
    local self = {}

    local properties = {
        Type = {
            --- Returns the object's type.
            --- @function self.Type.get
            --- @treturn string
            get = function ()
                return _type
            end
        },

        Subtype = {
            --- Returns the object's subtype.
            --- @function self.Subtype.get
            --- @treturn string
            get = function ()
                return _subtype
            end
            }
        }

    setmetatable(self, {
        __index = function (_, key)
            return (properties[key] and properties[key].get()) or Base[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set( value )
            end
        end,
    })

    return self
end

setmetatable(Base, {
    __call = new,
})

return Base
