pcall(loadstring(base64Decode(exports.cosmo_core:getInterfaceElements())));addEventHandler("onCoreStarted",root,function(functions) for k,v in ipairs(functions) do _G[v]=nil;end;collectgarbage();pcall(loadstring(base64Decode(exports.cosmo_core:getInterfaceElements())));end)

local sx, sy = guiGetScreenSize()
local currentATM = nil
local effects = {}
local effects2 = {}

local panelW = 258
local panelH = 366

local panelX = sx / 2 - panelW / 2
local panelY = sy / 2 - panelH / 2

local casettePanel = false
local casette = {
	[1] = true,
	[2] = true,
	[3] = true,
	[4] = true,
}

local robberyStopTimer = {}

addEventHandler("onClientResourceStart", getRootElement(),
	function()
		engineImportTXD(engineLoadTXD("files/atmrob/flex.txd"), 7312)
		engineReplaceModel(engineLoadDFF("files/atmrob/flex.dff"), 7312)
	end
)

addEventHandler("onClientPlayerQuit", getRootElement(), 
	function()
		removeEventHandler("onClientRender", root, renderCutting)
		triggerServerEvent("removeEffectSync", localPlayer, currentATM)
		triggerServerEvent("stopATMRob", localPlayer, localPlayer, currentATM)
		if currentATM then
			if isTimer(grinderTimer) then killTimer(grinderTimer) end 

			setElementData(currentATM, "atm.robberyInUse", false)

			triggerServerEvent("destroyATMSound3d", localPlayer, getElementsByType("player"), localPlayer, getElementData(currentATM, "atm.id"))
		end
		
		setElementFrozen(localPlayer, false)
		toggleAllControls(true)	
	end
)

-- function checkRobbedATM()
-- 	local cameraX, cameraY, cameraZ = getCameraMatrix()
	
-- 	for i, v in pairs(getElementsByType("object", root, true)) do
-- 		if isElement(v) then
-- 			if getElementType(v) == "object" and getElementData(v, "atm.id") then
-- 				local health = tonumber(getElementData(v, "atm.health")) or 100

-- 				if health == 0 then
-- 					local x, y, z = getElementPosition(v)
-- 					local atmX, atmY = getScreenFromWorldPosition(x, y, z + 1.5, 0, false)
					
-- 					if atmX and atmY then
-- 						local distance = getDistanceBetweenPoints3D(cameraX, cameraY, cameraZ, x, y, z)
-- 						if distance <= 15 then
-- 							local pictureSizeX = 180 * 0.4
-- 							local pictureSizeY = 280 * 0.4
-- 							local picturePosX = atmX - pictureSizeX * 0.4
-- 							local picturePosY = atmY - pictureSizeY * 0.4
							
-- 							dxDrawImage(picturePosX, picturePosY, pictureSizeX, pictureSizeY, "files/atmrob/outoforder.png", 0, 0, 0, tocolor(222, 44, 77, 245))
-- 						end
-- 					end
-- 				end
-- 			end
-- 		end	
-- 	end
-- end
-- addEventHandler("onClientRender", root,checkRobbedATM)

function renderCutting()
	if currentATM then
		if getKeyState("mouse1") and not isCursorShowing() then
			if tonumber(getElementHealth(localPlayer)) <= 0 then
				if isTimer(grinderTimer) then killTimer(grinderTimer) end 
				if isTimer(robberyStopTimer[currentATM]) then killTimer(robberyStopTimer[currentATM]) end

				robberyStopTimer[currentATM] = setTimer(
					function(currentATM)
						if tonumber(currentATM:getData("atm.health") or 0) > 0 then 
							currentATM:setData("atm.robbery", false)
							currentATM:setData("atm.health", 100)
						end
					end, 1 * 60 * 1000, 1, currentATM
				)

				removeEventHandler("onClientRender", root, renderCutting)
				triggerServerEvent("removeEffectSync", localPlayer, currentATM)
				triggerServerEvent("stopATMRob", localPlayer, localPlayer, currentATM)
				setElementData(currentATM, "atm.robberyInUse", false)

				triggerServerEvent("destroyATMSound3d", localPlayer, getElementsByType("player"), localPlayer, getElementData(currentATM, "atm.id"))

				local x,y,z = getElementPosition(localPlayer)
				local interior, dimension = getElementInterior(localPlayer), getElementDimension(localPlayer)	
				triggerServerEvent("playATMSound3d", localPlayer, getElementsByType("player", getRootElement(), true), localPlayer, "3d", "files/atmrob/grinder_stop.mp3", {x,y,z,interior,dimension})
				
				setElementFrozen(localPlayer,false)
				toggleAllControls(true)
				return
			end
		
			local aX, aY, aZ = getElementPosition(currentATM)
			local realX, realY = getScreenFromWorldPosition(aX, aY, aZ + 1, 0, false)
			
			if realX and realY then
				local dx = 200
				local dy = 15
				local ax = realX - dx * 0.5
				local ay = realY + 20 - dy
				
				local health = tonumber(getElementData(currentATM, "atm.health")) or 100
				
				dxDrawRectangle(ax - 2, ay - 2, dx + 4, dy + 4, tocolor(0, 0, 0, 175), false, true)
				dxDrawRectangle(ax+1, ay+1, dx * (100 / 100) - 3, dy - 3, tocolor(0, 0, 0, 255), false, true)
				
				if health > 0 then
					dxDrawRectangle(ax+1, ay+1, dx * (health / 100) - 3, dy - 3, tocolor(124, 197, 118, 255), false, true)
				end
				
				if health > 0 then
					setElementData(currentATM, "atm.health", tonumber((health - 0.010)))
				elseif health < 0 then
					setElementData(currentATM, "atm.health", tonumber(0))
				elseif health == 0 then
					if isTimer(grinderTimer) then killTimer(grinderTimer) end 
					if isTimer(robberyStopTimer[currentATM]) then killTimer(robberyStopTimer[currentATM]) end

					robberyStopTimer[currentATM] = setTimer(
						function(currentATM)
							if tonumber(currentATM:getData("atm.health") or 0) > 0 then 
								currentATM:setData("atm.robbery", false)
								currentATM:setData("atm.health", 100)
							end
						end, 1 * 60 * 1000, 1, currentATM
					)

					removeEventHandler("onClientRender", root, renderCutting)
					triggerServerEvent("removeEffectSync", localPlayer, currentATM)
					triggerServerEvent("stopATMRob", localPlayer, localPlayer, currentATM)
					setElementData(currentATM, "atm.robberyInUse", false)

					triggerServerEvent("destroyATMSound3d", localPlayer, getElementsByType("player"), localPlayer, getElementData(currentATM, "atm.id"))

					local x,y,z = getElementPosition(localPlayer)
					local interior, dimension = getElementInterior(localPlayer), getElementDimension(localPlayer)	
					triggerServerEvent("playATMSound3d", localPlayer, getElementsByType("player", getRootElement(), true), localPlayer, "3d", "files/atmrob/grinder_stop.mp3", {x,y,z,interior,dimension})
					
					exports.cosmo_chat:sendLocalMeAction(localPlayer, "befejezte a flexelést.")
					
					casettePanel = true
					addEventHandler("onClientRender", root, showRobPanel)
					addEventHandler("onClientClick", root, casettePanelClick)
				end
			end
		else
			if isTimer(grinderTimer) then killTimer(grinderTimer) end 
			if isTimer(robberyStopTimer[currentATM]) then killTimer(robberyStopTimer[currentATM]) end

			robberyStopTimer[currentATM] = setTimer(
				function(currentATM)
					if tonumber(currentATM:getData("atm.health") or 0) > 0 then 
						currentATM:setData("atm.robbery", false)
						currentATM:setData("atm.health", 100)
					end
				end, 1 * 60 * 1000, 1, currentATM
			)

			removeEventHandler("onClientRender", root, renderCutting)
			triggerServerEvent("removeEffectSync", localPlayer, currentATM)
			triggerServerEvent("stopATMRob", localPlayer, localPlayer, currentATM)
			setElementData(currentATM, "atm.robberyInUse", false)

			triggerServerEvent("destroyATMSound3d", localPlayer, getElementsByType("player"), localPlayer, getElementData(currentATM, "atm.id"))

			local x,y,z = getElementPosition(localPlayer)
			local interior, dimension = getElementInterior(localPlayer), getElementDimension(localPlayer)	
			triggerServerEvent("playATMSound3d", localPlayer, getElementsByType("player", getRootElement(), true), localPlayer, "3d", "files/atmrob/grinder_stop.mp3", {x,y,z,interior,dimension})
			
			setElementFrozen(localPlayer,false)
			toggleAllControls(true)
			exports.cosmo_chat:sendLocalMeAction(localPlayer, "befejezte a flexelést.")
		end
	end
end

function showRobPanel()
	if casettePanel then
		toggleAllControls(false) -- muszáj ide is betenni mert jó az mta
		buttons = {}
		
		dxDrawImage(panelX, panelY, panelW, panelH, "files/atmrob/atm_rob.png", 0, 0, 0, tocolor(255, 255, 255, 255))
		buttons.close = {panelX + panelW - 18, panelY + 3, 15, 15}
		
		for i = 1, 4 do
			dxDrawImage(panelX + 10, panelY - 40 + (i*80), 239, 74, "files/atmrob/atm_rob3.png", 0, 0, 0, tocolor(255, 255, 255, 255))
			if casette[i] then
				dxDrawImage(panelX + 10, panelY - 40 + (i*80), 239, 74, "files/atmrob/atm_rob2.png", 0, 0, 0, tocolor(255, 255, 255, 255))
				buttons["casette:"..i] = {panelX + 10, panelY - 40 + (i*80), 239, 74}
			end
		end
		
		local relX, relY = getCursorPosition()
		
		activeButton = false
		
		if relX and relY then
			relX = relX * sx
			relY = relY * sy
			
			for k, v in pairs(buttons) do
				if relX >= v[1] and relX <= v[1] + v[3] and relY >= v[2] and relY <= v[2] + v[4] then
					activeButton = k
					break
				end
			end
		end
	end
end

function casettePanelClick(button, state)
	if casettePanel then
		if button == "left" and state == "down" and activeButton then
			local selected = split(activeButton, ":")
			
			if selected[1] == "casette" then
				if exports.cosmo_inventory:countEmptySlots() > 0 then
					if exports.cosmo_inventory:getCurrentWeight() + 2 <= 20 then
						if isTimer(spamTimer) then 
							return 
						end 
						spamTimer = setTimer(function() end, 2 * 1000, 1)

						casette[tonumber(selected[2])] = false
						triggerServerEvent("addCasette", localPlayer, localPlayer)

						exports.cosmo_chat:sendLocalMeAction(localPlayer, "kivesz egy kazettát az ATM-ből.")

						local x,y,z = getElementPosition(localPlayer)
						local interior, dimension = getElementInterior(localPlayer), getElementDimension(localPlayer)	
						triggerServerEvent("playATMSound3d", localPlayer, getElementsByType("player", getRootElement(), true), localPlayer, "3d", "files/atmrob/rob.mp3", {x,y,z,interior,dimension})
					else
						exports.cosmo_hud:showInfobox("error", "Nincs nálad elegendő hely!")
					end
				else
					exports.cosmo_hud:showInfobox("error", "Nincs szabad slot az inventoryban!")
				end
			elseif selected[1] == "close" then
				removeEventHandler("onClientRender", root, showRobPanel)
				removeEventHandler("onClientClick", root, casettePanelClick)
				casettePanel = false
				
				-- Itt kell unfreezelni hogy ne a világ végén pakolja ki a kazettákat
				setElementFrozen(localPlayer,false)
				toggleAllControls(true)
			end
		end
	end
end

addEventHandler( "onClientKey", root, function(button,press)
	if getElementData(localPlayer, "canUseFlex") then
		if button == "mouse1" and press and not isCursorShowing() then
			currentATM = nil
	
			for i, v in ipairs(getElementsByType("object")) do
				if isElement(v) then
					if getElementType(v) == "object" and getElementData(v, "atm.id") then
						if exports.cosmo_core:inDistance3D(localPlayer, v, 1) then
							currentATM = v
						end
					end
				end
			end
		
			if currentATM then
				if isTimer(spamTimer) then 
					return 
				end 
				spamTimer = setTimer(function() end, 10 * 1000, 1)

				if not exports.cosmo_groups:isPlayerHavePermission(localPlayer, "atmRob") then return end
				if tonumber(getElementHealth(localPlayer)) <= 0 then return end
				if tonumber(getElementData(currentATM, "atm.health")) == 0 then return end
				if getElementData(currentATM, "atm.robberyInUse") then return end
				if isTimer(grinderTimer) then killTimer(grinderTimer) end 
				if isTimer(robberyStopTimer[currentATM]) then 
					killTimer(robberyStopTimer[currentATM]) 
				end
				
				setElementFrozen(localPlayer,true)
				toggleAllControls(false)
				
				cancelEvent()
				addEventHandler("onClientRender", root, renderCutting)
				
				
				if not getElementData(currentATM, "atm.robbery") then
					-- Ha új ATM-et kezd el vágni akkor vissza rakjuk hogy abból is ki tudjuk venni a kazikat
					for i = 1, 4 do
						casette[i] = true
					end
					exports.cosmo_chat:sendLocalMeAction(localPlayer, "elkezdett flexelni.")
					triggerServerEvent("startATMRob", localPlayer, localPlayer, currentATM)
					triggerServerEvent("syncEffect", localPlayer, currentATM, localPlayer)

					local x,y,z = getElementPosition(localPlayer)
					local interior, dimension = getElementInterior(localPlayer), getElementDimension(localPlayer)
					triggerServerEvent("playATMSound3d", localPlayer, getElementsByType("player", getRootElement(), true), localPlayer, "3d", "files/atmrob/grinder_start.mp3", {x,y,z,interior,dimension})

					grinderTimer = setTimer(
						function()
							triggerServerEvent("playATMSound3d", localPlayer, getElementsByType("player", getRootElement(), true), localPlayer, "3d", "files/atmrob/grinder.mp3", {x,y,z,interior,dimension,true,getElementData(currentATM, "atm.id")})
						end, 0.2 * 1000, 1
					)
				else
					exports.cosmo_chat:sendLocalMeAction(localPlayer, "elkezdett flexelni.")
					triggerServerEvent("atmRobContinue", localPlayer, localPlayer, currentATM)
					triggerServerEvent("syncEffect", localPlayer, currentATM, localPlayer)

					local x,y,z = getElementPosition(localPlayer)
					local interior, dimension = getElementInterior(localPlayer), getElementDimension(localPlayer)
					triggerServerEvent("playATMSound3d", localPlayer, getElementsByType("player", getRootElement(), true), localPlayer, "3d", "files/atmrob/grinder_start.mp3", {x,y,z,interior,dimension})

					grinderTimer = setTimer(
						function()
							triggerServerEvent("playATMSound3d", localPlayer, getElementsByType("player", getRootElement(), true), localPlayer, "3d", "files/atmrob/grinder.mp3", {x,y,z,interior,dimension,true,getElementData(currentATM, "atm.id")})
						end, 0.2 * 1000, 1
					)
				end
			end
		end
	end
end)

local soundCache = {}

addEvent("playATMSound3d", true)
addEventHandler("playATMSound3d", root,
	function (type, path, pos)
		if isElement(source) then
			if type == "3d" then
				local sourcePosX, sourcePosY, sourcePosZ, sourceInterior, sourceDimension, looped, id = unpack(pos)
				local soundElement = playSound3D(path, sourcePosX, sourcePosY, sourcePosZ, looped)

				if id then 
					soundCache[id] = soundElement
				end 

				if isElement(soundElement) then
					setElementInterior(soundElement, sourceInterior)
					setElementDimension(soundElement, sourceDimension)
				end
			else
				playSound(path)
			end
		end
	end
)

addEvent("destroyATMSound3d", true)
addEventHandler("destroyATMSound3d", root,
	function (id)
		if isElement(source) then
			if soundCache[id] then 
				destroyElement(soundCache[id])
				soundCache[id] = nil
			end 
		end
	end
)

addEvent("createEffects", true)
addEventHandler("createEffects", root,
	function(object, pPos, rPos, player)
		if not effects[object] then
			effects[object] = {}
		end
		if not effects2[object] then
			effects2[object] = {}
		end
		
		local oPos = {getElementPosition(object)}
		local rightRot = findRotation(pPos[1], pPos[2], oPos[1], oPos[2])
		setElementRotation(player, 0, 0, rightRot)
		effects[object] = createEffect("prt_spark", oPos[1], oPos[2], oPos[3]+0.5, 0, 0, 130 - rightRot)
		effects2[object] = createEffect("prt_spark", oPos[1], oPos[2], oPos[3]+0.5, 0, 0, 130 - rightRot)
	end
)

addEvent("removeEffect", true)
addEventHandler("removeEffect", root,
	function(object)
		if isElement(effects[object]) then
			destroyElement(effects[object])
			effects[object] = {}
		end
		if isElement(effects2[object]) then
			destroyElement(effects2[object])
			effects2[object] = {}
		end
	end
)

function createATMBlip(object)
	if isElement(object) then
		if gpsBlips[object] and isElement(gpsBlips[object]) then
			destroyElement(gpsBlips[object])
		end	
	
		gpsBlips[object] = createBlip(0, 0, 0)
		setElementData(gpsBlips[object], "blipIcon", "cp")
		setElementData(gpsBlips[object], "blipTooltipText", "Rablás alatt lévő atm")
		attachElements(gpsBlips[object], object)
		setElementData(gpsBlips[object], "blipColor", tocolor(255, 66, 66))
		setElementData(gpsBlips[object], "blipFarShow", true)
	end
end

addEventHandler("onClientElementDataChange", root,
	function(dataName, oldValue, newValue)
		if getElementType(source) == "object" then
			if dataName == "atm.robbery" then
				if getElementData(source, dataName) then
					if exports.cosmo_groups:isPlayerHavePermission(localPlayer, "cuff") then
						createATMBlip(source)
					end
				elseif oldValue then
					if exports.cosmo_groups:isPlayerHavePermission(localPlayer, "cuff") then
						destroyElement(gpsBlips[source])
					end
				end
			end
		end
		
		if getElementType(source) == "player" and dataName == "loggedIn" then
			if newValue == true then
				setTimer(function()
					for k, v in ipairs(getElementsByType("object")) do
						if isElement(v) then
							if getElementType(v) == "object" and getElementData(v, "atm.id") then
								if getElementData(v, "atm.robbery") then
									if exports.cosmo_groups:isPlayerHavePermission(localPlayer, "cuff") then
										createATMBlip(v)
									end
								end
							end
						end
					end
				end, 2000, 1)
			end
		end
	end
)

function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function toggleWeaponSounds_f ( )
setWorldSoundEnabled(0, 0, false, true)
setWorldSoundEnabled(0, 29, false, true)
setWorldSoundEnabled(0, 30, false, true)
end
addCommandHandler ( "toggleweaponsounds", toggleWeaponSounds_f )