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