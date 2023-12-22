local theKey = "8$nQe^WbJ3*XZsMb"

addEvent("requestVehDecodeKey", true)
addEventHandler("requestVehDecodeKey", getRootElement(),
	function (player)
		if isElement(source) and player then
			if client == source and source == player then
				triggerClientEvent(source, "decodeAndLoadVehModels", source, theKey)
			end
		end
	end
)

exports.cosmo_admin:addAdminCommand("encodemodels", 9, "Modell(ek) lekódolása")
addCommandHandler("encodevehmodels",
	function (player, cmd, ...)
		if getElementData(player, "acc.adminLevel") >= 9 then
			local names = {...}

			if string.len(#names) > 0 then
				for k, v in pairs(names) do
					local data = ""

					if fileExists("server_files/" .. v .. ".txd") then
						local file = fileOpen("server_files/" .. v .. ".txd", true)
						local size = fileGetSize(file)
						local bytes = fileRead(file, size)
						fileClose(file)

						data = data .. "isTxd" .. teaEncode(base64Encode(bytes), theKey) .. ";"
					end

					if fileExists("server_files/" .. v .. ".dff") then
						local file = fileOpen("server_files/" .. v .. ".dff", true)
						local size = fileGetSize(file)
						local bytes = fileRead(file, size)
						fileClose(file)

						data = data .. "isDff" .. teaEncode(base64Encode(bytes), theKey) .. ";"
					end

					if fileExists("files/" .. v .. ".cosmovehicle") then
						fileDelete("files/" .. v .. ".cosmovehicle")
					end

					local file = fileCreate("files/" .. v .. ".cosmovehicle")
					fileWrite(file, data)
					fileClose(file)

					outputDebugString("[encode]: 'files/" .. v .. ".cosmovehicle' created.")
				end
			else
				outputChatBox("#ff4646>> Használat: #ffffff/" .. cmd .. " [modell nevek, szóközzel elválasztva ha egyszerre többet akarsz]", 255, 255, 255, true)
			end
		end
	end
)