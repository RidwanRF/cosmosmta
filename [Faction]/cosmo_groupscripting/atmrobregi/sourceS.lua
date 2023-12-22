local atmTimers = {}

addEvent("startATMRob", true)
addEventHandler("startATMRob", root,
	function(player, atm)
		setPedAnimation(player, "SWORD", "sword_IDLE")
		setElementData(atm, "atm.robbery", true)
		setElementData(atm, "atm.robberyInUse", true)
		setElementData(atm, "atm.health", 100)

		setElementModel(atm, 2942)
		
		local x, y, z = getElementPosition(player)
		local zName = getZoneName(x, y, z)
		
		for i, v in ipairs(getElementsByType("player")) do
			if getElementData(v, "loggedIn") then
				if exports.cosmo_groups:isPlayerHavePermission(v, "cuff") then
					outputChatBox("#ff9428[CosmoMTA - ATM]: #ffffffFigyelem! Egy #d75959ATM #ffffffrablás alatt! (#32b3ef"..zName.."#ffffff).", v, 255, 255, 255, true)
				end
			end
		end
		
		atmTimers[atm] = setTimer(
			function(atm)
				if atm and isElement(atm) then
					setElementModel(atm, 2942)

					setElementData(atm, "atm.robbery", false)
					setElementData(atm, "atm.robberyInUse", false)
					setElementData(atm, "atm.health", 100)	
				end 		
			end,
		(60*60)*5, 1, atm)
	end
)

addEvent("atmRobContinue", true)
addEventHandler("atmRobContinue", root,
	function(player, atm)
		setPedAnimation(player, "SWORD", "sword_IDLE")
		setElementData(atm, "atm.robberyInUse", true)
	end
)

addEvent("stopATMRob", true)
addEventHandler("stopATMRob", root,
	function(player, atm)
		setPedAnimation(player)

		if atm and isElement(atm) and tonumber(atm:getData("atm.health") or 0) == 0 then 
			setElementModel(atm, 2943)
		end
	end
)

addEvent("syncEffect", true)
addEventHandler("syncEffect", root,
	function(object, player)
		local pPos = {getElementPosition(player)}
		local rPos = {getPositionInfrontOfElement(player, 1)}
		
		triggerClientEvent(getElementsByType("player"), "createEffects", source, object, pPos, rPos, player)
	end
)

addEvent("removeEffectSync", true)
addEventHandler("removeEffectSync", root,
	function(object)
		triggerClientEvent(getElementsByType("player"), "removeEffect", source, object)
	end
)

addEvent("playATMSound3d", true)
addEventHandler("playATMSound3d", getRootElement(),
	function (sendTo, sourceElement, ...)
		sendTo = sendTo or root

		triggerClientEvent(sendTo, "playATMSound3d", sourceElement, ...)
	end
)

addEvent("destroyATMSound3d", true)
addEventHandler("destroyATMSound3d", getRootElement(),
	function (sendTo, sourceElement, ...)
		sendTo = sendTo or root

		triggerClientEvent(sendTo, "destroyATMSound3d", sourceElement, ...)
	end
)

addEvent("addCasette", true)
addEventHandler("addCasette", root,
	function(player)
		if isElement(player) then
			setPedAnimation(player, "bomber", "bom_plant", 1000, false, false, false, false)

			exports.cosmo_inventory:giveItem(player, 181, 1, nil, nil, nil)
		end
	end
)

function getPositionInfrontOfElement ( element , meters ) 
    if not element or not isElement ( element ) then 
        return false 
    end 
    if not meters then 
        meters = 3 
    end 
    local posX , posY , posZ = getElementPosition ( element ) 
    local _ , _ , rotation = getElementRotation ( element ) 
    posX = posX - math.sin ( math.rad ( rotation ) ) * meters 
    posY = posY + math.cos ( math.rad ( rotation ) ) * meters 
    return posX , posY , posZ 
end 