local screenX, screenY = guiGetScreenSize()

local objectEditorMode = false
local fastMode = false
local objectEditorState = 0
local nearbyobjectMode = false
local objectData = {
	["objectID"] = 980,
	["open"] = {},
	["interior"] = 0,
	["dimension"] = 0,
}

function createPreviewobject(objID)
	if not objectEditorMode then
		local pX, pY, pZ = getElementPosition(localPlayer)
		local prX, prY, prZ = getElementRotation(localPlayer)
		local pInt = getElementInterior(localPlayer)
		local pDim = getElementDimension(localPlayer)
		objectEditorState = 1
		objectEditorMode = true
		if isElement(previewobjectObj) then
			destroyElement(previewobjectObj)
		end
		objectData["objectID"] = objID
		previewobjectObj = createObject(objID, pX, pY, pZ, 0, 0, 0)
		setElementCollisionsEnabled(previewobjectObj, false)
		setElementAlpha(previewobjectObj, 170)
		setElementInterior(previewobjectObj, pInt)
		setElementDimension(previewobjectObj, pDim)
	end
end

function createobjectByCommand(commandName, objectID)
    if getElementData(localPlayer, "acc.adminLevel") >= 6 then
        if objectID then
            if tonumber(objectID) then
                createPreviewobject(tonumber(objectID))
            end
        end
        if not objectID then
            outputChatBox("#E45656[object]#ffffff Add meg az object id-t!",255,255,255,true)
        end
    end
end
addCommandHandler("createobject", createobjectByCommand)

addEventHandler("onClientKey", root, function(button, press)
    if objectEditorMode then
		if (button == "lshift") and (press) then
			cancelEvent()
			
			if fastMode then
				outputChatBox("#b7ff00[object]: #ffffffGyors pozicionálás kikapcsolva", 0, 0, 0, true)
			else
				outputChatBox("#b7ff00[object]: #ffffffGyors pozicionálás bekapcsolva", 0, 0, 0, true)
			end
			fastMode = not fastMode
        elseif (button == "enter") and (press) then
            cancelEvent()
            if (objectEditorState == 1) then
				local hX, hY, hZ = getElementPosition(previewobjectObj)
				local hrX, hrY, hrZ = getElementRotation(previewobjectObj)
                objectData["position"] = {hX, hY, hZ, hrX, hrY, hrZ}
				objectData["interior"] = getElementInterior(previewobjectObj)
                objectData["dimension"] = getElementDimension(previewobjectObj)
				objectEditorState = 0
                triggerServerEvent("createobject", localPlayer, objectData["objectID"], objectData["position"], objectData["interior"], objectData["dimension"])
				outputChatBox("[object] A object létrehozva", 0, 0, 0, true)
                destroyPreviewobject()
            end
        elseif (button == "backspace") and (press) then
            outputChatBox("[object] A object létrehozás vissza vonva.")
            destroyPreviewobject()
        end
    end
end)

function destroyPreviewobject()
	if isElement(previewobjectObj) then
		destroyElement(previewobjectObj)
	end
	objectEditorMode = false
	objectEditorState = 0
end

function nearbyobjects()
	if getElementData(localPlayer, "acc.adminLevel") >= 6 then
		if (nearbyobjectMode) then
			outputChatBox("#E45656[object]#ffffff ID-k eltűntetve",255,255,255,true)
		else
			outputChatBox("#E45656[object]#ffffff ID-k megjelenítve",255,255,255,true)
		end
		nearbyobjectMode = not nearbyobjectMode
	end
end
addCommandHandler("nearbyobjects", nearbyobjects)

addEventHandler("onClientRender", root, function()
	selectedobjectButton = -1
	if nearbyobjectMode then
		for k, object in ipairs(getElementsByType("object", getResourceRootElement())) do
			if object and isElement(object) then
				local objectID = getElementData(object, "object.id")
				if objectID then
					local playerX, playerY, playerZ = getElementPosition(localPlayer)
					local objectX, objectY, objectZ = getElementPosition(object)
					local objectDistance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, objectX, objectY, objectZ)
					if objectDistance <= 15 then
						local screenX, screenY = getScreenFromWorldPosition(objectX, objectY, objectZ + 1, 1)
						if screenX and screenY then
							local scaleMultiplier = 1 - (objectDistance / 10) * 0.5
							local buttonWidth = (dxGetTextWidth("Törlés", 1.2, "default") + 20) * scaleMultiplier
							local boxWidth, boxHeight = (dxGetTextWidth("[object] ID: " .. objectID .. " ", 1.2, "default", true) + 20) * scaleMultiplier, (dxGetFontHeight(1.0, "default") + 10) * scaleMultiplier
							local boxX, boxY = screenX - ((boxWidth + buttonWidth) / 2), screenY - (boxHeight / 2)
							dxDrawText("object ID : " .. objectID .. " ", boxX, boxY, boxX + boxWidth, boxY + boxHeight, tocolor(255, 255, 255, 255), 1.2 * scaleMultiplier, "default", "center", "center", false, false, false, true, true)
							if cursorInBox(boxX + boxWidth, boxY, buttonWidth, boxHeight) then
								dxDrawRectangle(boxX + boxWidth, boxY, buttonWidth, boxHeight, tocolor(215, 89, 89, 255))
								selectedobjectButton = objectID
							else
								dxDrawRectangle(boxX + boxWidth, boxY, buttonWidth, boxHeight, tocolor(215, 89, 89, 200))	
							end
							dxDrawText("Törlés", boxX + boxWidth, boxY, boxX + boxWidth + buttonWidth, boxY + boxHeight, tocolor(0, 0, 0, 255), 1.2 * scaleMultiplier, "default", "center", "center", false, false, false, false, true)
						end
					end
				end
			end
		end
	end
end)

addEventHandler("onClientClick", root, function(button, state)
	if nearbyobjectMode then
		if (state == "down") then
			if (button == "left") then
				if (selectedobjectButton ~= -1) then
					triggerServerEvent("deleteobject", localPlayer, selectedobjectButton)	
				end
			end
		end
	end
end)

addEventHandler("onClientPreRender", root, function()
	if objectEditorMode then
		local hX, hY, hZ = getElementPosition(previewobjectObj)
		local hrX, hrY, hrZ = getElementRotation(previewobjectObj)
		moveValue = 0.01
		if fastMode then
			moveValue = 0.1
		else
			moveValue = 0.01
		end
		if getKeyState("num_4") then
			setElementPosition(previewobjectObj, hX + moveValue, hY, hZ)
		elseif getKeyState("num_6") then
			setElementPosition(previewobjectObj, hX - moveValue, hY, hZ)
		elseif getKeyState("num_8") then
			setElementPosition(previewobjectObj, hX, hY + moveValue, hZ)
		elseif getKeyState("num_2") then
			setElementPosition(previewobjectObj, hX, hY - moveValue, hZ)
		elseif getKeyState("num_7") then
			setElementRotation(previewobjectObj, hrX, hrY, hrZ + moveValue)
		elseif getKeyState("num_1") then
			setElementRotation(previewobjectObj, hrX, hrY, hrZ - moveValue)
		elseif getKeyState("num_9") then
			setElementPosition(previewobjectObj, hX, hY, hZ + moveValue)
		elseif getKeyState("num_3") then
			
			setElementPosition(previewobjectObj, hX, hY, hZ - moveValue)	
		end
	end
end)

function cursorInBox(x, y, w, h)
	if x and y and w and h then
		if isCursorShowing() then
			if not isMTAWindowActive() then
				local cursorX, cursorY = getCursorPosition()
				
				cursorX, cursorY = cursorX * screenX, cursorY * screenY
				
				if cursorX >= x and cursorX <= x + w and cursorY >= y and cursorY <= y + h then
					return true
				end
			end
		end
	end
	
	return false
end