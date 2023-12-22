addEvent("spawnTrailer", true)
addEventHandler("spawnTrailer", root, function(data)
	if data then
		local freight = freights[data[1]]
		local destination = deliveryPoints[data[2]]
		local current = deliveryPoints[data[3]]

		print("Jelenleg:", data[3], deliveryPoints[data[3]].name)
		print("Cél:", data[2], deliveryPoints[data[2]].name)

		outputChatBox("Sikeresen kiválasztottad a pót kocsit!. Csatlakoztassa a pótkocsiját a teherautóhoz,és vigye el a kiválasztott helyre (Zöld jelzés).", source, 0, 255, 0)

		local trailer = createVehicle(freight.model, current.pickupPoint[1], current.pickupPoint[2], current.pickupPoint[3], 0, 0, current.pickupPoint[4]) 
		setElementData(trailer, "trailer.owner", source)
		setElementData(trailer, "trailer.destinationId", data[2])
		setElementData(trailer, "trailer.freightId", data[1])
		setElementData(source, "player.trailer", trailer)
	end
end)

addEvent("deleteTrailer", true)
addEventHandler("deleteTrailer", root, function()
	local trailer = getElementData(source, "player.trailer")

	if isElement(trailer) then
		destroyElement(trailer)
	end

	removeElementData(source, "player.trailer")
end)