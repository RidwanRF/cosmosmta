local hornVehicle = {}

--[[function customHorn()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    triggerServerEvent("playHornSound", localPlayer, vehicle)
end--]]

function customHornOn ( key, keyState )
  if ( keyState == "down" ) then
  end
  local vehicle = getPedOccupiedVehicle(localPlayer)
  triggerServerEvent("playHornSound", localPlayer, vehicle)
end

function customHornOff ( key, keyState )
  if ( keyState == "up" ) then
  end
  local vehicle = getPedOccupiedVehicle(localPlayer)
  triggerServerEvent("playHornSound", localPlayer, vehicle)
end
 
addEventHandler("onClientVehicleEnter", getRootElement(),function(thePlayer, seat)
    if localPlayer == thePlayer then
        if tonumber(getElementData(source, "danihe->vehicles->customhorn")) >= 1 then
            bindKey("h", "down", customHornOn)
            bindKey("h", "up", customHornOff)
            toggleControl( 'horn', false ) 
        end
    end
end)
addEventHandler("onClientVehicleExit", getRootElement(), function(thePlayer, seat)
    if localPlayer == thePlayer then
        toggleControl( 'horn', true ) 
        unbindKey("h", "down", customHornOn)
        unbindKey("h", "up", customHornOff)
    end
end)

function playHornSoundClient(soundPath)
if not (hornVehicle[source]) then
local x,y,z = getElementPosition(source)
hornVehicle[source] = playSound3D(soundPath, x, y, z, true)
setElementInterior(hornVehicle[source], getElementInterior(source))
setElementDimension(hornVehicle[source], getElementDimension(source))
attachElements(hornVehicle[source], source)
setSoundMinDistance(hornVehicle[source], 1)
setSoundMaxDistance(hornVehicle[source], 150)
elseif (hornVehicle[source]) then
stopSound(hornVehicle[source])
hornVehicle[source] = nil
end
end
addEvent("playHornSoundClient", true)
addEventHandler ( "playHornSoundClient", getRootElement(), playHornSoundClient )