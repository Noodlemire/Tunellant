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
	core.player = core.actor.new("player", core.assets.player, core.assets.player_xray, 9, 9, nil, {
		on_step = function(self)
			local j = core.utils.vector_normalize({x = controls.joystickX(), y = -controls.joystickY()})
			local r = controls.joystickR()
			local s = controls.joystickS()

			local dist = core.utils.vector_length(j) / 16

			if s < 0 then
				dist = dist / 2
				r = r / 4
			elseif s > 0 then
				dist = dist * 2
				r = r * 4
			end

			self:set_yaw(self:get_yaw() + r)

			self:move(dist, self:get_yaw() + core.utils.d_atan(j.x, j.y))
		end,
	})
end
