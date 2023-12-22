function replaceModel(fileName, modelID, applyTransparency)
    if fileExists("textures.txd") then
    	modelTXD = engineLoadTXD("textures.txd")

    	engineImportTXD(modelTXD, modelID)
    end

    if fileExists(fileName .. ".dff") then
    	modelDFF = engineLoadDFF(fileName .. ".dff")

    	engineReplaceModel(modelDFF, modelID, applyTransparency)
    end

    if fileExists(fileName .. ".col") then
    	modelCOL = engineLoadCOL(fileName .. ".col")

    	engineReplaceCOL(modelCOL, modelID)
    end
end

addEventHandler("onClientResourceStart", resourceRoot,
	function ()
        removeWorldModel(7311, 100, 1918.8515625, -1776.328125, 16.9765625) -- Déli mosó
        removeWorldModel(7312, 100, 1918.8515625, -1776.328125, 16.9765625) -- Déli mosó LOD

        --createObject(11096, 1932.5999755859, -1782.0999755859, 12.5, 0, 0, 0) --Ablak geci

		replaceModel("laeroad38", 5503, false)
		replaceModel("building", 5489, false)
        replaceModel("glass", 11096, true)
        replaceModel("kutfej", 4337, false)

        engineSetModelLODDistance(5503, 300)
        engineSetModelLODDistance(5489, 300)
        engineSetModelLODDistance(11096, 300)
        engineSetModelLODDistance(4337, 300)
	end 
)

--createObject(5409, 1918.85, -1776.33, 16.9766)

