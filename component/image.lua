-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require("vyzor.base")
local Alignment = require("vyzor.enum.alignment")

--[[
    Class: Image
        Defines an Image Component.
]]
local Image = Base("Component", "Image")

--[[
    Constructor: new

    Parameters:
        _url - The filepath of the image used by the Image Component.
        initialAlignment - The <Alignment> of the Image within the <Frame>. Defaults to top-left.

    Returns:
        A new Image Component.
]]
local function new (_, _url, initialAlignment)
    assert(type(_url) == "string", "Vyzor: Url's must be strings.")

    --[[
        Structure: New Image
            This Components hold image data.
    ]]
    local self = {}

    -- Object: _alignment
    -- An Alignment Enum, determing positioning of the image.
    local _alignment = (Alignment:IsValid(initialAlignment) and initialAlignment) or Alignment.TopLeft

    -- String: stylesheet
    -- The Image Component's stylesheet. Generated via <updateStylesheet>.
    local _stylesheet

    --[[
        Function: updateStylesheet
            Updates the Image's <stylesheet>.
            You'll notice, in other Components that use
            Image, that they call <Url> directly. This is
            because an image is handled different by QT
            when it's used directly in a Frame as opposed
            to a <Background> or <Border>.
    ]]
    local function updateStylesheet ()
        _stylesheet = string.format("image: url(%s); image-position: %s", _url, _alignment)
    end

    --[[
        Properties: Image Properties
            Url - Returns the Image's filepath, made Stylesheet appropriate.
            RawUrl - Returns the Image's filepath.
            Alignment - Gets and sets the Image Component's Alignment.
            Stylesheet - Updates and returns the Image Component's <stylesheet>.
    ]]
    local properties = {
        Url = {
            get = function ()
                return string.format("url(%s)", _url)
            end
        },

        RawUrl = {
            get = function ()
                return _url
            end,
        },

        Alignment = {
            get = function ()
                return _alignment
            end,
            set = function (value)
                assert(Alignment:IsValid(value), "Vyzor: Alignment option passed to Image is invalid.")

                _alignment = value
            end
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

    setmetatable(self, {
        __index = function (_, key)
            return (properties[key] and properties[key].get()) or Image[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end
    })

    return self
end

setmetatable(Image, {
    __index = getmetatable(Image).__index,
    __call = new
})

return Image
