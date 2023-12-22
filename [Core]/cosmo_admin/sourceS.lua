local acmds = {}

logs = exports.cosmo_logs

protectedSerials = {
	["19657294303D0BB5097E858CA35A55A1"] = true, -- viktor
    ["954BC6A2BC1B13C8782F52834AC95C53"] = true, -- picsu
    ["D0236876BEEAEDA42C7C6B69D974FFB4"] = true, -- zsirbo
} 

function addAdminCommand(command, level, description, forceResourceName)
	if not acmds[command] then
		local resourceName = forceResourceName or "cosmo_admin"

		if not forceResourceName and sourceResource then
			resourceName = getResourceName(sourceResource)
		end

		acmds[command] = {level, description, resourceName}
	end
end

function gluePlayer(slot, vehicle, x, y, z, rotX, rotY, rotZ)
	attachElements(source, vehicle, x, y, z, rotX, rotY, rotZ)
end
addEvent("gluePlayer",true)
addEventHandler("gluePlayer",getRootElement(),gluePlayer)

function ungluePlayer(vehicle)
	detachElements(source)
end
addEvent("ungluePlayer",true)
addEventHandler("ungluePlayer",getRootElement(),ungluePlayer)

addEvent("requestAdminCommands", true)
addEventHandler("requestAdminCommands", getRootElement(),
	function()
		if isElement(source) then
			triggerClientEvent(source, "receiveAdminCommands", source, acmds)
		end
	end)

addEventHandler("onResourceStop", getRootElement(),
	function(stoppedResource)
		if stoppedResource == getThisResource() then
			local array = {}
			local count = 0

			for k, v in pairs(acmds) do
				if v[3] ~= "cosmo_admin" then
					array[k] = v
					count = count + 1
				end
			end

			if count > 0 then
				setElementData(getResourceRootElement(getResourceFromName("cosmo_modstarter")), "adminCommandsCache", array, false)
			end
		else
			local resname = getResourceName(stoppedResource)

			for k, v in pairs(acmds) do
				if v[3] == resname then
					acmds[k] = nil
				end
			end
		end
	end)

addEventHandler("onResourceStart", getResourceRootElement(),
	function(startedResource)
		connection = exports.cosmo_database:getConnection()

		local theRes = getResourceRootElement(getResourceFromName("cosmo_modstarter"))

		if theRes then
			local cache = getElementData(theRes, "adminCommandsCache")

			if cache then
				for k, v in pairs(cache) do
					if not acmds[k] then
						addAdminCommand(k, v[1], v[2], v[3])
					end
				end

				removeElementData(theRes, "adminCommandsCache")
			end
		end
	end)

	function updateAstat(player, data)
		local nowStat = false
		dbQuery(function(qh)
			local result = dbPoll(qh, 0)
			if result then
				for _, row in pairs(result) do
					nowStat = row[tostring(data)]
					--print(nowStat)
					if nowStat then
						dbExec(connection, 'UPDATE acmd SET ' .. tostring(data) .. '=? WHERE playerid = ?', nowStat + 1, getElementData(player, 'acc.ID'))
						--print('Admin statok frissitve')
					end
				end
			end
		end, connection, 'SELECT * FROM acmd WHERE playerid=?',getElementData(player, 'acc.ID'))
	end
	 
	addEventHandler('onResourceStart', resourceRoot, function()
		for k, v in pairs(getElementsByType('player')) do
			if havePermission(v, 'ajail', true) then
				dbQuery(function(qh)
					local result = dbPoll(qh, 0)
					if result and #result > 0 then
						--print('Már egyes játékosoknak, van adatjuk')
					else
						--print('Nincs (adatok pótolva ~ theMark)')
						dbExec(connection, 'INSERT INTO acmd SET playerid=?', getElementData(v, 'acc.ID'))
					end
				end, connection, 'SELECT * FROM acmd WHERE playerid=?', getElementData(v, 'acc.ID'))
			end
		end
	end)

addEventHandler("onPlayerChangeNick", getRootElement(),
	function(oldNick, newNick, changedByUser)
		if changedByUser then
			cancelEvent()
		end
	end)

function outputUsageText(commandName, string, playerSource)
	if isElement(playerSource) then
		outputChatBox(exports.cosmo_core:getServerTag("usage") .. "/" .. commandName .. " " .. string, playerSource, 0, 0, 0, true)
	end
end

function outputErrorText(string, playerSource)
	if isElement(playerSource) then
		outputChatBox(exports.cosmo_core:getServerTag("error") .. string, playerSource, 0, 0, 0, true)

		exports.cosmo_core:playSoundForElement(playerSource, ":cosmo_assets/audio/admin/error.ogg")
	end
end

function outputInfoText(string, playerSource)
	if isElement(playerSource) then
		outputChatBox(exports.cosmo_core:getServerTag("info") .. string, playerSource, 0, 0, 0, true)
	end
end

function outputAdminText(string, playerSource)
	if isElement(playerSource) then
		outputChatBox(exports.cosmo_core:getServerTag("admin") .. string, playerSource, 0, 0, 0, true)
	end
end

function getPlayerAdminNick(playerSource)
	if isElement(playerSource) then
		return getElementData(playerSource, "acc.adminNick") or "Admin"
	end
end

function getPlayerCharacterName(playerSource)
	if isElement(playerSource) then
		return (getElementData(playerSource, "char.Name"):gsub("_", " "))
	end
end

function getPlayerVisibleName(playerSource)
	if isElement(playerSource) then
		return (getElementData(playerSource, "visibleName"):gsub("_", " "))
	end
end

function havePermission(playerSource, command, forceDuty, helperLevel)
	if isElement(playerSource) then
		if (getElementData(playerSource, "acc.adminLevel") or 0) >= 7 then
			return true
		end

		if helperLevel and getElementData(playerSource, "acc.helperLevel") >= helperLevel then
			if forceDuty and helperLevel == 2 and not getElementData(playerSource, "helperDuty") then
				outputErrorText("Csak adminsegéd szolgálatban használhatod az adminsegéd parancsokat! (/asduty)", playerSource)
				return false
			end

			return true
		end

		if (getElementData(playerSource, "acc.adminLevel") or 0 ) >= acmds[command][1] and getElementData(playerSource, "acc.adminLevel") ~= 0 then
            if getElementData(playerSource, "acc.adminLevel") >= 6 then
                return true
            end

            if forceDuty then
                if not getElementData(playerSource, "adminDuty") then
                    outputErrorText("Csak adminszolgálatban használhatod az admin parancsokat!", playerSource)

                    return false
                else
                    return true
                end
            else
                return true
            end
		end
	end

	return false
end

local dutyTime = {}

addEventHandler("onResourceStop", getRootElement(),
	function(res)
		exports.cosmo_core:sendMessageToAdmins("Resource sikeresen leállítva. #d75959(" .. getResourceName(res) .. ")", 8)

		if res == getThisResource() then
			for k, v in pairs(dutyTime) do
				if isElement(k) then
					dbExec(connection, "UPDATE accounts SET adminDutyTime = adminDutyTime + ? WHERE accountID = ?", getTickCount() - v, getElementData(k, "acc.dbID"))
				end
			end
		end
	end)

addEventHandler("onResourceStart", getRootElement(),
	function(res)
		exports.cosmo_core:sendMessageToAdmins("Resource sikeresen elindítva. #d75959(" .. getResourceName(res) .. ")", 8)
	end)

addEventHandler("onElementDataChange", getRootElement(),
	function(data, oldval, newval)
		if data == "adminDuty" then
			if getElementData(source, "adminDuty") then
				dutyTime[source] = getTickCount()
			elseif dutyTime[source] then
				dbExec(connection, "UPDATE accounts SET adminDutyTime = adminDutyTime + ? WHERE accountID = ?", getTickCount() - dutyTime[source], getElementData(source, "acc.dbID"))
				dutyTime[source] = nil
			end
		end
	end)

addEventHandler("onPlayerQuit", getRootElement(),
	function()
		if dutyTime[source] then
			dbExec(connection, "UPDATE accounts SET adminDutyTime = adminDutyTime + ? WHERE accountID = ?", getTickCount() - dutyTime[source], getElementData(source, "acc.dbID"))
			dutyTime[source] = nil
		end
	end)

	setTimer(function()
		for k, v in pairs(getElementsByType('player')) do
			dbQuery(function(qh)
				local result = dbPoll(qh, 0)
				if result and #result > 0 then
					for _, row in pairs(result) do
						dbExec(connection, 'UPDATE acmd SET atime=? WHERE playerid=?', row['adminDutyTime'] or 0, getElementData(v, 'acc.ID'))
					end
				end
			end, connection, 'SELECT * FROM accounts WHERE accountID=?', getElementData(v, 'acc.ID'))
		end
	end, 5000, 0)
	function convertTime(ms) 
		local min = math.floor ( ms/60000 ) 
		local sec = math.floor( (ms/1000)%60 ) 
		return min, sec 
	end

	addAdminCommand('kozmunka', 11, 'Játékos közmunkára tétele.')
	addCommandHandler('kozmunka', function(player, cmd, target, time, ...)
		if getElementData(player, "acc.adminLevel") >= 11 then
		local reason = table.concat({...}, ' ')
		local time = tonumber(time)
		if target and reason then
			if time then
				local targetPlayer = exports.cosmo_core:findPlayer(player, target)
				if targetPlayer then
					if isPedInVehicle(targetPlayer) then
						removePedFromVehicle(targetPlayer)
					end
					setElementInterior(targetPlayer, 0)
					setElementDimension(targetPlayer, 0)
					outputInfoText('Sikeresen beraktad ' .. getElementData(targetPlayer, "visibleName"):gsub('_', ' ') .. ' játékost ' .. time .. ' közmunkára', player)
					updateAstat(targetPlayer, "kozmunka")
					setElementData(targetPlayer, 'adminjob>player', true)
					setElementData(targetPlayer, 'adminjob>playertime', time)
					setElementPosition(targetPlayer, -532.76165771484, -98.391479492188, 63.296875)
					dbExec(connection, 'UPDATE accounts SET kozmunka=?, kozmunkatime=? WHERE accountID=?', 1, time, getElementData(targetPlayer, 'acc.ID'))
					setTimer(function()
						triggerClientEvent(targetPlayer, 'createRandomMarker', targetPlayer)
						exports.cosmo_voice:setPlayerMuted(targetPlayer, true)
						toggleControl(targetPlayer, 'fire', false)
						toggleControl(targetPlayer, 'aim_weapon', false)
						local adminNick = getPlayerAdminNick(player)
						exports.cosmo_core:sendMessageToAdmins(exports.cosmo_core:getPlayerAdminTitle(player).. " #d75959" ..adminNick .. "#ffffff berakta #d75959" .. getElementData(targetPlayer, "visibleName"):gsub('_', ' ') .. '#ffffff játékost közmunkára #ffffffIndok: #d75959' .. reason .. ' #ffffffIdő: #d75959' .. time .. '', 7)
						outputInfoText(exports.cosmo_core:getPlayerAdminTitle(player) .. ' ' .. '#d75959' .. adminNick .. '#ffffff' .. ' berakta #d75959' .. getElementData(targetPlayer, "visibleName"):gsub('_', ' ') .. '#ffffff játékost közmunkára! Indok: ' .. reason, root)
					end, 350, 1)
				end
			else
				outputUsageText(cmd, "[Játékos név / ID] [Hány közmunka] [Indok]", player)
			end
		else
			outputUsageText(cmd, "[Játékos név / ID] [Hány közmunka] [Indok]", player)
		end
	end
end)
	 
	 
	function exportAJob(targetPlayer)
		if not targetPlayer or not isElement(targetPlayer) then
			return
		end
		targetPlayer.position = Vector3(0, 0, 3)
		Timer(function()
			triggerClientEvent(targetPlayer, 'createRandomMarker', targetPlayer)
			connection:query(function(qh)
				local result = dbPoll(qh, 0)
				if result and #result > 0 then
					for _, row in pairs(result) do
						if row.kozmunka == 1 then
							setElementData(target, 'adminjob>player', true)
							setElementData(target, 'adminjob>playertime', row.kozmunkatime)
							exports.cosmo_voice:setPlayerMuted(targetPlayer, true)
							toggleControl(targetPlayer, 'fire', false)
							toggleControl(targetPlayer, 'aim_weapon', false)
						end
					end
				end
			end, 'SELECT * FROM accounts WHERE accountID=?', getElementData(targetPlayer, 'acc.ID'))
		end, 350, 1)
	end
	 
	addAdminCommand('kozmunkaki', 11, 'Játékos közmunkából kivétel')
	addCommandHandler('kozmunkaki', function(player, cmd, target, time, ...)
		if getElementData(player, "acc.adminLevel") >= 11 then
		local reason = table.concat({...}, ' ')
		if target and reason  then
			local targetPlayer = exports.cosmo_core:findPlayer(player, target)
			if targetPlayer then
				outputInfoText('Sikeresen kivetted ' .. getElementData(targetPlayer, "visibleName"):gsub('_', ' ') .. ' játékost közmunkából', player)
				updateAstat(targetPlayer, "kozmunkaki")
				setElementData(targetPlayer, 'adminjob>player', false)
				setElementData(targetPlayer, 'adminjob>playertime', 0)
				dbExec(connection, 'UPDATE accounts SET kozmunka=? WHERE accountID=?', 0, getElementData(targetPlayer, 'acc.ID'))
				setElementPosition(targetPlayer, 1481.8155517578, -1737.2559814453, 13.3828125)
				exports.cosmo_voice:setPlayerMuted(targetPlayer, false)
				toggleControl(targetPlayer, 'fire', true)
				toggleControl(targetPlayer, 'aim_weapon', true)
				local adminNick = getPlayerAdminNick(player)
				triggerClientEvent(targetPlayer, 'destroyTargetMarkers', targetPlayer)
				outputInfoText(exports.cosmo_core:getPlayerAdminTitle(player) .. ' ' .. '#d75959' .. adminNick .. '#ffffff' .. ' kivette #d75959' .. getElementData(targetPlayer, "visibleName"):gsub('_', ' ') .. '#ffffff játékost közmunkából! Indok:' .. reason, root)
				exports.cosmo_core:sendMessageToAdmins(exports.cosmo_core:getPlayerAdminTitle(player).. " #d75959" ..adminNick .. "#ffffff kivette #d75959" .. getElementData(targetPlayer, "visibleName"):gsub('_', ' ') .. '#ffffff játékost közmunkáról #ffffff Indok: #d75959 ' .. reason .. '', 7)
			end
		else
			outputUsageText(cmd, "[Játékos név / ID] [Indok]", player)
		end
	end
end)
	  
	 
	addEvent('debugPlayerPosition', true)
	addEventHandler('debugPlayerPosition', root, function(player)
		if isElement(player) then
			player.position = Vector3(0, 0, 5)
		end
	end)
	 
	 
	addEventHandler('onResourceStart', resourceRoot, function()
		for k, v in pairs(getElementsByType('player')) do
			if getElementData(v, 'adminjob>player') and getElementData(v, 'adminjob>playertime') > 0 then
				if isElement(v) then
					setElementPosition(v, -532.76165771484, -98.391479492188, 63.296875)
					setTimer(function()
						triggerClientEvent(v, 'createRandomMarker', v)
						exports.cosmo_voice:setPlayerMuted(v, true)
						toggleControl(v, 'fire', false)
						toggleControl(v, 'aim_weapon', false)
					end, 350, 1)
				end
			end
		end
	end)
	 
	addEvent('setPlayerAnimation', true)
	addEventHandler('setPlayerAnimation', root, function(player, a, b)
		if a and b then
			setPedAnimation(player, a, b)
		else
			setPedAnimation(player)
		end
	end)
	 
	 
	addEvent('updateAjob', true)
	addEventHandler('updateAjob', root, function(localPlayer)
		setElementData(localPlayer, 'adminjob>playertime', getElementData(localPlayer, 'adminjob>playertime') - 1)
		dbExec(connection, 'UPDATE accounts SET kozmunkatime=? WHERE accountID=?', getElementData(localPlayer, 'adminjob>playertime'), getElementData(localPlayer, 'acc.ID'))
	end)
	 
	addEvent('getPlayerAJob', true)
	addEventHandler('getPlayerAJob', root, function(player)
		setElementPosition(player, 1481.8155517578, -1737.2559814453, 13.3828125)
		setElementData(player, 'adminjob>player', false)
		setElementData(player, 'adminjob>playertime', false)
		exports.cosmo_voice:setPlayerMuted(player, false)
		dbExec(connection, 'UPDATE accounts SET kozmunka=?, kozmunkatime=? WHERE accountID=?', 0, 0,getElementData(player, 'acc.ID'))
		triggerClientEvent(player, 'destroyTargetMarkers', player)
		toggleControl(player, 'fire', true)
		toggleControl(player, 'aim_weapon', true)
	end)