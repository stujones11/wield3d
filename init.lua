local update_time = 2 -- number of seconds between wielditem updates

dofile(minetest.get_modpath(minetest.get_current_modname()).."/rotation.lua")

minetest.register_item("wield3d:hand", {
	type = "none",
	wield_image = "wield3d_trans.png",
})

minetest.register_entity("wield3d:wield_entity", {
	initial_properties = {
		physical = false,
		collisionbox = {x=0, y=0, z=0},
		visual = "wielditem",
		visual_size = {x=0.25, y=0.25},
	},
	wield_item = "",
	player = nil,
	timer = 0,
	rotation = 0,
	on_step = function(self, dtime)
		local player = self.player
		if player == nil then 
			self.object:remove()
			return
		end
		self.timer = self.timer + dtime
		if self.timer < update_time then
			return
		end
		self.timer = 0
		if minetest.env:get_player_by_name(player:get_player_name()) == nil then 
			self.object:remove()
			return
		end		
		local stack = player:get_wielded_item()
		local item = stack:get_name()
		if item == self.wield_item then
			return
		end
		self.wield_item = item
		if item == "" then
			item = "wield3d:hand"
		end
		local rotation = wield3d_rotation[item] or 0
		if rotation ~= self.rotation then
			self.object:setpos(player:getpos())
			self.object:set_detach()
			self.object:set_attach(player, "Armature_Wield_Item", {x=0, y=0, z=0}, {x=0, y=0, z=rotation})
			self.rotation = rotation
		end
		self.object:set_properties({textures={item}})
	end,
})

minetest.register_on_joinplayer(function(player)
	minetest.after(0.5, function(player)
		player:set_properties({
			visual = "mesh",
			mesh = "wield3d_character.x",
			visual_size = {x=1, y=1},
		})
		local pos = player:getpos()
		local entity = minetest.env:add_entity(pos, "wield3d:wield_entity")
		if entity ~= nil then
			entity:set_attach(player, "Armature_Wield_Item", {x=0, y=0, z=0}, {x=0, y=0, z=0})
			entity = entity:get_luaentity() 
			entity.player = player      
		end
	end, player)
end)

