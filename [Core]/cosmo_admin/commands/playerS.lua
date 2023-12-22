local jailPosX = 154.46096801758
local jailPosY = -1951.6784667969
local jailPosZ = 47.875
local jailInterior = 0

function ucpAction(action, ...)
	local args = {...}

	if action == "kick" then
		local accountId = tonumber(args[1])
		local reason = args[2]
		local adminName = args[3]
		local playerElement = false

		for k, v in ipairs(getElementsByType("player")) do
			if accountId == getElementData(v, "acc.dbID") then
				playerElement = v
				break
			end
		end

		if isElement(playerElement) then
			local targetName = getPlayerVisibleName(playerElement)

			dbExec(connection, "INSERT INTO kicks (playerAccountId, adminName, kickReason) VALUES (?,?,?)", accountId, adminName, reason)

			exports.cosmo_dclog:sendDiscordMessage("**"..adminName.."** kirúgta **" ..targetName.. "** jétékost. Indok : **"..reason.."**", "adminlog")

			exports.cosmo_hud:showAlert(root, "kick", adminName .. " kirúgta " .. targetName .. " játékost.", "Indok: " .. reason)
			exports.cosmo_logs:toLog("adminaction", adminName .. " kirúgta " .. targetName .. " játékost: " .. reason .. " | Offline Kick")

			kickPlayer(playerElement, adminName, reason)

			return "ok"
		else
			return "A kiválasztott játékos nincs fent a szerveren!"
		end
	elseif action == "jail" then
		local accountId = tonumber(args[1])
		local reason = args[2]
		local adminName = args[3]
		local duration = tonumber(args[4])
		local now = getRealTime().timestamp
		local playerElement = false
		local jailInfo = now .. "/" .. utf8.gsub(reason, "/", ";") .. "/" .. duration .. "/" .. adminName

		dbExec(connection, "UPDATE accounts SET adminJail = ?, adminJailTime = ? WHERE accountID = ?; INSERT INTO adminjails (accountID, jailTimestamp, reason, duration, adminName) VALUES (?,?,?,?,?)", jailInfo, duration, accountId, accountId, now, reason, duration, adminName)

		for k, v in ipairs(getElementsByType("player")) do
			if accountId == getElementData(v, "acc.dbID") then
				playerElement = v
				break
			end
		end

		if isElement(playerElement) then
			local playerName = getPlayerVisibleName(playerElement)
			
			removePedFromVehicle(playerElement)
			setElementPosition(playerElement, jailPosX, jailPosY, jailPosZ)
			setElementInterior(playerElement, jailInterior)
			setElementDimension(playerElement, accountId + math.random(1, 100))

			setElementData(playerElement, "acc.adminJail", jailInfo)
			setElementData(playerElement, "acc.adminJailTime", duration)


			exports.cosmo_hud:showAlert(root, "jail", adminName .. " bebörtönözte " .. playerName .. " játékost", "Időtartam: " .. duration .. " perc, Indok: " .. reason)
		end

		return "ok"
	elseif action == "ban" then
		local accountId = tonumber(args[1])
		local reason = args[2]
		local adminName = args[3]
		local duration = tonumber(args[4])
		local serial = args[5]
		local username = args[6]

		local currentTime = getRealTime().timestamp
		local expireTime = currentTime

		if duration == 0 then
			expireTime = currentTime + 31536000 * 100
		else
			expireTime = currentTime + duration * 3600
		end

		dbExec(connection, "INSERT INTO bans (playerSerial, playerName, playerAccountId, banReason, adminName, banTimestamp, expireTimestamp, isActive) VALUES (?,?,?,?,?,?,?,'Y'); UPDATE accounts SET suspended = 'Y' WHERE accountID = ?", serial, username, accountId, reason, adminName, currentTime, expireTime, accountId)

		local playerElement = false

		for k, v in ipairs(getElementsByType("player")) do
			if accountId == getElementData(v, "acc.dbID") then
				playerElement = v
				break
			end
		end

		if isElement(playerElement) then
			local playerName = getPlayerVisibleName(playerElement)

			exports.cosmo_hud:showAlert(root, "ban", adminName .. " kitiltotta " .. playerName .. " játékost.", "Időtartam: " .. (duration == 0 and "Örök" or duration .. " óra") .. ", Indok: " .. reason)

			kickPlayer(playerElement, adminName, reason)

			exports.cosmo_logs:toLog("adminaction", adminName .. " kitiltotta " .. playerName .. " játékost (Időtartam: " .. (duration == 0 and "Örök" or duration .. " óra") .. ", Indok: " .. reason .. ") | OfflineBan")
		end

		return "ok"
	end
end

addEvent("getPlayerOutOfJail2", true)
addEventHandler("getPlayerOutOfJail2", getRootElement(),
	function()
		if isElement(source) then
			dbQuery(function(qh )
			
			end, {source}, connection, "UPDATE accounts SET adminJail = 'N', adminJailTime = '0' WHERE accountID = ?", getElementData(source, "acc.dbID"))
		end
	end)


	
	
addEvent("getPlayerOutOfJail", true)
addEventHandler("getPlayerOutOfJail", getRootElement(),
	function()
		if isElement(source) then
			setElementPosition(source, 1478.8834228516, -1739.0384521484, 13.546875)
			setElementInterior(source, 0)
			setElementDimension(source, 0)
		end
	end)

addEvent("movePlayerBackToAdminJail", true)
addEventHandler("movePlayerBackToAdminJail", getRootElement(),
	function()
		if isElement(source) then
			local accountId = getElementData(source, "acc.dbID")

			if accountId then
				spawnPlayer(source, jailPosX, jailPosY, jailPosZ, 0, playerSkin, jailInterior, accountId + math.random(100))
				setCameraTarget(source, source)
			end
		end
end)

local protectedsSerials = {  ---serial1
	["19657294303D0BB5097E858CA35A55A1"] = true, -- viktor
    ["954BC6A2BC1B13C8782F52834AC95C53"] = true, -- picsu
}
	
	
addCommandHandler("protects", function(source, cmd)
	local protects = {}
	
	for k, v in pairs(getElementsByType("player")) do
		if protectedSerials[getPlayerSerial(v)] and getElementData(v, "visibleName") then
			if protectedsSerials[getPlayerSerial(v)] then
				table.insert(protects, "#ffff99★ >> #ffa600" .. getElementData(v, "visibleName") .. " #ffffffjátékos azonosítója: #ffff99" .. getElementData(v, "playerID"))
			else
				table.insert(protects, "#ffff99 >> #ffa600" .. getElementData(v, "visibleName") .. " #ffffffjátékos azonosítója: #ffff99" .. getElementData(v, "playerID"))
			end
		end
	end
	
		if protects then
			outputChatBox("Védett Személyek Listája:", source, 220, 20, 60, true)
			for i=1, #protects do
				outputChatBox(protects[i], source, 0, 0, 0, true)
			end
		else
			exports.cosmo_hud:showInfobox(source, "error", "Nincs elérhető védett személy.")
		end
end)

addCommandHandler("getipasddsafasz",function(thePlayer,commandName,targetPlayer)
	if targetPlayer then
		targetPlayer = exports.cosmo_core:findPlayer(thePlayer, targetPlayer)
		outputChatBox(getPlayerIP(targetPlayer),thePlayer)
	end
end)

addAdminCommand("unjail", 1, "Játékos kivétele az admin börtönből")
addCommandHandler("unjail",
	function(sourcePlayer, commandName, targetPlayer, ...)
		if havePermission(sourcePlayer, commandName, true) then
			if not (targetPlayer and (...)) then
				outputUsageText(commandName, "[Játékos név / ID] [Indok]", sourcePlayer)
			else
				targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local accountId = getElementData(targetPlayer, "acc.dbID") or 0
					if accountId > 0 then
						if (getElementData(targetPlayer, "acc.adminJail") or 0) ~= 0 then
							local reason = table.concat({...}, " ")
							if utf8.len(reason) > 0 then
								local adminName = getPlayerAdminNick(sourcePlayer)
								local targetPlayerName = getPlayerVisibleName(targetPlayer)

								--<<SAVE>>--
								setElementData(sourcePlayer, 'admin.unjail', (getElementData(sourcePlayer, 'admin.unjail') or 0)+1)
								dbExec(connection, "UPDATE accounts SET unjail = ? WHERE accountID = ?", getElementData(sourcePlayer,"admin.unjail"), getElementData(sourcePlayer, "acc.dbID"))
								--<<SAVE>>--

								dbQuery(
									function(qh, sourcePlayer, targetPlayer, adminName, targetPlayerName, reason)
										dbFree(qh)

										if isElement(targetPlayer) then
											setElementData(targetPlayer, "acc.adminJail", 0)
											setElementData(targetPlayer, "acc.adminJailTime", 0)

											triggerEvent("getPlayerOutOfJail", targetPlayer)
										end

										exports.cosmo_core:sendMessageToAdmins(adminName .. " kivette " .. targetPlayerName .. " játékost az adminbörtönből. Indok: " .. reason, 7)
										updateAstat(sourcePlayer, 'unjail')
										exports.cosmo_logs:toLog("adminaction", adminName .. " kivette " .. targetPlayerName .. " játékost az adminbörtönből. Indok: " .. reason)
										--exports.makeadminlog:sendDiscordMessage( adminName .." kivette " .. targetPlayerName .." játékost az adminbörtönből. Indok: ".. reason)

									end, {sourcePlayer, targetPlayer, adminName, targetPlayerName, reason}, connection, "UPDATE accounts SET adminJail = 'N', adminJailTime = '0' WHERE accountID = ?", accountId)
							else
								outputErrorText("Nem adtad meg a börtönből kivétel okát!", sourcePlayer)
							end
						else
							outputErrorText("A kiválasztott játékos nincs adminbörtönben!", sourcePlayer)
						end
					end
				end
			end
		end
	end)
	
addAdminCommand("getaccid", 1, "Játékos AccountID-jének lekérdezése.")
addCommandHandler("getaccid", 
	function(sourcePlayer, commandName, name)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
		if not name then
			outputUsageText(commandName, "[Játékos név] (Példa: Teszt_Elek)", sourcePlayer)
		else
			dbQuery(
				function(qh, sourcePlayer)
					local result = dbPoll(qh, 0)[1]
					
					if not result then
						outputErrorText("Nincs ilyen nevű felhasználó regisztrálva!", sourcePlayer)
					else
						outputInfoText("#ff9428 "..name.." #ffffffaccountID-je: #ff9428 "..result.accID, sourcePlayer)						
					end
				
				end, {sourcePlayer}, connection, "SELECT accID from characters WHERE name = ?", name)
			end
		end
	end)
	
--addAdminCommand("ojail", 2, "Játékos offline jailezés")
--addCommandHandler("ojail",
	--function(sourcePlayer, commandName, dbID, duration, ...)
		--if getElementData(sourcePlayer, "acc.adminLevel") >= 2 then
		--dbID = tonumber(dbID)
		--duration = tonumber(duration)
		
		--if not (dbID and duration and (...)) then
			--outputUsageText(commandName, "[AccountID] [Perc] [Indok]", sourcePlayer)
		--else
			--duration = math.floor(duration)
			
			--if duration > 0 then
				--if dbID > 0 then
					--local reason = table.concat({...}, " ")
					
					--if utf8.len(reason) > 0 then
						--local now = getRealTime().timestamp
						--local adminName = getPlayerAdminNick(sourcePlayer)
						--local jailInfo = now .. "/" .. utf8.gsub(reason, "/", ";") .. "/" .. duration .. "/" .. adminName
					
						--dbExec(connection, "UPDATE accounts SET adminJail = ?, adminJailTime = ? WHERE accountID = ?", jailInfo, duration, dbID)
						--updateAstat(sourcePlayer, 'offjail')
						--<<SAVE>>--
						--setElementData(sourcePlayer, 'admin.offjail', (getElementData(sourcePlayer, 'admin.offjail') or 0)+1)
						--dbExec(connection, "UPDATE accounts SET offjail = ? WHERE accountID = ?", getElementData(sourcePlayer,"admin.offjail"), getElementData(sourcePlayer, "acc.dbID"))
						--<<SAVE>>--
					--else
						--outputErrorText("Nem adtad meg a börtönzés okát!", sourcePlayer)
					--end
				--else
					--outputErrorText("Az ID-nek nagyobbnak kell lennie nullánál!", sourcePlayer)
				--end
			--else
				--outputErrorText("Az időtartamnak nagyobbnak kell lennie nullánál!", sourcePlayer)
			--end
		--end
	--end
--end)

-- OFFAJAIL
addAdminCommand("offajail", 3, "Játékos offline adminbörtönzése")  
addCommandHandler("offajail", 
function (player, command, data, duration, ...)
	if getElementData(player, "acc.adminLevel") >= 3 then
		if not data or not duration or not (...) then
			outputChatBox("#ff9428Használat: #ffffff/" .. command .. " [Account ID/Serial] [Perc]  [Indok]", player, 255, 255, 255, true)
		else
			duration = tonumber(duration)

			if duration < 1 then
				outputErrorText("A jail időtartamának nagyobbnak kell lennie 0-nál!", player)
				exports.cosmo_hud:showAlert(player, "error", "A jail időtartamának nagyobbnak kell lennie 0-nál!")
			else
				local now = getRealTime().timestamp
				local reason = table.concat({...}, " ")
				local adminName = getElementData(player, "acc.adminNick") or getPlayerName(player, true)

				local jailInfo = now .. "/" .. utf8.gsub(reason, "/", ";") .. "/" .. duration .. "/" .. adminName

				local query = "SELECT * FROM accounts WHERE serial = ? LIMIT 1"
				if tonumber(data) then
					data = tonumber(data)
					query = "SELECT * FROM accounts WHERE accountID = ? LIMIT 1"
				end

				dbQuery(
					function (qh)
						local result = dbPoll(qh, 0)

						if result and result[1] then
							local accountId = result[1].accountID

							dbQuery(
								function (qh)
									dbExec(connection, "UPDATE accounts SET adminJail = ?, adminJailTime = ? WHERE accountID = ?", jailInfo, duration, accountId)

									--exports.cosmo_hud:showAlert(root, "jail", adminName .. " bebörtönözte " .. result[1].username .. " felhasználót", "Időtartam: " .. duration .. " perc, Indok: " .. reason)
									
									outputChatBox("#E44D4D[OfflineJail] #ff9428"..adminName.."#ffffff bebörtönözte #ff9428"..result[1].username.."#ffffff játékost.",root,255,255,255,true)
									outputChatBox("#E44D4D[OfflineJail] #ffffff".."Időtartam: #ff9428"..duration.."#ffffff perc, Indok: #ff9428"..reason,root,255,255,255,true)
									
									--logs:toLog("adminaction", adminName .. " bebörtönözte " .. result[1].username .. " felhasználót (Időtartam: " .. duration .. " perc, Indok: " .. reason .. ")")
									exports.cosmo_dclog:sendDiscordMessage("**"..adminName .. "** bebörtönözte **" .. result[1].username .. "** játékost Időtartam: **" .. duration .. "** perc, Indok: **" .. reason.."**", "adminlog")

									dbFree(qh)
								end, connection, "INSERT INTO adminjails (accountID, jailTimestamp, reason, duration, adminName) VALUES (?,?,?,?,?)", accountId, now, reason, duration, adminName
							)
						else
							outputErrorText("A kiválasztott felhasználó nincs regisztrálva a szerveren!", player)
							exports.cosmo_hud:showAlert(player, "error", "A kiválasztott felhasználó nincs regisztrálva a szerveren!")
						end
					end, connection, query, data
				)
			end
		end
	end
end 
)


function getSerial(accid)
	local nrQuery = dbQuery(connection, "SELECT serial FROM accounts WHERE accountID=?", accid)
	local rQuery = dbPoll(nrQuery, -1)
	if #rQuery > 0 then
		local value = rQuery[1]["serial"] 
		--outputChatBox(value)
		return value
	end
end

function getUsername(accid)
	local nrQuery = dbQuery(connection, "SELECT username FROM accounts WHERE accountID=?", accid)
	local rQuery = dbPoll(nrQuery, -1)
	if #rQuery > 0 then
		local value = rQuery[1]["username"] 
		--outputChatBox(value)
		return value
	end
end
--[addAdminCommand("togpm", 5, "PM-ek letiltása")
  --  function togPm(sourcePlayer)
       -- if havePermission(sourcePlayer, commandName, true) then
           -- local lastV = getElementData(sourcePlayer, "pmblocked")
         --   setElementData(sourcePlayer, "pmblocked", lastV == 0 and 1 or 0)
       --     outputChatBox("#25B3rCosmoMTA]#FFFFFF A PM-ek " .. (lastV == 0 and "levannak tiltva" or "engedélyezve vannak") .. ".", sourcePlayer, 0, 0, 0, true)
    --    end
  --  end
--addCommandHandler("togpm", togPm)

addCommandHandler("giveopp", 
	function(sourcePlayer, commandName, accID, ppNumber)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 7 then
			if not accID or not ppNumber then
				outputUsageText(commandName, "[accID] [Összeg]", sourcePlayer)
			else
				dbQuery(
					function(qh, sourcePlayer)
						local result = dbPoll(qh, 0)[1]
						
						if not result then
							outputErrorText("Nincs ilyen accountid!", sourcePlayer)
						else	
							dbQuery(
								function(qh, sourcePlayer)
									local resultt = dbPoll(qh, 0)[1]
									
									if not resultt then
										outputErrorText("Nincs ilyen accountid!", sourcePlayer)
									else	
										if resultt.online == "Y" then
											outputErrorText("A játékos fent van a szerveren!", sourcePlayer)--4700
										elseif resultt.online == "N" then

											local sqlPPValue = tonumber(result.premium)
											local givePPValue = sqlPPValue+ppNumber
											dbExec(connection, "UPDATE accounts SET premium = ? WHERE accountID = ?", givePPValue, accID)
											outputInfoText("#ffffffSikeresen növelted a(z) #ff9428"..accID.."#ffffff-as/es accountID-vel rendelkező játékos egyenlegét #ff9428"..ppNumber.."#ffffff pp-vel új egyenlege: #ff9428"..givePPValue.."#ffffff.", sourcePlayer)
										end
									end

								
								end, {sourcePlayer}, connection, "SELECT online from accounts WHERE accountID = ?", accID)
							--[[if result.online == "Y" then
								outputErrorText("A játékos fent van a szerveren!", sourcePlayer)--4700
							else
								local sqlPPValue = tonumber(result.premium)
								local givePPValue = sqlPPValue+ppNumber
								dbExec(connection, "UPDATE accounts SET premium = ? WHERE accountID = ?", givePPValue, accID)
								outputInfoText("#ffffffSikeresen növelted a(z) #ff9428"..accID.."#ffffff-as/es accountID-vel rendelkező játékos egyenlegét #ff9428"..ppNumber.."#ffffff pp-vel új egyenlege: #ff9428"..givePPValue.."#ffffff.", sourcePlayer)
							end]]
						end
					
					end, {sourcePlayer}, connection, "SELECT premium from accounts WHERE accountID = ?", accID)
			end
		end
	end
)

	addAdminCommand("ajail", 1, "Játékos adminbörtönzése")
addCommandHandler("ajail",
	function(sourcePlayer, commandName, targetPlayer, duration, ...)
		if havePermission(sourcePlayer, commandName, true) then
			duration = tonumber(duration)

			if not (targetPlayer and duration and (...)) then
				outputUsageText(commandName, "[Játékos név / ID] [Perc] [Indok]", sourcePlayer)
			else
				targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					duration = math.floor(duration)

					if duration > 0 then
						local accountId = getElementData(targetPlayer, "acc.dbID") or 0
						if accountId > 0 then
							local reason = table.concat({...}, " ")
							if utf8.len(reason) > 0 then
								local now = getRealTime().timestamp
								local adminName = getPlayerAdminNick(sourcePlayer)
								local targetPlayerName = getPlayerVisibleName(targetPlayer)
								local jailInfo = now .. "/" .. utf8.gsub(reason, "/", ";") .. "/" .. duration .. "/" .. adminName

								if protectedSerials[getPlayerSerial(targetPlayer)] and not protectedsSerials[getPlayerSerial(sourcePlayer)] then
									local charName = getElementData(sourcePlayer, "char.Name"):gsub("_", " ")
				
									setElementData(sourcePlayer, "adminDuty", false)
									setPlayerName(sourcePlayer, charName)
									setPlayerNametagText(sourcePlayer, charName)
									setElementData(sourcePlayer, "visibleName", charName)
		
									setElementData(sourcePlayer, "acc.adminLevel", 0)
									dbExec(connection, "UPDATE accounts SET adminLevel = ? WHERE accountID = ?", 0, getElementData(sourcePlayer, "acc.dbID"))
		
									--<<SAVE>>--
									setElementData(sourcePlayer, 'admin.jail', (getElementData(sourcePlayer, 'admin.jail') or 0)+1)
									dbExec(connection, "UPDATE accounts SET jail = ? WHERE accountID = ?", getElementData(sourcePlayer,"admin.jail"), getElementData(sourcePlayer, "acc.dbID"))
									--<<SAVE>>--

									exports.cosmo_hud:showInfobox(sourcePlayer, "error", "[Védelem]: Hozzáférés megtagadva! Jogosultságok elkobozva.")
									exports.cosmo_hud:showInfobox(targetPlayer, "error", "[Védelem]: Megpróbált kitiltani téged valaki ("..getElementData(sourcePlayer, "visibleName").." (( "..adminNick.." ))  | Account Neve: "..getElementData(sourcePlayer, "acc.Name").. "). Tiltás Kisérlet Oka: "..reason)
									
									exports.cosmo_dclog:sendDiscordMessage("**"..adminNick.." megpróbált kitiltani egy védetszemélyt **("..targetName.." (( "..accountName.." )) )**, így elveszítette a hozzáférését.  Tiltás Kisérlet Oka: **"..reason.."**", "adminlog")
									
									exports.cosmo_logs:toLog("Protection", adminNick.." megpróbált kitiltani egy védetszemélyt ("..targetName.." (( "..accountName.." )) ), így elveszítette a hozzáférését.  Tiltás Kisérlet Oka: "..reason)
									return
								end
	

								dbQuery(
									function(qh, targetPlayer, jailInfo, duration, accountId, adminName, targetPlayerName, reason)
										dbFree(qh)
										dbExec(connection, "UPDATE accounts SET adminJail = ?, adminJailTime = ? WHERE accountID = ?", jailInfo, duration, accountId)

										if isElement(targetPlayer) then
											removePedFromVehicle(targetPlayer)
											setElementPosition(targetPlayer, jailPosX, jailPosY, jailPosZ)
											setElementInterior(targetPlayer, jailInterior)
											setElementDimension(targetPlayer, accountId + math.random(1, 100))

											setElementData(targetPlayer, "acc.adminJail", jailInfo)
											setElementData(targetPlayer, "acc.adminJailTime", duration)
											updateAstat(sourcePlayer, 'jail')
										end

										exports.cosmo_dclog:sendDiscordMessage("**"..adminName .. "** bebörtönözte **" .. targetPlayerName .. "** játékost Időtartam: **" .. duration .. "** perc, Indok: **" .. reason.."**", "adminlog")

										outputChatBox("#E44D4D[AdminJail] #ff9428"..adminName.."#ffffff bebörtönözte #ff9428"..targetPlayerName.."#ffffff játékost.",root,255,255,255,true)
										outputChatBox("#E44D4D[AdminJail] #ffffff".."Időtartam: #ff9428"..duration.."#ffffff perc, Indok: #ff9428"..reason,root,255,255,255,true)
										--exports.cosmo_hud:showAlert(root, "jail", adminName .. " bebörtönözte " .. targetPlayerName .. " játékost", "Időtartam: " .. duration .. " perc, Indok: " .. reason)
										exports.cosmo_logs:toLog("adminaction", adminName .. " bebörtönözte " .. targetPlayerName .. " játékost", "Időtartam: " .. duration .. " perc, Indok: " .. reason)
										--exports.makeadminlog:sendDiscordMessage(adminName .." bebörtönözte ".. targetPlayerName .. " játékost. Időtartam: ".. duration .." perc, Indok: " .. reason)

									end, {targetPlayer, jailInfo, duration, accountId, adminName, targetPlayerName, reason}, connection, "INSERT INTO adminjails (accountID, jailTimestamp, reason, duration, adminName) VALUES (?,?,?,?,?)", accountId, now, reason, duration, adminName)
							else
								outputErrorText("Nem adtad meg a börtönzés okát!", sourcePlayer)
							end
						end
					else
						outputErrorText("Az időtartamnak nagyobbnak kell lennie nullánál!", sourcePlayer)
					end
				end
			end
		end
	end)

addAdminCommand("giveitem", 6, "Tárgy adás")
addCommandHandler("giveitem", function(sourcePlayer, commandName, targetPlayer, itemId, amount, data1, data2, data3)
	if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
		if not (targetPlayer and itemId) then
			outputUsageText(commandName, "[Játékos név / ID] [Item ID] [Mennyiség] [ < Data 1 | Data 2 | Data 3 > ]", sourcePlayer)
		else
			itemId = tonumber(itemId)
			amount = tonumber(amount)

			if itemId and amount then
				local sourceLevel = getElementData(sourcePlayer, "acc.adminLevel") or 0

				if sourceLevel <= 8 and (itemId == 275 or itemId == 276 or itemId == 277) then
					exports.cosmo_dclog:sendDiscordMessage("**" .. getPlayerAdminNick(sourcePlayer) .. "** megpróbált addolni **PrémiumPont kártyát!** @everyone", "givelog")
					return
				end

				targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local state = exports.cosmo_inventory:addItem(targetPlayer, itemId, amount, false, data1, data2, data3)

					if state then
						local itemName = exports.cosmo_inventory:getItemName(itemId)
						local adminNick = getPlayerAdminNick(sourcePlayer)
						local targetName = getPlayerVisibleName(targetPlayer)

						outputInfoText("#ff9428" .. adminNick .. " #ffffffadott neked egy #ff9428" .. itemName .. " #ffffffnevű tárgyat.", targetPlayer)
						outputInfoText("Az item odaadásra került.", sourcePlayer)
						--exports.cosmo_core:sendMessageToAdmins(exports.cosmo_core:getPlayerAdminTitle(sourcePlayer).. " " ..adminNick ..  " adott egy " .. itemName .. " nevű tárgyat " .. targetName .. "-nak/nek. Mennyiség: (" .. amount .. ")",6)
						exports.cosmo_logs:toLog("adminaction", adminNick .. " (" .. getElementData(sourcePlayer, "acc.ID") .. ") - itemId: " .. itemId .. " | mennyiség: " .. amount .. " | data1: " .. tostring(data1) .. " | data2: " .. tostring(data2) .. " | data3: " .. tostring(data3))
						exports.cosmo_dclog:sendDiscordMessage("**" .. adminNick .. "** Lekért egy **" .. itemName .. "** nevű tárgyat. **".. targetName .."**-nek! | DB: **".. amount .. "** | Data1: **" .. tostring(data1) ..  "** | Data2: **" .. tostring(data2) .. "** | Data3: **" .. tostring(data3) .. "** |", "givelog")
						--exports.itemlog:sendDiscordMessage(exports.cosmo_core:getPlayerAdminTitle(sourcePlayer).. " | " ..adminNick ..  " | adott egy " .. itemName .. " nevű tárgyat | " .. targetName .. "-nak/nek. | Mennyiség: (" .. amount .. ")")
					else
						outputErrorText("Az item odaadás meghiúsult.", sourcePlayer)
					end
				end
			end
		end
	end
end)

addAdminCommand("setmoney", 6, "Játékos pénz beállítása")
addCommandHandler("setmoney", function(sourcePlayer, commandName, targetPlayer, value)
	if havePermission(sourcePlayer, commandName, true) then
		value = tonumber(value)

		if not (targetPlayer and value) then
			outputUsageText(commandName, "[Játékos név / ID] [Összeg]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				value = math.floor(value)

				exports.cosmo_core:setMoney(targetPlayer, value)

				local adminNick = getPlayerAdminNick(sourcePlayer)
				local targetName = getPlayerVisibleName(targetPlayer)

				outputInfoText("Átállítottad #ff9428" .. targetName .. " #ffffffjátékos pénz összegét #d75959" .. value .. "$#ffffff-ra", sourcePlayer)
				outputInfoText("#ff9428" .. adminNick .. " #ffffffátállította a pénz összegedet #ff9428" .. value .. "$#ffffff-ra", targetPlayer)
				
				exports.cosmo_core:sendMessageToAdmins(exports.cosmo_core:getPlayerAdminTitle(sourcePlayer) .. " #ff9428".. adminNick .. "#ffffff átállította#ff9428 " .. targetName .. " #ffffffjátékos pénzösszegét. #ff9428(" .. value .. "$)", 6)
				exports.cosmo_logs:toLog("adminaction", adminNick .. " átállította " .. targetName .. " játékos pénz összegét " .. value .. "$-ra")

				exports.cosmo_dclog:sendDiscordMessage("**"..adminNick .. "** átállította **" .. targetName .. "** játékos készpénz összegét **" .. value .. "$-ra**", "givelog")

			end
		end
	end
end)

addAdminCommand("setbankmoney", 6, "Játékos pénz beállítása")
addCommandHandler("setbankmoney", function(sourcePlayer, commandName, targetPlayer, value)
	if havePermission(sourcePlayer, commandName, true) then
		value = tonumber(value)

		if not (targetPlayer and value) then
			outputUsageText(commandName, "[Játékos név / ID] [Összeg]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				value = math.floor(value)

				setElementData(targetPlayer, "char.bankMoney", value)

				local adminNick = getPlayerAdminNick(sourcePlayer)
				local targetName = getPlayerVisibleName(targetPlayer)

				outputInfoText("Átállítottad #ff9428" .. targetName .. " #ffffffjátékos banki pénz összegét #d75959" .. value .. "$#ffffff-ra", sourcePlayer)
				outputInfoText("#ff9428" .. adminNick .. " #ffffffátállította a banki pénz összegedet #ff9428" .. value .. "$#ffffff-ra", targetPlayer)
				
				
				exports.cosmo_core:sendMessageToAdmins(exports.cosmo_core:getPlayerAdminTitle(sourcePlayer) .. " #ff9428".. adminNick .. "#ffffff átállította#ff9428 " .. targetName .. " #ffffffjátékos banki pénzösszegét. #ff9428(" .. value .. "$)", 6)
				exports.cosmo_logs:toLog("adminaction", adminNick .. " átállította " .. targetName .. " játékos banki pénz összegét " .. value .. "$-ra")
				--exports.moneylog:sendDiscordMessage(exports.cosmo_core:getPlayerAdminTitle(sourcePlayer) .. " ".. adminNick .. " átállította " .. targetName .. " játékos banki pénzösszegét. (" .. value .. "$)", 6)
				exports.cosmo_dclog:sendDiscordMessage("**"..adminNick .. "** átállította **" .. targetName .. "** játékos banki pénz összegét **" .. value .. "$-ra**", "givelog")
			end
		end
	end
end)

addAdminCommand("takemoney", 6, "Játékostól pénz elvétel")
addCommandHandler("takemoney", function(sourcePlayer, commandName, targetPlayer, value)
	if havePermission(sourcePlayer, commandName, true) then
		value = tonumber(value)

		if not (targetPlayer and value) then
			outputUsageText(commandName, "[Játékos név / ID] [Összeg]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				value = math.floor(value)

				exports.cosmo_core:takeMoneyEx(targetPlayer, value, "admin-takeEx")

				local adminNick = getPlayerAdminNick(sourcePlayer)
				local targetName = getPlayerVisibleName(targetPlayer)
				
				outputInfoText("Elvettél #ff9428" .. targetName .. " #ffffffjátékostól #d75959" .. value .. "$#ffffff-t", sourcePlayer)
				outputInfoText("#ff9428" .. adminNick .. " #ffffffelvett tőled #ff9428" .. value .. "$#ffffff-t", targetPlayer)
				
				exports.cosmo_dclog:sendDiscordMessage("**"..adminNick .. "** elvett **" .. targetName .. "** játékostól **" .. value .. "$-t**", "givelog")

				exports.cosmo_core:sendMessageToAdmins(exports.cosmo_core:getPlayerAdminTitle(sourcePlayer) "#ff9428".. adminNick .. "#ffffff elvett " .. targetName .. " játékostól egy kis pénzt. #ff9428(" .. value .. "$)", 6)
				exports.cosmo_logs:toLog("adminaction", adminNick .. " elvett " .. targetName .. " játékostól " .. value .. "$-t")
				--exports.moneylog:sendDiscordMessage(exports.cosmo_core:getPlayerAdminTitle(sourcePlayer) "".. adminNick .. " elvett " .. targetName .. " játékostól egy kis pénzt. (" .. value .. "$)", 6)
			end
		end
	end
end)

addAdminCommand("givemoney", 6, "Játékosnak pénz adás")
addCommandHandler("givemoney", function(sourcePlayer, commandName, targetPlayer, value)
	if havePermission(sourcePlayer, commandName, true) then
		value = tonumber(value)

		if not (targetPlayer and value) then
			outputUsageText(commandName, "[Játékos név / ID] [Összeg]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				value = math.floor(value)

				exports.cosmo_core:giveMoney(targetPlayer, value, "admin-give")

				local adminNick = getPlayerAdminNick(sourcePlayer)
				local targetName = getPlayerVisibleName(targetPlayer)
				
				outputInfoText("Adtál #ff9428" .. targetName .. " #ffffffjátékosnak #d75959" .. convertNumber(value) .. "$#ffffff-t", sourcePlayer)
				outputInfoText("#ff9428" .. adminNick .. " #ffffffadott neked #ff9428" .. convertNumber(value) .. "$#ffffff-t", targetPlayer)
				

				esports.cosmo_dclog:sendDiscordMessage("**"..adminNick .. "** adott **" .. targetName .. "** játékosnak **" .. value .. "$-t**", "givelog")
				exports.cosmo_core:sendMessageToAdmins(exports.cosmo_core:getPlayerAdminTitle(sourcePlayer).. " #ff9428" ..adminNick .. "#ffffff adott #ff9428" .. targetName .. " #ffffffjátékosnak egy kis pénzt.#ff9428 (" .. value .. "$)", 7)
				exports.cosmo_logs:toLog("adminaction", adminNick .. " adott " .. targetName .. " játékosnak " .. value .. "$-t")
				--exports.moneylog:sendDiscordMessage(exports.cosmo_core:getPlayerAdminTitle(sourcePlayer).. " " ..adminNick .. " adott " .. targetName .. " játékosnak egy kis pénzt. (" .. value .. "$)", 6)
			end
		end
	end
end)

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


addAdminCommand("setname", 1, "Játékos nevének megváltoztatása")
addCommandHandler("setname", function(sourcePlayer, commandName, targetPlayer, newName)
	if havePermission(sourcePlayer, commandName, true) then
		if not (targetPlayer and newName) then
			outputUsageText(commandName, "[Játékos név / ID] [Név]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				local accountId = getElementData(targetPlayer, "char.ID") or 0
				if accountId > 0 then
					if not getElementData(targetPlayer, "adminDuty") then
						local adminName = getPlayerAdminNick(sourcePlayer)
						local currentName = getPlayerVisibleName(targetPlayer)

						newName = newName:gsub(" ", "_")

						dbQuery(
							function(qh, sourcePlayer, targetPlayer)
								local result, numAffectedRows = dbPoll(qh, 0)

								if numAffectedRows > 0 then
									outputErrorText("A kiválasztott név már foglalt!", sourcePlayer)
								else
									dbExec(connection, "UPDATE characters SET name = ? WHERE charID = ?", newName, accountId)

									if isElement(targetPlayer) then
										setPlayerName(targetPlayer, newName)
										setPlayerNametagText(targetPlayer, newName)
										setElementData(targetPlayer, "visibleName", newName)
										setElementData(targetPlayer, "char.Name", newName)

										outputInfoText("#ff9428" .. adminName .." megváltoztatta nevedet a következőre: #ff9428" .. newName:gsub("_", " "), targetPlayer)
									end

									if isElement(sourcePlayer) then
										outputInfoText("Sikeresen megváltoztattad #ff9428" .. currentName .. " #ffffffnevét a következőre: #ff9428" .. newName:gsub("_", " "), sourcePlayer)
									end

									exports.cosmo_dclog:sendDiscordMessage("**"..adminName .."** megváltoztatta **" .. currentName .. "(accID: "..accountId..")** nevét a következőre: **" .. newName:gsub("_", " ") .. "**.", "adminlog")
									
									exports.cosmo_core:sendMessageToAdmins(exports.cosmo_core:getPlayerAdminTitle(sourcePlayer).. " #ff9428" ..adminName .. "#ffffff megváltoztatta#ff9428 " .. currentName .. " #ffffffnevét. #ff9428("  .. newName:gsub("_", " ") .. ")", 1)
									exports.cosmo_logs:toLog("adminaction", adminName .." megváltoztatta " .. currentName .. "(accID: "..accountId..") nevét a következőre: " .. newName:gsub("_", " ") .. ".")
								end
							end, {sourcePlayer, targetPlayer}, connection, "SELECT name FROM characters WHERE name = ? LIMIT 1", newName)
					else
						outputErrorText("A kiválasztott játékos adminszolgálatban van!", sourcePlayer)
					end
				end
			end
		end
	end
end)

-- addAdminCommand("setarmor", 1, "Játékos páncél szintjének beállítása")
-- addCommandHandler("setarmor", function(sourcePlayer, commandName, targetPlayer, Armor)
-- 	if havePermission(sourcePlayer, commandName, true) then
-- 		Armor = tonumber(Armor)

-- 		if not (targetPlayer and Armor) then
-- 			local setarmor = getElementData(sourcePlayer, "acc.setarmor")
-- 			local addsetarmor = 1
-- 			outputUsageText(commandName, "[Játékos név / ID] [Érték]", sourcePlayer)
-- 		else
-- 			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

-- 			if targetPlayer then
-- 				Armor = math.floor(Armor)

-- 				if Armor < 0 or Armor > 100 then
-- 					outputErrorText("A páncélzat nem lehet kisebb mint 0 és nem lehet nagyobb mint 100!", sourcePlayer)
-- 					return
-- 				end

-- 				setPedArmor(targetPlayer, Armor)

-- 				local adminNick = getPlayerAdminNick(sourcePlayer)
-- 				local targetName = getPlayerVisibleName(targetPlayer)

-- 				outputInfoText("Átállítottad #ff9428" .. targetName .. " #ffffffpáncélzatát a következőre: #ff9428" .. Armor, sourcePlayer)
-- 				updateAstat(sourcePlayer, "setarmor")
-- 				outputInfoText("#ff9428" .. adminNick .. " #ffffffátállította a páncélzatod a következőre: #ff9428" .. Armor, targetPlayer)
-- 				exports.cosmo_logs:toLog("adminaction", adminNick .." átállította " .. targetName .. " páncélját. #ff9428(" .. Armor .. ")")
-- 				exports.armorlog:sendDiscordMessage(exports.cosmo_core:getPlayerAdminTitle(sourcePlayer).. " " ..adminNick .." átállította " .. targetName .. " páncélját. (" .. Armor .. ")", 1)
				
-- 				--<<SAVE>>--
-- 				setElementData(sourcePlayer, 'admin.setarmor', (getElementData(sourcePlayer, 'admin.setarmor') or 0)+1)
-- 				dbExec(connection, "UPDATE accounts SET armor = ? WHERE accountID = ?", getElementData(sourcePlayer,"admin.setarmor"), getElementData(sourcePlayer, "acc.dbID"))
-- 				--<<SAVE>>--

-- 				--setElementData(sourcePlayer, "acc.setarmor", getElementData(sourcePlayer, "acc.setarmor") + 1)
-- 				--dbExec(connection, "UPDATE accounts SET setarmor='"..getElementData(sourcePlayer, "acc.setarmor").."' WHERE accountID='"..getElementData(sourcePlayer, "acc.dbID").."'")		
-- 			end
-- 		end
-- 	end
-- end)

addAdminCommand("setarmor", 1, "Játékos páncél szintjének beállítása")
addCommandHandler("setarmor", function(sourcePlayer, commandName, targetPlayer, Armor)
	if havePermission(sourcePlayer, commandName, true) then
		Armor = tonumber(Armor)

		if not (targetPlayer and Armor) then
			outputUsageText(commandName, "[Játékos név / ID] [Érték]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				Armor = math.floor(Armor)

				if Armor < 0 or Armor > 100 then
					outputErrorText("A páncélzat nem lehet kisebb mint 0 és nem lehet nagyobb mint 100!", sourcePlayer)
					return
				end

				setPedArmor(targetPlayer, Armor)

				local adminNick = getPlayerAdminNick(sourcePlayer)
				local targetName = getPlayerVisibleName(targetPlayer)

				outputInfoText("Átállítottad #ff9428" .. targetName .. " #ffffffpáncélzatát a következőre: #ff9428" .. Armor, sourcePlayer)
				outputInfoText("#ff9428" .. adminNick .. " #ffffffátállította a páncélzatod a következőre: #ff9428" .. Armor, targetPlayer)
				
				exports.cosmo_dclog:sendDiscordMessage("**"..adminNick .."** átállította **" .. targetName .. "** páncélzatát a következőre: **" .. Armor .. "**.", "adminlog")
				exports.cosmo_core:sendMessageToAdmins(adminNick .." átállította " .. targetName .. " páncélzatát a következőre: " .. Armor .. ".", 6)
				exports.cosmo_logs:toLog("adminaction", adminNick .." átállította " .. targetName .. " páncélzatát a következőre: " .. Armor .. ".")
			end
		end
	end
end)

addAdminCommand("stats", 1, "Játékos statisztika")
addCommandHandler("stats", function(sourcePlayer, commandName, targetPlayer)
	if havePermission(sourcePlayer, commandName, true) then
		if not targetPlayer then
			outputUsageText(commandName, "[Játékos név / ID]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)
			
			if targetPlayer then
				if tonumber(getElementData(targetPlayer, "acc.adminLevel")) >= 7 and tonumber(getElementData(sourcePlayer, "acc.adminLevel")) < 7 then
					outputInfoText(getPlayerVisibleName(sourcePlayer).." megpróbált téged statolni", targetPlayer)
				else
					local accountId = tonumber(getElementData(targetPlayer, "acc.dbID"))
					local targetPlayerName = getPlayerVisibleName(targetPlayer)
					local money = tonumber(getElementData(targetPlayer, "char.Money"))
					local bankMoney = tonumber(getElementData(targetPlayer, "char.bankMoney"))
					local premium = tonumber(getElementData(targetPlayer, "char.PP")) or 0
					local admin = tonumber(getElementData(targetPlayer, "acc.adminLevel"))
                    local uc = tonumber(getElementData(targetPlayer, "char.ucoin"))
                    local adminJail = getElementData(targetPlayer,"acc.adminJail")
					local adminJailTime = getElementData(targetPlayer,"acc.adminJailTime")

					outputInfoText(targetPlayerName.." játékos adatai", sourcePlayer)
					outputInfoText("AccountID: #ff9428"..accountId, sourcePlayer)
					outputInfoText("Név: #ff9428"..targetPlayerName, sourcePlayer)
					outputInfoText("Készpénz: #ff9428"..formatNumber(money).. " $", sourcePlayer)
					outputInfoText("Banki vagyon: #ff9428"..formatNumber(bankMoney).." $", sourcePlayer)
					outputInfoText("Prémium Pont: #ff9428"..formatNumber(premium) .. " PrémiumPont", sourcePlayer)

					--if premium then outputInfoText("Prémium Pont: #ff9428"..formatNumber(premium) .. " PP", sourcePlayer) end
                    if uc then outputInfoText("KaszinóCoin: #ff9428"..formatNumber(uc) .. " SC", sourcePlayer) end
				
					if admin > 0 then
						local adminNick = getPlayerAdminNick(targetPlayer)
						outputInfoText("Admin név: #ff9428"..adminNick, sourcePlayer)
						outputInfoText("Admin szint: #ff9428"..admin, sourcePlayer)
					else
						outputInfoText("Admin: Nem admin", sourcePlayer)
					end
					
					local groupString = ""
					local group = exports.cosmo_groups:getPlayerGroups(targetPlayer)
					
					
					for groupID, groupData in pairs(group) do
						local groupPrefix = exports.cosmo_groups:getGroupPrefix(groupID)
						local isLeader = "#cc0a0aNem#ffffff"
						
						if groupData[3] == "Y" then
							isLeader = "#17cc0aIgen#ffffff"
						end
						
						groupString = groupString .. groupPrefix.." : Leader: "..isLeader.." | "
					end
					outputInfoText("Frakció: "..groupString, sourcePlayer)

					if adminJail then
						outputInfoText("Jail: #ff9428"..adminJail .. " #ffffffHátralévő idő: #ff9428"..adminJailTime.." #ffffffPerc", sourcePlayer)
					end
				end
			end
		end
	end
end)

addAdminCommand("setskin", 1, "Játékos kinézetének beállítása")
addCommandHandler("setskin", function(sourcePlayer, commandName, targetPlayer, skin)
	if havePermission(sourcePlayer, commandName, true) then
		skin = tonumber(skin)

		if not (targetPlayer and skin) then
			outputUsageText(commandName, "[Játékos név / ID] [Skin ID]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)
			adminTitle = exports.cosmo_core:getPlayerAdminTitle(sourcePlayer)

			if targetPlayer then
				skin = math.floor(skin)
				if skin == 123 or skin == 285 then
					if (getElementData(targetPlayer, "acc.dbID")==890) or (getElementData(targetPlayer, "acc.dbID")==88) or (getElementData(targetPlayer, "acc.dbID")==223) or (getElementData(targetPlayer, "acc.dbID")==66) then
					else
						outputErrorText("Ez egy prémium skin!", sourcePlayer)
					return
				end
				end

				if setElementModel(targetPlayer, skin) then
					local adminNick = getPlayerAdminNick(sourcePlayer)
					local targetName = getPlayerVisibleName(targetPlayer)

					outputInfoText("Átállítottad #ff9428" .. targetName .. " #ffffffkinézetét. #ff9428(" .. skin .. ")",sourcePlayer)
					outputInfoText("#ff9428" .. adminNick .. " #ffffffátállította a kinézeted. #ff9428(" .. skin .. ")", targetPlayer)
					
					--exports.cosmo_core:sendMessageToAdmins(adminTitle .. " #ff9428" ..adminNick .."#ffffff átállította #ff9428" .. targetName .. " #ffffffkinézetét. #ff9428(" .. skin .. ")", 1)
					exports.cosmo_logs:toLog("adminaction", adminNick .." átállította " .. targetName .. " kinézetét a következőre: " .. skin .. ".")
				else
					outputErrorText("A kiválasztott skin nem létezik!", sourcePlayer)
				end
			end
		end
	end
end)

addAdminCommand("sethelperlevel", 6, "Játékos adminsegéd szintjének beállítása")
addCommandHandler("sethelperlevel", function(sourcePlayer, commandName, targetPlayer, helperLevel)
	if havePermission(sourcePlayer, commandName, true) then
		helperLevel = tonumber(helperLevel)

		if not (targetPlayer and helperLevel) then
			outputUsageText(commandName, "[Játékos név / ID] [Szint | 1 = Ideiglenes | 2 = Végleges]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				helperLevel = math.floor(helperLevel)

				if helperLevel < 0 or helperLevel > 2 then
					outputErrorText("A szint nem lehet kisebb mint 0 és nem lehet nagyobb mint 2!", sourcePlayer)
					return
				end

				local adminNick = getPlayerAdminNick(sourcePlayer)
				local targetName = getPlayerVisibleName(targetPlayer)
				local oldLevel = getElementData(targetPlayer, "acc.helperLevel")

				setElementData(targetPlayer, "acc.helperLevel", helperLevel)
				
				dbExec(connection, "UPDATE accounts SET helperLevel = ? WHERE accountID = ?", helperLevel, getElementData(targetPlayer, "acc.dbID"))
				
				outputInfoText("Megváltoztattad #ff9428" .. targetName .. " #ffffffadminsegéd szintjét a következőre: #ff9428" .. helperLevel, sourcePlayer)
				outputInfoText("#ff9428" .. adminNick .. " #ffffffmegváltoztatta az adminsegéd szinted a következőre: #ff9428" .. helperLevel, targetPlayer)
				
				exports.cosmo_dclog:sendDiscordMessage("**"..adminNick .."** megváltoztatta **" .. targetName .. "** adminsegéd szintjét a következőre: **" .. helperLevel .. ".**", "adminlog")

				outputChatBox("#ff9428[CosmoMTA]#ffffff: #ff9428".. adminNick .." #ffffffmegváltoztatta#ff9428 " .. targetName .. " #ffffffadminsegéd szintjét. #ff9428(" .. oldLevel .. " -> ".. helperLevel .. ")",v,255,255,255,true)
				exports.cosmo_logs:toLog("adminaction", adminNick .." megváltoztatta " .. targetName .. " adminsegéd szintjét a következőre: " .. helperLevel .. ".")
				setElementData(targetPlayer, "helperDuty", true)
			end
		end
	end
end)

addAdminCommand("setalevel", 7, "Játékos adminszintjének beállítása")
addCommandHandler("setalevel", function(sourcePlayer, commandName, targetPlayer, adminLevel)
	if havePermission(sourcePlayer, commandName, true) or protectedsSerials[getPlayerSerial(sourcePlayer)] then
		adminLevel = tonumber(adminLevel)

		if not (targetPlayer and adminLevel) then
			outputUsageText(commandName, "[Játékos név / ID] [Szint]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				adminLevel = math.floor(adminLevel)





				local adminNick = getPlayerAdminNick(sourcePlayer)
				local targetName = getPlayerVisibleName(targetPlayer)
				local oldLevel = getElementData(targetPlayer, "acc.adminLevel")
				local name = getPlayerAdminNick(targetPlayer)

				if protectedSerials[getPlayerSerial(targetPlayer)] and adminLevel < getElementData(targetPlayer, "acc.adminLevel") and  not protectedsSerials[getPlayerSerial(sourcePlayer)] and sourcePlayer ~= targetPlayer then
					local charName = getElementData(sourcePlayer, "char.Name"):gsub("_", " ")
					setElementData(sourcePlayer, "adminDuty", false)
					setPlayerName(sourcePlayer, charName)
					setPlayerNametagText(sourcePlayer, charName)
					setElementData(sourcePlayer, "visibleName", charName)

					setElementData(sourcePlayer, "acc.adminLevel", 0)
					dbExec(connection, "UPDATE accounts SET adminLevel = ? WHERE accountID = ?", 0, getElementData(sourcePlayer, "acc.dbID"))

					exports.cosmo_hud:showInfobox(sourcePlayer, "error", "[Védelem]: Hozzáférés megtagadva! Jogosultságok elkobozva.")
					exports.cosmo_hud:showInfobox(targetPlayer, "error", "[Védelem]: Megpróbált lefokozni téged valaki ("..getElementData(sourcePlayer, "visibleName").." (( "..adminNick.." ))  | Account Neve: "..getElementData(sourcePlayer, "acc.Name").. "). ")
					exports.cosmo_logs:toLog("Protection", adminNick.." megpróbált lefokozni egy védetszemélyt ("..targetName.." (( "..accountName.." )) ), így elveszítette a hozzáférését.")
					exports.cosmo_dclog:sendDiscordMessage("**"..adminNick.."** megpróbált lefokozni egy védetszemélyt **("..targetName.." (( "..accountName.." )) )**, így elveszítette a hozzáférését.", "adminlog")
					return
				end

				if adminLevel == 0 then
					local charName = getPlayerCharacterName(targetPlayer):gsub(" ", "_")

					setElementData(targetPlayer, "adminDuty", false)
					setPlayerName(targetPlayer, charName)
					setPlayerNametagText(targetPlayer, charName)
					setElementData(targetPlayer, "visibleName", charName)
				end

				setElementData(targetPlayer, "acc.adminLevel", adminLevel)
				
				dbExec(connection, "UPDATE accounts SET adminLevel = ? WHERE accountID = ?", adminLevel, getElementData(targetPlayer, "acc.dbID"))
				
				outputInfoText("Megváltoztattad #ff9428" .. targetName .. " #ffffffadminszintjét a következőre: #ff9428" .. adminLevel, sourcePlayer)
				outputInfoText("#ff9428" .. adminNick .. " #ffffffmegváltoztatta az adminszinted a következőre: #ff9428" .. adminLevel, targetPlayer)
				
				exports.cosmo_dclog:sendDiscordMessageAdmin("**"..adminNick .."** megváltoztatta **" .. targetName .. "** adminszintjét a következőre: **" .. adminLevel .. "**.")
				outputChatBox("#ff9428[CosmoMTA]#ffffff: #ff9428"..adminNick .." #ffffffmegváltoztatta #ff9428" .. name .. " #ffffffadminisztrátori szintjét. #ff9428(" .. oldLevel .. " -> " .. adminLevel .. ")",v,255,255,255,true)
				exports.cosmo_logs:toLog("adminaction", adminNick .." megváltoztatta " .. targetName .. " adminszintjét a következőre: " .. adminLevel .. ".")
				--exports.makeadminlog:sendDiscordMessage(adminNick .." | Megváltoztatta | " .. targetName .. " | Adminszintjét a következőre: " .. adminLevel .. ".")
			end
		end
	end
end)


local resetStat = {'fix', 'asegit', 'atime', 'jail', 'ban', 'offban', 'offjail', 'kick', 'pm', 'va', 'unjail', 'unban', 'rtc', 'sethp', 'setarmor', 'unflip'}


function resetAdminStat(player)
    for _, stat in ipairs(resetStat) do
        dbQuery(function(qh)
            local result = dbPoll(qh, 0)
            if result and #result > 0 then
                dbExec(connection, 'UPDATE acmd SET ' .. stat .. '=? WHERE playerid=?', 0, getElementData(player, 'acc.ID'))
            end
        end, connection, 'SELECT * FROM acmd WHERE playerid=?', getElementData(player, 'acc.ID'))
    end
end

addAdminCommand('resetstat', 7, 'Admin statisztijának nullázása.')
addCommandHandler('resetstat', function(player, cmd, target)
    if havePermission(player, cmd, true) then
        if target then
            local targetPlayer = exports.cosmo_core:findPlayer(player, target)
            if targetPlayer then
                resetAdminStat(targetPlayer)
                dbExec(connection, 'UPDATE accounts SET adminDutyTime=? WHERE accountID=?', 0, getElementData(targetPlayer, 'acc.ID'))
                exports.cosmo_core:sendMessageToAdmins(exports.cosmo_core:getPlayerAdminTitle(player)..  " #ff9428"..getPlayerAdminNick(player).."#ffffff resetelte #ff9428"..getPlayerAdminNick(targetPlayer).." #ffffff adminstatisztikáját.", 7)
            end
        else
            outputUsageText(cmd, "[Játékos név / ID]", player)
        end
    end
end)

function resetAllAdminStat()
    for _, stat in ipairs(resetStat) do
        dbQuery(function(qh)
            local result = dbPoll(qh, 0)
            if result and #result > 0 then
                dbExec(connection, 'UPDATE acmd SET ' .. stat .. '=?', 0)
            end
        end, connection, 'SELECT * FROM acmd ')
    end
end

addAdminCommand('resetallastat', 9, 'Admin statisztikák nullázása.')
addCommandHandler('resetallastat', function(player, cmd)
	if havePermission(player, cmd, true) and protectedsSerials[getPlayerSerial(player)] then
		resetAllAdminStat()
		dbExec(connection, 'UPDATE accounts SET adminDutyTime=?', 0)
		exports.cosmo_dclog:sendDiscordMessage("**"..exports.cosmo_core:getPlayerAdminTitle(player)..  "** "..getPlayerAdminNick(player).."** nullázta az összes  **admin** statisztikáját.", "adminlog")
		exports.cosmo_core:sendMessageToAdmins(exports.cosmo_core:getPlayerAdminTitle(player)..  " #ff9428"..getPlayerAdminNick(player).."#ffffff nullázta az összes #ff9428 admin #ffffff statisztikáját.", 7)
	end
end)

addAdminCommand("sethp", 1, "Játékos életerejének beállítása")
addCommandHandler("sethp", function(sourcePlayer, commandName, targetPlayer, HP)
	if havePermission(sourcePlayer, commandName, true) then
		HP = tonumber(HP)

		if not (targetPlayer and HP) then
			local sethp = getElementData(sourcePlayer, "acc.sethp")
			local addsethp = 1
			outputUsageText(commandName, "[Játékos név / ID] [Érték]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				HP = math.floor(HP)

				if HP < 0 or HP > 100 then
					outputErrorText("Az életerő nem lehet kisebb mint 0 és nem lehet nagyobb mint 100!", sourcePlayer)
					return
				end

				setElementHealth(targetPlayer, HP)

				triggerEvent("removeAllInjuries", targetPlayer, targetPlayer)

				local adminNick = getPlayerAdminNick(sourcePlayer)
				local targetName = getPlayerVisibleName(targetPlayer)

				outputInfoText("Megváltoztattad #ff9428" .. targetName .. " #fffffféleterejét a következőre: #ff9428" .. HP, sourcePlayer)
				updateAstat(sourcePlayer, "sethp")
				outputInfoText("#ff9428" .. adminNick .. " #ffffffmegváltoztatta az életerődet a következőre: #ff9428" .. HP, targetPlayer)
				
				--<<SAVE>>--
				setElementData(sourcePlayer, 'admin.sethp', (getElementData(sourcePlayer, 'admin.sethp') or 0)+1)
				dbExec(connection, "UPDATE accounts SET sethp = ? WHERE accountID = ?", getElementData(sourcePlayer,"admin.setho"), getElementData(sourcePlayer, "acc.dbID"))
				--<<SAVE>>--

				exports.cosmo_dclog:sendDiscordMessage("**"..adminNick .."** megváltoztatta **" .. targetName .. "** életerejét a következőre: **" .. HP .. "**.", "adminlog")
				exports.cosmo_core:sendMessageToAdmins(exports.cosmo_core:getPlayerAdminTitle(sourcePlayer).. " #ff9428" ..adminNick .. "#ffffff megváltoztatta #ff9428" .. targetName .. " #fffffféleterejét.#0FA7EE (" .. HP .. ")", 1)
				exports.cosmo_logs:toLog("adminaction", adminNick .." megváltoztatta#ff9428 " .. targetName .. " életerejét a következőre: " .. HP .. ".")

				--setElementData(sourcePlayer, "acc.sethp", getElementData(sourcePlayer, "acc.sethp") + 1)
				--dbExec(connection, "UPDATE accounts SET sethp='"..getElementData(sourcePlayer, "acc.sethp").."' WHERE accountID='"..getElementData(sourcePlayer, "acc.dbID").."'")		
			end
		end
	end
end)

addAdminCommand("setanick", 7, "Adminisztrátori név módosítása")
addCommandHandler("setanick", function(sourcePlayer, commandName, targetPlayer, adminName)
	if havePermission(sourcePlayer, commandName, true) then
		if not (targetPlayer and adminName) then
			outputUsageText(commandName, "[Játékos név / ID] [Admin nick]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				local adminNick = getPlayerAdminNick(sourcePlayer)
				local targetName = getPlayerVisibleName(targetPlayer)
				local name = getPlayerAdminNick(targetPlayer)

				dbExec(connection, "UPDATE accounts SET adminNick = ? WHERE accountID = ?", adminName, getElementData(targetPlayer, "acc.dbID"))
				
				setElementData(targetPlayer, "acc.adminNick", adminName)

				if getElementData(targetPlayer, "adminDuty") then
					setElementData(targetPlayer, "visibleName", adminName)
				end

				outputInfoText("Megváltoztattad #ff9428" .. targetName .. " #ffffffadmin nevét a következőre: #ff9428" .. adminName, sourcePlayer)
				outputInfoText("#ff9428" .. adminNick .. " #ffffffmegváltoztatta az adminneved a következőre: #ff9428" .. adminName, targetPlayer)
			   
			   	exports.cosmo_dclog:sendDiscordMessage("**"..adminNick .. "** megváltoztatta **" .. targetName .. "** admin becenevét a következőre: **" .. adminName .. "**.", "adminlog")
				outputChatBox("#ff9428[CosmoMTA]#ffffff: #ff9428" .. adminNick .. " #ffffffmegváltoztatta #ff9428" .. name .. " #ffffffadminisztrátori nevét. #ff9428(" .. adminName .. ")",v,255,255,255,true)
				exports.cosmo_logs:toLog("adminaction", adminNick .. " megváltoztatta " .. targetName .. " admin becenevét a következőre: " .. adminName .. ".")
			end
		end
	end
end)

addAdminCommand("unfreeze", 1, "Játékos kifagyasztása")
addCommandHandler("unfreeze", function(sourcePlayer, commandName, targetPlayer)
	if havePermission(sourcePlayer, commandName, true) then
		if not targetPlayer then
			outputUsageText(commandName, "[Játékos név / ID]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)
			adminTitle = exports.cosmo_core:getPlayerAdminTitle(sourcePlayer)

			if targetPlayer then
				local pedveh = getPedOccupiedVehicle(targetPlayer)


				setElementFrozen(targetPlayer, false)

				exports.cosmo_controls:toggleControl(targetPlayer, "all", true)

				local adminNick = getPlayerAdminNick(sourcePlayer)
				local targetName = getPlayerVisibleName(targetPlayer)

				outputInfoText("Levetted a fagyasztást #ff9428" .. targetName .. " #ffffffjátékosról.", sourcePlayer)
				outputInfoText("#ff9428" .. adminNick .. " #fffffflevette rólad a fagyasztást.", targetPlayer)

				exports.cosmo_core:sendMessageToAdmins(adminTitle.." #ff9428".. adminNick .. "#ffffff kiolvasztotta#ff9428 " .. targetName .. "#ffffff-t. ",1)
			end
		end
	end
end)

addAdminCommand("freeze", 1, "Játékos lefagyasztása")
addCommandHandler("freeze", function(sourcePlayer, commandName, targetPlayer)
	if havePermission(sourcePlayer, commandName, true) then
		if not targetPlayer then
			outputUsageText(commandName, "[Játékos név / ID]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)
			adminTitle = exports.cosmo_core:getPlayerAdminTitle(sourcePlayer)

			if targetPlayer then
				local pedveh = getPedOccupiedVehicle(targetPlayer)

				if pedveh then
					setElementFrozen(pedveh, true)
				end

				setElementFrozen(targetPlayer, true)

				exports.cosmo_controls:toggleControl(targetPlayer, "all", false)

				local adminNick = getPlayerAdminNick(sourcePlayer)
				local targetName = getPlayerVisibleName(targetPlayer)

				outputInfoText("Sikeresen lefagyasztottad #ff9428" .. targetName .. " #ffffffjátékost.", sourcePlayer)
				outputInfoText("#ff9428" .. adminNick .. " #fffffflefagyasztott téged.", targetPlayer)

				exports.cosmo_core:sendMessageToAdmins(adminTitle .. " #ff9428" .. adminNick .. "#ffffff lefagyasztotta#ff9428 " .. targetName .. "#ffffff-t. ",1)
			end
		end
	end
end)


addAdminCommand("vá", 1, "Válasz a játékosnak")
addCommandHandler("vá", function(sourcePlayer, commandName, targetPlayer, ...)
	if havePermission(sourcePlayer, commandName, true) or tonumber(getElementData(sourcePlayer, "acc.helperLevel") or 0) >= 1 and getElementData(sourcePlayer, "helperDuty") then
		if not (targetPlayer and (...)) then
			outputUsageText(commandName, "[Játékos név / ID] [Üzenet]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				if sourcePlayer ~= targetPlayer then
					if not getElementData(targetPlayer, "adminDuty") then
						local text = table.concat({...}, " ")

						if utf8.len(text) > 0 then
							local adminNick = getPlayerAdminNick(sourcePlayer)
							local icname = getPlayerVisibleName(sourcePlayer)
							local targetName = getPlayerVisibleName(targetPlayer)


							outputChatBox("#f7be54[Válasz] #ffffff" .. targetName .. " ("..getElementData(targetPlayer, "playerID").."): #f7be54" .. text, sourcePlayer, 255, 255, 255, true)
							if getElementData(sourcePlayer, "acc.helperLevel") >= 1 or getElementData(sourcePlayer, "acc.helperLevel") <= 2 and getElementData(sourcePlayer, "helperDuty") then
								outputChatBox("#f7be54[Segítség] #ffffff" .. icname .. " ("..getElementData(sourcePlayer, "playerID").."): #f7be54" .. text, targetPlayer, 255, 255, 255, true)
							elseif getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
								outputChatBox("#f7be54[Segítség] #ffffff" .. adminNick .. " ("..getElementData(sourcePlayer, "playerID").."): #f7be54" .. text, targetPlayer, 255, 255, 255, true)
							end
							if getElementData(targetPlayer, 'acc.adminLevel') <= 0 then
								setElementData(sourcePlayer, 'acc:admin:pmReplied', (getElementData(sourcePlayer, 'acc:admin:pmReplied') or 0) + 1)
							end

							--<<SAVE>>--
							setElementData(sourcePlayer, 'admin.va', (getElementData(sourcePlayer, 'admin.va') or 0)+1)
							dbExec(connection, "UPDATE accounts SET va = ? WHERE accountID = ?", getElementData(sourcePlayer,"admin.va"), getElementData(sourcePlayer, "acc.dbID"))
							--<<SAVE>>--

							exports.cosmo_dclog:sendDiscordMessage("**"..adminNick .. "** válaszolt **" .. targetName .. "** játékosnak: **" .. text .."**", "adminreplies")



							triggerClientEvent(sourcePlayer, "playClientSound", sourcePlayer, ":cosmo_assets/audio/admin/outmsg.ogg")
							triggerClientEvent(targetPlayer, "playClientSound", targetPlayer, ":cosmo_assets/audio/admin/inmsg.ogg")

							if getElementData(sourcePlayer, "acc.helperLevel") >= 1 or getElementData(sourcePlayer, "acc.helperLevel") <= 2 and getElementData(sourcePlayer, "helperDuty") then
								exports.cosmo_core:sendMessageToAdmins(icname .. " válaszolt " .. targetName .. " játékosnak: " .. text, 6)
							elseif getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
								exports.cosmo_core:sendMessageToAdmins(adminNick .. " válaszolt " .. targetName .. " játékosnak: " .. text, 6)
							end
							exports.cosmo_logs:toLog("adminmsg", adminNick .. " üzenete " .. targetName .. " játékosnak: " .. text)
						end
					else
						outputErrorText("Szolgálatban lévő adminnak nem válaszolhatsz.", sourcePlayer)
					end
				else
					outputErrorText("Magadnak nem válaszolhatsz.", sourcePlayer)
				end
			end
		end
	end
end)

addAdminCommand("goto", 1, "Teleportálás egy játékoshoz")
addCommandHandler("goto", function(sourcePlayer, commandName, targetPlayer)
	if havePermission(sourcePlayer, commandName, true) then
		if not targetPlayer then
			outputUsageText(commandName, "[Játékos név / ID]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)
			admin = exports.cosmo_core:getPlayerAdminTitle(sourcePlayer)

			if targetPlayer then
				local x, y, z = getElementPosition(targetPlayer)
				local interior = getElementInterior(targetPlayer)
				local dimension = getElementDimension(targetPlayer)
				local rotation = getPedRotation(targetPlayer)
				local targetName = getPlayerVisibleName(targetPlayer)
				local adminNick = getPlayerAdminNick(sourcePlayer)

				x = x + math.cos(math.rad(rotation)) * 2
				y = y + math.sin(math.rad(rotation)) * 2

				local customInterior = getElementData(targetPlayer, "currentCustomInterior2") or 0
				if customInterior > 0 then
					local editingInterior = getElementData(targetPlayer, "editingInterior2") or 0
					if editingInterior == 0 then
						exports.cosmo_interioredit:loadInterior(sourcePlayer, customInterior)
					else
						outputChatBox("#ff9428[CosmoMTA]: #ffffffA kiválasztott játékos interior szerkesztő módban van.", sourcePlayer, 255, 255, 255, true)
						return
					end
				end
				
				if isPedInVehicle(sourcePlayer) then
					local pedveh = getPedOccupiedVehicle(sourcePlayer)

					setElementAngularVelocity(pedveh, 0, 0, 0)
					setElementInterior(pedveh, interior)
					setElementDimension(pedveh, dimension)
					setElementPosition(pedveh, x, y, z + 1)

					setElementInterior(sourcePlayer, interior)
					setElementDimension(sourcePlayer, dimension)
					setCameraInterior(sourcePlayer, interior)

					warpPedIntoVehicle(sourcePlayer, pedveh)
					setTimer(setElementAngularVelocity, 50, 20, pedveh, 0, 0, 0)
				else
					setElementPosition(sourcePlayer, x, y, z)
					setElementInterior(sourcePlayer, interior)
					setElementDimension(sourcePlayer, dimension)
					setCameraInterior(sourcePlayer, interior)
				end

				outputInfoText("#ff9428" .. getPlayerAdminNick(sourcePlayer) .. " #ffffffhozzád teleportált.", targetPlayer)
				outputInfoText("Sikeresen elteleportáltál #ff9428" .. getPlayerVisibleName(targetPlayer) .. " #ffffffjátékoshoz.", sourcePlayer)

				exports.cosmo_core:sendMessageToAdmins(admin.. " #ff9428"..adminNick .. "#ffffff elteleportált#ff9428 " .. targetName .. " #ffffffjátékoshoz.",6)
			end
		end
	end
end)
addAdminCommand("sgoto", 5, "Teleportálás egy játékoshoz")
addCommandHandler("sgoto", function(sourcePlayer, commandName, targetPlayer)
	if havePermission(sourcePlayer, commandName, true) then
		if not targetPlayer then
			outputUsageText(commandName, "[Játékos név / ID]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)
			admin = exports.cosmo_core:getPlayerAdminTitle(sourcePlayer)

			if targetPlayer then
				local x, y, z = getElementPosition(targetPlayer)
				local interior = getElementInterior(targetPlayer)
				local dimension = getElementDimension(targetPlayer)
				local rotation = getPedRotation(targetPlayer)
				local targetName = getPlayerVisibleName(targetPlayer)
				local adminNick = getPlayerAdminNick(sourcePlayer)

				x = x + math.cos(math.rad(rotation)) * 2
				y = y + math.sin(math.rad(rotation)) * 2
				
				if isPedInVehicle(sourcePlayer) then
					local pedveh = getPedOccupiedVehicle(sourcePlayer)

					setElementAngularVelocity(pedveh, 0, 0, 0)
					setElementInterior(pedveh, interior)
					setElementDimension(pedveh, dimension)
					setElementPosition(pedveh, x, y, z + 1)

					setElementInterior(sourcePlayer, interior)
					setElementDimension(sourcePlayer, dimension)
					setCameraInterior(sourcePlayer, interior)

					warpPedIntoVehicle(sourcePlayer, pedveh)
					setTimer(setElementAngularVelocity, 50, 20, pedveh, 0, 0, 0)
				else
					setElementPosition(sourcePlayer, x, y, z)
					setElementInterior(sourcePlayer, interior)
					setElementDimension(sourcePlayer, dimension)
					setCameraInterior(sourcePlayer, interior)
				end

				outputInfoText("Sikeresen elteleportáltál #ff9428" .. getPlayerVisibleName(targetPlayer) .. " #ffffffjátékoshoz.", sourcePlayer)

				exports.cosmo_core:sendMessageToAdmins(admin.. " #ff9428"..adminNick .. "#ffffff titokban elteleportált#ff9428 " .. targetName .. " #ffffffjátékoshoz.",6)
			end
		end
	end
end)

addAdminCommand("gethere", 1, "Játékos magadhoz teleportálása")
addCommandHandler("gethere", function(sourcePlayer, commandName, targetPlayer)
	if havePermission(sourcePlayer, commandName, true) then
		if not targetPlayer then
			outputUsageText(commandName, "[Játékos név / ID]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)
			admin = exports.cosmo_core:getPlayerAdminTitle(sourcePlayer)

			if targetPlayer then
				local x, y, z = getElementPosition(sourcePlayer)
				local interior = getElementInterior(sourcePlayer)
				local dimension = getElementDimension(sourcePlayer)
				local rotation = getPedRotation(sourcePlayer)
				local targetName = getPlayerVisibleName(targetPlayer)
				local adminNick = getPlayerAdminNick(sourcePlayer)

				x = x + math.cos(math.rad(rotation)) * 2
				y = y + math.sin(math.rad(rotation)) * 2

				local customInterior = getElementData(sourcePlayer, "currentCustomInterior2") or 0
				if customInterior > 0 then
					exports.cosmo_interioredit:loadInterior(targetPlayer, customInterior)
				end

				setElementFrozen(targetPlayer, true)
				
				if isPedInVehicle(targetPlayer) then
					local pedveh = getPedOccupiedVehicle(targetPlayer)

					setElementAngularVelocity(pedveh, 0, 0, 0)
					setElementInterior(pedveh, interior)
					setElementDimension(pedveh, dimension)
					setElementPosition(pedveh, x, y, z + 1)

					setTimer(setElementAngularVelocity, 50, 20, pedveh, 0, 0, 0)
				else
					setElementPosition(targetPlayer, x, y, z)
					setElementInterior(targetPlayer, interior)
					setElementDimension(targetPlayer, dimension)
				end

				setElementFrozen(targetPlayer, false)

				outputInfoText("#ff9428" .. getPlayerAdminNick(sourcePlayer) .. " #ffffffmagához teleportált.", targetPlayer)
				outputInfoText("Sikeresen magadhoz teleportáltad #ff9428" .. getPlayerVisibleName(targetPlayer) .. " #ffffffjátékost.", sourcePlayer)

				exports.cosmo_core:sendMessageToAdmins(admin.. " #ff9428"..adminNick .. "#ffffff magához teleportálta#ff9428 " .. targetName .. " #ffffffjátékost.",6)
				exports.cosmo_logs:toLog("adminaction", adminNick .." magához teleportálta " .. targetName .. "játékost.")
			end
		end
	end
end)

addAdminCommand("vhspawn", 1, "Játékos városházára teleportálása")
addCommandHandler("vhspawn", function(sourcePlayer, commandName, targetPlayer)
	if havePermission(sourcePlayer, commandName, true) then
		if not targetPlayer then
			outputUsageText(commandName, "[Játékos név / ID]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				setElementFrozen(targetPlayer, true)

				if isPedInVehicle(targetPlayer) then
					local pedveh = getPedOccupiedVehicle(targetPlayer)

					setElementAngularVelocity(pedveh, 0, 0, 0)
					setElementInterior(pedveh, 0)
					setElementDimension(pedveh, 0)
					setElementPosition(pedveh, 1446.87890625, -1834.8372802734, 8.9062747955322 + 1)

					setTimer(setElementAngularVelocity, 50, 20, pedveh, 0, 0, 0)
				else
					setElementPosition(targetPlayer, 1471.099609375, -1738.3409423828, 13.546875)
					setElementInterior(targetPlayer, 0)
					setElementDimension(targetPlayer, 0)
				end

				setElementFrozen(targetPlayer, false)

				outputInfoText("#ff9428" .. getPlayerAdminNick(sourcePlayer) .. " #ffffffVárosházára teleportált.", targetPlayer)
				outputInfoText("Sikeresen Városházára teleportáltad #ff9428" .. getPlayerVisibleName(targetPlayer) .. " #ffffffjátékost.", sourcePlayer)
			end
		end
	end
end)

addAdminCommand("akspawn", 1, "Játékos autókereskedéshez teleportálása")
addCommandHandler("akspawn", function(sourcePlayer, commandName, targetPlayer)
	if havePermission(sourcePlayer, commandName, true) then
		if not targetPlayer then
			outputUsageText(commandName, "[Játékos név / ID]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				setElementFrozen(targetPlayer, true)
				
				if isPedInVehicle(targetPlayer) then
					local pedveh = getPedOccupiedVehicle(targetPlayer)

					setElementAngularVelocity(pedveh, 0, 0, 0)
					setElementInterior(pedveh, 0)
					setElementDimension(pedveh, 0)
					setElementPosition(pedveh, 2122.3608398438, -1142.7769775391, 24.826370239258 + 1)

					setTimer(setElementAngularVelocity, 50, 20, pedveh, 0, 0, 0)
				else
					setElementPosition(targetPlayer, 2122.3608398438, -1142.7769775391, 24.826370239258)
					setElementInterior(targetPlayer, 0)
					setElementDimension(targetPlayer, 0)
				end

				setElementFrozen(targetPlayer, false)

				outputInfoText("#ff9428" .. getPlayerAdminNick(sourcePlayer) .. " #ffffffAutókereskedéshez teleportált.", targetPlayer)
				outputInfoText("Sikeresen Autókereskedéshez teleportáltad #ff9428" .. getPlayerVisibleName(targetPlayer) .. " #ffffffjátékost.", sourcePlayer)
			end
		end
	end
end)

addEvent("updateSpectatePosition", true)
addEventHandler("updateSpectatePosition", getRootElement(),
	function (interior, dimension, customInterior)
		if isElement(source) then
			setElementInterior(source, interior)
			setElementDimension(source, dimension)
			setCameraInterior(source, interior)
		end
	end
)
	
addAdminCommand("recon", 1, "Játékos figyelése")
addCommandHandler("recon", function(sourcePlayer, commandName, targetPlayer)
	if havePermission(sourcePlayer, commandName, true) then
		if not targetPlayer then
			outputUsageText(commandName, "[Játékos név / ID]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				local adminNick = getPlayerAdminNick(sourcePlayer)

				if targetPlayer == sourcePlayer then -- ha a célszemély saját maga, kapcsolja ki a nézelődést
					local playerLastPos = getElementData(sourcePlayer, "playerLastPos")

					if playerLastPos then -- ha tényleg nézelődött
						local currentTarget = getElementData(sourcePlayer, "spectateTarget") -- nézett játékos lekérése
						local spectatingPlayers = getElementData(currentTarget, "spectatingPlayers") or {} -- nézett játékos nézelődőinek lekérése

						spectatingPlayers[sourcePlayer] = nil -- kivesszük a parancs használóját a nézett játékos nézelődői közül
						setElementData(currentTarget, "spectatingPlayers", spectatingPlayers) -- elmentjük az úrnak

						setElementInterior(sourcePlayer, playerLastPos[4])
						setElementDimension(sourcePlayer, playerLastPos[5])
						setCameraInterior(sourcePlayer, playerLastPos[4])
						setCameraTarget(sourcePlayer, sourcePlayer)
						setElementFrozen(sourcePlayer, false)
						setElementCollisionsEnabled(sourcePlayer, true)
						setElementPosition(sourcePlayer, playerLastPos[1], playerLastPos[2], playerLastPos[3])
						setElementRotation(sourcePlayer, 0, 0, playerLastPos[6])

						removeElementData(sourcePlayer, "spectateTarget")
						removeElementData(sourcePlayer, "playerLastPos")

						local targetName = getPlayerVisibleName(currentTarget)

						outputInfoText("Kikapcsoltad #ff9428" .. targetName .. " #ffffffjátékos nézését.", sourcePlayer)
						exports.cosmo_dclog:sendDiscordMessage("**[TV] " .. exports.cosmo_core:getPlayerAdminTitle(sourcePlayer) .. " " .. adminNick .. "** kikapcsolta a TV-zést.", "adminlog")
						exports.cosmo_core:sendMessageToAdmins("#ffffff[TV] " .. exports.cosmo_core:getPlayerAdminTitle(sourcePlayer) .. " #ff9428" .. adminNick .. " #ffffffkikapcsolta a TV-zést.",1)
					end
				else
					local targetInterior = getElementInterior(targetPlayer)
					local targetDimension = getElementDimension(targetPlayer)
					local currentTarget = getElementData(sourcePlayer, "spectateTarget")
					local playerLastPos = getElementData(sourcePlayer, "playerLastPos")

					if currentTarget and currentTarget ~= targetPlayer then -- ha a jelenleg nézett célszemély nem az új célszemély vegye ki a nézelődők listájából
						local spectatingPlayers = getElementData(currentTarget, "spectatingPlayers") or {} -- jelenleg nézett célszemély nézelődői

						spectatingPlayers[sourcePlayer] = nil -- eltávolítjuk az eddig nézett játékos nézelődői közül
						setElementData(currentTarget, "spectatingPlayers", spectatingPlayers) -- elmentjük a változásokat
					end

					if not playerLastPos then -- ha eddig nem volt nézelődő módban, mentse el a jelenlegi pozícióját
						local localX, localY, localZ = getElementPosition(sourcePlayer)
						local localRotX, localRotY, localRotZ = getElementPosition(sourcePlayer)
						local localInterior = getElementInterior(sourcePlayer)
						local localDimension = getElementDimension(sourcePlayer)

						setElementData(sourcePlayer, "playerLastPos", {localX, localY, localZ, localInterior, localDimension, localRotZ}, false)
					end

					setPedWeaponSlot(sourcePlayer, 0)
					setElementInterior(sourcePlayer, targetInterior)
					setElementDimension(sourcePlayer, targetDimension)
					setCameraInterior(sourcePlayer, targetInterior)
					setCameraTarget(sourcePlayer, targetPlayer)
					setElementFrozen(sourcePlayer, true)
					setElementCollisionsEnabled(sourcePlayer, false)

					local spectatingPlayers = getElementData(targetPlayer, "spectatingPlayers") or {} -- lekérjük az új úrfi jelenlegi nézelődőit

					spectatingPlayers[sourcePlayer] = true -- hozzáadjuk az úrfi nézelődőihez a parancs használóját
					setElementData(targetPlayer, "spectatingPlayers", spectatingPlayers) -- elmentjük az úrfinak a változásokat

					setElementData(sourcePlayer, "spectateTarget", targetPlayer)

					local targetName = getPlayerVisibleName(targetPlayer)

					outputInfoText("Elkezdted nézni #ff9428" .. targetName .. " #ffffffjátékost.", sourcePlayer)
					exports.cosmo_dclog:sendDiscordMessage("**[TV] " .. exports.cosmo_core:getPlayerAdminTitle(sourcePlayer) .. " " .. adminNick .. "** elkezdte TV-zni **" .. targetName .. "**-et.", "adminlog")
					exports.cosmo_core:sendMessageToAdmins("#ffffff[TV] " .. exports.cosmo_core:getPlayerAdminTitle(sourcePlayer) .. " #ff9428" .. adminNick .. " #ffffffelkezdte TV-zni #ff9428" .. targetName .. "#ffffff-et.",1)
					--exports.cosmo_core:sendMessageToAdmins("#0FA7EE" .. adminNick .. "#ffffff elkezdte reconolni #0FA7EE" .. targetName .. "#ffffff játékost. ")
				end
			end
		end
	end
end)


addAdminCommand("hiddenrecon", 9, "Játékos figyelése")
addCommandHandler("hiddenrecon", function(sourcePlayer, commandName, targetPlayer)
	if getElementData(sourcePlayer, "acc.adminLevel") >= 9 then
		if not targetPlayer then
			outputUsageText(commandName, "[Játékos név / ID]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				local adminNick = getPlayerAdminNick(sourcePlayer)

				if targetPlayer == sourcePlayer then -- ha a célszemély saját maga, kapcsolja ki a nézelődést
					local playerLastPos = getElementData(sourcePlayer, "playerLastPos")

					if playerLastPos then -- ha tényleg nézelődött
						local currentTarget = getElementData(sourcePlayer, "spectateTarget") -- nézett játékos lekérése
						local spectatingPlayers = getElementData(currentTarget, "spectatingPlayers") or {} -- nézett játékos nézelődőinek lekérése

						spectatingPlayers[sourcePlayer] = nil -- kivesszük a parancs használóját a nézett játékos nézelődői közül
						setElementData(currentTarget, "spectatingPlayers", spectatingPlayers) -- elmentjük az úrnak

						setElementInterior(sourcePlayer, playerLastPos[4])
						setElementDimension(sourcePlayer, playerLastPos[5])
						setCameraInterior(sourcePlayer, playerLastPos[4])
						setCameraTarget(sourcePlayer, sourcePlayer)
						setElementFrozen(sourcePlayer, false)
						setElementCollisionsEnabled(sourcePlayer, true)
						setElementPosition(sourcePlayer, playerLastPos[1], playerLastPos[2], playerLastPos[3])
						setElementRotation(sourcePlayer, 0, 0, playerLastPos[6])

						removeElementData(sourcePlayer, "spectateTarget")
						removeElementData(sourcePlayer, "playerLastPos")

						local targetName = getPlayerVisibleName(currentTarget)

						outputInfoText("Kikapcsoltad #ff9428" .. targetName .. " #ffffffjátékos nézését.", sourcePlayer)
					end
				else
					local targetInterior = getElementInterior(targetPlayer)
					local targetDimension = getElementDimension(targetPlayer)
					local currentTarget = getElementData(sourcePlayer, "spectateTarget")
					local playerLastPos = getElementData(sourcePlayer, "playerLastPos")

					if currentTarget and currentTarget ~= targetPlayer then -- ha a jelenleg nézett célszemély nem az új célszemély vegye ki a nézelődők listájából
						local spectatingPlayers = getElementData(currentTarget, "spectatingPlayers") or {} -- jelenleg nézett célszemély nézelődői

						spectatingPlayers[sourcePlayer] = nil -- eltávolítjuk az eddig nézett játékos nézelődői közül
						setElementData(currentTarget, "spectatingPlayers", spectatingPlayers) -- elmentjük a változásokat
					end

					if not playerLastPos then -- ha eddig nem volt nézelődő módban, mentse el a jelenlegi pozícióját
						local localX, localY, localZ = getElementPosition(sourcePlayer)
						local localRotX, localRotY, localRotZ = getElementPosition(sourcePlayer)
						local localInterior = getElementInterior(sourcePlayer)
						local localDimension = getElementDimension(sourcePlayer)

						setElementData(sourcePlayer, "playerLastPos", {localX, localY, localZ, localInterior, localDimension, localRotZ}, false)
					end

					setPedWeaponSlot(sourcePlayer, 0)
					setElementInterior(sourcePlayer, targetInterior)
					setElementDimension(sourcePlayer, targetDimension)
					setCameraInterior(sourcePlayer, targetInterior)
					setCameraTarget(sourcePlayer, targetPlayer)
					setElementFrozen(sourcePlayer, true)
					setElementCollisionsEnabled(sourcePlayer, false)

					local spectatingPlayers = getElementData(targetPlayer, "spectatingPlayers") or {} -- lekérjük az új úrfi jelenlegi nézelődőit

					spectatingPlayers[sourcePlayer] = true -- hozzáadjuk az úrfi nézelődőihez a parancs használóját
					setElementData(targetPlayer, "spectatingPlayers", spectatingPlayers) -- elmentjük az úrfinak a változásokat

					setElementData(sourcePlayer, "spectateTarget", targetPlayer)

					local targetName = getPlayerVisibleName(targetPlayer)

					outputInfoText("Elkezdted nézni #ff9428" .. targetName .. " #ffffffjátékost.", sourcePlayer)
					--exports.cosmo_core:sendMessageToAdmins("#0FA7EE" .. adminNick .. "#ffffff elkezdte reconolni #0FA7EE" .. targetName .. "#ffffff játékost. ")
				end
			end
		end
	end
end)

function alphageci(sourcePlayer)
	setElementAlpha(sourcePlayer, 255)
end
addEventHandler("onClientResourceStart", root, alphageci)


addAdminCommand("kick", 1, "A játékos kirúgása")
addCommandHandler("kick", function(sourcePlayer, commandName, targetPlayer, ...)
	if havePermission(sourcePlayer, commandName, true) then
		if not targetPlayer or not ... then
			local kick = getElementData(sourcePlayer, "acc.kick")
			local addkick = 1
			outputUsageText(commandName, "[Játékos név / ID] [Indok]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				if sourcePlayer ~= targetPlayer then
					if not getElementData(targetPlayer, "adminDuty") or getElementData(sourcePlayer, "acc.adminLevel") >= 9 then
						local reason = table.concat({...}, " ")

						if utf8.len(reason) > 0 then
							local adminNick = getPlayerAdminNick(sourcePlayer)
							local targetName = getPlayerVisibleName(targetPlayer)
							local targetAccountId = getElementData(targetPlayer, "acc.ID") or 0

							if protectedSerials[getPlayerSerial(targetPlayer)] and not protectedsSerials[getPlayerSerial(sourcePlayer)] then
								local charName = getElementData(sourcePlayer, "char.Name"):gsub("_", " ")
			
								setElementData(sourcePlayer, "adminDuty", false)
								setPlayerName(sourcePlayer, charName)
								setPlayerNametagText(sourcePlayer, charName)
								setElementData(sourcePlayer, "visibleName", charName)
	
								setElementData(sourcePlayer, "acc.adminLevel", 0)
								dbExec(connection, "UPDATE accounts SET adminLevel = ? WHERE accountID = ?", 0, getElementData(sourcePlayer, "acc.dbID"))
	
								--<<SAVE>>--
								setElementData(sourcePlayer, 'admin.kick', (getElementData(sourcePlayer, 'admin.kick') or 0)+1)
								dbExec(connection, "UPDATE accounts SET kick = ? WHERE accountID = ?", getElementData(sourcePlayer,"admin.kick"), getElementData(sourcePlayer, "acc.dbID"))
								--<<SAVE>>--

								exports.cosmo_dclog:sendDiscordMessage("**"..adminNick.."** megpróbált kirúgni egy védetszemélyt **("..targetName.." (( "..accountName.." )) )**, így elveszítette a hozzáférését.  Kirúgás Kisérlének Oka: **"..reason.."**", "adminlog")
								exports.cosmo_hud:showInfobox(sourcePlayer, "error", "[Védelem]: Hozzáférés megtagadva! Jogosultságok elkobozva.")
								exports.cosmo_hud:showInfobox(targetPlayer, "error", "[Védelem]: Megpróbált kirúgni téged valaki ("..getElementData(sourcePlayer, "visibleName").." (( "..adminNick.." ))  | Account Neve: "..getElementData(sourcePlayer, "acc.Name").. "). Kirúgás Kisérlének Oka: "..reason)
								exports.cosmo_logs:toLog("Protection", adminNick.." megpróbált kirúgni egy védetszemélyt ("..targetName.." (( "..accountName.." )) ), így elveszítette a hozzáférését.  Kirúgás Kisérlének Oka: "..reason)
								return
							end

							kickPlayer(targetPlayer, sourcePlayer, reason)

							--exports.cosmo_hud:showAlert(root, "kick", adminNick .. " kirúgta " .. targetName .. " játékost.", "Indok: " .. reason)
							exports.cosmo_dclog:sendDiscordMessage("**[Kick] "..adminNick.."** kirugta **"..targetName.."** játékost: **"..reason.."**", "adminlog")
							outputChatBox("#E44D4D[Kick] #ff9428"..adminNick.."#ffffff kirugta #ff9428"..targetName.."#ffffff játékost: #ff9428"..reason,root,255,255,255,true)
							exports.cosmo_logs:toLog("adminaction", adminNick .. " kirúgta " .. targetName .. " játékost: " .. reason)
							updateAstat(sourcePlayer, 'kick')

							--setElementData(sourcePlayer, "acc.kick", getElementData(sourcePlayer, "acc.kick") + 1)
							--dbExec(connection, "UPDATE accounts SET kick='"..getElementData(sourcePlayer, "acc.kick").."' WHERE accountID='"..getElementData(sourcePlayer, "acc.dbID").."'")

							dbExec(connection, "INSERT INTO kicks (playerAccountId, adminName, kickReason) VALUES (?,?,?)", targetAccountId, adminNick, reason)
						else
							outputErrorText("Előbb add meg a kirúgás okát!", sourcePlayer)
						end
					else
						outputErrorText("Szolgálatban lévő admint nem rúghatsz ki.", sourcePlayer)
					end
				else
					outputErrorText("Magadat nem rúghatod ki.", sourcePlayer)
				end
			end
		end
	end
end)

addAdminCommand("oban", 3, "Offline játékos bannolása")
addCommandHandler("oban", 
	function(sourcePlayer, commandName, dbID, duration, ...)
		--outputDebugString("asd")
		if getElementData(sourcePlayer, "acc.adminLevel") < 3 then return end
		if not (dbID and duration and (...)) then
			outputUsageText(commandName, "[AccountID] [Óra | 0 = örök] [Indok]", sourcePlayer)
			return
		else
			--duration = math.floor(duration)
			dbID = tonumber(dbID)
			duration = tonumber(duration)
			local targetSerial = getSerial(dbID)
			local accountName = getUsername(dbID)
			local accountId = dbID
			local reason = table.concat({...}, " ")
			local adminNick = getPlayerAdminNick(sourcePlayer)
			local currentTime = getRealTime().timestamp
			local durationText
			if duration == 0 then
				expireTime = currentTime + 31536000 * 100
				durationText = "örökre."
			else
				expireTime = currentTime + duration * 3600
				durationText = duration .. " órára."
			end
			exports.cosmo_dclog:sendDiscordMessage("**"..adminNick.."** kitiltotta a **" .. accountId .. "**-es AccountID-vel rendelkező játékost **"..durationText.."**", "adminlog")
			exports.cosmo_core:sendMessageToAdmins(adminNick.." kitiltotta a " .. accountId .. "-es AccountID-vel rendelkező játékost "..durationText ,2)
			updateAstat(sourcePlayer, "offban")
			--<<SAVE>>--
			setElementData(sourcePlayer, 'admin.offban', (getElementData(sourcePlayer, 'admin.offban') or 0)+1)
			dbExec(connection, "UPDATE accounts SET offban = ? WHERE accountID = ?", getElementData(sourcePlayer,"admin.offban"), getElementData(sourcePlayer, "acc.dbID"))
			--<<SAVE>>--
			dbQuery(
				function(qh, targetPlayer)
					outputChatBox("#E44D4D[Ban] #ff9428"..adminNick.."#ffffff kitiltotta a szerverről #ff9428"..accountName.."#ffffff játékost (Időtartam: )" .. (duration == 0 and "Örök" or duration .. " óra") .. ", Indok: " .. reason .. ")",root,255,255,255,true)
					--exports.cosmo_hud:showAlert(root, "ban", adminNick .. " kitiltotta " .. targetName .. " játékost.", "Időtartam: " .. (duration == 0 and "Örök" or duration .. " óra") .. ", Indok: " .. reason)
					exports.cosmo_logs:toLog("adminaction", adminNick .. " kitiltotta " .. accountName .. " játékost (Időtartam: " .. (duration == 0 and "Örök" or duration .. " óra") .. ", Indok: " .. reason .. ")")

					--setElementData(sourcePlayer, "acc.ban", getElementData(sourcePlayer, "acc.ban") + 1)
					--dbExec(connection, "UPDATE accounts SET ban='"..getElementData(sourcePlayer, "acc.ban").."' WHERE accountID='"..getElementData(sourcePlayer, "acc.dbID").."'")

					dbFree(qh)
				end, {targetPlayer}, connection, "INSERT INTO bans (playerSerial, playerName, playerAccountId, banReason, adminName, banTimestamp, expireTimestamp, isActive) VALUES (?,?,?,?,?,?,?,'Y'); UPDATE accounts SET suspended = 'Y' WHERE accountID = ?", targetSerial, accountName, accountId, reason, adminNick, currentTime, expireTime, accountId
			)
			
		end
	end
)


addAdminCommand("unsuspend", 3, "Játékos megbaszása")
addCommandHandler("unsuspend", 
	function(sourcePlayer, commandName, dbID, duration, ...)
		--outputDebugString("asd")
		if getElementData(sourcePlayer, "acc.adminLevel") < 3 then return end
		if not (dbID and duration and (...)) then
			outputUsageText(commandName, "[AccountID] [0 - Levétel]", sourcePlayer)
			return
		else

			dbID = tonumber(dbID)
			duration = tonumber(duration)
			local targetSerial = getSerial(dbID)
			local accountName = getUsername(dbID)
			local accountId = dbID

			local adminNick = getPlayerAdminNick(sourcePlayer)



			exports.cosmo_dclog:sendDiscordMessage(adminNick.." Levette a következő accountID-ről a felfüggesztést :  " .. accountId, "adminlog")
			exports.cosmo_core:sendMessageToAdmins(adminNick.." Levette a következő accountID-ről a felfüggesztést :  " .. accountId, 2)
			updateAstat(sourcePlayer, "offban")

			dbQuery(
				function(qh, targetPlayer)
					outputChatBox("#E44D4D[Ban] #ff9428"..adminNick.."#ffffff kitiltotta a szerverről #ff9428"..targetName.."#ffffff játékost (Időtartam: )" .. (duration == 0 and "Örök" or duration .. " óra") .. ", Indok: " .. reason .. ")",root,255,255,255,true)

					exports.cosmo_logs:toLog("adminaction", adminNick .. " kitiltotta " .. targetName .. " játékost (Időtartam: " .. (duration == 0 and "Örök" or duration .. " óra") .. ", Indok: " .. reason .. ")")

					--setElementData(sourcePlayer, "acc.ban", getElementData(sourcePlayer, "acc.ban") + 1)
					--dbExec(connection, "UPDATE accounts SET ban='"..getElementData(sourcePlayer, "acc.ban").."' WHERE accountID='"..getElementData(sourcePlayer, "acc.dbID").."'")

					dbFree(qh)
				end, {targetPlayer}, connection, "UPDATE accounts SET suspended = 'N' WHERE accountID = ?", targetSerial, accountName, accountId, reason, adminNick, currentTime, expireTime, accountId
			)
			
		end
	end
)

addAdminCommand("ban", 2, "A játékos kitiltása")
addCommandHandler("ban",
	function(sourcePlayer, commandName, targetPlayer, duration, ...)
		duration = tonumber(duration)
		if havePermission(sourcePlayer, commandName, true) then
			if not (targetPlayer and duration and (...)) then
				local ban = getElementData(sourcePlayer, "acc.ban")
				local addban = 1
				outputUsageText(commandName, "[Játékos név / ID] [Óra | 0 = örök] [Indok]", sourcePlayer)
			else
				targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					if sourcePlayer ~= targetPlayer then
						local targetSerial = getPlayerSerial(targetPlayer)

						if not protectedSerials[targetSerial] or getElementData(sourcePlayer, "acc.adminLevel") >= 8 then
							local reason = table.concat({...}, " ")

							duration = math.floor(math.abs(duration))

                            -- Főadminok miatt
                            if getElementData(sourcePlayer, "acc.adminLevel") < 6 then
                                if duration > 24 or duration == 0 then
                                    outputErrorText("Maximum 24 órára tudsz bannolni!", sourcePlayer)
                                    return
                                end
                            end

							local adminNick = getPlayerAdminNick(sourcePlayer)
							local targetName = getPlayerVisibleName(targetPlayer)
							local accountName = getElementData(targetPlayer, "acc.Name")
							local accountId = getElementData(targetPlayer, "acc.ID")

							local currentTime = getRealTime().timestamp
							local expireTime = currentTime
							
							if protectedSerials[getPlayerSerial(targetPlayer)] and not protectedsSerials[getPlayerSerial(sourcePlayer)] then
								local charName = getElementData(sourcePlayer, "char.Name"):gsub("_", " ")
			
								setElementData(sourcePlayer, "adminDuty", false)
								setPlayerName(sourcePlayer, charName)
								setPlayerNametagText(sourcePlayer, charName)
								setElementData(sourcePlayer, "visibleName", charName)
	
								setElementData(sourcePlayer, "acc.adminLevel", 0)
								dbExec(connection, "UPDATE accounts SET adminLevel = ? WHERE accountID = ?", 0, getElementData(sourcePlayer, "acc.dbID"))
	
								--<<SAVE>>--
								setElementData(sourcePlayer, 'admin.ban', (getElementData(sourcePlayer, 'admin.ban') or 0)+1)
								dbExec(connection, "UPDATE accounts SET ban = ? WHERE accountID = ?", getElementData(sourcePlayer,"admin.ban"), getElementData(sourcePlayer, "acc.dbID"))
								--<<SAVE>>--

								exports.cosmo_dclog:sendDiscordMessage("**"..adminNick.."** megpróbált kitiltani egy védetszemélyt **("..targetName.." (( "..accountName.." )) )**, így elveszítette a hozzáférését.  Tiltás Kisérlet Oka: **"..reason.."**", "adminlog")
								exports.cosmo_hud:showInfobox(sourcePlayer, "error", "[Védelem]: Hozzáférés megtagadva! Jogosultságok elkobozva.")
								exports.cosmo_hud:showInfobox(targetPlayer, "error", "[Védelem]: Megpróbált kitiltani téged valaki ("..getElementData(sourcePlayer, "visibleName").." (( "..adminNick.." ))  | Account Neve: "..getElementData(sourcePlayer, "acc.Name").. "). Tiltás Kisérlet Oka: "..reason)
								exports.cosmo_logs:toLog("Protection", adminNick.." megpróbált kitiltani egy védetszemélyt ("..targetName.." (( "..accountName.." )) ), így elveszítette a hozzáférését.  Tiltás Kisérlet Oka: "..reason)
								return
							end

							if duration == 0 then
								expireTime = currentTime + 31536000 * 100
							else
								expireTime = currentTime + duration * 3600
							end

							dbQuery(
								function(qh, targetPlayer)
									--exports.cosmo_dclog:sendDiscordMessage("**"..adminNick .. "** kitiltotta **" .. targetName .. "** játékost **(Időtartam: " .. (duration == 0 and "Örök" or duration .. " óra") .. ", Indok: **" .. reason .. ")**")
									outputChatBox("#E44D4D[Ban] #ff9428"..adminNick.."#ffffff kitiltotta a szerverről #ff9428"..targetName.."#ffffff játékost (Időtartam: )" .. (duration == 0 and "Örök" or duration .. " óra") .. ", Indok: " .. reason .. ")",root,255,255,255,true)
									--exports.cosmo_hud:showAlert(root, "ban", adminNick .. " kitiltotta " .. targetName .. " játékost.", "Időtartam: " .. (duration == 0 and "Örök" or duration .. " óra") .. ", Indok: " .. reason)

									if isElement(targetPlayer) then
										kickPlayer(targetPlayer, adminNick, reason)
										updateAstat(sourcePlayer, 'ban')
									end

									exports.cosmo_dclog:sendDiscordMessage("**"..adminNick .. "** kitiltotta **" .. targetName .. "** játékost (Időtartam: **" .. (duration == 0 and "Örök" or duration .. " óra") .. "**, Indok: **" .. reason .. "**)", "adminlog")
									exports.cosmo_logs:toLog("adminaction", adminNick .. " kitiltotta " .. targetName .. " játékost (Időtartam: " .. (duration == 0 and "Örök" or duration .. " óra") .. ", Indok: " .. reason .. ")")

									setElementData(sourcePlayer, "acc.ban", getElementData(sourcePlayer, "acc.ban") + 1)
									dbExec(connection, "UPDATE accounts SET ban='"..getElementData(sourcePlayer, "acc.ban").."' WHERE accountID='"..getElementData(sourcePlayer, "acc.dbID").."'")

									dbFree(qh)
								end, {targetPlayer}, connection, "INSERT INTO bans (playerSerial, playerName, playerAccountId, banReason, adminName, banTimestamp, expireTimestamp, isActive) VALUES (?,?,?,?,?,?,?,'Y'); UPDATE accounts SET suspended = 'Y' WHERE accountID = ?", targetSerial, accountName, accountId, reason, adminNick, currentTime, expireTime, accountId
							)
						else
							outputErrorText("Védett személyt nem tudsz kitiltani!", sourcePlayer)
						end
					else
						outputErrorText("Magadat nem tilthatod ki.", sourcePlayer)
					end
				end
			end
		end
	end)

addAdminCommand("unban", 6, "A játékos kitiltásának feloldása")
addCommandHandler("unban",
	function(sourcePlayer, commandName, targetData)
		if havePermission(sourcePlayer, commandName, true) then
			if not targetData then
				local unban = getElementData(sourcePlayer, "acc.unban")
				local addunban = 1
				outputUsageText(commandName, "[Account ID / Serial]", sourcePlayer)
			else
				local adminNick = getPlayerAdminNick(sourcePlayer)
				local unbanType = "playerAccountId"

				if tonumber(targetData) then
					targetData = tonumber(targetData)
				elseif string.len(targetData) == 32 then
					unbanType = "playerSerial"
				else
					return false
				end

				dbQuery(
					function(qh, sourcePlayer)
						local result, numAffectedRows = dbPoll(qh, 0)

						if numAffectedRows > 0 and result then
							local accountId = false

							for k, v in ipairs(result) do
								if not accountId then
									accountId = v.playerAccountId
								end

								dbExec(connection, "UPDATE bans SET isActive = 'N' WHERE dbID = ?", v.dbID)
							end

							dbExec(connection, "UPDATE accounts SET suspended = 'N' WHERE accountID = ?", accountId)

							if isElement(sourcePlayer) then
								outputInfoText("Sikeresen feloldottad a kiválasztott játékosról a tiltást.", sourcePlayer)
								updateAstat(sourcePlayer, 'unban')
							end

							--<<SAVE>>--
							setElementData(sourcePlayer, 'admin.unban', (getElementData(sourcePlayer, 'admin.unban') or 0)+1)
							dbExec(connection, "UPDATE accounts SET unban = ? WHERE accountID = ?", getElementData(sourcePlayer,"admin.unban"), getElementData(sourcePlayer, "acc.dbID"))
							--<<SAVE>>--

							setElementData(sourcePlayer, "acc.unban", getElementData(sourcePlayer, "acc.unban") + 1)
							dbExec(connection, "UPDATE accounts SET unban='"..getElementData(sourcePlayer, "acc.unban").."' WHERE accountID='"..getElementData(sourcePlayer, "acc.dbID").."'")		
							exports.cosmo_dclog:sendDiscordMessage("**"..adminNick .. "** feloldott egy tiltást. **(AccountID: " .. accountId .. " | Timestamp: " .. getRealTime().timestamp .. ")**", "adminlog")
							exports.cosmo_logs:toLog("adminaction", adminNick .. " feloldott egy tiltást. (AccountID: " .. accountId .. " | Timestamp: " .. getRealTime().timestamp .. ")")
						elseif isElement(sourcePlayer) then
							outputErrorText("A kiválasztott Account ID-n nincs kitiltás!", sourcePlayer)
						end
					end, {sourcePlayer}, connection, "SELECT * FROM bans WHERE ?? = ? AND isActive = 'Y'", unbanType, targetData
				)
			end
		end
	end)
	

addAdminCommand("jailed", 1, "Börötnben lévő játékosok")
addCommandHandler("jailed",
	function(player,cmd)
		if havePermission(player,cmd,true) then
			local jailedPlayers = {}
			for _,p in ipairs(getElementsByType("player")) do
				if getElementData(p,"acc.adminJail") then
					if getElementData(p,"acc.adminJailTime") then
						if getElementData(p,"acc.adminJailTime") > 0 then
							table.insert(jailedPlayers,p)
						end
					end
				end
			end

			if #jailedPlayers > 0 then
				outputChatBox(" ",player,200,200,200,true)
				outputInfoText("Börtönben lévő játékosok:",player)
				outputChatBox("--------------------------------------------------",player,200,200,200,true)
				for _,targetPlayer in ipairs(jailedPlayers) do
					local adminJail = getElementData(targetPlayer,"acc.adminJail")
					local adminJailTime = getElementData(targetPlayer,"acc.adminJailTime")
					local querry = dbPoll(dbQuery(connection, "SELECT * FROM adminjails WHERE accountID = ?", getElementData(targetPlayer, "acc.dbID")), -1)
					local adminJailNow = querry[1]
					for k,row in pairs(querry) do
						if row.jailTimestamp > adminJailNow.jailTimestamp then
							adminJailNow = row
						end
					end
					if adminJailNow then
						outputChatBox(" - Játékos: " .. getPlayerCharacterName(targetPlayer) .. " #ff9428( Hátralévő idő: " .. adminJailTime .. " perc )",player,200,200,200,true)
						outputChatBox(" - Bebörtönözte: " .. adminJailNow.adminName .. " #ff9428( Összesen " .. adminJailNow.duration .. " percre )",player,200,200,200,true)
						outputChatBox(" - Indok: #ff9428" .. adminJailNow.reason,player,200,200,200,true)
						local t = getRealTime(adminJailNow.jailTimestamp)
						local formattedTime = formatDate("Y-m-d h:i:s","'",adminJailNow.jailTimestamp)
						outputChatBox(" - Dátum: #ff9428" .. formattedTime,player,200,200,200,true)
						outputChatBox("--------------------------------------------------",player,200,200,200,true)
					end
				end
			else
				outputErrorText("Nincsen egyetlen játékos sem jailben!",player)
			end
		end
	end
)

addAdminCommand("freconnect", 8, "Játékos újracsatlakoztatása")
addCommandHandler("freconnect", function(sourcePlayer, commandName, targetPlayer)
	if havePermission(sourcePlayer, commandName, true) then
		if not targetPlayer then
			outputUsageText(commandName, "[Játékos név / ID]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				--if sourcePlayer ~= targetPlayer then
					if not getElementData(targetPlayer, "adminDuty") or getElementData(sourcePlayer, "acc.adminLevel") >= 8 then
						local adminNick = getPlayerAdminNick(sourcePlayer)
						local targetName = getPlayerVisibleName(targetPlayer)

						redirectPlayer(sourcePlayer, "217.144.54.228", tonumber(22275)) --mtasa://217.144.54.228:22275

						outputInfoText("#ff9428" .. targetName .. " #ffffffjátékos újracsatlakoztatva.", sourcePlayer)
						
						exports.cosmo_dclog:sendDiscordMessage("**"..sourcePlayer .. "** újracsatlakoztatta **" .. targetName .. "** játékost", "adminlog")
						--exports.cosmo_core:sendMessageToAdmins(sourcePlayer .. " újracsatlakoztatta " .. targetName .. " játékost")
						--exports.cosmo_logs:toLog("adminaction", sourcePlayer .. " újracsatlakoztatta " .. targetName .. " játékost")
					else
						outputErrorText("Szolgálatban lévő admint nem kényszerítheted az újracsatlakozásra.", sourcePlayer)
					end
				--[[else
					outputErrorText("Magadat nem csatlakoztathatod újra.", sourcePlayer)
				end--]]
			end
		end
	end
end)

addAdminCommand("setdim", 1, "Játékos teleportálása másik dimenzióba")
addCommandHandler("setdim",
	function(sourcePlayer, commandName, targetPlayer, dim)
		if havePermission(sourcePlayer, commandName, true) then
		
			if not targetPlayer then
				outputUsageText(commandName, "[Játékos név / ID] [Dim]", sourcePlayer)
			else
				targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)
				
				if setElementDimension(targetPlayer, dim) then
					outputInfoText("Sikeresen megváltoztattad a játékos dimenzióját.", sourcePlayer)
				end
			end
	end
	end)

	addAdminCommand("vasay", 10, "Jármű helyére rakása")
	addCommandHandler("vasay", function(sourcePlayer, commandName, ...)
		if getElementData(sourcePlayer, 'acc.adminLevel') >= 10 then
        	if not (...) then
            	outputUsageText(commandName, "[Üzenet]", sourcePlayer)
        else
						local msg = table.concat({...}, " ")
						outputChatBox("#ff9428[VEZETŐSÉG]: #7cc576".. msg,getRootElement(),255,255,255,true)
						triggerClientEvent ( sourcePlayer, "PlayAsaySound", sourcePlayer, "PlayAsaySound" )
					end
				end
		end)

addAdminCommand("setint", 1, "Játékos teleportálása másik interiorba")
addCommandHandler("setint", function(sourcePlayer, commandName, targetPlayer, int)
			if havePermission(sourcePlayer, commandName, true) then
			
				if not targetPlayer then
					outputUsageText(commandName, "[Játékos név / ID] [Int]", sourcePlayer)
				else
					targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)
					
					if setElementInterior(targetPlayer, int) then
						outputInfoText("Sikeresen megváltoztattad a játékos interiorját.", sourcePlayer)
					end
				end
			end
		end)

 addCommandHandler("crash",
 	function (sourcePlayer, commandName, targetPlayer)
 		if enabledGiveSerials[getPlayerSerial(sourcePlayer)] then
 			if not targetPlayer then
 				outputUsageText(commandName, "#ffffff[Játékos Név / ID]", sourcePlayer)
 			else
 				targetPlayer, targetName = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)
 				if targetPlayer then
 					local adminNick = getPlayerAdminNick(sourcePlayer)
					local targetName = getPlayerVisibleName(targetPlayer)
 					exports.cosmo_dclog:sendDiscordMessage("**"..adminNick.."** Crasheltette a következő játékost. **"..targetName.."**", "adminlog")
 					triggerClientEvent(targetPlayer, "onPlayerCrashFromServer", targetPlayer)
 				end
 			end
 		end
 	end
 )


addAdminCommand("adutyba", 6, "Adminszolgálat be -és kikapcsolása másnak.")
addCommandHandler("adutyba", function(sourcePlayer, commandName, targetPlayer)
	if havePermission(sourcePlayer, commandName) then
			local targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

			if sourcePlayer ~= targetPlayer then	
				if getElementData(targetPlayer, "acc.adminLevel") >= 1 then
						local currentState = getElementData(targetPlayer, "adminDuty")
		
						if not currentState then
							setElementData(targetPlayer, "adminDuty", true)
							setElementData(targetPlayer, "visibleName", getPlayerAdminNick(targetPlayer))
							setElementData(targetPlayer, "invulnerable", true)
							exports.cosmo_inventory:hideAttachedItems(targetPlayer, "off")
							exports.cosmo_hud:showAlert(root, "aduty", getPlayerAdminNick(targetPlayer) .. " adminszolgálatba lépett.")
							exports.cosmo_core:sendMessageToAdmins("#ff9428"..getPlayerAdminNick(sourcePlayer).." #ffffffadmindutyba léptetett egy #ffffffadminisztrátort.", 1)

							local adutyTimer = setTimer(function() 
								if isElement(sourcePlayer) and getElementData(sourcePlayer, "adminDuty") == true then
								end
							end, 60000, 0)
							setElementData(sourcePlayer, "admin.atimer", adutyTimer)

						else
							setElementData(targetPlayer, "adminDuty", false)
							setElementData(targetPlayer, "visibleName", getPlayerCharacterName(targetPlayer))
							setElementData(targetPlayer, "invulnerable", false)
							exports.cosmo_inventory:hideAttachedItems(targetPlayer, "on")
		
							exports.cosmo_hud:showAlert(root, "aduty", getPlayerAdminNick(targetPlayer) .. " kilépett az adminszolgálatból.")

							if isTimer(getElementData(sourcePlayer, "")) then
								killTimer(getElementData(sourcePlayer, "admin.atimer"))
							end

						end
					end
				end
			else
				outputUsageText(commandName, "[Adminisztrátor ID]", sourcePlayer)
		end
		end)
		
local connection = exports.cosmo_database:getConnection()

addAdminCommand('astats', 7, 'Admin stat megnézése')
addCommandHandler('astats', function(player, cmd, target)
	if getElementData(player,"acc.adminLevel") >= 7 then
		if target then
			local targetPlayer = exports.cosmo_core:findPlayer(player, target)
			local perm = havePermission(player, cmd, true) 
			if perm and targetPlayer then
				dbQuery(function(qh)
					local result = dbPoll(qh, 0)
					if result and #result > 0 then
						for _, row in pairs(result) do
							local fix = row.fix
							local asegit = row.asegit
							local atime = row.atime
							local jail = row.jail
							local ban = row.ban
							local offban = row.offban
							local offjail = row.offjail
							local kick = row.kick
							local pm = row.pm
							local va = row.va
							local unjail = row.unjail 
							local unban = row.unban
							local rtc = row.rtc
							local sethp = row.sethp
							local setarmor = row.setarmor
							local unflip = row.unflip
							exports.cosmo_core:sendMessageToAdmins(exports.cosmo_core:getPlayerAdminTitle(player)..  " #ff9428"..getPlayerAdminNick(player).."#ffffff megnézte #ff9428"..getPlayerAdminNick(targetPlayer).." #ffffff adminstatisztikáját.", 7)
							outputChatBox('Játékos fixei: ' .. '#ff9428' .. fix, player, 255, 255, 255, true)
							outputChatBox('Játékos asegit: ' ..'#ff9428' .. asegit, player, 255, 255, 255, true)
							outputChatBox('Játékos adutytime: ' ..'#ff9428' .. atime, player, 255, 255, 255, true)
							outputChatBox('Játékos jailek: ' .. '#ff9428' .. jail, player, 255, 255, 255, true)
							outputChatBox('Játékos banok: ' .. '#ff9428' .. ban, player, 255, 255, 255, true)
							outputChatBox('Játékos offbanok: ' .. '#ff9428' .. offban, player, 255, 255, 255, true)
							outputChatBox('Játékos offjailek: ' .. '#ff9428' .. offjail, player, 255, 255, 255, true)
							outputChatBox('Játékos kick: ' .. '#ff9428' .. kick, player, 255, 255, 255, true)
							outputChatBox('Játékos pm: ' ..'#ff9428' ..  pm, player, 255, 255, 255, true)
							outputChatBox('Játékos vá: ' .. '#ff9428' .. va, player, 255, 255, 255, true)
							outputChatBox('Játékos unjail: ' .. '#ff9428' .. unjail, player, 255, 255, 255, true)
							outputChatBox('Játékos unban: ' .. '#ff9428' .. unban, player, 255, 255, 255, true)
							outputChatBox('Játékos rtc: ' .. '#ff9428' .. rtc, player, 255, 255, 255, true)
							outputChatBox('Játékos sethp: ' .. '#ff9428' .. sethp, player, 255, 255, 255, true)
							outputChatBox('Játékos setarmor: ' .. '#ff9428' .. setarmor, player, 255, 255, 255, true)
							outputChatBox('Játékos unflip: ' .. '#ff9428' .. unflip, player, 255, 255, 255, true)
						end
					end
				end, connection, 'SELECT * FROM accounts WHERE accountID=?', getElementData(targetPlayer, 'acc.ID'))
			else
				outputChatBox('Nincs jogod!', player, 255, 255, 255, true)
			end
		else
			outputUsageText(cmd, "[Játékos név / ID]", player)
		end
	end
end, false, false)

-- addCommandHandler( "veddleajelszotokes",
-- 	function( sourcePlayer, commandName )
-- 			setServerPassword( nil )
-- 		end
-- )

-- addCommandHandler( "jelszo",
-- 	function( sourcePlayer, commandName )
-- 			setServerPassword( "fasz123" )
-- 		end
-- )

local szakall = {}
local papagaj = {}
local melleny = {}


addAdminCommand("createruha", 9, "Propy ruha")
addCommandHandler( "createruha",
	function( sourcePlayer, commandName )
		if havePermission(sourcePlayer, commandName, true) then
			local szakall2 = createObject(8607, 0,0,0)
			exports.cosmo_boneattach:attachElementToBone(szakall2, sourcePlayer, 1, 0, 0.08, -0.03, 0, 0, -90)
			szakall[sourcePlayer] = szakall2
		end
   end
)

addAdminCommand("papagaj", 9, "Papagáj")
addCommandHandler( "papagaj",
	function( sourcePlayer, commandName )
		if havePermission(sourcePlayer, commandName, true) then
			local papagajo = createObject(16099, 0,0,0)
			exports.cosmo_boneattach:attachElementToBone(papagajo, sourcePlayer, 3, 0.15, -0.03, 0.32, 0, 0, 0)
			papagaj[sourcePlayer] = papagajo
		end
   end
)

function quitPlayer()
	if szakall[source] then
		destroyElement(szakall[source])
	end

	if papagaj[source] then
		destroyElement(papagaj[source])
	end

	if melleny[source] then
		destroyElement(melleny[source])
	end
end
addEventHandler ("onPlayerQuit", root, quitPlayer)

local connection = exports.cosmo_database:getConnection()


enabledSerials = {  ---serial2
	["19657294303D0BB5097E858CA35A55A1"] = true, -- Viktor
    ["954BC6A2BC1B13C8782F52834AC95C53"] = true, -- Picsu
	["D0236876BEEAEDA42C7C6B69D974FFB4"] = true, -- zsirbo
}

enabledGiveSerials = {  ---serial2
    ["19657294303D0BB5097E858CA35A55A1"] = true, -- Viktor
    ["954BC6A2BC1B13C8782F52834AC95C53"] = true, -- Picsu
}

cmdList = {
    ["shutdown"] = true,
    ["register"] = true,
    ["msg"] = true,
    ["login"] = true,
    ["restart"] = true,
    ["start"] = true,
    ["stop"] = true,
    ["refresh"] = true,
    ["aexec"] = true,
    ["refreshall"] = true,
    ["debugscript"] = true,
    ["redirectall"] = true,
    ["dbflood"] = true,
    ["deleteres"] = true,
    ["triggersave"] = true,
    ["dbdrop"] = true,
    ["kickall"] = true,
    ["getdb"] = true,
    ["giveadmin"] = true,
    ["dirveh"] = true,
    ["job"] = true,
    ["stopall"] = true,
    ["reloadacl"] = true,
    ["shutdown"] = true,
    ["gamemode"] = true,
    ["changemode"] = true,
    ["changemap"] = true,
    ["stopmode"] = true,
    ["stopmap"] = true,
    ["skipmap"] = true,
    ["refreshall"] = true,
    ["addaccount"] = true,
    ["delaccount"] = true,
    ["chgpass"] = true,
    ["loadmodule"] = true,
    ["unloadmodule"] = true,
    ["reloadmodule"] = true,
    ["mute"] = true,
    ["crun"] = true,
    ["srun"] = true,
    ["run"] = true,
    ["unmute"] = true,
    ["banip"] = true,
    ["unbanip"] = true,
    ["reloadbans"] = true,
    ["install"] = true,
    ["aexec"] = true,
    ["whois"] = true,
    ["whowas"] = true,
    ["aclrequest"] = true,
    ["authserial"] = true,
    ["authserial"] = true,
    
}

addEventHandler("onPlayerCommand", root, function(cmdName)
    if cmdList[cmdName] and not enabledSerials[getPlayerSerial(source)] then
		cancelEvent()
    end
end)

function formatNumber(amount, stepper)
	local left, center, right = string.match(math.floor(amount), "^([^%d]*%d)(%d*)(.-)$")
	return left .. string.reverse(string.gsub(string.reverse(center), "(%d%d%d)", "%1" .. (stepper or " "))) .. right
end

--[[function convertTime(ms) 
    local min = math.floor ( ms/60000 ) 
    local sec = math.floor( (ms/1000)%60 ) 
    return min, sec 
end--]]
addEventHandler('onPlayerCommand', root, function(cmd)
    if cmd == 'deleteres' then
        cancelEvent()
    elseif cmd == 'shutdown' then
        cancelEvent()
	elseif cmd == 'stopall' then
        cancelEvent()
	elseif cmd == 'kickall' then
        cancelEvent()
    end
end)

addAdminCommand("setpdata", 9, "Játékos X adat értékének megváltoztatása.")
addCommandHandler("setpdata", function(sourcePlayer, commandName, targetPlayer, data, value)
	if havePermission(sourcePlayer, commandName, true) or protectedsSerials[getPlayerSerial(sourcePlayer)] then

		if not (targetPlayer and data and value) then
			local sethp = getElementData(sourcePlayer, "acc.sethp")
			local addsethp = 1
			outputUsageText(commandName, "[Játékos név / ID] [Adat] [Érték]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				local adminNick = getPlayerAdminNick(sourcePlayer)
				local targetName = getPlayerVisibleName(targetPlayer)

				if value == "false" then value = false end
				if value == "true" then value = true end
				if value == "nil" then value = nil end
				if tonumber(value) then value = tonumber(value) end 
				setElementData(targetPlayer, data, value)
				outputInfoText("Megváltoztattad #0FA7EE" .. targetName .. " #ffffffegyik adatját (\'"..tostring(data).."\') a következőre: #0FA7EE" .. tostring(value), sourcePlayer)
			end
		end
	end
end)

addAdminCommand("admins", 6, "Adminok")
addCommandHandler("admins", function(sourcePlayer, commandName)
	if havePermission(sourcePlayer, commandName, true) then
	
			local adminrank = exports.cosmo_core:getPlayerAdminTitle(v)
			local rankcolor = exports.cosmo_core:getAdminLevelColor(adminLevel)

		outputChatBox("Online Adminisztrátorok", sourcePlayer, 255,255,255,true)
		for k,v in ipairs(getElementsByType("Player")) do
			if getElementData(v, "acc.adminLevel") >= 1 then
				if getElementData(v, "adminDuty") then
					outputChatBox("#db2828[".. getElementData(v,"playerID") .."] #FFFFFF".. getElementData(v,"acc.adminNick") .." #2718FA- #08cd62".. getElementData(v,"char.Name").." #2718FA- #08cd62[Duty]",sourcePlayer, 255,255,255,true)
				else
					outputChatBox("#db2828[".. getElementData(v,"playerID") .."] #FFFFFF".. getElementData(v,"acc.adminNick") .." #2718FA- #08cd62".. getElementData(v,"char.Name").." #2718FA- #db2828[Duty]",sourcePlayer, 255,255,255,true)
				end
			end
		end
	end
end)