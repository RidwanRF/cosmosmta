local screenX, screenY = guiGetScreenSize()

local moveDiffX, moveDiffY = 0, 0
local absX, absY = 0, 0
local isMovePanel = false
local renderPanel = false

local panelPosX = screenX / 2
local panelPosY = screenY / 2

local panelw, panelh = 130, 86
local panelx, panely = (screenX/2 - panelw/2) + screenX/2 - 100, (screenY/2 - panelh/2)

local cosmoTuning = {
    [1] = {"Gyorsulás", "Végsebesség", -1, 1, 0, "fasz", "Gyorsulás - Végsebesség"},
    [2] = {"Első fék", "Hátsó fék", -1, 1, 0, "pina", "Fékek"},
    [3] = {"Jobb fogyasztás", "Jobb gyorsulás", -1, 1, 0, "apad", " Jobb fogyasztás - Gyorsulás"},
    [4] = {"Előre", "Hátra", -1, 1, 0, "apad2", "Súlypont"},
}


local buttons = {}
local activeButton = false
local selected = 0

local lastClick = getTickCount()

addCommandHandler("drivetype",
    function ()
        if isPedInVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
            local currVeh = getPedOccupiedVehicle(localPlayer)
            if getElementData(currVeh, "danihe->tuning->drivetype") == 1 then

                renderPanel = not renderPanel

                if renderPanel then
                    addEventHandler("onClientClick", root, onClickDrivetype)
                    addEventHandler("onClientRender", root, renderDrivetype)

                    currentVehicle = currVeh
                else
                    removeEventHandler("onClientClick", root, onClickDrivetype)
                    removeEventHandler("onClientRender", root, renderDrivetype)
                end
            end
        end
    end)

setElementData(localPlayer, "mode", false)

function renderDrivetype()
    if not isPedInVehicle(localPlayer) or currentVehicle ~= getPedOccupiedVehicle(localPlayer) then
        renderPanel = false
        removeEventHandler("onClientRender", getRootElement(), renderDrivetype)
        removeEventHandler("onClientClick", getRootElement(), onClickDrivetype)
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

        buttons["button:up"] = {panelx + 28, panely + 32,43, 35} --RWD
        buttons["button:down"] = {panelx + 86, panely + 32,43, 35} --AWD

        dxDrawImage(panelx + 13, panely + 15,panelw, panelh, "files/panel.png", 0, 0, 0, tocolor(255, 255, 255, 255))--Background
        if getElementData(localPlayer, "mode", false) then
            dxDrawImage(panelx + 13, panely + 15,panelw, panelh,  "files/led1.png", 0, 0, 0, tocolor(33, 168, 198, 255)) --RWD
        end
        if not getElementData(localPlayer, "mode", false) then
            dxDrawImage(panelx+13, panely+15,panelw, panelh,  "files/led2.png", 0, 0, 0, tocolor(33, 168, 198, 255)) --AWD
        end     
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

function onClickDrivetype(button, state, absX, absY, worldX, worldY, worldZ, clickedWorld)	--KESZ MEGIRVA UJRA
	if button == "left" then
		if activeButton and state == "down" then
			local button = split(activeButton, ":")
			if button[2] == "down" then --led1 rwd
				if getTickCount() - lastClick > 1500 then --LED 1
                    local veh = getPedOccupiedVehicle(localPlayer)
                    setElementData(localPlayer, "mode", false) --RWD
                    triggerServerEvent("awd", resourceRoot, localPlayer)
                    --print("RWD - Button")
                end
			elseif button[2] == "up" then --led2 awd
				if getTickCount() - lastClick > 1500 then
                    local veh = getPedOccupiedVehicle(localPlayer)
                    setElementData(localPlayer, "mode", true) --AWD
                    triggerServerEvent("rwd", resourceRoot, localPlayer)
                    --print("AWD - Button")
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

