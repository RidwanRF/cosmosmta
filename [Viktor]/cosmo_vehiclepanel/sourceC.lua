local theOldCar = false

pcall(loadstring(base64Decode(exports.cosmo_core:getInterfaceElements())));addEventHandler("onCoreStarted",root,function(functions) for k,v in ipairs(functions) do _G[v]=nil;end;collectgarbage();pcall(loadstring(base64Decode(exports.cosmo_core:getInterfaceElements())));end)

local screenX, screenY = guiGetScreenSize()

local responsiveMultipler = 1

local responsiveMultipler = exports.cosmo_hud:getResponsiveMultipler()

function respc(x)
	return math.ceil(x * responsiveMultipler)
end

local renderData = {}

local engineStartTimer = false
local preEngineStart = false
local lastEngineStart = 0

local straterEffect = {}

--
--function hasItemWithData(sourceElement, itemId, dataType, data)

bindKey("j", "both",
	function (key, state)
		local pedveh = getPedOccupiedVehicle(localPlayer)
		if pedveh then
			if getVehicleOccupant(pedveh) == localPlayer then
				if getVehicleType(pedveh) ~= "BMX" then
					local id = getElementData(pedveh, "vehicle.dbID")
					--if exports.cosmo_inventory:hasItemWithData(localPlayer, 2, "data1", id) then
						if getTickCount() - lastEngineStart >= 1500 then
							local playerVehicle = getPedOccupiedVehicle(localPlayer)
							local id = getElementData(playerVehicle, "vehicle.dbID")

							if not (getElementData(playerVehicle, "vehicle.ownerJob") == localPlayer) and not (exports.cosmo_inventory:hasItemWithData(2, "data1", id)  or getElementData(localPlayer, "adminDuty") or getElementData(localPlayer, "acc.adminLevel") >= 7 or getElementData(playerVehicle, "vehicle.test") and getElementData(playerVehicle, "vehicle.testOwner") == localPlayer) then
								exports.cosmo_hud:showAlert("error", "Nincs kulcsod ehhez a járműhöz!")
								return
							end

							if state == "down" then
								playSound("files/key.mp3")
								if not getVehicleEngineState(pedveh) then
									startEngine(pedveh, state)
									playerStartSound = playSound("files/starter.mp3")
								else
									triggerServerEvent("toggleEngine", localPlayer, pedveh, false)
								end
							elseif state == "up" then
								startEngine(pedveh, state)

								if isElement(playerStartSound) then
									destroyElement(playerStartSound)
								end

								playerStartSound = nil
							end
						end
					--end

				end
			end
		end
	end
)

local dxPositionX = 0

local randomPositinonX = 2

local renderDataStart = {
	pos = {
		x = screenX - respc(260),
		y = screenY / 2 - respc(20),
	},

	size = {
		x = respc(250),
		y = respc(40),
	}

}

function startEngine(pedveh, state)
	if state == "down" then
		dxPositionX = 0
		randomPositinonX = 2

		downCurrentStartTick = getTickCount()
		randomPositinonX = math.random(2, respc(250) - respc(80) - 2)

		addEventHandler("onClientRender", getRootElement(), renderStarter)
	elseif state == "up" then
		upCurrentStartTick = getTickCount()
		removeEventHandler("onClientRender", getRootElement(), renderStarter)
		
		if dxPositionX > (randomPositinonX + renderDataStart.pos.x) and dxPositionX < (randomPositinonX + renderDataStart.pos.x + respc(80)) then
			dxPositionX = 0
			randomPositinonX = 2
			triggerServerEvent("syncVehicleSound", pedveh, "files/started.mp3", getElementsByType("player", root, true))
			triggerServerEvent("toggleEngine", localPlayer, pedveh, true)
		end
	end
end

function renderStarter()
	local now = getTickCount()
    local endTime = downCurrentStartTick + 2000
    local elapsedTime = now - downCurrentStartTick
    local duration = endTime - downCurrentStartTick
    local progress = elapsedTime / duration

	local starterLinePosX = interpolateBetween(renderDataStart.pos.x + 2, 0, 0, renderDataStart.pos.x + renderDataStart.size.x - 4, 0, 0, progress, "Linear")

	dxDrawRectangle(renderDataStart.pos.x, renderDataStart.pos.y, renderDataStart.size.x, renderDataStart.size.y, tocolor(0, 0, 0, 170))

	dxDrawRectangle(renderDataStart.pos.x + randomPositinonX, renderDataStart.pos.y + 2, respc(80), renderDataStart.size.y - 4, tocolor(255, 148, 40, 200))
	dxDrawText("Inditás", renderDataStart.pos.x + randomPositinonX + respc(80) / 2, renderDataStart.pos.y + 2 + (renderDataStart.size.y - 4) / 2, nil, nil, tocolor(200, 200, 200, 200), 1, Raleway, "center", "center")

	dxPositionX = starterLinePosX

	dxDrawRectangle(starterLinePosX, renderDataStart.pos.y + 2, 2, renderDataStart.size.y - 4, tocolor(255, 255, 255))
end

addEvent("syncVehicleSound", true)
addEventHandler("syncVehicleSound", getRootElement(),
	function (typ, path)
		if isElement(source) then
			if typ == "3d" then
				local x, y, z = getElementPosition(source)
				straterEffect[source] = playSound3D(path, x, y, z)

				if isElement(straterEffect[source]) then
					setElementInterior(straterEffect[source], getElementInterior(source))
					setElementDimension(straterEffect[source], getElementDimension(source))
					attachElements(straterEffect[source], source)
				end
			else
				--straterEffect[source] = playSound(path)
			end
		end
	end)


addEvent("onVehicleLockEffect", true)
addEventHandler("onVehicleLockEffect", getRootElement(),
	function ()
		if isElement(source) then
			processLockEffect(source)
		end
	end)

function processLockEffect(vehicle)
	if isElement(vehicle) then
		if getVehicleOverrideLights(vehicle) == 0 or getVehicleOverrideLights(vehicle) == 1 then
			setVehicleOverrideLights(vehicle, 2)
		else
			setVehicleOverrideLights(vehicle, 1)
		end
		
		setTimer(
			function()
				if getVehicleOverrideLights(vehicle) == 0 or getVehicleOverrideLights(vehicle) == 1 then
					setVehicleOverrideLights(vehicle, 2)
				else
					setVehicleOverrideLights(vehicle, 1)
				end
			end,
		548.57142857143 / 3, 3)
	end
end

local lastLockTick = 0

local lastLightTick = 0

addEventHandler("onClientPlayerVehicleEnter", getRootElement(),
	function (vehicle, seat)
		setVehicleDoorOpenRatio(vehicle, 2, 0, 0)
		setVehicleDoorOpenRatio(vehicle, 3, 0, 0)
		setVehicleDoorOpenRatio(vehicle, 4, 0, 0)
		setVehicleDoorOpenRatio(vehicle, 5, 0, 0)

		if getVehicleOverrideLights(vehicle) == 0 then
			setVehicleOverrideLights(vehicle, 1)
			setElementData(vehicle, "vehicle.lights", 0)
		end

		if source == localPlayer then
			if isElement(vehicle) then
				local vehicleType = getVehicleType(vehicle)

				theOldCar = getElementData(vehicle, "vehicle.dbID")

				if vehicleType == "BMX" then
					setVehicleEngineState(vehicle, true)
				end

				if (getElementData(vehicle, "vehicle.engine") or 0) ~= 1 then
					if seat == 0 and vehicleType ~= "BMX" then
						outputChatBox("#ff9428[CosmoMTA]: #ffffffBeinditáshoz tartsd lenyomva a #ff9428'J'#ffffff betűt.",255,255,255,true)
					end
				end
			end
		end
	end)

local screenX, screenY = guiGetScreenSize()

local brakePanelState = false

local brakePanelWidth = 10
local brakePanelHeight = 250

local brakePanelPosX = screenX - brakePanelWidth - 12
local brakePanelPosY = screenY / 2 - brakePanelHeight / 2

local brakeProgress = 1
local brakeLastProgress = false

-- addEventHandler("onClientCursorMove", getRootElement(),
-- 	function (relX, relY, absX, absY)
-- 		if brakePanelState then
-- 			if not isMTAWindowActive() and getKeyState("lalt") then
-- 				local pedveh = getPedOccupiedVehicle(localPlayer)
-- 				local state = getElementData(pedveh, "vehicle.handBrake")
				
-- 				brakeProgress = brakeProgress - (0.5 - relY) * 5

-- 				if brakeProgress < 0 then
-- 					brakeProgress = 0
-- 				elseif brakeProgress > 2 then
-- 					brakeProgress = 2
-- 				end

-- 				if brakeProgress < 0.5 then
-- 					if state then
-- 						if getVehicleType(pedveh) == "Automobile" then
-- 							setPedControlState(localPlayer, "handbrake", false)
-- 							triggerServerEvent("toggleHandBrake", pedveh, false, true)
-- 						else
-- 							triggerServerEvent("toggleHandBrake", pedveh, false)
-- 						end
-- 					end
-- 				elseif brakeProgress > 1.5 then
-- 					if not state then
-- 						if getVehicleType(pedveh) == "Automobile" then
-- 							setPedControlState(localPlayer, "handbrake", true)
-- 							triggerServerEvent("toggleHandBrake", pedveh, true, true)
-- 						else
-- 							triggerServerEvent("toggleHandBrake", pedveh, true)
-- 						end
-- 					end
-- 				end

-- 				setCursorPosition(screenX / 2, screenY / 2)
-- 			end
-- 		end
-- 	end)

-- addEventHandler("onClientElementDataChange", getRootElement(),
-- 	function (dataName)
-- 		if dataName == "vehicle.handBrake" then
-- 			local pedveh = getPedOccupiedVehicle(localPlayer)

-- 			if pedveh == source then
-- 				if getElementData(source, "vehicle.handBrake") then
-- 					playSound("files/handbrakeon.mp3")
-- 				else
-- 					playSound("files/handbrakeoff.mp3")
-- 				end
-- 			end
-- 		end
-- 	end)

local lastGear = 0
local gearIFP = engineLoadIFP("files/gear.ifp", "gear_shift")
local gearVals = {}
local nextKerregesTime = 0

function remFromTable()
	gearVals[source] = nil
end
addEventHandler("onClientElementStreamIn", getRootElement(), remFromTable)
addEventHandler("onClientElementStreamOut", getRootElement(), remFromTable)
addEventHandler("onClientElementDestroy", getRootElement(), remFromTable)

addEventHandler("onClientRender", getRootElement(),
	function ()
		local pedveh = getPedOccupiedVehicle(localPlayer)

		if pedveh and getPedOccupiedVehicleSeat(localPlayer) == 0 then
			local vehtype = getVehicleType(pedveh)
			local pedtask = getPedSimplestTask(localPlayer)

			if vehtype == "Automobile" then

				local currGear = getVehicleCurrentGear(pedveh)
				local x, y, z = getElementPosition(pedveh)
				local health = getElementHealth(pedveh)
				
				if health <= 600 then
					if getTickCount() > nextKerregesTime then
						local vx, vy, vz = getElementVelocity(pedveh)
						local actualspeed = math.sqrt(vx * vx + vy * vy + vz * vz) * 180

						if actualspeed >= 15 then
							nextKerregesTime = getTickCount() + math.random(40000, 60000)
							triggerServerEvent("playTurboSound", localPlayer, pedveh, -math.random(2, 3), getElementsWithinRange(x, y, z, 100, "player"))
						end
					end
				end

				if currGear > lastGear then
					lastGear = currGear

					if health <= 600 then
						if math.random(10) <= 7 then
							triggerServerEvent("playTurboSound", localPlayer, pedveh, -1, getElementsWithinRange(x, y, z, 100, "player"))
						end
					end
				elseif currGear < lastGear then
					lastGear = currGear

					if health <= 600 then
						if math.random(10) <= 7 then
							triggerServerEvent("playTurboSound", localPlayer, pedveh, -1, getElementsWithinRange(x, y, z, 100, "player"))
						end
					end
				end
			end
		end

		local x, y, z = getElementPosition(localPlayer)
		local vehicles = getElementsWithinRange(x, y, z, 100, "vehicle")

		for i = 1, #vehicles do
			local veh = vehicles[i]

			if isElement(veh) then
				if getVehicleType(veh) == "Automobile" then
					local currGear = getVehicleCurrentGear(veh)

					if currGear and gearVals[veh] ~= currGear then
						gearVals[veh] = currGear

						local driver = getVehicleController(veh)

						if isElement(driver) then
							local currAnim = getPedAnimation(driver)

							if not currAnim then
								setPedAnimation(driver, "gear_shift", "CAR_tune_radio", -1, false, false, true, false)
							end
						end
					end
				end
			end
		end
	end)

addEvent("playTurboSound", true)
addEventHandler("playTurboSound", getRootElement(),
	function (turboLevel)
		if isElement(source) then
			local x, y, z = getElementPosition(source)
			local soundEffect = false

			if turboLevel == -1 then
				soundEffect = playSound3D("files/kerreges.mp3", x, y, z)
			elseif turboLevel == -2 then
				soundEffect = playSound3D("files/ekszij1.mp3", x, y, z)
			elseif turboLevel == -3 then
				soundEffect = playSound3D("files/ekszij2.mp3", x, y, z)
			end

			if isElement(soundEffect) then
				if turboLevel == 4 then
					setSoundVolume(soundEffect, 0.3)
				end

				setElementDimension(soundEffect, getElementDimension(source))
				setElementInterior(soundEffect, getElementInterior(source))
				attachElements(soundEffect, source)
			end
		end
	end)

function getPlayerToVehicleRelatedPosition()
	local lookAtVehicle = getPedTarget(localPlayer)

	if lookAtVehicle and getElementType(lookAtVehicle) == "vehicle" then   
		local vehPosX, vehPosY, vehPosZ = getElementPosition(lookAtVehicle)
		local vehRotX, vehRotY, vehRotZ = getElementRotation(lookAtVehicle)
		local pedPosX, pedPosY, pedPosZ = getElementPosition(localPlayer)
		local angle = math.deg(math.atan2(pedPosX - vehPosX, pedPosY - vehPosY)) + 180 + vehRotZ
		
		if angle < 0 then
			angle = angle + 360
		elseif angle > 360 then
			angle = angle - 360
		end
		
		return math.floor(angle) + 0.5
	else
		return false
	end
end

function getDoor(vehicle)
	if vehicle then
		-- 0 (hood), 1 (trunk), 2 (front left), 3 (front right)
		if getPlayerToVehicleRelatedPosition() >= 140 and getPlayerToVehicleRelatedPosition() <= 220 then
			return 0
		end
			
		if getPlayerToVehicleRelatedPosition() >= 330 and getPlayerToVehicleRelatedPosition() <= 360 or getPlayerToVehicleRelatedPosition() >= 0 and getPlayerToVehicleRelatedPosition() <= 30 then
			return 1
		end
			
		if getPlayerToVehicleRelatedPosition() >= 65 and getPlayerToVehicleRelatedPosition() <= 120 then
			return 2
		end
			
		if getPlayerToVehicleRelatedPosition() >= 240 and getPlayerToVehicleRelatedPosition() <= 295 then
			return 3
		end
	elseif vehicle then
		-- 0 (hood), 2 (front left), 3 (front right)
		if getPlayerToVehicleRelatedPosition() >= 140 and getPlayerToVehicleRelatedPosition() <= 220 then
			return 0
		end
			
		if getPlayerToVehicleRelatedPosition() >= 65 and getPlayerToVehicleRelatedPosition() <= 120 then
			return 2
		end
			
		if getPlayerToVehicleRelatedPosition() >= 240 and getPlayerToVehicleRelatedPosition() <= 295 then
			return 3
		end
	elseif vehicle then
		-- 0 (hood), 1 (trunk), 2 (front left), 3 (front right), 4 (rear left), 5 (rear right)
		if getPlayerToVehicleRelatedPosition() >= 140 and getPlayerToVehicleRelatedPosition() <= 220 then
			return 0
		end
			
		if getPlayerToVehicleRelatedPosition() >= 330 and getPlayerToVehicleRelatedPosition() <= 360 or getPlayerToVehicleRelatedPosition() >= 0 and getPlayerToVehicleRelatedPosition() <= 30 then
			return 1
		end
			
		if getPlayerToVehicleRelatedPosition() >= 91 and getPlayerToVehicleRelatedPosition() <= 120 then
			return 2
		end
			
		if getPlayerToVehicleRelatedPosition() >= 240 and getPlayerToVehicleRelatedPosition() <= 270 then
			return 3
		end
			
		if getPlayerToVehicleRelatedPosition() >= 60 and getPlayerToVehicleRelatedPosition() <= 90 then
			return 4
		end
			
		if getPlayerToVehicleRelatedPosition() >= 271 and getPlayerToVehicleRelatedPosition() <= 300 then
			return 5
		end
	elseif vehicle then
		-- 0 (hood), 2 (front left), 3 (front right), 4 (rear left at back), 5 (rear right at back)
		if getPlayerToVehicleRelatedPosition() >= 140 and getPlayerToVehicleRelatedPosition() <= 220 then
			return 0
		end
			
		if getPlayerToVehicleRelatedPosition() >= 91 and getPlayerToVehicleRelatedPosition() <= 130 then
			return 2
		end
			
		if getPlayerToVehicleRelatedPosition() >= 230 and getPlayerToVehicleRelatedPosition() <= 270 then
			return 3
		end
			
		if getPlayerToVehicleRelatedPosition() >= 0 and getPlayerToVehicleRelatedPosition() <= 30 then
			return 4
		end
			
		if getPlayerToVehicleRelatedPosition() >= 330 and getPlayerToVehicleRelatedPosition() <= 360 then
			return 5
		end
	elseif vehicle then
		-- 0 (hood), 2 (front left), 3 (front right)
		if getPlayerToVehicleRelatedPosition() >= 160 and getPlayerToVehicleRelatedPosition() <= 200 then
			return 0
		end
			
		if getPlayerToVehicleRelatedPosition() >= 120 and getPlayerToVehicleRelatedPosition() <= 155 then
			return 2
		end
			
		if getPlayerToVehicleRelatedPosition() >= 205 and getPlayerToVehicleRelatedPosition() <= 230 then
			return 3
		end
	elseif vehicle then
		-- 2 (front left), 3 (front right)       
		if getPlayerToVehicleRelatedPosition() >= 120 and getPlayerToVehicleRelatedPosition() <= 155 then
			return 2
		end
			
		if getPlayerToVehicleRelatedPosition() >= 205 and getPlayerToVehicleRelatedPosition() <= 230 then
			return 3
		end
	elseif vehicle then
		-- 0 (hood), 1 (trunk), 2 (front left), 3 (front right), 4 (rear left), 5 (rear right)
		if getPlayerToVehicleRelatedPosition() >= 140 and getPlayerToVehicleRelatedPosition() <= 220 then
			return 0
		end
			
		if getPlayerToVehicleRelatedPosition() >= 330 and getPlayerToVehicleRelatedPosition() <= 360 or getPlayerToVehicleRelatedPosition() >= 0 and getPlayerToVehicleRelatedPosition() <= 30 then
			return 1
		end
			
		if getPlayerToVehicleRelatedPosition() >= 91 and getPlayerToVehicleRelatedPosition() <= 120 then
			return 2
		end
			
		if getPlayerToVehicleRelatedPosition() >= 240 and getPlayerToVehicleRelatedPosition() <= 270 then
			return 3
		end
			
		if getPlayerToVehicleRelatedPosition() >= 60 and getPlayerToVehicleRelatedPosition() <= 90 then
			return 4
		end
			
		if getPlayerToVehicleRelatedPosition() >= 271 and getPlayerToVehicleRelatedPosition() <= 300 then
			return 5
		end
	end

	return nil
end

bindKey("mouse2", "down",
	function ()
		if getPedWeapon(localPlayer) == 0 then
			if not isCursorShowing() then
				if not getPedOccupiedVehicle(localPlayer) then
					local lookAtVehicle = getPedTarget(localPlayer)

					if isElement(lookAtVehicle) then
						if getElementType(lookAtVehicle) == "vehicle" then
							local playerX, playerY, playerZ = getElementPosition(localPlayer)
							local targetX, targetY, targetZ = getElementPosition(lookAtVehicle)

							if getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ) <= 5 then
								if (getElementData(lookAtVehicle, "vehicle.locked") or 0) == 0 then
									local door = getDoor(lookAtVehicle)

									if door then
										local doorname = ""

										if door == 0 then
											doorname = "motorháztető"
										elseif door == 1 then
											doorname = "csomagtartó"
										elseif door == 2 then
											doorname = "bal első ajtó"
										elseif door == 3 then
											doorname = "jobb első ajtó"
										elseif door == 4 then
											doorname = "bal hátsó ajtó"
										elseif door == 5 then
											doorname = "jobb hátsó ajtó"
										end

										triggerServerEvent("doVehicleDoorInteract", localPlayer, lookAtVehicle, door, doorname)
									end
								else
									outputChatBox("#ff9428[CosmoMTA]: #ffffffA jármű zárva van, ezért nem tudod nyitogatni az ajtajait!",255,255,255,true)
								end
							end
						end
					end
				end
			end
		end
	end)

addEvent("playDoorEffect", true)
addEventHandler("playDoorEffect", getRootElement(),
	function (vehicle, typ)
		if isElement(vehicle) and typ then
			local soundPath = false

			if typ == "open" then
				soundPath = exports.cosmo_vehiclepanel:getDoorOpenSound(getElementModel(vehicle))
			elseif typ == "close" then
				soundPath = exports.cosmo_vehiclepanel:getDoorCloseSound(getElementModel(vehicle))
			end

			if soundPath then
				local x, y, z = getElementPosition(vehicle)
				local int = getElementInterior(vehicle)
				local dim = getElementDimension(vehicle)
				local sound = playSound3D(soundPath, x, y, z)

				if isElement(sound) then
					setElementInterior(sound, int)
					setElementDimension(sound, dim)
					attachElements(sound, vehicle)
				end
			end
		end
	end
)

local enabledButtons = 0

function loadFonts()
	Raleway = exports.cosmo_assets:loadFont("Roboto-Regular.ttf", respc(12), false, "antialiased")
end

loadFonts()

addEventHandler("onAssetsLoaded", getRootElement(),
	function ()
		loadFonts()
	end
)


local bootlessModel = {
	[409] = true,
	[416] = true,
	[433] = true,
	[427] = true,
	[490] = true,
	[528] = true,
	[407] = true,
	[544] = true,
	[523] = true,
	[470] = true,
	[596] = true,
	[598] = true,
	[599] = true,
	[597] = true,
	[432] = true,
	[601] = true,
	[428] = true,
	[431] = true,
	[420] = true,
	[525] = true,
	[408] = true,
	[552] = true,
	[499] = true,
	[609] = true,
	[498] = true,
	[524] = true,
	[532] = true,
	[578] = true,
	[486] = true,
	[406] = true,
	[573] = true,
	[455] = true,
	[588] = true,
	[403] = true,
	[423] = true,
	[414] = true,
	[443] = true,
	[515] = true,
	[514] = true,
	[531] = true,
	[456] = true,
	[459] = true,
	[422] = true,
	[482] = true,
	[605] = true,
	[530] = true,
	[418] = true,
	[572] = true,
	[582] = true,
	[413] = true,
	[440] = true,
	[543] = true,
	[583] = true,
	[478] = true,
	[554] = true
}

function bootCheck(veh)
	local cx, cy, cz = getVehicleComponentPosition(veh, "boot_dummy", "world")

	if not cx or not cy or getVehicleType(veh) ~= "Automobile" or bootlessModel[getElementModel(veh)] then
		return true
	end

	local px, py, pz = getElementPosition(localPlayer)
	local vx, vy, vz = getElementPosition(veh)
	local vrx, vry, vrz = getElementRotation(veh)
	local angle = math.rad(270 + vrz)

	cx = cx + math.cos(angle) * 1.5
	cy = cy + math.sin(angle) * 1.5

	if getDistanceBetweenPoints3D(px, py, pz, cx, cy, cz) < 1 then
		return true
	end

	return false
end