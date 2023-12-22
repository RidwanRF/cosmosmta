function replaceModel(fileName, modelID, applyTransparency)
    if fileExists(fileName .. ".txd") then
    	modelTXD = engineLoadTXD(fileName .. ".txd")

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

        replaceModel("erik/Bob_H", 16103, false)
        replaceModel("zee/CEhillhouse01", 13755, true)
        --replaceModel("ichben/ichben", 13872, false)
        engineSetModelLODDistance(16103, 500)   
        --engineSetModelLODDistance(9487, 500)   

	end 
)


