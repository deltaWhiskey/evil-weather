local args = {...}

function links()
	for  link_id, link in pairs(df.global.world.interaction_instances.all) do
		for k, v in pairs(link) do
			print(k, v)
		end
		print("-----")
	end
end

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

function starts_with(haystack, needle)
	local index
	local length

	index, length = string.find(haystack, needle)
	if (index == 0) then
		return true
	end
	
	return false
end

function scan_by_region()
	for  link_id, link in pairs(df.global.world.interaction_instances.all) do
		local region
		local interaction
		local material

		region = get_by_property(df.global.world.world_data.regions, "index", link.region_index)
		interaction = get_by_property(df.global.world.raws.interactions, 'id', link.interaction_id)

		-- we are only interested in interactions that involve a material
		if #interaction.targets > 1 then

			-- only proceed if we can find material in inorganics list
			if #df.global.world.raws.inorganics >= interaction.targets[1].mat_index then
				material = df.global.world.raws.inorganics[interaction.targets[1].mat_index]

				-- we only want rain or clouds
				material = df.global.world.raws.inorganics[interaction.targets[1].mat_index]
				if is_rain_or_cloud(material.id) then
					--print_table(material.str)
						--SYN_NAME, SYN_AFFECTED_CLASS,  STATE_ADJ
					print(
						dfhack.TranslateName(region.name, true),
						material.id
						)
					print_table(dfhack.maps.getRegionBiome(region.region_coords))
					-- TODO extract STATE_ADJ and SYN_NAME
					-- TODO biome
					-- TODO coordinates
					--print(link.interaction_id, link.region_index, region.index, region.reanimating)
					--print(dfhack.TranslateName(region.name, true))
					--print("interaction deets:")
					--print_table(interaction.str) -- RAW style
					--print_table(interaction)
					--print(interaction.targets[1].material_str[1])
					--print(interaction.targets[1].mat_index)
					--print("TARG")
					--print_table(interaction.targets[1])
					-- TODO continute down to syndrome from material table
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
			print(material.id) -- like EVIL_CLOUD_1

			-- output name of weather
			for k, v in pairs(material.str) do
				if string.find(v.value, "%[STATE_NAME:LIQUID:") == 1 
					or string.find(v.value, "%[STATE_NAME:ALL:") == 1 then
					print(v.value)
				end
			end

			-- find interaction id. We'll need this to link to region.
			interaction_id = nil
			for k, v in pairs(df.global.world.raws.interactions) do
				if #v.targets > 1 then
					for target_k, target_v in pairs(v.targets[1]) do
						if (target_k == "mat_index" and target_v == material_id) then
							interaction_id = v.id
						end
					end
				end
			end

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
