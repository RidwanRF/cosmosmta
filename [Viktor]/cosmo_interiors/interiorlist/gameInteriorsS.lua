addEvent("warpToGameInterior", true)
addEventHandler("warpToGameInterior", getRootElement(),
	function (interiorId, gameInterior)
		if isElement(source) then
			if gameInterior then
				setElementPosition(source, gameInterior.position[1], gameInterior.position[2], gameInterior.position[3])
				setElementRotation(source, gameInterior.rotation[1], gameInterior.rotation[2], gameInterior.rotation[3])
				setElementInterior(source, gameInterior.interior)
				setElementDimension(source, 0)
				setCameraInterior(source, gameInterior.interior)
				outputChatBox("#ff9428[CosmoMTA]: #ffffffSikeresen elteleportáltál a kiválasztott interior belsőbe. #ff9428([" .. interiorId .. "] " .. gameInterior.name .. ")", source, 255, 255, 255, true)
			end
		end
	end)