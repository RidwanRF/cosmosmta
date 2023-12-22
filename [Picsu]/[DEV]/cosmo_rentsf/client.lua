local sX, sY = guiGetScreenSize()
width, height = 442, 246
left, top = (sX / 2 - width / 2), (sY / 2 - height / 2)

local startX, startY = (sX-400)/2, (sY-237)/2
local kivalasztotJarmu = nil

showCarRent = false
kivalasztopanelnyitva = false

local carRentPed = createPed(29, -2596.3466796875, 581.59375, 14.453125)
setPedRotation(carRentPed, 0)
setElementFrozen(carRentPed, true)
setElementData(carRentPed, "invulnerable", true)
setElementData(carRentPed, "visibleName", "Teddy")
setElementData(carRentPed, "pedNameType", "Jármű Bérlés")
setElementData(carRentPed, "sanfierro.carrentped", true)


local redcircle = dxCreateTexture("fs/stripe.png")

x,y,z = 1507.66479, -1748.73694, 13.54688

size = 5


addEventHandler("onClientRender", root, function()
	--kocak = dxDrawMaterialLine3D(x+size+2, y+size, z-0.95, x-size-2, y-size, z-0.95, redcircle, size,tocolor(255, 255, 255, 255), x+2, y, z)
	
	--kocak = dxDrawMaterialLine3D(1507.84692-0.3, -1752.47925, 13.54688-0.95, 1507.84692-0.3, -1745.05432+1, 13.54688-0.95, redcircle, size,tocolor(255, 255, 255, 255), x, y, z+90) --JÓÓÓÓ
	
	
	
	--kocka = dxDrawMaterialLine3D(2441.20996, -2101.7, 12.57, 2429.94873, -2101.73486, 12.57, redcircle, 3.5, -1, 2470, -2101.7, 90)
end)

function clickcarRentPedPedSF(button, state, absX, absY, wx, wy, wz, element)
	if element and getElementType(element) == "ped" and state=="down" and getElementData(element, "sanfierro.carrentped") then
		local x, y, z = getElementPosition(getLocalPlayer())
		if getDistanceBetweenPoints3D(x, y, z, wx, wy, wz)<=4 then
			if not getElementData(localPlayer,"rent.hasBereltJarmu") then
				showCarRentPanel()
			else
				print("Már van")
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), clickcarRentPedPedSF, true)

function showCarRentPanel()
    if showCarRent == false then
		showCarRent = true
		showChat(false)
	end
end

local font1 = dxCreateFont("fs/SARP.ttf", 15)
local font2 = dxCreateFont("fs/Roboto.ttf", 12)
local font3 = dxCreateFont("fs/Roboto.ttf", 11.5)

--setElementData(localPlayer,"rent.hasBereltJarmu",false)

function renderCarRent()
	if showCarRent then
		dxDrawRectangle(startX, startY, 400, 237, tocolor( 22, 22, 22, 255 )) -- alap	
		dxDrawRectangle(startX+4, startY+4, 392, 25, tocolor( 50, 50, 50, 255 )) -- Fejléc
		
		
		dxDrawText("San Fierro Járműbérlő", startX+4, startY+4, startX+30+240+140, startY+3+25, tocolor(255, 255, 255, 255), 1, font1, "center", "center")
		
		if rajtvan(startX+376, startY+4, 20, 25) then
			dxDrawText("X", startX+376, startY+4, startX+30+240+130-2, startY+3+25, tocolor(220, 73, 73, 255), 1, font1, "center", "center")
		else	
			dxDrawText("X", startX+376, startY+4, startX+30+240+130-2, startY+3+25, tocolor(220, 73, 73, 200), 1, font1, "center", "center")
		end	
		
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		dxDrawRectangle(startX+4, startY+33, 250-40, 25, tocolor( 50, 50, 50, 255 )) -- Auto 1
		dxDrawRectangle(startX+4+250+4-40, startY+33, 34+40, 25, tocolor( 50, 50, 50, 255 )) -- Auto 1 ár	
		if rajtvan(startX+296, startY+33, 100, 25) then
			dxDrawRectangle(startX+296, startY+33, 100, 25, tocolor( 124, 197, 118, 255 )) -- Auto 1 vásárlás
		else	
			dxDrawRectangle(startX+296, startY+33, 100, 25, tocolor( 124, 197, 118, 200 )) -- Auto 1 vásárlás
		end		
		dxDrawText("Seat Leon", startX+38, startY+33, startX+30+150, startY+3+58, tocolor(255, 255, 255, 255), 1, font2, "center", "center") -- Auto 1 szoveg (kocsinev)
		dxDrawText("1.000 #7cc576$", startX+4+250+4-40, startY+33, startX+4+250+4-40+80, startY+3+58, tocolor(255, 255, 255, 255), 1, font2, "center", "center",false, false, false, true) -- Auto 1 szoveg (Bérlés ára)
		dxDrawText("Kiválasztás", startX+296, startY+33, startX+4+250+4-40+80+97, startY+3+58, tocolor(50, 50, 50, 255), 1, font2, "center", "center") -- Auto kiválasztás
		
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		dxDrawRectangle(startX+4, startY+33+29, 250-40, 25, tocolor( 50, 50, 50, 255 )) -- Auto 2
		dxDrawRectangle(startX+4+250+4-40, startY+33+29, 34+40, 25, tocolor( 50, 50, 50, 255 )) -- Auto 2 ár	
		if rajtvan(startX+296, startY+33+29, 100, 25) then
			dxDrawRectangle(startX+296, startY+33+29, 100, 25, tocolor( 124, 197, 118, 255 )) -- Auto 2 vásárlás
		else	
			dxDrawRectangle(startX+296, startY+33+29, 100, 25, tocolor( 124, 197, 118, 200 )) -- Auto 2 vásárlás
		end			
		dxDrawText("Audi Sport Quattro '83", startX+38, startY+33+29, startX+30+150, startY+3+58+29, tocolor(255, 255, 255, 255), 1, font2, "center", "center") -- Auto 2 szoveg (kocsinev)
		dxDrawText("1.000 #7cc576$", startX+4+250+4-40, startY+33+29, startX+4+250+4-40+80, startY+3+58+29, tocolor(255, 255, 255, 255), 1, font2, "center", "center",false, false, false, true) -- Auto 2 szoveg (Bérlés ára)
		dxDrawText("Kiválasztás", startX+296, startY+33+29, startX+4+250+4-40+80+97, startY+3+58+29, tocolor(50, 50, 50, 255), 1, font2, "center", "center") -- Auto kiválasztás
		
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		dxDrawRectangle(startX+4, startY+33+29+29, 250-40, 25, tocolor( 50, 50, 50, 255 )) -- Auto 3
		dxDrawRectangle(startX+4+250+4-40, startY+33+29+29, 34+40, 25, tocolor( 50, 50, 50, 255 )) -- Auto 3 ár
		if rajtvan(startX+296, startY+33+29+29, 100, 25) then
			dxDrawRectangle(startX+296, startY+33+29+29, 100, 25, tocolor( 124, 197, 118, 255 )) -- Auto 3 vásárlás
		else
			dxDrawRectangle(startX+296, startY+33+29+29, 100, 25, tocolor( 124, 197, 118, 200 )) -- Auto 3 vásárlás	
		end	
		dxDrawText("Honda CR-X SiR '90", startX+38, startY+33+29+29, startX+30+150, startY+3+58+29+29, tocolor(255, 255, 255, 255), 1, font2, "center", "center") -- Auto 3 szoveg (kocsinev)
		dxDrawText("1.000 #7cc576$", startX+4+250+4-40, startY+33+29+29, startX+4+250+4-40+80, startY+3+58+29+29, tocolor(255, 255, 255, 255), 1, font2, "center", "center",false, false, false, true) -- Auto 3 szoveg (Bérlés ára)
		dxDrawText("Kiválasztás", startX+296, startY+33+29+29, startX+4+250+4-40+80+97, startY+3+58+29+29, tocolor(50, 50, 50, 255), 1, font2, "center", "center") -- Auto kiválasztás
		
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		dxDrawRectangle(startX+4, startY+33+29+29+29, 250-40, 25, tocolor( 50, 50, 50, 255 )) -- Auto 4
		dxDrawRectangle(startX+4+250+4-40, startY+33+29+29+29, 34+40, 25, tocolor( 50, 50, 50, 255 )) -- Auto 4 ár
		if rajtvan(startX+296, startY+33+29+29+29, 100, 25) then
			dxDrawRectangle(startX+296, startY+33+29+29+29, 100, 25, tocolor( 124, 197, 118, 255 )) -- Auto 4 vásárlás
		else
			dxDrawRectangle(startX+296, startY+33+29+29+29, 100, 25, tocolor( 124, 197, 118, 200 )) -- Auto 4 vásárlás
		end
		dxDrawText("Volkswagen Golf IV", startX+38, startY+33+29+29+29, startX+30+150, startY+3+58+29+29+29, tocolor(255, 255, 255, 255), 1, font2, "center", "center") -- Auto 4 szoveg (kocsinev)
		dxDrawText("1.000 #7cc576$", startX+4+250+4-40, startY+33+29+29+29, startX+4+250+4-40+80, startY+3+58+29+29+29, tocolor(255, 255, 255, 255), 1, font2, "center", "center",false, false, false, true) -- Auto 4 szoveg (Bérlés ára)
		dxDrawText("Kiválasztás", startX+296, startY+33+29+29+29, startX+4+250+4-40+80+97, startY+3+58+29+29+29, tocolor(50, 50, 50, 255), 1, font2, "center", "center") -- Auto kiválasztás
		
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		dxDrawRectangle(startX+4, startY+33+29+29+29+29, 250-40, 25, tocolor( 50, 50, 50, 255 )) -- Auto 5
		dxDrawRectangle(startX+4+250+4-40, startY+33+29+29+29+29, 34+40, 25, tocolor( 50, 50, 50, 255 )) -- Auto 5 ár
		if rajtvan(startX+296, startY+33+29+29+29+29, 100, 25) then
			dxDrawRectangle(startX+296, startY+33+29+29+29+29, 100, 25, tocolor( 124, 197, 118, 255 )) -- Auto 5 vásárlás
		else
			dxDrawRectangle(startX+296, startY+33+29+29+29+29, 100, 25, tocolor( 124, 197, 118, 200 )) -- Auto 5 vásárlás
		end
		dxDrawText("Audi 80", startX+38, startY+33+29+29+29+29, startX+30+150, startY+3+58+29+29+29+29, tocolor(255, 255, 255, 255), 1, font2, "center", "center") -- Auto 5 szoveg (kocsinev)
		dxDrawText("1.000 #7cc576$", startX+4+250+4-40, startY+33+29+29+29+29, startX+4+250+4-40+80, startY+3+58+29+29+29+29, tocolor(255, 255, 255, 255), 1, font2, "center", "center",false, false, false, true) -- Auto 5 szoveg (Bérlés ára)
		dxDrawText("Kiválasztás", startX+296, startY+33+29+29+29+29, startX+4+250+4-40+80+97, startY+3+58+29+29+29+29, tocolor(50, 50, 50, 255), 1, font2, "center", "center") -- Auto kiválasztás
		
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		dxDrawRectangle(startX+4, startY+33+29+29+29+29+29, 250-40, 25, tocolor( 50, 50, 50, 255 )) -- Auto 6
		dxDrawRectangle(startX+4+250+4-40, startY+33+29+29+29+29+29, 34+40, 25, tocolor( 50, 50, 50, 255 )) -- Auto 6 ár
		if rajtvan(startX+296, startY+33+29+29+29+29+29, 100, 25) then
			dxDrawRectangle(startX+296, startY+33+29+29+29+29+29, 100, 25, tocolor( 124, 197, 118, 255 )) -- Auto 6 vásárlás
		else
			dxDrawRectangle(startX+296, startY+33+29+29+29+29+29, 100, 25, tocolor( 124, 197, 118, 200 )) -- Auto 6 vásárlás
		end
		dxDrawText("Honda Click", startX+38, startY+33+29+29+29+29+29, startX+30+150, startY+3+58+29+29+29+29+29, tocolor(255, 255, 255, 255), 1, font2, "center", "center") -- Auto 6 szoveg (kocsinev)
		dxDrawText("1.000 #7cc576$", startX+4+250+4-40, startY+33+29+29+29+29+29, startX+4+250+4-40+80, startY+3+58+29+29+29+29+29, tocolor(255, 255, 255, 255), 1, font2, "center", "center",false, false, false, true) -- Auto 6 szoveg (Bérlés ára)
		dxDrawText("Kiválasztás", startX+296, startY+33+29+29+29+29+29, startX+4+250+4-40+80+97, startY+3+58+29+29+29+29+29, tocolor(50, 50, 50, 255), 1, font2, "center", "center") -- Auto kiválasztás
		
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		dxDrawRectangle(startX+4, startY+33+29+29+29+29+29+29, 250-40, 25, tocolor( 50, 50, 50, 255 )) -- Auto 7
		dxDrawRectangle(startX+4+250+4-40, startY+33+29+29+29+29+29+29, 34+40, 25, tocolor( 50, 50, 50, 255 )) -- Auto 7 ár
		if rajtvan(startX+296, startY+33+29+29+29+29+29+29, 100, 25) then
			dxDrawRectangle(startX+296, startY+33+29+29+29+29+29+29, 100, 25, tocolor( 124, 197, 118, 255 )) -- Auto 7 vásárlás
		else
			dxDrawRectangle(startX+296, startY+33+29+29+29+29+29+29, 100, 25, tocolor( 124, 197, 118, 200 )) -- Auto 7 vásárlás
		end
		dxDrawText("Volkswagen Beetle 1963", startX+38, startY+33+29+29+29+29+29+29, startX+30+150, startY+3+58+29+29+29+29+29+29, tocolor(255, 255, 255, 255), 1, font2, "center", "center") -- Auto 7 szoveg (kocsinev)
		dxDrawText("1.000 #7cc576$", startX+4+250+4-40, startY+33+29+29+29+29+29+29, startX+4+250+4-40+80, startY+3+58+29+29+29+29+29+29, tocolor(255, 255, 255, 255), 1, font2, "center", "center",false, false, false, true) -- Auto 7 szoveg (Bérlés ára)
		dxDrawText("Kiválasztás", startX+296, startY+33+29+29+29+29+29+29, startX+4+250+4-40+80+97, startY+3+58+29+29+29+29+29+29, tocolor(50, 50, 50, 255), 1, font2, "center", "center") -- Auto kiválasztás
		
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	end								
end
addEventHandler("onClientRender", getRootElement(), renderCarRent)

function kivalasztotRender()

	kivalasztopanelnyitva = true
	
	dxDrawRectangle(startX, startY, 400, 237, tocolor( 22, 22, 22, 0 )) -- alap	
	
	dxDrawText("Biztosan ki szeretnéd bérelni a járművet?", startX, startY+237+4, startX+30+240+140, startY+3+25+230, tocolor(0, 0, 0, 255), 1, font2, "center", "center")
	dxDrawText("Biztosan ki szeretnéd bérelni a járművet?", startX, startY+237+4, startX+30+240+140, startY+3+25+230, tocolor(255, 255, 255, 255), 1, font2, "center", "center")
	
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	dxDrawRectangle(startX, startY+237+4+23-2, 198, 20+4, tocolor( 0, 0, 0, 255 )) -- Jóváhagyás hatter	
	if rajtvan(startX+2, startY+237+4+23, 194, 20) then
		dxDrawRectangle(startX+2, startY+237+4+23, 194, 20, tocolor( 50, 179, 239, 255 )) -- Jóváhagyás
	else
		dxDrawRectangle(startX+2, startY+237+4+23, 194, 20, tocolor( 50, 179, 239, 200 )) -- Jóváhagyás
	end
	dxDrawText("Jóváhagyás", startX+2, startY+237+4+23, startX+200, startY+3+25+230+25, tocolor(50, 50, 50, 255), 1, font3, "center", "center")
	
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	dxDrawRectangle(startX+202, startY+237+27-2, 198, 24, tocolor( 0, 0, 0, 255 )) -- Visszavonás hatter	
	if rajtvan(startX+204, startY+237+27, 194, 20) then
		dxDrawRectangle(startX+204, startY+237+27, 194, 20, tocolor( 255, 153, 51, 255 )) -- Visszavonás	
	else
		dxDrawRectangle(startX+204, startY+237+27, 194, 20, tocolor( 255, 153, 51, 200 )) -- Visszavonás	
	end
	dxDrawText("Visszavonás", startX+204, startY+237+27, startX+200+200, startY+3+25+230+25, tocolor(50, 50, 50, 255), 1, font3, "center", "center")
	
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
end

function clickHandler(button, state, x, y)
    if showCarRent then
		if button == "left" and state == "down" then
				if rajtvan(startX+296, startY+33, 100, 25) then --Jarmu 1
					--showCarRent = false
					--showChat(true)
					kivalasztotJarmu = 529
					print("asd")
					if not kivalasztopanelnyitva then
						addEventHandler("onClientRender", root, kivalasztotRender)
					else
						removeEventHandler("onClientRender", root, kivalasztotRender)
						kivalasztopanelnyitva = false
					end	
				elseif rajtvan(startX+296, startY+33+29, 100, 25) then --Jarmu 2
					kivalasztotJarmu = 602
					if not kivalasztopanelnyitva then
						addEventHandler("onClientRender", root, kivalasztotRender)
					else
						removeEventHandler("onClientRender", root, kivalasztotRender)
						kivalasztopanelnyitva = false
					end	
				elseif rajtvan(startX+296, startY+33+29+29, 100, 25) then --Jarmu 3
					kivalasztotJarmu = 542	-- honda geci autó
					if not kivalasztopanelnyitva then
						addEventHandler("onClientRender", root, kivalasztotRender)
					else
						removeEventHandler("onClientRender", root, kivalasztotRender)
						kivalasztopanelnyitva = false
					end	
				elseif rajtvan(startX+296, startY+33+29+29+29, 100, 25) then --Jarmu 4
					kivalasztotJarmu = 589 --golf 4
					if not kivalasztopanelnyitva then
						addEventHandler("onClientRender", root, kivalasztotRender)
					else
						removeEventHandler("onClientRender", root, kivalasztotRender)
						kivalasztopanelnyitva = false
					end	
				elseif rajtvan(startX+296, startY+33+29+29+29+29, 100, 25) then --Jarmu 5
					kivalasztotJarmu = 585	--audi 80
					if not kivalasztopanelnyitva then
						addEventHandler("onClientRender", root, kivalasztotRender)
					else
						removeEventHandler("onClientRender", root, kivalasztotRender)
						kivalasztopanelnyitva = false
					end				
				elseif rajtvan(startX+296, startY+33+29+29+29+29+29, 100, 25) then --Jarmu 6
					kivalasztotJarmu = 462	--robogó
					if not kivalasztopanelnyitva then
						addEventHandler("onClientRender", root, kivalasztotRender)
					else
						removeEventHandler("onClientRender", root, kivalasztotRender)
						kivalasztopanelnyitva = false
					end	
				elseif rajtvan(startX+296, startY+33+29+29+29+29+29+29, 100, 25) then --Jarmu 7
					kivalasztotJarmu = 474 --bogar		
					if not kivalasztopanelnyitva then
						addEventHandler("onClientRender", root, kivalasztotRender)
					else
						removeEventHandler("onClientRender", root, kivalasztotRender)
						kivalasztopanelnyitva = false
					end					
				elseif rajtvan(startX+376, startY+4, 20, 25) then
					showCarRent = false
					showChat(true)
					if kivalasztopanelnyitva then
						removeEventHandler("onClientRender", root, kivalasztotRender)
						kivalasztopanelnyitva = false
					end	
					
						--triggerServerEvent("createRentCarSF", localPlayer, localPlayer)
						--outputChatBox("#7cc576[Járműbérlő]: #ffffff A bérelt járműved 60 percen belül törölve lesz.",0,0,0,true)
						--showCarRent = false
						--showChat(true)				
						--setTimer(function() outputChatBox("#7cc576[Járműbérlő]: #ffffff A bérelt járműved 10 percen belül törölve lesz.",0,0,0,true) end, 50*60000, 1)			
						--setTimer(function() triggerServerEvent("destroyRentCar", localPlayer) end, 60*60000, 1)
					--else
						--exports.sarp_hud:showBox("Nincs elég pénzed a bérléshez.", "error")
					--end
				end		
		end
	end
end	
addEventHandler("onClientClick", root, clickHandler)

function clickHandler2(button, state, x, y)
	if kivalasztopanelnyitva then
		if button == "left" and state == "down" then
			if rajtvan(startX+2, startY+237+4+23, 194, 20) then
				print("sikeres bérlés")
				triggerServerEvent("createRentCarSF", localPlayer, localPlayer,kivalasztotJarmu)
				showCarRent = false
				showChat(true)
				kivalasztopanelnyitva = false
				removeEventHandler("onClientRender", root, kivalasztotRender)
				setElementData(localPlayer,"rent.hasBereltJarmu",true)
				
				--outputChatBox("#7cc576[Járműbérlő]: #ffffff A bérelt járműved 60 percen belül törölve lesz.",0,0,0,true)
				--setTimer(function() outputChatBox("#7cc576[Járműbérlő]: #ffffff A bérelt járműved 10 percen belül törölve lesz.",0,0,0,true) end, 50*60000, 1)
				--setTimer(function() triggerServerEvent("destroyRentCar", localPlayer) end, 60*60000, 1)				
				--setTimer(function() setElementData(localPlayer,"rent.hasBereltJarmu",false) end, 60*60000, 1)				
			elseif rajtvan(startX+204, startY+237+27, 194, 20) then
				print("Meggondolta magát")
				kivalasztopanelnyitva = false
				removeEventHandler("onClientRender", root, kivalasztotRender)
			end
		end
	end
end	
addEventHandler("onClientClick", root, clickHandler2)

addEventHandler("onClientPlayerVehicleExit", getRootElement(), function(vehicle, seat)
	if localPlayer and seat == 0 then
		if getElementData(vehicle,"rentCar") then
			if getElementData(vehicle,"vehicle.dbID") or 0 then
				--exports.cosmo_hud:showInfobox("warning","Kiszálltál a bérelt járművedből, 20 perced van hogy visszatérj hozzá, különben törlődni fog!")
				--outputChatBox("#7cc576[Járműbérlő]: #ffffff Kiszálltál a bérelt járművedből, 20 perced van hogy visszatérj hozzá, különben törlődni fog!",0,0,0,true)
				destroyTimer = setTimer(function()
					--exports.cosmo_hud:showInfobox("warning","A bérelt járműved törlődött, mert nem száltál vissza 20 percen belül.")
					setElementData(localPlayer,"rent.hasBereltJarmu",false)
					triggerServerEvent("destroyRentCar", localPlayer)
				end,(1000*60)*20, 1)
			end
		end
	end
end)

function rajtvan(startX, startY, endX, endY)
	if isCursorShowing() then
		cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*sX, cursorY*sY
			
		if cursorX >= startX and cursorX <= startX+endX and cursorY >= startY and cursorY <= startY+endY then
			return true
		else
			return false
		end
	else
		return false
	end
end
