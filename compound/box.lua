--- A container that holds and maintains a dynamically arranged collection of @{Frame}s.
-- @classmod Box

local Base = require("vyzor.base")
local BoxMode = require("vyzor.enum.box_mode")
local Lib = require("vyzor.lib")

local Box = Base("Compound", "Box")

--- Box constructor.
-- @function Box
-- @string _name The name of the Box and the automatically generated container @{Frame}.
-- @tparam[opt=BoxMode.Horizontal] BoxMode initialMode Alignment of @{Frame}s.
-- @tparam Frame initialBackground The background @{Frame} for this Box.
-- @tparam table initialFrames A numerically indexed table holding the @{Frame}s this Box contains.
-- @treturn Box
local function new (_, _name, initialMode, initialBackground, initialFrames)
    assert(_name, "Vyzor: New Box must be supplied with a name")

    --- @type Box
    local self = {}

    local _mode = initialMode or BoxMode.Horizontal
    local _frames = Lib.OrderedTable()

    if initialFrames and type(initialFrames) == "table" then
        for _, frame in ipairs(initialFrames) do
            _frames[frame.Name] = frame
        end
    end

    local _backgroundFrame = initialBackground
    if _frames:count() > 0 then
        for frame in _frames:each() do
            _backgroundFrame:Add(frame)
        end
    end

    local function updateFrames()
        if _mode == BoxMode.Horizontal then
            for index, frame in _frames:ipairs() do
                frame.Position.X = (1 / _frames:count()) * (index - 1)
                frame.Position.Y = 0
                frame.Size.Width = (1 / _frames:count())
                frame.Size.Height = 1
            end
        elseif _mode == BoxMode.Vertical then
            for index, frame in _frames:ipairs() do
                frame.Position.X = 0
                frame.Position.Y = (1 / _frames:count()) * (index - 1)
                frame.Size.Width = 1
                frame.Size.Height = (1 / _frames:count())
            end
        elseif _mode == BoxMode.Grid then
            local rows = math.floor(math.sqrt(_frames:count()))
            local columns = math.ceil(_frames:count() / rows)

            local currentRow = 1
            local currentColumn = 1

            for frame in _frames:each() do
                if currentColumn > rows then
                    currentColumn = 1
                    currentRow = currentRow + 1
                end

                frame.Position.X = (1 / rows) * (currentColumn - 1)
                frame.Position.Y = (1 / columns) * (currentRow - 1)
                frame.Size.Width = (1 / rows)
                frame.Size.Height = (1 / columns)

                currentColumn = currentColumn + 1
            end
        end
    end

    --- Properties
    --- @section
    local properties = {
        Name = {
            --- Returns the name of the Box.
            --- @function self.Name.get
            --- @treturn string
            get = function ()
                return _name
            end,
        },

        Background = {
            --- Returns the background @{Frame} of the Box.
            --- @function self.Background.get
            --- @treturn Frame
            get = function ()
                return _backgroundFrame
            end,
        },

        Frames = {
            --- Returns the @{Frame}s the Box contains.
            --- @function self.Frames.get
            --- @treturn table
            get = function ()
                if _frames:count() > 0 then
                    local copy = {}

                    for k, v in _frames:pairs() do
                        copy[k] = v
                    end

                    return copy
                else
                    return {}
                end
            end,
        },

        Container = {
            --- Returns the parent @{Frame} of the Box.
            --- @function self.Container.get
            --- @treturn Frame
            get = function ()
                return _backgroundFrame.Container
            end,

            --- Sets the parent @{Frame} of the Box.
            --- @function self.Container.set
            --- @tparam Frame value
            set = function (value)
                _backgroundFrame.Container = value
            end
        },

        Mode = {
            --- Returns the @{BoxMode} of the Box.
            --- @function self.Mode.get
            --- @treturn BoxMode
            get = function ()
                return _mode
            end,

            --- Sets the @{BoxMode} of the Box.
            --- @function self.Mode.set
            --- @tparam BoxMode value
            set = function (value)
                if BoxMode:IsValid(value) then
                    _mode = value
                    updateFrames()
                else
                    error(string.format("Vyzor: Invalid BoxMode Enum passed to %s", _name), 3)
                end
            end
        },
    }
    --- @section end

    updateFrames()
    setmetatable(self, {
        __index = function (_, key)
            return (properties[key] and properties[key].get()) or Box[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end,
    })
    return self
end

setmetatable(Box, {
    __index = getmetatable(Box).__index,
    __call = new,
})
return Box
