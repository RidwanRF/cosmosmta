local vehicleIndicators = {}
local vehicleIndicatorTimers = {}
local vehicleIndicatorStates = {}
local vehicleLightStates = {}
local vehicleOverrideLights = {}


local defaultConsumption = 1
local consumptionMultipler = 3
local consumptionValue = 0

local vehicleSaveTimer = false

local specialVehicles = {
	[457] = true,
	[485] = true,
	[486] = true,
	[530] = true,
	[531] = true,
	[539] = true,
	[571] = true,
	[572] = true
}


addEventHandler("onClientKey", getRootElement(),
	function (key, pressDown)
		local vehicle = getPedOccupiedVehicle(localPlayer)

		if vehicle and getPedOccupiedVehicleSeat(localPlayer) == 0 and not isCursorShowing() and not isConsoleActive() then
			local vehicleType = getVehicleType(vehicle)
			local model = getElementModel(vehicle)

			if vehicleType == "Automobile" or vehicleType == "Quad" or specialVehicles[model] then
				if pressDown then
					if key == "mouse1" and not getElementData(localPlayer, "inTuning") then
						setElementData(vehicle, "emergencyIndicator", false)
						setElementData(vehicle, "rightIndicator", false)
						setElementData(vehicle, "leftIndicator", not getElementData(vehicle, "leftIndicator"))
					elseif key == "mouse2" and not getElementData(localPlayer, "inTuning") then
						setElementData(vehicle, "emergencyIndicator", false)
						setElementData(vehicle, "leftIndicator", false)
						setElementData(vehicle, "rightIndicator", not getElementData(vehicle, "rightIndicator"))
					elseif key == "F2" then
						setElementData(vehicle, "leftIndicator", false)
						setElementData(vehicle, "rightIndicator", false)
						setElementData(vehicle, "emergencyIndicator", not getElementData(vehicle, "emergencyIndicator"))
					end
				end
			end
		end
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if dataName == "leftIndicator" then
			if not vehicleIndicators[source] then
				vehicleIndicators[source] = {}
			end

			if not vehicleLightStates[source] then
				vehicleLightStates[source] = {}

				for i = 0, 3 do
					vehicleLightStates[source][i] = 0
				end
			end

			if not vehicleOverrideLights[source] then
				local lightState = getElementData(source, "vehicle.light")

				if not lightState then
					vehicleOverrideLights[source] = 1
				else
					vehicleOverrideLights[source] = 2
				end
			end

			if getElementData(source, dataName) then
				vehicleIndicators[source].left = true

				vehicleLightStates[source][0] = getVehicleLightState(source, 0)
				vehicleLightStates[source][3] = getVehicleLightState(source, 3)
				vehicleOverrideLights[source] = getVehicleOverrideLights(source)

				setVehicleOverrideLights(source, 2)

				if not vehicleIndicatorTimers[source] then
					processIndicatorEffect(source)
					vehicleIndicatorTimers[source] = setTimer(processIndicatorEffect, 350, 0, source)

					vehicleLightStates[source][1] = getVehicleLightState(source, 1)
					vehicleLightStates[source][2] = getVehicleLightState(source, 2)
				end

				if vehicleOverrideLights[source] ~= 2 then
					setVehicleLightState(source, 1, 1)
					setVehicleLightState(source, 2, 1)
				end

				vehicleIndicatorStates[source] = true
			else
				vehicleIndicators[source].left = false

				setVehicleLightState(source, 0, vehicleLightStates[source][0] or 0)
				setVehicleLightState(source, 3, vehicleLightStates[source][3] or 0)

				if not vehicleIndicators[source].left then
					setVehicleOverrideLights(source, vehicleOverrideLights[source])

					setVehicleLightState(source, 1, vehicleLightStates[source][1] or 0)
					setVehicleLightState(source, 2, vehicleLightStates[source][2] or 0)

					if isTimer(vehicleIndicatorTimers[source]) then
						killTimer(vehicleIndicatorTimers[source])
						vehicleIndicatorTimers[source] = nil
					end

					vehicleIndicatorStates[source] = false
				end
			end
		end

		if dataName == "rightIndicator" then
			if not vehicleIndicators[source] then
				vehicleIndicators[source] = {}
			end

			if not vehicleLightStates[source] then
				vehicleLightStates[source] = {}

				for i = 0, 3 do
					vehicleLightStates[source][i] = 0
				end
			end

			if not vehicleOverrideLights[source] then
				local lightState = getElementData(source, "vehicle.light")

				if not lightState then
					vehicleOverrideLights[source] = 1
				else
					vehicleOverrideLights[source] = 2
				end
			end

			if getElementData(source, dataName) then
				vehicleIndicators[source].right = true

				vehicleLightStates[source][1] = getVehicleLightState(source, 1)
				vehicleLightStates[source][2] = getVehicleLightState(source, 2)
				vehicleOverrideLights[source] = getVehicleOverrideLights(source)

				setVehicleOverrideLights(source, 2)

				if not vehicleIndicatorTimers[source] then
					processIndicatorEffect(source)
					vehicleIndicatorTimers[source] = setTimer(processIndicatorEffect, 350, 0, source)

					vehicleLightStates[source][0] = getVehicleLightState(source, 0)
					vehicleLightStates[source][3] = getVehicleLightState(source, 3)
				end

				if vehicleOverrideLights[source] ~= 2 then
					setVehicleLightState(source, 0, 1)
					setVehicleLightState(source, 3, 1)
				end

				vehicleIndicatorStates[source] = true
			else
				vehicleIndicators[source].right = false

				setVehicleLightState(source, 1, vehicleLightStates[source][1] or 0)
				setVehicleLightState(source, 2, vehicleLightStates[source][2] or 0)

				if not vehicleIndicators[source].right then
					setVehicleOverrideLights(source, vehicleOverrideLights[source])
					setVehicleLightState(source, 0, vehicleLightStates[source][0] or 0)
					setVehicleLightState(source, 3, vehicleLightStates[source][3] or 0)

					if isTimer(vehicleIndicatorTimers[source]) then
						killTimer(vehicleIndicatorTimers[source])
						vehicleIndicatorTimers[source] = nil
					end

					vehicleIndicatorStates[source] = false
				end
			end
		end

		if dataName == "emergencyIndicator" then
			if not vehicleIndicators[source] then
				vehicleIndicators[source] = {}
			end

			if not vehicleLightStates[source] then
				vehicleLightStates[source] = {}

				for i = 0, 3 do
					vehicleLightStates[source][i] = 0
				end
			end

			if not vehicleOverrideLights[source] then
				local lightState = getElementData(source, "vehicle.light")

				if not lightState then
					vehicleOverrideLights[source] = 1
				else
					vehicleOverrideLights[source] = 2
				end
			end

			if getElementData(source, dataName) then
				vehicleIndicators[source].left = true
				vehicleIndicators[source].right = true

				for i = 0, 3 do
					vehicleLightStates[source][i] = getVehicleLightState(source, i)
				end

				vehicleOverrideLights[source] = getVehicleOverrideLights(source)

				setVehicleOverrideLights(source, 2)

				if not vehicleIndicatorTimers[source] then
					processIndicatorEffect(source)
					vehicleIndicatorTimers[source] = setTimer(processIndicatorEffect, 350, 0, source)
				end

				if vehicleOverrideLights[source] ~= 2 then
					for i = 0, 3 do
						setVehicleLightState(source, i, 1)
					end
				end

				vehicleIndicatorStates[source] = true
			else
				vehicleIndicators[source].left = false
				vehicleIndicators[source].right = false

				for i = 0, 3 do
					setVehicleLightState(source, i, vehicleLightStates[source][i] or 0)
				end

				setVehicleOverrideLights(source, vehicleOverrideLights[source])

				if isTimer(vehicleIndicatorTimers[source]) then
					killTimer(vehicleIndicatorTimers[source])
					vehicleIndicatorTimers[source] = nil
				end

				vehicleIndicatorStates[source] = false
			end
		end
	end
)

function processIndicatorEffect(vehicle)
	if isElement(vehicle) then
		if vehicleIndicators[vehicle].left then
			if vehicleLightStates[vehicle][0] ~= 1 then
				if vehicleIndicatorStates[vehicle] then
					setVehicleLightState(vehicle, 0, 0)
				else
					setVehicleLightState(vehicle, 0, 1)
				end
			end

			if vehicleLightStates[vehicle][3] ~= 1 then
				if vehicleIndicatorStates[vehicle] then
					setVehicleLightState(vehicle, 3, 0)
				else
					setVehicleLightState(vehicle, 3, 1)
				end
			end

			if vehicle == getPedOccupiedVehicle(localPlayer) then
				currentIndicatorState = vehicleIndicatorStates[vehicle]
			end
		end

		if vehicleIndicators[vehicle].right then
			if vehicleLightStates[vehicle][1] ~= 1 then
				if vehicleIndicatorStates[vehicle] then
					setVehicleLightState(vehicle, 1, 0)
				else
					setVehicleLightState(vehicle, 1, 1)
				end
			end

			if vehicleLightStates[vehicle][2] ~= 1 then
				if vehicleIndicatorStates[vehicle] then
					setVehicleLightState(vehicle, 2, 0)
				else
					setVehicleLightState(vehicle, 2, 1)
				end
			end

			if vehicle == getPedOccupiedVehicle(localPlayer) then
				currentIndicatorState = vehicleIndicatorStates[vehicle]
			end
		end

		--if vehicle == getPedOccupiedVehicle(localPlayer) and vehicleIndicatorStates[vehicle] then
			--playSound(":sarp_vehicles/files/turnsignal.ogg")
		--end

		vehicleIndicatorStates[vehicle] = not vehicleIndicatorStates[vehicle]
	else
		killTimer(sourceTimer)
	end
end

function getVehicleOverrideLightsEx(vehicle)
	if vehicleIndicators[vehicle] and (vehicleIndicators[vehicle].right or vehicleIndicators[vehicle].left) then
		return vehicleIndicatorStates[vehicle]
	end

	return getVehicleOverrideLights(vehicle)
end