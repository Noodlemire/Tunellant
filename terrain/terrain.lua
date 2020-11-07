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

core.terrain = {}
local map = core.smartVectorTable()
local vmap = core.smartVectorTable()



local u = core.utils

local function quadrangle(mesh, x1, y1, x2, y2, x3, y3, x4, y4)
	mesh:setVertices({{x1, y1, 0, 1}, {x2, y2, 1, 1}, {x3, y3, 1, 0}, {x4, y4, 0, 0}})

	return mesh
end

local static = {
	draw = function(self, canvas, v)
		if self:get_image() then
			local x, y, z = v.x, v.y, math.ceil(v.z / 2)

			if z - core.player:get_height() > 1 or z - core.player:get_height() < -6 then return end

			local dist = core.utils.distance(core.player:get_pos(), {x=x*16, y=y*16})

			if dist > 240 then return end

			local dir = core.utils.direction(core.player:get_pos(), {x=x*16, y=y*16})
			local yaw = core.player:get_yaw()

			if dist > 32 and (dir + yaw + 225) % 360 > 90 then return end

			local d1 = not core.terrain.v_get(x + 1, y, v.z)
			local d2 = not core.terrain.v_get(x - 1, y, v.z)
			local d3 = not core.terrain.v_get(x, y + 1, v.z)
			local d4 = not core.terrain.v_get(x, y - 1, v.z)
			local d5 = not core.terrain.v_get(x, y, v.z + 1)

			if not (d1 or d2 or d3 or d4 or d5) then return end

			local height_offset = 1 + 0.05 * (z - core.player:get_height() + 1)
			local depth_offset = height_offset - 0.05

			local rel_x, rel_y = x * 16 * core.scale, y * 16 * core.scale

			local top_x = (rel_x - core.player:get_pos().x * core.scale) * height_offset + canvas.getWidth() / 2 - 8
			local top_y = (rel_y - core.player:get_pos().y * core.scale) * height_offset + canvas.getHeight() / 2 - 8

			local t_x, t_y = 0, 0
			local h2 = 16 * height_offset * core.scale

			if v.z % 2 == 1 then
				local bot_x = (rel_x - core.player:get_pos().x * core.scale) * depth_offset + canvas.getWidth() / 2 - 8
				local bot_y = (rel_y - core.player:get_pos().y * core.scale) * depth_offset + canvas.getHeight() / 2 - 8

				local b_x, b_y = (bot_x - top_x), (bot_y - top_y)
				local h1 = 16 * depth_offset * core.scale

				if d2 and rel_x > core.player:get_pos().x * core.scale then
					canvas.draw(quadrangle(self.mesh[2], b_x, b_y, b_x, b_y + h1, t_x, t_y + h2, t_x, t_y),
						top_x, top_y, 0)
				elseif d1 and rel_x + 16 * core.scale < core.player:get_pos().x * core.scale then
					canvas.draw(quadrangle(self.mesh[1], b_x + h1, b_y, b_x + h1, b_y + h1, t_x + h2, t_y + h2, t_x + h2, t_y),
						top_x, top_y, 0)
				end

				if d4 and rel_y > core.player:get_pos().y * core.scale then
					canvas.draw(quadrangle(self.mesh[4], b_x + h1, b_y, b_x, b_y, t_x, t_y, t_x + h2, t_y),
						top_x, top_y, 0)
				elseif d3 and rel_y + 16 * core.scale < core.player:get_pos().y * core.scale then
					canvas.draw(quadrangle(self.mesh[3], b_x, b_y + h1, b_x + h1, b_y + h1, t_x + h2, t_y + h2, t_x, t_y + h2),
						top_x, top_y, 0)
				end
			elseif d5 then
				self.mesh[5]:setTexture(self:get_image())
				canvas.draw(quadrangle(self.mesh[5], t_x, t_y + h2, t_x + h2, t_y + h2, t_x + h2, t_y, t_x, t_y),
					top_x, top_y, 0)
			elseif z - core.player:get_height() == 1 then
				self.mesh[5]:setTexture(core.assets.black)
				canvas.draw(quadrangle(self.mesh[5], t_x, t_y + h2, t_x + h2, t_y + h2, t_x + h2, t_y, t_x, t_y),
					top_x, top_y, 0)
			end
		end
	end,

	get_hardness = function(self)
		return rawget(self, "hardness")
	end,
	get_image = function(self)
		return rawget(self, "image")
	end,
	get_name = function(self)
		return rawget(self, "name")
	end,

	newindex = function()
		error("Error: Attempt to directly set a value in a terrain object. Please call one of the provided functions instead.")
	end,
}



function core.terrain.new(name, image, hardness, x, y, height)
	x = u.round(x)
	y = u.round(y)

	height = height or 0

	local terrain = setmetatable({
		name = name,
		image = image,
		hardness = hardness
	}, {
		__index = {
			mesh = {},

			draw = static.draw,
			get_hardness = static.get_hardness,
			get_image = static.get_image,
			get_name = static.get_name,
		},

		__newindex = static.newindex,
		__metatable = {}
	})

	for i = 1, 5 do
		terrain.mesh[i] = love.graphics.newMesh({{0, 1, 0, 1}, {1, 1, 1, 1}, {1, 0, 1, 0}, {0, 0, 0, 0}})
		terrain.mesh[i]:setTexture(image)
	end

	map.set({x=x, y=y, z=height}, terrain)
	vmap.set({x=x, y=y, z=height * 2}, terrain)
	if height > 0 then
		vmap.set({x=x, y=y, z=height * 2 - 1}, terrain)
	end

	return terrain
end

function core.terrain.size()
	return map.size()
end

function core.terrain.v_size()
	return vmap.size()
end

function core.terrain.get(x, y, z)
	local v = x

	if type(x) ~= "table" then
		v = {
			x = u.round(x),
			y = u.round(y),
			z = u.round(z or 1),
		}
	else
		v.x = u.round(v.x)
		v.y = u.round(v.y)
		v.z = u.round(v.z or 1)
	end

	return map.get(v)
end

function core.terrain.v_get(x, y, z)
	local v = x

	if type(x) ~= "table" then
		v = {
			x = u.round(x),
			y = u.round(y),
			z = u.round(z or 1),
		}
	else
		v.x = u.round(v.x)
		v.y = u.round(v.y)
		v.z = u.round(v.z or 1)
	end

	return vmap.get(v)
end

function core.terrain.iterate()
	local i = 0

	return function()
		i = i + 1

		if i <= core.terrain.size() then
			return map.getVector(i), map.getValue(i)
		end
	end
end

function core.terrain.v_iterate()
	local i = 0

	return function()
		i = i + 1

		if i <= core.terrain.v_size() then
			return vmap.getVector(i), vmap.getValue(i)
		end
	end
end



function core.terrain.grid(x, y)
	core.terrain.new("grid", core.assets.grid, 0, x, y, 0)
end

function core.terrain.dirt(x, y)
	core.terrain.new("dirt", core.assets.dirt, 1, x, y, 1)
end

function core.terrain.clay(x, y)
	core.terrain.new("clay", core.assets.clay, 2, x, y, 2)
end

function core.terrain.stone(x, y)
	core.terrain.new("stone", core.assets.stone, 3, x, y, 3)
end

function core.terrain.copper(x, y)
	core.terrain.new("copper", core.assets.copper, 4, x, y, 4)
end

function core.terrain.iron(x, y)
	core.terrain.new("iron", core.assets.iron, 5, x, y, 5)
end
