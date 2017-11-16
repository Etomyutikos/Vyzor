--- The primary container for Vyzor Components.
-- @classmod Frame

local Base = require("vyzor.base")
local Lib = require("vyzor.lib")
local Options = require("vyzor.base.options")
local Position = require("vyzor.component.position")
local Size = require("vyzor.component.size")
local BoundingMode = require("vyzor.enum.bounding_mode")

local Frame = Base("Frame")

local _FirstFrame = true
local _ResizeRegistered = false
local _MasterList = {}

--- Frame constructor.
-- @function Frame
-- @string _name The name of the Frame, used for addressing.
-- @number _x Initial X position of the Frame. Defaults to 0.
-- @number _y Initial Y position of the Frame. Defaults to 0.
-- @number _width Initial width of the Frame. Defaults to 1.
-- @number _height Initial height of the Frame. Defaults to 1.
-- @treturn Frame
local function new(_, _name, _x, _y, _width, _height)
  --- @type Frame
  local self = {}

  local _isFirst = _FirstFrame
  _FirstFrame = false

  local _isDrawn = false
  local _isBounding = false
  local _isPlaceholder = false
  local _boundingType = BoundingMode.Size
  local _parent
  local _components = Lib.OrderedTable()
  local _miniConsoles = Lib.OrderedTable()
  local _compounds = Lib.OrderedTable()
  local _children = Lib.OrderedTable()
  local _callback
  local _callbackArguments
  local _position = Position(self, _x, _y, _isFirst)
  local _size = Size(self, _width, _height, _isFirst)
  local _stylesheet

  local function updateStylesheet()
    if _components:count() > 0 then
      local styleTable = {}

      for component in _components:each() do
        local componentSubtype = component.Subtype

        -- Hover is a special case. It must be last, and it will
        -- contain its own components. So we save it for last.
        if componentSubtype ~= "Hover" or componentSubtype ~= "MiniConsole" or componentSubtype ~= "Map" then
          styleTable[#styleTable + 1] = component.Stylesheet
        end
      end
      styleTable[#styleTable + 1] = _components["Hover"] and _components["Hover"].Stylesheet

      _stylesheet = table.concat(styleTable, "; ")
      _stylesheet = string.format("%s;", _stylesheet)
    end
  end

  local function updateStylesheetIfDrawn()
    if _isDrawn then
      updateStylesheet()

      if _stylesheet then
        setLabelStyleSheet(_name, _stylesheet)
      end
    end
  end

  local properties = {
    Name = {
      --- Returns the Frame's name.
      -- @function self.Name.get
      -- @treturn string
      get = function()
        return _name
      end
    },
    IsBounding = {
      --- Returns whether or not the Frame is bounding.
      -- @function self.IsBounding.get
      -- @treturn bool
      get = function()
        return _isBounding
      end,
      --- Sets whether or not the Frame is bounding.
      -- @function self.IsBounding.set
      -- @bool value
      set = function(value)
        _isBounding = value
      end
    },
    BoundingMode = {
      --- Returns the @{BoundingMode} for the Frame.
      -- @function self.BoundingMode.get
      -- @treturn BoundingMode
      get = function()
        return _boundingType
      end,
      --- Sets the @{BoundingMode} for this Frame.
      -- @function self.BoundingMode.set
      -- @tparam BoundingMode value
      set = function(value)
        _boundingType = value
      end
    },
    Container = {
      --- Returns the parent Frame.
      -- @function self.Container.get
      -- @treturn Frame
      get = function()
        return _parent
      end,
      --- Sets the parent Frame.
      -- Raises the sysWindowResizeEvent upon completion.
      -- @function self.Container.set
      -- @tparam Frame value
      set = function(value)
        if type(value) == "string" then
          _parent = _MasterList[value]
        else
          _parent = value
        end

        if not value then
          hideWindow(_name)
        end

        if _isDrawn then
          raiseEvent("sysWindowResizeEvent")
        end
      end
    },
    Components = {
      --- Returns the Components in the Frame.
      -- @function self.Components.get
      -- @treturn table
      get = function()
        if _components:count() > 0 then
          local copy = {}

          for subType, component in _components:pairs() do
            copy[subType] = component
          end

          return copy
        end
      end
    },
    MiniConsoles = {
      --- Returns the MiniConsoles in the Frame.
      -- @function self.MiniConsoles.get
      -- @treturn table
      get = function()
        if _miniConsoles:count() > 0 then
          local copy = {}

          for name, miniConsole in _miniConsoles:pairs() do
            copy[name] = miniConsole
          end

          return copy
        end
      end
    },
    Compounds = {
      --- Returns the Compounds in the Frame.
      -- @function self.Compounds.get
      -- @treturn table
      get = function()
        if _compounds:count() > 0 then
          local copy = {}

          for subtype, compound in _compounds:pairs() do
            copy[subtype] = compound
          end
          return copy
        end
      end
    },
    Frames = {
      --- Returns the Frames in the Frame.
      -- @function self.Frames.get
      -- @treturn table
      get = function()
        if _children:count() > 0 then
          local copy = {}

          for name, child in _children:pairs() do
            copy[name] = child
          end

          return copy
        end
      end
    },
    Position = {
      --- Returns the @{Position} supercomponent.
      -- @function self.Position.get
      -- @treturn Position
      get = function()
        return _position
      end
    },
    Size = {
      --- Returns the @{Size} supercomponent.
      -- @function self.Size.get
      -- @treturn Size
      get = function()
        return _size
      end
    },
    Stylesheet = {
      --- Updates and returns the stylesheet for the Frame.
      -- @function self.Stylesheet.get
      -- @treturn string
      get = function()
        if not _stylesheet then
          updateStylesheet()
        end

        return _stylesheet
      end
    },
    Callback = {
      --- Returns the callback for the Frame.
      -- @function self.Callback.get
      -- @treturn string
      get = function()
        return _callback
      end,
      --- Sets the callback for the Frame to be used when clicked.
      -- @function self.Callback.set
      -- @string value The function identifier, globally indexed.
      set = function(value)
        _callback = value

        if _callback and _callbackArguments then
          if type(_callbackArguments) == "table" then
            setLabelClickCallback(_name, _callback, unpack(_callbackArguments))
          else
            setLabelClickCallback(_name, _callback, _callbackArguments)
          end
        else
          setLabelClickCallback(_name, _callback)
        end
      end
    },
    CallbackArguments = {
      --- Returns the callback arguments passed to the callback.
      -- @function self.CallbackArguments.get
      -- @treturn table|string
      get = function()
        return _callbackArguments
      end,
      --- Sets the callback arguments to be passed to the callback.
      -- @function self.CallbackArguments.set
      -- @tparam table|string value A table of arguments or a single argument.
      set = function(value)
        _callbackArguments = value

        if _callback and _callbackArguments then
          if type(_callbackArguments) == "table" then
            setLabelClickCallback(_name, _callback, unpack(_callbackArguments))
          else
            setLabelClickCallback(_name, _callback, _callbackArguments)
          end
        end
      end
    },
    IsDrawn = {
      --- Returns a flag signalling whether or not the Frame has been drawn.
      -- @function self.IsDrawn.get
      -- @treturn bool
      get = function()
        return _isDrawn
      end
    },
    IsPlaceholder = {
      --- Returns a flag signaling whether or not a label will be drawn for this Frame.
      -- @function self.IsPlaceholder.get
      -- @treturn bool
      get = function()
        return _isPlaceholder
      end,
      --- Toggles whether or not to draw a label for this Frame.
      -- @function self.IsPlaceholder.set
      -- @tparam bool value
      set = function(value)
        _isPlaceholder = value
      end
    }
  }

  local function addComponent(component)
    if component.Subtype == "MiniConsole" then
      _miniConsoles[component.Name] = component
    else
      if not _components[component.Subtype] then
        _components[component.Subtype] = component
      else
        error(string.format("Vyzor: %s (Frame) already contains Component (%s).", _name, component.Subtype), 3)
      end
    end

    if component.Subtype == "MiniConsole" or component.Subtype == "Map" then
      component.Container = _MasterList[_name]
    end

    updateStylesheetIfDrawn()
  end

  local function addCompound(compound)
    _compounds[compound.Name] = compound
    compound.Container = _MasterList[_name]

    _children[compound.Background.Name] = _MasterList[compound.Background.Name]

    updateStylesheetIfDrawn()
  end

  local function addFrame(frame)
    _MasterList[frame.Name].Container = _MasterList[_name]
    _children[frame.Name] = _MasterList[frame.Name]
  end

  local function addFrameByName(name)
    if _MasterList[name] then
      _MasterList[name].Container = _MasterList[_name]
      _children[name] = _MasterList[name]
    else
      error(string.format("Vyzor: Invalid Frame (%s) passed to %s:Add.", name, _name), 3)
    end
  end

  --- Adds a new object.
  -- @tparam string|Frame|Component|Compound object A valid Frame name or object, Component, or Compound.
  function self:Add(object)
    if type(object) == "string" then
      addFrameByName(object)
    elseif type(object) == "table" then
      if not object.Type then
        error(string.format("Vyzor: Non-Vyzor object passed to %s:Add.", _name), 2)
      end

      if object.Type == "Frame" then
        addFrame(object)
      elseif object.Type == "Component" then
        addComponent(object)
      elseif object.Type == "Compound" then
        addCompound(object)
      else
        error(string.format("Vyzor: Invalid Type (%s) passed to %s:Add.", object.Type, _name), 2)
      end
    else
      error(string.format("Vyzor: Invalid object (%s) passed to %s:Add.", type(object), _name), 2)
    end
  end

  local function removeComponent(component)
    if _miniConsoles[component.Name] then
      _miniConsoles[component.Name] = nil
    elseif _components[component.Subtype] then
      _components[component.Subtype] = nil
    else
      error(string.format("Vyzor: %s (Frame) does not contain Component (%s).", _name, component.Subtype), 3)
    end

    if component.Subtype == "MiniConsole" or component.Subtype == "Map" then
      component.Container = nil
    end

    updateStylesheetIfDrawn()
  end

  local function removeCompoound(compound)
    if not _compounds[compound.Name] then
      error(string.format("Vyzor: Compound (%s) is not a child of Frame (%s).", compound.Name, _name), 3)
    end

    if _compounds[compound.Name] then
      _compounds[compound.Name] = nil
      compound.Container = nil

      _children[compound.Background.Name] = nil
    end

    updateStylesheetIfDrawn()
  end

  local function removeFrame(frame)
    if not _children[frame.Name] then
      error(string.format("Vyzor: Frame (%s) is not a child of Frame (%s).", frame.Name, _name), 3)
    end

    _children[frame.Name] = nil
    _MasterList[frame.Name].Container = nil
  end

  local function removeObjectByName(name)
    if _MasterList[name] then
      _MasterList[name].Container = nil
      _children[name] = nil
    elseif _miniConsoles[name] then
      _miniConsoles[name].Container = nil
      _miniConsoles[name] = nil
    elseif _components[name] then
      _components[name] = nil

      if name == "Map" then
        _components[name].Container = nil
      end

      updateStylesheetIfDrawn()
    else
      error(string.format("Vyzor: Invalid string '%s' passed to %s:Remove.", name, _name), 3)
    end
  end

  --- Removes an object.
  -- @tparam string|Frame|Component|Compound object A valid Frame name or object, Component Subtype or object, or Compound.
  function self:Remove(object)
    if type(object) == "string" then
      removeObjectByName(object)
    elseif type(object) == "table" then
      if not object.Type then
        error(string.format("Vyzor: Non-Vyzor object passed to %s:Remove.", _name), 2)
      end

      if object.Type == "Frame" then
        removeFrame(object)
      elseif object.Type == "Component" then
        removeComponent(object)
      elseif object.Type == "Compound" then
        removeCompound(object)
      else
        error(string.format("Vyzor: Invalid Type (%s) passed to %s:Remove.", object.Type, _name), 2)
      end
    else
      error(string.format("Vyzor: Invalid object (%s) passed to %s:Remove.", type(object), _name), 2)
    end
  end

  local function drawHUD()
    local borderOrder = Options.DrawOrder

    local function title(text)
      local first = text:sub(1, 1):upper()
      local rest = text:sub(2):lower()

      return first .. rest
    end

    local borderFrames = Vyzor.HUD.Frames
    for _, border in ipairs(borderOrder) do
      local name = "Vyzor" .. title(border)

      if borderFrames[name] then
        borderFrames[name]:Draw()
      else
        error("Vyzor: Invalid entry in Options.DrawOrder. Must be top, bottom, left, or right.", 2)
      end
    end

    for name, frame in _children:pairs() do
      if name:sub(1, 5) ~= "Vyzor" then
        frame:Draw()
      end
    end

    if not _ResizeRegistered then
      if Options.HandleBorders == true or Options.HandleBorders == "auto" then
        registerAnonymousEventHandler("sysWindowResizeEvent", "VyzorResize")
        _ResizeRegistered = true
      end
    end

    raiseEvent("sysWindowResizeEvent")
    raiseEvent("VyzorDrawnEvent")
  end

  local function drawFrame()
    if not _isPlaceholder then
      createLabel(_name, _position.AbsoluteX, _position.AbsoluteY, _size.AbsoluteWidth, _size.AbsoluteHeight, 1)

      updateStylesheet()
      if _stylesheet then
        setLabelStyleSheet(_name, _stylesheet)
      end

      if _callback then
        if _callbackArguments then
          if type(_callbackArguments) == "table" then
            setLabelClickCallback(_name, _callback, unpack(_callbackArguments))
          else
            setLabelClickCallback(_name, _callback, _callbackArguments)
          end
        else
          setLabelClickCallback(_name, _callback)
        end
      end
    end

    if _miniConsoles:count() > 0 then
      for console in _miniConsoles:each() do
        console:Draw()
      end
    end

    if _components["Map"] then
      _components["Map"]:Draw()
    end

    if _children:count() > 0 then
      for frame in _children:each() do
        frame:Draw()
      end
    end
  end

  --- Draws this Frame.
  -- Is only called Vyzor:Draw().
  -- Should not be used directly on a Frame.
  function self:Draw()
    if not _isFirst then
      drawFrame()
    elseif _isFirst then
      drawHUD()
    end

    _isDrawn = true
  end

  --- Resizes the Frame and its children.
  -- @number width The Frame's new width.
  -- @number height The Frame's new height.
  function self:Resize(width, height)
    _size.Dimensions = {width or _size.Width, height or _size.Height}

    if not _isFirst then
      resizeWindow(_name, _size.AbsoluteWidth, _size.AbsoluteHeight)
    end

    if _miniConsoles:count() > 0 then
      for console in _miniConsoles:each() do
        console:Resize()
      end
    end

    if _components["Map"] then
      _components["Map"]:Resize()
    end

    if _children:count() > 0 then
      for frame in _children:each() do
        frame:Resize()
      end
    end
  end

  --- Repositions the Frame and its children.
  -- @number x The Frame's new X position.
  -- @number y The Frame's new Y position.
  function self:Move(x, y)
    _position.Coordinates = {x or _position.X, y or _position.Y}

    if not _isFirst then
      moveWindow(_name, _position.AbsoluteX, _position.AbsoluteY)
    end

    if _miniConsoles:count() > 0 then
      for console in _miniConsoles:each() do
        console:Move()
      end
    end

    if _components["Map"] then
      _components["Map"]:Move()
    end

    if _children:count() > 0 then
      for frame in _children:each() do
        frame:Move()
      end
    end
  end

  --- Hides the Frame and, optionally, its children.
  -- @bool[opt=false] skipChildren If true, this will not hide any of the Frame's children.
  function self:Hide(skipChildren)
    if not skipChildren then
      if _children:count() > 0 then
        for frame in _children:each() do
          frame:Hide()
        end
      end
    end

    if _miniConsoles:count() > 0 then
      for console in _miniConsoles:each() do
        console:Hide()
      end
    end

    if _components["Map"] then
      _components["Map"]:Hide()
    end

    if not _isFirst then
      hideWindow(_name)
    end
  end

  --- Reveals the Frame and, optionally, its children.
  -- @bool[opt=false] skipChildren If true, this will not show any of the Frame's children.
  function self:Show(skipChildren)
    if not _isFirst then
      showWindow(_name)
    end

    if _miniConsoles:count() > 0 then
      for console in _miniConsoles:each() do
        console:Show()
      end
    end

    if _components["Map"] then
      _components["Map"]:Show()
    end

    if not skipChildren then
      if _children:count() > 0 then
        for frame in _children:each() do
          frame:Show()
        end
      end
    end
  end

  --- Displays text on the Frame.
  -- @string text The text to be displayed.
  function self:Echo(text)
    echo(_name, text)
  end

  --- Displays text on the Frame.
  -- @string text The text to be displayed.
  function self:CEcho(text)
    cecho(_name, text)
  end

  --- Clears all text from the Frame and, optionally, its children.
  -- @bool[opt=false] clearChildren Will call clear on child Frames if true.
  function self:Clear(clearChildren)
    clearWindow(_name)

    if clearChildren then
      for frame in _children:each() do
        frame:Clear(true)
      end
    end
  end

  setmetatable(
    self,
    {
      __index = function(_, key)
        return (properties[key] and properties[key].get()) or Frame[key]
      end,
      __newindex = function(_, key, value)
        if properties[key] and properties[key].set then
          properties[key].set(value)
        end
      end,
      __tostring = function(_)
        return _name
      end
    }
  )

  _MasterList[_name] = self
  return self
end

setmetatable(
  Frame,
  {
    __index = getmetatable(Frame).__index,
    __call = new
  }
)
return Frame
