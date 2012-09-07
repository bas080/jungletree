local leaves = {"green","yellow","red"}

function addIfBoreable(pos,info)
   local air = minetest.env:get_node_or_nil(pos)
   if not air then return end
   if (not (air.walkable or air.name:find('leaves'))) then
      minetest.env:add_node(pos,info)
   end
end

for color = 1, 3 do
   local leave_name = "jungletree:leaves_"..leaves[color]
	minetest.register_node(leave_name, {
		description = "Jungle Tree Leaves",
		drawtype = "allfaces_optional",
		tiles = {"jungletree_leaves_"..leaves[color]..".png"},
		paramtype = "light",
		groups = {snappy=3, leafdecay=3, flammable=2},
		drop = {
			max_items = 1,
			items = {
				{
					-- player will get sapling with 1/20 chance
					items = {'jungletree:sapling'},
					rarity = 20,
				},
				{
					-- player will get leaves only if he get no saplings,
					-- this is because max_items is 1
					items = {leave_name},
				}
			}
		},
		sounds = default.node_sound_leaves_defaults(),
	})
end



--[[ minetest.register_node("jungletree:tree", {
	description = "Tree",
	tiles = {"default_tree_top.png",
	"default_tree_top.png",
	"jungletree_bark.png"},
	is_ground_content = true,
	groups = {tree=1,snappy=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
}) --]]

minetest.register_alias("jungletree:tree", "default:jungletree")

minetest.register_node(":default:jungletree", {
	description = "Jungle Tree",
	tiles = {"default_jungletree_top.png", "default_jungletree_top.png", "default_jungletree.png"},
	is_ground_content = true,
	groups = {tree=1,snappy=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
	sounds = default.node_sound_wood_defaults(),
})

local function add_tree_branch(pos)

	--chooze random leave
	--green leaves are more common
	local chance = math.random(5)
	local leave = "jungletree:leaves_"..leaves[1]
	if (chance < 2) then
		leave = "jungletree:leaves_"..leaves[math.random(1,3)]
	end

	addIfBoreable(pos, {name="default:jungletree"})
	for i = math.floor(math.random(2)), -math.floor(math.random(2)), -1 do
		for k = math.floor(math.random(2)), -math.floor(math.random(2)), -1 do
			local p = {x=pos.x+i, y=pos.y, z=pos.z+k}
			local n = minetest.env:get_node(p)
			if (n.name=="air") then
				minetest.env:add_node(p, {name=leave})
			end
			local chance = math.abs(i+k)
			if (chance < 1) then
				p = {x=pos.x+i, y=pos.y+1, z=pos.z+k}
				n = minetest.env:get_node(p)
				if (n.name=="air") then
					minetest.env:add_node(p, {name=leave})
				end
			end
		end
	end
end
minetest.register_abm({
	nodenames = {"jungletree:sapling"},
	interval = 50,
	chance = 10,
	action = function(pos, node)
		local height = 5 + math.random(15)
		if height < 10 then
			for i = height, -1, -1 do
				local p = {x=pos.x, y=pos.y+i, z=pos.z}
				addIfBoreable(p, {name="default:jungletree"})
				if i == height then
					add_tree_branch({x=pos.x, y=pos.y+height+math.random(0, 1), z=pos.z})
					add_tree_branch({x=pos.x+1, y=pos.y+i-math.random(2), z=pos.z})
					add_tree_branch({x=pos.x-1, y=pos.y+i-math.random(2), z=pos.z})
					add_tree_branch({x=pos.x, y=pos.y+i-math.random(2), z=pos.z+1})
					add_tree_branch({x=pos.x, y=pos.y+i-math.random(2), z=pos.z-1})
				end
				if height <= 0 then
					addIfBoreable({x=pos.x+1, y=pos.y+i-math.random(2), z=pos.z}, {name="default:jungletree"})
					addIfBoreable({x=pos.x, y=pos.y+i-math.random(2), z=pos.z+1}, {name="default:jungletree"})
					addIfBoreable({x=pos.x-1, y=pos.y+i-math.random(2), z=pos.z}, {name="default:jungletree"})
					addIfBoreable({x=pos.x, y=pos.y+i-math.random(2), z=pos.z-1}, {name="default:jungletree"})
				end
				if (math.sin(i/height*i) < 0.2 and i > 3 and math.random(0,2) < 1.5) then
					branch_pos = {x=pos.x+math.random(0,1), y=pos.y+i, z=pos.z-math.random(0,1)}
					add_tree_branch(branch_pos)
				end
			end
		else
			for i = height, -2, -1 do
				if (math.sin(i/height*i) < 0.2 and i > 3 and math.random(0,2) < 1.5) then
					branch_pos = {x=pos.x+math.random(0,1), y=pos.y+i, z=pos.z-math.random(0,1)}
					add_tree_branch(branch_pos)
				end
				if i < math.random(0,1) then
					addIfBoreable({x=pos.x+1, y=pos.y+i, z=pos.z+1}, {name="default:jungletree"})
					addIfBoreable({x=pos.x+2, y=pos.y+i, z=pos.z-1}, {name="default:jungletree"})
					addIfBoreable({x=pos.x, y=pos.y+i, z=pos.z-2}, {name="default:jungletree"})
					addIfBoreable({x=pos.x-1, y=pos.y+i, z=pos.z}, {name="default:jungletree"})
				end
				if i == height then
					add_tree_branch({x=pos.x+1, y=pos.y+i, z=pos.z+1})
					add_tree_branch({x=pos.x+2, y=pos.y+i, z=pos.z-1})
					add_tree_branch({x=pos.x, y=pos.y+i, z=pos.z-2})
					add_tree_branch({x=pos.x-1, y=pos.y+i, z=pos.z})
					add_tree_branch({x=pos.x+1, y=pos.y+i, z=pos.z+2})
					add_tree_branch({x=pos.x+3, y=pos.y+i, z=pos.z-1})
					add_tree_branch({x=pos.x, y=pos.y+i, z=pos.z-3})
					add_tree_branch({x=pos.x-2, y=pos.y+i, z=pos.z})
					add_tree_branch({x=pos.x+1, y=pos.y+i, z=pos.z})
					add_tree_branch({x=pos.x+1, y=pos.y+i, z=pos.z-1})
					add_tree_branch({x=pos.x, y=pos.y+i, z=pos.z-1})
					add_tree_branch({x=pos.x, y=pos.y+i, z=pos.z})
				else
					addIfBoreable({x=pos.x+1, y=pos.y+i, z=pos.z}, {name="default:jungletree"})
					addIfBoreable({x=pos.x+1, y=pos.y+i, z=pos.z-1}, {name="default:jungletree"})
					addIfBoreable({x=pos.x, y=pos.y+i, z=pos.z-1}, {name="default:jungletree"})
					addIfBoreable({x=pos.x, y=pos.y+i, z=pos.z}, {name="default:jungletree"})
				end
			end
		end
	end,})

--function anti_generate(node, surfaces, minp, maxp, height_min, height_max, spread, habitat_size, habitat_nodes)
addFlower(
   { description = "Jungle Tree Sapling",
     name = "sapling",
     id = "jungletree:sapling",
     rarity = 50,
     radius = 5,
     avoid = {"jungletree:sapling","group:tree"},
     register = {
        drawtype = "plantlike",
        visual_scale = 1.0,
        tiles = {"jungletree_sapling.png"},
        inventory_image = "jungletree_sapling.png",
        wield_image = "default_sapling.png",
        groups = {tree=1,snappy=2,dig_immediate=3,flammable=2}
     }
  })

minetest.register_craft({
    output = 'default:wood 4',
    recipe = {
        {'default:jungletree'},
    }
})

--old mod compatible
minetest.register_alias("jungletree:leaves", "jungletree:leaves_green")

print("[Jungletree] Loaded!")
