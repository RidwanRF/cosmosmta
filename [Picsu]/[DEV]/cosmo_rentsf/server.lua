local theCar = {}

local count = -100000
local rentedPlateCount = 0

addEvent("createRentCarSF", true)
addEventHandler("createRentCarSF", getRootElement(),
	function(hitElement,kivalasztotJarmu)
	
		local money = getElementData(client, "char.Money")
	
		rentedPlateCount = rentedPlateCount + 1
		count = count - 1
		theCar[hitElement] = createVehicle(kivalasztotJarmu,-2589.9936523438, 583.70239257812, 14.453125+1, 0, 0, 270, "RENT-" .. rentedPlateCount, false, 1, 1)
		setElementData(theCar[hitElement], "veh:id", count)
		setElementData(theCar[hitElement], "rent.Owner", player)
		setElementHealth(theCar[hitElement], 1000)
		setElementData(theCar[hitElement], "vehicle.dbID",count)
		setElementData(theCar[hitElement], "job", -1)
		setElementData(theCar[hitElement], "owner", -1)
		setElementData(theCar[hitElement], "faction", -1)
		setElementData(theCar[hitElement], "fuel", 100)
		setElementData(theCar[hitElement], "vehicle.engine", 1)
		setElementData(theCar[hitElement], "vehicle.seatbelt", false)
		
		
		setElementData(client, "char.Money", money-1000)
		
		setTimer( function()
			setElementData(theCar[hitElement], "veh:fuel", 100)
		end, 500, 1)

		warpPedIntoVehicle(hitElement, theCar[hitElement])
		setElementData(theCar[hitElement], "rentCar", true)
	end
)

addEvent("destroyRentCar", true)
addEventHandler("destroyRentCar", root,
	function()
		if isElement(theCar[hitElement]) then
			destroyElement(theCar[hitElement])
		end
	end
)

addEventHandler("onPlayerQuit", getRootElement(), function()
	local veh = getElementData(source, "rentCar")
	if isElement(veh) then
		destroyElement(veh)
	end
end)