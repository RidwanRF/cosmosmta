local shaders = {}
local textures = {}

addCommandHandler("cDB", function()
	print("2022 / 9 / 1 : WHEELTEXTURE - PAINTJOB")
	print("2022 / 9 / 1 : WHEELTEXTURE - PAINTJOB")
	print("2022 / 9 / 1 : WHEELTEXTURE - PAINTJOB")
	print("2022 / 9 / 1 : WHEELTEXTURE - PAINTJOB")
	print("2022 / 9 / 1 : WHEELTEXTURE - PAINTJOB")
	print("2022 / 9 / 1 : WHEELTEXTURE - PAINTJOB")
	print("2022 / 9 / 1 : WHEELTEXTURE - PAINTJOB")
end)

addEventHandler("onClientElementStreamOut", getRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			local wheeltextureID = getElementData(source, "danihe->vehicles->wheeltexture") or 0

			if wheeltextureID > 0 then
				removeVehicleWheeltexture(source)
			end
		end
	end
)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			local wheeltextureID = getElementData(source, "danihe->vehicles->wheeltexture") or 0

			if wheeltextureID > 0 then
				setVehicleWheeltexture(source, wheeltextureID)
			end
		end
	end
)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in ipairs(getElementsByType("vehicle", getRootElement(), true)) do
			local wheeltextureID = getElementData(v, "danihe->vehicles->wheeltexture") or 0

			if wheeltextureID > 0 then
				setVehicleWheeltexture(v, wheeltextureID)
			end
		end
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldValue, newValue)
		if dataName == "danihe->vehicles->wheeltexture" then
			if not newValue or newValue == 0 then
				removeVehicleWheeltexture(source)
			else
				setVehicleWheeltexture(source, newValue)
			end
		end
	end
)

function setVehicleWheeltexture(vehicle, wheeltextureID)
	if isElement(vehicle) then
		if wheeltextureID then
			local model = getElementModel(vehicle)

			wheeltextureID = tonumber(wheeltextureID)

			if wheeltextures[model] then
				if wheeltextureID <= 0 or wheeltextureID > #wheeltextures[model] then
					removeVehicleWheeltexture(vehicle)
					return
				end

				if not shaders[vehicle] then
					shaders[vehicle] = dxCreateShader("files/changer.fx", 0, 100, false, "vehicle")
				end

				local k = "files/wheeltextures/" .. model .. "/" .. wheeltextures[model][wheeltextureID][2]

				if not textures[k] then
					textures[k] = dxCreateTexture(k, "dxt3")
				end

				if isElement(shaders[vehicle]) and isElement(textures[k]) then
					dxSetShaderValue(shaders[vehicle], "TEXTURE", textures[k])
					engineApplyShaderToWorldTexture(shaders[vehicle], wheeltextures[model][wheeltextureID][1], vehicle)
				end
			end
		end
	end
end

function removeVehicleWheeltexture(vehicle)
	if isElement(vehicle) then
		if isElement(shaders[vehicle]) then
			destroyElement(shaders[vehicle])
		end

		shaders[vehicle] = nil
	end
end