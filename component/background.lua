--- Defines a @{Frame}'s Background.
-- @classmod Background

local Base = require("vyzor.base")
local Alignment = require("vyzor.enum.alignment")
local Repeat = require("vyzor.enum.repeat")

local Background = Base("Component", "Background")

--- Background Constructor
-- @function Background
-- @tparam Brush|Image initialContent What the Background displays.
-- @tparam[opt=Alignment.TopLeft] Alignment initialAlignment Where the content sits in the Background.
-- @tparam[opt=Repeat.RepeatXY] Repeat initialRepeatMode Tiling rules for the content.
-- @treturn Background
local function new (_, initialContent, initialAlignment, initialRepeatMode)
    --- @type Background
    local self = {}

    local _content = initialContent
    local _alignment = (initialAlignment or Alignment.TopLeft)
    local _repeatMode = (initialRepeatMode or Repeat.RepeatXY)
    local _stylesheet

    local function updateStylesheet ()
        local styleTable = {
            string.format("background-position: %s", _alignment),
            string.format("background-repeat: %s", _repeatMode),
        }

        if _content then
            if _content.Subtype == "Brush" then
                if _content.Content.Subtype == "Gradient" then
                    styleTable[#styleTable + 1] = string.format("background: %s", _content.Stylesheet)
                else
                    styleTable[#styleTable + 1] = string.format("background-%s", _content.Stylesheet)
                end
            else
                styleTable[#styleTable + 1] = string.format("background-image: %s", _content.Url)
            end
        end

        _stylesheet = table.concat(styleTable, "; ")
    end

    --- Properties
    --- @section
    local properties = {
        Content = {
            --- Returns the @{Image} or @{Brush} used in the Background.
            --- @function self.Content.get
            --- @treturn Image|Brush
            get = function ()
                return _content
            end,

            --- Sets the @{Image} or @{Brush} used in the Background.
            --- @function self.Content.set
            --- @tparam Image|Brush value
            set = function (value)
                _content = value
            end,
        },

        Alignment = {
            --- Returns the Background's content @{Alignment}.
            --- @function self.Alignment.get
            --- @treturn Alignment
            get = function ()
                return _alignment
            end,

            --- Sets the Background's content @{Alignment}.
            --- @function self.Alignment.set
            --- @tparam Alignment value
            set = function (value)
                if Alignment:IsValid(value) then
                    _alignment = value
                end
            end
        },

        Repeat = {
            --- Returns the Background's content tiling rules.
            --- @function self.Repeat.get
            --- @treturn Repeat
            get = function ()
                return _repeatMode
            end,

            --- Sets the Background's content tiling rules.
            --- @function self.Repeat.set
            --- @tparam Repeat value
            set = function (value)
                if Repeat:IsValid(value) then
                    _repeatMode = value
                end
            end
        },

        Stylesheet = {
            --- Updates and returns the Background's stylesheet.
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
            return (properties[key] and properties[key].get()) or Background[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end
        })

    return self
end

setmetatable(Background, {
    __index = getmetatable(Background).__index,
    __call = new,
    })

return Background
