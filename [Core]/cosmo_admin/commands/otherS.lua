local places = {
	["ls"] = {1484.7469482422, -1740.1397705078, 13.546875, 180},
	["deli"] = {1933.1015625, -1744.0854492188, 13.546875, 180},
	["eszaki"] = {1005.5318603516, -951.64923095703, 42.192859649658, 0},
	["alsohatar"] = {85.606513977051, -1519.0068359375, 4.8448534011841, 180},
	["felsohatar"] = {-54.145683288574, -1386.3479003906, 11.854888916016, 309},
	["ur"] = {572.81579589844, -1432.7233886719, 70336.34375, 0},
	["szerelo"] = {1637.6104736328, -2159.2336425781, 13.5546875, 0},
	["lsgyar"] = {2783.6389160156, -1614.1549072266, 10.921875, 0},
}

addAdminCommand("gotoplace", 1, "Elteleportálás az adott helyre")
addCommandHandler("gotoplace", function(sourcePlayer, commandName, place)
    if havePermission(sourcePlayer, commandName, true) then
        if not place then
            outputUsageText(commandName, "[Hely]", sourcePlayer)
            outputInfoText("Elérhető helyek:", sourcePlayer)

			local availablePlaces = {}

			for k, v in pairs(places) do
				table.insert(availablePlaces, k)
			end

			outputInfoText(table.concat(availablePlaces, ", "), sourcePlayer)
        else

        	if places[place] then
        		local data = places[place]

        		setElementPosition(sourcePlayer, data[1], data[2], data[3])
				setElementDimension(sourcePlayer, 0)
				setElementInterior(sourcePlayer, 0)

				outputInfoText("Elteleportáltál a következő helyre: #658e57" .. place, sourcePlayer)
        	else
        		outputErrorText("A kiválasztott hely nem létezik.", sourcePlayer)
        	end
        end
    end
end)

addAdminCommand("asay", 1, "Admin felhívás a játékosok felé")
addCommandHandler("asay", function(sourcePlayer, commandName, ...)
    if havePermission(sourcePlayer, commandName, true) then
        if not (...) then
            outputUsageText(commandName, "[Üzenet]", sourcePlayer)
        else
            local text = table.concat({...}, " ")

            local adminNick = getPlayerAdminNick(sourcePlayer)
            local adminlevel = getElementData(sourcePlayer, "acc.adminLevel") or 0
			local adminrank = exports.cosmo_core:getPlayerAdminTitle(sourcePlayer)
			local rankcolor = exports.cosmo_core:getAdminLevelColor(adminlevel)

			outputInfoText(rankcolor .. adminrank .. " " .. adminNick .. " #fffffffelhívása: #d75959" .. text, root)
			exports.cosmo_dclog:sendDiscordMessage("**"..adminNick .. "** admin felhívása: **" .. text .."**", "adminlog")
			exports.cosmo_logs:toLog("adminaction", adminNick .. " admin felhívása: " .. text)
			triggerClientEvent ( sourcePlayer, "PlayAsaySound", sourcePlayer, "Hello World!" )

        end
    end
end)

addAdminCommand("vanish", 1, "Láthatatlanná/Láthatóvá válás")
addCommandHandler("vanish", function(sourcePlayer, commandName)
    if havePermission(sourcePlayer, commandName, true) then
        local invisible = getElementData(sourcePlayer, "invisible")

        if invisible then
            if getElementData(sourcePlayer, "adminDuty") then setElementAlpha(sourcePlayer, 255) else setElementAlpha(sourcePlayer, 255) end

            triggerClientEvent(sourcePlayer, "playClientSound", sourcePlayer, ":cosmo_assets/audio/admin/restore.ogg")
        else
            setElementAlpha(sourcePlayer, 0)

            triggerClientEvent(sourcePlayer, "playClientSound", sourcePlayer, ":cosmo_assets/audio/admin/minimize.ogg")
        end

        setElementData(sourcePlayer, "invisible", not invisible)
    end
end)

function outputChange()
    if (getElementType(source) == "player") then -- check if the element is a player
		helperLevel = getElementData (source, "acc.helperLevel")
		if helperLevel == 1 or helperLevel == 2 then
			setElementData(source, "helperDuty", true)
		end
    end
end
addEventHandler("onElementDataChange", root, outputChange)

--addAdminCommand("asduty", -1, "Adminsegéd szolgálat be -és kikapcsolása")
--addCommandHandler("asduty", function(sourcePlayer, commandName)
	--if havePermission(sourcePlayer, commandName, false, 1) then
		--local currentState = getElementData(sourcePlayer, "helperDuty")

		--if not currentState then
			--setElementData(sourcePlayer, "helperDuty", true)

			--outputInfoText("Adminsegéd szolgálatba léptél.", sourcePlayer)
		--else
			--setElementData(sourcePlayer, "helperDuty", false)

			--outputInfoText("Kiléptél az adminsegéd szolgálatból.", sourcePlayer)
		--end
	--end
--end)

addAdminCommand("adminduty", 1, "Adminszolgálat be -és kikapcsolása")
addCommandHandler("adminduty", function(sourcePlayer, commandName)
	if havePermission(sourcePlayer, commandName) then
		local currentState = getElementData(sourcePlayer, "adminDuty")

		if not currentState then
			setElementData(sourcePlayer, "adminDuty", true)
			setElementData(sourcePlayer, "visibleName", getPlayerAdminNick(sourcePlayer))
			setElementData(sourcePlayer, "invulnerable", true)
			exports.cosmo_inventory:hideAttachedItems(sourcePlayer, "off")
			exports.cosmo_hud:showInfobox(root, "aduty", getPlayerAdminNick(sourcePlayer) .. " adminszolgálatba lépett.")

			local adutyTimer = setTimer(function() 
				if isElement(sourcePlayer) and getElementData(sourcePlayer, "adminDuty") == true then
				end
			end, 60000, 0)
			setElementData(sourcePlayer, "admin.atimer", adutyTimer)

		else
			setElementData(sourcePlayer, "adminDuty", false)
			setElementData(sourcePlayer, "visibleName", getPlayerCharacterName(sourcePlayer))
			setElementData(sourcePlayer, "invulnerable", false)
			exports.cosmo_inventory:hideAttachedItems(sourcePlayer, "on")
			exports.cosmo_hud:showInfobox(root, "aduty", getPlayerAdminNick(sourcePlayer) .. " kilépett az adminszolgálatból.")

			if isTimer(getElementData(sourcePlayer, "")) then
				killTimer(getElementData(sourcePlayer, "admin.atimer"))
			end
		end
	end
end)

addAdminCommand("aduty", 1, "Adminszolgálat be -és kikapcsolása")
addCommandHandler("aduty", function(sourcePlayer, commandName)
	if havePermission(sourcePlayer, commandName) then
		local currentState = getElementData(sourcePlayer, "adminDuty")

		if not currentState then
			setElementData(sourcePlayer, "adminDuty", true)
			setElementData(sourcePlayer, "visibleName", getPlayerAdminNick(sourcePlayer))
			setElementData(sourcePlayer, "invulnerable", true)
			exports.cosmo_inventory:hideAttachedItems(sourcePlayer, "off")
			--exports.cosmo_core:sendMessageToAdmins ("#7cc576[AdminDuty]: #32b3ef" getPlayerAdminNick(sourcePlayer) .. " #ffffffadminszolgálatba lépett.")

			local adutyTimer = setTimer(function() 
				if isElement(sourcePlayer) and getElementData(sourcePlayer, "adminDuty") == true then
--					setElementData(sourcePlayer, "admin.atime", getElementData(sourcePlayer, "admin.atime")+1)
--					dbExec(connection, "UPDATE accounts SET atime=? WHERE accountID='" .. getElementData(sourcePlayer, "char.ID") .. "'", getElementData(sourcePlayer,"admin.atime"))
				end
			end, 60000, 0)
			setElementData(sourcePlayer, "admin.atimer", adutyTimer)

--			exports.cosmo_core:adminduty("#32b3ef" .. getPlayerAdminNick(sourcePlayer) .. " #ffffffadminszolgálatba lépett.",1, message, v, 255, 255, 255, true)
			exports.cosmo_hud:showInfobox(root, "aduty", getPlayerAdminNick(sourcePlayer) .. " adminszolgálatba lépett.")
		else
			setElementData(sourcePlayer, "adminDuty", false)
			setElementData(sourcePlayer, "visibleName", getPlayerCharacterName(sourcePlayer))
			setElementData(sourcePlayer, "invulnerable", false)
			exports.cosmo_inventory:hideAttachedItems(sourcePlayer, "on")
--			exports.cosmo_core:adminduty("#32b3ef" .. getPlayerAdminNick(sourcePlayer) .. " #ffffffkilépett az adminszolgálatból.",1, message, v, 255, 255, 255, true)
			exports.cosmo_hud:showInfobox(root, "aduty", getPlayerAdminNick(sourcePlayer) .. " kilépett az adminszolgálatból.")

			if isTimer(getElementData(sourcePlayer, "")) then
				killTimer(getElementData(sourcePlayer, "admin.atimer"))
			end
			
		end
	end
end)
function AdminDutyCommand(sourcePlayer, commandName)
	if havePermission(sourcePlayer, commandName) then
		local currentState = getElementData(sourcePlayer, "adminDuty")


		if not currentState then
			setElementData(sourcePlayer, "adminDuty", true)
			setElementData(sourcePlayer, "char.defaultSkin", getElementModel(sourcePlayer))
			setElementModel(sourcePlayer, 307)
			setElementData(sourcePlayer, "visibleName", getPlayerAdminNick(sourcePlayer))
			setElementData(sourcePlayer, "invulnerable", true)
			exports.cosmo_inventory:hideAttachedItems(sourcePlayer, "off")
			exports.cosmo_hud:showAlert(root, "aduty", getPlayerAdminNick(sourcePlayer) .. " adminszolgálatba lépett.")
		else
			setElementData(sourcePlayer, "adminDuty", false)
			setElementData(sourcePlayer, "visibleName", getPlayerCharacterName(sourcePlayer))
			setElementData(sourcePlayer, "invulnerable", false)
			exports.cosmo_inventory:hideAttachedItems(sourcePlayer, "on")
			exports.cosmo_hud:showAlert(root, "aduty", getPlayerAdminNick(sourcePlayer) .. " kilépett az adminszolgálatból.")
			setElementModel(sourcePlayer, getElementData(sourcePlayer, "char.defaultSkin"))
			setElementData(sourcePlayer, "char.defaultSkin")
		end
	end
end

addAdminCommand("createnpc", 8, "NPC lerakása")
addCommandHandler("createnpc", function(sourcePlayer, commandName, skin, pedtype, subtype, ...)
    if havePermission(sourcePlayer, commandName, true) then
    	skin = tonumber(skin)
    	pedtype = tonumber(pedtype)
    	subtype = tonumber(subtype)
		print(sourcePlayer, commandName, skin, pedtype, subtype, ...)
    	if not (skin and pedtype and subtype and (...) and pedtype ) then
    		outputUsageText(commandName, "[Skin ID] [Típus] [Altípus] [Név]", sourcePlayer)

    		for k, v in pairs(exports.cosmo_npcs:getNPCTypes()) do
				outputInfoText(k .. ": " .. v, sourcePlayer)
			end
    	else
    		skin = math.floor(skin)
    		pedtype = math.floor(pedtype)
    		subtype = math.floor(subtype)

    		local name = table.concat({...}, " ")

    		local x, y, z = getElementPosition(sourcePlayer)
			local rx, ry, rz = getElementRotation(sourcePlayer)
			local interior = getElementInterior(sourcePlayer)
			local dimension = getElementDimension(sourcePlayer)
			exports.cosmo_dclog:sendDiscordMessage("**"..getPlayerAdminNick(sourcePlayer).. "** Létrehozott egy **" ..exports.cosmo_npcs:getNPCTypeName(pedtype) .."** tipusú NPC-t!", "adminlog")

			if exports.cosmo_npcs:createNPC({x, y, z, rz, interior, dimension}, skin, name, pedtype, subtype) then

				outputInfoText("Sikeresen leraktál egy #658e57" .. exports.cosmo_npcs:getNPCTypeName(pedtype) .. " #fffffftípusú NPC-t.", sourcePlayer)
			end
    	end
    end
end)

addCommandHandler("setplayertime", function(sourcePlayer, commandName, targetPlayer, value)
	if (getElementData(sourcePlayer, "acc.adminLevel") or 0) >= 9 then
		value = tonumber(value)
		if not (targetPlayer and value) then
			outputChatBox("#2575c7[Használat]: #ffffff/" .. commandName .. " [ID/Név] [Összeg]", sourcePlayer, 255,255,255,true)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)
			if targetPlayer then
				value = math.floor(value)
				setElementData(targetPlayer, "char.playedMinutes", value)
			end
		end
	end
end)

--[[function adminChangeLock(thePlayer, commandName)
	if tonumber(getElementData(thePlayer, "acc.adminLevel") or 0) >= 1 then
		if isPedInVehicle(thePlayer) then
			local veh = getPedOccupiedVehicle(thePlayer)
			if veh then
				local vehid = getElementData(veh, "vehicle.dbID")
				local adutyname = getElementData(thePlayer, "acc.adminNick")
				if vehid > 0 then
					exports.cosmo_inventory:giveItem(thePlayer, 2, 1, vehid)
					outputChatBox("#FFFFFF A kulcs másolásra került.",thePlayer,255,255,255,true)
				end
			end
		end
	end
end
addCommandHandler("ach", adminChangeLock, false, false)]]

addAdminCommand("deletenpc", 8, "NPC törlése")
addCommandHandler("deletenpc", function(sourcePlayer, commandName, id)
    if havePermission(sourcePlayer, commandName, true) then
    	id = tonumber(id)

        if not id then
            outputUsageText(commandName, "[NPC ID]", sourcePlayer)
        else
        	id = math.floor(id)

            if exports.cosmo_npcs:deleteNPC(id) then
				outputInfoText("Sikeresen kitörölted a(z) #658e57# " .. id .. " #ffffffazonosítóval rendelkező NPC-t.", sourcePlayer)
			else
				outputErrorText("Nem sikerült kitörölni az NPC-t!", sourcePlayer)
			end
        end
    end
end)

addAdminCommand("nearbyatm", 7, "Közeledben lévő ATM-ek")
addCommandHandler("nearbyatm", function(sourcePlayer, commandName)
	if havePermission(sourcePlayer, commandName, true) then
		outputInfoText("Közeledben lévő ATM-ek: ", sourcePlayer)
		
		local px, py, pz = getElementPosition(sourcePlayer)
		local pInt = getElementInterior(sourcePlayer)
		local pDim = getElementDimension(sourcePlayer)
		
		for i, v in pairs(getElementsByType("object")) do
			if getElementData(v, "atm.id") then
				if pInt == getElementInterior(v) and pDim == getElementDimension(v) then
					local ox, oy, oz = getElementPosition(v)
					local distance = getDistanceBetweenPoints3D(px, py, pz, ox, oy, oz)
					
					if distance <= 15 then
						outputInfoText("#2575C7>> #FFFFFFAzonosító: #2575C7"..getElementData(v, "atm.id").."#FFFFFF <> Távolság: #2575C7" .. math.floor(distance), sourcePlayer)						
					end
				end
			end
		end
	end
end)

addAdminCommand("createatm", 8, "ATM létrehozása")
addCommandHandler("createatm", function(sourcePlayer, commandName)
    if havePermission(sourcePlayer, commandName, true) then
        local x, y, z = getElementPosition(sourcePlayer)
		local rx, ry, rz = getElementRotation(sourcePlayer)
		local interior = getElementInterior(sourcePlayer)
		local dimension = getElementDimension(sourcePlayer)

		exports.cosmo_dclog:sendDiscordMessage("**".. getPlayerAdminNick(sourcePlayer).. "** Létrehozott egy **ATM-et!**", "adminlog")

		if exports.cosmo_bank:createATM({x, y, z, rz, interior, dimension}) then
			outputInfoText("Sikeresen leraktál egy ATM-et.", sourcePlayer)
		end
    end
end)

addAdminCommand("deleteatm", 8, "ATM törlése")
addCommandHandler("deleteatm", function(sourcePlayer, commandName, id)
    if havePermission(sourcePlayer, commandName, true) then
    	id = tonumber(id)

        if not id then
            outputUsageText(commandName, "[ATM ID]", sourcePlayer)
        else
            if exports.cosmo_bank:deleteATM(id) then
				outputInfoText("Sikeresen kitörölted a(z) #658e57 #" .. id .. " #ffffffazonosítóval rendelkező ATM-et.", sourcePlayer)
			else
				outputErrorText("Nem sikerült kitörölni az ATM-et!", sourcePlayer)
			end
        end
    end
end)