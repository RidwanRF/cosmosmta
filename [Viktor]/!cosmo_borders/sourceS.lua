local longVehicles = {
	[409] = true,
	[431] = true,
	[437] = true,
	[408] = 1500,
	[407] = true,
	[544] = true,
	[578] = true,
	[443] = true,
	[515] = 5000,
	[514] = 5000,
	[508] = 1000
}

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		for i = 1, #availableBorders do
			setElementData(resourceRoot, "border." .. i .. ".mode", 1)
			setElementData(resourceRoot, "border." .. i .. ".state", false)
		end
	end)

addEvent("openTheBorder", true)
addEventHandler("openTheBorder", root, 
    function (currentBorderId, currentBorderColShapeId, pedveh)
        if exports.cosmo_core:takeMoney(source, 100000, "BORDER_CROSS") then
           -- triggerClientEvent(root, "warnAboutBorderCross", source, pedveh)

            for index, value in ipairs (getElementsByType("player")) do 
				if exports.cosmo_groups:isPlayerInGroup(value,1) or exports.cosmo_groups:isPlayerInGroup(value,4) or exports.cosmo_groups:isPlayerInGroup(value,57) then 
					if not getElementData(value, "togBorderMessage") then
						local vehID = getElementModel(getPedOccupiedVehicle(value))
						local vehName = exports.cosmo_mods_veh:getVehicleNameFromModel(vehID) or "Ismeretlen"
						local Plate = getVehiclePlateText(getPedOccupiedVehicle(value)) or "Ismeretlen rendszám"
						local r, g, b, r1, g1, b1 = getVehicleColor(getPedOccupiedVehicle(value))
						
						outputChatBox("#ff9428[Határ]:#ffffff Egy #ff9428".. vehName.. "#ffffff átlépte a határt!", value, 255, 255, 255, true)
						outputChatBox("#ff9428[Határ]:#ffffff Rendszám: #ff9428" .. Plate, value, 255, 255, 255, true)
						local vehicle = getPedOccupiedVehicle(value)
						local occupants = getVehicleOccupants(vehicle) or {}
						for seat, occupant in pairs(occupants) do 
							if (occupant and getElementType(occupant) == "player") then 
								if seat == 0 then 
									outputChatBox("#ff9428[Határ]:#ffffff Sofőr: #ff9428" .. getElementData(occupant, "char.Name") or "Ismeretlen" , value, 255, 255, 255, true)
								else
									outputChatBox("#ff9428[Határ]:#ffffff Utasok: #ff9428" .. getElementData(occupant, "char.Name") or "Ismeretlen" , value, 255, 255, 255, true)
								end
							end
						end
					end
				end
			end

            setElementData(resourceRoot, "border." .. currentBorderId .. ".state", true)

            setTimer(function() setElementData(resourceRoot, "border." .. currentBorderId .. ".state", false) end, 5000, 1)
        else
            exports.cosmo_hud:showInfobox("error", "Nincs elég pénzed az átlépési díj kifizetésére!", source)
        end
    end
)

addEvent("closeTheBorder", true)
addEventHandler("closeTheBorder", getRootElement(),
	function (borderId, colShapeId, vehicle)
		if borderId and colShapeId and vehicle then
			local model = getElementModel(vehicle)

			removeElementData(vehicle, "borderTargetColShapeId")

			if longVehicles[model] then
				setTimer(setElementData, tonumber(longVehicles[model]) or 2000, 1, resourceRoot, "border." .. borderId .. ".state", false)
			else
				setElementData(resourceRoot, "border." .. borderId .. ".state", false)
			end

			--triggerClientEvent(getElementsByType("player"), "warnAboutBorderCross", source, vehicle)
		end
	end)

addEvent("warnAboutBorderSet", true)
addEventHandler("warnAboutBorderSet", getRootElement(),
	function (playerName, borderId, set)
		if playerName and borderId and set then
			triggerClientEvent(getElementsByType("player"), "warnAboutBorderSet", source, playerName, borderId, set)
		end
	end)

setFPSLimit(61)

-- function toghatar(thePlayer)
-- 	if exports.cosmo_groups:isPlayerInGroup(thePlayer, 1) or exports.cosmo_groups:isPlayerInGroup(thePlayer, 57) or exports.cosmo_groups:isPlayerInGroup(thePlayer, 4) then 
-- 		if (getElementData(thePlayer, "faction:toghatar") == 0) then
-- 			setElementData(thePlayer, "faction:toghatar", 1)
-- 			outputChatBox("#ff9428[CosmoMTA]:#ffffff Bekapcsoltad a határ ellenőrzés szöveget.", thePlayer, 255, 255, 255, true)
-- 		else
-- 			setElementData(thePlayer, "faction:toghatar", 0)
-- 			outputChatBox("#ff9428[CosmoMTA]:#ffffff Kikapcsoltad a határ ellenőrzés szöveget.", thePlayer, 255, 255, 255, true)
-- 		end
-- 	end
-- end
-- addCommandHandler("toghatar", toghatar, false,false)
-- addCommandHandler("togborder", toghatar, false,false)

function toggleLogs(player)
	if exports.cosmo_groups:isPlayerInGroup(player, 1) or exports.cosmo_groups:isPlayerInGroup(player, 57) or exports.cosmo_groups:isPlayerInGroup(player, 4) then
		local pmBlocked = getElementData(player, "togBorderMessage")
		if pmBlocked then
			setElementData(player, "togBorderMessage", false)
			outputChatBox("#ff9428[CosmoMTA]:#ffffff Bekapcsoltad a határ ellenőrzés szöveget.", player, 255, 255, 255, true)
		else
			setElementData(player, "togBorderMessage", true)
			outputChatBox("#ff9428[CosmoMTA]:#ffffff Kikapcsoltad a határ ellenőrzés szöveget.", player, 255, 255, 255, true)
		end
	end
end
addCommandHandler("toghatar", toggleLogs)
addCommandHandler("togborder", toggleLogs)