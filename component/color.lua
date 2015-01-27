--- A Component that defines color information.
-- Used primarily in a @{Brush} Component.
-- @classmod Color

local Base = require("vyzor.base")
local ColorMode = require("vyzor.enum.color_mode")

local Color = Base("Component", "Color")

--- Color constructor.
-- Expected arguments differ depending on mode.
--
-- RGB and HSV modes expect a comma-separated list of 3 - 4 numbers.
--
-- Name mode expects a single string.
--
-- Hex mode expects a single Hex string.
-- @function Color
-- @tparam ColorMode _mode Determines handling of color data.
-- @param ... Color data. See description.
-- @treturn Color
local function new (_, _mode, ...)
  local arg = { ... }

  --- @type Color
  local self = {}

  local _colorData

  if _mode:find(ColorMode.RGB) then
    _colorData = {
      red = arg[1],
      blue = arg[2],
      green = arg[3],
      alpha = (arg[4] or 255)
    }
  elseif _mode:find(ColorMode.HSV) then
    _colorData = {
      hue = arg[1],
      saturation = arg[2],
      value = arg[3],
      alpha = (arg[4] or 255)
    }
  elseif _mode:match(ColorMode.Name) then
    _colorData = arg[1]
  elseif _mode:match(ColorMode.Hex) then
    if not arg[1]:find("#") then
      _colorData = "#" .. arg[1]
    else
      _colorData = arg[1]
    end
  end

  local _stylesheet

  local function updateStylesheet ()
    if _mode:find(ColorMode.RGB) then
      _stylesheet = string.format("color: rgba(%s, %s, %s, %s)",
        _colorData.red,
        _colorData.blue,
        _colorData.green,
        _colorData.alpha)
    elseif _mode:find(ColorMode.HSV) then
      _stylesheet = string.format("color: hsva(%s, %s, %s, %s)",
        _colorData.hue,
        _colorData.saturation,
        _colorData.value,
        _colorData.alpha)
    elseif _mode:match(ColorMode.Name) then
      _stylesheet = string.format("color: %s", _colorData)
    elseif _mode:match(ColorMode.Hex) then
      _stylesheet = string.format("color: %s", _colorData)
    end
  end

  --- Properties
  --- @section
  local properties = {
    Mode = {
      --- Returns the @{ColorMode} of this Color.
      -- @function self.Mode.get
      -- @treturn ColorMode
      get = function ()
        return _mode
      end
    },

    Data = {
      --- Returns the color data used to construct this Color Component.
      -- @function self.Data.get
      -- @treturn string|table
      get = function ()
        if type(_colorData) == "table" then
          local copy = {}

          for i in pairs(_colorData) do
            copy[i] = _colorData[i]
          end

          return copy
        else
          return _colorData
        end
      end
    },

    Stylesheet = {
      --- Updates and returns the stylesheet for this Color Component.
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
      return (properties[key] and properties[key].get()) or Color[key]
    end,
    __newindex = function (_, key, value)
      if properties[key] and properties[key].set then
        properties[key].set(value)
      end
    end
  })

  return self
end

setmetatable(Color, {
  __index = getmetatable(Color).__index,
  __call = new
})

return Color
