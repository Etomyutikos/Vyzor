--- This Component holds image data.
-- @classmod Image

local Base = require("vyzor.base")
local Alignment = require("vyzor.enum.alignment")

local Image = Base("Component", "Image")

--- Image constructor.
-- @function Image
-- @string _url The filepath of the image used by the Image Component.
-- @tparam[opt=Alignment.TopLeft] Alignment initialAlignment The @{Alignment} of the Image within the @{Frame}.
-- @treturn Image
local function new (_, _url, initialAlignment)
  assert(type(_url) == "string", "Vyzor: Url's must be strings.")

  --- @type Image
  local self = {}

  local _alignment = (Alignment:IsValid(initialAlignment) and initialAlignment) or Alignment.TopLeft

  local _stylesheet

  local function updateStylesheet ()
    _stylesheet = string.format("image: url(%s); image-position: %s", _url, _alignment)
  end

  --- Properties
  --- @section
  local properties = {
    Url = {
      --- Returns the Image's filepath, made stylesheet appropriate.
      --
      -- Other Components use this property, instead of Stylesheet.
      -- @function self.Url.get
      -- @treturn string
      get = function ()
        return string.format("url(%s)", _url)
      end
    },

    RawUrl = {
      --- Returns the Image's filepath.
      -- @function self.RawUrl.get
      -- @treturn string
      get = function ()
        return _url
      end,
    },

    Alignment = {
      --- Returns the Image's @{Alignment}.
      -- @function self.Alignment.get
      -- @treturn Alignment
      get = function ()
        return _alignment
      end,

      --- Sets the Image's @{Alignment}.
      -- @function self.Alignment.set
      -- @tparam Alignment value
      set = function (value)
        assert(Alignment:IsValid(value), "Vyzor: Alignment option passed to Image is invalid.")

        _alignment = value
      end
    },

    Stylesheet = {
      --- Updates and returns the Image's stylesheet.
      -- @function self.Stylesheet.get
      -- @treturn string
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
