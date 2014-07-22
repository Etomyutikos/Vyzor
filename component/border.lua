--- A Component that defines a @{Frame}'s Border.
--- @classmod Border

local Base = require("vyzor.base")
local BorderSide = require("vyzor.component.border_side")
local BorderStyle = require("vyzor.enum.border_style")

local Border = Base("Component", "Border")

local function getWidthString(width)
    if type(width) == "table" then
        local widthTable = {
            string.format("border-top-width: %s", width[1]),
            string.format("border-right-width: %s", width[2]),
            string.format("border-bottom-width: %s", width[3]),
            string.format("border-left-width: %s", width[4])
        }

        return table.concat(widthTable, "; ")
    else
        return string.format("border-width: %s", width)
    end
end

--- Border constructor.
--- @function Border
--- @tparam number|table initialWidth The Border Component's initial width. May be a number or a table of numbers.
--- @tparam[opt=BorderStyle.None] BorderStyle initialStyle The Border Component's initial @{BorderStyle}.
--- @tparam Image|Brush|table initialContent The Border Component's initial content.
--- @tparam[opt=0] number|table initialRadius The Border Component's initial radius, for rounded corners.
--- @tparam table initialBorders The Border Component's initial @{BorderSide} Subcomponents. Must be a table containing one to four @{BorderSide}s.
--- @treturn Border
local function new (_, initialWidth, initialStyle, initialContent, initialRadius, initialBorders)
    --- @type Border
    local self = {}

    local _width = initialWidth or 0
    local _style = initialStyle or BorderStyle.None
    local _content = initialContent
    local _radius = initialRadius or 0
    local _borders

    if initialBorders and type(initialBorders) == "table" then
        local defaultSide = BorderSide(_width, _style, _content, _radius)

        _borders = {}
        _borders["top"] = initialBorders["top"] or initialBorders[1] or defaultSide
        _borders["right"] = initialBorders["right"] or initialBorders[2] or defaultSide
        _borders["bottom"] = initialBorders["bottom"] or initialBorders[3] or defaultSide
        _borders["left"] = initialBorders["left"] or initialBorders[4] or defaultSide
    end

    local _stylesheet

    local function updateStylesheet ()
        local styleTable = {
            getWidthString(_width),
            string.format("border-style: %s", _style),
            string.format("border-radius: %s", _radius),
        }

        if _content then
            styleTable[#styleTable + 1] = string.format("border-%s",
                (_content.Subtype == "Brush" and _content.Stylesheet) or
                (_content.Subtype == "Image" and string.format("image: %s", _content.Url)))

            if _content.Subtype == "Image" then
                styleTable[#styleTable +1] = string.format("border-image-position: %s", _content.Alignment)
            end
        end

        if _borders then
            for _, side in ipairs({"top", "right", "bottom", "left"}) do
                for _, sideStyleTable in ipairs(_borders[side].Styletable) do
                    styleTable[#styleTable +1] = string.format("border-%s-%s", side, sideStyleTable)
                end
            end
        end

        _stylesheet = table.concat(styleTable, "; ")
    end

    --- Properties
    --- @section
    local properties = {
        Style = {
            --- Returns the Border's @{BorderStyle}.
            --- @function self.Style.get
            --- @treturn BorderStyle
            get = function ()
                return _style
            end,

            --- Sets the Border's @{BorderStyle}.
            --- @function self.Style.set
            --- @tparam BorderStyle value
            set = function (value)
                assert(BorderStyle:IsValid(value), "Vyzor: Invalid BorderStyle passed to Border.")
                _style = value
            end,
        },

        Width = {
            --- Returns the Border's width.
            --- @function self.Width.get
            --- @treturn number|table
            get = function ()
                if type(_width) == "table" then
                    local copy = {}

                    for i in ipairs(_width) do
                        copy[i] = _width[i]
                    end

                    return copy
                else
                    return _width
                end
            end,

            --- Sets the Border's width.
            --- @function self.Width.set
            --- @tparam number|table value
            set = function (value)
                _width = value
            end,
        },

        Content = {
            --- Returns the Border's content.
            --- @function self.Content.get
            --- @treturn Image|Brush|table
            get = function ()
                if type(_content) ~= "table" then
                    return _content
                else
                    local copy = {}

                    for i in ipairs(_content) do
                        copy[i] = _content[i]
                    end

                    return copy
                end
            end,

            --- Sets the Border's content.
            --- @function self.Content.set
            --- @param Image|Brush|table value
            set = function (value)
                _content = value
            end,
        },

        Top = {
            --- Returns the Border's top @{BorderSide} Component.
            --- @function self.Top.get
            --- @treturn table
            get = function ()
                return (_borders and _borders["top"]) or nil
            end,

            --- Sets the Border's top @{BorderSide} Component.
            --- @function self.Top.set
            --- @tparam BorderSide value
            set = function (value)
                _borders["top"] = value
            end
        },

        Right = {
            --- Returns the Border's right @{BorderSide} Component.
            --- @function self.Right.get
            --- @treturn table
            get = function ()
                return (_borders and _borders["right"]) or nil
            end,

            --- Sets the Border's right @{BorderSide} Component.
            --- @function self.Right.set
            --- @tparam BorderSide value
            set = function (value)
                _borders["right"] = value
            end
        },

        Bottom = {
            --- Returns the Border's bottom @{BorderSide} Component.
            --- @function self.Bottom.get
            --- @treturn table
            get = function ()
                return (_borders and _borders["bottom"]) or nil
            end,

            --- Sets the Border's bottom @{BorderSide} Component.
            --- @function self.Bottom.set
            --- @tparam BorderSide value
            set = function (value)
                _borders["bottom"] = value
            end
        },

        Left = {
            --- Returns the Border's left @{BorderSide} Component.
            --- @function self.Left.get
            --- @treturn table
            get = function ()
                return (_borders and _borders["left"]) or nil
            end,

            --- Sets the Border's left @{BorderSide} Component.
            --- @function self.Left.set
            --- @tparam BorderSide value
            set = function (value)
                _borders["left"] = value
            end
        },

        Stylesheet = {
            --- Updates and returns the Border's stylesheet.
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

    setmetatable(self, {
        __index = function (_, key)
            return (properties[key] and properties[key].get()) or Border[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end,
    })

    return self
end

setmetatable(Border, {
    __index = getmetatable(Border).__index,
    __call = new,
})

return Border
