local connection = exports.cosmo_database:getConnection()

local blockedSerials = {}

addEventHandler('onResourceStart', resourceRoot,
    function()		
        dbQuery(function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                for i, row in pairs(query) do
                    local serial = row["serial"]
                    blockedSerials[serial] = true
                end
            end
			outputDebugString("[Success] Loading blockedserials has finished successfuly. Loaded: " .. query_lines .. " serials!")
        end, connection, "SELECT * FROM `blockedserials`")
	end
)

addEventHandler("onPlayerConnect", root,
    function(_,_,_,serial)
        if blockedSerials[serial] then
            cancelEvent(true, "Rendszer\nA te serialod blockolva van ezen a szerveren!")
        end
    end
)

local syntax = "#ff9428[CosmoMTA] #ffffff"
local syntax2 = "#ff9428[CosmoMTA - Használat] #ffffff"

addCommandHandler("createblockedserial", 
    function(thePlayer, cmd, serial)
        if getElementData(thePlayer, "acc.adminLevel") >= 11 then
            if not serial then
                outputChatBox(syntax2 .. "/"..cmd.." [serial]", thePlayer, 255, 255, 255, true)
                return
            end
            
            dbExec(connection, "INSERT INTO `blockedserials` SET `serial` = ?", serial)
            blockedSerials[serial] = true
            outputChatBox(syntax .. "Sikeresen hozzáadtad a "..serial.."-t a blockedserialokhoz!", thePlayer, 255, 255, 255, true)
        end
    end
)

addCommandHandler("removeblockedserial", 
    function(thePlayer, cmd, serial)
        if getElementData(thePlayer, "acc.adminLevel") >= 11 then
            if not serial then
                outputChatBox(syntax2 .. "/"..cmd.." [serial]", thePlayer, 255, 255, 255, true)
                return
            end
            
            if not blockedSerials[serial] then
                outputChatBox(syntax .. "A törlendő serialnak blockedserialnak kell lennie!", thePlayer, 255, 255, 255, true)
                return
            end
            dbExec(connection, "DELETE FROM `blockedserials` WHERE `serial` = ?", serial)
            blockedSerials[serial] = false
            outputChatBox(syntax .. "Sikeresen kitörölted a "..serial.."-t a blockedserialokból!", thePlayer, 255, 255, 255, true)
        end
    end
)