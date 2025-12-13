-- Lists evil weather types, and what regions have them
--[====[

evil-weather
=============
When you are in legends mode, use this to make a list of evil weather types and what regions have them.

Usage
_____

"evil-weather"
   Show info about regions with evil weather

"evil-weather reanimating"
   Show info about regions where the dead reanimate

"evil-weather cloud"
   Show info about regions with evil clouds (not evil rain)

"evil-weather rain"
   Show info about regions with evil rain (not evil clouds)

"evil-weather regions"
   Show technical details for all regions

"evil-weather interactions"
   Show technical details for the world's interactions (magical effects)

"evil-weather inorganics"
   Show technical details for the world's inorganic materials

]====]

local args = {...}

local function get_by_property(table, key, value)
	for k, item in pairs(table) do
		if item[key] == value then
			return item
		end
	end
end

local function print_table(table)
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

-- provide numeric material id (position of material in list)
-- returns numeric interaction id
local function get_interaction_by_material(material_id)
	for k, v in pairs(df.global.world.raws.interactions.all) do
		if #v.targets > 1 and v.targets[1].mat_index == material_id then
			return v.id
		end
	end

	return nil
end

-- describe the weather associated with an inorganic material
local function describe_weather(material)
	for k, v in pairs(material.str) do
		if string.find(v.value, "%[STATE_NAME:LIQUID:") == 1 
			or string.find(v.value, "%[STATE_NAME:ALL:") == 1 then
			return material.id, v.value
		end
	end

	return nil
end

-- describe the syndrome inflicted by an inorganic material.
local function describe_syndrome(material)
	local output = ""

	for k, v in pairs(material.str) do
		if string.find(v.value, "%[CE_") == 1 then
			if v.value ~= "" then
				output = output .. "\t" .. v.value .. "\n"
			end
		end
	end

	if output == "" then
		output = "\t(no syndrome effects)\n"
	end

	return output
end

-- prints description directly to console
local function describe_region(region_index)

	local region = get_by_property(df.global.world.world_data.regions, 'index', region_index)

	dfhack.color(COLOR_GREY)
	dfhack.print("", dfhack.translation.translateName(region.name, true))

	if region.dead_percentage ~= 0 then
		dfhack.color(COLOR_YELLOW)
		dfhack.print(" - " .. region.dead_percentage .. "% dead")
	end

	if region.reanimating then
		dfhack.color(COLOR_RED)
		dfhack.print(" - reanimating")
	end

	dfhack.print("\n")
end

-- given numeric interaction id, return array of region_indexes
local function get_regions_by_interaction(interaction_id)
	local region_indexes = {}

	for k, v in pairs(df.global.world.interaction_instances.all) do
		if v.interaction_id == interaction_id then
			table.insert(region_indexes, v.source_context.region_index)
		end
	end

	return region_indexes
end

-- print list of reanimating regions
local function scan_for_dead()
	local reanimating_regions_found = 0

	for index, region in pairs(df.global.world.world_data.regions) do

		if region.dead_percentage ~= 0 then
			describe_region(region.index)
			reanimating_regions_found = reanimating_regions_found + 1
		end
	end

	if reanimating_regions_found == 0 then
		print("No reanimating regions found. What a pleasant world!")
	else
		print()
		print("Note: Percentages show how much of the plants will be dead. \"reanimating\" means corpses become undead monsters there.")
	end

end

local function scan_by_material(filter)
	local interaction_id
	local region_count = 0
	local show_cloud = true
	local show_rain = true
	local affected_regions = {}

	--check filter
	if filter == "cloud" then
		show_rain = false
	elseif filter == "rain" then
		show_cloud = false
	end

	-- loop once per evil weather material
	for material_id, material in pairs(df.global.world.raws.inorganics.all) do

		if string.find(material.id, "EVIL_CLOUD") then
			if show_cloud == false then
				goto loop_end
			end
		elseif string.find(material.id, "EVIL_RAIN") then
			if show_rain == false then
				goto loop_end
			end
		else
			goto loop_end
		end

		interaction_id = get_interaction_by_material(material_id)

		affected_regions = get_regions_by_interaction(interaction_id)

		if (#affected_regions < 1) then
			goto loop_end
		end

		region_count = region_count + #affected_regions

		-- print description of weather and regions

		print("found evil weather in:")
		for k, region_index in pairs(affected_regions) do
			describe_region(region_index)
		end
		print()

		print("******************")
		print("* weather details:")
		print("******************")
		dfhack.color(COLOR_WHITE)
		print(describe_weather(material))
		print()

		print("******************")
		print("* syndrome caused by weather:")
		print("******************")
		dfhack.color(COLOR_GREY)
		print(describe_syndrome(material))

		print("-----")
		print()

		::loop_end::
	end

	if region_count < 1 then
		dfhack.color(COLOR_RED)
		print("No regions in this world have evil weather. How nice.")
	end

	dfhack.color(-1)  -- reset to default color

end

if dfhack.gui.matchFocusString('legends') then
	if args[1] == "reanimating" then
		scan_for_dead()
	elseif args[1] == "regions" then
		print_table(df.global.world.world_data.regions)
--	elseif args[1] == "links" then
--		print_table(df.global.world.interaction_instances.all)
	elseif args[1] == "interactions" then
		print_table(df.global.world.raws.interactions.all)
	elseif args[1] == "inorganics" then
		print_table(df.global.world.raws.inorganics.all)
	elseif args[1] == "cloud" or args[1] == "clouds" then
		scan_by_material("cloud")
	elseif args[1] == "rain" then
		scan_by_material("rain")
	else
		scan_by_material()
	end
else
    qerror('must be run from the main legends view')
end
