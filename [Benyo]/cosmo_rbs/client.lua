local x, y = guiGetScreenSize()
local start = getTickCount()
local progress = ""
local tempX, tempY, tempZ, tempPRot = nil
local tempRot
local cObject
local objectID
local curr = -1
local showpanel = false
local font1small = dxCreateFont("sfpro.ttf",14)
local font2small = dxCreateFont("sfpro.ttf",22)
local screen = {guiGetScreenSize()}
local box = {500,400}
local canopen = false
local pos = {screen[1]/2 -box[1]/2,screen[2]/2 -box[2]/2}
function szar ()
    if isPedInVehicle(localPlayer) then
        canopen = false showpanel = false return end
    local playerDbid = getElementData(localPlayer,"acc.ID")
    if exports.cosmo_groups:isPlayerInGroup(localPlayer, 1) or exports.cosmo_groups:isPlayerInGroup(localPlayer, 4) or exports.cosmo_groups:isPlayerInGroup(localPlayer, 32) or exports.cosmo_groups:isPlayerInGroup(localPlayer, 33) or exports.cosmo_groups:isPlayerInGroup(localPlayer, 58) then
        local x,y,z = getElementPosition(localPlayer)
        local nearbyVehicles = getElementsWithinRange(x, y, z, 1, "vehicle")
		for i,v in ipairs(nearbyVehicles) do
            if getElementData(v,"vehicle.group") == 1 or getElementData(v,"vehicle.group") == 4 or getElementData(v,"vehicle.group") == 32 or getElementData(v,"vehicle.group") == 33 or getElementData(v,"vehicle.group") == 57 or getElementData(v,"vehicle.group") == 58 then
                if canopen then

        if showpanel then
            showpanel = false
        else
            showpanel = true
            start = getTickCount()-10000
            progress = "Linear"
        end
    end
end
end
end
end
bindKey("e","down",szar)

function inClose()
    if isPedInVehicle(localPlayer) then
        canopen = false showpanel = false return end
    local playerDbid = getElementData(localPlayer,"acc.ID")
    if exports.cosmo_groups:isPlayerInGroup(localPlayer, 1) or exports.cosmo_groups:isPlayerInGroup(localPlayer, 4) or exports.cosmo_groups:isPlayerInGroup(localPlayer, 32) or exports.cosmo_groups:isPlayerInGroup(localPlayer, 33) or exports.cosmo_groups:isPlayerInGroup(localPlayer, 58) then
        local x,y,z = getElementPosition(localPlayer)
        local nearbyVehicles = getElementsWithinRange(x, y, z, 1, "vehicle")
		for i,v in ipairs(nearbyVehicles) do
            if getElementData(v,"vehicle.group") == 1 or getElementData(v,"vehicle.group") == 4 or getElementData(v,"vehicle.group") == 32 or getElementData(v,"vehicle.group") == 33 or getElementData(v,"vehicle.group") == 57 or getElementData(v,"vehicle.group") == 58 then
                local px,py,pz = getElementPosition(v)
                if getDistanceBetweenPoints3D(x,y,z,px,py,pz) < 4 then
                    if  getElementModel(v) ==596 or getElementModel(v) ==597 or getElementModel(v) == 598 then 
                     local panelH = 300
                        dxDrawRectangle(pos[1]+100,pos[2]+550,box[1]-200,box[2]-360,tocolor(23,23,23,255)) -- Háttér
                        dxDrawText("Nyomj 'E' betűt az RBS panel megnyitásához", pos[1]+500,pos[2]+1145,pos[1],pos[2],tocolor(255,255,255,255),0.7,font1small,"center","center")
               
                canopen = true
                else
                    canopen = false
                    showpanel = false
                end
            end
            end
        end
    end
end
addEventHandler("onClientRender",root,inClose)
addEventHandler("onClientRender", getRootElement(), function()
    if showpanel then
        if isPedInVehicle(localPlayer) then return end
        local startTime = (getTickCount()-start)/1200
        local panelH = interpolateBetween(10,0,0,300,0,0, startTime, progress)
        dxDrawRectangle(x/2-300/2, y/2-panelH/2-100, 300, panelH, tocolor(22,22,22,250))
        dxDrawRectangle(x/2-304/2, y/2-panelH/2-2-100, 304, panelH+146, tocolor(22,22,22,255))
        dxDrawRectangle(x/2-300/2, y/2-panelH/2-2-98, 300, 140, tocolor(0,0,0,100))
        --dxDrawText("RBS", pos[1]+515,pos[2]-45,pos[1],pos[2],tocolor(255,148,40,255),1,font2small,"center","center")
        --dxDrawImage(pos[1]+110,pos[2]-45,60,60,"logo.png",0,0,0,tocolor(255,148,40,255)) -- Logo

        if panelH == 300 then

            for k, v in ipairs(objects) do
                id = tonumber(v[1])
                if isInSlot(x/2-300/2, y/2-130+27*k, 300, 23) then
                    dxDrawRectangle(x/2-300/2, y/2-130+27*k, 300, 23, tocolor(255,148,40,255))
                    dxDrawImage(x/2-298/2, y/2-panelH/2-2-96, 296, 136,"files/"..id..".png",0,0,0,tocolor(255,255,255,255),true)
                else
                    dxDrawRectangle(x/2-300/2, y/2-130+27*k, 300, 23, tocolor(0,0,0,100))
                end
                dxDrawText(v[2], x/2, y/2-120+27*k, _, _, tocolor(255,255,255),0.8,font1small,"center","center")
            end
        end
    end
end)

addEventHandler("onClientClick", getRootElement(), function(button, state,X,Y)
    if showpanel then
        if button == "left" and state == "down" then
            for k, v in ipairs(objects) do
                if clickedBox(x/2-150/2, y/2-165+24*k, 150, 20,X,Y) then
                    if isElement(cObject) then destroyElement(cObject) end
                    curr = index
                    cObject = createObject(v[1], 0, 0, 0)
                    setElementAlpha(cObject, 150)
                    setElementInterior ( cObject, getElementInterior ( localPlayer ) )
                    setElementDimension ( cObject, getElementDimension ( localPlayer ) )
                    tempRot = v[3]
                    objectID = v[1]
                    bindKey("lalt", "down", createObjectServer)
                    updateRoadblockObject()
                    removeEventHandler("onClientPreRender",getRootElement(),updateRoadblockObject)
                    addEventHandler("onClientPreRender",getRootElement(),updateRoadblockObject)
                end
            end
        end
    end
end)


function createObjectServer()
	triggerServerEvent("createObjectToServer", localPlayer, localPlayer, objectID, tempX, tempY, tempZ, tempPRot)
	if (isElement(cObject)) then
		destroyElement(cObject)
		tempX, tempY, tempZ, tempPRot = nil
		tempRot = nil
		unbindKey ( "lalt", "down", createObjectServer)
		curr = -1
	end
	removeEventHandler("onClientPreRender",getRootElement(),updateRoadblockObject)
end

function isInSlot(xS,yS,wS,hS)
	if(isCursorShowing()) then
		XY = {guiGetScreenSize()}
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*XY[1], cursorY*XY[2]
		if(clickedBox(xS,yS,wS,hS, cursorX, cursorY)) then
			return true
		else
			return false
		end
	end	
end

function clickedBox(dX, dY, dSZ, dM, eX, eY)
	if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
		return true
	else
		return false
	end
end


function updateRoadblockObject(key, keyState)
	if (isElement(cObject)) then
		local distance = 3
		local px, py, pz = getElementPosition ( localPlayer )
		local rz = getPedRotation ( localPlayer )    

		local x = distance*math.cos((rz+90)*math.pi/180) 
		local y = distance*math.sin((rz+90)*math.pi/180)
		local b2 = 15 / math.cos(math.pi/180)
		local nx = px + x
		local ny = py + y
		local nz = pz - 0.5
		  
		local objrot =  rz + tempRot
		if (objrot > 360) then
			objrot = objrot-360
		end
		  
		setElementRotation ( cObject, 0, 0, objrot )
		moveObject ( cObject, 10, nx, ny, nz)
		
		tempX = nx
		tempY = ny
		tempZ = nz
		tempPRot = objrot
	end
end

function close()
    if showpanel == true then
        showpanel = false
    end
end
bindKey("backspace","down",close)