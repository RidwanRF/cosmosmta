local x, y = guiGetScreenSize()
oX, oY = 1280, 720
local font = dxCreateFont("files/myriadproregular.ttf", 20)
local kTick = 0
local price = 0
local pricemultiplier = 20
local panelShow = {}
local markerPos = {
	{1183.3728027344, -1311.8920898438, 13.573407173157,0,0},
	{-2639.5268554688, 636.25317382812, 14.453125,0,0},
}
local healthTexture = dxCreateTexture("files/health.png")

addEventHandler("onClientResourceStart",resourceRoot,function()
	for k,v in ipairs(markerPos) do
		markers = createMarker(v[1],v[2],v[3]-1,"cylinder",1,231,101,101,0)
		setElementDimension(markers, v[4])
		setElementInterior(markers, v[5])
		setElementData(markers, "healPoint", true)
	end
end)

function markersTexture()
	for k,v in ipairs(markerPos) do
		--dxDrawImage3D(v[1],v[2],v[3]+1,1,1,healthTexture,tocolor(255,255,255,255))
		if v[1] == 1183.3728027344  and v[2] == -1311.8920898438 and v[3] == 13.778328895569 then
			for i = 1, 5 do
				dxDrawOctagon3D(v[1],v[2],v[3]-0.9+(i*0.1),1,2, tocolor(255,101,101,100))
			end
		else
			for i = 1, 5 do
				dxDrawOctagon3D(v[1],v[2],v[3]-1.1+(i*0.1),1,2, tocolor(255,101,101,100))
			end
		end
	end
end
addEventHandler("onClientRender",root,markersTexture)

function mainRender()
	if panelShow == true then
		if getElementHealth(localPlayer) < 100  then
			price = math.floor((100-getElementHealth(localPlayer))*pricemultiplier)
		elseif getElementData(localPlayer,"bloodLevel") < 100 then
			price = math.floor((100-getElementData(localPlayer,"bloodLevel"))*pricemultiplier)
		end
		roundedRectangle(500/oX*x,300/oY*y,300/oX*x,100/oY*y,tocolor(20,20,20,240))
		roundedRectangle(500/oX*x,300/oY*y,100/oX*x,100/oY*y,tocolor(40,40,40,240))
		roundedBorder(500/oX*x,300/oY*y,300/oX*x,100/oY*y,tocolor(0,0,0,255))
		dxDrawImage(512.5/oX*x,310/oY*y,75/oX*x,75/oY*y,"files/health.png",0,0,0,tocolor(255,255,255,255))
		if getElementData(localPlayer,"char.Money") >= price then
			dxDrawText("A gyógyítás ára:\n#87D37C"..formatMoney(price).."$", 1380/oX*x,650/oY*y,20/oX*x,20/oY*y, tocolor(255,255,255), 0.45/oX*x, font, "center", "center",false,false,false,true)
		elseif getElementData(localPlayer,"char.Money") < price then
			dxDrawText("A gyógyítás ára:\n#E76565"..formatMoney(price).."$", 1380/oX*x,650/oY*y,20/oX*x,20/oY*y, tocolor(255,255,255), 0.45/oX*x, font, "center", "center",false,false,false,true)
		end
		if isInSlot(605/oX*x,375/oY*y,190/oX*x,20/oY*y) then
			roundedRectangle(605/oX*x,375/oY*y,190/oX*x,20/oY*y,tocolor(30,30,30,240))
			if getElementData(localPlayer,"char.Money") >= price then
				dxDrawText("Gyógyítás", 1380/oX*x,750/oY*y,20/oX*x,20/oY*y, tocolor(135,211,124), 0.45/oX*x, font, "center", "center",false,false,false,true)
			elseif getElementData(localPlayer,"char.Money") < price then
				dxDrawText("Gyógyítás", 1380/oX*x,750/oY*y,20/oX*x,20/oY*y, tocolor(231,101,101), 0.45/oX*x, font, "center", "center",false,false,false,true)
			end
			if getKeyState("mouse1") and kTick+500 < getTickCount() then
				if getElementData(localPlayer,"char.Money") >= price then
					panelShow = false
					triggerServerEvent("healingPlayer",localPlayer,localPlayer,price)
					outputChatBox("#E76565[CosmoMTA - Medical]#FFFFFF Sikeresen elláttad magad (#87D37C"..formatMoney(price).."$#FFFFFF)",0,0,0,true)
				elseif getElementData(localPlayer,"char.Money") < price then
					outputChatBox("#E76565[CosmoMTA - Medical]#FFFFFF Nincs elegendő pénzed az ellátáshoz (#E76565"..formatMoney(price).."$#FFFFFF)",0,0,0,true)
					panelShow = false
				end
				kTick = getTickCount()
			end 
		else
			roundedRectangle(605/oX*x,375/oY*y,190/oX*x,20/oY*y,tocolor(40,40,40,240))
			dxDrawText("Gyógyítás", 1380/oX*x,750/oY*y,20/oX*x,20/oY*y, tocolor(255,255,255), 0.45/oX*x, font, "center", "center",false,false,false,true)
		end
	end
end
addEventHandler("onClientRender",root,mainRender)

addEventHandler("onClientMarkerHit",getRootElement(),function(hitPlayer,matchingDimension)
    if getElementData(source,"healPoint") then
        if hitPlayer == localPlayer and matchingDimension then
            if getElementHealth(localPlayer) < 100 or getElementData(localPlayer, "bloodLevel") < 100 or getElementData(localPlayer,"bulletDamages") == true or getElementData(localPlayer,"deathReason") == true or getElementData(localPlayer,"customDeath") == true then
                panelShow = true
            elseif getElementHealth(localPlayer) >= 100 then
                outputChatBox("#E76565[CosmoMTA - Medical]#FFFFFF Nincs szükséged gyógyításra!",0,0,0,true)
            end
        end
    end
end)
addEventHandler("onClientMarkerLeave",getRootElement(),function(hitPlayer,matchingDimension)
	if getElementData(source,"healPoint") then
		panelShow = false
	end
end)

function dxDrawImage3D( x, y, z, width, height, material, color, rotation, ... )
    return dxDrawMaterialLine3D( x, y, z, x, y, z - width, material, height, color or 0xFFFFFFFF, ... )
end

function roundedRectangle(x, y, w, h, bgColor, postGUI)
    if (x and y and w and h) then
        if (not borderColor) then
            borderColor = tocolor(0, 0, 0, 200);
        end
        if (not bgColor) then
            bgColor = borderColor;
        end
        dxDrawRectangle(x, y, w, h, bgColor, postGUI);
        dxDrawRectangle(x + 2, y - 1, w - 4, 1, bgColor, postGUI); -- top
        dxDrawRectangle(x + 2, y + h, w - 4, 1, bgColor, postGUI); -- bottom
        dxDrawRectangle(x - 1, y + 2, 1, h - 4, bgColor, postGUI); -- left
        dxDrawRectangle(x + w, y + 2, 1, h - 4, bgColor, postGUI); -- right
    end
end

function roundedBorder(x, y, w, h, borderColor, postGUI)
    if (x and y and w and h) then
        if (not borderColor) then
            borderColor = tocolor(255, 255, 255, 230)
        end
        dxDrawRectangle(x - 1, y + 1, 1, h - 2, borderColor, postGUI); -- left
        dxDrawRectangle(x + w, y + 1, 1, h - 2, borderColor, postGUI); -- right
        dxDrawRectangle(x + 1, y - 1, w - 2, 1, borderColor, postGUI); -- top
        dxDrawRectangle(x + 1, y + h, w - 2, 1, borderColor, postGUI); -- bottom
        dxDrawRectangle(x, y, 1, 1, borderColor, postGUI);
        dxDrawRectangle(x + w - 1, y, 1, 1, borderColor, postGUI);
        dxDrawRectangle(x, y + h - 1, 1, 1, borderColor, postGUI);
        dxDrawRectangle(x + w - 1, y + h - 1, 1, 1, borderColor, postGUI);
    end
end

function isInSlot(xS,yS,wS,hS)
	if(isCursorShowing()) then
		XY = {guiGetScreenSize()}
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*XY[1], cursorY*XY[2]
		if(isInBox(xS,yS,wS,hS, cursorX, cursorY)) then
			return true
		else
			return false
		end
	end	
end

function isInBox(dX, dY, dSZ, dM, eX, eY)
	if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
		return true
	else
		return false
	end
end

function formatMoney(amount)
    amount = tonumber(amount);
    if not amount then 
        return 0;
    end
	local left,num,right = string.match(tostring(amount),'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

function dxDrawOctagon3D(x, y, z, radius, width, color)
	if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then
		return false
	end

	local radius = radius or 1
	local radius2 = radius/math.sqrt(2)
	local width = width or 1
	local color = color or tocolor(255,255,255,150)

	point = {}

		for i=1,8 do
			point[i] = {}
		end

		point[1].x = x
		point[1].y = y-radius
		point[2].x = x+radius2
		point[2].y = y-radius2
		point[3].x = x+radius
		point[3].y = y
		point[4].x = x+radius2
		point[4].y = y+radius2
		point[5].x = x
		point[5].y = y+radius
		point[6].x = x-radius2
		point[6].y = y+radius2
		point[7].x = x-radius
		point[7].y = y
		point[8].x = x-radius2
		point[8].y = y-radius2
		
	for i=1,8 do
		if i ~= 8 then
			x, y, z, x2, y2, z2 = point[i].x,point[i].y,z,point[i+1].x,point[i+1].y,z
		else
			x, y, z, x2, y2, z2 = point[i].x,point[i].y,z,point[1].x,point[1].y,z
		end
		dxDrawLine3D(x, y, z, x2, y2, z2, color, width)
	end
	return true
end