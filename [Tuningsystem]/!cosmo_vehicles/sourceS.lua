--[[

CREATE TABLE `vehicles` (
	`vehicleID` INT(22) NOT NULL PRIMARY KEY AUTO_INCREMENT,
	`owner` INT(22) NOT NULL DEFAULT '0',
	`model` INT(3) NOT NULL DEFAULT '400',
	`groupID` INT(3) NOT NULL DEFAULT '0',
	`position` TEXT,
	`parkedPosition` TEXT,
	`health` INT(4) NOT NULL DEFAULT '1000',
	`fuel` INT(4) NOT NULL DEFAULT '50',
	`maxFuel` INT(4) NOT NULL DEFAULT '50',
	`engine` INT(1) NOT NULL DEFAULT '0',
	`light` INT(1) NOT NULL DEFAULT '0',
	`locked` INT(1) NOT NULL DEFAULT '0',
	`handBrake` INT(1) NOT NULL DEFAULT '0',
	`color` TEXT,
	`headLightColor` TEXT,
	`wheels` VARCHAR(7) NULL,
	`panels` VARCHAR(13) NULL,
	`doors` VARCHAR(11) NULL,
	`distance` INT(11) NOT NULL DEFAULT '0',
	`lastOilChange` INT(5) NOT NULL DEFAULT '0',
	`licensePlate` VARCHAR(8) NULL,
	`unit` VARCHAR(200) NULL,
	`impound` TEXT,
	`sirenPanel` INT(1) NOT NULL DEFAULT '0',
	`matrica` INT(3) NOT NULL DEFAULT '0',
	`theTicket` TEXT,
	`wheelClamp` ENUM('N', 'Y') NOT NULL DEFAULT 'N'
) DEFAULT CHARSET=utf8_hungarian_ci;

]]

local connection = false

local vehiclesCache = {}
local loadedVehicles = {}
local explodedVehicles = {}

addEventHandler("onElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if dataName == "vehicle.wheelClamp" then
			if getElementData(source, dataName) then
				setElementFrozen(source, true)
			elseif oldValue then
				setElementFrozen(source, false)
			end
		end
	end)

exports.cosmo_admin:addAdminCommand("deletevehicles", 9, "Összes jármű törlése")
addCommandHandler("deletevehicles",
	function (player, cmd, state)
		if getElementData(player, "acc.adminLevel") >= 9 then
			if not state then
				outputChatBox(exports.cosmo_core:getServerTag("admin") .. "Biztos vagy benne, hogy törlöd az összes járművet? Ha igen, használd az #ffa600/" .. cmd .. " yes #ffffffparancsot.", player, 0, 0, 0, true)
			elseif state == "yes" then
				deleteVehicles("all")

				outputChatBox(exports.cosmo_core:getServerTag("admin") .. "Az összes jármű sikeresen törölve.", player, 0, 0, 0, true)
			end
		end
	end
)

exports.cosmo_admin:addAdminCommand("setvehgroup", 6, "Jármű frakcióba tétele/kivétele")
addCommandHandler("setvehgroup",
	function (player, cmd, vehId, groupId)
		if getElementData(player, "acc.adminLevel") >= 6 then
			if not tonumber(vehId) or not tonumber(groupId) then
				outputChatBox(exports.cosmo_core:getServerTag("usage") .. "/" .. cmd .. " [Jármű ID] [Csoport ID]", player, 0, 0, 0, true)
			else
				vehId = tonumber(vehId)
				groupId = tonumber(groupId)

				if loadedVehicles[vehId] then
					local groups = exports.cosmo_groups:getGroups()

					if groups[groupId] or groupId == 0 then
						dbQuery(
							function (qh)
								setElementData(loadedVehicles[vehId], "vehicle.group", groupId)

								if isElement(player) then
									if groupId == 0 then
										outputChatBox(exports.cosmo_core:getServerTag("admin") .. "A kiválasztott jármű sikeresen eltávolítva a kiválasztott frakcióból.", player, 0, 0, 0, true)
									else
										outputChatBox(exports.cosmo_core:getServerTag("admin") .. "A kiválasztott jármű sikeresen hozzáadva a kiválasztott frakcióhoz. #ffff99(" .. groups[groupId].name .. ")", player, 0, 0, 0, true)
									end
								end

								dbFree(qh)
							end, connection, "UPDATE vehicles SET groupID = ? WHERE vehicleID = ?", groupId, vehId
						)
					else
						outputChatBox(exports.cosmo_core:getServerTag("error") .. "A kiválasztott frakció nem létezik!", player, 0, 0, 0, true)
					end
				else
					outputChatBox(exports.cosmo_core:getServerTag("error") .. "A kiválasztott jármű nem létezik vagy nincs lespawnolva!", player, 0, 0, 0, true)
				end
			end
		end
	end
)

addEventHandler("onResourceStart", getRootElement(),
	function (startedResource)
		if getResourceName(startedResource) == "cosmo_inventory" then
			for k, v in pairs(loadedVehicles) do
				exports.cosmo_inventory:loadItems(v, k)
			end
		elseif startedResource == getThisResource() then
			connection = exports.cosmo_database:getConnection()

			loadGroupVehicles()

			for k, v in ipairs(getElementsByType("player")) do
				if getElementData(v, "loggedIn") then
					local characterId = getElementData(v, "char.ID") or 0

					if characterId > 0 then
						loadPlayerVehicles(characterId, v)
					end
				end
			end

			setTimer(processExplodedVehicles, 5000, 0)
		end
	end
)

addEventHandler("onResourceStop", getResourceRootElement(),
	function (stoppedResource)
		saveAllVehicles()
	end
)

addEvent("loadPlayerVehicles", true)
addEventHandler("loadPlayerVehicles", getRootElement(),
	function (charID)
		loadPlayerVehicles(charID, source)
	end
)

function loadGroupVehicles()
	dbQuery(
		function (qh)
			local result, rows = dbPoll(qh, 0)

			if rows > 0 then
				for _, row in pairs(result) do
					loadVehicle(row)
				end
			end
		end, connection, "SELECT * FROM vehicles WHERE groupID > 0"
	)
end

function loadPlayerVehicles(charID, playerElement)
	if not charID then
		return
	end

	charID = tonumber(charID)

	dbQuery(
		function (qh, charID, sourcePlayer)
			if isElement(sourcePlayer) then
				local result, rows = dbPoll(qh, 0)

				if rows > 0 then
					local impoundVehicles = {}

					vehiclesCache[charID] = {}

					for _, row in pairs(result) do
						if row.impound and utfLen(row.impound) > 0 and row.impound ~= "NULL" then
							local data = split(row.impound, "/")

							if tonumber(data[4]) ~= tonumber(data[5]) and tonumber(data[5]) > getRealTime().timestamp then
								row.impound = ""

								dbExec(connection, "UPDATE vehicles SET impound = '' WHERE vehicleID = ?", row.vehicleID)
							else
								table.insert(impoundVehicles, row)
							end
						end

						table.insert(vehiclesCache[charID], row.vehicleID)

						loadVehicle(row)
					end

					if #impoundVehicles > 0 and isElement(sourcePlayer) then
						outputChatBox(exports.cosmo_core:getServerTag("info") .. "Neked #ffff99" .. #impoundVehicles .. "#ffffff db lefoglalt járműved van.", sourcePlayer, 0, 0, 0, true)

						for i = 1, #impoundVehicles do
							local vehData = impoundVehicles[i]

							outputChatBox(" - Rendszám: #ffff99" .. vehData.licensePlate .. "#ffffff, Típus: #ffff99" .. exports.cosmo_mods_veh:getVehicleNameFromModel(vehData.model), sourcePlayer, 255, 255, 255, true)
						end

						outputChatBox(exports.cosmo_core:getServerTag("info") .. "További információkért látogasson el a kapitányságunkra.", sourcePlayer, 0, 0, 0, true)
					end
				end
			else
				dbFree(qh)
			end
		end, {charID, playerElement}, connection, "SELECT * FROM vehicles WHERE owner = ? AND groupID = '0'", charID
	)
end

function loadVehicle(data)
	if data then
		local vehicleID = data.vehicleID

		if isElement(loadedVehicles[vehicleID]) then
			return
		end

		local licensePlate = data.licensePlate
		if not licensePlate or utfLen(licensePlate) <= 0 then
			licensePlate = processLicensePlate(vehicleID)
			--print(licensePlate)

			dbExec(connection, "UPDATE vehicles SET licensePlate = ? WHERE vehicleID = ?", licensePlate, vehicleID)
		end

		local position = fromJSON(data.position)
		local vehicle = createVehicle(data.model, position[1], position[2], position[3], position[4], position[5], position[6], licensePlate, false)

		if vehicle then
			triggerClientEvent("vehicleSpawnProtect", vehicle, vehicle)

			setVehicleRespawnPosition(vehicle, position[1], position[2], position[3], position[4], position[5], position[6])
			setElementData(vehicle, "vehicle.parkedPosition", position)

			--print("Load vehicle [" .. vehicleID .. "] for characterId: " .. data.owner)

			setElementData(vehicle, "vehicle.dbID", vehicleID)
			setElementData(vehicle, "vehicle.owner", data.owner)
			setElementData(vehicle, "vehicle.group", data.groupID)
			setElementData(vehicle, "vehicle.RadioStation", 1)
			--setElementData(vehicle,"danihe->vehicles->variant", 5)

			setElementData(vehicle, "vehicle.engine", data.engine == 1)
			setElementData(vehicle, "vehicle.locked", data.locked == 1)
			setElementData(vehicle, "vehicle.light", data.light == 1)
			setElementData(vehicle, "vehicle.handBrake", data.handBrake == 1)

			setElementData(vehicle, "spoilerState", "downed")

			setVehicleEngineState(vehicle, data.engine == 1)
			setVehicleLocked(vehicle, data.locked == 1)
			setVehicleOverrideLights(vehicle, data.light == 1 and 2 or 1)
			setElementFrozen(vehicle, data.handBrake == 1)

			setVehiclePlateText(vehicle, licensePlate)

			if data.doors and utf8.len(data.doors) > 0 then
				local doors = split(data.doors, "/")

				for i = 1, #doors do
					setVehicleDoorState(vehicle, i - 1, tonumber(doors[i]))
				end
			end

			if data.panels and utf8.len(data.panels) > 0 then
				local panels = split(data.panels, "/")

				for i = 1, #panels do
					setVehiclePanelState(vehicle, i - 1, tonumber(panels[i]))
				end
			end

			if data.wheels and utf8.len(data.wheels) > 0 then
				local wheels = split(data.wheels, "/")

				setVehicleWheelStates(vehicle, tonumber(wheels[1]), tonumber(wheels[2]), tonumber(wheels[3]), tonumber(wheels[4]))
			end

			--if data.headLightColor then
				--setVehicleHeadLightColor(vehicle, unpack(fromJSON(data.headLightColor))) --wardis -- bocsi de lehet nem te rontottad el? mert sql-be teszt-et írtál :D nem az csak akkor ha nincs rajta mas vagy nem tud mas rarakni
			--end

			local headLightColor = data.headLightColor

			if headLightColor then
				headLightColorFromJSON = fromJSON(headLightColor) or {255, 255, 255}
				if headLightColorFromJSON then
					setVehicleHeadLightColor(vehicle, unpack(headLightColorFromJSON)) -- faszomért vagy ki mindig az mta, idk lehet sok a ram hasznalat vram 6gb csak elég neki amúgy most tesztelnikell?
				end
			end

			--headLightColor = toJSON({getVehicleHeadLightColor(vehicle)})

			local r, g, b = unpack(fromJSON(data.color))
			setElementData(vehicle,"danihe->vehicles->bodyColor",{r, g, b})
			setVehicleColor(vehicle,r,g,b)

			setVehicleFuelTankExplodable(vehicle, false)
			--setVehicleColor(vehicle, unpack(fromJSON(data.color)))
			setElementHealth(vehicle, data.health or 1000)
			setElementInterior(vehicle, position[7])

			if data.impound and utfLen(data.impound) > 0 and data.impound ~= "NULL" then
				setElementData(vehicle, "vehicle.impound", data.impound)
				setElementData(vehicle, "vehicle.engine", false)

				setVehicleEngineState(vehicle, false)
				setElementDimension(vehicle, 6500)
			else
				setElementDimension(vehicle, position[8])
			end

			setElementData(vehicle,"danihe->tuning->airride",tonumber(data["airride"]))
			setElementData(vehicle,"danihe->tuning->airride_level",3)

			local avaibleTunes = exports.cosmo_tuning:getPerformanceTuneDatas()
			for k,v in ipairs(fromJSON(data.tunings)) do
				setElementData(vehicle,avaibleTunes[k],v)
			end

			if data["optics"] then
				local opticalTuning = fromJSON(data["optics"])

				if opticalTuning then
					for k, v in ipairs(opticalTuning) do
						addVehicleUpgrade(vehicle, v[2])
					end
				end
			end

			local nitro = fromJSON(data["nitro"])
			setElementData(vehicle, "danihe->tuning->nitro", tonumber(nitro[1]))
			setElementData(vehicle, "danihe->tuning->nitroprecent", tonumber(nitro[2]))


			setElementData(vehicle, "vehicle.fuel", data.fuel or 0)
			setElementData(vehicle, "vehicle.distance", data.distance or 0)
			setElementData(vehicle, "lastOilChange", data.lastOilChange or 0)

			setElementData(vehicle,"danihe->vehicles->neon", tonumber(data.neon))

			setElementData(vehicle, "danihe->tuning->backfire", data["backfire"])
			setElementData(vehicle, "danihe->vehicles->drivetype", data["drivetype"])
			setElementData(vehicle, "danihe->tuning->drivetype", data["dtState"])

			--setElementData(vehicle,"danihe->tuning->tiresmokeLeft",fromJSON(data["tiresmokeLeft"]))
			--setElementData(vehicle,"danihe->tuning->tiresmokeRight",fromJSON(data["tiresmokeRight"]))

			setVehicleHandling(vehicle,"steeringLock", tonumber(data["steeringLock"]))

			


			setElementData(vehicle,"danihe->vehicles->plate",licensePlate)
			setElementData(vehicle,"danihe->vehicles->plateStyle",tonumber(data["plateStyle"]))

			setElementData(vehicle,"danihe->vehicles->wheelsFront",fromJSON(data["wheelsFront"]))
			setElementData(vehicle,"danihe->vehicles->wheelsBack",fromJSON(data["wheelsBack"]))

			setElementData(vehicle,"danihe->vehicles->variant", tonumber(data.variant))
			setElementData(vehicle,"danihe->vehicles->matrica", tonumber(data.matrica))
			setElementData(vehicle,"danihe->vehicles->facelift", tonumber(data.facelift))
			setElementData(vehicle,"danihe->vehicles->wheeltexture", tonumber(data.wheeltexture))
			setElementData(vehicle,"danihe->tuning->backfire",tonumber(data["backfire"]))

			if data.unit and string.len(data.unit) > 0 then
				setElementData(vehicle, "siren.unit", data.unit)
			end

			if data.sirenPanel and data.sirenPanel == 1 then
				setElementData(vehicle, "vehicle.sirenPanel", true)
			end

			setElementData(vehicle, "siren.status", 1)


			if data.theTicket and utfLen(data.theTicket) > 10 and data.owner > 0 then
				local json_data = fromJSON(data.theTicket)
				
				if json_data and type(json_data) == "table" then
					local currentTime = getRealTime().timestamp
					local elapsedTime = json_data.elapsedTime or 0

					json_data.autoPayOut = currentTime + 172800 - elapsedTime

					data.theTicket = toJSON(json_data)
				end

				setElementData(vehicle, "vehicleTicket", data.theTicket)
			end

			setElementData(vehicle, "vehicle.wheelClamp", data.wheelClamp == "Y")

			if data.wheelClamp == "Y" then
				setElementFrozen(vehicle, true)
			end
			
            local tuningData = fromJSON(tostring(data.tuningData) or {}) or {}
            setElementData(vehicle, "vehicle.tuningData", tuningData)

            if tuningData["matrica"] then
                setElementData(vehicle, "danihe->vehicles->matrica", tuningData["matrica"] or 0)
            end
			
			if tuningData["facelift"] then
                setElementData(vehicle, "danihe->vehicles->facelift", tuningData["facelift"] or 0)
            end
			
			if tuningData["wheeltexture"] then
                setElementData(vehicle, "danihe->vehicles->wheeltexture", tuningData["wheeltexture"] or 0)
            end
			
			--[[setTimer(function()
                if tuningData["optical.14"] then 
                    exports.cosmo_newtuning:addOpticalTuning(vehicle, 14, tuningData["optical.14"])
                end 
        
                if tuningData["optical.15"] then 
                    exports.cosmo_newtuning:addOpticalTuning(vehicle, 15, tuningData["optical.15"])
                end 
        
                if tuningData["optical.3"] then 
                    exports.cosmo_newtuning:addOpticalTuning(vehicle, 3, tuningData["optical.3"])
                end 
        
                if tuningData["optical.0"] then 
                    exports.cosmo_newtuning:addOpticalTuning(vehicle, 0, tuningData["optical.0"])
                end 
        
                if tuningData["optical.12"] then 
                    exports.cosmo_newtuning:addOpticalTuning(vehicle, 12, tuningData["optical.12"])
                end 
        
                if tuningData["optical.2"] then 
                    exports.cosmo_newtuning:addOpticalTuning(vehicle, 2, tuningData["optical.2"])
                end 
        
                if tuningData["optical.13"] then 
                    exports.cosmo_newtuning:addOpticalTuning(vehicle, 13, tuningData["optical.13"])
                end 
        
                if tuningData["optical.7"] then 
                    exports.cosmo_newtuning:addOpticalTuning(vehicle, 7, tuningData["optical.7"])
                end 
        
                if tuningData["optical.9"] then 
                    exports.cosmo_newtuning:addOpticalTuning(vehicle, 9, tuningData["optical.9"])
                end
            end, 16000, 1)]]
    
           
    
            if tuningData["frontwheel"] then 
               -- exports.cosmo_newtuning:setVehicleHandlingFlags(vehicle, 3, wheelSizes[tuningData["frontwheel"]][1])
            end 
    
            if tuningData["rearwheel"] then 
               -- exports.cosmo_newtuning:setVehicleHandlingFlags(vehicle, 4, wheelSizes[tuningData["rearwheel"]][1])
            end 
    
            local driveTypes = {
                {"fwd", "Elsőkerék"},
                {"awd", "Összkerék"},
                {"rwd", "Hátsókerék"},
            }
    
            if tuningData["driveType"] then 
            --    exports.cosmo_newtuning:setVehicleHandling(vehicle, "driveType", driveTypes[tuningData["driveType"]][1])
            end 

			exports.cosmo_inventory:loadItems(vehicle, vehicleID)
			loadedVehicles[vehicleID] = vehicle
			
			setVehicleVariant(vehicle, data.variant, data.variant)
		end
	end
end

function saveAllVehicles()
	for k, v in pairs(loadedVehicles) do
		saveVehicle(v)
	end
end

function getLoadedVehicles()
	return loadedVehicles
end

function saveVehicle(vehicle)
	if not isElement(vehicle) then
		return
	end

	local vehicleID = getElementData(vehicle, "vehicle.dbID") or 0

	if vehicleID > 0 then
		do
			local x, y, z = getElementPosition(vehicle)
			local rx, ry, rz = getElementRotation(vehicle)
			local model = getElementModel(vehicle)
			local performanceTunes = {} 

			local doors = {}
			for i = 0, 5 do
				table.insert(doors, getVehicleDoorState(vehicle, i))
			end

			local panels = {}
			for i = 0, 6 do
				table.insert(panels, getVehiclePanelState(vehicle, i))
			end

			local frontLeft, rearLeft, frontRight, rearRight = getVehicleWheelStates(vehicle)
			local ticketData = getElementData(vehicle, "vehicleTicket")

			if ticketData then
				local json_data = fromJSON(ticketData)

				if json_data and type(json_data) == "table" then
					json_data.elapsedTime = json_data.autoPayOut - getRealTime().timestamp

					ticketData = toJSON(ticketData)
				else
					ticketData = ""
				end
			else
				ticketData = ""
			end

			local haveWheelClamp = getElementData(vehicle, "vehicle.wheelClamp") and "Y" or "N"
            local vari1, vari2 = getVehicleVariant(vehicle)

            local avaibleTunes = exports.cosmo_tuning:getPerformanceTuneDatas()

			for k, v in ipairs(avaibleTunes) do
				performanceTunes[k] = getElementData(vehicle,v) or 0
			end

			local c = {getVehicleColor(vehicle,true)}

			local bc = getElementData(vehicle,"danihe->vehicles->bodyColor") or {255,255,255}

			local tempOptics = {}

			for i = 1, 16 do
				local vehTuning = getVehicleUpgradeOnSlot(vehicle, i)

				if vehTuning then
					table.insert(tempOptics, {i, vehTuning})
				end
			end

			local datas = {
				position = toJSON({x, y, z, rx, ry, rz, getElementInterior(vehicle), getElementDimension(vehicle)}),
				engine = getElementData(vehicle, "vehicle.engine") and 1 or 0,
				locked = getElementData(vehicle, "vehicle.locked") and 1 or 0,
				light = getElementData(vehicle, "vehicle.light") and 1 or 0,
				handBrake = getElementData(vehicle, "vehicle.handBrake") and 1 or 0,
				fuel = getElementData(vehicle, "vehicle.fuel") or 0,
				maxFuel = getElementData(vehicle, "vehicle.maxFuel") or exports.cosmo_hud:getTheFuelTankSizeOfVehicle(model),
				distance = getElementData(vehicle, "vehicle.distance") or 0,
				lastOilChange = getElementData(vehicle, "lastOilChange") or 0,
				doors = table.concat(doors, "/"),
				panels = table.concat(panels, "/"),
				wheels = frontLeft .. "/" .. rearLeft .. "/" .. frontRight .. "/" .. rearRight,
				headLightColor = toJSON({getVehicleHeadLightColor(vehicle)}),
				health = math.max(320, math.min(getElementHealth(vehicle), 1000)),
				groupID = getElementData(vehicle, "vehicle.group") or 0,
				unit = getElementData(vehicle, "siren.unit") or "",
				sirenPanel = getElementData(vehicle, "vehicle.sirenPanel") and 1 or 0,
				matrica = getElementData(vehicle,"danihe->vehicles->matrica") or 0,
				facelift = getElementData(vehicle,"danihe->vehicles->facelift") or 0,
				wheeltexture = getElementData(vehicle,"danihe->vehicles->wheeltexture") or 0,
				theTicket = ticketData,
				wheelClamp = haveWheelClamp,
                tunings = toJSON(performanceTunes),
				airride = getElementData(vehicle,"danihe->tuning->airride") or 0,
				neon = getElementData(vehicle,"danihe->vehicles->neon") or 0,
				steeringLock = getVehicleHandling(vehicle)["steeringLock"] or 30,
				driveType = getElementData(vehicle,"danihe->vehicles->drivetype") or "def",
				--dtState = getElementData(vehicle, "danihe->tuning->drivetype") or 0,
				--backfire = getElementData(vehicle,"danihe->vehicles->back") or "def",
				nitro = toJSON({getElementData(vehicle,"danihe->tuning->nitro") or 0,getElementData(vehicle,"danihe->tuning->nitroprecent") or 0}),
				wheelsFront = toJSON(getElementData(vehicle,"danihe->vehicles->wheelsFront")),
				wheelsBack = toJSON(getElementData(vehicle,"danihe->vehicles->wheelsBack")),
				licensePlate = getElementData(vehicle,"danihe->vehicles->plate") or "CosmoMTA",
				plateStyle = getElementData(vehicle,"danihe->vehicles->plateStyle") or 1,
				color = toJSON({bc[1],bc[2],bc[3],c[4],c[5],c[6],c[7],c[8],c[9],c[10],c[11],c[12]}),
				variant = vari1 or 0,
				backfire = getElementData(vehicle,"danihe->tuning->backfire") or 0,
				optics = toJSON(tempOptics) or toJSON({})
			}

			local columns = {}
			local columnValues = {}

			for k,v in pairs(datas) do
				table.insert(columns, k .. " = ?")
				table.insert(columnValues, v)
			end

			table.insert(columnValues, vehicleID)

			dbExec(connection, "UPDATE vehicles SET " .. table.concat(columns, ", ") .. " WHERE vehicleID = ?", unpack(columnValues))

			local t1 = getElementData(vehicle, "danihe->tuning->airintake")
			local t2 = getElementData(vehicle, "danihe->tuning->fuelsystem")
			local t3 = getElementData(vehicle, "danihe->tuning->ignite")
			local t4 = getElementData(vehicle, "danihe->tuning->exhaust")
			local t5 = getElementData(vehicle, "danihe->tuning->camshaft")
			local t6 = getElementData(vehicle, "danihe->tuning->valve")
			local t7 = getElementData(vehicle, "danihe->tuning->engine")
			local t8 = getElementData(vehicle, "danihe->tuning->ecu")
			local t9 = getElementData(vehicle, "danihe->tuning->pistons")
			local t10 = getElementData(vehicle, "danihe->tuning->turbo")
			local t11 = getElementData(vehicle, "danihe->tuning->intercooler")
			local t12 = getElementData(vehicle, "danihe->tuning->oil_cooler")
			local t13 = getElementData(vehicle, "danihe->tuning->flywheel")
			local t14 = getElementData(vehicle, "danihe->tuning->brakes")
			local t15 = getElementData(vehicle, "danihe->tuning->suspension")
			local t16 = getElementData(vehicle, "danihe->tuning->chassis")
			local t17 = getElementData(vehicle, "danihe->tuning->weight")
			local t18 = getElementData(vehicle, "danihe->tuning->tires")
			local t19 = getElementData(vehicle, "danihe->tuning->clutch")
			local t20 = getElementData(vehicle, "danihe->tuning->gear")
			local t21 = getElementData(vehicle, "danihe->tuning->chain")
			local t22 = getElementData(vehicle, "danihe->tuning->diff")
			local t = {t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20,t21,t22}
			dbExec(connection, "UPDATE vehicles SET tunings = ? WHERE vehicleID = ?", toJSON(t), getElementData(vehicle, "vehicle.dbID"))
			--outputDebugString("Tuning: "..getElementData(vehicle,"vehicle.dbID").." (id) tunings save!",0,50,50,50)
		end
	end
end

function makeVehicle(model, owner, group, position, r, g, b)
	if not (model and isElement(owner)) then
		return
	end

	local charID = getElementData(owner, "char.ID") or 0

	group = group or 0

	if group < 0 then
		group = 0
	end

	if model < 400 or model > 611 then
		model = 400
	end

	r = r or 255
	g = g or 255
	b = b or 255

	position = position or {}

	for i = 1, 8 do
		position[i] = position[i] or 0
	end

	position = toJSON(position)

	local fuelCapacity = exports.cosmo_hud:getTheFuelTankSizeOfVehicle(model)
	dbExec(connection, "INSERT INTO vehicles (model, owner, groupID, position, parkedPosition, color, health, fuel, maxFuel, unit, handBrake) VALUES(?,?,?,?,?,?,?,?,?,?,?)", model, charID, group, position, position, toJSON({r, g, b}), 1000, fuelCapacity, fuelCapacity, "", 0)
	dbQuery(
		function (qh, targetPlayer)
			local result, rows = dbPoll(qh, 0)[1]

			if result then
				loadVehicle(result)

				if isElement(targetPlayer) then
					exports.cosmo_inventory:giveItem(targetPlayer, 2, 1, result.vehicleID)
				end
			end
		end, {owner}, connection, "SELECT * FROM vehicles WHERE vehicleID = LAST_INSERT_ID()"
	)
end

function deleteGroupVehicles(groupID)
	if not groupID then
		return
	end

	groupID = tonumber(groupID)

	local removableVehicles = {}

	for vehicleID, vehicleElement in pairs(loadedVehicles) do
		if getElementData(vehicleElement, "vehicle.group") == groupID then
			table.insert(removableVehicles, vehicleID)
		end
	end

	deleteVehicles(removableVehicles)
end

function deleteVehicles(vehicleIds)
	if vehicleIds == "all" then
		dbExec(connection, "TRUNCATE TABLE vehicles; DELETE FROM items WHERE itemId = '2'")

		for k, v in ipairs(getElementsByType("player")) do
			if getElementData(v, "char.ID") then
				exports.cosmo_inventory:removeAllItem(v, "itemId", 2)
			end
		end

		for k, v in pairs(loadedVehicles) do
			if isElement(loadedVehicles[k]) then
				destroyElement(loadedVehicles[k])
			end
		end

		loadedVehicles = {}
	else
		if not vehicleIds or type(vehicleIds) ~= "table" then
			return
		end

		if #vehicleIds > 0 then
			for i = 1, #vehicleIds do
				local vehicleID = vehicleIds[i]

				if loadedVehicles[vehicleID] then
					local ownerID = getElementData(loadedVehicles[vehicleID], "vehicle.owner")

					if ownerID and vehiclesCache[ownerID] then
						table.remove(vehiclesCache[ownerID], vehicleID)

						for k, v in ipairs(getElementsByType("player")) do
							if getElementData(v, "char.ID") == ownerID then
								exports.cosmo_inventory:removeItemByData(v, 2, "data1", vehicleID)
							end
						end
					end

					if isElement(loadedVehicles[vehicleID]) then
						destroyElement(loadedVehicles[vehicleID])
					end

					loadedVehicles[vehicleID] = nil
				end
			end

			dbExec(connection, "DELETE FROM vehicles WHERE vehicleID IN (" .. table.concat(vehicleIds, ",") .. "); DELETE FROM items WHERE ownerId IN (" .. table.concat(vehicleIds, ",") .. ") AND ownerType = 'vehicle'")
		end
	end
end

function deleteVehicle(vehicleID)
	if not vehicleID then
		return
	end

	vehicleID = tonumber(vehicleID)

	if loadedVehicles[vehicleID] then
		local ownerID = getElementData(loadedVehicles[vehicleID], "vehicle.owner")

		if ownerID and vehiclesCache[ownerID] then
			table.remove(vehiclesCache[ownerID], vehicleID)

			for k, v in ipairs(getElementsByType("player")) do
				if getElementData(v, "loggedIn") and getElementData(v, "char.ID") == ownerID then
					exports.cosmo_inventory:removeItemByData(v, 2, "data1", vehicleID)
				end
			end
		end

		if isElement(loadedVehicles[vehicleID]) then
			destroyElement(loadedVehicles[vehicleID])
		end

		loadedVehicles[vehicleID] = nil
	end

	dbExec(connection, "DELETE FROM items WHERE ownerId = ? AND ownerType = 'vehicle'; DELETE FROM vehicles WHERE vehicleID = ?", vehicleID, vehicleID)
end
addEvent("deleteVehicle", true)
addEventHandler("deleteVehicle", root, deleteVehicle)

function unloadPlayerVehicles(charID)
	if not charID then
		return
	end

	charID = tonumber(charID)

	if vehiclesCache[charID] then
		for _, vehicleID in pairs(vehiclesCache[charID]) do
			if loadedVehicles[vehicleID] then
				saveVehicle(loadedVehicles[vehicleID])

				if isElement(loadedVehicles[vehicleID]) then
					destroyElement(loadedVehicles[vehicleID])
				end

				loadedVehicles[vehicleID] = nil
			end
		end
	end
end

addEventHandler("onPlayerQuit", getRootElement(),
	function ()
		local characterId = getElementData(source, "char.ID") or 0

		if characterId > 0 then
			unloadPlayerVehicles(characterId)
		end
	end
)

addEventHandler("onElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if dataName == "loggedIn" then
			if oldValue then
				local characterId = getElementData(source, "char.ID") or 0

				if characterId > 0 then
					unloadPlayerVehicles(characterId)
				end
			end
		end
	end
)

addEvent("updateVehicle", true)
addEventHandler("updateVehicle", getRootElement(),
	function (vehicleElement, dbID, saveToDatabase, fuel, distance, kilometersToChangeOil)
		if isElement(vehicleElement) then
			fuel = tonumber(fuel)
			distance = tonumber(distance)
			kilometersToChangeOil = tonumber(kilometersToChangeOil)


			setElementData(vehicleElement, "vehicle.fuel", fuel)
			setElementData(vehicleElement, "vehicle.distance", distance)
			setElementData(vehicleElement, "lastOilChange", kilometersToChangeOil)

			if saveToDatabase then
				saveVehicle(loadedVehicles[dbID])
			end
		end
	end
)

addEvent("ranOutOfFuel", true)
addEventHandler("ranOutOfFuel", getRootElement(),
	function (vehicleElement)
		if isElement(vehicleElement) then
			setElementData(vehicleElement, "vehicle.fuel", 0)
			setElementData(vehicleElement, "vehicle.engine", false)
			setVehicleEngineState(vehicleElement, false)
		end
	end
)

addEvent("setVehicleHealthSync", true)
addEventHandler("setVehicleHealthSync", getRootElement(),
	function (vehicleElement, health)
		if isElement(vehicleElement) then
			setVehicleDamageProof(source, false) 
			setElementHealth(vehicleElement, health)
		end
	end
)

addEventHandler("onVehicleEnter", getRootElement(),
	function ()
		if getVehicleType(source) ~= "BMX" then
			setVehicleDamageProof(source, false) 
		end

		if getVehicleType(source) == "BMX" or getVehicleType(source) == "Bike" or getVehicleType(source) == "Boat" then
			setElementData(source, "vehicle.windowState", true)
		end
	end
)

addEventHandler("onVehicleStartEnter", getRootElement(), function(player, seat, jacked)
	if isElement(jacked) then
		cancelEvent()
		outputChatBox(exports.cosmo_core:getServerTag("error") .. "Ez nonos kocsilopás, használd a /kiszed parancsot.", player, 0, 0, 0, true)
	end
end)

addEventHandler("onVehicleStartExit", getRootElement(),
	function (player)
		if getElementData(player, "player.seatBelt") then
			cancelEvent()
			exports.cosmo_hud:showInfobox(player, "error", "Előbb csatold ki a biztonsági öved!")
		elseif getVehicleType(source) ~= "Bike" and getVehicleType(source) ~= "BMX" and getVehicleType(source) ~= "Boat" then
			if getElementData(source, "vehicle.locked") then
				cancelEvent()
				exports.cosmo_hud:showInfobox(player, "error", "Nem szállhatsz ki amíg az ajtók zárva vannak!")
			elseif getElementData(player, "player.Cuffed") then
				cancelEvent()
				exports.cosmo_hud:showInfobox(player, "error", "Nem szállhatsz ki amíg bilincs van a kezeden!")
			end
		end
	end
)

addEventHandler("onVehicleExplode", getRootElement(),
	function ()
		table.insert(explodedVehicles, source)
	end
)

function processExplodedVehicles()
	if #explodedVehicles > 0 then
		for i = 1, #explodedVehicles do
			local vehicle = explodedVehicles[i]

			if isElement(vehicle) then
				fixVehicle(vehicle)
				respawnVehicle(vehicle)
				setVehicleDamageProof(vehicle, false)
				setElementData(vehicle, "vehicle.engine", false)

				local parkedPosition = getElementData(vehicle, "vehicle.parkedPosition") or {}
				if #parkedPosition > 0 then
					setElementInterior(vehicle, parkedPosition[7] or 0)
					setElementDimension(vehicle, parkedPosition[8] or 0)
				end
			end
		end

		explodedVehicles = {}
	end
end

addEventHandler("onVehicleDamage", getRootElement(),
	function (loss)
		local health = getElementHealth(source)

		if health < 320 or (health - loss) < 320 then
			setElementHealth(source, 320)
			setVehicleDamageProof(source, true) 
			setElementData(source, "vehicle.engine", false)
			setVehicleEngineState(source, false)

			local theDriver = getVehicleController(source)
			if isElement(theDriver) then
				exports.cosmo_hud:showInfobox(theDriver, "error", "Lerobbant a járműved!")
			end
		else
			setVehicleDamageProof(source, false) 
		end
	end
)

addEvent("toggleVehicleLock", true)
addEventHandler("toggleVehicleLock", getRootElement(),
	function (vehicle, players, task)
		if isElement(source) then
			if isElement(vehicle) then
				local vehicleID = tonumber(getElementData(vehicle, "vehicle.dbID")) or -65535

				if not (exports.cosmo_inventory:hasItemWithData(source, 2, "data1", vehicleID) or getElementData(source, "adminDuty") or getElementData(source, "acc.adminLevel") >= 7) then
					exports.cosmo_hud:showInfobox(source, "error", "Nincs kulcsod ehhez a járműhöz!")
					return
				end

				if getElementData(vehicle, "vehicle.locked") then
					setElementData(vehicle, "vehicle.locked", false)
					setVehicleLocked(vehicle, false)

					if getVehicleOccupant(vehicle) == source and not task[1] then
						exports.cosmo_chat:sendLocalMeAction(source, "kinyit belülről egy " .. exports.cosmo_mods_veh:getVehicleName(vehicle) .. " típusú járművet.")
						triggerClientEvent(getVehicleOccupants(vehicle), "playVehicleSound", vehicle, "simple", ":cosmo_assets/audio/vehicles/lockin.ogg")
						
						local visibleName = getElementData(source, "visibleName"):gsub("_", " ")
						local text = visibleName.." kinyitotta a kocsit"
						
						--dbExec(connection, "INSERT INTO VehicleLog (dbID, action, time) VALUES(?, ?, NOW())", vehicleID, text)
						
						return
					end
					
					local visibleName = getElementData(source, "visibleName"):gsub("_", " ")
					local text = visibleName.." kinyitotta a kocsit"
					
					--dbExec(connection, "INSERT INTO VehicleLog (dbID, action, time) VALUES(?, ?, NOW())", vehicleID, text)

	
					triggerClientEvent(players, "onVehicleLockEffect", vehicle)
					exports.cosmo_chat:sendLocalMeAction(source, "kinyit egy " .. exports.cosmo_mods_veh:getVehicleName(vehicle) .. " típusú járművet.")
				else
					setElementData(vehicle, "vehicle.locked", true)
					setVehicleLocked(vehicle, true)

					if getVehicleOccupant(vehicle) == source and not task[1] then
						exports.cosmo_chat:sendLocalMeAction(source, "bezár belülről egy " .. exports.cosmo_mods_veh:getVehicleName(vehicle) .. " típusú járművet.")
						triggerClientEvent(getVehicleOccupants(vehicle), "playVehicleSound", vehicle, "simple", ":cosmo_assets/audio/vehicles/lockin.ogg")
	
						local visibleName = getElementData(source, "visibleName"):gsub("_", " ")
						local text = visibleName.." bezárta a kocsit"
						
						--dbExec(connection, "INSERT INTO VehicleLog (dbID, action, time) VALUES(?, ?, NOW())", vehicleID, text)
						
						return
					end
					
					local visibleName = getElementData(source, "visibleName"):gsub("_", " ")
					local text = visibleName.." bezárta a kocsit"
					
					--dbExec(connection, "INSERT INTO VehicleLog (dbID, action, time) VALUES(?, ?, NOW())", vehicleID, text)
					
					triggerClientEvent(players, "onVehicleLockEffect", vehicle)
					exports.cosmo_chat:sendLocalMeAction(source, "bezár egy " .. exports.cosmo_mods_veh:getVehicleName(vehicle) .. " típusú járművet.")
				end

				triggerClientEvent(players, "playVehicleSound", vehicle, "3d", ":cosmo_assets/audio/vehicles/lockout.ogg")
			end
		end
	end
)

--addEvent("syncVehicleSound", true)
--addEventHandler("syncVehicleSound", getRootElement(),
--	function (typ, path, players)
--		if isElement(source) then
--			if typ and path then
--				triggerClientEvent(players, "playVehicleSound", source, typ, path)
--			end
--		end
--	end
--)

addEvent("toggleVehicleEngine", true)
addEventHandler("toggleVehicleEngine", getRootElement(),
	function (vehicle, toggle)
		if isElement(source) then
			if isElement(vehicle) then
				local vehicleID = tonumber(getElementData(vehicle, "vehicle.dbID")) or -65535

				if not (exports.cosmo_inventory:hasItemWithData(source, 2, "data1", vehicleID) or not getElementData(vehicle, "vehicle.job") ~= 0 or getElementData(source, "adminDuty")) then
					exports.cosmo_hud:showInfobox(source, "error", "Nincs kulcsod ehhez a járműhöz!")
					return
				end

				local cosmo_mods_veh = getResourceFromName("cosmo_mods_veh")
				local vehicleNames = cosmo_mods_veh and getResourceState(cosmo_mods_veh) == "running"

				if toggle then
					if getElementHealth(vehicle) <= 320 then
						exports.cosmo_hud:showInfobox(source, "error", "A jármű motorja túlságosan sérült.")
						exports.cosmo_chat:sendLocalMeAction(source, "megpróbálja beindítani a jármű motorját, de nem sikerül neki.")
						return
					elseif getElementData(vehicle, "vehicle.fuel") <= 0 then
						exports.cosmo_hud:showInfobox(source, "error", "A járműből kifogyott az üzemanyag.")
						exports.cosmo_chat:sendLocalMeAction(source, "megpróbálja beindítani a jármű motorját, de nem sikerül neki.")
						return
					elseif getElementData(vehicle, "vehicle.impound") then
						exports.cosmo_hud:showInfobox(source, "error", "Ez a jármű le van foglalva, ezért nem tudod beindítani!")
						return
					end

					if vehicleNames then
						exports.cosmo_chat:sendLocalMeAction(source, "beindítja egy " .. exports.cosmo_mods_veh:getVehicleName(vehicle) .. " típusú jármű motorját.")
					else
						exports.cosmo_chat:sendLocalMeAction(source, "beindítja egy jármű motorját.")
					end

					setVehicleEngineState(vehicle, toggle)
					setElementData(vehicle, "vehicle.engine", toggle)
				else
					if vehicleNames then
						exports.cosmo_chat:sendLocalMeAction(source, "leállítja egy " .. exports.cosmo_mods_veh:getVehicleName(vehicle) .. " típusú jármű motorját.")
					else
						exports.cosmo_chat:sendLocalMeAction(source, "leállítja egy jármű motorját.")
					end

					setVehicleEngineState(vehicle, toggle)
					setElementData(vehicle, "vehicle.engine", toggle)
				end
			end
		end
	end
)

addEvent("toggleVehicleLights", true)
addEventHandler("toggleVehicleLights", getRootElement(),
	function (vehicle)
		if getElementData(vehicle, "vehicle.light") then
			setVehicleOverrideLights(vehicle, 1)
			setElementData(vehicle, "vehicle.light", false)
			exports.cosmo_chat:sendLocalMeAction(source, "lekapcsolja a jármű lámpáit.")
		else
			setVehicleOverrideLights(vehicle, 2)
			setElementData(vehicle, "vehicle.light", true)
			exports.cosmo_chat:sendLocalMeAction(source, "felkapcsolja a jármű lámpáit.")
		end

		triggerClientEvent(getVehicleOccupants(vehicle), "playVehicleSound", vehicle, "simple", ":cosmo_assets/audio/vehicles/lightswitch.ogg")
	end
)

addEvent("playVehicleSound", true)
addEventHandler("playVehicleSound", getRootElement(),
	function (sendTo, sourceElement, ...)
		sendTo = sendTo or getRootElement()

		triggerClientEvent(sendTo, "playVehicleSound", sourceElement, ...)
	end
)

addCommandHandler("park",
	function (player)
		local vehicle = getPedOccupiedVehicle(player)

		if not isElement(vehicle) then
			exports.cosmo_hud:showInfobox(player, "error", "Nem ülsz járműben!")
			return
		end

		local vehicleID = tonumber(getElementData(vehicle, "vehicle.dbID")) or -65535

		if not (exports.cosmo_inventory:hasItemWithData(player, 2, "data1", vehicleID) or getElementData(player, "adminDuty")) then
			exports.cosmo_hud:showInfobox(player, "error", "Nincs kulcsod ehhez a járműhöz!")
			return
		end

		local x, y, z = getElementPosition(vehicle)
		local rx, ry, rz = getElementRotation(vehicle)
		local interior = getElementInterior(vehicle)
		local dimension = getElementDimension(vehicle)
		local currentPosition = {x, y, z, rx, ry, rz, interior, dimension}

		if dbExec(connection, "UPDATE vehicles SET parkedPosition = ? WHERE vehicleID = ? ", toJSON(currentPosition), vehicleID) then
			setVehicleRespawnPosition(vehicle, x, y, z, rx, ry, rz)
			setElementData(vehicle, "vehicle.parkedPosition", currentPosition)
			exports.cosmo_hud:showInfobox(player, "success", "Járműved sikeresen leparkolva.")
		end
	end
)

addEvent("onVehicleHandbrakeStateChange", true)
addEventHandler("onVehicleHandbrakeStateChange", getRootElement(),
	function (state, normalBrakeMode)
		if isElement(source) then
			if state then
				if not normalBrakeMode then
					setElementFrozen(source, true)
				end

				setElementData(source, "vehicle.handBrake", true)
			else
				setElementFrozen(source, false)
				setElementData(source, "vehicle.handBrake", false)
			end
		end
	end
)

function getPlayerVehiclesCount(charID)
	if not charID then
		return 0
	end

	charID = tonumber(charID)
	local count = 0

	if vehiclesCache[charID] then
		for _, vehicleID in pairs(vehiclesCache[charID]) do
			if loadedVehicles[vehicleID] then
				count = count + 1
			end
		end
	end

	return count
end

local junkyard = createMarker(2183.5051269531, -1991.3364257813, 13.546875-1, "cylinder", 4, 255, 148, 40, 100)

addEventHandler ("onMarkerHit", junkyard,
	function(element)
		if isElement(element) then
			if getElementType(element) == "vehicle" then
				if getVehicleController(element) then
					local controller = getVehicleController(element)

					if tonumber(getElementData(element, "vehicle.owner")) == tonumber(getElementData(controller, "char.ID")) then
						triggerClientEvent(controller, "junkyardClientSide", controller, getElementData(element, "vehicle.dbID"))
					end
				end
			end
		end
	end
)


function startingMove(button, press)
    if (press) and button == "o" then
		local theVeh = getPedOccupiedVehicle(localPlayer)
        if getPedOccupiedVehicle(localPlayer) then
			if getVehicleOccupant(theVeh) == localPlayer then
				if getElementData(theVeh, "spoilerState") == "downed" then
					setElementData(theVeh, "spoilerState", "upped")
				elseif getElementData(theVeh, "spoilerState") == "upped" then
					setElementData(theVeh, "spoilerState", "downed")
				end
			end
        end
    end
end
addEventHandler("onClientKey", root, startingMove)