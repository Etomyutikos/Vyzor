--- A Component container that holds either a @{Color} or @{Gradient} Component.
-- @classmod Brush

local Base = require("vyzor.base")

local Brush = Base("Component", "Brush")

--- Brush constructor.
-- @function Brush
-- @tparam Color|Gradient initialContent The initial content of this Brush Component.
-- @treturn Brush
local function new ( _, initialContent)
    --- @type Brush
    local self = {}

    local _content = initialContent

    --- Properties
    --- @section
    local properties = {
        Content = {
            --- Returns the content this Brush contains.
            --- @function self.Content.get
            --- @treturn Color|Gradient
            get = function ()
                return _content
            end,

            --- Sets the content this Brush contains.
            --- @function self.Content.set
            --- @tparam Color|Gradient value
            set = function (value)
                _content = value
            end
        },

        Stylesheet = {
            --- Updates and returns the Brush's stylesheet.
            --- @function self.Stylesheet.get
            --- @treturn string
            get = function ()
                return _content.Stylesheet
            end,
        },
    }
    --- @section end

    setmetatable(self, {
        __index = function (_, key)
            return (properties[key] and properties[key].get()) or Brush[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end
    })

    return self
end

setmetatable(Brush, {
    __index = getmetatable(Brush).__index,
    __call = new
})

return Brush

