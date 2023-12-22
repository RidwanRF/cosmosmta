
function detainPlayer(vehicle, player)
	if vehicle and player then
		if getVehicleOccupant(vehicle, 2) and getVehicleOccupant(vehicle, 3) then
			exports.cosmo_alert:showInfobox("error", "A járműben nincs már hely szabad hely", source)
			return   
		end

		local targetSeat = 2
		if getVehicleOccupant(vehicle, 2) then
			targetSeat = 3
		end

		warpPedIntoVehicle(player, vehicle, targetSeat)

		setElementData(player, "player.seatBelt", true)
	end
end
addEvent("cosmo_detainS:detainPlayer", true)
addEventHandler("cosmo_detainS:detainPlayer", root, detainPlayer)

--[[function removePedFromVehicle(player, cmd, target)
	if not target then
		outputChatBox(exports.cosmo_core:getServerTag("usage") .. "/kiszed [Játékos ID]", player, 0, 0, 0, true)
	else
		if not isPedInVehicle(player) then
			local targetPlayer, targetPlayerName = exports.cosmo_core:findPlayer(thePlayer, target)
			if targetPlayer ~= player then
				if isPedInVehicle(targetPlayer) then
					if getElementData(targetPlayer, "player.seatBelt") == false then
						local x,y,z = getElementPosition(player)
						local px,py,pz = getElementPosition(targetPlayer)
						local distance = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
						if distance <= 2 then 
							removePedFromVehicle(targetPlayer)
							exports.cosmo_chat:sendLocalMeAction(player, "kiszedett valakit a járműből.")
						else 
							exports.cosmo_alert:showInfobox(player, "error", "A játékos túl messze van")
						end
					else
						exports.cosmo_alert:showInfobox(player, "error", "A játékos öve be van kötve")
					end
				else
					exports.cosmo_alert:showInfobox(player, "error", "A játékos nincs járműben")
				end
			else
				exports.cosmo_alert:showInfobox(player, "error", "Magadat nem szedheted ki")
			end
	else
		exports.cosmo_alert:showInfobox(player, "error", "Járműben ülve nem szedheted ki")
	end
end
end
addCommandHandler("kiszed2", removePedFromVehicle)]]

function outputUsageText(commandName, string, playerSource)
	if isElement(playerSource) then
		outputChatBox(exports.cosmo_core:getServerTag("usage") .. "/" .. commandName .. " " .. string, playerSource, 0, 0, 0, true)
	end
end

addEvent("kickPlayerFromVeh", true)
addEventHandler("kickPlayerFromVeh", root, function(e, comPos)
    local veh = e.vehicle
    removePedFromVehicle(e)

    local x, y, z = e.position
    if comPos and type(comPos) == "table" then
        x,y,z = unpack(comPos)
    end
    setElementPosition(e, x, y, z)
end)