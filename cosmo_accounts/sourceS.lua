--[[
CREATE TABLE `ucp_graph_players` (
	`dbID` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
	`players` INT(4) NOT NULL DEFAULT '0',
	`date` DATETIME NOT NULL
) Engine=InnoDB;

CREATE TABLE `bans` (
	`dbID` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
	`playerSerial` VARCHAR(512) DEFAULT '0',
	`playerName` VARCHAR(48) NOT NULL DEFAULT '',
	`playerAccountId` INT(11) NOT NULL,
	`banReason` TEXT,
	`adminName` VARCHAR(48) NOT NULL DEFAULT '',
	`banTimestamp` BIGINT(22) DEFAULT '0',
	`expireTimestamp` BIGINT(22) DEFAULT '0',
	`isActive` enum('Y', 'N') NOT NULL DEFAULT 'Y'
);

CREATE TABLE `kicks` (
	`dbID` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
	`playerAccountId` INT(11) NOT NULL,
	`adminName` INT(11) NOT NULL,
	`kickReason` TEXT,
	`date` DATETIME DEFAULT NOW()
);

CREATE TABLE `accounts` (
	`accountID` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
	`serial` VARCHAR(512) DEFAULT '0',
	`suspended` enum('Y', 'N') NOT NULL DEFAULT 'N',
	`username` VARCHAR(48) NOT NULL DEFAULT '',
	`password` TEXT NOT NULL DEFAULT '',
	`email` TEXT NOT NULL DEFAULT '',
	`adminLevel` INT(2) NOT NULL DEFAULT '0',
	`adminNick` VARCHAR(48) NOT NULL DEFAULT '',
	`registerTime` DATETIME DEFAULT NOW(),
	`lastLoggedIn` DATETIME DEFAULT 0,
	`maxCharacter` INT(2) NOT NULL DEFAULT '1',
	`adminJail` VARCHAR(512) NOT NULL DEFAULT 'N',
	`adminJailTime` INT(11) NOT NULL DEFAULT '0',
	`online` ENUM('N', 'Y') NOT NULL DEFAULT 'N',
	`helperLevel` INT(1) NOT NULL DEFAULT '0'
);


CREATE TABLE `characters` (
	`charID` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
	`accID` INT(11) NOT NULL DEFAULT '0',
	`name` VARCHAR(40) NOT NULL DEFAULT '',
	`skin` INT(3) NOT NULL DEFAULT '1',
	`age` INT(2) NOT NULL DEFAULT '24',
	`position` TEXT,
	`rotation` INT(3) NOT NULL DEFAULT '0',
	`interior` INT(11) NOT NULL DEFAULT '0',
	`dimension` INT(11) NOT NULL DEFAULT '0',
	`health` INT(3) NOT NULL DEFAULT '100',
	`armor` INT(3) NOT NULL DEFAULT '100',
	`hunger` INT(3) NOT NULL DEFAULT '100',
	`thirst` INT(3) NOT NULL DEFAULT '100',
	`money` INT(11) NOT NULL DEFAULT '0',
	`bankMoney` INT(11) NOT NULL DEFAULT '0',
	`job` INT(2) NOT NULL DEFAULT '0',
	`injured` INT(1) NOT NULL DEFAULT '0',
	`houseInterior` INT(11) NOT NULL DEFAULT '0',
	`customInterior` INT(11) NOT NULL DEFAULT '0',
	`actionbarItems` TEXT,
	`lastOnline` BIGINT(22) NOT NULL DEFAULT '0',
	`playedMinutes` INT(11) NOT NULL DEFAULT '0',
	`playTimeForPayday` INT(11) NOT NULL DEFAULT '0',
	`vehicleLimit` INT(4) NOT NULL DEFAULT '3',
	`interiorLimit` INT(4) NOT NULL DEFAULT '5',
	`bulletDamages` VARCHAR(512) DEFAULT NULL,
	`lastNameChange` DATETIME DEFAULT NULL
);

CREATE TABLE `adminjails` (
	`dbID` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
	`accountID` INT(11) NOT NULL DEFAULT '0',
	`jailTimestamp` BIGINT(22) NOT NULL DEFAULT '0',
	`reason` TEXT,
	`duration` INT(11) NOT NULL DEFAULT '0',
	`adminName` VARCHAR(100) NOT NULL DEFAULT ''
);
]]

--print(count)

local connection = false
local debugging = false

local taxesCache = {}
local assignedCharacters = {}
local characterDatas = {}

function sendTheHourlyPlayers()
	-- minden 1 nappal ezelőtti rekordot törlünk, ne teljen vele fölöslegesen az adatbázis
	dbExec(connection, "DELETE FROM ucp_graph_players WHERE date < NOW() - INTERVAL 1 DAY")

	-- beszúrjuk a mostani rekordot
	local timeNow = getRealTime()
	
	if timeNow.minute % 5 ~= 0 then
		timeNow.minute = timeNow.minute - timeNow.minute % 5
	end

	timeNow = string.format("%04d-%02d-%02d %02d:%02d:00", timeNow.year + 1900, timeNow.month + 1, timeNow.monthday, timeNow.hour, timeNow.minute)

	dbExec(connection, "INSERT INTO ucp_graph_players (players, date) VALUES (?, ?)", #getElementsByType("player"), timeNow)
end

addEventHandler("onResourceStart", getRootElement(),
	function (startedResource)
		if getResourceName(startedResource) == "cosmo_database" then
			connection = exports.cosmo_database:getConnection()
		elseif source == getResourceRootElement() then
			local cosmo_database = getResourceFromName("cosmo_database")

			if cosmo_database and getResourceState(cosmo_database) == "running" then
				connection = exports.cosmo_database:getConnection()
			end

			if connection then
				dbQuery(
					function (qh)
						local result, rows = dbPoll(qh, 0)

						for k,v in ipairs(result) do
							taxesCache[v.key] = {v.id, v.name, v.value, v.updated, v.created}

							if debugging then
								print(v.name .. ": " .. v.value)
							end
						end
					end, connection, "SELECT * FROM taxes"
				)

				sendTheHourlyPlayers()

				setTimer(sendTheHourlyPlayers, 300000, 0) -- 5 percenként
			end
		end
	end, true, "high+99"
)

addEventHandler("onPlayerJoin", getRootElement(),
	function ()
		if isElement(source) then
			local playerID = getElementData(source, "playerID") or math.random(1, 500)

			setElementDimension(source, 75 + playerID)
			setElementAlpha(source, 0)
			setElementFrozen(source, true)
			setPlayerNametagShowing(source, false)
		end
	end
)

addEvent("checkPlayerBanState", true)
addEventHandler("checkPlayerBanState", getRootElement(),
	function ()
		if isElement(source) then
			local serial = getPlayerSerial(source)

			dbQuery(
				function (qh, sourcePlayer)
					if isElement(sourcePlayer) then
						local result, rows = dbPoll(qh, 0)[1]
						local banState = {isActive = "N"}

						if result then
							if getRealTime().timestamp >= result.expireTimestamp then
								dbExec(connection, "UPDATE accounts SET suspended = 'N' WHERE serial = ?; UPDATE bans SET isActive = 'N' WHERE playerSerial = ? AND dbID = ?", serial, serial, v.dbID)
							else
								banState = result
							end
						end

						triggerClientEvent(sourcePlayer, "receiveBanState", sourcePlayer, banState)

						if getElementData(sourcePlayer, "loggedIn") then
							local characterId = getElementData(sourcePlayer, "char.ID") or 0

							if characterId > 0 then
								assignedCharacters[characterId] = sourcePlayer

								dbExec(connection, "UPDATE accounts SET online = 'Y' WHERE accountID = ?", getElementData(sourcePlayer, "acc.ID"))
							end
						end
					end
				end, {source}, connection, "SELECT * FROM bans WHERE playerSerial = ? AND isActive = 'Y' LIMIT 1", serial
			)
		end
	end
)

addEvent("onClientRegisterRequest", true)
addEventHandler("onClientRegisterRequest", getRootElement(),
	function ()
		if isElement(source) then
			dbQuery(
				function (qh, sourcePlayer)
					if isElement(sourcePlayer) then
						local result, rows = dbPoll(qh, 0)

						triggerClientEvent(sourcePlayer, "onClientRegister", sourcePlayer, rows)
					end
				end, {source}, connection, "SELECT * FROM accounts WHERE serial = ? LIMIT 1", getPlayerSerial(source)
			)
		end
	end
)

addEvent("checkCharacterName", true)
addEventHandler("checkCharacterName", getRootElement(),
	function (name)
		if isElement(source) then
			if not name then
				return
			end
			
			dbQuery(
				function (qh, sourcePlayer)
					if isElement(sourcePlayer) then
						local result, rows = dbPoll(qh, 0)

						triggerClientEvent(sourcePlayer, "checkNameCallback", sourcePlayer, rows)
					end
				end, {source}, connection, "SELECT * FROM characters WHERE name = ? LIMIT 1", name
			)
		end
	end
)

function generateRandomString(chars)
	local str = ""

	for i = 1, chars do 
		str = str .. (string.format("%c", math.random(48, 122)))
	end

	return str
end

function createHash(string, key)
	if not key then
		key = generateRandomString(8)
	end

	return "$" .. key .. "$" .. hash("sha512", "SARP#PW" .. md5(key) .. md5(string))
end

function makeHash(string, old)
	return createHash(string, gettok(old, 1, string.byte("$")))
end

function isEqualHash(string, old)
	return gettok(makeHash(string, old), 2, string.byte("$")) == gettok(old, 2, string.byte("$"))
end

addEvent("onClientTryToCreateAccount", true)
addEventHandler("onClientTryToCreateAccount", getRootElement(),
	function (username, password, email)
		if isElement(source) then
			if client and username and password and email then
				dbQuery(
					function (qh, sourcePlayer)
						if isElement(sourcePlayer) then
							local result = dbPoll(qh, 0)[1]

							if result then
								if result.username == username then
									exports.cosmo_hud:showInfobox(sourcePlayer, "error", "Ez a felhasználónév már foglalt!")
								elseif result.email == email then
									exports.cosmo_hud:showInfobox(sourcePlayer, "error", "Ez az e-mail cím már használatban van!")
								end
							else
								dbQuery(
									function (qh)
										local result, rows, lastID = dbPoll(qh, 0)

										triggerClientEvent(sourcePlayer, "onRegisterFinish", sourcePlayer, lastID)
									end, connection, "INSERT INTO accounts (username, password, email, serial, adminNick) VALUES (?,?,?,?,?)", username, createHash(password), email, getPlayerSerial(sourcePlayer), username
								)
							end
						end
					end, {source}, connection, "SELECT username, email FROM accounts WHERE username = ? OR email = ? LIMIT 1", username, email
				)
			end
		end
	end
)

function reloadPlayerCharacters(qh, sourcePlayer, accountID)
	if isElement(sourcePlayer) then
		dbQuery(
			function (qh)
				local result, rows = dbPoll(qh, 0)
				local characters = {}

				for k,v in pairs(result) do
					table.insert(characters, v)
				end

				triggerClientEvent(sourcePlayer, "onPlayerCharacterMade", sourcePlayer, characters)
			end, connection, "SELECT * FROM characters WHERE accID = ?", accountID
		)
	end

	dbFree(qh)
end

addEvent("onClientTryToCreateCharacter", true)
addEventHandler("onClientTryToCreateCharacter", getRootElement(),
	function (charName, data)
		if client and charName and data then
			dbQuery(reloadPlayerCharacters, {source, data.accID}, connection, "INSERT INTO characters (accID, name, skin, age, position, rotation, money, skills) VALUES (?,?,?,?,?,?,?,?)", data.accID, charName, data.skin, data.age, "1476.7922363281, -1789.3287353516, 13.734399795532", 0, 50000000, "0;0;0;0;0;0;0;0;0;0;0")
		end
	end
)

addEvent("onClientPasswordChangeForced", true)
addEventHandler("onClientPasswordChangeForced", getRootElement(),
	function (password)
		if isElement(source) then
			if client and password then
				local accountId = getElementData(source, "acc.dbID") or 0

				if accountId > 0 then
					dbQuery(
						function(qh, sourcePlayer)
							if isElement(sourcePlayer) then
								triggerClientEvent(sourcePlayer, "passwordChangeResult", sourcePlayer, true)
							end

							dbFree(qh)
						end, {source}, connection, "UPDATE accounts SET password = ? WHERE accountID = ?", createHash(password), accountId
					)
				end
			end
		end
	end
)

addEvent("onClientLoginRequest", true)
addEventHandler("onClientLoginRequest", getRootElement(),
	function (username, password)
		if isElement(source) then
			if client and username and password then
				local serial = getPlayerSerial(source)

				dbQuery(
					function(qh, sourcePlayer)
						local result = dbPoll(qh, 0)[1]
						local errno = false
						local forcePasswordChange = "N"

						if not result then
							errno = "Nincs ilyen nevű felhasználó regisztrálva!"
						elseif string.len(result.password) == 32 then -- régi jelszó, jelszóváltás eröltetése
							if result.password == hash("md5", string.reverse(username .. password)) then
								errno = false
								forcePasswordChange = "Y"
							else
								errno = "Hibás jelszó!"
							end
						elseif not isEqualHash(password, result.password) then
							errno = "Hibás jelszó!"
						end

						if not errno then
							if result.serial == "0" then
								dbExec(connection, "UPDATE accounts SET serial = ? WHERE accountID = ?", serial, result.accountID)
								result.serial = serial
							end

							if result.serial ~= serial then
								errno = "Ez a fiók nem a Te gépedhez van társítva!"
							elseif result.suspended == "Y" then
								errno = "Ez a fiók határozatlan ideig fel van függesztve!"
							else
								errno = false
							end
						end

						if errno then
							exports.cosmo_hud:showInfobox(sourcePlayer, "error", errno .. "\nVárj 10 másodpercet az újrapróbálkozáshoz.")
						else
							dbQuery(
								function(qh, account)
									local result, rows = dbPoll(qh, 0)
									local characters = {}

									for k, v in pairs(result) do
										table.insert(characters, v)
									end

									setElementData(sourcePlayer, "acc.Name", username)
									setElementData(sourcePlayer, "acc.ID", account.accountID)
									setElementData(sourcePlayer, "acc.dbID", account.accountID)
									setElementData(sourcePlayer, "acc.adminLevel", account.adminLevel)
									setElementData(sourcePlayer, "acc.adminNick", account.adminNick or username)
									setElementData(sourcePlayer, "acc.maxCharacter", account.maxCharacter)
									setElementData(sourcePlayer, "acc.helperLevel", account.helperLevel)
									setElementData(sourcePlayer, "char.PP", account.premium)
									setElementData(sourcePlayer, 'aduty:time', account.adminDutyTime)
									local t = fromJSON(account.adminStats)
									setElementData(sourcePlayer, 'acc:admin:pmReceived', t[2] or 0)
									setElementData(sourcePlayer, 'acc:admin:pmReplied', t[3] or 0)
									setElementData(sourcePlayer, 'acc:admin:vehicleFix', t[4] or 0)
									setElementData(sourcePlayer, 'acc:admin:vehicleRTC', t[5] or 0)
									setElementData(sourcePlayer, 'acc:admin:vehicleFuel', t[6] or 0)

									if account.adminJail == "N" then
										setElementData(sourcePlayer, "acc.adminJail", 0)
										setElementData(sourcePlayer, "acc.adminJailTime", 0)
									else
										setElementData(sourcePlayer, "acc.adminJail", account.adminJail)
										setElementData(sourcePlayer, "acc.adminJailTime", account.adminJailTime)

									end

									dbExec(connection, "UPDATE accounts SET lastLoggedIn = NOW(), online = 'Y' WHERE accountID = ?" , account.accountID)

									triggerClientEvent(sourcePlayer, "onSuccessLogin", sourcePlayer, characters, forcePasswordChange)
								end, {result}, connection, "SELECT * FROM characters WHERE accID = ?", result.accountID
							)
						end
					end, {source}, connection, "SELECT * FROM accounts WHERE username = ? LIMIT 1", username
				)
			end
		end
	end
)

addEvent("onCharacterSelect", true)
addEventHandler("onCharacterSelect", getRootElement(),
	function (player, charID, data)
		if isElement(source) and isElement(player) then
			if player and charID and data then
				assignedCharacters[charID] = source
				characterDatas[charID] = data

				local position = split(data.position, ",")

				spawnPlayer(player, tonumber(position[1]), tonumber(position[2]), tonumber(position[3]), data.rotation, data.skin, data.interior, data.dimension)

				setElementAlpha(player, 255)
				setElementModel(player, data.skin)
				setElementInterior(player, data.interior)
				setElementDimension(player, data.dimension)
				setPedRotation(player, data.rotation)
				setCameraTarget(player, player)

				setElementHealth(player, data.health)
				setPedArmor(player, data.armor)
				setElementData(player, "char.Hunger", data.hunger)
				setElementData(player, "char.Thirst", data.thirst)
				setElementData(player, "char.Injured", data.injured == 1)

				setElementData(player, "char.ID", charID)
				setPlayerName(player, data.name)
				setPlayerNametagText(player, data.name)
				setElementData(player, "visibleName", data.name)
				setElementData(player, "char.Name", data.name)
				setElementData(player, "char.Age", data.age)

				setElementData(player, "char.Money", data.money)
                setElementData(player, "char.ucoin", data.coin)
				setElementData(player, "char.bankMoney", data.bankMoney)
				setElementData(player, "char.Job", data.job)

				setElementData(player, "char.CompanyRank", tostring(data.company_rank))
				setElementData(player, "char.CompanyID", data.company)
				setElementData(player, "char.CompanyTaxPayed", data.company_tax_payed)

				setElementData(player, "char.playedMinutes", data.playedMinutes)
				setElementData(player, "char.playTimeForPayday", data.playTimeForPayday)

				setElementData(player, "player.currentInterior", data.houseInterior)
				setElementData(player, "currentCustomInterior2", data.customInterior) --            ["currentClothes"] = getElementData(player, "currentClothes") or "",
           																				-- ["boughtClothes"] = getElementData(player, "boughtClothes") or "",

				
				if data.jailed then
					exports.cosmo_groupscripting:loadPlayerJail(player, data.jailed)
				end

				if data.actionbarItems and utfLen(data.actionbarItems) > 0 then
					local items = split(data.actionbarItems, ";")

					for i = 1, 6 do
						local k = i - 1

						if items[i] ~= "-" then
							setElementData(source, "actionBarSlot_" .. k, tonumber(items[i]))
						elseif getElementData(source, "actionBarSlot_" .. k) then
							removeElementData(source, "actionBarSlot_" .. k)
						end
					end
				end

				setElementData(player, "char.vehicleLimit", data.vehicleLimit)
				setElementData(player, "char.interiorLimit", data.interiorLimit)

				if data.clothesLimit then
					setElementData(player, "clothesLimit", data.clothesLimit or 2)

					if data.boughtClothes and data.boughtClothes ~= "[[]]" and utfLen(data.boughtClothes) > 0 then
						setElementData(player, "boughtClothes", data.boughtClothes)
					end

					if data.currentClothes and data.currentClothes ~= "[[]]" and utfLen(data.currentClothes) > 0 then
						setElementData(player, "currentClothes", data.currentClothes)
					end
				end

				if data.bulletDamages and utf8.len(data.bulletDamages) > 0 then
					local damages = split(data.bulletDamages, ";")
					local current = {}

					for i=1,#damages,3 do
						current[damages[i] .. ";" .. damages[i+1]] = tonumber(damages[i+2])
					end

					setElementData(player, "bulletDamages", current)
				end

				setElementData(player, "loggedIn", true) -- ez mindenképpen itt kell, hogy maradjon!!

				setElementData(player, "weaponSkill", data.skills)
				
				local skill = split(data.skills, ";")
				
				setPedStat(source, 69, skill[1]) -- colt
				setPedStat(source, 70, skill[2]) -- silenced
				setPedStat(source, 71, skill[3]) -- desert eagle
				setPedStat(source, 75, skill[4]) -- uzi
				setPedStat(source, 76, skill[5]) -- mp5
				setPedStat(source, 77, skill[6]) -- ak47
				setPedStat(source, 78, skill[7]) -- m4
				setPedStat(source, 79, skill[8]) -- sniper
				setPedStat(source, 72, skill[9]) -- shotgun
				setPedStat(source, 74, skill[10]) -- spas12
				setPedStat(source, 73, skill[11]) -- sawnoff

				if getElementData(player, "acc.adminJail") ~= 0 then
					setElementPosition(player, 154.14526367188, -1951.6461181641, 47.875 + 1)
				end

				setElementData(player, "char.painted", data.painted)
				setElementData(player, "char.paintTime", data.paintedTime)

				processClothesOfCJ(player)

				exports.cosmo_vehicles:loadPlayerVehicles(charID, player)
				
				exports.cosmo_inventory:loadItems(player, charID)

				triggerEvent("requestGroups", player)

				triggerClientEvent(player, "onClientLoggedIn", player)
			end
		end
	end
)

function getPlayerFromCharacterID(characterId)
	if assignedCharacters[characterId] then
		return assignedCharacters[characterId]
	end

	return false
end

function getLastCharacterData(characterId, data) -- spawnkor és a fél órás mentésekkor frissül a tábla!!
	if characterDatas[characterId] then
		if data then
			if characterDatas[characterId][data] then
				return characterDatas[characterId][data]
			end
		else
			return characterDatas[characterId]
		end
	end

	return false
end

exports.cosmo_admin:addAdminCommand("triggersave", 10, "Játékosok mentése (debughoz)")
addCommandHandler("triggersave",
	function (player, command)
		if getElementData(player, "acc.adminLevel") == 10 then
			for k, v in ipairs(getElementsByType("player")) do
				autoSavePlayer(v)
				outputChatBox("[coso life - dev séró kommand]: sikeresen elmentettem " .. (getElementData(v, "visibleName") or "nem vot neve :(") .. " adatait!", player, 255, 255, 255, true)
			end
		end
	end
)

function autoSavePlayer(player, loggedOut)
	if not player then
		player = source
	end

	if getElementData(player, "loggedIn") then
		local characterId = getElementData(player, "char.ID")

		if loggedOut then
			assignedCharacters[characterId] = nil
			characterDatas[characterId] = nil
		end

		local onDuty = getElementData(player, "groupDuty")

		local actionbarItems = ""
		for i = 0, 5 do
			actionbarItems = actionbarItems .. (getElementData(player, "actionBarSlot_" .. tostring(i)) or "-") .. ";"
		end

		local bulletDamages = getElementData(player, "bulletDamages") or {}
		local damageStr = ""

		for k, v in pairs(bulletDamages) do
			damageStr = damageStr .. k .. ";" .. v .. ";"
		end

		local datas = {
			["skin"] = onDuty and getElementData(player, "char.defaultSkin") or getElementModel(player),
			["position"] = table.concat({getElementPosition(player)}, ","),
			["rotation"] = getPedRotation(player),
			["interior"] = getElementInterior(player),
			["dimension"] = getElementDimension(player),
			["health"] = getElementHealth(player),
			["armor"] = onDuty and getElementData(player, "char.defaultArmor") or getPedArmor(player),
			["hunger"] = getElementData(player, "char.Hunger") or 0,
			["thirst"] = getElementData(player, "char.Thirst") or 0,
			["money"] = getElementData(player, "char.Money") or 0,
			["bankMoney"] = getElementData(player, "char.bankMoney") or 0,
			["job"] = getElementData(player, "char.Job") or 0,
			["injured"] = (getElementData(player, "char.Injured") or getElementData(player, "char.Bleeding")) and 1 or 0,
			["houseInterior"] = getElementData(player, "player.currentInterior") or 0,
			["customInterior"] = 0,
			["actionbarItems"] = actionbarItems,
			["playedMinutes"] = getElementData(player, "char.playedMinutes") or 0,
			["playTimeForPayday"] = getElementData(player, "char.playTimeForPayday") or 0,
			["bulletDamages"] = damageStr,
			["painted"] = getElementData(player, "char.painted") or "N",
			["paintedTime"] = getElementData(player, "char.paintTime") or 0,
            ["coin"] = getElementData(player, "char.ucoin") or 0,
            ["vehicleLimit"] = getElementData(player, "char.vehicleLimit"),
            ["interiorLimit"] = getElementData(player, "char.interiorLimit"),
            ["currentClothes"] = getElementData(player, "currentClothes") or "",
            ["boughtClothes"] = getElementData(player, "boughtClothes") or "",
		}

		if not loggedOut then
			characterDatas[characterId] = datas
		end

		local columns = {}
		local columnValues = {}

		for k,v in pairs(datas) do
			table.insert(columns, k .. " = ?")
			table.insert(columnValues, v)
		end
		table.insert(columnValues, characterId)

		if not loggedOut then
			dbExec(connection, "UPDATE accounts SET adminJailTime = ? WHERE accountID = ?; UPDATE characters SET " .. table.concat(columns, ", ") .. " WHERE charID = ?", (getElementData(player, "acc.adminJailTime") or 0), getElementData(player, "acc.dbID"), unpack(columnValues))
		else
			local helperLevel = getElementData(player, "acc.helperLevel") or 0

			if helperLevel == 1 then
				helperLevel = 0
			end

			local adutyTime = getElementData(player, 'aduty:time') or 0
			local pmReceived = getElementData(player, 'acc:admin:pmReceived') or 0
			local pmReplied = getElementData(player, 'acc:admin:pmReplied') or 0
			local vehicleFix = getElementData(player, 'acc:admin:vehicleFix') or 0
			local vehicleRTC = getElementData(player, 'acc:admin:vehicleRTC') or 0
			local vehicleFuel = getElementData(player, 'acc:admin:vehicleFuel') or 0

			local t = {adutyTime, pmReceived, pmReplied, vehicleFix, vehicleRTC, vehicleFuel}

			dbExec(connection, "UPDATE accounts SET adminStats = ? WHERE accountID = ?", toJSON(t), getElementData(player, "acc.dbID"))
			dbExec(connection, "UPDATE accounts SET adminJailTime = ?, online = 'N', helperLevel = ?, premium = ? WHERE accountID = ?; UPDATE characters SET lastOnline = ?, " .. table.concat(columns, ", ") .. " WHERE charID = ?", (getElementData(player, "acc.adminJailTime") or 0), helperLevel, getElementData(player, "char.PP"), getElementData(player, "acc.dbID"), getRealTime().timestamp, unpack(columnValues))
		end
	end
end
addEvent("autoSavePlayer", true)
addEventHandler("autoSavePlayer", getRootElement(), autoSavePlayer)

addEventHandler("onResourceStop", getResourceRootElement(),
	function ()
		for k,v in ipairs(getElementsByType("player")) do
			autoSavePlayer(v, true)
		end
	end
)

addEventHandler("onPlayerQuit", getRootElement(),
	function ()
		autoSavePlayer(source, true)
	end
)

exports.cosmo_admin:addAdminCommand("payday", 10, "Fizetés/adó kiküldése magunknak (debughoz)")
addCommandHandler("payday",
	function (player, command)
		if getElementData(player, "acc.adminLevel") >= 10 then
			triggerEvent("onPayDay", player)
		end
	end
)

addEvent("onPayDay", true)
addEventHandler("onPayDay", getRootElement(),
	function ()
		if getElementData(source, "loggedIn") then
			local charID = getElementData(source, "char.ID")

			-- Bruttó bér
			local grossSalary = 0
			local playerGroups = exports.cosmo_groups:getPlayerGroups(source)

			if playerGroups then
				for k,v in pairs(playerGroups) do
					local rankId, rankName, rankPayment = exports.cosmo_groups:getPlayerRank(source, k)

					grossSalary = grossSalary + rankPayment
				end
			end

			 --Jövedelem adó
			local incomeTax = getElementData(source, "char.bankMoney") or 0

			if incomeTax > 0 then
				incomeTax = incomeTax * 0.05

				if incomeTax > 50000000 then
					incomeTax = 50000000
				end
			end

			-- Jármű adó
			local vehicleTax = exports.cosmo_vehicles:getPlayerVehiclesCount(charID) * (taxesCache["vehicleTax"] and taxesCache["vehicleTax"][3] or 125)
			local vehicleTax = vehicleTax*1000
		
			-- Ingatlan adó
			--local interiors = exports.cosmo_interiors:requestInteriors(source) or {}
			--local propertyTax = #interiors * (taxesCache["propertyTax"] and taxesCache["propertyTax"][3] or 175)

			grossSalary = math.floor(grossSalary)
			incomeTax = math.floor(incomeTax)
			vehicleTax = math.floor(vehicleTax)
			--propertyTax = math.floor(propertyTax)
			--bankKamat = (getElementData(source, "char.bankMoney") or 0) * 0.2

			outputChatBox(exports.cosmo_core:getServerTag() .. "Megérkezett a fizetésed.", source, 0, 0, 0, true)
			outputChatBox("#ffffff - Bruttó bér: #acd373" .. convertNumber(grossSalary) .. " $", source, 0, 0, 0, true)
			
			outputChatBox("#ffffff - Banki kamat: #acd373" .. convertNumber(incomeTax) .. " $", source, 0, 0, 0, true)
			--outputChatBox("#ffffff - Jövedelem adó: #acd373" .. incomeTax .. " $", source, 0, 0, 0, true)
			outputChatBox("#ffffff - Jármű adó: #dc143c" .. convertNumber(vehicleTax) .. " $", source, 0, 0, 0, true)
			
			--outputChatBox("#ffffff - Ingatlan adó: #dc143c" .. propertyTax .. " $", source, 0, 0, 0, true)

			local currentBankMoney = getElementData(source, "char.bankMoney") + incomeTax
			--print (currentBankMoney)
			currentBankMoney = math.floor(tonumber(currentBankMoney))


			local currentMoney = getElementData(source, "char.Money") or 0
			currentMoney = currentMoney + grossSalary - vehicleTax 

			setElementData(source, "char.bankMoney", currentBankMoney)
			setElementData(source, "char.Money", currentMoney)
		end
	end
)


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

addEventHandler("onElementModelChange", getRootElement(),
	function (oldModel, newModel)
		if getElementType(source) == "player" then
			processClothesOfCJ(source)
		end
	end
)

function processClothesOfCJ(player)
	--[[if getPlayerSerial(player) == "2B4485E163AF8BCD6A129A594E6262A2" and getElementModel(player) == 0 then
		--addPedClothes(player, "hoodyAblue", "hoodyA", 0)
		addPedClothes(player, "beard", "head", 1)
		--addPedClothes(player, "chinosblue", "chinosb", 2)
		addPedClothes(player, "convproblk", "conv", 3)
		--addPedClothes(player, "glasses04dark", "glasses04", 15)
		addPedClothes(player, "bbjackrim", "bbjack", 0)
		addPedClothes(player, "tracktrwhstr", "tracktr", 2)
		addPedClothes(player, "capred", "cap", 16)
		--addPedClothes(player, "sneakerheatwht", "sneaker", 3)
		addPedClothes(player, "neckcross", "neck", 13)
	end]]
end
