--- Defines options for aligning content within various Components.
-- @classmod Alignment

local Enum = require("vyzor.enum")

--- Alignment options.
-- @table Alignment
local _enum = {
  Top = "top",
  TopLeft = "top left",
  TopRight = "top right",
  TopCenter = "top center",
  Bottom = "bottom",
  BottomLeft = "bottom left",
  BottomRight = "bottom right",
  BottomCenter = "bottom center",
  Left = "left",
  LeftCenter = "left center",
  Right = "right",
  RightCenter = "right center",
  Center = "center",
}

local Alignment = Enum("Alignment", _enum)

return Alignment