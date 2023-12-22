level = -50
highlevel = 0
local floodWater1
local speed = tonumber(getElementData(root, "flooding:speed")) or 0.005

function setAllWatersLevel(level)
	if isElement(floodWater1) then
		if (getElementType(floodWater1) == "water") then
			if level > 0 then
				setWaterLevel(level)
			end
			setWaterLevel(floodWater1, level)
		end
	end
end

function waterLevel ( source,  glevel )
	highlevel = tonumber ( glevel )
	if (highlevel == nil) then
		highlevel = 0
	end
	if (highlevel ~= level) then
		if ( isTimer(waterTimer)) then
			killTimer(waterTimer)
		end
		if (highlevel > level) then
			waterTimer = setTimer ( addSomeWater, 100, 0, highlevel )
		else
			waterTimer = setTimer ( removeSomeWater, 100, 0, highlevel )
		end
		outputDebugString("Vízszint átírva " .. getPlayerName ( source ) .. " | " .. highlevel .. ".", 3 )
	end
end
addEvent( "onWaterLevel", true )
addEventHandler( "onWaterLevel", getRootElement(), waterLevel )

function showClientGui(source, command, highlevel)
	if getElementData(source, "acc.adminLevel") >= 9 then
		triggerClientEvent(source, "onShowWindow", getRootElement(), level, "true", highlevel)
	end
end
addCommandHandler("water", showClientGui)

addCommandHandler("setwater", function(source, command, changeto)
	if getElementData(source, "acc.adminLevel") >= 9 then
		if not changeto then
			outputChatBox("[COSMO] /"..command.." [Sebesség]", source, 100, 100, 255, true)
		else
			local changeto = tonumber(changeto) or 0
			setElementData(root, "flooding:speed", changeto)
			speed = changeto
			outputChatBox("[COSMO] Sebesség átírva:"..changeto, source, 100, 100, 255, true)
		end
	end
end)

function addSomeWater(highlevel)
	local thelevel = level
	level = thelevel + speed

	setAllWatersLevel(level)
	
	if (level >= highlevel) then
		level = highlevel
		if ( isTimer(waterTimer)) then
			killTimer(waterTimer)
		end
	end
end

function removeSomeWater(highlevel)
	local thelevel = level
	level = thelevel - speed
	
	setAllWatersLevel(level)
	
	if (level <= highlevel) then
		level = highlevel
		if ( isTimer(waterTimer)) then
			killTimer(waterTimer)
		end
	end
end

function initialize()
	resetWaterLevel()
	floodWater1 = createWater(-2998, -2998, level, 2998, -2998, level, -2998, 2998, level, 2998, 2998, level)
	for i=1,6 do
		if i == 2 or i == 4 or i == 6 then
			floodWater1 = createWater(-2998, -2998, level, 2998, -2998, level, -2998, 2998, level, 2998, 2998, level)
		else
			if isElement(floodWater1) then destroyElement(floodWater1) end
		end
	end
end
addEventHandler("onResourceStart", resourceRoot, initialize)

function destroy()
	if isTimer(waterTimer) then
		killTimer(waterTimer)
	end
	destroyElement(floodWater1)
	resetWaterLevel()
end
addEventHandler("onResourceStop", resourceRoot, destroy)

function onPlayerJoin()
	setAllWatersLevel(level)
end
addEventHandler("onPlayerJoin", getRootElement(), onPlayerJoin)