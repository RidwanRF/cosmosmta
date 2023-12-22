local mysql = exports.sarp_database
local connection = exports.sarp_database:getConnection()
local enterprises = {}

addEventHandler("onResourceStart", resourceRoot, function()
    dbQuery(function(query)
        local query, query_lines = dbPoll(query, 0)
        if query_lines > 0 then
            for i, k in pairs(query) do
                local co = coroutine.create(loadOneEnterprise)
                coroutine.resume(co, k["id"])
            end
        end
        outputDebugString(query_lines.."db vállakozás betöltve")
    end, connection, "SELECT id FROM enterprise")
end)

local categorys = {
    [1] = "Bolt",
    [2] = "Kocsma",
    [3] = "Étterem",
    [4] = "Club",
}


function loadOneEnterprise(id)
    dbQuery(function(query, id)
        local query, query_lines = dbPoll(query, 0)
        if query_lines > 0 then
            for i, k in pairs(query) do
                local id = k["id"]

                enterprises[id] = {}
                enterprises[id]["name"] = k["name"]
                enterprises[id]["id"] = k["id"]
                enterprises[id]["income"] = k["income"]
                enterprises[id]["outcome"] = k["outcome"]
                enterprises[id]["balance"] = k["money"]
                enterprises[id]["created"] = k["created"]
                enterprises[id]["type"] = k["type"]
                enterprises[id]["license"] = k["license"]
                enterprises[id]["slicense"] = k["stampLicense"]
                enterprises[id]["last_modified"] = k["last_modified"]
                enterprises[id]["rank_names"] = {}
                enterprises[id]["rank_pays"] = {}
                enterprises[id]["rank_changes"] = {}
                    
                enterprises[id]["members"] = {}
                    
                local co = coroutine.create(loadOneEnterpriseMembers)
                coroutine.resume(co, id)
                --print("LOADONEENTERPIRSE .. " .. id .. " CUCC")
                    
                for j=1, 10 do
                    enterprises[id]["rank_names"][j] = k["rank"..j.."_name"]
                    enterprises[id]["rank_pays"][j] = k["rank"..j.."_money"]
                    enterprises[id]["rank_changes"][j] = k["rank"..j.."_change"]
                end
            end
        end --UNIX_TIMESTAMP
    end, connection, "SELECT * FROM enterprise WHERE id = ?", id)
end

function createEnterprise(player, cmd, type, ...)
    if getElementData(player, "acc.adminLevel") >= 9 then
        if not ... then
            outputChatBox("Használat: /"..cmd.." [típus(szerelő, bolt, casino, autókereskedés, étterem, club)] [név]", player, 255, 255, 255)
        else
            local name = table.concat({...}, " ")
            local type = tonumber(type)
            if string.len(name) > 25 then
                outputChatBox("Túl hosszú név", player, 255, 255, 255)
            else
                if type > 0 and type < 7 then
                    dbQuery(function(query)
                        local query, query_lines, lastID = dbPoll(query, 0)
                        if query then
                            loadOneEnterprise(lastID)
                            outputChatBox("Sikeresen létrehoztad a vállalkozást! (ID: "..lastID..")", player, 255, 255, 255)
							setElementData(player, "log:business:6", {admin=getElementData(player, "char.Name"), tipus=type, nev=name})
                        end
                    end, {}, connection, "INSERT INTO enterprise SET name = ?, type = ?", name, type)
                end
            end
        end
    end
end
addCommandHandler("createenterprise", createEnterprise)

function getEnterprises()
    return enterprises
end

function showenterprises(player, cmd)
    if getElementData(player, "acc.adminLevel") >= 9 then
    --if getElementData(player, "acc.adminLevel") >= 9 then
        outputChatBox("Lekérés folyamatban...", player, 255, 255,255)
        local count = 0
        for i, k in pairs(enterprises) do
            outputChatBox(k["name"].." ID: "..k["id"], player, 255, 255,255)
            count = count + 1
        end
        outputChatBox("Lekérés befejeződött...("..count.."db vállalkozás)", player, 255, 255,255)
    end
end
addCommandHandler("showenterprises", showenterprises)

addEvent("ent->givemoney", true)
addEventHandler("ent->givemoney", getRootElement(), function(money)
    if client then
        --giveMoney(player, amount, saveLog)
        exports.sarp_core:giveMoney(client, money)
    end
end)

function addPlayerToEnterprise(player, cmd, newPlayer, ent)
    if getElementData(player, "acc.adminLevel") >= 9 then
        if not newPlayer then
            outputChatBox("Használat: /"..cmd.." [név] [vállalkozás id]", player, 255, 255, 255)
        else
            local targetPlayer, targetPlayerName = exports.sarp_core:findPlayer(localPlayer, newPlayer, nil, 2)
            if targetPlayer then
                local ent = tonumber(ent)
                --outputConsole(inspect(enterprises))
                if enterprises[ent] then
                    for i, k in pairs(enterprises[ent]["members"]) do
                        if k["account"] == getElementData(targetPlayer, "char.ID") then
                            outputChatBox("Ő már a tagja!", player, 255, 255, 255)
                            return
                        end
                    end
                    dbQuery(function(query)
                        local query, query_lines, lastID = dbPoll(query, 0)
                        if query then
                            if isElement(targetPlayer) then
                                --triggerClientEvent(targetPlayer, "showInfoBox", targetPlayer, "Felvettek téged egy vállalkozásba! Megtekintéshez shift+F5")   
                                exports.sarp_hud:showAlert(targetPlayer, "success", "Felvettek téged egy vállalkozásba!")   
                            end
                            outputChatBox("Hozzáadtad "..targetPlayerName.."-t a vállalkozáshoz", player, 255, 255, 255)
                            loadOneEnterpriseMembers(ent)
							setElementData(player, "log:business:7", {admin=getElementData(player, "char.Name"), jatekos=getElementData(targetPlayer, "char.Name"), vallalkozas=ent})
                        end
                    end, {}, connection, "INSERT INTO ent_attach SET account = ?, entID = ?", getElementData(targetPlayer, "char.ID"), ent)
                else
                    outputChatBox("Nincs ilyen vállalkozás!", player, 255, 255, 255)
                end
            else
                outputChatBox("Nincs ilyen játékos!", player, 255, 255, 255)
            end
        end
    end
end
addCommandHandler("playertoenterprise", addPlayerToEnterprise)

function addPlayerToEnterpriseLeader(player, cmd, newPlayer, ent, leader)
    if getElementData(player, "acc.adminLevel") >= 9 then
        if not newPlayer then
            outputChatBox("Használat: /"..cmd.." [név] [vállalkozás id] [leader 1=igen, 0=nem]", player, 255, 255, 255)
        else
            local targetPlayer, targetPlayerName = exports.sarp_core:findPlayer(localPlayer, newPlayer, nil, 2)
            if targetPlayer then
                local ent = tonumber(ent)
                local leader = tonumber(leader)
                if leader == 0 or leader == 1 then
                    
                    if enterprises[ent] then
                        for i, k in pairs(enterprises[ent]["members"]) do
                            if k["account"] == getElementData(targetPlayer, "char.ID") then
                                dbExec(connection, "UPDATE ent_attach SET leader = ? WHERE entID = ? and account = ?", leader, ent, getElementData(targetPlayer, "char.ID"))
                                if leader == 0 then
                                    outputChatBox("Módosítottad "..targetPlayerName.." leader rangját", player, 255, 255, 255)
									setElementData(player, "log:business:8", {admin=getElementData(player, "char.Name"), jatekos=getElementData(targetPlayer, "char.Name"), vallalkozas=ent})
                                    
                                    --triggerClientEvent(targetPlayer, "showInfoBox", targetPlayer, "Elvették a leader rangod egy vállalkozásban! Megtekintéshez shift+F5") 
                                    exports.sarp_hud:showAlert(targetPlayer, "warning", "Elvették a leader rangod egy vállalkozásban! Megtekintéshez shift+F5")
                                    --triggerClientEvent(targetPlayer, "showInfoBox", targetPlayer, "Elvették a leader rangod egy vállalkozásban! Megtekintéshez shift+F5") 
                                else
                                    outputChatBox("Módosítottad "..targetPlayerName.." leader rangját", player, 255, 255, 255)
									setElementData(player, "log:business:9", {admin=getElementData(player, "char.Name"), jatekos=getElementData(targetPlayer, "char.Name"), vallalkozas=ent})
                                    
                                    exports.sarp_hud:showAlert(targetPlayer, "warning", "Kineveztek leaderré egy vállalkozásban! Megtekintéshez shift+F5")
                                    --triggerClientEvent(targetPlayer, "showInfoBox", targetPlayer, "Kineveztek leaderré egy vállalkozásban! Megtekintéshez shift+F5")
                                end
                                loadOneEnterpriseMembers(ent)
                                return
                            end
                        end
                        dbQuery(function(query)
                            local query, query_lines, lastID = dbPoll(query, 0)
                            if query then
                                if isElement(targetPlayer) then
                                    exports.sarp_hud:showAlert(targetPlayer, "warning", "Felvettek téged egy vállalkozásba és leaderré neveztek!")
                                    --triggerClientEvent(targetPlayer, "showInfoBox", targetPlayer, "Felvettek téged egy vállalkozásba és leaderré neveztek! Megtekintéshez shift+F5")      
                                end
                                outputChatBox("Hozzáadtad és leaderré nevezted "..targetPlayerName.."-t a vállalkozáshoz", player, 255, 255, 255)
                                loadOneEnterpriseMembers(ent)
                            end
                        end, {}, connection, "INSERT INTO ent_attach SET account = ?, entID = ?, leader = ?", getElementData(targetPlayer, "char.ID"), ent, leader)
                    else
                        outputChatBox("Nincs ilyen vállalkozás!", player, 255, 255, 255)
                    end
                else
                    outputChatBox("[leader 1=igen, 0=nem]", player, 255, 255, 255)
                end
            else
                outputChatBox("Nincs ilyen játékos!", player, 255, 255, 255)
            end
        end
    end
end
addCommandHandler("playertoenterpriseleader", addPlayerToEnterpriseLeader)

function enterpriseplayerremove(player, cmd, newPlayer, ent)
    if getElementData(player, "acc.adminLevel") >= 9 then
        if not newPlayer then
            outputChatBox("Használat: /"..cmd.." [név] [vállalkozás id]", player, 255, 255, 255)
        else
            local targetPlayer, targetPlayerName = exports.sarp_core:findPlayer(localPlayer, newPlayer, nil, 2)
            if targetPlayer then
                local ent = tonumber(ent)
                if enterprises[ent] then
                    for i, k in pairs(enterprises[ent]["members"]) do
                        if k["account"] == getElementData(targetPlayer, "char.ID") then
                            dbExec(connection, "DELETE FROM ent_attach WHERE entID = ? AND account = ?", ent, getElementData(targetPlayer, "char.ID"))
                            outputChatBox("Kirúgtad "..targetPlayerName.."-t egy vállalkozásból", player, 255, 255, 255)
                            --triggerClientEvent(targetPlayer, "showInfoBox", targetPlayer, "Kirúgtak egy vállalkozásból")
                            exports.sarp_hud:showAlert(targetPlayer, "error", "Kirúgtak egy vállalkozásból")
							setElementData(player, "log:business:10", {admin=getElementData(player, "char.Name"), jatekos=getElementData(targetPlayer, "char.Name"), vallalkozas=ent})
                            table.remove(enterprises[ent]["members"], i)
                            loadOneEnterpriseMembers(ent)
                            return
                        end
                    end
                    outputChatBox("Ő nem a tagja a vállalkozásnak!", player, 255, 255, 255)   
                else
                    outputChatBox("Nincs ilyen vállalkozás!", player, 255, 255, 255)
                end
            else
                outputChatBox("Nincs ilyen játékos!", player, 255, 255, 255)
            end
        end
    end
end
addCommandHandler("enterpriseplayerremove", enterpriseplayerremove)

function loadOneEnterpriseMembers(id, update)
    dbQuery(function(query)
        local query, query_lines = dbPoll(query, 0)
        if query_lines > 0 then
            for i, k in pairs(query) do
                enterprises[id]["members"][i] = k
            end
            if update then
                local vehicles = exports.ex_vehicle_ent:getCarshopVehicles()
                --print(vehicles .. " KAKIGECIGALO")
                triggerClientEvent(client2, "client->getEnterprises", client2, enterprises, false, true, vehicles)    
            end
        end
    end, connection, "SELECT ent_attach.id as id, ent_attach.added as added, ent_attach.account as account, ent_attach.leader as leader, ent_attach.permissions as permissions, ent_attach.rank as rank, characters.lastOnline as lastlogin, characters.name as charactername FROM ent_attach LEFT JOIN characters ON ent_attach.account=characters.charID WHERE entID = ?", id)
end

addEvent("server->inviteToEnterprise", true)
addEventHandler("server->inviteToEnterprise", getRootElement(), function(player, ent)
    if client then
        if enterprises[ent] then
            client2 = client
            dbQuery(function(query)
                local query, query_lines, lastID = dbPoll(query, 0)
                if query then
                    if isElement(player) then
                        --triggerClientEvent(player, "showInfoBox", player, "Felvettek téged egy vállalkozásba! Megtekintéshez shift+F5")      
                        exports.sarp_hud:showAlert(player, "success", "Felvettek téged egy vállalkozásba!")
                    end
                    loadOneEnterpriseMembers(ent, true)
                end
            end, {}, connection, "INSERT INTO ent_attach SET account = ?, entID = ?", getElementData(player, "char.ID"), ent)
        end
    end
end)

addEvent("server->savePermissions", true)
addEventHandler("server->savePermissions", getRootElement(), function(cache, ent, player)
    if client then
        if enterprises[ent]["members"][player] then
            print(toJSON(cache).." | "..enterprises[ent]["members"][player]["account"].." | "..ent)
            dbExec(connection, "UPDATE ent_attach SET permissions = ? WHERE account = ? AND entID = ?", toJSON(cache), enterprises[ent]["members"][player]["account"], ent)
            enterprises[ent]["members"][player]["permissions"] = toJSON(cache) 
            triggerClientEvent(root, "client->getEntDatas", root, enterprises) --Mark: WTF öld meg szegény klienst, köszi!
        end
    end
end)

function update()
    local vehicles = exports.ex_vehicle_ent:getCarshopVehicles()
    triggerClientEvent(client, "client->getEnterprises", client, enterprises, true, false, vehicles)
    triggerClientEvent(root, "client->getEntDatas", root, enterprises) --Mark: Hajrá... itt már 10mb/s
    triggerClientEvent(client, "carshop:reloadMarkers", client)
end

function loadOneEnterpriseStorage(id)
    dbQuery(function(query)
        local query, query_lines = dbPoll(query, 0)
        if query_lines > 0 then
            for i, k in pairs(query) do
                if not enterprises[id]["storage"][k["slot"]] then
                    enterprises[id]["storage"][k["slot"]] = {k["id"], k["item"], k["category"], k["db"], k["slot"]}
                end
            end
        end
    end, connection, "SELECT * FROM ent_storage WHERE entID = ?", id)
end

addEvent("server->getEnterprises", true)
addEventHandler("server->getEnterprises", getRootElement(), function()
    if client then
        update()
    end
end)

addEvent("server->removeMoney", true)
addEventHandler("server->removeMoney", getRootElement(), function(ent, money, update, money2)
    if client then
		if not enterprises[ent] then return end
		if not enterprises[ent]["balance"] then
			enterprises[ent]["balance"] = 0
		end
        outputDebugString("Pénzváltozás vállalkozás számlán(kiadás): entID: "..ent.." pénz: "..money.." régipénz: "..enterprises[ent]["balance"])
        enterprises[ent]["balance"] = money
        local newMoney = enterprises[ent]["outcome"] + money2
        enterprises[ent]["outcome"] = newMoney
        dbExec(connection, "UPDATE enterprise SET money = ?, outcome = ? WHERE id = ?", money, newMoney, ent)
        triggerClientEvent(root, "client->getEntDatas", root, enterprises)    
        triggerClientEvent(client, "carshop:reloadMarkers", client)
        if update then
            local vehicles = exports.ex_vehicle_ent:getCarshopVehicles()
            triggerClientEvent(client, "client->getEnterprises", client, enterprises, false, true, vehicles)
        end
    end
end)

addEvent("server->addMoney", true)
addEventHandler("server->addMoney", getRootElement(), function(ent, money, update, money2)
    if client then
        outputDebugString("Pénzváltozás vállalkozás számlán(berakás): entID: "..ent.." pénz: "..money.." régipénz: "..enterprises[ent]["balance"])
        enterprises[ent]["balance"] = money
        local newMoney = enterprises[ent]["income"] + money2
        enterprises[ent]["income"] = newMoney
        dbExec(connection, "UPDATE enterprise SET money = ?, income = ? WHERE id = ?", money, newMoney, ent)
        triggerClientEvent(root, "client->getEntDatas", root, enterprises)    
        triggerClientEvent(client, "carshop:reloadMarkers", client)
        if update then
            local vehicles = exports.ex_vehicle_ent:getCarshopVehicles()
            triggerClientEvent(client, "client->getEnterprises", client, enterprises, false, true, vehicles)
        end
    end
end)

addEvent("server->getEntDatas", true)
addEventHandler("server->getEntDatas", getRootElement(), function()
    if client then
        triggerClientEvent(root, "client->getEntDatas", root, enterprises) --Mark: Azt a kva
        triggerClientEvent(client, "carshop:reloadMarkers", client)
    end
end)

addEvent("server->changePlayerName", true)
addEventHandler("server->changePlayerName", getRootElement(), function(id, line, name)
    if client then
        if enterprises[id]["members"][line] then
            enterprises[id]["members"][line]["charactername"] = name
        end
        triggerClientEvent(root, "client->getEntDatas", root, enterprises)
    end
end)

addEvent("server->leaderChange", true)
addEventHandler("server->leaderChange", getRootElement(), function(id, line, status)
    if client then
        if enterprises[id]["members"][line] then
            local player = getPlayerFromName(enterprises[id]["members"][line]["charactername"])
               
            enterprises[id]["members"][line]["leader"] = status
            if isElement(player) then
                if status == 1 then
                    triggerClientEvent(player, "showInfoBox", player, "Kineveztek leaderré! ("..enterprises[id]["name"]..")")
                else
                    triggerClientEvent(player, "showInfoBox", player, "Elvették a leader jogodat! ("..enterprises[id]["name"]..")")
                end
                local vehicles = exports.ex_vehicle_ent:getCarshopVehicles()
                triggerClientEvent(player, "client->getEnterprises", player, enterprises, false, true, vehicles)
            end
            triggerClientEvent(root, "client->getEntDatas", root, enterprises)
            dbExec(connection, "UPDATE ent_attach SET leader = ? WHERE account = ? AND entID = ?", status, enterprises[id]["members"][line]["account"], id)
        end
    end
end)

addEvent("server->rankChange", true)
addEventHandler("server->rankChange", getRootElement(), function(id, line, rank)
    if client then
        if enterprises[id]["members"][line] then
            local oldRank = enterprises[id]["members"][line]["rank"]
            local player = getPlayerFromName(enterprises[id]["members"][line]["charactername"])
                
            enterprises[id]["members"][line]["rank"] = rank
            if isElement(player) then
                triggerClientEvent(player, "showInfoBox", player, "Megváltoztatták a rangodat!("..enterprises[id]["name"]..": "..oldRank.." -> "..rank..")")
                local vehicles = exports.ex_vehicle_ent:getCarshopVehicles()
                triggerClientEvent(player, "client->getEnterprises", player, enterprises, false, true, vehicles)
            end
            triggerClientEvent(root, "client->getEntDatas", root, enterprises)
            dbExec(connection, "UPDATE ent_attach SET rank = ? WHERE account = ? AND entID = ?", rank, enterprises[id]["members"][line]["account"], id)
        end
    end
end)

addEvent("server->changeRankName", true)
addEventHandler("server->changeRankName", getRootElement(), function(id, line, rankname)
    if client then
        if enterprises[id]["rank_names"][line] then
            local oldRankName = enterprises[id]["rank_names"][line]
            
            local time = getRealTime()
            local hour = time.hour
            local minute = time.minute
            local day = time.monthday
            local month = time.month + 1
            local year = time.year + 1900
            local second = time.second

            if hour < 10 then
                hour = "0"..hour
            end

            if minute < 10 then
                minute = "0"..minute
            end

            if month < 10 then
                month = "0"..month
            end  

            if day < 10 then
                day = "0"..day
            end
                
            if second < 10 then
                second = "0"..second
            end
                
            enterprises[id]["rank_names"][line] = rankname
            enterprises[id]["rank_changes"][line] = year.."-"..month.."-"..day.." "..hour..":"..minute..":"..second
            
            local vehicles = exports.ex_vehicle_ent:getCarshopVehicles()
            triggerClientEvent(client, "client->getEnterprises", client, enterprises, false, true, vehicles)
            triggerClientEvent(root, "client->getEntDatas", root, enterprises) --Mark: Már megint
            dbExec(connection, "UPDATE enterprise SET rank"..line.."_name = ?, rank"..line.."_change = ? WHERE id = ?", rankname, year.."-"..month.."-"..day.." "..hour..":"..minute..":"..second, id)
        end
    end
end)

addEvent("server->changeRankMoney", true)
addEventHandler("server->changeRankMoney", getRootElement(), function(id, line, money)
    if client then
        if enterprises[id]["rank_pays"][line] then
            local oldRankPay = enterprises[id]["rank_pays"][line]
            
            local time = getRealTime()
            local hour = time.hour
            local minute = time.minute
            local day = time.monthday
            local month = time.month + 1
            local year = time.year + 1900
            local second = time.second

            if hour < 10 then
                hour = "0"..hour
            end

            if minute < 10 then
                minute = "0"..minute
            end

            if month < 10 then
                month = "0"..month
            end  

            if day < 10 then
                day = "0"..day
            end
                
            if second < 10 then
                second = "0"..second
            end
            
            enterprises[id]["rank_pays"][line] = money
            enterprises[id]["rank_changes"][line] = year.."-"..month.."-"..day.." "..hour..":"..minute..":"..second
            
            local vehicles = exports.ex_vehicle_ent:getCarshopVehicles()
            triggerClientEvent(client, "client->getEnterprises", client, enterprises, false, true, vehicles)
            triggerClientEvent(root, "client->getEntDatas", root, enterprises)
            dbExec(connection, "UPDATE enterprise SET rank"..line.."_money = ?, rank"..line.."_change = ? WHERE id = ?", money, year.."-"..month.."-"..day.." "..hour..":"..minute..":"..second, id)
        end
    end
end)

addEvent("server->kickPlayer", true)
addEventHandler("server->kickPlayer", getRootElement(), function(id, line, rank)
    if client then
        if enterprises[id]["members"][line] then
            local player = getPlayerFromName(enterprises[id]["members"][line]["charactername"])
            local dbid = enterprises[id]["members"][line]["account"]
                
            dbExec(connection, "DELETE FROM ent_attach WHERE entID = ? AND account = ?", id, dbid)
            table.remove(enterprises[id]["members"], line)
                
            if isElement(player) then
                triggerClientEvent(player, "showInfoBox", player, "Kirúgtak egy vállalkozásból! ("..enterprises[id]["name"]..")") 
                local vehicles = exports.ex_vehicle_ent:getCarshopVehicles()
                triggerClientEvent(player, "client->getEnterprises", player, enterprises, false, true, vehicles)
                triggerClientEvent(root, "client->getEntDatas", root, enterprises)
            end
        end
    end
end)

addEvent("server->updateLastLogin", true)
addEventHandler("server->updateLastLogin", getRootElement(), function(id, line)
    if client then
        if enterprises[id]["members"][line] then
            local time = getRealTime()
            local hour = time.hour
            local minute = time.minute
            local day = time.monthday
            local month = time.month + 1
            local year = time.year + 1900
            local second = time.second

            if hour < 10 then
                hour = "0"..hour
            end

            if minute < 10 then
                minute = "0"..minute
            end

            if month < 10 then
                month = "0"..month
            end  

            if day < 10 then
                day = "0"..day
            end
                
            if second < 10 then
                second = "0"..second
            end
                
            enterprises[id]["members"][line]["lastlogin"] = year.."-"..month.."-"..day.." "..hour..":"..minute..":"..second
            triggerClientEvent(root, "client->getEntDatas", root, enterprises)
            return
        end
    end
end)

addEvent("server->giveKey", true)
addEventHandler("server->giveKey", getRootElement(), function(dbid)
    if client then
        --local state, msg = exports.ex_inventory:giveItem(client, 29, dbid)
        local state = exports.sarp_inventory:giveItem(client, 2, 1, dbid)
        --if state then
        --    outputChatBox("Adtál magadnak egy jármű kulcsot.", client, 255, 255, 255)
        --else
        --    outputChatBox("[GoodMTA] #FFFFFFINVENTORY ÜZENETE", client, 255, 0, 0, true)
        --end
    end
end)