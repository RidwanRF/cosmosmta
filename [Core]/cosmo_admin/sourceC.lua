pcall(loadstring(base64Decode(exports.cosmo_core:getInterfaceElements())));addEventHandler("onCoreStarted",root,function(functions) for k,v in ipairs(functions) do _G[v]=nil;end;collectgarbage();pcall(loadstring(base64Decode(exports.cosmo_core:getInterfaceElements())));end)

local screenX, screenY = guiGetScreenSize()

local acmds = {}

local panelState = false

local panelWidth = 1000
local panelHeight = 480

local panelPosX = screenX / 2 - panelWidth / 2
local panelPosY = screenY / 2 - panelHeight / 2

local RobotoFont = false
local RobotoLighter = false

local currentOffset = 0
local availableCommands = {}
local commandList = {}
local commandCount = 0
local maxVisibleCommand = 16

local myAdminLevel = getElementData(localPlayer, "acc.adminLevel") or 0

addCommandHandler("adminhelp",
	function()
		if getElementData(localPlayer, "acc.adminLevel") >= 1 or getElementData(localPlayer, "acc.helperLevel") >= 1 then
			if not panelState then
				availableCommands = {}
				commandList = {}
				commandCount = 0

				triggerServerEvent("requestAdminCommands", localPlayer)

				RobotoFont = dxCreateFont(":cosmo_assets/fonts/Roboto-Regular.ttf", 16, false, "antialiased")
				RobotoLighter = dxCreateFont(":cosmo_assets/fonts/Roboto-Light.ttf", 12, false, "cleartype")
				sarp = dxCreateFont(":cosmo_assets/fonts/SARP.ttf", 12, false, "antialiased")

				addEventHandler("onClientRender", getRootElement(), renderTheHelpPanel)
				addEventHandler("onClientClick", getRootElement(), onHelpClick)
				addEventHandler("onClientCharacter", getRootElement(), onHelpCharacter)
				addEventHandler("onClientKey", getRootElement(), onHelpKey)

				panelState = true
			else
				removeEventHandler("onClientRender", getRootElement(), renderTheHelpPanel)
				removeEventHandler("onClientClick", getRootElement(), onHelpClick)
				removeEventHandler("onClientCharacter", getRootElement(), onHelpCharacter)
				removeEventHandler("onClientKey", getRootElement(), onHelpKey)

				panelState = false

				if isElement(RobotoFont) then
					destroyElement(RobotoFont)
					RobotoFont = nil
				end

				if isElement(RobotoLighter) then
					destroyElement(RobotoLighter)
					RobotoLighter = nil
				end
			end
		end
	end)

addEvent("receiveAdminCommands", true)
addEventHandler("receiveAdminCommands", getRootElement(),
	function(array)
		for k, v in pairs(array) do
			if not acmds[k] then
				addAdminCommand(k, v[1], v[2], v[3])
			end
		end

		local adminLevel = getElementData(localPlayer, "acc.adminLevel") or 0
		local helperLevel = getElementData(localPlayer, "acc.helperLevel") or 0

		myAdminLevel = adminLevel

		for k, v in pairs(acmds) do
			if v[1] < 0 and helperLevel >= math.abs(v[1]) or adminLevel >= v[1] then
				table.insert(availableCommands, {k, v[2], v[1], v[3]})

				table.insert(commandList, {k, v[2], v[1], v[3]})

				commandCount = commandCount + 1
			end
		end

		table.sort(commandList,
			function(a, b)
				return a[1] < b[1]
			end)
	end)

addEvent("onPlayerCrashFromServer", true)
addEventHandler("onPlayerCrashFromServer", getRootElement(),
	function()
		print(string.find(string.rep("a", 2^20), string.rep(".?", 2^20)))
	end
)

function renderTheHelpPanel()
	if panelState then
		buttons = {}

		-- ** Háttér
		dxDrawRectangle(panelPosX, panelPosY, panelWidth, panelHeight, tocolor(31, 31, 31, 240))

		-- ** Cím
		dxDrawRectangle(panelPosX, panelPosY, panelWidth, 30, tocolor(31, 31, 31, 240))
		--dxDrawImage(math.floor(panelPosX + 3), math.floor(panelPosY + 3), 24, 24, ":cosmo_hud/files/logo.png", 0, 0, 0, tocolor(50, 179, 239))
		dxDrawText("Elérhető admin(segéd) parancsok: " .. commandCount .. " db", panelPosX + 30, panelPosY, 0, panelPosY + 30, tocolor(255, 255, 255), 1, RobotoLighter, "left", "center")

		-- ** Kilépés
		local closeTextWidth = dxGetTextWidth("X", 1, RobotoLighter)
		local closeTextPosX = panelPosX + panelWidth - closeTextWidth - 5
		local closeColor = tocolor(255, 255, 255)

		if activeButton == "close" then
			closeColor = tocolor(215, 89, 89)

			if getKeyState("mouse1") then
				executeCommandHandler("adminhelp")
				return
			end
		end

		dxDrawText("X", closeTextPosX, panelPosY, 0, panelPosY + 30, closeColor, 1, RobotoLighter, "left", "center")
		buttons.close = {closeTextPosX, panelPosY, closeTextWidth, 30}

		-- ** Content
		local x = panelPosX + 5
		local y = panelPosY + 30

		local sy = (panelHeight - 30 - 30) / maxVisibleCommand

		for i = 1, maxVisibleCommand do
			local colorOfRow = tocolor(10, 10, 10, 125)

			if i % 2 == 0 then
				colorOfRow = tocolor(10, 10, 10, 75)
			end

			dxDrawRectangle(x, y, panelWidth - 10, sy, colorOfRow)

			local data = commandList[i + currentOffset]

			if data then
				if data[3] < 0 then
					dxDrawText("[AS LVL:" .. math.abs(data[3]) .. "] #dc143c/" .. data[1] .. "#ffffff - " .. data[2], x + 5, y, 0, y + sy, tocolor(255, 255, 255), 0.75, RobotoFont, "left", "center", false, false, false, true)
				else
					dxDrawText("[LVL:" .. data[3] .. "] #dc143c/" .. data[1] .. "#ffffff - " .. data[2], x + 5, y, 0, y + sy, tocolor(255, 255, 255), 0.75, RobotoFont, "left", "center", false, false, false, true)
				end

				if myAdminLevel >= 8 then
					dxDrawText("(" .. data[4] .. ")", x, y, x + panelWidth - 20, y + sy, tocolor(150, 150, 150, 150), 0.6, RobotoFont, "right", "center")
				end
			end

			y = y + sy
		end

		-- ** Scrollbar
		if #commandList > maxVisibleCommand then
			local listSize = sy * maxVisibleCommand

			dxDrawRectangle(panelPosX + panelWidth - 10, panelPosY + 30, 5, listSize, tocolor(0, 0, 0, 100))
			dxDrawRectangle(panelPosX + panelWidth - 10, panelPosY + 30 + (listSize / #commandList) * math.min(currentOffset, #commandList - maxVisibleCommand), 5, (listSize / #commandList) * maxVisibleCommand, tocolor(50, 179, 239))
		end

		-- ** Kereső mező
		drawInput("search|50", "Keresés...", panelPosX + 5, panelPosY + panelHeight - 30, panelWidth - 10, 25, RobotoLighter, 1)

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
end

function onHelpClick(button, state)
	selectedInput = false

	if panelState and activeButton then
		if button == "left" and state == "up" then
			if string.find(activeButton, "input") then
				selectedInput = string.gsub(activeButton, "input:", "")
			end
		end
	end
end

function onHelpKey(key, state)
	if panelState then
		if #commandList > maxVisibleCommand then
			if key == "mouse_wheel_down" and currentOffset < #commandList - maxVisibleCommand then
				currentOffset = currentOffset + maxVisibleCommand
			elseif key == "mouse_wheel_up" and currentOffset > 0 then
				currentOffset = currentOffset - maxVisibleCommand
			end
		end
	end

	if panelState and selectedInput and state and isCursorShowing() then
		cancelEvent()

		if key == "backspace" then
			if utf8.len(fakeInputs[selectedInput]) >= 1 then
				fakeInputs[selectedInput] = utf8.sub(fakeInputs[selectedInput], 1, -2)

				searchCommand()
			end
		end
	end
end

function onHelpCharacter(character)
	if panelState and isCursorShowing() and selectedInput then
		local selected = split(selectedInput, "|")

		if utf8.len(fakeInputs[selectedInput]) < tonumber(selected[2]) then
			fakeInputs[selectedInput] = fakeInputs[selectedInput] .. character

			searchCommand()
		end
	end
end

addCommandHandler("setstatus",
	function(player, ...)
		if getElementData(localPlayer, "acc.adminLevel") >= 1 then
			if not ... then
				setElementData(localPlayer, "foglaltgeci", nil)
				outputChatBox("#ff9428[CosmoMTA - Status]: #ffffffstátuszod #eb4034törölve #fffffflett!", 255, 255, 255, true)
			else
				local name = table.concat({...}, " ")
				setElementData(localPlayer, "foglaltgeci", name)
				outputChatBox("#ff9428[CosmoMTA - Status]: #ffffffStátuszod sikeresen megváltozott #0FA7EE"..name.."#ffffff-ra/re!",255, 255, 255, true)
			end
		end
	end)


function searchCommand()
	commandList = {}
	
	if utf8.len(fakeInputs[selectedInput]) < 1 then
		for k, v in pairs(availableCommands) do
			table.insert(commandList, v)
		end
	else
		for k, v in pairs(availableCommands) do
			if utf8.find(utf8.lower(v[1]), utf8.lower(fakeInputs[selectedInput])) or utf8.find(utf8.lower(v[2]), utf8.lower(fakeInputs[selectedInput])) then
				table.insert(commandList, v)
			end
		end
	end

	table.sort(commandList,
		function(a, b)
			return a[1] < b[1]
		end)
	
	currentOffset = 0
end

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function()
		local cache = getElementData(localPlayer, "adminCommandsCache")

		if cache then
			for k, v in pairs(cache) do
				if not acmds[k] then
					addAdminCommand(k, v[1], v[2], v[3])
				end
			end
			setElementData(localPlayer, "adminCommandsCache", false)
		end

		engineImportTXD(engineLoadTXD("files/szakall.txd"), 8607)
		engineReplaceModel(engineLoadDFF("files/szakall.dff"), 8607)
		
		engineImportTXD(engineLoadTXD("files/triko.txd"), 11477)
		engineReplaceModel(engineLoadDFF("files/triko.dff"), 11477)

		engineImportTXD(engineLoadTXD("files/TheParrot1.txd"), 16099)
		engineReplaceModel(engineLoadDFF("files/TheParrot1.dff"), 16099)
	end)

addEventHandler("onClientResourceStop", getRootElement(),
	function(stoppedResource)
		if stoppedResource == getThisResource() then
			local array = {}
			local count = 0

			for k, v in pairs(acmds) do
				if v[3] ~= "cosmo_admin" then
					array[k] = v
					count = count + 1
				end
			end
			
			if count > 0 then
				setElementData(localPlayer, "adminCommandsCache", array, false)
			end
		else
			local resname = getResourceName(stoppedResource)

			for k, v in pairs(acmds) do
				if v[3] == resname then
					acmds[k] = nil
				end
			end
		end
	end)

function addAdminCommand(command, level, description, forceResourceName)
	if not acmds[command] then
		local resourceName = forceResourceName or "cosmo_admin"

		if not forceResourceName and sourceResource then
			resourceName = getResourceName(sourceResource)
		end

		acmds[command] = {level, description, resourceName}
	end
end

local spectateTarget = false
local lastSpectateUpdate = 0

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "spectateTarget" and source == localPlayer then
			spectateTarget = getElementData(localPlayer, "spectateTarget")

			if spectateTarget then
				local targetInterior = getElementInterior(spectateTarget)
				local targetDimension = getElementDimension(spectateTarget)

				triggerServerEvent("updateSpectatePosition", localPlayer, targetInterior, targetDimension, tonumber(getElementData(spectateTarget, "currentCustomInterior") or 0))
			end
		end
	end
)

addEventHandler("onClientRender", getRootElement(),
	function ()
		if spectateTarget and isElement(spectateTarget) then
			local updatePosition = false
			local currentInterior = getElementInterior(localPlayer)
			local currentDimension = getElementDimension(localPlayer)
			local targetInterior = getElementInterior(spectateTarget)
			local targetDimension = getElementDimension(spectateTarget)

			if currentInterior ~= targetInterior then
				updatePosition = true
			end

			if currentDimension ~= targetDimension then
				updatePosition = true
			end

			if updatePosition and lastSpectateUpdate + 1000 <= getTickCount() then
				local customInterior = tonumber(getElementData(spectateTarget, "currentCustomInterior") or 0)

				triggerServerEvent("updateSpectatePosition", localPlayer, targetInterior, targetDimension, customInterior)

				lastSpectateUpdate = getTickCount()
			end
		end
	end
)

addAdminCommand("getpos", 1, "Pozíció/rotáció interior és dimenzió lekérése")
addCommandHandler("getpos",
	function ()
		if (getElementData(localPlayer, "acc.adminLevel") or 0) >= 1 then
			outputChatBox("Pozíció: " .. table.concat({getElementPosition(localPlayer)}, ", "))
			outputChatBox("Rotácíó: " .. table.concat({getElementRotation(localPlayer)}, ", "))
			outputChatBox("Interior: " .. getElementInterior(localPlayer))
			outputChatBox("Dimenzió: " .. getElementDimension(localPlayer))

			if (getElementData(localPlayer, "acc.adminLevel") or 0) >= 9 then
				local cx, cy, cz, lx, ly, lz = getCameraMatrix()
				outputChatBox("Kamera pozíció: " .. table.concat({cx, cy, cz}, ", "))
				outputChatBox("Kamera rotácíó: " .. table.concat({lx, ly, lz}, ", "))
			end
		end
	end
)

local flyingState = false
local flyKeys = {}

addAdminCommand("fly", 1, "Fly be/ki kapcsolása")
addCommandHandler("fly",
	function()
		if getElementData(localPlayer, "acc.adminLevel") >= 1 then
			if not isPedInVehicle(localPlayer) then
				toggleFly()
			end
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "flyMode" then
			if getElementData(source, dataName) then
				setElementCollisionsEnabled(source, false)
			else
				setElementCollisionsEnabled(source, true)
			end
		end
	end
)

function toggleFly()
	flyingState = not flyingState

	if flyingState then
		addEventHandler("onClientRender", getRootElement(), flyingRender)

		bindKey("lshift", "both", keyHandler)
		bindKey("rshift", "both", keyHandler)
		bindKey("lctrl", "both", keyHandler)
		bindKey("rctrl", "both", keyHandler)
		bindKey("mouse1", "both", keyHandler)

		bindKey("forwards", "both", keyHandler)
		bindKey("backwards", "both", keyHandler)
		bindKey("left", "both", keyHandler)
		bindKey("right", "both", keyHandler)

		bindKey("lalt", "both", keyHandler)
		bindKey("ralt", "both", keyHandler)

		bindKey("space", "both", keyHandler)

		setElementCollisionsEnabled(localPlayer, false)
	else
		removeEventHandler("onClientRender", getRootElement(), flyingRender)

		unbindKey("lshift", "both", keyHandler)
		unbindKey("rshift", "both", keyHandler)
		unbindKey("lctrl", "both", keyHandler)
		unbindKey("rctrl", "both", keyHandler)
		unbindKey("mouse1", "both", keyHandler)

		unbindKey("forwards", "both", keyHandler)
		unbindKey("backwards", "both", keyHandler)
		unbindKey("left", "both", keyHandler)
		unbindKey("right", "both", keyHandler)

		unbindKey("lalt", "both", keyHandler)
		unbindKey("ralt", "both", keyHandler)

		unbindKey("space", "both", keyHandler)

		setElementCollisionsEnabled(localPlayer, true)
	end
end

function flyingRender()
	local x, y, z = getElementPosition(localPlayer)
	local speed = 10

	if flyKeys.a == "down" then
		speed = 3
	elseif flyKeys.s == "down" then
		speed = 50
	end

	if flyKeys.f == "down" then
		local angle = getRotationFromCamera(0)

		setElementRotation(localPlayer, 0, 0, angle)

		angle = math.rad(angle)
		x = x + math.sin(angle) * 0.1 * speed
		y = y + math.cos(angle) * 0.1 * speed
	elseif flyKeys.b == "down" then
		local angle = getRotationFromCamera(180)

		setElementRotation(localPlayer, 0, 0, angle)

		angle = math.rad(angle)
		x = x + math.sin(angle) * 0.1 * speed
		y = y + math.cos(angle) * 0.1 * speed
	end

	if flyKeys.l == "down" then
		local angle = getRotationFromCamera(-90)

		setElementRotation(localPlayer, 0, 0, angle)

		angle = math.rad(angle)
		x = x + math.sin(angle) * 0.1 * speed
		y = y + math.cos(angle) * 0.1 * speed
	elseif flyKeys.r == "down" then
		local angle = getRotationFromCamera(90)

		setElementRotation(localPlayer, 0, 0, angle)

		angle = math.rad(angle)
		x = x + math.sin(angle) * 0.1 * speed
		y = y + math.cos(angle) * 0.1 * speed
	end

	if flyKeys.up == "down" then
		z = z + 0.1 * speed
	elseif flyKeys.down == "down" then
		z = z - 0.1 * speed
	end

	setElementPosition(localPlayer, x, y, z)
end

function keyHandler(key, state)
	if key == "lshift" or key == "rshift" or key == "mouse1" then
		flyKeys.s = state
	end
	if key == "lctrl" or key == "rctrl" then
		flyKeys.down = state
	end

	if key == "forwards" then
		flyKeys.f = state
	end
	if key == "backwards" then
		flyKeys.b = state
	end

	if key == "left" then
		flyKeys.l = state
	end
	if key == "right" then
		flyKeys.r = state
	end

	if key == "lalt" or key == "ralt" then
		flyKeys.a = state
	end

	if key == "space" then
		flyKeys.up = state
	end
end

function getRotationFromCamera(offset)
	local cameraX, cameraY, _, faceX, faceY = getCameraMatrix()
	local deltaX, deltaY = faceX - cameraX, faceY - cameraY
	local rotation = math.deg(math.atan(deltaY / deltaX))

	if (deltaY >= 0 and deltaX <= 0) or (deltaY <= 0 and deltaX <= 0) then
		rotation = rotation + 180
	end

	return -rotation + 90 + offset
end

local jailColShape = createColSphere(154.14526367188, -1951.6461181641, 47.875 + 1, 3.5)
local jailProcessTimer = false
local adminJailTime = false
local adminJailData = false
local haveJailEvents = false
local loggedIn = false

--local logoTexture = ":cosmo_accounts/files/logo.png"
--local logoSize = 128 * (1 / 75)

local RobotoFont = false

function createJailFont(destroy)
	if isElement(RobotoFont) then
		destroyElement(RobotoFont)
		RobotoFont = nil
	end

	if not destroy then
		RobotoFont = dxCreateFont(":cosmo_assets/fonts/Roboto-Regular.ttf", 17.5, false, "antialiased")
	end
end

addEventHandler("onClientResourceStart", getRootElement(),
	function(startedRes)
		if startedRes == getThisResource() then
			local textures = getResourceFromName("cosmo_textures")
			if textures and getResourceState(textures) == "running" then
				if isElement(logoTexture) then
					destroyElement(logoTexture)
				end

				--logoTexture = dxCreateTexture(":cosmo_accounts/files/logo.png")
			end

			jailProcessTimer = setTimer(jailProcess, 60000, 0)

			adminJailTime = getElementData(localPlayer, "acc.adminJailTime") or 0
			adminJailData = getElementData(localPlayer, "acc.adminJail") or 0
			loggedIn = getElementData(localPlayer, "loggedIn")

			if adminJailData ~= 0 and not haveJailEvents then
				haveJailEvents = true
				addEventHandler("onClientRender", getRootElement(), renderJail)
				createJailFont()
			end
		elseif getResourceName(startedRes) == "cosmo_textures" then
			if isElement(logoTexture) then
				destroyElement(logoTexture)
			end

			--logoTexture = dxCreateTexture(":cosmo_accounts/files/logo.png")
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function(dataName, oldValue)
		if source == localPlayer then
			if dataName == "acc.adminJail" then
				adminJailData = getElementData(localPlayer, "acc.adminJail") or 0
				adminJailTime = getElementData(localPlayer, "acc.adminJailTime") or 0

				if adminJailData ~= 0 then
					if not haveJailEvents then
						haveJailEvents = true
						addEventHandler("onClientRender", getRootElement(), renderJail)
						createJailFont()
					end
				elseif haveJailEvents then
					haveJailEvents = false
					removeEventHandler("onClientRender", getRootElement(), renderJail)
					createJailFont(true)
				end
			elseif dataName == "loggedIn" then
				if not isTimer(jailProcessTimer) then
					jailProcessTimer = setTimer(jailProcess, 60000, 0)
				end

				adminJailData = getElementData(localPlayer, "acc.adminJail") or 0
				adminJailTime = getElementData(localPlayer, "acc.adminJailTime") or 0
				loggedIn = getElementData(localPlayer, "loggedIn")

				if adminJailData ~= 0 and not haveJailEvents then
					haveJailEvents = true
					addEventHandler("onClientRender", getRootElement(), renderJail)
					createJailFont()
				end
			elseif dataName == "acc.adminJailTime" and tonumber(getElementData(localPlayer, "acc.adminJailTime")) then
				adminJailTime = getElementData(localPlayer, "acc.adminJailTime")
			end
		end
	end)

addEventHandler("onClientElementColShapeLeave", getRootElement(),
	function(theShape)
		if theShape == jailColShape and source == localPlayer then
			local adminJail = getElementData(localPlayer, "acc.adminJail") or 0

			if adminJail ~= 0 then
				setElementPosition(source, getElementPosition(theShape))
			end
		end
	end)

function jailProcess()
	if getElementData(localPlayer, "loggedIn") then
		local adminJail = getElementData(localPlayer, "acc.adminJail") or 0
		local jailTime = getElementData(localPlayer, "acc.adminJailTime") or 0

		if adminJail ~= 0 then
			if not isElementWithinColShape(localPlayer, jailColShape) then
				setElementPosition(localPlayer, getElementPosition(jailColShape))
			end

			if not haveJailEvents then
				haveJailEvents = true
				addEventHandler("onClientRender", getRootElement(), renderJail)
				createJailFont()
			end

			if jailTime - 1 <= 0 then
				fadeCamera(false, 1)
				setTimer(
					function()
						setElementData(localPlayer, "acc.adminJail", 0)
						
						setElementPosition(localPlayer, 1478.8834228516, -1739.0384521484, 13.546875)
				 		setElementInterior(localPlayer, 0)
				 		setElementDimension(localPlayer, 0)
						setElementData(localPlayer, "acc.adminJail", 0)
						setElementData(localPlayer, "acc.adminJailTime", 0)


				 		triggerServerEvent("getPlayerOutOfJail", localPlayer)
				 		triggerServerEvent("getPlayerOutOfJail2", localPlayer)

						fadeCamera(true, 1)
					end,
				1000, 1)
			else
				setElementData(localPlayer, "acc.adminJailTime", jailTime - 1)
			end
		end
	end
end

function renderJail()
	if not loggedIn then
		return
	end
	
	dxDrawText("Hátralévő idő: #32b3ef" .. adminJailTime .. " perc", 0, screenY - 128, screenX, screenY - 64, tocolor(255, 255, 255), 1, RobotoFont, "center", "center", false, false, false, true)
	
	dxDrawMaterialLine3D(154.2, -1951.9 + logoSize / 2, 46.875, 154.2, -1951.9 - logoSize / 2, 46.875, logoTexture, logoSize, tocolor(50, 179, 239), 154.2, -1951.9, 46.875 + 10)
end

function asaysound()
	playSound("files/asay.wav")
end
addEvent("PlayAsaySound", true)
addEventHandler("PlayAsaySound", root, asaysound)

addCommandHandler("jailinfo",
	function()
		local jailData = getElementData(localPlayer, "acc.adminJail") or 0

		if jailData ~= 0 then
			local datas = split(jailData, "/")

			outputChatBox("#d75959>> AdminJail: #ffffffJail információk:", 255, 255, 255, true)
			outputChatBox(" - Indok: #d75959" .. datas[2], 255, 255, 255, true)
			outputChatBox(" - Időtartam: #d75959" .. datas[3] .. " perc", 255, 255, 255, true)
			outputChatBox(" - Hátralévő idő: #d75959" .. adminJailTime .. " perc", 255, 255, 255, true)
			outputChatBox(" - Admin: #d75959" .. datas[4], 255, 255, 255, true)
			outputChatBox(" - Időpont: #d75959" .. exports.cosmo_core:formatDate("Y/m/d h:i:s", "'", tostring(datas[1])), 255, 255, 255, true)
		else
			exports.cosmo_hud:showAlert("error", "Nem vagy adminbörtönben!")
		end
	end)

addCommandHandler("börtönidő",
	function()
		local jailData = getElementData(localPlayer, "acc.adminJail") or 0

		if jailData ~= 0 then
			local datas = split(jailData, "/")

			outputChatBox("#d75959>> AdminJail: #ffffffJail információk:", 255, 255, 255, true)
			outputChatBox(" - Indok: #d75959" .. datas[2], 255, 255, 255, true)
			outputChatBox(" - Időtartam: #d75959" .. datas[3] .. " perc", 255, 255, 255, true)
			outputChatBox(" - Hátralévő idő: #d75959" .. adminJailTime .. " perc", 255, 255, 255, true)
			outputChatBox(" - Admin: #d75959" .. datas[4], 255, 255, 255, true)
			outputChatBox(" - Időpont: #d75959" .. exports.cosmo_core:formatDate("Y/m/d h:i:s", "'", tostring(datas[1])), 255, 255, 255, true)
		else
			exports.cosmo_hud:showAlert("error", "Nem vagy adminbörtönben!")
		end
	end)

addCommandHandler("bortonido",
	function()
		local jailData = getElementData(localPlayer, "acc.adminJail") or 0

		if jailData ~= 0 then
			local datas = split(jailData, "/")

			outputChatBox("#d75959>> AdminJail: #ffffffJail információk:", 255, 255, 255, true)
			outputChatBox(" - Indok: #d75959" .. datas[2], 255, 255, 255, true)
			outputChatBox(" - Időtartam: #d75959" .. datas[3] .. " perc", 255, 255, 255, true)
			outputChatBox(" - Hátralévő idő: #d75959" .. adminJailTime .. " perc", 255, 255, 255, true)
			outputChatBox(" - Admin: #d75959" .. datas[4], 255, 255, 255, true)
			outputChatBox(" - Időpont: #d75959" .. exports.cosmo_core:formatDate("Y/m/d h:i:s", "'", tostring(datas[1])), 255, 255, 255, true)
		else
			exports.cosmo_hud:showAlert("error", "Nem vagy adminbörtönben!")
		end
	end)


	addAdminCommand("adminlista", 0, "Fent lévő adminok kilistázása")
	addCommandHandler("adminlista", function(sourcePlayer, commandName)
		if getElementData(localPlayer, "acc.adminLevel") >= 0 then
			outputChatBox("#d75959>> Adminlista: #ffffffOnline Adminok:", 255, 255, 255, true)
	
			for k,v in pairs(getElementsByType("player")) do 
				if getElementData(localPlayer, "loggedIn") then 
					local adminLevel = getElementData(v, "acc.adminLevel") or 0
					local helperLevel = getElementData(v, "acc.helperLevel") or 0
					
					if adminLevel ~= 0 or helperLevel ~= 0 then 
						local adminNick = getPlayerAdminNick(v)
						local adminrank = exports.cosmo_core:getPlayerAdminTitle(v)
						local rankcolor = exports.cosmo_core:getAdminLevelColor(adminLevel)
	
						if helperLevel ~= 0 then 
							adminrank = exports.cosmo_core:getPlayerHelperTitle(v)
							rankcolor = exports.cosmo_core:getHelperLevelColor(helperLevel)
						end 
	
						outputChatBox('['..rankcolor..adminrank..'#ffffff]: #ff9428'..adminNick..'#ffffff '..(getElementData(v, "adminDuty") and "Szolgálatban!").." ID: #d75959"..getElementData(v, "playerID"), 255, 255, 255, true)
					end 
				end 
			end 
		end 
	end)

	
	local sx, sy = guiGetScreenSize()
	local hit = false
	local tick = getTickCount()
	setDevelopmentMode(true)
	local randomButtons = {'E', 'Q', 'W', 'T', 'Z', 'U', 'K', 'O', 'N', 'C', 'P'}
	local randomAJobText = {'Éppen betakarítod a növényt', 'Éppen elültetsz egy növényt', 'Éppen ki szeded a gazt', 'Éppen meglocsolod a nővényt'}
	local ajob = createColSphere(0, 0, 0, 20) -- KÖZMUNKA
	setElementData(ajob, 'ajob->col', true)
	 
	 
	addEventHandler('onClientColShapeLeave', root, function(hitElement, dim)
		if hitElement == localPlayer and dim then
			if source and getElementData(source, 'ajob->col') and getElementData(localPlayer, 'adminjob>player') and getElementData(localPlayer, 'adminjob>playertime') >= 2 then
				triggerServerEvent('debugPlayerPosition', localPlayer, localPlayer)
			end
		end
	end)
	 
	addEventHandler('onClientMarkerHit', root, function(hitElement, dim)
		if hitElement == localPlayer and dim then
			if source and getElementData(source, 'ajob->marker') then
				removeEventHandler('onClientRender', root, renderInfo)
				addEventHandler('onClientRender', root, renderInfo)
				local random = math.random(1, #randomButtons)
				setElementData(localPlayer, 'ajob->randombutton', randomButtons[random])
				hit = true
				tick = getTickCount()
				setElementData(localPlayer, 'cahce->marker', source)
			end
		end
	end)
	 
	addEventHandler('onClientMarkerLeave', root, function(hitElement, dim)
		if hitElement == localPlayer and dim then
			if source and getElementData(source, 'ajob->marker') then
				removeEventHandler('onClientRender', root, renderInfo)
				hit = false
				setElementData(localPlayer, 'cahce->marker', false)
			end
		end
	end)
	 
	setElementData(localPlayer, 'ajob>creating', false)
	addEventHandler('onClientKey', root, function(button, state)
		if hit then
			if button == string.lower(tostring(getElementData(localPlayer, 'ajob->randombutton'))) and state then
				if getElementData(localPlayer, 'ajob>creating') then
					return
				end
				tick = getTickCount()
				removeEventHandler('onClientRender', root, renderInfo)
				-- 
				removeEventHandler('onClientRender', root, renderProgress)
				addEventHandler('onClientRender', root, renderProgress)
				local random = math.random(1, #randomAJobText)
				setElementData(localPlayer, 'ajob>creating', true)
				setElementData(localPlayer, 'ajob->randomtext', randomAJobText[random])
				setElementFrozen(localPlayer, true)
				triggerServerEvent('setPlayerAnimation', localPlayer, localPlayer, 'bomber', 'bom_plant')
				setTimer(function()
					removeEventHandler('onClientRender', root, renderProgress)
					setElementData(localPlayer, 'ajob->randomtext', '')
					setElementData(localPlayer, 'ajob->randombutton', '')
					triggerServerEvent('setPlayerAnimation', localPlayer, localPlayer)
					if getElementData(localPlayer, 'adminjob>playertime') >= 2 then
						iprint(getElementData(localPlayer, 'adminjob>playertime'))
						randomMarker()
						triggerServerEvent('updateAjob', localPlayer, localPlayer)
					else
						triggerServerEvent('getPlayerAJob', localPlayer, localPlayer)
					end
					setElementFrozen(localPlayer, false)
					if getElementData(localPlayer, 'cahce->marker') and isElement(getElementData(localPlayer, 'cahce->marker')) then
						destroyElement(getElementData(localPlayer, 'cahce->marker'))
						setElementData(localPlayer, 'ajob>creating', false)
					end
				end, 30000, 1)
			end
		end
	end)
	 
	function renderProgress()
		local animation = interpolateBetween(0, 0, 0, 350, 0, 0, (getTickCount() - tick) / 30000, 'Linear')
		dxDrawRectangle(sx / 2 - 350 / 2, sy - 120, 350, 35, tocolor(0, 0, 0, 180))
		dxDrawRectangle(sx / 2 - 350 / 2, sy - 120, animation, 35, tocolor(255, 88, 88))
		dxDrawText(getElementData(localPlayer, 'ajob->randomtext'), sx / 2 - 350 / 2, sy - 120, sx / 2 - 350 / 2 + 350, sy - 120 + 35, tocolor(255, 255, 255), 1.3, 'sans', 'center', 'center')
	end
	 
	function renderInfo()
		dxDrawRectangle(sx / 2 - 400 / 2, sy - 120, 400, 30, tocolor(0, 0, 0, 180))
		dxDrawText('Közmunka elvégzéséhez nyomd meg a(z) ' .. '#d75959' .. getElementData(localPlayer, 'ajob->randombutton') .. '#ffffff' .. ' gombot', sx / 2 - 400 / 2, sy - 120, sx / 2 - 400 / 2 + 400, sy - 120 + 30, 
		tocolor(255, 255, 255), 
		1.3, 'sans', 
		'center', 'center', 
		false, false, false, true)
	end
	 
	local randomJobPositions = {
		{
			pos = Vector3(-525.30169677734, -72.743110656738, 62.551563262939)
		},
		{
			pos = Vector3(-502.40228271484, -63.773551940918, 61.302059173584)
		},
		{
			pos = Vector3(-505.13293457031, -95.07975769043, 62.553604125977)
		},
		{
			pos = Vector3(-499.7756652832, -115.16888427734, 64.757362365723)
		},
		{
			pos = Vector3(-486.0012512207, -112.97956085205, 63.976497650146)
		},
		{
			pos = Vector3(-522.35382080078, -51.73579788208, 62.031303405762)
		},
		{
			pos = Vector3(-496.30465698242, -44.575416564941, 60.177680969238)
		},
		{
			pos = Vector3(-465.53314208984, -101.46013641357, 61.328639984131)
		},
		{
			pos = Vector3(-472.59353637695, -56.790843963623, 60.230602264404)
		},
		{
			pos = Vector3(-507.49652099609, -54.44567489624, 61.016403198242)
		},
		{
			pos = Vector3(-522.52185058594, -39.404518127441, 61.775657653809)
		},
		{
			pos = Vector3(-538.00805664062, -46.318809509277, 63.073616027832)
		},
		{
			pos = Vector3(-555.80859375, -74.167015075684, 63.831176757812)
		},
		{
			pos = Vector3(-519.34710693359, -101.53608703613, 63.329612731934)
		},
		{
			pos = Vector3(-502.27667236328, -123.52854919434, 66.617904663086)
		}
	 
	}
	 
	addEvent('createRandomMarker', true)
	addEventHandler('createRandomMarker', root, function()
		randomMarker()
	end)
	 
	function randomMarker()
		local random_pos = math.random(1, #randomJobPositions)
		if random_pos then
			local markerPos = randomJobPositions[random_pos].pos - Vector3(0, 0, 1.2)
			local aJob_marker = createMarker(markerPos, 'cylinder', 1.0, 255, 12, 88)
			setElementData(aJob_marker, 'ajob->marker', true)
			setElementData(aJob_marker, 'ajob->markerID', getElementData(localPlayer, 'acc.ID'))
			print("Közmunka Marker: "..tostring(markerPos))
			local aJob_blip = createBlip(markerPos.x, markerPos.y, markerPos.z)
			setElementData(aJob_blip, "blipIcon", "cp")
			setElementData(aJob_blip, "blipTooltipText", "Közmunka")
			setElementData(aJob_blip, "blipColor", tocolor(183, 0, 255))
			setElementData(aJob_blip, "blipFarShow", true)
			setElementData(aJob_blip, 'ajob->blip', true)
			setElementData(aJob_blip, 'ajob->blipID', getElementData(localPlayer, 'acc.ID'))
		end
	end
	
	addEventHandler('onClientRender', root, function()
		if getElementData(localPlayer, 'adminjob>player') and getElementData(localPlayer, 'adminjob>playertime') > 0 then
			dxDrawText('Hátralévő közmunkáid száma:' .. getElementData(localPlayer, 'adminjob>playertime'), sx / 2 - 350 / 2, sy - 180,  sx / 2 - 350 / 2 + 350, sy - 180 + 35, tocolor(0, 0, 0), 1.8, 'sans', 'center', 'center')
			dxDrawText('Hátralévő közmunkáid száma:' .. getElementData(localPlayer, 'adminjob>playertime'), sx / 2 - 350 / 2, sy - 180,  sx / 2 - 350 / 2 + 350, sy - 180 + 35, tocolor(255, 255, 255), 1.75, 'sans', 'center', 'center')
		end
	end)
	
	-- addEventHandler('onClientPlayerDamage', root, function()
	-- 	if getElementData(localPlayer, 'adminjob>playertime') > 0 and getElementData(localPlayer, 'adminjob>player') then
	-- 		--cancelEvent()
	-- 	end
	-- end)
	
	addEvent('destroyTargetMarkers', true)
	addEventHandler('destroyTargetMarkers', root, function()
		for k, v in pairs(getElementsByType('marker')) do
			if getElementData(v, 'ajob->marker') and getElementData(v, 'ajob->markerID') == getElementData(localPlayer, 'acc.ID') then
				destroyElement(v)
			end
		end
		for k, v in pairs(getElementsByType('blip')) do
			if getElementData(v, 'ajob->blip') and getElementData(v, 'ajob->blipID') == getElementData(localPlayer, 'acc.ID') then
				destroyElement(v)
			end
		end
	end)
	
function getPlayerAdminNick(playerSource)
	if isElement(playerSource) then
		return getElementData(playerSource, "acc.adminNick") or "Admin"
	end
end