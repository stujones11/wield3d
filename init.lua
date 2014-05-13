dofile(minetest.get_modpath(minetest.get_current_modname()).."/location.lua")

local update_time = 2 -- number of seconds between wielditem updates
local location = {
	"Arm_Right",           -- default bone
	{x=0.2, y=5.5, z=3},   -- default position
	{x=-100, y=225, z=90}, -- default rotation
}
local player_wielding = {}
local timer = 0

local function add_wield_entity(player)
	local name = player:get_player_name()
	local pos = player:getpos()
	local inv = player:get_inventory()
	if name and pos and inv then
		local object = minetest.add_entity(pos, "wield3d:wield_entity")
		if object then
			object:set_attach(player, location[1], location[2], location[3])
			local entity = object:get_luaentity()
			if entity then
				entity.player = player
				player_wielding[name] = 1
			else
				object:remove()
			end
		end
	end
end

minetest.register_item("wield3d:hand", {
	type = "none",
	wield_image = "wield3d_trans.png",
})

minetest.register_entity("wield3d:wield_entity", {
	physical = false,
	collisionbox = {x=0, y=0, z=0},
	visual = "wielditem",
	visual_size = {x=0.25, y=0.25},
	textures = {"wield3d:hand"},
	player = nil,
	item = nil,
	timer = 0,
	location = {location[1], location[2], location[3]},
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer < update_time then
			return
		end
		self.timer = 0
		local player = self.player
		if player then
			local pos = player:getpos()
			if pos then
				local stack = player:get_wielded_item()
				local item = stack:get_name()
				if item == self.item then
					return
				end
				self.item = item
				if item == "" then
					item = "wield3d:hand"
				end
				local loc = wield3d_location[item] or location
				if loc[1] ~= self.location[1]
				or vector.equals(loc[2], self.location[2]) == false
				or vector.equals(loc[3], self.location[3]) == false then
					self.object:setpos(pos)
					self.object:set_detach()
					self.object:set_attach(player, loc[1], loc[2], loc[3])
					self.location = {loc[1], loc[2], loc[3]}
				end
				self.object:set_properties({textures={item}})
				return
			end
		end
		self.object:remove()
	end,
})

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer > 10 then
		for name, state in pairs(player_wielding) do
			if state == 0 then
				local player = minetest.get_player_by_name(name)
				if player then
					add_wield_entity(player)
				else
					player_wielding[name] = nil
				end
			end
		end
		timer = 0
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	if name then
		player_wielding[name] = nil
	end
end)

minetest.register_on_joinplayer(function(player)
	default.player_set_model(player, "wield3d_character.b3d")
	player_wielding[player:get_player_name()] = 0
	minetest.after(1, add_wield_entity, player)
end)

default.player_register_model("wield3d_character.b3d", {
	animation_speed = 30,
	textures = {"character.png"},
	animations = {
		stand = {x=0, y=79},
		lay = {x=162, y=166},
		walk = {x=168, y=187},
		mine = {x=189, y=198},
		walk_mine = {x=200, y=219},
		sit = {x=81, y=160},
	},
})

