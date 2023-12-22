local screenX, screenY = guiGetScreenSize()
local UI = exports.cosmo_ui
local responsiveMultipler = UI:getResponsiveMultiplier()

function loadFonts()
    fonts = {
        Roboto11 = exports.cosmo_assets:loadFont("Roboto-Regular.ttf", respc(11), false, "antialiased"),
        Roboto14 = exports.cosmo_assets:loadFont("Roboto-Regular.ttf", respc(14), false, "antialiased"),
        Roboto16 = exports.cosmo_assets:loadFont("Roboto-Regular.ttf", respc(16), false, "cleartype"),
        Roboto18 = exports.cosmo_assets:loadFont("Roboto-Regular.ttf", respc(18), false, "cleartype"),
        RobotoL = exports.cosmo_assets:loadFont("Roboto-Light.ttf", respc(18), false, "cleartype"),
        RobotoL14 = exports.cosmo_assets:loadFont("Roboto-Light.ttf", respc(14), false, "cleartype"),
        RobotoL16 = exports.cosmo_assets:loadFont("Roboto-Light.ttf", respc(16), false, "cleartype"),
        RobotoL18 = exports.cosmo_assets:loadFont("Roboto-Light.ttf", respc(18), false, "cleartype"),
        RobotoL24 = exports.cosmo_assets:loadFont("Roboto-Light.ttf", respc(24), false, "cleartype"),
        RobotoLI16 = exports.cosmo_assets:loadFont("Roboto-Light-Italic.ttf", respc(16), false, "cleartype"),
        RobotoLI24 = exports.cosmo_assets:loadFont("Roboto-Light-Italic.ttf", respc(24), false, "cleartype"),
        RobotoB18 = exports.cosmo_assets:loadFont("Roboto-Bold.ttf", respc(18), false, "antialiased"),
    }
end

local registerEvent = function(eventName, element, func)
	addEvent(eventName, true)
	addEventHandler(eventName, element, func)
end

addEventHandler("onAssetsLoaded", root, function ()
	loadFonts()
end)

addEventHandler("onClientResourceStart", resourceRoot, function ()
	loadFonts()
end)

function resp(value)
    return value * responsiveMultipler
end

function respc(value)
    return math.ceil(value * responsiveMultipler)
end

Interaction = {}

local selectedElement = nil
local elementInteractions = {}

local panelW, panelH = respc(300), respc(65)
local panelX, panelY = (screenX - panelW) / 2, (screenY - panelH) / 2

local scrollbarW = respc(12)

local rowW, rowH = panelW, respc(40)
local rowX = panelX

local iconW, iconH = respc(40), respc(40)

local actionTextX = panelX + iconH + respc(10)

local maxRow = 6

local isFactiory = false
local maxDis = 4

--[[local test = {
    {"Bezárás", ":cosmo_assets/images/sarplogo_big.png", {100, 100, 100}, "action"},
    {"Menü 2", ":cosmo_assets/images/sarplogo_big.png", {100, 100, 100}},
    {"Menü 3", ":cosmo_assets/images/sarplogo_big.png", {100, 100, 100}},
    {"Menü 4", ":cosmo_assets/images/sarplogo_big.png", {100, 100, 100}},
    {"Menü 5", ":cosmo_assets/images/sarplogo_big.png", {100, 100, 100}},
    --{"Menü 6", ":cosmo_assets/images/sarplogo_big.png", {100, 100, 100}},
    --{"Menü 7", ":cosmo_assets/images/sarplogo_big.png", {100, 100, 100}},
    --{"Menü 8", ":cosmo_assets/images/sarplogo_big.png", {100, 100, 100}},
}--]]
local interactionActive = false

Interaction.Show = function(element)
    elementInteractions = getInteractions(element)
    selectedElement = element
    interactionActive = true
    addEventHandler("onClientRender", root, Interaction.Render)
end

Interaction.Close = function()
    elementInteractions = {}
    interactionActive = false
    --destroyElementOutlineEffect(selectedElement)
    effectOn = false
    removeEventHandler("onClientRender", root, Interaction.Render)
end

Interaction.Render = function()
    if interactionActive then
        Interaction.Panel(elementInteractions)
    end
end

Interaction.Panel = function(interactions)
    if interactionActive then
        local px, py, pz = getElementPosition(localPlayer)
        local ex, ey, ez = getElementPosition(selectedElement)
        if getDistanceBetweenPoints3D(px, py, pz, ex, ey, ez) > getElementRadius(selectedElement) * maxDis then
            Interaction.Close()
            return
        end

        local adjustH = #interactions
        if #interactions > 6 then
            adjustH = maxRow
        end

        if getElementType(selectedElement) == "vehicle" then
            local textW = dxGetTextWidth(exports.cosmo_mods_veh:getVehicleName(selectedElement), 1, fonts.Roboto14)
            panelW = textW + respc(200)
            rowW = textW + respc(200)
		else
			panelW = respc(300)
			rowW = panelW
        end

        dxDrawRectangle(panelX, panelY, panelW, panelH + (rowH * adjustH), tocolor(31, 31, 31, 240))

        if getElementType(selectedElement) == "vehicle" then
            dxDrawText(exports.cosmo_mods_veh:getVehicleName(selectedElement), panelX, panelY + respc(10), panelW + panelX, panelH + panelY, tocolor(255, 255, 255, 255), 1, fonts.Roboto14, "center", "top")
        elseif getElementType(selectedElement) == "player" then
            dxDrawText(getPlayerName(selectedElement):gsub("_", " "), panelX, panelY + respc(10), panelW + panelX, panelH + panelY, tocolor(255, 255, 255, 255), 1, fonts.Roboto14, "center", "top")
        elseif getElementType(selectedElement) == "ped" then
            dxDrawText(getElementData(selectedElement, "ped.name"):gsub("_", " "), panelX, panelY + respc(10), panelW + panelX, panelH + panelY, tocolor(255, 255, 255, 255), 1, fonts.Roboto14, "center", "top")
        elseif getElementType(selectedElement) == "object" then
            dxDrawText(getElementData(selectedElement, "object.name"):gsub("_", " "), panelX, panelY + respc(10), panelW + panelX, panelH + panelY, tocolor(255, 255, 255, 255), 1, fonts.Roboto14, "center", "top")
        end


        if getElementType(selectedElement) == "vehicle" then
            dxDrawText("(Jármű)", panelX, panelY + respc(10) + dxGetFontHeight(1, fonts.Roboto14), panelW + panelX, panelH + panelY, tocolor(255, 255, 255, 255), 1, fonts.Roboto11, "center", "top")
        elseif getElementType(selectedElement) == "player" then
            dxDrawText("(Játékos)", panelX, panelY + respc(10) + dxGetFontHeight(1, fonts.Roboto14), panelW + panelX, panelH + panelY, tocolor(255, 255, 255, 255), 1, fonts.Roboto11, "center", "top")
        elseif getElementType(selectedElement) == "ped" then
            dxDrawText("(NPC)", panelX, panelY + respc(10) + dxGetFontHeight(1, fonts.Roboto14), panelW + panelX, panelH + panelY, tocolor(255, 255, 255, 255), 1, fonts.Roboto11, "center", "top")
        elseif getElementType(selectedElement) == "object" then
            dxDrawText("(Tárgy)", panelX, panelY + respc(10) + dxGetFontHeight(1, fonts.Roboto14), panelW + panelX, panelH + panelY, tocolor(255, 255, 255, 255), 1, fonts.Roboto11, "center", "top")
        end
        --if 
        --dxDrawText("(Típusa)", panelX, panelY + respc(10) + dxGetFontHeight(1, fonts.Roboto14), panelW + panelX, panelH + panelY, tocolor(255, 255, 255, 255), 1, fonts.Roboto11, "center", "top")

        local interactionOffset = scrollData["interactionOffset"] or 0

        local calculatedRowW = rowW
        if #interactions > adjustH then
            drawScrollbar("interaction", rowX + rowW - scrollbarW, panelY + panelH, scrollbarW, rowH * adjustH, adjustH, #interactions)
            calculatedRowW = rowW - scrollbarW
        end

        for i = 1, adjustH do
            local interaction = interactions[i + interactionOffset]

            if interaction then
	            local rowY = panelY + panelH + (rowH * (i - 1))
	            if i % 2 == 0 then 
	                --dxDrawRectangle(rowX, rowY, rowW, rowH, tocolor(53, 53, 53, 50))
	                dxDrawInteractionButton("interaction:" .. i, interaction[1], rowX, rowY, calculatedRowW, rowH, {53, 53, 53, 50}, {255, 148, 40, 200}, {255, 255, 255}, fonts.Roboto11, "left", "center", interaction[2], iconW, iconH, {100, 100, 100})
	            else
	                --dxDrawRectangle(rowX, rowY, rowW, rowH, tocolor(53, 53, 53, 100))
	                dxDrawInteractionButton("interaction:" .. i, interaction[1], rowX, rowY, calculatedRowW, rowH, {53, 53, 53, 100}, {255, 148, 40, 200}, {255, 255, 255}, fonts.Roboto11, "left", "center", interaction[2], iconW, iconH, {100, 100, 100})
	            end
	        end
            --dxDrawImage(rowX + respc(5), rowY + respc(5), iconW - respc(10), iconH - respc(10), interaction[2], 0, 0, 0, tocolor(interaction[3][1], interaction[3][2], interaction[3][3], 255))
            --dxDrawText(interaction[1], actionTextX, rowY, actionTextX, rowY + rowH, tocolor(255, 255, 255, 255), 1, fonts.Roboto11, "left", "center")
            --dxDrawRectangle(panelX, panelY + panelH, rowW, rowH, tocolor(31, 31, 31, 240))
        end

        activeButtonChecker()
    end
end

addEventHandler("onClientClick", root, function(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
    if button == "right" and state == "down" then
        if not interactionActive then
            local cameraX, cameraY, cameraZ = getCameraMatrix()

            worldX, worldY, worldZ = (worldX - cameraX) * 200, (worldY - cameraY) * 200, (worldZ - cameraZ) * 200

            local _, _, _, _, hitElement = processLineOfSight(cameraX, cameraY, cameraZ, worldX + cameraX, worldY + cameraY, worldZ + cameraZ, false, true, true, true, false, false, false, false, localPlayer)
            if hitElement then
                clickedElement = hitElement
            end

            if isElement(clickedElement) then
                if clickedElement ~= localPlayer then
                    if getElementData(clickedElement, "isInteractable") or getElementType(clickedElement) == "vehicle" or getElementType(clickedElement) == "player" or getElementData(clickedElement, "isSafe") or getElementData(clickedElement, "isWeaponBox") then
                        if getElementData(clickedElement, "isFactoryObject") then
							maxDis = 4
						elseif getElementData(clickedElement, "safeId") then
							maxDis = 4
						elseif getElementData(clickedElement, "isWeaponBox") then
							maxDis = 4
						else
							maxDis = 2
						end

						if exports.cosmo_core:inDistance3D(clickedElement, localPlayer, getElementRadius(clickedElement) * maxDis) then
                            if clickedElement ~= selectedElement then
                                --destroyElementOutlineEffect(selectedElement)
                                effectOn = false
                            end
                            effectOn = true
                            --createElementOutlineEffect(clickedElement, true)
                            Interaction.Show(clickedElement)
                        end
                    end
                end
            end
        else
            exports.cosmo_alert:showAlert("error", "Előbb zárd be az interakció panelt")
        end
    elseif button == "left" and state == "down" then
        if interactionActive then
            for i = 1, #elementInteractions do
                if activeButton == "interaction:" .. i then
                    playSound(":cosmo_assets/audio/interface/click.ogg")
                    local k = i + scrollData["interactionOffset"]
                    if elementInteractions[k][3] then 
                        if type(elementInteractions[k][3]) == "string" then
                            triggerEvent(elementInteractions[k][3], localPlayer, selectedElement, i - 1)
                        else
                            elementInteractions[k][3](localPlayer, selectedElement, i - 1)
                        end
                    end
                    Interaction.Close()
                end
            end
        end
    end
end)

addEventHandler("onClientKey", getRootElement(),
    function (key, press)
        if interactionActive then
            if press then
                --if activePage == "Property" then
                    --if selectedTab == "vehicle" then
                        local offset = scrollData["interactionOffset"] or 0

                        if key == "mouse_wheel_down" and offset < #elementInteractions - maxRow then
                            offset = offset + 1
                        elseif key == "mouse_wheel_up" and offset > 0 then
                            offset = offset - 1
                        end

                        scrollData["interactionOffset"] = offset
                    --end
                --end
            end
        end
    end
)