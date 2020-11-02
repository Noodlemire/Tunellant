core = {}

math.randomseed(os.time())
math.random()

dofile("utils.lua")
dofile("assets.lua")
dofile("controls.lua")

dofile("actors/actor.lua")
dofile("actors/player.lua")

dofile("terrain/smartVectorTable.lua")
dofile("terrain/terrain.lua")

local utils = core.utils
local assets = core.assets
local controls = core.controls

local actor = core.actor
local terra = core.terrain
local graphs = love.graphics
graphs.setDefaultFilter("nearest")

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

core.paused = false

local TEXT_PERIOD = 100
local doText = TEXT_PERIOD
local text = "Load complete."

core.scale = 4

function love.load()
	assets.load()
	core.new_player()
	controls.init()

	for x = 1, 16 do
		for y = 1, 16 do
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
		end
	end
end

function love.update(dt)
	if paused then return end

	for _, a in actor.iterate() do
		a:on_step()
	end
end
 
function love.draw()
	for v, t in terra.v_iterate() do
		t:draw(graphs, v)
	end

	for _, a in actor.iterate() do
		a:draw(graphs)
	end

	if doText > 0 then
		doText = doText - 1

		if doText == 0 then
			text = 0
		end
	end

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
