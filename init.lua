-- Simple registration function for minetest_game
function register_stair_and_slab_simple(subname, sourcenode, desc_stair, desc_slab, desc_double_slab, corner_stair_texture_override)
    local def = minetest.registered_nodes[sourcenode]
    local groups = def.groups or {}
    local tiles = def.tiles or {sourcenode .. ".png"}
    local sounds = def.sounds or default.node_sound_defaults()

    stairs.register_stair_and_slab(
        subname,
        sourcenode,
        groups,
        tiles,
        desc_stair,
        desc_slab,
        sounds,
        false,  -- worldaligntex
        "Inner " .. desc_stair,  -- desc_stair_inner
        "Outer " .. desc_stair   -- desc_stair_outer
    )
end

function capitalizeFirstLetter(str)
    return (str:gsub("^%l", string.upper))
end

-- Improved function to capitalize each word and format the color name
local function formatColorName(str)
    -- Replace underscores with spaces and capitalize each word
    return str:gsub("_", " "):gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper()..rest:lower()
    end)
end

-- Function to extract wool color names, excluding carpets and specific colors
local function extract_wool_colors(game_prefix)
    local colors = {}
    for nodename, _ in pairs(minetest.registered_nodes) do
        if nodename:match("^" .. game_prefix) and not nodename:match("carpet") then
            local color = nodename:match("^" .. game_prefix .. ":(.+)")
            if color and color ~= "dark_blue" and color ~= "gold" then
                table.insert(colors, color)
            end
        end
    end
    return colors
end

-- Determine the game and set the prefix and registration function accordingly
local game_prefix, register_stair_and_slab
if minetest.get_modpath("mcl_wool") then
    -- mineclone2
    game_prefix = "mcl_wool"
    register_stair_and_slab = mcl_stairs.register_stair_and_slab_simple
elseif minetest.get_modpath("wool") then
    -- minetest_game
    game_prefix = "wool"
    register_stair_and_slab = register_stair_and_slab_simple
end

-- Dynamically extract wool types from registered nodes, excluding carpets
local wool_types = extract_wool_colors(game_prefix)

-- Register stairs and slabs for each wool type
for _, color in ipairs(wool_types) do
    local formattedColor = formatColorName(color)
    local wool_name = game_prefix .. ":" .. color  -- Corrected prefix based on the game
    local desc_stair = formattedColor .. " Wool Stairs"
    local desc_slab = formattedColor .. " Wool Slab"
    local desc_double_slab = formattedColor .. " Double Wool Slab"

    -- Register stair and slab for this wool type
    register_stair_and_slab(
        color,
        wool_name,
        desc_stair,
        desc_slab,
        desc_double_slab
    )
end
