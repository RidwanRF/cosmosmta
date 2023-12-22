local state = false;


function check ()
    if getPedOccupiedVehicle(localPlayer) then
        local veh = getPedOccupiedVehicle(localPlayer);   
        local speed = getElementSpeed(veh, 1) 
        if speed > 80 then
            enableCrosshair(false)
            exports.cosmo_hud:showInfobox("error", "80 km/h fölött nem tudsz pullozni!")
        end 
        if getElementData(localPlayer,"pulling") then 
            local veh = getPedOccupiedVehicle(localPlayer);
            if veh then 
                if getElementData(veh,"vehicle.window.") then 
                    enableCrosshair(false);
                end
            else 
                enableCrosshair(false);
            end
        end
    end
end 

function enableCrosshair(state)
   setPlayerHudComponentVisible("crosshair", true)
    setPedDoingGangDriveby(localPlayer, state);
    setElementData(localPlayer,"pulling",state);
    if state then 
        removeEventHandler("onClientRender",root,check);
        addEventHandler("onClientRender",root,check);
    else 
        removeEventHandler("onClientRender",root,check);

    end
end

function bind()
    if isPedInVehicle(localPlayer) then 
        local seat = getPedOccupiedVehicleSeat(localPlayer);
        local veh = getPedOccupiedVehicle(localPlayer);
        if seat > 0 then
                if (getPedWeapon(localPlayer) < 39) then -- Fegyverek tiltása pullnál
                    state = not state;
                    enableCrosshair(state); 
                else 
                 outputChatBox("Ezzel a fegyverrel nem hajolhatsz ki")
                end
            end
        end
    end

addEventHandler("onClientElementDataChange",localPlayer,function(dataName,old,new)
    if dataName == "weaponusing" then 
        if not new then 
            enableCrosshair(false);
        end
    end
end);

bindKey("x","down",bind);


function getElementSpeed(theElement, unit)
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end