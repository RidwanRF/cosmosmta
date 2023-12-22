local connection = false

addEventHandler("onResourceStart", getRootElement(),
	function (startedResource)
		if getResourceName(startedResource) == "cosmo_database" then
			connection = exports.cosmo_database:getConnection()
		elseif source == getResourceRootElement() then
			local cosmo_database = getResourceFromName("cosmo_database")

			if cosmo_database and getResourceState(cosmo_database) == "running" then
				connection = exports.cosmo_database:getConnection()
			end
		end
	end, true, "high+99"
)

function setHorn(thePlayer, command, state)
	if getElementData(thePlayer, "acc.adminLevel") >= 10 then
        if not state then
            outputChatBox("#ff9428[CosmoMTA]: #ffffff/" .. command .. " [0=Kivétel, >=1 Berakás (Azonosító)]", thePlayer, 255, 0, 0, true)
        else
            local vehicle = getPedOccupiedVehicle(thePlayer)
            local dbid = getElementData(vehicle, "vehicle.dbID")
            setElementData(vehicle, "danihe->vehicles->customhorn", state)
            outputChatBox("#ff9428[CosmoMTA]: #ffffffSikeresen beletettél a kocsiba egy egyedi dudát! #33ccff[" .. state .. "]", thePlayer, 255, 0, 0, true)
        end
    end
end
addCommandHandler("setcustomhorn", setHorn)

function playHornSound(vehicle)
local data = getElementData(vehicle, "danihe->vehicles->customhorn")
local model = getElementModel(vehicle)
    if vehicle then
        if data then
          triggerClientEvent(root, "playHornSoundClient", vehicle, "horns/" .. data .. ".mp3")
        end
    end
end
addEvent("playHornSound", true)
addEventHandler ( "playHornSound", getRootElement(), playHornSound )

function stopHornSound(vehicle)
local data = getElementData(vehicle, "danihe->vehicles->customhorn")
local model = getElementModel(vehicle)
    if vehicle then
          triggerClientEvent(root, "destroyHornSoundClient", vehicle)
    end
end
addEvent("stopHornSound", true)
addEventHandler ( "stopHornSound", getRootElement(), playHornSound )