--- Vyzor, UI Manager for Mudlet
--- @module Vyzor

-- TODO: Remove NaturalDocs comments. Replace with LuaDoc?
-- TODO: GitHub license file?

--- The primary interface, exposing the Vyzor API.
--- @table Vyzor
local Vyzor = {
    Frame = require("vyzor.base.frame"), --- See @{Frame}.

    Background = require("vyzor.component.background"), --- See @{Background}.
    Border = require("vyzor.component.border"), --- See @{Border}.
    BorderSide = require("vyzor.component.border_side"), --- See @{BorderSide}.
    Brush = require("vyzor.component.brush"), --- See @{Brush}.
    Color = require("vyzor.component.color"), --- See @{Color}.
    Font = require("vyzor.component.font"), --- See @{Font}.
    Gradient = require("vyzor.component.gradient"), --- See @{Gradient}.
    Hover = require("vyzor.component.hover"), --- See @{Hover}.
    Image = require("vyzor.component.image"), --- See @{Image}.
    Map = require("vyzor.component.map"), --- See @{Map}.
    Margin = require("vyzor.component.margin"), --- See @{Margin}.
    MiniConsole = require("vyzor.component.mini_console"), --- See @{MiniConsole}.
    Padding = require("vyzor.component.padding"), --- See @{Padding}.

    Alignment = require("vyzor.enum.alignment"), --- See 2{Alignment}.
    BorderStyle = require("vyzor.enum.border_style"), --- See 2{BorderStyle}.
    BoundingMode = require("vyzor.enum.bounding_mode"), --- See 2{BoundingMode}.
    BoxMode = require("vyzor.enum.box_mode"), --- See 2{BoxMode}.
    ColorMode = require("vyzor.enum.color_mode"), --- See 2{ColorMode}.
    FontDecoration = require("vyzor.enum.font_decoration"), --- See 2{FontDecoration}.
    FontStyle = require("vyzor.enum.font_style"), --- See 2{FontStyle}.
    FontWeight = require("vyzor.enum.font_weight"), --- See 2{FontWeight}.
    GaugeFill = require("vyzor.enum.gauge_fill"), --- See 2{GaugeFill}.
    GradientMode = require("vyzor.enum.gradient_mode"), --- See 2{GradientMode}.
    Repeat = require("vyzor.enum.repeat"), --- See 2{Repeat}.
    TabLocation = require("vyzor.enum.tab_location"), --- See 2{TabLocation}.
    VyzorBorder = require("vyzor.enum.vyzorborder"), --- See 2{VyzorBorder}.

    Box = require("vyzor.compound.box"), --- See 2{Box}.
    Chat = require("vyzor.compound.chat"), --- See 2{Chat}.
    Gauge = require("vyzor.compound.gauge"), --- See 2{Gauge}.

    Options = require("vyzor.base.options"), --- See @{Options}.

    HUD = require("vyzor.base.hud"), --- See @{HUD}.
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
        ]])
end

setmetatable(Vyzor, {
    __index = function(_, key)
        return Vyzor.HUD.Frames["Vyzor" .. key]
    end,
    __newindex = function(_, key, value)
        error("Vyzor: May not write directly to Vyzor table.", 2)
    end,
})
return Vyzor
