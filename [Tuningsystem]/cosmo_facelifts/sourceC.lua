local shaders = {}
local textures = {}

--addCommandHandler("cDB", function()
	--print("2022 / 9 / 1 : FACELIFT - PAINTJOB")
	--print("2022 / 9 / 1 : FACELIFT - PAINTJOB")
	--print("2022 / 9 / 1 : FACELIFT - PAINTJOB")
	--print("2022 / 9 / 1 : FACELIFT - PAINTJOB")
	--print("2022 / 9 / 1 : FACELIFT - PAINTJOB")
	--print("2022 / 9 / 1 : FACELIFT - PAINTJOB")
	--print("2022 / 9 / 1 : FACELIFT - PAINTJOB")
--end)



addEventHandler("onClientElementStreamOut", getRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			local faceliftId = getElementData(source, "danihe->vehicles->facelift") or 0

			if faceliftId > 0 then
				removeVehicleFacelift(source)
			end
		end
	end
)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			local faceliftId = getElementData(source, "danihe->vehicles->facelift") or 0

			if faceliftId > 0 then
				setVehicleFacelift(source, faceliftId)
			end
		end
	end
)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in ipairs(getElementsByType("vehicle", getRootElement(), true)) do
			local faceliftId = getElementData(v, "danihe->vehicles->facelift") or 0

			if faceliftId > 0 then
				setVehicleFacelift(v, faceliftId)
			end
		end
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldValue, newValue)
		if dataName == "danihe->vehicles->facelift" then
			if not newValue or newValue == 0 then
				removeVehicleFacelift(source)
				--print("newfaceliftApplied")
			else
				setVehicleFacelift(source, newValue)
			end
		end
	end
)

function setVehicleFacelift(vehicle, faceliftId)
	if isElement(vehicle) then
		if faceliftId then
			local model = getElementModel(vehicle)

			faceliftId = tonumber(faceliftId)

			if facelifts[model] then
				if faceliftId <= 0 or faceliftId > #facelifts[model] then
					removeVehicleFacelift(vehicle)
					return
				end

				if not shaders[vehicle] then
					shaders[vehicle] = dxCreateShader("files/changer.fx", 0, 100, false, "vehicle")
				end

				local k = "files/facelifts/" .. model .. "/" .. facelifts[model][faceliftId][2]

				if not textures[k] then
					textures[k] = dxCreateTexture(k, "dxt3")
				end

				if isElement(shaders[vehicle]) and isElement(textures[k]) then
					dxSetShaderValue(shaders[vehicle], "TEXTURE", textures[k])
					engineApplyShaderToWorldTexture(shaders[vehicle], facelifts[model][faceliftId][1], vehicle)
				end
			end
		end
	end
end

function removeVehicleFacelift(vehicle)
	if isElement(vehicle) then
		if isElement(shaders[vehicle]) then
			destroyElement(shaders[vehicle])
		end

		shaders[vehicle] = nil
	end
end