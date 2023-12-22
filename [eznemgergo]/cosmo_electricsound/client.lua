function setVehicleSound()
    if getPedOccupiedVehicle(localPlayer) then
        if getElementModel(getPedOccupiedVehicle(localPlayer)) == 600 then 
            local theVehicle = getPedOccupiedVehicle(localPlayer)   
            setVehicleHandling(theVehicle,"engineType","electric")
            print("Hang leveve")
        end
    end
end
addEventHandler("onClientResourceStart", root, setVehicleSound)