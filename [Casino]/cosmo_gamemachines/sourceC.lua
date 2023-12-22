pcall(loadstring(base64Decode(exports.cosmo_core:getInterfaceElements())));addEventHandler("onCoreStarted",root,function(functions) for k,v in ipairs(functions) do _G[v]=nil;end;collectgarbage();pcall(loadstring(base64Decode(exports.cosmo_core:getInterfaceElements())));end)

local screenWidth, screenHeight = guiGetScreenSize()
local responsiveMultipler = exports.cosmo_hud:getResponsiveMultipler()

function resp(value)
	return value * responsiveMultipler
end

function respc(value)
	return math.ceil(value * responsiveMultipler)
end

function reMap(value, low1, high1, low2, high2)
	return (value - low1) * (high2 - low2) / (high1 - low1) + low2
end

local fontSizeMultipler = reMap(screenWidth, 1024, 1920, 0.7, 1)

local panelWidth = respc(230)
local panelHeight = respc(210)

local panelPosX = (screenWidth - panelWidth) / 2
local panelPosY = (screenHeight - panelHeight) / 2

local panelFont = false

local clickedMachineId = false
local clickedMachineElement = false

local activeButton = false
local selectedAmount = ""

local cursorState = false
local cursorStateChange = 0

local creatingMachineObject = false
local creatingMachineType = false

addCommandHandler("placegamemachine",
	function (commandName, gameTypeIndex)
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			if not creatingMachineObject then
				gameTypeIndex = tonumber(gameTypeIndex)

				if not gameTypeIndex then
					outputChatBox("#ff9428[Használat]: #FFFFFF/" .. commandName .. " [Típus]", 255, 255, 255, true)
					outputChatBox("#ff9428[Típusok]: #FFFFFFGold Rush (1), NEM JÓ (2), Western (3), Star Wars (4)", 255, 255, 255, true)
				else
					local gameTypeName = gameTypes[gameTypeIndex]

					if gameTypeName then
						creatingMachineType = gameTypeName
						creatingMachineObject = createObject(machineModels[gameTypeName], 0, 0, 0)

						setElementCollisionsEnabled(creatingMachineObject, false)
						setElementAlpha(creatingMachineObject, 175)
						setElementInterior(creatingMachineObject, getElementInterior(localPlayer))
						setElementDimension(creatingMachineObject, getElementDimension(localPlayer))

						addEventHandler("onClientRender", root, renderMachinePlacement)

						outputChatBox("#ff9428[CosmoMTA]: #ffffffJátékgép létrehozás #ffffffmód #ff9428bekapcsolva!", 255, 255, 255, true)
						outputChatBox("#ff9428[CosmoMTA]: #ffffffA játékgép #ff9428lerakásához #ffffffnyomd meg az #ff9428BAL ALT #ffffffgombot!", 255, 255, 255, true)
						outputChatBox("#ff9428[CosmoMTA]: #ffffffA #d75959kilépéshez #ffffffírd be a #d75959/" .. commandName .. " #ffffffparancsot!", 255, 255, 255, true)
					else
						outputChatBox("#d75959[CosmoMTA]: #ffffffÉrvénytelen játékgép típus.", 255, 255, 255, true)
					end
				end
			else
				removeEventHandler("onClientRender", root, renderMachinePlacement)

				if isElement(creatingMachineObject) then
					destroyElement(creatingMachineObject)
				end

				creatingMachineObject = nil
				creatingMachineType = false

				outputChatBox("#ff9428[CosmoMTA]: #ffffffJátékgép létrehozás #ffffffmód #d75959kikapcsolva!", 255, 255, 255, true)
			end
		end
	end
)

function renderMachinePlacement()
	if isElement(creatingMachineObject) then
		local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
		local playerRotX, playerRotY, playerRotZ = getElementRotation(localPlayer)

		playerPosZ = playerPosZ - 1
		playerPosZ = playerPosZ + getElementDistanceFromCentreOfMassToBaseOfModel(creatingMachineObject)

		setElementPosition(creatingMachineObject, playerPosX, playerPosY, playerPosZ)
		setElementRotation(creatingMachineObject, 0, 0, playerRotZ + 180)
	end

	if creatingMachineType then
		if getKeyState("lalt") then
			local objectPosX, objectPosY, objectPosZ = getElementPosition(creatingMachineObject)
			local objectRotX, objectRotY, objectRotZ = getElementRotation(creatingMachineObject)
			local playerInterior = getElementInterior(localPlayer)
			local playerDimension = getElementDimension(localPlayer)

			triggerServerEvent("placeGameMachine", resourceRoot, {
				gameType = creatingMachineType,
				posX = objectPosX,
				posY = objectPosY,
				posZ = objectPosZ,
				rotZ = objectRotZ,
				interior = playerInterior,
				dimension = playerDimension,
			})

			removeEventHandler("onClientRender", root, renderMachinePlacement)

			if isElement(creatingMachineObject) then
				destroyElement(creatingMachineObject)
			end

			creatingMachineObject = nil
			creatingMachineType = false
		end
	end
end

addCommandHandler("nearbygamemachine",
	function (commandName)
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			local createdMachineObjects = getElementsByType("object", resourceRoot, true)
			local nearbyGameMachines = {}

			local localX, localY, localZ = getElementPosition(localPlayer)
			local localInterior = getElementInterior(localPlayer)
			local localDimension = getElementDimension(localPlayer)

			for i = 1, #createdMachineObjects do
				local thisElement = createdMachineObjects[i]

				if isElement(thisElement) then
					local thisX, thisY, thisZ = getElementPosition(thisElement)
					local distanceBetween = getDistanceBetweenPoints3D(localX, localY, localZ, thisX, thisY, thisZ)

					if distanceBetween <= 15 then
						local thisInterior = getElementInterior(thisElement)
						local thisDimension = getElementDimension(thisElement)

						if thisInterior == localInterior and thisDimension == localDimension then
							local slotMachineId = getElementData(thisElement, "slotMachineId")

							if slotMachineId then
								table.insert(nearbyGameMachines, {slotMachineId, math.floor(distanceBetween * 1000) / 1000})
							end
						end
					end
				end
			end

			if #nearbyGameMachines > 0 then
				outputChatBox("#ff9428[CosmoMTA]: #ffffffA közeledben lévõ játékgépek (15 yard):", 255, 255, 255, true)

				for arrayIndex, arrayInfo in ipairs(nearbyGameMachines) do
					outputChatBox("    * #ff9428ID: #ffffff" .. arrayInfo[1] .. " <> #ff9428Távolság: #ffffff" .. arrayInfo[2], 255, 255, 255, true)
				end
			else
				outputChatBox("#d75959[CosmoMTA]: #ffffffA közeledben nem található egyetlen játékgép sem.", 255, 255, 255, true)
			end
		end
	end
)

addEventHandler("onClientClick", root,
	function (button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
		if not clickedMachineElement then
			if button == "right" then
				if state == "up" then
					if isElement(clickedElement) then
						local slotMachineId = getElementData(clickedElement, "slotMachineId")

						if slotMachineId then
							local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
							local targetPosX, targetPosY, targetPosZ = getElementPosition(clickedElement)

							if getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, targetPosX, targetPosY, targetPosZ) <= 1.5 then
								if not getElementData(localPlayer, "coinTransaction") then
									local slotMachineUser = getElementData(clickedElement, "slotMachineInUse")

									if not isElement(slotMachineUser) then
										clickedMachineId = slotMachineId
										clickedMachineElement = clickedElement

										if not panelFont then
											panelFont = dxCreateFont("files/Roboto.ttf", 12 * fontSizeMultipler, false, "antialiased")
										end

										panelPosX = absoluteX
										panelPosY = absoluteY

										activeButton = false
										selectedAmount = ""

										showCursor(true)

										addEventHandler("onClientRender", root, onRender)
										addEventHandler("onClientCharacter", root, onInputCharacter)
										addEventHandler("onClientKey", root, onKeyPress)
									else
										exports.cosmo_hud:showInfobox("error", "Ez a játékgép használatban van!")
									end
								else
									exports.cosmo_hud:showInfobox("error", "Kérlek várj egy kicsit!")
								end
							end
						end
					end
				end
			end
		else
			if button == "left" then
				if state == "down" then
					if activeButton then
						showCursor(false)

						removeEventHandler("onClientRender", root, onRender)
						removeEventHandler("onClientCharacter", root, onInputCharacter)
						removeEventHandler("onClientKey", root, onKeyPress)

						if activeButton == "play" then
							triggerServerEvent("requestGameOpen", resourceRoot, clickedMachineId)
						elseif activeButton == "deposit" or activeButton == "withdraw" then
							local creditAmount = tonumber(selectedAmount) or 0

							if creditAmount > 0 then
								triggerServerEvent("requestTransaction", resourceRoot, clickedMachineId, activeButton, creditAmount)
							else
								exports.cosmo_hud:showInfobox("error", "Minimum 1db zsetont kell megadnod.")
							end
						end

						clickedMachineId = false
						clickedMachineElement = false

						if isElement(panelFont) then
							destroyElement(panelFont)
						end

						panelFont = nil
					end
				end
			end
		end
	end
)

function onInputCharacter(character)
	if utfLen(selectedAmount) < 7 then
		if string.find(character, "[0-9]") then
			selectedAmount = selectedAmount .. character
		end
	end
end

function onKeyPress(keyName, isPressed)
	if isPressed then
		if keyName == "backspace" then
			if utfLen(selectedAmount) >= 1 then
				selectedAmount = utfSub(selectedAmount, 1, -2)
			end
		elseif keyName ~= "escape" then
			cancelEvent()
		end
	end
end

function onRender()
	local buttons = {}
	local absX, absY = 0, 0

	if isCursorShowing() then
		local relX, relY = getCursorPosition()

		absX = relX * screenWidth
		absY = relY * screenHeight
	end

	-- ** Háttér
	dxDrawRectangle(panelPosX, panelPosY, panelWidth, panelHeight, tocolor(0, 0, 0, 150))

	-- ** Keret
	dxDrawRectangle(panelPosX, panelPosY - 2, panelWidth, 2, tocolor(0, 0, 0, 130)) -- felső
	dxDrawRectangle(panelPosX, panelPosY + panelHeight, panelWidth, 2, tocolor(0, 0, 0, 130)) -- alsó
	dxDrawRectangle(panelPosX - 2, panelPosY - 2, 2, panelHeight + 4, tocolor(0, 0, 0, 130)) -- bal
	dxDrawRectangle(panelPosX + panelWidth, panelPosY - 2, 2, panelHeight + 4, tocolor(0, 0, 0, 130)) -- jobb

	-- ** Játék indítása
	buttons.play = {panelPosX + respc(5), panelPosY + panelHeight - respc(40) * 5, panelWidth - respc(10), respc(30)}
	if activeButton == "play" then
		dxDrawRectangle(buttons.play[1], buttons.play[2], buttons.play[3], buttons.play[4], tocolor(255, 148, 40, 255))
	else
		--dxDrawRectangle(buttons.play[1], buttons.play[2], buttons.play[3], buttons.play[4], tocolor(89, 142, 215, 160))
	end
	drawButton2("play", "Játék", panelPosX + respc(5), panelPosY + panelHeight - respc(40) * 5, panelWidth - respc(10), respc(30), 255,148,40, 1, exports.cosmo_assets:loadFont("Roboto-Regular.ttf", respc(14)), 1)

	-- ** Mennyiség megadása
	local amountInput = {panelPosX + respc(5), panelPosY + panelHeight - respc(40) * 4, panelWidth - respc(10), respc(30)}
	local amountString = "Zseton: " .. thousandsStepper(selectedAmount)

	dxDrawRectangle(amountInput[1], amountInput[2], amountInput[3], amountInput[4], tocolor(0, 0, 0, 130))
	dxDrawText(amountString, amountInput[1] + respc(10), amountInput[2], amountInput[1] + amountInput[3] - respc(20), amountInput[2] + amountInput[4], tocolor(255, 255, 255), 1, panelFont, "left", "center")

	if getTickCount() >= cursorStateChange + 500 then
		cursorState = not cursorState
		cursorStateChange = getTickCount()
	end

	if cursorState then
		local textWidth = dxGetTextWidth(amountString, 1, panelFont) + respc(2)

		if textWidth then
			dxDrawRectangle(amountInput[1] + respc(10) + textWidth, amountInput[2] + respc(10), 1, amountInput[4] - respc(20), tocolor(255, 255, 255))
		end
	end

	-- ** Befizetés
	buttons.deposit = {panelPosX + respc(5), panelPosY + panelHeight - respc(40) * 3, panelWidth - respc(10), respc(30)}
	if activeButton == "deposit" then
		dxDrawRectangle(buttons.deposit[1], buttons.deposit[2], buttons.deposit[3], buttons.deposit[4], tocolor(255, 148, 40, 255))
	else
		--dxDrawRectangle(buttons.deposit[1], buttons.deposit[2], buttons.deposit[3], buttons.deposit[4], tocolor(255, 148, 40, 160))
	end
	drawButton2("deposit", "Befizetés", panelPosX + respc(5), panelPosY + panelHeight - respc(40) * 3, panelWidth - respc(10), respc(30), 255,148,40, 1, exports.cosmo_assets:loadFont("Roboto-Regular.ttf", respc(14)), 1)
	--dxDrawText("Befizetés", buttons.deposit[1], buttons.deposit[2], buttons.deposit[1] + buttons.deposit[3], buttons.deposit[2] + buttons.deposit[4], tocolor(0, 0, 0), 1, panelFont, "center", "center")

	-- ** Kifizetés
	buttons.withdraw = {panelPosX + respc(5), panelPosY + panelHeight - respc(40) * 2, panelWidth - respc(10), respc(30)}
	if activeButton == "withdraw" then
		dxDrawRectangle(buttons.withdraw[1], buttons.withdraw[2], buttons.withdraw[3], buttons.withdraw[4], tocolor(255, 148, 40, 255))
	else
		--dxDrawRectangle(buttons.withdraw[1], buttons.withdraw[2], buttons.withdraw[3], buttons.withdraw[4], tocolor(255, 148, 40, 160))
	end
	drawButton2("withdraw", "Kifizetés", panelPosX + respc(5), panelPosY + panelHeight - respc(40) * 2, panelWidth - respc(10), respc(30), 255,148,40, 1, exports.cosmo_assets:loadFont("Roboto-Regular.ttf", respc(14)), 1)
	--dxDrawText("Kifizetés", buttons.withdraw[1], buttons.withdraw[2], buttons.withdraw[1] + buttons.withdraw[3], buttons.withdraw[2] + buttons.withdraw[4], tocolor(0, 0, 0), 1, panelFont, "center", "center")

	-- ** Bezárás
	buttons.exit = {panelPosX + respc(5), panelPosY + panelHeight - respc(40), panelWidth - respc(10), respc(30)}
	if activeButton == "exit" then
		dxDrawRectangle(buttons.exit[1], buttons.exit[2], buttons.exit[3], buttons.exit[4], tocolor(255, 148, 40, 255))
	else
		--dxDrawRectangle(buttons.exit[1], buttons.exit[2], buttons.exit[3], buttons.exit[4], tocolor(215, 89, 89, 160))
	end
	drawButton2("exit", "Kilépés", panelPosX + respc(5), panelPosY + panelHeight - respc(40), panelWidth - respc(10), respc(30), 255,148,40, 1, exports.cosmo_assets:loadFont("Roboto-Regular.ttf", respc(14)), 1)
	--dxDrawText("Kilépés", buttons.exit[1], buttons.exit[2], buttons.exit[1] + buttons.exit[3], buttons.exit[2] + buttons.exit[4], tocolor(0, 0, 0), 1, panelFont, "center", "center")

	-- ** Gombok kezelése
	activeButton = false

	for buttonKey, buttonInfo in pairs(buttons) do
		if absX >= buttonInfo[1] and absX <= buttonInfo[1] + buttonInfo[3] and absY >= buttonInfo[2] and absY <= buttonInfo[2] + buttonInfo[4] then
			activeButton = buttonKey
			break
		end
	end
end

function thousandsStepper(amount)
	local formatted = tostring(amount)
	local counter = 0

	while true do
		formatted, counter = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1 %2")

		if counter == 0 then
			break
		end
	end

	return formatted
end