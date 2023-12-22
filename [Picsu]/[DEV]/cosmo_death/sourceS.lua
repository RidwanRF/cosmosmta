local connection = exports.cosmo_database:getConnection()

addEvent("fallAnimByBulletDamage", true)
addEventHandler("fallAnimByBulletDamage", getRootElement(),
	function ()
		if isElement(source) then
			setPedAnimation(source, "PED", "FALL_collapse", 2000, false, true, true, false)
		end
	end
)

exports.cosmo_admin:addAdminCommand("afelsegit", 1, "Játékos felsegítése a halálból")
addCommandHandler("afelsegit",
	function (localPlayer, cmd, target)
		if getElementData(localPlayer, "acc.adminLevel") >= 1 then
			if not target then
				outputChatBox(exports.cosmo_core:getServerTag("usage") .. "/" .. cmd .. " [Játékos név / ID]", localPlayer, 0, 0, 0, true)
			else
				local targetPlayer, targetPlayerName = exports.cosmo_core:findPlayer(localPlayer, target)

				if targetPlayer then
					if getElementHealth(targetPlayer) <= 20 or isPedDead(targetPlayer) then
						local playerPosX, playerPosY, playerPosZ = getElementPosition(targetPlayer)
						local playerInterior = getElementInterior(targetPlayer)
						local playerDimension = getElementDimension(targetPlayer)
						local playerSkin = getElementModel(targetPlayer)

						spawnPlayer(targetPlayer, playerPosX, playerPosY, playerPosZ, getPedRotation(targetPlayer), playerSkin, playerInterior, playerDimension)
						healPlayer(targetPlayer)
						setPedAnimation(targetPlayer)
						setCameraTarget(targetPlayer, targetPlayer)

						--<<SAVE>>--
						setElementData(localPlayer, 'admin.asegit', (getElementData(localPlayer, 'admin.asegit') or 0)+1)
						dbExec(connection, "UPDATE accounts SET asegit = ? WHERE accountID = ?", getElementData(localPlayer,"admin.asegit"), getElementData(localPlayer, "acc.dbID"))
						--<<SAVE>>--

						outputChatBox(exports.cosmo_core:getServerTag("admin") .. "Sikeresen felsegítetted #ff9428" .. targetPlayerName .. " #ffffffjátékost.", localPlayer, 0, 0, 0, true)
						outputChatBox(exports.cosmo_core:getServerTag("admin") .. "#ff9428" .. (getElementData(localPlayer, "acc.adminNick") or "Admin") .. " #fffffffelsegített téged.", targetPlayer, 0, 0, 0, true)
					else
						outputChatBox(exports.cosmo_core:getServerTag("admin") .. "A kiválasztott játékos nem ájult és/vagy nincs meghalva.", localPlayer, 0, 0, 0, true)
					end
				end
			end
		end
	end
)

exports.cosmo_admin:addAdminCommand("asegit", 1, "Játékos felsegítése a halálból")
addCommandHandler("asegit",
	function (localPlayer, cmd, target)
		if getElementData(localPlayer, "acc.adminLevel") >= 1 then
			if not target then
				outputChatBox(exports.cosmo_core:getServerTag("usage") .. "/" .. cmd .. " [Játékos név / ID]", localPlayer, 0, 0, 0, true)
			else
				local targetPlayer, targetPlayerName = exports.cosmo_core:findPlayer(localPlayer, target)

				if targetPlayer then
					if getElementHealth(targetPlayer) <= 20 or isPedDead(targetPlayer) then
						local playerPosX, playerPosY, playerPosZ = getElementPosition(targetPlayer)
						local playerInterior = getElementInterior(targetPlayer)
						local playerDimension = getElementDimension(targetPlayer)
						local playerSkin = getElementModel(targetPlayer)

						spawnPlayer(targetPlayer, playerPosX, playerPosY, playerPosZ, getPedRotation(targetPlayer), playerSkin, playerInterior, playerDimension)
						healPlayer(targetPlayer)
						setPedAnimation(targetPlayer)
						setCameraTarget(targetPlayer, targetPlayer)

						--<<SAVE>>--
						setElementData(localPlayer, 'admin.asegit', (getElementData(localPlayer, 'admin.asegit') or 0)+1)
						dbExec(connection, "UPDATE accounts SET asegit = ? WHERE accountID = ?", getElementData(localPlayer,"admin.asegit"), getElementData(localPlayer, "acc.dbID"))
						--<<SAVE>>--

						outputChatBox(exports.cosmo_core:getServerTag("admin") .. "Sikeresen felsegítetted #ff9428" .. targetPlayerName .. " #ffffffjátékost.", localPlayer, 0, 0, 0, true)
						outputChatBox(exports.cosmo_core:getServerTag("admin") .. "#ff9428" .. (getElementData(localPlayer, "acc.adminNick") or "Admin") .. " #fffffffelsegített téged.", targetPlayer, 0, 0, 0, true)
					else
						outputChatBox(exports.cosmo_core:getServerTag("admin") .. "A kiválasztott játékos nem ájult és/vagy nincs meghalva.", localPlayer, 0, 0, 0, true)
					end
				end
			end
		end
	end
)

exports.cosmo_admin:addAdminCommand("agyogyit", 1, "Játékos meggyógyítása")
addCommandHandler("agyogyit",
	function (localPlayer, cmd, target)
		if getElementData(localPlayer, "acc.adminLevel") >= 1 then
			if not target then
				outputChatBox(exports.cosmo_core:getServerTag("usage") .. "/" .. cmd .. " [Játékos név / ID]", localPlayer, 0, 0, 0, true)
			else
				local targetPlayer, targetPlayerName = exports.cosmo_core:findPlayer(localPlayer, target)

				if targetPlayer then
					if isPedDead(targetPlayer) then
						outputChatBox(exports.cosmo_core:getServerTag("admin") .. "A kiválasztott játékos halott! A felélesztéshez használd az #ffa600/afelsegit #ffffffparancsot.", localPlayer, 0, 0, 0, true)
					else
						healPlayer(targetPlayer)
						setPedAnimation(targetPlayer)
						setCameraTarget(targetPlayer, targetPlayer)

						outputChatBox(exports.cosmo_core:getServerTag("admin") .. "Sikeresen meggyógyítottad #ff9428" .. targetPlayerName .. " #ffffffjátékost.", localPlayer, 0, 0, 0, true)
						outputChatBox(exports.cosmo_core:getServerTag("admin") .. "#ff9428" .. (getElementData(localPlayer, "acc.adminNick") or "Admin") .. " #ffffffmeggyógyított téged.", targetPlayer, 0, 0, 0, true)
					end
				end
			end
		end
	end
)

function healPlayer(playerElement)
	if isElement(playerElement) then
		setElementHealth(playerElement, 100)
		setElementData(playerElement, "isPlayerDeath", false)
		setElementData(playerElement, "bulletDamages", false)
		--setElementData(playerElement, "boneDamages", false)
		setElementData(playerElement, "bloodLevel", 100)
		setElementData(playerElement, "deathReason", false)
		setElementData(playerElement, "customDeath", false)
		setElementData(playerElement, "char.Hunger", 100)
		setElementData(playerElement, "char.Thirst", 100)
	end
end

addEvent("reSpawnInJail", true)
addEventHandler("reSpawnInJail", getRootElement(),
	function ()
		if isElement(source) then
			local adminJail = getElementData(source, "acc.adminJailTime") or 0
			local inJail = getElementData(source, "char.arrested")

			if adminJail > 0 then
				triggerEvent("movePlayerBackToAdminJail", source)
			elseif inJail then
				triggerEvent("movePlayerBackToJail", source)
			end

			healPlayer(source)
			setPedAnimation(source)
		end
	end
)

addEvent("spawnToHospital", true)
addEventHandler("spawnToHospital", getRootElement(),
	function ()
		if isElement(source) then
			local playerSkin = getElementModel(source)
			local playeraccid = getElementData(source, "char.ID")
			--exports.cosmo_inventory:removeItemByData(source, 6)
			--exports.cosmo_inventory:removeItemByData(source, 7)
			--exports.cosmo_inventory:removeItemByData(source, 205)
			--exports.cosmo_inventory:removeItemByData(source, 206)
			--exports.cosmo_inventory:removeItemByData(source, 3)
			--exports.cosmo_inventory:removeItemByData(source, 4)
			--exports.cosmo_inventory:removeItemByData(source, 5)
			--exports.cosmo_inventory:removeItemByData(source, 6)
			--exports.cosmo_inventory:removeItemByData(source, 7)
			--exports.cosmo_inventory:removeItemByData(source, 8)
			--exports.cosmo_inventory:removeItemByData(source, 9)
			--exports.cosmo_inventory:removeItemByData(source, 10)
			-- exports.cosmo_inventory:removeItemByData(source, 11)
			-- exports.cosmo_inventory:removeItemByData(source, 12)
			-- exports.cosmo_inventory:removeItemByData(source, 13)
			-- exports.cosmo_inventory:removeItemByData(source, 14)
			-- exports.cosmo_inventory:removeItemByData(source, 15)
			-- exports.cosmo_inventory:removeItemByData(source, 16)
			-- exports.cosmo_inventory:removeItemByData(source, 17)
			-- exports.cosmo_inventory:removeItemByData(source, 18)
			-- exports.cosmo_inventory:removeItemByData(source, 19)
			-- exports.cosmo_inventory:removeItemByData(source, 20)
			-- exports.cosmo_inventory:removeItemByData(source, 21)
			-- setElementData(source, "char.Money", getElementData(source, "char.Money")-100000)
			spawnPlayer(source, 1178.0516357422, -1324.3172607422, 14.100989341736, 130, playerSkin, 0, 0)
			healPlayer(source)

			setPedAnimation(source)
			setCameraTarget(source, source)
		end
	end
)

addEvent("spawnToHospitalSF", true)
addEventHandler("spawnToHospitalSF", getRootElement(),
	function ()
		if isElement(source) then
			local playerSkin = getElementModel(source)
			local playeraccid = getElementData(source, "char.ID")
			--exports.cosmo_inventory:removeItemByData(source, 6)
			--exports.cosmo_inventory:removeItemByData(source, 7)
			--exports.cosmo_inventory:removeItemByData(source, 205)
			--exports.cosmo_inventory:removeItemByData(source, 206)
			--exports.cosmo_inventory:removeItemByData(source, 3)
			--exports.cosmo_inventory:removeItemByData(source, 4)
			--exports.cosmo_inventory:removeItemByData(source, 5)
			--exports.cosmo_inventory:removeItemByData(source, 6)
			--exports.cosmo_inventory:removeItemByData(source, 7)
			--exports.cosmo_inventory:removeItemByData(source, 8)
			--exports.cosmo_inventory:removeItemByData(source, 9)
			--exports.cosmo_inventory:removeItemByData(source, 10)
			-- exports.cosmo_inventory:removeItemByData(source, 11)
			-- exports.cosmo_inventory:removeItemByData(source, 12)
			-- exports.cosmo_inventory:removeItemByData(source, 13)
			-- exports.cosmo_inventory:removeItemByData(source, 14)
			-- exports.cosmo_inventory:removeItemByData(source, 15)
			-- exports.cosmo_inventory:removeItemByData(source, 16)
			-- exports.cosmo_inventory:removeItemByData(source, 17)
			-- exports.cosmo_inventory:removeItemByData(source, 18)
			-- exports.cosmo_inventory:removeItemByData(source, 19)
			-- exports.cosmo_inventory:removeItemByData(source, 20)
			-- exports.cosmo_inventory:removeItemByData(source, 21)
			-- setElementData(source, "char.Money", getElementData(source, "char.Money")-100000)
			spawnPlayer(source, -2654.875, 636.80828857422, 14.453125, 180, playerSkin, 0, 0)
			healPlayer(source)

			setPedAnimation(source)
			setCameraTarget(source, source)
		end
	end
)

addEvent("killPlayerAnimTimer", true)
addEventHandler("killPlayerAnimTimer", getRootElement(),
	function ()
		if isElement(source) then
			local playerId = getElementData(source, "playerID")

			setElementHealth(source, 0)
			setPedAnimation(source)
		end
	end
)

addEvent("bringBackInjureAnim", true)
addEventHandler("bringBackInjureAnim", getRootElement(),
	function (state)
		if isElement(source) then
			if state then
				setPedAnimation(source)
			elseif isPedInVehicle(source) then
				setPedAnimation(source, "ped", "car_dead_lhs", -1, false, false, false)
			else
				if getElementData(source, "weaponBoxInHand") then
					exports.cosmo_weaponship:dropWeaponBox(source)
				end
				setPedAnimation(source, "wuzi", "cs_dead_guy", -1, false, false, false)
			end
		end
	end
)

function player_Wasted ( ammo, attacker, weapon, bodypart )
	
	local time = getRealTime()
	local hours = time.hour
	local minutes = time.minute
	
	local killog
	
	if (attacker) then
		if (getElementType(attacker) == "player") then 
			if getWeaponNameFromID(weapon) == "Explosion" then
				allapot = "Felrobbantotta"
			else
				allapot = "Fegyver: " .. getWeaponNameFromID(weapon)
			end
			killog = "[" .. hours .. ":" .. minutes .. "] ".. getPlayerName(attacker):gsub("_"," ")   .. " megölte " .. getPlayerName(source):gsub("_"," ") .. " játékost. (" .. allapot .. ")"
			if (bodypart) == 9 then
				killog = killog .. " (Fejbelövés)"
			elseif (bodypart) == 4 then
				killog = killog .. " (Seggbelőtték)"
			end
		elseif (getElementType(attacker) == "vehicle") then
			if getWeaponNameFromID(weapon) == "Rammed" then
				allapot = "Elütötte"
			elseif getWeaponNameFromID(weapon) == "Ranover" then
				allapot = "Ráállt DB"
			end
			killog = "[" .. hours .. ":" .. minutes .. "] " .. getPlayerVisibleName(getVehicleController(attacker)):gsub("_"," ") .. " elütötte " .. getPlayerVisibleName(source):gsub("_"," ") .. " játékost. (Járművel: " .. allapot .. ")"
		elseif (getElementType(attacker) == "ped") then 
			allapot = "( PET )"
			killog = "[" .. hours .. ":" .. minutes .. "] ".. (getElementData(attacker, "ped:name") or "Ismeretlen") .. " "..allapot .. " megölte " .. getPlayerVisibleName(source):gsub("_"," ") .. " játékost."
		end
	else
		killog = "[" .. hours .. ":" .. minutes .. "] " .. getPlayerVisibleName(source):gsub("_", " ") .. " meghalt."
	end
	
	exports.cosmo_inventory:removeATMCasette(source)
	
	exports.cosmo_core:sendMessageToAdmins(killog, 1)
	exports.cosmo_dclog:sendDiscordMessage(killog, "killog")
	if getElementData(source, "weaponBoxInHand") then
		exports.cosmo_weaponship:resetPlayerWithCreate(source)
	end
end
addEventHandler ( "onPlayerWasted", getRootElement(), player_Wasted )

function getPlayerVisibleName(playerSource)
	if isElement(playerSource) then
		return (getElementData(playerSource, "visibleName"):gsub("_", " "))
	end
end