-- Lists evil weather types, and what regions have them
--[====[

evil-weather
=============
When you are in legends mode, use this to make a list of evil weather types
and what regions have them.

]====]

local args = {...}

function get_by_property(table, key, value)
	for k, item in pairs(table) do
		if item[key] == value then
			return item
		end
	end
end

function print_table(table)
	for id, item in pairs(table) do
		if type(item) == "userdata" then
			print("id: "..id)
			for k, v in pairs(item) do
				print(k, v)
			end
			print("-----")
		else
			print(id, item)
		end
	end
end

function is_rain_or_cloud(string)
	local index
	local length

	if string == nil then
		return false
	end

	index, length = string.find(string, "EVIL_RAIN")
	if index == 1 then
		return true
	end

	index, length = string.find(string, "EVIL_CLOUD")
	if index == 1 then
		return true
	end

	return false
end

-- provide numeric material id (position of material in list)
-- returns numeric interaction id
function get_interaction_by_material(material_id)
	local interaction_id = nil
	for k, v in pairs(df.global.world.raws.interactions) do
		if #v.targets > 1 then
			for target_k, target_v in pairs(v.targets[1]) do
				if (target_k == "mat_index" and target_v == material_id) then
					return v.id
				end
			end
		end
	end
end

function scan_by_material()
	local region
	local link
	local interaction_id

	-- loop once per evil weather material
	for material_id, material in pairs(df.global.world.raws.inorganics) do

		if is_rain_or_cloud(material.id) then
			-- output name of weather
			for k, v in pairs(material.str) do
				if string.find(v.value, "%[STATE_NAME:LIQUID:") == 1 
					or string.find(v.value, "%[STATE_NAME:ALL:") == 1 then
					print(material.id, v.value)
				end
			end

			-- find interaction id. We'll need this to link to region.
			interaction_id = get_interaction_by_material(material_id)

			-- find regions and print them
			for k, v in pairs(df.global.world.interaction_instances.all) do
				if v.interaction_id == interaction_id then
					region = get_by_property(df.global.world.world_data.regions, 'index', v.region_index)
					print("    ", dfhack.TranslateName(region.name, true))
				end
			end

		end

	end

end

-- TODO add "cloud" and "rain" filters
if dfhack.gui.getCurFocus() == "legends" or dfhack.gui.getCurFocus() == "dfhack/lua/legends" then
	if args[1] == "regions" then
		print_table(df.global.world.world_data.regions)
	elseif args[1] == "links" then
		print_table(df.global.world.interaction_instances.all)
	elseif args[1] == "interactions" then
		print_table(df.global.world.raws.interactions)
	elseif args[1] == "inorganics" then
		print_table(df.global.world.raws.inorganics)
	else
		scan_by_material()
	end
else
    qerror('exportlegends must be run from the main legends view')
end
