
--picsu anyja ehy kurva
function setAirRide(player, Vehicle, airRideLevel)	
		
		local vehicle = getPedOccupiedVehicle(player)
			
		setElementData(vehicle,"danihe->tuning->airride_level", tonumber(airRideLevel))

		if tonumber(airRideLevel) == 1 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",0.009)
		elseif tonumber(airRideLevel) == 2 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",0.003)
		elseif tonumber(airRideLevel) == 3 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",0)
		elseif tonumber(airRideLevel) == 4 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",-0.03)
		elseif tonumber(airRideLevel) == 5 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",-0.05)
		elseif tonumber(airRideLevel) == 6 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",-0.07)
		elseif tonumber(airRideLevel) == 7 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",-0.10)
		elseif tonumber(airRideLevel) == 8 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",-0.14)
		elseif tonumber(airRideLevel) == 9 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",-0.17)
		elseif tonumber(airRideLevel) == 10 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",-0.2)
		elseif tonumber(airRideLevel) == 11 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",-0.23)
		elseif tonumber(airRideLevel) == 12 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",-0.26)
		elseif tonumber(airRideLevel) == 13 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",-0.29)
		elseif tonumber(airRideLevel) == 14 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",-0.32)
		elseif tonumber(airRideLevel) == 15 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",-0.35)
		end
		triggerClientEvent(player,"playAirRideSound",player,vehicle)
end
addEvent("setAirRide", true )
addEventHandler("setAirRide", resourceRoot, setAirRide)


addEventHandler("onElementDataChange",root, --Ha kiszereli bassza le annak a kocsognek
	function(data,old,new)
		if getElementType(source) == "Vehicle" then
			if data == "eznemgergo->tuning->airride" then
				if new == 0 then
					local defaultHandling = exports.cosmo_handling:getDefaultHandling(getElementModel(source))
		
					if not defaultHandling then
						defaultHandling = getVehicleHandling(source).suspensionLowerLimit
					else
						defaultHandling = defaultHandling["suspensionLowerLimit"] or defaultHandling["suspensionLowerLimit"]
					end
					
					setElementData(source,"danihe->tuning->airride_level",3)
					setVehicleHandling(source,"suspensionLowerLimit",defaultHandling)	
				end
			end
		end
	end
)