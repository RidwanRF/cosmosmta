local screenX, screenY = guiGetScreenSize()
iconFont = dxCreateFont("files/fonts/FontAwesome.ttf", respc(14),false, "proof")
Roboto = dxCreateFont("files/fonts/Roboto.ttf", respc(14),false, "proof")
local iconPath = "files/icons/"
local rbg = {30,30,30,255}
local rgb2 = {20,20,20,200}
local textX = 0
loadingLastTick = 0
local selectedTable = objectList



renderData = {
  panelW = screenX,
  panelH = respc(150),
  rbsPanelState = false,
  notificationText = "",
  pageIndex = "home",
  selectedObjIndex = 0,
  editingState = false,
}

-- // variables for Object creation
local hitPosX, hitPosY, hitPosZ = 0,0,0
local saveObjectTable = {}
createdObject = nil

local favoriteTable = {}
saveTable = {}
saveObjectID = 0
saveObjectName = ""
saveObjectIndex = 0
saveObjectKey = 0

local buttonTable = {
  {"exit", ""},
  {"home", ""},
  {"favorites", ""},
  {"save", ""},
}

local activeDirectX = false
local lastActiveDirectX = false


function drawMainMenu()
  lastActiveDirectX = activeDirectX
	activeDirectX = false

  drawBoxByState("top", 0, screenY-renderData.panelH-respc(30), renderData.panelW, respc(30), rgb2, renderData.rbsPanelState, false)
  drawBoxByState("background", 0, screenY-renderData.panelH, renderData.panelW, renderData.panelH, rbg, renderData.rbsPanelState, false)

  -- // Notification text center
  local cTick = getTickCount ()
	local progress = (cTick - loadingLastTick)/1000
  textX, _, _ = interpolateBetween ( 0, 0, 0, dxGetTextWidth(renderData.notificationText, 0.8, Roboto), 0, 0, progress, "Linear")
  dxDrawText(renderData.notificationText, screenX/2-textX/2, screenY-renderData.panelH-respc(30), screenX/2+textX/2, screenY-renderData.panelH, tocolor(255,255,255,255), 0.8, Roboto, "left", "center",true)


  -- // buttons
  for k, v in pairs(buttonTable) do
  --  drawBoxByState("buttn"..k, respc(10)+(k-1)*respc(40), screenY-renderData.panelH-respc(30), respc(30), respc(30), {255,255,255,255}, renderData.rbsPanelState, false)
    if renderData.pageIndex == v[1] then
      drawAlphaText("icons"..k, renderData.rbsPanelState, v[2], respc(10)+(k-1)*respc(40), screenY-renderData.panelH-respc(30), respc(30), respc(30), {255, 148, 40,255}, 0.8, iconFont, "left", "center")
    else
      if isCursorInBox(respc(10)+(k-1)*respc(40), screenY-renderData.panelH-respc(30), respc(30), respc(30)) then
        drawAlphaText("icons"..k, renderData.rbsPanelState, v[2], respc(10)+(k-1)*respc(40), screenY-renderData.panelH-respc(30), respc(30), respc(30), {255, 148, 40,255}, 0.8, iconFont, "left", "center")
      else
        drawAlphaText("icons"..k, renderData.rbsPanelState, v[2], respc(10)+(k-1)*respc(40), screenY-renderData.panelH-respc(30), respc(30), respc(30), {255,255,255,255}, 0.8, iconFont, "left", "center")
      end
    end
  end

  --// objects
  for k, v in pairs(selectedTable) do
    drawBoxByState("object"..k, respc(10)+(k-1)*respc(140), screenY-renderData.panelH+respc(10), respc(130), renderData.panelH-respc(20), rgb2, renderData.rbsPanelState, false)
    drawAlphaText("objectName"..k, renderData.rbsPanelState, v.name, respc(10)+(k-1)*respc(140), screenY-renderData.panelH+respc(10), respc(130), renderData.panelH-respc(25), {255, 255, 255,255}, 0.7, Roboto, "center", "bottom")

    if v.favorite then
      drawAlphaText("addToFavorite"..k, renderData.rbsPanelState, "", respc(15)+(k-1)*respc(140), screenY-renderData.panelH+respc(15), respc(130), renderData.panelH-respc(20), {124, 197, 118,255}, 0.7, iconFont, "left", "top")
    else
      if isCursorInBox(respc(15)+(k-1)*respc(140), screenY-renderData.panelH+respc(15), respc(15), respc(15)) then
        drawAlphaText("addToFavorite"..k, renderData.rbsPanelState, "", respc(15)+(k-1)*respc(140), screenY-renderData.panelH+respc(15), respc(130), renderData.panelH-respc(20), {255, 255, 255,255}, 0.7, iconFont, "left", "top")
      else
        drawAlphaText("addToFavorite"..k, renderData.rbsPanelState, "", respc(15)+(k-1)*respc(140), screenY-renderData.panelH+respc(15), respc(130), renderData.panelH-respc(20), {255, 255, 255,150}, 0.7, iconFont, "left", "top")
      end
    end

    if renderData.rbsPanelState then
      drawFrame("hoverFrame"..k, respc(10)+(k-1)*respc(140), screenY-renderData.panelH+respc(10), respc(130), renderData.panelH-respc(20), respc(2), {255,255,255,255})
      if isCursorInBox(respc(10)+(k-1)*respc(140), screenY-renderData.panelH+respc(10), respc(130), renderData.panelH-respc(20)) then
        activeDirectX = "hoverFrame"..k
      end
    end

    if renderData.selectedObjIndex == k then state = true else state = false end
    drawFrameByState("selectedFrame"..k, respc(10)+(k-1)*respc(140), screenY-renderData.panelH+respc(10), respc(130), renderData.panelH-respc(20), respc(2), {255, 148, 40, 255}, false, state)

    if v.image then
      drawImageByState("objectImage"..k, respc(10)+(k-1)*respc(140), screenY-renderData.panelH, respc(130), renderData.panelH-respc(20), {255,255,255,255}, renderData.rbsPanelState, v.image)
    else
      drawImageByState("objectImage"..k, respc(10)+(k-1)*respc(140), screenY-renderData.panelH, respc(130), renderData.panelH-respc(20), {255,255,255,255}, renderData.rbsPanelState, objectImagePath.."noobj.png")
    end
  end

  --// Check for favorite elements
  if #selectedTable == 0 and renderData.pageIndex ~= "save" then
    noFavState = true
  else
    noFavState = false
  end
  drawAlphaText("noFav", noFavState, " Még egyetlen útzárat sem helyeztél a kedvencek közé", 0, screenY-renderData.panelH, renderData.panelW, renderData.panelH, {217, 83, 79,255}, 1, iconFont, "center", "center")

  -- // Move our object with the Cursor
  if renderData.selectedObjIndex > 0 and isCursorShowing() then
    local relativeX, relativeY = getCursorPosition()
    cursorX, cursorY = relativeX * screenX, relativeY * screenY
    local cameraPosX, cameraPosY, cameraPosZ = getCameraMatrix()
    local cursorWorldPosX, cursorWorldPosY, cursorWorldPosZ = getWorldFromScreenPosition(cursorX, cursorY, 1000)
    local hit, hitX, hitY, hitZ, hitElement, normalX, normalY, normalZ = processLineOfSight(cameraPosX, cameraPosY, cameraPosZ, cursorWorldPosX, cursorWorldPosY, cursorWorldPosZ, true, true, false, true, true, true, false, true, createdObject)
    hitPosX, hitPosY, hitPosZ = hitX, hitY, hitZ
    setElementPosition(createdObject, hitX, hitY, hitZ)
  end

  -- // Saving panel
  if renderData.pageIndex == "save" then
     saveState = true
     if #saveTable == 0 then noSavings = true else noSavings = false end
  else
     saveState = false
     noSavings = false
  end
  drawAlphaText("noSaves", noSavings, " Még egyetlen útzárat sem helyeztél le", 0, screenY-renderData.panelH, renderData.panelW, renderData.panelH, {217, 83, 79,255}, 1, iconFont, "center", "center")

  for k, v in pairs(saveTable) do
    drawBoxByState("savedIbject"..k, respc(10)+(k-1)*respc(140), screenY-renderData.panelH+respc(10), respc(130), renderData.panelH-respc(20), rgb2, saveState, false)
    drawAlphaText("savedObjectName"..k, saveState, v.name, respc(10)+(k-1)*respc(140), screenY-renderData.panelH+respc(10), respc(130), renderData.panelH-respc(25), {255, 255, 255,255}, 0.7, Roboto, "center", "bottom")
    drawImageByState("savedObjectImage"..k, respc(10)+(k-1)*respc(140), screenY-renderData.panelH, respc(130), renderData.panelH-respc(20), {255,255,255,255}, saveState, objectImagePath.."noobj.png")
    if isCursorInBox(respc(15)+(k-1)*respc(140), screenY-renderData.panelH+respc(15), respc(15), respc(15)) then
      drawAlphaText("saveIcon"..k, saveState, "", respc(15)+(k-1)*respc(140), screenY-renderData.panelH+respc(15), respc(130), renderData.panelH-respc(20), {217, 83, 79,255}, 0.7, iconFont, "left", "top")
    else
      drawAlphaText("saveIcon"..k, saveState, "", respc(15)+(k-1)*respc(140), screenY-renderData.panelH+respc(15), respc(130), renderData.panelH-respc(20), {217, 83, 79,150}, 0.7, iconFont, "left", "top")
    end
    drawAlphaText("deleteSavingIcon"..k, saveState, "#"..k, respc(5)+(k-1)*respc(140), screenY-renderData.panelH+respc(15), respc(130), renderData.panelH-respc(20), {255, 255, 255,255}, 0.7, Roboto, "right", "top")

    if saveState then
      drawFrame("savedHoverFrame"..k, respc(10)+(k-1)*respc(140), screenY-renderData.panelH+respc(10), respc(130), renderData.panelH-respc(20), respc(2), {255,255,255,255})
      if isCursorInBox(respc(10)+(k-1)*respc(140), screenY-renderData.panelH+respc(10), respc(130), renderData.panelH-respc(20)) then
        activeDirectX = "savedHoverFrame"..k
      end
    end
  end
  if activeDirectX ~= lastActiveDirectX and activeDirectX then
		playSound("files/sounds/hover.mp3")
	end
end


function clickHandle(button, state)
  if button == "left" and state == "down" then
    if renderData.rbsPanelState then
      -- // Icons click
      for k, v in pairs(buttonTable) do
        if isCursorInBox(respc(10)+(k-1)*respc(40), screenY-renderData.panelH-respc(30), respc(30), respc(30)) then
          if renderData.selectedObjIndex == 0 then
            if v[1] == "exit" then
              exitEditor()
            elseif v[1] == "home" then
              renderData.pageIndex = v[1]
              selectedTable = objectList
              loadingLastTick = getTickCount()
              renderData.notificationText = "Kezdőlap - Válassz egy útzárat!"
              playSound("files/sounds/bubble.mp3")
            elseif v[1] == "save" then
              renderData.pageIndex = v[1]
              selectedTable = {}
              loadingLastTick = getTickCount()
              renderData.notificationText = "Létrehozott útzárak - Kattints a szerkeszteni kívánt útzárra!"
              playSound("files/sounds/bubble.mp3")
            elseif v[1] == "favorites" then
              renderData.pageIndex = v[1]
              selectedTable = favoriteTable
              loadingLastTick = getTickCount()
              renderData.notificationText = "Kedvenc útzárak - Válassz egy útzárat!"
              playSound("files/sounds/bubble.mp3")
            end
          end
        end
      end
      if renderData.pageIndex ~= "save" then
        for k, v in pairs(selectedTable) do
          if isCursorInBox(respc(15)+(k-1)*respc(140), screenY-renderData.panelH+respc(15), respc(15), respc(15)) then
            if not v.favorite then
              v.favorite = true
              loadingLastTick = getTickCount()
              renderData.notificationText = "Sikeresen elhelyezted a kedvencek között az útzárat!"
              playSound("files/sounds/accept.mp3")
              table.insert(favoriteTable, v)
            else
              if renderData.pageIndex == "favorites" then
                v.favorite = false
                playSound("files/sounds/delete.mp3")
                loadingLastTick = getTickCount()
                renderData.notificationText = "Sikeresen kitörölted a kedvencek közül az útzárat!"
                for favK, favV in pairs(favoriteTable) do
                  if favK == k then
                    table.remove(favoriteTable, k)
                  end
                end
              end
            end
          elseif isCursorInBox(respc(10)+(k-1)*respc(140), screenY-renderData.panelH+respc(10), respc(130), renderData.panelH-respc(20)) then
            if renderData.selectedObjIndex == 0 then
              -- // object select
              renderData.selectedObjIndex = k
              loadingLastTick = getTickCount()
              renderData.notificationText = "Az útzár lehelyezéséhez kattints! // Az útzár forgatásához használd a görgőt! // A gyorsabb forgatáshoz használd a bal 'SHIFT' billentyűt!"
              playSound("files/sounds/accept.mp3")

              --// delete if it is already exist
              if isElement(createdObject) then
                destroyElement(createdObject)
                toggleEditor(false)
              end
              -- // create our basic object
              createdObject = createObject(v.objID, 0,0,0)
              setElementCollisionsEnabled(createdObject, false)

              -- // save our datas if they needed to save it to table //
              saveObjectID = v.objID
              saveObjectName = v.name
            end
          end
        end
        -- // Click to apply the Object on its place
        if renderData.selectedObjIndex > 0 and not isCursorWithinMenuPanel() then
          renderData.selectedObjIndex = 0
          editorMenu = {
          	{"move", "Mozgatás"},
          	{"rotate", "Forgatás"},
          	{"delete", "Törlés"},
          	{"save", "Mentés"},
          }
          toggleEditor(createdObject)
          loadingLastTick = getTickCount()
          renderData.notificationText = "Sikeresen lehelyezted az útzárat!"
          playSound("files/sounds/accept.mp3")
        end
      else
        -- // Save panel click handle
        for k, v in pairs(saveTable) do
          if isCursorInBox(respc(15)+(k-1)*respc(140), screenY-renderData.panelH+respc(15), respc(15), respc(15)) then -- // delete saving icon
            if k > 0 then
              if not isElement(createdObject) then
                loadingLastTick = getTickCount()
                renderData.notificationText = "Sikeresen kitörölted az útzárat!"
                triggerServerEvent("deleteObjectServerSide", localPlayer, v.index)
                table.remove(saveTable, k)
                playSound("files/sounds/delete.mp3")
              else
                loadingLastTick = getTickCount()
                renderData.notificationText = "Előbb fejezd be az útzár elhelyezését!"
                playSound("files/sounds/delete.mp3")
              end
            end
          elseif isCursorInBox(respc(10)+(k-1)*respc(140), screenY-renderData.panelH+respc(10), respc(130), renderData.panelH-respc(20), respc(2)) then
            local pX, pY, pZ = getElementPosition(localPlayer)
            if getDistanceBetweenPoints3D(pX, pY, pZ, v.x,v.y,v.z) > 5 then
              loadingLastTick = getTickCount()
              renderData.notificationText = "Túl messze vagy az útzártól!"
              playSound("files/sounds/delete.mp3")
            else
              if not renderData.editingState then
                loadingLastTick = getTickCount()
                renderData.notificationText = "Sikeresen kiválasztottad az útzárat!"
                playSound("files/sounds/accept.mp3")

                --// debug it - it won't cause any problems
                if isElement(createdObject) then
                  destroyElement(createdObject)
                  toggleEditor(false)
                end
                triggerServerEvent("deleteObjectServerSide", localPlayer, v.index)
                saveState = true
                saveObjectIndex = v.index
                saveObjectKey = k
                saveObjectID = v.objID
                saveObjectName = v.name
                -- // create our dummy to edit
                createdObject = createObject(v.objID, v.x, v.y, v.z, v.rotX, v.rotY, v.rotZ)
                setElementCollisionsEnabled(createdObject, false)
                editorMenu = {
                	{"move", "Mozgatás"},
                	{"rotate", "Forgatás"},
                	{"save", "Mentés"},
                }
                toggleEditor(createdObject)
              else
                loadingLastTick = getTickCount()
                renderData.notificationText = "Előbb fejezd be az útzár elhelyezését!"
                playSound("files/sounds/delete.mp3")
              end
            end
          end
        end
      end
    end
  end
end

function showEditor()
  if exports.cosmo_groups:isPlayerHavePermission(localPlayer, "roadBlock") then
    if not renderData.rbsPanelState then
      exports.cosmo_hud:toggleHUD(false)
      showChat(false)
      addEventHandler("onClientRender", getRootElement(), drawMainMenu)
      addEventHandler("onClientClick", getRootElement(), clickHandle)
      --
      setTimer(function()
        renderData.rbsPanelState = true
        renderData.notificationText = "Válassz egy útzárat!"
        loadingLastTick = getTickCount()
        playSound("files/sounds/open.mp3")
      end, 500, 1)
    else
      exitEditor()
    end
  end
end
addCommandHandler("utzar", showEditor)
addCommandHandler("utzarak", showEditor)
addCommandHandler("rbs", showEditor)
addCommandHandler("roadblock", showEditor)
addCommandHandler("roadblocks", showEditor)
addCommandHandler("getrbs", showEditor)

addEventHandler("onClientKey", root,
    function(button)
      if renderData.selectedObjIndex > 0 and isElement(createdObject) then
          local rotX, rotY, rotZ = getElementRotation(createdObject)
          if button == "mouse_wheel_up" then
            if not getKeyState("lshift") then
              setElementRotation(createdObject, rotX, rotY, rotZ+1)
            else
              setElementRotation(createdObject, rotX, rotY, rotZ+5)
            end
          elseif button == "mouse_wheel_down" then
            -- // Left shift = speed up the rotation
            if not getKeyState("lshift") then
              setElementRotation(createdObject, rotX, rotY, rotZ-1)
            else
              setElementRotation(createdObject, rotX, rotY, rotZ-5)
            end
          end
      end
    end
)



function exitEditor()
  renderData = {
    panelW = screenX,
    panelH = respc(150),
    rbsPanelState = false,
    notificationText = "",
    pageIndex = "home",
    selectedObjIndex = 0,
  }
  loadingLastTick = getTickCount()
--  showCursor(false)
  playSound("files/sounds/open.mp3")
  setTimer(function()
    removeEventHandler("onClientRender", getRootElement(), drawMainMenu)
    removeEventHandler("onClientClick", getRootElement(), clickHandle)
    exports.cosmo_hud:toggleHUD(true)
    showChat(true)
  end, 800, 1)
end


function isCursorWithinMenuPanel()
  if isCursorInBox(0, screenY-renderData.panelH-respc(30), renderData.panelW, renderData.panelH+respc(30)) then
    return true
  else
    return false
  end
end



-- // Load rbs Models
local loadableModels = {
  {"files/models/rbs1",16188},
  {"files/models/rbs2",16035},
  {"files/models/rbs3",3330},
  {"files/models/rbs4",7470},
}


function changeObjectModel (filename,id)
	if id and filename then
		if fileExists(filename..".txd") then
			txd = engineLoadTXD( filename..".txd", true)
			engineImportTXD( txd, id )
		end
		if fileExists(filename..".dff") then
			dff = engineLoadDFF( filename..".dff", 0)
			engineReplaceModel( dff, id )
		end
		if fileExists(filename..".col") then
			col = engineLoadCOL( filename..".col" )
			engineReplaceCOL( col, id )
		end
	end
end

function startLoading()
	for k, v in ipairs(loadableModels) do
		if tostring(k) ~= tostring(v) then
			changeObjectModel(v[1],v[2],v[3])
		end
	end
end
startLoading()
