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

local controls = core.controls

core.new_player = function()
	core.player = core.actor.new("player", core.assets.player, 280, 280, nil, {
		draw = function(self, canvas)
			--canvas.draw(self:get_image(), canvas.getWidth() / 2 - 8 * core.scale, canvas.getHeight() / 2 - 8 * core.scale, 0, core.scale, core.scale)
			core.print("{x="..self:get_pos().x..", y="..self:get_pos().y.."} FPS: "..love.timer.getFPS())
		end,

		on_step = function(self)
			local jx = controls.joystickX() * core.scale
			local jy = -controls.joystickY() * core.scale

			self:move({x = jx, y = jy})
		end,
	})
end
