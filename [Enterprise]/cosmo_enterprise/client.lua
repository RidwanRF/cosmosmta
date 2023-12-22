all_enterprise = {}
local enterprises = {}
local members = {}
local carshopVehicles = {}
local storage = {}
local success = false

local selectedEnt = 1
local selectedPage = 1
local lineVehicle = 1
local linePlayer = 1
local lineRanks = 1
local lineCarshopVehicle = 1
local lineStorage = 1

local selectedVehicle = 0
local selectedMember = 1
local selectedRank = 0

local name = ""
local triggered = false

local vehicles = {}
local keys = {}

local element = nil
local timer

addEventHandler("onClientResourceStart", resourceRoot, function()
    triggerServerEvent("server->getEntDatas", localPlayer)
end)

local stats = {
    ["Engine"] = {
        [0] = "leállitva",
        [1] = "elinditva",
    },
    ["Light"] = {
        [0] = "lekapcsolva",
        [1] = "felkapcsolva",
    },
    ["Leader"] = {
        [0] = "Leader adás",
        [1] = "Leader elvétel",
    }
}


local upgrades = {
	[0] = "gyári",
	[1] = "alap",
	[2] = "profi",
	[3] = "verseny",
}

addEventHandler("onClientPlayerSpawn", localPlayer, function()
    triggerServerEvent("server->getEntDatas", localPlayer)
end)

addEvent("client->getEntDatas", true)
addEventHandler("client->getEntDatas", getRootElement(), function(temp)
    all_enterprise = temp
end)

local isLeader = false

local tick = 0
local screenW, screenH = guiGetScreenSize()
local width, height = 1315*0.8, 723*0.8
local pos = {screenW/2 - width/2, screenH/2 - height/2}

local font = dxCreateFont("files/Roboto.ttf", 10)
local font2 = dxCreateFont("files/Roboto.ttf", 9)
local font3 = dxCreateFont("files/Roboto.ttf", 8)
local font4 = dxCreateFont("files/Roboto.ttf", 7)
local font_bold = dxCreateFont("files/Roboto-Bold.ttf", 10)
local font_bold2 = dxCreateFont("files/Roboto-Bold.ttf", 9)
local names = {"Áttekintés", "Tagok", "Rangok", "Járművek"}
local special_names = {
    [1] = "Raktár",
    [2] = "Raktár",
    [3] = "Raktár",
    [4] = "Kereskedésben lévő járművek",
    [5] = "Raktár",
    [6] = "Raktár",
}

local gui = nil
local editBoxes = {}
editBoxes["playerName"] = ""
editBoxes["rankName"] = ""
editBoxes["rankMoney"] = ""
editBoxes["moneyIN"] = ""
editBoxes["moneyOUT"] = ""

local showPermissionPanel = false
local permission = {}

local permissions = {
    [4] = {
        {"Jármű berakása a kereskedésbe", "Jármű kivétele a kereskedésből", "Jármű árának a szerkesztése", "Jármű kivétele saját nevére"}
    },
    [2] = {
        {"Ár módosítása", "Tárgy berakás"}
    }
}

local ticked = {}

function addEditBox(box)
    if not box then
        if isElement(gui) then
            destroyElement(gui)
        end
        guiSetInputMode("allow_binds")
        return
    end
    if isElement(gui) then
        destroyElement(gui)
    end
    if editBoxes[box] then
        gui = guiCreateEdit(-1,-1, 1, 1, editBoxes[box] or "", false)
        guiSetInputMode("no_binds_when_editing")
		addEventHandler("onClientGUIChanged", gui, function(element)
            if string.len(editBoxes[box]) < 26 then
                editBoxes[box] = guiGetText(element)
            end
		end)
		guiBringToFront(gui)
    end
end

function getOnlinePlayerCache()
	local playerCache = {}
	for k,v in ipairs(Element.getAllByType("player")) do
		if v:getData("loggedIn") then
			local name = tostring(v:getData("char.Name")) or "Ismeretlen"
			playerCache[name] = v
		end
	end
	return playerCache
end

local pcache = getOnlinePlayerCache()

function renderEnterprise()
    if show then
        --exports.ex_blur:createBlur()
        local ent = enterprises[selectedEnt]["id"]
        local type = enterprises[selectedEnt]["type"]
        dxDrawImage(pos[1], pos[2], width, height, "files/img/bg.png")
    
        dxDrawRectangle(pos[1] + width - 100, pos[2] + height, 100, 20, (isInSlot(pos[1] + width - 100, pos[2] + height, 100, 20) and tocolor(0, 0, 0, 150) or tocolor(0, 0, 0, 125)))
        dxDrawText("Bezárás", pos[1] + width - 100, pos[2] + height, pos[1] + width - 100 + 100, pos[2] + height + 20, tocolor(255, 105, 38, 255), 1, font, "center", "center")
        
        if isElement(gui) then
            guiEditSetCaretIndex(gui, guiGetText(gui):len())
        end
        
        for i=1, 6 do
            local poz = {pos[1] + 10, pos[2] + 125 + i*35, 246*0.8, 40*0.8}
            dxDrawImage(poz[1], poz[2], poz[3], poz[4], ((isInSlot(poz[1], poz[2], poz[3], poz[4]) or selectedPage == i) and "files/img/button_c.png" or "files/img/button.png"))
            if names[i] then
                dxDrawText(names[i], pos[1] + 10, pos[2] + 126 + i*35, pos[1] + 10 + 246*0.8, pos[2] + 126 + i*35 + 40*0.8, ((isInSlot(poz[1], poz[2], poz[3], poz[4]) or selectedPage == i) and tocolor(0, 0, 0, 255) or tocolor(255, 255, 255, 255)), 1, font, "center", "center")
            elseif special_names[enterprises[selectedEnt]["type"]] and i == 5 then
                dxDrawText(special_names[enterprises[selectedEnt]["type"]], pos[1] + 10, pos[2] + 126 + i*35, pos[1] + 10 + 246*0.8, pos[2] + 126 + i*35 + 40*0.8, ((isInSlot(poz[1], poz[2], poz[3], poz[4]) or selectedPage == i) and tocolor(0, 0, 0, 255) or tocolor(255, 255, 255, 255)), 1, font, "center", "center")
            elseif i == 6 then
                dxDrawText("Számla", pos[1] + 10, pos[2] + 126 + i*35, pos[1] + 10 + 246*0.8, pos[2] + 126 + i*35 + 40*0.8, ((isInSlot(poz[1], poz[2], poz[3], poz[4]) or selectedPage == i) and tocolor(0, 0, 0, 255) or tocolor(255, 255, 255, 255)), 1, font, "center", "center")
            end
        end
        
        if selectedEnt > 1 then
            dxDrawImage(pos[1] + 5, pos[2] + 425, 7, 18, "files/img/left.png")
        end
        
        if selectedEnt + 1 <= #enterprises then
            dxDrawImage(pos[1] + 208, pos[2] + 425, 7, 18, "files/img/right.png")
        end
        
        dxDrawText(enterprises[selectedEnt]["name"], pos[1] + 15, pos[2] + 425, pos[1] + 15 + 190, pos[2] + 425 + 18, tocolor(255, 255, 255, 255), 1, font2, "center", "center")
        
        dxDrawImage(pos[1] + 12.5, pos[2] + 460, 240*0.8, 133*0.8, "files/img/logo.png")
        dxDrawRectangle(pos[1] + 12.5, pos[2] + 460, 240*0.8, 133*0.8, tocolor(0, 0, 0, 150))
        
        if names[selectedPage] == "Áttekintés" then
            dxDrawImage(pos[1] + 230, pos[2] + 100, 500*0.8, 350*0.8, "files/img/home/car_bg.png")
            dxDrawImage(pos[1] + 235, pos[2] + 105, 24*0.8, 17*0.8, "files/img/icons/car.png")
            dxDrawText("Járművek #FF6926("..#carshopVehicles[ent].."db)", pos[1] + 257.5, pos[2] + 106, pos[1] + 257.5 + 24*0.8, pos[2] + 106 + 17*0.8, tocolor(255, 255, 255, 255), 1, font2, "left", "center", false, false, false, true, false)
            
            if isInSlot(pos[1] + 230, pos[2] + 100, 500*0.8, 350*0.8) then
                element = "scrollVehicles"
            elseif isInSlot(pos[1] + 230 + 515*0.8, pos[2] + 100, 500*0.8, 350*0.8) then
                element = "scrollPlayers"
            else
                element = nil
            end
            
            if #carshopVehicles[ent] > 0 then
                local maxLine = 9
                local y = pos[2] + 125
                local latestLine = lineVehicle + maxLine - 1

                for i=1, #carshopVehicles[ent] do
                    if i >= lineVehicle then 
                        if i <= latestLine then
                            local veh = carshopVehicles[ent][i]
                            dxDrawImage(pos[1] + 230, y, 500*0.8, 30*0.8, "files/img/line.png")
                            
                            dxDrawText(exports.sarp_mods_veh:getVehicleNameFromModel(veh["model"]), pos[1] + 235, y + 1, pos[1] + 235 + 500*0.8, y + 1 + 30*0.8, tocolor(255, 255, 255, 255), 1, font3, "left", "center")
                            dxDrawText("#FF6926"..veh["dbid"], pos[1] + 230, y + 1, pos[1] + 230 + 500*0.8, y + 1 + 30*0.8, tocolor(255, 255, 255, 255), 1, font3, "center", "center", false, false, false, true, false)
                            dxDrawText((math.floor(getElementHealth(veh["element"])/10) > 50 and "#008000"..math.floor(getElementHealth(veh["element"])/10).."" or "#A52A2A"..math.floor(getElementHealth(veh["element"])/10)).."%", pos[1] + 200, y + 1, pos[1] + 200 + 500*0.8, y + 1 + 30*0.8, tocolor(255, 255, 255, 255), 1, font3, "right", "center", false, false, false, true, false)
                            dxDrawImage(pos[1] + 230 + 475*0.8, y +2, 19*0.8, 24*0.8, (isVehicleLocked(veh["element"]) and "files/img/icons/locked.png" or "files/img/icons/unlocked.png"))
                            
                            y = y + 28
                        end
                    end
                end
            else
                dxDrawText("A vállalkozásnak nincsen járműve!", pos[1] + 230, pos[2] + 100, pos[1] + 230 + 500*0.8, pos[2] + 100 + 350*0.8, tocolor(255, 255, 255, 255), 1, font2, "center", "center")
            end
            
            dxDrawImage(pos[1] + 230 + 515*0.8, pos[2] + 100, 500*0.8, 350*0.8, "files/img/home/player_bg.png")
            dxDrawImage(pos[1] + 235 + 515*0.8, pos[2] + 105, 18*0.8, 17*0.8, "files/img/icons/player.png")
            dxDrawText("Játékosok #FF6926("..#members[ent].."db)", pos[1] + 257.5 + 515*0.8, pos[2] + 106, pos[1] + 257.5 + 515*0.8 + 18*0.8, pos[2] + 106 + 17*0.8, tocolor(255, 255, 255, 255), 1, font2, "left", "center", false, false, false, true, false)
            
            if #members[ent] > 0 then
                local maxLine = 9
                local y = pos[2] + 125
                local latestLine = linePlayer + maxLine - 1

                for i=1, #members[ent] do
                    if i >= linePlayer then 
                        if i <= latestLine then
                            dxDrawImage(pos[1] + 230 + 515*0.8, y, 500*0.8, 30*0.8, "files/img/line.png")
                            --outputConsole(inspect(members[ent]))
                            dxDrawText(members[ent][i]["charactername"]:gsub("_", " "), pos[1] + 235 + 515*0.8, y + 1, pos[1] + 235 + 515*0.8 + 500*0.8, y + 1 + 30*0.8, tocolor(255, 255, 255, 255), 1, font3, "left", "center")
                            local rank = members[ent][i]["rank"]
                            dxDrawText("#FF6926"..enterprises[selectedEnt]["rank_names"][rank], pos[1] + 230 + 515*0.8, y + 1, pos[1] + 230 + 515*0.8 + 500*0.8, y + 1 + 30*0.8, tocolor(255, 255, 255, 255), 1, font3, "center", "center", false, false, false, true, false)
                            
                            dxDrawImage(pos[1] + 230 + 515*0.8 + 500*0.8 - 20, y + 8, 12*0.8, 12*0.8, (pcache[members[ent][i]["charactername"]]  and "files/img/icons/online.png" or "files/img/icons/offline.png"))
                            if isInSlot(pos[1] + 230 + 515*0.8 + 500*0.8 - 20, y + 8, 12*0.8, 12*0.8) then
                                tooltip("Felvéve: "..members[ent][i]["added"].."\nUtoljára online: "..members[ent][i]["lastlogin"].."")
                            end
                            
                            y = y + 28
                        end
                    end
                end
            end
            
            dxDrawImage(pos[1] + 230, pos[2] + 390, 1013*0.8, 30*0.8, "files/img/home/incoming.png")
            dxDrawImage(pos[1] + 230, pos[2] + 420, 1013*0.8, 30*0.8, "files/img/home/outcoming.png")
            
            dxDrawText("Bevétel", pos[1] + 235, pos[2] + 391, pos[1] + 235 + 1013*0.8, pos[2] + 391 + 30*0.8, tocolor(0, 0, 0, 255), 1, font_bold, "left", "center")
            --dxDrawText("+ "..formatMoney(enterprises[selectedEnt]["income"]).." $", pos[1] + 225, pos[2] + 391, pos[1] + 225 + 1013*0.8, pos[2] + 391 + 30*0.8, tocolor(0, 0, 0, 255), 1, font_bold, "right", "center")
            dxDrawText("+ "..formatMoney(enterprises[selectedEnt]["income"]).." $", pos[1] + 225, pos[2] + 391, pos[1] + 225 + 1013*0.8, pos[2] + 391 + 30*0.8, tocolor(0, 0, 0, 255), 1, font_bold, "right", "center")
            
            dxDrawText("Kiadás", pos[1] + 235, pos[2] + 421, pos[1] + 235 + 1013*0.8, pos[2] + 421 + 30*0.8, tocolor(0, 0, 0, 255), 1, font_bold, "left", "center")
            --dxDrawText("- "..formatMoney(enterprises[selectedEnt]["outcome"]).." $", pos[1] + 225, pos[2] + 421, pos[1] + 225 + 1013*0.8, pos[2] + 421 + 30*0.8, tocolor(0, 0, 0, 255), 1, font_bold, "right", "center")
            dxDrawText("- "..formatMoney(enterprises[selectedEnt]["outcome"]).." $", pos[1] + 225, pos[2] + 421, pos[1] + 225 + 1013*0.8, pos[2] + 421 + 30*0.8, tocolor(0, 0, 0, 255), 1, font_bold, "right", "center")
            
            dxDrawImage(pos[1] + 230, pos[2] + 455, 1013*0.8, 139*0.8, "files/img/home/info_bg.png")
            --dxDrawText("Vállalkozás neve: "..enterprises[selectedEnt]["name"].."\nLétrehozva: "..enterprises[selectedEnt]["created"].."\nTagok száma: "..#members[ent].."\nJárművek száma: "..#vehicles[ent].."\nÖsszes bevétel: "..formatMoney(enterprises[selectedEnt]["income"]-enterprises[selectedEnt]["outcome"]).." $\nLicensz érvényesség: "..enterprises[selectedEnt]["license"].."", pos[1] + 230, pos[2] + 455, pos[1] + 230 + 1013*0.8, pos[2] + 455 + 139*0.8, tocolor(255, 255, 255, 255), 1, font, "center", "center")
            dxDrawText("Vállalkozás neve: "..enterprises[selectedEnt]["name"].."\nLétrehozva: "..enterprises[selectedEnt]["created"].."\nTagok száma: "..#members[ent].."\nJárművek száma: "..#vehicles[ent].."\nÖsszes bevétel: "..formatMoney(enterprises[selectedEnt]["income"]-enterprises[selectedEnt]["outcome"]).." $\nLicensz érvényesség: "..enterprises[selectedEnt]["license"].."", pos[1] + 230, pos[2] + 455, pos[1] + 230 + 1013*0.8, pos[2] + 455 + 139*0.8, tocolor(255, 255, 255, 255), 1, font, "center", "center")
        elseif names[selectedPage] == "Tagok" then
            dxDrawImage(pos[1] + 230, pos[2] + 100, 709*0.8, 519*0.8, "files/img/players/bg.png")
            dxDrawImage(pos[1] + 235, pos[2] + 105, 18*0.8, 17*0.8, "files/img/icons/player.png")
            dxDrawText("Játékosok #FF6926("..#members[ent].."db)", pos[1] + 257.5, pos[2] + 106, pos[1] + 257.5 + 24*0.8, pos[2] + 106 + 17*0.8, tocolor(255, 255, 255, 255), 1, font2, "left", "center", false, false, false, true, false)
            
            dxDrawImage(pos[1] + 230, pos[2] + 125, 709*0.8, 30*0.8, "files/img/players/line.png")
            
            dxDrawText("Név", pos[1] + 240, pos[2] + 126, pos[1] + 240 + 709*0.8, pos[2] + 126 + 30*0.8, tocolor(255, 105, 38, 255), 1, font3, "left", "center")
            dxDrawText("Rang", pos[1] + 210, pos[2] + 126, pos[1] + 210 + 709*0.8, pos[2] + 126 + 30*0.8, tocolor(255, 105, 38, 255), 1, font3, "center", "center")
            dxDrawText("Fentlét", pos[1] + 360, pos[2] + 126, pos[1] + 360 + 709*0.8, pos[2] + 126 + 30*0.8, tocolor(255, 105, 38, 255), 1, font3, "center", "center")
            dxDrawText("Leader", pos[1] + 220, pos[2] + 126, pos[1] + 220 + 709*0.8, pos[2] + 126 + 30*0.8, tocolor(255, 105, 38, 255), 1, font3, "right", "center")
            
            if isInSlot(pos[1] + 230, pos[2] + 100, 709*0.8, 519*0.8) then
                element = "scrollPlayers"
            else
                element = nil
            end
            
            if #members[ent] > 0 then
                --print(ent .. " si oji")
                local maxLine = 14
                local y = pos[2] + 125 + 28
                local latestLine = linePlayer + maxLine - 1

                for i=1, #members[ent] do
                    if i >= linePlayer then 
                        if i <= latestLine then
                            local poz = {pos[1] + 230, y, 709*0.8, 30*0.8}
                            dxDrawImage(poz[1], poz[2], poz[3], poz[4], ((isInSlot(poz[1], poz[2], poz[3], poz[4]) or selectedMember == i) and "files/img/players/line_c.png" or "files/img/players/line.png"))
                            
                            local rank = members[ent][i]["rank"]
                            local element = pcache[members[ent][i]["charactername"]]
                            
                            dxDrawText(members[ent][i]["charactername"]:gsub("_", " "), pos[1] + 240, y + 1, pos[1] + 240 + 709*0.8, y + 1 + 30*0.8, ((isInSlot(poz[1], poz[2], poz[3], poz[4]) or selectedMember == i) and tocolor(0, 0, 0, 255) or tocolor(255, 255, 255, 255)), 1, font3, "left", "center")
                            dxDrawText(enterprises[selectedEnt]["rank_names"][rank], pos[1] + 210, y + 1, pos[1] + 210 + 709*0.8, y + 1 + 30*0.8, ((isInSlot(poz[1], poz[2], poz[3], poz[4]) or selectedMember == i) and tocolor(0, 0, 0, 255) or tocolor(255, 255, 255, 255)), 1, font3, "center", "center")

                            dxDrawImage(pos[1] + 637.5, y + 8, 12*0.8, 12*0.8, (pcache[members[ent][i]["charactername"]] and "files/img/icons/online.png" or "files/img/icons/offline.png"))
                            
                            if isInSlot(pos[1] + 637.5, y + 8, 12*0.8, 12*0.8) then
                                if isElement(element) then
                                    local zone = "Ismeretlen"
                                    local x,y,z = getElementPosition(element)
                                    zone = getZoneName(x, y, z, true)
                                    tooltip("Felvéve: "..members[ent][i]["added"].."\nUtoljára online: "..members[ent][i]["lastlogin"].."", "Tartozkodás: "..zone.."")
                                else
                                    tooltip("Felvéve: "..members[ent][i]["added"].."\nUtoljára online: "..members[ent][i]["lastlogin"].."")
                                end
                            end
                            
                            if members[ent][i]["leader"] == 1 then
                                --dxDrawImage(pos[1] + 762, y + 5, 15*0.8, 14*0.8, "files/img/players/leader.png")
                                dxDrawImage(pos[1] + 762, y + 5, 15*0.8, 14*0.8, "files/img/icons/leader.png")
                            end 
                            
                            y = y + 28
                        end
                    end
                end
                
                if isLeader then
                    dxDrawImage(pos[1] + 807.5, pos[2] + 145 + 30, 290*0.8, 30*0.8, "files/img/players/tgf.png")
                    local name = "Játékos neve"
                    if editBoxes["playerName"] ~= "" then
                        name = editBoxes["playerName"]
                    end
                    dxDrawText(name, pos[1] + 807.5, pos[2] + 145 + 30, pos[1] + 807.5 + 290*0.8, pos[2] + 145 + 30 + 30*0.8, (pcache[name] and tocolor(0, 255, 0, 255) or tocolor(255, 255, 255, 255)), 1, font2, "center", "center")
                    local poz = {pos[1] + 807.5, pos[2] + 145 + 60, 290*0.8, 30*0.8}
                    dxDrawImage(poz[1], poz[2], poz[3], poz[4], (isInSlot(poz[1], poz[2], poz[3], poz[4]) and "files/img/players/green_c.png" or "files/img/players/green.png"))
                    dxDrawText("Felvétel", poz[1], poz[2], poz[1] + poz[3], poz[2] + poz[4], tocolor(0, 0, 0, 255), 1, font_bold2, "center", "center")
                end
                
                if selectedMember > 0 then
                    if isLeader then
                        local poz = {pos[1] + 807.5, pos[2] + 115, 290*0.8, 30*0.8}
                        dxDrawImage(poz[1], poz[2], poz[3], poz[4], (isInSlot(poz[1], poz[2], poz[3], poz[4]) and "files/img/players/green_c.png" or "files/img/players/green.png"))
                        local poz = {pos[1] + 807.5, pos[2] + 145, 290*0.8, 30*0.8}
                        dxDrawImage(poz[1], poz[2], poz[3], poz[4], (isInSlot(poz[1], poz[2], poz[3], poz[4]) and "files/img/players/red_c.png" or "files/img/players/red.png"))
                        
                        local poz = {pos[1] + 807.5, pos[2] + 275, 290*0.8, 30*0.8}
                        dxDrawImage(poz[1], poz[2], poz[3], poz[4], (isInSlot(poz[1], poz[2], poz[3], poz[4]) and "files/img/players/red_c.png" or "files/img/players/red.png"))
                        local poz = {pos[1] + 807.5, pos[2] + 305, 290*0.8, 30*0.8}
                        dxDrawImage(poz[1], poz[2], poz[3], poz[4], (isInSlot(poz[1], poz[2], poz[3], poz[4]) and "files/img/players/red_c.png" or "files/img/players/red.png"))
                        local poz = {pos[1] + 807.5, pos[2] + 345, 290*0.8, 30*0.8}
                        dxDrawImage(poz[1], poz[2], poz[3], poz[4], (isInSlot(poz[1], poz[2], poz[3], poz[4]) and "files/img/players/green_c.png" or "files/img/players/green.png"))
                        
                        dxDrawText("Előléptetés", pos[1] + 807.5, pos[2] + 116, pos[1] + 807.5 + 290*0.8, pos[2] + 116 + 30*0.8, tocolor(0, 0, 0, 255), 1, font_bold2, "center", "center")
                        dxDrawText("Lefokozás", pos[1] + 807.5, pos[2] + 146, pos[1] + 807.5 + 290*0.8, pos[2] + 146 + 30*0.8, tocolor(0, 0, 0, 255), 1, font_bold2, "center", "center")
                        
                        dxDrawText(stats["Leader"][members[ent][selectedMember]["leader"]], pos[1] + 807.5, pos[2] + 276, pos[1] + 807.5 + 290*0.8, pos[2] + 276 + 30*0.8, tocolor(0, 0, 0, 255), 1, font_bold2, "center", "center")
                        dxDrawText("Kirúgás", pos[1] + 807.5, pos[2] + 306, pos[1] + 807.5 + 290*0.8, pos[2] + 306 + 30*0.8, tocolor(0, 0, 0, 255), 1, font_bold2, "center", "center")
                        
                        dxDrawText("Jogok szerkesztése", pos[1] + 807.5, pos[2] + 345, pos[1] + 807.5 + 290*0.8, pos[2] + 345 + 30*0.8, tocolor(0, 0, 0, 255), 1, font_bold2, "center", "center")
                    end
                end
            end
        elseif names[selectedPage] == "Rangok" then
            dxDrawImage(pos[1] + 230, pos[2] + 95, 709*0.8, 591*0.8, "files/img/ranks/bg.png")
            dxDrawImage(pos[1] + 235, pos[2] + 100, 18*0.8, 17*0.8, "files/img/icons/player.png")
            dxDrawText("Rangok és fizetések", pos[1] + 257.5, pos[2] + 101, pos[1] + 257.5 + 24*0.8, pos[2] + 101 + 17*0.8, tocolor(255, 255, 255, 255), 1, font2, "left", "center", false, false, false, true, false)
            
            if isInSlot(pos[1] + 230, pos[2] + 95, 709*0.8, 591*0.8) then
                element = "scrollRanks"
            else
                element = nil
            end
            
            dxDrawImage(pos[1] + 230, pos[2] + 125, 709*0.8, 30*0.8, "files/img/players/line.png")
            dxDrawText("Rang neve", pos[1] + 235, pos[2] + 126, pos[1] + 235 + 709*0.8, pos[2] + 126 + 30*0.8, tocolor(255, 105, 38, 255), 1, font3, "left", "center")
            dxDrawText("Fizetés", pos[1] + 230, pos[2] + 126, pos[1] + 230 + 709*0.8, pos[2] + 126 + 30*0.8, tocolor(255, 105, 38, 255), 1, font3, "center", "center")
            dxDrawText("Utoljára módosítva", pos[1] + 225, pos[2] + 126, pos[1] + 225 + 709*0.8, pos[2] + 126 + 30*0.8, tocolor(255, 105, 38, 255), 1, font3, "right", "center")
            
            local maxLine = 14
            local y = pos[2] + 125 + 28
            local latestLine = lineRanks + maxLine - 1

            for i=1, #enterprises[selectedEnt]["rank_names"] do
                if i >= lineRanks then
                    if i <= latestLine then
                        local poz = {pos[1] + 230, y, 709*0.8, 30*0.8}
                        dxDrawImage(poz[1], poz[2], poz[3], poz[4], ((isInSlot(poz[1], poz[2], poz[3], poz[4]) or selectedRank == i) and "files/img/players/line_c.png" or "files/img/players/line.png"))
                        
                        dxDrawText(enterprises[selectedEnt]["rank_names"][i], pos[1] + 235, y+1, pos[1] + 235 + 709*0.8, y+1 + 30*0.8, ((isInSlot(poz[1], poz[2], poz[3], poz[4]) or selectedRank == i) and tocolor(255, 255, 255, 255) or tocolor(255, 105, 38, 255)), 1, font3, "left", "center")
                        --dxDrawText(formatMoney(enterprises[selectedEnt]["rank_pays"][i]).."$", pos[1] + 230, y+1, pos[1] + 230 + 709*0.8, y+1 + 30*0.8, ((isInSlot(poz[1], poz[2], poz[3], poz[4]) or selectedRank == i) and tocolor(255, 255, 255, 255) or tocolor(255, 105, 38, 255)), 1, font3, "center", "center")
                        dxDrawText(formatMoney(enterprises[selectedEnt]["rank_pays"][i]).."$", pos[1] + 230, y+1, pos[1] + 230 + 709*0.8, y+1 + 30*0.8, ((isInSlot(poz[1], poz[2], poz[3], poz[4]) or selectedRank == i) and tocolor(255, 255, 255, 255) or tocolor(255, 105, 38, 255)), 1, font3, "center", "center")
                        dxDrawText(enterprises[selectedEnt]["rank_changes"][i], pos[1] + 225, y+1, pos[1] + 225 + 709*0.8, y+1 + 30*0.8, ((isInSlot(poz[1], poz[2], poz[3], poz[4]) or selectedRank == i) and tocolor(255, 255, 255, 255) or tocolor(255, 105, 38, 255)), 1, font3, "right", "center")
                        
                        y = y + 28
                    end
                end
            end
            
            if selectedRank > 0 then
                if isLeader then
                    dxDrawImage(pos[1] + 230 + 709*0.8 + 10, pos[2] + 125, 290*0.8, 30*0.8, "files/img/players/tgf.png")--név
                    dxDrawImage(pos[1] + 230 + 709*0.8 + 10, pos[2] + 125 + 100, 290*0.8, 30*0.8, "files/img/players/tgf.png")--fizu
                    local name = "Rang név"
                    if editBoxes["rankName"] ~= "" then
                        name = editBoxes["rankName"]
                    end
                    
                    local money = "0"
                    if editBoxes["rankMoney"] ~= "" then
                        money = editBoxes["rankMoney"]
                    end
                    dxDrawImage(pos[1] + 230 + 709*0.8 + 10, pos[2] + 125 + 30, 290*0.8, 30*0.8, (isInSlot(pos[1] + 230 + 709*0.8 + 10, pos[2] + 125 + 30, 290*0.8, 30*0.8) and "files/img/ranks/name_bg_c.png" or "files/img/ranks/name_bg.png"))
                    dxDrawText(name, pos[1] + 230 + 709*0.8 + 10, pos[2] + 126, pos[1] + 230 + 709*0.8 + 10 + 290*0.8, pos[2] + 126 + 30*0.8, tocolor(255, 255, 255, 255), 1, font2, "center", "center")
                    dxDrawText("Név megváltoztatása", pos[1] + 230 + 709*0.8 + 10, pos[2] + 126 + 31, pos[1] + 230 + 709*0.8 + 10 + 290*0.8, pos[2] + 126 + 31 + 30*0.8, tocolor(0, 0, 0, 255), 1, font2, "center", "center")
                    dxDrawImage(pos[1] + 230 + 709*0.8 + 10, pos[2] + 125 + 30 + 100, 290*0.8, 30*0.8, (isInSlot(pos[1] + 230 + 709*0.8 + 10, pos[2] + 125 + 30 + 100, 290*0.8, 30*0.8) and "files/img/ranks/name_bg_c.png" or "files/img/ranks/name_bg.png"))
                    dxDrawText(money.."$", pos[1] + 230 + 709*0.8 + 10, pos[2] + 126 + 100, pos[1] + 230 + 709*0.8 + 10 + 290*0.8, pos[2] + 126 + 100 + 30*0.8, tocolor(255, 255, 255, 255), 1, font2, "center", "center")
                    dxDrawText("Fizetés megváltoztatása", pos[1] + 230 + 709*0.8 + 10, pos[2] + 126 + 30 + 100, pos[1] + 230 + 709*0.8 + 10 + 290*0.8, pos[2] + 126 + 30 + 100 + 30*0.8, tocolor(0, 0, 0, 255), 1, font2, "center", "center")
                end
            end
        elseif names[selectedPage] == "Járművek" then
            --vehicles = carshopVehicles
            dxDrawImage(pos[1] + 230, pos[2] + 95, 369*0.8, 591*0.8, "files/img/vehicles/bg.png")
            dxDrawImage(pos[1] + 235, pos[2] + 100, 24*0.8, 17*0.8, "files/img/icons/car.png")
            dxDrawText("Járművek #FF6926("..#carshopVehicles[ent].."db)", pos[1] + 257.5, pos[2] + 101, pos[1] + 257.5 + 24*0.8, pos[2] + 101 + 17*0.8, tocolor(255, 255, 255, 255), 1, font2, "left", "center", false, false, false, true, false)
            
            if isInSlot(pos[1] + 230, pos[2] + 95, 369*0.8, 591*0.8) then
                element = "scrollVehicles" 
            else
                element = nil
            end
            --print(#carshopVehicles[ent] .. " AKASDSDIAS " .. ent)
            if #carshopVehicles[ent] > 0 then
                --print("SZAR")

                --outputConsole(inspect(carshopVehicles))

                local maxLine = 16
                local y = pos[2] + 125
                local latestLine = lineVehicle + maxLine - 1

                for i=1, #carshopVehicles[ent] do
                    if i >= lineVehicle then 
                        if i <= latestLine then
                            local poz = {pos[1] + 230, y, 369*0.8, 30*0.8}
                            local veh = carshopVehicles[ent][i]
                            dxDrawImage(poz[1], poz[2], poz[3], poz[4], ((isInSlot(poz[1], poz[2], poz[3], poz[4]) or selectedVehicle == i) and "files/img/players/line_c.png" or "files/img/vehicles/line.png"))
                            dxDrawText(exports.sarp_mods_veh:getVehicleNameFromModel(veh["model"]), pos[1] + 235, y + 1, pos[1] + 235 + 369*0.8, y + 1 + 30*0.8, ((isInSlot(poz[1], poz[2], poz[3], poz[4]) or selectedVehicle == i) and tocolor(0, 0, 0, 255) or tocolor(255, 255, 255, 255)), 1, font3, "left", "center")
                            dxDrawText(veh["dbid"], pos[1] + 225, y + 1, pos[1] + 225 + 369*0.8, y + 1 + 30*0.8, ((isInSlot(poz[1], poz[2], poz[3], poz[4]) or selectedVehicle == i) and tocolor(255, 255, 255, 255) or tocolor(255, 105, 38, 255)), 1, font3, "right", "center")
                            y = y + 28
                        end
                    end
                end
                
                if selectedVehicle > 0 then
                    local veh = carshopVehicles[ent][selectedVehicle]
                    
                    local element = veh["element"]
                    if isElement(element) then
                        outputConsole(inspect(veh))
                        local engine = veh["engine"]
                        local light = veh["light"]
                        local airride = veh["airride"]

                        local upgrade1 = veh["upgrade1"]
                        local upgrade2 = veh["upgrade2"]
                        local upgrade3 = veh["upgrade3"]
                        dxDrawImage(pos[1] + 230 + 369*0.8 + 10, pos[2] + 95, 629*0.8, 243*0.8, "files/img/vehicles/info_bg.png")

                        dxDrawText("Kijelölt jármű specifikációi", pos[1] + 230 + 369*0.8 + 10, pos[2] + 100, pos[1] + 230 + 369*0.8 + 10 + 629*0.8, pos[2] + 100 + 243*0.8, tocolor(255, 255, 255, 255), 1, font, "center", "top")

                        dxDrawText("#FFFFFFÁllapot: #913032"..math.floor(getElementHealth(element)/10).."%\n#FFFFFFMotor: #913032"..stats["Engine"][engine].." #FFFFFFLámpa: #913032"..stats["Light"][light].." #FFFFFFKézifék: #5c7535"..(isElementFrozen(element) and "behúzva" or "kiengedve")..
                        "\n#FFFFFFAirRide: #5c7535"..(airride and "van" or "nincs").." #FFFFFFNeon: #913032"..(neon and "van" or "nincs").." #FFFFFFMotor: #913032"..upgrades[upgrade1]..
                        " #FFFFFFVáltó: #913032"..upgrades[upgrade2].."\n#FFFFFFKerék - fék: #913032"..upgrades[upgrade3].." #FFFFFFChip: #913032"..(chip and "van" or "nincs").."", pos[1] + 230 + 369*0.8 + 10, pos[2] + 95, pos[1] + 230 + 369*0.8 + 10 + 629*0.8, pos[2] + 95 + 243*0.8, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, false, true, false)
                        
                        dxDrawImage(pos[1] + 230 + 369*0.8 + 10, pos[2] + 95 + 200, 629*0.8, 30*0.8, "files/img/vehicles/give.png")
                        local poz = {pos[1] + 230 + 369*0.8 + 10, pos[2] + 95 + 200, 629*0.8, 30*0.8}
                        dxDrawText("Kulcs adás", pos[1] + 230 + 369*0.8 + 10, pos[2] + 96 + 200, pos[1] + 230 + 369*0.8 + 10 + 629*0.8, pos[2] + 96 + 200 + 30*0.8, (isInSlot(poz[1], poz[2], poz[3], poz[4]) and tocolor(255, 255, 255, 255) or tocolor(0, 0, 0, 255)), 1, font, "center", "center")
                    end
                end
            end
        elseif not names[selectedPage] and selectedPage == 5 and special_names[type] == "Raktár" then
            local y = pos[2] + 110
            local column = 0  
            for i=1, 180 do
                dxDrawRectangle(pos[1] + 235 + column*45, y, 38, 38, tocolor(0, 0, 0, 105))
                
                if storage[ent][i] then
                    local store = storage[ent][i]
                    dxDrawImage(pos[1] + 235 + column*45 - 1, y - 2, 40, 40, ":ex_inventory/images/"..store[2]..".png")
                    if isInSlot(pos[1] + 235 + column*45 - 1, y - 2, 40, 40) then
                        tooltip(exports.ex_inventory:getItemName(store[2]))
                    end
                    
                    local db = 0
                    if store[4] > 999 then
                        db = 1000
                    else
                        db = store[4]
                    end
                    dxDrawText(db.."db", pos[1] + 237.5 + column*45 - 1, y - 2, pos[1] + 237.5 + column*45 - 1 + 40, y - 2 + 40, tocolor(255, 255, 255, 255), 1, font4, "left", "bottom")
                end
                
                column = column + 1
                if column == 18 then
                    column = 0
                end
                
                if i%18 == 0 then
                    y = y + 45 
                end
            end
            
        elseif not names[selectedPage] and selectedPage == 5 and special_names[type] == "Kereskedésben lévő járművek" then
            if isInSlot(pos[1] + 230, pos[2] + 95, 1010*0.8, 591*0.8) then
                element = "scrollCarshopVehicles" 
            else
                element = nil
            end
            
            local maxLine = 10
            local y = pos[2] + 100
            local latestLine = lineCarshopVehicle + maxLine - 1
            for i=1, #carshopVehicles[ent] do
                if i >= lineCarshopVehicle then 
                    if i <= latestLine then
                        local poz = {pos[1] + 230, y, 1010*0.8, 50*0.8}
                        local veh = vehicles[ent][i]
                        dxDrawImage(poz[1], poz[2], poz[3], poz[4], "files/img/vehicles/line.png")
                        
                        local veh = carshopVehicles[ent][i]
                        local element = veh["element"]
                        local light = veh["light"]
                        local airride = veh["airride"]

                        local upgrade1 = veh["upgrade1"]
                        local upgrade2 = veh["upgrade2"]
                        local upgrade3 = veh["upgrade3"]
                        
                        local time = getElementData(element, "veh:carshop_added") or "2017.01.01. 00:00:00"
                        
                        if element and isElement(element) then
                            dxDrawText(exports.sarp_mods_veh:getVehicleNameFromModel(getElementModel(element)), poz[1]+5, poz[2]+1, poz[1]+5 + poz[3], poz[2]+1 + poz[4], tocolor(255, 255, 255, 255), 1, font3, "left", "center")
                            dxDrawText("#FFFFFFAirRide: #5c7535"..(airride and "van" or "nincs").." #FFFFFFNeon: #913032"..(neon and "van" or "nincs").." #FFFFFFMotor: #913032"..upgrades[upgrade1].." #FFFFFFVáltó: #913032"..upgrades[upgrade2].."\n#FFFFFFKerék - fék: #913032"..upgrades[upgrade3].." #FFFFFFChip: #913032"..(chip and "van" or "nincs").."", poz[1]+5, poz[2]+1, poz[1]+5 + poz[3], poz[2]+1 + poz[4], tocolor(255, 255, 255, 255), 1, font3, "center", "center", false, false, false, true, false)
                            dxDrawText(formatMoney(getElementData(element, "veh:Price")).."$", poz[1]-5, poz[2]+1, poz[1]-5 + poz[3], poz[2]+1 + poz[4], tocolor(255, 255, 255, 255), 1, font3, "right", "center")
                            if isInSlot(poz[1], poz[2], poz[3], poz[4]) then
                                tooltip("Kereskedésbe rakva: "..time)
                            end
                        end
                        
                        y = y + 45
                    end
                end
            end
        elseif selectedPage == 6 then
            if isLeader then
                --dxDrawText("Vállalkozás egyenleg: "..formatMoney(enterprises[selectedEnt]["balance"]).."$", pos[1] + 230 + 250, pos[2] + 150, pos[1] + 230 + 250 + 350*0.8, pos[2] + 150 + 45*0.8, tocolor(255, 255, 255, 255), 1, font, "center", "top")
                dxDrawText("Vállalkozás egyenleg: "..enterprises[selectedEnt]["balance"].."$", pos[1] + 230 + 250, pos[2] + 150, pos[1] + 230 + 250 + 350*0.8, pos[2] + 150 + 45*0.8, tocolor(255, 255, 255, 255), 1, font, "center", "top")
                
                dxDrawImage(pos[1] + 230 + 250, pos[2] + 200, 350*0.8, 45*0.8, "files/img/players/tgf.png")
                dxDrawImage(pos[1] + 230 + 250 - 15, pos[2] + 200 + 45, 350*0.8 + 30, 35*0.8, (isInSlot(pos[1] + 230 + 250 - 15, pos[2] + 200 + 45, 350*0.8 + 30, 35*0.8) and "files/img/ranks/name_bg_c.png" or "files/img/ranks/name_bg.png"))
                local money = "0"
                if editBoxes["moneyIN"] ~= "" then
                    money = editBoxes["moneyIN"]
                end
                --dxDrawText(formatMoney(money).."$", pos[1] + 230 + 250, pos[2] + 200, pos[1] + 230 + 250 + 350*0.8, pos[2] + 200 + 45*0.8, tocolor(255, 255, 255, 255), 1, font2, "center", "center")
                dxDrawText(money.."$", pos[1] + 230 + 250, pos[2] + 200, pos[1] + 230 + 250 + 350*0.8, pos[2] + 200 + 45*0.8, tocolor(255, 255, 255, 255), 1, font2, "center", "center")
                dxDrawText("Befizetés", pos[1] + 230 + 250 - 15, pos[2] + 200 + 45, pos[1] + 230 + 250 - 15 + 350*0.8 + 30, pos[2] + 200 + 45 + 35*0.8, tocolor(255, 255, 255, 255), 1, font, "center", "center")
                
                dxDrawImage(pos[1] + 230 + 250, pos[2] + 300, 350*0.8, 45*0.8, "files/img/players/tgf.png")
                dxDrawImage(pos[1] + 230 + 250 - 15, pos[2] + 300 + 45, 350*0.8 + 30, 35*0.8, (isInSlot(pos[1] + 230 + 250 - 15, pos[2] + 300 + 45, 350*0.8 + 30, 35*0.8) and "files/img/ranks/name_bg_c.png" or "files/img/ranks/name_bg.png"))
                local money = "0"
                if editBoxes["moneyOUT"] ~= "" then
                    money = editBoxes["moneyOUT"]
                end
                --dxDrawText(formatMoney(money).."$", pos[1] + 230 + 250, pos[2] + 300, pos[1] + 230 + 250 + 350*0.8, pos[2] + 300 + 45*0.8, tocolor(255, 255, 255, 255), 1, font2, "center", "center")
                dxDrawText(money.."$", pos[1] + 230 + 250, pos[2] + 300, pos[1] + 230 + 250 + 350*0.8, pos[2] + 300 + 45*0.8, tocolor(255, 255, 255, 255), 1, font2, "center", "center")
                dxDrawText("Kifizetés", pos[1] + 230 + 250 - 15, pos[2] + 300 + 45, pos[1] + 230 + 250 - 15 + 350*0.8 + 30, pos[2] + 300 + 45 + 35*0.8, tocolor(255, 255, 255, 255), 1, font, "center", "center")

            else
                dxDrawText("Csak leader használhatja ezt a funkciót!", pos[1] + 100, pos[2], pos[1] + width + 100, pos[2] + height, tocolor(255, 255, 255, 255), 1, font, "center", "center")
            end
        end
        if showPermissionPanel then
            --exports.ex_blur:createBlur()
            dxDrawRectangle(screenW/2 - 320/2, screenH/2 - 410/2, 320, 410, tocolor(0, 0, 0, 50))
            dxDrawRectangle(screenW/2 - 320/2, screenH/2 - 410/2, 320, 25, tocolor(0, 0, 0, 100))
            dxDrawRectangle(screenW/2 - 320/2, screenH/2 - 410/2 + 410 - 25, 320, 25, (isInSlot(screenW/2 - 320/2, screenH/2 - 410/2 + 410 - 25, 320, 25) and tocolor(0, 0, 0, 50) or tocolor(0, 0, 0, 100)))
            dxDrawText(members[ent][selectedMember]["charactername"]:gsub("_", " "), screenW/2 - 320/2, screenH/2 - 410/2, screenW/2 - 320/2 + 320, screenH/2 - 410/2 + 25, tocolor(255, 255, 255, 255), 1, font, "center", "center")
            dxDrawText("Bezárás - mentés", screenW/2 - 320/2, screenH/2 - 410/2 + 410 - 25, screenW/2 - 320/2 + 320, screenH/2 - 410/2 + 410 - 25 + 25, tocolor(65, 140, 240, 255), 1, font, "center", "center")
            for i = 1, #permissions[enterprises[selectedEnt]["type"]][1] do
                dxDrawRectangle(screenW/2 - 320/2, screenH/2 - 410/2 + i*30, 320, 25, tocolor(0, 0, 0, 100))
                dxDrawText(permissions[enterprises[selectedEnt]["type"]][1][i], screenW/2 - 320/2 + 2, screenH/2 - 410/2 + i*30+1, screenW/2 - 320/2 + 320 + 2, screenH/2 - 410/2 + i*30+1 + 25, tocolor(255, 255, 255, 255), 1, font3, "left", "center")
                
                dxDrawRectangle(screenW/2 - 320/2 + 320 - 20, screenH/2 - 410/2 + i*30 + 5, 15, 15, (isInSlot(screenW/2 - 320/2 + 320 - 20, screenH/2 - 410/2 + i*30 + 5, 15, 15) and tocolor(0, 0, 0, 100) or tocolor(0, 0, 0, 150)))
                if ticked[i] then
                    dxDrawRectangle(screenW/2 - 320/2 + 320 - 20 + 7.5/2, screenH/2 - 410/2 + i*30 + 5 + 7.5/2, 7.5, 7.5, tocolor(255, 255, 255, 255))
                end
            end
        end
    end
end

local bank = createColSphere(3586.7978515625, -1361.4548339844, 14.59375, 15)
local bankInt = 0;
local bankDim = 0;
local cache = {}
local moneyTimer

function isInBank()
	if isElementWithinColShape(localPlayer, bank) and getElementDimension(localPlayer) == bankDim and getElementInterior(localPlayer) == bankInt then
		return true
	end
	return false
end

function click(button, state, abX, abY)
    if show then
        if button == "left" then
            if state == "down" then
                if showPermissionPanel then
                    local ent = enterprises[selectedEnt]["id"]
                    local newCache = {}
                    if isInSlot(screenW/2 - 320/2, screenH/2 - 410/2 + 410 - 25, 320, 25) then
                        local perms = fromJSON(members[ent][selectedMember]["permissions"])
                        for i, k in pairs(permissions[enterprises[selectedEnt]["type"]][1]) do
                            if cache[k] then
                                newCache[k] = cache[k][1]
                            else
                                newCache[k] = perms[k]
                            end
                        end
                        members[ent][selectedMember]["permissions"] = toJSON(newCache)
                        triggerServerEvent("server->savePermissions", localPlayer, newCache, ent, selectedMember)
                        ticked = {}
                        cache = {}
                        showPermissionPanel = false
                        return
                    end
                    
                    for i = 1, #permissions[enterprises[selectedEnt]["type"]][1] do
                        if isInSlot(screenW/2 - 320/2 + 320 - 20, screenH/2 - 410/2 + i*30 + 5, 15, 15) then
                            if ticked[i] then
                                ticked[i] = false
                                cache[permissions[enterprises[selectedEnt]["type"]][1][i]] = {false}
                            else
                                ticked[i] = true
                                cache[permissions[enterprises[selectedEnt]["type"]][1][i]] = {true}
                            end
                            return
                        end
                    end
                    return
                end
                --------------------------------------------------------------------------------------------
                -- Bezárás(kattintással)
                if isInBox(pos[1] + width - 100, pos[2] + height, 100, 20, abX, abY) then
                    remove()
                    return
                end
                
                --------------------------------------------------------------------------------------------
                -- Vállalkozás választás
                if isInBox(pos[1] + 5, pos[2] + 425, 7, 18, abX, abY) then
                    if selectedEnt > 1 then
                        selectedEnt = selectedEnt - 1
                        selectedPage = 1
                        lineVehicle = 1
                        linePlayer = 1
                        lineRanks = 1

                        selectedVehicle = 0
                        selectedMember = 0
                        selectedRank = 0
                        checkLeader()
                    end
                    return
                elseif isInBox(pos[1] + 208, pos[2] + 425, 7, 18, abX, abY) then
                    if selectedEnt + 1 <= #enterprises then
                        selectedEnt = selectedEnt + 1
                        selectedPage = 1
                        lineVehicle = 1
                        linePlayer = 1
                        lineRanks = 1

                        selectedVehicle = 0
                        selectedMember = 0
                        selectedRank = 0
                        checkLeader()
                    end
                    return
                end
                
                --------------------------------------------------------------------------------------------
                -- Menü választás
                for i=1, 6 do
                    if isInBox(pos[1] + 10, pos[2] + 125 + i*35, 246*0.8, 40*0.8, abX, abY) then
                        selectedPage = i
                        checkLeader()
                        return
                    end
                end
                
                --------------------------------------------------------------------------------------------
                if selectedPage == 6 then
                    if isLeader then
                        local ent = enterprises[selectedEnt]["id"]
                        if isInSlot(pos[1] + 230 + 250 - 15, pos[2] + 200 + 45, 350*0.8 + 30, 35*0.8) then
                            if not isInBank() then exports.sarp_hud:showAlert("error", "Csak bankban!") return end
                            local loss = getNetworkStats()["packetlossLastSecond"]
	                        if (loss > 2) then
                                return
                            end
                            if isTimer(moneyTimer) then return end
                            if tonumber(editBoxes["moneyIN"]) or 0 > 0 then
                                if exports.ex_core:takeMoney(localPlayer, tonumber(editBoxes["moneyIN"])) then
                                    if giveEnterpriseMoney(localPlayer, ent, tonumber(editBoxes["moneyIN"]), true) then 
                                        exports.ex_gui:showInfoBox("Sikeresen befizettél "..editBoxes["moneyIN"].."dollárt!")
                                        moneyTimer = setTimer(function() end, 5000, 1)
                                    end
                                else
                                    exports.ex_gui:showInfoBox("Nincs nálad ennyi pénz!")
                                end
                            else
                                exports.ex_gui:showInfoBox("0-nál többet kell beraknod!")
                            end
                        elseif isInSlot(pos[1] + 230 + 250 - 15, pos[2] + 300 + 45, 350*0.8 + 30, 35*0.8) then
                            if not isInBank() then exports.sarp_hud:showAlert("error", "Csak bankban!") return end
                            local loss = getNetworkStats()["packetlossLastSecond"]
	                        if (loss > 2) then
                                return
                            end
                            if isTimer(moneyTimer) then return end
                            if tonumber(editBoxes["moneyOUT"]) or 0 > 0 then
                                local balance = enterprises[selectedEnt]["balance"]
                                if balance - tonumber(editBoxes["moneyOUT"]) >= 0 then
                                    if takeEnterpriseMoney(localPlayer, ent, tonumber(editBoxes["moneyOUT"]), true) then
                                        exports.ex_gui:showInfoBox("Sikeresen kivettél "..editBoxes["moneyOUT"].."dollárt!")
                                        triggerServerEvent("ent->givemoney", localPlayer, tonumber(editBoxes["moneyOUT"]))
                                        moneyTimer = setTimer(function() end, 5000, 1)
                                    end
                                else
                                    exports.ex_gui:showInfoBox("Vállalkozásnak nincs ennyi pénze!")
                                end
                            else
                                exports.ex_gui:showInfoBox("0-nál többet kell beírnod!")
                            end
                        end
                        
                        if isInSlot(pos[1] + 230 + 250, pos[2] + 200, 350*0.8, 45*0.8) then
                            addEditBox("moneyIN")
                        elseif isInSlot(pos[1] + 230 + 250, pos[2] + 300, 350*0.8, 45*0.8) then
                            addEditBox("moneyOUT")
                        else
                            addEditBox()
                        end
                    end
                    return
                end
                
                -- Funkciók
                if names[selectedPage] == "Tagok" then
                    local ent = enterprises[selectedEnt]["id"]
                    if #members[ent] > 0 then
                        local maxLine = 14
                        local y = pos[2] + 125 + 28
                        local latestLine = linePlayer + maxLine - 1

                        for i=1, #members[ent] do
                            if i >= linePlayer then 
                                if i <= latestLine then
                                    if isInBox(pos[1] + 230, y, 709*0.8, 30*0.8, abX, abY) then
                                        selectedMember = i
                                        return
                                    end
                                    y = y + 28
                                end
                            end
                        end
                    end
                    
                    if isLeader then
                        if isInSlot(pos[1] + 807.5, pos[2] + 145 + 30, 290*0.8, 30*0.8) then
                            addEditBox("playerName")
                        else
                            addEditBox()
                        end
                        
                        if isInSlot(pos[1] + 807.5, pos[2] + 145 + 60, 290*0.8, 30*0.8) then
                            if string.len(editBoxes["playerName"]) > 0 then
                                local player = pcache[editBoxes["playerName"]]
                                local element = isElement(player)
                                if element then
                                    for i=1, #members[ent] do
                                        if members[ent][i]["account"] == getElementData(player, "char.ID") then
                                           -- exports.ex_gui:showInfoBox("Ő már a vállalkozás tagja!")
                                            exports.sarp_hud:showAlert("error", "Ő már a vállalkozás tagja!")
                                            return
                                        end
                                    end
                                    
                                    triggerServerEvent("server->inviteToEnterprise", localPlayer, player, ent)
                                    --exports.ex_gui:showInfoBox("Sikeresen felvetted "..editBoxes["playerName"]:gsub("_", " ").."-t")
                                    exports.sarp_hud:showAlert("success", "Sikeresen felvetted "..editBoxes["playerName"]:gsub("_", " ").."-t")
                                else
                                    --exports.ex_gui:showInfoBox("Nincs ilyen játékos!")
                                    exports.sarp_hud:showAlert("error", "Nincs ilyen játékos!")
                                end
                            end
                        end
                    end
                    
                    if selectedMember > 0 then
                        if isLeader then
                            local player = members[ent][selectedMember]
                            if isInBox(pos[1] + 807.5, pos[2] + 115, 290*0.8, 30*0.8, abX, abY) then
                                if isTimer(timer) then
                                    return
                                end
                                timer = setTimer(function() end, 1000, 1)
                                local rank = player["rank"]
                                if rank == 10 then
                                    exports.ex_gui:showInfoBox("10-es rangnál nem adhatsz nagyobbat!")
                                else
                                    triggerServerEvent("server->rankChange", localPlayer, ent, selectedMember, rank + 1)
                                    members[ent][selectedMember]["rank"] = rank + 1
                                end
                                return
                            elseif isInBox(pos[1] + 807.5, pos[2] + 145, 290*0.8, 30*0.8, abX, abY) then
                                if isTimer(timer) then
                                    return
                                end
                                timer = setTimer(function() end, 1000, 1)
                                local rank = player["rank"]
                                if rank == 1 then
                                    exports.ex_gui:showInfoBox("1-es rangnál nem adhatsz kisebbet!")
                                else
                                    triggerServerEvent("server->rankChange", localPlayer, ent, selectedMember, rank - 1)
                                    members[ent][selectedMember]["rank"] = rank - 1
                                end
                                return
                            elseif isInBox(pos[1] + 807.5, pos[2] + 275, 290*0.8, 30*0.8, abX, abY) then
                                if isTimer(timer) then
                                    return
                                end
                                timer = setTimer(function() end, 1000, 1)
                                local leader = player["leader"]
                                if leader == 1 then
                                    triggerServerEvent("server->leaderChange", localPlayer, ent, selectedMember, 0)
                                    members[ent][selectedMember]["leader"] = 0
                                    exports.ex_gui:showInfoBox("Elvetted "..player["charactername"]:gsub("_", " ").."-nak/nek leader jogot!")
                                else
                                    triggerServerEvent("server->leaderChange", localPlayer, ent, selectedMember, 1)
                                    members[ent][selectedMember]["leader"] = 1
                                    exports.ex_gui:showInfoBox("Adtál "..player["charactername"]:gsub("_", " ").." leader jogát!")
                                end
                                return
                            elseif isInBox(pos[1] + 807.5, pos[2] + 305, 290*0.8, 30*0.8, abX, abY) then
                                if isTimer(timer) then
                                    return
                                end
                                timer = setTimer(function() end, 1000, 1)
                                local element = pcache[player["charactername"]]
                                if isElement(element) then
                                    if element == localPlayer then
                                        exports.ex_gui:showInfoBox("Magadat nem rúghatod ki!")
                                        return
                                    end
                                end
                                triggerServerEvent("server->kickPlayer", localPlayer, ent, selectedMember)
                                table.remove(members[ent], selectedMember)
                                selectedMember = 0
                                return
                            elseif isInBox(pos[1] + 807.5, pos[2] + 345, 290*0.8, 30*0.8, abX, abY) then
                                if permissions[enterprises[selectedEnt]["type"]] then
                                    local perms = fromJSON(members[ent][selectedMember]["permissions"])
                                    for i = 1, #permissions[enterprises[selectedEnt]["type"]][1] do
                                        ticked[i] = perms[permissions[enterprises[selectedEnt]["type"]][1][i]]
                                    end
                                    showPermissionPanel = true
                                else
                                    exports.ex_gui:showInfoBox("Ez a vállalkozás jelenleg nem rendelkezik ezzel a funkcióval!")
                                end
                                return
                            end
                        end
                    end
                elseif names[selectedPage] == "Rangok" then
                    local ent = enterprises[selectedEnt]["id"]
                    local maxLine = 14
                    local y = pos[2] + 125 + 28
                    local latestLine = lineRanks + maxLine - 1

                    for i=1, #enterprises[selectedEnt]["rank_names"] do
                        if i >= lineRanks then
                            if i <= latestLine then
                                local poz = {pos[1] + 230, y, 709*0.8, 30*0.8}
                                if isInBox(poz[1], poz[2], poz[3], poz[4], abX, abY) then
                                    selectedRank = i
                                    return
                                end
                                
                                y = y + 28
                            end
                        end
                    end
                    if selectedRank > 0 then
                        if isLeader then
                            if isInSlot(pos[1] + 230 + 709*0.8 + 10, pos[2] + 125, 290*0.8, 30*0.8) then
                                addEditBox("rankName")
                            elseif isInSlot(pos[1] + 230 + 709*0.8 + 10, pos[2] + 125 + 100, 290*0.8, 30*0.8) then
                                addEditBox("rankMoney")
                            else
                                addEditBox()
                            end
                            
                            if isInSlot(pos[1] + 230 + 709*0.8 + 10, pos[2] + 125 + 30, 290*0.8, 30*0.8) then
                                if string.len(editBoxes["rankName"]) > 0 then
                                    exports.ex_gui:showInfoBox("Sikeresen megváltoztattad a rang nevét!")
                                    triggerServerEvent("server->changeRankName", localPlayer, enterprises[selectedEnt]["id"], selectedRank, editBoxes["rankName"])
                                end
                            elseif isInSlot(pos[1] + 230 + 709*0.8 + 10, pos[2] + 125 + 30 + 100, 290*0.8, 30*0.8) then
                                if (tonumber(editBoxes["rankMoney"]) or -1) >= 0 and string.len(editBoxes["rankMoney"]) > 0 then
                                    exports.ex_gui:showInfoBox("Sikeresen megváltoztattad a rang fizetését!")
                                    triggerServerEvent("server->changeRankMoney", localPlayer, enterprises[selectedEnt]["id"], selectedRank, editBoxes["rankMoney"])
                                end
                            end
                        end
                    end
                elseif names[selectedPage] == "Járművek" then
                    if isTimer(timer) then
                        return
                    end
                    timer = setTimer(function() end, 1000, 1)
                    local ent = enterprises[selectedEnt]["id"]
                    local maxLine = 16
                    local y = pos[2] + 125
                    local latestLine = linePlayer + maxLine - 1

                    for i=1, #carshopVehicles[ent] do
                        if i >= linePlayer then 
                            if i <= latestLine then
                                local poz = {pos[1] + 230, y, 369*0.8, 30*0.8}
                                if isInBox(poz[1], poz[2], poz[3], poz[4], abX, abY) then
                                    selectedVehicle = i
                                    return
                                end
                                y = y + 28
                            end
                        end
                    end
                    if selectedVehicle > 0 then
                        local veh = carshopVehicles[ent][selectedVehicle]
                        local element = veh["element"]
                        local dbid = veh["dbid"]
                        if isElement(element) then
                            if isInBox(pos[1] + 230 + 369*0.8 + 10, pos[2] + 95 + 200, 629*0.8, 30*0.8, abX, abY) and isLeader then
                                if (dbid or 0) > 0 then
                                    setElementData(localPlayer, "log:vehicle:27", {player=getElementData(localPlayer, "char.ID"), entID=ent, veh=dbid})
                                    exports.sarp_hud:showAlert("success","Adtál magadnak egy vállalkozás jármű kulcsot!")
                                    triggerServerEvent("server->giveKey", localPlayer, dbid)
                                    return
                                end
                            end
                        end
                    end
                end
                --------------------------------------------------------------------------------------------
            end            
        end
    end
end

function key(button, state)
    if show then
        if button == "mouse_wheel_down" then
            if element == "scrollVehicles" then
                if lineVehicle + 1 <= #vehicles[enterprises[selectedEnt]["id"]] then
                    lineVehicle = lineVehicle + 1
                end
            elseif element == "scrollCarshopVehicles" then
                if lineCarshopVehicle + 1 <= #carshopVehicles[enterprises[selectedEnt]["id"]] then
                    lineCarshopVehicle = lineCarshopVehicle + 1
                end
            elseif element == "scrollPlayers" then
                if linePlayer + 1 <= #members[enterprises[selectedEnt]["id"]] then
                    linePlayer = linePlayer + 1
                end
            elseif element == "scrollRanks" then
                if lineRanks + 1 <= #enterprises[selectedEnt]["rank_names"] then
                    lineRanks = lineRanks + 1
                end
            end
        elseif button == "mouse_wheel_up" then
            if element == "scrollVehicles" then
                if lineVehicle > 1 then
                    lineVehicle = lineVehicle - 1
                end
            elseif element == "scrollCarshopVehicles" then
                if lineCarshopVehicle > 1 then
                    lineCarshopVehicle = lineCarshopVehicle - 1
                end
            elseif element == "scrollPlayers" then
                if linePlayer > 1 then
                    linePlayer = linePlayer - 1
                end
            elseif element == "scrollRanks" then
                if lineRanks > 1 then
                    lineRanks = lineRanks - 1
                end
            end
        end
    end
end

function checkCursor()
	if not guiGetInputEnabled() and not isMTAWindowActive() and isCursorShowing() then
		return true
	else
		return false
	end
end

--local FONT = exports.ex_core:getFont("roboto.ttf")
--local FONT =  exports.sarp_assets:loadFont("Roboto-Regular.ttf", 20, false, "antialiased")
local FONT =  dxCreateFont("files/Roboto.ttf", 20, false, "antialiased")

function tooltip(text, text2)
	if checkCursor() then
        sx, sy = screenW, screenH
		local x,y = getCursorPosition()
		local x,y = x * sx, y * sy
		text = tostring(text)
		if text2 then
			text2 = tostring(text2)
		end
        
		if text == text2 then
			text2 = nil
		end
		
		local width = dxGetTextWidth(text, 1, "clear") + 20
		if text2 then
			width = math.max(width, dxGetTextWidth( text2, 1, "clear") + 20)
			text = text .. "\n" .. text2
		end
        
		local height = 10 * (text2 and 5 or 3)
		local x = math.max(10, math.min(x, sx-width - 10))-width/2
		local y = math.max(10, math.min(y, sy-height - 10))-height-5

		dxDrawImage(x, y, width, height, "files/img/tooltip_bg.png", 0, 0, 0, nil, true)
		dxDrawImage(x+width/2-7, y+height, 14, 4, "files/img/tooltip_arrow.png", 0, 0, 0, nil, true)
		dxDrawText(text, x, y, x + width, y + height, tocolor(255,255,255,255), 0.42, FONT, "center", "center", false, false, true)
	end
end

function remove()
    removeEventHandler("onClientRender", getRootElement(), renderEnterprise)
    removeEventHandler("onClientClick", getRootElement(), click)
    removeEventHandler("onClientKey", getRootElement(), key)
    show = false
    showCursor(false)
    showChat(true)
    triggered = false
end
    
local carshopIDToEnterPriseID = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,
    [10] = 10,
    [11] = 11,
    [12] = 12,
    [13] = 13,
}

addEvent("client->getEnterprises", true)
addEventHandler("client->getEnterprises", getRootElement(), function(temp, keyed, update, vehs)
    if keyed then
        if show then
            remove()
            return
        end
    end
    
    selectedEnt = 1
    selectedPage = 1
    lineVehicle = 1
    linePlayer = 1
    lineRanks = 1
    lineCarshopVehicle = 1
    lineStorage = 1
    editBoxes = {}
    editBoxes["playerName"] = ""
    editBoxes["rankName"] = ""
    editBoxes["rankMoney"] = ""
    editBoxes["moneyIN"] = ""
    editBoxes["moneyOUT"] = ""
    success = false
    showPermissionPanel = false

    selectedVehicle = 0
    selectedMember = 0
    selectedRank = 0
    members = {}
    carshopVehicles = {}
    vehicles = {}
    enterprises = {}
    storage = {}
    pcache = getOnlinePlayerCache()
         
    if update and not show then
        return
    end
        
    --outputConsole(inspect(temp))

    for i, k in pairs(temp) do
        local id = i
        local veh = {}
        local veh = vehs
        local membersTemp = temp[id]["members"]
        local storageTemp = temp[id]["storage"]
        
        if not members[id] then
            members[id] = {}
        end

        if not vehicles[id] then
            vehicles[id] = {}
            --print("PINA " .. id)
        end
        --print("FASZ")
            
        if not storage[id] then
            storage[id] = {}
        end
            
        storage[id] = storageTemp
            
        for j=1, #membersTemp do
            if membersTemp[j]["account"] == (getElementData(localPlayer, "char.ID")) then
                success = true
                table.insert(enterprises, k)

                --print("a1")
                if k["type"] == 4 then
                    --print("a2")
                    if not carshopVehicles[id] then
                        carshopVehicles[id] = {}
                        --rint("a3")
                    end
                    for k, i in pairs(vehs) do
                        
                        --print("veh: " .. id .. " -> " .. getElementData(k, "veh:CarshopID") .. " -> " .. carshopIDToEnterPriseID[tonumber(getElementData(k, "veh:CarshopID")) or 0])
                        if carshopIDToEnterPriseID[tonumber(getElementData(k, "veh:CarshopID")) or 0] == id then
                            table.insert(carshopVehicles[id], {
                                element = k,
                                dbid = getElementData(k, "vehicle.dbID"),
                                model = getElementModel(k),
                                engine = getElementData(k, "veh:Engine"),
                                light = getElementData(k, "veh:Lights"),
                                airride = getElementData(k, "veh:AirRide") or false,
                                neon = getElementData(k, "veh:Neon") or false,
                                upgrade1 = getElementData(k, "veh:Level1") or 0,
                                upgrade2 = getElementData(k, "veh:Level2") or 0,
                                upgrade3 = getElementData(k, "veh:Level3") or 0,
                                chip = getElementData(k, "veh:Chip") or false,
                            })
                        end
                    end
                end
                if membersTemp[j]["charactername"] ~= getElementData(localPlayer, "char.Name") then
                    membersTemp[j]["charactername"] = getElementData(localPlayer, "char.Name")
                    triggerServerEvent("server->changePlayerName", localPlayer, id, j, getElementData(localPlayer, "char.Name"))
                end
            end

            if pcache[membersTemp[j]["charactername"]] then
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
                    
                membersTemp[j]["lastlogin"] = year.."-"..month.."-"..day.." "..hour..":"..minute..":"..second
                triggerServerEvent("server->updateLastLogin", resourceRoot, id, j)
            end
            table.insert(members[id], membersTemp[j])
        end
    end
    
    if not success then
        if show then
            remove()
        end
        exports.sarp_hud:showAlert("error","Te nem vagy egy vállalkozás tagja sem!")
        return
    end

    for i, k in pairs(getElementsByType("vehicle")) do
        local ent = getElementData(k, "veh:Enterprise") or 0
        if ent > 0 then
            if not vehicles[ent] then
                vehicles[ent] = {}
            end
            table.insert(vehicles[ent], {
                element = k,
                dbid = getElementData(k, "vehicle.dbID"),
                model = getElementModel(k),
                engine = getElementData(k, "veh:Engine"),
                light = getElementData(k, "veh:Lights"),
                airride = getElementData(k, "veh:AirRide") or false,
                neon = getElementData(k, "veh:Neon") or false,
                upgrade1 = getElementData(k, "veh:Level1") or 0,
                upgrade2 = getElementData(k, "veh:Level2") or 0,
                upgrade3 = getElementData(k, "veh:Level3") or 0,
                chip = getElementData(k, "veh:Chip") or false,
            })
        end
    end
    
    checkLeader()
        
    if not triggered then
        triggered = true
        addEventHandler("onClientRender", getRootElement(), renderEnterprise)
        addEventHandler("onClientClick", getRootElement(), click)
        addEventHandler("onClientKey", getRootElement(), key)

        show = true
        showCursor(true)
        showChat(false)
    end
end)

function checkLeader()
    local ent = enterprises[selectedEnt]["id"]
    local dbid = getElementData(localPlayer, "char.ID")
    for i, k in pairs(members[ent]) do
        if k["account"] == dbid then
            if k["leader"] == 1 then
				-- if not exports.ex_core:hasAchievement(localPlayer, 11) then
				-- 	exports.ex_core:addAchievement(localPlayer, 11)
				-- end
                isLeader = true
                return
            end
        end
    end
    isLeader = false
end

function isInSlot(xS,yS,wS,hS)
    if isCursorShowing() then
        XY = {guiGetScreenSize()}
        local cursorX, cursorY = getCursorPosition()
        cursorX, cursorY = cursorX*XY[1], cursorY*XY[2]
        if isInBox(xS,yS,wS,hS, cursorX, cursorY) then
            return true
        else
            return false
        end
    end 
end

function isInBox(dX, dY, dSZ, dM, eX, eY)
    if eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM then
        return true
    else
        return false
    end
end