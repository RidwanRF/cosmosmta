
local sx,sy = guiGetScreenSize();
sColor = 246,137,52
sColor2 = 246,137,52
local colPos = { --BOXOK--
    {1809.7919921875, -1102.6157226562, 24.13906288147},  
    {1797.2066650391, -1102.0202636719, 24.13906288147}, 
    {1782.6138916016, -1102.4321289062, 24.13906288147},
    {1768.8581542969, -1101.3485107422, 23.43546295166}, ---s-d
    {1755.3745117188, -1101.1728515625, 23.43546295166},
    {1753.1644287109, -1131.8637695312, 24.935459136963},
    {1764.8493652344, -1132.3869628906, 24.935459136963},
    {1779.5457763672, -1132.6016845703, 24.935459136963},
    {1758.4627685547, -1794.0632324219, 13.537494659424},
    {1794.123046875, -1132.1674804688, 24.035499572754},


 -- 12

}
local isCol = false;
local componentList = {
    ["door_lf_dummy"] = {"bal első ajtó",1,2},
    ["door_rf_dummy"] = {"jobb első ajtó",1,3},
    ["door_lr_dummy"] = {"bal hátsó ajtó",1,4},
    ["door_rr_dummy"] = {"jobb hátsó ajtó",1,5},
    ["boot_dummy"] = {"csomagtartó",1,1, 6},
    ["bonnet_dummy"] = {"motorháztető",1,0},
    ["windscreen_dummy"] = {"szélvédő",1,0},

    ["bump_front_dummy"] = {"első lökhárító",2,5},
    ["bump_rear_dummy"] = {"hátsó lökhárító",2,6},

    ["wheel_lf_dummy"] = {"bal első kerék", 3, 1},
	["wheel_rf_dummy"] = {"jobb első kerék", 3, 3},
	["wheel_lb_dummy"] = {"bal hátsó kerék", 3, 2},
	["wheel_rb_dummy"] = {"jobb hátsó kerék", 3, 4},
}
local clickTick = 0;
local bugMarker = false;
local repairMarker = false;
local compSave = {};
local loading = {0,"Felszerelés",false,false,false,false};

--Cache Tables--
local sounds = {}
local cols = {};
local colVehicles = {};
local carryVehicles = {};
----------------

addEventHandler("onClientResourceStart",resourceRoot,function(res)
        font = dxCreateFont("sfcDisplaybold.ttf",15)
        font2 = dxCreateFont("sfcDisplaybold.ttf",15)
     
        compSave = false;

        setElementData(localPlayer,"mechanic.hand",false);
        setElementData(localPlayer,"mechanic.comp",false);
        setElementData(localPlayer,"isMechanicCol",false);

        for k,v in pairs(colPos) do 
            local x,y,z = unpack(v);
            local col = createColSphere(x,y,z,4.5);
            setElementData(col,"mechanic.col",true);
            cols[col] = true;

            addEventHandler("onClientColShapeHit",col,function(hitElement,dim)
                if hitElement == localPlayer and dim then 
                    if not isCol then 
                    if  exports.cosmo_groups:isPlayerInGroup(localPlayer,1)then
                            isCol = source;
                            colVehicles = {};
                            for k,v in pairs(getElementsByType("vehicle",_,true)) do 
                                if isElementWithinColShape(v,col) then 
                                    colVehicles[v] = true;
                                end
                            end
                            setElementData(localPlayer,"isMechanicCol",true);
                        end
                    end
                end 
                if getElementType(hitElement) == "vehicle" then 
                    if not colVehicles[hitElement] then 
                        colVehicles[hitElement] = true;
                    end
                end
            end);
            addEventHandler("onClientColShapeLeave",col,function(hitElement,dim)
                if hitElement == localPlayer and dim then 
                    if isCol then 
                        isCol = false;
                        colVehicles = {};
                        setElementData(localPlayer,"isMechanicCol",false);
                    end
                end
            end);
        end

        local r,g,b = 207,99,99
        bugMarker = createMarker(1784.8977050781, -1145.6636962891, 23.951822280884-2,"cylinder",3,r,g,b,150);
        setElementData(bugMarker,"bugmarker",true);
        setElementData(bugMarker, "3DText", "Elem kidobása")
        addEventHandler("onClientMarkerHit",bugMarker,function(hitElement,dim)
            if hitElement == localPlayer and dim and not isPedInVehicle(localPlayer) then 
                local carry = getElementData(localPlayer,"mechanic.hand");
                if carry then 
                    triggerServerEvent("mechanic.deleteHand",localPlayer,localPlayer);
                    triggerServerEvent("mechanic.applyAnimation2", localPlayer, localPlayer);
                else 

                end
            end
        end);


        r,g,b = 46,62,156
        repairMarker = createMarker(1812.4387207031, -1144.1619873047, 24.0224609375-2, "cylinder",2.5,r,g,b,150);
        --repairMarker2 = createMarker(1803.9305419922, -1751.8662109375, 12.546875,"cylinder",2.5,r,g,b,150)
        -- setElementData(repairMarker4,"repairmarker",true)
        -- setElementData(repairMarker3,"repairmarker",true)
        --setElementData(repairMarker2,"repairmarker",true)
        setElementData(repairMarker,"repairmarker",true)
        setElementData(repairMarker, "3DText", "Elem javítása")
        --setElementData(repairMarker2, "3DText", "Elem javítása")
        addEventHandler("onClientMarkerHit",getRootElement(),function(hitElement,dim)
            if hitElement == localPlayer and dim and not isPedInVehicle(localPlayer) then 
                if getElementData(source,"repairmarker") then
                if getElementData(localPlayer,"mechanic.hand") then 
                    local carry = getElementData(localPlayer,"mechanic.hand");
                    if getElementData(carry,"mechanic.repaired") then 
                       
                        return;
                    end
                    fixVehicle(carry);
                    setElementData(carry,"mechanic.repaired",true);
                   
                else 
                    if compSave and #compSave > 0 then 
                        triggerServerEvent("mechanic.down",localPlayer,localPlayer,compSave[1],compSave[2],compSave[3],compSave[4],true);
                        compSave = {};
                    else 

                    end
                end
            end
        end
        end);
    
end);

addEventHandler("onClientRender",root,function()
    if getElementData(localPlayer,"mechanic.hand") then
        toggleControl("fire", false)
        toggleControl("sprint", false)
        toggleControl("crouch", false)
        toggleControl("jump", false)
    end
    if getElementData(localPlayer,"mechanic.down") then
        toggleControl("fire", true)
        toggleControl("sprint", true)
        toggleControl("crouch", true)
        toggleControl("jump", true)
    end
    if getElementData(localPlayer, "mechanic.deleteHand") then
        toggleControl("fire", true)
        toggleControl("sprint", true)
        toggleControl("crouch", true)
        toggleControl("jump", true)
    end
    if getElementData(localPlayer, "mechanic.repaired") then
        toggleControl("fire", true)
        toggleControl("sprint", true)
        toggleControl("crouch", true)
        toggleControl("jump", true)
    end
    if getElementData(localPlayer, "mechanic.comp") then
        toggleControl("fire", true)
        toggleControl("sprint", true)
        toggleControl("crouch", true)
        toggleControl("jump", true)
    end
    if getElementData(localPlayer, "bugmarker") then
        toggleControl("fire", true)
        toggleControl("sprint", true)
        toggleControl("crouch", true)
        toggleControl("jump", true)
    end
    if isCol and not isPedInVehicle(localPlayer) then 
        for vehicle,valid in pairs(colVehicles) do 
            if isElement(vehicle) and not carryVehicles[vehicle] and isElementWithinColShape(vehicle,isCol) then 
                local count = 0;
                for k,v in pairs(componentList) do 
                    if validComponent(vehicle,k) then 
                        local wx,wy,wz = getVehicleComponentPosition(vehicle,k,"world");
                        local damaged = false;

                        if v[2] == 1 then --Ajtók
                            if getVehicleDoorState(vehicle,v[3]) > 0 then 
                                damaged = true;
                            end
                        end

                        if v[2] == 2 then --Panelek
                            if getVehiclePanelState(vehicle,v[3]) ~= 0 then 
                                damaged = true;
                            end
                        end

                        if v[2] == 3 then --Kerekek
                            local wheels = {getVehicleWheelStates(vehicle)};
                            if wheels[v[3]] ~= 0 then 
                                damaged = true;
                            end
                        end

                        if damaged then 
                            if wx and wy and wz then 
                                local x,y = getScreenFromWorldPosition(wx,wy,wz);
                                if x and y then 
                                    local w = dxGetTextWidth(v[1],1,font,false)+20;
                                    local color = tocolor(255,255,255);
                                    if isInSlot(x-w/2,y-5,w,30) then 
                                        color = tocolor(246,137,52,255);
                                        if getKeyState("mouse1") and clickTick+1500 < getTickCount() then 
                                            local carry = getElementData(localPlayer,"mechanic.hand");
                                            if not getVehicleComponentVisible(vehicle,k) then --Felszerelés
                                                if not carry then 
                                                    compSave = {vehicle,k,v[2],v[3]};
                                                    
                                                    clickTick = getTickCount();
                                                    return;
                                                end
                                                if getElementData(carry,"mechanic.comp") ~= k then 

                                                    clickTick = getTickCount();
                                                    return;
                                                end
                                                if not getElementData(carry,"mechanic.repaired") then 
                                                   
                                                    clickTick = getTickCount();
                                                    return;
                                                end
                                                triggerServerEvent("mechanic.applyAnimation", localPlayer, localPlayer, "BOMBER", "BOM_Plant_Loop", -1, true, false, false);
                                                exports.cosmo_chat:sendLocalMeAction(localPlayer, "elkezdte felszerelni a "..v[1].."-t.")
                                                setElementFrozen(localPlayer,true);
                                                loading = {};
                                                loading = {
                                                    [1] = -1,
                                                    [2] = "Felszerelés",
                                                    [3] = vehicle,
                                                    [4] = k,
                                                    [5] = v[2],
                                                    [6] = v[3],
                                                    [7] = 1,
                                                }
                                                removeEventHandler("onClientPreRender",root,loadingRender);
                                                addEventHandler("onClientPreRender",root,loadingRender);
                                            else --Leszerelés
                                                if carry then 

                                                    clickTick = getTickCount();
                                                    return;
                                                end
                                                triggerServerEvent("mechanic.applyAnimation", localPlayer, localPlayer, "BOMBER", "BOM_Plant_Loop", -1, true, false, false);
                                                exports.cosmo_chat:sendLocalMeAction(localPlayer, "elkezdte leszerelni a "..v[1].."-t.")
                                                setElementFrozen(localPlayer,true);
                                                loading = {};
                                                loading = {
                                                    [1] = -1,
                                                    [2] = "Leszerelés",
                                                    [3] = vehicle,
                                                    [4] = k,
                                                    [5] = v[2],
                                                    [6] = v[3],
                                                    [7] = false;
                                                }
                                                removeEventHandler("onClientPreRender",root,loadingRender);
                                                addEventHandler("onClientPreRender",root,loadingRender);
                                                --triggerServerEvent("mechanic.down",localPlayer,localPlayer,vehicle,k,v[2],v[3]);
                                            end
                                            clickTick = getTickCount();
                                        end
                                    end

                                    dxDrawText(v[1],x,y,x,y,color,1,font,"center","top");
                                end
                            end
                            count = count + 1;
                        end
                    end
                end

                local light = getVehLight(vehicle);
                local hp = getElementHealth(vehicle);

                if hp < 999 or light then 



                    if hp < 999 then 
                        local engineColor = tocolor(246,137,52,255,180);
                        if isInSlot(sx-195,sy/2-40,190,30) then 
                            engineColor = tocolor(246,137,52,255);
                            if getKeyState("mouse1") and clickTick+1500 < getTickCount() then 
                                --if count == 0 then 
                                dxDrawRectangle ( sx/3.8, sy/3.8, sx/2.02, sy/2, tocolor ( 0, 0, 0, 150 ))
                                    if getElementHealth(vehicle) < 999 then 
                                        triggerServerEvent("mechanic.applyAnimation", localPlayer, localPlayer, "BOMBER", "BOM_Plant_Loop", -1, true, false, false);
                                        exports.cosmo_chat:sendLocalMeAction(localPlayer, "elkezdte megszerelni a motort.")
                                        setElementFrozen(localPlayer,true);
                                        loading = {};
                                        loading = {
                                            [1] = -1,
                                            [2] = "Motor javítása",
                                            [3] = vehicle,
                                            [4] = k,
                                            [5] = 5,
                                            [6] = 1,
                                            [7] = 2;
                                        }
                                        removeEventHandler("onClientPreRender",root,loadingRender);
                                        addEventHandler("onClientPreRender",root,loadingRender);
                                    else 
                                      
                                    end
                                --else 
                                   
                                --end
                                clickTick = getTickCount();
                            end
                        end 
                        dxDrawRectangle(sx-183,sy/2-38,170,30,tocolor(0,0,0,180)); 
                        dxDrawText("Motor Javítása",sx-195,sy/2-40,sx-195+190,sy/2-40+30,tocolor(255,255,255),1,font,"center","center");
                    end                   
                    if light then 
                        local lightColor = tocolor(246,137,52,255,180);
                        if isInSlot(sx-195,sy/2+10,190,30) then 
                            lightColor = tocolor(246,137,52,255);
                            if getKeyState("mouse1") and clickTick+1500 < getTickCount() then 
                                triggerServerEvent("mechanic.applyAnimation", localPlayer, localPlayer, "BOMBER", "BOM_Plant_Loop", -1, true, false, false);
                                exports.cosmo_chat:sendLocalMeAction(localPlayer, "elkezdte megszerelni a fényszórót.")
                                setElementFrozen(localPlayer,true);
                                loading = {};
                                loading = {
                                    [1] = -1,
                                    [2] = "Lámpák javítása",
                                    [3] = vehicle,
                                    [4] = k,
                                    [5] = 4,
                                    [6] = 1,
                                    [7] = 3;
                                }
                                removeEventHandler("onClientPreRender",root,loadingRender);
                                addEventHandler("onClientPreRender",root,loadingRender);
                                clickTick = getTickCount();
                            end
                        end
                        dxDrawRectangle(sx-188,sy/1.7-85,170,30,tocolor(0,0,0,180));
                        dxDrawText("Lámpák Javítása",sx-195,sy/2+10,sx-195+190,sy/2+10+30,tocolor(255,255,255),1,font,"center","center");
                    end

                end
                --[[local light = false;
                if count == 0 and not engine then 
                    local damaged = false;
                    for i=0,3 do 
                        if getVehicleLightState(vehicle,i) == 1 then
                            damaged = true;
                        end
                    end
                    light = damaged
                    if damaged then 
                        local wx,wy,wz = getElementPosition(vehicle);
                        local x,y = getScreenFromWorldPosition(wx,wy,wz);
                        if x and y then 
                            exports.fv_engine:roundedRectangle(x-50,y-100,100,30,tocolor(0,0,0,180));
                            local lightColor = tocolor(255,255,255);
                            if exports.fv_engine:isInSlot(x-50,y-100,100,30) then 
                                lightColor = tocolor(246,137,52,255);
                                if getKeyState("mouse1") and clickTick+1500 < getTickCount() then 
                                    setControl(false);
                                    triggerServerEvent("mechanic.applyAnimation", localPlayer, localPlayer, "BOMBER", "BOM_Plant_Loop", -1, true, false, false);
                                    setElementFrozen(localPlayer,true);
                                    loading = {};
                                    loading = {
                                        [1] = -1,
                                        [2] = "Lámpák javítása",
                                        [3] = vehicle,
                                        [4] = k,
                                        [5] = 4,
                                        [6] = 1,
                                        [7] = 3;
                                    }
                                    removeEventHandler("onClientPreRender",root,loadingRender);
                                    addEventHandler("onClientPreRender",root,loadingRender);
                                    clickTick = getTickCount();
                                end
                            end
                            dxDrawText("Lámpák",x-50,y-100,x-50+100,y-100+30,lightColor,1,font,"center","center");
                        end
                    end
                end
                if not light and count == 0 and getElementHealth(vehicle) < 500 then 
                    local wx,wy,wz = getElementPosition(vehicle);
                    local x,y = getScreenFromWorldPosition(wx,wy,wz);
                    if x and y then 
                        exports.fv_engine:roundedRectangle(x-50,y-100,100,30,tocolor(0,0,0,180));
                        local engineColor = tocolor(255,255,255);
                        if exports.fv_engine:isInSlot(x-50,y-100,100,30) then 
                            engineColor = tocolor(246,137,52,255);
                            if getKeyState("mouse1") and clickTick+1500 < getTickCount() then 
                                setControl(false);
                                triggerServerEvent("mechanic.applyAnimation", localPlayer, localPlayer, "BOMBER", "BOM_Plant_Loop", -1, true, false, false);
                                setElementFrozen(localPlayer,true);
                                loading = {};
                                loading = {
                                    [1] = -1,
                                    [2] = "Motor javítása",
                                    [3] = vehicle,
                                    [4] = k,
                                    [5] = 5,
                                    [6] = 1,
                                    [7] = 2;
                                }
                                removeEventHandler("onClientPreRender",root,loadingRender);
                                addEventHandler("onClientPreRender",root,loadingRender);
                                clickTick = getTickCount();
                            end
                        end
                        dxDrawText("Motor",x-50,y-100,x-50+100,y-100+30,engineColor,1,font,"center","center");
                    end
                end]]
            --else 
                --colVehicles[vehicle] = false;
                break;
            end
        end
    end
end);

function loadingRender(dt)
    if loading[1] < 100 then 
        loading[1] = loading[1] + (dt*0.01);
    elseif loading[1] > 100 then 
        if not loading[7] then --leszerelés
            setVehicleComponentVisible(loading[3],loading[4],false);
            triggerServerEvent("mechanic.down",localPlayer,localPlayer,loading[3],loading[4],loading[5],loading[6]);
            setElementFrozen(localPlayer,false);
        elseif loading[7] == 1 then  --felszerelés
            setVehicleComponentVisible(loading[3],loading[4],true);
            fixComponent(loading[3],loading[4]);
            triggerServerEvent("mechanic.applyAnimation", localPlayer, localPlayer);
            triggerServerEvent("mechanic.deleteHand",localPlayer,localPlayer);
            setElementFrozen(localPlayer,false);
        elseif loading[7] == 2 then --motor javítása
            triggerServerEvent("mechanic.fixVehicle",localPlayer,localPlayer,loading[3]);
            triggerServerEvent("mechanic.applyAnimation", localPlayer, localPlayer);
            setElementFrozen(localPlayer,false);
        elseif loading[7] == 3 then 
            for i=0,3 do 
                setVehicleLightState(loading[3],i,0);
            end
            triggerServerEvent("mechanic.applyAnimation", localPlayer, localPlayer);
            setElementFrozen(localPlayer,false);
           
        end
        loading = {};
        removeEventHandler("onClientPreRender",root,loadingRender);
    end
    if loading[1] then
        dxDrawRectangle(sx/2-205,sy-175,410,50,tocolor(0,0,0,180));
        dxDrawRectangle(sx/2-200,sy-170,loading[1]*4,40,tocolor(246,137,52,255,180));
        dxDrawText(loading[2],sx/2-200,sy-170,sx/2-200+400,sy-170+40,tocolor(255,255,255),1,font2,"center","center");
    end
end

addEvent("mechanic.handSync",true);
addEventHandler("mechanic.handSync",root,function(veh,component)
    if not carryVehicles[veh] then 
        carryVehicles[veh] = component;
    end
end);

addEvent("createMechanicSound",true)
addEventHandler("createMechanicSound",getRootElement(),function(element)
    local x,y,z = getElementPosition(element)
    if not isElement(sounds[element]) then
        sounds[element] = playSound3D("repair.mp3",x,y,z, false)
        setElementInterior(sounds[element], 0)
        setElementDimension(sounds[element], 0)
    end
end)

addEventHandler("onClientPreRender",root,function() --Szinkronizáció
    for k,v in pairs(carryVehicles) do 
        if isElement(k) then 
            for component in pairs(getVehicleComponents(k)) do 
                if component ~= v then 
                    setVehicleComponentVisible(k,component,false);
                else 
                    setVehicleComponentVisible(k,component,true);
                end

                setElementCollisionsEnabled(k, false);
                setElementFrozen(k, true);
            end
        else 
            carryVehicles[k] = nil;
        end
    end
end);

addEventHandler("onClientVehicleStartEnter",root,function(player) --Nem tud beülni abba amit visz valaki
    if player == localPlayer then 
        if source and carryVehicles[source] then 
            cancelEvent();
        end
    end
end);   

function fixComponent(veh,comp)
    local name,type,helo = unpack(componentList[comp]);
    if type == 1 then 
        setVehicleDoorState(veh,helo,0);
    elseif type == 2 then 
        setVehiclePanelState(veh,helo,0);
    elseif type == 3 then 
        local wheels = {getVehicleWheelStates(veh)};
        wheels[helo] = nil;
        wheels[helo] = 0;
        setVehicleWheelStates(veh,unpack(wheels));
    end
end

function getVehLight(veh)
    local light = false;
    for i=0,3 do 
        if getVehicleLightState(veh,i) == 1 then
            light = true;
            break;
        end
    end
    return light;
end

--UTILS--
function validComponent(vehicle, component)
	for value in pairs(getVehicleComponents(vehicle)) do
		if value == component then
			return true
		end
	end

	return false
end
function isInSlot(xS,yS,wS,hS)
	if(isCursorShowing()) then
		XY = {guiGetScreenSize()}
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*XY[1], cursorY*XY[2]
		if(isInBox(xS,yS,wS,hS, cursorX, cursorY)) then
			return true
		else
			return false
		end
	end
end
function isInBox(dX, dY, dSZ, dM, eX, eY)
    if eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM then
        return true
    else
        return false
    end
end