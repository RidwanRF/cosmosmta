local perishableValue = 420
local sellPed = {}
local sellCol = {}
local sellCol2 = {}

local itemNames = {}
local itemPrices = {
	[201] = 150000,
	[202] = 75000,
	[203] = 75000,
	[204] = 150000,
	[207] = 75000,
	[208] = 75000,
	[209] = 150000,
	[210] = 75000,
	[211] = 75000,
	[212] = 150000,
	[94] = 150000
}

local sellPos = {
	{156, 154.20877075195, -1942.8863525391, 3.7734375, "Hal felvásárló", 0, 0, 0, 0},
	{156, 2133.3176269531, -72.287864685059, 2.7959001064301, "Hal felvásárló", 220, 0, 0, 0},
}

addEventHandler("onResourceStart", getRootElement(),
	function (startedResource)
		if startedResource == getThisResource() then
	for index, value in ipairs (sellPos) do 
		if isElement(sellPed[index]) then destroyElement(sellPed[index]) end
		if isElement(sellCol[index]) then destroyElement(sellCol[index]) end
		if isElement(sellCol2[index]) then destroyElement(sellCol2[index]) end
		sellPed[index] = createPed(value[1], value[2], value[3], value[4])
		setPedRotation(sellPed[index], value[6])
		setElementData(sellPed[index], "ped.name", "Hal felvásárló")		
		--sellCol[index] = createColCuboid(value[2], value[3], value[4],10)
		sellCol[index] = createColCuboid(154.20877075195-2.5, -1942.8863525391-3, 3.7734375-1, 5.5966796875, 5.46875, 2)
		sellCol2[index] = createColCuboid(2133.3176269531-2.5, -72.2878646850591-3, 2.7959001064301-1, 5.5966796875, 5.46875, 2)
		setElementData(sellCol[index], "sell:fishing", true)
		setElementData(sellCol2[index], "sell:fishing", true)
		setElementData(sellPed[index], "invulnerable", true)
	end

			local inventoryResource = getResourceFromName("cosmo_inventory")
			if inventoryResource then
				if getResourceState(inventoryResource) == "running" then
					itemNames = {}

					for itemId in pairs(itemPrices) do
						itemNames[itemId] = exports.cosmo_inventory:getItemName(itemId)
					end
				end
			end
		else
			if getResourceName(startedResource) == "cosmo_inventory" then
				itemNames = {}

				for itemId in pairs(itemPrices) do
					itemNames[itemId] = exports.cosmo_inventory:getItemName(itemId)
				end
			end
		end
	end
)

function sellFishing(element)
	for key, value in ipairs(fishIds) do
	if exports["cosmo_inventory"]:hasItem(element,value[1],1) then
			exports["cosmo_inventory"]:removeItemByData(element,value[1],1)
			setElementData(element,"char.Money",getElementData(element,"char.Money")+value[2])

		end
	end
    --outputChatBox("#32b3ef[Fishing]#FFFFFF Nincs nálad hal!",element,255,255,255,true)
end
addEvent("sell:Fishing", true)
addEventHandler("sell:Fishing", root, sellFishing)

addEvent("throwInRod", true)
addEventHandler("throwInRod", getRootElement(),
	function (waterPosX, waterPosY, waterPosZ)
		if isElement(source) then
			if waterPosX and waterPosY and waterPosZ then
				triggerClientEvent("throwInRod", source, waterPosX, waterPosY, waterPosZ)
				exports.cosmo_chat:sendLocalMeAction(source, "bedobja a horgot a vízbe.")
			end
		end
	end
)

addEvent("endFishing", true)
addEventHandler("endFishing", getRootElement(),
	function (itemId, itemName)
		if isElement(source) then
			triggerClientEvent("endFishing", source, itemId)

			if itemId and itemName then
				if exports.cosmo_inventory:getInventoryWeight(source, itemId) then
					exports.cosmo_inventory:giveItem(source, itemId, 1)

					outputChatBox("#ff9428[CosmoMTA - Horgászat]: #FFFFFFSikeresen fogtál egy #598ed7" .. itemName .. "#FFFFFF-t.", source, 0, 0, 0, true)
					exports.cosmo_chat:sendLocalDoAction(source, "Kifogott valamit: (" .. itemName .. ")")
				else
					outputChatBox("#d75959[CosmoMTA - Horgászat]: #FFFFFFSajnos nincs elég hely az inventorydban, hogy megtartsd a halat.", source, 0, 0, 0, true)
				end
			end

			setElementFrozen(source, false)
			setPedAnimation(source, false)

			exports.cosmo_controls:toggleControl(source, "all", true)
			exports.cosmo_chat:sendLocalMeAction(source, "kihúzza a horgot a vízből.")
		end
	end
)

addEvent("setFishingAnim", true)
addEventHandler("setFishingAnim", getRootElement(),
	function (streamedPlayers)
		if isElement(source) then
			triggerClientEvent(streamedPlayers, "moveDownFloater", source)
			setElementFrozen(source, true)
			setPedAnimation(source, "SWORD", "sword_IDLE")
			exports.cosmo_controls:toggleControl(source, "all", false)
		end
	end
)

addEvent("floaterMoveStopped", true)
addEventHandler("floaterMoveStopped", getRootElement(),
	function (streamedPlayers)
		if isElement(source) then
			triggerClientEvent(streamedPlayers, "floaterMoveStopped", source)
		end
	end
)

addEvent("failTheRod", true)
addEventHandler("failTheRod", getRootElement(),
	function ()
		if isElement(source) then
			local fishingRodInHand = getElementData(source, "fishingRodInHand")
			if fishingRodInHand then
				exports.cosmo_inventory:removeItemByData(source, "dbID", fishingRodInHand)
				setElementData(source, "fishingRodInHand", false)
			end
		end
	end
)

addEvent("playCatchSound", true)
addEventHandler("playCatchSound", getRootElement(),
	function (streamedPlayers)
		if isElement(source) then
			triggerClientEvent(streamedPlayers, "playCatchSound", source)
		end
	end
)

addEvent("giveMoneyFish",true)
addEventHandler("giveMoneyFish",root,function(player,amount)
	setElementData(player, "char.Money",getElementData(player,"char.Money")+amount)
end)
