pcall(loadstring(base64Decode(exports.cosmo_core:getInterfaceElements())));addEventHandler("onCoreStarted",root,function(functions) for k,v in ipairs(functions) do _G[v]=nil;end;collectgarbage();pcall(loadstring(base64Decode(exports.cosmo_core:getInterfaceElements())));end)

local screenX, screenY = guiGetScreenSize()

function respc(num)
	return num
end

local placedTable = false

exports.cosmo_admin:addAdminCommand("createroulette", 9, "Roulette létrehozása")
addCommandHandler("createroulette",
	function (commandName)
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			if not placedTable then
				if isElement(placedTable) then
					destroyElement(placedTable)
				end

				placedTable = createObject(1978, 0, 0, 0)

				setElementCollisionsEnabled(placedTable, false)
				setElementAlpha(placedTable, 175)
				setElementInterior(placedTable, getElementInterior(localPlayer))
				setElementDimension(placedTable, getElementDimension(localPlayer))

				addEventHandler("onClientRender", getRootElement(), tablePlaceRender)
				addEventHandler("onClientKey", getRootElement(), tablePlaceKey)

				outputChatBox("#ff9428[CosmoMTA - Rulett]: #ffffffRulett asztal létrehozás mód #ff9428bekapcsolva!", 255, 255, 255, true)
				outputChatBox("#ff9428[CosmoMTA - Rulett]: #ffffffAz asztal #ff9428lerakásához #ffffffnyomd meg az #ff9428BAL CTRL #ffffffgombot.", 255, 255, 255, true)
				outputChatBox("#ff9428[CosmoMTA - Rulett]: #ffffffA #d75959kilépéshez #ffffffírd be a #d75959/" .. commandName .. " #ffffffparancsot.", 255, 255, 255, true)
			else
				removeEventHandler("onClientRender", getRootElement(), tablePlaceRender)
				removeEventHandler("onClientKey", getRootElement(), tablePlaceKey)

				if isElement(placedTable) then
					destroyElement(placedTable)
				end
				placedTable = nil

				outputChatBox("#ff9428[CosmoMTA - Rulett]: #ffffffRulett asztal létrehozás mód #d75959kikapcsolva!", 255, 255, 255, true)
			end
		end
	end)

function tablePlaceRender()
	if placedTable then
		local x, y, z = getElementPosition(localPlayer)
		local rz = select(3, getElementRotation(localPlayer))
		
		setElementPosition(placedTable, x, y, z + 0.075)
		setElementRotation(placedTable, 0, 0, rz + 90)
	end
end

function tablePlaceKey(button, state)
	if isElement(placedTable) then
		if button == "lctrl" and state then
			local x, y, z = getElementPosition(placedTable)
			local rz = select(3, getElementRotation(placedTable))
			local interior = getElementInterior(placedTable)
			local dimension = getElementDimension(placedTable)

			triggerServerEvent("placeTheRouletteTable", localPlayer, {x, y, z - 0.075, rz, interior, dimension})

			if isElement(placedTable) then
				destroyElement(placedTable)
			end
			placedTable = nil

			removeEventHandler("onClientRender", getRootElement(), tablePlaceRender)
			removeEventHandler("onClientKey", getRootElement(), tablePlaceKey)
		end
	end
end

exports.cosmo_admin:addAdminCommand("nearbyroulette", 9, "Közeledben lévő roulette asztal")
addCommandHandler("nearbyroulette",
	function (commandName, maxDistance)
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			local playerX, playerY, playerZ = getElementPosition(localPlayer)
			local nearbyList = {}

			maxDistance = tonumber(maxDistance) or 15

			for i, v in ipairs(getElementsByType("object", resourceRoot, true)) do
				local tableId = getElementData(v, "isRoulette")

				if tableId then
					local targetX, targetY, targetZ = getElementPosition(v)
					local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ)

					if distance <= maxDistance then
						table.insert(nearbyList, {tableId, distance})
					end
				end
			end

			if #nearbyList > 0 then
				outputChatBox("#ff9428[CosmoMTA - Rulett]: #ffffffKözeledben lévő asztalok (" .. maxDistance .. " yard):", 255, 255, 255, true)

				for i, v in ipairs(nearbyList) do
					outputChatBox("    * #ff9428Azonosító: #ffffff" .. v[1] .. " - " .. math.floor(v[2] * 1000) / 1000 .. " yard", 255, 255, 255, true)
				end
			else
				outputChatBox("#d75959[CosmoMTA - Rulett]: #ffffffNincs egyetlen asztal sem a közeledben.", 255, 255, 255, true)
			end
		end
	end)

local rouletteEffects = {}
local defaultWheelNum = getRealTime().monthday

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		if getElementData(localPlayer, "playerUsingRoulette") then
			setElementData(localPlayer, "playerUsingRoulette", false)
		end

        local sound = playSound3D ("files/jazz.mp3",1210.8082275391, -8.419732093811, 1000.921875,true)
        setElementInterior(sound, 2)
        setElementDimension(sound, 1043)
        setSoundMaxDistance (sound, 50)


        engineImportTXD (engineLoadTXD ("files/kbroul1.txd"), 1978)
		engineImportTXD (engineLoadTXD ("files/chips/chips.txd"), 1858)
		engineImportTXD (engineLoadTXD ("files/chips/chips.txd"), 1857)
		engineImportTXD (engineLoadTXD ("files/chips/chips.txd"), 1856)
		engineImportTXD (engineLoadTXD ("files/chips/chips.txd"), 1855)
		engineImportTXD (engineLoadTXD ("files/chips/chips.txd"), 1854)
		engineImportTXD (engineLoadTXD ("files/chips/chips.txd"), 1853)
	end)

addEventHandler("onClientElementStreamIn", getResourceRootElement(),
	function ()
		local tableId = getElementData(source, "isRoulette")

		if tableId then
			processRouletteEffects(source)
		end
	end)

addEventHandler("onClientElementStreamOut", getResourceRootElement(),
	function ()
		if rouletteEffects[source] then
			for k, v in pairs(rouletteEffects[source]) do
				if isElement(v) then
					destroyElement(v)
				end
			end

			rouletteEffects[source] = nil
		end
	end)

addEventHandler("onClientElementDestroy", getResourceRootElement(),
	function ()
		if rouletteEffects[source] then
			for k, v in pairs(rouletteEffects[source]) do
				if isElement(v) then
					destroyElement(v)
				end
			end

			rouletteEffects[source] = nil
		end
	end)

function processRouletteEffects(element)
	local tableX, tableY, tableZ = getElementPosition(element)
	local tableRotation = select(3, getElementRotation(element))
	local tableInterior = getElementInterior(element)
	local tableDimension = getElementDimension(element)

	rouletteEffects[element] = {}

	local x, y = rotateAround(tableRotation, -0.195, 1.35)
	local obj = createObject(1979, tableX + x, tableY + y, tableZ - 0.025, 0, 0, tableRotation)

	setElementInterior(obj, tableInterior)
	setElementDimension(obj, tableDimension)
	setElementDoubleSided(obj, true)

	rouletteEffects[element].wheel = obj

	local obj = createObject(3003, tableX + x, tableY + y, tableZ + 0.05, 0, 0, tableRotation)

	setElementInterior(obj, tableInterior)
	setElementDimension(obj, tableDimension)
	setObjectScale(obj, 0.4)
	setElementCollisionsEnabled(obj, false)

	rouletteEffects[element].ball = obj

	local x, y = rotateAround(tableRotation, 1.55, 1.5)
	local ped = createPed(171, tableX + x, tableY + y, tableZ, tableRotation + 90)

	setElementInterior(ped, tableInterior)
	setElementDimension(ped, tableDimension)
	setElementCollidableWith(ped, element, false)
	setTimer(isSetElementFrozen, 1500, 1, ped, true)
	setTimer(isSetPedAnimation, 1750, 1, ped, "CASINO", "Roulette_loop", -1, true, false, false, false)
	
    setElementData(ped, "ped.name", "Krupié")
    setElementData(ped, "ped.type", 0)
    setElementData(ped, "ped.subtype", 0) 
    setElementData(ped, "invulnerable", true)

	rouletteEffects[element].ped = ped

	local num = getElementData(element, "theRouletteNum")

	if not num then
		num = defaultWheelNum
	end

	rouletteEffects[element].interpolation = {wheelNumbers[num] * degPerNum, num}
end

function isSetElementFrozen(element, state)
	if isElement(element) then
		setElementFrozen(element, state)
	end
end

function isSetPedAnimation(element, ...)
	if isElement(element) then
		setPedAnimation(element, ...)
	end
end

addEventHandler("onClientRender", getRootElement(),
	function ()
		local now = getTickCount()
		local rot = -now / 50

		for k, v in pairs(rouletteEffects) do
			setElementRotation(v.wheel, 0, 0, rot)

			if v.interpolation then
				local wheelX, wheelY, wheelZ = getElementPosition(v.wheel)
				local wheelRot = select(3, getElementRotation(v.wheel))

				wheelRot = wheelRot - 135

				local angle = 0
				local x, z = 0, 0

				if tonumber(v.interpolation[1]) then
					angle = wheelRot - v.interpolation[1]
				else
					local elapsedTime = now - v.interpolation[2]
					local progress = interpolateBetween(0, 0, 0, 1, 0, 0, elapsedTime / 11000, "InOutQuad")

					angle = interpolateBetween(wheelRot - v.interpolation[3], 0, 0, wheelRot - v.interpolation[4], 0, 0, progress, "OutBack", 0.3, 1, 2)

					local progress = (elapsedTime - 5000) / 3500
					local progress2 = 0

					if progress > 0 then
						progress2 = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "InOutQuad")
					end

					x, z = interpolateBetween(0.15, 0.075, 0, 0.025, 0.025, 0, progress2, "OutBack", 0.3, 1, 4)

					local progress = (elapsedTime - 8000) / 500
					if progress > 0 then
						x, z = interpolateBetween(0.025, 0.025, 0, 0, 0, 0, progress, "Linear")
					end

					if progress >= 5 then
						rouletteEffects[k].interpolation = {v.interpolation[4], v.interpolation[5]}
					end
				end

				local rotatedX, rotatedY = rotateAround(angle, -0.23 - x, 0)

				setElementPosition(v.ball, wheelX + rotatedX, wheelY + rotatedY, wheelZ - 0.055 + z)
			end
		end
	end)

local mySlotCoins = 0
local myCharId = false

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if source == localPlayer then
			if dataName == "char.ucoin" then
				mySlotCoins = getElementData(source, dataName) or 0
			end
		end

		if dataName == "theRouletteNum" then
			if isElementStreamedIn(source) then
				local theNumber = getElementData(source, "theRouletteNum")
				local oldNumber = 0

				if rouletteEffects[source] and rouletteEffects[source].interpolation then
					oldNumber = rouletteEffects[source].interpolation[2] or 0
				end
			
				rouletteEffects[source].interpolation = {true, getTickCount(), wheelNumbers[oldNumber] * degPerNum, wheelNumbers[theNumber] * degPerNum - 1080, theNumber}
			end
		end
	end)

local tableWidth = respc(734)
local tableHeight = respc(268)

local chipSize = respc(24)
local chipPotSize = respc(32)

local panelWidth = tableWidth + respc(10)
local panelHeight = tableHeight + respc(50) + chipPotSize + respc(204)
local panelPosX = screenX / 2 - panelWidth / 2
local panelPosY = screenY / 2 - panelHeight / 2

local draggingPanel = false
local movedChip = false

local standingTableId = false
local standingTableObj = false

local cantExitNotiState = false
local ballInterpolation = false

local Roboto = false
local gtaFont = false
local tooltipFont = false

local timeLeft = false
local havePlacedBets = false

local availableCoins = {
	[1] = 1,
	[2] = 5,
	[3] = 25,
	[4] = 50,
	[5] = 100,
	[6] = 500
}

local blockPosition = {respc(284), respc(25), respc(692), respc(167)} -- startX, startY, endX, endY
local blockSizeX = (blockPosition[3] - blockPosition[1]) / 12
local blockSizeY = (blockPosition[4] - blockPosition[2]) / 3

local fieldPositions = {
	{"0", respc(230), blockPosition[2], respc(52), respc(141)},

	{"1st12", blockPosition[1], blockPosition[4] + respc(1), blockSizeX * 4, respc(36)},
	{"2nd12", blockPosition[1] + blockSizeX * 4, blockPosition[4] + respc(1), blockSizeX * 4, respc(36)},
	{"3rd12", blockPosition[1] + blockSizeX * 8, blockPosition[4] + respc(1), blockSizeX * 4, respc(36)},

	{"1-18", blockPosition[1], blockPosition[4] + respc(37), blockSizeX * 2, respc(35)},
	{"even", blockPosition[1] + blockSizeX * 2, blockPosition[4] + respc(37), blockSizeX * 2, respc(35)},
	{"red", blockPosition[1] + blockSizeX * 4, blockPosition[4] + respc(37), blockSizeX * 2, respc(35)},
	{"black", blockPosition[1] + blockSizeX * 6, blockPosition[4] + respc(37), blockSizeX * 2, respc(35)},
	{"odd", blockPosition[1] + blockSizeX * 8, blockPosition[4] + respc(37), blockSizeX * 2, respc(35)},
	{"19-36", blockPosition[1] + blockSizeX * 10, blockPosition[4] + respc(37), blockSizeX * 2, respc(35)},

	{"2to3", blockPosition[3], blockPosition[2], blockSizeX, blockSizeY},
	{"2to2", blockPosition[3], blockPosition[2] + blockSizeY, blockSizeX, blockSizeY},
	{"2to1", blockPosition[3], blockPosition[2] + blockSizeY * 2, blockSizeX, blockSizeY}
}

for i = 0, 12 * 3 - 1 do
	local x = math.floor(i / 3)
	local y = i % 3

	table.insert(fieldPositions, {
		tostring(x * 3 + (3 - y)),
		blockPosition[1] + blockSizeX * x,
		blockPosition[2] + blockSizeY * y,
		blockSizeX,
		blockSizeY
	})
end

local hoverFields = {}
local hoverFieldDatas = {}

local topBets = {}
local allBets = {}
local myBets = {}

local clickTick = 0
local activeBetField = false
local betRemovingProcess = false

local betsHistory = ""
local roundHistory = ""

addEvent("openRouletteTable", true)
addEventHandler("openRouletteTable", getRootElement(),
	function (tableId, element, theNumber, fieldBets, actions, history, roundTime)
		if not theNumber then
			theNumber = defaultWheelNum
		end

		standingTableId = tableId
		standingTableObj = element
		ballInterpolation = {0, wheelNumbers[theNumber] * degPerNum, wheelNumbers[theNumber] * degPerNum - 1080, theNumber}

		Roboto = dxCreateFont("files/Roboto.ttf", respc(14), false, "antialiased")
		gtaFont = dxCreateFont("files/gtaFont.ttf", respc(20), false, "antialiased")
		tooltipFont = dxCreateFont("files/Roboto.ttf", respc(18), false, "antialiased")

		mySlotCoins = getElementData(localPlayer, "char.ucoin") or 0
		myCharId = getElementData(source, "acc.ID")

		triggerEvent("onPlayerRouletteRefresh", localPlayer, fieldBets, actions, history, roundTime)

		showCursor(true)
		addEventHandler("onClientRender", getRootElement(), renderTheRoulette)
	end)

function closeRouletteTable()
	triggerServerEvent("onPlayerExitRoulette", localPlayer)

	standingTableId = false
	standingTableObj = false

	removeEventHandler("onClientRender", getRootElement(), renderTheRoulette)

	if isElement(Roboto) then
		destroyElement(Roboto)
	end

	Roboto = nil

	if isElement(gtaFont) then
		destroyElement(gtaFont)
	end

	gtaFont = nil

	if isElement(tooltipFont) then
		destroyElement(tooltipFont)
	end

	tooltipFont = nil

	showCursor(false)

	movedChip = false
	draggingPanel = false
end

addEvent("onPlayerRouletteRefresh", true)
addEventHandler("onPlayerRouletteRefresh", getRootElement(),
	function (fieldBets, actions, history, roundTime)
		if not roundTime then
			timeLeft = false
		elseif not timeLeft then
			timeLeft = getTickCount() - roundTime
		end

		topBets = {}

		for field, bets in pairs(fieldBets) do
			for i = 1, #bets do
				topBets[field] = bets[i][1]
			end
		end

		local newgame = false

		betsHistory = ""
        roundHistory = ""

        for i, v in pairs(history) do
            roundHistory = roundHistory..""..v.."\n"

            if i == 11 then
                break
            end
        end

		allBets = {}
		myBets = {}

		havePlacedBets = false

		for i = #actions, 1, -1 do
			local dat = actions[i]

			if i > #actions - 11 then
				if dat == "new" then
					betsHistory = betsHistory .. "#737373-- Új kör kezdődött --\n"
					newgame = true
				else
					betsHistory = betsHistory .. "#D6D6D6" .. dat[5] .. " fogadott erre: " .. dat[2] .. " (" .. dat[3] .. " ZSETON)\n"
				end
			end

			if dat ~= "new" and not newgame then
				if not allBets[dat[1]] then
					allBets[dat[1]] = dat[5] .. " tétje: " .. dat[3] .. " ZSETON"
				else
					allBets[dat[1]] = allBets[dat[1]] .. "\n" .. dat[5] .. " tétje: " .. dat[3] .. " ZSETON"
				end

				if tonumber(dat[4]) == myCharId then
					myBets[dat[1]] = true
					havePlacedBets = true
				end
			end
		end
	end)

addEvent("onRouletteBetRemoved", true)
addEventHandler("onRouletteBetRemoved", getRootElement(),
	function ()
		betRemovingProcess = false
	end
)

addEvent("chipSound", true)
addEventHandler("chipSound", getRootElement(), function(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_)
  setSoundMaxDistance(playSound3D("files/chip" .. _ARG_3_ .. ".mp3", _ARG_0_, _ARG_1_, _ARG_2_),75)
  setElementInterior(playSound3D("files/chip" .. _ARG_3_ .. ".mp3", _ARG_0_, _ARG_1_, _ARG_2_),getElementInterior(localPlayer))
  setElementDimension(playSound3D("files/chip" .. _ARG_3_ .. ".mp3", _ARG_0_, _ARG_1_, _ARG_2_),getElementDimension(localPlayer))
end)

addEvent("onRouletteWheelSound", true)
addEventHandler("onRouletteWheelSound", getRootElement(),
	function ()
		local tableX, tableY, tableZ = getElementPosition(source)
		local tableRot = select(3, getElementRotation(source))
		local rotatedX, rotatedY = rotateAround(tableRot, -0.2, 1.35)
		local soundEffect = playSound3D("files/wheel.mp3", tableX + rotatedX, tableY + rotatedY, tableZ)

		setSoundMaxDistance(soundEffect, 125)
		setElementInterior(soundEffect, getElementInterior(source))
		setElementDimension(soundEffect, getElementDimension(source))
		setTimer(function()
			setElementData(localPlayer, 'playerPlacedBetAlready', false)
		end, 11000, 1)
end
)

addEvent("interpolateTheRouletteBall", true)
addEventHandler("interpolateTheRouletteBall", getRootElement(),
	function (oldNumber, newNumber)
		oldNumber = tonumber(oldNumber) or getRealTime().monthday

		ballInterpolation = {
			getTickCount(),
			wheelNumbers[oldNumber] * degPerNum,
			wheelNumbers[newNumber] * degPerNum - 1080,
			newNumber
		}
	end
)

addCommandHandler("cc",
	function()
		clearChatBox()
	end
)

function renderTheRoulette()
	local currentTick = getTickCount()
	local cursorX, cursorY = getCursorPosition()

	if cursorX then
		cursorX = cursorX * screenX
		cursorY = cursorY * screenY

		if getKeyState("mouse1") then
			if cursorX >= panelPosX and cursorX <= panelPosX + panelWidth - respc(150) and cursorY>= panelPosY and cursorY <= panelPosY + respc(40) and not draggingPanel then
				draggingPanel = {cursorX, cursorY, panelPosX, panelPosY}
			end

			if draggingPanel then
				panelPosX = cursorX - draggingPanel[1] + draggingPanel[3]
				panelPosY = cursorY - draggingPanel[2] + draggingPanel[4]
			end
		elseif draggingPanel then
			draggingPanel = false
		end
	else
		cursorX, cursorY = -1, -1
		
		if movedChip then
			movedChip = false
		end

		if draggingPanel then
			draggingPanel = false
		end
	end

	-- ** Keret
	--[[dxDrawRectangle(panelPosX, panelPosY - 2, panelWidth, 2, tocolor(0, 0, 0, 200)) -- felső
	dxDrawRectangle(panelPosX, panelPosY + panelHeight, panelWidth, 2, tocolor(0, 0, 0, 200)) -- alsó
	dxDrawRectangle(panelPosX - 2, panelPosY - 2, 2, panelHeight + 4, tocolor(0, 0, 0, 200)) -- bal
	dxDrawRectangle(panelPosX + panelWidth, panelPosY - 2, 2, panelHeight + 4, tocolor(0, 0, 0, 200)) -- jobb]]

	-- ** Háttér
	dxDrawRectangle(panelPosX, panelPosY+respc(10), panelWidth, panelHeight, tocolor(0, 0, 0, 170))

	-- ** Cím
	dxDrawRectangle(panelPosX, panelPosY+respc(10), panelWidth, respc(30), tocolor(0, 0, 0, 70))
	centeredText("#ff9428CosmoMTA #ffffff- #ffffffRulett",panelPosX - respc(-1), panelPosY+respc(10), panelWidth, respc(30),tocolor(214,89,89),1,Roboto,true)
	--dxDrawText("#ff9428See#ffffffMTA - Rulett", panelPosX + respc(10), panelPosY, 0, panelPosY + respc(40), tocolor(255, 255, 255), 1, Roboto, "left", "center", false, false, false, true)

	-- ** Kilépés
	local closeLength = dxGetTextWidth("X", 0.8, Roboto)
	local closeColor = tocolor(255, 255, 255)

	if cursorX >= panelPosX + panelWidth - respc(10) - closeLength and cursorX <= panelPosX + panelWidth - respc(10) and cursorY >= panelPosY and cursorY <= panelPosY + respc(47) then
		closeColor = tocolor(215, 89, 89)

		if getKeyState("mouse1") then
			if havePlacedBets then
				if timeLeft == 0 then
					if not cantExitNotiState then
						cantExitNotiState = true
						exports.cosmo_hud:showInfobox("error", "Várd meg a kör végét")
					end
				elseif not cantExitNotiState then
					cantExitNotiState = true
                    exports.cosmo_hud:showInfobox("warning", "Előbb vedd le a tétjeid!")
				elseif getElementData(localPlayer, 'playerPlacedBetAlready') then
					exports.cosmo_hud:showInfobox("error", "Várd meg a kör végét")
				end
			elseif not havePlacedBets and not getElementData(localPlayer, 'playerPlacedBetAlready') then
				closeRouletteTable()
				return
			elseif getElementData(localPlayer, 'playerPlacedBetAlready') and not havePlacedBets then
				exports.cosmo_hud:showInfobox("error", "Várd meg a kör végét")
			end
		elseif cantExitNotiState then
			cantExitNotiState = false
		end
	end

	dxDrawText("X", 0, panelPosY, panelPosX + panelWidth - respc(10), panelPosY + respc(47), closeColor, 0.8, Roboto, "right", "center")

	-- ** Content
	local tableX = math.floor(panelPosX + respc(5))
	local tableY = math.floor(panelPosY + respc(45))

	dxDrawImage(tableX, tableY, tableWidth, tableHeight, "files/table.png")

	local wheelRot = currentTick / 50
	local wheelX = math.ceil(tableX - respc(12))
	local wheelY = math.ceil(tableY + tableHeight / 2 - respc(256) / 2)

	dxDrawImage(wheelX, wheelY, respc(256), respc(256), "files/wheel.png", wheelRot)

	-- Kerék
	local elapsedTime = currentTick - ballInterpolation[1]
	local animProgress = elapsedTime / 10900
	local rotProgress = interpolateBetween(0, 0, 0, 1, 0, 0, animProgress, "InOutQuad")
	local ballRot = interpolateBetween(ballInterpolation[2], 0, 0, ballInterpolation[3], 0, 0, rotProgress, "OutBack", 0.3, 1, 2)

	local preMoveProgress = (elapsedTime - 5500) / 3500
	local moveProgress = 0

	if preMoveProgress > 0 then
		moveProgress = interpolateBetween(0, 0, 0, 1, 0, 0, preMoveProgress, "InOutQuad")
	end

	local moveX, moveY = interpolateBetween(-65, 0, 0, 0, 10, 0, moveProgress, "OutBack", 0.3, 1, 4)
	local ballX, ballY = rotateAround(ballRot + wheelRot, moveX, moveY - 5)

	dxDrawImage(wheelX + ballX + respc(28), wheelY + ballY + respc(28), respc(200), respc(200), "files/ball.png", wheelRot + ballRot)

	if animProgress > 0 and moveProgress >= 1 then
		local sx, sy = respc(30), respc(25)
		local x = wheelX + respc(256) / 2 - sx / 2
		local y = wheelY + respc(24) - sy

		local num = ballInterpolation[4]

		if redex[num] then
			dxDrawRectangle(x, y, sx, sy, tocolor(225, 25, 35))
		elseif blackex[num] then
			dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0))
		else
			dxDrawRectangle(x, y, sx, sy, tocolor(25, 150, 50))
		end

		dxDrawText(num, x, y, x + sx, y + sy, tocolor(255, 255, 255), 0.8, Roboto, "center", "center")
	end

	-- Hátralévő idő
	local min, sec = 1, 0

	if timeLeft then
		local elapsedTime = currentTick - timeLeft
		local progress = math.floor((interactionTime - elapsedTime) / 1000)

		if progress > 0 then
			min, sec = math.floor(progress / 60), progress

			if progress <= 0 then
				timeLeft = 0
			end
		else
			min, sec = 0, 0
			timeLeft = 0
			movedChip = false
		end
	end

	if string.len(sec) < 2 then
		sec = "0" .. sec
	end

	dxDrawImage(panelPosX+panelWidth-respc(735),panelPosY+panelHeight/2+respc(42),respc(20),respc(20), "files/time.png", 0, 0, 0, tocolor(215, 89, 89))
	centeredText(min..":"..sec,panelPosX-respc(640),panelPosY+panelHeight/2+respc(35),panelWidth,respc(30),tocolor(214,89,89),0.9,gtaFont,true,false,true)
	--dxDrawText(min .. ":" .. sec, tableX + chipPotSize, tableY + tableHeight, 0, tableY - tableHeight - respc(45), tocolor(215, 89, 89), 0.9, gtaFont, "left", "center")

	-- Elválasztó
	--dxDrawRectangle(tableX, tableY + tableHeight + chipPotSize, tableWidth,respc(214), tocolor(35, 35, 35))

	-- Zseton
	--dxDrawText("#598ed7" .. formatNumber(mySlotCoins) .. " #ffffffCoin", 0, tableY + tableHeight, panelPosX + panelWidth - respc(10), tableY + tableHeight + chipPotSize - respc(5), tocolor(255, 255, 255), 0.9, gtaFont, "right", "center", false, false, false, true)
	centeredText("#598ed7 " .. formatNumber(mySlotCoins) .. " #ffffffZSETON",panelPosX-respc(180),panelPosY+respc(313),panelWidth,respc(30),tocolor(214,89,89),0.9,gtaFont,true, false, true)
	local chipX = panelPosX + (panelWidth - #availableCoins * chipPotSize) / 2 + 275
	local chipY = tableY + tableHeight + (chipPotSize - chipSize) / 2

	for i = 1, #availableCoins do
		local x = math.floor(chipX + (i - 1) * chipPotSize)
		local y = math.floor(chipY)

		if mySlotCoins >= availableCoins[i] and timeLeft ~= 0 then
			dxDrawImage(x, y, chipSize, chipSize, "/files/chips/" .. availableCoins[i] .. ".png")

			if not movedChip and cursorX >= x and cursorY >= y and cursorX <= x + chipSize and cursorY <= y + chipSize then
				if getKeyState("mouse1") then
					movedChip = availableCoins[i]
				end

				showTooltip(cursorX, cursorY, "#598ed7" .. availableCoins[i] .. " #ffffffZSETON")
			end
		else
			dxDrawImage(x, y, chipSize, chipSize, "/files/chips/" .. availableCoins[i] .. ".png", 0, 0, 0, tocolor(255, 255, 255, 120))
		end
	end

	activeBetField = false

	if not movedChip then
		for field, chip in pairs(topBets) do
			local pos = split(field, ",")
			local x = tableX + pos[1] - chipSize / 2
			local y = tableY + pos[2] - chipSize / 2

			dxDrawImage(x, y, chipSize, chipSize, "/files/chips/" .. chip .. ".png")

			if cursorX >= x and cursorX <= x + chipSize and cursorY >= y and cursorY <= y + chipSize then
				if allBets[field] then
					showTooltip(cursorX, cursorY, "Fogadások", allBets[field])

					if not activeBetField and myBets[field] then
						activeBetField = field
					end
				end
			end
		end

		if activeBetField and not betRemovingProcess and timeLeft ~= 0 and getKeyState("mouse2") then
			betRemovingProcess = true

			if currentTick - clickTick > 500 and myBets[activeBetField] then
				triggerServerEvent("removeRouletteBet", localPlayer, activeBetField)
			else
				betRemovingProcess = false
			end
		end
	elseif isCursorShowing() then
		local activeFields = {}
		local activeFieldX, activeFieldY = 0, 0

		local fieldMinX, fieldMinY = 9999, 9999
		local fieldMaxX, fieldMaxY = -1, -1

		for i = 1, #fieldPositions do
			local dat = fieldPositions[i]

			local fieldX = math.floor(tableX + dat[2])
			local fieldY = math.floor(tableY + dat[3])

			if boxesIntersect(cursorX - chipSize / 2, cursorY - chipSize / 2, cursorX + chipSize / 2, cursorY + chipSize / 2, fieldX, fieldY, fieldX + dat[4], fieldY + dat[5]) then
				table.insert(activeFields, dat[1])
			end

			local field = dat[1]
			local numField = tonumber(field)
			local drawed = false

			if field ~= hoverFieldDatas[3] then
				drawed = true
			end

			if field == hoverFieldDatas[3] then
				activeFieldX = math.floor(dat[2] + dat[4] / 2)
				activeFieldY = math.floor(dat[3] + dat[5] / 2)
			elseif hoverFieldDatas[5] then
				if hoverFieldDatas[5][numField] then
					if activeFieldX <= 0 and activeFieldY <= 0 then
						local startX = dat[2]

						if numField == 0 then
							startX = respc(250)
						end

						if startX < fieldMinX then
							fieldMinX = startX
						end

						if fieldMaxX < dat[2] + dat[4] then
							fieldMaxX = dat[2] + dat[4]
						end

						if numField ~= 0 then
							if dat[3] < fieldMinY then
								fieldMinY = dat[3]
							end

							if fieldMaxY < dat[3] + dat[5] then
								fieldMaxY = dat[3] + dat[5]
							end
						end
					end

					drawed = false
				end
			elseif not drawed then
				drawed = true
			end

			if drawed then
				if numField == 0 then
					dxDrawImage(tableX, tableY, respc(734), respc(268), "files/0.png", 0, 0, 0, tocolor(0, 0, 0, 150))
				else
					dxDrawRectangle(fieldX, fieldY, dat[4], dat[5], tocolor(0, 0, 0, 150))
				end
			end
		end

		if activeFieldX <= 0 and activeFieldY <= 0 then
			activeFieldX = fieldMinX + (fieldMaxX - fieldMinX) / 2
			activeFieldY = fieldMinY + (fieldMaxY - fieldMinY) / 2
			
			if (hoverFieldDatas[2] == "three line" or hoverFieldDatas[2] == "six line" or hoverFieldDatas[2] == "corner") and not tonumber(hoverFields[1]) then
				activeFieldY = fieldMinY + (fieldMaxY - fieldMinY)
			end
		end

		if #activeFields == 0 then
			hoverFields = {}
			hoverFieldDatas = {}
		else
			for i = 1, #activeFields do
				local activeField = activeFields[i]
				local selectedField = hoverFields[i]

				if activeField == selectedField then
					activeField = #activeFields
					selectedField = #hoverFields
				end

				if activeField ~= selectedField then
					local fieldNumbers, fieldName, oneFieldName, priceMultipler = getDetailsFromName(activeFields)

					hoverFields = activeFields
					hoverFieldDatas = {fieldNumbers, fieldName, oneFieldName, priceMultipler}
					hoverFieldDatas[5] = {}

					for j = 1, #fieldNumbers do
						hoverFieldDatas[5][tonumber(fieldNumbers[j])] = true
					end

					break
				end
			end
		end

		dxDrawImage(cursorX - chipSize / 2, cursorY - chipSize / 2, chipSize, chipSize, "/files/chips/" .. movedChip .. ".png")

		if #hoverFields > 0 and tonumber(hoverFieldDatas[4]) then
			showTooltip(cursorX, cursorY, hoverFieldDatas[2], "Kifizetés: " .. hoverFieldDatas[4] + 1 .. "x")
		end

		for field, chip in pairs(topBets) do
			local pos = split(field, ",")
			local x = tableX + pos[1] - chipSize / 2
			local y = tableY + pos[2] - chipSize / 2

			dxDrawImage(x, y, chipSize, chipSize, "/files/chips/" .. chip .. ".png")
		end

		if not getKeyState("mouse1") then
			if #hoverFields > 0 and timeLeft ~= 0 and currentTick - clickTick > 500 then
				local field = activeFieldX .. "," .. activeFieldY

				topBets[field] = movedChip
				hoverFieldDatas[3] = nil
				hoverFieldDatas[5] = nil
				hoverFieldDatas[6] = movedChip
				clickTick = getTickCount()

				triggerServerEvent("placeRouletteBet", localPlayer, field, hoverFieldDatas, getElementsByType("player", getRootElement(), true))
				setElementData(localPlayer, 'playerPlacedBetAlready', true)

				hoverFieldDatas = {}
			end

			movedChip = false
		end
	end
	centeredText(roundHistory,tableX,tableY + tableHeight/2+respc(75),panelWidth,respc(194),tocolor(255,255,255),0.75,Roboto,true,true,false,true)
	centeredText(betsHistory,tableX,tableY + tableHeight/2+respc(75),panelWidth,respc(194),tocolor(255,255,255),0.75,Roboto,true,false,true,true)
	--dxDrawText(betsHistory, tableX, tableY + tableHeight + chipPotSize + respc(5), tableX + tableWidth, tableY + tableHeight + chipPotSize + respc(5) + respc(194), tocolor(255, 255, 255), 0.75, Roboto, "left", "top", false, false, false, true)
	--dxDrawText(roundHistory, tableX, tableY + tableHeight + chipPotSize + respc(5), tableX + tableWidth, tableY + tableHeight + chipPotSize + respc(5) + respc(194), tocolor(255, 255, 255), 0.75, Roboto, "right", "top", false, false, false, true)
end

function boxesIntersect(x, y, sx, sy, x2, y2, sx2, sy2)
	if sx < x2 then
		return false
	end
	
	if sx2 < x then
		return false
	end
	
	if sy < y2 then
		return false
	end
	
	if sy2 < y then
		return false
	end
	
	return true
end

function showTooltip(x, y, text, text2)
	text = tostring(text)
	text2 = text2 and tostring(text2)

	if text == text2 then
		text2 = nil
	end

	local sx = dxGetTextWidth(text, 1, "clear", true) + 20
	
	if text2 then
		sx = math.max(sx, dxGetTextWidth(text2, 1, "clear", true) + 20)
		text = "#ff9428" .. text .. "\n#ffffff" .. text2
	end

	local sy = 30

	if text2 then
		local lines = select(2, string.gsub(text2, "\n", "")) + 1
		sy = sy + 12 * lines
	end

	x = math.max(0, math.min(screenX - sx, x))
	y = math.max(0, math.min(screenY - sy, y))

	dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 150), true)
	dxDrawText(text, x, y, x + sx, y + sy, tocolor(255, 255, 255), 0.5, tooltipFont, "center", "center", false, false, true, true)
end

function shadowedText(text,x,y,w,h,color,fontsize,font,aligX,alignY)

    dxDrawText(text,x,y,w,h,color,fontsize,font,aligX,alignY, false, false, false, true)
end

function centeredText(text,x,y,w,h,color,size,font,shadow,leftcentered,rightcentered,top)
    if leftcentered then
		if shadow then
			if top then
				shadowedText(text,x+20,y+h/2,x+20,y+h/2,color,size,font,"left","top",false,false,false,true)
			else
				shadowedText(text,x+20,y+h/2,x+20,y+h/2,color,size,font,"left","center",false,false,false,true)
			end
        else
            dxDrawText(text,x+20,y+h/2,x+20,y+h/2,color,size,font,"left","center",false,false,false,true)
        end
	elseif rightcentered then
        if shadow then
            if top then
                shadowedText(text,x+w,y+h/2,x+w-20,y+h/2,color,size,font,"right","top",false,false,false,true)
            else
                shadowedText(text,x+w,y+h/2,x+w-20,y+h/2,color,size,font,"right","center",false,false,false,true)
            end
        else
            dxDrawText(text,x+20-20,y+h/2,x+20,y+h/2,color,size,font,"right","center",false,false,false,true)
        end
	else
        if shadow then 
            shadowedText(text,x+w/2,y+h/2,x+w/2,y+h/2,color,size,font,"center","center",false,false,false,true)
        else
            dxDrawText(text,x+w/2,y+h/2,x+w/2,y+h/2,color,size,font,"center","center",false,false,false,true)
        end
    end
end

local coinPanel = false
local localPrice = 10000

local panelWidth = 400
local panelHeight = 250
local panelPosX = screenX / 2 - panelWidth / 2
local panelPosY = screenY / 2 - panelHeight / 2

addEventHandler("onClientClick", root,
    function(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
        if button == "right" and state == "down" then
            if clickedElement and isElement(clickedElement) then
                if getElementData(clickedElement, "ped.type") == 8 then
                    if not coinPanel then
                        local playerX, playerY, playerZ = getElementPosition(localPlayer)
                        local pedX, pedY, pedZ = getElementPosition(clickedElement)
                        local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, pedX, pedY, pedZ)
 
                        if distance < 3 then 
                            coinPanel = true
                            createFont()
                            fakeInputs = {}
                            selectedInput = false
                            addEventHandler("onClientRender", root, drawCoinPanel)
                            addEventHandler("onClientKey", getRootElement(), inputKey)
                            addEventHandler("onClientClick", getRootElement(), onInputClick)
                            addEventHandler("onClientCharacter", getRootElement(), inputCharacterHandler)    
                        end
                    end
                end
            end
        end
    end
)

function createFont()
	Roboto = dxCreateFont(":cosmo_assets/fonts/Roboto-Regular.ttf", 16, false, "cleartype")
	Robotol1 = dxCreateFont(":cosmo_assets/fonts/Roboto-Regular.ttf", 12, false, "cleartype")
    Robotol2 = dxCreateFont(":cosmo_assets/fonts/Roboto-Regular.ttf", 12, false, "cleartype")
	RobotoL16 = dxCreateFont(":cosmo_assets/fonts/Roboto-Light.ttf", 16, false, "cleartype")
end

function drawCoinPanel()
    buttons = {}

    -- ** Háttér
    dxDrawRectangle(panelPosX, panelPosY, panelWidth, panelHeight, tocolor(31, 31, 31, 240))
    
    -- ** Cím
    dxDrawRectangle(panelPosX, panelPosY, panelWidth, 30, tocolor(31, 31, 31, 240))
    dxDrawText("#ff9428CosmoMTA - #ffffffZSETON", panelPosX + 210, panelPosY + 15, panelPosX + 200, panelPosY + 15, tocolor(255, 255, 255, 255), 1, Robotol1, "center", "center", false, false, false, true)
    dxDrawText("Jelenlegi: #ff9428"..formatNumber(getElementData(localPlayer, "char.ucoin")) .." ZSETON", panelPosX + 10, panelPosY + 50, panelPosX + 10, panelPosY + 50, tocolor(255, 255, 255, 255), 1, Robotol1, "left", "center", false, false, false, true)
    dxDrawText("Ár: #ff9428"..formatNumber(10000).." FT/ZSETON", panelPosX + 10, panelPosY + 75, panelPosX + 10, panelPosY + 75, tocolor(255, 255, 255, 255), 1, Robotol1, "left", "center", false, false, false, true)

    local inputPrice = tonumber(fakeInputs["atmPrice|9"] or 0) or 0
    local result = inputPrice * localPrice

    dxDrawText("Ár: #ff9428"..formatNumber(result).." FT", panelPosX + 10, panelPosY + 100, panelPosX + 10, panelPosY + 100, tocolor(255, 255, 255, 255), 1, Robotol1, "left", "center", false, false, false, true)

    drawInput("atmPrice|9", "FT", panelPosX + 10 , panelPosY + 120, 380, 30, Robotol1, 1)

    drawButton2("buyuc", "Coin Vásárlás", panelPosX + 10, panelPosY + 165, 180, 30, 7,112,196, 1, Robotol2, 1)
    drawButton2("exitPrice", "Coin Eladása", panelPosX + 210, panelPosY + 165, 180, 30, 7,112,196, 1, Robotol2, 1)
    drawButton2("closePanel", "Kilépés", panelPosX + 10, panelPosY + 210, 380, 30, 230, 28, 14, 1, Roboto, 1)


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

function onInputClick(button, state)
	selectedInput = false
	
	if coinPanel and activeButton then
		if button == "left" and state == "up" then
			local selected = split(activeButton, ":")
			if selected[1] == "input" then
				selectedInput = false
				selectedInput = selected[2]
			elseif selected[1] == "closePanel" then
				coinPanel = false
				fakeInputs = {}
				selectedInput = false
				removeEventHandler("onClientRender", root, drawCoinPanel)
				removeEventHandler("onClientKey", getRootElement(), inputKey)
				removeEventHandler("onClientClick", getRootElement(), onInputClick)
				removeEventHandler("onClientCharacter", getRootElement(), inputCharacterHandler)
			elseif selected[1] == "buyuc" then
				if fakeInputs["atmPrice|9"] == "" then return end
				
				local num = tonumber(fakeInputs["atmPrice|9"])
                local myMoney = getElementData(localPlayer, "char.Money")
                local res = num * localPrice

				if num > 0 then
                    if myMoney - res >= 0 then
                        local ownUC = getElementData(localPlayer, "char.ucoin") or 0
                        setElementData(localPlayer, "char.ucoin", ownUC + num)
                        exports.cosmo_core:takeMoney(localPlayer, res, false)
                    else
                        exports.cosmo_hud:showAlert("error", "Nincs elég pénzed!")
                    end
				end
			elseif selected[1] == "exitPrice" then
				if fakeInputs["atmPrice|9"] == "" then return end
				
				local num = tonumber(fakeInputs["atmPrice|9"])

                local myUC = getElementData(localPlayer, "char.ucoin") or 0

				if num > 0 then
                    if myUC - num >= 0 then
                        local resMoney = num * localPrice
                        local money = getElementData(localPlayer, "char.Money")
                        local tax = resMoney * 0.15
                        resMoney = resMoney - tax
                        setElementData(localPlayer, "char.ucoin", myUC - num)
                        setElementData(localPlayer, "char.Money", money + resMoney)
                    else
                        exports.cosmo_hud:showAlert("error", "Nincs elég coinod!")
                    end
				end
			end
		end
	end
end

function inputKey(key, state)
	if coinPanel then
		if selectedInput and state and key == "backspace" then
			if utf8.len(fakeInputs[selectedInput]) >= 1 then
				fakeInputs[selectedInput] = utf8.sub(fakeInputs[selectedInput], 1, -2)
			elseif utf8.len(fakeInputs[selectedInput]) < 1 then
				fakeInputs[selectedInput] = ""
			end
		end
		cancelEvent()
	end
end

function inputCharacterHandler(character)
	if selectedInput then
		local selected = split(selectedInput, "|")

		if utf8.len(fakeInputs[selectedInput]) < tonumber(selected[2]) then
			if tonumber(character) then
				fakeInputs[selectedInput] = fakeInputs[selectedInput] .. character
			end
		end
	end
end

function formatNumber(amount, stepper)
	local left, center, right = string.match(math.floor(amount), "^([^%d]*%d)(%d*)(.-)$")
	 return left .. string.reverse(string.gsub(string.reverse(center), "(%d%d%d)", "%1" .. (stepper or " "))) .. right
end