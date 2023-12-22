function registerEvent(event, element, func)
    addEvent(event, true)
    addEventHandler(event, element, func)
end

exports.cosmo_admin:addAdminCommand("addwheelclamp", 6, "Kerékbilincs felrakása!")
addCommandHandler("addwheelclamp", function(player)
    if getElementData(player, "acc.adminLevel") >= 6 then
        addWheelClamp(getPedOccupiedVehicle(player))
    end
end)

exports.cosmo_admin:addAdminCommand("removewheelclamp", 6, "Kerékbilincs levétele!")
addCommandHandler("removewheelclamp", function(player)
    if getElementData(player, "acc.adminLevel") >= 6 then
        removeWheelClamp(getPedOccupiedVehicle(player))
    end
end)

function addWheelClamp(vehicle)
    if isElement(vehicle) and getElementType(vehicle) == "vehicle" then
        setElementData(vehicle, "vehicle.wheelClamp", true)
    end
end


function removeWheelClamp(vehicle)
    if isElement(vehicle) and getElementType(vehicle) == "vehicle" then
        setElementData(vehicle, "vehicle.wheelClamp", false)
    end
end

registerEvent("cosmo_wheelclampS:applyAnimation", root, function(state)
    print(state)
    if state then
        setPedAnimation(source, "bomber", "bom_plant_loop", -1, true, false)
    else
        setPedAnimation(source)
    end
end)