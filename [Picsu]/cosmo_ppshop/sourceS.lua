addEvent("ppShop >> itemBuy", true)
addEventHandler("ppShop >> itemBuy", root, 
	function(player, itemID, count, itemName, amount)
		exports.cosmo_inventory:giveItem(player, itemID, count)
		outputChatBox(exports.cosmo_core:getServerTag("info") .. "Vettél #d64d4d" .. count .. "#ffffff db #d64d4d".. itemName .."#ffffff-t (#d64d4d".. getPlayerName(player) .."#ffffff) ID: #d64d4d"..itemID.."#ffffff.", player, 255, 150, 0, true)
		exports.cosmo_hud:showInfobox(player, "success", "Sikerese vásárlás!")
		exports.cosmo_dclog:sendDiscordMessage("**"..getPlayerName(player).. "** Vásárolt egy **"..itemName.."**-t **["..count.."-DB]** **["..amount.."]** [Prémium shop]", "itemlog")
		setElementData(player, "char.PP", (tonumber(getElementData(player, "char.PP")) - amount))
	end
)

exports.cosmo_admin:addAdminCommand("givepp", 9, "Prémium Pont hozzáadás")
addCommandHandler("givepp",
	function(sourcePlayer, cmd, target, amount)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 9 then
			if not (target and tonumber(amount)) then
				outputChatBox("#ff9428[CosmoMta]: #ffffff/" .. cmd .. " [ID/Név] [PP]", sourcePlayer, 0, 0, 0, true)
				return
			else
				target = exports.cosmo_core:findPlayer(sourcePlayer, target)
				
				if target then
					local cPP = getElementData(target, "char.PP")
					
					setElementData(target, "char.PP", cPP+tonumber(amount))
					exports.cosmo_dclog:sendDiscordMessage("**"..getPlayerCharacterName(sourcePlayer).. " [".. getPlayerAdminNick(sourcePlayer) .."]** Adott **".. getPlayerName(target) .."-nak/nek** ennyi prémiumpontot: **" ..tonumber(amount).. "**", "givelog")
					outputChatBox(exports.cosmo_core:getServerTag("info").."Sikeresen adtál #d64d4d" .. getPlayerName(target) .. " #ffffffjátékosnak #d64d4d"..tonumber(amount).."#ffffff PP-t.", sourcePlayer, 255, 255, 255, true)
				end
			end
		end
	end
)

exports.cosmo_admin:addAdminCommand("takepp", 9, "Prémium Pont levétel")
addCommandHandler("takepp",
	function(sourcePlayer, cmd, target, amount)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 9 then
			if not (target and tonumber(amount)) then
				outputChatBox("#ff9428[CosmoMta]: #ffffff/" .. cmd .. " [ID/Név] [PP]", sourcePlayer, 0, 0, 0, true)
				return
			else
				target = exports.cosmo_core:findPlayer(sourcePlayer, target)
				
				if target then
					local cPP = getElementData(target, "char.PP")
					if cPP >= tonumber(amount) then
						setElementData(target, "char.PP", cPP-tonumber(amount))
						exports.cosmo_dclog:sendDiscordMessage("**"..getPlayerCharacterName(sourcePlayer).. " [".. getPlayerAdminNick(sourcePlayer) .."]** Elvett **".. getPlayerName(target) .."-tól/től** ennyi prémiumpontot: **" ..tonumber(amount).. "**", "givelog")
						outputChatBox(exports.cosmo_core:getServerTag("info").."Sikeresen elvettél #d64d4d" .. getPlayerName(target) .. " #ffffffjátékostól #d64d4d"..tonumber(amount).."#ffffff PP-t.", sourcePlayer, 255, 255, 255, true)
					else
						outputChatBox(exports.cosmo_core:getServerTag("info").."Nincs elég prémiumpontja.", sourcePlayer, 255, 255, 255, true)
					end	
				end
			end
		end
	end
)

exports.cosmo_admin:addAdminCommand("setpp", 9, "Prémium Pont beállítása")
addCommandHandler("setpp",
	function(sourcePlayer, cmd, target, amount)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 9 then
			if not (target and tonumber(amount)) then
				outputChatBox("#ff9428[CosmoMta]: #ffffff/" .. cmd .. " [ID/Név] [PP]", sourcePlayer, 0, 0, 0, true)
				return
			else
				target = exports.cosmo_core:findPlayer(sourcePlayer, target)
				
				if target then				
					setElementData(target, "char.PP", tonumber(amount))
					exports.cosmo_dclog:sendDiscordMessage("**"..getPlayerCharacterName(sourcePlayer).. " [".. getPlayerAdminNick(sourcePlayer) .."]** Átállította **".. getPlayerName(target) .."-nak/nek** a prémiumpontját a következőre **" ..tonumber(amount).. "**", "givelog")
					outputChatBox(exports.cosmo_core:getServerTag("info").."Sikeresen beállítottad #d64d4d" .. getPlayerName(target) .. " #ffffffjátékosnak a Prémium Pontját(#d64d4d"..tonumber(amount).."#ffffff).", sourcePlayer, 255, 255, 255, true)
				end
			end
		end
	end
)

function getPlayerAdminNick(playerSource)
	if isElement(playerSource) then
		return getElementData(playerSource, "acc.adminNick") or "Admin"
	end
end

function getPlayerCharacterName(playerSource)
	if isElement(playerSource) then
		return (getElementData(playerSource, "char.Name"):gsub("_", " "))
	end
end

