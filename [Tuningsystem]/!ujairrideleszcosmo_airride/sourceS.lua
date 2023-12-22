addEvent("setAirRide", true)
addEventHandler("setAirRide", getRootElement(),
	function (vehicle, level, players)
		if client == source and isElement(vehicle) and level then
			local originalLimit = getHandlingProperty(vehicle, "suspensionLowerLimit")
			local newLimit = originalLimit + (level - 8) * 0.0175

			setVehicleHandling(vehicle, "suspensionLowerLimit", newLimit)
			setElementData(vehicle, "airRideLevel", level)

			local x, y, z = getElementPosition(vehicle)

			setElementPosition(vehicle, x, y, z + 0.01)
			setElementPosition(vehicle, x, y, z)

			triggerClientEvent(players or getElementsByType("player"), "playAirRideSound", source, vehicle)
		end
	end
)