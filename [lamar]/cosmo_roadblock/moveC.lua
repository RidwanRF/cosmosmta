local screenX, screenY = guiGetScreenSize()

local infoShow = false

editorMenu = {
    {"move", "Mozgatás"},
    {"rotate", "Forgatás"},
    {"delete", "Törlés"},
    {"save", "Mentés"}
}

local iconSize = 16
local iconHalfSize = iconSize / 2

local axisLineThickness = 1.5

addEvent("saveObject", true)
addEventHandler("saveObject", root, 
    function(object)
        if object == movabledObject then
            destroyElement(object)
        end
    end
)

local editorColors = {
    axisX = {200, 50, 60},
    axisY = {50, 200, 60},
    axisZ = {50, 60, 200},

    activeMode = {255, 150, 0},
    inactiveMode = {255, 255, 255}
}

addEventHandler("onClientRender", getRootElement(), 
    function()
        if not editorTable then
            return
        end
        if not editorTable.element then
            return
        end
        if not isElement(editorTable.element) then
            return
        end
        local elementX, elementY, elementZ = getElementPosition(editorTable["element"])

        local startX, startY = getScreenFromWorldPosition(elementX, elementY, elementZ, 128)

        local xX, xY, xZ = getPositionFromElementOffset(editorTable.element, editorTable.elementRadius, 0, 0)
        local yX, yY, yZ = getPositionFromElementOffset(editorTable.element, 0, editorTable.elementRadius, 0)
        local zX, zY, zZ = getPositionFromElementOffset(editorTable.element, 0, 0, editorTable.elementRadius)

        local absX, absY = 0, 0

        if isCursorShowing() then
            if not isMTAWindowActive() then
                local relX, relY = getCursorPosition()

                absX, absY = relX * screenX, relY * screenY
            end
        end
        
        endXX, endXY = getScreenFromWorldPosition(xX, xY, xZ, 128)
        endYX, endYY = getScreenFromWorldPosition(yX, yY, yZ, 128)
        endZX, endZY = getScreenFromWorldPosition(zX, zY, zZ, 128)
       
        if not endXX or not endYX or not endZX or not endXY or not endYY or not endZY then
            return
        end
        
        dxDrawImage(endXX - iconHalfSize-2, endXY - iconHalfSize-2, iconSize+4, iconSize+4, "files/circle.png")
        dxDrawImage(endYX - iconHalfSize-2, endYY - iconHalfSize-2, iconSize+4, iconSize+4, "files/circle.png")
        dxDrawImage(endZX - iconHalfSize-2, endZY - iconHalfSize-2, iconSize+4, iconSize+4, "files/circle.png")
        
        dxDrawLine(startX, startY, endXX, endXY, tocolor(255, 255, 255, 255), axisLineThickness, false)
        dxDrawLine(startX, startY, endYX, endYY, tocolor(255, 255, 255, 255), axisLineThickness, false)
        dxDrawLine(startX, startY, endZX, endZY, tocolor(255, 255, 255, 255), axisLineThickness, false)

        dxDrawImage(endXX - iconHalfSize, endXY - iconHalfSize, iconSize, iconSize, "files/" .. editorTable["currentMode"] .. ".png")
        dxDrawImage(endYX - iconHalfSize, endYY - iconHalfSize, iconSize, iconSize, "files/" .. editorTable["currentMode"] .. ".png")
        dxDrawImage(endZX - iconHalfSize, endZY - iconHalfSize, iconSize, iconSize, "files/" .. editorTable["currentMode"] .. ".png")
        
        if editorTable.hoveredMenuIcon then
            editorTable.hoveredMenuIcon = false
        end
        if not editorTable.activeAxis then
            for _FORV_19_ = 1, #editorMenu do
                --if not _UPVALUE7_[editorMenu[_FORV_19_][1]] then
                    if editorMenu[_FORV_19_][1] == "save" then
                        if editorTable.currentMode == editorMenu[_FORV_19_][1] then
                        else
                        end
                    elseif editorMenu[_FORV_19_][1] == "reset" then
                        if editorTable.currentMode == editorMenu[_FORV_19_][1] then
                        else
                        end
                    elseif editorTable.currentMode == editorMenu[_FORV_19_][1] then
                    end
                    local currentColor = {255, 255, 255}
                    local iconX = ((startX - iconHalfSize) + ((_FORV_19_ - 1) * (iconSize + 5))) + 32
                    local iconY = (startY - iconHalfSize) + 32
                    dxDrawRectangle(iconX, iconY, iconSize, iconSize, tocolor(currentColor[1], currentColor[2], currentColor[3], 255))
                    dxDrawImage(iconX, iconY, iconSize, iconSize, "files/" .. editorMenu[_FORV_19_][1] .. ".png")

                    if absX >= iconX and absX <= iconX + iconSize and absY >= iconY and absY <= iconY + iconSize then
                        editorTable["hoveredMenuIcon"] = _FORV_19_
                    end
               -- end
            end
        end
        if editorTable.hoveredMenuIcon then
            local tooltipWidth = dxGetTextWidth(editorMenu[editorTable["hoveredMenuIcon"]][2], 1.0, iconFont) + 10
            local tooltipHeight = dxGetFontHeight(1.0, Roboto) + 10

            dxDrawRectangle(absX + 10, absY, tooltipWidth, tooltipHeight, tocolor(0, 0, 0, 200))
            dxDrawText(editorMenu[editorTable["hoveredMenuIcon"]][2], absX + 10, absY, absX + 10 + tooltipWidth, absY + tooltipHeight, tocolor(255, 255, 255, 255), 1.0, iconFont, "center", "center")

            if getKeyState("mouse1") then
                local hoveredMenuIcon = editorMenu[editorTable["hoveredMenuIcon"]][1]
                
                if editorTable["currentMode"] ~= hoveredMenuIcon then
                    if hoveredMenuIcon == "save" then
                        saveEditorElementChanges()
                    elseif hoveredMenuIcon == "delete" then
                        if isElement(editorTable.element) then
                            destroyElement(editorTable.element)
                            toggleEditor(false)
                            loadingLastTick = getTickCount()
                            renderData.notificationText = "Sikeresen kitörölted az útzárat!"
                            playSound("files/sounds/delete.mp3")
                        end
                    else
                        editorTable["currentMode"] = hoveredMenuIcon
                    end
                end
            end
        end
        if editorTable and editorTable["hoveredMode"] then
            editorTable["hoveredMode"] = false
        end

        if absX >= endXX - iconHalfSize and absX <= endXX - iconHalfSize + iconSize and absY >= endXY - iconHalfSize and absY <= endXY - iconHalfSize + iconSize then
            editorTable["hoveredMode"] = "X"
        elseif absX >= endYX - iconHalfSize and absX <= endYX - iconHalfSize + iconSize and absY >= endYY - iconHalfSize and absY <= endYY - iconHalfSize + iconSize then
            editorTable["hoveredMode"] = "Y"
        elseif absX >= endZX - iconHalfSize and absX <= endZX - iconHalfSize + iconSize and absY >= endZY - iconHalfSize and absY <= endZY - iconHalfSize + iconSize then
            editorTable["hoveredMode"] = "Z"
        end
        if editorTable and editorTable.activeAxis then
            if isCursorShowing() and getKeyState("mouse1") then
                
                local relX, relY = getCursorPosition()
                local cameraRotation = getCameraRotation()

                local elementX, elementY, elementZ = 0, 0, 0
                local elementRX, elementRY, elementRZ = 0, 0, 0
                local elementSX, elementSY, elementSZ = 0, 0, 0

                if isElementAttached(editorTable["element"]) then
                    elementX, elementY, elementZ, elementRX, elementRY, elementRZ = getElementAttachedOffsets(editorTable["element"])

                    local attachedElementRX, attachedElementRY, attachedElementRZ = getElementRotation(getElementAttachedTo(editorTable["element"]))

                    cameraRotation = cameraRotation + attachedElementRZ
                else
                    elementX, elementY, elementZ = getElementPosition(editorTable["element"])
                    elementRX, elementRY, elementRZ = getElementRotation(editorTable["element"])
                end

                if getElementType(editorTable["element"]) == "object" then
                    elementSX, elementSY, elementSZ = getObjectScale(editorTable["element"])
                end

                if editorTable["currentMode"] == "move" then
                    if editorTable["activeAxis"] == "X" then
                        elementX = getInFrontOf(elementX, false, -(cameraRotation + 90), ((relX - 0.5) * 5))
                    elseif editorTable["activeAxis"] == "Y" then
                        elementY = getInFrontOf(false, elementY, -cameraRotation, -((relY - 0.5) * 5))
                    elseif editorTable["activeAxis"] == "Z" then
                        elementZ = elementZ - ((relY - 0.5) * 5)
                    end
                elseif editorTable["currentMode"] == "rotate" then
                    if editorTable["activeAxis"] == "X" then
                        elementRX = getInFrontOf(elementRX, false, -(cameraRotation + 90), ((relY - 0.5) * 15))
                    elseif editorTable["activeAxis"] == "Y" then
                        elementRY = getInFrontOf(false, elementRY, -cameraRotation, ((relX - 0.5) * 15))
                    elseif editorTable["activeAxis"] == "Z" then
                        elementRZ = getInFrontOf(elementRZ, false, -(cameraRotation + 90), -((relX - 0.5) * 15))
                    end
                elseif editorTable["currentMode"] == "scale" then
                    if editorTable["activeAxis"] == "X" then
                        elementSX = getInFrontOf(elementSX, false, -(cameraRotation + 90), ((relX - 0.5) * 5))
                    elseif editorTable["activeAxis"] == "Y" then
                        elementSY = getInFrontOf(false, elementSY, -cameraRotation, ((relY - 0.5) * 5))
                    elseif editorTable["activeAxis"] == "Z" then
                        elementSZ = elementSZ - ((relY - 0.5) * 5)
                    end
                end

                if isElementAttached(editorTable["element"]) then
                    setElementAttachedOffsets(editorTable["element"], elementX, elementY, elementZ, elementRX, elementRY, elementRZ)
                else
                    setElementPosition(editorTable["element"], elementX, elementY, elementZ)
                    setElementRotation(editorTable["element"], elementRX, elementRY, elementRZ)
                end

                if getElementType(editorTable["element"]) == "object" then
                    elementSX = math.max(0.25, math.min(3.0, elementSX))
                    elementSY = math.max(0.25, math.min(3.0, elementSY))
                    elementSZ = math.max(0.25, math.min(3.0, elementSZ))

                    setObjectScale(editorTable["element"], elementSX, elementSY, elementSZ)
                end
                
                setCursorPosition(screenX / 2, screenY / 2)
                setCursorAlpha(0)
            elseif editorTable.activeAxis then
                editorTable.activeAxis = false
                setCursorAlpha(255)
            end
        end
    end
)

addEventHandler("onClientClick", getRootElement(), 
    function (button, state, absX, absY)
        if not editorTable then
            return
        end
        if button == "left" then
            if state == "down" then
                if editorTable["hoveredMode"] then
                    setCursorPosition(screenX / 2, screenY / 2)
                    setCursorAlpha(0)
                    editorTable["activeAxis"] = editorTable["hoveredMode"]
                end
            elseif state == "up" then
                local oldActiveAxis = editorTable["activeAxis"]
                if oldActiveAxis then
                    editorTable["activeAxis"] = false
                    if oldActiveAxis == "X" then
                        setCursorPosition(endXX, endXY)
                    elseif oldActiveAxis == "Y" then
                        setCursorPosition(endYX, endYY)
                    elseif oldActiveAxis == "Z" then
                        setCursorPosition(endZX, endZY)
                    end
                        setCursorAlpha(255)
                    end
                end
            end
        end
)



function getPositionFromElementOffset(element, offsetX, offsetY, offsetZ)
    local elementMatrix = getElementMatrix(element, false)

    local elementX = offsetX * elementMatrix[1][1] + offsetY * elementMatrix[2][1] + offsetZ * elementMatrix[3][1] + elementMatrix[4][1]
    local elementY = offsetX * elementMatrix[1][2] + offsetY * elementMatrix[2][2] + offsetZ * elementMatrix[3][2] + elementMatrix[4][2]
    local elementZ = offsetX * elementMatrix[1][3] + offsetY * elementMatrix[2][3] + offsetZ * elementMatrix[3][3] + elementMatrix[4][3]

    return elementX, elementY, elementZ
end

function toggleEditor(theObject, _ARG_1_, ...)
    _UPVALUE0_ = {}
    if theObject then
        if _ARG_1_ then
            for _FORV_6_, _FORV_7_ in ipairs(_ARG_1_) do
                _UPVALUE0_[_FORV_7_] = true
            end
        end
        editorTable = {
            element = theObject,
            elementRadius = 0.37,
            defaultX = 0,
            defaultY = 0,
            defaultZ = 0,
            defaultRX = 0,
            defaultRY = 0,
            defaultRZ = 0,
            defaultScale = getObjectScale(theObject),
            others = {
                ...
            },
            currentMode = "move",
            hoveredMode = false,
            hoveredMenuIcon = false,
            activeAxis = false
        }
        renderData.editingState = true
    else
        editorTable = nil
        setCursorAlpha(255)
        renderData.editingState = false
    end
end

function getCameraRotation()
    local cx, cy, _, tx, ty = getCameraMatrix()

    return math.deg(math.atan2(tx - cx, ty - cy))
end

function getInFrontOf(x, y, angle, distance)
    distance = distance or 1

    if x and not y then
        return x + distance * math.sin(math.rad(-angle))
    elseif not x and y then
        return y + distance * math.cos(math.rad(-angle))
    elseif x and y then
        return x + distance * math.sin(math.rad(-angle)), y + distance * math.cos(math.rad(-angle))
    end
end

function saveEditorElementChanges()
    if not editorTable then
        return
    end

    if not editorTable["element"] or not isElement(editorTable["element"]) then
        return
    end
    
    if not saveState then
        local x, y, z = getElementPosition(editorTable.element)
        local rx, ry, rz = getElementRotation(editorTable.element)
        triggerServerEvent("syncObjectToServer", localPlayer, #saveTable + 1, getElementModel(editorTable.element), x, y, z, rx, ry, rz)
        destroyElement(editorTable.element)
        saveTable[#saveTable + 1] = {
            objID = saveObjectID,
            name = saveObjectName,
            x = x,
            y = y,
            z = z,
            index = #saveTable + 1,
        }
    else
        local x, y, z = getElementPosition(editorTable.element)
        local rx, ry, rz = getElementRotation(editorTable.element)
        triggerServerEvent("syncObjectToServer", localPlayer, saveObjectIndex, getElementModel(editorTable.element), x, y, z, rx, ry, rz)
        destroyElement(editorTable.element)
        print(saveObjectKey)
        saveTable[saveObjectKey] = {
            objID = saveObjectID,
            name = saveObjectName,
            x = x,
            y = y,
            z = z,
            index = saveObjectKey,
        } 
    end
    loadingLastTick = getTickCount()
    renderData.notificationText = "Sikeres lehelyezted az útzárat!"
    playSound("files/sounds/accept.mp3")
    toggleEditor(false)
end