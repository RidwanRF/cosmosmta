local connection = exports.cosmo_database:getConnection()

local jailPosX = 154.46096801758
local jailPosY = -1951.6784667969
local jailPosZ = 47.875
local jailInterior = 0

zeroTolerance = createElement("viktor","zerotolerance")
setElementData(zeroTolerance,"activate",false)

function setZeroStatus(playerSource,commandName,mode)
	if getElementData(playerSource,"acc.adminLevel") >= 6 then
		if not mode then
			outputChatBox("#ff9428[Zéró Tolerancia]:#ffffff /zeromod [on/off]",playerSource,255,255,255,true)
		end
		if mode == "on" then
			if getElementData(zeroTolerance,"activate") == false then
				setElementData(zeroTolerance,"activate",true)
				outputChatBox("#ff9428[Zéró Tolerancia]: #ffffffSikeresen bekapcsoltad a zéró tolerancia módot!",playerSource,255,255,255,true)
				exports.cosmo_dclog:sendDiscordMessage("......................", "adminlog")
				exports.cosmo_dclog:sendDiscordMessage("**"..getElementData(playerSource, "acc.adminNick").." (".. getPlayerName(playerSource) ..")** bekapcsolta a zéró toleranciát! @viktor#3763", "adminlog")
				exports.cosmo_dclog:sendDiscordMessage("......................", "adminlog")
			end
		elseif mode == "off" then
			if getElementData(zeroTolerance,"activate") == true then
				setElementData(zeroTolerance,"activate",false)
				outputChatBox("#ff9428[Zéró Tolerancia]: #ffffffSikeresen kikapcsoltad a zéró tolerancia módot!",playerSource,255,255,255,true)
				exports.cosmo_dclog:sendDiscordMessage("......................", "adminlog")
				exports.cosmo_dclog:sendDiscordMessage("**"..getElementData(playerSource, "acc.adminNick").." (".. getPlayerName(playerSource) ..")** kikapcsolta a zéró toleranciát! @viktor#3763", "adminlog")
				exports.cosmo_dclog:sendDiscordMessage("......................", "adminlog")
			end
		end
	end
end
addCommandHandler("zeromode",setZeroStatus)

addEventHandler("onPlayerWasted",getRootElement(),function(ammo,killer,killerweapon,bodypart)
	if killer and killerweapon then
		if getElementData(zeroTolerance,"activate") == true then
			if killerweapon == 0 or killerweapon == 1 or killerweapon == 2 or killerweapon == 3 or killerweapon == 4 or killerweapon == 5 or killerweapon == 6 or killerweapon == 7 or killerweapon == 8 or killerweapon == 9 or killerweapon == 22 or killerweapon == 23 or killerweapon == 24 or killerweapon == 25 or killerweapon == 26 or killerweapon == 27 or killerweapon == 28 or killerweapon == 29 or killerweapon == 30 or killerweapon == 31 or killerweapon == 32 or killerweapon == 33 or killerweapon == 34 or killerweapon == 35 or killerweapon == 36 or killerweapon == 37 or killerweapon == 38 or killerweapon == 16 or killerweapon == 17 or killerweapon == 18 or killerweapon == 39 or killerweapon == 41 or killerweapon == 42 or killerweapon == 43 or killerweapon == 10 or killerweapon == 11 or killerweapon == 12 or killerweapon == 14 or killerweapon == 15 or killerweapon == 44 or killerweapon == 45 or killerweapon == 46 or killerweapon == 40 then
				local jailInfo = "Zéró tolerancia"
				local duration = 60
				dbExec(connection, "UPDATE accounts SET adminJail = ?, adminJailTime = ? WHERE accountID = ?", jailInfo, duration, getElementData(killer,"acc.dbID"))
				removePedFromVehicle(killer)
				setElementPosition(killer, jailPosX, jailPosY, jailPosZ)
				setElementInterior(killer, jailInterior)
				setElementDimension(killer, getElementData(killer,"acc.dbID") + math.random(1, 100))
				setElementData(killer, "acc.adminJail", jailInfo)
				setElementData(killer, "acc.adminJailTime", duration)
				outputChatBox("#ff9428[Jail]:#FFFFFF #ff9428" .. "Rendszer" .. "#FFFFFF bebörtönözte #ff9428" .. getElementData(killer,"char.Name") .. "#FFFFFF-t #ff9428" .. duration .. "#FFFFFF percre.", getRootElement(), 255, 0, 0, true)
				outputChatBox("#ff9428[Jail]:#FFFFFF Indok: #ff9428" .. jailInfo, getRootElement(), 255, 0, 0, true)
			end
		end
	end
end)

addEvent("getzerostate", true)
addEventHandler("getzerostate", getRootElement(),function(sourcePlayer)
	local source = client
	if getElementData(zeroTolerance,"activate") == true then
		triggerClientEvent(source,"setTextIsZeroMode",source,"on")
	elseif getElementData(zeroTolerance,"activate") == false then
		triggerClientEvent(source,"setTextIsZeroMode",source,"off")
	end
end)