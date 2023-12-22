--pcall(loadstring(base64Decode(exports.cosmo_core:getInterfaceElements())));addEventHandler("onCoreStarted",root,function(functions) for k,v in ipairs(functions) do _G[v]=nil;end;collectgarbage();pcall(loadstring(base64Decode(exports.cosmo_core:getInterfaceElements())));end)

local colorInterpolationValues = {}
local lastColorInterpolationValues = {}
local colorInterpolationTicks = {}
function colorInterpolation(key, r, g, b, a, duration)
    if not colorInterpolationValues[key] then
        colorInterpolationValues[key] = {r, g, b, a}
        lastColorInterpolationValues[key] = r .. g .. b .. a
    end

    if lastColorInterpolationValues[key] ~= (r .. g .. b .. a) then
        lastColorInterpolationValues[key] = r .. g .. b .. a
        colorInterpolationTicks[key] = getTickCount()
    end

    if colorInterpolationTicks[key] then
        local progress = (getTickCount() - colorInterpolationTicks[key]) / (duration or 500)
        local red, green, blue = interpolateBetween(colorInterpolationValues[key][1], colorInterpolationValues[key][2], colorInterpolationValues[key][3], r, g, b, progress, "Linear")
        local alpha = interpolateBetween(colorInterpolationValues[key][4], 0, 0, a, 0, 0, progress, "Linear")

        colorInterpolationValues[key][1] = red
        colorInterpolationValues[key][2] = green
        colorInterpolationValues[key][3] = blue
        colorInterpolationValues[key][4] = alpha

        if progress >= 1 then
            colorInterpolationTicks[key] = false
        end
    end

    return colorInterpolationValues[key][1], colorInterpolationValues[key][2], colorInterpolationValues[key][3], colorInterpolationValues[key][4]
end

local x, y = guiGetScreenSize()
local screenX, screenY = guiGetScreenSize()

function reMap(value, low1, high1, low2, high2)
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

local clickTick = getTickCount()

responsiveMultipler = reMap(screenX, 1024, 1920, 0.75, 1)

function respc(num)
    return math.ceil(num * responsiveMultipler)
end

local quartz = dxCreateFont(":cosmo_assets/fonts/counter2.ttf", respc(30))

function getvehanyad()
    if currentVehicle then
        local vx, vy, vz = getElementVelocity(currentVehicle)
        return math.sqrt(vx^2 + vy^2 + vz^2) * 187.5
    end
    return 0
end

local panelWidth = respc(240)
local panelHeight = respc(130)
local panelPosX = screenX / 2 - panelWidth / 2
local panelPosY = screenY- 220

function round2(num, idp)
    return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

function getVehicleSpeed(element)
    if isPedInVehicle(getLocalPlayer()) then
	    local theVehicle = element
        local vx, vy, vz = getElementVelocity (theVehicle)
        return math.sqrt(vx^2 + vy^2 + vz^2) * 165
    end
    return 0
end

local x,y = guiGetScreenSize()
function isInSlot(dX, dY, dSZ, dM) --Létre hozzuk az isInSlot funkciót (Amit később majd meghívunk).
    if isCursorShowing() then --Ha látszódik a kurzor.
        local cX ,cY = getCursorPosition() --Lekéri a kurzor pozícióját.
        cX,cY = cX*x , cY*y --Lekéri a kurzor pozícióját az adott felbontáson.
        if(cX >= dX and cX <= dX+dSZ and cY >= dY and cY <= dY+dM) then --Ha ott van a kurzor ahol megadtuk akkor.
            return true, cX, cY --Ha a dobozban van akkor adja vissza, hogy igaz.
        else
            return false --Ha nincs a dobozban akkor adja vissza, hogy hamis.
        end
    end
end

--[[addEventHandler("onClientResourceStart", resourceRoot,
    function()
        triggerServerEvent("taxiclock.start", localPlayer, localPlayer, getPedOccupiedVehicle(localPlayer))
        setElementData(getPedOccupiedVehicle(localPlayer), "taxiclock.travelled", 0)
    end
)
]]

function drawButton(key, label, x, y, w, h, activeColor, postGui, theFont, labelScale)
	local buttonColor
	

	if wardisActiveButton == key then
		buttonColor = {colorInterpolation(key, 30, 30, 30, activeColor[4] or 255, 1500)}  --{activeColor[1], activeColor[2], activeColor[3], 175}
	else
		buttonColor =  {colorInterpolation(key, 40, 40, 40, activeColor[4] or 255, 1500)} --{activeColor[1], activeColor[2], activeColor[3], 125}
	end
		
	local alphaDifference = 175 - buttonColor[4]
		
	local labelFont = theFont or "arial"
	local postGui = false
	local labelScale = labelScale or 0.85

	dxDrawRectangle(x, y, w, h, tocolor(30, 30, 30), postGui)
	dxDrawRectangle(x + 2, y + 2, w - 4, h - 4, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 175 - alphaDifference), postGui)
	dxDrawText(label, x + 2, y + 2, x + 2 + w - 4, y + 2 + h - 4, tocolor(222, 222, 222, 222), labelScale, labelFont, "center", "center", false, false, postGui, true)

	wardisButtons[key] = {x + 2, y + 2, w - 4, h - 4}
end

sirenPos = {
	[445] = {-0.4,0.08, 0.75, 0, 0, 0}, -- M5
	[602] = {-0.4,0.08, 0.95, 0, 0, 0}, -- m4
	[580] = {-0.45,0.02, 0.95, 0, 0, 0}, -- rs4
	[507] = {-0.45,0.02, 0.80, 0, 0, 0}, -- e500
	[400] = {-0.45,0.02, 1.27, 0, 0, 0}, -- SRT8 landstalker
	[458] = {-0.45,-0.22, 0.95, 0, 0, 0}, -- e500
	[550] = {-0.45,0.02, 0.68, 0, 0, 0}, -- e420
	[585] = {-0.45,0.02, 0.95, 0, 0, 0}, -- crown vic
}

local vehtaxi = false
local t1, t2, t3 = 255, 255, 255

function renderTaxi()
    local currentTick = getTickCount()
    local cursorX, cursorY = getCursorPosition()
    local dragHeight = respc(22)

    if not getPedOccupiedVehicle(localPlayer) then return end
    if not isElement(getElementData(getPedOccupiedVehicle(localPlayer), "taxiObject")) then return end

    if cursorX then
        cursorX = cursorX * screenX
        cursorY = cursorY * screenY

        if getKeyState("mouse1") then
            if isInSlot(panelPosX, panelPosY, panelWidth, dragHeight) and not draggingPanel then
                draggingPanel = {cursorX, cursorY, panelPosX, panelPosY}
            end

            if draggingPanel then
                panelPosX = cursorX - draggingPanel[1] + draggingPanel[3]
                panelPosY = cursorY - draggingPanel[2] + draggingPanel[4]
            end
        elseif draggingPanel then
            draggingPanel = false
        end
    else
        cursorX, cursorY = -1, -1
        
        if movedChip then
            movedChip = false
        end

        if draggingPanel then
            draggingPanel = false
        end
    end
    --local fuvardij = "00000000"
    local fuvardij = getElementData(getPedOccupiedVehicle(localPlayer),"taxiclock.travelled") or 0000000

    fuvardij = math.floor(fuvardij * 1500)
    local fuvarszex = "0"
    for i = 1, math.floor(panelWidth-respc(6) - dxGetTextWidth(fuvardij, 1, quartz) - respc(70)) / dxGetTextWidth("0", 1, quartz) + string.len(fuvardij) - utfLen(fuvardij) do
        fuvarszex = fuvarszex .. "0"
    end

    wardisButtons = {}

    fuvarszex = fuvarszex.."#ffa500"..fuvardij

    local veh = getPedOccupiedVehicle(localPlayer)
    
    --
    if isElement(getElementData(getPedOccupiedVehicle(localPlayer), "taxiObject")) then -- ha van taxilampa
        dxDrawRectangle(panelPosX, panelPosY, panelWidth, panelHeight, tocolor(0, 0, 0, 170)) -- panel

        --dxDrawRectangle(panelPosX + respc(3), panelPosY + respc(35), panelWidth - respc(6), respc(60)) -- fuvardij pozi

        dxDrawRectangle(panelPosX + respc(3), panelPosY + respc(3), panelWidth - respc(6), dragHeight, tocolor(0, 0, 0, 130)) -- label, itt lesz mozgatható
        dxDrawText("CosmoMTA - Taxi", panelPosX + respc(6), panelPosY + respc(3), panelWidth - respc(6) + panelPosX+respc(6), panelPosY + dragHeight, tocolor(220, 220, 220), 1, exports.cosmo_assets:loadFont("SARP.ttf", respc(11), false, "antialiased")) --labeltext
        dxDrawText("#dedede"..fuvarszex.."#ffa500$", panelPosX + respc(3), panelPosY + respc(35) - 20, panelPosX + respc(3) + panelWidth - respc(6), panelPosY + respc(35) + respc(60), tocolor(220, 220, 220), 1, quartz,"center","center",false,false,false,true) --labeltext

        -- itt kezdődik a gombos szarság stb

        buttons = {}

        drawButton("start", "Indítás", panelPosX + respc(6), panelPosY + panelHeight - respc(6) - respc(30), panelWidth/2 - respc(12), respc(30), {10, 255, 30}, true, exports.cosmo_assets:loadFont("SARP.ttf", respc(11), false, "antialiased"), 1)
        drawButton("stop", "Leállítás", panelPosX + respc(6) + panelWidth/2, panelPosY + panelHeight - respc(6) - respc(30), panelWidth/2 - respc(12), respc(30), {170, 20, 20}, true, exports.cosmo_assets:loadFont("SARP.ttf", respc(11), false, "antialiased"), 1)
        drawButton("reset", "", panelPosX + panelWidth - respc(4) - respc(18), panelPosY + respc(4), respc(18), respc(18), {0, 0, 0, 0}, true, exports.cosmo_assets:loadFont("SARP.ttf", respc(11), false, "antialiased"), 1)

	    local relX, relY = getCursorPosition()

        wardisActiveButton = false

        if relX and relY then
            relX = relX * screenX
            relY = relY * screenY

            for k, v in pairs(wardisButtons) do
                if relX >= v[1] and relY >= v[2] and relX <= v[1] + v[3] and relY <= v[2] + v[4] then
                    wardisActiveButton = k
                    break
                end
            end
        end
        dxDrawImage(panelPosX + panelWidth - respc(4) - respc(18), panelPosY + respc(4), respc(18), respc(18), "files/circle.png", 0, 0, 0, tocolor(t1, t2, t3))
        if wardisActiveButton == "reset" then
            if getPedOccupiedVehicleSeat(localPlayer) == 0 then
                if getKeyState("mouse1") and clickTick+1500 < getTickCount() then
                    triggerServerEvent("taxiclock.reset", localPlayer, localPlayer, getPedOccupiedVehicle(localPlayer))
                    triggerServerEvent("syncButton", localPlayer, getPedOccupiedVehicle(localPlayer), true)
                    clickTick = getTickCount()
                end
            end
        end
        if wardisActiveButton == "start" and getKeyState("mouse1") and clickTick+1500 < getTickCount() then
            if getPedOccupiedVehicleSeat(localPlayer) == 0 then
                if getElementData(getPedOccupiedVehicle(localPlayer),"taxiclock.state") == false then
                    triggerServerEvent("taxiclock.start", localPlayer, localPlayer, getPedOccupiedVehicle(localPlayer))
                    outputChatBox("#ffa500[CosmoMTA - Taxi]:#ffffff A taxióra elindítva!", 255, 255, 255, true)
                    clickTick = getTickCount()
                    --playSound("files/taxibutton.mp3")
                    triggerServerEvent("syncButton", localPlayer, getPedOccupiedVehicle(localPlayer), true)
                    --addVehicleSirens(vehicle, 1, 2, false, false, false, true)
		            --setVehicleSirens(vehicle, 1, sirenPos[getElementModel(vehicle)][1], sirenPos[getElementModel(vehicle)][2], sirenPos[getElementModel(vehicle)][3]-0.07, 255, 166, 0, 255, 10)
                end
            end
        end
        if wardisActiveButton == "stop" and getKeyState("mouse1") and clickTick+1500 < getTickCount() then
            if getPedOccupiedVehicleSeat(localPlayer) == 0 then
                if getElementData(getPedOccupiedVehicle(localPlayer),"taxiclock.state") == true then
                    triggerServerEvent("taxiclock.stop", localPlayer, localPlayer, getPedOccupiedVehicle(localPlayer))
                    outputChatBox("#ffa500[CosmoMTA - Taxi]:#ffffff A taxióra leállítva!", 255, 255, 255, true)
                    clickTick = getTickCount()
                    --playSound("files/taxibutton.mp3")
                    --playSound("files/taxiprint.mp3")ű
                    local vehicle = getPedOccupiedVehicle(localPlayer)
                    local p1, p2, p3 = getElementPosition(getPedOccupiedVehicle(localPlayer))
                    --triggerClientEvent(getVehicleOccupants(vehicle), "playVehicleSound", vehicle, "simple", "files/taxiprint.mp3")
                    triggerServerEvent("syncPrint", localPlayer, getPedOccupiedVehicle(localPlayer), true)
                    triggerServerEvent("syncButton", localPlayer, getPedOccupiedVehicle(localPlayer), true)
                end
            end
        end
        if getElementData(getPedOccupiedVehicle(localPlayer),"taxiclock.state") == true then
            vehtaxi = "yes"
            t1, t2, t3 = 0, 255, 0
        else
            vehtaxi = "no"
            t1, t2, t3 = 255, 0, 0
        end
    end
end
addEventHandler("onClientRender", getRootElement(), renderTaxi)

addEvent("playTaxiSound", true)
addEventHandler("playTaxiSound", getRootElement(),
	function (type, path)
		if isElement(source) then
			if type == "3d" then
				local sourcePosX, sourcePosY, sourcePosZ = getElementPosition(source)
				local sourceInterior = getElementInterior(source)
				local sourceDimension = getElementDimension(source)
				local soundElement = playSound3D(path, sourcePosX, sourcePosY, sourcePosZ)

				if isElement(soundElement) then
					setElementInterior(soundElement, sourceInterior)
					setElementDimension(soundElement, sourceDimension)

					attachElements(soundElement, source)
				end
			else
				playSound(path)
			end
            if path == "files/taxiprint.mp3" and getPedOccupiedVehicle(localPlayer) == source then
                outputChatBox("#ffa500[CosmoMTA - Taxi]: #ffffffA fizetéshez használd a #ffa500/paytaxi#ffffff parancsot!", 255, 255, 255, true)
            end
		end
	end
)

addCommandHandler("paytaxi",
    function()
        local cost = getElementData(getPedOccupiedVehicle(localPlayer),"taxiclock.travelled")
    
        local driver = getVehicleController(getPedOccupiedVehicle(localPlayer))
        local veh = getPedOccupiedVehicle(localPlayer)
        if getElementData(getPedOccupiedVehicle(localPlayer),"taxiclock.state") == false then
            triggerServerEvent("taxiclock.paytaxi",localPlayer,localPlayer,veh,driver,cost)    
        end
    end
)

addEvent("paytaxiChat", true)
addEventHandler("paytaxiChat", getRootElement(),
    function(msg)
        if exports.cosmo_groups:isPlayerHavePermission(localPlayer, "taxi") then
            outputChatBox("#ffa500[CosmoMTA - Taxi]: #ffffff"..msg, 255, 255, 255, true)
        end
    end
)