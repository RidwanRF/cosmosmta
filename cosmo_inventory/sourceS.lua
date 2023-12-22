--[[


CREATE TABLE `items` (
	`dbID` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
	`itemId` INT(3) NOT NULL,
	`slot` INT(11) NOT NULL DEFAULT '0',
	`amount` INT(10) NOT NULL DEFAULT '1',
	`data1` TEXT NULL,
	`data2` TEXT NULL,
	`data3` TEXT NULL
	`ownerType` VARCHAR(8) NOT NULL,
	`ownerId` INT(11) NOT NULL,
) ENGINE=MyISAM;

CREATE TABLE `trashes` (
	`trashID` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
	`x` FLOAT NOT NULL,
	`y` FLOAT NOT NULL,
	`z` FLOAT NOT NULL,
	`rotation` FLOAT NOT NULL,
	`interior` INT(3) NOT NULL,
	`dimension` INT(5) NOT NULL
) ENGINE=InnoDB;

]]

local connection = exports.cosmo_database:getConnection()

local itemsTable = {}
local inventoryInUse = {}
local perishableTimer = false

local playerAttachments = {}
local storedTrashes = {}
local weaponAttachments = {}
local playerItemObjects = {}

local petardaTimer =0 

for k, v in ipairs(printerPos) do
	local printerObj = createObject(2202, v[1], v[2], v[3] - 1, 0, 0, v[4])
	setElementDimension(printerObj, v[5])
	setElementInterior(printerObj, v[6])
	setElementData(printerObj, "object.Printer", true)
end

addEvent("setPedCraftAnim", true)
addEventHandler("setPedCraftAnim", getRootElement(),
	function(sourcePlayer)
		setPedAnimation(sourcePlayer, "shop", "shp_serve_loop", true, false, false, false)
		
		setTimer(function()
			triggerEvent("stopPedCraftAnim",sourcePlayer,sourcePlayer)
		end, 10000, 1)
		
	end
)
addEvent("stopPedCraftAnim", true)
addEventHandler("stopPedCraftAnim", getRootElement(),
	function(sourcePlayer)
		--setPedAnimation(sourcePlayer, "shop", "shp_serve_loop", 10, false, false, false)
		setPedAnimation(sourcePlayer)
	end
)

--printSound
addEvent("printSound", true)
addEventHandler("printSound", getRootElement(),
	function(prX, prY, prZ, clickedWorld)
		triggerClientEvent(root, "printSoundC", root, prX, prY, prZ, clickedWorld)
	end)

addEvent("printAnim", true)
addEventHandler("printAnim", getRootElement(),
	function(sourcePlayer)
		setPedAnimation(sourcePlayer, "BAR", "Barserve_bottle", 8000, false)
	end)

-- bírság
addEvent("ticketPerishableEvent2", true)
addEventHandler("ticketPerishableEvent2", getRootElement(),
	function(itemId)
		if isElement(source) and itemsTable[source] then
			local theItem = false

			for k, v in pairs(itemsTable[source]) do
				if v.dbID == itemId then
					theItem = v
					break
				end
			end

			if theItem then
				dbQuery(
					function(qh, sourcePlayer)
						dbFree(qh)

						if isElement(sourcePlayer) then
							local json_data = fromJSON(theItem.data1)

							if json_data then
								local fineAmount = tonumber(json_data.fine)

								exports.cosmo_core:takeMoneyEx(sourcePlayer, fineAmount * 10, "autoticket")

								exports.cosmo_hud:showInfobox(sourcePlayer, "error", "Nem fizetted be a bírságot ezért a tízszeresét azaz " .. fineAmount * 10 .. " $-t vontunk le.")
							end

							itemsTable[sourcePlayer][theItem.slot] = nil

							triggerItemEvent(sourcePlayer, "deleteItem", "player", {theItem.dbID})
						end
					end, {source}, connection, "DELETE FROM items WHERE dbID = ?", theItem.dbID
				)
			end
		end
	end)

-- parkolási bírság
addEvent("ticketPerishableEvent", true)
addEventHandler("ticketPerishableEvent", getRootElement(),
	function(itemId)
		if isElement(source) and itemsTable[source] then
			local theItem = false

			for k, v in pairs(itemsTable[source]) do
				if v.dbID == itemId then
					theItem = v
					break
				end
			end

			if theItem then
				dbQuery(
					function(qh, sourcePlayer)
						dbFree(qh)

						if isElement(sourcePlayer) then
							local json_data = fromJSON(theItem.data1)

							if json_data then
								local fineAmount = tonumber(json_data.fine)

								exports.cosmo_core:takeMoneyEx(sourcePlayer, fineAmount * 10, "autoticket")

								exports.cosmo_hud:showInfobox(sourcePlayer, "error", "Nem fizetted be a parkolási bírságot ezért a tízszeresét azaz " .. fineAmount * 10 .. " $-t vontunk le.")
							end

							itemsTable[sourcePlayer][theItem.slot] = nil

							triggerItemEvent(sourcePlayer, "deleteItem", "player", {theItem.dbID})
						end
					end, {source}, connection, "DELETE FROM items WHERE dbID = ?", theItem.dbID
				)
			end
		end
	end)

addEvent("requestVehicleTicket", true)
addEventHandler("requestVehicleTicket", getRootElement(),
	function(theVehicle, data)
		if isElement(source) then
			if data then
				local vehicleId = getElementData(theVehicle, "vehicle.dbID") or 0

				if vehicleId > 0 then
					dbQuery(
						function(qh, sourcePlayer)
							dbFree(qh)

							setElementData(theVehicle, "vehicleTicket", false)

							if isElement(sourcePlayer) then
								local currentTime = getRealTime().timestamp
								local elapsedMinute = (data.autoPayOut - currentTime) / 60

								addItem(sourcePlayer, 118, 1, false, toJSON(data), false, math.floor(perishableItems[118] - elapsedMinute))
							end
						end, {source}, connection, "UPDATE vehicles SET theTicket = '' WHERE vehicleID = ?", vehicleId
					)
				end
			end
		end
	end)

addEvent("giveArmor", true)
addEventHandler("giveArmor", root, function(newValue)
	setPedArmor(source, newValue)
end)

function processVehicleTickets()
	local currentTime = getRealTime().timestamp
	local vehicles = getElementsByType("vehicle")
	local notify = {}

	for k = 1, #vehicles do
		local v = vehicles[k]

		if v then	
			local theTicket = getElementData(v, "vehicleTicket")

			if theTicket then
				local json_data = fromJSON(theTicket)
				local vehicleOwnerId = getElementData(v, "vehicle.owner") or 0

				if json_data and type(json_data) == "table" and vehicleOwnerId > 0 then
					local vehicleOwnerSource = exports.cosmo_accounts:getPlayerFromCharacterID(vehicleOwnerId)

					if isElement(vehicleOwnerSource) then
						if currentTime >= (json_data.autoPayOut or 0) then
							local fineAmount = tonumber(json_data.fine)

							exports.cosmo_core:takeMoneyEx(vehicleOwnerSource, fineAmount * 10, "autoticket")

							exports.cosmo_hud:showInfobox(vehicleOwnerSource, "error", "Nem fizetted be a parkolási bírságot ezért a tízszeresét azaz " .. fineAmount * 10 .. " $-t vontunk le.")
						
							setElementData(v, "vehicleTicket", false)

							local vehicleId = getElementData(v, "vehicle.dbID") or 0

							if vehicleId > 0 then
								dbExec(connection, "UPDATE vehicles SET theTicket = '' WHERE vehicleID = ?", vehicleId)
							end
						else
							if not notify[vehicleOwnerSource] then
								notify[vehicleOwnerSource] = {}
							end

							table.insert(notify[vehicleOwnerSource], json_data)
						end
					end
				end
			end
		end
	end

	local players = getElementsByType("player")

	for k = 1, #players do
		local v = players[k]

		if v and notify[v] then
			outputChatBox("#d75959<< FIGYELMEZTETÉS >> #ffffffTájékoztatjuk, hogy önnek #d75959" .. #notify[v] .. " db #ffffffintézetlen csekkje van az alábbi járművein:", v, 0, 0, 0, true)

			for k2, v2 in ipairs(notify[v]) do
				local remaining = math.floor((v2.autoPayOut - currentTime) % 172800 / 3600) + 1

				outputChatBox(" - Rendszám: #d75959" .. v2.numberplate .. " #ffffff| Lejáratig hátralévő idő: #d75959kb. " .. remaining .. " #ffffffóra.", v, 255, 255, 255, true)
			end
		end
	end
end

addEvent("ticketTheVehicle", true)
addEventHandler("ticketTheVehicle", getRootElement(),
	function(theVehicle, data)
		if isElement(source) then
			if isElement(theVehicle) and data then
				local vehicleId = getElementData(theVehicle, "vehicle.dbID") or 0

				if vehicleId > 0 then
					local vehicleOwnerId = getElementData(theVehicle, "vehicle.owner") or 0

					if vehicleOwnerId > 0 then
						data.autoPayOut = getRealTime().timestamp + 172800 -- (60 * 60 * 48) = 48 óra
						data = toJSON(data)

						dbQuery(
							function(qh, sourcePlayer)
								dbFree(qh)

								setElementData(theVehicle, "vehicleTicket", data)

								if isElement(sourcePlayer) then

								end
							end, {source}, connection, "UPDATE vehicles SET theTicket = ? WHERE vehicleID = ?", data, vehicleId
						)
					else
						exports.cosmo_hud:showInfobox(source, "e", "Erre a járműre nem állíthatsz ki csekket!")
					end
				else
					exports.cosmo_hud:showInfobox(source, "e", "Erre a járműre nem állíthatsz ki csekket!")
				end
			end
		end
	end)

addEventHandler("onResourceStart", getRootElement(),
	function(startedResource)
		if getResourceName(startedResource) == "cosmo_database" then
			connection = exports.cosmo_database:getConnection()
		elseif source == getResourceRootElement() then
			local cosmo_database = getResourceFromName("cosmo_database")

			if cosmo_database and getResourceState(cosmo_database) == "running" then
				connection = exports.cosmo_database:getConnection()
			end

			for k, v in ipairs(getElementsByType("player")) do
				takeAllWeapons(v)
			end

			dbQuery(loadTrashes, connection, "SELECT * FROM trashes")
			dbQuery(loadSafes, connection, "SELECT * FROM safes")

			if isTimer(perishableTimer) then
				killTimer(perishableTimer)
			end

			perishableTimer = setTimer(processPerishableItems, 60000, 0)

			setTimer(processVehicleTickets, 1800000, 0)
		end
	end)

	addEvent("updateItemNametag", true)
	addEventHandler("updateItemNametag", getRootElement(),
		function(sourceElement, dbID, newData, sync)
			if isElement(sourceElement) then
				dbID = tonumber(dbID)
	
				if dbID and newData then
					--print("dbid meg newdata van ok")
					for k, v in pairs(itemsTable[sourceElement]) do
						--print("forciklus done")
						if v.dbID == dbID then
							--print("ugyanaz a döböidö")
							itemsTable[sourceElement][v.slot].nameTag = newData
							dbExec(connection, "UPDATE items SET nameTag = ? WHERE dbID = ?", newData, dbID)
							--print("ez is megvan (dbexeksz)")
	
							if sync then
								if getElementType(source) ~= "player" then
									triggerItemEvent(sourceElement, "loadItems", itemsTable[sourceElement], getElementType(source))
								end
							end
	
							break
						end
					end
				end
			end
		end)

function processPerishableItems()
	for k, v in pairs(itemsTable) do
		if isElement(k) then
			if getElementType(k) == "vehicle" or getElementType(k) == "object" then
				for k2, v2 in pairs(itemsTable[k]) do
					if perishableItems[v2.itemId] then
						local perishableAmount = (tonumber(v2.data3) or 0) + 1

						if perishableAmount - 1 > perishableItems[v2.itemId] then
							triggerEvent("updateItemData3", k, k, v2.dbID, perishableItems[v2.itemId], true)
						end

						if perishableAmount <= perishableItems[v2.itemId] then
							triggerEvent("updateItemData3", k, k, v2.dbID, perishableAmount, true)
						elseif perishableEvent[v2.itemId] then
							triggerEvent(perishableEvent[v2.itemId], k, v2.dbID)
						end
					end
				end
			end
		else
			itemsTable[k] = nil
		end
	end
end

addCommandHandler("reloadmyweapon",
	function(sourcePlayer, commandName)
		reloadPedWeapon(sourcePlayer)
	end)

addEvent("requestTrashes", true)
addEventHandler("requestTrashes", getRootElement(),
	function()
		if isElement(source) then
			triggerClientEvent(source, "receiveTrashes", source, storedTrashes)
		end
	end)

function loadSafes(qh)
	local result = dbPoll(qh, 0)
	
	if result then
		for k, v in pairs(result) do
			loadSafe(v)
		end
	end
end

function loadSafe(data)
	local objectElement = createObject(2332, tonumber(data.x), tonumber(data.y), tonumber(data.z) - 0.5, 0, 0, data.rotation)
	
	if isElement(objectElement) then
		setElementInterior(objectElement, data.interior)
		setElementDimension(objectElement, data.dimension)
		setElementData(objectElement, "safeId", data.id)
		setElementData(objectElement, "isSafe", true)
		setElementData(objectElement, "object.name", "Széf (ID: "..data.id..")")
		
		loadItems(objectElement, data.id)
		return true
	end
	return false
end

function loadTrashes(qh)
	local result = dbPoll(qh, 0)

	if result then
		for k, v in pairs(result) do
			loadTrash(v)
		end
	end
end

function loadTrash(data)
	local objectElement = createObject(1359, data.x, data.y, data.z - 0.3, 0, 0, data.rotation)

	if isElement(objectElement) then
		local trashId = data.trashID

		setElementInterior(objectElement, data.interior)
		setElementDimension(objectElement, data.dimension)

		storedTrashes[trashId] = {}
		storedTrashes[trashId].trashId = trashId
		storedTrashes[trashId].objectElement = objectElement
		storedTrashes[trashId].interior = data.interior
		storedTrashes[trashId].dimension = data.dimension

		return true
	end

	return false
end

exports.cosmo_admin:addAdminCommand("seeinv", 1, "Játékos inventoryjának megtekintése")
addCommandHandler("seeinv", 
	function(localPlayer, cmd, target)
		if getElementData(localPlayer, "acc.adminLevel") >= 1 then
			if not (target) then
				outputChatBox("#32b3ef>> Használat: #ffffff/" .. cmd .. " [ID/Név]", localPlayer, 0, 0, 0, true)
				return
			else
				target = exports.cosmo_core:findPlayer(localPlayer, target)
				
				if target then
					local playerName = getElementData(target, "visibleName"):gsub("_", " ")
					local charMoney = getElementData(target, "char.Money") or 0
					triggerClientEvent(localPlayer, "bodySearchGetDatas", localPlayer, itemsTable[target] or {}, playerName, charMoney)
 				end
			end
		end
	end
)

exports.cosmo_admin:addAdminCommand("getsafe", 6, "Széf getelés")
addCommandHandler("getsafe",
	function(player, cmd, safeid)
		if getElementData(player, "acc.adminLevel") >= 6 then
			if not safeid then
				outputChatBox("#32b3ef>> Használat: #ffffff/" .. cmd .. " [Széf Azonosító]", player, 0, 0, 0, true)
				return			
			else
				local px, py, pz = getElementPosition(player)
				local rotX, rotY, rotZ = getElementRotation(player)
				local int = getElementInterior(player)
				local dim = getElementDimension(player)
				
				
				for i, v in ipairs(getElementsByType("object")) do
					if getElementData(v, "isSafe") then
						if getElementData(v, "safeId") == tonumber(safeid) then
							setElementPosition(v, px, py, pz - 0.5)
							setElementRotation(v, 0, 0, -rotZ)
							setElementDimension(v, dim)
							setElementInterior(v, int)
						end
					end
				end
				
				dbExec(connection, "UPDATE safes SET x = ?, y = ?, z = ?, rotation = ?, interior = ?, dimension = ? WHERE id = ?", px, py, pz, -rotZ, int, dim, safeid)
			end
		end
	end
)

exports.cosmo_admin:addAdminCommand("delsafe", 6, "Széf törlés")
addCommandHandler("delsafe", 
	function(player, cmd, safeId)
		if getElementData(player, "acc.adminLevel") >= 6 then
			if not safeId then
				outputChatBox(exports.cosmo_core:getServerTag("usage") .. "/" .. cmd .. " [Széf Azonosító]", player, 255, 255, 255, true)
			else
				safeId = tonumber(safeId)
				
				for i, v in ipairs(getElementsByType("object")) do
					if getElementData(v, "isSafe") then
						if getElementData(v, "safeId") == safeId then
							destroyElement(v)
						end
					end
				end
				
				dbExec(connection, "DELETE FROM safes WHERE id = ?", safeId)
			end
		end
	end
)

exports.cosmo_admin:addAdminCommand("createsafe", 6, "Széf létrehozás")
addCommandHandler("createsafe",
	function(localPlayer)
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
			local playerRotX, playerRotY, playerRotZ = getElementRotation(localPlayer)
			local playerInterior = getElementInterior(localPlayer)
			local playerDimension = getElementDimension(localPlayer)
			
			dbQuery(
				function(qh, sourcePlayer)
					local result = dbPoll(qh, 0, true)[2][1][1]
					
					if result then
						if loadSafe(result) then
							if isElement(sourcePlayer) then
								outputChatBox(exports.cosmo_core:getServerTag("info") .. "Széf sikeresen létrehozva. ID: #acd373" .. result.id, sourcePlayer, 255, 255, 255, true)
							end
						end
					end
				end, {localPlayer}, connection, "INSERT INTO safes (x, y, z ,rotation, interior, dimension) VALUES (?, ?, ?, ?, ?, ?); SELECT * FROM safes ORDER BY id DESC LIMIT 1", playerPosX, playerPosY, playerPosZ, playerRotZ, playerInterior, playerDimension
			)
		end
	end
)

exports.cosmo_admin:addAdminCommand("createtrash", 6, "Szemetes létrehozása")
addCommandHandler("createtrash",
	function(localPlayer)
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
			local playerRotX, playerRotY, playerRotZ = getElementRotation(localPlayer)
			local playerInterior = getElementInterior(localPlayer)
			local playerDimension = getElementDimension(localPlayer)

			dbQuery(
				function (qh, sourcePlayer)
					local result = dbPoll(qh, 0, true)[2][1][1]

					if result then
						if loadTrash(result) then
							triggerClientEvent("createTrash", resourceRoot, result.trashID, result)

							if isElement(sourcePlayer) then
								outputChatBox(exports.cosmo_core:getServerTag("info") .. "Szemetes sikeresen létrehozva. ID: #acd373" .. result.trashID, sourcePlayer, 255, 255, 255, true)
							end
						end
					end
				end, {localPlayer}, connection, "INSERT INTO trashes (x, y, z, rotation, interior, dimension) VALUES (?,?,?,?,?,?); SELECT * FROM trashes ORDER BY trashID DESC LIMIT 1", playerPosX, playerPosY, playerPosZ, playerRotZ, playerInterior, playerDimension
			)
		end
	end)

exports.cosmo_admin:addAdminCommand("deletetrash", 6, "Szemetes törlése")
addCommandHandler("deletetrash",
	function(localPlayer, cmd, trashId)
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			if not trashId then
				outputChatBox(exports.cosmo_core:getServerTag("usage") .. "/" .. cmd .. " [Szemetes Azonosító]", localPlayer, 255, 255, 255, true)
			else
				trashId = tonumber(trashId)

				if trashId and storedTrashes[trashId] then
					triggerClientEvent("destroyTrash", localPlayer, trashId)

					destroyElement(storedTrashes[trashId].objectElement)

					storedTrashes[trashId] = nil

					dbExec(connection, "DELETE FROM trashes WHERE trashID = ?", trashId)

					outputChatBox(exports.cosmo_core:getServerTag("admin") .. "A kiválasztott szemetes sikeresen törölve.", localPlayer, 255, 255, 255, true)
				else
					outputChatBox(exports.cosmo_core:getServerTag("admin") .. "A kiválasztott szemetes nem létezik.", localPlayer, 255, 255, 255, true)
				end
			end
		end
	end)

addEvent("showTheItem", true)
addEventHandler("showTheItem", getRootElement(),
	function(item, players)
		if isElement(source) and item then
			triggerClientEvent(players, "showTheItem", source, item)
		end
	end)

function friskCommand(localPlayer, command, target)
	if getElementData(localPlayer, "loggedIn") then
		if not target then
			outputChatBox(exports.cosmo_core:getServerTag("usage") .. "/" .. command .. " [Játékos név / ID]", localPlayer, 255, 255, 255, true)
		else
			local targetPlayer = exports.cosmo_core:findPlayer(localPlayer, target)

			if targetPlayer and getElementData(targetPlayer, "loggedIn") then
				local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
				local playerInterior = getElementInterior(localPlayer)
				local playerDimension = getElementDimension(localPlayer)

				local targetPosX, targetPosY, targetPosZ = getElementPosition(targetPlayer)
				local targetInterior = getElementInterior(targetPlayer)
				local targetDimension = getElementDimension(targetPlayer)

				if getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, targetPosX, targetPosY, targetPosZ) <= 3 and playerInterior == targetInterior and playerDimension == targetDimension then
					local playerName = getElementData(targetPlayer, "visibleName"):gsub("_", " ")
					local charMoney = getElementData(targetPlayer, "char.Money") or 0

					triggerClientEvent(localPlayer, "bodySearchGetDatas", localPlayer, itemsTable[targetPlayer] or {}, playerName, charMoney)

					exports.cosmo_chat:sendLocalMeAction(localPlayer, "megmotozott valakit. ((" .. playerName .. "))")
				end
			end
		end
	end
end
addCommandHandler("motozas", friskCommand)
addCommandHandler("motozás", friskCommand)
addCommandHandler("motoz", friskCommand)
addCommandHandler("frisk", friskCommand)

addEvent("friskPlayer", true)
addEventHandler("friskPlayer", getRootElement(),
	function(targetPlayer)
		if isElement(source) and isElement(targetPlayer) then
			local playerPosX, playerPosY, playerPosZ = getElementPosition(source)
			local playerInterior = getElementInterior(source)
			local playerDimension = getElementDimension(source)

			local targetPosX, targetPosY, targetPosZ = getElementPosition(targetPlayer)
			local targetInterior = getElementInterior(targetPlayer)
			local targetDimension = getElementDimension(targetPlayer)

			if getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, targetPosX, targetPosY, targetPosZ) <= 3 and playerInterior == targetInterior and playerDimension == targetDimension then
				local playerName = getElementData(targetPlayer, "visibleName"):gsub("_", " ")
				local charMoney = getElementData(targetPlayer, "char.Money") or 0

				triggerClientEvent(source, "bodySearchGetDatas", source, itemsTable[targetPlayer] or {}, playerName, charMoney)

				exports.cosmo_chat:sendLocalMeAction(source, "megmotozott valakit. ((" .. playerName .. "))")
			end
		end
	end)

addEventHandler("onPlayerQuit", getRootElement(),
	function()
		removeATMCasette(source)
		
		if itemsTable[source] then
			itemsTable[source] = nil
		end

		if isElement(playerAttachments[source]) then
			destroyElement(playerAttachments[source])
			playerAttachments[source] = nil
		end
		
		if weaponAttachments[source] then
			for k, v in pairs(weaponAttachments[source]) do
				if isElement(v) then
					destroyElement(v)
					weaponAttachments[source] = {}
				end
			end
		end
		if getElementData(source, "sirenInVehicle") then
			local vehicle = getPedOccupiedVehicle(source) or getElementData(source, "isSirenVehicle")[1]
			triggerEvent("sirenInServer", source, source, vehicle, "destroy")
		end
	end)

addEventHandler("onPlayerQuit", getRootElement(),
	function()
		removeShopCasette(source)
		
		if itemsTable[source] then
			itemsTable[source] = nil
		end

		if isElement(playerAttachments[source]) then
			destroyElement(playerAttachments[source])
			playerAttachments[source] = nil
		end
		
		if weaponAttachments[source] then
			for k, v in pairs(weaponAttachments[source]) do
				if isElement(v) then
					destroyElement(v)
					weaponAttachments[source] = {}
				end
			end
		end
		if getElementData(source, "sirenInVehicle") then
			local vehicle = getPedOccupiedVehicle(source) or getElementData(source, "isSirenVehicle")[1]
			triggerEvent("sirenInServer", source, source, vehicle, "destroy")
		end
	end)

addEventHandler("onElementDestroy", getRootElement(),
	function()
		if itemsTable[source] then
			itemsTable[source] = nil
		end

		if isElement(playerAttachments[source]) then
			destroyElement(playerAttachments[source])
			playerAttachments[source] = nil
		end
	end)

addEvent("takeWeapon", true)
addEventHandler("takeWeapon", getRootElement(),
	function(player, item, dbid)
		if isElement(source) then
			takeAllWeapons(source)
			
			exports["cosmo_weaponsticker"]:removeWeaponStickers(client)
			if not getElementData(player, "adminDuty") then
				attachWeapon(player, item, dbid)
			end
		end
	end)

addEvent("giveWeapon", true)
addEventHandler("giveWeapon", getRootElement(),
	function(itemId, weaponId, ammo, dbid)
		if isElement(source) then
			takeAllWeapons(source)

			giveWeapon(source, weaponId, ammo, true)
			
			if itemId == 223 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"sawedoff", "camo", "sawed")
                setElementData(client, "weaponshadername", "sawedoff")
                setElementData(client, "weaponshaderid", "camo")
                setElementData(client, "weaponFolder", "sawed")
			elseif itemId == 224 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"sawedoff", "gold", "sawed")
                setElementData(client, "weaponshadername", "sawedoff")
                setElementData(client, "weaponshaderid", "gold")
                setElementData(client, "weaponFolder", "sawed")
			elseif itemId == 225 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"sawedoff", "tiger", "sawed")
                setElementData(client, "weaponshadername", "sawedoff")
                setElementData(client, "weaponshaderid", "tiger")
                setElementData(client, "weaponFolder", "sawed")
			elseif itemId == 226 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"sawedoff", "winter", "sawed")
                setElementData(client, "weaponshadername", "sawedoff")
                setElementData(client, "weaponshaderid", "winter")
                setElementData(client, "weaponFolder", "sawed")
			end			
			if itemId == 135 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"kabar", "knife1", "knife")
                setElementData(client, "weaponshadername", "kabar")
                setElementData(client, "weaponshaderid", "knife1")
                setElementData(client, "weaponFolder", "knife")
			elseif itemId == 136 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"kabar", "knife2", "knife")
                setElementData(client, "weaponshadername", "kabar")
                setElementData(client, "weaponshaderid", "knife2")
                setElementData(client, "weaponFolder", "knife")
			elseif itemId == 137 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"kabar", "knife3", "knife")
                setElementData(client, "weaponshadername", "kabar")
                setElementData(client, "weaponshaderid", "knife3")
                setElementData(client, "weaponFolder", "knife")
			elseif itemId == 138 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"kabar", "knife4", "knife")
                setElementData(client, "weaponshadername", "kabar")
                setElementData(client, "weaponshaderid", "knife4")
                setElementData(client, "weaponFolder", "knife")
			elseif itemId == 139 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"kabar", "knife6", "knife")
                setElementData(client, "weaponshadername", "kabar")
                setElementData(client, "weaponshaderid", "knife6")
                setElementData(client, "weaponFolder", "knife")
			elseif itemId == 140 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"kabar", "knife5", "knife")
                setElementData(client, "weaponshadername", "kabar")
                setElementData(client, "weaponshaderid", "knife5")
                setElementData(client, "weaponFolder", "knife")
			elseif itemId == 128 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"ak", "kitty", "ak")
                setElementData(client, "weaponshadername", "ak")
                setElementData(client, "weaponshaderid", "kitty")
                setElementData(client, "weaponFolder", "ak")
			elseif itemId == 129 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"ak", "camo3", "ak")
                setElementData(client, "weaponshadername", "ak")
                setElementData(client, "weaponshaderid", "camo3")
                setElementData(client, "weaponFolder", "ak")
			elseif itemId == 130 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"ak", "camo2", "ak")
                setElementData(client, "weaponshadername", "ak")
                setElementData(client, "weaponshaderid", "camo2")
                setElementData(client, "weaponFolder", "ak")
			elseif itemId == 131 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"ak", "camo", "ak")
                setElementData(client, "weaponshadername", "ak")
                setElementData(client, "weaponshaderid", "camo")
                setElementData(client, "weaponFolder", "ak")
			elseif itemId == 132 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"ak", "gold", "ak")
                setElementData(client, "weaponshadername", "ak")
                setElementData(client, "weaponshaderid", "gold")
                setElementData(client, "weaponFolder", "ak")
			elseif itemId == 133 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"ak", "gold2", "ak")
                setElementData(client, "weaponshadername", "ak")
                setElementData(client, "weaponshaderid", "gold2")
                setElementData(client, "weaponFolder", "ak")
			elseif itemId == 134 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"ak", "silver", "ak")
                setElementData(client, "weaponshadername", "ak")
                setElementData(client, "weaponshaderid", "silver")
                setElementData(client, "weaponFolder", "ak")
			elseif itemId == 141 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"deagle", "camo", "deagle")
                setElementData(client, "weaponshadername", "deagle")
                setElementData(client, "weaponshaderid", "camo")
                setElementData(client, "weaponFolder", "deagle")
			elseif itemId == 142 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"deagle", "gold", "deagle")
                setElementData(client, "weaponshadername", "deagle")
                setElementData(client, "weaponshaderid", "gold")
                setElementData(client, "weaponFolder", "deagle")
			elseif itemId == 143 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"deagle", "hellokitty", "deagle")
                setElementData(client, "weaponshadername", "deagle")
                setElementData(client, "weaponshaderid", "hellokitty")
                setElementData(client, "weaponFolder", "deagle")
			elseif itemId == 144 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"mp5", "mp51", "mp5")
                setElementData(client, "weaponshadername", "mp5")
                setElementData(client, "weaponshaderid", "mp51")
                setElementData(client, "weaponFolder", "mp5")
			elseif itemId == 145 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"mp5", "mp52", "mp5")
                setElementData(client, "weaponshadername", "mp5")
                setElementData(client, "weaponshaderid", "mp52")
                setElementData(client, "weaponFolder", "mp5")
			elseif itemId == 146 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"mp5", "mp53", "mp5")
                setElementData(client, "weaponshadername", "mp5")
                setElementData(client, "weaponshaderid", "mp53")
                setElementData(client, "weaponFolder", "mp5")
			elseif itemId == 147 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"mp5", "mp54", "mp5")
                setElementData(client, "weaponshadername", "mp5")
                setElementData(client, "weaponshaderid", "mp54")
                setElementData(client, "weaponFolder", "mp5")
			elseif itemId == 148 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"tekstura", "camo", "sniper")
                setElementData(client, "weaponshadername", "tekstura")
                setElementData(client, "weaponshaderid", "camo")
                setElementData(client, "weaponFolder", "sniper")
			elseif itemId == 149 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"tekstura", "camo2", "sniper")
                setElementData(client, "weaponshadername", "tekstura")
                setElementData(client, "weaponshaderid", "camo2")
                setElementData(client, "weaponFolder", "sniper")
			elseif itemId == 185 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"tekstura", "gold", "sniper")
                setElementData(client, "weaponshadername", "tekstura")
                setElementData(client, "weaponshaderid", "gold")
                setElementData(client, "weaponFolder", "sniper")
            elseif itemId == 186 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"tekstura", "hellokitty", "sniper")
                setElementData(client, "weaponshadername", "tekstura")
                setElementData(client, "weaponshaderid", "hellokitty")
                setElementData(client, "weaponFolder", "sniper")
			elseif itemId == 150 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"gun", "tec1", "tec")
                setElementData(client, "weaponshadername", "gun")
                setElementData(client, "weaponshaderid", "tec1")
                setElementData(client, "weaponFolder", "tec")
			elseif itemId == 151 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"gun", "tec2", "tec")
                setElementData(client, "weaponshadername", "gun")
                setElementData(client, "weaponshaderid", "tec2")
                setElementData(client, "weaponFolder", "tec")
			elseif itemId == 152 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"gun", "tec3", "tec")
                setElementData(client, "weaponshadername", "gun")
                setElementData(client, "weaponshaderid", "tec3")
                setElementData(client, "weaponFolder", "tec")
			elseif itemId == 153 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"gun", "tec4", "tec")
                setElementData(client, "weaponshadername", "gun")
                setElementData(client, "weaponshaderid", "tec4")
                setElementData(client, "weaponFolder", "tec")
			elseif itemId == 154 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"9MM_c", "uzi1", "uzi")
                setElementData(client, "weaponshadername", "9MM_c")
                setElementData(client, "weaponshaderid", "uzi1")
                setElementData(client, "weaponFolder", "uzi")
			elseif itemId == 155 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"9MM_c", "uzi2", "uzi")
                setElementData(client, "weaponshadername", "9MM_c")
                setElementData(client, "weaponshaderid", "uzi2")
                setElementData(client, "weaponFolder", "uzi")
			elseif itemId == 156 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"9MM_c", "uzi3", "uzi")
                setElementData(client, "weaponshadername", "9MM_c")
                setElementData(client, "weaponshaderid", "uzi3")
                setElementData(client, "weaponFolder", "uzi")
			elseif itemId == 157 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"9MM_c", "uzi4", "uzi")
                setElementData(client, "weaponshadername", "9MM_c")
                setElementData(client, "weaponshaderid", "uzi4")
                setElementData(client, "weaponFolder", "uzi")
			elseif itemId == 172 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"1stpersonassualtcarbine", "camom4", "m4")
                setElementData(client, "weaponshadername", "1stpersonassualtcarbine")
                setElementData(client, "weaponshaderid", "camom4")
                setElementData(client, "weaponFolder", "m4")
			elseif itemId == 173 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"1stpersonassualtcarbine", "goldm4", "m4")
                setElementData(client, "weaponshadername", "1stpersonassualtcarbine")
                setElementData(client, "weaponshaderid", "goldm4")
                setElementData(client, "weaponFolder", "m4")
			elseif itemId == 174 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"1stpersonassualtcarbine", "hellom4", "m4")
                setElementData(client, "weaponshadername", "1stpersonassualtcarbine")
                setElementData(client, "weaponshaderid", "hellom4")
                setElementData(client, "weaponFolder", "m4")
			elseif itemId == 175 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"1stpersonassualtcarbine", "paintm4", "m4")
                setElementData(client, "weaponshadername", "1stpersonassualtcarbine")
                setElementData(client, "weaponshaderid", "paintm4")
                setElementData(client, "weaponFolder", "m4")
			elseif itemId == 176 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"1stpersonassualtcarbine", "winterm4", "m4")
                setElementData(client, "weaponshadername", "1stpersonassualtcarbine")
                setElementData(client, "weaponshaderid", "winterm4")
                setElementData(client, "weaponFolder", "m4")
			elseif itemId == 182 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"m870t", "shotgun_camo", "shotgun")
                setElementData(client, "weaponshadername", "m870t")
                setElementData(client, "weaponshaderid", "shotgun_camo")
                setElementData(client, "weaponFolder", "shotgun")
			elseif itemId == 183 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"m870t", "shotgun_gold", "shotgun")
                setElementData(client, "weaponshadername", "m870t")
                setElementData(client, "weaponshaderid", "shotgun_gold")
                setElementData(client, "weaponFolder", "shotgun")
            elseif itemId == 184 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"m870t", "shotgun_rust2", "shotgun")
                setElementData(client, "weaponshadername", "m870t")
                setElementData(client, "weaponshaderid", "shotgun_rust2")
                setElementData(client, "weaponFolder", "shotgun")
			elseif itemId == 213 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"1stpersonassualtcarbine", "digitm4", "m4")
                setElementData(client, "weaponshadername", "1stpersonassualtcarbine")
                setElementData(client, "weaponshaderid", "digitm4")
                setElementData(client, "weaponFolder", "m4")
			elseif itemId == 214 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"1stpersonassualtcarbine", "icem4", "m4")
                setElementData(client, "weaponshadername", "1stpersonassualtcarbine")
                setElementData(client, "weaponshaderid", "icem4")
                setElementData(client, "weaponFolder", "m4")
			elseif itemId == 215 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"1stpersonassualtcarbine", "silverm4", "m4")
                setElementData(client, "weaponshadername", "1stpersonassualtcarbine")
                setElementData(client, "weaponshaderid", "silverm4")
                setElementData(client, "weaponFolder", "m4")
			elseif itemId == 216 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"1stpersonassualtcarbine", "wandalm4", "m4")
                setElementData(client, "weaponshadername", "1stpersonassualtcarbine")
                setElementData(client, "weaponshaderid", "wandalm4")
                setElementData(client, "weaponFolder", "m4")
			elseif itemId == 217 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"1stpersonassualtcarbine", "rustm4", "m4")
                setElementData(client, "weaponshadername", "1stpersonassualtcarbine")
                setElementData(client, "weaponshaderid", "rustm4")
                setElementData(client, "weaponFolder", "m4")
			elseif itemId == 229 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"1stpersonassualtcarbine", "rosem4", "m4")
                setElementData(client, "weaponshadername", "1stpersonassualtcarbine")
                setElementData(client, "weaponshaderid", "rosem4")
                setElementData(client, "weaponFolder", "m4")
			elseif itemId == 269 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"kabar", "knife7", "knife")
                setElementData(client, "weaponshadername", "kabar")
                setElementData(client, "weaponshaderid", "knife7")
                setElementData(client, "weaponFolder", "knife")
			elseif itemId == 270 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"kabar", "knife8", "knife")
                setElementData(client, "weaponshadername", "kabar")
                setElementData(client, "weaponshaderid", "knife8")
                setElementData(client, "weaponFolder", "knife")
			elseif itemId == 271 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"mp5", "mp55", "mp5")
                setElementData(client, "weaponshadername", "mp5")
                setElementData(client, "weaponshaderid", "mp55")
                setElementData(client, "weaponFolder", "mp5")
			elseif itemId == 272 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"mp5", "mp56", "mp5")
                setElementData(client, "weaponshadername", "mp5")
                setElementData(client, "weaponshaderid", "mp56")
                setElementData(client, "weaponFolder", "mp5")
			elseif itemId == 274 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"1911", "kitty", "silenced")
                setElementData(client, "weaponshadername", "1911")
                setElementData(client, "weaponshaderid", "kitty")
                setElementData(client, "weaponFolder", "silenced")
			elseif itemId == 279 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"1911", "gold", "silenced")
                setElementData(client, "weaponshadername", "1911")
                setElementData(client, "weaponshaderid", "gold")
                setElementData(client, "weaponFolder", "silenced")
			elseif itemId == 261 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"map", "galaxy", "katana")
                setElementData(client, "weaponshadername", "map")
                setElementData(client, "weaponshaderid", "galaxy")
                setElementData(client, "weaponFolder", "katana")
			elseif itemId == 262 then
				exports["cosmo_weaponsticker"]:setStickerOnWeapon(client,"map", "gold", "katana")
                setElementData(client, "weaponshadername", "map")
                setElementData(client, "weaponshaderid", "gold")
                setElementData(client, "weaponFolder", "katana")
			end

			if weaponModels[itemId] and not getElementData(client, "adminDuty") then
				delAttachWeapon(source, itemId, dbid)
			end
			--reloadPedWeapon(source)
		end
	end)

function changeModelIntOrDim(player)
	local int = getElementInterior(player)
	local dim = getElementDimension(player)

	if weaponAttachments[player] then
		for k, v in pairs(weaponAttachments[player]) do
			if isElement(v) then
				setElementInterior(v, int)
				setElementDimension(v, dim)
			end
		end
	end
end
addEvent("changeModelIntOrDim", true)
addEventHandler("changeModelIntOrDim", root, changeModelIntOrDim)

function attachWeapon(player, item, dbid)
	if not weaponAttachments[player] then
		weaponAttachments[player] = {}
	end
	
    setElementData(player, "weaponshadername", 0)
    setElementData(player, "weaponshaderid", 0)
    setElementData(player, "weaponFolder", 0)
	if not isElement(weaponAttachments[player][dbid]) or not weaponAttachments[player][dbID] then
		local x, y, z = getElementPosition(player)
		
		if weaponModels[item] then
			weaponAttachments[player][dbid] = createObject(weaponModels[item][1], 0, 0, 0)
			setElementCollisionsEnabled(weaponAttachments[player][dbid], false)
			setElementPosition(weaponAttachments[player][dbid], x, y, z)
			setElementInterior(weaponAttachments[player][dbid], getElementInterior(player))
			setElementDimension(weaponAttachments[player][dbid], getElementDimension(player))
			--setElementData(weaponAttachments[player][dbid], "attachedObject", true)
			
			if item == 223 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"sawedoff", "camo", "sawed")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "sawedoff")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "camo")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "sawed")
			elseif item == 224 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"sawedoff", "gold", "sawed")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "sawedoff")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "gold")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "sawed")
			elseif item == 225 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"sawedoff", "tiger", "sawed")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "sawedoff")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "tiger")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "sawed")
			elseif item == 226 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"sawedoff", "winter", "sawed")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "sawedoff")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "winter")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "sawed")
			end
			if item == 128 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"ak", "kitty",  "ak")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "ak")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "kitty")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "ak")
			elseif item == 129 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"ak", "camo3",  "ak")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "ak")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "camo3")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "ak")
			elseif item == 130 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"ak", "camo2",  "ak")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "ak")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "camo2")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "ak")
			elseif item == 131 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"ak", "camo",  "ak")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "ak")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "camo")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "ak")
			elseif item == 132 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"ak", "gold",  "ak")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "ak")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "gold")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "ak")
			elseif item == 133 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"ak", "gold2",  "ak")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "ak")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "gold2")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "ak")
			elseif item == 134 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"ak", "silver",  "ak")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "ak")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "silver")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "ak")
			elseif item == 135 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"kabar", "knife1", "knife")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "kabar")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "knife1")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "knife")
			elseif item == 136 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"kabar", "knife2", "knife")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "kabar")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "knife2")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "knife")
			elseif item == 137 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"kabar", "knife3", "knife")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "kabar")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "knife3")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "knife")
			elseif item == 138 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"kabar", "knife4", "knife")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "kabar")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "knife4")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "knife")
			elseif item == 139 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"kabar", "knife6", "knife")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "kabar")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "knife6")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "knife")
			elseif item == 140 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"kabar", "knife5", "knife")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "kabar")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "knife5")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "knife")
			elseif item == 141 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"deagle", "camo", "deagle")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "deagle")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "camo")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "deagle")
			elseif item == 142 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"deagle", "gold", "deagle")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "deagle")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "gold")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "deagle")
			elseif item == 143 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"deagle", "hellokitty", "deagle")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "deagle")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "hellokitty")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "deagle")
			elseif item == 144 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"mp5", "mp51", "mp5")	
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "mp5")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "mp51")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "mp5")
			elseif item == 145 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"mp5", "mp52", "mp5")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "mp5")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "mp52")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "mp5")
			elseif item == 146 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"mp5", "mp53", "mp5")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "mp5")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "mp53")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "mp5")
			elseif item == 147 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"mp5", "mp54", "mp5")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "mp5")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "mp54")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "mp5")
			elseif item == 148 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"tekstura", "camo", "sniper")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "tekstura")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "camo")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "sniper")
			elseif item == 149 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"tekstura", "camo2", "sniper")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "tekstura")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "camo2")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "sniper")
			elseif item == 185 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"tekstura", "gold", "sniper")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "tekstura")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "gold")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "sniper")
			elseif item == 186 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"tekstura", "hellokitty", "sniper")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "tekstura")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "hellokitty")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "sniper")
			elseif item == 172 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"1stpersonassualtcarbine", "camom4", "m4")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "1stpersonassualtcarbine")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "camom4")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "m4")
			elseif item == 173 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"1stpersonassualtcarbine", "goldm4", "m4")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "1stpersonassualtcarbine")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "goldm4")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "m4")
			elseif item == 174 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"1stpersonassualtcarbine", "hellom4", "m4")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "1stpersonassualtcarbine")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "hellom4")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "m4")
			elseif item == 175 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"1stpersonassualtcarbine", "paintm4", "m4")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "1stpersonassualtcarbine")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "paintm4")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "m4")
			elseif item == 176 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"1stpersonassualtcarbine", "winterm4", "m4")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "1stpersonassualtcarbine")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "winterm4")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "m4")
            elseif item == 182 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"m870t", "shotgun_camo", "shotgun")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "m870t")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "shotgun_camo")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "shotgun")
            elseif item == 183 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"m870t", "shotgun_gold", "shotgun")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "m870t")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "shotgun_gold")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "shotgun")
            elseif item == 184 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"m870t", "shotgun_rust2", "shotgun")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "m870t")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "shotgun_rust2")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "shotgun")
			elseif item == 213 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"1stpersonassualtcarbine", "digitm4", "m4")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "1stpersonassualtcarbine")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "digitm4")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "m4")
			elseif item == 214 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"1stpersonassualtcarbine", "icem4", "m4")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "1stpersonassualtcarbine")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "icem4")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "m4")
			elseif item == 215 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"1stpersonassualtcarbine", "silverm4", "m4")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "1stpersonassualtcarbine")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "silverm4")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "m4")
			elseif item == 216 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"1stpersonassualtcarbine", "wandalm4", "m4")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "1stpersonassualtcarbine")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "wandalm4")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "m4")
			elseif item == 217 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"1stpersonassualtcarbine", "rustm4", "m4")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "1stpersonassualtcarbine")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "rustm4")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "m4")
			elseif item == 229 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"1stpersonassualtcarbine", "rosem4", "m4")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "1stpersonassualtcarbine")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "rosem4")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "m4")
			elseif item == 269 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"kabar", "knife7", "knife")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "kabar")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "knife7")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "knife")
			elseif item == 270 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"kabar", "knife8", "knife")
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "kabar")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "knife8")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "knife")
			elseif item == 271 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"mp5", "mp55", "mp5")	
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "mp5")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "mp55")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "mp5")
			elseif item == 272 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"mp5", "mp56", "mp5")	
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "mp5")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "mp56")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "mp5")
			elseif item == 261 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"map", "galaxy", "katana")	
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "map")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "galaxy")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "katana")
			elseif item == 262 then
				exports["cosmo_weaponsticker"]:setObjectPaintjob(weaponAttachments[player][dbid],"map", "gold", "katana")	
				setElementData(weaponAttachments[player][dbid], "weaponshadername", "map")
                setElementData(weaponAttachments[player][dbid], "weaponshaderid", "gold")
                setElementData(weaponAttachments[player][dbid], "weaponFolder", "katana")
			end	
			
			exports.cosmo_boneattach:attachElementToBone(weaponAttachments[player][dbid], player, weaponPosition[availableItems[item][5]][1], weaponPosition[availableItems[item][5]][2], weaponPosition[availableItems[item][5]][3], weaponPosition[availableItems[item][5]][4], weaponPosition[availableItems[item][5]][5], weaponPosition[availableItems[item][5]][6], weaponPosition[availableItems[item][5]][7])
		end
	end
end

function delAttachWeapon(player, item, dbid)
	if weaponAttachments[player][dbid] then
		if isElement(weaponAttachments[player][dbid]) then
			exports.cosmo_boneattach:detachElementFromBone(weaponAttachments[player][dbid])
			destroyElement(weaponAttachments[player][dbid])
			weaponAttachments[player][dbid] = {}
		end
	end
end

function taxiLampToServer(playerSource, vehicle, state)
    if state == "create" then
        if not isElement(getElementData(vehicle, "lampObject")) then
            local x, y, z = getElementPosition(vehicle)
            local lamp = createObject(1313,x,y,z)

            local posX, posY, posZ, rotX, rotY, rotZ = taxiPos[getElementModel(vehicle)][1], taxiPos[getElementModel(vehicle)][2], taxiPos[getElementModel(vehicle)][3], taxiPos[getElementModel(vehicle)][4], taxiPos[getElementModel(vehicle)][5], taxiPos[getElementModel(vehicle)][6]
                
            attachElements(lamp, vehicle, posX, posY, posZ, rotX, rotY, rotZ)
            setElementCollisionsEnabled(lamp, false)
            setElementData(vehicle, "lampObject", lamp)
                
            local clockState = getElementData(vehicle, "veh.TaxiClock")
                
            if clockState then
                local marker = createMarker(x, y, z, "corona", 0.6, 255, 255, 0, 80)

                attachElements(marker, lamp)
                setElementData(vehicle, "lampMarker", marker)
            end

            setElementData(vehicle, "isVehicleInObject", true)
            setElementData(playerSource, "isSirenVehicle", vehicle)
        end
    elseif state == "destroy" then
        if isElement(getElementData(vehicle, "lampObject")) then
            destroyElement(getElementData(vehicle, "lampObject"))
        end
        
        if isElement(getElementData(vehicle, "lampMarker")) then
            destroyElement(getElementData(vehicle, "lampMarker"))
        end
            
        setElementData(vehicle, "isVehicleInObject", false)
        setElementData(playerSource, "isSirenVehicle", nil)
    end
end

addEventHandler("onElementDataChange", getRootElement(),
	function(dataName, oldValue)
		if dataName == "canUseMegaphone" then
			if getElementData(source, dataName) then
				local playerInterior = getElementInterior(source)
				local playerDimension = getElementDimension(source)

				if isElement(playerAttachments[source]) then
					destroyElement(playerAttachments[source])
				end

				local obj = createObject(3090, 0, 0, 0)
						
				if isElement(obj) then
					setElementInterior(obj, playerInterior)
					setElementDimension(obj, playerDimension)
					setElementCollisionsEnabled(obj, false)
					setElementDoubleSided(obj, true)

					exports.cosmo_boneattach:attachElementToBone(obj, source, 12, 0.05, 0, 0.05, 0, 0, 0)

					playerAttachments[source] = obj
				end
			elseif oldValue then
				if isElement(playerAttachments[source]) then
					destroyElement(playerAttachments[source])
				end

				playerAttachments[source] = nil
			end
		elseif dataName == "canUseFlex" then
			if getElementData(source, dataName) then
				local playerInterior = getElementInterior(source)
				local playerDimension = getElementDimension(source)

				if isElement(playerAttachments[source]) then
					destroyElement(playerAttachments[source])
				end

				local obj = createObject(7312, 0, 0, 0)
						
				if isElement(obj) then
					setElementInterior(obj, playerInterior)
					setElementDimension(obj, playerDimension)
					setElementCollisionsEnabled(obj, false)
					setElementDoubleSided(obj, true)

					exports.cosmo_boneattach:attachElementToBone(obj, source, 12, 0, 0.05, 0.05, 0, -90, 90)

					playerAttachments[source] = obj
				end
			elseif oldValue then
				if isElement(playerAttachments[source]) then
					destroyElement(playerAttachments[source])
				end

				playerAttachments[source] = nil
			end
		end
	end)

local availableObjectAttachments = {
	[1] = {
		model = 2703,
		pos = {12, 0, 0.0375, 0, 0, -90, 0}
	},
	[2] = {
		model = 2769,
		pos = {12, 0, 0.0375, 0.0375, 0, -180, 0}
	},
	[3] = {
		model = 1546,
		pos = {11, 0, 0.0375, 0.0375, -90, 0, -90}
	},
	[4] = {
		model = 1544,
		pos = {11, 0, 0.0375, 0.0375, -90, 0, -90},
		scale = 0.5
	},
	[5] = {
		model = 1509,
		pos = {11, 0, 0.0375, 0.0375, -90, 0, -90}
	},
	[6] = {
		model = 1485,
		pos = {11, -0.075, 0, 0.05, 0, 0, 0}
	},
	[7] = {
		model = 1669,
		pos = {11, 0, 0.0375, 0.1, -90, 0, -90}
	}
}

addEvent("useItem", true)
addEventHandler("useItem", getRootElement(),
	function(dbID, use)
		if isElement(source) and dbID then
			local item = false

			for k, v in pairs(itemsTable[source]) do
				if v.dbID == dbID then
					item = v
					break
				end
			end

			if item then
				local playerInterior = getElementInterior(source)
				local playerDimension = getElementDimension(source)
				local itemId = item.itemId

			    if itemId == 71 then -- telefon
					if use then
						if not item.data1 or not tonumber(item.data1) then
							local x, y, z = getElementPosition(source)
							local city = getZoneName(x, y, z, true)
							local prenum = "202"

							if city == "San Fierro" then
								city = "203"
							else
								city = "20" .. math.random(4, 9)
							end

							itemsTable[source][item.slot].data1 = tonumber(prenum .. math.random(1000000, 9999999)) -- telefonszám
							itemsTable[source][item.slot].data2 = "[[]]" -- adatok / üzenetek / hívásnapló stb
							itemsTable[source][item.slot].data3 = "-" -- kontaktok

							dbExec(connection, "UPDATE items SET data1 = ?, data2 = '[[]]', data3 = '-' WHERE dbID = ?", itemsTable[source][item.slot].data1, item.dbID)

							triggerClientEvent(source, "updateItemData1", source, "player", item.dbID, itemsTable[source][item.slot].data1, true)
						end
						exports.cosmo_chat:sendLocalMeAction(source, "elővesz egy telefont.")
						setElementData(source, "phoneOpened", true)
						triggerClientEvent(source, "openPhone", source, item.dbID, tonumber(item.data1), item.data2, item.data3)
					else
						exports.cosmo_chat:sendLocalMeAction(source, "elrak egy telefont.")
						setElementData(source, "phoneOpened", false)
						triggerClientEvent(source, "openPhone", source, false)
					end

				elseif itemId == 82 then
						--triggerEvent("placeHifix", source,source)
						exports.cosmo_radio:placeRadio(source, 82)
						triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)

				elseif itemId == 122 then -- kötszer
					if (getElementData(source, "bloodLevel") or 100) < 100 then
						if not getElementData(source, "usingBandage") then
							setElementData(source, "usingBandage", true)

							triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)

							exports.cosmo_hud:showInfobox(source, "info", "Sikeresen felraktál egy kötést, ezzel lassítva a vérzést.")
						else
							exports.cosmo_hud:showInfobox(source, "error", "Már van fent egy kötés!")
						end
					else
						exports.cosmo_hud:showInfobox(source, "error", "Nem vérzel!")
					end
				elseif itemId == 86 then -- jelvény
					if use then
						setElementData(source, "badgeData", tostring(item.data1) .. " - " .. tostring(item.data2))

						exports.cosmo_chat:sendLocalMeAction(source, "felrakja a jelvényét.")
					else
						setElementData(source, "badgeData", false)

						exports.cosmo_chat:sendLocalMeAction(source, "leveszi a jelvényét.")
					end
            	elseif itemId == 258 then
                    triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)

                    itemsTable.player[slotId] = nil

                    triggerEvent("showTheRaffle", localPlayer, "day")
				elseif itemId == 179 then -- Villogó
					if use then
						local vehicle = getPedOccupiedVehicle(source)
						triggerEvent("sirenInServer", source, source, vehicle, "create")
						exports.cosmo_chat:sendLocalMeAction(source, "felrak egy villogót.")
					else
						local vehicle = getPedOccupiedVehicle(source) or getElementData(source, "isSirenVehicle")[1]
						triggerEvent("sirenInServer", source, source, vehicle, "destroy")
						exports.cosmo_chat:sendLocalMeAction(source, "levesz egy villogót.")
					end --faszfasz
				elseif itemId == 245 then -- taxu
					if use then
						local vehicle = getPedOccupiedVehicle(source)
						triggerEvent("taxiInServer", source, source, vehicle, "create")
						exports.cosmo_chat:sendLocalMeAction(source, "felrak egy taxilámpát.")
					else
						local vehicle = getPedOccupiedVehicle(source) or getElementData(source, "isTaxiVehicle")[1]
						triggerEvent("taxiInServer", source, source, vehicle, "destroy")
						exports.cosmo_chat:sendLocalMeAction(source, "levesz egy taxilámpát.")
					end
				elseif itemId == 106 then -- Vitamin
					local health = getElementHealth(source)
					
					if health + 25 >= 100 then
						health = 100
					end

					setElementHealth(source, health)
				elseif itemId == 246 then -- Gyógyszer
						triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)
				-- elseif itemId == 275 then -- PrémiumKártya		
				-- 	local cPP = getElementData(source, "char.PP")		
				-- 	setElementData(source, "char.PP", cPP+5000)
				-- 	exports.cosmo_dclog:sendDiscordMessage("**"..getPlayerName(source).."** Elhasznált egy prémium kártyát! **[5000]** @everyone", "anticheat")
				-- 	triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)	
				-- elseif itemId == 276 then -- PrémiumKártya		
				-- 	local cPP = getElementData(source, "char.PP")		
				-- 	setElementData(source, "char.PP", cPP+10000)
				-- 	exports.cosmo_dclog:sendDiscordMessage("**"..getPlayerName(source).."** Elhasznált egy prémium kártyát! **[10000]** @everyone", "anticheat")
				-- 	triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)					
				-- elseif itemId == 277 then -- PrémiumKártya		
				-- 	local cPP = getElementData(source, "char.PP")		
				-- 	setElementData(source, "char.PP", cPP+20000)
				-- 	exports.cosmo_dclog:sendDiscordMessage("**"..getPlayerName(source).."** Elhasznált egy prémium kártyát! **[20000]** @everyone", "anticheat")
				-- 	triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)				
				elseif itemId == 105 then -- Gyógyszer
					local health = getElementHealth(source)
					if health >= 20 then
						health = health + 45
						if health + 45 >= 100 then
							health = 100
						end
						triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)
						setElementHealth(source, health)
					end
				elseif itemId == 161 then
					triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)
					local skill = split(getElementData(source, "weaponSkill"), ";")
					local szoveg = "999;"..skill[2]..";"..skill[3]..";"..skill[4]..";"..skill[5]..";"..skill[6]..";"..skill[7]..";"..skill[8]..";"..skill[9]..";"..skill[10]..";"..skill[11]
					
					setElementData(source, "weaponSkill", szoveg)
					dbExec(connection, "UPDATE characters SET skills = ? WHERE charID = ?", szoveg, getElementData(source, "char.ID"))
					setPedStat(source, 69, 999) -- colt
					exports.cosmo_hud:showInfobox(source, "info", "Sikeresen kitanultad a könyvet.")
					
				elseif itemId == 162 then
					triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)
					local skill = split(getElementData(source, "weaponSkill"), ";")
					local szoveg = skill[1]..";999;"..skill[3]..";"..skill[4]..";"..skill[5]..";"..skill[6]..";"..skill[7]..";"..skill[8]..";"..skill[9]..";"..skill[10]..";"..skill[11]
					
					setElementData(source, "weaponSkill", szoveg)
					dbExec(connection, "UPDATE characters SET skills = ? WHERE charID = ?", szoveg, getElementData(source, "char.ID"))
					setPedStat(source, 70, 999) -- silenced
					exports.cosmo_hud:showInfobox(source, "info", "Sikeresen kitanultad a könyvet.")
				elseif itemId == 163 then
					triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)

					local skill = split(getElementData(source, "weaponSkill"), ";")
					local szoveg = skill[1]..";"..skill[2]..";999;"..skill[4]..";"..skill[5]..";"..skill[6]..";"..skill[7]..";"..skill[8]..";"..skill[9]..";"..skill[10]..";"..skill[11]
					
					setElementData(source, "weaponSkill", szoveg)
					dbExec(connection, "UPDATE characters SET skills = ? WHERE charID = ?", szoveg, getElementData(source, "char.ID"))
					setPedStat(source, 71,999) -- desert eagle
					exports.cosmo_hud:showInfobox(source, "info", "Sikeresen kitanultad a könyvet.")

				elseif itemId == 164 then
					triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)
					local skill = split(getElementData(source, "weaponSkill"), ";")
					local szoveg = skill[1]..";"..skill[2]..";"..skill[3]..";999;"..skill[5]..";"..skill[6]..";"..skill[7]..";"..skill[8]..";"..skill[9]..";"..skill[10]..";"..skill[11]
					
					setElementData(source, "weaponSkill", szoveg)
					dbExec(connection, "UPDATE characters SET skills = ? WHERE charID = ?", szoveg, getElementData(source, "char.ID"))
					setPedStat(source, 75, 999) -- uzi
					exports.cosmo_hud:showInfobox(source, "info", "Sikeresen kitanultad a könyvet.")
				elseif itemId == 165 then
					triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)
					local skill = split(getElementData(source, "weaponSkill"), ";")
					local szoveg = skill[1]..";"..skill[2]..";"..skill[3]..";"..skill[4]..";999;"..skill[6]..";"..skill[7]..";"..skill[8]..";"..skill[9]..";"..skill[10]..";"..skill[11]
					
					setElementData(source, "weaponSkill", szoveg)
					dbExec(connection, "UPDATE characters SET skills = ? WHERE charID = ?", szoveg, getElementData(source, "char.ID"))
					setPedStat(source, 76, 999) -- mp5
					exports.cosmo_hud:showInfobox(source, "info", "Sikeresen kitanultad a könyvet.")
				elseif itemId == 166 then
					triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)
					local skill = split(getElementData(source, "weaponSkill"), ";")
					local szoveg = skill[1]..";"..skill[2]..";"..skill[3]..";"..skill[4]..";"..skill[5]..";999;"..skill[7]..";"..skill[8]..";"..skill[9]..";"..skill[10]..";"..skill[11]
					
					setElementData(source, "weaponSkill", szoveg)
					dbExec(connection, "UPDATE characters SET skills = ? WHERE charID = ?", szoveg, getElementData(source, "char.ID"))
					setPedStat(source, 77, 999) -- ak47
					exports.cosmo_hud:showInfobox(source, "info", "Sikeresen kitanultad a könyvet.")
				elseif itemId == 167 then
					triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)
					local skill = split(getElementData(source, "weaponSkill"), ";")
					local szoveg = skill[1]..";"..skill[2]..";"..skill[3]..";"..skill[4]..";"..skill[5]..";"..skill[6]..";999;"..skill[8]..";"..skill[9]..";"..skill[10]..";"..skill[11]
					
					setElementData(source, "weaponSkill", szoveg)
					dbExec(connection, "UPDATE characters SET skills = ? WHERE charID = ?", szoveg, getElementData(source, "char.ID"))
					setPedStat(source, 78, 999) -- m4
					exports.cosmo_hud:showInfobox(source, "info", "Sikeresen kitanultad a könyvet.")
				elseif itemId == 168 then
					triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)
					local skill = split(getElementData(source, "weaponSkill"), ";")
					local szoveg = skill[1]..";"..skill[2]..";"..skill[3]..";"..skill[4]..";"..skill[5]..";"..skill[6]..";"..skill[7]..";999;"..skill[9]..";"..skill[10]..";"..skill[11]
					
					setElementData(source, "weaponSkill", szoveg)
					dbExec(connection, "UPDATE characters SET skills = ? WHERE charID = ?", szoveg, getElementData(source, "char.ID"))
					setPedStat(source, 79, tonumber(skill[8])) -- sniper
					exports.cosmo_hud:showInfobox(source, "info", "Sikeresen kitanultad a könyvet.")
				elseif itemId == 169 then
					triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)
					local skill = split(getElementData(source, "weaponSkill"), ";")
					local szoveg = skill[1]..";"..skill[2]..";"..skill[3]..";"..skill[4]..";"..skill[5]..";"..skill[6]..";"..skill[7]..";"..skill[8]..";999;"..skill[10]..";"..skill[11]
					
					setElementData(source, "weaponSkill", szoveg)
					dbExec(connection, "UPDATE characters SET skills = ? WHERE charID = ?", szoveg, getElementData(source, "char.ID"))
					setPedStat(source, 72, 999) -- shotgun
					exports.cosmo_hud:showInfobox(source, "info", "Sikeresen kitanultad a könyvet.")
				elseif itemId == 170 then
					triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)
					local skill = split(getElementData(source, "weaponSkill"), ";")
					local szoveg = skill[1]..";"..skill[2]..";"..skill[3]..";"..skill[4]..";"..skill[5]..";"..skill[6]..";"..skill[7]..";"..skill[8]..";"..skill[9]..";999;"..skill[11]
					
					setElementData(source, "weaponSkill", szoveg)
					dbExec(connection, "UPDATE characters SET skills = ? WHERE charID = ?", szoveg, getElementData(source, "char.ID"))
					setPedStat(source, 74, 999) -- spas12
					exports.cosmo_hud:showInfobox(source, "info", "Sikeresen kitanultad a könyvet.")
				elseif itemId == 171 then
					triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)
					local skill = split(getElementData(source, "weaponSkill"), ";")
					local szoveg = skill[1]..";"..skill[2]..";"..skill[3]..";"..skill[4]..";"..skill[5]..";"..skill[6]..";"..skill[7]..";"..skill[8]..";"..skill[9]..";"..skill[10]..";999"
					
					setElementData(source, "weaponSkill", szoveg)
					dbExec(connection, "UPDATE characters SET skills = ? WHERE charID = ?", szoveg, getElementData(source, "char.ID"))
					setPedStat(source, 73, 999) -- sawnoff
					exports.cosmo_hud:showInfobox(source, "info", "Sikeresen kitanultad a könyvet.")
				elseif itemId == 177 then -- kicsi
					startPetardaRP(source)
					triggerClientEvent(root, "petardaUse", root, source, "kicsi")
					triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)
				elseif itemId == 178 then -- nagy
					startPetardaRP(source)
					triggerClientEvent(source, "petardaUse", root, source, "nagy")
					triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)
				elseif itemId == 200 then
					if getElementData(source, "fishingRodInHand") then
						setElementData(source, "fishingRodInHand", false)
						triggerClientEvent(source, "updateInUse", source, "player", item.dbID, false)
						exports.cosmo_chat:sendLocalMeAction(source, "elrak egy horgászbotot.")

					if playerItemObjects[source] then
						if isElement(playerItemObjects[source]) then
							if getElementModel(playerItemObjects[source]) == 338 then
								exports.cosmo_boneattach:detachElementFromBone(playerItemObjects[source])
								destroyElement(playerItemObjects[source])
								playerItemObjects[source] = nil
								setElementData(source, "attachedObject", false)
							end
						end
					end
				else
					setElementData(source, "fishingRodInHand", item.dbID)
					triggerClientEvent(source, "updateInUse", source, "player", item.dbID, true)
					exports.cosmo_chat:sendLocalMeAction(source, "elővesz egy horgászbotot.")

					playerItemObjects[source] = createObject(338, 0, 0, 0)

					if isElement(playerItemObjects[source]) then
						setElementInterior(playerItemObjects[source], getElementInterior(source))
						setElementDimension(playerItemObjects[source], getElementDimension(source))
						exports.cosmo_boneattach:attachElementToBone(playerItemObjects[source], source, 12, 0.05, 0.05, 0.05, 0, -90, 0)
						setElementData(source, "attachedObject", playerItemObjects[source])
					end
				end
				-- elseif itemId == 94 then
				-- 	local random1 = math.random(1, 60)
				-- 	local chance = #winterBox/(#winterBox+random1) * 100
					
				-- 	local secondTable = {}

				-- 	chance = (100-chance)
				-- 	for i, v in ipairs(winterBox) do
				-- 		if math.floor(chance) <= v[3] then
				-- 			table.insert(secondTable, v)
				-- 		end
				-- 	end
					
				-- 	local random2 = math.random(1, #secondTable)
				-- 	local winItem = nil
				-- 	for i, v in ipairs(secondTable) do
				-- 		if i == random2 then
				-- 			winItem = v
				-- 		end
				-- 	end
				-- 	triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)
				-- 	addItem(source, winItem[1], 1)
				-- 	outputChatBox(exports.cosmo_core:getServerTag("info") .. "A láda egy #32b3ef"..winItem[2].."-t #ffffffrejtett.", source, 255, 255, 255, true)
            	elseif itemId == 257 then
                    triggerServerEvent("takeItem", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)

                    itemsTable.player[slotId] = nil

                    triggerEvent("showTheRaffle", localPlayer, "day")
					triggerEvent("takeItem", source, source, "dbID", item.dbID, 1)
					addItem(source, winItem[1], 1)
					outputChatBox(exports.cosmo_core:getServerTag("info") .. "A láda egy #32b3ef"..winItem[2].."-t #ffffffrejtett.", source, 255, 255, 255, true)
				elseif isSpecialItem(itemId) then
					if isElement(playerAttachments[source]) then
						destroyElement(playerAttachments[source])
					end

					local animationTime = 0

					if isFoodItem(itemId) then
						animationTime = 3000
						setPedAnimation(source, "food", "eat_burger", animationTime, false, false, false, false)
					elseif isDrinkItem(itemId) then
						animationTime = 1375
						setPedAnimation(source, "VENDING", "VEND_Drink2_P", animationTime, false, false, false, false)
					elseif itemId == 97 or itemId == 98 then
						animationTime = 5000
						setPedAnimation(source, "smoking", "m_smkstnd_loop", animationTime, false, false, false, false)
					elseif itemId == 278 then -- Manóbar

						animationTime = 5000

						setPedAnimation(source, "smoking", "m_smkstnd_loop", animationTime, false, false, false, false)
					end

					setTimer(
						function (player)
							if isElement(player) then
								setPedAnimation(player, false)

								if isElement(playerAttachments[player]) then
									destroyElement(playerAttachments[player])
								end
							end
						end,
					animationTime + 200, 1, source)

					if itemId == 97 or itemId == 98 or itemId == 278 then
						exports.cosmo_chat:sendLocalMeAction(source, "szívott egy slukkot.")
					elseif availableItems[itemId] then
						if isFoodItem(itemId) then
							exports.cosmo_chat:sendLocalMeAction(source, "evett valamiből. ((" .. getItemName(itemId) .. "))")
							local rnd = math.random(5, 10)
							local hunger = getElementData(source, "char.Hunger")
							
							if hunger + rnd >= 100 then
								setElementData(source, "char.Hunger", 100)
							else
								setElementData(source, "char.Hunger", hunger+rnd)
							end
						elseif isDrinkItem(itemId) then
							exports.cosmo_chat:sendLocalMeAction(source, "ivott valamiből. ((" .. getItemName(itemId) .. "))")
							local rnd = math.random(5, 10)
							local Thirst = getElementData(source, "char.Thirst")
							
							if Thirst + rnd >= 100 then
								setElementData(source, "char.Thirst", 100)
							else
								setElementData(source, "char.Thirst", Thirst+rnd)
							end
						end
					elseif isFoodItem(itemId) then
						exports.cosmo_chat:sendLocalMeAction(source, "evett valamiből.")
					elseif isDrinkItem(itemId) then
						exports.cosmo_chat:sendLocalMeAction(source, "ivott valamit.")
					end

					local attachment = false

					if itemId == 45 or itemId == 47 then -- Hamburger/Szendvics
						attachment = availableObjectAttachments[1]
					elseif itemId == 46 or itemId == 48 then -- Hot-Dog/Taco
						attachment = availableObjectAttachments[2]
					elseif (itemId >= 52 and itemId <= 59) or itemId == 70 then -- Dobozos üdítők/Kávé
						attachment = availableObjectAttachments[3]
					elseif itemId >= 60 and itemId <= 63 then -- Ásványvíz/Sörök
						attachment = availableObjectAttachments[4]
					elseif itemId >= 64 and itemId <= 69 then -- Vodka/Whiskey
						attachment = availableObjectAttachments[5]
					elseif itemId == 97 or itemId == 98 then -- Cigaretta
						attachment = availableObjectAttachments[6]	
					elseif itemId == 278 then		
						attachment = availableObjectAttachments[7]	
					end

					if attachment then
						local obj = createObject(attachment.model, 0, 0, 0)
						
						if isElement(obj) then
							setElementInterior(obj, playerInterior)
							setElementDimension(obj, playerDimension)
							setElementCollisionsEnabled(obj, false)
							setElementDoubleSided(obj, true)
							setObjectScale(obj, attachment.scale or 0.75)

							exports.cosmo_boneattach:attachElementToBone(obj, source, unpack(attachment.pos))

							playerAttachments[source] = obj
						end
					end

					if tonumber(item.data3) and isFoodItem(itemId) then
						if math.floor(100 - item.data3 / perishableItems[itemId] * 100) <= 25 then
							triggerClientEvent(source, "rottenEffect", source, item.data3 / (perishableItems[itemId] * 0.75))

							local health = getElementHealth(source) - math.random(3500, 7500) / item.data3

							if health <= 0 then
								health = 0
								setElementData(source, "customDeath", "ételmérgezés")
							end

							setElementHealth(source, health)
						end
					end
				end
			end
		end
	end)

function removeATMCasette(playerElement)
	if isElement(playerElement) then
		local deletedItems = {}
		
		if not itemsTable[playerElement] then
			return
		end
		
		for k, v in pairs(itemsTable[playerElement]) do
			if v.itemId == 181 then
				table.insert(deletedItems, v.dbID)
				itemsTable[playerElement][v.slot] = nil
			end
		end
		
		if #deletedItems > 0 then
			dbExec(connection, "DELETE FROM items WHERE dbID IN (" .. table.concat(deletedItems, ",") .. ")")
			triggerItemEvent(playerElement, "deleteItem", "player", deletedItems)
		end
	end
end

function removeShopCasette(playerElement)
	if isElement(playerElement) then
		local deletedItems = {}
		
		if not itemsTable[playerElement] then
			return
		end
		
		for k, v in pairs(itemsTable[playerElement]) do
			if v.itemId == 244 then
				table.insert(deletedItems, v.dbID)
				itemsTable[playerElement][v.slot] = nil
			end
		end
		
		if #deletedItems > 0 then
			dbExec(connection, "DELETE FROM items WHERE dbID IN (" .. table.concat(deletedItems, ",") .. ")")
			triggerItemEvent(playerElement, "deleteItem", "player", deletedItems)
		end
	end
end

function removePlayerDutyItems(playerElement)
	if isElement(playerElement) then
		local deletedItems = {}

		if not itemsTable[playerElement] then
			return
		end

		for k, v in pairs(itemsTable[playerElement]) do
			if v.data3 == "duty" and v.itemId ~= 86 then -- ha duty item, de nem jelvény (jelvényt off-dutyban is lehessen használni)
				table.insert(deletedItems, v.dbID)
				itemsTable[playerElement][v.slot] = nil
				delAttachWeapon(playerElement, v.itemId, v.dbID)
			end
		end

		if #deletedItems > 0 then
			dbExec(connection, "DELETE FROM items WHERE dbID IN (" .. table.concat(deletedItems, ",") .. ")")

			triggerItemEvent(playerElement, "deleteItem", "player", deletedItems)
		end
	end
end

function removeAllItem(sourceElement, dataType, data)
	if sourceElement then
		local elementType = getElementType(sourceElement)
		local dbID = getElementDatabaseId(sourceElement)

		if dbID and itemsTable[sourceElement] then
			local deletedItems = {}

			for k, v in pairs(itemsTable[sourceElement]) do
				if (tonumber(v[dataType]) or v[dataType]) == data then
					table.insert(deletedItems, v.dbID)
					itemsTable[sourceElement][v.slot] = nil
				end
			end

			if #deletedItems > 0 then
				triggerItemEvent(sourceElement, "deleteItem", elementType, deletedItems)
			end
		end
	end

	return false
end

function removeItemByData(sourceElement, itemId, dataType, data)
	if sourceElement then
		local elementType = getElementType(sourceElement)
		local dbID = getElementDatabaseId(sourceElement)

		if dbID and itemsTable[sourceElement] then
			local deletedItems = {}

			for k, v in pairs(itemsTable[sourceElement]) do
				if v.itemId == itemId and (tonumber(v[dataType]) or v[dataType]) == data then
					table.insert(deletedItems, v.dbID)
					itemsTable[sourceElement][v.slot] = nil
				end
			end

			if #deletedItems > 0 then
				dbExec(connection, "DELETE FROM items WHERE dbID IN (" .. table.concat(deletedItems, ",") .. ")")

				triggerItemEvent(sourceElement, "deleteItem", elementType, deletedItems)

				exports.cosmo_logs:logItemAction(sourceElement, itemId, false, " removeItemByData")
			end
			
			return true
		end
	end
	
	return false
end

function removeItemFromCharacter(characterId, itemId, dataType, data)
	if characterId and itemId and dataType and data then
		dbExec(connection, "DELETE FROM items WHERE itemId = ? AND ?? = ? AND ownerId = ? AND ownerType = 'player'", tonumber(itemId), dataType, data, characterId)

		local playerElement = exports.cosmo_accounts:getPlayerFromCharacterID(characterId)
		local deletedItems = {}

		if itemsTable[playerElement] then
			for k, v in pairs(itemsTable[playerElement]) do
				if v.itemId == itemId and (tonumber(v[dataType]) or v[dataType]) == data then
					table.insert(deletedItems, v.dbID)
					itemsTable[playerElement][v.slot] = nil
				end
			end
		else
			print("playerSource with characterId [" .. characterId .. "] not assigned.", playerElement)
		end

		if #deletedItems > 0 then
			if isElement(playerElement) then
				triggerItemEvent(playerElement, "deleteItem", "player", deletedItems)

				exports.cosmo_logs:logItemAction(playerElement, itemId, false, " removeItemFromCharacter")
			end
		end

		return true
	end

	return false
end

addEvent("takeItem", true)
addEventHandler("takeItem", getRootElement(),
	function(sourceElement, itemKey, itemValue, amount)
		if isElement(source) then
			if isElement(sourceElement) then
				if itemKey and itemValue then
					amount = tonumber(amount)

					local deletedItems = {}

					for k, v in pairs(itemsTable[sourceElement]) do
						if v[itemKey] and v[itemKey] == itemValue then
							if amount and itemsTable[sourceElement][v.slot].amount - amount > 0 then
								itemsTable[sourceElement][v.slot].amount = itemsTable[sourceElement][v.slot].amount - amount

								dbExec(connection, "UPDATE items SET amount = ? WHERE ?? = ?", itemsTable[sourceElement][v.slot].amount, itemKey, itemValue)

								triggerItemEvent(sourceElement, "updateItemAmount", getElementType(sourceElement), v.dbID, itemsTable[sourceElement][v.slot].amount)

								exports.cosmo_logs:logItemAction(sourceElement, itemsTable[sourceElement][v.slot].itemId, itemsTable[sourceElement][v.slot].amount, " updateAmount")
							else
								exports.cosmo_logs:logItemAction(sourceElement, itemsTable[sourceElement][v.slot].itemId, amount, " takeItem")

								table.insert(deletedItems, itemsTable[sourceElement][v.slot].dbID)
								
								if weaponModels[itemsTable[sourceElement][v.slot].itemId] then
									delAttachWeapon(sourceElement, itemsTable[sourceElement][v.slot].itemId, itemsTable[sourceElement][v.slot].dbID)
								end

								itemsTable[sourceElement][v.slot] = nil
							end
						end
					end

					if #deletedItems > 0 then
						dbExec(connection, "DELETE FROM items WHERE dbID IN (" .. table.concat(deletedItems, ",") .. ")")

						triggerItemEvent(sourceElement, "deleteItem", getElementType(sourceElement), deletedItems)
					end
				end
			end
		end
	end)

addEvent("updateItemData3", true)
addEventHandler("updateItemData3", getRootElement(),
	function(sourceElement, dbID, newData, sync)
		if isElement(sourceElement) then
			dbID = tonumber(dbID)

			if dbID and newData then
				for k, v in pairs(itemsTable[sourceElement]) do
					if v.dbID == dbID then
						itemsTable[sourceElement][v.slot].data3 = newData
						dbExec(connection, "UPDATE items SET data3 = ? WHERE dbID = ?", newData, dbID)

						if sync then
							if getElementType(source) ~= "player" then
								triggerItemEvent(sourceElement, "loadItems", itemsTable[sourceElement], getElementType(source))
							end
						end

						break
					end
				end
			end
		end
	end)

addEvent("updateItemData2", true)
addEventHandler("updateItemData2", getRootElement(),
	function(sourceElement, dbID, newData, sync)
		if isElement(sourceElement) then
			dbID = tonumber(dbID)

			if dbID and newData then
				for k, v in pairs(itemsTable[sourceElement]) do
					if v.dbID == dbID then
						itemsTable[sourceElement][v.slot].data2 = newData
						dbExec(connection, "UPDATE items SET data2 = ? WHERE dbID = ?", newData, dbID)

						if sync then
							if getElementType(source) ~= "player" then
								triggerItemEvent(sourceElement, "loadItems", itemsTable[sourceElement], getElementType(source))
							end
						end

						break
					end
				end
			end
		end
	end)

addEvent("updateItemData1", true)
addEventHandler("updateItemData1", getRootElement(),
	function(sourceElement, dbID, newData, sync)
		if isElement(sourceElement) then
			dbID = tonumber(dbID)

			if dbID and newData then
				for k, v in pairs(itemsTable[sourceElement]) do
					if v.dbID == dbID then
						itemsTable[sourceElement][v.slot].data1 = newData
						dbExec(connection, "UPDATE items SET data1 = ? WHERE dbID = ?", newData, dbID)

						if sync then
							if getElementType(source) ~= "player" then
								triggerItemEvent(sourceElement, "loadItems", itemsTable[sourceElement], getElementType(source))
							end
						end

						break
					end
				end
			end
		end
	end)
	
addCommandHandler("addfigyu", function(player, cmd, target, weaponID)
	if exports.cosmo_groups:isPlayerHavePermission(player, "weaponWarn") then
		if not (target and weaponID) then
			outputChatBox(exports.cosmo_core:getServerTag("usage") .. "/" .. cmd .. " [Játékos név / ID] [Fegyver sorozatszám(CSAK A SZÁMOT ADD MEG)]", player, 255, 255, 255, true)	
		else
			weaponID = tonumber(weaponID)
			
			if weaponID then
				target = exports.cosmo_core:findPlayer(player, target)
				
				if target then
					for k, v in pairs(itemsTable[target]) do
						if v.dbID == weaponID then
							theItem = v
							break
						end
					end	
					local a = theItem.data3 or 0
					a = a + 1
					outputChatBox(exports.cosmo_core:getServerTag("info") .. "Adtál a #d75959"..weaponID.." #ffffffidéjű fegyverre egy figyut.", player, 255, 255, 255, true)
					triggerClientEvent(target, "updateItemData3", target, "player", theItem.dbID, a, true)
				end
			end	
		end
	end
end)

-- Adatbázis lekérések optimalizálásához

addEvent("updateItemAmount", true)
addEventHandler("updateItemAmount", getRootElement(),
	function(sourceElement, dbID, newAmount)
		if isElement(source) then
			if isElement(sourceElement) then
				dbID = tonumber(dbID)
				newAmount = tonumber(newAmount)

				if dbID and newAmount then
					for k, v in pairs(itemsTable[sourceElement]) do
						if v.dbID == dbID then
							itemsTable[sourceElement][v.slot].amount = newAmount
							dbExec(connection, "UPDATE items SET amount = ? WHERE dbID = ?", newAmount, dbID)
							break
						end
					end
				end
			end
		end
	end)

	addEvent("moveItem", true)
	addEventHandler("moveItem", getRootElement(),
		function(dbID, itemId, sourceSlot, targetSlot, stackAmount, sourceElement, targetElement)
			if isElement(source) then
				dbID = tonumber(dbID)
	
				if dbID then
					local sourceType = getElementType(sourceElement)
					local sourceDbId = getElementDatabaseId(sourceElement)
	
					-- mozgatás/stackelés a megnyitott inventoryban
					if sourceElement == targetElement then
						if itemsTable[sourceElement][sourceSlot] and dbID == itemsTable[sourceElement][sourceSlot].dbID then
							if not itemsTable[sourceElement][targetSlot] then
								-- mozgatás
								if stackAmount >= itemsTable[sourceElement][sourceSlot].amount or stackAmount <= 0 then
									dbExec(connection, "UPDATE items SET ownerType = ?, ownerId = ?, slot = ? WHERE dbID = ?", sourceType, sourceDbId, targetSlot, dbID)
	
									itemsTable[sourceElement][targetSlot] = itemsTable[sourceElement][sourceSlot]
									itemsTable[sourceElement][targetSlot].slot = targetSlot
									itemsTable[sourceElement][sourceSlot] = nil
									
									if sourceType == "player" and getElementType(targetElement) == "player" then
										triggerClientEvent(source, "movedItemInInventory", source, true)
									end
								-- stackelés
								elseif stackAmount > 0 then
									itemsTable[sourceElement][sourceSlot].amount = itemsTable[sourceElement][sourceSlot].amount - stackAmount
	
									dbExec(connection, "UPDATE items SET amount = ? WHERE dbID = ?", itemsTable[sourceElement][sourceSlot].amount, dbID)
	
									addItem(sourceElement, itemId, stackAmount, targetSlot, itemsTable[sourceElement][sourceSlot].data1, itemsTable[sourceElement][sourceSlot].data2, itemsTable[sourceElement][sourceSlot].data3, itemsTable[sourceElement][sourceSlot].nameTag)
								end
							else
								outputChatBox(exports.cosmo_core:getServerTag("info") .. "A kiválasztott slot foglalt.", source, 255, 255, 255, true)
	
								triggerClientEvent(source, "failedToMoveItem", source, targetSlot, sourceSlot, stackAmount)
							end
						end
					-- átmozgatás egy másik inventoryba
					else
						local targetType = getElementType(targetElement)
						local targetDbId = getElementDatabaseId(targetElement)
						local canTransfer = true
						if targetType == "vehicle" and isVehicleLocked(targetElement) then
							canTransfer = false
							exports.cosmo_hud:showInfobox(source, "error", "A kiválasztott jármű csomagtartója zárva van.")
						end
	
						if canTransfer then
							if itemsTable[sourceElement][sourceSlot] and dbID == itemsTable[sourceElement][sourceSlot].dbID then
								if not itemsTable[targetElement] then
									itemsTable[targetElement] = {}
								end
	
								targetSlot = findEmptySlot(targetElement, itemId)
	
								if targetSlot then
									local statement = false
	
									if stackAmount >= itemsTable[sourceElement][sourceSlot].amount or stackAmount <= 0 then
										statement = "move"
										stackAmount = itemsTable[sourceElement][sourceSlot].amount
									elseif stackAmount > 0 then
										statement = "split"
									end
	
									if getInventoryWeight(targetElement) + (getItemWeight(itemId) * stackAmount) < getWeightLimit(targetType, targetElement) then
										if statement == "move" then
											dbExec(connection, "UPDATE items SET ownerType = ?, ownerId = ?, slot = ? WHERE dbID = ?", targetType, targetDbId, targetSlot, dbID)
	
											itemsTable[targetElement][targetSlot] = itemsTable[sourceElement][sourceSlot]
											itemsTable[targetElement][targetSlot].slot = targetSlot
											itemsTable[sourceElement][sourceSlot] = nil
	
											triggerItemEvent(targetElement, "addItem", targetType, itemsTable[targetElement][targetSlot])
											triggerItemEvent(sourceElement, "deleteItem", sourceType, {dbID})
					
											if weaponModels[itemId] and targetType == "object" and sourceType == "player" then
												delAttachWeapon(sourceElement, itemId, dbID)
												--attachWeapon(targetElement, itemId, dbID)
											elseif weaponModels[itemId] and targetType == "vehicle" and sourceType == "player" then
												delAttachWeapon(sourceElement, itemId, dbID)
											elseif weaponModels[itemId] and sourceType == "object" and targetType == "player" then
												attachWeapon(targetElement, itemId, dbID)
											elseif weaponModels[itemId] and sourceType == "player" and targetType == "player" then
												delAttachWeapon(sourceElement, itemId, dbID)
												attachWeapon(targetElement, itemId, dbID)											
											end
											exports.cosmo_logs:logItemAction(source, itemId, stackAmount, "moveItem:move")
										elseif statement == "split" then
											dbExec(connection, "UPDATE items SET amount = ? WHERE dbID = ?", itemsTable[sourceElement][sourceSlot].amount - stackAmount, dbID)
	
											itemsTable[sourceElement][sourceSlot].amount = itemsTable[sourceElement][sourceSlot].amount - stackAmount
	
											addItem(targetElement, itemId, stackAmount, targetSlot, itemsTable[sourceElement][sourceSlot].data1, itemsTable[sourceElement][sourceSlot].data2, itemsTable[sourceElement][sourceSlot].data3, itemsTable[sourceElement][sourceSlot].nameTag)
	
											triggerItemEvent(sourceElement, "updateItemAmount", sourceType, dbID, itemsTable[sourceElement][sourceSlot].amount)
	
											exports.cosmo_logs:logItemAction(source, itemId, stackAmount, "moveItem:split")
										end
	
										transferItemMessage(itemsTable[targetElement][targetSlot], sourceElement, targetElement, sourceType, targetType)
									else
										exports.cosmo_hud:showInfobox(source, "error", "A kiválasztott inventory nem bír el több tárgyat!")
									end
								else
									exports.cosmo_hud:showInfobox(source, "error", "Nincs szabad slot a kiválasztott inventoryban!")
								end
							end
						end
	
						triggerClientEvent(source, "unLockItem", source, sourceType, sourceSlot)
					end
				end
			end
		end)

function transferItemMessage(item, fromElement, toElement, fromElementType, toElementType)
	local itemName = ""

	if availableItems[item.itemId] then
		itemName = " (" .. getItemName(item.itemId) .. ")"
	end

	if fromElementType == "player" and toElementType == "player" then
		exports.cosmo_dclog:sendDiscordMessage("**"..getElementData(fromElement, "visibleName"):gsub("_", " ").. "** átadott egy tárgyat **" .. getElementData(toElement, "visibleName"):gsub("_", " ") .. "**-nak/nek. **" ..itemName.. "**", "itemlog")
		exports.cosmo_chat:sendLocalMeAction(fromElement, "átadott egy tárgyat " .. getElementData(toElement, "visibleName"):gsub("_", " ") .. "-nak/nek." .. itemName)
		-- exports.atadaslog:sendDiscordMessage(getPlayerName(source) .." átadott egy tárgyat ".. getElementData(toElement, "visibleName"):gsub("_", " ") .."-nak/nek. ".. itemName .."")

		setPedAnimation(fromElement, "DEALER", "DEALER_DEAL", 3000, false, false, false, false)
		setPedAnimation(toElement, "DEALER", "DEALER_DEAL", 3000, false, false, false, false)
	elseif fromElementType == "player" and toElementType == "vehicle" then
		exports.cosmo_dclog:sendDiscordMessage("**"..getElementData(fromElement, "visibleName"):gsub("_", " ").. "** berakott egy tárgyat a jármű csomagtartójába. **"..itemName.."**", "itemlog")
		exports.cosmo_chat:sendLocalMeAction(fromElement, "berakott egy tárgyat a jármű csomagtartójába." .. itemName)
		-- exports.csomilog:sendDiscordMessage(getPlayerName(source) .." berakott egy tárgyat a jármű csomagtartójába. ".. itemName .."")
		
		local visibleName = getElementData(fromElement, "visibleName"):gsub("_", " ")
		local text = visibleName.." berakott egy tárgyat a jármű csomagtartójába." .. itemName	
			
		--dbExec(connection, "INSERT INTO VehicleLog (dbID, action, time, type) VALUES(?, ?, NOW(), 2)", getElementData(toElement, "vehicle.dbID"), text)
	elseif fromElementType == "player" and toElementType == "object" then
		exports.cosmo_dclog:sendDiscordMessage("**"..getElementData(fromElement, "visibleName"):gsub("_", " ").. "** berakott egy tárgyat a széfbe. **" ..itemName.."**", "itemlog")
		exports.cosmo_chat:sendLocalMeAction(fromElement, "berakott egy tárgyat a széfbe." .. itemName)
		-- exports.szeflog:sendDiscordMessage(getPlayerName(source) .." berakott egy tárgyat a széfbe. ".. itemName .."")
	elseif fromElementType == "vehicle" then
		exports.cosmo_dclog:sendDiscordMessage("**"..getElementData(toElement, "visibleName"):gsub("_", " ").. "** kivett egy tárgyat a jármű csomagtartójából. **" ..itemName.."**", "itemlog")
		exports.cosmo_chat:sendLocalMeAction(toElement, "kivett egy tárgyat a jármű csomagtartójából." .. itemName)
		-- exports.csomilog:sendDiscordMessage(getPlayerName(source) .." kivett egy tárgyat a jármű csomagtartójából. ".. itemName .."")
		
		local visibleName = getElementData(toElement, "visibleName"):gsub("_", " ")
		local text = visibleName.." kivett egy tárgyat a jármű csomagtartójából." .. itemName	
			
		--d-bExec(connection, "INSERT INTO VehicleLog (dbID, action, time, type) VALUES(?, ?, NOW(), 2)", getElementData(fromElement, "vehicle.dbID"), text)
	elseif fromElementType == "object" then
		exports.cosmo_dclog:sendDiscordMessage("**"..getElementData(toElement, "visibleName"):gsub("_", " ").. "** kivett egy tárgyat a széfből. **"..itemName.."**", "itemlog")
		exports.cosmo_chat:sendLocalMeAction(toElement, "kivett egy tárgyat a széfből." .. itemName)
		-- exports.szeflog:sendDiscordMessage(getPlayerName(source) .." kivett egy tárgyat a széfből. ".. itemName .."")
	end
end

function countItemsByItemID(sourceElement, itemId, countAmount)
	local x = 0

	if itemsTable[sourceElement] then
		for k, v in pairs(itemsTable[sourceElement]) do
			if v.itemId == itemId then
				if countAmount then
					x = x + v.amount
				else
					x = x + 1
				end
			end
		end
	end
	
	return x
end

function getDBIdFromData1(player, data)
	if itemsTable[player] then
		for k, v in pairs(itemsTable[player]) do
			if tostring(v.data1) == tostring(data) then
				return v.dbID
			end
		end
	end
end

function hasItemWithData(sourceElement, itemId, dataType, data)
	if itemsTable[sourceElement] then
		data = tonumber(data) or data

		for k, v in pairs(itemsTable[sourceElement]) do
			if v.itemId == itemId and  (tonumber(v[dataType]) or v[dataType]) == data then
				return v
			end
		end
	end

	return false
end

function hasItem(sourceElement, itemId)
	if itemsTable[sourceElement] then
		for k, v in pairs(itemsTable[sourceElement]) do
			if v.itemId == itemId then
				return v
			end
		end
	end

	return false
end

addEvent("closeInventory", true)
addEventHandler("closeInventory", getRootElement(),
	function(sourceElement, streamedPlayers)
		if isElement(sourceElement) then
			inventoryInUse[sourceElement] = nil
			
			if getElementType(sourceElement) == "vehicle" then
				setVehicleDoorOpenRatio(sourceElement, 1, 0, 350)
			end
		end
	end)

addEvent("requestItems", true)
addEventHandler("requestItems", getRootElement(),
	function(sourceElement, ownerId, ownerType, streamedPlayers)
		if isElement(source) then
			local gotRequest = true

			if ownerType == "vehicle" and isVehicleLocked(sourceElement) then
				gotRequest = false
			end

			if not gotRequest then
				exports.cosmo_hud:showInfobox(source, "error", "A kiválasztott inventory zárva van, esetleg nincs kulcsod hozzá.")
				return
			end

			if isElement(inventoryInUse[sourceElement]) then
				exports.cosmo_hud:showInfobox(source, "error", "A kiválasztott inventory már használatban van!")
				return
			end

			inventoryInUse[sourceElement] = source

			if itemsTable[sourceElement] then
				triggerClientEvent(source, "loadItems", source, itemsTable[sourceElement], ownerType, sourceElement, true)
			else
				loadItems(sourceElement, ownerId)
			end

			if ownerType == "vehicle" then
				setVehicleDoorOpenRatio(sourceElement, 1, 1, 500)

				exports.cosmo_chat:sendLocalMeAction(source, "belenézett egy jármű csomagtartójába.")
			elseif ownerType == "object" then
				exports.cosmo_chat:sendLocalMeAction(source, "belenézett egy széfbe.")
			end
		end
	end)

function triggerItemEvent(sourceElement, eventName, ...)
	local sourcePlayer = sourceElement

	if getElementType(sourceElement) == "player" then
		triggerClientEvent(sourceElement, eventName, sourceElement, ...)
	elseif isElement(inventoryInUse[sourceElement]) then
		sourcePlayer = inventoryInUse[sourceElement]

		triggerClientEvent(inventoryInUse[sourceElement], eventName, inventoryInUse[sourceElement], ...)
	end

	if eventName == "addItem" or eventName == "deleteItem" or eventName == "updateItemAmount" then
		if isElement(sourcePlayer) and getElementType(sourceElement) == "player" then
			triggerClientEvent(sourcePlayer, "movedItemInInventory", sourcePlayer, eventName ~= "updateItemAmount")
		end
	end
end

function loadItems(sourceElement, ownerId)
	if isElement(sourceElement) then
		local ownerType = getElementType(sourceElement)

		--[[for k, v in pairs(itemsTable) do
			iprint(v[1])
		end]]
			
		if itemsTable[sourceElement] then
			
			if ownerType == "player" then
				triggerClientEvent(sourceElement, "loadItems", sourceElement, itemsTable[sourceElement], ownerType)
			elseif isElement(inventoryInUse[sourceElement]) then
				triggerClientEvent(inventoryInUse[sourceElement], "loadItems", inventoryInUse[sourceElement], itemsTable[sourceElement], ownerType, sourceElement, true)
			end

			--outputDebugString("Request items cache from - " .. tostring(sourceElement))
		else
			itemsTable[sourceElement] = {}

			--outputDebugString("Request items from - " .. tostring(sourceElement))

			dbQuery(
				function (query, sourceElement)
					local result = dbPoll(query, 0)

					if isElement(sourceElement) then
						local lost, restored = 0, 0

						for k, v in pairs(result) do
							if not itemsTable[sourceElement][v.slot] then
								addItemEx(sourceElement, v.dbID, v.slot, v.itemId, v.amount, v.data1, v.data2, v.data3, v.nameTag)
								if weaponModels[v.itemId] and v.ownerType == "player" then
									attachWeapon(sourceElement, v.itemId, v.dbID)
								end
							else
								local emptySlot = findEmptySlot(sourceElement, v.itemId)

								if emptySlot then
									addItemEx(sourceElement, v.dbID, emptySlot, v.itemId, v.amount, v.data1, v.data2, v.data3, v.nameTag)

									dbExec(connection, "UPDATE items SET slot = ? WHERE dbID = ?", emptySlot, v.dbID)
									
									restored = restored + 1
								end

								lost = lost + 1
							end
						end

						if ownerType == "player" then
							triggerClientEvent(sourceElement, "loadItems", sourceElement, itemsTable[sourceElement], ownerType)
							
							if lost > 0 then
								outputChatBox(exports.cosmo_core:getServerTag("info") .. "#fc1414" .. lost .. " #ffffffdarab elveszett tárggyal rendelkezel.", sourceElement, 255, 255, 255, true)
								
								if restored > 0 then
									outputChatBox(exports.cosmo_core:getServerTag("info") .. "Ebből #fc1414" .. restored .. " #ffffffdarab lett visszaállítva.", sourceElement, 255, 255, 255, true)
								end
								
								if lost - restored > 0 then
									outputChatBox(exports.cosmo_core:getServerTag("info") .. "Nem sikerült visszaállítani #fc1414" .. lost - restored .. " #ffffffdarab tárgyad, mert nincs szabad slot az inventorydban.", sourceElement, 255, 255, 255, true)
									outputChatBox(exports.cosmo_core:getServerTag("info") .. "A következő bejelentkezésedkor ismét megpróbáljuk.", sourceElement, 255, 255, 255, true)
								end

								if lost == restored then
									outputChatBox(exports.cosmo_core:getServerTag("info") .. "Az összes hibás tárgyadat sikeresen visszaállítottuk. Kellemes játékot kívánunk! :).", sourceElement, 255, 255, 255, true)
								end
							end
						elseif isElement(inventoryInUse[sourceElement]) then
							triggerClientEvent(inventoryInUse[sourceElement], "loadItems", inventoryInUse[sourceElement], itemsTable[sourceElement], ownerType, sourceElement, true)
						end
					end
				end, {sourceElement}, connection, "SELECT * FROM items WHERE ownerId = ? AND ownerType = ? ORDER BY slot", ownerId, ownerType
			)
		end
	end
end

addEvent("requestCache", true)
addEventHandler("requestCache", getRootElement(),
	function()
		if isElement(source) then
			local ownerId = getElementDatabaseId(source)

			if tonumber(ownerId) then
				loadItems(source, ownerId)
			end
		end
	end)

function getInventoryItemsCount(sourceElement)
	local items = 0

	if itemsTable[sourceElement] then
		for k, v in pairs(itemsTable[sourceElement]) do
			items = items + 1
		end
	end

	return items
end

function getInventoryWeight(sourceElement)
	local weight = 0

	if itemsTable[sourceElement] then
		for k, v in pairs(itemsTable[sourceElement]) do
			weight = weight + getItemWeight(v.itemId) * v.amount
		end
	end

	return weight
end

function findEmptySlot(sourceElement, itemId)
	if getElementType(sourceElement) == "player" and isKeyItem(itemId) then
		return findEmptySlotOfKeys(sourceElement)
	elseif getElementType(sourceElement) == "player" and isPaperItem(itemId) then
		return findEmptySlotOfPapers(sourceElement)
	else
		local emptySlot = false

		for i = 0, defaultSettings.slotLimit - 1 do
			if not itemsTable[sourceElement][i] then
				emptySlot = tonumber(i)
				break
			end
		end

		if emptySlot then
			if emptySlot <= defaultSettings.slotLimit then
				return emptySlot
			else
				return false
			end
		else
			return false
		end
	end
end

function findEmptySlotOfKeys(sourceElement)
	local emptySlot = false

	for i = defaultSettings.slotLimit, defaultSettings.slotLimit * 2 - 1 do
		if not itemsTable[sourceElement][i] then
			emptySlot = tonumber(i)
			break
		end
	end

	if emptySlot then
		if emptySlot <= defaultSettings.slotLimit * 2 then
			return emptySlot
		else
			return false
		end
	else
		return false
	end
end

function findEmptySlotOfPapers(sourceElement)
	local emptySlot = false

	for i = defaultSettings.slotLimit * 2, defaultSettings.slotLimit * 3 - 1 do
		if not itemsTable[sourceElement][i] then
			emptySlot = tonumber(i)
			break
		end
	end

	if emptySlot then
		if emptySlot <= defaultSettings.slotLimit * 3 then
			return emptySlot
		else
			return false
		end
	else
		return false
	end
end

function addItemEx(sourceElement, dbID, slot, itemId, amount, data1, data2, data3, nameTag)
	itemsTable[sourceElement][slot] = {}
	itemsTable[sourceElement][slot].dbID = dbID
	itemsTable[sourceElement][slot].slot = slot
	itemsTable[sourceElement][slot].itemId = itemId
	itemsTable[sourceElement][slot].amount = amount
	itemsTable[sourceElement][slot].data1 = data1
	itemsTable[sourceElement][slot].data2 = data2
	itemsTable[sourceElement][slot].data3 = data3
	itemsTable[sourceElement][slot].inUse = false
	itemsTable[sourceElement][slot].locked = false
	itemsTable[sourceElement][slot].nameTag = nameTag or nil
end

function giveItem(sourceElement, itemId, amount, data1, data2, data3, nameTag)
	addItem(sourceElement, itemId, amount, false, data1, data2, data3, nameTag)
end

function addItem(sourceElement, itemId, amount, slotId, data1, data2, data3, nameTag)
	if isElement(sourceElement) and itemId and amount then
		itemId = tonumber(itemId)
		amount = tonumber(amount)

		if not itemsTable[sourceElement] then
			itemsTable[sourceElement] = {}
		end

		if not slotId then
			slotId = findEmptySlot(sourceElement, itemId)
		elseif tonumber(slotId) then
			if itemsTable[sourceElement][slotId] then
				slotId = findEmptySlot(sourceElement, itemId)
			end
		end

		if slotId then
			local ownerType = getElementType(sourceElement)
			local ownerId = getElementDatabaseId(sourceElement)

			if tonumber(ownerId) then
				itemsTable[sourceElement][slotId] = {}
				itemsTable[sourceElement][slotId].locked = true

				dbQuery(
					function (qh, sourceElement)
						if isElement(sourceElement) then
							local result = dbPoll(qh, 0, true)[2][1][1]

							if result then
								addItemEx(sourceElement, result.dbID, result.slot, result.itemId, result.amount, result.data1, result.data2, result.data3, result.nameTag)

								triggerItemEvent(sourceElement, "addItem", getElementType(sourceElement), result)
								attachWeapon(sourceElement, result.itemId, result.dbID)
							end
						end
					end, {sourceElement}, connection, "INSERT INTO items (itemId, slot, amount, data1, data2, data3, ownerType, ownerId, nameTag) VALUES (?,?,?,?,?,?,?,?,?); SELECT * FROM items ORDER BY dbID DESC LIMIT 1", itemId, slotId, amount, data1, data2, data3, ownerType, ownerId, nameTag
				)

				return true
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end
addEvent("addItem", true)
addEventHandler("addItem", getRootElement(), addItem)

function hideAttachedItems(player, state)
	if state == "off" then
		if weaponAttachments[player] then
			for k, v in pairs(weaponAttachments[player]) do
				if isElement(v) then
					setElementAlpha(v, 0)
				end
			end
		end	
	else
		if weaponAttachments[player] then
			for k, v in pairs(weaponAttachments[player]) do
				if isElement(v) then
					setElementAlpha(v, 255)
				end
			end
		end	
	end
end

function fixVehicleWithCard(veh)
	fixVehicle(veh)
	setVehicleDamageProof(veh, false)
end
addEvent("fixVehicleWithCard", true)
addEventHandler("fixVehicleWithCard", root, fixVehicleWithCard)

function setPlayerAlpha(player)
	setElementAlpha(player,150)
	setTimer(function()
		setElementAlpha(player,255)
	end, 15000, 1)
end
addEvent("setPlayerAlpha", true)
addEventHandler("setPlayerAlpha", root, setPlayerAlpha)

function fuelVehicleWithCard(veh)
	local fuelTankSize = exports.cosmo_hud:getTheFuelTankSizeOfVehicle(getElementModel(veh))
	setElementData(veh, "vehicle.fuel", tonumber(fuelTankSize))
end
addEvent("fuelVehicleWithCard", true)
addEventHandler("fuelVehicleWithCard", root, fuelVehicleWithCard)

function healPlayerCard(player, type)
	if type == "dead" then
		local playerPosX, playerPosY, playerPosZ = getElementPosition(player)
		local playerInterior = getElementInterior(player)
		local playerDimension = getElementDimension(player)
		local playerSkin = getElementModel(player)

		spawnPlayer(player, playerPosX, playerPosY, playerPosZ, getPedRotation(player), playerSkin, playerInterior, playerDimension)
	
		healPlayer(player)
		setPedAnimation(player)
		setCameraTarget(player, player)	
	elseif type == "knock" then
		healPlayer(player)
		setPedAnimation(player)
		setCameraTarget(player, player)
	end
end
addEvent("healPlayerCard", true)
addEventHandler("healPlayerCard", root, healPlayerCard)

function csokiuse(player, type)
	local HP = getElementHealth(player) + math.random(25, 50)
	local ARMOR = getPedArmor(player) + math.random(10, 25)
	setPedArmor(player, ARMOR)
	setElementHealth(player, HP)
end
addEvent("csokiuse", true)
addEventHandler("csokiuse", root, csokiuse)

function zapuse(player, type)
	local HP = getElementHealth(player) - math.random(5, 15)
	setElementHealth(player, HP)
end
addEvent("zapuse", true)
addEventHandler("zapuse", root, zapuse)

function healPlayer(playerElement)
	if isElement(playerElement) then
		setElementHealth(playerElement, 100)
		setElementData(playerElement, "isPlayerDeath", false)
		setElementData(playerElement, "bulletDamages", false)
		--setElementData(playerElement, "boneDamages", false)
		setElementData(playerElement, "bloodLevel", 100)
		setElementData(playerElement, "deathReason", false)
		setElementData(playerElement, "customDeath", false)
	end
end

function startPetardaRP(player)
	exports.cosmo_chat:sendLocalMeAction(player, "meggyújtja a petárdát.")
	setTimer(function()
		exports.cosmo_chat:sendLocalMeAction(player, "eldobja a petárdát kicsit messzebb tőle.")
		setTimer(function()
			exports.cosmo_chat:sendLocalDoAction(player, "Petárda sistergés.")
			setTimer(function()
				exports.cosmo_chat:sendLocalDoAction(player, "Petárda robbanás.")
			end, 1000, 1)
		end, 1000, 1)
	end, 1000, 1)
end

addEvent("sirenInServer", true)
addEventHandler("sirenInServer", getRootElement(), function(player, vehicle, state)
	if state == "create" then
		local vx, vy, vz = getElementPosition(vehicle)
		local siren = createObject(1253, vx, vy, vz)
		local posx, posy, posz, rotx, roty, rotz = sirenPos[getElementModel(vehicle)][1],sirenPos[getElementModel(vehicle)][2],sirenPos[getElementModel(vehicle)][3],sirenPos[getElementModel(vehicle)][4],sirenPos[getElementModel(vehicle)][5],sirenPos[getElementModel(vehicle)][6]
		
		attachElements(siren, vehicle, posx, posy, posz, rotx, roty, rotz)
		setElementCollisionsEnabled(siren, false)
		
		setElementData(vehicle, "sirenObject", siren)
        setElementData(vehicle, "sirenInVeh", true)
		setElementData(player, "isSirenVehicle", {vehicle, siren})
		setElementData(player, "sirenInVehicle", true)
		createSirens(vehicle, true)
	elseif state == "destroy" then
		if isElement(getElementData(vehicle,"sirenObject")) then
			destroyElement(getElementData(vehicle,"sirenObject"))
		end
		createSirens(vehicle, false)
        setElementData(vehicle, "sirenInVeh", false)
		setElementData(player, "isSirenVehicle", nil)
		setElementData(player, "sirenInVehicle", false)
	end
end)

addEvent("taxiInServer", true)
addEventHandler("taxiInServer", getRootElement(), function(player, vehicle, state)
	if state == "create" then
		local vx, vy, vz = getElementPosition(vehicle)
		local taxi = createObject(4054, vx, vy, vz)
		local posx, posy, posz, rotx, roty, rotz = sirenPos[getElementModel(vehicle)][1],sirenPos[getElementModel(vehicle)][2],sirenPos[getElementModel(vehicle)][3]-0.07,sirenPos[getElementModel(vehicle)][4],sirenPos[getElementModel(vehicle)][5],sirenPos[getElementModel(vehicle)][6]
		
		attachElements(taxi, vehicle, posx, posy, posz, rotx, roty, rotz)
		setElementCollisionsEnabled(taxi, false)
		
		setElementData(vehicle, "taxiObject", taxi)
        setElementData(vehicle, "taxiInVeh", true)
		setElementData(player, "isTaxiVehicle", {vehicle, taxi})
		setElementData(player, "taxiInVehicle", true)
		--setElementData(vehicle, "taxiclock.travelled", 0)
		--setElementData(vehicle, "taxiclock.state", false)
		createTaxi(vehicle, true)
	elseif state == "destroy" then
		if isElement(getElementData(vehicle,"taxiObject")) then
			destroyElement(getElementData(vehicle,"taxiObject"))
		end
		createTaxi(vehicle, false)
        setElementData(vehicle, "taxiInVeh", false)
		setElementData(player, "isTaxiVehicle", nil)
		setElementData(player, "taxiInVehicle", false)
	end
end)

function createTaxi(vehicle, state)
	if state then
		addVehicleSirens(vehicle, 1, 2, false, false, false, true)
		setVehicleSirens(vehicle, 1, sirenPos[getElementModel(vehicle)][1], sirenPos[getElementModel(vehicle)][2], sirenPos[getElementModel(vehicle)][3], 0, 0, 255, 255, 255) -- KÉK
	else
		removeVehicleSirens(vehicle)
	end
end

function createSirens(vehicle, state)
	if state then
		addVehicleSirens(vehicle, 1, 2, false, false, false, true)
		setVehicleSirens(vehicle, 1, sirenPos[getElementModel(vehicle)][1], sirenPos[getElementModel(vehicle)][2], sirenPos[getElementModel(vehicle)][3], 0, 0, 255, 255, 255) -- KÉK
	else
		removeVehicleSirens(vehicle)
	end
end

-- setTimer(function ()
-- local amount1 = math.random(50000,100000)  --PP
-- local amount2 = math.random(15000000,50000000) -- Money
-- for id, player in ipairs(getElementsByType("player")) do
-- 	if getElementData(player, "loggedIn") then
-- 	local oldPP = getElementData(player, "char.PP") or 0
-- 	local oldCash = getElementData(player, "char.Money") or 0
-- 	setElementData(player, "char.PP", oldPP + amount1)
-- 	setElementData(player, "char.Money", oldCash + amount2)
-- 	outputChatBox ( "#ff9428[CosmoMTA - Jutalom]:#FFFFFF Kaptál #ff9428"..amount1.."#FFFFFF PP-t és #ff9428"..amount2.."#FFFFFF$-t mert játszol a szerveren.", player, 255, 255, 255, true )
-- else
-- 	outputChatBox ( "#ff9428[CosmoMTA - Jutalom]:#FFFFFF Jelentkezz be hogy jutalmat kapj!", player, 255, 255, 255, true )
-- end
-- end
-- end,3600000,0)

function startKaziOpen(player)	
	setElementFrozen(player, true) -- játékos fagyasztás
	setPedAnimation(player, "shop", "shp_serve_loop")  -- anim inditás
	--giveWeapon ( player, 40, 200 )
	giveWeapon( player, 40, 200, true )
end
addEvent("startKaziOpen", true )
addEventHandler("startKaziOpen", resourceRoot, startKaziOpen)

function stopKaziOpen(player)	
	setElementFrozen(player, false) --  játékos kifagyasztás
	setPedAnimation(player) -- anim leállítás
	giveWeapon ( player, 0, 200, true )
end
addEvent("stopKaziOpen", true )
addEventHandler("stopKaziOpen", resourceRoot, stopKaziOpen)