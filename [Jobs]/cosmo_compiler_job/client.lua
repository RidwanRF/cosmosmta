addCommandHandler("compile", function(cmd, file, fileType, keyID)
    if file and type and keyID then 
        compileFile(file, fileType, keyID)
    else
        outputChatBox("Használat: /"..cmd.." [File] [Kiterjesztés] [Key]", 255, 255, 255, true)
    end
end)

function compileFile(fileName, type, key)
    outputChatBox("Start file compile. File: "..fileName.."."..type)

    --if file then 
        local filePath = tostring(fileName.."."..type)
        --file = fileOpen(":cosmo_compiler_job/502.dff", false)
        openedFile = fileOpen(":cosmo_compiler_job/"..filePath, true)

        if openedFile then 
            local count = fileGetSize(openedFile)
            local fileData = fileRead(openedFile, fileGetSize(openedFile))

            --print(fileData)

            local newData = teaEncode(base64Encode(fileData), key)

            if fileExists(fileName..type..".cosmomodel") then
                fileDelete(fileName..type..".cosmomodel")
              end

            local compliedFile = fileCreate(fileName..type..".cosmomodel")

            fileWrite(compliedFile, newData)
            fileClose(compliedFile)

            fileClose(openedFile)
            fileDelete(":cosmo_compiler_job/"..filePath)

            outputChatBox("Compile completed")
        end
    --end
end

function loadCompliedModel(modelID, key, dffSRC, txdSRC, colSRC, applyTransparency, isTXDNotComplied)
    local txd = false
    local dff = false
    local col = false

    if txdSRC then 
        txd = fileOpen(txdSRC)
    end

    if dffSRC then 
        dff = fileOpen(dffSRC)
    end

    if colSRC then 
        col = fileOpen(colSRC)
    end

    local txdData = false
    local dffData = false
    local colData = false

    if txd then 
        txdData = fileRead(txd, fileGetSize(txd))
    end

    if dff then 
        dffData = fileRead(dff, fileGetSize(dff))
    end

    if col then 
        colData = fileRead(col, fileGetSize(col))
    end

    if txd then 
        fileClose(txd)
    end

    if dff then 
        fileClose(dff)
    end

    if col then 
        fileClose(col)
    end

    if txdData then 
        if not isTXDNotComplied then
            txdData = base64Decode(teaDecode(txdData, key))
            local loadedTXD = engineLoadTXD(txdData, true)

            if loadedTXD then 
                if not engineImportTXD(loadedTXD, modelID) then 
                    engineImportTXD(loadedTXD, modelID)
                end
            end
        else
            engineImportTXD(txdSRC, modelID)
        end
    end

    if dffData then 
        dffData = base64Decode(teaDecode(dffData, key))
        local loadedDFF = engineLoadDFF(dffData)
        engineReplaceModel(loadedDFF, modelID, applyTransparency)
    end

    if colData then 
        colData = base64Decode(teaDecode(colData, key))
        loadedCol = engineLoadCOL(colData)
        engineReplaceCOL(loadedCol, modelID)
    end

    engineSetModelLODDistance(modelID, 20000)
end