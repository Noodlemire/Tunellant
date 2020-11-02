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

core.actor = {}
local actors = {}



local u = core.utils

local static = {
	die = function(self)
		actors[self:get_id()] = false
	end,

	draw = function(self, canvas)
		canvas.draw(self:get_image(),
			core.player:get_pos().x - core.player:get_pos().x + canvas.getWidth() / 2 - 8,
			core.player:get_pos().y - core.player:get_pos().y + canvas.getHeight() / 2 - 8,
			0, core.scale, core.scale)
	end,

	get_hp = function(self)
		return rawget(self, "hp")
	end,
	get_id = function(self)
		return rawget(self, "id")
	end,
	get_image = function(self)
		return rawget(self, "image")
	end,
	get_max_hp = function(self)
		return rawget(self, "max_hp")
	end,
	get_name = function(self)
		return rawget(self, "name")
	end,
	get_pos = function(self)
		return rawget(self, "pos")
	end,

	move = function(self, dir)
		local pos = {x = self:get_pos().x, y = self:get_pos().y}
		pos.x = pos.x + tonumber(dir.x)
		pos.y = pos.y + tonumber(dir.y)
		self:set_pos(pos)

		return self
	end,

	set_hp = function(self, hp)
		if hp <= 0 then
			self:die()
		else
			rawset(self, "hp", math.min(self:get_max_hp(), hp))
		end
	end,

	set_pos = function(self, pos)
		pos = pos or self:get_pos()
		rawset(self:get_pos(), "x", tonumber(pos.x or self:get_pos().x))
		rawset(self:get_pos(), "y", tonumber(pos.y or self:get_pos().y))
	end,

	newindex = function()
		error("Error: Attempt to directly set a value in an actor object. Please call one of the provided functions instead.")
	end,
}



function core.actor.new(name, image, x, y, properties, functions, init_func)
	properties = properties or {}

	properties.name = tostring(name)
	properties.image = image
	properties.pos = setmetatable({x = tonumber(x), y = tonumber(y)}, {
		__newindex = static.newindex,
		__metatable = {},
	})
	properties.id = #actors + 1

	properties.max_hp = properties.max_hp or 1
	properties.hp = properties.max_hp

	funcitons = functions and u.copy_functions(functions) or {}

	functions.die = functions.die or static.die
	functions.draw = functions.draw or static.draw
	functions.get_hp = functions.get_hp or static.get_hp
	functions.get_id = functions.get_id or static.get_id
	functions.get_image = functions.get_image or static.get_image
	functions.get_max_hp = functions.get_max_hp or static.get_max_hp
	functions.get_name = functions.get_name or static.get_name
	functions.get_pos = functions.get_pos or static.get_pos
	functions.move = functions.move or static.move
	functions.set_hp = functions.get_hp or static.set_hp
	functions.set_pos = functions.set_pos or static.set_pos

	local actor = setmetatable(properties, {
		__index = functions,
		__newindex = static.newindex,
		__metatable = {},
	})

	if init_func then
		actor = init_func(actor)
	end

	if actor then
		actors[actor:get_id()] = actor
		return actor
	end
end

function core.actor.count()
	return #actors
end

function core.actor.get(id)
	return actors[id]
end

function core.actor.iterate()
	local i = 0

	return function()
		i = i + 1

		while not core.actor.get(i) and i < core.actor.count() do
			i = i + 1
		end

		if core.actor.get(i) then
			return i, core.actor.get(i)
		end
	end
end