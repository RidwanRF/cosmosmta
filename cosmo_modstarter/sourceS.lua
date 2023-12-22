local resources = {
	--[CORE]--
	"cosmo_database",
	"cosmo_core",
	"cosmo_logs",
	"cosmo_admin",
	"cosmo_hud",
	--[CORE]--

	"gnihaz",
	"gnihazmap",
	--[Carl]--
	"cosmo_aranyrob",
	"cosmo_bankmodel",
	"cosmo_kamionjob",
	"cosmo_minigames",
	"cosmo_pf",
	"cosmo_radio",
	"cosmo_szerelo",

	--[Casino]--
	"cosmo_blackjack",
	"cosmo_casinoped",
	"cosmo_fortunewheel",
	"cosmo_gamemachines",
	"cosmo_goldrush",
	"cosmo_poker",
	"cosmo_roulette",
	"cosmo_swslot",
	"cosmo_westernslot",

	--[eznemgergo]--
	"cosmo_dclog",
	"cosmo_fpnezet",
	"cosmo_netlimiter-false",
	"cosmo_szerelo-fegyo",
	"cosmo_other-minigames",
	"cosmo_deli",
	"cosmo_deli-map",

	--[Faction]--
	"cosmo_ropsys",
	"cosmo_emcall",
	"cosmo_groups",
	"cosmo_groupscripting",
	"cosmo_healpoint",
	"cosmo_siren",
	"cosmo_taxipanel",

	--[Gate]--
	"cosmo_gate_engine",
	"cosmo_gate",

	--[Jobs]--
	"cosmo_custommarker",
	"cosmo_boneattach",
	"cosmo_compiler_job",
	"cosmo_fishing",
	"cosmo_hobby_mushrooms",
	"cosmo_job_gardener",
	"cosmo_job_cashier",
	"cosmo_job_cleaner",
	"cosmo_job_fuel",
	"cosmo_job_hacker",
	"cosmo_job_pizzamaker",
	"cosmo_jobhandler",
	"cosmo_jobmaps",
	"cosmo_jobvehicle",
	"cosmo_model_loader",

	--[Maps]--
	"cosmo_maps",

	--[Models]--
	"cosmo_newcars",
	"cosmo_garagemodell",
	"cosmo_mods_obj",
	"cosmo_mods_skin",
	"cosmo_mods_veh",
	"cosmo_mods_weapon",
	"cosmo_cityhall_modell",
	"cosmo_winbirtok",
	"cosmo_maganbirtok",

	--[Picsu]--
	"s_flashbang",
	"cosmo_mappfix",
	"cosmo_mechanic-cp",
	"cosmo_ppshop",
	"cosmo_pump",
	"cosmo_textures-picsu",
	"cosmo_tips",
	"romanmap",
	"uszo",
	"picsu_birtokgate",
	"cosmo_heliszerelo",
	"cosmo_balanceminigame",
	"cosmo_maverickrotor",
	"alhambra",
	"utca",
	"birtokmap",
	"birtokmodel",
	"map_hazak",
	"cosmo_eszakimod",
	"eszaki",

	--[Tuningsystem]--
	"cosmo_supercharger",
	"cosmo_airride",
	"cosmo_cars",
	"cosmo_drivetype",
	"cosmo_facelifts",
	"cosmo_handling",
	"cosmo_paintjobs",
	"cosmo_plates",
	"cosmo_tuning",
	"cosmo_vehicles",
	"cosmo_wheels",
	"cosmo_wheeltextures",

	--[Vehicle]--
	"cosmo_carshop",
	"cosmo_fuel",

	--[HOSPITAL]--
	"cosmo_hospital",
	"cosmo_hospital_map",

	--[Viktor]--
	"cosmo_3dtext",
	"cosmo_binco",
	"cosmo_borders",
	"cosmo_case",
	"cosmo_druglab",
	"cosmo_ferriswheel",
	"cosmo_interioredit",
	"cosmo_interiors",
	"cosmo_radio",
	"cosmo_rajt",
	"cosmo_shutdown",
	"cosmo_sounds",
	"cosmo_vehiclepanel",
	"cosmo_vehicleradio",
	"cosmo_clothesshop",
	"cosmo_animations",


	--[Voice]--
	"cosmo_voice",
	"cosmo_voicerp",
	
	--ALL MAPPA--
	"cosmo_accounts",
	"cosmo_alert",
	"cosmo_anticheat",
	"cosmo_assets",
	"cosmo_bank",
	"cosmo_bone_attach",
	"cosmo_boneattach",
	"cosmo_channelwater",
	"cosmo_chat",
	"cosmo_controls",
	"cosmo_crosshair",
	"cosmo_damage",
	"cosmo_dashboard",
	"cosmo_death",
	"cosmo_dpg",
	"cosmo_dx",
	"cosmo_glue",
	"cosmo_interaction",
	"cosmo_inventory",
	"cosmo_licenses",
	"cosmo_loader",
	"cosmo_mdc",
	"cosmo_minigame",
	"cosmo_nametag",
	"cosmo_newdebug",
	"cosmo_npcs",
	"cosmo_performance",
	"cosmo_phone",
	"cosmo_remove",
	"cosmo_removelv",
	"cosmo_rent",
	"cosmo_service",
	"cosmo_shader",
	"cosmo_shop",
	"cosmo_tempomat",
	"cosmo_textures",
	"cosmo_ticket",
	"cosmo_traffipax",
	"cosmo_trafimodel",
	"cosmo_ui",
	"cosmo_water",
	"cosmo_weapons",
	"cosmo_weaponship",
	"cosmo_kupon",
	"cosmo_weather",
	"cosmo_wheels-other",
	"cosmo_workaround",
	"cosmo_spoiler",

	"cosmo_adminpanel",

	"cosmo_ppmodells",
	"erik_sziget",
	"zee_Maganbirtok",
	"strikerppmapbywatta",

	"cosmo_object",
}

local failedToLoad = false

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		local tickCount = getTickCount()

		for i = 1, #resources do
			local resname = getResourceFromName(resources[i])
			local state = startResource(resname)

			if resname == "cosmo_database" and not state then
				failedToLoad = true
				break
			end
		end

		if failedToLoad then
			print("[UNITE]: Nincs kapcsolat az adatbázissal ezért a resourcek nem indultak el.")
		else
			print("[UNITE]: Mod started in " .. getTickCount() - tickCount .. " ms.")
		end
	end
)

addEventHandler("onResourceStop", getResourceRootElement(),
	function ()
		for i = #resources, 1, -1 do
			stopResource(getResourceFromName(resources[i]))
		end
	end
)

function getResourceList()
	return resources
end