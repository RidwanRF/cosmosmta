local abKapcsolat = exports.cosmo_database:getConnection()

function mdcLoginServer(username, password)
	local source = client
	dbQuery(
		function (queryHandler)
			local result, numAffectedRows, errorMsg = dbPoll(queryHandler, 0)
			if numAffectedRows > 0 then
				for _, row in ipairs(result) do
 					frakcio = row["frakcio"]
 				end
 				triggerClientEvent(source, "loginMdcClient", source, frakcio)
			else
				exports.cosmo_hud:showInfobox(source,"error","Hibás felhasználónév/jelszó.")
			end
		end,
		abKapcsolat,
		"SELECT * FROM mdcaccounts WHERE username = ? AND password = ?", username, password
	)
end
addEvent("mdcLoginServer", true)
addEventHandler("mdcLoginServer", getRootElement(), mdcLoginServer)

addEvent("acceptPlayerLogin", true)
addEventHandler("acceptPlayerLogin", getRootElement(), function(player)
	triggerClientEvent(player, "loginMdcClient", player)
end)

function createMdcAccount(thePlayer, command, username, password)
	if exports.cosmo_groups:isPlayerLeaderInGroup(thePlayer, 1) then
		faction = "LSPD"
		if faction then
		if not (username) or not (password) then
			outputChatBox("#ff9428[CosmoMTA]: #FFFFFF/" .. command .. " [Felhasználónév] [Jelszó]", thePlayer, 255, 0, 0, true)
		else
			local query = dbExec(abKapcsolat, "INSERT INTO mdcaccounts SET username = ?, password = ?, frakcio = ?",username,password,faction)
			if query then
				outputChatBox("#ff9428[CosmoMTA - MDC]: #ffffffHozzáadva!", thePlayer, 255, 0, 0, true)
			else
				outputChatBox("#ff9428[CosmoMTA - MDC] #ffffffMySQL Hiba [#001-es kód]", thePlayer, 255, 0, 0, true)
			end

			end
		end
	end
	if exports.cosmo_groups:isPlayerLeaderInGroup(thePlayer, 4) then
		    faction = "FBI"
			if faction then
		if not (username) or not (password) then
			outputChatBox("#ff9428[CosmoMTA - Használat]: #ffffff/" .. command .. " [Felhasználónév] [Jelszó]", thePlayer, 255, 0, 0, true)
		else
			local query = dbExec(abKapcsolat, "INSERT INTO mdcaccounts SET username = ?, password = ?, frakcio = ?",username,password,faction)
			if query then
				outputChatBox("#ff9428[CosmoMTA - MDC]: #ffffffHozzáadva!", thePlayer, 255, 0, 0, true)
			else
				outputChatBox("#ff9428[CosmoMTA - MDC] #ffffffMySQL Hiba [#001-es kód]", thePlayer, 255, 0, 0, true)
			    end
			end
		end
	end
	if exports.cosmo_groups:isPlayerLeaderInGroup(thePlayer, 57) then
		faction = "SWAT"
	if faction then
		if not (username) or not (password) then
			outputChatBox("#ff9428[CosmoMTA - Használat]: #ffffff/" .. command .. " [Felhasználónév] [Jelszó]", thePlayer, 255, 0, 0, true)
		else
		local query = dbExec(abKapcsolat, "INSERT INTO mdcaccounts SET username = ?, password = ?, frakcio = ?",username,password,faction)
			if query then
				outputChatBox("#ff9428[CosmoMTA - MDC]: #ffffffHozzáadva!", thePlayer, 255, 0, 0, true)
			else
				outputChatBox("#ff9428[CosmoMTA - MDC] #ffffffMySQL Hiba [#001-es kód]", thePlayer, 255, 0, 0, true)
			    end
			end
		end
	end
	if exports.cosmo_groups:isPlayerLeaderInGroup(thePlayer, 58) then
		faction = "SASD"
	if faction then
		if not (username) or not (password) then
			outputChatBox("#ff9428[CosmoMTA - Használat]: #ffffff/" .. command .. " [Felhasználónév] [Jelszó]", thePlayer, 255, 0, 0, true)
		else
		local query = dbExec(abKapcsolat, "INSERT INTO mdcaccounts SET username = ?, password = ?, frakcio = ?",username,password,faction)
			if query then
				outputChatBox("#ff9428[CosmoMTA - MDC]: #ffffffHozzáadva!", thePlayer, 255, 0, 0, true)
			else
				outputChatBox("#ff9428[CosmoMTA - MDC] #ffffffMySQL Hiba [#001-es kód]", thePlayer, 255, 0, 0, true)
			    end
			end
		end
	end
end
addCommandHandler("createmdcaccount", createMdcAccount)

function deleteMdcAccount(thePlayer, command, username)
	if exports.cosmo_groups:isPlayerLeaderInGroup(thePlayer, 1) then
		faction = "LSPD"

	    if faction then
	    if not (username) then
			outputChatBox("#ff9428[CosmoMTA - MDC]: #ffffff/" .. command .. " [Felhasználónév]", thePlayer, 255, 0, 0, true)
		else
			local query = dbExec(abKapcsolat, "DELETE FROM mdcaccounts WHERE username=?",username)
			if query then
				outputChatBox("#ff9428[CosmoMTA - MDC]: #ffffffKitörölve!", thePlayer, 255, 0, 0, true)
			else
				outputChatBox("#ff9428[CosmoMTA - MDC]: #ffffffMySQL Hiba [#002-es kód]", thePlayer, 255, 0, 0, true)
			    end
			end
		end
	end
	if exports.cosmo_groups:isPlayerLeaderInGroup(thePlayer, 4) then
		faction = "FBI"

	    if faction then
	    if not (username) then
			outputChatBox("#ff9428[CosmoMTA - MDC]: #ffffff/" .. command .. " [Felhasználónév]", thePlayer, 255, 0, 0, true)
		else
			local query = dbExec(abKapcsolat, "DELETE FROM mdcaccounts WHERE username=?",username)
			if query then
				outputChatBox("#ff9428[CosmoMTA - MDC]: #ffffffKitörölve!", thePlayer, 255, 0, 0, true)
			else
				outputChatBox("#ff9428[CosmoMTA - MDC]: #ffffffMySQL Hiba [#002-es kód]", thePlayer, 255, 0, 0, true)
			    end
			end
		end
	end
	if exports.cosmo_groups:isPlayerLeaderInGroup(thePlayer, 57) then
		faction = "SWAT"

	    if faction then
	    if not (username) then
			outputChatBox("#ff9428[CosmoMTA - MDC]: #ffffff/" .. command .. " [Felhasználónév]", thePlayer, 255, 0, 0, true)
		else
			local query = dbExec(abKapcsolat, "DELETE FROM mdcaccounts WHERE username=?",username)
			if query then
				outputChatBox("#ff9428[CosmoMTA - MDC]: #ffffffKitörölve!", thePlayer, 255, 0, 0, true)
			else
				outputChatBox("#ff9428[CosmoMTA - MDC]: #ffffffMySQL Hiba [#002-es kód]", thePlayer, 255, 0, 0, true)
			    end
			end
		end
	end
	if exports.cosmo_groups:isPlayerLeaderInGroup(thePlayer, 58) then
		faction = "SASD"

	    if faction then
	    if not (username) then
			outputChatBox("#ff9428[CosmoMTA - MDC]: #ffffff/" .. command .. " [Felhasználónév]", thePlayer, 255, 0, 0, true)
		else
			local query = dbExec(abKapcsolat, "DELETE FROM mdcaccounts WHERE username=?",username)
			if query then
				outputChatBox("#ff9428[CosmoMTA - MDC]: #ffffffKitörölve!", thePlayer, 255, 0, 0, true)
			else
				outputChatBox("#ff9428[CosmoMTA - MDC]: #ffffffMySQL Hiba [#002-es kód]", thePlayer, 255, 0, 0, true)
			    end
			end
		end
	end
end
addCommandHandler("deletemdcaccount", deleteMdcAccount)

--================================================--

local positions = {
  	-- x, y, z, méret, név
  	{1939.830078125, -1778.4091796875, 13.390598297119, 20, "Déli benzinkút"},
  	{1528.837890625, -1674.6318359375, 13.3828125, 50, "Rendőrség"},
  	--{1304.6455078125, -1700.59375, 13.546875, 50, "Mozi"},
  	{1548.044921875, -1789.8291015625, 13.546875, 50, "Városháza mellet"},
  	{1477.966796875, -1759.06640625, 13.58437538147, 50, "Városháza előtt"},
  	{2102.0439453125, -1782.5283203125, 13.392087936401, 50, "Well Stacked Pizzázó"},
  	{1909.9931640625, -1421.6787109375, 11.533273696899, 100, "Skate Park"},
  	{1012.896484375, -931.2958984375, 42.1796875, 50, "Északi benzinkút"},
  	{1582.197265625, -2165.1767578125, 13.60000038147, 50, "Szerelőtelep"},
  	{2227.388671875, -1722.4697265625, 13.555265426636, 20, "Edzőterem"},
  	--{2860.5537109375, -2048.947265625, 10.9375, 30, "Versenypálya bejárat"},
  	--{2058.3115234375, -1912.3310546875, 13.546875, 50, "Taxis telep"},
  	{1821.87109375, -1684.2158203125, 13.3828125, 50, "Alhambra Club"},
  	{1192.4443359375, -1322.03125, 13.3984375, 50, "Kórház"}
}

for k,v in ipairs(positions) do
   local x,y,z = v[1], v[2], v[3]
   local marker = createMarker(x,y,z-1, "cylinder", v[4], 255,255,255,0)
   setElementData(marker, "marker.ZoneName", v[5])
   setElementData(marker, "marker.isZoneCamera", true)
end

--================================================--

local factionNames = {
	[1]="LSPD",
	[4]="FBI",
	[57]="SWAT",
	[58]="SASD",
}

function sendGroupMessage(factionid, msg)
	for k, v in ipairs(getElementsByType("player")) do
		if exports.cosmo_groups:isPlayerInGroup(v,tonumber(factionid)) then
			outputChatBox("#F9BF3B[" .. factionNames[factionid] .. "]#ffffff " .. msg, v, 255, 255, 255, true)
		end
	end
end
addEvent("sendGroupMessage", true)
addEventHandler("sendGroupMessage", root, sendGroupMessage)

function sendMessageToPolice(text, number)
	--sendGroupMessage(28, "#ff9428" .. text .. "")
	sendGroupMessage(1, "#ff9428" .. text .. "")
	sendGroupMessage(4, "#ff9428" .. text .. "")
	sendGroupMessage(57, "#ff9428" .. text .. "")
	sendGroupMessage(58, "#ff9428" .. text .. "")
end
addEvent("sendMessageToPolice", true)
addEventHandler("sendMessageToPolice", getRootElement(), sendMessageToPolice)

function sendMessageToPoliceG(text, number)
	--sendGroupMessage(28, "#ff9428" .. text .. "")
	sendGroupMessage(1, "#ff9428" .. text .. "")
	sendGroupMessage(4, "#ff9428" .. text .. "")
	sendGroupMessage(57, "#ff9428" .. text .. "")
	sendGroupMessage(58, "#ff9428" .. text .. "")
end
addEvent("sendMessageToPoliceG", true)
addEventHandler("sendMessageToPoliceG", getRootElement(), sendMessageToPoliceG)

function createBackupBlipServer(vehicle)
	for _, player in ipairs(getElementsByType("player")) do
		if exports.cosmo_groups:isPlayerInGroup(player,1) or exports.cosmo_groups:isPlayerInGroup(player,4) or exports.cosmo_groups:isPlayerInGroup(player,57) or exports.cosmo_groups:isPlayerInGroup(player,58) then 
			triggerClientEvent(player, "createBackupBlipClient", player, vehicle)
		end
	end
end
addEvent("createBackupBlipServer", true)
addEventHandler("createBackupBlipServer", getRootElement(), createBackupBlipServer)

function createBackupBlipServer2(vehicle, reason)
	for _, player in ipairs(getElementsByType("player")) do
		if exports.cosmo_groups:isPlayerInGroup(player,1) or exports.cosmo_groups:isPlayerInGroup(player,4) or exports.cosmo_groups:isPlayerInGroup(player,57) or exports.cosmo_groups:isPlayerInGroup(player,58) then 
			triggerClientEvent(player, "createBackupBlipClient2", player, vehicle)
		end
	end
	local unitNum = getElementData(vehicle, "visibleName") or "Ismeretlen"
	sendMessageToPoliceG("#e36868"..unitNum:gsub("_", " ") .. "#ffffff-nek/nak #e36868erősítésre#ffffff van szüksége az alábbi miatt: #e36868"..getElementData(vehicle, "mdc.backup"))
end
addEvent("createBackupBlipServer2", true)
addEventHandler("createBackupBlipServer2", getRootElement(), createBackupBlipServer2)

function destroyBlipServer(vehicle, backup)
	local unitNum = getElementData(vehicle, "visibleName") or "Ismeretlen"
	if backup == true then
		triggerClientEvent("destroyBlipClient", root, vehicle)
		sendMessageToPoliceG("#e36868"..unitNum:gsub("_", " ") .. " #fffffflemondta az #e36868erősítés#ffffff kérést.")
	else
		triggerClientEvent("destroyBlipClient", root, vehicle)
	end
end
addEvent("destroyBlipServer", true)
addEventHandler("destroyBlipServer", getRootElement(), destroyBlipServer)

function createDutyBlipServer(vehicle)
	for _, player in ipairs(getElementsByType("player")) do
		if exports.cosmo_groups:isPlayerInGroup(player,1) or exports.cosmo_groups:isPlayerInGroup(player,4) or exports.cosmo_groups:isPlayerInGroup(player,57) or exports.cosmo_groups:isPlayerInGroup(player,58) then 
			triggerClientEvent(player, "createDutyBlipClient", player, vehicle)
		end
	end
end
addEvent("createDutyBlipServer", true)
addEventHandler("createDutyBlipServer", getRootElement(), createDutyBlipServer)

function addTicket(charactername, price, jail, reason)
	 local insertSQL = dbExec(abKapcsolat, "INSERT INTO mdctickets SET targetname = ?, price = ?, jailtime =?, reason =?",charactername, price, jail, reason)
end
addEvent("addTicket", true)
addEventHandler("addTicket", getRootElement(), addTicket)

function deleteFromTickets(id)
	 local insertSQL = dbExec(abKapcsolat, "DELETE FROM mdctickets WHERE id=?",id)
end
addEvent("deleteFromTickets", true)
addEventHandler("deleteFromTickets", getRootElement(), deleteFromTickets)

function addWantedPerson(charactername, reason, description)
	 local insertSQL = dbExec(abKapcsolat, "INSERT INTO mdcwantedpersons SET charactername = ?, reason = ?, leiras = ?",charactername, reason, description)
end
addEvent("addWantedPerson", true)
addEventHandler("addWantedPerson", getRootElement(), addWantedPerson)

function deleteFromWantedPersons(id)
	 local insertSQL = dbExec(abKapcsolat, "DELETE FROM mdcwantedpersons WHERE id=?",id)
end
addEvent("deleteFromWantedPersons", true)
addEventHandler("deleteFromWantedPersons", getRootElement(), deleteFromWantedPersons)

function addWantedCar(modelname,numberplate,reason)
	 local insertSQL = dbExec(abKapcsolat, "INSERT INTO mdcwantedcars SET modelname = ?, numberplate = ?, reason = ?",modelname,numberplate,reason)
	 triggerEvent("getKorozottKocsik", root)
end
addEvent("addWantedCar", true)
addEventHandler("addWantedCar", getRootElement(), addWantedCar)

function deleteFromWantedCars(id)
	 local insertSQL = dbExec(abKapcsolat, "DELETE FROM mdcwantedcars WHERE id=?",id)
	 triggerEvent("getKorozottKocsik", root)
end
addEvent("deleteFromWantedCars", true)
addEventHandler("deleteFromWantedCars", getRootElement(), deleteFromWantedCars)

function getTicketsServer(playerSource)
	local tickets = {}
	tickets = {}
	local QueryEredmeny = dbPoll ( dbQuery( abKapcsolat, "SELECT * FROM mdctickets"), -1 )
	if (QueryEredmeny) then
		for k, v in ipairs(QueryEredmeny) do
			tickets[#tickets + 1] = {v["targetname"], v["price"], v["jailtime"], v["reason"], v["id"]}
		end
		triggerClientEvent(root, "getTicketsClient", root, tickets)
	end
end
addEvent("getTicketsServer", true)
addEventHandler("getTicketsServer", getRootElement(), getTicketsServer)

function getWantedCarsServer(playerSource)
	local wantedcars = {}
	wantedcars = {}
	local QueryEredmeny = dbPoll ( dbQuery( abKapcsolat, "SELECT * FROM mdcwantedcars"), -1 )
	if (QueryEredmeny) then
		for k, v in ipairs(QueryEredmeny) do
			wantedcars[#wantedcars + 1] = {v["modelname"], v["numberplate"], v["reason"], v["id"]}
		end
		triggerClientEvent(root, "getWantedCarsClient", root, wantedcars)
	end
end
addEvent("getWantedCarsServer", true)
addEventHandler("getWantedCarsServer", getRootElement(), getWantedCarsServer)

function getWantedPersonsServer(playerSource)
	local wantedpersons = {}
	wantedpersons = {}
	local QueryEredmeny = dbPoll ( dbQuery( abKapcsolat, "SELECT * FROM mdcwantedpersons"), -1 )
	if (QueryEredmeny) then
		for k, v in ipairs(QueryEredmeny) do
			wantedpersons[#wantedpersons + 1] = {v["charactername"], v["reason"], v["id"], v["leiras"]}
		end
		triggerClientEvent(root, "getWantedPersonsClient", root, wantedpersons)
	end
end
addEvent("getWantedPersonsServer", true)
addEventHandler("getWantedPersonsServer", getRootElement(), getWantedPersonsServer)

--[[Szirénapanel]]--

function playSoundServerOff(vehicle)
	local model = getElementModel(vehicle)
	if vehicle then
		triggerClientEvent(root, "stopSoundsClient", vehicle)
end
end
addEvent("playSoundServerOff", true)
addEventHandler ( "playSoundServerOff", getRootElement(), playSoundServerOff )

function playSoundServer(vehicle)
	local model = getElementModel(vehicle)
	if vehicle then
	if (model==598) or (model==597) or (model==596) or (model==599) or (model==490) or (model==604) or (model==479) or (model==490) or (model==523) or (model==528) or (model==601) or (model==427) then
		soundPath = "sound/siren2.mp3"
	elseif (model==416) or (model==419) then
		soundPath = "sound/ambulance.mp3"
	elseif (model==407) or (model==544) then
		soundPath = "sound/siren2_fire.mp3"
	end
triggerClientEvent(root, "playSoundClient", vehicle, soundPath)
end
end
addEvent("playSoundServer", true)
addEventHandler ( "playSoundServer", getRootElement(), playSoundServer )

function playSoundServer2(vehicle)
	local model = getElementModel(vehicle)
	if vehicle then
	if (model==598) or (model==597) or (model==596) or (model==599) or (model==490) or (model==604) or (model==479) or (model==490) or (model==523) or (model==528) or (model==601) or (model==427) then
		soundPath = "sound/siren3.mp3"
	elseif (model==416) or (model==419) then
		soundPath = "sound/siren3_fire.mp3"
	elseif (model==407) or (model==544) then
		soundPath = "sound/siren3_fire.mp3"
	end
triggerClientEvent(root, "playSoundClient2", vehicle, soundPath)
end
end
addEvent("playSoundServer2", true)
addEventHandler ( "playSoundServer2", getRootElement(), playSoundServer2 )

function playSoundServer3(vehicle)
	local model = getElementModel(vehicle)
	if vehicle then
	if (model==598) or (model==597) or (model==596) or (model==599) or (model==490) or (model==604) or (model==479) or (model==490) or (model==523) or (model==528) or (model==601) or (model==427) then
		soundPath = "sound/siren4.mp3"
	elseif (model==523) then
		soundPath = "sound/siren4.mp3"
	elseif (model==416) or (model==419) then
		soundPath = "sound/siren4.mp3"
	elseif (model==407) or (model==544) then
		soundPath = "sound/siren4.mp3"
	end
triggerClientEvent(root, "playSoundClient3", vehicle, soundPath)
end
end
addEvent("playSoundServer3", true)
addEventHandler ( "playSoundServer3", getRootElement(), playSoundServer3 )

function playSoundServer4(vehicle)
	local model = getElementModel(vehicle)
	if vehicle then
	if (model==598) or (model==597) or (model==596) or (model==599) or (model==490) or (model==604) or (model==479) or (model==490) or (model==523) or (model==528) or (model==601) or (model==427) then
			soundPath = "sound/sirenhorn.mp3"
	elseif (model==523) then
		soundPath = "sound/sirenhorn.mp3"
	elseif (model==416) or (model==419) then
		soundPath = "sound/sirenhorn.mp3"
	elseif (model==407) or (model==544) then
		soundPath = "sound/sirenhorn.mp3"
	end
triggerClientEvent(root, "playSoundClient4", vehicle, soundPath)
end
end
addEvent("playSoundServer4", true)
addEventHandler ( "playSoundServer4", getRootElement(), playSoundServer4 )

function toggleSirens(vehicle)
		if (vehicle) then
			if (getElementData(vehicle, "veh:sirensOn")) then
				removeElementData(vehicle, "veh:sirensOn")
				setVehicleSirensOn(vehicle, false)
			else
				setElementData(vehicle, "veh:sirensOn", true, true)
				setVehicleSirensOn(vehicle, true)
			end
		end
	end
addEvent("toggleSirens", true)
addEventHandler ( "toggleSirens", getRootElement(), toggleSirens )

--[[CCTV]]--

local pdcamera1 = createObject ( 2606, 253.7, 115.19140625, 1009, 0, 0, 90)
local pdcamera2 = createObject ( 2606, 253.7, 115.19140625, 1009.5, 0, 0, 90)
local pdcamera3 = createObject ( 2606, 253.7, 115.19140625, 1010, 0, 0, 90)
setElementInterior(pdcamera1,10)
setElementDimension(pdcamera1,31)
setElementInterior(pdcamera2,10)
setElementDimension(pdcamera2,31)
setElementInterior(pdcamera3,10)
setElementDimension(pdcamera3,31)