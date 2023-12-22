local showed = false
local factionNames = {
	[1]="Rendőrség",
	[28]="Szerelőtelep",
	--[10]="Taxitársaság",
}

function callEmergency(thePlayer)
	if getElementData(thePlayer, "loggedIn") then
		if not showed then
			triggerClientEvent(thePlayer, "startEmergencyCall", thePlayer)
			showed = true
		else
			triggerClientEvent(thePlayer, "startEmergencyCall", thePlayer)
			showed = false
		end
	end
end
addCommandHandler("call", callEmergency, false, false)



local pdCall = {}
local msCall = {}
local mhCall = {}
local taxCall = {}
local sfCall = {}

local pdCount = 0
local msCount = 0
local mhCount = 0
local taxCount = 0
local sfCount = 0

function leszed(player)
	setElementData(player, "call:pd", false)
	setElementData(player, "call:mh", false)
	setElementData(player, "call:tax", false)
end
addCommandHandler("fasz", leszed)

function emergencyCalling(player, faction, service)
	if isElement(player) then
		if faction == 1 then
			if getElementData(player, "call:pd") then 
				outputChatBox("#dc143c[Hiba]:#ffffff Már folyamatban van egy hívásod.", player, 255, 255, 255, true)
			return
		end

			pdCount = pdCount + 1
			pdCall[pdCount] = player

			outputChatBox("#1E8BC3[Segítséghívás]:#ffffff Sikeresen értesítetted a rendőröket. ", player, 255, 255, 255, true)
			setElementData(player, "call:pd", pdCount)
		--if exports.cosmo_groups:isPlayerHavePermission(player, "cuff") then
			--outputChatBox("Sűrgős hívás érkezett! Elfogadáshoz: #0094ff/pdaccept " .. pdCount .. "#ffffff (( " .. getPlayerName(pdCall[pdCount]):gsub("_"," ") .. " ))", root, 255, 255, 255, true)	
			sendCallMessage(service, "Sűrgős hívás érkezett! Elfogadáshoz: #0094ff/pdaccept " .. pdCount .. "#ffffff (( " .. getPlayerName(pdCall[pdCount]):gsub("_"," ") .. " ))", 255, 255, 255, true)
		--end

			local x, y, z = getElementPosition(player)

			setElementData(player, "call:pdposx", x)
			setElementData(player, "call:pdposy", y)
			setElementData(player, "call:pdposz", z)
		elseif faction == 28 then
			if getElementData(player, "call:mh") then 
				outputChatBox("#dc143c[Hiba]:#ffffff Már folyamatban van egy hívásod.", player, 255, 255, 255, true)
			return
		end

			mhCount = mhCount + 1
			mhCall[mhCount] = player

			outputChatBox("#1E8BC3[Segítséghívás]:#ffffff Sikeresen értesítetted a szerelőket. ", player, 255, 255, 255, true)
			setElementData(player, "call:mh", mhCount)
		--if exports.cosmo_groups:isPlayerHavePermission(player, "cuff") then
			--outputChatBox("Sűrgős hívás érkezett! Elfogadáshoz: #0094ff/pdaccept " .. pdCount .. "#ffffff (( " .. getPlayerName(pdCall[pdCount]):gsub("_"," ") .. " ))", root, 255, 255, 255, true)	
			sendCallMessage(service, "Sűrgős hívás érkezett! Elfogadáshoz: #0094ff/mhaccept " .. mhCount .. "#ffffff (( " .. getPlayerName(mhCall[mhCount]):gsub("_"," ") .. " ))", 255, 255, 255, true)
		--end

			local x, y, z = getElementPosition(player)

			setElementData(player, "call:mhposx", x)
			setElementData(player, "call:mhposy", y)
			setElementData(player, "call:mhposz", z)
		elseif faction == 10 then
			if getElementData(player, "call:tax") then 
				outputChatBox("#dc143c[Hiba]:#ffffff Már folyamatban van egy hívásod.", player, 255, 255, 255, true)
			return
		end

			taxCount = taxCount + 1
			taxCall[taxCount] = player

			outputChatBox("#1E8BC3[Segítséghívás]:#ffffff Sikeresen értesítetted a szerelőket. ", player, 255, 255, 255, true)
			setElementData(player, "call:tax", taxCount)
		--if exports.cosmo_groups:isPlayerHavePermission(player, "cuff") then
			--outputChatBox("Sűrgős hívás érkezett! Elfogadáshoz: #0094ff/pdaccept " .. pdCount .. "#ffffff (( " .. getPlayerName(pdCall[pdCount]):gsub("_"," ") .. " ))", root, 255, 255, 255, true)	
			sendCallMessage(service, "Sűrgős hívás érkezett! Elfogadáshoz: #0094ff/taxaccept " .. taxCount .. "#ffffff (( " .. getPlayerName(taxCall[taxCount]):gsub("_"," ") .. " ))", 255, 255, 255, true)
		--end

			local x, y, z = getElementPosition(player)

			setElementData(player, "call:taxposx", x)
			setElementData(player, "call:taxposy", y)
			setElementData(player, "call:taxposz", z)
		end
	end
end
addEvent("emergencyCalling", true)
addEventHandler("emergencyCalling", root, emergencyCalling)

function acceptPd(thePlayer, commandName, acceptID)
		if exports.cosmo_groups:isPlayerHavePermission(thePlayer, "cuff") then
		if (acceptID) then
			local acceptID = tonumber(acceptID)
			if pdCall[acceptID] then

				outputChatBox("Elfogadtad a(z) " .. acceptID .. " számú hívást.", thePlayer, 255, 255, 255, true)
				outputChatBox("A rendőrök elfogadták a hívásodat.", pdCall[acceptID], 255, 255, 255, true)
				sendCallMessage(service, getPlayerName(thePlayer):gsub("_"," ") .. " elfogadta a(z) #0094ff" .. acceptID .. "#ffffff hívást.", 255, 255, 255, true)

				local x, y, z = getElementData(pdCall[acceptID], "call:pdposx"), getElementData(pdCall[acceptID], "call:pdposy"), getElementData(pdCall[acceptID], "call:pdposz")
				triggerClientEvent(thePlayer, "createEmergencyMarker", thePlayer, thePlayer, acceptID, 1, pdCall[acceptID], x, y, z)
				pdCall[acceptID] = nil
			else
				outputChatBox("#dc143c[Hiba]:#ffffff Nincs ilyen hívás, vagy a hívást már fogadták.", thePlayer, 255, 255, 255, true)
			end
		end
	end
end
addCommandHandler("pdaccept", acceptPd, false, false)

function acceptMh(thePlayer, commandName, acceptID)
		if exports.cosmo_groups:isPlayerHavePermission(thePlayer, "repair") then
		if (acceptID) then
			local acceptID = tonumber(acceptID)
			if mhCall[acceptID] then

				outputChatBox("Elfogadtad a(z) " .. acceptID .. " számú hívást.", thePlayer, 255, 255, 255, true)
				outputChatBox("A szerelők elfogadták a hívásodat.", mhCall[acceptID], 255, 255, 255, true)
				sendCallMessage(service, getPlayerName(thePlayer):gsub("_"," ") .. " elfogadta a(z) #0094ff" .. acceptID .. "#ffffff hívást.", 255, 255, 255, true)

				local x, y, z = getElementData(mhCall[acceptID], "call:mhposx"), getElementData(mhCall[acceptID], "call:mhposy"), getElementData(mhCall[acceptID], "call:mhposz")
				triggerClientEvent(thePlayer, "createEmergencyMarker", thePlayer, thePlayer, acceptID, 3, mhCall[acceptID], x, y, z)
				mhCall[acceptID] = nil
			else
				outputChatBox("#dc143c[Hiba]:#ffffff Nincs ilyen hívás, vagy a hívást már fogadták.", thePlayer, 255, 255, 255, true)
			end
		end
	end
end
addCommandHandler("mhaccept", acceptMh, false, false)

function acceptTaxi(thePlayer, commandName, acceptID)
		if exports.cosmo_groups:isPlayerHavePermission(thePlayer, "taxi") then
		if (acceptID) then
			local acceptID = tonumber(acceptID)
			if taxCall[acceptID] then

				outputChatBox("Elfogadtad a(z) " .. acceptID .. " számú hívást.", thePlayer, 255, 255, 255, true)
				outputChatBox("A szerelők elfogadták a hívásodat.", taxCall[acceptID], 255, 255, 255, true)
				sendCallMessage(service, getPlayerName(thePlayer):gsub("_"," ") .. " elfogadta a(z) #0094ff" .. acceptID .. "#ffffff hívást.", 255, 255, 255, true)

				local x, y, z = getElementData(taxCall[acceptID], "call:taxposx"), getElementData(taxCall[acceptID], "call:taxposy"), getElementData(taxCall[acceptID], "call:taxposz")
				triggerClientEvent(thePlayer, "createEmergencyMarker", thePlayer, thePlayer, acceptID, 3, taxCall[acceptID], x, y, z)
				taxCall[acceptID] = nil
			else
				outputChatBox("#dc143c[Hiba]:#ffffff Nincs ilyen hívás, vagy a hívást már fogadták.", thePlayer, 255, 255, 255, true)
			end
		end
	end
end
addCommandHandler("taxiaccept", acceptTaxi, false, false)

--------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------

function sendCallMessage(service, message, r, g, b, colorCoded)
    for k, v in ipairs(getElementsByType("player")) do
        if exports.cosmo_groups:isPlayerHavePermission(v, "cuff") or exports.cosmo_groups:isPlayerHavePermission(v, "repair") or exports.cosmo_groups:isPlayerHavePermission(v, "taxi") then
            outputChatBox(message, v, r, g, b, colorCoded)                    
        end
    end
end

function sendGroupMessage(service1, message1, r1, g1, b1, colorCoded1)
    for k, v in ipairs(getElementsByType("player")) do
        if exports.cosmo_groups:isPlayerHavePermission(v, "repair") then
            outputChatBox(message, v, r, g, b, colorCoded)      
		end
	end
end