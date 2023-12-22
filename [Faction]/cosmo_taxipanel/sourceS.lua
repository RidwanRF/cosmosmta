function getVehicleSpeed(element)
	local theVehicle = element
    local vx, vy, vz = getElementVelocity (theVehicle)
    return math.sqrt(vx^2 + vy^2 + vz^2) * 165
end

sirenPos = {
	[445] = {-0.4,0.08, 0.75, 0, 0, 0}, -- M5
	[602] = {-0.4,0.08, 0.95, 0, 0, 0}, -- m4
	[580] = {-0.45,0.02, 0.95, 0, 0, 0}, -- rs4
	[507] = {-0.45,0.02, 0.80, 0, 0, 0}, -- e500
	[400] = {-0.45,0.02, 1.27, 0, 0, 0}, -- SRT8 landstalker
	[458] = {-0.45,-0.22, 0.95, 0, 0, 0}, -- e500
	[550] = {-0.45,0.02, 0.68, 0, 0, 0}, -- e420
	[585] = {-0.45,0.02, 0.95, 0, 0, 0}, -- crown vic
}

local timers = {};

addEvent("taxiclock.start",true);
addEventHandler("taxiclock.start",root,function(player,veh)
    if not timers[veh] then 
        setElementData(veh,"taxiclock.state",true); 
        setElementData(veh,"taxiclock.travelled",0);

        --addVehicleSirens(veh, 1, 2, false, false, false, true)
	   -- setVehicleSirens(veh, 1, sirenPos[getElementModel(veh)][1], sirenPos[getElementModel(veh)][2], sirenPos[getElementModel(veh)][3]-0.0, 255, 166, 0, 255, 255)

        timers[veh] = setTimer(function()
            if isElement(veh)  then 
                if getElementData(veh,"taxiclock.state") then 
                    local kmh = getVehicleSpeed(veh);
                    if kmh > 0 then 
                        local current = (getElementData(veh,"taxiclock.travelled") or 0);
                        setElementData(veh,"taxiclock.travelled",current + (kmh/720));
                        
                    end
                end
            else 
                killTimer(timers[veh]);
                timers[veh] = false;
            end
        end,1,0);
    end
end);

addEvent("taxiclock.stop",true);
addEventHandler("taxiclock.stop",root,function(player,veh)
    if timers[veh] then 
        killTimer(timers[veh]);
        timers[veh] = false;
    end
    setElementData(veh,"taxiclock.state",false); 
end);

addEvent("taxiclock.reset",true);
addEventHandler("taxiclock.reset",root,function(player,veh)
    --setElementData(veh,"taxiclock.state",false);
    setElementData(veh,"taxiclock.travelled",0);
end);

function syncPrint(vehicle, players, task)
    triggerClientEvent(getVehicleOccupants(vehicle), "playTaxiSound", vehicle, "simple", "files/taxiprint.mp3")
    
    --outputChatBox("#ffa500[HealMTA - Taxi]: #ffffffA fizetéshez használd a #ffa500/paytaxi#ffffff parancsot!", players, 255, 255, 255, true)
    
end 
addEvent("syncPrint", true)
addEventHandler("syncPrint", root, syncPrint)

function syncButton(vehicle, players, task)
    triggerClientEvent(getVehicleOccupants(vehicle), "playTaxiSound", vehicle, "simple", "files/taxibutton.mp3")
end 
addEvent("syncButton", true)
addEventHandler("syncButton", root, syncButton)

addEvent("taxiclock.paytaxi",true);
addEventHandler("taxiclock.paytaxi",root,function(player,veh,driver,cost)
    setElementData(driver,"char.Money",getElementData(driver,"char.Money") + cost);
    setElementData(player,"char.Money",getElementData(player,"char.Money") - cost);

    if isTimer(timers[veh]) then 
        killTimer(timers[veh]);
    end
    timers[veh] = false;
    setElementData(veh,"taxiclock.state",false);
    setElementData(veh,"taxiclock.travelled",0);
    
    local playerName = getPlayerName(player)
    local driverName = getPlayerName(driver)
    triggerClientEvent(root, "paytaxiChat", root, playerName:gsub("_", " ") .. " kifizette a fuvardíjat.")
    triggerClientEvent(root, "paytaxiChat", root, "Sofőr: " .. driverName:gsub("_", " ") .. ".")
    triggerClientEvent(root, "paytaxiChat", root, "Összeg: " .. math.floor(tostring(cost)) .. " $.")
end);