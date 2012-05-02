-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Frame 	= require( "vyzor.base.frame" )
local Options 	= require( "vyzor.base.options" )

local window_width, window_height = getMainWindowSize()
--[[
	Structure: HUD
		This is the primary Vyzor <Frame>, responsible for managing
		all other Frames. The HUD itself is not a Label, but it
		does create and maintain four Frames as Labels that give
		shape to Mudlet's Borders.
]]
local HUD = Frame( "Vyzor", 0, 0, window_width, window_height )
HUD.IsBounding = true

-- Double: console_width
-- The width of the main console.
local console_width = getMainConsoleWidth()

-- Double: console_height
-- The height of the main console.
-- Currently set manually via Vyzor.Options.
local console_height = Options.ConsoleHeight

-- Array: borders
-- Contains Vyzor's Border information. Used to manage
-- Mudlet's Borders.
local borders = {}

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
	local new_borders = {}

	-- A function local function that may have been called
	-- multiple times once. Or I thought it should be.
	-- Calculates values for Borders that are NOT set
	-- dynamically.
	local function calculate (border, space)
		if not space then
			if border == "Top" or border == "Bottom" then
				space = window_height
			else
--				space = window_width - ((border == "Right" and 15) or 0)
				space = window_width
			end
		end

		if options[border] > 0 and options[border] <= 1.0 then
			new_borders[border] = space * options[border]
		else
			new_borders[border] = options[border]
		end
	end

	-- Iterates through each Border, setting its value. If it's not set
	-- dynamically, it's simple math to get its size. If it is set dynamically,
	-- however, we must know how much space is remaining, which means we
	-- must know the size of the opposite Border.
	for _,border in ipairs({"Top", "Bottom", "Left", "Right"}) do
		if options[border] ~= "dynamic" then
			calculate( border )
		else
			-- Some placeholders for values we'll need later.
			local box
			local space
			local opposite
			if border == "Top" or border == "Bottom" then
				box = window_height
				space = window_height - console_height
				opposite = (border == "Top" and "Bottom") or "Top"
			else
				box = window_width
				space = window_width - console_width
				opposite = (border == "Left" and "Right") or "Left"
			end

			-- Both Borders are dynamic. YaY! This makes it easy.
			if options[opposite] == "dynamic" then
				new_borders[border] = space/2
			-- Only one side is dynamic. Now we must maths. =(
			else
				-- The other side has already been calculated. Makes this easy.
				if new_borders[opposite] then
					new_borders[border] = space - new_borders[opposite]
				-- Other side has not been calculated. So we figure it out.
				else
					if options[opposite] > 0 and options[opposite] <= 1.0 then
						new_borders[border] = space - (box * options[opposite])
					else
						new_borders[border] = space - options[opposite]
					end
				end
			end
		end
	end

	-- Here we actually tell Mudlet what size our Borders should be.
	setBorderTop( new_borders.Top )
	setBorderBottom( new_borders.Bottom )
	setBorderRight( new_borders.Right )
	setBorderLeft( new_borders.Left )

	-- And update it to use later.
	borders = new_borders
end

-- Initialize Border sizes.
updateBorders()

-- Here we define the Border Frames. For the most part, these use the values
-- we generated in updateBorders. However, because of the way Frames handle
-- their sizing, it's necessary to sometimes send the "raw" size (i.e.,
-- the value set in the options).
-- I think.

-- Object: VyzorTop
-- The Frame defined by Mudlet's top border.
local top = Frame( "VyzorTop",
	0,
	0,
	1.0,
	(Options.Borders["Top"] == "dynamic" and borders["Top"]) or Options.Borders["Top"]
)

-- Object: VyzorBottom
-- The Frame defined by Mudlet's bottom border.
local bottom = Frame( "VyzorBottom",
	0,
	-- This messy bit says...
	-- local var
	-- if Options.Borders["Bottom"] is "dynamic" then y = window - borders["Bottom"]
	-- else
	-- if Options.Borders["Bottom"] is between 0 and 1.0 then var = 1.0
	-- else
	-- var = window_height
	-- y = var - Options.Borders["Bottom"]
	(Options.Borders["Bottom"] == "dynamic" and (window_height - borders["Bottom"])) or
		((((Options.Borders["Bottom"] > 0 and Options.Borders["Bottom"] <= 1.0) and 1.0) or
			window_height) - Options.Borders["Bottom"]),
	1.0,
	Options.Borders["Bottom"]
)

-- Object: VyzorRight
-- The Frame defined by Mudlet's right border.
local right = Frame( "VyzorRight",
	-- Solve for x.
	-- I thought these bits were clever. Go me. =\
	(Options.Borders["Right"] == "dynamic" and (window_width - borders["Right"])) or
		((((Options.Borders["Right"] > 0 and Options.Borders["Right"] <= 1.0) and 1.0) or
			window_width) - Options.Borders["Right"]),
	0,
	(Options.Borders["Right"] == "dynamic" and borders["Right"]) or Options.Borders["Right"],
	1.0
)

-- Object: VyzorLeft
-- The Frame defined by Mudlet's left border.
local left = Frame( "VyzorLeft",
	0,
	0,
	(Options.Borders["Left"] == "dynamic" and borders["Left"]) or Options.Borders["Left"],
	1.0
)

-- Add our Border Frames to Vyzor.
HUD:Add( top )
HUD:Add( bottom )
HUD:Add( right )
HUD:Add( left )


-- I hate to do this, but must make a global function to handle resize. =\
local resizing
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
	if not resizing then
		resizing = true
		window_width, window_height = getMainWindowSize()
		updateBorders()

		HUD.Size.Dimensions = {window_width, window_height}
		if Options.Borders["Top"] == "dynamic" then
			HUD.Frames["VyzorTop"].Size.Height = (borders.Top <= 1 and 0) or borders.Top
		end
		if Options.Borders["Bottom"] == "dynamic" then
			HUD.Frames["VyzorBottom"].Size.Height = (borders.Bottom <= 1 and 0) or borders.Bottom
			HUD.Frames["VyzorBottom"].Position.Y = window_height - borders.Bottom
		end
		if Options.Borders["Right"] == "dynamic" then
			HUD.Frames["VyzorRight"].Size.Width = (borders.Right <= 1 and 0) or borders.Right
			HUD.Frames["VyzorRight"].Position.X = window_width - borders.Right
		end
		if Options.Borders["Left"] == "dynamic" then
			HUD.Frames["VyzorLeft"].Size.Width = (borders.Left <= 1 and 0) or borders.Left
		end

		HUD:Resize( HUD.Size.ContentWidth, HUD.Size.ContentHeight )
		HUD:Move( 0, 0 )
		resizing = false
	end
end

registerAnonymousEventHandler( "sysWindowResizeEvent", "VyzorResize")

return HUD
