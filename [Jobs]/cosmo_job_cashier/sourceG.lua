color, r, g, b = "#ff9428", 255, 148, 40
prefix = color.."[CosmoMTA - Pénztáros]: #ffffff"

buyableItems = {
    {110, 140, 84000},
    {110, 140, 78000},
    {112, 80, 74000},
    {100, 50, 66000},
    {60, 180, 86000},
    {100, 130, 84000},
    {110, 130, 70000},
    {115, 150, 76000},
    {115, 180, 74000},
    {115, 100, 90000},
    {115, 200, 76000},
    {120, 120, 90000},
    {110, 180, 60000},
    {110, 100, 74000},
    {70, 130, 89000},
    {200, 170, 84000},
    {30, 170, 70000},
    {110, 85, 78000},
    {110, 110, 60000},
    {100, 130, 88000},
}

markerPositions = {
    {1445.1085205078, -1303.2149658203, 13.546875},

}

function genRandomBarcode()
    local barcode = ""

    for i = 1, math.random(8, 14) do 
        barcode = barcode .. math.random(0, 9)
    end

    return barcode
end

function isInSlot(x,y,w,h)
    if isCursorShowing() then 
        local cX,cY = getCursorPosition()
        if cX and cY then 
            local sx,sy = guiGetScreenSize()
            cX,cY = cX*sx,cY*sy 

            if cX > x and cX < x + w and cY > y and cY < y + h then 
                return true 
            else 
                return false 
            end
        else 
            return false 
        end
    else 
        return false
    end
end

function dxDrawShadowedText(text, x, y, w, h, color, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded)
	if not font then
		return
	end

    local textWithoutColors = string.gsub(text, "#......", "")

    dxDrawText(textWithoutColors, x - 1, y - 1, w - 1, h - 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
    dxDrawText(textWithoutColors, x - 1, y + 1, w - 1, h + 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
    dxDrawText(textWithoutColors, x + 1, y - 1, w + 1, h - 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
    dxDrawText(textWithoutColors, x + 1, y + 1, w + 1, h + 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
	dxDrawText(text, x, y, w, h, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
end


-----SmoothCamera
local sm = {}
sm.moov = 0
sm.object1,sm.object2 = nil,nil
 
local function removeCamHandler()
	if(sm.moov == 1)then
		sm.moov = 0
	end
end
 
local function camRender()
	if (sm.moov == 1) then
		local x1,y1,z1 = getElementPosition(sm.object1)
		local x2,y2,z2 = getElementPosition(sm.object2)
		setCameraMatrix(x1,y1,z1,x2,y2,z2)
	else
		removeEventHandler("onClientPreRender",root,camRender)
	end
end

function smoothMoveCamera(x1,y1,z1,x1t,y1t,z1t,x2,y2,z2,x2t,y2t,z2t,time)
	if(sm.moov == 1)then
		destroyElement(sm.object1)
		destroyElement(sm.object2)
		killTimer(timer1)
		killTimer(timer2)
		killTimer(timer3)
		removeEventHandler("onClientPreRender",root,camRender)
	end
	sm.object1 = createObject(1337,x1,y1,z1)
	sm.object2 = createObject(1337,x1t,y1t,z1t)
        setElementCollisionsEnabled (sm.object1,false) 
	setElementCollisionsEnabled (sm.object2,false) 
	setElementAlpha(sm.object1,0)
	setElementAlpha(sm.object2,0)
	setObjectScale(sm.object1,0.01)
	setObjectScale(sm.object2,0.01)
	moveObject(sm.object1,time,x2,y2,z2,0,0,0,"InOutQuad")
	moveObject(sm.object2,time,x2t,y2t,z2t,0,0,0,"InOutQuad")
	sm.moov = 1
	timer1 = setTimer(removeCamHandler,time,1)
	timer2 = setTimer(destroyElement,time,1,sm.object1)
	timer3 = setTimer(destroyElement,time,1,sm.object2)
	addEventHandler("onClientPreRender",root,camRender)
	return true
end