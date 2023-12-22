local screenX, screenY = guiGetScreenSize()

local moveDiffX, moveDiffY = 0, 0
local absX, absY = 0, 0
local isMovePanel = false
local renderPanel = false

local panelPosX = screenX / 2
local panelPosY = screenY / 2

local panelw, panelh = 160, 310
local panelx, panely = (screenX/2 - panelw/2) + screenX/2 - 100, (screenY/2 - panelh/2)

local responsiveMultipler = exports.cosmo_hud:getResponsiveMultipler()

local function respc(x)
  return math.ceil(x * responsiveMultipler)
end

local Roboto = exports.cosmo_assets:loadFont("Roboto-Regular.ttf", respc(35), false, "antialiased")

airRideLevel = 8

renderPanel = false

local buttons = {}
local activeButton = false
local selected = 0
setElementData(localPlayer, "settingMemory", false)

local lastClick = getTickCount()

addCommandHandler("airride",
    function ()
        if isPedInVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
            local currVeh = getPedOccupiedVehicle(localPlayer)
            if getElementData(currVeh, "danihe->tuning->airride") == 1 then

                renderPanel = not renderPanel

                if renderPanel then
                    addEventHandler("onClientRender", root, renderAirride)
                    addEventHandler("onClientClick", root, onClickAirRide)

                    currentVehicle = currVeh
                else
                    removeEventHandler("onClientRender", root, renderAirride)
                    removeEventHandler("onClientClick", root, onClickAirRide)
                end
            end
        end
    end)

function renderAirride()
    if not isPedInVehicle(localPlayer) or currentVehicle ~= getPedOccupiedVehicle(localPlayer) then
        renderPanel = false
        removeEventHandler("onClientRender", getRootElement(), renderAirride)
        removeEventHandler("onClientClick", getRootElement(), onClickAirRide)
        return
    end
    
    if renderPanel then
        absX, absY = 0, 0
        buttons = {}

        if isCursorShowing() then
            local relX, relY = getCursorPosition()

            absX = screenX * relX
            absY = screenY * relY
        end

        if isCursorShowing() and isMovePanel then
            panelx = absX - moveDiffX
            panely = absY - moveDiffY
        end

        buttons["button:up"] = {panelx+respc(25), panely+respc(138), 115, 30} --Up
        buttons["button:down"] = {panelx+respc(25), panely+respc(185), 115, 30} --Down
        buttons["button:memory1"] = {panelx+respc(25), panely+respc(233), 33, 30} --Memory1
        buttons["button:2"] = {panelx+respc(68), panely+respc(233), 33, 30} --Memory2
        buttons["button:setButton"] = {panelx+respc(112), panely+respc(233), 33, 30} --SetButt
        
        dxDrawImage(panelx, panely, panelw, panelh, "files/panel.png")



        dxDrawRectangle(panelx+26+(airRideLevel*6), panely+94, 12, 12, tocolor(0, 0, 0, 160))

        if getElementData(localPlayer, "settingMemory", true) then
            dxDrawImage(panelx, panely, panelw, panelh, "files/ledorange.png")
        end

        if getElementData(localPlayer, "switchingAirRide", true) then
            setElementData(localPlayer, "settingMemory", false)
            dxDrawImage(panelx, panely, panelw, panelh, "files/led.png")
        end


        --    
        --end

   
        local cursorX, cursorY = getCursorPosition()

        activeButton = false

        if cursorX and cursorY then
            cursorX = cursorX * screenX
            cursorY = cursorY * screenY

            for k, v in pairs(buttons) do
                if cursorX >= v[1] and cursorX <= v[1] + v[3] and cursorY >= v[2] and cursorY <= v[2] + v[4] then
                    activeButton = k
                end
            end
        end
    end
end

local ar_timer

function onClickAirRide(button, state, absX, absY, worldX, worldY, worldZ, clickedWorld)  --KESZ MEGIRVA UJRA
  if button == "left" then
    if activeButton and state == "down" then
      local button = split(activeButton, ":")
      if button[2] == "down" then 
        if getTickCount() - lastClick > 1500 then 
			if isTimer(ar_timer) then
                return
            end
            if airRideLevel == 1 then
                --outputChatBox("Már a földön fekszik a kocsi mit szeretnél te balfasz", 255, 255, 255, true)
            else
                airRideLevel = airRideLevel-1
                local vehicle = getPedOccupiedVehicle(localPlayer)
				level = tonumber(airRideLevel)
                --triggerServerEvent("setAirRide",resourceRoot,localPlayer, airRideLevel)
				triggerServerEvent("setAirRide",resourceRoot,localPlayer,vehicle,airRideLevel,level)
                print(airRideLevel)

                setTimer(function()
                    setElementData(localPlayer, "switchingAirRide", true)
                end,500,1)
                setTimer(function()
                    setElementData(localPlayer, "switchingAirRide", false)
                end,550,1)

				ar_timer = setTimer(function() end,500,1)
            end
        end
      elseif button[2] == "up" then 
        if getTickCount() - lastClick > 1500 then
            if isTimer(ar_timer) then        
                return
            end
                if airRideLevel == 15 then
                    --outputChatBox("A rúgók terpesztenek már mint anyád, csak ne szakadna szét", 255, 255, 255, true)
                else
                    airRideLevel = airRideLevel+1
                    local vehicle = getPedOccupiedVehicle(localPlayer)
                    --triggerServerEvent("setAirRide",resourceRoot,localPlayer, airRideLevel)
    				level = tonumber(airRideLevel)
    				triggerServerEvent("setAirRide",resourceRoot,localPlayer,vehicle,airRideLevel,level)
                    print(airRideLevel)
                    setTimer(function()
                        setElementData(localPlayer, "switchingAirRide", true)
                    end,500,1)
                    setTimer(function()
                        setElementData(localPlayer, "switchingAirRide", false)
                    end,550,1)
                    dxDrawImage(panelx, panely, panelw, panelh, "files/ledorange.png")
    				ar_timer = setTimer(function() end,500,1)
                end
        end
        elseif button[2] == "setButton" then 
        if getTickCount() - lastClick > 1500 then
            --outputChatBox("#7cc576[SG:RP - AirRide] #ffffffGergő lusta volt megírni, de a többi része működik!", 255, 255, 255, true)
            setElementData(localPlayer, "settingMemory", true)
        end
      end
    end

        if not isMovePanel and not activeButton then
            if state == "down" then
                if absX >= panelx and absX <= panelx + panelw and absY >= panely and absY <= panely + panelh then
                    moveDiffX = absX - panelx
                    moveDiffY = absY - panely
                    isMovePanel = true
                    return
                end
            end
        elseif state == "up" and isMovePanel then
            isMovePanel = false
            moveDiffX, moveDiffY = 0, 0
        end
    end
end


addEvent("playAirRideSound", true)
addEventHandler("playAirRideSound", getRootElement(), function(player)
  if isElement(player) and getElementData(localPlayer, "loggedIn") and isElement((playSound3D("files/airride/airride.mp3", getElementPosition(player)))) then
    setSoundVolume(playSound3D("files/airride.mp3", getElementPosition(player)), 0.3)
    setElementDimension(playSound3D("files/airride.mp3", getElementPosition(player)), (getElementDimension(player)))
    setElementInterior(playSound3D("files/airride.mp3", getElementPosition(player)), (getElementInterior(player)))
    attachElements(playSound3D("files/airride.mp3", getElementPosition(player)), player)
  end
end)