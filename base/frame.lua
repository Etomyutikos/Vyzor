-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require("vyzor.base")
local Lib = require("vyzor.lib")
local Options = require("vyzor.base.options")
local Position = require("vyzor.component.position")
local Size = require("vyzor.component.size")
local BoundingMode = require("vyzor.enum.bounding_mode")

--[[
    Class: Frame
        Defines the primary container for
        Vyzor Components. Frames are modified via Components,
        and may hold other Frames.
]]
local Frame = Base("Frame")

-- Boolean: first_frame
-- Used for very specific handling of the master Vyzor HUD.
local _FirstFrame = true

-- Boolean: resize_registered
-- Determines whether or not the resize function has been registered
-- as an event handler.
local _ResizeRegistered = false

-- Array: master_list
-- Holds all Frames for reference.
local _MasterList = {}

--[[
    Constructor: new

    Parameters:
        name - The name of the Frame, used for addressing.
        x - Initial X position of the Frame. Defaults to 0.
        y - Initial Y position of the Frame. Defaults to 0.
        width - Initial width of the Frame. Defaults to 1.
        height - Initial height of the Frame. Defaults to 1.

    Returns:
        A new Frame.
]]
local function new (_, _name, _x, _y, _width, _height)
    -- Structure: New Frame
    -- A new Frame object.
    local self = {}

    -- Boolean: _isFirst
    -- Is this the HUD?
    local _isFirst = _FirstFrame
    _FirstFrame = false

    -- Boolean: _isDrawn
    -- Has this Frame been drawn?
    local _isDrawn = false

    -- Boolean: _isBounding
    -- Does this object obey bounding rules?
    local _isBounding = false

    -- String: _boundingType
    -- The <BoundingMode> rules to which this object adheres.
    local _boundingType = BoundingMode.Size

    -- Object: _parent
    -- The Frame that contains this one.
    local _parent

    -- Array: _components
    -- A list of Components this Frame contains.
    local _components = {}
    local _componentCount = 0 -- TODO: Why is this necessary?

    -- Array: _miniConsoles
    -- Stores MiniConsole Components.
    local _miniConsoles = {}
    local _miniConsoleCount = 0 -- TODO: Why is this necessary?

    -- Array: _compounds
    -- Stores Compounds.
    local _compounds = {}
    local _compoundCount = 0 -- TODO: Why is this necessary?

    -- Array: _children
    -- A list of Frames this Frame contains.
    local _children = Lib.OrderedTable()
    local _childCount = 0 -- TODO: Why is this necessary?

    -- String: _callback
    -- The name of a function to be used as a Label callback.
    local _callback

    -- Array: _callbackArguments
    -- A table holding the arguments for a Label callback.
    local _callbackArguments

    -- Object: _position
    -- The Position Supercomponent managing this Frame's
    -- location.
    local _position = Position(self, _x, _y, _isFirst)

    -- Object: _size
    -- The Size Supercomponent managing this Frame's space.
    local _size = Size(self, _width, _height, _isFirst)

    -- String: stylesheet
    -- This Frame's Stylesheet. Generated via <updateStylesheet>.
    local _stylesheet

    --[[
        Function: updateStylesheet
            Polls all Component's for their Stylesheets.
            Constructs the final <stylesheet> applied by setLabelStyleSheet.
    ]]
    local function updateStylesheet ()
        if _componentCount > 0 then
            local styleTable = {}

            for _, component in pairs(_components) do
                local componentSubtype = component.Subtype

                -- Hover is a special case. It must be last, and it will
                -- contain its own components. So we save it for last.
                if componentSubtype ~= "Hover" or componentSubtype ~= "MiniConsole" or componentSubtype ~= "Map" then
                    styleTable[#styleTable + 1] = component.Stylesheet
                end
            end
            styleTable[#styleTable +1] = _components["Hover"] and _components["Hover"].Stylesheet

            _stylesheet = table.concat(styleTable, "; ")
            _stylesheet = string.format("%s;", _stylesheet)
        end
    end

    --[[
        Properties: Frame Properties
            Name - Return the Frame's name.
            IsBounding - Gets and sets a boolean value.
            BoundingMode - Gets and sets the BoundingMode for this Frame.
            Container - Gets and sets the parent Frame for this Frame.
            Components - Returns a copy of the Frame's Components.
            MiniConsoles - Returns a copy of the Frame's MiniConsoles.
            Compounds - Returns a copy of the Frame's Compounds.
            Frames - Returns a copy of the Frame's child Frames.
            Position - Returns this Frame's Position Supercomponent.
            Size - Returns this Frame's Size Supercomponent.
            Stylesheet - Updates and returns this Frame's Stylesheet.
            Callback - Gets and sets a Callback for this Frame.
            CallbackArguments - Gets and sets the arguments passed to the Callback. Should be a table.
            IsDrawn - Has this Frame been drawn?
    ]]
    local properties = {
        Name = {
            get = function ()
                return _name
            end,
        },

        IsBounding = {
            get = function ()
                return _isBounding
            end,
            set = function (value)
                _isBounding = value
            end
        },

        BoundingMode = {
            get = function ()
                return _boundingType
            end,
            set = function (value)
                _boundingType = value
            end
        },

        Container = {
            get = function ()
                return _parent
            end,
            set = function (value)
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
            end,
        },

        Components = {
            get = function ()
                if _componentCount > 0 then
                    local copy = {}

                    for i in pairs(_components) do
                        copy[i] = _components[i]
                    end
                    return copy
                end
            end,
        },

        MiniConsoles = {
            get = function ()
                if _miniConsoleCount > 0 then
                    local copy = {}

                    for i in pairs(_miniConsoles) do
                        copy[i] = _miniConsoles[i]
                    end
                    return copy
                end
            end,
        },

        Compounds = {
            get = function ()
                if _compoundCount > 0 then
                    local copy = {}

                    for i in pairs(_compounds) do
                        copy[i] = _compounds[i]
                    end
                    return copy
                end
            end
        },

        Frames = {
            get = function ()
                if _childCount > 0 then
                    local copy = {}

                    for _, name, child in _children() do
                        copy[name] = child
                    end
                    return copy
                end
            end
        },

        Position = {
            get = function ()
                return _position
            end
        },

        Size = {
            get = function ()
                return _size
            end
        },

        Stylesheet = {
            get = function ()
                if not _stylesheet then
                    updateStylesheet()
                end
                return _stylesheet
            end
        },

        Callback = {
            get = function ()
                return _callback
            end,
            set = function (value)
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
            end,
        },

        CallbackArguments = {
            get = function ()
                return _callbackArguments
            end,
            set = function (value)
                _callbackArguments = value

                if _callback and _callbackArguments then
                    if type(_callbackArguments) == "table" then
                        setLabelClickCallback(_name, _callback, unpack(_callbackArguments))
                    else
                        setLabelClickCallback(_name, _callback, _callbackArguments)
                    end
                end
            end,
        },

        IsDrawn = {
            get = function ()
                return _isDrawn
            end,
        },
    }

    --[[
        Function: Add
            Adds a new object to this Frame.
            Objects can be a string (must be a valid Frame name),
            a Frame object, or a Component object.

        Parameters:
            object - A valid Frame name or object, or a Component.
    ]]
    function self:Add (object) -- TODO: Break this up.
        if type(object) == "string" then
            if _MasterList[object] then
                _MasterList[object].Container = _MasterList[_name]
                _children[object] = _MasterList[object]
                _childCount = _childCount + 1
            else
                error(string.format(
                    "Vyzor: Invalid Frame (%s) passed to %s:Add.",
                    object, _name), 2)
            end
        elseif type(object) == "table" then
            if object.Type then
                if object.Type == "Frame" then
                    _MasterList[object.Name].Container = _MasterList[_name]
                    _children[object.Name] = _MasterList[object.Name]
                    _childCount = _childCount + 1
                elseif object.Type == "Component" then
                    if not _components[object.Subtype] then
                        if object.Subtype == "MiniConsole" then
                            _miniConsoles[object.Name] = object
                            _miniConsoleCount = _miniConsoleCount + 1
                        else
                            _components[object.Subtype] = object
                            _componentCount = _componentCount + 1
                        end

                        if object.Subtype == "MiniConsole" or object.Subtype == "Map" then
                            object.Container = _MasterList[_name]
                        end

                        if _isDrawn then
                            updateStylesheet()

                            if _stylesheet then
                                setLabelStyleSheet(_name, _stylesheet)
                            end
                        end
                    else
                        error(string.format(
                            "Vyzor: %s (Frame) already contains Component (%s).",
                            _name, object.Subtype), 2)
                    end
                elseif object.Type == "Compound" then
                    _compounds[object.Name] = object
                    _compoundCount = _compoundCount + 1
                    object.Container = _MasterList[_name]

                    local compoundContainerName = object.Background.Name
                    _children[compoundContainerName] = _MasterList[compoundContainerName]
                    _childCount = _childCount + 1

                    if _isDrawn then
                        updateStylesheet()
                        if _stylesheet then
                            setLabelStyleSheet(_name, _stylesheet)
                        end
                    end
                else
                    error(string.format(
                        "Vyzor: Invalid Type (%s) passed to %s:Add.",
                        object.Type, _name), 2)
                end
            else
                error(string.format(
                    "Vyzor: Invalid object (%s) passed to %s:Add.",
                    type(object), _name), 2)
            end
        else
            error(string.format(
                "Vyzor: Invalid object (%s) passed to %s:Add.",
                type(object), _name), 2)
        end
    end

    --[[
        Function: Remove
            Removes an object from this Frame.
            Objects must be a string (must be a valid Frame's name or
            Component Subtype), a Frame object, or a Component object.

        Parameters:
            object - A valid Frame name or object, or a Component Subtype or object.
    ]]
    function self:Remove (object) -- TODO: Break this up.
        if type(object) == "string" then
            if _MasterList[object] then
                _MasterList[object].Container = nil
                _children[object] = nil
                _childCount = _childCount - 1
            elseif _components[object] or _miniConsoles[object] then
                if _miniConsoles[object] then
                    _miniConsoles[object].Container = nil
                    _miniConsoles[object] = nil
                    _miniConsoleCount = _miniConsoleCount - 1
                else
                    if object == "Map" then
                        _components[object].Container = nil
                    end

                    _components[object] = nil
                    _componentCount = _componentCount - 1
                end

                if _isDrawn then
                    updateStylesheet()

                    if _stylesheet then
                        setLabelStyleSheet(_name, _stylesheet)
                    end
                end
            else
                error(string.format(
                    "Vyzor: Invalid string '%s' passed to %s:Remove.",
                    object, _name), 2)
            end
        elseif type(object) == "table" then
            if object.Type then
                if object.Type == "Frame" then
                    for _, name, frame in _children() do -- TODO: Can't I just index into this?
                        if frame == object then
                            _MasterList[name].Container = nil
                            _children[name] = nil
                            _childCount = _childCount - 1
                            break
                        end
                    end
                elseif object.Type == "Component" then
                    if _miniConsoles[object.Name] then
                        _miniConsoles[object.Name] = nil
                        _miniConsoleCount = _miniConsoleCount - 1
                    elseif _components[object.Subtype] then
                        _components[object.Subtype] = nil
                        _componentCount = _componentCount - 1

                        if object.Subtype == "MiniConsole" or object.Subtype == "Map" then
                            object.Container = nil
                        end
                    else
                        error(string.format(
                            "Vyzor: %s (Frame) does not contain Component (%s).",
                            _name, object.Subtype), 2)
                    end

                    if _isDrawn then
                        updateStylesheet()
                    end
                elseif object.Type == "Compound" then
                    if _compounds[object.Name] then
                        _compounds[object.Name] = nil
                        _compoundCount = _compoundCount - 1
                        object.Container = nil

                        local compoundContainerName = object.Background.Name
                        _children[compoundContainerName] = nil
                        _childCount = _childCount - 1
                    end

                    if _isDrawn then
                        updateStylesheet()

                        if _stylesheet then
                            setLabelStyleSheet(_name, _stylesheet)
                        end
                    end
                else
                    error(string.format(
                        "Vyzor: Invalid Type (%s) passed to %s:Remove.",
                        object.Type, _name), 2)
                end
            else
                error(string.format(
                    "Vyzor: Invalid object (%s) passed to %s:Remove.",
                    type(object), _name), 2)
            end
        else
            error(string.format(
                "Vyzor: Invalid object (%s) passed to %s:Remove.",
                type(object), _name), 2)
        end
    end

    --[[
        Function: Draw
            Draws this Frame. Is only called via Vyzor:Draw().
            Should not be used directly on a Frame.
    ]]
    function self:Draw () -- TODO: Break this up.
        -- We don't draw the master Frame, because it covers
        -- everything. Think of it as a virtual Frame.
        if not _isFirst then
            createLabel(
                _name,
                _position.AbsoluteX, _position.AbsoluteY,
                _size.AbsoluteWidth, _size.AbsoluteHeight, 1)

            updateStylesheet()
            if _stylesheet then
                setLabelStyleSheet(_name, _stylesheet)
            end

            if _miniConsoleCount > 0 then
                for _, console in pairs(_miniConsoles) do
                    console:Draw()
                end
            end

            if _components["Map"] then
                _components["Map"]:Draw()
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

            _isDrawn = true

            if _childCount > 0 then
                for _, _, frame in _children() do
                    frame:Draw()
                end
            end
        elseif _isFirst then
            local drawOrder = Options.DrawOrder

            local function title (text)
                local first = text:sub(1, 1):upper()
                local rest = text:sub(2):lower()
                return first .. rest
            end

            local hudChildren = Vyzor.HUD.Frames
            for _, frame in ipairs(drawOrder) do
                local frame = "Vyzor" .. title(frame)
                if hudChildren[frame] then
                    hudChildren[frame]:Draw()
                else
                    error("Vyzor: Invalid entry in Options.DrawOrder. Must be top, bottom, left, or right.", 2)
                end
            end

            for _, name, frame in _children() do
                if name:sub(1, 5) ~= "Vyzor" then
                    frame:Draw()
                end
            end

            _isDrawn = true

            if not _ResizeRegistered then
                if Options.HandleBorders == true or Options.HandleBorders == "auto" then
                    registerAnonymousEventHandler("sysWindowResizeEvent", "VyzorResize")
                    _ResizeRegistered = true
                end
            end
            raiseEvent("sysWindowResizeEvent")

            raiseEvent("VyzorDrawnEvent")
        end
    end

    --[[
        Function: Resize
            Resizes the Frame.

        Parameters:
            width - The Frame's new width.
            height - The Frame's new height.
    ]]
    function self:Resize (width, height)
        _size.Dimensions = { width or _size.Width, height or _size.Height }

        if not _isFirst then
            resizeWindow(_name, _size.AbsoluteWidth, _size.AbsoluteHeight)
        end

        if _miniConsoleCount > 0 then
            for _, console in pairs(_miniConsoles) do
                console:Resize()
            end
        end

        if _components["Map"] then
            _components["Map"]:Resize()
        end

        if _childCount > 0 then
            for _, _, frame in _children() do
                frame:Resize()
            end
        end
    end

    --[[
        Function: Move
            Repositions the Frame.

        Parameters:
            x - The Frame's new X position.
            y - The Frame's new Y position.
    ]]
    function self:Move (x, y)
        _position.Coordinates = { x or _position.X, y or _position.Y }

        if not _isFirst then
            moveWindow(_name, _position.AbsoluteX, _position.AbsoluteY)
        end

        if _miniConsoleCount > 0 then
            for _, console in pairs(_miniConsoles) do
                console:Move()
            end
        end

        if _components["Map"] then
            _components["Map"]:Move()
        end

        if _childCount > 0 then
            for _, _, frame in _children() do
                frame:Move()
            end
        end
    end

    --[[
        Function: Hide
            Hides the Frame.
            Iterates through the Frame's children first, hiding
            each of them before hiding itself.

        Parameters:
            skipChildren - If true, this will not hide any of the Frame's children.
    ]]
    function self:Hide (skipChildren)
        if not skipChildren then
            if _childCount > 0 then
                for _, _, frame in _children() do
                    frame:Hide()
                end
            end
        end

        if _miniConsoleCount > 0 then
            for _, console in pairs(_miniConsoles) do
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

    --[[
        Function: Show
            Reveals the Frame.
            Reveals itself first, then iterates through each of its
            children, revealing them.

        Parameters:
            skipChildren - If true, this will not show any of the Frame's children.
    ]]
    function self:Show (skipChildren)
        if not _isFirst then
            showWindow(_name)
        end

        if _miniConsoleCount > 0 then
            for _, console in pairs(_miniConsoles) do
                console:Show()
            end
        end

        if _components["Map"] then
            _components["Map"]:Show()
        end

        if not skipChildren then
            if _childCount > 0 then
                for _, _, frame in _children() do
                    frame:Show()
                end
            end
        end
    end

    --[[
        Function: Echo
            Displays text on a Frame.

        Parameters:
            text - The text to be displayed.
    ]]
    function self:Echo (text)
        echo(_name, text)
    end

    --[[
        Function: Echo
            Displays text on a Frame.

        Parameters:
            text - The text to be displayed.
    ]]
    function self:CEcho (text)
        cecho(_name, text)
    end
    --[[
        Function: Clear
            Clears all text from the Frame.

        Paramaters:
            clearChildren - Will call clear on child Frames if true.
    ]]
    function self:Clear (clearChildren)
        clearWindow(_name)

        if clearChildren then
            for _, _, frame in _children() do
                frame:Clear(true)
            end
        end
    end

    setmetatable(self, { -- TODO: It should be possible to generify this.
        __index = function (_, key)
            return (properties[key] and properties[key].get()) or Frame[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end,
        __tostring = function (_)
            return _name
        end,
        })

    _MasterList[_name] = self
    return self
end

setmetatable(Frame, {
    __index = getmetatable(Frame).__index,
    __call = new,
    })
return Frame
