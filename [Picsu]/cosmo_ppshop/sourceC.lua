pcall(loadstring(base64Decode(exports.cosmo_core:getInterfaceElements())));addEventHandler("onCoreStarted",root,function(functions) for k,v in ipairs(functions) do _G[v]=nil;end;collectgarbage();pcall(loadstring(base64Decode(exports.cosmo_core:getInterfaceElements())));end)

local sX, sY = guiGetScreenSize()

local panelWidth = 1000
local panelHeight = 480

local panelPosX = sX / 2 - panelWidth / 2
local panelPosY = sY / 2 - panelHeight / 2

local cPanelWidth = 300
local cPanelHeight = 230

local cPanelPosX = sX / 2 - cPanelWidth / 2
local cPanelPosY = sY / 2 - cPanelHeight / 2

local panelState = false
local countPanel = false
local RobotoFont = false
local RobotoLighter = false

local currentOffset = 0
local currentPanel = "weaponTab"
local maxVisibiledItem = 10



addEventHandler("onClientResourceStart", root, function()
	panelState = false
	RobotoFont = dxCreateFont(":cosmo_assets/fonts/Roboto-Regular.ttf", 16, false, "antialiased")
	RobotoLighter = dxCreateFont(":cosmo_assets/fonts/Roboto-Regular.ttf", 12, false, "antialiased")
end)

bindKey("F7", "down", function()
	if not panelState and not countPanel then
		panelState = true
		addEventHandler("onClientRender", getRootElement(), renderPpPanel)
		addEventHandler("onClientKey", getRootElement(), onShopKey)
		addEventHandler("onClientClick", getRootElement(), onShopClick)
		addEventHandler("onClientCharacter", getRootElement(), shopCharacterHandler)
		
		selectedBuy = {}
		fakeInputs = {}
		selectedInput = false
	else
		panelState = false
		countPanel = false
		removeEventHandler("onClientRender", getRootElement(), renderPpPanel)
		removeEventHandler("onClientKey", getRootElement(), onShopKey)
		removeEventHandler("onClientClick", getRootElement(), onShopClick)
		removeEventHandler("onClientCharacter", getRootElement(), shopCharacterHandler)
	
		selectedBuy = {}
		fakeInputs = {}
		selectedInput = false
	end
end)

function panelButtonClose()
	panelState = false
	removeEventHandler("onClientRender", getRootElement(), renderPpPanel)
	removeEventHandler("onClientKey", getRootElement(), onShopKey)
	removeEventHandler("onClientClick", getRootElement(), onShopClick)
	removeEventHandler("onClientCharacter", getRootElement(), shopCharacterHandler)
	
	selectedBuy = {}
	fakeInputs = {}
	selectedInput = false
end

function renderPpPanel()
	if panelState then
		buttons = {}
		
		-- ** Háttér
		dxDrawRectangle(panelPosX, panelPosY, panelWidth, panelHeight, tocolor(25,25,25,200))
		
		-- ** Cím
		dxDrawRectangle(panelPosX, panelPosY, panelWidth, 30, tocolor(25,25,25,200))
		dxDrawText("#ff9428Cosmo #ffffff- Prémium Shop ", panelPosX + 400, panelPosY+20, panelPosY+20, panelPosY + 10, tocolor(255, 255, 255, 255), 1, RobotoLighter, "left", "center", false, false, false, true)
		dxDrawText(convertNumber(getElementData(localPlayer, "char.PP")).." #ff9428PrémiumPont", panelPosX+5, panelPosY-970+panelWidth, panelPosY+panelWidth, panelPosY, tocolor(255, 255, 255, 255), 1, RobotoLighter, "left", "center", false, false, false, true)

		-- ** Kilépés
		local closeTextWidth = dxGetTextWidth("X", 1, RobotoLighter)
		local closeTextPosX = panelPosX + panelWidth - closeTextWidth - 5
		local closeColor = tocolor(255, 255, 255)
		
		if activeButton == "close" then
			closeColor = tocolor(215, 89, 89)
			
			if getKeyState("mouse1") then
				panelButtonClose()
				return
			end
		end
		
		local x = panelPosX + 20
		
		-- ** Tabok
		for i, v in pairs(tabs) do
			local s = {}
			s = split(v, ';')
			drawButton2(s[2], s[1], x, panelPosY+40, 184, 30, 255, 153, 51,1, RobotoLighter, 1)
			
			x = (x + 184) + 10
		end
		
		dxDrawText("X", closeTextPosX, panelPosY, 0, panelPosY + 30, closeColor, 1, RobotoLighter, "left", "center")
		buttons.close = {closeTextPosX, panelPosY, closeTextWidth, 30}
		
		-- ** Content
		local x1 = panelPosX + 5
		local y1 = panelPosY + 30
		
		local sy1 = (panelHeight - 30 - 50) / maxVisibiledItem
		
		for i = 1, maxVisibiledItem do
			local colorOfRow = tocolor(0, 0, 0, 125)
			
			if i%2 == 0 then
				colorOfRow = tocolor(0, 0, 0,75)
			end
			dxDrawRectangle(x1, y1 + 45, panelWidth - 20, sy1, colorOfRow)

			local data = tabItems[currentPanel][i + currentOffset]
			
			if data then
				dxDrawImage(x1+5, y1+50, 30, 30, ":cosmo_inventory/files/items/"..data.itemID..".png", 0, 0, 0, tocolor(255, 255, 255, 255))
				--dxDrawText(data.name, x1+45, y1 + 45, 0, y1+sy1+ 45, tocolor(255,255,255), 0.65, RobotoFont, "left", "center", false, false, false, true)
				dxDrawText(exports.cosmo_inventory:getItemName(data.itemID).."  #ff9428(("..exports.cosmo_inventory:getItemDescription(data.itemID).."))", x1+45, y1 + 45, 0, y1+sy1+ 45, tocolor(255,255,255), 0.65, RobotoFont, "left", "center", false, false, false, true)
				dxDrawText(convertNumber(data.price).." PP", x1, y1 + 45, x1 + panelWidth - 115, y1 + sy1 + 45, tocolor(255, 255, 255, 255), 0.6, RobotoFont, "right", "center")
				drawButton2("buyPPItems:"..currentPanel..":"..i+currentOffset, "Vásárlás", x1 + panelWidth - 105, y1 + 53, 75, 25, 255, 153, 51, 1, RobotoLighter, 0.8)
			end

			
			y1 = y1 + sy1
		end
		
		-- ** Scrollbar
		if #tabItems[currentPanel] > maxVisibiledItem then
			local listSize = sy1 * maxVisibiledItem
			
			dxDrawRectangle(panelPosX + panelWidth - 10, panelPosY + 75, 5, listSize, tocolor(0, 0, 0, 100))
			dxDrawRectangle(panelPosX + panelWidth - 10, panelPosY + 75 + (listSize / #tabItems[currentPanel]) * math.min(currentOffset, #tabItems[currentPanel] - 10), 5, (listSize / #tabItems[currentPanel]) * 10, tocolor(255, 153, 51))
		end
	
		local relX, relY = getCursorPosition()
		
		activeButton = false
		
		if relX and relY then
			relX = relX * sX
			relY = relY * sY
			
			for k, v in pairs(buttons) do
				if relX >= v[1] and relX <= v[1] + v[3] and relY >= v[2] and relY <= v[2] + v[4] then
					activeButton = k
					break
				end
			end
		end
	end
	
	if countPanel then
		buttons = {}
		-- ** Háttér
		dxDrawRectangle(cPanelPosX, cPanelPosY, cPanelWidth, cPanelHeight, tocolor(40, 40, 40, 255))
		
		-- ** Cím
		dxDrawRectangle(cPanelPosX, cPanelPosY, cPanelWidth, 27, tocolor(15, 15, 15, 255))
		dxDrawRectangle(cPanelPosX, cPanelPosY+27, cPanelWidth, 1, tocolor(200, 200, 200, 255))
		dxDrawText("Prémium item vásárlás", cPanelPosX + 150, cPanelPosY + 14, cPanelPosX + 150, cPanelPosY + 14, tocolor(255, 255, 255, 255), 1, RobotoLighter, "center", "center")
		dxDrawText("Nyomj #ffffffEsc#ffffff-et a visszalépéshez.", cPanelPosX + 150, cPanelPosY + cPanelWidth - 40, cPanelPosX + 150, cPanelPosY + cPanelWidth - 40, tocolor(255, 255, 255, 255), 1, RobotoLighter, "center", "center", false, false, false, true)
	
		-- ** Content
	
		local darab = tonumber(fakeInputs["buyCount|4"]) or 1
		dxDrawText("Kérlek add meg a mennyiséget ", cPanelPosX + 150, cPanelPosY + 50, cPanelPosX + 150, cPanelPosY + 50, tocolor(255, 255, 255, 255), 1, RobotoLighter, "center", "center")
		dxDrawText(selectedBuy[1].name.."\n#ffffff"..convertNumber(selectedBuy[1].price*darab).." PrémiumPont", cPanelPosX + 150, cPanelPosY + 90, cPanelPosX + 150, cPanelPosY + 90, tocolor(255, 255, 255, 255), 1, RobotoLighter, "center", "center", false, false, false, true)
		drawInput("buyCount|4", "db", cPanelPosX + (cPanelWidth/2) - (60/2), cPanelPosY + 130, 60, 30, RobotoLighter, 1)
	
		drawButton2("finishBuy", "Vásárlás", cPanelPosX + (cPanelWidth/2) - (184/2), cPanelPosY+180, 184, 30, 255, 153, 51,1, RobotoLighter, 1)
	
		local relX, relY = getCursorPosition()
		
		activeButton = false
		
		if relX and relY then
			relX = relX * sX
			relY = relY * sY
			
			for k, v in pairs(buttons) do
				if relX >= v[1] and relX <= v[1] + v[3] and relY >= v[2] and relY <= v[2] + v[4] then
					activeButton = k
					break
				end
			end
		end
	end
end

function onShopClick(button, state)
	selectedInput = false

	if button == "left" and state == "down" and activeButton then
		local selected = split(activeButton, ":")
		
		if selected[1] == "weaponTab" then
			currentPanel = "weaponTab"
			currentOffset = 0
		elseif selected[1] == "skinWeaponTab" then
			currentPanel = "skinWeaponTab"
			currentOffset = 0
		elseif selected[1] == "specialTab" then
			currentPanel = "specialTab"
			currentOffset = 0
		elseif selected[1] == "bookTab" then
			currentPanel = "bookTab"
			currentOffset = 0
		elseif selected[1] == "ammoTab" then
			currentPanel = "ammoTab"
			currentOffset = 0
		elseif selected[1] == "buyPPItems" then
			local tableName = selected[2]
			local tableID = tonumber(selected[3])
			
			table.insert(selectedBuy, tabItems[tableName][tableID])
			fakeInputs["buyCount|4"] = "1"
			panelState = false
			countPanel = true
		end
	end
	
	if countPanel and activeButton then
		if button == "left" and state == "up" then
			local selected = split(activeButton, ":")
			
			if selected[1] == "input" then
				selectedInput = false
				selectedInput = selected[2]
				fakeInputs[selectedInput] = "1"
			elseif selected[1] == "finishBuy" then
				if fakeInputs["buyCount|4"] ~= "" then
					local count = tonumber(fakeInputs["buyCount|4"])
					local itemID = tonumber(selectedBuy[1].itemID)
					local itemName = selectedBuy[1].name
					
					if count ~= 0 then
						if count <= selectedBuy[1].maxStack then
							local playerPP = getElementData(localPlayer, "char.PP")
							if tonumber(playerPP) < (tonumber(fakeInputs["buyCount|4"])*selectedBuy[1].price) then
								exports.cosmo_hud:showInfobox("error", "Nincs elegendő Prémium Pontod.")
								return
							end
						
							triggerServerEvent("ppShop >> itemBuy", localPlayer, localPlayer, itemID, count, itemName, tonumber(fakeInputs["buyCount|4"])*selectedBuy[1].price)
							selectedBuy = {}
							fakeInputs = {}
							selectedInput = false
							
							countPanel = false
							panelState = true
						else
							exports.cosmo_hud:showInfobox("error", "Ebből az itemből maximum "..selectedBuy[1].maxStack.." db-ot vehetsz.")
						end
					else
						exports.cosmo_hud:showInfobox("error", "Hibás mennyiség.")
					end
				end
			end
		end
		cancelEvent()
	end
end	

function onShopKey(key, state)
	if panelState then
		if #tabItems[currentPanel] > maxVisibiledItem then
			if key == "mouse_wheel_down" and currentOffset < #tabItems[currentPanel] - maxVisibiledItem then
				currentOffset = currentOffset + 1
			elseif key == "mouse_wheel_up" and currentOffset > 0 then
				currentOffset = currentOffset - 1
			end			
		end
	end
	
	if countPanel then
		if selectedInput and state and key == "backspace" then
			if utf8.len(fakeInputs[selectedInput]) >= 1 then
				fakeInputs[selectedInput] = utf8.sub(fakeInputs[selectedInput], 1, -2)
			elseif utf8.len(fakeInputs[selectedInput]) < 1 then
				fakeInputs[selectedInput] = "1"
			end
		end
		
		if state and key == "escape" then
			selectedBuy = {}
			fakeInputs = {}
			selectedInput = false
			
			countPanel = false
			panelState = true
		end	
		
	cancelEvent()
	end
end

function shopCharacterHandler(character)
	if selectedInput then
		local selected = split(selectedInput, "|")

		if utf8.len(fakeInputs[selectedInput]) < tonumber(selected[2]) then
			if tonumber(character) then
				fakeInputs[selectedInput] = fakeInputs[selectedInput] .. character
			end
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