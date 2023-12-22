local sx,sy = guiGetScreenSize()
local fix = sx*0.005
local fix2 = sx*0.1
local x, y = guiGetScreenSize()
oX, oY = 1280, 720

local white = "#FFFFFF"; --255,255,255
local gray = "#646464"; --100,100,100
local black = "#000000"; --0,0,0
local red = "#DF3535"; --223,53,53
local orange = "#ff9428"; --0,127,201
local green = "#7cc576"; --124,197,118

local blocker = false
local othercolor = false
local colorPicker = {{0,0,0}}

local count = -1

local cache = {}
local start = getTickCount()

cache.roboto = dxCreateFont("files/roboto.ttf",20)
cache.fontawsome = dxCreateFont("files/fontawsome.ttf",20)
cache.bold = dxCreateFont("files/mesmerize.ttf",20)
cache.name = dxCreateFont("files/namefont.ttf",40)

cache.carnumber = 1
cache.carshop = false
cache.choosecolor = false
cache.choosecolorpp = false
cache.carrot = false
cache.lfd = false
cache.rfd = false
cache.lsd = false
cache.rsd = false
cache.carb = false
cache.cart = false
cache.headl = false
selectCarButton = false
componentHover = nil 
showBuyPanel = false

addEventHandler('onClientResourceStart', resourceRoot,function()
local txd = engineLoadTXD('files/models/garazs2.txd',true)
engineImportTXD(txd, 7588)
local dff = engineLoadDFF('files/models/garazs2.dff', 0)
engineReplaceModel(dff, 7588)
local col = engineLoadCOL('files/models/garazs2.col')
engineReplaceCOL(col, 7588)
engineSetModelLODDistance(7588, 301)
end)

function resetElements()
    cache.carnumber = 1
    cache.carshop = false
    cache.choosecolor = false
    cache.choosecolorpp = false
    cache.carrot = false
    cache.lfd = false
    cache.rfd = false
    cache.lsd = false
    cache.rsd = false
    cache.carb = false
    cache.cart = false
    cache.headl = false
    selectCarButton = false
    componentHover = nil 
    showBuyPanel = false
end

local setVehLimitSQLExport = 0
function getServerExportInClient(vehLimit)
    if vehLimit == -1 then
        setVehLimitSQLExport = 10000
    end
    if vehLimit >= 0 then
        setVehLimitSQLExport = tonumber(vehLimit)
    end
end
addEvent("getServerExportInClient", true)
addEventHandler("getServerExportInClient", getRootElement(), getServerExportInClient)

function drawCarshop()
    local vehName = veh[cache.carnumber][2] or "Ismeretlen (Jelentsd egy fejlesztőnek)"
    local fuelType = veh[cache.carnumber][3] or "Ismeretlen (Jelentsd egy fejlesztőnek)"
    local wheelDrive = veh[cache.carnumber][4] or "Ismeretlen (Jelentsd egy fejlesztőnek)"
    local ppprice = tostring(veh[cache.carnumber][5]) or "Ismeretlen (Jelentsd egy fejlesztőnek)"
    local price = tostring(veh[cache.carnumber][6]) or "Ismeretlen (Jelentsd egy fejlesztőnek)"
    local getlimit = count
    local limit = tostring(veh[cache.carnumber][7]) or "0"

    local now = getTickCount()
    local endTime = start + 1000
    local elapsedTime = now - start
    local duration = endTime - start
    local progress = elapsedTime / duration

    triggerServerEvent("getVehicleModelInSQL",localPlayer,locelPlayer,veh[cache.carnumber][1])

    dxDrawRectangle(0/oX*x, 0/oY*y, 1400/oX*x, 85/oY*y,tocolor(0,0,0,190))
    dxDrawRectangle(0/oX*x, 660/oY*y, 1400/oX*x, 65/oY*y,tocolor(0,0,0,190))
    dxDrawImage(2.5/oX*x,2.5/oY*y,80/oX*x,80/oY*y,"files/logo.png",0,0,0,tocolor(255,255,255,255))
    dxDrawText(orange.."CosmoMTA"..white.." Járműkereskedés", 90/oX*x,55/oY*y,10/oX*x,30/oY*y, tocolor(255, 255, 255), 0.50/oX*x, cache.name, "left", "center",false,false,false,true)
    dxDrawText(white..vehName, 1300/oX*x,1260/oY*y,10/oX*x,30/oY*y, tocolor(255, 255, 255), 0.75/oX*x, cache.roboto, "center", "center",false,false,false,true)
    dxDrawText(white.."Ár: "..formatNumber(price).." $ vagy "..formatNumber(ppprice).." prémium pont", 10/oX*x,1320/oY*y,10/oX*x,30/oY*y, tocolor(255, 255, 255), 0.45/oX*x, cache.roboto, "left", "center",false,false,false,true)
    if setVehLimitSQLExport < (veh[cache.carnumber][7]) then
        dxDrawText(white.."Limit: "..setVehLimitSQLExport.."/"..limit, 10/oX*x,1350/oY*y,10/oX*x,30/oY*y, tocolor(255, 255, 255), 0.45/oX*x, cache.roboto, "left", "center",false,false,false,true)
    else
        dxDrawText(white.."Limit: "..limit.."/"..limit, 10/oX*x,1350/oY*y,10/oX*x,30/oY*y, tocolor(255, 255, 255), 0.45/oX*x, cache.roboto, "left", "center",false,false,false,true)
    end
    dxDrawText(white.."Készpénz: \n"..formatNumber(getElementData(localPlayer,"char.Money")).." $", 10/oX*x,10/oY*y,1250/oX*x,30/oY*y, tocolor(255, 255, 255), 0.45/oX*x, cache.roboto, "right", "center",false,false,false,true)
    dxDrawText(white.."Prémium egyenleg: \n"..formatNumber(getElementData(localPlayer,"char.PP")).." PP", 10/oX*x,70/oY*y,1250/oX*x,30/oY*y, tocolor(255, 255, 255), 0.45/oX*x, cache.roboto, "right", "center",false,false,false,true)


    --<<BUY>>--
    if isInSlot(1075/oX*x, 667.5/oY*y, 200/oX*x, 30) then 
        dxDrawRectangle(1072.5/oX*x, 665/oY*y, 205/oX*x, 35/oY*y,tocolor(0,0,0,140))
        dxDrawRectangle(1075/oX*x, 667.5/oY*y, 200/oX*x, 30/oY*y,tocolor(255,148,40,75))
        dxDrawImage(1130/oX*x,673/oY*y,20/oX*x,20/oY*y,"files/rotate.png",0,0,0,tocolor(185,185,185,255))
        dxDrawText("Forgatás", 2365/oX*x,1335/oY*y,10/oX*x,30/oY*y, tocolor(185, 185, 185, 255), 0.55/oX*x, cache.roboto, "center", "center",false,false,false,true)
    else
        dxDrawRectangle(1072.5/oX*x, 665/oY*y, 205/oX*x, 35/oY*y,tocolor(0,0,0,140))
        dxDrawRectangle(1075/oX*x, 667.5/oY*y, 200/oX*x, 30/oY*y,tocolor(0,0,0,140))
        dxDrawImage(1130/oX*x,673/oY*y,20/oX*x,20/oY*y,"files/rotate.png",0,0,0,tocolor(185,185,185,255))
        dxDrawText("Forgatás", 2365/oX*x,1335/oY*y,10/oX*x,30/oY*y, tocolor(185, 185, 185, 255), 0.55/oX*x, cache.roboto, "center", "center",false,false,false,true)
    end
    if isInSlot(862.5/oX*x, 667.5/oY*y, 200/oX*x, 30) then 
        dxDrawRectangle(865/oX*x, 665/oY*y, 205/oX*x, 35/oY*y,tocolor(0,0,0,140))
        dxDrawRectangle(867.5/oX*x, 667.5/oY*y, 200/oX*x, 30/oY*y,tocolor(255,148,40,75))
        dxDrawImage(920/oX*x,673/oY*y,20/oX*x,20/oY*y,"files/paint.png",0,0,0,tocolor(185,185,185,255))
        dxDrawText("Fényezés", 1945/oX*x,1335/oY*y,10/oX*x,30/oY*y, tocolor(185, 185, 185, 255), 0.55/oX*x, cache.roboto, "center", "center",false,false,false,true)
    else
        dxDrawRectangle(865/oX*x, 665/oY*y, 205/oX*x, 35/oY*y,tocolor(0,0,0,140))
        dxDrawRectangle(867.5/oX*x, 667.5/oY*y, 200/oX*x, 30/oY*y,tocolor(0,0,0,140))
        dxDrawImage(920/oX*x,673/oY*y,20/oX*x,20/oY*y,"files/paint.png",0,0,0,tocolor(185,185,185,255))
        dxDrawText("Fényezés", 1945/oX*x,1335/oY*y,10/oX*x,30/oY*y, tocolor(185, 185, 185, 255), 0.55/oX*x, cache.roboto, "center", "center",false,false,false,true)
    end
    if cache.choosecolor then
        dxDrawRectangle(1025/oX*x, 460/oY*y, 250/oX*x, 20/oY*y,tocolor(0,0,0,200))
        dxDrawRectangle(1025/oX*x, 480/oY*y, 250/oX*x, 175/oY*y,tocolor(0,0,0,140))
        dxDrawText(white.."Fényezés", 1030/oX*x,910/oY*y,10/oX*x,30/oY*y, tocolor(185,185,185,255), 0.45/oX*x, cache.roboto, "left", "center",false,false,false,true)
        dxDrawRectangle(1257.5/oX*x, 462.5/oY*y, 15/oX*x, 15/oY*y,tocolor(217,89,89,200))
        dxDrawImage(1257.5/oX*x,462.5/oY*y,15/oX*x,15/oY*y,"files/cancel.png",0,0,0,tocolor(0,0,0,255))
    end
    --<<3DBUTTONS>>--
    for k, v in pairs(vehicleComponents) do 
        local vcx,vcy,vcz = getVehicleComponentPosition(vehicle,k,"world")
        if vcx and vcy and vcz then 
            local sx, sy = getScreenFromWorldPosition(vcx, vcy, vcz) 
            local w, h = 30,30
            if isInSlot(sx-w/2,sy-h/2,w,h) then
                componentHover = k
                dxDrawImage(sx-w/2,sy-h/2,w,h,"files/door.png",0,0,0,tocolor(150,150,150,255))
            else
                dxDrawImage(sx-w/2,sy-h/2,w,h,"files/door.png",0,0,0,tocolor(255,255,255,255))
            end
        end
    end
    local vlx,vly,vlz = getVehicleComponentPosition(vehicle,"bump_front_dummy","world")
    if vlx and vly and vlz then 
        local sx, sy = getScreenFromWorldPosition(vlx, vly, vlz) 
        local w, h = 30,30
        if isInSlot(sx-w/2,sy-h/2,w,h) then
            dxDrawImage(sx-w/2,sy-h/2,w,h,"files/headlights.png",0,0,0,tocolor(150,150,150,255))
        else
            dxDrawImage(sx-w/2,sy-h/2,w,h,"files/headlights.png",0,0,0,tocolor(255,255,255,255))
        end
    end

    if showBuyPanel then
        dxDrawRectangle(567.5/oX*x, 300/oY*y, 175/oX*x, 100/oY*y,tocolor(0,0,0,180))
        dxDrawRectangle(570/oX*x, 302.5/oY*y, 170/oX*x, 20/oY*y,tocolor(50,50,50,200))
        dxDrawText("Jármű vásárlás", 1300/oX*x,597.5/oY*y,10/oX*x,30/oY*y, tocolor(255, 255, 255), 0.40/oX*x, cache.roboto, "center", "center",false,false,false,true)
        dxDrawRectangle(570/oX*x, 327.5/oY*y, 170/oX*x, 20/oY*y,tocolor(255,148,40,100))
        dxDrawText("Készpénz", 1300/oX*x,645/oY*y,10/oX*x,30/oY*y, tocolor(255, 255, 255), 0.40/oX*x, cache.roboto, "center", "center",false,false,false,true)
        dxDrawRectangle(570/oX*x, 350/oY*y, 170/oX*x, 20/oY*y,tocolor(255,148,40,100))
        dxDrawText("Prémiumpont", 1300/oX*x,690/oY*y,10/oX*x,30/oY*y, tocolor(255, 255, 255), 0.40/oX*x, cache.roboto, "center", "center",false,false,false,true)
        dxDrawRectangle(570/oX*x, 372.5/oY*y, 170/oX*x, 20/oY*y,tocolor(217,89,89,100))
        dxDrawText("Mégsem", 1300/oX*x,735/oY*y,10/oX*x,30/oY*y, tocolor(255, 255, 255), 0.40/oX*x, cache.roboto, "center", "center",false,false,false,true)
    end
end 

function triggerCarshop(element)
    if element == localPlayer then 
        fadeCamera(false)
        exports.cosmo_hud:toggleHUD(false)
		showChat(false)
        cache.carshop = true 
        num = math.random(1,100)*getElementData(localPlayer,"acc.dbID")
        triggerServerEvent("openCarshop",localPlayer,localPlayer,num)
        if not cache.carrot then
            vehicle = createVehicle(veh[cache.carnumber][1],1781.873046875, -1357.0814208984, 145.84342956543,0,0,150,"")
        else
            vehicle = createVehicle(veh[cache.carnumber][1],1781.873046875, -1357.0814208984, 145.84342956543,0,0,150,"")
        end
        count = -1
        countVehicles(vehicle)
        setElementDimension(vehicle,num)
        setElementFrozen(localPlayer,true)
        carshop = createObject(7588,1781.4484863281, -1357.5690917969, 147.40350341797,0,0,180)
        setElementFrozen(carshop,true)
        setElementDimension(carshop,num)
        setTimer(function()
            fadeCamera(true)
            setCameraMatrix(1779.4206542969, -1367.3250732422, 147.64559936523, 1779.6081542969, -1366.4071044922, 147.29602050781)
            addEventHandler("onClientRender",root,drawCarshop)
            start = getTickCount()
        end,1500,1)
    end 
end 
addEvent("triggerCarshop",true)
addEventHandler("triggerCarshop",root,triggerCarshop)

function triggerQuitAfterSuccessBuy(element)
    if element == localPlayer then 
        if not cache.choosecolor and not cache.choosecolorpp then 
            fadeCamera(false)
            removeEventHandler("onClientRender",root,drawCarshop)
            destroyElement(vehicle)
            setTimer(function()
                setElementFrozen(localPlayer,false)
                fadeCamera(true)
                showCursor(false)
                othercolor = false
                cache.carshop = false 
                triggerServerEvent("quitCarshop",localPlayer,localPlayer)
                exports.cosmo_hud:toggleHUD(true)
                showChat(false)
                count = -1
                setElementDimension(localPlayer, 0)
                setElementInterior(localPlayer, 0)
            end,1500,1)
            setTimer(function()
                setCameraTarget(localPlayer)
                destroyElement(carshop)
            end,1501,1)
        else 
            cache.choosecolor = false 
            cache.choosecolorpp = false 
            destroyColorPicker()  
        end
    end 
end
addEvent("triggerQuitAfterSuccessBuy",true)
addEventHandler("triggerQuitAfterSuccessBuy",root,triggerQuitAfterSuccessBuy)

addEventHandler("onClientKey",root,function(button,state)
    if cache.carshop then 
        if button == "backspace" then 
            if state then 
                if showBuyPanel == false then
                    if not selectCarButton then
                    fadeCamera(false)
                    removeEventHandler("onClientRender",root,drawCarshop)
                    if cache.choosecolor then
                        destroyColorPicker()
                        cache.choosecolor = false
                    end
                    destroyElement(vehicle)
                        setTimer(function()
                            setElementFrozen(localPlayer,false)
                            fadeCamera(true)
                            showCursor(false)
                            othercolor = false
                            cache.carshop = false 
                            triggerServerEvent("quitCarshop",localPlayer,localPlayer)
                            exports.cosmo_hud:toggleHUD(true)
                            showChat(false)
                            count = -1
                        end,1500,1)
                        setTimer(function()
                            setCameraTarget(localPlayer)
                            destroyElement(carshop)
                        end,1501,1)
                        resetElements()
                    end 
                end
            end 
        elseif button == "enter" then
            if showBuyPanel == false then
                showBuyPanel = true
            end
        elseif button == "arrow_r" then 
            if state then 
                if not showBuyPanel then
                    if not cache.lfd and not cache.rfd and not cache.lsd and not cache.rsd and not cache.carb and not cache.cart then 
                        if cache.carnumber >= 1 and cache.carnumber < #veh then 
                            if not selectCarButton then
                                if not blocker then
                                selectCarButton = true
                                fadeCamera(false)
                                setTimer(function()
                                    fadeCamera(true)
                                end,1500,1)
                                setTimer(function()
                                    selectCarButton = false
                                end,1850,1)
                                setTimer(function()
                                    cache.carnumber = cache.carnumber + 1 
                                    setElementModel(vehicle,veh[cache.carnumber][1])
                                    start = getTickCount()
                                    setElementPosition(vehicle,1781.873046875, -1357.0814208984, 145.84342956543)
                                    if not cache.carrot then
                                        setElementRotation(vehicle,0,0,150)
                                    else
                                        setElementRotation(vehicle,0,0,330)
                                    end
                                    blocker = true 
                                    count = -1
                                    countVehicles(vehicle)
                                end,1000,1)
                                setTimer(function()
                                    blocker = false 
                                end,1000,1)
                                end
                            end
                        end 
                    end
                end
            end 
        elseif button == "arrow_l" then 
            if state then 
                if not showBuyPanel then
                    if not cache.lfd and not cache.rfd and not cache.lsd and not cache.rsd and not cache.carb and not cache.cart then
                        if cache.carnumber > 1 then 
                            if not selectCarButton then
                                if not blocker then 
                                    selectCarButton = true
                                    fadeCamera(false)
                                    setTimer(function()
                                        fadeCamera(true)
                                    end,1500,1)
                                    setTimer(function()
                                        selectCarButton = false
                                    end,1850,1)
                                    setTimer(function()
                                    cache.carnumber = cache.carnumber - 1 
                                    setElementModel(vehicle,veh[cache.carnumber][1])
                                    start = getTickCount()
                                    setElementPosition(vehicle,1781.873046875, -1357.0814208984, 145.84342956543)
                                    if not cache.carrot then
                                        setElementRotation(vehicle,0,0,150)
                                    else
                                        setElementRotation(vehicle,0,0,330)
                                    end
                                    blocker = true 
                                    count = -1
                                    countVehicles(vehicle)
                                end,1000,1)
                                setTimer(function()
                                    blocker = false 
                                end,1000,1)
                                end
                            end
                        end
                    end 
                end
            end 
        end 
    end 
end)

addEventHandler("onClientClick",root,function(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
    if button == "left" and state == "down" then 
        if cache.carshop then 
            for k,v in pairs(vehicleComponents) do
                local vcx,vcy,vcz = getVehicleComponentPosition(vehicle,k,"world")
                if vcx and vcy and vcz then 
                    local sx, sy = getScreenFromWorldPosition(vcx, vcy, vcz) 
                    local w, h = 30,30
                    if isInSlot(sx-w/2,sy-h/2,w,h) then
                        local num = vehicleComponents[k]
				        local openRatio = getVehicleDoorOpenRatio(vehicle, num)
                        if openRatio == 1 then
                            openRatio = 0
                        else
                            openRatio = 1
                        end
                        setVehicleDoorOpenRatio(vehicle, num, openRatio, 650)
                    end
                end
            end
            local vlx,vly,vlz = getVehicleComponentPosition(vehicle,"bump_front_dummy","world")
            if vlx and vly and vlz then 
                local sx, sy = getScreenFromWorldPosition(vlx, vly, vlz) 
                local w, h = 30,30
                if isInSlot(sx-w/2,sy-h/2,w,h) then
                    if not cache.headl then
                        setVehicleOverrideLights(vehicle,2)
                        setElementData(vehicle,"vehicle.light",true)
                        cache.headl = true
                    else
                        setVehicleOverrideLights(vehicle,1)
                        setElementData(vehicle,"vehicle.light",false)
                        cache.headl = false
                    end
                end
            end
            if isInSlot(1075/oX*x, 667.5/oY*y, 200/oX*x, 30) then
                if not cache.carrot then
                    setElementRotation(vehicle,0,0,330)
                    cache.carrot = true
                else
                    setElementRotation(vehicle,0,0,150)
                    cache.carrot = false
                end
            end
            if isInSlot(862.5/oX*x, 667.5/oY*y, 200/oX*x, 30) then
                picker = createColorPicker(colorPicker[1],1030/oX*x, 485/oY*y, 240/oX*x, 150/oY*y, "color1")
                cache.choosecolor = true
            end
            if isInSlot(1257.5/oX*x, 462.5/oY*y, 15/oX*x, 15/oY*y) then
                if cache.choosecolor == true then
                    cache.choosecolor = false
                    destroyColorPicker()
                end
            end
            if showBuyPanel == true then
                if isInSlot(570/oX*x, 327.5/oY*y, 170/oX*x, 20/oY*y) then --buy money
                    local cr,cg,cb = getVehicleColor(vehicle,true)
                    local park = math.random(1,#spawnpos)   
                    local finalprice = veh[cache.carnumber][6]
                    local vehicle2 = getElementData(localPlayer, "char.vehicleLimit")
                    if setVehLimitSQLExport < (veh[cache.carnumber][7]) then
                        if #ProcessPlayerVehicles() < vehicle2 then
                            if getElementData(localPlayer,"char.Money") >= finalprice then
                                triggerServerEvent("buyVehicle",localPlayer,localPlayer,getElementModel(vehicle),veh[cache.carnumber][2],cr,cg,cb,spawnpos[park][1],spawnpos[park][2],spawnpos[park][3],spawnpos[park][4],finalprice)
                                exports.cosmo_hud:showInfobox("success", "Sikeres vásárlás.")
                                if cache.choosecolor == true then
                                    cache.choosecolor = false
                                    destroyColorPicker()
                                end
                                resetElements()
                            else
                                exports.cosmo_hud:showInfobox("error", "Nincs elég pénzed a vásárláshoz.")
                            end
                        else
                            exports.cosmo_hud:showInfobox("error", "Nincs elegendő slotod!")
                        end
                    else
                        exports.cosmo_hud:showInfobox("error", "Ennek a járműnek betelt a slotja.")
                    end
                end
                if isInSlot(570/oX*x, 350/oY*y, 170/oX*x, 20/oY*y) then --buy premium
                    local cr,cg,cb = getVehicleColor(vehicle,true)
                    local park = math.random(1,#spawnpos)   
                    local finalpricepp = veh[cache.carnumber][5]
                    local vehicle2 = getElementData(localPlayer, "char.vehicleLimit")
                    if #ProcessPlayerVehicles() < vehicle2 then
                        if getElementData(localPlayer,"char.PP") >= finalpricepp then
                            triggerServerEvent("buyVehiclepp",localPlayer,localPlayer,getElementModel(vehicle),veh[cache.carnumber][2],cr,cg,cb,spawnpos[park][1],spawnpos[park][2],spawnpos[park][3],spawnpos[park][4],finalpricepp)
                            exports.cosmo_hud:showInfobox("success", "Sikeres vásárlás.")
                            if cache.choosecolor == true then
                                cache.choosecolor = false
                                destroyColorPicker()
                            end
                            resetElements()
                        else
                            exports.cosmo_hud:showInfobox("error", "Nincs elég prémiumpontod a vásárláshoz.")
                        end
                    else
                        exports.cosmo_hud:showInfobox("error", "Nincs elegendő slotod!")
                    end
                end
                if isInSlot(570/oX*x, 372.5/oY*y, 170/oX*x, 20/oY*y) then --exit
                    showBuyPanel = false
                end
            end
        end 
    end 
end)

function getMouseState()
    if cache.choosecolor == true then
        if isCursorShowing() then
            if isCursorOnBox(1030/oX*x, 485/oY*y, 240/oX*x, 150/oY*y) then
                if not getKeyState("mouse1") then
                    local tr,tg,tb = getPaletteColor()
                    setVehicleColor(vehicle,tr,tg,tb)
                end
            end
        end
    end
end
addEventHandler("onClientRender",root,getMouseState)

function countVehicles(vehicle)
    local vehicleModel = getElementModel(vehicle)
    for k,veh in pairs(getElementsByType("vehicle")) do 
        if getElementModel(veh) == vehicleModel then 
            count = count + 1
        end 
    end 

end 

function ProcessPlayerVehicles()
    local playerVehicles = {}
    for k, v in ipairs(getElementsByType("vehicle")) do
        if getElementData(v, "vehicle.dbID") and getElementData(v, "vehicle.owner") == getElementData(localPlayer, "char.ID") then
            table.insert(playerVehicles, v)
        end
    end

    return playerVehicles
end

function isCursorOnBox(xS,yS,wS,hS)
	if(isCursorShowing()) then
		XY = {guiGetScreenSize()}
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*XY[1], cursorY*XY[2]
		if(cursorX >= xS and cursorX <= xS+wS and cursorY >= yS and cursorY <= yS+hS) then
			return true
		else
			return false
		end
	end	
end

function formatNumber(amount)
    amount = tonumber(amount);
    if not amount then 
        return 0;
    end
	local left,num,right = string.match(tostring(amount),'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1 '):reverse())..right
end

--<<ColorPicker>>--
local screenX, screenY = guiGetScreenSize()

local cursorIsMoving, pickingColor, pickingLuminance = false, false, false

local pickerData = {}
local availableTextures = {
	["palette"] = dxCreateTexture("files/palette.png", "argb", true, "clamp"),
	["light"] = dxCreateTexture("files/light.png", "argb", true, "clamp"),
}

local lightIconXOffset = 20

addEventHandler("onClientRender", root, function()
	if pickerData and pickerData["colortype"] ~= nil and pickerData["active"] then
		--> Vehicle color
		local selectedR, selectedG, selectedB = pickerData["color"][1], pickerData["color"][2], pickerData["color"][3]
		r,g,b = selecterR,selectedG,selectedB
		if pickerData["vehicle"] and isElement(pickerData["vehicle"]) then
			local r1, g1, b1 = 0,0,0
			
			if pickerData["colortype"] == "color1" then
				r1, g1, b1 = selectedR, selectedG, selectedB
			end
			
		    
			--outputChatBox(r1.." - "..g1.." - "..b1)

			dxSetShaderValue(pickerData["vehicle"], "tColor",r1, g1, b1,0.3)
			engineApplyShaderToWorldTexture(pickerData["vehicle"], "*upper*", localPlayer)
		end
		
		--> Luminance selector
		local arrowX = pickerData["posX"] + ((1 - pickerData["lightness"]) * (pickerData["width"] - lightIconXOffset))
		arrowX = math.max(pickerData["posX"], math.min(pickerData["posX"] + pickerData["width"] - lightIconXOffset, arrowX))
		
		dxDrawRectangle(pickerData["posX"] - 2, pickerData["posY"] + pickerData["height"] - 2, pickerData["width"] + 4, 20 + 4, tocolor(0, 0, 0, 255),true)
		
		for i = 0, (pickerData["width"] - lightIconXOffset) do
			local luminanceR, luminanceG, luminanceB = HSLToRGB(pickerData["hue"], pickerData["saturation"], ((pickerData["width"] - lightIconXOffset) - i) / (pickerData["width"] - lightIconXOffset))
			
			dxDrawRectangle(pickerData["posX"] + i, pickerData["posY"] + pickerData["height"], 1, 20, tocolor(luminanceR * 255, luminanceG * 255, luminanceB * 255, 255),true)
		end
		
		dxDrawRectangle(arrowX, pickerData["posY"] + pickerData["height"], 2, 20, tocolor(0, 0, 0, 200),true)
		dxDrawImage(pickerData["posX"] + pickerData["width"] - lightIconXOffset, pickerData["posY"] + pickerData["height"] + 1, 20, 20, availableTextures["light"],0,0,0,tocolor(255,255,255,255),true)
		
		--> Color selector
		--drawBorder(pickerData["posX"], pickerData["posY"], pickerData["width"], pickerData["height"], 2, tocolor(0, 0, 0, 255))
		dxDrawImage(pickerData["posX"], pickerData["posY"], pickerData["width"], pickerData["height"], availableTextures["palette"],0,0,0,tocolor(255,255,255,255),true)
		--drawBorderedRectangle((pickerData["posX"] + (pickerData["hue"] * pickerData["width"] - 1)) - (8 / 2), (pickerData["posY"] + ((1 - pickerData["saturation"]) * pickerData["height"] - 1)) - (8 / 2), 8, 8, 1, tocolor(0, 0, 0, 255), tocolor(pickerData["selectedColor"][1], pickerData["selectedColor"][2], pickerData["selectedColor"][3], 255))
		
		--> Manage cursor
		if isCursorShowing() and isMoving then
			local cursorX, cursorY = getCursorPosition()

			cursorX = cursorX * screenX
			cursorY = cursorY * screenY
			
			if getKeyState("mouse1") and pickingColor then
				cursorX = math.max(pickerData["posX"], math.min(pickerData["posX"] + pickerData["width"], cursorX))
				cursorY = math.max(pickerData["posY"], math.min(pickerData["posY"] + pickerData["height"], cursorY))
				setCursorPosition(cursorX, cursorY)
				
				pickerData["hue"], pickerData["saturation"] = (cursorX - pickerData["posX"]) / (pickerData["width"] - 1), ((pickerData["height"] - 1) - cursorY + pickerData["posY"]) / (pickerData["height"] - 1)
				
				local convertedR, convertedG, convertedB = HSLToRGB(pickerData["hue"], pickerData["saturation"], pickerData["lightness"])
				local oldR, oldG, oldB = HSLToRGB(pickerData["hue"], pickerData["saturation"], 0.5)
				
				pickerData["selectedColor"] = convertColor({oldR * 255, oldG * 255, oldB * 255})
				pickerData["color"] = convertColor({convertedR * 255, convertedG * 255, convertedB * 255, pickerData["color"][4]})
			elseif getKeyState("mouse1") and pickingLuminance then
				cursorX = math.max(pickerData["posX"], math.min(pickerData["posX"] + pickerData["width"] - 25, cursorX))
				cursorY = math.max(pickerData["posY"] + pickerData["height"], math.min(pickerData["posY"] + pickerData["height"] + 20, cursorY))
				setCursorPosition(cursorX, cursorY)
				
				pickerData["lightness"] = ((pickerData["width"] - 20) - cursorX + pickerData["posX"]) / (pickerData["width"] - 20)
				
				local convertedR, convertedG, convertedB = HSLToRGB(pickerData["hue"], pickerData["saturation"], pickerData["lightness"])
				
				pickerData["color"] = convertColor({convertedR * 255, convertedG * 255, convertedB * 255, pickerData["color"][4]})
			end
		end
	end
end)

addEventHandler("onClientClick", root, function(button, state, cursorX, cursorY)
	if pickerData and pickerData["colortype"] ~= nil and pickerData["active"] then
		if button == "left" and state == "down" then
			if cursorX >= pickerData["posX"] and cursorX <= pickerData["posX"] + pickerData["width"] and cursorY >= pickerData["posY"] and cursorY <= pickerData["posY"] + pickerData["height"] then
				isMoving, pickingColor, pickingLuminance = true, true, false
			elseif cursorX >= pickerData["posX"] and cursorX <= pickerData["posX"] + pickerData["width"] - 25 and cursorY >= pickerData["posY"] + pickerData["height"] and cursorY <= pickerData["posY"] + pickerData["height"] + 20 then
				isMoving, pickingColor, pickingLuminance = true, false, true
			end
		else
			isMoving, pickingColor, pickingLuminance = false, false, false
		end
	end
end)

function getPaletteColor()
 return pickerData["color"][1], pickerData["color"][2], pickerData["color"][3]
end 

function setPaletteType(type)
	if type then
		pickerData["colortype"] = type
	end
end

function createColorPicker(vehicle, x, y, w, h, colortype)
	if vehicle and x and y and w and h and colortype then
		pickerData = {["active"] = true, ["posX"] = x, ["posY"] = y, ["width"] = w, ["height"] = h, ["colortype"] = colortype, ["vehicle"] = vehicle}
		updatePaletteColor(vehicle, colortype)
	end
end

function destroyColorPicker()
	pickerData["active"] = false
	pickerData = {}
	pickerData = nil
end

function updatePaletteColor(vehicle, colortype)
	if vehicle and colortype then
		local vehicleColor = {255, 255, 255}
		local r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4 = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		local r5, g5, b5 = 0,0,0
		
		if pickerData["colortype"] == "color1" then
			vehicleColor = {r1, g1, b1}
		elseif pickerData["colortype"] == "color2" then
			vehicleColor = {r2, g2, b2}
		elseif pickerData["colortype"] == "color3" then
			vehicleColor = {r3, g3, b3}
		elseif pickerData["colortype"] == "color4" then
			vehicleColor = {r4, g4, b4}
		elseif pickerData["colortype"] == "headlight" then
			vehicleColor = {r5, g5, b5}
		end
		
		pickerData["color"] = convertColor({vehicleColor[1], vehicleColor[2], vehicleColor[3]})
		pickerData["hue"], pickerData["saturation"], pickerData["lightness"] = RGBToHSL(pickerData["color"][1] / 255, pickerData["color"][2] / 255, pickerData["color"][3] / 255)
		
		local currentR, currentG, currentB = HSLToRGB(pickerData["hue"], pickerData["saturation"], 0.5)
		pickerData["selectedColor"] = convertColor({currentR * 255, currentG * 255, currentB * 255})
	end
end

function convertColor(color)
	color[1] = fixColorValue(color[1])
	color[2] = fixColorValue(color[2])
	color[3] = fixColorValue(color[3])
	color[4] = fixColorValue(color[4])

	return color
end

function fixColorValue(value)
	if not value then
		return 255
	end
	
	value = math.floor(tonumber(value))
	
	if value < 0 then
		return 0
	elseif value > 255 then
		return 255
	else
		return value
	end
end

function HSLToRGB(hue, saturation, lightness)
	local lightnessValue2
	
	if lightness < 0.5 then
		lightnessValue2 = lightness * (saturation + 1)
	else
		lightnessValue2 = (lightness + saturation) - (lightness * saturation)
	end
	
	local lightnessValue1 = lightness * 2 - lightnessValue2
	local r = HUEToRGB(lightnessValue1, lightnessValue2, hue + 1 / 3)
	local g = HUEToRGB(lightnessValue1, lightnessValue2, hue)
	local b = HUEToRGB(lightnessValue1, lightnessValue2, hue - 1 / 3)
	
	return r, g, b
end

function HUEToRGB(lightness1, lightness2, hue)
	if hue < 0 then
		hue = hue + 1
	elseif hue > 1 then
		hue = hue - 1
	end

	if hue * 6 < 1 then
		return lightness1 + (lightness2 - lightness1) * hue * 6
	elseif hue * 2 < 1 then
		return lightness2
	elseif hue * 3 < 2 then
		return lightness1 + (lightness2 - lightness1) * (2 / 3 - hue) * 6
	else
		return lightness1
	end
end

function RGBToHSL(red, green, blue)
	local max = math.max(red, green, blue)
	local min = math.min(red, green, blue)
	local hue, saturation, lightness = 0, 0, (min + max) / 2

	if max == min then
		hue, saturation = 0, 0
	else
		local different = max - min

		if lightness < 0.5 then
			saturation = different / (max + min)
		else
			saturation = different / (2 - max - min)
		end

		if max == red then
			hue = (green - blue) / different
			
			if green < blue then
				hue = hue + 6
			end
		elseif max == green then
			hue = (blue - red) / different + 2
		else
			hue = (red - green) / different + 4
		end

		hue = hue / 6
	end

	return hue, saturation, lightness
end