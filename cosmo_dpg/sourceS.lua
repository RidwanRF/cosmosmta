local resources = {
	"cosmo_anticheat",
	"cosmo_database",
	"cosmo_core",

	"cosmo_assets",
	"cosmo_ui",
	"cosmo_newhandling",

	"cosmo_logs",

	"cosmo_hud",
	"cosmo_admin",
	
	"cosmo_removelv",
	"cosmo_water",
	"cosmo_maps",
	"cosmo_kreszmap",
	"cosmo_kresz-mods",

	"cosmo_mods_weapon",
	"cosmo_mods_veh",
	"cosmo_mods_skin",
	"cosmo_mods_obj",

	"cosmo_textures",
	"cosmo_controls",
	"cosmo_alert",
	"cosmo_3dview",
	"cosmo_boneattach",
	"cosmo_weather",

	"cosmo_inventory",
	"cosmo_interiors",
	"cosmo_vehicles",

	"cosmo_nametag",
	"cosmo_jobs",
	"cosmo_chat",
	"cosmo_billiard",
	"cosmo_dashboard",
	"cosmo_damage",
	"cosmo_carshop",
	"cosmo_licenses",
	"cosmo_bank",
	"cosmo_loader",
	"cosmo_npcs",
	"cosmo_shop",
	"cosmo_groups",
	"cosmo_groupscripting",
	"cosmo_crosshair",
	"cosmo_weapons",
	"cosmo_newdebug",
	"cosmo_performance",
	"cosmo_interaction",
	"cosmo_fuel",
	"cosmo_minigames",
	"cosmo_death",
	"cosmo_tempomat",
	"cosmo_paintjobs",
	"cosmo_remove",
	"cosmo_phone",
	"cosmo_ppshop",

	"cosmo_job_storekeeper",

	"cosmo_accounts",

	"cosmo_tips",
	"cosmo_ticket",
	"cosmo_animation",
	"cosmo_skinshop",
    "cosmo_cardoors",
    "cosmo_garagemodell",
	"cosmo_gates",
    "cosmo_service",
    "cosmo_wheels",

    "cosmo_roulette",
    
	"cosmo_newtuning",
	"cosmo_ujtuningeljaras",
	"cosmo_weaponsticker",
}

addEventHandler("onResourceStart", getResourceRootElement(),
	function()
		for i = 1, #resources do
			local resName = resources[i]
			local res = getResourceFromName(resName)
			if res then
				setTimer(
					function()
						local meta = xmlLoadFile(":" .. resName .. "/meta.xml")
						if meta then
							local dpg = xmlFindChild(meta, "download_priority_group", 0)
							local download_priority_group = 0 - i
							if dpg then
								xmlNodeSetValue(dpg, tostring(download_priority_group))
							else
								dpg = xmlCreateChild(meta, "download_priority_group")
								xmlNodeSetValue(dpg, tostring(download_priority_group))
							end
							print(resName .. " download_priority_group changed to -> " .. tostring(download_priority_group))
							xmlSaveFile(meta)
							xmlUnloadFile(meta)
						end
					end,
				1000, 1)
			end
		end
	end)