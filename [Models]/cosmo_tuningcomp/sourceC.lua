local modificationList = {}
local threadTimer = false
local pendingCount = 0

local function registerMod(carModel, upgradeName, upgradeModel)
	local model = tonumber(carModel) or getVehicleModelFromName(carModel)

	if not modificationList[model] then
		modificationList[model] = {}
		modificationList[model].path = carModel
		modificationList[model].upgrades = {}
	end

	if upgradeName then
		table.insert(modificationList[model].upgrades, {upgradeModel, upgradeName})
	end
end

local function loadMod(model, upgrade)
	local path = ""

	if not upgrade then
		path = modificationList[model].path
	else
		path = upgrade
	end

	if fileExists("mods/" .. path .. ".txd") then
		local txd = engineLoadTXD("mods/" .. path .. ".txd")
		if txd then
			engineImportTXD(txd, model)
		end
	end

	if fileExists("mods/" .. path .. ".dff") then
		local dff = engineLoadDFF("mods/" .. path .. ".dff", model)
		if dff then
			engineReplaceModel(dff, model)
		end
	end
end

local function preLoadMod(model, upgrade)
	if isTimer(threadTimer) then
		killTimer(threadTimer)
	end

	threadTimer = setTimer(
		function ()
			pendingCount = 0
		end,
	200, 1)

	if pendingCount > 0 then
		setTimer(loadMod, pendingCount * 250, 1, model, upgrade)
		return
	end

	pendingCount = pendingCount + 1

	loadMod(model, upgrade)
end

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		local nextPreLoadTime = 50

		for model, data in pairs(modificationList) do
			setTimer(preLoadMod, nextPreLoadTime, 1, model)
			nextPreLoadTime = nextPreLoadTime + 50

			for k, upgrade in ipairs(data.upgrades) do
				setTimer(preLoadMod, nextPreLoadTime, 1, upgrade[1], upgrade[2])
				nextPreLoadTime = nextPreLoadTime + 50
			end
		end
	end
)

registerMod("elegy", "exh_a_l", 1034)
registerMod("elegy", "exh_c_l", 1037)
registerMod("elegy", "fbmp_a_l", 1171)
registerMod("elegy", "fbmp_c_l", 1172)
registerMod("elegy", "rbmp_a_l", 1149)
registerMod("elegy", "rbmp_c_l", 1148)
registerMod("elegy", "spl_a_l_b", 1147)
registerMod("elegy", "spl_c_l_b", 1146)
registerMod("elegy", "wg_L_a_l", 1036)
registerMod("elegy", "wg_l_c_l", 1039)
registerMod("elegy", "wg_r_a_l", 1040)
registerMod("elegy", "wg_r_c_l", 1041)
registerMod("elegy", "exh_a_f", 1046)
registerMod("elegy", "exh_c_f", 1045)
registerMod("elegy", "fbmp_a_f", 1153)
registerMod("elegy", "fbmp_c_f", 1152)
registerMod("elegy", "rbmp_a_f", 1150)
registerMod("elegy", "rbmp_c_f", 1151)
registerMod("elegy", "rf_a_f", 1054)
registerMod("elegy", "rf_c_f", 1053)
registerMod("elegy", "spl_a_f_r", 1049)
registerMod("elegy", "spl_c_f_r", 1050)
registerMod("elegy", "wg_l_a_f", 1047)
registerMod("elegy", "wg_l_c_f", 1048)
registerMod("elegy", "wg_r_a_f", 1051)
registerMod("elegy", "wg_r_c_f", 1052)

registerMod("jester", "exh_a_j", 1065)
registerMod("jester", "exh_c_j", 1066)
registerMod("jester", "fbmp_a_j", 1160)
registerMod("jester", "fbmp_c_j", 1173)
registerMod("jester", "rbmp_a_j", 1159)
registerMod("jester", "rbmp_c_j", 1161)
registerMod("jester", "rf_a_j", 1067)
registerMod("jester", "rf_c_j", 1068)
registerMod("jester", "spl_a_j_b", 1162)
registerMod("jester", "spl_c_j_b", 1158)
registerMod("jester", "wg_l_a_j", 1070)
registerMod("jester", "wg_r_a_j", 1071)
registerMod("jester", "wg_r_c_j", 1072)
