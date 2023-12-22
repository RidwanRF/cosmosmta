local connection = exports.cosmo_database:getConnection()

function addContact(player, number, name, ownerNumber)
	if player and number and name and ownerNumber then		
		dbQuery(
			function(qh, sourcePlayer)
				local result = dbPoll(qh, 0, true)[2]
				
				if result then
					if isElement(sourcePlayer) then
						print("contact sikeresen hozzáadva")
					end
				end
			end, {player}, connection, "INSERT INTO contacts (name, number, owner, accID) VALUES (?, ?, ?, ?)", name, number, ownerNumber, getElementData(player, "acc.ID")
		)
	end
end
addEvent("addContact", true)
addEventHandler("addContact", getRootElement(), addContact)

function loadSMS(player, ownerNumber)
	if player and ownerNumber then
		dbQuery(
			function(qh, sourcePlayer)
				local result = dbPoll(qh, 0)
				if #result > 0 then
					for k, v in pairs(result) do
						triggerClientEvent(player, "loadSMSFromServer", player, fromJSON(v.data2))
					end
				end
			end, {player}, connection, "SELECT * FROM items WHERE data1 = ?", ownerNumber
		)
	end
end
addEvent("loadSMS", true)
addEventHandler("loadSMS", getRootElement(), loadSMS)

function loadContact(player, ownerNumber)
	if player and ownerNumber then
		dbQuery(
			function(qh, sourcePlayer)
				local result = dbPoll(qh, 0)
				local contacts = {}
				if isElement(sourcePlayer) then
					for k, v in ipairs(result) do
						table.insert(contacts, {v["name"], v["number"], tocolor(pastelcolor(v["name"]))})
						table.sort(contacts, function(a, b) return a[1] < b[1] end)				
					end
					triggerClientEvent(player, "loadContactsFromServer", player, contacts)
				end
			end, {player}, connection, "SELECT * FROM contacts WHERE accID = ?", ownerNumber
		)
	end
end
addEvent("loadContact", true)
addEventHandler("loadContact", getRootElement(), loadContact)

function removeContact(player, number, ownNumber)
	if player and number and ownNumber then
		dbQuery(
			function(qh, sourcePlayer)
				dbFree(qh)
			end, {player}, connection, "DELETE FROM contacts WHERE number = ? and owner = ?", number, ownNumber
		)
	end
end
addEvent("removeContact", true)
addEventHandler("removeContact", getRootElement(), removeContact)

function onClientCallAd(player, ad, number)
	if player and ad and number then
		for i, v in ipairs(getElementsByType("player")) do
			if getElementData(v, "loggedIn") then
				if getElementData(v, "hiredetesbekapcsolva") then
					if getElementData(player,"telefonszambekapcsolva") then
						outputChatBox ("#a3c96eHIRDETÉS: #e0bd21" ..ad.. " ((".. getPlayerName(player):gsub("_", " ") .."))",v,0, 233, 58,true)
						outputChatBox ("#a3c96eKapcsolat: #e0bd21" .. number,v,0, 233, 58,true)
					else
						outputChatBox ("#a3c96eHIRDETÉS: #e0bd21" ..ad.. " ((".. getPlayerName(player):gsub("_", " ") .."))",v,0, 233, 58,true)
					end
				end
			end
		end
	end
end
addEvent("onClientCallAd", true)
addEventHandler("onClientCallAd", getRootElement(), onClientCallAd)

function onClientCallAdDark(player, ad, number)
	if player and ad and number then
		for i, v in ipairs(getElementsByType("player")) do
			if getElementData(v, "loggedIn") then
				if getElementData(v, "hiredetesbekapcsolvaillegal") then
					if getElementData(player,"telefonszambekapcsolvaillegal") then
						outputChatBox ("#b8312f[DarkWeb]: #d79f00" ..ad.. " ((".. getPlayerName(player):gsub("_", " ") .."))",v,0, 233, 58,true)
						outputChatBox ("#b8312fKapcsolat: #d79f00" .. number,v,0, 233, 58,true)	
					else
						outputChatBox ("#b8312f[DarkWeb]: #d79f00" ..ad.. " ((".. getPlayerName(player):gsub("_", " ") .."))",v,0, 233, 58,true)
					end
				end
			end
		end
	end
end
addEvent("onClientCallAdDark", true)
addEventHandler("onClientCallAdDark", getRootElement(), onClientCallAdDark)

function callTargetInServer(player, number, playerNumber)
	if player and number and playerNumber then
		targetPlayer = callMember(number)
		
		if targetPlayer and targetPlayer ~= "inCall" then
			exports.cosmo_chat:sendLocalMeAction(player, "felhív valakit.")
			exports.cosmo_chat:sendLocalDoAction(targetPlayer, "Csörög a telefonja.")
			
			local tDBID = exports.cosmo_inventory:getDBIdFromData1(targetPlayer, number)

			triggerClientEvent(root, "playPhoneSound", root, targetPlayer, "call")

			local x, y, z = getElementPosition(targetPlayer)

			triggerClientEvent(targetPlayer, "showPhoneInCall", targetPlayer, playerNumber, player, tDBID)
			triggerClientEvent(player, "calling", player, targetPlayer)
		elseif targetPlayer == "inCall" then
			exports.cosmo_hud:showInfobox(player, "error", "Ezen a szám már hívásban van.")
		else
			exports.cosmo_hud:showInfobox(player, "error", "Ezen a számon előfizető nem kapcsolható.")
		end
	end
end
addEvent("callTargetInServer", true)
addEventHandler("callTargetInServer", getRootElement(), callTargetInServer)

function acceptCallServer(player, caller)
	if player and caller then
		triggerClientEvent(caller, "accpetedCall", caller, player)
		setElementData(player, "isCall", true)
		setElementData(caller, "isCall", true)
		triggerClientEvent(root, "stopPhoneSound", root, caller)
		triggerClientEvent(root, "stopPhoneSound", root, player)
	end
end
addEvent("acceptCallServer", true)
addEventHandler("acceptCallServer", getRootElement(), acceptCallServer)

function cancelledCallSend(player, caller)
	if player and caller then
		triggerClientEvent(caller, "cancelledCall", caller)
		setElementData(player, "isCall", false)
		setElementData(caller, "isCall", false)
		triggerClientEvent(root, "stopPhoneSound", root, caller)
		triggerClientEvent(root, "stopPhoneSound", root, player)
	end
end
addEvent("cancelledCallSend", true)
addEventHandler("cancelledCallSend",  getRootElement(), cancelledCallSend)

function sendCallMessages(player, targetPlayer, msg, number)
	if player and targetPlayer and msg and number then
		triggerClientEvent(player, "insertMessages", player, msg, number)
		triggerClientEvent(targetPlayer, "insertMessages", targetPlayer, msg, number)
		
		exports.cosmo_chat:sendLocalMessageInPhone(player, msg)
	end
end
addEvent("sendCallMessages", true)
addEventHandler("sendCallMessages", getRootElement(), sendCallMessages)


-- SMS
function newSMS(player, myNumber, number, text, oldSMS)
	if player and myNumber and number and text then
		local targetPlayer = callMembersms(number)
		if targetPlayer then
			dbQuery(
				function(qh, sourcePlayer)
					local result = dbPoll(qh, 0)
					
					if #result > 0 then
						for k, v in pairs(result) do
							local sms = fromJSON(v.data2)
							sms = addSMS(sms, text, myNumber, number)
							sms2 = addSMS2(oldSMS, text, number, myNumber)
							
							exports.cosmo_chat:sendLocalMeAction(plyer, "küldött egy üzenetet.")
							
							dbExec(connection, "UPDATE items SET data2 = ? WHERE data1 = ?", toJSON(sms), number)
							dbExec(connection, "UPDATE items SET data2 = ? WHERE data1 = ?", toJSON(sms2), myNumber)
						end
					end
				end, {player}, connection, "SELECT * FROM items WHERE data1 = ?", number
			)
		else
			exports.cosmo_hud:showInfobox(player, "error", "Ezen a számon előfizető nem kapcsolható.")
		end
	end
end
addEvent("newSMS", true)
addEventHandler("newSMS", getRootElement(), newSMS)

function smsSync(player, myNumber, tables)
	if player and myNumber and tables then
		dbExec(connection, "UPDATE items SET data2 = ? WHERE data1 = ?", toJSON(tables), myNumber)
	end
end
addEvent("smsSync", true)
addEventHandler("smsSync", getRootElement(), smsSync)

function sendMessages(player, myNumber, number, text)
	if player and myNumber and number and text then
		dbQuery(
			function(qh, sourcePlayer)
				local result = dbPoll(qh, 0)
				
				if #result > 0 then
					for k, v in pairs(result) do
						local sms = fromJSON(v.data2)
						exports.cosmo_chat:sendLocalMeAction(player, "küldött egy üzenetet.")
					
						sms = addSMS(sms, text, myNumber, number)
						dbExec(connection, "UPDATE items SET data2 = ? WHERE data1 = ?", toJSON(sms), number)
					end
				end
			end, {player}, connection, "SELECT * FROM items WHERE data1 = ?", number
		)
	end
end
addEvent("sendMessages", true)
addEventHandler("sendMessages", getRootElement(), sendMessages)

function pastelcolor(str)
	local baseRed, baseGreen, baseBlue = 128, 128, 128
	local seed = 0

	for character in utf8.gmatch(str, ".") do
		seed = seed + utf8.byte(character)
	end
	
	local rand1 = math.abs(math.sin(seed) * 10000) % 256

	seed = seed + seed

	local rand2 = math.abs(math.sin(seed) * 10000) % 256

	seed = seed + seed

	local rand3 = math.abs(math.sin(seed) * 10000) % 256

	return math.ceil(rand1 + baseRed) / 2, math.ceil(rand2 + baseGreen) / 2, math.ceil(rand3 + baseBlue) / 2
end

function callMember(number)
	for i, v in ipairs(getElementsByType("player")) do
		if v and exports.cosmo_inventory:hasItemWithData(v, 71, "data1", number) then
			if getElementData(v, "isCall") then
				return "inCall"
			else
				return v
			end
		end
	end
end

function callMembersms(number)
	for i, v in ipairs(getElementsByType("player")) do
		if v and exports.cosmo_inventory:hasItemWithData(v, 71, "data1", number) then
			return v
		end
	end
end

function tableCopy(t)
	if type(t) == "table" then
		local r = {}
		for k, v in pairs(t) do
			r[k] = tableCopy(v);
		end
		return r;
	else
		return t;
	end
end

function addSMS2(t,text,sourceNumber,number)
    local temp = {};
    local found = false;
    if t and #t > 0 then 
        for k, v in pairs(t) do 
            if tonumber(v[1]) == tonumber(sourceNumber) then 
                --table.insert(t[k][2],{text,sourceNumber});
                t[k][#t[k] + 1] = {text,sourceNumber};
                found = true;
                break;
            end
        end
    else 
        t = {};
    end
    if not found then 
        table.insert(t,{tostring(sourceNumber),{text,number}});
    end
    temp = tableCopy(t);
	
    local owner = false;
    for k,v in pairs(getElementsByType("player")) do 
        if getElementData(v,"loggedIn") then 
            if exports.cosmo_inventory:hasItemWithData(v, 71, "data1", number) then 
                owner = v;
                break;
            end
        end
    end

    if owner then --Ha online a playerxxxxxxxxx
        triggerClientEvent(owner,"loadSMSFromServer",owner,temp);
    end
	
    return temp;
end


function addSMS(t,text,sourceNumber,number)
    local temp = {};
    local found = false;
    if t and #t > 0 then 
        for k, v in pairs(t) do 
            if tonumber(v[1]) == tonumber(sourceNumber) then 
                --table.insert(t[k][2],{text,sourceNumber});
                t[k][#t[k] + 1] = {text,sourceNumber};
                found = true;
                break;
            end
        end
    else 
        t = {};
    end
    if not found then 
        table.insert(t,{tostring(sourceNumber),{text,sourceNumber}});
    end
    temp = tableCopy(t);

    local owner = false;
    for k,v in pairs(getElementsByType("player")) do 
        if getElementData(v,"loggedIn") then 
            if exports.cosmo_inventory:hasItemWithData(v, 71, "data1", number) then 
                owner = v;
                break;
            end
        end
    end

    if owner then --Ha online a playerxxxxxxxxx
		exports.cosmo_chat:sendLocalDoAction(owner, "Kapott egy SMS-t.")
        triggerClientEvent(owner,"loadSMSFromServer",owner,temp);
		triggerClientEvent(root, "playPhoneSound", root, owner, "sms")
    end

    return temp;
end
