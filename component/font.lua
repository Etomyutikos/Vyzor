--- A Component defining certain text manipulations.
--- @classmod Font

local Base = require("vyzor.base")
local FontDecoration = require("vyzor.enum.font_decoration")
local FontStyle = require("vyzor.enum.font_style")
local FontWeight = require("vyzor.enum.font_weight")

local Font = Base("Component", "Font")

--- Font constructor.
--- @function Font
--- @tparam number|string initialSize The Font Component's initial size. Valid sizes are defined by QT, but I can only seem to get numbers to work.
--- @string initialFamily The font family for this Font Component.
--- @tparam[opt=FontStyle.Normal] FontStyle|FontWeight initialStyle The Font Component's initial style.
--- @tparam[opt] FontDecoration initialDecoration The Font Component's initial FontDecoration.
--- @treturn Font
local function new (_, initialSize, initialFamily, initialStyle, initialDecoration)
    --- @type Font
    local self = {}

    local _size = initialSize
    local _family = initialFamily or "Bitsteam Vera Sans Mono"
    local _style = initialStyle or FontStyle.Normal
    local _decoration = initialDecoration
    local _stylesheet

    local function updateStylesheet ()
        _stylesheet = string.format("font-size: %s; font-family: %s; %s: %s; text-decoration: %s",
            (type(_size) == "number" and tostring(_size) .. "px") or _size,
            _family,
            ((_style and FontStyle:IsValid(_style)) and "font-style")
                or ((_style and FontWeight:IsValid(_style)) and "font-weight"),
            _style or FontStyle.Normal,
            _decoration or FontDecoration.None)
    end

    local properties = {
        Size = {
            --- Returns the Font's size.
            --- @function self.Size.get
            --- @treturn number|string
            get = function ()
                return _size
            end,

            --- Sets the Font's size.
            --- @function self.Size.set
            --- @tparam number|string value If a string is passed, it must end in "px" or "pt".
            set = function (value)
                _size = value
            end,
        },

        Family = {
            --- Returns the Font's family.
            --- @function self.Family.get
            --- @treturn string
            get = function ()
                return _family
            end,

            --- Sets the Font's family.
            --- @function self.Family.set
            --- @tparam string value
            set = function (value)
                _family = value
            end,
        },

        Style = {
            --- Returns the Font's FontStyle.
            --- @function self.Style.get
            --- @treturn FontStyle
            get = function ()
                return _style
            end,

            --- Sets the Font's FontStyle
            --- @function self.Style.set
            --- @tparam FontStyle value
            set = function (value)
                _style = value
            end,
        },

        Decoration = {
            --- Returns the Font's FontDecoration.
            --- @function self.Decoration.get
            --- @treturn FontDecoration
            get = function ()
                return _decoration
            end,

            --- Sets the Font's FontDecoration.
            --- @function self.Decoration.set
            --- @tparam FontDecoration value
            set = function (value)
                _decoration = value
            end,
        },

        Stylesheet = {
            --- Updates and returns the Font's stylesheet.
            --- @function self.Stylesheet.get
            --- @treturn string
            get = function ()
                updateStylesheet()
                return _stylesheet
            end,
        },
    }

    setmetatable(self, {
        __index = function (_, key)
            return (properties[key] and properties[key].get()) or Font[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end
    })

    return self
end

setmetatable(Font, {
    __index = getmetatable(Font).__index,
    __call = new,
})

return Font
