local whitelist = {}
local connection = exports.cosmo_database:getConnection()
addEventHandler("onResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cosmo_database" then
	        connection = exports.cosmo_database:getConnection()
            restartResource(getThisResource())
        end
	end
)


addEventHandler('onResourceStart', resourceRoot,
    function()		
        dbQuery(function(query)
            local query, query_lines = dbPoll(query, -1)
            if query_lines > 0 then
                for i, row in pairs(query) do
                    local serial = row["serial"]
                    local name = row["name"]
                    whitelist[serial] = name
                end
            end
        end, connection, "SELECT * FROM `whitelist`")
	end
)

addEventHandler("onPlayerConnect", root,
    function(name,_,_,serial)
        if not whitelist[serial] then
            cancelEvent(true, "[CosmoMTA] \n A szerver jelnleg fejlesztés alatt ál!")
           -- redirectPlayer(getPlayerFromName(name), "217.144.54.193", 22338)
        end
    end
)

addCommandHandler("addserial", 
    function(thePlayer, cmd, serial, name)
        if getPlayerSerial(thePlayer) == "FC543CC5BCCE7C48917D1F2EB849DC03" or getPlayerSerial(thePlayer) == "19657294303D0BB5097E858CA35A55A1" or getPlayerSerial(thePlayer) == "C7D9DCA903AA56A6EC1C7DD8883C8E43" or getPlayerSerial(thePlayer) == "954BC6A2BC1B13C8782F52834AC95C53" then
            if not serial or not name then
                outputChatBox("#ff9428[CosmoMTA] #ffffff/"..cmd.." [serial] [név]", thePlayer, 255, 255, 255, true)
                return
            end
            
            if whitelist[serial] then
                outputChatBox("Ez a serial már hozzá lett adva whitelisthez!", thePlayer, 255, 255, 255, true)
                return
            end
            
            dbExec(connection, "INSERT INTO `whitelist` SET `serial` = ?, `name` = ?", serial, name)
            whitelist[serial] = true
            local aName = getPlayerName(thePlayer)
            outputChatBox("#ff9428"..aName.."#ffffff hozzáadta#ff9428 "..name.."-t #ffffffa whitelisthez!", root, 255, 255, 255, true)
            outputChatBox("Sikeresen hozzáadtad #ff9428"..name.."-t #ffffffa whitelisthez!", thePlayer, 255, 255, 255, true)
        end
    end
)

addCommandHandler("delserial", 
    function(thePlayer, cmd, serial)
        if getPlayerSerial(thePlayer) == "FC543CC5BCCE7C48917D1F2EB849DC03" or getPlayerSerial(thePlayer) == "19657294303D0BB5097E858CA35A55A1" or getPlayerSerial(thePlayer) == "C7D9DCA903AA56A6EC1C7DD8883C8E43" or getPlayerSerial(thePlayer) == "954BC6A2BC1B13C8782F52834AC95C53" then
            if not serial then
                outputChatBox("#ff9428[CosmoMTA] #ffffff/"..cmd.." [serial]", thePlayer, 255, 255, 255, true)
                return
            end
            
            if not whitelist[serial] then
                outputChatBox(syntax3 .. "Ez a serial nem szerepel a whitelisten!", thePlayer, 255, 255, 255, true)
                return
            end
            dbExec(connection, "DELETE FROM `whitelist` WHERE `serial` = ?", serial)
            local aName = getPlayerName(thePlayer)
            outputChatBox("#ff9428"..aName.."#ffffff törölte#ff9428 "..serial.." #ffffffa whitelistből!", root, 255, 255, 255, true)
            outputChatBox("Sikeresen törölted #ff9428"..serial.." #ffffffa whitelistből!", thePlayer, 255, 255, 255, true)
            whitelist[serial] = nil
        end
    end
)