if fileExists("c_carshop.lua") then fileDelete("c_carshop.lua"); end

local renderVehicles = {}

function isCarshopVehicle(veh)
	local cid = tonumber(veh:getData("veh:CarshopID")) or 0
	if cid > 0 then
		return true
	else
		return false
	end
end

function isCarshopOpen(id)
	return true
end

local vehicleAdo = 1.00
addEventHandler("onClientElementStreamIn", root,function ()
	if source:getType() == "vehicle" then
		if source:getDimension() == localPlayer:getDimension() and source:getInterior() == localPlayer:getInterior() then
			if isCarshopVehicle(source) then
				renderVehicles[source] = source
			end
		end
	end
end)

local loadedPickups = {}
local createdPickup = {}

addEvent("vehEnt_ReceivePickups", true)
addEventHandler("vehEnt_ReceivePickups", getRootElement(), function(pickups)
	--print("got")
	-- megkapva a blipek, pickupok
	for k,v in pairs(pickups) do
		--outputConsole(inspect(pickups[k].pickupsData[1]))
		for key, value in pairs(pickups[k].pickupsData) do
			if not createdPickup[value.id] then
				local pickup = createPickup(value.position[1], value.position[2], value.position[3], 3, 1274)
				pickup:setData("name", value.name, false)
				pickup:setData("owner", value.owner, false)
				pickup:setData("parent", value.parent, false)
				pickup:setData("id", value.id, false)
				value["parent"]:setID(value.setID)
				createdPickup[value.id] = true
				loadedPickups[pickup] = {data = value}
			end
		end
	end
end)

local clickDestroy = false

addCommandHandler("toggleDestroy", function()
	clickDestroy = not clickDestroy
	--outputChatBox(tostring(clickDestroy))
end)

removeWorldModel(17543, 100,  2313.6550292969, -1357.7006835938, 24.03003692627)
function addLabelOnClick ( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
	if clickDestroy then
		outputChatBox("aa")
       if(clickedElement)then
	        local modelID = getElementModel(clickedElement)
	        local oX, oY, oZ = getElementPosition(clickDestroy)
	        removeWorldModel(modelID, 10, oX, oY, oZ)
	    end
	end
end
addEventHandler ( "onClientClick", root, addLabelOnClick )

function reloadMarkers()
	local myID = tonumber(localPlayer:getData("char.ID")) or 0
	for k,v in ipairs(getElementsByType("marker",resourceRoot)) do
		local markerOwnerID = tonumber(getElementData(v, "owner")) or 0
        local id = tonumber(v:getData("carshopID")) or 0
		--if not exports.ex_core:isSuperAdmin(localPlayer) then
		if not (getElementData(localPlayer, "acc.adminLevel") >= 9) then
			if not exports.ex_ent:isInEnterprise(localPlayer, carshopIDToEnterPriseID[id]) then
				setMarkerColor(v, 255, 0, 0, 0)
			else
				setMarkerColor(v, 255, 255, 255, 20)
			end
		else
			setMarkerColor(v, 255, 255, 255, 20)
		end
	end
end
addEvent("carshop:reloadMarkers", true)
addEventHandler("carshop:reloadMarkers", root, reloadMarkers)

addEventHandler("onClientElementDataChange", root, function(data)
	if getElementType(source) == "vehicle" then
		if data == "veh:CarshopID" then
			if source:getType() == "vehicle" then
				local carshop_id = tonumber(source:getData(data)) or 0
				if isElementStreamedIn(source) then
					if carshop_id > 0 then
						renderVehicles[source] = source
					else
						renderVehicles[source] = nil
					end
				end
			end
		end
	elseif source == localPlayer then
		if data == "loggedIn" or data == "user:adminlevel" then
			reloadMarkers()
		end
	end
end)

addEventHandler("onClientElementStreamOut", root,function ()
	if source:getType() == "vehicle" and renderVehicles[source] then
		if isCarshopVehicle(source) then
			renderVehicles[source] = nil
		end
	end
end)

addEventHandler("onClientElementDestroy", root,function ()
	if getElementType(source) == "vehicle" and renderVehicles[source] then
		if isCarshopVehicle(source) then
			renderVehicles[source] = nil
		end
	end
end)

addEventHandler("onClientResourceStart", getRootElement(), function()
	for k,v in ipairs(getElementsByType("vehicle",root,true)) do
        if isCarshopVehicle(v) then
            renderVehicles[v] = v
        end
	end

	if getElementData(localPlayer, "loggedIn") then
		reloadMarkers()
		setTimer(function()
			triggerServerEvent("vehEnt_RequestPickups", localPlayer)
			--print("küld")
			-- ez a küldés a markerekfelé
		end, 1000, 1)
	end
	
end)

function getVehicleEngineInfo(veh)
	local health = veh:getHealth()
	local colorCode = ""
	if health < 600 then
		colorCode = "#FF2F00"
	else
		colorCode = "#0DFF00"
	end
	return colorCode..math.floor(health/10).."%"
end

addEventHandler("onClientVehicleDamage", root, function(attacker)
	if attacker == localPlayer then
		if isElement(source) and renderVehicles[source] then
			cancelEvent()
		end
	end
end)

--local FONT2 = exports.sarp_assets:loadFont("Roboto-Regular.ttf", 20, false, "antialiased")
local FONT2 = dxCreateFont("files/Roboto.ttf", 20, false, "antialiased")
addEventHandler("onClientRender", root, function()
	local cx, cy, cz = getCameraMatrix()
	--FONT2 = exports.ex_core:getFont("montserrat.ttf", 20)
	for _, element in pairs(renderVehicles) do
		if isElementOnScreen(element) then
			if isCarshopVehicle(element) then
				local px, py, pz = getElementPosition(element)
				local distance = getDistanceBetweenPoints3D(px, py, pz, cx, cy, cz)
				if distance <= 15 then
					if isLineOfSightClear(cx, cy, cz, px, py, pz, true, false, false, true, false, false, true, localPlayer) then
						local sx, sy = getScreenFromWorldPosition(px, py, pz)
						if sx and sy then
							local realname = exports.sarp_mods_veh:getVehicleNameFromModel(getElementModel(element))
							if not realname then
								realname = element:getName()
							end
							local price = tonumber(math.floor(element:getData("veh:Price")*vehicleAdo)) or 0
							local text = "#D9D9D9"..realname.."\nMotor állapota: "..getVehicleEngineInfo(element).."\n#D9D9D9Ár: "..formatMoney(price) .."$"
							dxDrawText(tostring(text), sx, sy, sx, sy, tocolor( 0, 0, 0, 255 ), 0.4, FONT2, "center", "center", false, false, false, true )
							dxDrawText(tostring(text), sx, sy, sx, sy, tocolor( 255, 255, 255, 255 ), 0.4, FONT2, "center", "center", false, false, false, true )
						end
					end
				end
			end
		end
	end
end)

local triggered = false
addEventHandler("onClientMarkerHit", resourceRoot, function(player)
	if not triggered then
		if player == localPlayer and source:getData("available") then
			local myID = tonumber(localPlayer:getData("dbid")) or 0
            local id = tonumber(source:getData("carshopID")) or 0
            local pos = tonumber(source:getData("carshopPos")) or 0
			if exports.ex_ent:isInEnterprise(localPlayer, carshopIDToEnterPriseID[id]) or (getElementData(localPlayer, "acc.adminLevel") >= 9) then
				local veh = getPedOccupiedVehicle(player)
				if veh then
                    local vehID = tonumber(veh:getData("vehicle.dbID")) or 0
					local vehCarshop = tonumber(veh:getData("veh:CarshopID")) or 0
					local entID = tonumber(veh:getData("veh:Enterprise")) or 0
					if vehCarshop == 0 then
						local vehOwner = tonumber(veh:getData("veh:Owner")) or 0
				        if id > 0 and pos > 0 and (vehOwner == myID or carshopIDToEnterPriseID[id] == entID) then
				        	--print(carshopIDToEnterPriseID[id])
                            if exports.ex_ent:hasPermission(localPlayer, carshopIDToEnterPriseID[id], "Jármű berakása a kereskedésbe") then
                                local money = countVehicleRealPrice(veh)
                                triggerServerEvent("addVehicleToCarshop", localPlayer, veh, id, pos, localPlayer, money, true)
                                triggered = true
                            else
                                exports.sarp_hud:showAlert("error","Nincs jogosultságod, hogy járművet rakj a kereskedésbe!")   
                            end
                        end
					end
				end
			end
		end
	end
end)

addEvent("acceptedTrigger", true)
addEventHandler("acceptedTrigger", root, function(veh, price, id)
	triggered = false
	showCarshopUI(1, veh, price, id)
	
	local vehID = tonumber(veh:getData("vehicle.dbID"))
	for k, v in ipairs(getElementsByType("player")) do
		if getElementData(v,"loggedIn") then
			--local state, slot, _, id = exports.ex_inventory:hasItem(v, 29, vehID)
			--print(vehID .. " VEHICLEIDMO ")
			--local itemTable = exports.sarp_inventory:hasItemWithData(2, "data1", tostring(vehID))

			--print(#itemTable .. " db -> ")
			--outputConsole(inspect(itemTable))

			-- if state then
			-- 	-- deleteItem(element, dbid, itemID, slot, update)
			--print("ELVESZ GECI")
			triggerServerEvent("server->deleteKey", localPlayer, 2, "data1", vehID);
			-- end
		end
	end
end)

addEventHandler("onClientPlayerVehicleEnter", localPlayer, function(veh, seat)
	if source == localPlayer then
		if seat == 0 then
			local source = getPedOccupiedVehicle(source)
			local vehCarshop = tonumber(source:getData("veh:CarshopID")) or 0
			if vehCarshop > 0 then
				if isCarshopOpen(vehCarshop) then
					local pos = tonumber(source:getData("veh:CarshopPos")) or 0
					if pos > 0 then
						local marker = getElementByID("carshopMarker:"..vehCarshop..":"..pos)
						if isElement(marker) then
							local myID = tonumber(localPlayer:getData("char.ID")) or 0
							local markerOwnerID = tonumber(marker:getData("owner")) or 0
                            local id = tonumber(marker:getData("carshopID")) or 0
							--[[ if exports.ex_core:isSuperAdmin(localPlayer) then ]]
							if getElementData(localPlayer, "acc.adminLevel") >= 9 then
								local driver = getVehicleOccupant(source)
								if(driver==localPlayer)then
                                    if getElementData(localPlayer, "adminDuty") or false then
									    showCarshopUI(1, source, false, id)
                                    else
                                        showCarshopUI(2, source, false, id) 
                                        --print("nincs admin dutyban")
                                    end
								end
							else
								if exports.ex_ent:isInEnterprise(localPlayer, carshopIDToEnterPriseID[id]) then
								    showCarshopUI(1, source, false, id)
								    --print("benne van a vállalkozásban")
								else
									showCarshopUI(2, source, false, id)
								end
							end
						end
					end
				else
					outputChatBox("[GoodMTA] #FFFFFFEz az autókereskedés jelenleg zárva van!",255,0,0,true)
				end
			end
		end
	end
end)

--local guiFont = guiCreateFont(":ex_core/fonts/roboto.ttf")
--local guiFont2 = guiCreateFont(":ex_core/fonts/roboto.ttf",15)
--local guiFont = exports.sarp_assets:loadFont("Roboto-Regular.ttf", 12, false, "antialiased")
--local guiFont2 = exports.sarp_assets:loadFont("Roboto-Regular.ttf", 15, false, "antialiased")
local guiFont = guiCreateFont(":sarp_assets/fonts/Roboto-Regular.ttf")
local guiFont2 = guiCreateFont(":sarp_assets/fonts/Roboto-Regular.ttf", 15)
local sx,sy = guiGetScreenSize()
function showCarshopUI(type, veh, newprice, carshopID)
	if not isElement(guiCarshop) then
		showCursor(true)
        local vehCarshop = tonumber(veh:getData("veh:CarshopID")) or 0
		local vehiclePrice = tonumber(veh:getData("veh:Price")) or 0
        
		if newprice then
			vehiclePrice = newprice
		end
        
		guiCarshop = guiCreateWindow(sx/2-100,sy/2-130,200,310,"Jármű beállításai", false)
		guiWindowSetMovable(guiCarshop, false)
		guiWindowSetSizable(guiCarshop, false)
		
		if type == 2 then
			label1 = guiCreateLabel(5,25,200,40,"A jármű jelenlegi ára:\n".. formatMoney(math.floor(vehiclePrice*vehicleAdo)) .."$",false,guiCarshop)
		else
			label1 = guiCreateLabel(5,25,200,40,"A jármű jelenlegi ára:\n".. formatMoney(vehiclePrice) .."$",false,guiCarshop)
		end
        
		guiLabelSetHorizontalAlign(label1, "center")
		guiSetFont(label1, guiFont)
		
		button1 = guiCreateButton(5,60,200,40,"Ár módosítása",false,guiCarshop)
		guiSetFont(button1, guiFont)
		if type == 2 then
			guiSetEnabled(button1, false)
		end
		addEventHandler("onClientGUIClick", button1, function()
			if source == button1 then
                if exports.ex_ent:hasPermission(localPlayer, carshopIDToEnterPriseID[carshopID], "Jármű árának a szerkesztése") then
                    guiSetAlpha(button1, 0)
                    editBox1 = guiCreateEdit(5,60,200,40,vehiclePrice,false,guiCarshop)
                    guiSetText(label1, "Mentés:\nDupla kattintás.")
                    addEventHandler("onClientGUIDoubleClick", editBox1, function()
                        if source == editBox1 then
                            local price = tonumber(guiGetText(editBox1)) or 0
                            price = math.abs(price)
                            veh:setData("veh:Price", price)
                            local vehID = tonumber(veh:getData("vehicle.dbID")) or 0
                            guiSetText(label1, "A jármű jelenlegi ára:\n"..formatMoney(price) .."$")
							exports.sarp_hud:showAlert("success", "Az ár sikeresen módosítva!\nA jármű ára mostantól: "..formatMoney(price) .." dollár.")
                            triggerServerEvent("clientQuery", localPlayer, "UPDATE vehicles SET carshop_price = '".. price .."' WHERE vehicleID = '".. vehID .."'")
                            destroyElement(editBox1)
                            guiSetAlpha(button1, 1)
                        end
                    end)
                else
                    --exports.ex_gui:showInfoBox("Nincs jogod, hogy szerkeszd a jármű árát!")    
					exports.sarp_hud:showAlert("error", "Nincs jogod, hogy szerkeszd a jármű árát!")
                end
			end
		end)
			
		button2 = guiCreateButton(5,110,200,40,"Kivétel a kereskedésből",false,guiCarshop)
		guiSetFont(button2, guiFont)
		if type == 2 then
			guiSetEnabled(button2, false)
		end
		addEventHandler("onClientGUIClick", button2, function()
			if source == button2 then
                if exports.ex_ent:hasPermission(localPlayer, carshopIDToEnterPriseID[carshopID], "Jármű kivétele a kereskedésből") then
                    triggerServerEvent("removeVehicleFromCarshop", localPlayer, veh, localPlayer:getData("char.ID"))
                    --exports.ex_gui:showInfoBox("A jármű mostantól nincs a használtautó kereskedésedben!")
					exports.sarp_hud:showAlert("success", "A jármű mostantól nincs a használtautó kereskedésedben!")
                    local vehID = tonumber(veh:getData("vehicle.dbID")) or 0
                    guiCarshop:destroy()
                    showCursor(false)
                else
					exports.sarp_hud:showAlert("error", "Nincs jogod, hogy kivedd a járművet a kereskedésből!")
                    --exports.ex_gui:showInfoBox("Nincs jogod, hogy kivedd a járművet a kereskedésből!")  
                end
			end
		end)
		
		button3 = guiCreateButton(5,160,200,40,"Megvásárol",false,guiCarshop)
		guiSetFont(button3, guiFont)
		if type == 1 then
			guiSetEnabled(button3, false)
		end
		addEventHandler("onClientGUIClick", button3, function()
			if source == button3 then
				local price = tonumber(veh:getData("veh:Price")) or 0
				local priceTo = math.floor(price*vehicleAdo)
				--if not exports.ex_utility:canBuyVehicle(localPlayer) then
				if not ( tonumber(#ProcessPlayerVehicles())+1 <= tonumber(getElementData(localPlayer, "char.vehicleLimit"))) then
					--exports.ex_gui:showInfoBox("Sikertelen jármű vétel! (nincs szabad jármű slot)")
					exports.sarp_hud:showAlert("error", "Sikertelen jármű vétel! (nincs szabad jármű slot)")
				--elseif exports.ex_core:takeMoney(localPlayer, priceTo) then					
				elseif exports.sarp_core:takeMoney(localPlayer, priceTo) then					
					outputChatBox("[GoodMTA]#ffffff Hamarosan megtörténik a szerződés aláírása.", 255, 0, 0, true)
					if not isTimer(_timer) then
						_timer = setTimer(function()
							--if not exports.ex_core:getNetworkState() then return end
							triggerServerEvent("removeVehicleFromCarshop", localPlayer, veh, localPlayer:getData("char.ID"), math.floor(price/vehicleAdo))
							local vehID = tonumber(veh:getData("vehicle.dbID")) or 0
							setElementData(veh, "veh:Enterprise", 0)
							exports.ex_ent:giveEnterpriseMoney(localPlayer, carshopIDToEnterPriseID[carshopID], math.floor(price/vehicleAdo))
							--exports.ex_inventory:giveItem(localPlayer, 29, vehID)
							triggerServerEvent("entCarshopGiveKey", localPlayer, vehID)
							--exports.ex_gui:showInfoBox("Sikeres jármű vásárlás!")
							exports.sarp_hud:showAlert("success", "Sikeres jármű vásárlás!")
							guiCarshop:destroy()
							showCursor(false)
						end, math.random(2000,3500), 1)
					end
				else
					--exports.ex_gui:showInfoBox("Nincs elég pénzed!")
					exports.sarp_hud:showAlert("error", "Nincs elég pénzed!")
				end
			end
		end)
        
        button4 = guiCreateButton(5,210,200,40,"Kivétel saját névre",false,guiCarshop)
		guiSetFont(button4, guiFont)
		if type == 2 then
			guiSetEnabled(button4, false)
		end
		addEventHandler("onClientGUIClick", button4, function()
			if source == button4 then
				if exports.ex_ent:hasPermission(localPlayer, carshopIDToEnterPriseID[carshopID], "Jármű kivétele saját nevére") then
                    --if not exports.ex_utility:canBuyVehicle(localPlayer) then
					--print(type(#ProcessPlayerVehicles()))
					--print(type(getElementData(localPlayer, "char.vehicleLimit")))
					if not ( tonumber(#ProcessPlayerVehicles())+1 <= tonumber(getElementData(localPlayer, "char.vehicleLimit"))) then
                        --exports.ex_gui:showInfoBox("Nincs elég slotod!")   
						exports.sarp_hud:showAlert("error","Nincs elég slotod!")    
                    else
                        local vehID = tonumber(veh:getData("vehicle.dbID")) or 0
                        triggerServerEvent("removeVehicleFromCarshop", localPlayer, veh, localPlayer:getData("char.ID"), 0, true)
                        --exports.ex_inventory:giveItem(localPlayer, 29, vehID)
						triggerServerEvent("entCarshopGiveKey", localPlayer, vehID)
                        guiCarshop:destroy()
					    showCursor(false)
                    end
                else
                    --exports.ex_gui:showInfoBox("Nincs hozzá jogod!")   
					exports.sarp_hud:showAlert("error","Nincs hozzá jogod!")
                end
			end
		end)
		
		button5 = guiCreateButton(5,270,200,40,"Ablak bezárása",false,guiCarshop)
		guiSetFont(button5, guiFont)
		addEventHandler("onClientGUIClick", button5, function()
			if source == button5 then
				guiCarshop:destroy()
				setPedControlState("enter_exit", true)
				setTimer(function()
					setPedControlState("enter_exit", false)
				end, 50, 1)
				showCursor(false)
			end
		end)
	end
end

setElementData(localPlayer, "char.vehicleLimit", 20)

function ProcessPlayerVehicles()
    local playerVehicles = {}
    for k, v in ipairs(getElementsByType("vehicle")) do
        if getElementData(v, "vehicle.dbID") and getElementData(v, "vehicle.owner") == getElementData(localPlayer, "char.ID") then
            table.insert(playerVehicles, v)
        end
    end

    return playerVehicles
end

addEvent("showCarshopPremium", true)
addEventHandler("showCarshopPremium", root, function(cid, actualSlots)
	if not isElement(guiCarshopPremium) then
		triggered = false
		showCursor(true)
		guiCarshopPremium = guiCreateWindow(sx/2-200,sy/2-80,400,160,"Limit", false)
		guiWindowSetMovable(guiCarshopPremium, false)
		guiWindowSetSizable(guiCarshopPremium, false)
		
		label1 = guiCreateLabel(0,25,400,40,"Sajnos elérted a maximum jármű limited. ("..actualSlots..")\nSzeretnéd megnövelni a maximum slotokat 1000 Prémiumpontért?",false,guiCarshopPremium)
		guiLabelSetHorizontalAlign(label1, "center")
		guiSetFont(label1, guiFont)
		
		button1 = guiCreateButton(0,60,400,40,"Igen, bővíteni szeretném a slotokat.",false,guiCarshopPremium)
		guiSetFont(button1, guiFont)
		addEventHandler("onClientGUIClick", button1, function()
			if source == button1 then
				if exports.ex_core:takePP(localPlayer, 1000) then
                    exports.ex_ppstat:insertPPLog(30003)
                    setElementData( localPlayer, "log:premium:1", {"item:"..30003})
					--exports.ex_gui:showInfoBox("Sikeresen megvásároltál +1 slotot az autókereskedésedhez!")
					exports.sarp_hud:showAlert("success","Sikeresen megvásároltál +1 slotot az autókereskedésedhez!")    
					triggerServerEvent("giveCarshopSlot", localPlayer, cid)
				else
					--exports.ex_gui:showInfoBox("Nincs elég prémium pontod!")
					exports.sarp_hud:showAlert("error","Nincs elég prémium pontod!")    
				end
				guiCarshopPremium:destroy()
				showCursor(false)
			end
		end)
		
		button2 = guiCreateButton(0,110,400,40,"Nem, nem szeretném bővíteni a slotokat.",false,guiCarshopPremium)
		guiSetFont(button2, guiFont)
		addEventHandler("onClientGUIClick", button2, function()
			if source == button2 then
				guiCarshopPremium:destroy()
				showCursor(false)
			end
		end)
	end
end)

local actualCarshop = 0
local pickup = nil
local rendered = false
local theTimer
local renderName, renderOpen, isCarshopOwner
local six, siy = 321, 86
local defX, defY = sx/2-six/2, sy-siy-50
local actualY = sy
local rendered = false
local alphaDown = false
local alpha = 0
local carshopPickup
function renderCarshop(owner)
	if isTimer(theTimer) then
		killTimer(theTimer)
	end
	isCarshopOwner = owner
	local parent = getElementData(carshopPickup, "parent")
	renderName = getElementData(parent, "name")
	renderOpen = getElementData(carshopPickup, "name")
	startTick = getTickCount()
	if not rendered then
		addEventHandler("onClientRender", root, renderCarshopName)
	end
	alphaDown = false
	rendered = true
	fromMoveY = actualY
	toMoveY = defY
end

function destroyCarshopRender()
	if isTimer(theTimer) then killTimer(theTimer) end
	fromMoveY = actualY
	toMoveY = sy
	startTick = getTickCount()
	alphaDown = true
	theTimer = setTimer(function()
		rendered = false
		alpha = 0
		removeEventHandler("onClientRender", root, renderCarshopName)
	end, 1000,1)
end

local centerX = 195
--local FONT = exports.ex_core:getFont("roboto.ttf", 20)
--local FONT = exports.sarp_assets:loadFont("Roboto-Regular.ttf", 20, false, "antialiased")
local FONT = dxCreateFont("files/Roboto.ttf", 20, false, "antialiased")
--[[ addEvent("onClientServerCoreRestarted", true)
addEventHandler("onClientServerCoreRestarted", getRootElement(), function()
	FONT = exports.ex_core:getFont("roboto.ttf", 20)
end) ]]
function renderCarshopName()
	progress = (getTickCount() - startTick) / 300
	actualY, y, z = interpolateBetween( 
		fromMoveY, 0, 0,
		toMoveY, 0, 0, 
		progress, "Linear")
		
	if alphaDown then
		alpha = alpha - 10
	else
		alpha = alpha + 10
	end
	if alpha > 255 then
		alpha = 255
	elseif alpha < 0 then
		alpha = 0
	end
		
	dxDrawImage(defX, actualY, six, siy, "files/enterprise.png", 0, 0, 0, tocolor ( 255, 255, 255, alpha ))
	dxDrawText(renderName, defX + centerX, actualY + 5, defX + centerX, actualY + 5, tocolor ( 255, 255, 255, alpha ), 0.5, FONT, "center")
	dxDrawText(renderOpen, defX + centerX, actualY + 30, defX + centerX, actualY + 30, tocolor ( 255, 255, 255, alpha ), 0.4, FONT, "center")
	if isCarshopOwner then
		dxDrawText("A kezeléshez nyomd meg az 'E' gombot.", defX + centerX, actualY + 55, defX + centerX, actualY + 55, tocolor ( 255, 255, 255, alpha ), 0.4, FONT, "center")
	end
end

addEventHandler("onClientPickupHit", root, function(player)
	if player == localPlayer then
		if getElementParent(getElementParent(source)) == getResourceRootElement() then
			if actualCarshop == 0 then
				carshopPickup = source
				local myID = tonumber(localPlayer:getData("char.ID")) or 0
				local ownerID = tonumber(source:getData("owner")) or 0
                local id = tonumber(source:getData("id")) or 0
				if exports.ex_ent:isInEnterprise(localPlayer, carshopIDToEnterPriseID[id]) or (getElementData(localPlayer, "acc.adminLevel") >= 9) then
					actualCarshop = tonumber(source:getData("id")) or 0
					pickup = source
					bindKey("e", "down", handleModifyCarshop)
					renderCarshop(true)
				else
					renderCarshop(false)
				end
			end
		end
		cancelEvent()
	end
end)

addEventHandler("onClientPickupLeave", root, function(player)
	if player == localPlayer then
		if actualCarshop > 0 then
			local myID = tonumber(localPlayer:getData("dbid")) or 0
			local ownerID = tonumber(source:getData("owner")) or 0
            local id = tonumber(source:getData("id")) or 0
			if exports.ex_ent:isInEnterprise(localPlayer, carshopIDToEnterPriseID[id]) or getElementData(localPlayer, "acc.adminLevel") >= 9 then
				actualCarshop = 0
				pickup = nil
				unbindKey("e", "down", handleModifyCarshop)
			end
		end
		if carshopPickup then
			carshopPickup = nil
			destroyCarshopRender()
		end
		cancelEvent()
	end
end)

local renderedCarShopPickups = {};
addEventHandler("onClientElementStreamIn", root, function()
	if isElement(source) and getElementType(source) == "pickup" and getElementParent(getElementParent(source)) == getResourceRootElement() then
		if not renderedCarShopPickups[source] then
			local parent = getElementData(source, "parent")
			renderName = getElementData(parent, "name")
			renderOpen = getElementData(source, "name")
			renderedCarShopPickups[source] = {renderName, renderOpen}
		end
	end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
	for i,v in pairs(getElementsByType("pickup", resourceRoot, true)) do
		if isElementStreamedIn(v) then
			if not renderedCarShopPickups[v] then
				local parent = getElementData(v, "parent")
				renderName = getElementData(parent, "name")
				renderOpen = getElementData(v, "name")
				renderedCarShopPickups[v] = {renderName, renderOpen}
			end
		end
	end
end)

addEventHandler("onClientElementStreamOut", root, function()
	if isElement(source) then
		if renderedCarShopPickups[source] then
			renderedCarShopPickups[source] = nil
		end
	end
end)

function changePickupListener(theKey, oldValue, newValue)
    if (getElementType(source) == "pickup") then
        if renderedCarShopPickups[source] then
			local parent = getElementData(source, "parent")
			renderName = getElementData(parent, "name")
			renderOpen = getElementData(source, "name")
        	renderedCarShopPickups[source] = {renderName, renderOpen}
    	end
	elseif string.find(getElementType(source), "carshop:") then
		for k,v in pairs(renderedCarShopPickups) do
			local pickupParent = getElementData(k, "parent")
			if source == pickupParent then
				if renderedCarShopPickups[k] then
					local parent = getElementData(k, "parent")
					renderName = getElementData(source, "name")
					renderOpen = getElementData(k, "name")
		        	renderedCarShopPickups[k] = {renderName, renderOpen}
    			end
			end
		end
	end
end
addEventHandler("onClientElementDataChange", getRootElement(), changePickupListener)

--local iconFont = exports.sarp_assets:loadFont("Roboto-Regular.ttf", 12, false, "antialiased")
local iconFont = dxCreateFont("files/Roboto.ttf", 12, false, "antialiased")
addEventHandler("onClientRender", root, function()
	local cameraX, cameraY, cameraZ = getCameraMatrix()
	--print("rendergeci")
	for i,v in pairs(renderedCarShopPickups) do
		if getElementDimension(i) == getElementDimension(localPlayer) and getElementInterior(i) == getElementInterior(localPlayer) then
			local markerX, markerY, markerZ = getElementPosition(i)
			markerZ = markerZ + 0.75

			if isLineOfSightClear(cameraX, cameraY, cameraZ, markerX, markerY, markerZ, true, false, false, true, false, false, false, localPlayer) then
				local dist = math.sqrt((cameraX - markerX) ^ 2 + (cameraY - markerY) ^ 2 + (cameraZ - markerZ) ^ 2)

				if dist < 20 then
					local name = tostring(v[1]) .. "\n" .. tostring(v[2])
					local worldX, worldY = getScreenFromWorldPosition(markerX, markerY, markerZ)
					local size = 0.40 + (15 - dist) * 0.05
					local half = dxGetTextWidth(name, size, iconFont) / 2
					local height = dxGetFontHeight(size, iconFont) *2
						
					if worldX and worldY then
						drawBorderedRectangle(worldX - half - 5, worldY - 5, half * 2 + 10, height + 10, tocolor(102, 187, 106, 150), false, tocolor(20, 20, 20, 220), 1)

						dxDrawText(name, worldX + 1, worldY + 1, worldX + 1, worldY + 1, tocolor(0, 0, 0, 40), size, iconFont, "center", "top")
						dxDrawText(name, worldX + 1, worldY - 1, worldX + 1, worldY - 1, tocolor(0, 0, 0, 40), size, iconFont, "center", "top")
						dxDrawText(name, worldX - 1, worldY + 1, worldX - 1, worldY + 1, tocolor(0, 0, 0, 40), size, iconFont, "center", "top")										
						dxDrawText(name, worldX - 1, worldY - 1, worldX - 1, worldY - 1, tocolor(0, 0, 0, 40), size, iconFont, "center", "top")
								
						dxDrawText(name, worldX, worldY, worldX, worldY, tocolor(255, 255, 255, 255), size, iconFont, "center", "top", false, false, false, true)
					end	
				end
			end
		end
	end
end)

function drawBorderedRectangle( x, y, width, height, color, postGUI, bgcolor, bgsize)
	if x and y and width and height then
		local color = color or tocolor(255, 0, 0);
		local postGUI = postGUI or false;
		local bgcolor = bgcolor or tocolor(0, 0, 0, 255);
		local bgsize = bgsize or 1;
		dxDrawRectangle ( x+bgsize, y+bgsize, width-bgsize, height-bgsize, color, postGUI );
		dxDrawLine ( x, y, x+width, y, bgcolor, bgsize, postGUI ); -- Top
		dxDrawLine ( x, y, x, y+height, bgcolor, bgsize, postGUI ); -- Left
		dxDrawLine ( x, y+height, x+width, y+height, bgcolor, bgsize, postGUI ); -- Bottom
		dxDrawLine ( x+width, y, x+width, y+height, bgcolor, bgsize, postGUI ); -- Right
	end
end

function handleModifyCarshop()
	if actualCarshop > 0 then
		if not isElement(guiModifyCarshop) then
			local carshopParent = Element.getAllByType("carshop:"..actualCarshop)[1]
			if isElement(carshopParent) then
				showCursor(true)
				
				guiModifyCarshop = guiCreateWindow(sx/2-200,sy/2-137.5,400,250,"Vállalkozás beállításai",false)
				guiWindowSetMovable(guiModifyCarshop, false)
				guiWindowSetSizable(guiModifyCarshop, false)
				label1 = guiCreateLabel(0,35,400,40,"Nyitvatartási idő:",false,guiModifyCarshop)
				guiLabelSetHorizontalAlign(label1, "center")
				guiSetFont(label1, guiFont)
				
				local balance = tonumber(math.floor(carshopParent:getData("balance"))) or 0
				
				local openHour = tonumber(carshopParent:getData("open_hour")) or 0
				local openMinute = tonumber(carshopParent:getData("open_minute")) or 0
				local closeHour = tonumber(carshopParent:getData("close_hour")) or 0
				local closeMinute = tonumber(carshopParent:getData("close_minute")) or 0
				local enterpriseName = tostring(carshopParent:getData("name")) or "Használtautó kereskedés"
				if openHour < 10 then
					openHour = "0"..openHour
				end
				if openMinute < 10 then
					openMinute = "0"..openMinute
				end
				if closeHour < 10 then
					closeHour = "0"..closeHour
				end
				if closeMinute < 10 then
					closeMinute = "0"..closeMinute
				end
				
				centerDot = guiCreateLabel(0,61,400,40," - ",false,guiModifyCarshop)
				guiLabelSetHorizontalAlign(centerDot, "center")
				guiSetFont(centerDot, guiFont2)
				
				leftDot = guiCreateLabel(-34,60,400,40,":",false,guiModifyCarshop)
				guiLabelSetHorizontalAlign(leftDot, "center")
				guiSetFont(leftDot, guiFont2)
				
				openMinuteLabel = guiCreateLabel(-20,62,400,40,openMinute,false,guiModifyCarshop)
				guiLabelSetHorizontalAlign(openMinuteLabel, "center")
				guiSetFont(openMinuteLabel, guiFont2)
				
				openHourLabel = guiCreateLabel(-47,62,400,40,openHour,false,guiModifyCarshop)
				guiLabelSetHorizontalAlign(openHourLabel, "center")
				guiSetFont(openHourLabel, guiFont2)
				
				rightDot = guiCreateLabel(33,60,400,40,":",false,guiModifyCarshop)
				guiLabelSetHorizontalAlign(rightDot, "center")
				guiSetFont(rightDot, guiFont2)
				
				closeMinuteLabel = guiCreateLabel(47,62,400,40,closeMinute,false,guiModifyCarshop)
				guiLabelSetHorizontalAlign(closeMinuteLabel, "center")
				guiSetFont(closeMinuteLabel, guiFont2)
				
				closeHourLabel = guiCreateLabel(20,62,400,40,closeHour,false,guiModifyCarshop)
				guiLabelSetHorizontalAlign(closeHourLabel, "center")
				guiSetFont(closeHourLabel, guiFont2)

				buttonMinus1 = guiCreateButton(40,55,40,40,"-",false,guiModifyCarshop)
				buttonPlus1 = guiCreateButton(85,55,40,40,"+",false,guiModifyCarshop)
				buttonMinus2 = guiCreateButton(275,55,40,40,"-",false,guiModifyCarshop)
				buttonPlus2 = guiCreateButton(320,55,40,40,"+",false,guiModifyCarshop)
				

				addEventHandler("onClientGUIClick", guiModifyCarshop, function()
					if source == buttonMinus1 then
						local openHour = tonumber(guiGetText(openHourLabel)) or 0
						local openMinute = tonumber(guiGetText(openMinuteLabel)) or 0
						if openHour > 2 or openMinute == 30 then
							if openMinute == 0 then
								openMinute = 30
								openHour = openHour - 1
							elseif openMinute == 30 then
								openMinute = 0
							end
						end
						
						if openHour < 10 then
							openHour = "0"..openHour 
						end
						if openMinute < 10 then
							openMinute = "0"..openMinute 
						end
						
						guiSetText(openHourLabel, openHour)
						guiSetText(openMinuteLabel, openMinute)
					elseif source == buttonPlus1 then
						local openHour = tonumber(guiGetText(openHourLabel)) or 0
						local openMinute = tonumber(guiGetText(openMinuteLabel)) or 0
						
						if openHour < 22 or openMinute == 30 then
							if openMinute == 0 then
								openMinute = 30
							elseif openMinute == 30 then
								openHour = openHour + 1
								openMinute = 0
							end
						end
						
						if openHour < 10 then
							openHour = "0"..openHour 
						end
						if openMinute < 10 then
							openMinute = "0"..openMinute 
						end
						
						guiSetText(openHourLabel, openHour)
						guiSetText(openMinuteLabel, openMinute)
					elseif source == buttonMinus2 then
						local closeHour = tonumber(guiGetText(closeHourLabel)) or 0
						local closeMinute = tonumber(guiGetText(closeMinuteLabel)) or 0
						
						if closeHour > 2 or closeMinute == 30 then
							if closeMinute == 0 then
								closeMinute = 30
								closeHour = closeHour - 1
							elseif closeMinute == 30 then
								closeMinute = 0
							end
						end
						
						if closeHour < 10 then
							closeHour = "0"..closeHour 
						end
						if closeMinute < 10 then
							closeMinute = "0"..closeMinute 
						end
						
						guiSetText(closeHourLabel, closeHour)
						guiSetText(closeMinuteLabel, closeMinute)
					elseif source == buttonPlus2 then
						local closeHour = tonumber(guiGetText(closeHourLabel)) or 0
						local closeMinute = tonumber(guiGetText(closeMinuteLabel)) or 0
						
						if closeHour < 22 or closeMinute == 30 then
							if closeMinute == 0 then
								closeMinute = 30
							elseif closeMinute == 30 then
								closeHour = closeHour + 1
								closeMinute = 0
							end
						end
						
						if closeHour < 10 then
							closeHour = "0"..closeHour 
						end
						if closeMinute < 10 then
							closeMinute = "0"..closeMinute 
						end
						
						guiSetText(closeHourLabel, closeHour)
						guiSetText(closeMinuteLabel, closeMinute)
					end
				end)
				
				label3 = guiCreateLabel(0,110,400,40,"Kereskedés elnevezése:",false,guiModifyCarshop)
				guiLabelSetHorizontalAlign(label3, "center")
				guiSetFont(label3, guiFont)
				
				editName = guiCreateEdit(0,130,400,40,enterpriseName,false,guiModifyCarshop)
				guiSetFont(label3, guiFont)
                
				guiSetInputMode("no_binds_when_editing")

				button1 = guiCreateButton(0,200,400,30,"Mentés / Bezárás",false,guiModifyCarshop)
				guiSetFont(button1, guiFont)
				addEventHandler("onClientGUIClick", button1, function()
					if source == button1 then
						local openHour = tonumber(guiGetText(openHourLabel)) or 0
						local openMinute = tonumber(guiGetText(openMinuteLabel)) or 0
						local closeHour = tonumber(guiGetText(closeHourLabel)) or 0
						local closeMinute = tonumber(guiGetText(closeMinuteLabel)) or 0
						
						local name = tostring(guiGetText(editName)) or ""
						
						if openHour == closeHour and openMinute == closeMinute then
							exports.sarp_hud:showAlert("error", "Miért zárnál be egyből amikor kinyitsz?")
							--exports.ex_gui:showInfoBox("Miért zárnál be egyből amikor kinyitsz?")
							return
						elseif closeHour < openHour then
							--exports.ex_gui:showInfoBox("IDŐUTAZÓ?!")
							exports.sarp_hud:showAlert("error", "IDŐUTAZÓ?!")
							return
						elseif name:len() < 10 then
							--exports.ex_gui:showInfoBox("A vállalkozás neve túl rövid!")
							exports.sarp_hud:showAlert("error", "A vállalkozás neve túl rövid!")
							return
						elseif name:len() > 60 then
							--exports.ex_gui:showInfoBox("A vállalkozás neve túl hosszú!")
							exports.sarp_hud:showAlert("error", "A vállalkozás neve túl hosszú!")
							return
						end
						
						carshopParent:setData("name", name)
						carshopParent:setData("open_hour", openHour)
						carshopParent:setData("open_minute", openMinute)
						carshopParent:setData("close_hour", closeHour)
						carshopParent:setData("close_minute", closeMinute)
						
						local id = tonumber(carshopParent:getData("id")) or 0
						if id > 0 then
							triggerServerEvent("saveCarshopConfig", localPlayer, name, openHour, openMinute, closeHour, closeMinute, id)
						end
						
						if closeMinute < 10 then
							closeMinute = "0"..closeMinute
						end
						if openMinute < 10 then
							openMinute = "0"..openMinute
						end
						if openHour < 10 then
							openHour = "0"..openHour
						end
						if closeHour < 10 then
							closeHour = "0"..closeHour
						end
						
						for k,v in ipairs(Element.getAllByType("pickup", getResourceRootElement(getThisResource()))) do
							--print(tostring(v:getData("parent")) .. " ->>>> " .. tostring(carshopParent))
							if v:getData("parent") == carshopParent then
								v:setData("name", "Nyitvatartás: "..openHour..":"..openMinute.." - "..closeHour..":"..closeMinute.."")
							end
						end
						
						showCursor(false)
						guiModifyCarshop:destroy()
					end
				end)
			end
		end
	end
end

local getPlayerName = function(p)
	local name = exports.ex_core:getAccuratePlayerName(p)
	return name:gsub("_", " ")
end