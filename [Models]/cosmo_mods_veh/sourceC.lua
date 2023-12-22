local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = 1

function respc(x)
	return math.ceil(x * responsiveMultipler)
end

local myMods = {}

function spairs(t, order)
	local keys = {}

	for k in pairs(t) do
		keys[#keys + 1] = k
	end

	if order then
		table.sort(keys,
			function (a, b)
				return order(t, a, b)
			end
		)
	else
		table.sort(keys)
	end

	local i = 0
	return function ()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

addEventHandler("onClientResourceStart", getRootElement(),
	function (res)
		if source == getResourceRootElement() then
			responsiveMultipler = exports.cosmo_hud:getResponsiveMultipler()
		else
			local cosmo_hud = getResourceFromName("cosmo_hud")
			if cosmo_hud and getResourceState(cosmo_hud) == "running" then
				responsiveMultipler = exports.cosmo_hud:getResponsiveMultipler()
			end
		end

		if source == getResourceRootElement() then
            if fileExists("newcosmosave.json") then
                local theFile = fileOpen("newcosmosave.json")
                local fileData = fileRead(theFile, fileGetSize(theFile))
                fileClose(theFile)
                local readableData = fromJSON(fileData)
                iprint(#readableData, #availableMods)
                if #readableData ~= #availableMods then
                    for k, v in spairs(availableMods, function (t, a, b) return utf8.lower(t[b][3]) > utf8.lower(t[a][3]) end) do
                        table.insert(v, true)
                        table.insert(myMods, v)
                    end
                    outputChatBox("INFO: A jármű modok között változás történt! A beállítások visszaálltak az alaphelyzetbe.")

                    loadVehicleModels(false)
                    return
                end
                myMods = readableData
                
                loadVehicleModels(true)
            else
                for k, v in spairs(availableMods, function (t, a, b) return utf8.lower(t[b][3]) > utf8.lower(t[a][3]) end) do
                    table.insert(v, true)
                    table.insert(myMods, v)
                end

                loadVehicleModels(true)
            end
        end
	end
)


local panelFont = false
local colorSwitches = {}
local lastColorSwitches = {}
local startColorSwitch = {}
local lastColorConcat = {}

local activeButton = false
local buttons = {}
local modPanelScrollAmount = 0

function togglePanel(state)
	if state then
		addEventHandler("onClientClick", root, onClick)
		addEventHandler("onClientRender", root, onRender)
		addEventHandler("onClientKey", root, onKey)
		panelFont = dxCreateFont("Roboto.ttf", respc(19), false, "antialiased")
	else
		removeEventHandler("onClientClick", root, onClick)
		removeEventHandler("onClientRender", root, onRender)
		removeEventHandler("onClientKey", root, onKey)

		if isElement(panelFont) then
			destroyElement(panelFont)
			panelFont = false
		end
	end

	panelState = state
end

local panelW, panelH = respc(600), respc(450)
local panelX, panelY = (screenX - panelW) / 2, (screenY - panelH) / 2

local dataHeight = panelH - respc(30)
local maxVehicles = 13
local columnWidth = panelW / 3
local logoS = respc(22)

function onRender()
	dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(11, 11, 11, 190))
	dxDrawRectangle(panelX, panelY, panelW, respc(30), tocolor(0, 0, 0, 225))
	dxDrawImage(panelX + respc(4), panelY + respc(4), logoS, logoS, "files/logo.png", 0, 0, 0, tocolor(255, 255, 255))
	dxDrawText("#ff9428Cosmo#ffffffMTA - Jármű panel", panelX + respc(8) + logoS, panelY + respc(4), panelX + panelW, panelY + panelH, -1, 0.7, panelFont, "left", "top", false, false, false, true)

	dxDrawText("X", panelX + respc(4), panelY + respc(4), panelX + panelW - respc(4), panelY + panelH, activeButton == "close" and tocolor(255, 100, 100) or -1, 0.7, panelFont, "right", "top")
	buttons["close"] = {panelX + panelW - respc(15), panelY + respc(4), respc(10), respc(17)}

	local rowHeight = dataHeight / maxVehicles

	for i = 1, maxVehicles do
		local startY = panelY + respc(30)

		if i % 2 == 0 then
			dxDrawRectangle(panelX, startY + ((i - 1) * rowHeight), panelW, rowHeight, tocolor(10, 10, 10, 140))
		end
	end

	for i = 1, (maxVehicles - 2) do
		local startY = panelY + respc(30)

		if i == 1 then
			dxDrawText("Jármű neve", panelX + respc(4), startY, panelX + columnWidth, startY + rowHeight, -1, 0.6, panelFont, "left", "center")
			dxDrawText("Eredeti modell", panelX + respc(4) + columnWidth, startY, panelX + (columnWidth * 2), startY + rowHeight, -1, 0.6, panelFont, "left", "center")
			dxDrawText("Állapot", panelX + respc(4) + (columnWidth * 2), startY, panelX + (columnWidth * 3), startY + rowHeight, -1, 0.6, panelFont, "left", "center")
		end

		if i == 11 then
			drawButton("turnOffAll", "Összes kikapcsolása", panelX + respc(4) + (columnWidth * 2) - respc(5), startY + ((i + 1) * rowHeight) + respc(5), (columnWidth - respc(10)), rowHeight - respc(10), {255, 148, 40}, false, panelFont, true, 0.6)
			drawButton("turnOnAll", "Összes bekapcsolása", panelX + respc(4), startY + ((i + 1) * rowHeight) + respc(5), (columnWidth - respc(10)), rowHeight - respc(10), {255, 148, 40}, false, panelFont, true, 0.6)
		end

		local data = myMods[i + modPanelScrollAmount]

		if data then
			local modelId, modelPath, modelRealName, turnable, isOn = data[1], "files/" .. data[2], data[3], data[4], data[5]

			dxDrawText(modelRealName, panelX + respc(4), startY + (i * rowHeight), panelX + columnWidth, startY + rowHeight + (i * rowHeight), -1, 0.6, panelFont, "left", "center", true)
			dxDrawText(_getVehicleNameFromModel(modelId), panelX + respc(4) + columnWidth, startY + (i * rowHeight), panelX + (columnWidth * 2), startY + rowHeight + (i * rowHeight), -1, 0.6, panelFont, "left", "center")
			
			if turnable then
				drawButton("changeState:" .. i + modPanelScrollAmount, isOn and "Kikapcsolás" or "Bekapcsolás", panelX + respc(4) + (columnWidth * 2) - respc(5), startY + (i * rowHeight) + respc(5), (columnWidth - respc(10)), rowHeight - respc(10), {255, 148, 40}, false, panelFont, true, 0.6)
			end
		end
	end

	activeButton = false

	if isCursorShowing() then
		local cursorX, cursorY = getCursorPosition()

		cursorX = cursorX * screenX
		cursorY = cursorY * screenY

		for k, v in pairs(buttons) do
			if cursorX >= v[1] and cursorX <= v[1] + v[3] and cursorY >= v[2] and cursorY <= v[2] + v[4] then
				activeButton = k
				break
			end
		end
	end
end

local oldTick = 0

function onClick(button, state)
	if button == "left" and state == "down" then
		if activeButton then
			local buttonDetails = split(activeButton, ":")

			if oldTick + 3000 <= getTickCount() then
				oldTick = getTickCount()

				if buttonDetails[1] == "changeState" then
					local data = myMods[tonumber(buttonDetails[2])]
					local modelId, modelPath, modelRealName, turnable, isOn = data[1], "files/" .. data[2], data[3], data[4], data[5]
					
					if fileExists(modelPath .. ".txd") and fileExists(modelPath .. ".dff") then
						if isOn then
							engineRestoreModel(modelId)

							myMods[tonumber(buttonDetails[2])][5] = false
						else
							local theTXD = engineLoadTXD(modelPath .. ".txd")
							engineImportTXD(theTXD, modelId)

							local theDFF = engineLoadDFF(modelPath .. ".dff")
							engineReplaceModel(theDFF, modelId)

							myMods[tonumber(buttonDetails[2])][5] = true
						end
					end
				end

				if buttonDetails[1] == "turnOffAll" then
					for k, v in pairs(myMods) do
						local modelId, modelPath, modelRealName, turnable, isOn = v[1], "files/" .. v[2], v[3], v[4], v[5]

						engineRestoreModel(modelId)

						myMods[k][5] = false
					end
				end

				if buttonDetails[1] == "turnOnAll" then
					for k, v in pairs(myMods) do
						local modelId, modelPath, modelRealName, turnable, isOn = v[1], "files/" .. v[2], v[3], v[4], v[5]

						if fileExists(modelPath .. ".txd") and fileExists(modelPath .. ".dff") then
							local theTXD = engineLoadTXD(modelPath .. ".txd")
							engineImportTXD(theTXD, modelId)

							local theDFF = engineLoadDFF(modelPath .. ".dff")
							engineReplaceModel(theDFF, modelId)

							myMods[k][5] = true
						end
					end
				end
			end

			if buttonDetails[1] == "close" then
				togglePanel(false)
			end
		end
	end
end

function onKey(button, state)
	if button == "mouse_wheel_up" and state then
		if modPanelScrollAmount > 0 then
			modPanelScrollAmount = modPanelScrollAmount - 1
		end
	end

	if button == "mouse_wheel_down" and state then
		if modPanelScrollAmount < #myMods - (maxVehicles - 2) then
			modPanelScrollAmount = modPanelScrollAmount + 1
		end
	end
end

function showThePanel()
	if getElementData(localPlayer, "loggedIn") then
		togglePanel(not panelState)
	end
end
addCommandHandler("mods", showThePanel)
addCommandHandler("modpanel", showThePanel)
addCommandHandler("jarmuvek", showThePanel)
addCommandHandler("jarmumodok", showThePanel)
addCommandHandler("modok", showThePanel)
addCommandHandler("modolasok", showThePanel)

function drawButton(key, label, x, y, w, h, activeColor, postGui, theFont, rgbaoff, labelScale)
	local buttonColor
	if activeButton == key then
		buttonColor = {processColorSwitchEffect(key, {activeColor[1], activeColor[2], activeColor[3], 175})}
	else
		buttonColor = {processColorSwitchEffect(key, {25, 25, 25, 130})}
	end

	local alphaDifference = 175 - buttonColor[4]

	labelFont = theFont
	postGui = postGui or false
	labelScale = labelScale or 0.85
	rgbaoff = true
	
	if rgbaoff then
		dxDrawRectangle(x, y, w, h, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 175 - alphaDifference), postGui)
		dxDrawInnerBorder(2, x, y, w, h, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 125 + alphaDifference), postGui)
		dxDrawText(label, x, y, x + w, y + h, tocolor(255, 255, 255, 230), labelScale, labelFont, "center", "center", false, false, postGui, true)
	else
		dxDrawRectangle(x, y, w, h, rgba(buttonColor[1], buttonColor[2], buttonColor[3], 175 - alphaDifference), postGui)
		dxDrawInnerBorder(2, x, y, w, h, rgba(buttonColor[1], buttonColor[2], buttonColor[3], 125 + alphaDifference), postGui)
		dxDrawText(label, x, y, x + w, y + h, rgba(255, 255, 255, 230), labelScale, labelFont, "center", "center", false, false, postGui, true)
	end

	buttons[key] = {x, y, w, h}
end

function dxDrawInnerBorder(thickness, x, y, w, h, color, postGUI)
	thickness = thickness or 1
	dxDrawRectangle(x, y, w, thickness, color, postGUI)
	dxDrawRectangle(x, y + h - thickness, w, thickness, color, postGUI)
	dxDrawRectangle(x, y, thickness, h, color, postGUI)
	dxDrawRectangle(x + w - thickness, y, thickness, h, color, postGUI)
end

function processColorSwitchEffect(key, color, duration, type)
	if not colorSwitches[key] then
		if not color[4] then
			color[4] = 255
		end

		colorSwitches[key] = color
		lastColorSwitches[key] = color

		lastColorConcat[key] = table.concat(color)
	end

	duration = duration or 3000
	type = type or "Linear"

	if lastColorConcat[key] ~= table.concat(color) then
		lastColorConcat[key] = table.concat(color)
		lastColorSwitches[key] = color
		startColorSwitch[key] = getTickCount()
	end

	if startColorSwitch[key] then
		local progress = (getTickCount() - startColorSwitch[key]) / duration

		local r, g, b = interpolateBetween(
				colorSwitches[key][1], colorSwitches[key][2], colorSwitches[key][3],
				color[1], color[2], color[3],
				progress, type
		)

		local a = interpolateBetween(colorSwitches[key][4], 0, 0, color[4], 0, 0, progress, type)

		colorSwitches[key][1] = r
		colorSwitches[key][2] = g
		colorSwitches[key][3] = b
		colorSwitches[key][4] = a

		if progress >= 1 then
			startColorSwitch[key] = false
		end
	end

	return colorSwitches[key][1], colorSwitches[key][2], colorSwitches[key][3], colorSwitches[key][4]
end

function loadVehicleModels(customSave)
	if customSave then
		for k, v in pairs(myMods) do
			local modelId, modelPath, turnable, isOn = v[1], "files/" .. v[2], v[4], v[5]

			if modelId ~= 547 and modelId ~= 405 and modelId ~= 426 and modelId ~= 466 and modelId ~= 480 then
				if fileExists(modelPath .. ".txd") and fileExists(modelPath .. ".dff") then
					if turnable then
						if isOn then
							local theTXD = engineLoadTXD(modelPath .. ".txd")
							engineImportTXD(theTXD, modelId)

							local theDFF = engineLoadDFF(modelPath .. ".dff")
							engineReplaceModel(theDFF, modelId)
						end
					else
						local theTXD = engineLoadTXD(modelPath .. ".txd")
						engineImportTXD(theTXD, modelId)

						local theDFF = engineLoadDFF(modelPath .. ".dff")
						engineReplaceModel(theDFF, modelId)
					end
				end
			end
		end
	else
		for k, v in pairs(myMods) do
			local modelId, modelPath, turnable = v[1], "files/" .. v[2], v[4]
			
			if modelId ~= 547 and modelId ~= 405 and modelId ~= 426 and modelId ~= 466 and modelId ~= 480 then
				if modelId and modelPath then
					if fileExists(modelPath .. ".txd") and fileExists(modelPath .. ".dff") then
						engineImportTXD(engineLoadTXD(modelPath .. ".txd"), modelId)
						
						engineReplaceModel(engineLoadDFF(modelPath .. ".dff"), modelId)
					end
				end
			end
		end
	end
end

addEventHandler("onClientResourceStop", resourceRoot,
	function (res)
		if type(myMods) == "table" then
			if fileExists("newcosmosave.json") then
				fileDelete("newcosmosave.json")
			end
				
			local theFile = fileCreate("newcosmosave.json")
			fileWrite(theFile, toJSON(myMods))
			fileClose(theFile)
		end
	end
)