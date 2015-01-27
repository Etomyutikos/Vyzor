--- A Mudlet text container that mimicks the main console.
-- @classmod MiniConsole

local Base = require("vyzor.base")

local MiniConsole = Base("Component", "MiniConsole")

local _MasterList = {}

local function calculateAbsolutePosition(axisValue, frameAxis, frameDimension)
    if axisValue >= 0.0 and axisValue <= 1.0 then
        return frameAxis + (axisValue * frameDimension)
    else
        return frameAxis + axisValue
    end
end

local function calculateAbsoluteDimension(dimension, frameDimension)
    if dimension >= 0.0 and dimension <= 1.0 then
        return dimension * frameDimension
    else
        return dimension
    end
end

--- MiniConsole constructor.
-- @function MiniConsole
-- @string _name Used for echoing and other Mudlet referencing.
-- @number[opt=0] initialX X coordinate position.
-- @number[opt=0] initialY Y coordinate position.
-- @number[opt=1.0] initialWidth Width of the MiniConsole.
-- @number[opt=1.0] initialHeight Height of the MiniConsole.
-- @tparam[opt] number|string initialWordWrap Sets the MiniConsole's word wrap in characters. Default is dynamic or 80
--- if initialFontSize is dynamic.
-- @tparam[opt] number|string initialFontSize Sets the MiniConsole's font size. Default is dynamic or 8 if
--- initialWordWrap is dynamic.
-- @treturn MiniConsole
local function new (_, _name, initialX, initialY, initialWidth, initialHeight, initialWordWrap, initialFontSize)
    assert(_name, "Vyzor: New MiniConsole must have a name.")

    --- @type MiniConsole
    local self = {}

    local _container
    local _x = initialX or 0
    local _absoluteX
    local _y = initialY or 0
    local _absoluteY
    local _width = initialWidth or 1.0
    local _absoluteWidth
    local _height = initialHeight or 1.0
    local _absoluteHeight
    local _wordWrap = initialWordWrap or "dynamic"
    local _absoluteWordWrap
    local _fontSize = initialFontSize or ((_wordWrap == "dynamic" and 8) or "dynamic")
    local _absoluteFontSize

    if _fontSize == "dynamic" and _wordWrap == "dynamic" then
        _wordWrap = 80
    end

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

    --- Properties
    --- @section
    local properties = {
        Name = {
            --- Returns the MiniConsole's name.
            --- @function self.Name.get
            --- @treturn string
            get = function ()
                return _name
            end
        },

        Container = {
            --- Returns the MiniConsole's parent @{Frame}.
            --- @function self.Container.get
            --- @treturn Frame
            get = function ()
                return _container
            end,

            --- Sets the MiniConsole's parent @{Frame}.
            --- @function self.Container.set
            --- @tparam Frame value
            set = function (value)
                if value.Type == "Frame" then
                    _container = value
                end
            end
        },

        X = {
            --- Returns the MiniConsole's user-defined X coordinate.
            --- @function self.X.get
            --- @treturn number
            get = function ()
                return _x
            end,

            --- Sets the MiniConsole's user-defined X coordinate.
            --- @function self.X.set
            --- @tparam number value
            set = function (value)
                _x = value
                updateAbsolutes()
            end
        },

        AbsoluteX = {
            --- Returns the MiniConsole's actual X coordinate.
            --- @function self.AbsoluteX.get
            --- @treturn number
            get = function ()
                return _absoluteX
            end
        },

        Y = {
            --- Returns the MiniConsole's user-defined Y coordinate.
            --- @function self.Y.get
            --- @treturn number
            get = function ()
                return _y
            end,

            --- Sets the MiniConsole's user-defined Y coordinate.
            --- @function self.Y.set
            --- @tparam number value
            set = function (value)
                _y = value
                updateAbsolutes()
            end
        },

        AbsoluteY = {
            --- Returns the MiniConsole's actual Y coordinate.
            --- @function self.AbsoluteY.get
            --- @treturn number
            get = function ()
                return _absoluteY
            end
        },

        Width = {
            --- Returns the MiniConsole's user-defined width.
            --- @function self.Width.get
            --- @treturn number
            get = function ()
                return _width
            end,

            --- Sets the MiniConsole's user-defined width.
            --- @function self.Width.set
            --- @tparam number value
            set = function (value)
                _width = value
                updateAbsolutes()
            end
        },

        AbsoluteWidth = {
            --- Returns the MiniConsole's actual width.
            --- @function self.AbsoluteWidth.get
            --- @treturn number
            get = function ()
                return _absoluteWidth
            end
        },

        Height = {
            --- Returns the MiniConsole's user-defined height.
            --- @function self.Height.get
            --- @treturn number
            get = function ()
                return _height
            end,

            --- Sets the MiniConsole's user-defined height.
            --- @function self.Height.set
            --- @tparam number value
            set = function (value)
                _height = value
                updateAbsolutes()
            end
        },

        AbsoluteHeight = {
            --- Returns the MiniConsole's actual height.
            --- @function self.AbsoluteHeight.get
            --- @treturn number
            get = function ()
                return _absoluteHeight
            end
        },

        WordWrap = {
            --- Returns the MiniConsole's word wrap.
            --- @function self.WordWrap.get
            --- @treturn number|string
            get = function ()
                return _wordWrap
            end,

            --- Sets the MiniConsole's word wrap.
            --- @function self.WordWrap.set
            --- @tparam number|string value Only acceptable string is "dynamic".
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
            --- Returns the MiniConsole's actual word wrap.
            --- @function self.AbsoluteWrap.get
            --- @treturn number
            get = function ()
                return _absoluteWordWrap
            end
        },

        FontSize = {
            --- Returns the MiniConsole's font size.
            --- @function self.FontSize.get
            --- @treturn number|string
            get = function ()
                return _fontSize
            end,

            --- Sets the MiniConsole's font size.
            --- @function self.FontSize.set
            --- @tparam number|string value Only acceptable string is "dynamic".
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
            --- Returns the MiniConsole's actual font size.
            --- @function self.AbsoluteSize.get
            --- @treturn number
            get = function ()
                return _absoluteFontSize
            end
        }
    }
    --- @section end

    --- Draws the MiniConsole.
    --- Should only be called internally.
    function self:Draw ()
        if not _container then
            error(string.format("Vyzor: Tried to Draw a MiniConsole (%s) without a parent Frame.", _name), 2)
        end

        updateAbsolutes()

        createMiniConsole(_name, _absoluteX, _absoluteY, _absoluteWidth, _absoluteHeight)
        setMiniConsoleFontSize(_name, _absoluteFontSize)
        setWindowWrap(_name, _absoluteWordWrap)
    end

    --- Changes the MiniConsole's size.
    --- @number width New width of the MiniConsole.
    --- @number height New height of the MiniConsole.
    function self:Resize (width, height)
        _width = width or _width
        _height = height or _height

        updateAbsolutes()

        resizeWindow(_name, _absoluteWidth, _absoluteHeight)
        setWindowWrap(_name, _absoluteWordWrap)
        setMiniConsoleFontSize(_name, _absoluteFontSize)
    end

    --- Moves the MiniConsole.
    --- @number x New relative X coordinate of the MiniConsole.
    --- @number y New relative Y coordinate of the MiniConsole.
    function self:Move (x, y)
        _x = x or _x
        _y = y or _y

        updateAbsolutes()

        moveWindow(_name, _absoluteX, _absoluteY)
    end

    --- Hides the MiniConsole.
    function self:Hide ()
        hideWindow(_name)
    end

    --- Shows the MiniConsole.
    function self:Show ()
        showWindow(_name)
    end

    --- Displays text on a MiniConsole.
    --- Starts where the last line left off.
    --- @string text
    function self:Echo (text)
        echo(_name, text)
    end

    --- Displays text on a MiniConsole with Hex color formatting.
    --- @string text
    function self:HEcho (text)
        hecho(_name, text)
    end

    --- Displays text on a MiniConsole with colour tags.
    --- @string text
    function self:CEcho (text)
        cecho(_name, text)
    end

    --- Displays text on a MiniConsole with some crazy-ass formatting.
    --- @string text
    --- @param foregroundColor The foreground color of the text.
    --- @param backgroundColor The background color of the text.
    --- @bool useInsertText If true, uses InsertText() instead of echo().
    function self:DEcho (text, foregroundColor, backgroundColor, useInsertText)
        decho(text, foregroundColor, backgroundColor, useInsertText, _name)
    end

    --- Displays a clickable line of text in a MiniConsole.
    --- @string text
    --- @tparam function|string command Script to be executed when clicked.
    --- @string tooltipText
    --- @bool keepFormat If true, uses Frame text formatting.
    --- @bool useInsertText If true, uses InsertText() instead of Echo()
    function self:EchoLink (text, command, tooltipText, keepFormat, useInsertText)
        if not useInsertText then
            echoLink(_name, text, command, tooltipText, keepFormat)
        else
            insertLink(_name, text, command, tooltipText, keepFormat)
        end
    end

    --- Clickable text that expands out to a menu.
    --- @string text
    --- @tparam table commands A table of scripts to be executed.
    --- @tparam table tooltipTexts A table of tooltips.
    --- @bool keepFormat If true, uses MiniConsole text formatting.
    --- @bool useInsertText If true, uses InsertText() instead of Echo()
    function self:EchoPopup (text, commands, tooltipTexts, keepFormat, useInsertText)
        if not useInsertText then
            echoPopup(_name, text, commands, tooltipTexts, keepFormat)
        else
            insertPopup(_name, text, commands, tooltipTexts, keepFormat)
        end
    end

    --- Copies text to the MiniConsole from the clipboard (via copy()).
    --- Clears the window first.
    function self:Paste ()
        selectCurrentLine()
        copy()
        paste(_name)
    end

    --- Copies text to the MiniConsole from a buffer or the clipboard (via copy()).
    --- Adds the text beginning at a new line.
    function self:Append ()
        selectCurrentLine()
        copy()
        appendBuffer(_name)
    end

    --- Clears all text from the MiniConsole
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
