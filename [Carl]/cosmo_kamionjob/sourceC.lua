local screenX, screenY = guiGetScreenSize()

local spawnedTrailers = {} 
local trailerModels = {584, 435, 450, 591}

local selectedTrailer = 1
local selectedDeliveryPoint = 1

local cameraIsMoving = false

local lastInterior = 0 

local destinationBlip = nil


local fonts = {
	Roboto13 = dxCreateFont("files/Roboto.ttf", 13, false, "proof") or "default",
	RobotoL20 = dxCreateFont("files/Roboto-Light.ttf", 20, false, "proof") or "default",
	RobotoB20 = dxCreateFont("files/Roboto-Bold.ttf", 20, false, "proof") or "default",
}

local spawnedPeds = {}
local destinationData = {}

addEventHandler("onClientResourceStart", resourceRoot, function()
	setElementData(localPlayer, "player.trailer", nil)
	for k, v in pairs(deliveryPoints) do
		local ped = createPed(100, unpack(v.ped))
		setElementFrozen(ped, true)
		spawnedPeds[ped] = k
	end	
end)

addEventHandler("onClientClick", root, function(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
	if button == "left" and state == "down" then
		if clickedElement then
			if spawnedPeds[clickedElement] then
				if getElementData(localPlayer, "player.trailer") then
					local trailer = getElementData(localPlayer, "player.trailer")
					local destinationId = getElementData(trailer, "trailer.destinationId")
					local destination = deliveryPoints[destinationId]

					if destinationId == spawnedPeds[clickedElement] then
						if checkAABB(getElementData(localPlayer, "player.trailer"), destinationData.colShapeBounds) then
							local freightId = getElementData(trailer, "trailer.freightId")
							local freight = freights[freightId]

							local reward = freight.reward

							-- setElementData(localPlayer,"player:money",getElementData(localPlayer,"player:money")+math.random(5000,15000))

							triggerServerEvent("deleteTrailer", localPlayer)

							outputChatBox("Sikeresen megkaptad/leadtad a pótkocsidat! Menny vissza a depóba ha szeretnél még több pénzt keresni!", 0, 255, 0)

							removeEventHandler("onClientRender", root, renderParkingZone)
							
							if isElement(destinationBlip) then
								destroyElement(destinationBlip)
							end

							destinationData = {}
						else
							outputChatBox("Parkolj a megjelöltl területre!", 216, 12, 12)
						end
					else
						outputChatBox("Ez nem a te rakomány raktárad!", 216, 12, 12)
					end
				else
					selectedDeliveryPoint = spawnedPeds[clickedElement]
					showTrailerSelector()
				end
			end
		end
	end
end)

function showTrailerSelector()
	fadeCamera(false, 0.5)

	setTimer(function()
		lastInterior = getElementInterior(localPlayer)

		setPlayerHudComponentVisible("all", false)
		showChat(false)

		setTime(12, 0)
		setElementInterior(localPlayer, 1)
		setElementFrozen(localPlayer, true)

		for i = 1, 4 do
			local randomDeliveryPoint = math.random(1, #deliveryPoints)
			repeat
				randomDeliveryPoint = math.random(1, #deliveryPoints)
			until(randomDeliveryPoint ~= selectedDeliveryPoint)

			local randomFreight = math.random(1, #freights)
			local freight = freights[randomFreight]


			spawnedTrailers[i] = createVehicle(freight.model, 1370.76746, -40.29878 + 10 * (i - 1), 1000.92188 + 1)
			setElementRotation(spawnedTrailers[i], 0, 0, 270)
			setElementInterior(spawnedTrailers[i], 1)
			setElementDimension(spawnedTrailers[i], 0)
			setElementData(spawnedTrailers[i], "freightDetails", {randomFreight, randomDeliveryPoint}, false)
		end

		selectedTrailer = #spawnedTrailers

		animationStarted = true
		initAnimation("trailerCam", true, {getElementPosition(spawnedTrailers[selectedTrailer])}, {getElementPosition(spawnedTrailers[selectedTrailer])}, 1000, "Linear", function()
			fadeCamera(true)
			addEventHandler("onClientKey", root, trailerSelectorKeyHandler)
			addEventHandler("onClientRender", root, renderTrailerInformation)
		end)	
	end, 500, 1)
end

function trailerSelectorKeyHandler(key, isPressed)
	if isPressed then
		if key == "arrow_l" then
			selectedTrailer = selectedTrailer - 1

			if selectedTrailer <= 0 then
				selectedTrailer = #spawnedTrailers
			end

			local cameraLook = getAnimationValue("trailerCam")
			initAnimation("trailerCam", true, cameraLook, {getElementPosition(spawnedTrailers[selectedTrailer])}, 1000, "InOutQuad")
		elseif key == "arrow_r" then
			selectedTrailer = selectedTrailer + 1

			if selectedTrailer > #spawnedTrailers then
				selectedTrailer = 1
			end

			local cameraLook = getAnimationValue("trailerCam")
			initAnimation("trailerCam", true, cameraLook, {getElementPosition(spawnedTrailers[selectedTrailer])}, 1000, "InOutQuad")
		elseif key == "backspace" or key == "enter" then
			fadeCamera(false, 0.5)
			animationStarted = false
			
			setElementInterior(localPlayer, lastInterior)
			
			removeEventHandler("onClientKey", root, trailerSelectorKeyHandler)
			removeEventHandler("onClientRender", root, renderTrailerInformation)

			if key == "enter" then
				local data = getElementData(spawnedTrailers[selectedTrailer], "freightDetails")
				triggerServerEvent("spawnTrailer", localPlayer, {data[1], data[2], selectedDeliveryPoint})

				-- Létrehozzuk a blipet a célhoz, a cél lerakodó pontját...
				local destination = deliveryPoints[data[2]]

				if isElement(destinationBlip) then
					destroyElement(destinationBlip)
				end

				local bX, bY, bZ = unpack(destination.position)
				destinationBlip = createBlip(bX, bY, bZ, 0, 3, 80, 200, 120)

				createDropPoint(data[2])

				addEventHandler("onClientRender", root, renderParkingZone)
			end

			setTimer(function()
				setCameraTarget(localPlayer)
				fadeCamera(true)
				setElementFrozen(localPlayer, false)
				showChat(true)
				setPlayerHudComponentVisible("all", false)

				for k, v in pairs(spawnedTrailers) do 
					if isElement(v) then
						destroyElement(v)
					end
				end
			end, 1000, 1)
		end
	end
end

local panelW, panelH = 260, 270
local panelX, panelY = screenX - panelW - 15, (screenY - panelH) * 0.5

local tooltipW, tooltipH = 458, 40	
local tooltipX, tooltipY = screenX - tooltipW - 15, screenY - tooltipH - 15

function renderTrailerInformation()
	local trailerData = freights[getElementData(spawnedTrailers[selectedTrailer], "freightDetails")[1]]
	local destination = deliveryPoints[getElementData(spawnedTrailers[selectedTrailer], "freightDetails")[2]]

	dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(0, 0, 0, 160))
	dxDrawRectangle(panelX, panelY, panelW, 50, tocolor(80, 200, 120, 230))

	dxDrawText("Pótkocsi", panelX + 10, panelY, panelW + panelX, 50 + panelY, tocolor(255, 255, 255, 255), 1, fonts.RobotoL20, "left", "center")
	dxDrawText("#" .. selectedTrailer, panelX, panelY, panelW + panelX - 10, 50 + panelY, tocolor(255, 255, 255, 255), 1, fonts.RobotoB20, "right", "center")

	local y = panelY + 50
	local x = panelX

	for i = 1, 3 do
		local headerText = "Szállítmány"
		local descriptionText = trailerData.name

		if i == 2 then
			headerText = "Leszállítási pont"
		 	descriptionText = destination.name
		elseif i == 3 then
			headerText = "Összeg"
		 	descriptionText = "$ " .. trailerData.reward
		end

		dxDrawRectangle(x + 1, y, panelW - 1, 30, tocolor(0, 0, 0, 160))
		dxDrawText(headerText, x + 15, y, panelW - 1 + x, 30 + y, tocolor(255, 255, 255), 0.5, fonts.RobotoB20, "left", "center")
		dxDrawText(descriptionText, x + 15, y + 30, panelW - 1 + x, 30 + y + 30, tocolor(255, 255, 255), 0.9, fonts.Roboto13, "center", "center")

		y = y + 60
	end

	dxDrawRectangle(tooltipX, tooltipY, tooltipW, tooltipH, tocolor(0, 0, 0, 200))
	dxDrawKeyWithText("Írányítás", "<>", tooltipX + 5, tooltipY, tooltipW, tooltipH)
	dxDrawKeyWithText("Kiválasztás", "Enter", tooltipX + 110, tooltipY, tooltipW, tooltipH)
	dxDrawKeyWithText("Kilépés", "Backspace", tooltipX + 260, tooltipY, tooltipW, tooltipH)
end

function createDropPoint(deliveryPoint)

	local middleX, middleY = deliveryPoints[deliveryPoint].dropPoint[1], deliveryPoints[deliveryPoint].dropPoint[2]

	local parkingDetails = {middleX, middleY, deliveryPoints[deliveryPoint].dropPoint[3], 13, 4}

	destinationData = {
		basePosition = {parkingDetails[1], parkingDetails[2], deliveryPoints[deliveryPoint].dropPoint[3]},
		baseRotation = deliveryPoints[deliveryPoint].dropPoint[4] + 90,
		parkingSizes = {parkingDetails[4], parkingDetails[5]},
	}

	rotated_x1, rotated_y1 = rotateAround(destinationData.baseRotation, -destinationData.parkingSizes[1] / 2, -destinationData.parkingSizes[2] / 2)
	local rotated_x2, rotated_y2 = rotateAround(destinationData.baseRotation, destinationData.parkingSizes[1] / 2, -destinationData.parkingSizes[2] / 2)
	local rotated_x3, rotated_y3 = rotateAround(destinationData.baseRotation, destinationData.parkingSizes[1] / 2, destinationData.parkingSizes[2] / 2)
	local rotated_x4, rotated_y4 = rotateAround(destinationData.baseRotation, -destinationData.parkingSizes[1] / 2, destinationData.parkingSizes[2] / 2)

	destinationData.colShape = createColPolygon(
		destinationData.basePosition[1],
		destinationData.basePosition[2],

		destinationData.basePosition[1] + rotated_x1,
		destinationData.basePosition[2] + rotated_y1,

		destinationData.basePosition[1] + rotated_x2,
		destinationData.basePosition[2] + rotated_y2,

		destinationData.basePosition[1] + rotated_x3,
		destinationData.basePosition[2] + rotated_y3,

		destinationData.basePosition[1] + rotated_x4,
		destinationData.basePosition[2] + rotated_y4
	)

	destinationData.colShapeBounds = {
		[1] = {destinationData.basePosition[1] + rotated_x2, destinationData.basePosition[2] + rotated_y2}, -- top right
		[2] = {destinationData.basePosition[1] + rotated_x3, destinationData.basePosition[2] + rotated_y3}, -- top left
		[3] = {destinationData.basePosition[1] + rotated_x1, destinationData.basePosition[2] + rotated_y1}, -- bottom right
		[4] = {destinationData.basePosition[1] + rotated_x4, destinationData.basePosition[2] + rotated_y4} -- bottom left
	}

	setDevelopmentMode(true)
end

local allowedVehicles = {[584] = true, [435] = true, [450] = true, [591] = true}

function checkAABB(vehicleElement, colshapeBounds, requiredRotation)
	if not isElement(vehicleElement) then
		return false
	end

	if not allowedVehicles[getElementModel(vehicleElement)] then
		return false
	end

	local vehicleMatrix = getElementMatrix(vehicleElement)
	local vehicleBounds = {
		[1] = {getPositionFromOffset(vehicleMatrix, 1.5, 7.5, 0)}, -- Top right
		[2] = {getPositionFromOffset(vehicleMatrix, -1.5, 7.5, 0)}, -- Top left
		[3] = {getPositionFromOffset(vehicleMatrix, 1.5, -4.5, 0)}, -- Bottom right
		[4] = {getPositionFromOffset(vehicleMatrix, -1.5, -4.5, 0)}, -- Bottom left
	}

	local vehicleX = {vehicleBounds[1][1], vehicleBounds[2][1], vehicleBounds[3][1], vehicleBounds[4][1]} 
	local vehicleY = {vehicleBounds[1][2], vehicleBounds[2][2], vehicleBounds[3][2], vehicleBounds[4][2]}

	local colshapeX = {colshapeBounds[1][1], colshapeBounds[2][1], colshapeBounds[3][1], colshapeBounds[4][1]}
	local colshapeY = {colshapeBounds[1][2], colshapeBounds[2][2], colshapeBounds[3][2], colshapeBounds[4][4]}

	local colMinX, colMinY = math.min(unpack(colshapeX)), math.min(unpack(colshapeY))
	local colMaxX, colMaxY = math.max(unpack(colshapeX)), math.max(unpack(colshapeY))

	local vehMinX, vehMinY = math.min(unpack(vehicleX)), math.min(unpack(vehicleY))
	local vehMaxX, vehMaxY = math.max(unpack(vehicleX)), math.max(unpack(vehicleY))

	if requiredRotation then
		local vehicleRotation = select(3, getElementRotation(vehicleElement))

		if vehicleRotation < requiredRotation - 15 or vehicleRotation > requiredRotation + 15 then
			return false
		end
	end

	if vehMinX > colMinX and vehMaxX < colMaxX then
		if vehMinY > colMinY and vehMaxY < colMaxY then
			return true
		end
	end

	return false
end

function renderParkingZone()
	local x, y = unpack(destinationData.colShapeBounds[1])
	local z = getGroundPosition(x, y, 20) + 0.1

	local color = tocolor(255, 0, 0)
	if checkAABB(getElementData(localPlayer, "player.trailer"), destinationData.colShapeBounds) then
		color = tocolor(0, 255, 0)
	end

	dxDrawLine3D(
		destinationData.colShapeBounds[1][1], destinationData.colShapeBounds[1][2], z,
		destinationData.colShapeBounds[2][1], destinationData.colShapeBounds[2][2], z,
		color, 3
	)

	dxDrawLine3D(
		destinationData.colShapeBounds[2][1], destinationData.colShapeBounds[2][2], z,
		destinationData.colShapeBounds[4][1], destinationData.colShapeBounds[4][2], z,
		color, 3
	)

	dxDrawLine3D(
		destinationData.colShapeBounds[4][1], destinationData.colShapeBounds[4][2], z,
		destinationData.colShapeBounds[3][1], destinationData.colShapeBounds[3][2], z,
		color, 3
	)

	dxDrawLine3D(
		destinationData.colShapeBounds[3][1], destinationData.colShapeBounds[3][2], z,
		destinationData.colShapeBounds[1][1], destinationData.colShapeBounds[1][2], z,
		color, 3
	)
end

------------------------------------------------------------------------

local animations = {}

addEventHandler("onClientRender", root, function()
	for k, v in pairs(animations) do
        if not v.completed then
            local currentTick = getTickCount()
            local elapsedTick = currentTick - v.startTick
            local duration = v.endTick - v.startTick
            local progress = elapsedTick / duration

            v.currentValue[1], v.currentValue[2], v.currentValue[3] = interpolateBetween(
                v.startValue[1], v.startValue[2], v.startValue[3], 
                v.endValue[1], v.endValue[2], v.endValue[3], 
                progress, 
                v.easingType or "Linear"
            )

            if progress >= 1 then
                v.completed = true

                if v.completeFunction then
                    v.completeFunction(unpack(v.functionArgs))
                end
            end
        end
	end
	
	if animationStarted then
		local cameraLook = getAnimationValue("trailerCam")

		setCameraMatrix(cameraLook[1] + 15, cameraLook[2] + 5, cameraLook[3] + 5, cameraLook[1], cameraLook[2], cameraLook[3])
	end
end)

function initAnimation(id, storeVal, startVal, endVal, time, easing, compFunction, args)
    if not storeVal then
        animations[id] = {}
    end

    if not animations[id] then
        animations[id] = {}
    end

    animations[id].startValue = startVal
    animations[id].endValue = endVal
    animations[id].startTick = getTickCount()
    animations[id].endTick = animations[id].startTick + (time or 3000)
    animations[id].easingType = easing
    animations[id].completeFunction = compFunction
    animations[id].functionArgs = args or {}

    animations[id].currentValue = storeVal and animations[id].currentValue or {0, 0, 0}
    animations[id].completed = false
end

function getAnimationValue(id)
	if animations[id] then
		return animations[id].currentValue
	end

	return {0, 0, 0}
end

function setAnimationValue(id, val)
    animations[id].currentValue = val 
end

function dxDrawRoundedRectangle(x, y, rx, ry, color, radius)
    rx = rx - radius * 2
    ry = ry - radius * 2
    x = x + radius
    y = y + radius

    if (rx >= 0) and (ry >= 0) then
        dxDrawRectangle(x, y, rx, ry, color)
        dxDrawRectangle(x, y - radius, rx, radius, color)
        dxDrawRectangle(x, y + ry, rx, radius, color)
        dxDrawRectangle(x - radius, y, radius, ry, color)
        dxDrawRectangle(x + rx, y, radius, ry, color)

        dxDrawCircle(x, y, radius, 180, 270, color, color, 7)
        dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7)
        dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7)
        dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7)
    end
end

function dxDrawBorderedRectangle( x, y, width, height, color1, color2, _width, postGUI )
    local _width = _width or 1
    dxDrawRectangle ( x+1, y+1, width-1, height-1, color1, postGUI )
    dxDrawLine ( x, y, x+width, y, color2, _width, postGUI ) -- Top
    dxDrawLine ( x, y, x, y+height, color2, _width, postGUI ) -- Left
    dxDrawLine ( x, y+height, x+width, y+height, color2, _width, postGUI ) -- Bottom
    dxDrawLine ( x+width, y, x+width, y+height, color2, _width, postGUI ) -- Right
end

function dxDrawKeyWithText(text, keyText, x, y, w, h)
	local textWidth = dxGetTextWidth(text, 1, fonts.Roboto13)
	dxDrawText(text, x, y, w + x, h + y, tocolor(255, 255, 255), 1, fonts.Roboto13, "left", "center")
		
	local keyTextWidth = dxGetTextWidth(keyText, 0.9, fonts.Roboto13)
	dxDrawRoundedRectangle(x + textWidth + 10 - 5, y + 5, keyTextWidth + 10, h - 10, tocolor(255, 255, 255), 5)
	dxDrawText(keyText, x + textWidth + 10, y + 5, keyTextWidth + x + textWidth + 10, h - 10 + y + 5, tocolor(0, 0, 0), 0.9, fonts.Roboto13, "center", "center")
end

addCommandHandler("aasadsdsadsadsasasdadsadsadsadsa", function()
showTrailerSelector()
end)