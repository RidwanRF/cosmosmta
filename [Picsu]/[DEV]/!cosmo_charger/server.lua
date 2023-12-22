addEventHandler("onResourceStart",resourceRoot,
	function()
		for k,v in ipairs(getElementsByType("vehicle")) do
			local id = getElementModel ( v )
			if id == 426 then
				if isElement(getElementData(v,"chargerObject")) then
					destroyElement(getElementData(v,"chargerObject"))
				end
				setElementData(v, "chargerInVehicle", false)
			end
		end
	end
)

addEvent("chargerInServer", true)
addEventHandler("chargerInServer", getRootElement(), function(player, v)
	local vx, vy, vz = getElementPosition(v)
	local charger = createObject(7648, vx, vy, vz)
	
	attachElements(charger, v, 0, 1.8, 0.39)
	setElementCollisionsEnabled(charger, false)
	
	setElementData(v, "chargerObject", charger)
	setElementData(v, "chargerInVehicle", true)
end)



addEvent("chargerDestroyInServer", true)
addEventHandler("chargerDestroyInServer", getRootElement(), function(player, v)
	if isElement(getElementData(v,"chargerObject")) then
		destroyElement(getElementData(v,"chargerObject"))
		print("destroyelement")
	end
	setElementData(v, "chargerInVehicle", false)
end)