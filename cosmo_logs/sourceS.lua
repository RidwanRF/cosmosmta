local connection = false

addEventHandler("onResourceStart", getRootElement(),
	function (startedResource)
		if getResourceName(startedResource) == "cosmo_database" then
			connection = exports.cosmo_database:getConnection()
		elseif source == getResourceRootElement() then
			local cosmo_database = getResourceFromName("cosmo_database")

			if cosmo_database and getResourceState(cosmo_database) == "running" then
				connection = exports.cosmo_database:getConnection()
			end
		end
	end
)

function toLog(type, str)
	return dbExec(connection, "INSERT INTO logs (type, logstring) VALUES (?,?)", type, str)
end

function logEconomy(playerElement, type, msg)
	if isElement(playerElement) and getElementType(playerElement) == "player" then
		if type and msg then
			local accountId = getElementData(playerElement, "acc.ID")
			local charId = getElementData(playerElement, "char.ID") or "N/A"

			if accountId and charId then
				return toLog(type, "economy|accID:" .. accountId .. "|charId:" .. charId .. "|" .. type .. "|" .. msg)
			end
		end
	end
end

function logItemAction(playerElement, itemId, amount, action)
	if isElement(playerElement) and getElementType(playerElement) == "player" then
		if action then
			local accountId = getElementData(playerElement, "acc.ID")
			local charId = getElementData(playerElement, "char.ID") or "N/A"

			if accountId and charId then
				itemId = itemId or "N/A"
				amount = amount or "All"

				return toLog("item", "accID:" .. accountId .. "|charId:" .. charId .. "|itemData:" .. itemId .. ";" .. amount .. "|action:" .. action)
			end
		end
	end
end