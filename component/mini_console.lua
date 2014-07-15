-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require("vyzor.base")

--[[
    Class: MiniConsole
        Defines the MiniConsole Component.
]]
local MiniConsole = Base("Component", "MiniConsole")

-- Array: master_list
-- Holds all MiniConsoles for consistent reference.
local _MasterList = {}

-- TODO: These are shared. Move to single location?
local function calculateAbsolutePosition(axis, frameAxis, frameDimension)
    if axis >= 0.0 and axis <= 1.0 then
        return frameAxis + (axis * frameDimension)
    else
        return frameAxis + axis
    end
end

local function calculateAbsoluteDimension(dimension, frameDimension)
    if dimension >= 0.0 and dimension <= 1.0 then
        return dimension * frameDimension
    else
        return dimension
    end
end

--[[
    Constructor: new

    Parameters:
        _name - Used for echoing and other Mudlet referencing.
        initialX - X coordinate position.
        initialY - Y coordinate position.
        initialWidth - Width of the MiniConsole.
        initialHeight - Height of the MiniConsole.
        initialWordWrap - Sets the MiniConsole's word wrap in characters. Default is dynamic or 80 if <initialFontSize> is dynamic.
        initialFontSize - Sets the MiniConsole's font size. Default is dynamic or 8 if <initialWordWrap> is dynamic.
]]
local function new (_, _name, initialX, initialY, initialWidth, initialHeight, initialWordWrap, initialFontSize)
    assert(_name, "Vyzor: New MiniConsole must have a name.")

    --[[
        Structure: New MiniConsole
            A Mudlet text container allowing that mimicks the
            main console.
    ]]
    local self = {}

    -- Object: _container
    -- The MiniConsole's parent frame. Usually set automatically when added to a Frame.
    local _container

    -- Number: _x
    -- User-defined X coordinate of the MiniConsole.
    local _x = initialX or 0

    -- Number: _absoluteX
    -- Actual X coordinate of the MiniConsole.
    local _absoluteX

    -- Number: _y
    -- User-defined Y Coordinate of the MiniConsole.
    local _y = initialY or 0

    -- Number: _absoluteY
    -- Actual Y Coordinate of the MiniConsole.
    local _absoluteY

    -- Number: _width
    -- User-defined Width of the MiniConsole.
    local _width = initialWidth or 1.0

    -- Number: _absoluteWidth
    -- Actual Width of the MiniConsole.
    local _absoluteWidth

    -- Number: _height
    -- User-defined Height of the MiniConsole.
    local _height = initialHeight or 1.0

    -- Number: _absoluteHeight
    -- Actual Height of the MiniConsole.
    local _absoluteHeight

    -- Variable: _wordWrap
    -- Number of characters at which the MiniConsole will wrap.
    local _wordWrap = initialWordWrap or "dynamic"

    -- Number: _absoluteWordWrap
    -- Actual word wrap of the MiniConsole.
    local _absoluteWordWrap

    -- Variable: _fontSize
    -- Font size of the text in MiniConsole.
    local _fontSize = initialFontSize or ((_wordWrap == "dynamic" and 8) or "dynamic")

    -- Number: _absoluteFontSize
    -- Actual font size of the MiniConsole.
    local _absoluteFontSize

    if _fontSize == "dynamic" and _wordWrap == "dynamic" then
        _wordWrap = 80
    end

    --[[
        Function: updateAbsolutes
            Sets the actual size and position of the MiniConsole
            using the parent Frame's Content.
    ]]
    local function updateAbsolutes ()
        if _container then
            _absoluteX = calculateAbsolutePosition(_x, _container.Position.ContentX, _container.Size.ContentWidth)
            _absoluteY = calculateAbsolutePosition(_y, _container.Position.ContentY, _container.Size.ContentHeight)

            _absoluteWidth = calculateAbsoluteDimension(_width, _container.Size.ContentWidth)
            _absoluteHeight = calculateAbsoluteDimension(_height, _container.Size.ContentHeight)

            if _wordWrap == "dynamic" then
                _absoluteFontSize = _fontSize

                _absoluteWordWrap = _absoluteWidth / calcFontSize(_absoluteFontSize)
            else
                _absoluteWordWrap = _wordWrap

                local currentSize = 39
                local totalWidth = _wordWrap * calcFontSize(currentSize)
                while totalWidth > _absoluteWidth do
                    if currentSize == 1 then
                        break
                    end

                    currentSize = currentSize - 1
                    totalWidth = _wordWrap * calcFontSize(currentSize)
                end

                _absoluteFontSize = currentSize
            end
        end
    end

    --[[
        Properties: MiniConsole Properties
            Name - Returns the MiniConsole's name.
            Container - Gets and sets the MiniConsole's parent Frame.
            X - Gets and sets the MiniConsole's relative X coordinate.
            AbsoluteX - Returns the MiniConsole's actual X coordinate.
            Y - Gets and sets the MiniConsole's relative Y coordinate.
            AbsoluteY - Returns the MiniConsole's actual Y coordinate.
            Width - Gets and sets the MiniConsole's relative width.
            AbsoluteWidth - Returns the MiniConsole's actual width.
            Height - Gets and sets the MiniConsole's relative height.
            AbsoluteHeight - Returns the MiniConsole's actual height.
            WordWrap - Gets and sets the MiniConsole's word wrap. If <size> is dynamic, <size> is set to 8.
            AbsoluteWrap - Returns the actual word <wrap> of the MiniConsole.
            FontSize - Gets and sets the MiniConsole's font size. If <wrap> is dynamic, <wrap> is set to 80.
            AbsoluteSize - Returns the actual <size> of the MiniConsole's text.
    ]]
    local properties = {
        Name = {
            get = function ()
                return _name
            end
        },

        Container = {
            get = function ()
                return _container
            end,
            set = function (value)
                if value.Type == "Frame" then
                    _container = value
                end
            end
        },

        X = {
            get = function ()
                return _x
            end,
            set = function (value)
                _x = value
                updateAbsolutes()
            end
        },

        AbsoluteX = {
            get = function ()
                return _absoluteX
            end
        },

        Y = {
            get = function ()
                return _y
            end,
            set = function (value)
                _y = value
                updateAbsolutes()
            end
        },

        AbsoluteY = {
            get = function ()
                return _absoluteY
            end
        },

        Width = {
            get = function ()
                return _width
            end,
            set = function (value)
                _width = value
                updateAbsolutes()
            end
        },

        AbsoluteWidth = {
            get = function ()
                return _absoluteWidth
            end
        },

        Height = {
            get = function ()
                return _height
            end,
            set = function (value)
                _height = value
                updateAbsolutes()
            end
        },

        AbsoluteHeight = {
            get = function ()
                return _absoluteHeight
            end
        },

        WordWrap = {
            get = function ()
                return _wordWrap
            end,
            set = function (value)
                _wordWrap = value

                if _wordWrap == "dynamic" and _fontSize == "dynamic" then
                    _fontSize = 8
                end

                if _container then
                    updateAbsolutes()
                    setWindowWrap(_name, _absoluteWordWrap)
                end
            end
        },

        AbsoluteWrap = {
            get = function ()
                return _absoluteWordWrap
            end
        },

        FontSize = {
            get = function ()
                return _fontSize
            end,
            set = function (value)
                _fontSize = value

                if _fontSize == "dynamic" and _wordWrap == "dynamic" then
                    _wordWrap = 80
                end

                if _container then
                    updateAbsolutes()
                    setMiniConsoleFontSize(_name, _absoluteFontSize)
                end
            end
        },

        AbsoluteSize = {
            get = function ()
                return _absoluteFontSize
            end
        }
    }

    --[[
        Function: Draw
            Draws the MiniConsole. Should only be called internally.
    ]]
    function self:Draw ()
        if not _container then
            error(string.format("Vyzor: Tried to Draw a MiniConsole (%s) without a parent Frame.", _name), 2)
        end

        updateAbsolutes()

        createMiniConsole(_name, _absoluteX, _absoluteY, _absoluteWidth, _absoluteHeight)
        setMiniConsoleFontSize(_name, _absoluteFontSize)
        setWindowWrap(_name, _absoluteWordWrap)
    end

    --[[
        Function: Resize

        Parameters:
            width - New relative width of the MiniConsole.
            height - New relative height of the MiniConsole.
    ]]
    function self:Resize (width, height)
        _width = width or _width
        _height = height or _height

        updateAbsolutes()

        resizeWindow(_name, _absoluteWidth, _absoluteHeight)
        setWindowWrap(_name, _absoluteWordWrap)
        setMiniConsoleFontSize(_name, _absoluteFontSize)
    end

    --[[
        Function: Move

        Parameters:
            x - New relative X coordinate of the MiniConsole.
            y - New relative Y coordinate of the MiniConsole.
    ]]
    function self:Move (x, y)
        _x = x or _x
        _y = y or _y

        updateAbsolutes()

        moveWindow(_name, _absoluteX, _absoluteY)
    end

    --[[
        Function: Hide
    ]]
    function self:Hide ()
        hideWindow(_name)
    end

    --[[
        Function: Show
    ]]
    function self:Show ()
        showWindow(_name)
    end

    --[[
        Function: Echo
            Displays text on a MiniConsole. Starts where the last
            line left off.

        Parameters:
            text - The text to be displayed.
    ]]
    function self:Echo (text)
        echo(_name, text)
    end

    --[[
        Function: HEcho
            Displays text on a MiniConsole with Hex color formatting.

        Paramaters:
            text - The text to be displayed.
    ]]
    function self:HEcho (text)
        hecho(_name, text)
    end

    --[[
        Function: CEcho
            Displays text on a MiniConsole with colour tags.

        Paramaters:
            text - The text to be displayed.
    ]]
    function self:CEcho (text)
        cecho(_name, text)
    end

    --[[
        Function: DEcho
            Displays text on a MiniConsole with some crazy-ass formatting.

        Paramaters:
            text - The text to be displayed.
            foregroundColor - The foreground color of the text.
            backgroundColor - The background color of the text.
            useInsertText - If true, uses InsertText() instead of echo().
    ]]
    function self:DEcho (text, foregroundColor, backgroundColor, useInsertText)
        decho(text, foregroundColor, backgroundColor, useInsertText, _name)
    end

    --[[
        Function: EchoLink
            Displays a clickable line of text in a MiniConsole.

        Parameters:
            text - The text to be displayed.
            command - Script to be executed when clicked.
            tooltipText - Tooltip text.
            keepFormat - If true, uses Frame text formatting.
            useInsertText - If true, uses InsertText() instead of Echo()
    ]]
    function self:EchoLink (text, command, tooltipText, keepFormat, useInsertText)
        if not useInsertText then
            echoLink(_name, text, command, tooltipText, keepFormat)
        else
            insertLink(_name, text, command, tooltipText, keepFormat)
        end
    end

    --[[
        Function: EchoPopup
            Clickable text that expands out to a menu.

        Parameters:
            text - The text to be displayed.
            commands - A table of scripts to be executed.
            tooltipTexts - A table of tooltips.
            keepFormat - If true, uses MiniConsole text formatting.
            useInsertText - If true, uses InsertText() insead of Echo().
    ]]
    function self:EchoPopup (text, commands, tooltipTexts, keepFormat, useInsertText)
        if not useInsertText then
            echoPopup(_name, text, commands, tooltipTexts, keepFormat)
        else
            insertPopup(_name, text, commands, tooltipTexts, keepFormat)
        end
    end

    --[[
        Function: Paste
            Copies text to the MiniConsole from the clipboard (via copy()).
            Clears the window first.
    ]]
    function self:Paste ()
        selectCurrentLine()
        copy()
        paste(_name)
    end

    --[[
        Function: Append
            Copies text to the MiniConsole from a buffer or
            the clipboard (via copy()).
            Adds the text beginning at a new line.
    ]]
    function self:Append ()
        selectCurrentLine()
        copy()
        appendBuffer(_name)
    end

    --[[
        Function: Clear
            Clears all text from the MiniConsole.
    ]]
    function self:Clear ()
        clearWindow(_name)
    end

    setmetatable(self, {
        __index = function (_, key)
            return (properties[key] and properties[key].get()) or MiniConsole[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end,
    })

    _MasterList[_name] = self
    return self
end

setmetatable(MiniConsole, {
    __index = getmetatable(MiniConsole).__index,
    __call = new,
})

return MiniConsole
