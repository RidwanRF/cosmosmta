if fileExists("codeC.lua") then
	fileDelete("codeC.lua")
end

local monitorSize = {guiGetScreenSize()}
local panelSize = {280 + 40, 70}
local panelX, panelY = monitorSize[1]/2-panelSize[1]/2, monitorSize[2]-panelSize[2]
local Font = dxCreateFont("files/myriadproregular.ttf", 9)
local Cars = { [416]=true, [418]=true, [596]=true, [597]=true, [598]=true, [599]=true, [427]=true, [490]=true, [523]=true }
local x,y = monitorSize[1]/2-panelSize[1]/2, monitorSize[2]-panelSize[2]
local sirenaMove 
local soundElementsOutside = { }
local soundElementsOutsideHorn = { }
local sirenTable = {
	{"siren", 65, 131, 215, "police_sirena.mp3","Rendőr sziréna"},
	{"siren", 65, 131, 215, "police_sirena_2.mp3","Rendőr sziréna"},
	{"siren", 210, 77, 87, "omsz_sirena.mp3","Mentős sziréna"},
	{"horn", 132,255,0, "horn.mp3","Kürt"},
}

vehicleLampColor = {}

local song = nil
local horn = nil
local isSirenPanelShowing = false 

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), function ()
	if isPedInVehicle(localPlayer) then 
		
		local veh =  getPedOccupiedVehicle(localPlayer)
		local seat =  getPedOccupiedVehicleSeat(localPlayer)
		if not Cars[getElementModel(veh)] then return end
		if seat >= 2 then return end
		
		if  Cars[getElementModel(getPedOccupiedVehicle(localPlayer))] then 
			removeEventHandler("onClientRender", root, showSirenPanel)
			addEventHandler("onClientRender", root, showSirenPanel)
			removeEventHandler("onClientClick", root, sirenClick)
			addEventHandler("onClientClick", root, sirenClick)			
			createGui("create")
			currentSiren = 0
			current = 0
			getPedOccupiedVehicle(localPlayer):setData("vehicle:siren", 0) 
			getPedOccupiedVehicle(localPlayer):setData("vehicle:horn", 0) 
		end
	end
end)

addEventHandler("onClientVehicleEnter", root, function (player, seat)
	if player ~= getLocalPlayer() then return end
	if not Cars[getElementModel(source)] then return end
	if seat >= 2 then return end
	
	if Cars[getElementModel(source)] then
		if seat < 2 then
			createGui("create")
			currentSiren = 0
			current = 0
		end
	end
end)

addEventHandler("onClientVehicleExit", root, function (player)
	if player ~= getLocalPlayer() then return end
	createGui("remove")
	currentSiren = 0
	current = 0
end)


function createGui(type)
	if type == "create" then 
		if not isElement(sirenaMove) then
			sirenaMove = guiCreateWindow( monitorSize[1]/2-panelSize[1]/2+30, monitorSize[2]-panelSize[2]-120,panelSize[1] -60, panelSize[2], "", false)
			guiSetAlpha(sirenaMove, 0)
			guiWindowSetSizable ( sirenaMove, false )
		end
	end
end

local currentSiren = 0
function sirenClick(button, state, clickX, clickY)
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle and isPedInVehicle(localPlayer) then	
		if isSirenPanelShowing or Cars[getElementModel(getPedOccupiedVehicle(localPlayer))] then
			local x, y = guiGetPosition (sirenaMove, false )
			if button == "left" and state == "down" then 
				for index, value in ipairs (sirenTable) do
					if dobozbaVan(x-20+5+index*(39)-17+51, y+panelSize[2]/2-7-10 -1, 24, 24, clickX, clickY) then 
						if vehicle:getData("vehicle:siren")  ~= index then 
						currentSiren = index
							if index ~= 4 then 
								vehicle:setData("vehicle:siren", currentSiren)
								triggerServerEvent("SirenSinc", localPlayer, currentSiren)
								--exports.dm_core:sendLocalMeAction(localPlayer," bekapcsolja a szirénát a műszerfalon.")
								vehicle:setData("vehicle:siren:sound", 1)
							else
								vehicle:setData("vehicle:siren:sound", 1)
								vehicle:setData("vehicle:horn", 4) 
								triggerServerEvent("SirenHorn", localPlayer, 4)
								setTimer(function ()
									vehicle:setData("vehicle:horn", 0) 
									triggerServerEvent("SirenHorn", localPlayer, 0)	
								end, 800, 1)
							end
						else
							triggerServerEvent("SirenSinc", localPlayer, 0)
							vehicle:setData("vehicle:siren", 0) 
					--		exports.dm_core:sendLocalMeAction(localPlayer," kikapcsolja a szirénát a műszerfalon.")
						end
					end
				end
				if isInSlot(x-20+5*(39)-17+57, y+panelSize[2]/2-7-10 -1 , 24, 24) then
					toggleFlashers()
				end
			end
		end
	end
end
addEventHandler("onClientClick", root, sirenClick)
			

function showSirenPanel()
	if isPedInVehicle(localPlayer)then
		local veh = getPedOccupiedVehicle(localPlayer)
		if isElement(veh) then
			if isElement(getElementData(veh, "sirenObject")) or Cars[getElementModel(veh)] then
				if not isSirenPanelShowing then
					isSirenPanelShowing = true

					createGui("create")
					currentSiren = 0
					current = 0
				end
			else
				if isSirenPanelShowing then
					isSirenPanelShowing = false

					createGui("remove")
					currentSiren = 0
					current = 0
				end
			end
			if isSirenPanelShowing then
				if not isPedInVehicle(localPlayer) then return end
				local x, y = guiGetPosition ( sirenaMove, false )
				--dxDrawRectangle(x, y , panelSize[1]-60, panelSize[2], tocolor(22,22,22, 255))
				--dxDrawBorder(x, y , panelSize[1]-60, panelSize[2], tocolor(0, 0, 0, 180),1)
				--dxDrawRectangle(x, y , panelSize[1]-60, 20, tocolor(35, 35, 35, 255))
				--dxDrawBorder(x, y , panelSize[1]-60, 20, tocolor(0, 0, 0, 180),1)
				--dxDrawText("#7cc576SimpleMTA - Sziréna",x+panelSize[1]/2-1, y+20/2+1, x+panelSize[1]/2-60-1, y+20/2+1, tocolor(0, 0, 0, 255),1, Font, "center", "center", false, false, false, true) 
				--dxDrawText("#f68934P:SA#ffffff - Sziréna",x+panelSize[1]/2, y+20/2, x+panelSize[1]/2-60, y+20/2, tocolor(255, 255, 255, 255),1, Font, "center", "center", false, false, false, true)
				dxDrawImage(x + 45, y + 2 , panelSize[1]-60 - 45, 55, "files/panel.png", 0, 0, 0, tocolor(255,255,255, 255)) 
				for index, value in ipairs (sirenTable) do 
					if isInSlot(x-20+5+index*(39)-17+51, y+panelSize[2]/2-7-10 -1, 24, 24) or veh:getData("vehicle:siren") == index or veh:getData("vehicle:horn") == index then 
						dxDrawImage(x-20+5+index*(39)-17-1+51, y+panelSize[2]/2-7+1-10 -1, 24, 24, "files/" ..value[1].. ".png", 0, 0, 0, tocolor(0,0,0, 255))
						dxDrawImage(x-20+5+index*(39)-17+51, y+panelSize[2]/2-7-10 -1, 24, 24, "files/" ..value[1].. ".png", 0, 0, 0, tocolor(value[2], value[3], value[4], 255))
					else
						dxDrawImage(x-20+5+index*(39)-17-1+51, y+panelSize[2]/2-7+1-10 -1, 24, 24, "files/" ..value[1].. ".png", 0, 0, 0, tocolor(0, 0, 0, 255))
						dxDrawImage(x-20+5+index*(39)-17+51, y+panelSize[2]/2-7-10 -1, 24, 24, "files/" ..value[1].. ".png", 0, 0, 0, tocolor(255, 255, 255, 255))
					end
				end
				dxDrawImage(x-20+5*(39)-17+57, y+panelSize[2]/2-7-10  , 24, 24, "files/fenyjelzo.png",0,0,0, tocolor(0,0,0,255))
				if isInSlot(x-20+5*(39)-17+57, y+panelSize[2]/2-7-10 -1 , 24, 24) and not getVehicleSirensOn(veh) then
					dxDrawImage(x-20+5*(39)-17+57, y+panelSize[2]/2-7-10 -1 , 24, 24, "files/fenyjelzo.png",0,0,0, tocolor(132,255,0,255))
				elseif not isInSlot(x-20+5*(39)-17+57, y+panelSize[2]/2-7-10 -1 , 24, 24) and not getVehicleSirensOn(veh) then
					dxDrawImage(x-20+5*(39)-17+57, y+panelSize[2]/2-7-10 -1 , 24, 24, "files/fenyjelzo.png",0,0,0, tocolor(255,255,255,255))
				end

				if getVehicleSirensOn(veh) then
					dxDrawImage(x-20+5*(39)-17+57, y+panelSize[2]/2-7-10 -1 , 24, 24, "files/fenyjelzo.png",0,0,0, tocolor(132,255,0,255))
				end
			end
		end
	end
end
addEventHandler("onClientRender", root, showSirenPanel)

addEventHandler ( "onClientElementDataChange", getRootElement(),
	function ( dataName )
		if getElementType ( source ) == "vehicle" and dataName == "vehicle:siren" then
			local newStation =  getElementData(source, "vehicle:siren") or 0
			if (isElementStreamedIn (source)) then
				if newStation ~= 0 then
					if (soundElementsOutside[source]) then
						stopSound(soundElementsOutside[source])
					end
					local x, y, z = getElementPosition(source)
					song = nil
					song = sirenTable[newStation][5]
					newSoundElement = playSound3D("files/"..song, x, y, z, true)
					soundElementsOutside[source] = newSoundElement
					setElementDimension(newSoundElement, getElementDimension(source))
					setElementDimension(newSoundElement, getElementDimension(source))
					setSoundMinDistance(soundElementsOutside[source], 40)
					setSoundMaxDistance(soundElementsOutside[source], 80)
					setSoundVolume(soundElementsOutside[source], getElementData(source, "vehicle:siren:sound"))

				else
					if (soundElementsOutside[source]) then
						stopSound(soundElementsOutside[source])
						soundElementsOutside[source] = nil
					end
				end

			end
		end
		if getElementType ( source ) == "vehicle" and dataName == "vehicle:horn" then
			local newhorn =  getElementData(source, "vehicle:horn") or 0
			if (isElementStreamedIn (source)) then
				if newhorn ~= 0 then
					if (soundElementsOutsideHorn[source]) then
					end
					local x, y, z = getElementPosition(source)
					horn = nil
					horn = sirenTable[newhorn][5]
					newSoundHorn = playSound3D("files/"..horn, x, y, z, false)
					soundElementsOutsideHorn[source] = newSoundHorn
					setElementDimension(newSoundHorn, getElementDimension(source))
					setElementDimension(newSoundHorn, getElementDimension(source))
					setSoundMinDistance(soundElementsOutsideHorn[source], 60)
					setSoundMaxDistance(soundElementsOutsideHorn[source], 120)
					setSoundVolume(soundElementsOutsideHorn[source], getElementData(source, "vehicle:siren:sound"))
				end

			end
		end
	end 
)

addEventHandler("onClientElementDestroy", getRootElement(), function ()
	local siren = getElementData(source, "vehicle:siren") or 0
	if getElementType(source) == "vehicle" and siren ~= 0 then
		if isElement(newSoundElement) then
			stopSound(newSoundElement)
		end
		setElementData(source, "vehicle:siren", 0)
	end
end)
addEventHandler("onClientElementDestroy", getRootElement(), function ()
	local horn = getElementData(source, "vehicle:horn") or 0
	if getElementType(source) == "vehicle" and horn ~= 0 then
		if isElement(newSoundHorn) then
			stopSound(newSoundHorn)
		end
		setElementData(source, "vehicle:horn", 0)
	end
end)

addEventHandler( "onClientPreRender", getRootElement(),
	function()
		if soundElementsOutside ~= nil then
			for element, sound in pairs(soundElementsOutside) do
				if (isElement(sound) and isElement(element)) then
					local x, y, z = getElementPosition(element)
					setElementPosition(sound, x, y, z)
					setElementInterior(sound, getElementInterior(element))
					getElementDimension(sound, getElementDimension(element))

				end
			end
		end
	end	
)

addEventHandler( "onClientElementStreamIn", getRootElement( ),
    function ( )
		spawnSound(source)
    end
)

function spawnSound(theVehicle)
	local newSoundElement = nil
    if getElementType( theVehicle ) == "vehicle" then
		local newStation = getElementData(theVehicle, "vehicle:siren") or 0
		if newStation ~= 0 then
			if (soundElementsOutside[source]) then
				stopSound(soundElementsOutside[source])
			end
			local x, y, z = getElementPosition(source)
			song = nil
			song = sirenTable[newStation][5]
			newSoundElement = playSound3D("files/"..song, x, y, z, true)
			soundElementsOutside[source] = newSoundElement
			setElementDimension(newSoundElement, getElementDimension(source))
			setElementDimension(newSoundElement, getElementDimension(source))
			setSoundMinDistance(soundElementsOutside[source], 40)
			setSoundMaxDistance(soundElementsOutside[source], 80)
			setSoundVolume(soundElementsOutside[source], getElementData(source, "vehicle:siren:sound"))

		end
    end
end

addEventHandler( "onClientElementStreamOut", getRootElement( ),
    function ( )
		local newSoundElement = nil
        if getElementType( source ) == "vehicle" then
			if (soundElementsOutside[source]) then
				stopSound(soundElementsOutside[source])
				soundElementsOutside[source] = nil
			end
        end
    end
)

function isInSlot(xS,yS,wS,hS)
	if(isCursorShowing()) then
		XY = {guiGetScreenSize()}
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*XY[1], cursorY*XY[2]
		if(dobozbaVan(xS,yS,wS,hS, cursorX, cursorY)) then
			return true
		else
			return false
		end
	end	
end

function dobozbaVan(dX, dY, dSZ, dM, eX, eY)
	if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
		return true
	else
		return false
	end
end

local flashingVehicles = { }

function bindKeys(res)	
	for key, value in ipairs(getElementsByType("vehicle")) do
		if isElementStreamedIn(value) then
			local flasherState = getElementData(value, "lspd:flashers")
			if flasherState and flasherState > 0 then
				flashingVehicles[value] = true
			end
		end
	end
end
addEventHandler("onClientResourceStart", getResourceRootElement(), bindKeys)

function toggleFlashers()
	local theVehicle = getPedOccupiedVehicle(getLocalPlayer())
	if (theVehicle) and getPedOccupiedVehicleSeat(localPlayer) < 2  then
		if Cars[getElementModel(theVehicle)] or isElement(getElementData(theVehicle, "sirenObject")) then
			triggerServerEvent("lspd:toggleFlashers", localPlayer , theVehicle)
			triggerServerEvent("triggerTheLPSDSirens", localPlayer, localPlayer)
		end
	end
end

function streamIn()
	if getElementType( source ) == "vehicle" and getElementData( source, "lspd:flashers" ) then
		local flasherState = getElementData(source, "lspd:flashers")
		if flasherState and flasherState > 0 then
			flashingVehicles[source] = true
		end
	end
end
addEventHandler("onClientElementStreamIn", getRootElement(), streamIn)

function streamOut()
	if getElementType( source ) == "vehicle" then
		flashingVehicles[source] = nil
	end
end
addEventHandler("onClientElementStreamOut", getRootElement(), streamOut)

function updateSirens( name )
	if name == "lspd:flashers" and isElementStreamedIn( source ) and getElementType( source ) == "vehicle" then
		local flasherState = getElementData(source, "lspd:flashers")
		if flasherState and flasherState > 0 then
			flashingVehicles[source] = true
		else
			flashingVehicles[source] = false
		end
	end
end
addEventHandler("onClientElementDataChange", getRootElement(), updateSirens)

function doFlashes()
	for veh in pairs(flashingVehicles) do
		if not (isElement(veh)) then
			flashingVehicles[veh] = nil
		else
			local flasherState = getElementData(veh, "lspd:flashers")
			if flasherState and flasherState == 0 then
				flashingVehicles[veh] = nil
				setVehicleHeadLightColor(veh, 255, 255, 255)
				setVehicleLightState(veh, 0, 0)
				setVehicleLightState(veh, 1, 0)
				setVehicleLightState(veh, 2, 0)
				setVehicleLightState(veh, 3, 0)
			else
				local state = getVehicleLightState(veh, 0)
				if flasherState == 2 then
					setVehicleHeadLightColor(veh, 128, 64, 0)
				else
					if (state==0) then
						setVehicleHeadLightColor(veh, 0, 0, 255)
					else
						setVehicleHeadLightColor(veh, 255, 0, 0)
					end
				end
				setVehicleLightState(veh, 0, 1-state)
				setVehicleLightState(veh, 1, state)
				setVehicleLightState(veh, 2, 1-state)
				setVehicleLightState(veh, 3, state)
			end
		end		
	end
end
setTimer(doFlashes, 250, 0)

function dxDrawBorder( x, y, width, height, color, _width, postGUI )
	_width = _width or 1
	dxDrawLine ( x, y, x+width, y, color, _width, postGUI ) -- Top
	dxDrawLine ( x, y, x, y+height, color, _width, postGUI ) -- Left
	dxDrawLine ( x, y+height, x+width, y+height, color, _width, postGUI ) -- Bottom
	return dxDrawLine ( x+width, y, x+width, y+height, color, _width, postGUI ) -- Right
end

addEventHandler("onVehicleEnter", root,function(thePlayer)
	triggerServerEvent("createLPSDSirens", localPlayer, localPlayer)
end)

function tooltip( text, text2 )
	local x,y = getCursorPosition( )
	local x,y = x * monitorSize[1], y * monitorSize[2]
	text = tostring( text )
	if text2 then
		text2 = tostring( text2 )
	end

	if text == text2 then
		text2 = nil
	end

	local width = dxGetTextWidth(text,2,Font) - 10
	if text2 then
		width = math.max( width, dxGetTextWidth( text2, 1, Font ) - 10 )
		text = text .. "\n"..text2
	end
	local height = 8 * ( text2 and 5 or 3)
	x = math.max( 10, math.min( x, monitorSize[1] - width - 10 ) )
	y = math.max( 10, math.min( y, monitorSize[2] - height - 10 ) )
	dxDrawRectangle(x, y, width, height, tocolor(22,22,22,180), true);
	dxDrawText( text, x, y, x + width, y + height, tocolor(255,255,255,255), 1.0, Font, "center", "center", false, false, true,true)
end