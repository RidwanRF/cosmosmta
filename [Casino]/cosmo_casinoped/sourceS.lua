local connection = false

addEventHandler("onDatabaseConnected", getRootElement(),
	function (db)
		connection = db
	end)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.cosmo_database:getConnection()

		dbQuery(
			function (qh)
				local result = dbPoll(qh, 0)

				if result then
					for i, v in ipairs(result) do
						loadPed(v.pedId, v)
					end
				end
			end,
		connection, "SELECT * FROM casinopeds")
	end)

function loadPed(id, data)
	local ped = createPed(data.skinId, data.posX, data.posY, data.posZ, data.rotZ, false)

	setElementInterior(ped, data.interior)
	setElementDimension(ped, data.dimension)
	setElementFrozen(ped, true)

	setElementData(ped, "invulnerable", true)
	setElementData(ped, "visibleName", data.name)
	setElementData(ped, "currencyPed", id)
	setElementData(ped, "pedNameType", "Zseton váltó")
end

addEvent("buySlotCoin", true)
addEventHandler("buySlotCoin", getRootElement(),
	function (amount)
		if isElement(source) then
			if exports.cosmo_core:takeMoney(source, amount * 250, eventName) then
				local currentBalance = getElementData(source, "char.ucoin") or 0

				setElementData(source, "char.ucoin", currentBalance + amount)

				exports.cosmo_hud:showInfobox(source, "success", "Sikeres vásárlás!")
			else
				exports.cosmo_hud:showInfobox(source, "error", "Nincs elég pénzed!")
			end
		end
	end)

addEvent("sellSlotCoin", true)
addEventHandler("sellSlotCoin", getRootElement(),
	function (amount)
		if isElement(source) then
			local slotCoins = getElementData(source, "char.ucoin") or 0

			if slotCoins - amount >= 0 then
				local currentBalance = getElementData(source, "char.Money") or 0

				setElementData(source, "char.ucoin", slotCoins - amount)
				setElementData(source, "char.Money", currentBalance + amount * 250)

				exports.cosmo_hud:showInfobox(source, "success", "Sikeres eladtál " .. amount .. " zsetont " .. amount * 250 .. " $ értékben!")
			else
				exports.cosmo_hud:showInfobox(source, "error", "Nincs ennyi coinod!")
			end
		end
	end)

addCommandHandler("createcasinoped",
	function (sourcePlayer, commandName, skinId, ...)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 9 then
			skinId = tonumber(skinId)

			if not (skinId and (...)) then
				outputChatBox("#ff9428[Használat]: #ffffff/" .. commandName .. " [Skin ID] [Név]", sourcePlayer, 0, 0, 0, true)
			else
				local allSkins = getValidPedModels()
				local result = false

				for i = 1, #allSkins do
					if allSkins[i] == skinId then
						result = true
						break
					end
				end

				if result then
					local name = table.concat({...}, " ")
					local x, y, z = getElementPosition(sourcePlayer)
					local rz = select(3, getElementRotation(sourcePlayer))
					local int = getElementInterior(sourcePlayer)
					local dim = getElementDimension(sourcePlayer)

					dbExec(connection, "INSERT INTO casinopeds (posX, posY, posZ, rotZ, interior, dimension, skinId, name) VALUES (?,?,?,?,?,?,?,?)", x, y, z, rz, int, dim, skinId, name:gsub(" ", "_"))
					dbQuery(
						function (qh)
							local result = dbPoll(qh, 0)[1]

							if result then
								loadPed(result.pedId, result)

								if isElement(sourcePlayer) then
									outputChatBox("#ff9428[CosmoMTA]: #ffffffSikeresen létrehoztál egy kaszínó pedet. #32b3ef(" .. result.pedId .. ")", sourcePlayer, 0, 0, 0, true)
								end
							end
						end,
					connection, "SELECT * FROM casinopeds WHERE pedId = LAST_INSERT_ID()")
				else
					outputChatBox("#d75959[CosmoMTA]: #ffffffÉrvénytelen skin id.", sourcePlayer, 0, 0, 0, true)
				end
			end
		end
	end)