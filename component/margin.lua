--- This Component defines the Margin of a @{Frame}.
-- The Margin is the exterior part of the @{Frame}.
--
-- See http://doc.qt.nokia.com/4.7-snapshot/stylesheet-customizing.html.
-- @classmod Margin

local Base = require("vyzor.base")

local Margin = Base("Component", "Margin")

--- Margin constructor.
-- @function Margin
-- @param ... A list of numbers defining the size of each side of the Margin.
-- @treturn Margin
local function new (_, ...)
  local arg = { ... }
  if not arg[1] then
    error("Vyzor: Must pass at least one size to new Margin.", 2)
  end

  --- @type Margin
  local self = {}

  local _top = arg[1]
  local _right = arg[2] or _top
  local _bottom = arg[3] or _top
  local _left = arg[4] or _right
  local _stylesheet

  local function updateStylesheet ()
    _stylesheet = string.format("margin: %s", table.concat({ _top, _right, _bottom, _left }, " "))
  end

  --- Properties
  --- @section
  local properties = {
    Top = {
      --- Returns the size of the Margin's top.
      -- @function self.Top.get
      -- @treturn number
      get = function ()
        return _top
      end,

      --- Sets the size of the Margin's top.
      -- @function self.Top.set
      -- @tparam number value
      set = function (value)
        _top = value
      end,
    },

    Right = {
      --- Returns the size of the Margin's right.
      -- @function self.Right.get
      -- @treturn number
      get = function ()
        return _right
      end,

      --- Sets the size of the Margin's right.
      -- @function self.Right.set
      -- @tparam number value
      set = function (value)
        _right = value
      end,
    },

    Bottom = {
      --- Returns the size of the Margin's bottom.
      -- @function self.Bottom.get
      -- @treturn number
      get = function ()
        return _bottom
      end,

      --- Sets the size of the Margin's bottom.
      -- @function self.Bottom.set
      -- @tparam number value
      set = function (value)
        _bottom = value
      end,
    },

    Left = {
      --- Returns the size of the Margin's left.
      -- @function self.Left.get
      -- @treturn number
      get = function ()
        return _left
      end,

      --- Sets the size of the Margin's left.
      -- @function self.Left.set
      -- @tparam number value
      set = function (value)
        _left = value
      end,
    },

    Stylesheet = {
      --- Updates and returns the Margin's stylesheet.
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
      return (properties[key] and properties[key].get()) or Margin[key]
    end,
    __newindex = function (_, key, value)
      if properties[key] and properties[key].set then
        properties[key].set(value)
      end
    end,
  })

  return self
end

setmetatable(Margin, {
  __index = getmetatable(Margin).__index,
  __call = new,
})

return Margin
