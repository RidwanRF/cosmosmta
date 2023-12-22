local previewBlockObject = false
local blockObjects = {}
local blockOffsets = {
	[516] = {0, 1.8, 0.35}, -- dodge charger srt hellcat
	[500] = {0, 1.8, 0.55}, -- jeep grand cherokee
	[517] = {0, 1.8, 0.35}, -- dodge coronet
	[546] = {0, 1.8, 0.58}, -- dodge charger srt8
	[426] = {0, 1.8, 0.35} -- dodge demon
}

addEventHandler("onClientResourceStart", getResourceRootElement(),
function ()
	local txd = engineLoadTXD("files/block.txd")
	engineImportTXD(txd, 2052)
	local dff = engineLoadDFF("files/block.dff")
	engineReplaceModel(dff, 2052)

	for k, v in pairs(getElementsByType("vehicle", getRootElement(), true)) do
		if getElementData(v, "danihe->tuning->turbo") == 5 then
			local vehicleModel = getElementModel(v)
			
			if blockOffsets[vehicleModel] then
				blockObjects[v] = createObject(2052, 0, 0, 0)
				
				attachElements(blockObjects[v], v, unpack(blockOffsets[vehicleModel]))
				setElementCollisionsEnabled(blockObjects[v], false)
				
				local x, y, z = getElementPosition(v)

				setElementPosition(v, x, y, z + 0.01)
				setElementPosition(v, x, y, z)
			end
		end
	end
end)

addEventHandler("onClientElementDestroy", getRootElement(),
function ()
	if blockObjects[source] then
		if isElement(blockObjects[source]) then
			destroyElement(blockObjects[source])
		end

		blockObjects[source] = nil
	end
end)

addEventHandler("onClientElementStreamOut", getRootElement(),
function ()
	if blockObjects[source] then
		if isElement(blockObjects[source]) then
			destroyElement(blockObjects[source])
		end
		
		blockObjects[source] = nil
	end
end)

addEventHandler("onClientElementStreamIn", getRootElement(),
function ()
	if blockObjects[source] then
		if isElement(blockObjects[source]) then
			destroyElement(blockObjects[source])
		end
		
		blockObjects[source] = nil
	end

	if getElementData(source, "danihe->tuning->turbo") == 5 then
		local vehicleModel = getElementModel(source)
			
		if blockOffsets[vehicleModel] then
			blockObjects[source] = createObject(2052, 0, 0, 0)
			
			attachElements(blockObjects[source], source, unpack(blockOffsets[vehicleModel]))
			setElementCollisionsEnabled(blockObjects[source], false)
			
			local x, y, z = getElementPosition(source)

			setElementPosition(source, x, y, z + 0.01)
			setElementPosition(source, x, y, z)
		end
	end
end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldValue)
		--if source == localPlayer then

		if dataName == "danihe->tuning->turbo" then
			if blockObjects[source] then
				if isElement(blockObjects[source]) then
					destroyElement(blockObjects[source])
				end
				
				blockObjects[source] = nil
			end

				if getElementData(source, "danihe->tuning->turbo") == 5 then
					if isElementStreamedIn(source) then
						local vehicleModel = getElementModel(source)
							
						if blockOffsets[vehicleModel] then
							blockObjects[source] = createObject(2052, 0, 0, 0)
							
							attachElements(blockObjects[source], source, unpack(blockOffsets[vehicleModel]))
							setElementCollisionsEnabled(blockObjects[source], false)
							
							local x, y, z = getElementPosition(source)

							setElementPosition(source, x, y, z + 0.01)
							setElementPosition(source, x, y, z)
						end
					end
				end
			end
		--end
	end
)