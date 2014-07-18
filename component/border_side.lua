--- A subcomponent that defines individual sides of a Border Component.
--- @classmod BorderSide

local Base = require("vyzor.base")
local BorderStyle = require("vyzor.enum.border_style")

local BorderSide = Base("Subcomponent", "BorderSide")

--- Border constructor.
--- @function Border
--- @number initialWidth The BorderSide's initial width.
--- @tparam[opt=BorderStyle.None] BorderStyle initialStyle The BorderSide's initial BorderStyle.
--- @tparam Brush|Image initialContent The BorderSide's initial Brush or Image.
--- @number initialRadius The radius of the BorderSide's corners. Only relevant for top and bottom BorderSides.
--- @treturn BorderSide
local function new (_, initialWidth, initialStyle, initialContent, initialRadius)
    --- @type BorderSide
    local self = {}

    local _isSide = false
    local _width = initialWidth or 0
    local _style = initialStyle or BorderStyle.None
    local _content = initialContent
    local _radius = initialRadius or 0
    local _styleTable

    local function updateStyleTable()
        _styleTable = {
            string.format("width: %s", _width),
            string.format("style: %s", _style),
        }

        if _content then
            _styleTable[#_styleTable +1] = string.format("%s: %s",
                (_content.Subtype == "Brush" and _content.Stylesheet) or
                (_content.Subtype == "Image" and string.format("image: %s", _content.Url)))

            if _content.Subtype == "Image" then
                _styleTable[#_styleTable +1] = string.format("image-position: %s", _content.Alignment)
            end
        end

        if not _isSide then
            if type(_radius == "table") then
                _styleTable[#_styleTable +1] = string.format("left-radius: %s", _radius[1])
                _styleTable[#_styleTable +1] = string.format("right-radius: %s", _radius[2])
            else
                _styleTable[#_styleTable +1] = string.format("radius: %s", _radius)
            end
        end
    end

    local properties = {
        Width = {
            --- Returns the BorderSide's width.
            --- @function self.Width.get
            --- @treturn number
            get = function ()
                return _width
            end,

            --- Sets the BorderSide's width.
            --- @function self.Width.set
            --- @tparam number value
            set = function (value)
                _width = value
            end,
        },

        Style = {
            --- Returns the BorderSide's BorderStyle.
            --- @function self.Style.get
            --- @treturn BorderStyle
            get = function ()
                return _style
            end,

            --- Sets the BorderSide's BorderStyle.
            --- @function self.Style.set
            --- @tparam BorderStyle value
            set = function (value)
                if BorderStyle:IsValid(value) then
                    _style = value
                end
            end,
        },

        Content = {
            --- Returns the BorderSide's content.
            --- @function self.Content.get
            --- @treturn Image|Brush
            get = function ()
                return _content
            end,

            --- Sets the BorderSide's content.
            --- @function self.Content.set
            --- @tparam Image|Brush value
            set = function (value)
                _content = value
            end,
        },

        Radius = {
            --- Returns the BorderSide's corner radius.
            --- @function self.Radius.get
            --- @treturn number
            get = function ()
                return _radius
            end,

            --- Sets the BorderSide's corner radius. Only useful for top and bottom BorderSides.
            --- @function self.Radius.set
            --- @tparam number value
            set = function (value)
                _radius = value
            end,
        },

        IsSide = {
            --- If true, this is a left or right BorderSide. If false, it is a top or bottom BorderSide.
            --- @function self.IsSide.get
            --- @treturn bool
            get = function ()
                return _isSide
            end,

            --- Sets a flag determining whether this is a left or right BorderSide, or a top or bottom.
            --- @function self.IsSide.set
            --- @tparam bool value
            set = function (value)
                _isSide = value
            end,
        },

        Styletable = {
            --- Updates and returns the BorderSide's styletable.
            --- @function self.Styletable.get
            --- @treturn table
            get = function ()
                if not _styleTable then
                    updateStyleTable()
                end

                return _styleTable
            end,
        },
    }

    setmetatable(self, {
        __index = function (_, key)
            return (properties[key] and properties[key].get()) or BorderSide[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end,
        })

    return self
end

setmetatable(BorderSide, {
    __index = getmetatable(BorderSide).__index,
    __call = new
})

return BorderSide
