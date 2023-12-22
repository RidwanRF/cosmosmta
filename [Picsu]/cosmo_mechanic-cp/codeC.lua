local screenSize = {guiGetScreenSize()}
screenSize.x, screenSize.y = screenSize[1], screenSize[2]

local bgColor = tocolor(0, 0, 0, 180)
local slotColor = tocolor(40, 40, 40, 200)

local hoverColor = tocolor(255, 148, 40, 180)
local cancelColor = tocolor(243, 85, 85, 180)

local markers = {
	{1744.9583740234, -1132.0863037109, 24.131258010864},
	{1757.7816162109, -1101.3253173828, 24.13906288147},
	{1772.0170898438, -1132.2398681641, 24.131258010864},
	{1785.1773681641, -1100.9311523438, 24.131258010864},
	{1799.5007324219, -1132.2014160156, 24.131258010864},
	{1798.6358642578, -1100.0490722656, 24.131258010864},
	{1785.5563964844, -1132.7288818359, 24.131258010864},
	{1771.3603515625, -1100.9437255859, 24.131258010864},
	{1758.4958496094, -1132.1977539062, 24.131258010864},
}

local createdMarkers = {}

for key, value in ipairs(markers) do
	createdMarkers[key] = createMarker(value[1], value[2], value[3] - 1, "cylinder", 2, 255, 148, 40, 150)
	setElementData(createdMarkers[key], "points->FixMarker", true)
	setElementAlpha(createdMarkers[key],0);
end

function get_duty_mechanic()
	local counter = 0;
	for _,v in pairs(getElementsByType("player")) do
		if getElementData(v, "groupDuty") and exports.cosmo_groups:isPlayerInGroup(v, 28) then
			counter = counter + 1;
			print(counter)
			--outputChatBox(tostring(getElementData(v, "groupDutyID")), 255, 255, 255, true) --debug
		end			
	end

	for c, value in ipairs(markers) do
		if counter == 0 then 
			setElementAlpha(createdMarkers[c],255);
		else 
			setElementAlpha(createdMarkers[c],0);
		end
	end
end

setTimer ( function()
		get_duty_mechanic()
end, 5000, 0 )


function isCursorHover(startX, startY, sizeX, sizeY)
	if isCursorShowing() then
		local cursorPosition = {getCursorPosition()}
		cursorPosition.x, cursorPosition.y = cursorPosition[1] * screenSize.x, cursorPosition[2] * screenSize.y

		if cursorPosition.x >= startX and cursorPosition.x <= startX + sizeX and cursorPosition.y >= startY and cursorPosition.y <= startY + sizeY then
			return true
		else
			return false
		end
	else
		return false
	end
end

local roboto = dxCreateFont("files/Roboto.ttf", 9)

local panelStates = false

addEventHandler("onClientMarkerHit", root, function(player)
	for c, value in ipairs(markers) do
		if getElementAlpha(createdMarkers[c]) == 0 then return end
		
		if player == localPlayer and getElementData(source, "points->FixMarker") then
			vehicle = getPedOccupiedVehicle(localPlayer)

			if vehicle and getPedOccupiedVehicleSeat(localPlayer) == 0 then
				if getElementHealth(vehicle) >= 990 then
					outputChatBox("#ff9428[CosmoMTA] #ffffffA járműved nem sérült.", 0, 0, 0, true)
				else
					panelStates = true
					--fixMoney = math.random(120000,250000)
					if getElementData(vehicle, "vehicle.group") == 1 or getElementData(vehicle, "vehicle.group") == 4 or getElementData(vehicle, "vehicle.group") == 11 then
						fixMoney = 0
					else
						fixMoney = 150000
					end
				end
			end
		end
	end
end)

addEventHandler("onClientMarkerLeave", root, function(player)
	for c, value in ipairs(markers) do
		if getElementAlpha(createdMarkers[c]) == 0 then return end
		if player == localPlayer and getElementData(source, "points->FixMarker") then
			if panelStates then
				panelStates = false
			end
		end
	end
end)

addEventHandler("onClientRender", root, function()
	if panelStates then
		dxDrawRectangle(screenSize.x/2 - 200, screenSize.y/2 - 50, 400, 100, bgColor)
		dxDrawRectangle(screenSize.x/2 - 200, screenSize.y/2 + 50, 400, 2, hoverColor)

		dxDrawText("Szeretnéd megjavítani a járművedet?\nJavítás ára : #ff9428" .. fixMoney.."$", screenSize.x/2 - 200, screenSize.y/2 - 45, screenSize.x/2 + 200, 0, tocolor(255, 255, 255), 1, roboto, "center", "top", false, false, false, true)
	
		dxDrawRectangle(screenSize.x/2 - 170, screenSize.y/2, 150, 30, slotColor)
		dxDrawText("Javítás", screenSize.x/2 - 170, screenSize.y/2, screenSize.x/2 - 20, screenSize.y/2 + 30, tocolor(255, 255, 255), 1, roboto, "center", "center")
	
		if isCursorHover(screenSize.x/2 - 170, screenSize.y/2, 150, 30) then
			dxDrawRectangle(screenSize.x/2 - 170, screenSize.y/2, 150, 30, hoverColor)
			dxDrawText("Javítás", screenSize.x/2 - 170, screenSize.y/2, screenSize.x/2 - 20, screenSize.y/2 + 30, tocolor(0, 0, 0), 1, roboto, "center", "center")
		end

		dxDrawRectangle(screenSize.x/2 + 20, screenSize.y/2, 150, 30, slotColor)
		dxDrawText("Kilépés", screenSize.x/2 + 20, screenSize.y/2, screenSize.x/2 + 170, screenSize.y/2 + 30, tocolor(255, 255, 255), 1, roboto, "center", "center")
	
		if isCursorHover(screenSize.x/2 + 20, screenSize.y/2, 150, 30) then
			dxDrawRectangle(screenSize.x/2 + 20, screenSize.y/2, 150, 30, cancelColor)
			dxDrawText("Kilépés", screenSize.x/2 + 20, screenSize.y/2, screenSize.x/2 + 170, screenSize.y/2 + 30, tocolor(0, 0, 0), 1, roboto, "center", "center")
		end
	elseif repairState then
		if getTickCount() >= startTick then
			local delayTime = getTickCount() - startTick
			if delayTime < 4000 then
				progTime = delayTime / 4000
				panelX = interpolateBetween(0, 0, 0, 250, 0, 0, progTime, "Linear")

				dxDrawRectangle(screenSize.x/2 - 250/2 - 2, screenSize.y/2 - 10, 254, 20, bgColor)
				dxDrawRectangle(screenSize.x/2 - 250/2, screenSize.y/2 - 8, 250, 16, slotColor)
				dxDrawRectangle(screenSize.x/2 - 250/2, screenSize.y/2 - 8, panelX, 16, hoverColor)

				dxDrawText("Szerelés folyamatban...", 0, 0, screenSize.x, screenSize.y, tocolor(255, 255, 255), 1, roboto, "center", "center")
			else
				repairState = false

				setElementData(localPlayer, "char.Money", getElementData(localPlayer, "char.Money") - fixMoney)
				outputChatBox("#ff9428[CosmoMTA] #ffffffSikeresen megjavíttattad a járműved #ff9428"..fixMoney.."#ffffff$-ért.", 0, 0, 0, true)

				triggerServerEvent("points->FixVehicle", localPlayer, vehicle)

				toggleAllControls(true)
			end
		end
	end
end)

addEventHandler("onClientClick", root, function(key, state)
	if key == "left" and state == "down" and panelStates then
		if isCursorHover(screenSize.x/2 - 170, screenSize.y/2, 150, 30) then
			if getElementData(localPlayer, "char.Money") >= fixMoney then
				panelStates = false

				repairState = true
				startTick = getTickCount()

				toggleAllControls(false)
			else
				outputChatBox("#ff9428[CosmoMTA] #ffffffNincs elég pénzed a jármű javításához. #ff9428("..fixMoney..")", 0, 0, 0, true)
			end
		elseif isCursorHover(screenSize.x/2 + 20, screenSize.y/2, 150, 30) then
			panelStates = false
		end
	end
end)