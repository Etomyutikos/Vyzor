-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Frame = require("vyzor.base.frame")
local Options = require("vyzor.base.options")

local _windowWidth, _windowHeight = getMainWindowSize()
--[[
    Structure: HUD
        This is the primary Vyzor <Frame>, responsible for managing
        all other Frames. The HUD itself is not a Label, but it
        does create and maintain four Frames as Labels that give
        shape to Mudlet's Borders.
]]
local HUD = Frame("Vyzor", 0, 0, _windowWidth, _windowHeight)
HUD.IsBounding = true

-- Double: _consoleWidth
-- The width of the main console.
local _consoleWidth = getMainConsoleWidth()

-- Double: _consoleHeight
-- The height of the main console.
-- Currently set manually via Vyzor.Options.
local _consoleHeight = Options.ConsoleHeight

-- Array: _borders
-- Contains Vyzor's Border information. Used to manage
-- Mudlet's Borders.
local _borders = {
    Top = 0,
    Right = 0,
    Bottom = 0,
    Left = 0
}

--[[
    Function: updateBorders
        Updates Mudlet's Borders.
        This uses values defined in options.lua. The default is dynamic,
        which uses all available space surrounding the main console.
        This means that there is no top or bottom by default, but
        that can easily be changed. This is called every time the Mudlet
        window is resized.
]]
local function updateBorders ()
    local options = Options.Borders
    local newBorders = {}

    -- A function local function that may have been called
    -- multiple times once. Or I thought it should be.
    -- Calculates values for Borders that are NOT set
    -- dynamically.
    local function calculate (border, space)
        if not space then
            if border == "Top" or border == "Bottom" then
                space = _windowHeight
            else
                space = _windowWidth
            end
        end

        if options[border] > 0 and options[border] <= 1.0 then
            newBorders[border] = space * options[border]
        else
            newBorders[border] = options[border]
        end
    end

    -- Iterates through each Border, setting its value. If it's not set
    -- dynamically, it's simple math to get its size. If it is set dynamically,
    -- however, we must know how much space is remaining, which means we
    -- must know the size of the opposite Border.
    for _, border in ipairs({"Top", "Bottom", "Left", "Right"}) do -- TODO: Should be an Enum.
        if options[border] ~= "dynamic" then
            calculate(border)
        else
            local box
            local space
            local opposite

            if border == "Top" or border == "Bottom" then
                box = _windowHeight
                space = _windowHeight - _consoleHeight
                opposite = (border == "Top" and "Bottom") or "Top"
            else
                box = _windowWidth
                space = (_windowWidth - _consoleWidth) - 10
                opposite = (border == "Left" and "Right") or "Left"
            end

            -- Both Borders are dynamic. YaY! This makes it easy.
            if options[opposite] == "dynamic" then
                newBorders[border] = space / 2
            -- Only one side is dynamic. Now we must maths. =(
            else
                -- The other side has already been calculated. Makes this easy.
                if newBorders[opposite] then
                    newBorders[border] = space - newBorders[opposite]
                -- Other side has not been calculated. So we figure it out.
                else
                    if options[opposite] > 0 and options[opposite] <= 1.0 then
                        newBorders[border] = space - (box * options[opposite])
                    else
                        newBorders[border] = space - options[opposite]
                    end
                end
            end
        end
    end

    -- Here we actually tell Mudlet what size our Borders should be.
    for _, border in ipairs({"Top", "Bottom", "Right", "Left"}) do
        if newBorders[border] > 0 then
            _G["setBorder" .. border](newBorders[border])
        else
            _G["setBorder" .. border](0)
        end
    end

    -- And update it to use later.
    _borders = newBorders
end

if Options.HandleBorders == true then
    -- Initialize Border sizes.
    updateBorders()
end

-- Here we define the Border Frames. For the most part, these use the values
-- we generated in updateBorders. However, because of the way Frames handle
-- their sizing, it's necessary to sometimes send the "raw" size (i.e.,
-- the value set in the options).
-- I think.

-- Object: VyzorTop
-- The Frame defined by Mudlet's top border.
local top = Frame("VyzorTop",
    0,
    0,
    1.0,
    (Options.Borders["Top"] == "dynamic" and _borders["Top"]) or Options.Borders["Top"])

-- Object: VyzorLeft
-- The Frame defined by Mudlet's left border.
local left = Frame("VyzorLeft",
    0,
    0,
    (Options.Borders["Left"] == "dynamic" and _borders["Left"]) or Options.Borders["Left"],
    1.0)

local bottom
local right
do
    local function calculateBorderPosition(windowDimension, borderOption, borderValue)
        if borderOption == "dynamic" then
            return windowDimension - borderValue
        else
            if borderOption > 0 and borderOption <= 1.0 then
                return 1.0 - borderOption
            else
                return windowDimension - borderOption
            end
        end
    end

    -- Object: VyzorBottom
    -- The Frame defined by Mudlet's bottom border.
    bottom = Frame("VyzorBottom",
        0,
        calculateBorderPosition(_windowHeight, Options.Borders["Bottom"], _borders["Bottom"]),
        1.0,
        (Options.Borders["Bottom"] == "dynamic" and _borders["Bottom"]) or Options.Borders["Bottom"])

    -- Object: VyzorRight
    -- The Frame defined by Mudlet's right border.
    right = Frame("VyzorRight",
        calculateBorderPosition(_windowWidth, Options.Borders["Right"], _borders["Right"]),
        0,
        (Options.Borders["Right"] == "dynamic" and _borders["Right"]) or Options.Borders["Right"],
        1.0)
end

-- Add our Border Frames to Vyzor.
HUD:Add(top)
HUD:Add(bottom)
HUD:Add(right)
HUD:Add(left)

-- I hate to do this, but must make a global function to handle resize. =\
local _Resizing

--[[
    Event: VyzorResize
        Handles Mudlet's window resizing via anonymous Event.
        This is called whenever Mudlet is resizes. Also used to
        readjust Frames after options are changed.
]]
function VyzorResize ()
    -- If this isn't here, it tries to resize while it's
    -- resizing, which caused some kind of infinite loop.
    -- Or something. Bottom line, this makes it work
    -- efficiently. Or at all. =p
    if not _Resizing then
        _Resizing = true

        if Options.HandleBorders == true or Options.HandleBorders == "auto" then
            _windowWidth, _windowHeight = getMainWindowSize()
            _consoleWidth = getMainConsoleWidth()
            updateBorders()
        end

        local hudSize = HUD.Size
        hudSize.Dimensions = { _windowWidth, _windowHeight }

        local hudFrames = HUD.Frames
        if Options.Borders["Top"] == "dynamic" then
            hudFrames["VyzorTop"].Size.Height = (_borders.Top <= 1 and 0) or _borders.Top
        end

        do
            local bottomBorder = hudFrames["VyzorBottom"]

            if Options.Borders["Bottom"] == "dynamic" then
                bottomBorder.Size.Height = (_borders.Bottom <= 1 and 0) or _borders.Bottom
                bottomBorder.Position.Y = _windowHeight - _borders.Bottom
            else
                bottomBorder.Position.Y = _windowHeight - bottomBorder.Size.AbsoluteHeight
            end
        end

        do
            local rightBorder = hudFrames["VyzorRight"]

            if Options.Borders["Right"] == "dynamic" then
                rightBorder.Size.Width = (_borders.Right <= 1 and 0) or _borders.Right
                rightBorder.Position.X = _windowWidth - _borders.Right
            else
                rightBorder.Position.X = _windowWidth - rightBorder.Size.AbsoluteWidth
            end
        end

        if Options.Borders["Left"] == "dynamic" then
            hudFrames["VyzorLeft"].Size.Width = (_borders.Left <= 1 and 0) or _borders.Left
        end

        HUD:Resize(hudSize.ContentWidth, hudSize.ContentHeight)
        HUD:Move(0, 0)
        _Resizing = false

        raiseEvent("VyzorResizedEvent")
    end
end

return HUD
