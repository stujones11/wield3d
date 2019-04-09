--[[

MIT License

Copyright (c) 2019 stujones11, Stuart Jones

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

]]--

wield3d = {}

dofile(minetest.get_modpath(minetest.get_current_modname()).."/location.lua")

local player_wielding = {}
local has_wieldview = minetest.get_modpath("wieldview")
local update_time = minetest.settings:get("wield3d_update_time")
local verify_time = minetest.settings:get("wield3d_verify_time")
local wield_scale = minetest.settings:get("wield3d_scale")

update_time = update_time and tonumber(update_time) or 1
verify_time = verify_time and tonumber(verify_time) or 10
wield_scale = wield_scale and tonumber(wield_scale) or 0.25 -- default scale

local default_bone = "Arm_Right"
local default_position = {x=0, y=5.5, z=3}
local default_rotation = {x=-90, y=225, z=90}
local default_scale = {x=wield_scale, y=wield_scale}

local function add_wield_entity(player)
	if not player or not player:is_player() then
		return
	end
	local name = player:get_player_name()
	local pos = player:get_pos()
	if name and pos and not player_wielding[name] then
		pos.y = pos.y + 0.5
		local object = minetest.add_entity(pos, "wield3d:wield_entity", name)
		if object then
			object:set_attach(player, default_bone, default_position,
				default_rotation)
			object:set_properties({
				textures = {"wield3d:hand"},
				visual_size = default_scale,
			})
			player_wielding[name] = true
		end
	end
end

local function sq_dist(a, b)
	local x = a.x - b.x
	local y = a.y - b.y
	local z = a.z - b.z
	return x * x + y * y + z * z
end

local wield_entity = {
	physical = false,
	collisionbox = {-0.125,-0.125,-0.125, 0.125,0.125,0.125},
	visual = "wielditem",
	textures = {"wield3d:hand"},
	wielder = nil,
	timer = 0,
	static_save = false,
}

function wield_entity:on_activate(staticdata)
	if staticdata and staticdata ~= "" then
		self.wielder = staticdata
		return
	end
	self.object:remove()
end

function wield_entity:on_step(dtime)
	if self.wielder == nil then
		return
	end
	self.timer = self.timer + dtime
	if self.timer < update_time then
		return
	end
	local player = minetest.get_player_by_name(self.wielder)
	if player == nil or not player:is_player() or
			sq_dist(player:get_pos(), self.object:get_pos()) > 3 then
		self.object:remove()
		return
	end
	local stack = player:get_wielded_item()
	local item = stack:get_name() or ""
	if has_wieldview then
		local def = minetest.registered_items[item] or {}
		if def.inventory_image ~= "" then
			item = ""
		end
	end
	if item == "" then
		item = "wield3d:hand"
	end
	local location = wield3d.location[item] or {}
	local bone = location[1] or default_bone
	local position = location[2] or default_position
	local rotation = location[3] or default_rotation
	local scale = location[4] or default_scale
	self.object:set_attach(player, bone, position, rotation)
	self.object:set_properties({
		textures = {item},
		visual_size = scale,
	})
	self.timer = 0
end

local function table_iter(t)
	local i = 0
	local n = table.getn(t)
	return function ()
		i = i + 1
		if i <= n then
			return t[i]
		end
	end
end

local player_iter = nil

local function verify_wielditems()
	if player_iter == nil then
		local names = {}
		local tmp = {}
		for player in table_iter(minetest.get_connected_players()) do
			local name = player:get_player_name()
			if name then
				tmp[name] = true;
				table.insert(names, name)
			end
		end
		player_iter = table_iter(names)
		-- clean-up player_wielding table
		for name, _ in pairs(player_wielding) do
			player_wielding[name] = tmp[name]
		end
	end
	 -- only deal with one player per server step
	local name = player_iter()
	if name then
		local player = minetest.get_player_by_name(name)
		if player and player:is_player() then
			local pos = player:get_pos()
			pos.y = pos.y + 0.5
			local wielding = false
			local objects = minetest.get_objects_inside_radius(pos, 1)
			for object in table_iter(objects) do
				local entity = object:get_luaentity()
				if entity and entity.wielder == name then
					if wielding then
						-- remove duplicates
						object:remove()
					end
					wielding = true
				end
			end
			if not wielding then
				player_wielding[name] = nil
				add_wield_entity(player)
			end
		end
		return minetest.after(0, verify_wielditems)
	end
	player_iter = nil
	minetest.after(verify_time, verify_wielditems)
end

minetest.after(verify_time, verify_wielditems)

minetest.register_entity("wield3d:wield_entity", wield_entity)

minetest.register_item("wield3d:hand", {
	type = "none",
	wield_image = "blank.png",
})

minetest.register_on_joinplayer(function(player)
	minetest.after(2, add_wield_entity, player)
end)
