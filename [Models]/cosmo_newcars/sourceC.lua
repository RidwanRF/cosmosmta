function loadVehModel(name, model, key)
	local file = fileOpen(name)
	local size = fileGetSize(file)
	local bytes = fileRead(file, size)

	fileClose(file)

	local sections = splitEx(bytes, ";")

	for k, v in pairs(sections) do
		processData = sections[k]

		local isTXD = string.find(processData, "isTxd")
		local isDFF = string.find(processData, "isDff")

		processData = string.gsub(processData, "isTxd", "")
		processData = string.gsub(processData, "isDff", "")

		processData = teaDecode(processData, key)
		processData = base64Decode(processData)

		if isTXD then
			engineImportTXD(engineLoadTXD(processData), model)
		elseif isDFF then
			engineReplaceModel(engineLoadDFF(processData), model)
		end
	end
end

addEvent("decodeAndLoadVehModels", true)
addEventHandler("decodeAndLoadVehModels", getRootElement(),
	function (key)
		for k, v in pairs(availableModels) do
			if fileExists("files/" .. k .. ".cosmovehicle") then
				setTimer(
					function(key)
						loadVehModel("files/" .. k .. ".cosmovehicle", v, key)
					end,
				1000, 1, key)
			end
		end
	end
)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		triggerServerEvent("requestVehDecodeKey", localPlayer, localPlayer)
	end
)