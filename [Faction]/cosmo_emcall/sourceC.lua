local font = dxCreateFont(":cosmo_assets/fonts/BebasNeue-Regular.ttf", 12)

function startEmergencyCall()
	if not showEm then
		showEm = true
		addEventHandler("onClientRender", root, renderEmergencyPanel)
	else
		showEm = false
		removeEventHandler("onClientRender", root, renderEmergencyPanel)
	end
end
addEvent("startEmergencyCall", true)
addEventHandler("startEmergencyCall", root, startEmergencyCall)



function renderEmergencyPanel()
	if showEm then
		local monitorSize = {guiGetScreenSize()}
		local panelSize = {200, 325}
		local panelX, panelY = monitorSize[1]/2-panelSize[1]/2, monitorSize[2]/2-panelSize[2]/2
		local buttons = {{"Rendőrség"}, {"Mentőszolgálat"}, {"Szerelőtársaság"}, {"Taxitársaság"}, {"Sheriffség"}}

		

		dxDrawRectangle(panelX, panelY, panelSize[1], panelSize[2], tocolor(0, 0, 0, 180))
		dxDrawRectangle(panelX, panelY, panelSize[1], 25, tocolor(0, 0, 0, 230))
		dxDrawText("#ffffffCosmoMTA - #ff9428Segítséghívás", panelX+200/2, panelY+12.5, panelX+200/2, panelY+12.5, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)

		

		for i, v in ipairs(buttons) do
			if isInSlot(panelX+25, panelY-30+(i*60), 150, 40) then
				dxDrawRectangle(panelX+25, panelY-30+(i*60), 150, 40, tocolor(255, 148, 40, 230))
			else
				dxDrawRectangle(panelX+25, panelY-30+(i*60), 150, 40, tocolor(0, 0, 0, 230))
			end
			dxDrawText(v[1], panelX+100, panelY+20-30+(i*60), panelX+100, panelY+20-30+(i*60), tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
		end		
	end
end	



function clickEmergencyPanel(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
	if button == "left" and state == "down" and showEm then

		local monitorSize = {guiGetScreenSize()}
		local panelSize = {200, 325}
		local panelX, panelY = monitorSize[1]/2-panelSize[1]/2, monitorSize[2]/2-panelSize[2]/2
		local buttons = {{"Rendőrség"}, {"Mentőszolgálat"}, {"Szerelőtársaság"}, {"Taxitársaság"}, {"Sheriffség"}}

		for i, v in ipairs(buttons) do
			if dobozbaVan(panelX+25, panelY-30+(i*60), 150, 40, absoluteX, absoluteY) then
				if v[1] == "Rendőrség" then
					triggerServerEvent("emergencyCalling", localPlayer, localPlayer, 1)
				elseif v[1] == "Mentőszolgálat" then
					triggerServerEvent("emergencyCalling", localPlayer, localPlayer, 8)
				elseif v[1] == "Szerelőtársaság" then
					triggerServerEvent("emergencyCalling", localPlayer, localPlayer, 28)
				elseif v[1] == "Taxitársaság" then
					triggerServerEvent("emergencyCalling", localPlayer, localPlayer, 10)
				elseif v[1] == "Sheriffség" then
					triggerServerEvent("emergencyCalling", localPlayer, localPlayer, 9)
				end
				startEmergencyCall(2)
			end
		end
	end
end
addEventHandler ( "onClientClick", getRootElement(), clickEmergencyPanel )



local pdMarkers = {}
local msMarkers = {}
local mhMarkers = {}
local taxMarkers = {}
local sfMarkers = {}
local pdBlips = {}
local msBlips = {}
local mhBlips = {}
local taxBlips = {}
local sfBlips = {}



function createEmergencyMarker(player, id, tipus, tplayer, x, y, z)
	if isElement(player) then
		if tipus == 1 then

			pdMarkers[id] = createMarker( x , y , z, "checkpoint", 4, 0, 0, 255, 255 )
			pdBlips[id] = createBlip( x , y , z, cb )

			setElementData(pdBlips[id], "blipIcon", "cp", false)
			setElementData(pdBlips[id], "blipTooltipText", "Segélyhívás", false)
			setElementData(pdBlips[id], "blipColor", tocolor(255, 148, 40), false)

			setElementData(pdMarkers[id], "call:player", tplayer)
			setElementData(pdMarkers[id], "call:id", id)
			setElementData(pdMarkers[id], "call:type", 1)
			setElementData(pdMarkers[id], "call:accepted", player)

		elseif tipus == 2 then

			msMarkers[id] = createMarker( x , y , z, "checkpoint", 4, 0, 0, 255, 255 )
			msBlips[id] = createBlip( x , y , z, cb )

			setElementData(msMarkers[id], "call:player", tplayer)
			setElementData(msMarkers[id], "call:id", id)
			setElementData(msMarkers[id], "call:type", 2)
			setElementData(msMarkers[id], "call:accepted", player)

		elseif tipus == 3 then

			mhMarkers[id] = createMarker( x , y , z, "checkpoint", 4, 0, 0, 255, 255 )
			mhBlips[id] = createBlip( x , y , z, cb )

			setElementData(mhBlips[id], "blipIcon", "cp", false)
			setElementData(mhBlips[id], "blipTooltipText", "Segélyhívás", false)
			setElementData(mhBlips[id], "blipColor", tocolor(255, 148, 40), false)

			setElementData(mhMarkers[id], "call:player", tplayer)
			setElementData(mhMarkers[id], "call:id", id)
			setElementData(mhMarkers[id], "call:type", 3)
			setElementData(mhMarkers[id], "call:accepted", player)

		elseif tipus == 4 then

			taxMarkers[id] = createMarker( x , y , z, "checkpoint", 4, 0, 0, 255, 255 )
			taxBlips[id] = createBlip( x , y , z, cb )

			setElementData(taxBlips[id], "blipIcon", "cp", false)
			setElementData(taxBlips[id], "blipTooltipText", "Segélyhívás", false)
			setElementData(taxBlips[id], "blipColor", tocolor(255, 148, 40), false)

			setElementData(taxMarkers[id], "call:player", tplayer)
			setElementData(taxMarkers[id], "call:id", id)
			setElementData(taxMarkers[id], "call:type", 4)
			setElementData(taxMarkers[id], "call:accepted", player)

		elseif tipus == 5 then
			sfMarkers[id] = createMarker( x , y , z, "checkpoint", 4, 0, 0, 255, 255 )
			sfBlips[id] = createBlip( x , y , z, cb )

			setElementData(sfMarkers[id], "call:player", tplayer)
			setElementData(sfMarkers[id], "call:id", id)
			setElementData(sfMarkers[id], "call:type", 5)
			setElementData(sfMarkers[id], "call:accepted", player)
		end
	end
end
addEvent("createEmergencyMarker", true)
addEventHandler("createEmergencyMarker", root, createEmergencyMarker)

function emergencyMarker( hitPlayer, matchingDimension )
	if pdMarkers[getElementData(source, "call:id")] and getElementData(source, "call:type") == 1 and getElementData(source, "call:accepted") == hitPlayer then		

		local acceptID = getElementData(source, "call:id")
		local tplayer = getElementData(source, "call:player")
		
		if (acceptID) then
			exports.cosmo_hud:showInfobox("success", "Megérkeztél a(z) " .. acceptID .. " számú hívásra.")
			setElementData(tplayer, "call:pd", false)
			destroyElement(pdBlips[acceptID])
			destroyElement(pdMarkers[acceptID])
		end
	elseif mhMarkers[getElementData(source, "call:id")] and getElementData(source, "call:type") == 3 and getElementData(source, "call:accepted") == hitPlayer then		

		local acceptID = getElementData(source, "call:id")
		local tplayer = getElementData(source, "call:player")
		
		if (acceptID) then
			exports.cosmo_hud:showInfobox("success", "Megérkeztél a(z) " .. acceptID .. " számú hívásra.")
			setElementData(tplayer, "call:mh", false)
			destroyElement(mhBlips[acceptID])
			destroyElement(mhMarkers[acceptID])
	elseif taxMarkers[getElementData(source, "call:id")] and getElementData(source, "call:type") == 4 and getElementData(source, "call:accepted") == hitPlayer then		

		local acceptID = getElementData(source, "call:id")
		local tplayer = getElementData(source, "call:player")
		
		if (acceptID) then
			exports.cosmo_hud:showInfobox("success", "Megérkeztél a(z) " .. acceptID .. " számú hívásra.")
			setElementData(tplayer, "call:tax", false)
			destroyElement(taxBlips[acceptID])
			destroyElement(taxMarkers[acceptID])
			end
		end
	end
end	
addEventHandler( "onClientMarkerHit", getRootElement(), emergencyMarker )
----------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------

function sendCallMessage(service, message, r, g, b, colorCoded)
    for k, v in ipairs(getElementsByType("player")) do
        if exports.cosmo_groups:isPlayerHavePermission(v, "cuff") then
            outputChatBox(message, v, r, g, b, colorCoded)                    
        end
    end
end

function sendGroupMessage(groupId, msg)
	for k, v in ipairs(getElementsByType("player")) do
		if exports.cosmo_groups:isPlayerInGroup(v, tonumber(factionid)) then
			outputChatBox("#F9BF3B[" .. factionNames[groupId] .. "]#ffffff " .. msg, v, 255, 255, 255, true)
		end
	end
end

function isInSlot(xS,yS,wS,hS)
	if(isCursorShowing()) then
		XY = {guiGetScreenSize()}
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*XY[1], cursorY*XY[2]
		if(dobozbaVan(xS,yS,wS,hS, cursorX, cursorY)) then
			return true
		else
			return false
		end
	end	
end





function dobozbaVan(dX, dY, dSZ, dM, eX, eY)
	if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
		return true
	else
		return false
	end
end