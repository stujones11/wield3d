-- Wielded Item Location Overrides - [item_name] = {bone, position, rotation}

local bone = "Arm_Right"
local pos = {x=0, y=5.5, z=3}
local scale = {x=0.25, y=0.25}
local rx = -90
local rz = 90

wield3d.location = {
	["default:torch"] = {bone, pos, {x=rx, y=180, z=rz}, scale},
	["default:sapling"] = {bone, pos, {x=rx, y=180, z=rz}, scale},
	["flowers:dandelion_white"] = {bone, pos, {x=rx, y=180, z=rz}, scale},
	["flowers:dandelion_yellow"] = {bone, pos, {x=rx, y=180, z=rz}, scale},
	["flowers:geranium"] = {bone, pos, {x=rx, y=180, z=rz}, scale},
	["flowers:rose"] = {bone, pos, {x=rx, y=180, z=rz}, scale},
	["flowers:tulip"] = {bone, pos, {x=rx, y=180, z=rz}, scale},
	["flowers:viola"] = {bone, pos, {x=rx, y=180, z=rz}, scale},
	["default:shovel_wood"] = {bone, pos, {x=rx, y=135, z=rz}, scale},
	["default:shovel_stone"] = {bone, pos, {x=rx, y=135, z=rz}, scale},
	["default:shovel_steel"] = {bone, pos, {x=rx, y=135, z=rz}, scale},
	["default:shovel_bronze"] = {bone, pos, {x=rx, y=135, z=rz}, scale},
	["default:shovel_mese"] = {bone, pos, {x=rx, y=135, z=rz}, scale},
	["default:shovel_diamond"] = {bone, pos, {x=rx, y=135, z=rz}, scale},
	["bucket:bucket_empty"] = {bone, pos, {x=rx, y=135, z=rz}, scale},
	["bucket:bucket_water"] = {bone, pos, {x=rx, y=135, z=rz}, scale},
	["bucket:bucket_lava"] = {bone, pos, {x=rx, y=135, z=rz}, scale},
	["screwdriver:screwdriver"] = {bone, pos, {x=rx, y=135, z=rz}, scale},
	["screwdriver:screwdriver1"] = {bone, pos, {x=rx, y=135, z=rz}, scale},
	["screwdriver:screwdriver2"] = {bone, pos, {x=rx, y=135, z=rz}, scale},
	["screwdriver:screwdriver3"] = {bone, pos, {x=rx, y=135, z=rz}, scale},
	["screwdriver:screwdriver4"] = {bone, pos, {x=rx, y=135, z=rz}, scale},
	["vessels:glass_bottle"] = {bone, pos, {x=rx, y=135, z=rz}, scale},
	["vessels:drinking_glass"] = {bone, pos, {x=rx, y=135, z=rz}, scale},
	["vessels:steel_bottle"] = {bone, pos, {x=rx, y=135, z=rz}, scale},
}

