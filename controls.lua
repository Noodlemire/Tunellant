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

core.controls = {}
local this = core.controls

local keyboard = love.keyboard

function this.init()
	this.up = 'up'
	this.down = 'down'
	this.left = 'left'
	this.right = 'right'

	local buttonMap = 
	{
		--[button] = function
	}

	local unButtonMap = 
	{
		--[button] = function
	}

	function this.process(key)
		if type(buttonMap[key]) == "function" then
			buttonMap[key]()
		end
	end

	function this.unprocess(key)
		if type(unButtonMap[key]) == "function" then
			unButtonMap[key]()
		end
	end

	--lower bound key and upper bound key
	local function makejoystick(lbkey, ubkey)
		local value = 0

		if keyboard.isDown(lbkey) then
			value = value - 1
		end

		if keyboard.isDown(ubkey) then
			value = value + 1
		end

		return value
	end

	function this.joystickX()
		return makejoystick(this.left, this.right)
	end

	function this.joystickY()
		return makejoystick(this.down, this.up)
	end
end
