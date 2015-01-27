--- Vyzor, UI Manager for Mudlet
-- @module Vyzor

--- The primary interface, exposing the Vyzor API.
-- @table Vyzor
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

  Alignment = require("vyzor.enum.alignment"), --- See @{Alignment}.
  BorderStyle = require("vyzor.enum.border_style"), --- See @{BorderStyle}.
  BoundingMode = require("vyzor.enum.bounding_mode"), --- See @{BoundingMode}.
  BoxMode = require("vyzor.enum.box_mode"), --- See @{BoxMode}.
  ColorMode = require("vyzor.enum.color_mode"), --- See @{ColorMode}.
  FontDecoration = require("vyzor.enum.font_decoration"), --- See @{FontDecoration}.
  FontStyle = require("vyzor.enum.font_style"), --- See @{FontStyle}.
  FontWeight = require("vyzor.enum.font_weight"), --- See @{FontWeight}.
  GaugeFill = require("vyzor.enum.gauge_fill"), --- See @{GaugeFill}.
  GradientMode = require("vyzor.enum.gradient_mode"), --- See @{GradientMode}.
  Repeat = require("vyzor.enum.repeat"), --- See @{Repeat}.
  TabLocation = require("vyzor.enum.tab_location"), --- See @{TabLocation}.
  VyzorBorder = require("vyzor.enum.vyzorborder"), --- See @{VyzorBorder}.

  Box = require("vyzor.compound.box"), --- See @{Box}.
  Chat = require("vyzor.compound.chat"), --- See @{Chat}.
  Gauge = require("vyzor.compound.gauge"), --- See @{Gauge}.

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
  openWebPage("http://oneymus.github.io/Vyzor/")
else
  openUrl("http://oneymus.github.io/Vyzor/")
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
