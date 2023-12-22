function elkaparASzar()
    local Vehicle = getPedOccupiedVehicle(localPlayer)
    if Vehicle then
        local Gear = getVehicleCurrentGear(Vehicle)
        if getElementModel(getPedOccupiedVehicle(localPlayer)) == 426 then
            if Gear == 2 or Gear == 1 then
                triggerServerEvent("setBetterVehicle", localPlayer, Vehicle)
            else
                triggerServerEvent("setBetterVehicleBACK", localPlayer, Vehicle)
            end
        end
    end
end
addEventHandler("onClientPreRender", getRootElement(), elkaparASzar)