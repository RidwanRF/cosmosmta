function setBetterVehicle(source, vehicle)
	--local Vehicle = getPedOccupiedVehicle(source)
	setVehicleHandling(source, "engineInertia", 2)
    setVehicleHandling(source, "driveType", "rwd")
    setVehicleHandling(source, "engineAcceleration", 60.0 )
end
addEvent("setBetterVehicle", true)
addEventHandler("setBetterVehicle", root, setBetterVehicle)

function setBetterVehicleBACK(vehicle, source)
	--local Vehicle = getPedOccupiedVehicle(source)
	setVehicleHandling(vehicle, "driveType", "rwd")
    setVehicleHandling(vehicle, "engineAcceleration", 140.0 )
    setVehicleHandling(vehicle, "engineInertia", 0.9)
end
addEvent("setBetterVehicleBACK", true)
addEventHandler("setBetterVehicleBACK", root, setBetterVehicleBACK)