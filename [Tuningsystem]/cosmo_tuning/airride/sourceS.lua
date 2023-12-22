addEvent("changeAirrideLevel",true)
addEventHandler("changeAirrideLevel",resourceRoot,
	function(player,vehicle,old_level,level)
		setElementData(vehicle,"danihe->tuning->airride_level", tonumber(level))
		--exports.reach_chat:createMeMessage(player,"állít a járműve hasmagasságán.")

		local vehicle = getPedOccupiedVehicle(player)
		local defaultHandling = exports.cosmo_handling:getDefaultHandling(getElementModel(vehicle))
		
		if not defaultHandling then
			defaultHandling = getVehicleHandling(vehicle).suspensionLowerLimit
		else
			defaultHandling = defaultHandling["suspensionLowerLimit"] or defaultHandling["suspensionLowerLimit"]
		end
		
		if tonumber(level) == 0 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",0.009);
		elseif tonumber(level) == 1 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",-0.05);
		elseif tonumber(level) == 2 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",-0.1);
		elseif tonumber(level) == 3 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",0);
		elseif tonumber(level) == 4 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",-0.2);
		elseif tonumber(level) == 5 then
			setVehicleHandling(vehicle,"suspensionLowerLimit",-0.35);
		end

		triggerClientEvent(player,"playbackAirride",player,vehicle)
	end
)

--// Kiszerelésnél fix
addEventHandler("onElementDataChange",root,
	function(data,old,new)
		if getElementType(source) == "vehicle" then
			if data == "danihe->tuning->airride" then
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