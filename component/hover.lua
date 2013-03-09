-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require("vyzor.base")

--[[
	Class: Hover
		Defines a Hover Component.
]]
local Hover = Base( "Component", "Hover" )

--[[
	Constructor: new

	Parameters:
		init_components - A table of Components to be contained in this Hover Component.
							Optional.

	Returns:
		A new Hover Component.
]]
local function new (_, init_components )
	--[[
		Structure: New Hover
			This Component defines <Frame> behaviour on mouse-over,
			and may contain other Components much like <Frames>.
	]]
	local new_hover = {}

	-- Array: components
	-- A table of Components.
	local components = {}
	local component_count = 0

	if init_components then
		for i,v in ipairs( init_components ) do
			assert( not components[v.Subtype], "Vyzor: Attempt to add duplicate Component to Hover Component." )
			assert( v.Subtype ~= "Hover", "Vyzor: May not add Hover Component to Hover Component." )
			components[v.Subtype] = v
			component_count = component_count + 1
		end
	end

	-- String: stylesheet
	-- Hover Component's stylesheet. Generated via <updateStylesheet>.
	local stylesheet

	--[[
		Function: updateStylesheet
			Updates the Hover Component's <stylesheet>.
			The string generated is a combination of all Components'
			stylesheets.
	]]
	local function updateStylesheet ()
		if component_count > 0 then
			local style_table = {}
			for _,v in pairs( components ) do
				style_table[#style_table+1] = v.Stylesheet
			end

			-- I don't know why that opening brace is there. I assume
			-- it's some weird artifact caused by Mudlet's handling
			-- of QT's Stylesheets. But it has to be there.
			stylesheet = string.format( "}QLabel::Hover{ %s }",
				table.concat( style_table, "; " ) )
		end
	end

	--[[
		Properties: Hover Properties
			Components - Returns a table copy of Hover Component's contained Components.
			Stylesheet - Updates and returns the Hover Component's <stylesheet>.
	]]
	local properties = {
		Components = {
			get = function ()
				if component_count > 0 then
					local copy = {}
					for i in ipairs( components ) do
						copy[i] = components[i]
					end
					return copy
				end
			end,
		},
		Stylesheet = {
			get = function ()
				if not stylesheet then
					updateStylesheet()
				end
				return stylesheet
			end,
		},
	}

	--[[
		Function: Add
			Adds a new Component to the Hover Component.

		Parameters:
			component - The Component to be added.
	]]
	function new_hover:Add (component)
		if not components[component.Subtype] then
			components[component.Subtype] = component
			component_count = component_count + 1
		end
	end

	--[[
		Function: Remove
			Removes a Component from the Hover Component.

		Paramaters:
			subtype - The Subtype of the Component to be removed.
	]]
	function new_hover:Remove (subtype)
		if components[subtype] then
			components[subtype] = nil
			component_count = component_count - 1
		end
	end

	--[[
		Function: Replace
			Replaces a Component in the Hover Component.

		Parameters:
			component - The Component to be added.
	]]
	function new_hover:Replace (component)
		components[component.Subtype] = component
	end

	setmetatable( new_hover, {
		__index = function (_, key)
			return (properties[key] and properties[key].get()) or Hover[key]
		end,
		__newindex = function (_, key, value)
			if properties[key] and properties[key].set then
				properties[key].set()
			end
		end,
	} )
	return new_hover
end

setmetatable( Hover, {
	__index = getmetatable(Hover).__index,
	__call = new,
} )
return Hover
