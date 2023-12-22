local screenX, screenY = guiGetScreenSize()

local RobotoFont = false

local seatBeltState = false
local lastSeatBeltStateChange = 0

local nonSeatBeltVehicles = {
	[472] = true,
	[473] = true,
	[493] = true,
	[595] = true,
	[484] = true,
	[430] = true,
	[453] = true,
	[452] = true,
	[446] = true,
	[454] = true,

	[581] = true,
	[509] = true,
	[481] = true,
	[462] = true,
	[521] = true,
	[463] = true,
	[510] = true,
	[522] = true,
	[461] = true,
	[448] = true,
	[468] = true,
	[586] = true,

	[432] = true,
	[531] = true,
	[583] = true,
}

function seatbeltFunction()
	local vehicle = getPedOccupiedVehicle(localPlayer)

	if isElement(vehicle) and (getVehicleType(vehicle) or "N/A") == "Automobile" then
		local model = getElementModel(vehicle)

		if not nonSeatBeltVehicles[model] then
			if getTickCount() - lastSeatBeltStateChange >= 1000 then
				local seatBelt = getElementData(localPlayer, "player.seatBelt")

				setElementData(localPlayer, "player.seatBelt", not seatBelt)

				if seatBelt then
					exports.cosmo_chat:sendLocalMeAction(localPlayer, "kicsatolja a biztonsági övét.")
					playSound(":cosmo_assets/audio/vehicles/ovki.ogg", false)
				else
					exports.cosmo_chat:sendLocalMeAction(localPlayer, "becsatolja a biztonsági övét.")
					playSound(":cosmo_assets/audio/vehicles/ovbe.ogg", false)
				end

				lastSeatBeltStateChange = getTickCount()
			else
				exports.cosmo_hud:showInfobox("error", "Csak 1 másodpercenként csatolhatod ki/be az öved.")
			end
		end
	end
end
addCommandHandler("ov", seatbeltFunction)
addCommandHandler("öv", seatbeltFunction)
addCommandHandler("seatbelt", seatbeltFunction)
bindKey("F5", "down", "öv")

addCommandHandler("oldcar",
	function ()
		outputChatBox(exports.cosmo_core:getServerTag("info") .. "Előző járműved: #ffff99" .. getElementData(localPlayer, "theOldCar") or "-", 0, 0, 0, true)
	end
)

addEvent("onVehicleLockEffect", true)
addEventHandler("onVehicleLockEffect", getRootElement(),
	function ()
		if isElement(source) then
			processLockEffect(source)
		end
	end
)

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
		250, 3)
	end
end

	function toggleVehicleLock()
		local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
		local playerInterior = getElementInterior(localPlayer)
		local playerDimension = getElementDimension(localPlayer)

		local vehicleFound = getPedOccupiedVehicle(localPlayer)
		local lastMinDistance = math.huge

		if not isElement(vehicleFound) then
			local vehicles = getElementsByType("vehicle", getRootElement(), true)

			for i = 1, #vehicles do
				local vehicle = vehicles[i]

				if isElement(vehicle) and getElementInterior(vehicle) == playerInterior and getElementDimension(vehicle) == playerDimension then
					local distance = getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, getElementPosition(vehicle))

					if distance <= 5 then
						vehicleFound = vehicle
					end
				end
			end
		end

		if isElement(vehicleFound) then

			triggerServerEvent("toggleVehicleLock", localPlayer, vehicleFound, getElementsByType("player", getRootElement(), true), {getPedTask(localPlayer, "primary", 3)})
		end
	end


addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "isPlayerDeath" then
			unbindKey("k")
			unbindKey("l")
	       	bindKey("k","down",toggleVehicleLock)
	      	bindKey("l","down",toggleVehicleLights)
		end
	end
)


function vehicleKeybind()
	unbindKey("k")
	unbindKey("l")
    bindKey("k","down",toggleVehicleLock)
    bindKey("l","down",toggleVehicleLights)
end
addEventHandler("onClientResourceStart", getResourceRootElement(),vehicleKeybind)
addEventHandler("onClientPlayerJoin", getRootElement(), vehicleKeybind)


local engineStartTimer = false
local preEngineStart = false
local lastEngineStart = 0


	function toggleVehicleLights()
		if isPedInVehicle(localPlayer) then
			local vehicle = getPedOccupiedVehicle(localPlayer)

			if getVehicleType(vehicle) ~= "BMX" and getVehicleOccupant(vehicle) == localPlayer then
				if not getElementData(vehicle, "emergencyIndicator") and not getElementData(vehicle, "leftIndicator") and not getElementData(vehicle, "rightIndicator") then
					triggerServerEvent("toggleVehicleLights", localPlayer, vehicle)
				end
			end
		end
	end


addEvent("playVehicleSound", true)
addEventHandler("playVehicleSound", getRootElement(),
	function (type, path)
		if isElement(source) then
			if type == "3d" then
				local sourcePosX, sourcePosY, sourcePosZ = getElementPosition(source)
				local sourceInterior = getElementInterior(source)
				local sourceDimension = getElementDimension(source)
				local soundElement = playSound3D(path, sourcePosX, sourcePosY, sourcePosZ)

				if isElement(soundElement) then
					setElementInterior(soundElement, sourceInterior)
					setElementDimension(soundElement, sourceDimension)

					attachElements(soundElement, source)
				end
			else
				playSound(path)
			end
		end
	end
)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		if getElementData(localPlayer, "loggedIn") then
			RobotoFont = dxCreateFont(":cosmo_assets/fonts/Roboto-Regular.ttf", 10, false, "antialiased")
			--setTimer(triggerServerEvent, 2000, 1, "loadPlayerVehicles", localPlayer, getElementData(localPlayer, "char.ID"))
		end
	end
)

addEventHandler("onClientVehicleEnter", getRootElement(),
	function (player, seat)
		setVehicleDoorOpenRatio(source, 2, 0, 0)
		setVehicleDoorOpenRatio(source, 3, 0, 0)
		setVehicleDoorOpenRatio(source, 4, 0, 0)
		setVehicleDoorOpenRatio(source, 5, 0, 0)

		if getVehicleOverrideLights(source) == 0 then
			setVehicleOverrideLights(source, 1)
			setElementData(source, "vehicle.light", false)
		end

		if player == localPlayer then
			if getVehicleType(source) == "BMX" then
				setVehicleEngineState(source, true)
			end

			setElementData(localPlayer, "theOldCar", getElementData(source, "vehicle.dbID"))

			if seat == 0 then
				if getElementData(source, "vehicle.wheelClamp") then
					toggleHandBrakeInfo(true, true)
				elseif getElementData(source, "vehicle.handBrake") then
					toggleHandBrakeInfo(true)
				end

				--outputChatBox(exports.cosmo_core:getServerTag().."A járművet a J + SPACE egyidejű lenyomásával tudod beindítani, a biztonsági övet pedig az F5 lenyomásával tudod bekötni.",255,255,255,true)
			else
				--outputChatBox(exports.cosmo_core:getServerTag().."A biztonsági övet az F5 lenyomásával tudod bekötni.",255,255,255,true)
			end
		end
	end
)

addEventHandler("onClientVehicleStartEnter", getRootElement(),
	function (player, seat, door)
		if player == localPlayer then
			if getVehicleType(source) == "Bike" or getVehicleType(source) == "BMX" or getVehicleType(source) == "Boat" then
				if getElementData(source, "vehicle.locked") then
					cancelEvent()
					exports.cosmo_hud:showInfobox("error", "Ez a jármű zárva van!")
				end
			end
		end
	end
)

addEventHandler("onClientVehicleStartExit", getRootElement(),
	function (player, seat, door)
		if seat == 0 and player == localPlayer then
			toggleHandBrakeInfo()
		end
	end
)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			setVehicleDoorOpenRatio(source, 2, 0, 0)
			setVehicleDoorOpenRatio(source, 3, 0, 0)
			setVehicleDoorOpenRatio(source, 4, 0, 0)
			setVehicleDoorOpenRatio(source, 5, 0, 0)
			
			for i = 0, 6 do
				setVehiclePanelState(source, i, getVehiclePanelState(source, i))
			end
		end
	end
)

local brakePanelState = false
local brakePanelWidth = 10
local brakePanelHeight = 250
local brakePanelPosX = screenX - brakePanelWidth - 12
local brakePanelPosY = screenY / 2 - brakePanelHeight / 2
local brakeState = 1
local brakeLastState = false
local brakeInfoBinded = false

function informatePlayerAboutHandbrake()
	local playerVehicle = getPedOccupiedVehicle(localPlayer)

	if isElement(playerVehicle) and getVehicleEngineState(playerVehicle) then
		exports.cosmo_hud:showInfobox("error", "Amíg be van húzva a kézifék, nem indulhatsz el.")
	end
end



function toggleHandBrakeInfo(state, wheelClamp)
	if state and not brakeInfoBinded then
		toggleControl("accelerate", false)
		toggleControl("brake_reverse", false)

		if not wheelClamp then
			bindKey("accelerate", "down", informatePlayerAboutHandbrake)
			bindKey("brake_reverse", "down", informatePlayerAboutHandbrake)
		else
			bindKey("accelerate", "down", informatePlayerAboutWheelClamp)
			bindKey("brake_reverse", "down", informatePlayerAboutWheelClamp)
		end

		brakeInfoBinded = true
	else
		toggleControl("accelerate", true)
		toggleControl("brake_reverse", true)

		if not wheelClamp then
			unbindKey("accelerate", "down", informatePlayerAboutHandbrake)
			unbindKey("brake_reverse", "down", informatePlayerAboutHandbrake)
		else
			unbindKey("accelerate", "down", informatePlayerAboutWheelClamp)
			unbindKey("brake_reverse", "down", informatePlayerAboutWheelClamp)
		end

		brakeInfoBinded = false
	end
end

addEventHandler("onClientCursorMove", getRootElement(),
	function (relX, relY, absX, absY)
		if not isMTAWindowActive() and getKeyState("lalt") and brakePanelState then
			local playerVehicle = getPedOccupiedVehicle(localPlayer)
			local vehicleType = getVehicleType(playerVehicle)
			local handBrake = getElementData(playerVehicle, "vehicle.handBrake")
			
			if not brakeLastState then
				if handBrake then
					brakeLastState = 1
					relY = 2
					setCursorPosition(screenX / 2, screenY)
				else
					brakeLastState = 0
					relY = 0
					setCursorPosition(screenX / 2, 0)
				end
			end

			local y = relY * 2

			if y < 0.25 then
				if handBrake and not getElementData(playerVehicle, "vehicle.wheelClamp") then
					if vehicleType == "Automobile" then
						setPedControlState(localPlayer, "handbrake", false)
						triggerServerEvent("onVehicleHandbrakeStateChange", playerVehicle, false, true)
					else
						triggerServerEvent("onVehicleHandbrakeStateChange", playerVehicle, false)
					end

					toggleHandBrakeInfo()
				end

				if y < 0 then
					y = 0
				end
			elseif y > 1.75 then
				if not handBrake and not getElementData(playerVehicle, "vehicle.wheelClamp") then
					if vehicleType == "Automobile" then
						setPedControlState(localPlayer, "handbrake", true)
						triggerServerEvent("onVehicleHandbrakeStateChange", playerVehicle, true, true)
					else
						triggerServerEvent("onVehicleHandbrakeStateChange", playerVehicle, true)
					end

					toggleHandBrakeInfo(true)
				end

				if y > 2 then
					y = 2
				end
			end

			brakeState = y
		end
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "vehicle.handBrake" then
			local playerVehicle = getPedOccupiedVehicle(localPlayer)

			if playerVehicle == source then
				if getElementData(source, "vehicle.handBrake") then
					playSound("files/handbrake.wav")
				end
			end
		end
	end
)

addEventHandler("onClientRender", getRootElement(),
	function ()
		local playerVehicle = getPedOccupiedVehicle(localPlayer)

		if playerVehicle and getPedOccupiedVehicleSeat(localPlayer) == 0 then
			local vehicleType = getVehicleType(playerVehicle)
			local task = getPedSimplestTask(localPlayer)

			if getKeyState("lalt") and task == "TASK_SIMPLE_CAR_DRIVE" and not getElementData(playerVehicle, "vehicle.wheelClamp") then
				local velocityX, velocityY, velocityZ = getElementVelocity(playerVehicle)
				local speed = getDistanceBetweenPoints3D(0, 0, 0, velocityX, velocityY, velocityZ) * 180

				if (vehicleType ~= "Automobile" and speed <= 5) or vehicleType == "Automobile" then
					brakePanelState = true
					showCursor(true)
					setCursorAlpha(0)
				end
			else
				brakePanelState = false
				showCursor(false)
				setCursorAlpha(255)
				brakeLastState = false
			end

			if brakePanelState then
				local sizeForZone = brakePanelHeight / 3

				dxDrawRectangle(brakePanelPosX, brakePanelPosY, brakePanelWidth, brakePanelHeight, tocolor(0, 0, 0, 200))

				dxDrawRectangle(brakePanelPosX + 2, brakePanelPosY + 2, brakePanelWidth - 4, sizeForZone - 4, tocolor(50, 200, 50))

				dxDrawRectangle(brakePanelPosX + 2, brakePanelPosY + 2 + brakePanelHeight - sizeForZone, brakePanelWidth - 4, sizeForZone - 4, tocolor(200, 50, 50))

				dxDrawRectangle(brakePanelPosX + 2, brakePanelPosY + 2 + sizeForZone * brakeState, brakePanelWidth - 4, sizeForZone - 4, tocolor(255, 255, 255, 160))
			end

			if vehicleType == "Automobile" then
				if getElementData(playerVehicle, "vehicle.handBrake") then
					local velocityX, velocityY, velocityZ = getElementVelocity(playerVehicle)
					local speed = getDistanceBetweenPoints3D(0, 0, 0, velocityX, velocityY, velocityZ) * 180

					if speed <= 5 then
						setElementFrozen(playerVehicle, true)
					else
						setPedControlState(localPlayer, "handbrake", true)
					end
				end
			end
		end
	end
)

exports.cosmo_admin:addAdminCommand("nearbyvehicles", 1, "Közelben lévő járművek")
addCommandHandler("nearbyvehicles",
	function (cmd, distance)
		if getElementData(localPlayer, "acc.adminLevel") >= 1 then
			if not distance then
				distance = 15
			elseif tonumber(distance) then
				distance = tonumber(distance)
			end

			local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
			local nearbyVehicles = {}
			
			for k, v in ipairs(getElementsByType("vehicle", getRootElement(), true)) do
				local vehiclePosX, vehiclePosY, vehiclePosZ = getElementPosition(v)

				if getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, vehiclePosX, vehiclePosY, vehiclePosZ) <= distance then
					local model = getElementModel(v)

					table.insert(nearbyVehicles, {
						model,
						exports.cosmo_mods_veh:getVehicleNameFromModel(model),
						getElementData(v, "vehicle.dbID") or 0,
						getVehiclePlateText(v)
					})
				end
			end
			
			if #nearbyVehicles > 0 then
				outputChatBox(exports.cosmo_core:getServerTag("admin") .. "Közeledben lévő járművek #ffff99(" .. distance .. " yard):", 0, 0, 0, true)

				for k, v in ipairs(nearbyVehicles) do
					outputChatBox("    * #d75959Típus: #ffffff" .. v[1] .. " (" .. v[2] .. ") | #d75959Azonosító: #ffffff" .. (v[3] == 0 and "Nincs (ideiglenes)" or v[3]) .. " | #d75959Rendszám: #ffffff" .. (v[4] or "Nincs"), 255, 255, 255, true)
				end
			else
				outputChatBox(exports.cosmo_core:getServerTag("admin") .. "Nincs egyetlen jármű sem a közeledben.", 0, 0, 0, true)
			end
		end
	end
)

local vehicleStatsHandled = false
local RobotoFont2 = false
local RobotoBolderFont = false

exports.cosmo_admin:addAdminCommand("dl", 1, "Jármű adatok mutatása a járművek felett")
addCommandHandler("dl",
	function()
		if getElementData(localPlayer, "acc.adminLevel") >= 1 then
			if vehicleStatsHandled then
				removeEventHandler("onClientRender", getRootElement(), renderVehicleStats)

				if isElement(RobotoFont2) then
					destroyElement(RobotoFont2)
					RobotoFont2 = nil
				end

				if isElement(RobotoBolderFont) then
					destroyElement(RobotoBolderFont)
					RobotoBolderFont = nil
				end

				vehicleStatsHandled = false
			else
				RobotoFont2 = dxCreateFont("files/Roboto.ttf", 10, false, "antialiased")
				RobotoBolderFont = dxCreateFont("files/RobotoB.ttf", 14, false, "antialiased")

				addEventHandler("onClientRender", getRootElement(), renderVehicleStats)

				vehicleStatsHandled = true
			end
		end
	end)

function renderVehicleStats()
	local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
	local vehicles = getElementsByType("vehicle", getRootElement(), true)

	for k = 1, #vehicles do
		v = vehicles[k]

		if isElement(v) and isElementOnScreen(v) then
			local vehiclePosX, vehiclePosY, vehiclePosZ = getElementPosition(v)

			if isLineOfSightClear(playerPosX, playerPosY, playerPosZ, vehiclePosX, vehiclePosY, vehiclePosZ, true, false, false, true, false, false, false, localPlayer) then
				local dist = getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, vehiclePosX, vehiclePosY, vehiclePosZ)

				if dist <= 75 then
					local screenPosX, screenPosY = getScreenFromWorldPosition(vehiclePosX, vehiclePosY, vehiclePosZ)

					if screenPosX and screenPosY then
						local scaleFactor = 1 - dist / 75

						local vehicleId = getElementData(v, "vehicle.dbID") or "Ideiglenes"
						local vehicleName = getVehicleName(v)
						local vehicleModel = getElementModel(v)

						local sx = dxGetTextWidth(vehicleName .. " (" .. vehicleModel .. ")", scaleFactor, RobotoBolderFont) + 100 * scaleFactor
						local sy = 80 * scaleFactor

						local x = screenPosX - sx / 2
						local y = screenPosY - sy / 2

						dxDrawRectangle(x - 7, y - 7, sx + 14, sy + 14, tocolor(0, 0, 0, 150))
						dxDrawRectangle(x - 5, y - 5, sx + 10, sy + 10, tocolor(0, 0, 0, 125))

						dxDrawText("#7cc576" .. vehicleName .. " #7cc576(" .. vehicleModel .. ")", x, y, x + sx, y, tocolor(255, 255, 255), scaleFactor, RobotoBolderFont, "center", "top", false, false, false, true)
							
						dxDrawText("Adatbázis ID:", x, y + 25 * scaleFactor, x + sx, 0, tocolor(255, 255, 255), scaleFactor, RobotoFont2, "left", "top")
						dxDrawText(vehicleId, x, y + 25 * scaleFactor, x + sx, 0, tocolor(215, 89, 89), scaleFactor, RobotoFont2, "right", "top")

						dxDrawRectangle(x, y + 41.5 * scaleFactor, sx, 2, tocolor(255, 255, 255, 50))

						dxDrawText("Rendszám:", x, y + 45 * scaleFactor, x + sx, 0, tocolor(255, 255, 255), scaleFactor, RobotoFont2, "left", "top")
						dxDrawText(getVehiclePlateText(v), x, y + 45 * scaleFactor, x + sx, 0, tocolor(50, 179, 239), scaleFactor, RobotoFont2, "right", "top")

						dxDrawRectangle(x, y + 61.5 * scaleFactor, sx, 2, tocolor(255, 255, 255, 50))

						dxDrawText("Állapot:", x, y + 65 * scaleFactor, x + sx, 0, tocolor(255, 255, 255), scaleFactor, RobotoFont2, "left", "top")
						dxDrawText(math.floor(getElementHealth(v) / 10) .. "%", x, y + 65 * scaleFactor, x + sx, 0, tocolor(50, 179, 239), scaleFactor, RobotoFont2, "right", "top")
					end
				end
			end
		end
	end
end

local w = 300
local h = 100

local panelx = screenX / 2 - w / 2
local panely = screenY / 2 - h / 2
local currentVeh = nil

function rendersPanel()
	buttons = {}

	dxDrawRectangle(panelx-1, panely-1, w+2, h+2, tocolor(0, 0, 0, 225))
	dxDrawRectangle(panelx, panely, w, h, tocolor(40, 40, 40, 225))

	dxDrawText("Biztos hogy be szeretnéd zúzatni a kocsit?", panelx + 150, panely + 30, panelx + 150, panely + 30, tocolor(255, 255, 255, 255), 1, RobotoFont, "center", "center")

	dxDrawRectangle(panelx, panely + h - 30, w/2, 30, tocolor(255, 148, 40, 155))
	dxDrawRectangle(panelx + w/2, panely + h - 30, w/2, 30, tocolor(220, 73, 73, 155))
	
	dxDrawText("Igen", panelx + 75, panely + 85, panelx + 75, panely + 85, tocolor(255, 255, 255, 255), 1, RobotoFont, "center", "center")
	buttons.yes = {panelx, panely + h - 30, w/2, 30}
	dxDrawText("Nem", panelx + 225, panely + 85, panelx + 225, panely + 85, tocolor(255, 255, 255, 255), 1, RobotoFont, "center", "center")
	buttons.no = {panelx + w/2, panely + h - 30, w/2, 30}
	
	local relX, relY = getCursorPosition()
	
	activeButton = false
	
	if relX and relY then
		relX = relX * screenX
		relY = relY * screenY
		
		for k, v in pairs(buttons) do
			if relX >= v[1] and relX <= v[1] + v[3] and relY >= v[2] and relY <= v[2] + v[4] then
				activeButton = k
				break
			end
		end
	end
end

function junkClick(button, state)
	if button == "left" and state == "down" and activeButton then
		local selected = split(activeButton, ";")
		
		if selected[1] == "yes" then
			local playerVehicle = getPedOccupiedVehicle (localPlayer)
			setElementFrozen(playerVehicle, false)
			triggerServerEvent("deleteVehicle", localPlayer, currentVeh)
			removeEventHandler("onClientRender", root, rendersPanel)
			removeEventHandler("onClientClick", root, junkClick)
			currentVeh = nil
		elseif selected[1] == "no" then
			local playerVehicle = getPedOccupiedVehicle (localPlayer)
			setElementFrozen(playerVehicle, false)
			removeEventHandler("onClientRender", root, rendersPanel)
			removeEventHandler("onClientClick", root, junkClick)
			currentVeh = nil
		end
	end
end

--[[addCommandHandler("faszomat", function()
addEventHandler("onClientRender", root, rendersPanel)
end)]]

function junkyardClientSide(vehID)
	RobotoFont = dxCreateFont("files/Roboto.ttf", 10, false, "antialiased")
	if vehID then
		addEventHandler("onClientRender", root, rendersPanel)
		addEventHandler("onClientClick", root, junkClick)
		currentVeh = vehID
		local playerVehicle = getPedOccupiedVehicle (localPlayer)
		setElementFrozen(playerVehicle, true)
	end
end
addEvent("junkyardClientSide", true)
addEventHandler("junkyardClientSide", root, junkyardClientSide)