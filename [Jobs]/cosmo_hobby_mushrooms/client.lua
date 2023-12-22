exports.cosmo_compiler_job:loadCompliedModel(8003, "rS)#49WmJ&c/R!rH", ":cosmo_hobby_mushrooms/files/mushroom1dff.cosmomodel", ":cosmo_hobby_mushrooms/files/mushroomstxd.cosmomodel", false, false)
exports.cosmo_compiler_job:loadCompliedModel(8002, "rS)#49WmJ&c/R!rH", ":cosmo_hobby_mushrooms/files/mushroom2dff.cosmomodel", ":cosmo_hobby_mushrooms/files/mushroomstxd.cosmomodel", false, false)
exports.cosmo_compiler_job:loadCompliedModel(8470, "rS)#49WmJ&c/R!rH", ":cosmo_hobby_mushrooms/files/mushroom3dff.cosmomodel", ":cosmo_hobby_mushrooms/files/mushroomstxd.cosmomodel", false, false)
exports.cosmo_compiler_job:loadCompliedModel(8466, "rS)#49WmJ&c/R!rH", ":cosmo_hobby_mushrooms/files/mushroom4dff.cosmomodel", ":cosmo_hobby_mushrooms/files/mushroomstxd.cosmomodel", false, false)
exports.cosmo_compiler_job:loadCompliedModel(8857, "rS)#49WmJ&c/R!rH", ":cosmo_hobby_mushrooms/files/mushroom5dff.cosmomodel", ":cosmo_hobby_mushrooms/files/mushroomstxd.cosmomodel", false, false)

local inCol = false

local occupiedCol = false
local occupiedColMushroom = false
local occupiedColType = 0

local startedPicking= false

local progressbar_datas = {"nan", 0}
local tick = getTickCount()

local roboto = false

function createFont()
    roboto = dxCreateFont("files/lunabar.ttf", 14, false, "antialiased")
end

function destroyFont()
    if isElement(roboto) then
        destroyElement(roboto)
        roboto = false
    end
end

addEventHandler("onClientColShapeHit", root, function(element, mdim)
    if mdim then 
        if element == localPlayer then 
            if getElementData(source, "mushroom:type") then 
                if not inCol then 
                    inCol = true
                    occupiedColMushroom = getElementData(source, "mushroom:object")
                    occupiedColType = getElementData(source, "mushroom:type")
                    occupiedCol = source
                    addEventHandler("onClientRender", root, interactionRender)
                    bindKey("e", "up", pickUpMushroom)
                    createFont()
                end
            end
        end
    end
end)

addEventHandler("onClientColShapeLeave", root, function(element, mdim)
    if mdim then 
        if element == localPlayer then 
            if getElementData(source, "mushroom:type") then 
                if inCol then 
                    inCol = false
                    occupiedCol = false
                    removeEventHandler("onClientRender", root, interactionRender)
                    unbindKey("e", "up", pickUpMushroom)
                    destroyFont()
                end
            end
        end
    end
end)

local sx, sy = guiGetScreenSize()
local myX, myY = 1600, 900

function interactionRender()
    if not isElement(occupiedCol) then 
        inCol = false
        occupiedCol = false
        removeEventHandler("onClientRender", root, interactionRender)
        unbindKey("e", "up", pickUpMushroom)
    end

    dxDrawText("A gomba felvételéhez nyomd meg az #ff9428[E] #ffffffgombot.", 0, sy*0.89, sx, sy*0.89+sy*0.05, tocolor(255, 255, 255, 230), 1, roboto, "center", "center", false, false, false, true)
end

local progressBarAnimType = "open"
local progressBarAnimTick = getTickCount()
function renderProgressBar()
    local alpha
    
    if progressBarAnimType == "open" then 
        alpha = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount() - progressBarAnimTick)/250, "Linear")
    else
        alpha = interpolateBetween(1, 0, 0, 0, 0, 0, (getTickCount() - progressBarAnimTick)/250, "Linear")
    end

    local line_height = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount() - tick)/progressbar_datas[2], "Linear")

    dxDrawRectangle(sx*0.4, sy*0.85, sx*0.2, sy*0.02, tocolor(0, 0, 0, 130))
    dxDrawRectangle(sx*0.401, sy*0.852, (sx*0.2-sx*0.002), sy*0.02-sy*0.004, tocolor(0, 0, 0, 100))
    dxDrawRectangle(sx*0.401, sy*0.852, (sx*0.2-sx*0.002)*line_height, sy*0.02-sy*0.004, tocolor(255, 148, 40))

    dxDrawText(progressbar_datas[1], sx*0.4, sy*0.85, sx*0.4+sx*0.2, sy*0.85+sy*0.02, tocolor(255, 255, 255, 230), 1, roboto, "center", "center", false, false, false, true)
end

local lastItemGive = 0
function pickUpMushroom()
    if not getPedOccupiedVehicle(localPlayer) then 
        if getElementData(occupiedCol, "mushroom:pickedup") then return end
        if startedPicking then return end 
        startedPicking = true
        setElementData(localPlayer, "mushroom:mushroomPickingUp", true)
        setElementData(occupiedCol, "mushroom:pickedup", true)
        triggerServerEvent("mushroom > startPickup", resourceRoot, occupiedCol)
        inCol = false
        occupiedCol = false
        removeEventHandler("onClientRender", root, interactionRender)
        unbindKey("e", "up", pickUpMushroom)
        setElementFrozen(localPlayer, true)

        tick = getTickCount()
        progressbar_datas = {"Gomba felszedése", 8000}
        progressBarAnimType = "open"
        progressBarAnimTick = getTickCount()

        addEventHandler("onClientRender", root, renderProgressBar)

        triggerServerEvent("mushroom > setAnimation", resourceRoot, "BOMBER", "BOM_Plant")

        setTimer(function()
            startedPicking = false
            setElementData(localPlayer, "mushroom:mushroomPickingUp", false)

            setElementFrozen(localPlayer, false)
            progressBarAnimType = "close"
            progressBarAnimTick = getTickCount()    
            
            if lastItemGive + 7000 < getTickCount() then
                lastItemGive = getTickCount()
                triggerServerEvent("mushroom > endMushroomPickup", resourceRoot, occupiedColMushroom, occupiedColType, {getElementPosition(occupiedColMushroom)}, true)
                exports.cosmo_chat:sendLocalMeAction(localPlayer, "felvett egy "..(mushroom_types[occupiedColType].name).."-(e)t.")
            else
                lastItemGive = getTickCount()
                triggerServerEvent("mushroom > endMushroomPickup", resourceRoot, occupiedColMushroom, occupiedColType, {getElementPosition(occupiedColMushroom)}, false)
                exports.cosmo_chat:sendLocalMeAction(localPlayer, "felvett egy "..(mushroom_types[occupiedColType].name).."-(e)t.")
            end

            setTimer(function() removeEventHandler("onClientRender", root, renderProgressBar) end, 250, 1)
        end, 8000, 1)
    end
end

function hasPlayerFish(itemID)
    if exports.cosmo_inventory:hasItem(itemID) then
        return true
    else
        return false
    end
end

function hasFish(itemID)
    return exports.cosmo_inventory:countItemsByItemID(itemID,true)
end

function takeFish(itemID, itemCount)
    local haveItem = exports.cosmo_inventory:hasItem(itemID)
    if haveItem then
        triggerServerEvent("takeItem",localPlayer,localPlayer,"itemId",haveItem.itemId,itemCount)
    end
end

addEventHandler("onClientColShapeHit", getRootElement(),
    function(player)
        if player ~= getLocalPlayer() then return end
        if source and getElementData(source, "sell:Mushrooms") then 
            getPlayerItem()
        end
    end
)

local fishIds = {
        {264, 130000},
        {265, 130000},
        {266, 150000},
        {267, 150000},
        {268, 180000}
}

function getPlayerItem()
    for key, value in ipairs(fishIds) do
        if hasPlayerFish(value[1]) then
            if hasFish(value[1]) >= 1 then
                takeFish(value[1], hasFish(value[1]))
                local cost = hasFish(value[1])*value[2]
                triggerServerEvent("giveMoneyMushrooms",localPlayer,localPlayer,cost)
            end
        end
    end
end