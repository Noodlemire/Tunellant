--[[
Tunnellant
Copyright (C) 2020 Noodlemire

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
--]]

core.assets = {}

local this = core.assets
local load = love.graphics

local dir = "assets/"

local function loadNewImage(image)
	return load.newImage(dir..image..".png")
end

function this.load()
	this.missing = loadNewImage("nil")
	this.grid = loadNewImage("grid")

	this.player = loadNewImage("player")
	this.player_xray = loadNewImage("player_xray")

	this.black = loadNewImage("black")
	this.clay = loadNewImage("clay")
	this.copper = loadNewImage("copper")
	this.dirt = loadNewImage("dirt")
	this.iron = loadNewImage("iron")
	this.stone = loadNewImage("stone")
end
