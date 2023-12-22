local mushroomPositionsServer = {}

local sellPed = {}
local sellCol = {}

local sellPos = {
    {159, -607.80578613281, -1074.2081298828, 23.50373840332, "Gomba felvásárló", 178, 0, 0, 0}
}

function sellFishing(element)
    for key, value in ipairs(fishIds) do
    if exports["cosmo_inventory"]:hasItem(element,value[1],1) then
            exports["cosmo_inventory"]:removeItemByData(element,value[1],1)
            setElementData(element,"char.Money",getElementData(element,"char.Money")+value[2])
        end
    end
    --outputChatBox("#32b3ef[Fishing]#FFFFFF Nincs nálad hal!",element,255,255,255,true)
end
addEvent("sell:Mushrooms", true)
addEventHandler("sell:Mushrooms", root, sellFishing)


function createMushrooms()
    for k, v in ipairs(mushroomPositionsServer) do 
        local randType = math.random(#mushroom_types)
        if math.random(1, 2) == 1 then 
            if math.random(1, (mushroom_types[randType].spawnChance)) == 1  then 
                local obj = createObject(mushroom_types[randType].modelID, v.x, v.y, v.z-1)
                setElementDoubleSided(obj, true)
                setElementRotation(obj, 90, 0, 0)
                setElementCollisionsEnabled(obj, false)

                local col = createColSphere(v.x, v.y, v.z-1, 1.6)
                setElementData(col, "mushroom:object", obj)
                setElementData(col, "mushroom:type", randType)

                table.remove(mushroomPositionsServer, k)
            end
        end
    end
end

addEventHandler("onResourceStart", resourceRoot, function() 
    for index, value in ipairs (sellPos) do 
        if isElement(sellPed[index]) then destroyElement(sellPed[index]) end
        if isElement(sellCol[index]) then destroyElement(sellCol[index]) end
        sellPed[index] = createPed(value[1], value[2], value[3], value[4])
        setPedRotation(sellPed[index], value[6])
        setElementData(sellPed[index], "ped.name", "Gomba felvásárló")        
        --sellCol[index] = createColCuboid(value[2], value[3], value[4],10)
        sellCol[index] = createColCuboid(-609.33996582031, -1076.0512695312, 23.028129577637, 5.5966796875, 5.46875, 2)
        setElementData(sellCol[index], "sell:Mushrooms", true)
        setElementData(sellPed[index], "invulnerable", true)
    end

    mushroomPositionsServer = mushroomPositions
    createMushrooms()

    setTimer(function()
        createMushrooms()
    end, 60000, 1)
end)

addEvent("mushroom > startPickup", true)
addEventHandler("mushroom > startPickup", resourceRoot, function(col)
    destroyElement(col)
end)

addEvent("mushroom > setAnimation", true)
addEventHandler("mushroom > setAnimation", resourceRoot, function(group, name)
    setPedAnimation(client, group, name)
end)    

addEvent("mushroom > endMushroomPickup", true)
addEventHandler("mushroom > endMushroomPickup", resourceRoot, function(obj, type, position, giveitem)
    setPedAnimation(client, "", "")

    local x, y, z = unpack(position)
    z = z + 1

    table.insert(mushroomPositionsServer, Vector3(x, y, z))

    destroyElement(obj)

    if giveitem then
        -- if exports.cosmo_inventory:getInventoryWeight(client) + exports.cosmo_inventory:getItemWeight(mushroom_types[type].item) < 20 then 
        exports.cosmo_inventory:giveItem(client, mushroom_types[type].item, 1, 1, 0)
        -- end
    end
end)  

addEvent("giveMoneyMushrooms",true)
addEventHandler("giveMoneyMushrooms",root,function(player,amount)
    setElementData(player, "char.Money",getElementData(player,"char.Money")+amount)
end)
