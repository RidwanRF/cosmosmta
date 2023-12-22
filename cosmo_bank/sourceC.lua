pcall(loadstring(base64Decode(exports.cosmo_core:getInterfaceElements())));addEventHandler("onCoreStarted",root,function(functions) for k,v in ipairs(functions) do _G[v]=nil;end;collectgarbage();pcall(loadstring(base64Decode(exports.cosmo_core:getInterfaceElements())));end)

local sx, sy = guiGetScreenSize()

local panelWidth = 400
local panelHeight = 225

local panelPosX = sx / 2 - panelWidth / 2
local panelPosY = sy / 2 - panelHeight / 2

local isVisible = false

local Roboto = false
local Robotol1 = false
local RobotoL16 = false

local clickTime = getTickCount()

addEventHandler("onClientResourceStart", root, function()
	isVisible = false
end)

function createFont()
	Roboto = dxCreateFont(":cosmo_assets/fonts/BebasNeue-Regular.ttf", 20, false, "cleartype")
	Robotol1 = dxCreateFont(":cosmo_assets/fonts/BebasNeue-Regular.ttf", 16, false, "cleartype")
	RobotoL16 = dxCreateFont(":cosmo_assets/fonts/BebasNeue-Regular.ttf", 20, false, "cleartype")
end

function atmRender()
	if isVisible then
		buttons = {}
		
		-- ** Háttér
		dxDrawRectangle(panelPosX, panelPosY, panelWidth, panelHeight, tocolor(0, 0, 0, 200))
		
		-- ** Cím
		dxDrawRectangle(panelPosX, panelPosY, panelWidth, 30, tocolor(0, 0, 0, 170))
		dxDrawText("#ff9428CosmoMTA#ffffff - BANK", panelPosX + 5, panelPosY + 15, panelPosX + 175, panelPosY + 17.5, tocolor(255, 255, 255, 255), 0.9, Robotol1, "left", "center", false, false, false, true)
		dxDrawText("Bankkártya tulajdonosa: #ff9428"..getPlayerName(localPlayer), panelPosX + 10, panelPosY + 50, panelPosX + 10, panelPosY + 50, tocolor(255, 255, 255, 255), 0.9, Robotol1, "left", "center", false, false, false, true)
		dxDrawText("Egyenleged: #ff9428"..formatNumber(getElementData(localPlayer, "char.bankMoney")) .." $", panelPosX + 10, panelPosY + 130, panelPosX + 10, panelPosY + 50, tocolor(255, 255, 255, 255), 0.9, Robotol1, "left", "center", false, false, false, true)


		drawInput("atmPrice|14", "$", panelPosX + 10 , panelPosY + 125, 380, 30, Robotol1, 1)

		drawButton2("enterPrice", "Befizetés", panelPosX + 10, panelPosY + 175, 180, 30, 255, 148, 40, 1, Roboto, 0.9)
		drawButton2("exitPrice", "Kivétel", panelPosX + 210, panelPosY + 175, 180, 30, 255, 148, 40, 1, Roboto, 0.9)
		drawButton2("closePanel", "Kilépés", panelPosX + 290, panelPosY + 2.5, 100, 22.5, 230, 28, 14, 1, Roboto, 0.8)
	
		local relX, relY = getCursorPosition()
		
		activeButton = false
		
		if relX and relY then
			relX = relX * sx
			relY = relY * sy
			
			for k, v in pairs(buttons) do
				if relX >= v[1] and relX <= v[1] + v[3] and relY >= v[2] and relY <= v[2] + v[4] then
					activeButton = k
					break
				end
			end
		end
	end
end

function packetLossCheck()
	local loss = getNetworkStats()["messagesInSendBuffer"]
	if (loss > 0) then
		moving = false
		cancelEvent("takePlayerBankMoney")
		cancelEvent("givePlayerBankMoney")
	else
		--moving = true
	end
end
setTimer(packetLossCheck, 1000, 0) -- Ezt kell most kuhúzni de akkor majd lehet bugoltatni tesó.

addEventHandler("onClientClick", root, function(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
	if (getPlayerPing(localPlayer) > 220) then return outputChatBox("Itt a buggoltatás nem lehetséges.", 255, 255, 255, true) end
	packetLossCheck()
	if not isVisible then
		if button == "right" and state == "down" and clickedElement then
			if getElementType(clickedElement) == "object" and getElementData(clickedElement, "atm.id") then
				if getElementData(clickedElement, "atm.robbery") then return end
				if exports.cosmo_core:inDistance3D(localPlayer, clickedElement, 2) then
					isVisible = true
					createFont()
					fakeInputs = {}
					selectedInput = false
					addEventHandler("onClientRender", root, atmRender)
					addEventHandler("onClientKey", getRootElement(), inputKey)
					addEventHandler("onClientClick", getRootElement(), onInputClick)
					addEventHandler("onClientCharacter", getRootElement(), inputCharacterHandler)
				end
			end
		end
		if isElement(clickedElement) then
			if getElementType(clickedElement) == "ped" then
				local pedType = getElementData(clickedElement, "ped.type") or 0

				if pedType == 2 then -- banki ügyintéző ped
					if exports.cosmo_core:inDistance3D(localPlayer, clickedElement, 2) then
						isVisible = true
						createFont()
						fakeInputs = {}
						selectedInput = false
						addEventHandler("onClientRender", root, atmRender)
						addEventHandler("onClientKey", getRootElement(), inputKey)
						addEventHandler("onClientClick", getRootElement(), onInputClick)
						addEventHandler("onClientCharacter", getRootElement(), inputCharacterHandler)
					end
				end
			end
		end
	end
end)

function onInputClick(button, state)
	selectedInput = false
	
	if isVisible and activeButton then
		if button == "left" and state == "up" then
			local selected = split(activeButton, ":")
			if selected[1] == "input" then
				selectedInput = false
				selectedInput = selected[2]
			elseif selected[1] == "closePanel" then
				isVisible = false
				createFont()
				fakeInputs = {}
				selectedInput = false
				removeEventHandler("onClientRender", root, atmRender)
				removeEventHandler("onClientKey", getRootElement(), inputKey)
				removeEventHandler("onClientClick", getRootElement(), onInputClick)
				removeEventHandler("onClientCharacter", getRootElement(), inputCharacterHandler)
			elseif selected[1] == "enterPrice" then
                if getTickCount() - clickTime > 7000 then
                    if fakeInputs["atmPrice|14"] == "" then return end
                    
                    local num = tonumber(fakeInputs["atmPrice|14"])

                    if num > 0 then
                        clickTime = getTickCount()

                        

                        triggerServerEvent("cosmo_bankS:givePlayerBankMoney", localPlayer, localPlayer, num)
                    else
                        exports.cosmo_hud:showAlert("error", "Az összegnek nagyobbnak kell", "lennie, mint 0")				
                    end
                end
			elseif selected[1] == "exitPrice" then
                if getTickCount() - clickTime > 7000 then
                    if fakeInputs["atmPrice|14"] == "" then return end
                    
                    local num = tonumber(fakeInputs["atmPrice|14"])

                    if num > 0 then
						clickTime = getTickCount()

						

                        triggerServerEvent("cosmo_bankS:takePlayerBankMoney", localPlayer, localPlayer, num)
                    else
                        exports.cosmo_hud:showAlert("error", "Az összegnek nagyobbnak kell", "lennie, mint 0")				
                    end
                end
			end
		end
	end
end

function inputKey(key, state)
	if isVisible then
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