addEvent("playTurboSound", true)
addEventHandler("playTurboSound", getRootElement(),
	function (vehicle, turboLevel, players)
		if isElement(vehicle) and turboLevel and #players > 0 then
			triggerClientEvent(players, "playTurboSound", vehicle, turboLevel)
		end
	end)

addEvent("doVehicleDoorInteract", true)
addEventHandler("doVehicleDoorInteract", getRootElement(),
	function (vehicle, door, doorname)
		if isElement(source) and door then
			local doorRatio = getVehicleDoorOpenRatio(vehicle, door)

			if doorRatio <= 0 then
				setVehicleDoorOpenRatio(vehicle, door, 1, 500)

				triggerClientEvent(getElementsByType("player"), "playDoorEffect", source, vehicle, "open")

				exports.cosmo_chat:sendLocalMeAction(source, "kinyitja a " .. doorname .. "t.")
			elseif doorRatio > 0 then
				setVehicleDoorOpenRatio(vehicle, door, 0, 250)

				setTimer(triggerClientEvent, 250, 1, getElementsByType("player"), "playDoorEffect", source, vehicle, "close")
				
				exports.cosmo_chat:sendLocalMeAction(source, "becsukja a " .. doorname .. "t.")
			end

			setPedAnimation(source, "ped", "CAR_open_LHS", 300, false, false, true, false)
		end
	end)

addEvent("syncVehicleSound", true)
addEventHandler("syncVehicleSound", getRootElement(),
	function (path, nearby, typ)
		if isElement(source) then
			if path then
				--triggerClientEvent(nearby, "syncVehicleSound", source, typ or "3d", path)
			end
		end
	end)

addEvent("toggleEngine", true)
addEventHandler("toggleEngine", getRootElement(),
	function (vehicle, toggle)
		if isElement(vehicle) then
			local vehicleId = getElementData(vehicle, "vehicle.dbID") or 0
			local adminDuty = getElementData(source, "adminDuty") or 0

			if vehicleId > 0 then
				if adminDuty == 0 then
					if not (exports.cosmo_inventory:hasItemWithData(source, 2, "data1", vehicleId) or not getElementData(vehicle, "vehicle.job") ~= 0 or getElementData(source, "adminDuty")) then
						exports.cosmo_hud:showInfobox(source, "error", "Ehhez a járműhöz nincs kulcsod!")
						return
					end
				end
			else
				if adminDuty == 0 then
					local jobSpawner = getElementData(vehicle, "jobSpawner")

					if jobSpawner ~= getElementData(source, "playerID") then
						exports.cosmo_hud:showInfobox(source, "error", "Ehhez a járműhöz nincs kulcsod!")
						return
					end
				end
			end

			local vehicleModel = getElementModel(vehicle)

			if toggle then
				if getElementHealth(vehicle) <= 320 then
					exports.cosmo_hud:showInfobox(source, "error", "A jármű motorja túlságosan sérült.")
					exports.cosmo_chat:sendLocalMeAction(source, "megpróbálja beindítani a jármű motorját, de nem sikerül neki.")
					return
				end

				if (getElementData(vehicle, "vehicle.fuel") or 50) <= 0 then
					exports.cosmo_hud:showInfobox(source, "error", "Nincs elég üzemanyag a járműben.")
					exports.cosmo_chat:sendLocalMeAction(source, "megpróbálja beindítani a jármű motorját, de nem sikerül neki.")
					return
				end

				exports.cosmo_chat:sendLocalMeAction(source, "beindítja egy " .. exports.cosmo_mods_veh:getVehicleNameFromModel(vehicleModel) .. " motorját.")
			else
				exports.cosmo_chat:sendLocalMeAction(source, "leállítja egy " .. exports.cosmo_mods_veh:getVehicleNameFromModel(vehicleModel) .. " motorját.")
			end
			
			setVehicleEngineState(vehicle, toggle)


			setElementData(vehicle, "vehicle.engine", toggle and 1 or 0)
		end
	end)

addEventHandler("onVehicleEnter", getRootElement(),
	function ()
		local vehicleType = getVehicleType(source)

		if vehicleType ~= "BMX" then
			setVehicleEngineState(source, getElementData(source, "vehicle.engine") == 1)
			setVehicleDamageProof(source, false) 
		end

		if vehicleType == "BMX" or vehicleType == "Bike" or vehicleType == "Boat" then
			setElementData(source, "vehicle.windowState", true)
		end
	end)