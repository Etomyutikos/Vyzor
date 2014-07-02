-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

--[[
    Structure: Vyzor
        The primary Vyzor module, which holds all other modules.
]]
local Vyzor = {
    -- Object: Frame
    -- See Frame.
    Frame = require("vyzor.base.frame"),

    --[[
        Objects: Components
            Background - See Background.
            Border - See Border.
            BorderSide - See BorderSide.
            Brush - See Brush.
            Color - See Color.
            Font - See Font.
            Gradient - See Gradient.
            Hover - See Hover.
            Image - See Image.
            Map - See Map.
            Margin - See Margin.
            MiniConsole - See MiniConsole.
            Padding - See Padding.
    ]]
    Background = require("vyzor.component.background"),
    Border = require("vyzor.component.border"),
    BorderSide = require("vyzor.component.border_side"),
    Brush = require("vyzor.component.brush"),
    Color = require("vyzor.component.color"),
    Font = require("vyzor.component.font"),
    Gradient = require("vyzor.component.gradient"),
    Hover = require("vyzor.component.hover"),
    Image = require("vyzor.component.image"),
    Map = require("vyzor.component.map"),
    Margin = require("vyzor.component.margin"),
    MiniConsole = require("vyzor.component.mini_console"),
    Padding = require("vyzor.component.padding"),

    --[[
        Objects: Enums
            Alignment - See Alignment.
            BorderStyle - See BorderStyle.
            BoundingMode - See BoundingMode.
            BoxMode - See BoxMode.
            ColorMode - See ColorMode.
            FontDecoration - See FontDecoration.
            FontStyle - See FontStyle.
            FontWeight - See FontWeight.
            GaugeFill - See GaugeFill.
            GradientMode - See GradientMode.
            Repeat - See Repeat.
            TabLocation - See TabLocation.
    ]]
    Alignment = require("vyzor.enum.alignment"),
    BorderStyle = require("vyzor.enum.border_style"),
    BoundingMode = require("vyzor.enum.bounding_mode"),
    BoxMode = require("vyzor.enum.box_mode"),
    ColorMode = require("vyzor.enum.color_mode"),
    FontDecoration = require("vyzor.enum.font_decoration"),
    FontStyle = require("vyzor.enum.font_style"),
    FontWeight = require("vyzor.enum.font_weight"),
    GaugeFill = require("vyzor.enum.gauge_fill"),
    GradientMode = require("vyzor.enum.gradient_mode"),
    Repeat = require("vyzor.enum.repeat"),
    TabLocation = require("vyzor.enum.tab_location"),

    --[[
        Objects: Compounds
            Box - See Box.
            Chat - See Chat.
            Gauge - See Gauge.
    ]]
    Box = require("vyzor.compound.box"),
    Chat = require("vyzor.compound.chat"),
    Gauge = require("vyzor.compound.gauge"),

    -- Object: Options
    -- See Options.
    Options = require("vyzor.base.options"),

    -- Object: HUD
    -- See HUD.
    HUD = require("vyzor.base.hud"),
}

if exists("vyzor", "alias") == 0 then
    permGroup("vyzor", "alias")
end

if exists("Vyzor Help", "alias") == 0 then
    permAlias("Vyzor Help", "vyzor", [[^vy(?:zor)?\s?h(?:elp)?$]],
        [[
if openWebPage then
    openWebPage(getMudletHomeDir():gsub("\\", "/") .. "/vyzor/doc/index.html")
else
    openUrl(getMudletHomeDir():gsub("\\", "/") .. "/vyzor/doc/index.html")
end
        ]]
)
end

setmetatable(Vyzor, {
    __index = function (_, key)
        return Vyzor.HUD.Frames["Vyzor" .. key]
    end,
    __newindex = function (_, key, value)
        error("Vyzor: May not write directly to Vyzor table.", 2)
    end,
})
return Vyzor
