pcall(loadstring(base64Decode(exports.cosmo_core:getInterfaceElements())));addEventHandler("onCoreStarted",root,function(functions) for k,v in ipairs(functions) do _G[v]=nil;end;collectgarbage();pcall(loadstring(base64Decode(exports.cosmo_core:getInterfaceElements())));end)

local useingNametag
local useingNametagIcon

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        engineImportTXD(engineLoadTXD("files/taxi.txd", 1313), 1313)
        engineReplaceModel(engineLoadDFF("files/taxi.dff", 1313), 1313)
    end
)

function dxCreateButton(key, label, x, y, w, h, activeColor, postGui, theFont, labelScale)
	local buttonColor

	if wardisActiveButton == key then
		buttonColor = {activeColor[1], activeColor[2], activeColor[3], 175}
	else
		buttonColor = {activeColor[1], activeColor[2], activeColor[3], 125}
	end
		
	local alphaDifference = 175 - buttonColor[4]
		
	local labelFont = theFont or "arial"
	local postGui = postGui or false
	local labelScale = labelScale or 0.85

	dxDrawRectangle(x, y, w, h, tocolor(0, 0, 0, 170), postGui)
	dxDrawRectangle(x + 2, y + 2, w - 4, h - 4, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 175 - alphaDifference), postGui)
	dxDrawText(label, x + 2, y + 2, x + 2 + w - 4, y + 2 + h - 4, tocolor(222, 222, 222, 222), labelScale, labelFont, "center", "center", false, false, postGui, true)

	wardisButtons[key] = {x + 2, y + 2, w - 4, h - 4}
end

local screenX, screenY = guiGetScreenSize()
local sx, sy = guiGetScreenSize()

local panelState = false

local panelWidth = (defaultSettings.slotBoxWidth + 5) * defaultSettings.width + 5 + 10
local panelHeight = (defaultSettings.slotBoxHeight + 5) * math.floor(defaultSettings.slotLimit / defaultSettings.width) + 5

local panelPosX = screenX / 2
local panelPosY = screenY / 2

local moveDifferenceX, moveDifferenceY = 0, 0
local panelIsMoving = false

local sizeForTabs = panelWidth / 3

local Roboto = dxCreateFont("files/fonts/RobotoB.ttf", 20, false, "antialiased")
local RobotoT = dxCreateFont("files/fonts/Roboto.ttf", 16, false, "antialiased")
local RobotoL = dxCreateFont("files/fonts/RobotoL.ttf", 12, false, "antialiased")
local RobotoL4 = dxCreateFont("files/fonts/RobotoL.ttf", 14, false, "antialiased")
local RobotoB = dxCreateFont("files/fonts/RobotoB.ttf", 12, false, "antialiased")
local RobotoB2 = dxCreateFont("files/fonts/RobotoB.ttf", 10, false, "antialiased")
local Roboto2 = dxCreateFont("files/fonts/Roboto.ttf", 18, false, "antialiased")
local moneyfont = dxCreateFont("files/fonts/gtaFont.ttf", 17, false, "antialiased")
local hand = dxCreateFont("files/hand.ttf", 18, false, "antialiased")


function renderBook()
	guiBringToFront(bookEditBox)

	wardisButtons = {}

	dxDrawImage(screenX / 2 - 504 / 2, screenY / 2 - 610 / 2, 504, 610, "files/paper.png")

	dxDrawText(guiGetText(bookEditBox), screenX / 2 - 504 / 2 + 90, screenY / 2 - 610 / 2, 504 + screenX / 2 - 504 / 2 - 10, 610 + screenY / 2 - 610 / 2 - 5, tocolor(0, 0, 0), 1, hand, "left", "top", true, true, false, false, false)

	dxCreateButton("writenPaper", "Megírás", screenX / 2 - 504 / 2, screenY / 2 + 610 / 2 + 3, 504, 30, {20, 102, 255}, false, Roboto2)
	dxCreateButton("exitFromPaper", "Kilépés", screenX / 2 - 504 / 2, screenY / 2 + 610 / 2 + 30 + 2 + 3, 504, 30, {188, 64, 61}, false, Roboto2)

	if getKeyState("mouse1") then 
		if wardisActiveButton == "writenPaper" then
			removeEventHandler("onClientRender", getRootElement(), renderBook)
			triggerServerEvent("addItem", resourceRoot, localPlayer, 233, 1, false, toJSON(guiGetText(bookEditBox)))

			bookState = false
			showCursor(false)

			destroyElement(bookEditBox)
		elseif wardisActiveButton == "exitFromPaper" then
			removeEventHandler("onClientRender", getRootElement(), renderBook)
			destroyElement(bookEditBox)
			bookState = false
			showCursor(false)
		end
	end

	local relX, relY = getCursorPosition()

	wardisActiveButton = false

	if relX and relY then
		relX = relX * screenX
		relY = relY * screenY

		for k, v in pairs(wardisButtons) do
			if relX >= v[1] and relY >= v[2] and relX <= v[1] + v[3] and relY <= v[2] + v[4] then
				wardisActiveButton = k
				break
			end
		end
	end
end
function renderPaper()
	wardisButtons = {}

	if printedPaper then
		dxDrawImage(screenX / 2 - 504 / 2, screenY / 2 - 610 / 2, 504, 610, "files/paperc.png")
		dxDrawText(activePaperText, screenX / 2 - 504 / 2 + 90, screenY / 2 - 610 / 2, 504 + screenX / 2 - 504 / 2 - 10, 610 + screenY / 2 - 610 / 2 - 5, tocolor(0, 0, 0, 170), 1, hand, "left", "top", true, true, false, false, false)
	else
		dxDrawImage(screenX / 2 - 504 / 2, screenY / 2 - 610 / 2, 504, 610, "files/paper.png")
		dxDrawText(activePaperText, screenX / 2 - 504 / 2 + 90, screenY / 2 - 610 / 2, 504 + screenX / 2 - 504 / 2 - 10, 610 + screenY / 2 - 610 / 2 - 5, tocolor(0, 0, 0), 1, hand, "left", "top", true, true, false, false, false)
	end


	dxCreateButton("exitFromPaper", "Kilépés", screenX / 2 - 504 / 2, screenY / 2 + 610 / 2 + 3, 504, 30, {188, 64, 61}, false, Roboto2)

	if getKeyState("mouse1") then 
		if wardisActiveButton == "exitFromPaper" then
			removeEventHandler("onClientRender", getRootElement(), renderPaper)
			paperState = false
			printedPaper = false
		end
	end

	local relX, relY = getCursorPosition()

	wardisActiveButton = false

	if relX and relY then
		relX = relX * screenX
		relY = relY * screenY

		for k, v in pairs(wardisButtons) do
			if relX >= v[1] and relY >= v[2] and relX <= v[1] + v[3] and relY <= v[2] + v[4] then
				wardisActiveButton = k
				break
			end
		end
	end
end

local stackAmount = 0

itemsTable = {}
itemsTable.player = {}
itemsTable.vehicle = {}
itemsTable.object = {}
itemsTableState = "player"
currentInventoryElement = localPlayer

local fixCardUse = 0
local healCardUse = 0
local csokiUse = 0
local zapUse = 0
local petardaTick = 0

local haveMoving = false

local movedslotId = false
local lastslotId = false

local currentCategory = "main"
local categoryHover = false
local tabLineInterpolation = false
local lastCategory = currentCategory

local absX = -1
local absY = -1

local lastWeightSize = 0
local gotWeightInterpolation = false

local itemPictures = {}
local grayItemPictures = {}
local perishableTimer = false

local itemListState = false
local itemListWidth = screenX / 2
local itemListHeight = 30 + defaultSettings.slotBoxHeight * 12 + 30 + 5
local itemListPosX = screenX / 2 - itemListWidth / 2
local itemListPosY = screenY / 2 - itemListHeight / 2
local itemListOffset = 0
local itemListItems = false

local friskPanelState = false
local friskPanelWidth = (defaultSettings.slotBoxWidth + 5) * defaultSettings.width + 5
local friskPanelHeight = (defaultSettings.slotBoxHeight + 5) * math.floor(defaultSettings.slotLimit / defaultSettings.width) + 5
local friskPanelPosX = screenX / 3
local friskPanelPosY = screenY / 3
local friskTableState = false

local friskCategory = "main"
local friskCategoryHover = false
local friskCatInterpolate = false
local friskLastCategory = friskCategory
local friskPanelIsMoving = false

local hoverShowItem = false
local lastShowItemTick = 0

local lastSpecialItemUsage = 0

local drunkenLevel = 0
local drunkHandled = false
local drunkenScreenSource = false
local fuckControlsDisabledControl = false
local fuckControlsChangeTick = 0
local drunkenScreenFlickeringState = false

--<<CRAFT>>--
local kTick = 0;
local currentRowItem = 1
local latestRowItem = 1
local craftItemNameDrawMax = 7
local crafting = false
local craftloading = 0
local pedInCraftAnim = false
local maxCraftItemNameDraw = 11
--<<CRAFT>>--

local rottenEffect = false

local storedTrashes = {}

local vehicleTickets = {}
local hoverTicket = false

local myCharacterId = false

local itemsLoaded = false

local currInte = getElementInterior(localPlayer)
local currDim = getElementDimension(localPlayer)

local craftCol = {
	{2550.65234375, -1297.8826904297, 1044.125, 10, 9},
	{2540.8432617188, -1298.1016845703, 1044.125, 5, 9},
}
local colShape = {}
local inCraftShape = false

addEventHandler("onClientPreRender", getRootElement(),
	function()
		local activeInt = getElementInterior(localPlayer)
		local activeDim = getElementDimension(localPlayer)
		
		if currDim ~= activeDim or currInte ~=  activeInt then
			currDim = activeDim
			currInte = activeInt
			triggerServerEvent("changeModelIntOrDim", localPlayer, localPlayer)
		end
	end
)

addEventHandler("onClientClick", getRootElement(),
	function (button, state)
		if state == "up" and hoverTicket and itemsLoaded then
			if myCharacterId == hoverTicket[2].ownerId then
				triggerServerEvent("requestVehicleTicket", localPlayer, hoverTicket[1], hoverTicket[2].data)

				exports.cosmo_chat:sendLocalMeAction(localPlayer, "elvesz egy bírságot a járműről.")
			else
				exports.cosmo_hud:showAlert("error", "A jármű nem a Te tulajdonod ezért a csekket sem tudod elvenni!")
			end
		end
	end
)

addEventHandler("onClientRender", getRootElement(),
	function ()
		local cameraPosX, cameraPosY, cameraPosZ = getCameraMatrix()
		local playerDimension = getElementDimension(localPlayer)
		local cursorX, cursorY = getCursorPosition()

		if cursorX then
			cursorX, cursorY = cursorX * screenX, cursorY * screenY
		else
			cursorX, cursorY = -1, -1
		end

		hoverTicket = false

		for k, v in pairs(vehicleTickets) do
			if isElement(k) and isElement(v.thePicture) then
				local vehicleDimension = getElementDimension(k)

				if vehicleDimension == playerDimension then
					local vehiclePosX, vehiclePosY, vehiclePosZ = getVehicleComponentPosition(k, "windscreen_dummy", "world")

					if not vehiclePosX then
						vehiclePosX, vehiclePosY, vehiclePosZ = getElementPosition(k)
					end

					if isLineOfSightClear(cameraPosX, cameraPosY, cameraPosZ, vehiclePosX, vehiclePosY, vehiclePosZ, true, false, false, true, false, false) then
						local screenPosX, screenPosY = getScreenFromWorldPosition(vehiclePosX, vehiclePosY, vehiclePosZ)

						if screenPosX and screenPosY then
							local distance = getDistanceBetweenPoints3D(cameraPosX, cameraPosY, cameraPosZ, vehiclePosX, vehiclePosY, vehiclePosZ)

							if distance <= 8 then
								local scaleFactor = 1 - distance / 16

								local sx = 256 * 0.25 * scaleFactor
								local sy = 512 * 0.25 * scaleFactor

								local x = screenPosX - sx / 2
								local y = screenPosY - sy / 2

								if cursorX >= x and cursorX <= x + sx and cursorY >= y and cursorY <= y + sy then
									sx = 256 * scaleFactor
									sy = 512 * scaleFactor

									hoverTicket = {k, v}
								end

								dxDrawRectangle(x - 5, y - 5, sx + 10, sy + 10, tocolor(0, 0, 0, 160))
								dxDrawImage(x, y, sx, sy, v.thePicture)
							end
						end
					end
				end
			else
				vehicleTickets[k] = nil
			end
		end
	end
)

function render3DTicket(sourceVehicle, data)
	if vehicleTickets[sourceVehicle] and isElement(vehicleTickets[sourceVehicle].thePicture) then
		destroyElement(vehicleTickets[sourceVehicle].thePicture)
	end

	data = fromJSON(data)

	if not data or type(data) ~= "table" or data and not data.date or not data.fine or not data.numberplate or not data.type or not data.location or not data.reason or not data.agency then
		vehicleTickets[sourceVehicle] = nil
		setElementData(sourceVehicle, "vehicleTicket", false)
		return
	end

	vehicleTickets[sourceVehicle] = {}
	vehicleTickets[sourceVehicle].ownerId = getElementData(sourceVehicle, "vehicle.owner") or 0
	vehicleTickets[sourceVehicle].data = data

	local renderTarget = dxCreateRenderTarget(256, 512)
	local handFont = dxCreateFont(":cosmo_assets/fonts/hand.otf", 24, false, "antialiased")
	local lunabar = dxCreateFont(":cosmo_assets/fonts/lunabar.ttf", 16, false, "antialiased")
	local scaleFactor = 0.7

	dxSetRenderTarget(renderTarget)

	dxDrawImage(0, 0, 256, 512, ":cosmo_ticket/files/parking.png")

	dxDrawText(data["date"], 16 * scaleFactor, 145 * scaleFactor, 170 * scaleFactor, 49 * scaleFactor, tocolor(255, 148, 40), 0.6, handFont)
	dxDrawText(data["fine"] .. "$", 186 * scaleFactor, 145 * scaleFactor, 167 * scaleFactor, 49 * scaleFactor, tocolor(255, 148, 40), 0.6, handFont)
	dxDrawText(data["numberplate"], 16 * scaleFactor, 195 * scaleFactor, 337 * scaleFactor, 49 * scaleFactor, tocolor(255, 148, 40), 0.6, handFont)
	dxDrawText(data["type"], 16 * scaleFactor, 249 * scaleFactor, 337 * scaleFactor, 49 * scaleFactor, tocolor(255, 148, 40), 0.6, handFont)
	dxDrawText(data["location"], 16 * scaleFactor, 303 * scaleFactor, 337 * scaleFactor, 49 * scaleFactor, tocolor(255, 148, 40), 0.6, handFont)
	dxDrawText(data["reason"], 16 * scaleFactor, 357 * scaleFactor, 337 * scaleFactor, 49 * scaleFactor, tocolor(255, 148, 40), 0.6, handFont)
	dxDrawText(data["agency"], 16 * scaleFactor, 409 * scaleFactor, 337 * scaleFactor, 49 * scaleFactor, tocolor(255, 148, 40), 0.6, handFont)

	if data["officer"] then
		dxDrawText(data["officer"], 188 * scaleFactor, 512 - 49 * scaleFactor - 10 * scaleFactor, 188 * scaleFactor + 152 * scaleFactor, 512 - 49 * scaleFactor - 30 * scaleFactor + 49 * scaleFactor, tocolor(255, 148, 40), 1, lunabar, "center", "center")
	end

	dxSetRenderTarget()

	if isElement(handFont) then
		destroyElement(handFont)
	end

	if isElement(lunabar) then
		destroyElement(lunabar)
	end

	if isElement(renderTarget) then
		local pixels = dxGetTexturePixels(renderTarget)

		pixels = dxConvertPixels(pixels, "png")

		destroyElement(renderTarget)

		vehicleTickets[sourceVehicle].thePicture = dxCreateTexture(pixels, "dxt3")
	end

	return false
end

addEventHandler("onClientRestore", getRootElement(),
	function ()
		for k, v in ipairs(getElementsByType("vehicle", getRootElement(), true)) do
			local theTicket = getElementData(v, "vehicleTicket")

			if theTicket then
				render3DTicket(v, theTicket)
			elseif vehicleTickets[v] then
				if isElement(vehicleTickets[v].thePicture) then
					destroyElement(vehicleTickets[v].thePicture)
				end

				vehicleTickets[v] = nil
			end
		end
	end
)


addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		setTimer(triggerServerEvent, 5000, 1, "requestTrashes", localPlayer)

		if getElementData(localPlayer, "loggedIn") then
			setTimer(triggerServerEvent, 5000, 1, "requestCache", localPlayer)

			if isTimer(perishableTimer) then
				killTimer(perishableTimer)
			end
			
			perishableTimer = setTimer(processPerishableItems, 60000*10, 0)
		end

		for k, v in pairs(availableItems) do
			if fileExists("files/items/" .. k .. ".png") then
				itemPictures[k] =  dxCreateTexture("files/items/" .. k .. ".png")
			else
				itemPictures[k] =  dxCreateTexture("files/noitempic.png")
			end
		end

		for k, v in pairs(itemsTable.player) do
			if itemsTable.player[v].data3 == "printed" then
				grayItemPictures[k] = dxCreateShader("files/blackwhite.fx")

				dxSetShaderValue(grayItemPictures[k], "screenSource", itemPictures[v])
			end
		end

		setElementData(localPlayer, "canUseMegaphone", false)
		setElementData(localPlayer, "canUseFlex", false)

		setTimer(
			function()
				toggleControl("next_weapon", false)
				toggleControl("previous_weapon", false)
			end,
		1000, 0)

		bindKey("r", "down", "reloadmyweapon")

		for k, v in ipairs(getElementsByType("vehicle", getRootElement(), true)) do
			local theTicket = getElementData(v, "vehicleTicket")

			if theTicket then
				render3DTicket(v, theTicket)
			end
		end

		engineImportTXD(engineLoadTXD("files/villogo.txd",1253),1253)
		engineReplaceModel(engineLoadDFF("files/villogo.dff",1253),1253)
		engineImportTXD(engineLoadTXD("files/taxilogo.txd",4054),4054)
		engineReplaceModel(engineLoadDFF("files/taxilogo.dff",4054),4054)
		myCharacterId = getElementData(localPlayer, "char.ID")
		createCraftCol()
	end
)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			local theTicket = getElementData(source, "vehicleTicket")

			if theTicket then
				render3DTicket(source, theTicket)
			end
		end
	end
)

addEventHandler("onClientElementStreamOut", getRootElement(),
	function ()
		if vehicleTickets[source] then
			if isElement(vehicleTickets[source].thePicture) then
				destroyElement(vehicleTickets[source].thePicture)
			end

			vehicleTickets[source] = nil
		end
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if source == localPlayer then
			if dataName == "loggedIn" and getElementData(source, dataName) then
				if isTimer(perishableTimer) then
					killTimer(perishableTimer)
				end

				perishableTimer = setTimer(processPerishableItems, 60000*10, 0)

				myCharacterId = getElementData(localPlayer, "char.ID")
			end
		elseif dataName == "vehicleTicket" then
			local theTicket = getElementData(source, "vehicleTicket")

			if theTicket then
				if isElementStreamedIn(source) then
					render3DTicket(source, theTicket)
				end
			elseif vehicleTickets[source] then
				if isElement(vehicleTickets[source].thePicture) then
					destroyElement(vehicleTickets[source].thePicture)
				end

				vehicleTickets[source] = nil
			end
		end
	end
)

addCommandHandler("reloadmyweapon",
	function (commandName)
		if not isPedDead(localPlayer) and getPedTask(localPlayer, "secondary", 0) ~= "TASK_SIMPLE_USE_GUN" then
			if getElementData(localPlayer, "tazerReloadNeeded") then
				setElementData(localPlayer, "tazerReloadNeeded", false)
				exports.cosmo_controls:toggleControl({"fire", "vehicle_fire", "action"}, true)
			end
		end
	end
)

exports.cosmo_admin:addAdminCommand("nearbysafes", 6, "Közelben lévő széfek")
addCommandHandler("nearbysafes",
	function()
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			outputChatBox(exports.cosmo_core:getServerTag("admin") .. "A közeledben lévő szemetesek:", 255, 255, 255, true)

			local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
			local playerInterior = getElementInterior(localPlayer)
			local playerDimension = getElementDimension(localPlayer)
			local nearbyTrashes = 0
			
			for k, v in pairs(getElementsByType("object")) do
				if getElementData(v, "isSafe") then
					if playerInterior == getElementInterior(v) and playerDimension == getElementDimension(v) then
						local objectPosX, objectPosY, objectPosZ = getElementPosition(v)
						local distance = getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, objectPosX, objectPosY, objectPosZ)

						if distance <= 15 then
							outputChatBox("#4bd439>> #FFFFFFAzonosító: #4bd439" .. getElementData(v, "safeId") .. "#FFFFFF <> Távolság: #4bd439" .. math.floor(distance), 255, 255, 255, true)
							nearbyTrashes = nearbyTrashes + 1
						end
					end
				end
			end
			
			if nearbyTrashes == 0 then
				outputChatBox(exports.cosmo_core:getServerTag("admin") .. "A közeledben nem található egyetlen szemetes sem.", 255, 255, 255, true)
			end
		end
	end
)

exports.cosmo_admin:addAdminCommand("nearbytrashes", 1, "Közelben lévő szemetesek")
addCommandHandler("nearbytrashes",
	function ()
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			outputChatBox(exports.cosmo_core:getServerTag("admin") .. "A közeledben lévő szemetesek:", 255, 255, 255, true)

			local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
			local playerInterior = getElementInterior(localPlayer)
			local playerDimension = getElementDimension(localPlayer)
			local nearbyTrashes = 0

			for k, v in pairs(storedTrashes) do
				if playerInterior == v.interior and playerDimension == v.dimension then
					local objectPosX, objectPosY, objectPosZ = getElementPosition(v.objectElement)
					local distance = getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, objectPosX, objectPosY, objectPosZ)

					if distance <= 15 then
						outputChatBox("#4bd439>> #FFFFFFAzonosító: #4bd439" .. v.trashId .. "#FFFFFF <> Távolság: #4bd439" .. math.floor(distance), 255, 255, 255, true)
						nearbyTrashes = nearbyTrashes + 1
					end
				end
			end

			if nearbyTrashes == 0 then
				outputChatBox(exports.cosmo_core:getServerTag("admin") .. "A közeledben nem található egyetlen szemetes sem.", 255, 255, 255, true)
			end
		end
	end
)

addEvent("receiveTrashes", true)
addEventHandler("receiveTrashes", getRootElement(),
	function (array)
		if array and type(array) == "table" then
			storedTrashes = array
		end
	end
)

addEvent("createTrash", true)
addEventHandler("createTrash", getRootElement(),
	function (trashId, array)
		if trashId then
			trashId = tonumber(trashId)

			if array and type(array) == "table" then
				storedTrashes[trashId] = array
			end
		end
	end
)

addEvent("destroyTrash", true)
addEventHandler("destroyTrash", getRootElement(),
	function (trashId)
		if trashId then
			trashId = tonumber(trashId)

			if storedTrashes[trashId] then
				storedTrashes[trashId] = nil
			end
		end
	end
)

function addDrunkenLevel(amount)
	drunkenLevel = drunkenLevel + amount

	processDrunkRender()

	setTimer(removeDrunkenLevel, 30000, 1, 2, 30000)
end

function removeDrunkenLevel(amount, renderTime)
	drunkenLevel = drunkenLevel - amount
	
	if drunkenLevel < 0 then
		drunkenLevel = 0
	end

	processDrunkRender()

	if renderTime and drunkenLevel > 0 then
		setTimer(removeDrunkenLevel, renderTime, 1, 2, renderTime)
	end
end

function giveArmor(thePlayer, give)
	if give then
		if getPedArmor(thePlayer) + give <= 100 then
			triggerServerEvent("giveArmor", thePlayer, getPedArmor(thePlayer) + give)
			return true
		elseif getPedArmor(thePlayer) + give > 100 then
			triggerServerEvent("giveArmor", thePlayer, 100)
			return true
		end 
	end 
end

function bugfix()
	if getElementData(localPlayer, "acc.adminLevel") >= 1 then
	setGameSpeed(1)
	end
end
addCommandHandler("gamefix", bugfix)

function setHeroinScreen(state)
	if state then
		addEventHandler("onClientRender", root, renderHeroinScreen)
		screen = dxCreateScreenSource(sx, sy)
		setTimer(function()
			setHeroinScreen(false)
		end, 120000, 1)
		setGameSpeed(0.8)
	else
		removeEventHandler("onClientRender", root, renderHeroinScreen)
		setGameSpeed(1)
	end
end

function setGombaScreen(state)
	if state then
		addEventHandler("onClientRender", root, renderHeroinScreen)
		screen = dxCreateScreenSource(sx, sy)
		setTimer(function()
			setHeroinScreen(false)
		end, 12000, 1)
		setGameSpeed(2)
	else
		removeEventHandler("onClientRender", root, renderHeroinScreen)
		setGameSpeed(1)
	end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	blurShader, blurTec = dxCreateShader("effects/blur.fx")
end)

function renderHeroinScreen()
	if blurShader then
		dxUpdateScreenSource(screen)
		dxSetShaderValue(blurShader, "ScreenSource", screen)
		dxSetShaderValue(blurShader, "BlurStrength", 15)
		dxSetShaderValue(blurShader, "UVSize", sx, sy)
		dxDrawImage(0, 0, sx, sy, blurShader)
	end		
	dxUpdateScreenSource(screen, true)
end

function processDrunkRender()
	if drunkenLevel > 0 then
		if not drunkHandled then
			drunkHandled = true
			addEventHandler("onClientRender", getRootElement(), drunkenRender, true, "low-999")

			drunkenScreenSource = dxCreateScreenSource(screenX, screenY)
		end
	else
		if drunkHandled then
			drunkHandled = false
			removeEventHandler("onClientRender", getRootElement(), drunkenRender)

			if isElement(drunkenScreenSource) then
				destroyElement(drunkenScreenSource)
			end
		end

		if fuckControlsDisabledControl then
			setAnalogControlState("vehicle_left", 0)
     		setAnalogControlState("vehicle_right", 0)
     		exports.cosmo_controls:toggleControl({"vehicle_left", "vehicle_right"}, true)
     		fuckControlsDisabledControl = false
		end
	end
end

function drunkenRender()
	if isElement(drunkenScreenSource) then
		dxUpdateScreenSource(drunkenScreenSource)
	end

	local currentTick = getTickCount()
	local elapsedTime = currentTick - fuckControlsChangeTick

	if elapsedTime >= 3000 then
		fuckControlsChangeTick = currentTick
		elapsedTime = 0
		drunkenScreenFlickeringState = not drunkenScreenFlickeringState

		if fuckControlsDisabledControl then
			setAnalogControlState("vehicle_left", 0)
     		setAnalogControlState("vehicle_right", 0)
     		exports.cosmo_controls:toggleControl({"vehicle_left", "vehicle_right"}, true)
     		fuckControlsDisabledControl = false
		end

		if math.random(5) <= 3 then
			exports.cosmo_controls:toggleControl({"vehicle_left", "vehicle_right"}, false)
			fuckControlsDisabledControl = true

			if math.random(10) <= 5 then
				setAnalogControlState("vehicle_left", 1)
			else
				setAnalogControlState("vehicle_right", 1)
			end
		end
	end

	local progress = elapsedTime / 3000
	local flickerOffsetX = 0
	local flickerOffsetY = 0

	if drunkenScreenFlickeringState then
		flickerOffsetX, flickerOffsetY = interpolateBetween(0, 0, 0, -drunkenLevel * 5, -drunkenLevel * 5, 0, progress, "OutQuad")
	else
		flickerOffsetX, flickerOffsetY = interpolateBetween(-drunkenLevel * 5, -drunkenLevel * 5, 0, 0, 0, 0, progress, "OutQuad")
	end

	if isElement(drunkenScreenSource) then
		dxDrawImage(0 - flickerOffsetX, 0 - flickerOffsetY, screenX, screenY, drunkenScreenSource, 0, 0, 0, tocolor(255, 255, 255, 200))
		dxDrawImage(0 + flickerOffsetX, 0 + flickerOffsetY, screenX, screenY, drunkenScreenSource, 0, 0, 0, tocolor(255, 255, 255, 200))
	end
end

addEventHandler("onClientPlayerWeaponSwitch", getRootElement(),
	function (previousWeaponSlot, currentWeaponSlot)
		if getPedWeapon(localPlayer, currentWeaponSlot) == 0 then
			deactivateWeapon()
		end
	end
)

function deactivateWeapon()
	local weaponInUse = false
	local ammoInUse = false

	for k, v in pairs(itemsTable.player) do
		if v.inUse then
			if isWeaponItem(v.itemId) and not weaponInUse then
				weaponInUse = weaponInUse or v
			elseif isAmmoItem(v.itemId) and not ammoInUse then
				ammoInUse = v
			end
		end
	end

	if weaponInUse then
		local slotId = weaponInUse.slot
		local itemId = itemsTable.player[slotId].itemId
		local databaseId = itemsTable.player[slotId].dbID

		itemsTable.player[slotId].inUse = false

		triggerServerEvent("takeWeapon", localPlayer, localPlayer, itemId, databaseId)

		if availableItems[itemId] then
			if itemId == 28 then
				exports.cosmo_chat:sendLocalMeAction(localPlayer, "elrakott egy fényképezőgépet.")
			elseif itemId == 110 then
				if getElementData(localPlayer, "tazerReloadNeeded") then
					exports.cosmo_controls:toggleControl({"fire", "vehicle_fire", "action"}, true)
					setElementData(localPlayer, "tazerReloadNeeded", false)
				end

				exports.cosmo_chat:sendLocalMeAction(localPlayer, "elrakott egy sokkoló pisztolyt.")

				setElementData(localPlayer, "tazerState", false)
			else
				if itemsTable.player[slotId].nameTag then
					fegyoName = getItemName(itemId) .. " (" .. itemsTable.player[slotId].nameTag .. "#C2A2DA)" 
				else
					fegyoName = getItemName(itemId)
				end

				exports.cosmo_chat:sendLocalMeAction(localPlayer, "elrakott egy fegyvert. (" .. fegyoName .. "#C2A2DA)")

				triggerEvent("movedItemInInventory", localPlayer)
			end
		else
			exports.cosmo_chat:sendLocalMeAction(localPlayer, "elrakott egy fegyvert.")
		end

		togglePlayerWeaponFire(true)

		if ammoInUse then
			itemsTable.player[ammoInUse.slot].inUse = false
		end
	end
end

function unuseItem(dbID)
	if dbID then
		dbID = tonumber(dbID)

		for k, v in pairs(itemsTable.player) do
			if v.dbID == dbID then
				itemsTable.player[v.slot].inUse = false
				break
			end
		end
	end
end

local lastDrugTick = 0

function useItem(itemDbId)
	if itemDbId then
		if (getElementData(localPlayer, "acc.adminJail") or 0) ~= 0 then
			return
		end

		local hoveredSlot = findSlot(absX, absY)
		local movedItem = itemsTable[itemsTableState][movedslotId]

		if movedItem and movedItem.dbID == itemDbId then
			return exports.cosmo_hud:showInfobox("error", "Jelenleg mozgatod ezt az itemet!")
		end

		if getElementData(localPlayer, "player.Cuffed") then
			exports.cosmo_hud:showInfobox("error", "Bilincsben nem tudod használni az itemeket!")
			return
		end

		local slotId = false
		itemDbId = tonumber(itemDbId)

		for k, v in pairs(itemsTable.player) do
			if v.dbID == itemDbId then
				slotId = k
				break
			end
		end

		if itemsTable.player[slotId] and itemsTable.player[slotId].amount > 0 and itemsTable.player[slotId].itemId then
			local itemData = itemsTable.player[slotId]
			local itemId = tonumber(itemData.itemId)

			if isWeaponItem(itemId) or isAmmoItem(itemId) then
				local weaponInUse = false
				local ammoInUse = false

				for k, v in pairs(itemsTable.player) do
					if v.inUse then
						if isWeaponItem(v.itemId) and not weaponInUse then
							weaponInUse = v
						elseif isAmmoItem(v.itemId) and not ammoInUse then
							ammoInUse = v
						end
					end
				end

				if isWeaponItem(itemId) then
					if not weaponInUse then
						if getPedControlState("fire") then
							exports.cosmo_hud:showInfobox("warning", "Amíg nyomva tartod a lövés gombot, nem veheted elő a fegyvert.")
							return
						elseif getPedControlState("aim_weapon") then
							exports.cosmo_hud:showInfobox("warning", "Amíg nyomva tartod a célzás gombot, nem veheted elő a fegyvert.")
							return
						elseif getElementData(localPlayer, "canUseMegaphone") then
							exports.cosmo_hud:showInfobox("warning", "Előbb rakd el a megafont!")
							return
						elseif getElementData(localPlayer, "canUseFlex") then
							exports.cosmo_hud:showInfobox("warning", "Előbb rakd el a flexet!")
							return
						end

						itemsTable.player[slotId].inUse = true
						weaponInUse = itemsTable.player[slotId]

						local haveAmmo = false

						if getItemAmmoID(weaponInUse.itemId) > 0 then
							for k, v in pairs(itemsTable.player) do
								if isAmmoItem(v.itemId) and not v.inUse and getItemAmmoID(weaponInUse.itemId) == v.itemId then
									ammoInUse = v
									itemsTable.player[v.slot].inUse = true
									haveAmmo = true
									break
								end
							end
						end

						if (not haveAmmo and getItemAmmoID(weaponInUse.itemId) == weaponInUse.itemId) or getItemAmmoID(weaponInUse.itemId) == -1 then
							ammoInUse = weaponInUse
							haveAmmo = true
						end

						if haveAmmo then
							if weaponInUse.itemId == 110 then
								triggerServerEvent("giveWeapon", localPlayer, weaponInUse.itemId, getItemWeaponID(weaponInUse.itemId), 99999)
							elseif weaponInUse.itemId == ammoInUse.itemId then
								triggerServerEvent("giveWeapon", localPlayer, weaponInUse.itemId, getItemWeaponID(weaponInUse.itemId), ammoInUse.amount, itemData.dbID)
							elseif ammoInUse.itemId == 44 then
								if (tonumber(ammoInUse.data1) or 0) >= 100 then
									togglePlayerWeaponFire(false)
								end

								triggerServerEvent("giveWeapon", localPlayer, weaponInUse.itemId, getItemWeaponID(weaponInUse.itemId), 99999)
							else
								triggerServerEvent("giveWeapon", localPlayer, weaponInUse.itemId, getItemWeaponID(weaponInUse.itemId), ammoInUse.amount + 1, itemData.dbID)
							end
						else
							triggerServerEvent("giveWeapon", localPlayer, weaponInUse.itemId, getItemWeaponID(weaponInUse.itemId), 1, itemData.dbID)
							togglePlayerWeaponFire(false)
						end

						if availableItems[weaponInUse.itemId] then
							if weaponInUse.itemId == 28 then
								exports.cosmo_chat:sendLocalMeAction(localPlayer, "elővett egy fényképezőgépet.")
							elseif weaponInUse.itemId == 110 then
								exports.cosmo_chat:sendLocalMeAction(localPlayer, "elővett egy sokkoló pisztolyt.")
								setElementData(localPlayer, "tazerState", true)
							else
								local itemName = ""

								if availableItems[weaponInUse.itemId] then
									if weaponInUse.nameTag then
										itemName = " (" .. getItemName(weaponInUse.itemId) .. " (" .. weaponInUse.nameTag .. "#C2A2DA))"
									else
										itemName = " (" .. getItemName(weaponInUse.itemId) .. ")"
									end
								end

								exports.cosmo_chat:sendLocalMeAction(localPlayer, "elővett egy fegyvert." .. itemName)

								setElementData(localPlayer, "tazerState", false)

								triggerEvent("movedItemInInventory", localPlayer)
							end
						end
					elseif weaponInUse.dbID == itemDbId then
						deactivateWeapon()
					end
				elseif isAmmoItem(itemId) and weaponInUse then
					if not ammoInUse then
						if getItemAmmoID(weaponInUse.itemId) == itemId then
							if itemsTable.player[slotId].itemId == 44 then
								if (tonumber(itemsTable.player[slotId].data1) or 0) >= 100 then
									togglePlayerWeaponFire(false)
								else
									togglePlayerWeaponFire(true)
								end

								triggerServerEvent("giveWeapon", localPlayer, weaponInUse.itemId, getItemWeaponID(weaponInUse.itemId), 99999)
							else
								triggerServerEvent("giveWeapon", localPlayer, weaponInUse.itemId, getItemWeaponID(weaponInUse.itemId), itemsTable.player[slotId].amount + 1)

								togglePlayerWeaponFire(true)
							end

							itemsTable.player[slotId].inUse = true
						end
					elseif getItemWeaponID(weaponInUse.itemId) and ammoInUse.dbID == itemDbId then
						triggerServerEvent("giveWeapon", localPlayer, weaponInUse.itemId, getItemWeaponID(weaponInUse.itemId), 1)

						togglePlayerWeaponFire(false)

						itemsTable.player[slotId].inUse = false
					end
				end
			elseif isSpecialItem(itemId) then
				if getTickCount() >= lastSpecialItemUsage then
					if getElementData(localPlayer, "canUseMegaphone") then
						exports.cosmo_hud:showInfobox("warning", "Előbb rakd el a megafont!")
						return
					elseif getElementData(localPlayer, "canUseFlex") then
						exports.cosmo_hud:showInfobox("warning", "Előbb rakd el a flexet!")
						return
					end

					lastSpecialItemUsage = getTickCount() + 3000

					local currentAmount = tonumber(itemsTable.player[slotId].data2) or 0

					if itemId == 62 or itemId == 63 or (itemId >= 64 and itemId <= 69) then
						addDrunkenLevel(3)
					end

					if currentAmount + (specialItemUsage[itemId] or 20) >= 100 then
						triggerServerEvent("useItem", localPlayer, itemsTable.player[slotId].dbID)
						triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)
						itemsTable.player[slotId] = nil
					else
						triggerEvent("updateItemData2", localPlayer, "player", itemsTable.player[slotId].dbID, currentAmount + (specialItemUsage[itemId] or 20), true)
						triggerServerEvent("useItem", localPlayer, itemsTable.player[slotId].dbID)
					end
				else
					exports.cosmo_hud:showInfobox("error", "Ne kapkodj, még megfulladsz!")
				end
			elseif itemId == 230 then
				if isTimer(drugTimer) then outputChatBox("#ff9428[CosmoMTA - Drog]#FFFFFF Csak 1 percenként használhatsz drogot",255,255,255,true) return end
				setHeroinScreen(true)
				exports.cosmo_chat:sendLocalMeAction(localPlayer, "felszívott egy kis kokaint.")
				giveArmor(localPlayer, math.random(5, 30))
				triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)
				drugTimer = setTimer(function() end, 1000*60*1, 1)
			elseif itemId == 231 then
				if isTimer(drugTimer) then outputChatBox("#ff9428[CosmoMTA - Drog]#FFFFFF Csak 1 percenként használhatsz drogot",255,255,255,true) return end
				setHeroinScreen(true)
				exports.cosmo_chat:sendLocalMeAction(localPlayer, "felszívott egy kis kokaint.")
				giveArmor(localPlayer, math.random(5, 30))
				triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)
				drugTimer = setTimer(function() end, 1000*60*1, 1)
			elseif itemId == 80 then
				exports.cosmo_ropsys:startRopeDown()
				setTimer(function()
					if getElementData(localPlayer, "rappeling") == true then
						exports.cosmo_chat:sendLocalMeAction(localPlayer,"rögzíti a kötelet.")
						-- triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1) -- Ezt rakd vissza, hogyha 1x használatosat akarsz
					end
				end,600,1)
			elseif itemId == 268 then
				if isTimer(gombaTimer) then outputChatBox("#ff9428[CosmoMTA - Drog]#FFFFFF Csak 1 percenként használhatod ezt a gombát",255,255,255,true) return end
				setGombaScreen(true)
				exports.cosmo_chat:sendLocalMeAction(localPlayer, "meg evett egy őzláb gombát.")
				giveArmor(localPlayer, math.random(60, 90))
				triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)
				gombaTimer = setTimer(function() end, 100*60*1, 1)
			elseif itemId == 254 then
				if isTimer(drugTimer) then outputChatBox("#ff9428[CosmoMTA - Drog]#FFFFFF Csak 1 percenként használhatsz drogot",255,255,255,true) return end
				setHeroinScreen(true)
				exports.cosmo_chat:sendLocalMeAction(localPlayer, "felszívott egy kis metamfetamint.")
				giveArmor(localPlayer, math.random(5, 30))
				triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)
				drugTimer = setTimer(function() end, 1000*60*1, 1)
			elseif itemId == 246 then
					triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)
			elseif itemId == 76 then
				exports.cosmo_interiors:useDoorRammer()
			elseif itemId == 199 then
				if itemsTable.player[slotId].inUse then 
					itemsTable.player[slotId].inUse = false
				else
					itemsTable.player[slotId].inUse = true
				end
				exports.nlrp_company:showProductLetter(fromJSON(itemsTable.player[slotId].data1), itemsTable.player[slotId].inUse)	
			-- elseif itemId == 200 then
			-- 	exports.cosmo_fishing:createStick(localPlayer)
			-- 	--exports.fishing:setPecaState(localPlayer)
			-- 	if not getElementData(localPlayer, "char:pecabotInHand") then
			-- 		setElementData(localPlayer, "char:pecabotInHand", true)
			-- 	else
			-- 		setElementData(localPlayer, "char:pecabotInHand", false)
			-- 	end
			elseif itemId == 123 then --Cserép Marihuána
				if getElementInterior(localPlayer) == 0 or getElementDimension(localPlayer) == 0 then
					outputChatBox("#ff9428[CosmoMTA - Drog] #ffffffCsak interiorban helyezhető le!",255,255,255,true)
				else
					exports["cosmo_plant"]:createPlantC(getLocalPlayer(),1)
					triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)		
				end
			elseif itemId == 124 then --Cserép Koka
				if getElementInterior(localPlayer) == 0 or getElementDimension(localPlayer) == 0 then
					outputChatBox("#ff9428[CosmoMTA - Drog] #ffffffCsak interiorban helyezhető le!",255,255,255,true)
				else
					exports["cosmo_plant"]:createPlantC(getLocalPlayer(),2)
					triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)		
				end
			elseif itemId == 111 or itemId == 112 or itemId == 263 then -- Jogsi/Személyi
				for k, v in pairs(itemsTable.player) do
					if (v.itemId == 111 or v.itemId == 112 or v.itemId == 263) and v.inUse then

						itemsTable.player[v.slot].inUse = false

						if v.itemId == 111 then
							exports.cosmo_chat:sendLocalMeAction(localPlayer, "elrak egy jogosítványt.")
							triggerEvent("cosmo_licensesC:showDocument", localPlayer)
						elseif v.itemId == 112 then
							exports.cosmo_chat:sendLocalMeAction(localPlayer, "elrak egy személyigazolványt.")
							triggerEvent("cosmo_licensesC:showDocument", localPlayer)
						elseif v.itemId == 263 then
							exports.cosmo_chat:sendLocalMeAction(localPlayer, "elrak egy fegyverengedélyt.")
							triggerEvent("cosmo_licensesC:showDocument", localPlayer)
						end
					end
				end

				if not licenseState then
					itemsTable.player[slotId].inUse = true

					if itemsTable.player[slotId].itemId == 111 then
						--triggerEvent("cosmo_licensesC:showDocument", localPlayer, "driver", fromJSON(itemsTable.player[slotId].data1))
						triggerEvent("cosmo_licensesC:showDocument", localPlayer, "DriverLicense", fromJSON(itemsTable.player[slotId].data1), itemsTable.player[slotId].data3)

						exports.cosmo_chat:sendLocalMeAction(localPlayer, "megnéz egy jogosítványt.")
					elseif itemsTable.player[slotId].itemId == 263 then
						triggerEvent("cosmo_licensesC:showDocument", localPlayer, "weapon", fromJSON(itemsTable.player[slotId].data1), itemsTable.player[slotId].data3)

						exports.cosmo_chat:sendLocalMeAction(localPlayer, "megnéz egy fegyverengedélyt.")	
					elseif itemsTable.player[slotId].itemId == 112 then
						--triggerEvent("cosmo_licensesC:showDocument", localPlayer, "identity", fromJSON(itemsTable.player[slotId].data1))
						triggerEvent("cosmo_licensesC:showDocument", localPlayer, "Identity", fromJSON(itemsTable.player[slotId].data1), itemsTable.player[slotId].data3)
					else
						triggerEvent("cosmo_licensesC:showDocument", localPlayer, "IdentityPrinted", fromJSON(itemsTable.player[slotId].data1), itemsTable.player[slotId].data3)

						exports.cosmo_chat:sendLocalMeAction(localPlayer, "megnéz egy személyigazolványt.")
					end

					licenseState = true
				else
					licenseState = false
				end
			-- elseif itemId == 82 then
			-- 	if getElementData(localPlayer, "loggedIn") then
			-- 		triggerServerEvent("placeHifi", root, localPlayer)
			-- 		triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)
			-- end
			elseif itemId == 119 or itemId == 118 then -- Bírság/Parkolási bírság
				for k, v in pairs(itemsTable.player) do
					if (v.itemId == 119 or v.itemId == 118) and v.inUse then

						itemsTable.player[v.slot].inUse = false

						if v.itemId == 119 then
							exports.cosmo_chat:sendLocalMeAction(localPlayer, "elrak egy bírságot.")
							triggerEvent("cosmo_ticketC:showTicket", localPlayer)
						elseif v.itemId == 118 then
							exports.cosmo_chat:sendLocalMeAction(localPlayer, "elrak egy parkolási bírságot.")
							triggerEvent("cosmo_ticketC:showTicket", localPlayer)
						end
					end
				end

				if not ticketState then
					

					local nearNPC = false
					for k, v in pairs(getElementsByType("ped", root, true)) do
						if getElementData(v, "ped.type") == "FINEPAY" then
							if exports.cosmo_core:inDistance3D(v, localPlayer, 5) then
								nearNPC = true
								break
							end
						end
					end

					if nearNPC then
						local ticketData = fromJSON(itemsTable.player[slotId].data1)
						if exports.cosmo_core:takeMoney(localPlayer, tonumber(ticketData["fine"])) then
							triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)
							exports.cosmo_hud:showAlert("info", "Sikeresen befizetted a bírságot")
						else
							exports.cosmo_hud:showAlert("error", "Nincs elegendő pénzed befizetni a bírságot")
						end
					else
						itemsTable.player[slotId].inUse = true
						if itemsTable.player[slotId].itemId == 119 then
							triggerEvent("cosmo_ticketC:showTicket", localPlayer, itemsTable.player[slotId].dbID, true, "Traffic", fromJSON(itemsTable.player[slotId].data1), false)

							exports.cosmo_chat:sendLocalMeAction(localPlayer, "megnéz egy bírságot.")
						elseif itemsTable.player[slotId].itemId == 118 then
							triggerEvent("cosmo_ticketC:showTicket", localPlayer, itemsTable.player[slotId].dbID, true, "Parking", fromJSON(itemsTable.player[slotId].data1), false)

							exports.cosmo_chat:sendLocalMeAction(localPlayer, "megnéz egy parkolási bírságot.")
						end
						ticketState = true
					end

					
				else
					ticketState = false
				end
			elseif itemId == 120 or itemId == 121 then -- Bírság/Parkolási bírság tömb
				for k, v in pairs(itemsTable.player) do
					if (v.itemId == 120 or v.itemId == 121) and v.inUse then

						itemsTable.player[v.slot].inUse = false

						if v.itemId == 120 then
							exports.cosmo_chat:sendLocalMeAction(localPlayer, "elrak egy bírság tömböt.")
							triggerEvent("cosmo_ticketC:showTicket", localPlayer)
						elseif v.itemId == 121 then
							exports.cosmo_chat:sendLocalMeAction(localPlayer, "elrak egy parkolási bírság tömböt.")
							triggerEvent("cosmo_ticketC:showTicket", localPlayer)
						end
					end
				end

			elseif itemId == 232 then	

				if not bookState then
					bookEditBox = guiCreateEdit(- 1000, - 1000, 200, 20, "", false)
					addEventHandler("onClientRender", getRootElement(), renderBook)
					showCursor(true)
					
					bookState = true
				end
			elseif itemId == 233 then	
				if itemsTable.player[slotId].inUse then
					itemsTable.player[slotId].inUse = false
					triggerServerEvent("useItem", localPlayer, itemDbId, false)
				else
					local itemFound = false

					for k, v in pairs(itemsTable.player) do
						if (v.itemId == 233) and v.inUse then
							itemsTable.player[v.slot].inUse = false
							itemFound = true
						end
					end

				if not paperState then
					activePaperText = fromJSON(itemsTable.player[slotId].data1)

					if activePaperText then
						triggerServerEvent("useItem", localPlayer, itemDbId, true)

						addEventHandler("onClientRender", getRootElement(), renderPaper)

					end
					paperState = true
				else
					triggerServerEvent("useItem", localPlayer, itemDbId, false)
				end
			end
			elseif itemId == 234 then -- zseblámpa
				if use then
					exports.dl_flashlight:toggleFlashLight()
				else
					exports.dl_flashlight:toggleFlashLight()
					triggerServerEvent("useItem", localPlayer, itemDbId, false)

				end

			elseif itemId == 235 then
				--triggerServerEvent("useItem", localPlayer, itemDbId)
				--triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)
				
				--triggerEvent("showTheRaffle", localPlayer, "defaultEgg")
			elseif itemId == 236 then
				--triggerServerEvent("useItem", localPlayer, itemDbId)
				--triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)
				
				--triggerEvent("showTheRaffle", localPlayer, "redEgg")
			elseif itemId == 237 then
				--triggerServerEvent("useItem", localPlayer, itemDbId)
				--triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)
				

				--triggerEvent("showTheRaffle", localPlayer, "goldEgg")


				-- if not ticketState then
				-- 	itemsTable.player[slotId].inUse = true

				-- 	if itemsTable.player[slotId].itemId == 120 then
				-- 		triggerEvent("cosmo_ticketC:showTicket", localPlayer, itemsTable.player[slotId].dbID, true, "Traffic", nil, true)

				-- 		exports.cosmo_chat:sendLocalMeAction(localPlayer, "elővesz egy bírság tömböt.")
				-- 	elseif itemsTable.player[slotId].itemId == 121 then
				-- 		triggerEvent("cosmo_ticketC:showTicket", localPlayer, itemsTable.player[slotId].dbID, true, "Parking", nil, true)

				-- 		exports.cosmo_chat:sendLocalMeAction(localPlayer, "elővesz egy parkolási bírság tömböt.")
				-- 	end

				-- 	ticketState = true
				-- else
				-- 	ticketState = false
				-- end
			elseif itemId == 79 then -- Walkie Talkie
				local itemFound = false

				for k, v in pairs(itemsTable.player) do
					if v.itemId == 79 and v.inUse then
						exports.cosmo_hud:showWalkieTalkie(false)
						itemsTable.player[v.slot].inUse = false
						exports.cosmo_chat:sendLocalMeAction(localPlayer, "elrak egy rádiót.")
						itemFound = true
					end
				end

				if not itemFound then
					itemsTable.player[slotId].inUse = true
					exports.cosmo_hud:showWalkieTalkie(true, itemsTable.player[slotId])
					exports.cosmo_chat:sendLocalMeAction(localPlayer, "elővesz egy rádiót.")
				end
			elseif itemId == 114 then -- Megaphone
				if getElementData(localPlayer, "canUseFlex") then
					exports.cosmo_hud:showInfobox("warning", "Előbb rakd el a flexet!")
					return
				end	
				
				local itemFound = false

				for k, v in pairs(itemsTable.player) do
					if v.itemId == 114 and v.inUse then
						setElementData(localPlayer, "canUseMegaphone", false)
						itemsTable.player[v.slot].inUse = false
						exports.cosmo_chat:sendLocalMeAction(localPlayer, "elrak egy megafont.")
						itemFound = true
					end
				end

				if getPedWeapon(localPlayer) > 0 then
					exports.cosmo_hud:showInfobox("error", "Előbb rakd el a fegyvert!")
				elseif not itemFound then
					itemsTable.player[slotId].inUse = true
					setElementData(localPlayer, "canUseMegaphone", true)
					exports.cosmo_chat:sendLocalMeAction(localPlayer, "elővesz egy megafont.")
				end
			elseif itemId == 180 then -- flex
				if getElementData(localPlayer, "canUseMegaphone") then
					exports.cosmo_hud:showInfobox("warning", "Előbb rakd el a megafont!")
					return
				end	
		
				local itemFound = false

				for k, v in pairs(itemsTable.player) do
					if v.itemId == 180 and v.inUse then
						setElementData(localPlayer, "canUseFlex", false)
						itemsTable.player[v.slot].inUse = false
						exports.cosmo_chat:sendLocalMeAction(localPlayer, "elrak egy flexet.")
						itemFound = true
					end
				end

				if getPedWeapon(localPlayer) > 0 then
					exports.cosmo_hud:showInfobox("error", "Előbb rakd el a fegyvert!")
				elseif not itemFound then
					itemsTable.player[slotId].inUse = true
					setElementData(localPlayer, "canUseFlex", true)
					exports.cosmo_chat:sendLocalMeAction(localPlayer, "elővesz egy flexet.")
				end
			elseif itemId == 105 then -- Gyógyszer
				if getElementHealth(localPlayer) >= 20 then
					if getTickCount() >= lastDrugTick then
						lastDrugTick = getTickCount() + 60000

						triggerServerEvent("useItem", localPlayer, itemDbId)
						triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)
						
						itemsTable.player[slotId] = nil
					else
						exports.cosmo_hud:showInfobox("error", "Csak percenként vehetsz be gyógyszert!")
					end
				end
			elseif itemId == 106 then -- Vitamin
				if getTickCount() >= lastDrugTick then
					lastDrugTick = getTickCount() + 60000

					triggerServerEvent("useItem", localPlayer, itemDbId)
					triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)
					
					itemsTable.player[slotId] = nil
				else
					exports.cosmo_hud:showInfobox("error", "Csak percenként vehetsz be gyógyszert!")
				end
			elseif itemId == 94 then -- láda geci
				triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)

                itemsTable.player[slotId] = nil

                triggerEvent("showTheRaffle", localPlayer, "day")	
            elseif itemId == 257 then
                    triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)

                    itemsTable.player[slotId] = nil

                    triggerEvent("showTheRaffle", localPlayer, "day")				
			elseif itemId == 86 or itemId == 71 then -- Jelvény / Telefon / Villogó
				if itemsTable.player[slotId].inUse then
					itemsTable.player[slotId].inUse = false
					triggerServerEvent("useItem", localPlayer, itemDbId, false)
				else
					local itemFound = false

					for k, v in pairs(itemsTable.player) do
						if (v.itemId == 86 or v.itemId == 71) and v.inUse then
							itemsTable.player[v.slot].inUse = false
							itemFound = true
						end
					end
				
					if not itemFound then
						itemsTable.player[slotId].inUse = true
						triggerServerEvent("useItem", localPlayer, itemDbId, true)
					else
						triggerServerEvent("useItem", localPlayer, itemDbId, false)
					end
				end
			elseif itemId == 245 then -- Villogó
				if itemsTable.player[slotId].inUse then
					itemsTable.player[slotId].inUse = false
					triggerServerEvent("useItem", localPlayer, itemDbId, false)
				else
					local itemFound = false

					for k, v in pairs(itemsTable.player) do
						if (v.itemId == 245) and v.inUse then
							itemsTable.player[v.slot].inUse = false
							itemFound = true
						end
					end
				
					if not itemFound then
						local isInVehicle = getPedOccupiedVehicleSeat(localPlayer)
						local vehType = getPedOccupiedVehicle(localPlayer)
						
						if isInVehicle == 0 or isInVehicle == 1 then
							if sirenPos[getElementModel(vehType)] then
								itemsTable.player[slotId].inUse = true
								triggerServerEvent("useItem", localPlayer, itemDbId, true)
							else
								exports.cosmo_hud:showAlert("error", "Ebben a kocsiban nem használhatod.")
							end
						else
							exports.cosmo_hud:showAlert("error", "Csak kocsiban/Első ülésen használhatod.")
						end
					else
						triggerServerEvent("useItem", localPlayer, itemDbId, false)
					end
				end
			elseif itemId == 179 then -- Villogó
				if itemsTable.player[slotId].inUse then
					itemsTable.player[slotId].inUse = false
					triggerServerEvent("useItem", localPlayer, itemDbId, false)
				else
					local itemFound = false

					for k, v in pairs(itemsTable.player) do
						if (v.itemId == 179) and v.inUse then
							itemsTable.player[v.slot].inUse = false
							itemFound = true
						end
					end
				
					if not itemFound then
						local isInVehicle = getPedOccupiedVehicleSeat(localPlayer)
						local vehType = getPedOccupiedVehicle(localPlayer)
						
						if isInVehicle == 0 or isInVehicle == 1 then
							if sirenPos[getElementModel(vehType)] then
								itemsTable.player[slotId].inUse = true
								triggerServerEvent("useItem", localPlayer, itemDbId, true)
							else
								exports.cosmo_hud:showAlert("error", "Ebben a kocsiban nem használhatod.")
							end
						else
							exports.cosmo_hud:showAlert("error", "Csak kocsiban/Első ülésen használhatod.")
						end
					else
						triggerServerEvent("useItem", localPlayer, itemDbId, false)
					end
				end

			elseif itemId == 158 then
				if getTickCount() - fixCardUse >= 30000 then
					local veh = getPedOccupiedVehicle(localPlayer)
					
					if veh then
						triggerServerEvent("fixVehicleWithCard", localPlayer, veh)
						triggerServerEvent("useItem", localPlayer, itemDbId)
						triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)		
						fixCardUse = getTickCount()
					else
						exports.cosmo_hud:showInfobox("error", "Ezt az itemet csak a kocsiban használhatod.")
					end
				else
					exports.cosmo_hud:showInfobox("error", "Csak 30 másodpercenként használhatod.")
				end
			elseif itemId == 159 then
				local veh = getPedOccupiedVehicle(localPlayer)
				
				if veh then
					triggerServerEvent("fuelVehicleWithCard", localPlayer, veh)
					triggerServerEvent("useItem", localPlayer, itemDbId)
					triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)		
				else
					exports.cosmo_hud:showInfobox("error", "Ezt az itemet csak a kocsiban használhatod.")
				end



			elseif itemId == 160 then
				if getTickCount() - healCardUse >= 30000 then
					if isPedDead(localPlayer) then
						triggerServerEvent("useItem", localPlayer, itemDbId)
						triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)			
						triggerServerEvent("healPlayerCard", localPlayer, localPlayer, "dead")
						exports.cosmo_hud:showInfobox("info", "Sikeresen felsegítetted magad.")
						healCardUse = getTickCount()
						exports.cosmo_chat:sendLocalMeAction(localPlayer, "elhasznál egy Heal Kártyát.")
						triggerServerEvent("setPlayerAlpha", localPlayer, localPlayer)
					else
						triggerServerEvent("useItem", localPlayer, itemDbId)
						triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)
						triggerServerEvent("healPlayerCard", localPlayer, localPlayer, "knock")
						exports.cosmo_hud:showInfobox("info", "Sikeresen felsegítetted magad.")
						healCardUse = getTickCount()
						exports.cosmo_chat:sendLocalMeAction(localPlayer, "elhasznál egy Heal Kártyát.")
					end
				else
					exports.cosmo_hud:showInfobox("error", "Csak 30 másodpercenként használhatod.")
				end
			elseif itemId == 256 then
				if getTickCount() - csokiUse >= 10000 then
					triggerServerEvent("useItem", localPlayer, itemDbId)
					triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)			
					triggerServerEvent("csokiuse", localPlayer, localPlayer)
					exports.cosmo_chat:sendLocalMeAction(localPlayer, "megevett egy csokitojást.")
					csokiUse = getTickCount()
				else
					exports.cosmo_hud:showInfobox("error", "Csak 10 másodpercenként használhatod.")
				end
			elseif itemId == 255 then
				if getTickCount() - zapUse >= 10000 then
					triggerServerEvent("useItem", localPlayer, itemDbId)
					triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)			
					triggerServerEvent("zapuse", localPlayer, localPlayer)
					exports.cosmo_chat:sendLocalMeAction(localPlayer, "megevett egy záptojást.")
					zapUse = getTickCount()
					x,y,z = getElementPosition(localPlayer)
					effect = createEffect("spraycan",x, y, z+0.7,0,0,0)
					exports.cosmo_boneattach:attachElementToBone(effect, localPlayer, 1, 0, 0, 0, 0, 0, 0)
					setEffectSpeed (effect, 0.1 )
					setTimer(function()
						destroyElement(effect)
					end, 10000, 1)	
				else
					exports.cosmo_hud:showInfobox("error", "Csak 10 másodpercenként használhatod.")
				end
			elseif itemId == 177 then
				if getTickCount() - petardaTick >= 15000 then
					triggerServerEvent("useItem", localPlayer, itemDbId)
					petardaTick = getTickCount()
				else
					exports.cosmo_hud:showInfobox("error", "Várj egy kicsit.")
				end
			elseif itemId == 178 then
				if getTickCount() - petardaTick >= 15000 then
					triggerServerEvent("useItem", localPlayer, itemDbId)
					petardaTick = getTickCount()
				else
					exports.cosmo_hud:showInfobox("error", "Várj egy kicsit.")
				end
			elseif itemId == 181 then
				if inCraftShape then
					--exports.cosmo_minigames:startMinigame("buttons", "successOpen", "failedOpen", 0.27, 0.75, 175, math.random(40, 60))
					exports["cosmo_balanceminigame"]:setBalanceQTEState(true, 1, "cosmo_inventory")
					setElementFrozen(localPlayer, true)
					triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)
					triggerServerEvent("startKaziOpen", resourceRoot, localPlayer)				
				end
			else
				triggerServerEvent("useItem", localPlayer, itemDbId)
			end


		elseif itemId == 244 then
			if inCraftShape then
				exports.cosmo_minigames:startMinigame("buttons", "successOpen", "failedOpen", 0.27, 0.75, 175, math.random(40, 60))
				triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)
			end
		else
			triggerServerEvent("useItem", localPlayer, itemDbId)
		end
		end
	end

local sounds = {}

function petarda(player, type)
	if player and isElement(player) then
		if type == "kicsi" then		
			local x, y, z = getElementPosition(player)
			local sound = playSound3D("files/sounds/smallfirework.mp3", x, y, z, false)
			sounds[player] = sound
			setSoundMaxDistance(sounds[player], 50)
			setSoundVolume(sounds[player], 1)
		elseif type == "nagy" then		
			local x, y, z = getElementPosition(player)
			local sound = playSound3D("files/sounds/largefirework.mp3", x, y, z, false)
			sounds[player] = sound
			setSoundMaxDistance(sounds[player], 150)
			setSoundVolume(sounds[player], 1)		
		end
	end
end
addEvent("petardaUse", true)
addEventHandler("petardaUse", root, petarda)

function onQuitGame( )
    sounds[source] = nil
	setElementData(source, "inATMCasette", false)
end
addEventHandler("onClientPlayerQuit", getRootElement(), onQuitGame )

function onQuitGamee( )
    sounds[source] = nil
	setElementData(source, "inShopCasette", false)
end
addEventHandler("onClientPlayerQuit", getRootElement(), onQuitGamee )

local weaponFireCount = 0

addEventHandler("onClientPlayerWeaponFire", getLocalPlayer(),
	function (weaponId)
		local weaponInUse = false
		local ammoInUse = false

		for k, v in pairs(itemsTable.player) do
			if v.inUse then
				if isWeaponItem(v.itemId) then
					weaponInUse = v
				elseif isAmmoItem(v.itemId) then
					ammoInUse = v
				end
			end
		end

		local itemAmmoId = getItemAmmoID(weaponInUse.itemId)

		if weaponInUse and not ammoInUse and itemAmmoId and (itemAmmoId <= 0 or itemAmmoId == weaponInUse.itemId) then
			ammoInUse = weaponInUse
		end

		if weaponInUse and ammoInUse and ammoInUse.amount and weaponInUse.itemId ~= 110 then
			if weaponId == 43 then
				exports.cosmo_chat:sendLocalMeAction(localPlayer, "készít egy képet a kamerával.")
				
				if (tonumber(ammoInUse.data1) or 0) + 5 >= 100 then
					triggerEvent("updateItemData1", localPlayer, "player", ammoInUse.dbID, 100, true)

					if getItemAmmoID(itemsTable.player[weaponInUse.slot].itemId) ~= weaponInUse.itemId then
						triggerServerEvent("giveWeapon", localPlayer, weaponInUse.itemId, weaponId, 1)
						togglePlayerWeaponFire(false)
					end

					exports.cosmo_hud:showInfobox("warning", "Betelt a kamera SD kártyája!")
				else
					triggerEvent("updateItemData1", localPlayer, "player", ammoInUse.dbID, (tonumber(itemsTable.player[ammoInUse.slot].data1) or 0) + 5, true)
				end
			else
				if weaponInUse.itemId ~= ammoInUse.itemId and getPedTotalAmmo(localPlayer) > ammoInUse.amount - 1 and ammoInUse.amount - 1 == 0 then
					togglePlayerWeaponFire(false)
				end

				if ammoInUse.amount - 1 > 0 then
					if itemsTable.player[ammoInUse.slot].amount then
						weaponFireCount = weaponFireCount + 1

						itemsTable.player[ammoInUse.slot].amount = itemsTable.player[ammoInUse.slot].amount - 1

						if weaponId == 24 or weaponId == 25 or weaponId == 33 or weaponId == 34 or (weaponId >= 16 and weaponId <= 18) then
							triggerServerEvent("updateItemAmount", localPlayer, localPlayer, ammoInUse.dbID, itemsTable.player[ammoInUse.slot].amount)
							weaponFireCount = 0
						elseif weaponFireCount == 4 then
							triggerServerEvent("updateItemAmount", localPlayer, localPlayer, ammoInUse.dbID, itemsTable.player[ammoInUse.slot].amount)
							weaponFireCount = 0
						end

						triggerEvent("movedItemInInventory", localPlayer, true)
					end
				else
					triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[ammoInUse.slot].dbID)
					itemsTable.player[ammoInUse.slot] = nil
				end
			end
		end
	end
)

function togglePlayerWeaponFire(state)
	if state then
		if getElementData(localPlayer, "playerNoAmmo") then
			exports.cosmo_controls:toggleControl({"fire", "vehicle_fire", "action"}, true)
			setElementData(localPlayer, "playerNoAmmo", false)
		end
	else
		if not getElementData(localPlayer, "playerNoAmmo") then
			exports.cosmo_controls:toggleControl({"fire", "vehicle_fire", "action"}, false)
			setElementData(localPlayer, "playerNoAmmo", true)
		end
	end
end

function processPerishableItems()
	for k, v in pairs(itemsTable.player) do
		if perishableItems[v.itemId] then
			local perishableAmount = (tonumber(v.data3) or 0) + 1

			if perishableAmount - 1 > perishableItems[v.itemId] then
				triggerEvent("updateItemData3", localPlayer, "player", v.dbID, perishableItems[v.itemId], true)
			end

			if perishableAmount <= perishableItems[v.itemId] then
				triggerEvent("updateItemData3", localPlayer, "player", v.dbID, perishableAmount, true)
			elseif perishableEvent[v.itemId] then
				triggerServerEvent(perishableEvent[v.itemId], localPlayer, v.dbID)
			end
		end
	end
end

function getLocalPlayerItems()
	return itemsTable.player
end

function countEmptySlots(category)
	local x = 0

	if not category then
		for i = 0, defaultSettings.slotLimit - 1 do
			if not itemsTable.player[i] then
				x = x + 1
			end
		end
	elseif category == "keys" then
		for i = defaultSettings.slotLimit, defaultSettings.slotLimit * 2 - 1 do
			if not itemsTable.player[i] then
				x = x + 1
			end
		end
	elseif category == "papers" then
		for i = defaultSettings.slotLimit * 2, defaultSettings.slotLimit * 3 - 1 do
			if not itemsTable.player[i] then
				x = x + 1
			end
		end
	end

	return x
end

function countItemsByItemID(itemId, countAmount)
	local x = 0

	for i = 0, defaultSettings.slotLimit * 3 - 1 do
		if itemsTable.player[i] and itemsTable.player[i].itemId == itemId then
			if countAmount then
				x = x + itemsTable.player[i].amount
			else
				x = x + 1
			end
		end
	end

	return x
end

function hasItem(itemId)
	for k, v in pairs(itemsTable.player) do
		if v.itemId == itemId then
			return v
		end
	end

	return false
end

function hasItemWithData(itemId, dataType, data)
	data = tonumber(data) or data

	for k, v in pairs(itemsTable.player) do
		if v.itemId == itemId and (tonumber(v[dataType]) or v[dataType]) == data then
			return v
		end
	end
	
	return false
end

function getItemsWeight(elementType)
	local weight = 0
	
	if itemsTable[elementType] then
		for k, v in pairs(itemsTable[elementType]) do
			if availableItems[v.itemId] then
				weight = weight + getItemWeight(v.itemId) * v.amount
			end
		end
	end
	
	return weight
end

function getCurrentWeight()
	local weight = 0
	
	for k, v in pairs(itemsTable.player) do
		if availableItems[v.itemId] then
			weight = weight + getItemWeight(v.itemId) * v.amount
		end
	end
	
	return weight
end

addEvent("updateInUse", true)
addEventHandler("updateInUse", getRootElement(),
	function (ownerType, itemDbId, newState)
		if itemsTable[ownerType] then
			itemDbId = tonumber(itemDbId)

			if itemDbId then
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemDbId then
						itemsTable[ownerType][v.slot].inUse = newState
						break
					end
				end
			end
		end
	end
)

addEvent("updateItemID", true)
addEventHandler("updateItemID", getRootElement(),
	function (ownerType, itemDbId, newId)
		if itemsTable[ownerType] then
			itemDbId = tonumber(itemDbId)
			newId = tonumber(newId)

			if itemDbId and newId then
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemDbId then
						itemsTable[ownerType][v.slot].itemId = newId
						break
					end
				end
			end
		end
	end
)

addEvent("updateItemData3", true)
addEventHandler("updateItemData3", getRootElement(),
	function (ownerType, itemDbId, newData, sync)
		if itemsTable[ownerType] then
			itemDbId = tonumber(itemDbId)

			if itemDbId and newData then
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemDbId then
						itemsTable[ownerType][v.slot].data3 = newData
						if sync then
							triggerServerEvent("updateItemData3", localPlayer, localPlayer, itemDbId, newData)
						end

						break
					end
				end
			end
		end
	end
)

addEvent("updateItemData2", true)
addEventHandler("updateItemData2", getRootElement(),
	function (ownerType, itemDbId, newData, sync)
		if itemsTable[ownerType] then
			itemDbId = tonumber(itemDbId)

			if itemDbId and newData then
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemDbId then
						itemsTable[ownerType][v.slot].data2 = newData

						if sync then
							triggerServerEvent("updateItemData2", localPlayer, localPlayer, itemDbId, newData)
						end

						break
					end
				end
			end
		end
	end
)

addEvent("updateItemData1", true)
addEventHandler("updateItemData1", getRootElement(),
	function (ownerType, itemDbId, newData, sync)
		if itemsTable[ownerType] then
			itemDbId = tonumber(itemDbId)
			newData = tonumber(newData) or newData

			if itemDbId and newData then
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemDbId then
						itemsTable[ownerType][v.slot].data1 = newData

						if sync then
							triggerServerEvent("updateItemData1", localPlayer, localPlayer, itemDbId, newData)
						end

						break
					end
				end
			end
		end
	end
)

addEvent("updateItemNametag", true)
addEventHandler("updateItemNametag", getRootElement(),
	function (ownerType, itemDbId, newData, sync)
		if itemsTable[ownerType] then
			itemDbId = tonumber(itemDbId)

			if itemDbId and newData then
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemDbId then
						itemsTable[ownerType][v.slot].nameTag = newData

						if sync then
							triggerServerEvent("updateItemNametag", localPlayer, localPlayer, itemDbId, newData)
						end

						break
					end
				end
			end
		end
	end
)

addEvent("updateItemAmount", true)
addEventHandler("updateItemAmount", getRootElement(),
	function (ownerType, itemDbId, newAmount)
		if itemsTable[ownerType] then
			itemDbId = tonumber(itemDbId)
			newAmount = tonumber(newAmount)
			
			if itemDbId and newAmount then
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemDbId then
						itemsTable[ownerType][v.slot].amount = newAmount
						break
					end
				end
			end
		end
	end
)

addEvent("unLockItem", true)
addEventHandler("unLockItem", getRootElement(),
	function (ownerType, slot)
		if itemsTable[ownerType] and itemsTable[ownerType][slot] and itemsTable[ownerType][slot].locked then
			itemsTable[ownerType][slot].locked = false
		end
	end
)

function takeItem(itemID)
	if (itemID > -1) then
		local haveItem = hasItem(itemID)
		--outputChatBox(inspect(haveItem))
		--function(sourceElement, itemKey, itemValue, amount)
		
		--triggerServerEvent()
		if haveItem then
			print("done")
			triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", haveItem.dbID, 1)
			--triggerEvent("deleteItem", localPlayer, localPlayer, itemsTable["player"][haveItem.dbID])
		end
	end
end


addEvent("deleteItem", true)
addEventHandler("deleteItem", getRootElement(),
	function (ownerType, items)
		if itemsTable[ownerType] and items and type(items) == "table" then
			for k, v in pairs(items) do
				for i = 0, defaultSettings.slotLimit * 3 - 1 do
					if itemsTable[ownerType][i] and itemsTable[ownerType][i].dbID == v then
						itemsTable[ownerType][i] = nil
						
						if movedslotId == i then
							movedslotId = false
						end
					end
				end
			end
		end
	end
)

function addItem(ownerType, dbID, slot, itemId, amount, data1, data2, data3,nameTag)
	if dbID and slot and itemId and amount and not itemsTable[ownerType][slot] then
		itemsTable[ownerType][slot] = {}
		itemsTable[ownerType][slot].dbID = dbID
		itemsTable[ownerType][slot].slot = slot
		itemsTable[ownerType][slot].itemId = itemId
		itemsTable[ownerType][slot].amount = amount
		itemsTable[ownerType][slot].data1 = data1
		itemsTable[ownerType][slot].data2 = data2
		itemsTable[ownerType][slot].data3 = data3
		itemsTable[ownerType][slot].inUse = false
		itemsTable[ownerType][slot].locked = false
		itemsTable[ownerType][slot].nameTag = nameTag or nil
		--print("nameTag: "..tostring(nameTag).." dbid: "..tostring(dbID))
	end
end

addEvent("addItem", true)
addEventHandler("addItem", getRootElement(),
	function (ownerType, item)
		if itemsTable[ownerType] and item and type(item) == "table" then
			addItem(ownerType, item.dbID, item.slot, item.itemId, item.amount, item.data1, item.data2, item.data3, item.nameTag)
			--print(item.nameTag)
		end
	end
)

addEvent("loadItems", true)
addEventHandler("loadItems", getRootElement(),
	function (items, ownerType, inventoryElement, otherType)
		if items and type(items) == "table" then
			itemsTable[ownerType] = {}

			for k, v in pairs(items) do
				addItem(tostring(ownerType), v.dbID, v.slot, v.itemId, v.amount, v.data1, v.data2, v.data3, v.nameTag)
				if ownerType == "player" and v.itemId == 79 then
					exports.cosmo_hud:setWalkieTalkieData(v.dbID, v.data1, v.data2)
				end
			end

			if otherType then
				toggleInventory(false)
				currentInventoryElement = inventoryElement
				itemsTableState = ownerType
				toggleInventory(true)
			else
				itemsLoaded = true
			end

			triggerEvent("movedItemInInventory", localPlayer)
		end
	end
)

function isPointOnInventory(x, y)
	if panelState then
		if x >= panelPosX and x <= panelPosX + panelWidth and y >= panelPosY and y <= panelPosY + panelHeight then
			return true
		else
			return false
		end
	else
		return false
	end
end

function findSlot(x, y)
	if panelState then
		local slotId = false
		local slotPosX, slotPosY = false, false

		for i = 0, defaultSettings.slotLimit - 1 do
			local x2 = panelPosX + (defaultSettings.slotBoxWidth + 5) * (i % defaultSettings.width)
			local y2 = panelPosY + (defaultSettings.slotBoxHeight + 5) * math.floor(i / defaultSettings.width)

			if x >= x2 and x <= x2 + defaultSettings.slotBoxWidth and y >= y2 and y <= y2 + defaultSettings.slotBoxHeight then
				slotId = tonumber(i)
				slotPosX, slotPosY = x2, y2
				break
			end
		end

		if slotId then
			if itemsTableState == "player" and currentCategory == "keys" then
				slotId = slotId + defaultSettings.slotLimit
			elseif itemsTableState == "player" and currentCategory == "papers" then
				slotId = slotId + defaultSettings.slotLimit * 2
			end

			return slotId, slotPosX, slotPosY
		else
			return false
		end
	else
		return false
	end
end

function findEmptySlot(ownerType)
	local emptySlot = false
	
	for i = 0, defaultSettings.slotLimit - 1 do
		if not itemsTable[ownerType][i] then
			emptySlot = i
			break
		end
	end
	
	return emptySlot
end

function findEmptySlotOfKeys(ownerType)
	local emptySlot = false
	
	for i = defaultSettings.slotLimit, defaultSettings.slotLimit * 2 - 1 do
		if not itemsTable[ownerType][i] then
			emptySlot = i
			break
		end
	end
	
	return emptySlot
end

function findEmptySlotOfPapers(ownerType)
	local emptySlot = false
	
	for i = defaultSettings.slotLimit * 2, defaultSettings.slotLimit * 3 - 1 do
		if not itemsTable[ownerType][i] then
			emptySlot = i
			break
		end
	end
	
	return emptySlot
end

function bootCheck(vehicle)
	local componentPosX, componentPosY, componentPosZ = getVehicleComponentPosition(vehicle, "boot_dummy", "world")

	if not componentPosX or not componentPosY or getVehicleType(vehicle) ~= "Automobile" then
		return true
	end

	local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
	local vehiclePosX, vehiclePosY, vehiclePosZ = getElementPosition(vehicle)
	local vehicleRotX, vehicleRotY, vehicleRotZ = getElementRotation(vehicle)

	if getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, componentPosX, componentPosY, componentPosZ) < 1.75 then
		local angle = math.deg(math.atan2(vehiclePosY - playerPosY, vehiclePosX - playerPosX)) + 180 - vehicleRotZ

		if angle < 0 then
			angle = angle + 360
		end

		if angle > 250 and angle <= 285 then
			return true
		end
	end

	return false
end

addEvent("failedToMoveItem", true)
addEventHandler("failedToMoveItem", getRootElement(),
	function (failSlot, originalSlot, amount)
		if originalSlot then
			itemsTable[itemsTableState][originalSlot] = itemsTable[itemsTableState][failSlot]
			itemsTable[itemsTableState][originalSlot].slot = originalSlot
			itemsTable[itemsTableState][failSlot] = nil
		elseif stackAmount > 0 then
			itemsTable[itemsTableState][originalSlot].amount = amount
		end
	end
)

addEventHandler("onClientClick", getRootElement(),
	function (button, state, absX, absY, worldX, worldY, worldZ, clickedWorld)
		if button == "left" then
			if state == "up" then
				selectedInput = false

				if activeButton and string.find(activeButton, "input:") then
					selectedInput = string.gsub(activeButton, "input:", "")
					inputCursorState = true
					lastChangeCursorState = getTickCount()
				end
			end

			if friskTableState then
				if not friskPanelIsMoving then
					if state == "down" then
						if absX >= friskPanelPosX and absX <= friskPanelPosX + panelWidth - 50 - 15 and absY >= friskPanelPosY - 30 and absY <= friskPanelPosY then
							moveDifferenceX = absX - friskPanelPosX
							moveDifferenceY = absY - friskPanelPosY
							friskPanelIsMoving = true
							return
						end

						if friskCategoryHover and friskCategoryHover ~= friskCategory then
							friskCatInterpolate = getTickCount()

							friskLastCategory = friskCategory
							friskCategory = friskCategoryHover

							playSound(":cosmo_assets/audio/interface/3.ogg")
						end
					end
				elseif state == "up" and friskTableState then
					friskPanelIsMoving = false
					moveDifferenceX, moveDifferenceY = 0, 0
				end
			end

			if panelState then
				if not panelIsMoving then
					if state == "down" then
						if absX >= panelPosX and absX <= panelPosX + panelWidth - 50 - 15 and absY >= panelPosY - 85 and absY <= panelPosY then
							moveDifferenceX = absX - panelPosX
							moveDifferenceY = absY - panelPosY
							panelIsMoving = true
							return
						end

						if itemsTableState == "player" then
							if categoryHover and categoryHover ~= currentCategory then
								tabLineInterpolation = getTickCount()

								lastCategory = currentCategory
								currentCategory = categoryHover

								playSound(":cosmo_assets/audio/interface/3.ogg")
							end
						end

						local hoveredSlot, slotPosX, slotPosY = findSlot(absX, absY)

						if hoveredSlot and itemsTable[itemsTableState][hoveredSlot] then
							if not itemsTable[itemsTableState][hoveredSlot].inUse then
								haveMoving = true
								movedslotId = hoveredSlot

								moveDifferenceX = absX - slotPosX
								moveDifferenceY = absY - slotPosY
							else
								exports.cosmo_hud:showInfobox("error", "Használatban lévő itemet nem mozgathatsz!")
							end
						end
					elseif state == "up" then
						if movedslotId then
							local hoveredSlot = findSlot(absX, absY)
							local movedItem = itemsTable[itemsTableState][movedslotId]

							if hoverShowItem then
								if getTickCount() - lastShowItemTick >= 5500 then
									lastShowItemTick = getTickCount()

									if movedItem.nameTag then
										movedItemName = getItemName(movedItem.itemId) .. " #d75959(" .. movedItem.nameTag .. ")"
									else
										movedItemName = getItemName(movedItem.itemId)
									end

									if availableItems[movedItem.itemId] then
										exports.cosmo_chat:sendLocalMeAction(localPlayer, "felmutat egy tárgyat: " .. movedItemName)
									else
										exports.cosmo_chat:sendLocalMeAction(localPlayer, "felmutat egy tárgyat.")
									end

									triggerServerEvent("showTheItem", localPlayer, movedItem, getElementsByType("player", getRootElement(), true))
								end
							elseif hoveredSlot then
								if itemsTableState == "player" and isKeyItem(movedItem.itemId) and hoveredSlot < defaultSettings.slotLimit then
									hoveredSlot = findEmptySlotOfKeys("player")

									if not hoveredSlot then
										return
									end

									exports.cosmo_hud:showInfobox("warning", "Ez az item átkerült a kulcsokhoz!")
								end

								if itemsTableState == "player" and isPaperItem(movedItem.itemId) and hoveredSlot < defaultSettings.slotLimit then
									hoveredSlot = findEmptySlotOfPapers("player")

									if not hoveredSlot then
										return
									end

									exports.cosmo_hud:showInfobox("warning", "Ez az item átkerült a iratokhoz!")
								end

								if movedslotId ~= hoveredSlot and movedItem then
									if hoveredSlot >= defaultSettings.slotLimit * 2 and not isPaperItem(movedItem.itemId) then
										if isKeyItem(movedItem.itemId) then
											hoveredSlot = findEmptySlotOfKeys("player")
											exports.cosmo_hud:showInfobox("warning", "Ez az item átkerült a kulcsokhoz!")
										else
											hoveredSlot = findEmptySlot("player")
											exports.cosmo_hud:showInfobox("warning", "Ez nem irat!")
										end
									elseif hoveredSlot >= defaultSettings.slotLimit and hoveredSlot < defaultSettings.slotLimit * 2 and not isKeyItem(movedItem.itemId) then
										if isPaperItem(movedItem.itemId) then
											hoveredSlot = findEmptySlotOfPapers("player")
											exports.cosmo_hud:showInfobox("warning", "Ez az item átkerült az iratokhoz!")
										else
											hoveredSlot = findEmptySlot("player")
											exports.cosmo_hud:showInfobox("warning", "Ez nem kulcs item!")
										end
									end

									if not movedItem.inUse and not movedItem.locked then
										local hoveredItem = itemsTable[itemsTableState][hoveredSlot]

										if not hoveredItem then
											triggerServerEvent("moveItem", localPlayer, movedItem.dbID, movedItem.itemId, movedslotId, hoveredSlot, stackAmount, currentInventoryElement, currentInventoryElement)

											playSound(":cosmo_assets/audio/interface/6.ogg")

											if stackAmount >= 0 then
												if stackAmount >= movedItem.amount or stackAmount <= 0 then
													itemsTable[itemsTableState][hoveredSlot] = itemsTable[itemsTableState][movedslotId]
													itemsTable[itemsTableState][hoveredSlot].slot = hoveredSlot
													itemsTable[itemsTableState][movedslotId] = nil
												elseif stackAmount > 0 then
													itemsTable[itemsTableState][movedslotId].amount = itemsTable[itemsTableState][movedslotId].amount - stackAmount
												end
											end
										elseif movedItem.itemId == hoveredItem.itemId and isItemStackable(hoveredItem.itemId) then
											if stackAmount >= 0 then
												if (movedItem.data3 == "duty" or hoveredItem.data3 == "duty") and (movedItem.data3 ~= "duty" or hoveredItem.data3 ~= "duty") then
													exports.cosmo_hud:showInfobox("error", "Szolgálati eszközzel ezt nem teheted meg!")
												else
													local amount = stackAmount

													if amount <= 0 or amount >= movedItem.amount then
														amount = movedItem.amount
													end

													playSound(":cosmo_assets/audio/interface/6.ogg")

													if movedItem.amount - amount > 0 then
														triggerServerEvent("updateItemAmount", localPlayer, currentInventoryElement, hoveredItem.dbID, hoveredItem.amount + amount)
														itemsTable[itemsTableState][hoveredSlot].amount = itemsTable[itemsTableState][hoveredSlot].amount + amount

														triggerServerEvent("updateItemAmount", localPlayer, currentInventoryElement, movedItem.dbID, movedItem.amount - amount)
														itemsTable[itemsTableState][movedslotId].amount = itemsTable[itemsTableState][movedslotId].amount - amount
													else
														triggerServerEvent("updateItemAmount", localPlayer, currentInventoryElement, hoveredItem.dbID, hoveredItem.amount + movedItem.amount)
														itemsTable[itemsTableState][hoveredSlot].amount = itemsTable[itemsTableState][hoveredSlot].amount + movedItem.amount

														triggerServerEvent("takeItem", localPlayer, currentInventoryElement, "dbID", movedItem.dbID)
														itemsTable[itemsTableState][movedslotId] = nil
													end

													triggerEvent("movedItemInInventory", localPlayer, true)
												end
											end
										end
									end
								end
							elseif isPointOnActionBar(absX, absY) then
								if itemsTableState == "player" then
									hoveredSlot = findActionBarSlot(absX, absY)

									if hoveredSlot then
										putOnActionBar(hoveredSlot, itemsTable[itemsTableState][movedslotId])
										playSound(":cosmo_assets/audio/interface/6.ogg")
									end
								end
							elseif not movedItem.locked and not movedItem.inUse and not isPointOnInventory(absX, absY) then
								if isElement(clickedWorld) then
									local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
									local targetPosX, targetPosY, targetPosZ = getElementPosition(clickedWorld)
									local clickedElementType = getElementType(clickedWorld)

									if movedItem.itemId == 118 or movedItem.itemId == 119 then
										exports.cosmo_hud:showInfobox("error", "Ezt az itemet nem dobhatod ki és nem adhatod át másnak!")
										movedslotId = false
										haveMoving = false
										return
									end

									if clickedElementType == "object" and isTrashModel(getElementModel(clickedWorld)) and not getElementAttachedTo(clickedWorld) and itemsTableState == "player" then
										if getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, targetPosX, targetPosY, targetPosZ) <= 4 then
											if availableItems[movedItem.itemId] then
												exports.cosmo_chat:sendLocalMeAction(localPlayer, "kidobott egy tárgyat a szemetesbe. (" .. getItemName(movedItem.itemId) .. ")")
											else
												exports.cosmo_chat:sendLocalMeAction(localPlayer, "kidobott egy tárgyat a szemetesbe.")
											end

											if stackAmount > 0 and stackAmount < movedItem.amount then
												triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", movedItem.dbID, stackAmount)
											else
												triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", movedItem.dbID)
											end

											if movedItem.itemId == 79 then 
												local currentRadioTune = getElementData(localPlayer, "currentRadioTune")
	
												if currentRadioTune then 
													setElementData(localPlayer, "currentRadioTune", nil)
													setElementData(localPlayer, "char.voice", "local")
												end
											end
										end
									else
										if movedItem.data3 == "duty" then
											exports.cosmo_hud:showInfobox("error", "Szolgálati eszközzel ezt nem teheted meg!")
										else
											if getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, targetPosX, targetPosY, targetPosZ) <= 8 then
												if not (clickedElementType == "player" and clickedWorld == localPlayer and itemsTableState == "player") then
													if (itemsTableState == "vehicle" or itemsTableState == "object") and (clickedElementType ~= "player" or clickedWorld ~= localPlayer) then
														exports.cosmo_hud:showInfobox("error", "Járműből / széfből csak a saját inventorydba pakolhatsz!")
													else
														local hitDatabaseId = getElementDatabaseId(clickedWorld)

														if tonumber(hitDatabaseId) then
															if clickedElementType == "vehicle" then
																if not bootCheck(clickedWorld) then
																	exports.cosmo_hud:showInfobox("error", "Csak a jármű csomagtartójánál állva rakhatsz tárgyat a csomagtérbe!")
																	movedslotId = false
																	haveMoving = false
																	return
																end
															elseif clickedElementType == "object" and getElementData(clickedWorld, "60") then
																if not hasItemWithData(127, "data1", getElementData(clickedWorld, "60")) then
																	movedslotId = false
																	haveMoving = false
																	return
																end
															end

															if movedItem.itemId == 181 and clickedElementType == "vehicle" then
																exports.cosmo_hud:showInfobox("error", "Ezt az itemet nem rakhatod jármű csomagtartójába.")
																movedslotId = false
																haveMoving = false
																return
															end
															if movedItem.itemId == 181 and clickedElementType == "object" then
																exports.cosmo_hud:showInfobox("error", "Ezt az itemet nem rakhatod széfbe.")
																movedslotId = false
																haveMoving = false
																return
															end

															if movedItem.itemId == 244 and clickedElementType == "vehicle" then
																exports.cosmo_hud:showInfobox("error", "Ezt az itemet nem rakhatod jármű csomagtartójába.")
																movedslotId = false
																haveMoving = false
																return
															end
															if movedItem.itemId == 244 and clickedElementType == "object" then
																exports.cosmo_hud:showInfobox("error", "Ezt az itemet nem rakhatod széfbe.")
																movedslotId = false
																haveMoving = false
																return
															end

															itemsTable[itemsTableState][movedslotId].locked = true
															
															triggerServerEvent("moveItem", localPlayer, movedItem.dbID, movedItem.itemId, movedslotId, false, stackAmount, currentInventoryElement, clickedWorld)
															itemsTable[itemsTableState][movedslotId].locked = true
															
															triggerServerEvent("moveItem", localPlayer, movedItem.dbID, movedItem.itemId, movedslotId, false, stackAmount, currentInventoryElement, clickedWorld)
														elseif isItemCanBePrint(movedItem.itemId) then
															if getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, targetPosX, targetPosY, targetPosZ) <= 4 then
																if clickedElementType == "object" then
																	if getElementData(clickedWorld, "object.Printer") then
																		if getElementData(clickedWorld, "printer.Used") == false then
																		local prX, prY, prZ = getElementPosition(clickedWorld)
																			triggerServerEvent("addItem", resourceRoot, localPlayer, movedItem.itemId, 1, false, movedItem.data1, false, "printed")
																			triggerServerEvent("printSound", resourceRoot, prX, prY, prZ, clickedWorld)
																			triggerServerEvent("printAnim", resourceRoot, localPlayer)
																			setElementData(localPlayer, "char.Money", getElementData(localPlayer, "char.Money") - 10)
																			setElementData(clickedWorld, "printer.Used", true)
																		else
																			outputChatBox("#ff9428[CosmoMTA - Nyomtatás]:#ffffff A nyomtató jelenleg használatban van!", 255, 255, 255, true)
																		end
																	end
																end
															end
														--[[elseif movedItem.itemId == 189 then
															if getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, targetPosX, targetPosY, targetPosZ) <= 4 then
																--if clickedElementType == "object" then
																outputChatBox(worldX, worldY, worldZ)
																--end
															end]]
														else
															exports.cosmo_hud:showInfobox("error", "A kiválasztott elem nem rendelkezik önálló tárterülettel!")
														end
													end
												end
											end
										end
									end
								end
							end

							movedslotId = false
							haveMoving = false
						end
					end
				elseif state == "up" and panelState then
					panelIsMoving = false
					moveDifferenceX, moveDifferenceY = 0, 0
				end
			end
		elseif button == "right" and state == "up" then
			local hoveredSlot, slotX, slotY = findSlot(absX, absY)
			local vitem = itemsTable[itemsTableState][hoveredSlot]

			--[[friskTableState.items[v.slot] = {
				itemId = v.itemId,
				dbID = v.dbID,
				amount = v.amount,
				data1 = v.data1,
				data2 = v.data2,
				data3 = v.data3
			}]]
			-- item datak vagymik

			if hoveredSlot and vitem then
				if vitem and useingNametag and not (vitem.itemId == 246) and not (nametagX) then
					nametagX, nametagY = slotX + defaultSettings.slotBoxWidth, slotY
					nametagID = vitem.dbID
					--outputChatBox("cigany")
					useingNametagIcon = false
				end
				if vitem.amount < 2 then 
					if (vitem.itemId == 246) and not useingNametag then
						useingNametag = true
						useingNametagIcon = true
						usedNametag = vitem
						print(tostring(useingNametag))
						outputChatBox("#ff9428[CosmoMTA - Inventory]: #ffffffKlikkelj jobb klikkel a kiválasztott itemre!", 255, 255, 255, true)
						exports.cosmo_controls:toggleControl({"all"}, false)
					end
				else
					outputChatBox("#ff9428[CosmoMTA - Inventory]: #ffffffAz item stackelve van, ezért nem használhatod!", 255, 255, 255, true)
				end
			end

			if panelState then
				if hoveredSlot then
					if itemsTable[itemsTableState][hoveredSlot] and not (vitem.itemId == 246) and not useingNametag then
						print("hasznalva")
						useItem(itemsTable[itemsTableState][hoveredSlot].dbID)
						movedslotId = false
					end
				end
			end
		end
	end
)

addEvent("rottenEffect", true)
addEventHandler("rottenEffect", getRootElement(),
	function (amount)
		rottenEffect = {getTickCount(), amount}
	end
)

addEvent("printSoundC", true)
addEventHandler("printSoundC", getRootElement(),
	function (prX, prY, prZ, clickedWorld)
		local tS = playSound3D("files/copy.mp3", prX, prY, prZ, false)
		setSoundMaxDistance(tS, 10)
		setElementDimension(tS, getElementDimension(clickedWorld))
		setElementInterior(tS, getElementInterior(clickedWorld))
		local tm = getSoundLength(tS)
		setTimer(function()
			--outputChatBox("anal")
			--outputChatBox(tostring(tm))
			setElementData(clickedWorld, "printer.Used", false)
		end, tm*1000, 1)
	end
)

addEventHandler("onClientRender", getRootElement(),
	function ()
		if rottenEffect then
			local currentTick = getTickCount()
			local elapsedTime = currentTick - rottenEffect[1]
			local progress = elapsedTime / 750
			
			local alpha = interpolateBetween(0, 0, 0, 150 * rottenEffect[2] + 55, 0, 0, progress, "InQuad")

			if progress - 1 > 0 then
				alpha = interpolateBetween(150 * rottenEffect[2] + 55, 0, 0, 0, 0, 0, progress - 1, "OutQuad")
			end

			if progress > 2 then
				rottenEffect = false
			end

			dxDrawImage(0, 0, screenX, screenY, "files/vin.png", 0, 0, 0, tocolor(20, 100, 40, alpha))
		end
	end
)

local showedItems = {}
local showItemsHandled = false

addEvent("showTheItem", true)
addEventHandler("showTheItem", getRootElement(),
	function (item)
		if item.nameTag then
			itemName = getItemName(item.itemId) .. " #d75959(" .. item.nameTag .. ")"
		else
			itemName = getItemName(item.itemId)
		end

		local sx, sy = processTooltip(0, 0, itemName, item.itemId, item, true)

		sy = sy + 8

		table.insert(showedItems, {source, getTickCount(), item, dxCreateRenderTarget(sx, sy, true), sx, sy})

		processShowItem()
	end
)
function processShowItem(hide)
	if #showedItems > 0 then
		if not showItemsHandled then
			addEventHandler("onClientRender", getRootElement(), renderShowItem)
			addEventHandler("onClientRestore", getRootElement(), processShowItem)
			showItemsHandled = true
		end

		if not hide and showedItems then
			for i = 1, #showedItems do
				if showedItems[i] then
					local item = showedItems[i][3]

					dxSetRenderTarget(showedItems[i][4], true)

					dxSetBlendMode("modulate_add")

					if item.nameTag then
						itemName = getItemName(item.itemId) .. " #d75959(" .. item.nameTag .. ")"
					else
						itemName = getItemName(item.itemId)
					end

					processTooltip(0, 0, itemName, item.itemId, item, false, showedItems[i][5])
				end
			end

			dxSetBlendMode("blend")

			dxSetRenderTarget()
		end
	elseif showItemsHandled then
		removeEventHandler("onClientRender", getRootElement(), renderShowItem)
		removeEventHandler("onClientRestore", getRootElement(), processShowItem)
		showItemsHandled = false
	end
end

function renderShowItem()
	local currentTick = getTickCount()
	local cameraPosX, cameraPosY, cameraPosZ = getCameraMatrix()
	local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)

	if showedItems then
		for i = 1, #showedItems do
			if showedItems[i] then
				local elapsedTime = currentTick - showedItems[i][2]
				local progress = 255
				
				if elapsedTime < 500 then
					progress = 255 * elapsedTime / 500
				end

				if elapsedTime > 5000 then
					progress = 255 - (255 * (elapsedTime - 5000) / 500)

					if progress < 0 then
						progress = 0
					end

					if elapsedTime > 5500 then
						showedItems[i] = nil
						processShowItem(true)
					end
				end

				if showedItems[i] then
					local sourcePlayer = showedItems[i][1]

					if isElement(sourcePlayer) then
						local sourcePosX, sourcePosY, sourcePosZ = getElementPosition(sourcePlayer)
						local distance = getDistanceBetweenPoints3D(sourcePosX, sourcePosY, sourcePosZ, playerPosX, playerPosY, playerPosZ)
						
						if distance < 10 then
							if isLineOfSightClear(cameraPosX, cameraPosY, cameraPosZ, sourcePosX, sourcePosY, sourcePosZ, true, false, false, true, false, true, false) then
								local multipler = 1

								if distance > 7.5 then
									multipler = 1 - (distance - 7.5) / 2.5
								end

								local x, y, z = getPedBonePosition(sourcePlayer, 5)
								x, y = getScreenFromWorldPosition(x, y, z + 0.55)

								if x and y then
									dxDrawImage(math.floor(x - showedItems[i][5] / 2), math.floor(y - showedItems[i][6] / 2) + (255 - progress) / 4, showedItems[i][5], showedItems[i][6], showedItems[i][4], 0, 0, 0, tocolor(255, 255, 255, progress * 0.9 * multipler))
								end
							end
						end
					end
				end
			end
		end
	end
end
local x,y = guiGetScreenSize()

function isInSlot(dX, dY, dSZ, dM) --Létre hozzuk az isInSlot funkciót (Amit később majd meghívunk).
	if isCursorShowing() then --Ha látszódik a kurzor.
		local cX ,cY = getCursorPosition() --Lekéri a kurzor pozícióját.
		cX,cY = cX*x , cY*y --Lekéri a kurzor pozícióját az adott felbontáson.
		if(cX >= dX and cX <= dX+dSZ and cY >= dY and cY <= dY+dM) then --Ha ott van a kurzor ahol megadtuk akkor.
			return true, cX, cY --Ha a dobozban van akkor adja vissza, hogy igaz.
		else
			return false --Ha nincs a dobozban akkor adja vissza, hogy hamis.
		end
	end
end

function drawCategoryTab(x, y, k, picture, name, bodySearch)
	local colorOfTab = tocolor(145, 145, 145)
	local textWidth = dxGetTextWidth(name, 0.55, Roboto)
	local x2 = x + 24 / 2

	if not bodySearch then
		if itemsTableState ~= "player" then
			x2 = x + 24 / 2
			colorOfTab = tocolor(200, 200, 200)
		elseif currentCategory == k or absX >= x2 - 1.5 and isInSlot(x2, y, 20, 20) then
			colorOfTab = tocolor(255, 255, 255)

			if currentCategory ~= k then
				categoryHover = k
			end
		end
	elseif friskCategory == k or absX >= x2 - 1.5 and absX <= x2 + 1.5 + textWidth and absY >= y and absY <= y + 20 then
		colorOfTab = tocolor(255, 255, 255)

		if friskCategory ~= k then
			friskCategoryHover = k
		end
	end

	dxDrawImage(x2 - 1.5, y, 20, 20, "files/categories/" .. picture ..".png", 0, 0, 0, colorOfTab)
	--dxDrawText(name, x2 + 14.5, y, 0, y + 24, colorOfTab, 0.55, Roboto, "left", "center")

	return x
end

addEvent("bodySearchGetDatas", true)
addEventHandler("bodySearchGetDatas", getRootElement(),
	function (items, playerName, charMoney)
		friskTableState = {}
		friskTableState.items = {}
		friskTableState.name = playerName
		friskTableState.money = charMoney

		for k, v in pairs(items) do
			friskTableState.items[v.slot] = {
				itemId = v.itemId,
				dbID = v.dbID,
				amount = v.amount,
				data1 = v.data1,
				data2 = v.data2,
				data3 = v.data3
			}
		end

		addEventHandler("onClientRender", getRootElement(), renderBodySearch)
	end
)

function renderBodySearch()
	absX, absY = 0, 0

	buttons = {}

	if isCursorShowing() then
		local relX, relY = getCursorPosition()

		absX = screenX * relX
		absY = screenY * relY
	end

	if isCursorShowing() and friskPanelIsMoving then
		friskPanelPosX = absX - moveDifferenceX
		friskPanelPosY = absY - moveDifferenceY
	end

	-- ** Háttér
	local x = friskPanelPosX - 5
	local y = friskPanelPosY - 5

	dxDrawRectangle(x, y, friskPanelWidth, friskPanelHeight, tocolor(0, 0, 0, 170))

	-- ** Cím
	dxDrawRectangle(x, y - 30, friskPanelWidth, 30, tocolor(0, 0, 0, 170))
	--dxDrawImage(math.floor(x + 3), math.floor(y - 25), 24, 24, ":cosmo_hud/files/logo.png", 0, 0, 0, tocolor(37,117,199))
	dxDrawText("Motozás: ", x + 5, y - 25, 0, y, tocolor(255, 255, 255), 1, RobotoL, "left", "center")
	dxDrawText(friskTableState.name, x + 5 + dxGetTextWidth("Motozás: ", 1, RobotoL), y - 25, 0, y, tocolor(255, 148, 40), 0.5, Roboto, "left", "center")

	-- ** Kilépés
	local closeTextWidth = dxGetTextWidth("X", 1, RobotoL)
	local closeTextPosX = x + friskPanelWidth - closeTextWidth - 5
	local closeColor = tocolor(255, 255, 255)

	if absX >= closeTextPosX and absY >= y - 30 and absX <= closeTextPosX + closeTextWidth and absY <= y then
		closeColor = tocolor(215, 89, 89)

		if getKeyState("mouse1") then
			removeEventHandler("onClientRender", getRootElement(), renderBodySearch)
			friskTableState = false
			return
		end
	end

	dxDrawText("X", closeTextPosX, y - 25, 0, y, closeColor, 1, RobotoL, "left", "center")

	-- ** Kategóriák
	dxDrawRectangle(x, y + friskPanelHeight, friskPanelWidth, 30, tocolor(0, 0, 0, 170))

	local tabStartX = math.floor(x)
	local tabStartY = math.floor(y + friskPanelHeight)
	local sizeForTabs = friskPanelWidth / 3

	friskCategoryHover = false

	local currentCategoryId = 0
	local lastCategoryId = currentCategoryId

	if friskCategory == "keys" then
		currentCategoryId = 1
	elseif friskCategory == "papers" then
		currentCategoryId = 2
	end

	if friskLastCategory == "keys" then
		lastCategoryId = 1
	elseif friskLastCategory == "papers" then
		lastCategoryId = 2
	end

	if friskCatInterpolate and friskCategory ~= friskLastCategory then
		local elapsedTime = getTickCount() - friskCatInterpolate
		local duration = 250
		local progress = elapsedTime / duration

		local x = interpolateBetween(
			tabStartX + sizeForTabs * lastCategoryId, 0, 0,
			tabStartX + sizeForTabs * currentCategoryId, 0, 0,
			progress, "InOutQuad")

		dxDrawRectangle(x, tabStartY + 28, sizeForTabs, 2, tocolor(255, 148, 40))

		if progress >= 1 then
			friskCatInterpolate = false
		end
	else
		dxDrawRectangle(tabStartX + sizeForTabs * currentCategoryId, tabStartY + 28, sizeForTabs, 2, tocolor(255, 148, 40))
	end

	tabStartX = drawCategoryTab(tabStartX, tabStartY, "main", "bag", "Tárgyak", true)
	tabStartX = drawCategoryTab(tabStartX + sizeForTabs, tabStartY, "keys", "key", "Kulcsok", true)
	tabStartX = drawCategoryTab(tabStartX + sizeForTabs, tabStartY, "papers", "wallet", "Iratok", true)

	-- ** Itemek
	local hoveredItemSlot = false

	for i = 0, defaultSettings.slotLimit - 1 do
		local slot = i

		x = friskPanelPosX + (defaultSettings.slotBoxWidth + 5) * (slot % defaultSettings.width)
		y = friskPanelPosY + (defaultSettings.slotBoxHeight + 5) * math.floor(slot / defaultSettings.width)

		if friskCategory == "keys" then
			i = i + defaultSettings.slotLimit
		elseif friskCategory == "papers" then
			i = i + defaultSettings.slotLimit * 2
		end

		local item = friskTableState.items

		if item then
			item = friskTableState.items[i]

			if item and not availableItems[item.itemId] then
				item = false
			end
		end

		dxDrawRectangle(x, y, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, tocolor(0, 0, 0, 170))

		if item then
			if absX >= x and absX <= x + defaultSettings.slotBoxWidth and absY >= y and absY <= y + defaultSettings.slotBoxHeight then
				hoveredItemSlot = item
			end

			drawItemPicture(item, x, y)
			dxDrawText(item.amount, x + defaultSettings.slotBoxWidth - 6, y + defaultSettings.slotBoxHeight - 15, x + defaultSettings.slotBoxWidth, y + defaultSettings.slotBoxHeight - 15 + 5, tocolor(255, 255, 255), 0.375, Roboto, "right")
		end
	end

	if hoveredItemSlot then
		processTooltip(absX, absY, getItemName(hoveredItemSlot.itemId), hoveredItemSlot.itemId, hoveredItemSlot, false)
	end

	activeButton = false

	if absX and absY then
		for k, v in pairs(buttons) do
			if absX >= v[1] and absY >= v[2] and absX <= v[1] + v[3] and absY <= v[2] + v[4] then
				activeButton = k
				break
			end
		end
	end
end

function onRender()
	absX, absY = 0, 0

	buttons = {}

	if isCursorShowing() then
		local relX, relY = getCursorPosition()

		absX = screenX * relX
		absY = screenY * relY
	end

	if isCursorShowing() and panelIsMoving then
		panelPosX = absX - moveDifferenceX
		panelPosY = absY - moveDifferenceY
	end

	if currentInventoryElement ~= localPlayer and isElement(currentInventoryElement) then
		local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
		local targetPosX, targetPosY, targetPosZ = getElementPosition(currentInventoryElement)

		if getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, targetPosX, targetPosY, targetPosZ) >= 5 then
			toggleInventory(false)
			return
		end
	end

	-- ** Háttér
	local x = panelPosX - 5
	local y = panelPosY - 5

	--dxDrawRectangle(x, y, panelWidth, panelHeight, tocolor(10, 10, 10, 255))
	--dxDrawRectangle(x-3, y-30, 3, panelHeight+60, tocolor(37,117,199))
	--dxDrawRectangle(x+panelWidth, y-30, 3, panelHeight+60, tocolor(37,117,199))

	-- ** Cím
	dxDrawRectangle(x, y - 30, panelWidth, panelHeight + 60, tocolor(0, 0, 0, 170))
	dxDrawImage(math.floor(x - 3), math.floor(y - 35), 40, 40, ":cosmo_hud/files/logo.png", 0, 0, 0, tocolor(255,255,255))
	--dxDrawText("Inventory", x + 30, y - 25, 0, y, tocolor(255, 255, 255), 1, RobotoL, "left", "center")

	drawInput("stack|6|num-only", "Mennyiség", panelPosX + panelWidth - 50 - 10 - 25, panelPosY - 30 + 235, 75, 25, Roboto, 0.45)

	local drawShowItemTooltip = false
	hoverShowItem = false

	moslekcX, moslekcY = getCursorPosition()

	if movedslotId and itemsTableState == "player" and currentInventoryElement == localPlayer then
		local textWidth = dxGetTextWidth("Tárgy felmutatása", 0.5, Roboto)
		local x2 = x + (panelWidth - textWidth) / 2

		if absX >= x2 and absY >= y - 75 and absX <= x2 + textWidth and absY <= y then
			local elapsedTime = getTickCount() - lastShowItemTick

			if elapsedTime >= 5500 then
				hoverShowItem = true
			else
				drawShowItemTooltip = elapsedTime
			end

			dxDrawText("Tárgy felmutatása", x2, y - 75, 50, y, tocolor(225, 225, 225), 0.4, Roboto, "left", "center")
		else
			dxDrawText("Tárgy felmutatása", x2, y - 75, 50, y, tocolor(154, 154, 154), 0.4, Roboto, "left", "center")
		end
	end

	-- ** Súly
	local weightLimit = getWeightLimit(itemsTableState, currentInventoryElement)
	local weight = 0

	for k, v in pairs(itemsTable[itemsTableState]) do
		if availableItems[v.itemId] then
			weight = weight + getItemWeight(v.itemId) * v.amount
		end
	end

	if weight > weightLimit then
		weight = weightLimit
	end

	local sizeOfWeight = (320) * weight / weightLimit
	local weightSize = lastWeightSize

	if lastWeightSize ~= sizeOfWeight then
		if not gotWeightInterpolation then
			gotWeightInterpolation = getTickCount()
		else
			local elapsedTime =  getTickCount() - gotWeightInterpolation
			local progress = elapsedTime / 250

			weightSize = interpolateBetween(
				lastWeightSize, 0, 0,
				sizeOfWeight, 0, 0,
				progress, "OutQuad")

			if progress >= 1 then
				lastWeightSize = sizeOfWeight
				gotWeightInterpolation = false
			end
		end
	end

	--dxDrawRectangle(panelPosX + panelWidth - 15, panelPosY, 5, panelHeight - 10, tocolor(15, 15, 15, 255))
	--dxDrawRectangle(panelPosX + panelWidth - 15, panelPosY + panelHeight - 10 - weightSize, 5, weightSize, tocolor(37,117,199))
	dxDrawText(math.ceil(weight) .. "/" .. weightLimit .. "kg", 0, y - 30, panelPosX + panelWidth - 50 - 14 + 50, y, tocolor(255, 255, 230), 0.45, Roboto, "right", "center")

	-- ** Kategóriák
	--dxDrawRectangle(x, y + panelHeight, panelWidth, 30, tocolor(15, 15, 15, 255))

	local tabStartX = math.floor(x) - 35
	local tabStartY = math.floor(y + panelHeight) + 345

	categoryHover = false

	local currentCategoryId = 0
	local lastCategoryId = currentCategoryId

	if itemsTableState == "player" then
		if currentCategory == "keys" then
			currentCategoryId = 1
		elseif currentCategory == "papers" then
			currentCategoryId = 2
		end

		if lastCategory == "keys" then
			lastCategoryId = 1
		elseif lastCategory == "papers" then
			lastCategoryId = 2
		end
	else
		currentCategoryId = 0
		lastCategoryId = currentCategoryId
	end

	if tabLineInterpolation and currentCategory ~= lastCategory then
		local elapsedTime = getTickCount() - tabLineInterpolation
		local duration = 250
		local progress = elapsedTime / duration

		local x = interpolateBetween(
			tabStartX + sizeForTabs * lastCategoryId, 0, 0,
			tabStartX + sizeForTabs * currentCategoryId, 0, 0,
			progress, "InOutQuad")

		--dxDrawRectangle(x, tabStartY + 28, sizeForTabs, 2, tocolor(37,117,199))

		if progress >= 1 then
			tabLineInterpolation = false
		end
	else
		if itemsTableState ~= "player" then
			dxDrawRectangle(tabStartX, tabStartY + 28, panelWidth, 2, tocolor(255, 148, 40))
		else
			--dxDrawRectangle(tabStartX + sizeForTabs * currentCategoryId, tabStartY + 28, sizeForTabs, 2, tocolor(255, 148, 40))
		end
	end

	dxDrawRectangle(panelPosX + 30, panelPosY - 23, 320, 10, tocolor(0, 0, 0, 90))
	dxDrawRectangle(panelPosX + 30, panelPosY - 23, weightSize, 10, tocolor(255, 148, 40))

	if itemsTableState == "player" then
		tabStartX = drawCategoryTab(tabStartX + 40, tabStartY - 343, "main", "bag", "")
		tabStartX = drawCategoryTab(tabStartX + 30, tabStartY - 343, "keys", "key", "")
		tabStartX = drawCategoryTab(tabStartX + 30, tabStartY - 343, "papers", "wallet", "")
		tabStartX = drawCategoryTab(tabStartX + 30, tabStartY - 343, "craft", "craft", "")
	elseif itemsTableState == "vehicle" then
		tabStartX = drawCategoryTab(tabStartX + 40, tabStartY - 343, "main", "vehicle", "Csomagtartó")
	elseif itemsTableState == "object" then
		tabStartX = drawCategoryTab(tabStartX + 40, tabStartY - 343, "main", "safe", "Széf")
	end

	-- ** Slotok @ Itemek
	local hoveredItemSlot = false

	if currentCategory == "main" or currentCategory == "keys" or currentCategory == "papers" then
	for i = 0, defaultSettings.slotLimit - 1 do
		local slot = i

		x = panelPosX + (defaultSettings.slotBoxWidth + 5) * (slot % defaultSettings.width)
		y = panelPosY + (defaultSettings.slotBoxHeight + 5) * math.floor(slot / defaultSettings.width)

		if itemsTableState == "player" and currentCategory == "keys" then
			i = i + defaultSettings.slotLimit
		elseif itemsTableState == "player" and currentCategory == "papers" then
			i = i + defaultSettings.slotLimit * 2
		end

		local item = itemsTable[itemsTableState]

		if item then
			item = itemsTable[itemsTableState][i]

			if item and not availableItems[item.itemId] then
				item = false
			end
		end

		local slotColor = tocolor(0, 0, 0, 100)

		if item and item.inUse then
			slotColor = tocolor(50, 200, 50, 200)
		end

		if absX >= x and absX <= x + defaultSettings.slotBoxWidth and absY >= y and absY <= y + defaultSettings.slotBoxHeight then
			slotColor = tocolor(255, 148, 40, 200)

			if item and not movedslotId then
				hoveredItemSlot = item

				if lastslotId ~= i then
					lastslotId = i
					playSound(":cosmo_assets/audio/interface/9.ogg")
				end
			end
		elseif lastslotId == i then
			lastslotId = false
		end

		dxDrawRectangle(x, y, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, slotColor)

		if item and (movedslotId ~= i or movedslotId == i and stackAmount > 0 and stackAmount < item.amount) then
			drawItemPicture(item, x, y)
			dxDrawText(item.amount, x + defaultSettings.slotBoxWidth - 6, y + defaultSettings.slotBoxHeight - 15, x + defaultSettings.slotBoxWidth, y + defaultSettings.slotBoxHeight - 15 + 5, tocolor(255, 255, 255), 0.375, Roboto, "right")
		end
	end
	if hoveredItemSlot then
		if hoveredItemSlot.nameTag then
			nameTagName = getItemName(hoveredItemSlot.itemId) .. " #d75959(" .. hoveredItemSlot.nameTag .. ")"
		else
			nameTagName = getItemName(hoveredItemSlot.itemId)
		end

		if hoveredItemSlot.data3 == "printed" then
			processTooltip(absX, absY, nameTagName .. " (másolat)", hoveredItemSlot.itemId, hoveredItemSlot)
			--outputChatBox(hoveredItemSlot.data1)
		else
			processTooltip(absX, absY, nameTagName, hoveredItemSlot.itemId, hoveredItemSlot)
		end
	end

	if isCursorShowing() then
		moslekcX, moslekcY = getCursorPosition()
	else
		moslekcX, moslekcY = 300000000000000 , 30000000000000000000000
	end

	if nametagX and nametagY then
		dxDrawRectangle(nametagX, nametagY, 200, 24, tocolor(0, 0, 0, 200)) -- Nametag Background

		-- Nametag Ok
		dxDrawRectangle(nametagX + 200 - 64, nametagY + 3, 28, 18, tocolor(255, 148, 40, 255))
   		dxDrawText("Ok", nametagX + 200 - 64, nametagY + 3, nametagX + 200 - 64 + 28, nametagY + 3 + 18, tocolor(0, 0, 0), 0.5, Roboto, "center", "center")

		-- Nametag bezárás
		dxDrawRectangle(nametagX + 200 - 32 + 1, nametagY + 3, 28, 18, tocolor(215, 89, 89, 255))
		dxDrawText("X", nametagX + 200 - 32, nametagY + 3, nametagX + 200 - 32 + 28, nametagY + 3 + 18, tocolor(0, 0, 0), 0.5, Roboto, "center", "center")

		drawInput("nametag|16", "Névcédula...", nametagX, nametagY, 200-66, 24, Roboto, 0.45) -- Nametag input

		-- Nametag close action
		if isInSlot(nametagX + 200 - 32 + 1, nametagY + 3, 28, 18) and getKeyState("mouse1") then
			nametagX, nametagY = false, false
			useingNametagIcon = false
			useingNametag = false
			fakeInputs["nametag|16"] = ""
			exports.cosmo_controls:toggleControl({"all"}, true)
		end
		-- Nametag ok action
		if isInSlot(nametagX + 200 - 64, nametagY + 3, 28, 18) and getKeyState("mouse1") then
			--nametagID = vitem.dbID
			--triggerEvent("updateNameTag", localPlayer, nametagID, fakeInputs["nametag|16"])
			triggerEvent("updateItemNametag", localPlayer, "player", nametagID, fakeInputs["nametag|16"], true)
			nametagX, nametagY = false, false
			useingNametagIcon = false
			useingNametag = false
			fakeInputs["nametag|16"] = ""
			triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", usedNametag.dbID, 1)
			usedNametag = false
			exports.cosmo_controls:toggleControl({"all"}, true)
		end
	end

	if useingNametagIcon then
		dxDrawImage(moslekcX * screenX, moslekcY * screenY, 20, 20, "files/items/246.png",0,0,0, tocolor(255,255,255))
	end
	

	-- ** Mozgatott item
	if movedslotId then
		local x = absX - moveDifferenceX
		local y = absY - moveDifferenceY

		drawItemPicture(itemsTable[itemsTableState][movedslotId], x, y)

		if stackAmount < itemsTable[itemsTableState][movedslotId].amount then
			if stackAmount > 0 then
				dxDrawText(stackAmount, x + defaultSettings.slotBoxWidth - 6, y + defaultSettings.slotBoxHeight - 15, x + defaultSettings.slotBoxWidth, y + defaultSettings.slotBoxHeight - 15 + 5, tocolor(255, 255, 255), 0.375, Roboto, "right")
			else
				dxDrawText(itemsTable[itemsTableState][movedslotId].amount, x + defaultSettings.slotBoxWidth - 6, y + defaultSettings.slotBoxHeight - 15, x + defaultSettings.slotBoxWidth, y + defaultSettings.slotBoxHeight - 15 + 5, tocolor(255, 255, 255), 0.375, Roboto, "right")
			end
		else
			dxDrawText(itemsTable[itemsTableState][movedslotId].amount, x + defaultSettings.slotBoxWidth - 6, y + defaultSettings.slotBoxHeight - 15, x + defaultSettings.slotBoxWidth, y + defaultSettings.slotBoxHeight - 15 + 5, tocolor(255, 255, 255), 0.375, Roboto, "right")
		end
	end
end

	if drawShowItemTooltip then
		-- local tooltipText = "Várj #d75959" .. math.floor(6.5 - drawShowItemTooltip / 1000) .. "#ffffff másodpercet."
		-- local tooltipWidth, tooltipHeight = getTooltipBestSize(tooltipText)

		-- showTooltip(panelPosX + (panelWidth - tooltipWidth) / 2, panelPosY - 30 - tooltipHeight, tooltipText)
	end

	if itemsTableState == "player" and currentCategory == "craft" then
		local x = panelPosX - 5
		local y = panelPosY - 5
	
		dxDrawRectangle(x+(panelWidth/1.85), y+181, panelHeight-35, 20, tocolor(0, 0, 0, 200))
		--dxDrawRectangle(x+(panelWidth/1.85), y+27.5, panelHeight-35, 150, tocolor(255, 255, 255, 255))
		if isInSlot(x+(panelWidth/1.85), y+181, panelHeight-35, 20) then
			if getKeyState("mouse1") and kTick+1000 < getTickCount() then 
				px,py,pz = getElementPosition(localPlayer)
				dim = getElementDimension(localPlayer)
				int = getElementInterior(localPlayer)
					if craftingName == "Horgászbot" then
						if (craftingHasItem7==1 and craftingHasItem12==1 and craftingHasItem13==1 and craftingHasItem17==1) then
							if crafting == false and craftloading == 0 then
								crafting = true
								if pedInCraftAnim == false then
									pedInCraftAnim = true
									takeItemInCraft(craftingSlot7, 1)
									takeItemInCraft(craftingSlot12, 1)
									takeItemInCraft(craftingSlot13, 1)
									takeItemInCraft(craftingSlot17, 1)
									takeItemInCraft(craftingSlot18, 1)
									triggerServerEvent("setPedCraftAnim",localPlayer,localPlayer)
									setTimer(function()
										triggerServerEvent("giveItem", localPlayer, 200, 1) 
									end, 10000, 1)
								end
							end
						end
					end
					if inCraftShape then
					if craftingName == "Szárított Marihuána" then
						if (craftingHasItem12 ==1 and craftingHasItem13 ==1) then
							if crafting == false and craftloading == 0 then
								crafting = true
								if pedInCraftAnim == false then
									pedInCraftAnim = true
									takeItemInCraft(craftingSlot12, 1)
									takeItemInCraft(craftingSlot13, 1)
									triggerServerEvent("setPedCraftAnim",localPlayer,localPlayer)
									setTimer(function()
										triggerServerEvent("giveItem", localPlayer, 286, 1) 
									end, 10000, 1)
								end
							end
						end
					end
					if craftingName == "Füvescigi" then
						if (craftingHasItem12 ==1 and craftingHasItem13 ==1) then
							if crafting == false and craftloading == 0 then
								crafting = true
								if pedInCraftAnim == false then
									pedInCraftAnim = true
									takeItemInCraft(craftingSlot12, 1)
									takeItemInCraft(craftingSlot13, 1)
									triggerServerEvent("setPedCraftAnim",localPlayer,localPlayer)
									setTimer(function()
										triggerServerEvent("giveItem", localPlayer, 282, 1) 
									end, 10000, 1)
								end
							end
						end
					end
					if craftingName == "Kokain" then
						if (craftingHasItem7==1 and craftingHasItem12==1 and craftingHasItem13==1) then
							if crafting == false and craftloading == 0 then
								crafting = true
								if pedInCraftAnim == false then
									pedInCraftAnim = true
									takeItemInCraft(craftingSlot7, 1)
									takeItemInCraft(craftingSlot12, 1)
									takeItemInCraft(craftingSlot13, 1)
									triggerServerEvent("setPedCraftAnim",localPlayer,localPlayer)
									setTimer(function()
										triggerServerEvent("giveItem", localPlayer, 231, 1) 
									end, 10000, 1)
								end
							end
						end
					end
					if craftingName == "Heroin por" then
						if (craftingHasItem7==1 and craftingHasItem12==1 and craftingHasItem13==1 and craftingHasItem17==1) then
							if crafting == false and craftloading == 0 then
								crafting = true
								if pedInCraftAnim == false then
									pedInCraftAnim = true
									takeItemInCraft(craftingSlot7, 1)
									takeItemInCraft(craftingSlot12, 1)
									takeItemInCraft(craftingSlot13, 1)
									takeItemInCraft(craftingSlot17, 1)
									triggerServerEvent("setPedCraftAnim",localPlayer,localPlayer)
								end
							end
						end
					end
					if craftingName == "Heroinos fecskendő" then
						if (craftingHasItem7==1 and craftingHasItem12==1 and craftingHasItem13==1 and craftingHasItem17==1) then
							if crafting == false and craftloading == 0 then
								crafting = true
								if pedInCraftAnim == false then
									pedInCraftAnim = true
									takeItemInCraft(craftingSlot7, 1)
									takeItemInCraft(craftingSlot12, 1)
									takeItemInCraft(craftingSlot13, 1)
									takeItemInCraft(craftingSlot17, 1)
									triggerServerEvent("setPedCraftAnim",localPlayer,localPlayer)
								end
							end
						end
					end
					if craftingName == "Colt-45" then
						if (craftingHasItem7==1 and craftingHasItem12==1 and craftingHasItem13==1 and craftingHasItem17==1 and craftingHasItem18==1 and craftingHasItem19==1) then
							if crafting == false and craftloading == 0 then
								crafting = true
								if pedInCraftAnim == false then
									pedInCraftAnim = true
									takeItemInCraft(craftingSlot7, 1)
									takeItemInCraft(craftingSlot12, 1)
									takeItemInCraft(craftingSlot13, 1)
									takeItemInCraft(craftingSlot17, 1)
									takeItemInCraft(craftingSlot18, 1)
									takeItemInCraft(craftingSlot19, 1)
									triggerServerEvent("setPedCraftAnim",localPlayer,localPlayer)
									setTimer(function()
										triggerServerEvent("giveItem", localPlayer, 9, 1) 
									end, 10000, 1)
								end
							end
						end
					end
					if craftingName == "UZI" then
						if (craftingHasItem7==1 and craftingHasItem12==1 and craftingHasItem13==1 and craftingHasItem14==1 and craftingHasItem17==1) then
							if crafting == false and craftloading == 0 then
								crafting = true
								if pedInCraftAnim == false then
									pedInCraftAnim = true
									takeItemInCraft(craftingSlot7, 1)
									takeItemInCraft(craftingSlot12, 1)
									takeItemInCraft(craftingSlot13, 1)
									takeItemInCraft(craftingSlot14, 1)
									takeItemInCraft(craftingSlot17, 1)
									triggerServerEvent("setPedCraftAnim",localPlayer,localPlayer)
									setTimer(function()
										triggerServerEvent("giveItem", localPlayer, 12, 1) 
									end, 10000, 1)
								end
							end
						end
					end
					if craftingName == "TEC-9" then
						if (craftingHasItem7==1 and craftingHasItem12==1 and craftingHasItem13==1 and craftingHasItem14==1 and craftingHasItem17==1) then
							if crafting == false and craftloading == 0 then
								crafting = true
								if pedInCraftAnim == false then
									pedInCraftAnim = true
									takeItemInCraft(craftingSlot7, 1)
									takeItemInCraft(craftingSlot12, 1)
									takeItemInCraft(craftingSlot13, 1)
									takeItemInCraft(craftingSlot14, 1)
									takeItemInCraft(craftingSlot17, 1)
									triggerServerEvent("setPedCraftAnim",localPlayer,localPlayer)
									setTimer(function()
										triggerServerEvent("giveItem", localPlayer, 13, 1) 
									end, 10000, 1)
								end
							end
						end
					end
					if craftingName == "AK-47" then
						if (craftingHasItem7==1 and craftingHasItem12==1 and craftingHasItem13==1 and craftingHasItem17==1 and craftingHasItem18==1) then
							if crafting == false and craftloading == 0 then
								crafting = true
								if pedInCraftAnim == false then
									pedInCraftAnim = true
									takeItemInCraft(craftingSlot7, 1)
									takeItemInCraft(craftingSlot12, 1)
									takeItemInCraft(craftingSlot13, 1)
									takeItemInCraft(craftingSlot17, 1)
									triggerServerEvent("setPedCraftAnim",localPlayer,localPlayer)
									setTimer(function()
										triggerServerEvent("giveItem", localPlayer, 15, 1) 
									end, 10000, 1)
								end
							end
						end
					end
					if craftingName == "Vadászpuska" then
						if (craftingHasItem7==1 and craftingHasItem12==1 and craftingHasItem13==1 and craftingHasItem17==1) then
							if crafting == false and craftloading == 0 then
								crafting = true
								if pedInCraftAnim == false then
									pedInCraftAnim = true
									takeItemInCraft(craftingSlot7, 1)
									takeItemInCraft(craftingSlot12, 1)
									takeItemInCraft(craftingSlot13, 1)
									takeItemInCraft(craftingSlot17, 1)
									triggerServerEvent("setPedCraftAnim",localPlayer,localPlayer)
									setTimer(function()
										triggerServerEvent("giveItem", localPlayer, 17, 1) 
									end, 10000, 1)
								end
							end
						end
					end
					if craftingName == "Sörétespuska" then
						if (craftingHasItem8==1 and craftingHasItem13==1 and craftingHasItem18==1) then
							if crafting == false and craftloading == 0 then
								crafting = true
								if pedInCraftAnim == false then
									pedInCraftAnim = true
									takeItemInCraft(craftingSlot8, 1)
									takeItemInCraft(craftingSlot13, 1)
									takeItemInCraft(craftingSlot18, 1)
									triggerServerEvent("setPedCraftAnim",localPlayer,localPlayer)
									setTimer(function()
										triggerServerEvent("giveItem", localPlayer, 19, 1) 
									end, 10000, 1)
								end
							end
						end
					end
				else
					outputChatBox("#DE6363[CRAFT]#FFFFFF Nem vagy megfelelő helyen a tárgy elkészítéséhez.(Gyár)",255,255,255,true)
				end
				kTick = getTickCount()
			end
		end
		if crafting == true then
			setTimer(function()
				pedInCraftAnim = false
				crafting = false
			end, 10000, 1)
		end
		dxDrawText("Elkészít", x+290, y+382.5, 0, y, tocolor(255, 255, 255, 230), 0.8, RobotoB, "left", "center")
		for i = 0, 8 do
			local craftItemListColor = 0
			if i == 1 or i == 3 or i == 5 or i == 7 then
				craftItemListColor = 75
			elseif i == 2 or i == 4 or i == 6 then
				craftItemListColor = 110
			elseif i == 0 then
				craftItemListColor = 180
			end
			dxDrawRectangle(x+(panelWidth/1.85), y+6+(i*22), panelHeight-35, 21, tocolor(0, 0, 0, craftItemListColor))
		end
		for i = 0, 4 do 
			dxDrawRectangle(x+11, y+6+(i*40), 35, 35, tocolor(0, 0, 0, 200))
			dxDrawRectangle(x+51, y+6+(i*40), 35, 35, tocolor(0, 0, 0, 200))
			dxDrawRectangle(x+91, y+6+(i*40), 35, 35, tocolor(0, 0, 0, 200))
			dxDrawRectangle(x+131, y+6+(i*40), 35, 35, tocolor(0, 0, 0, 200))
			dxDrawRectangle(x+171, y+6+(i*40), 35, 35, tocolor(0, 0, 0, 200))
		end
		latestRowItem = currentRowItem+craftItemNameDrawMax-1
		for k, v in pairs(craftItems) do
			if k >= currentRowItem and k <= latestRowItem then
				k = k - currentRowItem + 1
				dxDrawText(v[1], x+235, y+37.5+(k*43), 0, y, tocolor(255, 255, 255, 230), 0.8, RobotoB, "left", "center")
			end
		end
		dxDrawText("Recept: "..craftingName, x+235, y+37.5, 0, y, tocolor(255, 255, 255, 230), 0.8, RobotoB, "left", "center")
		--<<oszlop == 1>>--
		if craftingSlot1 > 0 then
			if not hasItem(craftingSlot1) then
				dxDrawRectangle(x+11, y+6, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem1 = 0
			elseif hasItem(craftingSlot1) then
				dxDrawRectangle(x+11, y+6, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem1 = 1
			end
			dxDrawImage(x+12, y+7, 33, 33,"files/items/"..craftingSlot1..".png",0,0,0,tocolor(255,255,255,255))
		end
		if craftingSlot2 > 0 then
			if not hasItem(craftingSlot2) then
				dxDrawRectangle(x+11, y+46, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem2 = 0
			elseif hasItem(craftingSlot2) then
				dxDrawRectangle(x+11, y+46, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem2 = 1
			end
			dxDrawImage(x+12, y+47, 33, 33,"files/items/"..craftingSlot2..".png",0,0,0,tocolor(255,255,255,255))
		end
		if craftingSlot3 > 0 then
			if not hasItem(craftingSlot3) then
				dxDrawRectangle(x+11, y+86, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem3 = 0
			elseif hasItem(craftingSlot3) then
				dxDrawRectangle(x+11, y+86, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem3 = 1
			end
			dxDrawImage(x+12, y+87, 33, 33,"files/items/"..craftingSlot3..".png",0,0,0,tocolor(255,255,255,255))
		end
		if craftingSlot4 > 0 then
			if not hasItem(craftingSlot4) then
				dxDrawRectangle(x+11, y+126, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem4 = 0
			elseif hasItem(craftingSlot4) then
				dxDrawRectangle(x+11, y+126, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem4 = 1
			end
			dxDrawImage(x+12, y+127, 33, 33,"files/items/"..craftingSlot4..".png",0,0,0,tocolor(255,255,255,255))
		end
		if craftingSlot5 > 0 then
			if not hasItem(craftingSlot5) then
				dxDrawRectangle(x+11, y+166, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem5 = 0
			elseif hasItem(craftingSlot5) then
				dxDrawRectangle(x+11, y+166, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem5 = 1
			end
			dxDrawImage(x+12, y+167, 33, 33,"files/items/"..craftingSlot5..".png",0,0,0,tocolor(255,255,255,255))
		end
		--<<oszlop == 2>>--
		if craftingSlot6 > 0 then
			if not hasItem(craftingSlot6) then
				dxDrawRectangle(x+51, y+6, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem6 = 0
			elseif hasItem(craftingSlot6) then
				dxDrawRectangle(x+51, y+6, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem6 = 1
			end
			dxDrawImage(x+52, y+7, 33, 33,"files/items/"..craftingSlot6..".png",0,0,0,tocolor(255,255,255,255))
		end
		if craftingSlot7 > 0 then
			if not hasItem(craftingSlot7) then
				dxDrawRectangle(x+51, y+46, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem7 = 0
			elseif hasItem(craftingSlot7) then
				dxDrawRectangle(x+51, y+46, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem7 = 1
			end
			dxDrawImage(x+52, y+47, 33, 33,"files/items/"..craftingSlot7..".png",0,0,0,tocolor(255,255,255,255))
		end
		if craftingSlot8 > 0 then
			if not hasItem(craftingSlot8) then
				dxDrawRectangle(x+51, y+86, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem8 = 0
			elseif hasItem(craftingSlot8) then
				dxDrawRectangle(x+51, y+86, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem8 = 1
			end
			dxDrawImage(x+52, y+87, 33, 33,"files/items/"..craftingSlot8..".png",0,0,0,tocolor(255,255,255,255))
		end
		if craftingSlot9 > 0 then
			if not hasItem(craftingSlot9) then
				dxDrawRectangle(x+51, y+126, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem9 = 0
			elseif hasItem(craftingSlot9) then
				dxDrawRectangle(x+51, y+126, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem9 = 1
			end
			dxDrawImage(x+52, y+127, 33, 33,"files/items/"..craftingSlot9..".png",0,0,0,tocolor(255,255,255,255))
		end
		if craftingSlot10 > 0 then
			if not hasItem(craftingSlot10) then
				dxDrawRectangle(x+51, y+166, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem10 = 0
			elseif hasItem(craftingSlot10) then
				dxDrawRectangle(x+51, y+166, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem10 = 1
			end
			dxDrawImage(x+52, y+167, 33, 33,"files/items/"..craftingSlot10..".png",0,0,0,tocolor(255,255,255,255))
		end
		--<<oszlop == 3>>--
		if craftingSlot11 > 0 then
			if not hasItem(craftingSlot11) then
				dxDrawRectangle(x+91, y+6, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem11 = 0
			elseif hasItem(craftingSlot11) then
				dxDrawRectangle(x+91, y+6, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem11 = 1
			end
			dxDrawImage(x+92, y+7, 33, 33,"files/items/"..craftingSlot11..".png",0,0,0,tocolor(255,255,255,255))
		end
		if craftingSlot12 > 0 then
			if not hasItem(craftingSlot12) then
				dxDrawRectangle(x+91, y+46, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem12 = 0
			elseif hasItem(craftingSlot12) then
				dxDrawRectangle(x+91, y+46, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem12 = 1
			end
			dxDrawImage(x+92, y+47, 33, 33,"files/items/"..craftingSlot12..".png",0,0,0,tocolor(255,255,255,255))
		end
		if craftingSlot13 > 0 then
			if not hasItem(craftingSlot13) then
				dxDrawRectangle(x+91, y+86, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem13 = 0
			elseif hasItem(craftingSlot13) then
				dxDrawRectangle(x+91, y+86, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem13 = 1
			end
			dxDrawImage(x+92, y+87, 33, 33,"files/items/"..craftingSlot13..".png",0,0,0,tocolor(255,255,255,255))
		end
		if craftingSlot14 > 0 then
			if not hasItem(craftingSlot14) then
				dxDrawRectangle(x+91, y+126, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem14 = 0
			elseif hasItem(craftingSlot14) then
				dxDrawRectangle(x+91, y+126, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem14 = 1
			end
			dxDrawImage(x+92, y+127, 33, 33,"files/items/"..craftingSlot14..".png",0,0,0,tocolor(255,255,255,255))
		end
		if craftingSlot15 > 0 then
			if not hasItem(craftingSlot15) then
				dxDrawRectangle(x+91, y+166, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem15 = 0
			elseif hasItem(craftingSlot15) then
				dxDrawRectangle(x+91, y+166, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem15 = 1
			end
			dxDrawImage(x+92, y+167, 33, 33,"files/items/"..craftingSlot15..".png",0,0,0,tocolor(255,255,255,255))
		end
		--<<oszlop == 4>>--
		if craftingSlot16 > 0 then
			if not hasItem(craftingSlot16) then
				dxDrawRectangle(x+131, y+6, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem16 = 0
			elseif hasItem(craftingSlot16) then
				dxDrawRectangle(x+131, y+6, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem16 = 1
			end
			dxDrawImage(x+132, y+7, 33, 33,"files/items/"..craftingSlot16..".png",0,0,0,tocolor(255,255,255,255))
		end
		if craftingSlot17 > 0 then
			if not hasItem(craftingSlot17) then
				dxDrawRectangle(x+131, y+46, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem17 = 0
			elseif hasItem(craftingSlot17) then
				dxDrawRectangle(x+131, y+46, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem17 = 1
			end
			dxDrawImage(x+132, y+47, 33, 33,"files/items/"..craftingSlot17..".png",0,0,0,tocolor(255,255,255,255))
		end
		if craftingSlot18 > 0 then
			if not hasItem(craftingSlot18) then
				dxDrawRectangle(x+131, y+86, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem18 = 0
			elseif hasItem(craftingSlot18) then
				dxDrawRectangle(x+131, y+86, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem18 = 1
			end
			dxDrawImage(x+132, y+87, 33, 33,"files/items/"..craftingSlot18..".png",0,0,0,tocolor(255,255,255,255))
		end
		if craftingSlot19 > 0 then
			if not hasItem(craftingSlot19) then
				dxDrawRectangle(x+131, y+126, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem19 = 0
			elseif hasItem(craftingSlot19) then
				dxDrawRectangle(x+131, y+126, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem19 = 1
			end
			dxDrawImage(x+132, y+127, 33, 33,"files/items/"..craftingSlot19..".png",0,0,0,tocolor(255,255,255,255))
		end
		if craftingSlot20 > 0 then
			if not hasItem(craftingSlot20) then
				dxDrawRectangle(x+131, y+166, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem20 = 0
			elseif hasItem(craftingSlot20) then
				dxDrawRectangle(x+131, y+166, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem20 = 1
			end
			dxDrawImage(x+132, y+167, 33, 33,"files/items/"..craftingSlot20..".png",0,0,0,tocolor(255,255,255,255))
		end
		--<<oszlop == 5>>--
		if craftingSlot21 > 0 then
			if not hasItem(craftingSlot21) then
				dxDrawRectangle(x+171, y+6, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem21 = 0
			elseif hasItem(craftingSlot21) then
				dxDrawRectangle(x+171, y+6, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem21 = 1
			end
			dxDrawImage(x+172, y+7, 33, 33,"files/items/"..craftingSlot21..".png",0,0,0,tocolor(255,255,255,255))
		end
		if craftingSlot22 > 0 then
			if not hasItem(craftingSlot22) then
				dxDrawRectangle(x+171, y+46, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem22 = 0
			elseif hasItem(craftingSlot22) then
				dxDrawRectangle(x+171, y+46, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem22 = 1
			end
			dxDrawImage(x+172, y+47, 33, 33,"files/items/"..craftingSlot22..".png",0,0,0,tocolor(255,255,255,255))
		end
		if craftingSlot23 > 0 then
			if not hasItem(craftingSlot23) then
				dxDrawRectangle(x+171, y+86, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem23 = 0
			elseif hasItem(craftingSlot23) then
				dxDrawRectangle(x+171, y+86, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem23 = 1
			end
			dxDrawImage(x+172, y+87, 33, 33,"files/items/"..craftingSlot23..".png",0,0,0,tocolor(255,255,255,255))
		end
		if craftingSlot24 > 0 then
			if not hasItem(craftingSlot24) then
				dxDrawRectangle(x+171, y+126, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem24 = 0
			elseif hasItem(craftingSlot24) then
				dxDrawRectangle(x+171, y+126, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem24 = 1
			end
			dxDrawImage(x+172, y+127, 33, 33,"files/items/"..craftingSlot24..".png",0,0,0,tocolor(255,255,255,255))
		end
		if craftingSlot25 > 0 then
			if not hasItem(craftingSlot25) then
				dxDrawRectangle(x+171, y+166, 35, 35, tocolor(223, 65, 65, 255))
				craftingHasItem25 = 0
			elseif hasItem(craftingSlot25) then
				dxDrawRectangle(x+171, y+166, 35, 35, tocolor(79, 201, 90, 255))
				craftingHasItem25 = 1
			end
			dxDrawImage(x+172, y+167, 33, 33,"files/items/"..craftingSlot25..".png",0,0,0,tocolor(255,255,255,255))
		end
	end

	-- ** Gombok
	activeButton = false

	if absX and absY then
		for k, v in pairs(buttons) do
			if absX >= v[1] and absY >= v[2] and absX <= v[1] + v[3] and absY <= v[2] + v[4] then
				activeButton = k
				break
			end
		end
	end
end

function settingClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
	local x = panelPosX - 5
	local y = panelPosY - 5
	if itemsTableState == "player" and currentCategory == "craft" then
		if (button=="left") and (state=="down") then
			latestRowItem = currentRowItem+craftItemNameDrawMax-1
			for k, v in pairs(craftItems) do
				if k >= currentRowItem and k <= latestRowItem then
					k = k - currentRowItem + 1
					if crafting == false then
						if isInSlot(x+(panelWidth/1.85), y+6+(k*22), panelHeight-35, 21) then
							craftingName = v[1]
							craftingId = v[2]
							craftingSlot1 = v[3]
							craftingSlot2 = v[4]
							craftingSlot3 = v[5]
							craftingSlot4 = v[6]
							craftingSlot5 = v[7]
							craftingSlot6 = v[8]
							craftingSlot7 = v[9]
							craftingSlot8 = v[10]
							craftingSlot9 = v[11]
							craftingSlot10 = v[12]
							craftingSlot11 = v[13]
							craftingSlot12 = v[14]
							craftingSlot13 = v[15]
							craftingSlot14 = v[16]
							craftingSlot15 = v[17]
							craftingSlot16 = v[18]
							craftingSlot17 = v[19]
							craftingSlot18 = v[20]
							craftingSlot19 = v[21]
							craftingSlot20 = v[22]
							craftingSlot21 = v[23]
							craftingSlot22 = v[24]
							craftingSlot23 = v[25]
							craftingSlot24 = v[26]
							craftingSlot25 = v[27]
							--outputChatBox(v[3].." "..v[4].." "..v[5].." "..v[6].." "..v[7].." "..v[8].." "..v[9].." "..v[10].." "..v[11].." "..v[12].." "..v[13].." "..v[14].." "..v[15].." "..v[16].." "..v[17].." "..v[18].." "..v[19].." "..v[20].." "..v[21].." "..v[22].." "..v[23].." "..v[24].." "..v[25].." "..v[26].." "..v[27])
							--outputChatBox("1: "..craftingSlot1.." 2: "..craftingSlot2.." 3: "..craftingSlot3.." 4: "..craftingSlot4.." 5: "..craftingSlot5.." 6: "..craftingSlot6.." 7: "..craftingSlot7.." 8: "..craftingSlot8.." 9: "..craftingSlot9.." 10: "..craftingSlot10.." 11: "..craftingSlot11.." 12: "..craftingSlot12.." 13: "..craftingSlot13.." 14: "..craftingSlot14.." 15: "..craftingSlot15.." 16: "..craftingSlot16.." 17: "..craftingSlot17.." 18: "..craftingSlot18.." 19: "..craftingSlot19.." 20: "..craftingSlot20.." 21: "..craftingSlot21.." 22: "..craftingSlot22.." 23: "..craftingSlot23.." 24: "..craftingSlot24.." 25: "..craftingSlot25)
						end
					end
				end
			end
		end
	end
end
addEventHandler("onClientClick",root,settingClick)


function processTooltip(x, y, text, itemId, item, getSize, showItem)
	local text2 = ""

	if itemId == 71 and tonumber(item.data1) then
		text2 = "Telefonszám: #7cc576" .. item.data1
	elseif itemId == 86 then
		if item.data1 and item.data2 then
			text2 = "#DCA300# " .. tostring(item.data1) .. " - " .. item.data2 .. " #"
		end
	elseif itemId == 118 or itemId == 119 then
		if item.data1 then
			local remainMinute = perishableItems[itemId] - (item.data3 or 0)
			local totalSecond = remainMinute * 60
			local remainHour = math.floor(totalSecond / 3600)

			if remainHour >= 1 then
				text2 = "Hátralévő idő a befizetésig: #d75959" .. remainHour .. " óra és " .. ((totalSecond % 3600) / 60) .. " perc"
			else
				text2 = "Hátralévő idő a befizetésig: #d75959" .. remainMinute .. " perc"
			end
		end
	elseif isKeyItem(itemId) then
		if item.data1 then
			text2 = "Azonosító: " .. item.data1
		else
			text2 = "#d75959** HIBÁS KULCS **"
		end
	elseif isWeaponItem(itemId) then
		text2 = "#bf8f0aAWL# "..item.dbID.."\n#ffffffFigyelmeztetés: "..(item.data3 or 0)
	elseif itemId == 79 then
		if item.data1 and tonumber(item.data1) > 0 then
			text2 = "Frekvencia: #6fcc9fCH-" .. item.data1
		else
			text2 = "#d75959Nincs beállítva frekvencia."
		end
	elseif perishableItems[itemId] or isSpecialItem(itemId) then
		local health = 0
		local color = ""

		if perishableItems[itemId] then
			health = math.floor(100 - (item.data3 or 0) / perishableItems[itemId] * 100)
			color = "#6fcc9f"

			if health > 30 and health <= 65 then
				color = "#FF9600"
			elseif health <= 30 then
				color = "#d75959"
			end

			text2 = "Állapot: " .. color .. health .. "%"

			if isSpecialItem(itemId) then
				text2 = text2 .. "\n"
			end
		end

		if isSpecialItem(itemId) then
			health = tonumber(item.data2) or 0
			color = "#d75959"
			
			if health > 45 and health <= 75 then
				color = "#FF9600"
			elseif health <= 45 then
				color = "#6fcc9f"
			end
			
			text2 = text2 .. "#ffffffElfogyasztva: " .. color .. health .. "%"
		end
	elseif itemId == 44 then -- SD Kártya
		local health = tonumber(item.data1) or 0
		local color = "#d75959"
		
		if health > 30 and health <= 65 then
			color = "#FF9600"
		elseif health <= 30 then
			color = "#6fcc9f"
		end
		
		text2 = "Telítettség: " .. color .. health .. "%"
	elseif itemId == 111 then -- Jogosítvány
		local data = fromJSON(item.data1)

		text2 = "Aláírás: #4283de" .. data.name .. "\n#ffffffKategória: #6fcc9f" .. data.category
	elseif itemId == 112 then -- Személyigazolvány
		local data = fromJSON(item.data1)

		text2 = "Aláírás: #4283de" .. data.name
	elseif itemId == 263 then -- Fegyverengedély
		local data = fromJSON(item.data1)

		text2 = "Aláírás: #4283de" .. data.name
	elseif itemId == 113 then -- Vizsga záradék
		local result = "#d75959Sikertelen"

		if tonumber(item.data1) == 1 then
			result = "#6fcc9fSikeres"
		end

		text2 = "Vizsga megnevezése: #8e8e8e" .. item.data2 .. "\n#ffffffVizsga eredménye: " .. result
	elseif availableItems[itemId][2] then
		text2 = availableItems[itemId][2]
		text2 = text2 .."\n#ffffffSúly: #8e8e8e" .. getItemWeight(itemId) * item.amount .. " kg"
	else
		text2 = "#ffffffSúly: #8e8e8e" .. getItemWeight(itemId) * item.amount .. " kg"
	end

	if not getSize then
		if showItem then
			showTooltip(showItem / 2, 0, text, text2, item)
		else
			showTooltip(x, y, text, text2)
		end
	else
		return getTooltipBestSize(text, text2, true)
	end
end

function processTooltip(x, y, text, itemId, item, getSize, showItem)
	local text2 = ""

	if itemId == 71 and tonumber(item.data1) then
		text2 = "Telefonszám: #7cc576" .. item.data1
	elseif itemId == 86 then
		if item.data1 and item.data2 then
			text2 = "#DCA300# " .. tostring(item.data1) .. " - " .. item.data2 .. " #"
		end
	elseif itemId == 118 or itemId == 119 then
		if item.data1 then
			local remainMinute = perishableItems[itemId] - (item.data3 or 0)
			local totalSecond = remainMinute * 60
			local remainHour = math.floor(totalSecond / 3600)

			if remainHour >= 1 then
				text2 = "Hátralévő idő a befizetésig: #d75959" .. remainHour .. " óra és " .. ((totalSecond % 3600) / 60) .. " perc"
			else
				text2 = "Hátralévő idő a befizetésig: #d75959" .. remainMinute .. " perc"
			end
		end
	elseif isKeyItem(itemId) then
		if item.data1 then
			text2 = "Azonosító: " .. item.data1
		else
			text2 = "#d75959** HIBÁS KULCS **"
		end
	elseif isWeaponItem(itemId) then
		text2 = "#bf8f0aAWL# "..item.dbID.."\n#ffffffFigyelmeztetés: "..(item.data3 or 0)
	elseif itemId == 79 then
		if item.data1 and tonumber(item.data1) > 0 then
			text2 = "Frekvencia: #6fcc9fCH-" .. item.data1
		else
			text2 = "#d75959Nincs beállítva frekvencia."
		end
	elseif perishableItems[itemId] or isSpecialItem(itemId) then
		local health = 0
		local color = ""

		if perishableItems[itemId] then
			health = math.floor(100 - (item.data3 or 0) / perishableItems[itemId] * 100)
			color = "#6fcc9f"

			if health > 30 and health <= 65 then
				color = "#FF9600"
			elseif health <= 30 then
				color = "#d75959"
			end

			text2 = "Állapot: " .. color .. health .. "%"

			if isSpecialItem(itemId) then
				text2 = text2 .. "\n"
			end
		end

		if isSpecialItem(itemId) then
			health = tonumber(item.data2) or 0
			color = "#d75959"
			
			if health > 45 and health <= 75 then
				color = "#FF9600"
			elseif health <= 45 then
				color = "#6fcc9f"
			end
			
			text2 = text2 .. "#ffffffElfogyasztva: " .. color .. health .. "%"
		end
	elseif itemId == 44 then -- SD Kártya
		local health = tonumber(item.data1) or 0
		local color = "#d75959"
		
		if health > 30 and health <= 65 then
			color = "#FF9600"
		elseif health <= 30 then
			color = "#6fcc9f"
		end
		
		text2 = "Telítettség: " .. color .. health .. "%"
	elseif itemId == 111 then -- Jogosítvány
		local data = fromJSON(item.data1)

		text2 = "Aláírás: #4283de" .. data.name .. "\n#ffffffKategória: #6fcc9f" .. data.category
	elseif itemId == 112 then -- Személyigazolvány
		local data = fromJSON(item.data1)

		text2 = "Aláírás: #4283de" .. data.name
	elseif itemId == 263 then -- Fegyverengedély
		local data = fromJSON(item.data1)

		text2 = "Aláírás: #4283de" .. data.name
	elseif itemId == 113 then -- Vizsga záradék
		local result = "#d75959Sikertelen"

		if tonumber(item.data1) == 1 then
			result = "#6fcc9fSikeres"
		end

		text2 = "Vizsga megnevezése: #8e8e8e" .. item.data2 .. "\n#ffffffVizsga eredménye: " .. result
	elseif availableItems[itemId][2] then
		text2 = availableItems[itemId][2]
		text2 = text2 .."\n#ffffffSúly: #8e8e8e" .. getItemWeight(itemId) * item.amount .. " kg"
	else
		text2 = "#ffffffSúly: #8e8e8e" .. getItemWeight(itemId) * item.amount .. " kg"
	end

	if not getSize then
		if showItem then
			showTooltip(showItem / 2, 0, text, text2, item)
		else
			showTooltip(x, y, text, text2)
		end
	else
		return getTooltipBestSize(text, text2, true)
	end
end

function drawItemPicture(item, x, y)
	if not item then
		dxDrawImage(x, y, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, "files/noitem.png")
	else
		local picture = ""

		if itemPictures[item.itemId] then
			if item.data3 == "printed" then
				picture = "files/items/" .. item.itemId .. "_printed.png"
			else
				picture = "files/items/" .. item.itemId .. ".png"
			end
		else
			picture = itemPictures[item.itemId]
		end

		local perishableItem = false
		local pictureAlpha = 255

		if item.itemId and grayItemPictures[item.itemId] then
			pictureAlpha = 255 * (1 - (item.data3 or 0) / perishableItems[item.itemId])
			perishableItem = grayItemPictures[item.itemId]
		end

		if perishableItem then
			dxDrawImage(x, y, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, perishableItem)
		end

		dxDrawImage(x, y, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, picture, 0, 0, 0, tocolor(255, 255, 255, pictureAlpha))

		local k = 1

		if perishableItem then
			k = drawItemStatusBar(x, y, item, "perishable", k)
		end

		if isSpecialItem(item.itemId) then
			k = drawItemStatusBar(x, y, item, "usage", k)
		end

		if item.itemId == 44 then
			k = drawItemStatusBar(x, y, item, "sdcard", k)
		end
	end
end

function drawItemStatusBar(x, y, item, stat, k)
	local health = 0
	local color = 0

	if stat == "perishable" then
		health = math.floor(100 - (item.data3 or 0) / perishableItems[item.itemId] * 100)
		color = tocolor(20, 165, 20)

		if health > 30 and health <= 65 then
			color =  tocolor(255, 128, 0)
		elseif health <= 30 then
			color = tocolor(180, 40, 40)
		end
	elseif stat == "usage" then
		health = 100 - (item.data2 or 0)
		color = tocolor(20, 140, 250)
	elseif stat == "sdcard" then
		health = tonumber(item.data1) or 0
		color = tocolor(180, 40, 40)

		if health > 45 and health <= 75 then
			color = tocolor(255, 128, 0)
		elseif health <= 45 then
			color = tocolor(20, 165, 20)
		end
	end

	health = health / 100

	dxDrawRectangle(x + 2, y + defaultSettings.slotBoxHeight - 3 * k - 2 - (k - 1), defaultSettings.slotBoxWidth - 4, 3, tocolor(0, 0, 0, 175))
	dxDrawRectangle(x + 2, y + defaultSettings.slotBoxHeight - 3 * k - 2 - (k - 1), (defaultSettings.slotBoxWidth - 4) * health, 3, color)

	if health > 0 then
		return k + 1
	end

	return k
end

function isCursorOnBox(xS,yS,wS,hS)
	if(isCursorShowing()) then
		XY = {guiGetScreenSize()}
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*XY[1], cursorY*XY[2]
		if(cursorX >= xS and cursorX <= xS+wS and cursorY >= yS and cursorY <= yS+hS) then
			return true
		else
			return false
		end
	end	
end

bindKey("mouse_wheel_down", "down", function()
	local x = panelPosX - 5
	local y = panelPosY - 5
	if panelState == true then
		if itemsTableState == "player" and currentCategory == "craft" then
			if isCursorOnBox(x+(panelWidth/1.85), y+27.5, panelHeight-35, 150) then
				if craftItemNameDrawMax < maxCraftItemNameDraw then
					currentRowItem = currentRowItem+1
				end
			end
		end
	end
end)	
bindKey("mouse_wheel_up", "down", function()
	local x = panelPosX - 5
	local y = panelPosY - 5
	if panelState == true then
		if itemsTableState == "player" and currentCategory == "craft" then
			if isCursorOnBox(x+(panelWidth/1.85), y+27.5, panelHeight-35, 150) then
				if currentRowItem > 1 then
					currentRowItem = currentRowItem-1
				end
			end
		end
	end
end)

function getTooltipBestSize(text, subText, showItem)
	text = tostring(text)
	subText = subText and tostring(subText)

	if text == subText then
		subText = nil
	end

	local sx = dxGetTextWidth(text, 0.5, Roboto2, true) + 20

	if subText then
		sx = math.max(sx, dxGetTextWidth(subText, 0.5, Roboto2, true) + 20)
		text = "#4bd439" .. text .. "\n#ffffff" .. subText
	end

	local _, newLines = string.gsub(subText or "", "\n", "")
	local sy = 10 * (newLines + 4)

	if not subText then
		sy = 30
	end

	if showItem then
		sx = sx + defaultSettings.slotBoxWidth - 10
	end

	return sx, sy, text
end

function showTooltip(x, y, text, subText, showItem)
	local sx, sy, text = getTooltipBestSize(text, subText, showItem)

	if showItem then
		x = math.floor(x - sx / 2)

		--dxDrawImage(x, y, sx, sy, "files/tooltip_bg.png", 0, 0, 0, tocolor(23,23,23,210))
		dxDrawRectangle(x, y-6, sx+10, sy+10, tocolor(20,20,20,240))
		--dxDrawBorder(x, y-6, sx+10, sy+10,2, tocolor(37,117,199,210))
		--dxDrawBorder(x, y-6, sx+10, sy+10, 10,tocolor(16,16,16,210))
		--dxDrawImage(x + (sx - 16) / 2, y + sy, 16, 8, "files/tooltip_arrow.png", 0, 0, 0, tocolor(0, 0, 0, 190))

		drawItemPicture(showItem, math.floor(x), math.floor(y + (sy - defaultSettings.slotBoxHeight) / 2))

		dxDrawText(showItem.amount, x, y + (sy - defaultSettings.slotBoxHeight) / 2, x + defaultSettings.slotBoxWidth - 3, y + (sy + defaultSettings.slotBoxHeight) / 2 - 3, tocolor(255, 255, 255), 0.5, Roboto2, "right", "bottom")

		dxDrawText(text, x + defaultSettings.slotBoxWidth + 5, y, x + sx, y + sy, tocolor(255, 255, 255), 0.5, Roboto2, "left", "center", false, false, false, true)
	else
		x = math.max(0, math.min(screenX - sx, x))
		y = math.max(0, math.min(screenY - sy, y))

        dxDrawBorder(x, y, sx, sy,2, tocolor(16,16,16,240))
		dxDrawRectangle(x, y, sx, sy, tocolor(20,20,20,240))
		dxDrawText(text, x, y, x + sx, y + sy, tocolor(255, 255, 255, 255), 0.5, Roboto2, "center", "center", false, false, false, true)
	end
end

function toggleInventory(state)
	if panelState ~= state then
		if state then
			stackAmount = 0

			addEventHandler("onClientRender", getRootElement(), onRender, true, "low-999")

			panelState = true
		else
			if itemsTableState == "vehicle" or itemsTableState == "object" then
				local nearbyPlayers = getElementsByType("player", getRootElement(), true)
				
				triggerServerEvent("closeInventory", localPlayer, currentInventoryElement, nearbyPlayers)
			end

			removeEventHandler("onClientRender", getRootElement(), onRender)

			panelState = false

            movedItem = false
            movedslotId = false
            haveMoving = false

			stackAmount = 0
			fakeInputs = {}
			selectedInput = false
		end
	end
end

bindKey("i", "down",
	function (key, keyState)
		if getElementData(localPlayer, "loggedIn") then
			toggleInventory(not panelState)

			itemsTableState = "player"
			currentInventoryElement = localPlayer

			panelIsMoving = false
			selectedInput = false
		end
	end
)

exports.cosmo_admin:addAdminCommand("itemlist", 6, "Item lista")
addCommandHandler("itemlist",
	function ()
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			itemListState = not itemListState
			
			if itemListState then
				if not itemListItems then
					itemListItems = {}
					
					for i = 1, #availableItems do
						table.insert(itemListItems, i)
					end
				end
				
				addEventHandler("onClientRender", getRootElement(), onItemListRender, true, "low-1000")
				showCursor(true)
			else
				removeEventHandler("onClientRender", getRootElement(), onItemListRender)
				showCursor(false)
			end
		end
	end
)

function onItemListRender()
	absX, absY = 0, 0

	buttons = {}

	if isCursorShowing() then
		local relX, relY = getCursorPosition()

		absX = screenX * relX
		absY = screenY * relY
	end

	-- ** Háttér
	dxDrawRectangle(itemListPosX+110, itemListPosY-40, itemListWidth-200, itemListHeight+40, tocolor(0,0,0, 170))
	dxDrawRectangle(itemListPosX+110, itemListPosY+25, itemListWidth-200, 3, tocolor(255, 148, 40, 250))

	-- ** Cím
	--dxDrawRectangle(itemListPosX+130, itemListPosY-50, itemListWidth-200, 70, tocolor(15, 15, 15, 255))
	--dxDrawImage(math.floor(itemListPosX + 3), math.floor(itemListPosY + 3), 24, 24, ":cosmo_hud/files/logo.png", 0, 0, 0, tocolor(37,117,199))
	--dxDrawImage(itemListPosX + 110, itemListPosY-49, 70, 80, ":cosmo_hud/files/logo.png", 0, 0, 0, tocolor(255,255,255))
	dxDrawText("#ff9428Cosmo#ffffffMTA - Item Lista", itemListPosX + 120, itemListPosY-42, 0, itemListPosY + 30, tocolor(255, 255, 255,230), 1, RobotoT, "left", "center", false, false, false, true)

	-- ** Kilépés
	local closeTextWidth = dxGetTextWidth("X", 1, RobotoL)
	local closeTextPosX = itemListPosX + itemListWidth - closeTextWidth - 96
	local closeColor = tocolor(255, 255, 255)

	if absX >= closeTextPosX and absY >= itemListPosY - 50 and absX <= closeTextPosX + closeTextWidth and absY <= itemListPosY + 30 then
		closeColor = tocolor(215, 89, 89)

		if getKeyState("mouse1") then
			selectedInput = false
			itemListState = false
			removeEventHandler("onClientRender", getRootElement(), onItemListRender)
			showCursor(false)
			return
		end
	end
    --dxDrawRectangle(itemListPosX+itemListWidth-200,itemListPosY-23, 100,30, tocolor(23,23,23, 250))
	dxDrawText("X", closeTextPosX, itemListPosY, 0, itemListPosY - 50, closeColor, 1, RobotoL, "left", "center")

	-- ** Content
	local x = itemListPosX + 110
	local y = itemListPosY + 30

	for i = 1, 12 do
		local colorOfRow = tocolor(0,0,0, 120)

		if i % 2 == 0 then
			colorOfRow = tocolor(0,0,0, 170)
		end

		dxDrawRectangle(x, y, itemListWidth-200, defaultSettings.slotBoxHeight, colorOfRow)

		local itemId = itemListItems[i + itemListOffset]

		if itemId then
			if itemPictures[itemId] then
				dxDrawImage(math.floor(x), math.floor(y), defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, itemPictures[itemId])
			end

			local itemName = getItemName(itemId)
			local itemDesc = getItemDescription(itemId)

			if itemDesc then
				dxDrawText("#4bd439[" .. itemId .. "] #ffffff" .. itemName, x + defaultSettings.slotBoxWidth + 5, y, 0, y + defaultSettings.slotBoxHeight / 2 + 3, tocolor(255, 255, 255,230), 0.45, Roboto, "left", "center", false, false, false, true)
				dxDrawText(itemDesc, x + defaultSettings.slotBoxWidth + 5, y + defaultSettings.slotBoxHeight / 2 - 3, 0, y + defaultSettings.slotBoxHeight, tocolor(200, 200, 200), 0.4, Roboto, "left", "center")
			else
				dxDrawText("#4bd439[" .. itemId .. "] #ffffff" .. itemName, x + defaultSettings.slotBoxWidth + 5, y, 0, y + defaultSettings.slotBoxHeight, tocolor(255, 255, 255,230), 0.45, Roboto, "left", "center", false, false, false, true)
			end
		end

		y = y + defaultSettings.slotBoxHeight
	end

	-- ** Scrollbar
	if #itemListItems > 12 then
		local listSize = defaultSettings.slotBoxHeight * 12

		dxDrawRectangle(itemListPosX + itemListWidth - 95, itemListPosY + 30, 5, listSize, tocolor(0,0,0,200))
		dxDrawRectangle(itemListPosX + itemListWidth - 95, itemListPosY + 30 + (listSize / #itemListItems) * math.min(itemListOffset, #itemListItems - 12), 5, (listSize / #itemListItems) * 12, tocolor(255, 148, 40))
	end

	-- ** Kereső mező
	drawInput("searchitem|50", "Keresés...", itemListPosX + 113, itemListPosY + itemListHeight - 30, itemListWidth - 206, 25, Roboto, 0.5)

	activeButton = false

	if absX and absY then
		for k, v in pairs(buttons) do
			if absX >= v[1] and absY >= v[2] and absX <= v[1] + v[3] and absY <= v[2] + v[4] then
				activeButton = k
				break
			end
		end
	end
end

function searchItems()
	itemListItems = {}
	
	local searchText = fakeInputs["searchitem|50"] or ""

	if utf8.len(searchText) < 1 then
		for i = 1, #availableItems do
			table.insert(itemListItems, i)
		end
	elseif tonumber(searchText) then
		searchText = tonumber(searchText)

		if availableItems[searchText] then
			table.insert(itemListItems, searchText)
		end
	else
		for i = 1, #availableItems do
			if utf8.find(utf8.lower(availableItems[i][1]), utf8.lower(searchText)) then
				table.insert(itemListItems, i)
			end
		end
	end
	
	itemListOffset = 0
end

addEventHandler("onClientCharacter", getRootElement(),
	function (character)
		if selectedInput and character ~= "\\" and fakeInputs[selectedInput] then
			local selected = split(selectedInput, "|")

			if panelState and not useingNametag and character == "i" then
				toggleInventory(false)
				return
			end

			if utf8.len(fakeInputs[selectedInput]) < tonumber(selected[2]) then
				if selected[3] == "num-only" and not tonumber(character) then
					return
				end

				if not string.find(character, "[a-zA-Z0-9#@._öüóőúűéáÖÜÓŐÚŰÉÁ]") then
					return
				end

				fakeInputs[selectedInput] = fakeInputs[selectedInput] .. character

				if selected[1] == "stack" then
					local stack = tonumber(fakeInputs[selectedInput])

					if stack then
						if stack >= 0 then
							stackAmount = tonumber(string.format("%.0f", stack))
						else
							stackAmount = 0
						end
					else
						stackAmount = 0
					end
				elseif selected[1] == "searchitem" then
					searchItems()
				end
			end
		end
	end
)

addEventHandler("onClientKey", getRootElement(),
	function (key, state)
		if itemListState and isCursorShowing() then
			if #itemListItems > 12 then
				if key == "mouse_wheel_down" and itemListOffset < #itemListItems - 12 then
					itemListOffset = itemListOffset + 1
				elseif key == "mouse_wheel_up" and itemListOffset > 0 then
					itemListOffset = itemListOffset - 1
				end
			end
		end

		if selectedInput and state then
			cancelEvent()

			if key == "backspace" then
				removeCharacterFromInput(selectedInput)
				if getKeyState(key) then
					repeatStartTimer = setTimer(removeCharacterFromInput, 500, 1, selectedInput, true)
				end
			end
		else
			if isTimer(repeatStartTimer) then
				killTimer(repeatStartTimer)
			end

			if isTimer(repeatTimer) then
				killTimer(repeatTimer)
			end

			repeatStartTimer = nil
			repeatTimer = nil
		end
	end
)

function removeCharacterFromInput(input, repeatTheTimer)
	if utf8.len(fakeInputs[input]) >= 1 then
		fakeInputs[input] = utf8.sub(fakeInputs[input], 1, -2)

		if string.find(input, "stack") then
			local stack = tonumber(fakeInputs[input])

			if stack then
				if stack >= 0 then
					stackAmount = tonumber(string.format("%.0f", stack))
				else
					stackAmount = 0
				end
			else
				stackAmount = 0
			end
		elseif string.find(input, "searchitem") then
			searchItems()
		end
	end

	if repeatTheTimer then
		repeatTimer = setTimer(removeCharacterFromInput, 50, 1, selectedInput, repeatTheTimer)
	end
end

local casetteBlips = {}

function checkCasetteBlip()
	if isElement(localPlayer) then
		local casetts = {}
		
		if not itemsTable.player then
			return
		end
		
		for k, v in pairs(itemsTable.player) do
			if v.itemId == 181 then
				table.insert(casetts, v.itemId)
			end
		end
		
		if #casetts > 0 then
			setElementData(localPlayer, "inATMCasette", true)
		else
			setElementData(localPlayer, "inATMCasette", false)
		end
	end
end

function checkShopCasetteBlip()
	if isElement(localPlayer) then
		local casetts = {}
		
		if not itemsTable.player then
			return
		end
		
		for k, v in pairs(itemsTable.player) do
			if v.itemId == 244 then
				table.insert(casetts, v.itemId)
			end
		end
		
		if #casetts > 0 then
			setElementData(localPlayer, "inShopCasette", true)
		else
			setElementData(localPlayer, "inShopCasette", false)
		end
	end
end

addEventHandler("onClientElementDataChange", root,
	function(dataName, oldValue, newValue)
		if getElementType(source) == "player" then
			if dataName == "inATMCasette" then
				if getElementData(source, "inATMCasette") then
					if exports.cosmo_groups:isPlayerHavePermission(localPlayer, "cuff") then
						createCasetteBlip(source)
					end
				elseif oldValue then
					if exports.cosmo_groups:isPlayerHavePermission(localPlayer, "cuff") then
						if isElement(casetteBlips[source]) then
							destroyElement(casetteBlips[source])
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientElementDataChange", root,
	function(dataName, oldValue, newValue)
		if getElementType(source) == "player" then
			if dataName == "inShopCasette" then
				if getElementData(source, "inShopCasette") then
					if exports.cosmo_groups:isPlayerHavePermission(localPlayer, "cuff") then
						createShopCasetteBlip(source)
					end
				elseif oldValue then
					if exports.cosmo_groups:isPlayerHavePermission(localPlayer, "cuff") then
						if isElement(shopBlips[source]) then
							destroyElement(shopBlips[source])
						end
					end
				end
			end
		end
	end
)

function createCasetteBlip(player)
	if isElement(player) then
		if casetteBlips[player] and isElement(casetteBlips[player]) then
			destroyElement(casetteBlips[player])
		end
		
		casetteBlips[player] = createBlip(0, 0, 0)
		setElementData(casetteBlips[player], "blipIcon", "target")
		setElementData(casetteBlips[player], "blipTooltipText", "ATM pénzkazetta")
		attachElements(casetteBlips[player], player)
		setElementData(casetteBlips[player], "blipColor", tocolor(227, 224, 48))
		setElementData(casetteBlips[player], "blipFarShow", true)
	end
end
setTimer(checkCasetteBlip, 2000, 0)

function createShopCasetteBlip(player)
	if isElement(player) then
		if shopBlips[player] and isElement(shopBlips[player]) then
			destroyElement(shopBlips[player])
		end
		
		shopBlips[player] = createBlip(0, 0, 0)
		setElementData(shopBlips[player], "blipIcon", "target")
		setElementData(shopBlips[player], "blipTooltipText", "Bolti pénzkazetta")
		attachElements(shopBlips[player], player)
		setElementData(shopBlips[player], "blipColor", tocolor(227, 224, 48))
		setElementData(shopBlips[player], "blipFarShow", true)
	end
end
setTimer(createShopCasetteBlip, 2000, 0)

function createCraftCol()
	for i, v in ipairs(craftCol) do
		colShape[i] = createColCuboid(v[1], v[2], v[3]-1, v[4], v[5], 3)
		setElementData(colShape[i], "craftShape.id", i)
	end
end

addEventHandler("onClientColShapeHit", root,
	function(hitPlayer)
		if hitPlayer ~= localPlayer then return end
		if not getElementDimension(localPlayer) == 1 then return end
		if not getElementInterior(localPlayer) == 2 then return end
		if not tonumber(getElementData(source, "craftShape.id")) then return end
		
		if tonumber(getElementData(source, "craftShape.id")) > 0 then
			for i, v in ipairs(craftCol) do
				if getElementData(source, "craftShape.id") == i then
					inCraftShape = true
				end
			end
		end
	end
)

addEventHandler("onClientColShapeLeave", root,
	function(hitPlayer)
		if hitPlayer ~= localPlayer then return end
		if not tonumber(getElementData(source, "craftShape.id")) then return end
		if getElementData(source, "craftShape.id") > 0 then
			inCraftShape = false
		end
	end
)

local playerKazettaSounds = {}

txd_floors = engineLoadTXD ( "files/hammer/hammer.txd" )
engineImportTXD ( txd_floors, 364 )
dff_floors = engineLoadDFF ( "files/hammer/hammer.dff")
engineReplaceModel ( dff_floors, 364 )

function giveATMVIsszajelzes(type)
	if not type then return end
	triggerServerEvent("stopKaziOpen", resourceRoot, localPlayer)
	setElementFrozen(localPlayer, false)
	if type == 1 then -- Nem sikerült
		local now = getRealTime().timestamp
		local info = now .. "/Y/180"
		
		setElementData(localPlayer, "char.painted", info)
		setElementData(localPlayer, "char.paintTime", 180)
		
		outputChatBox("#ff9428[CosmoMTA - ATM]: #FFFFFFNem sikerült kinyitni a kazettát, ezért #ff4646felrobbant a festékpatron#FFFFFF.", 255, 255, 255, true)
		outputChatBox("#ff9428[CosmoMTA - ATM]: #FFFFFFA #ff4646festék #FFFFFF3 órán át látható lesz az arcodon.", 255, 255, 255, true)
	else -- Sikerült
		local a = math.random(1, 100)
		if a > 30 then
			local randomMoney = math.random(5000000, 10000000)
			setElementData(localPlayer, "char.Money", getElementData(localPlayer, "char.Money")+randomMoney)
			outputChatBox("#ff9428[CosmoMTA - ATM]: #FFFFFFKinyitottad a kazettát, és #ff9428"..convertNumber(randomMoney).." $ #ffffffvolt benne.", 255, 255, 255, true)
		else
			outputChatBox("#ff9428[CosmoMTA - ATM]: #FFFFFFKinyitottad a kazettát, és #ff94280 $ #ffffffvolt benne.", 255, 255, 255, true)
		end
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

--addEvent("successOpen", true)
--addEventHandler("successOpen", root,
	--function()
		--local a = math.random(1, 100)
		--if a > 30 then
			--local randomMoney = math.random(10000, 30000)
			--setElementData(localPlayer, "char.Money", getElementData(localPlayer, "char.Money")+randomMoney)
			--outputChatBox("#ff9428[CosmoMTA - ATM]: #FFFFFFKinyitottad a kazettát, és #4bd439"..randomMoney.." Ft #ffffffvolt benne.", 255, 255, 255, true)

		--else
			--outputChatBox("#ff9428[CosmoMTA - ATM]: #FFFFFFKinyitottad a kazettát, és #4bd4390 $ #ffffffvolt benne.", 255, 255, 255, true)
		--end
	--end
--)

--addEvent("failedOpen", true)
--addEventHandler("failedOpen", root,
	--function()
		--local now = getRealTime().timestamp
		--local info = now .. "/Y/180"
		
		--setElementData(localPlayer, "char.painted", info)
		--setElementData(localPlayer, "char.paintTime", 180)
		
		--outputChatBox("#ff9428[CosmoMTA - ATM]: #FFFFFFNem sikerült kinyitni a kazettát, ezért #4bd439felrobbant a festékpatron#FFFFFF.", 255, 255, 255, true)
		--outputChatBox("#ff9428[CosmoMTA - ATM]: #FFFFFFA #4bd439festék #FFFFFF3 órán át látható lesz az arcodon.", 255, 255, 255, true)
	--end
--)

addEvent("successOpenn", true)
addEventHandler("successOpenn", root,
	function()
		local a = math.random(1, 100)
		if a > 30 then
			local randomMoney = math.random(10000, 30000)
			setElementData(localPlayer, "char.Money", getElementData(localPlayer, "char.Money")+randomMoney)
			outputChatBox("#ff9428[CosmoMTA - ShopRob]: #FFFFFFKinyitottad a kazettát, és #4bd439"..randomMoney.." Ft #ffffffvolt benne.", 255, 255, 255, true)

		else
			outputChatBox("#ff9428[CosmoMTA - ShopRob]: #FFFFFFKinyitottad a kazettát, és #4bd4390 Ft #ffffffvolt benne.", 255, 255, 255, true)
		end
	end
)

addEvent("failedOpenn", true)
addEventHandler("failedOpenn", root,
	function()
		local now = getRealTime().timestamp
		local info = now .. "/Y/180"
		
		setElementData(localPlayer, "char.painted", info)
		setElementData(localPlayer, "char.paintTime", 180)
		
		outputChatBox("#ff9428[CosmoMTA - ShopRob]: #FFFFFFNem sikerült kinyitni a kazettát, ezért #4bd439felrobbant a festékpatron#FFFFFF.", 255, 255, 255, true)
		outputChatBox("#ff9428[CosmoMTA - ShopRob]: #FFFFFFA #4bd439festék #FFFFFF3 órán át látható lesz az arcodon.", 255, 255, 255, true)
	end
)

function getMoney()
    local maxDrawNull = 4
    local actualCharMoney = maxDrawNull - string.len(tostring(getElementData(localPlayer,"char.Money")))
    finalConvert = ""
             
    for i = 0, actualCharMoney, 1 do
        finalConvert = finalConvert .. "0"
    end

    if getElementData(localPlayer, "char.Money") >= 0 then
        finalConvert = finalConvert .. "#4bd439" .. thousandsStepper(getElementData(localPlayer, "char.Money"))
    else
        finalConvert = "-" .. finalConvert .. "#4bd439" .. thousandsStepper(math.abs(getElementData(localPlayer, "char.Money")))
    end

    return finalConvert
end

function thousandsStepper(amount)
    local formatted = amount
    
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1 %2')
        if k == 0 then
            break
        end
    end

    return formatted
end

function dxDrawBorder(x, y, w, h, radius, color) 
	dxDrawRectangle(x - radius, y, radius, h, color)
	dxDrawRectangle(x + w, y, radius, h, color)
	dxDrawRectangle(x - radius, y - radius, w + (radius * 2), radius, color)
	dxDrawRectangle(x - radius, y + h, w + (radius * 2), radius, color)
end