print("fasz")


function rwd(player)	
	local beul = getPedOccupiedVehicle(player)
	--print("beul2")
	if beul then -- ha nem ül járműben
		setVehicleHandling(beul, "driveType", "rwd")
		--print("RWD")
	end
end
addEvent("rwd", true )
addEventHandler("rwd", resourceRoot, rwd)

function awd(player)	
	local beul = getPedOccupiedVehicle(player)
	--print("Beul")
	if  beul then -- ha nem ül járműben
		setVehicleHandling(beul, "driveType", "awd")
		--print("AWD")
	end
end
addEvent("awd", true )
addEventHandler("awd", resourceRoot, awd)

function lstart(player)	
	local vehicle = getPedOccupiedVehicle(player)
	if  vehicle then
		local normalTuning = exports.cosmo_handling:getDefaultHandling(getElementModel(vehicle))["maxVelocity"]
		local lMaxV = normalTuning+80
		setVehicleHandling(vehicle, "maxVelocity", lMaxV)
		outputChatBox("Current velocity : " ..normalTuning)
	end
end
addEvent("lstart", true )
addEventHandler("lstart", resourceRoot, lstart)

function lstartOFF(player)	
	local vehicle = getPedOccupiedVehicle(player)
	if  vehicle then
		local normalTuning = exports.cosmo_handling:getDefaultHandling(getElementModel(vehicle))["maxVelocity"]
		local lMaxV = normalTuning-80
		setVehicleHandling(vehicle, "maxVelocity", lMaxV)
		outputChatBox("Current velocity : " ..normalTuning)
	end
end
addEvent("lstartOFF", true )
addEventHandler("lstartOFF", resourceRoot, lstartOFF)

function makeTrain(source)
	local myTrain = createVehicle(537,1784.9392089844, -1954.0101318359, 13.546875)  -- This will make a freight train just east of the LS train station
	setTrainDerailable(myTrain, false) -- myTrain can not be derailed now
	outputChatBox("A freight train has been created for you.", source, 255, 255, 0) -- Just a simple message for the player
        warpPedIntoVehicle(source, myTrain) -- This will warp you to inside the train
        setTrainSpeed(myTrain, 1) -- Set the train speed to 1 - 100mph, 160kmh
end
addCommandHandler("trainmeup", makeTrain)