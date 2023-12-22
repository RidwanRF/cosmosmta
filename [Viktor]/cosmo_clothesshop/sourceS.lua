local connection = false

addEventHandler("onDatabaseConnected", getRootElement(),
	function (db)
		connection = db
	end
)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.cosmo_database:getConnection()
	end
)

addEvent("tryToBuyCloth", true)
addEventHandler("tryToBuyCloth", getRootElement(),
	function (model, price)
		if isElement(source) then
			local currentBalance = exports.cosmo_core:getMoney(source) or 0

			if currentBalance - price >= 0 then
				local characterId = getElementData(source, "char.ID")
				local boughtClothes = getElementData(source, "boughtClothes") or ""
				
				boughtClothes = fromJSON(boughtClothes) or {}
				boughtClothes[model] = true
				boughtClothes = toJSON(boughtClothes, true)

				exports.cosmo_core:takeMoney(source, price, "buycloth")

				setElementData(source, "boughtClothes", boughtClothes)
				dbExec(connection, "UPDATE characters SET boughtClothes = ? WHERE charID = ?", boughtClothes, characterId)

				triggerClientEvent(source, "clothBuyProcessed", source, "success", "Sikeres vásárlás!")
			else
				triggerClientEvent(source, "clothBuyProcessed", source, "error", "Nincs elég pénzed!")
			end
		end
	end
)

addEvent("tryToBuyClothSlot", true)
addEventHandler("tryToBuyClothSlot", getRootElement(),
	function ()
		if isElement(source) then
			local currentBalance = getElementData(source, "char.PP") or 0

			currentBalance = currentBalance - 1000

			if currentBalance  >= 0 then
				local accountId = getElementData(source, "char.accID")
				local characterId = getElementData(source, "char.ID")
				local clothesLimit = getElementData(source, "clothesLimit") or 2

				clothesLimit = clothesLimit + 1

				setElementData(source, "clothesLimit", clothesLimit)
				setElementData(source, "char.PP", currentBalance)

				dbExec(connection, "UPDATE characters SET clothesLimit = ? WHERE charID = ?", clothesLimit, characterId)

				triggerClientEvent(source, "buyTheClothesSlot", source, "success", "Sikeresen vásároltál +1 slotot!")
			else
				triggerClientEvent(source, "buyTheClothesSlot", source, "error", "Nincs elég prémium pontod!")
			end
		end
	end
)

addEvent("onTryToRemoveCloth", true)
addEventHandler("onTryToRemoveCloth", getRootElement(),
	function (targetPlayer, slotName)
		if isElement(source) then
			if isElement(targetPlayer) then
				local targetName = getElementData(targetPlayer, "visibleName"):gsub("_", " ")

				if slotName then
					local currentClothes = getElementData(targetPlayer, "currentClothes") or ""

					currentClothes = fromJSON(currentClothes) or {}
					currentClothes[slotName] = nil

					setElementData(targetPlayer, "currentClothes", toJSON(currentClothes, true))

					outputChatBox("#ff9428[CosmoMTA - Adminruha]:#ffffff Sikeresen levetted #32b3ef" .. targetName .. " #ffffffegy ruhadarabját. #32b3ef(" .. slotName .. ")", source, 255, 255, 255, true)
				end
			end
		end
	end
)

addEvent("onNeededForWaitAim", true)
addEventHandler("onNeededForWaitAim", getRootElement(),
	function (state)
		if isElement(source) then
			if state == "off" then
				setPedAnimation(source, false)
			else
				setPedAnimation(source, "COP_AMBIENT", "Coplook_loop", -1, true, false, false)
			end
		end
	end
)
