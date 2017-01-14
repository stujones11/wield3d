wield3d = {}

dofile(minetest.get_modpath(minetest.get_current_modname()).."/location.lua")

local has_wieldview = minetest.get_modpath("wieldview")
local update_time_conf = minetest.setting_get("wield3d_update_time") or 1
local update_time = tonumber(update_time_conf) or 1
local timer = 0
local player_wielding = {}
local location = {
	"Arm_Right",          -- default bone
	{x=0, y=5.5, z=3},    -- default position
	{x=-90, y=225, z=90}, -- default rotation
	{x=0.25, y=0.25},     -- default scale
}

local function add_wield_entity(player)
	local name = player:get_player_name()
	local pos = player:getpos()
	if name and pos then
		pos.y = pos.y + 0.5
		local object = minetest.add_entity(pos, "wield3d:wield_entity")
		if object then
			object:set_attach(player, location[1], location[2], location[3])
			object:set_properties({
				textures = {"wield3d:hand"},
				visual_size = location[4],
			})
			player_wielding[name] = {}
			player_wielding[name].item = ""
			player_wielding[name].object = object
			player_wielding[name].location = location
		end
	end
end

minetest.register_item("wield3d:hand", {
	type = "none",
	wield_image = "blank.png",
})

minetest.register_entity("wield3d:wield_entity", {
	physical = false,
	collisionbox = {-0.125,-0.125,-0.125, 0.125,0.125,0.125},
	visual = "wielditem",
	on_activate = function(self, staticdata)
		if staticdata == "expired" then
			self.object:remove()
		end
	end,
	on_punch = function(self)
		self.object:remove()
	end,
	get_staticdata = function(self)
		return "expired"
	end,
})

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < update_time then
		return
	end
	local active_players = {}
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local wield = player_wielding[name]
		if wield and wield.object then
			local stack = player:get_wielded_item()
			local item = stack:get_name() or ""
			if item ~= wield.item then
				if has_wieldview then
					local def = minetest.registered_items[item] or {}
					if def.inventory_image ~= "" then
						item = ""
					end
				end
				wield.item = item
				if item == "" then
					item = "wield3d:hand"
				end
				local loc = wield3d.location[item] or location
				if loc[1] ~= wield.location[1] or
						not vector.equals(loc[2], wield.location[2]) or
						not vector.equals(loc[3], wield.location[3]) then
					wield.object:set_attach(player, loc[1], loc[2], loc[3])
					wield.location = {loc[1], loc[2], loc[3]}
				end
				wield.object:set_properties({
					textures = {item},
					visual_size = loc[4],
				})
			end
		else
			add_wield_entity(player)
		end
		active_players[name] = true
	end
	for name, wield in pairs(player_wielding) do
		if not active_players[name] then
			if wield.object then
				wield.object:remove()
			end
			player_wielding[name] = nil
		end
	end
	timer = 0
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	if name then
		local wield = player_wielding[name] or {}
		if wield.object then
			wield.object:remove()
		end
		player_wielding[name] = nil
	end
end)

