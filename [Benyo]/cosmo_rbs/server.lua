local sObject = {}
local maxRoadBlock = 1000

addEvent("createObjectToServer", true)
addEventHandler("createObjectToServer", root, function (player, objectID, x, y, z, rot)
	local id = 0
	for i = 1, maxRoadBlock do 
		if (sObject[i] == nil) then 
			sObject[i] = createObject(objectID, x, y, z-0.21, 0, 0, rot)
			setElementInterior ( sObject[i], getElementInterior ( player ) )
			setElementDimension ( sObject[i], getElementDimension ( player ) )
			setElementData(sObject[i], "object:name", i)
			setElementData(sObject[i], "object:create", getElementData(player, "char >> name"))
			id = i
			break
		end
	end
	if not (id == 0) then
		outputChatBox("#ff9428[CosmoMTA] #FFFFFFRBS létrehozva id:#ff9428 "..id.."#ff9428",player, 255, 255, 255, true)
	else
	end
end)

function removeRoadblock(thePlayer, commandName, id)
    local playerDbid = getElementData(thePlayer,"acc.ID")
    if exports.cosmo_groups:isPlayerInGroup(thePlayer, 1) or exports.cosmo_groups:isPlayerInGroup(thePlayer, 4) or exports.cosmo_groups:isPlayerInGroup(thePlayer, 32) or exports.cosmo_groups:isPlayerInGroup(thePlayer, 33) or exports.cosmo_groups:isPlayerInGroup(thePlayer, 58) then
		if not (id) then
				outputChatBox("#ff9428[CosmoMTA] #ffffff/"..commandName.. " [ID]", thePlayer, 255, 255, 255, true)
		else
			id = tonumber(id)
			if (sObject[id]==nil) then
				outputChatBox("#ff9428[CosmoMTA] #ffffffNincs RBS ezzel az ID-vel.", thePlayer, 255, 255, 255, true)
			else
				local object = sObject[id]
					
				destroyElement(object)
				sObject[id] = nil
				outputChatBox("#ff9428[CosmoMTA] #ffffffSikeresen törölted az útzárat!", thePlayer, 255, 255, 255, true)
			end
		end
	end
end
addCommandHandler("delrbs", removeRoadblock, false, false)

function getNearbyRoadblocks(thePlayer, commandName)
    local playerDbid = getElementData(thePlayer,"acc.ID")
	if exports.cosmo_groups:isPlayerInGroup(thePlayer, 1) or exports.cosmo_groups:isPlayerInGroup(thePlayer, 4) or exports.cosmo_groups:isPlayerInGroup(thePlayer, 32) or exports.cosmo_groups:isPlayerInGroup(thePlayer, 33) or exports.cosmo_groups:isPlayerInGroup(thePlayer, 58) then
		local posX, posY, posZ = getElementPosition(thePlayer)
		local found = false
			
		for i = 1, maxRoadBlock do
			if not (sObject[i]==nil) then
				local x, y, z = getElementPosition(sObject[i])
				local distance = getDistanceBetweenPoints3D(posX, posY, posZ, x, y, z)
				if (distance<=10) then
					outputChatBox("#ff9428[CosmoMTA] #FFFFFFKözeledben levő RBS: "..i.."#ff9428",thePlayer, 255, 255, 255, true)
					found = true
				end
			end
		end
			
		if not (found) then
			outputChatBox("#ff9428[CosmoMTA] #FFFFFFNincs RBS a közeledben.",thePlayer, 255, 255, 255, true)
		end
	end
end
addCommandHandler("nearbyrbs", getNearbyRoadblocks, false, false)
