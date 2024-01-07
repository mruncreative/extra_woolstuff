# Extra Woolstuff
Adds more wool items and nodes to the game.

## Functionality
- Stairs for every wool colour.
- Slabs for every wool colour.

## Technicals (Needed to make mod)
```lua
➜  mineclone2 git:(master) ✗ cat ./mods/ITEMS/mcl_stairs/api.lua
local S = minetest.get_translator(minetest.get_current_modname())

-- Core mcl_stairs API

-- Wrapper around mintest.pointed_thing_to_face_pos.
local function get_fpos(placer, pointed_thing)
	local finepos = minetest.pointed_thing_to_face_pos(placer, pointed_thing)
	return finepos.y % 1
end

local function place_slab_normal(itemstack, placer, pointed_thing)
	-- Use pointed node's on_rightclick function first, if present
	local node = minetest.get_node(pointed_thing.under)
	if placer and not placer:get_player_control().sneak then
		if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
			return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
		end
	end

	local p0 = pointed_thing.under
	local p1 = pointed_thing.above

	--local placer_pos = placer:get_pos()

	local fpos = get_fpos(placer, pointed_thing)

	local place = ItemStack(itemstack)
	local origname = itemstack:get_name()
	if p0.y - 1 == p1.y or (fpos > 0 and fpos < 0.5)
			or (fpos < -0.5 and fpos > -0.999999999) then
		place:set_name(origname .. "_top")
	end
	local ret = minetest.item_place(place, placer, pointed_thing, 0)
	ret:set_name(origname)
	return ret
end

local function place_stair(itemstack, placer, pointed_thing)
	-- Use pointed node's on_rightclick function first, if present
	local node = minetest.get_node(pointed_thing.under)
	if placer and not placer:get_player_control().sneak then
		if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
			return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
		end
	end

	local p0 = pointed_thing.under
	local p1 = pointed_thing.above
	local param2 = 0

	local placer_pos = placer:get_pos()
	if placer_pos then
		param2 = minetest.dir_to_facedir(vector.subtract(p1, placer_pos))
	end

	local fpos = get_fpos(placer, pointed_thing)

	if p0.y - 1 == p1.y or (fpos > 0 and fpos < 0.5)
			or (fpos < -0.5 and fpos > -0.999999999) then
		param2 = param2 + 20
		if param2 == 21 then
			param2 = 23
		elseif param2 == 23 then
			param2 = 21
		end
	end
	return minetest.item_place(itemstack, placer, pointed_thing, param2)
end

-- Register stairs.
-- Node will be called mcl_stairs:stair_<subname>

function mcl_stairs.register_stair(subname, recipeitem, groups, images, description, sounds, blast_resistance, hardness, corner_stair_texture_override)

	if recipeitem then
		if not images then
			images = minetest.registered_items[recipeitem].tiles
		end
		if not groups then
			groups = minetest.registered_items[recipeitem].groups
		end
		if not sounds then
			sounds = minetest.registered_items[recipeitem].sounds
		end
		if not hardness then
			hardness = minetest.registered_items[recipeitem]._mcl_hardness
		end
		if not blast_resistance then
			blast_resistance = minetest.registered_items[recipeitem]._mcl_blast_resistance
		end
	end

	groups.stair = 1
	groups.building_block = 1

	minetest.register_node(":mcl_stairs:stair_" .. subname, {
		description = description,
		_doc_items_longdesc = S("Stairs are useful to reach higher places by walking over them; jumping is not required. Placing stairs in a corner pattern will create corner stairs. Stairs placed on the ceiling or at the upper half of the side of a block will be placed upside down."),
		drawtype = "mesh",
		mesh = "stairs_stair.obj",
		tiles = images,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = groups,
		sounds = sounds,
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end

			return place_stair(itemstack, placer, pointed_thing)
		end,
		on_rotate = function(pos, node, user, mode, param2)
			-- Flip stairs vertically
			if mode == screwdriver.ROTATE_AXIS then
				local minor = node.param2
				if node.param2 >= 20 then
					minor = node.param2 - 20
					if minor == 3 then
						minor = 1
					elseif minor == 1 then
						minor = 3
					end
					node.param2 = minor
				else
					if minor == 3 then
						minor = 1
					elseif minor == 1 then
						minor = 3
					end
					node.param2 = minor
					node.param2 = node.param2 + 20
				end
				minetest.set_node(pos, node)
				return true
			end
		end,
		_mcl_blast_resistance = blast_resistance,
		_mcl_hardness = hardness,
	})

	if recipeitem then
		minetest.register_craft({
			output = "mcl_stairs:stair_" .. subname .. " 4",
			recipe = {
				{recipeitem, "", ""},
				{recipeitem, recipeitem, ""},
				{recipeitem, recipeitem, recipeitem},
			},
		})

		-- Flipped recipe
		minetest.register_craft({
			output = "mcl_stairs:stair_" .. subname .. " 4",
			recipe = {
				{"", "", recipeitem},
				{"", recipeitem, recipeitem},
				{recipeitem, recipeitem, recipeitem},
			},
		})

		-- Stonecutter recipe
		mcl_stonecutter.register_recipe(recipeitem, "mcl_stairs:stair_".. subname)
	end

	mcl_stairs.cornerstair.add("mcl_stairs:stair_"..subname, corner_stair_texture_override)
end


-- Slab facedir to placement 6d matching table
--local slab_trans_dir = {[0] = 8, 0, 2, 1, 3, 4}

-- Register slabs.
-- Node will be called mcl_stairs:slab_<subname>

-- double_description: NEW argument, not supported in Minetest Game
-- double_description: Description of double slab
function mcl_stairs.register_slab(subname, recipeitem, groups, images, description, sounds, blast_resistance, hardness, double_description)
	local lower_slab = "mcl_stairs:slab_"..subname
	local upper_slab = lower_slab.."_top"
	local double_slab = lower_slab.."_double"

	if recipeitem then
		if not images then
			images = minetest.registered_items[recipeitem].tiles
		end
		if not groups then
			groups = minetest.registered_items[recipeitem].groups
		end
		if not sounds then
			sounds = minetest.registered_items[recipeitem].sounds
		end
		if not hardness then
			hardness = minetest.registered_items[recipeitem]._mcl_hardness
		end
		if not blast_resistance then
			blast_resistance = minetest.registered_items[recipeitem]._mcl_blast_resistance
		end
	end

	-- Automatically generate double slab description
	if not double_description then
		double_description = S("Double @1", description)
	end

	groups.slab = 1
	groups.building_block = 1
	local longdesc = S("Slabs are half as high as their full block counterparts and occupy either the lower or upper part of a block, depending on how it was placed. Slabs can be easily stepped on without needing to jump. When a slab is placed on another slab of the same type, a double slab is created.")

	local slabdef = {
		description = description,
		_doc_items_longdesc = longdesc,
		drawtype = "nodebox",
		tiles = images,
		paramtype = "light",
		-- Facedir intentionally left out (see below)
		is_ground_content = false,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		},
		on_place = function(itemstack, placer, pointed_thing)
			local under = minetest.get_node(pointed_thing.under)
			local wield_item = itemstack:get_name()
			local creative_enabled = minetest.is_creative_enabled(placer:get_player_name())

			-- place slab using under node orientation
			local dir = vector.subtract(pointed_thing.above, pointed_thing.under)

			local p2 = under.param2

			-- combine two slabs if possible
			-- Requirements: Same slab material, must be placed on top of lower slab, or on bottom of upper slab
			if (wield_item == under.name or (minetest.registered_nodes[under.name] and wield_item == minetest.registered_nodes[under.name]._mcl_other_slab_half)) and
					not ((dir.y >= 0 and minetest.get_item_group(under.name, "slab_top") == 1) or
					(dir.y <= 0 and minetest.get_item_group(under.name, "slab_top") == 0)) then

				local player_name = placer:get_player_name()
				if minetest.is_protected(pointed_thing.under, player_name) and not
						minetest.check_player_privs(placer, "protection_bypass") then
					minetest.record_protection_violation(pointed_thing.under,
						player_name)
					return
				end
				local newnode = double_slab
				minetest.set_node(pointed_thing.under, {name = newnode, param2 = p2})
				if not creative_enabled then
					itemstack:take_item()
				end
				return itemstack
			-- No combination possible: Place slab normally
			else
				return place_slab_normal(itemstack, placer, pointed_thing)
			end
		end,
		_mcl_hardness = hardness,
		_mcl_blast_resistance = blast_resistance,
		_mcl_other_slab_half = upper_slab,
		on_rotate = function(pos, node, user, mode, param2)
			-- Flip slab
			if mode == screwdriver.ROTATE_AXIS then
				node.name = upper_slab
				minetest.set_node(pos, node)
				return true
			end
			return false
		end,
	}

	minetest.register_node(":"..lower_slab, slabdef)

	-- Register the upper slab.
	-- Using facedir is not an option, as this would rotate the textures as well and would make
	-- e.g. upper sandstone slabs look completely wrong.
	local topdef = table.copy(slabdef)
	topdef.groups.slab = 1
	topdef.groups.slab_top = 1
	topdef.groups.not_in_creative_inventory = 1
	topdef.groups.not_in_craft_guide = 1
	topdef.description = S("Upper @1", description)
	topdef._doc_items_create_entry = false
	topdef._doc_items_longdesc = nil
	topdef._doc_items_usagehelp = nil
	topdef.drop = lower_slab
	topdef._mcl_other_slab_half = lower_slab
	function topdef.on_rotate(pos, node, user, mode, param2)
		-- Flip slab
		if mode == screwdriver.ROTATE_AXIS then
			node.name = lower_slab
			minetest.set_node(pos, node)
			return true
		end
		return false
	end
	topdef.node_box = {
		type = "fixed",
		fixed = {-0.5, 0, -0.5, 0.5, 0.5, 0.5},
	}
	topdef.selection_box = {
		type = "fixed",
		fixed = {-0.5, 0, -0.5, 0.5, 0.5, 0.5},
	}
	minetest.register_node(":"..upper_slab, topdef)


	-- Double slab node
	local dgroups = table.copy(groups)
	dgroups.not_in_creative_inventory = 1
	dgroups.not_in_craft_guide = 1
	dgroups.slab = nil
	dgroups.double_slab = 1
	minetest.register_node(":"..double_slab, {
		description = double_description,
		_doc_items_longdesc = S("Double slabs are full blocks which are created by placing two slabs of the same kind on each other."),
		tiles = images,
		is_ground_content = false,
		groups = dgroups,
		sounds = sounds,
		drop = lower_slab .. " 2",
		_mcl_hardness = hardness,
		_mcl_blast_resistance = blast_resistance,
	})

	if recipeitem then
		minetest.register_craft({
			output = lower_slab .. " 6",
			recipe = {
				{recipeitem, recipeitem, recipeitem},
			},
		})

		mcl_stonecutter.register_recipe(recipeitem, lower_slab, 2)

	end

	-- Help alias for the upper slab
	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", lower_slab, "nodes", upper_slab)
	end
end


-- Stair/slab registration function.
-- Nodes will be called mcl_stairs:{stair,slab}_<subname>

function mcl_stairs.register_stair_and_slab(subname, recipeitem,
		groups, images, desc_stair, desc_slab, sounds, blast_resistance, hardness,
		double_description, corner_stair_texture_override)
	mcl_stairs.register_stair(subname, recipeitem, groups, images, desc_stair, sounds, blast_resistance, hardness, corner_stair_texture_override)
	mcl_stairs.register_slab(subname, recipeitem, groups, images, desc_slab, sounds, blast_resistance, hardness, double_description)
end

-- Very simple registration function
-- Makes stair and slab out of a source node
function mcl_stairs.register_stair_and_slab_simple(subname, sourcenode, desc_stair, desc_slab, desc_double_slab, corner_stair_texture_override)
	local def = minetest.registered_nodes[sourcenode]
	local groups = {}
	-- Only allow a strict set of groups to be added to stairs and slabs for more predictable results
	local allowed_groups = { "dig_immediate", "handy", "pickaxey", "axey", "shovely", "shearsy", "shearsy_wool", "swordy", "swordy_wool" }
	for a=1, #allowed_groups do
		if def.groups[allowed_groups[a]] then
			groups[allowed_groups[a]] = def.groups[allowed_groups[a]]
		end
	end
	mcl_stairs.register_stair_and_slab(subname, sourcenode, groups, def.tiles, desc_stair, desc_slab, def.sounds, def._mcl_blast_resistance, def._mcl_hardness, desc_double_slab, corner_stair_texture_override)
end


-- Use this function to register the stair_and_slab:
  -- Very simple registration function
  -- Makes stair and slab out of a source node
  function mcl_stairs.register_stair_and_slab_simple(subname, sourcenode, desc_stair, desc_slab, desc_double_slab, corner_stair_texture_override)
```

Here is the code for the mcl_wool mod:
```lua
➜  mineclone2 git:(master) ✗ cat ./mods/ITEMS/mcl_wool/init.lua
local S = minetest.get_translator(minetest.get_current_modname())
local mod_doc = minetest.get_modpath("doc")

-- minetest/wool/init.lua

-- Backwards compatibility with jordach's 16-color wool mod
minetest.register_alias("mcl_wool:dark_blue", "wool:blue")
minetest.register_alias("mcl_wool:gold", "wool:yellow")

local wool = {}
-- This uses a trick: you can first define the recipes using all of the base
-- colors, and then some recipes using more specific colors for a few non-base
-- colors available. When crafting, the last recipes will be checked first.
wool.dyes = {
	-- name,       texture,               wool desc.,           carpet desc.,           dye,          color_group
	{"white",      "wool_white",          S("White Wool"),      S("White Carpet"),      nil,          "unicolor_white"},
	{"grey",       "wool_dark_grey",      S("Grey Wool"),       S("Grey Carpet"),       "dark_grey",  "unicolor_darkgrey"},
	{"silver",     "wool_grey",           S("Light Grey Wool"), S("Light Grey Carpet"), "grey",       "unicolor_grey"},
	{"black",      "wool_black",          S("Black Wool"),      S("Black Carpet"),      "black",      "unicolor_black"},
	{"red",        "wool_red",            S("Red Wool"),        S("Red Carpet"),        "red",        "unicolor_red"},
	{"yellow",     "wool_yellow",         S("Yellow Wool"),     S("Yellow Carpet"),     "yellow",     "unicolor_yellow"},
	{"green",      "wool_dark_green",     S("Green Wool"),      S("Green Carpet"),      "dark_green", "unicolor_dark_green"},
	{"cyan",       "wool_cyan",           S("Cyan Wool"),       S("Cyan Carpet"),       "cyan",       "unicolor_cyan"},
	{"blue",       "wool_blue",           S("Blue Wool"),       S("Blue Carpet"),       "blue",       "unicolor_blue"},
	{"magenta",    "wool_magenta",        S("Magenta Wool"),    S("Magenta Carpet"),    "magenta",    "unicolor_red_violet"},
	{"orange",     "wool_orange",         S("Orange Wool"),     S("Orange Carpet"),     "orange",     "unicolor_orange"},
	{"purple",     "wool_violet",         S("Purple Wool"),     S("Purple Carpet"),     "violet",     "unicolor_violet"},
	{"brown",      "wool_brown",          S("Brown Wool"),      S("Brown Carpet"),      "brown",      "unicolor_dark_orange"},
	{"pink",       "wool_pink",           S("Pink Wool"),       S("Pink Carpet"),       "pink",       "unicolor_light_red"},
	{"lime",       "mcl_wool_lime",       S("Lime Wool"),       S("Lime Carpet"),       "green",      "unicolor_green"},
	{"light_blue", "mcl_wool_light_blue", S("Light Blue Wool"), S("Light Blue Carpet"), "lightblue",  "unicolor_light_blue"},
}
local canonical_color = "white"

for _, row in ipairs(wool.dyes) do
	local name = row[1]
	local texture = row[2]
	local desc_wool = row[3]
	local desc_carpet = row[4]
	local dye = row[5]
	local color_group = row[6]
	local longdesc_wool, longdesc_carpet, create_entry, name_wool, name_carpet
	local is_canonical = name == canonical_color
	if mod_doc then
		if is_canonical then
			longdesc_wool = S("Wool is a decorative block which comes in many different colors.")
			longdesc_carpet = S("Carpets are thin floor covers which come in many different colors.")
			name_wool = S("Wool")
			name_carpet = S("Carpet")
		else
			create_entry = false
		end
	end
	-- Node Definition
		minetest.register_node("mcl_wool:"..name, {
			description = desc_wool,
			_doc_items_create_entry = create_entry,
			_doc_items_entry_name = name_wool,
			_doc_items_longdesc = longdesc_wool,
			stack_max = 64,
			is_ground_content = false,
			tiles = {texture..".png"},
			groups = {handy=1,shearsy_wool=1, flammable=1,fire_encouragement=30, fire_flammability=60, wool=1,building_block=1,[color_group]=1},
			sounds = mcl_sounds.node_sound_wool_defaults(),
			_mcl_hardness = 0.8,
			_mcl_blast_resistance = 0.8,
		})
		minetest.register_node("mcl_wool:"..name.."_carpet", {
			description = desc_carpet,
			_doc_items_create_entry = create_entry,
			_doc_items_entry_name = name_carpet,
			_doc_items_longdesc = longdesc_carpet,

			is_ground_content = false,
			tiles = {texture..".png"},
			wield_image = texture..".png",
			wield_scale = { x=1, y=1, z=0.5 },
			groups = {handy=1, carpet=1,supported_node=1,flammable=1,fire_encouragement=60, fire_flammability=20, dig_by_water=1,deco_block=1,[color_group]=1},
			sounds = mcl_sounds.node_sound_wool_defaults(),
			paramtype = "light",
			sunlight_propagates = true,
			stack_max = 64,
			drawtype = "nodebox",
			node_box = {
				type = "fixed",
				fixed = {
					{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16},
				},
			},
			_mcl_hardness = 0.1,
			_mcl_blast_resistance = 0.1,
		})
	if mod_doc and not is_canonical then
		doc.add_entry_alias("nodes", "mcl_wool:"..canonical_color, "nodes", "mcl_wool:"..name)
		doc.add_entry_alias("nodes", "mcl_wool:"..canonical_color.."_carpet", "nodes", "mcl_wool:"..name.."_carpet")
	end
	if dye then
	-- Crafting from dye and white wool
		minetest.register_craft({
			type = "shapeless",
			output = "mcl_wool:"..name,
			recipe = {"mcl_dye:"..dye, "mcl_wool:white"},
		})
	end
	minetest.register_craft({
		output = "mcl_wool:"..name.."_carpet 3",
		recipe = {{"mcl_wool:"..name, "mcl_wool:"..name}},
	})
end

minetest.register_craft({
	output = "mcl_wool:white",
	recipe = {
		{ "mcl_mobitems:string", "mcl_mobitems:string" },
		{ "mcl_mobitems:string", "mcl_mobitems:string" },
	},
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:wool",
	burntime = 5,
})
minetest.register_craft({
	type = "fuel",
	recipe = "group:carpet",
	-- Original value: 3.35
	burntime = 3,
})
```
