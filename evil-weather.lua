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
	for k, v in pairs(df.global.world.raws.interactions) do
		if #v.targets > 1 then
			for target_k, target_v in pairs(v.targets[1]) do
				if (target_k == "mat_index" and target_v == material_id) then
					return v.id
				end
			end
		end
	end

	return nil
end

-- given an object from inorganics array, return descriptive string
function describe_weather(material)
	for k, v in pairs(material.str) do
		if string.find(v.value, "%[STATE_NAME:LIQUID:") == 1 
			or string.find(v.value, "%[STATE_NAME:ALL:") == 1 then
			return material.id, v.value
		end
	end

	return nil
end

function scan_by_material()
	local region
	local interaction_id
	local region_count

	-- loop once per evil weather material
	for material_id, material in pairs(df.global.world.raws.inorganics) do

		if string.find(material.id, "EVIL_CLOUD") then
			dfhack.color(COLOR_RED)
		elseif string.find(material.id, "EVIL_RAIN") then
			dfhack.color(COLOR_YELLOW)
		else
			goto loop_end
		end

		print(describe_weather(material))
		interaction_id = get_interaction_by_material(material_id)

		region_count = 0
		dfhack.color(COLOR_GREY)
		for k, v in pairs(df.global.world.interaction_instances.all) do
			if v.interaction_id == interaction_id then
				region = get_by_property(df.global.world.world_data.regions, 'index', v.region_index)
				print("", dfhack.TranslateName(region.name, true))
				region_count = region_count + 1
			end
		end

		if (region_count < 1) then
			print("", "(no regions with this weather)")
		end

		::loop_end::
	end

	dfhack.color(-1)

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
