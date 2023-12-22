local bone = getElementData(localPlayer, "char.bone") or {true, true, true, true, true};

render.bone = function (x, y)
    local w,h = 50, 50
    local x, y = x - 10, y
    --dxDrawImage(x - 2, y - 2, w + 4, h + 4, "hud/files/bone.png", 0,0,0, tocolor(0,0,0,255));
    dxDrawImage(x, y, w, h, "widgets/bone/files/bone.png", 0,0,0, tocolor(255,255,255,255));
    if not bone[2] then
        dxDrawImage(x, y, w, h, "widgets/bone/files/injureLeftArm.png", 0,0,0, tocolor(255,255,255,255));
    end
    if not bone[3] then
        dxDrawImage(x, y, w, h, "widgets/bone/files/injureRightArm.png", 0,0,0, tocolor(255,255,255,255));
    end
    if not bone[4] then
        dxDrawImage(x-0.5, y, w, h, "widgets/bone/files/injureLeftFoot.png", 0,0,0, tocolor(255,255,255,255));
    end
    if not bone[5] then
        dxDrawImage(x, y, w, h, "widgets/bone/files/injureRightFoot.png", 0,0,0, tocolor(255,255,255,255));
    end
end 

addEventHandler("onClientElementDataChange", localPlayer, 
    function(dName, oValue, nValue)
        if dName == "char.bone" then
            bone = getElementData(localPlayer, "char.bone") or {true, true, true, true, true};
            return
        end
    end 
)

--[[
char.bone felépítése = {Has, Bal kéz, Jobb kéz, Bal láb, Jobb láb}
]]

local damageTypes = {
	[19] = "Rocket",
	[37] = "Burnt",
	[49] = "Rammed",
	[50] = "Ranover/Helicopter Blades",
	[51] = "Explosion",
	[52] = "Driveby",
	[53] = "Drowned",
	[54] = "Fall",
	[55] = "Unknown",
	[56] = "Melee",
	--[57] = "Weapon",
	[59] = "Tank Grenade",
	[63] = "Blown"
}

local disabledWeapon = {
    --1,2,3,4,5,6,7,14,15,10,11,12
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [7] = true,
    [10] = true,
    [11] = true,
    [12] = true,
    [14] = true,
    [15] = true,
    [19] = true,
    [59] = true,
    [35] = true,
    [36] = true,
    [37] = true,
    [38] = true,
    [39] = true,
    [40] = true,
    [17] = true,
    [41] = true,
    [42] = true,
}

addEventHandler("onClientPlayerDamage", localPlayer,
    function(attacker, weapon, bodypart, loss)
        if not getElementData(localPlayer, "loggedIn") then return end
        if getElementData(localPlayer, "adminDuty") then return end
        if getElementData(localPlayer, "isPlayerDeath") then
            cancelEvent()
            return
        end
        if localPlayer:getData("player.Tazed") then
            return
        end
        if attacker and attacker:getData("tazerState") then return end
        --if getElementType(attacker) == "player" then
        local newBone = getElementData(localPlayer, "char.bone") or {true, true, true, true, true}
        if weapon == 54 then
            if not loss then 
                loss = 0 
            end
            if loss > 10 and loss < 20 then
                if newBone[4] then
                    newBone[4] = false
                    exports.cosmo_hud:showInfobox("warning", "Eltörted a Bal lábadat!")
                else
                    if newBone[5] then
                        newBone[5] = false
                        exports.cosmo_hud:showInfobox("warning", "Eltörted a Jobb lábadat!")
                    end
                end
                setElementData(localPlayer, "char.bone", newBone)
            elseif loss > 20 then
                local d = false
                if newBone[4] then
                    newBone[4] = false
                    d = true
                end
                if newBone[5] then
                    newBone[5] = false
                    d = true
                end
                if d then
                    exports.cosmo_hud:showInfobox("warning", "Eltörted mindkét lábadat a nagy esés következtében!")
                    setElementData(localPlayer, "char.bone", newBone)
                end
            end
        elseif bodypart == 5 then -- Bal kéz
            if newBone[2] then
                local num = tonumber(getElementData(localPlayer, "bone2 >> chance")) or 2 -- "Def: 50%" / Ha ez 4 akk már csak 25
                local chance = math.random(1, num)
                if num == 2 then
                    newBone[2] = false
                    setElementData(localPlayer, "char.bone", newBone)
                    exports.cosmo_hud:showInfobox("warning", "Eltörted a Bal kezedet!")
                    --outputChatBox("Asd")
                end
            end
        elseif bodypart == 6 then -- Jobb kéz
            if newBone[3] then
                local num = tonumber(getElementData(localPlayer, "bone3 >> chance")) or 2 -- "Def: 50%" / Ha ez 4 akk már csak 25
                local chance = math.random(1, num)
                if num == 2 then
                    newBone[3] = false
                    setElementData(localPlayer, "char.bone", newBone)
                    exports.cosmo_hud:showInfobox("warning", "Eltörted a Jobb kezedet!")
                end    
            end
        elseif bodypart == 7 then -- Bal láb
            if newBone[4] then
                local num = tonumber(getElementData(localPlayer, "bone4 >> chance")) or 2 -- "Def: 50%" / Ha ez 4 akk már csak 25
                local chance = math.random(1, num)
                if num == 2 then
                    newBone[4] = false
                    setElementData(localPlayer, "char.bone", newBone)
                    exports.cosmo_hud:showInfobox("warning", "Eltörted a Bal lábadat!")
                end
            end
        elseif bodypart == 8 then -- Jobb láb
            if newBone[5] then
                local num = tonumber(getElementData(localPlayer, "bone5 >> chance")) or 2 -- "Def: 50%" / Ha ez 4 akk már csak 25
                local chance = math.random(1, num)
                if num == 2 then
                    newBone[5] = false
                    setElementData(localPlayer, "char.bone", newBone)
                    exports.cosmo_hud:showInfobox("warning", "Eltörted a Jobb lábadat!")
                end
            end
        end
        --end
    end
)

function getNearestVeh()
    local nearest, nearestE = 9999
    for k,v in pairs(getElementsByType("vehicle", _, true))  do
        local dist = getDistanceBetweenPoints3D(localPlayer.position, v.position)
        if dist <= nearest and dist <= 2.5 then
            nearest = dist
            nearestE = v
        end
    end
    
    return nearest, nearestE
end

function checkPedTask()
    if fight and fightE and isElement(fightE) and fightE.type == "vehicle" then
        local nowHp = fightE.health
        if oldHp ~= nowHp then -- nem egyenlő a 2 érték és legalább 2 hpval kevesebb
            if not getElementData(localPlayer, "loggedIn") then return end
            if getElementData(localPlayer, "adminDuty") then return end
            if getElementData(localPlayer, "isPlayerDeath") then
                cancelEvent()
                return
            end

            if getPedWeapon(localPlayer) ~= 0 then 
                return 
            end

            local x,y,z = getElementPosition(fightE)
            local px,py,pz = getElementPosition(localPlayer)
            local newBone = getElementData(localPlayer, "char.bone") or {true, true, true, true, true}
            if pz > z + 0.5 then
                local attackOnHand = getElementData(localPlayer, "attackOnHand") or 0
                attackOnHand = attackOnHand + 1
                setElementData(localPlayer, "attackOnHand", attackOnHand)
                if attackOnHand >= 2 then
                    if newBone[4] then
                        newBone[4] = false
                        setElementData(localPlayer, "char.bone", newBone)
                        exports.cosmo_hud:showInfobox("warning", "Eltörted a Bal lábad!")
                        setElementData(localPlayer, "attackOnHand", 0)
                    else
                        if newBone[5] then
                            newBone[5] = false
                            setElementData(localPlayer, "char.bone", newBone)
                            exports.cosmo_hud:showInfobox("warning", "Eltörted a Jobb lábad!")
                            setElementData(localPlayer, "attackOnHand", 0)
                        end
                    end
                end
            else
                local attackOnHand = getElementData(localPlayer, "attackOnHand") or 0
                attackOnHand = attackOnHand + 1
                setElementData(localPlayer, "attackOnHand", attackOnHand)
                if attackOnHand >= 2 then
                    if newBone[2] then
                        newBone[2] = false
                        setElementData(localPlayer, "char.bone", newBone)
                        exports.cosmo_hud:showInfobox("warning", "Eltörted a Bal kezedet!")
                        setElementData(localPlayer, "attackOnHand", 0)
                    else
                        if newBone[3] then
                            newBone[3] = false
                            setElementData(localPlayer, "char.bone", newBone)
                            exports.cosmo_hud:showInfobox("warning", "Eltörted a Jobb kezedet!")
                            setElementData(localPlayer, "attackOnHand", 0)
                        end
                    end
                end
            end
        end
        
        fight = false
    end
    
    for k=0,5 do
        local task,b,c,d = getPedTask ( getLocalPlayer(), "secondary", k )
        if task then
            if string.lower(task) == string.lower("TASK_SIMPLE_FIGHT") then
                local target = getPedTarget(localPlayer)
                local dist, veh = getNearestVeh()
                
                if not target or not isElement(target) then
                    target = veh    
                end
                
                if target and isElement(target) then
                    if target.type == "vehicle" then
                        fight = true
                        fightE = target
                        oldHp = fightE.health
                    end
                end
            end
        end
    end
end
setTimer(checkPedTask, 400, 0)

function toggleMoveControls(value)
    exports.cosmo_controls:toggleControl({"forwards", "backwards", "left", "right", "jump", "fire", "aim_weapon", "enter_exit", "action"}, value, value)
end

function boneSync(dName, oValue, nValue)
    if not localPlayer:getData("loggedIn") then 
        return 
    end 
    --outputChatBox(dName)
    if dName == "char.bone" then

        --outputChatBox("asd")
        local value = getElementData(source, dName)
        
        if value[4] or value[5] then -- Bal és Jobb láb megjavult -- Tud mozogni, futni újra
            toggleMoveControls(true) 
        end

        if not value[2] and not value[3] then -- Bal és Jobb kéz eltörve -- Nem tud lőni
            exports.cosmo_controls:toggleControl({"fire", "action"}, false)
            --exports.cosmo_hud:showInfobox("error", "Mivel eltörted mindkét kezed nem tudsz lőni!")
        end

        if value[2] or value[3] then -- Bal és Jobb kéz megjavult -- Tud lőni, célozni újra
            exports.cosmo_controls:toggleControl({"aim_weapon", "action"}, true, true)
        end

        if value[2] and value[3] then
            exports.cosmo_controls:toggleControl({"fire", "action"}, true, true)
        end

        if not value[4] and not value[5] then -- Bal és Jobb láb eltörve -- Nem tud mozogni
            toggleMoveControls(false) 
            --exports.cosmo_hud:showInfobox("error", "Mivel eltörted mindkét kezed nem tudsz mozogni!")
        end

        if value[4] and value[5] then
            exports.cosmo_controls:toggleControl({"sprint", "jump"}, true, true)
        end

        if not value[2] then
            exports.cosmo_controls:toggleControl({"aim_weapon", "action"}, false)
        end

        if not value[3] then
            exports.cosmo_controls:toggleControl({"aim_weapon", "action"}, false)
        end

        if not value[4] then
            exports.cosmo_controls:toggleControl({"sprint", "jump"}, false)
        end

        if not value[5] then
            exports.cosmo_controls:toggleControl({"sprint", "jump"}, false)
        end
    end
end
addEventHandler("onClientElementDataChange", localPlayer, boneSync)