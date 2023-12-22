local x, y = guiGetScreenSize()
oX, oY = 1280, 720

local font = dxCreateFont("files/font.ttf",14)

local mode = "off"

function setTextIsZeroMode(zMode)
	mode = zMode
end
addEvent("setTextIsZeroMode", true)
addEventHandler("setTextIsZeroMode", root, setTextIsZeroMode)

function zeroModeDraw()
	triggerServerEvent("getzerostate",localPlayer,localPlayer)
	if getElementData(localPlayer, "loggedIn") then
		if mode == "on" then
			--dxDrawRectangle(550/oX*x, 5/oY*y, 200/oX*x, 30/oY*y,tocolor(0,0,0,170))
	        dxDrawText("#DD5757".."ZÉRÓ TOLERANCIA", 1300/oX*x,12.5/oY*y,10/oX*x,30/oY*y, tocolor(255, 255, 255), 0.75/oX*x, font, "center", "center",false,false,false,true)
		end
	end
end
addEventHandler("onClientRender",root,zeroModeDraw)