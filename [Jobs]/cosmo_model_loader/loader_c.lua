local waitingLoads = {}

local counters = {
    ["object"] = {0,0,0},
    ["skin"] = {0,0,0},
    ["vehicle"] = {0,0,0},
}

local loadedModels = 0

function startModelLoading()
    loadModels()
    setElementFrozen(localPlayer,true)
    loadedModels = 0
end

local loadTick = getTickCount()


function loadModels()
    for k, v in ipairs(models) do 
        setTimer(function() 
            loadTick = getTickCount()
            if v[2] == "object" then 
                local folder = v.folder or ""
                
                if string.len(folder) > 0 then
                    folder = folder.."/"
                end

                if v.key then
                    local txdFile = "txd.cosmomodel"

                    if v.txdNotComplied then 
                        txdFile = ".txd"
                    end

                    if v[4] then 
                        if not fileExists("models/objects/"..folder..v[4]..txdFile) then
                            outputDebugString("Nem található TXD fájl! (Lista ID:"..k.."; Fájl név:"..v[4]..txdFile.."; Típus: OBJECT)",0,220,0,0)
                            counters["object"][2] = counters["object"][2] + 1
                            return 
                        end
                    end 

                    if not fileExists("models/objects/"..folder..v[3].."dff.cosmomodel") then
                        outputDebugString("Nem található DFF fájl! (Lista ID:"..k.."; Fájl név:"..v[3]..".dff; Típus: OBJECT)",0,220,0,0)
                        counters["object"][2] = counters["object"][2] + 1
                        return 
                    end

                    if not (colLoad_disallowdFolders[v.folder]) then 
                        if not fileExists("models/objects/"..folder..v[3].."col.cosmomodel") then
                            outputDebugString("Nem található COL fájl! (Lista ID:"..k.."; Fájl név:"..v[3]..".dff; Típus: OBJECT)",0,220,0,0)
                            counters["object"][2] = counters["object"][2] + 1
                            return 
                        end

                        local glass = v.transparent or false

                        if v[4] then 
                            exports.cosmo_compiler_job:loadCompliedModel(v[5], v.key, ":cosmo_model_loader/models/objects/"..folder..v[3].."dff.cosmomodel", ":cosmo_model_loader/models/objects/"..folder..v[4]..txdFile, ":cosmo_model_loader/models/objects/"..folder..v[3].."col.cosmomodel", glass)
                        else
                            exports.cosmo_compiler_job:loadCompliedModel(v[5], v.key, ":cosmo_model_loader/models/objects/"..folder..v[3].."dff.cosmomodel", _, ":cosmo_model_loader/models/objects/"..folder..v[3].."col.cosmomodel", glass)
                        end
                    else
                        local glass = v.transparent or false

                        if v[4] then 
                            exports.cosmo_compiler_job:loadCompliedModel(v[5], v.key, ":cosmo_model_loader/models/objects/"..folder..v[3].."dff.cosmomodel", ":cosmo_model_loader/models/objects/"..folder..v[4]..txdFile, _, glass)
                        else
                            exports.cosmo_compiler_job:loadCompliedModel(v[5], v.key, ":cosmo_model_loader/models/objects/"..folder..v[3].."dff.cosmomodel", _, _, glass)
                        end
                    end
                else
                    if fileExists("models/objects/"..folder..v[4]..".txd") then
                        local txd = engineLoadTXD("models/objects/"..folder..v[4]..".txd")
                        if not engineImportTXD(txd, v[5]) then 
                            outputDebugString("Ismeretlen hiba a TXD fájl betöltése közben! :( (Lista ID:"..k.."; Fájl név:"..v[4]..".txd; Típus: OBJ)",0,200,0,0)
                            counters["skin"][3] = counters["skin"][3] + 1
                            return 
                        end
                    else
                        outputDebugString("Nem található TXD fájl! (Lista ID:"..k.."; Fájl név:"..v[4]..".txd; Típus: SKIN)",0,220,0,0)
                        counters["skin"][2] = counters["skin"][2] + 1
                        return 
                    end
    
                    if fileExists("models/objects/"..folder..v[3]..".dff") then
                        local dff = engineLoadDFF("models/objects/"..folder..v[3]..".dff")
                        if not engineReplaceModel(dff, v[5]) then 
                            outputDebugString("Ismeretlen hiba a DFF fájl betöltése közben! :( (Lista ID:"..k.."; Fájl név:"..v[3]..".dff; Típus: OBJ)",0,200,0,0)
                            counters["skin"][3] = counters["skin"][3] + 1
                            return 
                        end
                    else
                        outputDebugString("Nem található DFF fájl! (Lista ID:"..k.."; Fájl név:"..v[3]..".dff; Típus: SKIN)",0,220,0,0)
                        counters["skin"][2] = counters["skin"][2] + 1
                        return 
                    end
                end

                outputDebugString("Object: "..v[3].." betöltése sikeres!",0,0,220,0)
                counters["object"][1] = counters["object"][1] +1
            elseif v[2] == "skin" then 
                if fileExists("models/skins/"..v[4]..".txd") then
                    local txd = engineLoadTXD("models/skins/"..v[4]..".txd")
                    if not engineImportTXD(txd, v[5]) then 
                        outputDebugString("Ismeretlen hiba a TXD fájl betöltése közben! :( (Lista ID:"..k.."; Fájl név:"..v[4]..".txd; Típus: SKIN)",0,200,0,0)
                        counters["skin"][3] = counters["skin"][3] + 1
                        return 
                    end
                else
                    outputDebugString("Nem található TXD fájl! (Lista ID:"..k.."; Fájl név:"..v[4]..".txd; Típus: SKIN)",0,220,0,0)
                    counters["skin"][2] = counters["skin"][2] + 1
                    return 
                end

                if fileExists("models/skins/"..v[3]..".dff") then
                    local dff = engineLoadDFF("models/skins/"..v[3]..".dff")
                    if not engineReplaceModel(dff, v[5]) then 
                        outputDebugString("Ismeretlen hiba a DFF fájl betöltése közben! :( (Lista ID:"..k.."; Fájl név:"..v[3]..".dff; Típus: SKIN)",0,200,0,0)
                        counters["skin"][3] = counters["skin"][3] + 1
                        return 
                    end
                else
                    outputDebugString("Nem található DFF fájl! (Lista ID:"..k.."; Fájl név:"..v[3]..".dff; Típus: SKIN)",0,220,0,0)
                    counters["skin"][2] = counters["skin"][2] + 1
                    return 
                end

                --outputDebugString("Skin: "..v[3].." betöltése sikeres!",0,0,220,0)
                counters["skin"][1] = counters["skin"][1] +1
            elseif v[2] == "vehicle" then 
                if fileExists("models/vehicles/"..v[4]..".txd") then
                    local txd = engineLoadTXD("models/vehicles/"..v[4]..".txd")
                    if not engineImportTXD(txd, v[5]) then 
                        outputDebugString("Ismeretlen hiba a TXD fájl betöltése közben! :( (Lista ID:"..k.."; Fájl név:"..v[4]..".txd; Típus: VEHICLE)",0,200,0,0)
                        counters["vehicle"][3] = counters["vehicle"][3] + 1
                        return 
                    end
                else
                    outputDebugString("Nem található TXD fájl! (Lista ID:"..k.."; Fájl név:"..v[4]..".txd; Típus: VEHICLE)",0,220,0,0)
                    counters["vehicle"][2] = counters["vehicle"][2] + 1
                    return 
                end

                if fileExists("models/vehicles/"..v[3]..".dff") then
                    local dff = engineLoadDFF("models/vehicles/"..v[3]..".dff")
                    if not engineReplaceModel(dff, v[5]) then 
                        outputDebugString("Ismeretlen hiba a DFF fájl betöltése közben! :( (Lista ID:"..k.."; Fájl név:"..v[3]..".dff; Típus: VEHICLE)",0,200,0,0)
                        counters["vehicle"][3] = counters["vehicle"][3] + 1
                        return 
                    end
                else
                    outputDebugString("Nem található DFF fájl! (Lista ID:"..k.."; Fájl név:"..v[3]..".dff; Típus: VEHICLE)",0,220,0,0)
                    counters["vehicle"][2] = counters["vehicle"][2] + 1
                    return 
                end

                --outputDebugString("Jármű: "..v[3].." betöltése sikeres!",0,0,220,0)
                counters["vehicle"][1] = counters["vehicle"][1] +1
            else
                outputDebugString("Ismeretlen modell típus! (Lista ID:"..k.."; Típus:"..v[2]..")",0,200,0,0)
            end
            loadedModels = loadedModels + 1
        end, waiting_time*k, 1)
    end

    setTimer(loadEnd, waiting_time*#models,1)
end

function loadEnd()
    displayAllModelInfo()
    setElementFrozen(localPlayer,false)
end

function displayAllModelInfo()
    --outputDebugString("Összegzés:",0,50, 135, 168)
    --outputDebugString(" Skin betöltések:",0,81, 171, 207)
    --outputDebugString(" ~ Sikeres skin betöltések: " .. counters["skin"][1].. " db",0,154, 189, 109)
    --outputDebugString(" ~ Sikertelen skin betöltések (Nem található fájl): " .. counters["skin"][2].. " db",0,201, 124, 89)
    --outputDebugString(" ~ Sikertelen skin betöltések (Ismeretlen hiba): " ..counters["skin"][3] .." db",0,201, 124, 89)

    --outputDebugString(" Object betöltések:",0,81, 171, 207)
    --outputDebugString(" ~ Sikeres object betöltések: " .. counters["object"][1].. " db",0,154, 189, 109)
    --outputDebugString(" ~ Sikertelen object betöltések (Nem található fájl): " .. counters["object"][2].. " db",0,201, 124, 89)
    --outputDebugString(" ~ Sikertelen object betöltések (Ismeretlen hiba): " ..counters["object"][3] .." db",0,201, 124, 89)

    --outputDebugString(" Jármű betöltések:",0,81, 171, 207)
    --outputDebugString(" ~ Sikeres jármű betöltések: " .. counters["vehicle"][1].. " db",0,154, 189, 109)
    --outputDebugString(" ~ Sikertelen jármű betöltések (Nem található fájl): " .. counters["vehicle"][2].. " db",0,201, 124, 89)
    --outputDebugString(" ~ Sikertelen jármű betöltések (Ismeretlen hiba): " ..counters["vehicle"][3] .." db",0,201, 124, 89)
end

local sx, sy = guiGetScreenSize()
local myX, myY = 1600, 900 


function renderLoadingScreen()
    --dxDrawRectangle(sx*0.8, 0, sx*0.2, sy*0.04, tocolor(32, 32, 32, 255), true)
    --core:dxDrawShadowedText("A modellek betöltése folyamatban! \n"..color.."("..loadedModels.."/"..#models..")", 0, sy*0.8, sx, sy*0.9, tocolor(255, 255, 255, 255), tocolor(0, 0, 0, 255), 1, font:getFont("condensed", 13/myX*sx), "center", "center", _, _, true, true)

    --local value = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount()-loadTick)/waiting_time, "Linear")
    --dxDrawRectangle(0, sy*0.98, sx*value, sy*0.02, tocolor(r, g, b))
    -- dxDrawText(100*value.."%", 0, sy*0.98, sx*value, sy, tocolor(30, 30, 30, 255), 1, font:getFont("condensed", 10/myX*sx), "center", "center")
end
--addEventHandler("onClientRender", root, renderLoadingScreen)

startModelLoading()