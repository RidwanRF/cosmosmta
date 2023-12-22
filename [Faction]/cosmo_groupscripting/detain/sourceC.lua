
local Detain = {}

Detain.TargetPlayer = nil
Detain.TargetVehicle = nil
Detain.Active = false

Detain.ClickHandler = function(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
    if Detain.Active then
        print('1')
        if Detain.TargetPlayer then
            print("Nincs targetPlayer")
            if button == "left" and state == "down" then
                print("2")
                if exports.cosmo_core:inDistance3D(localPlayer, clickedElement, 10) then
                    print("3")
                    if clickedElement ~= localPlayer then
                        print("4")
                        
                        if getElementType(clickedElement) == "vehicle" then
                            Detain.TargetVehicle = clickedElement
                            
                            if isElement(Detain.TargetVehicle) then
                                triggerServerEvent("cosmo_detainS:detainPlayer", localPlayer, Detain.TargetVehicle, Detain.TargetPlayer)
                                removeEventHandler("onClientClick", root, Detain.ClickHandler)
                                Detain.Active = not Detain.Active
                            end
                        end
                    end
                end
            end
        end
    end
end

addEvent("cosmo_detainC:detainMode", true)
addEventHandler("cosmo_detainC:detainMode", root, function(target)
    Detain.Active = not Detain.Active

    if not isElement(target) then
        return
    end
    Detain.TargetPlayer = target

    if Detain.Active then
        outputInfoText("Válaszd ki a cél járművet")
        addEventHandler("onClientClick", root, Detain.ClickHandler)
    end
end)

addCommandHandler("berak", function()
    Detain.Active = not Detain.Active

    if Detain.Active then
        outputInfoText("Berakás mód bekapcsolva")
        addEventHandler("onClientClick", root, Detain.ClickHandler)
    else
        outputInfoText("Berakás mód kikapcsolva")
        removeEventHandler("onClientClick", root, Detain.ClickHandler)
    end
end)

outputErrorText = function(text, element)
    triggerEvent("playClientSound", element, ":cosmo_assets/audio/admin/error.ogg")
	assert(type(text) == "string", "Bad argument @ 'outputErrorText' [expected string at argument 1, got "..type(text).."]")
	outputChatBox(exports.sapr_core:getServerTag("error") .. text, 0, 0, 0, true)
end

outputInfoText = function(text, element)
	assert(type(text) == "string", "Bad argument @ 'outputInfoText' [expected string at argument 1, got "..type(text).."]")
	outputChatBox(exports.cosmo_core:getServerTag("info") .. text, 0, 0, 0, true)
end

local seatNames = {
    [0] = "door_lf_dummy",
    [1] = "door_rf_dummy",
    [2] = "door_lr_dummy",
    [3] = "door_rr_dummy",
}

function removePedFromVehicleFunc(cmd, id)
    if not id then
        outputChatBox(exports.cosmo_core:getServerTag("usage") .. "/" .. cmd .. " [Cselekvés]", 255, 255, 255, true)
        return
    end
    
    local target = exports['cosmo_core']:findPlayer(localPlayer, id)
    
    if target then
        if getElementData(target, "loggedIn") then
            local _target = target
            if target:getData("clone") then
                inspect(target:getData("clone"))
                target = target:getData("clone")
            end
            local veh = getPedOccupiedVehicle(target)
            
            if veh then
                
                local x,y,z = getElementPosition(target)
                local px,py,pz = getElementPosition(localPlayer)
                local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
                local dim1, dim2 = getElementDimension(localPlayer), getElementDimension(target)
                local int1, int2 = getElementInterior(localPlayer), getElementInterior(target)
                
                if dist < 4 and dim1 == dim2 and int1 == int2 then
                    local veh = getPedOccupiedVehicle(target)
                    if veh then
                        if not getElementData(veh, "vehicle.locked") then
                            if not getElementData(target, "player.seatBelt") then
                                if target == localPlayer then
                                    outputChatBox(exports.cosmo_core:getServerTag("error").."Saját magadat nem rángathatod ki!", 255,255,255,true)
                                    
                                    return
                                end
                                
                                local name = getElementData(_target, "visibleName")
                                exports.cosmo_chat:sendLocalMeAction(localPlayer, "kirángott valakit a gépjárműből ((" .. name .. "))")
                                
                                local veh = getPedOccupiedVehicle(target)
                                local comPos = false
                                local seat = nil
                                if veh then
                                    seat = getPedOccupiedVehicleSeat(target)
                                    triggerServerEvent("kickPlayerFromVeh", localPlayer, localPlayer)
                                    local name = seatNames[seat]
                                    local x,y,z = getVehicleComponentPosition(veh, name, "world")
                                    if x and y and z then
                                        comPos = {x,y,z}
                                    end
                                    
                                    if comPos then
                                        x,y,z = unpack(comPos)
                                    else
                                        if getVehicleType(veh) == "BMX" or getVehicleType(veh) == "Bike" then
                                            x,y,z = getElementPosition(veh)
                                            if seat == 0 then
                                                x = x + 0.5
                                                y = y + 0.5
                                            elseif seat == 1 then
                                                x = x - 0.5
                                                y = y - 0.5
                                            end
                                        else
                                            if getElementModel(veh) == 539 or getElementModel(veh) == 457 or getElementModel(veh) == 424 or getElementModel(veh) == 568 then
                                                if seat == 1 then
                                                    x,y,z = getElementPosition(veh)
                                                    x = x + 1
                                                    y = y + 1
                                                elseif seat == 0 then
                                                    x,y,z = getElementPosition(veh)
                                                    x = x - 1
                                                    y = y - 1
                                                end
                                            else
                                                x,y,z = getElementPosition(veh)
                                                x = x + 3
                                                y = y + 3
                                            end    
                                        end
                                    end
                                    z = z + 0.1
                                    
                                    comPos = {x,y,z}
                                end
                            
                                triggerServerEvent("kickPlayerFromVeh", localPlayer, target, comPos)
                                
                                return
                            else
                                local name = getElementData(target, "visibleName")
                                outputChatBox(exports.cosmo_core:getServerTag("error")..name.." biztonsági öve be van csatolva!", 255,255,255,true)
                                
                                return
                            end
                        else
                            outputChatBox(exports.cosmo_core:getServerTag("usage") "A jármű zárva van!", 255,255,255,true)
                            
                            return
                        end
                    end
                end
            else
                local name = getElementData(target, "visibleName")
                outputChatBox(exports.cosmo_core:getServerTag("error")..name.." nincs járműben!", 255,255,255,true)
                
                return
            end
        else
            outputChatBox(exports.cosmo_core:getServerTag("error").."A játékos nincs bejelentkezve!", 255,255,255,true)
        end
    end
end
addCommandHandler("kiszed", removePedFromVehicleFunc)