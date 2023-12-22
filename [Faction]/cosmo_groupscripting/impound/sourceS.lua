local connection = false

addEventHandler("onResourceStart", getRootElement(),
    function (startedResource)
        if getResourceName(startedResource) == "cosmo_database" then
            connection = exports.cosmo_database:getConnection()
        elseif source == getResourceRootElement() then
            if getResourceFromName("cosmo_database") and getResourceState(getResourceFromName("cosmo_database")) == "running" then
                connection = exports.cosmo_database:getConnection()
            end
        end
    end
)

function registerEvent(eventName, element, ...)
	addEvent(eventName, true)
	addEventHandler(eventName, element, ...)
end

function impoundVehicle(player, vehicle, reason, price, canGet, impoundedDate, expiredDate, impoundedBy)
    local impoundText = reason .. "/" .. price .. "/" .. tostring(canGet) .. "/" .. impoundedDate .. "/" .. expiredDate .. "/" .. impoundedBy
    dbExec(connection, "UPDATE vehicles SET impound = ? WHERE vehicleID = ?", impoundText, getElementData(vehicle, "vehicle.dbID"))
    setElementData(vehicle, "vehicle.impound", impoundText)
    exports.cosmo_alert:showInfobox(player, "info", "Sikeresen lefoglaltad a járművet")

    for k, v in pairs(getVehicleOccupants(vehicle)) do
        removePedFromVehicle(v)
    end

    setElementDimension(vehicle, 65000)
	setElementPosition(vehicle, 1717.0002441406, -3266.2478027344, -9.4034767150879)
end
registerEvent("cosmo_impoundS:impoundVehicle", root, impoundVehicle)

local spawnPositions = {
    {1562.7181396484, -1722.765625, 13.076086997986, 88},
    {1567.0974121094, -1722.2524414063, 13.076949119568, 88},
    {1573.0791015625, -1722.1400146484, 13.074376106262, 88},
    {1577.0762939453, -1721.796875, 13.075749397278, 88},
}

function getVehicle(player, vehicle, price)
    --outputChatBox(price .. " " .. tostring(player) .. " " .. tostring(vehicle))
	if getElementData(player,"char.Money") >= 6000000 then
    --if exports.cosmo_core:takeMoney(player, 0) then
        print("Kiváltva")
        removeElementData(vehicle, "vehicle.impound")
        dbExec(connection, "UPDATE vehicles SET impound = NULL WHERE vehicleID = ?", getElementData(vehicle, "vehicle.dbID"))
        local rnd = math.random(1, #spawnPositions)
        setElementPosition(vehicle, spawnPositions[rnd][1], spawnPositions[rnd][2], spawnPositions[rnd][3])
        setElementRotation(vehicle, 0, 0, spawnPositions[rnd][4])
        setElementDimension(vehicle, 0)
        setElementInterior(vehicle, 0)
		fixVehicle(vehicle)
    else
        print("No")
        exports.cosmo_alert:showInfobox(player, "error", "Nincs elég pénzed a kiváltáshoz")
    end
end
registerEvent("cosmo_impoundS:getVehicle", root, getVehicle)
