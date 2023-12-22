addEvent("clientBackfire >> create", true)
addEventHandler("clientBackfire >> create", root, function(vehicle)

	triggerClientEvent(root, "serverBackfire >> create", root, vehicle)

end)