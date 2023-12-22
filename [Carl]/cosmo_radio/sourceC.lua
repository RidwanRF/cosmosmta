local sx,sy = guiGetScreenSize()
local opensans = dxCreateFont("files/opensans.ttf", 12)

local show = false
local textShowing = false
setElementData(localPlayer, "char:check", false)

local designation = 1
local status = "Kikapcsolva"
local soundElementsOutside = { }
local musicTable = {
	{"https://icast.connectmedia.hu/5201/live.mp3", "Rádió 1"},
	{"https://icast.connectmedia.hu/5001/live.mp3", "Retro Rádió"},
	{"http://listen.radionomy.com/One-love-Hip-Hop-Radio", "One love Hip Hop Radio"},
	{"http://ais.rastamusic.com/rastamusic.mp3.m3u", "808 Live Reggaecast"},
	{"http://uk6.internet-radio.com:8213/listen.pls&t=.m3u", "Pigpen Radio"},
	{"http://sc-t40.1.fm:8075", "1.fm Absolute Top 40"},
	{"http://icast.connectmedia.hu/4738/mr2.mp3", "Petőfi Rádió"},
	{"https://www.internet-radio.com/servers/tools/playlistgenerator/?u=http://198.178.123.17:10922/listen.pls?sid=1&t=.m3u", "San Franciscos 70s Hits"},
	{"https://www.internet-radio.com/servers/tools/playlistgenerator/?u=http://uk2.internet-radio.com:8024/listen.pls&t=.m3u", "Dance UK"},
	{"https://www.internet-radio.com/servers/tools/playlistgenerator/?u=http://us4.internet-radio.com:8197/listen.pls&t=.m3u", "EZ Hits South Florida"},
	{"https://www.internet-radio.com/servers/tools/playlistgenerator/?u=http://us5.internet-radio.com:8267/listen.pls&t=.m3u", "Classic Rock Radio"},
}

addEventHandler("onClientPlayerVehicleEnter", getLocalPlayer(),

	function(theVehicle)
		setRadioChannel(0)

		radio = getElementData(theVehicle, "vehicle:radio") or 0

		setElementData(theVehicle, "vehicle:radio", radio)
		if radio > 0  then
			designation = radio
			setElementData(theVehicle, "vehicle:radio:status", 1)
			Image = 1
			triggerServerEvent("car:radio:sync", getLocalPlayer(), designation)
		else
			Image = "kikapcsolva"
			setElementData(theVehicle, "vehicle:radio:status", 0)
		end

		bindKey("r","down", createVehicleRadio)

	end

)

addEventHandler("onClientPlayerVehicleExit", getLocalPlayer(),

	function(theVehicle)
		show = false

		unbindKey("r","down", createVehicleRadio)

	end

)

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()) , function ()
	if isPedInVehicle(localPlayer) then
		local vehicle = getPedOccupiedVehicle(localPlayer)

		setRadioChannel(0)

		radio = getElementData(vehicle, "vehicle:radio") or 0
		setElementData(vehicle, "vehicle:radio:status", 0)
		Image = "kikapcsolva"

		setElementData(vehicle, "vehicle:radio", radio)

		bindKey("r","down", createVehicleRadio)
	end
end)
function createVehicleRadio ()
	--if  getPedOccupiedVehicleSeat(localPlayer) == 1  then
		local vehicle = getPedOccupiedVehicle(localPlayer)
		local radio = getElementData(vehicle, "vehicle:radio") or 0
		if not show  then
			show = true
			removeEventHandler("onClientRender", root, createRadioPanel)
			addEventHandler("onClientRender", root, createRadioPanel)
		elseif show then
			show = false
			removeEventHandler("onClientRender", root, createRadioPanel)
		end
	--end
end

function createRadioPanel()
	if not show then return end
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if isPedInVehicle(localPlayer) then
		local radio = getElementData(vehicle, "vehicle:radio") or 0
		local radioStatus = getElementData(vehicle, "vehicle:radio:status") or 0
		if radioStatus == 0 or radio == 0 then
			dxDrawImage(sx / 2 - 200, sy / 2 - 100, 400, 200, "files/radiobg.png")
			if isCursorOnBox(sx / 2 - 25, sy / 2 + 50, 40, 40) then
			  dxDrawImage(sx / 2 - 200, sy / 2 - 100, 400, 200, "files/onbutton.png", 0, 0, 0, tocolor(255, 255, 255, 255))
			else
			  dxDrawImage(sx / 2 - 200, sy / 2 - 100, 400, 200, "files/onbutton.png", 0, 0, 0, tocolor(102, 153, 204, 200))
			end
		else
			local newStation =  getElementData(vehicle, "vehicle:radio") or 0
			if newStation <= 1 then
				designation = 1
				setElementData(vehicle, "vehicle:radio", designation)
			end
			if newStation >= #musicTable then
				designation = 1
				setElementData(vehicle, "vehicle:radio", designation)
			end

			dxDrawImage(sx / 2 - 200, sy / 2 - 100, 400, 200, "files/radiobgon.png")
			if isCursorOnBox(sx / 2 - 25, sy / 2 + 50, 40, 40) then
			  dxDrawImage(sx / 2 - 200, sy / 2 - 100, 400, 200, "files/onbutton.png", 0, 0, 0, tocolor(102, 153, 204, 200))
			else
			  dxDrawImage(sx / 2 - 200, sy / 2 - 100, 400, 200, "files/onbutton.png", 0, 0, 0, tocolor(255, 255, 255, 255))
			end
			if isCursorOnBox(sx / 2 - 90, sy / 2 + 55, 25, 25) then
			  dxDrawImage(sx / 2 - 200, sy / 2 - 100, 400, 200, "files/l1.png", 0, 0, 0, tocolor(102, 153, 204, 255))
			else
			  dxDrawImage(sx / 2 - 200, sy / 2 - 100, 400, 200, "files/l1.png")
			end
			if isCursorOnBox(sx / 2 - 90 + 160, sy / 2 + 55, 25, 25) then
			  dxDrawImage(sx / 2 - 200, sy / 2 - 100, 400, 200, "files/r1.png", 0, 0, 0, tocolor(102, 153, 204, 255))
			else
			  dxDrawImage(sx / 2 - 200, sy / 2 - 100, 400, 200, "files/r1.png")
			end
			dxDrawImage(sx / 2 - 200, sy / 2 - 100, 400, 200, "files/speaker.png")
			if isCursorOnBox(sx / 2 - 50, sy / 2 + 20, 25, 25) then
			  dxDrawImage(sx / 2 - 200, sy / 2 - 100, 400, 200, "files/mute.png", 0, 0, 0, tocolor(102, 153, 204, 255))
			else
			  dxDrawImage(sx / 2 - 200, sy / 2 - 100, 400, 200, "files/mute.png")
			end

			local hangero = getElementData(vehicle, "vehicle:radio:volume") or 40
			if hangero < 0 then
				hangero = 0
			end
			if hangero > 100 then
				hangero = 100
			end

			dxDrawText(musicTable[newStation][2], sx / 2 - 200, sy / 2 - 100, sx / 2 - 200 + 400, sy / 2 - 100 + 200, tocolor(255, 255, 255, 255), 1, opensans, "center", "center", false, false, false, true)
			dxDrawImage(sx / 2 + 60, sy / 2 + 30, 107, 3, "files/sliderBG.png")
			dxDrawImage(sx / 2 + 60, sy / 2 + 30, hangero, 3, "files/sliderBG.png", 0, 0, 0, tocolor(102, 153, 204, 255))
			dxDrawImage(sx / 2 + 60 + hangero, sy / 2 + 28, 10, 6, "files/sliderC.png", 0, 0, 0, tocolor(255, 255, 255, 255))

			clientRenderFunc()
		end
	end
end

function clientRenderFunc()
    if(newSoundElement) then
    local bt = getSoundFFTData(newSoundElement,2048,257)
    if(not bt) then return end
        for i=1, 250 do
            bt[i] = math.sqrt(bt[i]) * 100 --scale it (sqrt to make low values more visible)
            dxDrawRectangle(sx / 2 - 195 + i * 1.585, sy / 2 - 90, 1, bt[i], tocolor(255, 255, 255, 100))
        end
    end
end

function menuClick(gomb, stat, x, y)
	if not show then
		return
	end
	if isPedInVehicle(localPlayer) and gomb == "left" and stat == "down" and getPedOccupiedVehicle(localPlayer) then
		if dobozbaVan(sx / 2 - 90, sy / 2 + 55, 25, 25, x, y) then
		if (getElementData(getPedOccupiedVehicle(localPlayer), "vehicle:radio:status") or 0) == 1 and 1 < designation then
			designation = designation - 1
			setElementData(getPedOccupiedVehicle(localPlayer), "vehicle:radio", designation)
			setSoundVolume(playSound("files/stationswitch.mp3"), 0.2)
		end
		elseif dobozbaVan(sx / 2 - 90 + 160, sy / 2 + 55, 25, 25, x, y) then
		if (getElementData(getPedOccupiedVehicle(localPlayer), "vehicle:radio:status") or 0) == 1 and designation < #musicTable then
			designation = designation + 1
			setSoundVolume(playSound("files/stationswitch.mp3"), 0.2)
			setElementData(getPedOccupiedVehicle(localPlayer), "vehicle:radio", designation)
		end
		elseif dobozbaVan(sx / 2 - 50, sy / 2 + 20, 25, 25, x, y) then
		if (getElementData(getPedOccupiedVehicle(localPlayer), "vehicle:radio:status") or 0) == 1 then
			hangero = 0
			setElementData(getPedOccupiedVehicle(localPlayer), "vehicle:radio:volume", hangero)
			triggerServerEvent("car:radio:vol", getLocalPlayer(), tonumber(hangero))
		end
		elseif dobozbaVan(sx / 2 - 25, sy / 2 + 50, 40, 40, x, y) then
		if (getElementData(getPedOccupiedVehicle(localPlayer), "vehicle:radio:status") or 0) == 0 then
			setElementData(getPedOccupiedVehicle(localPlayer), "vehicle:radio:status", 1)
			designation = 1
			setElementData(getPedOccupiedVehicle(localPlayer), "vehicle:radio", designation)
			setSoundVolume(playSound("files/poweronoff.mp3", false), 0.2)
			print(designation)
		else
			setElementData(getPedOccupiedVehicle(localPlayer), "vehicle:radio:status", 0)
			setElementData(getPedOccupiedVehicle(localPlayer), "vehicle:radio", 0)
			designation = 0
			setSoundVolume(playSound("files/poweronoff.mp3", false), 0.2)
		end
		end
		triggerServerEvent("car:radio:sync", getLocalPlayer(), designation)
	end
end
addEventHandler("onClientClick",getRootElement(),menuClick)

--<[ Görgetés ]>--
bindKey("mouse_wheel_down", "down",
	function()
		if show and isPedInVehicle(localPlayer) then
			local theVehicle = getPedOccupiedVehicle(getLocalPlayer())
			local hangero = getElementData(theVehicle, "vehicle:radio:volume") or 25
			if hangero > 0 and hangero <= 105 then
				hangero = hangero - 10
				setElementData(theVehicle, "vehicle:radio:volume", hangero)
				triggerServerEvent("car:radio:vol", getLocalPlayer(), tonumber(hangero))
			end
		end
	end
)


bindKey("mouse_wheel_up", "down",
	function()
		if show and isPedInVehicle(localPlayer) then
			local theVehicle = getPedOccupiedVehicle(getLocalPlayer())
			local hangero = getElementData(theVehicle, "vehicle:radio:volume") or 25
			if hangero < 100 then
				hangero = hangero + 10
				setElementData(theVehicle, "vehicle:radio:volume", hangero)
				triggerServerEvent("car:radio:vol", getLocalPlayer(), tonumber(hangero))
			end
		end
	end
)
--<[ Görgetés vége ]>--

function dobozbaVan(dX, dY, dSZ, dM, eX, eY)
	if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
		return true
	else
		return false
	end
end

function isCursorOnBox(xS,yS,wS,hS)
	if(isCursorShowing()) then
		XY = {guiGetScreenSize()}
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*XY[1], cursorY*XY[2]
		if(cursorX >= xS and cursorX <= xS+wS and cursorY >= yS and cursorY <= yS+hS) then
			return true
		else
			return false
		end
	end
end

addEventHandler("onClientElementDestroy", getRootElement(), function ()
	local radio = getElementData(source, "vehicle:radio") or 0

	if getElementType(source) == "vehicle" and radio ~= 0 then
		if isElement(newSoundElement) then
			stopSound(newSoundElement)
		end
		setElementData(source, "vehicle:radio", 0)
	end
end)

addEventHandler ( "onClientElementDataChange", getRootElement(),

	function ( dataName )
		if getElementType ( source ) == "vehicle" and dataName == "vehicle:radio" then
				local newStation =  getElementData(source, "vehicle:radio") or 0

				if (isElementStreamedIn (source)) then
					if newStation ~= 0 then
						if (soundElementsOutside[source]) then
							stopSound(soundElementsOutside[source])
						end

						local x, y, z = getElementPosition(source)

						local song = nil

						song = musicTable[newStation][1]
						newSoundElement = playSound3D(song, x, y, z, true)
						soundElementsOutside[source] = newSoundElement
						updateLoudness(source)
						setElementDimension(newSoundElement, getElementDimension(source))
						setElementDimension(newSoundElement, getElementDimension(source))
					else
						if (soundElementsOutside[source]) then
							stopSound(soundElementsOutside[source])
							soundElementsOutside[source] = nil
						end
					end
				end
		elseif getElementType(source) == "vehicle" and dataName == "vehicle:windowstat" then
			if (isElementStreamedIn (source)) then
				if (soundElementsOutside[source]) then
					updateLoudness(source)
				end
			end
		elseif getElementType(source) == "vehicle" and dataName == "vehicle:radio:volume" then
			if (isElementStreamedIn (source)) then
				if (soundElementsOutside[source]) then
					updateLoudness(source)
				end
			end
		end
	end
)

addEventHandler("onClientPlayerRadioSwitch", getLocalPlayer(), function()
	cancelEvent()
end)

function updateLoudness(theVehicle)
	if (soundElementsOutside[theVehicle]) then

		local windowState = getElementData(theVehicle, "vehicle:windowstat") or 1

		local carVolume = getElementData(theVehicle, "vehicle:radio:volume") or 25

		carVolume = carVolume / 100
		--  ped is inside
		if (getPedOccupiedVehicle( getLocalPlayer() ) == theVehicle) then
			setSoundMinDistance(soundElementsOutside[theVehicle], 8)
			setSoundMaxDistance(soundElementsOutside[theVehicle], 70)
			setSoundVolume(soundElementsOutside[theVehicle], 0.6775*carVolume)
		elseif (getVehicleType(theVehicle) == "Boat") then
			setSoundMinDistance(soundElementsOutside[theVehicle], 25)
			setSoundMaxDistance(soundElementsOutside[theVehicle], 50)
			setSoundVolume(soundElementsOutside[theVehicle], 0.6725*carVolume)
		elseif (windowState == 1) then --letekerve az ablak
			setSoundMinDistance(soundElementsOutside[theVehicle], 5)
			setSoundMaxDistance(soundElementsOutside[theVehicle], 15.5)
			setSoundVolume(soundElementsOutside[theVehicle], 0.6725*carVolume)
		elseif (windowState == 0 ) then --feltekerve az ablak
			setSoundMinDistance(soundElementsOutside[theVehicle], 3)
			setSoundMaxDistance(soundElementsOutside[theVehicle], 7.5)
			setSoundVolume(soundElementsOutside[theVehicle], 0.6725*carVolume)
		else
			setSoundMinDistance(soundElementsOutside[theVehicle], 3)
			setSoundMaxDistance(soundElementsOutside[theVehicle], 10)
			setSoundVolume(soundElementsOutside[theVehicle], 0.6725*carVolume)
		end
	end
end

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

function spawnSound(theVehicle)
		local newSoundElement = nil
    if getElementType( theVehicle ) == "vehicle" then

			local radioStation = getElementData(theVehicle, "vehicle:radio") or 0
			if radioStation ~= 0 then
				if (soundElementsOutside[theVehicle]) then
					stopSound(soundElementsOutside[theVehicle])
				end

				local x, y, z = getElementPosition(theVehicle)

				song = musicTable[radioStation][1]
				newSoundElement = playSound3D(song, x, y, z, true)
				soundElementsOutside[theVehicle] = newSoundElement
				setElementDimension(newSoundElement, getElementDimension(theVehicle))
				setElementDimension(newSoundElement, getElementDimension(theVehicle))
				updateLoudness(theVehicle)
			end
    end
end


function removeTheEvent()
	removeEventHandler("onClientPreRender", getRootElement(), showStation)
	textShowing = false
end



function saveRadio(station)

	cancelEvent()
	local radios = 0
	if (station == 0) then
		return
	end
	local vehicle = getPedOccupiedVehicle(getLocalPlayer())

	if (vehicle) then

		if getVehicleOccupant(vehicle) == getLocalPlayer() or getVehicleOccupant(vehicle, 1) == getLocalPlayer() then
			if (station == 12) then
				if (radio == 0) then
					radio = totalStreams + 1
				end

				if (streams[radio - 1]) then
					radio = radio - 1
				else
					radio = 0
				end
			elseif (station == 0) then
				if (streams[radio+1]) then
					radio = radio+1
				else
					radio = 0
				end
			end
			if not textShowing then
				addEventHandler("onClientPreRender", getRootElement(), showStation)
				if (isTimer(theTimer)) then
					resetTimer(theTimer)
				else
					theTimer = setTimer(removeTheEvent, 6000, 1)
				end
				textShowing = true
			else
				removeEventHandler("onClientPreRender", getRootElement(), showStation)
				addEventHandler("onClientPreRender", getRootElement(), showStation)
				if (isTimer(theTimer)) then
					resetTimer(theTimer)
				else
					theTimer = setTimer(removeTheEvent, 6000, 1)
				end
			end
			triggerServerEvent("car:radio:sync", getLocalPlayer(), radio)
		end
	end
end



addEventHandler( "onClientElementStreamIn", getRootElement( ),
    function ( )
			spawnSound(source)
    end
)


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
