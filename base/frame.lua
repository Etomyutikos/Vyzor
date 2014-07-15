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
    local _components = Lib.OrderedTable()

    -- Array: _miniConsoles
    -- Stores MiniConsole Components.
    local _miniConsoles = Lib.OrderedTable()

    -- Array: _compounds
    -- Stores Compounds.
    local _compounds = Lib.OrderedTable()

    -- Array: _children
    -- A list of Frames this Frame contains.
    local _children = Lib.OrderedTable()

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
            styleTable[#styleTable +1] = _components["Hover"] and _components["Hover"].Stylesheet

            _stylesheet = table.concat(styleTable, "; ")
            _stylesheet = string.format("%s;", _stylesheet)
        end
    end

    local function updateStylesheetIfDrawn ()
        if _isDrawn then
            updateStylesheet()

            if _stylesheet then
                setLabelStyleSheet(_name, _stylesheet)
            end
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
                if _components:count() > 0 then
                    local copy = {}

                    for subType, component in _components:pairs() do
                        copy[subType] = component
                    end

                    return copy
                end
            end,
        },

        MiniConsoles = {
            get = function ()
                echo("_miniConsoles:count() = " .. _miniConsoles:count() .. "\n")
                if _miniConsoles:count() > 0 then
                    local copy = {}

                    for name, miniConsole in _miniConsoles:pairs() do
                        copy[name] = miniConsole
                    end

                    return copy
                end
            end,
        },

        Compounds = {
            get = function ()
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
            get = function ()
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

    local function addComponent (component)
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

    local function addCompound (compound)
        _compounds[compound.Name] = compound
        compound.Container = _MasterList[_name]

        _children[compound.Background.Name] = _MasterList[compound.Background.Name]

        updateStylesheetIfDrawn()
    end

    local function addFrame(frame)
        _MasterList[frame.Name].Container = _MasterList[_name]
        _children[frame.Name] = _MasterList[frame.Name]
    end

    local function addFrameByName (name)
        if _MasterList[name] then
            _MasterList[name].Container = _MasterList[_name]
            _children[name] = _MasterList[name]
        else
            error(string.format("Vyzor: Invalid Frame (%s) passed to %s:Add.", name, _name), 3)
        end
    end

    --[[
        Function: Add
            Adds a new object to this Frame.
            Objects can be a string (must be a valid Frame name),
            a Frame object, or a Component object.

        Parameters:
            object - A valid Frame name or object, or a Component.
    ]]
    function self:Add (object)
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

    local function removeComponent (component)
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

    local function removeCompoound (compound)
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

    local function removeFrame (frame)
        if not _children[frame.Name] then
            error(string.format("Vyzor: Frame (%s) is not a child of Frame (%s).", frame.Name, _name), 3)
        end

        _children[frame.Name] = nil
        _MasterList[frame.Name].Container = nil
    end

    local function removeObjectByName (name)
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

    --[[
        Function: Remove
            Removes an object from this Frame.
            Objects must be a string (must be a valid Frame's name or
            Component Subtype), a Frame object, or a Component object.

        Parameters:
            object - A valid Frame name or object, or a Component Subtype or object.
    ]]
    function self:Remove (object)
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

    local function drawFrame ()
        createLabel(_name,
            _position.AbsoluteX, _position.AbsoluteY,
            _size.AbsoluteWidth, _size.AbsoluteHeight, 1)

        updateStylesheet()
        if _stylesheet then
            setLabelStyleSheet(_name, _stylesheet)
        end

        if _miniConsoles:count() > 0 then
            for console in _miniConsoles:each() do
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

        if _children:count() > 0 then
            for frame in _children:each() do
                frame:Draw()
            end
        end
    end

    --[[
        Function: Draw
            Draws this Frame. Is only called via Vyzor:Draw().
            Should not be used directly on a Frame.
    ]]
    function self:Draw ()
        if not _isFirst then
            drawFrame()

        elseif _isFirst then
            drawHUD()
        end

        _isDrawn = true
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
            for frame in _children:each() do
                frame:Clear(true)
            end
        end
    end

    setmetatable(self, {
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
        end
    })

    _MasterList[_name] = self
    return self
end

setmetatable(Frame, {
    __index = getmetatable(Frame).__index,
    __call = new,
    })
return Frame
