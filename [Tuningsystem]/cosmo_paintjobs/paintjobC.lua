local pjTextures = {};
local pjCache = {};




addEventHandler("onClientResourceStart",resourceRoot,function()
    for name,_ in pairs(paintjobs) do
        if fileExists("paintjobs/"..name..".png") then 
            pjTextures[name] = dxCreateTexture("paintjobs/"..name..".png","dxt5");
        end
    end;
    setTimer(function()
        Async:foreach(getElementsByType("vehicle",root,true),function(v)
            local value = getElementData(v,"tuning.paintJob");
            if value then 
                addPaintJob(v,value);
            end
        end);
    end,100,1);
end)     
function addPaintJob(veh,name)
    setTimer(function()
        if name == "gold" and pjTextures[name] and fileExists("paintjobs/"..name..".png") and veh then
            removePaintJob(veh);
            local shader = dxCreateShader("hl_gold.fx")
            local gold = {0.9, 0.643, 0}--arany
            dxSetShaderValue(shader, "gSurfaceColor", unpack(gold))
            dxSetShaderValue(shader, "gFuzzySpecColor", unpack(gold))
            dxSetShaderValue(shader, "gSubColor", unpack(gold))
            pjCache[veh] = {shader,name}
            engineApplyShaderToWorldTexture(shader,paintjobs[name][2] or "*remap*",veh)
        elseif name == "silver" and pjTextures[name] and fileExists("paintjobs/"..name..".png") and veh then
            removePaintJob(veh);
            local shader = dxCreateShader("hl_gold.fx")
            local silver = {0.6, 0.6, 0.6} -- ezüst
            dxSetShaderValue(shader, "gSurfaceColor", unpack(silver))
            dxSetShaderValue(shader, "gFuzzySpecColor", unpack(silver))
            dxSetShaderValue(shader, "gSubColor", unpack(silver))
            engineApplyShaderToWorldTexture(shader,paintjobs[name][2] or "*remap*",veh)
            pjCache[veh] = {shader,name}
        elseif name == "purple" and pjTextures[name] and fileExists("paintjobs/"..name..".png") and veh then
            removePaintJob(veh);
            local shader = dxCreateShader("hl_gold.fx")
            local purple = {0.301, 0, 0.345} -- lila
            dxSetShaderValue(shader, "gSurfaceColor", unpack(purple))
            dxSetShaderValue(shader, "gFuzzySpecColor", unpack(purple))
            dxSetShaderValue(shader, "gSubColor", unpack(purple))
            engineApplyShaderToWorldTexture(shader,paintjobs[name][2] or "*remap*",veh)
            pjCache[veh] = {shader,name}
        elseif name == "black" and pjTextures[name] and fileExists("paintjobs/"..name..".png") and veh then
            removePaintJob(veh);
            local shader = dxCreateShader("hl_gold.fx")
            local black = {0.1, 0.1, 0.1} -- fekete
            dxSetShaderValue(shader, "gSurfaceColor", unpack(black))
            dxSetShaderValue(shader, "gFuzzySpecColor", unpack(black))
            dxSetShaderValue(shader, "gSubColor", unpack(black))
            engineApplyShaderToWorldTexture(shader,paintjobs[name][2] or "*remap*",veh)
            pjCache[veh] = {shader,name}
        elseif name == "red" and pjTextures[name] and fileExists("paintjobs/"..name..".png") and veh then
            removePaintJob(veh);
            local shader = dxCreateShader("hl_gold.fx")
            local red = {0.698, 0.133, 0.133} -- piros
            dxSetShaderValue(shader, "gSurfaceColor", unpack(red))
            dxSetShaderValue(shader, "gFuzzySpecColor", unpack(red))
            dxSetShaderValue(shader, "gSubColor", unpack(red))
            engineApplyShaderToWorldTexture(shader,paintjobs[name][2] or "*remap*",veh)
            pjCache[veh] = {shader,name}
        elseif name == "blue" and pjTextures[name] and fileExists("paintjobs/"..name..".png") and veh then
            removePaintJob(veh);
            local shader = dxCreateShader("hl_gold.fx")
            local blue = {0.255, 0.412, 0.882} -- kék
            dxSetShaderValue(shader, "gSurfaceColor", unpack(blue))
            dxSetShaderValue(shader, "gFuzzySpecColor", unpack(blue))
            dxSetShaderValue(shader, "gSubColor", unpack(blue))
            engineApplyShaderToWorldTexture(shader,paintjobs[name][2] or "*remap*",veh)
            pjCache[veh] = {shader,name}
        elseif name and pjTextures[name] and fileExists("paintjobs/"..name..".png") and veh then
            removePaintJob(veh);
            local shader = dxCreateShader("replace.fx",0,100);
            dxSetShaderValue(shader, "TEXTURE", pjTextures[name]);
            engineApplyShaderToWorldTexture(shader, paintjobs[name][2] or "*remap*", veh);
            pjCache[veh] = {shader,name};
        elseif name == "none" then
            if pjCache[veh] then 
                if pjCache[veh][1] then 
                    engineRemoveShaderFromWorldTexture(pjCache[veh][1],paintjobs[pjCache[veh][2]][2] or "*remap*",veh);
                    if isElement(pjCache[veh][1]) then 
                        destroyElement(pjCache[veh][1]);
                    end
                end
                pjCache[veh] = nil;
            end
        end
    end,200,1)
end

function removePaintJob(veh)
    if pjCache[veh] then 
        if pjCache[veh][1] then 
            engineRemoveShaderFromWorldTexture(pjCache[veh][1],paintjobs[pjCache[veh][2]][2] or "*remap*",veh);
            if isElement(pjCache[veh][1]) then 
                destroyElement(pjCache[veh][1]);
            end
        end
        pjCache[veh] = nil;
    end
end

addEventHandler("onClientElementDataChange",root,function(dataName,oldValue,newValue)
    if getElementType(source) == "vehicle" and isElementStreamedIn(source) then 
        if dataName == "tuning.paintJob" then 
            print("asd")
            if newValue then 
                print("rá")
                addPaintJob(source,newValue);
            end
        end
    end
end);

addEventHandler("onClientElementStreamIn", root, function()
    if getElementType(source) == "vehicle" then 
        local value = getElementData(source,"tuning.paintJob");
        if value then 
            addPaintJob(source,value);
        end
    end
end);

addEventHandler("onClientElementStreamOut", root, function()
    if getElementType(source) == "vehicle" then 
        removePaintJob(source);
    end
end);

addEventHandler("onClientElementDestroy", root, function()
    if getElementType(source) == "vehicle" then 
        removePaintJob(source);
    end
end);

addCommandHandler("gpj", function()
    print(inspect(getPaintJobs(getPedOccupiedVehicle(localPlayer))))
end)