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

core = {}

math.randomseed(os.time())
math.random()

local load = function(f)
	love.filesystem.load(f)()
end

load("utils.lua")
load("assets.lua")
load("controls.lua")

load("actors/actor.lua")
load("actors/player.lua")

load("terrain/smartVectorTable.lua")
load("terrain/wall.lua")
load("terrain/terrain.lua")

local utils = core.utils
local assets = core.assets
local controls = core.controls

local actor = core.actor
local terra = core.terrain
local graphs = love.graphics
graphs.setDefaultFilter("nearest")

core.paused = false

local TEXT_PERIOD = 100
local doText = TEXT_PERIOD
local text = "Load complete."

core.scale = 32

function love.load()
	assets.load()
	core.new_player()
	controls.init()

	local x = 1

	while x <= 32 do
		local y = 1

		while y <= 32 do
			if utils.distance({x=x, y=y}, {x=8.5, y=8.5}) > 3 then
				local i = math.random(1, 5)

				if i == 1 then
					core.terrain.dirt(x, y)
				elseif i == 2 then
					core.terrain.clay(x, y)
				elseif i == 3 then
					core.terrain.stone(x, y)
				elseif i == 4 then
					core.terrain.copper(x, y)
				elseif i == 5 then
					core.terrain.iron(x, y)
				end
			else
				core.terrain.grid(x, y)
			end

			y = y + 0.9
		end

		x = x + 0.9
	end
end

function love.update(dt)
	if paused then return end

	for _, a in actor.iterate() do
		a:on_step()
	end
end
 
function love.draw()
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()


	--rotate around the center of the screen according to the player's direction
	graphs.translate(width/2, height/2)
	graphs.rotate(-core.player:get_yaw() * math.pi / 180)
	--graphs.translate(-width/2, -height/2)

	local atan = core.utils.d_atan(0, -height/3) + core.player:get_yaw()
	local c = -height/3 * core.utils.d_cos(atan)
	local s = -height/3 * core.utils.d_sin(atan)

	graphs.translate(c, s)

	for i = core.player:get_height() * 2 - 12, core.player:get_height() * 2 + 2 do
		for v, t in terra.v_iterate(i) do
			t:draw(graphs, v)
		end

		if i % 2 == 0 then
			for _, a in actor.iterate(i / 2) do
				a:draw(graphs)
			end
		end
	end

	for i = core.player:get_height() - 6, core.player:get_height() + 1 do
		for _, a in actor.iterate(i) do
			a:draw_overlay(graphs)
		end
	end

	if doText > 0 then
		doText = doText - 1

		if doText == 0 then
			text = 0
		end
	end

	graphs.translate(-c, -s)

	--Reverse the rotation so that UI elements don't turn around as well.
	--graphs.translate(width/2, height/2)
	graphs.rotate(core.player:get_yaw() * math.pi / 180)
	graphs.translate(-width/2, -height/2)

	core.print("{x="..core.player:get_pos().x..", y="..core.player:get_pos().y.."} FPS: "..love.timer.getFPS())

	graphs.print(text)
end

function love.mousepressed(x, y, button, istouch)
	if button == 1 then
	end
end

function love.mousereleased(x, y, button, istouch)
	if button == 1 then
	end
end

function love.keypressed(key, scancode, isrepeat)
	if not isrepeat then controls.process(key) end
end

function love.keyreleased(key)
	controls.unprocess(key)
end

function love.quit()
	graphs.print("Thanks for playing! Come back soon!")
end

function core.print(txt)
	doText = TEXT_PERIOD
	text = txt
end
