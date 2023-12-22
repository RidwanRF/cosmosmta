
function setRajHandlingF(handling)

	setVehicleHandling(source,"mass",handling[1])
	setVehicleHandling(source,"engineAcceleration",handling[2])
	setVehicleHandling(source,"centerOfMass",handling[3])
	setVehicleHandling(source,"engineInertia",handling[4])
	setVehicleHandling(source,"suspensionForceLevel",handling[5])

end
addEvent("setRajHandling",true)
addEventHandler("setRajHandling",getRootElement(), setRajHandlingF)


function resetHandling(handling,com)
	setVehicleHandling(source,"mass",handling["mass"])
	setVehicleHandling(source,"engineAcceleration",handling["engineAcceleration"])
	com[2] = com[2] + 1.2
	setVehicleHandling(source,"centerOfMass",com)
	setVehicleHandling(source,"engineInertia",handling["engineInertia"])
	setVehicleHandling(source,"suspensionForceLevel",handling["suspensionForceLevel"])

end
addEvent("resetRajVehicleHandling",true)
addEventHandler("resetRajVehicleHandling",getRootElement(),resetHandling)

function cigany(player)
	setElementData(getPedOccupiedVehicle(player),"danihe->tuning->nitroprecent",100)
end
addCommandHandler("agynitroazonal", cigany)

addCommandHandler("fulltuningfactioncar", function(player, vehicle)
	if getElementData(player, "acc.adminLevel") >= 6 then
		local vehicle = getPedOccupiedVehicle(player)
		outputChatBox("Sikeresen fullosra tuningoltad a járgányt haver (frakció)", player, 255, 255, 255, true)
		setElementData(vehicle, "danihe->tuning->airintake", 4)
		setElementData(vehicle, "danihe->tuning->fuelsystem", 4)
		setElementData(vehicle, "danihe->tuning->ignite", 4)
		setElementData(vehicle, "danihe->tuning->exhaust", 4)
		setElementData(vehicle, "danihe->tuning->camshaft", 4)
		setElementData(vehicle, "danihe->tuning->valve", 4)
		setElementData(vehicle, "danihe->tuning->engine", 4)
		setElementData(vehicle, "danihe->tuning->ecu", 4)
		setElementData(vehicle, "danihe->tuning->pistons", 4)
		setElementData(vehicle, "danihe->tuning->turbo", 3)
		setElementData(vehicle, "danihe->tuning->intercooler", 4)
		setElementData(vehicle, "danihe->tuning->oil_cooler", 4)
		setElementData(vehicle, "danihe->tuning->flywheel", 4)
		setElementData(vehicle, "danihe->tuning->brakes", 4)
		setElementData(vehicle, "danihe->tuning->pistons", 4)
		setElementData(vehicle, "danihe->tuning->suspension", 4)
		setElementData(vehicle, "danihe->tuning->chassis", 4)
		setElementData(vehicle, "danihe->tuning->weight", 4)
		setElementData(vehicle, "danihe->tuning->tires", 4)
		setElementData(vehicle, "danihe->tuning->clutch", 4)
		setElementData(vehicle, "danihe->tuning->gear", 4)
		setElementData(vehicle, "danihe->tuning->chain", 4)
		setElementData(vehicle, "danihe->tuning->diff", 4)
		setElementData(vehicle, "danihe->tuning->airride", 1)
		setElementData(vehicle, "danihe->tuning->drivetype", 1)
	end
end)