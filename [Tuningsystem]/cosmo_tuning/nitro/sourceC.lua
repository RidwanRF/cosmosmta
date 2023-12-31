
--// Itt tároljuk a be stream-elt járműveket
local nitro_vehicles = {}
local nitro_usage = 0.075

addEventHandler("onClientRender",root,
	function()
		local vehicle = getPedOccupiedVehicle(localPlayer)
		local vehicle_seat = getPedOccupiedVehicleSeat(localPlayer)
		if vehicle and vehicle_seat == 0 then
			if nitro_vehicles[vehicle] then
				local nitro = getElementData(vehicle,"danihe->tuning->nitro") or 0
				local nitro_level = getElementData(vehicle,"danihe->tuning->nitroprecent") or 0
				if nitro == 1 then
					if nitro_level > 0 then
						if nitro_vehicles[vehicle].activated then
							--if getElementData(localPlayer,"acc.adminLevel") < 9 then
								nitro_level = nitro_level - nitro_usage
								if nitro_level <= 0 then
									nitro_level = 0
								end
								setElementData(vehicle,"danihe->tuning->nitroprecent",nitro_level)
							--end
						end

						if getKeyState("rshift") or getKeyState("lshift") or getKeyState("lctrl") or getKeyState("rctrl") then
							if isTuningActive() then return end
							if not getElementData(vehicle,"danihe->vehicles->nitro_activated") then
								if nitro_level > 0 then
									setElementData(vehicle,"danihe->vehicles->nitro_activated",true)
								end
							end
						else
							if getElementData(vehicle,"danihe->vehicles->nitro_activated") then
								setElementData(vehicle,"danihe->vehicles->nitro_activated",false)
							end
						end
					else
						setVehicleNitroActivated(source,false)
						setElementData(vehicle,"danihe->vehicles->nitro_activated",false)
					end
				end
			else
				nitro_vehicles[vehicle] = {activated = false}
			end
		end
	end
)

addEventHandler("onClientKey",root,
	function(k,p)
		local vehicle = getPedOccupiedVehicle(localPlayer)
		if vehicle then
			if k == "lctrl" or k == "rctrl" or k == "mouse1" or k == "lalt" and p then
				if not isTuningActive() then
					local nitro = getElementData(vehicle,"danihe->tuning->nitro") or 0
					if nitro == 1 then 
						cancelEvent()
					end
				end
			end
		end
	end
)

addEventHandler("onClientElementDataChange",root,
	function(data)
		if getElementType(source) == "vehicle" then
			if isElementStreamedIn(source) then
				if nitro_vehicles[source] then
					if data == "danihe->vehicles->nitro_activated" then
						nitro_vehicles[source].activated = getElementData(source,"danihe->vehicles->nitro_activated")
						if nitro_vehicles[source].activated then
							addVehicleUpgrade(source,1010)
							setVehicleNitroCount(source,101)
							setVehicleNitroLevel(source,1)
							setVehicleNitroActivated(source,true)
						else
							setVehicleNitroActivated(source,false)
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientElementStreamIn",root,
	function()
		if getElementType(source) == "vehicle" then
			nitro_vehicles[source] = {activated = false}
		end
	end
)

addEventHandler("onClientElementStreamOut",root,
	function()
		if getElementType(source) == "vehicle" then
			nitro_vehicles[source] = nil
		end
	end
)

addEventHandler("onClientResourceStart",resourceRoot,
	function()
		for k,v in ipairs(getElementsByType("vehicle")) do
			setElementData(v,"danihe->vehicles->nitro_activated",false)
			if isElementStreamedIn(v) then
				nitro_vehicles[v] = {activated = false}
			end
		end
	end
)