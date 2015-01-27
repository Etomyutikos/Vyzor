--- A Supercomponent used only within @{Frame}s to manage space.
-- @classmod Size

local Base = require("vyzor.base")
local BoundingMode = require("vyzor.enum.bounding_mode")

local Size = Base("Supercomponent", "Size")

local function calculateAbsoluteDimension(rawDimension, containerDimension)
  if rawDimension <= 1 and rawDimension > 0 then
    return containerDimension * rawDimension
  elseif rawDimension < 0 then
    return containerDimension + rawDimension
  else
    return rawDimension
  end
end

local function setBoundedDimension(absoluteDimension, maximum, edge, containerEdge)
  if absoluteDimension > maximum then
    return maximum
  elseif edge > containerEdge then
    return absoluteDimension - (edge - containerEdge)
  else
    return absoluteDimension
  end
end

--- Size constructor.
-- @function Size
-- @tparam Frame _frame The @{Frame} to which this Size Supercomponent belongs.
-- @number[opt=1.0] initialWidth Initial width of the @{Frame}.
-- @number[opt=1.0] initialHeight Initial height of the @{Frame}.
-- @bool _isFirst Determines whether or not the parent @{Frame} is the @{HUD}.
-- @treturn Size
local function new (_, _frame, initialWidth, initialHeight, _isFirst)
  --- @type Size
  local self = {}

  local _dimensions = {
    Width = (initialWidth or 1),
    Height = (initialHeight or 1),
  }
  local _absoluteDimensions = {}
  local _contentDimensions = {}

  local function updateContent ()
    -- We must respect QT's Box Model, so we have to find the space the
    -- Content Rectangle occupies.
    -- See: http://doc.qt.nokia.com/4.7-snapshot/stylesheet-customizing.html
    local top = 0
    local right = 0
    local bottom = 0
    local left = 0

    if _frame.Components then
      local border = _frame.Components["Border"]
      if border then
        if border.Top then
          right = right + border.Right.Width
          left = left + border.Left.Width

          top = top + border.Top.Width
          bottom = bottom + border.Bottom.Width
        else
          if type(border.Width) == "table" then
            right = right + border.Width[2]
            left = left + border.Width[4]

            top = top + borders.Width[1]
            bottom = bottom + borders.Width[3]
          else
            right = right + border.Width
            left = left + border.Width

            top = top + border.Width
            bottom = bottom + border.Width
          end
        end
      end

      local margin = _frame.Components["Margin"]
      if margin then
        right = right + margin.Right
        left = left + margin.Left

        top = top + margin.Top
        bottom = bottom + margin.Bottom
      end

      local padding = _frame.Components["Padding"]
      if padding then
        right = right + padding.Right
        left = left + padding.Left

        top = top + padding.Top
        bottom = bottom + padding.Bottom
      end
    end

    _contentDimensions = {
      Width = _absoluteDimensions.Width - (right + left),
      Height = _absoluteDimensions.Height - (top + bottom)
    }
  end

  local function updateAbsolute ()
    -- Is HUD.
    if _isFirst then
      _absoluteDimensions = _dimensions
      _contentDimensions = _dimensions
      return
    end

    assert(_frame.Container, "Vyzor: Frame must have container before Size can be determined.")

    local frameContainer = _frame.Container
    local containerPosition = frameContainer.Position.Content
    local containerSize = frameContainer.Size.Content

    _absoluteDimensions.Width = calculateAbsoluteDimension(_dimensions.Width, containerSize.Width)
    _absoluteDimensions.Height = calculateAbsoluteDimension(_dimensions.Height, containerSize.Height)

    if frameContainer.IsBounding and _frame.BoundingMode == BoundingMode.Size then
      _absoluteDimensions.Width = setBoundedDimension(
        _absoluteDimensions.Width,
        containerSize.Width,
        _frame.Position.AbsoluteX + _absoluteDimensions.Width,
        containerPosition.X + containerSize.Width)

      _absoluteDimensions.Height = setBoundedDimension(_absoluteDimensions.Height,
        containerSize.Height,
        _frame.Position.AbsoluteY + _absoluteDimensions.Height,
        containerPosition.Y + containerSize.Width)
    end

    updateContent()
  end

  --- Properties
  --- @section
  local properties = {
    Dimensions = {
      --- Returns the user-defined dimensions of the @{Frame}.
      -- @function self.Dimensions.get
      -- @treturn table
      get = function ()
        local copy = {}

        for i in pairs(_dimensions) do
          copy[i] = _dimensions[i]
        end

        return copy
      end,

      --- Sets the user-defined dimensions of the @{Frame}.
      -- @function self.Dimensions.set
      -- @tparam table value
      set = function (value)
        _dimensions.Width = value.Width or value[1]
        _dimensions.Height = value.Height or value[2]
        updateAbsolute()
      end
    },

    Absolute = {
      --- Returns the actual dimensions of the @{Frame}.
      -- @function self.Absolute.get
      -- @treturn table
      get = function ()
        if not _absoluteDimensions.Width or not _absoluteDimensions.Height then
          updateAbsolute()
        end

        local copy = {}

        for i in pairs(_absoluteDimensions) do
          copy[i] = _absoluteDimensions[i]
        end

        return copy
      end
    },

    Content = {
      --- Returns the content dimensions of the @{Frame}.
      -- @function self.Content.get
      -- @treturn table
      get = function ()
        if not _contentDimensions.Width or not _contentDimensions.Height then
          updateAbsolute()
        end

        local copy = {}

        for i in pairs(_absoluteDimensions) do
          copy[i] = _contentDimensions[i]
        end

        return copy
      end
    },

    Width = {
      --- Returns the user-defined width of the @{Frame}.
      -- @function self.Width.get
      -- @treturn number
      get = function ()
        return _dimensions.Width
      end,

      --- Sets the user-defined width of the @{Frame}.
      -- @function self.Width.set
      -- @tparam number value
      set = function (value)
        _dimensions.Width = value

        if _frame.Container.IsDrawn then
          updateAbsolute()
        end
      end
    },

    Height = {
      --- Returns the user-defined height of the @{Frame}.
      -- @function self.Height.get
      -- @treturn number
      get = function ()
        return _dimensions.Height
      end,

      --- Sets the user-defined height of the @{Frame}.
      -- @function self.Height.set
      -- @tparam number value
      set = function (value)
        _dimensions.Height = value

        if _frame.Container.IsDrawn then
          updateAbsolute()
        end
      end
    },

    AbsoluteWidth = {
      --- Returns the actual width of the @{Frame}.
      -- @function self.AbsoluteWidth.get
      -- @treturn number
      get = function ()
        if not _absoluteDimensions.Width then
          updateAbsolute()
        end

        return _absoluteDimensions.Width
      end
    },

    AbsoluteHeight = {
      --- Returns the actual height of the @{Frame}.
      -- @function self.AbsoluteHeight.get
      -- @treturn number
      get = function ()
        if not _absoluteDimensions.Height then
          updateAbsolute()
        end

        return _absoluteDimensions.Height
      end
    },

    ContentWidth = {
      --- Returns the width of the @{Frame}'s content.
      -- @function self.ContentWidth.get
      -- @treturn number
      get = function ()
        if not _contentDimensions.Width then
          updateAbsolute()
        end

        return _contentDimensions.Width
      end
    },

    ContentHeight = {
      --- Returns the height of the @{Frame}'s content.
      -- @function self.ContentHeight.get
      -- @treturn number
      get = function ()
        if not _contentDimensions.Height then
          updateAbsolute()
        end

        return _contentDimensions.Height
      end
    },
  }
  --- @section end

  setmetatable(self, {
    __index = function (_, key)
      return (properties[key] and properties[key].get()) or Size[key]
    end,
    __newindex = function (_, key, value)
      if properties[key] and properties[key].set then
        properties[key].set(value)
      end
    end,
  })

  return self
end

setmetatable(Size, {
  __index = getmetatable(Size).__index,
  __call = new,
})

return Size
