--created by tobzoska

local aLastCheck = 0

local tick = getTickCount()

local attachedEffects = {}

local currentBackfire_popcorn = 0

local currentBackfire = 0

local popcorn_vehicles = { --ezekkel birsz popcornozni, ha lenyomva tartod W-S gurulás közben alacsony sebességnél, csak megadod a modell IDjét az indexbe.

    [558] = true, --m3

    [540] = true, --subaru

    [496] = true, --golf 7

    [547] = true, --golf 8

    [545] = true, --m8

    [526] = true, --m4

    [562] = true, --skyline

    [401] = true, --gtr

    [559] = true, --supra

}

addEventHandler("onClientRender", getRootElement(), function()

    if not localPlayer.vehicle then return end

    if getElementData(localPlayer.vehicle,"danihe->tuning->backfire") == 1 and getElementSpeed(localPlayer.vehicle) > 5 then --az első argumentumot cseréld a kocsi datájára

        if (getTickCount() >= aLastCheck) then

            local current = tonumber(getVehicleCurrentGear(localPlayer.vehicle))

            local speed = getElementSpeed(localPlayer.vehicle, 1)

            if localPlayer.vehicleSeat == 0 then

                if getKeyState("w") and getKeyState("s") and tick + 150 < getTickCount() and localPlayer.vehicle.engineState and getElementSpeed(localPlayer.vehicle) < 40 then  

                    if popcorn_vehicles[localPlayer.vehicle.model] then

                        currentBackfire = currentBackfire + 1

                        tick = getTickCount()

                        if (currentBackfire >= 1) then

                            triggerServerEvent("clientBackfire >> create", root, localPlayer.vehicle)

                            currentBackfire = 0
                        end

                    end
                   
                end
            end

            if (current ~= curEngine) then

                if localPlayer.vehicleSeat == 0 then

                    if not getKeyState("w") then --ezt kiveheted ha akarod hogy gázadás közben is durrogjon.

                        triggerServerEvent("clientBackfire >> create", root, localPlayer.vehicle)

                        curEngine = current
    
                    end                  

                end

            end

            aLastCheck = getTickCount() + 20

        end

    end

end)

addEvent("serverBackfire >> create", true)
addEventHandler("serverBackfire >> create", getRootElement(), function(veh) 

    --for k, v in pairs(Element.getAllByType("player")) do

        if veh then

            if not veh then

                return

            end

            local speed = getElementSpeed(veh, 1)

            local x, y, z = getVehicleModelDummyPosition(veh.model, "exhaust")

            local rot1, rot2, rot3 = getVehicleComponentRotation(veh, "chassis_dummy")

            if not rot1 then return end

            local temp_object = Object(1107, 0, 0, 0)

            temp_object:attach(veh, 0, 0, -9999, rot1, rot2, rot3)

            local rot = veh.rotation

            local effectName = "gunflash"

            local effect = createEffect(effectName, 0, 0, 0, -temp_object.rotation - Vector3(90, 180, 0))

            local effect2 = createEffect(effectName, 0, 0, 0, -temp_object.rotation - Vector3(90, 180, 0))

            attachEffect(effect, veh, Vector3(x, y, z + 0.05))

            if isDoubleExhauts(veh) then

                attachEffect(effect2, veh, Vector3(-x, y, z + 0.05))

            end

            local sound = playSound3D("backfire.mp3", veh.position)

            --if veh.model == 558 then

                --local growl = playSound3D("growl.mp3", veh.position)

                --growl:attach(veh)

            --end

            sound:attach(veh)

            sound.volume = 2

            Timer(function()

                if effect then

                    effect:destroy()

                end

                if effect2 then

                    effect2:destroy()

                end

                if sound then

                    sound:destroy()

                end

                if temp_object then

                    temp_object:destroy()

                end

            end, 500, 1)

            local rand = math.random(1, 100)

            if (rand > 40) then

                setTimer(function()

                    if speed > 200 then --ha kettőszáz felett megy, és elengeded a gázt, akkor 60%esély van rá hogy nagy lángot köp és durran.

                        local sound2 = playSound3D("kickback.mp3", veh.position)

                        sound2:attach(veh)

                        sound2.volume = 8

                        local temp_object2 = Object(1107, 0, 0, 0)

                        temp_object2:attach(veh, 0, 0, -9999, rot1, rot2, rot3)

                        local kickback_effect = "fire"

                        local effect3 = createEffect(kickback_effect, 0, 0, 0, -temp_object2.rotation - Vector3(90, 180, 0))

                        local effect4 = createEffect(kickback_effect, 0, 0, 0, -temp_object2.rotation - Vector3(90, 180, 0))

                        attachEffect(effect3, veh, Vector3(x, y, z + 0.05))

                        if isDoubleExhauts(veh) then

                            attachEffect(effect4, veh, Vector3(-x, y, z + 0.05))

                        end

                        Timer(function()

                            if effect3 then
        
                                effect3:destroy()
        
                            end
        
                            if effect4 then
        
                                effect4:destroy()
        
                            end

                            if sound2 then

                                sound2:destroy()
        
                            end
        
                            if temp_object2 then

                                temp_object2:destroy()

                            end
        
                        end, 500, 1)

                    end
                        
                end, 1000, 1)

            end

        --end

    end

end)

--//UTILS (ezeket ne piszkáljátok)

function getPositionFromElementOffset(element, offX, offY, offZ)

    local m = getElementMatrix (element) 

    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  

    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]

    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]

    return x, y, z  

end

function attachEffect(effect, element, pos)

    attachedEffects[effect] = { effect = effect, element = element, pos = pos }

    addEventHandler("onClientElementDestroy", effect, function() attachedEffects[effect] = nil end)

    addEventHandler("onClientElementDestroy", element, function() attachedEffects[effect] = nil end)

    return true

end

addEventHandler("onClientPreRender", root, function()

    for fx, info in pairs(attachedEffects) do

        local x, y, z = getPositionFromElementOffset(info.element, info.pos.x, info.pos.y, info.pos.z)

        setElementPosition(fx, x, y, z)

    end

end)

function getPositionFromElementOffset(element,offX,offY,offZ)

    local m = getElementMatrix ( element )

    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]

    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]

    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]

    return x, y, z

end

function getVectors(x, y, z, x2, y2, z2)

    return x - x2, y - y2, z-z2

end

local bytes = {["2"] = true, ["6"] = true, ["A"] = true, ["E"] = true}

function isDoubleExhauts (veh)

    local handling = getVehicleHandling (veh)["modelFlags"]

    local newHandling = string.format ("%X", handling)

    local reversedHex = string.reverse ( newHandling )..string.rep ( "0", 8 - string.len ( newHandling ) )
    
    local byte4 = string.sub(reversedHex, 4, 4)

    if bytes[byte4] then

        return true

    else

        return false

    end

end

function getElementSpeed(theElement, unit)

    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")

    local elementType = getElementType(theElement)

    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")

    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")

    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))

    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)

    return (Vector3(getElementVelocity(theElement)) * mult).length

end

