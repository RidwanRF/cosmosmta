local screenSize = {guiGetScreenSize()}
screenSize.x, screenSize.y = screenSize[1], screenSize[2]

local bgColor = tocolor(0, 0, 0, 180)
local slotColor = tocolor(40, 40, 40, 200)

local hoverColor = tocolor(255, 148, 40, 180)
local cancelColor = tocolor(243, 85, 85, 180)

local markers = {
	{1765.0189208984+0.6, -2286.2160644531, 26.796022415161},
}
local createdMarkersHeli = {}

for key, value in ipairs(markers) do
	createdMarkersHeli[key] = createMarker(value[1], value[2], value[3] - 1, "cylinder", 3, 0, 174, 235, 150)
	setElementData(createdMarkersHeli[key], "points->FixMarker->Heli", true)
end

local roboto = dxCreateFont("files/Roboto.ttf", 9)
local roboto2 = dxCreateFont("files/Roboto.ttf", 15)
local panelSzereles = false
local panelTankolas = false
local panelStatesValasztas = false

addEventHandler("onClientMarkerHit", root, function(player)
	if player == localPlayer and getElementData(source, "points->FixMarker->Heli") then
		vehicle = getPedOccupiedVehicle(localPlayer)

		if vehicle and getPedOccupiedVehicleSeat(localPlayer) == 0 then
			panelStatesValasztas = true
			setElementFrozen(vehicle,true)
			setCameraMatrix(1759.1802978516, -2277.8137207031, 26.796022415161,1765.4593505859, -2285.8278808594, 26.796022415161)
			setElementPosition(vehicle,1766.0512695312, -2286.8269042969, 26.796022415161)
			setElementRotation(vehicle, 0,0,0)
			executeCommandHandler ( "toghud")
			--fixMoney = math.floor((exports.exg_carshop:getVehicleShopCost(getElementModel(vehicle)) or 10000) / getElementHealth(vehicle) * 4) 
			if getElementData(vehicle, "vehicle.group") == 1 or getElementData(vehicle, "vehicle.group") == 4 or getElementData(vehicle, "vehicle.group") == 11 then
				fixMoney = 0
			else
				fixMoney = 300000
				--fixMoney = getElementHealth(vehicle) * 500 
			end
		end
	end
end)

local colorPicker = {{0,0,0}}
local x, y = guiGetScreenSize()
oX, oY = 1280, 720

addEventHandler("onClientRender", root, function()
	if panelStatesValasztas then
		dxDrawRectangle(50, screenSize.y/2 - 75, 400, 50, tocolor(40, 40, 40, 255))
		
		dxDrawRectangle(50, screenSize.y/2 - 25, 400, 50, tocolor(60,60,60,255))
		
		
		dxDrawRectangle(50, screenSize.y/2 - 25 + 50, 400, 50, tocolor(40,40,40,255))

		dxDrawText("Javítás", 50, screenSize.y/2 - 65, 50+100, 0, tocolor(255, 255, 255), 1, roboto2, "center", "top", false, false, false, true)
		
		dxDrawText("Tankolás", 50, screenSize.y/2 - 15, 50+110, 0, tocolor(255, 255, 255), 1, roboto2, "center", "top", false, false, false, true)
		
		
		dxDrawText("Színezés", 50, screenSize.y/2 - 15 + 50, 50+110, 0, tocolor(255, 255, 255), 1, roboto2, "center", "top", false, false, false, true)
	
	
		if isCursorHover(50, screenSize.y/2 - 75, 400, 50) then
			dxDrawRectangle(50, screenSize.y/2 - 75, 400, 50, tocolor(255, 148, 40, 255))
			dxDrawText("Javítás", 50, screenSize.y/2 - 65, 50+100, 0, tocolor(0, 0, 0), 1, roboto2, "center", "top", false, false, false, true)
		end
		
		if isCursorHover(50, screenSize.y/2 - 25, 400, 50) then
			dxDrawRectangle(50, screenSize.y/2 - 25, 400, 50, tocolor(255, 148, 40,255))
			dxDrawText("Tankolás", 50, screenSize.y/2 - 15, 50+110, 0, tocolor(0, 0, 0), 1, roboto2, "center", "top", false, false, false, true)
		end
		
		if isCursorHover(50, screenSize.y/2 - 25 + 50, 400, 50) then
			dxDrawRectangle(50, screenSize.y/2 - 25 + 50, 400, 50, tocolor(255, 148, 40,255))
			dxDrawText("Színezés", 50, screenSize.y/2 - 15 + 50, 50+110, 0, tocolor(0, 0, 0), 1, roboto2, "center", "top", false, false, false, true)
		end
		
		if colortallit then
        dxDrawRectangle(480, 415/oY*y, 190/oX*x, 25/oY*y, tocolor(0,0,0,255))
		dxDrawText("Szín megvásárlás", 480, 415/oY*y, 480+280, 415/oY*y+24, tocolor(255, 255, 255), 1, roboto2, "center", "center", false, false, false, true)
		dxDrawText("200.000$", 480, 415/oY*y, 480+280, 415/oY*y+60, tocolor(255, 255, 255), 1, roboto, "center", "center", false, false, false, true)
		end
	end
end)

colortallit = false

addEventHandler("onClientClick", root, function(key, state)
	if key == "left" and state == "down" and panelStatesValasztas then
		if isCursorHover(50, screenSize.y/2 - 75, 400, 50) then
			if not repairState then
				if not panelSzereles then
					print("Javítás")
						if colortallit then
							destroyColorPicker()
							colortallit = false
						end	
						if panelTankolas then
							panelTankolas = false
						end
					if getElementHealth(vehicle) >= 990 then
						outputChatBox("#ff9428[CosmoMTA] #ffffffA járműved nem sérült.", 0, 0, 0, true)
					else
						panelSzereles = true
					end	
				end	
			end	
		elseif isCursorHover(50, screenSize.y/2 - 25, 400, 50) then
			if not tankolasState then
				if not panelTankolas then
					print("Tankolás")
						if colortallit then
							destroyColorPicker()
							colortallit = false
						end	
						if panelSzereles then
							panelSzereles = false
						end
						panelTankolas = true
				end	
			end	
		elseif isCursorHover(50, screenSize.y/2 - 25 + 50, 400, 50) then
			if not colortallit then
				if not repairState then
					if not panelSzereles then
						if not tankolasState then
							if not panelTankolas then
								print("Festés")
								picker = createColorPicker(colorPicker[1],480, 300/oY*y, 190/oX*x, 100/oY*y, "color1")
								colortallit = true
							else
								panelTankolas = false
							end
						end
					else
						panelSzereles = false
					end	
				end		
			end	
		elseif isCursorHover(480, 415/oY*y, 190/oX*x, 25/oY*y) then
			if colortallit then
				if getElementData(localPlayer, "char.Money") >= 200000 then
					setElementData(localPlayer, "char.Money", getElementData(localPlayer, "char.Money") - 200000)
					local tr,tg,tb = getPaletteColor()
					setVehicleColor(vehicle,tr,tg,tb)
				end
			end
		end
	end
end)


addEventHandler("onClientRender", root, function()
	if panelSzereles then
		dxDrawRectangle(screenSize.x/2 - 200, screenSize.y/2 - 50, 400, 100, bgColor)
		dxDrawRectangle(screenSize.x/2 - 200, screenSize.y/2 + 50, 400, 2, hoverColor)

		dxDrawText("Szeretnéd megjavítani a járművedet?\nJavítás ára : #ff9428" .. convertNumber(fixMoney).."$", screenSize.x/2 - 200, screenSize.y/2 - 45, screenSize.x/2 + 200, 0, tocolor(255, 255, 255), 1, roboto, "center", "top", false, false, false, true)
	
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
			if delayTime < 8000 then
				progTime = delayTime / 8000
				panelX = interpolateBetween(0, 0, 0, 250, 0, 0, progTime, "Linear")

				dxDrawRectangle(screenSize.x/2 - 250/2 - 2, screenSize.y/2 - 10, 254, 20, bgColor)
				dxDrawRectangle(screenSize.x/2 - 250/2, screenSize.y/2 - 8, 250, 16, slotColor)
				dxDrawRectangle(screenSize.x/2 - 250/2, screenSize.y/2 - 8, panelX, 16, hoverColor)

				dxDrawText("Szerelés folyamatban...", 0, 0, screenSize.x, screenSize.y, tocolor(255, 255, 255), 1, roboto, "center", "center")
			else
				repairState = false

				setElementData(localPlayer, "char.Money", getElementData(localPlayer, "char.Money") - fixMoney)
				outputChatBox("#ff9428[CosmoMTA] #ffffffSikeresen megjavíttattad a járműved #7cc576$"..convertNumber(fixMoney).."#ffffff-ért.", 0, 0, 0, true)

				triggerServerEvent("points->FixVehicle->Heli", localPlayer, vehicle)

				toggleAllControls(true)
			end
		end
	elseif panelTankolas then
		dxDrawRectangle(screenSize.x/2 - 200, screenSize.y/2 - 50, 400, 100, bgColor)
		dxDrawRectangle(screenSize.x/2 - 200, screenSize.y/2 + 50, 400, 2, hoverColor)

		dxDrawText("Szeretnéd megtankolni a járművedet?\nTankolás ára : #ff9428200.000$", screenSize.x/2 - 200, screenSize.y/2 - 45, screenSize.x/2 + 200, 0, tocolor(255, 255, 255), 1, roboto, "center", "top", false, false, false, true)
	
		dxDrawRectangle(screenSize.x/2 - 170, screenSize.y/2, 150, 30, slotColor)
		dxDrawText("Tankolás", screenSize.x/2 - 170, screenSize.y/2, screenSize.x/2 - 20, screenSize.y/2 + 30, tocolor(255, 255, 255), 1, roboto, "center", "center")
	
		if isCursorHover(screenSize.x/2 - 170, screenSize.y/2, 150, 30) then
			dxDrawRectangle(screenSize.x/2 - 170, screenSize.y/2, 150, 30, hoverColor)
			dxDrawText("Tankolás", screenSize.x/2 - 170, screenSize.y/2, screenSize.x/2 - 20, screenSize.y/2 + 30, tocolor(0, 0, 0), 1, roboto, "center", "center")
		end

		dxDrawRectangle(screenSize.x/2 + 20, screenSize.y/2, 150, 30, slotColor)
		dxDrawText("Kilépés", screenSize.x/2 + 20, screenSize.y/2, screenSize.x/2 + 170, screenSize.y/2 + 30, tocolor(255, 255, 255), 1, roboto, "center", "center")
	
		if isCursorHover(screenSize.x/2 + 20, screenSize.y/2, 150, 30) then
			dxDrawRectangle(screenSize.x/2 + 20, screenSize.y/2, 150, 30, cancelColor)
			dxDrawText("Kilépés", screenSize.x/2 + 20, screenSize.y/2, screenSize.x/2 + 170, screenSize.y/2 + 30, tocolor(0, 0, 0), 1, roboto, "center", "center")
		end
	elseif tankolasState then
		if getTickCount() >= startTick then
			local delayTime = getTickCount() - startTick
			if delayTime < 8000 then
				progTime = delayTime / 8000
				panelX = interpolateBetween(0, 0, 0, 250, 0, 0, progTime, "Linear")

				dxDrawRectangle(screenSize.x/2 - 250/2 - 2, screenSize.y/2 - 10, 254, 20, bgColor)
				dxDrawRectangle(screenSize.x/2 - 250/2, screenSize.y/2 - 8, 250, 16, slotColor)
				dxDrawRectangle(screenSize.x/2 - 250/2, screenSize.y/2 - 8, panelX, 16, hoverColor)

				dxDrawText("Tankolás folyamatban...", 0, 0, screenSize.x, screenSize.y, tocolor(255, 255, 255), 1, roboto, "center", "center")
			else
				tankolasState = false

				setElementData(localPlayer, "char.Money", getElementData(localPlayer, "char.Money") - 200000)
				outputChatBox("#ff9428[CosmoMTA] #ffffffSikeresen megtankoltad a járműved #7cc576200.000$#ffffff-ért.", 0, 0, 0, true)

				triggerServerEvent("points->FuelVehicle->Heli", localPlayer, vehicle)

				toggleAllControls(true)
			end
		end
	end	
end)

addEventHandler("onClientClick", root, function(key, state)
	if key == "left" and state == "down" and panelSzereles then
		if isCursorHover(screenSize.x/2 - 170, screenSize.y/2, 150, 30) then
			if getElementData(localPlayer, "char.Money") >= fixMoney then
				panelSzereles = false

				repairState = true
				startTick = getTickCount()

				toggleAllControls(false)
			else
				outputChatBox("#ff9428[CosmoMTA] #ffffffNincs elég pénzed a jármű javításához. #7cc576($"..fixMoney..")", 0, 0, 0, true)
			end
		elseif isCursorHover(screenSize.x/2 + 20, screenSize.y/2, 150, 30) then
			panelSzereles = false
		end
	end
end)

addEventHandler("onClientClick", root, function(key, state)
	if key == "left" and state == "down" and panelTankolas then
		if isCursorHover(screenSize.x/2 - 170, screenSize.y/2, 150, 30) then
			if getElementData(localPlayer, "char.Money") >= 200000 then
				panelTankolas = false

				tankolasState = true
				startTick = getTickCount()

				toggleAllControls(false)
			else
				outputChatBox("#ff9428[CosmoMTA] #ffffffNincs elég pénzed a jármű tankolásához. #7cc576($200.000)", 0, 0, 0, true)
			end
		elseif isCursorHover(screenSize.x/2 + 20, screenSize.y/2, 150, 30) then
			panelTankolas = false
		end
	end
end)

bindKey("backspace", "down", function()
	if panelStatesValasztas then
		if not tankolasState then
			if not repairState then
				executeCommandHandler ( "toghud")
				panelStatesValasztas = false
				setElementFrozen(vehicle,false)
				setCameraTarget(localPlayer)
				if colortallit then
					destroyColorPicker()
					colortallit = false
				end	
				if panelSzereles then
					panelSzereles = false
				end
				if panelTankolas then
					panelTankolas = false
				end
			end	
		end	
	end
end)


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

function convertNumber(number)  
	local formatted = number;
	while true do      
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2'); 
		if (k==0) then      
			break;
		end  
	end  
	return formatted;
end