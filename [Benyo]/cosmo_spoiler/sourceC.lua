local componentTable ={
    [442] = true, --442
}
local drawSpoilerPos = false

function kmhForgas()
	for k, v in pairs(getElementsByType("vehicle", true, getRootElement())) do
		if getElementModel(v) == 442 then --442
			local sX, sY, sZ = getVehicleComponentPosition(v, "movspoiler_1")
			local rX1, rY1, rZ1 = getVehicleComponentRotation(v, "movspoiler_2")
			local rX2, rY2, rZ2 = getVehicleComponentRotation(v, "movspoiler_3")
			local rX3, rY3, rZ3 = getVehicleComponentRotation(v, "movspoiler_4")
			local rX4, rY4, rZ4 = getVehicleComponentRotation(v, "movspoiler_5")
			local rX5, rY5, rZ5 = getVehicleComponentRotation(v, "movspoiler_6")
			local rX6, rY6, rZ6 = getVehicleComponentRotation(v, "movspoiler_7")
			local rX7, rY7, rZ7 = getVehicleComponentRotation(v, "movspoiler_8")
			local rX8, rY8, rZ8 = getVehicleComponentRotation(v, "movspoiler_9")
			if getElementData(localPlayer,"acc.adminLevel") == 9 then
				if drawSpoilerPos == false then
					--outputChatBox("Spoilerpos: "..sX.." "..sY.." "..sZ)
					--outputChatBox("Spoilerrot1: "..rX1.." "..rY1.." "..rZ1.."")
					--outputChatBox("Spoilerrotall: "..rX1.." "..rY1.." "..rZ1..""..rX2.." "..rY2.." "..rZ2..""..rX3.." "..rY3.." "..rZ3..""..rX4.." "..rY4.." "..rZ4..""..rX5.." "..rY5.." "..rZ5.."")
					drawSpoilerPos = true
				end
			end
			if getElementData(v,"spoilerState") == "upped" then --csukódik
				if not sX then
					sX = 0
				end
				if not sY then
					sY = -2.0258500576019
				end
				if not sZ then
					sZ = 0.48
				end
				if not rX1 or not rY1 or not rZ1 then
					rX1 = 346.35510253906
					rX2 = 346.35510253906
					rX3 = 346.35510253906
					rX4 = 346.35510253906
					rX5 = 346.35510253906
					rX6 = 346.35510253906
					rX7 = 346.35510253906
					rX8 = 346.35510253906

					rY1 = 0
					rY2 = 0
					rY3 = 0
					rY4 = 0
					rY5 = 0
					rY6 = 0
					rY7 = 0
					rY8 = 0

					rZ1 = 0
					rZ2 = 0
					rZ3 = 0
					rZ4 = 0
					rZ5 = 0
					rZ6 = 0
					rZ7 = 0
					rZ8 = 0
				end
				if sZ < 0.625 then
					setVehicleComponentPosition(v, "movspoiler_1", sX, sY-0.003, sZ+0.003)
					setVehicleComponentRotation(v, "movspoiler_2", rX1-0.3, rY1, rZ1)
					setVehicleComponentRotation(v, "movspoiler_3", rX2-0.3, rY2, rZ2)
					setVehicleComponentRotation(v, "movspoiler_4", rX3-0.3, rY3, rZ3)
					setVehicleComponentRotation(v, "movspoiler_5", rX4-0.3, rY4, rZ4)
					setVehicleComponentRotation(v, "movspoiler_6", rX5-0.3, rY5, rZ5)
					setVehicleComponentRotation(v, "movspoiler_7", rX6-0.3, rY6, rZ6)
					setVehicleComponentRotation(v, "movspoiler_8", rX7-0.3, rY7, rZ7)
					setVehicleComponentRotation(v, "movspoiler_9", rX8-0.3, rY8, rZ8)
					drawSpoilerPos = false
				end
			elseif getElementData(v,"spoilerState") == "downed" then --nyillik
				if not sX then
					sX = 0
				end
				if not sY then
					sY = -2.0258500576019
				end
				if not sZ then
					sZ = 0.625
				end
				if not rX1 or not rY1 or not rZ1 then
					rX1 = 1.0499877929688 
					rX2 = 1.0499877929688 
					rX3 = 1.0499877929688 
					rX4 = 1.0499877929688 
					rX5 = 1.0499877929688 
					rX6 = 1.0499877929688 
					rX7 = 1.0499877929688 
					rX8 = 1.0499877929688 

					rY1 = 0
					rY2 = 0
					rY3 = 0
					rY4 = 0
					rY5 = 0
					rY6 = 0
					rY7 = 0
					rY8 = 0

					rZ1 = 0
					rZ2 = 0
					rZ3 = 0
					rZ4 = 0
					rZ5 = 0
					rZ6 = 0
					rZ7 = 0
					rZ8 = 0
				end
				if sZ >= 0.48 then
					setVehicleComponentPosition(v, "movspoiler_1", sX, sY+0.0015, sZ-0.0015)
					setVehicleComponentRotation(v, "movspoiler_2",rX1+0.15,rY1,rZ1)
					setVehicleComponentRotation(v, "movspoiler_3",rX2+0.15,rY2,rZ2)
					setVehicleComponentRotation(v, "movspoiler_4",rX3+0.15,rY3,rZ3)
					setVehicleComponentRotation(v, "movspoiler_5",rX4+0.15,rY4,rZ4)
					setVehicleComponentRotation(v, "movspoiler_6",rX5+0.15,rY5,rZ5)
					setVehicleComponentRotation(v, "movspoiler_7",rX6+0.15,rY6,rZ6)
					setVehicleComponentRotation(v, "movspoiler_8",rX7+0.15,rY7,rZ7)
					setVehicleComponentRotation(v, "movspoiler_9",rX8+0.15,rY8,rZ8)
					drawSpoilerPos = false
				end
			end
		end
	end
end
addEventHandler("onClientRender", root, kmhForgas)

addCommandHandler("getspoilerpos", function()
	if drawSpoilerPos == false then
		drawSpoilerPos = true
	elseif drawSpoilerPos == true then
		drawSpoilerPos = false
	end
end)

function startingMove(button, press)
    if (press) and button == "o" then
		local theVeh = getPedOccupiedVehicle(localPlayer)
        if getPedOccupiedVehicle(localPlayer) then
			if getVehicleOccupant(theVeh) == localPlayer then
				local spd = getElementSpeed(theVeh, "kmh")
				if spd == 0 then
					if getElementData(theVeh, "spoilerState") == "downed" then
						setElementData(theVeh, "spoilerState", "upped")
					elseif getElementData(theVeh, "spoilerState") == "upped" then
						setElementData(theVeh, "spoilerState", "downed")
					end
				else
					if getElementModel(theVeh) == 442 then
						outputChatBox("#ff9428[Veh]#ffffff A spoilert csak álló helyzetben tudod nyitni/zárni!",255,255,255,true)
					end	
				end
			end
        end
    end
end
addEventHandler("onClientKey", root, startingMove)

function breaking()
	for k, v in pairs(getElementsByType("vehicle", true, getRootElement())) do
		if getElementModel(v) == 442 then --442
			if getElementData(v,"spoilerState") == "upped" then
				local rX, rY, rZ = getVehicleComponentRotation(v, "movspoiler_1")
				local rX1, rY1, rZ1 = getVehicleComponentRotation(v, "movspoiler_2")
				local rX2, rY2, rZ2 = getVehicleComponentRotation(v, "movspoiler_3")
				local rX3, rY3, rZ3 = getVehicleComponentRotation(v, "movspoiler_4")
				local rX4, rY4, rZ4 = getVehicleComponentRotation(v, "movspoiler_5")
				local rX5, rY5, rZ5 = getVehicleComponentRotation(v, "movspoiler_6")
				local rX6, rY6, rZ6 = getVehicleComponentRotation(v, "movspoiler_7")
				local rX7, rY7, rZ7 = getVehicleComponentRotation(v, "movspoiler_8")
				local rX8, rY8, rZ8 = getVehicleComponentRotation(v, "movspoiler_9")
				if getKeyState("space") or getKeyState("s") then
					local spd = getElementSpeed(v, "kmh")
					if spd > 0 then
						local rX, rY, rZ = getVehicleComponentRotation(v, "movspoiler_1")
						local rX1, rY1, rZ1 = getVehicleComponentRotation(v, "movspoiler_2")
						local rX2, rY2, rZ2 = getVehicleComponentRotation(v, "movspoiler_3")
						local rX3, rY3, rZ3 = getVehicleComponentRotation(v, "movspoiler_4")
						local rX4, rY4, rZ4 = getVehicleComponentRotation(v, "movspoiler_5")
						local rX5, rY5, rZ5 = getVehicleComponentRotation(v, "movspoiler_6")
						local rX6, rY6, rZ6 = getVehicleComponentRotation(v, "movspoiler_7")
						local rX7, rY7, rZ7 = getVehicleComponentRotation(v, "movspoiler_8")
						local rX8, rY8, rZ8 = getVehicleComponentRotation(v, "movspoiler_9")
						if not rX then
							rX = 0
							rY = 0
							rZ = 0
						end
						if not rX1 then
							rX1 = 0
							rY1 = 0
							rZ1 = 0
						end
						if not rX2 then
							rX2 = 0
							rY2 = 0
							rZ2 = 0
						end
						if not rX3 then
							rX3 = 0
							rY3 = 0
							rZ3 = 0
						end
						if not rX4 then
							rX4 = 0
							rY4 = 0
							rZ4 = 0
						end
						if not rX5 then
							rX5 = 0
							rY5 = 0
							rZ5 = 0
						end
						if not rX6 then
							rX6 = 0
							rY6 = 0
							rZ6 = 0
						end
						if not rX7 then
							rX7 = 0
							rY7 = 0
							rZ7 = 0
						end
						if not rX8 then
							rX8 = 0
							rY8 = 0
							rZ8 = 0
						end
						if rX > 350 or rX == 0.25 or rX < 0.25 then
							setVehicleComponentRotation(v, "movspoiler_1",rX-0.55,rY,rZ)
							setVehicleComponentRotation(v, "movspoiler_2",rX1-0.75,rY1,rZ1)
							setVehicleComponentRotation(v, "movspoiler_3",rX2-0.75,rY2,rZ2)
							setVehicleComponentRotation(v, "movspoiler_4",rX3-0.75,rY3,rZ3)
							setVehicleComponentRotation(v, "movspoiler_5",rX4-0.75,rY4,rZ4)
							setVehicleComponentRotation(v, "movspoiler_6",rX5-0.75,rY5,rZ5)
							setVehicleComponentRotation(v, "movspoiler_7",rX6-0.75,rY6,rZ6)
							setVehicleComponentRotation(v, "movspoiler_8",rX7-0.75,rY7,rZ7)
							setVehicleComponentRotation(v, "movspoiler_9",rX8-0.75,rY8,rZ8)
						end
					end
				else
					local rX, rY, rZ = getVehicleComponentRotation(v, "movspoiler_1")
					local rX1, rY1, rZ1 = getVehicleComponentRotation(v, "movspoiler_2")
					local rX2, rY2, rZ2 = getVehicleComponentRotation(v, "movspoiler_3")
					local rX3, rY3, rZ3 = getVehicleComponentRotation(v, "movspoiler_4")
					local rX4, rY4, rZ4 = getVehicleComponentRotation(v, "movspoiler_5")
					local rX5, rY5, rZ5 = getVehicleComponentRotation(v, "movspoiler_6")
					local rX6, rY6, rZ6 = getVehicleComponentRotation(v, "movspoiler_7")
					local rX7, rY7, rZ7 = getVehicleComponentRotation(v, "movspoiler_8")
					local rX8, rY8, rZ8 = getVehicleComponentRotation(v, "movspoiler_9")
					if not rX then
						rX = 0
						rY = 0
						rZ = 0
					end
					if not rX1 then
						rX1 = 0
						rY1 = 0
						rZ1 = 0
					end
					if not rX2 then
						rX2 = 0
						rY2 = 0
						rZ2 = 0
					end
					if not rX3 then
						rX3 = 0
						rY3 = 0
						rZ3 = 0
					end
					if not rX4 then
						rX4 = 0
						rY4 = 0
						rZ4 = 0
					end
					if not rX5 then
						rX5 = 0
						rY5 = 0
						rZ5 = 0
					end
					if not rX6 then
						rX6 = 0
						rY6 = 0
						rZ6 = 0
					end
					if not rX7 then
						rX7 = 0
						rY7 = 0
						rZ7 = 0
					end
					if not rX8 then
						rX8 = 0
						rY8 = 0
						rZ8 = 0
					end
					if rX > 0.25 then
						setVehicleComponentRotation(v, "movspoiler_1",rX+0.55,rY,rZ)
						setVehicleComponentRotation(v, "movspoiler_2",rX1+0.75,rY1,rZ1)
						setVehicleComponentRotation(v, "movspoiler_3",rX2+0.75,rY2,rZ2)
						setVehicleComponentRotation(v, "movspoiler_4",rX3+0.75,rY3,rZ3)
						setVehicleComponentRotation(v, "movspoiler_5",rX4+0.75,rY4,rZ4)
						setVehicleComponentRotation(v, "movspoiler_6",rX5+0.75,rY5,rZ5)
						setVehicleComponentRotation(v, "movspoiler_7",rX6+0.75,rY6,rZ6)
						setVehicleComponentRotation(v, "movspoiler_8",rX7+0.75,rY7,rZ7)
						setVehicleComponentRotation(v, "movspoiler_9",rX8+0.75,rY8,rZ8)
					end
				end
			end
		end
	end
end
addEventHandler("onClientRender", root, breaking)

function getElementSpeed(element, unit)
    if (unit == nil) then
        unit = 0
    end
    if (isElement(element)) then
        local x, y, z = getElementVelocity(element)
        if (unit == "mph" or unit == 1 or unit == '1') then
            return math.floor((x^2 + y^2 + z^2) ^ 0.5 * 100)
        else
            return math.floor((x^2 + y^2 + z^2) ^ 0.5 * 100 * 1.609344)
        end
    else
        return false
    end
end