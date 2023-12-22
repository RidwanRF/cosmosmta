local rajtimes = nil
local rajhandling = nil
local mhandling = nil
local rajulasoskocsi = {}
local lastTick = getTickCount()

function setRajIndulas()
	if(isPedInVehicle(localPlayer) and getTickCount() - lastTick >= 3000) then
		rajulasoskocsi = getPedOccupiedVehicle(localPlayer)
		if getElementModel(rajulasoskocsi) == 426 then
			local airride = tonumber(getElementData(rajulasoskocsi, "airrideLevel")) or 3
			if airride >= 3 then
				lastTick = getTickCount()
				rajtimes = 0
				local vehmod_id = getElementModel(rajulasoskocsi)
				local speedx, speedy, speedz = getElementVelocity ( rajulasoskocsi )
				local actualspeed = (speedx^2 + speedy^2 + speedz^2)^(0.5) 
				if(actualspeed == 0) then
					return 0;
				end
				if (actualspeed < 0.5) then
					rajulastimer = setTimer(checkplayerAndVehicle,100,0)
					rajhandling = getVehicleHandling(rajulasoskocsi)
					mhandling = {}
					mhandling[1] = rajhandling["mass"] / 3
					mhandling[2] = rajhandling["engineAcceleration"] * 2

					com = rajhandling["centerOfMass"]
					com[2] = com[2] - 1.2
					mhandling[3] = com

					mhandling[4] = 0.01
					mhandling[5] = rajhandling["suspensionForceLevel"] * 2

					triggerServerEvent("setRajHandling",rajulasoskocsi,mhandling)
					setTimer ( function()
						resetVehicleHandling()
					end, 7000, 1 )
				end
			end
		end	
	end
end

function outputChange(dataName,oldValue)
	if getElementType(source) == "player" then
		local newValue = getElementData(source,dataName)
		if(dataName == "player.inTuning") then
			resetVehicleHandling()
		end
	end
end
addEventHandler("onElementDataChange",getRootElement(),outputChange)

function unSetRajIndulas()
	if rajulastimer ~= nil then
		if rajulastimer ~= nil then
			killTimer(rajulastimer)
			rajulastimer = nil
			rajtimes = 0

			resetVehicleHandling()
		end
	end
end

addEventHandler("onClientVehicleExit",root,function(player, seat)
	if player == localPlayer then
		if seat == 0 then
			unSetRajIndulas()
		end
	end
end)

function checkplayerAndVehicle()
	rajtimes = rajtimes + 1
	local hanyanvannakbenne = 0;
	local rajulasoskocsi = getPedOccupiedVehicle(localPlayer)
    for seat, occupant in pairs(getVehicleOccupants(rajulasoskocsi)) do
        if (occupant and getElementType(occupant) == "player") then
            hanyanvannakbenne = hanyanvannakbenne + 1
        end
    end
	if(hanyanvannakbenne == 0) then
		killTimer(rajulastimer)
		rajulastimer = nil
		resetVehicleHandling()
	end
	if not isPedInVehicle(localPlayer) and rajulastimer ~= nil then
		killTimer(rajulastimer)
		rajulastimer = nil
		resetVehicleHandling()
	else
		speedx, speedy, speedz = getElementVelocity ( rajulasoskocsi )
		actualspeed = (speedx^2 + speedy^2 + speedz^2)^(0.5) 
		
		if actualspeed > 0.55 then
			unSetRajIndulas()
		end
	end
end

bindKey("lshift","down",setRajIndulas)
bindKey("lshift","up",unSetRajIndulas)

function resetVehicleHandling()
	if rajhandling ~= nil then
		triggerServerEvent("resetRajVehicleHandling",rajulasoskocsi,rajhandling,mhandling[3])
	end
	rajulasoskocsi = nil
	rajhandling = nil
end